class AddOwnerCodeToFindingAid < ActiveRecord::Migration
  def change
    add_column :finding_aids, :owner_code, :string
  end
end
