Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
select *
from NashvilleHousing		
--where PropertyAddress is null
order by ParcelID;



select a.ParcelID,a.PropertyAddress , b.ParcelID , b.PropertyAddress,isnull(a.PropertyAddress , b.PropertyAddress) as new_PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into In

select PropertyAddress
from NashvilleHousing


select PropertyAddress,
substring(PropertyAddress , 1 ,CHARINDEX(',',PropertyAddress)-1) as house_adress,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as city_name ,
/*substring(
	PropertyAddress,
	CHARINDEX(' ' , PropertyAddress) ,
	CHARINDEX(' ',PropertyAddress,CHARINDEX(' ' , PropertyAddress) + 2)  - CHARINDEX(' ',PropertyAddress) - 2
	) as county_name,*/
substring(PropertyAddress , 1 ,CHARINDEX(' ',PropertyAddress)) as house_number,
CHARINDEX(' ',PropertyAddress,CHARINDEX(' ' , PropertyAddress) + 2)  - CHARINDEX(' ',PropertyAddress) - 2 as scend_space
from NashvilleHousing




Alter TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress  = substring(PropertyAddress , 1 ,CHARINDEX(',',PropertyAddress)-1);

Alter TABLE NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity  = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

/*select PropertySplitCity , PropertySplitAddress
from NashvilleHousing*/





select OwnerAddress
from NashvilleHousing

select
PARSENAME(replace(OwnerAddress , ',' , '.') , 3),
PARSENAME(replace(OwnerAddress , ',' , '.') , 2),
PARSENAME(replace(OwnerAddress , ',' , '.') , 1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


select OwnerSplitAddress , OwnerSplitCity , OwnerSplitState
from NashvilleHousing





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct(SoldAsVacant) , count(SoldAsVacant) 
from NashvilleHousing
group by SoldAsVacant
order by 2;


select SoldAsVacant,
	Case when SoldAsVacant  = 'Y' then 'Yes'
		when SoldAsVacant  = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant  = 'Y' then 'Yes'
		when SoldAsVacant  = 'N' then 'No'
		else SoldAsVacant
		end;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
delete 
from RowNumCTE
where row_num > 1
--order by PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select *
from NashvilleHousing