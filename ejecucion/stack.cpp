#include <iostream>
#include <string>
#include <list>
#include <set>
#include <stack>

#include "stack.h"
#include "base.h"
#include "memory.h"
#include "RInteger.h"
#include "RString.h"
#include "RBool.h"
class RString;
using namespace std;

set<string> tsimbolos;
unordered_map<string, list<Instruccion*> *> functions;
//unordered_map<string, RObject*> vTemporales;

unordered_map<string, RObject*> global_variables; // las variables deben agregarse a este hash variables["nombre"] = RObject*
unordered_map<string, list<Instruccion*>*> global_methods; // los metodos globales se guardan aqui methods["nombre"] = list<Instruccion *>*
unordered_map<string, RObject*>* current_stack;
list<unordered_map<string, RObject*>*> scope_stack;
stack<bool> cond_stack;
stack<list<Instruccion *>::iterator> while_stack;

//RObject *getValue(string* key){
//	return vTemporales[*key];
//}

void initializer(){
  // Stack inicial
  scope_stack.push_back(new unordered_map<string, RObject*>);
  current_stack = scope_stack.back();
}

void clean_up(){
  free_memory();
  list<unordered_map<string, RObject*>*>::iterator it;
  for (it=scope_stack.begin(); it != scope_stack.end(); it++)
    delete *it;
}

void ejecutar(list<Instruccion*> *codigo) {
  list<Instruccion *>::iterator it = codigo->begin();
  Instruccion *ri;
  do {
    ri = *it++;
    switch (ri->op) {
      case FIN   : cout << "Fin ejecución" << endl; break;
      case PUTS  : puts((RString *)ri->arg1); break;
      case GETS  : gets((RString *)ri->arg1); break;
      case ADD   : cout << "adddddddddddd" << endl;
        add((RString *)ri->arg1, (RString *)ri->arg2, (RString *)ri->arg3); 
        //cout << "Voy a ejecutar el ADD" << endl;
        //vTemporales[*(((RString *)ri->arg3)->getValue())] = add((RInteger *)ri->arg1, (RInteger *)ri->arg2); 
        //cout << "El valor es ----    " << vTemporales[*(((RString *)ri->arg3)->getValue())]  << endl;
        break;
      case OBJID : if (ri->arg1 != NULL) *((RInteger*)ri->arg1) = getDir(ri->arg2); break;
      case ASSIGN_TMP : assign_tmp((RString *)ri->arg1, ri->arg2); break;
      case MULT : mult((RString *)ri->arg1, (RString *)ri->arg2, (RString *)ri->arg3); break;
      case SUB : sub((RString *)ri->arg1, (RString *)ri->arg2, (RString *)ri->arg3); break;
      case DIV : div((RString *)ri->arg1, (RString *)ri->arg2, (RString *)ri->arg3); break;
      case POW : pow((RString *)ri->arg1, (RString *)ri->arg2, (RString *)ri->arg3); break;
      case MOD : mod((RString *)ri->arg1, (RString *)ri->arg2, (RString *)ri->arg3); break;
      case IF : if (!((RBool*)ri->arg1)->getValue()) it = descartar_if(it); cond_stack.push(((RBool*)ri->arg1)->getValue()); break;
      case ELSIF : if (!((RBool*)ri->arg1)->getValue()) it = descartar_if(it); else { cond_stack.pop(); cond_stack.push(((RBool*)ri->arg1)->getValue());} break;
      case ELSIFCOND : if (cond_stack.top()) it = descartar_hasta_end(it); break;
      case ELSE : if (cond_stack.top()) it = descartar_hasta_end(it); break;
      case END : cond_stack.pop(); break;
      case WHILE : if (((RBool*)ri->arg1)->getValue()) while_stack.push(it); else it=descartar_whileend(it); break;
      case WHILEEND : if (((RBool*)ri->arg1)->getValue()) it = while_stack.top(); else while_stack.pop(); break;
    }
  } while (ri->op != FIN);

  for (it=codigo->begin(); it != codigo->end(); it++)
    delete *it;
  clean_up();
}

void add_symbol(char *name) {
  tsimbolos.insert(name);
}

RObject *get_variable(char *name){ //aca hay q considerar el tema del scope?
  list<unordered_map<string, RObject*>*>::reverse_iterator rit;
  //unordered_map<string, Instruccion*>* stack;
  rit = scope_stack.rbegin();
  RObject *object;
  do {
    object = (**rit)[name];
  } while (rit != scope_stack.rend());
  return global_variables[name];
}

void set_variable(char *name, RObject* var){ //aca hay q considerar el tema del scope?
  global_variables[name]= var;
}

void add_global_function(char* name, list<Instruccion*>* codigo){
  global_methods[name] = codigo;
}

void new_scope(){
  current_stack = new unordered_map<string, RObject*>;
  scope_stack.push_back(current_stack);
}

void pop_stack(){
  scope_stack.pop_back();
  current_stack = scope_stack.back();
}

list<Instruccion*>::iterator descartar_if(list<Instruccion*>::iterator it) { // caso if false
  Instruccion *ri = *it;
  while (ri->op != ELSIF && ri->op != ELSIFCOND && ri->op != ELSE && ri->op != END) {
    if (ri->op == IF || ri->op == DO || ri->op == IF)
      it = descartar_hasta_end(++it);
    ri = *(++it);
  }
  return it;
}

list<Instruccion*>::iterator descartar_hasta_end(list<Instruccion*>::iterator it){
  Instruccion *ri = *it;
  while (ri->op != END) {
    if (ri->op == IF || ri->op == DO || ri->op == IF)
      it = descartar_hasta_end(++it);
    ri = *(++it);
  }
  return it;
}

std::list<Instruccion*>::iterator descartar_whileend(std::list<Instruccion*>::iterator it){
  Instruccion *ri = *it;
  while (ri->op != WHILEEND) {
    ri = *(++it);
  }
  return ++it;
}

Instruccion *nuevaInst(enum code_ops op, RObject* arg1, RObject* arg2, RObject* arg3){
  Instruccion *inst = new Instruccion;
  inst->op = op;
  inst->arg1 = arg1;
  inst->arg2 = arg2;
  inst->arg3 = arg3;
  return inst;
}

