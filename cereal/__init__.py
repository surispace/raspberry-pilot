import os
import capnp

CEREAL_PATH = os.path.dirname(os.path.abspath(__file__))
capnp.remove_import_hook()

log = capnp.load(os.path.join(CEREAL_PATH, "log.capnp"))
car = capnp.load(os.path.join(CEREAL_PATH, "car.capnp"))

# pycapnp >= 2.0 made StructModule.from_bytes a @contextmanager (returns an
# un-opened _GeneratorContextManager). This codebase calls
# `module.from_bytes(data).field` directly expecting a reader back, which then
# fails with "object has no attribute 'field'". Wrap each from_bytes so it
# returns an entered (live) reader, preserving direct access and `with ... as`.
def _reader_from_bytes(orig):
  def wrapped(*args, **kwargs):
    return orig(*args, **kwargs).__enter__()
  return wrapped

for _mod in (log, car):
  for _name in dir(_mod):
    _obj = getattr(_mod, _name)
    if isinstance(_obj, type) and hasattr(_obj, "from_bytes"):
      try:
        setattr(_obj, "from_bytes", _reader_from_bytes(_obj.from_bytes))
      except Exception:
        pass
