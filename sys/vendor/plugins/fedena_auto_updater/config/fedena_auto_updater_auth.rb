authorization do

  role :admin do
    has_permission_on [:fedena_auto_updater],
      :to => [
      :index,
      :pull_changes]
  end
end
