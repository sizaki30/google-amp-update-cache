#!/bin/bash
#
# This script uses the update-cache request to update the contents of the Google AMP cache.
# Docs: https://developers.google.com/amp/cache/update-cache
#

# Specify private key with full path.
private_key='/home/sample/private-key.pem'

if [[ -z $1 ]]; then
  echo 'This script uses the update-cache request to update the contents of the Google AMP cache.'
  echo "Usage: google-amp-update-cache.sh '<url>'"
  echo "Example: google-amp-update-cache.sh 'https://wwww.example.com/article'"
  exit 1
fi

if [[ ! -r ${private_key} ]]; then
  echo 'I do not have a private key or I can not read it.'
  echo 'Please specify private key with full path to private_key variable.'
  exit 2
fi

url=$1
protocol=$(echo ${url} | cut -d / -f 1)
domain=$(echo ${url} | cut -d / -f 3)
page=$(echo ${url} | sed "s/^${protocol}\/\/${domain}//g")
if [[ ${protocol} = 'https:' ]]; then
  content_type='c/s/'
else
  content_type='c/'
fi

domain_amp_format=$(echo ${domain} | sed -e 's/-/--/g' -e 's/\./-/g')

# https://cdn.ampproject.org/caches.json
updateCacheApiDomainSuffix='cdn.ampproject.org'

ts_val=$(date +%s)

if [[ $(echo ${page} | grep ?) ]]; then
  symbol='&'
else
  symbol='?'
fi

update_cache_request="/update-cache/${content_type}${domain}${page}${symbol}amp_action=flush&amp_ts=${ts_val}"

echo -n ${update_cache_request} | openssl dgst -sha256 -sign ${private_key} >.signature.bin

# base64 web-safe
# https://en.wikipedia.org/wiki/Base64#URL_applications
# https://linux.die.net/man/1/base64
echo | base64 -w 0 > /dev/null 2>&1
if [ $? -eq 0 ]; then
  signature_base64=$(base64 -w 0 .signature.bin)
else
  signature_base64=$(base64 .signature.bin)
fi
rm .signature.bin
sig_val=$(echo -n ${signature_base64} | sed -e 's/+/-/g' -e 's/\//_/g' -e 's/=//g')

update_cache_url="https://${domain_amp_format}.${updateCacheApiDomainSuffix}${update_cache_request}\
&amp_url_signature=${sig_val}"

curl $update_cache_url
echo

exit 0

