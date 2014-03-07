#encoding: utf-8
require 'json'
require 'httparty'

require_relative 'lib/interface'
require_relative 'lib/client'
require_relative 'lib/organization'
require_relative 'lib/repository'
require_relative 'lib/commit'


login = Interface::ask_login
pass = Interface::ask_password
month = Interface::ask("Informe o mes (numero) (em branco para mês atual, 0 para todos os meses)").to_i
month = month == 0 ? nil : month

client = Client.new(login,pass)

orgs = File.readlines('orgs').map { |l| l.chomp! }
orgs.map! { |o| Organization.new(o,client) }

author = login

aggregated_commits = []
commits_this_month = []

puts 'Carregando commits...'
orgs.each do |org|
   org.repositories(author).each do |r|
    commits = month.nil? ? r.commits : r.commits_by_month(month)
    puts r.name + ': ' + commits.count.to_s if commits.count > 0
    aggregated_commits += commits    
  end
end

aggregated_commits.sort!
commits_by_date = {}

aggregated_commits.each do |ac|
  date_string = ac.date.strftime("%d/%m/%Y")
  commits_by_date[date_string] = [] if commits_by_date[date_string].nil?
  commits_by_date[date_string] << ac
end

puts '========================='
puts 'por dia:'
commits_by_date.each_pair do |date,commits|
  repos = []
  commits.each do |commit|
    repos << commit.repository
  end
  repos.uniq!

  puts date + "\t" + commits.count.to_s + "\t(" + (repos.map { |x| x.name } * ' ') + ')'
end