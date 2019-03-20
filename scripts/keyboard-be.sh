#!/bin/bash
source common.sh

ifapt sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="be"/' /etc/default/keyboard || \
el6 sed -i 's/^KEYTABLE=.*/KEYTABLE="be-latin1"/' /etc/sysconfig/keyboard || \
el7 localectl set-keymap be-latin1 || :
el loadkeys be-latin1 || :

