#INCLUDE 'PROTHEUS.CH'
#Include 'FWMVCDef.ch'
#INCLUDE 'GTPLOAD.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPLOAD()
Fun��o responsavel para carragmento de dados no momento da abertura do modulo

@sample	GTPLOAD()

@return	null

@author		jacomo.fernandes
@since		05/07/2017
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function GTPLOAD()
			
	//Cria parametros do m�dulo
    If GTPxVldDic('GYF')
	    FwMsgRun( ,{||LoadParamRules()},,STR0001)//"Verificando parametros do Modulo..."
    Endif
	
	//Cria tipos de recursos
    If GTPxVldDic('GYK')
	    FwMsgRun( ,{|| LoadTiposRecursos()},,STR0061)//"Verificando tipos de recursos..."
    Endif

	//Carrega tabela para uso na carta de corre�?o de CTE OS
    IF GTPxVldDic('G53')
	    FwMsgRun( ,{||GTPA712LOA()},,STR0064)	// "Carregando tabela de tags CT-e OS..." 
    Endif

	If FindFunction('GTPANPS')
		GTPANPS()	
	Endif

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadParamRules()
Fun��o responsavel para cria��o de parametros de m�dulo

@sample	LoadParamRules()

@return	null

@author		jacomo.fernandes
@since		05/07/2017
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function LoadParamRules()
//	GTPSetRules(cParameter	, cDataType	, cPicture	, cContent			,cGroupFunc		, cDescription		, cF3, cSeekFil, nOperation)
	GTPSetRules("FILRMD"	, "1"		,""			,FWCodFil()			, "GTPR428"		, STR0003+FwCodEmp(),"")	//"Filial Centralizadora (MATRIZ) Emp:"
	GTPSetRules("VRBCOMISSN", "1"		,""			,"" 				, "GTPA418"		, STR0004			,"")	//"C�digo da verba referente a comiss�o M�s"		
	GTPSetRules("VRBCOMIDSR", "1"		,""			,"" 				, "GTPA418"		, STR0005			,"")	//"C�digo da verba ref DSR sobre comiss�o"		
	GTPSetRules("BASECOMCTR", "1"		,"@!"		,"1" 				, "GTPA418"		, STR0006			,"")	//"1=NF Ag�ncia|2=NF Vend.|3=Bx.Tit.Vend."		
	GTPSetRules("LISTACARGO", "1"		,""			,""					, "GTPA008"		, STR0007			,"SQ3")	//"Cargos de funcion�rios separados por ;"		
	GTPSetRules("LISTAFUNCA", "1"		,""			,""					, "GTPA008"		, STR0008			,"SRJ")	//"Fun��es de funcion�rios separadas por ;"		
	GTPSetRules("GTPEXIBTOT", "3"		,""			,".T." 				, "GTPA302"		, STR0009			,"")	//"Exibe totalizadores-escala colaborador"		
	GTPSetRules("VRBAGCOMSN", "1"		,"@!"		,""					, "GTPA410"		, STR0012			,"SRV")	//"Verba ref.comiss�o respons�vel Ag�ncia."		
	GTPSetRules("VRBAGCMDSR", "1"		,"@!"		,""					, "GTPA410"		, STR0013			,"SRV")	//"Verba ref DSR s/comiss�o respons�vel Ag"		
	GTPSetRules("PREFTITFOR", "1"		,""			,""					, "GTPA410"		, STR0014			,"")	//"Prefixo Titulo pagar p/Ag.Terceirizada"		
	GTPSetRules("TIPOTITFOR", "1"		,""			,""					, "GTPA410"		, STR0015			,"05")	//"Tipo do Titulo pagar p/Ag.Terceirizada"		
	GTPSetRules("NATUTITFOR", "1"		,""			,""					, "GTPA410"		, STR0016			,"SED")	//"Natureza Tit. pagar p/Ag.Terceirizada"		
	GTPSetRules("CDPGTITFOR", "1"		,""			,""					, "GTPA410"		, STR0017			,"SE4")	//"Cond.Pgto.Tit. pagar p/Ag.Terceirizada"		
	GTPSetRules("HISTTITFOR", "1"		,""			,""					, "GTPA410"		, STR0019			,"")	//"Hist�rico Tit. pagar p/Ag.Terceirzada"		
	GTPSetRules("QTDHRDIA"	, "1"		,"@R 99:99"	,"0800"				, "GTPA302"		, STR0020			,"")	//"QTD. HR. MAX. ESCALA COLABORADOR"				
	GTPSetRules("BLQHRDIA"	, "3"		,""			,".F."				, "GTPA302"		, STR0021			,"")	//"LIMITE HRS BLOQUEIA ESCALA COLABORADOR"		
	GTPSetRules("MONITTIMER", "3"		,""			,".F."				, "GTPC300"		, STR0022			,"")	//"SALVAMENTO AUTOMATICA MONITOR"				
	GTPSetRules("MONITQTDTM", "2"		,"@E 99"	,"15"				, "GTPC300"		, STR0023			,"")	//"TEMPO (SEGUNDOS) SALV. AUT. MONITOR"			
	GTPSetRules("SERIRMD"	, "1"		,""			,FwCodEmp()			, "GTPA500"		, STR0024			,"")	//"Serie utilizada para RMD"						
	GTPSetRules("NATUPAG"	, "1"		,""			,""					, "GTPA700"		, STR0025			,"SED")	//"Natureza para titulo a pagar"					
	GTPSetRules("NATUREC"	, "1"		,""			,""					, "GTPA700"		, STR0026			,"SED")	//"Natureza para titulo a receber"				
	GTPSetRules("BANCOBX"	, "1"		,""			,""					, "GTPA700"		, STR0027			,"")	//"banco para baixar titulo."					
	GTPSetRules("PRODTAR"	, "1"		,""			,""					, "GTPJ001"		, STR0028			,"SB1")	//"Produto utilizado para tarifa"				
	GTPSetRules("PRODTAX"	, "1"		,""			,""					, "GTPJ001"		, STR0029			,"SB1")	//"Produto utilizado para taxa"					
	GTPSetRules("PRODPED"	, "1"		,""			,""					, "GTPJ001"		, STR0030			,"SB1")	//"Produto utilizado para ped�gio"				
	GTPSetRules("PROSGFACU"	, "1"		,""			,""					, "GTPJ001"		, STR0031			,"SB1")	//"Produto utilizado Seguro Facultativo"			
	GTPSetRules("PROUTTOT"	, "1"		,""			,""					, "GTPJ001"		, STR0032			,"SB1")	//"Produto utilizado para outros totais"			
	GTPSetRules("ESPECF"	, "1"		,""			,"BPECF"			, "GTPJ001"		, STR0035			,"")	//"Especie para bilhete ECF"						
	GTPSetRules("IDPOLTRONA", "1"		,""			,""					, "GTPA600"		, STR0036			,"")	//"ID DA CARACTERISTICA POLTRONA"				
	GTPSetRules("NATUREZA"	, "1"		,"@!"		,""					, "GTPA421"		, STR0037			,"SED")	//"C�digo Natureza p/ gera��o Titulo"			
	GTPSetRules("CTACTBL"	, "1"		,"@!"		,"" 				, "GTPA500"		, STR0042			,"CT1")	//"CONTA CONT�BIL PARA RMD"						
	GTPSetRules("GERNFDTINI", "1"		,"@D"		,"" 				, "GTPJ001"		, STR0043			,"")	//"Data Inicial para gera��o de notas"			
	GTPSetRules("GERNFDTFIM", "1"		,"@D"		,"" 				, "GTPJ001"		, STR0044			,"")	//"Data final para gera��o de notas"				
	GTPSetRules("GERNFAGENC", "1"		,"@!"		,"" 				, "GTPJ001"		, STR0045			,"GI6")	//"Lista de agencias para gera��o de notas "		
	GTPSetRules("GERNFSERDV", "1"		,""			,"" 				, "GTPJ001"		, STR0046			,"01")	//"Numero da S�rie da NFE de devolu��o"			
	GTPSetRules("TIPOESCEXT", "1"		,""			,"" 				, "GTPC300"		, STR0047			,"GZS")	//"Informa o tipo de Escala Extraordin�ria"		
	GTPSetRules("XMLCONFRJ"	, "1"		,""			,"rjintegra\conf"	, "GTPRJINTEG"	, STR0048			,"")	//"Informa o local do arquivo xml de config"		
	GTPSetRules("TPSRVMNT"	, "1"		,""			,"REV" 				, "GTPA409"		, STR0049			,"ST4")	//"Informa o tipo de servi�o da manuten��o"		
	GTPSetRules("TPCARDCRED", "1"		,""			,"CC" 				, "GTPA700L"	, STR0051			,"")	//"Informa  tipo titulo para Cart�o Credito"	
	GTPSetRules("TPCARDDEBI", "1"		,""			,"CD" 				, "GTPA700L"	, STR0052			,"")	//"Informa  tipo titulo para Cart�o Debito"		
	GTPSetRules("TPCARDPARC", "1"		,""			,"CP" 				, "GTPA700L"	, STR0053			,"")	//"Informa  tipo titulo para Cart�o Parcela"		
	GTPSetRules("DIVCOMNEG" , "1"		,""			,"  " 				, "GTPA113"	    , STR0063       	,"")	//"Infomar o Tipo de Verba"
    GTPSetRules("TXCONVENIE", "1"		,"@!"		,"  " 				, "GTPA421"		, STR0066       	,"")	//"Contrapartida de taxas (separados por ;)" 
	GTPSetRules("INTTIMEOUT", "2"		,""  		,"120"  			, "GTPA421"		, STR0067       	,"")	//"Informe o Tempo de TimeOut em Segundos"
    GTPSetRules("SERIECTE"  , "1"		,"@R 999"	,"  "  			    , "GTPA801"		, STR0068           ,"01")	//"Informa a serie do CTE" 
    GTPSetRules("SERDEVCTE" , "1"		,"@R 999"	,"  "  			    , "GTPA801"		, STR0069           ,"01")	//"Informa a serie de devolu��o do CTE" 	
	GTPSetRules("RETSTAEVEN", "2"		,""	        ,""  			    , "GTPA801C"    , STR0070           ,"")	//"Tempo para Retorno do Envio do CTE" 
	GTPSetRules("SERIEMDF"  , "1"		,"@R 999"	,"  "  			    , "GTPA810"		, STR0071           ,"01")  //"Informa a serie do MDF"
	GTPSetRules("ENVIAEMAIL", "3"		,""	        ,".F." 			    , "GTPA814"		, STR0072           ,"")    //"Informa se ser� enviado e-mail ou n�o"
	GTPSetRules("SERFATCNTR", "1"		,"@R 999"   ,"  " 			    , "GTPA819"		, STR0074,			"01")   //"S�rie util. fat. de contr. de encomendas"
	GTPSetRules("SERDEVCNTR", "1"		,"@R 999"   ,"  " 			    , "GTPA819"		, STR0075,			"01")   //"S�rie util. dev. de contr. de encomendas"
	GTPSetRules("ESPFATCNTR", "1"		,""			,"  "				, "GTPA819"		, STR0076,			"42")	//"Especie util. fat. de contr. encomendas"		
	GTPSetRules("PASTARQDOT", "1"		,""			,"  "				, "GTPR286"		, STR0077,			"")	    //"Pasta de Grava��o do arquivo.dot"
	GTPSetRules("NOMEARQDOT", "1"		,""			,"  "				, "GTPR286"		, STR0078,			"")	    //"Nome do arquivo.dot"		
	GTPSetRules("ARQDOTAUTR", "1"		,""			,"autorizacao.dot"	, "GTPR113A"	, STR0079,			"")
	GTPSetRules("DIRDOTAUTR", "1"		,""			,"C:\TEMP\"			, "GTPR113A"	, STR0080,			"")
	GTPSetRules("PREFTITTES", "1"		,""			,"FCH"				, "GTPA700"		, STR0081,			"") 	//"Prefixo de t�tulo da tesouraria."
	GTPSetRules("ISENTOIMP" , "1"		,""			," "				, "GTPA281"		, STR0082,			"") 	//tipos de linhas isen��o de impostos
	GTPSetRules("TPDOCEXBAG", "1"		,""			,"" 				, "GTPA117"		, STR0083,			"GYA")	//"Informa o c�digo de documento de excesso de bagagem"
	GTPSetRules("VERSAOBPE" , "1"		,""			,"1.00" 			, "GTPA117C"	, STR0084,			"")		//"Vers�o BP-e"
	GTPSetRules("VERLAYBPE" , "1"		,""			,"1.00"				, "GTPA117C"	, STR0085,			"")		//"Vers�o Layout BP-e"
	GTPSetRules("VERLAYEVEN", "1"		,""			,"1.00"				, "GTPA117C"	, STR0086,			"")		//"Vers�o Layout Envento Excesso de Bagagem"
	GTPSetRules("AMBENVBPE",  "2"		,""			,"" 				, "GTPA117C"	, STR0087,			"")		//"Ambiente Envio Evento Exc.Bagagem"
	GTPSetRules("PARCONFRJ"	, "1"		,""			,"StartPath"		, "GTPRJINTEG"	, STR0088,          "")     //Parametro de busca dos arquivos
	GTPSetRules("GRVPEDORC"	, "3"		,""			,".T."				, "GTPA600"		, STR0090,          "")	    //"Grava��o autom�tica de ped�gio do or�amento."
	GTPSetRules("NUMCOPIAS",  "2"		,""			,"" 				, "GTPX600R"	, STR0089,			"")		//"Numero de copias para impress�o"
	GTPSetRules("XXFREFER",   "1"		,""			,"TotalBus"			, "GTPXEAI" 	, STR0091,			"")     //"Referencia da XXF"
	GTPSetRules("VALREFER",   "3"		,""			,".T."	    		, "GTPXEAI" 	, STR0092,			"")     //"Valida se utiliza a fun��o de busca da XXF"
	GTPSetRules("GRUPOSUP",   "1"		,""			,""	 		   		, "AGEWEB" 		, STR0093,			"GRP")  //"Usu�rios Supervisores das Ag�ncias"  	
	GTPSetRules("PATHREST",   "1"		,""			,""		    		, "REST" 		, STR0096,			"")
	GTPSetRules("DIASBOLETO", "2"		,""			,"" 				, "GTPA421"		, STR0094,			"")		//"Numero de copias para impress�o"
	GTPSetRules("PREFDEPTER", "1"		,""			,"DEP"				, "GTPA700"		, STR0095,			"") 	//"Prefixo do t�tulo de dep. terceiros"
	GTPSetRules("ISGTPPNMTA", "3"		,""			,".T."				, "GTPPNMTAB"	, STR0097,			"")
	GTPSetRules("USEENCSEG",  "3"		,""			,".T."				, "GTPA803"		, STR0098,			"")     //"Usa averba��o automatica"
	GTPSetRules("ENCSEGURA",  "1"		,""			,""					, "GTPA803"		, STR0099,			"GTPDL6")//"C�digo seguradora averba��o"
	GTPSetRules("SERIECTEOS", "1"		,"@R 999"	,"  "  			    , "GTPA850"		, STR0100,			"H61SER")	//"Informa a serie do CTEOS" 
	GTPSetRules("AJHRFINESC", "3"		,""			,".F."				, "GTPA302"		, STR0101,			"")
	GTPSetRules("SERIEMANOP", "1"		,"@R 999"	,"000" 			    , "GTPA810"		, STR0102,			"")	//"Informa a serie do Manifesto Operaciona" 

Return

/*/{Protheus.doc} LoadTiposRecursos
	Fun��o responsavel para cria��o autom�tica dos tipos padr�es de recursos
	@type  Static Function
	@author jacomo.fernandes
	@since 29/05/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function LoadTiposRecursos()
Local oModel	:= FwLoadModel('GTPA010')
Local oMdlGYK	:= oModel:GetModel('GYKMASTER')
Local aArea		:= GetArea()
Local aTipos	:= {}
Local cCodigo	:= ""
Local nX		:= 0

aAdd(aTipos,{STR0055	,'1','1'})//'MOTORISTA'
aAdd(aTipos,{STR0056	,'2','1'})//'COBRADOR'
aAdd(aTipos,{STR0057	,'1','2'})//'MOTORISTA/TREINAMENTO'
aAdd(aTipos,{STR0058	,'2','2'})//'MOTORISTA/PASSAGEIRO'
aAdd(aTipos,{STR0059	,'2','2'})//'COBRADOR/PASSAGEIRO'
aAdd(aTipos,{STR0060	,'1','2'})//'MOTORISTA/PRATICANDO'

GYK->(DbSetOrder(1))//GYK_FILIAL+GYK_CODIGO
For nX := 1 to Len(aTipos)
	cCodigo	:= StrZero(nX,TamSx3('GYK_CODIGO')[1])
	If !GYK->(DbSeek(xFilial('GYK')+cCodigo ))
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If oModel:Activate()
			oMdlGYK:SetValue('GYK_CODIGO'	,cCodigo)
			oMdlGYK:SetValue('GYK_DESCRI'	,aTipos[nX][1])
			oMdlGYK:SetValue('GYK_VALCNH'	,aTipos[nX][2])
			oMdlGYK:SetValue('GYK_PROPRI'	,"S") //Define que esses cadastros foram feito pelo sistema
			oMdlGYK:SetValue('GYK_LIMTIP'	,aTipos[nX][3]) //Define se limita ou n�o o tipo de recurso
			
			If oModel:VldData() 
				oModel:CommitData()
			EndIf
		EndIf
		
		oModel:Deactivate()
	Endif
Next

oModel:Destroy()
RestArea(aArea)
GtpDestroy(aTipos)
Return 
