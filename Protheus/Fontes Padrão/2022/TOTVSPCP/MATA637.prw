#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'MATA637.CH'
#DEFINE DS_MODALFRAME 128

Static _lNewMRP := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA637
Relacionamento Opera��es x Componentes

@author Samantha Preima
@since 18/02/2015
@version P11

/*/
//-------------------------------------------------------------------
Function MATA637()

	Local oBrowse

	PRIVATE cProduto := ""

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SGF')
	oBrowse:SetDescription( STR0001 ) // "Opera��o X Componente"
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MATA637' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MATA637' OPERATION 3 ACCESS 0    // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MATA637' OPERATION 4 ACCESS 0    // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.MATA637' OPERATION 5 ACCESS 0    // 'Excluir'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructM := FWFormStruct( 1, 'SGF', { |cFld| AllTrim(cFld) + '/' $ 'GF_PRODUTO/GF_ROTEIRO/GF_DSPROD/' } )
Local oStructG := FWFormStruct( 1, 'SGF', { |cFld| !AllTrim(cFld) + '/' $ 'GF_PRODUTO/GF_ROTEIRO/GF_DSPROD/' } )
Local oModel
Local nI := 1
Local nL := 0

oModel := MPFormModel():New('MATA637', /*bPreValidacao*/, { | oMdl | MATA637POS ( oMdl ) }, { | oMdl | MATA637CMM ( oMdl ) }, /*bCancel*/ )

oModel:AddFields( 'SGFMASTER', /*cOwner*/, oStructM )

oModel:AddGrid( 'SGFDETAIL', 'SGFMASTER', oStructG )
oModel:SetRelation( 'SGFDETAIL' , { { 'GF_FILIAL' , 'xFilial( "SGF" )' } , { 'GF_PRODUTO' , 'GF_PRODUTO' } , { 'GF_ROTEIRO' , 'GF_ROTEIRO' }} , SGF->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0007 ) //'Relacionamento Opera��es x Componentes'

oModel:GetModel( 'SGFMASTER' ):SetPrimaryKey( { 'GF_FILIAL','GF_PRODUTO','GF_ROTEIRO'} )

oModel:GetModel( 'SGFDETAIL' ):SetUniqueLine( { 'GF_OPERAC','GF_COMP', 'GF_TRT'})
oModel:GetModel( 'SGFDETAIL' ):SetMaxLine(9999)

oStructM:SetProperty("GF_DSPROD",MODEL_FIELD_INIT	,{|| IF (oModel:GetOperation() == MODEL_OPERATION_INSERT,'',POSICIONE('SB1',1,XFILIAL('SB1')+SGF->GF_PRODUTO,'B1_DESC'))} )

oStructM:SetProperty("GF_ROTEIRO", MODEL_FIELD_NOUPD, .T.)

oStructG:SetProperty("GF_OPERAC"    , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "lVldOpe()"))
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
Local oStructM := FWFormStruct( 2, 'SGF', { |cFld| AllTrim(cFld) + '/' $ 'GF_PRODUTO/GF_ROTEIRO/GF_DSPROD/' } )
Local oStructG := FWFormStruct( 2, 'SGF', { |cFld| !AllTrim(cFld) + '/' $ 'GF_PRODUTO/GF_ROTEIRO/GF_DSPROD/'  })
Local oModel   := FWLoadModel( 'MATA637' )
Local oView

oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_SGF' , oStructM, 'SGFMASTER' )

oView:AddGrid( 'VIEW_DET' , oStructG, 'SGFDETAIL' )

oView:CreateHorizontalBox( 'PAI', 10 )
oView:CreateHorizontalBox( 'FILHO', 90 )

oView:SetOwnerView( 'VIEW_SGF', 'PAI' )
oView:SetOwnerView( 'VIEW_DET', 'FILHO' )

oView:GetViewStruct('VIEW_SGF'):SetProperty('GF_PRODUTO', MVC_VIEW_ORDEM, '01' )
oView:GetViewStruct('VIEW_SGF'):SetProperty('GF_DSPROD', MVC_VIEW_ORDEM, '02' )
oView:GetViewStruct('VIEW_SGF'):SetProperty('GF_ROTEIRO', MVC_VIEW_ORDEM, '03' )

If IsInCallStack("P200Oper")
	oView:AddUserButton(STR0005, "", {|oView| AcaoMenu(1)}, , ,{MODEL_OPERATION_UPDATE}, .T.) //"Alterar"
	oView:AddUserButton(STR0006, "", {|oView| AcaoMenu(2)}, , ,{MODEL_OPERATION_UPDATE}, .T.) //"Excluir"
	oView:SetCloseOnOk({||.T.})
EndIf

Return oView

//-------------------------------------------------------------------
// Exibe lista de ordens de produ��o
//-------------------------------------------------------------------
Function MATA637LIS(aOPGrid)
Local lOk     := .F.
Local oOk     := LoadBitmap( GetResources(), "LBOK" )
Local oNOk    := LoadBitmap( GetResources(), "LBNO" )
Local nI      := 0
Local oSay1
Local oDlgUpd, oBtnCancelar, oBtnAvanca, oTexto, oBtnDetalhar, oList, oCheckBoxOP, oPanel3

Public lToggleCheckBoxOP

DEFINE DIALOG oDlgUpd TITLE STR0008 FROM 0, 0 TO 22, 75 SIZE 550, 350 PIXEL // Ordens de Produ��o

@ 006,005 SAY oSay1 PROMPT STR0037 SIZE 234, 007 OF oDlgUpd  PIXEL

oPanel3 := TPanel():New( 25, 05, ,oDlgUpd, , , , , , 270, 120, .F.,.T. )

oList := TWBrowse():New( 05, 05, 260, 110,,{"",STR0008,"Produto"},,oPanel3,,,,,,,,,,,,.F.,,.T.,,.F.,,,) // "Ordens de Produ��o"

