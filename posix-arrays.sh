#!/usr/bin/env sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# Copyright (c) 2022 Blakely North. All rights reserved.
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Title: posix-arrays
# Description: An array library for POSIX shell script
# Author: Blakely North
# Homepage: https://github.com/PowerUser64/posix-arrays/

# shellcheck disable=SC2086,SC2034,SC2015

# ${ARRAY_DEBUG:-false} && set -x || :
# set -eux

msg() { echo "$@"; }
err() { msg "$@" >&2; }
dbg() { "${ARRAY_DEBUG:-false}" && err "$@" || :; }

# init
   # array_init ARRAY
# Write
   # array_set ARRAY INDEX VALUE
   # array_append ARRAY VALUE [...]
# Read
   # array_get ARRAY INDEX
# Iterate
   # array_itr_init ARRAY
   # array_itr_next ARRAY
   # array_itr_prev ARRAY
   # array_get_here ARRAY
   # array_set_here ARRAY
# attributes
   # array_attr_size ARRAY
   # array_attr_itr ARRAY
# utility
   # array_print_esc ARRAY

# TODO:
#   - Safety:
#     - ensure array_itr_set can't go outside bounds
#   - Optimize?
#     - remove debug info? (not sure how much this would do)
#     - try to reduce the number of `eval`'s

# TODO: Make a resize() function that doesn't allow resizing smaller than the minimum and doesn't allow growing

# init
array_init()         { dbg "init";      test -z "${1+foo}" && return 1; eval "${1}_ct=-1" ; array_itr_init $1; array_append "$@"; }
# write
array_set()          { dbg "set";       test "$2" -le "$(array_attr_size $1)" || return 1; eval "${1}_$2=\"\$3\""; eval "dbg set to \"\$${1}_$2\""; }
array_append()       {
   dbg "append";    arr="$1"; shift;
   for value in "$@"; do
      # increment the array size
      eval "${arr}_ct=$((${arr}_ct+1));"
      # write the escaped variable to the end of the array
      eval "array_set ${arr} \$${arr}_ct \"\$value\"";
   done;
}
# shellcheck disable=SC2046
array_set_here()     { array_set $1 $(array_attr_itr $1) "$2"; }
# read
array_get()          { dbg "get";       eval "printf '%s' \"\$${1}_$2\""; }
# shellcheck disable=SC2046
array_itr_set()      { dbg "set_itr"; eval "${1}_itr=\"\$2\""; }
array_itr_init()     { dbg "reset_itr"; array_itr_set $1 -1; }
array_itr_prev()     {
   # shellcheck disable=SC2046
   if test $(array_attr_itr $1) -gt 0; then
      eval "${1}_itr=\$((\$${1}_itr-1))";
   elif test $(array_attr_itr $1) -eq -1; then
      array_itr_set $1 $(array_attr_size $1)
   else
      array_itr_init $1;
      return 1;
   fi;
}
array_itr_next()     {
   # shellcheck disable=SC2046
   if test $(array_attr_itr $1) -lt $(array_attr_size $1); then
      eval "${1}_itr=\$((\$${1}_itr+1))";
   else
      array_itr_init $1;
      return 1;
   fi;
}
array_get_next()     {
   dbg "get_next";
   if array_itr_next $1; then
      # shellcheck disable=SC2046
      array_get $1 $(array_attr_itr $1);
   else
      return $?;
   fi;
}
array_get_here()     { dbg "get_here";  eval " eval \"printf '%s' \"\\\$${1}_\$${1}_itr\"\""; }
# info
# shellcheck disable=SC2154
array_attr_size()    { dbg "attr_size";  eval "printf '%s' \"\$${1}_ct\""; }
array_attr_size_p1() { dbg "attr_size_p1";  eval "printf '%s' \"\$(($(array_attr_size $1)+1))\""; }
array_attr_itr()     { dbg "attr_itr";   eval "printf '%s' \"\$${1}_itr\""; }
# utility

# pass this an unquoted variable, returns false if it splits (multiple arguments) or true if it doesn't have splits (one argument)
var_splits() { if test $# -gt 1; then return 1; fi; return 0; }

# shellcheck disable=SC2046
array_print_esc() {
   dbg "print_esc";
   arr=$1;
   index=1
   # shellcheck disable=SC2154
   while array_itr_next $arr; do
      eval "vname=${arr}_$(array_attr_itr $arr)"
      if eval "var_splits $vname"; then
         printf ' "%s"' "\$$vname"
      else
         printf ' %s' "\$$vname"
      fi
   done;
}
