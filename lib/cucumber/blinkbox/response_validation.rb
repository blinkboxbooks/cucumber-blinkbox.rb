# encoding: utf-8
module KnowsAboutResponseValidation
  INFINITY = 1.0 / 0.0

  # Parses a string into a data if that's the specified date type. This is needed for interpreting JSON markup as
  # it doesn't have dates as a first-class concept so they should appear as specifically formatted strings.
  def parse_and_validate_date_if_necessary(value, type)
    # note: cannot use 'case type' as that expands to === which checks for instances of rather than type equality
    if type == Date
      expect(value).to match(/^\d{4}-\d{2}-\d{2}$/)
      Date.strptime(value, "%Y-%m-%d")
    elsif type == DateTime
      expect(value).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/)
      DateTime.strptime(value, "%Y-%m-%dT%H:%M:%SZ")
    else
      value
    end
  end

  def validate_attribute(data, name, options = {})
    type = options[:type]
    type = type.constantize if type.respond_to?(:constantize) # allows it to be passed in as a string or a constant
    expected_value = options[:is] || options[:value]
    expected_value = expected_value.to_type(type) if expected_value.is_a?(String) && !type.nil?
    expected_content = options[:contains]

    value = parse_and_validate_date_if_necessary(data.deep_key(name), type)

    begin
      expect(value).to_not be_nil
      expect(value).to be_a_kind_of(type) unless type.nil?
      expect(value).to eq(expected_value) unless expected_value.nil?
      expect(value).to match(/#{Regexp.escape(expected_content)}/) unless expected_content.nil?
      yield value if block_given?
    rescue => e
      message = "'#{name}' is invalid: #{e.message}"
      send((options[:warn_only] ? "puts" : "raise").to_sym, message)
    end
  end

  def validate_entity(data, type, options = {})
    validate_attribute(data, "type", type: String, warn_only: options[:warn_only].include?(:type)) { |value| expect(value).to eq("urn:blinkboxbooks:schema:#{type}") }
    validate_attribute(data, "guid", type: String, warn_only: options[:warn_only].include?(:guid)) { |value| expect(value).to start_with "urn:blinkboxbooks:id:#{type}:#{data["id"]}" }
  end

  def validate_link(data)
    validate_attribute(data, "rel", type: String) { |value| expect(value).to start_with "urn:blinkboxbooks:schema:" }
    validate_attribute(data, "href", type: String) { |value| expect(value).to_not be_empty } if data["href"]
    validate_attribute(data, "title", type: String) { |value| expect(value).to_not be_empty } if data["title"]
    validate_attribute(data, "text", type: String) { |value| expect(value).to_not be_empty } if data["text"]
  end

  def validate_links(data, *expected)
    validate_attribute(data, "links", type: Array)
    data["links"].each { |link_data| validate_link(link_data) }
    expected.each do |link_info|
      rel = link_info[:rel] || link_info[:relationship]
      rel = "urn:blinkboxbooks:schema:" << rel.tr(" ", "").downcase unless rel.start_with?("urn:")
      count = data["links"].select { |link| link["rel"] == rel }.count
      min = link_info[:min].to_i
      max = %w{∞ *}.include?(link_info[:max]) ? INFINITY : link_info[:min].to_i
      raise "Wrong number of #{rel} links: Expected #{min..max}, Actual: #{count}" unless count >= min && count <= max
    end
  end

  # Validates a list of items is in the standardised blinkbox books format.
  #
  # @param options [Hash] Options for the validation.
  # @option options [String] :item_type The (singular, snake cased) name of the items in the list, and the validation method (`validate_item_type`) that will be used to test them.
  # @option options [String] :list_type The (signular, snake cased) name of the list type to be validated. Corresponds to the schema urn of `urn:blinkboxbooks:schema:listtypelist` and will look for the method `validate_list_of_list_type`.
  # @option options [Integer] :min_count The minimum number of items there must be.
  # @option options [Integer] :max_count The maximum number of items there can be.
  # @option options [Integer] :count The exact number of items there must be. (Is overridden by min_ and max_count)
  # @option options [Integer] :offset The offset expected for the data (used for ensuring the `offset` value is correct)
  # @option options [Array<Symbol>] :warn_only Ask the validator to be lenient while testing the specified attributes (NB. Use snake_case)
  def validate_list(data, options = {})
    list_type = options[:list_type]
    item_type = options[:item_type]
    min_count = options[:min_count] || options[:count] || 0
    max_count = options[:max_count] || options[:count] || 1000000
    offset = options[:offset] || 0
    warn_only = options[:warn_only] || []

    # TODO: Should this be :list:#{list_type} rather than the list type before list?
    expected_type = "urn:blinkboxbooks:schema:#{(list_type || "").tr("_", "")}list"
    validate_attribute(data, "type",            type: String,  warn_only: warn_only.include?(:type))              { |value| expect(value).to eq(expected_type) }
    validate_attribute(data, "count",           type: Integer, warn_only: warn_only.include?(:count))             { |value| expect(min_count..max_count).to cover(value) }
    validate_attribute(data, "offset",          type: Integer, warn_only: warn_only.include?(:offset))            { |value| expect(value).to eq(offset) }
    validate_attribute(data, "numberOfResults", type: Integer, warn_only: warn_only.include?(:number_of_results)) { |value| expect(value).to be >= data["count"] }

    unless list_type.nil?
      further_validation = "validate_list_of_#{list_type}".to_sym
      send(further_validation, data) if respond_to?(further_validation)
    end

    if data["items"] || min_count > 0
      validate_attribute(data, "items", type: Array) do |value|
        if min_count == max_count
          expect(value.count).to eq(min_count)
        else
          expect(value.count).to be_between(min_count, max_count)
        end
      end
      unless item_type.nil?
        item_validation_method = "validate_#{item_type}".to_sym
        data["items"].each { |item| self.send(item_validation_method, item) }
      end
    end
  end

  def validate_list_order(data, order, descending)
    attribute_name = Blinkbox::Test::Api::Json.attr_name(order)
    attribute_values = data["items"].map.with_index do |item, index|
      value = item[attribute_name]
      expect(value).to_not be_nil, "'#{attribute_name}' is nil in item at index #{index}"
      if attribute_name =~ /date$/i
        DateTime.parse(value)
      else
        value
      end
    end
    expected_values = attribute_values.sort do |a, b|
      if a.respond_to?(:upcase)
        a.upcase <=> b.upcase # ordering of values should be case-insensitive
      else
        a <=> b
      end
    end
    expected_values.reverse! if descending
    expect(attribute_values).to eq(expected_values)
  end
end

World(KnowsAboutResponseValidation)