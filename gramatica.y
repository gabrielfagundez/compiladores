%start program
%token T_PTO_COMA tNEWLINE T_DO T_PIPE T_END /*UNDEF ALIAS*/ T_IF T_WHILE /*UNLESS UNTIL BEGIN*/ T_LLAVE_IZQ T_LLAVE_DER
%token T_RETURN /*YIELD*/ T_AND T_OR T_NOT /*SUPER*/ T_PAR_IZQ T_PAR_DER /*tTWOPOINTS tTHREEPOINTS*/ T_MAS T_MENOS
%token T_ASTER T_EXPO T_BAR T_PORCENTAJE /*tEXP tCARET tAMP*/ T_MENOR_IGUAL_MAYOR T_MAYOR T_MAS_IGUAL T_MENOR T_MENOS_IGUAL
%token T_DOBLE_IGUAL T_TRIPLE_IGUAL T_NOT_IGUAL T_IGUAL_NIOQUI T_NOT_NIOQUI T_NIOQUI /*tPUSH tSHIFT tBAND tBOR tDEFINED*/
%token T_ELSE T_ELSIF /*FOR IN RESCUE ENSURE*/ T_CLASS /*MODULE*/ T_DEF T_COMA T_PTO /*tDOUBLECOLON*/ T_DOS_PTOS T_THEN
%token T_CORCHETE_IZQ T_CORCHETE_DER T_NIL /*SELF tTHEN NUMERIC*/ /*tMULASGN tDIVASGN*/
%token T_CASE /*HERE_DOC REGEXP*/ STRING STRING2 SYMBOL VARNAME T_WHEN fname T_IDENTIF
%token T_IGUAL /*tBEGIN*/ T_FIN_INTERROGACION
/*=========================================================================
                          OPERATOR PRECEDENCE
=========================================================================*/
%left T_MENOS T_MAS
%left T_ASTER T_BAR
//%right '^'
%%
program : compstmt;
t : T_PTO_COMA | '\n';
opt_t : /* empty */
     | t;
compstmt : stmt
         | stmt t
         | stmt texpr
         | stmt texpr t;
texpr : t expr
      | texpr t expr;
def_blockvar :T_PIPE block_var T_PIPE;
opt_blockvar : /* empty */
             | def_blockvar;
opt_block : /* empty */
         | T_DO opt_blockvar compstmt T_END;
stmt : call T_DO opt_blockvar compstmt T_END
//| UNDEF fname
//| ALIAS fname fname
| stmt T_IF expr
| stmt T_WHILE expr
//| stmt UNLESS expr
//| stmt UNTIL expr
//| tBEGIN T_LLAVE_IZQ compstmt T_LLAVE_DER /*object initializer*/
//| T_END T_LLAVE_IZQ compstmt T_LLAVE_DER /*object finalizer*/
| lhs T_IGUAL command opt_block
| expr
;
expr : mlhs T_IGUAL mrhs
    | T_RETURN call_args
//    | YIELD call_args
    | expr T_AND expr
    | expr T_OR expr
    | T_NOT expr
    | command
    | T_NOT command
    | arg
;
call : function
    | command
;
command : operation call_args
 | primary T_PTO operation call_args
// | primary tDOUBLECOLON operation call_args
// | SUPER call_args
;
paren_or_call_args : T_PAR_IZQ T_PAR_DER
              | T_PAR_IZQ call_args T_PAR_DER;
opt_call_args : /* empty */
              | paren_or_call_args;
function : operation
         | operation paren_or_call_args
         | primary T_PTO operation
         | primary T_PTO operation paren_or_call_args
  //       | primary tDOUBLECOLON operation
  //       | primary tDOUBLECOLON operation paren_or_call_args
  //       | SUPER
  //       | SUPER paren_or_call_args;
arg : lhs T_IGUAL arg
//| lhs OP_ASGN arg /*la cambie por la de abajo */
| lhs T_IGUAL arg
//| arg tTWOPOINTS arg | arg tTHREEPOINTS arg
| arg T_MAS arg | arg T_MENOS arg | arg T_ASTER arg | arg T_BAR arg
| arg T_PORCENTAJE arg | arg T_EXPO arg
| T_MAS arg | T_MENOS arg
/*| arg T_PIPE arg
| arg '^' arg | arg '&' arg*/
| arg T_MENOR_IGUAL_MAYOR arg
| arg T_MAYOR arg | arg T_MAS_IGUAL arg | arg T_MENOR arg | arg T_MENOS_IGUAL arg
| arg T_DOBLE_IGUAL arg | arg T_TRIPLE_IGUAL arg | arg T_NOT_IGUAL arg
| arg T_IGUAL_NIOQUI arg | arg T_NOT_NIOQUI arg
| T_NOT arg | T_NIOQUI arg
//| arg tPUSH arg 
//| arg tSHIFT arg
//| arg tBAND arg 
//| arg tBOR arg
//| tDEFINED arg
| primary;

opt_args : /* empty */
         | args;
opt_args_comma : opt_args
               | args T_COMA;
opt_args_or_assocs : args
                   | assocs
                   | assocs T_COMA;
recursive_elsif : /* empty */
                | T_ELSIF expr then compstmt recursive_elsif;
opt_else : /* empty */
         | T_ELSE compstmt;
rec_when_then : T_WHEN when_args then compstmt
              | rec_when_then T_WHEN when_args then compstmt;
//rec_rescue : /* empty */
//           | rec_rescue RESCUE opt_args T_DO compstmt;
//opt_ensure : /* empty */
//           | ENSURE compstmt;
opt_subclass : /* empty */
             | T_MENOR T_IDENTIF;
