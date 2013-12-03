class Organization

  attr_reader :name, :repositories

  def initialize(name,client)
    @name = name
    @client = client
  end

  def repositories(author)
    @repositories ||= get_repos(author)
  end

  private
  def get_repos(author)
    repositories = []
    response = @client.request("https://api.github.com/orgs/#{@name}/repos")
    response.each do |r|
      repositories << Repository.new(r['full_name'],@client,author)
    end
    repositories
  end
end