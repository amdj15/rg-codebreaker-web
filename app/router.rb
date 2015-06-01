class Router
  @@routes = {
    '/game/start' =>  'start',
    '/game/guess/:assemption' => 'guess',
    '/game/save/:name' => 'save',
    '/game/load' => 'load',
    '/game/hint' => 'hint',
    '/results' => 'results',
    '/' => 'main'
  }

  def initialize
    @routes = []

    @@routes.each do |route, action|
      @routes << {
        pattern: Regexp.new('^' + route.gsub(/:\w+/, '([\w\-\.]+)') + '$'),
        action: action
      }
    end
  end

  def check path, req
    action = ""
    args = [req]

    @routes.each do |route|
      path.scan(route[:pattern]) do |match|
        action = route[:action]
        args = args.concat(match) if match.kind_of?(Array)
      end

      break if action.size > 0
    end

    [action, args]
  end
end