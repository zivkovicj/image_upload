module ApplicationHelper
    
    def full_title(page_title = '')
        base_title = "Mr. Z School"
        if page_title.empty?
            base_title
        else 
            page_title + " | " + base_title
        end
    end
    
    def conditional_wrapper(condition=true, options={}, &block)
        options[:tag] ||= :strong
        if condition
            concat content_tag(options[:tag], capture(&block), options.delete_if{|k,v| k == :tag})
        else
            concat capture(&block)
        end
    end
end
