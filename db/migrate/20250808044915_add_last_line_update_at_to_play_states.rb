class AddLastLineUpdateAtToPlayStates < ActiveRecord::Migration[8.0]
  def change
    add_column :play_states, :last_line_update_at, :datetime
  end
end
