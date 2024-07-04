#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA153A.ch'

Static lTmsIsRest := .F.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153A
Cadastro de Demanda
@type function
@author Wander Horongoso.
@version 12.1.17
@since 09/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA153A()
	//Funcionalidades de Demanda
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu 
@type function
@author Wander Horongoso.
@version 12.1.17
@since 09/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function Menudef()
Local aRotina := {}

	aAdd(aRotina, {STR0001, 'VIEWDEF.TMSA153A', 0, 3, 0, NIL}) //Incluir
	aAdd(aRotina, {STR0002, 'VIEWDEF.TMSA153A', 0, 4, 0, NIL}) //Alterar
	aAdd(aRotina, {STR0003, 'VIEWDEF.TMSA153A', 0, 2, 0, NIL}) //Visualizar
	aAdd(aRotina, {STR0004, 'VIEWDEF.TMSA153A', 0, 5, 0, NIL}) //Excluir
	aAdd(aRotina, {STR0026, 'TMA154Par(3, DL8->DL8_CRTDMD, DL8->DL8_COD, DL8->DL8_SEQ, DL8->DL8_PLNDMD, DL8->DL8_CLIDEV, DL8->DL8_LOJDEV, 2)', 0, 2, 0, NIL}) //Tracking
	
Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados 
@type function
@author Wander Horongoso.
@version 12.1.17
@since 09/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruDL8 := FWFormStruct(1, "DL8")
Local oStrDLA := FWFormStruct(1, "DLA")
Local oStrDLL := FWFormStruct(1, "DLL")
Local oModel

Local bPost   := {|oModel| T153AbPost(oModel)}
Local bCommit := {|oModel| TM153ACmt(oModel)}
Local bCancel := {|oModel| T153ACanc(oModel)}

Local bPreOri	 := { | oDlOri, nLine, cOpera| T153APreOr( oDlOri, nLine, cOpera) }
Local bPosOri    := { | oDlOri, nLine, cOpera| T153PosOri( oDlOri, nLine, cOpera) }
Local bLnPosOri	 := { | oDlOri | T153ALNPOS( oDlOri, '1') }
Local bPreDes	 := { | oDlDes,nLine,cOpera | T153APREDs( oDlDes, nLine, cOpera) }
Local bLnPosDes	 := { | oDlDes | T153ALNPOS( oDlDes, '2') }

	If FindFunction("TMSIsRest") 
		lTmsIsRest := TMSIsRest() .OR. IsBlind()
	EndIf
	
	oModel := MPFormModel():New('TMSA153A', , bPost, bCommit, bCancel )
	oModel:SetDescription(STR0005) //Demandas
	
	oStruDL8:AddTrigger("DL8_UM", "DL8_UM", {||.T.}, {|oModel|T153DL8UM(oModel)})
	oStruDL8:AddTrigger("DL8_CRTDMD", "DL8_CRTDMD", {||.T.}, {|oModel|T153GTCRT(oModel)})
	oStruDL8:AddTrigger("DL8_CODGRD", "DL8_CODGRD", {||.T.}, {|oModel|T153GTGRD(oModel)})
	oStruDL8:AddTrigger("DL8_DATPRV", "DL8_DATPRV", {||.T.}, {|oModel|T153ATSLD(oModel, .F.)}) //Atualiza o Saldo de acordo com a Data de previs�o da Demanda
	oStruDL8:AddTrigger("DL8_QTD", "DL8_QTD", {||.T.}, {|oModel|T153ATSLD(oModel, .F.)}) //Atualiza o Saldo de acordo com a Data de previs�o da Demanda
	
	oStruDL8:SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||.F.})
	oStruDL8:SetProperty("DL8_CODGRD", MODEL_FIELD_WHEN,{||.F.})
	
	oStrDLA:SetProperty("DLA_PREVIS", MODEL_FIELD_INIT,{||'2'})
	oStrDLL:SetProperty("DLL_PREVIS", MODEL_FIELD_INIT,{||'2'})
	
	oModel:AddFields('MASTER_DL8',nil,oStruDL8)
	oModel:SetPrimaryKey({"DL8_FILIAL","DL8_COD","DL8_SEQ"})
	
 	oStrDLA:AddTrigger("DLA_CODREG", "DLA_CODREG", {||.T.}, {|oModel|T153GTREG(oModel, 1)})
	oStrDLL:AddTrigger("DLL_CODREG", "DLL_CODREG", {||.T.}, {|oModel|T153GTREG(oModel, 2)})
	 
	oModel:AddGrid('GRID_ORI','MASTER_DL8',oStrDLA, /*bLinePre*/, bLnPosOri, bPreOri, bPosOri )
	
	oModel:AddGrid('GRID_DES','MASTER_DL8',oStrDLL, /*bLinePre*/, bLnPosDes, bPreDes, /*bPosVal*/ )
	
	oModel:SetVldActivate ( { |oModel, nLine, cAction| TMSA153AVL(oModel,nLine, cAction) } )
	oModel:SetDeActivate ( {|oModel| T153ADeAct(oModel)})
	
	oModel:GetModel('GRID_ORI'):SetOptional(.T.)
	oModel:GetModel('GRID_DES'):SetOptional(.T.)
	
	// Faz relacionamento entre os compomentes do model
	oModel:SetRelation( 'GRID_ORI', { {'DLA_FILIAL', 'xFilial( "DLA" )'}, {'DLA_CODDMD', 'DL8_COD'}, {'DLA_SEQDMD', 'DL8_SEQ'}}, DLA->( IndexKey( 1 ) ) )
	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'GRID_ORI' ):SetUniqueLine( {"DLA_CODREG"} )	
	
	// Faz relacionamento entre os compomentes do model
	oModel:SetRelation( 'GRID_DES', { {'DLL_FILIAL', 'xFilial( "DLL" )'}, {'DLL_CODDMD', 'DL8_COD'}, {'DLL_SEQDMD', 'DL8_SEQ'}}, DLL->( IndexKey( 1 ) ) )
	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'GRID_DES' ):SetUniqueLine( {"DLL_CODREG"} )

Return oModel

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estrutura de dados 
@type function
@author Wander Horongoso.
@version 12.1.17
@since 09/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('TMSA153A')
Local oStruDL8 := FWFormStruct(2,'DL8')
Local oStrDLA := FWFormStruct(2,'DLA')
Local oStrDLL := FWFormStruct(2,'DLL')

