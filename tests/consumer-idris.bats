# Consumer idris
# Tests the idris installation inside the "consumer" images - Ubuntu and Debian

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
    # note that the consumer images have an entrypoint of the "idris2" binary
    run docker run --entrypoint /bin/bash $DOCKER_IMAGE which idris2
    assert_output --partial '/root/.idris2/bin/idris2'
}

@test "Test idris version" {
    # since we can't guess the idris version (e.g. the commit hash if we're on latest)
    # we just test if it has "Idris 2, version" at the beginning
    run docker run $DOCKER_IMAGE --version
    assert_output --partial 'Idris 2, version'
}

@test "Test Idris2 command output" {
    # make sure it doesn't have "Module Prelude not found"
    # or, any other errors
    # https://github.com/joshuanianji/idris-2-docker/issues/16#issuecomment-1254561254

    # the ENTRYPOINT is already the `idris2` command, so we just `docker run` without any other stuff
    run docker run $DOCKER_IMAGE
    refute_output --partial "Uncaught error:"
}

@test "Check environment variables" {
    # make sure IDRIS_SHA is set
    # https://bats-core.readthedocs.io/en/stable/writing-tests.html#run-test-other-commands
    # expects the cmd to return 0
    if [[ $IDRIS_VERSION != "latest" ]]; then
        # For versions that are not latest, IDRIS_VERSION should be set
        docker run $DOCKER_IMAGE bash -c "if [[ -z \$IDRIS_VERSION ]]; then exit 1; else exit 0; fi"
    else 
        # For latest, IDRIS_SHA should be set
        docker run $DOCKER_IMAGE bash -c "if [[ -z \$IDRIS_SHA ]]; then exit 1; else exit 0; fi"
    fi
}