Pod::Spec.new do |s|
    s.name = 'iOSRichTextEditor'
    s.version = '0.0.27'
    s.summary = 'A RichTextEditor for iPhone & iPad.'
    s.homepage = 'https://github.com/stubma/iOSRichTextEditor'
    s.dependency 'WEPopover', '~> 1.0.0'
    s.license = {
      :type => 'MIT',
      :file => 'License.txt'
    }
    s.author = {'luma' => 'https://github.com/stubma/iOSRichTextEditor.git'}
    s.source = {:git => 'https://github.com/stubma/iOSRichTextEditor.git', :tag => s.version}
    s.platform = :ios, '10.0'
    s.source_files = 'RichTextEditor/Source/*.{h,m}','RichTextEditor/Source/Categories/*.{h,m}'
    s.resources = ['RichTextEditor/Source/Assets/**/*','RichTextEditor/Source/iphone Popover/**/*']
    s.framework = 'Foundation', 'UIKit'
    s.requires_arc = true
end
