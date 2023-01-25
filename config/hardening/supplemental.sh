#!/bin/sh
# This script was written by Frank Caviggia
# Last update was 13 May 2017
#
# Script: suplemental.sh (system-hardening)
# Description: Supplemental Hardening 
# License: GPLv2
# Copyright: Frank Caviggia, 2016
# Author: Frank Caviggia <fcaviggi (at) gmail.com>

########################################
# LEGAL BANNER CONFIGURATION
########################################
BANNER_MESSAGE_TEXT=' This is a private computer system, access to which is\n strictly limited to those employees of UKCloud\n Services who have appropriate permissions.\n Unauthorised access and/or use of this system is a\n violation of the Computer Misuse Act 1990, and will \n be subject to criminal prosecution.\n \n System use is subject to monitoring and logging: your\n use of this system constitutes your awareness of and\n consent to these activities.\n\n For Authorised users please use management su accounts to login.'
echo -e "${BANNER_MESSAGE_TEXT}" > /etc/issue
echo -e "${BANNER_MESSAGE_TEXT}" > /etc/issue.net

########################################
# DISA STIG PAM Configurations
########################################
cat <<EOF > /etc/pam.d/system-auth-local
#%PAM-1.0
auth required pam_env.so
# auth required pam_lastlog.so inactive=35
auth required pam_faillock.so preauth silent audit deny=3 even_deny_root root_unlock_time=900 unlock_time=300 fail_interval=900
auth sufficient pam_unix.so try_first_pass
auth        sufficient    pam_sss.so forward_pass
auth [default=die] pam_faillock.so authfail audit deny=3 even_deny_root root_unlock_time=900 unlock_time=300 fail_interval=900
auth sufficient pam_faillock.so authsucc audit deny=3 even_deny_root root_unlock_time=900 unlock_time=300 fail_interval=900
auth requisite pam_succeed_if.so uid >= 1000 quiet
auth required pam_deny.so

account required pam_faillock.so
account required pam_unix.so
# account required pam_lastlog.so inactive=35
account sufficient pam_localuser.so
account sufficient pam_succeed_if.so uid < 1000 quiet
account     [default=bad success=ok user_unknown=ignore] pam_sss.so
account required pam_permit.so

# Password Quality now set in /etc/security/pwquality.conf
password required pam_pwquality.so retry=3
password sufficient pam_unix.so sha512 shadow try_first_pass use_authtok remember=24
password    sufficient    pam_sss.so use_authtok
password required pam_deny.so

