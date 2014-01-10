class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :setting, index: true

      t.timestamps
    end
  end
end
