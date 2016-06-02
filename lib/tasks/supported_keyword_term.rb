# KeywordTerm(id: integer, term: string, parent_term_id: integer, keyword_type: string, created_at: datetime, updated_at: datetime, term_count: integer, language_id: integer, access_level_id: integer)

def create_supported_keyword_term
  ['media_type', 'topic'].each do |keyword_type|
    Language.all.each do |language|
      AccessLevel.all.each do |access_level|
        supported_keyword_term.each do |keyword_terms_main|
          parent_keyword_term = KeywordTerm.find_or_create_by(term: keyword_terms_main[0], language_id: language.id, access_level_id: access_level.id, keyword_type: keyword_type)
          (1...keyword_terms_main.size).each do |keyword|
            KeywordTerm.find_or_create_by(term: keyword_terms_main[keyword], language_id: language.id, access_level_id: access_level.id, parent_term_id: parent_keyword_term.id, keyword_type: keyword_type)
          end
        end
      end
    end
  end
end

def supported_keyword_term
  prng = Random.new
  min_keywords = 2
  max_keywords = 10
  keyword_terms_main = [[]]
  (0...prng.rand(min_keywords..max_keywords)).each do
    keyword_terms_main = fetch_branch(keyword_terms_main)
  end
  keyword_terms_main
end

def remove_empty(keyword_terms)
  keywords = []
  keyword_terms.each do |keyword|
    keywords.push(keyword) unless keyword.empty?
  end
  keywords
end

def insert_unique(keyword_terms, keyword_terms_main)
  if keyword_terms_main.size > 0
    (0...keyword_terms.size).each do |delete|
      keyword_terms.delete_at(delete) if keyword_terms_main.include?(keyword_terms[delete])
    end
  end
  keyword_terms_main.push(remove_empty(keyword_terms))
  keyword_terms_main
end

def insert_spaces(keyword)
  random_number = Random.new
  area_of_insert = 2
  while keyword.size - 1 > area_of_insert
    replace_char = random_number.rand(2..keyword.size - 1)
    keyword.insert(replace_char, ' ')
    area_of_insert *= 2
  end
end

def fetch_branch(keyword_terms_main)
  random_number = Random.new
  keyword = ''
  keyword_terms = []
  (25...random_number.rand(50..100)).each do
    keyword = make_search_term
    insert_spaces(keyword)
    keyword_terms.push(keyword) unless keyword_terms.include?(keyword) && !keyword_terms.empty?
  end
  insert_unique(keyword_terms, keyword_terms_main)
end

def make_search_term
  random_number = Random.new
  (4..random_number.rand(8..20)).map { [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten[rand([('a'..'z'), ('A'..'Z')].map(&:to_a).flatten.length)] }.join
end
