#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 

NODE *root;

void rec_insert_node(NODE *n, NODE *r){

    int check = strcmp(n->word, r->word);

    if(check < 0){
        if(r->left == NULL){
            r->left = n;
        } else {
            rec_insert_node(n, r->left);
        }
    } else {
        if(r->right == NULL){
            r->right = n;
        } else {
            rec_insert_node(n, r->right);
        }
    }


}

void insert_node(char *str){
    NODE *node = (NODE *) malloc(sizeof(NODE));
    node->word = str;

    if(root != NULL){
        rec_insert_node(node, root);
    } else {
        root = node;
    }
}

void print_tree(NODE *r){

    if(r == NULL){
        return;
    }

    print_tree(r->left);
    printf("%s\n", r->word);
    print_tree(r->right);
}
