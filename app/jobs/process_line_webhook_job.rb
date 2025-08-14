class ProcessLineWebhookJob < ApplicationJob
  queue_as :default

  def perform(raw_body, signature)
    client, events = initialize_line_client_and_events(raw_body, signature)
    return if events.empty?

    events.each do |event|
      case event
      when Line::Bot::V2::Webhook::FollowEvent, Line::Bot::V2::Webhook::UnfollowEvent
        process_follow_unfollow_event(event)
      when Line::Bot::V2::Webhook::MessageEvent
        process_message_event(event, client)
      end
    end
  end

  private
  def initialize_line_client_and_events(raw_body, signature)
    parser = Line::Bot::V2::WebhookParser.new(channel_secret: ENV.fetch("LINE_CHANNEL_SECRET"))
    client = Line::Bot::V2::MessagingApi::ApiClient.new(channel_access_token: ENV.fetch("LINE_CHANNEL_TOKEN"))
    events = parser.parse(body: raw_body, signature: signature)
    [ client, events ]
  rescue Line::Bot::V2::WebhookParser::InvalidSignatureError => e
    Rails.logger.warn("[LINE] Invalid signature: #{e.message}")
    [ client, [] ]
  end

  def process_follow_unfollow_event(event)
    auth = Authentication.find_by(provider: "line", uid: event.source.user_id)
    linked = event.is_a?(Line::Bot::V2::Webhook::FollowEvent)
    auth&.user&.update!(line_friend_linked: linked)
  end

  def process_message_event(event, client)
    return unless event.message.type == "text"
    user = Authentication.find_by(provider: "line", uid: event.source.user_id)&.user
    return unless user
    handle_message(user, event, client)
  end

  def handle_message(user, event, client)
    if SleepinessChecker.new(user).sleepy_time?
      reply_message = sleepy_reply_message
    else
      text = event.message.text
      reply_message = handle_text_message(user, text)
    end
    send_reply(event.reply_token, reply_message, client)
  end

  def sleepy_reply_message
    "ににに～・・・。\n----（訳）----\nおねむ～・・・。"
  end

  def handle_text_message(user, text)
    case text
    when /\A(?:ご飯|ごはん|ゴハン|食事|しょくじ|お食事|おしょくじ|飯|めし|メシ)(?:だよ|ですよ|だ|だぜ)?ー?[!！]?\z/
      handle_feed(user)
    when /\A(?:よしよし|よーしよーし|ヨシヨシ|ヨーシヨーシ|ﾖｼﾖｼ|ﾖｰｼﾖｰｼ|なでなで|なーでなーで|ナデナデ|ナーデナーデ|ﾅﾃﾞﾅﾃﾞ|ﾅｰﾃﾞﾅｰﾃﾞ)[!！]?\z/
      handle_pet(user)
    when "35894421"
      handle_change_image(user)
    else
      default_reply
    end
  end

  def handle_feed(user)
    user.play_state.line_apply_automatic_update!
    status = user.user_status.reload

    if status.hunger_value <= 70
      status.update!(hunger_value: [ status.hunger_value + 40, 100 ].min)
      status.update!(vitality:     [ status.vitality + 1, 99_999_999 ].min)
      "にー！ににーにー！\nににににー！\n----（訳）----\nわーい！ごはんだー！\nありがとう！"
    else
      "ににー！\nんににに～！\n----（訳）----\nうー！\n今はお腹いっぱいだよー！"
    end
  end

  def handle_pet(user)
    user.play_state.line_apply_automatic_update!
    status = user.user_status.reload
    status.update!(love_value:      [ status.love_value + 10, 100 ].min)
    status.update!(happiness_value: [ status.happiness_value + 1, 99_999_999 ].min)
    "にー！\nにににーにー！\n----（訳）----\nわーい！\nうれしいなあ！"
  end

  def handle_change_image(user)
    user.update!(image_change: !user.image_change)
    "にに！にににーに！？\nにーににーに、んにーににににに！\nんににに、にににーに！\n----（訳）----\nあれ！どうしてそのコードを知ってるの！？\nゲーム中の画像データがさし変わるよ！\n戻したいときは同じコードを使ってね！"
  end

  def default_reply
    "んににー！にーににー！"
    replies = [
      "んににー！にーににー！",
      "にー！ににに！",
      "にに？にーにー！",
      "んに！ににに、んにー！",
      "にーに、んににににー！",
      "にににー！にーに！",
      "んにんに！にーにー！",
      "にーんにー・・・！ににに！",
      "にに！？にんにーに！",
      "にーにー、んににんに。",
      "にににー！にい！",
      "んににんにー！に！にーに！"
    ]
    replies.sample
  end

  def send_reply(reply_token, reply_message, client)
    reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(reply_token: reply_token, messages: [ Line::Bot::V2::MessagingApi::TextMessage.new(text: reply_message) ])
    client.reply_message(reply_message_request: reply_req)
  end
end
