#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
/*
///<summary>
///	
///</summary>
CLASS DataSet FROM LongNameClass
	DATA __RemotingFormat
	DATA __SchemaSerializationMode
	DATA __CaseSensitive AS LOGIC
	DATA __DefaultViewManager
	DATA __EnforceConstraints AS LOGIC
	DATA __DataSetName AS CHAR
	DATA __Namespace AS CHAR
	DATA __Prefix AS CHAR
	DATA __ExtendedProperties
	DATA __HasErrors AS LOGIC
	DATA __IsInitialized AS LOGIC
	DATA __Locale
	DATA __Site
	DATA __Relations
	DATA __Tables
	DATA __Container
	DATA __DesignMode AS LOGIC

	METHOD GetRemotingFormat()
	METHOD SetRemotingFormat(value)

	METHOD GetSchemaSerializationMode()
	METHOD SetSchemaSerializationMode(value)

	METHOD GetCaseSensitive()
	METHOD SetCaseSensitive(value)

	METHOD GetDefaultViewManager()

	METHOD GetEnforceConstraints()
	METHOD SetEnforceConstraints(value)

	METHOD GetDataSetName()
	METHOD SetDataSetName(value)

	METHOD GetNamespace()
	METHOD SetNamespace(value)

	METHOD GetPrefix()
	METHOD SetPrefix(value)

	METHOD GetExtendedProperties()

	METHOD GetHasErrors()

	METHOD GetIsInitialized()

	METHOD GetLocale()
	METHOD SetLocale(value)

	METHOD GetSite()
	METHOD SetSite(value)

	METHOD GetRelations()

	METHOD GetTables()

	METHOD GetContainer()

	METHOD GetDesignMode()


	METHOD GetObjectData(info, context)
	METHOD AcceptChanges()
	METHOD add_MergeFailed(value)
	METHOD remove_MergeFailed(value)
	METHOD add_Initialized(value)
	METHOD remove_Initialized(value)
	METHOD BeginInit()
	METHOD EndInit()
	METHOD Clear()
	METHOD Clone()
	METHOD Copy()
	//METHOD GetChanges()
	METHOD GetChanges(rowStates)
	METHOD GetXml()
	METHOD GetXmlSchema()
	//METHOD HasChanges()
	METHOD HasChanges(rowStates)
	METHOD InferXmlSchema(reader, nsArray)
	//METHOD InferXmlSchema(stream, nsArray)
	//METHOD InferXmlSchema(reader, nsArray)
	//METHOD InferXmlSchema(fileName, nsArray)
	METHOD ReadXmlSchema(reader)
	//METHOD ReadXmlSchema(stream)
	//METHOD ReadXmlSchema(reader)
	//METHOD ReadXmlSchema(fileName)
	METHOD WriteXmlSchema(stream)
	//METHOD WriteXmlSchema(writer)
	//METHOD WriteXmlSchema(writer)
	//METHOD WriteXmlSchema(fileName)
	//METHOD ReadXml(reader)
	METHOD ReadXml(stream)
	//METHOD ReadXml(reader)
	//METHOD ReadXml(fileName)
	//METHOD ReadXml(reader, mode)
	//METHOD ReadXml(stream, mode)
	//METHOD ReadXml(reader, mode)
	//METHOD ReadXml(fileName, mode)
	METHOD WriteXml(stream)
	METHOD WriteXml(writer)
	METHOD WriteXml(writer)
	METHOD WriteXml(fileName)
	METHOD WriteXml(stream, mode)
	METHOD WriteXml(writer, mode)
	METHOD WriteXml(writer, mode)
	METHOD WriteXml(fileName, mode)
	METHOD Merge(dataSet)
	METHOD Merge(dataSet, preserveChanges)
	METHOD Merge(dataSet, preserveChanges, missingSchemaAction)
	METHOD Merge(table)
	METHOD Merge(table, preserveChanges, missingSchemaAction)
	METHOD Merge(rows)
	METHOD Merge(rows, preserveChanges, missingSchemaAction)
	METHOD RejectChanges()
	METHOD Reset()
	METHOD GetDataSetSchema(schemaSet)
	METHOD Load(reader, loadOption, errorHandler, tables)
	METHOD Load(reader, loadOption, tables)
	METHOD Load(reader, loadOption, tables)
	METHOD CreateDataReader()
	METHOD CreateDataReader(dataTables)
	METHOD add_Disposed(value)
	METHOD remove_Disposed(value)
	METHOD Dispose()
	METHOD GetService(service)
	METHOD ToString()
	METHOD GetType()
	METHOD Equals(obj)
	METHOD GetHashCode()

ENDCLASS

///<summary>
///	
///</summary>
METHOD GetRemotingFormat() CLASS DataSet
RETURN SELF:__RemotingFormat

///<summary>
///	
///</summary>
METHOD SetRemotingFormat(value) CLASS DataSet
RETURN SELF:__RemotingFormat:= value


///<summary>
///	
///</summary>
METHOD GetSchemaSerializationMode() CLASS DataSet
RETURN SELF:__SchemaSerializationMode

///<summary>
///	
///</summary>
METHOD SetSchemaSerializationMode(value) CLASS DataSet
RETURN SELF:__SchemaSerializationMode:= value


///<summary>
///	
///</summary>
METHOD GetCaseSensitive() CLASS DataSet
RETURN SELF:__CaseSensitive

///<summary>
///	
///</summary>
METHOD SetCaseSensitive(value) CLASS DataSet
RETURN SELF:__CaseSensitive:= value


///<summary>
///	
///</summary>
METHOD GetDefaultViewManager() CLASS DataSet
RETURN SELF:__DefaultViewManager


///<summary>
///	
///</summary>
METHOD GetEnforceConstraints() CLASS DataSet
RETURN SELF:__EnforceConstraints

///<summary>
///	
///</summary>
METHOD SetEnforceConstraints(value) CLASS DataSet
RETURN SELF:__EnforceConstraints:= value


///<summary>
///	
///</summary>
METHOD GetDataSetName() CLASS DataSet
RETURN SELF:__DataSetName

///<summary>
///	
///</summary>
METHOD SetDataSetName(value) CLASS DataSet
RETURN SELF:__DataSetName:= value


///<summary>
///	
///</summary>
METHOD GetNamespace() CLASS DataSet
RETURN SELF:__Namespace

///<summary>
///	
///</summary>
METHOD SetNamespace(value) CLASS DataSet
RETURN SELF:__Namespace:= value


///<summary>
///	
///</summary>
METHOD GetPrefix() CLASS DataSet
RETURN SELF:__Prefix

///<summary>
///	
///</summary>
METHOD SetPrefix(value) CLASS DataSet
RETURN SELF:__Prefix:= value


///<summary>
///	
///</summary>
METHOD GetExtendedProperties() CLASS DataSet
RETURN SELF:__ExtendedProperties


///<summary>
///	
///</summary>
METHOD GetHasErrors() CLASS DataSet
RETURN SELF:__HasErrors


///<summary>
///	
///</summary>
METHOD GetIsInitialized() CLASS DataSet
RETURN SELF:__IsInitialized


///<summary>
///	
///</summary>
METHOD GetLocale() CLASS DataSet
RETURN SELF:__Locale

///<summary>
///	
///</summary>
METHOD SetLocale(value) CLASS DataSet
RETURN SELF:__Locale:= value


///<summary>
///	
///</summary>
METHOD GetSite() CLASS DataSet
RETURN SELF:__Site

///<summary>
///	
///</summary>
METHOD SetSite(value) CLASS DataSet
RETURN SELF:__Site:= value


///<summary>
///	
///</summary>
METHOD GetRelations() CLASS DataSet
RETURN SELF:__Relations


///<summary>
///	
///</summary>
METHOD GetTables() CLASS DataSet
RETURN SELF:__Tables


///<summary>
///	
///</summary>
METHOD GetContainer() CLASS DataSet
RETURN SELF:__Container


///<summary>
///	
///</summary>
METHOD GetDesignMode() CLASS DataSet
RETURN SELF:__DesignMode



///<summary>
///	
///</summary>
///<param name="info" type="SerializationInfo"></param>
///<param name="context" type="StreamingContext"></param>
///<returns></returns>
METHOD GetObjectData(info, context) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD AcceptChanges() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="MergeFailedEventHandler"></param>
///<returns></returns>
METHOD add_MergeFailed(value) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="MergeFailedEventHandler"></param>
///<returns></returns>
METHOD remove_MergeFailed(value) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="EventHandler"></param>
///<returns></returns>
METHOD add_Initialized(value) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="EventHandler"></param>
///<returns></returns>
METHOD remove_Initialized(value) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD BeginInit() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD EndInit() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Clear() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Clone() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Copy() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
//METHOD GetChanges() CLASS DataSet
	
//RETURN


///<summary>
///	
///</summary>
///<param name="rowStates" type="DataRowState"></param>
///<returns></returns>
METHOD GetChanges(rowStates) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD GetXml() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD GetXmlSchema() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
//METHOD HasChanges() CLASS DataSet

//RETURN


///<summary>
///	
///</summary>
///<param name="rowStates" type="DataRowState"></param>
///<returns></returns>
METHOD HasChanges(rowStates) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="XmlReader"></param>
///<param name="nsArray" type="String[]"></param>
///<returns></returns>
METHOD InferXmlSchema(reader, nsArray) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="stream" type="Stream"></param>
///<param name="nsArray" type="String[]"></param>
///<returns></returns>
METHOD InferXmlSchema(stream, nsArray) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="TextReader"></param>
///<param name="nsArray" type="String[]"></param>
///<returns></returns>
METHOD InferXmlSchema(reader, nsArray) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="fileName" type="String"></param>
///<param name="nsArray" type="String[]"></param>
///<returns></returns>
METHOD InferXmlSchema(fileName, nsArray) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="XmlReader"></param>
///<returns></returns>
METHOD ReadXmlSchema(reader) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="stream" type="Stream"></param>
///<returns></returns>
METHOD ReadXmlSchema(stream) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="TextReader"></param>
///<returns></returns>
METHOD ReadXmlSchema(reader) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="fileName" type="String"></param>
///<returns></returns>
METHOD ReadXmlSchema(fileName) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="stream" type="Stream"></param>
///<returns></returns>
METHOD WriteXmlSchema(stream) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="writer" type="TextWriter"></param>
///<returns></returns>
METHOD WriteXmlSchema(writer) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="writer" type="XmlWriter"></param>
///<returns></returns>
METHOD WriteXmlSchema(writer) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="fileName" type="String"></param>
///<returns></returns>
METHOD WriteXmlSchema(fileName) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="XmlReader"></param>
///<returns></returns>
METHOD ReadXml(reader) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="stream" type="Stream"></param>
///<returns></returns>
METHOD ReadXml(stream) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="TextReader"></param>
///<returns></returns>
METHOD ReadXml(reader) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="fileName" type="String"></param>
///<returns></returns>
METHOD ReadXml(fileName) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="XmlReader"></param>
///<param name="mode" type="XmlReadMode"></param>
///<returns></returns>
METHOD ReadXml(reader, mode) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="stream" type="Stream"></param>
///<param name="mode" type="XmlReadMode"></param>
///<returns></returns>
METHOD ReadXml(stream, mode) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="TextReader"></param>
///<param name="mode" type="XmlReadMode"></param>
///<returns></returns>
METHOD ReadXml(reader, mode) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="fileName" type="String"></param>
///<param name="mode" type="XmlReadMode"></param>
///<returns></returns>
METHOD ReadXml(fileName, mode) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="stream" type="Stream"></param>
///<returns></returns>
METHOD WriteXml(stream) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="writer" type="TextWriter"></param>
///<returns></returns>
METHOD WriteXml(writer) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="writer" type="XmlWriter"></param>
///<returns></returns>
METHOD WriteXml(writer) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="fileName" type="String"></param>
///<returns></returns>
METHOD WriteXml(fileName) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="stream" type="Stream"></param>
///<param name="mode" type="XmlWriteMode"></param>
///<returns></returns>
METHOD WriteXml(stream, mode) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="writer" type="TextWriter"></param>
///<param name="mode" type="XmlWriteMode"></param>
///<returns></returns>
METHOD WriteXml(writer, mode) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="writer" type="XmlWriter"></param>
///<param name="mode" type="XmlWriteMode"></param>
///<returns></returns>
METHOD WriteXml(writer, mode) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="fileName" type="String"></param>
///<param name="mode" type="XmlWriteMode"></param>
///<returns></returns>
METHOD WriteXml(fileName, mode) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="dataSet" type="DataSet"></param>
///<returns></returns>
METHOD Merge(dataSet) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="dataSet" type="DataSet"></param>
///<param name="preserveChanges" type="Boolean"></param>
///<returns></returns>
METHOD Merge(dataSet, preserveChanges) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="dataSet" type="DataSet"></param>
///<param name="preserveChanges" type="Boolean"></param>
///<param name="missingSchemaAction" type="MissingSchemaAction"></param>
///<returns></returns>
METHOD Merge(dataSet, preserveChanges, missingSchemaAction) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="table" type="DataTable"></param>
///<returns></returns>
METHOD Merge(table) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="table" type="DataTable"></param>
///<param name="preserveChanges" type="Boolean"></param>
///<param name="missingSchemaAction" type="MissingSchemaAction"></param>
///<returns></returns>
METHOD Merge(table, preserveChanges, missingSchemaAction) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="rows" type="DataRow[]"></param>
///<returns></returns>
METHOD Merge(rows) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="rows" type="DataRow[]"></param>
///<param name="preserveChanges" type="Boolean"></param>
///<param name="missingSchemaAction" type="MissingSchemaAction"></param>
///<returns></returns>
METHOD Merge(rows, preserveChanges, missingSchemaAction) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD RejectChanges() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Reset() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="schemaSet" type="XmlSchemaSet"></param>
///<returns></returns>
METHOD GetDataSetSchema(schemaSet) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="IDataReader"></param>
///<param name="loadOption" type="LoadOption"></param>
///<param name="errorHandler" type="FillErrorEventHandler"></param>
///<param name="tables" type="DataTable[]"></param>
///<returns></returns>
METHOD Load(reader, loadOption, errorHandler, tables) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="IDataReader"></param>
///<param name="loadOption" type="LoadOption"></param>
///<param name="tables" type="DataTable[]"></param>
///<returns></returns>
METHOD Load(reader, loadOption, tables) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="reader" type="IDataReader"></param>
///<param name="loadOption" type="LoadOption"></param>
///<param name="tables" type="String[]"></param>
///<returns></returns>
METHOD Load(reader, loadOption, tables) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD CreateDataReader() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="dataTables" type="DataTable[]"></param>
///<returns></returns>
METHOD CreateDataReader(dataTables) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="EventHandler"></param>
///<returns></returns>
METHOD add_Disposed(value) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="value" type="EventHandler"></param>
///<returns></returns>
METHOD remove_Disposed(value) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD Dispose() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="service" type="Type"></param>
///<returns></returns>
METHOD GetService(service) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD ToString() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD GetType() CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<param name="obj" type="Object"></param>
///<returns></returns>
METHOD Equals(obj) CLASS DataSet
	
RETURN


///<summary>
///	
///</summary>
///<returns></returns>
METHOD GetHashCode() CLASS DataSet
	
RETURN



*/