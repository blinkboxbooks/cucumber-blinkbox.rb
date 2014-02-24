module KnowsAboutDataDependencies
  ::TEST_CONFIG ||= {}

  def self.extended(base)
    base.instance_eval do
      path = TEST_CONFIG["data.yml"] || "config/data.yml"
      raise "The data dependencies file does not exist at #{path}" unless File.exist?(path)
      @@data_dependencies = YAML.load_file(path)
    end
  end

  def data_for_a(object, which: "is currently available for purchase", but_isnt: nil)
    data = @@data_dependencies[object.to_s][which]

    if data.respond_to? :sample
      data.delete_if { |item| item == but_isnt } if but_isnt
      data = data.sample
    end

    raise unless data
    data
  rescue
    pending "Test error: There is no data dependency defined for a #{object} which #{which}"
  end
end

World(KnowsAboutDataDependencies)