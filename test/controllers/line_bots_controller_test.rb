require "test_helper"

class LineBotsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @line_user = line_users(:one)
    @subscription = subscriptions(:one)
  end

  test "should handle follow event" do
    event_body = {
      events: [
        {
          type: "follow",
          source: { userId: "test_line_user_id" },
          replyToken: "test_reply_token"
        }
      ]
    }.to_json
    
    assert_difference('LineUser.count', 0) do  # Should not create new user since fixture exists
      post line_callback_path, params: event_body, headers: { 'Content-Type' => 'application/json' }
    end
    
    assert_response :ok
  end

  test "should handle subscription list message" do
    event_body = {
      events: [
        {
          type: "message",
          message: { type: "text", text: "サブスク一覧" },
          source: { userId: "test_line_user_id" },
          replyToken: "test_reply_token"
        }
      ]
    }.to_json
    
    post line_callback_path, params: event_body, headers: { 'Content-Type' => 'application/json' }
    
    assert_response :ok
  end

  test "should handle subscription registration message" do
    event_body = {
      events: [
        {
          type: "message",
          message: { type: "text", text: "サブスク登録" },
          source: { userId: "test_line_user_id" },
          replyToken: "test_reply_token"
        }
      ]
    }.to_json
    
    post line_callback_path, params: event_body, headers: { 'Content-Type' => 'application/json' }
    
    assert_response :ok
  end

  test "should handle subscription edit message" do
    event_body = {
      events: [
        {
          type: "message",
          message: { type: "text", text: "サブスク編集" },
          source: { userId: "test_line_user_id" },
          replyToken: "test_reply_token"
        }
      ]
    }.to_json
    
    post line_callback_path, params: event_body, headers: { 'Content-Type' => 'application/json' }
    
    assert_response :ok
  end

  test "should handle subscription delete message" do
    event_body = {
      events: [
        {
          type: "message",
          message: { type: "text", text: "サブスク削除" },
          source: { userId: "test_line_user_id" },
          replyToken: "test_reply_token"
        }
      ]
    }.to_json
    
    post line_callback_path, params: event_body, headers: { 'Content-Type' => 'application/json' }
    
    assert_response :ok
  end
end
