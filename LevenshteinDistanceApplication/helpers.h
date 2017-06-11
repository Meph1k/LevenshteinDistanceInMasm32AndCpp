#pragma once
#include <iostream>

using namespace std;

class Helpers {
	public:
		static void loadWords(string& s1, string& s2);
		static unsigned int getNumberOfThreads();
		static void showFormattedAsmMatrix(unsigned int* levTable, int len1, int len2);
		static void showFormattedCppMatrix(unsigned int** levTable, int len1, int len2);
		static void convertStringToArrayOfInts(string s, int* intsArray);
		static int chooseBetweenAsmAndCpp();
		static int chooseIfConcurrencyOrNot();
};
