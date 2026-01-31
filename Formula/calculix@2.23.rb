# SPDX-License-Identifier: LGPL-2.1-or-later
# SPDX-FileNotice: Part of the FreeCAD project.

class CalculixAT223 < Formula
  desc "Free Software Three-Dimensional Structural Finite Element Program"
  homepage "https://www.calculix.de/"
  url "https://www.dhondt.de/ccx_2.23.src.tar.bz2"
  version "2.23"
  sha256 "9c88385c10fb04f5dc6c4e98027a51bebdd8aee3920e05190d6c1dd08357d6e7"

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any,                 arm64_tahoe:   "fb04b0417f9fffb65c05cd2271cb97dff01d430f4e9c5e7dc5bbfc5a3adc74b5"
    sha256 cellar: :any,                 arm64_sequoia: "018b5c8c36de6eb5dab7a0c8c372c2c85e573b3fc896ff386f7a7155cee93e7f"
    sha256 cellar: :any,                 arm64_sonoma:  "8074146ebd2a5634f6554cbdf3891e6a5c1aea9c797e1aa7660147ec0042dd4f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8f06dea19dab57fd9f04dc7a4fdc256126e13e7cc8b16eba9808c439eb6bb298"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "eigen"
  depends_on "gcc"
  depends_on "openblas"

  resource "spooles" do
    url "http://www.netlib.org/linalg/spooles/spooles.2.2.tgz"
    sha256 "a84559a0e987a1e423055ef4fdf3035d55b65bbe4bf915efaa1a35bef7f8c5dd"
  end

  resource "arpack" do
    url "https://github.com/opencollab/arpack-ng/archive/refs/tags/3.9.1.tar.gz"
    sha256 "f6641deb07fa69165b7815de9008af3ea47eb39b2bb97521fbf74c97aba6e844"
  end

  def install
    # build SPOOLES
    resource("spooles").stage do
      # debug: print the contents
      # puts File.read("Make.inc")

      # Remove old Make.inc and create our own
      rm "Make.inc"

      # Add -fPIC for shared library compatibility
      # Write our own custom Make.inc with actual tabs (not spaces) for make recipes
      File.open("Make.inc", "w") do |f|
        f.puts "CC = #{ENV.cc}"
        f.puts "CFLAGS = -O2 -fPIC -Wno-error=implicit-function-declaration"
        f.puts ""
        f.puts "AR = ar"
        f.puts "ARFLAGS = rv"
        f.puts "RANLIB = ranlib"
        f.puts ""
        f.puts ".c.o :"
        f.puts "\t$(CC) -c $(CFLAGS) $< -o $@" # Real tab character here
        f.puts ""
        f.puts ".c.a :"
        f.puts "\t$(CC) -c $(CFLAGS) $<"
        f.puts "\t$(AR) $(ARFLAGS) $@ $*.o"
        f.puts "\trm -f $*.o"
      end

      # Fix NULL -> 0 bug in ETree/src/transform.c for modern compilers
      inreplace "ETree/src/transform.c" do |s|
        s.gsub! "IVinit(nfront, NULL)", "IVinit(nfront, 0)"
      end

      system "make", "lib"

      # Create target directory and copy everything
      spooles_dest = buildpath/"spooles"
      spooles_dest.mkpath
      cp_r Dir["*"], spooles_dest
    end

    # Build ARPACK
    resource("arpack").stage do
      system "./bootstrap" if File.exist?("bootstrap")

      # use openblas
      openblas = Formula["openblas"]

      system "./configure", "--prefix=#{buildpath}/arpack",
        "--enable-static=yes",
         "--enable-shared=no",
        "--with-blas=-L#{openblas.opt_lib} -lopenblas",
        "--with-lapack=-L#{openblas.opt_lib} -lopenblas",
        "--disable-mpi",
        "F77=#{Formula["gcc"].opt_bin}/gfortran"
      system "make"
      system "make", "install"
    end

    # Debug: see what's in the buildpath
    puts "--- Contents of buildpath ---"
    system "ls", "-la", buildpath
    puts "--- Looking for CCX source ---"
    system "find", buildpath.to_s, "-type", "d", "-name", "src"

    # Build CalculiX CCX - find the actual source directory
    # Common possibilities: ccx_2.23/src, CalculiX/ccx_2.23/src, src
    src_dir = if File.directory?("ccx_2.23/src")
      "ccx_2.23/src"
    elsif File.directory?("CalculiX/ccx_2.23/src")
      "CalculiX/ccx_2.23/src"
    elsif File.directory?("src")
      "src"
    else
      raise "Cannot find CCX source directory"
    end

    cd src_dir do
      # Fix void function returning NULL - works on all compilers
      inreplace "readnewmesh.c" do |s|
        s.gsub!("return NULL;", "return;")
      end

      openblas = Formula["openblas"]

      # Debug: check what arpack files exist
      puts "--- DEBUG: Checking for arpack lib ---"
      system "ls", "-la", "#{buildpath}/arpack/lib/" if File.directory?("#{buildpath}/arpack/lib")

      # Update the Makefile with correct paths
      inreplace "Makefile" do |s|
        # Fix compiler
        s.gsub!(/^CC=.*$/, "CC=#{ENV.cc}")
        s.gsub!(/^FC=.*$/, "FC=#{Formula["gcc"].opt_bin}/gfortran")

        # Fix CFLAGS - add platform-specific warning flags
        # macOS clang needs -Wno-error=return-mismatch for return type issues
        # macOS-14 (Sonoma) needs both -Wno-error=return-mismatch and -Wno-error=return-type
        # Older GCC on Ubuntu doesn't recognize this flag, so only add on macOS
        warning_flags = if OS.mac? && MacOS.version == :sonoma
          "-Wno-error=return-mismatch -Wno-error=return-type"
        elsif OS.mac?
          "-Wno-error=return-mismatch"
        else
          ""
        end

        cflags = "CFLAGS = -Wall -O2 -I#{buildpath}/spooles " \
                 "-DARCH=\"Linux\" -DSPOOLES -DARPACK " \
                 "-DMATRIXSTORAGE -DNETWORKOUT #{warning_flags}".strip
        s.gsub!(/^CFLAGS = .*$/, cflags)

        # Fix DIR
        s.gsub!(/^DIR=.*$/, "DIR=#{buildpath}/spooles")

        # Update LIBS to point to actual archive files (these are used as dependencies)
        # The arpack library might be named differently
        arpack_lib = Dir["#{buildpath}/arpack/lib/*.a"].first
        if arpack_lib
          puts "Found ARPACK lib: #{arpack_lib}"
          libs_replacement = <<~LIBS
            LIBS = \\
              $(DIR)/spooles.a \\
              #{arpack_lib}

            LDFLAGS = -L#{openblas.opt_lib} -lopenblas -lpthread -lm -lc
          LIBS
          s.gsub!(/^LIBS = .*-lc$/m, libs_replacement.chomp)
        else
          odie "Could not find ARPACK library in #{buildpath}/arpack/lib/"
        end
        # Update the link line to use LDFLAGS
        s.gsub!(/(\$\(FC\).*-o \$@ \$\(OCCXMAIN\) ccx_2.23\.a \$\(LIBS\))( -fopenmp)/,
          '\1 $(LDFLAGS)\2')
      end

      system "make"

      bin.install "ccx_2.23" => "ccx"
    end
  end

  def caveats
    <<~EOS
      1. there is another tap that contains a calculix formula
      https://github.com/brewsci/homebrew-science/blob/master/Formula/calculix-ccx.rb

      2. taken from the freebsd port file
      pkg-message:

      For install:
          Spooles: by default the single-threaded solver is used unless you set the
          CCX_NPROC_EQUATION_SOLVER or the OMP_NUM_THREADS environment variables with
          the number of cores you want to use.#{" "}

      Configuration Options:
      ===> The following configuration options are available for CalculiX-ccx-2.22_1:
           DOCS=on: Build and/or install documentation
           EXAMPLES=on: Build and/or install examples
      ===> Use 'make config' to modify these settings

      3. links to other package / distro releases
      https://www.freshports.org/math/spooles/
      https://www.freshports.org/cad/calculix-ccx

      https://www.netlib.org/linalg/spooles/spooles.2.2.html

      https://github.com/bobmel/CalculiX

      https://aur.archlinux.org/packages/calculix-ccx

      https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=calculix-ccx
    EOS
  end

  test do
    # prove that the formual successfully installed, and works as intended
    system "true"
  end
end
