#!/bin/bash
# Script creates a simple repository like pypi in a folder named 'packages' in current working directory. packages will contain a folder for each Python package/project
# that is in top downloaded in last 365 days (credits @hugovk.github,io). Each package's folder will contain .whl and .tar.gz
# of the package's 4 latest version as applicable. Steps:
# 1. Signup and get API key as mentioned in https://pypi.org/help/#apitoken
# 2. Copy this script into a folder 
# 3. Create file with package names in each line. Eg: https://github.com/harisankar-krishna-swamy/bash-scripts/blob/main/data/packages.txt
# 4. Run as
# parallel --jobs 5 --eta ./create_pypi_repository.sh :::: a_file_with_package_names_per_line ::: number_of_versions_to_save
# Example: to save past 4 versions of each package
# parallel --jobs 5 --eta ./create_pypi_repository.sh :::: packages.txt ::: 4
# 3. Once finished run an https/http server on 'packages' folder and use it in pip as
# 4. "pip install --index-url https://yourl_local_pypi_host:port python_package_name"

PACKAGES_DIR="packages"
PACKAGE_NAME=$1
VERSIONS=$2
PACKAGE_URL="https://pypi.org/pypi/$PACKAGE_NAME/json"
PACKAGES_META_TEMP="/tmp/pkg_meta"

PYPI_API_KEY="Your PYPI API Key here"

PYPI_CREDENTIAL="__token__:$PYPI_API_KEY"

mkdir -p $PACKAGES_META_TEMP

mkdir -p $PACKAGES_DIR/$PACKAGE_NAME
cd $PACKAGES_DIR/$PACKAGE_NAME


curl -u $PYPI_CREDENTIAL -L $PACKAGE_URL | python3 -c "import sys, json; versions=list(json.load(sys.stdin)['releases'].keys())[-$VERSIONS:]; print(versions)" | tr -d "'[] " | tr -s ',' '\n' > $PACKAGES_META_TEMP/$PACKAGE_NAME

if [ $? -ne 0 ]
then
   echo "ERROR: curl failed for $PACKAGE_URL"
   exit 1
fi

for version in `cat $PACKAGES_META_TEMP/$PACKAGE_NAME`;
do
   python -m pip download --disable-pip-version-check --no-cache-dir --no-deps --no-use-pep517 $PACKAGE_NAME==$version
   python -m pip download --disable-pip-version-check --no-binary :all: --no-cache-dir --no-deps --no-use-pep517 $PACKAGE_NAME==$version
done

[ -f "$PACKAGES_META_TEMP/$PACKAGE_NAME" ] && rm $PACKAGES_META_TEMP/$PACKAGE_NAME
