require 'bundler'

Bundler.require(:default, :development)

require 'mongo_mapper'
require 'frisky'

Frisky.config_file "frisky.yml"