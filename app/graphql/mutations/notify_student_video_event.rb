module Mutations
  class NotifyStudentVideoEvent < GraphQL::Schema::Mutation
    argument :student_id, String, required: true
    argument :course_id, String, required: true
    argument :video_id, String, required: true
    argument :event, String, required: true

    description "Notifies about student video events"

    field :success, Boolean, null: false

    def resolve(params)
      puts params.inspect
      ActiveSupport::Notifications.instrument(
        "student_video_event_occured.pupilfirst",
        resource_id: params[:video_id],
        actor_id: params[:student_id],
        course_id: params[:course_id],
        event: params[:event]
      )
      { success: true }
    end
  end
end
