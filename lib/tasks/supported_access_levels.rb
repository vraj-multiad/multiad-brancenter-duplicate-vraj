def create_supported_access_levels
  supported_access_levels.each do |access_level|
    AccessLevel.find_or_create_by(access_level)
  end
end

def supported_access_levels
  supported_access = []
  (0..5).each do |access|
    supported_access << { name: "level #{access}", title: "level #{access}", parent_access_level_id: nil }
  end
  supported_access
end
