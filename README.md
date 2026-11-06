# SubCheck

サブスクリプションの請求日と支出を保存する API です。
LINE のリッチメニューから使います。

## リッチメニュー

- 登録は、Rails の登録フォームを開く
- 編集は、LINE 上でサブスクを選んで Rails の編集フォームを開く
- 一覧は、LINE のトークに登録内容を返す
- 削除は、LINE 上でサブスクを選んで削除する
- アプリを開くは、React のアプリを開く
- 使い方は、ボタンだけあり、処理はまだない

React 側では、一覧、登録、編集、削除、カレンダー、分析ができる。保存先は、この Rails の API です。LINE の ID トークンで本人を確認し、LINE ユーザー ID は URL にも JSON にも入れません。

## リマインダー

- 請求日の 16 時間前、8 時間前、2 時間前、30 分前に通知する
- 毎日 10 時に、明日が請求日のサブスクを通知する

## 環境変数

値そのものは書きません。

- `LINE_CHANNEL_SECRET`
- `LINE_CHANNEL_ACCESS_TOKEN`
- `LINE_CHANNEL_ID`
- `SUBSCRIPTION_CREATE_LIFF_ID`
- `SUBSCRIPTION_EDIT_LIFF_ID`

## データベース
本番は PostgreSQL です。

## バージョン
- Ruby 3.1.0
- Rails 7.2
