class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    @users = User.all.order(:username)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.expect(user: [:username, :email, :password])
  end
end
