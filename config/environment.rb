# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Costingtool::Application.initialize!

Costingtool::Application.config.lastRmasPoll = ''