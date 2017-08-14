require 'fileutils'
require 'mini_magick'
require 'chunky_png'
require_relative 'zip_file_generator.rb'

class AssetMaker
  attr_accessor :source_image
  attr_accessor :destination
  attr_accessor :working_dir
  attr_accessor :existing_background

  def initialize(source_image, destination)
    @source_image = File.expand_path source_image
    @destination = File.expand_path destination

    chunky_image = ChunkyPNG::Image.from_file(@source_image)
    red = (chunky_image[0, 0] & 0xff000000) >> 24
    green = (chunky_image[0, 0] & 0x00ff0000) >> 16
    blue = (chunky_image[0, 0] & 0x0000ff00) >> 8
    alpha = (chunky_image[0, 0] & 0x000000ff)
    @existing_background = '#' + ([red, green, blue, alpha].map {|c| c.to_s(16).upcase.rjust(2, '0') }).join
  end

  def prepare_working_dir
    if @destination.end_with? '.zip'
      @working_dir = File.expand_path "app_iconifier_#{Time.now.strftime('%Y%m%d%H%M%S%L')}"
      Dir.mkdir @working_dir
    elsif !File.exist? @destination
      @working_dir = File.expand_path @destination
      Dir.mkdir @working_dir
    else
      @working_dir = File.expand_path @destination
    end
  end

  def transparent?
    !@existing_background.end_with? "FF"
  end

  def write_splash(source_file, width, height, destination_file)
    image = MiniMagick::Image.open(source_file)
    top_left_pixel = image.get_pixels[0][0]
    bgcolor = pixel_rgb_to_hex(top_left_pixel)
    image.combine_options do |b|
      b.resize("#{width}x#{width}")
      b.background(bgcolor)
      b.gravity("center")
      b.extent("#{width+10}x#{height+10}")
    end
    image.write(destination_file)
  end

  def background_image(background, width, height)
    image = MiniMagick::Image.open File.join(File.dirname(File.expand_path(__FILE__)), 'transparent.png')
    image.combine_options do |b|
      b.background background
      b.extent "#{width}x#{height}"
    end
  end

  def generate_image(file, background)
    filename = file[:filename]
    width = file[:width]
    height = file[:height] || width
    dirname = File.dirname(File.expand_path(filename))
    FileUtils.mkpath dirname unless File.exist? dirname
    image = MiniMagick::Image.open @source_image
    # aspectFit (either perfect fit, or margin)
    if width == height and background
      # icon must make colored background with a background image
      image.combine_options do |b|
        b.resize "#{width}x#{width}"
        b.background background
        b.gravity 'center'
        b.extent "#{width}x#{height}"
      end
      result = background_image(background, width, height).composite(image) do |c|
        c.compose "Over"    # OverCompositeOp
        c.geometry "+0+0" # copy second_image onto first_image from (20, 20)
      end
      result.write filename
    else
      # either it's a splash screen, or there's no background
      image.combine_options do |b|
        b.resize "#{width}x#{width}"
        b.background background
        b.gravity 'center'
        b.extent "#{width}x#{height}"
      end
      image.write filename
    end
  end
end

