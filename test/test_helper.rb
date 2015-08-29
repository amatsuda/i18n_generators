$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rails'
require 'rails/generators'
require 'test/unit'
require 'test/unit/rr'

Rails.logger ||= Logger.new STDOUT
