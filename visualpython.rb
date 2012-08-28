require 'formula'

class Visualpython < Formula
  homepage 'http://www.vpython.org/'
  url 'http://www.vpython.org/contents/download/visual-5.74_release.tar.bz2'
  sha1 'd658166f681e66c2a412a9e8a7f6b6a8476884f3'

  depends_on :x11  # if your formula requires any X11/XQuartz components
  depends_on 'boost'
  depends_on 'gtkglextmm'
  depends_on 'libglademm'
  depends_on 'autoconf'

  # convert makefile from DOS (CRLF) to UNIX (LF) to apply patch
  #  remove the Fink hard path
  #  set dynamic multi-threaded boost libs
  def patches
    system "cp src/Makefile.in src/Makefile.in.dos"
    system "tr -d '\r' <src/Makefile.in.dos> src/Makefile.in"
    DATA
  end

  # see Visual Python mailing list for manual compilation
  # http://sourceforge.net/mailarchive/message.php?msg_id=29670266

  def install

    ENV.append 'LDFLAGS', '-framework OpenGL'

    # This code was adapted from the VTK and OpenCV formula and uses the output to
    # `python-config` to locate the Python lib
    python_prefix = `python-config --prefix`.strip
    # Python is actually a library. The libpythonX.Y.dylib points to this lib, too.
    if File.exist? "#{python_prefix}/Python"
      # Python was compiled with --framework:
      ENV.append 'LDFLAGS', "-L#{python_prefix}/lib -lpython2.7"
    else
      # ELSE BRANCH HAS NOT BEEN TESTED!!
      python_lib = "#{python_prefix}/lib/lib#{which_python}"
      if File.exists? "#{python_lib}.a"
        ENV.append 'LDFLAGS', "-L#{python_lib}.a"
      else
        ENV.append 'LDFLAGS', "-L#{python_lib}.dylib"
      end
    end

    args = [
       "--prefix=#{HOMEBREW_PREFIX}",
       "--disable-dependency-tracking"
      ]

    system "autoconf"
    system "./configure", *args
    system "make install"
  end

  def caveats; <<-EOS.undent
    The Visual Python module will not work until you edit your PYTHONPATH like so:
      export PYTHONPATH="#{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages:$PYTHONPATH"

    To make this permanent, put it in your shell's profile (e.g. ~/.profile or ~/.bash_profile).
    EOS
  end

  def test
    ENV.prepend 'PYTHONPATH', "#{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages", ':'
    system "python", "-c", %(from visual import *; sphere())
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end

__END__
diff --git a/src/Makefile.in b/src/Makefile.in
index c6d68e6..f140858 100644
--- a/src/Makefile.in
+++ b/src/Makefile.in
@@ -200,7 +200,8 @@ else
   ifeq ($(PYTHON_PLATFORM),darwin)
     # Special rules for OSX
     CVISUAL_LIBS += $(filter-out $(_FILTER_OUT), $(GTK_LIBS) \
-       $(GTHREAD_LIBS) /sw/lib/libboost_python-mt.a -lboost_thread-mt -lboost_signals)
+       $(GTHREAD_LIBS) -lboost_python-mt -lboost_thread-mt -lboost_signals-mt)
+       #$(GTHREAD_LIBS) /sw/lib/libboost_python-mt.a -lboost_thread-mt -lboost_signals)
     CXX_RULE = $(DEFAULT_CXX_RULE)
     LINK_RULE = $(OSX_SORULE)
     PLATFORM_TARGET = cvisualmodule.so

