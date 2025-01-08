require_relative '../../timeline_compiler.rb'
require 'spec_helper'

root = File.dirname __FILE__

out = File.expand_path(root) + '/out.txt'
_out = File.expand_path(root) + '/out.ignore'

describe 'ExpectedTimelinesComments' do
  before do
    timeline_dir = File.expand_path(root) + '/timelines'
    images_dir = File.expand_path(root) + '/images'
    expected_file = File.expand_path(root) + '/expected.txt'

    orig_stdout = $stdout.dup
    $stdout.reopen(out, "w")
    compile_timelines(timeline_dir, expected_file, images_dir, _out)
    $stdout.reopen(orig_stdout)
  end

  it 'is correct' do
    expect(File.read(out)).to eq("")
  end
end
