require 'communities'
class CreateCommunityMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { length: { minimum: 1, maximum: 50 } }
  property :target_linkable
  property :course_ids

  validate :course_must_exist_in_current_school

  def course_must_exist_in_current_school
    return if courses.count == course_ids.count

    errors[:base] << 'invalid courses'
  end

  def create_community
    Community.transaction do
      comm = current_school.communities.create!(
        name: name,
        target_linkable: target_linkable,
        courses: courses,
      )
      publish_event(comm)

      comm
    end
  end

  private

  def resource_school
    current_school
  end

  def courses
    @courses ||= current_school.courses.where(id: course_ids)
  end

  def publish_event(community)
    event = Communities::CommunityCreated.new(data: { school_id: current_school.id, community_id: community.id, name: community.name, courses_ids: community.courses.ids})
    stream_name = "school$#{current_school.id}"
    event_store.publish(event, stream_name: stream_name)
  end


  def event_store
    Rails.configuration.event_store
  end
end
