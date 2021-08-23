#!/bin/bash

set -euo pipefail

./init.sh
source venv/bin/activate

# Env vars... belt and braces :)
export CC=gcc-11
export CXX=g++-11
export FC=gfortran-11
export NPY_BLAS_ORDER=openblas
export NPY_BLAS_LIBS='-lopenblas'
export NPY_CBLAS_LIBS='-lcublas -lopenblas' # To be frank this is currently guesswork
#                                             (note "cublas" instead of "cblas").
#                                             Can be empty to trigger auto detect..?
export NPY_LAPACK_LIBS='llapack -lblas'
export OPENBLAS=/usr/lib/aarch64-linux-gnu/
export OPENBLAS_CORETYPE=ARMV8

CC="${CC}" \
  CXX="${CXX}" \
  FC="${FC}" \
  NPY_BLAS_ORDER="${NPY_BLAS_ORDER}" \
  NPY_BLAS_LIBS="${NPY_BLAS_LIBS}" \
  NPY_CBLAS_LIBS="${NPY_CBLAS_LIBS}" \
  NPY_LAPACK_LIBS="${NPY_LAPACK_LIBS=}" \
  OPENBLAS="${OPENBLAS}" \
  OPENBLAS_CORETYPE="${OPENBLAS_CORETYPE}" \
  pip wheel -vvv --no-binary 'numpy' --no-deps numpy==1.19.4 -w dist

# echo "Checking if OpenBLAS was used in build, and is available."
# set -e
# for x in $(for f in $(find venv/ -iname "*multiarray*so" | grep -v tests) ; do
# 	       ldd "${f}" ; done | grep '=>' | grep '/lib/' | awk '{print $3}'
# 	  ) ; do
#     ls "${x}" 2>/dev/null >/dev/null
# done
# set +e
# 
# Kudos here for checking if numpy has built successfully with OpenBLAS:
# https://stackoverflow.com/a/37190672
# https://stackoverflow.com/a/9002083
