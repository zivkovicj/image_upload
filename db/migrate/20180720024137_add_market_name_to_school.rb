class AddMarketNameToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column  :schools, :market_name, :string
    add_column  :schools, :school_currency_name, :string
    add_column  :users, :teacher_currency_name, :string
    add_column  :users, :school_bucks_owned, :integer
    rename_column :seminar_students, :bucks_owned, :seminar_bucks_owned
  end
end
