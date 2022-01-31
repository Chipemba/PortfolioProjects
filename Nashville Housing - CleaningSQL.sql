/*

Nashville Housing Data cleaning in SQL

*/

Select *
From PortfolioProjects.dbo.NashvilleHousing;

-----------------------------------------------------------------------------------


-- Standadize Date format


Select SaleDate, SaleDateConverted--, CONVERT(Date, SaleDate)
From PortfolioProjects.dbo.NashvilleHousing;

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate);


-----------------------------------------------------------------------------------

--Populate Property Address Date


Select *
From PortfolioProjects.dbo.NashvilleHousing
Order By ParcelID;



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;



Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]


-----------------------------------------------------------------------------------


--Breaking out Address into Individual columns

Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing
--Order By ParcelID;

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Adress
From PortfolioProjects.dbo.NashvilleHousing;

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(256);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(256);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));




Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing;

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From PortfolioProjects.dbo.NashvilleHousing;



Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(256);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3);

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(256);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2);

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(256);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1);


-----------------------------------------------------------------------------------

--Change Y and N to YES and NO in Sold as Vacant

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2;

Select SoldAsVacant,
CASE when SoldAsVacant = 'N' then 'NO'
	 when SoldAsVacant = 'Y' then 'YES'
	 ELSE SoldAsVacant
END
From PortfolioProjects.dbo.NashvilleHousing;


Update NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'N' then 'NO'
	 	   when SoldAsVacant = 'Y' then 'YES'
	 	   ELSE SoldAsVacant
		   END
;



-----------------------------------------------------------------------------------


--Remove Duplicates using CTE
With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By UniqueID
				 ) row_num
From PortfolioProjects.dbo.NashvilleHousing
--Order By ParcelID;
)
Select *
From RowNumCTE
Where row_num > 1;


-----------------------------------------------------------------------------------


--Delet unused Coloumns

Select *
From PortfolioProjects.dbo.NashvilleHousing;


Alter Table PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

Alter Table PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate;