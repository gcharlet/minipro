%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "environ.h"
  #include "arbre_imp.h"
  #include "bilquad.h"
  
  int yyerror(char *s);
  int yylex();
  pile *p = NULL;
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

int environ_imp(arbre_imp *s, ENV *e){
  switch(s->action)
    {
    case MP:
      environ_imp(s->fils[0], e);
      break;
    case NB:
      return s->valeur;
      break;
    case VAR:
      initenv(e, s->variable);
      return valch(*e, s->variable);
      break;
    case PL:
      return eval(Pl, environ_imp(s->fils[0], e), environ_imp(s->fils[1], e));
    case MO:
      return eval(Mo, environ_imp(s->fils[0], e), environ_imp(s->fils[1], e));
    case MU:
      return eval(Mu, environ_imp(s->fils[0], e), environ_imp(s->fils[1], e));
    case SE:
      environ_imp(s->fils[0], e);
      environ_imp(s->fils[1], e);
      break;
    case AF:
      environ_imp(s->fils[0], e);
      affect(*e, s->fils[0]->variable, environ_imp(s->fils[1], e));
      break;
    case IFTHEL:
      if(environ_imp(s->fils[0], e) != 0)
	environ_imp(s->fils[1], e);
      else
	environ_imp(s->fils[2], e);
      break;
    case WH:
      while(environ_imp(s->fils[0], e) != 0)
	environ_imp(s->fils[1], e);
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
      sprintf(s, "ET%d", *et);
      *et += 1;
      tmp = creer_quad(s, St, v1, v2, res);
      end = concatq(fils1, creer_bilquad(tmp));
      break;
    case SE:
      fils1 = creer_c3a(arbre->fils[0], et, ct, va);
      fils2 = creer_c3a(arbre->fils[1], et, ct, va);
      end = concatq(fils1, fils2);
      break;
    case VAR:
      op = Sk;
      res = arbre->variable; 
      sprintf(s, "ET%d", (*et)++);
      end = creer_bilquad(creer_quad(s, op, v1, v2, res));
      break;
    case NB:
      op = Afc;
      res = Idalloc();
      sprintf(res, "CT%d", *ct);
      *ct += 1;
      v1 = Idalloc();
      sprintf(v1, "%d", arbre->valeur);
      sprintf(s, "ET%d", (*et)++);
      end = creer_bilquad(creer_quad(s, op, v1, v2, res));
      free(v1);
      free(res);
      break;
    case AF:
      op = Af;
      v1 = Idalloc();
      strcpy(v1, arbre->fils[0]->variable);
      fils1 = creer_c3a(arbre->fils[1], et, ct, va);
      v2 = fils1.fin->RES;
      sprintf(s, "ET%d", (*et)++);
      end = creer_bilquad(creer_quad(s, op, v1, v2, res));
      end = concatq(fils1, end);
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
      sprintf(s, "ET%d", (*et)++);
      end = creer_bilquad(creer_quad(s, op, v1, v2, res));
      fils1 = concatq(fils1, fils2);
      end = concatq(fils1, end);
      free(res);
      break;
    case SK:
      op = Sk;
      sprintf(s, "ET%d", (*et)++);
      end = creer_bilquad(creer_quad(s, op, v1, v2, res));
      break;
    case IFTHEL:
      fils1 = creer_c3a(arbre->fils[0], et, ct, va);
      fils2 = creer_c3a(arbre->fils[1], et, ct, va);
      fils3 = creer_c3a(arbre->fils[2], et, ct, va);
      res = fils3.debut->ETIQ;
      v1 = fils1.fin->RES;
      op = Jz;
      sprintf(s, "ET%d", (*et)++);
      end = creer_bilquad(creer_quad(s, op, v1, v2, res));
      fils1 = concatq(fils1, end);
      fils1 = concatq(fils1, fils2);
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
      free(res);
      break;
    case WH:
      fils1 = creer_c3a(arbre->fils[0], et, ct, va);
      fils2 = creer_c3a(arbre->fils[1], et, ct, va);
      res = fils1.debut->ETIQ;
      op = Jp;
      sprintf(s, "ET%d", (*et)++);
      end = creer_bilquad(creer_quad(s, op, v1, v2, res));
      fils2 = concatq(fils2, end);
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
      free(res);
      break;
    }
  free(s);
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
	q = q->SUIV;
	break;
      case Af:
	initenv(&c, q->ARG1);
	affect (c, q->ARG1, valch(c, q->ARG2));
	q = q->SUIV;
	break;
      case St:
	return c;
	break;
      case Afc:
	initenv(&c, q->RES);
	affect(c, q->RES, atoi(q->ARG1));
	q = q->SUIV;
	break;
      case Pl:
      case Mo:
      case Mu:
	initenv (&c, q->RES);
	affect (c, q->RES, eval(q->OP, valch(c, q->ARG1), valch(c, q->ARG2)));
	q = q->SUIV;
	break;
      case Jz:
	if (valch (c, q->ARG1) == 0) {
	  q = rechbq (q->RES, tmp);
	}
	else {
	  q = q->SUIV;
	}
	break;
      case Jp:
	q = rechbq (q->RES, tmp);
	break;
      default:
	q = q->SUIV;
      }
  }
  return NULL;
}

