class Worksheet < ApplicationRecord
    mount_uploader  :uploaded_file, WorksheetUploader
    
    has_many    :objective_worksheets, dependent: :destroy
    has_many    :objectives, :through => :objective_worksheets
    belongs_to  :user
    
    validates  :name, :presence => true
    
    include ModelMethods
end
