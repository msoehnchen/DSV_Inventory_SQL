/**
	short function to convert CargoWrite's DSTAM
	to an actual interger, which is readable by Excel as a DateValue
**/
	to_number(substr(TIMESTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2)
