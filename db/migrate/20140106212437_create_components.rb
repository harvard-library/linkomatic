class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.references :finding_aid, index: true
      t.references :setting, index: true

      t.string :cid
      t.text :name

      t.timestamps
    end
  end
end
