class CreateDifferentPosts < ActiveRecord::Migration
  # DUPLICATED FROM Posts
  def change
    create_table :different_posts do |t|
      t.belongs_to :author
      t.string :name
      t.string :content
      t.string :serialized_thing

      t.timestamps
    end
    add_index :different_posts, :author_id
  end
end
