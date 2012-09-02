namespace :fedena_auto_updater do
  desc "Install Fedena Auto Updater Module"
  task :install do
    require "#{File.dirname(__FILE__)}/../lib/fedena_tracker.rb"
    FedenaTracker.new.track_installation
    system "rsync --exclude=.svn -ruv vendor/plugins/fedena_auto_updater/public ."
  end
end
