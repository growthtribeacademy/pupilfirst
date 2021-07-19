class Transactional
  def initialize(handler)
    @handler = handler
  end

  def call(payload)
    ApplicationRecord.transaction do
      @handler.call(payload)
    end
  end
end