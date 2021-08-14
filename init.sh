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
    pip download --no-binary ':all:' numpy==${numpy_version}
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
	    else pip download --no-binary ':all:' numpy==${numpy_version} ; fi
	else pip download --no-binary ':all:' numpy==${numpy_version} ; fi
    else pip download --no-binary ':all:' numpy==${numpy_version} ; fi
fi
set -e


# Deactivate virtual env (and prevent error about unbound variables).
set +u
deactivate
