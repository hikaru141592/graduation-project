categories = [
  { name: '通常',     description: '何か言っている、何かしたそう',                         loop_minutes: nil  },
  { name: 'ルンルン', description: '踊っている',                                           loop_minutes: 3   },
  { name: '泣いている', description: '泣いている(空腹)、泣いている(よしよし不足)、泣いている(ランダム)', loop_minutes: 20 },
  { name: '怒っている', description: '怒っている',                                         loop_minutes: 20   },
  { name: '夢中',     description: 'ブロックのおもちゃに夢中、マンガに夢中',               loop_minutes: 12  },
  { name: '眠そう',   description: '眠そう',                                               loop_minutes: 12   },
  { name: '寝ている', description: '寝ている',                                             loop_minutes: 60   },
  { name: '寝かせた', description: '寝かせた',                                             loop_minutes: 240   },
  { name: '算数',     description: '算数',                                               loop_minutes: nil   },
  { name: 'ボール遊び', description: 'ボール遊び',                                        loop_minutes: nil   },
  { name: '特訓',     description: '特訓',                                               loop_minutes: nil   }
]

categories.each do |attrs|
  category = EventCategory.find_or_initialize_by(name: attrs[:name])
  category.description  = attrs[:description]
  category.loop_minutes = attrs[:loop_minutes]
  category.save!
end

event_sets = [
  { category_name: '通常',      name: '何か言っている' },
  { category_name: '通常',      name: '何かしたそう' },
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
  { category_name: '算数',      name: '算数' },
  { category_name: 'ボール遊び',      name: 'ボール遊び' },
  { category_name: '特訓',      name: '特訓' }
]

event_sets.each do |attrs|
  category = EventCategory.find_by!(name: attrs[:category_name])
  set = EventSet.find_or_initialize_by(
    event_category: category,
    name:          attrs[:name]
  )
  set.trigger_conditions = { always: true }
  set.save!
end

event_set_conditions = [
  {
    name: '泣いている(空腹)',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":      "status",
          "attribute": "hunger_value",
          "operator":  "<=",
          "value":     20
        }
      ]
    }
  },
  {
    name: '泣いている(よしよし不足)',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":      "status",
          "attribute": "love_value",
          "operator":  "<=",
          "value":     40
        }
      ]
    }
  },
  {
    name: '泣いている(ランダム)',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 3
        }
      ]
    }
  },
  {
    name: '踊っている',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":      "status",
          "attribute": "mood_value",
          "operator":  ">=",
          "value":     80
        }
      ]
    }
  },
  {
    name: '何かしたそう',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 50
        }
      ]
    }
  },
  {
    name: '何か言っている',
    trigger_conditions: {
      "always": true
    }
  },
  {
    name: '寝ている',
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 0,
          "from_min":  46,
          "to_hour":   6,
          "to_min":    38,
          "offsets_by_day": [
            {
              "add":        43,
              "mult":       17,
              "mod":        60,
              "target":     "to_min"
            },
            {
              "add":        27,
              "mult":       19,
              "mod":        60,
              "target":     "from_min"
            }
          ]
        }
      ]
    }
  },
  {
    name: 'ブロックのおもちゃに夢中',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 2
        }
      ]
    }
  },
  {
    name: 'マンガに夢中',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 5
        }
      ]
    }
  },
  {
    name: '眠そう',
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 22,
          "from_min":  14,
          "to_hour":   2,
          "to_min":    0,
          "offsets_by_day": [
            {
              "add":        14,
              "mult":       43,
              "mod":        60,
              "target":     "to_min"
            },
            {
              "add":        5,
              "mult":       17,
              "mod":        60,
              "target":     "from_min"
            }
          ]
        }
      ]
    }
  },
  {
    name: '寝かせた',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 0
        }
      ]
    }
  },
  {
    name: '怒っている',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 0
        }
      ]
    }
  },
  {
    name: '算数',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 0
        }
      ]
    }
  },
  {
    name: 'ボール遊び',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 0
        }
      ]
    }
  },
  {
    name: '特訓',
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 0
        }
      ]
    }
  }
]

event_set_conditions.each do |attrs|
  set = EventSet.find_by!(name: attrs[:name])
  set.update!(trigger_conditions: attrs[:trigger_conditions])
end

