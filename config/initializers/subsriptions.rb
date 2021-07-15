require 'transactional'
require 'async_handler'

{
  :student_added => [
    ->(payload) { Keycloak::SetupStudentAccount::Job.perform_later(payload) }
  ],
  :submission_graded => [
    AsyncHandler.new(Students::LevelProgressionCheck)
  ],
  :submission_automatically_verified => [
    AsyncHandler.new(Students::LevelProgressionCheck)
  ],
}
.each do |event_type, subscribers|
  subscribers.each do |subscriber|
    ActiveSupport::Notifications.subscribe("#{event_type}.pupilfirst") do |_, _, _, _, payload|
      subscriber.call(**payload)
    end
  end
end