@ 8, 6 CHECKBOX oCheckBoxOP VAR lToggleCheckBoxOP PROMPT "" WHEN PIXEL OF oPanel3 SIZE 015,015 MESSAGE ""
oCheckBoxOP:bChange := {|| MarcaTodos(oList, lToggleCheckBoxOP)}
lToggleCheckBoxOP := .T.

oList:SetArray(aOPGrid)
oList:bLine := {|| {If(aOPGrid[oList:nAT,1],oOk,oNOK),aOPGrid[oList:nAt,2]}}
oList:bLDblClick := {|| aOPGrid[oList:nAt,1] := !aOPGrid[oList:nAt,1], controlCheckAllState(oCheckBoxOP, aOPGrid)}

@ 155,140 BUTTON oBtnCancelar PROMPT STR0010 SIZE 60,14 ACTION oDlgUpd:End() OF oDlgUpd PIXEL // "Cancelar"
@ 155,210 BUTTON oBtnAvanca   PROMPT STR0011 SIZE 60,14 ACTION {|| lOk := .T.,oDlgUpd:End()} OF oDlgUpd PIXEL // "Confirmar"

ACTIVATE DIALOG oDlgUpd CENTER

Return lOk

//---------------------------------------------------------------------
/* Controladora do estado de checkbox */
//---------------------------------------------------------------------
Static Function controlCheckAllState(oCheckBox,aArray)

	Local bSeek := {|x| x[1] == .F. }

	@lToggleCheckBoxOP := If(aScan(aArray, bSeek) > 0, .F., .T.)
	oCheckBox:Refresh()

Return Nil

//-------------------------------------------------------------------
// Quando for alterada a SGF, validar a exist�ncia de Ordens n�o
// Iniciadas que possuam Requisi��es Empenhadas(SD4) e apresentar a
// lista de Ordens destas ordens para sele��o e atualiza��o da SD4.
//-------------------------------------------------------------------
Function MATA637SC2(cProduto,cRoteiro,oModel)
Local lRet      := .T.
Local aOrdens   := {}
Local aOPGrid   := {}
Local nI        := 0
Local lOk       := .F.
Local lIntSFC   := FindFunction('ExisteSFC') .And. ExisteSFC("SC2")
Local lIntgMES  := PCPIntgPPI()
Local lBkpInc   := NIL
Local lBkpAlt   := NIL
Local aAreaC2   := {}
Local aDadosInt := {}
Local nTotal    := 0
Local nSucess   := 0
Local nError    := 0

Private aIntegPPI := {}

dbSelectArea('SC2')
SC2->(dbSetOrder(11))
if SC2->(dbSeek(xFilial('SC2')+cProduto+cRoteiro))
	While SC2->(!EOF()) .AND. SC2->C2_FILIAL == xFilial('SC2') .and. SC2->C2_PRODUTO == cProduto .AND. SC2->C2_ROTEIRO == cRoteiro
		dbSelectArea('SD4')
		SD4->(dbSetOrder(2))
		if SD4->(dbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
			if A650DefLeg(1) .OR. A650DefLeg(2) // Prevista ou em aberto
				aadd(aOrdens,{SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN})
			Endif
		Endif

		SC2->(dbSkip())
	End
Endif

For nI := 1 To Len(aOrdens)
	aAdd(aOPGrid,{.T.,AllTrim(aOrdens[nI][1])})
Next

if Len(aOPGrid) > 0
	lOk := MATA637LIS(aOPGrid)
Endif
// Replicar altera��o
IF lOk
	For nI := 1 to Len(aOPGrid)
		if aOPGrid[nI][1]
			dbSelectArea('SD4')
			SD4->(dbSetOrder(2))
			if SD4->(dbSeek(xFilial('SD4')+aOPGrid[nI][2]))
				While SD4->(!EOF()) .AND. SD4->D4_FILIAL == xFilial('SD4') .AND. alltrim(SD4->D4_OP) == alltrim(aOPGrid[nI][2])
					dbSelectArea('SGF')
					SGF->(dbSetOrder(2))
					if SGF->(dbSeek(xFilial('SGF')+cProduto+cRoteiro+SD4->D4_COD+SD4->D4_TRT))
						RecLock('SD4',.F.)

						SD4->D4_OPERAC  := SGF->GF_OPERAC
						SD4->D4_ROTEIRO := SGF->GF_ROTEIRO
						SD4->D4_PRODUTO := SGF->GF_PRODUTO

						MsUnLock()
					Else
						RecLock('SD4',.F.)

						If Alltrim(cRoteiro) == ''
							SD4->D4_OPERAC  := ''
							SD4->D4_PRODUTO := ''
							SD4->D4_ROTEIRO := ''
						Else
							SD4->D4_OPERAC  := ''
							SD4->D4_ROTEIRO := cRoteiro
						EndIf

						MsUnLock()
					Endif

					if lIntSFC
						dbSelectArea('CYP')
						CYP->(dbSetOrder(3))
						IF CYP->(dbSeek(xFilial('CYP')+Padr(SD4->D4_OP,TamSx3('CYP_NRORPO')[1])+SD4->D4_COD+SD4->D4_TRT))
							RecLock('CYP',.F.)

							CYP->CYP_CDAT := SD4->D4_OPERAC
							CYP->CYP_CDRT := SD4->D4_ROTEIRO

							MsUnLock()
						Endif
					Endif

					SD4->(dbSkip())
				End
			Endif
			If lIntgMES
				//Realiza a integra��o TOTVS MES
				aAreaC2 := SC2->(GetArea())
				dbSelectArea("SC2")
				SC2->(dbSetOrder(1))
				lBkpAlt := oModel:GetOperation() == MODEL_OPERATION_UPDATE
				lBkpInc	:= oModel:GetOperation() == MODEL_OPERATION_INSERT
				SC2->(dbSeek(xFilial("SC2")+aOPGrid[nI][2]))
				If PCPFiltPPI("SC2", SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"SC2")
					nTotal++
					If mata650PPI(, SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), .T., .T., .F., .F.)
						nSucess++
						aAdd(aDadosInt, {SG2->G2_PRODUTO, STR0025, STR0024}) //"OK" "Processado com sucesso"
					Else
						nError++
					EndIf
				EndIf
				SC2->(RestArea(aAreaC2))
				INCLUI  := lBkpInc
				ALTERA  := lBkpAlt
			EndIf
		Endif
	Next
