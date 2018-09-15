require 'test_helper'

class CommoditiesIndexTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_commodities
    end
    
    def go_to_edit_game_ticket
        click_on("Manage #{@teacher_1.name_with_title} Market")
        find("#edit_#{@game_time_ticket.id}").click
    end
    
    test "deliverable not salable on edit" do
        capybara_login(@teacher_1)
        go_to_edit_game_ticket
        
        choose("salable_true")
        choose("deliverable_true")
        click_on("Save Changes")
        
        @game_time_ticket.reload
        assert @game_time_ticket.deliverable
        assert_not @game_time_ticket.salable
    end
    
    test "edit school commodity" do
        assert_not @commodity_2.salable
        
        capybara_login(@teacher_1)
        click_on("Manage #{@school.market_name}")
        find("#edit_#{@commodity_2.id}").click
        
        fill_in("commodity[name]", :with => "New Pickle")
        fill_in("commodity[current_price]", :with => 22)
        fill_in("commodity[quantity]", :with => 55)
        choose("salable_true")
        choose("deliverable_false")
        
        click_on("Save Changes")
        
        assert_no_selector('h2', :text => "Edit Item")
        
        @commodity_2.reload
        assert_equal "New Pickle", @commodity_2.name
        assert_equal @school, @commodity_2.school
        assert_nil @commodity_2.user_id
        assert_equal 22, @commodity_2.current_price
        assert_equal 55, @commodity_2.quantity
        assert @commodity_2.salable
    
        assert_selector('h2', :text => @school.market_name)
    end
    
    test "edit teacher commodity" do
        assert_equal 6, @game_time_ticket.current_price
        
        capybara_login(@teacher_1)
        go_to_edit_game_ticket
        
        fill_in("commodity[name]", :with => "Game Slime Slicket")
        fill_in("commodity[current_price]", :with => 33)
        fill_in("commodity[quantity]", :with => 66)
        choose("salable_true")
        choose("deliverable_false")
        
        click_on("Save Changes")
        
        assert_no_selector('h2', :text => "Edit Item")
        
        @game_time_ticket.reload
        assert_equal "Game Slime Slicket", @game_time_ticket.name
        assert_equal @teacher_1, @game_time_ticket.user
        assert_nil @game_time_ticket.school_id
        assert_equal 33, @game_time_ticket.current_price
        assert_equal 66, @game_time_ticket.quantity
        assert @game_time_ticket.salable
        
        assert_selector('h2', :text => "#{@teacher_1.name_with_title} Market")
    end
    
    test "edit teacher commodity default info" do
        capybara_login(@teacher_1)
        click_on("Manage #{@teacher_1.name_with_title} Market")
        find("#edit_#{@game_time_ticket.id}").click
        
        click_on("Save Changes")
        
        assert_no_selector('h2', :text => "Edit Item")
        
        @game_time_ticket.reload
        assert_equal "Game Time Ticket", @game_time_ticket.name
        assert_equal @teacher_1, @game_time_ticket.user
        assert_nil @game_time_ticket.school_id
        assert_equal 6, @game_time_ticket.current_price
        assert_equal 50, @game_time_ticket.quantity
        assert @game_time_ticket.salable
        
        assert_selector('h2', :text => "#{@teacher_1.name_with_title} Market")
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