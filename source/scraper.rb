require 'mechanize'
require 'timers'


class Items
  def initialize
    @mechanize = Mechanize.new
    @timers = Timers::Group.new
    @items = fetch_all

    @timers.every(900) { @items = fetch_all }

    Thread.new do
      loop { @timers.wait }
    end
  end

  def all
    @items
  end

  def fetch_all
    puts "Fetching all items..."
    (fetch_filosofie + fetch_praktische_filosofie + fetch_rug)
      .sort_by(&:date)
      .select {|i| i.date >= Date.today }
      .tap {|i| pp i }
  end

  def filosofie_nl_pages
    (Date.today..Date.today + 11.months)
      .map {|d| "#{d.month}-#{d.year}"}
      .uniq
      .map {|d| "https://www.filosofie.nl/nl/agenda/hitlist/0/#{d}/index.html" }
  end

  def fetch_filosofie
    filosofie_nl_pages.flat_map do |url|
      if agenda_list = @mechanize.get(url).at('ul.agenda-list')
        agenda_list.css('a').map do |a|
          # Date
          month = a.css('b i').text
          a.css('b i').remove
          day = a.css('b').text

          # City
          city = a.css('p i').text
          a.css('i').remove

          Item.new(city: city,
                   name: a.css('p').text,
                   date: Date.parse("#{day} #{month}"),
                   source: 'filosofie.nl',
                   link: "https://www.filosofie.nl#{a.attr('href')}")
        end
      else
        []
     end
   end.uniq(&:link)
  end

  def fetch_praktische_filosofie
    @mechanize
      .get('https://www.praktischefilosofie.nl/agenda')
      .at('.events').css('tr')
      .map do |tr|
        date = tr.css('.date')
        day = date.css('.day').text
        month = date.css('.month').text

        Item.new(city: tr.attr('data-location'),
                 name: tr.css('.description').text.gsub(/\s+/, ' ')[1..-2],
                 date: Date.parse("#{day} #{month}"),
                 source: 'praktischefilosofie.nl',
                 link: tr.css('.description a').attr('href'))
      end
  end

  def fetch_rug
    @mechanize
      .get('http://www.rug.nl/filosofie/news/events/')
      .css('.rug-layout .rug-table-holder')
      .map do |table|
        Item.new(city: 'Groningen',
                 name:  table.css('h2').text,
                 date: Date.parse(table.css('tr:nth-child(3) td').text),
                 source: 'rug.nl',
                 link: 'http://www.rug.nl/filosofie/news/events/')
      end
  end
end
