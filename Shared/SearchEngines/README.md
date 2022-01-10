#  Custom Search Engine support code

The JSON files in this folder are taken from Google Chrome using the `update-search-engine-list.sh` script in this folder.

- `engines_by_country.json` is directly [downloaded from the Chromium repository mirror on GitHub](https://github.com/chromium/chromium/blob/main/components/search_engines/prepopulated_engines.json). (If this file moves at some point, perhaps [this permalink](https://github.com/chromium/chromium/blob/71b8f29aca2ae10f382b11cdf3bf6d70aa95ea8d/components/search_engines/prepopulated_engines.json) will help you locate it.)
- `prepopulated_engines.json` is derived from [`components/search_engines/template_url_prepopulate_data.cc` in the Chromium repository](https://github.com/chromium/chromium/blob/main/components/search_engines/template_url_prepopulate_data.cc). Yes, that’s a C++ source file. The Python script in this folder uses regular expressions to pull out the information we need, and serialize it into JSON. As far as I can tell, this is the canonical source for the relevant information (which countries get to see which search engines).
