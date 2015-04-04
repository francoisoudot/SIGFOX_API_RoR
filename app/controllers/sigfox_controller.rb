class SigfoxController < ApplicationController
  def index
  	@devicetype=Devicetype.last(20)
  end

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
        device_id => { "downlinkData" => "deadbeefcafebabe"}
      }
    else
      render :json=>''
    end

  end
end
