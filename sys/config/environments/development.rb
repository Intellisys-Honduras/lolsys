# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.reload_plugins = true

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  :enable_starttls_auto => true,
  :address => 'smtp.gmail.com',
  :port => 587,
  :authentication => :plain,
  :domain => 'gmail.com',
  :user_name => 'intellisys.honduras@gmail.com',
  :password => 'cxzdsaewq'
}



#config.after_initialize do
#  Bullet.enable = true
#  Bullet::Association.alert = true
#  Bullet::Association.bullet_logger = true
#  Bullet::Association.console = true
#  Bullet::Association.growl = true
#  Bullet::Association.rails_logger = true
#  begin
#    require 'ruby-growl'
#    Bullet.growl = true
#  rescue MissingSourceFile
#  end
#end