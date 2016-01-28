#!/bin/sh
#build site locally and run

echo "Starting server."
jekyll serve -c _config.yml,_config_dev.yml
