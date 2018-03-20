#!/bin/bash

function run_python() {
  $1 --version >/dev/null 2>&1
  if [ ! $? -eq 0 ]; then
    echo "fail"
  else
    echo "pass"
  fi
}

if [ -e "/usr/bin/python2.7" ]; then
  out=$(run_python "/usr/bin/python2.7")
  if [ "$out" == "pass" ]; then
    export PATH=/usr/bin:$PATH
  fi
elif [ -e "/usr/local/python27/bin/python2.7" ]; then
  out=$(run_python "/usr/local/python27/bin/python2.7")
  if [ "$out" == "pass" ]; then
    export PATH=/usr/local/python27/bin:$PATH
  fi
elif [ -e "/opt/rh/python27/root/usr/bin/python2.7" ]; then
  . /opt/rh/python27/enable
  out=$(run_python "/opt/rh/python27/root/usr/bin/python2.7")
  if [ "$out" == "pass" ]; then
    export PATH=/opt/rh/python27/root/usr/bin:$PATH
  fi
fi