Local cFunction	:= "TMSA153A"

	//--For�a LOG DE ACESSO Ref. a Prote��o de Dados	
	IIf(ExistFunc('FwPdLogUser'),FwPDLogUser(cFunction),)

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oModel )
	
	//Remove os campos para nao serem apresentado ao inclui/editar/visualizar
	oStruDL8:RemoveField("DL8_MARK")
	oStruDL8:RemoveField("DL8_FILGER")
	oStruDL8:RemoveField("DL8_CODOBS")
	oStruDL8:RemoveField("DL8_ORIDMD")
	oStruDL8:RemoveField("DL8_PLNDMD")	
	oStruDL8:RemoveField("DL8_SEQMET")
			
	oView:AddField( 'VIEW_DL8', oStruDL8, 'MASTER_DL8' )
	
	oStrDLA:SetProperty( 'DLA_SEQREG', MVC_VIEW_CANCHANGE, .F. )
	oStrDLL:SetProperty( 'DLL_SEQREG', MVC_VIEW_CANCHANGE, .F. )
	
	//remove o campo da grid desejada
	oStrDLA:RemoveField( 'DLA_CODDMD' )
	oStrDLA:RemoveField( 'DLA_SEQDMD' )
	
	oStrDLL:RemoveField( 'DLL_CODDMD' )
	oStrDLL:RemoveField( 'DLL_SEQDMD' )
		
	oView:CreateHorizontalBox('BOX_FORM',55)
	oView:CreateHorizontalBox('BOX_DOWN',45)
	oView:CreateVerticalBox('BOX_ESQ', 50 ,'BOX_DOWN')
	oView:CreateVerticalBox('BOX_DIR', 50 ,'BOX_DOWN')
	
	oView:AddGrid('GRID_ORI', oStrDLA, 'GRID_ORI')
	oView:AddGrid('GRID_DES', oStrDLL, 'GRID_DES')
	
	oView:AddIncrementField( 'GRID_ORI', 'DLA_SEQREG' )
	oView:AddIncrementField( 'GRID_DES', 'DLL_SEQREG' )
	
	oView:EnableTitleView('GRID_ORI', STR0006) //Regi�o Origem 
	oView:EnableTitleView('GRID_DES', STR0007) //Regi�o Destino
	
	oView:AddUserButton(STR0068,'',{|| T153ConsDoc() }) //Consultar Documentos

	oView:SetViewCanActivate( { |oView,cIdView,nNumLine| T153DmdPln( oView,'MASTER_DL8',nNumLine ) } )
	
	oView:SetOwnerView( 'VIEW_DL8', 'BOX_FORM')
	oView:SetOwnerView( 'GRID_ORI', 'BOX_ESQ')
	oView:SetOwnerView( 'GRID_DES', 'BOX_DIR')
	
Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} T153ADeAct
Desativa��o do modelo 
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 04/07/2018
/*/
//-----------------------------------------------------------------
Function T153ADeAct(oModel)
	Local cCodDMD
	Local cSeqDMD 
	Local nIndex	:= DL8->(IndexOrd())

	If IsInCallStack('TMSA153') //quando chamado por fora do painel de gest�o de demandas os browses n�o existem
		If type('nRfDMD') == 'N' .And. (nRfDMD == 1) 
			Pergunte('TMSA153', .F.)
			If !lTmsIsRest
			 	If !oModel:GetOperation() == MODEL_OPERATION_DELETE
			 		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			 			cCodDMD := DL8->DL8_COD
						cSeqDMD := DL8->DL8_SEQ
						oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
						
						DL8->(DbSetOrder(1))
						DL8->(DbSeek(xFilial('DL8')+cCodDMD+cSeqDMD))
			 		Else
			 			oBrwDeman:GoTo(nPosDL8)
						cCodDMD := DL8->DL8_COD
						cSeqDMD := DL8->DL8_SEQ
						oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))

						DL8->(DbSetOrder(1))
						If !DL8->(DbSeek(xFilial('DL8')+cCodDMD+cSeqDMD))
							oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
							oBrwDeman:GoTop()
						Else
							oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
							oBrwDeman:GoTo(nPosDL8)
						EndIf
					EndIf
					DL8->(DbSetOrder(nIndex))
				EndIf 
			
				oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
				oBrwPlan:GoTo(nPosDL9)
			EndIf
		EndIf
	
		If lTmsIsRest
			TMUnLockDmd('TMSA153A_' + DL8->DL8_FILIAL + DL8->DL8_COD + DL8->DL8_SEQ, .T.)
		EndIf
	
		SetKey(VK_F5,{ ||TMA153Par(.F.)} )
		SetKey(VK_F12,{�||Pergunte('TMSA1531',�.T.), Pergunte('TMSA153',�.F.)}�)
	ElseIf IsInCallStack('TMSA158') //quando chamado por fora do painel de gest�o de demandas os browses n�o existem
		SetKey(VK_F5,{ ||TMA158Par(2)} )		
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} T153DmdPln
Valida se demanda est� planejada, para o caso de uma demanda j� ter 
sido planejada por outro operador, mas ainda estar dispon�vel em tela
@author  Gustavo Krug
@since   12/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153DmdPln(oView, cIdView, nNumLine)
Local lRet := .T.
Local cQuery := ''
Local cAliasQry := GetNextAlias()

	If IsInCallStack('TMSA153') //quando chamado por fora do painel de gest�o de demandas os browses n�o existem
		cQuery := " SELECT DL8_COD, DL8_PLNDMD "
		cQuery += " FROM " + RetSqlName('DL8') + " DL8 "
		cQuery += " WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
		cQuery += " AND DL8.DL8_COD = '" + DL8->DL8_COD + "'"
		cQuery += " AND DL8.DL8_SEQ = '" + DL8->DL8_SEQ + "'"
		cQuery += " AND DL8.DL8_PLNDMD <> '' "
		cQuery += " AND DL8.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )
	
		While (cAliasQry)->(!EoF())
			FwClearHLP()
			Help( ,, 'Help',, STR0021, 1, 0 ) //Demanda est� em planejamento.
			lRet := .F.
			DBSkip()
		EndDo
		nRfDMD := 1 //Refresh Demanda
		
		(cAliasQry)->(dbCloseArea())
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153PosOri
P�s-valida��o do modelo regi�es de origem
@author  Gustavo Krug
@since   01/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153PosOri(oModelGrid, nLine, cOpera)
Local oModelDL8 := oModelGrid:GetModel('MASTER_DL8')
Local nLintemp := oModelGrid:GetLine()
Local nQtdTot := 0
Local lRet := .T.
Local nX := 0

	//Caso a gera�ao de demandas esteja sendo feita por API, 
	//a soma da quantidade n�o � feita na fun��o T153APreOr e � feita aqui
	If M->DL8_UM <> "2" .AND. !EMPTY(M->DL8_UM) .AND. lTmsIsRest
		For nX := 1 to oModelGrid:GetQtdLine()
			oModelGrid:GoLine(nX)  // Vai pra primeira linha para varrer o grid de regiao.
			If !oModelGrid:IsDeleted(nX)
				nQtdTot += oModelGrid:GetValue("DLA_QTD")
			EndIf

			oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.T.})
			oModelDL8:SetValue("MASTER_DL8","DL8_QTD",nQtdTot)
			oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.F.})
		Next nx
		oModelGrid:GoLine(nLintemp)  //Retorna para a linha que estava possionado
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153AbPost()
Realiza a valida��o tudo OK ap�s clicar em confirmar.
@author  Gustavo Krug	
@since   02/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153AbPost(oModel)
Local oModelDL8 := oModel:GetModel('MASTER_DL8')
Local oModelOri := oModel:GetModel('GRID_ORI')
Local oModelDes := oModel:GetModel('GRID_DES')
Local nOperation:= oModel:GetOperation()
Local lRet := .T.
Local lRegiao := .F.
Local nX   := 0
Local aCrtDmd := {}
Local aReg := {}
Local cCliDev	:= oModelDL8:GetValue('DL8_CLIDEV')
Local cLojDev	:= oModelDL8:GetValue('DL8_LOJDEV')
Local cUM		:= oModelDL8:GetValue('DL8_UM')
Local cSeq := TGetSeqDLG(oModelDL8:GetValue("DL8_CRTDMD"), oModelDL8:GetValue("DL8_CODGRD"), oModelDL8:GetValue("DL8_TIPVEI"), oModelDL8:GetValue("DL8_DATPRV"))
Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.)
Local lFrac := IsInCallStack("TMSA153I")


	If Empty(oModelDL8:GetValue("DL8_CRTDMD")) .AND. nOperation == MODEL_OPERATION_INSERT
		For nX := 1 to oModelOri:GetQtdLine()
			oModelOri:GoLine(nX)
			If .NOT. Empty(oModelOri:GetValue('DLA_CODREG')) .AND. .NOT. oModelOri:IsDeleted(nX) 
				AAdd(aReg,{oModelOri:GetValue('DLA_CODREG'), '1' })
			EndIf
		Next nX

		For nX := 1 to oModelDes:GetQtdLine()
			oModelDes:GoLine(nX)
			If .NOT. Empty(oModelDes:GetValue('DLL_CODREG')) .AND. .NOT. oModelDes:IsDeleted(nX)  
				AAdd(aReg,{oModelDes:GetValue('DLL_CODREG'), '2' })
			EndIf
		Next nX 
		
	EndIf

	For nX := 1 to oModelOri:GetQtdLine()
		oModelOri:GoLine(nX)
		If !oModelOri:IsDeleted(nX) .AND. !Empty(oModelOri:GetValue("DLA_CODREG"))
			lRegiao := .T.//Encontrada uma linha n�o deletada com a regiao de origem informada	
			Exit		
		EndIf
	Next nX
	If !lRegiao 
		Help( ,, 'HELP',, STR0037, 1, 0,,,,,, {STR0067}) //Demanda n�o possui regi�o de origem cadastrada. Favor realizar o cadastro no grid Regi�o Origem
		lRet := .F.
	EndIf

	If lRet .AND. lMVITMSDMD 
		lRet := VldColDMD(1, oModelOri, oModelDL8:GetValue('DL8_FILEXE'))
	EndIf

	For nX := 1 to oModelOri:GetQTDLine()
		If nOperation <> MODEL_OPERATION_DELETE .AND. lRet
			If Empty(oModelOri:GetValue("DLA_CODCLI", nX))
				Help( ,, 'HELP',, STR0060 + oModelOri:GetValue("DLA_CODREG", nX) + " - " + oModelOri:GetValue("DLA_NOMREG", nX) + ".", 1, 0,,,,,, {STR0061} ) //C�digo do Cliente n�o foi informado. //Insira o c�digo do cliente na Regi�o de Origem.
				lRet := .F.
			ElseIf Empty(oModelOri:GetValue("DLA_LOJA", nX))
				Help( ,, 'HELP',, STR0062 + oModelOri:GetValue("DLA_CODREG", nX) + " - " + oModelOri:GetValue("DLA_NOMREG", nX) + ".", 1, 0,,,,,, {STR0063} ) //C�digo da Loja n�o foi informado. //Insira o c�digo da Loja na Regi�o de Origem.
				lRet := .F.
			EndIf
		EndIf
	Next nX

	//Sugest�o de contrato
	// Obs.: A sugest�o de contrato deve ser a �ltima a��o antes de finalizar o bPost e ir para o bCommit 
		If lRet
			aCrtDmd := TGetCrtDmd(cCliDev, cLojDev, cUM, aReg)
			If Empty(oModelDL8:GetValue("DL8_CRTDMD")) .AND. nOperation == MODEL_OPERATION_INSERT .AND. !lFrac
				If Len(aCrtDmd) == 1 
					If lTmsIsRest .OR. MsgYesNo(STR0041 + aCrtDmd[1][1] + STR0042 + AllTrim(aCrtDmd[1][2]) + STR0043 , STR0044) /*'Deseja utilizar o contrato '*/ /*' e grupo de regi�o '*/ /*' para gerar essa demanda?'*/ /*'Contrato encontrado'*/
						T153UsaCrt(aCrtDmd[1][1], aCrtDmd[1][2])
						cSeq := TGetSeqDLG(oModelDL8:GetValue("DL8_CRTDMD"), oModelDL8:GetValue("DL8_CODGRD"), oModelDL8:GetValue("DL8_TIPVEI"), oModelDL8:GetValue("DL8_DATPRV"))
					EndIf
				ElseIf Len(aCrtDmd) > 1 
					If !lTmsIsRest .AND. MsgYesNo(STR0045 , STR0044 ) /*'Existem contratos compat�veis com essa demanda. Deseja escolher algum deles?' */ /*'Contrato encontrado'*/
						T153CrtDmd(aCrtDmd)
						cSeq := TGetSeqDLG(oModelDL8:GetValue("DL8_CRTDMD"), oModelDL8:GetValue("DL8_CODGRD"), oModelDL8:GetValue("DL8_TIPVEI"), oModelDL8:GetValue("DL8_DATPRV"))
					EndIf
				EndIf
			EndIf
			//Caso encontre Contrato, Grupo de Regi�es e a data da previs�o esteja preenchida, buscar a sequ�ncia da meta
			If nOperation <> MODEL_OPERATION_DELETE .And. !Empty(cSeq) .And. (Empty(oModelDL8:GetValue("DL8_SEQMET")) .OR. oModelDL8:GetValue("DL8_SEQMET") <> cSeq) 
				oModelDL8:SetValue("DL8_SEQMET",cSeq)
			EndIf
		EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153ACmt
