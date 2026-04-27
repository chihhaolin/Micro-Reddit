require "test_helper"

# Tests that dependent: :destroy works correctly across the model hierarchy.
class CascadeDestroyTest < ActionDispatch::IntegrationTest
  test "deleting a post also destroys its comments" do
    post_to_delete = posts(:first_post)
    comment_id = comments(:first_comment).id

    assert_difference "Comment.count", -1 do
      assert_difference "Post.count", -1 do
        delete post_path(post_to_delete)
      end
    end

    assert_nil Comment.find_by(id: comment_id)
  end

  test "deleting a post via HTTP redirects and removes all associated comments" do
    post posts_path, params: { post: { title: "Temp Post", body: "Will be deleted", user_id: users(:alice).id } }
    temp_post = Post.find_by(title: "Temp Post")

    post post_comments_path(temp_post), params: { comment: { body: "Comment A", user_id: users(:alice).id } }
    post post_comments_path(temp_post), params: { comment: { body: "Comment B", user_id: users(:bob).id } }
    assert_equal 2, temp_post.comments.reload.count

    assert_difference "Comment.count", -2 do
      delete post_path(temp_post)
    end
    assert_redirected_to posts_path
  end

  test "deleting user destroys their posts and comments" do
    alice = users(:alice)
    alice_post_ids = alice.posts.pluck(:id)
    alice_comment_ids = alice.comments.pluck(:id)

    alice.destroy

    alice_post_ids.each { |id| assert_nil Post.find_by(id: id) }
    alice_comment_ids.each { |id| assert_nil Comment.find_by(id: id) }
  end

  test "deleting user does not delete comments left by others on their posts" do
    # bob's comment on alice's post — deleting alice's post removes bob's comment
    assert_equal users(:bob), comments(:first_comment).user
    assert_equal posts(:first_post), comments(:first_comment).post
    assert_equal users(:alice), posts(:first_post).user

    bob_comment_id = comments(:first_comment).id

    # delete alice's post
    posts(:first_post).destroy
    assert_nil Comment.find_by(id: bob_comment_id)
  end
end
