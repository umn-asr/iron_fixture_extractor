class Comment < ActiveRecord::Base
  belongs_to :author
  belongs_to :post, :inverse_of => :comments
  attr_accessible :content
end
