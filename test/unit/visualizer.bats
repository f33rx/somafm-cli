#!/usr/bin/env bats

load ../bats

@test '--visualizer with nonexistent channel should exit nonzero' {
  run build/bin/somafm listen nonexistentchannel --visualizer
  [ "${status}" -ne 0 ]
}
