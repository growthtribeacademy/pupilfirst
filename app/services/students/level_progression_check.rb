module Students
  class LevelProgressionCheck
    def call(resource_id:, **_)
      submission = TimelineEvent.find(resource_id)

      return unless Flipper[:auto_level_up].enabled?(submission.course)
      return unless submission.course.unlimited?
      return unless all_previous_levels_completed?(
        submission.course,
        submission.target.level,
        submission.founders
      )

      level_up(submission.course, submission.startup)
    end

    private

    def all_previous_levels_completed?(course, level, founders)
      course
        .levels
        .where('number > 0 and number <= ?', level.number)
        .all?{|lvl| completed?(lvl, founders)}
    end

    def completed?(level, founders)
      level.targets.all?{|t| target_completed?(t, founders)}
    end

    def target_completed?(target, founders)
      founders.all?{|f| target_completed_by?(target, f)}
    end

    def target_completed_by?(target, founder)
      target.status(founder).in?(eligible_statuses)
    end

    def level_up(course, team)
      up = next_level(course, team.level)
      return unless up
      team.update!(level: up)
    end

    def next_level(course, current_level)
      course.levels.find_by(number: current_level.number + 1)
    end

    def eligible_statuses
      [
        Targets::StatusService::STATUS_SUBMITTED,
        Targets::StatusService::STATUS_PASSED,
        Targets::StatusService::STATUS_FAILED
      ]
    end
  end
end