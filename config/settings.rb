erb = ERB.new(File.read("#{Rails.root}/config/settings.yml")).result
Settings = OpenStruct.new YAML.load(erb)[Rails.env]