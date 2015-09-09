require 'spec_helper'

module VCAP::CloudController
  describe VCAP::CloudController::RouteBinding, type: :model do
    it { is_expected.to have_timestamp_columns }

    describe 'Associations' do
      it { is_expected.to have_associated :route, associated_instance: ->(binding) { Route.make(space: binding.space, domain: binding.domain) } }
      it { is_expected.to have_associated :service_instance, associated_instance: ->(binding) { ServiceInstance.make(space: binding.space) } }
    end
  end
end
