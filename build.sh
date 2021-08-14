#!/bin/bash

set -euo pipefail

./init.sh
source venv/bin/activate
pip wheel . -w dist

