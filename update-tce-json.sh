#!/bin/bash

## You can use this script to replace the default password with your environment variables.
sed -i '' -e 's/VMware!/'"$ESXI_PWD"'/g' tce.tanzu.local.json
sed -i '' -e 's/VMware!/'"$VCSA_PWD"'/g' tce.tanzu.local.json
