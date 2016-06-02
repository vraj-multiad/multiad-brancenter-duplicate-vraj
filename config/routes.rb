BrandCenter::Application.routes.draw do
  resources :ac_creator_template_groups

  resources :dynamic_form_input_groups
  get '/dynamic_form_input_groups/copy/:id' => 'dynamic_form_input_groups#copy', as: 'copy_dynamic_form_input_group'

  resources :dynamic_forms
  get '/forms/get_attachment_form/:token/:dynamic_form_input_id' => 'dynamic_forms#get_attachment_form', as: 'dynamic_form_get_attachment_form'
  get '/forms/display/:token' => 'dynamic_forms#display_form', as: 'display_form'
  post '/forms/submit' => 'dynamic_forms#submit_form', as: 'submit_form'
  get '/forms/submissions/:token' => 'dynamic_forms#display_submissions', as: 'form_submissions'
  get '/forms/display_submitted_form/:token' => 'dynamic_forms#display_submitted_form', as: 'display_submitted_form'
  get '/forms/delete_submitted_form/:token' => 'dynamic_forms#delete_submitted_form', as: 'delete_submitted_form'

  get 'error_page' => 'sessions#test' if Rails.env.development?
  # contacts
  resources :contact_types

  resources :contacts
  post '/contacts/search' => 'contacts#search'
  post '/contacts/new_contact' => 'contacts#new_contact', as: 'contact_new'
  post '/contacts/create_contact' => 'contacts#create_contact', as: 'contact_create'
  post '/contacts/edit_contact' => 'contacts#edit_contact', as: 'contact_edit'
  post '/contacts/save_contact' => 'contacts#save_contact', as: 'contact_save'
  post '/contacts/remove_contact' => 'contacts#remove_contact', as: 'contact_remove'

  # document_approval
  post '/admin/approve_document' => 'ac_exports#admin'

  # approval queues
  match '/admin/approve_users' => 'operation_queues#approve_users', via: %w(post get), as: 'admin_approve_users'
  match '/admin/approve_documents' => 'operation_queues#approve_documents', via: %w(post get), as: 'admin_approve_documents'
  match '/admin/approve_orders' => 'operation_queues#approve_orders', via: %w(post get), as: 'admin_approve_orders'

  resources :kwikee_external_codes

  resources :kwikee_custom_data_attributes

  resources :kwikee_custom_data

  resources :operation_queues
  get '/operation_queue/status/:token/:status' => 'operation_queues#set_operation_queue_status', as: 'set_operation_queue_status'
  match '/profile/user_orders' => 'users#user_orders', via: %w(post get), as: 'user_orders'
  match '/profile/user_order_details/:id' => 'users#user_order_details', via: %w(post get), as: 'user_order_details'

  resources :mailing_lists

  match '/profile/user_mailing_lists' => 'users#user_mailing_lists', via: %w(post get)
  match '/adcreator/user_mailing_lists_select' => 'ac_sessions#user_mailing_lists_select', via: %w(post get)
  post '/mailing_lists/delete_list' => 'mailing_lists#delete_list', as: 'mailing_lists_delete_list'
  get '/mailing_list/upload_form' => 'mailing_lists#upload_form', as: 'mailing_list_upload_form'
  get '/mailing_list/create_list' => 'mailing_lists#create_list', as: 'mailing_list_create'
  post '/mailing_list/set_title' => 'mailing_lists#set_title', as: 'mailing_list_set_title'

  resources :click_events
  post '/click_event/create' => 'click_events#create_user_event', as: 'create_user_click_event'

  resources :roles

  resources :marketing_email_recipients

  resources :marketing_emails

  resources :opt_outs
  post '/marketing_email/opt_out' => 'opt_outs#unsubscribe', as: 'marketing_email_opt_out'
  get '/marketing_email/opt_out/:email_address' => 'opt_outs#unsubscribe'

  resources :email_lists
  match '/profile/marketing_emails' => 'users#user_marketing_emails', via: %w(post get), as: 'user_marketing_emails'
  match '/profile/marketing_email_stats' => 'users#user_marketing_email_stats', via: %w(post get), as: 'user_marketing_email_stats'
  match '/profile/user_email_lists' => 'users#user_email_lists', via: %w(post get)
  match '/adcreator/user_email_lists_select' => 'ac_sessions#user_email_lists_select', via: %w(post get)
  post '/email_lists/delete_list' => 'email_lists#delete_list', as: 'email_lists_delete_list'
  get '/email_list/upload_form' => 'email_lists#upload_form', as: 'email_list_upload_form'
  get '/email_list/create_list' => 'email_lists#create_list', as: 'email_list_create'
  post '/email_list/set_title' => 'email_lists#set_title', as: 'email_list_set_title'

  match '/stats' => 'stats#display_form', via: %w(post get)
  match '/stats/display_form' => 'stats#display_form', via: %w(post get)
  match '/stats/download_report' => 'stats#download_report', via: %w(post get)
  match '/stats/common_search_phrases' => 'stats#common_search_phrases', via: %w(post get), as: 'common_search_phrases'
  match '/stats/ac_images_in_exports' => 'stats#ac_images_in_exports', via: %w(post get), as: 'ac_images_in_exports'
  match '/stats/asset_report' => 'stats#asset_report', via: %w(post get), as: 'asset_report'
  match '/stats/user_report' => 'stats#user_report', via: %w(post get), as: 'user_report'
  match '/stats/template_export_report' => 'stats#template_export_report', via: %w(post get), as: 'template_export_report'
  match '/stats/template_order_report' => 'stats#template_order_report', via: %w(post get), as: 'template_order_report'
  match '/stats/template_approval_report' => 'stats#template_approval_report', via: %w(post get), as: 'template_approval_report'

  resources :kwikee_files

  resources :kwikee_assets

  resources :kwikee_nutritions

  resources :kwikee_products

  get '/admin/kapi/init' => 'kwikee_api_jobs#init'

  resources :kwikee_api_job_files

  resources :kwikee_api_jobs

  resources :dl_image_groups

  post '/admin/dl_image_group/create' => 'dl_image_groups#admin_create', as: 'admin_dl_image_group_create'
  post '/admin/dl_image_group/add/:token' => 'dl_image_groups#admin_add', as: 'admin_dl_image_group_add'
  match '/admin/dl_image_group/edit/:token' => 'dl_image_groups#admin_edit_form', via: %w(post get), as: 'admin_dl_image_group_edit'
  post '/admin/dl_image_group/update/:token' => 'dl_image_groups#admin_update', as: 'admin_dl_image_group_update'
  post '/admin/dl_image_group/remove' => 'dl_image_groups#admin_remove', as: 'admin_dl_image_group_remove'

  resources :fulfillment_items

  resources :order_items

  resources :orders

  resources :fulfillment_methods

  resources :access_levels

  resources :languages

  resources :keyword_types

  resources :shared_page_downloads

  resources :shared_page_items

  resources :shared_pages

  resources :user_keywords

  # omniauth callbacks
  get '/auth/facebook/callback' => 'social_media_accounts#facebook_callback'
  get '/auth/twitter/callback'  => 'social_media_accounts#twitter_callback'
  get '/auth/youtube/callback'  => 'social_media_accounts#youtube_callback'
  get '/auth/failure'           => 'social_media_accounts#auth_fail'
  match  '/auth/saml/callback'  => 'sessions#saml_authenticate', via: ['post','get']

  # social networks logout
  match '/profile/facebook/logout' => 'social_media_accounts#facebook_logout', via: %w(post get)
  match '/profile/twitter/logout'  => 'social_media_accounts#twitter_logout', via: %w(post get)
  match '/profile/youtube/logout'  => 'social_media_accounts#youtube_logout', via: %w(post get)

  # social media posts
  post '/social_media_post/share'   => 'social_media_posts#share'
  get '/social_media_post'         => 'social_media_posts#index'
  post '/social_media_post'         => 'social_media_posts#post'
  match '/social_media_post/status' => 'social_media_posts#status', via: %w(post get)
  get '/social_media_post/new'     => 'social_media_posts#new'
  post '/social_media_post/create'  => 'social_media_posts#post' # instead of post /social_media_post

  get '/shared_assets/page' => 'social_media_posts#shared_page'
  post '/shared_assets/asset_preview' => 'social_media_posts#shared_page_asset_preview'

  # resources :social_media_posts

  # resources :social_media_accounts

  resources :keyword_terms

  resources :ac_exports

  resources :user_downloads

  resources :dl_cart_items

  resources :dl_carts

  # resources :user_uploaded_images

  resources :ac_images

  resources :ac_texts
  post 'ac_texts/name_title', to: 'ac_texts#search_name_title', as: 'ac_texts_name_title_search'
  post 'ac_texts/keyword/text', to: 'ac_texts#search_text', as: 'ac_texts_text_search'
  post 'ac_texts/keyword', to: 'ac_texts#search_keywords', as: 'ac_texts_keyword_search'
  post 'ac_texts/set', to: 'ac_texts#search_set_attributes', as: 'ac_texts_set_search'
  post 'ac_texts/responds', to: 'ac_texts#search_responds_to_attributes', as: 'ac_texts_responds_search'
  get 'ac_texts/name_title/:name/:title', to: 'ac_texts#search_name_title'
  get 'ac_texts/keyword/text/:text', to: 'ac_texts#search_text'
  get 'ac_texts/keyword/:keyword', to: 'ac_texts#search_keywords'
  get 'ac_texts/set/:name/:value', to: 'ac_texts#search_set_attributes'
  get 'ac_texts/responds/:name/:value', to: 'ac_texts#search_responds_to_attributes'

  resources :ac_session_attributes

  resources :responds_to_attributes

  resources :set_attributes

  # get 'static_pages/home'
  # get 'static_pages/help'

  # admin
  match '/admin_ac_images', to: 'static_pages#admin_ac_images', via: %w(post get)
  match '/admin', to: 'static_pages#admin', via: %w(post get)
  match '/contributor', to: 'static_pages#contributor', via: %w(post get)
  # ac ( ac_creator_templates, ac_base, ac_steps)

  match '/admin/ac', to: 'ac_creator_templates#admin_ac', via: %w(post get), as: 'admin_ac'
  match '/admin/ac/upload', to: 'ac_creator_templates#admin_ac_upload', via: 'get'
  match '/admin/ac/upload_direct_bundle', to: 'ac_creator_templates#admin_upload_direct_bundle', via: 'get'
  match '/admin/ac/edit', to: 'ac_creator_templates#admin_edit_ac', via: 'get'
  match '/admin/ac/load', to: 'ac_creator_templates#admin_load_ac', via: 'post'
  match '/admin/ac/staged', to: 'ac_creator_templates#admin_ac_staged', via: 'get'
  match '/admin/ac/display', to: 'ac_creator_templates#admin_ac_display', via: 'get'
  match '/admin/ac/save', to: 'ac_creator_templates#admin_ac_save', via: 'post'
  match '/admin/ac/publish', to: 'ac_creator_templates#admin_ac_publish', via: 'get'
  get '/admin/open_sessions', to: 'ac_session_histories#admin_open_sessions', as: 'admin_open_sessions'
  get '/admin/repair_ac_session/:bad_session_id/:good_session_id', to: 'ac_session_histories#admin_repair_session', as: 'admin_repair_ac_session_history'
  get '/admin/expire_ac_session/:id', to: 'ac_session_histories#admin_expire_session', as: 'admin_expire_ac_session'

  # edit asset
  match '/admin/edit_assets' => 'users#admin_edit_assets', via: %w(post get)
  match '/admin/edit_assets/update' => 'users#admin_edit_assets_update', via: %w(post get)
  # fulfillment_item
  match '/admin/fulfillment_items' => 'fulfillment_items#admin', via: %w(post get)
  match '/admin/fulfillment_items/add' => 'fulfillment_items#add', via: %w(post get)

  # ac_image
  match '/admin/ac_image', to: 'ac_images#admin_ac_image', via: 'get'
  match '/admin/ac_image_upload', to: 'ac_images#admin_ac_image_upload', via: 'get'
  match '/admin/ac_image/upload_direct_bundle', to: 'ac_images#admin_upload_direct_bundle', via: 'get'
  match '/admin/ac_image/edit', to: 'ac_images#admin_edit_ac_image', via: 'get'
  match '/admin/ac_image/load', to: 'ac_images#admin_load_ac_image', via: 'post'
  match '/admin/ac_image/staged', to: 'ac_images#admin_ac_image_staged', via: 'get'
  match '/admin/ac_image/display', to: 'ac_images#admin_ac_image_display', via: 'get'
  match '/admin/ac_image/save', to: 'ac_images#admin_ac_image_save', via: 'post'
  match '/admin/ac_image/publish', to: 'ac_images#admin_ac_image_publish', via: %w(post get)
  match '/admin/ac_image/production', to: 'ac_images#admin_ac_image_production', via: 'get'
  match '/admin/ac_images/processing' => 'ac_images#admin_processing', via: %w(post get)
  match '/admin/ac_images/add_to_library' => 'ac_images#admin_add_to_library', via: %w(post get)
  match '/admin/ac_images/cancel' => 'ac_images#admin_cancel', via: %w(post get)
  match '/admin/ac_image/upload_direct_ac_image', to: 'ac_images#admin_upload_direct_ac_image', via: 'post'
  match '/admin/ac_images/poll', to: 'ac_images#poll', via: 'get'
  match '/admin/ac_images/incomplete', to: 'ac_images#incomplete', via: 'get'
  match '/admin/ac_images/upload_form', to: 'ac_images#upload_form', via: 'get'

  # dl_image
  match '/admin/dl_image', to: 'dl_images#admin_dl_image', via: 'get'
  match '/admin/dl_image_upload', to: 'dl_images#admin_dl_image_upload', via: 'get'
  match '/admin/dl_image/upload_direct_bundle', to: 'dl_images#admin_upload_direct_bundle', via: 'get'
  match '/admin/dl_image/edit', to: 'dl_images#admin_edit_dl_image', via: 'get'
  match '/admin/dl_image/load', to: 'dl_images#admin_load_dl_image', via: 'post'
  match '/admin/dl_image/staged', to: 'dl_images#admin_dl_image_staged', via: 'get'
  match '/admin/dl_image/display', to: 'dl_images#admin_dl_image_display', via: 'get'
  match '/admin/dl_image/save', to: 'dl_images#admin_dl_image_save', via: 'post'
  match '/admin/dl_image/publish', to: 'dl_images#admin_dl_image_publish', via: %w(post get)
  match '/admin/dl_images/processing' => 'dl_images#admin_processing', via: %w(post get)
  match '/admin/dl_images/add_to_library' => 'dl_images#admin_add_to_library', via: %w(post get)
  match '/admin/dl_images/cancel' => 'dl_images#admin_cancel', via: %w(post get)
  match '/dl_images/upload_direct_contributor' => 'dl_images#upload_direct_contributor', via: %w(post get)
  match '/dl_images/upload_form' => 'dl_images#upload_form', via: ['get']
  match '/dl_images/incomplete' => 'dl_images#incomplete', via: ['get']
  match '/dl_images/poll' => 'dl_images#poll', via: ['get']

  # keyword
  match '/admin/assets_keywords', to: 'keyword#admin_assets', via: %w(post get)
  # filters
  match '/admin/filter', to: 'keyword_terms#admin', via: %w(post get)
  match '/admin/filter/new', to: 'keyword_terms#admin_new', via: %w(post get)
  match '/admin/filter/delete', to: 'keyword_terms#admin_delete', via: %w(post get)
  # users
  match '/admin/users', to: 'users#admin', via: %w(post get)
  match '/admin/user/edit', to: 'users#admin_edit', via: %w(post get)
  match '/admin/user/save', to: 'users#admin_save', via: ['patch']
  match '/admin/user/expire', to: 'users#admin_expire', via: %w(post get)
  match '/admin/user/reset_password', to: 'users#admin_reset_password', via: %w(post get)
  match '/superuser/users', to: 'users#superuser', via: %w(post get)
  match '/superuser/become_user', to: 'users#superuser_become_user', via: %w(post get)

  # asset_group
  match '/asset_group/assets' => 'users#asset_group_assets', via: %w(post get)
  match '/asset_group/init' => 'users#asset_group_init', via: ['post']
  match '/asset_group/add' => 'users#asset_group_add', via: ['post']
  match '/asset_group' => 'users#asset_group_display', via: %w(post get)
  # asset_group_operation
  match '/asset_group/download' => 'dl_carts#submit', via: ['post']
  match '/asset_group/categorize' => 'user_keywords#categorize', via: %w(post get)
  match '/asset_group/share' => 'social_media_posts#share', via: %w(post get)
  # admin asset_group_operation
  match '/asset_group/admin_keywords' => 'keyword#admin', via: %w(post get)
  match '/asset_group/admin_keyword_types' => 'keyword#admin_keyword_types', via: %w(post get)
  match '/asset_group/admin_refresh' => 'keyword#admin_refresh', via: %w(post get)
  match '/asset_group/admin_ac_image_keywords' => 'keyword#admin_ac_image', via: ['post']
  match '/asset_group/admin_dl_image_keywords' => 'keyword#admin_dl_image', via: ['post']
  match '/asset_group/admin_keyword_types' => 'keyword#admin_keyword_types', via: %w(post get)

  # Supported Application routes
  match '/forgot_password', to: 'users#forgot_password', via: 'post'
  match '/reset_password', to: 'users#reset_password', via: 'get'
  match '/change_password', to: 'users#change_password', via: 'patch'
  match '/update_password', to: 'users#update_password', via: 'patch'
  match '/register', to: 'users#new', via: 'get'
  match '/activate' => 'users#activate', via: ['get']

  match '/profile', to: 'users#profile', via: ['get']
  match '/update_profile', to: 'users#update', via: ['patch']
  match '/profile/attachments', to: 'users#attachments', via: %w(post get)
  match '/profile/logos', to: 'users#logos', via: %w(post get)
  match '/profile/upload_image', to: 'user_uploaded_images#upload', via: ['post']
  match '/profile/expire_image', to: 'user_uploaded_images#expire_logo', via: ['post']

  match '/error',  to: 'sessions#error', via: 'get'
  match '/login',  to: 'sessions#new', via: 'get'
  match '/logout', to: 'sessions#destroy', via: 'get'

  root to: 'static_pages#login_redirect'
  match '/help', to: 'static_pages#help', via: 'get'
  match '/home', to: 'static_pages#home', via: %w(post get)
  match '/my_library', to: 'static_pages#my_library', via: %w(post get)
  match '/my_documents', to: 'static_pages#my_documents', via: %w(post get)
  match '/my_documents', to: 'static_pages#my_documents', via: %w(post get)
  match '/my_contributions', to: 'static_pages#my_contributions', via: %w(post get)
  match '/s3_result', to: 'static_pages#s3_result', via: ['get']

  match '/search', to: 'keyword#search', via: %w(post get)
  match '/search_filters', to: 'keyword#search_filters', via: %w(post get)
  match '/asset_preview', to: 'keyword#asset_preview', via: %w(post get)

  match '/adcreator/start', to: 'ac_sessions#start', via: %w(post get)
  match '/adcreator/undo', to: 'ac_sessions#undo', via: %w(post get)
  match '/adcreator/save', to: 'ac_sessions#save', via: %w(post get)
  match '/adcreator/load', to: 'ac_sessions#load', via: %w(post get)
  match '/adcreator/expire', to: 'ac_session_histories#expire', via: %w(post get)
  match '/adcreator/expire_image_and_session_histories' => 'ac_sessions#expire_image_and_session_histories', via: %w(post get)
  match '/adcreator/workspace', to: 'ac_sessions#workspace', via: %w(post get)
  match '/adcreator/process_step' => 'ac_sessions#process_step', via: %w(post get)
  post '/adcreator/get_text_choice_results' => 'ac_sessions#get_text_choice_results'
  post '/adcreator/get_text_choice_multiple_results' => 'ac_sessions#get_text_choice_multiple_results'
  match '/adcreator/user_uploaded_images_ac_image', to: 'ac_sessions#user_uploaded_images_ac_image', via: %w(post get)
  match '/adcreator/set_export_email_address' => 'ac_sessions#set_export_email_address', via: %w(post get)
  match '/adcreator/saved_ads' => 'ac_session_histories#saved_ads', via: %w(post get)
  match '/adcreator/export_finished' => 'ac_sessions#export_finished', via: %w(post get)
  match '/adcreator/reconcile_document' => 'ac_sessions#reconcile_document', via: %w(post get)
  match '/adcreator/load_step_images' => 'ac_sessions#load_step_images', via: %w(post get)
  match '/adcreator/load_step_logos' => 'ac_sessions#load_step_logos', via: %w(post get)
  match '/adcreator/load_step_kwikee_products' => 'ac_sessions#load_step_kwikee_products', via: %w(post get)
  match '/adcreator/export_panel', to: 'ac_sessions#export_panel', via: %w(post get)

  match '/categorize/assets' => 'user_keywords#categorize_assets', via: %w(post get)
  match '/categorize/init' => 'user_keywords#categorize_init', via: ['post']
  # match '/categorize/add' => 'user_keywords#categorize_add', via: ['post']
  match '/categorize' => 'user_keywords#categorize', via: %w(post get)
  match '/categorize_multiple' => 'user_keywords#categorize_multiple', via: %w(post get)
  match '/add_to_favorites' => 'user_keywords#add_to_favorites', via: %w(post get)

  # match '/dl_cart_items/remove' => 'dl_cart_items#destroy', via: ['delete']
  match '/dl_cart/add' => 'dl_cart_items#new', via: ['post']
  match '/dl_cart' => 'dl_carts#view_cart', via: ['get']
  match '/dl_cart/submit' => 'dl_carts#submit', via: ['post']
  match '/dl_cart/finish' => 'dl_carts#finish', via: %w(post get)
  match '/dl_cart/close' => 'dl_carts#close', via: %w(post get)
  match '/dl_cart/clear' => 'dl_carts#clear', via: %w(post get)
  match '/dl_cart/wait' => 'dl_carts#wait', via: %w(post get)

  # order cart routines
  match '/cart' => 'orders#cart', via: %w(post get)
  match '/cart_button' => 'orders#cart_button', via: %w(post get)
  match '/cart/add' => 'orders#add_to_cart', via: %w(post get)
  match '/cart/update' => 'orders#update_cart', via: %w(post), as: 'cart_update'
  match '/cart/remove_item/:order_id/:remove_cart_item_id' => 'orders#remove_cart_item', via: %w(get), as: 'remove_cart_item'
  match '/cart/process' => 'orders#process_cart', via: %w(post get), as: 'cart_process'
  match '/cart/submit/:order_id' => 'orders#submit_cart', via: %w(post get), as: 'cart_submit'

  # match '/download' => 'user_downloads#download', via: ['post']
  match '/download' => 'dl_carts#single_download', via: ['post']
  match '/shared_download' => 'dl_carts#single_download', via: ['post']

  match '/admin' => 'ac_creator_templates#admin_upload', via: ['get']
  match '/admin/new_ac_creator_template' => 'ac_creator_templates#admin_new_ac_creator_template', via: ['get']
  match '/admin/process_ac_creator_template' => 'ac_creator_templates#admin_process_ac_creator_template', via: ['post']
  match '/refresh_document_xml' => 'ac_creator_templates#refresh_document_xml', via: ['get']
  match '/refresh_keyword_term_count' => 'keyword_terms#refresh_term_count', via: ['get']

  resources :user_upload_requests
  match '/user_upload_requests_init' => 'user_upload_requests#init', via: %w(post get)
  match '/user_upload_requests_cancel' => 'user_upload_requests#cancel', via: %w(post get)

  match '/user_uploaded_images' => 'user_uploaded_images#create', via: ['post']
  match '/user_uploaded_images/upload_form' => 'user_uploaded_images#upload_form', via: ['get']
  match '/user_uploaded_images/init' => 'user_uploaded_images#upload_init', via: %w(post get)
  match '/user_uploaded_images/processing' => 'user_uploaded_images#processing', via: %w(post get)
  match '/user_uploaded_images/processing_ac_image' => 'user_uploaded_images#processing_ac_image', via: %w(post get)
  match '/user_uploaded_images/processing_logo' => 'user_uploaded_images#processing_logo', via: %w(post get)
  match '/user_uploaded_images/add_to_library' => 'user_uploaded_images#add_to_library', via: %w(post get)
  match '/user_uploaded_images/cancel' => 'user_uploaded_images#cancel', via: %w(post get)
  match '/user_uploaded_images/expire_image', to: 'user_uploaded_images#expire_library', via: ['post']
  match '/user_uploaded_images/upload_direct_ac_image' => 'user_uploaded_images#upload_direct_ac_image', via: ['post']
  match '/user_uploaded_images/upload_direct_attachment' => 'user_uploaded_images#upload_direct_attachment', via: ['post']
  match '/user_uploaded_images/upload_direct_library' => 'user_uploaded_images#upload_direct_library', via: ['post']
  match '/user_uploaded_images/upload_direct_logo' => 'user_uploaded_images#upload_direct_logo', via: ['post']
  match '/user_uploaded_images/poll', to: 'user_uploaded_images#poll', via: ['get']
  match '/user_uploaded_images/incomplete/:upload_type', to: 'user_uploaded_images#incomplete', via: ['get']

  # asset callbacks
  post '/user_uploaded_images/blitline' => 'image_upload_callback#user_uploaded_image_blitline'
  post '/user_uploaded_images/zencoder' => 'image_upload_callback#user_uploaded_image_zencoder'
  post '/dl_images/blitline' => 'image_upload_callback#dl_image_blitline'
  post '/dl_images/zencoder' => 'image_upload_callback#dl_image_zencoder'

  # internal videos
  get '/admin/videos'          => 'internal_videos#new',      as: 'internal_videos'
  get '/admin/videos/create'   => 'internal_videos#create',   as: 'create_internal_video' # has to be get because of s3 redirect
  post '/admin/videos/zencoder' => 'internal_videos#zencoder', as: 'internal_videos_zencoder'
  get '/admin/videos/:id'      => 'internal_videos#edit',     as: 'internal_video'
  patch '/admin/videos/:id'      => 'internal_videos#update'

  # These will be migrated to different functions later

  resources :users, via: 'post'
  resources :sessions, only: [:new, :create, :destroy], via: 'post'

  # Need to inspect
  resources :keyword, only: [:index]

  # Scaffold defaults to be remapped
  resources :ac_documents
  resources :ac_session_histories
  resources :ac_steps
  resources :ac_bases
  resources :ac_sessions
  resources :ac_creator_templates
  resources :dl_images

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  require 'sidekiq/web'
  require 'superuser_constraint'
  mount Sidekiq::Web => '/sidekiq', constraints: SuperuserConstraint.new

  #####################################################################
  # Custom Routes for projects
  #####################################################################

  #####################################################################
  # Custom Routes for projects
  #####################################################################
end
