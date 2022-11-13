function setup() {
    # Assumes the BATS_TEST_FILENAME is always one layer deep inside tests/
    # not a very good assumption! But i'm not going to be using bats much right now...
    DIR="$( dirname $( dirname "$BATS_TEST_FILENAME" ) )"

    # by default, look in tests/test_helper
    if [[ -z "${LIB_PATH}" ]]; then
        LIB_PATH="$DIR/tests/test_helper"
    fi
    
    load "$LIB_PATH/bats-support/load"
    load "$LIB_PATH/bats-assert/load"
}

@test "Test location of Idris binary" {
    echo "Running idris bin location tests on docker image $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE which idris2
    assert_output '/usr/local/lib/idris2/bin/idris2'
}

@test "Test Idris prefix" {
    echo "Testing Idris prefix in $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE idris2 --prefix
    assert_output '/usr/local/lib/idris2'
}

@test "Test Idris2 command output" {
    # make sure it doesn't have "Module Prelude not found"
    # https://github.com/joshuanianji/idris-2-docker/issues/16#issuecomment-1254561254
    echo "Testing Idris2 command output $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE idris2
    refute_output --partial "Module Prelude not found"
}