BILQUAD creer_y86(BILQUAD c3a){
  BILQUAD y86 = bilquad_vide();
  QUAD q = c3a.debut;
  int edx = 4;
  char* str = Idalloc();
  ENV address = NULL;
  QUAD q_tmp;
  BILQUAD tmp;
  while(q != NULL){
    switch(q->OP)
      {
      case Sk:
	y86 = concatq(y86, creer_bilquad(creer_quad(q->ETIQ, empty, "nop", NULL, NULL)));
	if(q->RES != NULL){
	  if(rech(q->RES, address) == NULL){
	    initenv(&address, q->RES);
	    affect(address, q->RES, edx);
	    sprintf(str, "%d(%%edx)", edx);
	    edx += 4;
	  }
	}
	break;
      case St:
	y86 = concatq(y86, creer_bilquad(creer_quad(q->ETIQ, empty, "halt", NULL, NULL)));
	break;
      case Af:
	sprintf(str, "%d(%%edx),", valch(address, q->ARG2));
	q_tmp = creer_quad(q->ETIQ, empty, "mrmovl", str, "%eax");
	tmp = creer_bilquad(q_tmp);
	if(rech(q->ARG1, address) == NULL){
	  initenv(&address, q->ARG1);
	  affect(address, q->ARG1, edx);
	  sprintf(str, "%d(%%edx)", edx);
	  edx += 4;
	} else {
	  sprintf(str, "%d(%%edx)", valch(address, q->ARG1));
	}
	q_tmp = creer_quad("", empty, "rmmovl", "%eax,", str);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	y86 = concatq(y86, tmp);
	break;
      case Afc:
	sprintf(str, "%s,", q->ARG1);
	q_tmp = creer_quad(q->ETIQ, empty, "irmovl", str, "%eax");
	tmp = creer_bilquad(q_tmp);
	initenv(&address, q->RES);
	affect(address, q->RES, edx);
	sprintf(str, "%d(%%edx)", edx);
	edx += 4;
	q_tmp = creer_quad("", empty, "rmmovl", "%eax,", str);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	y86 = concatq(y86, tmp);
	break;
      case Pl:
      case Mo:
	sprintf(str, "%d(%%edx),", valch(address, q->ARG1));
	q_tmp = creer_quad(q->ETIQ, empty, "mrmovl", str, "%eax");
	tmp = creer_bilquad(q_tmp);
	sprintf(str, "%d(%%edx),", valch(address, q->ARG2));
	q_tmp = creer_quad("", empty, "mrmovl", str, "%ebx");
	tmp = concatq(tmp, creer_bilquad(q_tmp));
        char *s = (q->OP==Pl)?"addl":"subl";
	q_tmp = creer_quad("", empty, s, "%eax,", "%ebx");
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	initenv(&address, q->RES);
	affect(address, q->RES, edx);
	sprintf(str, "%d(%%edx)", edx);
	edx += 4;
	q_tmp = creer_quad("", empty, "rmmovl", "%eax,", str);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	y86 = concatq(y86, tmp);
	break;
      case Mu:
	sprintf(str, "%d(%%edx),", valch(address, q->ARG1));
	q_tmp = creer_quad(q->ETIQ, empty, "mrmovl", str, "%eax");
	tmp = creer_bilquad(q_tmp);
	sprintf(str, "%d(%%edx),", valch(address, q->ARG2));
	q_tmp = creer_quad("", empty, "mrmovl", str, "%ebx");
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	q_tmp = creer_quad("", empty, "pushl", "%ebx", NULL);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	q_tmp = creer_quad("", empty, "pushl", "%eax", NULL);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	q_tmp = creer_quad("", empty, "call", "MUL", NULL);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	q_tmp = creer_quad("", empty, "popl", "%eax", NULL);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	q_tmp = creer_quad("", empty, "popl", "%ebx", NULL);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	q_tmp = creer_quad("", empty, "mrmovl", "0(%edx),", "%eax");
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	initenv(&address, q->RES);
	affect(address, q->RES, edx);
	sprintf(str, "%d(%%edx)", edx);
	edx += 4;
	q_tmp = creer_quad("", empty, "rmmovl", "%eax,", str);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	y86 = concatq(y86, tmp);
	break;
      case Jp:
	q_tmp = creer_quad(q->ETIQ, empty, "jump", q->RES, NULL);
	y86 = concatq(y86, creer_bilquad(q_tmp));
	break;
      case Jz:
	sprintf(str, "%d(%%edx),", valch(address, q->ARG1));
	q_tmp = creer_quad(q->ETIQ, empty, "mrmovl", str, "%eax");
	tmp = creer_bilquad(q_tmp);
	q_tmp = creer_quad("", empty, "andl", "%eax,", "%eax");
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	q_tmp = creer_quad("", empty, "je", q->RES, NULL);
	tmp = concatq(tmp, creer_bilquad(q_tmp));
	y86 = concatq(y86, tmp);
	break;
      }
    q = q->SUIV;
  }
  return y86;
}

