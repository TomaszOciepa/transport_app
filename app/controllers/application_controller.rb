class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  helper_method :active_whatsapp_conversation_id

  # Do NOT run this logic for mark_as_read
  before_action :store_active_whatsapp_conversation, unless: :mark_as_read_action?

  def active_whatsapp_conversation_id
    session[:active_whatsapp_conversation_id]
  end

  private

  # =========================
  # Active conversation state
  # =========================
  def store_active_whatsapp_conversation
    if controller_name == "messages"
      # WE ARE IN THE CHAT MODULE (index)

      if params[:conversation_id].present?
        session[:active_whatsapp_conversation_id] = params[:conversation_id].to_i
      end

      RequestStore.store[:active_whatsapp_conversation_id] =
        session[:active_whatsapp_conversation_id]
    else
      # OUT OF CHAT → NO ACTIVE CONVERSATION

      session[:active_whatsapp_conversation_id] = nil
      RequestStore.store[:active_whatsapp_conversation_id] = nil
    end
  end

  # =========================
  # Skip logic for POST /mark_as_read
  # =========================
  def mark_as_read_action?
    controller_name == "messages" && action_name == "mark_as_read"
  end

  # =========================
  # Errors
  # =========================
  def render_not_found
    render "errors/not_found", status: :not_found
  end
end
