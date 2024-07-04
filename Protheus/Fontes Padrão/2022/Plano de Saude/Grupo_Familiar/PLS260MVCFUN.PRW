#INCLUDE "PLSMGER.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSA260.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "hat-actions.ch"
#INCLUDE 'FWMBROWSE.CH'

/*/{Protheus.doc} PLS260COFZ
Substitui a função PLS260COFP
Valida no XB a consulta B43 . Trata o num. contrato
@author DEV TOTVS.
@since 05/08/2019
@version P12
/*/
Function PLS260COFZ(lHelp,oModel,cCodFor,nTipo)

Local lRet    	:= .T.
Local cEmp    	:= ""
Local cCodPlano := ""
Local cVerPlano := ""
Local cConEmp   := ""
Local cNumCom   := ""
Local cVerCon   := ""
Local cSubCon   := ""
Local cVerSub   := ""

Default lHelp 	:= .T.
Default cCodFor := If(oModel:cID == "PLSA260FD3PLANO",oModel:GetModel('MasterBA3'):GetValue('BA3_FORPAG'),oModel:GetModel('BA3DETAIL'):GetValue('BA3_FORPAG'))
Default nTipo   := 1


If oModel:cID == "PLSA260FD3PLANO"
	cEmp  	  := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT') + oModel:GetModel('MasterBA3'):GetValue('BA3_CODEMP')
	cCodPlano := oModel:GetModel('MasterBA3'):GetValue('BA3_CODPLA')
	cVerPlano := oModel:GetModel('MasterBA3'):GetValue('BA3_VERSAO')
	cConEmp   := BA3->BA3_CONEMP
	cNumCom   := BA3->BA3_NUMCON
	cVerCon   := BA3->BA3_VERCON
	cSubCon   := BA3->BA3_SUBCON
	cVerSub   := BA3->BA3_VERSUB
Else
	cEmp  	  := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT') + oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODEMP')
	cCodPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODPLA')
	cVerPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	cConEmp   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CONEMP')
	cNumCom   := ""//oModel:GetModel('BA3DETAIL'):GetValue('BA3_NUMCON')
	cVerCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERCON')
	cSubCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_SUBCON')
	cVerSub   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSUB')
Endif

BG9->(DBSetOrder(1))
BG9->(MsSeek(xFilial("BG9")+cEmp))

If BG9->BG9_TIPO == "2"
	lRet := PLSA260FPG(cCodPlano,cVerPlano,SubStr(cEmp,1,4),SubStr(cEmp,5,4),cConEmp,cCodFor,lHelp,nTipo,cVerCon,cSubCon,cVerSub,cCodPlano,cVerPlano)
Else
	lRet := PLSA260FPG(cCodPlano,cVerPlano,SubStr(cEmp,1,4),SubStr(cEmp,5,4),AllTrim(cNumCom),cCodFor,lHelp,nTipo,cVerCon,cSubCon,cVerSub,cCodPlano,cVerPlano)
Endif

DBSelectArea("BJ1")
Return(lRet)

/*/{Protheus.doc} PLSABA3MVC
Substitui a função PLSA260BA3
Valida a data analisando a versao do plano no contrato
@author DEV TOTVS
@since 06/08/2019
@version P12
/*/
Function PLSABA3MVC(oModel,nModel)

Local lRet		:= .T.
Local cChave    := ""
Local cCodPlano := ""
Local cVerPlano := ""
Local cConEmp   := ""
Local cVerCon   := ""
Local cSubCon   := ""
Local cVerSub   := ""
Local lAtuVar   := .T.

Local cCodPlaBA1:= ""
Local cVerPlaBA1:= ""
Local cDtIncBA1 := ""
Local dDataBas  := date()

Default oModel  := FwModelActive()
DeFault nModel	:= 1 // 1 Vem dos modelos BA3DETAIL e os demais BA1MASTER


If nModel = 1 .and. oModel:cID <> "PLSA260FD3PLANO"
	cChave    := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT') + oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODEMP')
	cCodPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODPLA')
	
	If !Empty(oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO'))
		cVerPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	Else
		oModel:LoadValue( 'BA3DETAIL','BA3_VERSAO',BI3->BI3_VERSAO )
		cVerPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	EndIf
	 
	dDataBas  := oModel:GetModel('BA3DETAIL'):GetValue('BA3_DATBAS')
	cConEmp   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CONEMP')
	cVerCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERCON')
	cSubCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_SUBCON')
	cVerSub   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSUB')
	dDataBas  := oModel:GetModel('BA3DETAIL'):GetValue('BA3_DATBAS')
	lAtuVar := .T.
ElseIf nModel = 1 .and. oModel:cID == "PLSA260FD3PLANO"
	cChave    := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT') + oModel:GetModel('MasterBA3'):GetValue('BA3_CODEMP')
	cCodPlano := oModel:GetModel('MasterBA3'):GetValue('BA3_CODPLA')
	cVerPlano := BA3->BA3_VERSAO
	dDataBas  := BA3->BA3_DATBAS
	cConEmp   := BA3->BA3_CONEMP
	cVerCon   := BA3->BA3_VERCON
	cSubCon   := BA3->BA3_SUBCON
	cVerSub   := BA3->BA3_VERSUB
	dDataBas  := BA3->BA3_DATBAS
	lAtuVar := .T.

Else
	cChave 	  := BA1->(BA1_CODINT+BA1_CODEMP) //Campos estaticos eu acesso direto a tabela
	cCodPlano := oModel:GetModel('BA1MASTER'):GetValue('BA1_CODPLA')
	cVerPlano := If(!Empty(oModel:GetModel('BA1MASTER'):GetValue('BA1_VERSAO')),oModel:GetModel('BA1MASTER'):GetValue('BA1_VERSAO'),"001")
	cConEmp   := BA1->BA1_CONEMP
	cVerCon   := BA1->BA1_VERCON
	cSubCon   := BA1->BA1_SUBCON
	cVerSub   := BA1->BA1_VERSUB
	lAtuVar   := .F.

Endif


BG9->(DBSetOrder(1))
BG9->(MsSeek(xFilial("BG9")+cChave))

lRet    := PLS260PLAMvc(cCodPlano,dDataBas,SubStr(cChave,1,4),SubStr(cChave,5,4),cConEmp,cVerCon,cSubCon,cVerSub, lAtuVar, , cVerPlano,Empty(cSubCon)  ) [1]

Return(lRet)

/*/{Protheus.doc} PLSA260GCMvc
Substitui a função PLSA260GCF
BA3_CODPLA - Validacao de campo
@author DEV TOTVS
@since 06/08/2019
@version P12
/*/
Function PLSA260GCMvc(oModel,lDireto)

Local cCodPlano := ""
Local cChaveBI3 := ""
Local cTipOUS   := ""
Local cCodEmp   := ""
Local cVerPlano := ""
Local cForPag   := ""
Local cForCTX   := ""
Local cCodInt   := ""
Local cConEmp   := ""
Local cSubCon   := ""
Local cVerCon   := ""
Local cVerSub   := ""

Default lDireto := .F.

If oModel:cID == "PLSA260FD3PLANO"

	cCodPlano := oModel:GetModel('MasterBA3'):GetValue('BA3_CODPLA')
	cChaveBI3 := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT') +cCodPlano+oModel:GetModel('MasterBA3'):GetValue('BA3_VERSAO')
	cCodEmp   := oModel:GetModel('MasterBA3'):GetValue('BA3_CODEMP')
	cVerPlano := BA3->BA3_VERSAO
	cForPag   := oModel:GetModel('MasterBA3'):GetValue('BA3_FORPAG')
	cForCTX   := oModel:GetModel('MasterBA3'):GetValue('BA3_FORCTX')
	cCodInt   := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT')
	cTipOUS   := BA3->BA3_TIPOUS
	cConEmp   := BA3->BA3_CONEMP
	cSubCon   := BA3->BA3_SUBCON
	cVerCon   := BA3->BA3_VERCON
	cVerSub   := BA3->BA3_VERSUB
Else
	cCodPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODPLA')
	cChaveBI3 := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT') +cCodPlano+oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	cTipOUS   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_TIPOUS')
	cCodEmp   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODEMP')
	cVerPlano := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	cForPag   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_FORPAG')
	cForCTX   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_FORCTX')
	cCodInt   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT')
	cConEmp   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CONEMP')
	cSubCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_SUBCON')
	cVerCon   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERCON')
	cVerSub   := oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSUB')
Endif


BI3->( dbSetorder(01) )
If BI3->( MsSeek(xFilial("BI3")+cChaveBI3) ) .and. BI3->BI3_STATUS == '2'
	If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
		Help("",1,"PLSSITANS")
	Else
		Help("",1,"PLSA260003")
	Endif
	Return(.F.)
Endif


