module Seeds
  module_function
  def always          = { "always" => true }.freeze
  def prob(p)         = { "type" => "probability", "percent" => p }.freeze
  def prob_only(p)    = { "operator" => "and", "conditions" => [ prob(p) ] }.freeze
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
  def set_deriv(set, deriv = 0)                 = { event_set_name: set, derivation_number: deriv }
  def ar_key(set, deriv, label, prio = 1)       = { event_set_name: set, derivation_number: deriv, label: label, priority: prio }
  def cut_key(ar_key, pos = 1)                  = { **ar_key, position: pos }

  def s_l(set_deriv, label = 'つぎへ')  = { **set_deriv, labels: [ label ] }
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
      { name: 'ゲーム',    description: 'ゲーム',                                             loop_minutes: 30   },
      { name: '質問',     description: '質問',                                                loop_minutes: nil  },
      { name: 'マニュアル', description: 'マニュアル',                                         loop_minutes: nil  }
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
      { category_name: 'ゲーム',     name: 'タマモンカート' },
      { category_name: '質問',       name: '元気ない？' },
      { category_name: 'マニュアル',  name: 'マニュアル' }
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
        trigger_conditions: and_(status("mood_value", "==", 100))
      },
      {
        name: 'ボーっとしている',
        trigger_conditions: prob_only(12)
      },
      {
        name: 'ニコニコしている',
        trigger_conditions: prob_only(9)
      },
      {
        name: 'ゴロゴロしている',
        trigger_conditions: prob_only(6)
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
        trigger_conditions: and_(time_range(22, 14, 2, 0, [ off_fm(14, 43, 60), off_tm(5, 17, 60) ]))
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
      },
      {
        name: '元気ない？',
        daily_limit: 1,
        trigger_conditions: and_(time_range(10, 30, 13, 30, [ off_fm(5, 193, 540), off_tm(5, 193, 540) ]), weekday([ 2, 4, 6 ]),
                                 status("hunger_value", ">", 70), status("love_value", "==", 100), status("happiness_value", ">", 60),
                                 status("mood_value", "==", 100))
      },
      {
        name: 'マニュアル',
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
        message:           '〈たまご〉が なにか いっているよ。',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    '何かしたそう',
        name:              'べんきょうする',
        derivation_number: 1,
        message:           'よし！ なんの べんきょうを しよう？',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '何かしたそう',
        name:              '何かしたそう',
        derivation_number: 0,
        message:           '〈たまご〉は なにか したそうだ。',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    '何かしたそう',
        name:              'ゲームさせてあげる？',
        derivation_number: 2,
        message:           '（30ぷんかん、 かまって もらえなくなるけど いい？）',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    'ボーっとしている',
        name:              'ボーっとしている',
        derivation_number: 0,
        message:           '〈たまご〉は ボーっと している。',
        **image_set("temp-hidariwomiru.png")
      },
      {
        event_set_name:    'ニコニコしている',
        name:              'ニコニコしている',
        derivation_number: 0,
        message:           '〈たまご〉は ニコニコしている。',
        **image_set("temp-suwatte-nikoniko.png")
      },
      {
        event_set_name:    'ゴロゴロしている',
        name:              'ゴロゴロしている',
        derivation_number: 0,
        message:           '〈たまご〉は ゴロゴロ している。',
        **image_set("temp-gorogoro.png")
      },
      {
        event_set_name:    '踊っている',
        name:              '踊っている',
        derivation_number: 0,
        message:           '〈たまご〉は おどっている！',
        **image_set("temp-dance.png")
      },
      {
        event_set_name:    '泣いている(空腹)',
        name:              '泣いている(空腹)',
        derivation_number: 0,
        message:           '〈たまご〉が ないている！',
        **image_set("temp-naku.png")
      },
      {
        event_set_name:    '泣いている(よしよし不足)',
        name:              '泣いている(よしよし不足)',
        derivation_number: 0,
        message:           '〈たまご〉が ないている！',
        **image_set("temp-naku.png")
      },
      {
        event_set_name:    '泣いている(ランダム)',
        name:              '泣いている(ランダム)',
        derivation_number: 0,
        message:           '〈たまご〉が ないている！',
        **image_set("temp-naku.png")
      },
      {
        event_set_name:    '怒っている',
        name:              '怒っている',
        derivation_number: 0,
        message:           '〈たまご〉は おこっている！',
        **image_set("temp-okoru.png")
      },
      {
        event_set_name:    '寝ている',
        name:              '寝ている',
        derivation_number: 0,
        message:           '〈たまご〉は ねている。',
        **image_set("temp-sleep.png")
      },
      {
        event_set_name:    'ブロックのおもちゃに夢中',
        name:              'ブロックのおもちゃに夢中',
        derivation_number: 0,
        message:           '〈たまご〉は ブロックの おもちゃに むちゅうだ。',
        **image_set("temp-building_blocks.png")
      },
      {
        event_set_name:    'マンガに夢中',
        name:              'マンガに夢中',
        derivation_number: 0,
        message:           '〈たまご〉は マンガを よんでいる。',
        **image_set("temp-comics.png")
      },
      {
        event_set_name:    '眠そう',
        name:              '眠そう',
        derivation_number: 0,
        message:           '〈たまご〉は ねむそうに している。',
        **image_set("temp-sleepy.png")
      },
      {
        event_set_name:    '寝かせた',
        name:              '寝かせた',
        derivation_number: 0,
        message:           '〈たまご〉は ねている。',
        **image_set("temp-sleep.png")
      },
      {
        event_set_name:    '寝かせた',
        name:              '寝かせた（ゴミ箱なし）',
        derivation_number: 1,
        message:           '〈たまご〉は ねている。',
        **image_set("temp-sleep.png")
      },
      {
        event_set_name:    '寝起き',
        name:              '寝起き',
        derivation_number: 0,
        message:           '〈たまご〉が おきたようだ！',
        **image_set("temp-wakeup.png")
      },
      {
        event_set_name:    '寝起き',
        name:              '起こす、1回目の警告',
        derivation_number: 1,
        message:           'おきにいりの ハードロック ミュージックでも かけっちゃおっかなー？',
        **image_set("temp-wakeup.png")
      },
      {
        event_set_name:    '寝起き',
        name:              '起こす、2回目の警告',
        derivation_number: 2,
        message:           'ほんとに かけるの？',
        **image_set("temp-wakeup.png")
      },
      {
        event_set_name:    '寝起き',
        name:              '起こす、3回目の警告',
        derivation_number: 3,
        message:           'ほんとに いいんですね？',
        **image_set("temp-wakeup.png")
      },
      {
        event_set_name:    '占い',
        name:              '占い',
        derivation_number: 0,
        message:           'テレビで うらないを やってる！',
        **image_set("temp-TV1.png")
      },
      {
        event_set_name:    'タマモン',
        name:              'タマモンがやっている',
        derivation_number: 0,
        message:           '〈たまご〉は タマモンが みたいらしい。 どうする？',
        **image_set("temp-TV3.png")
      },
      {
        event_set_name:    'タマモン',
        name:              'タマモンを見ている',
        derivation_number: 1,
        message:           '〈たまご〉は タマモンを みている！',
        **image_set("temp-TV6.png")
      },
      {
        event_set_name:    'タマえもん',
        name:              'タマえもんがやっている',
        derivation_number: 0,
        message:           '〈たまご〉は タマえもんが みたいらしい。 どうする？',
        **image_set("temp-TV3.png")
      },
      {
        event_set_name:    'タマえもん',
        name:              'タマえもんを見ている',
        derivation_number: 1,
        message:           '〈たまご〉は タマえもんを みている！',
        **image_set("temp-TV6.png")
      },
      {
        event_set_name:    'ニワトリビアの湖',
        name:              'ニワトリビアの湖がやっている',
        derivation_number: 0,
        message:           '〈たまご〉は ニワトリビアの みずうみが みたいらしい。 どうする？',
        **image_set("temp-TV3.png")
      },
      {
        event_set_name:    'ニワトリビアの湖',
        name:              'ニワトリビアの湖を見ている',
        derivation_number: 1,
        message:           '〈たまご〉は ニワトリビアの みずうみを みている！',
        **image_set("temp-TV6.png")
      },
      {
        event_set_name:    '扇風機',
        name:              '扇風機',
        derivation_number: 0,
        message:           '〈たまご〉は すずんでいる！',
        **image_set("temp-senpuuki1.png")
      },
      {
        event_set_name:    'こたつ',
        name:              'こたつ',
        derivation_number: 0,
        message:           '〈たまご〉は こたつで ヌクヌク している！',
        **image_set("temp-kotatu1.png")
      },
      {
        event_set_name:    '花見',
        name:              '花見',
        derivation_number: 0,
        message:           '〈たまご〉は おはなみに いきたい みたい。',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    '紅葉',
        name:              '紅葉',
        derivation_number: 0,
        message:           '〈たまご〉は コウヨウを みにいきたい みたい。',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    '年始',
        name:              '年始',
        derivation_number: 0,
        message:           'たまご 「にー！！」',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '算数',
        name:              '出題前',
        derivation_number: 0,
        message:           'よし、 さんすうの もんだいに ちょうせんだ！',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '算数',
        name:              '1つ目が正解',
        derivation_number: 1,
        message:           '「X 演算子 Y」の こたえは？',
        **image_set("temp-kangaeru.png")
      },
      {
        event_set_name:    '算数',
        name:              '2つ目が正解',
        derivation_number: 2,
        message:           '「X 演算子 Y」の こたえは？',
        **image_set("temp-kangaeru.png")
      },
      {
        event_set_name:    '算数',
        name:              '3つ目が正解',
        derivation_number: 3,
        message:           '「X 演算子 Y」の こたえは？',
        **image_set("temp-kangaeru.png")
      },
      {
        event_set_name:    '算数',
        name:              '4つ目が正解',
        derivation_number: 4,
        message:           '「X 演算子 Y」の こたえは？',
        **image_set("temp-kangaeru.png")
      },
      {
        event_set_name:    'ボール遊び',
        name:              '投球前',
        derivation_number: 0,
        message:           'ボール なげるよー！',
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
        message:           '〈たまご〉、 そっちだ！',
        **image_set("temp-ball3.png")
      },
      {
        event_set_name:    'ボール遊び',
        name:              '真ん中が成功',
        derivation_number: 3,
        message:           '〈たまご〉、 そっちだ！',
        **image_set("temp-ball3.png")
      },
      {
        event_set_name:    'ボール遊び',
        name:              '右が成功',
        derivation_number: 4,
        message:           '〈たまご〉、 そっちだ！',
        **image_set("temp-ball3.png")
      },
      {
        event_set_name:    '特訓',
        name:              '特訓',
        derivation_number: 0,
        message:           'なんの とっくんを しよう？',
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
        message:           '20もんちゅう 〈X〉もん せいかい！ 〈Y〉ふん 〈Z〉びょう クリア！ すごいね！',
        **image_set("temp-nikoniko.png")
      },
      {
        event_set_name:    '特訓',
        name:              '特訓結果良し',
        derivation_number: 3,
        message:           '20もんちゅう 〈X〉もん せいかい！ よくがんばったね！',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '特訓',
        name:              '特訓結果微妙',
        derivation_number: 4,
        message:           '20もんちゅう 〈X〉もん せいかい！ また ちょうせんしよう！',
        **image_set("temp-bimuyou.png")
      },
      {
        event_set_name:    '特訓',
        name:              'ボール遊び特訓結果良し',
        derivation_number: 5,
        message:           '〈X〉かい せいこう！ よくがんばったね！',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '特訓',
        name:              'ボール遊び特訓結果微妙',
        derivation_number: 6,
        message:           '〈X〉かい せいこう！ また ちょうせんしよう！',
        **image_set("temp-bimuyou.png")
      },
      {
        event_set_name:    'イントロ',
        name:              'イントロ開始',
        derivation_number: 0,
        message:           'よくきた！ まちくたびれたぞ！',
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
        message:           'まあ、 そんなことは さておきだな。',
        **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              'たまごのなまえ',
        derivation_number: 3,
        message:           '〈たまご〉、 だったな！',
        **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              'たまごのかいせつ',
        derivation_number: 4,
        message:           '〈たまご〉は とっても なきむしだ。',
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
        message:           'もういちど こえを かけてみよう！',
        **image_set("temp-normal.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              '声かけ3回目',
        derivation_number: 7,
        message:           'ぜんぜん しゃべって くれない！',
        **image_set("temp-normal.png", "temp-in-house.png")
      },
      {
        event_set_name:    'イントロ',
        name:              '仲良くなれそう',
        derivation_number: 8,
        message:           '・・・！',
        **image_set("temp-nikoniko.png", "temp-in-house.png")
      },
      {
        event_set_name:    '誕生日',
        name:              '誕生日',
        derivation_number: 0,
        message:           '〈たまご〉 「にー！」',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    '誕生日',
        name:              'どういう一年にする？',
        derivation_number: 1,
        message:           '「これからの いちねん、 どうすごしたい？」 って きいてるよ。',
        **image_set("temp-nikoniko2.png")
      },
      {
        event_set_name:    'タマモンカート',
        name:              'タマモンカート',
        derivation_number: 0,
        message:           '〈たまご〉は ゲーム 『タマモンカート』で あそんでいる！',
        **image_set("temp-game-nikoniko.png")
      },
      {
        event_set_name:    '元気ない？',
        name:              '元気ないのと聞いてくる',
        derivation_number: 0,
        message:           '〈たまご〉 「にに？ ににーにー、 んにに？」',
        **image_set("temp-tewoageru.png")
      },
      {
        event_set_name:    '元気ない？',
        name:              '元気ない？に対する返事',
        derivation_number: 1,
        message:           '『なんか げんきない？』と きかれている。',
        **image_set("temp-normal.png")
      },
      {
        event_set_name:    'マニュアル',
        name:              'マニュアルを手に取る',
        derivation_number: 0,
        message:           'ノートだ。 〈たまご〉について いろいろ まとめられている みたい。',
        **image_set("temp-manual.png")
      },
      {
        event_set_name:    'マニュアル',
        name:              'マニュアル1ページ目',
        derivation_number: 1,
        message:           'なにについて よむ？',
        **image_set("temp-manual.png")
      },
      {
        event_set_name:    'マニュアル',
        name:              'マニュアル2ページ目',
        derivation_number: 2,
        message:           'なにについて よむ？',
        **image_set("temp-manual.png")
      },
      {
        event_set_name:    'マニュアル',
        name:              'マニュアル3ページ目',
        derivation_number: 3,
        message:           'なにについて よむ？',
        **image_set("temp-manual.png")
      },
      {
        event_set_name:    'マニュアル',
        name:              'マニュアル4ページ目',
        derivation_number: 4,
        message:           'なにについて よむ？',
        **image_set("temp-manual.png")
      },
      {
        event_set_name:    'マニュアル',
        name:              'マニュアル5ページ目',
        derivation_number: 5,
        message:           'なにについて よむ？',
        **image_set("temp-manual.png")
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
      { **set_deriv('ボーっとしている'),        labels: [ 'ながめている',   'こえをかける', 'タンスのうえのノートをみる' ] },
      { **set_deriv('ニコニコしている'),        labels: [ 'ながめている', 'タンスのうえのノートをみる' ] },
      { **set_deriv('ゴロゴロしている'),        labels: [ 'ながめている', 'タンスのうえのノートをみる' ] },
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
      s_l(set_deriv('タマモン', 1), 'いっしょにみる'),
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
      s_l(set_deriv('イントロ', 8)),

      s_l(set_deriv('誕生日')),
      { **set_deriv('誕生日', 1),               labels: [ 'たのしくすごす！', 'えがおですごす！', 'せいちょうする！', 'ひとをだいじにする！' ] },
      s_l(set_deriv('タマモンカート'), 'ながめている'),
      s_l(set_deriv('元気ない？')),
      { **set_deriv('元気ない？', 1),           labels: [ 'そんなことないよ！', 'さいきんつかれてて', 'つらいことがあって', 'かなしいことがあって' ] },

      s_l(set_deriv('マニュアル')),
      { **set_deriv('マニュアル', 1),           labels: [ 'よむのをやめる',       'ごはん',                'よしよし',                 'ほか' ] },
      { **set_deriv('マニュアル', 2),           labels: [ 'ボールあそび',         'べんきょう',            'おえかき',                 'ほか' ] },
      { **set_deriv('マニュアル', 3),           labels: [ 'ゲーム',               'なつきぐあい',          'どういうときなく？',        'ほか' ] },
      { **set_deriv('マニュアル', 4),           labels: [ 'どういうときおこる？',  'なにかにむちゅうなとき', 'すいみん',                 'ほか' ] },
      { **set_deriv('マニュアル', 5),           labels: [ 'すきなテレビ',         'きせつによって',         'はなしをきいてあげると',    'ほか'  ] }
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
        effects:               effects_status([ "happiness_value", 1 ], [ "mood_value", 5 ]),
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
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 1 ], [ "mood_value", 5 ]),
        **next_ev
      },
      {
        **ar_key('何か言っている', 0, 'おやつをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 95)),
        effects:               effects_status([ "hunger_value", 30 ], [ "happiness_value", 5 ], [ "mood_value", 15 ]),
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
        effects:               effects_status([ "hunger_value", 40 ], [ "vitality", 1 ], [ "happiness_value", 1 ]),
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
        effects:               effects_status([ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'おえかきする', 3),
        trigger_conditions:    prob_only(88),
        effects:               effects_status([ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'おえかきする', 4),
        trigger_conditions:    prob_only(80),
        effects:               effects_status([ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'おえかきする', 5),
        trigger_conditions:    always,
        effects:               effects_status([ "art_value", 100 ], [ "happiness_value", 50 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 0, 'ゲームする'),
        trigger_conditions:    and_(status("sports_value", ">=", 1), status("vitality", ">=", 153)),
        effects:               {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('何かしたそう', 0, 'ゲームする', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('何かしたそう', 2, 'ゲームさせてあげる'),
        trigger_conditions:    always,
        effects:               effects_status([ "happiness_value", 10 ]),
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
        trigger_conditions:    prob_only(10),
        effects:               effects_status([ "japanese", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 5 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'こくご', 2),
        trigger_conditions:    prob_only(30),
        effects:               effects_status([ "japanese", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'こくご', 3),
        trigger_conditions:    always,
        effects:               effects_status([ "japanese_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'りか'),
        trigger_conditions:    prob_only(10),
        effects:               effects_status([ "science", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 5 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'りか', 2),
        trigger_conditions:    prob_only(30),
        effects:               effects_status([ "science", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'りか', 3),
        trigger_conditions:    always,
        effects:               effects_status([ "science_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'しゃかい'),
        trigger_conditions:    prob_only(10),
        effects:               effects_status([ "social_studies", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 5 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'しゃかい', 2),
        trigger_conditions:    prob_only(30),
        effects:               effects_status([ "social_studies", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('何かしたそう', 1, 'しゃかい', 3),
        trigger_conditions:    always,
        effects:               effects_status([ "social_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
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
        trigger_conditions: and_(status("happiness_value", "<=", 20)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 3),
        trigger_conditions: and_(status("happiness_value", "<=", 60)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 4),
        trigger_conditions: and_(status("happiness_value", "<=", 160)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 5),
        trigger_conditions: and_(status("happiness_value", "<=", 300)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 6),
        trigger_conditions: and_(status("happiness_value", "<=", 800)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 7),
        trigger_conditions: and_(status("happiness_value", "<=", 2000)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 8),
        trigger_conditions: and_(status("happiness_value", "<=", 5000)),
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'こえをかける', 9),
        trigger_conditions: always,
        effects: {}, **next_ev
      },
      {
        **ar_key('ボーっとしている', 0, 'タンスのうえのノートをみる'),
        trigger_conditions: always,
        effects: {}, **next_ev(call: 'マニュアル')
      },
      {
        **ar_key('ニコニコしている', 0, 'ながめている'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('ニコニコしている', 0, 'タンスのうえのノートをみる'),
        trigger_conditions: always,
        effects: {}, **next_ev(call: 'マニュアル')
      },
      {
        **ar_key('ゴロゴロしている', 0, 'ながめている'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('ゴロゴロしている', 0, 'タンスのうえのノートをみる'),
        trigger_conditions: always,
        effects: {}, **next_ev(call: 'マニュアル')
      },
      {
        **ar_key('踊っている', 0, 'よしよしする'),
        trigger_conditions:    prob_only(20),
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 10 ], [ "mood_value", -100 ]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('踊っている', 0, 'よしよしする', 2),
        trigger_conditions:    always,
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 3 ], [ "mood_value", -100 ]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('踊っている', 0, 'おやつをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 95)),
        effects:               effects_status([ "hunger_value", 30 ], [ "happiness_value", 15 ], [ "mood_value", -100 ]),
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
        effects:               effects_status([ "hunger_value", 40 ], [ "vitality", 1 ], [ "happiness_value", 3 ], [ "mood_value", -100 ]),
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
        effects:               effects_status([ "love_value", 5 ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('泣いている(空腹)', 0, 'おやつをあげる'),
        trigger_conditions:    always,
        effects:               effects_status([ "hunger_value", 40 ], [ "happiness_value", 5 ]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('泣いている(空腹)', 0, 'ごはんをあげる'),
        trigger_conditions:    always,
        effects:               effects_status([ "hunger_value", 50 ], [ "vitality", 1 ], [ "happiness_value", 5 ]),
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
        effects:               effects_status([ "love_value", 40 ], [ "happiness_value", 3 ]),
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
        effects:               effects_status([ "love_value", 30 ], [ "happiness_value", 3 ]),
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
        effects:               effects_status([ "love_value", 40 ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('寝ている', 0, 'たたきおこす'),
        trigger_conditions:    always,
        effects:               effects_status([ "happiness_value", -5 ]),
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
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('ブロックのおもちゃに夢中', 0, 'ちょっかいをだす'),
        trigger_conditions:    prob_only(20),
        effects:               effects_status([ "happiness_value", -5 ]),
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
        trigger_conditions:    prob_only(10),
        effects:               effects_status([ "happiness_value", -50 ]),
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
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 1 ]),
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
        effects:               effects_status([ "happiness_value", -30 ]),
        **next_ev(call: '怒っている', resolve: true)
      },
      {
        **ar_key('眠そう', 0, 'ねかせる'),
        trigger_conditions:    prob_only(35),
        effects:               effects_status([ "happiness_value", 10 ]),
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
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 1 ]),
        **next_ev(call: '寝かせた', resolve: true)
      },
      {
        **ar_key('眠そう', 0, 'よしよしする', 2),
        trigger_conditions:    always,
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('眠そう', 0, 'はみがきをさせる'),
        trigger_conditions:    prob_only(25),
        effects:               effects_status([ "happiness_value", 10 ]),
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
        effects:               effects_status([ "happiness_value", 20 ]),
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
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 10 ]),
        **next_ev(deriv: 1)
      },
      {
        **ar_key('寝かせた', 0, 'たたきおこす'),
        trigger_conditions:    always,
        effects:               effects_status([ "happiness_value", -5 ]),
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
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('寝かせた', 1, 'たたきおこす'),
        trigger_conditions:    always,
        effects:               effects_status([ "happiness_value", -5 ]),
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
        trigger_conditions:    prob_only(35),
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 1 ]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('寝起き', 0, 'よしよしする', 2),
        trigger_conditions:    always,
        effects:               effects_status([ "love_value", 10 ], [ "happiness_value", 1 ]),
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
        effects:               effects_status([ "happiness_value", -20 ]),
        **next_ev(call: '怒っている', resolve: true)
      },
      {
        **ar_key('寝起き', 3, 'いいえ'),
        trigger_conditions:    always,
        effects:               {},
        **next_ev(deriv: 0)
      },
      {
        **ar_key('占い', 0, 'つぎへ'),
        trigger_conditions: prob_only(10),
        effects: {},
        **next_ev
      },
      {
        **ar_key('占い', 0, 'つぎへ', 2),
        trigger_conditions: prob_only(33),
        effects: {},
        **next_ev
      },
      {
        **ar_key('占い', 0, 'つぎへ', 3),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('タマモン', 0, 'みていいよ'),
        trigger_conditions: always,
        effects: effects_status([ "happiness_value", 10 ]),
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
        effects: effects_status([ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('タマえもん', 0, 'みていいよ'),
        trigger_conditions: always,
        effects: effects_status([ "happiness_value", 10 ]),
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
        effects: effects_status([ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('ニワトリビアの湖', 0, 'みていいよ'),
        trigger_conditions: always,
        effects: effects_status([ "happiness_value", 10 ]),
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
        effects: effects_status([ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('扇風機', 0, 'よしよしする'),
        trigger_conditions: always,
        effects: effects_status([ "love_value", 10 ], [ "happiness_value", 2 ]),
        **next_ev
      },
      {
        **ar_key('扇風機', 0, 'スイカをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 95)),
        effects: effects_status([ "hunger_value", 30 ], [ "vitality", 3 ], [ "happiness_value", 10 ]),
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
        effects: effects_status([ "happiness_value", -1 ]),
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
        effects: effects_status([ "love_value", 10 ], [ "happiness_value", 2 ]),
        **next_ev
      },
      {
        **ar_key('こたつ', 0, 'ミカンをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 95)),
        effects: effects_status([ "hunger_value", 30 ], [ "vitality", 3 ], [ "happiness_value", 10 ]),
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
        effects: effects_status([ "happiness_value", -1 ]),
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
        effects: effects_status([ "happiness_value", 15 ]),
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
        effects: effects_status([ "happiness_value", 15 ]),
        **next_ev
      },
      {
        **ar_key('紅葉', 0, 'いかない'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('年始', 0, 'つぎへ'),
        trigger_conditions: always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('怒っている', 0, 'よしよしする'),
        trigger_conditions:    prob_only(25),
        effects:               effects_status([ "love_value", 10 ]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('怒っている', 0, 'よしよしする', 2),
        trigger_conditions:    always,
        effects:               effects_status([ "love_value", 3 ]),
        **next_ev
      },
      {
        **ar_key('怒っている', 0, 'おやつをあげる'),
        trigger_conditions:    and_(status("hunger_value", "<=", 50)),
        effects:               effects_status([ "hunger_value", 30 ]),
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
        effects:               effects_status([ "happiness_value", 1 ]),
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
        effects:               effects_status([ "happiness_value", 1 ]),
        **next_ev(resolve: true)
      },
      {
        **ar_key('怒っている', 0, 'あやまる', 2),
        trigger_conditions:    always,
        effects:               {},
        **next_ev
      },
      {
        **ar_key('算数', 0, 'つぎへ'),
        trigger_conditions: prob_only(25),
        effects: {},
        **next_ev(deriv: 1)
      },
      {
        **ar_key('算数', 0, 'つぎへ', 2),
        trigger_conditions: prob_only(33),
        effects: {},
        **next_ev(deriv: 2)
      },
      {
        **ar_key('算数', 0, 'つぎへ', 3),
        trigger_conditions: prob_only(50),
        effects: {},
        **next_ev(deriv: 3)
      },
      {
        **ar_key('算数', 0, 'つぎへ', 4),
        trigger_conditions: always,
        effects: {},
        **next_ev(deriv: 4)
      },
      {
        **ar_key('算数', 1, '〈A〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('算数', 1, '〈B〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 1, '〈C〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 1, '〈D〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 2, '〈A〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('算数', 2, '〈B〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 2, '〈C〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 2, '〈D〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 3, '〈A〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('算数', 3, '〈B〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 3, '〈C〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 3, '〈D〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 4, '〈A〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('算数', 4, '〈B〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 4, '〈C〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('算数', 4, '〈D〉'),
        trigger_conditions: always,
        effects: effects_status([ "arithmetic_effort", 1 ], [ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 0, 'つぎへ'),
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
        effects: effects_status([ "sports_value", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 2, 'そこだ！'),
        trigger_conditions: prob_only(50),
        effects: effects_status([ "sports_value", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 2, 'そこだ！', 2),
        trigger_conditions: always,
        effects: effects_status([ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 2, 'みぎだ！'),
        trigger_conditions: always,
        effects: effects_status([ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'ひだりだ！'),
        trigger_conditions: prob_only(30),
        effects: effects_status([ "sports_value", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'ひだりだ！', 2),
        trigger_conditions: always,
        effects: effects_status([ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'そこだ！'),
        trigger_conditions: always,
        effects: effects_status([ "sports_value", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'みぎだ！'),
        trigger_conditions: prob_only(30),
        effects: effects_status([ "sports_value", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 3, 'みぎだ！', 2),
        trigger_conditions: always,
        effects: effects_status([ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 4, 'ひだりだ！'),
        trigger_conditions: always,
        effects: effects_status([ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 4, 'そこだ！'),
        trigger_conditions: prob_only(50),
        effects: effects_status([ "sports_value", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 4, 'そこだ！', 2),
        trigger_conditions: always,
        effects: effects_status([ "temp_vitality", -VITALITY_UNIT ]),
        **next_ev
      },
      {
        **ar_key('ボール遊び', 4, 'みぎだ！'),
        trigger_conditions: always,
        effects: effects_status([ "sports_value", 1 ], [ "temp_vitality", -VITALITY_UNIT ], [ "happiness_value", 1 ]),
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
        **ar_key('特訓', 1, 'つぎへ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 2, 'つぎへ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 3, 'つぎへ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 4, 'つぎへ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 5, 'つぎへ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('特訓', 6, 'つぎへ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('イントロ', 0, 'つぎへ'),
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
        **ar_key('イントロ', 2, 'つぎへ'),
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
        **ar_key('イントロ', 4, 'つぎへ'),
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
        effects: effects_status([ "love_value", 10 ], [ "happiness_value", 1 ]),
        **next_ev(deriv: 8)
      },
      {
        **ar_key('イントロ', 8, 'つぎへ'),
        trigger_conditions:    always,
        effects: {},
        **next_ev
      },
      {
        **ar_key('誕生日', 0, 'つぎへ'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('誕生日', 1, 'たのしくすごす！'), trigger_conditions: always,
        effects: effects_status([ "happiness_value", 20 ]),
        **next_ev
      },
      {
        **ar_key('誕生日', 1, 'えがおですごす！'), trigger_conditions: always,
        effects: effects_status([ "happiness_value", 20 ]),
        **next_ev
      },
      {
        **ar_key('誕生日', 1, 'せいちょうする！'), trigger_conditions: always,
        effects: effects_status([ "happiness_value", 20 ]),
        **next_ev
      },
      {
        **ar_key('誕生日', 1, 'ひとをだいじにする！'), trigger_conditions: always,
        effects: effects_status([ "happiness_value", 20 ]),
        **next_ev
      },
      {
        **ar_key('タマモンカート', 0, 'ながめている'), trigger_conditions: prob_only(85),
        effects: {}, **next_ev
      },
      {
        **ar_key('タマモンカート', 0, 'ながめている', 2), trigger_conditions: always,
        effects: {}, **next_ev
      },
      {
        **ar_key('元気ない？', 0, 'つぎへ'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('元気ない？', 1, 'そんなことないよ！'), trigger_conditions: always,
        effects: effects_status([ "happiness_value", 10 ]), **next_ev
      },
      {
        **ar_key('元気ない？', 1, 'さいきんつかれてて'), trigger_conditions: always,
        effects: effects_status([ "happiness_value", 10 ]), **next_ev
      },
      {
        **ar_key('元気ない？', 1, 'つらいことがあって'), trigger_conditions: always,
        effects: effects_status([ "happiness_value", 10 ]), **next_ev
      },
      {
        **ar_key('元気ない？', 1, 'かなしいことがあって'), trigger_conditions: always,
        effects: effects_status([ "happiness_value", 10 ]), **next_ev
      },
      {
        **ar_key('マニュアル', 0, 'つぎへ'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 1, 'ごはん'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 1, 'よしよし'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 1, 'ほか'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 2)
      },
      {
        **ar_key('マニュアル', 1, 'よむのをやめる'), trigger_conditions: always,
        effects: {}, **next_ev
      },
      {
        **ar_key('マニュアル', 2, 'ボールあそび'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 2, 'べんきょう'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 2, 'おえかき'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 2, 'ほか'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 3)
      },
      {
        **ar_key('マニュアル', 3, 'ゲーム'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 3, 'なつきぐあい'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 3, 'どういうときなく？'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 3, 'ほか'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 4)
      },
      {
        **ar_key('マニュアル', 4, 'どういうときおこる？'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 4, 'なにかにむちゅうなとき'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 4, 'すいみん'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 4, 'ほか'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 5)
      },
      {
        **ar_key('マニュアル', 5, 'すきなテレビ'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 5, 'きせつによって'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 5, 'はなしをきいてあげると'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
      },
      {
        **ar_key('マニュアル', 5, 'ほか'), trigger_conditions: always,
        effects: {}, **next_ev(deriv: 1)
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
      { **cut_key(ar_key('何か言っている', 0, 'はなしをきいてあげる', 1), 1), message: '〈たまご〉 「ににに！ にににー！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何か言っている', 0, 'はなしをきいてあげる', 1), 2), message: 'さいきん、 ボールあそびが たのしいようだ！', **image_set("temp-nikoniko2.png"),
      messages: [ 'さいきん、 ボールあそびが たのしいようだ！', 'ちきゅうは まるいんだよ、 といっている。 まさか～！', 'しょうらいは パイロットに なりたいらしい！', '〈たまご〉は まいにちが たのしいらしい！', '〈ユーザー〉は おなかが まんまるだね、 といっている。 うるさい！',
                  'このまえ、 おとしよりの にもつを もって あげたんだって！ えらい！', 'みそラーメンより とんこつラーメン、 といっている。むずかしい ぎろんだ！', 'おとなになったら バイクに のってみたいらしい。 あんぜんうんてん するんだよ！', '〈たまご〉は きんようびの よるに やっている テレビばんぐみ、 タマえもんが すきらしい！', 'さいきん、 はしるのが はやくなったらしい！いつも チョロチョロ はしりまわってるもんね！', 'ともだちとの あいだで タマモンのゲームが はやっているらしい！', 'カレーライスは あまくちが すきらしい！ わかる！',
                  'ラッコさんって かわいいよね、 って いってる。 すいぞくかんに いるかなー？', 'タコには しんぞうが 3つあるらしい。 うそー！？', 'バナナは ベリーの なかまらしい！ ふーん！', 'カンガルーは うしろに すすめないらしい。 ふしぎー！', 'カタツムリの しょっかくは 4ほんあるらしい。 こんど よくみてみよう！', 'このまえ、 がいこくじんの ひとに みちあんない してあげたらしい！ ことばわかった？', 'チーズバーガーは ケチャップおおめが すきらしい！ わかってるじゃん！', 'このまえ、 れいぞうこの ケチャップ こっそり なめたらしい！ あー！！',
                  'おとは 1オクターブあがると、 しゅうはすうが 2ばいに なるらしい。 へー！', 'タンスに かくしてあった ポテチ おいしかったと いっている。 え！ とっておきのやつー！', 'じゅうどうって かっこいいよねって いっている。 つよい せいしんりょくが ひつようだぞ！', 'ダジャレの もちネタが 10こあるらしい。 まだまだだな！', 'こんど おんがくフェスに いきたいらしい！ さんせんしちゃう！？', 'ハンバーグの おいしさを かたっている！', 'からあげの おいしい おべんとうやが、 さいきん できたらしい！' ] },
      { **cut_key(ar_key('何か言っている', 0, 'はなしをきいてあげる', 2), 1), message: 'なになに？ うんうん。', **image_set("temp-komattakao.png") },
      { **cut_key(ar_key('何か言っている', 0, 'はなしをきいてあげる', 2), 2), message: '〈たまご〉は とっくんが したいと いっている！', **image_set("temp-yaruki.png") },
      { **cut_key(ar_key('何か言っている', 0, 'よしよしする',        1), 1), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('何か言っている', 0, 'おやつをあげる',      1), 1), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('何か言っている', 0, 'ごはんをあげる',      1), 1), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('何か言っている', 0, 'おやつをあげる',      2), 1), message: '〈たまご〉は おなかいっぱいの ようだ。', **image_set("temp-normal.png") },
      { **cut_key(ar_key('何か言っている', 0, 'ごはんをあげる',      2), 1), message: '〈たまご〉は おなかいっぱいの ようだ。', **image_set("temp-normal.png") },

      { **cut_key(ar_key('何かしたそう', 0, 'ボールあそびをする', 1), 1), message: 'よし！ ボールあそびを しよう！',                       **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'ボールあそびをする', 2), 1), message: '〈たまご〉は つかれている！ やすませて あげよう！',       **image_set("temp-hukigen.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'べんきょうする',     2), 1), message: '〈たまご〉は つかれている！ やすませて あげよう！',      **image_set("temp-hukigen.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       1), 1), message: 'おえかきをした！ じょうずに かけたね！',               **image_set("temp-ewokaita1.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       2), 1), message: 'おえかきをした！ 〈たまご〉は おえかきが じょうずだね！', **image_set("temp-ewokaita2.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       3), 1), message: 'おえかきをした！ これは なんだろう？',                 **image_set("temp-ewokaita3.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       4), 1), message: 'おえかきをした！ ん！？ なに かいてんだー！',            **image_set("temp-ewokaita4.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'おえかきする',       5), 1), message: 'おえかきをした！ ん！？ てんさい てきだーーー！！！',     **image_set("temp-ewokaita5.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'ゲームする',         1), 1), message: 'テレビゲームで あそばせて あげよっかな！',              **image_set("temp-normal.png") },
      { **cut_key(ar_key('何かしたそう', 0, 'ゲームする',         2), 1), message: 'いや、 まずは ほかのことを やらせてあげよう！',          **image_set("temp-normal.png") },
      { **cut_key(ar_key('何かしたそう', 2, 'ゲームさせてあげる',  1), 1), message: 'テレビゲームで あそんでいいよ！ 30ぷんかんね！',         **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 2, 'やっぱやめよう',     1), 1), message: 'やっぱゲームは またこんどかな！',                      **image_set("temp-okoru.png") },

      { **cut_key(ar_key('何かしたそう', 1, 'こくご')), message: 'こくごの べんきょうを しよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご'), 2), message: '・・・。',                   **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご'), 3), message: '〈たまご〉は シェイクスピアの さくひんを よんだ！', **image_set("temp-nikoniko2.png"),
      messages: [ '〈たまご〉は シェイクスピアの さくひんを よんだ！', '〈たまご〉は こくごじてんを まるあんき した！', '〈たまご〉は ドストエフスキーの さくひんを よんだ！',
                  '〈たまご〉は エドガー・アラン・ポーの さくひんを よんだ！', '〈たまご〉は なつめそうせきの 『こころ』を よんだ！' ] },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 2)), message: 'こくごの べんきょうを しよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 2), 2), message: '・・・。',                   **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 2), 3), message: '〈たまご〉は 「はしれメロス」を よんだ！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 3)), message: 'こくごの べんきょうを しよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 3), 2), message: '・・・。',                   **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 3), 3), message: '『どんぶらこー、 どんぶらこー』', **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'こくご', 3), 4), message: '〈たまご〉は ももたろうを よんだ！', **image_set("temp-study.png") },

      { **cut_key(ar_key('何かしたそう', 1, 'りか')), message: 'りかの べんきょうを しよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか'), 2), message: '・・・。',                   **image_set("temp-rika.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか'), 3), message: '〈たまご〉は ふろうふしに なれる クスリを つくった！', **image_set("temp-rika2.png"),
      messages: [ '〈たまご〉は ふろうふしに なれる クスリを つくった！', '〈たまご〉は じかんを さかのぼれる ジュースを つくった！', '〈たまご〉は なにを たべても チョコの あじになる クスリを つくった！',
                  '〈たまご〉は ぜんしんが とうめいになる クスリを つくった！', '〈たまご〉は じぶんの みらいが みえる ジュースを つくった！', '〈たまご〉は ぜったい にげられない カレーの においの クスリを つくった！' ] },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 2)), message: 'りかの べんきょうを しよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 2), 2), message: '・・・。',                   **image_set("temp-rika.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 2), 3), message: '！！！',                     **image_set("temp-rika3.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 2), 4), message: '・・・。',                   **image_set("temp-rika4.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 3)), message: 'りかの べんきょうを しよう！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 3), 2), message: '・・・。',                   **image_set("temp-rika.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'りか', 3), 3), message: 'じっけんは しっぱいした！', **image_set("temp-rika.png") },

      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい')), message: 'しゃかいの べんきょうを しよう！',                           **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい'), 2), message: '・・・。',                                               **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい'), 3), message: 'すっごい ゆうめいな ブショウが タイムスリップ してきた！ すご！！', **image_set("temp-busyou3.png"),
      messages: [ 'すっごい ゆうめいな ブショウが タイムスリップ してきた！ すご！！', 'でんせつの ブショウが タイムスリップして 〈たまご〉に あいにきた！ なんで！？', '〈たまご〉の あこがれの ブショウが タイムスリップ してきた！ サイン！ サイン！',
                  'すっごい つよい ブショウが タイムスリップして げんだいを しんりゃくしにきた！ どうしよう！', 'すっごい いだいな ブショウが タイムスリップ してきた！ しゃしん とっていい！？' ] },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 2)), message: 'しゃかいの べんきょうを しよう！',                           **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 2), 2), message: '・・・。',                                               **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 2), 3), message: 'なまえを きいたこと あるような ないような ブショウが タイムスリップ してきた！', **image_set("temp-busyou2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 2), 4), message: 'こんにちは！',                                           **image_set("temp-busyou2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 3)), message: 'しゃかいの べんきょうを しよう！',                           **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 3), 2), message: '・・・。',                                               **image_set("temp-study.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 3), 3), message: 'むめいの ブショウが タイムスリップ してきた！',                 **image_set("temp-busyou1.png") },
      { **cut_key(ar_key('何かしたそう', 1, 'しゃかい', 3), 4), message: 'はやく かえって！',                                         **image_set("temp-busyou1.png") },

      { **cut_key(ar_key('ボーっとしている', 0, 'ながめている')), message: 'きょうも のどかだねえ。', **image_set("temp-hidariwomiru-teage.png"),
      messages: [ 'きょうも のどかだねえ。', '〈たまご〉 「んに～」', '〈たまご〉 「んにに～」', '〈たまご〉 「にー、 にに～」', '〈たまご〉 「にににー、 にに～」',
                  '〈たまご〉 「にー、 にに！」', '〈たまご〉 「ににに？ に～」', 'こうみえて、 いろいろ かんがえごと してるのかも。', 'きょうも へいわだ。', 'のんびり すごすのが いちばんだよね～。', 'ボケっとしてると、 あっというまに じかんがすぎるよ。' ] },
      { **cut_key(ar_key('ニコニコしている', 0, 'ながめている')), message: 'どうしたのかな！', **image_set("temp-suwatte-nikoniko-teage.png"),
      messages: [ 'どうしたのかな！', '〈たまご〉 「んに～！」', '〈たまご〉 「んにに～！」', '〈たまご〉 「にー！ にに～！」', '〈たまご〉 「にににー！ にに～！」',
                  '〈たまご〉 「にー！ んにー！」', '〈たまご〉 「んににー！」', 'ごきげんそう！' ] },
      { **cut_key(ar_key('ゴロゴロしている', 0, 'ながめている')), message: 'ゴロゴロ！', **image_set("temp-gorogoro.png"),
      messages: [ 'ゴロゴロ！', 'きもちよさそう だなあ。', 'ゴロゴロばっかしてると ふとっちゃうよ！', 'じぶんも ゴロゴロしようかなあ。', 'ゆか、 かたくないのかな？',
                  'ゴロゴロ きもちいいねえ！', '〈たまご〉 「に～！」', '〈たまご〉 「に！ んにに～！」' ] },

      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける')), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける'), 2), message: '・・・。けいかい されている。いちど じぶんのムネに てをあてて、 げんいんを かんがえてみるんだ。', **image_set("temp-kanasii.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 2)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 2), 2), message: 'あー！ ぜんぜん なついて いないようだ。',                                                  **image_set("temp-mewosorasu.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 3)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 3), 2), message: 'うーん、 もっとこころを ひらいてほしいなあ。',                                             **image_set("temp-tewoageru.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 4)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 4), 2), message: 'お！ すこしこころを ひらいてくれて いるようだ！',                                           **image_set("temp-nikoniko3.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 5)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 5), 2), message: '〈たまご〉は こころを ひらいてくれて いるようだ！',                                         **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 6)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 6), 2), message: '〈たまご〉に すごく すかれている ようだ！',                                                **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 7)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 7), 2), message: '〈たまご〉に すっごく すかれている ようだ！！',                                             **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 8)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 8), 2), message: '〈たまご〉に すーっごく かなり すかれている ようだ！！！',                                    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 9)), message: '〈たまご〉ー！',                                                                      **image_set("temp-normal.png") },
      { **cut_key(ar_key('ボーっとしている', 0, 'こえをかける', 9), 2), message: '〈たまご〉に すーーっごく かなり すかれている ようだ！！！！',                                **image_set("temp-nikoniko.png") },

      { **cut_key(ar_key('踊っている',     0, 'よしよしする')), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('踊っている',     0, 'おやつをあげる')), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('踊っている',     0, 'ごはんをあげる')), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },

      { **cut_key(ar_key('踊っている',     0, 'よしよしする', 2)), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('踊っている',     0, 'おやつをあげる', 2)), message: '〈たまご〉は おなかいっぱいの ようだ。', **image_set("temp-normal.png") },
      { **cut_key(ar_key('踊っている',     0, 'ごはんをあげる', 2)), message: '〈たまご〉は おなかいっぱいの ようだ。', **image_set("temp-normal.png") },

      { **cut_key(ar_key('泣いている(空腹)', 0, 'よしよしする')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(空腹)', 0, 'おやつをあげる')), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('泣いている(空腹)', 0, 'ごはんをあげる')), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('泣いている(空腹)', 0, 'あそんであげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },

      { **cut_key(ar_key('泣いている(よしよし不足)', 0, 'よしよしする')), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('泣いている(よしよし不足)', 0, 'おやつをあげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(よしよし不足)', 0, 'ごはんをあげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(よしよし不足)', 0, 'あそんであげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },

      { **cut_key(ar_key('泣いている(ランダム)', 0, 'よしよしする')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(ランダム)', 0, 'おやつをあげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(ランダム)', 0, 'ごはんをあげる')), message: 'そうじゃないらしい！', **image_set("temp-naku.png") },
      { **cut_key(ar_key('泣いている(ランダム)', 0, 'あそんであげる')), message: '〈たまご〉は よろこんでいる！', **image_set("temp-nikoniko.png") },

      { **cut_key(ar_key('寝ている',           0, 'そっとする')), message: 'きもちよさそうに ねている。', **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝ている',           0, 'よしよしする')), message: 'おこさないように、 やさしくなでた。', **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝ている',           0, 'たたきおこす')), message: 'ひとでなし！！', **image_set("temp-sleep.png") },

      { **cut_key(ar_key('寝起き',             0, 'そっとする')), message: 'まだ ねむいみたいだから そっとしておこう！', **image_set("temp-wakeup.png") },
      { **cut_key(ar_key('寝起き',             0, 'よしよしする')), message: '〈たまご〉が よろこんでいる！ おはよう！',   **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('寝起き',             0, 'よしよしする', 2)), message: 'よしよし！',                            **image_set("temp-wakeup.png") },
      { **cut_key(ar_key('寝起き',             0, 'きがえさせる')), message: '〈たまご〉は ふくなんか きていない！',      **image_set("temp-wakeup.png") },
      { **cut_key(ar_key('寝起き',             3, 'はい')), message: '〈たまご〉は おこってしまった！',           **image_set("temp-okoru.png") },

      { **cut_key(ar_key('占い',               0, 'つぎへ')), message: '『ほんじつの あなたは すっごくラッキー！』', **image_set("temp-TV1.png") },
      { **cut_key(ar_key('占い',               0, 'つぎへ'), 2), message: '『ちょっかんに したがうと、 おもわぬ いいことがありそう！』', **image_set("temp-TV2.png"),
      messages: [ '『ちょっかんに したがうと、 おもわぬ いいことがありそう！』', '『せっきょくてきに うごくと、 とっても いいことが おこりそう！』', '『おいしいものを たべると、 きんうんアップ！』', '『ふだんと へんかのあるこうどうを いしきしよう！』', '『まわりのひとからかんしゃされそうなよかん！』',
                  '『なにを やっても うまくいきそう！』', '『いつもは しっぱいすることも、 きょうなら うまくいきそう！』', '『じぶんの とくいなことに うちこんでみよう！』', '『ひとのえがおに ふれると、 うんきがアップ！』', '『まわりへの おもいやりを、 いつもいじょうに だいじにしよう！』' ] },
      { **cut_key(ar_key('占い',               0, 'つぎへ'), 3), message: 'だそうだ！', **image_set("temp-TV2.png") },

      { **cut_key(ar_key('占い',               0, 'つぎへ',    2)), message: '『ほんじつの あなたは そこそこラッキー！』', **image_set("temp-TV1.png") },
      { **cut_key(ar_key('占い',               0, 'つぎへ',    2), 2), message: '『あんまり ふかく かんがえすぎず、 こうどうしよう！』', **image_set("temp-TV2.png"),
      messages: [ '『あんまり ふかく かんがえすぎず、 こうどうしよう！』', '『ごぜんちゅうから、 かっぱつてきに こうどうしよう！』', '『あまいものを たべると、 いいことが あるかも！』', '『じぶんを かざらず、 すごしてみよう！』', '『コミュニケーションが じゅうような いちにちになりそう！』',
                  '『けんこうてきな いちにちを すごすのが ポイント！』', '『ちょうせんが うまくいきそうな よかん！』', '『じぶんの にがてなことに うちこんでみよう！』', '『たまには のんびりすごすのも いいかも！』', '『にんげんかんけいが うまくいきそう！』' ] },
      { **cut_key(ar_key('占い',               0, 'つぎへ',    2), 3), message: 'だそうだ！', **image_set("temp-TV2.png") },

      { **cut_key(ar_key('占い',               0, 'つぎへ',    3)), message: '『ほんじつの あなたは ちょっぴりラッキー！』', **image_set("temp-TV1.png") },
      { **cut_key(ar_key('占い',               0, 'つぎへ',    3), 2), message: '『でも マンホールの うえには きをつけよう！』', **image_set("temp-TV1.png"),
      messages: [ '『でも マンホールの うえには きをつけよう！』', '『みぎか ひだりだったら、 ひだりを えらぼう！』', '『みぎか ひだりだったら、 みぎを えらぼう！』', '『おとしよりに やさしくするのが ポイント！』', '『にがてなたべものを がんばってたべてみよう！』',
                  '『うんどうをすると いいことが あるかも？』', '『トイレは がまんしないほうが よさそう！』', '『せいじつなきもちを もっていれば、 いい いちにちになりそう！』', '『きょうは いそがしいかも しれないけど、 がんばってみよう！』', '『でも ひとのわるぐちを いうと、 うんきが ガクッとさがるよ！』',
                  '『ラッキーカラーは きいろ！』', '『ラッキーカラーは あお！』', '『ラッキーカラーは あか！』', '『ラッキーカラーは みどり！』', '『ニコニコすることを こころがけよう！』' ] },
      { **cut_key(ar_key('占い',               0, 'つぎへ',    3), 3), message: 'だそうだ！', **image_set("temp-TV1.png") },

      { **cut_key(ar_key('タマモン',               0, 'みていいよ')), message: '〈たまご〉は よろこんでいる！',              **image_set("temp-TV4.png") },
      { **cut_key(ar_key('タマモン',               0, 'みさせてあげない')), message: 'しょぼん。',                              **image_set("temp-TV5.png") },
      { **cut_key(ar_key('タマモン',               1, 'いっしょにみる')), message: '『でばんだ、 タマチュウ！』', **image_set("temp-TV6.png"),
      messages: [ '『でばんだ、 タマチュウ！』', '『これから たびにでるぞ！』', '『タマモンマスターへの みちはながい！』', '『タマチュウが つよくなってきた！』', '『バトルだ タマチュウ！』',
                  '『タマチュウ にげるぞ！』', '『タマチュウ！ かえってこい！』', '『タマチュウ きょうは ちょうしわるいか？』', '『タマチュウ！ たたかってくれ！』', '『これが タマチュウ？』',
                  '『タマチュウ、 さいきんふとった？』', '『あのタマモン つかまえよう！』', '『あー、 にげられた！』', '『あのやまを こえないと！』', '『タマチュウ、 これからも よろしくな！』' ] },

      { **cut_key(ar_key('タマえもん',               0, 'みていいよ')), message: '〈たまご〉は よろこんでいる！',           **image_set("temp-TV4.png") },
      { **cut_key(ar_key('タマえもん',               0, 'みさせてあげない')), message: 'しょぼん。',                           **image_set("temp-TV5.png") },
      { **cut_key(ar_key('タマえもん',               1, 'いっしょにみる')), message: '『たすけてタマえもん！』', **image_set("temp-TV6.png"),
      messages: [ '『たすけて タマえもん！』', '『タマえもーん！』', '『タマえもんに どうにかしてもらおう！』', '『タマえもんと ケンカしてしまった・・・。』', '『タマえもんにも できないことが あるんだね』',
                  '『しっかりしてよ タマえもん！』', '『いそいで かえらないと！』', '『タマえもん、 これどうやって つかえばいいの？』', '『いつも ありがとうね、 タマえもん！』', '『きょうは がっこうに いきたくないなあ』',
                  '『こうえんに あそびにいこう！』', '『タマえもん、 またあしたね！』', '『いそいで タマえもんのところに いかないと！』', '『タマえもん、 さっきはごめんね！』', '『タマえもん、 これからもよろしくね！』' ] },

      { **cut_key(ar_key('ニワトリビアの湖',           0, 'みていいよ')), message: '〈たまご〉は よろこんでいる！',           **image_set("temp-TV4.png") },
      { **cut_key(ar_key('ニワトリビアの湖',           0, 'みさせてあげない')), message: 'しょぼん。',                           **image_set("temp-TV5.png") },
      { **cut_key(ar_key('ニワトリビアの湖',           1, 'いっしょにみる')), message: '『コケーコケーコケー、 100コケー！』', **image_set("temp-TV6.png"),
      messages: [ '『コケーコケーコケー、 97コケー！』', '『コケーコケーコケー、 91コケー！』', '『コケーコケーコケー、 88コケー！』', '『コケーコケーコケー、 84コケー！』', '『コケーコケーコケー、 75コケー！』',
                  '『コケーコケーコケー、 69コケー！』', '『コケーコケーコケー、 61コケー！』', '『コケーコケーコケー、 54コケー！』', '『コケーコケーコケー、 46コケー！』', '『コケーコケーコケー、 43コケー！』', '『コケーコケーコケー、 36コケー！』', '『コケーコケーコケー、 35コケー！』',
                  '『コケーコケーコケー、 27コケー！』', '『コケーコケーコケー、 14コケー！』', '『コケーコケーコケー、 7コケー！』', '『0コケー！』' ] },

      { **cut_key(ar_key('扇風機',                 0, 'よしよしする')), message: '〈たまご〉は よろこんでいる！',                 **image_set("temp-senpuuki2.png") },
      { **cut_key(ar_key('扇風機',                 0, 'スイカをあげる')), message: '〈たまご〉は おいしそうにたべている！',          **image_set("temp-senpuuki3.png") },
      { **cut_key(ar_key('扇風機',                 0, 'スイカをあげる', 2)), message: '〈たまご〉は おなかいっぱい みたい。',            **image_set("temp-senpuuki4.png") },
      { **cut_key(ar_key('扇風機',                 0, 'せんぷうきをとめる')), message: '〈たまご〉 「・・・！」',                       **image_set("temp-bikkuri.png") },
      { **cut_key(ar_key('扇風機',                 0, 'そっとする')), message: '〈たまご〉は きもちよさそう！',                 **image_set("temp-senpuuki1.png") },

      { **cut_key(ar_key('こたつ',                 0, 'よしよしする')), message: '〈たまご〉は よろこんでいる！',                 **image_set("temp-kotatu2.png") },
      { **cut_key(ar_key('こたつ',                 0, 'ミカンをあげる')), message: '〈たまご〉は おいしそうに たべている！',          **image_set("temp-kotatu3.png") },
      { **cut_key(ar_key('こたつ',                 0, 'ミカンをあげる', 2)), message: '〈たまご〉は おなかいっぱい みたい。',            **image_set("temp-kotatu4.png") },
      { **cut_key(ar_key('こたつ',                 0, 'こたつをとめる')), message: '〈たまご〉 「・・・！」',                       **image_set("temp-bikkuri.png") },
      { **cut_key(ar_key('こたつ',                 0, 'そっとする')), message: '〈たまご〉は きもちよさそう！',                 **image_set("temp-kotatu1.png") },

      { **cut_key(ar_key('花見',                   0, 'つれていく')), message: 'よし！おはなみに いこっか！',                    **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 2), message: 'おはなみに きた！',                             **image_set("temp-hanami.png", "temp-hanami.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 3), message: '〈たまご〉 「にー！ んににー！」',                             **image_set("temp-hanami.png", "temp-hanami.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 4), message: '〈たまご〉 「にににーに、 んにににに！」',                             **image_set("temp-hanami.png", "temp-hanami.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 5), message: '〈たまご〉 「にー！ んにー、 んにに！」',                             **image_set("temp-hanami.png", "temp-hanami.png") },
      { **cut_key(ar_key('花見',                   0, 'つれていく'), 6), message: '〈たまご〉は たのしんで いるようだ！',                             **image_set("temp-hanami.png", "temp-hanami.png"),
      messages: [ '〈たまご〉は たのしんでいる ようだ！', '〈たまご〉は さくらが きょうみぶかい みたい！', '〈たまご〉は さくらが きれいだと いっている！', '〈たまご〉は しあわせを かんじているようだ！', '〈たまご〉は しぜんを だいじにしていきたいと いっている！',
                  '〈たまご〉は たこやきが たべたいようだ！', '〈たまご〉は はるが すきらしい！', '〈たまご〉は これからもっと いろんなものを みたいらしい！', '〈たまご〉は たわいもないことを たのしそうに はなしている！', '〈たまご〉は きいてほしいはなしが いっぱいあるようだ！', '〈たまご〉は おこのみやきがたべたいようだ！',
                  '〈たまご〉は ふってくるさくらを がんばって つかもうとしている！', '〈たまご〉は ずっとむこうまで みにいきたいらしい！', '〈たまご〉は またつれてきてね といっている！', '〈たまご〉は やさしいきもちで いっぱいなようだ！' ] },
      { **cut_key(ar_key('花見',                   0, 'いかない')), message: 'しょぼん。',                    **image_set("temp-gakkari.png") },

      { **cut_key(ar_key('紅葉',                   0, 'つれていく')), message: 'よし！ コウヨウを みにいこっか！',                    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('紅葉',                   0, 'つれていく'), 2), message: 'コウヨウを みにきた！',                             **image_set("temp-kouyou.png", "temp-kouyou.png") },
      { **cut_key(ar_key('紅葉',                   0, 'つれていく'), 3), message: '〈たまご〉 「んにー！」',                             **image_set("temp-kouyou.png", "temp-kouyou.png") },
      { **cut_key(ar_key('紅葉',                   0, 'つれていく'), 4), message: '〈たまご〉 「んにに！ にー！」',                             **image_set("temp-kouyou.png", "temp-kouyou.png") },
      { **cut_key(ar_key('紅葉',                   0, 'つれていく'), 5), message: '〈たまご〉は たのしんで いるようだ！',                             **image_set("temp-kouyou.png", "temp-kouyou.png"),
      messages: [ '〈たまご〉は たのしんでいる ようだ！', '〈たまご〉は おちばを あつめている！', '〈たまご〉は おおはしゃぎ！', '〈たまご〉は いまのコウヨウの いろみが すきなようだ！', '〈たまご〉は コウヨウの うつくしさに かんどうしている！',
                  '〈たまご〉は ニコニコだ！', '〈たまご〉は あきがすきらしい！', '〈たまご〉は これからもっと いろんなものを みたいらしい！', '〈たまご〉は おちばを じまんしている！', '〈たまご〉は なぜ はっぱのいろが うつりかわるのか、 ふしぎなようだ！', 'またこんども こようね！',
                  '〈たまご〉は ふってくるおちばを つかまえるのが すきらしい！', '〈たまご〉は ここにいると こころが おちつくようだ！', '〈たまご〉は またつれてきてねと いっている！', '〈たまご〉は せいめいの とうとさを かんじているようだ！' ] },
      { **cut_key(ar_key('紅葉',                   0, 'いかない')), message: 'しょぼん。',                    **image_set("temp-gakkari.png") },

      { **cut_key(ar_key('年始',                   0, 'つぎへ')), message: '〈たまご〉 「ににににに、 んにににー！」',                    **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('年始',                   0, 'つぎへ'), 2), message: '〈たまご〉 「にににに、 ににににー！」',                     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('年始',                   0, 'つぎへ'), 3), message: 'あけましておめでとう！',                                 **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('年始',                   0, 'つぎへ'), 4), message: 'ことしもよろしくね、 〈たまご〉！',                                   **image_set("temp-nikoniko2.png") },

      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'そっとする')), message: '〈たまご〉は たのしそうに あそんでいる！',                **image_set("temp-building_blocks.png") },
      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'よしよしする')), message: '〈たまご〉は うれしそう！',                             **image_set("temp-building_blocks_nikoniko.png") },
      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'ちょっかいをだす')), message: '〈たまご〉が おこってしまった！',                       **image_set("temp-okoru.png") },
      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'ブロックをくずす')), message: 'あー！ ほんとに ブロックを くずしちゃった！ これはひどい！', **image_set("temp-okoru.png") },

      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'ちょっかいをだす', 2)), message: '〈たまご〉は ちょっと いやそう。', **image_set("temp-hukigen.png") },
      { **cut_key(ar_key('ブロックのおもちゃに夢中', 0, 'ブロックをくずす', 2)), message: '〈たまご〉に そしされた。',       **image_set("temp-building_blocks.png") },

      { **cut_key(ar_key('マンガに夢中', 0, 'そっとする')), message: '〈たまご〉は マンガが おもしろいようだ。',                     **image_set("temp-comics.png") },
      { **cut_key(ar_key('マンガに夢中', 0, 'よしよしする')), message: '〈たまご〉は うれしそう！',                                  **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('マンガに夢中', 0, 'はなしかける')), message: '〈たまご〉は マンガに しゅうちゅう したいみたい。ごめんごめん。', **image_set("temp-hukigen.png") },
      { **cut_key(ar_key('マンガに夢中', 0, 'マンガをとりあげる')), message: '〈たまご〉が おこってしまった！',                            **image_set("temp-okoru.png") },

      { **cut_key(ar_key('マンガに夢中', 0, 'はなしかける',  2)), message: '〈たまご〉は ニコニコしている。',                            **image_set("temp-nikoniko2.png") },

      { **cut_key(ar_key('眠そう', 0, 'ねかせる')), message: 'きょうは もうねようね！ 〈たまご〉 おやすみ！', **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('眠そう', 0, 'ねかせる',    2)), message: 'まだ もうちょっと おきてたいみたい。',        **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'よしよしする')), message: '〈たまご〉は うれしそうだ！',               **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('眠そう', 0, 'よしよしする'), 2), message: '〈たまご〉は おふとんに はいって ねた！',      **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('眠そう', 0, 'よしよしする', 2)), message: '〈たまご〉は よろこんでいる！',             **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('眠そう', 0, 'はみがきをさせる')), message: 'よし、 よく みがこうね！',                   **image_set("temp-hamigaki.png") },
      { **cut_key(ar_key('眠そう', 0, 'はみがきをさせる'), 2), message: '〈たまご〉は ちゃんと はみがきして おやすみした！', **image_set("temp-hamigaki.png") },
      { **cut_key(ar_key('眠そう', 0, 'はみがきをさせる',   2)), message: 'はみがきしたくない みたい。まったくー！',     **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう')), message: 'チーターが がけから・・・',                 **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう'), 2), message: 'おっこちーたー！！',                       **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう'), 3), message: '〈たまご〉は おおわらいした！',             **image_set("temp-warau.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 2)), message: 'アルミかんの うえに・・・',                 **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 2), 2), message: 'あるミカン！！',                          **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 2), 3), message: '〈たまご〉が ちょっと ひいてる・・・。',      **image_set("temp-donbiki.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 3)), message: 'ふとんが・・・',                          **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 3), 2), message: 'ふっとんだ！！',                          **image_set("temp-sleepy.png") },
      { **cut_key(ar_key('眠そう', 0, 'ダジャレをいう', 3), 3), message: 'わらわない・・・。',                       **image_set("temp-sleepy.png") },

      { **cut_key(ar_key('寝かせた', 0, 'そっとする')), message: 'きもちよさそうに ねているなあ。',      **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 0, 'よしよしする')), message: 'よしよし、 りっぱに そだちますように。', **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 0, 'たたきおこす')), message: 'できるわけないだろ！！',              **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 0, 'ゴミばこのなかをのぞく')), message: 'はなを かんだティッシュが いっぱい！',   **image_set("temp-sleep.png"),
      messages: [ 'はなを かんだ ティッシュが いっぱい！', 'だが、 からっぽだ！', 'しっかり ぶんべつされている！', 'テレビ ばんぐみひょうだ。うらないばんぐみは、 まいあさ やっているようだ。', 'テレビ ばんぐみひょうだ。 『タマモン』は、 げつようびの よる7じから やっているようだ。', 'テレビ ばんぐみひょうだ。 『ニワトリビアのみずうみ』は、 すいようびの よる8じから やっているようだ。', 'テレビ ばんぐみひょうだ。 『タマえもん』は、 きんようびの よる7じから やっているようだ。',
                  'メモがきだ。 「とっくんを したくなると、 はなしかけようと してくる」 だって。', 'メモがきだ。 「げいじゅつせいは バクハツから やってくる」 だって。', 'メモがきだ。 「ダジャレが ウケなくても、 あきらめるな」 だって。',
                  'メモがきだ。 「このあたりは、 はるになると サクラがきれい」 だって。', 'メモがきだ。 「このあたりは、 あきになると こうようが きれい」 だって。', 'メモがきだ。 「せんぷうき、 あります」 だって。', 'メモがきだ。 「コタツ、 あります」 だって。', 'メモがきだ。 「しっぱいしたって、 せいちょう しないわけじゃない」 だって。', 'メモがきだ。 「L-I-N-E/35894421」 だって。', 'メモがきだ。 「L-I-N-E/44235819」 だって。', 'メモがきだ。 「メモがきの なかには ごくひの ものも ある」 だって。' ] },
      { **cut_key(ar_key('寝かせた', 1, 'そっとする')), message: 'きもちよさそうに ねているなあ。',      **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 1, 'よしよしする')), message: 'よしよし、 りっぱに そだちますように。', **image_set("temp-sleep.png") },
      { **cut_key(ar_key('寝かせた', 1, 'たたきおこす')), message: 'できるわけないだろ！！',              **image_set("temp-sleep.png") },

      { **cut_key(ar_key('怒っている', 0, 'よしよしする')), message: '〈たまご〉は よろこんでいる！',     **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('怒っている', 0, 'よしよしする'), 2), message: '〈たまご〉は ゆるしてくれた！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('怒っている', 0, 'よしよしする', 2)), message: '〈たまご〉は ゆるしてくれない！！', **image_set("temp-okoru.png") },
      { **cut_key(ar_key('怒っている', 0, 'おやつをあげる')), message: '〈たまご〉は よろこんでいる！',     **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('怒っている', 0, 'おやつをあげる'), 2), message: '〈たまご〉は ゆるしてくれた！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('怒っている', 0, 'おやつをあげる', 2)), message: 'おやつじゃ ゆるしてくれない！',     **image_set("temp-okoru.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする')), message: 'こんしんの へんがお！',             **image_set("temp-hengao.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする'), 2), message: '〈たまご〉 「キャッキャッ！」',      **image_set("temp-warau.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする'), 3), message: '大ウケした！',                    **image_set("temp-warau.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする', 2)), message: 'こんしんの へんがお！',             **image_set("temp-hengao.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする', 2), 2), message: '〈たまご〉 「・・・。」',             **image_set("temp-donbiki.png") },
      { **cut_key(ar_key('怒っている', 0, 'へんがおをする', 2), 3), message: 'すべった。',                      **image_set("temp-donbiki.png") },
      { **cut_key(ar_key('怒っている', 0, 'あやまる')), message: 'ごめんよ・・・。',                **image_set("temp-gomen.png") },
      { **cut_key(ar_key('怒っている', 0, 'あやまる'), 2), message: '〈たまご〉は ゆるしてくれた！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('怒っている', 0, 'あやまる',     2)), message: 'ごめんよ・・・。',                **image_set("temp-gomen.png") },
      { **cut_key(ar_key('怒っている', 0, 'あやまる',     2), 2), message: '〈たまご〉は まだおこっている！',    **image_set("temp-okoru.png") },

      { **cut_key(ar_key('算数',      1,  '〈A〉')), message: 'おー！ せいかい！ いいちょうしだね！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('算数',      1,  '〈B〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      1,  '〈C〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      1,  '〈D〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },

      { **cut_key(ar_key('算数',      2,  '〈A〉')), message: 'おー！ せいかい！ いいちょうしだね！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('算数',      2,  '〈B〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      2,  '〈C〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      2,  '〈D〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },

      { **cut_key(ar_key('算数',      3,  '〈A〉')), message: 'おー！ せいかい！ いいちょうしだね！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('算数',      3,  '〈B〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      3,  '〈C〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      3,  '〈D〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },

      { **cut_key(ar_key('算数',      4,  '〈A〉')), message: 'おー！ せいかい！ いいちょうしだね！',     **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('算数',      4,  '〈B〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      4,  '〈C〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('算数',      4,  '〈D〉')), message: 'ちがうよー！ ざんねん！',     **image_set("temp-ochikomu.png") },

      { **cut_key(ar_key('ボール遊び',      2,  'ひだりだ！')), message: 'おー！ きれいにキャッチ！',     **image_set("temp-ball4.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'そこだ！')), message: 'なんとかキャッチ！',           **image_set("temp-ball4.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'そこだ！', 2)), message: 'あちゃー！',                  **image_set("temp-ball7.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'みぎだ！')), message: 'あちゃー！',                  **image_set("temp-ball10.png") },

      { **cut_key(ar_key('ボール遊び',      2,  'ひだりだ！'), 2), message: '〈たまご〉 じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'そこだ！'), 2), message: '〈たまご〉 じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'そこだ！', 2), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('ボール遊び',      2,  'みぎだ！'), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },

      { **cut_key(ar_key('ボール遊び',      3,  'ひだりだ！')), message: 'なんとかキャッチ！',           **image_set("temp-ball8.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'ひだりだ！',   2)), message: 'あちゃー！',                  **image_set("temp-ball5.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'そこだ！')), message: 'おー！ きれいにキャッチ！',     **image_set("temp-ball8.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'みぎだ！')), message: 'なんとかキャッチ！',           **image_set("temp-ball8.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'みぎだ！', 2)), message: 'あちゃー！',                  **image_set("temp-ball11.png") },

      { **cut_key(ar_key('ボール遊び',      3,  'ひだりだ！'), 2), message: '〈たまご〉 じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'ひだりだ！',   2), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'そこだ！'), 2), message: '〈たまご〉 じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'みぎだ！'), 2), message: '〈たまご〉 じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      3,  'みぎだ！', 2), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },

      { **cut_key(ar_key('ボール遊び',      4,  'ひだりだ！')), message: 'あちゃー！',                  **image_set("temp-ball6.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'そこだ！')), message: 'なんとかキャッチ！',           **image_set("temp-ball12.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'そこだ！', 2)), message: 'あちゃー！',                  **image_set("temp-ball9.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'みぎだ！')), message: 'おー！ きれいにキャッチ！',     **image_set("temp-ball12.png") },

      { **cut_key(ar_key('ボール遊び',      4,  'ひだりだ！'), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'そこだ！'), 2), message: '〈たまご〉 じょうずだねえ！',    **image_set("temp-nikoniko.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'そこだ！', 2), 2), message: 'しょぼん。',                  **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('ボール遊び',      4,  'みぎだ！'), 2), message: '〈たまご〉 じょうずだねえ！',    **image_set("temp-nikoniko.png") },

      { **cut_key(ar_key('特訓',      0,  'さんすう')), message: 'とっくんは れんぞく 20もんになるぞ！',      **image_set("temp-bikkuri.png") },
      { **cut_key(ar_key('特訓',      0,  'さんすう',        2)), message: 'この とっくんは 〈たまご〉には まだはやい！', **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('特訓',      0,  'ボールあそび')), message: 'とっくんは 3かい しっぱいするまで つづくぞ！', **image_set("temp-bikkuri.png") },
      { **cut_key(ar_key('特訓',      0,  'ボールあそび',    2)), message: 'この とっくんは 〈たまご〉には まだはやい！', **image_set("temp-gakkari.png") },
      { **cut_key(ar_key('特訓',      0,  'やっぱやめておく')), message: 'いや、 いまは やっぱやめておこう。',        **image_set("temp-normal.png") },
      { **cut_key(ar_key('特訓',      1,  'つぎへ')), message: 'けっかは・・・。',                      **image_set("temp-tukareta.png") },

      { **cut_key(ar_key('イントロ',   0,  'つぎへ')), message: 'あんたが・・・',                  **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   0,  'つぎへ'), 2), message: '〈ユーザー〉 だな！',               **image_set("temp-niwatori.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   0,  'つぎへ'), 3), message: 'これからよろしくな！',             **image_set("temp-niwatori.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   0,  'つぎへ'), 4), message: 'おれは みてのとおり、 ヒヨコだ！',    **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   1,  'えっ？')), message: 'えっ・・・。',                      **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   1,  'まさか！')), message: 'なに・・・！？',                    **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   1,  'うーん')), message: 'こら、 うそでも かっこいいですと いえ！', **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   1,  'かっこいいです')), message: 'そうだろ？ うんうん！',               **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   2,  'つぎへ')), message: 'きょうから あんたには、 この たまごと いっしょに くらしてもらうぞ！', **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   2,  'つぎへ'), 2), message: 'なまえは たしか・・・。',                                     **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   3,  'ちゃんをつけて！')), message: 'わかった わかった！',              **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   3,  'くんをつけて！')), message: 'わかった わかった！',              **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   3,  'さまをつけて！')), message: 'わかった わかった！',              **image_set("temp-hiyoko-tamago-shokai.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   4,  'つぎへ')),    message: 'おなかが へっても なくし、 さびしくなっても なく！',                             **image_set("temp-hiyoko-tuyoimagao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 2), message: 'だからできたら ていきてきに 〈たまご〉の ようすを みてほしいんだな。',            **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 3), message: 'また じかんたいや ひに よって こうどうパターンが かわるぞ。',                     **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 4), message: 'よるは ねるし、 すきなテレビが やってるひは じかんになると みたいっていうし、',    **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 5), message: 'ふゆは こたつに はいる！',                                                     **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 6), message: 'いろんなタイミングで 〈たまご〉を かんさつ してみてくれ。',                       **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 7), message: 'ちなみに 〈たまご〉は あそびだしたり、 なにかに むちゅうに なると、',              **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 8), message: 'しばらく それにしか きょうみが なくなるが、',                                    **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 9), message: 'そんなときは しばらく そっとしてやってくれ。 じかんをあけて、 またもどってきてくれ。', **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 10), message: 'ひだりうえの ほうを みてくれ、 「またあとでね」って あるだろ？',                   **image_set("temp-hiyoko-hidariue.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 11), message: '〈たまご〉の そばから はなれても またいつでも もどってこれるから、',                **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 12), message: 'そこは あんしんしてくれよな。',                                                 **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 13), message: 'ん？ なに？',                                                                 **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 14), message: 'もくてきや めざさないと いけないことは あるのかって？',                           **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 15), message: 'そんなもんはない。',                                                           **image_set("temp-hiyoko-tuyoimagao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 16), message: 'が、 〈たまご〉と せっするなかで、',                                             **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 17), message: 'かんけいせいを ふかめていって くれたら うれしいかな。',                                    **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 18), message: '〈ユーザー〉なら うまく やっていけると しんじてるぜ。',                            **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 19), message: 'そうそう、 おなじことを してあげても、 はんのうが そのときそのときで かわったりするから、', **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 20), message: 'まあ とにかくたくさん せっしてみてくれよな。',                                  **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 21), message: 'さいごに、 これは 『LINEログイン』を りようしているばあいの はなしなんだが、 ',    **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 22), message: 'じつは 『LINE』をつうじて 〈たまご〉と おはなしすることが できるんだ！',          **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 23), message: '『せってい』がめんから 『LINEともだちついか』が できるから かくにん してみてくれよな。', **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 24), message: '『ごはんだよ！』と メッセージを おくると ごはんを あげられたり、 なにかと べんりだぞ。', **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 25), message: 'よし、 オレはこのあと ちょっとよていが あるから、 もういくな。',                  **image_set("temp-hiyoko-magao.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 26), message: '〈たまご〉のこと、 だいじにしてくれよ！',                                       **image_set("temp-hiyoko-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 27), message: 'いってしまった。 〈たまご〉の めんどう、 うまくみれるかな～。',                   **image_set("temp-none.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   4,  'つぎへ'), 28), message: 'まあ、 とりあえずまずは こえを かけてみよう。',                                  **image_set("temp-normal.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   5,  'こんにちは！')),    message: 'あ！ へんじ してくれなかった！', **image_set("temp-mewosorasu.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   5,  'なかよくしてね！')), message: 'あ！ へんじ してくれなかった！', **image_set("temp-mewosorasu.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   6,  'よっ！')),            message: 'あ！ また めを そらした！',    **image_set("temp-mewosorasu.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   6,  'なかよくたのむぜ！')), message: 'あ！ また めを そらした！',    **image_set("temp-mewosorasu.png", "temp-in-house.png") },

      { **cut_key(ar_key('イントロ',   7,  'こんにちは！')),    message: 'うぐぐ～！',                                        **image_set("temp-mewosorasu.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   7,  'なかよくしてね！')), message: 'うぐぐ～！',                                        **image_set("temp-mewosorasu.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   7,  'よしよし')),        message: '〈たまご〉 「んに～！」',                            **image_set("temp-nikoniko.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   8,  'つぎへ')),          message: 'なんだ！ けっこう すなおじゃん！',                    **image_set("temp-nikoniko2.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   8,  'つぎへ'), 2),       message: 'とにかく、 ちょっときょりが ちじまったきがする！',      **image_set("temp-nikoniko2.png", "temp-in-house.png") },
      { **cut_key(ar_key('イントロ',   8,  'つぎへ'), 3),       message: 'これからよろしくね、 〈たまご〉！',                    **image_set("temp-nikoniko2.png", "temp-in-house.png") },

      { **cut_key(ar_key('誕生日',     0,  'つぎへ')), message: '〈たまご〉 「にににーに・・・」', **image_set("temp-maekagami.png") },
      { **cut_key(ar_key('誕生日',     0,  'つぎへ'), 2), message: '〈たまご〉 「ににににー！！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     0,  'つぎへ'), 3), message: 'あ！ 〈たまご〉が たんじょうびを いわってくれた！', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     0,  'つぎへ'), 4), message: '〈たまご〉 「ににににに、 んににに、 ににーに？」', **image_set("temp-nikoniko2.png") },

      { **cut_key(ar_key('誕生日',     1,  'たのしくすごす！')), message: '〈たまご〉 「ににー！ にー、 にににーにんににーに！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'たのしくすごす！'), 2), message: 'ワクワクが いっぱいの いちねんになりますよう！',      **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'えがおですごす！')), message: '〈たまご〉 「ににー！ にー、 にににーにんににーに！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'えがおですごす！'), 2), message: 'ワクワクが いっぱいの いちねんになりますよう！',      **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'せいちょうする！')), message: '〈たまご〉 「ににー！ にー、 にににーにんににーに！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'せいちょうする！'), 2), message: 'すてきな いちねんに なりますよう！',                **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'ひとをだいじにする！')), message: '〈たまご〉 「ににー！ にー、 にににーにんににーに！」', **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('誕生日',     1,  'ひとをだいじにする！'), 2), message: 'すてきな いちねんに なりますよう！',                **image_set("temp-nikoniko2.png") },

      { **cut_key(ar_key('タマモンカート', 0,  'ながめている')), message: '〈たまご〉 「ににー！」',                          **image_set("temp-game-nikoniko.png"),
      messages: [ '〈たまご〉 「ににー！」', '〈たまご〉 「にっにに～！」', '〈たまご〉 「んにー！ ににー！」', 'いま、 だいにんきの タマモンカートだ！', 'いいぞ！ はやいぞー！', 'おいぬけー！', 'アイテムをとった！ これはきょうりょく！', 'さいきんの レースゲームは、 りんじょうかんが すごい！', 'はやすぎて めがまわるー！',
                  'ライバルに おいぬかれた！まけるなー', 'ふくざつな コースだ！ぶつからず はしれるか！？', '〈たまご〉は レースゲームにだいこうふん！', '〈たまご〉は レースゲームが だいすき！ おとなになったら、 ほんとの クルマものりたいね！', 'いいスタートだ！ はやいぞー！', 'レースゲームなのに コースに バナナのカワが おちている！ あぶないなあ！',
                  'いいドリフト！ かっこいいー！', 'いいカソク！ そのままおいぬけー！', 'げんざいトップだ！ ライバルを きりはなせ！', 'あー！ カートが カベにぶつかってる！！', 'はやいぞー！・・・って、 ぎゃくそうしてない！？', 'レースゲームといったら、 やっぱ タマモンカートだよね！' ] },
      { **cut_key(ar_key('タマモンカート', 0,  'ながめている',  2)), message: '〈たまご〉 「ににー！」',                          **image_set("temp-game-ochikomu.png"),
      messages: [ 'あちゃー！ おいぬかれたー！', 'あー！ ビリじゃんー！', 'ライバルに こうげきされた！ あちゃー！', 'なかなか いいアイテムが でないようだ！', 'カートが スピンしちゃった！ あれれー！' ] },

      { **cut_key(ar_key('元気ない？', 1, 'そんなことないよ！')), message: '〈たまご〉 「ににににー？」',                      **image_set("temp-sounanokanaa.png") },
      { **cut_key(ar_key('元気ない？', 1, 'そんなことないよ！'), 2), message: '〈たまご〉 「にに、 にーに！」',                 **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('元気ない？', 1, 'そんなことないよ！'), 3), message: '〈たまご〉は あんしんしたようだ！',              **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('元気ない？', 1, 'そんなことないよ！'), 4), message: 'しんぱい してくれて ありがとうね！',             **image_set("temp-nikoniko2.png") },

      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて')),     message: '〈たまご〉 「ににに、 んにににー・・・。」',                **image_set("temp-kanasii.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 2),  message: '〈たまご〉 「にー・・・。」',                              **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 3),  message: '〈たまご〉 「にに！」',                                   **image_set("temp-yaruki.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 4),  message: '？？？',                                                **image_set("temp-none.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 5),  message: 'バタバタ バタバタ',                                      **image_set("temp-none.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 6),  message: '〈たまご〉 「にー！」',                                   **image_set("temp-none.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 7),  message: 'あ！ おにぎり！ 〈たまご〉が つくったの！？',               **image_set("temp-onigiri.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 8),  message: 'これたべて げんきだして ってこと？',                        **image_set("temp-nikoniko3.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 9),  message: '〈たまご〉 「んにー！」',                                 **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 10), message: 'ありがとう！ 〈たまご〉の つくった おにぎりいただくね！',    **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 11), message: 'たべてみると、 おにぎりは しおと さとうを まちがえたものだった。', **image_set("temp-none.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 12), message: 'でも、 おいしかった。 ごちそうさま。',                      **image_set("temp-none.png") },
      { **cut_key(ar_key('元気ない？', 1, 'さいきんつかれてて'), 13), message: 'げんきが わいてきた きがする！。',                          **image_set("temp-none.png") },

      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって')),     message: '〈たまご〉 「ににに、 んにににー・・・。」',                **image_set("temp-kanasii.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 2),  message: '〈たまご〉 「・・・。」',                                 **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 3),  message: '〈たまご〉 「ににー！」',                                **image_set("temp-tewoageru.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 4),  message: '？？？',                                                **image_set("temp-none.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 5),  message: '・・・。',                                              **image_set("temp-none.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 6),  message: '〈たまご〉 「にー！」',                                   **image_set("temp-none.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 7),  message: 'ん？ おはなだ！ これくれるの？',                          **image_set("temp-flower.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 8),  message: 'きれいで めずらしい おはな！ 〈たまご〉が みつけてきて くれたみたい！', **image_set("temp-flower.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 9),  message: '〈たまご〉 「にー！ ににー！」',                          **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 10), message: 'ありがとう！',                                          **image_set("temp-none.png") },
      { **cut_key(ar_key('元気ない？', 1, 'つらいことがあって'), 11), message: 'なんだか、 きもちが かるくなった きがする！。',            **image_set("temp-none.png") },

      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって')),     message: '〈たまご〉 「ににに、 にーににー・・・。」',                **image_set("temp-kanasii.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 2),  message: '〈たまご〉 「んにに・・・。」',                            **image_set("temp-ochikomu.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 3),  message: '〈たまご〉 「・・・。」',                                 **image_set("temp-kanasii.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 4),  message: '〈たまご〉 「にーににー・・・、」',                        **image_set("temp-inai-inai.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 5),  message: '〈たまご〉 「にー！」',                                  **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 6),  message: '！！',                                                  **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 7),  message: '〈たまご〉 「にーににー・・・、」',                        **image_set("temp-inai-inai.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 8),  message: '〈たまご〉 「にー！」',                                  **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 9),  message: '〈たまご〉が なんとか げんきづけようと してくれてる。',      **image_set("temp-nikoniko3.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 10),  message: 'そうだ、いつまでも おちこんでちゃ だめだよね。',            **image_set("temp-komattakao.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 11),  message: 'だいじょうぶ、 ちょっとずつまえを むけそうな きがするよ！',  **image_set("temp-normal.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 12),  message: 'ありがとうね、 〈たまご〉！',                             **image_set("temp-nikoniko2.png") },
      { **cut_key(ar_key('元気ない？', 1, 'かなしいことがあって'), 13),  message: '〈たまご〉 「にー！」',                                   **image_set("temp-nikoniko.png") },

      { **cut_key(ar_key('マニュアル', 1, 'ごはん')),                  message: '〈たまご〉は じかんがたつと おなかがへるよ。',                 **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'ごはん'), 2),               message: 'おなかがへると ないちゃうから、ていきてきに ごはんをあげよう。', **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'ごはん'), 3),               message: 'また、 ごはんを いっぱいあげると たいりょくが つくよ。',        **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'ごはん'), 4),               message: 'いっぽうで おやつは たいりょくが つかないが、',                **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'ごはん'), 5),               message: 'おやつのほうが よろこぶので バランスがだいじ。',                **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'ごはん'), 6),               message: 'ちなみに ごはんは LINEからも あげることが できるので、',        **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'ごはん'), 7),               message: 'いそがしいときは LINEで あげてもいいね。 LINEれんけいは せっていがめん から。', **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 1, 'よしよし')),                message: '〈たまご〉は さびしくなると ないてしまうので、',                   **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'よしよし'), 2),             message: 'ていきてきに よしよし しよう。',                                  **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'よしよし'), 3),             message: 'ちなみに 〈たまご〉は いろんな たいけんを つうじて あなたになつくが、', **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'よしよし'), 4),             message: 'きほんは よしよし してくれるひとを このむぞ。',                    **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'よしよし'), 5),             message: 'LINEからも よしよし することが できるので、',                      **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 1, 'よしよし'), 6),             message: 'いそがしいときは LINEで よしよしも あり。LINEれんけいは せっていがめんから。', **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 1, 'よむのをやめる')),           message: '〈ユーザー〉は ノートを とじた！',                               **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 2, 'ボールあそび')),             message: '〈たまご〉は ボールあそびが だいすき。',                          **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'ボールあそび'), 2),          message: 'うまく しじをだすと ボールを キャッチしてくれるよ。',              **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'ボールあそび'), 3),          message: 'しじが ちょっとずれても なんとか キャッチしてくれるかも。',         **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'ボールあそび'), 4),          message: 'うんどうしんけいが どれだけ よくなったかは ステータスがめんで かくにんできるよ。', **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'ボールあそび'), 5),          message: 'ちなみに れんぞくで あそびつづけると つかれちゃうよ。',             **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 2, 'べんきょう')),              message: 'べんきょうは だいじ。',                                  **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 2),           message: 'さんすうは けいさんもんだいに ちょうせん できるよ。',       **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 3),           message: 'こくごは どくしょで べんきょう。',                         **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 4),           message: 'むずかしい ほんにも ちょうせん してもらおう。',             **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 5),           message: 'りかは じっけんを おこなうよ。',                           **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 6),           message: 'せいこう するために、しっぱいを くりかえそう。',            **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 7),           message: 'しゃかいは きょうかしょを よむけど、',                     **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 8),           message: 'なぜか いつも ふしぎなげんしょうが おきる。',               **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 9),           message: 'でもそれが がくしゅういよくの こうじょうに つながることも。',  **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 10),          message: 'べんきょうが どれだけ とくいになったかは ステータスがめんで かくにんできるよ。', **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'べんきょう'), 11),          message: 'ちなみに れんぞくで べんきょうしつづけると つかれちゃうよ。', **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 2, 'おえかき')),                message: '〈たまご〉は おえかきが だいすき。',                 **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'おえかき'), 2),             message: 'いろんな えを かかせてあげよう。',                   **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'おえかき'), 3),             message: 'もしかしたら かくれたさいのうが ばくはつするかも？',   **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 2, 'おえかき'), 4),             message: 'ちなみに おえかきは れんぞくでしても つかれないよ。',  **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 3, 'ゲーム')),                  message: 'ゲームは 30ぷんと じかんをきめて あそばせてあげよう。',                **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 3, 'ゲーム'), 2),               message: 'そのあいだ 〈たまご〉は むちゅうになるから、',                        **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 3, 'ゲーム'), 3),               message: 'じっさいに 30ぷんかん、 かまって もらえなくなるけど',                  **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 3, 'ゲーム'), 4),               message: 'ゲームをさせてあげると とてもよろこぶから、 ぜひ あそばせてあげよう。',  **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 3, 'ゲーム'), 5),               message: 'そばで みていてもいいし、 『またあとで』と してもよし。',               **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 3, 'なつきぐあい')),            message: '〈たまご〉は いろんなたいけんを つうじて あなたになつくが、',   **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 3, 'なつきぐあい'), 2),         message: 'きほんは よしよし してくれるひとを このむぞ。',                **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 3, 'なつきぐあい'), 3),         message: 'あとは おやつをあげたり、 ゲームで あそばせて あげるのもいい。', **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 3, 'なつきぐあい'), 4),         message: 'ちなみに いじわるをすると、 いっきに きょりが できてしまうぞ。', **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 3, 'どういうときなく？')),         message: 'おなかが へったり、 さびしく なったりすると ないてしまうよ。', **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 3, 'どういうときなく？'), 2),      message: 'ていきてきに ごはんを あげたり よしよし しよう。',            **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 3, 'どういうときなく？'), 3),      message: 'ほかのりゆうで なくことも あるけどね。',                     **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 4, 'どういうときおこる？')),       message: '〈たまご〉に いじわるを すると おこってしまうよ。',                   **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 4, 'どういうときおこる？'), 2),    message: 'あやまったり すれば ゆるしてくれるかも しれないけど、',                **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 4, 'どういうときおこる？'), 3),    message: 'いじわるの ないように よっては、いっきに きょりを おかれてしまうので、', **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 4, 'どういうときおこる？'), 4),    message: 'ぜったいに いじわるはしないこと。',                                   **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 4, 'なにかにむちゅうなとき')),    message: '〈たまご〉は あそびだしたり マンガを よみだしたりすると、',     **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 4, 'なにかにむちゅうなとき'), 2), message: 'しばらく むちゅうになって、 かまって くれなくなるよ。',         **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 4, 'なにかにむちゅうなとき'), 3), message: 'でも そういうときは じゃまを しないであげようね。',            **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 4, 'なにかにむちゅうなとき'), 4), message: '『またあとで』で そばを はなれても オッケー。',                **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 4, 'すいみん')),                message: 'よるになると ねむくなるし、 おそくなると かってにねるよ。',         **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 4, 'すいみん'), 2),             message: 'でも あなたが ねかせてあげると とてもよろこぶよ。',                **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 4, 'すいみん'), 3),             message: 'まあ、 なかなか ねてくれなかったり するんだけどね。',              **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 5, 'すきなテレビ')),            message: '〈たまご〉は きまった ようびのよるに、 すきな テレビばんぐみが あるよ。', **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 5, 'すきなテレビ'), 2),         message: 'なんようび だったか わすれたけど、 せっきょくてきに みせてあげてね。',    **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 5, 'すきなテレビ'), 3),         message: 'そのあいだ 〈たまご〉は むちゅうに なるから、',                        **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 5, 'すきなテレビ'), 4),         message: '『またあとで』で そばをはなれても オッケー。',                         **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 5, 'すきなテレビ'), 5),         message: 'あと まいあさ テレビで うらないを みるのが すきらしいよ。',             **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 5, 'きせつによって')),        message: '〈たまご〉は きせつを かんじることが だいすき。',     **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 5, 'きせつによって'), 2),        message: 'ふゆは こたつで ミカンを たべるのが すきみたい。',    **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 5, 'きせつによって'), 3),        message: 'きせつを かんじると いつもいじょうに よろこぶので、',  **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 5, 'きせつによって'), 4),        message: 'いろんな たいけんを させてあげよう。',                **image_set("temp-manual.png") },

      { **cut_key(ar_key('マニュアル', 5, 'はなしをきいてあげると')),     message: '〈たまご〉は おはなしを きいてもらうのが だいすき。', **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 5, 'はなしをきいてあげると'), 1),  message: 'たわいもない はなしが たいていだけど、',             **image_set("temp-manual.png") },
      { **cut_key(ar_key('マニュアル', 5, 'はなしをきいてあげると'), 2),  message: 'まじめな そうだんを してくることも あるかも？',       **image_set("temp-manual.png") }
    ]

    kept_cut_ids ||= []
    cuts.each do |attrs|
      set    = EventSet.find_by!(name: attrs[:event_set_name])
      event  = Event.find_by!(event_set: set, derivation_number: attrs[:derivation_number])
      choice = ActionChoice.find_by!(event: event, label: attrs[:label])
      result = ActionResult.find_by!(action_choice: choice, priority: attrs[:priority])

      cut = Cut.find_or_initialize_by(action_result: result, position: attrs[:position])
      cut.message          = attrs[:message]
      cut.messages         = Array(attrs[:messages] || [])
      cut.character_image  = attrs[:character_image]
      cut.background_image = attrs[:background_image]
      cut.save!

      kept_cut_ids << cut.id
    end
    raise "kept_cut_idsが空です。削除処理を中断します。" if kept_cut_ids.blank?
    Cut.where.not(id: kept_cut_ids).delete_all

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
