#ifndef _BOOL_H
#define _BOOL_H
#include "RObject.h"

// Forward declaration
class RString;

class RBool: public RObject {
  protected:
    bool value;
  public:
    bool getValue();
    RBool();
    RBool(bool arg);
    RBool(RBool *arg);
    RString *get_class();
    RBool *respond_to(RString *method);
    bool operator= (RBool param);
    RBool operator== (RBool param);
    RBool operator|| (RBool param);
    RBool operator&& (RBool param);
};
#endif
