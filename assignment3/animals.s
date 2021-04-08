# THIS IS THE UNIX (MACOS, LINUX) CALLING CONVENTION:
#
# Passing Parameters:
#  First six integer/pointer parameters (in order): %rdi, %rsi, %rdx, %rcx, %r8, %r9
#        (or correspoding 32-bit halves)

#  Additional parameters are passed on the stack, pushed in right-to-left (reverse) order.

# Return Value: %rax (for 64-bit result), %eax (for 32-bit result)

# Caller-Saved Registers (may be overwritten by called function):
#    %rax , %rcx , %rdx , %rdi , %rsi , %rsp , %r8, %r9, %r10, %r11

# Callee-Saved Registers (must be preserved – or saved and restored – by called function):
#    %rbx, %rbp, %r12, %r13, %r14, %r15

# If you are calling a C function (like _printf) from assembly, keep the stack pointer
# at a 32-byte boundary.


	.section	__TEXT,__text,regular,pure_instructions
	.globl	_yes_response
	.p2align	4, 0x90


// Returns true (1 or any non-zero value) if user types "yes" or "y" (upper or lower case)
// and returns false (0) if user types "no" or "n". Keeps prompting otherwise.
	
// DON'T TOUCH THIS FUNCTION! It works fine and serves as an example for you.
// Make sure you understand what's going on.

_yes_response:	

	pushq	%rbp
	movq	%rsp, %rbp

	//  char response[STRING_SIZE];  // recall that STRING_SIZE is 200
	                           // Allocate this on the stack, at least 200 bytes, but make
	//                         // it a multiple of 16, so 208 (which is 13 x 16)
	//			   // The array can still start at -200(%rbp).

	subq	$208,%rsp

	//
	//   BOOL result;        // since this is the return value, use %eax.
	                         // Nothing needs to be done with this yet, though.


	//   while (TRUE)                       // Just the top of the loop, so need a label here
	                                        // There's no test needed, since it's "while(TRUE)"
	

RESPONSE_LOOP_TOP:	
	
	//     read_line(response, STRING_SIZE);  // call read_line, passing the ADDRESS (using leaq) of the start of the 
	// array in %rdi and 200 in %rsi.  No registers need saving at this point.
	// No return value.
	
	  
        leaq	-200(%rbp),%rdi
	movq	$200,%rsi
	callq	_read_line
	
	//     if (!strcasecmp(response,"yes") || !strcasecmp(response,"y")) {
	//       result = TRUE;
	//       break;
	//     }

	// Two calls to strcasecmp(). The || means that we do the second one only
	// if the first one returns a non-zero number. If they both return a
	// non-zero number, then we execute the else part, below. Otherwise,
	// we write 1 to result (%eax) and jump out of the loop.

        leaq	-200(%rbp),%rdi		# call strcasecmp, passing the addresses of the array and the string "yes"
	leaq	string_yes(%rip),%rsi
	call	_strcasecmp		# returns 0 in %eax if the strings are the same

	cmp	$0,%eax			# if the strings are the same, i.e. the string was "yes", 
	je	FOUND_YES		# then jump over the next comparison                     

        leaq	-200(%rbp),%rdi		# wasn't a "yes", check for "y", need to reload %rdi since it is caller-saved
	leaq	string_y(%rip),%rsi
	call	_strcasecmp		# returns 0 in %eax if the strings are the same

	cmp	$0,%eax	
	jne	CHECK_FOR_NO            # if didn't match "y", then check for "No"

FOUND_YES:	
	movl	$1,%eax			# otherwise, the answer was yes, so put 1 in %eax
	jmp	RESPONSE_LOOP_DONE	# and jump out of the loop


CHECK_FOR_NO:
	
	//     else if (!strcasecmp(response,"no") || !strcasecmp(response,"n")) {
	//       result = FALSE;
	//       break;
	//     }
	
        leaq	-200(%rbp),%rdi		# call strcasecmp, passing the addresses of the array and the string "no"
	leaq	string_no(%rip),%rsi
	call	_strcasecmp		# returns 0 in %eax if the strings are the same

	cmp	$0,%eax			# if the strings are the same, i.e. the string was "no",
	je	FOUND_NO                # then jump over the next comparison                     

        leaq	-200(%rbp),%rdi		# wasn't a "no", check for "n", need to reload %rdi since it is caller-saved
	leaq	string_n(%rip),%rsi
	call	_strcasecmp		# returns 0 in %eax if the strings are the same

	cmp	$0,%eax	
	jne	RE_ENTER		# if the answer didn't match "n", jump to code for asking user to re-enter input

