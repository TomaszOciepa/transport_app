class OrderDriver < ApplicationRecord
  belongs_to :order
  belongs_to :driver
  belongs_to :user

  validates :driver_id, :order_id, :user_id, presence: true
  validate :driver_must_be_available

  before_create :unset_previous_current

  private

  def unset_previous_current
    if current
      order.order_drivers.where(current: true).update_all(current: false)
    end
  end

  def driver_must_be_available
    unless driver.available_for?(order)
      errors.add(:driver, "nie jest dostępny w okresie tego zamówienia")
    end
  end

end
