#
# Cookbook Name:: LAMPDeployCookbook
# Recipe:: docker_install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

directory '/tmp/htdocs' do
    action :create
end

template '/tmp/htdocs/index.html' do
  source 'index.html.erb'
end

template '/tmp/htdocs/index.php' do
  source 'index.php.erb'
end

docker_service 'default' do
  action [:create, :start]
end

docker_image 'mysql' do
  action :pull_if_missing
end

# Pull latest image
docker_image 'httpd' do
  tag 'latest'
  action :pull_if_missing
  notifies :redeploy, 'docker_container[my_httpd]'
end

# Run container exposing ports
docker_container 'my_httpd' do
  repo 'httpd'
  tag 'latest'
  port '8080:80'
  volumes [ '/tmp/htdocs:/usr/local/apache2/htdocs' ]
end

# Pull latest image
docker_image 'php' do
  tag '7.0-apache'
  action :pull_if_missing
  notifies :redeploy, 'docker_container[my_php]'
end

# Run container exposing ports
docker_container 'my_php' do
  repo 'php'
  tag '7.0-apache'
  port '80:80'
  volumes [ '/tmp/htdocs:/var/www/html' ]
end
