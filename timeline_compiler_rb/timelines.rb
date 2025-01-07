require_relative 'objects.rb'

class Timelines
  attr_accessor :colours, :images, :groups, :people, :next_page_links

  @@patterns = {
    "Pages"    =>   /^\d+(-\d+(-2)?)?\s*(:\s*[\w+\.\w-]+\s*)?$/i,
    "==>"      =>   /^=+>$/,
    "<=="      =>   /^<=+$/,
    "GOTO"     =>   /^~\s*[\w ()'^@-]+$/i,
    "@"        =>   /^@\s*[\w ()'^@-]+$/i,
    "!"        =>   /^!\s*$/,
    "Name"     =>   /^Name:\s*[\w ()'^-]+$/i,
    "Colour"   =>   /^Colour:\s*#[0-9A-F]{6}$/i,
    "Image"    =>   /^Image:\s*[\w+\.\w-]+$/i,
    "Group"    =>   /^Group:\s*[\w ()'-]+$/i,
    "Caption"  =>   /^Caption:\s*[\w ()'^=<>-]+$/i,
    "Image*"   =>   /^Image\*:\s*[\w+\.\w-]+$/i,
    "Story"    =>   /^Story:\s*[\w -]*$/i
  }

  def patterns
     @@patterns
  end

  def initialize
    @colours = []
    @images = []
    @groups = []

    @people = {}
    @next_page_links = Hash.new { |h, k| h[k] = [] }
  end

  def get_person(person_name)
    unless @people.member?(person_name)
      @people[person_name] = Person.new(@people.length, person_name)
    end

    @people[person_name]
  end


  def tokenize_timeline_file(file_path)
    lines = File.open(file_path, "r").to_enum(:each_line)
    indent_levels = []

    Enumerator.new do |g|
      first_timeline_segment = true
      lines.each do |line|
        potential_command = line.strip
        pattern_match = self.patterns.map do |name,regex|
          if potential_command =~ regex
            break [name]
          end
        end.first

        unless pattern_match
          next
        end

        next_indent_level = line.chomp.length - line.chomp.lstrip.length
        if first_timeline_segment
          indent_levels << next_indent_level
          first_timeline_segment = false
        end

        if next_indent_level > indent_levels.last
          indent_levels << next_indent_level
          g << ["BOT"]
        elsif next_indent_level < indent_levels.last
          loop do
            indent_levels.pop
            g << ["EOT"]
            break if next_indent_level == indent_levels.last
          end
        end
        indent_level = next_indent_level


        if pattern_match == "Pages"
          args = potential_command.split(":")
          page_args, image_args = args
          page_args = page_args.split("-").map { |s| s.to_i }
          if page_args.length == 1
            page_args << page_args[0]
          end
          g << [pattern_match, [page_args, image_args]]
        elsif pattern_match == "!"
          if indent_levels.last > 0
            g << ["EOT"]
          end
          g << ["BOT"]
        elsif pattern_match == "GOTO"
          g << [pattern_match, potential_command[1..].strip] # ~john -> john
        elsif %w(Name Colour Image Image* Group Caption Story).include?(pattern_match)
          g << [pattern_match, potential_command.split(":", 2)[1].strip]
        elsif pattern_match == "@"
          g << [pattern_match, potential_command.split("@", 2)[1].strip]
        else
          g << [pattern_match]
        end
      end

      g << ["EOT"]
    end.to_a
  end

  def sanity_check(timeline_tokens, file_path)
    timeline_tokens.each_cons(2).any? do |a,b|
      command_a, arg_a = a
      command_b, arg_b = b
      if command_a == command_b
        case command_a
        when "GOTO"
          raise "Consecutive GOTOs in " + file_path
        end
      end

      if command_a == "GOTO" && arg_a.match(/.+@.+/) && command_b == "Pages"
        raise "GOTO TAG followed by Pages in " + file_path
      end
    end
  end

  def add_timeline(file_path)
    timeline_tokens = tokenize_timeline_file(file_path)
    sanity_check(timeline_tokens, file_path)
    exec_timeline_tokens(timeline_tokens)
  end

  def exec_timeline_tokens(command_iterator, previous_pages=nil, current_person=nil, current_colour=nil, current_image=nil, current_group=nil, next_caption=Array(nil), current_story="", image_star=Array(nil))
    # Page to pass into next splinter timeline
    splinter_pages = []
    # Page returned from splinter timeline
    return_pages = []

    unless previous_pages
      previous_pages = []
    end


    loop do
      command, args = command_iterator.shift

      # Ensure timeline ends by feeding as many EOTs as needed.
      # Required when a split timeline ends a file, not giving
      # previous timelines a chance to end.
      if command.nil?
        command = "EOT"
      end

      case command
      when "Pages"
        pages, page_image = args
        f,l,s = pages

        if page_image
          page_image = page_image.strip
          unless @images.include?(page_image)
            @images << page_image
          end
          page_image = Array(@images.index(page_image))
        end

        previous_image = current_image
        current_image = page_image ? page_image[0] : current_image

        (f..l).step(s||1).each do |page_number|
          unless current_story.empty?
            page_number = current_story + page_number.to_s
          end

          next_link = Link.new(self, page_number, current_person, current_colour, current_image, current_group)

          if current_person.is_a?(Person) and current_person.first_page == nil
            current_person.first_page = next_link
          end

          current_person.tags.each do |tag, link|
            if current_person.is_a?(Person) and current_person.tags[tag] == Array(nil)
              current_person.tags[tag] = next_link
            end
          end

          @next_page_links[page_number] << next_link

          previous_pages.each { |page| page.link_to(next_link, next_caption, image_star: image_star) }
          previous_pages = [next_link]
          next_caption = nil
          image_star = nil
        end
        current_image = previous_image

      when "==>"
        splinter_pages = previous_pages

      when "<=="
        previous_pages += return_pages

      when "@"
        current_person.tags[args] = Array(nil)

      when "GOTO"
        args = args.split("@", 2)
        person = UnknownPerson.find(args[0].strip)
        tag = args[1] && args[1].strip

        previous_pages.each do |page|
          page.link_to(person, next_caption, tag: tag, image_star: image_star)
        end
        previous_pages = [Link.new(self, person)]
        @next_page_links[person] << previous_pages[0]
        next_caption = Array(nil)

      when "EOT"
        current_person.last_pages = previous_pages
        return previous_pages

      when "BOT"
        return_pages = self.exec_timeline_tokens(command_iterator, splinter_pages, current_person, current_colour, current_image, current_group, next_caption, current_story, image_star)
        splinter_pages = []

      when "Name"
        args = args.strip
        current_person = self.get_person(args)

      when "Colour"
        args = args.strip
        unless @colours.include?(args)
          @colours << args
        end
        current_colour = @colours.index(args)

      when "Image"
        args = args.strip
        unless @images.include?(args)
          @images << args
        end
        current_image = @images.index(args)

      when "Image*"
        args = args.strip
        unless @images.include?(args)
          @images << args
        end
        image_star = Array(@images.index(args))

      when "Group"
        args = args.strip
        unless @groups.include?(args)
          @groups << args
        end
        current_group = @groups.index(args)

      when "Caption"
        args = args.strip
        next_caption = Array(args)

      when "Story"
        args = args.strip
        current_story = args
        unless current_story.empty?
          current_story = current_story + "_"
        end
      end
    end
  end
end
