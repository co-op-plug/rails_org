module RailsOrg::ResignReason
  extend ActiveSupport::Concern
  included do
    prepend RailsTaxon::Node

    has_many :resign_references, dependent: :destroy
    has_many :resigns, through: :resign_references

    validates :name, presence: true
  end

end
