require 'test_helper'

class StudentsEditTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_objectives
        setup_scores_and_commodities
        setup_goals
    end
end