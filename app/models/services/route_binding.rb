module VCAP::CloudController
  class RouteBinding < Sequel::Model

    one_to_one :route
    many_to_one :service_instance

    export_attributes :route_guid, :service_instance_guid

    import_attributes :route_guid, :service_instance_guid

    delegate :client, :service, :service_plan,
      to: :service_instance

    delegate :space, :domain,
      to: :route

    plugin :after_initialize

    def validate
      validates_presence :route
      validates_presence :service_instance
      validates_unique [:route_id, :service_instance_id]

      validate_cannot_change_binding
    end

    def validate_cannot_change_binding
      return if new?

      route_change = column_change(:route_id)
      errors.add(:route, :invalid_relation) if route_change && route_change[0] != route_change[1]

      service_change = column_change(:service_instance_id)
      errors.add(:service_instance, :invalid_relation) if service_change && service_change[0] != service_change[1]
    end

    def required_parameters
      { route_guid: route_guid, service_instance_guid: service_instance_guid }
    end

    def after_initialize
      super
      self.guid ||= SecureRandom.uuid
    end

    def self.user_visibility_filter(user)
      { service_instance: ServiceInstance.user_visible(user) }
    end

    def logger
      @logger ||= Steno.logger('cc.models.route_binding')
    end

    private

    def safe_unbind
      client.unbind(self)
    rescue => unbind_e
      logger.error "Unable to unbind #{self}: #{unbind_e}"
    end
  end
end
