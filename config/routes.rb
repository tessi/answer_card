Rails.application.routes.draw do
  namespace 'admin' do
    resources :cards
  end

  get   ':uuid' => 'cards#edit',   as: 'card'
  patch ':uuid' => 'cards#update', as: 'update_card'
  put   ':uuid' => 'cards#update'

  root 'admin/cards#index'
end
