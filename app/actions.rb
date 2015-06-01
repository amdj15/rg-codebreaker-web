class Actions < Ctrl
  @@current_games = {}

  interceptors :access, [:guess, :save, :load, :hint]

  def main req
    path = Dir.pwd + '/tpls/index.html.erb'
    ERB.new(File.read(path)).result(binding)
  end

  def start req
    @@current_games.delete_if do |key, value|
      (value[:game].won? || value[:game].lost?) || (value[:started_at] + 1800) < Time.new.to_i
    end

    token = generate_token

    @@current_games[token] = {
      :game => Codebreaker::Game.new(5),
      :history => [],
      :started_at => Time.new.to_i,
      :hints => []
    }

    game_resource(token).to_json
  end

  def load req
    game_resource(req.params["token"]).to_json
  end

  def guess req, assumption
    begin
      init_assemption = assumption.clone
      result = @@current_games[req.params["token"]][:game].guess(assumption)

      @@current_games[req.params["token"]][:history] << {
          :assumption => init_assemption,
          :result => result,
      }

      game_resource(req.params["token"]).to_json
    rescue Exception => e
      [{:error => e}.to_json, 400]
    end
  end

  def save req, name
    @@current_games[req.params["token"]][:game].save name
  end

  def hint req
    hint = @@current_games[req.params["token"]][:game].hint
    @@current_games[req.params["token"]][:hints] << hint if hint != nil

    game_resource(req.params["token"]).to_json
  end

  def results req
    Codebreaker::Game.load('data').to_json
  end

  private
  def generate_token length = 64
    selection = [('a'..'z'), ('A'..'Z'), (1..9), ["_"]].map { |i| i.to_a }.flatten
    length.times.map { selection[rand(selection.length)] }.join
  end

  def access req
    return ["Bad request: token missed", 400] unless req.params["token"]
    return ["Bad request: invalid token", 400] unless @@current_games[req.params["token"]]
  end

  def game_resource token
    {
      :history => @@current_games[token][:history],
      :hints =>  @@current_games[token][:hints],
      :hints_available => @@current_games[token][:game].hints?,
      :gameover => (@@current_games[token][:game].won? || @@current_games[token][:game].lost?),
      :won => @@current_games[token][:game].won?,
      :token => token,
    }
  end
end