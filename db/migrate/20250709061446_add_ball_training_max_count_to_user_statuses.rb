class AddBallTrainingMaxCountToUserStatuses < ActiveRecord::Migration[8.0]
  def change
    add_column :user_statuses, :ball_training_max_count, :integer
  end
end