Usado para grava��o dos registros no banco de dados
@type function
@author Wander Horongoso.
@version 12.1.17
@since 10/04/2018
/*/
//-------------------------------------------------------------------------------------------------
function TM153ACmt(oModel) 
Local lRet 		:= .T.
Local oModelDL8 := oModel:GetModel('MASTER_DL8')
Local oView		:= FWViewActive()
Local nOperation:= oModel:GetOperation()
Local cQuery 	:= ''
Local cMsgErro	:= ''
Local cMsgSol 	:= ''
Local cSeq		:= ''
Local cTemp		:= GetNextAlias()
Local lMarkBrw	:= .T.

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
		
		If lRet .AND. !Empty(oModelDL8:GetValue("DL8_CRTDMD")) 
			If Empty(oModelDL8:GetValue("DL8_CODGRD"))
			 	lRet := .F.
			 	cMsgErro := STR0038 //Obrigat�rio o preenchimento do campo Grupo de Regi�o.
			EndIf

			If lRet .AND. Empty(oModelDL8:GetValue("DL8_TIPVEI")) .AND. !Empty(oModelDL8:GetValue("DL8_CODGRD"))
		 		cQuery := " SELECT COUNT(DLF_CRTDMD) nCount "
				cQuery += " FROM " + RetSqlName('DLF') + " DLF "
				cQuery += " WHERE DLF.DLF_FILIAL = '" + xFilial('DLF') + "'"
				cQuery += " AND DLF.DLF_CRTDMD = '"+ oModelDL8:GetValue("DL8_CRTDMD") +"'"
				cQuery += " AND DLF.DLF_CODGRD = '"+ oModelDL8:GetValue("DL8_CODGRD") +"'"
				cQuery += " AND DLF.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )

				If (cTemp)->(nCount) > 0
					lRet := .F.
					cMsgErro := STR0039 //Obrigat�rio o preenchimento do campo Tipo de Ve�culo.
				EndIf
				(cTemp)->(dbCloseArea())
			EndIf

			//Valida se consumiu saldo da meta
			If !Empty(oModelDL8:GetValue('DL8_CODGRD'))
				//Valida se possui sequ�ncia da meta
				If lRet .And. !Empty(oModelDL8:GetValue('DL8_DATPRV')) 
					If Empty(oModelDL8:GetValue('DL8_SEQMET'))
						lRet := .F.
						cMsgErro := STR0046 // "N�o foi encontrado sequ�ncia de meta para esta demanda. "
						cMsgSol  := STR0047 //Verifique se existe meta cadastrada pra este contrato e grupo de regi�o ou se a data de previs�o de atendimento informada nesta demanda est� dentro do per�odo informado na meta do contrato com o grupo de regi�o.
						FwClearHLP()
						oModel:SetErrorMessage (,,,,,cMsgErro,cMsgSol)
						DisarmTransaction()
						Break
					Else
						If nOperation == MODEL_OPERATION_UPDATE	
							cSeq := TGetSeqDLG(oModelDL8:GetValue("DL8_CRTDMD"), oModelDL8:GetValue("DL8_CODGRD"), oModelDL8:GetValue("DL8_TIPVEI"), oModelDL8:GetValue("DL8_DATPRV"))
							If !(oModelDL8:GetValue('DL8_SEQMET') == cSeq)
								lRet := .F.
								cMsgErro := STR0046 //"N�o foi encontrado sequ�ncia de meta para esta demanda. "
								cMsgSol  := STR0054 //Verifique se a data de previs�o de atendimento informada nesta demanda est� dentro do per�odo informado na meta do contrato com o grupo de regi�o.        
								FwClearHLP()
								If Empty(cSeq)
									T153ATSLD(oModel, .T.) //Atualiza Saldo do Contrato na tela de Demanda
								EndIf
								oModel:SetErrorMessage (,,,,,cMsgErro,cMsgSol)
								DisarmTransaction()
								Break
							EndIf
						EndIf
					EndIf
				ElseIf Empty(oModelDL8:GetValue('DL8_DATPRV')) //Se a data de previs�o foi anulada, deve ser anulada tamb�m a sequencia da Meta.
					oModelDL8:SetValue("DL8_SEQMET",'')
				EndIf
			EndIf	
		EndIf
	EndIf
	If lRet
		//Alimenta o campo Origem da Demanda (DL8_ORIDMD) 
		If IsInCallStack('TMSA153') .And. nOperation <> MODEL_OPERATION_DELETE			
			oModel:LoadValue('MASTER_DL8','DL8_ORIDMD', "1") 
		EndIf
		
		If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
			T153AtuDt(oModel)
		EndIf

		If nOperation == MODEL_OPERATION_INSERT
			If __lSX8
				ConfirmSX8()
			EndIf
		EndIf 
		
		If nOperation == MODEL_OPERATION_DELETE 
			TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ, ,'X', , ) //Tracking da Exclus�o de Demanda
		EndIf

		If nOperation == MODEL_OPERATION_UPDATE

			If !Empty(DL8->DL8_SEQMET)

				aRet := TMUpQtMDmd(xFilial("DL7"), DL8->DL8_CRTDMD, DL8->DL8_CODGRD, DL8->DL8_TIPVEI, DL8->DL8_SEQMET, DL8->DL8_QTD, 2) //Exclus�o de Demanda
				If lRet .AND. !aRet[1]
					lRet := aRet[1]
					cMsgErro := aRet[2]
				EndIf
				
				aRet := {}
				aRet := TMUpQtMDmd(xFilial("DL7"), oModelDL8:GetValue('DL8_CRTDMD'), oModelDL8:GetValue('DL8_CODGRD'), oModelDL8:GetValue('DL8_TIPVEI'), oModelDL8:GetValue('DL8_SEQMET'), oModelDL8:GetValue('DL8_QTD') , 1)//Inclus�o de Demanda*
				If lRet .AND. !aRet[1]
					lRet := aRet[1]
					cMsgErro := aRet[2]
				EndIf
			Else			
				
				aRet := TMUpQtMDmd(xFilial("DL7"), oModelDL8:GetValue('DL8_CRTDMD'), oModelDL8:GetValue('DL8_CODGRD'), oModelDL8:GetValue('DL8_TIPVEI'), oModelDL8:GetValue('DL8_SEQMET'), oModelDL8:GetValue('DL8_QTD') , 1) //Inclus�o de Demanda
			
				If lRet .AND. !aRet[1]
					lRet := aRet[1]
					cMsgErro := STR0048 //"N�o foi poss�vel consumir saldo da meta."
				EndIf
				
			EndIf
		EndIf
		//Retira o lock incluso no activate do model
		//--N�o executar para teste automatizado 	
    	If !lTmsIsRest
			lMarkBrw := DL8->DL8_MARK <> oBrwDeman:Mark()
		EndIf
		If lRet .AND. (nOperation == MODEL_OPERATION_UPDATE .AND. lMarkBrw ) .Or. (nOperation == MODEL_OPERATION_DELETE)
			TMUnLockDmd('TMSA153A_' + DL8->DL8_FILIAL + DL8->DL8_COD + DL8->DL8_SEQ, .T.)
		EndIf
		lRet := FwFormCommit(oModel)
		If !lRet
			lRet := .F.
		 	cMsgErro:= STR0040 //Erro ao gravar os dados da demanda.
		EndIf

		If lRet .AND. nOperation == MODEL_OPERATION_INSERT 
			If __lSX8
				ConfirmSX8()
			EndIf
		
			If !Empty(M->DL8_OBS)
				MSMM(DL8->DL8_CODOBS,,,M->DL8_OBS,1,,,"DL8","DL8_CODOBS")
			EndIf

			//Valida se consumiu saldo da meta
			If !Empty(oModelDL8:GetValue('DL8_CRTDMD')) .AND. !Empty(oModelDL8:GetValue('DL8_CODGRD'))
				If !Empty(oModelDL8:GetValue('DL8_SEQMET'))
					If lRet
						aRet := TMUpQtMDmd(xFilial("DL7"), oModelDL8:GetValue('DL8_CRTDMD'), oModelDL8:GetValue('DL8_CODGRD'), oModelDL8:GetValue('DL8_TIPVEI'), oModelDL8:GetValue('DL8_SEQMET'), oModelDL8:GetValue('DL8_QTD') , 1) //Inclus�o de Demanda
					EndIf
					If lRet .AND. !aRet[1]
						lRet := aRet[1]
						cMsgErro := STR0048 //"N�o foi poss�vel consumir saldo da meta."
					EndIf
				EndIf
			EndIf
			If lRet
				TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ, ,'I', , ) //Tracking da Inclus�o de Demanda 
			EndIf
		EndIf 
		
		If lRet .AND. nOperation == MODEL_OPERATION_UPDATE
			MSMM(DL8->DL8_CODOBS,,,M->DL8_OBS,1,,,"DL8","DL8_CODOBS")
		EndIf

		If lRet .AND. nOperation == MODEL_OPERATION_DELETE //Excluir
			If !Empty(DL8->DL8_CODOBS)
				lRet := MSMM(DL8->DL8_CODOBS,,,M->DL8_OBS,2,,,"DL8","DL8_CODOBS")
				If !lRet
					lRet := .F.
					cMsgErro := STR0008 //Erro ao gravar a observa��o.
				EndIf
			EndIf
			aRet := TMUpQtMDmd(xFilial("DL7"), DL8->DL8_CRTDMD, DL8->DL8_CODGRD, DL8->DL8_TIPVEI, DL8->DL8_SEQMET, DL8->DL8_QTD , 2) //Exclus�o de Demanda
			If lRet .AND. aRet[1]				
				lRet := aRet[1]
				cMsgErro := aRet[2]
			EndIf
		EndIf
	EndIf
	
	If !lRet
		FwClearHLP()
		oModel:SetErrorMessage (,,,,,cMsgErro)
		DisarmTransaction()
		Break
	EndIf

End Transaction

	//--N�o executar para teste automatizado 	//Grava as posicoes
    If !lTmsIsRest
		oView:Refresh()
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMVALIDALT
Valida se o campo DL8_CRTDMD esta em branco. Caso esteja, ele � liberado para altera��o.
@type function
@author Natalia Maria Neves.
@version 12.1.17
@since 15/08/2018
/*/
Function TMVALIDALT()

	Local lRet := .F.
	
	If ALTERA .AND. Empty( DL8->DL8_CRTDMD ) .OR. INCLUI
		lRet := .T.	
	EndIf
	

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153ACan
Usado para cancelamento do processo de edi��o/exclus�o/inclus�o
@type function
@author Wander Horongoso.
@version 12.1.17
@since 25/05/2018
/*/
Function T153ACanc(oModel)

Local oModelDMD := oModel:GetModel('MASTER_DL8')
Local lRet := .T.
Local nOperation := oModel:GetOperation()

	If (nOperation == MODEL_OPERATION_UPDATE) .Or. (nOperation == MODEL_OPERATION_DELETE)
		If !Empty(oModelDMD:GetValue('DL8_COD')) .And. Empty(oModelDMD:GetValue('DL8_MARK')) 
			TMUnLockDmd('TMSA153A_' + DL8->DL8_FILIAL + DL8->DL8_COD + DL8->DL8_SEQ, .T.)
		EndIf
	EndIf
  	
	FWFormCancel(oModel)
	
	If __lSX8
		RollBackSX8()
	EndIf	
	
Return lRet
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153AVal
Valida��o de campos.
Usado no valid (dicion�rio de dados) dos campos da tabela DL8.

@type function
@author Wander Horongoso.
@version 12.1.17
@since 10/04/2018
/*/
//-------------------------------------------------------------------------------------------------
function TM153AVal(cCampo)
	Local lRet := .T.
	Local cQryDLE := ''
	Local cQryDLF := ''
	Local cQuery  := ''	
	Local oModel  := FwModelActive()
	
	If cCampo == "M->DL8_CLIDEV" 	
		If !Empty(M->DL8_CLIDEV) .AND. !Empty(FwFldGet('DL8_LOJDEV')) /*Verifica se o campo est� preenchido, para validar o conjunto campo e loja*/
			lRet := ExistCpo("SA1",M->DL8_CLIDEV+FwFldGet('DL8_LOJDEV'))
			If lRet
				FwFldPut('DL8_NOMDEV', POSICIONE("SA1",1,XFILIAL("SA1")+FwFldGet('DL8_CLIDEV')+FwFldGet('DL8_LOJDEV'),"A1_NOME"))
			EndIf	
		ElseIf !Empty(M->DL8_CLIDEV)
			lRet := ExistCpo("SA1",M->DL8_CLIDEV)	
		EndIf		
		
		If Empty(M->DL8_CLIDEV) .OR. Empty(FwFldGet('DL8_LOJDEV')) /*N�o gatilha o nome se um dos campos estiver em branco*/
			FwFldPut('DL8_NOMDEV','')
		EndIf
	Endif
	
	If lRet .AND. cCampo == "M->DL8_LOJDEV"
		If !Empty(FwFldGet('DL8_CLIDEV')) .AND. !Empty(M->DL8_LOJDEV) /*Verifica se o campo est� preenchido, para validar o conjunto campo e loja*/
			lRet := ExistCpo("SA1",FwFldGet('DL8_CLIDEV')+M->DL8_LOJDEV)	
			If lRet
				FwFldPut('DL8_NOMDEV', POSICIONE("SA1",1,XFILIAL("SA1")+FwFldGet('DL8_CLIDEV')+FwFldGet('DL8_LOJDEV'),"A1_NOME"))
			EndIf	
			
			If lRet
				/*Verifica se a loja do devedor, n�o est� selecionando um cliente que cont�m um contrato mais espec�fico*/
				lRet := T153VldCtr()
			EndIf			
			
		EndIf
	
		If Empty(M->DL8_LOJDEV) .OR. Empty(FwFldGet('DL8_CLIDEV')) /*N�o gatilha o nome se um dos campos estiver em branco*/
			FwFldPut('DL8_NOMDEV','')
		EndIf
	Endif
	
	If lRet .AND. cCampo == "DLA_CODCLI"	
		If !Empty(M->DLA_CODCLI) .AND. !Empty(FwFldGet('DLA_LOJA')) /*Verifica se o campo est� preenchido, para validar o conjunto campo e loja*/
			lRet := ExistCpo("SA1",M->DLA_CODCLI+FwFldGet('DLA_LOJA'))
			If lRet
				FwFldPut('DLA_NOMCLI', POSICIONE("SA1",1,XFILIAL("SA1")+FwFldGet('DLA_CODCLI')+FwFldGet('DLA_LOJA'),"A1_NOME"))
			EndIf	
		ElseIf !Empty(M->DLA_CODCLI)
			lRet := ExistCpo("SA1",M->DLA_CODCLI)	
		EndIf		
		
		If Empty(M->DLA_CODCLI) .OR. Empty(FwFldGet('DLA_LOJA')) /*N�o gatilha o nome se um dos campos estiver em branco*/
			FwFldPut('DLA_NOMCLI','')
		EndIf
	EndIf
	
	If lRet .AND. cCampo == "DLA_LOJA"
		If !Empty(FwFldGet('DLA_CODCLI')) .AND. !Empty(M->DLA_LOJA) /*Verifica se o campo est� preenchido, para validar o conjunto campo e loja*/
			lRet := ExistCpo("SA1",FwFldGet('DLA_CODCLI')+M->DLA_LOJA)	
			If lRet
				FwFldPut('DLA_NOMCLI', POSICIONE("SA1",1,XFILIAL("SA1")+FwFldGet('DLA_CODCLI')+FwFldGet('DLA_LOJA'),"A1_NOME"))
			EndIf	
		EndIf

		If Empty(M->DLA_LOJA) .OR. Empty(FwFldGet('DLA_CODCLI')) /*N�o gatilha o nome se um dos campos estiver em branco*/
			FwFldPut('DLA_NOMCLI','')
		EndIf
	EndIf
	
	//Valida��o de exist�ncia de relacionamento entre o Contrato e o Grupo de Regi�es informados em tela.
	If lRet .AND. cCampo == "M->DL8_CODGRD"
		If !Empty(M->DL8_CRTDMD) .And. !Empty(M->DL8_CODGRD)
	 		cQryDLE := GetNextAlias()
	 		cQuery := " SELECT COUNT(DLE_CRTDMD) nCount "
			cQuery += " FROM " + RetSqlName('DLE') + " DLE "
			cQuery += " WHERE DLE.DLE_FILIAL = '" + xFilial('DLE') + "'"
			cQuery += " AND DLE.DLE_CRTDMD = '"+ M->DL8_CRTDMD +"'"
			cQuery += " AND DLE.DLE_CODGRD = '"+ M->DL8_CODGRD +"'"
			cQuery += " AND DLE.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryDLE, .F., .T. )
	
			If (cQryDLE)->(nCount) == 0
				lRet:= .F.
				Help( ,, 'Help',, STR0052, 1, 0 ) //Grupo de regi�es n�o est� relacionado ao Contrato.
			EndIf
			(cQryDLE)->(dbCloseArea())
		EndIf	
	EndIf
	
	//Valida��o de exist�ncia de relacionamento entre o Contrato, o Grupo de Regi�es e o Tipo de ve�culo informados em tela.
	If lRet .AND. cCampo == "M->DL8_TIPVEI"
		If !Empty(M->DL8_CRTDMD) .And. !Empty(M->DL8_CODGRD) .And. !Empty(M->DL8_TIPVEI)
	 		cQryDLF := GetNextAlias()
	 		cQuery := " SELECT COUNT(DLF_CRTDMD) nCount "
			cQuery += " FROM " + RetSqlName('DLF') + " DLF "
			cQuery += " WHERE DLF.DLF_FILIAL = '" + xFilial('DLF') + "'"
			cQuery += " AND DLF.DLF_CRTDMD = '"+ M->DL8_CRTDMD +"'"
			cQuery += " AND DLF.DLF_CODGRD = '"+ M->DL8_CODGRD +"'"
			cQuery += " AND DLF.DLF_TIPVEI = '"+ M->DL8_TIPVEI +"'"
			cQuery += " AND DLF.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryDLF, .F., .T. )
	
			If (cQryDLF)->(nCount) == 0
				lRet:= .F.
				Help( ,, 'Help',, STR0053, 1, 0 ) //Tipo de ve�culo n�o est� relacionado ao Contrato e Grupo de regi�es.
			EndIf
			(cQryDLF)->(dbCloseArea())
		EndIf	
	EndIf	
		
	If lRet .AND. (cCampo $ "M->DL8_CRTDMD" .OR. cCampo $ "M->DL8_CODGRD")
		DbSelectArea("DL7")
		DL7->(DBSetOrder(1))
		If DL7->(DbSeek(xFilial("DL7")+M->DL8_CRTDMD))
			If!IsInCallStack("TmIncDem")
				If DL7->DL7_STATUS == "2" 
					Help( ,, 'Help',, STR0023, 1, 0 ) //"Contrato de demanda est� suspenso."
					lRet := .F.
				ElseIf DL7->DL7_STATUS == "3"
					Help( ,, 'Help',, STR0024, 1, 0 ) //"Contrato de demanda est� encerrado."
					lRet := .F.
				ElseIf DL7->DL7_STATUS == "4"
					If DL7->DL7_FIMVIG < dDataBase
						Help( ,, 'Help',, STR0035, 1, 0 ) //Contrato de demanda esta vencido.
						lRet := .F.
					Else
						If cCampo $ "M->DL8_CRTDMD"
							MsgAlert(STR0036) 	//Contrato de demanda esta inativo.
						EndIf
					EndIf
				EndIf
			EndIf
			If lRet
				T153CrtReg()
			EndIf
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. M->DL8_UM != DL7->DL7_UM 
				Help( ,, 'HELP',,STR0057, 1, 0,,,,,,{STR0058}) //A Unidade informada no contrato e na demanda est�o divergentes. Selecione outro contrato.
				lRet := .F.
			EndIf
			
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. M->DL8_CLIDEV != DL7->DL7_CLIDEV 
				Help( ,, 'HELP',,STR0059, 1, 0,,,,,,{STR0058}) //O Cliente informado no contrato e na demanda est�o divergentes. Selecione outro contrato.
				lRet := .F.
			EndIf
			If lRet .AND. cCampo == "M->DL8_CRTDMD" //Tratamento troca de contrato e cliente n�o tem loja anterior cadastrada. (� preenchido no gatilho novamente.)
				M->DL8_CLIDEV := " "
				M->DL8_LOJDEV := " "
			EndIf
		Else
			If !Empty(M->DL8_CRTDMD)
				Help( ,, 'Help',, STR0025, 1, 0 ) //"Contrato de demanda n�o cadastrado."
				lRet := .F.
			Else
				T153CrtReg()
			EndIf
		EndIf
	EndIf

	If lRet .AND. cCampo $ "M->DL8_UM"
		lRet := AjustQtDem("M->DL8_UM", "M->DL8_QTD")
	EndIf

	If lRet .AND. cCampo $ "M->DL8_QTD"
		lRet := ValidQtDem("M->DL8_UM", "M->DL8_QTD")
	EndIf

