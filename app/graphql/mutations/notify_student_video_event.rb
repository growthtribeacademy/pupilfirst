module Mutations
  class NotifyStudentVideoEvent < GraphQL::Schema::Mutation
    argument :student_id, ID, required: true
    argument :video_id, String, required: true

    description "Notifies about student video events"

    field :success, Boolean, null: false

    def resolve(params)
      ActiveSupport::Notifications.instrument(
        "student_video_event_occured.pupilfirst",
        resource_id: params[:video_id],
        actor_id: params[:student_id]
      )
      { success: true }
    end
  end
end
