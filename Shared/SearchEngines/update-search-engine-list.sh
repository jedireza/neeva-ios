#!/bin/zsh

scriptsDir="$(realpath $(dirname $0))"

cd $scriptsDir/../Shared/SearchEngines

echo "Updating prepopulated_engines.json..."
curl https://raw.githubusercontent.com/chromium/chromium/main/components/search_engines/prepopulated_engines.json | sed '/^ *\/\//d' > prepopulated_engines.json

echo "Updating engines_by_country.json..."
curl https://raw.githubusercontent.com/chromium/chromium/main/components/search_engines/template_url_prepopulate_data.cc | python $scriptsDir/parse_template_url_prepopulate_data.py > engines_by_country.json
