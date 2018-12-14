# frozen_string_literal: true

# Cookbook Name:: travis_packer_templates
# Recipe:: job_board
#
# Copyright 2018, Travis CI GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

template '/etc/profile.d/Z90-travis-packer-templates.sh' do
  source 'etc-profile-d-travis-packer-templates.sh.erb'
  cookbook 'travis_packer_templates'
  owner 'root'
  group 'root'
  mode 0o755
  variables(
    lazy do
      {
        features: node['travis_packer_templates']['job_board']['features'],
        languages: node['travis_packer_templates']['job_board']['languages'],
        stack: node['travis_packer_templates']['job_board']['stack'],
        timestamp: ENV['travis_packer_templates_init_time']
      }
    end
  )
end

ruby_block 'write node attributes' do
  block(lazy) do
    travis_packer_templates.write_node_attributes_yml
  end
  action :nothing
end

log 'trigger writing node attributes' do
  notifies :run, 'ruby_block[write node attributes]'
end

ruby_block 'write job-board registration bits' do
  block(lazy) do
    travis_packer_templates.write_job_board_register_yml
  end
end
