# frozen_string_literal: true

module HttpHelper
  def stub_http_error(verb, path, body: '{"error":"error"}', status: 400)
    stub_http(verb, path, body: body, status: status)
    body
  end

  def stub_http(verb, path, body: '{}', status: 200)
    stub_request(verb, /#{path.split(':').last}/).to_return(status: status, body: body)
  end
end
