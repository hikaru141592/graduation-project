class ProcessLineWebhookJob < ApplicationJob
  queue_as :default

  def perform(raw_body, signature)
    parser = Line::Bot::V2::WebhookParser.new(channel_secret: ENV.fetch("LINE_CHANNEL_SECRET"))

    begin
      events = parser.parse(body: raw_body, signature: signature)
    rescue Line::Bot::V2::WebhookParser::InvalidSignatureError => e
      Rails.logger.warn("[LINE] Invalid signature: #{e.message}")
      return
    end
    events.each do |event|
      case event
      when Line::Bot::V2::Webhook::FollowEvent
        auth = Authentication.find_by(provider: "line", uid: event.source.user_id)
        auth&.user&.update!(line_friend_linked: true)
      when Line::Bot::V2::Webhook::UnfollowEvent
        auth = Authentication.find_by(provider: "line", uid: event.source.user_id)
        auth&.user&.update!(line_friend_linked: false)
      end
    end
  end
end
