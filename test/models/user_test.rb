require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    # インスタンス変数を設定、UserTestクラス内で共通して使用できる
    # その他のテストにもこのUserTestクラスは継承される？
    @user = User.new(name: "Example User", email: "user@example.com",
            password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid? # @userはあるか？あればtrue、なければfalse
  end

  test "name should be present" do
    @user.name = "  " # @user.nameが空
    assert_not @user.valid? # assert_not はテストがfalseか確認する
  end

  test "email should be present" do
    @user.email = "  " # @user.emailが空
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51 # @user.nameが51文字以上
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com" # @user.emailが256文字以上
    assert_not @user.valid?
  end
  
  # メールアドレスが正しいか
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    # valid_addressesについて1つずつ検証  
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, '#{invalid_address.inspect} should be invalid'
    end
  end
   
  # メールアドレスが一意か
  test "email addresses should be unique" do
    duplicate_user = @user.dup # dupは同じ属性を持つユーザーを複製
    duplicate_user.email = @user.email.upcase # 複製したユーザーのメールアドレスを大文字化
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = "" * 6
    assert_not @user.valid?
  end
  
  # パスワードが短すぎないか
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and undollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end

  test "feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    # フォローしているユーザーの投稿を確認
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    # 自分自身の投稿を確認
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    # フォローしていないユーザーの投稿を確認
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
