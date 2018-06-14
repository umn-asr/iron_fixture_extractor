class CreateGroupMembers < ActiveRecord::Migration[4.2]
  def change
    create_table :group_members do |t|
      t.belongs_to :author
      t.belongs_to :group
      t.string :role

      t.timestamps
    end
    add_index :group_members, :author_id
    add_index :group_members, :group_id
  end
end
