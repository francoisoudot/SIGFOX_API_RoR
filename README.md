# SIGFOX_API_RoR
Integration of SIGFOX API uplink and downlink with Ruby on Rails

## 1. Introduction
SIGFOX - <http://sigfox.com/> - is the first and only company providing global cellular connectivity for the Internet of Things, fully dedicated to low-throughput communications. SIGFOX is re-inventing connectivity by radically lowering prices and energy consumption for connected devices.
Your device connects to SIGFOX network and the messages received are pushed to the customer’s backend through an API.

    device <---> base stations <---> SIGFOX cloud <---> your backend
 
The purpose of this turorial is to show a simple integration of the API in the case of a rails application.

## 2. SIGFOX API
You have to define the API callback on the SIGFOX backend for your device type.
Connect to the backend and go to device type. Select your device type and go in callbacks.  
Click on new – top right
 
For each message that you send through the SIGFOX network we will push an http request in the format that you describe in the field URL pattern.
For this tutorial we will use the following URL. 

    http://YOURURL/sigfox/devicetype?id={device}&time={time}&data={data}&rssi={rssi}&signal={signal}

Hint : For the moment YOURURL is not important we will change it later on after uploading our code on heroku.


## 3.	Create the rails app
You will need rails installed on your computer check <http://guides.rubyonrails.org/getting_started.html> to start with it.
In the terminal go to the directory you want to create the SIGFOX app and type

    $ sudo rails new SIGFOX_API

You will have to install the gems

    $ bundle install

Test that your app is can start before going further. Go in SIGFOX_API folder and launch the server:

    $ rails s

Open your internet browser and go to <http://localhost:3000/> - you should see the default rails starting page
 
Congratulations your rails app is working. Type Ctrl +C to stop the server.

##4. Create the Devicetype database
Each devicetype will be stored in a different database. So we will create the model in rails for a database:

    $ bin/rails generate model Devicetype device_id:string time:string data:string rssi:string signal:string

Then migrate the DB:

    $ rake db:migrate

## 5.	Create the SIGFOX controller
The squeleton of your app is created. Now we will generate the sigfox controller to handle the SIGFOX’s backend HTTP requests.

    $ sudo bin/rails generate controller sigfox index

Now we have a sigfox controller that will handle the HTTP requests and show them in the index view

In the routes rb file we have to route the SIGFOX’s API calls to our controller so add the following line

    get "sigfox/index"
    get "sigfox/devicetype" => "sigfox#devicetype "

Now in the controller you have to add the method to handle the HTTP requests from SIGFOX and store the values in your DB. Create this method in the SIGFOX controller.

    def devicetype
			Devicetype.create(
				:device_id=>params['id'],
				:time=>params['time'],
				:data=>params['data'],
				:rssi=>params['rssi'],
				:signal=>params['signal'])
    end

Congratulations, your platform is ready to receive and store the messages pushed by SIGFOX.


First you will have to create your account on heroku. Go to : <https://devcenter.heroku.com/start> and get started with the deployment of a Ruby app.
Make sure you changed your DB for Postgre before sending the app to heroku. To do this you have to modify the Gemfile to the following:

    # Use sqlite3 as the database for Active Record
    gem 'sqlite3',        group: :development

    # Use pg as the DB for heroku
    gem 'pg',        group: :production
    gem 'rails_12factor', group: :production

You will have to install the new gem

    $ bundle install

Then we will create the git

    cd SIGFOX_API
    $ git init
    $ git add .
    $ git commit –a -m "my first commit"

Then we will instanciate the heroku platform

    $ heroku create
    Creating murmuring-mountain-7957... done, stack is cedar-14
    https://murmuring-mountain-7957.herokuapp.com/ | git@heroku.com:murmuring-mountain-7957.git
    Git remote heroku added

