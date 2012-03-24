
# Lamantanimation deployment with capistrano

require 'capistrano/ext/multistage'
set :stages, %w[staging production]
set :default_stage, 'staging'
set :node_env, 'staging'

set :application, "Lamantanimation"
set :node_file, "hello.js"
set :host, "tappe.lu"
set :repository, "git@github.com:PKJedi/Lamantanimation.git"
set :user, "pkjedi"
set :admin_runner, 'pkjedi'

set :scm, :git
set :deploy_via, :remote_cache
role :app, host
set :deploy_to, "/var/www/node/#{application}/#{node_env}"
set :use_sudo, true
default_run_options[:pty] = true

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} start #{application}_#{node_env}"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} stop #{application}_#{node_env}"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} restart #{application}_#{node_env} || sudo start #{application}_#{node_env}"
  end

  task :create_deploy_to_with_sudo, :roles => :app do
    run "#{sudo} mkdir -p #{deploy_to}"
    run "#{sudo} chown #{admin_runner}:users #{deploy_to}"
  end

  task :write_upstart_script, :roles => :app do
    upstart_script = <<-UPSTART
  description "#{application}"

  start on startup
  stop on shutdown

  script
      # We found $HOME is needed. Without it, we ran into problems
      export HOME="/home/#{admin_runner}"
      export NODE_ENV="#{node_env}"

      cd #{current_path}
      exec sudo -u #{admin_runner} sh -c "NODE_ENV=#{node_env} /usr/local/bin/node #{current_path}/#{node_file} #{application_port} >> #{shared_path}/log/#{node_env}.log 2>&1"
  end script
  respawn
UPSTART
  put upstart_script, "/tmp/#{application}_upstart.conf"
    run "#{sudo} mv /tmp/#{application}_upstart.conf /etc/init/#{application}_#{node_env}.conf"
  end

  task :npm_update, :roles => :app do
    run "cd #{release_path}; /usr/local/bin/npm install socket.io"
  end

end

before 'deploy:setup', 'deploy:create_deploy_to_with_sudo'
after 'deploy:setup', 'deploy:write_upstart_script'
after "deploy:finalize_update", "deploy:npm_update"
