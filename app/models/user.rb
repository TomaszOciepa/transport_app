class User < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :vehicle_drivers, dependent: :nullify
  has_many :assigned_vehicle_drivers, class_name: "VehicleDriver"
  has_many :whatsapp_conversations, dependent: :destroy
  has_one :whatsapp_session, dependent: :destroy

  enum :role, [ :client, :dispatcher, :admin ]

  after_initialize :set_default_role, if: :new_record?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  private

  def set_default_role
    self.role ||= :client
  end
end
