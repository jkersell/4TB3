#include <stdio.h>

/* This is a "multiline" comment /*and //should be removed.*/
int main(int argc, char *argv[]) {
    // This comment should go away "as well"
    printf("Hello /*comment*/ //\"stripping\"!\n");
}