Return lRet

/*/{Protheus.doc} T153AFrDMD
Fracionamento de demanda
@type function
@author ruan.salvador
@since 19/09/2018
@version 1.0
/*/
Function T153AFrDMD()
	Local cTempCount := GetNextAlias()
	Local cMarkDem   := IF( IsBlind(), "5e", oBrwDeman:mark() )
	Local cQuery 	 := ''
	Local nPosDL8	 := 0
	Local nIndex	:= DL8->(IndexOrd())
	Local lRet := .T.
	Local nCount := 0
	Local aDL8Area := DL8->(GetArea())
	
	// Valida se rotina possui alguma demanda marcada
	DL8->(DbSetOrder(2))
	DL8->(DBGoTop())
	If DL8->( DbSeek(xFilial('DL8') + cMarkDem ))
		lRet := .T.
		cDeman := DL8->DL8_COD
		cSeq   := DL8->DL8_SEQ
	Else
		Help( ,, 'HELP',, STR0028, 1, 0 )//"Selecionar ao menos uma demanda para fracionar."
		lRet := .F.
		FwClearHLP()
	EndIf		

	If lRet
		// Valida se possui mais de uma demanda marcada

		cQuery  := "  SELECT DL8.DL8_COD, DL8.DL8_SEQ, DL8.DL8_MARK "
		cQuery  += "    FROM "+RetSqlName('DL8')+ " DL8 "
		cQuery  += "   WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
		cQuery  += "     AND DL8.DL8_MARK = '" + cMarkDem + "'"
		cQuery  += "     AND DL8.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempCount, .F., .T. )
		
		DL8->(DbSetOrder(1))
		While (cTempCount)->(!EoF())
			/*Varre o alias da query com os registros marcados e verifica 
			se eles est�o dentro do filtro de tela efetuando DbSeek*/
			If DL8->( DbSeek(xFilial('DL8') + (cTempCount)->DL8_COD + (cTempCount)->DL8_SEQ ))
				If !Empty(DL8->DL8_MARK)
					nCount++
				EndIf
				If nCount > 1
					Help( ,, 'HELP',, STR0027, 1, 0 ) //"Selecionar apenas uma demanda para fracionar."
					lRet := .F.
					Exit
				EndIf
			EndIf
			(cTempCount)->(DBSkip())
		EndDo
		(cTempCount)->(dbCloseArea())
	EndIf

	If lRet
		DL8->( DbSeek(xFilial('DL8') + cDeman + cSeq ))
		//So podera ser fracionado demandas que nao estiverem em planejamento
		If lRet .AND. Empty(DL8->DL8_PLNDMD) .And. DL8->DL8_STATUS == '1'
			nPosDL8 := oBrwDeman:At() 
			TMSA153I(DL8->DL8_COD, DL8->DL8_SEQ)
			
		Else
			Help( ,, 'HELP',,STR0021, 1, 0 ) //Demanda esta em planejamento	
		Endif
	EndIf	
	
	RestArea(aDL8Area)
	If lRet
		oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
		oBrwDeman:GoTo(nPosDL8)
	EndIf
	DL8->(DBSetOrder(nIndex))
	
Return
						
