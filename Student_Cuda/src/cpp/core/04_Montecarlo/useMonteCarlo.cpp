#include <iostream>
#include "Grid.h"
#include "Device.h"
#include "MathTools.h"
#include "limits.h"

#include "montecarlo.h"

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

bool useMonteCarlo(void);

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

bool useMonteCarlo()
    {
    int n = 1000000;//INT_MAX/1.001;
    // Partie interessante GPGPU

    // Grid cuda
    int mp = Device::getMPCount();
    int coreMP = Device::getCoreCountMP();

    dim3 dg = dim3(32, 1, 1);  		// disons, a optimiser selon le gpu, peut drastiquement ameliorer ou baisser les performances
    dim3 db = dim3(512, 1, 1);   	// disons, a optimiser selon le gpu, peut drastiquement ameliorer ou baisser les performances
    Grid grid(dg, db);
    Montecarlo monteCarlo(grid, -1.0f, 1.0f, 1.0f,INT_MAX/10);
    monteCarlo.run();
    //AddVector addVector(grid, ptrV1, ptrV2, ptrW, n); // on passse la grille à AddVector pour pouvoir facilement la faire varier de l'extérieur (ici) pour trouver l'optimum
    //addVector.run();

    cout << "PI : " << monteCarlo.piHat << endl;

    return true;
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

