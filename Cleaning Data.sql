-- Cleaning data in SQL Queries
select *
from Portfolio.dbo.NashvilleHousing


-- Standardize Date Format
select SaleDateConverted, convert(date,SaleDate)
from Portfolio.dbo.NashvilleHousing


update NashvilleHousing
set SaleDate = convert(date,SaleDate)


alter table NashvilleHousing
add SaleDateConverted Date;



update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)



-- Populate Property Address data
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



-- Breaking out Address into Individual Columns (Addressm, City, State)
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



-- Change Y and N to Yes and No in 'Sold as vacant' field
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


-- Remove Duplicate
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




-- Deleted Unused Columns


select *
from Portfolio.dbo.NashvilleHousing


alter table Portfolio.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Portfolio.dbo.NashvilleHousing
drop column SaleDate