class CreateSomeData < ActiveRecord::Migration
  def up
    a=Author.create :name => "Joe"
    p1=a.posts.create :name => "First post", :serialized_thing => ComplexThing.new
      p1.comments.create :content => "This is crap"
    p2=a.posts.create :name => "Second post", :serialized_thing => ComplexThing.new
      p2.comments.create :content => "This is great"

    a2=Author.create :name => "Bill"
    g=Group.create :name => "Group 1"
    g.authors << a2
    g.save

    User::Jerk.create(:name => "Jimmy the jerk")
    User::Admin.create(:name => "Ron the admin")
  end
end
