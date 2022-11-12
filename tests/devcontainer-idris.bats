function setup() {
    DIR="$( dirname $( dirname "$BATS_TEST_FILENAME" ) )"
    echo "DIR: $DIR"
    
    load "$DIR/tmp/bats-support/load"
    load "$DIR/tmp/bats-assert/load"
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