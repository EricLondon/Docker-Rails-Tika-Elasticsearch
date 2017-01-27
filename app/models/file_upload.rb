class FileUpload < ApplicationRecord
  include Elasticsearch::Model

  after_commit :process_document
  attr_accessor :document_content
  has_attached_file :document
  validates :document, attachment_presence: true
  validates_attachment_content_type :document, content_type: 'application/pdf'

  mapping do
    indexes :document_content, type: 'multi_field' do
      indexes :document_content
      indexes :raw, index: :no
    end
  end

  def as_indexed_json(options={})
    as_json.merge(document_content: document_content)
  end

  def from_elasticsearch
    search_definition = {
      query: {
        filtered: {
          filter: {
            term: {
              _id: id
            }
          }
        }
      }
    }
    begin
      self.class.__elasticsearch__.search(search_definition).first._source
    rescue => e
      retry
    end
  end

  def set_document_content
    self.document_content = document_content_from_tika
    __elasticsearch__.index_document
  end

  def document_content_from_elasticsearch
    from_elasticsearch[:document_content]
  end

  def document_content_from_tika
    meta_data = JSON.parse(`curl -H "Accept: application/json" -T "#{document.path}" http://#{ENV['TIKA_HOST']}:9998/meta`)
    `curl -X PUT --data-binary "@#{document.path}" --header "Content-type: #{meta_data['Content-Type']}" http://#{ENV['TIKA_HOST']}:9998/tika --header "Accept: text/plain"`.strip
  end

  private

  def process_document
    DocumentProcessorJob.perform_later self
  end
end
