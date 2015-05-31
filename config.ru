require './app/main'
use Rack::Static, :urls => ['/css', '/fonts', '/js', '/templates', 'ico'], :root => "public"

run App