.set noreorder
.set noat

	addi $1, $0, 7
	addi $2, $0, 11
	addi $3, $0, 40
	sw   $1, 0($3)
	lw   $4, 0($3)
	sw   $2, 0($3)
	lw   $4, 0($3) 
	