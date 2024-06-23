Pod::Spec.new do |s|
    s.name = 'unihub'
    s.version = '1.0.0'
    s.summary          = 'UniHub mac project'
    s.description      = <<-DESC
    Unihub mac binary container.
                           DESC
    s.homepage         = 'http://example.com'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'UniControlHub' => 'email@example.com' }
    s.source           = { :path => '.' }
    s.source_files     = 'Classes/**/*'

    # place all binaries here
    s.vendored_libraries = 'libusb.dylib'
end