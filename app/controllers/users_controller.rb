class UsersController < ApplicationController
  def init
  	@publickey = User.key
  	@salt = User.salt
  	@user_errors = []
  end


  def new
  	init
  end

  def create
  	init
  	decrypted=["","",""]
  	begin
  	  	decrypted = User.decrypt(params[:password]).rpartition('|')
  	  	@decryption_failed = false
  	rescue
  		@decryption_failed = true
  		puts "Error #{$!}"
  	end
  	err = @decryption_failed

  	@name = params[:name].squish()
  	#@username_empty = @name.
  	
  	@email = params[:email].squish()
  	
  	user = User.new(name: @name, email: @email, password_digest: decrypted[0])
  	@user = user

    unless @name_empty = !user.has_name?
    	@name_too_short = !user.long_enough_name?
    	@name_too_long = !user.short_enough_name?
    	unless @name_too_short or @username_too_long
	    	unless @name_invalid = !user.valid_name?
	          	@name_taken = !user.unique_name?
	        end
        end
    end
    err ||= (@username_empty || @username_too_short || @username_too_long || @username_taken || @name_invalid)

  	unless @email_empty = !user.has_email?
  		unless @email_too_long = !user.short_enough_email?
		  	unless @email_invalid = !user.valid_email?
		  	  	@email_taken = !user.unique_email?
		  	end
  	  	end
  	end

  	err ||= (@email_empty || @email_too_long ||  @email_invalid || @email_taken)

	unless @decryption_failed
	  	@password_empty = user.has_pass?(decrypted[-1])
	  	@doublepost = !User.checksalt(decrypted[-1])
	end

  	err ||= (@doublepost || @password_empty)

  	unless err
  	  	
  	  	if user.valid?
  	  	  	user.pseudosave
  	  	else
  	  		@user_errors = user.errors
  	  	end
  	end

  	render '_form', :layout => false
  end
end
