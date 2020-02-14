# frozen_string_literal: true

default_jvm = nil
default_java_version = node['travis_java']['default_version']

unless default_java_version.to_s.empty?
  default_jvm = node['travis_java'][default_java_version]['jvm_name']
end

directory ::File.dirname(node['travis_java']['jdk_switcher_path']) do
    owner node['travis_build_environment']['user']
    group node['travis_build_environment']['group']
    mode 0o755
    recursive true
end
  
remote_file node['travis_java']['jdk_switcher_path'] do
    source node['travis_java']['jdk_switcher_url']
    owner node['travis_build_environment']['user']
    group node['travis_build_environment']['group']
    mode 0o644
end

include_recipe 'travis_build_environment::bash_profile_d'

template ::File.join(
  node['travis_build_environment']['home'],
  '.bash_profile.d/travis-java.bash'
) do
  source 'travis-java.bash.erb'
  owner node['travis_build_environment']['user']
  group node['travis_build_environment']['group']
  mode 0o755
  variables(
    jdk_switcher_default: default_java_version,
    jdk_switcher_path: node['travis_java']['jdk_switcher_path'],
    jvm_base_dir: node['travis_java']['jvm_base_dir'],
    jvm_name: default_jvm
  )
end

execute 'append_jdk_switcher_to_bashrc' do
    command "echo 'source #{node['travis_build_environment']['home']}/.bash_profile.d/travis-java.bash' >> #{node['travis_build_environment']['home']}/.bashrc"
end
