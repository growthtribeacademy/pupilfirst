APP_CONFIG = {
  sms_provider_url: ENV['SMS_PROVIDER_URL'],
  google_analytics_tracking_id: ENV['GOOGLE_ANALYTICS_TRACKING_ID'],
  easyrtc_socket_url: ENV['EASYRTC_SOCKET_URL'],
  slack_token: ENV['SLACK_TOKEN'],
  instamojo: {
    url: ENV['INSTAMOJO_API_URL'],
    api_key: ENV['INSTAMOJO_API_KEY'],
    auth_token: ENV['INSTAMOJO_AUTH_TOKEN'],
    salt: ENV['INSTAMOJO_SALT']
  },
  instagram_access_token: ENV['INSTAGRAM_ACCESS_TOKEN']
}.with_indifferent_access

APP_CONSTANTS = {
  certificate_background_base64: Base64.strict_encode64(
    open(File.expand_path(File.join(Rails.root, 'app', 'assets', 'images', 'apply', 'admission-process', 'coding-video-certificate.png'))).read
  )
}.with_indifferent_access