void ecrire_y86(BILQUAD y){
  printf("                      .pos      0         #debut zone code \n");
  printf("INIT      :irmovl     Data,     %%edx      #adresse de la zone de donnees\n");
  printf("           irmovl     256,      %%eax      #espace pile\n");
  printf("           addl       %%edx,     %%eax                \n");
  printf("           rrmovl     %%eax,     %%esp      #init pile \n");
  printf("           rrmovl     %%eax,     %%ebp      \n");
  ecrire_bilquad(y);
  printf("MUL       :nop                            #ssprog mult:M[M[%%edx]]:=X*Y\n");
  printf("           mrmovl     4(%%esp),  %%eax      #A := X   \n");
  printf("           mrmovl     8(%%esp),  %%ebx      # B:= Y   \n");
  printf("           andl       %%eax,     %%eax      # si A==0 return 0\n");
  printf("           je         END                           \n");
  printf("SIGN      :nop                            #si A <= 0 alors (X:= -A,Y:= -B)\n");
  printf("           jg         MULPLUS             #cas ou A > 0\n");
  printf("           irmovl     0,        %%ecx                \n");
  printf("           subl       %%eax,     %%ecx                \n");
  printf("           rrmovl     %%ecx,     %%eax                \n");
  printf("           rmmovl     %%eax,     4(%%esp)   #X := -A  \n");
  printf("           irmovl     0,        %%ecx                \n");
  printf("           subl       %%ebx,     %%ecx                \n");
  printf("           rrmovl     %%ecx,     %%ebx                \n");
  printf("           rmmovl     %%ebx,     8(%%esp)   #Y := -B  \n");
  printf("MULPLUS   :nop                            #ssprog X>0->M[M[%%edx]]:=X*Y\n");
  printf("           mrmovl     4(%%esp),  %%eax      #A := X   \n");
  printf("           andl       %%eax,     %%eax      # si X==0 return 0\n");
  printf("           je         END                           \n");
  printf("           irmovl     1,        %%esi      # A:=A-1  \n");
  printf("           subl       %%esi,     %%eax                \n");
  printf("           mrmovl     8(%%esp),  %%ebx      # B:= Y   \n");
  printf("           pushl      %%ebx                # empiler B, puis A\n");
  printf("           pushl      %%eax                          \n");
  printf("           call       MULPLUS             # M[%%edx]:= A * B=(X-1) * Y\n");
  printf("           popl       %%eax                # depiler A puis B\n");
  printf("           popl       %%eax                          \n");
  printf("           mrmovl     0(%%edx),  %%eax      # M[%%edx]:= M[%%edx] + Y\n");
  printf("           mrmovl     8(%%esp),  %%ebx                \n");
  printf("           addl       %%ebx,     %%eax                \n");
  printf("           rmmovl     %%eax,     0(%%edx)   #end MUL(X<>0) ret(Z)\n");
  printf("           ret                                  \n");
  printf("END       :irmovl     0,        %%eax      #end MUL(X==0) ret(Z)\n");
  printf("           rmmovl     %%eax,     0(%%edx)             \n");
  printf("           ret                                  \n");
  printf("                      .align    8         #debut zone donnees\n");
  printf("Data      :                                     \n");
}

void main(){
  yyparse();

  ENV e = NULL;
  arbre_imp *s = creer_arbre(p);

  printf("arbre de syntaxe abstraite\n");
  afficher_arbre_imp(s);
  printf("\n\n");

  environ_imp(s, &e);
  printf("environnement imp\n");
  ecrire_env(e);
  printf("\n");

  int et = 0, ct = 0, va = 0;
  BILQUAD c3a = creer_c3a(s, &et, &ct, &va);
  printf("code C3A\n");
  ecrire_bilquad(c3a);
  printf("\n");
  
  e = environ_c3a(c3a);
  printf("environnement c3a\n");
  ecrire_env(e);
  printf("\n");
  
  BILQUAD y = creer_y86(c3a);
  printf("code Y86\n");
  ecrire_y86(y);
  
  free_arbre(s);
}
