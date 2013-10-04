require 'json'
require 'httparty'


require_relative 'lib/client'
require_relative 'lib/organization'
require_relative 'lib/repository'
require_relative 'lib/commit'

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

orgs = [Organization.new('innvent',client), Organization.new('elogroup',client)]

author = login
aggregated_commits = []

puts 'By repository total:'
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
