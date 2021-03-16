typedef struct node {
    char *word;
    struct node *left;
    struct node *right;

} NODE;

extern NODE *root;

void insert_node(char *str);

void print_tree(NODE *r);
