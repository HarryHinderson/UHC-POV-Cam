require_relative '../../timeline_compiler.rb'
require 'spec_helper'

root = File.dirname __FILE__

out_rb = File.expand_path(root) + '/out_rb.js'
out_py = File.expand_path(root) + '/out_py.js'

describe 'HomestuckTimeline' do
  before do
    timeline_dir = File.expand_path(root) + '/timelines'
    images_dir = File.expand_path(root) + '/images'
    expected_file = File.expand_path(root) + '/expected.txt'



    # File.stubs(:read).with(timeline_dir
    system "python #{root}/compile_timelines.py"
    compile_timelines(timeline_dir, expected_file, images_dir, out_rb)
  end

  it 'is correct' do
    expect(JSON.pretty_generate(JSON.parse(IO.read(out_rb).delete_prefix("json = ")))).to eq(JSON.pretty_generate(JSON.parse(IO.read(out_py).delete_prefix("json = "))))
  end
end
