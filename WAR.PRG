DECKSIZE		EQUATE 52
CARDS		CHAR 2(DECKSIZE)

.Player 1 variables
DECK1		CHAR 2(DECKSIZE)
PTR1			FORM 3				Pointer to current card in deck 1
TEMPPTR1		FORM 3
VAL1			FORM 3
NUMCARDS1		FORM 2

.Player 2 variables
DECK2		CHAR 2(DECKSIZE)
PTR2			FORM 3				Pointer to current card in deck 2
TEMPPTR2		FORM 3
VAL2 		FORM 3
NUMCARDS2		FORM 2

WINNER		FORM 1
.This is used for cards in "War"
.First delete cards from each players deck, then add this array to winners
TEMPDECK		FORM 3(DECKSIZE)
LOOPNUM2		FORM 5
NUMTEMPS		FORM 4

*These variables are for shuffle functions
RANDCARD		FORM 3
TEMPCARD		CHAR 2		Stores a card temporarily for swapping
LOOPNUM		FORM 5

*These variables are for the random number generator
TSEED 		CHAR 16
SEED			FORM 4
XVAL			FORM 14
SHIFTAMT		FORM 2
LEFTRIGHT		FORM 1

	CALL INITCARDS
	CALL SHUFFLE
.	Move cards to each players deck
	CALL INITPDECKS

.	Display the UI and players decks
	CALL DISPLAYOUTLINE
	CALL DISPLAYCARDDOWN WITH 35, 1
	CALL DISPLAYCARDDOWN WITH 35, 22

	MOVE 1 TO PTR1
	MOVE 1 TO PTR2
	MOVE PTR1 TO TEMPPTR1
	MOVE PTR2 TO TEMPPTR2
	CALL REMCARDS1
	CALL REMCARDS2
	DISPLAY *P=13:1, "##", NUMCARDS1
	DISPLAY *P=69:25, "##", NUMCARDS2
	KEYIN *P=25:12, "WELCOME TO THE GAME OF WAR", LEFTRIGHT
	DISPLAY *P=25:12, *EL

.	Game Loop
	LOOP
		KEYIN *P=75:25, LEFTRIGHT

		CALL P1DS
		CALL P2DS

		CALL BUILDVALS
		IF (VAL1 = VAL2)
			CALL WAR
			KEYIN *P=75:25, LEFTRIGHT
			DISPLAY *P=1:5, *EL
			DISPLAY *P=1:6, *EL
			DISPLAY *P=1:7, *EL
			DISPLAY *P=1:8, *EL
			DISPLAY *P=1:17, *EL
			DISPLAY *P=1:18, *EL
			DISPLAY *P=1:19, *EL
			DISPLAY *P=1:20, *EL
			CALL REMCARDS1
			CALL REMCARDS2
			DISPLAY *P=13:1, "##", NUMCARDS1
			DISPLAY *P=69:25, "##", NUMCARDS2
			CONTINUE
		ENDIF
		CALL CHECKWINNER
		BREAK IF EOS

		CALL MOVEPTR1
		CALL MOVEPTR2
		CALL REMCARDS1
		CALL REMCARDS2
		DISPLAY *P=13:1, "##", NUMCARDS1
		DISPLAY *P=69:25, "##", NUMCARDS2
	REPEAT
	DISPLAY *P=25:12, "WINNER: PLAYER ", WINNER
	SHUTDOWN

DISPLAYOUTLINE
	DISPLAY *P=3:1, *BOLDON,"PLAYER 2"
	DISPLAY *P=1:2, "===================="
	DISPLAY *P=20:1, "????"

	DISPLAY *P=60:25, "PLAYER 1", *BOLDOFF
	DISPLAY *P=56:24, "========================="
	DISPLAY *P=56:25, "????"

	DISPLAY *P=55:2, "Press any key to"
	DISPLAY *P=55:3, "  step forward"
	RETURN

DISPLAYCARDDOWN LROUTINE POSX@, POSY@
POSX@	FORM @
POSY@	FORM @
	DISPLAY *P=POSX@:POSY@," ____ "
	DISPLAY *P=POSX@:(POSY@+1),"| ???? |"
	DISPLAY *P=POSX@:(POSY@+2),"|????????|"
	DISPLAY *P=POSX@:(POSY@+3),"|_????_|"
	RETURN
	ENDROUTINE ./DISPLAYCARDDOWN

