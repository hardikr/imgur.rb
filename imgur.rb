require 'rubygems'
require 'oauth'
require 'json'

IM_DIR = "#{ENV['HOME']}/.img"
AUTH_FILE = IM_DIR+"/auth"
OAUTH_FILE = IM_DIR+"/oauth"

IMGUR_URL = 'https://api.imgur.com'

def load_auth()
	if !File.exist?(AUTH_FILE)
		puts "Looks like you need to setup your Imgur credentials. "
		puts "Enter your Imgur Key:"
		gr_key = gets
		puts "Enter your Imgur Secret"
		gr_secret = gets
		config_file = File.new(AUTH_FILE, "w")
		config_file.puts(gr_key)
		config_file.puts(gr_secret)
		config_file.close()
		return [gr_key.strip!,gr_secret.strip!]
	else
		return File.read(AUTH_FILE).split("\n")
	end
end

def load_oauth_token(consumer)
	if !File.exist?(OAUTH_FILE)
		request_token = consumer.get_request_token
		puts "Please visit this URL and authorize yourself. After that, come back and press Enter(return)"
		puts request_token.authorize_url

		gets

		access_token = request_token.get_access_token
		puts access_token.inspect
		
		File.open(OAUTH_FILE,'w') do |file|
			Marshal.dump(access_token, file)
		end

		return access_token
	else
		return File.open(OAUTH_FILE) do |file|
			Marshal.load(file)
		end
	end
end

Dir::mkdir(IM_DIR) if !File.directory?(IM_DIR)

imgur_key,imgur_secret = load_auth

consumer = OAuth::Consumer.new(imgur_key, 
                               imgur_secret, 
                               :site => IMGUR_URL,
                               :request_token_path => IMGUR_URL+"/oauth/request_token",
                               :authorize_path => IMGUR_URL+ "/oauth/authorize",
                               :access_token_path  => IMGUR_URL+'/oauth/access_token')

access_token = load_oauth_token(consumer)

response = access_token.get('/2/account/albums.json')

doc = JSON.parse(response.body)

puts doc