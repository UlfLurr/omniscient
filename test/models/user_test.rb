require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Ex@mple User_001", email: "user@example.com", password_digest: "asdfasdfasd3425d14231asdl")
    @user1 = User.new(name: "Ex@mple User_002", email: "user2@example.com", password_digest: "asdasdfasdf8192347qwersdl")
  end

  test "should be valid" do
    assert @user.has_name?
    assert @user.short_enough_name?
    assert @user.long_enough_name?
    assert @user.has_email?
    assert @user.short_enough_email?
    assert @user.has_email?
    assert @user.unique_name?
    assert @user.unique_email?
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
    assert_not @user.has_name?
  end

  test "name should not be too long" do
    @user.name = ("a" * 51)
    assert_not @user.valid?
    assert_not @user.short_enough_name?
    @user.name = ("a" * 26)
    assert @user.valid?
    assert @user.short_enough_name?
  end

  test "name should not be too short" do
    @user.name = "a" * 1
    assert_not @user.valid?
    assert_not @user.long_enough_name?
    @user.name = "a" * 2
    assert @user.valid?
    assert @user.long_enough_name?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
    assert_not @user.has_email?
  end

  test "email should not be too long" do
    @user.email = ("a" * 200) + "@" + ("a" * 50) + "." + "aaaa"
    assert_not @user.valid?
    assert_not @user.short_enough_email?
    @user.email = ("a" * 200) + "@" + ("a" * 50) + "." + "aaa"
    assert @user.valid?
    assert @user.short_enough_email?
  end


  test "user should be unique" do
    duplicate_user = @user.dup
    @user.pseudosave
    assert_not duplicate_user.unique_name?
    assert_not duplicate_user.unique_email?
    @user.save
    assert_not duplicate_user.valid?    
  end

  test "user email should be unique" do
    @user1.email = @user.email.upcase
    @user.pseudosave
    assert @user1.unique_name?
    assert_not @user1.unique_email? 
    @user.save
    assert_not @user1.valid?    
  end

  test "user name should be unique" do
    @user1.name = @user.name.upcase
    @user.pseudosave
    assert_not @user1.unique_name?
    assert @user1.unique_email? 
    @user.save
    assert_not @user1.valid?    
  end


  #test "password digest should be present" do
  #  @user.email = "     "
  #  assert_not @user.valid?
  #  assert_not @user.hasPassword?
  #end
end
