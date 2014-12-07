#!/bin/bash
source common.sh

########## install puppet ##########

ensure_packages ruby rubygems libselinux-ruby ruby-augeas ruby-shadow puppet

