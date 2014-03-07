module KnowsAboutDataDependencies
  ::TEST_CONFIG ||= {}

  def self.extended(base)
    base.instance_eval do
      path = TEST_CONFIG["data.yml"] || "config/data.yml"
      raise "The data dependencies file does not exist at #{path}" unless File.exist?(path)
      @data_dependencies = YAML.load_file(path)
    end
  end

  def data_for_a(object, which: nil, but_isnt: nil, instances: nil)
    raise ArgumentError, "Please specify a condition using `which:`" if which.nil?
    data = @data_dependencies[object.to_s][which] rescue nil

    if data.respond_to? :sample
      data.delete_if { |item| item == but_isnt } if but_isnt
      if instances
        pending "Test error: There are not enough examples defined for a #{object} which #{which}" unless data.size >= instances
        data = data.sample(instances)
      else
        data = data.sample
      end
    end

    pending "Test error: There is no data dependency defined for a #{object} which #{which}" unless data
    data
  end
end

World(KnowsAboutDataDependencies)