# require Rails.root.join('spec','seeder.rb')
require 'rubygems'           #so it can load gems
require 'factory_girl_rails' #so it can run in development
require 'csv'

text1 = AcText.create(
  :name => 'replace_all',
  :title => 'Replace Text',
  # :set_attributes => '',
  # :responds_to_attributes => '',
  :creator => '__text__',
  :html => '__text__')


text1 = AcText.create(
  :name => 'contact_information_4_line',
  :title => 'Address',
  # :set_attributes => '',
  # :responds_to_attributes => '',
  :creator => '__title__\n__address_1__\n__city__, __state__  __zip_code__\n__url__',
  :html => '__title__<br/>__address_1__<br/>__city__, __state__, __zip_code__<br/>__url__')
  
text1 = AcText.create(
  :name => 'contact_4_line',
  :title => 'Address',
  # :set_attributes => '',
  # :responds_to_attributes => '',
  :creator => '__$title__\n__$address_1__\n__$city__, __$state__  __$zip_code__\n__$url__',
  :html => '__$title__<br/>__$address_1__<br/>__$city__, __$state__, __$zip_code__<br/>__$url__')

  
search = KeywordType.create(
  :name => 'search',
  :title => 'Search',
  :label => 'Search Keywords',
)  
media_type = KeywordType.create(
  :name => 'media_type',
  :title => 'Media Type',
  :label => 'Media Type Filters',
)  
topic = KeywordType.create(
  :name => 'topic',
  :title => 'Topic',
  :label => 'Topic Filters',
)  


