require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "GET /posts returns 200" do
    get posts_path
    assert_response :success
  end

  test "GET /posts/:id returns 200" do
    get post_path(posts(:first_post))
    assert_response :success
  end

  test "GET /posts/new returns 200" do
    get new_post_path
    assert_response :success
  end

  test "POST /posts with valid params creates post and redirects" do
    assert_difference("Post.count") do
      post posts_path, params: { post: { title: "New Post", body: "Body text", user_id: users(:alice).id } }
    end
    assert_redirected_to post_path(Post.last)
  end

  test "POST /posts with invalid params re-renders new" do
    assert_no_difference("Post.count") do
      post posts_path, params: { post: { title: "", body: "", user_id: users(:alice).id } }
    end
    assert_response :unprocessable_entity
  end

  test "DELETE /posts/:id destroys post and redirects" do
    assert_difference("Post.count", -1) do
      delete post_path(posts(:first_post))
    end
    assert_redirected_to posts_path
  end
end
