require 'd_types'
require 'event'

module Communities
  class PostCreated < Event
    attribute :post_id, DTypes::ID
  end
end
