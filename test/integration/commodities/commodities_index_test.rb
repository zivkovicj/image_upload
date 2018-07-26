require 'test_helper'

class CommoditiesIndexTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_commodities
    end
    
    test "edit commodity" do
        capybara_login(@teacher_1)
        click_on("Manage #{@school.market_name}")
        find("#edit_#{@commodity_2.id}").click
        
        fill_in("commodity[name]", :with => "New Pickle")
        fill_in("commodity[current_price]", :with => 22)
        fill_in("commodity[quantity]", :with => 55)
        
        click_on("Save Changes")
        
        assert_no_selector('h2', :text => "Edit Item")
        
        @commodity_2.reload
        assert_equal "New Pickle", @commodity_2.name
        assert_equal @school, @commodity_2.school
        assert_equal 22, @commodity_2.current_price
        assert_equal 55, @commodity_2.quantity
        assert_nil @commodity_2.user_id
        
        assert_selector('h2', :text => @school.market_name)
    end
    
    test "cant edit commodity to blank name" do
        capybara_login(@teacher_1)
        click_on("Manage #{@school.market_name}")
        find("#edit_#{@commodity_2.id}").click
        
        fill_in("commodity[name]", :with => "")
        
        click_on("Save Changes")
        
        @commodity_2.reload
        assert_equal "Burger Salad", @commodity_2.name
        assert_equal @school, @commodity_2.school
        assert_equal 5, @commodity_2.current_price
        assert_equal 400, @commodity_2.quantity
        assert_nil @commodity_2.user_id
        
        assert_no_selector('h2', :text => "School Market")
        assert_selector('h2', :text => "Edit Item")
    end
    
    test "cant edit commodity to star name" do
        capybara_login(@teacher_1)
        click_on("Manage #{@school.market_name}")
        find("#edit_#{@commodity_2.id}").click
        
        fill_in("commodity[name]", :with => "Star")
        
        click_on("Save Changes")
        
        @commodity_2.reload
        assert_equal "Burger Salad", @commodity_2.name
        assert_equal @school, @commodity_2.school
        assert_equal 5, @commodity_2.current_price
        assert_equal 400, @commodity_2.quantity
        assert_nil @commodity_2.user_id
        
        assert_no_selector('h2', :text => "School Market")
        assert_selector('h2', :text => "Edit Item")
    end
    
    test "delete commodity" do
        old_school_commodity_count = @school.commodities.count
        assert old_school_commodity_count > 0
        
        capybara_login(@teacher_1)
        click_on("Manage #{@school.market_name}")
        
        find("#delete_#{@commodity_2.id}").click
        click_on("confirm_#{@commodity_2.id}")
        
        @school.reload
        assert_equal old_school_commodity_count - 1, @school.commodities.count
        
        assert_selector('h2', :text => @school.market_name)
    end
    
   
    
end