class Admin < User
                
    validates  :password, presence: true,
                    length: {minimum: 6},
                    allow_nil: true
    has_secure_password

end
