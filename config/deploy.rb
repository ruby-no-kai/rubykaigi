# -*- coding: utf-8 -*-
set :stages, %w(staging production)
set :default_stage, "staging"
set :application, "rubykaigi"
set :repository,  "git://github.com/ruby-no-kai/rubykaigi.git"
set :branch, "production"
set :appdir, "railsapp"
set :port, 2022
require "capistrano/ext/multistage"

set(:deploy_to){ "/home/#{application}/#{appdir}" }
set :ssh_options, { :forward_agent => true }

set :scm, :git
set :git_shallow_clone, 1

set :use_sudo, false
set :runner, "rubykaigi"
ssh_options[:username] = application

set :rake, "bundle exec rake"

#set :wenever_command, 'bundle exec whenever'
#set(:whenever_environment) { fetch(:stage, 'staging') }
#require 'whenever/capistrano'

def setup_shared(dir, path)
  src = "#{shared_path}/#{dir}/#{path}"
  dest = "#{latest_release}/#{dir}/#{path}"
  run "! test -e #{dest} && ln -s #{src} #{dest}"
end

def setup_shared_config(path)
  setup_shared("config", path)
end

namespace :deploy do
  task :start, :roles => :app do
  end

  desc "Restart Passenger"
  task :restart do
    run "touch #{latest_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
  end

  namespace :web do
    desc "maintenance variable: REASON,UNTIL"
    task :disable, :roles => :web, :except => { :no_release => true } do
      require 'erb'
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }

      reason = ENV['REASON']
      deadline = ENV['UNTIL']

      template = File.read(File.join(File.dirname(__FILE__), 'templates', 'maintenance.html.erb'))
      result = ERB.new(template).result(binding)

      put result, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end
end

after("deploy:update_code") do
  setup_shared_config("database.yml")
  setup_shared_config("config.yml")
  stage = fetch(:stage, 'staging')
  run "ln -fs #{latest_release}/config/rubykaigi_template.pill #{latest_release}/config/#{stage}.pill"
end

after("deploy:symlink") do
  run "mkdir -p #{current_path}/public/tmp"
  setup_shared("public/tmp", "pamphlet-20090708.zip")
  setup_shared("public/2011", "rk11prospectus.pdf")
  setup_shared("public/2011", "RubyKaigi2011_FloorGuide.pdf")
  setup_shared("public/2011", "irc-in-rubykaigi.tar.gz")
  setup_shared("public/2011", "tweets-in-rubykaigi.tar.gz")
  setup_shared("certs","app_cert.pem")
  setup_shared("certs","app_key.pem")
  setup_shared("certs","paypal_cert_sandbox.pem")
  setup_shared("certs","paypal_cert_live.pem")
  setup_shared("vendor", "bundle")
  run "rm -rf #{shared_path}/tmp/rails-cache/*"
end

namespace :bundler do
  task :bundle do
    run("cd #{latest_release} && bundle install #{shared_path}/vendor/bundle --deployment --without development test cucumber")
  end
end

namespace :bluepill do
  desc "take the bluepill"
  task :take do
    stage = fetch(:stage, 'staging')
    run "/usr/local/bin/bluepill --no-privileged --base-dir #{current_path}/tmp load #{current_path}/config/#{stage}.pill"
  end
end

namespace :delayed_job do
  desc "restart delayed_job"
  task :restart do
    run "/usr/local/bin/bluepill --no-privileged --base-dir #{current_path}/tmp #{fetch(:stage, 'staging')} restart delayed_job"
  end
end

before 'deploy:restart', 'bluepill:take'
after 'deploy', 'delayed_job:restart'

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
require 'capistrano-notification'

notification.irc do |irc|
  irc.host    'chat.freenode.net'
  irc.channel '#rubykaigi.org'
  irc.message { "#{local_user} deployed #{application} to #{fetch(:stage, 'staging')}" }
end

after 'deploy:finalize_update', 'bundler:bundle'
after 'deploy:migrations', 'god:reboot'

namespace 'db' do
  desc "run RAILS_ENV=#{fetch(:stage, 'staging')} bundle exec rake db:seed_2010 on rubykaigi.org. sweet :)"
  task 'seed_2010', :roles => :app do
    stage = fetch(:stage, 'staging')
    run("cd #{current_path} && RAILS_ENV=#{stage} bundle exec rake db:seed_2010")
  end
end
before 'db:seed_2010', 'deploy'
before 'db:seed_2010', 'deploy:web:disable'
after 'db:seed_2010', 'deploy:web:enable'

namespace 'ticket' do
  desc "ticket summary report"
  task "summary", :roles => :app do
    ticket_summary = capture("cd #{current_path} && RAILS_ENV=#{fetch(:stage, 'staging')} bundle exec rails runner script/ticket_summary")
    puts ticket_summary
  end
end
