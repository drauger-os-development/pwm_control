#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#  pwm_control.py
#
#  Copyright 2022 Thomas Castleman <contact@draugeros.org>
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
"""Control Fan State on RockPro64 based on
current CPU temps
"""
from time import sleep
from psutil import sensors_temperatures as get_temps
from sys import stderr
from os import mkdir, listdir, path
import json


defaults = {
 "fan curve":{
    "low": 45.0,
    "low-mid": 55.0,
    "mid": 65.0,
    "mid-high": 75.0,
    "high": 85.0,
    "max": 95.0
    },
 "speeds":{
    "off": 25,
    "low": 75,
    "low-mid": 105,
    "mid": 125,
    "mid-high": 175,
    "high": 225,
    "max": 255
}


def __apply_speed__(speed):
    """Apply Fan Speed"""
    try:
        with open("/sys/class/hwmon/hwmon0/pwm1", "w+") as fan:
            fan.write(str(speed))
    except PermissionError:
        try:
            with open("/sys/class/pwm/pwm1", "w+") as fan:
                fan.write(str(speed))
        except PermissionError:
            folders = listdir("/sys/devices/platform/pwm-fan/hwmon")
            for each in folders:
                if path.isfile("/sys/devices/platform/pwm-fan/hwmon/" + each + "/pwm1"):
                    with open("/sys/devices/platform/pwm-fan/hwmon/" + each + "/pwm1", "w+") as fan:
                        fan.write(str(speed))
                        return


def set_fan_speed(temp, temp_curve, speed_curve):
    """Set fan speed based on temps"""
    speed_setting = "off"
    for each in temp_curve:
        if temp >= temp_curve[each]:
            speed_setting = each
    __apply_speed__(speed_curve[speed_setting])


def eprint(*args, **kwargs):
    """Make it easier for us to print to stderr"""
    print(*args, file=stderr, **kwargs)


# Read Settings
try:
    with open("/etc/pwm_control/settings.json", "r") as settings:
        data = json.load(settings)
except FileNotFoundError:
    try:
        with open("settings.json", "r") as settings:
            data = json.load(settings)
    except FileNotFoundError:
        # Settings aren't found. Make 'em
        eprint("ERROR: settings.json not found. Generating...")
        try:
            mkdir("/etc/pwm_control")
            with open("/etc/pwm_control/settings.json", "w+") as settings:
                json.dump(defaults, settings,
                          indent=1)
        except PermissionError:
            with open("settings.json", "w+") as settings:
                json.dump(defaults, settings,
                          indent=1)
        data = {}

# Check settings are actually set. If not, set defaults and warn.
try:
    fan_curve = data["fan curve"]
except KeyError:
    fan_curve = defaults["fan curve"]
    eprint("WARNING: fan temp curve not set. Falling back to default.")
try:
    speeds = data["speeds"]
except KeyError:
    speeds = defaults["speeds"]
    eprint("WARNING: fan speed curve not set. Falling back to default.")

# Make sure fans are working
with open("/sys/devices/virtual/thermal/thermal_zone0/mode", "w") as toggle:
    toggle.write("disabled")

# Monitor Temps
while True:
    temps = get_temps()
    if "coretemp" in temps:
        temps = temps["coretemp"]
    average = 0
    sensors = 0
    if type(temps) == list:
        for each in temps:
            average = average + each[1]
            sensors += 1
    elif type(temps) == dict:
        for each in temps:
            average = average + temps[each][0][1]
            sensors += 1
    else:
        eprint("ERROR: get_temps returned unexpected data type")
        exit(2)
    average = average / sensors
    # Set fan state
    set_fan_speed(average, fan_curve, speeds)
    sleep(0.1)
