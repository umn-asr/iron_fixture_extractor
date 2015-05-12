class GroupMember < ActiveRecord::Base
  belongs_to :author
  belongs_to :group
end
