#include <stdio.h>

/* This is a "multiline" comment /*and //should be removed.*/
int main(int argc, char *argv[]) {
    /* Here is */ int i = 0; /* some *really
                                weird commenting*/
    /* and even */ int j = 3; // weird commenting
    // This comment should go away "as well"
    printf("Hello /*comment*/ //\"stripping\"!\n");
}
