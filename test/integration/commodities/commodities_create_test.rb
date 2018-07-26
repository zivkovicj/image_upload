require 'test_helper'

class CommoditiesCreateTest < ActionDispatch::IntegrationTest
    
    include CommoditiesHelper
    
    def setup
        setup_users
        setup_schools
        
        @old_commodity_count = Commodity.count
    end
    
    def go_to_new_commodity_page
        click_on("Manage #{@school.market_name}")
        click_on(new_item_button_text)
    end
    
    test "create new commodity" do
        capybara_login(@teacher_1)
        go_to_new_commodity_page
        
        fill_in("commodity[name]", :with => "Burger Salad")
        fill_in("commodity[current_price]", :with => 6)
        fill_in("commodity[quantity]", :with => 95)
        
        click_on("Create a New Item")
        
        assert_no_selector('h2', :text => "New Item")
        assert_selector('h2', :text => @school.market_name)
        
        assert_equal @old_commodity_count + 1, Commodity.count
        
        @commodity = Commodity.last
        assert_equal "Burger Salad", @commodity.name
        assert_equal @school, @commodity.school
        assert_equal 6, @commodity.current_price
        assert_equal 95, @commodity.quantity
        assert_nil @commodity.user_id
    end
    
    test "default commodity values" do
        capybara_login(@teacher_1)
        go_to_new_commodity_page
        
        fill_in("commodity[name]", :with => "Burger Salad")
        
        click_on("Create a New Item")
        
        assert_equal @old_commodity_count + 1, Commodity.count
        
        @commodity = Commodity.last
        assert_equal "Burger Salad", @commodity.name
        assert_equal @school, @commodity.school
        assert_equal 5, @commodity.current_price
        assert_equal 10, @commodity.quantity
        assert_nil @commodity.user_id
    end
    
    test "commodity must have name" do
        capybara_login(@teacher_1)
        go_to_new_commodity_page
        
        fill_in("commodity[current_price]", :with => 6)
        fill_in("commodity[quantity]", :with => 95)
        
        click_on("Create a New Item")
        
        assert_equal @old_commodity_count, Commodity.count
        assert_selector('h2', :text => "New Item")
    end
    
    test "cannot name commodity star or gem" do
        capybara_login(@teacher_1)
        go_to_new_commodity_page
        
        fill_in("commodity[name]", :with => "Star")
        
        click_on("Create a New Item")
        
        assert_equal @old_commodity_count, Commodity.count
        assert_selector('h2', :text => "New Item")
        
        fill_in("commodity[name]", :with => "gems")
        click_on("Create a New Item")
        
        assert_equal @old_commodity_count, Commodity.count
        assert_selector('h2', :text => "New Item")
    end
    
    test "create item button does not appear for lower level admin" do
        @other_teacher.update(:school_admin => 0)
        capybara_login(@other_teacher)
        click_on("View #{@school.market_name}")
        
        assert_no_text(new_item_button_text)
    end
    
    test "must be school admin to create commodity" do
        @teacher_1.update(:school_admin => 0)
        
        capybara_login(@teacher_1)
        visit("/commodities/new")
        
        assert_no_selector('h2', :text => "New Item")
        assert_selector('p', :text => "Mr. Z School Teacher Since:")
    end
    
end