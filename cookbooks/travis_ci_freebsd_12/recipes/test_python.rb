message = node.has_key?(:message) ? node[:message] : "Test Python"

execute "echo message" do
  command "echo '#{message}'"
  action :run
end