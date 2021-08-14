#!/bin/bash

rm -rf dist/* 2>/dev/null

set -euo pipefail

./build.sh
