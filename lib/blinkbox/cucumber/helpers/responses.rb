require "http_capture"

module KnowsAboutApiResponses
  # Parses response data that is expected to be in JSON format.
  #
  # @return [Hash] The response data.
  def parse_response_data
    expect(HttpCapture::RESPONSES.last["Content-Type"]).to match(%r{^application/vnd.blinkboxbooks.data.v1\+json;?})
    begin
      @response_data = JSON.load(HttpCapture::RESPONSES.last.body)
    rescue => e
      raise "The response is not valid JSON: #{e.message}"
    end
  end
end

World(KnowsAboutApiResponses)