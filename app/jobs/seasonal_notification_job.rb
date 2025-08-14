require "line/bot"

class SeasonalNotificationJob < ApplicationJob
  queue_as :default

  BALL_PLAY_MESSAGE   = "にににー、ににに！\nにににににー、にっににに、んににに！\nににー、んにににー！\n----（訳）----\n最近はボール遊びにハマってるよ！\nなかなかうまくキャッチできないときもあるけど、そっちだよって言ってくれるときれいにとれるんだ！\nもっと練習しよー！"
  BOOK_MESSAGE        = "にににーにににーに？\nににににーににーにに！\nんにににににに、んににに、んににににに！\nにににに、にーにににー！\n----（訳）----\n君は読書って好きー？\n僕は大好きだよー！\nこの先どんな展開が待ってるんだろうとか、登場人物は今どんな気持ちなんだろうとかいろいろ考えちゃうよね！\n今日もお気に入りの本を読むんだあ！"
  SANSU_MESSAGE       = "にににーにーににに！\nにーにに、にににーにに、にににーんにににに！\nにーに、にーにににににーに！\n----（訳）----\n僕は最近算数の勉強を頑張ってるんだ！\n計算ミスしちゃうこともあるけど、少しずつ早く計算できるようになってるんだよ！\n今日は何問解こうかなあ！"
  OEKAKI_MESSAGE      = "ににに、にーにに、んににに！\nにっににににーに、ににーに、んににーにににに～！\nにに、にににーにににーに、んにににに！\n----（訳）----\nこの前いい絵が描けたんだ！\n絵って難しいよね、ひらめくときとひらめかないときがあるんだよね～。\nでもいっぱい描いていれば、そのうちまたいい絵が描けるよね！"
  BLOCK_TOY_MESSAGE   = "にーに！んにっに、にににーんにににに！\nににに、んにっににににーににににーにーにに、にーにーににに、んにににに！\n----（訳）----\nねえね！ブロックのおもちゃをたくさんつみあげられたんだ！\n僕はブロックのおもちゃで遊んでいるときは集中してるからね、そういうときは邪魔をしちゃだめだよ！"

  TAMAMON_MESSAGE     = "にににーににに？\nんににに、にににににー！\nにーにに、にににーにー！\n----（訳）----\n君は好きなテレビ番組ってあるー？\n僕は毎週月曜日の19時からやってる「タマモン」が好きだよ！\n毎週楽しみなんだー！"
  NIWATORIBIA_MESSAGE = "にににーににに？\nんににに、にににににー！\nにーにに、にににーにー！\n----（訳）----\n君は好きなテレビ番組ってあるー？\n僕は毎週水曜日の20時からやってる「ニワトリビアの湖」が好きだよ！\n毎週楽しみなんだー！"
  TAMAEMON_MESSAGE    = "にににーににに？\nんににに、にににににー！\nにーにに、にににーにー！\n----（訳）----\n君は好きなテレビ番組ってあるー？\n僕は毎週金曜日の19時からやってる「タマえもん」が好きだよ！\n毎週楽しみなんだー！"

  KOTATSU_MESSAGE_1   = "ににんにに！\nにににー、にーににに～！\nにににに、んににーにに！\n----（訳）----\n最近だいぶ寒くなってきたね！\n冬と言ったらやっぱこたつだよね～！\nこたつの中でみかんを食べるのが好きなんだ！"
  KOTATSU_MESSAGE_2   = "ににー！\nにーにに、にににーに～！\nににに、んにににに～！\n----（訳）----\n今日も寒ーい！\nこんなに寒いとおうちから出られないよ～！\n今日もこたつでゆっくり過ごそうかな～！"
  HANAMI_MESSAGE      = "ににににんにに！\nにににに、んににに～！\nにににー、にににーに！\n----（訳）----\nそろそろ春が来るね！\n今年もお花見いけるかな～！\nきれいな桜が見れたらいいな！"
  SHINGAKKI_MESSAGE   = "ににに！\nんにに、にににー！\nにーにににににー！\n----（訳）----\n今日から新学期！\n何か新しい出会いが待ってるかもー！\n今年度も頑張っていこうね！"
  SENPUKI_MESSAGE     = "ににー！\nんににー、にににーにににい！\nにににー、んにににに！\n----（訳）----\nもう夏だね！\n暑いときは扇風機の風にでもあたって気持ちよくなりたいなあ！\n熱中症には気を付けてね！"
  SUICA_MESSAGE       = "ににに～！\nににんにに、にににににーに！\nにににんににに～！\n----（訳）----\n暑い日が続くね～！\n水分補給もだいじだけど、冷たいおやつを食べるのもいいと思うよ！\n僕はスイカが食べたいなあ！"
  KOYO_MESSAGE        = "にににー、んににに！\nんににに、にににー、ににんにに！\nにーにに、んににに～！\n----（訳）----\n秋って好きなんだあ！\n読書もしたいしスポーツもいいけど、やっぱ紅葉だよね！\n今年は見に行けるかな～！"

  NEGOTO_MESSAGE      = "ににに、ににに～・・・。\n----（訳）----\nむにゃむにゃ、もう食べられないよ～・・・。（寝言）"

  SCHEDULE = {
    "1-10-11"  => BALL_PLAY_MESSAGE,
    "1-22-14"  => BLOCK_TOY_MESSAGE,
    "1-29-17"  => TAMAMON_MESSAGE,
    "2-3-13"   => KOTATSU_MESSAGE_2,
    "2-24-17"  => NIWATORIBIA_MESSAGE,
    "3-9-15"   => OEKAKI_MESSAGE,
    "3-16-9"   => HANAMI_MESSAGE,
    "4-1-8"    => SHINGAKKI_MESSAGE,
    "4-21-4"   => NEGOTO_MESSAGE,
    "5-4-11"   => SANSU_MESSAGE,
    "5-19-18"  => TAMAMON_MESSAGE,
    "6-6-11"   => BOOK_MESSAGE,
    "6-15-14"  => BLOCK_TOY_MESSAGE,
    "6-25-19"  => NIWATORIBIA_MESSAGE,
    "7-1-9"    => SENPUKI_MESSAGE,
    "7-22-17"  => TAMAEMON_MESSAGE,
    "7-25-14"  => BALL_PLAY_MESSAGE,
    "8-10-13"  => SUICA_MESSAGE,
    "8-28-15"  => OEKAKI_MESSAGE,
    "9-4-17"   => NIWATORIBIA_MESSAGE,
    "9-15-3"   => NEGOTO_MESSAGE,
    "9-30-16"  => BLOCK_TOY_MESSAGE,
    "10-10-10" => SANSU_MESSAGE,
    "11-1-9"   => KOYO_MESSAGE,
    "11-13-17" => TAMAMON_MESSAGE,
    "12-4-14"  => BOOK_MESSAGE,
    "12-16-9"  => KOTATSU_MESSAGE_1,
    "12-22-17" => TAMAEMON_MESSAGE
  }.freeze

  def perform
    now = Time.zone.now
    key = now.strftime("%-m-%-d-%-H")
    text = SCHEDULE[key]
    return unless text

    text_message = Line::Bot::V2::MessagingApi::TextMessage.new(
      text:)

    User.where(line_notifications_enabled: true, line_friend_linked: true)
        .joins(:authentications)
        .where(authentications: { provider: "line" })
        .pluck("authentications.uid")
        .each do |uid|
      push_req = Line::Bot::V2::MessagingApi::PushMessageRequest.new(to: uid, messages: [ text_message ])
      line_client.push_message(push_message_request: push_req)
    end

    Rails.logger.info "[SeasonalNotificationJob] #{key}の通知を完了しました。"
  end

  private

  def line_client
    @line_client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV.fetch("LINE_CHANNEL_TOKEN")
    )
  end
end