/*/{Protheus.doc} T153CrtReg
//Fun��o respons�vel  efetuar a carga das regi�es do contrato na demanda.
@author wander.horongoso
@since 03/05/2018
@version 1.0
@return lRet: indica que a opera��o foi executada
@param oModel, object, descricao
@type function
/*/
function T153CrtReg()
Local oModelGrid := nil
Local cTemp := GetNextAlias()
Local cQuery := ''	
Local cSeq := '00'
Local oModel := FwModelActive()

	If oModel:GetOperation() != MODEL_OPERATION_UPDATE .And. !IsInCallStack("T153UsaCrt")		
		
		oModelGrid := oModel:GetModel('GRID_ORI')
		
		If oModelGrid:Length() > 0 .AND. !Empty(oModelGrid:GetValue("DLA_CODREG"))
			ClearGrid(oModel, 'GRID_ORI')
		EndIf
		
		If !Empty(M->DL8_CRTDMD) .AND. !Empty(M->DL8_CODGRD)
			cQuery := " SELECT DLM.DLM_FILIAL, DLM.DLM_CODREG "
			cQuery += "   FROM " + RetSqlName('DLM') + " DLM "
			cQuery += "  WHERE DLM.DLM_FILIAL = '" + xFilial('DLM') + "'"
			cQuery += "    AND DLM.DLM_CRTDMD = '"+ M->DL8_CRTDMD +"'"
			cQuery += "    AND DLM.DLM_CODGRD = '"+ M->DL8_CODGRD +"'"			
			cQuery += "    AND DLM.D_E_L_E_T_ = '' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
			(cTemp)->(dbGoTop())
		
			cSeq := '00'
			
			while !(cTemp)->(Eof())			
				If !(cSeq =='00') //Somente a partir da segunda linha adiciona. Do contr�rio, usa a linha criada automaticamente na Grid.
					oModelGrid:AddLine()
				EndIf
						
				cSeq := Soma1(cSeq)
				oModelGrid:LoadValue('DLA_FILIAL', (cTemp)->DLM_FILIAL)
				oModelGrid:LoadValue('DLA_CODREG', (cTemp)->DLM_CODREG)
				oModelGrid:LoadValue('DLA_CODDMD', DL8->DL8_COD)
				oModelGrid:LoadValue('DLA_SEQDMD', DL8->DL8_SEQ)
				oModelGrid:LoadValue('DLA_NOMREG', Posicione("DUY",1,xFilial("DUY")+(cTemp)->DLM_CODREG,"DUY_DESCRI"))
				oModelGrid:LoadValue('DLA_SEQREG', cSeq)				
				oModelGrid:LoadValue('DLA_CODCLI', oModel:GetValue("MASTER_DL8","DL8_CLIDEV"))
				oModelGrid:LoadValue('DLA_LOJA',   oModel:GetValue("MASTER_DL8","DL8_LOJDEV"))
				oModelGrid:LoadValue('DLA_NOMCLI', Posicione("SA1",1,xFilial("SA1")+oModel:GetValue("MASTER_DL8","DL8_CLIDEV"),"A1_NOME"))
				oModelGrid:LoadValue('DLA_PREVIS', "1")

				(cTemp)->(dbSkip())		
					
			EndDo
			
			oModelGrid:SetLine(1)
			
			(cTemp)->(dbCloseArea())
			
		EndIf 
		
		oModelGrid := oModel:GetModel('GRID_DES')

		If oModelGrid:Length() > 0 .AND. !Empty(oModelGrid:GetValue("DLL_CODREG"))
			ClearGrid(oModel, 'GRID_DES')
		EndIf

		If !Empty(M->DL8_CRTDMD) .AND. !Empty(M->DL8_CODGRD)

			cQuery := " SELECT DLN.DLN_FILIAL, DLN.DLN_CODREG "
			cQuery += "   FROM " + RetSqlName('DLN') + " DLN "
			cQuery += "  WHERE DLN.DLN_FILIAL = '" + xFilial('DLN') + "'"
			cQuery += "    AND DLN.DLN_CRTDMD = '"+ M->DL8_CRTDMD +"'"
			cQuery += "    AND DLN.DLN_CODGRD = '"+ M->DL8_CODGRD +"'"			
			cQuery += "    AND DLN.D_E_L_E_T_ = '' "
				
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
			(cTemp)->(dbGoTop())
		
			cSeq := '00'
			
			while !(cTemp)->(Eof())			
				If !(cSeq =='00') //Somente a partir da segunda linha adiciona. Do contr�rio, usa a linha criada automaticamente na Grid.
					oModelGrid:AddLine()
				EndIf
						
				cSeq := Soma1(cSeq)
				oModelGrid:LoadValue('DLL_FILIAL', (cTemp)->DLN_FILIAL)
				oModelGrid:LoadValue('DLL_CODREG', (cTemp)->DLN_CODREG)
				oModelGrid:LoadValue('DLL_CODDMD', DL8->DL8_COD)
				oModelGrid:LoadValue('DLL_SEQDMD', DL8->DL8_SEQ)
				oModelGrid:LoadValue('DLL_NOMREG', Posicione("DUY",1,xFilial("DUY")+(cTemp)->DLN_CODREG,"DUY_DESCRI"))
				oModelGrid:LoadValue('DLL_SEQREG', cSeq)
				oModelGrid:LoadValue('DLL_PREVIS', "1")

				(cTemp)->(dbSkip())		
						
			EndDo 
			
			oModelGrid:SetLine(1)	
			
			(cTemp)->(dbCloseArea())
			
		EndIf		
	EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} function
Valida se regi�o informada pertence ou n�o ao contrato. 
Caso pertenca, campo DLA_PREVIS passa a ser = '1' - Sim
@author  Gustavo Krug
@since   11/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153AVReg(cCrtDmd, cCodReg, cCodGrd,cTipReg,oModelGrid)
Local lRet := .T.
Local cQuery := ''
Local cAliasQry := GetNextAlias()

	If !Empty(M->DL8_CRTDMD)
	
		If cTipReg == '1' //Origem
			cQuery := " SELECT DLM_CODREG "
			cQuery += "   FROM " + RetSqlName("DLM") + " DLM "
			cQuery += "  WHERE DLM.DLM_FILIAL = '" + xFilial('DLM') + "' "
			cQuery += "    AND DLM.DLM_CRTDMD = '" + cCrtDmd + "' "
			cQuery += "    AND DLM.DLM_CODGRD = '" + cCodGrd + "' "  
			cQuery += "    AND DLM.DLM_CODREG = '" + cCodReg + "' " 
			cQuery += "    AND DLM.D_E_L_E_T_ = ' ' "
		ElseIf cTipReg == '2' //Destino
			cQuery := " SELECT DLN_CODREG "
			cQuery += "   FROM " + RetSqlName("DLN") + " DLN "
			cQuery += "  WHERE DLN.DLN_FILIAL = '" + xFilial('DLN') + "' "
			cQuery += "    AND DLN.DLN_CRTDMD = '" + cCrtDmd + "' "
			cQuery += "    AND DLN.DLN_CODGRD = '" + cCodGrd + "' "  
			cQuery += "    AND DLN.DLN_CODREG = '" + cCodReg + "' " 
			cQuery += "    AND DLN.D_E_L_E_T_ = ' ' "			
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		
		While (cAliasQry)->(!Eof())
			If cTipReg == '1' .And. M->DLA_CODREG == (cAliasQry)->DLM_CODREG //Origem
				oModelGrid:LoadValue('DLA_PREVIS', '1')
			ElseIf cTipReg == '2' .And. M->DLL_CODREG == (cAliasQry)->DLN_CODREG //Destino
				oModelGrid:LoadValue('DLL_PREVIS', '1')
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153DL8UM()
Gatilho do campo DL8_UM para apagar dados das quantidades de acordo com o tipo de unidade informado.
@author  Gustavo Krug
@since   11/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153DL8UM(oModel)
Local oModelAux := oModel:GetModel( 'MASTER_DL8' )
Local oModelDLA	:= oModelAux:GetModel('GRID_ORI')
Local nX := 0
Local nLintemp := oModelDLA:GetLine()
Local lPrev := .F.

	If M->DL8_UM <> "2"
		oModel:LoadValue("DL8_QTD",0)
		oModel:GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.F.})
	ElseIf M->DL8_UM = "2"
		oModel:GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.T.})
		For nX := 1 to oModelDLA:GetQtdLine()
			oModelDLA:GoLine(nX)  //Vai pra primeira linha para varrer o grid de regiao.
			If oModelDLA:GetValue('DLA_PREVIS') == '1'
				lPrev := .T.
			EndIf
			If !oModelDLA:IsDeleted(nX) 
				oModelDLA:LoadValue("DLA_QTD",0)
				oModelDLA:ClearField("DLA_QTD",nX)
			EndIf
		Next nx
		oModelDLA:GoLine(nLintemp)

		oModel:LoadValue("DL8_QTD",0)
	EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} T153APreOr()
Fun��o de pr�-valida��o do submodelo, � invocado na dele��o de linha, no undelete da linha, 
na inser��o de uma linha e nas tentativas de atribui��o de valor.
@author Gustavo Krug
@since   10/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153APreOr( oModelGrid, nLine, cOpera)
	Local lRet       := .T.
	Local oModelDL8 := oModelGrid:GetModel( 'MASTER_DL8' )
	Local nOperation :=  oModelGrid:GetOperation()
	Local nQtdTot := 0
	Local nX := 0
	Local nLintemp := oModelGrid:GetLine()
	Local lQuant:= .F.

	If Type("M->DLA_QTD") <> "U" .OR. lTmsIsRest
		lQuant:= .T.
	EndIf

	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE ) .AND. (cOpera == "SETVALUE")

		//Valida se data informada � igual ou superior � atual
		If !Empty(M->DLA_DTPREV) .And. M->DLA_DTPREV < Date()
			Help( ,, 'Help',, STR0030, 1, 0 ) //Data informada inferior a data atual
			lRet := .F.
		ElseIf M->DLA_DTPREV == Date() .And. !Empty(oModelGrid:GetValue('DLA_HRPREV')) .And. oModelGrid:GetValue('DLA_HRPREV') < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  ))
			Help( ,, 'Help',, STR0031, 1, 0 ) //Hora informada inferior a hora atual
			oModelGrid:LoadValue("DLA_HRPREV",'')

			lRet := .F.
		EndIf

		//Valida se o formato da hora � valido
		If !Empty(M->DLA_HRPREV)
			lRet:= AtVldHora(M->DLA_HRPREV) 
		EndIf		
		//Valida se hora informada � igual ou superior � atual
		If  !Empty(oModelGrid:GetValue('DLA_DTPREV')) .And. !Empty(M->DLA_HRPREV) .And. oModelGrid:GetValue('DLA_DTPREV') <= Date() .And. M->DLA_HRPREV < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  ))
			Help( ,, 'Help',, STR0031, 1, 0 ) //Hora informada inferior a hora atual
			lRet := .F.
		EndIf		

		//Efetua a soma da quantidade do grid de regiao de origem quando a unidade do contrato for diferente de 2
		If (M->DL8_UM <> "2") .AND. !EMPTY(M->DL8_UM) .AND. !lTmsIsRest //Caso a gera�ao de demandas esteja sendo feita por API, a soma da quantidade � feita na fun��o T153PosOri()
			For nX := 1 to oModelGrid:GetQtdLine()
				oModelGrid:GoLine(nX)  // Vai pra primeira linha para varrer o grid de regiao.
				If !oModelGrid:IsDeleted(nX) .AND. lQuant
					If !(nLine == nX )  //Como a fun��o � chamada na pr� valida��o, o valor do campo � o anterior, por isso aqui � validade par apegar da mem�ria
						nQtdTot += oModelGrid:GetValue("DLA_QTD")
					Else
						nQtdTot += M->DLA_QTD 
					EndIf
					oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.T.})
 					oModelDL8:SetValue("MASTER_DL8","DL8_QTD",nQtdTot)
 					oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.F.})

				EndIf
			Next nx
			oModelGrid:GoLine(nLintemp)  //Retorna para a linha que estava possionado
		EndIf
	ElseIf (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE ) .AND. (cOpera == "DELETE") 	
		
		If (M->DL8_UM <> "2") .AND. !EMPTY(M->DL8_UM)
			nQtdTot := oModelDL8:GetValue("MASTER_DL8","DL8_QTD") - oModelGrid:GetValue("DLA_QTD")
			
			oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.T.})
			If !oModelDL8:SetValue("MASTER_DL8","DL8_QTD",nQtdTot)
				lRet:= .F.
			EndIf
			oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.F.})

		EndIf
	ElseIf (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE ) .AND. (cOpera == "UNDELETE") 

		If (M->DL8_UM <> "2") .AND. !EMPTY(M->DL8_UM)
			nQtdTot := oModelDL8:GetValue("MASTER_DL8","DL8_QTD") + oModelGrid:GetValue("DLA_QTD")

			oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.T.})
			If !oModelDL8:SetValue("MASTER_DL8","DL8_QTD",nQtdTot)
				lRet:= .F.
			EndIf
			oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.F.})

		EndIf
	EndIf
	