FOUND_NO:	
	movl	$0,%eax			# otherwise, the answer was no, so put 0 in %eax

	jmp	RESPONSE_LOOP_DONE	# and jump out of the loop

RE_ENTER:

	//     printf("Please enter \"yes\" or \"no\" > ");
	//   } 

	leaq	string_enter(%rip),%rdi   # pass the string to printf
	call	_printf

	jmp	RESPONSE_LOOP_TOP	  # always jump to the top of the loop

RESPONSE_LOOP_DONE:	

	//   return result;
	# result is already in %eax, so just restore the stack (removing the array)

	addq	$208,%rsp

	popq	%rbp
	retq
// }


	.section	__TEXT,__text,regular,pure_instructions	

string_yes:                                 
	.asciz	"yes"
string_y:	
	.asciz	"y"
string_no:
	.asciz	"no"
string_n:
	.asciz	"n"
string_enter:
	.asciz  "Please enter \"yes\" or \"no\" > "
	


// // This procedure creates a new NODE and copies
// // the contents of string s into the 
// // question_or_animal field.  It also initializes
// // the left and right fields to NULL.
// // It should return a pointer to the new node
// 
// NODE *new_node(char *s)
// {

	.globl	_new_node
	.p2align	4, 0x90

_new_node:

	pushq	%rbp
	movq	%rsp,%rbp

	# IMPORANT: THE ALIGNMENT RULE FOR MALLOC AND OTHER C FUNCTIONS IS THAT THE STACK HAS
	# TO BE 16-BYTE ALIGNED. SO, AFTER THE PUSH TO %RBP, THE STACK POINTER %RSP, SHOULD
	# BE INCREMENTED OR DECREMENTED IN MULTIPLES OF 16.

	# So, two 8-byte pushes is fine.

	# the string to write into the new node is pointed to by %rdi
	# NOTE: sizeof(NODE) is 216.
        # Offsets within NODE are: question_or_animal = 0, left = 200, right = 208
	# NULL is 0.

	# We'll move s to a callee-saved register, %rbx, so we don't have to repeatedly
	# push and pop it when we make calls to malloc and strcpy.
	# Similarly, we'll put p in %r12, another callee-saved register.

	# first save %rbx and %r12 on the stack.

	pushq %rbx
	pushq %r12
	
	# then move s to %rbx

	movq %rdi, %rbx //move address into rbx

//   NODE *p = (NODE *) malloc(sizeof(NODE));  // where sizeof(NODE) is 216

	movq $224, %rdi
	call _malloc

	# put the result of malloc into p (%r12)

	movq %rax, %r12

//   p->left = NULL;
//   p->right = NULL;
	
	movq $0, 200(%r12) //offset of 200 = p->left
	movq $0, 208(%r12) //ofset of 208 = p->right 

//   strcpy(p->question_or_animal, s);	

	# call strcpy, passing the address of p->question_or_animal and the pointer s (which is in %rbx)

	leaq (%r12), %rdi //address of p->question_or_animal passed
	movq %rbx, %rsi //second parameter is a pointer, so we move an address to the register
	callq _strcpy

//   return p;

	# restore the callee-saved registers %r12, %rbx

	popq %r12 //restore r12
	popq %rbx //restore rbx

	popq	%rbp
	retq
	


	.section	__TEXT,__text,regular,pure_instructions
	.globl	_guess_animal
	.p2align	4, 0x90
	

	
// // This is the function that performs the guessing.
// // If the animal is not correctly guessed, it prompts
// // the user for the name of the animal and inserts a
// // new node for that animal into the tree.
// 
// void guess_animal()
// {

