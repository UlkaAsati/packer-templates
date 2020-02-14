# frozen_string_literal: true

pyenv_installer_path = ::File.join(
    Chef::Config[:file_cache_path], 'pyenv-installer'
)

remote_file pyenv_installer_path do
    source node['travis_python']['pyenv_install_url']
    owner node['travis_build_environment']['user']
    group node['travis_build_environment']['group']
    mode 0o755
end

bash 'install_pyenv' do
    code "#{pyenv_installer_path}"
    user node['travis_build_environment']['user']
    group node['travis_build_environment']['group']
    environment('HOME' => node['travis_build_environment']['home'])
    retries 2
    retry_delay 30
end

ENV['PATH'] = "#{node['travis_build_environment']['home']}/.pyenv/bin:#{ENV['PATH']}"
bash "echo 'export PATH=#{node['travis_build_environment']['home']}/.pyenv/bin:#{ENV['PATH']}' >> #{node['travis_build_environment']['home']}/.bashrc"

pyenv_versions = %w[
    3.6.10
    3.7.6
    3.8.1
    pypy-5.7.1
    pypy3.6-7.3.0
]

pyenv_versions.each do |p|
    execute "pyenv_install_#{p}" do
        command "pyenv install #{p}"
    end
end
