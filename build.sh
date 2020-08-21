#!/bin/bash
# -*- coding: utf-8 -*-
#
#  build.sh
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
# Fix Version numbers
VERSION=$(<VERSION)
sed -i.bak "s/Version:/Version: $VERSION/" pwm-contol.spec
sed -i.bak "s/Version:/Version: $VERSION/" DEBIAN/control
sed -i.bak "s/VERSION =/VERSION = $VERSION/" usr/bin/pwm_contol
# Move back up copies
mv DEBIAN/control.bak control
mv usr/bin/pwm_control.bak pwm_control
# Put postinst and postrm into the spec file
post=$(<DEBIAN/postinst.sh)
postun=$(<DEBIAN/postrm.sh)
builtin echo -e "%post\n$post\n\n%postun\n$postun\n" >> pwm-control.spec
# Build the DEB
./build-deb.sh
# Build the RPM
./build-rpm.sh
# Restore the backups, overwriting the changes we made, and putting us back where we where initially
mv --force control DEBIAN/control
mv --force pwm_control usr/bin/pwm_control
mv --force pwm-control.spec.bak pwm-control.spec

