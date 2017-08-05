require 'test_helper'

class AdminTest < ActiveSupport::TestCase
  def setup
    @admin = Admin.new(first_name: "Beef", last_name: "Stroganoff", 
          email: "user@example.com", 
          password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid" do
    assert @admin.valid?
  end
  
  test "first name should be present" do
    @admin.first_name = "    "
    assert_not @admin.valid?
  end
  
  test "last name should be present" do
    @admin.last_name = "    "
    assert_not @admin.valid?
  end
  
  test "email should be present" do
    @admin.email = "     "
    assert_not @admin.valid?
  end
  
  test "first name should not be too long" do
    @admin.first_name = "a" * 26
    assert_not @admin.valid?
  end
  
  test "last name should not be too long" do
    @admin.last_name = "a" * 26
    assert_not @admin.valid?
  end

  test "email should not be too long" do
    @admin.email = "a" * 244 + "@example.com"
    assert_not @admin.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @admin.email = valid_address
      assert @admin.valid?, "#{valid_address.inspect} should be valid"
    end
  end
    
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @admin.email = invalid_address
      assert_not @admin.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @admin.dup
    duplicate_user.email = @admin.email.upcase
    @admin.save
    assert_not duplicate_user.valid?
  end
  
  test "password should be present (nonblank)" do
    @admin.password = @admin.password_confirmation = " " * 6
    assert_not @admin.valid?
  end

  test "password should have a minimum length" do
    @admin.password = @admin.password_confirmation = "a" * 5
    assert_not @admin.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @admin.authenticated?(:remember, '')
  end
end
