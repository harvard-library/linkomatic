class CreateFindingAids < ActiveRecord::Migration
  def change
    create_table :finding_aids do |t|
      t.references :owner, index: true
      t.references :project, index: true
      t.string :url
      t.text :name
      t.text :urn_fetch_jobs
      t.references :setting, index: true

      t.timestamps
    end
  end
end
