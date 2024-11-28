-- Cleaning data in SQL Queries
select *
from Portfolio.dbo.NashvilleHousing


-- Standardizing Date Format in SaleDate Field
select SaleDateConverted, convert(date,SaleDate)
from Portfolio.dbo.NashvilleHousing


update NashvilleHousing
set SaleDate = convert(date,SaleDate)


alter table NashvilleHousing
add SaleDateConverted Date;



update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)



-- Populating Missing Property Address Data
select p1.ParcelID, p1.PropertyAddress, p1.ParcelID, p2.PropertyAddress, isnull(p1.PropertyAddress,p2.PropertyAddress)
from Portfolio.dbo.NashvilleHousing as p1
join Portfolio.dbo.NashvilleHousing as p2
on p1.ParcelID = p2.ParcelID
and p1.UniqueID <> p2.UniqueID
where p1.PropertyAddress is null


update p1
set PropertyAddress = isnull(p1.PropertyAddress,p2.PropertyAddress)
from Portfolio.dbo.NashvilleHousing as p1
join Portfolio.dbo.NashvilleHousing as p2
on p1.ParcelID = p2.ParcelID
and p1.UniqueID <> p2.UniqueID
where p1.PropertyAddress is null



-- Breaking Address into Individual Columns (Address, City, State)
select PropertyAddress
from Portfolio.dbo.NashvilleHousing


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from Portfolio.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAdress nvarchar(255);

update NashvilleHousing
set PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


alter table NashvilleHousing
add PropertyPlitCity nvarchar(255);

update NashvilleHousing
set PropertyPlitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))


select * 
from Portfolio.dbo.NashvilleHousing


-- Splitting Owner Address into Separate Columns (Address, City, State)
select OwnerAddress
from Portfolio.dbo.NashvilleHousing

select
parsename(replace(OwnerAddress,',','.'),3)
,parsename(replace(OwnerAddress,',','.'),2)
,parsename(replace(OwnerAddress,',','.'),1)
from Portfolio.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAdress nvarchar(255);

update NashvilleHousing
set OwnerSplitAdress = parsename(replace(OwnerAddress,',','.'),3)


alter table NashvilleHousing
add OwnerPlitCity nvarchar(255);

update NashvilleHousing
set OwnerPlitCity = parsename(replace(OwnerAddress,',','.'),2)


alter table NashvilleHousing
add OwnerSplitStates nvarchar(255);

update NashvilleHousing
set OwnerSplitStates = parsename(replace(OwnerAddress,',','.'),1)



-- Standardizing 'Sold as Vacant' Field (Y/N to Yes/No)
select distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio.dbo.NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from Portfolio.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end


-- Removing Duplicate Records from Nashville Housing
with RowNumCTE as (
select *,
ROW_NUMBER() over (
partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
				UniqueID
				) row_num
				
from Portfolio.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1




-- Dropping Unused Columns from Nashville Housing Table


select *
from Portfolio.dbo.NashvilleHousing


alter table Portfolio.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Portfolio.dbo.NashvilleHousing
drop column SaleDate
