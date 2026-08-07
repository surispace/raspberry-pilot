import os
import shlex
import subprocess
from setuptools import Extension, setup

from Cython.Build import cythonize

from common.cython_hacks import BuildExtWithoutPlatformSuffix

_HERE = os.path.dirname(os.path.abspath(__file__))

def pkg_config(flag):
  try:
    out = subprocess.check_output(["pkg-config", flag, "capnp"], encoding='utf8').strip()
  except (subprocess.CalledProcessError, FileNotFoundError):
    return []
  return shlex.split(out)


extra_compile_args = ["-std=c++14"]
extra_link_args = ["-lcapnp_c"]

for token in pkg_config("--cflags"):
  if token.startswith("-I"):
    continue
  extra_compile_args.append(token)

extra_link_args.extend(pkg_config("--libs"))

setup(name='Boardd API Implementation',
      cmdclass={'build_ext': BuildExtWithoutPlatformSuffix},
      ext_modules=cythonize(
        Extension(
          "boardd_api_impl",
          sources=['boardd_api_impl.pyx', 'can_list_to_can_capnp.cc'],
          language="c++",
          include_dirs=['../..'],
          extra_compile_args=extra_compile_args,
          extra_link_args=extra_link_args,
        )
      )
)
