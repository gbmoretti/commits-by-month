require 'json'
require 'httparty'

require_relative 'lib/interface'
require_relative 'lib/client'
require_relative 'lib/organization'
require_relative 'lib/repository'
require_relative 'lib/commit'



login = Interface::ask_login
pass = Interface::ask_password

client = Client.new(login,pass)

orgs = [Organization.new('innvent',client), Organization.new('elogroup',client)]

author = login
aggregated_commits = []

puts 'Carregando commits...'
orgs.each do |org|
   org.repositories.each do |r|
    commits = r.commits_from_author(author)
    puts r.name + ': ' + commits.count.to_s if commits.count > 0
    aggregated_commits += commits    
  end
end

aggregated_commits.sort!
commits_by_date = {}
puts 'By date:'
aggregated_commits.each do |ac|
  date_string = ac.date.strftime("%d/%m/%Y")
  commits_by_date[date_string] = [] if commits_by_date[date_string].nil?
  commits_by_date[date_string] << ac
end

commits_by_date.each_pair do |date,commits|
  repos = []
  commits.each do |commit|
    repos << commit.repository
  end
  repos.uniq!
  
  puts date + "\t" + commits.count.to_s + "\t(" + (repos.map { |x| x.name } * ' ') + ')'
end
