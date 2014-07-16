class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.text :body
      t.references :owner, index: true
      t.boolean :public

      t.timestamps
    end
  end
end
