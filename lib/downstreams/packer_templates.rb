require 'find'
require 'thread'
require 'yaml'

module Downstreams
  class PackerTemplates
    def self.load(cookbook_path, packer_templates_path)
      inst = new
      inst.load(cookbook_path, packer_templates_path)
      inst
    end

    def initialize
      @rec = {}
    end

    def each(&block)
      @rec.each(&block)
    end

    def load(cookbook_path, packer_templates_path)
      packer_templates(packer_templates_path).each do |filename|
        parsed = YAML.load_file(filename)
        Array(parsed['provisioners']).each do |provisioner|
          next unless provisioner['type'] =~ /chef/
          next if Array(provisioner.fetch('run_list', [])).empty?
          key = File.basename(filename, '.yml')
          @rec[key] = find_cookbooks(provisioner['run_list'], cookbook_path)
        end
      end
    end

    private

    def packer_templates(packer_templates_path)
      packer_templates_path.map do |packer_templates_dir|
        Dir.glob(File.join(packer_templates_dir, '*.yml')).select do |f|
          packer_template?(f)
        end
      end.flatten.compact.sort
    end

    def packer_template?(filename)
      parsed = YAML.load_file(filename)
      %w(variables builders provisioners).all? { |k| parsed.include?(k) }
    rescue => e
      $stderr.puts "ERROR: #{e}\n#{e.backtrace.join("\n")}"
      false
    end

    def find_cookbooks(run_list, cookbook_path)
      Array(run_list).map do |cb|
        find_dependency_cookbooks(
          cb.gsub(/^recipe\[/, '').delete(']'),
          cookbook_path
        )
      end.flatten.sort.uniq
    end

    def find_dependency_cookbooks(cookbook_name, cookbook_path)
      deps = [cookbook_name]
      sem = Mutex.new
      cookbook_path.each do |cookbooks_dir|
        recipes_dir = File.join(cookbooks_dir, cookbook_name, 'recipes')
        next unless File.exist?(recipes_dir)
        Dir.glob(File.join(recipes_dir, '*.rb')) do |recipe_rb|
          sem.synchronize do
            begin
              @included_recipes = []
              @node = {
                'travis_ci_standard' => {
                  'standalone' => false
                },
                'travis_packer_templates' => {
                  'env' => {
                    'PACKER_BUILDER_TYPE' => 'lilchef'
                  }
                },
                tmate_remote_tmux: {},
                tmate_proxy: {},
                'ec2_docker_worker' => {
                  'docker' => {
                    'languages' => []
                  }
                }
              }
              instance_eval(File.read(recipe_rb))
              deps += @included_recipes
            rescue => e
              $stderr.puts "ERROR:#{recipe_rb.sub("#{cookbooks_dir}/", '')}: #{e}"
            end
          end
        end
        @included_recipes = []
      end
      deps.compact.uniq
    end

    attr_reader :node

    include FakeRecipeMethods
  end
end
