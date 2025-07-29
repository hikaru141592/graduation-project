categories = [
  { name: '通常',     description: '何か言っている、何かしたそう',                         loop_minutes: nil  },
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
          "value":     5
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
    daily_limit: 1,
    trigger_conditions: {
      "operator":   "and",
      "conditions": [
        {
          "type":    "probability",
          "percent": 100
        }, {
          "type":      "time_range",
          "from_hour": 11,
          "from_min":  0,
          "to_hour":   14,
          "to_min":    0,
          "offsets_by_day": [
            {
              "add":        11,
              "mult":       77,
              "mod":        300,
              "target":     "from_min"
            },
            {
              "add":        11,
              "mult":       77,
              "mod":        300,
              "target":     "to_min"
            }
          ]
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
          "percent": 6
        }, {
          "type":      "time_range",
          "from_hour": 10,
          "from_min":  0,
          "to_hour":   23,
          "to_min":    30,
          "offsets_by_day": [
            {
              "add":        4,
              "mult":       7,
              "mod":        30,
              "target":     "from_min"
            }
          ]
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
    name: '寝起き',
    daily_limit: 1,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 6,
          "from_min":  38,
          "to_hour":   7,
          "to_min":    38,
          "offsets_by_day": [
            {
              "add":        27,
              "mult":       19,
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
    name: '占い',
    daily_limit: 1,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 6,
          "from_min":  0,
          "to_hour":   11,
          "to_min":    0
        },
        {
          "type":    "probability",
          "percent": 33
        }
      ]
    }
  },
  {
    name: 'タマモン',
    daily_limit: 1,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 19,
          "from_min":  0,
          "to_hour":   20,
          "to_min":    0
        },
        {
          "type": "weekday",
          "value": [ 1 ]
        }
      ]
    }
  },
  {
    name: 'タマえもん',
    daily_limit: 1,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 19,
          "from_min":  0,
          "to_hour":   20,
          "to_min":    0
        },
        {
          "type": "weekday",
          "value": [ 5 ]
        }
      ]
    }
  },
  {
    name: 'ニワトリビアの湖',
    daily_limit: 1,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 20,
          "from_min":  0,
          "to_hour":   21,
          "to_min":    0
        },
        {
          "type": "weekday",
          "value": [ 3 ]
        }
      ]
    }
  },
  {
    name: '扇風機',
    daily_limit: 2,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 11,
          "from_min":  0,
          "to_hour":   17,
          "to_min":    0,
          "offsets_by_day": [
            {
              "add":        27,
              "mult":       4,
              "mod":        15,
              "target":     "to_min"
            },
            {
              "add":        27,
              "mult":       4,
              "mod":        15,
              "target":     "from_min"
            }
          ]
        },
        {
          "type": "date_range",
          "from": { "month": 7, "day": 1 },
          "to":   { "month": 9, "day": 15 }
        },
        {
          "type":    "probability",
          "percent": 25
        }
      ]
    }
  },
  {
    name: 'こたつ',
    daily_limit: 2,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 11,
          "from_min":  0,
          "to_hour":   21,
          "to_min":    30,
          "offsets_by_day": [
            {
              "add":        27,
              "mult":       4,
              "mod":        15,
              "target":     "to_min"
            },
            {
              "add":        27,
              "mult":       4,
              "mod":        15,
              "target":     "from_min"
            }
          ]
        },
        {
          "type": "date_range",
          "from": { "month": 12, "day": 16 },
          "to":   { "month": 3, "day": 15 }
        },
        {
          "type":    "probability",
          "percent": 25
        }
      ]
    }
  },
  {
    name: '花見',
    daily_limit: 1,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 10,
          "from_min":  30,
          "to_hour":   16,
          "to_min":    30,
          "offsets_by_day": [
            {
              "add":        27,
              "mult":       51,
              "mod":        120,
              "target":     "to_min"
            },
            {
              "add":        27,
              "mult":       6,
              "mod":        15,
              "target":     "from_min"
            }
          ]
        },
        {
          "type": "date_range",
          "from": { "month": 3, "day": 16 },
          "to":   { "month": 4, "day": 15 }
        },
        {
          "type":    "probability",
          "percent": 30
        }
      ]
    }
  },
  {
    name: '紅葉',
    daily_limit: 1,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type":      "time_range",
          "from_hour": 10,
          "from_min":  30,
          "to_hour":   16,
          "to_min":    30,
          "offsets_by_day": [
            {
              "add":        27,
              "mult":       51,
              "mod":        120,
              "target":     "to_min"
            },
            {
              "add":        27,
              "mult":       6,
              "mod":        15,
              "target":     "from_min"
            }
          ]
        },
        {
          "type": "date_range",
          "from": { "month": 11, "day": 1 },
          "to":   { "month": 12, "day": 15 }
        },
        {
          "type":    "probability",
          "percent": 25
        }
      ]
    }
  },
  {
    name: '年始',
    daily_limit: 1,
    trigger_conditions: {
      "operator": "and",
      "conditions": [
        {
          "type": "date_range",
          "from": { "month": 7, "day": 15 },
          "to":   { "month": 7, "day": 15 }
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
  set.update!(trigger_conditions: attrs[:trigger_conditions], daily_limit: attrs[:daily_limit])
end

events = [
  {
    event_set_name:    '何か言っている',
    name:              '何か言っている',
    derivation_number: 0,
    message:           '〈たまご〉がなにかいっているよ。',
    character_image:   'temp-character/temp-normal.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '何かしたそう',
    name:              'べんきょうする',
    derivation_number: 1,
    message:           'よし！なんのべんきょうをしよう？',
    character_image:   'temp-character/temp-nikoniko2.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '何かしたそう',
    name:              '何かしたそう',
    derivation_number: 0,
    message:           '〈たまご〉はなにかしたそうだ。',
    character_image:   'temp-character/temp-normal.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '踊っている',
    name:              '踊っている',
    derivation_number: 0,
    message:           '〈たまご〉はおどっている！',
    character_image:   'temp-character/temp-dance.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '泣いている(空腹)',
    name:              '泣いている(空腹)',
    derivation_number: 0,
    message:           '〈たまご〉がないている！',
    character_image:   'temp-character/temp-naku.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '泣いている(よしよし不足)',
    name:              '泣いている(よしよし不足)',
    derivation_number: 0,
    message:           '〈たまご〉がないている！',
    character_image:   'temp-character/temp-naku.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '泣いている(ランダム)',
    name:              '泣いている(ランダム)',
    derivation_number: 0,
    message:           '〈たまご〉がないている！',
    character_image:   'temp-character/temp-naku.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '怒っている',
    name:              '怒っている',
    derivation_number: 0,
    message:           '〈たまご〉はおこっている！',
    character_image:   'temp-character/temp-okoru.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '寝ている',
    name:              '寝ている',
    derivation_number: 0,
    message:           '〈たまご〉はねている。',
    character_image:   'temp-character/temp-sleep.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'ブロックのおもちゃに夢中',
    name:              'ブロックのおもちゃに夢中',
    derivation_number: 0,
    message:           '〈たまご〉はブロックのおもちゃにむちゅうだ。',
    character_image:   'temp-character/temp-building_blocks.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'マンガに夢中',
    name:              'マンガに夢中',
    derivation_number: 0,
    message:           '〈たまご〉はマンガをよんでいる。',
    character_image:   'temp-character/temp-comics.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '眠そう',
    name:              '眠そう',
    derivation_number: 0,
    message:           '〈たまご〉はねむそうにしている。',
    character_image:   'temp-character/temp-sleepy.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '寝かせた',
    name:              '寝かせた',
    derivation_number: 0,
    message:           '〈たまご〉はねている。',
    character_image:   'temp-character/temp-sleep.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '寝起き',
    name:              '寝起き',
    derivation_number: 0,
    message:           '〈たまご〉がおきたようだ！',
    character_image:   'temp-character/temp-wakeup.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '寝起き',
    name:              '起こす、1回目の警告',
    derivation_number: 1,
    message:           'おきにいりのハードロックミュージックでもかけっちゃおっかなー？',
    character_image:   'temp-character/temp-wakeup.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '寝起き',
    name:              '起こす、2回目の警告',
    derivation_number: 2,
    message:           'ほんとにかけるの？',
    character_image:   'temp-character/temp-wakeup.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '寝起き',
    name:              '起こす、3回目の警告',
    derivation_number: 3,
    message:           'ほんとにいいんですね？',
    character_image:   'temp-character/temp-wakeup.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '占い',
    name:              '占い',
    derivation_number: 0,
    message:           'テレビでうらないをやってる！',
    character_image:   'temp-character/temp-TV1.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'タマモン',
    name:              'タマモンがやっている',
    derivation_number: 0,
    message:           '〈たまご〉はタマモンがみたいらしい。どうする？',
    character_image:   'temp-character/temp-TV3.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'タマモン',
    name:              'タマモンを見ている',
    derivation_number: 1,
    message:           '〈たまご〉はタマモンをみている！',
    character_image:   'temp-character/temp-TV6.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'タマえもん',
    name:              'タマえもんがやっている',
    derivation_number: 0,
    message:           '〈たまご〉はタマえもんがみたいらしい。どうする？',
    character_image:   'temp-character/temp-TV3.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'タマえもん',
    name:              'タマえもんを見ている',
    derivation_number: 1,
    message:           '〈たまご〉はタマえもんをみている！',
    character_image:   'temp-character/temp-TV6.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'ニワトリビアの湖',
    name:              'ニワトリビアの湖がやっている',
    derivation_number: 0,
    message:           '〈たまご〉はニワトリビアのみずうみがみたいらしい。どうする？',
    character_image:   'temp-character/temp-TV3.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'ニワトリビアの湖',
    name:              'ニワトリビアの湖を見ている',
    derivation_number: 1,
    message:           '〈たまご〉はニワトリビアのみずうみをみている！',
    character_image:   'temp-character/temp-TV6.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '扇風機',
    name:              '扇風機',
    derivation_number: 0,
    message:           '〈たまご〉はすずんでいる！',
    character_image:   'temp-character/temp-senpuuki1.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'こたつ',
    name:              'こたつ',
    derivation_number: 0,
    message:           '〈たまご〉はこたつでヌクヌクしている！',
    character_image:   'temp-character/temp-kotatu1.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '花見',
    name:              '花見',
    derivation_number: 0,
    message:           '〈たまご〉はおはなみにいきたいみたい。',
    character_image:   'temp-character/temp-normal.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '紅葉',
    name:              '紅葉',
    derivation_number: 0,
    message:           '〈たまご〉はコウヨウをみにいきたいみたい。',
    character_image:   'temp-character/temp-normal.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '年始',
    name:              '年始',
    derivation_number: 0,
    message:           '〈たまご〉「にー！！」',
    character_image:   'temp-character/temp-nikoniko2.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '出題前',
    derivation_number: 0,
    message:           'よし、さんすうのもんだいにちょうせんだ！',
    character_image:   'temp-character/temp-nikoniko2.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '1つ目が正解',
    derivation_number: 1,
    message:           '「X 演算子 Y」のこたえは？',
    character_image:   'temp-character/temp-kangaeru.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '2つ目が正解',
    derivation_number: 2,
    message:           '「X 演算子 Y」のこたえは？',
    character_image:   'temp-character/temp-kangaeru.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '3つ目が正解',
    derivation_number: 3,
    message:           '「X 演算子 Y」のこたえは？',
    character_image:   'temp-character/temp-kangaeru.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '算数',
    name:              '4つ目が正解',
    derivation_number: 4,
    message:           '「X 演算子 Y」のこたえは？',
    character_image:   'temp-character/temp-kangaeru.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '投球前',
    derivation_number: 0,
    message:           'ボールなげるよー！',
    character_image:   'temp-character/temp-ball1.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '投球',
    derivation_number: 1,
    message:           'ブンッ！',
    character_image:   'temp-character/temp-ball2.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '左が成功',
    derivation_number: 2,
    message:           'ボールをなげた！〈たまご〉、そっちだ！',
    character_image:   'temp-character/temp-ball3.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '真ん中が成功',
    derivation_number: 3,
    message:           '〈たまご〉、そっちだ！',
    character_image:   'temp-character/temp-ball3.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    'ボール遊び',
    name:              '右が成功',
    derivation_number: 4,
    message:           '〈たまご〉、そっちだ！',
    character_image:   'temp-character/temp-ball3.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓',
    derivation_number: 0,
    message:           'なんのとっくんをしよう？',
    character_image:   'temp-character/temp-kangaeru.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓終了',
    derivation_number: 1,
    message:           'ここまで！',
    character_image:   'temp-character/temp-tukareta.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓結果優秀',
    derivation_number: 2,
    message:           '20もんちゅう〈X〉もんせいかい！〈Y〉分〈Z〉秒クリア！すごいね！',
    character_image:   'temp-character/temp-nikoniko.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓結果良し',
    derivation_number: 3,
    message:           '20もんちゅう〈X〉もんせいかい！よくがんばったね！',
    character_image:   'temp-character/temp-nikoniko2.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              '特訓結果微妙',
    derivation_number: 4,
    message:           '20もんちゅう〈X〉もんせいかい！またちょうせんしよう！',
    character_image:   'temp-character/temp-bimuyou.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              'ボール遊び特訓結果良し',
    derivation_number: 5,
    message:           '〈X〉かいせいこう！よくがんばったね！',
    character_image:   'temp-character/temp-nikoniko2.png',
    background_image:  'temp-background/temp-background.png'
  },
  {
    event_set_name:    '特訓',
    name:              'ボール遊び特訓結果微妙',
    derivation_number: 6,
    message:           '〈X〉かいせいこう！またちょうせんしよう！',
    character_image:   'temp-character/temp-bimuyou.png',
    background_image:  'temp-background/temp-background.png'
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
    event_set_name:    '寝起き',
    derivation_number: 0,
    labels:            [ 'そっとする',        'よしよしする',     'きがえさせる',     'ばくおんをながす' ]
  },
  {
    event_set_name:    '寝起き',
    derivation_number: 1,
    labels:            [ 'かけちゃう',        'やめておく' ]
  },
  {
    event_set_name:    '寝起き',
    derivation_number: 2,
    labels:            [ 'はい',              'やっぱやめておく' ]
  },
  {
    event_set_name:    '寝起き',
    derivation_number: 3,
    labels:            [ 'はい',              'いいえ' ]
  },
  {
    event_set_name:    '占い',
    derivation_number: 0,
    labels:            [ 'すすむ' ]
  },
  {
    event_set_name:    'タマモン',
    derivation_number: 0,
    labels:            [ 'みていいよ',         'みさせてあげない' ]
  },
  {
    event_set_name:    'タマモン',
    derivation_number: 1,
    labels:            [ 'いっしょにみる' ]
  },
  {
    event_set_name:    'タマえもん',
    derivation_number: 0,
    labels:            [ 'みていいよ',         'みさせてあげない' ]
  },
  {
    event_set_name:    'タマえもん',
    derivation_number: 1,
    labels:            [ 'いっしょにみる' ]
  },
  {
    event_set_name:    'ニワトリビアの湖',
    derivation_number: 0,
    labels:            [ 'みていいよ',         'みさせてあげない' ]
  },
  {
    event_set_name:    'ニワトリビアの湖',
    derivation_number: 1,
    labels:            [ 'いっしょにみる' ]
  },
  {
    event_set_name:    '扇風機',
    derivation_number: 0,
    labels:            [ 'よしよしする',       'スイカをあげる',   'せんぷうきをとめる',   'そっとする' ]
  },
  {
    event_set_name:    'こたつ',
    derivation_number: 0,
    labels:            [ 'よしよしする',       'ミカンをあげる',    'こたつをとめる',      'そっとする' ]
  },
  {
    event_set_name:    '花見',
    derivation_number: 0,
    labels:            [ 'つれていく',       'いかない' ]
  },
  {
    event_set_name:    '紅葉',
    derivation_number: 0,
    labels:            [ 'つれていく',       'いかない' ]
  },
  {
    event_set_name:    '年始',
    derivation_number: 0,
    labels:            [ 'すすむ' ]
  },
  {
    event_set_name:    '怒っている',
    derivation_number: 0,
    labels:            [ 'よしよしする',       'おやつをあげる',   'へんがおをする',   'あやまる' ]
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
                                                               { "type": "status", "attribute": "temp_vitality", "operator": "<", "value": 30 },
                                                               { "type": "probability", "percent": 80 } ] },
    effects:               { "status": [ { "attribute": "mood_value", "delta": 5 } ] },
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
                                         { "attribute": "mood_value", "delta": 5 } ] },
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
                                         { "attribute": "mood_value", "delta": 15 } ] },
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
    effects:               { "status": [ { "attribute": "hunger_value", "delta": 40 },
                                         { "attribute": "vitality", "delta": 1 } ] },
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
    trigger_conditions:    { "operator": "and", "conditions": [ { "type": "status", "attribute": "temp_vitality", "operator": ">=", "value": 30 } ] },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  'ボール遊び',
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     0,
    label:                 'ボールあそびをする',
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
    label:                 'べんきょうする',
    priority:              1,
    trigger_conditions:    { "operator": "and", "conditions": [ { "type": "status", "attribute": "temp_vitality", "operator": ">=", "value": 30 } ] },
    effects:               {},
    next_derivation_number: 1,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     0,
    label:                 'べんきょうする',
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
    label:                 'おえかきする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
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
    effects:               {},
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
    effects:               { "status": [ { "attribute": "japanese", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
    effects:               { "status": [ { "attribute": "japanese", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
    effects:               { "status": [ { "attribute": "japanese_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
    effects:               { "status": [ { "attribute": "science", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
    effects:               { "status": [ { "attribute": "science", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
    effects:               { "status": [ { "attribute": "science_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
    effects:               { "status": [ { "attribute": "social_studies", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
    effects:               { "status": [ { "attribute": "social_studies", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
    effects:               { "status": [ { "attribute": "social_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
                                         { "attribute": "vitality", "delta": 1 },
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
    effects:               { "status": [ { "attribute": "hunger_value", "delta": 50 },
                                         { "attribute": "vitality", "delta": 1 } ] },
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
    effects:               {},
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
    effects:               {},
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
    effects:               {},
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
    event_set_name:        '寝起き',
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
    event_set_name:        '寝起き',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 20 } ] },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         true
  },
  {
    event_set_name:        '寝起き',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝起き',
    derivation_number:     0,
    label:                 'きがえさせる',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝起き',
    derivation_number:     0,
    label:                 'ばくおんをながす',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: 1,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝起き',
    derivation_number:     1,
    label:                 'かけちゃう',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: 2,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝起き',
    derivation_number:     1,
    label:                 'やめておく',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: 0,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝起き',
    derivation_number:     2,
    label:                 'はい',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: 3,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝起き',
    derivation_number:     2,
    label:                 'やっぱやめておく',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: 0,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '寝起き',
    derivation_number:     3,
    label:                 'はい',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "happiness_value", "delta": -2 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  '怒っている',
    resolves_loop:         true
  },
  {
    event_set_name:        '寝起き',
    derivation_number:     3,
    label:                 'いいえ',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               {},
    next_derivation_number: 0,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name: '占い', derivation_number: 0, label: 'すすむ', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 10 } ] },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '占い', derivation_number: 0, label: 'すすむ', priority: 2,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 33 } ] },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '占い', derivation_number: 0, label: 'すすむ', priority: 3,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'タマモン', derivation_number: 0, label: 'みていいよ', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "happiness_value", "delta": 1 } ] },
    next_derivation_number: 1, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'タマモン', derivation_number: 0, label: 'みさせてあげない', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: true
  },
  {
    event_set_name: 'タマモン', derivation_number: 1, label: 'いっしょにみる', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'タマえもん', derivation_number: 0, label: 'みていいよ', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "happiness_value", "delta": 1 } ] },
    next_derivation_number: 1, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'タマえもん', derivation_number: 0, label: 'みさせてあげない', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: true
  },
  {
    event_set_name: 'タマえもん', derivation_number: 1, label: 'いっしょにみる', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ニワトリビアの湖', derivation_number: 0, label: 'みていいよ', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "happiness_value", "delta": 1 } ] },
    next_derivation_number: 1, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ニワトリビアの湖', derivation_number: 0, label: 'みさせてあげない', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: true
  },
  {
    event_set_name: 'ニワトリビアの湖', derivation_number: 1, label: 'いっしょにみる', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '扇風機', derivation_number: 0, label: 'よしよしする', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "love_value", "delta": 10 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '扇風機', derivation_number: 0, label: 'スイカをあげる', priority: 1,
    trigger_conditions:    { "operator": "and", "conditions": [ { "type": "status", "attribute": "hunger_value", "operator": "<=", "value": 90 } ] },
    effects: { "status": [ { "attribute": "hunger_value", "delta": 30 }, { "attribute": "vitality", "delta": 3 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '扇風機', derivation_number: 0, label: 'スイカをあげる', priority: 2,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '扇風機', derivation_number: 0, label: 'せんぷうきをとめる', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: true
  },
  {
    event_set_name: '扇風機', derivation_number: 0, label: 'そっとする', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'こたつ', derivation_number: 0, label: 'よしよしする', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "love_value", "delta": 10 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'こたつ', derivation_number: 0, label: 'ミカンをあげる', priority: 1,
    trigger_conditions:    { "operator": "and", "conditions": [ { "type": "status", "attribute": "hunger_value", "operator": "<=", "value": 90 } ] },
    effects: { "status": [ { "attribute": "hunger_value", "delta": 30 }, { "attribute": "vitality", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'こたつ', derivation_number: 0, label: 'ミカンをあげる', priority: 2,
    trigger_conditions:    { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'こたつ', derivation_number: 0, label: 'こたつをとめる', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: true
  },
  {
    event_set_name: 'こたつ', derivation_number: 0, label: 'そっとする', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '花見', derivation_number: 0, label: 'つれていく', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "happiness_value", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '花見', derivation_number: 0, label: 'いかない', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '紅葉', derivation_number: 0, label: 'つれていく', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "happiness_value", "delta": 1 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '紅葉', derivation_number: 0, label: 'いかない', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '年始', derivation_number: 0, label: 'すすむ', priority: 1,
    trigger_conditions: { always: true },
    effects: {},
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
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
    effects: { "status": [ { "attribute": "arithmetic", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 1, label: '〈B〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 1, label: '〈C〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 1, label: '〈D〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 2, label: '〈A〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 2, label: '〈B〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 2, label: '〈C〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 2, label: '〈D〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 3, label: '〈A〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 3, label: '〈B〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 3, label: '〈C〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 3, label: '〈D〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 4, label: '〈A〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 4, label: '〈B〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 4, label: '〈C〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: '算数', derivation_number: 4, label: '〈D〉', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "arithmetic_effort", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 2, label: 'そこだ！', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 50 } ] },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 2, label: 'そこだ！', priority: 2,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 2, label: 'みぎだ！', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'ひだりだ！', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 30 } ] },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'ひだりだ！', priority: 2,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'そこだ！', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'みぎだ！', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 30 } ] },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 3, label: 'みぎだ！', priority: 2,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 4, label: 'ひだりだ！', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 4, label: 'そこだ！', priority: 1,
    trigger_conditions: { "operator": "and", "conditions": [ { "type": "probability", "percent": 50 } ] },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 4, label: 'そこだ！', priority: 2,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "temp_vitality", "delta": -30 } ] },
    next_derivation_number: nil, calls_event_set_name: nil, resolves_loop: false
  },
  {
    event_set_name: 'ボール遊び', derivation_number: 4, label: 'みぎだ！', priority: 1,
    trigger_conditions: { always: true },
    effects: { "status": [ { "attribute": "sports_value", "delta": 1 }, { "attribute": "temp_vitality", "delta": -30 } ] },
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
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 1, position: 1, message: '〈たまご〉がうれしそうにはなしている！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 1, position: 2, message: '〈たまご〉「んに～！！」', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 2, position: 1, message: 'なになに？うんうん。', character_image: 'temp-character/temp-komattakao.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 2, position: 2, message: '〈たまご〉はとっくんがしたいといっている！', character_image: 'temp-character/temp-yaruki.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'ごはんをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '何か言っている', derivation_number: 0, label: 'おやつをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ。', character_image: 'temp-character/temp-normal.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'ごはんをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ。', character_image: 'temp-character/temp-normal.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'ボールあそびをする', priority: 1, position: 1, message: 'よし！ボールあそびをしよう！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'ボールあそびをする', priority: 2, position: 1, message: '〈たまご〉はつかれている！やすませてあげよう！', character_image: 'temp-character/temp-hukigen.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'べんきょうする',     priority: 2, position: 1, message: '〈たまご〉はつかれている！やすませてあげよう！', character_image: 'temp-character/temp-hukigen.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'おえかきする',       priority: 1, position: 1, message: 'おえかきをした！じょうずにかけたね！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'ゲームする',         priority: 1, position: 1, message: 'いっしょにあそんであげた！ゲームはたのしいね！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },

  #  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'さんすう',     priority: 1, position: 1, message: 'さんすうのべんきょうをした！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 1, position: 1, message: 'こくごのべんきょうをしよう！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 1, position: 2, message: '・・・。',                   character_image: 'temp-character/temp-study.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 1, position: 3, message: '〈たまご〉はシェイクスピアのさくひんをよんだ！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 2, position: 1, message: 'こくごのべんきょうをしよう！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 2, position: 2, message: '・・・。',                   character_image: 'temp-character/temp-study.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 2, position: 3, message: '〈たまご〉は「はしれメロス」をよんだ！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 3, position: 1, message: 'こくごのべんきょうをしよう！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 3, position: 2, message: '・・・。',                   character_image: 'temp-character/temp-study.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 3, position: 3, message: '『どんぶらこー、どんぶらこー』', character_image: 'temp-character/temp-study.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'こくご',       priority: 3, position: 4, message: '〈たまご〉はももたろうをよんだ！', character_image: 'temp-character/temp-study.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 1, position: 1, message: 'りかのべんきょうをしよう！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 1, position: 2, message: '・・・。',                   character_image: 'temp-character/temp-rika.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 1, position: 3, message: '〈たまご〉はふろうふしになれるクスリをつくった！', character_image: 'temp-character/temp-rika2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 2, position: 1, message: 'りかのべんきょうをしよう！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 2, position: 2, message: '・・・。',                   character_image: 'temp-character/temp-rika.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 2, position: 3, message: '！！！',                     character_image: 'temp-character/temp-rika3.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 2, position: 4, message: '・・・。',                   character_image: 'temp-character/temp-rika4.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 3, position: 1, message: 'りかのべんきょうをしよう！', character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 3, position: 2, message: '・・・。',                   character_image: 'temp-character/temp-rika.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'りか',       priority: 3, position: 3, message: 'じっけんはしっぱいした！', character_image: 'temp-character/temp-rika.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 1, position: 1, message: 'しゃかいのべんきょうをしよう！',                           character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 1, position: 2, message: '・・・。',                                               character_image: 'temp-character/temp-study.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 1, position: 3, message: 'すっごいゆうめいなブショウがタイムスリップしてきた！すご！！', character_image: 'temp-character/temp-busyou3.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 2, position: 1, message: 'しゃかいのべんきょうをしよう！',                           character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 2, position: 2, message: '・・・。',                                               character_image: 'temp-character/temp-study.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 2, position: 3, message: 'なまえをきいたことあるようなないようなブショウがタイムスリップしてきた！', character_image: 'temp-character/temp-busyou2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 2, position: 4, message: 'こんにちは！',                                           character_image: 'temp-character/temp-busyou2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 3, position: 1, message: 'しゃかいのべんきょうをしよう！',                           character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 3, position: 2, message: '・・・。',                                               character_image: 'temp-character/temp-study.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 3, position: 3, message: 'むめいのブショウがタイムスリップしてきた！',                 character_image: 'temp-character/temp-busyou1.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 1, label: 'しゃかい',       priority: 3, position: 4, message: 'はやくかえって！',                                         character_image: 'temp-character/temp-busyou1.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '踊っている',     derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'ごはんをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '踊っている',     derivation_number: 0, label: 'よしよしする',       priority: 2, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'おやつをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ。', character_image: 'temp-character/temp-normal.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'ごはんをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ。', character_image: 'temp-character/temp-normal.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '泣いている(空腹)', derivation_number: 0, label: 'よしよしする',     priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'temp-character/temp-naku.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '泣いている(空腹)', derivation_number: 0, label: 'おやつをあげる',   priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '泣いている(空腹)', derivation_number: 0, label: 'ごはんをあげる',   priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '泣いている(空腹)', derivation_number: 0, label: 'あそんであげる',   priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'temp-character/temp-naku.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '泣いている(よしよし不足)', derivation_number: 0, label: 'よしよしする',   priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '泣いている(よしよし不足)', derivation_number: 0, label: 'おやつをあげる', priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'temp-character/temp-naku.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '泣いている(よしよし不足)', derivation_number: 0, label: 'ごはんをあげる', priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'temp-character/temp-naku.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '泣いている(よしよし不足)', derivation_number: 0, label: 'あそんであげる', priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'temp-character/temp-naku.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '泣いている(ランダム)', derivation_number: 0, label: 'よしよしする',     priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'temp-character/temp-naku.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '泣いている(ランダム)', derivation_number: 0, label: 'おやつをあげる',   priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'temp-character/temp-naku.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '泣いている(ランダム)', derivation_number: 0, label: 'ごはんをあげる',   priority: 1, position: 1, message: 'そうじゃないらしい！', character_image: 'temp-character/temp-naku.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '泣いている(ランダム)', derivation_number: 0, label: 'あそんであげる',   priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '寝ている',           derivation_number: 0, label: 'そっとする',       priority: 1, position: 1, message: 'きもちよさそうにねている。', character_image: 'temp-character/temp-sleep.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '寝ている',           derivation_number: 0, label: 'よしよしする',     priority: 1, position: 1, message: '〈たまご〉がちょっともぞもぞした。', character_image: 'temp-character/temp-sleep.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '寝ている',           derivation_number: 0, label: 'たたきおこす',     priority: 1, position: 1, message: 'それはひとでなしのすることだ！！', character_image: 'temp-character/temp-sleep.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '寝起き',             derivation_number: 0, label: 'そっとする',       priority: 1, position: 1, message: 'まだねむいみたいだからそっとしておこう！', character_image: 'temp-character/temp-wakeup.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '寝起き',             derivation_number: 0, label: 'よしよしする',     priority: 1, position: 1, message: '〈たまご〉がよろこんでいる！おはよう！',   character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '寝起き',             derivation_number: 0, label: 'よしよしする',     priority: 2, position: 1, message: 'よしよし！',                            character_image: 'temp-character/temp-wakeup.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '寝起き',             derivation_number: 0, label: 'きがえさせる',     priority: 1, position: 1, message: '〈たまご〉はふくなんかきていない！',      character_image: 'temp-character/temp-wakeup.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '寝起き',             derivation_number: 3, label: 'はい',            priority: 1, position: 1, message: '〈たまご〉はおこってしまった！',           character_image: 'temp-character/temp-okoru.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '占い',               derivation_number: 0, label: 'すすむ',          priority: 1, position: 1, message: '『ほんじつのあなたはすっごくラッキー！』', character_image: 'temp-character/temp-TV1.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '占い',               derivation_number: 0, label: 'すすむ',          priority: 1, position: 2, message: '『ちょっかんにしたがうと、おもわぬいいことが！』', character_image: 'temp-character/temp-TV2.png', background_image: 'temp-background/temp-background.png',
   messages: [ '『ちょっかんにしたがうと、おもわぬいいことがありそう！』', '『せっきょくてきにうごくと、とってもいいことがおこりそう！』', '『おいしいものをたべると、きんうんアップ！』', '『ふだんとへんかのあるこうどうをいしきしよう！』', '『まわりのひとからかんしゃされそうなよかん！』',
               '『なにをやってもうまくいきそう！』', '『いつもはしっぱいすることも、きょうならうまくいきそう！』', '『じぶんのとくいなことにうちこんでみよう！』', '『ひとのえがおにふれると、うんきがアップ！』', '『まわりへのおもいやりを、いつもいじょうにだいじにしよう！』' ] },
  { event_set_name: '占い',               derivation_number: 0, label: 'すすむ',          priority: 1, position: 3, message: 'だそうだ！', character_image: 'temp-character/temp-TV2.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '占い',               derivation_number: 0, label: 'すすむ',          priority: 2, position: 1, message: '『ほんじつのあなたはそこそこラッキー！』', character_image: 'temp-character/temp-TV1.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '占い',               derivation_number: 0, label: 'すすむ',          priority: 2, position: 2, message: '『あんまりふかくかんがえすぎず、こうどうしよう！』', character_image: 'temp-character/temp-TV2.png', background_image: 'temp-background/temp-background.png',
   messages: [ '『あんまりふかくかんがえすぎず、こうどうしよう！』', '『ごぜんちゅうから、かっぱつてきにこうどうしよう！』', '『あまいものをたべると、いいことがあるかも！』', '『じぶんをかざらず、すごしてみよう！』', '『コミュニケーションがじゅうようないちにちになりそう！』',
               '『けんこうてきないちにちをすごすのがポイント！』', '『ちょうせんがうまくいきそうなよかん！』', '『じぶんのにがてなことにうちこんでみよう！』', '『たまにはのんびりすごすのもいいかも！』', '『にんげんかんけいがうまくいきそう！』' ] },
  { event_set_name: '占い',               derivation_number: 0, label: 'すすむ',          priority: 2, position: 3, message: 'だそうだ！', character_image: 'temp-character/temp-TV2.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '占い',               derivation_number: 0, label: 'すすむ',          priority: 3, position: 1, message: '『ほんじつのあなたはちょっぴりラッキー！』', character_image: 'temp-character/temp-TV1.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '占い',               derivation_number: 0, label: 'すすむ',          priority: 3, position: 2, message: '『でもマンホールのうえにはきをつけよう！』', character_image: 'temp-character/temp-TV1.png', background_image: 'temp-background/temp-background.png',
   messages: [ '『でもマンホールのうえにはきをつけよう！』', '『みぎかひだりだったら、ひだりをえらぼう！』', '『みぎかひだりだったら、みぎをえらぼう！』', '『おとしよりにやさしくするのがポイント！』', '『にがてなたべものをがんばってたべてみよう！』',
               '『うんどうをするといいことがあるかも？』', '『トイレはがまんしないほうがよさそう！』', '『せいじつなきもちをもっていれば、いいいちにちになりそう！』', '『きょうはいそがしいかもしればいけど、がんばってみよう！』', '『でもひとのわるぐちをいうと、うんきがガクッとさがるよ！』',
               '『ラッキーカラーはきいろ！』', '『ラッキーカラーはあお！』', '『ラッキーカラーはあか！』', '『ラッキーカラーはみどり！』', '『ニコニコすることをこころがけよう！』' ] },
  { event_set_name: '占い',               derivation_number: 0, label: 'すすむ',          priority: 3, position: 3, message: 'だそうだ！', character_image: 'temp-character/temp-TV1.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'タマモン',               derivation_number: 0, label: 'みていいよ',          priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！',              character_image: 'temp-character/temp-TV4.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'タマモン',               derivation_number: 0, label: 'みさせてあげない',     priority: 1, position: 1, message: 'しょぼん。',                              character_image: 'temp-character/temp-TV5.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'タマモン',               derivation_number: 1, label: 'いっしょにみる',       priority: 1, position: 1, message: '『でばんだ、タマチュウ！』', character_image: 'temp-character/temp-TV6.png', background_image: 'temp-background/temp-background.png',
   messages: [ '『でばんだ、タマチュウ！』', '『これからたびにでるぞ！』', '『タマモンマスターへのみちはながい！』', '『タマチュウがつよくなってきた！』', '『バトルだタマチュウ！』',
               '『タマチュウにげるぞ！』', '『タマチュウ！かえってこい！』', '『タマチュウきょうはちょうしわるいか？』', '『タマチュウ！たたかってくれ！』', '『これがタマチュウ？』',
               '『タマチュウ、さいきんふとった？』', '『あのタマモンつかまえよう！』', '『あー、にげられた！』', '『あのやまをこえないと！』', '『タマチュウ、これからもよろしくな！』' ] },

  { event_set_name: 'タマえもん',               derivation_number: 0, label: 'みていいよ',          priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！',           character_image: 'temp-character/temp-TV4.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'タマえもん',               derivation_number: 0, label: 'みさせてあげない',     priority: 1, position: 1, message: 'しょぼん。',                           character_image: 'temp-character/temp-TV5.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'タマえもん',               derivation_number: 1, label: 'いっしょにみる',       priority: 1, position: 1, message: '『たすけてタマえもん！』', character_image: 'temp-character/temp-TV6.png', background_image: 'temp-background/temp-background.png',
   messages: [ '『たすけてタマえもん！』', '『タマえもーん！』', '『タマえもんにどうにかしてもらおう！』', '『タマえもんとケンカしてしまった・・・。』', '『タメえもんにもできないことがあるんだね』',
               '『しっかりしてよタマえもん！』', '『いそいでかえらないと！』', '『タマえもん、これどうやってつかえばいいの？』', '『いつもありがとうね、タマえもん！』', '『きょうはがっこうにいきたくないなあ』',
               '『こうえんにあそびにいこう！』', '『タマえもん、またあしたね！』', '『いそいでタマえもんのところにいかないと！』', '『タマえもん、さっきはごめんね！』', '『タマえもん、これからもよろしくね！』' ] },

  { event_set_name: 'ニワトリビアの湖',           derivation_number: 0, label: 'みていいよ',          priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！',           character_image: 'temp-character/temp-TV4.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ニワトリビアの湖',           derivation_number: 0, label: 'みさせてあげない',     priority: 1, position: 1, message: 'しょぼん。',                           character_image: 'temp-character/temp-TV5.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ニワトリビアの湖',           derivation_number: 1, label: 'いっしょにみる',       priority: 1, position: 1, message: '『コケーコケーコケー、100コケー！』', character_image: 'temp-character/temp-TV6.png', background_image: 'temp-background/temp-background.png',
   messages: [ '『コケーコケーコケー、97コケー！』', '『コケーコケーコケー、91コケー！』', '『コケーコケーコケー、88コケー！』', '『コケーコケーコケー、84コケー！』', '『コケーコケーコケー、75コケー！』',
               '『コケーコケーコケー、69コケー！』', '『コケーコケーコケー、61コケー！』', '『コケーコケーコケー、54コケー！』', '『コケーコケーコケー、46コケー！』', '『コケーコケーコケー、43コケー！』', '『コケーコケーコケー、36コケー！』', '『コケーコケーコケー、35コケー！』',
               '『コケーコケーコケー、27コケー！』', '『コケーコケーコケー、14コケー！』', '『コケーコケーコケー、7コケー！』', '『0コケー！』' ] },

  { event_set_name: '扇風機',                 derivation_number: 0, label: 'よしよしする',      priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！',                 character_image: 'temp-character/temp-senpuuki2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '扇風機',                 derivation_number: 0, label: 'スイカをあげる',    priority: 1, position: 1, message: '〈たまご〉はおいしそうにたべている！',          character_image: 'temp-character/temp-senpuuki3.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '扇風機',                 derivation_number: 0, label: 'スイカをあげる',    priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいみたい。',            character_image: 'temp-character/temp-senpuuki4.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '扇風機',                 derivation_number: 0, label: 'せんぷうきをとめる', priority: 1, position: 1, message: '〈たまご〉「・・・！」',                       character_image: 'temp-character/temp-bikkuri.png',   background_image: 'temp-background/temp-background.png' },
  { event_set_name: '扇風機',                 derivation_number: 0, label: 'そっとする',        priority: 1, position: 1, message: '〈たまご〉はきもちよさそう！',                 character_image: 'temp-character/temp-senpuuki1.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'こたつ',                 derivation_number: 0, label: 'よしよしする',      priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！',                 character_image: 'temp-character/temp-kotatu2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'こたつ',                 derivation_number: 0, label: 'ミカンをあげる',    priority: 1, position: 1, message: '〈たまご〉はおいしそうにたべている！',          character_image: 'temp-character/temp-kotatu3.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'こたつ',                 derivation_number: 0, label: 'ミカンをあげる',    priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいみたい。',            character_image: 'temp-character/temp-kotatu4.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'こたつ',                 derivation_number: 0, label: 'こたつをとめる',    priority: 1, position: 1, message: '〈たまご〉「・・・！」',                       character_image: 'temp-character/temp-bikkuri.png',   background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'こたつ',                 derivation_number: 0, label: 'そっとする',        priority: 1, position: 1, message: '〈たまご〉はきもちよさそう！',                 character_image: 'temp-character/temp-kotatu1.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '花見',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 1, message: 'よし！おはなみにいこっか！',                    character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '花見',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 2, message: 'おはなみにきた！',                             character_image: 'temp-character/temp-hanami.png', background_image: 'temp-background/temp-hanami.png' },
  { event_set_name: '花見',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 3, message: '〈たまご〉「にー！んににー！」',                             character_image: 'temp-character/temp-hanami.png', background_image: 'temp-background/temp-hanami.png' },
  { event_set_name: '花見',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 4, message: '〈たまご〉「にににーに、んにににに！」',                             character_image: 'temp-character/temp-hanami.png', background_image: 'temp-background/temp-hanami.png' },
  { event_set_name: '花見',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 5, message: '〈たまご〉「にー！んにー、んにに！」',                             character_image: 'temp-character/temp-hanami.png', background_image: 'temp-background/temp-hanami.png' },
  { event_set_name: '花見',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 6, message: '〈たまご〉はたのしんでいるようだ！',                             character_image: 'temp-character/temp-hanami.png', background_image: 'temp-background/temp-hanami.png',
   messages: [ '〈たまご〉はたのしんでいるようだ！', '〈たまご〉はさくらがきょうみぶかいみたい！', '〈たまご〉はさくらがきれいだといっている！', '〈たまご〉はしあわせをかんじているようだ！', '〈たまご〉はしぜんをだいじにしていきたいといっている！',
               '〈たまご〉はたこやきがたべたいようだ！', '〈たまご〉ははるがすきらしい！', '〈たまご〉はこれからもっといろんなものをみたいらしい！', '〈たまご〉はたわいもないことをたのしそうにはなしている！', '〈たまご〉はきいてほしいはなしがいっぱいあるようだ！', '〈たまご〉はおこのみやきがたべたいようだ！』',
               '〈たまご〉はふってくるさくらをがんばってつかもうとしている！', '〈たまご〉はずっとむこうまでみにいきたいらしい！！', '〈たまご〉はまたつれてきてねといっている！', '〈たまご〉はやさしいきもちでいっぱいなようだ！' ] },
  { event_set_name: '花見',                   derivation_number: 0, label: 'いかない',         priority: 1, position: 1, message: 'しょぼん。',                    character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '紅葉',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 1, message: 'よし！コウヨウをみにいこっか！',                    character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '紅葉',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 2, message: 'コウヨウをみにきた！',                             character_image: 'temp-character/temp-kouyou.png', background_image: 'temp-background/temp-kouyou.png' },
  { event_set_name: '紅葉',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 3, message: '〈たまご〉「んにー！」',                             character_image: 'temp-character/temp-kouyou.png', background_image: 'temp-background/temp-kouyou.png' },
  { event_set_name: '紅葉',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 4, message: '〈たまご〉「んにに！にー！」',                             character_image: 'temp-character/temp-kouyou.png', background_image: 'temp-background/temp-kouyou.png' },
  { event_set_name: '紅葉',                   derivation_number: 0, label: 'つれていく',       priority: 1, position: 5, message: '〈たまご〉はたのしんでいるようだ！',                             character_image: 'temp-character/temp-kouyou.png', background_image: 'temp-background/temp-kouyou.png',
   messages: [ '〈たまご〉はたのしんでいるようだ！', '〈たまご〉はおちばをあつめている！', '〈たまご〉はおおはしゃぎ！', '〈たまご〉はいまのコウヨウのいろみがすきなようだ！', '〈たまご〉はコウヨウのうつくしさにかんどうしている！',
               '〈たまご〉はニコニコだ！', '〈たまご〉はあきがすきらしい！', '〈たまご〉はこれからもっといろんなものをみたいらしい！', '〈たまご〉はおちばをじまんしている！', '〈たまご〉はなぜはっぱのいろがうつりかわるのか、ふしぎなようだ！', 'またこんどもこようね！』',
               '〈たまご〉はふってくるおちばをつかまえるのがすきらしい！', '〈たまご〉はここにいるとココロがおちつくようだ！', '〈たまご〉はまたつれてきてねといっている！', '〈たまご〉はせいめいのとうとさをかんじているようだ！' ] },
  { event_set_name: '紅葉',                   derivation_number: 0, label: 'いかない',         priority: 1, position: 1, message: 'しょぼん。',                    character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '年始',                   derivation_number: 0, label: 'すすむ',           priority: 1, position: 1, message: '〈たまご〉「ににににに、んにににー！」',                    character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '年始',                   derivation_number: 0, label: 'すすむ',           priority: 1, position: 2, message: '〈たまご〉「にににに、ににににー！」',                     character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '年始',                   derivation_number: 0, label: 'すすむ',           priority: 1, position: 3, message: 'あけましておめでとう！',                                 character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '年始',                   derivation_number: 0, label: 'すすむ',           priority: 1, position: 4, message: 'ことしもよろしくね、〈たまご〉！',                                   character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'そっとする',      priority: 1, position: 1, message: '〈たまご〉はたのしそうにあそんでいる！',                character_image: 'temp-character/temp-building_blocks.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'よしよしする',    priority: 1, position: 1, message: '〈たまご〉はうれしそう！',                             character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'ちょっかいをだす', priority: 1, position: 1, message: '〈たまご〉がおこってしまった！',                       character_image: 'temp-character/temp-okoru.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'ブロックをくずす', priority: 1, position: 1, message: 'あー！ほんとにブロックをくずしちゃった！これはひどい！', character_image: 'temp-character/temp-okoru.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'ちょっかいをだす', priority: 2, position: 1, message: '〈たまご〉はちょっといやそう。', character_image: 'temp-character/temp-hukigen.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ブロックのおもちゃに夢中', derivation_number: 0, label: 'ブロックをくずす', priority: 2, position: 1, message: '〈たまご〉にそしされた。',       character_image: 'temp-character/temp-building_blocks.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'そっとする',        priority: 1, position: 1, message: '〈たまご〉はマンガがおもしろいようだ。',                     character_image: 'temp-character/temp-comics.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'よしよしする',      priority: 1, position: 1, message: '〈たまご〉はうれしそう！',                                  character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'はなしかける',      priority: 1, position: 1, message: '〈たまご〉はマンガにしゅうちゅうしたいみたい。ごめんごめん。', character_image: 'temp-character/temp-hukigen.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'マンガをとりあげる', priority: 1, position: 1, message: '〈たまご〉がおこってしまった！',                            character_image: 'temp-character/temp-okoru.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'マンガに夢中', derivation_number: 0, label: 'はなしかける',      priority: 2, position: 1, message: '〈たまご〉はニコニコしている。',                            character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '眠そう', derivation_number: 0, label: 'ねかせる',          priority: 1, position: 1, message: 'きょうはもうねようね！〈たまご〉おやすみ！', character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ねかせる',          priority: 2, position: 1, message: 'まだもうちょっとおきてたいみたい。',        character_image: 'temp-character/temp-sleepy.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はうれしそうだ！',               character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 2, message: '〈たまご〉はおふとんにはいってねた！',      character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'よしよしする',       priority: 2, position: 1, message: '〈たまご〉はよろこんでいる！',             character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'はみがきをさせる',   priority: 1, position: 1, message: 'よし、よくみがこうね！',                   character_image: 'temp-character/temp-hamigaki.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'はみがきをさせる',   priority: 1, position: 2, message: '〈たまご〉はちゃんとはみがきした！',        character_image: 'temp-character/temp-hamigaki.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'はみがきをさせる',   priority: 2, position: 1, message: 'はみがきしたくないみたい。まったくー！',     character_image: 'temp-character/temp-sleepy.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 1, position: 1, message: 'チーターががけから・・・',                 character_image: 'temp-character/temp-sleepy.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 1, position: 2, message: 'おっこちーたー！！',                       character_image: 'temp-character/temp-sleepy.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 1, position: 3, message: '〈たまご〉はおおわらいした！',             character_image: 'temp-character/temp-warau.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 2, position: 1, message: 'アルミかんのうえに・・・',                 character_image: 'temp-character/temp-sleepy.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 2, position: 2, message: 'あるミカン！！',                          character_image: 'temp-character/temp-sleepy.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 2, position: 3, message: '〈たまご〉がちょっとひいてる・・・。',      character_image: 'temp-character/temp-donbiki.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 3, position: 1, message: 'ふとんが・・・',                          character_image: 'temp-character/temp-sleepy.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 3, position: 2, message: 'ふっとんだ！！',                          character_image: 'temp-character/temp-sleepy.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '眠そう', derivation_number: 0, label: 'ダジャレをいう',     priority: 3, position: 3, message: 'わらわない・・・。',                       character_image: 'temp-character/temp-sleepy.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '寝かせた', derivation_number: 0, label: 'そっとする',       priority: 1, position: 1, message: 'きもちよさそうにねているなあ。', character_image: 'temp-character/temp-sleep.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '寝かせた', derivation_number: 0, label: 'よしよしする',     priority: 1, position: 1, message: 'りっぱにそだちますように。', character_image: 'temp-character/temp-sleep.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '寝かせた', derivation_number: 0, label: 'たたきおこす',     priority: 1, position: 1, message: 'できるわけないだろ！！', character_image: 'temp-character/temp-sleep.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '怒っている', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！',     character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 2, message: '〈たまご〉はゆるしてくれた！',     character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'よしよしする',       priority: 2, position: 1, message: '〈たまご〉はゆるしてくれない！！', character_image: 'temp-character/temp-okoru.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！',     character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 2, message: '〈たまご〉はゆるしてくれた！',     character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'おやつをあげる',     priority: 2, position: 1, message: 'おやつじゃゆるしてくれない！',     character_image: 'temp-character/temp-okoru.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 1, position: 1, message: 'こんしんのへんがお！',             character_image: 'temp-character/temp-hengao.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 1, position: 2, message: '〈たまご〉「キャッキャッ！」',      character_image: 'temp-character/temp-warau.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 1, position: 3, message: '大ウケした！',                    character_image: 'temp-character/temp-warau.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 2, position: 1, message: 'こんしんのへんがお！',             character_image: 'temp-character/temp-hengao.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 2, position: 2, message: '〈たまご〉「・・・。」',             character_image: 'temp-character/temp-donbiki.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'へんがおをする',     priority: 2, position: 3, message: 'すべった。',                      character_image: 'temp-character/temp-donbiki.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'あやまる',           priority: 1, position: 1, message: 'ごめんよ・・・。',                character_image: 'temp-character/temp-gomen.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'あやまる',           priority: 1, position: 2, message: '〈たまご〉はゆるしてくれた！',     character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'あやまる',           priority: 2, position: 1, message: 'ごめんよ・・・。',                character_image: 'temp-character/temp-gomen.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '怒っている', derivation_number: 0, label: 'あやまる',           priority: 2, position: 2, message: '〈たまご〉はまだおこっている！',    character_image: 'temp-character/temp-okoru.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '算数',      derivation_number: 1,  label: '〈A〉',                priority: 1, position: 1, message: 'おー！せいかい！いいちょうしだね！',     character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 1,  label: '〈B〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 1,  label: '〈C〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 1,  label: '〈D〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '算数',      derivation_number: 2,  label: '〈A〉',                priority: 1, position: 1, message: 'おー！せいかい！いいちょうしだね！',     character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 2,  label: '〈B〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 2,  label: '〈C〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 2,  label: '〈D〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '算数',      derivation_number: 3,  label: '〈A〉',                priority: 1, position: 1, message: 'おー！せいかい！いいちょうしだね！',     character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 3,  label: '〈B〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 3,  label: '〈C〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 3,  label: '〈D〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '算数',      derivation_number: 4,  label: '〈A〉',                priority: 1, position: 1, message: 'おー！せいかい！いいちょうしだね！',     character_image: 'temp-character/temp-nikoniko2.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 4,  label: '〈B〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 4,  label: '〈C〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '算数',      derivation_number: 4,  label: '〈D〉',                priority: 1, position: 1, message: 'ちがうよー！ざんねん！',     character_image: 'temp-character/temp-ochikomu.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'ひだりだ！',   priority: 1, position: 1, message: 'おー！きれいにキャッチ！',     character_image: 'temp-character/temp-ball4.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'そこだ！',     priority: 1, position: 1, message: 'なんとかキャッチ！',           character_image: 'temp-character/temp-ball4.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'そこだ！',     priority: 2, position: 1, message: 'あちゃー！',                  character_image: 'temp-character/temp-ball7.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'みぎだ！',     priority: 1, position: 1, message: 'あちゃー！',                  character_image: 'temp-character/temp-ball10.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'ひだりだ！',   priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'そこだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'そこだ！',     priority: 2, position: 2, message: 'しょぼん。',                  character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 2,  label: 'みぎだ！',     priority: 1, position: 2, message: 'しょぼん。',                  character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'ひだりだ！',   priority: 1, position: 1, message: 'なんとかキャッチ！',           character_image: 'temp-character/temp-ball8.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'ひだりだ！',   priority: 2, position: 1, message: 'あちゃー！',                  character_image: 'temp-character/temp-ball5.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'そこだ！',     priority: 1, position: 1, message: 'おー！きれいにキャッチ！',     character_image: 'temp-character/temp-ball8.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'みぎだ！',     priority: 1, position: 1, message: 'なんとかキャッチ！',           character_image: 'temp-character/temp-ball8.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'みぎだ！',     priority: 2, position: 1, message: 'あちゃー！',                  character_image: 'temp-character/temp-ball11.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'ひだりだ！',   priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'ひだりだ！',   priority: 2, position: 2, message: 'しょぼん。',                  character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'そこだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'みぎだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 3,  label: 'みぎだ！',     priority: 2, position: 2, message: 'しょぼん。',                  character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'ひだりだ！',   priority: 1, position: 1, message: 'あちゃー！',                  character_image: 'temp-character/temp-ball6.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'そこだ！',     priority: 1, position: 1, message: 'なんとかキャッチ！',           character_image: 'temp-character/temp-ball12.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'そこだ！',     priority: 2, position: 1, message: 'あちゃー！',                  character_image: 'temp-character/temp-ball9.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'みぎだ！',     priority: 1, position: 1, message: 'おー！きれいにキャッチ！',     character_image: 'temp-character/temp-ball12.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'ひだりだ！',   priority: 1, position: 2, message: 'しょぼん。',                  character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'そこだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'そこだ！',     priority: 2, position: 2, message: 'しょぼん。',                  character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: 'ボール遊び',      derivation_number: 4,  label: 'みぎだ！',     priority: 1, position: 2, message: '〈たまご〉じょうずだねえ！',    character_image: 'temp-character/temp-nikoniko.png', background_image: 'temp-background/temp-background.png' },

  { event_set_name: '特訓',      derivation_number: 0,  label: 'さんすう',              priority: 1, position: 1, message: 'とっくんはれんぞく20もんになるぞ！', character_image: 'temp-character/temp-bikkuri.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '特訓',      derivation_number: 0,  label: 'さんすう',              priority: 2, position: 1, message: 'このとっくんは〈たまご〉にはまだはやい！', character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '特訓',      derivation_number: 0,  label: 'ボールあそび',          priority: 1, position: 1, message: 'とっくんは3かいしっぱいするまでつづくぞ！', character_image: 'temp-character/temp-bikkuri.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '特訓',      derivation_number: 0,  label: 'ボールあそび',          priority: 2, position: 1, message: 'このとっくんは〈たまご〉にはまだはやい！', character_image: 'temp-character/temp-gakkari.png', background_image: 'temp-background/temp-background.png' },
  { event_set_name: '特訓',      derivation_number: 1,  label: 'すすむ',                priority: 1, position: 1, message: 'けっかは・・・。',                    character_image: 'temp-character/temp-tukareta.png', background_image: 'temp-background/temp-background.png' }
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
