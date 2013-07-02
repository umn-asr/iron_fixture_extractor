class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :author
      t.belongs_to :post
      t.string :content

      t.timestamps
    end
    add_index :comments, :author_id
    add_index :comments, :post_id
  end
end
