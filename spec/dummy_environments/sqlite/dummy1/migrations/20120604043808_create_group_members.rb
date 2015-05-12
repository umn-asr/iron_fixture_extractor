class CreateGroupMembers < ActiveRecord::Migration
  def change
    create_table :group_members do |t|
      t.belongs_to :author
      t.belongs_to :group
      t.string :role

      t.timestamps null: true
    end
    add_index :group_members, :author_id
    add_index :group_members, :group_id
  end
end
