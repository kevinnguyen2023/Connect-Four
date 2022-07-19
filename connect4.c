#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <errno.h>
#include "connect4.h"


uint32_t m_w;
uint32_t m_z;
int cols = 9; 
int rows = 6;
int check = 0;

int main(){

	
	char** board;
	
	int row;
	int col;
	int gameOver = 0;
	int turn;
	board = calloc(rows, sizeof(char*));
	
	for(int i = 0; i < rows; i++){
		board[i] = calloc(cols, sizeof(char));

	}
	
	
	fillGrid(board);
	
	printf("Welcome to Connect Four, Five-in-a-Row variant\n");
	printf("Enter two positive numbers to initialize the random number generator.\n");
	printf("Number 1: ");
	scanf("%u", &m_w);
	printf("Number 2: ");
	scanf("%u", &m_z);


	uint32_t random = random_in_range(0,100);
	if(random < 50){
		turn = 0;
	}
	else{
		turn = 1;
	}
	printBoard(board);
	while(gameOver == 0){

	//Turn = 0 is the players turn
	//Turn = 1 is the computers turn
		if(turn == 0){
			printf("Enter a column: ");
			scanf("%i", &col);
			while(col < 1 || col > 7){
				printf("Invalid Entry! Enter a column: ");
				scanf("%i", &col);
			}
			//printf("row = %i col = %i\n", row, col);
			row = placeCoin(1, board, col);

			while(row == -1){
				printf("Column Full Enter a column: ");
				scanf("%i", &col);
				row = placeCoin(1, board, col);
				
			}
			


		}
		else if(turn == 1){ 
			col = random_in_range(1,7);
			//printf("col = %i\n", col);
			row = placeCoin(0, board, col);

		}

		int total = (rows * (cols-2));
		if(check == total){
			printf("\nNo one won?!");
			gameOver = 1;
		}

		else if(checkWin(turn, row, col, board) == 1){
			if(turn == 0){
				printf("\nHuman Player Wins!!");
			}
			else{
				printf("\nComputer Player Wins!!");
			}
			gameOver = 1;
		}
		
		printBoard(board);
		
	if (turn == 0) {
	   turn = 1;
	}
	else {
	   turn = 0; 
	}
		
    }
}
int placeCoin(int isHuman, char** board,int col){
	int i = rows - 1;
	while(i >= 0){
		//printf("i = %i", i);
		if(board[i][col] == '-' && isHuman == 1){
			board[i][col] = 'H';
			check++;
			return i;
		}
		else if(board[i][col] == '-' && isHuman == 0){
			board[i][col] = 'C';
			check++;
			return i;
		}
		

		i--;

	}
	
	
	return -1;
}

int checkWin(int turn, int row, int col, char** board){
	char x;
	if(turn == 0){
		x = 'H';
	}
	else{
		x = 'C';
	}
		
	if(checkVertical(x, row, col, board) == 1 || checkHorizontal(x, row, col, board) == 1 || checkDiagonalLR(x, row, col, board) == 1|| checkDiagonalRL(x, row, col, board) == 1){
		return 1;
	}

	return 0;

}
int checkVertical(char x, int row, int col, char** board){
	int i = row;
	int count = 0;
	while(i < rows && board[i][col] == x){
		i++;
	}
	i--;

	while(i > 0 && board[i][col] == x){
		count++;
		i--;
	}
	if(count >= 5){
		return 1;
	}
	
	return 0;
}
int checkHorizontal(char x, int row, int col, char** board){
	int j = col;
	int count = 0;
	while(j < cols && board[row][j] == x){
		j++;
	}
	j--;
	while(j > 0 && board[row][j] == x){
		count++;
		j--;
	}
	if(count >= 5){
		return 1;
	}
	return 0;
	
}	
int checkDiagonalLR(char x, int row, int col, char** board){
	int count = 0;
	int i = row;
	int j = col;

	while(i > 0 && j > 1 && board[i][j] == x){
		i--;
		j--;
	}
	i++;
	j++;
	while(i < rows && j < cols - 1 && board[i][j] == x){
		count++;
		i++;
		j++;
	}
	if(count >= 5){
		return 1;
	}
	return 0;

}

int checkDiagonalRL(char x, int row, int col, char** board){
	int count = 0;
	int i = row;
	int j = col;
	//i++;
	//j--;
	while(i < rows && j > 0 && board[i][j] == x){
		i++;
		j--;
	}
	i--;
	j++;
	while(i > 0 && j < cols - 1 && board[i][j] == x){
		count++;
		i--;
		j++;
	}
	if(count >= 5){
		return 1;
	}
	return 0;
}

void printBoard(char** board){
	printf("\n--------------------------------------\n");
	printf("   ");
	for(int i = 1; i <= 7; i++){
		printf("   %i", i);
	}
	printf("\n--------------------------------------\n");

	for(int i = 0; i < rows; i++){
		for(int j = 0; j < cols; j++){
			printf("| %c ", board[i][j]);
		}
		printf("|\n");
	}
	printf("--------------------------------------\n");
}
void fillGrid(char** board){
	for(int i = 0; i < rows; i++){
		for(int j = 0; j < cols; j++){
			if(j == 0 || j == cols - 1){
				if(i % 2 == 0){
					board[i][j] = 'C';
				}
				else{
					board[i][j] = 'H';
				}
			}
			else{
				board[i][j] = '-';
			}
		}
	}
}
uint32_t random_in_range(uint32_t low, uint32_t high){
  uint32_t range = high-low+1;
  uint32_t rand_num = get_random();

  return (rand_num % range) + low;
}
 

uint32_t get_random(){
  uint32_t result;
  m_z = 36969 * (m_z & 65535) + (m_z >> 16);
  m_w = 18000 * (m_w & 65535) + (m_w >> 16);
  result = (m_z << 16) + m_w;  /* 32-bit result */
  return result;
}