Return lRet   

//-------------------------------------------------------------------
/*/{Protheus.doc} T153APreDs()
Fun��o de pr�-valida��o do submodelo, � invocado na dele��o de linha, no undelete da linha, 
na inser��o de uma linha e nas tentativas de atribui��o de valor.
@author Gustavo Krug
@since   10/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153APreDs( oModelGrid, nLine, cOpera)
	Local nOperation :=  oModelGrid:GetOperation()
	Local lRet := .T.

	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE ) .AND. (cOpera == "SETVALUE")
		//Valida se data informada � igual ou superior � atual
		If !Empty(M->DLL_DTPREV) .And. M->DLL_DTPREV < Date()
			Help( ,, 'Help',, STR0030, 1, 0 ) //Data informada inferior a data atual
			lRet := .F.
		ElseIf M->DLL_DTPREV == Date() .And. !Empty(oModelGrid:GetValue('DLL_HRPREV')) .And. oModelGrid:GetValue('DLL_HRPREV') < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  ))
			Help( ,, 'Help',, STR0031, 1, 0 ) //Hora informada inferior a hora atual
			oModelGrid:LoadValue("DLL_HRPREV",'')
			lRet := .F.
		EndIf

		//Valida se o formato da hora � valido
		If !Empty(M->DLL_HRPREV)
			lRet:= AtVldHora(M->DLL_HRPREV) 
		EndIf		
		//Valida se hora informada � igual ou superior � atual
		If  !Empty(oModelGrid:GetValue('DLL_DTPREV')) .And. !Empty(M->DLL_HRPREV) .And. oModelGrid:GetValue('DLL_DTPREV') <= Date() .And. M->DLL_HRPREV < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  ))
			Help( ,, 'Help',, STR0031, 1, 0 ) //Hora informada inferior a hora atual
			lRet := .F.
		EndIf		
	EndIf
	
Return lRet                   
      
//-------------------------------------------------------------------	
/*/{Protheus.doc} T153ALNPOS()
Realiza p�s valida��o da linha (Grids Origem e Destino)
@author  Gustavo Krug
@since   22/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153ALNPOS( oModelGrid, cTipo )
Local lRet       := .T.
Local oModel
Local nOperation
Local cCamDTPREV := ''
Local cCamHRPREV := ''
	
	If cTipo == '1'
		oModel     := oModelGrid:GetModel( 'GRID_ORI' )
		cCamDTPREV := 'DLA_DTPREV'
		cCamHRPREV := 'DLA_HRPREV'
	Else
		oModel     := oModelGrid:GetModel( 'GRID_DES' )
		cCamDTPREV := 'DLL_DTPREV'
		cCamHRPREV := 'DLL_HRPREV'
	EndIf
	nOperation := oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

		If Empty(oModelGrid:GetValue(cCamDTPREV)) .And. !Empty(oModelGrid:GetValue(cCamHRPREV))
			Help( ,, 'HELP',, STR0032, 1, 0 ) //Data n�o informada
			lRet:= .F.
		EndIf
	EndIf
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA153AVL
Realiza a pr� valida��o ao ativar o model (clicar em incluir, alterar ou excluir) 
@author  Marlon Augusto Heiber	
@since   21/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function TMSA153AVL(oModel,nLine, cAction)
Local lRet 		:= .T.
Local aRet 		:= {}	
Local nOperation:= oModel:GetOperation()
Local nIndex	:= DL8->(IndexOrd())

	If (nOperation == MODEL_OPERATION_UPDATE) .AND. (DL8->DL8_ORIDMD <> "1")
		FwClearHLP()
		oModel:SetErrorMessage('TMSA153A',,,,,STR0029,'',�nil,�nil) //Esta Demanda n�o foi originada pelo Painel de Gest�o de Demandas - (TMSA153). S� � possivel alterar Demandas geradas pelo Painel de Gest�o de Demandas.
		lRet := .F.      
	Endif 
	
	If !nOperation == MODEL_OPERATION_INSERT
		DL8->(DbSetOrder(1))
		If !DL8->(DbSeek(xFilial('DL8')+ DL8->DL8_COD + DL8->DL8_SEQ))
			FwClearHLP()
			oModel:SetErrorMessage('TMSA153A',,,,,STR0051,'',�nil,�nil) //Este registro j� foi exclu�do.
			lRet := .F.
		EndIf
		DL8->(DbSetOrder(nIndex))
	EndIf
	
	If lRet .And. (nOperation == MODEL_OPERATION_UPDATE) .OR. (nOperation == MODEL_OPERATION_DELETE)
		aRet := TMLockDmd('TMSA153A_' + DL8->DL8_FILIAL + DL8->DL8_COD + DL8->DL8_SEQ,.F.)
		If !aRet[1]
			Help( ,, 'HELP',, aRet[2], 1, 0 )
			lRet := .F.
		Else
			If IsInCallStak("TMSA153GRV")
				TMUnLockDmd('TMSA153A_' + DL8->DL8_FILIAL + DL8->DL8_COD + DL8->DL8_SEQ,.T.)
			EndIf
		EndIf
	EndIf
    
    //Grava as posicoes
	If !lTmsIsRest .And. IsInCallStack('TMSA153') //quando chamado por fora do painel de gest�o de demandas os browses n�o existem 
    		nPosDL9 := oBrwPlan:At()
    		nPosDL8 := oBrwDeman:At() 
    		nPosDL7 := oBrwCrtDmd:At()
	EndIf

	If lRet
		TClearFKey()
	EndIf
Return lRet

/*/{Protheus.doc} T153GTCRT
//Gatilho do campo Contrato
@author gustavo.baptista
@since 19/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
static function T153GTCRT(oModel)

	Local cTemp := Nil
	Local cQuery:= ''
	Local lRet:= .T.
	Local aDleArea := DLE->(GetArea())
	Local nRecNo := DLE->(RECNO())

	If "'" $ M->DL8_CRTDMD .OR. '"' $ M->DL8_CRTDMD
		lRet:= .F.
	EndIf
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. !Empty(DL8->DL8_CRTDMD)
		lRet:= .F.
	EndIf

	If lRet 
			//retira a valida��o do campo x3_when pra poder limpar o campo e depois volta a valida��o que estava l�
			oModel:GetStruct():SetProperty("DL8_CODGRD", MODEL_FIELD_WHEN,{||.T.})
			oModel:SetValue('DL8_CODGRD','')
			oModel:GetStruct():SetProperty("DL8_CODGRD", MODEL_FIELD_WHEN,{||(INCLUI .AND. !Empty(M->DL8_CRTDMD)) .OR. (ALTERA .AND. !Empty(M->DL8_CRTDMD))})
			
			oModel:GetStruct():SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||.T.})
			oModel:SetValue('DL8_TIPVEI','')
 			oModel:GetStruct():SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||(INCLUI .AND. !Empty(M->DL8_CODGRD)) .OR. (ALTERA .AND. !Empty(M->DL8_CODGRD))})
			
 			cTemp:= getNextAlias()
 			
			cQuery := " SELECT Count(DLE_CRTDMD) nCount "
			cQuery += " FROM " + RetSqlName('DLE') + " DLE "
			cQuery += " WHERE DLE.DLE_FILIAL = '" + xFilial('DLE') + "'"
			cQuery += " AND DLE.DLE_CRTDMD = '"+ M->DL8_CRTDMD +"'"
			cQuery += " AND DLE.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
	
			If (cTemp)->(nCount) == 1
		
				//� necess�rio limpar o filtro da DLE pois o comando addRelation (utilizado ao criar o browse),
				//	acaba filtrando a tabela DLE
				
				DLE->(DbClearFilter())
				DLE->(DbCloseArea())
				DLE->(DbSetOrder(1))
				If DLE->(DbSeek(xFilial("DLE")+M->DL8_CRTDMD))
	
					oModel:GetStruct():SetProperty("DL8_CODGRD", MODEL_FIELD_WHEN,{||.T.})
					oModel:SetValue('DL8_CODGRD','')
					oModel:GetStruct():SetProperty("DL8_CODGRD", MODEL_FIELD_WHEN,{||(INCLUI .AND. !Empty(M->DL8_CRTDMD)) .OR. (ALTERA .AND. !Empty(M->DL8_CRTDMD))})
					
					oModel:GetStruct():SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||.T.})
					oModel:SetValue('DL8_TIPVEI','')
					oModel:GetStruct():SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||INCLUI .AND. !Empty(M->DL8_CODGRD) .OR. ALTERA .AND. !Empty(M->DL8_CODGRD)})
						
					oModel:SetValue('DL8_CODGRD',DLE->DLE_CODGRD)
					
				EndIf
			EndIf
			dbCloseArea(cTemp)
		EndIf
	RestArea(aDleArea)
	DLE->(DbGoTo(nRecNo))

Return lRet

/*/{Protheus.doc} T153GTGRD
//Gatilho do campo C�digo do grupo de regi�o
@author gustavo.baptista
@since 19/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
static function T153GTGRD(oModel)

	Local cQuery := ''
	Local lRet := .T.
	Local cTemp := Nil

	If "'" $ M->DL8_CODGRD .OR. '"' $ M->DL8_CODGRD
		lRet:= .F.
	EndIf

	If lRet
	
		oModel:GetStruct():SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||.T.})
		oModel:SetValue('DL8_TIPVEI','')
		
		cTemp := getNextAlias()
		
		cQuery := " SELECT COUNT(DLF_CRTDMD) nCount "
		cQuery += " FROM " + RetSqlName('DLF') + " DLF "
		cQuery += " WHERE DLF.DLF_FILIAL = '" + xFilial('DLF') + "'"
		cQuery += " AND DLF.DLF_CRTDMD = '"+ oModel:GetValue('DL8_CRTDMD') +"'"
		cQuery += " AND DLF.DLF_CODGRD = '"+ M->DL8_CODGRD +"'"
		cQuery += " AND DLF.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
	
	
		If (cTemp)->(nCount) > 0
		
			oModel:GetStruct():SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||.T.})
		
			If (cTemp)->(nCount) == 1
	
				DLF->(DbSetOrder(1))
				If DLF->(DbSeek(xFilial("DLF")+oModel:GetValue('DL8_CRTDMD')+M->DL8_CODGRD)) .AND. !Empty(M->DL8_CODGRD)
					oModel:SetValue('DL8_TIPVEI',DLF->DLF_TIPVEI)
				Else 
					oModel:GetStruct():SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||.F.})
				EndIf
			EndIf
		Else
			oModel:GetStruct():SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||.F.})
		EndIf
		
		dbCloseArea(cTemp)
	EndIf

