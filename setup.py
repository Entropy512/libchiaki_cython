from setuptools import setup
from setuptools import Extension
from Cython.Build import cythonize

libraries = ["chiaki", "crypto", "ssl", "protobuf-nanopb", "curl", "json-c", "Jerasure", "miniupnpc"]
discovery_extension = Extension(
    name="chiaki_discovery",
    sources=["discovery.pyx"],
    libraries=libraries
)

wakeup_extension = Extension(
    name="chiaki_wakeup",
    sources=["wakeup.pyx"],
    libraries=libraries
)

streamsession_extension = Extension(
    name="chiaki_streamsession",
    sources=["streamsession.pyx"],
    libraries=libraries
)

setup(
    name="chiaki",
    ext_modules=cythonize([discovery_extension, wakeup_extension, streamsession_extension])
)
