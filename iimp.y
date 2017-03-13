%{
  #include <stdio.h>
  #include <string.h>
  #include "environ.h"
  #include "arbre_imp.h"
  
  int yyerror(char *s);

  arbre_imp *s;
  pile *p = NULL;
  ENV e = NULL;
%}

%union {
  char *str;
  int   val;
}
%start C
%token <str>V <val>I Plus Moins Mult Wh Do If Th El Affect Skip Se

%%
E : E Plus T       {p = empiler_operateur(p, PL);}
| E Moins T        {p = empiler_operateur(p, MO);}
| T
;

T : T Mult F       {p = empiler_operateur(p, MU);}
| F
;

F : '(' E ')'
| I                {p = empiler_valeur(p, $1);}
| V                {p = empiler_variable(p, $1); free($1);}
;

W : V              {p = empiler_variable(p, $1); free($1);}
;

C : C Se c0        {p = empiler_operateur(p, SE);}
| c0
;

c0 : W Affect E    {p = empiler_operateur(p, AF);}
| '(' C ')'
| If E Th c0 El c0 {p = empiler_operateur(p, IFTHEL);}
| Wh E Do c0       {p = empiler_operateur(p, WH);}
| Skip             {p = empiler_operateur(p, SK);}
;
%%

int yyerror(char *s){
  fprintf(stderr, "***ERROR:%s***\n", s);
  return -1;
}

int environ_p(arbre_imp *s){
  switch(s->action)
    {
    case MP:
      environ_p(s->fils[0]);
      break;
    case NB:
      return s->valeur;
      break;
    case VAR:
      initenv(&e, s->variable);
      return valch(e, s->variable);
      break;
    case PL:
      return eval(Pl, environ_p(s->fils[0]), environ_p(s->fils[1]));
    case MO:
      return eval(Mo, environ_p(s->fils[0]), environ_p(s->fils[1]));
    case MU:
      return eval(Mu, environ_p(s->fils[0]), environ_p(s->fils[1]));
    case SE:
      environ_p(s->fils[0]);
      environ_p(s->fils[1]);
      break;
    case AF:
      environ_p(s->fils[0]);
      affect(e, s->fils[0]->variable, environ_p(s->fils[1]));
      break;
    case IFTHEL:
      if(environ_p(s->fils[0]) != 0)
	environ_p(s->fils[1]);
      else
	environ_p(s->fils[2]);
      break;
    case WH:
      while(environ_p(s->fils[0]) != 0)
	environ_p(s->fils[1]);
    }
  return 0;
}

void main(){
  yyparse();

  s = creer_arbre(p);
  afficher_arbre_imp(s);
  printf("\n\n");

  environ_p(s);
  ENV tmp = e;
  while(tmp != NULL){
    printf("%s = %d\n", tmp->ID, tmp->VAL);
    tmp = tmp->SUIV;
  }
  
  free_arbre(s);
}
