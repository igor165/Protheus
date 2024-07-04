#Include 'PROTHEUS.CH'
#Include 'FWMVCDef.ch'

#DEFINE CLI_CODCLI  1
#DEFINE CLI_LOJCLI	2 
#DEFINE CLI_END		3
#DEFINE CLI_BAIRRO	4
#DEFINE CLI_MUN		5
#DEFINE CLI_CEP		6
#DEFINE CLI_EST		7
#DEFINE CLI_CODMUN	8
#DEFINE CLI_CDRDES	9
#DEFINE CLI_NOME	10
#DEFINE CLI_NREDUZ	11
#DEFINE CLI_CGC		12
#DEFINE CLI_INSCR	13
#DEFINE CLI_CONTATO	14
#DEFINE CLI_EMAIL	15	
#DEFINE CLI_DDD		16
#DEFINE CLI_TEL		17
/*/-----------------------------------------------------------
TMSA441(aDadosCli)
Função para Incluir o Cadastro de Solicitante via Execução automática

Uso: MATN030 / CRM980EVENTDEFTMS

@sample
@author Rafael 
@since 23/08/19
@version 1.0
-----------------------------------------------------------/*/

Function TMSA441(aDadosCli)

Local aCabDUE   := {}
Local aItemDVJ  := {}
Local aColsDVJ	:= {}
Local aCabDUL	:= {}
Local aAreaS    := { SA1->(GetArea()), GetArea() }
Local lRet      := .F.
Local cCodPro   := Padr(SuperGetMV('MV_PROGEN',,''),Len(SB1->B1_COD))
Local lSoliAut  := SuperGetMV("MV_SOLIAUT",,"0")
Local nOpcAuto	:= 3
Local lCriaDUL	:= .F. 
Local cQuery	:= ""
Local cAliasQry	:= ""

