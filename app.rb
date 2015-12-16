require 'sinatra'
require 'net/http'
require 'uri'
require 'json'

GOOD_KEYWORD = ENV['GOOD_KEYWORD'] || '鳥取県'
BAD_KEYWORD  = ENV['BAD_KEYWORD']  || '島根県'

get '/' do
  erb :index, :locals => {
    :good_word => GOOD_KEYWORD,
    :bad_word => BAD_KEYWORD
  }
end

get '/*' do
  redirect to('/')
end

post '/search' do
  items = dbpedia(params[:keywords].last)
  
  good_index = items.index GOOD_KEYWORD
  bad_index = items.index BAD_KEYWORD
  
  is_good = (not good_index.nil?)
  is_bad = (not bad_index.nil?)
  
  if is_good && is_bad
    status = 'even'
  elsif is_good
    status = 'good'
  elsif is_bad
    status = 'bad'
  else
    status = 'none'
  end
  
  if items.empty?
    status = 'end'
  end
  
  erb :result, :locals => {
    :items => items,
    :keywords => params[:keywords],
    :status => status,
    :good_index => good_index,
    :bad_index => bad_index
  }
end

private
def dbpedia(keyword)
  url = "http://ja.dbpedia.org/data/#{keyword}.json"
  uri = URI.parse(URI.escape(url))
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.open_timeout = 60
    http.read_timeout = 60
    http.get(uri.request_uri)
  end
  json = response.body
  result = JSON.parse(json)["http://ja.dbpedia.org/resource/#{keyword}"]
  if result
    links = result['http://dbpedia.org/ontology/wikiPageWikiLink'].map do |link|
      link['value'].gsub('http://ja.dbpedia.org/resource/', '')
    end
    links.delete_if do |text|
      ['Category:', '特別:', 'En:', 'ファイル:'].any? {|prefix| text.start_with? prefix}
    end
  else
    []
  end
end
