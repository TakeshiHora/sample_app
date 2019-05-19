class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update,:destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy]

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    #debugger
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  #GET /users/new
  def new
    @user = User.new
    render "new"
  end
  
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render "new"
    end
  end
  
  #GET /users/:id/edit
  #params[:id] => :id
  def edit
    @user = User.find(params[:id])
    # => @user.errors.full_messages()
  end
  
   #PATCH /users/:id
  def update
    @user = User.find(params[:id])
    #@user.errors.full_messages()
     if @user.update_attributes(user_params)
      #success
        flash[:success] = "Profile updated"
        redirect_to @user
     else
      #Fail
       render 'edit'
     end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
   
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
  

    def correct_user
      @user = User.find(params[:id])
       redirect_to(root_url) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
