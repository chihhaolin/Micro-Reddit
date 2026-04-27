require "test_helper"

# Tests the full journey of posting and commenting, including validation failures.
class PostCommentFlowTest < ActionDispatch::IntegrationTest
  test "create post then add comment then delete comment" do
    # Step 1: create post
    post posts_path, params: { post: { title: "Discuss This", body: "Topic body", user_id: users(:alice).id } }
    new_post = Post.find_by(title: "Discuss This")

    # Step 2: bob adds a comment
    assert_difference "Comment.count" do
      post post_comments_path(new_post), params: { comment: { body: "Interesting!", user_id: users(:bob).id } }
    end
    assert_redirected_to post_path(new_post)

    comment = Comment.find_by(body: "Interesting!")
    assert_equal users(:bob), comment.user
    assert_equal new_post, comment.post

    # Step 3: delete the comment
    assert_difference "Comment.count", -1 do
      delete post_comment_path(new_post, comment)
    end
    assert_redirected_to post_path(new_post)
  end

  test "comment with blank body is rejected and does not persist" do
    assert_no_difference "Comment.count" do
      post post_comments_path(posts(:first_post)), params: { comment: { body: "", user_id: users(:alice).id } }
    end
    assert_redirected_to post_path(posts(:first_post))
  end

  test "comment without user_id is rejected" do
    assert_no_difference "Comment.count" do
      post post_comments_path(posts(:first_post)), params: { comment: { body: "Ghost comment" } }
    end
    assert_redirected_to post_path(posts(:first_post))
  end

  test "multiple users can comment on same post" do
    assert_difference "Comment.count", 2 do
      post post_comments_path(posts(:first_post)), params: { comment: { body: "Alice says hi", user_id: users(:alice).id } }
      post post_comments_path(posts(:first_post)), params: { comment: { body: "Bob says hello", user_id: users(:bob).id } }
    end
    assert_equal 3, posts(:first_post).comments.reload.count
  end

  test "post shows its comments through association" do
    get post_path(posts(:first_post))
    assert_response :success
    assert_equal 1, posts(:first_post).comments.count
    assert_equal users(:bob), posts(:first_post).comments.first.user
  end
end
