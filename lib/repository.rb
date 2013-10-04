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
    commits = []
    response = @client.request("https://api.github.com/repos/#{@name}/commits?author=#{author}&per_page=100")
    response.each do |rep|
      commits << Commit.new(rep,self)     
    end
    commits
  end
end