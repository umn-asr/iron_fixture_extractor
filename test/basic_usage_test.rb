require 'test_helper'
class BasicUsage < ActiveSupport::TestCase
  setup do
    @poo = 'poo'
  end
  should "do crap" do
    assert_respond_to Fe, :extract
  end
end

