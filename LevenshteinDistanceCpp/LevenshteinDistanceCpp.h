#pragma once
#ifdef MATHLIBRARY_EXPORTS
#define MATHLIBRARY_API __declspec(dllexport) 
#else
#define MATHLIBRARY_API __declspec(dllimport) 
#endif
#include <iostream>
#include <string>
#include <vector>

namespace LevenshteinDistanceCpp
{
	class Functions
	{
		static MATHLIBRARY_API int findMinimum(int a, int b, int c);
	public:
		static MATHLIBRARY_API void countLevenshteinDistance(unsigned int** levTable, const std::string& fragText1, const std::string& fragText2, int dir, int index);
		static MATHLIBRARY_API void initializeLevMatrix(unsigned int** levTab, size_t len1, size_t len2);
		static MATHLIBRARY_API void countDiagonally(unsigned int** levTab, int index, std::string& s1, std::string& s2);
	};
}