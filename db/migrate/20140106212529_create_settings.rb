class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :link_text
      t.references :template
      t.string :thumbnail_url
      t.string :owner_code

      t.timestamps
    end
  end
end
