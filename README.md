# Subcheck - サブスクリプション管理アプリ

サブスクリプション管理用のWebアプリケーション。LINEボット機能により、LINEから直接サブスクの登録・編集・削除・一覧表示が可能です。

## LINE Bot 機能

### リッチメニュー対応機能
1. **サブスク登録** - 新規サブスクリプションをLIFFフォームで登録
2. **サブスク編集** - 既存のサブスクリプションを選択して編集
3. **サブスク削除** - 既存のサブスクリプションを選択して削除
4. **サブスク一覧** - 登録済みサブスクリプションの一覧表示と月額合計
5. **リマインダー** - 更新日の16時間前、8時間前、2時間前、30分前に自動通知

### 環境変数設定
LINEボット機能を使用するには以下の環境変数が必要です：
- `LINE_CHANNEL_SECRET`: LINE Botチャンネルシークレット
- `LINE_CHANNEL_ACCESS_TOKEN`: LINE Botアクセストークン
- `SUBSCRIPTION_CREATE_LIFF_ID`: 登録用LIFF ID
- `SUBSCRIPTION_EDIT_LIFF_ID`: 編集用LIFF ID

## 従来のREADME内容

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
