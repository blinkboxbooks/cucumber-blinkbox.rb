require_relative "../../spec_helper"
require 'rspec'
require 'cucumber/blinkbox/requests'

# needed for String#camel_case
# (ought this be required by cucumber/blinkbox/requests ?)
require 'cucumber/helpers'

# needed for String#camelize
# (ought this be required by cucumber/helpers ?)
require 'active_support/core_ext/string'

describe "requests" do

    describe "setting query parameters" do

        before :each do
            @request = Object.new
            @request.extend(KnowsAboutApiRequests)
        end

        it "accepts a single value" do
            @request.set_query_param("foo", 1)
            @request.query["foo"].should eq(1)
        end

        it "accepts an array of values" do
            @request.set_query_param("foo", [1, 2])
            @request.query["foo"].should eq([1, 2])
        end

        it "accepts multiple single values" do
            @request.set_query_param("foo", 1)
            @request.set_query_param("foo", 2)
            @request.query["foo"].should eq([1, 2])
        end

        it "appends arrays to existing arrays" do
            @request.set_query_param("foo", [1, 2])
            @request.set_query_param("foo", [3, 4])
            @request.query["foo"].should eq([1, 2, 3, 4])
        end

        it "appends single values to existing arrays" do
            @request.set_query_param("foo", [1, 2])
            @request.set_query_param("foo", 3)
            @request.query["foo"].should eq([1, 2, 3])
        end

        it "appends arrays to existing values" do
            @request.set_query_param("foo", 1)
            @request.set_query_param("foo", [2, 3])
            @request.query["foo"].should eq([1, 2, 3])
        end
    end
end
