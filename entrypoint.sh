#!/bin/bash
set -e
bundle exec whenever --update-crontab
service cron start
exec "$@"
