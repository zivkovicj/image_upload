require 'test_helper'

class SeminarsSeatingChartTest < ActionDispatch::IntegrationTest
    
    def setup
        @user = users(:michael)
        @teacher_user = users(:archer)
        @seminar = seminars(:one)
        @student = students(:student_1)
    end
    
    #test 'checkSeatingChart' do
        #capybara_teacher_login()
        #seatChartId = "seatingChart#{@seminar.id}"
        #click_on(seatChartId)
        #source = page.first("div", :class => 'draggable-item')
        #target = page.find('#1003')
        #source.drag_to(target)
        #save_and_open_page
    #end
    
end