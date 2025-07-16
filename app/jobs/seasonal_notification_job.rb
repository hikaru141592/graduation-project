require 'line/bot'

class SeasonalNotificationJob < ApplicationJob
  queue_as :default

  def perform
    today = Date.current

    start_date = Date.new(today.year, 7, 1)
    end_date   = Date.new(today.year, 9, 15)

    return unless (start_date..end_date).cover?(today)

    text_message = Line::Bot::V2::MessagingApi::TextMessage.new(
      text: 'もう夏だね！暑いときは扇風機の風にでもあたって気持ちよくなりたいなあ！熱中症には気を付けてね！'
    )

    User.where(line_notifications_enabled: true)
        .joins(:authentications)
        .where(authentications: { provider: 'line' })
        .pluck('authentications.uid')
        .each do |uid|
      line_client.push_message(uid, message)
      push_req = Line::Bot::V2::MessagingApi::PushMessageRequest.new(to: uid, messages: [text_message])
      line_client.push_message(push_message_request: push_req)
    end

    uids.each do |uid|  
    end

    Rails.logger.info "[SeasonalNotificationJob] #{today}の通知を完了しました。"
  end

  private

  def line_client
    @line_client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV.fetch('LINE_CHANNEL_TOKEN')
    )
  end
end
