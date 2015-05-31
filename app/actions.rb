class Actions < Ctrl
  @@current_games = {}

  interceptors :access, [:guess, :save]

  def main req
    path = Dir.pwd + '/tpls/index.html.erb'
    ERB.new(File.read(path)).result(binding)
  end

  def start req
    token = generate_token
    @@current_games[token] = Codebreaker::Game.new 3

    {token: token}.to_json
  end

  def guess req, assumption
    begin
      init_assemption = assumption.clone

      response = {}
      response["result"] = @@current_games[req.params["token"]].guess(assumption)
      response["assumption"] = init_assemption

      response.to_json
    rescue Exception => e
      [{:error => e}.to_json, 400]
    end
  end

  def save req, name
    @@current_games[req.params["token"]].save name
  end

  def results req
    Codebreaker::Game.load('data').to_json
  end

  private
  def generate_token length = 64
    selection = [('a'..'z'), ('A'..'Z'), (1..9), ["_"]].map { |i| i.to_a }.flatten
    length.times.map { selection[rand(selection.length)] }.join

    "IjqrAulD3V4UMOK1I1kuj9H8EUvZYAel3DEHOIdCKI97Er7h2TCYcuzE8h1avmI8"
  end

  def access req
    return ["Bad request: token missed", 400] unless req.params["token"]
    return ["Bad request: invalid token", 400] unless @@current_games[req.params["token"]]
  end
end