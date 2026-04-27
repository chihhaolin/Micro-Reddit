require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "GET /users returns 200" do
    get users_path
    assert_response :success
  end

  test "GET /users/:id returns 200" do
    get user_path(users(:alice))
    assert_response :success
  end

  test "GET /users/new returns 200" do
    get new_user_path
    assert_response :success
  end

  test "POST /users with valid params creates user and redirects" do
    assert_difference("User.count") do
      post users_path, params: { user: { username: "newuser1", email: "new@example.com", password: "pass123" } }
    end
    assert_redirected_to user_path(User.last)
  end

  test "POST /users with invalid params re-renders new" do
    assert_no_difference("User.count") do
      post users_path, params: { user: { username: "", email: "", password: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "POST /users with duplicate username fails" do
    assert_no_difference("User.count") do
      post users_path, params: { user: { username: users(:alice).username, email: "other@example.com", password: "pass123" } }
    end
    assert_response :unprocessable_entity
  end
end
