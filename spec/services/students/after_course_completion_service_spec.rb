require 'rails_helper'

describe Students::AfterCourseCompletionService do
  let(:student) { create :student }

  describe '#execute' do
    it 'publishes course_completed event' do
      notification_service = instance_double('Developers::NotificationService')
      analytics_tool = instance_double('Segment::Analytics::Client')
      expect(notification_service).to receive(:execute).with(
        student.course,
        :course_completed,
        student.user,
        student.course
      )
      expect(analytics_tool).to receive(:track).with(
        user_id: student.user.external_id,
        event: 'Course Completed',
        properties: {
          course_name: student.course.name,
          course_id: student.course.id
        }
      )

      subject =
        described_class.new(
          student,
          notification_service: notification_service,
          analytics: analytics_tool
        )
      subject.execute
    end
  end
end
