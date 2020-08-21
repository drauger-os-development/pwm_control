#!/bin/bash
# -*- coding: utf-8 -*-
#
#  build-rpm.sh
#
#  Copyright 2020 Thomas Castleman <contact@draugeros.org>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#
if [ $(grep "Version:" pwm-control.spec) == "Version:" ]; then
    VERSION=$(<VERSION)
    sed -i.bak "s/Version:/Version: $VERSION/" pwm-control.spec
else
    VERSION=$(grep 'Version: ' pwm-control.spec | sed 's/Version: //g')
fi
sed -i.bak "s/VERSION =/VERSION = $VERSION/" usr/bin/pwm_control
post=$(<DEBIAN/postinst.sh)
postun=$(<DEBIAN/postrm.sh)
builtin echo -e "%post\n$post\n\n%postun\n$postun\n" >> pwm-control.spec
FOLDER="build"
mkdir $FOLDER
if [ -d bin ]; then
    cp -R bin "$FOLDER"/bin
fi
if [ -d etc ]; then
    cp -R etc "$FOLDER"/etc
fi
if [ -d usr ]; then
    cp -R usr "$FOLDER"/usr
fi
if [ -d lib ]; then
    cp -R lib "$FOLDER"/lib
fi
if [ -d lib32 ]; then
    cp -R lib32 "$FOLDER"/lib32
fi
if [ -d lib64 ]; then
    cp -R lib64 "$FOLDER"/lib64
fi
if [ -d libx32 ]; then
    cp -R libx32 "$FOLDER"/libx32
fi
if [ -d sbin ]; then
    cp -R sbin "$FOLDER"/sbin
fi
if [ -d var ]; then
    cp -R var "$FOLDER"/var
fi
if [ -d opt ]; then
    cp -R opt "$FOLDER"/opt
fi
if [ -d srv ]; then
    cp -R srv "$FOLDER"/srv
fi
rpmbuild -ba --buildroot "$PWD"/build --target arm64 --sign pwm-control.spec
mv --force usr/bin/pwm_control.bak usr/bin/pwm_control
mv --force pwm-control.spec.bak pwm-control.spec
