#pragma once

#include "cudaTools.h"
#include "DataCreator.h"

class Histogram
{

public:

	Histogram(const Grid& grid, int tabSize);
	virtual ~Histogram(void);

public:

	int *run();




private:

	// Tools
	int tabSize;
	DataCreator *dataCreator;

	int *ptrTabResult;
		int *ptrTabData;
		int n;

	dim3 dg, db;
	int *ptrResultDev;
	int *ptrDataDev;

	size_t sizeOctetData;
	size_t sizeOctetResult;

};
