class ChangeLoveValueDefaultOnUserStatuses < ActiveRecord::Migration[8.0]
  def up
    change_column_default :user_statuses, :love_value, from: 0, to: 50
  end

  def down
    change_column_default :user_statuses, :love_value, from: 50, to: 0
  end
end
