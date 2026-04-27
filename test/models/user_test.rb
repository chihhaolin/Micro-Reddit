require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_attrs
    { username: "testuser", email: "test@example.com", password: "pass123" }
  end

  test "valid user saves successfully" do
    assert User.new(valid_attrs).valid?
  end

  test "username is required" do
    assert_not User.new(valid_attrs.merge(username: "")).valid?
  end

  test "username must be unique" do
    User.create!(valid_attrs)
    assert_not User.new(valid_attrs.merge(email: "other@example.com")).valid?
  end

  test "username minimum length is 4" do
    assert_not User.new(valid_attrs.merge(username: "abc")).valid?
  end

  test "username maximum length is 12" do
    assert_not User.new(valid_attrs.merge(username: "a" * 13)).valid?
  end

  test "email is required" do
    assert_not User.new(valid_attrs.merge(email: "")).valid?
  end

  test "email must be unique" do
    User.create!(valid_attrs)
    assert_not User.new(valid_attrs.merge(username: "other1")).valid?
  end

  test "password is required" do
    assert_not User.new(valid_attrs.merge(password: "")).valid?
  end

  test "password minimum length is 6" do
    assert_not User.new(valid_attrs.merge(password: "abc12")).valid?
  end

  test "password maximum length is 16" do
    assert_not User.new(valid_attrs.merge(password: "a" * 17)).valid?
  end

  test "has many posts" do
    user = users(:alice)
    assert_respond_to user, :posts
  end

  test "has many comments" do
    user = users(:alice)
    assert_respond_to user, :comments
  end
end
