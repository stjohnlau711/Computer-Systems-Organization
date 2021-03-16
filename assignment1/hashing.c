#include <stdio.h>
#include <stdlib.h>
#include <string.h> 

#include "tree.h"

#define SIZE 100

typedef struct hashcell {
    char *word;
    struct hashcell *next;
} HASHCELL;


HASHCELL * hashtable[SIZE];

unsigned int hash_string(char *str){ //step 1

    unsigned int hash = 1;

    for(int i = 0; i < strlen(str); i++){
        char c = str[i];
        hash = (hash * 7) + c;
    }

    return hash % SIZE;
}

void insert_hash_cell(char *str){ //step 1

    unsigned int index = hash_string(str);

    HASHCELL *cell = (HASHCELL *) malloc(sizeof(HASHCELL));
    //create cell and fill with data
    char *new_str = (char *) malloc(strlen(str) + 1);
    cell->word = new_str;
    cell->next = NULL;
    strcpy(new_str, str);

    HASHCELL *current = hashtable[index];

    char flag = 0; 

    while(current != NULL) { //check if word exists using bool var
        if(!strcmp(current->word, cell->word)){ //if strcmp(word1, word2) == 0
            flag = 1;
        }
        current = current->next;
    }

    if(!flag){ //if word doesn't exist (flag == 0), insert at head
        cell->next = hashtable[index];
        hashtable[index] = cell;
    }

}

void print_hash_table(){ //step 1

    for(int i = 0; i < SIZE; i++){
        printf("%d: ", i);
        if(hashtable[i] == NULL){
            printf("~~");
        } else {
            HASHCELL *temp = hashtable[i];
            while(temp != NULL){
                printf("%s ", temp->word);
                temp = temp->next;
            }
        }
        printf("\n");
    }
}

int main(){ //step 2

    char str[100];

    while(scanf("%s", str) != EOF){
        insert_hash_cell(str);
    }

    //print_hash_table();

    for(int i = 0; i < SIZE; i++){
        HASHCELL *current = hashtable[i];
        while(current != NULL){
            insert_node(current->word);
            current = current->next;
        }
    }

    print_tree(root);

}


