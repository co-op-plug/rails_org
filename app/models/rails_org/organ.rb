module RailsOrg::Organ
  extend ActiveSupport::Concern
  included do
    attribute :limit_wechat, :integer, default: 1
    attribute :name_short, :string

    has_taxons :area
    belongs_to :area
    
    has_many :supports, -> { where(department_id: nil) }, dependent: :destroy
    has_many :departments, dependent: :destroy
    has_many :rooms, dependent: :delete_all
    has_many :members, dependent: :nullify
    has_many :organ_grants, dependent: :delete_all
    
    has_one_attached :logo

    validates :name, presence: true

    before_validation do
      self.organ_uuid ||= UidHelper.nsec_uuid('ORG')
    end
  end

  def get_organ_token(user_id)
    grant = self.organ_grants.valid.find_by(user_id: user_id)
    if grant
      grant
    else
      self.organ_grants.where(user_id: user_id).delete_all
      grant = organ_grants.create(user_id: user_id)
    end
    grant.token
  end

  def refresh_organ_token(member_id)
    self.organ_grants.delete_all
    create_organ_grant
  
    organ_grant.token
  end

  def generate_token(**options)
    JwtHelper.generate_jwt_token(id, organ_uuid, options)
  end

end
