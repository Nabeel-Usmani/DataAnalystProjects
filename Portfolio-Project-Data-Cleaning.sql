/* Data Cleaning in SQL */

Select *
From PortfolioProject2.dbo.[NashVille-Housing]

------------------------------------------------------------------------------------------------

--Standardize Date Format
Select SaleDateConverted, Convert(date,SaleDate)
From PortfolioProject2.dbo.[NashVille-Housing]

Update PortfolioProject2.dbo.[NashVille-Housing]
Set SaleDate = CONVERT(date,SaleDate)

Alter Table PortfolioProject2.dbo.[NashVille-Housing]
Add SaleDateConverted Date;

Update PortfolioProject2.dbo.[NashVille-Housing]
Set SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------
--Populating Property Address
Select PropertyAddress
from PortfolioProject2.dbo.[NashVille-Housing]
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject2.dbo.[NashVille-Housing] a
	Join PortfolioProject2.dbo.[NashVille-Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject2.dbo.[NashVille-Housing] a
	Join PortfolioProject2.dbo.[NashVille-Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------

--Breaking Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject2.dbo.[NashVille-Housing]

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
	SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject2.dbo.[NashVille-Housing]

Alter Table PortfolioProject2.dbo.[NashVille-Housing]
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject2.dbo.[NashVille-Housing]
Set PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 

Alter Table PortfolioProject2.dbo.[NashVille-Housing]
Add PropertySplitCity nvarchar(255);

Update PortfolioProject2.dbo.[NashVille-Housing]
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject2.dbo.[NashVille-Housing]

Select PARSENAME (REPLACE (OwnerAddress, ',' , '.'), 3)
,PARSENAME (REPLACE (OwnerAddress, ',' , '.' ), 2)
,PARSENAME (REPLACE (OwnerAddress, ',' , '.' ) , 1)
from PortfolioProject2.dbo.[NashVille-Housing] 

Alter Table PortfolioProject2.dbo.[NashVille-Housing]
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject2.dbo.[NashVille-Housing]
Set OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',' , '.'), 3)

Alter Table PortfolioProject2.dbo.[NashVille-Housing]
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject2.dbo.[NashVille-Housing]
Set OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress, ',' , '.'), 2)

Alter Table PortfolioProject2.dbo.[NashVille-Housing]
Add OwnerSplitState nvarchar(255);

Update PortfolioProject2.dbo.[NashVille-Housing]
Set OwnerSplitState = PARSENAME (REPLACE (OwnerAddress, ',' , '.'), 1)

------------------------------------------------------------------------------------------------
--Changing Y and N to 'YES' OR 'NO' to "Sold as Vacant"

Select Distinct (SoldasVacant), Count(SoldasVacant)
from PortfolioProject2.dbo.[NashVille-Housing]
Group by (SoldAsVacant)
Order by (SoldAsVacant)

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END 
from PortfolioProject2.dbo.[NashVille-Housing]

Update PortfolioProject2.dbo.[NashVille-Housing]
Set SoldASVacant = Case When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END 

------------------------------------------------------------------------------------------------
--Removing Duplicates (Not Recommended)

--Just Deleting the Duplicates to showcase in the Portfolio Project
With RowNumCTE as(
Select *,
Row_Number() Over(
Partition By ParcelID,
			 SaleDate,
			 SalePrice,
			 LegalReference
Order by 
	UniqueID
	) row_num
from PortfolioProject2.dbo.[NashVille-Housing]
--order by ParcelID
) 
Select *
from RowNumCTE
where row_num > 1

------------------------------------------------------------------------------------------------
--Deleting Unused Columns
Select *
from PortfolioProject2.dbo.[NashVille-Housing]

Alter Table PortfolioProject2.dbo.[NashVille-Housing]
Drop Column PropertyAddress,OwnerAddress,TaxDistrict
