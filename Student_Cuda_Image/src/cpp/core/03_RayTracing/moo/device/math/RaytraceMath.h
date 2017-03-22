#pragma once

#include <math.h>
#include "MathTools.h"
#include "Sphere.h"

#include "ColorTools_GPU.h"
#include <limits.h>
using namespace gpu;
#define FLT_MAX 3.402823466e+38F

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

class RaytraceMath
    {
	/*--------------------------------------*\
	|*		Constructeur		*|
	 \*-------------------------------------*/

    public:
	__device__ RaytraceMath(uint w, uint h, Sphere* tabSphere, int nbSpheres)
	    {
	    this->nbSpheres = nbSpheres;
	    this->tabSphere = tabSphere;
	    }

	// constructeur copie: pas besoin car pas attribut ptr
	/*__device__
	 {
	 // rien
	 }
	 */
	/*--------------------------------------*\
	|*		Methode			*|
	 \*-------------------------------------*/

    public:
	__device__
	void colorIJ(uchar4* ptrColorIJ, int i, int j, float t)
	    {


	    Sphere* nearest = getNearestSphereFromPoint(i, j);

	    if (nearest == NULL)
		{
		ptrColorIJ->x = 0;
		ptrColorIJ->y = 0;
		ptrColorIJ->z = 0;
		}
	    else
		{
		float hc = nearest->hCarre(make_float2(j, i));
		float dz = nearest->dz(hc);
		ColorTools::HSB_TO_RVB(nearest->hue(t), 1, nearest->brightness(dz), ptrColorIJ);
		}
	    ptrColorIJ->w = 255; //opaque
	    }

	__device__
	Sphere* getNearestSphereFromPoint(int i, int j)
	    {
	    float currentNearestDistance = FLT_MAX;
	    Sphere* currentNearestSphere = nullptr;

	    int s = 0;
	    float2 pos = make_float2(j,i);
	    while (s < this->nbSpheres)
		{
		Sphere currentSphere = tabSphere[s];
		float hCarre = currentSphere.hCarre(pos);
		bool estAbove = currentSphere.isEnDessous(hCarre);

		if (estAbove)
		    {
		    float dz = currentSphere.dz(hCarre);
		    float range = currentSphere.distance(dz);

		    if (range < currentNearestDistance)
			{
			currentNearestDistance = range;
			currentNearestSphere = &tabSphere[s];
			}
		    }

		s++;
		}

	    return currentNearestSphere;
	    }

    private:

	float hueSphere(float t, float hStart)
	    {
	    return 0.5f + 0.5f * sinf(t + 1.5f * PI_FLOAT + T(hStart));
	    }

	float T(float hStart)
	    {
	    return asinf(2.0f * hStart - 1) - 1.5f * PI_FLOAT;
	    }

	/*--------------------------------------*\
	|*		Attribut			*|
	 \*-------------------------------------*/

    private:

	//Inputs
	int nbSpheres;
	Sphere* tabSphere;
    };

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/
