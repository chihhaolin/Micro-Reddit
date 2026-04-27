require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def valid_attrs
    { body: "Nice post!", user: users(:bob), post: posts(:first_post) }
  end

  test "valid comment saves successfully" do
    assert Comment.new(valid_attrs).valid?
  end

  test "body is required" do
    assert_not Comment.new(valid_attrs.merge(body: "")).valid?
  end

  test "user_id is required" do
    assert_not Comment.new(body: "Hi", post: posts(:first_post)).valid?
  end

  test "post_id is required" do
    assert_not Comment.new(body: "Hi", user: users(:bob)).valid?
  end

  test "belongs to user" do
    comment = comments(:first_comment)
    assert_equal users(:bob), comment.user
  end

  test "belongs to post" do
    comment = comments(:first_comment)
    assert_equal posts(:first_post), comment.post
  end
end