session required pam_lastlog.so showfailed
session optional pam_keyinit.so revoke
session required pam_limits.so
-session optional pam_systemd.so
session     optional      pam_oddjob_mkhomedir.so umask=0077
session [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session required pam_unix.so
session     optional      pam_sss.so
EOF
ln -sf /etc/pam.d/system-auth-local /etc/pam.d/system-auth
cat /etc/pam.d/system-auth-local > /etc/pam.d/system-auth-ac
chattr -i /etc/pam.d/system-auth-local
cat <<EOF > /etc/pam.d/password-auth-local
#%PAM-1.0
auth required pam_env.so
# auth required pam_lastlog.so inactive=35
auth required pam_faillock.so preauth silent audit deny=3 even_deny_root root_unlock_time=900 unlock_time=300 fail_interval=900
auth sufficient pam_unix.so try_first_pass
auth        sufficient    pam_sss.so forward_pass
auth [default=die] pam_faillock.so authfail audit deny=3 even_deny_root root_unlock_time=900 unlock_time=300 fail_interval=900
auth sufficient pam_faillock.so authsucc audit deny=3 even_deny_root root_unlock_time=900 unlock_time=300 fail_interval=900
auth requisite pam_succeed_if.so uid >= 1000 quiet
auth required pam_deny.so

account required pam_faillock.so
account required pam_unix.so
# account required pam_lastlog.so inactive=35
account sufficient pam_localuser.so
account sufficient pam_succeed_if.so uid < 1000 quiet
account     [default=bad success=ok user_unknown=ignore] pam_sss.so
account required pam_permit.so

# Password Quality now set in /etc/security/pwquality.conf
password required pam_pwquality.so retry=3
password sufficient pam_unix.so sha512 shadow try_first_pass use_authtok remember=24
password    sufficient    pam_sss.so use_authtok
password required pam_deny.so

session required pam_lastlog.so showfailed
session optional pam_keyinit.so revoke
session required pam_limits.so
-session optional pam_systemd.so
session     optional      pam_oddjob_mkhomedir.so umask=0077
session [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     optional      pam_sss.so
session required pam_unix.so
EOF
ln -sf /etc/pam.d/password-auth-local /etc/pam.d/password-auth
cat /etc/pam.d/password-auth-local > /etc/pam.d/password-auth-ac
chattr -i /etc/pam.d/password-auth-local

cat <<EOF > /etc/security/pwquality.conf
# Configuration for systemwide password quality limits
# Defaults:
#
# Number of characters in the new password that must not be present in the
# old password.
 difok = 5
#difok = 15
#
# Minimum acceptable size for the new password (plus one if
# credits are not disabled which is the default). (See pam_cracklib manual.)
# Cannot be set to lower value than 6.
 minlen = 9
#minlen = 15
#
# The maximum credit for having digits in the new password. If less than 0
# it is the minimum number of digits in the new password.
# dcredit = 1
dcredit = -1
#
# The maximum credit for having uppercase characters in the new password.
# If less than 0 it is the minimum number of uppercase characters in the new
# password.
# ucredit = 1
ucredit = -1
#
# The maximum credit for having lowercase characters in the new password.
# If less than 0 it is the minimum number of lowercase characters in the new
# password.
# lcredit = 1
lcredit = -1
#
# The maximum credit for having other characters in the new password.
# If less than 0 it is the minimum number of other characters in the new
# password.
# ocredit = 1
ocredit = -1
#
# The minimum number of required classes of characters for the new
# password (digits, uppercase, lowercase, others).
minclass = 4
#
# The maximum number of allowed consecutive same characters in the new password.
# The check is disabled if the value is 0.
maxrepeat = 2
#
# The maximum number of allowed consecutive characters of the same class in the
# new password.
# The check is disabled if the value is 0.
maxclassrepeat = 2
#
# Whether to check for the words from the passwd entry GECOS string of the user.
# The check is enabled if the value is not 0.
# gecoscheck = 0
#
# Path to the cracklib dictionaries. Default is to use the cracklib default.
# dictpath =
EOF

## Secured NTP Configuration
cat <<EOF > /etc/ntp.conf
# by default act only as a basic NTP client
restrict -4 default nomodify nopeer noquery notrap
restrict -6 default nomodify nopeer noquery notrap
# allow NTP messages from the loopback address, useful for debugging
restrict 127.0.0.1
restrict ::1
# poll server at higher rate to prevent drift
maxpoll 17
# server(s) we time sync to
server time1.il2management.local
server time2.il2management.local
#server time.example.net
EOF

cat <<EOF > /etc/chrony.conf
# server(s) we time sync to
server time1.il2management.local iburst
server time2.il2management.local iburst
pool time1.il2management.local iburst
pool time2.il2management.local iburst



#Allow system clock changes to be stepped if greater than 3 seconds
makestep 1.0 3

driftfile /etc/chrony.drift

keyfile /etc/chrony.keys

logdir /var/log/chrony
maxupdateskew 100.0

port 0
bindcmdaddress 127.0.0.1
bindcmdaddress ::1
EOF

cat <<'EOF' > /etc/rsyslog.d/ignore-systemd-session-slice.conf
if $programname == "systemd" and ($msg contains "Starting Session" or $msg contains "Started Session" or $msg contains "Created slice" or $msg contains "Starting user-" or $msg contains "Starting User Slice of" or $msg contains "Removed session" or $msg contains "Removed slice User Slice of" or $msg contains "Stopping User Slice of") then stop
EOF

########################################
# STIG Audit Configuration
########################################
cat <<EOF > /etc/audit/rules.d/audit.rules
# DISA STIG Audit Rules
## Add keys to the audit rules below using the -k option to allow for more 
## organized and quicker searches with the ausearch tool.  See auditctl(8) 
## and ausearch(8) for more information.

# Remove any existing rules
-D

# Increase kernel buffer size
-b 16384

# Failure of auditd causes a kernel panic
-f 2

###########################
## DISA STIG Audit Rules ##
###########################

# Watch syslog configuration
-w /etc/rsyslog.conf
-w /etc/rsyslog.d/

# Watch PAM and authentication configuration
-w /etc/pam.d/
-w /etc/nsswitch.conf

# Watch system log files
-w /var/log/messages
-w /var/log/audit/audit.log
-w /var/log/audit/audit[1-4].log

# Watch audit configuration files
-w /etc/audit/auditd.conf -p wa
-w /etc/audit/audit.rules -p wa

# Watch login configuration
-w /etc/login.defs
-w /etc/securetty
-w /etc/resolv.conf

# Watch cron and at
-w /etc/at.allow
-w /etc/at.deny
-w /var/spool/at/
-w /etc/crontab
-w /etc/anacrontab
-w /etc/cron.allow
-w /etc/cron.deny
-w /etc/cron.d/
-w /etc/cron.hourly/
-w /etc/cron.weekly/
-w /etc/cron.monthly/

# Watch shell configuration
-w /etc/profile.d/
-w /etc/profile
-w /etc/shells
-w /etc/bashrc
-w /etc/csh.cshrc
-w /etc/csh.login

# Watch kernel configuration
-w /etc/sysctl.conf
-w /etc/modprobe.conf

# Watch linked libraries
-w /etc/ld.so.conf -p wa
-w /etc/ld.so.conf.d/ -p wa

# Watch init configuration
-w /etc/rc.d/init.d/
-w /etc/sysconfig/
-w /etc/inittab -p wa
-w /etc/rc.local
-w /usr/lib/systemd/
-w /etc/systemd/

# Watch filesystem and NFS exports
-w /etc/fstab
-w /etc/exports

# Watch xinetd configuration
-w /etc/xinetd.conf
-w /etc/xinetd.d/

# Watch Grub2 configuration
-w /etc/grub2.cfg
-w /etc/grub.d/

# Watch TCP_WRAPPERS configuration
-w /etc/hosts.allow
-w /etc/hosts.deny

# Watch sshd configuration
-w /etc/ssh/sshd_config

# Audit system events
-a always,exit -F arch=b32 -S acct -S reboot -S sched_setparam -S sched_setscheduler -S setrlimit -S swapon 
-a always,exit -F arch=b64 -S acct -S reboot -S sched_setparam -S sched_setscheduler -S setrlimit -S swapon 

# Audit any link creation
-a always,exit -F arch=b32 -S link -S symlink
-a always,exit -F arch=b64 -S link -S symlink

##############################
## NIST 800-53 Requirements ##
##############################

#2.6.2.4.1 Records Events that Modify Date and Time Information
-a always,exit -F arch=b32 -S adjtimex -S stime -S settimeofday -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change

#2.6.2.4.2 Record Events that Modify User/Group Information
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
-w /etc/sudoers

#2.6.2.4.3 Record Events that Modify the Systems Network Environment
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k audit_network_modifications
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k audit_network_modifications
-w /etc/issue -p wa -k audit_network_modifications
-w /etc/issue.net -p wa -k audit_network_modifications
-w /etc/hosts -p wa -k audit_network_modifications
-w /etc/sysconfig/network -p wa -k audit_network_modifications

#2.6.2.4.4 Record Events that Modify the System Mandatory Access Controls
-w /etc/selinux/ -p wa -k MAC-policy

#2.6.2.4.5 Ensure auditd Collects Logon and Logout Events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins

#2.6.2.4.6 Ensure auditd Collects Process and Session Initiation Information
-w /var/run/utmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/wtmp -p wa -k session

#2.6.2.4.7 Ensure auditd Collects Discretionary Access Control Permission Modification Events
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod

#2.6.2.4.8 Ensure auditd Collects Unauthorized Access Attempts to Files (unsuccessful)
-a always,exit -F arch=b32 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S open_by_handle_at -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access

#2.6.2.4.9 Ensure auditd Collects Information on the Use of Privileged Commands
-a always,exit -F path=/usr/sbin/semanage -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged-priv_change
-a always,exit -F path=/usr/sbin/setsebool -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged-priv_change
-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged-priv_change
-a always,exit -F path=/usr/sbin/restorecon -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged-priv_change
-a always,exit -F path=/usr/bin/userhelper -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged
-a always,exit -F path=/usr/bin/sudoedit -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged
-a always,exit -F path=/usr/libexec/pt_chown -F perm=x -F auid>=1000 -F auid!=4294967295 -F key=privileged
EOF
# Find All privileged commands and monitor them
for PROG in `find / -xdev -type f -perm -4000 -o -type f -perm -2000 2>/dev/null`; do
	echo "-a always,exit -F path=$PROG -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged"  >> /etc/audit/rules.d/audit.rules
done
cat <<EOF >> /etc/audit/rules.d/audit.rules

#2.6.2.4.10 Ensure auditd Collects Information on Exporting to Media (successful)
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k export
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k export

#2.6.2.4.11 Ensure auditd Collects Files Deletion Events by User (successful and unsuccessful)
-a always,exit -F arch=b32 -S unlink -S rmdir -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b64 -S unlink -S rmdir -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete

#2.6.2.4.12 Ensure auditd Collects System Administrator Actions
-w /etc/sudoers -p wa -k actions

#2.6.2.4.13 Make the auditd Configuration Immutable
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b32 -S init_module -S delete_module -k modules
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules

#2.6.2.4.14 Make the auditd Configuration Immutable
-e 2
EOF

########################################
# Fix cron.allow
########################################
echo "root" > /etc/cron.allow
chmod 400 /etc/cron.allow
chown root:root /etc/cron.allow

########################################
# Make SELinux Configuration Immutable
########################################
chattr +i /etc/selinux/config


########################################
# Disable Control-Alt-Delete
########################################
ln -sf /dev/null /etc/systemd/system/ctrl-alt-del.target


########################################
# No Root Login to Console (use admin user)
########################################
cat /dev/null > /etc/securetty


########################################
# SSSD Configuration
########################################
mkdir -p /etc/sssd
cat <<EOF > /etc/sssd/sssd.conf
[sssd]
services = sudo, autofs, pam
EOF

########################################
# Disable Interactive Shell (Timeout)
########################################
cat <<EOF > /etc/profile.d/autologout.sh
#!/bin/sh
TMOUT=900
export TMOUT
readonly TMOUT
EOF
cat <<EOF > /etc/profile.d/autologout.csh
#!/bin/csh
set autologout=15
set -r autologout
EOF
chown root:root /etc/profile.d/autologout.sh
chown root:root /etc/profile.d/autologout.csh
chmod 555 /etc/profile.d/autologout.sh
chmod 555 /etc/profile.d/autologout.csh

########################################
# Set Shell UMASK Setting (027)
########################################
cat <<EOF > /etc/profile.d/umask.sh
#!/bin/sh

# Non-Privledged Users get 027
# Privledged Users get 022
if [[ \$EUID -ne 0 ]]; then
	umask 027
else
	umask 022
fi
EOF
cat <<EOF > /etc/profile.d/umask.csh
#!/bin/csh
umask 027
EOF
chown root:root /etc/profile.d/umask.sh
chown root:root /etc/profile.d/umask.csh
chmod 555 /etc/profile.d/umask.sh
chmod 555 /etc/profile.d/umask.csh


########################################
# Vlock Alias (Console Screen Lock)
########################################
cat <<EOF > /etc/profile.d/vlock-alias.sh
#!/bin/sh
alias vlock='clear;vlock -a'
EOF
cat <<EOF > /etc/profile.d/vlock-alias.csh
#!/bin/csh
alias vlock 'clear;vlock -a'
EOF
chown root:root /etc/profile.d/vlock-alias.sh
chown root:root /etc/profile.d/vlock-alias.csh
chmod 555 /etc/profile.d/vlock-alias.sh
chmod 555 /etc/profile.d/vlock-alias.csh


########################################
# Wheel Group Require (sudo)
########################################
sed -i -re '/pam_wheel.so use_uid/s/^#//' /etc/pam.d/su
sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*ALL\)/\1/' /etc/sudoers
echo -e "\n## Set timeout for authentiation (5 Minutes)\nDefaults:ALL timestamp_timeout=5\n" >> /etc/sudoers
echo "%skyscape\ super\ users ALL=(ALL)       ALL" >> /etc/sudoers


########################################
# Set Removeable Media to noexec
#   CCE-27196-5
########################################
for DEVICE in $(/bin/lsblk | grep sr | awk '{ print $1 }'); do
	mkdir -p /mnt/$DEVICE
	echo -e "/dev/$DEVICE\t\t/mnt/$DEVICE\t\tiso9660\tdefaults,ro,noexec,nosuid,nodev,noauto\t0 0" >> /etc/fstab
done
for DEVICE in $(cd /dev;ls *cd* *dvd*); do
	mkdir -p /mnt/$DEVICE
	echo -e "/dev/$DEVICE\t\t/mnt/$DEVICE\t\tiso9660\tdefaults,ro,noexec,nosuid,nodev,noauto\t0 0" >> /etc/fstab
done


########################################
# SSHD Hardening
########################################
sed -i '/Ciphers.*/d' /etc/ssh/ssh*config
sed -i '/MACs.*/d' /etc/ssh/ssh*config
sed -i '/Protocol.*/d' /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/ssh/ssh_config
echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" >> /etc/ssh/sshd_config
echo "MACs hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/ssh_config
echo "MACs hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config
echo "PrintLastLog yes" >> /etc/ssh/sshd_config
echo "AllowGroups sshusers 'skyscape super users'" >> /etc/ssh/sshd_config
echo "MaxAuthTries 5" >> /etc/ssh/sshd_config
echo "Banner /etc/issue" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
echo "KerberosAuthentication no" >> /etc/ssh/sshd_config
echo "IgnoreUserKnownHosts yes" >> /etc/ssh/sshd_config
echo "StrictModes yes" >> /etc/ssh/sshd_config
echo "UsePrivilegeSeparation yes" >> /etc/ssh/sshd_config
echo "Compression delayed" >> /etc/ssh/sshd_config
if [ $(grep -c sshusers /etc/group) -eq 0 ]; then
	/usr/sbin/groupadd sshusers &> /dev/null
fi


########################################
# TCP_WRAPPERS
########################################
cat <<EOF >> /etc/hosts.allow
# LOCALHOST (ALL TRAFFIC ALLOWED) DO NOT REMOVE FOLLOWING LINE
ALL: 127.0.0.1 [::1]
# Allow SSH (you can limit this further using IP addresses - e.g. 192.168.0.*)
sshd: ALL
snmpd: 10.8.202.0/24
snmpd: 10.24.202.0/24
keepalived: 10.8.200.0/24

EOF
cat <<EOF >> /etc/hosts.deny
# Deny All by Default
ALL: ALL
EOF


########################################
# Filesystem Attributes
#  CCE-26499-4,CCE-26720-3,CCE-26762-5,
#  CCE-26778-1,CCE-26622-1,CCE-26486-1.
#  CCE-27196-5
########################################
FSTAB=/etc/fstab
SED=`which sed`

if [ $(grep " \/sys " ${FSTAB} | grep -c "nosuid") -eq 0 ]; then
	MNT_OPTS=$(grep " \/sys " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/sys.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/boot " ${FSTAB} | grep -c "nosuid") -eq 0 ]; then
	MNT_OPTS=$(grep " \/boot " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/boot.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/usr " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/usr " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/usr .*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/home " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/home " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/home .*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/export\/home " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/export\/home " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/export\/home .*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/usr\/local " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/usr\/local " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/usr\/local.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/dev\/shm " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/dev\/shm " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/dev\/shm.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/tmp " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/tmp " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/tmp.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/tmp " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/tmp " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/tmp.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/log " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/tmp " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/tmp.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/log\/audit " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/log\/audit " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/log\/audit.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/var\/www " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/var\/wwww " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/var\/www.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
if [ $(grep " \/opt " ${FSTAB} | grep -c "nodev") -eq 0 ]; then
	MNT_OPTS=$(grep " \/opt " ${FSTAB} | awk '{print $4}')
	${SED} -i "s/\( \/opt.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${FSTAB}
fi
echo -e "tmpfs\t\t\t/dev/shm\t\ttmpfs\tnoexec,nosuid,nodev\t\t0 0" >> /etc/fstab

########################################
# File Ownership 
########################################
find / -nouser -print | xargs chown root
find / -nogroup -print | xargs chown :root
cat <<EOF > /etc/cron.daily/unowned_files
#!/bin/sh
# Fix user and group ownership of files without user
find / -nouser -print | xargs chown root
find / -nogroup -print | xargs chown :root
EOF
chown root:root /etc/cron.daily/unowned_files
chmod 0700 /etc/cron.daily/unowned_files


########################################
# USGCB Blacklist
########################################
if [ -e /etc/modprobe.d/usgcb-blacklist.conf ]; then
	rm -f /etc/modprobe.d/usgcb-blacklist.conf
fi
touch /etc/modprobe.d/usgcb-blacklist.conf
chmod 0644 /etc/modprobe.d/usgcb-blacklist.conf
chcon 'system_u:object_r:modules_conf_t:s0' /etc/modprobe.d/usgcb-blacklist.conf

cat <<EOF > /etc/modprobe.d/usgcb-blacklist.conf
# Disable Bluetooth
install bluetooth /bin/true
# Disable AppleTalk
install appletalk /bin/true
# NSA Recommendation: Disable mounting USB Mass Storage
install usb-storage /bin/true
# Disable mounting of cramfs CCE-14089-7
install cramfs /bin/true
# Disable mounting of freevxfs CCE-14457-6
install freevxfs /bin/true
# Disable mounting of hfs CCE-15087-0
install hfs /bin/true
# Disable mounting of hfsplus CCE-14093-9
install hfsplus /bin/true
# Disable mounting of jffs2 CCE-14853-6
install jffs2 /bin/true
# Disable mounting of squashfs CCE-14118-4
install squashfs /bin/true
# Disable mounting of udf CCE-14871-8
install udf /bin/true
# CCE-14268-7
install dccp /bin/true
# CCE-14235-5
install sctp /bin/true
#i CCE-14027-7
install rds /bin/true
# CCE-14911-2
install tipc /bin/true
# CCE-14948-4 (row 176)
install net-pf-31 /bin/true
EOF


########################################
# GNOME 3 Lockdowns
########################################
if [ -x /bin/gsettings ]; then
	cat << EOF > /etc/dconf/db/gdm.d/99-gnome-hardening
[org/gnome/login-screen]
banner-message-enable=true
banner-message-text="${BANNER_MESSAGE_TEXT}"
disable-user-list=true
disable-restart-buttons=true

[org/gnome/desktop/lockdown]
user-administration-disabled=true
disable-user-switching=true

[org/gnome/desktop/media-handling]
automount=false
automount-open=false
autorun-never=true

[org/gnome/desktop/notifications] 
show-in-lock-screen=false

[org/gnome/desktop/privacy]
remove-old-temp-files=true
remove-old-trash-files=true
old-files-age=7

[org/gnome/desktop/interface]
clock-format="12h"

[org/gnome/desktop/screensaver]
user-switch-enabled=false

[org/gnome/desktop/session]
idle-delay=900

[org/gnome/desktop/thumbnailers]
disable-all=true

[org/gnome/nm-applet]
disable-wifi-create=true
EOF

cat << EOF > /etc/snmp/snmpd.conf
rocommunity                 QH45ErX,5Zm$
syslocation                 Farnborough A8
syscontact                  support@skyscapecloud.com
com2sec                     notConfigUser   default     QH45ErX,5Zm$
group                       notConfigGroup  v1          notConfigUser
group                       notConfigGroup  v2c         notConfigUser
view                        systemview      included    .1.3.6.1.2.1.1
view                        systemview      included    .1.3.6.1.2.1.25.1.1
access                      notConfigGroup  ""          any       noauth    exact  systemview none none
com2sec                     mynetwork       10.0.0.0/8  QH45ErX,5Zm$
dontLogTCPWrappersConnects  yes
includeAllDisks                         10%
EOF

cat << EOF > /etc/dconf/db/gdm.d/locks/99-gnome-hardening
/org/gnome/login-screen/banner-message-enable
/org/gnome/login-screen/banner-message-text
/org/gnome/login-screen/disable-user-list
/org/gnome/login-screen/disable-restart-buttons
/org/gnome/desktop/lockdown/user-administration-disabled
/org/gnome/desktop/lockdown/disable-user-switching
/org/gnome/desktop/media-handling/automount
/org/gnome/desktop/media-handling/automount-open
/org/gnome/desktop/media-handling/autorun-never
/org/gnome/desktop/notifications/show-in-lock-screen
/org/gnome/desktop/privacy/remove-old-temp-files
/org/gnome/desktop/privacy/remove-old-trash-files
/org/gnome/desktop/privacy/old-files-age
/org/gnome/desktop/screensaver/user-switch-enabled
/org/gnome/desktop/session/idle-delay
/org/gnome/desktop/thumbnailers/disable-all
/org/gnome/nm-applet/disable-wifi-create
EOF

cat << EOF > /usr/share/glib-2.0/schemas/99-custom-settings.gschema.override
[org.gnome.login-screen]
banner-message-enable=true
banner-message-text="${BANNER_MESSAGE_TEXT}"
disable-user-list=true
disable-restart-buttons=true

[org.gnome.desktop.lockdown]
user-administration-disabled=true
disable-user-switching=true

[org.gnome.desktop.media-handling]
automount=false
automount-open=false
autorun-never=true

[org.gnome.desktop.notifications] 
show-in-lock-screen=false

[org.gnome.desktop.privacy]
remove-old-temp-files=true
remove-old-trash-files=true
old-files-age=7

[org.gnome.desktop.interface]
clock-format="12h"

[org.gnome.desktop.screensaver]
user-switch-enabled=false

[org.gnome.desktop.session]
idle-delay=900

[org.gnome.desktop.thumbnailers]
disable-all=true

[org.gnome.nm-applet]
disable-wifi-create=true
EOF

cat << EOF > /etc/gdm/custom.conf
# GDM configuration storage

[daemon]
AutomaticLoginEnable=false
TimedLoginEnable=false

[security]

[xdmcp]

[greeter]

[chooser]

[debug]

EOF
	cp /etc/dconf/db/gdm.d/locks/99-gnome-hardening /etc/dconf/db/local.d/locks/99-gnome-hardening
 	/bin/glib-compile-schemas /usr/share/glib-2.0/schemas/
	/bin/dconf update
fi

########################################
# Kernel - Randomize Memory Space
# CCE-27127-0, SC-30(2), 1.6.1
########################################
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf

########################################
# Kernel - Accept Source Routed Packets
# AC-4, 366, SRG-OS-000480-GPOS-00227
########################################
echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf

#######################################
# Kernel - Disable Redirects
#######################################
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf

#######################################
# Kernel - Disable ICMP Broadcasts
#######################################
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf

#######################################
# Kernel - Disable Syncookies
#######################################
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf

#######################################
# Kernel - Disable TCP Timestamps
#######################################
echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf

########################################
# Disable SystemD Date Service 
# Use (chrony or ntpd)
########################################
timedatectl set-ntp false

######################################## 
# Disable Kernel Dump Service 
######################################## 
systemctl disable kdump.service 
systemctl mask kdump.service

rm -f /etc/localtime

cp /usr/share/zoneinfo/Europe/London /etc/localtime

echo "ZONE=internal" >> /etc/sysconfig/network-scripts/ifcfg-ens32
echo "DOMAIN=il2management.local" >> /etc/sysconfig/network-scripts/ifcfg-ens32


sed -i -e 's/#$UDPServerRun 514/$UDPServerRun 514/g' /etc/rsyslog.conf
sed -i -e 's/#$ModLoad imudp/$ModLoad imudp/g' /etc/rsyslog.conf
echo "#*.* @rsyslog-farnborough.il2management.local:514" >> /etc/rsyslog.conf



usermod -aG sshusers bdylan
cat << EOF > /home/bdylan/realm_edit.sh
#!/bin/sh
USER1="$1"
if [[ -n "$USER1" ]]; then
    realm join --user=$USER1 il2management.local

    sed -i -e 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
    sed -i -e 's/fallback_homedir = \/home\/%u@%d/fallback_homedir = \/home\/%u/g' /etc/sssd/sssd.conf
    systemctl restart sssd
else
    echo "please enter domain account"
    exit 1
fi
EOF
chmod 700 /home/bdylan/realm_edit.sh

cat << EOF > /home/bdylan/haproxy.sh
echo "Installing haproxy and keepalived"
yum -y install haproxy keepalived
echo "configuring Internal firewall zone for HTTP access"
firewall-cmd --zone=internal --permanent --add-service=http
echo "configuring Internal firewall zone for HTTPS access"
firewall-cmd --zone=internal --permanent --add-service=https
echo "configuring Internal firewall zone for protocol 112 to allow keepalived"
firewall-cmd --zone=internal --permanent --add-protocol=112
echo "reloading firewall"
firewall-cmd --reload
echo "User confirmation"
firewall-cmd --reload
echo "Confirm /etc/rsyslog.d/haproxy.conf has the correct local log setting or change"
echo "local0.*    /var/log/haproxy.log" >> /etc/rsyslog.d/haproxy.conf
echo "Confirm /etc/rsyslog.d/keepalived.conf has the correct local log setting or change"
sed -i -e 's/"-D"/"-D -S 2"/g'  /etc/sysconfig/keepalived
mv /tmp/keepalive_state_change.py /etc/keepalived/state_change.py
chmod +x /etc/keepalived/state_change.py
chcon -t etc_t -u system_u /etc/keepalived/state_change.py
restorecon -v -R /etc/haproxy
restorecon -v -R /etc/keepalived

echo "local2.*    /var/log/keepalived.log" >> /etc/rsyslog.d/keepalived.conf

echo "Restarting keepalived"
systemctl enable haproxy
systemctl enable keepalived
systemctl restart keepalived
echo "Restarting rsyslog"
systemctl restart rsyslog
EOF

cat << EOF > /tmp/keepalive_state_change.py
#!/bin/python

import argparse
import json
import ssl
import base64
import requests
import socket
import syslog
from requests.auth import HTTPBasicAuth

from requests.adapters import HTTPAdapter
from requests.packages.urllib3.poolmanager import PoolManager

syslog.openlog(ident="LOG_STATE_CHANGED",logoption=syslog.LOG_PID, facility=syslog.LOG_LOCAL2)

def SLAPI_ID(device_ip):
    url = "https://sciencelogic.il2management.local/api/device?limit=1&=&extended_fetch=1&filter.ip=" + device_ip
    apicreds = base64.b64encode("em7admin:*********")
    apiauthheader = "Basic %s" % apicreds
    apiheaders = {"Authorization" : apiauthheader , "Accept" : "application/json"}
    r = requests.get(url, headers=apiheaders, verify=False)
    results = r.json()
    for data in results['result_set']:
        if data.startswith("/api/device/"):
           return data[len("/api/device/"):]


def SLAPI(text, device_id):
    url = "https://sciencelogic.il2management.local/api/alert"
    apicreds = base64.b64encode("em7admin:*********")
    apiauthheader = "Basic %s" % apicreds
    apiheaders = {"Authorization" : apiauthheader , "Accept" : "application/json"}
    jsonData = {"force_ytype":"0", "force_yid":"0","force_yname":"1", "message": "" + text + "","value":"","threshold":"0", "message_time":"0","aligned_resource":"/device/" + str(device_id)}
    r = requests.post(url,headers=apiheaders, data=json.dumps(jsonData), verify=False)
    return r

parser = argparse.ArgumentParser(argument_default=argparse.SUPPRESS)

#parser.add_argument('instance', action='store', nargs=None)
#parser.add_argument('instance_name', action='store', nargs=None)
#parser.add_argument('state', action='store', nargs=None)

parser.add_argument('--name', '-n', dest='device_name', action='store',
                    help='device name')
parser.add_argument('--object', '-o', dest='device_id', action='store',
                    help='object id in sciencelogic')
parser.add_argument('--ip', '-i', dest='ip', action='store',
                    help='keepalived ip address')
parser.add_argument('--service', '-s', dest='service', action='store',
                    help='service')
parser.add_argument('--state', '-S', dest='state', action='store',
                    help='changed state')

args = parser.parse_args()

if hasattr(args, "state") :
    state = args.state
else :
    state = "UNKNOWN"
if hasattr(args,"device_name"):
    device_name =  args.device_name
else :
    device_name = socket.gethostname().split('.')[0]

if hasattr(args, "ip"):
    ip = args.ip
else:
    ip = socket.gethostbyname(socket.gethostname())

if hasattr(args, "service") :
    service = args.service
else:
    service = "UNKNOWN"

if hasattr(args, "device_id") :
    device_id = args.device_id
else:
    device_id = SLAPI_ID(ip)

csvError = "State Change: Service " + service + "(" + ip + ")" + ", HAProxy " + device_name + " has changed to " + state
syslog.syslog(csvError)
success = SLAPI(csvError, device_id)
if success.status_code == 201 :
   logging = "Alert written to device " + device_id
   syslog.syslog(logging)
EOF


firewall-cmd --zone=internal --permanent --add-service=snmp
systemctl enable snmp
firewall-cmd --zone=internal --permanent --remove-service=samba-client
firewall-cmd --reload
sudo chmod 700 /home/bdylan/haproxy.sh


echo "yum -y update"

