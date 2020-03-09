# frozen_string_literal: true

require 'net/http'
require 'ipaddr'

RSpec::Matchers.define :be_ip_address do
  match do |actual|
    begin
      IPAddr.new(actual)
      true
    rescue IPAddr::Error
      false
    end
  end
end

RSpec::Matchers.alias_matcher :an_ip_address_string, :be_ip_address

RSpec.describe 'https://api.github.com/meta', :vcr do
  subject(:response) do
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.get(uri.path)
  end

  let(:uri) do
    URI.parse('https://api.github.com/meta')
  end

  it 'returns valid JSON response specified in https://developer.github.com/v3/meta/' do
    expect(response.body).to be_json matching(
      verifiable_password_authentication: a_value(true).or(a_value(false)),
      github_services_sha: a_string_matching(/\A[0-9a-f]{40}\z/),
      hooks: all(an_ip_address_string),
      git: all(an_ip_address_string),
      pages: all(an_ip_address_string),
      importer: all(an_ip_address_string)
    )
  end
end
