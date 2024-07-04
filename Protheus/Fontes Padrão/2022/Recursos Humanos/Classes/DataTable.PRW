#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

///<summary>
///	
///</summary>
CLASS DataTable FROM LongNameClass
	DATA __Rows AS OBJECT
	DATA __Columns AS OBJECT
	                
	METHOD New() CONSTRUCTOR
		
	METHOD GetRows()
	METHOD SetRows(value)

	METHOD GetColumns()
	METHOD SetColumns(value)
ENDCLASS


///<summary>
///	
///</summary>
METHOD New() CLASS DataTable  
	SELF:__Rows:= ArrayList():New()
	SELF:__Columns:= ArrayList():New()
RETURN SELF



///<summary>
///	
///</summary>
METHOD GetRows() CLASS DataTable
RETURN SELF:__Rows

///<summary>
///	
///</summary>
METHOD SetRows(value) CLASS DataTable
RETURN SELF:__Rows:= value


///<summary>
///	
///</summary>
METHOD GetColumns() CLASS DataTable
RETURN SELF:__Columns

///<summary>
///	
///</summary>
METHOD SetColumns(value) CLASS DataTable
RETURN SELF:__Columns:= value

