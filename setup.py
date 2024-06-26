from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

discovery_extension = Extension(
    name="chiaki_discovery",
    sources=["discovery.pyx"],
    libraries=["chiaki", "crypto", "ssl", "gf_complete", "jerasure"]
)

wakeup_extension = Extension(
    name="chiaki_wakeup",
    sources=["wakeup.pyx"],
    libraries=["chiaki", "crypto", "ssl", "gf_complete", "jerasure"]
)

streamsession_extension = Extension(
    name="chiaki_streamsession",
    sources=["streamsession.pyx"],
    libraries=["chiaki", "crypto", "ssl", "gf_complete", "jerasure"]
)

setup(
    name="chiaki",
    ext_modules=cythonize([discovery_extension, wakeup_extension, streamsession_extension], gdb_debug=True)
)
