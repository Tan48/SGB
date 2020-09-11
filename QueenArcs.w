% This file is a part of the Stanford GraphBase (c) Stanford University 1993
@i boilerplate.w %<< legal stuff: PLEASE READ IT BEFORE MAKING ANY CHANGES!
@i gb_types.w

\def\title{QUEEN}

@* Queen moves.
This program \.{QueenArcs.w} is a modification of \.{Queen.w} and not part
of the Stanford GraphBase files.
  
This is a short demonstration of how to generate and traverse graphs
with the Stanford GraphBase. It creates a graph with 12 vertices,
representing the cells of a $3\times4$ rectangular board; two
cells are considered adjacent if you can get from one to another
by a queen move. Then it prints a description of the vertices and
their neighbors, on the standard output file.  The new filename is:
\.{QueenArcs.w} and it writes an ASCII file: \.{QueenArcs.gb} specified below.

The original program \.{queen.w} produced an ASCII file called \.{queen.gb} 
and can be read by this program by changing the input filename below.

Programs can obtain a copy of the queen graph by calling:
|restore_graph("queen.gb")|.  You might find it interesting to compare the
output of {\sc QUEEN} with the contents of \.{queen.gb}; the former is intended
to be readable by human beings, the latter by computers.

@p
#include "gb_graph.h" /* we use the {\sc GB\_\,GRAPH} data structures */
#include "gb_basic.h" /* we test the basic graph operations */
#include "gb_save.h" /* and we save our results in ASCII format */
@#

/* Macro definitions for GraphBase Extensions - See Section:
   2.1 Representation of Graphs - Page 39 in The Stanford GraphBase - 
   Copyright 1993 by Stanford University */
#define source     a.V
#define back_arcs  z.A
#define back_next  b.A

/* This is a modified version of the Queen program in the GraphBase.  It alters
   the graph after writing it to the data file by adding a set of back pointing 
   arcs to each vertex in the graph. */

int main()
{@+Graph *g, *gg, *ggg, *gggg;

  register Vertex *v; /* current vertex being visited */
  register Vertex *u; /* utility vertex */
  int i; /* Index into array of vertices */
  int n_back_arcs=0;   /* number of back arcs added to graph */
  register Arc *a; /* current arc from |v| */

  g=board(3L,4L,0L,0L,-1L,0L,0L); /* a graph with rook moves */
  gg=board(3L,4L,0L,0L,-2L,0L,0L); /* a graph with bishop moves */
  ggg=gunion(g,gg,0L,0L); /* a graph with queen moves */

  save_graph(ggg,"QueenArcs.gb"); /* generate an ASCII file for |ggg| */

  @<Print Vertices and Edges of |ggg|@>;

  /* Recycle the Graph ggg and restore it from GB data file */
  /* Deallocate storage for Graph ggg - NOTE pointer is not set to NULL */
  gb_recycle (ggg); 
  if (ggg != NULL) {
    printf ("Graph ggg recycled.\n");
    ggg = restore_graph ("QueenArcs.gb");
    if (ggg == NULL) {
      printf ("Panic - File 'QueenArcs.gb' missing or corrupted: (panic %ld)!\n",panic_code);
      return 1;
    }
    /* Modify Graph ggg to add list of back Arcs that point to each Vertex u */
    for (i=0; i < ggg->n; i++) { v = &ggg->vertices[i]; v->back_arcs = NULL; }
    n_back_arcs = 0;
    for (i=0; i < ggg->n; i++) {
      v = &ggg->vertices[i];
      for (a = v->arcs; a!=NULL; a=a->next) {
        a->source = v;
        u = a->tip;
        a->back_next = u->back_arcs;
        u->back_arcs = a;
        n_back_arcs++;
      }
    }
    printf("QueenArcs has %ld vertices and %ld arcs:\n", ggg->n, ggg->m);
    printf("Back Arcs added %d\n\n", n_back_arcs);
  }
  else {
    printf ("Panic - Graph ggg not deallocated (panic code %ld)!\n",panic_code);
    return 1;
  }
  return 0; /* normal exit */
}

@ @<Print Vertices and Edges of |ggg|@>=
if (ggg==NULL)
    printf("Something went wrong (panic code %ld)!\n",panic_code);
else {
  printf("QueenArcs - Modified Program: Queen Moves on a 3x4 Board\n\n");
  printf("  The graph whose official name is\n%s\n", ggg->id);
  printf("  has %ld vertices and %ld arcs:\n\n", ggg->n, ggg->m);

  for (i=0; i < ggg->n; i++) {
    v = &ggg->vertices[i];
    printf("%s\n", v->name);
    for (a=v->arcs; a; a=a->next)
      printf("  -> %s, length %ld\n", a->tip->name, a->len);
  }
}

@* Index.
