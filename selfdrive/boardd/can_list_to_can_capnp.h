#pragma once
#include <string>
#include <vector>

struct can_frame {
  long address;
  std::string dat;
  long busTime;
  long src;
};

void can_list_to_can_capnp_cpp(const std::vector<can_frame> &can_list, std::string &out, bool sendCan, bool valid);
