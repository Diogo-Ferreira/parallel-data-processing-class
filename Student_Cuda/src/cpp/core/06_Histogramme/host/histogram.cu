#include <iostream>

#include "Device.h"
#include "histogram.h"


using std::cout;
using std::endl;

const int SIZE_TAB_SM = 256;

extern __global__ void histogramd(int* ptrTabData, int n, int *ptrDevResult);

Histogram::Histogram(const Grid& grid, int tabSize) :
		tabSize(tabSize)
{
	this->ptrTabResult = new int[SIZE_TAB_SM];

	this->dataCreator = new DataCreator(tabSize);
	this->ptrTabData = dataCreator->getTabData();
	this->n = dataCreator->getLength();

	this->sizeOctetResult = sizeof(int) * SIZE_TAB_SM; // octet
	this->sizeOctetData = sizeof(int) * this->n;

	Device::malloc(&this->ptrDataDev, sizeOctetData);
	Device::memclear(this->ptrDataDev, sizeOctetData);

	Device::malloc(&this->ptrResultDev, sizeOctetResult);
	Device::memclear(this->ptrResultDev, sizeOctetResult);

	Device::memcpyHToD(this->ptrDataDev, this->ptrTabData, this->sizeOctetData);


	this->dg = grid.dg;
	this->db = grid.db;




}

Histogram::~Histogram(void)
{
	Device::free(ptrResultDev);
	Device::free(ptrDataDev);
}

int* Histogram::run()
{
	histogramd<<<dg,db,sizeOctetResult>>>(this->ptrDataDev, this->n, ptrResultDev); // asynchrone
	Device::synchronize();

	Device::memcpyDToH(ptrTabResult, ptrResultDev, sizeOctetResult);

	return ptrTabResult;
}
