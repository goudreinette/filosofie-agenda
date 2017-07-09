require 'mechanize'


def filosofie_nl_items
  Mechanize.new
    .get('https://www.filosofie.nl/agenda/index.html')
    .at('ul.agenda-list').css('a')
    .map do |a|
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
               source: 'Filosofie.nl',
               link: "https://www.filosofie.nl#{a.attr('href')}")
    end
end

def praktische_filosofie_items

end
