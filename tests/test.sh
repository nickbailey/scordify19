#!/bin/bash

shopt -s expand_aliases

SCORDIFY19=../scordify19

oneTimeSetUp() { echo oneTimeSetUp ; }

#oneTimeTearDown () { }

test_a4mapstoa4_absolute () {
    expected="a'"
    result=$( $SCORDIFY19 "a'" <<< "a'")
    assertTrue "a', with origin a', should map to a'" \
        '[[ "$result" == "$expected" ]]'
}

. shunit2
