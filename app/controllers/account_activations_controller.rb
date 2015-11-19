class AccountActivationsController < ApplicationController

	def create
		user = current_user
		UserMailer.account_activation(user.account_activation, user)
		flash[:notice] = 'Activation letter sent.'
		@user = user
		respond_to do |format|
	        format.js { render :json => { :html => render_to_string('_redirect'), redirect: true}, :content_type => 'text/json' }
	        format.html { redirect_to @user }
	    end
	end

	def activate
		aa = AccountActivation.find_token(params[:token])
		p aa
		puts aa
		if aa
			user = User.find_by(id: aa.user_id)
			p aa
			puts user
			if user
				user.update_attribute(:activated, true)
			end
			flash[:notice] = 'Account was successfully actvated.'
			@user = user
			respond_to do |format|
		        format.js { render :json => { :html => render_to_string('_notice'), redirect: false}, :content_type => 'text/json' }
		        format.html { redirect_to @user }
		    end
		else
			flash[:notice] = 'Activation failed.'
			respond_to do |format|
		        format.js { render :json => { :html => render_to_string('_notice'), redirect: false}, :content_type => 'text/json' }
		        format.html { redirect_to root_url }
		    end

		end
	end
end
