#
# Cookbook Name:: gitorious
# Recipe:: default
#
# Copyright 2010, Example Com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This is a transliteration from http://cjohansen.no/en/ruby/setting_up_gitorious_on_your_own_server#comments



packages = """
git-core 
git-svn 
apg 
build-essential 
libpcre3 
libpcre3-dev 
sendmail
make
zlibg
zlibg-dev
ssh
ruby1.8
libbluecloth-ruby
libopenssl-ruby1.8
ruby1.8-dev
ri
rdoc
irb
rubygems
libonig-dev
libyaml-dev
geoip-bin
libgeoip-dev
libgeoip1
mysql-client-5.0
mysql-server-5.0
libmysqlclient15-dev
uuid
uuid-dev
openjdk-6-jre
""".split

gem_package "rubygems-update"

# This will install the latest rubygems even on older versions
# of ubuntu
execute "update ruby gems to latest " do
  command "/var/lib/gems/1.8/bin/update_rubygems"
end

packages.each do |p|
  package p
end

link "/usr/bin/ruby1.8" do
  to "/usr/bin/ruby"
end

directory "/tmp/gsrc"

remote_file "/tmp/gsrc/ruby-enterprise_1.8.6-20090610-i386.deb" do
  source "http://rubyforge.org/frs/download.php/58679/ruby-enterprise_1.8.6-20090610_i386.deb"
end

bash "install ruby-enterprise" do
  cwd "/tmp/gsrc"
  code <<-EOF
  sudo dpkg -i ruby-enterprise_1.8.6-20090610-i386.deb"
  EOF
end

template "/etc/profile.d/gitorious.sh" do
  source "gitorious-profile.sh.erb"
end

template "/etc/ld.so.conf.d/gitorious.conf" do
  source "gitorious-ld.so.conf.erb"
end

bash "ldconfig" do
  code<<-EOF
  source "/etc/profile"
  ldconfig
  EOF
end

gem_package "mysql"

directory "/tmp/sphinxsrc"

bash "install sphinx" do
  cwd "/tmp/sphixsrc"

  code<<-EOF
  wget http://www.sphinxsearch.com/downloads/sphinx-0.9.8.tar.gz
  tar xvfz sphinx-0.9.8.tar.gz
  cd sphinx-0.9.8
  ./configure
  make && sudo make install
  sudo gem install --no-ri --no-rdoc ultrasphinx
  EOF

end

directory "/tmp/amqsrc"


bash "install activeMQ" do
  cwd "/tmp/amqsrc"
  code<<-EOF
  wget http://www.powertech.no/apache/dist/activemq/apache-activemq/5.2.0/apache-activemq-5.2.0-bin.tar.gz
  tar xzvf apache-activemq-5.2.0-bin.tar.gz  -C /usr/local/
  sh -c 'echo "export ACTIVEMQ_HOME=/usr/local/apache-activemq-5.2.0" >> /etc/activemq.conf'
  sh -c 'echo "export JAVA_HOME=/usr/" >> /etc/activemq.conf'
  adduser --system --no-create-home activemq
  chown -R activemq /usr/local/apache-activemq-5.2.0/data
  EOF
end
