#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TbIconn.ch"
#INCLUDE 'PCPA119.CH'

Function PCPA119()

	Local oBrowse

	//Proteção do fonte para não ser utilizado pelos clientes neste momento.
	If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		HELP(' ',1,"Help" ,,STR0009,2,0,,,,,,) //"Rotina não disponível nesta release."
		Return
	EndIf 

	oBrowse := BrowseDef()
	oBrowse:Activate()

Return NIL

Static Function BrowseDef()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SVC')
	oBrowse:SetDescription(STR0004) //Versão da Produção

Return oBrowse

Static Function ModelDef()
	Local oStruSVC := FWFormStruct( 1, 'SVC' )
	Local oModel
	Local oEventPad := PCPA119EVDEF():New()
	Local oEventApi := PCPA119API():New()

	oStruSVC:SetProperty( 'VC_VERSAO' , MODEL_FIELD_NOUPD,.T.)

	oModel := MPFormModel():New('PCPA119',, )
	oModel:AddFields( 'SVCMASTER', /*cOwner*/, oStruSVC)
	oModel:SetDescription( STR0004 ) //Versão da Produção
	oModel:GetModel( 'SVCMASTER' ):SetDescription( STR0004 ) //Versão da produção
	oModel:SetPrimaryKey({'VC_VERSAO','VC_PRODUTO'})

	//Comando para localização
	oModel:InstallEvent("PCPA119EVDEF", /*cOwner*/, oEventPad)
	oModel:InstallEvent("PCPA119API"  , /*cOwner*/, oEventApi)

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel( 'PCPA119' )
	Local oStruSVC := FWFormStruct( 2, 'SVC')
	Local oView

	//DMANNEWPCP-5549 - esconder campo de armazém até que a funcionalidade seja desenvolvida
	oStruSVC:RemoveField("VC_LOCCONS")
	oStruSVC:RemoveField("VC_LOCCDES")

	oView :=FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_SVC', oStruSVC, 'SVCMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SVC', 'TELA' )

Return oView

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCPA119' OPERATION OP_VISUALIZAR ACCESS 0 //VISUALIZAR
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCPA119' OPERATION OP_INCLUIR    ACCESS 0 //Incluir
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.PCPA119' OPERATION OP_ALTERAR    ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.PCPA119' OPERATION OP_EXCLUIR    ACCESS 0 //Excluir

Return aRotina

