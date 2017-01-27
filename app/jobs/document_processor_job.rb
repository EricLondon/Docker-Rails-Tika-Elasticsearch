class DocumentProcessorJob < ApplicationJob
  queue_as :default

  def perform(file_upload)
    file_upload.set_document_content
  end
end
