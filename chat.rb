
require 'sinatra/base'
require 'erb'
require 'mongo'
require 'json'
include Mongo


                
def connected
	puts session[:id]
	puts session[:user]
	if session[:id].nil?
		puts "not connected"  		
		return 0
	else
		puts "connected"
		return 1
	end
end

# basic authentication from uri
def connectiondb
	uri    = 'mongodb://test:test@ds045521.mongolab.com:45521/ruby_project'
	client = MongoClient.from_uri(uri)
	db     = client['ruby_project']
	return db
end

def recupmessages
	db=connectiondb
	coll = db.collection("messages")
	messages = coll.find
	return messages
end

def insererMsg(message,idauthor,auteur)
	db =connectiondb
	coll = db.collection("messages")
	doc = {"message" => message,"auteur" => auteur ,"idauthor" => idauthor, "date" => Time.now.strftime("%d/%m/%Y %H:%M")}
	id = coll.insert(doc)
	return id
end

def recupuser(name)
	db=connectiondb
	coll = db.collection("users")
	user = coll.find( { "user" => name } )
	return user
end

def connection(user,passwd)
	user_data=recupuser(user)
	count=user_data.count
	
	if count == 1
		
		user_data.each { |user| session[:id]=user["_id"]; session[:user]=user["user"]}
		puts session[:id]
		puts session[:user]
	end
end

#****************************************************

class MyApp < Sinatra::Base
	get '/' do
		if connected == 0
	    		erb :login
		else
			@messages = recupmessages
			erb :chat
		end
	end
	
	

	get '/chat' do
		if connected == 0
			erb :login
		else
			@messages = recupmessages
	    		erb :chat
		end 
	end

	post '/chat/insertMessage' do
		if connected == 0
			redirect "/"
		else	 
			message = params[:message] 
		        idauthor = session[:id]
			auteur = session[:user]
			insererMsg(message,idauthor,auteur)
			@status = "message insert"
			@messages = recupmessages
			redirect "/chat"
		end 
  	end

	post '/connection' do
		if !params[:user].nil?		
			user = params[:user]
			password = params[:password]
			connection(user,password)
		end
		if connected == 0
			redirect "/"
		else	 
			@messages = recupmessages
			redirect "/chat"
		end 	
		
	end

	post '/disconnect' do
		session.clear
		redirect "/"
	end
	
	post '/refresh' do
		redirect "/chat"
	end

	get '/*' do
		redirect '/'
	end
	
end
