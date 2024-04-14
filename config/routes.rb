Rails.application.routes.draw do
  get '/instant', to: 'tests#instant'
  get '/blocking', to: 'tests#blocking'
end
