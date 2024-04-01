#!/bin/sh

# ${1} = version tag (e.g. v1.5.1)
# ${2} = os name (e.g. centos7, rocky9

set -eux

# ref=$(< .git/refs)
# version=${ref#v} # v1.5.0 -> 1.5.0
version=${1#v}
# build=${2}
# package_dir="${1}-${2}"
package_dir="package-${2}/"

# temp_dir=$(mktemp -d -p $(pwd))

# rpmdev-setuptree --root "${temp_dir}"

mkdir -p ./rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $(pwd))/rpmbuild' > ~/.rpmmacros

cp ./ci/files/snmptt.service "./rpmbuild/SOURCES/"

sed -re "s/^(Version: ).+/\1${version}/" \
  ./ci/files/snmptt.spec > ./rpmbuild/SPECS/snmptt.spec

ls -latr
tar --create --gzip \
  --directory=. \
  --exclude=docs/build \
  --file="./rpmbuild/SOURCES/snmptt-${version}.tgz" \
  snmptt/

rpmbuild -ba ./rpmbuild/SPECS/snmptt.spec

# mkdir package/
mkdir ${package_dir}
# mkdir "package/${package_dir}"
find ./rpmbuild/RPMS/ \
  -name '*.noarch.rpm' -exec cp {} "${package_dir}" \; , \
  -name '*.noarch.rpm' -exec rpm --query --info --package {} \;
