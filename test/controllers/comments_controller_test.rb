require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "POST /posts/:post_id/comments with valid params creates comment and redirects" do
    assert_difference("Comment.count") do
      post post_comments_path(posts(:first_post)),
           params: { comment: { body: "Great post!", user_id: users(:alice).id } }
    end
    assert_redirected_to post_path(posts(:first_post))
  end

  test "POST /posts/:post_id/comments with invalid params redirects with alert" do
    assert_no_difference("Comment.count") do
      post post_comments_path(posts(:first_post)),
           params: { comment: { body: "", user_id: users(:alice).id } }
    end
    assert_redirected_to post_path(posts(:first_post))
  end

  test "DELETE /posts/:post_id/comments/:id destroys comment and redirects" do
    assert_difference("Comment.count", -1) do
      delete post_comment_path(posts(:first_post), comments(:first_comment))
    end
    assert_redirected_to post_path(posts(:first_post))
  end
end
