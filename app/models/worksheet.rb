class Worksheet < ApplicationRecord
    mount_uploader  :uploaded_file, WorksheetUploader
    
    validates  :name, :presence => true
end