Default cCodCli     := ""
Default cLojaCli    := ""
Default aDadosCli	:={}

	If Type('lMsErroAuto') == 'U'
		Private lMsErroAuto := .F.
	EndIf

	dbSelectArea("DUE")
	DUE->(dbSetOrder(3))
	If  (lSoliAut == "1" .Or. lSoliAut == "2") .And. !DUE->(MsSeek(xFilial("DUE")+aDadosCli[CLI_CODCLI][2]+aDadosCli[CLI_LOJCLI][2]) ) 

		Aadd( aCabDUE, { "DUE_FILIAL" , xFilial("DUE")  , Nil } )
		Aadd( aCabDUE, { "DUE_CGC   " , aDadosCli[CLI_CGC][2]    , Nil } )
		Aadd( aCabDUE, { "DUE_CODCLI" , aDadosCli[CLI_CODCLI][2] , Nil } )
		Aadd( aCabDUE, { "DUE_LOJCLI" , aDadosCli[CLI_LOJCLI][2] , Nil } )
		Aadd( aCabDUE, { "DUE_CODMUN" , aDadosCli[CLI_CODMUN][2] , Nil } )

		aItemDVJ := {}
		Aadd( aItemDVJ, { "DVJ_CODPRO", cCodPro                                          , Nil } )
		Aadd( aItemDVJ, { "DVJ_CODEMB", Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_UM"), Nil } )

		Aadd(aColsDVJ,aClone(aItemDVJ))	
		nOpcAuto := 3
		lRet 	 := .T. 

	ElseIf lSoliAut == "1" .And. DUE->(MsSeek(xFilial("DUE")+aDadosCli[CLI_CODCLI][2]+aDadosCli[CLI_LOJCLI][2]) )
		RecLock('DUE',.F.)
		DUE->DUE_NOME	:= PadR( aDadosCli[CLI_NOME][2]		,TamSX3("DUE_NOME")[1]	)
		DUE->DUE_NREDUZ := PadR( aDadosCli[CLI_NREDUZ][2]	,TamSX3("DUE_NREDUZ")[1])
		DUE->DUE_END	:= PadR( aDadosCli[CLI_END][2]		,TamSX3("DUE_END")[1]	)
		DUE->DUE_MUN 	:= PadR( aDadosCli[CLI_MUN][2]		,TamSX3("DUE_MUN")[1]	)
		DUE->DUE_BAIRRO	:= PadR( aDadosCli[CLI_BAIRRO][2]	,TamSX3("DUE_BAIRRO")[1])
		DUE->DUE_CEP 	:= aDadosCli[CLI_CEP][2]
		DUE->DUE_CGC 	:= aDadosCli[CLI_CGC][2]
		DUE->DUE_INSCR 	:= aDadosCli[CLI_INSCR][2]
		DUE->DUE_CONTAT := PadR( aDadosCli[CLI_CONTATO][2]	,TamSX3("DUE_CONTAT")[1])
		DUE->DUE_EMAIL 	:= PadR( aDadosCli[CLI_EMAIL][2]	,TamSX3("DUE_EMAIL")[1]	)
		DUE->DUE_CDRSOL := aDadosCli[CLI_CDRDES][2]
		DUE->DUE_DDD	:= aDadosCli[CLI_DDD][2]
		DUE->DUE_TEL	:= PadR( aDadosCli[CLI_TEL][2]		,TamSX3("DUE_TEL")[1])
		DUE->DUE_CODMUN	:= aDadosCli[CLI_CODMUN][2]
		DUE->(MsUnLock())

	ElseIf lSoliAut == "2" .And. DUE->(MsSeek(xFilial("DUE")+aDadosCli[CLI_CODCLI][2]+aDadosCli[CLI_LOJCLI][2]) )
		DUL->(dbSetOrder(2))
		If !DUL->(MsSeek(xFilial("DUL")+aDadosCli[CLI_CODCLI][2]+aDadosCli[CLI_LOJCLI][2]) )
			cAliasQry := GetNextAlias()
			cQuery 	:= " SELECT DUE_CODCLI, DUE_LOJCLI, DUE_END, DUE_BAIRRO, DUE_CEP, DUE_CODMUN"
			cQuery 	+= " FROM "
			cQuery	+= " "+RetSqlName('DUE')+" DUE "
			cQuery  += " WHERE DUE.DUE_FILIAL = '"+xFilial("DUE")+"'"
			cQuery 	+= " AND DUE.DUE_CODCLI = '" + aDadosCli[CLI_CODCLI][2] + "'"
			cQuery	+= " AND DUE.DUE_LOJCLI = '" + aDadosCli[CLI_LOJCLI][2] + "'"
			cQuery	+= " AND DUE.DUE_END	= '" + PadR( aDadosCli[CLI_END][2] ,TamSX3("DUE_END")[1]) + "'"
			cQuery	+= " AND DUE.DUE_BAIRRO = '" + PadR( aDadosCli[CLI_BAIRRO][2] ,TamSX3("DUE_BAIRRO")[1]) +  "'"
			cQuery	+= " AND DUE.DUE_CEP 	= '" + aDadosCli[CLI_CEP][2] + "'"
			cQuery	+= " AND DUE.DUE_CODMUN = '" + aDadosCli[CLI_CODMUN][2]+ "'"
			cQuery  += " AND DUE.D_E_L_E_T_  = ' '"

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

			If (cAliasQry)->(Eof())
				lCriaDUL := .T. 
			EndIf
			(cAliasQry)->(dbCloseArea())

		Else
			cAliasQry := GetNextAlias()
			cQuery 	:= " SELECT DUL_SEQEND, DUL_CODCLI, DUL_LOJCLI, DUL_END, DUL_BAIRRO, DUL_CEP, DUL_CODMUN"
			cQuery 	+= " FROM "
			cQuery	+= " "+RetSqlName('DUL')+" DUL "
			cQuery  += " WHERE DUL.DUL_FILIAL = '"+xFilial("DUL")+"'"
			cQuery 	+= " AND DUL.DUL_CODCLI = '" +aDadosCli[CLI_CODCLI][2]+ "'"
			cQuery	+= " AND DUL.DUL_LOJCLI = '" +aDadosCli[CLI_LOJCLI][2]+"'"
			cQuery	+= " AND DUL.DUL_END	= '" + PadR( aDadosCli[CLI_END][2] ,TamSX3("DUL_END")[1]) + "'"
			cQuery	+= " AND DUL.DUL_BAIRRO = '" + PadR( aDadosCli[CLI_BAIRRO][2] ,TamSX3("DUL_BAIRRO")[1]) +  "'"
			cQuery	+= " AND DUL.DUL_CEP 	= '" + aDadosCli[CLI_CEP][2] + "'"
			cQuery	+= " AND DUL.DUL_CODMUN = '" + aDadosCli[CLI_CODMUN][2]+ "'"
			cQuery  += " AND DUL.D_E_L_E_T_  = ' '"

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

			If (cAliasQry)->(Eof())
				lCriaDUL := .T. 
			EndIf
			(cAliasQry)->(dbCloseArea())

		EndIf 

		If lCriaDUL 
			Aadd( aCabDUL, { "DUL_FILIAL" , xFilial("DUL")  		 , Nil } )
			Aadd( aCabDUL, { "DUL_CODCLI" , aDadosCli[CLI_CODCLI][2] , Nil } )
			Aadd( aCabDUL, { "DUL_LOJCLI" , aDadosCli[CLI_LOJCLI][2] , Nil } )
			Aadd( aCabDUL, { "DUL_END"    , PadR( aDadosCli[CLI_END][2]		,TamSX3("DUL_END")[1])		, Nil } )
			Aadd( aCabDUL, { "DUL_BAIRRO" , PadR( aDadosCli[CLI_BAIRRO][2]	,TamSX3("DUL_BAIRRO")[1])	, Nil } )
			Aadd( aCabDUL, { "DUL_CEP"    , aDadosCli[CLI_CEP][2] 	 , Nil } )
			Aadd( aCabDUL, { "DUL_CODMUN" , aDadosCli[CLI_CODMUN][2] , Nil } )	
			
			MSExecAuto({|x,y| TMSA450(x,y)},aCabDUL,3)
			If !IsBlind() .And. lMsErroAuto  
				MostraErro()
			EndIf
		EndIf 

	EndIf 
    
	If lRet
		SA1->(DbSetOrder(1))
		//-- Chama a rotina automática de gravação do solicitante 
		MSExecAuto({|u,v,x| TMSA440(u,v,x)},aCabDUE,aColsDVJ,nOpcAuto)
		If !IsBlind() .And. lMsErroAuto  
			MostraErro()
		EndIf
	EndIf 

	FwFreeArray(aCabDUE)
	FwFreeArray(aItemDVJ)
	FwFreeArray(aColsDVJ)
	FwFreeArray(aCabDUL)
	Aeval(aAreas, {|aArea| RestArea(aArea), FwFreeArray(aArea) })
	FwFreeArray(aAreas)

Return lRet 
