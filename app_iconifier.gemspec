Gem::Specification.new do |s|
  s.name                    = 'app_iconifier'
  s.version                 = '0.0.1'
  s.date                    = '2017-08-12'
  s.summary                 = 'App Iconifier'
  s.description             = 'A gem to generate iOS and Android app icons and splash screens from source images!'
  s.authors                 = ['Alex Kelly']
  s.email                   = 'mezzanine.us@gmail.com'
  s.files                   = ['lib/app_iconifier.rb']
  s.homepage                = 'https://github.com/MezzanineMK2/app_iconifier'
  s.license                 = 'MIT'
  s.add_runtime_dependency  'mini_magick', '>= 4.8.0'
end