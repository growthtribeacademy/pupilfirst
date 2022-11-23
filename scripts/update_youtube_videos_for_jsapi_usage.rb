embed_blocks = ContentBlock.where(block_type: 'embed')
domains = Oembed::YoutubeProvider.domains

youtube_blocks = embed_blocks.select do |block|
  string = block.content['embed_code']
  string && domains.any? { |domain| string.match?(domain) }
end

youtube_blocks.each do |block|
  content = block.content
  embed_code = content['embed_code']
  Oembed::YoutubeProvider.new(nil).provide_youtube_player_required_configuration(embed_code)
  content['embed_code'] = embed_code
  block.save!
end
