require 'translator'
require 'rush'
require File.join(File.dirname(__FILE__), "lib", "fedena_auto_updater")

FedenaPlugin.register = {
  :name=>"fedena_auto_updater",
  :description=>"Fedena Auto Updater Module",
  :auth_file=>"config/fedena_auto_updater_auth.rb",
  :more_menu=>{:title=>"fedena_auto_updater_label",:controller=>"fedena_auto_updater",:action=>"index",:target_id=>"more-parent"}
}

Dir[File.join("#{File.dirname(__FILE__)}/config/locales/*.yml")].each do |locale|
  I18n.load_path.unshift(locale)
end