Endif

If lIntgMES
   If Len(aIntegPPI) > 0
		For nI := 1 To Len(aIntegPPI)
			aAdd(aDadosInt, {aIntegPPI[nI,1], STR0033, StrTran(aIntegPPI[nI,2],CHR(10)," ")}) //"Erro"
		Next nI
		erroPPI(aDadosInt, nTotal, nSucess, nError)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
// MATA637CMM - Commit
//-------------------------------------------------------------------
Static Function MATA637CMM(oModel)
Local aMRPxJson
Local lRet       := .T.
Local nOpc       := oModel:GetOperation()
Local cProduto   := oModel:GetValue('SGFMASTER','GF_PRODUTO')
Local cRoteiro   := oModel:GetValue('SGFMASTER','GF_ROTEIRO')
Local lIntgMES   := PCPIntgPPI()
Local lIntNewMRP := FindFunction("Ma637MrpOn") .AND. FWAliasInDic( "HW9", .F. )

Begin Transaction

	//Chama a fun��o MRPIntOp, para caso a integra��o esteja configurada
	//para ser online, j� crie a tabela tempor�ria utilizada
	//na gera��o das pend�ncias.
	If lIntNewMRP
		aMRPxJson  := {{}, JsonObject():New()} //{aDados para commit, JsonObject() com RECNOS} - Integracao Novo MRP
		IntegraMRP(oModel, @aMRPxJson, .T., .F.) //DELETE
	EndIf

	//Salva os campos padr�es do model
	FWFormCommit( oModel )

	if nOpc == 4 .Or. nOpc == 3
		MATA637SC2(cProduto, cRoteiro, oModel)
	Endif

	If lIntgMES
		SG1->(dbSetOrder(1))
		If SG1->(dbSeek(xFilial("SG1")+cProduto))
			Altera := .T.
			Inclui := .F.
			lRet := MATA200PPI(, cProduto, .F., .T., .F.)
			Altera := .F.
			Inclui := .F.
			If !lRet
				DisarmTransaction()
			EndIf
		EndIf
	EndIf

	If lRet .AND. lIntNewMRP
		IntegraMRP(oModel, @aMRPxJson)  //INSERT
	EndIf

End Transaction

Return lRet

//-------------------------------------------------------------------
// MATA637POS - VALIDA��ES
//-------------------------------------------------------------------
Static Function MATA637POS(oModel)
Local lRet      := .T.
Local oModelMAS := oModel:GetModel('SGFMASTER')
Local oModelDET := oModel:GetModel('SGFDETAIL')
Local nI        := 0
Local nJ        := 0
Local nOpc      := oModel:GetOperation()
Local cPRODUTO  := oModelMAS:GetValue('GF_PRODUTO')
Local cROTEIRO  := oModelMAS:GetValue('GF_ROTEIRO')
Local aLista    := {}

if nOpc == 3 .OR. nOpc == 4
	IF nOpc == 3
		// N�o deixar incluir produto + roteiro que j� existe
		dbSelectArea('SGF')
		SGF->(dbSetOrder(1))
		IF SGF->(dbSeek(xFilial('SGF')+cPRODUTO+cROTEIRO))
			Help( ,, 'HELP', 'MATA637REGREP', , 1, 0) // J� existe com produto e roteiro informados

			lRet := .F.
		Endif
	Endif

	if lRet
		lRet := MATA638PAI(cProduto, cRoteiro)

		// Verificar se existe opera��o para produto + roteiro
		For nI := 1 to oModelDET:GetQtdLine()
			oModelDET:GoLine(nI)

			if !oModelDET:IsDeleted()
				lRet := MATA638FIL(cProduto, cRoteiro, oModelDET:GetValue('GF_OPERAC'), oModelDET:GetValue('GF_COMP'),oModelDET:GetValue('GF_TRT'))

				if !lRet
					Exit
				Endif

				aadd(aLista, {oModelDET:GetValue('GF_OPERAC'),oModelDET:GetValue('GF_COMP'),oModelDET:GetValue('GF_TRT')})
			Endif
		Next
	Endif

	// Valida se o componente � usado em apenas uma opera��o
	if lRet
		For nI := 1 to len(aLista)

			For nJ := 1 to len(aLista)
				if nI != nJ
					if aLista[nI][2] == aLista[nJ][2] .AND. aLista[nI][3] == aLista[nJ][3]
						Help( ,, 'HELP', 'MATA637OUTOPE', , 1, 0) // 'Componente j� est� sendo usado em outra opera�ao'

						lRet := .F.

						Exit
					Endif
				Endif
			Next nJ

			if !lRet
				Exit
			Endif
		Next nI
	Endif
Endif

Return lRet

/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 �A635BxComp    � Autor � Marcelo Iuspa       � Data � 10-07-03 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna componentes a serem baixados de determinada operacao ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cProduto  = Produto a ser pesquisado                         ���
���          � cRoteiro  = Roteiro de producao do produto                   ���
���          � cOperacao = Operacao a ser pesquisada                        ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � MatA635                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A637BxComp(cProduto, cRoteiro, cOperacao, cOP)
Local aComp   := Nil
Local aSavAre := {SD4->(GetArea()), GetArea()}
Local cAlias  := GetNextAlias()
Local cFilSD4 := xFilial("SD4")
Local cQuery  := ""
Local cTabSD4 := RetSqlName("SD4")

cQuery := "SELECT SD4.D4_COD, SD4.D4_TRT "
cQuery += "  FROM " + cTabSD4 + " SD4 "
cQuery += " WHERE SD4.D4_FILIAL = ? AND "
If !Empty(cOP)
	cQuery += "   SD4.D4_OP = ? AND "
