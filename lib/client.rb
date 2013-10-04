require 'uri'

class Client
  class BadResponseError < StandardError; end
  class InvalidBodyError < StandardError; end

  def initialize(username,password)
    @username = username
    @password = password
    @method = Net::HTTP::Get
  end

  def request(url,body=[])
    part_parsed = []
    begin
      response = perform_request(url)
      part_parsed += parse_response(response.body)
      body += request(next_page(response),body) unless next_page(response).nil?
      body += part_parsed
      body
    rescue BadResponseError => e
      puts '!! ' + e.message
      return []
    rescue InvalidBodyError => e
      puts '!! ' + e.message
      return []
    end
  end

  private
  def perform_request(url)
    request = HTTParty::Request.new(@method,url,basic_auth: {username: @username, password: @password})
    response = request.perform
    raise BadResponseError.new("#{response.code}: #{response.message} (#{url})") if response.code != 200
    return response
  end

  def next_page(response)
    link_string = response.headers['link']
    ref_next_url(link_string) unless link_string.nil?
  end

  def ref_next_url(string)
    string = string.match(/^<.+>; rel="next",/)
    string[0].match(URI.regexp)[0] unless string.nil?
  end

  def parse_response(response)
    begin
      JSON::parse(response)
    rescue => e
       raise InvalidBodyError.new(response)
    end
  end

end