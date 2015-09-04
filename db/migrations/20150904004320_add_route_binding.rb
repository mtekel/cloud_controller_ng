Sequel.migration do
  change do
    create_table :route_service_binding do
      primary_key :id

      VCAP::Migration.timestamps(self, 's_i_d_clients')

      Integer :route_id, null: false
      foreign_key [:route_id], :route, name: :fk_route_service_bindings_route_id

      Integer :service_instance_id, null: false
      foreign_key [:service_instance_id], :service_instances, name: :fk_route_service_bindings_service_instance_id
    end
  end
end