EndIf
cQuery += "       SD4.D4_PRODUTO = ? AND "
cQuery += "       SD4.D4_ROTEIRO = ? AND "
cQuery += "       SD4.D4_OPERAC  = ? AND "
cQuery += "       SD4.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)

oPrepSD4 := FWPreparedStatement():New(cQuery) //Construtor da carga.

oPrepSD4:SetString(1, cFilSD4) //Seta um par�metro na query via String.

If !Empty(cOP)
	oPrepSD4:SetString(2, cOP)
	oPrepSD4:SetString(3, cProduto)
	oPrepSD4:SetString(4, cRoteiro)
	oPrepSD4:SetString(5, cOperacao)
Else
	oPrepSD4:SetString(2, cProduto)
	oPrepSD4:SetString(3, cRoteiro)
	oPrepSD4:SetString(4, cOperacao)
EndIf

cQuery := oPrepSD4:GetFixQuery() //Retorna a query com os par�metros j� tratados e substitu�dos.
cAlias := MPSysOpenQuery(cQuery, cAlias) //Abre um alias com a query informada.

If (cAlias)->(!Eof())
	aComp := {}
EndIf

While (cAlias)->(!Eof())
	Aadd(aComp, {(cAlias)->D4_COD, (cAlias)->D4_TRT})
	(cAlias)->(dbSkip())
EndDo

dbSelectArea(cAlias)
(cAlias)->(dbCloseArea())

RestArea(aSavAre[1])
RestArea(aSavAre[2])
Return(aComp)

Function A637SEEK()

dbSelectArea("SG1")
dbSetOrder(1)

dbseek(xFilial("SG1")+FWFLDGET("GF_PRODUTO"))

Return .T.

/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 �A635SeleOperac� Autor � Marcelo Iuspa       � Data � 02-06-03 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Apresenta tela de consulta ao tecla F4 ou botoes             ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cProduto = Produto a ser pesquisado                          ���
���          � cRoteiro = Roteiro de Operacoes a ser pesquisado             ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � MatA635                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A637SeleOperac(cProduto, cRoteiro, lAtuAcols, bInit, cComp, cTRT)
Local lOk    	:= .F.
Default cRoteiro := ""

lOk := A637Consulta(cProduto,cComp,cTRT)

Return(lOk)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �A637Consulta� Autor � Marcelo Iuspa       � Data � 02-06-03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Apresenta uma tela para selecao de registro                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cTitulo = Titulo da Janela                                 ���
���          � cAlias  = Alias a ser pesquisado                           ���
���          � cSeek   = Expressao do Seek (nao precisa xFilial)          ���
���          � bWhile  = Expressao para avaliar final do loop             ���
���          � aFields = Campos que serao mostrados no browse             ���
���          � bInit   = Bloco para avaliar qual registro sera posicionado���
���          � bFor    = Bloco para filtrar registros que serao exibidos  ���
���          � aCompFant= Array de comparacao para produto fantasma       ���
���          � nIndexOrd = Ordem do indice do alias a ser pesquisado      ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � MatA635													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A637Consulta(cProduto,cComp,cTRT)
Local oDlg		 // Dialog
Local oBox       // Listbox
Local lOk     := .F.
Local aRegs   := {}
Local aHeaLis := {}
Local nSeek   := 0
Local nCount  := 0
Local nFields := 0
Local nRegs   := 1
Local aFields := {'GF_ROTEIRO','GF_OPERAC','G2_DESCRI','GF_COMP','GF_TRT','G2_RECURSO'}
Local nI       := 1
Local lDel     := .F.
Private aList    := {}
Private aListDel := {}

aEval(aFields, {|z| Aadd(aHeaLis, RetTitle(z))})
Aadd(aFields)

nFields := Len(aFields)
aFields[nFields] := "RecNo"

CursorWait()

dbSelectArea('SGF')

SGF->(dbSetOrder(1))
SGF->(dbSeek(xFilial('SGF') + cProduto))

For nI := 1 to len(aRegsSGF)
	If aRegsSGF[nI][1] == cProduto
		dbSelectArea("SG2")
		SG2->(dbSetOrder(1))
		SG2->(dbSeek(xFilial('SG2') + cProduto + aRegsSGF[nI][2] + aRegsSGF[nI][3]))
		Aadd(aList, {aRegsSGF[nI][2], aRegsSGF[nI][3], SG2->G2_DESCRI, aRegsSGF[nI][4],aRegsSGF[nI][5],SG2->G2_RECURSO,3})
	Endif
Next

dbSelectArea("SGF")

While SGF->(!Eof() .And. SGF->GF_FILIAL == xFilial('SGF') .AND. SGF->GF_PRODUTO == cProduto)

	//If SGF->GF_TRT == cTRT

		lDel := .F.

		// Verifica se o registro j� foi marcado como eliminado
		If Len(aRegsSGFdel) > 0
			For nI := 1 to Len(aRegsSGFdel)
				if aRegsSGFdel[nI][1] == cProduto .AND.;
				   aRegsSGFdel[nI][2] == SGF->GF_ROTEIRO .AND.;
				   aRegsSGFdel[nI][3] == SGF->GF_OPERAC .AND.;
				   aRegsSGFdel[nI][4] == SGF->GF_COMP .And. ;
				   aRegsSGFDel[nI][5] == SGF->GF_TRT

				   lDel := .T.
				Endif
			Next
		Endif

		If !lDel
			Aadd(aRegs, SGF->(RecNo()))

			dbSelectArea("SG2")
			SG2->(dbSetOrder(1))
			SG2->(dbSeek(xFilial('SG2') + cProduto + SGF->GF_ROTEIRO + SGF->GF_OPERAC))

			IF aScan(aList, {|x| x[1]==SGF->GF_ROTEIRO .And. x[2]==SGF->GF_OPERAC .And. x[4]==SGF->GF_COMP .And. x[5]==SGF->GF_TRT}) == 0
				Aadd(aList, {SGF->GF_ROTEIRO, SGF->GF_OPERAC, SG2->G2_DESCRI, SGF->GF_COMP, SGF->GF_TRT, SG2->G2_RECURSO, SGF->(RecNo()),0})
			EndIf

			dbSelectArea("SGF")

			nRegs := nRegs + 1
		Endif
	//Endif
	SGF->(dbSkip())
