#Include "Protheus.ch"  
#Include "iRep_main.ch"  
#Include "ApWebSrv.ch"  
#Include "IReport_MainStru.ch"

WSService iReport description STR0001 NAMESPACE "http://webservices.microsiga.com.br/" 
  	WSData sessionID 			as String
  	WSData initStatus			as String
	WSData tableAlias			as String
	WSData listTables			as String
	WSData empresa				as String
	WSData filial				as String
	WSData report				as String
	WSData reportName			as String  
	WSData cVersion	   			as String
	
  	WSData internationalization	as InterStru   
	WSData systemTables			as array Of SysTablesStru
	WSData systemFields			as array Of SysFieldsStru
	WSData listRelations		as array Of lstRelations
	WSData listParameters		as array Of lstParameters
	
	WSMethod makeInternationalization	Description STR0002 //"Retorna os textos internacionalizados."      
	WSMethod getSystemTables 			Description STR0003 //"Retorna as tabelas do sistema."      	
	WSMethod getSystemFields 			Description STR0004 //"Retorna os campos do sistema."      	
	WSMethod getTablesRelation 			Description STR0005 //"Retorna os relacionamento entre as tabelas do sistema."
	WSMethod getReport		 			Description STR0006 //"Retorna o jrxml de um relatorio."	
	WSMethod getTableSX2Name 			Description STR0007 //"Retorna o nome das tabelas, considerando empresa e filial."
	WSMethod getParameters	 			Description STR0008 //"Retorna os parametros para a geracao do relatorio."	 
	WSMethod getVersion		 			Description STR0009 //"Retorna a versão do servidor do iReport"
EndWSService
 

WSMethod makeInternationalization WSReceive sessionID WSSend internationalization WSService iReport
	::internationalization:Language	:=	cIR_Location()
	::internationalization:Text 	:=	cIR_International()
	::internationalization:FileName	:=	cIR_IntName()
Return .t.                         
   

WSMethod getSystemTables WSReceive sessionID,empresa, filial WSSend systemTables WSService iReport  
	::systemTables := {}
	lIR_GetTables(::systemTables,::empresa,::filial)
return .t.
  

WSMethod getSystemFields WSReceive sessionID,tableAlias,empresa, filial WSSend systemFields WSService iReport  
	::systemFields := {}
	lIR_GetFields(::systemFields,alltrim(::tableAlias),::empresa,::filial)
return .t.
   

WSMethod getTablesRelation WSReceive sessionID, listTables,empresa, filial WSSend listRelations WSService iReport  
	::listRelations := {}
	lIR_TableRel(::listRelations,upper(alltrim(::listTables)),::empresa,::filial)
return .t.
     

WSMethod getReport WSReceive sessionID, reportName WSSend report WSService iReport  
	local lRet := .t.
	::report := ""
	lRet := lGetIReport(@::report,reportName)
return lRet


WSMethod getTableSX2Name WSReceive sessionID , empresa, filial, listTables WSSend systemTables WSService iReport  
	::systemTables := {}
	lIR_SX2TabName(::systemTables,::empresa,::filial,::listTables)
return .T.


WSMethod getParameters WSReceive sessionID , empresa, filial, reportName WSSend listParameters WSService iReport  
	::listParameters := {}
	lIR_GetPerguntas(::listParameters,::empresa,::filial,::reportName)
return .T.	
      

WSMethod getVersion WSReceive sessionID WSSend cVersion WSService iReport  
	::cVersion := lIR_GetVersion()
return .T.