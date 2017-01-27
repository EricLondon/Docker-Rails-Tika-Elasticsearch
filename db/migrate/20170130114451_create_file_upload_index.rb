class CreateFileUploadIndex < ActiveRecord::Migration[5.0]
  def change
    FileUpload.__elasticsearch__.create_index! force: true
  end
end
