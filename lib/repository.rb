class Repository

  attr_reader :name, :commits

  def initialize(name,client,author)
    @name = name
    @client = client
    @author = author
  end

  def commits
    @commits ||= get_commits(@author)
  end

  def commits_by_month(month)
    @commits ||= get_commits(@author)
    @commits.keep_if { |c| c.date.month == month }
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