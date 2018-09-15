class School < ApplicationRecord
    after_create  :set_market_and_currency_name
    
    has_many  :teachers
    has_many  :students
    has_many  :commodities
    
    include ModelMethods
    include NeedDelivered
    
    validates :name, presence: true
    validates :city, presence: true
    validates :state, presence: true
    
    serialize :term_dates
    
    def self.default_terms
        [["08/14/2018","10/27/2018"],
         ["10/28/2018","01/19/2019"],
         ["01/20/2019","03/23/2019"],
         ["03/24/2019","06/05/2019"]]
    end
    attribute :term_dates, :text, default: self.default_terms
    attribute   :term, :integer, default: 0
    
    def verified_teachers
        self.teachers.where(:verified => 1) 
    end
    
    def unverified_teachers
        self.teachers.where(:verified => 0)
    end
    
    def set_market_and_currency_name
        self.update(:market_name => "#{self.name} Market", :school_currency_name => "#{self.name} Bucks")
    end
end
