#!/bin/sh

# ${1} = version tag (e.g. v1.5.1)
# ${2} = build number (e.g. what build run from Jenkins this is)

set -eux

# ref=$(< .git/refs)
# version=${ref#v} # v1.5.0 -> 1.5.0
version=${1#v}
build=${2}
package_dir="${1}-${2}""

rpmdev-setuptree

cp ./ci/files/snmptt.service /root/rpmbuild/SOURCES/

sed -re "s/^(Version: ).+/\1${version}/" \
  ./ci/files/snmptt.spec > /root/rpmbuild/SPECS/snmptt.spec

ls -latr
tar --create --gzip \
  --directory=. \
  --exclude=docs/build \
  --file=/root/rpmbuild/SOURCES/snmptt-${version}.tgz \
  snmptt/

rpmbuild -ba /root/rpmbuild/SPECS/snmptt.spec

mkdir package/
mkdir "package/${package_dir}"
find /root/rpmbuild/RPMS/ \
  -name '*.noarch.rpm' -exec cp {} "package/${package_dir}" \; , \
  -name '*.noarch.rpm' -exec rpm --query --info --package {} \;