End

If Len(aList) == 0
	aadd(aList,{'','','','','','',0})
Endif

DEFINE MSDIALOG oDlg TITLE STR0012 FROM 00,00 TO 300,700 PIXEL OF oMainWnd STYLE DS_MODALFRAME // 'Opera��es x Componentes'

	//@ 02,02 TO 120,210 LABEL "" PIXEL OF oDlg
	oBox := TWBrowse():New( 05, 04, 315, 135,{|| {NOSCROLL } },aHeaLis,, oDlg,,,,{|| nSeek:= oBox:nAt},,,,,,,, .F.,, .T.,, .F.,,, )
	oBox:SetArray(aList)
	oBox:bLine:={|| aList[oBox:nAt] }
	oBox:Refresh()
	If nSeek > 0
		oBox:nAt := nSeek
	Endif
	DEFINE SBUTTON FROM 05,325 TYPE 4 ENABLE OF oDlg ACTION (A637FIELDS(3,cProduto, PadR(' ',TamSx3('GF_ROTEIRO')[1]) , PadR(' ',TamSx3('GF_OPERAC')[1]), cComp, cTRT,),oBox:SetArray(aList), oBox:bLine:={|| aList[oBox:nAt] }, oBox:Refresh())
	DEFINE SBUTTON FROM 25,325 TYPE 3 ENABLE OF oDlg ACTION (A637FIELDS(5,cProduto, aList[oBox:nAt][1], aList[oBox:nAt][2], aList[oBox:nAt][4], aList[oBox:nAt][5], oBox:nAt),oBox:SetArray(aList), oBox:bLine:={|| aList[oBox:nAt] }, oBox:Refresh())
	DEFINE SBUTTON FROM 45,325 TYPE 1 ENABLE OF oDlg ACTION (lOk:=.T.,oDlg:End())
	//DEFINE SBUTTON FROM 65,325 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

	oDlg:lEscClose := .F.
ACTIVATE MSDIALOG oDlg CENTERED

/*aRegsSGF := {}

For nI := 1 to Len(aList)
	If aList[nI][6] <> ''
	    dbSelectArea("SG2")
		SG2->(dbSetOrder(1))
		SG2->(dbSeek(xFilial('SG2') + cProduto + aList[nI][1] + aList[nI][2]))

		AADD(aRegsSGF,{cProduto,aList[nI][1],aList[nI][2],aList[nI][4],cTRT})
	Endif
Next*/

Return(lOk)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �A635VldGrava� Autor � Marcelo Iuspa       � Data � 02-06-03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida, pede confirmacao ao usuario e grava dados no SGF   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto    = Produto PAI                                  ���
���          � cRoteiro    = Roteiro de Operacoes                         ���
���          � cOperac     = Operacao                                     ���
���          � cComponente = Componente da estrutura                      ���
���          � cSequencia  = Sequencia do componente                      ���
���          � lGrava      = Inclusao no SGF caso valido                  ���
���          � lConfirma   = Exibe tela para usuario confirmar inclusao   ���
���          � bEval       = Bloco executado se validado                  ���
���          � lAcols      = Testa duplicidade no aCols                   ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � MatA635													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A637VldGrava(cProduto, cRoteiro, cOperac, cComponente, cSequencia, lGrava, lConfirma, bEval, lAcols, nAcao)
Local aSavAre  := {SGF->(IndexOrd()), SGF->(RecNo()), Alias()}
Local lRet     := .T.
Local oModel638

Default nAcao := 3

If nAcao = 3
	oModel638 := FwLoadModel('MATA638')
	oModel638:SetOperation(3)
	oModel638:Activate()

	oModel638:SetValue('SGFMASTER','GF_PRODUTO', cProduto)
	oModel638:SetValue('SGFMASTER','GF_ROTEIRO', cRoteiro)
	oModel638:SetValue('SGFMASTER','GF_OPERAC' , cOperac)
	oModel638:SetValue('SGFMASTER','GF_COMP'   , cComponente)
	oModel638:SetValue('SGFMASTER','GF_TRT'    , cSequencia)

	If lGrava
		If oModel638:VldData()
			oModel638:CommitData()
		Else
			lRet := .F.
			msginfo(STR0013 + oModel638:GetErrorMessage()[6]) // 'N�o foi poss�vel criar relacionamento componentes x opera��es: '
		EndIf
	Else
		IF aScan(aList, {|x| x[1]==cRoteiro .And. x[4]==cComponente .And. x[5]==cSequencia}) != 0
			Help(" ",1,"A635MOPE",, AllTrim(RetTitle("GF_COMP")) + ": " + RTrim(cComponente) + cSequencia, 4, 0) //O produto ja esta definido para esta operacao deste mesmo roteiro
			lRet := .F.
		EndIf
	Endif

	dbSetOrder(aSavAre[1])
	dbGoto(aSavAre[2])
	dbSelectArea(aSavAre[3])
EndIf

Return(lRet)

/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � A635VldFan   � Autor � Andre Anjos		  � Data � 10/11/08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida utilizacao de componente fantasma e atualiza variaveis���
���			 � da tela para correta gravacao							    ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cComp = Componente a ser validado							���
���������������������������������������������������������������������������Ĵ��
���Retorno	 � lRet: Prossegue ou nao			                            ���
���������������������������������������������������������������������������Ĵ��
���Uso		 � MATA635                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function A635VldFan(cComp,cRoteiro,cOperac,cProduto,cComponente,cSequencia)
Local lRet := .T.