_guess_animal:

	push	%rbp
	mov	%rsp,%rbp

	# IMPORANT: THE ALIGNMENT RULE FOR MALLOC AND OTHER C FUNCTIONS IS THAT THE STACK HAS
	# TO BE 16-BYTE ALIGNED. SO, AFTER THE PUSH TO %RBP, THE STACK POINTER %RSP, SHOULD
	# BE INCREMENTED OR DECREMENTED IN MULTIPLES OF 16 . 
	
	# We'll use some callee-saved registers, since we have a bunch of calls.

	//     char new_question_or_animal[200];

	# In this function, we're going to save registers at fixed offsets from %ebp (as local variables).
	# We're using two callee-saved registers (that's 16 bytes) and have a 200-byte array, for a total of
	# of 216 bytes.  The next 16-byte boundary is at 224, so we'll decrement %rsp by 224 and save/restore
	# %rbx and %r12 as offsets from %rbp (as if they were local variables)
	#  %rbx: -8(%rbp)
	#  %r12: -16(%rbp)
	#  new_question_or_animal: -216(%rbp)

	# We'll use %rbx for p and %r12 for new_n (see below).

	# make space on the stack for the array and the two callee-saved registers

	subq $224, %rsp
	pushq %rbx
	pushq %r12
	
//   if (root == NULL) {
	
	cmpq $0, _root(%rip) //compare root to 0
	jne ROOT_NOT_NULL //jump to root_not_null if root != 0

//     p = (NODE *) malloc(sizeof(NODE));	

	# NOTE: sizeof(NODE) is 216.
	# Also, copy the address to p in %rbx, don't leave it in %rax

	movq $224, %rdi
	call _malloc

	movq %rax, %rbx

	//     p->left = NULL;
	//     p->right = NULL;

        # Offsets within NODE are: question_or_animal = 0, left = 200, right = 208	

	movq $0, 200(%rbx) //offset of 200 = p->left
	movq $0, 208(%rbx) //offset of 208 = p->right
	
	
//     printf("I give up! What animal is it? > ");	

	leaq string_give_up(%rip), %rdi
	call _printf

//     read_line(p->question_or_animal, STRING_SIZE);	

	leaq (%rbx), %rdi //dereference p->question_or_animal and put in param 1
	movq $200, %rsi //put 200 in param 2
	callq _read_line //read line

//     root = p;

	movq %rbx, _root(%rip) //move p -> root, need to use %rip b/c global var

	jmp GUESS_FUNCTION_BOTTOM

//   }  // end of if (root == NULL)
//   else {

ROOT_NOT_NULL:
	
//     p = root;

	movq _root(%rip), %rbx //copy root into rbx (where p should be)

//     while (TRUE) {

GUESS_LOOP_TOP:
	
//       if ((p->left == NULL) && (p->right == NULL)) { //leaf, guess the animal

        # Offsets within NODE are: question_or_animal = 0, left = 200, right = 208

	cmpq $0, 200(%rbx) //check if left is null
	jne NOT_LEAF

	cmpq $0, 208(%rbx) //check if right is null
	jne NOT_LEAF

	# - if we are here, we're at a leaf

// 	printf("I'm guessing: %s\n", p->question_or_animal);

	leaq string_guessing(%rip), %rdi 
	leaq (%rbx), %rsi //STRING PROBLEM HERE
	call _printf

// 	printf("Am I right? > ");	

	leaq string_right(%rip), %rdi
	call _printf

// 	if (yes_response()) {

	call _yes_response //call yes response, jump to wrong answer if we get 0 back
	cmpq $0, %rax
	je WRONG_ANSWER
	# call yes_reponse, then compare its result and jump as necessary.

// 	  printf("I win!\n");

	leaq string_win(%rip), %rdi
	call _printf
	
// 	  break;

	jmp GUESS_FUNCTION_BOTTOM //jump to bottom of function sincne we won


// 	}  // end of if (yes_response())

	
// 	else { //guess was wrong

WRONG_ANSWER:

// 	  printf("\noops.  What animal were you thinking of? > ");

	leaq string_what_animal(%rip), %rdi
	call _printf
	
// 	  read_line(new_question_or_animal); 

	leaq -216(%rbp), %rdi
	movq $200, %rsi
	call _read_line

	
