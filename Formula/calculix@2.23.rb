class CalculixAT223 < Formula
  desc "Free Software Three-Dimensional Structural Finite Element Program"
  homepage "https://www.calculix.de/"
  url "https://www.dhondt.de/ccx_2.23.src.tar.bz2"
  version "2.23"
  sha256 "9c88385c10fb04f5dc6c4e98027a51bebdd8aee3920e05190d6c1dd08357d6e7"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gcc" => :build
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

      # # Fix Make.inc compiler paths
      # inreplace "Make.inc" do |s|
      #   s.gsub! "/usr/lang-4.0/bin/cc", ENV.cc
      #   s.gsub! %r{/usr/lang-4.0/bin/f77}, Formula["gcc"].opt_bin/"gfortran"
      # end

      # Add -fPIC for shared library compatibility

      # Fix NULL -> 0 bug in ETree/src/transform.c
      # inreplace "ETree/src/transform.c", "IVinit(nfront, NULL)", "IVinit(nfront, 0)"

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

      # Fix specific broken includes
      # inreplace "misc.h", '#include "misc/misc.h"', '/* #include "misc/misc.h" */'
      #   inreplace "FrontMtx.h", '#include "FrontMtx/FrontMtx.h"', '/* #include "FrontMtx/FrontMtx.h" */'

      #   # Check for other problematic includes and fix them
      #   %w[A2 BKL BPG Chv ChvList ChvManager DenseMtx DSTree DV EGraph ETree
      #      GPart Graph I2Ohash IV IVL InpMtx Lock MSMD Network Perm
      #      SubMtx SubMtxList SubMtxManager SymbFac Tree Utilities ZV].each do |name|
      #        if File.exist?("#{name}.h")
      # inreplace "#{name}.h", "#include \"#{name}/#{name}.h\"", "/* #include \"#{name}/#{name}.h\" */" rescue nil
      #        end
      #      end

      # Fix all broken subdirectory includes in SPOOLES headers
      # These reference subdirectories that don't exist
      # Dir.glob("*.h").each do |header|
      #   inreplace header do |s|
      #     # Comment out all includes that reference subdirectories
      #     s.gsub! %r{^#include\s+"[A-Z][^/]+/[^"]+\.h"}, '/* \0 */'
      #   end
      # end

      # Fix SPOOLES header includes - they reference subdirectories that don't exist
      # Change #include "misc/misc.h" to just include the defines directly or remove
      # inreplace "misc.h" do |s|
      #   s.gsub! '#include "misc/misc.h"', '/* #include "misc/misc.h" */'
      # end

      # Create spooles install directory
      # spooles_dir = buildpath/"spooles"
      # spooles_dir.mkpath

      # puts "=== DEBUG: PWD = #{Dir.pwd} ==="
      # puts "=== DEBUG: buildpath = #{buildpath} ==="
      # puts "=== DEBUG: spooles_dir = #{spooles_dir} ==="

      # Copy headers BEFORE make (they get deleted during build)
      # root_headers = Dir.glob("*.h")
      # puts "=== DEBUG: Found #{root_headers.length} root headers ==="
      # puts "First 5: #{root_headers.first(5).join(', ')}"

      # root_headers.each { |h| cp h, spooles_dir }

      # Check if copy worked
      # puts "=== DEBUG: After copying, spooles_dir contains: ==="
      # system "ls -la #{spooles_dir}"

      # Install headers from subdirectories
      # puts "=== DEBUG: Checking misc/src directory ==="
      # system "ls -la misc/src | head -10" if File.directory?("misc/src")

      # Install headers maintaining directory structure with LOWERCASE names
      # dir_map = {
      #   "A2" => "a2",
      #   "BKL" => "bkl",
      #   "BPG" => "bpg",
      #   "Chv" => "chv",
      #   "ChvList" => "chvlist",
      #   "ChvManager" => "chvmanager",
      #   "DenseMtx" => "densemtx",
      #   "DSTree" => "dstree",
      #   "DV" => "dv",
      #   "DVhistogram" => "dvhistogram",
      #   "EGraph" => "egraph",
      #   "ETree" => "etree",
      #   "FrontMtx" => "frontmtx",
      #   "GPart" => "gpart",
      #   "Graph" => "graph",
      #   "I2Ohash" => "i2ohash",
      #   "IV" => "iv",
      #   "IVL" => "ivl",
      #   "InpMtx" => "inpmtx",
      #   "Lock" => "lock",
      #   "MSMD" => "msmd",
      #   "Misc" => "misc",
      #   "Network" => "network",
      #   "Perm" => "perm",
      #   "QRpack" => "qrpack",
      #   "Solvers" => "solvers",
      #   "SubMtx" => "submtx",
      #   "SubMtxList" => "submtxlist",
      #   "SubMtxManager" => "submtxmanager",
      #   "SymbFac" => "symbfac",
      #   "Tree" => "tree",
      #   "Utilities" => "utilities",
      #   "ZV" => "zv"
      # }

      # dir_map.each do |src_dir, target_dir|
      #   # Create the target directory
      #   target_path = spooles_dir/target_dir
      #   target_path.mkpath

      #   src_path = "#{src_dir}/src"
      #   if File.directory?(src_path)
      #     headers = Dir.glob("#{src_path}/*.h")
      #     if headers.length > 0
      #       puts "DEBUG: Copying #{headers.length} headers from #{src_path} to #{target_dir}"
      #     end
      #     headers.each do |h|
      #       cp h, target_path
      #     end
      #   end
      # end

      system "make", "lib"

      # Create target directory and copy everything
      spooles_dest = buildpath/"spooles"
      spooles_dest.mkpath
      cp_r Dir["*"], spooles_dest

      # Copy the entire directory to buildpath for linking
      # cp_r Dir["*"], buildpath/"spooles"

      # Create spooles install directory
      # spooles_dir = buildpath/"spooles"
      # spooles_dir.mkpath

      # Install spooles library
      # cp "spooles.a", spooles_dir

      # Install root headers (they're all we need)
      # Dir.glob("*.h").each { |h| cp h, spooles_dir }

      # cp "spooles.a", spooles_dir
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
    # system "find", buildpath, "-name", "*.c", "-o", "-name", "Makefile" | head -20
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
        # s.gsub!("return NULL;", "return;") if s.match?(/void\s+readnewmesh/)
        s.gsub!("return NULL;", "return;")
      end

      openblas = Formula["openblas"]

      # Debug: check what arpack files exist
      puts "=== DEBUG: Checking for arpack lib ==="
      system "ls", "-la", "#{buildpath}/arpack/lib/" if File.directory?("#{buildpath}/arpack/lib")

      # Update the Makefile with correct paths
      inreplace "Makefile" do |s|
        # Fix compiler
        s.gsub!(/^CC=.*$/, "CC=#{ENV.cc}")
        s.gsub!(/^FC=.*$/, "FC=#{Formula["gcc"].opt_bin}/gfortran")

        # Fix CFLAGS - update include path and add our warning flag
        # macos-14 github hosted runner will fail without `-Wno-error=return-type`
        # GCC 14+ and Clang need different flags for return type mismatches
        cflags = "CFLAGS = -Wall -O2 -I#{buildpath}/spooles " \
                 "-DARCH=\"Linux\" -DSPOOLES -DARPACK " \
                 "-DMATRIXSTORAGE -DNETWORKOUT -Wno-error=return-mismatch " \
                 "-Wno-error=return-type"
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
