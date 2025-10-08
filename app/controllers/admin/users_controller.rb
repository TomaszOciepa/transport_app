module Admin
    class UsersController < ApplicationController
      before_action :set_user, only: [:edit, :update, :destroy]
  
      def index
        @users = User.order(:email)
      end
  
      def edit
      end
  
      def update
        # nie próbujemy aktualizować hasła jeśli pola puste
        if params[:user][:password].blank?
          params[:user].delete(:password)
          params[:user].delete(:password_confirmation)
        end
  
        # zabezpieczenie: admin nie może odebrać sobie roli admin
        if @user == current_user && params[:user][:role].present? && params[:user][:role] != "admin"
          redirect_to admin_users_path, alert: "Nie możesz odebrać sobie roli administratora." and return
        end
  
        if @user.update(user_params)
          redirect_to admin_users_path, notice: "Użytkownik zaktualizowany."
        else
          render :edit, status: :unprocessable_entity
        end
      end
  
      def destroy
        # zabezpieczenie: nie usuwamy siebie
        if @user == current_user
          redirect_to admin_users_path, alert: "Nie możesz usunąć własnego konta przez panel admina." and return
        end
  
        # zabezpieczenie: nie usuwamy ostatniego admina
        if @user.admin? && User.admin.count <= 1
          redirect_to admin_users_path, alert: "Nie można usunąć ostatniego administratora." and return
        end
  
        @user.destroy
        redirect_to admin_users_path, notice: "Użytkownik usunięty."
      end
  
      private
  
      def set_user
        @user = User.find(params[:id])
      end
  
      def user_params
        params.require(:user).permit(:email, :role, :password, :password_confirmation)
      end
    end
  end
  