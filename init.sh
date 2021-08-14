#!/bin/bash

set -euo pipefail

python_version="3.6"
venv_dir="venv"

numpy_version="1.19.4"

pip_version="21.2.4"
setuptools_version="57.4.0"
wheel_version="0.37.0"
build_version="0.6.0"

################################################################################

# See end of this script for explanation of this env var.
export OPENBLAS_CORETYPE=ARMV8

# Fail if desired Python version not available.
python${python_version} --version > /dev/null

# Create virtual env if it's not detected.
if [[ ! -d ${venv_dir} ]] ; then
    python${python_version} -m venv ${venv_dir}
fi

# Activate virtual env (and prevent error about unbound variables).
set +u
source ${venv_dir}/bin/activate
set -u

# Check if pip, setuptools, wheel and build are at expected minimum versions.
echo "Checking build tools."
installed=$(pip list --local --format freeze | grep -v 'pkg-resources')
update_candidates=""
for p in pip setuptools wheel build ; do
    set +e
    current_version=$(echo -n "${installed}" | grep -E '^'${p}'[=><]+' | sed -E -e 's/^.*[=><]+//')
    set -e
    if [[ "x${current_version}" == "x" ]] ; then
	update_candidates="${update_candidates} ${p}"
    else
	read -r current_version_maj current_version_min current_version_patch \
	     <<< $(echo ${current_version} | awk -F'.' '{print $1" "$2" "$3}')
	desired_version=$(eval echo \$$(eval echo \${p}_version))
	read -r desired_version_maj desired_version_min desired_version_patch \
	     <<< $(echo ${desired_version} | awk -F'.' '{print $1" "$2" "$3}')
	if [[ $(echo $((${current_version_maj} < ${desired_version_maj}))) == "0" ]] ; then
	    if [[ $(echo $((${current_version_min} < ${desired_version_min}))) == "0" ]] ; then
		if [[ $(echo $((${current_version_patch} < ${desired_version_patch}))) == "0" ]] ; then
		    :
		else update_candidates="${update_candidates} ${p}" ; fi
	    else update_candidates="${update_candidates} ${p}" ; fi
	else update_candidates="${update_candidates} ${p}" ; fi
    fi
done
do_updates=""
for p in ${update_candidates} ; do
    if [[ ${p} == "pip" ]] ; then p='pip>='${pip_version} ; fi
    if [[ ${p} == "setuptools" ]] ; then p='setuptools>='${setuptools_version} ; fi
    if [[ ${p} == "wheel" ]] ; then p='wheel>='${wheel_version} ; fi
    if [[ ${p} == "build" ]] ; then p='build>='${build_version} ; fi
    do_updates="${do_updates} ${p}"
done
if [[ "x${do_updates}" != "x" ]] ; then pip install --upgrade ${do_updates} ; fi


echo "Checking numpy."
set +e
current_numpy_version=$(echo -n "${installed}" | grep -E '^numpy[=><]+' | sed -E -e 's/^.*[=><]+//')
if [[ "x${current_numpy_version}" == "x" ]] ; then
    set -e
    pip install numpy==${numpy_version}
else
    set -e
    read -r current_version_maj current_version_min current_version_patch \
	 <<< $(echo ${current_numpy_version} | awk -F'.' '{print $1" "$2" "$3}')
    read -r desired_version_maj desired_version_min desired_version_patch \
	 <<< $(echo ${numpy_version} | awk -F'.' '{print $1" "$2" "$3}')
    if [[ $(echo $((${current_version_maj} < ${desired_version_maj}))) == "0" ]] ; then
	if [[ $(echo $((${current_version_min} < ${desired_version_min}))) == "0" ]] ; then
	    if [[ $(echo $((${current_version_patch} < ${desired_version_patch}))) == "0" ]] ; then
		:
	    else pip install numpy==${numpy_version} ; fi
	else pip install numpy==${numpy_version} ; fi
    else pip install numpy==${numpy_version} ; fi
fi
set -e


echo "Checking Python can import numpy successfully."
set +e +u +p pipefail
python -c 'import numpy' 2>&1 > /dev/null
if [[ "$?" != "0" ]] ; then
    echo
    echo "One or more packages failed."
    echo
    exit 1
fi
set -euo pipefail

echo  

installed=$(pip list --local --format freeze --exclude pkg_resources)
numpy_current_version=$(echo -n "${installed}" | grep -E '^numpy[=><]1.19.5+' | sed -E -e 's/^.*[=><]+//')
if [[ "${numpy_current_version}" == "1.19.5" ]] ; then
    echo "Finished! But... there is a BUG in numpy 1.19.5 which you are using."
    echo "See: https://github.com/numpy/numpy/issues/18131"
    echo "Workaround: https://forums.developer.nvidia.com/t/cupy-crashes-on-jetson-nano/169103/3"
    echo "Do this:"
    echo "    export OPENBLAS_CORETYPE=ARMV8"
    echo "before running Python scripts/REPLs/etc."
else
    echo "Finished!"
fi
echo

# Deactivate virtual env (and prevent error about unbound variables).
set +u
deactivate
