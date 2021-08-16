module Students
  # This service handles all actions related to course completion by the given student.
  class AfterCourseCompletionService
    def initialize(
      student,
      notification_service: Developers::NotificationService.new,
      analytics: Segment::Analytics.new(
        {
          write_key: ENV['SEGMENT_WRITE_KEY'] || '',
          on_error: Proc.new { |_status, msg| Rails.logger.debug{msg} }
        }
      )
    )
      @student = student
      @notification_service = notification_service
      @analytics = analytics
    end

    def execute
      @analytics.track(
        user_id: @student.user.external_id,
        event: 'Course Completed',
        properties: {
          course_name: @student.course.name,
          course_id: @student.course.id
        }
      ) if @student.user.external_id

      Startups::IssueCertificateService.new(@student.startup).execute

      user = @student.user
      course = @student.course
      @notification_service.execute(
        course,
        :course_completed,
        user,
        course
      )
    end
  end
end
