#ifndef _RSTRING_H
#define _RSTRING_H

#include <iostream>
#include <string>

#include "RObject.h"

class RBool;
class RInteger;
class RDecimal;

class RString: public RObject {
  protected:
    std::string *str;
  public:
    std::string *getValue();
    RString();
    ~RString();
    RString(const char *arg);
    RString(char *arg);
    RString(char *arg, bool cortar_extremos);
    RString(std::string *arg);
    RString(RString *arg);
    RString(RInteger *arg);
    RString(RDecimal *arg);
    RString *get_class();
    RString *to_s();
    int size();
    void setValue(const char * param);
    void setValue(std::string param);
    void setValue(std::string *param);
    void setValue(RString * param);
    bool respond_to(RString *method);
};
#endif
