class Commit

  attr_reader :author, :message, :date, :repository

  def initialize(data,repository)
    @repository = repository
    @author = data['commit']['author']['name']
    @message = data['commit']['message']
    @date = DateTime.rfc3339(data['commit']['author']['date'])
  end

  def <=>(other)
    @date <=> other.date
  end

end