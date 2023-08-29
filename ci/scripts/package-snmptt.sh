#!/bin/sh
set -eux

# ref=$(< .git/refs)
# version=${ref#v} # v1.5.0 -> 1.5.0
version=${1#v}

rpmdev-setuptree

# cp ./ci/files/snmptt.service /root/rpmbuild/SOURCES/
cp ./ci/files/snmptt.service ./rpmbuild/SOURCES/

sed -re "s/^(Version: ).+/\1${version}/" \
  ./ci/files/snmptt.spec > ./rpmbuild/SPECS/snmptt.spec

tar --create --gzip \
  --directory=snmptt-repo \
  --exclude=docs/build \
  --file=./rpmbuild/SOURCES/snmptt-${version}.tgz \
  snmptt/

rpmbuild -ba ./rpmbuild/SPECS/snmptt.spec

find ./rpmbuild/RPMS/ \
  -name '*.noarch.rpm' -exec cp {} package/ \; , \
  -name '*.noarch.rpm' -exec rpm --query --info --package {} \;
  
