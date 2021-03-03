#!/usr/bin/env bash

# Only setup virtualenv if we intend on localizing the app.
function setup_virtualenv {
  # Install Python tooling for localizations scripts
  echo password | sudo easy_install pip
  echo password | sudo -S pip install --upgrade pip
  echo password | sudo -S pip install virtualenv
}

#
# Install Node.js dependencies and build user scripts
#

npm install
npm run build

#
# Import only the shipping locales (from shipping_locales.txt) on Release
# builds. Import all locales on Beta and Fennec_Enterprise, except for pull
# requests.
#

git clone https://github.com/mozilla-mobile/ios-l10n-scripts.git || exit 1

if [ "$BUDDYBUILD_SCHEME" = "Neeva" ]; then
  setup_virtualenv
  ./ios-l10n-scripts/import-locales-firefox.sh --release
fi

carthage checkout

(cd content-blocker-lib-ios/ContentBlockerGen && swift run)
