ActionController::Routing::Routes.draw do |map|
  map.auto_updater "auto_updater", :controller=>"fedena_auto_updater" , :action=>"index"
  map.build_trigger_fedena_auto_updater "auto_updater/build_trigger", :controller=>"fedena_auto_updater" , :action=>"build_trigger"
  map.resources :fedena_auto_updater,:collection=>{
    :pull_changes=>:post,
    :check_updates=>:post,
    :setup_git=>:post,
    :build_trigger => :post
  }
end

