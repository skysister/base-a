#!/bin/sh

# CONFIGURE SERVICES
#################################
for filename in /usr/local/bin/config/*.sh; do
  $filename 2>&1
done

# START SERVICES
#################################
for filename in /usr/local/bin/init/*.sh; do
  $filename 2>&1
done
