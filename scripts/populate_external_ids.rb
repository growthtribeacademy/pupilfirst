sso = Rails.configuration.keycloak_client

User.all.each do |user|
  print '.'
  next if user.external_id
  info = sso.fetch_user(user.email) rescue nil
  next unless info
  user.update!(external_id: info["id"])
end
puts "Done."