require_relative './serialized_attribute_encoder'
class Post < ActiveRecord::Base
  belongs_to :author
  has_many :comments, :inverse_of => :post
  attr_accessible :content, :name, :serialized_thing
  serialize :serialized_thing, SerializedAttributeEncoder.new
end
