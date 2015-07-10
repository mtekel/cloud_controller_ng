require 'spec_helper'

describe MaxAppInstancesPolicy do
  let(:app) { VCAP::CloudController::AppFactory.make(instances: 1, state: 'STARTED') }
  let(:quota_definition) { double(app_instance_limit: 4) }
  let(:error_name) { :app_instance_limit_error }

  subject(:validator) { MaxAppInstancesPolicy.new(app, quota_definition, error_name) }

  it 'gives error when number of instances exceeds instance limit' do
    app.instances = 5
    expect(validator).to validate_with_error(app, :app_instance_limit, error_name)
  end

  it 'does not give error when number of instances equals instance limit' do
    app.instances = 4
    expect(validator).to validate_without_error(app)
  end

  context 'when quota definition is null' do
    let(:quota_definition) { nil }

    it 'does not give error ' do
      app.instances = 150
      expect(validator).to validate_without_error(app)
    end
  end

  context 'when app instance limit is -1' do
    let(:quota_definition) { double(app_instance_limit: -1) }

    it 'does not give error' do
      app.instances = 150
      expect(validator).to validate_without_error(app)
    end
  end

  it 'does not register error when not performing a scaling operation' do
    app.instances = 200
    app.state = 'STOPPED'
    expect(validator).to validate_without_error(app)
  end
end

