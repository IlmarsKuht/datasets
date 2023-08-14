# Github repo to store ML datasets of the same format 
![Datset status](https://github.com/IlmarsKuht/datasets/workflows/Check%20Dataset%20Format/badge.svg) 

## Classification datasets must be formatted like this:
- No missing values, no Null values etc.
- Formatted like a CSV file and have the .csv extension
- The last field in every row (sample) is the class, classes are integers
- All values are numeric (also can be scientific)
- Every sample must have the same amount of features

If your dataset doesn't meet these requirements, but you still want to upload it, put it in a separate folder that indicates that it does not meet the format. 
Preferably you can make the folder indicating what requirement it does not meet.

Later could make it process files in external storage, becaues you cannot add big files to github.