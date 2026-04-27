require "test_helper"

# Tests the full journey of a user creating and owning posts.
class UserPostFlowTest < ActionDispatch::IntegrationTest
  test "create user then create post owned by that user" do
    # Step 1: create a new user via HTTP
    post users_path, params: { user: { username: "newuser1", email: "new1@example.com", password: "pass123" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success

    new_user = User.find_by(username: "newuser1")
    assert_not_nil new_user

    # Step 2: create a post belonging to that user
    assert_difference "Post.count" do
      post posts_path, params: { post: { title: "My First Post", body: "Hello Reddit!", user_id: new_user.id } }
    end
    assert_response :redirect

    new_post = Post.find_by(title: "My First Post")
    assert_equal new_user, new_post.user
  end

  test "user profile shows their posts" do
    get user_path(users(:alice))
    assert_response :success
    assert_equal 1, users(:alice).posts.count
  end

  test "user with no posts has empty posts collection" do
    post users_path, params: { user: { username: "loner123", email: "loner@example.com", password: "pass123" } }
    loner = User.find_by(username: "loner123")
    assert_empty loner.posts
    assert_empty loner.comments
  end

  test "create user with duplicate username fails and does not redirect" do
    post users_path, params: { user: { username: users(:alice).username, email: "dup@example.com", password: "pass123" } }
    assert_response :unprocessable_entity
    assert_equal 2, User.count
  end

  test "post belongs_to user reflects correct owner" do
    post posts_path, params: { post: { title: "Bob Post", body: "Content", user_id: users(:bob).id } }
    new_post = Post.find_by(title: "Bob Post")
    assert_equal users(:bob).id, new_post.user_id
    assert_includes users(:bob).posts, new_post
  end
end
