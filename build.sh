#!/bin/bash

set -euo pipefail

./init.sh
source venv/bin/activate
pip wheel --no-binary ':all:' --no-deps numpy==1.19.4 -w dist


