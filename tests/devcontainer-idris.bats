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
    # use "partial" in case we need to pull the image from the cloud

    run docker run $DOCKER_IMAGE which idris2
    assert_output --partial '/usr/local/lib/idris2/bin/idris2'
}

@test "Test Idris prefix" {
    echo "Testing Idris prefix in $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE idris2 --prefix
    assert_output --partial '/usr/local/lib/idris2'
}

@test "Test Idris2 command output" {
    # make sure it doesn't have "Module Prelude not found"
    # or, i guess any other error.
    # https://github.com/joshuanianji/idris-2-docker/issues/16#issuecomment-1254561254
    echo "Testing Idris2 command output $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE idris2
    refute_output --partial "Uncaught error:"
}

@test "Check environment variables" {
    # make sure IDRIS_SHA is set
    # https://bats-core.readthedocs.io/en/stable/writing-tests.html#run-test-other-commands
    # expects the cmd to return 0
    if [[ $IDRIS_VERSION != "latest" ]]; then
        # For versions that are not latest, IDRIS_VERSION should be set
        docker run $DOCKER_IMAGE bash -c "if [[ -z \$IDRIS_LSP_VERSION ]]; then exit 1; else exit 0; fi"
    else 
        # For latest, IDRIS_SHA should be set
        docker run $DOCKER_IMAGE bash -c "if [[ -z \$IDRIS_LSP_SHA ]]; then exit 1; else exit 0; fi"
    fi
}