// 	  new_n = new_node(new_question_or_animal);

	leaq -216(%rbp), %rdi
	call _new_node

	mov %rax, %r12 //move result from calling new_node to r12, where we store new_n
	

// 	  printf("Enter a yes/no question to distinguish between a %s and a %s > ", 
// 		 new_question_or_animal, p->question_or_animal);

	leaq string_enter_question(%rip), %rdi 
	leaq -216(%rbp), %rsi
	leaq (%rbx), %rdx
	call _printf
	
// 	  read_line(new_question_or_animal);

	leaq -216(%rbp), %rdi
	movq $200, %rsi
	call _read_line

// 	  printf("What is the answer for a %s (yes or no)? > ",
// 		 new_n->question_or_animal);

	leaq string_what_is_answer(%rip), %rdi
	leaq (%r12), %rsi
	call _printf

// 	  if (yes_response()) {
	
	call _yes_response //call yes response, jump to wrong answer if we get 0 back
	cmpq $0, %rax
	je NO_RESPONSE

// 	    p->left = new_n;

	movq %r12, 200(%rbx) //move new_n to p->left

// 	    p->right = new_node(p->question_or_animal);

	leaq (%rbx), %rdi
	call _new_node //p->right is now a pointer to a node 
	mov %rax, 208(%rbx)

	jmp PROCESSED_RESPONSE
	
// 	  }  // end of if (yes_response())

// 	  else {
NO_RESPONSE:
	
// 	    p->right = new_n;
// 	    p->left = new_node(p->question_or_animal);
// 	  }  # end of else

	movq %r12, 208(%rbx) //move new_n to p->right
    
	leaq (%rbx), %rdi
	call _new_node //p->left is now a pointer to a node 
	mov %rax, 200(%rbx)

// 	  }  # end of else	

PROCESSED_RESPONSE:
	
	// 	  strcpy(p->question_or_animal, new_question_or_animal);

	leaq (%rbx), %rdi //Use leaq to move addresses
	leaq -216(%rbp), %rsi //%rbp is already a pointer
	call _strcpy

	// 	  break;

	jmp GUESS_FUNCTION_BOTTOM
// 	}

//  else { //not a leaf

NOT_LEAF:
	
	//      printf("%s (yes/no) > ", p->question_or_animal);

	leaq string_yes_no(%rip), %rdi
	leaq (%rbx), %rsi
	call _printf

// 	if (yes_response())

	call _yes_response //call yes response, jump to wrong answer if we get 0 back
	cmpq $0, %rax
	je GO_NO

// 	  p = p->left;

	movq 200(%rbx), %rbx //move p.left into p
	
	jmp GUESS_LOOP_BOTTOM //dont want to do p = p->right as well, so we jump to bottom of loop

//	} // end of if (yes_response())

// 	else {

GO_NO:

// 	  p = p->right;

	movq 208(%rbx), %rbx //move p.right into p

//      }  // end of else

GUESS_LOOP_BOTTOM:
	# jump back to top of loop

	jmp GUESS_LOOP_TOP

GUESS_FUNCTION_BOTTOM:

	# Restore the callee-saved registers and remove locals from stack (by adding to %rsp)

	popq %r12
	popq %rbx
	addq $224, %rsp
	
	popq	%rbp
	retq
	

	.section	__TEXT,__text,regular,pure_instructions	

string_give_up:                                 
	.asciz	"I give up! What animal is it? > "
string_guessing:	
	.asciz	"I'm guessing: %s\n"
string_right:
	.asciz	"Am I right? > "
string_win:
	.asciz	"I win!\n"
string_what_animal:
	.asciz  "\noops.  What animal were you thinking of? > "
string_enter_question:
	.asciz "Enter a yes/no question to distinguish between a %s and a %s > "
string_what_is_answer:
	.asciz "What is the answer for a %s (yes or no)? > "
string_yes_no:
	.asciz "%s (yes/no) > "
	

	# The global "root" variable is here. You don't need
	# to touch it.
	
	.section	__DATA,__data
	.globl	_root
	.p2align	2
_root:
	.quad	0		# allocating 8 bytes and initializing to 0
	