Default cRoteiro := ""
Default cOperac := ""
Default cProduto := ""
Default cComponente := ""
Default cSequencia := ""

If SB1->(dbSeek(xFilial("SB1")+cComp)) .And. RetFldProd(SB1->B1_COD,"B1_FANTASM") == "S" // Projeto Implementeacao de campos MRP e FANTASM no SBZ
	lRet := Aviso(STR0014, STR0015 + Trim(cComp) + STR0016 +" " + STR0017, {STR0018,STR0019}) == 1 // "Aten��o" ## "O produto " ## " � um componente fantasma dentro da estrutura." ## "Confirma inclus�o?" ## "Sim" ## "N�o"
EndIf

If !Empty(cRoteiro+cOperac+cProduto+cComponente+cSequencia)
	cRoteiro := M->GF_ROTEIRO
	cOperac := M->GF_OPERAC
	cProduto := M->GF_PRODUTO
	cComponente := M->GF_COMP
	cSequencia := M->GF_TRT
EndIf

Return lRet


//---------------------------------------------------------------------------
// Tela de atualiza��o de SGF
//---------------------------------------------------------------------------
Static Function A637FIELDS(cAcao, cProduto, cRoteiro, cOperac, cComponente, cSequencia,nPos)
Local aAlter := {'GF_OPERAC','GF_ROTEIRO'}
Local lOk    := .T.
Local nI     := 0

RegToMemory("SGF", .T.) // Caso o cliente tenha campos criados no SGF
DEFINE MSDIALOG oDlg TITLE STR0020 Of oMainWnd PIXEL FROM 0,0 TO 280,600 // 'Manuten��o Componentes x Opera��es'

	M->GF_ROTEIRO := cRoteiro
	M->GF_OPERAC  := cOperac
	M->GF_PRODUTO := cProduto
	M->GF_COMP    := cComponente
	M->GF_TRT     := cSequencia

	MsmGet():New( "SGF",,cAcao,,,,{'GF_ROTEIRO','GF_OPERAC','GF_PRODUTO','GF_COMP','GF_TRT'}, {35, 04, (oDlg:nHeight * .5)-15,(oDlg:nWidth *.5)-4},aAlter,,,,,,,.T.)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(If(lOk := A635VldFan(M->GF_COMP,@cRoteiro,@cOperac,@cProduto,@cComponente,@cSequencia),;
	                                                         If(A637VldGrava(M->GF_PRODUTO,M->GF_ROTEIRO,M->GF_OPERAC, M->GF_COMP, M->GF_TRT, .F., .F.,/*08*/,/*09*/,cAcao),oDlg:End(), ), ))},{|| lOk := .F., oDlg:End()})  //"Confirma Inclusao"

IF lOk
	If cAcao == 3
		If Len(aList) == 1 .AND. Empty(aList[1][1])
			aList := {}
		Endif

		dbSelectArea("SG2")
		SG2->(dbSetOrder(1))
		SG2->(dbSeek(xFilial('SG2') + cProduto + M->GF_ROTEIRO + M->GF_OPERAC))

		AADD(aList,{M->GF_ROTEIRO,M->GF_OPERAC,SG2->G2_DESCRI,M->GF_COMP,M->GF_TRT,SG2->G2_RECURSO,3})
		AADD(aRegsSGF,{cProduto,M->GF_ROTEIRO,M->GF_OPERAC,M->GF_COMP,cSequencia,nPos})

		dbSelectArea("SGF")
	Else

		nI := aScan(aRegsSGF, {|x| x[1] == cProduto .And. x[2] == cRoteiro .And. x[3] == cOperac .And. x[4] == cComponente .And. x[5] == cSequencia})
		If nI > 0
			aDel(aRegsSGF,nI)
			ASIZE(aRegsSGF,Len(aRegsSGF) - 1)
		Else

			AADD(ARegsSGFdel,{cProduto,cRoteiro,cOperac,cComponente,cSequencia,nPos})

		EndIf

		aDel(aList,nPos)
		ASIZE(aList,Len(aList) - 1)

		if Len(aList) == 0
			aadd(aList,{'','','','','','',0})
		Endif
	Endif
Endif

Return .T.

//---------------------------------------------------------------------------
// Elimina registros de SGF
//---------------------------------------------------------------------------
Function A637VLDDel(aDel)
Local nI := 0
Local oModel638 := FwLoadModel('MATA638')
Local lRet := .T.

dbSelectArea('SGF')
SGF->(dbSetOrder(1))

For nI := 1 to Len(aDel)
	IF SGF->(dbSeek(xFilial('SGF')+aDel[nI][1]+aDel[nI][2]+aDel[nI][3]+aDel[nI][4]+aDel[nI][5]))

		oModel638:SetOperation(5)
		oModel638:Activate()

		if oModel638:VldData()
			oModel638:CommitData()
		Else
			lRet := .F.
			Msginfo(oModel638:GetErrorMessage[6])
		Endif

		oModel638:DeActivate()
	Endif
Next

Return lRet

//---------------------------------------------------------------------
/* A fun��o ter� comportamento de toggle se o lFixedBool n�o foi informado.*/
//---------------------------------------------------------------------
Static Function MarcaTodos( oBrw, lFixedBool )

	Local bSeek := {|x| x[1] == .F. }
	Local lSet  := .F.

	Default lFixedBool := Nil

	If lFixedBool != Nil
		lSet := lFixedBool
	ElseIf aScan(@oBrw:aArray, bSeek) > 0
		lSet := .T.
	EndIf

	aEval(@oBrw:aArray, {|x| x[1] := lSet})
	oBrw:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA637SG2()
Fun��o de consulta padr�o SG2001

