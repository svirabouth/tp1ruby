
require 'sinatra/base'
require 'erb'
require 'mongo'
require 'json'
include Mongo



#Méthode qui vérifie si un utilisateur est connecté grâce au variable de session  
def connected
	puts session[:id]
	puts session[:user]
	#nil? pour tester si la variable est nul
	if session[:id].nil?
		puts "not connected"  		
		return 0
	else
		puts "connected"
		return 1
	end
end

# connection à la base de donnée mongo par uri
def connectiondb
	uri    = 'mongodb://test:test@ds045521.mongolab.com:45521/ruby_project'
	client = MongoClient.from_uri(uri)
	db     = client['ruby_project']
	return db
end

# méthode pour récuper ma collection de messages dans la bdd
def recupmessages
	db=connectiondb
	coll = db.collection("messages")
	messages = coll.find
	return messages
end

# méthode pour insérer un document dans la collection messages
def insererMsg(message,idauthor,auteur)
	db =connectiondb
	coll = db.collection("messages")
	#document au format BSON
	doc = {"message" => message,"auteur" => auteur ,"idauthor" => idauthor, "date" => Time.now.strftime("%d/%m/%Y %H:%M")}
	id = coll.insert(doc)
	return id
end

#méthode pour récupérer un user
def recupuser(name)
	db=connectiondb
	coll = db.collection("users")
	#find({condition)} => clause where
	user = coll.find( { "user" => name } )
	return user
end

def recupuser(name,password)
	db=connectiondb
	coll = db.collection("users")
	#find({condition)} => clause where

	user = coll.find("user" => name,"password" => password)
	puts name
	puts password
	return user
end


#méthode de connection et qui test sur l'user est en base
def connection(user,passwd)
	# ! oublie du test mot de passe
	#user_data=recupuser(user)
	user_data=recupuser(user,passwd)
	count=user_data.count
	
	if count == 1
		#si on trouve un user avec le mot de passe et le password qui matche, on les met en variable de session
		user_data.each { |user| session[:id]=user["_id"]; session[:user]=user["user"]}
		puts session[:id]
		puts session[:user]
		return 1
	else
		return 0
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
			@status = "username ou password incorrecte"
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

