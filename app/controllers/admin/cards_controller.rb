module Admin
  class CardsController < Admin::BaseController
    inherit_resources
    actions :all, only: [:index, :create, :destroy]

    def create
      create! { admin_cards_path }
    end

    def destroy
      destroy! { admin_cards_path }
    end

    protected

    def permitted_params
      params.permit(card: [:name])
    end
  end
end
