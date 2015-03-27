class SigfoxController < ApplicationController
  def index
  	@devicetype=Devicetype.all
  end

  def devicetype
   Devicetype.create(
   	:device_id=>params['id'],
   	:time=>params['time'],
   	:data=>params['data'],
   	:rssi=>params['rssi'],
   	:signal=>params['signal'])
  end
end
