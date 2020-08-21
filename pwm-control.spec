Name: pwm-control
Version:
License: GPL
Packager: Thomas Castleman <contact@draugeros.org>
Vendor: Drauger OS Development
URL: https://github.com/drauger-os-development/pwm_control
Release: 1.0
Summary: Easily control PWM fans
Requires: python >= 3.6.7, systemd >= 237, python-psutil >= 5.5.0

%description
Easily Control PWM fans using CPU temps and an easy to configure fan curve.

%files
%config /etc/pwm_control/settings.json
/etc/systemd/system/pwm_control.service
/etc/udev/rules.d/70-pwmcontrol.rules
/usr/bin/pwm_control
/usr/share/pwm_control/pwm_control.py
#%doc ./README.md
#%doc ./LICENSE

#%exclude
#/.git
#/DEBIAN
#/VERSION
#/LICENSE
#/README.md
#/.gitignore
#/build*
#/pwm-control.spec
#/*.bak
#/usr/bin/pwm_control.bak
