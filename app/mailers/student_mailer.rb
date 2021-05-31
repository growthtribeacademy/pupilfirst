class StudentMailer < SchoolMailer
  def enrollment(student)
    @school = student.course.school
    @course = student.course
    @student = student
    @levels = @course.levels.where.not(unlock_at: nil)
    @course_start_date = @levels.pluck(:unlock_at).min
    @course_end_date = @course.ends_at

    simple_roadie_mail(@student.email, "You have been added as a student in #{@school.name}")
  end
end