Return lRet

/*/{Protheus.doc} T153GTREG
//Gatilho do C�digo de Regi�o
@author gustavo.baptista
@since 27/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
static function T153GTREG(oModel, nOpc)

	Local lRet := .T.
	Local oModelDL8:= oModel:GetModel():GetModel('MASTER_DL8')

	If !Empty(oModelDL8:GetValue('DL8_CRTDMD')) .AND. !Empty(oModel:GetValue(Iif(nOpc == 1,'DLA_CODREG', 'DLL_CODREG'))) .AND. !Empty(oModelDL8:GetValue('DL8_CODGRD'))
		If nOpc == 1 //Origem
			oModel:LoadValue('DLA_PREVIS', '2')
			T153AVReg(oModelDL8:GetValue('DL8_CRTDMD'), oModel:GetValue('DLA_CODREG'), oModelDL8:GetValue('DL8_CODGRD'),'1',oModel)
		ElseIf nOpc == 2 //Destino
			oModel:LoadValue('DLL_PREVIS', '2')
			T153AVReg(oModelDL8:GetValue('DL8_CRTDMD'), oModel:GetValue('DLL_CODREG'), oModelDL8:GetValue('DL8_CODGRD'),'2',oModel)
		EndIf		
	EndIf
	
	If nOpc == 1
		oModel:SetValue("DLA_CODCLI",oModelDL8:GetValue('DL8_CLIDEV'))
		oModel:SetValue("DLA_LOJA",oModelDL8:GetValue('DL8_LOJDEV'))
	EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153CrtDmd()
Monta tela que exibe quais contratos podem ser utilizados para gerar
uma determinada demanda.
@author  Gustavo Krug
@since   02/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153CrtDmd(aOpc)
Local oBrowse
Local oPnlObj
Local oFWLayer
Local bDbClick  :=  {|| T153UsaCrt(("DL7TEMP")->CRTDMD, ("DL7TEMP")->CODGRD), oDlgMan:DeActivate() } 

	oDlgMan := FWDialogModal():New()
	oDlgMan:SetBackground(.F.)
	oDlgMan:SetTitle(STR0049) //Contratos de Demanda
	oDlgMan:SetEscClose(.T.)
	oDlgMan:SetSize(300, 400)
	oDlgMan:CreateDialog()

	oPnlModal := oDlgMan:GetPanelMain()	

	oFWLayer := FWLayer():New()                
	oFWLayer:Init(oPnlModal, .F., .F.)          

	oFWLayer:AddLine('LIN', 100, .F.)           
	oFWLayer:AddCollumn('COL', 100, .F., 'LIN') 
	oPnlObj := oFWLayer:GetColPanel('COL', 'LIN')
	
	oBrowse:= FWMBrowse():New()
    oBrowse:SetOwner( oPnlObj ) 
    oBrowse:SetDescription( STR0050 ) //'Selecione um contrato para gerar a demanda'
    oBrowse:SetMenuDef( '' )                   
    oBrowse:DisableDetails()
    oBrowse:DisableLocate()
    oBrowse:DisableReport()
	oBrowse:SetDataQuery(.T.)
    oBrowse:SetQuery(T153AClQry(aOpc)) //Monta query para exibi��o do browse
	oBrowse:SetAlias("DL7TEMP" )
    oBrowse:SetColumns(T153AClBrw())
    oBrowse:SetDoubleClick(bDbClick)
	oBrowse:SetProfileID( '1' )
    oBrowse:Activate()
	oBrowse:Refresh(.T.)
	oDlgMan:Activate()
	
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} T153AClQry
Monta Query com contratos encontrados para gerar demanda
@author  Gustavo Krug
@since   28/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function T153AClQry(aOpc)
	Local cQuery 	:= ''
	Local nX 		:= 0

	cQuery := " SELECT DISTINCT DL7TEMP.DL7_COD CRTDMD, DL7TEMP.DL7_TIPCTR TIPCTR, DL7TEMP.DL7_ABRANG ABRANG, DLETEMP.DLE_CODGRD CODGRD"
	cQuery += " FROM " 		 + RetSqlName("DL7") + " DL7TEMP"
	cQuery += " INNER JOIN " + RetSqlName("DLE") + " DLETEMP ON DLETEMP.DLE_FILIAL = '" + FWxFilial('DLE') + "' "
	cQuery +=                                             " AND DL7TEMP.DL7_COD    = DLETEMP.DLE_CRTDMD "
	cQuery +=                                             " AND DLETEMP.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE 		DL7TEMP.DL7_FILIAL = '" + FWxFilial('DL7') + "' "
	cQuery += " AND 		DL7TEMP.D_E_L_E_T_ = ' ' "
	For nX := 1 To Len(aOpc)
		If nX == 1
			cQuery += "AND ( ( DL7TEMP.DL7_COD = '" + aOpc[nX][1] + "' AND DLE_CODGRD = '" + aOpc[nX][2] + "' )"
		Else
			cQuery += "OR    ( DL7TEMP.DL7_COD = '" + aOpc[nX][1] + "' AND DLE_CODGRD = '" + aOpc[nX][2] + "' )"
		EndIf
	Next nX
	cQuery += " )"
	cQuery := ChangeQuery(cQuery)

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} T153AClBrw()
Cria colunas para construir browse
@author  Gustavo Krug
@since   28/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153AClBrw()
Local aColumns := {}

   	//Contrato de Demandas
    AAdd(aColumns,FWBrwColumn():New())  
    aColumns[Len(aColumns)]:SetData( {||("DL7TEMP")->CRTDMD} ) // Dado que ir� popular o campo
	aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DL7_COD','X3_TITULO')) // T�tulo da coluna 

    //Tipo do Contrato
    AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData( {|| FwGetSX5("NW",padr(("Dl7TEMP")->TIPCTR, 6))[1][4] } ) // Dado que ir� popular o campo
    aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DL7_TIPCTR','X3_TITULO')) // T�tulo da coluna

    //Abrangencia
    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( {|| IIf( ("DL7TEMP")->ABRANG == '1', STR0065  , STR0066  ) } ) // Dado que ir� popular o campo //"Espec�fica"#"Gen�rica"
    aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DL7_ABRANG','X3_TITULO')) // T�tulo da coluna
    
    //Grupo de Regi�es
    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( {||("DL7TEMP")->CODGRD} ) // Dado que ir� popular o campo
    aColumns[Len(aColumns)]:SetTitle(GetSx3Cache('DLE_CODGRD','X3_TITULO')) // T�tulo da coluna

Return aColumns

//-------------------------------------------------------------------
/*/{Protheus.doc} T153UsaCrt
Utiliza Contrato e Grupo de Regi�es � Demanda
@author  Gustavo Krug
@since   28/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153UsaCrt(cCrtDmd, cCodGrd)
Local oModel    := FwModelActive()
Local oModelDL8 := oModel:GetModel('MASTER_DL8')
Local oModelOri := oModel:GetModel('GRID_ORI')
Local oModelDes := oModel:GetModel('GRID_DES')
Local nX        := 0
Local cTemp     := GetNextAlias()
Local cQuery    := ""
Local aReg      := {}      

	oModelDL8:SetValue("DL8_CRTDMD",cCrtDmd)
	oModelDL8:GetStruct():SetProperty("DL8_CODGRD", MODEL_FIELD_WHEN,{||.T.})
	oModelDL8:LoadValue("DL8_CODGRD",cCodGrd)
	oModelDL8:GetStruct():SetProperty("DL8_CODGRD", MODEL_FIELD_WHEN,{||.F.})
	
	cQuery  := " SELECT DLM_CODREG "	
	cQuery  += "   FROM " + RetSqlName('DLM') + " DLM "                              
	cQuery  += "  WHERE DLM_FILIAL = '" + xFilial('DLM') + "'" 
	cQuery  += "    AND DLM_CRTDMD = '" + cCrtDmd + "'"
	cQuery  += "    AND DLM_CODGRD = '" + cCodGrd + "'"
	cQuery  += "    AND D_E_L_E_T_ = ' '"
	
    cQuery := ChangeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
    
	While !(cTemp)->(Eof())
		aAdd(aReg, {(cTemp)->DLM_CODREG} )
		(cTemp)->(dbSkip())
	EndDo

	(cTemp)->(dbCloseArea())
	
	For nX := 1 to oModelOri:GetQtdLine()
		oModelOri:GoLine(nX)
		
		If aScan(aReg, {|x| x[1] == oModelOri:GetValue('DLA_CODREG')}) > 0
			oModelOri:LoadValue("DLA_PREVIS","1")
		EndIf
	Next nX	

	cQuery  := " SELECT DLN_CODREG "	
	cQuery  += "   FROM " + RetSqlName('DLN') + " DLN "                              
	cQuery  += "  WHERE DLN_FILIAL = '" + xFilial('DLN') + "'" 
	cQuery  += "    AND DLN_CRTDMD = '" + cCrtDmd + "'"
	cQuery  += "    AND DLN_CODGRD = '" + cCodGrd + "'"
	cQuery  += "    AND D_E_L_E_T_ = ' '"
	
    cQuery := ChangeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )	
	
	aReg := {}
	While !(cTemp)->(Eof())
		aAdd(aReg, {(cTemp)->DLN_CODREG} )

		(cTemp)->(dbSkip())
	EndDo
		
	(cTemp)->(dbCloseArea())

	For nX := 1 to oModelDes:GetQtdLine()
		oModelDes:GoLine(nX)
		
		If aScan(aReg, {|x| x[1] == oModelDes:GetValue('DLL_CODREG')}) > 0
			oModelDes:LoadValue("DLL_PREVIS","1")
		EndIf
	Next nX
	
	aReg := {}	
	
Return Nil

/*/{Protheus.doc} T153AWhen
//Altera a propriedade When do campo passado por par�metro
@author gustavo.baptista
@since 17/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cCampo, characters, Define qual campo que ser� validado no When
@type function
/*/
Function T153AWhen(cCampo)

	Local lRet := .T.
	Local cQuery := ""
	Local cAliasQry := GetNextAlias()

	if cCampo == 'DL8_LOJDEV'
	
		cQuery:= " Select DL7_ABRANG"
		cQuery+= " From "+RetSqlName('DL7')+" DL7 "
		cQuery+= " Where DL7_FILIAL = '"+xFilial("DL7")+"'"
		cQuery+= " And DL7_COD = '"+ M->DL8_CRTDMD +"'"
		cQuery+= " And D_E_L_E_T_ = '' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )
		
		if (cAliasQry)->(!EoF())
			if (cAliasQry)->DL7_ABRANG == '1'
				lRet:= EMPTY(M->DL8_CRTDMD) .AND. INCLUI
			else
				lRet:= INCLUI
			endif
		EndIf

		(cAliasQry)->(DbCloseArea())
	else
		lRet:= EMPTY(M->DL8_CRTDMD) .AND. INCLUI
	endif
	

return lRet 


