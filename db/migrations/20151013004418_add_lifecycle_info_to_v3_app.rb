Sequel.migration do
  change do
    up do
      add_column :apps_v3, :stack_name, String, text: true, null: true
      add_column :apps_v3, :lifecycle, String, text: true, null: true
    end

    down do
      alter_table(:v3_droplets) do
        drop_column :stack_name
        drop_column :lifecycle
      end
    end
  end
end
