#!/bin/sh
#build site locally and run

echo "Starting server."
rm -r _site
jekyll serve -c _config.yml,_config_dev.yml
