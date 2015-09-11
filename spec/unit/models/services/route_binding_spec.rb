require 'spec_helper'

module VCAP::CloudController
  describe VCAP::CloudController::RouteBinding, type: :model do
    let(:binding) { RouteBinding.new }
    it { is_expected.to have_timestamp_columns }

    describe '#new' do
      it 'has a guid when constructed' do
        expect(binding.guid).to be
      end
    end

    describe 'Associations' do
      it { is_expected.to have_associated :route }
      it { is_expected.to have_associated :service_instance }
    end

    describe 'Validations' do
      it 'must have a service instance' do
        binding.route = Route.make
        binding.valid?
        expect(binding.errors[:service_instance]).to eq [:presence]
      end

      it 'must have a route' do
        binding.service_instance = ManagedServiceInstance.make
        binding.valid?
        expect(binding.errors[:route]).to eq [:presence]
      end

      it 'requires a service instance to have route_forwarding enabled' do
        service_instance = ManagedServiceInstance.make
        binding.service_instance = service_instance

        expect {
          binding.save
        }.to raise_error Sequel::ValidationFailed, 'service_instance does not allow route binding'
      end

      it 'requires a service instance and route be in the same space' do
        space = Space.make
        other_space = Space.make

        service_instance = ManagedServiceInstance.make(:routing, space: space)
        route = Route.make space: other_space

        binding.service_instance = service_instance
        binding.route = route

        expect {
          binding.save
        }.to raise_error Sequel::ValidationFailed, 'service_instance is not in the same space as the route'
      end
    end
  end
end
