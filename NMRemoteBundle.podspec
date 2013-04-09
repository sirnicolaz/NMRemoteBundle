Pod::Spec.new do |s|
  s.name         = 'NMRemoteBundle'
  s.version      = '1.0.0'
  s.summary      = 'NSBundle category that handles dinamically loaded remote bundles.'
  s.author = {
    'Nicola Miotto' => 'sirnicolaz@gmail.com'
  }
  s.source = {
    :git => 'https://github.com/sirnicolaz/NMRemoteBundle.git',
    :tag => '1.0.0'
  }
  s.license      = { 
     :type => 'New BSD License', 
     :file => 'LICENSE.markdown'
  }
  s.source_files = 'NMRemoteBundle/Classes/*.{h,m}'
  s.homepage     = 'https://github.com/sirnicolaz/NMRemoteBundle'
  s.dependency     'SSZipArchive'
  s.requires_arc = true
end
