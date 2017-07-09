require 'sinatra'
require 'active_support/all'
require 'stamp'
require 'icalendar'
require 'require_all'
require_all 'source'


get '/' do
  @title = 'Filosofie agenda'
  @items = all_items
  pp filosofie_nl_items
  slim :index
end

get '/feed.ics' do
  # Generate feed
  cal = Icalendar::Calendar.new
  all_items.map do |item|
    p item.name
    cal.event do |e|
      e.summary     = item.name
      e.description = item.name
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
