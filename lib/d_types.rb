require 'dry-types'
module DTypes
  include Dry.Types()

  UUID = Dry::Types['string'].constrained(format: /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\z/i)
  ID = Dry::Types['integer']
end
