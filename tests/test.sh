#!/bin/bash

shopt -s expand_aliases

SCORDIFY19="../scordify19 -d"

#oneTimeSetUp() { }

#oneTimeTearDown () { }

test_frist_note_converted_outside_braces () {
    # works with leading space!
    expected="g'! g'!"
    result=$( $SCORDIFY19 "a'" <<< "gis' gis'")
    assertTrue "Music expression without braces incorrectly parsed" \
        '[[ "$result" == "$expected" ]]'
}

test_a4mapstoa4_absolute () {
    expected="{ a' }"
    result=$( $SCORDIFY19 "a'" <<< "{ a' }")
    assertTrue "a', with origin a', should map to a'" \
        '[[ "$result" == "$expected" ]]'
}

test_octave_interval_absolute () {
    expected="{ a'! e'''! a'! d! }"
    result=$( $SCORDIFY19 "a'" <<< "{ a' a'' a' a }")
    echo $result
    assertTrue "Octave jumps in 12EDO map to octave+fifth" \
        '[[ "$result" == "$expected" ]]'
}

. shunit2

 { "c", "cis", "d", "ees", "e", "f", "fis", "g", "aes", "a", "bes", "b" };
