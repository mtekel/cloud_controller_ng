require 'vcap_request_id'
require 'cors'
require 'rack/cors'

module VCAP::CloudController
  class RackAppBuilder
    def build(config, request_metrics)
      token_decoder = VCAP::UaaTokenDecoder.new(config[:uaa])

      logger = access_log(config)

      Rails.application.initialize!

      Rack::Builder.new do
        # use Rack::Cors do
        #   allow do
        #     origins config[:allowed_cors_domains].map { |d| /^#{Regexp.quote(d).gsub('\*', '.*?')}$/ }
        #
        #     resource '*',
        #       methods:     [:get, :post, :put, :delete],
        #       headers:     :any,
        #       expose:      ['x-cf-warnings', 'x-app-staging-log', 'x-vcap-request-id', 'location', 'range'],
        #       max_age:     900,
        #       credentials: true,
        #       vary:        ['Origin']
        #   end
        # end
        use CloudFoundry::Middleware::Cors, config[:allowed_cors_domains].map { |d| /^#{Regexp.quote(d).gsub('\*', '.*?')}$/ }
        use CloudFoundry::Middleware::VcapRequestId
        use Rack::CommonLogger, logger if logger

        if config[:development_mode] && config[:newrelic_enabled]
          require 'new_relic/rack/developer_mode'
          use NewRelic::Rack::DeveloperMode
        end

        map '/' do
          run FrontController.new(config, token_decoder, request_metrics)
        end

        map '/v3' do
          run Rails.application.app
        end
      end
    end

    private

    def access_log(config)
      if !config[:nginx][:use_nginx] && config[:logging][:file]
        access_filename = File.join(File.dirname(config[:logging][:file]), 'cc.access.log')
        access_log ||= File.open(access_filename, 'a')
        access_log.sync = true
        return access_log
      end
    end
  end
end
