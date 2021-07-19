class AsyncHandler
  class Job < ApplicationJob
    queue_as :low_priority

    def perform(payload)
      handler = Transactional.new(payload.fetch(:handler).new)
      handler.call(**payload.except(:handler))
    end
  end

  def initialize(handler_klass)
    @handler_klass = handler_klass
  end

  def call(payload)
    Job.perform_later(payload.merge(handler: @handler_klass))
  end
end