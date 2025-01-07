#!/bin/bash

# Configure PHP
echo "Configuring php..."

PHPCONF=/etc/php/8.3/cli/php.ini
echo "  Applying configuration changes to $PHPCONF"
sed -i '/error_reporting =/c\error_reporting = E_ALL' $PHPCONF
sed -i 's/variables_order = .*/variables_order = "EGPCS"/' $PHPCONF
sed -i 's/;error_log = syslog/error_log = \/var\/log\/php\/cli-error.log/' $PHPCONF

PHPFPMCONF=/etc/php/8.3/fpm/php.ini
echo "  Applying configuration changes to $PHPFPMCONF"
sed -i '/;date.timezone/c\date.timezone = UTC' $PHPFPMCONF
sed -i 's/variables_order = .*/variables_order = "EGPCS"/' $PHPFPMCONF

if [[ -n ${PHP_UPLOAD_MAX_FILESIZE+x} ]]; then
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = '$PHP_UPLOAD_MAX_FILESIZE'/' $PHPFPMCONF
fi

if [[ -n ${PHP_POST_MAX_SIZE+x} ]]; then
  sed -i 's/post_max_size = 8M/post_max_size = '$PHP_POST_MAX_SIZE'/' $PHPFPMCONF
fi

FPMPOOLCONF=/etc/php/8.3/fpm/pool.d/www.conf
echo "  Applying configuration changes to $FPMPOOLCONF"
sed -i 's/www-data/nginx/' $FPMPOOLCONF
sed -i 's/user  =  www-data/user = nginx/' $FPMPOOLCONF
sed -i 's/group =  www-data/user = nginx/' $FPMPOOLCONF
sed -i 's/;listen.mode/listen.mode/' $FPMPOOLCONF
sed -i "s/;php_flag[display_errors]/php_flag[display_errors]/" $FPMPOOLCONF

ACCESS_LOG="access.log = /var/log/php/fpm-access.log"
grep -sxF $ACCESS_LOG $PHPFPMPOOLCONF || echo $ACCESS_LOG >> $FPMPOOLCONF

FPMCONF=/etc/php/8.3/fpm/php-fpm.conf
echo "  Applying configuration changes to $FPMCONF"
#sed -i '/;log_level = notice/c\log_level = debug' $FPMCONF
sed -i 's/error_log = \/var\/log\/php7.0-fpm.log/error_log = \/var\/log\/php\/fpm-error.log/' $FPMCONF

while IFS='=' read -r name value; do
  if [[ $name == *'BUILD'* ]]; then
    echo "  Adding environment variable $name"
    VAR="env[$name] = $value"
    grep -sxF $VAR $PHPFPMCONF || echo $VAR >> $FPMPOOLCONF
  fi
done < <(env)

while IFS='=' read -r name value; do
  if [[ $name == *'MP'* ]]; then
    echo "  Adding environment variable $name"
    VAR="env[$name] = $value"
    grep -sxF $VAR $PHPFPMCONF || echo $VAR >> $FPMPOOLCONF
  fi
done < <(env)

while IFS='=' read -r name value; do
  if [[ $name == *'SQL'* && $name != *'MYSQL_'* ]]; then
    echo "  Adding environment variable $name"
    VAR="env[$name] = $value"
    grep -sxF $VAR $PHPFPMCONF || echo $VAR >> $FPMPOOLCONF
  fi
done < <(env)
