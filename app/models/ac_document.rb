# == Schema Information
#
# Table name: ac_documents
#
#  id                :integer          not null, primary key
#  bundle            :string(255)
#  document_spec_xml :text
#  pdf               :string(255)
#  preview           :string(255)
#  status            :text
#  thumbnail         :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  png               :string(255)
#  jpg               :string(255)
#  eps               :string(255)
#  bleed_pdf         :string(255)
#

# class AcDocument < ActiveRecord::Base
class AcDocument < ActiveRecord::Base
  has_many :ac_session_histories

  def thumbnail_url
    SECURE_BASE_URL + thumbnail
  end

  def preview_url
    SECURE_BASE_URL + preview
    # SECURE_BASE_URL + self.thumbnail
  end

  def load_document_spec_xml
    return document_spec_xml unless document_spec_xml.match('p.json')
    xml_uri = URI(AC_BASE_URL + document_spec_xml)
    xml_response = Net::HTTP.get(xml_uri)
    self.document_spec_xml = xml_response
    save
    document_spec_xml
  end
end
