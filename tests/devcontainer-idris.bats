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
    assert_output '/home/vscode/.local/bin/idris2'
}

@test "Test pack info command" {
    echo "Testing pack info command on docker image $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE pack info
    assert_success
}

@test "Test pack binary location" {
    echo "Testing pack binary location on docker image $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE which pack
    assert_output '/home/vscode/.local/bin/pack'
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
    # make sure version information is set
    # https://bats-core.readthedocs.io/en/stable/writing-tests.html#run-test-other-commands
    # expects the cmd to return 0
    if [[ $IDRIS_VERSION != "latest" ]]; then
        # For versions that are not latest, IDRIS_VERSION should be set
        docker run $DOCKER_IMAGE bash -c "if [[ -z \$IDRIS_VERSION ]]; then exit 1; else exit 0; fi"
    fi

    # the devcontainer-latest has no $IDRIS_SHA env var - it just uses the latest pack repo.
}

@test "Test rlwrap is available" {
    echo "Testing rlwrap availability on docker image $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE which rlwrap
    assert_output '/usr/local/bin/rlwrap'
}

@test "Test rlwrap functionality" {
    echo "Testing rlwrap basic functionality on docker image $DOCKER_IMAGE"

    # Test that rlwrap can wrap a simple command and exit cleanly
    # Using echo with immediate EOF to test basic wrapping without interaction
    run docker run $DOCKER_IMAGE bash -c 'echo "" | rlwrap echo "test"'
    assert_success
    assert_output "test"
}