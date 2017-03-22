#pragma once

#include <math.h>
#include "MathTools.h"

#include "ColorTools_GPU.h"
using namespace gpu;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

class RipplingMath
    {
	/*--------------------------------------*\
	|*		Constructeur		*|
	 \*-------------------------------------*/

    public:
	__device__
	RipplingMath(uint w, uint h)
	    {
	    this->dim2 = w / h;
	    }

	// constructeur copie: pas besoin car pas attribut ptr
	__device__
	virtual ~RipplingMath(void)
	    {
	    // rien
	    }

	/*--------------------------------------*\
	|*		Methode			*|
	 \*-------------------------------------*/

    public:
	__device__
	void colorIJ(uchar4* ptrColorIJ, int i, int j, float t)
	    {
	    uchar levelGris;

	    f(j, i, t, &levelGris);

	    ptrColorIJ->x = levelGris;
	    ptrColorIJ->y = levelGris;
	    ptrColorIJ->z = levelGris;

	    ptrColorIJ->w = 255; //opaque
	    }

    private:
	__device__
	void f(int i, int j, float t, uchar* ptrlevelGris)
	    {
	    // TODO cf fonction math pdf
	    // use focntion dij ci-dessous

	    float dijVar = 0.0f;

	    dij(i,j,&dijVar);

	    float dijVar10 = dijVar/10.0f;


	    float num = cosf(dijVar10 - t/7.0f);
	    float denum = dijVar10 + 1.0f;

	    *ptrlevelGris = 128.0f + 127.0f *(num/denum);
	    }
	__device__
	void dij(int i, int j, float* ptrResult)
	    {
	    *ptrResult = sqrtf( powf((i-this->dim2),2.0f) + powf((j-this->dim2),2.0f));
	    }

	/*--------------------------------------*\
	|*		Attribut			*|
	 \*-------------------------------------*/

    private:

	// Tools
	double dim2;

    };

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/
