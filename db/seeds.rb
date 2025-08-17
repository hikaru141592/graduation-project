module Seeds
  module_function
  def always          = { "always" => true }.freeze
  def prob(p)         = { "type" => "probability", "percent" => p }.freeze
  def prob_only(p)    = { "operator" => "and", "conditions" => [prob(p)] }.freeze
  def status(a, o, v) = { "type" => "status", "attribute" => a, "operator" => o, "value" => v }.freeze
  def off_fm(add, mult, mod) = { "add" => add, "mult" => mult, "mod" => mod, "target" => "from_min" }.freeze
  def off_tm(add, mult, mod) = { "add" => add, "mult" => mult, "mod" => mod, "target" => "to_min"   }.freeze
  def time_range(fh, fm, th, tm, offsets = nil)
    h = {
      "type"      => "time_range",
      "from_hour" => fh, "from_min" => fm,
      "to_hour"   => th, "to_min"   => tm
    }
    h["offsets_by_day"] = offsets if offsets.present?
    h
  end
  def weekday(array)              = { "type" => "weekday", "value" => array }.freeze
  def date_range(fm, fd, tm, td)  = { "type" => "date_range", "from" => { "month" => fm, "day" => fd }, "to" => { "month" => tm, "day" => td } }
  def and_(*conditions)           = { "operator" => "and", "conditions" => conditions }
  def or_(*conditions)            = { "operator" => "or", "conditions" => conditions }
  def effects_status(*pairs)      = { "status" => pairs.map { |attr, delta| { "attribute" => attr.to_s, "delta" => delta } } }
  def set_deriv(set, deriv = 0)                 = { event_set_name: set, derivation_number: deriv}
  def ar_key(set, deriv, label, prio = 1)       = { event_set_name: set, derivation_number: deriv, label: label, priority: prio }
  def cut_key(ar_key, pos = 1)                  = { **ar_key, position: pos }

  def s_l(set_deriv, label = 'すすむ')  = { **set_deriv, labels: [ label ] }
  def next_ev(deriv: nil, call: nil, resolve: false)
    {
      next_derivation_number: deriv,
      calls_event_set_name:   call,
      resolves_loop:          resolve
    }.freeze
  end
  def image_set(char, bg = "temp-background.png") = { character_image: "temp-character/#{char}", background_image:  "temp-background/#{bg}" }

  def run!
    categories = [
      { name: 'イントロ', description: 'イントロ',                                        loop_minutes: nil  },
      { name: '通常',     description: '何か言っている、何かしたそう',                         loop_minutes: nil  },
      { name: '暇そう',     description: 'ボーっとしている、ニコニコしている、ゴロゴロしている', loop_minutes: nil  },
      { name: 'ルンルン', description: '踊っている',                                           loop_minutes: 3   },
      { name: '泣いている', description: '泣いている(空腹)、泣いている(よしよし不足)、泣いている(ランダム)', loop_minutes: 20 },
      { name: '怒っている', description: '怒っている',                                         loop_minutes: 20   },
      { name: '夢中',     description: 'ブロックのおもちゃに夢中、マンガに夢中',               loop_minutes: 10  },
      { name: '眠そう',   description: '眠そう',                                               loop_minutes: 12   },
      { name: '寝ている', description: '寝ている',                                             loop_minutes: 5   },
      { name: '寝かせた', description: '寝かせた',                                             loop_minutes: 240   },
      { name: '寝起き',   description: '寝起き',                                             loop_minutes: 15   },
      { name: '占い',     description: '占い',                                               loop_minutes: nil   },
      { name: 'テレビ',   description: 'テレビ',                                             loop_minutes: 15   },
      { name: '扇風機',   description: '扇風機',                                             loop_minutes: 10   },
      { name: 'こたつ',   description: 'こたつ',                                             loop_minutes: 10   },
      { name: '花見',     description: '花見',                                               loop_minutes: nil   },
      { name: '紅葉',     description: '紅葉',                                               loop_minutes: nil   },
      { name: '年始',     description: '年始',                                               loop_minutes: nil   },
      { name: '算数',     description: '算数',                                               loop_minutes: nil   },
      { name: 'ボール遊び', description: 'ボール遊び',                                        loop_minutes: nil   },
      { name: '特訓',     description: '特訓',                                               loop_minutes: nil   },
      { name: '誕生日',    description: '誕生日',                                             loop_minutes: nil   },
      { name: 'ゲーム',    description: 'ゲーム',                                             loop_minutes: 30   }
    ]

    categories.each do |attrs|
      category = EventCategory.find_or_initialize_by(name: attrs[:name])
      category.description  = attrs[:description]
      category.loop_minutes = attrs[:loop_minutes]
      category.save!
    end

    event_sets = [
      { category_name: 'イントロ', name: 'イントロ' },
      { category_name: '通常',      name: '何か言っている' },
      { category_name: '通常',      name: '何かしたそう' },
      { category_name: '暇そう',    name: 'ボーっとしている' },
      { category_name: '暇そう',    name: 'ニコニコしている' },
      { category_name: '暇そう',    name: 'ゴロゴロしている' },
      { category_name: 'ルンルン',  name: '踊っている' },
      { category_name: '泣いている', name: '泣いている(空腹)' },
      { category_name: '泣いている', name: '泣いている(よしよし不足)' },
      { category_name: '泣いている', name: '泣いている(ランダム)' },
      { category_name: '怒っている', name: '怒っている' },
      { category_name: '夢中',      name: 'ブロックのおもちゃに夢中' },
      { category_name: '夢中',      name: 'マンガに夢中' },
      { category_name: '眠そう',    name: '眠そう' },
      { category_name: '寝ている',  name: '寝ている' },
      { category_name: '寝かせた',  name: '寝かせた' },
      { category_name: '寝起き',    name: '寝起き' },
      { category_name: '占い',      name: '占い' },
      { category_name: 'テレビ',      name: 'タマモン' },
      { category_name: 'テレビ',      name: 'タマえもん' },
      { category_name: 'テレビ',      name: 'ニワトリビアの湖' },
      { category_name: '扇風機',      name: '扇風機' },
      { category_name: 'こたつ',      name: 'こたつ' },
      { category_name: '花見',        name: '花見' },
      { category_name: '紅葉',        name: '紅葉' },
      { category_name: '年始',        name: '年始' },
      { category_name: '算数',      name: '算数' },
      { category_name: 'ボール遊び', name: 'ボール遊び' },
      { category_name: '特訓',      name: '特訓' },
      { category_name: '誕生日',     name: '誕生日' },
      { category_name: 'ゲーム',     name: 'タマモンカート' }
    ]

    event_sets.each do |attrs|
      category = EventCategory.find_by!(name: attrs[:category_name])
      set = EventSet.find_or_initialize_by(
        event_category: category,
        name:          attrs[:name]
      )
      set.trigger_conditions = always
      set.save!
    end

    event_set_conditions = [
      {
        name: '泣いている(空腹)',
        trigger_conditions: and_(status("hunger_value", "<=", 5))
      },
      {
        name: '泣いている(よしよし不足)',
        trigger_conditions: and_(status("love_value", "<=", 40))
      },
      {
        name: '泣いている(ランダム)',
        trigger_conditions: prob_only(3)
      },
      {
        name: '踊っている',
        trigger_conditions: and_(status("mood_value", ">=", 80))
      },
      {
        name: 'ボーっとしている',
        trigger_conditions: prob_only(15)
      },
      {
        name: 'ニコニコしている',
        trigger_conditions: prob_only(9)
      },
      {
        name: 'ゴロゴロしている',
        trigger_conditions: prob_only(9)
      },
      {
        name: '何かしたそう',
        trigger_conditions: prob_only(50)
      },
      {
        name: '何か言っている',
        trigger_conditions: always
      },
      {
        name: '寝ている',
        trigger_conditions: and_(time_range(0, 46, 6, 38, [ off_fm(43, 17, 60), off_tm(27, 19, 60) ]))
      },
      {
        name: 'ブロックのおもちゃに夢中',
        daily_limit: 1,
        trigger_conditions: and_(prob(100), time_range(11, 0, 14, 0, [ off_fm(11, 77, 300), off_tm(11, 77, 300) ]), status("sports_value", ">=", 2))
      },
      {
        name: 'マンガに夢中',
        trigger_conditions: and_(prob(5), time_range(10, 0, 23, 30, [ off_fm(4, 7, 30) ]), status("sports_value", ">=", 2))
      },
      {
        name: '眠そう',
        trigger_conditions: and_(time_range(22, 14, 2, 0, [ off_fm(14, 43, 60), off_fm(5, 17, 60) ]))
      },
      {
        name: '寝かせた',
        trigger_conditions: prob_only(0)
      },
      {
        name: '寝起き',
        daily_limit: 1,
        trigger_conditions: and_(time_range(6, 38, 7, 38, [ off_fm(27, 19, 60), off_tm(27, 19, 60) ]))
      },
      {
        name: '占い',
        daily_limit: 1,
        trigger_conditions: and_(time_range(6, 0, 11, 0), prob(33))
      },
      {
        name: 'タマモン',
        daily_limit: 1,
        trigger_conditions: and_(time_range(19, 0, 20, 0), weekday([ 1 ]), status("sports_value", ">=", 2))
      },
      {
        name: 'タマえもん',
        daily_limit: 1,
        trigger_conditions: and_(time_range(19, 0, 20, 0), weekday([ 5 ]), status("sports_value", ">=", 2))
      },
      {
        name: 'ニワトリビアの湖',
        daily_limit: 1,
        trigger_conditions: and_(time_range(20, 0, 21, 0), weekday([ 3 ]), status("sports_value", ">=", 2))
      },
      {
        name: '扇風機',
        daily_limit: 2,
        trigger_conditions: and_(time_range(11, 0, 17, 0, [ off_fm(27, 4, 15), off_tm(27, 4, 15) ]),
                            date_range(7, 1, 9, 15), prob(25), status("sports_value", ">=", 2))
      },
      {
        name: 'こたつ',
        daily_limit: 2,
        trigger_conditions: and_(time_range(11, 0, 21, 30, [ off_fm(27, 4, 15), off_tm(27, 4, 15) ]),
                            date_range(12, 16, 3, 15), prob(25), status("sports_value", ">=", 2))
      },
      {
        name: '花見',
        daily_limit: 1,
        trigger_conditions: and_(time_range(10, 30, 16, 30, [ off_fm(27, 6, 15), off_tm(27, 51, 120) ]), date_range(3, 16, 4, 15), prob(30))
      },
      {
        name: '紅葉',
        daily_limit: 1,
        trigger_conditions: and_(time_range(10, 30, 16, 30, [ off_fm(27, 6, 15), off_tm(27, 51, 120) ]), date_range(11, 1, 12, 15), prob(25))
      },
      {
        name: '年始',
        daily_limit: 1,
        trigger_conditions: and_(date_range(1, 1, 1, 1))
      },
      {
        name: '怒っている',
        trigger_conditions: prob_only(0)
      },
      {
        name: '算数',
        trigger_conditions: prob_only(0)
      },
      {
        name: 'ボール遊び',
        trigger_conditions: prob_only(0)
      },
      {
        name: '特訓',
        trigger_conditions: prob_only(0)
      },
      {
        name: 'イントロ',
        trigger_conditions: prob_only(0)
      },
      {
        name: '誕生日',
        daily_limit: 1,
        trigger_conditions: prob_only(0)
      },
      {
        name: 'タマモンカート',
        trigger_conditions: prob_only(0)
      }
    ]

    event_set_conditions.each do |attrs|
      set = EventSet.find_by!(name: attrs[:name])
      set.update!(trigger_conditions: attrs[:trigger_conditions], daily_limit: attrs[:daily_limit])
    end

    events = [
      {
        event_set_name:    '何か言っている',
        name:              '何か言っている',
        derivation_number: 0,
        message:           '〈たまご〉がなにかいっているよ。',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    '何かしたそう',
        name:              'べんきょうする',
        derivation_number: 1,
        message:           'よし！なんのべんきょうをしよう？',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '何かしたそう',
        name:              '何かしたそう',
        derivation_number: 0,
        message:           '〈たまご〉はなにかしたそうだ。',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    '何かしたそう',
        name:              'ゲームさせてあげる？',
        derivation_number: 2,
        message:           '（30ぷんかん、かまってもらえなくなるけどいい？）',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    'ボーっとしている',
        name:              'ボーっとしている',
        derivation_number: 0,
        message:           '〈たまご〉はボーっとしている。',
        **image_set("temp-hidariwomiru.png")
      },
      {
        event_set_name:    'ニコニコしている',
        name:              'ニコニコしている',
        derivation_number: 0,
        message:           '〈たまご〉はニコニコしている。',
        **image_set("temp-suwatte-nikoniko.png")
      },
      {
        event_set_name:    'ゴロゴロしている',
        name:              'ゴロゴロしている',
        derivation_number: 0,
        message:           '〈たまご〉はゴロゴロしている。',
        **image_set("temp-gorogoro.png")
      },
      {
        event_set_name:    '踊っている',
        name:              '踊っている',
        derivation_number: 0,
        message:           '〈たまご〉はおどっている！',
        **image_set("temp-dance.png")
      },
      {
        event_set_name:    '泣いている(空腹)',
        name:              '泣いている(空腹)',
        derivation_number: 0,
        message:           '〈たまご〉がないている！',
        **image_set("temp-naku.png")
      },
      {
        event_set_name:    '泣いている(よしよし不足)',
        name:              '泣いている(よしよし不足)',
        derivation_number: 0,
        message:           '〈たまご〉がないている！',
        **image_set("temp-naku.png")
      },
      {
        event_set_name:    '泣いている(ランダム)',
        name:              '泣いている(ランダム)',
        derivation_number: 0,
        message:           '〈たまご〉がないている！',
        **image_set("temp-naku.png")
      },
      {
        event_set_name:    '怒っている',
        name:              '怒っている',
        derivation_number: 0,
        message:           '〈たまご〉はおこっている！',
        **image_set("temp-okoru.png")
      },
      {
        event_set_name:    '寝ている',
        name:              '寝ている',
        derivation_number: 0,
        message:           '〈たまご〉はねている。',
        **image_set("temp-sleep.png")
      },
      {
        event_set_name:    'ブロックのおもちゃに夢中',
        name:              'ブロックのおもちゃに夢中',
        derivation_number: 0,
        message:           '〈たまご〉はブロックのおもちゃにむちゅうだ。',
        **image_set("temp-building_blocks.png")
      },
      {
        event_set_name:    'マンガに夢中',
        name:              'マンガに夢中',
        derivation_number: 0,
        message:           '〈たまご〉はマンガをよんでいる。',
        **image_set("temp-comics.png")
      },
      {
        event_set_name:    '眠そう',
        name:              '眠そう',
        derivation_number: 0,
        message:           '〈たまご〉はねむそうにしている。',
        **image_set("temp-sleepy.png")
      },
      {
        event_set_name:    '寝かせた',
        name:              '寝かせた',
        derivation_number: 0,
        message:           '〈たまご〉はねている。',
        **image_set("temp-sleep.png")
      },
      {
        event_set_name:    '寝かせた',
        name:              '寝かせた（ゴミ箱なし）',
        derivation_number: 1,
        message:           '〈たまご〉はねている。',
        **image_set("temp-sleep.png")
      },
      {
        event_set_name:    '寝起き',
        name:              '寝起き',
        derivation_number: 0,
        message:           '〈たまご〉がおきたようだ！',
        **image_set("temp-wakeup.png")
      },
      {
        event_set_name:    '寝起き',
        name:              '起こす、1回目の警告',
        derivation_number: 1,
        message:           'おきにいりのハードロックミュージックでもかけっちゃおっかなー？',
        **image_set("temp-wakeup.png")
      },
      {
        event_set_name:    '寝起き',
        name:              '起こす、2回目の警告',
        derivation_number: 2,
        message:           'ほんとにかけるの？',
        **image_set("temp-wakeup.png")
      },
      {
        event_set_name:    '寝起き',
        name:              '起こす、3回目の警告',
        derivation_number: 3,
        message:           'ほんとにいいんですね？',
        **image_set("temp-wakeup.png")
      },
      {
        event_set_name:    '占い',
        name:              '占い',
        derivation_number: 0,
        message:           'テレビでうらないをやってる！',
        **image_set("temp-TV1.png")
      },
      {
        event_set_name:    'タマモン',
        name:              'タマモンがやっている',
        derivation_number: 0,
        message:           '〈たまご〉はタマモンがみたいらしい。どうする？',
        **image_set("temp-TV3.png")
      },
      {
        event_set_name:    'タマモン',
        name:              'タマモンを見ている',
        derivation_number: 1,
        message:           '〈たまご〉はタマモンをみている！',
        **image_set("temp-TV6.png")
      },
      {
        event_set_name:    'タマえもん',
        name:              'タマえもんがやっている',
        derivation_number: 0,
        message:           '〈たまご〉はタマえもんがみたいらしい。どうする？',
        **image_set("temp-TV3.png")
      },
      {
        event_set_name:    'タマえもん',
        name:              'タマえもんを見ている',
        derivation_number: 1,
        message:           '〈たまご〉はタマえもんをみている！',
        **image_set("temp-TV6.png")
      },
      {
        event_set_name:    'ニワトリビアの湖',
        name:              'ニワトリビアの湖がやっている',
        derivation_number: 0,
        message:           '〈たまご〉はニワトリビアのみずうみがみたいらしい。どうする？',
        **image_set("temp-TV3.png")
      },
      {
        event_set_name:    'ニワトリビアの湖',
        name:              'ニワトリビアの湖を見ている',
        derivation_number: 1,
        message:           '〈たまご〉はニワトリビアのみずうみをみている！',
        **image_set("temp-TV6.png")
      },
      {
        event_set_name:    '扇風機',
        name:              '扇風機',
        derivation_number: 0,
        message:           '〈たまご〉はすずんでいる！',
        **image_set("temp-senpuuki1.png")
      },
      {
        event_set_name:    'こたつ',
        name:              'こたつ',
        derivation_number: 0,
        message:           '〈たまご〉はこたつでヌクヌクしている！',
        **image_set("temp-kotatu1.png")
      },
      {
        event_set_name:    '花見',
        name:              '花見',
        derivation_number: 0,
        message:           '〈たまご〉はおはなみにいきたいみたい。',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    '紅葉',
        name:              '紅葉',
        derivation_number: 0,
        message:           '〈たまご〉はコウヨウをみにいきたいみたい。',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    '年始',
        name:              '年始',
        derivation_number: 0,
        message:           '〈たまご〉「にー！！」',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '算数',
        name:              '出題前',
        derivation_number: 0,
        message:           'よし、さんすうのもんだいにちょうせんだ！',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '算数',
        name:              '1つ目が正解',
        derivation_number: 1,
        message:           '「X 演算子 Y」のこたえは？',
        **image_set("temp-kangaeru.png")
      },
      {
        event_set_name:    '算数',
        name:              '2つ目が正解',
        derivation_number: 2,
        message:           '「X 演算子 Y」のこたえは？',
        **image_set("temp-kangaeru.png")
      },
      {
        event_set_name:    '算数',
        name:              '3つ目が正解',
        derivation_number: 3,
        message:           '「X 演算子 Y」のこたえは？',
        **image_set("temp-kangaeru.png")
      },
      {
        event_set_name:    '算数',
        name:              '4つ目が正解',
        derivation_number: 4,
        message:           '「X 演算子 Y」のこたえは？',
        **image_set("temp-kangaeru.png")
      },
      {
        event_set_name:    'ボール遊び',
        name:              '投球前',
        derivation_number: 0,
        message:           'ボールなげるよー！',
        **image_set("temp-ball1.png")
      },
      {
        event_set_name:    'ボール遊び',
        name:              '投球',
        derivation_number: 1,
        message:           'ブンッ！',
        **image_set("temp-ball2.png")
      },
      {
        event_set_name:    'ボール遊び',
        name:              '左が成功',
        derivation_number: 2,
        message:           'ボールをなげた！〈たまご〉、そっちだ！',
        **image_set("temp-ball3.png")
      },
      {
        event_set_name:    'ボール遊び',
        name:              '真ん中が成功',
        derivation_number: 3,
        message:           '〈たまご〉、そっちだ！',
        **image_set("temp-ball3.png")
      },
      {
        event_set_name:    'ボール遊び',
        name:              '右が成功',
        derivation_number: 4,
        message:           '〈たまご〉、そっちだ！',
        **image_set("temp-ball3.png")
      },
      {
        event_set_name:    '特訓',
        name:              '特訓',
        derivation_number: 0,
        message:           'なんのとっくんをしよう？',
        **image_set("temp-kangaeru.png")
      },
      {
        event_set_name:    '特訓',
        name:              '特訓終了',
        derivation_number: 1,
        message:           'ここまで！',
        **image_set("temp-tukareta.png")
      },
      {
        event_set_name:    '特訓',
        name:              '特訓結果優秀',
        derivation_number: 2,
        message:           '20もんちゅう〈X〉もんせいかい！〈Y〉分〈Z〉秒クリア！すごいね！',
        **image_set("temp-nikoniko.png")
      },
      {
        event_set_name:    '特訓',
        name:              '特訓結果良し',
        derivation_number: 3,
        message:           '20もんちゅう〈X〉もんせいかい！よくがんばったね！',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '特訓',
        name:              '特訓結果微妙',
        derivation_number: 4,
        message:           '20もんちゅう〈X〉もんせいかい！またちょうせんしよう！',
        **image_set("temp-bimuyou.png")
      },
      {
        event_set_name:    '特訓',
        name:              'ボール遊び特訓結果良し',
        derivation_number: 5,
        message:           '〈X〉かいせいこう！よくがんばったね！',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '特訓',
        name:              'ボール遊び特訓結果微妙',
        derivation_number: 6,
        message:           '〈X〉かいせいこう！またちょうせんしよう！',
        **image_set("temp-bimuyou.png")
      },
      {
        event_set_name:    'イントロ',
        name:              'イントロ開始',
        derivation_number: 0,
        message:           'よくきた！まちくたびれたぞ！',
        **image_set("temp-hiyoko-magao.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              'かっこいい？',
        derivation_number: 1,
        message:           'かっこいいだろ！',
        **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              'そんなことはさておき',
        derivation_number: 2,
        message:           'まあ、そんなことはさておきだな。',
        **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              'たまごのなまえ',
        derivation_number: 3,
        message:           '〈たまご〉、だったな！',
        **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              'たまごのかいせつ',
        derivation_number: 4,
        message:           '〈たまご〉はとってもなきむしだ。',
        **image_set("temp-hiyoko-magao.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              '声かけ1回目',
        derivation_number: 5,
        message:           '〈たまご〉！',
        **image_set("temp-normal.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              '声かけ2回目',
        derivation_number: 6,
        message:           'もういちどこえをかけてみよう！',
        **image_set("temp-normal.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              '声かけ3回目',
        derivation_number: 7,
        message:           'ぜんぜんしゃべってくれない！',
        **image_set("temp-normal.png", "temp-in-house.png")
      },
      {
        event_set_name:    '誕生日',
        name:              '誕生日',
        derivation_number: 0,
        message:           '〈たまご〉「にー！」',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '誕生日',
        name:              'どういう一年にする？',
        derivation_number: 1,
        message:           '「これからのいちねん、どうすごしたい？」ってきいてるよ。',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    'タマモンカート',
        name:              'タマモンカート',
        derivation_number: 0,
        message:           '〈たまご〉はゲーム『タマモンカート』であそんでいる！',
        **image_set("temp-game-nikoniko.png")
      }
    ]

    events.each do |attrs|
      set = EventSet.find_by!(name: attrs[:event_set_name])
      event = Event.find_or_initialize_by(
        event_set:         set,
        derivation_number: attrs[:derivation_number]
      )
      event.name             = attrs[:name]
      event.message          = attrs[:message]
      event.character_image  = attrs[:character_image]
      event.background_image = attrs[:background_image]
      event.save!
    end

    choices = [
      { **set_deriv('何か言っている'),          labels: [ 'はなしをきいてあげる', 'よしよしする', 'おやつをあげる', 'ごはんをあげる' ] },
      { **set_deriv('何かしたそう'),            labels: [ 'ボールあそびをする',   'べんきょうする',   'おえかきする',     'ゲームする' ] },
      { **set_deriv('何かしたそう', 2),         labels: [ 'ゲームさせてあげる',   'やっぱやめよう' ] },
      { **set_deriv('ボーっとしている'),        labels: [ 'ながめている',   'こえをかける' ] },
      s_l(set_deriv('ニコニコしている'), 'ながめている'),
      s_l(set_deriv('ゴロゴロしている'), 'ながめている'),
      { **set_deriv('何かしたそう', 1),         labels: [ 'さんすう',   'こくご',   'りか',     'しゃかい' ] },
      { **set_deriv('踊っている'),              labels: [ 'よしよしする',       'おやつをあげる',   'ごはんをあげる' ] },
      { **set_deriv('泣いている(空腹)'),        labels: [ 'よしよしする',       'おやつをあげる',   'ごはんをあげる',   'あそんであげる' ] },
      { **set_deriv('泣いている(よしよし不足)'), labels: [ 'よしよしする',       'おやつをあげる',   'ごはんをあげる',   'あそんであげる' ] },
      { **set_deriv('泣いている(ランダム)'),     labels: [ 'よしよしする',       'おやつをあげる',   'ごはんをあげる',   'あそんであげる' ] },
      { **set_deriv('寝ている'),                labels: [ 'そっとする',        'よしよしする',     'たたきおこす' ] },
      { **set_deriv('ブロックのおもちゃに夢中'), labels: [ 'そっとする',       'よしよしする',   'ちょっかいをだす',   'ブロックをくずす' ] },
      { **set_deriv('マンガに夢中'),            labels: [ 'そっとする',       'よしよしする',   'はなしかける',   'マンガをとりあげる' ] },
      { **set_deriv('眠そう'),                  labels: [ 'ねかせる',         'よしよしする',   'はみがきをさせる', 'ダジャレをいう' ] },
      { **set_deriv('寝かせた'),                labels: [ 'そっとする',        'よしよしする',     'たたきおこす',     'ゴミばこのなかをのぞく' ] },
      { **set_deriv('寝かせた', 1),             labels: [ 'そっとする',        'よしよしする',     'たたきおこす' ] },
      { **set_deriv('寝起き'),                  labels: [ 'そっとする',        'よしよしする',     'きがえさせる',     'ばくおんをながす' ] },
      { **set_deriv('寝起き', 1),               labels: [ 'かけちゃう',        'やめておく' ] },
      { **set_deriv('寝起き', 2),               labels: [ 'はい',              'やっぱやめておく' ] },
      { **set_deriv('寝起き', 3),               labels: [ 'はい',              'いいえ' ] },
      s_l(set_deriv('占い')),
      { **set_deriv('タマモン'),                labels: [ 'みていいよ',         'みさせてあげない' ] },
      s_l(set_deriv('タマモン', 1), 'いっしょにみる' ),
      { **set_deriv('タマえもん'),              labels: [ 'みていいよ',         'みさせてあげない' ] },
      s_l(set_deriv('タマえもん', 1), 'いっしょにみる'),
      { **set_deriv('ニワトリビアの湖'),         labels: [ 'みていいよ',         'みさせてあげない' ] },
      s_l(set_deriv('ニワトリビアの湖', 1), 'いっしょにみる'),
      { **set_deriv('扇風機'),                  labels: [ 'よしよしする',       'スイカをあげる',   'せんぷうきをとめる',   'そっとする' ] },
      { **set_deriv('こたつ'),                  labels: [ 'よしよしする',       'ミカンをあげる',    'こたつをとめる',      'そっとする' ] },
      { **set_deriv('花見'),                    labels: [ 'つれていく',       'いかない' ] },
      { **set_deriv('紅葉'),                    labels: [ 'つれていく',       'いかない' ] },
      s_l(set_deriv('年始')),
      { **set_deriv('怒っている'),               labels: [ 'よしよしする',       'おやつをあげる',   'へんがおをする',   'あやまる' ] },
      s_l(set_deriv('算数')),
      { **set_deriv('算数', 1),                 labels: [ '〈A〉', '〈B〉', '〈C〉', '〈D〉' ] },
      { **set_deriv('算数', 2),                 labels: [ '〈B〉', '〈A〉', '〈C〉', '〈D〉' ] },
      { **set_deriv('算数', 3),                 labels: [ '〈B〉', '〈C〉', '〈A〉', '〈D〉' ] },
      { **set_deriv('算数', 4),                 labels: [ '〈B〉', '〈C〉', '〈D〉', '〈A〉' ] },
      s_l(set_deriv('ボール遊び')),
      s_l(set_deriv('ボール遊び', 1), 'ぜんりょくとうきゅう'),
      { **set_deriv('ボール遊び', 2),            labels: [ 'ひだりだ！', 'そこだ！', 'みぎだ！' ] },
      { **set_deriv('ボール遊び', 3),            labels: [ 'ひだりだ！', 'そこだ！', 'みぎだ！' ] },
      { **set_deriv('ボール遊び', 4),            labels: [ 'ひだりだ！', 'そこだ！', 'みぎだ！' ] },
      { **set_deriv('特訓'),                     labels: [ 'さんすう', 'ボールあそび', 'やっぱやめておく' ] },
      s_l(set_deriv('特訓', 1)),
      s_l(set_deriv('特訓', 2)),
      s_l(set_deriv('特訓', 3)),
      s_l(set_deriv('特訓', 4)),
      s_l(set_deriv('特訓', 5)),
      s_l(set_deriv('特訓', 6)),

      s_l(set_deriv('イントロ')),
      { **set_deriv('イントロ', 1),             labels: [ 'えっ？', 'まさか！', 'うーん', 'かっこいいです' ] },
      s_l(set_deriv('イントロ', 2)),
      { **set_deriv('イントロ', 3),             labels: [ 'いいなまえ！', 'ちゃんをつけて！', 'くんをつけて！', 'さまをつけて！' ] },
      s_l(set_deriv('イントロ', 4)),
      { **set_deriv('イントロ', 5),             labels: [ 'こんにちは！', 'なかよくしてね！' ] },
      { **set_deriv('イントロ', 6),             labels: [ 'よっ！',       'なかよくたのむぜ！' ] },
      { **set_deriv('イントロ', 7),             labels: [ 'こんにちは！', 'なかよくしてね！', 'よしよし' ] },

      s_l(set_deriv('誕生日')),
      { **set_deriv('誕生日', 1),               labels: [ 'たのしくすごす！', 'えがおですごす！', 'せいちょうする！', 'ひとをだいじにする！' ] },
      s_l(set_deriv('タマモンカート'), 'ながめている')
    ]

    choices.each do |attrs|
      set   = EventSet.find_by!(name: attrs[:event_set_name])
      event = Event.find_by!(event_set: set, derivation_number: attrs[:derivation_number])
      # event.action_choices.delete_all
      attrs[:labels].each_with_index do |label, idx|
        choice = ActionChoice.find_or_initialize_by(event: event, position: idx + 1)
        choice.label = label
        choice.save!
      end
    end

    action_results = [
      {
        **ar_key('何か言っている', 0, 'はなしをきいてあげる'),
        trigger_conditions:    or_(status("sports_value", "<", 2), status("arithmetic", "<", 2), status("temp_vitality", "<", VITALITY_UNIT), prob(80)),
        effects:               effects_status(["happiness_value", 1], ["mood_value", 5]),
        **next_ev
      },
      {
        **ar_key('何か言っている', 0, 'はなしをきいてあげる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(call: '特訓')
      },
      {
        **ar_key('何か言っている', 0, 'よしよしする'),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 10], ["happiness_value", 1], ["mood_value", 5]),
        **next_ev
      },
      {
        **ar_key('何か言っている', 0, 'おやつをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 95)),
        effects:               effects_status(["hunger_value", 30], ["happiness_value", 1], ["mood_value", 15]),
        **next_ev
      },
      {
        **ar_key('何か言っている', 0, 'おやつをあげる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何か言っている', 0, 'ごはんをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 85)),
        effects:               effects_status(["hunger_value", 40], ["vitality", 1]),
        **next_ev
      },
      {
        **ar_key('何か言っている', 0, 'ごはんをあげる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'ボールあそびをする'),
        trigger_conditions:    and_(status("temp_vitality", ">=", VITALITY_UNIT)),
        effects:               {},
        **next_ev(call: 'ボール遊び')
      },
      {
        **ar_key('何かしたそう', 0, 'ボールあそびをする', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'べんきょうする'),
        trigger_conditions:    and_(status("temp_vitality", ">=", VITALITY_UNIT)),
        effects:               {},
        **next_ev(deriv: 1)
      },
      {
        **ar_key('何かしたそう', 0, 'べんきょうする', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'おえかきする'),
        trigger_conditions:    prob_only(40),
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'おえかきする', 2),
        trigger_conditions:    prob_only(66),
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'おえかきする', 3),
        trigger_conditions:    prob_only(88),
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'おえかきする', 4),
        trigger_conditions:    prob_only(80),
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'おえかきする', 5),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'ゲームする'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('何かしたそう', 2, 'ゲームさせてあげる'),
        trigger_conditions:    always,
        effects:               effects_status(["happiness_value", 5]),
        **next_ev(call: 'タマモンカート')
      },
      {
        **ar_key('何かしたそう', 2, 'やっぱやめよう'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'さんすう'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(call: '算数')
      },
      {
        **ar_key('何かしたそう', 1, 'こくご'),
        trigger_conditions:    prob_only(5),
        effects:               effects_status(["japanese", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'こくご', 2),
        trigger_conditions:    prob_only(20),
        effects:               effects_status(["japanese", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'こくご', 3),
        trigger_conditions:    always,
        effects:               effects_status(["japanese_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'りか'),
        trigger_conditions:    prob_only(5),
        effects:               effects_status(["science", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'りか', 2),
        trigger_conditions:    prob_only(20),
        effects:               effects_status(["science", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'りか', 3),
        trigger_conditions:    always,
        effects:               effects_status(["science_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'しゃかい'),
        trigger_conditions:    prob_only(5),
        effects:               effects_status(["social_studies", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'しゃかい', 2),
        trigger_conditions:    prob_only(20),
        effects:               effects_status(["social_studies", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'しゃかい', 3),
        trigger_conditions:    always,
        effects:               effects_status(["social_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'ながめている'),
        trigger_conditions: always,
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける'),
        trigger_conditions: and_(status("happiness_value", "==", 0)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 2),
        trigger_conditions: and_(status("happiness_value", "<=", 10)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 3),
        trigger_conditions: and_(status("happiness_value", "<=", 30)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 4),
        trigger_conditions: and_(status("happiness_value", "<=", 80)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 5),
        trigger_conditions: and_(status("happiness_value", "<=", 150)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 6),
        trigger_conditions: and_(status("happiness_value", "<=", 400)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 7),
        trigger_conditions: and_(status("happiness_value", "<=", 1000)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 8),
        trigger_conditions: and_(status("happiness_value", "<=", 2500)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 9),
        trigger_conditions: always,
        effects: {}, **next_ev
      },
      {
        **ar_key('ニコニコしている', 0, 'ながめている'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('ゴロゴロしている', 0, 'ながめている'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('踊っている', 0, 'よしよしする'),
        trigger_conditions:    prob_only(20),
        effects:               effects_status(["love_value", 10], ["happiness_value", 10], ["mood_value", -100]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('踊っている', 0, 'よしよしする', 2),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 10], ["happiness_value", 1], ["mood_value", -100]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('踊っている', 0, 'おやつをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 95)),
        effects:               effects_status(["hunger_value", 30], ["happiness_value", 3], ["mood_value", -100]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('踊っている', 0, 'おやつをあげる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('踊っている', 0, 'ごはんをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 85)),
        effects:               effects_status(["hunger_value", 40], ["vitality", 1], ["happiness_value", 1], ["mood_value", -100]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('踊っている', 0, 'ごはんをあげる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('泣いている(空腹)', 0, 'よしよしする'),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 5]),
        **next_ev
      },
      {
        **ar_key('泣いている(空腹)', 0, 'おやつをあげる'),
        trigger_conditions:    always,
        effects:               effects_status(["hunger_value", 40]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('泣いている(空腹)', 0, 'ごはんをあげる'),
        trigger_conditions:    always,
        effects:               effects_status(["hunger_value", 50], ["vitality", 1]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('泣いている(空腹)', 0, 'あそんであげる'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('泣いている(よしよし不足)', 0, 'よしよしする'),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 40]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('泣いている(よしよし不足)', 0, 'おやつをあげる'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('泣いている(よしよし不足)', 0, 'ごはんをあげる'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('泣いている(よしよし不足)', 0, 'あそんであげる'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('泣いている(ランダム)', 0, 'よしよしする'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('泣いている(ランダム)', 0, 'おやつをあげる'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('泣いている(ランダム)', 0, 'ごはんをあげる'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('泣いている(ランダム)', 0, 'あそんであげる'),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 30]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('寝ている', 0, 'そっとする'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('寝ている', 0, 'よしよしする'),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 40], ["happiness_value", 1]),
        **next_ev
      },
      {
        **ar_key('寝ている', 0, 'たたきおこす'),
        trigger_conditions:    always,
        effects:               effects_status(["happiness_value", -5]),
        **next_ev
      },
      {
        **ar_key('ブロックのおもちゃに夢中', 0, 'そっとする'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('ブロックのおもちゃに夢中', 0, 'よしよしする'),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 10], ["happiness_value", 1]),
        **next_ev
      },
      {
        **ar_key('ブロックのおもちゃに夢中', 0, 'ちょっかいをだす'),
        trigger_conditions:    prob_only(20),
        effects:               effects_status(["happiness_value", -1]),
        **next_ev(call: '怒っている', resolve: true)
      },
      {
        **ar_key('ブロックのおもちゃに夢中', 0, 'ちょっかいをだす', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('ブロックのおもちゃに夢中', 0, 'ブロックをくずす'),
        trigger_conditions:    prob_only(6),
        effects:               effects_status(["happiness_value", -100]),
        **next_ev(call: '怒っている', resolve: true)
      },
      {
        **ar_key('ブロックのおもちゃに夢中', 0, 'ブロックをくずす', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('マンガに夢中', 0, 'そっとする'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('マンガに夢中', 0, 'よしよしする'),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 10], ["happiness_value", 1]),
        **next_ev
      },
      {
        **ar_key('マンガに夢中', 0, 'はなしかける'),
        trigger_conditions:    prob_only(30),
        effects:               {},
        **next_ev
      },
      {
        **ar_key('マンガに夢中', 0, 'はなしかける', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('マンガに夢中', 0, 'マンガをとりあげる'),
        trigger_conditions:    always,
        effects:               effects_status(["happiness_value", -50]),
        **next_ev(call: '怒っている', resolve: true)
      },
      {
        **ar_key('眠そう', 0, 'ねかせる'),
        trigger_conditions:    prob_only(30),
        effects:               effects_status(["happiness_value", 5]),
        **next_ev(call: '寝かせた', resolve: true)
      },
      {
        **ar_key('眠そう', 0, 'ねかせる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('眠そう', 0, 'よしよしする'),
        trigger_conditions:    prob_only(20),
        effects:               effects_status(["love_value", 10], ["happiness_value", 1]),
        **next_ev(call: '寝かせた', resolve: true)
      },
      {
        **ar_key('眠そう', 0, 'よしよしする', 2),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 10], ["happiness_value", 1]),
        **next_ev
      },
      {
        **ar_key('眠そう', 0, 'はみがきをさせる'),
        trigger_conditions:    prob_only(33),
        effects:               effects_status(["happiness_value", 3]),
        **next_ev(call: '寝かせた', resolve: true)
      },
      {
        **ar_key('眠そう', 0, 'はみがきをさせる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('眠そう', 0, 'ダジャレをいう'),
        trigger_conditions:    prob_only(5),
        effects:               effects_status(["happiness_value", 1]),
        **next_ev
      },
      {
        **ar_key('眠そう', 0, 'ダジャレをいう', 2),
        trigger_conditions:    prob_only(20),
        effects:               {},
        **next_ev
      },
      {
        **ar_key('眠そう', 0, 'ダジャレをいう', 3),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('寝かせた', 0, 'そっとする'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('寝かせた', 0, 'よしよしする'),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 10], ["happiness_value", 10]),
        **next_ev(deriv: 1)
      },
      {
        **ar_key('寝かせた', 0, 'たたきおこす'),
        trigger_conditions:    always,
        effects:               effects_status(["happiness_value", -5]),
        **next_ev(deriv: 1)
      },
      {
        **ar_key('寝かせた', 0, 'ゴミばこのなかをのぞく'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(deriv: 1)
      },
      {
        **ar_key('寝かせた', 1, 'そっとする'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
         **ar_key('寝かせた', 1, 'よしよしする'),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 10], ["happiness_value", 1]),
        **next_ev
      },
      {
        **ar_key('寝かせた', 1, 'たたきおこす'),
        trigger_conditions:    always,
        effects:               effects_status(["happiness_value", -5]),
        **next_ev
      },
      {
        **ar_key('寝起き', 0, 'そっとする'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('寝起き', 0, 'よしよしする'),
        trigger_conditions:    prob_only(20),
        effects:               effects_status(["love_value", 10], ["happiness_value", 1]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('寝起き', 0, 'よしよしする', 2),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 10], ["happiness_value", 1]),
        **next_ev
      },
      {
        **ar_key('寝起き', 0, 'きがえさせる'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('寝起き', 0, 'ばくおんをながす'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(deriv: 1)
      },
      {
        **ar_key('寝起き', 1, 'かけちゃう'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('寝起き', 1, 'やめておく'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(deriv: 0)
      },
      {
        **ar_key('寝起き', 2, 'はい'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(deriv: 3)
      },
      {
        **ar_key('寝起き', 2, 'やっぱやめておく'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(deriv: 0)
      },
      {
        **ar_key('寝起き', 3, 'はい'),
        trigger_conditions:    always,
        effects:               effects_status(["happiness_value", -30]),
        **next_ev(call: '怒っている', resolve: true)
      },
      {
        **ar_key('寝起き', 3, 'いいえ'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(deriv: 0)
      },
      {
        **ar_key('占い', 0, 'すすむ'),
        trigger_conditions: prob_only(10),
        effects: {},
        **next_ev
      },
      {
        **ar_key('占い', 0, 'すすむ', 2),
        trigger_conditions: prob_only(33),
        effects: {},
        **next_ev
      },
      {
        **ar_key('占い', 0, 'すすむ', 3),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('タマモン', 0, 'みていいよ'),
        trigger_conditions: always,
        effects: effects_status(["happiness_value", 5]),
        **next_ev(deriv: 1)
      },
      {
        **ar_key('タマモン', 0, 'みさせてあげない'),
        trigger_conditions: always,
        effects: {},
        **next_ev(resolve: true)
      },
      {
        **ar_key('タマモン', 1, 'いっしょにみる'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('タマえもん', 0, 'みていいよ'),
        trigger_conditions: always,
        effects: effects_status(["happiness_value", 5]),
        **next_ev(deriv: 1)
      },
      {
        **ar_key('タマえもん', 0, 'みさせてあげない'),
        trigger_conditions: always,
        effects: {},
        **next_ev(resolve: true)
      },
      {
        **ar_key('タマえもん', 1, 'いっしょにみる'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('ニワトリビアの湖', 0, 'みていいよ'),
        trigger_conditions: always,
        effects: effects_status(["happiness_value", 3]),
        **next_ev(deriv: 1)
      },
      {
        **ar_key('ニワトリビアの湖', 0, 'みさせてあげない'),
        trigger_conditions: always,
        effects: {},
        **next_ev(resolve: true)
      },
      {
        **ar_key('ニワトリビアの湖', 1, 'いっしょにみる'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('扇風機', 0, 'よしよしする'),
        trigger_conditions: always,
        effects: effects_status(["love_value", 10], ["happiness_value", 2]),
        **next_ev
      },
      {
        **ar_key('扇風機', 0, 'スイカをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 95)),
        effects: effects_status(["hunger_value", 30], ["vitality", 3], ["happiness_value", 2]),
        **next_ev
      },
      {
        **ar_key('扇風機', 0, 'スイカをあげる', 2),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('扇風機', 0, 'せんぷうきをとめる'),
        trigger_conditions: always,
        effects: effects_status(["happiness_value", -1]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('扇風機', 0, 'そっとする'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('こたつ', 0, 'よしよしする'),
        trigger_conditions: always,
        effects: effects_status(["love_value", 10], ["happiness_value", 2]),
        **next_ev
      },
      {
        **ar_key('こたつ', 0, 'ミカンをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 95)),
        effects: effects_status(["hunger_value", 30], ["vitality", 3], ["happiness_value", 2]),
        **next_ev
      },
      {
        **ar_key('こたつ', 0, 'ミカンをあげる', 2),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('こたつ', 0, 'こたつをとめる'),
        trigger_conditions: always,
        effects: effects_status(["happiness_value", -1]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('こたつ', 0, 'そっとする'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('花見', 0, 'つれていく'),
        trigger_conditions: always,
        effects: effects_status(["happiness_value", 10]),
        **next_ev
      },
      {
        **ar_key('花見', 0, 'いかない'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('紅葉', 0, 'つれていく'),
        trigger_conditions: always,
        effects: effects_status(["happiness_value", 10]),
        **next_ev
      },
      {
        **ar_key('紅葉', 0, 'いかない'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('年始', 0, 'すすむ'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('怒っている', 0, 'よしよしする'),
        trigger_conditions:    prob_only(25),
        effects:               effects_status(["love_value", 10]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('怒っている', 0, 'よしよしする', 2),
        trigger_conditions:    always,
        effects:               effects_status(["love_value", 3]),
        **next_ev
      },
      {
        **ar_key('怒っている', 0, 'おやつをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 50)),
        effects:               effects_status(["hunger_value", 30]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('怒っている', 0, 'おやつをあげる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('怒っている', 0, 'へんがおをする'),
        trigger_conditions:    prob_only(10),
        effects:               effects_status(["happiness_value", 1]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('怒っている', 0, 'へんがおをする', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('怒っている', 0, 'あやまる'),
        trigger_conditions:    prob_only(33),
        effects:               effects_status(["happiness_value", 1]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('怒っている', 0, 'あやまる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('算数', 0, 'すすむ'),
        trigger_conditions: prob_only(25),
        effects: {},
        **next_ev(deriv: 1)
      },
      {
        **ar_key('算数', 0, 'すすむ', 2),
        trigger_conditions: prob_only(33),
        effects: {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('算数', 0, 'すすむ', 3),
        trigger_conditions: prob_only(50),
        effects: {},
        **next_ev(deriv: 3)
      },
      {
        **ar_key('算数', 0, 'すすむ', 4),
        trigger_conditions: always,
        effects: {},
        **next_ev(deriv: 4)
      },
      {
        **ar_key('算数', 1, '〈A〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 1, '〈B〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 1, '〈C〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 1, '〈D〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 2, '〈A〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 2, '〈B〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 2, '〈C〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 2, '〈D〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 3, '〈A〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 3, '〈B〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 3, '〈C〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 3, '〈D〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 4, '〈A〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 4, '〈B〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 4, '〈C〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('算数', 4, '〈D〉'),
        trigger_conditions: always,
        effects: effects_status(["arithmetic_effort", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 0, 'すすむ'),
        trigger_conditions: always,
        effects: {},
        **next_ev(deriv: 1)
      },
      {
        **ar_key('ボール遊び', 1, 'ぜんりょくとうきゅう'),
        trigger_conditions: prob_only(33),
        effects: {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('ボール遊び', 1, 'ぜんりょくとうきゅう', 2),
        trigger_conditions: prob_only(50),
        effects: {},
        **next_ev(deriv: 3)
      },
      {
        **ar_key('ボール遊び', 1, 'ぜんりょくとうきゅう', 3),
        trigger_conditions: always,
        effects: {},
        **next_ev(deriv: 4)
      },
      {
        **ar_key('ボール遊び', 2, 'ひだりだ！'),
        trigger_conditions: always,
        effects: effects_status(["sports_value", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 2, 'そこだ！'),
        trigger_conditions: prob_only(50),
        effects: effects_status(["sports_value", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 2, 'そこだ！', 2),
        trigger_conditions: always,
        effects: effects_status(["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 2, 'みぎだ！'),
        trigger_conditions: always,
        effects: effects_status(["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'ひだりだ！'),
        trigger_conditions: prob_only(30),
        effects: effects_status(["sports_value", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'ひだりだ！', 2),
        trigger_conditions: always,
        effects: effects_status(["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'そこだ！'),
        trigger_conditions: always,
        effects: effects_status(["sports_value", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'みぎだ！'),
        trigger_conditions: prob_only(30),
        effects: effects_status(["sports_value", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'みぎだ！', 2),
        trigger_conditions: always,
        effects: effects_status(["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 4, 'ひだりだ！'),
        trigger_conditions: always,
        effects: effects_status(["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 4, 'そこだ！'),
        trigger_conditions: prob_only(50),
        effects: effects_status(["sports_value", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 4, 'そこだ！', 2),
        trigger_conditions: always,
        effects: effects_status(["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 4, 'みぎだ！'),
        trigger_conditions: always,
        effects: effects_status(["sports_value", 1], ["temp_vitality", -VITALITY_UNIT]),
        **next_ev
      },
      {
        **ar_key('特訓', 0, 'さんすう'),
        trigger_conditions: and_(status("arithmetic", ">=", 0)),
        effects: {},
        **next_ev(call: '算数')
      },
      {
        **ar_key('特訓', 0, 'さんすう', 2),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 0, 'ボールあそび'),
        trigger_conditions:    and_(status("sports_value", ">=", 0)),
        effects: {},
        **next_ev(call: 'ボール遊び')
      },
      {
        **ar_key('特訓', 0, 'ボールあそび', 2),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 0, 'やっぱやめておく'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 1, 'すすむ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 2, 'すすむ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 3, 'すすむ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 4, 'すすむ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 5, 'すすむ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 6, 'すすむ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('イントロ', 0, 'すすむ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 1)
      },
      {
        **ar_key('イントロ', 1, 'えっ？'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('イントロ', 1, 'まさか！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('イントロ', 1, 'うーん'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('イントロ', 1, 'かっこいいです'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('イントロ', 2, 'すすむ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 3)
      },
      {
        **ar_key('イントロ', 3, 'いいなまえ！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 4)
      },
      {
        **ar_key('イントロ', 3, 'ちゃんをつけて！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 4)
      },
      {
        **ar_key('イントロ', 3, 'くんをつけて！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 4)
      },
      {
        **ar_key('イントロ', 3, 'さまをつけて！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 4)
      },
      {
        **ar_key('イントロ', 4, 'すすむ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 5)
      },
      {
        **ar_key('イントロ', 5, 'こんにちは！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 6)
      },
      {
        **ar_key('イントロ', 5, 'なかよくしてね！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 6)
      },
      {
        **ar_key('イントロ', 6, 'よっ！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 7)
      },
      {
        **ar_key('イントロ', 6, 'なかよくたのむぜ！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 7)
      },
      {
        **ar_key('イントロ', 7, 'こんにちは！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 7)
      },
      {
        **ar_key('イントロ', 7, 'なかよくしてね！'),
        trigger_conditions:    always,
        effects: {},
        **next_ev(deriv: 7)
      },
      {
        **ar_key('イントロ', 7, 'よしよし'),
        trigger_conditions:    always,
        effects: effects_status(["love_value", 10], ["happiness_value", 1]),
        **next_ev
      },
      {
        **ar_key('誕生日', 0, 'すすむ'), trigger_conditions: always,
        effects: {},**next_ev(deriv: 1)
      },
      {
        **ar_key('誕生日', 1, 'たのしくすごす！'), trigger_conditions: always,
        effects: effects_status(["happiness_value", 10]),
        **next_ev
      },
      {
        **ar_key('誕生日', 1, 'えがおですごす！'), trigger_conditions: always,
        effects: effects_status(["happiness_value", 10]),
        **next_ev
      },
      {
        **ar_key('誕生日', 1, 'せいちょうする！'), trigger_conditions: always,
        effects: effects_status(["happiness_value", 10]),
        **next_ev
      },
      {
        **ar_key('誕生日', 1, 'ひとをだいじにする！'), trigger_conditions: always,
        effects: effects_status(["happiness_value", 10]),
        **next_ev
      },
      {
        **ar_key('タマモンカート', 0, 'ながめている'), trigger_conditions: prob_only(85),
        effects: {}, **next_ev
      },
      {
        **ar_key('タマモンカート', 0, 'ながめている', 2), trigger_conditions: always,
        effects: {}, **next_ev
      }
    ]

    action_results.each do |attrs|
      set    = EventSet.find_by!(name: attrs[:event_set_name])
      event  = Event.find_by!(event_set: set, derivation_number: attrs[:derivation_number])
      choice = ActionChoice.find_by!(event: event, label: attrs[:label])

      result = ActionResult.find_or_initialize_by(
        action_choice: choice,
        priority:      attrs[:priority]
      )

      result.trigger_conditions     = attrs[:trigger_conditions]
      result.effects                = attrs[:effects]
      result.next_derivation_number = attrs[:next_derivation_number]
      if attrs[:calls_event_set_name].present?
        called_set = EventSet.find_by!(name: attrs[:calls_event_set_name])
        result.calls_event_set_id = called_set.id
      else
        result.calls_event_set_id = nil
      end
      result.resolves_loop = attrs[:resolves_loop]

      result.save!
    end

    cuts = [
      { **cut_key(ar_key('何か言っている', 0, 'はなしをきいてあげる', 1), 1), message: '〈たまご〉「ににに！にににー！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何か言っている', 0, 'はなしをきいてあげる', 1), 2), message: 'さいきん、ボールあそびがたのしいようだ！', **image_set("temp-nikoniko2.png"),
      messages: [ 'さいきん、ボールあそびがたのしいようだ！', 'ちきゅうはまるいんだよ、といっている。まさか～！', 'しょうらいはパイロットになりたいらしい！', '〈たまご〉はまいにちがたのしいらしい！', '〈ユーザー〉はおなかがまんまるだね、といっている。うるさい！',
                  'このまえ、おとしよりのニモツをもってあげたんだって！えらい！', 'みそラーメンよりとんこつラーメン、といっている。むずかしいぎろんだ！', 'おとなになったらバイクにのってみたいらしい。あんぜんうんてんするんだよ！', '〈たまご〉はきんようびのよるにやっているテレビばんぐみ、タマえもんがすきらしい！', 'さいきん、はしるのがはやくなったらしい！いつもチョロチョロはしりまわってるもんね！', 'ともだちとのあいだでタマモンのゲームがはやっているらしい！', 'カレーライスはあまくちがすきらしい！わかる！',
                  'ラッコさんってかわいいよね、っていってる。すいぞくかんにいるかなー？', 'タコにはしんぞうが3つあるらしい。うそー！？', 'バナナはベリーのなかまらしい！ふーん！', 'カンガルーはうしろにすすめないらしい。ふしぎー！', 'カタツムリのしょっかくは4ほんあるらしい。こんどよくみてみよう！', 'このまえ、がいこくじんのひとにみちあんないしてあげたらしい！ことばわかった？', 'チーズバーガーはケチャップおおめがすきらしい！わかってるじゃん！', 'このまえ、れいぞうこのケチャップこっそりなめたらしい！あー！！',
                  'オトは1オクターブあがると、しゅうはすうが2ばいになるらしい。へー！', 'タンスにかくしてあったポテチおいしかったといっている。え！とっておきのやつー！', 'ジュウドウってかっこいいよねっていっている。つよいセイシンリョクがひつようだぞ！', 'ダジャレのもちネタが10こあるらしい。まだまだだな！', 'こんどおんがくフェスにいきたいらしい！さんせんしちゃう！？', 'ハンバーグのおいしさをかたっている！', 'からあげのおいしいおべんとうやが、さいきんできたらしい！' ] },
      { **cut_key(ar_key('何か言っている', 0, 'はなしをきいてあげる', 2), 1), message: 'なになに？うんうん。', **image_set("temp-komattakao.png") },
      { **cut_key(ar_key('何か言っている', 0, 'はなしをきいてあげる', 2), 2), message: '〈たまご〉はとっくんがしたいといっている！', **image_set("temp-yaruki.png") },
      { **cut_key(ar_key('何か言っている', 0, 'よしよしする',        1), 1), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('何か言っている', 0, 'おやつをあげる',      1), 1), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('何か言っている', 0, 'ごはんをあげる',      1), 1), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('何か言っている', 0, 'おやつをあげる',      2), 1), message: '〈たまご〉はおなかいっぱいのようだ。', **image_set("temp-normal.png") },
      { **cut_key(ar_key('何か言っている', 0, 'ごはんをあげる',      2), 1), message: '〈たまご〉はおなかいっぱいのようだ。', **image_set("temp-normal.png") },

      { **cut_key(ar_key('何かしたそう', 0, 'ボールあそびをする', 1), 1), message: 'よし！ボールあそびをしよう！',                       **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'ボールあそびをする', 2), 1), message: '〈たまご〉はつかれている！やすませてあげよう！',       **image_set("temp-hukigen.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'べんきょうする',     2), 1), message: '〈たまご〉はつかれている！やすませてあげよう！',      **image_set("temp-hukigen.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       1), 1), message: 'おえかきをした！じょうずにかけたね！',               **image_set("temp-ewokaita1.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       2), 1), message: 'おえかきをした！〈たまご〉はおえかきがじょうずだね！', **image_set("temp-ewokaita2.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       3), 1), message: 'おえかきをした！これはなんだろう？',                 **image_set("temp-ewokaita3.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       4), 1), message: 'おえかきをした！ん！？なにかいてんだー！',            **image_set("temp-ewokaita4.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       5), 1), message: 'おえかきをした！ん！？てんさいてきだーーー！！！',     **image_set("temp-ewokaita5.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'ゲームする',         1), 1), message: 'テレビゲームであそばせてあげよっかな！',              **image_set("temp-normal.png") },
      { **cut_key(ar_key('何かしたそう', 2, 'ゲームさせてあげる',  1), 1), message: 'テレビゲームであそんでいいよ！30ぷんかんね！',         **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 2, 'やっぱやめよう',     1), 1), message: 'やっぱゲームはまたこんどかな！',                      **image_set("temp-okoru.png") },

      { **cut_key(ar_key('何かしたそう', 1, 'こくご')), message: 'こくごのべんきょうをしよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご'), 2), message: '・・・。',                   **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご'), 3), message: '〈たまご〉はシェイクスピアのさくひんをよんだ！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 2)), message: 'こくごのべんきょうをしよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 2), 2), message: '・・・。',                   **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 2), 3), message: '〈たまご〉は「はしれメロス」をよんだ！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 3)), message: 'こくごのべんきょうをしよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 3), 2), message: '・・・。',                   **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 3), 3), message: '『どんぶらこー、どんぶらこー』', **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 3), 4), message: '〈たまご〉はももたろうをよんだ！', **image_set("temp-study.png") },

      { **cut_key(ar_key('何かしたそう', 1, 'りか')), message: 'りかのべんきょうをしよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか'), 2), message: '・・・。',                   **image_set("temp-rika.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか'), 3), message: '〈たまご〉はふろうふしになれるクスリをつくった！', **image_set("temp-rika2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 2)), message: 'りかのべんきょうをしよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 2), 2), message: '・・・。',                   **image_set("temp-rika.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 2), 3), message: '！！！',                     **image_set("temp-rika3.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 2), 4), message: '・・・。',                   **image_set("temp-rika4.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 3)), message: 'りかのべんきょうをしよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 3), 2), message: '・・・。',                   **image_set("temp-rika.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 3), 3), message: 'じっけんはしっぱいした！', **image_set("temp-rika.png") },

      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい')), message: 'しゃかいのべんきょうをしよう！',                           **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい'), 2), message: '・・・。',                                               **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい'), 3), message: 'すっごいゆうめいなブショウがタイムスリップしてきた！すご！！', **image_set("temp-busyou3.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 2)), message: 'しゃかいのべんきょうをしよう！',                           **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 2), 2), message: '・・・。',                                               **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 2), 3), message: 'なまえをきいたことあるようなないようなブショウがタイムスリップしてきた！', **image_set("temp-busyou2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 2), 4), message: 'こんにちは！',                                           **image_set("temp-busyou2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 3)), message: 'しゃかいのべんきょうをしよう！',                           **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 3), 2), message: '・・・。',                                               **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 3), 3), message: 'むめいのブショウがタイムスリップしてきた！',                 **image_set("temp-busyou1.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 3), 4), message: 'はやくかえって！',                                         **image_set("temp-busyou1.png") },

      { **cut_key(ar_key('ボーっとしている', 0, 'ながめている')), message: 'きょうものどかだねえ。', **image_set("temp-hidariwomiru-teage.png"),
      messages: [ 'きょうものどかだねえ。', '〈たまご〉「んに～」', '〈たまご〉「んにに～」', '〈たまご〉「にー、にに～」', '〈たまご〉「にににー、にに～」',
                  '〈たまご〉「にー、にに！」', '〈たまご〉「ににに？に～」', 'こうみえて、いろいろかんがえごとしてるのかも。', 'きょうもへいわだ。', 'のんびりすごすのがいちばんだよね～。', 'ボケっとしてると、あっというまにじかんがすぎるよ。' ] },
      { **cut_key(ar_key('ニコニコしている', 0, 'ながめている')), message: 'どうしたのかな！', **image_set("temp-suwatte-nikoniko-teage.png"),
      messages: [ 'どうしたのかな！', '〈たまご〉「んに～！」', '〈たまご〉「んにに～！」', '〈たまご〉「にー！にに～！」', '〈たまご〉「にににー！にに～！」',
                  '〈たまご〉「にー！んにー！」', '〈たまご〉「んににー！」', 'ごきげんそう！' ] },
      { **cut_key(ar_key('ゴロゴロしている', 0, 'ながめている')), message: 'ゴロゴロ！', **image_set("temp-gorogoro.png"),
      messages: [ 'ゴロゴロ！', 'きもちよさそうだなあ。', 'ゴロゴロばっかしてるとふとっちゃうよ！', 'じぶんもゴロゴロしようかなあ。', 'ゆか、かたくないのかな？',
                  'ゴロゴロきもちいいねえ！', '〈たまご〉「に～！」', '〈たまご〉「に！んにに～！」' ] },

      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける')), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける'), 2), message: '・・・。けいかいされている。いちどじぶんのムネにてをあてて、げんいんをかんがえてみるんだ。', **image_set("temp-kanasii.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 2)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 2), 2), message: 'あー！ぜんぜんなついていないようだ。',                                                  **image_set("temp-mewosorasu.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 3)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 3), 2), message: 'うーん、もっとこころをひらいてほしいなあ。',                                             **image_set("temp-tewoageru.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 4)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 4), 2), message: 'お！すこしこころをひらいてくれているようだ！',                                           **image_set("temp-nikoniko3.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 5)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 5), 2), message: '〈たまご〉はこころをひらいてくれているようだ！',                                         **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 6)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 6), 2), message: '〈たまご〉にすごくすかれているようだ！',                                                **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 7)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 7), 2), message: '〈たまご〉にすっごくすかれているようだ！！',                                             **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 8)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 8), 2), message: '〈たまご〉にすーっごくかなりすかれているようだ！！！',                                    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 9)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 9), 2), message: '〈たまご〉にすーーっごくかなりすかれているようだ！！！！',                                **image_set("temp-nikoniko.png") },

      { **cut_key(ar_key('踊っている',     0, 'よしよしする')), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('踊っている',     0, 'おやつをあげる')), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('踊っている',     0, 'ごはんをあげる')), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },

      { **cut_key(ar_key('踊っている',     0, 'よしよしする', 2)), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('踊っている',     0, 'おやつをあげる', 2)), message: '〈たまご〉はおなかいっぱいのようだ。', **image_set("temp-normal.png") },
      { **cut_key(ar_key('踊っている',     0, 'ごはんをあげる', 2)), message: '〈たまご〉はおなかいっぱいのようだ。', **image_set("temp-normal.png") },

      { **cut_key(ar_key('泣いている(空腹)', 0, 'よしよしする')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(空腹)', 0, 'おやつをあげる')), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('泣いている(空腹)', 0, 'ごはんをあげる')), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('泣いている(空腹)', 0, 'あそんであげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },

      { **cut_key(ar_key('泣いている(よしよし不足)', 0, 'よしよしする')), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('泣いている(よしよし不足)', 0, 'おやつをあげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(よしよし不足)', 0, 'ごはんをあげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(よしよし不足)', 0, 'あそんであげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },

      { **cut_key(ar_key('泣いている(ランダム)', 0, 'よしよしする')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(ランダム)', 0, 'おやつをあげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(ランダム)', 0, 'ごはんをあげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(ランダム)', 0, 'あそんであげる')), message: '〈たまご〉はよろこんでいる！', **image_set("temp-nikoniko.png") },

      { **cut_key(ar_key('寝ている',           0, 'そっとする')), message: 'きもちよさそうにねている。', **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝ている',           0, 'よしよしする')), message: 'おこさないように、やさしくなでた。', **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝ている',           0, 'たたきおこす')), message: 'ひとでなし！！', **image_set("temp-sleep.png") },

      { **cut_key(ar_key('寝起き',             0, 'そっとする')), message: 'まだねむいみたいだからそっとしておこう！', **image_set("temp-wakeup.png") },
      { **cut_key(ar_key('寝起き',             0, 'よしよしする')), message: '〈たまご〉がよろこんでいる！おはよう！',   **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('寝起き',             0, 'よしよしする', 2)), message: 'よしよし！',                            **image_set("temp-wakeup.png") },
      { **cut_key(ar_key('寝起き',             0, 'きがえさせる')), message: '〈たまご〉はふくなんかきていない！',      **image_set("temp-wakeup.png") },
      { **cut_key(ar_key('寝起き',             3, 'はい')), message: '〈たまご〉はおこってしまった！',           **image_set("temp-okoru.png") },

      { **cut_key(ar_key('占い',               0, 'すすむ')), message: '『ほんじつのあなたはすっごくラッキー！』', **image_set("temp-TV1.png") },
      { **cut_key(ar_key('占い',               0, 'すすむ'), 2), message: '『ちょっかんにしたがうと、おもわぬいいことが！』', **image_set("temp-TV2.png"),
      messages: [ '『ちょっかんにしたがうと、おもわぬいいことがありそう！』', '『せっきょくてきにうごくと、とってもいいことがおこりそう！』', '『おいしいものをたべると、きんうんアップ！』', '『ふだんとへんかのあるこうどうをいしきしよう！』', '『まわりのひとからかんしゃされそうなよかん！』',
                  '『なにをやってもうまくいきそう！』', '『いつもはしっぱいすることも、きょうならうまくいきそう！』', '『じぶんのとくいなことにうちこんでみよう！』', '『ひとのえがおにふれると、うんきがアップ！』', '『まわりへのおもいやりを、いつもいじょうにだいじにしよう！』' ] },
      { **cut_key(ar_key('占い',               0, 'すすむ'), 3), message: 'だそうだ！', **image_set("temp-TV2.png") },

      { **cut_key(ar_key('占い',               0, 'すすむ',    2)), message: '『ほんじつのあなたはそこそこラッキー！』', **image_set("temp-TV1.png") },
      { **cut_key(ar_key('占い',               0, 'すすむ',    2), 2), message: '『あんまりふかくかんがえすぎず、こうどうしよう！』', **image_set("temp-TV2.png"),
      messages: [ '『あんまりふかくかんがえすぎず、こうどうしよう！』', '『ごぜんちゅうから、かっぱつてきにこうどうしよう！』', '『あまいものをたべると、いいことがあるかも！』', '『じぶんをかざらず、すごしてみよう！』', '『コミュニケーションがじゅうようないちにちになりそう！』',
                  '『けんこうてきないちにちをすごすのがポイント！』', '『ちょうせんがうまくいきそうなよかん！』', '『じぶんのにがてなことにうちこんでみよう！』', '『たまにはのんびりすごすのもいいかも！』', '『にんげんかんけいがうまくいきそう！』' ] },
      { **cut_key(ar_key('占い',               0, 'すすむ',    2), 3), message: 'だそうだ！', **image_set("temp-TV2.png") },

      { **cut_key(ar_key('占い',               0, 'すすむ',    3)), message: '『ほんじつのあなたはちょっぴりラッキー！』', **image_set("temp-TV1.png") },
      { **cut_key(ar_key('占い',               0, 'すすむ',    3), 2), message: '『でもマンホールのうえにはきをつけよう！』', **image_set("temp-TV1.png"),
      messages: [ '『でもマンホールのうえにはきをつけよう！』', '『みぎかひだりだったら、ひだりをえらぼう！』', '『みぎかひだりだったら、みぎをえらぼう！』', '『おとしよりにやさしくするのがポイント！』', '『にがてなたべものをがんばってたべてみよう！』',
                  '『うんどうをするといいことがあるかも？』', '『トイレはがまんしないほうがよさそう！』', '『せいじつなきもちをもっていれば、いいいちにちになりそう！』', '『きょうはいそがしいかもしればいけど、がんばってみよう！』', '『でもひとのわるぐちをいうと、うんきがガクッとさがるよ！』',
                  '『ラッキーカラーはきいろ！』', '『ラッキーカラーはあお！』', '『ラッキーカラーはあか！』', '『ラッキーカラーはみどり！』', '『ニコニコすることをこころがけよう！』' ] },
      { **cut_key(ar_key('占い',               0, 'すすむ',    3), 3), message: 'だそうだ！', **image_set("temp-TV1.png") },

      { **cut_key(ar_key('タマモン',               0, 'みていいよ')), message: '〈たまご〉はよろこんでいる！',              **image_set("temp-TV4.png") },
      { **cut_key(ar_key('タマモン',               0, 'みさせてあげない')), message: 'しょぼん。',                              **image_set("temp-TV5.png") },
      { **cut_key(ar_key('タマモン',               1, 'いっしょにみる')), message: '『でばんだ、タマチュウ！』', **image_set("temp-TV6.png"),
      messages: [ '『でばんだ、タマチュウ！』', '『これからたびにでるぞ！』', '『タマモンマスターへのみちはながい！』', '『タマチュウがつよくなってきた！』', '『バトルだタマチュウ！』',
                  '『タマチュウにげるぞ！』', '『タマチュウ！かえってこい！』', '『タマチュウきょうはちょうしわるいか？』', '『タマチュウ！たたかってくれ！』', '『これがタマチュウ？』',
                  '『タマチュウ、さいきんふとった？』', '『あのタマモンつかまえよう！』', '『あー、にげられた！』', '『あのやまをこえないと！』', '『タマチュウ、これからもよろしくな！』' ] },

      { **cut_key(ar_key('タマえもん',               0, 'みていいよ')), message: '〈たまご〉はよろこんでいる！',           **image_set("temp-TV4.png") },
      { **cut_key(ar_key('タマえもん',               0, 'みさせてあげない')), message: 'しょぼん。',                           **image_set("temp-TV5.png") },
      { **cut_key(ar_key('タマえもん',               1, 'いっしょにみる')), message: '『たすけてタマえもん！』', **image_set("temp-TV6.png"),
      messages: [ '『たすけてタマえもん！』', '『タマえもーん！』', '『タマえもんにどうにかしてもらおう！』', '『タマえもんとケンカしてしまった・・・。』', '『タマえもんにもできないことがあるんだね』',
                  '『しっかりしてよタマえもん！』', '『いそいでかえらないと！』', '『タマえもん、これどうやってつかえばいいの？』', '『いつもありがとうね、タマえもん！』', '『きょうはがっこうにいきたくないなあ』',
                  '『こうえんにあそびにいこう！』', '『タマえもん、またあしたね！』', '『いそいでタマえもんのところにいかないと！』', '『タマえもん、さっきはごめんね！』', '『タマえもん、これからもよろしくね！』' ] },

      { **cut_key(ar_key('ニワトリビアの湖',           0, 'みていいよ')), message: '〈たまご〉はよろこんでいる！',           **image_set("temp-TV4.png") },
      { **cut_key(ar_key('ニワトリビアの湖',           0, 'みさせてあげない')), message: 'しょぼん。',                           **image_set("temp-TV5.png") },
      { **cut_key(ar_key('ニワトリビアの湖',           1, 'いっしょにみる')), message: '『コケーコケーコケー、100コケー！』', **image_set("temp-TV6.png"),
      messages: [ '『コケーコケーコケー、97コケー！』', '『コケーコケーコケー、91コケー！』', '『コケーコケーコケー、88コケー！』', '『コケーコケーコケー、84コケー！』', '『コケーコケーコケー、75コケー！』',
                  '『コケーコケーコケー、69コケー！』', '『コケーコケーコケー、61コケー！』', '『コケーコケーコケー、54コケー！』', '『コケーコケーコケー、46コケー！』', '『コケーコケーコケー、43コケー！』', '『コケーコケーコケー、36コケー！』', '『コケーコケーコケー、35コケー！』',
                  '『コケーコケーコケー、27コケー！』', '『コケーコケーコケー、14コケー！』', '『コケーコケーコケー、7コケー！』', '『0コケー！』' ] },

      { **cut_key(ar_key('扇風機',                 0, 'よしよしする')), message: '〈たまご〉はよろこんでいる！',                 **image_set("temp-senpuuki2.png") },
      { **cut_key(ar_key('扇風機',                 0, 'スイカをあげる')), message: '〈たまご〉はおいしそうにたべている！',          **image_set("temp-senpuuki3.png") },
      { **cut_key(ar_key('扇風機',                 0, 'スイカをあげる', 2)), message: '〈たまご〉はおなかいっぱいみたい。',            **image_set("temp-senpuuki4.png") },
      { **cut_key(ar_key('扇風機',                 0, 'せんぷうきをとめる')), message: '〈たまご〉「・・・！」',                       **image_set("temp-bikkuri.png") },
      { **cut_key(ar_key('扇風機',                 0, 'そっとする')), message: '〈たまご〉はきもちよさそう！',                 **image_set("temp-senpuuki1.png") },

      { **cut_key(ar_key('こたつ',                 0, 'よしよしする')), message: '〈たまご〉はよろこんでいる！',                 **image_set("temp-kotatu2.png") },
      { **cut_key(ar_key('こたつ',                 0, 'ミカンをあげる')), message: '〈たまご〉はおいしそうにたべている！',          **image_set("temp-kotatu3.png") },
      { **cut_key(ar_key('こたつ',                 0, 'ミカンをあげる', 2)), message: '〈たまご〉はおなかいっぱいみたい。',            **image_set("temp-kotatu4.png") },
      { **cut_key(ar_key('こたつ',                 0, 'こたつをとめる')), message: '〈たまご〉「・・・！」',                       **image_set("temp-bikkuri.png") },
      { **cut_key(ar_key('こたつ',                 0, 'そっとする')), message: '〈たまご〉はきもちよさそう！',                 **image_set("temp-kotatu1.png") },

      { **cut_key(ar_key('花見',                   0, 'つれていく')), message: 'よし！おはなみにいこっか！',                    **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 2), message: 'おはなみにきた！',                             **image_set("temp-hanami.png", "temp-hanami.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 3), message: '〈たまご〉「にー！んににー！」',                             **image_set("temp-hanami.png", "temp-hanami.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 4), message: '〈たまご〉「にににーに、んにににに！」',                             **image_set("temp-hanami.png", "temp-hanami.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 5), message: '〈たまご〉「にー！んにー、んにに！」',                             **image_set("temp-hanami.png", "temp-hanami.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 6), message: '〈たまご〉はたのしんでいるようだ！',                             **image_set("temp-hanami.png", "temp-hanami.png"),
      messages: [ '〈たまご〉はたのしんでいるようだ！', '〈たまご〉はさくらがきょうみぶかいみたい！', '〈たまご〉はさくらがきれいだといっている！', '〈たまご〉はしあわせをかんじているようだ！', '〈たまご〉はしぜんをだいじにしていきたいといっている！',
                  '〈たまご〉はたこやきがたべたいようだ！', '〈たまご〉ははるがすきらしい！', '〈たまご〉はこれからもっといろんなものをみたいらしい！', '〈たまご〉はたわいもないことをたのしそうにはなしている！', '〈たまご〉はきいてほしいはなしがいっぱいあるようだ！', '〈たまご〉はおこのみやきがたべたいようだ！',
                  '〈たまご〉はふってくるさくらをがんばってつかもうとしている！', '〈たまご〉はずっとむこうまでみにいきたいらしい！！', '〈たまご〉はまたつれてきてねといっている！', '〈たまご〉はやさしいきもちでいっぱいなようだ！' ] },
      { **cut_key(ar_key('花見',                   0, 'いかない')), message: 'しょぼん。',                    **image_set("temp-gakkari.png") },

      { **cut_key(ar_key('紅葉',                   0, 'つれていく')), message: 'よし！コウヨウをみにいこっか！',                    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('紅葉',                   0, 'つれていく'), 2), message: 'コウヨウをみにきた！',                             **image_set("temp-kouyou.png", "temp-kouyou.png") },
      { **cut_key(ar_key('紅葉',                   0, 'つれていく'), 3), message: '〈たまご〉「んにー！」',                             **image_set("temp-kouyou.png", "temp-kouyou.png") },
      { **cut_key(ar_key('紅葉',                   0, 'つれていく'), 4), message: '〈たまご〉「んにに！にー！」',                             **image_set("temp-kouyou.png", "temp-kouyou.png") },
      { **cut_key(ar_key('紅葉',                   0, 'つれていく'), 5), message: '〈たまご〉はたのしんでいるようだ！',                             **image_set("temp-kouyou.png", "temp-kouyou.png"),
      messages: [ '〈たまご〉はたのしんでいるようだ！', '〈たまご〉はおちばをあつめている！', '〈たまご〉はおおはしゃぎ！', '〈たまご〉はいまのコウヨウのいろみがすきなようだ！', '〈たまご〉はコウヨウのうつくしさにかんどうしている！',
                  '〈たまご〉はニコニコだ！', '〈たまご〉はあきがすきらしい！', '〈たまご〉はこれからもっといろんなものをみたいらしい！', '〈たまご〉はおちばをじまんしている！', '〈たまご〉はなぜはっぱのいろがうつりかわるのか、ふしぎなようだ！', 'またこんどもこようね！',
                  '〈たまご〉はふってくるおちばをつかまえるのがすきらしい！', '〈たまご〉はここにいるとココロがおちつくようだ！', '〈たまご〉はまたつれてきてねといっている！', '〈たまご〉はせいめいのとうとさをかんじているようだ！' ] },
      { **cut_key(ar_key('紅葉',                   0, 'いかない')), message: 'しょぼん。',                    **image_set("temp-gakkari.png") },

      { **cut_key(ar_key('年始',                   0, 'すすむ')), message: '〈たまご〉「ににににに、んにににー！」',                    **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('年始',                   0, 'すすむ'), 2), message: '〈たまご〉「にににに、ににににー！」',                     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('年始',                   0, 'すすむ'), 3), message: 'あけましておめでとう！',                                 **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('年始',                   0, 'すすむ'), 4), message: 'ことしもよろしくね、〈たまご〉！',                                   **image_set("temp-nikoniko2.png") },

      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'そっとする')), message: '〈たまご〉はたのしそうにあそんでいる！',                **image_set("temp-building_blocks.png") },
      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'よしよしする')), message: '〈たまご〉はうれしそう！',                             **image_set("temp-building_blocks_nikoniko.png") },
      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'ちょっかいをだす')), message: '〈たまご〉がおこってしまった！',                       **image_set("temp-okoru.png") },
      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'ブロックをくずす')), message: 'あー！ほんとにブロックをくずしちゃった！これはひどい！', **image_set("temp-okoru.png") },

      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'ちょっかいをだす', 2)), message: '〈たまご〉はちょっといやそう。', **image_set("temp-hukigen.png") },
      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'ブロックをくずす', 2)), message: '〈たまご〉にそしされた。',       **image_set("temp-building_blocks.png") },

      { **cut_key(ar_key('マンガに夢中', 0, 'そっとする')), message: '〈たまご〉はマンガがおもしろいようだ。',                     **image_set("temp-comics.png") },
      { **cut_key(ar_key('マンガに夢中', 0, 'よしよしする')), message: '〈たまご〉はうれしそう！',                                  **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('マンガに夢中', 0, 'はなしかける')), message: '〈たまご〉はマンガにしゅうちゅうしたいみたい。ごめんごめん。', **image_set("temp-hukigen.png") },
      { **cut_key(ar_key('マンガに夢中', 0, 'マンガをとりあげる')), message: '〈たまご〉がおこってしまった！',                            **image_set("temp-okoru.png") },

      { **cut_key(ar_key('マンガに夢中', 0, 'はなしかける',  2)), message: '〈たまご〉はニコニコしている。',                            **image_set("temp-nikoniko2.png") },

      { **cut_key(ar_key('眠そう', 0, 'ねかせる')), message: 'きょうはもうねようね！〈たまご〉おやすみ！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('眠そう', 0, 'ねかせる',    2)), message: 'まだもうちょっとおきてたいみたい。',        **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'よしよしする')), message: '〈たまご〉はうれしそうだ！',               **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('眠そう', 0, 'よしよしする'), 2), message: '〈たまご〉はおふとんにはいってねた！',      **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('眠そう', 0, 'よしよしする', 2)), message: '〈たまご〉はよろこんでいる！',             **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('眠そう', 0, 'はみがきをさせる')), message: 'よし、よくみがこうね！',                   **image_set("temp-hamigaki.png") },
      { **cut_key(ar_key('眠そう', 0, 'はみがきをさせる'), 2), message: '〈たまご〉はちゃんとはみがきしておやすみした！', **image_set("temp-hamigaki.png") },
      { **cut_key(ar_key('眠そう', 0, 'はみがきをさせる',   2)), message: 'はみがきしたくないみたい。まったくー！',     **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう')), message: 'チーターががけから・・・',                 **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう'), 2), message: 'おっこちーたー！！',                       **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう'), 3), message: '〈たまご〉はおおわらいした！',             **image_set("temp-warau.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 2)), message: 'アルミかんのうえに・・・',                 **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 2), 2), message: 'あるミカン！！',                          **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 2), 3), message: '〈たまご〉がちょっとひいてる・・・。',      **image_set("temp-donbiki.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 3)), message: 'ふとんが・・・',                          **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 3), 2), message: 'ふっとんだ！！',                          **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 3), 3), message: 'わらわない・・・。',                       **image_set("temp-sleepy.png") },

      { **cut_key(ar_key('寝かせた', 0, 'そっとする')), message: 'きもちよさそうにねているなあ。',      **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 0, 'よしよしする')), message: 'よしよし、りっぱにそだちますように。', **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 0, 'たたきおこす')), message: 'できるわけないだろ！！',              **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 0, 'ゴミばこのなかをのぞく')), message: 'はなをかんだティッシュがいっぱい！',   **image_set("temp-sleep.png"),
      messages: [ 'はなをかんだティッシュがいっぱい！', 'だが、からっぽだ！', 'しっかりブンベツされている！', 'テレビばんぐみひょうだ。うらないばんぐみは、まいあさやっているようだ。', 'テレビばんぐみひょうだ。『タマモン』は、げつようびのよる7じからやっているようだ。', 'テレビばんぐみひょうだ。『ニワトリビアのみずうみ』は、すいようびのよる8じからやっているようだ。', 'テレビばんぐみひょうだ。『タマえもん』は、きんようびのよる7じからやっているようだ。',
                  'メモがきだ。「とっくんをしたくなると、はなしかけようとしてくる」だって。', 'メモがきだ。「れんぞくでべんきょうや、ボールあそびするとつかれちゃう」だって。', 'メモがきだ。「つかれても、じかんがたてばもとどおり」だって。', 'メモがきだ。「ごはんをあげると、ちょっとずつたいりょくがつく」だって。', 'メモがきだ。「おやつではたいりょくはつかない」だって。', 'メモがきだ。「げいじゅつせいはバクハツからやってくる」だって。', 'メモがきだ。「ダジャレがウケなくても、あきらめるな」だって。',
                  'メモがきだ。「このあたりは、はるになるとサクラがきれい」だって。', 'メモがきだ。「このあたりは、あきになるとコウヨウがきれい」だって。', 'メモがきだ。「せんぷうき、あります」だって。', 'メモがきだ。「コタツ、あります」だって。', 'メモがきだ。「しっぱいしたって、せいちょうしないわけじゃない」だって。', 'メモがきだ。「L-I-N-E/35894421」だって。', 'メモがきだ。「メモがきをゴミばこにすてておこう」だって。', 'メモがきだ。「メモがきのなかにはゴクヒのものもある」だって。' ] },
      { **cut_key(ar_key('寝かせた', 1, 'そっとする')), message: 'きもちよさそうにねているなあ。',      **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 1, 'よしよしする')), message: 'よしよし、りっぱにそだちますように。', **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 1, 'たたきおこす')), message: 'できるわけないだろ！！',              **image_set("temp-sleep.png") },

      { **cut_key(ar_key('怒っている', 0, 'よしよしする')), message: '〈たまご〉はよろこんでいる！',     **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('怒っている', 0, 'よしよしする'), 2), message: '〈たまご〉はゆるしてくれた！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('怒っている', 0, 'よしよしする', 2)), message: '〈たまご〉はゆるしてくれない！！', **image_set("temp-okoru.png") },
      { **cut_key(ar_key('怒っている', 0, 'おやつをあげる')), message: '〈たまご〉はよろこんでいる！',     **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('怒っている', 0, 'おやつをあげる'), 2), message: '〈たまご〉はゆるしてくれた！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('怒っている', 0, 'おやつをあげる', 2)), message: 'おやつじゃゆるしてくれない！',     **image_set("temp-okoru.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする')), message: 'こんしんのへんがお！',             **image_set("temp-hengao.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする'), 2), message: '〈たまご〉「キャッキャッ！」',      **image_set("temp-warau.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする'), 3), message: '大ウケした！',                    **image_set("temp-warau.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする', 2)), message: 'こんしんのへんがお！',             **image_set("temp-hengao.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする', 2), 2), message: '〈たまご〉「・・・。」',             **image_set("temp-donbiki.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする', 2), 3), message: 'すべった。',                      **image_set("temp-donbiki.png") },
      { **cut_key(ar_key('怒っている', 0, 'あやまる')), message: 'ごめんよ・・・。',                **image_set("temp-gomen.png") },
      { **cut_key(ar_key('怒っている', 0, 'あやまる'), 2), message: '〈たまご〉はゆるしてくれた！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('怒っている', 0, 'あやまる',     2)), message: 'ごめんよ・・・。',                **image_set("temp-gomen.png") },
      { **cut_key(ar_key('怒っている', 0, 'あやまる',     2), 2), message: '〈たまご〉はまだおこっている！',    **image_set("temp-okoru.png") },

      { **cut_key(ar_key('算数',      1,  '〈A〉')), message: 'おー！せいかい！いいちょうしだね！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('算数',      1,  '〈B〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      1,  '〈C〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      1,  '〈D〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },

      { **cut_key(ar_key('算数',      2,  '〈A〉')), message: 'おー！せいかい！いいちょうしだね！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('算数',      2,  '〈B〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      2,  '〈C〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      2,  '〈D〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },

      { **cut_key(ar_key('算数',      3,  '〈A〉')), message: 'おー！せいかい！いいちょうしだね！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('算数',      3,  '〈B〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      3,  '〈C〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      3,  '〈D〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },

      { **cut_key(ar_key('算数',      4,  '〈A〉')), message: 'おー！せいかい！いいちょうしだね！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('算数',      4,  '〈B〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      4,  '〈C〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      4,  '〈D〉')), message: 'ちがうよー！ざんねん！',     **image_set("temp-ochikomu.png") },

      { **cut_key(ar_key('ボール遊び',      2,  'ひだりだ！')), message: 'おー！きれいにキャッチ！',     **image_set("temp-ball4.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'そこだ！')), message: 'なんとかキャッチ！',           **image_set("temp-ball4.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'そこだ！', 2)), message: 'あちゃー！',                  **image_set("temp-ball7.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'みぎだ！')), message: 'あちゃー！',                  **image_set("temp-ball10.png") },

      { **cut_key(ar_key('ボール遊び',      2,  'ひだりだ！'), 2), message: '〈たまご〉じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'そこだ！'), 2), message: '〈たまご〉じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'そこだ！', 2), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'みぎだ！'), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },

      { **cut_key(ar_key('ボール遊び',      3,  'ひだりだ！')), message: 'なんとかキャッチ！',           **image_set("temp-ball8.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'ひだりだ！',   2)), message: 'あちゃー！',                  **image_set("temp-ball5.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'そこだ！')), message: 'おー！きれいにキャッチ！',     **image_set("temp-ball8.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'みぎだ！')), message: 'なんとかキャッチ！',           **image_set("temp-ball8.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'みぎだ！', 2)), message: 'あちゃー！',                  **image_set("temp-ball11.png") },

      { **cut_key(ar_key('ボール遊び',      3,  'ひだりだ！'), 2), message: '〈たまご〉じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'ひだりだ！',   2), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'そこだ！'), 2), message: '〈たまご〉じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'みぎだ！'), 2), message: '〈たまご〉じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'みぎだ！', 2), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },

      { **cut_key(ar_key('ボール遊び',      4,  'ひだりだ！')), message: 'あちゃー！',                  **image_set("temp-ball6.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'そこだ！')), message: 'なんとかキャッチ！',           **image_set("temp-ball12.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'そこだ！', 2)), message: 'あちゃー！',                  **image_set("temp-ball9.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'みぎだ！')), message: 'おー！きれいにキャッチ！',     **image_set("temp-ball12.png") },

      { **cut_key(ar_key('ボール遊び',      4,  'ひだりだ！'), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'そこだ！'), 2), message: '〈たまご〉じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'そこだ！', 2), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'みぎだ！'), 2), message: '〈たまご〉じょうずだねえ！',    **image_set("temp-nikoniko.png") },

      { **cut_key(ar_key('特訓',      0,  'さんすう')), message: 'とっくんはれんぞく20もんになるぞ！',      **image_set("temp-bikkuri.png") },
      { **cut_key(ar_key('特訓',      0,  'さんすう',        2)), message: 'このとっくんは〈たまご〉にはまだはやい！', **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('特訓',      0,  'ボールあそび')), message: 'とっくんは3かいしっぱいするまでつづくぞ！', **image_set("temp-bikkuri.png") },
      { **cut_key(ar_key('特訓',      0,  'ボールあそび',    2)), message: 'このとっくんは〈たまご〉にはまだはやい！', **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('特訓',      0,  'やっぱやめておく')), message: 'いや、いまはやっぱやめておこう。',        **image_set("temp-normal.png") },
      { **cut_key(ar_key('特訓',      1,  'すすむ')), message: 'けっかは・・・。',                      **image_set("temp-tukareta.png") },

      { **cut_key(ar_key('イントロ',   0,  'すすむ')), message: 'あんたが・・・',                  **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   0,  'すすむ'), 2), message: '〈ユーザー〉だな！',               **image_set("temp-niwatori.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   0,  'すすむ'), 3), message: 'これからよろしくな！',             **image_set("temp-niwatori.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   0,  'すすむ'), 4), message: 'おれはみてのとおり、ヒヨコだ！',    **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   1,  'えっ？')), message: 'えっ・・・。',                      **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   1,  'まさか！')), message: 'なに・・・！？',                    **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   1,  'うーん')), message: 'こら、うそでもかっこいいですといえ！', **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   1,  'かっこいいです')), message: 'そうだろ？うんうん！',               **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   2,  'すすむ')), message: 'きょうからあんたには、このたまごといっしょにくらしてもらうぞ！', **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   2,  'すすむ'), 2), message: 'なまえはたしか・・・。',                                     **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   3,  'ちゃんをつけて！')), message: 'わかったわかった！',              **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   3,  'くんをつけて！')), message: 'わかったわかった！',              **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   3,  'さまをつけて！')), message: 'わかったわかった！',              **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   4,  'すすむ')), message: 'おなかがへってもなくし、さびしくなってもなく！',                              **image_set("temp-hiyoko-tuyoimagao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 2), message: 'またよるはとうぜんねむくなるし、じかんたいによってこうどうパターンがかわるぞ。', **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 3), message: '〈たまご〉はあそびだしたり、なにかにムチュウになると',                        **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 4), message: 'しばらくそれにしかキョウミがなくなるが',                                     **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 5), message: 'そういうときはしばらくそっとしてやってくれ。じかんをあけて、ようすをみてあげるんだ。', **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 6), message: 'あとおなじことをしてあげても、はんのうがそのときそのときでかわったりするから',   **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 7), message: 'まあとにかくたくさんせっしてみてくれよな。',                                  **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 8), message: 'そうそう。',                                                               **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 9), message: 'これは『LINEログイン』をりようしているばあいのはなしなんだが、',                **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 10), message: 'じつは『LINE』をつうじて〈たまご〉とおはなしすることができるんだ！',            **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 11), message: '『せってい』がめんから『LINEともだちついか』ができるからカクニンしてみてくれよな。', **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 12), message: '『ごはんだよ！』とメッセージをおくるとごはんをあげられたり、なにかとべんりだぞ。', **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 13), message: 'おっと、いけねえ。',                                                        **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 14), message: 'このあとちょっとよていがあるから、オレはもういくな。',                         **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 15), message: '〈たまご〉のこと、だいじにしてくれよ！',                                      **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 16), message: 'いってしまった。',                                                          **image_set("temp-none.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 17), message: '〈たまご〉のめんどう、うまくみれるかな～。',                                   **image_set("temp-none.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 18), message: '・・・。',                                                                 **image_set("temp-none.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'すすむ'), 19), message: 'とりあえず、まずはこえをかけてみよう。',                                     **image_set("temp-normal.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   5,  'こんにちは！')), message: 'あ！へんじしてくれなかった！', **image_set("temp-mewosorasu.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   5,  'なかよくしてね！')), message: 'あ！へんじしてくれなかった！', **image_set("temp-mewosorasu.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   6,  'よっ！')), message: 'あ！まためをそらした！', **image_set("temp-mewosorasu.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   6,  'なかよくたのむぜ！')), message: 'あ！まためをそらした！', **image_set("temp-mewosorasu.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   7,  'こんにちは！')), message: 'うぐぐ～！', **image_set("temp-mewosorasu.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   7,  'なかよくしてね！')), message: 'うぐぐ～！', **image_set("temp-mewosorasu.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   7,  'よしよし')), message: '〈たまご〉「んに～！」',         **image_set("temp-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   7,  'よしよし'), 2), message: '・・・！',                     **image_set("temp-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   7,  'よしよし'), 3), message: 'なんだ！けっこうすなおじゃん！',                    **image_set("temp-nikoniko2.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   7,  'よしよし'), 4), message: 'とにかく、ちょっときょりがちじまったきがする！',      **image_set("temp-nikoniko2.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   7,  'よしよし'), 5), message: 'これからよろしくね、〈たまご〉！',                    **image_set("temp-nikoniko2.png", "temp-in-house.png") },

      { **cut_key(ar_key('誕生日',     0,  'すすむ')), message: '〈たまご〉「にににーに・・・」', **image_set("temp-maekagami.png") },
      { **cut_key(ar_key('誕生日',     0,  'すすむ'), 2), message: '〈たまご〉「ににににー！！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     0,  'すすむ'), 3), message: 'あ！〈たまご〉がたんじょうびをいわってくれた！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     0,  'すすむ'), 4), message: '〈たまご〉「ににににに、んににに、ににーに？」', **image_set("temp-nikoniko2.png") },

      { **cut_key(ar_key('誕生日',     1,  'たのしくすごす！')), message: '〈たまご〉「ににー！にー、にににーにんににーに！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'たのしくすごす！'), 2), message: 'ワクワクがいっぱいのいちねんになりますよう！',      **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'えがおですごす！')), message: '〈たまご〉「ににー！にー、にににーにんににーに！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'えがおですごす！'), 2), message: 'ワクワクがいっぱいのいちねんになりますよう！',      **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'せいちょうする！')), message: '〈たまご〉「ににー！にー、にににーにんににーに！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'せいちょうする！'), 2), message: 'すてきないちねんになりますよう！',                **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'ひとをだいじにする！')), message: '〈たまご〉「ににー！にー、にににーにんににーに！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'ひとをだいじにする！'), 2), message: 'すてきないちねんになりますよう！',                **image_set("temp-nikoniko2.png") },

      { **cut_key(ar_key('タマモンカート', 0,  'ながめている')), message: '〈たまご〉「ににー！」',                          **image_set("temp-game-nikoniko.png"),
      messages: [ '〈たまご〉「ににー！」', '〈たまご〉「にっにに～！」', '〈たまご〉「んにー！ににー！」', 'いま、だいにんきのタマモンカートだ！', 'いいぞ！はやいぞー！', 'おいぬけー！', 'アイテムをとった！これはきょうりょく！', 'さいきんのレースゲームは、りんじょうかんがすごい！', 'はやすぎてめがまわるー！',
                  'ライバルにおいぬかれた！まけるなー', 'ふくざつなコースだ！ぶつからずはしれるか！？', '〈たまご〉はレースゲームにだいこうふん！', '〈たまご〉はレースゲームがだいすき！おとなになったら、ほんとのクルマものりたいね！', 'いいスタートだ！はやいぞー！', 'レースゲームなのにコースにバナナのカワがおちている！あぶないなあ！',
                  'いいドリフト！かっこいいー！', 'いいカソク！そのままおいぬけー！', 'げんざいトップだ！ライバルをきりはなせ！', 'あー！カートがカベにぶつかってる！！', 'はやいぞー！・・・って、ぎゃくそうしてない！？', 'レースゲームといったら、やっぱタマモンカートだよね！' ] },
      { **cut_key(ar_key('タマモンカート', 0,  'ながめている',  2)), message: '〈たまご〉「ににー！」',                          **image_set("temp-game-ochikomu.png"),
      messages: [ 'あちゃー！おいぬかれたー！', 'あー！ビリじゃんー！', 'ライバルにこうげきされた！あちゃー！', 'なかなかいいアイテムがでないようだ！', 'カートがスピンしちゃった！あれれー！' ] }
    ]

    cuts.each do |attrs|
      set    = EventSet.find_by!(name: attrs[:event_set_name])
      event  = Event.find_by!(event_set: set, derivation_number: attrs[:derivation_number])
      choice = ActionChoice.find_by!(event: event, label: attrs[:label])
      result = ActionResult.find_by!(action_choice: choice, priority: attrs[:priority])

      cut = Cut.find_or_initialize_by(action_result: result, position: attrs[:position])
      cut.message          = attrs[:message]
      if attrs[:messages].present?
        cut.messages = attrs[:messages]
      end
      cut.character_image  = attrs[:character_image]
      cut.background_image = attrs[:background_image]
      cut.save!
    end

    User.find_each do |user|
      UserStatus.find_or_create_by!(user: user) do |status|
        status.hunger_value   = 50
        status.happiness_value = 10
        status.love_value     = 50
        status.mood_value     = 0
        status.sports_value   = 0
        status.art_value      = 0
        status.money          = 0
        status.arithmetic         = 0
        status.arithmetic_effort  = 0
        status.japanese           = 0
        status.japanese_effort    = 0
        status.science            = 0
        status.science_effort     = 0
        status.social_studies     = 0
        status.social_effort      = 0
      end

      PlayState.find_or_create_by!(user: user) do |ps|
        first_set   = EventSet.find_by!(name: 'イントロ')
        first_event = Event.find_by!(event_set: first_set, derivation_number: 0)
        ps.current_event_id         = first_event.id
        ps.action_choices_position  = nil
        ps.action_results_priority  = nil
        ps.current_cut_position     = nil
      end

      EventTemporaryDatum.find_or_create_by!(user: user) do |etd|
        etd.reception_count = 0
        etd.success_count = 0
        etd.started_at = nil
      end
    end
  end
end

Seeds.run!
