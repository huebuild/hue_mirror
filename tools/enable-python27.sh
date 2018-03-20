#!/bin/bash

echo "Prakash - $SHELL - $USER - $HOME - $PWD"

function run_python() {
  $1 --version >/dev/null 2>&1
  if [ ! $? -eq 0 ]; then
    echo "fail"
  else
    echo "pass"
  fi
}

function append_path() {
  if [ -f "$2" ]; then
    out=$(grep -l "PATH=$1" $2)
    if [ ! $? -eq 0 ]; then
      echo "export PATH=$PATH" >> $2
    fi
  fi
}

function append_this() {
  if [ -f "$2" ]; then
    out=$(grep -l "$1" $2)
    if [ ! $? -eq 0 ]; then
      echo "$1" >> $2
    fi
  fi
}

if [ -e "/usr/bin/python2.7" ]; then
  out=$(run_python "/usr/bin/python2.7")
  if [ "$out" == "pass" ]; then
    append_path "/usr/bin" "$HOME/.bashrc"
    export PATH=/usr/bin:$PATH
  fi
elif [ -e "/usr/local/python27/bin/python2.7" ]; then
  out=$(run_python "/usr/local/python27/bin/python2.7")
  if [ "$out" == "pass" ]; then
    append_path "/usr/local/python27/bin" "$HOME/.bashrc"
    export PATH=/usr/local/python27/bin:$PATH
  fi
elif [ -e "/opt/rh/python27/root/usr/bin/python2.7" ]; then
  . /opt/rh/python27/enable
  out=$(run_python "/opt/rh/python27/root/usr/bin/python2.7")
  if [ "$out" == "pass" ]; then
    append_path "/opt/rh/python27/root/usr/bin" "$HOME/.bashrc"
    export PATH=/opt/rh/python27/root/usr/bin:$PATH
    append_this ". /opt/rh/python27/enable" "$HOME/.bashrc"
  fi
fi

if [ -f "$HOME/.bashrc" ]; then
  . $HOME/.bashrc
fi
