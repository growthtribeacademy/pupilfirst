module Mutations
  class NotifyStudentVideoEvent < ApplicationQuery
    include QueryAuthorizeStudent
    argument :video_id, String, required: true
    argument :target_id, String, required: true
    argument :event, String, required: true

    description "Notifies about student video events"

    field :success, Boolean, null: false

    def resolve(params)
      course = target.course
      ActiveSupport::Notifications.instrument(
        "video_#{params[:event]}.pupilfirst",
        resource_id: params[:video_id],
        actor_id: student.id,
        course_id: course.id
      )
      { success: true }
    end
  end
end
