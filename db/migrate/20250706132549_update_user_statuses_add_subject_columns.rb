class UpdateUserStatusesAddSubjectColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :user_statuses, :arithmetic,         :integer, default: 0, null: false
    add_column :user_statuses, :arithmetic_effort,  :integer, default: 0, null: false

    add_column :user_statuses, :japanese,           :integer, default: 0, null: false
    add_column :user_statuses, :japanese_effort,    :integer, default: 0, null: false

    add_column :user_statuses, :science,            :integer, default: 0, null: false
    add_column :user_statuses, :science_effort,     :integer, default: 0, null: false

    add_column :user_statuses, :social_studies,     :integer, default: 0, null: false
    add_column :user_statuses, :social_effort,      :integer, default: 0, null: false

    remove_column :user_statuses, :study_value, :integer
  end
end
