# City of Edmonton Housing Dataset:
The following dataset was constructed for my Master's thesis on impacts of LRT stations on housing prices. It originally contained 2.4 million observations from 2012 to 2022 of every property within the City of Edmonton during those years. Due to the size of the data (of multiple files), I cannot upload the raw csvs directly.

**I have subset the data to 10,000 observations (8,000 training observations and 2,000 test observations) in 2019 for future use on alternate models.**

![edmontonhousingdata](https://user-images.githubusercontent.com/52394699/180631668-776f6203-99ef-4bf8-99c8-ae8102b8fcd3.png)

## Variables:
1. **realprice**: The real assessed value of the home, in 2002 dollars.
2. **neighbourhood dummies**: Indicator for neighbourhood.
3. **actualyearbuilt**: Year home was built.
4. **zoning dummies**: Indicator for zoning designations. (https://webdocs.edmonton.ca/InfraPlan/zoningbylaw/Matrix/Matrix_PDF/Zoning_Matrix_Printable.pdf)
5. **lotsize**: Lot size in square metres.
6. **garagebinary**: Indicates whether the home has a garage or not.
7. **distance**: Represents the distance to downtown (approximated by City Hall; calculated by haversine formula and given in kms)
8. **structuresize**: Size of the main structure on the property, given in square metres.
9. **distancelrtopen**: kms from nearest open LRT station.
10. **distancelrtvalleylinese**: kms from nearest unopen (but under construction) Valley Line SE station.
11. **distancelrtvalleylinewest**: kms from nearest unopen (but announced) Valley Line West station.
12. **apartment**: Indicates whether the property is an apartment/condo.
13. **theftcrime**: Incidents of robberies, BNEs, thefts of/from vehicles in that neighbourhood in 2019, divided by the number of properties in that neighbourhood in 2019.
14. **personcrime**: Similar to theftcrime, but with assaults and sexual assaults. 

## Sources: 
This data comes primarily^ from merging together several tables from the City of Edmonton open data portal. 

^ Data for the Valley Line stations is unavailable as of July 2022, and was constructed by me.

