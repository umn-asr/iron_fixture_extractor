class Group < ActiveRecord::Base
  has_many :group_members
  has_many :authors, :through => :group_members
end
