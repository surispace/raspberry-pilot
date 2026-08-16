import os
import capnp

CEREAL_PATH = os.path.dirname(os.path.abspath(__file__))
capnp.remove_import_hook()

log = capnp.load(os.path.join(CEREAL_PATH, "log.capnp"))
car = capnp.load(os.path.join(CEREAL_PATH, "car.capnp"))

# pycapnp >= 2.0 made StructModule.from_bytes a @contextmanager (returns an
# un-opened _GeneratorContextManager). This codebase calls
# `module.from_bytes(data).field` directly expecting a reader back, which then
# fails with "object has no attribute 'field'". Some capnp struct types don't
# allow assigning `from_bytes` directly, so shadow each struct type with a small
# proxy that forwards everything but overrides from_bytes to return a live reader.
def _struct_reader_proxy(orig):
  class Proxy:
    def from_bytes(self, *args, **kwargs):
      return orig.from_bytes(*args, **kwargs).__enter__()
    def __getattr__(self, name):
      return getattr(orig, name)
  Proxy.__name__ = getattr(orig, "__name__", "Proxy")
  Proxy.__qualname__ = getattr(orig, "__qualname__", "Proxy")
  return Proxy()

for _mod in (log, car):
  for _name in dir(_mod):
    _obj = getattr(_mod, _name)
    if isinstance(_obj, type) and hasattr(_obj, "from_bytes"):
      try:
        setattr(_mod, _name, _struct_reader_proxy(_obj))
      except Exception:
        pass