/*/{Protheus.doc} T153VldCtr
//Valida se ao alterar a loja do devedor, n�o est� selecionando um cliente que cont�m um contrato mais espec�fico ( abrang�ncia cliente/loja )
@author gustavo.baptista
@since 20/08/2018
@version 1.0
@return ${return}, ${Caso encontre outro contrato para este cliente e seja do tipo '1', n�o deve permitir continuar}

@type function
/*/
Function T153VldCtr()

	Local lRet 		:= .T.
	Local cQuery 	:= ''
	Local cAliasQry	:= GetNextAlias()
	Local cTipCtr 	:= Posicione('DL7',1,FWxFilial('DL7')+M->DL8_CRTDMD,'DL7_TIPCTR')
	Local cStatus   := DL7->DL7_STATUS

	If !Empty(M->DL8_CRTDMD)

		If cStatus <> '4' //s� ir� validar abrang�ncia, se o contrato que est� sendo digitado n�o for inativo 
			cQuery:= " SELECT COUNT(DL7_COD) cCod FROM " + RetSqlName('DL7')+ " DL7 "
			cQuery+= " WHERE DL7.DL7_FILIAL = '" + xFilial('DL7') + "'"
			cQuery+= "   AND DL7.DL7_CLIDEV = '" + M->DL8_CLIDEV  + "'"
			cQuery+= "   AND DL7.DL7_LOJDEV = '" + M->DL8_LOJDEV + "'"
			cQuery+= "   AND DL7.DL7_STATUS <> '3'"		
			cQuery+= "   AND DL7.DL7_ABRANG = '1'"	
			cQuery+= "   AND DL7.DL7_COD 	<> '" + M->DL8_CRTDMD + "'"
			cQuery+= "   AND DL7.DL7_TIPCTR = '" + cTipCtr + "'"
			cQuery+= "   AND (DL7.DL7_INIVIG <= '" + DTOS(dDataBase) + "'"
			cQuery+= "   AND DL7.DL7_FIMVIG >= '" + DTOS(dDataBase) + "')"
			cQuery+= "   AND D_E_L_E_T_ 	= ' ' "
		
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )
		
			If (cAliasQry)->(!EoF())
				If (cAliasQry)->cCod > 0
					Help( ,, 'Help',, STR0064, 1, 0 ) //Este cliente/loja cont�m um contrato de abrang�ncia mais espec�fica.
					lRet:= .F.
				EndIf
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153AtuDt
Atribui a vari�veis:
1�: A quantidade de regi�es de origem e destino da demanda.
2�: Data e hora de inicio e fim da demanda.

Vari�veis:
->DL8_QTDPO - Qtd. de Pontos de Origem.
->DL8_QTDPD - Qtd. de Pontos de Destino.
->DL8_PRVORI - Previs�o Origem.
->DL8_HRPROR - Hora Previs�o Origem.
->DL8_PRVDES - Previs�o Destino.
->DL8_HRPRDS - Hora Previs�o Destino.

@author  natalia.neves
@since   18/09/2018
@version 1.0
@param oModel - retorna o model ativo.
/*/
//-------------------------------------------------------------------
Function T153AtuDt(oModel)

Local oModelOri := oModel:GetModel('GRID_ORI'  )
Local oModelDes := oModel:GetModel('GRID_DES'  )
Local nQtdOri   := IIF(oModelOri:IsEmpty(), 0, oModelOri:Length(.T.) )
Local nQtdDes   := IIF(oModelDes:IsEmpty(), 0, oModelDes:Length(.T.) )
Local cMinDt    := ""
Local cMaxDt    := ""
Local cMinHr    := ""
Local cMaxHr    := ""
Local nX        := 0

	//Verifica linha por linha do grid de reg. origem para determinar as previs�es.
	For nX := 1 to oModelOri:GetQtdLine()
		If !(oModelOri:IsDeleted(nX))
			If Empty(cMinDt) .Or.  oModelOri:GetValue('DLA_DTPREV', nX) < cMinDt
				cMinDt := oModelOri:GetValue('DLA_DTPREV', nX)
				cMinHr := oModelOri:GetValue('DLA_HRPREV', nX)
			ElseIf oModelOri:GetValue('DLA_DTPREV', nX) == cMinDt
				If oModelOri:GetValue('DLA_HRPREV', nX) < cMinHr
					cMinDt := oModelOri:GetValue('DLA_DTPREV', nX)
					cMinHr := oModelOri:GetValue('DLA_HRPREV', nX)
				EndIf
			EndIf
		EndIf
	Next nX	
	
	//Verifica linha por linha do Grid de reg. destino para determinar as previs�es.
	For nX := 1 to oModelDes:GetQtdLine()
		If !(oModelDes:IsDeleted(nX))
			If Empty(cMaxDt) .Or.  oModelDes:GetValue('DLL_DTPREV', nX) > cMaxDt
				cMaxDt := oModelDes:GetValue('DLL_DTPREV', nX)
				cMaxHr := oModelDes:GetValue('DLL_HRPREV', nX)
			ElseIf oModelDes:GetValue('DLL_DTPREV', nX) == cMaxDt
				If oModelDes:GetValue('DLL_HRPREV', nX) > cMaxHr
					cMaxDt := oModelDes:GetValue('DLL_DTPREV', nX)
					cMaxHr := oModelDes:GetValue('DLL_HRPREV', nX)
				EndIf
			EndIf	
		EndIf
	Next nX	

	oModel:LoadValue('MASTER_DL8','DL8_QTDPO ', nQtdOri)
	oModel:LoadValue('MASTER_DL8','DL8_QTDPD ', nQtdDes)
	
	//Caso n�o exista regi�es de origem ou destino no Grid, os campos abaixo ficar�o em branco.
	If nQtdOri <> 0
		oModel:LoadValue('MASTER_DL8','DL8_PRVORI', cMinDt) 
		oModel:LoadValue('MASTER_DL8','DL8_HRPROR', cMinHr)
	Else
		oModel:LoadValue('MASTER_DL8','DL8_PRVORI', Ctod("")) 
		oModel:LoadValue('MASTER_DL8','DL8_HRPROR', Space(TamSX3('DL8_HRPROR')[1]))
	EndIf
	
	If nQtdDes <> 0
		oModel:LoadValue('MASTER_DL8','DL8_PRVDES', cMaxDt) 
		oModel:LoadValue('MASTER_DL8','DL8_HRPRDS', cMaxHr)
	Else
		oModel:LoadValue('MASTER_DL8','DL8_PRVDES', Ctod("")) 
		oModel:LoadValue('MASTER_DL8','DL8_HRPRDS', Space(TamSX3('DL8_HRPRDS')[1]))
	EndIf	
	
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} T153ATSLD

@author  Aluizio Fernando Habizenreuter
@since   30/01/2019
@version 1.0
@param oModel - retorna o model ativo.
/*/
//------------------------------------------------------------------

Function T153ATSLD(oModel, lSemMeta)
Local nSaldo := 0
Local nQtd := M->DL8_QTD
Local cSeq := ''
Local nOperation := oModel:GetOperation()

Default lSemMeta := .F.

//Por conta desta fun��o ser chamada na Trigger do campo "DATPRV", e tamb�m na fun��o de Commit, foi necess�ria a implementa��o desta l�gica, 
//pois por mais que se trate do mesmo oModel, as estruturas s�o diferentes de acordo com o ponto onde a fun��o � chamada.
If lSemMeta
	nQtd := (M->DL8_QTD * -1)
Else 	
	If Empty(oModel:GetValue('DL8_DATPRV'))
		If nOperation == MODEL_OPERATION_INSERT
			nQtd := 0
		Else
			If Empty(DL8->DL8_DATPRV)
				nQtd := 0
			Else
				nQtd := (DL8->DL8_QTD * -1)
			EndIf
		EndIf
	Else
		//Via gatilho, tentar buscar uma sequencia de Meta. Caso n�o encontre, setar a quantidade para negativo, para que o Saldo seja atualizado.
		cSeq := TGetSeqDLG(oModel:GetValue("DL8_CRTDMD"), oModel:GetValue("DL8_CODGRD"), oModel:GetValue("DL8_TIPVEI"), oModel:GetValue("DL8_DATPRV"))
		If Empty(cSeq)
			nQtd := (M->DL8_QTD * -1)
		Else
			If nOperation == MODEL_OPERATION_UPDATE .And. !Empty(DL8->DL8_DATPRV) 
				nQtd := nQtd - DL8->DL8_QTD
			EndIf
		EndIf
	EndIF
EndIf
   
nSaldo := TMCalcQtd('SALDO', nQtd, 3)

If lSemMeta
	oModel:SetValue('MASTER_DL8','DL8_SDCTDM',nSaldo)
Else
	oModel:SetValue('DL8_SDCTDM',nSaldo)
EndIf

Return .T.

/*/{Protheus.doc} T153ConsDoc
//Fun��o respons�vel por determinar a exist�ncia de documentos vinculados � demanda e chamar TMSA500 para exibi-los.
@author wander.horongoso
@since 12/02/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function T153ConsDoc()
Local aRet := {}
Local cQuery := ''
Local nX

	aRet := TmsDmdXDoc(DL8->DL8_COD, DL8->DL8_SEQ, , , .F.)
	
	If Len(aRet) == 0
		Help(,,'Help',,STR0069,1,0,,,,,,) //Demanda n�o possui documentos vinculados.
	Else
		For nX := 1 to Len(aRet)
			cQuery += "(DT6_FILDOC = '" + aRet[nX,1] 
			cQuery += "' AND DT6_DOC = '" + aRet[nX,2] 
			cQuery += "' AND DT6_SERIE = '" + aRet[nX,3] + "')"'
			
			iIf (nX < Len(aRet), cQuery += " OR ", "")
	
		Next nX
		
		TMSA500(,,,,,, cQuery)
	EndIf
	
Return nil		

Function TMS153ABrw(cCampo)
Local cQuery := ''
Local cTemp:= GetNextAlias()
Local cDescr := ''

	If cCampo == 'DL8_DESGRD'
	    if !Empty(DL8->DL8_CODGRD)
			cQuery  := " SELECT DLC_DESCRI "
			cQuery  += "   FROM "+RetSqlName('DLC')+ " DLC "
			cQuery  += " WHERE DLC.DLC_FILIAL = '" + xFilial('DLC') + "'" 
			cQuery  += "  	AND DLC.DLC_COD = '"+DL8->DL8_CODGRD+"'" 
  			cQuery  += "    AND DLC.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
		
			cDescr := (cTemp)->DLC_DESCRI
			(cTemp)->(DbCloseArea())
		EndIf
	ElseIf cCampo == 'DL8_NOMDEV'
		 if !Empty(DL8->DL8_CLIDEV) .AND. !Empty(DL8->DL8_LOJDEV)
			cQuery  := " SELECT A1_NOME "
			cQuery  += "   FROM "+RetSqlName('SA1')+ " SA1 "
			cQuery  += " WHERE SA1.A1_FILIAL = '" + xFilial('SA1') + "'" 
			cQuery  += "  	AND SA1.A1_COD = '"+DL8->DL8_CLIDEV+"'" 
			cQuery  += "  	AND SA1.A1_LOJA = '"+DL8->DL8_LOJDEV+"'" 
  			cQuery  += "    AND SA1.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
		
			cDescr := (cTemp)->A1_NOME
			(cTemp)->(DbCloseArea())
		EndIf		
	EndIf

Return cDescr 