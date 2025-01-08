#!/usr/bin/env ruby

require_relative 'timeline_compiler_rb/timeline_compiler'

current_location = File.dirname(__FILE__)

compile_timelines(
  File.join(current_location, "Readable Timelines"),
  File.join(current_location, "expected_timelines.txt"),
  File.join(current_location, "icons"),
  File.join(current_location, "timelines.json"))
