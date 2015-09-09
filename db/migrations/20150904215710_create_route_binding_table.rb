Sequel.migration do
  change do
    create_table :route_binding do
      VCAP::Migration.common(self)

      Integer :route_id, null: false
      foreign_key [:route_id], :route, name: :fk_route_bindings_route_id

      Integer :service_instance_id, null: false
      foreign_key [:service_instance_id], :service_instances, name: :fk_route_bindings_service_instance_id
    end
  end
end
