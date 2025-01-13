class Person
  attr_accessor :person_id, :name, :first_page, :last_pages, :tags

  def initialize(person_id, name)
    @person_id = person_id
    @name = name

    @first_page = nil
    @tags = {}
    @last_pages = []
  end
end

class UnknownPerson
  attr_accessor :name, :tag

  @@unknown_people = {}
  def initialize(name)
    @name = name
    @@unknown_people[name] = self
  end

  def self.find(name)
    person = @@unknown_people[name]
    person ||= UnknownPerson.new(name)
  end
end

class Link
  attr_accessor :current_page_number, :person, :colour_id, :image_id, :group_id, :next_links, :next_link_captions, :next_link_image_stars
  def initialize(timeline, current_page_number, person=nil, colour_id=nil, image_id=nil, group_id=nil)
    @@timeline = timeline
    @current_page_number = current_page_number
    @person = person
    @colour_id = colour_id
    @image_id = image_id
    @group_id = group_id
    @next_links = []
    @next_link_captions = []
    @next_link_image_stars = []
    @next_link_tags = []
  end

  def to_s
    "%s ==> %s %s %s %s" % [@current_page_number,
                            @next_links.map { |next_link| if next_link.is_a?(Link) then next_link.current_page_number else next_link.name end },
                            @person.name,
                            @colour_id,
                            @image_id]
  end

  def link_to(next_link, caption=nil, tag: nil, image_star: nil)
    @next_links << next_link
    @next_link_tags << tag
    @next_link_captions << caption
    @next_link_image_stars << image_star
  end

  def to_json
    begin
      @next_links = @next_links.zip(@next_link_tags).map do |next_link, tag|
        if next_link.is_a?(Link)
          next_link
        elsif tag
          raise "No tag \"#{tag}\" for person #{next_link.name}" if @@timeline.get_person(next_link.name).tags[tag] == nil
          @@timeline.get_person(next_link.name).tags[tag]
        else
          @@timeline.get_person(next_link.name).first_page
        end
      end
    end

    next_links_zip = @next_links.zip(@next_link_captions, @next_link_image_stars)

    [
      @person.person_id, @colour_id, @image_id, @group_id,
      next_links_zip.map do |next_link, caption, image_star|
        if image_star && !caption
          caption = Array.new(1)
        else
          image_star = Array(image_star)
          caption = Array(caption)
        end
        [
          next_link.current_page_number, @@timeline.next_page_links[next_link.current_page_number].index(next_link)] + caption + image_star
      end
    ]
  rescue => exception
    raise exception
  end
end
