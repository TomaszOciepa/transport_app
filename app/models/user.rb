class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  
  enum :role, [ :client, :dispatcher, :admin ]
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
