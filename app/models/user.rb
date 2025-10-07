class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  
  enum :role, [ :client, :dispatcher, :admin ]
  
  after_initialize :set_default_role, if: :new_record?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  private

  def set_default_role
    self.role ||= :client
  end
end