events = [
  {
    event_set_name:    '何か言っている',
    name:              '何か言っている',
    derivation_number: 0,
    message:           '〈たまご〉がなにかいっているよ。',
    character_image:   'character/kari-normal.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '何かしたそう',
    name:              'べんきょうする',
    derivation_number: 1,
    message:           'よし！なんのべんきょうをしよう？',
    character_image:   'character/kari-nikoniko2.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '何かしたそう',
    name:              '何かしたそう',
    derivation_number: 0,
    message:           '〈たまご〉はなにかしたそうだ。',
    character_image:   'character/kari-normal.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '踊っている',
    name:              '踊っている',
    derivation_number: 0,
    message:           '〈たまご〉はおどっている！',
    character_image:   'character/kari-dance.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '泣いている(空腹)',
    name:              '泣いている(空腹)',
    derivation_number: 0,
    message:           '〈たまご〉がないている！',
    character_image:   'character/kari-naku.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '泣いている(よしよし不足)',
    name:              '泣いている(よしよし不足)',
    derivation_number: 0,
    message:           '〈たまご〉がないている！',
    character_image:   'character/kari-naku.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '泣いている(ランダム)',
    name:              '泣いている(ランダム)',
    derivation_number: 0,
    message:           '〈たまご〉がないている！',
    character_image:   'character/kari-naku.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '怒っている',
    name:              '怒っている',
    derivation_number: 0,
    message:           '〈たまご〉はおこっている！',
    character_image:   'character/kari-okoru.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '寝ている',
    name:              '寝ている',
    derivation_number: 0,
    message:           '〈たまご〉はねている。',
    character_image:   'character/kari-sleep.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    'ブロックのおもちゃに夢中',
    name:              'ブロックのおもちゃに夢中',
    derivation_number: 0,
    message:           '〈たまご〉はブロックのおもちゃにむちゅうだ。',
    character_image:   'character/kari-building_blocks.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    'マンガに夢中',
    name:              'マンガに夢中',
    derivation_number: 0,
    message:           '〈たまご〉はマンガをよんでいる。',
    character_image:   'character/kari-comics.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '眠そう',
    name:              '眠そう',
    derivation_number: 0,
    message:           '〈たまご〉はねむそうにしている。',
    character_image:   'character/kari-sleepy.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '寝かせた',
    name:              '寝かせた',
    derivation_number: 0,
    message:           '〈たまご〉はねている。',
    character_image:   'character/kari-sleep.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '出題前',
    derivation_number: 0,
    message:           'よし、さんすうのもんだいにちょうせんだ！',
    character_image:   'character/kari-nikoniko2.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '1つ目が正解',
    derivation_number: 1,
    message:           '「X 演算子 Y」のこたえは？',
    character_image:   'character/kari-kangaeru.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '2つ目が正解',
    derivation_number: 2,
    message:           '「X 演算子 Y」のこたえは？',
    character_image:   'character/kari-kangaeru.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '3つ目が正解',
    derivation_number: 3,
    message:           '「X 演算子 Y」のこたえは？',
    character_image:   'character/kari-kangaeru.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '4つ目が正解',
    derivation_number: 4,
    message:           '「X 演算子 Y」のこたえは？',
    character_image:   'character/kari-kangaeru.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '投球前',
    derivation_number: 0,
    message:           'ボールなげるよー！',
    character_image:   'character/kari-ball1.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '投球',
    derivation_number: 1,
    message:           'ブンッ！',
    character_image:   'character/kari-ball2.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '左が成功',
    derivation_number: 2,
    message:           'ボールをなげた！〈たまご〉、そっちだ！',
    character_image:   'character/kari-ball3.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '真ん中が成功',
    derivation_number: 3,
    message:           '〈たまご〉、そっちだ！',
    character_image:   'character/kari-ball3.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '右が成功',
    derivation_number: 4,
    message:           '〈たまご〉、そっちだ！',
    character_image:   'character/kari-ball3.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓',
    derivation_number: 0,
    message:           'なんのとっくんをしよう？',
    character_image:   'character/kari-kangaeru.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓終了',
    derivation_number: 1,
    message:           'ここまで！',
    character_image:   'character/kari-tukareta.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓結果優秀',
    derivation_number: 2,
    message:           '20もんちゅう〈X〉もんせいかい！〈Y〉分〈Z〉秒クリア！すごいね！',
    character_image:   'character/kari-nikoniko.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓結果良し',
    derivation_number: 3,
    message:           '20もんちゅう〈X〉もんせいかい！よくがんばったね！',
    character_image:   'character/kari-nikoniko2.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓結果微妙',
    derivation_number: 4,
    message:           '20もんちゅう〈X〉もんせいかい！またちょうせんしよう！',
    character_image:   'character/kari-bimuyou.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              'ボール遊び特訓結果良し',
    derivation_number: 5,
    message:           '〈X〉かいせいこう！よくがんばったね！',
    character_image:   'character/kari-nikoniko2.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              'ボール遊び特訓結果微妙',
    derivation_number: 6,
    message:           '〈X〉かいせいこう！またちょうせんしよう！',
    character_image:   'character/kari-bimuyou.png',
    background_image:  'background/kari-background.png'
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
  {
    event_set_name:    '何か言っている',
    derivation_number: 0,
    labels:            [ 'はなしをきいてあげる', 'よしよしする', 'おやつをあげる', 'ごはんをあげる' ]
  },
  {
    event_set_name:    '何かしたそう',
    derivation_number: 0,
    labels:            [ 'ボールあそびをする',   'べんきょうする',   'おえかきする',     'ゲームする' ]
  },
  {
    event_set_name:    '何かしたそう',
    derivation_number: 1,
    labels:            [ 'さんすう',   'こくご',   'りか',     'しゃかい' ]
  },
  {
    event_set_name:    '踊っている',
    derivation_number: 0,
    labels:            [ 'よしよしする',       'おやつをあげる',   'ごはんをあげる' ]
  },
  {
    event_set_name:    '泣いている(空腹)',
    derivation_number: 0,
    labels:            [ 'よしよしする',       'おやつをあげる',   'ごはんをあげる',   'あそんであげる' ]
  },
  {
    event_set_name:    '泣いている(よしよし不足)',
    derivation_number: 0,
    labels:            [ 'よしよしする',       'おやつをあげる',   'ごはんをあげる',   'あそんであげる' ]
  },
  {
    event_set_name:    '泣いている(ランダム)',
    derivation_number: 0,
    labels:            [ 'よしよしする',       'おやつをあげる',   'ごはんをあげる',   'あそんであげる' ]
  },
  {
    event_set_name:    '寝ている',
    derivation_number: 0,
    labels:            [ 'そっとする',        'よしよしする',     'たたきおこす' ]
  },
  {
    event_set_name:    'ブロックのおもちゃに夢中',
    derivation_number: 0,
    labels:            [ 'そっとする',       'よしよしする',   'ちょっかいをだす',   'ブロックをくずす' ]
  },
  {
    event_set_name:    'マンガに夢中',
    derivation_number: 0,
    labels:            [ 'そっとする',       'よしよしする',   'はなしかける',   'マンガをとりあげる' ]
  },
  {
    event_set_name:    '眠そう',
    derivation_number: 0,
    labels:            [ 'ねかせる',         'よしよしする',   'はみがきをさせる', 'ダジャレをいう' ]
  },
  {
    event_set_name:    '寝かせた',
    derivation_number: 0,
    labels:            [ 'そっとする',        'よしよしする',     'たたきおこす' ]
  },
  {
    event_set_name:    '怒っている',
    derivation_number: 0,
    labels:            [ 'よしよしする',       'おやつをあげる',   'へんがおをする', 'あやまる' ]
  },
  {
    event_set_name:    '算数',
    derivation_number: 0,
    labels:            [ 'すすむ' ]
  },
  {
    event_set_name:    '算数',
    derivation_number: 1,
    labels:            [ '〈A〉', '〈B〉', '〈C〉', '〈D〉' ]
  },
  {
    event_set_name:    '算数',
    derivation_number: 2,
    labels:            [ '〈B〉', '〈A〉', '〈C〉', '〈D〉' ]
  },
  {
    event_set_name:    '算数',
    derivation_number: 3,
    labels:            [ '〈B〉', '〈C〉', '〈A〉', '〈D〉' ]
  },
  {
    event_set_name:    '算数',
    derivation_number: 4,
    labels:            [ '〈B〉', '〈C〉', '〈D〉', '〈A〉' ]
  },
  {
    event_set_name:    'ボール遊び',
    derivation_number: 0,
    labels:            [ 'すすむ' ]
  },
  {
    event_set_name:    'ボール遊び',
    derivation_number: 1,
    labels:            [ 'ぜんりょくとうきゅう' ]
  },
  {
    event_set_name:    'ボール遊び',
    derivation_number: 2,
    labels:            [ 'ひだりだ！', 'そこだ！', 'みぎだ！' ]
  },
  {
    event_set_name:    'ボール遊び',
    derivation_number: 3,
    labels:            [ 'ひだりだ！', 'そこだ！', 'みぎだ！' ]
  },
  {
    event_set_name:    'ボール遊び',
    derivation_number: 4,
    labels:            [ 'ひだりだ！', 'そこだ！', 'みぎだ！' ]
  },
  {
    event_set_name:    '特訓',
    derivation_number: 0,
    labels:            [ 'さんすう',       'ボールあそび' ]
  },
  {
    event_set_name:    '特訓',
    derivation_number: 1,
    labels:            [ 'すすむ' ]
  },
  {
    event_set_name:    '特訓',
    derivation_number: 2,
    labels:            [ 'すすむ' ]
  },
  {
    event_set_name:    '特訓',
    derivation_number: 3,
    labels:            [ 'すすむ' ]
  },
  {
    event_set_name:    '特訓',
    derivation_number: 4,
    labels:            [ 'すすむ' ]
  },
  {
    event_set_name:    '特訓',
    derivation_number: 5,
    labels:            [ 'すすむ' ]
  },
  {
    event_set_name:    '特訓',
    derivation_number: 6,
    labels:            [ 'すすむ' ]
  }
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
    event_set_name:        '何か言っている',
    derivation_number:     0,
    label:                 'はなしをきいてあげる',
    priority:              1,
    trigger_conditions:    { "operator": "or", "conditions": [ { "type": "status", "attribute": "sports_value", "operator": "<", "value": 5 },
                                                               { "type": "status", "attribute": "arithmetic", "operator": "<", "value": 5 },
                                                               { "type": "probability", "percent": 50 } ] },
    effects:               { "status": [ { "attribute": "mood_value", "delta": 10 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何か言っている',
    derivation_number:     0,
    label:                 'はなしをきいてあげる',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  '特訓',
    resolves_loop:         false
  },
  {
    event_set_name:        '何か言っている',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 10 },
                                         { "attribute": "mood_value", "delta": 10 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何か言っている',
    derivation_number:     0,
    label:                 'おやつをあげる',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "status",
                                  "attribute": "hunger_value",
                                  "operator": "<=",
                                  "value": 90
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "hunger_value", "delta": 30 },
                                         { "attribute": "mood_value", "delta": 30 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何か言っている',
    derivation_number:     0,
    label:                 'おやつをあげる',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何か言っている',
    derivation_number:     0,
    label:                 'ごはんをあげる',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "status",
                                  "attribute": "hunger_value",
                                  "operator": "<=",
                                  "value": 70
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "hunger_value", "delta": 40 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何か言っている',
    derivation_number:     0,
    label:                 'ごはんをあげる',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     0,
    label:                 'ボールあそびをする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  'ボール遊び',
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     0,
    label:                 'べんきょうする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: 1,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     0,
    label:                 'おえかきする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "mood_value", "delta": 20 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     0,
    label:                 'ゲームする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "mood_value", "delta": 20 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'さんすう',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  '算数',
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'こくご',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 5
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "japanese", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'こくご',
    priority:              2,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 20
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "japanese", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'こくご',
    priority:              3,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "japanese_effort", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'りか',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 5
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "science", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'りか',
    priority:              2,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 20
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "science", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'りか',
    priority:              3,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "science_effort", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'しゃかい',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 5
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "social_studies", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'しゃかい',
    priority:              2,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 20
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "social_studies", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     1,
    label:                 'しゃかい',
    priority:              3,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "social_effort", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '踊っている',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 6
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "love_value", "delta": 10 },
                                         { "attribute": "mood_value", "delta": -100 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '踊っている',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 10 },
                                         { "attribute": "happiness_value", "delta": 1 },
                                         { "attribute": "mood_value", "delta": -100 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '踊っている',
    derivation_number:     0,
    label:                 'おやつをあげる',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "status",
                                  "attribute": "hunger_value",
                                  "operator": "<=",
                                  "value": 90
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "hunger_value", "delta": 30 },
                                         { "attribute": "mood_value", "delta": -100 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '踊っている',
    derivation_number:     0,
    label:                 'おやつをあげる',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '踊っている',
    derivation_number:     0,
    label:                 'ごはんをあげる',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "status",
                                  "attribute": "hunger_value",
                                  "operator": "<=",
                                  "value": 70
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "hunger_value", "delta": 40 },
                                         { "attribute": "mood_value", "delta": -100 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '踊っている',
    derivation_number:     0,
    label:                 'ごはんをあげる',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '泣いている(空腹)',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 5 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '泣いている(空腹)',
    derivation_number:     0,
    label:                 'おやつをあげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "hunger_value", "delta": 40 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '泣いている(空腹)',
    derivation_number:     0,
    label:                 'ごはんをあげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "hunger_value", "delta": 50 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '泣いている(空腹)',
    derivation_number:     0,
    label:                 'あそんであげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '泣いている(よしよし不足)',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 40 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '泣いている(よしよし不足)',
    derivation_number:     0,
    label:                 'おやつをあげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '泣いている(よしよし不足)',
    derivation_number:     0,
    label:                 'ごはんをあげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '泣いている(よしよし不足)',
    derivation_number:     0,
    label:                 'あそんであげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '泣いている(ランダム)',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '泣いている(ランダム)',
    derivation_number:     0,
    label:                 'おやつをあげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '泣いている(ランダム)',
    derivation_number:     0,
    label:                 'ごはんをあげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '泣いている(ランダム)',
    derivation_number:     0,
    label:                 'あそんであげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 30 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '寝ている',
    derivation_number:     0,
    label:                 'そっとする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝ている',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 40 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝ている',
    derivation_number:     0,
    label:                 'たたきおこす',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        'ブロックのおもちゃに夢中',
    derivation_number:     0,
    label:                 'そっとする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        'ブロックのおもちゃに夢中',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 10 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        'ブロックのおもちゃに夢中',
    derivation_number:     0,
    label:                 'ちょっかいをだす',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 20
                                }
                              ]
                            },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  '怒っている',
    resolves_loop:         true
  },
  {
    event_set_name:        'ブロックのおもちゃに夢中',
    derivation_number:     0,
    label:                 'ちょっかいをだす',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        'ブロックのおもちゃに夢中',
    derivation_number:     0,
    label:                 'ブロックをくずす',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 6
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "happiness_value", "delta": -2 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  '怒っている',
    resolves_loop:         true
  },
  {
    event_set_name:        'ブロックのおもちゃに夢中',
    derivation_number:     0,
    label:                 'ブロックをくずす',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        'マンガに夢中',
    derivation_number:     0,
    label:                 'そっとする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        'マンガに夢中',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 10 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        'マンガに夢中',
    derivation_number:     0,
    label:                 'はなしかける',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 30
                                }
                              ]
                            },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        'マンガに夢中',
    derivation_number:     0,
    label:                 'はなしかける',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        'マンガに夢中',
    derivation_number:     0,
    label:                 'マンガをとりあげる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "happiness_value", "delta": -2 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  '怒っている',
    resolves_loop:         true
  },
  {
    event_set_name:        '眠そう',
    derivation_number:     0,
    label:                 'ねかせる',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 30
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "happiness_value", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  '寝かせた',
    resolves_loop:         true
  },
  {
    event_set_name:        '眠そう',
    derivation_number:     0,
    label:                 'ねかせる',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '眠そう',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 20
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "love_value", "delta": 10 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  '寝かせた',
    resolves_loop:         true
  },
  {
    event_set_name:        '眠そう',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 10 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '眠そう',
    derivation_number:     0,
    label:                 'はみがきをさせる',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 33
                                }
                              ]
                            },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  '寝かせた',
    resolves_loop:         true
  },
  {
    event_set_name:        '眠そう',
    derivation_number:     0,
    label:                 'はみがきをさせる',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '眠そう',
    derivation_number:     0,
    label:                 'ダジャレをいう',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 5
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "happiness_value", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '眠そう',
    derivation_number:     0,
    label:                 'ダジャレをいう',
    priority:              2,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 20
                                }
                              ]
                            },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '眠そう',
    derivation_number:     0,
    label:                 'ダジャレをいう',
    priority:              3,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝かせた',
    derivation_number:     0,
    label:                 'そっとする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝かせた',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 20 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝かせた',
    derivation_number:     0,
    label:                 'たたきおこす',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '怒っている',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 25
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "love_value", "delta": 10 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '怒っている',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 3 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '怒っている',
    derivation_number:     0,
    label:                 'おやつをあげる',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "status",
                                  "attribute": "hunger_value",
                                  "operator": "<=",
                                  "value": 50
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "hunger_value", "delta": 30 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '怒っている',
    derivation_number:     0,
    label:                 'おやつをあげる',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '怒っている',
    derivation_number:     0,
    label:                 'へんがおをする',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 10
                                }
                              ]
                            },
    effects:               { "status": [ { "attribute": "happiness_value", "delta": 1 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '怒っている',
    derivation_number:     0,
    label:                 'へんがおをする',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '怒っている',
    derivation_number:     0,
    label:                 'あやまる',
    priority:              1,
    trigger_conditions:    {
                              "operator": "and",
                              "conditions": [
                                {
                                  "type": "probability",
                                  "percent": 33
                                }
                              ]
                            },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '怒っている',
    derivation_number:     0,
    label:                 'あやまる',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name: '算数', derivation_number: 0, label: 'すすむ', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 25 } ] },
    effects: {},
    next_derivation_number: 1, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 0, label: 'すすむ', priority: 2,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 33 } ] },
    effects: {},
    next_derivation_number: 2, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 0, label: 'すすむ', priority: 3,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 50 } ] },
    effects: {},
    next_derivation_number: 3, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 0, label: 'すすむ', priority: 4,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: 4, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 1, label: '〈A〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 1, label: '〈B〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 1, label: '〈C〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 1, label: '〈D〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 2, label: '〈A〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 2, label: '〈B〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 2, label: '〈C〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 2, label: '〈D〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 3, label: '〈A〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 3, label: '〈B〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 3, label: '〈C〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 3, label: '〈D〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 4, label: '〈A〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 4, label: '〈B〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 4, label: '〈C〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 4, label: '〈D〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 0, label: 'すすむ', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: 1, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 1, label: 'ぜんりょくとうきゅう', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 33 } ] },
    effects: {},
    next_derivation_number: 2, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 1, label: 'ぜんりょくとうきゅう', priority: 2,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 50 } ] },
    effects: {},
    next_derivation_number: 3, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 1, label: 'ぜんりょくとうきゅう', priority: 3,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: 4, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 2, label: 'ひだりだ！', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 2, label: 'そこだ！', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 50 } ] },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 2, label: 'そこだ！', priority: 2,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 2, label: 'みぎだ！', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'ひだりだ！', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 30 } ] },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'ひだりだ！', priority: 2,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'そこだ！', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'みぎだ！', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 30 } ] },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'みぎだ！', priority: 2,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 4, label: 'ひだりだ！', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 4, label: 'そこだ！', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 50 } ] },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 4, label: 'そこだ！', priority: 2,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 4, label: 'みぎだ！', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 0, label: 'さんすう', priority: 1,
    trigger_conditions:    { "operator": "and", "conditions": [ { "type": "status", "attribute": "arithmetic", "operator": ">=", "value": 0 } ] },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: '算数', resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 0, label: 'さんすう', priority: 2,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 0, label: 'ボールあそび', priority: 1,
    trigger_conditions:    { "operator": "and", "conditions": [ { "type": "status", "attribute": "sports_value", "operator": ">=", "value": 0 } ] },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: 'ボール遊び', resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 0, label: 'ボールあそび', priority: 2,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 1, label: 'すすむ', priority: 1,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 2, label: 'すすむ', priority: 1,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 3, label: 'すすむ', priority: 1,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 4, label: 'すすむ', priority: 1,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 5, label: 'すすむ', priority: 1,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '特訓', derivation_number: 6, label: 'すすむ', priority: 1,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
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
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 1, position: 1, message: '〈たまご〉がうれしそうにはなしている！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 1, position: 2, message: '〈たまご〉「んに～！！」', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 2, position: 1, message: 'なになに？うんうん。', character_image: 'character/kari-komattakao.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 2, position: 2, message: '〈たまご〉はとっくんがしたいといっている！', character_image: 'character/kari-yaruki.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'ごはんをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },

  { event_set_name: '何か言っている', derivation_number: 0, label: 'おやつをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ。', character_image: 'character/kari-normal.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'ごはんをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ。', character_image: 'character/kari-normal.png', background_image: 'background/kari-background.png' },

  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'ボールあそびをする', priority: 1, position: 1, message: 'よし！ボールあそびをしよう！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  #  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'べんきょうする',     priority: 1, position: 1, message: 'よし、べんきょうをしよう！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'おえかきする',       priority: 1, position: 1, message: 'おえかきをした！じょうずにかけたね！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'ゲームする',         priority: 1, position: 1, message: 'いっしょにあそんであげた！ゲームはたのしいね！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },

  #  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'さんすう',     priority: 1, position: 1, message: 'さんすうのべんきょうをした！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },

  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 1, position: 1, message: 'こくごのべんきょうをしよう！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 1, position: 2, message: '・・・。',                   character_image: 'character/kari-study.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 1, position: 3, message: '〈たまご〉はシェイクスピアのさくひんをよんだ！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 2, position: 1, message: 'こくごのべんきょうをしよう！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 2, position: 2, message: '・・・。',                   character_image: 'character/kari-study.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 2, position: 3, message: '〈たまご〉は「はしれメロス」をよんだ！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 3, position: 1, message: 'こくごのべんきょうをしよう！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 3, position: 2, message: '・・・。',                   character_image: 'character/kari-study.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 3, position: 3, message: '『どんぶらこー、どんぶらこー』', character_image: 'character/kari-study.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 3, position: 4, message: '〈たまご〉はももたろうをよんだ！', character_image: 'character/kari-study.png', background_image: 'background/kari-background.png' },

  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 1, position: 1, message: 'りかのべんきょうをしよう！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 1, position: 2, message: '・・・。',                   character_image: 'character/kari-rika.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 1, position: 3, message: '〈たまご〉はふろうふしになれるクスリをつくった！', character_image: 'character/kari-rika2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 2, position: 1, message: 'りかのべんきょうをしよう！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 2, position: 2, message: '・・・。',                   character_image: 'character/kari-rika.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 2, position: 3, message: '！！！',                     character_image: 'character/kari-rika3.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 2, position: 4, message: '・・・。',                   character_image: 'character/kari-rika4.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 3, position: 1, message: 'りかのべんきょうをしよう！', character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 3, position: 2, message: '・・・。',                   character_image: 'character/kari-rika.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 3, position: 3, message: 'じっけんはしっぱいした！', character_image: 'character/kari-rika.png', background_image: 'background/kari-background.png' },

  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 1, position: 1, message: 'しゃかいのべんきょうをしよう！',                           character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 1, position: 2, message: '・・・。',                                               character_image: 'character/kari-study.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 1, position: 3, message: 'すっごいゆうめいなブショウがタイムスリップしてきた！すご！！', character_image: 'character/kari-busyou3.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 2, position: 1, message: 'しゃかいのべんきょうをしよう！',                           character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 2, position: 2, message: '・・・。',                                               character_image: 'character/kari-study.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 2, position: 3, message: 'なまえをきいたことあるようなないようなブショウがタイムスリップしてきた！', character_image: 'character/kari-busyou2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 2, position: 4, message: 'こんにちは！',                                           character_image: 'character/kari-busyou2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 3, position: 1, message: 'しゃかいのべんきょうをしよう！',                           character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 3, position: 2, message: '・・・。',                                               character_image: 'character/kari-study.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 3, position: 3, message: 'むめいのブショウがタイムスリップしてきた！',                 character_image: 'character/kari-busyou1.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 3, position: 4, message: 'はやくかえって！',                                         character_image: 'character/kari-busyou1.png', background_image: 'background/kari-background.png' },

  { event_set_name: '踊っている',     derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'ごはんをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },

  { event_set_name: '踊っている',     derivation_number: 0, label: 'よしよしする',       priority: 2, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'おやつをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ。', character_image: 'character/kari-normal.png', background_image: 'background/kari-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'ごはんをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ。', character_image: 'character/kari-normal.png', background_image: 'background/kari-background.png' },

  { event_set_name: '泣いている(空腹)', derivation_number: 0, label: 'よしよしする',     priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'character/kari-naku.png', background_image: 'background/kari-background.png' },
  { event_set_name: '泣いている(空腹)', derivation_number: 0, label: 'おやつをあげる',   priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '泣いている(空腹)', derivation_number: 0, label: 'ごはんをあげる',   priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '泣いている(空腹)', derivation_number: 0, label: 'あそんであげる',   priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'character/kari-naku.png', background_image: 'background/kari-background.png' },

  { event_set_name: '泣いている(よしよし不足)', derivation_number: 0, label: 'よしよしする',   priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '泣いている(よしよし不足)', derivation_number: 0, label: 'おやつをあげる', priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'character/kari-naku.png', background_image: 'background/kari-background.png' },
  { event_set_name: '泣いている(よしよし不足)', derivation_number: 0, label: 'ごはんをあげる', priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'character/kari-naku.png', background_image: 'background/kari-background.png' },
  { event_set_name: '泣いている(よしよし不足)', derivation_number: 0, label: 'あそんであげる', priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'character/kari-naku.png', background_image: 'background/kari-background.png' },

  { event_set_name: '泣いている(ランダム)', derivation_number: 0, label: 'よしよしする',     priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'character/kari-naku.png', background_image: 'background/kari-background.png' },
  { event_set_name: '泣いている(ランダム)', derivation_number: 0, label: 'おやつをあげる',   priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'character/kari-naku.png', background_image: 'background/kari-background.png' },
  { event_set_name: '泣いている(ランダム)', derivation_number: 0, label: 'ごはんをあげる',   priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'character/kari-naku.png', background_image: 'background/kari-background.png' },
  { event_set_name: '泣いている(ランダム)', derivation_number: 0, label: 'あそんであげる',   priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },

  { event_set_name: '寝ている',           derivation_number: 0, label: 'そっとする',       priority: 1, position: 1, message: 'きもちよさそうにねている。', character_image: 'character/kari-sleep.png', background_image: 'background/kari-background.png' },
  { event_set_name: '寝ている',           derivation_number: 0, label: 'よしよしする',     priority: 1, position: 1, message: '〈たまご〉がちょっともぞもぞした。', character_image: 'character/kari-sleep.png', background_image: 'background/kari-background.png' },
  { event_set_name: '寝ている',           derivation_number: 0, label: 'たたきおこす',     priority: 1, position: 1, message: 'それはひとでなしのすることだ！！', character_image: 'character/kari-sleep.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'そっとする',      priority: 1, position: 1, message: '〈たまご〉はたのしそうにあそんでいる！',                character_image: 'character/kari-building_blocks.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'よしよしする',    priority: 1, position: 1, message: '〈たまご〉はうれしそう！',                             character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'ちょっかいをだす', priority: 1, position: 1, message: '〈たまご〉がおこってしまった！',                       character_image: 'character/kari-okoru.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'ブロックをくずす', priority: 1, position: 1, message: 'あー！ほんとにブロックをくずしちゃった！これはひどい！', character_image: 'character/kari-okoru.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'ちょっかいをだす', priority: 2, position: 1, message: '〈たまご〉はちょっといやそう。', character_image: 'character/kari-hukigen.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'ブロックをくずす', priority: 2, position: 1, message: '〈たまご〉にそしされた。',       character_image: 'character/kari-building_blocks.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'そっとする',        priority: 1, position: 1, message: '〈たまご〉はマンガがおもしろいようだ。',                     character_image: 'character/kari-comics.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'よしよしする',      priority: 1, position: 1, message: '〈たまご〉はうれしそう！',                                  character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'はなしかける',      priority: 1, position: 1, message: '〈たまご〉はマンガにしゅうちゅうしたいみたい。ごめんごめん。', character_image: 'character/kari-hukigen.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'マンガをとりあげる', priority: 1, position: 1, message: '〈たまご〉がおこってしまった！',                            character_image: 'character/kari-okoru.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'はなしかける',      priority: 2, position: 1, message: '〈たまご〉はニコニコしている。',                            character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },

  { event_set_name: '眠そう', derivation_number: 0, label: 'ねかせる',          priority: 1, position: 1, message: 'きょうはもうねようね！〈たまご〉おやすみ！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ねかせる',          priority: 2, position: 1, message: 'まだもうちょっとおきてたいみたい。',        character_image: 'character/kari-sleepy.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はうれしそうだ！',               character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 2, message: '〈たまご〉はおふとんにはいってねた！',      character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'よしよしする',       priority: 2, position: 1, message: '〈たまご〉はよろこんでいる！',             character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'はみがきをさせる',   priority: 1, position: 1, message: 'よし、よくみがこうね！',                   character_image: 'character/kari-hamigaki.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'はみがきをさせる',   priority: 1, position: 2, message: '〈たまご〉はちゃんとはみがきした！',        character_image: 'character/kari-hamigaki.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'はみがきをさせる',   priority: 2, position: 1, message: 'はみがきしたくないみたい。まったくー！',     character_image: 'character/kari-sleepy.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 1, position: 1, message: 'チーターががけから・・・',                 character_image: 'character/kari-sleepy.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 1, position: 2, message: 'おっこちーたー！！',                       character_image: 'character/kari-sleepy.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 1, position: 3, message: '〈たまご〉はおおわらいした！',             character_image: 'character/kari-warau.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 2, position: 1, message: 'アルミかんのうえに・・・',                 character_image: 'character/kari-sleepy.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 2, position: 2, message: 'あるミカン！！',                          character_image: 'character/kari-sleepy.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 2, position: 3, message: '〈たまご〉がちょっとひいてる・・・。',      character_image: 'character/kari-donbiki.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 3, position: 1, message: 'ふとんが・・・',                          character_image: 'character/kari-sleepy.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 3, position: 2, message: 'ふっとんだ！！',                          character_image: 'character/kari-sleepy.png', background_image: 'background/kari-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 3, position: 3, message: 'わらわない・・・。',                       character_image: 'character/kari-sleepy.png', background_image: 'background/kari-background.png' },

  { event_set_name: '寝かせた', derivation_number: 0, label: 'そっとする',       priority: 1, position: 1, message: 'きもちよさそうにねているなあ。', character_image: 'character/kari-sleep.png', background_image: 'background/kari-background.png' },
  { event_set_name: '寝かせた', derivation_number: 0, label: 'よしよしする',     priority: 1, position: 1, message: 'りっぱにそだちますように。', character_image: 'character/kari-sleep.png', background_image: 'background/kari-background.png' },
  { event_set_name: '寝かせた', derivation_number: 0, label: 'たたきおこす',     priority: 1, position: 1, message: 'できるわけないだろ！！', character_image: 'character/kari-sleep.png', background_image: 'background/kari-background.png' },

  { event_set_name: '怒っている', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！',     character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 2, message: '〈たまご〉はゆるしてくれた！',     character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'よしよしする',       priority: 2, position: 1, message: '〈たまご〉はゆるしてくれない！！', character_image: 'character/kari-okoru.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！',     character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 2, message: '〈たまご〉はゆるしてくれた！',     character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'おやつをあげる',     priority: 2, position: 1, message: 'おやつじゃゆるしてくれない！',     character_image: 'character/kari-okoru.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 1, position: 1, message: 'こんしんのへんがお！',             character_image: 'character/kari-hengao.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 1, position: 2, message: '〈たまご〉「キャッキャッ！」',      character_image: 'character/kari-warau.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 1, position: 3, message: '大ウケした！',                    character_image: 'character/kari-warau.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 2, position: 1, message: 'こんしんのへんがお！',             character_image: 'character/kari-hengao.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 2, position: 2, message: '〈たまご〉「・・・。」',             character_image: 'character/kari-donbiki.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 2, position: 3, message: 'すべった。',                      character_image: 'character/kari-donbiki.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'あやまる',           priority: 1, position: 1, message: 'ごめんよ・・・。',                character_image: 'character/kari-gomen.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'あやまる',           priority: 1, position: 2, message: '〈たまご〉はゆるしてくれた！',     character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'あやまる',           priority: 2, position: 1, message: 'ごめんよ・・・。',                character_image: 'character/kari-gomen.png', background_image: 'background/kari-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'あやまる',           priority: 2, position: 2, message: '〈たまご〉はまだおこっている！',    character_image: 'character/kari-okoru.png', background_image: 'background/kari-background.png' },

  { event_set_name: '算数',      derivation_number: 1,  label: '〈A〉',                priority: 1, position: 1, message: 'おー！せいかい！いいちょうしだね！',     character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 1,  label: '〈B〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 1,  label: '〈C〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 1,  label: '〈D〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },

  { event_set_name: '算数',      derivation_number: 2,  label: '〈A〉',                priority: 1, position: 1, message: 'おー！せいかい！いいちょうしだね！',     character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 2,  label: '〈B〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 2,  label: '〈C〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 2,  label: '〈D〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },

  { event_set_name: '算数',      derivation_number: 3,  label: '〈A〉',                priority: 1, position: 1, message: 'おー！せいかい！いいちょうしだね！',     character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 3,  label: '〈B〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 3,  label: '〈C〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 3,  label: '〈D〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },

  { event_set_name: '算数',      derivation_number: 4,  label: '〈A〉',                priority: 1, position: 1, message: 'おー！せいかい！いいちょうしだね！',     character_image: 'character/kari-nikoniko2.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 4,  label: '〈B〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 4,  label: '〈C〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },
  { event_set_name: '算数',      derivation_number: 4,  label: '〈D〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'character/kari-ochikomu.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'ひだりだ！',   priority: 1, position: 1, message: 'おー！きれいにキャッチ！',     character_image: 'character/kari-ball4.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'そこだ！',     priority: 1, position: 1, message: 'なんとかキャッチ！',           character_image: 'character/kari-ball4.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'そこだ！',     priority: 2, position: 1, message: 'あちゃー！',                  character_image: 'character/kari-ball7.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'みぎだ！',     priority: 1, position: 1, message: 'あちゃー！',                  character_image: 'character/kari-ball10.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'ひだりだ！',   priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'そこだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'そこだ！',     priority: 2, position: 2, message: 'しょぼん。',                  character_image: 'character/kari-gakkari.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'みぎだ！',     priority: 1, position: 2, message: 'しょぼん。',                  character_image: 'character/kari-gakkari.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'ひだりだ！',   priority: 1, position: 1, message: 'なんとかキャッチ！',           character_image: 'character/kari-ball8.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'ひだりだ！',   priority: 2, position: 1, message: 'あちゃー！',                  character_image: 'character/kari-ball5.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'そこだ！',     priority: 1, position: 1, message: 'おー！きれいにキャッチ！',     character_image: 'character/kari-ball8.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'みぎだ！',     priority: 1, position: 1, message: 'なんとかキャッチ！',           character_image: 'character/kari-ball8.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'みぎだ！',     priority: 2, position: 1, message: 'あちゃー！',                  character_image: 'character/kari-ball11.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'ひだりだ！',   priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'ひだりだ！',   priority: 2, position: 2, message: 'しょぼん。',                  character_image: 'character/kari-gakkari.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'そこだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'みぎだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'みぎだ！',     priority: 2, position: 2, message: 'しょぼん。',                  character_image: 'character/kari-gakkari.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'ひだりだ！',   priority: 1, position: 1, message: 'あちゃー！',                  character_image: 'character/kari-ball6.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'そこだ！',     priority: 1, position: 1, message: 'なんとかキャッチ！',           character_image: 'character/kari-ball12.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'そこだ！',     priority: 2, position: 1, message: 'あちゃー！',                  character_image: 'character/kari-ball9.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'みぎだ！',     priority: 1, position: 1, message: 'おー！きれいにキャッチ！',     character_image: 'character/kari-ball12.png', background_image: 'background/kari-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'ひだりだ！',   priority: 1, position: 2, message: 'しょぼん。',                  character_image: 'character/kari-gakkari.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'そこだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'そこだ！',     priority: 2, position: 2, message: 'しょぼん。',                  character_image: 'character/kari-gakkari.png', background_image: 'background/kari-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'みぎだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },

  { event_set_name: '特訓',      derivation_number: 0,  label: 'さんすう',              priority: 1, position: 1, message: 'とっくんはれんぞく20もんになるぞ！', character_image: 'character/kari-bikkuri.png', background_image: 'background/kari-background.png' },
  { event_set_name: '特訓',      derivation_number: 0,  label: 'さんすう',              priority: 2, position: 1, message: 'このとっくんは〈たまご〉にはまだはやい！', character_image: 'character/kari-gakkari.png', background_image: 'background/kari-background.png' },
  { event_set_name: '特訓',      derivation_number: 0,  label: 'ボールあそび',          priority: 1, position: 1, message: 'とっくんは3かいしっぱいするまでつづくぞ！', character_image: 'character/kari-bikkuri.png', background_image: 'background/kari-background.png' },
  { event_set_name: '特訓',      derivation_number: 0,  label: 'ボールあそび',          priority: 2, position: 1, message: 'このとっくんは〈たまご〉にはまだはやい！', character_image: 'character/kari-gakkari.png', background_image: 'background/kari-background.png' },
  { event_set_name: '特訓',      derivation_number: 1,  label: 'すすむ',                priority: 1, position: 1, message: 'けっかは・・・。',                    character_image: 'character/kari-tukareta.png', background_image: 'background/kari-background.png' }
]

cuts.each do |attrs|
  set    = EventSet.find_by!(name: attrs[:event_set_name])
  event  = Event.find_by!(event_set: set, derivation_number: attrs[:derivation_number])
  choice = ActionChoice.find_by!(event: event, label: attrs[:label])
  result = ActionResult.find_by!(action_choice: choice, priority: attrs[:priority])

  cut = Cut.find_or_initialize_by(action_result: result, position: attrs[:position])
  cut.message          = attrs[:message]
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
    first_set   = EventSet.find_by!(name: '何か言っている')
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
