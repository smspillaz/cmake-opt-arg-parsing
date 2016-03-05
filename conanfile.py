from conans import ConanFile
from conans.tools import download, unzip
import os


class CMakeOptimizedArgParsingConan(ConanFile):
    name = "cmake-opt-arg-parsing"
    version = "master"
    generators = "cmake"
    requires = ("cmake-include-guard/master@smspillaz/cmake-include-guard", )
    url = "http://github.com/polysquare/cmake-opt-arg-parsing"
    license = "MIT"

    def source(self):
        zip_name = "cmake-opt-arg-parsing-master.zip"
        download("https://github.com/polysquare/" +
                 "cmake-opt-arg-parsing/archive/master.zip", zip_name)
        unzip(zip_name)
        os.unlink(zip_name)

    def package(self):
        self.copy(pattern="*.cmake",
                  dst="cmake/cmake-opt-arg-parsing",
                  src=".",
                  keep_path=True)
