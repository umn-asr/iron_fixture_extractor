class Group < ActiveRecord::Base
  attr_accessible :name
  has_many :group_members
  has_many :authors, through: :group_members
end
