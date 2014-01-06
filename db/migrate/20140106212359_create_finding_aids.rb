class CreateFindingAids < ActiveRecord::Migration
  def change
    create_table :finding_aids do |t|
      t.references :owner, index: true
      t.references :project, index: true
      t.string :url
      t.string :name
      t.references :settings, index: true

      t.timestamps
    end
  end
end
