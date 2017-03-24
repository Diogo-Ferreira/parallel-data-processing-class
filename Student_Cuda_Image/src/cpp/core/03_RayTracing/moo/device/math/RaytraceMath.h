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
	    int nearestIndex = -1;
	    float bestDz = 0;
	    getNearestSphereFromPoint(i, j,&nearestIndex,&bestDz);
	    Sphere *nearest = &tabSphere[nearestIndex];

	    if (nearest == nullptr)
		{
		ptrColorIJ->x = 0;
		ptrColorIJ->y = 0;
		ptrColorIJ->z = 0;
		}
	    else
		{
		ColorTools::HSB_TO_RVB(nearest->hue(t), 1, nearest->brightness(bestDz), ptrColorIJ);
		}
	    ptrColorIJ->w = 255; //opaque
	    }

	__device__
	void getNearestSphereFromPoint(int i, int j, int* nearestSphereIndex,float* bestDz)
	    {
	    float currentNearestDistance = FLT_MAX;

	    int s = 0;
	    float2 pos = make_float2(j,i);
	    while (s < this->nbSpheres)
		{
		Sphere currentSphere = tabSphere[s];
		float hCarre = currentSphere.hCarre(pos);
		int estAbove = currentSphere.isEnDessous(hCarre);

		float dz = currentSphere.dz(hCarre);
		float range = currentSphere.distance(dz);

		// Si estAbove == False donc 0 currentNearestDistance sera forcément plus petite que range
		if (range < currentNearestDistance * estAbove)
		    {
		    currentNearestDistance = range;
		    *nearestSphereIndex = s;
		    *bestDz = dz;
		    }

		s++;
		}
	    }

    private:



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
