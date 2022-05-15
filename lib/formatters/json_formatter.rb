# frozen_string_literal: true

class JsonFormatter < ActiveSupport::Logger::SimpleFormatter
  def call(severity, timestamp, _progname, message)
    "#{{
      request_id:   Thread.current[:request_id].presence || 'n/a',
      timestamp:    timestamp,
      log_level:    severity,
      service_name: Rails.application.class.module_parent_name,
      host_name:    Socket.gethostname,
      message:      message
    }.to_json}\n"
  end
end
