#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/../bats.bash"

@test '-v should output version' {
  run build/bin/somafm -v
  [ "${status}" -eq 0 ]
}

@test '--version should output version' {
  run build/bin/somafm --version
  [ "${status}" -eq 0 ]
}
