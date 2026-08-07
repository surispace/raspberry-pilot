UNAME_M ?= $(shell uname -m)
UNAME_S ?= $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
CEREAL_CFLAGS = -I$(PHONELIBS)/capnp-c/include
CEREAL_CXXFLAGS = -I$(PHONELIBS)/capnp-cpp/mac/include
CEREAL_LIBS = $(PHONELIBS)/capnp-cpp/mac/lib/libcapnp.a \
              $(PHONELIBS)/capnp-cpp/mac/lib/libkj.a \
              $(PHONELIBS)/capnp-c/mac/lib/libcapnp_c.a

else ifeq ($(UNAME_M),x86_64)
else
CEREAL_CFLAGS = -I/usr/local/include
CEREAL_CXXFLAGS = $(shell pkg-config --cflags capnp 2>/dev/null)
ifeq ($(CEREAL_LIBS),)
  CEREAL_LIBS = -L/usr/local/lib -lcapnp_c $(shell pkg-config --libs capnp 2>/dev/null)
endif
endif

CEREAL_OBJS = ../../cereal/gen/c/log.capnp.o ../../cereal/gen/c/car.capnp.o

log.capnp.o: ../../cereal/gen/cpp/log.capnp.c++
	@echo "[ CXX ] $@"
	$(CXX) $(CXXFLAGS) $(CEREAL_CXXFLAGS) \
           -c -o '$@' '$<'

car.capnp.o: ../../cereal/gen/cpp/car.capnp.c++
	@echo "[ CXX ] $@"
	$(CXX) $(CXXFLAGS) $(CEREAL_CXXFLAGS) \
           -c -o '$@' '$<'