If cTipOUS == "1" .and. !Empty(cForPag)//PF
	aRet := PLFORPAGPF(cCodPlano,cVerPlano, cForPag, cForCTX, lDireto, cCodInt)
	//forço através do LoadValue para não que seja feita validação de Dicionario
	If oModel:cID == "PLSA260FD3PLANO"

		oModel:LoadValue( 'MasterBA3','BA3_FORPAG', AllTrim(aRet[1]) )
		oModel:LoadValue( 'MasterBA3','BA3_DESFOR', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI")) )
		oModel:LoadValue( 'MasterBA3','BA3_ROTINA', AllTrim(aRet[2]) )
		oModel:LoadValue( 'MasterBA3','BA3_FORCTX', AllTrim(aRet[3]) )
		oModel:LoadValue( 'MasterBA3','BA3_DEFOTX', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI")) )
		oModel:LoadValue( 'MasterBA3','BA3_RATSAI', AllTrim(aRet[5]) )

	Else
		oModel:LoadValue( 'BA3DETAIL','BA3_FORPAG', AllTrim(aRet[1]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_DESFOR', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI")) )
		oModel:LoadValue( 'BA3DETAIL','BA3_ROTINA', AllTrim(aRet[2]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_FORCTX', AllTrim(aRet[3]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_DEFOTX', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI")) )
		oModel:LoadValue( 'BA3DETAIL','BA3_MODPAG', AllTrim(aRet[4]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_RATSAI', AllTrim(aRet[5]) )
	Endif					
	
	
ElseIf cTipOUS == "2" .and. !Empty(cForPag) //PJ
	//Forma de Cobranca Grp Empresa	
	aRet := PLFORPAGPJ(cCodPlano,cVerPlano, cForPag, cForCTX, lDireto, cCodEmp, cConEmp, cVerCon, cSubCon, cVerSub, cCodInt)
	//forço através do LoadValue para não que seja feita validação de Dicionario
	If oModel:cID == "PLSA260FD3PLANO"

		oModel:LoadValue( 'MasterBA3','BA3_FORPAG', AllTrim(aRet[1]) )
		oModel:LoadValue( 'MasterBA3','BA3_DESFOR', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI")) )
		oModel:LoadValue( 'MasterBA3','BA3_ROTINA', AllTrim(aRet[2]) )
		oModel:LoadValue( 'MasterBA3','BA3_FORCTX', AllTrim(aRet[3]) )
		oModel:LoadValue( 'MasterBA3','BA3_DEFOTX', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI")) )
		oModel:LoadValue( 'MasterBA3','BA3_RATSAI', AllTrim(aRet[5]) )
	Else	

		oModel:LoadValue( 'BA3DETAIL','BA3_FORPAG', AllTrim(aRet[1]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_DESFOR', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[1],"BJ1_DESCRI")) )
		oModel:LoadValue( 'BA3DETAIL','BA3_ROTINA', AllTrim(aRet[2]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_FORCTX', AllTrim(aRet[3]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_DEFOTX', BJ1->(Posicione("BJ1",1,xFilial("BJ1")+aRet[3],"BJ1_DESCRI")) )
		oModel:LoadValue( 'BA3DETAIL','BA3_MODPAG', AllTrim(aRet[4]) )
		oModel:LoadValue( 'BA3DETAIL','BA3_RATSAI', AllTrim(aRet[5]) )	
	Endif	
				
Endif

Return(.T.)




/*/{Protheus.doc} PLS260CAMPOS
Tratamento para ajustar os campos a serem utilizados nas telas.
@author DEV TOTVS
@since 05/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260CAMPOS(cCampo, cAlias,cFolder)

Local lRet		:= .F.
Local cSXCampo 	:= "X3_FOLDER"

If cAlias == "BA3" .and. cFolder == 'Cobranca'

	If GetSx3Cache(cCampo,"X3_FOLDER") == '6' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.	
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'Comercial'
	If GetSx3Cache(cCampo,cSXCampo) == '5' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.
	EndIF


ElseIf cAlias == "BA3" .and. cFolder == 'Plano'
	If GetSx3Cache(cCampo,cSXCampo) == '2' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC" )
		lRet := .T.
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'ANS'
	If GetSx3Cache(cCampo,cSXCampo) == '3' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'OUTROS'
	If GetSx3Cache(cCampo,cSXCampo) == ' ' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'Cadastro'
	If GetSx3Cache(cCampo,cSXCampo) == '1' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.
	EndIF

ElseIf cAlias == "BA3" .and. cFolder == 'LOG'
	If GetSx3Cache(cCampo,cSXCampo) == '7' .OR. (cCampo == "BA3_CODINT" .or. cCampo == "BA3_CODEMP" .or. cCampo == "BA3_MATRIC")
		lRet := .T.
	EndIF

ElseIf cAlias == "BA1" .and. cFolder == 'Pessoais'
	if GetSx3Cache(cCampo,cSXCampo) == '1' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'Plano'
	if GetSx3Cache(cCampo,cSXCampo) == '3' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" ;
	  		.or. cCampo == "BA1_DATINC")
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'Cobranca'	
	if GetSx3Cache(cCampo,cSXCampo) == '4' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'ANS'
	if GetSx3Cache(cCampo,cSXCampo) == '5' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'OUTROS'
	if GetSx3Cache(cCampo,cSXCampo) == '6' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

ElseIf cAlias == "BA1" .and. cFolder == 'Parcelamento'
	if GetSx3Cache(cCampo,cSXCampo) == '7' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif


ElseIf cAlias == "BA1" .and. cFolder == 'Demais'
	if GetSx3Cache(cCampo,cSXCampo) == ' ' .OR. (cCampo == "BA1_CODINT" .or. cCampo == "BA1_CODEMP" .or. cCampo == "BA1_MATRIC" .or. cCampo == "BA1_NOMUSR" )
		lRet := .T.
	endif

EndIF

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MENU
Menu
@author DEV TOTVS
@since 02/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260MENU(nOpMenu,lAutomato)

Default nOpMenu := 0
Default lAutomato := .f.

If nOpMenu == 1 		// Forma de Cobrança da Familia
	BJK->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BJK', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 2 	// Dados da Cobrança da Familia
	If(!lAutomato,FWExecView('Edição','PLSA260FD1COB', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 3		// Dados Comerciais da Familia
	If(!lAutomato,FWExecView('Edição','PLSA260FD2COME', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 4 	// Logs
	If(!lAutomato,FWExecView('Edição','PLSA260FD7LOGS', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 5 	// Dados do Plano da Familia
	If(!lAutomato,FWExecView('Edição','PLSA260FD3PLANO', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 6 	// Dados da ANS
	If(!lAutomato,FWExecView('Edição','PLSA260FD4ANS', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 7 	// Outros Dados
	If(!lAutomato,FWExecView('Edição','PLSA260FD5OUTROS', MODEL_OPERATION_UPDATE,, { || .T. } ),)	
Elseif nOpMenu == 8 	// Demais Dados Cadastrais
	If(!lAutomato,FWExecView('Edição','PLSA260FD6DEMAIS', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 9 	// Dados Pessoais	
	If(!lAutomato,FWExecView('Edição','PLSA260FD8BA1', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 10 	// Relativos ao Plano
	If(!lAutomato,FWExecView('Edição','PLSA260FD9BA1', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 11	// Dados da Cobrança	
	If(!lAutomato,FWExecView('Edição','PLSA260FDABA1', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 12	// Dados da ANS
	If(!lAutomato,FWExecView('Edição','PLSA260FDBBA1', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 13	// Outros Dados
	If(!lAutomato,FWExecView('Edição','PLSA260FDCBA1', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 14	// Regras de Parcelamento
	If(!lAutomato,FWExecView('Edição','PLSA260FDDBA1', MODEL_OPERATION_UPDATE,, { || .T. } ),)
Elseif nOpMenu == 15	// Outras Informações
	If(!lAutomato,FWExecView('Edição','PLSA260FDEBA1', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 16 	// Taxa de Adesão
	BJL->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BJL', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 17 	// Gratuidade
	BH5->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BH5', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 18	// Opcional do Beneficiario
	BF4->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BF4', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 19	// Gratuidade do Beneficiario
	BH6->(dbSetorder(1))
    If(!lAutomato,FWExecView('Edição','PLSA260BH6', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 20	// Grupo de Cobertura - Cobertura
	BFC->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BFC', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 21	// Grupo de Cobertura - Procedimentos
	BFD->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BFD', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 22	// Grupo de Cobertura - Grupo de Quantidade
	BW7->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BW7', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 23	// Grupo de Cobertura - Classe de Carência
	BFJ->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BFJ', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 24	// Cobertura - Grupos Determinados
	BFE->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BFE', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 25	// Cobertura - Procedimentos
	BFG->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BFG', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 26	// Cobertura - Grupo de Quantidade
	BW9->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BW9', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 27	// Cobertura - Classe de Carência
	BFO->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BFO', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 28	// Documentos Obrigatórios
	BCP->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BCP', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 29 	// Faixa Etaria Especifica do Beneficiario
	BDK->(dbSetorder(1))
	If(!lAutomato,FWExecView('Edição','PLSA260BDQ', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 30 	// Histórico Financeiro
	If(!lAutomato,FWExecView('Visualização','PLSA260SE1', MODEL_OPERATION_VIEW,, { || .T. } ),)
ElseIf nOpMenu == 31 	// Histórico Cobrança Carteirinha
	If(!lAutomato,FWExecView('Visualização','PLSA260BED', MODEL_OPERATION_VIEW,, { || .T. } ),)
ElseIf nOpMenu == 32 	// Histórico Bloqueio da Família
	If(!lAutomato,FWExecView('Visualização','PLSA260BC3', MODEL_OPERATION_VIEW,, { || .T. } ),)
ElseIf nOpMenu == 33 	// Doenças pré-existentes
	If(!lAutomato,FWExecView('Edição','PLSA260BF3', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 34 	// Situações Adversas
	If(!lAutomato,FWExecView('Edição','PLSA260BHH', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 35 	// Historico Bloqueio do usuário
	If(!lAutomato,FWExecView('Edição','PLSA260BCA', MODEL_OPERATION_UPDATE,, { || .T. } ),)
ElseIf nOpMenu == 36 	// Historico Parcelamento
	If(!lAutomato,FWExecView('Edição','PLSA260B78', MODEL_OPERATION_VIEW,, { || .T. } ),)
EndIf


Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS260PLAMvc
Reescrita da função PLSA260PLA
Valida a data analisando a versao do plano..
@author DEV TOTVS
@since 02/09/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260PLAMvc(cCodPla,dData,cCodInt,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,lAtuVar,cCodOpc,cVerPla,lJuridico)

Local lRet   	:= .F.
Local lBloq	 	:= .F.
Local cChave 	:= cCodInt+cCodPla
Local lBT6Found
Local lSitAns	:= .T.

Default lJuridico := .F.
Default lAtuVar := .T.
Default cCodOpc	:= ""
Default cVerPla := "001"


//Verificar so o plano esta disponivel para a empresa/contrato...
If BG9->BG9_TIPO == "2"

	If !Empty(cCodOpc)
		DbSelectArea("BHS")
		BHS->(DbSetOrder(1))//BHS_FILIAL + BHS_CODINT + BHS_CODIGO + BHS_NUMCON + BHS_VERCON + BHS_SUBCON + BHS_VERSUB + BHS_CODPRO + BHS_VERPRO + BHS_CODPLA + BHS_VERPLA
		If BHS->(MsSeek(xFilial("BHS")+cCodInt+cCodEmp+cNumCon+cVercon+cSubCon+cVerSub+cCodPla+cVerPla+cCodOpc))
			Return({.T.,BHS->BHS_VERPLA})
		Else
			Return({.T.,M->BF1_VERSAO})
		EndIf
	EndIf

	BT6->(DBSetOrder(1))

    lBT6Found := BT6->(MsSeek(xFilial("BT6")+cCodInt+cCodEmp+cNumCon+cVercon+cSubCon+cVerSub+cCodPla+cVerPla))

	If ! lBT6Found
	   Help("",1,"Codigo de Plano inexistente na base.")
	   Return({lRet,""})
	Else
		//Verificar se a data base e maior que a data do servidor...		
		BI3->(DbSetOrder(1))
		If BI3->(MsSeek(xFilial("BI3")+cChave))			
			//Posiciona na primeira versao...			
			BIL->(DbSetOrder(1))
			If BIL->(MsSeek(xFilial("BIL")+cChave))
				While ! BIL->(Eof()) .And. BIL->(BIL_FILIAL+BIL_CODIGO) == xFilial("BIL")+cChave
					If dtos(dData) >= dtos(BIL->BIL_DATINI) .And. dtos(dData) <= dtos(BIL->BIL_DATFIN)
						// Testa agora se a versao do produto disponivel esta ativa...
						If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))
							If BI3->BI3_STATUS <> '2' .and.  !BI3->BI3_SITANS $ "2,3"
								lRet := .T.
								Exit
							Else
								If inclui
									If !lJuridico
										lBloq := .T.
									Else
										lRet := .T.
										Exit
									EndIf
								Else
									If !lJuridico
										If PLS260IsTMvc()
											lBloq := .T.
										Else
											lRet := .T.
											Exit
										Endif
									Else
										lRet := .T.
										Exit
									EndIf
								Endif
							Endif
						Endif
					ElseIf Empty(BIL->BIL_DATFIN)
						If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO)) //BI3->(MsSeek(xFilial("BI3")+M->BA3_CODINT+M->BA3_CODPLA+BIL->BIL_VERSAO))
							If Dtos(dData) >= dtos(BIL->BIL_DATINI)
								If BI3->BI3_STATUS <> '2'.and.!BI3->BI3_SITANS $ "2,3"
									lRet := .T.
									Exit
								Else
									If inclui
										If !lJuridico
											lBloq := .T.
										Else
											lRet := .T.
											Exit
										EndIf
									Else
										If !lJuridico
											If PLS260IsTMvc()
												lBloq := .T.
											Else
												lRet := .T.
												Exit
											Endif
										Else
											lRet := .T.
											Exit
										EndIf
									Endif
								Endif
							Else
								// Se a versao selecionada nao estiver na faixa de datas e nao estiver bloqueada
								// Deve apresentar o help sobre a faixa de datas, entao desligo o flag de mensagem
								// de versao bloqueada, caso ela esteja ligada.
								If BI3->BI3_STATUS <> '2' .and. lBloq
									lBloq := .F.
								Endif
							Endif
						Endif
					Endif
					BIL->(DbSkip())
				Enddo
			Endif

			If ! lRet
				If !lBloq
					Help("",1,"PLS26003")
				Else
					If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
						If (!INCLUI .and. Readvar()=='M->BA3_CODPLA' .and. M->BA3_CODPLA == BA3->BA3_CODPLA) .or.;
						   (!INCLUI .and. Readvar()=='M->BA1_CODPLA' .and. IIf(Empty(BA1->BA1_CODPLA), M->BA3_CODPLA == BA3->BA3_CODPLA, M->BA1_CODPLA == BA1->BA1_CODPLA) )
							lSitAns	:= .F.
							lRet	:= .T.
						EndIf
						If !PLS260IsTMvc() .and. lSitAns
							Help("",1,"PLSSITANS")
						EndIf
					Else
						Help("",1,"PLSA260002")
					Endif
				Endif
				Return({lRet,""})
			Else
				BI3->(DbSetOrder(1))
				BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))
				If lAtuVar
					M->BA3_SEGPLA := BT6->BT6_CODSEG
					M->BA3_MODPAG := BT6->BT6_MODPAG
					M->BA3_APLEI  := BT6->BT6_APOSRG
					M->BA3_ABRANG := BT6->BT6_ABRANG
				Endif
			Endif
	    Endif
	Endif

	lRet := .T.

Else

	If !Empty(cCodOpc)

		DbSelectArea("BT3")
		BT3->(DbSetOrder(1))//BT3_FILIAL + BT3_CODIGO + BT3_VERSAO + BT3_CODPLA + BT3_VERPLA
		If BT3->(MsSeek(xFilial("BTS")+cCodInt+cCodPla+cVerPla+cCodOpc))
			Return({.T.,BT3->BT3_VERPLA})
		Else
			Return({.T.,M->BF1_VERSAO})
		EndIf

	EndIf
	//Verificar se a data base e maior que a data do servidor...

	BI3->(DbSetOrder(1))
	If BI3->(MsSeek(xFilial("BI3")+cChave))
		//Posiciona na primeira versao...		
		BIL->(DbSetOrder(1))
		If BIL->(MsSeek(xFilial("BIL")+cChave))
			While ! BIL->(Eof()) .And. BIL->(BIL_FILIAL+BIL_CODIGO) == xFilial("BIL")+cChave
				If     dtos(dData) >= dtos(BIL->BIL_DATINI) .And. dtos(dData) <= dtos(BIL->BIL_DATFIN)
					// Testa agora se a versao do produto disponivel esta ativa...
					If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))
						If BI3->BI3_STATUS <> '2'.and. !BI3->BI3_SITANS $ "2,3"
							lRet := .T.
							Exit
						Else
							If inclui
								lBloq := .T.
							Else
								If !PLS260IsTMvc()
									lBloq := .T.
								Else
									lRet := .T.
									Exit
								Endif
							Endif
						Endif
					Endif
				ElseIf Empty(BIL->BIL_DATFIN)
					// Testa agora se a versao do produto disponivel esta ativa...
					If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))//BI3->(MsSeek(xFilial("BI3")+M->BA3_CODINT+M->BA3_CODPLA+BIL->BIL_VERSAO))
						If Dtos(dData) >= dtos(BIL->BIL_DATINI)
							If BI3->BI3_STATUS <> '2' .and. !BI3->BI3_SITANS $ "2,3"
								lRet := .T.
								Exit
							Else
								If inclui
									lBloq := .T.
								Else
									If !PLS260IsTMvc()
										lBloq := .T.
									Else
										lRet := .T.
										Exit
									Endif
								Endif
							Endif
						Else
							// Se a versao selecionada nao estiver na faixa de datas e nao estiver bloqueada
							// Deve apresentar o help sobre a faixa de datas, entao desligo o flag de mensagem
							// de versao bloqueada, caso ela esteja ligada.
							If BI3->BI3_STATUS <> '2' .and. lBloq
								lBloq := .F.
							Endif
						Endif
					Endif
				Endif
				BIL->(DbSkip())
			Enddo
		Endif

		If ! lRet
			If !lBloq
				Help("",1,"PLS26003")
			Else
				If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
					If (!INCLUI .and. Readvar()=='M->BA3_CODPLA' .and. M->BA3_CODPLA == BA3->BA3_CODPLA) .or.;
   					   (!INCLUI .and. Readvar()=='M->BA1_CODPLA' .and. IIf(Empty(BA1->BA1_CODPLA), M->BA3_CODPLA == BA3->BA3_CODPLA, M->BA1_CODPLA == BA1->BA1_CODPLA) )
						lSitAns	:= .F.
						lRet	:= .T.
					EndIf
					If lSitAns
						Help("",1,"PLSSITANS")
					EndIf
				Else
					Help("",1,"PLSA260002")
				Endif
			Endif
			Return({lRet,""})
		Else
			BI3->(DbSetOrder(1))
			BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPla+BIL->BIL_VERSAO))
			If lAtuVar
				M->BA3_SEGPLA := BI3->BI3_CODSEG
				M->BA3_MODPAG := BI3->BI3_MODPAG
				M->BA3_APLEI  := BI3->BI3_APOSRG
				M->BA3_ABRANG := BI3->BI3_ABRANG
			Endif
		Endif
	Else
		Help("",1,"RECNO")
		Return({lRet,""})
	Endif
Endif

If lAtuVar
	If BG9->BG9_TIPO == "2"
		M->BA3_TIPCON := BT5->BT5_TIPCON
	Else
		M->BA3_TIPCON := GetNewPar("MV_PLSTIPC","1")
	Endif
Endif

Return({lRet,BIL->BIL_VERSAO})

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS260IsTit
Reescrita da função PLS260IsTit
Valida a data analisando a versao do plano..
@author DEV TOTVS
@since 02/09/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260IsTMvc()

Local lRetIsTit := .F.

If ReadVar() =='M->BA3_CODPLA' .Or. Type("M->BA1_TIPUSU") == "U"
	lRetIsTit:= BA1->BA1_TIPUSU <> GetNewPar("MV_PLCDTIT","T")
ElseIf ReadVar() == 'M->BF4_CODPRO'
	lRetIsTit:= BA1->BA1_TIPUSU <> GetNewPar("MV_PLCDTIT","T")
Else
	lRetIsTit:= BA1->BA1_TIPUSU <> GetNewPar("MV_PLCDTIT","T")
EndIf

Return lRetIsTit

//----------------------------------------------------------------
/*/{Protheus.doc} PLSVLDVIGMvc
--Substitui a função PLSVLDVIG
Validacao da vigencia
@author  DEV TOTVS
@version P12
@since   09/09/19
/*/
//----------------------------------------------------------------
Function PLSVLDVIGMvc(cAlias, oModel)

    Local lRet    := .T.
    Local nQTD    := ""
    Local nLinha  := ""
    Local dVigIni := ""
    Local dVigFim := ""
    Local nI      := 0
    Local cModel  := ""
    Local cCmpIni := ""
    Local cCmpFim := ""
    Local cCmpTip := ""


    If cALias == "BVC"
        cModel  := "BVCDETAIL"
        cCmpIni := "BVC_VIGINI"
        cCmpFim := "BVC_VIGFIM"
        cCmpTip := "BVC_TIPO"
        nQTD    := oModel:GetModel(cModel):Length(.T.)
        nLinha  := oModel:GetModel(cModel):GetLine()
        dVigIni := oModel:GetValue(cModel,cCmpIni)
        dVigFim := oModel:GetValue(cModel,cCmpFim)
        cTipo   := oModel:GetValue(cModel,cCmpTip)    
    ElseIf cAlias == "BVF"
        cModel  := "BVFDETAIL"
        cCmpIni := "BVF_VIGINI"
        cCmpFim := "BVF_VIGFIN"
        nQTD    := oModel:GetModel(cModel):Length(.T.)
        nLinha  := oModel:GetModel(cModel):GetLine()
        dVigIni := oModel:GetValue(cModel,cCmpIni)
        dVigFim := oModel:GetValue(cModel,cCmpFim)
        cTipo   := ""
        cCmpTip := ""
    ElseIf cAlias == "BVJ"
        cModel  := "BVJDETAIL"
        cCmpIni := "BVJ_VIGDE"
        cCmpFim := "BVJ_VIGATE"
        nQTD    := oModel:GetModel(cModel):Length(.T.)
        nLinha  := oModel:GetModel(cModel):GetLine()
        dVigIni := oModel:GetValue(cModel,cCmpIni)
        dVigFim := oModel:GetValue(cModel,cCmpFim)
        cTipo   := ""
        cCmpTip := ""
    ElseIf cAlias == "BVM"
        cModel  := "BVMDETAIL"
        cCmpIni := "BVM_VIGDE"
        cCmpFim := "BVM_VIGATE"
        nQTD    := oModel:GetModel(cModel):Length(.T.)
        nLinha  := oModel:GetModel(cModel):GetLine()
        dVigIni := oModel:GetValue(cModel,cCmpIni)
        dVigFim := oModel:GetValue(cModel,cCmpFim)
        cTipo   := ""
        cCmpTip := ""

    EndIf
        
    //Verifico se a vigência final é maior que a inicial.
    If !Empty(dVigFim) .and. dVigIni > dVigFim
        Help( ,, "Atenção",, "Vigência Final maior que a Inicial", 1, 0 )
        lRet := .F.
        Return(lRet)
    EndIf

    //Verifico se já existe uma vigência em aberto
    If nQtd > 1
        For nI := 1 To nQtd
            If nI <> nLinha
                oModel:GetModel(cModel):GoLine(nI)
                If !Empty(cTipo)
                    If cTipo == oModel:GetValue(cModel,cCmpTip)//Tipos diferentes podem ter vigencias iguais.
                        If !Empty(dVigFim) .and. (dVigIni >= oModel:GetValue(cModel,cCmpIni) .and. dVigIni <= oModel:GetValue(cModel,cCmpFim))//Verifico se estão no mesmo intervalo                
                            lRet := .F.
                            Help( ,, "Atenção",, "Já existe um intervalo de data que compreende a data selecionada!", 1, 0 )
                            Return(lRet)
                        EndIf
                    EndIf
                else
                    If !Empty(dVigFim) .AND. (dVigIni >= oModel:GetValue(cModel,cCmpIni)  .and. dVigIni <= oModel:GetValue(cModel,cCmpFim))//Verifico se estão no mesmo intervalo                
                        lRet := .F.
                        Help( ,, "Atenção",, "Já existe um intervalo de data que compreende a data selecionada!", 1, 0 )
                        Return(lRet)
                    EndIf
                    
                EndIf

            EndIf        
        Next nI

    else
    lRet := .T.
    EndIf

    //Retorno o Grid para a posição original
    If nQtd > 1
        oModel:GetModel(cModel):GoLine(nLinha)
    EndIf

Return (lRet)


/*/{Protheus.doc} PLSPermMVC
-*-*-*-Substitui a função PLSPerm*-*-*-
Verifica se o usuario possui permissao para usar o plano
que esta no contrato
@author Totver
@version P2
@since   22/08/19
/*/
//-------------------------------------------------------------------

Function PLSPermMVC(cTipUsu,cGrauPa,cEstCiv,cSexo,oBrwUsr,cCodInt,cCodPro,cVersao,dDatInc,dDatNas,;
		cCodEmp,cNumcon,cVerCon,cSubCon,cVerSub,lJuridico)

Local I
LOCAL aQtd      := {}
LOCAL nPos      := {0,0,0}
LOCAL _aQtdUsr  := {,,,}
LOCAL bClose    := {|| TrbBT1->(dbCloseArea())}
Local aArea     := GetArea()
LOCAL lRet      := .F.
Local Inclui    := .T.

Default cTipUsu := ""
Default cGrauPa := ""
Default cEstCiv := ""
Default cSexo   := ""
Default cCodInt := ""
Default cCodPro := ""
Default cVersao := ""
Default dDatInc := CtoD("")
Default dDatNas := CtoD("")
Default cCodEmp := ""
Default cNumcon := ""
Default cVerCon := ""
Default cSubCon := ""
Default cVerSub := ""
Default lJuridico := !Empty(cSubCon)


//Coloco na quantidade de usuarios este que estou tentando inserir
aadd(aQtd,{cTipUsu,cGrauPa,cEstCiv,cSexo,dDatNas})

BT0->(DBSetOrder(1))
BT1->(DBSetOrder(1))
BQC->(DBSetOrder(1))
BT6->(DBSetOrder(1))

//Verifico se o titular está ciente e de acordo com a RN 309. Se não estiver permito apenas a
//inclusão de conjuge e filhos no contrato. Os graus de parentesco estarão definidos no MV_RN309GP
If Inclui .and.  BQC->( msSeek(xFilial("BQC")+cCodInt+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub))
	If BT5->( MsSeek(xFilial("BT5")+cCodInt+cCodEmp+cNumCon+cVerCon) )
		DbSelectArea("BQC")
		If AllTrim(BT5->BT5_TIPCON) $ "2,3" .AND. IIF(BQC->( FieldPos("BQC_CIE309") ) > 0 , AllTrim(BQC->BQC_CIE309) $ '2,3',.F.)
			If !(cGrauPa $ GetNewPar("MV_RN309GP","01,02,03,04,05,06"))
				Help("",1,"PLS260R309")
				RestArea(aArea)
				Return(.F.)
			EndIf
		EndIf
	EndIf
EndIf


// Verifico no SubContrato para pessoa Juridica se o tipo de usuario pode usar o plano
If BT0->(MsSeek(xFilial("BT0")+cCodInt+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub+cCodPro+cVersao))
	//Verifica se esta dentro dos padroes de permissao  no Subcontrato Usuários Permitido...
	cSQL := "SELECT BT0_TIPUSR TIPUSR, BT0_GRAUPA GRAUPA, BT0_ESTCIV ESTCIV, BT0_SEXO SEXO, "
	cSQL +=    "BT0_NMIUSR NMIUSR, BT0_NMAUSR NMAUSR, BT0_IDAMIN IDAMIN, BT0_UNIMIN UNIMIN, BT0_IDAMAX IDAMAX, BT0_UNIMAX UNIMAX "
	cSQL +=   "FROM "+RetSQLName("BT0")+" WHERE "
	cSQL +=    "BT0_FILIAL = '"+xFilial("BT1")+"' AND "
	cSQL +=    "BT0_CODIGO = '"+cCodInt+cCodEmp+"' AND "
	cSQL +=    "BT0_NUMCON = '"+cNumCon+"' AND "
	cSQL +=    "BT0_VERCON = '"+cVerCon+"' AND "
	cSQL +=    "BT0_SUBCON = '"+cSubCon+"' AND "
	cSQL +=    "BT0_VERSUB = '"+cVerSub+"' AND "
	cSQL +=    "BT0_CODPRO = '"+cCodPro+"' AND "
	cSQL +=    "BT0_VERSAO = '"+cVersao+"' AND "
	cSQL +=    "BT0_ATIVO  = '1' AND " // somente regras ativas
	cSQL +=    "D_E_L_E_T_ = ' ' "
	cSQL +=  "ORDER BY BT0_TIPUSR DESC, BT0_GRAUPA DESC, BT0_ESTCIV DESC, BT0_SEXO DESC"
	PLSQuery(cSQL,"TrbBT1")
Else

	//Verifico se o produto e permitido para todos os usuario
	BI3->(DBSetOrder(1))
	If BI3->(MsSeek(xFilial("BI3")+cCodInt+cCodPro+cVersao))
		If BI3->BI3_ALLUSR == "1"
			If !lJuridico .and. !PLS260IsTMvc() .and. BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
				If !INCLUI .and. cCodPro == IIf(Empty(BA1->BA1_CODPLA), BA3->BA3_CODPLA, BA1->BA1_CODPLA)
					lSitAns	:= .F.
					lRet	:= .T.
				EndIf
				If !lRet
					Help("",1,"PLSSITANS")
				EndIf
				Return(lRet)
			Else
				//se ele eh permitido para todos usuarios retorna .t.
				RestArea(aArea)
				Return(.T.)
			Endif
		Endif
	Endif

	// Se não estiver para todos os Usuarios verifico  na BT1 (Produtos Usuários Permitidos  )
	// quais os tipo de usuario tem permissão para usar Pessoa Fisica

		
	cSQL := "SELECT BT1_TIPUSR TIPUSR, BT1_GRAUPA GRAUPA, BT1_ESTCIV ESTCIV, BT1_SEXO SEXO, "
	cSQL +=    "BT1_NMIUSR NMIUSR, BT1_NMAUSR NMAUSR, BT1_IDAMIN IDAMIN, BT1_UNIMIN UNIMIN, BT1_IDAMAX IDAMAX, BT1_UNIMAX UNIMAX "
	cSQL +=   "FROM "+RetSQLName("BT1")+" WHERE "
	cSQL +=    "BT1_FILIAL = '"+xFilial("BT1")+"' AND "
	cSQL +=    "BT1_CODIGO = '"+cCodInt+cCodPro+"' AND "
	cSQL +=    "BT1_VERSAO = '"+cVersao+"' AND "
	cSQL +=    "BT1_ATIVO  = '1' AND " // somente regras ativas
	cSQL +=    "D_E_L_E_T_ = ' ' "
	cSQL +=  "ORDER BY BT1_TIPUSR DESC, BT1_GRAUPA DESC, BT1_ESTCIV DESC, BT1_SEXO DESC"
	PLSQuery(cSQL,"TrbBT1")

Endif
While !TrbBT1->(Eof())
	_aQtdUsr := {,,,}
	For I := 1 to 4
		_aQtdUsr[I] := PL260QUsrMVC(I,aQtd,TrbBT1->TIPUSR,TrbBT1->GRAUPA,TrbBT1->ESTCIV,TrbBT1->SEXO)
	Next

	//Verifico se esta preenchido o Grau e o Tipo do Usuario, Estado Civil e Sexo...	
	if !Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cTipUsu == TrbBT1->TIPUSR .And. cGrauPa == TrbBT1->GRAUPA .And. cEstCiv   == TrbBT1->ESTCIV .And.;
				(TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==cTipUsu})
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==cGrauPa})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==cEstCiv})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[2] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Grau e o Tipo do Usuario, Estado Civil...	
	if !Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cTipUsu == TrbBT1->TIPUSR .And. cGrauPa == TrbBT1->GRAUPA .And. cEstCiv == TrbBT1->ESTCIV

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[2] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se esta preenchido o Grau e o Tipo do Usuario e Sexo...              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cTipUsu == TrbBT1->TIPUSR .And. cGrauPa == TrbBT1->GRAUPA .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[2] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif
	//Verifico se esta preenchido o Grau e o Estado Civil e Sexo..	
	if Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cGrauPa == TrbBT1->GRAUPA .And. cEstCiv   == TrbBT1->ESTCIV .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[2] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Tipo do Usuario, Estado Civil e Sexo...	
	if !Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cTipUsu == TrbBT1->TIPUSR .And. cEstCiv   == TrbBT1->ESTCIV .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

   //Verifico se esta preenchido o Grau e o Tipo do Usuario...	
	if !Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cTipUsu == TrbBT1->TIPUSR .And. cGrauPa== TrbBT1->GRAUPA

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[2] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif	
	
	//Verifico se esta preenchido o Estado Civil e Sexo...	
	if Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cEstCiv   == TrbBT1->ESTCIV .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Grau e o Sexo...	
	if Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cGrauPa== TrbBT1->GRAUPA .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[2] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Grau Estado Civil...	
	if Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cGrauPa== TrbBT1->GRAUPA .And. cEstCiv   == TrbBT1->ESTCIV

			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[2] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Tipo do Usuario, Estado Civil..	
	if !Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cTipUsu == TrbBT1->TIPUSR .And. cEstCiv   == TrbBT1->ESTCIV

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0 .And. nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Tipo do Usuario, Sexo...	
	if !Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if cTipUsu == TrbBT1->TIPUSR .And. (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif
	
	//Verifico se esta preenchido o Tipo do Usuario...	
	if !Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cTipUsu == TrbBT1->TIPUSR

			nPos[1] := aScan(_aQtdUsr[1],{|x|x[1]==TrbBT1->TIPUSR})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[1] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[1,nPos[1],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[1,nPos[1],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	//Verifico se esta preenchido o Sexo...	
	if Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. !Empty(TrbBT1->SEXO)
		if (TrbBT1->SEXO == cSexo .Or. TrbBT1->SEXO == "3")
			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
				Eval(bClose)
				RestArea(aArea)
				lRet:= .T.
			Endif
		Endif
	Endif

	lFlag := .F.

	//Verifico se esta preenchido o Estado Civil..	
	if Empty(TrbBT1->TIPUSR) .And. Empty(TrbBT1->GRAUPA) .And. !Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cEstCiv   == TrbBT1->ESTCIV
			nPos[3] := aScan(_aQtdUsr[3],{|x|x[1]==TrbBT1->ESTCIV})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[3] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[3,nPos[3],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[3,nPos[3],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	lFlag := .F.

	//Verifico se esta preenchido o Grau...	
	if Empty(TrbBT1->TIPUSR) .And. !Empty(TrbBT1->GRAUPA) .And. Empty(TrbBT1->ESTCIV) .And. (Empty(TrbBT1->SEXO) .or. TrbBT1->SEXO == "3")
		if cGrauPa== TrbBT1->GRAUPA
			nPos[2] := aScan(_aQtdUsr[2],{|x|x[1]==TrbBT1->GRAUPA})

			If (TrbBT1->UNIMIN == "1")
				nDataPadMin := DateDiffMonth(dDatInc,dDatNas)
			ElseIf (TrbBT1->UNIMIN == "0" .Or. TrbBT1->UNIMIN == " " )
					nDataPadMin := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMin := DateDiffYear(dDatInc,dDatNas)
			EndIf

			If (TrbBT1->UNIMAX == "1")
				nDataPadMax := DateDiffMonth(dDatInc,dDatNas)
				ElseIf (TrbBT1->UNIMAX == "0" .Or. TrbBT1->UNIMAX == " ")
					nDataPadMax := DateDiffDay(dDatInc,dDatNas)
				Else
				 	nDataPadMax := DateDiffYear(dDatInc,dDatNas)
			EndIf

			nDataI := TrbBT1->IDAMIN *(if(TrbBT1->UNIMIN=="0" .or. TrbBT1->UNIMIN==" " ,365.25,if(TrbBT1->UNIMIN=="1",12,1)))
			nDataF := TrbBT1->IDAMAX *(if(TrbBT1->UNIMAX=="0" .or. TrbBT1->UNIMAX==" " ,365.25,if(TrbBT1->UNIMAX=="1",12,1)))

			if nPos[2] > 0
				if nDataPadMin >= nDataI  .And.;
					nDataPadMax <= nDataF .And.;
						_aQtdUsr[2,nPos[2],2] >= TrbBT1->NMIUSR .And.;
						_aQtdUsr[2,nPos[2],2] <= TrbBT1->NMAUSR
					Eval(bClose)
					RestArea(aArea)
					lRet:= .T.
				Endif
			Endif
		Endif
	Endif

	TRBBT1->(DbSkip())
Enddo
Eval(bClose)
RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAPPRDPMVC
-*-*-*-Substitui a função PLSAPPRDPq*-*-*-
Pesquisa os Opcionais na base de dados como um opcional
@author Totver
@version P2
@since   22/08/19
/*/
//-------------------------------------------------------------------

Function PLSAPPRDPMVC(aBrowPro,aVetPad,oBrowPro,cNumCon,cCodInt,cCodEmp,cCodPla,cVersao,cSubCon,lValid,cCampo,oModel)
Local aArea    := GetArea()
Local cSQL
//Local dDt
//Local aOpcoes  	:= {}
Local cRetBI3  	:= BI3->(RetSQLName("BI3"))
Local cRetBHS  	:= BHS->(RetSQLName("BHS"))
Local cRetBT3  	:= BT3->(RetSQLName("BT3"))
Local cRetBE5  	:= BG9->(RetSQLName("BE5"))
Local lRet 	   	:= .F.



DEFAULT lValid 	:= .F.
DEFAULT cCampo 	:= READVAR()
DEFAULT cSubCon := ""
DEFAULT cVersao := ""
DEFAULT oModel  := FwModelActive()

//Verifica se o usuario tem um plano especifico
If BG9->BG9_TIPO == "1" .And. !Empty(BA1->BA1_CODPLA)
    cCodPla := BA1->BA1_CODPLA
    cVersao := BA1->BA1_VERSAO
EndIf

//Posiciona no grupo/empresa...
//If BG9->(BG9_CODINT+BG9_CODIGO) <> cCodInt+cCodEmp
//	BG9->(DbSetOrder(1))
//	BG9->(MsSeek(xFilial("BG9")+cCodInt+cCodEmp))
//Endif

//Limpa resultado...
If !lValid
   aBrowPro := {}
EndIf

If BG9->BG9_TIPO == "1"

	//Faz uma pesquisa pelos produtos vinculados ao produto do contrato	
	cSQL := "SELECT DISTINCT BT3_FILIAL, BT3_CODIGO, BT3_CODPLA "
	cSQL += "  FROM "+cRetBT3
	cSQL += " WHERE BT3_FILIAL = '"+xFilial("BT3")+"'"
	cSQL += "   AND "+cRetBT3+".D_E_L_E_T_ = '' "
	cSQL += "   AND BT3_CODIGO = '"+cCodInt+cCodPla+"'"

	cSQL += "   AND BT3_VERSAO = '"+cVersao+"'"
	cSQL += "   AND BT3_CODPLA IN (SELECT BI3_CODIGO "
	cSQL +=                       "  FROM "+cRetBI3+","+cRetBE5
    cSQL +=                       " WHERE BI3_FILIAL = '"+xFilial("BI3")+"'"
    cSQL +=                       "   AND BE5_FILIAL = '"+xFilial("BE5")+"'"
    cSQL +=                       "   AND "+cRetBI3+".D_E_L_E_T_ = ''"
    cSQL +=                       "   AND "+cRetBE5+".D_E_L_E_T_ = ''"
    cSQL +=                       "   AND BE5_CODGRU = BI3_GRUPO "
    cSQL +=                       "   AND (BE5_PEROPC = '1' OR BE5_PERAGR = '1')"
    cSQL +=                       "   AND BI3_STATUS <> '2' ) "
    cSQL += " ORDER BY BT3_FILIAL, BT3_CODIGO, BT3_CODPLA "

    cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbPes",.T.,.T.)

	TrbPes->(DbGoTop())
	While ! TrbPes->(Eof())
		If !lValid
		   If aScan(aBrowPro,{ |x| x[1] == TrbPes->BT3_CODIGO }) == 0
		     	TrbPes->(aadd(aBrowPro,{BT3_CODPLA,;
		    	Posicione("BI3",1,xFilial("BI3")+cCodInt+BT3_CODPLA,"BI3_DESCRI")}))
		   Endif
		Else
           If cCampo $ "BF1_CODPRO" .And. oModel:GetModel('BF1DETAIL'):GetValue('BF1_CODPRO') == TrbPes->BT3_CODPLA
		      lRet := .T.
		   ElseIf cCampo $ "BF4_CODPRO" .And. oModel:GetModel("BF4DETAIL"):GetValue("BF4_CODPRO") == TrbPes->BT3_CODPLA
		      lRet := .T.
		   ElseIf cCampo $ "BK0_CODFOR" .And. oModel:GetModel("BK0DETAIL"):GetValue("BK0_CODFOR") == TrbPes->BT3_CODPLA
		      lRet := .T.			  
		   EndIf
		EndIf
		TrbPes->(DbSkip())
	Enddo

	TrbPes->(DbCloseArea())
	RestArea(aArea)
Else
	//Faz uma pesquisa agora para os produtos opcionais do Grupo/Empresa
	cSQL := "SELECT BI3_DESCRI, BHS_CODINT, BHS_CODIGO, BHS_NUMCON, BHS_CODPLA, BE5_PEROPC, BE5_CODGRU, "
	cSql += "       BI3_GRUPO,  BI3_CODINT, BI3_CODIGO  "
	cSQL += "  FROM "+cRetBHS+","+cRetBE5+","+cRetBI3
	cSQL += " WHERE BHS_FILIAL = '"+xFilial("BHS")+"'"
	cSQL += "   AND "+cRetBHS+".D_E_L_E_T_ = ' '"
	cSQL += "   AND BHS_CODINT = '"+cCodInt+"'"
	cSQL += "   AND BHS_CODIGO = '"+cCodEmp+"'"
	cSQL += "   AND BHS_NUMCON = '"+cNumCon+"'"
	cSQL += "   AND BHS_SUBCON = '"+cSubCon+"'"
	cSQL += "   AND BHS_CODPRO = '"+cCodPla+"'"
	cSQL += "   AND BE5_CODGRU = BI3_GRUPO "
	cSQL += "   AND BI3_CODINT = '"+cCodInt+"'"
	cSQL += "   AND BE5_PEROPC = '1' "
	cSQL += "   AND BI3_CODIGO = BHS_CODPLA "
   	

	cSQL += " ORDER BY BHS_FILIAL, BHS_CODINT, BHS_CODPRO"
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TrbPes",.F.,.T.)

	TrbPes->(DbGoTop())
	While ! TrbPes->(Eof())
		If !lValid
		   If aScan(aBrowPro,{ |x| x[1] == TrbPes->BHS_CODPLA }) == 0
		      TrbPes->(aadd(aBrowPro,{BHS_CODPLA,;
			  TrbPes->BI3_DESCRI}))
		   Endif
		Else
		   If cCampo $ "BF1_CODPRO" .And. oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO") == TrbPes->BHS_CODPLA
		      lRet := .T.
		   ElseIf cCampo $ "BF4_CODPRO" .And. oModel:GetModel("BF4DETAIL"):GetValue("BF4_CODPRO") == TrbPes->BHS_CODPLA
		      lRet := .T.
		   EndIf
		Endif
		TrbPes->(DbSkip())
	Enddo

	TrbPes->(DbCloseArea())
	RestArea(aArea)
Endif

If !lValid
   //Testa resultado da pesquisa...
    If Len(aBrowPro) == 0
      aBrowPro := aClone(aVetPad)
   Endif

	//Atualiza browse...   
   oBrowPro:SetArray(aBrowPro)
   oBrowPro:Refresh()
   oBrowPro:SetFocus()

EndIf

//Fim da Rotina...
Return(lRet)

/*/{Protheus.doc} PLSPESPROMvc
*--Substitui a função PLSPESPROD
função utilizada na propriedade WHEN do campo BF4_CODPRO
para que permita a edição do campo caso o opcional não tenha
sido gravado na tabela para que no momento do desbloqueio do
mesmo registro, o usuário não possa alterar o opcional
@author Totver
@since 22/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSPESPROMvc()
LOCAL oDlgPesPro
LOCAL nOpca      := 0
LOCAL aBrowPro   := {}
LOCAL aVetPad    := { {"",""} }
LOCAL oBrowPro
LOCAL bRefresh   := { || PLSAPPRDPMVC(aBrowPro,aVetPad,oBrowPro,cNumCon,cCodInt,cCodEmp,cCodPla,cVersao,cSubCon), If( Empty(aBrowPro[1,1]),.F.,.T. ) }
LOCAL bOK        := { || nLin := oBrowPro:nAt, If(Empty(aBrowPro[1,1]),nOpca := 3,nOpca := 1),oDlgPesPro:End() }
LOCAL bCanc      := { || nOpca := 3,oDlgPesPro:End() }
LOCAL nLin       := 1

cNumCon  := BA3->BA3_CONEMP
cCodInt  := BA3->BA3_CODINT
cCodEmp  := BA3->BA3_CODEMP
cCodPla  := BA3->BA3_CODPLA
cVersao  := BA3->BA3_VERSAO
cSubCon  := BA3->BA3_SUBCON

aBrowPro         := aClone(aVetPad)
//Define dialogo...
	DEFINE MSDIALOG oDlgPesPro TITLE OemtoAnsi(STR0105) FROM 008.2,000 TO 025,ndColFin OF GetWndDefault() //"Pesquisa de Produtos Opcionais"
//Monta Browse...
oBrowPro := TcBrowse():New( 033, 008, 378, 093,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowPro:AddColumn(TcColumn():New(OemtoAnsi(STR0106),nil,; //"Codigo"
nil,nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowPro:ACOLUMNS[1]:BDATA     := { || aBrowPro[oBrowPro:nAt,1] }
oBrowPro:AddColumn(TcColumn():New(Oemtoansi(STR0107),nil,; //"Nome"
nil,nil,nil,nil,120,.F.,.F.,nil,nil,nil,.F.,nil))
oBrowPro:ACOLUMNS[2]:BDATA     := { || aBrowPro[oBrowPro:nAt,2] }

oBrowPro:SetArray(aBrowPro)
oBrowPro:BLDBLCLICK := bOK
Eval(bRefresh)
//Ativa o Dialogo...
ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.) })

If nOpca == K_OK
	If !Empty(aBrowPro[1,1])
		BI3->(DBSetOrder(1))
		BI3->(MsSeek(xFilial("BI3")+cCodInt+aBrowPro[nLin,1]))
	Endif
Endif

Return(nOpca==K_OK)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLChkOpcMvc
*--Substitui a função PL260ChkOpc
Funcao que verifica a data base no BF4 BIL_DATINI
@author Totver
@since 03/09/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLChkOpcMvc(nTipo, oModel)
Local lRet		:= .T.
Local dDatNov	:= ReadVar()


If nTipo = 1 // opcional na familia //Verificar depois, quando implementar na familia
	IF BIL->(DbSeek(xFilial("BIL")+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO)) 
		If BIL->BIL_DATINI >= &dDatNov
			MsgAlert(OemtoAnsi(STR0247))//"A data base deve ser maior ou igual a data inicial da versão do produto"
			lRet := .F.
		Endif
	Endif
Else
	// opcional no Usuario
		IF BIL->(DbSeek(xFilial("BIL")+BI3->BI3_CODINT+BI3->BI3_CODIGO+BI3->BI3_VERSAO)) .and. !Empty(oModel:GetModel('BF4DETAIL'):GetValue('BF4_CODPRO'))
			If BIL->BIL_DATINI >= &dDatNov
				MsgAlert(OemtoAnsi(STR0247))//"A data base deve ser maior ou igual a data inicial da versão do produto"
				lRet := .F.
			Endif
		Endif
		
		IF lRet
			//Verificar se já existe outros produtos no grid	
			If oModel:GetModel('BF4DETAIL'):Length(.T.) > 1
				
				If BF4->BF4_DATBAS <> oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBAS')
					
					If oModel:GetModel('BF4DETAIL'):GetValue('BF4_TIPBLO') == "0" .AND. !EMPTY(BF4->BF4_DATBLO) 
					
						MsgAlert(OemtoAnsi(STR0265))//"A alteração da data base será permitida após o debloqueio do opcional."
						oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBAS'):= BF4->BF4_DATBAS 
						lRet := .F.
					
					ElseIf oModel:GetModel('BF4DETAIL'):GetValue('BF4_TIPBLO') == "1" .And. oBrwOUsu:aCols[oBrwOUsu:Linha(),oBrwOUsu:PlRetPos("BF4_TIPBLO")] =="1"
					
						MsgAlert(OemtoAnsi(STR0266)) //"Opcional já Desbloqueado. Realize o Bloqueio para alterar a data base!"						
						oModel:GetModel('BF4DETAIL'):LoadValue('BF4_DATBAS',BF4->BF4_DATBAS)						
						lRet := .F.
					Endif
				EndIf
			EndIf 
		ENDIF 
	
		If oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBAS') > oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBLO') .AND.;
		 	!EMPTY(oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBLO')) .AND. lRet
			msgAlert(STR0262,STR0242) //STR0262,"A ve ser menor ou igual a data de bloqueio.##"Atenção"
			lRet := .F.
		EndIf

EndIf


If nTipo = 1
	    dDataBas :=  oModel:GetModel('BF1DETAIL'):GetValue('BF1_DATBAS')    
   Else
	    dDataBas :=  oModel:GetModel('BF4DETAIL'):GetValue('BF4_DATBAS')
Endif 

If (BA1->BA1_DATINC > dDataBas) 
   MsgAlert(STR0281,STR0071) //STR0281,"A data base deve ser maior ou igual a data de Inclusão do Beneficiário.##"Atenção"
   lRet := .F.
EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridBYXValid
Criação do array para validação de tipo de usuario, grau de parentesco, estado civil e sexo
Essa função é chamada da PLSPermMVC 
@author Totver
@since 04/09/19
@version P12
/*/

Static Function PL260QUsrMVC(nTipo,aVet,cTIPUSR,cGRAUPA,cESTCIV,cSEXO)
//nTipo
//  1 - Tipo Usuario
//  2 - Grau Parentesco
//  3 - Estado Civil
//  4 - Sexo
LOCAL _I := 0
LOCAL nTemp   := 0
Local cTemp   := ""
LOCAL aQtdUsr := {}
For _I := 1 to Len(aVet)
	If 	aVet[_I,1] == cTipUSR .and.;
		(aVet[_I,2] == cGrauPa .Or. Empty(cGrauPa)) .and.;
		(aVet[_I,3] == cEstCiv .or. Empty(cEstCiv)) .and.;
		(aVet[_I,4] == cSexo .or. cSexo == "3" .or. Empty(cSexo))
		if !Empty(aVet[_I,1])
			cTemp := aVet[_I,nTipo]
			nTemp := aScan(aQtdUsr,{|x|x[1]==cTemp})
			if nTemp > 0
				aQtdUsr[nTemp,2] := aQtdUsr[nTemp,2] + 1
			Else
				aadd(aQtdUsr,{aVet[_I,nTipo],1})
			Endif
		Endif
	EndIf
Next
Return(aQtdUsr)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlM260NAlMVC
Substitui a função ³PLSM260NAl 
Nao permite alteracao do codigo da cobranca caso ja tenha propriedades
@author  DEV TOTVS
@version P12
@since   19/08/19
/*/
//-------------------------------------------------------------------
Function PlM260NAlMVC(oModel, cAlias)

	Local lEdita := .T.
	Local cCodFor
	Local nOpc 		 := oModel:GetOperation()
	Local aAreaBJK   := BJK->(GetArea())
	Local aSaveLines := FWSaveRows()

	//Se tem dados na BBU e BFY, eu não permito editar a BJK
		if cAlias == "BJK" .AND. nOpc == MODEL_OPERATION_UPDATE
			BJK->(DbSetOrder(1))
			BJK->(MsSeek(xFilial('BJK')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
			cCodFor := BJK->BJK_CODFOR
		Elseif cAlias = "BJL" .AND. nOpc == MODEL_OPERATION_UPDATE
			cCodFor := M->BJL_CODFOR
		Elseif cAlias = "BK0" .AND. nOpc == MODEL_OPERATION_UPDATE		
			cCodFor := M->BK0_CODFOR 
		Elseif cAlias = "BYX" .AND. nOpc == MODEL_OPERATION_UPDATE				
			cCodFor := BYX->BYX_CODFOR
		Endif

		If cAlias == "BJK" 
			oBJK := oModel:GetModel( 'BJKDETAIL' )
			oBjk:GoLine(oBjk:getline())
		 	If !Empty(oBJK:GetValue('BJK_CODFOR')) .AND. oBJK:GetValue('BJK_CODFOR') == cCodFor	
				lEdita := .F.
			Endif	
			RestArea(aAreaBJK)
		ElseIf cAlias == "BF4" .AND. !Empty(oModel:GetValue("BYXDETAIL", 'BYX_CODFOR')) .AND. oModel:GetValue( "BYXDETAIL",  'BYX_CODFOR') == cCodFor	
			lEdita := .F.
		EndIf

		
	
	FWRestRows( aSaveLines )
Return (lEdita)

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldCbMVC
Substitui a função PlsVldCb 
Funcao para verificar se forma de cobranca pode ser digitada
@author  DEV TOTVS
@version P12
@since   20/08/19
/*/
//-------------------------------------------------------------------
Function PlsVldCbMVC(cTipo, cUso, cCpoDescri, uCampos,oModel,cCodFor)

	Local lRet    := .T.
	Local cDesUsu := ""
	
	Default cCodFor := ""

	If cCpoDescri == "BYX_DESFOR"
		cCodFor := oModel:GetValue("BYXDETAIL","BYX_CODFOR")
	ElseIf cCpoDescri == "BJL_DESFOR"
		cCodFor := oModel:GetValue("BJLDETAIL","BJL_CODFOR")
	ElseIf cCpoDescri == "BK0_CODFOR"
		cCodFor := oModel:GetValue("BK0DETAIL","BK0_CODFOR")	
	Else
		cCodFor := oModel:GetValue("BJKDETAIL","BJK_CODFOR")
	EndIf

	If ! BJ1->(MsSeek(xFilial("BJ1") + cCodFor))
		lRet := .F.
		Help("",1,"REGNOIS")
	Else
		If BJ1->BJ1_TIPO <> cTipo
			ApMsgAlert(	'Codigo da Cobranca invalido. Somente podera ser informado' +; //"Codigo da Cobranca invalido. Somente podera ser informado "
						AllTrim(QA_CBOX("BJ1_TIPO",cTipo)) + ".")
			lRet := .F.
		Endif
		If ! cUso $ BJ1->BJ1_USO
			If cUso = "1"
				cDesUsu := 'no Produto'
			ElseIf cUso = "2"
				cDesUsu := 'no Grupo/Empresa'
			ElseIf cUso = "3"
				cDesUsu := 'na Familia'
			ElseIf cUso = "4"
				cDesUsu := 'no Usuario'
			Endif
			ApMsgAlert(	'Codigo da Cobranca invalido. Nao pode ser informado' +;
						cDesUsu)
			lRet := .F.
		Endif
	Endif

	If lRet .And. cCpoDescri # Nil
		&("M->" + cCpoDescri) := BJ1->BJ1_DESCRI
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBusMatric
Inicializador padrão do codigo da mtricula
@author  DEV TOTVS
@version P12
@since   10/01/2020
/*/
//-------------------------------------------------------------------

Function PlsBusMatric()

cMatric:= BA1->BA1_MATRIC


 Return cMatric



//-------------------------------------------------------------------
/*/{Protheus.doc} 
Função de Pré Validação do Model
Retorna a chave do plano na BA3
@author Totver
@since 09/08/2019
@version P12
/*/
//-------------------------------------------------------------------

Function RetFilPla(oModel)
Local cRet := ""	
	If oModel:cID == "PLSA260FD3PLANO"
		cRet := oModel:GetModel('MasterBA3'):GetValue('BA3_CODINT')+oModel:GetModel('MasterBA3'):GetValue('BA3_CODPLA')//+oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	Else
		cRet := oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODINT')+oModel:GetModel('BA3DETAIL'):GetValue('BA3_CODPLA')//+oModel:GetModel('BA3DETAIL'):GetValue('BA3_VERSAO')
	Endif
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaCampMVC

Devido aos campos que estao como não usado para atender ao cadastro 
antigo temos que criar esse campos no Model e na View 
@author Team PLS
@param nOp 		= 1 pra Model/2 pra View
	   oStruBA1	= Estrutura a ser adicionada os campos
	   cCampo   = Campo a ser criado na estrutua
	   cOrdem   = Ordem a ser criada o campo (Especifico pra View)
@return Retorna a estrura com os campos adicionados
@since 25/10/2019
@version P12
/*/
//-------------------------------------------------------------------

Function CriaCampMVC(nOp,oStruTab,cCampo,cOrdem)

Local aDadosCpo

Default nOp    := 0
Default cCampo := ""
Default cOrdem := ""

If nOp == 1 .AND. !Empty(cCampo) // Cria os campos para a Model
	aDadosCpo := TxSX3Campo(cCampo)
	oStruTab:AddField(			;
					aDadosCpo[1]			, ;	// [01] Titulo do campo	
					aDadosCpo[2]			, ;	// [02] ToolTip do campo
					cCampo					, ;	// [03] Id do Field
					aDadosCpo[6]			, ;	// [04] Tipo do campo
					aDadosCpo[3]			, ;	// [05] Tamanho do campo
					aDadosCpo[4]			, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .F. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						,;	// [10] Indica se o campo tem preenchimento obrigatÃ¯Â¿Â½rio
					FWBuildFeature( STRUCT_FEATURE_INIPAD, GetSx3Cache(cCampo, "X3_RELACAO") ))	// [11] Inicializador Padrão do campo
								
											
ElseIf nOp == 2 .AND. !Empty(cCampo) .AND. !Empty(cOrdem) // Cria os campos para View
	aDadosCpo := TxSX3Campo(cCampo)
	oStruTab:AddField(cCampo	,;	// [01]  C   Nome do Campo
				cOrdem			,;	// [02]  C   Ordem
				aDadosCpo[1]	,;	// [03]  C   Titulo do campo
				aDadosCpo[1]	,;	// [04]  C   Descricao do campo
				NIL				,;	// [05]  A   Array com Help
				aDadosCpo[6]	,;	// [06]  C   Tipo do campo
				aDadosCpo[5]	,;	// [07]  C   Picture
				NIL				,;	// [08]  B   Bloco de Picture Var
				NIL				,;	// [09]  C   Consulta F3
				.F.				,;	// [10]  L   Indica se o campo é alteravel
				NIL				,;	// [11]  C   Pasta do campo
				NIL				,;	// [12]  C   Agrupamento do campo
				Iif(!Empty(aDadosCpo[7]),StrTokArr(Alltrim(aDadosCpo[7]),';'),NIL)			,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL				,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL				,;	// [15]  C   Inicializador de Browse
				.F.				,;	// [16]  L   Indica se o campo é virtual
				NIL				,;	// [17]  C   Picture Variavel
				NIL				)	// [18]  L   Indica pulo de linha após o campo

EndIf

Return oStruTab


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSACHKMENU

Funçõao que determina na chamdado do menu se vai utilizar o modelo de titular ou dependnete
para os itens de cpnsulta, alteração e exclusão.
@author Team PLS
@param nOperation 			= 2 Consultar
							= 3 Incluir
							= 4 Alterar
							= 5 Excluir
						   
@return nil
@since 30/10/2019
@version P12
/*/
//-------------------------------------------------------------------


Function PLSACHKMENU(nOperation,lAutomato)
Local aAreaBa1 := BA1->(Getarea())
Default lAutomato	:= .F.

Default nOperation = 3

If(!lAutomato,BA1->(DbGoTo(oBrowse:nat)),)

If BA1->BA1_TIPUSU	= "T"			
	PLSA260VLMVC(nOperation,lAutomato)	
Else

	If(!lAutomato,FWExecView('','PL260DEPMVC' , nOperation,, { || .T. } ),)
Endif	

RestArea(aAreaBa1)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PosFinBenef()
Chamada para exibir a posiçã0 financeira do beneficiario.
@author Totver
@since 12/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PosFinBenef()

If BA3->((DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC))))

	PLPOSFIN(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),.T.,.T.)

Endif

Return





