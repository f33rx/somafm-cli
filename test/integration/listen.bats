#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/../bats.bash"

@test 'listen with invalid quality should exit 1' {
  run build/bin/somafm listen groovesalad --quality=invalid
  [ "${status}" -eq 1 ]
}
