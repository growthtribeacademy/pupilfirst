
class AutoLevelUp
  def call(course_id)
    course = Course.find(course_id)
    return unless Flipper[:auto_level_up].enabled?(submission.course)

    course.startups.each do |team|
      ApplicationRecord.transaction do
        next unless completed?(team.level, team.founders)
        level_up(course, team)
      end
    end
  end

  private

  def completed?(level, founders)
    level.targets.all?{|t| target_completed?(t, founders)}
  end

  def target_completed?(target, founders)
    founders.all?{|f| target_completed_by?(target, f)}
  end

  def target_completed_by?(target, founder)
    target.status(founder).in?([Targets::StatusService::STATUS_PASSED])
  end

  def level_up(course, team)
    up = next_level(course, team.level)
    return unless up

    puts "Level up from #{team.level.number} - #{team.name}"
    team.update!(level: up)
  end

  def next_level(course, current_level)
    course.levels.find_by(number: current_level.number + 1)
  end
end

AutoLevelUp.new.call(ARGV[0])