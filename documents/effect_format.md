# EventCategoryモデルにおけるeffect属性のJSONB ひな型

## 指定できること
- 以下の値の増減が可能
  - ステータス値
  - アイテム所持数（今後実装予定）

```
{
  "status": [
    { "attribute": "hunger_value", "delta": 30 },
    { "attribute": "love_value",   "delta": -10 }
  ],
  "items": [
    { "item_code": "special_toy", "delta": 1 },
    { "item_code": "snack",       "delta": -2 }
  ]
}
