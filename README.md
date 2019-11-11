# google-amp-update-cache
This script uses the update-cache request to update the contents of the Google AMP cache. 

## Docs
Before using this script, you need to generate a RSA key pair. You can learn more about this at https://developers.google.com/amp/cache/update-cache

After generating the key pair, place the public key on the server to the path `/.well-known/amphtml/apikey.pub` and set it's mime type to `text/plain`. Place private key somewhere safe and update the script with it's absolute path. Then you can use the script to update AMP cache as follows.

## Usage
```Shell
bash google-amp-update-cache.sh '<url>'
```

## Example
```Shell
bash google-amp-update-cache.sh 'https://wwww.example.com/article'
```

