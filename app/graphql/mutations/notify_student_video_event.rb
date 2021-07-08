module Mutations
  class NotifyStudentVideoEvent < GraphQL::Schema::Mutation
    argument :video_id, String, required: true

    description "Notifies about student video events"

    field :success, Boolean, null: false

    def resolve(params)
      { success: true }
    end
  end
end
