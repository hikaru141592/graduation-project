# Trigger Conditions JSONB スキーマ

## ひな型

```json
{
  "operator": "and",       // "and" または "or"、単体条件の場合も"operator": "and"を用いる。
  "conditions": [
    {
      "type": "status",       // ステータス変動判定
      "attribute": "hunger_value",
      "operator": ">=",
      "value": 50
    },
    {
      "type": "probability",  // 確率判定
      "percent": 15
    },
    {
      "type": "item",         // アイテム所持数判定
      "item_code": "special_toy",
      "operator": ">=",
      "value": 1
    }
    // 必要であれば OR/AND のネスト条件も追加可能
  ]
}