//--------------------------------------------------------------------
/*/{Protheus.doc} A119VldVer()
Valida o codigo da Versão da Produção para o produto já existe
Valida se o produto fo informado
@author Fabio Cortes
@since 16/04/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A119VldVer()
	Local oModel    := FWModelActive()
	Local oModelSVC := oModel:GetModel("SVCMASTER")
	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	Local cVerSVC   := oModelSVC:GetValue("VC_VERSAO")
	Local cProdSVC  := oModelSVC:GetValue("VC_PRODUTO")

	IF Empty(cProdSVC)
		Help(" ",1,"A119PRODINF") //Produto não informado.
		lRet := .F.
	Else
		IF !Empty(cProdSVC)
			dbSelectArea("SB1")
			dbSetOrder(1)
			If !MsSeek( xFilial("SB1")+cProdSVC)
				Help(" ",1,"A119PRODEXISTE") //Produto não cadastrado.
				lRet := .F.
			Else
				dbSelectArea("SG1")
				dbSetOrder(1)
				If !MsSeek( xFilial("SG1")+cProdSVC)
					Help(" ",1,"A119ESTREXISTE") //Não existe estrutura para o produto.
					lRet := .F.
				Else
					dbSelectArea("SG2")
					dbSetOrder(1)
					If !MsSeek( xFilial("SG2")+cProdSVC)
						Help(" ",1,"A119ROTEXISTE") //Não existe roteiro para o produto.
						lRet := .F.
					Else
						If !Empty(cVerSVC) .AND. !Empty(cProdSVC)
							dbSelectArea("SVC")
							dbSetOrder(1)
							If MsSeek( xFilial("SVC")+cVerSVC+cProdSVC)
								Help(" ",1,"A119JAEXISTE") //Versão da produção já existe para o produto informado.
								lRet := .F.
							EndIf
						EndIf
					EndIf
				Endif
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A119VldRev()
Valida se existe a revisão para o produto
@author Fabio Cortes
@since 16/04/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A119VldRev()
	Local lRet		:= .T.
	Local oModel    := FWModelActive()
	Local oModelSVC := oModel:GetModel("SVCMASTER")
	Local cRevSVC   := oModelSVC:GetValue("VC_REV")
	Local cProdSVC  := oModelSVC:GetValue("VC_PRODUTO")

	IF !Empty(cRevSVC) .AND. !Empty(cProdSVC)
		IF !PCPVldRev(cProdSVC,cRevSVC)
			Help(" ",1,"A119REVEXISTE") //Revisão não existe para o produto informado.
			lRet := .F.
		EndIf
	EndIf
	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A119VldRot()
Valida se existe o roteiro do produto
@author Fabio Cortes
@since 17/04/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A119VldRot()

	Local lRet		:= .T.
	Local oModel    := FWModelActive()
	Local oModelSVC := oModel:GetModel("SVCMASTER")
	Local cRotSVC   := oModelSVC:GetValue("VC_ROTEIRO")
	Local cProdSVC  := oModelSVC:GetValue("VC_PRODUTO")

	If !Empty(cRotSVC)
  		dbSelectArea("SG2")
		dbSetOrder(1)
		If !MsSeek( xFilial("SG2")+cProdSVC+cRotSVC)
	    	Help(" ",1,"A119ROTPROD") //Roteiro não cadastrado para o produto
    		lRet := .F.
		EndIf
	EndIf	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A119VldQtd()
Valida se a faixa de quantidade já existe para o produto
@author Fabio Cortes
@since 17/04/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A119VldQtd(lCommit)
	Local lRet		:= .T. 
	Local oModel    := FWModelActive()
	Local oModelSVC := oModel:GetModel("SVCMASTER")
	Local cProdSVC  := oModelSVC:GetValue("VC_PRODUTO")
	Local dQtdeSVC  := oModelSVC:GetValue("VC_QTDDE")
	Local dQtatSVC  := oModelSVC:GetValue("VC_QTDATE")
	Local dtIniSVC  := oModelSVC:GetValue("VC_DTINI")
	Local dtFimSVC  := oModelSVC:GetValue("VC_DTFIM")
	Local cVerSVC   := oModelSVC:GetValue('VC_VERSAO')

	Local cQuery    := ""
	Local aBkpArea  := GetArea()
	Local cAliasQry := GetNextAlias()

	If  A119VldQt2(lCommit)
		cQuery := " SELECT VC_VERSAO "
		cQuery += " FROM " + RetSqlName("SVC") + " SVC "
		cQuery += " WHERE SVC.VC_FILIAL  = '" + xFilial("SVC") + "' "
		cQuery += " AND SVC.VC_PRODUTO     = '" + cProdSVC + "'"

		If ReadVar() == 'M->VC_QTDDE' 
			If !Empty(dQtatSVC)
				cQuery += " AND ((" + Str(dQtatSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE ) OR (" + Str(dQtdeSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE ))"
			Else
				cQuery += " AND (" + Str(dQtdeSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE )"
			EndIf
		EndIf

		If ReadVar() == 'M->VC_QTDATE' .OR. lCommit
			If !Empty(dQtdeSVC)
				cQuery += " AND ((" + Str(dQtatSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE ) OR (" + Str(dQtdeSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE ))"
			Else
				cQuery += " AND (" + Str(dQtatSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE )"
			Endif
		EndIf

		IF !Empty(dtIniSVC) .And. !Empty(dtFimSVC)
	         cQuery += " AND (('" + Dtos(dtIniSVC) + "' BETWEEN VC_DTINI AND VC_DTFIM ) OR ('" + Dtos(dtFimSVC) + "' BETWEEN VC_DTINI AND VC_DTFIM ))"
		Else
			IF !Empty(dtIniSVC)
				cQuery += " AND ('" + Dtos(dtIniSVC) + "' BETWEEN VC_DTINI AND VC_DTFIM )"
			EndIf
			IF !Empty(dtFimSVC)
				cQuery += " AND ('" + Dtos(dtFimSVC) + "' BETWEEN VC_DTINI AND VC_DTFIM )"
			EndIf
		EndIf

	    //Verifica se já não existe registro com as duas data em branco para mesma faixa de quantidade.
		If Empty(dtIniSVC) .And. Empty(dtFimSVC)
			cQuery += " AND ( VC_DTINI  = '' AND VC_DTFIM = '' ) "
		Endif
		
		//Na alteração não deve validar o proprio registro
		If oModelSVC:GetOperation() == MODEL_OPERATION_UPDATE
			cQuery += " AND SVC.VC_VERSAO     <> '" + cVerSVC + "'"
		EndIf
		
		cQuery += " AND D_E_L_E_T_ <> '*' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(Eof())
			lRet	 := .T.
		Else
			Help(" ",1,"A119FAIXAEXIST") //Faixa de quantidade/data já existe para esse produto.
			lRet	 := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
		RestArea(aBkpArea)
	Else
		Help(" ",1,"A119FAIXAEXIST") //Faixa de quantidade/data já existe para esse produto.
		lRet	 := .F.
	EndIf
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A119VldQtd2()
Valida se a faixa de quantidade já existe para o produto - Aqui valida se tem data nula
@author Fabio Cortes
@since 17/04/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A119VldQt2(lCommit)
	Local lRet		:= .T.
	Local oModel    := FWModelActive()
	Local oModelSVC := oModel:GetModel("SVCMASTER")
	Local cProdSVC  := oModelSVC:GetValue("VC_PRODUTO")
	Local dQtdeSVC  := oModelSVC:GetValue("VC_QTDDE")
	Local dQtatSVC  := oModelSVC:GetValue("VC_QTDATE")
	Local dtIniSVC  := oModelSVC:GetValue("VC_DTINI")
	Local dtFimSVC  := oModelSVC:GetValue("VC_DTFIM")
	Local cVerSVC   := oModelSVC:GetValue('VC_VERSAO')

	Local cQuery    := ""
	Local cQuery2   := ""
	Local aBkpArea  := GetArea()
	Local cAliasQry := GetNextAlias()

	If lCommit 
		lRet	 := .T.
	Else
		//Quando existir registro com as duas datas em branco
		//não poderá incluir nenhum outro registro com data para a mesma faixa de quantidade
		cQuery := " SELECT VC_VERSAO "
		cQuery += " FROM " + RetSqlName("SVC") + " SVC "Ö
		cQuery += " WHERE SVC.VC_FILIAL  = '" + xFilial("SVC") + "' "
		cQuery += " AND SVC.VC_PRODUTO     = '" + cProdSVC + "'"
	
		If ReadVar() == 'M->VC_QTDATE'
			cQuery += " AND (" + Str(dQtatSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE )"
		EndIf

		If ReadVar() == 'M->VC_QTDDE'
			cQuery += " AND (" + Str(dQtdeSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE )"
		EndIf

		cQuery2 := cQuery //backup da variavel

		cQuery += " AND ( VC_DTINI  = '' AND VC_DTFIM = '' ) "
	
		//Na alteração não deve validar o proprio registro
		If oModelSVC:GetOperation() == MODEL_OPERATION_UPDATE
			cQuery += " AND SVC.VC_VERSAO     <> '" + cVerSVC + "'"
		EndIf
	
		cQuery += " AND D_E_L_E_T_ <> '*' "
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(Eof())
			lRet	 := .T.
		Else
			lRet	 := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
		RestArea(aBkpArea)

		//Quando existir registro com apenas uma das datas informdas
		//não poderá incluir nenhum outro registro com as duas datas em branco
		//para a mesma faixa de quantidade
		If lRet .And. Empty(dtIniSVC) .And. Empty(dtFimSVC)
			cQuery := cQuery2
			cQuery += " AND ( VC_DTINI  <> '' OR VC_DTFIM <> '' ) "
			cQuery += " AND D_E_L_E_T_ <> '*' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			If (cAliasQry)->(Eof())
				lRet	 := .T.
			Else
				lRet	 := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
			RestArea(aBkpArea)
		EndIf

		//Se informar data inicial e final deverá validar
		//se existe registro no banco com data fim nula e data inicial menor ou igual a data ini informada
		//para a mesma faixa de quantidade
		If lRet .And. !Empty(dtIniSVC) .And. !Empty(dtFimSVC)
	   		cQuery := cQuery2
			cQuery += " AND ( VC_DTINI <= '" + Dtos(dtIniSVC) + "' AND VC_DTFIM = '')"
			cQuery += " AND D_E_L_E_T_ <> '*' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			If (cAliasQry)->(Eof())
				lRet	 := .T.
			Else
				lRet	 := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
			RestArea(aBkpArea)
		EndIf


		If lRet .And. !Empty(dtIniSVC) .And. Empty(dtFimSVC)

			cQuery := " SELECT VC_VERSAO "
			cQuery += " FROM " + RetSqlName("SVC") + " SVC "
			cQuery += " WHERE SVC.VC_FILIAL  = '" + xFilial("SVC") + "' "
			cQuery += " AND SVC.VC_PRODUTO     = '" + cProdSVC + "'"
			cQuery += " AND ((" + Str(dQtdeSVC) + " <= VC_QTDATE ) OR ( " + Str(dQtatSVC) + " <= VC_QTDATE ))"
			cQuery += " AND ( VC_DTINI = '' AND VC_DTFIM = '') "
			cQuery += " AND D_E_L_E_T_ <> '*' "

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			If (cAliasQry)->(Eof())
				lRet	 := .T.
			Else
				lRet	 := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
			RestArea(aBkpArea)
		EndIf

		If lRet .And. Empty(dtIniSVC) .And. Empty(dtFimSVC) .And. dQtdeSVC > 0 .And.  dQtatSVC > 0

			cQuery := " SELECT VC_VERSAO "
			cQuery += " FROM " + RetSqlName("SVC") + " SVC "
			cQuery += " WHERE SVC.VC_FILIAL  = '" + xFilial("SVC") + "' "
			cQuery += " AND SVC.VC_PRODUTO     = '" + cProdSVC + "'"
				
			//Na alteração não deve validar o proprio registro
			If oModelSVC:GetOperation() == MODEL_OPERATION_UPDATE
				cQuery += " AND SVC.VC_VERSAO     <> '" + cVerSVC + "'"
			EndIf
		
			cQuery += " AND D_E_L_E_T_ <> '*' "
		
			//Backup da query
			cQuery2 := cQuery
			cQuery += " AND ((" + Str(dQtdeSVC) + " <= VC_QTDATE ) OR ( " + Str(dQtatSVC) + " <= VC_QTDATE ))"
			cQuery += " AND ( VC_DTINI <> '' AND VC_DTFIM = '') "
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			If (cAliasQry)->(Eof())
				lRet	 := .T.
			Else
				lRet	 := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
			RestArea(aBkpArea)
		EndIf
	EndIf	

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A119VldDat()
Valida se a faixa de datas já existe para o produto
@author Fabio Cortes
@since 17/04/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A119VldDat()
	Local lRet		:= .T.
	Local oModel    := FWModelActive()
	Local oModelSVC := oModel:GetModel("SVCMASTER")
	Local cProdSVC  := oModelSVC:GetValue("VC_PRODUTO")
	Local dQtdeSVC  := oModelSVC:GetValue("VC_QTDDE")
	Local dQtatSVC  := oModelSVC:GetValue("VC_QTDATE")
	Local dtIniSVC  := oModelSVC:GetValue("VC_DTINI")
	Local dtFimSVC  := oModelSVC:GetValue("VC_DTFIM")

	Local cQuery    := ""
	Local aBkpArea  := GetArea()
	Local cAliasQry := GetNextAlias()

	cQuery := " SELECT VC_VERSAO "
	cQuery += " FROM " + RetSqlName("SVC") + " SVC "
	cQuery += " WHERE SVC.VC_FILIAL  = '" + xFilial("SVC") + "' "
	cQuery += " AND SVC.VC_PRODUTO     = '" + cProdSVC + "'"


	If !Empty(dtIniSVC) .And. !Empty(dtFimSVC) .And. !Empty(dQtdeSVC) .And. !Empty(dQtatSVC)
		cQuery += " AND ('" + Dtos(dtIniSVC) + "' BETWEEN VC_DTINI AND VC_DTFIM )"
		cQuery += " AND ('" + Dtos(dtFimSVC) + "' BETWEEN VC_DTINI AND VC_DTFIM )"
		cQuery += " AND (" + Str(dQtdeSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE )"
		cQuery += " AND (" + Str(dQtatSVC) + " BETWEEN VC_QTDDE AND VC_QTDATE )"
		cQuery += " AND D_E_L_E_T_ <> '*' "
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE
			cQuery += " AND SVC.VC_VERSAO     <> '" + oModelSVC:GetValue("VC_VERSAO") + "'"
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(Eof())
			lRet	 := .T.
		Else
			Help(" ",1,"A119FAIXAEXIST") //Faixa de quantidade/data já existe para esse produto.
			lRet	 := .F.
		EndIf

		(cAliasQry)->(dbCloseArea())
		RestArea(aBkpArea)
	EndIf
	
	If lRet .And. ReadVar() == 'M->VC_DTINI' .And. Empty(dtFimSVC) .And. !Empty(dtIniSVC)
		oModelSVC:LoadValue("VC_DTFIM",StoD("20491231"))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA119SG2()
Função de consulta padrão SG2

@author  Fabio Cortes
@version P12
@since   20/04/2018
/*/
//-------------------------------------------------------------------
Function PCPA119SG2()
   Local oDlg, oLbx
   Local aCpos  := {}
   Local aRet   := {}
   Local cQuery := ""
   Local cAlias := GetNextAlias()
   Local lRet   := .F.

   cQuery := " SELECT DISTINCT SG2.G2_CODIGO, SG2.G2_PRODUTO "
   cQuery +=   " FROM " + RetSqlName("SG2") + " SG2 "
   cQuery +=  " WHERE SG2.D_E_L_E_T_ = ' ' "
   cQuery +=    " AND SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
   If !Empty(M->VC_PRODUTO)
      cQuery += " AND SG2.G2_PRODUTO = '" + M->VC_PRODUTO + "' "
   EndIf
   cQuery += " ORDER BY 2, 1 "

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

   While (cAlias)->(!Eof())
      aAdd(aCpos,{(cAlias)->(G2_CODIGO), (cAlias)->(G2_PRODUTO)})
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   If Len(aCpos) < 1
      aAdd(aCpos,{" "," "})
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0001 /*"Roteiro de operações"*/ FROM 0,0 TO 240,500 PIXEL

     @ 10,10 LISTBOX oLbx FIELDS HEADER STR0002 /*"Roteiro"*/, STR0003 /*"Produto"*/  SIZE 230,95 OF oDlg PIXEL

     oLbx:SetArray( aCpos )
     oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
     oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

  DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
  ACTIVATE MSDIALOG oDlg CENTER

  If Len(aRet) > 0 .And. lRet
	 If Empty(aRet[1])
        lRet := .F.
     Else
		SG2->(dbSetOrder(1))
		SG2->(DbSeek( xFilial("SG2")+aRet[2]+aRet[1]))   
     EndIf
  EndIf
Return lRet
