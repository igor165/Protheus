#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/-----------------------------------------------------------
TMSIntRot(cTabela,cRecno)
Integração com a Rota Inteligente e TPR Neolog

Uso: TMSA440, TMSA450, MATN030, CRM980EVENTDEFTMS

@sample
//cTabela    -- cTabela
//cRecno     -- cRecno

@author Katia 
@since 11/06/19
@version 1.0
-----------------------------------------------------------/*/
Function TMSIntRot(cTabela, nRecno)

Local oDadosGeo := Nil 
Local aGeoCode  := {}

Local cFilEnt   := ""
Local cEntida   := ""
Local cCodEnt   := ""
Local cEnd      := ""
Local cEst      := ""
Local cMun      := ""
Local cBairro   := ""
Local cCep      := ""
Local cLatitude := ""
Local cLongitude:= ""
Local aDadosCli	:= {}
Local lRotaInt	:= SuperGetMV("MV_ROTAINT",,.F.)
Local lSoliAut  := SuperGetMV("MV_SOLIAUT",,"0")
Local lIntTMS	:= SuperGetMV("MV_INTTMS",,.F.) 
Local cRoteiri  := ""
Local cIdent    :=  ""
Local cSigla    :=  ""
Local lRet      := .T.

Default cTabela  := ""
Default nRecno   := 0

If lRotaInt .And. (nModulo == 43 .Or. nModulo == 39) .Or. ( lIntTMS .And. lSoliAut != "0" )  
	cRoteiri:= TMSROTEIRI()   //Verifica o Roteirizador

	&(cTabela)->( dbGoto(nRecno) )
	If cTabela == "SA1"
		cFilEnt:= xFilial("SA1")
		cEntida:= "SA1"
		cCodEnt:= SA1->A1_COD+SA1->A1_LOJA
		cEnd   := SA1->A1_END
		cEst   := SA1->A1_EST
		cMun   := SA1->A1_MUN
		cBairro:= SA1->A1_BAIRRO
		cCep   := SA1->A1_CEP
		If cRoteiri == '2'  //TPR Neolog
			cSigla := Posicione('SYA',1,xFilial('SYA')+SA1->A1_PAIS,'YA_SIGLA')
		EndIf

	ElseIf cTabela == "DUE"
		cFilEnt:= xFilial("DUE")
		cEntida:= "DUE"
		cCodEnt:= DUE->DUE_CODSOL
		cEnd   := DUE->DUE_END
		cEst   := DUE->DUE_EST
		cMun   := DUE->DUE_MUN
		cBairro:= DUE->DUE_BAIRRO
		cCep   := DUE->DUE_CEP
	ElseIf cTabela == "DUL"
		cFilEnt:= xFilial("DUL")
		cEntida:= "DUL"
		cCodEnt:= DUL->DUL_SEQEND
		cEnd   := DUL->DUL_END
		cEst   := DUL->DUL_EST
		cMun   := DUL->DUL_MUN
		cBairro:= DUL->DUL_BAIRRO
		cCep   := DUL->DUL_CEP
	EndIf

	If lRotaInt
		
		If cRoteiri == '2'  //TPR Neolog
			cIdent     := cFilEnt+cEntida+cCodEnt     //Chave da DAR
			oDadosGeo  := TMSBCATPRNeolog():New()			
			
			lRet:= oDadosGeo:Auth()
			If lRet
				oDadosGeo:AddAddress( cIdent, Iif(Empty(cSigla) .Or. AllTrim(cSigla)== "*","BRA",cSigla) , cEst, cMun, cCep, cEnd )
				lRet:= oDadosGeo:PostGeoLoc()				
				If lRet
					aGeoCode:= oDadosGeo:GetGeoLoc()
				EndIf
			EndIf
			If !lRet
				oDadosGeo:ShowError()
			EndIf
		EndIf

		If Len(aGeoCode) > 0
			cLatitude  := aGeoCode[1]
			cLongitude := aGeoCode[2]
		
			FWMsgRun(,{|| TMSROT015(cFilEnt,cEntida,cCodEnt,cLatitude,cLongitude) },,'Atualizando Referencia Geografica...' )
		EndIf

	EndIf 


	If lSoliAut != "0" .And. ExistFunc("TMSA441") .And. cTabela == "SA1"
		//--
		Aadd( aDadosCli, { "A1_COD" 	, SA1->A1_COD   	, Nil } )
		Aadd( aDadosCli, { "A1_LOJA" 	, SA1->A1_LOJA		, Nil } )
		Aadd( aDadosCli, { "A1_END" 	, AllTrim(cEnd)		, Nil } )
		Aadd( aDadosCli, { "A1_BAIRRO" 	, cBairro     		, Nil } )
		Aadd( aDadosCli, { "A1_MUN" 	, cMun        		, Nil } )
		Aadd( aDadosCli, { "A1_CEP"		, cCep        		, Nil } )
		Aadd( aDadosCli, { "A1_EST" 	, cEst        		, Nil } )
		Aadd( aDadosCli, { "A1_COD_MUN"	, SA1->A1_COD_MUN	, Nil } )
		Aadd( aDadosCli, { "A1_CDRDES"	, SA1->A1_CDRDES	, Nil } )
		Aadd( aDadosCli, { "A1_NOME"	, SA1->A1_NOME		, Nil } )
		Aadd( aDadosCli, { "A1_NREDUZ"	, SA1->A1_NREDUZ	, Nil } )
		Aadd( aDadosCli, { "A1_CGC"		, SA1->A1_CGC		, Nil } )
		Aadd( aDadosCli, { "A1_INSCR"	, SA1->A1_INSCR		, Nil } )
		Aadd( aDadosCli, { "A1_CONTATO"	, SA1->A1_CONTATO	, Nil } )
		Aadd( aDadosCli, { "A1_EMAIL"	, SA1->A1_EMAIL		, Nil } )
		Aadd( aDadosCli, { "A1_DDD"		, SA1->A1_DDD		, Nil } )
		Aadd( aDadosCli, { "A1_TEL"		, SA1->A1_TEL		, Nil } )

		TMSA441(aDadosCli)
	EndIf 
EndIf 

Return	


/*/-----------------------------------------------------------
TMSROT015(cFilEnt,cEntidade,cCodEnt,cLatitude,cLongitude)
Função gravar o Cadastro de referencia Geografica com dados
do GeoCoding 