primary: T_PAR_IZQ compstmt T_PAR_DER
| literal
| variable
//| primary tDOUBLECOLON T_IDENTIF
//| tDOUBLECOLON T_IDENTIF
| primary T_CORCHETE_IZQ T_CORCHETE_DER
| primary T_CORCHETE_IZQ args T_CORCHETE_DER
| T_CORCHETE_IZQ T_CORCHETE_DER
| T_CORCHETE_IZQ args T_CORCHETE_DER
| T_LLAVE_IZQ T_LLAVE_DER
| T_LLAVE_IZQ opt_args_or_assocs T_LLAVE_DER
| T_RETURN
| T_RETURN paren_or_call_args
//| YIELD
//| YIELD paren_or_call_args
//| tDEFINED T_PAR_IZQ arg T_PAR_DER
| function
| function T_LLAVE_IZQ opt_blockvar compstmt T_LLAVE_DER
| T_IF expr then compstmt
  recursive_elsif
  opt_else
  T_END
/*| UNLESS expr then
  compstmt
  opt_else
  T_END*/
| T_WHILE expr T_DO compstmt T_END
//| UNTIL expr T_DO compstmt T_END
| T_CASE compstmt
  rec_when_then
  opt_else
  T_END
/*| FOR block_var IN expr T_DO
    compstmt
  T_END*/
/*| BEGIN
    compstmt
    rec_rescue
    opt_else
    opt_ensure
  T_END*/
| T_CLASS T_IDENTIF opt_subclass
    compstmt
  T_END
/*| MODULE T_IDENTIF
    compstmt
  T_END */
| T_DEF fname argdecl
    compstmt
  T_END
| T_DEF singleton point_or_doublecolon fname argdecl
    compstmt
  T_END;
point_or_doublecolon : T_PTO
//                     | tDOUBLECOLON;
opt_comma_mul_arg : /* empty */
              | T_COMA T_ASTER arg;
when_args : args opt_comma_mul_arg
          | T_ASTER arg;
then : t    /*"then" and "do" can go on next line*/
     | T_THEN
     | t T_THEN;
do   : t
     | T_DO
     | t T_DO;
block_var : lhs | mlhs;
mlhs_item_list : mlhs_item
               | mlhs_item_list T_COMA mlhs_item;
opt_mul_opt_lhs : /* empty */
                | T_ASTER lhs
                | T_ASTER;
mlhs : mlhs_item_list opt_mul_opt_lhs
     | T_ASTER lhs;
mlhs_item : lhs | T_PAR_IZQ mlhs T_PAR_DER;
lhs : variable
    | primary T_CORCHETE_IZQ T_CORCHETE_DER
    | primary T_CORCHETE_IZQ args T_CORCHETE_DER
    | primary T_PTO T_IDENTIF;
mrhs : args opt_comma_mul_arg
     | T_ASTER arg;
opt_comma_assocs : /* empty */
                 | T_COMA assocs;
//opt_comma_amp_arg : /* empty */
//                  | T_COMA '&' arg;
call_args : args opt_comma_assocs opt_comma_mul_arg //opt_comma_amp_arg
//          | assocs opt_comma_mul_arg opt_comma_amp_arg
//          | T_ASTER arg opt_comma_amp_arg 
//	  | '&' arg
          | command;
args : arg
     | args T_COMA arg;
argdecl : T_PAR_IZQ arglist T_PAR_DER
        | arglist t;
identifier_list : T_IDENTIF
                | identifier_list T_COMA T_IDENTIF;
opt_comma_mul_ident : /* empty */
                    | T_COMA T_ASTER
                    | T_COMA T_ASTER T_IDENTIF;
//opt_comma_amp_ident : /* empty */
//                    | T_COMA '&' T_IDENTIF;
//opt_amp_ident : /* empty */
//              | '&' T_IDENTIF;
arglist : identifier_list opt_comma_mul_ident //opt_comma_amp_ident
//        | T_ASTER T_IDENTIF opt_comma_amp_ident
//        | opt_amp_ident;
singleton : variable
        | T_PAR_IZQ expr T_PAR_DER;
assocs : assoc
       | assocs T_COMA assoc;
assoc : arg T_THEN arg;
variable : VARNAME
         | T_NIL
//         | SELF;
literal : /*NUMERIC
        |*/ SYMBOL
        | STRING
        | STRING2
    //  | HERE_DOC
    //  | REGEXP;
opt_terc : /* empty */
          | T_NOT 
	  | T_FIN_INTERROGACION;
operation : T_IDENTIF opt_terc;
%%
/* estos son reconocidos por el lexer */
/*
op_asgn : '+=' | '-=' | '*=' | '/=' | '%=' | '**='
        | '&=' | '|=' | '^=' | '<<=' | '>>='
        | '&&=' | '||=';
symbol : ':'fname | ':'varname;
fname : identifier | '..' | '|' | '^' | '&' | '<=>' | '==' | '===' | '=~'
      | '>' | '>=' | '<' | '<=' | '+' | '-' | '*' | '/' | '%' | '**'
     | '<<' | '>>' | '~' | '+@' | '-@' | '[]' | '[]=';
opt_terc : 
          | '!' | '?';
operation : identifier opt_terc;
varname : global | '@'identifier | identifier;
global : '$'identifier | '$'any_char | '$-'any_char;
string : '"' {any_char} '"'
       | '´' {any_char} '´'
       | '' {any_char} '';
STRING2 : %(Q|q|x)char {any_char} char
HERE_DOC : <<(T_IDENTIF | STRING)
{any_char}
T_IDENTIF
REGEXP : / {any_char} / [i|o|p]
| %r char {any_char} char
T_IDENTIF : sequence in /[a-zA-Z_]{a-zA-Z0-9_}/.
*/
