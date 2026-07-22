#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/../bats.bash"

@test 'channels should output more than one channel and exit 0' {
  run build/bin/somafm channels
  [ "${#lines[@]}" -gt 1 ]
  [ "${status}" -eq 0 ]
}
