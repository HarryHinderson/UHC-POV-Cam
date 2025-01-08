require 'json'
require 'neatjson'
require_relative 'timelines.rb'
require 'optparse'

@options = {}
OptionParser.new do |opt|
  opt.on('-v','--verbose', 'List timelines as they are added') { |o| @options[:verbose] = true }
end.parse!

def to_json(obj)
  JSON.neat_generate(obj, {indent: '    ', after_colon: 1})
end

def timelines_in_directory(directory)
  directory = File.join(directory, "")
  timelines_in_directory_1(directory).map do |file|
    file.slice!(directory)
    file
  end
end

def timelines_in_directory_1(directory)
  results = []

  Dir.foreach(directory) do |file|
    next if (file == "." || file == "..")
    file = File.join(directory, file)
    if File.directory? file
      results << timelines_in_directory_1(file)
    else
      results << file
    end
  end
  results.flatten
end

def compile_timelines(timeline_directory, expected_timelines_path, images_directory, output_path)
  # Get order of expected people from designated file
  # Read timelines in order
  # Check expected images present
  unless @options
    @options = {}
  end

  timelines = Timelines.new

  actual_timeline_files = timelines_in_directory(timeline_directory)
  expected_timeline_files = []

  File.open(expected_timelines_path, "r").each_line do |line|
    case line.strip
    when ""
      next
    when /^#/
      next
    else
      expected_timeline_files << "%s.txt" % [line.strip]
    end
  end

  timeline_files = expected_timeline_files.select { |timeline| actual_timeline_files.include?(timeline) }

  missing_timeline_files = expected_timeline_files.reject { |timeline| actual_timeline_files.include?(timeline) }

  unexpected_timeline_files = actual_timeline_files.reject { |timeline| timeline.end_with?('~') || expected_timeline_files.include?(timeline)}

  begin
    timeline_files.each do |timeline_file|
      puts "Adding %s" % timeline_file if @options[:verbose]
      timelines.add_timeline(File.join(timeline_directory, timeline_file))
    end
  rescue => exception
    warn "FATAL ERROR:\n" + exception.message
    return
  end

  # Pass through, replacing links from relative locations with absolute locations
  # (Note: still have links to relative locations)
  timelines.people.keys.each do |person_name|
    person = UnknownPerson.find(person_name)
    if timelines.next_page_links.include?(person)
      timelines.next_page_links[person].each do |page|
        page.next_links.each do |next_link|
          timelines.people[person_name].last_pages.each do |last_page|
            last_page.link_to(next_link)
          end
        end
      end
      timelines.next_page_links.delete(person)
    end
  end

  missing_jumps = timelines.next_page_links.select { |page_number, link| page_number.is_a? UnknownPerson }.map { |person, link| person.name }
  unless missing_jumps.empty?
    raise "Missing required jumps:
      #{missing_jumps.join(', ')}"
  end

  sorted_page_links = timelines.next_page_links.sort_by do |k,v|
    case k
    when Integer
      [1, k]
    when String
      match = k.match(/(^.+)_(\d+)/)
      [2, match[1], match[2].to_i]
    end
  end

  begin
    puts "Resolving relative links, and converting to json" if @options[:verbose]
    # TODO: This should not be a single step, and to_json is a
    # terrible name for doing the former
    links = {}
    sorted_page_links.each do |page_number, next_page_links|
      links[page_number] = next_page_links.map do |link|
        link.to_json
      end
    end
  rescue => exception
    warn "FATAL ERROR\n" + exception.message
    return
  end

  output = {
    "peoplenames" => timelines.people.keys,
    "colours" => timelines.colours,
    "images" => timelines.images,
    "groups" => timelines.groups,

    "timelines" => links
  }
    
  File.open(output_path, "w") do |output_file|
    json_output = to_json(output)
    output_file.write(json_output)
  end

  existing_images = Dir.children(images_directory).reject { |img| img.end_with?('~') }
  missing_images = timelines.images.reject { |image| existing_images.include?(image) }
  unexpected_images = existing_images.reject { |image| timelines.images.include?(image) }

  if [missing_images, unexpected_images, missing_timeline_files, unexpected_timeline_files].any? { |problem| !problem.empty? }
    puts "Problems:"

    unless missing_images.empty?
      puts "Missing Images:"
      puts missing_images.to_s
    end

    
    unless unexpected_images.empty?
      puts "Unexpected Images:"
      puts unexpected_images.to_s
    end

    
    unless missing_timeline_files.empty?
      puts "Missing timeline files:"
      puts missing_timeline_files.to_s
    end

    unless unexpected_timeline_files.empty?
      puts "Unexpected Timeline files:"
      puts unexpected_timeline_files.to_s
    end
  end
end
