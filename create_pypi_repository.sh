#!/bin/bash
# Script creates a simple repository like pypi in a folder named 'packages' in current working directory. packages will contain a folder for each Python package/project
# that is in top downloaded in last 365 days (credits @hugovk.github,io). Each package's folder will contain .whl and .tar.gz
# of the package's 4 latest version as applicable. Steps:
# 1. Signup and get API key as mentioned in https://pypi.org/help/#apitoken
# 2. Copy this script into a folder and run as
# parallel --jobs 5 --eta ./create_pypi_repository.sh :::: <(curl https://hugovk.github.io/top-pypi-packages/top-pypi-packages-365-days.json | tac | tac | grep project | cut -d ':' -f 2 | tr -s ' "' ' ')
# 3. Once finished run an https/http server on 'packages' folder and use it in pip as
# 4. "pip install --index-url https://yourl_local_pypi_host:port python_package_name"

PACKAGES_DIR="packages"
PACKAGE_NAME=$1
PACKAGE_URL="https://pypi.org/pypi/$PACKAGE_NAME/json"

PYPI_API_KEY="INSERT YOUR PYPI API KEY HERE"

PYPI_CREDENTIAL="__token__:$PYPI_API_KEY"

mkdir -p $PACKAGES_DIR 
cd $PACKAGES_DIR
mkdir -p $PACKAGE_NAME
cd $PACKAGE_NAME

curl -u $PYPI_CREDENTIAL -L $PACKAGE_URL | python3 -c "import sys, json; versions=list(json.load(sys.stdin)['releases'].keys())[-4:]; print(versions)" | tr -d "'[] " | tr -s ',' '\n' > /tmp/$PACKAGE_NAME

if [ $? -ne 0 ]
then
   echo "ERROR: curl failed for $PACKAGE_URL"
   exit 1
fi

for version in `cat /tmp/$PACKAGE_NAME`;
do
   python -m pip download --disable-pip-version-check --no-cache-dir --no-deps --no-use-pep517 $PACKAGE_NAME==$version
   python -m pip download --disable-pip-version-check --no-binary :all: --no-cache-dir --no-deps --no-use-pep517 $PACKAGE_NAME==$version
done

[ -f "/tmp/$PACKAGE_NAME" ] && rm /tmp/$PACKAGE_NAME
