from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

discovery_extension = Extension(
    name="chiaki_discovery",
    sources=["discovery.pyx"],
    libraries=["chiaki", "crypto", "ssl", "gf_complete", "jerasure"]
)

setup(
    name="chiaki_discovery",
    ext_modules=cythonize([discovery_extension])
)