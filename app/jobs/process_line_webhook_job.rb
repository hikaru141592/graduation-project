class ProcessLineWebhookJob < ApplicationJob
  queue_as :default

  def perform(raw_body, signature)
    parser = Line::Bot::V2::WebhookParser.new(channel_secret: ENV.fetch("LINE_CHANNEL_SECRET"))
    client = Line::Bot::V2::MessagingApi::ApiClient.new(channel_access_token: ENV.fetch("LINE_CHANNEL_TOKEN"))

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
      when Line::Bot::V2::Webhook::MessageEvent
        next unless event.message.type == "text"
        user = Authentication.find_by(provider: "line", uid: event.source.user_id)&.user
        next unless user
        now = Time.current
        if now.hour >= 23 || now.hour < 7
          reply_message = "ににに～・・・。\n----（訳）----\nおねむ～・・・。"
        else
          text = event.message.text
          case text
          when /\A(?:ご飯|ごはん|ゴハン|食事|しょくじ|お食事|おしょくじ|飯|めし|メシ)(?:だよ|ですよ|だ|だぜ)?ー?[!！]?\z/
            status = user.user_status
            if status.hunger_value <= 70
              status.update!(hunger_value: [ status.hunger_value + 40, 100 ].min)
              reply_message = "にー！ににーにー！\nににににー！\n----（訳）----\nわーい！ごはんだー！\nありがとう！"
            else
              reply_message = "ににー！\nんににに～！\n----（訳）----\nうー！\n今はお腹いっぱいだよー！"
            end
          when "よしよし！"
            status = user.user_status
            status.update!(love_value: [ status.love_value + 10, 100 ].min)

            reply_message = "にー！\nにににーにー！\n----（訳）----\nわーい！\nうれしいなあ！"
          else
            reply_message = "んににー！にーににー！"
          end
        end
        reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(reply_token: event.reply_token, messages: [Line::Bot::V2::MessagingApi::TextMessage.new(text: reply_message)])
        client.reply_message(reply_message_request: reply_req)
      end
    end
  end
end
