require 'dry-struct'
require 'd_types'
class Event < Dry::Struct
  transform_keys(&:to_sym)

  def self.new(data: {}, metadata: {}, **rest)
    super(rest.merge(data).merge(metadata: metadata))
  end

  def self.inherited(klass)
    super
    klass.attribute :metadata, DTypes.Constructor(RubyEventStore::Metadata).default { RubyEventStore::Metadata.new }
    klass.attribute :event_id, DTypes::ID.default { SecureRandom.uuid }
  end

  def timestamp
    metadata[:timestamp]
  end

  def valid_at
    metadata[:valid_at]
  end

  def data
    to_h.except(:event_id, :metadata)
  end

  def event_type
    self.class.name
  end

  def ==(other_event)
    other_event.instance_of?(self.class) &&
      other_event.event_id.eql?(event_id) &&
      other_event.data.eql?(data)
  end

  alias_method :eql?, :==
end
