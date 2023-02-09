

/* 
Cleaning Data in SQL Queries
*/

select *
from [Portfolio Project].dbo.NashvilleHousing

--Standardize Data Format

select SaleDate, convert(date,saleDate)
from [Portfolio Project].dbo.NashvilleHousing

update [Portfolio Project].dbo.NashvilleHousing
SET SaleDate = convert (date,saleDate)

--Populate Property Address Data

select *
from [Portfolio Project].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select A.ParcelID,A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(a.PropertyAddress, B.propertyAddress)
from [Portfolio Project].dbo.NashvilleHousing as A
JOIN [Portfolio Project].dbo.NashvilleHousing as B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

update A 
SET PropertyAddress = ISNULL(a.PropertyAddress, B.propertyAddress)
from [Portfolio Project].dbo.NashvilleHousing as A
JOIN [Portfolio Project].dbo.NashvilleHousing as B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]

--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from [Portfolio Project].dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
from [Portfolio Project].dbo.NashvilleHousing

Alter Table [Portfolio Project].dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table[Portfolio Project].dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from [Portfolio Project].dbo.NashvilleHousing

select OwnerAddress
from [Portfolio Project].dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '-') , 3)
--,PARSENAME(REPLACE(OwnerAddress, ',','-') , 2)
--,PARSENAME(REPLACE(OwnerAddress, ',','-') , 1)
from [Portfolio Project].dbo.NashvilleHousing

Select 
SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1) --AS Address
, SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, LEN(OwnerAddress)) --AS Address
, SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+12, LEN(OwnerAddress)) --AS Address
from [Portfolio Project].dbo.NashvilleHousing

Alter Table [Portfolio Project].dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1)


Alter Table[Portfolio Project].dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, LEN(OwnerAddress))

Alter Table[Portfolio Project].dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitState = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+12, LEN(OwnerAddress))

select *
from [Portfolio Project].dbo.NashvilleHousing

--Change Y and N to Yes and NO in "Sold as Vacant" field

select distinct(soldasvacant), count(soldasvacant)
from [Portfolio Project].dbo.NashvilleHousing
group by soldasvacant
order by 2

select SoldAsVacant
,	case when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else Soldasvacant
		End
from [Portfolio Project].dbo.NashvilleHousing

update [Portfolio Project].dbo.NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else Soldasvacant
		End


--Remove Duplicate

WITH RollnumCTE AS(
select *,
	ROW_NUMBER() over (
	partition by parcelID,
				 PropertyAddress,
				 SaleDate,
				 salePrice,
				 LegalReference
				 Order By
				    UniqueID
					) row_num

from [Portfolio Project].dbo.NashvilleHousing
--order by ParcelID
)
select *
from RollnumCTE
where row_num > 1
--order by PropertyAddress


select *
from [Portfolio Project].dbo.NashvilleHousing



--Delete unused columns

select *
from [Portfolio Project].dbo.NashvilleHousing

Alter Table [Portfolio Project].dbo.NashvilleHousing
Drop Column OwnerAddress, Taxdistrict, PropertyAddress

Alter Table [Portfolio Project].dbo.NashvilleHousing
Drop Column SaleDate