*	A 	->	 Ace
*	____		 ____
*   |  A |	| 10 |
*   |    |	|    |
*   |____|	|____|
*
DISPLAYCARD LROUTINE CARDVAL@, POSX@, POSY@
CARDVAL@	CHAR @
POSX@	FORM @
POSY@	FORM @
	DISPLAY *P=POSX@:POSY@, " ____ "
	DISPLAY *P=POSX@:(POSY@+1), "| ", CARDVAL@, " |"
	DISPLAY *P=POSX@:(POSY@+2), "|    |"
	DISPLAY *P=POSX@:(POSY@+3), "|____|"
	RETURN
	ENDROUTINE ./DISPLAYCARD

REMCARDS1
	MOVE 0 TO NUMCARDS1
	MOVE 1 TO LOOPNUM
	LOOP
		IF (CHOP DECK1(LOOPNUM) != "")
			ADD 1 TO NUMCARDS1
		ENDIF
		ADD 1 TO LOOPNUM
	REPEAT UNTIL (LOOPNUM>52)
	RETURN

REMCARDS2
	MOVE 0 TO NUMCARDS2
	MOVE 1 TO LOOPNUM
	LOOP
		IF (CHOP DECK2(LOOPNUM) != "")
			ADD 1 TO NUMCARDS2
		ENDIF
		ADD 1 TO LOOPNUM
	REPEAT UNTIL (LOOPNUM>52)
	RETURN

MOVEPTR1
.	First deck
	MOVE TEMPPTR1 TO PTR1
	LOOP
		ADD 1 TO PTR1
		IF (PTR1 >= DECKSIZE)
			MOVE 1 TO PTR1
		ENDIF
		BREAK IF (CHOP DECK1(PTR1) != "")
	REPEAT
	RETURN

MOVEPTR2
.	Second deck
	MOVE TEMPPTR2 TO PTR2
	LOOP
		ADD 1 TO PTR2
		IF (PTR2 >= DECKSIZE)
			MOVE 1 TO PTR2
		ENDIF
		BREAK IF (CHOP DECK2(PTR2) != "")
	REPEAT
	RETURN
WAR
	CLEAR TEMPDECK
	MOVE 1 TO LOOPNUM2

	LOOP
		IF (LOOPNUM2 > 4)
			CALL DISPLAYCARDDOWN WITH 41, 5
			CALL DISPLAYCARDDOWN WITH 29, 17
		ENDIF
.	Deck 1
		MOVE PTR1 TO TEMPDECK(LOOPNUM2)
		MOVE PTR1 TO TEMPPTR1
		CALL MOVEPTR1
		MOVE PTR1 TO TEMPDECK(LOOPNUM2+1)
		CALL DISPLAYCARD WITH DECK1(PTR1), 35, 5
		MOVE PTR1 TO TEMPPTR1
		CALL MOVEPTR1
		MOVE PTR1 TO TEMPDECK(LOOPNUM2+2)
		CALL DISPLAYCARD WITH DECK1(PTR1), 29, 5
		MOVE PTR1 TO TEMPPTR1
		CALL MOVEPTR1
		MOVE PTR1 TO TEMPDECK(LOOPNUM2+3)
		CALL DISPLAYCARD WITH DECK1(PTR1), 23, 5