@author  Lucas Konrad Fran�a
@version P118
@since   24/02/2016
/*/
//-------------------------------------------------------------------
Function MATA637SG2()
   Local oDlg, oLbx
   Local aCpos  := {}
   Local aRet   := {}
   Local cQuery := ""
   Local cAlias := GetNextAlias()
   Local lRet   := .F.
   Local oModel    := FWModelActive()

   cQuery := " SELECT DISTINCT SG2.G2_CODIGO, SG2.G2_PRODUTO "
   cQuery +=   " FROM " + RetSqlName("SG2") + " SG2 "
   cQuery +=  " WHERE SG2.D_E_L_E_T_ = ' ' "
   cQuery +=    " AND SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "

	If IsInCallStack("P200Oper")
		If !Empty(SG1->G1_COD)
			cQuery += " AND SG2.G2_PRODUTO = '" + SG1->G1_COD + "' "
		EndIf
	ElseIf oModel != Nil .And. oModel:cID == "PCPA124"
		cProduto  := oModel:GetModel("PCPA124_CAB"):GetValue("G2_PRODUTO")
		If !Empty(cProduto)
			cQuery += " AND SG2.G2_PRODUTO = '" + cProduto + "' "
		EndIf
	Else
		If !Empty(M->GF_PRODUTO)
			cQuery += " AND SG2.G2_PRODUTO = '" + M->GF_PRODUTO + "' "
		EndIf
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

   DEFINE MSDIALOG oDlg TITLE STR0021 /*"Roteiro de opera��es"*/ FROM 0,0 TO 240,500 PIXEL

     @ 10,10 LISTBOX oLbx FIELDS HEADER STR0022 /*"Roteiro"*/, STR0023 /*"Produto"*/  SIZE 230,95 OF oDlg PIXEL

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
        SG2->(dbSeek(xFilial("SG2")+aRet[2]+aRet[1]))
		If oModel != Nil .And. oModel:cID == "PCPA124"
			If Empty(cProduto)
				oModel:SetValue("G2_CODIGO",aRet[2])
			EndIf
		else
			If Empty(M->GF_PRODUTO)
				M->GF_PRODUTO := aRet[2]
			EndIf
		EndIf
     EndIf
  EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} erroPPI

Exibe uma tela com as mensagens de erro que aconteceram durante a integra��o

@param aDadosInt - Array com as informa��es dos erros.
@param nTotal	    - Quantidade total de registros processados.
@param nSucess   - Quantidade de registros processados com sucesso.
@param nError    - Quantidade de registros processados com erro.

@author  Lucas Konrad Fran�a
@version P118
@since   11/04/2016
@return  Nil
/*/
//-------------------------------------------------------------------------------------------------
Static Function erroPPI(aDadosInt, nTotal, nSucess, nError)
	Local oDlgErr, oPanel, oBrwErr, oGetTot, oGetErr, oGetSuc
	Local aCampos := {}
	Local aSizes  := {}

	DEFINE MSDIALOG oDlgErr TITLE STR0026 FROM 0,0 TO 350,800 PIXEL //"Erros integra��o TOTVS MES"

	oPanel := tPanel():Create(oDlgErr,01,01,,,,,,,401,156)
	//Cria o array dos campos para o browse
	aCampos := {STR0027,STR0028,STR0029} //"Ordem de produ��o" / "Status" / "Mensagem"
	aSizes  := {80, 30, 400}

	// Cria Browse
	oBrwErr := TCBrowse():New( 0 , 0, 400, 155,,;
	                           aCampos,aSizes,;
	                           oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	// Seta vetor para a browse
	oBrwErr:SetArray(aDadosInt)
	oBrwErr:bLine := {||{ aDadosInt[oBrwErr:nAT,1],;
	                      aDadosInt[oBrwErr:nAt,2],;
	                      aDadosInt[oBrwErr:nAt,3]}}
	oPanel:Refresh()
	oPanel:Show()

	@ 162,02 Say STR0030 Of oDlgErr Pixel //"Total de registros:"
	@ 160,48 MSGET oGetTot VAR nTotal SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.

	@ 162,90 Say STR0031 Of oDlgErr Pixel //"Processados com erro:"
	@ 160,150 MSGET oGetErr VAR nError SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.

	@ 162,190 Say STR0032 Of oDlgErr Pixel //"Processados com sucesso:"
	@ 160,260 MSGET oGetSuc VAR nSucess SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.

	DEFINE SBUTTON FROM 160,373 TYPE 1 ACTION (oDlgErr:End()) ENABLE OF oDlgErr
	ACTIVATE DIALOG oDlgErr CENTERED

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA637SG1()
Fun��o de consulta padr�o SG1GF2

@author  Ricardo Prandi
@version P118
@since   02/06/2016
/*/
//-------------------------------------------------------------------
Function MATA637SG1()
Local oDlg, oLbx
Local aCpos  := {}
Local aRet   := {}
Local cQuery := ""
Local cAlias := GetNextAlias()
Local lRet   := .F.
Local aArea  := GetArea()

cQuery :=  " SELECT DISTINCT SG1.G1_TRT, SG1.G1_COMP, SG1.G1_QUANT, SB1.B1_DESC"
cQuery +=  " FROM " + RetSqlName("SG1") + " SG1 "
cQuery +=  " INNER JOIN " + RetSqlName("SB1") + ' SB1 '
cQuery +=  " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery +=  " AND SG1.G1_COMP = SB1.B1_COD "
cQuery +=  " AND SB1.D_E_L_E_T_ = ' ' "
cQuery +=  " WHERE SG1.D_E_L_E_T_ = ' ' "
cQuery +=  " AND SG1.G1_FILIAL  = '" + xFilial("SG1") + "' "
If !Empty(M->GF_PRODUTO)
	cQuery += " AND SG1.G1_COD = '" + M->GF_PRODUTO + "' "
EndIf
cQuery += " ORDER BY 2, 1 "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

While (cAlias)->(!Eof())
	Aadd(aCpos,{(cAlias)->(G1_TRT), (cAlias)->(G1_COMP), (cAlias)->(B1_DESC), (cAlias)->(G1_QUANT)})
	(cAlias)->(dbSkip())
End

(cAlias)->(dbCloseArea())

