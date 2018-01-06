class Pyside2TestCase < Formula
  desc "Minimal demo?"
  url "https://gitter.im/FreeCAD/macOS"
  version "1"

  depends_on :python => :recommended

  def install
    File.open("demo.cpp", 'w') do
      |file|
      file << <<-ENDCPP
#include <iostream>
#include "Python.h"

int main(int argc, char **argv)
{
    std::cout << "Built!" << std::endl;
    return 0;
}
      ENDCPP
    end

    File.open("Makefile", 'w') do
      |file|
      file << <<-ENDMAKE
demo: demo.cpp
	clang++ $(shell python-config --include) -o $@ $^
      ENDMAKE
    end

    system make, "demo"

    # Uncomment this to get the option to enter the Ruby shell
    # raise
  end

end
