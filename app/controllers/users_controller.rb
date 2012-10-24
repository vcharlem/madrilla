
class UsersController < ApplicationController
	before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end



	def create 

    # if we got here from the Salon maintenance page, (a salon
    # manager added a user), add the user to the salon and
    # redirect back to the salon
    if params[:salon_id]

      @salon = Salon.find(params[:salon_id])

      # check to see if this user already exists.
      @user = User.find_by_email(params[:user][:email])

      if @user
        @salon.users << @user
      else
        @user = @salon.users.build(params[:user])
        @user.password = 'password'
        @user.password_confirmation = 'password'
      end
      if @salon.save
        redirect_to @salon
        return
      end
    end

    # otherwise... we got here from the signup page. 
    # so, we probably aren't doing this right!
    @user = User.new(params[:user])

		if @user.save
			sign_in @user

      # send them a signup email
      UserNotifier.signedup(@user).deliver

			# everything is good. handle the success scenario
			flash[:success] = "Thanks for signing up for Madrilla!"
			redirect_to @user
		else
			render 'new'
		end
	end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed"
    redirect_to users_url
  end

	def show 
		@user = User.find(params[:id])
	end
	
  def new
  	@user = User.new
  end


  def edit
  end


  def update
  	if @user.update_attributes(params[:user])
  		flash[:success] = "Profile updated"
  		sign_in @user
  		redirect_to @user
  	else
  		render 'edit'
  	end
  end


  def confirm

    #logger.debug("User#confirm called")

    @user = User.find(params[:id])

    if @user && @user.confirmation_code == params[:confirmation_code]

      # logger.debug("Found the user and the confirmation code matches")

      @user.update_attribute(:confirmed, true)
      sign_in @user

      # logger.debug("update_attribute called but no error")
      
      render 'confirm'
    else
      redirect_to root_path
    end
  end

  private

  	def signed_in_user
      unless signed_in?
        store_location
  		  redirect_to signin_url, notice: "Please sign in."
      end
  	end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user) 
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

end
