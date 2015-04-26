class CardsController < ApplicationController
  inherit_resources
  actions :edit, :update

  def update
    update! do
      if resource.valid?
        flash[:notice] = "Das Speichern war erfolgreich!"
      else
        flash[:error] = "Es gab einen Fehler. Überprüfe bitte deine Eingaben!"
      end

      card_path(uuid: resource.uuid)
    end
  end

  protected

  def resource
    get_resource_ivar || set_resource_ivar(end_of_association_chain.find_by_uuid(params[:uuid]))
  end

  def permitted_params
    params.permit(card: [:name, :can_come, :people_count, :need_room, :room_start_date, :room_end_date, :notes])
  end
end
