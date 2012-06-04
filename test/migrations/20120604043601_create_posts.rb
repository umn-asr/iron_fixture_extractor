class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.belongs_to :author
      t.string :name
      t.string :content

      t.timestamps
    end
    add_index :posts, :author_id
  end
end
