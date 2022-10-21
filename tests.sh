#!/usr/bin/env bash

# add -x flag for more debugging
set -eu

source ./posix-arrays.sh

ARRAY_DEBUG=true  # get the array library to print extra debug information

# Some colors to spice things up
Green="[32m"
   Nc="(B[m" # No Color

#######################################################
##                       TESTS                       ##
#######################################################

# Announce a test
ann() {
   if ${TEST:-false};then
      if test -n "${1:+foo}";then
         msg="$Green$1$Nc"
         shift
         if test -n "${1:+foo}";then
            msg2=" $*";
         fi;
         msg "$msg${msg2:-}"
      else
         msg
      fi;
   fi;
}

test1() {
   ann "Test 1:" "weird array"

   # make an array with lots of weird elements
   array_init m hello world "'" '"' '' "I've got an apostrophe" 'I"ve got a quote' '

there are some newlines

in here

' 'there should be two blank lines above me' 'hello   there' i am 'at    the ...  \ end'
   # print the array with each element on a new line
   eval "printf '%s\n' $(array_print_esc m)"

   # What the output of element 5 should look like
   ## array_get m 5

   ann "Test 1.5:" "weird array: variable edition"

   # shellcheck disable=SC2034
   my_var="I_shouldn't_be_\"_here"
   # shellcheck disable=SC2034
   my_var_with_spaces="I shouldn't be \" here"

   # shellcheck disable=SC2016
   array_init vars '$my_var' '"$my_var"' '\"$my_var\"' '$my_var_with_spaces' '"$my_var_with_spaces"' '\"$my_var_with_spaces\"' \
    "'\$my_var'" "\"\$my_var\"" '\"\$my_var\"' "'\$my_var_with_spaces'" "\"\$my_var_with_spaces\"" '\"\$my_var_with_spaces\"'
   eval "printf '%s\n' $(array_print_esc vars)"

   ann
   ann "Test 2:" "combining arrays"

   # make a new array that has the previous array inside it, but add strings on to the ends
   eval "array_init the_best_array 'I AM THE BEST ARRAY!!!!' $(array_print_esc m) 'I AM TWO ARRAYS COMBINED !!!!!!!!'"
   # print the array with each element on a new line
   eval "printf '%s\n' $(array_print_esc the_best_array)"
}

test3() {
   ann
   ann "Test 3:" "2d array"

   # A 2d array
   two_dee_array='I_am_a_2D_array' # Declaring the name with a variable just for fun
   array_init $two_dee_array
   rows=1
   cols=6
   for var in $(seq 0 $rows); do
      array_append $two_dee_array "${two_dee_array}_$var"
   done
   # init rows
   start=0
   # shellcheck disable=SC2046
   for var in $(seq 0 $(array_attr_size $two_dee_array)); do
      # shellcheck disable=SC2086
      array_init "$(array_get $two_dee_array $var)"
      for i in $(seq $start $cols); do
         # shellcheck disable=SC2086
         array_append "$(array_get $two_dee_array $var)" $i
         start=$((start+1))
         cols=$((cols+1))
      done
   done
   # print rows
   while array_get_next $two_dee_array; do
      var="$(array_get_here $two_dee_array)"
      printf '%s: ' "$var"
      # shellcheck disable=SC2086
      eval "printf '% 6d' $(array_print_esc $var)"
      printf '\n'
   done
}

test4() {
   ann
   ann "Test 4:" "iterating over the list"

   # Make an array, print each element from it while setting each element form it to another value, then print it again

   array_init my_awesome_array 'the_first' 'the second' 'thethird'
   i=1
   while array_itr_next my_awesome_array; do
      dbg "getting here"
      printf '  %s\n' "$(array_get_here my_awesome_array)"
      dbg "setting here"
      array_set_here my_awesome_array "$i"
      i=$((i+1))
   done
   # array_itr_init my_awesome_array
   ann "Test 4:" "iterating forwards"
   while array_itr_next my_awesome_array; do
      printf '  %s\n' "$(array_get_here my_awesome_array)"
   done

   ann "Test 4:" "iterating backwards"
   while array_itr_prev my_awesome_array; do
      printf '  %s\n' "$(array_get_here my_awesome_array)"
   done
}

num_tests=4

if test $# = 0; then
   echo "Usage: ${0##*/} [TEST_NUM]"
   echo "There are currently $num_tests tests"
fi

for test in "$@"; do
   test "$test" = 2 && test=1
   test "$test" -gt 0 || msg "Please input a test number to run from 1 to 4" && exit 1
   test "$test" -le $num_tests || msg "Please input a test number to run from 1 to 4" && exit 1
   eval "test$test"
done
