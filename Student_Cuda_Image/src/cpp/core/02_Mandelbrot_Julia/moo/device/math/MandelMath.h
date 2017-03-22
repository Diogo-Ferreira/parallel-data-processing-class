#pragma once

#include <math.h>
#include "MathTools.h"

#include <iostream>

#include "Calibreur_GPU.h"
#include "ColorTools_GPU.h"
using namespace gpu;
using std::cout;
using std::endl;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

class MandelMath
    {

	/*--------------------------------------*\
	|*		Constructor		*|
	 \*-------------------------------------*/

    public:
	__device__
	MandelMath(uint n, uint N) :
		calibreur(Interval<float>(0, n), Interval<float>(0, 1))
	    {
	    this->n = n;
	    this->N = N;
	    }

	// constructeur copie automatique car pas pointeur dans
	//	DamierMath
	// 	calibreur
	// 	IntervalF
	__device__
	virtual ~MandelMath()
	    {
	    // rien
	    }

	/*--------------------------------------*\
	|*		Methodes		*|
	 \*-------------------------------------*/

    public:
	__device__
	void colorXY(uchar4* ptrColor, float x, float y, float t)
	    {
	    int N = t;

	    int z = f(x, y, N);

	    float hue01 = z;
	    calibreur.calibrer(hue01);


	    if(z >= N)
		{
	    	ptrColor->x = 0;
	    	ptrColor->y = 0;
	    	ptrColor->z = 0;
	    	}
	    else
		{
		ColorTools::HSB_TO_RVB(hue01, ptrColor); // update color
		}



	    ptrColor->w = 255; // opaque
	    }

    private:
	__device__
	int f(float x, float y, int N)
	    {
	    int k = 0;
	    float a = 0.0f;
	    float b = 0.0f;
	    while((a*a+b*b) < 4.0f && k < N)
		{
		float aCopy = a;
		a = (a*a-b*b)+x;
		b = 2*aCopy*b+y;
		k++;
	    }
	    return k;
	    }


	/*--------------------------------------*\
	|*		Attributs		*|
	 \*-------------------------------------*/

    private:

	// Input
	uint n;

	uint N;
	// Tools
	Calibreur<float> calibreur;

    };

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/
