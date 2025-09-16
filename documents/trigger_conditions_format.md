# Trigger Conditions JSONB ひな型

## 指定できる条件
- 以下の条件をAND条件かOR条件で複数指定可能
  - ステータス値
  - 確率
  - アイテム所持数（今後実装予定）
  - 時間帯
    - 0時をまたいで指定可能
    - 擬似乱数（日にち、user_id依存）によって揺らぎを生成
  - 曜日
  - 日付の範囲
    - 年末年始をまたいで指定可能

```
{
  "operator": "and",              // "and"または"or"
  "conditions": [
    { "type" => "status",         // hunger_valueが70を超えているとき
      "attribute" => "hunger_value",
      "operator"  => ">",
      "value"     => 70 },

    { "type" => "probability",    // 40%の確率で
      "percent" => 40 },

    {
      "type" => "item",           // リンゴを一つ以上所持しているとき（アイテムは今後実装予定）
      "item_code" => "apple",
      "operator" => ">=",
      "value" => 1
    },

    {
      "type"      => "time_range",          // 7時30分~8時30分のとき
      "from_hour" => 7, "from_min" => 30,   // ただし以下の擬似乱数パラメータによって生成された議事乱数で微妙にずらす
      "to_hour"   => 8, "to_min"   => 30
      "offsets_by_day" => [
        { "add" => 27, "mult" => 4, "mod" => 15, "target" => "from_min" },  //疑似乱数生成パラメーター
        { "add" => 27, "mult" => 4, "mod" => 15, "target" => "to_min" }
      ]
    },

    { "type" => "weekday",        // 月、水、金曜日のとき
      "value" => [1, 3, 5] },

    { "type" => "date_range",     // 12月1日～1月31日のとき
      "from" =>{
        "month" => 12,
        "day" => 1 },
      "to" => {
        "month" => 1,
        "day" => 31 } },
  ]
}
```
