#!/bin/bash
# -*- coding: utf-8 -*-
#
#  postinst.sh
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
set -eE
builtin echo "Adding hwmon group . . ."
groupadd hwmon || builtin echo "hwmon group already exists"
userlist=$(groupmems --list -g hwmon)
username=$(grep ':1000:1000:' /etc/passwd | sed 's/:/ /g' | awk '{print $1}')
if $(builtin echo "$userlist" | grep -qv "$username"); then
	builtin echo "Adding user $username to group hwmon . . ."
	usermod -a -G hwmon 
else
	builtin echo "User $username is already part of group hwmon."
fi
sed -i "s/User=/User=$username/" /etc/systemd/system/pwm_control.service
