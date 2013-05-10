#!/bin/bash
source common.sh

rhel loadkeys be-latin1 && sed -i 's/^KEYTABLE=.*/XKBLAYOUT="be-latin1"/' /etc/sysconfig/keyboard \
|| debian sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="be"/' /etc/default/keyboard

