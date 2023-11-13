require_relative './serialized_attribute_encoder'
class DifferentPost < ActiveRecord::Base
  # This is supposed to be identical to post
  # and used to test fixture loading to a model
  # different from the one it was extracted from
  # so behavior doesn't matter
  serialize :serialized_thing, coder: SerializedAttributeEncoder.new
end
