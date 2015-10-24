class SessionsController < ApplicationController
    before_action :init_form

	def new
	end

   	def create
   		@user.name = user_params[:name].squish()

   		#TODO: DRY
	    if  user_params[:password_encrypted]
	    	begin
		  	  	d1 = User.decrypt(user_params[:password_encrypted])
		  	  	decrypted = d1.rpartition('|')
		  	  	@decryption_failed = false
	    	rescue
	    		@decryption_failed = true
	    	end
	    else
	      decrypted = [user.hash_pass(user_params[:password]),'|',params[:salt]]
	      @decryption_failed = false
	    end
	    
	    
		@doublepost = !User.checksalt(decrypted[-1]) unless @decryption_failed

		@success = !(@doublepost or @decryption_failed)
		if @success
	        user = User.find_by(downame: @user.name.downcase)
	        if user
		        if user.authenticate(decrypted[0])
		        	@user = user
		        else
		        	@password_invalid = true
		        end
	        else
	        	@name_unknown = true
	        end
		end
		@success = !(@password_invalid or @name_unknown)

	    if @success
	      respond_to do |format|
	      	log_in(@user)
	        format.js { render :json => { :html => render_to_string('users/_redirect'), redirect: true}, :content_type => 'text/json' }
	        format.html { redirect_to @user, notice: 'Login successfull.' }
	      end
	    else
	      respond_to do |format|
	        format.js { render :json => { :html => render_to_string('users/_form'), redirect: false}, :content_type => 'text/json' }
	        format.html { render :new }
	      end
	    end
	end

	private
	    def user_params
			params.require(:user).permit(:name, :password, :password_encrypted, :salt)
	    end
		def init_form
			@user = User.new
			@islogin = true
			@publickey = User.key
			@salt = User.salt
		end
end
