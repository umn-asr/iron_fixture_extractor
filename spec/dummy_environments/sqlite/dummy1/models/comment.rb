class Comment < ActiveRecord::Base
  belongs_to :author
  belongs_to :post
  attr_accessible :content
end
