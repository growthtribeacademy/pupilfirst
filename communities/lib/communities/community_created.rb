require 'd_types'
require 'event'

module Communities
  class CommunityCreated < Event
    attribute :school_id, DTypes::ID
    attribute :community_id, DTypes::ID
    attribute :name, DTypes::String
    attribute :courses_ids, DTypes::Array.of(DTypes::ID)
  end
end
