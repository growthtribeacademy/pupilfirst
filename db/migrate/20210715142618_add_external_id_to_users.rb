class AddExternalIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :external_id, :string
  end
end
