/*

Cleaning Data in SQL Queries

*/

Select *
From ProjectPortfolio.dbo.[Nashville Housing] 

--Standard Date Format

Select SaleDateConverted, CONVERT (Date,Saledate)
From ProjectPortfolio.dbo.[Nashville Housing] 

Update [Nashville Housing] 
SET SaleDate = CONVERT (Date,SaleDate)

ALTER TABLE [Nashville Housing]
Add SaleDateConverted Date;

Update [Nashville Housing] 
SET SaleDateConverted = CONVERT (Date,SaleDate)


--Populate Property Address data

Select * 
From ProjectPortfolio.dbo.[Nashville Housing] 
--where PropertyAddress is null
order by ParcelID 


Select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress )
From ProjectPortfolio.dbo.[Nashville Housing] a
JOIN ProjectPortfolio.dbo.[Nashville Housing] b
     on a.ParcelID = b.ParcelID 
	 AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null


Update a 
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress )
From ProjectPortfolio.dbo.[Nashville Housing] a
JOIN ProjectPortfolio.dbo.[Nashville Housing] b
     on a.ParcelID = b.ParcelID 
	 AND a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null



--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress  
From ProjectPortfolio.dbo.[Nashville Housing] 
--where PropertyAddress is null
--order by ParcelID 

SELECT
SUBSTRING (PropertyAddress , 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress ))as Address
From ProjectPortfolio.dbo.[Nashville Housing] 



ALTER TABLE [Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing] 
SET PropertySplitAddress = SUBSTRING (PropertyAddress , 1, CHARINDEX(',', PropertyAddress)-1)



ALTER TABLE [Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing] 
SET PropertySplitCity = SUBSTRING (PropertyAddress , CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress ))

Select *
From [ProjectPortfolio].dbo.[Nashville Housing] 




Select OwnerAddress 
From [ProjectPortfolio].dbo.[Nashville Housing] 

Select 
PARSENAME( REPLACE (OwnerAddress,',', '.'), 3)
,PARSENAME( REPLACE (OwnerAddress,',', '.'), 2)
,PARSENAME( REPLACE (OwnerAddress,',', '.'), 1)
From [ProjectPortfolio].dbo.[Nashville Housing] 




ALTER TABLE [Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing] 
SET OwnerSplitAddress = PARSENAME( REPLACE (OwnerAddress,',', '.'), 3)



ALTER TABLE [Nashville Housing]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing] 
SET OwnerSplitCity = PARSENAME( REPLACE (OwnerAddress,',', '.'), 2)


ALTER TABLE [Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing] 
SET OwnerSplitState = PARSENAME( REPLACE (OwnerAddress,',', '.'), 1)


Select *
From [ProjectPortfolio].dbo.[Nashville Housing] 



--Change Y and N to Yes and No in "Sold As Vacant" field


Select Distinct(SoldAsVacant ), COUNT ( SoldAsVacant)
From [ProjectPortfolio].dbo.[Nashville Housing] 
Group By SoldAsVacant 
Order By 2 



Select SoldAsVacant 
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From [ProjectPortfolio].dbo.[Nashville Housing] 


Update [Nashville Housing] 
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END



--Remove Duplicates

WITH RowNumCTE AS(
Select *,
  ROW_NUMBER () OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
			       UniqueID
				   ) row_num
From ProjectPortfolio.dbo.[Nashville Housing] 
--order by ParcelID 
)
Select *
From RowNumCTE
where row_num >1
order by PropertyAddress 


--Delete unused columns

Select *
From [ProjectPortfolio].dbo.[Nashville Housing] 


ALTER TABLE [ProjectPortfolio].dbo.[Nashville Housing] 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE [ProjectPortfolio].dbo.[Nashville Housing] 
DROP COLUMN SaleDate

