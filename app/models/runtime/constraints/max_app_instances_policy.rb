class MaxAppInstancesPolicy
  def initialize(app, quota_definition, error_name)
    @app = app
    @quota_definition = quota_definition
    @error_name = error_name
    @errors = app.errors
  end

  def validate
    return unless @quota_definition
    return unless @app.scaling_operation?
    return if @quota_definition.app_instance_limit == -1

    if(@app.instances > @quota_definition.app_instance_limit)
      @errors.add(:app_instance_limit, @error_name)
    end
  end
end
