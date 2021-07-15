
class AutoLevelUp
  def call(course_id)
    course = Course.find(course_id)
    return unless Flipper[:auto_level_up].enabled?(submission.course)

    course.startups.each do |team|
      ApplicationRecord.transaction do
        LevelProgressionCheck::Internal.new(course, team.level, team)
      end
    end
  end
end

AutoLevelUp.new.call(ARGV[0])