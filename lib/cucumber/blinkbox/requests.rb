module KnowsAboutApiRequests
  CONTENT_TYPE = "application/vnd.blinkboxbooks.data.v1+json"
  
  def http_client
    @http ||= HTTPClient.new(TEST_CONFIG["proxy"])
    @http.debug_dev = STDOUT if TEST_CONFIG["debug"]
    #@http.reset_all
    @http
  end

  def query
    @query ||= {}
  end

  def request_headers(header = {})
    @request_headers ||= {
        "Accept" => CONTENT_TYPE
    }
    if @access_token
      @request_headers["Authorization"] = "Bearer #{@access_token}" 
    else
      @request_headers.delete("Authorization")
    end
    @request_headers.merge!(header)
    @request_headers
  end

  def set_query_param(name, value)
    name = name.camel_case
    value = is_enum_param(name) ? value.snake_case(:upper) : value
    current_value = query[name]
    if current_value.nil?
      query[name] = value
    elsif current_value.is_a?(Array)
      query[name] << value
    else
      query[name] = [current_value, value]
    end
  end

  def qualified_uri(server, path)
    uri = test_env.servers[server.to_sym]
    raise "Test Error: #{server} doesn't appear to be defined in the environments.yml" if uri.nil?
    path = path[1..-1] if path.start_with?("/")
    URI.join(uri.to_s, path)
  end

  # request methods

  def http_get(server, path, header = {})
    uri = qualified_uri(server, path)
    params = query if query.count > 0
    @response = http_client.get(uri, query: params, header: request_headers(header), follow_redirect: true)
  end

  def http_post(server, path, body = {}, header = {})
    uri = qualified_uri(server, path)
    @response = http_client.post(uri, body: format_body(body), header: request_headers(header.merge({"Content-Type" => CONTENT_TYPE})))
  end

  def http_put(server, path, body = {}, header = {})
    uri = qualified_uri(server, path)
    @response = http_client.put(uri, body: format_body(body), header: request_headers(header.merge({"Content-Type" => CONTENT_TYPE})))
  end

  def http_delete(server, path, header = {})
    uri = qualified_uri(server, path)
    params = query if query.count > 0
    @response = http_client.delete(uri, query: params, header: request_headers(header))
  end

  private

  def format_body(body)
    body.is_a?(Hash) ? JSON.dump(body) : body
  end

  # So that we don't have to put enum parameters in the Gherkin in SCREAMING_SNAKE_CASE this heuristic identifies
  # enum parameters so that we can transform them, meaning an enum value like PURCHASE_DATE can be written in the
  # Gherkin as "purchase date" but still be sent correctly. This heuristic will need updating over time.
  def is_enum_param(name)
    ["bookmarkType", "order", "role"].include?(name)
  end
end

World(KnowsAboutApiRequests)