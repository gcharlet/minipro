#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arbre_imp.h"
#include "environ.h"

char *list_operateur[] = {[MP] = "MP", [SE] = "Se", [SK] = "skip", [AF] = "Af", [IFTHEL] = "IfThEl", [WH] = "Wh", [PL] = "+", [MO] = "-", [MU] = "*"};

char *char_alloc(){
  return Idalloc();
}

arbre_imp *cell_alloc(){
  return(malloc(sizeof(struct cell)));
}

pile *pile_alloc(){
  return(malloc(sizeof(struct tmp)));
}

arbre_imp *define_operateur(enum operateur_imp op){
  arbre_imp *cell = cell_alloc();
  cell->action = op;
  cell->nb_fils = 0;
  switch (op)
    {
    case MP:
      cell->fils = malloc(sizeof(arbre_imp*));
      break;
    case SE:
    case AF:
    case WH:
    case PL:
    case MO:
    case MU:
      cell->fils = malloc(2*sizeof(arbre_imp*));
      break;
    case IFTHEL :
      cell->fils = malloc(3*sizeof(arbre_imp*));
      break;
    default:
      cell->fils = NULL;
      break;
    }
  return cell;
}

arbre_imp *define_valeur(int val){
  arbre_imp *cell = define_operateur(NB);
  cell->valeur = val;
  return cell;
}

arbre_imp *define_variable(char* var){
  arbre_imp *cell = define_operateur(VAR);
  cell->variable = char_alloc();
  strcpy(cell->variable, var);
  return cell;
}


pile *empiler_operateur(pile *p, enum operateur_imp op){
  pile *tmp = pile_alloc();
  tmp->s = define_operateur(op);
  tmp->next = p;
  return tmp;
}

pile *empiler_valeur(pile *p, int val){
  pile *tmp = pile_alloc();
  tmp->s = define_valeur(val);
  tmp->next = p;
  return tmp;
}


pile *empiler_variable(pile *p, char* var){
  pile *tmp = pile_alloc();
  tmp->s = define_variable(var);
  tmp->next = p;
  return tmp;
}

arbre_imp *last_parent(arbre_imp *cell){
  if(cell->action == NB || cell->action == VAR || cell->action == SK)
    return NULL;
  arbre_imp *tmp;
  for(int i = 0; i < cell->nb_fils; i++){
    tmp = last_parent(cell->fils[i]);
    if(tmp != NULL)
      return tmp;
  }
  switch (cell->action)
    {
    case MP:
      if(cell->nb_fils == 1)
	return NULL;
      break;
    case SE:
    case AF:
    case WH:
    case PL:
    case MO:
    case MU:
      if(cell->nb_fils == 2)
	return NULL;
      break;
    case IFTHEL:
      if(cell->nb_fils == 3)
	return NULL;
      break;
    }
  return cell;
}

int ajouter_fils_gauche(arbre_imp *s, arbre_imp *fils){
  arbre_imp *pere = last_parent(s);
  switch (pere->action)
    {
    case MP:
      if(pere->nb_fils == 1)
	return EXIT_FAILURE;
      break;
    case SE:
    case AF:
    case WH:
    case PL:
    case MO:
    case MU:
      if(pere->nb_fils == 2)
	return EXIT_FAILURE;
      break;
    case IFTHEL :
      if(pere->nb_fils == 3)
	return EXIT_FAILURE;
      break;
    default:
      return EXIT_FAILURE;
      break;
    }
  for(int i = pere->nb_fils; i > 0 ; i--)
    pere->fils[i] = pere->fils[i-1];
  pere->fils[0] = fils;
  pere->nb_fils += 1;
  return EXIT_SUCCESS;
}

void afficher_arbre_imp(arbre_imp *s){
  switch(s->action)
    {
    case MP:
    case SE:
    case AF:
    case WH:
    case PL:
    case MO:
    case MU:
    case IFTHEL:
      printf("%s ", list_operateur[s->action]);
      for(int i = 0; i < s->nb_fils; i++)
	afficher_arbre_imp(s->fils[i]);
      break;
    case SK:
      printf("%s ", list_operateur[s->action]);
      break;
    case NB:
      printf("%d ", s->valeur);
      break;
    case VAR:
      printf("%s ", s->variable);
      break;
    }
}

arbre_imp *creer_arbre(pile *p){
  arbre_imp *s = define_operateur(MP);
  pile *tmp;
  while(p != NULL){
    ajouter_fils_gauche(s, p->s);
    tmp = p;
    p = p->next;
    free(tmp);
  }
  return s;
}

void free_arbre(arbre_imp *s){
  for(int i = 0; i < s->nb_fils; i++)
    free_arbre(s->fils[i]);
  if(s->nb_fils != 0)
    free(s->fils);
  if(s->action == VAR)
    free(s->variable);
  free(s);
}
