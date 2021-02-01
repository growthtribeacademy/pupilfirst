class CreatePostMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :body, validates: { length: { minimum: 1, maximum: 10_000 } }
  property :topic_id, validates: { presence: true }
  property :reply_to_post_id

  validate :cannot_reply_to_topic_body

  def cannot_reply_to_topic_body
    return if reply_to_post_id.blank?

    return if reply_to_post_id.present? && reply_to_post_id != topic.first_post.id

    errors[:base] << 'Cannot add reply to first post'
  end

  validate :topic_is_not_locked

  def topic_is_not_locked
    return if topic.locked_at.blank?

    errors[:base] << 'Cannot add reply to a locked topic'
  end

  def create_post
    Post.transaction do
      post = Post.create!(
        creator: current_user,
        topic: topic,
        body: body,
        reply_to_post: reply_to_post,
        post_number: post_number
      )

      # Update the topic's last activity time.
      topic.update!(last_activity_at: Time.zone.now)

      publish_event(post)

      post
    end
  end

  private

  alias authorized? authorized_create?

  def community
    @community ||= topic&.community
  end

  def topic
    @topic ||= Topic.find_by(id: topic_id)
  end

  def reply_to_post
    community.posts.find_by(id: reply_to_post_id)
  end

  def post_number
    topic.posts.maximum(:post_number) + 1
  end

  def event_store
    Rails.configuration.event_store
  end

  def publish_event(post)
    event = Communities::PostCreated.new(data: { post_id: post.id })
    stream_name = "school$#{current_school.id}"
    event_store.publish(event, stream_name: stream_name)
  end
end
