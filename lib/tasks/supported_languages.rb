def create_supported_languages
  supported_languages.each do |language|
    Language.find_or_create_by(language)
  end
end

def supported_languages
  [
    { name: 'en', title: 'English' },
    { name: 'fr', title: 'Français' }
  ]
end
