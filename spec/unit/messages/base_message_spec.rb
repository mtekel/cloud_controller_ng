require 'spec_helper'
require 'messages/base_message'

module VCAP::CloudController
  describe BaseMessage do
    describe '#requested?' do
      it 'returns true if the key was requested, false otherwise' do
        message = BaseMessage.new({ requested: 'thing' })

        expect(message.requested?(:requested)).to be_truthy
        expect(message.requested?(:notrequested)).to be_falsey
      end
    end

    describe 'additional keys validation' do
      class AdditionalKeysMessage < VCAP::CloudController::BaseMessage
        validates_with NoAdditionalKeysValidator

        attr_accessor :allowed

        def allowed_keys
          [:allowed]
        end
      end

      it 'is valid with an allowed message' do
        message = AdditionalKeysMessage.new({ allowed: 'something' })

        expect(message).to be_valid
      end

      it 'is NOT valid with not allowed keys in the message' do
        message = AdditionalKeysMessage.new({ notallowed: 'something', extra: 'stuff' })

        expect(message).to be_invalid
        expect(message.errors.full_messages[0]).to include("Unknown field(s): 'notallowed', 'extra'")
      end
    end

    describe 'guid validation' do
      class GuidMessage < VCAP::CloudController::BaseMessage
        attr_accessor :guid
        validates :guid, guid: true

        def allowed_keys
          [:guid]
        end
      end

      context 'when guid is not a string' do
        let(:params) { { guid: 4 } }

        it 'is not valid' do
          message = GuidMessage.new(params)

          expect(message).not_to be_valid
          expect(message.errors[:guid]).to include('must be a string')
        end
      end

      context 'when guid is nil' do
        let(:params) { { guid: 4 } }

        it 'is not valid' do
          message = GuidMessage.new(params)

          expect(message).not_to be_valid
          expect(message.errors[:guid]).to include('must be a string')
        end
      end

      context 'when guid is too long' do
        let(:params) { { guid: 'a' * 201 } }

        it 'is not valid' do
          message = GuidMessage.new(params)

          expect(message).not_to be_valid
          expect(message.errors[:guid]).to include('must be between 1 and 200 characters')
        end
      end

      context 'when guid is empty' do
        let(:params) { { guid: '' } }

        it 'is not valid' do
          message = GuidMessage.new(params)

          expect(message).not_to be_valid
          expect(message.errors[:guid]).to include('must be between 1 and 200 characters')
        end
      end
    end

    describe 'relationship validation' do
      class RelationshipMessage  < VCAP::CloudController::BaseMessage
        attr_accessor :relationships
        def allowed_keys
          [:relationships]
        end
        validates_with RelationshipValidator

        class Relationships < VCAP::CloudController::BaseMessage
          attr_accessor :foo
          def allowed_keys
            [:foo]
          end
          validates :foo, numericality: true
        end
      end

      it "adds relationships' error message to the base class" do
        message = RelationshipMessage.new({ relationships: { foo: 'not a number' } })
        expect(message).not_to be_valid
        expect(message.errors_on(:relationships)).to include('Foo is not a number')
      end

      it 'returns early when base class relationships is not a hash' do
        message = RelationshipMessage.new({ relationships: 'not a hash' })
        expect(message).to be_valid
        expect(message.errors_on(:relationships)).to be_empty
      end
    end

    describe 'to one relationship validation' do
      class FooMessage  < VCAP::CloudController::BaseMessage
        attr_accessor :bar
        def allowed_keys
          [:bar]
        end
        validates :bar, to_one_relationship: true
      end

      it 'ensures that the data has the correct structure' do
        invalid_one = FooMessage.new({ bar: { not_a_guid: 1234 } })
        invalid_two = FooMessage.new({ bar: { guid: { woah: 1234 } } })
        valid = FooMessage.new(bar: { guid: '123' })

        expect(invalid_one).not_to be_valid
        expect(invalid_two).not_to be_valid
        expect(valid).to be_valid
      end
    end

    describe 'to many relationship validation' do
      class BarMessage  < VCAP::CloudController::BaseMessage
        attr_accessor :routes
        def allowed_keys
          [:routes]
        end
        validates :routes, to_many_relationship: true
      end

      it 'ensures that the data has the correct structure' do
        valid = BarMessage.new({ routes: [{ guid: '1234' }, { guid: '1234' }, { guid: '1234' }, { guid: '1234' }] })
        invalid_one = BarMessage.new({ routes: { guid: '1234' } })
        invalid_two = BarMessage.new({ routes: [{ guid: 1234 }, { guid: 1234 }] })

        expect(valid).to be_valid
        expect(invalid_one).not_to be_valid
        expect(invalid_two).not_to be_valid
      end
    end
  end
end