.	Deck 2
		MOVE PTR2 TO TEMPDECK(DECKSIZE-LOOPNUM2 +1)
		MOVE PTR2 TO TEMPPTR2
		CALL MOVEPTR2
		MOVE PTR2 TO TEMPDECK(DECKSIZE-LOOPNUM2)
		CALL DISPLAYCARD WITH DECK2(PTR2), 35, 17
		MOVE PTR2 TO TEMPPTR2
		CALL MOVEPTR2
		MOVE PTR2 TO TEMPDECK(DECKSIZE-LOOPNUM2-1)
		CALL DISPLAYCARD WITH DECK2(PTR2), 41, 17
		MOVE PTR2 TO TEMPPTR2
		CALL MOVEPTR2
		MOVE PTR2 TO TEMPDECK(DECKSIZE-LOOPNUM2-2)
		CALL DISPLAYCARD WITH DECK2(PTR2), 47, 17

		CALL BUILDVALS

		ADD 4 TO LOOPNUM2
		BREAK IF (VAL1 != VAL2)
		MOVE PTR1 TO TEMPPTR1
		CALL MOVEPTR1
		MOVE PTR2 TO TEMPPTR2
		CALL MOVEPTR2
		KEYIN *P=75:25, LEFTRIGHT
	REPEAT

	MOVE (LOOPNUM2-1) TO NUMTEMPS

	IF (VAL1 > VAL2)
		MOVE DECKSIZE TO LOOPNUM2
		LOOP
			MOVE TEMPDECK(LOOPNUM2) TO PTR2
			MOVE PTR1 TO TEMPPTR1
			CALL FINDNEXTEMPTY1
			RETURN IF EOS
			MOVE DECK2(PTR2) TO DECK1(PTR1)
			CLEAR DECK2(PTR2)
			ADD -1 TO LOOPNUM2
		REPEAT UNTIL ((DECKSIZE-LOOPNUM2) > (NUMTEMPS-1))
	ELSE
		MOVE 1 TO LOOPNUM2
		LOOP
			MOVE TEMPDECK(LOOPNUM2) TO PTR1
			MOVE PTR2 TO TEMPPTR2
			CALL FINDNEXTEMPTY2
			RETURN IF EOS
			MOVE DECK1(PTR1) TO DECK2(PTR2)
			CLEAR DECK1(PTR1)
			ADD 1 TO LOOPNUM2
		REPEAT UNTIL (LOOPNUM2 > NUMTEMPS)
	ENDIF

.	Final Move for next turn
	MOVE PTR1 TO TEMPPTR1
	CALL MOVEPTR1
	MOVE PTR2 TO TEMPPTR2
	CALL MOVEPTR2

	RETURN

FINDNEXTEMPTY1
	MOVE 1 TO LOOPNUM
	LOOP
		IF (LOOPNUM > 2)
			MOVE 2 TO WINNER
			SETFLAG EOS
			RETURN
		ENDIF
		IF (PTR1 = DECKSIZE)
			MOVE 1 TO PTR1
			ADD 1 TO LOOPNUM
		ENDIF
		BREAK IF (CHOP DECK1(PTR1) = "")
		ADD 1 TO PTR1
	REPEAT
	SETFLAG NOT EOS
	RETURN

FINDNEXTEMPTY2
	MOVE 1 TO LOOPNUM
	LOOP
		IF (LOOPNUM > 2)
			MOVE 1 TO WINNER
			SETFLAG EOS
			RETURN
		ENDIF
		IF (PTR2 = DECKSIZE)
			MOVE 1 TO PTR2
			ADD 1 TO LOOPNUM
		ENDIF
		BREAK IF (CHOP DECK2(PTR2) = "")
		ADD 1 TO PTR2
	REPEAT
	SETFLAG NOT EOS
	RETURN

CHECKWINNER
	MOVE 0 TO LOOPNUM
	IF (VAL1 > VAL2)
		MOVE PTR1 TO TEMPPTR1
		CALL FINDNEXTEMPTY1
		RETURN IF EOS
		MOVE DECK2(PTR2) TO DECK1(PTR1)
		CLEAR DECK2(PTR2)
	ELSE
		MOVE PTR2 TO TEMPPTR2
		CALL FINDNEXTEMPTY2
		RETURN IF EOS
		MOVE DECK1(PTR1) TO DECK2(PTR2)
		CLEAR DECK1(PTR1)
	ENDIF
	RETURN

BUILDVALS
	MOVE DECK1(PTR1) TO TEMPCARD
	CHOP TEMPCARD TO TEMPCARD
	IF (TEMPCARD = "A")
		MOVE 14 TO VAL1
	ELSE IF (TEMPCARD = "J")
		MOVE 11 TO VAL1
	ELSE IF (TEMPCARD = "Q")
		MOVE 12 TO VAL1
	ELSE IF (TEMPCARD = "K")
		MOVE 13 TO VAL1
	ELSE
		MOVE TEMPCARD TO VAL1
	ENDIF

	MOVE DECK2(PTR2) TO TEMPCARD
	CHOP TEMPCARD TO TEMPCARD
	IF (TEMPCARD = "A")
		MOVE 14 TO VAL2
	ELSE IF (TEMPCARD = "J")
		MOVE 11 TO VAL2
	ELSE IF (TEMPCARD = "Q")
		MOVE 12 TO VAL2
	ELSE IF (TEMPCARD = "K")
		MOVE 13 TO VAL2
	ELSE
		MOVE TEMPCARD TO VAL2
	ENDIF

	RETURN

