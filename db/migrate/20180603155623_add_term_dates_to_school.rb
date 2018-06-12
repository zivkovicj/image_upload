class AddTermDatesToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column       :schools, :term_dates, :text
  end
end
