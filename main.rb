require 'json'
require 'httparty'

class Client
  class BadResponseError < StandardError; end
  class InvalidBodyError < StandardError; end

  def initialize(username,password)
    @username = username
    @password = password
    @method = Net::HTTP::Get
  end

  def request(url)
    begin
      perform_request(url)
      parse_response
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
    @request = HTTParty::Request.new(@method,url,basic_auth: {username: @username, password: @password})
    @response = @request.perform
    raise BadResponseError.new("#{@response.code}: #{@response.message} (#{url})") if @response.code != 200
  end

  def parse_response
    begin
      JSON::parse(@response.body)
    rescue => e
       raise InvalidBodyError.new(@response.body)
    end
  end

end

class Repository

  attr_reader :name, :commits

  def initialize(name,client)
    @name = name
    @client = client
  end

  def commits_from_author(author)
    @commits ||= get_commits(author)
  end

  private
  def get_commits(author)
    @client.request("https://api.github.com/repos/#{@name}/commits?author=#{author}")
  end

end

class Organization

  attr_reader :name, :repositories

  def initialize(name,client)
    @name = name
    @client = client
  end

  def repositories
    @repositories ||= get_repos
  end

  private
  def get_repos
    repositories = []
    response = @client.request("https://api.github.com/orgs/#{@name}/repos")
    response.each do |r|
      repositories << Repository.new(r['full_name'],@client)
    end
    repositories
  end

end

client = Client.new('gbmoretti','4215891')
orgs = [Organization.new('elogroup',client), Organization.new('innvent',client)]

author = 'gbmoretti'


orgs.each do |org|
   org.repositories.each do |r|
    commits = r.commits_from_author(author)
    puts r.name + ': ' + commits.count.to_s if commits.count > 0
  end
end