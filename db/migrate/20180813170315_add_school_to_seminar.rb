class AddSchoolToSeminar < ActiveRecord::Migration[5.0]
  def change
    add_reference  :seminars, :school, :foreign_key => true
    add_column      :seminars, :term_start_date, :datetime
    add_column      :seminars, :term_end_date, :datetime
    add_reference  :quizzes, :seminar, :foreign_key => true      
  end
end