class IconMaker < AssetMaker
  def ios_artwork_files
    [
        {filename: 'ios/iTunesArtwork@1x.png', width: 512},
        {filename: 'ios/iTunesArtwork@2x.png', width: 1024},
        {filename: 'ios/iTunesArtwork@3x.png', width: 1536},
    ]
  end

  def ios_icon_files
    [
        {filename: 'ios/AppIcon.appiconset/Icon-App-20x20@2x.png', width: 40},
        {filename: 'ios/AppIcon.appiconset/Icon-App-20x20@3x.png', width: 60},
        {filename: 'ios/AppIcon.appiconset/Icon-App-29x29@1x.png', width: 29},
        {filename: 'ios/AppIcon.appiconset/Icon-App-29x29@2x.png', width: 58},
        {filename: 'ios/AppIcon.appiconset/Icon-App-29x29@3x.png', width: 87},
        {filename: 'ios/AppIcon.appiconset/Icon-App-40x40@1x.png', width: 40},
        {filename: 'ios/AppIcon.appiconset/Icon-App-40x40@2x.png', width: 80},
        {filename: 'ios/AppIcon.appiconset/Icon-App-40x40@3x.png', width: 120},
        {filename: 'ios/AppIcon.appiconset/Icon-App-57x57@1x.png', width: 57},
        {filename: 'ios/AppIcon.appiconset/Icon-App-57x57@2x.png', width: 114},
        {filename: 'ios/AppIcon.appiconset/Icon-App-60x60@1x.png', width: 60},
        {filename: 'ios/AppIcon.appiconset/Icon-App-60x60@2x.png', width: 120},
        {filename: 'ios/AppIcon.appiconset/Icon-App-60x60@3x.png', width: 180},
        {filename: 'ios/AppIcon.appiconset/Icon-App-76x76@1x.png', width: 76},
        {filename: 'ios/AppIcon.appiconset/Icon-App-20x20@1x.png', width: 20},
        {filename: 'ios/AppIcon.appiconset/Icon-App-20x20@2x.png', width: 40},
        {filename: 'ios/AppIcon.appiconset/Icon-App-29x29@1x.png', width: 29},
        {filename: 'ios/AppIcon.appiconset/Icon-App-29x29@2x.png', width: 58},
        {filename: 'ios/AppIcon.appiconset/Icon-App-40x40@1x.png', width: 40},
        {filename: 'ios/AppIcon.appiconset/Icon-App-40x40@2x.png', width: 80},
        {filename: 'ios/AppIcon.appiconset/Icon-Small-50x50@1x.png', width: 50},
        {filename: 'ios/AppIcon.appiconset/Icon-Small-50x50@2x.png', width: 100},
        {filename: 'ios/AppIcon.appiconset/Icon-App-72x72@1x.png', width: 72},
        {filename: 'ios/AppIcon.appiconset/Icon-App-72x72@2x.png', width: 144},
        {filename: 'ios/AppIcon.appiconset/Icon-App-76x76@1x.png', width: 76},
        {filename: 'ios/AppIcon.appiconset/Icon-App-76x76@2x.png', width: 152},
        {filename: 'ios/AppIcon.appiconset/Icon-App-76x76@3x.png', width: 228},
        {filename: 'ios/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png', width: 167}
    ]
  end

  def android_icon_files
    [
        {filename: 'android/mipmap-ldpi/ic_launcher.png', width: 36},
        {filename: 'android/mipmap-mdpi/ic_launcher.png', width: 48},
        {filename: 'android/mipmap-hdpi/ic_launcher.png', width: 72},
        {filename: 'android/mipmap-xhdpi/ic_launcher.png', width: 96},
        {filename: 'android/mipmap-xxhdpi/ic_launcher.png', width: 144},
        {filename: 'android/mipmap-xxxhdpi/ic_launcher.png', width: 192}
    ]
  end

  def android_playstore_file
    {filename: 'android/playstore-icon.png', width: 512}
  end

  def generate_set(settings)
    prepare_working_dir

    ios = 'android'.casecmp(settings[:os] || 'all') != 0
    android = 'ios'.casecmp(settings[:os] || 'all') != 0

    desired_background = settings[:background] if /^#([A-Fa-f0-9]{8}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.match settings[:background]

    Dir.chdir @working_dir do
      if ios
        background = desired_background
        if background.nil?
          background = transparent? ? '#FFFFFF' : @existing_background
        end
        (ios_artwork_files + ios_icon_files).each do |file|
          generate_image file, background
        end
      end
      if android
        background = desired_background || @existing_background
        ([android_playstore_file] + android_icon_files).each do |file|
          generate_image file, background
        end
      end
    end
    if @destination.end_with? '.zip'
      puts "writing output to #{@destination}"
      ZipFileGenerator.new(@working_dir, @destination).write
      FileUtils.rm_rf @working_dir
    end
    @destination
  end
end