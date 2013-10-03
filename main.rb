require 'json'
require 'httparty'

def request(url,method=Net::HTTP::Get)
  request = HTTParty::Request.new(method,url,basic_auth: {username: 'gbmoretti', password: '4215891'})
  response = request.perform
  if response.code != 200
    puts "#{response.code}: #{response.message} (#{url})"
    return nil
  else
    response.body
  end
end

def parse(string)
  return [] if string.nil?
  begin
    JSON::parse(string)
  rescue => e
     puts "Algo deu errado :("
     puts string
     raise Exception
  end
end

orgs = %w(elogroup innvent)
author = 'gbmoretti'

orgs.each do |org|
  #repositories = exec("curl -s -u gbmoretti:4215891 ")
  repositories = request("https://api.github.com/orgs/#{org}/repos")
  repositories = parse(repositories)


  repositories.each do |r|
    full_name =  r['full_name']
    #cmd = "curl -s -u gbmoretti:4215891 https://api.github.com/repos/#{r['full_name']}/commits?author=#{author}"
    #commits = exec(cmd)
    commits = request("https://api.github.com/repos/#{r['full_name']}/commits?author=#{author}")

    commits = parse(commits)
    puts full_name + ': ' + commits.count.to_s if commits.count > 0
  end
end