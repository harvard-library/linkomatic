class CreateDigitizations < ActiveRecord::Migration
  def change
    create_table :digitizations do |t|
      t.references :component, index: true
      t.references :setting, index: true
      t.string :urn, index: true
      t.integer :position

      t.timestamps
    end
  end
end
