module ModelMethods
    extend ActiveSupport::Concern
    
    def shortName
        name[0,20].split.map(&:capitalize).join(' ')
    end
    
    module ClassMethods
        
        # Search for specific records
        def search(search, whichParam)
            if search
                results = where("#{whichParam} LIKE ?" , "%#{search}%")
            else
               nil
            end
            results = [0] if results == []
            return results
        end
        
        
    
    end
end