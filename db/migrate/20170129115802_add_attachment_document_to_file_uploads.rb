class AddAttachmentDocumentToFileUploads < ActiveRecord::Migration
  def self.up
    change_table :file_uploads do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :file_uploads, :document
  end
end
