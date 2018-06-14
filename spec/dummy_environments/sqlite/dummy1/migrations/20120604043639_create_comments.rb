class CreateComments < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.belongs_to :author
      t.belongs_to :post
      t.string :content

      t.timestamps null: true
    end
    add_index :comments, :author_id
    add_index :comments, :post_id
  end
end
