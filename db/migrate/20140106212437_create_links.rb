class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :finding_aid, index: true
      t.string :component_id
      t.string :urn
      t.integer :order
      t.references :settings, index: true

      t.timestamps
    end
  end
end
