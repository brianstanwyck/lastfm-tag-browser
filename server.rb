require 'sinatra'
require 'httparty'
require 'json'

LAST_FM_API_KEY = '18508165b781bb40ebbd6aa5401117e3'

class LastFM
  def initialize(api_key)
    @api_key = api_key
  end

  def top_tags
    url = "http://ws.audioscrobbler.com/2.0/?method=tag.getTopTags&api_key=#{@api_key}&format=json"

    HTTParty.get(url).parsed_response["toptags"]["tag"]
  end

  def tag_tree(tag, depth = 1)
    if depth == 1
      {
        name: tag,
        children: similar_tags(tag)
      }
    else
      {
        name: tag,
        children: similar_tags(tag).map do |other_tag|
          tag_tree(other_tag['name'], depth - 1)
        end
      }
    end
  end

  def tag_artists(tag)
    url = "http://ws.audioscrobbler.com/2.0/?method=tag.gettopartists&tag=#{tag}&api_key=#{@api_key}&format=json"
    HTTParty.get(url).parsed_response["topartists"]["artist"].map do |artist_hash|
      {
        name: artist_hash['name'],
        image_url: artist_hash['image'].find { |image| image['size'] == 'large' }['#text']
      }
    end
  end

  private

  def similar_tags(tag)
    url = "http://ws.audioscrobbler.com/2.0/?method=tag.getsimilar&tag=#{tag}&api_key=#{@api_key}&format=json"
    HTTParty.get(url).parsed_response["similartags"]["tag"].take(15).map do |tag_hash|
      { name: tag_hash['name'] }
    end
  end
end

class TagTree
  def initialize(depth)
    @depth = depth
  end
end

get '/' do
  send_file File.join('public','index.html')
end

get '/top_tags.json' do
  content_type :json
  @last_fm = LastFM.new(LAST_FM_API_KEY)
  @last_fm.top_tags.map { |hash| { name: hash['name'] } }.to_json
end

get '/tag_tree.json' do
  content_type :json
  @last_fm = LastFM.new(LAST_FM_API_KEY)
  tag = params[:t]
  @last_fm.tag_tree(tag, 2).to_json
end

get '/artists.json' do
  content_type :json
  @last_fm = LastFM.new(LAST_FM_API_KEY)
  tag = params[:t]
  @last_fm.tag_artists(tag).to_json
end
