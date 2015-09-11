module VCAP::CloudController
  class RouteBinding < Sequel::Model

    plugin :after_initialize

    many_to_one :route
    many_to_one :service_instance

    delegate :service, :service_plan, :client, to: :service_instance

    def after_initialize
      super
      self.guid ||= SecureRandom.uuid
    end

    def validate
      validates_presence :service_instance
      validate_presence :route
      validate_service_instance
    end

    def required_parameters
      { route: route.uri }
    end

    def validate_service_instance
      return unless service_instance && route

      unless service_instance.service.requires.include? 'route_forwarding'
        errors.add(:service_instance, :route_binding_not_allowed)
      end

      unless service_instance.space == route.space
        errors.add(:service_instance, :space_mismatch)
      end
    end
  end
end
