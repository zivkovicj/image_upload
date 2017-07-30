require 'test_helper'

class ConsultanciesIndexTest < ActionDispatch::IntegrationTest
    
    def setup
        @seminar = seminars(:one)

    
    end
    
    
    test "index consultancies" do
        capybara_teacher_login()
        click_on("index_consult_#{@seminar.id}")
    end
    
end