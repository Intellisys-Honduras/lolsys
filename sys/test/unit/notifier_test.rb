require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "gmail" do
    @expected.subject = 'Notifier#gmail'
    @expected.body    = read_fixture('gmail')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifier.create_gmail(@expected.date).encoded
  end

end
