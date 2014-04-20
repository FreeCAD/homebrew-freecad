require 'formula'

class OrocosKdl < Formula
  homepage 'http://www.orocos.org/kdl'
  head 'http://git.mech.kuleuven.be/robotics/orocos_kinematics_dynamics.git'
  url 'http://people.mech.kuleuven.be/~rsmits/kdl/orocos-kdl-1.0.2-src.tar.bz2'
  sha1 'dd06fe5bff8dfa1940fc80cd2b2f84ce25bea4e7'
  version '1.0.2'

  option 'with-check', 'Enable build-time checking (requires that cppunit was built with gcc)'

  if build.head?
    depends_on 'eigen'
  else
    depends_on 'eigen2'
    def patches
      DATA
    end
  end

  depends_on 'cmake' => :build
  depends_on 'cppunit' => :build if build.with? 'check'

  fails_with :clang do
    build 503
    cause <<-EOS.undent
      More information at this webpage:
      http://answers.ros.org/question/94771/building-ros-on-osx-109-solution/
      which says that a patch has been submitted upstream.
      EOS
  end

  def install
    if build.head?
      cd 'orocos_kdl'
      # Removes solvertest from orocos-kdl, as per
      # http://www.orocos.org/forum/rtt/rtt-dev/bug-1043-new-errors-underlying-ik-solver-are-not-correctly-processed
      inreplace 'tests/CMakeLists.txt', 'ADD_TEST(solvertest solvertest)', ''
    end

    mkdir 'build' do
      args = std_cmake_args
      args << '-DENABLE_TESTS=ON' if build.with? 'check'
      system 'cmake', '..', *args
      system 'make'
      system 'make check' if build.with? 'check'
      system 'make install'
    end
  end
end

__END__
diff --git i/config/FindEigen2.cmake w/config/FindEigen2.cmake
index 0050f19e..4f8313b2 100644
--- i/config/FindEigen2.cmake
+++ w/config/FindEigen2.cmake
@@ -1,4 +1,4 @@
-FIND_PATH(EIGEN2_INCLUDE_DIR Eigen/Core /usr/include /usr/include/eigen2)
+FIND_PATH(EIGEN2_INCLUDE_DIR Eigen/Core /usr/include /usr/include/eigen2 HOMEBREW_PREFIX/opt/eigen2/include/eigen2)
 IF ( EIGEN2_INCLUDE_DIR )
     MESSAGE(STATUS "-- Looking for Eigen2 - found")
     SET(KDL_CFLAGS "${KDL_CFLAGS} -I${EIGEN2_INCLUDE_DIR}" CACHE INTERNAL "")
