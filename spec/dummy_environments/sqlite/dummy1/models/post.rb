require_relative './serialized_attribute_encoder'
class Post < ActiveRecord::Base
  belongs_to :author
  has_many :comments, :inverse_of => :post
  serialize :serialized_thing, SerializedAttributeEncoder.new
end
