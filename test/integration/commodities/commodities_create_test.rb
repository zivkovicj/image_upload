require 'test_helper'

class CommoditiesCreateTest < ActionDispatch::IntegrationTest
    
    include CommoditiesHelper
    
    def setup
        setup_users
        setup_schools
        
        @old_commodity_count = Commodity.count
    end
    
    def go_to_new_commodity_page
        click_on("manage_teacher_market")
        click_on("Create a New Item")
    end
    
    test "create school commodity" do
        capybara_login(@teacher_1)
        click_on("manage_school_market")
        click_on("Create a New Item")
        
        fill_in("commodity[name]", :with => "Burger Salad")
        fill_in("commodity[current_price]", :with => 6)
        fill_in("commodity[quantity]", :with => 95)
        
        click_on("Create a New Item")
        
        assert_no_selector('h2', :text => "New Item")
        assert_selector('h2', :text => "#{@school.market_name}")
        
        assert_equal @old_commodity_count + 1, Commodity.count
        
        @commodity = Commodity.last
        assert_equal "Burger Salad", @commodity.name
        assert_equal @school, @commodity.school
        assert_nil  @commodity.user_id
        assert_equal 6, @commodity.current_price
        assert_equal 95, @commodity.quantity
        assert_not @commodity.salable
        assert_not @commodity.usable
    end
    
    test "create teacher commodity" do
        capybara_login(@teacher_1)
        click_on("manage_teacher_market")
        click_on("Create a New Item")
        
        fill_in("commodity[name]", :with => "Teacher Salad")
        fill_in("commodity[current_price]", :with => 7)
        fill_in("commodity[quantity]", :with => 99)
        
        click_on("Create a New Item")
        
        assert_no_selector('h2', :text => "New Item")
        assert_selector('h2', :text => "Star Market")
        
        assert_equal @old_commodity_count + 1, Commodity.count
        
        @commodity = Commodity.last
        assert_equal "Teacher Salad", @commodity.name
        assert_nil @commodity.school_id
        assert_equal @teacher_1, @commodity.user
        assert_equal 7, @commodity.current_price
        assert_equal 99, @commodity.quantity
        assert_not @commodity.salable
        assert_not @commodity.usable
    end
    
    test "default commodity values" do
        capybara_login(@teacher_1)
        go_to_new_commodity_page
        
        fill_in("commodity[name]", :with => "Burger Salad")
        
        click_on("Create a New Item")
        
        assert_equal @old_commodity_count + 1, Commodity.count
        
        @commodity = Commodity.last
        assert_equal "Burger Salad", @commodity.name
        assert_nil @commodity.school
        assert_equal 5, @commodity.current_price
        assert_equal 10, @commodity.quantity
        assert_equal @teacher_1, @commodity.user
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
    
    test "no new item button for low admin" do
        @other_teacher.update(:school_admin => 0)
        capybara_login(@other_teacher)
        click_on("View #{@school.market_name}")
        
        assert_no_text("Create a New Item")
    end
    
    test "no item screen for non admin" do
        @teacher_1.update(:school_admin => 0)
        
        capybara_login(@teacher_1)
        visit("/commodities/new")
        
        assert_no_selector('h2', :text => "New Item")
        assert_selector('p', :text => "New to Desk Consultants?")
    end
    
end