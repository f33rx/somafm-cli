#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/../bats.bash"

@test '--visualizer with nonexistent channel should exit nonzero' {
  run build/bin/somafm listen nonexistentchannel --visualizer
  [ "${status}" -ne 0 ]
}
