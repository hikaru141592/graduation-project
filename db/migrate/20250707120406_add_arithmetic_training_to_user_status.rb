class AddArithmeticTrainingToUserStatus < ActiveRecord::Migration[8.0]
  def change
    add_column :user_statuses, :arithmetic_training_max_count, :integer, null: true
    add_column :user_statuses, :arithmetic_training_fastest_time, :integer, null: true
  end
end
