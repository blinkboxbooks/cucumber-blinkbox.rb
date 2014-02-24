module KnowsAboutTheEnvironment
  ::TEST_CONFIG ||= {}

  class EnvStruct
    def initialize(env)
      @env = env
    end
    def [](key)
      value = @env[key.to_s]
      value.is_a?(Hash) ? EnvStruct.new(value) : value
    end
    def method_missing(name, *args)
      key = name.to_s.tr("_", " ").downcase
      self[key]
    end
    def inspect
      @env.inspect
    end
  end

  def self.extended(base)
    base.instance_eval do
      path = TEST_CONFIG["environments.yml"] || "config/environments.yml"
      raise "The environments file does not exist at #{path}" unless File.exist?(path)
      env = YAML.load_file(path)[TEST_CONFIG["server"].downcase]
      raise "Environment '#{TEST_CONFIG["server"]}' is not defined in environments.yml" if env.nil?
      @test_env =  EnvStruct.new(env)
    end
  end

  def test_env
    @test_env
  end

  # legacy - use test_env.servers
  def servers
    @servers ||= test_env.servers
  end
end
World(KnowsAboutTheEnvironment)