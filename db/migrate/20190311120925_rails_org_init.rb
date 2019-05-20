class RailsOrgInit < ActiveRecord::Migration[6.0]

  def change

    create_table :organs do |t|
      t.references :area
      t.references :parent
      t.string :name
      t.string :organ_uuid
      t.integer :limit_wechat
      t.string :address
      t.string :timezone
      t.string :locale
      t.integer :members_count, default: 0
      t.timestamps
    end

    create_table :organ_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index [:ancestor_id, :descendant_id, :generations], unique: true, name: 'organ_anc_desc_idx'
      t.index [:descendant_id], name: 'organ_desc_idx'
    end

    create_table :organ_grants do |t|
      t.references :organ
      t.references :member
      t.references :user
      t.string :token, null: false
      t.datetime :expire_at
      t.timestamps
    end
    
    create_table :rooms do |t|
      t.references :organ
      t.string :room_number
      t.integer :limit_number
      t.string :color
      t.integer :time_plans_count, default: 0
      t.timestamps
    end

    create_table :departments do |t|
      t.references :organ
      t.references :parent
      t.string :name
      t.integer :member_departments_count, default: 0
      t.integer :all_member_departments_count, default: 0
      t.integer :needed_number
      t.string :collective_email
      t.timestamps
    end

    create_table :department_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
      t.index [:ancestor_id, :descendant_id, :generations], unique: true, name: 'department_anc_desc_idx'
      t.index [:descendant_id], name: 'department_desc_idx'
    end

    create_table :members do |t|
      t.references :user
      t.references :organ
      t.string :type
      t.string :name
      t.string :identity
      t.string :number
      t.date :join_on
      t.boolean :enabled, default: true
      t.string :state
      t.string :organ_token
      t.timestamps
    end

    create_table :tutorials do |t|
      t.references :member
      t.references :tutor
      t.string :kind
      t.string :state
      t.string :accepted_status
      t.string :verified
      t.date :start_on
      t.date :finish_on
      t.string :performance
      t.integer :allowance
      t.string :note, limit: 4096
      t.string :comment, limit: 4096
      t.timestamps
    end

    create_table :job_titles do |t|
      t.references :organ
      t.references :department
      t.references :department_root
      t.string :name
      t.string :description
      t.integer :grade
      t.integer :limit_number
      t.timestamps
    end

    create_table :member_departments do |t|
      t.references :member
      t.references :job_title
      t.references :department_root
      t.references :department
      t.references :organ
      t.integer :grade
      t.boolean :major
      t.integer :department_descendant_ids, array: true
      t.timestamps
    end

    create_table :supports do |t|
      t.references :department
      t.references :office
      t.references :member
      t.string :name
      t.integer :grade
      t.string :code
      t.timestamps
    end
    
    create_table :organ_handles do |t|
      t.string :name
      t.string :description
      t.string :record_class
      t.string :record_column
      t.timestamps
    end
    
    create_table :department_grants do |t|
      t.references :organ
      t.references :organ_handle
      t.references :department
      t.references :job_title
      t.timestamps
    end

  end

end
