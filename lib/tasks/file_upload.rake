namespace :file_upload do
  desc "File upload test"
  task test: :environment do
    file_upload = FileUpload.new
    file = File.open Rails.root.join('eric-london-blog.pdf')
    file_upload.document = file
    file_upload.save!
    puts file_upload.document_content_from_elasticsearch
  end
end
