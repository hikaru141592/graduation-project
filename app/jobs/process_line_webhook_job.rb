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
    [client, events]
  rescue Line::Bot::V2::WebhookParser::InvalidSignatureError => e
    Rails.logger.warn("[LINE] Invalid signature: #{e.message}")
    [client, [ ]]
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
    if sleepy_time?(user)
      reply_message = sleepy_reply_message
    else
      text = event.message.text
      reply_message = handle_text_message(user, text)
    end
    send_reply(event.reply_token, reply_message, client)
  end

  def sleepy_time?(user)
    if definitely_asleep?
      true
    elsif possibility_of_slept?
      handle_possibility_of_slept(user)
    elsif possibility_of_not_awake?
      handle_possibility_of_not_awake(user)
    else
      false
    end
  end

  def definitely_asleep?
    definitely_slept? && definitely_not_awake?(Time.current)
  end

  def definitely_slept?
    Time.current.hour > 1 || (Time.current.hour == 1 && Time.current.min >= 58)
  end

  def definitely_not_awake?(time)
    time.hour < 6 || (time.hour == 6 && time.min < 38)
  end

  def possibility_of_slept?
    possibility_of_slept_start?(Time.current) || possibility_of_slept_end?
  end

  def possibility_of_slept_start?(time)
    time.hour > 22 || (time.hour == 22 && time.min >= 14)
  end

  def possibility_of_slept_end?
    !definitely_slept?
  end

  def possibility_of_not_awake?
    possibility_of_not_awake_start?(Time.current) && possibility_of_not_awake_end?
  end

  def possibility_of_not_awake_start?(time)
    !definitely_not_awake?(time)
  end

  def possibility_of_not_awake_end?
    Time.current.hour < 8 || (Time.current.hour == 8 && Time.current.min < 53)
  end

  def handle_possibility_of_slept(user)
    if before_midnight?
      handle_before_midnight(user)
    else
      handle_after_midnight(user)
    end
  end

  def before_midnight?
    Time.current.hour >= 12
  end

  def handle_before_midnight(user)
    if play_state_updated_tonight?(user)
      handle_asleep_or_awake(user)
    else
      false
    end
  end

  def play_state_updated_tonight?(user)
    updated_time = user.play_state.updated_at
    updated_time.to_date == Date.current && possibility_of_slept_start?(updated_time)
  end

  def handle_asleep_or_awake(user)
    category_name = user.play_state.current_event.event_set.event_category.name
    %w[寝ている 寝かせた].include?(category_name)
  end

  def handle_after_midnight(user)
    if play_state_updated_last_night?(user)
      handle_asleep_or_awake(user)
    else
      false
    end
  end

  def play_state_updated_last_night?(user)
    updated_time = user.play_state.updated_at
    updated_time.to_date == Date.current || (updated_time.to_date == (Date.current - 1) && possibility_of_slept_start?(updated_time))
  end

  def handle_possibility_of_not_awake(user)
    updated_time = user.play_state.updated_at
    if updated_time.to_date == Date.current && possibility_of_not_awake_start?(updated_time)
      handle_asleep_or_awake(user)
    else
      true
    end
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
    else
      default_reply
    end
  end

  def handle_feed(user)
    status = user.user_status
    if status.hunger_value <= 70
      status.update!(hunger_value: [ status.hunger_value + 40, 100 ].min)
      "にー！ににーにー！\nににににー！\n----（訳）----\nわーい！ごはんだー！\nありがとう！"
    else
      "ににー！\nんににに～！\n----（訳）----\nうー！\n今はお腹いっぱいだよー！"
    end
  end

  def handle_pet(user)
    status = user.user_status
    status.update!(love_value: [ status.love_value + 10, 100 ].min)
    "にー！\nにににーにー！\n----（訳）----\nわーい！\nうれしいなあ！"
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
    reply_req = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(reply_token: reply_token, messages: [Line::Bot::V2::MessagingApi::TextMessage.new(text: reply_message)])
    client.reply_message(reply_message_request: reply_req)
  end
end
