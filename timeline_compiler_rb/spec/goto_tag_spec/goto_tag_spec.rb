require_relative '../../timeline_compiler.rb'
require 'spec_helper'

root = File.dirname __FILE__

out_rb = File.expand_path(root) + '/out_rb.js'
out_rb_static = File.expand_path(root) + '/out_rb_static.js'

describe 'GotoTag' do
  before do
    timeline_dir = File.expand_path(root) + '/timelines'
    images_dir = File.expand_path(root) + '/images'
    expected_file = File.expand_path(root) + '/expected.txt'

    compile_timelines(timeline_dir, expected_file, images_dir, out_rb)
  end

  it 'is correct' do
    expect(JSON.pretty_generate(JSON.parse(IO.read(out_rb).delete_prefix("json = ")))).to eq(JSON.pretty_generate(JSON.parse(IO.read(out_rb_static).delete_prefix("json = "))))
  end
end

describe 'GotoTag2' do
  let(:timeline_dir) { File.expand_path(root) + '/timelines2' }
  let(:out_rb2) {  File.expand_path(root) + '/out_rb2.js' }
  let(:out_rb2_static) { File.expand_path(root) + '/out_rb2_static.js' }
  let(:expected_file) { File.expand_path(root) + '/expected2.txt' }
  let(:images_dir) { File.expand_path(root) + '/images2' }
  it 'is correct 2' do
    compile_timelines(timeline_dir, expected_file, images_dir, out_rb2)
    expect(JSON.parse(IO.read(out_rb2).delete_prefix("json = "))).to eq(JSON.parse(IO.read(out_rb2_static).delete_prefix("json = ")))
  end
end

describe 'Multiple timelines end before GotoTag' do
  let(:timeline_dir) { File.expand_path(root) + '/timelines3' }
  let(:out_rb3) {  File.expand_path(root) + '/out_rb3.js' }
  let(:out_rb3_static) { File.expand_path(root) + '/out_rb3_static.js' }
  let(:expected_file) { File.expand_path(root) + '/expected3.txt' }
  let(:images_dir) { File.expand_path(root) + '/images3' }
  it 'links correctly' do
    compile_timelines(timeline_dir, expected_file, images_dir, out_rb3)
    expect(JSON.parse(IO.read(out_rb3).delete_prefix("json = "))).to eq(JSON.parse(IO.read(out_rb3_static).delete_prefix("json = ")))
  end
end
