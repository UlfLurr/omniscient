class AccountActivation < ActiveRecord::Base
	validates :token,  presence: true
	validates :email,  presence: true
	validates :user_id,  presence: true

	def get_token
    	return @token_string + '|' + self.id.to_s           #you can encrypt here
	end
	def init_token
		token = AccountActivation.new_token
		self.token = self.hash_token(token)
		@token_string = token 
	end
	def self.find_token(token)
		parsed = token.rpartition('|')                      #and decrypt here
		aa = AccountActivation.find_by(id: parsed[-1])
		p aa.token
		p parsed[0]
		p aa.hash_token(parsed[0])
		return aa if aa and aa.token == aa.hash_token(parsed[0])	
		return nil
	end
	def self.new_token
		return SecureRandom.urlsafe_base64;
	end
	def hash_token(token)
		digest = OpenSSL::Digest.new('sha256')
		return OpenSSL::HMAC.digest(digest, email, token).unpack('H*')[0]
	end
end
