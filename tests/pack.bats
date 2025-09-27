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

@test "Test pack info command" {
    echo "Testing pack info command on docker image $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE pack info
    assert_success
}

@test "Test pack binary location" {
    echo "Testing pack binary location on docker image $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE which pack
    assert_output '/home/vscode/.pack/bin/pack'
}

@test "Test idris2 binary location" {
    echo "Testing idris2 binary location on docker image $DOCKER_IMAGE"

    run docker run $DOCKER_IMAGE which idris2
    assert_output '/home/vscode/.pack/bin/idris2'
}