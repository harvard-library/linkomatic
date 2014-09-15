class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :setting, index: true
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
