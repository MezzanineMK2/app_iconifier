require_relative 'app_iconifier/asset_maker.rb'

class AppIconifier
  def self.make_icons(source_image, destination, settings = {})
    raise "Source image not found: #{source_image}" unless File.exist? source_image
    IconMaker.new(source_image, destination).generate_set(settings)
  end

  def self.make_splash_screens(source_image, destination, settings)
    raise "Source image not found: #{source_image}" unless File.exist? source_image

  end
end