#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//#INCLUDE 'GTPA812.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA812()
Cadastro de Eventos CTE
@sample	GTPA812() 
@return	oBrowse	Retorna o Cadastro de Eventos CTE
@author	GTP
@since		22/10/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA812()

Local oBrowse := FWMBrowse():New()	
oBrowse:SetAlias('GI7')
oBrowse:SetDescription('Cadastro de de Eventos CTE')	//Cadastro de de Eventos CTE

oBrowse:SetMenuDef('GTPA812')

oBrowse:AddLegend("GI7_STATUS=='1'", "YELLOW"   , "Aguardando"      ,"GI7_STATUS")
oBrowse:AddLegend("GI7_STATUS=='2'", "BLUE"     , "Assinada"        ,"GI7_STATUS")
oBrowse:AddLegend("GI7_STATUS=='3'", "ORANGE"   , "Rejeitado"       ,"GI7_STATUS")
oBrowse:AddLegend("GI7_STATUS=='6'", "GREEN"    , "Autorizado"      ,"GI7_STATUS")

oBrowse:Activate()

Return ( oBrowse )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu 
@sample	MenuDef() 
@return	aRotina - Retorna as opções do Menu 
@author		GTP
@since		22/10/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.GTPA812' OPERATION 2 ACCESS 0 // Visualizar


Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados 
@sample	ModelDef() 
@return	oModel  Retorna o Modelo de Dados 
@author	GTP
@since		22/10/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	:= MPFormModel():New('GTPA812', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
Local oStruGI7	:= FWFormStruct(1,'GI7')

oModel:AddFields('GI7MASTER',/*cOwner*/,oStruGI7)
oModel:SetDescription('Cadastro de de Eventos CTE')				//Cadastro de de Eventos CTE
oModel:GetModel('GI7MASTER'):SetDescription('Dados do Evento')	//Dados do Evento


Return ( oModel )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface 
@sample	ViewDef() 
@return	oView  Retorna a View 
@author	GTP
@since		22/10/2019
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA812') 
Local oView		:= FWFormView():New()
Local oStruGI7	:= FWFormStruct(2, 'GI7')

oView:SetModel(oModel)
oView:AddField('VIEW_GI7' ,oStruGI7,'GI7MASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_GI7','TELA')

oView:SetDescription('Dados do Evento')

Return ( oView )


/*/{Protheus.doc} GTPA812ATU
//TODO Descrição auto-gerada.
@author osmar.junior
@since 22/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodigo, characters, descricao
@param cTpEvento, characters, descricao
@param cSeq, characters, descricao
@param cStatus, characters, descricao
@param cXmlEnv, characters, descricao
@param cXmlRet, characters, descricao
@param cProtoc, characters, descricao
@param cChave, characters, descricao
@param cCodref, characters, descricao
@param cMotRej, characters, descricao
@param cDataEnv, characters, descricao
@param cDataAut, characters, descricao
@type function
/*/
Function GTPA812ATU(cCodigo,cTpEvento,cSeq,cStatus,cXmlEnv,cXmlRet,cProtoc,cChave,cCodref,cMotRej,dDataEnv,dDataAut,cTipo)
Local lRet		:= .T.
Local oModel	:= FwLoadModel('GTPA812') 

Default cSeq 	:= '01'
Default cStatus := '2' //aguardando
Default cXmlEnv := ''
Default cXmlRet := ''
Default cProtoc := ''
Default cChave 	:= ''
Default cCodref := ''
Default cMotRej	:= ''
Default dDataEnv:= dDatabase
Default dDataAut := dDatabase

	GI7->(dbSetOrder(1))  //GI7_FILIAL+GI7_CODIGO+GI7_TIPCTE+GI7_SEQUEN
	If GI7->( MsSeek( xFilial('GI7') + cCodigo + cTpEvento + cSeq ) ) 
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
	Else
		oModel:SetOperation(MODEL_OPERATION_INSERT)
	EndIf
	
	oModel:Activate()
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_CODIGO'	, cCodigo )
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_TIPCTE'	, cTpEvento )
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_SEQUEN'	, cSeq )
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_STATUS'	, cStatus )
	If cTipo=='1'
		oModel:GetModel('GI7MASTER'):LoadValue('GI7_XMLENV'	, cXmlEnv )
	EndIf
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_XMLRET'	, cXmlRet )	
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_PROTOC'	, cProtoc )
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_CHVCTE'	, cChave )
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_CODREF'	, cCodref )
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_MOTREJ'	, cMotRej )
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_DTENV'	, dDataEnv )
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_DTAUT'	, dDataAut )
	oModel:GetModel('GI7MASTER'):LoadValue('GI7_USUINC'	, AllTrim( RetCodUsr() ) )
	
	If oModel:VldData()   	
		oModel:CommitData()
		oModel:DeActivate() 
		If cTpEvento == '2' //cancelamento
			AtuCancel(cCodigo)
		EndIf
	Else
		JurShowErro( oModel:GetModel():GetErrormessage() )	
		lRet := .F.
	EndIf 

Return lRet

/*/{Protheus.doc} GTPA812RET
//TODO Descrição auto-gerada.
@author osmar.junior
@since 25/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodigo, characters, descricao
@param cEvento, characters, descricao
@param cChave, characters, descricao
@param oWS, object, descricao
@param cJsonRet, characters, descricao
@param cTipo, characters, descricao
@type function
/*/
Function GTPA812RET(cCodigo, cEvento, cChave, oWS, cJsonRet,cTipo, cXmlEnv)

Local cDHREGEVEN := ''	
Local cID_EVENTO := ''	
Local cMENSAGEM	 := ''
Local cCSTATENV	 := ''
Local cCSTATEVEN := ''
Local cPROTOCOLO := ''
Local cSTATUS	 := ''
Local cTIPOEVENTO:= ''
Local cChaveCte  := ''
Local cMotivo	 := ''
Local cMotivoEnv	 := ''

Default cChave := ''
Default cXmlEnv := ''


If cTipo == '2' //consulta
	If cEvento == '1' //Carta de correção
		cMotivo	 := ALLTRIM(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:CCMOTENV) //"Evento registrado e vinculado a CT-e                                                                                                                                                                                                                      "	
		cMotivoEnv	 := ALLTRIM(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:CCMOTEVEN) //"Evento registrado e vinculado a CT-e                                                                                                                                                                                                                          "	
		cDHREGEVEN := ALLTRIM(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:CDHREGEVEN)//	"2019-10-25T13:41:53-03:00     "	
		cID_EVENTO := ALLTRIM(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:CID_EVENTO)	//"ID1101104319105311379100012257375000000032110018979702"	
		CMENSAGEM	 := ALLTRIM(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:CMENSAGEM) //" Evento Autorizado"	
		cCSTATENV	 := ALLTRIM(STR(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:NCSTATENV)) //135	
		cCSTATEVEN := ALLTRIM(STR(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:NCSTATEVEN))	//135	
		cPROTOCOLO := ALLTRIM(STR(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:NPROTOCOLO))//	143190000396825	
		cSTATUS	 := ALLTRIM(STR(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:NSTATUS))//6	
		cTIPOEVENTO:= ALLTRIM(STR(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:NTIPOEVENTO))//	110110	
	ElseIf cEvento == '2' //cancelamento
		cMotivo	 := ALLTRIM(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:CMSGRETNFE) //"Cancelamento de CT-e homologado"	                                                                                                                                                                                                                    "	
		cMotivoEnv	 := ALLTRIM(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:CMSGRETRECIBO) //"Cancelamento de CT-e homologado"	                                                                                                                                                                                                                        "	
		cCSTATENV	 := ALLTRIM(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:CCODRETNFE) //101		
		cPROTOCOLO   := ALLTRIM(STR(oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[1]:NRECIBOSEFAZ))//	143190000396825	
		If oWs:oWSMonitorFaixaResult:oWSMonitorNFE[1]:oWSErro:oWSLoteNFe[nLote]:CCODRETNFE == '101'
			cSTATUS	 := '6' //Autorizado	
		Else
			cSTATUS	 := '2' //Assinada
		EndIf
		cTIPOEVENTO:= 	'110111'	//Cancelamento
		
	EndIf
EndIf

If cTIPOEVENTO =='110110' 		//Carta
	cEvento := '1'
ElseIf cTIPOEVENTO =='110111'	//Cancela
	cEvento := '2'
EndIf
GTPA812ATU(cCodigo,cEvento,NIL,cSTATUS,cXmlEnv,cJsonRet,cPROTOCOLO,cChave,cCSTATENV,cMotivo,dDatabase,dDatabase, cTipo)   
	
Return




/*/{Protheus.doc} GTP812AtuEv
//TODO Descrição auto-gerada.
@author osmar.junior
@since 25/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTP812AtuEv()  

Local cTmpAlias := GetNextAlias() 
Local cEvento := ''

	BeginSql Alias cTmpAlias
	    SELECT GI7_FILIAL, GI7_CODIGO,GI7_TIPCTE,GI7_SEQUEN,GI7_STATUS,G99_SERIE,G99_NUMDOC,G99_CHVCTE
	    FROM %Table:GI7% GI7 INNER JOIN %Table:G99% G99 ON GI7_FILIAL=G99_FILIAL AND GI7_CODIGO=G99_CODIGO
	    WHERE GI7_STATUS IN ('1','2')
	    	AND GI7.D_E_L_E_T_=' '
	    	AND G99.D_E_L_E_T_=' '
	    	
	EndSql

	If (cTmpAlias)->(!Eof())
		While (cTmpAlias)->(!Eof())
		
			If (cTmpAlias)->GI7_TIPCTE == '1'
				cEvento :='110110'
			Else
				cEvento :='110111'
			EndIf
			AtuEventos((cTmpAlias)->GI7_CODIGO, cEvento,G99_CHVCTE,G99_CHVCTE)  
			(cTmpAlias)->(dbSkip())
		End		
	Endif
	
	(cTmpAlias)->(DbCloseArea())	
    
return



/*/{Protheus.doc} AtuEventos
//TODO Descrição auto-gerada.
@author osmar.junior
@since 25/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodigo, characters, descricao
@param cEvento, characters, descricao
@param cDocIni, characters, descricao
@param cDocFim, characters, descricao
@type function
/*/
Static Function AtuEventos(cCodigo,cEvento,cDocIni,cDocFim)  
local oWS        := Nil
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
local cStatEven  := ''
local cMotEven   := ''
local cProtocolo := ''    
local cJsonRet   := ''
local cError     := ''
Local cTipo      := '1'

	 If (!isConnTSS(@cError) )
	    cError := "Falha de comunicação com TSS. Realize a configuração."
	    If !IsBlind()
	    	aviso("CTe", cError, {'ok'}, 3)
	    EndIf
	    spedNFeCfg()
	    cError := Iif( Empty( getWscError(3)), getWscError(1), getWscError(3))
	endif
	
	
	If empty(cError)
	    cIdEnt := getCfgEntidade(@cError)
	    lOk := empty(cError)
	endif

	If lOk
		oWS  := wsNFeSBra():new()
		oWS:_URL        := AllTrim(cURL) + "/NFeSBRA.apw"
		oWS:cUserToken  := "TOTVS"
		oWS:cID_ENT     := cIdEnt
		oWS:cEvento     := cEvento
		oWS:cChvInicial := cDocIni
		oWS:cChvFinal   := cDocFim
	
		If(oWS:nfeMonitorLoteEvento())
		    nLote := len(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO)
		    If ( nLote > 0 )
		        cStatEven := str(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nCStatEven, 3)
		        cMotEven  := alltrim(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:cCMotEven)
		        
		        If( oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nCStatEven == 0 )            
		        
		            cJsonRet :='{"status": 1, "details": "Aguardando Processamento.", '
		            cJsonRet += '"autorizacao":{"protocolo": ""}, '
		            cJsonRet += '"rejeicao": {"codigo": "", "motivo": ""} }' 
		            
		            GTPA812RET(cCodigo, cTipo, cDocIni, oWS, cJsonRet,'2')
		        
		        Elseif(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nProtocolo > 0 )
		
		            cProtocolo:= alltrim(str(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nProtocolo))
		            cJsonRet := '{"status": 2, "details": "Evento Autorizado.", '
		            cJsonRet += '"autorizacao":{"protocolo": "' + cProtocolo + '"}, '
		            cJsonRet += '"rejeicao": {"codigo": "", "motivo": ""} }'
		       
		           GTPA812RET(cCodigo, cTipo, cDocIni, oWS, cJsonRet,'2')
		        Else
		            cJsonRet := '{"status": 3, "details": "Evento Rejeitado.", '
		            cJsonRet += '"autorizacao":{"protocolo": "" }, "rejeicao": '
		            cJsonRet += '{ "codigo": "' + cStatEven +'", "motivo":"' + cMotEven + '"}}' 
		            
		            GTPA812RET(cCodigo, cTipo, cDocIni, oWS, cJsonRet,'2')
		        EndIf
		    Else
		        cError := "Documento não possui evento."
		    EndIf        
		Else
		    cError := Iif( Empty( getWscError(3)), getWscError(1), getWscError(3))
		EndIf
	EndIf

Return




/*/{Protheus.doc} GTPA802E
//TODO Descrição auto-gerada.
@author osmar.junior
@since 25/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPA802E()
	
Local oBrowse 	:= FWMBrowse():New()
oBrowse:SetAlias('GI7')
oBrowse:CleanFilter()
oBrowse:SetFilterDefault ( "GI7_CODIGO == " + "'" + G99->G99_CODIGO + "' .AND. GI7_STATUS <> ''" )
oBrowse:SetDescription('Eventos vinculados')
oBrowse:SetMenuDef('GTPA812')
oBrowse:AddLegend("GI7_STATUS=='1'", "YELLOW"   , "Aguardando"      ,"GI7_STATUS")
oBrowse:AddLegend("GI7_STATUS=='2'", "BLUE"     , "Assinada"        ,"GI7_STATUS")
oBrowse:AddLegend("GI7_STATUS=='3'", "ORANGE"   , "Rejeitado"       ,"GI7_STATUS")

//Tipo CTE
// Adiciona as colunas do Browse
oColumn := FWBrwColumn():New()
oColumn:SetData( {|| IIF(GI7_TIPCTE == '1', "Carta de correção", "Cancelamento") } )
oColumn:SetTitle("Tipo CTE")
oColumn:SetSize(1)
oBrowse:SetColumns({oColumn})


oBrowse:AddLegend("GI7_STATUS=='6'", "GREEN"    , "Autorizado"      ,"GI7_STATUS")
oBrowse:Activate()

Return


/*/{Protheus.doc} AtuCancel
//TODO Descrição auto-gerada.
@author osmar.junior
@since 28/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodigo, characters, descricao
@type function
/*/
Static Function AtuCancel(cCodigo)
		G99->(dbSetOrder(1))  //G99_FILIAL+G99_CODIGO
		If G99->(MsSeek(xFilial('G99')+ cCodigo))			
			RecLock('G99',.F.)	
				G99->G99_STATRA := '8'     //"CTe Cancelado"    
            G99->(MsUnLock()) 
		EndIf		

Return 