The URL of the platform will be <https://murmuring-mountain-7957.herokuapp.com/> and we will have to modify the SIGFOX HTTP callback accordingly.
We will now push our git repository to heroku and create the DB

    $ git push heroku master
    $ heroku run rake db:migrate

We will now modify the URL on the backend to send the messages to our heroku platform:
Congratulations, you can start sending messages to your platform through SIGFOX. You can make sure that the messages are received by querying the DB:

    $ heroku pg:psql
    select * from devicetypes;
    
    \q to exit


##6. Display the SIGFOX’s messages
We will now display the SIGFOX’s messages on a web page. This is an optional part and deciding on implementing it will depend on your project.
First we will create the code in the controller. In sigfox_controller.rb add:

      def index
      	@devicetype=Devicetype.last(20)
      end
      
Note you can change the last 20 to another value. A too high value will slow down your page.
In the view in index.html.erb add the following code

        <h1>Sigfox#index</h1>

	<table style="width:90%" align="center">
		<thead>
		    <tr>
		        <th width="20%">Device id</th>
		        <th width="25%">Time SIGFOX</th>
		        <th width="25%">Time DB</th>
		        <th width="40%">Data</th>
		        <th width="10%">RSSI</th>
		        <th width="10%">SNR</th>
		    </tr>
		</thead>
		<tbody align="center">
		    <% @devicetype.each do |devicetype| %>
		    <tr>
		        <td>
					<%= devicetype.device_id %>
		        </td>
				<td>
					<%= devicetype.time %>
		        </td>
		        <td>
					<%= devicetype.created_at %>
		        </td>
		        <td>
					<%= devicetype.data %>
		        </td>
		        <td>
					<%= devicetype.rssi %>
		        </td>
		        <td>
					<%= devicetype.signal %>
		        </td>
		    </tr>
		    <% end %>
		</tbody>
	</table>
	<script type="text/javascript">
	var myVar=setInterval(function(){myTimer()},2000);
	function myTimer() {
	    location.reload();
	}
	</script>

The page will automatically reload every 2s to display the new messages. You can change the timer to whatever value that makes sense for your application.
Now in routes.rb, we will change the root of the app to our new view so add:

    root 'sigfox#index'

Congratulations, you just have to save, commit on git and push back to heroku your done:

    $ git commit -a -m "commit with view"
    $ git push heroku master

## 7. Downlink callback
The SIGFOX network can handle bi directional communication between your backend and the devices. In order to maintain the battery life of the wireless devices, the downlink communication has to be initiated by the device. The steps are the following:
1.	Device sends a message that requires an answer
2.	SIGFOX backend requires an answer to your backend 
3.	You backend answers to SIGFOX
4.	SIGFOX base station sends the answer to the device
The URL pushed will be similar but an acknowledgement value (true or false) will be added.
First, change the URL to:

    http://YOURURL/sigfox/devicetype?id={device}&time={time}&data={data}&rssi={rssi}&signal={signal}&ack={ack}

Next in the sigfox controller, we will add an if loop in the devicetype function to either answer to the downlink request initiated by the device or we will just acknowlege the message sent by the SIGFOX API :

    def devicetype
          
         device_id=params['id']

         Devicetype.create(
         	:device_id=>device_id,
         	:time=>params['time'],
         	:data=>params['data'],
         	:rssi=>params['rssi'],
         	:signal=>params['signal'])

         /JSON answer to the DL/

          if params['ack']=="true"
            /change the data to send back/
            render :json=>{
              device_id => { "downlinkData" => "deadbeefbabebabe"}
            }
          else
            render :json=>''
          end

      end

Congratulations you know can send back messages from your backend to your devices!

##Useful links
You can check SIGFOX @ <http://sigfox.com/>

You will find a very cool project of pet tracking – server side - using SIGFOX network @ <https://github.com/Ekito/hackerz-server>

You can check the python code to control your @ <https://github.com/francoisoudot/SIGFOX_KAP_PYTHON>




