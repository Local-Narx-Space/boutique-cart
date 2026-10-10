#!/bin/sh
set -eu
mkdir -p /reports
python -m pytest -q tests --junitxml=/reports/junit.xml -o cache_dir=/tmp/pytest-cache
