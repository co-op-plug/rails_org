module RailsOrg::JobTitle
  extend ActiveSupport::Concern
  included do
    attribute :grade, :integer
    attribute :name, :string
    attribute :description, :string
    attribute :limit_member, :integer

    belongs_to :department
    belongs_to :department_root, class_name: 'Department'
    has_many :member_departments, dependent: :destroy
    has_many :members, through: :member_departments, source: :member
    has_many :same_job_titles, ->(o){ where(organ_id: o.organ_id) }, class_name: self.base_class.name, foreign_key: :department_root_id, primary_key: :department_root_id
    has_many :lower_job_titles, ->(o){ default_where(organ_id: o.organ_id, 'grade-gte': o.grade) }, class_name: self.name, foreign_key: :department_root_id, primary_key: :department_root_id

    default_scope -> { order(grade: :asc) }
    
    before_validation :init_department_root
    after_update_commit :sync_grade_member_departments, if: -> { saved_change_to_grade? }
    
    acts_as_list column: :grade, scope: [:department_root_id], top_of_list: ->(o){ o.top_grade }
  end

  def init_department_root
    self.department_root = self.department.root
  end

  def sync_grade_member_departments
    member_departments.update_all(grade: self.grade)
  end

  def top_grade
    SuperJobTitle.where(organ_id: department.organ_id).maximum(:grade).to_i + 1
  end

  def sync_to_role_ids
    self.role_ids = cached_role_ids
    moved = Array(cached_role_ids_before_last_save) - Array(cached_role_ids)
  
    self.members.each do |member|
      r = Array(member.cached_role_ids) - moved
      r |= Array(cached_role_ids)
      member.cached_role_ids = r
      member.save
    end
  end
  
end
