#include <iostream>
#include "Grid.h"
#include "Device.h"

using std::cout;
using std::endl;

#include "histogram.h"

bool useHistogram(void);

bool useHistogram()
    {
    const int SIZE_TAB = 256;
    int* tabResult;
    bool isOk = true;

    int mp = Device::getMPCount();
    dim3 dg = dim3(mp, 1);
    dim3 db = dim3(64, 1, 1);
    Grid grid(dg, db);

    Histogram histogram(grid, SIZE_TAB);
    tabResult = histogram.run();

    cout << "Results :" << endl;
    for (int i = 0; i < 256; i++)
	{
	if (i > 0)
	    {
	    isOk &= (tabResult[i] == tabResult[i - 1] + 1);
	    }
	cout << tabResult[i] << ", ";
	}
    cout << endl;

    return isOk;
    }
