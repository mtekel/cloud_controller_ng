Sequel.migration do
  up do
    alter_table(:v3_droplets) { add_foreign_key :stack_id, :stacks }
  end

  down do
    alter_table(:v3_droplets) { drop_foreign_key :stack_id }
  end
end