Uso: TMSBCAHere: TMSA440

@sample
//cFilEnt    -- Filial do Alias Tabela
//cEntidade  -- Alias da Tabela
//cCodEnt    -- Codigo chave
//cLatitude
//cLongitude

@author Katia 
@since 09/06/19
@version 1.0
-----------------------------------------------------------/*/
Function TMSROT015(cFilEnt,cEntidade,cCodEnt,cLatitude,cLongitude)

Local nOpcAuto   := 4
Local aArea      := GetArea()
Local aCabAux    := {}
Local lExecAuto  := .F.
Local lRet       := .T.
Local aMaster	:= {} 

Default cFilEnt    := ""
Default cEntidade  := ""
Default cCodEnt    := ""
Default cLatitude  := ""
Default cLongitude := ""

Private lMsErroAuto := .F.

dbSelectArea("DAR")
DAR->(dbSetOrder(1))
If !DAR->(MsSeek(xFilial("DAR")+cFilEnt+cEntidade+cCodEnt) ) 
	nOpcAuto:= 3
	lExecAuto := .T.
	Aadd( aCabAux, { "DAR_FILIAL" , xFilial("DAR")  , Nil } )
	Aadd( aCabAux, { "DAR_FILENT" , cFilEnt         , Nil } )
	Aadd( aCabAux, { "DAR_ENTIDA" , cEntidade       , Nil } )
	Aadd( aCabAux, { "DAR_CODENT" , cCodEnt         , Nil } )
Else
	If RTrim(DAR->DAR_LATITU) <> cValToChar(cLatitude) .Or.  RTrim(DAR->DAR_LONGIT) <> cValToChar(cLongitude)
	   	lExecAuto := .T.
	EndIf 
EndIf

If 	lExecAuto 
	Aadd( aCabAux, { "DAR_LATITU" , cValtoChar(cLatitude), Nil } )
	Aadd( aCabAux, { "DAR_LONGIT" , cValtoChar(cLongitude), Nil } )

	Aadd( aMaster ,{} )
	Aadd( aMaster[Len(aMaster)] , aClone(aCabAux) )
	Aadd( aMaster[Len(aMaster)] , "MdFieldDAR" )
	Aadd( aMaster[Len(aMaster)] , "DAR" )

	lRet	:= TMSExecAuto( "TMSAO15" ,  aMaster  ,,  nOpcAuto  , .T. ,  )

EndIf

RestArea(aArea)
Return lRet

/*/-----------------------------------------------------------
TMSExcDAR(cCodCli, cLojaCli)
Função para apagar a DAR no caso de exclusão do cadastro de cliente

Uso: MATN030

@sample
@author Rafael 
@since 02/07/19
@version 1.0
-----------------------------------------------------------/*/
Function TMSExcDAR(cCodCli, cLojaCli)

Local lRet 		:= .F.
Local aArea     := GetArea()
Local lRotaInt	:= SuperGetMV("MV_ROTAINT",,.F.) 

Default cCodCli 	:= ""
Default	cLojaCli	:= ""

If lRotaInt .And. (nModulo == 43 .Or. nModulo == 39)

	dbSelectArea("DAR")
	DAR->(dbSetOrder(1))
	If DAR->(MsSeek(xFilial("DAR")+xFilial("SA1")+"SA1"+(cCodCli+cLojaCli) ))
		oMdlDAR := FWLoadModel( 'TMSAO15' )
		oMdlDAR :SetOperation( MODEL_OPERATION_DELETE )
		oMdlDAR :Activate()
		lRet := oMdlDAR:VldData()

		If lRet
			lRet := oMdlDAR:CommitData()
		EndIf
		
		oMdlDAR:DeActivate()
	EndIf
EndIf 	

RestArea(aArea)
Return lRet 


/*/-----------------------------------------------------------
TMSROTEIRI()
Função para verificar o Roteirizador utilizado para integração
Maplink ou TPR Neolog
@sample
@author Katia 
@since 19/08/21
@version 12.1.37
-----------------------------------------------------------/*/
Function TMSROTEIRI()
Local cRoteiri := ""   //1-Maplink, 2-TPR Neolog
Local lRoteiri := DLV->(ColumnPos('DLV_ROTERI')) > 0
Local cQuery   := ""
Local cAliasQry:= ""

If lRoteiri
	cAliasQry:=  GetNextAlias()
	cQuery := " SELECT DLV_ROTERI FROM "
	cQuery += RetSqlName("DLV") + "  DLV "
	cQuery += "   WHERE DLV_FILIAL = '" + xFilial("DLV") + "' "
	cQuery += "     AND DLV_MSBLQL = '2'
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasQry, .T., .T.)
	If (cAliasQry)->( !Eof() )
		cRoteiri:= (cAliasQry)->DLV_ROTERI
	EndIf
	(cAliasQry)->(dbCloseArea())
EndIf

If Empty(cRoteiri) 
	cRoteiri:= '1'  //-- Default Maplink 
EndIf

Return cRoteiri
