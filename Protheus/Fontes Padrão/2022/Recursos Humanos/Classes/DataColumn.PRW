/*#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

///<summary>
///	
///</summary>
CLASS DataColumn FROM LongNameClass
	DATA __AllowDBNull AS LOGIC
	DATA __AutoIncrement AS LOGIC
	DATA __AutoIncrementSeed AS NUMERIC
	DATA __AutoIncrementStep AS NUMERIC
	DATA __Caption AS CHAR
	DATA __ColumnName AS CHAR
	DATA __Prefix AS CHAR
	DATA __DataType AS CHAR
	DATA __DateTimeMode
	DATA __DefaultValue
	DATA __Expression AS CHAR
	DATA __ExtendedProperties
	DATA __Length AS NUMERIC
	DATA __Decimals AS NUMERIC
	DATA __Namespace AS CHAR
	DATA __Ordinal AS NUMERIC
	DATA __ReadOnly AS LOGIC
	DATA __Table
	DATA __Unique AS LOGIC
	DATA __ColumnMapping
	DATA __Site
	DATA __Container
	DATA __DesignMode AS LOGIC

	METHOD GetAllowDBNull()
	METHOD SetAllowDBNull(value)

	METHOD GetAutoIncrement()
	METHOD SetAutoIncrement(value)

	METHOD GetAutoIncrementSeed()
	METHOD SetAutoIncrementSeed(value)

	METHOD GetAutoIncrementStep()
	METHOD SetAutoIncrementStep(value)

	METHOD GetCaption()
	METHOD SetCaption(value)

	METHOD GetColumnName()
	METHOD SetColumnName(value)

	METHOD GetPrefix()
	METHOD SetPrefix(value)

	METHOD GetDataType()
	METHOD SetDataType(value)

	METHOD GetDateTimeMode()
	METHOD SetDateTimeMode(value)

	METHOD GetDefaultValue()
	METHOD SetDefaultValue(value)

	METHOD GetExpression()
	METHOD SetExpression(value)

	METHOD GetExtendedProperties()

	METHOD GetMaxLength()
	METHOD SetMaxLength(value)

	METHOD GetNamespace()
	METHOD SetNamespace(value)

	METHOD GetOrdinal()

	METHOD GetReadOnly()
	METHOD SetReadOnly(value)

	METHOD GetTable()

	METHOD GetUnique()
	METHOD SetUnique(value)

	METHOD GetColumnMapping()
	METHOD SetColumnMapping(value)

	METHOD GetSite()
	METHOD SetSite(value)

	METHOD GetContainer()

	METHOD GetDesignMode()


	METHOD SetOrdinal(ordinal)
	METHOD ToString()
	METHOD add_Disposed(value)
	METHOD remove_Disposed(value)
	METHOD Dispose()
	METHOD GetService(service)
	METHOD GetType()
	METHOD Equals(obj)
	METHOD GetHashCode()

ENDCLASS


///<summary>
///	
///</summary>
METHOD New(ColumnName, Caption, DataType, Length, Decimals) CLASS DataColumn  
	SELF:__ColumnName:= ColumnName
	SELF:__Caption:= Caption
	SELF:__DataType:= DataType
	SELF:__Length:= Length
	SELF:__Decimals:= Decimals	
RETURN SELF



///<summary>
///	
///</summary>
METHOD GetAllowDBNull() CLASS DataColumn
RETURN SELF:__AllowDBNull

///<summary>
///	
///</summary>
METHOD SetAllowDBNull(value) CLASS DataColumn
RETURN SELF:__AllowDBNull:= value


///<summary>
///	
///</summary>
METHOD GetAutoIncrement() CLASS DataColumn
RETURN SELF:__AutoIncrement

///<summary>
///	
///</summary>
METHOD SetAutoIncrement(value) CLASS DataColumn
RETURN SELF:__AutoIncrement:= value


///<summary>
///	
///</summary>
METHOD GetAutoIncrementSeed() CLASS DataColumn
RETURN SELF:__AutoIncrementSeed

///<summary>
///	
///</summary>
METHOD SetAutoIncrementSeed(value) CLASS DataColumn
RETURN SELF:__AutoIncrementSeed:= value


///<summary>
///	
///</summary>
METHOD GetAutoIncrementStep() CLASS DataColumn
RETURN SELF:__AutoIncrementStep

///<summary>
///	
///</summary>
METHOD SetAutoIncrementStep(value) CLASS DataColumn
RETURN SELF:__AutoIncrementStep:= value


///<summary>
///	
///</summary>
METHOD GetCaption() CLASS DataColumn
RETURN SELF:__Caption

///<summary>
///	
///</summary>
METHOD SetCaption(value) CLASS DataColumn
RETURN SELF:__Caption:= value


///<summary>
///	
///</summary>
METHOD GetColumnName() CLASS DataColumn
RETURN SELF:__ColumnName

///<summary>
///	
///</summary>
METHOD SetColumnName(value) CLASS DataColumn
RETURN SELF:__ColumnName:= value


///<summary>
///	
///</summary>
METHOD GetPrefix() CLASS DataColumn
RETURN SELF:__Prefix

///<summary>
///	
///</summary>
METHOD SetPrefix(value) CLASS DataColumn
RETURN SELF:__Prefix:= value


///<summary>
///	
///</summary>
METHOD GetDataType() CLASS DataColumn
RETURN SELF:__DataType

///<summary>
///	
///</summary>
METHOD SetDataType(value) CLASS DataColumn
RETURN SELF:__DataType:= value


///<summary>
///	
///</summary>
METHOD GetDateTimeMode() CLASS DataColumn
RETURN SELF:__DateTimeMode

///<summary>
///	
///</summary>
METHOD SetDateTimeMode(value) CLASS DataColumn
RETURN SELF:__DateTimeMode:= value


///<summary>
///	
///</summary>
METHOD GetDefaultValue() CLASS DataColumn
RETURN SELF:__DefaultValue

///<summary>
///	
///</summary>
METHOD SetDefaultValue(value) CLASS DataColumn
RETURN SELF:__DefaultValue:= value


///<summary>
///	
///</summary>
METHOD GetExpression() CLASS DataColumn
RETURN SELF:__Expression

///<summary>
///	
///</summary>
METHOD SetExpression(value) CLASS DataColumn
RETURN SELF:__Expression:= value


///<summary>
///	
///</summary>
METHOD GetExtendedProperties() CLASS DataColumn
RETURN SELF:__ExtendedProperties



///<summary>
///	
///</summary>
METHOD GetLength() CLASS DataColumn
RETURN SELF:__Length	


///<summary>
///	
///</summary>
METHOD SetLength(value) CLASS DataColumn	
RETURN SELF:__Length:= value


///<summary>
///	
///</summary>
METHOD GetDecimals() CLASS DataColumn
RETURN SELF:__Decimals


///<summary>
///	
///</summary>
METHOD SetDecimals(value) CLASS DataColumn
RETURN SELF:__Decimals:= value


///<summary>
///	
///</summary>
METHOD GetNamespace() CLASS DataColumn
RETURN SELF:__Namespace

///<summary>
///	
///</summary>
METHOD SetNamespace(value) CLASS DataColumn
RETURN SELF:__Namespace:= value


///<summary>
///	
///</summary>
METHOD GetOrdinal() CLASS DataColumn
RETURN SELF:__Ordinal


///<summary>
///	
///</summary>
METHOD GetReadOnly() CLASS DataColumn
RETURN SELF:__ReadOnly

///<summary>
///	
///</summary>
METHOD SetReadOnly(value) CLASS DataColumn
RETURN SELF:__ReadOnly:= value


///<summary>
///	
///</summary>
METHOD GetTable() CLASS DataColumn
RETURN SELF:__Table


///<summary>
///	
///</summary>
METHOD GetUnique() CLASS DataColumn
RETURN SELF:__Unique

///<summary>
///	
///</summary>
METHOD SetUnique(value) CLASS DataColumn
RETURN SELF:__Unique:= value


///<summary>
///	
///</summary>
METHOD GetColumnMapping() CLASS DataColumn
RETURN SELF:__ColumnMapping

///<summary>
///	
///</summary>
METHOD SetColumnMapping(value) CLASS DataColumn
RETURN SELF:__ColumnMapping:= value


///<summary>
///	
///</summary>
METHOD GetSite() CLASS DataColumn
RETURN SELF:__Site

///<summary>
///	
///</summary>
METHOD SetSite(value) CLASS DataColumn
RETURN SELF:__Site:= value


///<summary>
///	
///</summary>
METHOD GetContainer() CLASS DataColumn
RETURN SELF:__Container


///<summary>
///	
///</summary>
METHOD GetDesignMode() CLASS DataColumn
RETURN SELF:__DesignMode



///<summary>
///	
///</summary>
///<param name="ordinal" type="Int32"></param>
///<returns></returns>
METHOD SetOrdinal(ordinal) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD ToString() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="EventHandler"></param>
///<returns></returns>
METHOD add_Disposed(value) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="EventHandler"></param>
///<returns></returns>
METHOD remove_Disposed(value) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Dispose() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<param name="service" type="Type"></param>
///<returns></returns>
METHOD GetService(service) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD GetType() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<param name="obj" type="Object"></param>
///<returns></returns>
METHOD Equals(obj) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD GetHashCode() CLASS DataColumn
	
RETURN









#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

///<summary>
///	
///</summary>
CLASS DataColumn FROM LongNameClass
	DATA __AllowDBNull AS LOGIC
	DATA __AutoIncrement AS LOGIC
	DATA __AutoIncrementSeed AS NUMERIC
	DATA __AutoIncrementStep AS NUMERIC
	DATA __Caption AS CHAR
	DATA __ColumnName AS CHAR
	DATA __Prefix AS CHAR
	DATA __DataType
	DATA __DateTimeMode
	DATA __DefaultValue
	DATA __Expression AS CHAR
	DATA __ExtendedProperties
	DATA __Length AS NUMERIC
	DATA __Decimals AS NUMERIC
	
	DATA __Namespace AS CHAR
	DATA __Ordinal AS NUMERIC
	DATA __ReadOnly AS LOGIC
	DATA __Table
	DATA __Unique AS LOGIC
	DATA __ColumnMapping
	DATA __Site
	DATA __Container
	DATA __DesignMode AS LOGIC
	
	
	METHOD New(cFieldName, cTitle, cType, nWidth, nDecimals) CONSTRUCTOR

	METHOD GetAllowDBNull()
	METHOD SetAllowDBNull(value)

	METHOD GetAutoIncrement()
	METHOD SetAutoIncrement(value)

	METHOD GetAutoIncrementSeed()
	METHOD SetAutoIncrementSeed(value)

	METHOD GetAutoIncrementStep()
	METHOD SetAutoIncrementStep(value)

	METHOD GetCaption()
	METHOD SetCaption(value)

	METHOD GetColumnName()
	METHOD SetColumnName(value)

	METHOD GetPrefix()
	METHOD SetPrefix(value)

	METHOD GetDataType()
	METHOD SetDataType(value)

	METHOD GetDateTimeMode()
	METHOD SetDateTimeMode(value)

	METHOD GetDefaultValue()
	METHOD SetDefaultValue(value)

	METHOD GetExpression()
	METHOD SetExpression(value)

	METHOD GetExtendedProperties()

	METHOD GetLength()
	METHOD SetLength(value)

	METHOD GetDecimals()
	METHOD SetDecimals(value)

	METHOD GetNamespace()
	METHOD SetNamespace(value)

	METHOD GetOrdinal()

	METHOD GetReadOnly()
	METHOD SetReadOnly(value)

	METHOD GetTable()

	METHOD GetUnique()
	METHOD SetUnique(value)

	METHOD GetColumnMapping()
	METHOD SetColumnMapping(value)

	//METHOD GetSite()
	//METHOD SetSite(value)

	METHOD GetContainer()

	METHOD GetDesignMode()


	METHOD SetOrdinal(ordinal)
	METHOD ToString()
	METHOD Dispose()
	METHOD GetService(service)
	METHOD GetType()
	//METHOD Equals(obj)
	//METHOD GetHashCode()
ENDCLASS



///<summary>
///	
///</summary>
METHOD GetAllowDBNull() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetAllowDBNull(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetAutoIncrement() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetAutoIncrement(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetAutoIncrementSeed() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetAutoIncrementSeed(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetAutoIncrementStep() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetAutoIncrementStep(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetCaption() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetCaption(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetColumnName() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetColumnName(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetPrefix() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetPrefix(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetDataType() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetDataType(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetDateTimeMode() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetDateTimeMode(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetDefaultValue() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetDefaultValue(value) CLASS DataColumn	
RETURN



///<summary>
///	
///</summary>
METHOD GetExpression() CLASS DataColumn	
RETURN


///<summary>
///	
///</summary>
METHOD SetExpression(value) CLASS DataColumn
RETURN



///<summary>
///	
///</summary>
//METHOD GetExtendedProperties() CLASS DataColumn	
//RETURN




///<summary>
///	
///</summary>
METHOD GetNamespace() CLASS DataColumn
RETURN


///<summary>
///	
///</summary>
METHOD SetNamespace(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetOrdinal() CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetReadOnly() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetReadOnly(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetTable() CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetUnique() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetUnique(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetColumnMapping() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetColumnMapping(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetSite() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
METHOD SetSite(value) CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetContainer() CLASS DataColumn
	
RETURN



///<summary>
///	
///</summary>
METHOD GetDesignMode() CLASS DataColumn
	
RETURN




///<summary>
///	
///</summary>
///<param name="ordinal" type="Int32"></param>
///<returns></returns>
METHOD SetOrdinal(ordinal) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD ToString() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="EventHandler"></param>
///<returns></returns>
METHOD add_Disposed(value) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="EventHandler"></param>
///<returns></returns>
METHOD remove_Disposed(value) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Dispose() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<param name="service" type="Type"></param>
///<returns></returns>
METHOD GetService(service) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD GetType() CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<param name="obj" type="Object"></param>
///<returns></returns>
METHOD Equals(obj) CLASS DataColumn
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD GetHashCode() CLASS DataColumn
	
RETURN



*/