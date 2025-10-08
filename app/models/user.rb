class User < ApplicationRecord
  has_many :orders, dependent: :destroy
  
  enum :role, [ :client, :dispatcher, :admin ]
  
  after_initialize :set_default_role, if: :new_record?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  private

  def set_default_role
    self.role ||= :client
  end
end
