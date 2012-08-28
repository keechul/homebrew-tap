require 'formula'

class WithReadline < Formula
  homepage 'http://www.greenend.org.uk/rjk/sw/withreadline.html'
  url 'http://www.greenend.org.uk/rjk/sw/with-readline-0.1.tar.bz2'
  sha1 '9e75a51717ac2d0d9c377299c9e28b11f5250d84'

  depends_on 'readline'

  def install
    readline = Formula.factory 'readline'
    system "./configure", "--prefix=#{prefix}", "LDFLAGS=-L#{readline.lib}",
                          "CFLAGS=-I#{readline.include}", "--mandir=#{man}"
    system "make"
    system "make install"
  end

end
