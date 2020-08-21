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
	sed -i.bak "s/Version: /Version: $VERSION/" pwm-contol.spec
else
	VERSION=$(grep 'Version: ' pwm-control.spec | sed 's/Version: //g')
fi
sed -i.bak "s/VERSION = /VERSION = $VERSION/" usr/bin/pwm_contol
rpmbuild -ba pwm-control.spec
rm -rf "$FOLDER"
mv --force usr/bin/pwm_control.bak usr/bin/pwm_control
mv --force pwm-control.spec.bak pwm-control.spec
