module VCAP::CloudController
  class AppsListParameters
    include ActiveModel::Model
    include VCAP::CloudController::Validators

    attr_accessor :names, :guids, :organization_guids, :space_guids, :page, :per_page, :order_by, :order_direction

    validates :names, array: true, allow_blank: true
    validates :guids, array: true, allow_blank: true
    validates :organization_guids, array: true, allow_blank: true
    validates :space_guids, array: true, allow_blank: true
    validates_numericality_of :page, greater_than: 0, allow_blank: true
    validates_numericality_of :per_page, greater_than: 0, allow_blank: true
    validates_inclusion_of :order_by, in: %w(created_at updated_at), allow_blank: true
    validates_inclusion_of :order_direction, in: %w(asc desc), allow_blank: true
  end
end
