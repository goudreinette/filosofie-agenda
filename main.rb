require 'sinatra'
require 'active_support/all'
require 'stamp'
require 'require_all'
require_all 'source'


get '/' do
  @title = 'Filosofie agenda'
  @items = filosofie_nl_items
  pp filosofie_nl_items
  slim :index
end