If Len(aCpos) < 1
	aAdd(aCpos,{" "," ",0})
EndIf

DEFINE MSDIALOG oDlg TITLE STR0034 /*"Estrutura de produto"*/ FROM 0,0 TO 240,600 PIXEL

@ 10,10 LISTBOX oLbx FIELDS HEADER STR0035 /*"Sequ�ncia"*/, STR0023 /*"Produto"*/, STR0039 /*"Descri��o"*/, STR0036 /*"Quantidade"*/ SIZE 285,95 OF oDlg PIXEL

oLbx:SetArray( aCpos )
oLbx:bLine := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4]}}
oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]}}}

DEFINE SBUTTON FROM 107,265 TYPE 1 ACTION (oDlg:End(), lRet:= .T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]}) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

If Len(aRet) > 0 .And. lRet
	If Empty(aRet[2])
    	lRet := .F.
    Else
    	SG1->(dbSetOrder(1))
        SG1->(dbSeek(xFilial("SG1")+M->GF_PRODUTO+aRet[2]+aRet[1]))
    EndIf
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} AcaoMenu
Execu��o das a��es do Menu
@author Carlos Alexandre da Silveira
@since 16/04/2019
@version P12
@return Nil
@param nOpc, numeric, a��es:
1 - Alterar registro
2 - Excluir registro
@return Nil
/*/
Static Function AcaoMenu(nOpc)
	Local oModel	:= FwModelActive()
	Local oView		:= FwViewActive()

	If nOpc == 1 //Alterar
		oModel:GetModel("SGFDETAIL"):SetNoInsertLine(.F.)
		oModel:GetModel("SGFDETAIL"):SetNoUpdateLine(.F.)
		oModel:GetModel("SGFDETAIL"):SetNoDeleteLine(.F.)
		oView:oControlBar:cTitle := STR0007 + " - " + STR0005 //"Relacionamento Opera��es x Componentes" - "Alterar"
	ElseIf nOpc == 2 //Excluir
		If ApMsgYesNo(STR0038,STR0006) // Deseja excluir todos os relacionamentos? // Excluir
			oModel:DeActivate()
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			oView:SetOperation(5)
			oModel:Activate()
			oView:ButtonOkAction(.T.)

			oModel:DeActivate()
			oModel:SetOperation(MODEL_OPERATION_VIEW)
			oModel:Activate()

			oView:SetOperation(1)
			oView:DeActivate()
			oView:Activate()
		EndIf
	EndIf

Return

/*/{Protheus.doc} IntegraMRP
Integra as opera��es por componente com o MRP

@type  Static Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param 01 - oModel     , objeto, modelDef da MATA637
@param 02 - aMRPxJson  , Array , Array com os dados para enviar
@param 03 - lDelete    , l�gico, indica se deve considerar a dele��o de todos os registros
@param 04 - lCommit    , l�gico, indica se deve realizar o commit das altera��es
@return Nil
/*/

Static Function IntegraMRP(oModel, aMRPxJson, lDelete, lCommit)

	Local aAreaAtu   := GetArea()
	Local lIntegra   := Ma637MrpOn(@_lNewMRP)
	Local oMdlMaster := oModel:GetModel("SGFMASTER")
	Local oMdlGrid   := oModel:GetModel("SGFDETAIL")
	Local nTotal     := oMdlGrid:Length(.F.)
	Local nInd       := 0
	Local nRecno     := 0
	Local cChave     := ""
	Local cChvMaster

	Default lDelete  := oModel:GetOperation() == MODEL_OPERATION_DELETE
	Default lCommit  := .T.

	//Integra��o de OPs filhas com o novo MRP. Carrega os dados para enviar
	If lIntegra .AND. nTotal > 0
		cChvMaster := oMdlMaster:GetValue("GF_PRODUTO") + oMdlMaster:GetValue("GF_ROTEIRO")
		dbSelectArea("SGF")
		SGF->(DbSetOrder(1)) //GF_FILIAL+GF_PRODUTO+GF_ROTEIRO+GF_OPERAC+GF_COMP+GF_TRT
		For nInd := 1 to nTotal
			nRecno := oMdlGrid:GetDataID(nInd)
			If nRecno > 0
				SGF->(DbGoTo(nRecno))

			ElseIf oMdlGrid:IsDeleted(nInd)
				Loop

			Else
				cChave := oMdlGrid:GetValue("GF_FILIAL" , nInd)
				cChave := Iif(Empty(cChave), xFilial("SGF"), cChave)
				cChave += cChvMaster
				cChave += oMdlGrid:GetValue("GF_OPERAC" , nInd)
				cChave += oMdlGrid:GetValue("GF_COMP"   , nInd)
				cChave += oMdlGrid:GetValue("GF_TRT"    , nInd)

				If !SGF->(DbSeek(cChave))
					Loop
				EndIf
			EndIf

			//Inclui dados no array para integra��o com o novo MRP
			If oMdlGrid:IsDeleted(nInd) .OR. lDelete
				A637AddJIn(@aMRPxJson, "DELETE")
			Else
				A637AddJIn(@aMRPxJson, "INSERT")
			EndIf
		Next

		If lCommit .AND. aMRPxJson != Nil .and. Len(aMRPxJson[1]) > 0
			MATA637INT("INSERT", aMRPxJson[1], , , , lDelete)
			aSize(aMRPxJson[1], 0)
			FwFreeObj(aMRPxJson[2])
			aMRPxJson[2] := Nil
		EndIf
	EndIf

	RestArea(aAreaAtu)
Return

/*/{Protheus.doc} lVldOpe
Fun��o de Valida��o do campo "Opera��o"
@type  Function
@author bruno.bernardo
@since 01/09/2020
@version P12
@return lRet
/*/
Function lVldOpe()

	Local lRet := .T.
	
	lRet := ExistCpo("SG2",FwFldGet("GF_PRODUTO")+FwFldGet("GF_ROTEIRO")+FwFldGet("GF_OPERAC"))
	
Return lRet
