class CreateUserEventCategoryInvalidations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_event_category_invalidations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event_category, null: false, foreign_key: true
      t.datetime :expires_at

      t.timestamps
    end
    add_index :user_event_category_invalidations, [ :user_id, :event_category_id ], unique: true, name: :index_user_event_cat_invalidations_on_user_and_category
  end
end
