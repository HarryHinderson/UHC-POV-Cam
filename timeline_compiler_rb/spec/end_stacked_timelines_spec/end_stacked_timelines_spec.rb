require_relative '../../timeline_compiler.rb'
require 'spec_helper'

root = File.dirname __FILE__

describe 'Stacked timelines end correctly' do
  let(:timeline_dir) { File.expand_path(root) + '/timelines' }
  let(:out_rb) {  File.expand_path(root) + '/out_rb.js' }
  let(:out_rb_static) { File.expand_path(root) + '/out_rb_static.js' }
  let(:expected_file) { File.expand_path(root) + '/expected.txt' }
  let(:images_dir) { File.expand_path(root) + '/images' }
  it 'links correctly' do
    compile_timelines(timeline_dir, expected_file, images_dir, out_rb)
    expect(JSON.pretty_generate(JSON.parse(IO.read(out_rb).delete_prefix("json = ")))).to eq(JSON.pretty_generate(JSON.parse(IO.read(out_rb_static).delete_prefix("json = "))))
  end
end
