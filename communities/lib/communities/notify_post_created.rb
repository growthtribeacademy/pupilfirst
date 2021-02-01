module Communities
  class NotifyPostCreated
    def call(event)
      post = Post.find(event.data[:post_id])

      email_post_creator(post)
      notify_post_creator(post)
    end

    def email_post_creator(post)
      addressee = post.reply_to_post&.creator || post.topic.creator
      if addressee.present? && post.creator != addressee
        UserMailer.new_post(post, addressee).deliver_later
      end
    end

    def notify_post_creator(post)
      Notifications::PostCreatedJob.perform_later(post.creator.id, post.id)
    end
  end
end
