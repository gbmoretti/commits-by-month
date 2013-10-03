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

def ask_login
  p "Enter your GitHub username"
  gets.chomp
end

# No-echo password input, stolen from Defunkt's `hub`
# Won't work in Windows
def ask_password
  p "Enter your GitHub password (this will NOT be stored)"
  tty_state = `stty -g`
  system 'stty raw -echo -icanon isig' if $?.success?
  pass = ''
  while char = $stdin.getbyte and not (char == 13 or char == 10)
    if char == 127 or char == 8
      pass[-1,1] = '' unless pass.empty?
    else
      pass << char.chr
    end
  end
  pass
ensure
  system "stty #{tty_state}" unless tty_state.empty?
end

login = ask_login
pass = ask_password

client = Client.new(login,pass)
orgs = [Organization.new('elogroup',client), Organization.new('innvent',client)]

author = login


orgs.each do |org|
   org.repositories.each do |r|
    commits = r.commits_from_author(author)
    puts r.name + ': ' + commits.count.to_s if commits.count > 0
  end
end