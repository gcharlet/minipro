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

extern char *char_alloc();
extern arbre_imp *cell_alloc();

extern arbre_imp *define_operateur(enum operateur_imp op);
extern arbre_imp *define_valeur(int val);
extern arbre_imp *define_variable(char* var);
extern int ajouter_fils(arbre_imp *s, arbre_imp *fils);
extern void afficher_arbre_imp(arbre_imp *s);
extern void free_arbre(arbre_imp *s);

#endif
