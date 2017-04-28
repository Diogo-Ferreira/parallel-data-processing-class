#include <iostream>
#include "Grid.h"
#include "Device.h"
#include "MathTools.h"
#include "limits.h"

#include "slice.h"

using std::cout;
using std::endl;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

bool useSlice(void);

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

bool useSlice()
    {
    int n = 1000000;//INT_MAX/1.001;
    // Partie interessante GPGPU

    // Grid cuda
    int mp = Device::getMPCount();
    int coreMP = Device::getCoreCountMP();

    dim3 dg = dim3(32, 1, 1);  		// disons, a optimiser selon le gpu, peut drastiquement ameliorer ou baisser les performances
    dim3 db = dim3(512, 1, 1);   	// disons, a optimiser selon le gpu, peut drastiquement ameliorer ou baisser les performances
    Grid grid(dg, db);
    Slice slice(grid, n);
    slice.run();
    //AddVector addVector(grid, ptrV1, ptrV2, ptrW, n); // on passse la grille à AddVector pour pouvoir facilement la faire varier de l'extérieur (ici) pour trouver l'optimum
    //addVector.run();

    cout << slice.piHat << endl;
    bool isOk = MathTools::isEquals(slice.piHat, PI, 1e-6);
    cout << "isOk = " << isOk << endl;

    return isOk;
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

