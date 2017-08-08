Rails.application.routes.draw do

  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/partner', to: 'static_pages#partner'
  get   '/materials', to: 'static_pages#materials', :as => "materials"
  get    '/signup',  to: 'teachers#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  #get     '/seminar_students/:id', to: 'seminar_students#removeFromClass'
  #put     '/seminar_students/:id', to: 'seminar_students#ajaxUpdate'
  
  #post '/objective_seminars/edit', to: 'objective_seminars#edit'
  #post '/objective_seminars/update_priorities', to: 'objective_seminars#update_priorities'
  
  #post '/label_objectives/edit', to: 'label_objectives#edit'
  #post '/label_objectives/update', to: 'label_objectives#update'
  
  #get    '/seminars/scoresheet/:id', to: 'seminars#scoresheet', 
    #:as => "scoresheet"
  #get   '/seminars/student_view/:id', to: 'seminars#student_view',
    #:as => "student_view"
    
  #post   '/seminars/student_view/:id', to: 'seminars#student_view'
  
  #get 'students/edit_teaching_requests/:id', to: 'students#edit_teaching_requests',
    #:as => "edit_teaching_requests"
    
  #get '/objectives/quantities/:id',    to: 'objectives#quantities', :as => "quantities"
  
  
  
  resources :admins
  resources :account_activations, only: [:edit]
  resources :consultancies, only: [:new, :create, :show, :index]
  resources :labels
  resources :label_objectives do
    post 'update_quantities', on: :collection
  end
  resources :objective_seminars do
    post 'update_pretests', on: :collection
    post 'update_priorities', on: :collection
  end
  resources :objective_students
  resources :objectives do
    get 'quantities', on: :member
  end
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :pictures
  resources :preconditions
  resources :questions
  resources :quizzes
  resources :ripostes
  resources :seminars do
    get 'pretests', on: :member
    get 'priorities', on: :member
    get 'scoresheet', on: :member
    get 'student_view', on: :member
  end
  resources :seminar_students do
    get 'removeFromClass', on: :member
    put 'ajaxUpdate', on: :member
  end
  resources :students do
    get 'edit_teaching_requests', on: :member
  end
  resources :teachers
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
