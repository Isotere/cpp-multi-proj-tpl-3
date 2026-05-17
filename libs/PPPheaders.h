// PPPheaders.h

// IWYU pragma: begin_exports
#include <algorithm>
#include <cstdint>
#include <exception>
#include <iostream>
#include <list>
#include <map>
#include <memory>
#include <random>
#include <set>
#include <span>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

#define PPP_EXPORT
#include "PPP_support.h"
// IWYU pragma: end_exports

using namespace PPP;

// disgusting macro hack to get a range checking:
#define vector Checked_vector
#define string Checked_string
#define span   Checked_span
