require 'sinatra'
require 'active_support/all'
require 'stamp'
require 'icalendar'
require 'require_all'
require_all 'source'


configure do
  @@items = Items.new
end


get '/' do
  @title = 'Filosofie agenda'
  @items = @@items.all
  slim :index
end

get '/feed.ics' do
  # Generate feed
  cal = Icalendar::Calendar.new
  @@items.all.map do |item|
    pp item.description
    cal.event do |e|
      e.summary     = item.name
      e.description = item.description
      e.dtstart     = item.date
      e.dtend       = item.date
      e.url         = item.link
    end
  end

  # Send it
  content_type 'text/calendar'
  attachment "feed.ics"
  cal.to_ical
end
