#include "stdafx.h"
#include "helpers.h"
#include <iostream>
#include <string>
#include <thread>
#include <fstream>

using namespace std;

void Helpers::loadWords(string& s1, string& s2) {
	printf("Please, provide a file name\n");
	string fileName = "";
	cin >> fileName;
	string line;
	ifstream myfile(fileName);
	if (myfile.is_open()) {
		int i = 0;

		while (getline(myfile, line))
		{
			if (0 == i)
				s1 = line;
			else
				s2 = line;
			i++;
		}
		myfile.close();
	}
	else {
		printf("Unable to open the file\n");
		exit(1);
	}
}

void Helpers::showFormattedCppMatrix(unsigned int** levTable, int len1, int len2) {
	for (int i = 0; i <= len1; ++i) {
		for (int j = 0; j <= len2; ++j) {
			printf("%d\n", levTable[i][j]);
		}
		printf("----------------\n");
	}
	printf("\n\n");
}

void Helpers::showFormattedAsmMatrix(unsigned int* levTab, int len1, int len2) {
	for (int i = 0; i < (len1 + 1) * (len2 + 1); i++) {
		if (0 == i % (len1 + 1) && 0 != i) {
			printf("----------------\n");
		}
		printf("%d\n", levTab[i]);
	}
	printf("\n\n");
}

int Helpers::chooseBetweenAsmAndCpp() {
	int choice = 3;
	printf("Choose between ASM and Cpp. Type '1' for ASM or '2' for Cpp\n");
	cin >> choice;

	return choice;
}

int Helpers::chooseIfConcurrencyOrNot() {
	int choice = 3;
	int coresNumber = getNumberOfThreads();
		printf("%d number of cores on your computer: \n", coresNumber);
		if (coresNumber > 1) {
			printf("That means it's recommended to use concurrency. Do you want to do it? Type 1 for 'yes' or 2 for 'no'\n");
		}
		else {
			printf("That means it's NOT recommended to use concurrency. Do you want to do it? Type 1 for 'yes' or 2 for 'no'\n");
		}
		cin >> choice;
	return choice;
}

void Helpers::convertStringToArrayOfInts(string str, int* intsArray) {
	int length = str.length();
	for (int i = 0; i < length; i++) {
		intsArray[i] = str[i];
	}
}

unsigned int Helpers::getNumberOfThreads() {
	return std::thread::hardware_concurrency();
}