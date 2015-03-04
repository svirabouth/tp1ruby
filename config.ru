# config.ru
require './chat'

require 'bundler'

Bundler.require

use Rack::Session::Cookie, :expire_after => 2592000 # In seconds
run MyApp
