# app/services/whatsapp/ensure_groups_for_vehicle.rb
module Whatsapp
  class EnsureGroupsForVehicle
    def self.call(order_vehicle:, dispatcher:)
      new(order_vehicle, dispatcher).call
    end

    def initialize(order_vehicle, dispatcher)
      @order_vehicle = order_vehicle
      @vehicle       = order_vehicle.vehicle
      @dispatcher    = dispatcher
      @driver        = vehicle.current_driver
    end

    def call
      return unless driver

      relevant_orders.find_each do |order|
        ensure_group_for(order)
      end
    end

    private

    attr_reader :order_vehicle, :vehicle, :driver, :dispatcher

    # -----------------------------------
    # Orders that need WhatsApp groups
    # -----------------------------------
    def relevant_orders
      vehicle
        .current_orders
        .where("pickup_date > ?", Time.current)
    end

    def ensure_group_for(order)
      return if group_exists?(order)

      group_id = create_whatsapp_group(order)
      create_conversation(order, group_id)
      send_welcome_message(order, group_id)
    rescue => e
      Rails.logger.error(
        "[WHATSAPP GROUP FAIL] order=#{order.id} driver=#{driver.id}"
      )
      Rails.logger.error(e.message)
    end

    def group_exists?(order)
      WhatsappConversation.exists?(
        order_id: order.id,
        driver_id: driver.id,
        chat_type: "group"
      )
    end

    # -----------------------------------
    # WhatsApp (Node)
    # -----------------------------------
    def create_whatsapp_group(order)
      # ensure WhatsApp session exists in Node
      Faraday.post(
        "http://localhost:3005/sessions/ensure",
        { user_id: dispatcher.id }.to_json,
        "Content-Type" => "application/json"
      )

      response = Faraday.post(
        "http://localhost:3005/groups/create_for_order",
        {
          user_id: dispatcher.id,
          group_name: group_name(order),
          participants: [ driver.phone ]
        }.to_json,
        "Content-Type" => "application/json"
      )

      unless response.success?
        Rails.logger.error("[WHATSAPP GROUP ERROR] status=#{response.status}")
        Rails.logger.error("[WHATSAPP GROUP ERROR] body=#{response.body}")
        raise "WhatsApp group create failed"
      end

      JSON.parse(response.body).fetch("group_id")
    end

    def send_welcome_message(order, group_id)
      Faraday.post(
        "http://localhost:3005/send_to_group",
        {
          user_id: dispatcher.id,
          group_id: group_id,
          message: welcome_message(order)
        }.to_json,
        "Content-Type" => "application/json"
      )
    end

    # -----------------------------------
    # Database
    # -----------------------------------
    def create_conversation(order, group_id)
      WhatsappConversation.create!(
        user_id: dispatcher.id,
        chat_type: "group",
        whatsapp_chat_id: group_id,
        order_id: order.id,
        driver_id: driver.id
      )
    end

    # -----------------------------------
    # Helpers
    # -----------------------------------
    def group_name(order)
      "Zamówienie #{order.order_number} – #{driver.full_name}"
    end

    def welcome_message(order)
      <<~MSG.strip
        👋 Witaj!
        Grupa WhatsApp dla zamówienia #{order.order_number}.

        🚚 Kierowca: #{driver.full_name}
        📍 Odbiór: #{order.pickup_place}
        📦 Dostawa: #{order.delivery_place}
      MSG
    end
  end
end
