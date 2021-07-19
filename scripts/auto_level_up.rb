
class AutoLevelUp
  def initialize
    @service = Students::LevelProgressionCheck::Internal.new
  end
  attr_reader :service

  def call(course_id)
    course = Course.find(course_id)
    return unless Flipper[:auto_level_up].enabled?(course)

    teams = course.startups
    puts "Teams registered in course: #{teams.count}"
    while !teams.empty?
      puts "Teams to check: #{teams.count}"
      teams = update(course, teams).compact
      puts "Teams leveled up: #{teams.count}"
    end
  end

  def update(course, teams)
    teams.map do |team|
      ApplicationRecord.transaction do
        before = team.level.number
        service.(course, team.level, team)
        team.reload.level.number > before ? team : nil
      end
    end
  end
end

AutoLevelUp.new.call(ARGV[0])