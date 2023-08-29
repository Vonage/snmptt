#!/bin/sh
set -eux

# ref=$(< .git/refs)
# version=${ref#v} # v1.5.0 -> 1.5.0
version=${1#v}

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

mkdir package
mkdir "package/${version}"
find /root/rpmbuild/RPMS/ \
  -name '*.noarch.rpm' -exec cp {} "package/${version}" \; , \
  -name '*.noarch.rpm' -exec rpm --query --info --package {} \;
