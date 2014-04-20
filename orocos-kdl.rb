require 'formula'

class OrocosKdl < Formula
  # Attribution: https://github.com/adzenith/homebrew-science
  # Recipe modified from source above
  homepage 'http://www.orocos.org/kdl'
  head "https://github.com/orocos/orocos_kinematics_dynamics.git"

  option 'with-check', 'Enable build-time checking'

  depends_on 'eigen'
  depends_on 'cmake' => :build
  depends_on 'cppunit' => :build if build.with? 'check'

  def install
    cd 'orocos_kdl'

    # Set up cmake args
    args = std_cmake_args
    args << '-DENABLE_TESTS=ON' if build.with? 'check'
    args << '.'

    system 'cmake', *args
    system 'make'
    system 'make check' if build.with? 'check'
    system 'make install'
  end
end
