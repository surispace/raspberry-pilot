import os
import capnp

CEREAL_PATH = os.path.dirname(os.path.abspath(__file__))
capnp.remove_import_hook()

_log = capnp.load(os.path.join(CEREAL_PATH, "log.capnp"))
_car = capnp.load(os.path.join(CEREAL_PATH, "car.capnp"))

# pycapnp >= 2.0 made StructModule.from_bytes a @contextmanager, returning an
# un-opened _GeneratorContextManager. This codebase calls
# `module.from_bytes(data).field` directly expecting a reader back (old pycapnp
# returned a live reader). The loaded capnp modules are immutable, so we cannot
# patch from_bytes onto the struct types. Instead, present `log` and `car` as a
# thin namespace that forwards every attribute, but overrides from_bytes on any
# struct type to enter the context manager and hand back a live reader.
def _struct_reader_proxy(struct):
  class Proxy:
    def from_bytes(self, *args, **kwargs):
      return struct.from_bytes(*args, **kwargs).__enter__()
    def __getattr__(self, name):
      return getattr(struct, name)
  Proxy.__name__ = getattr(struct, "__name__", "Proxy")
  Proxy.__qualname__ = getattr(struct, "__qualname__", "Proxy")
  return Proxy()

def _make_namespace(real_mod):
  _proxy_cache = {}
  class Namespace:
    def __getattr__(self, name):
      if name in _proxy_cache:
        return _proxy_cache[name]
      inner = getattr(real_mod, name)
      if isinstance(inner, type) and hasattr(inner, "from_bytes"):
        p = _struct_reader_proxy(inner)
        _proxy_cache[name] = p
        return p
      return inner
  return Namespace()

log = _make_namespace(_log)
car = _make_namespace(_car)