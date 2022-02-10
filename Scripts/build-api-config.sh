#!/bin/sh

# this script injects all the API keys required by the browser

echo "Building API Config"

cp Client/APIConfig-sample.xcconfig Client/APIConfig.xcconfig
sed -i '' "s|\$OPENSEA_API_KEY|$OPENSEA_API_KEY|g" Client/APIConfig.xcconfig
sed -i '' "s|\$CRYPTO_ETH_URL|$CRYPTO_ETH_URL|g" Client/APIConfig.xcconfig
sed -i '' "s|\$CRYPTO_ROPSTEN_URL|$CRYPTO_ROPSTEN_URL|g" Client/APIConfig.xcconfig
sed -i '' "s|\$CRYPTO_POLYGON_URL|$CRYPTO_POLYGON_URL|g" Client/APIConfig.xcconfig
