module Students
  class LevelProgressionCheck
    def call(resource_id:, **_)
      submission = TimelineEvent.find(resource_id)

      return unless Flipper[:auto_level_up].enabled?(submission.course)
      return unless submission.course.unlimited?
      return unless completed?(submission.target.level, submission.founders)

      level_up(submission.course, submission.startup)
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
      next_level = course.levels.find_by(number: team.level.number + 1)
      team.update!(level: next_level)
    end
  end
end