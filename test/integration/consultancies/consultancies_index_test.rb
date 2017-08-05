require 'test_helper'

class ConsultanciesIndexTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_seminars

    
    end
    
    test "index consultancies" do
        capybara_login(@seminar.user)
        click_on("index_consult_#{@seminar.id}")
    end
    
end