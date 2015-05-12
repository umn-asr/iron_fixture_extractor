class Post < ActiveRecord::Base
  belongs_to :author
  has_many :comments
  serialize :serialized_thing, SerializedAttributeEncoder.new
end
