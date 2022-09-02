require "httparty"
require "json"
require "date"

module Services
  class Sessions
    include HTTParty
    base_uri "https://expensable-api.herokuapp.com/"
    def self.login(credentials)
      options = {
        body: credentials.to_json,
        headers: {
          "Content-Type": "application/json"
        }
      }
      response = post("/login", options)
      # HTTParty::ResponseError
      raise ResponseError.new(response) unless response.success?
      JSON.parse(response.body, symbolize_names: true)
    end
    def self.signup(credentials)
      options = {
        body: credentials.to_json,
        headers: {
          "Content-Type": "application/json"
        }
      }
      response = post("/signup", options)
      # HTTParty::ResponseError
      raise ResponseError.new(response) unless response.success?
      JSON.parse(response.body, symbolize_names: true)
    end
    def self.indexcategories(token)
      options = {
        headers: { Authorization: "Token token=#{token}" }
      }
      response = get("/categories", options)
      # HTTParty::ResponseError
      raise ResponseError.new(response) unless response.success?
      JSON.parse(response.body, symbolize_names: true)
    end
    def self.addto(token, id, transaction_data)
      options = {
        body: transaction_data.to_json,
        headers: {
          Authorization: "Token token=#{token}",
          "Content-Type": "application/json"
        }
      }
      response = post("/categories/#{id}/transactions", options)
      p response
      # HTTParty::ResponseError
      raise ResponseError.new(response) unless response.success?
      JSON.parse(response.body, symbolize_names: true)
    end
    def self.indextransactions(token, id)
      options = {
        headers: { Authorization: "Token token=#{token}" }
      }
      response = get("/categories/#{id}/transactions", options)
      # HTTParty::ResponseError
      raise ResponseError.new(response) unless response.success?
      JSON.parse(response.body, symbolize_names: true)
    end
    # transactions
    # /categories/67/transactions

  end
end



