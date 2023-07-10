use Housing 
SELECT * from [Housing Dataset] 

----1.Date formatting----
ALTER TABLE [housing dataset]
Add converted_SaleDate Date;

Update [Housing Dataset]
SET converted_SaleDate = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------------------------------------------------------------------------
----2.Populating missing property adress----
--check the missing data
select PropertyAddress from [Housing Dataset] where PropertyAddress is null

--populate the address where parcelid is same
select a.UniqueID,a.parcelid,b.parcelid,a.propertyaddress,b.propertyaddress 
from [Housing Dataset] a join [Housing Dataset] b on a.parcelid=b.parcelid
where a.PropertyAddress is null and b.PropertyAddress is not null

--update the table
update a
set PropertyAddress=ISNULL(a.propertyaddress,b.propertyaddress)
from [Housing Dataset] a join [Housing Dataset] b on a.parcelid=b.parcelid
where a.PropertyAddress is null and b.PropertyAddress is not null

------------------------------------------------------------------------------------------------------------------------------------------------------------
----3.splitting address columns into address,city,state----
--Property address breaking
alter table [Housing dataset]
add propertyaddress1 Nvarchar(250);

update [Housing Dataset]
set propertyaddress1=SUBSTRING(propertyaddress,1, charindex(',',propertyaddress) -1)

alter table [housing dataset]
add propertyaddress2 Nvarchar(250)

update [Housing Dataset]
set propertyaddress2 = SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,LEN(propertyaddress))

--Owner address breaking
alter table [housing dataset]
add Owneraddress1 Nvarchar(255)

update [Housing Dataset]
set owneraddress1= PARSENAME(replace(owneraddress,',','.'),3)

alter table [housing dataset]
add Owneraddress2 Nvarchar(255)

update [Housing Dataset]
set owneraddress2= PARSENAME(replace(owneraddress,',','.'),2)

alter table [housing dataset]
add Owneraddress3 Nvarchar(255)

update [Housing Dataset]
set owneraddress3= PARSENAME(replace(owneraddress,',','.'),1)

------------------------------------------------------------------------------------------------------------------------------------------------------------
----4.Remove duplicates----
with tempCTE as(
select *, ROW_NUMBER() over(partition by
                          parcelid,
						  propertyaddress,
						  saleprice,
						  legalreference,
						  saledate
						  order by uniqueid)
						  as row_num
from [Housing Dataset])
--select * from tempCTE where row_num>1
delete from tempCTE where row_num>1

------------------------------------------------------------------------------------------------------------------------------------------------------------
----5.Remove unused column----
select * from [Housing Dataset]

alter table [housing dataset]
drop column propertyaddress,owneraddress,taxdistrict,saledate

