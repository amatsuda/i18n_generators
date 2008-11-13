require 'fileutils'
# runs only when installed as a plugin
FileUtils.cp_r File.join(File.dirname(__FILE__), 'templates'), File.join(File.dirname(__FILE__), 'generators/i18n/')

