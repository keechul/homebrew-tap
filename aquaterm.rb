require 'formula'

class Aquaterm < Formula
  homepage 'https://github.com/AquaTerm/AquaTerm'
  url 'https://github.com/AquaTerm/AquaTerm/tarball/tempv1.1.1a'
  md5 'a91bd7c6fc188fb33d2f1684eed600fd'
  version '1.1.1'

  head 'https://github.com/AquaTerm/AquaTerm.git', :using => :git

  def install
    apppath       = prefix + "Applications"
    frameworkpath = prefix + "Library/Frameworks"
    sharepath     = share  + "aquaterm"

    Dir.chdir('aquaterm') do
      # one can add
      # ARCHS="i386 x86_64" to environment to build universally
      system "xcodebuild", "-target", "AquaTerm", "-configuration", "Default", "LOCAL_FRAMEWORKS_DIR=#{frameworkpath}", "LOCAL_APPS_DIR=#{apppath}"

      apppath.install       'build/Default/AquaTerm.app'
      frameworkpath.install 'build/Default/AquaTerm.framework'
    end
    sharepath.install 'adapters'
  end

  def caveats
    # the same for AquaTerm.app?
    framework = prefix + "Library/Frameworks/AquaTerm.framework"
    if self.installed? and File.exists? framework
      return <<-EOS.undent
        AquaTerm.framework was installed to:
          #{framework}

        You may want to symlink this Framework to a standard OS X location,
        such as:
          ln -s "#{framework}" /Library/Frameworks
      EOS
    end
    return nil
  end
end
