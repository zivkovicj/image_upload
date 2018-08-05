class AddBucksToSeminarStudent < ActiveRecord::Migration[5.0]
  def change
    add_column    :seminar_students, :bucks_earned, :integer
    add_column    :seminar_students, :gems_given_toward_reward, :integer
    add_column    :seminar_students, :stars_used_toward_grade, :text
    
    add_column    :seminars, :default_buck_increment, :integer
    add_column    :seminars, :class_reward, :string
    add_column    :seminars, :target_rate, :integer
  end
end
