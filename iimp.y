%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "environ.h"
  #include "arbre_imp.h"
  #include "bilquad.h"
  
  int yyerror(char *s);

  arbre_imp *s;
  pile *p = NULL;
  ENV e = NULL;
  BILQUAD b;
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

BILQUAD creer_c3a(arbre_imp *arbre, int *et, int *ct, int *va){
  QUAD tmp;
  BILQUAD fils1, fils2, fils3, end;
  char *s = Idalloc();
  char *res = NULL;
  char *v1 = NULL, *v2 = NULL;
  int op;
  switch(arbre->action)
    {
    case MP:
      fils1 = creer_c3a(arbre->fils[0], et, ct, va);
      b = concatq(b, fils1);
      sprintf(s, "ET%d", *et);
      *et += 1;
      tmp = creer_quad(s, St, v1, v2, res);
      b = concatq(b, creer_bilquad(tmp));
      free(s);
      return b;
      break;
    case SE:
      fils1 = creer_c3a(arbre->fils[0], et, ct, va);
      fils2 = creer_c3a(arbre->fils[1], et, ct, va);
      fils1 = concatq(fils1, fils2);
      return fils1;
      break;
    case VAR:
      op = Sk;
      res = arbre->variable;
      break;
    case NB:
      op = Afc;
      res = Idalloc();
      sprintf(res, "CT%d", *ct);
      *ct += 1;
      v1 = Idalloc();
      sprintf(v1, "%d", arbre->valeur);
      break;
    case AF:
      op = Af;
      v1 = Idalloc();
      strcpy(v1, arbre->fils[0]->variable);
      fils1 = creer_c3a(arbre->fils[1], et, ct, va);
      v2 = fils1.fin->RES;
      break;
    case PL:
    case MO:
    case MU:
      if(arbre->action == PL)
	op = Pl;
      else if(arbre->action == MO)
	op = Mo;
      else
	op = Mu;
      fils1 = creer_c3a(arbre->fils[0], et, ct, va);
      fils2 = creer_c3a(arbre->fils[1], et, ct, va);
      v1 = fils1.fin->RES;
      v2 = fils2.fin->RES;
      res = Idalloc();
      sprintf(res, "VA%d", *va);
      *va += 1;
      break;
    case SK:
      op = Sk;
      break;
    case IFTHEL:
      fils1 = creer_c3a(arbre->fils[0], et, ct, va);
      fils2 = creer_c3a(arbre->fils[1], et, ct, va);
      fils3 = creer_c3a(arbre->fils[2], et, ct, va);
      res = fils3.debut->ETIQ;
      v1 = fils1.fin->RES;
      op = Jz;
      break;
    case WH:
      fils1 = creer_c3a(arbre->fils[0], et, ct, va);
      fils2 = creer_c3a(arbre->fils[1], et, ct, va);
      res = fils1.debut->ETIQ;
      op = Jp;
      break;
    }
  sprintf(s, "ET%d", *et);
  *et += 1;
  tmp = creer_quad(s, op, v1, v2, res);
  end = creer_bilquad(tmp);
  free(s);
  switch(arbre->action)
    {
    case NB:
      free(v1);
      free(res);
      break;
    case AF:
      end = concatq(fils1, end);
      break;
    case PL:
    case MO:
    case MU:
      fils1 = concatq(fils1, fils2);
      end = concatq(fils1, end);
      free(res);
      break;
    case IFTHEL:
      fils1 = concatq(fils1, end);
      fils1 = concatq(fils1, fils2);
      s = Idalloc();
      sprintf(s, "ET%d", *et);
      *et += 1;
      res = Idalloc();
      sprintf(res, "ET%d", *et);
      tmp = creer_quad(s, Jp, NULL, NULL, res);
      end = concatq(fils1, creer_bilquad(tmp));
      end = concatq(end, fils3);
      *et += 1;
      tmp = creer_quad(res, Sk, NULL, NULL, NULL);
      end = concatq(end, creer_bilquad(tmp));
      free(s);
      free(res);
      break;
    case WH:
      fils2 = concatq(fils2, end);
      s = Idalloc();
      sprintf(s, "ET%d", *et);
      *et += 1;
      res = Idalloc();
      sprintf(res, "ET%d", *et);
      *et += 1;
      v1 = fils1.fin->RES;
      tmp = creer_quad(s, Jz, v1, NULL, res);
      fils1 = concatq(fils1, creer_bilquad(tmp));
      end = concatq(fils1, fils2);
      tmp = creer_quad(res, Sk, NULL, NULL, NULL);
      end = concatq(end, creer_bilquad(tmp));
      free(s);
      free(res);
    }
  return end;  
}

ENV environ_c3a(BILQUAD tmp){
  ENV c = NULL;
  QUAD q = tmp.debut;
  while(q != NULL){
    switch(q->OP)
      {
      case Sk:
	if(q->RES != NULL)
	  initenv(&c, q->RES);
	break;
      case Af:
	initenv(&c, q->ARG1);
	affect (c, q->ARG1, valch(c, q->ARG2));
	break;
      case St:
	return c;
	break;
      case Afc:
	initenv(&c, q->RES);
	affect(c, q->RES, atoi(q->ARG1));
	break;
      case Pl:
      case Mo:
      case Mu:

	break;
      }
    q = q->SUIV;
  }
  return NULL;
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

  printf("\n");
  int et = 0, ct = 0, va = 0;
  b = bilquad_vide();
  creer_c3a(s, &et, &ct, &va);
  ecrire_bilquad(b);

  printf("\n");
  tmp = environ_c3a(b);
  ecrire_env(tmp);
  
  free_arbre(s);
}
