Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::Client.new

  event_store.subscribe(Communities::NotifyCommunityCreated.new, to: [Communities::CommunityCreated])
  event_store.subscribe(Communities::NotifyPostCreated.new, to: [Communities::PostCreated])
end
