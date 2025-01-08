require_relative '../../timeline_compiler.rb'
require 'spec_helper'

root = File.dirname __FILE__

out_rb = File.expand_path(root) + '/out_rb.js'
out_py = File.expand_path(root) + '/out_py.js'

describe 'TimelineFiles' do
  let(:timeline_dir) { __dir__ + '/timelines' }
  let(:expected_file) { __dir__ + '/expected.txt' }

  it 'lists files recursively' do
    expect(timelines_in_directory(timeline_dir)).to match_array(
                                                      ["Homestuck/dave.txt",
                                                       "Homestuck/jade.txt",
                                                       "Homestuck/john.txt",
                                                       "Homestuck/rose.txt",
                                                       "Homestuck_Beyond_Canon/Candy/dave.txt",
                                                       "Homestuck_Beyond_Canon/Candy/jade.txt",
                                                       "Homestuck_Beyond_Canon/Candy/john.txt",
                                                       "Homestuck_Beyond_Canon/Candy/rose.txt",
                                                       "Homestuck_Beyond_Canon/Meat/dave.txt",
                                                       "Homestuck_Beyond_Canon/Meat/jade.txt",
                                                       "Homestuck_Beyond_Canon/Meat/john.txt",
                                                       "Homestuck_Beyond_Canon/Meat/rose.txt",
                                                       "Homestuck_Epilogues/Candy/dave.txt",
                                                       "Homestuck_Epilogues/Candy/jade.txt",
                                                       "Homestuck_Epilogues/Candy/john.txt",
                                                       "Homestuck_Epilogues/Candy/rose.txt",
                                                       "Homestuck_Epilogues/Meat/dave.txt",
                                                       "Homestuck_Epilogues/Meat/jade.txt",
                                                       "Homestuck_Epilogues/Meat/john.txt",
                                                       "Homestuck_Epilogues/Meat/rose.txt"])
  end
end
