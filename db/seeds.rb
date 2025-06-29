categories = [
  { name: '通常',     description: '何か言っている、何かしたそう',                         loop_minutes: nil  },
  { name: 'ルンルン', description: '踊っている',                                           loop_minutes: 12   },
  { name: '泣いている', description: '泣いている(空腹)、泣いている(よしよし不足)、泣いている(ランダム)', loop_minutes: 60 },
  { name: '怒っている', description: '怒っている',                                         loop_minutes: 60   },
  { name: '夢中',     description: 'ブロックのおもちゃに夢中、マンガに夢中',               loop_minutes: nil  },
  { name: '眠そう',   description: '眠そう',                                               loop_minutes: 12   },
  { name: '寝ている', description: '寝ている',                                             loop_minutes: 90   }
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
  { category_name: '寝ている',  name: '寝ている' }
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
          "value":     20
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
          "percent": 0
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
    character_image:   'character/kari-nikoniko.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    'ブロックのおもちゃに夢中',
    name:              'ブロックのおもちゃに夢中',
    derivation_number: 0,
    message:           '〈たまご〉はブロックのおもちゃにむちゅうだ。',
    character_image:   'character/kari-nikoniko.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    'マンガに夢中',
    name:              'マンガに夢中',
    derivation_number: 0,
    message:           '〈たまご〉はマンガをよむのにむちゅうだ',
    character_image:   'character/kari-nikoniko.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '眠そう',
    name:              '眠そう',
    derivation_number: 0,
    message:           '〈たまご〉はねむそうだ',
    character_image:   'character/kari-nikoniko.png',
    background_image:  'background/kari-background.png'
  },
  {
    event_set_name:    '寝ている',
    name:              '寝ている',
    derivation_number: 0,
    message:           '〈たまご〉はねている',
    character_image:   'character/kari-nikoniko.png',
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
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "mood_value", "delta": 10 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何か言っている',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              1,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 30 },
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
    effects:               { "status": [ { "attribute": "mood_value", "delta": 20 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '何かしたそう',
    derivation_number:     0,
    label:                 'べんきょうする',
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
    effects:               { "status": [ { "attribute": "love_value", "delta": 30 },
                                         { "attribute": "mood_value", "delta": -100 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
  },
  {
    event_set_name:        '踊っている',
    derivation_number:     0,
    label:                 'よしよしする',
    priority:              2,
    trigger_conditions:    { always: true },
    effects:               { "status": [ { "attribute": "love_value", "delta": 30 },
                                         { "attribute": "happiness_value", "delta": 1 },
                                         { "attribute": "mood_value", "delta": -100 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
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
    resolves_loop:         false
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
    resolves_loop:         false
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
    resolves_loop:         false
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
    resolves_loop:         false
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
    effects:               { "status": [ { "attribute": "love_value", "delta": 30 } ] },
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
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
    effects:               {},
    next_derivation_number: nil,
    calls_event_set_name:  nil,
    resolves_loop:         false
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
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 1, position: 1, message: '〈たまご〉がうれしそうにはなしている！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'はなしをきいてあげる', priority: 1, position: 2, message: '〈たまご〉「んに～！！」', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'ごはんをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },

  { event_set_name: '何か言っている', derivation_number: 0, label: 'おやつをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ', character_image: 'character/kari-normal.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何か言っている', derivation_number: 0, label: 'ごはんをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ', character_image: 'character/kari-normal.png', background_image: 'background/kari-background.png' },

  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'ボールあそびをする', priority: 1, position: 1, message: 'いっしょにあそんであげた！とてもよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'べんきょうする',     priority: 1, position: 1, message: 'おべんきょうをした！がんばったね！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'おえかきする',       priority: 1, position: 1, message: 'おえかきをした！じょうずにかけたね！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '何かしたそう',   derivation_number: 0, label: 'ゲームする',         priority: 1, position: 1, message: 'いっしょにあそんであげた！ゲームはたのしいね！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },

  { event_set_name: '踊っている',     derivation_number: 0, label: 'よしよしする',       priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'おやつをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'ごはんをあげる',     priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },

  { event_set_name: '踊っている',     derivation_number: 0, label: 'よしよしする',       priority: 2, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'おやつをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ', character_image: 'character/kari-normal.png', background_image: 'background/kari-background.png' },
  { event_set_name: '踊っている',     derivation_number: 0, label: 'ごはんをあげる',     priority: 2, position: 1, message: '〈たまご〉はおなかいっぱいのようだ', character_image: 'character/kari-normal.png', background_image: 'background/kari-background.png' },

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
  { event_set_name: '泣いている(ランダム)', derivation_number: 0, label: 'あそんであげる',   priority: 1, position: 1, message: '〈たまご〉はよろこんでいる！', character_image: 'character/kari-nikoniko.png', background_image: 'background/kari-background.png' }
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
    status.hunger_value  = 50
    status.happiness_value = 10
    status.love_value     = 50
    status.mood_value     = 0
    status.study_value    = 0
    status.sports_value   = 0
    status.art_value      = 0
    status.money          = 0
  end

  PlayState.find_or_create_by!(user: user) do |ps|
    first_set   = EventSet.find_by!(name: '何か言っている')
    first_event = Event.find_by!(event_set: first_set, derivation_number: 0)
    ps.current_event_id         = first_event.id
    ps.action_choices_position  = nil
    ps.action_results_priority  = nil
    ps.current_cut_position     = nil
  end
end
