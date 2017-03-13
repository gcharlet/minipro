#ifndef ARBRE_IMP_H
#define ARBRE_IMP_H

enum operateur_imp {MP = 0, SE, SK, AF, IFTHEL, WH, PL, MO, MU, NB, VAR};

typedef struct cell {
  enum operateur_imp action;
  struct cell **fils;
  int nb_fils;
  char* variable;
  int valeur;
} arbre_imp;

typedef struct tmp {
  struct cell *s;
  struct tmp *next;
} pile;

extern char *char_alloc();
extern arbre_imp *cell_alloc();
extern pile *pile_alloc();

extern arbre_imp *define_operateur(enum operateur_imp op);
extern arbre_imp *define_valeur(int val);
extern arbre_imp *define_variable(char* var);
extern pile *empiler_operateur(pile *p, enum operateur_imp op);
extern pile *empiler_valeur(pile *p, int val);
extern pile *empiler_variable(pile *p, char* var);
extern int ajouter_fils_gauche(arbre_imp *s, arbre_imp *fils);
extern arbre_imp *creer_arbre(pile *p);
extern void afficher_arbre_imp(arbre_imp *s);
extern void free_arbre(arbre_imp *s);

#endif
