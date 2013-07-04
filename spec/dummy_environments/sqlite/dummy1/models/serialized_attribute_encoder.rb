# This encoder just serializes complex attributes with the string
# representation of their class. A +ComplexThing+ instance is stored in
# the database as 'ComplexThing', not a marshalled Ruby object.
#
class SerializedAttributeEncoder
  def load(value)
    value.constantize.new
  end
  def dump(object)
    object.class.to_s
  end
end