P1DS
	CALL DISPLAYCARD WITH DECK1(PTR1), 35, 9
	RETURN

P2DS
	CALL DISPLAYCARD WITH DECK2(PTR2), 35, 13
	RETURN

INITPDECKS
	MOVE 1 TO LOOPNUM
	LOOP
		IF (LOOPNUM < (DECKSIZE/2) + 1)
			MOVE CARDS(LOOPNUM) TO DECK1(LOOPNUM)
		ELSE
			MOVE CARDS(LOOPNUM) TO DECK2(LOOPNUM - (DECKSIZE/2))
		ENDIF
		ADD 1 TO LOOPNUM
	REPEAT UNTIL (LOOPNUM > DECKSIZE)
	RETURN

* Initialize all 104 cards A -> King order
.ORDER		"A 2 3 4 5 6 7 8 9 10J Q K"
INITCARDS LROUTINE
	MOVE 1 TO LOOPNUM
	LOOP
		MOVE "A " TO CARDS(LOOPNUM)
		MOVE "2 " TO CARDS(LOOPNUM+1)
		MOVE "3 " TO CARDS(LOOPNUM+2)
		MOVE "4 " TO CARDS(LOOPNUM+3)
		MOVE "5 " TO CARDS(LOOPNUM+4)
		MOVE "6 " TO CARDS(LOOPNUM+5)
		MOVE "7 " TO CARDS(LOOPNUM+6)
		MOVE "8 " TO CARDS(LOOPNUM+7)
		MOVE "9 " TO CARDS(LOOPNUM+8)
		MOVE "10" TO CARDS(LOOPNUM+9)
		MOVE "J " TO CARDS(LOOPNUM+10)
		MOVE "Q " TO CARDS(LOOPNUM+11)
		MOVE "K " TO CARDS(LOOPNUM+12)
		ADD 13 TO LOOPNUM
	REPEAT UNTIL (LOOPNUM>DECKSIZE)
	RETURN
	ENDROUTINE ./INITCARDS


. Shuffles cards using Fisher Yates Algorithms
SHUFFLE LROUTINE
	MOVE (DECKSIZE) TO LOOPNUM
	LOOP
		BREAK IF (LOOPNUM=1)
		CALL GETRANDNUMBER
		MOVE ((XVAL % (LOOPNUM))+1) INTO RANDCARD
		MOVE CARDS(LOOPNUM) TO TEMPCARD
		MOVE CARDS(RANDCARD) TO CARDS(LOOPNUM)
		MOVE TEMPCARD TO CARDS(RANDCARD)
		ADD -1 TO LOOPNUM
	REPEAT
     RETURN
     ENDROUTINE ./SHUFFLE


. Random number generator
. XORS and bitshifts using Clock for seed
. Returns XVAL
.x = SEED
.x ^= (x << 7)
.x ^= (x >> 11)
.x ^= (x << 2)
GETRANDNUMBER LROUTINE
	CLOCK TIMESTAMP TO TSEED
	MOVE TSEED TO SEED

	MOVE 7 TO SHIFTAMT
	MOVE 0 TO LEFTRIGHT
	CALL BITSHIFT WITH SEED

	MOVE 11 TO SHIFTAMT
	MOVE 1 TO LEFTRIGHT
	CALL BITSHIFT WITH XVAL

	MOVE 2 TO SHIFTAMT
	MOVE 0 TO LEFTRIGHT
	CALL BITSHIFT WITH XVAL

     RETURN
     ENDROUTINE ./GETRANDNUMBER


.Left shift = 0
.Right shift = 1
BITSHIFT ROUTINE X
X 			FORM @
TEMPVAR		FORM 14
	IF (LEFTRIGHT=0)
		MULT (2**SHIFTAMT) WITH X GIVING TEMPVAR
	ELSE
		DIV (2**SHIFTAMT) INTO X  GIVING TEMPVAR
	ENDIF
	XOR X INTO TEMPVAR
	MOVE TEMPVAR TO XVAL
	RETURN
	ENDROUTINE ./BITSHIFT
