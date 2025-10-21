/*

Written by Montek Singh
Copyright and all rights reserved by Montek Singh
Last Updated:  April 4, 2025

Permission granted to use this only for students, teaching/learning assistants
and instructors of the COMP 541 course at UNC Chapel Hill.
For any other use, contact Montek Singh first.

*/

/*

This is a C template for initial development
of your demo app for COMP541 find projects!

You must compile and run this code in an ANSI
compatible terminal.  You can use the terminal app
in the course VM.  For macOS and Linux users, the
standard terminal/shell on your laptop is also ANSI
compatible.

Open a terminal and compile and run the code as follows:

	gcc code.c -lSDL2 -lm
	./a.out

*/

/* Specify the keys here that get_key() will look for,
returning 1 if the first key was found, 2, for the second key, etc.,
and returning 0 if none of these keys was found.
In the actual board-level implementation, you will define
scancodes instead of characters, and you can specify 
key releases as well.
*/
// For our piano, we use eight white keys.
int key_array[] = {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k'};

// Specify the keys here that get_key2() will look for.
// For our piano, we use five black keys.
int key_array2[] = {'w', 'e', 't', 'y', 'u'};

/* Let us define our sprites.  These will be text approximations
of the actual sprites used in the board implementation.
Here, each sprite is specified by:
	{ text character, foreground color, background color }

For example, specifying a sprite as
	{'.', white, red},
means it is drawn as a white dot over a red background.

Specify the number of sprites first (Nchars), and then the
attributes of each sprite.
*/

// type definition for emulating sprites (see below)
typedef struct {
	char char_to_display;
	int fg_color;
	int bg_color;
} sprite_attr;

#define Nchars 5

enum colors {black, red, green, yellow, blue, magenta, cyan, white};

sprite_attr sprite_attributes[Nchars] = {
	{' ', white, white}, // white (unpressed)
	{' ', red, red},     // white pressed
	{' ', black, black}, // black (unpressed)
	{' ', red, red},      // black pressed
	{' ', blue, blue} //background
};

/* 
   In our application we will use the following sprite indexes:
     0: WHITE_UNPRESSED  – the white key in its normal state
     1: WHITE_PRESSED    – the white key when pressed (lit red)
     2: BLACK_UNPRESSED  – the black key in its normal state
     3: BLACK_PRESSED    – the black key when pressed (lit red)
*/
#define WHITE_UNPRESSED 0
#define WHITE_PRESSED   1
#define BLACK_UNPRESSED 2
#define BLACK_PRESSED   3

//===============================================================
// Here are the functions available for I/O.  These correspond
// one-to-one to functions available in MIPS assembly in the
// helper files provided.
//
// NOTE:  There is one function specific to the C implementation
// that is not needed in the assembly implementation:
//     void initialize_IO(char* smem_initfile);
//===============================================================

void my_pause(int N);  	// N is hundredths of a second

void putChar_atXY(int charcode, int col, int row);
	// puts a character at screen location (X, Y)

int getChar_atXY(int col, int row);
	// gets the character from screen location (X, Y)

int get_key();
	// if a key has been pressed and it matches one of the
	// characters specified in key_array[], return the
	// index of the key in that array (starting with 1),
	// else return 0 if no valid key was pressed.

int get_key2();
	// similar to get_key(), but looks for key in
	// key_array2[].

int pause_and_getkey(int N);
	// RECOMMENDED!
	// combines pause(N) with get_key() to produce a 
	// *responsive* version of reading keyboard input

void pause_and_getkey_2player(int N, int* key1, int* key2);
	// 2-player version of pause_and_getkey().

int get_accel();
	// returns the accelerometer value:  accelX in bits [31:16], accelY in bits [15:0]
	// to emulate accelerometer, use the four arrow keys

int get_accelX();
	// returns X tilt value (increases back-to-front)

int get_accelY();
	// returns Y tilt value (increases right-to-left)

void put_sound(int period);
	// visually shows approximate sound tone generated
	// you will not hear a sound, but see the tone highlighted on a sound bar

void sound_off();
	// turns sound off

void put_leds(int pattern);
	// put_leds: set the LED lights to a specified pattern
	//   displays on row #31 (below the screen display)

void initialize_IO(char* smem_initfile);

//-------------------------------------------------------------
// Define period values for our synthesized notes.
// Lower period means a higher pitch.
// (These numbers are exemplary; adjust them as needed.)
//
// White notes for keys C, D, E, F, G, A, B, high C:
int white_note_periods[] = {
	393419, //c
	350497, //d
	312257, //e
	294731, //f
	262576, //g 
	233928, //a 
	208406, //b 
	196710, //c2
};


// Black notes for keys C♯, D♯, F♯, G♯, A♯:
int black_note_periods[] = {
    371338,   // C#3 / Db3
    330825, // D#3 / Eb3
    278189,  // F#3 / Gb3
    247838,// G#3 / Ab3
    220799,   // A#3 / Bb3
};


//-------------------------------------------------------------
// We define a structure to hold information for each piano key.
typedef struct {
    char key;      // The key character (e.g., 'a')
    int col;       // The column on screen (0-indexed)
    int row;       // The row on screen (0-indexed)
    int note_index; // Index into the note period array (for white or black keys)
} PianoKey;

#define NUM_WHITE 8
#define NUM_BLACK 5


PianoKey whiteKeys[NUM_WHITE] = { // key, col, row, note_index (period/pitch)
    {'a',  0, 20, 0}, //c
    {'s', 5, 20, 1}, //d
    {'d', 10, 20, 2}, //e
    {'f', 15, 20, 3}, //f
    {'g', 20, 20, 4}, //g
    {'h', 25, 20, 5}, //a
    {'j', 30, 20, 6}, //b
    {'k', 35, 20, 7}  //c
};


PianoKey blackKeys[NUM_BLACK] = {
    {'w', 3, 15, 0}, //c#
    {'e', 8, 15, 1}, //d#
    {'t', 18, 15, 2}, //f#
    {'y', 23, 15, 3}, //g#
    {'u', 28, 15, 4}  //a#
};

//-------------------------------------------------------------
void drawWhiteKey(PianoKey key, int spriteIndex) {
    int startRow = 5;
    int endRow = 25;
    int keyWidth = 4;  // Each key occupies 4 columns.
    for (int r = startRow; r <= endRow; r++) {
        for (int c = key.col; c < key.col + keyWidth; c++) {
            putChar_atXY(spriteIndex, c, r);
        }
    }
}

void drawBlackKey(PianoKey key, int spriteIndex) {
	int startRow = 5;
	int endRow = 15;
	int keyWidth = 3;
	for (int r = startRow; r <= endRow; r++) {
		for (int c = key.col; c < key.col + keyWidth; c++) {
			putChar_atXY(spriteIndex, c, r);
		}
	}
	
}

int main() {
	initialize_IO("smem.mem");

	// Draw white keys
	for (int i = 0; i < NUM_WHITE; i++) {
	    drawWhiteKey(whiteKeys[i], WHITE_UNPRESSED);
	}
	// draw blalck keys
	for (int i = 0; i < NUM_BLACK; i++) {
	    putChar_atXY(BLACK_UNPRESSED, blackKeys[i].col, blackKeys[i].row);
	}

	// Variables to store which key (if any) is pressed.
	int keyWhite = 0, keyBlack = 0;
	
	// Main loop: poll for input, update sound and display.
	while (1) {
	    // Poll both sets of keys; pause briefly to allow responsiveness.
	    pause_and_getkey_2player(10, &keyWhite, &keyBlack);
	    
	    // Process white keys.
	    if (keyWhite != 0 && keyWhite >= 1 && keyWhite <= NUM_WHITE) {
	        // A white key is pressed; play its note.
	        put_sound(white_note_periods[keyWhite - 1]);
	    } 
  	    // Process black keys.
	    else if (keyBlack != 0 && keyBlack >= 1 && keyBlack <= NUM_BLACK) {
	        put_sound(black_note_periods[keyBlack - 1]);
	    }
	    else {
	    sound_off(); 
	    }
	    
	    // Update display for white keys.
	    for (int i = 0; i < NUM_WHITE; i++) {
	        if (keyWhite == (i + 1))
	            drawWhiteKey(whiteKeys[i], WHITE_PRESSED);
	        else
	            drawWhiteKey(whiteKeys[i], WHITE_UNPRESSED);
	    }
	    
	    // Update display for black keys.
	    for (int i = 0; i < NUM_BLACK; i++) {
	        if (keyBlack == (i + 1))
	        	drawBlackKey(blackKeys[i], BLACK_PRESSED);
	            //putChar_atXY(BLACK_PRESSED, blackKeys[i].col, blackKeys[i].row);
	        else
        		drawBlackKey(blackKeys[i], BLACK_UNPRESSED);	
	            //putChar_atXY(BLACK_UNPRESSED, blackKeys[i].col, blackKeys[i].row);
	    }
	    
	    // Short pause before polling again.
	    // my_pause(1);
	}

	return 0;
}

// The file below has the implementation of all of the helper functions.
#include "procs.c"

