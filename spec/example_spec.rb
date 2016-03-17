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
      hooks: all(be_ip_address),
      git: all(be_ip_address),
      pages: all(be_ip_address),
      importer: all(be_ip_address)
    )
  end
end
