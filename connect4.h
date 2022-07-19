#ifndef CONNECT4_H
#define CONNECT4_H
#include <stdint.h>
void fillGrid(char** board);
void printBoard(char** board);
void directions();
void printInfo();

uint32_t random_in_range(uint32_t low, uint32_t high);
uint32_t get_random();
int placeCoin(int turn, char** board, int col);
void initializeBoard(char** board);
int checkWin(int turn, int row, int col, char** board);
int checkHorizontal(char x, int row, int col, char** board);
int checkVertical(char x, int row, int col, char** board);
int checkDiagonalLR(char x, int row, int col, char** board);
int checkDiagonalRL(char x, int row, int col, char** board);
#endif // GCD_H

