require "test_helper"

class PostTest < ActiveSupport::TestCase
  def valid_attrs
    { title: "Hello", body: "World", user: users(:alice) }
  end

  test "valid post saves successfully" do
    assert Post.new(valid_attrs).valid?
  end

  test "title is required" do
    assert_not Post.new(valid_attrs.merge(title: "")).valid?
  end

  test "body is required" do
    assert_not Post.new(valid_attrs.merge(body: "")).valid?
  end

  test "user_id is required" do
    assert_not Post.new(title: "Hi", body: "World").valid?
  end

  test "belongs to user" do
    post = posts(:first_post)
    assert_equal users(:alice), post.user
  end

  test "has many comments" do
    post = posts(:first_post)
    assert_respond_to post, :comments
  end
end
