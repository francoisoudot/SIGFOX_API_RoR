class CreateDevicetypes < ActiveRecord::Migration
  def change
    create_table :devicetypes do |t|
      t.string :device_id
      t.string :time
      t.string :data
      t.string :rssi
      t.string :signal

      t.timestamps
    end
  end
end
