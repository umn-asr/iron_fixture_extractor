class CreatePosts < ActiveRecord::Migration[4.2]
  def change
    create_table :posts do |t|
      t.belongs_to :author
      t.string :name
      t.string :content
      t.string :serialized_thing

      t.timestamps
    end
    add_index :posts, :author_id
  end
end
