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