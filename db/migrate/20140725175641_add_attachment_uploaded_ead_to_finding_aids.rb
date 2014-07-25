class AddAttachmentUploadedEadToFindingAids < ActiveRecord::Migration
  def self.up
    change_table :finding_aids do |t|
      t.attachment :uploaded_ead
    end
  end

  def self.down
    remove_attachment :finding_aids, :uploaded_ead
  end
end
