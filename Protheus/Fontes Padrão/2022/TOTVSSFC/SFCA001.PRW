#INCLUDE "SFCA001.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#DEFINE PULALINHA CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA001
Tela de cadastro de Centro de Trabalho

@author Tiago Gauziski
@since 12/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA001()
Local oBrowse

SFCValInt(.T.) // Verifica integração ligada
                     
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CYI')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Centro de Trabalho'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.SFCA001' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.SFCA001' OPERATION 3 ACCESS 0  // 'Incluir'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.SFCA001' OPERATION 4 ACCESS 0  // 'Alterar'
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.SFCA001' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.SFCA001' OPERATION 8 ACCESS 0  // 'Imprimir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.SFCA001' OPERATION 9 ACCESS 0  // 'Copiar'
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYI := FWFormStruct( 1, 'CYI', /*bAvalCampo*/,/*lViewUsado*/ ) 
Local oModel    

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SFCA001', /*bPreValidacao*/, { | oMdl | SFCA001POS ( oMdl ) }, { | oMdl | SFCA001CMM ( oMdl ) }, /*bCancel*/ )

AddTempFld(@oStructCYI)

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYIMASTER', /*cOwner*/, oStructCYI, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Dados de Centro de Trabalho'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYIMASTER' ):SetDescription( STR0010 )  //'Dados de centro de Trabalho'

// Caso esteja integrando, edita campos do modelo  
If SFCIntegra(.T.) == 1
	oModel:GetModel( 'CYIMASTER' ):GetStruct():SetProperty( 'CYI_CDCETR',  MODEL_FIELD_TAMANHO,   6  )
	If !IsInCallStack("A770IntSFC") .AND. !IsInCallStack('CARGADPR') .AND. !IsInCallStack('CARGASFC')
		oModel:GetModel( 'CYIMASTER' ):GetStruct():SetProperty( 'CYI_CDARPO',  MODEL_FIELD_OBRIGAT,  .T. ) 
   		oModel:GetModel( 'CYIMASTER' ):GetStruct():SetProperty( 'CYI_HRUTDY',  MODEL_FIELD_OBRIGAT,  .T. )
   		oModel:GetModel( 'CYIMASTER' ):GetStruct():SetProperty( 'CYI_CDCECS',  MODEL_FIELD_OBRIGAT,  .T. )
	EndIf                         
ElseIf SFCIntegra(.T.) == 2
	If !IsInCallStack("INTDF_A001")                                                                  
		oModel:GetModel( 'CYIMASTER' ):GetStruct():SetProperty( 'CYI_CDARPO',  MODEL_FIELD_OBRIGAT,  .T. ) 
	EndIf
EndIf     

Return oModel

//-------------------------------------------------------------------
Static Function AddTempFld(oStruct)
	oStruct:AddField(;
		"Reportado Temp"		,;	// [01]  C   Titulo do campo  - Produto
		"Reportado Temp"		,;	// [02]  C   ToolTip do campo - Código do Produto
		"TMP_LGCERP"	   		,;	// [03]  C   Id do Field
		"L"						,;	// [04]  C   Tipo do campo
		TamSX3("CYI_LGCERP")[1]	,;	// [05]  N   Tamanho do campo
		TamSX3("CYI_LGCERP")[2]	,;	// [06]  N   Decimal do campo
		NIL						,;	// [07]  B   Code-block de validação do campo
		NIL				   		,;	// [08]  B   Code-block de validação When do campo
		NIL						,; 	// [09]  A   Lista de valores permitido do campo
		.F.						,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
		{|| CYI->CYI_LGCERP}	,;	// [11]  B   Code-block de inicializacao do campo
		NIL						,; 	// [12]  L   Indica se trata-se de um campo chave
		NIL						,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.						 ;	// [14]  L   Indica se o campo é virtual
	)
Return Nil

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'SFCA001' )
// Cria a estrutura a ser usada na View
Local oStructCYI := FWFormStruct( 2, 'CYI' )

// Cria o objeto de View
oView := FWFormView():New()
                                
// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYI', oStructCYI, 'CYIMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )                                        

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYI', 'TELA' ) 

If SFCIntegra(.T.) == 1
	oStructCYI:RemoveField("CYI_LGVFAV")
	oStructCYI:RemoveField("CYI_TPCE")
ElseIf SFCIntegra(.T.) == 2
	oStructCYI:RemoveField('CYI_CDCECS')
Endif

Return oView 

//-------------------------------------------------------------------
// Função não é mais usada, mas foi deixada para evitar erro em clientes antigos
//-------------------------------------------------------------------
Function SFCA001VCD()
Local lRet := .T.

Return lRet

//---------------------------------------------------------------------
/*Apresenta um grid com todas OPs abertas para seleção do que será
ou não regerada operações do roteiro*/
//---------------------------------------------------------------------
Static Function GridOP(aVersoes,cCDCETR,lReport)
	Local oDlgUpd, nI, oBtnCancelar, oBtnAvanca, oTexto, oBtnDetalhar, oList, oCheckBoxOP, oPanel3
	Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
	Local oNOk		:= LoadBitmap( GetResources(), "LBNO" )
	Local aVerGrid	:= {}
	Public lToggleCheckBoxOP

	For nI := 1 To Len(aVersoes)
		aAdd(aVerGrid,{.T.,AllTrim(aVersoes[nI][1]),AllTrim(aVersoes[nI][2]),aVersoes[nI][3]})
	Next

	Define Dialog oDlgUpd Title STR0024 FROM 0, 0 TO 22, 75 Size 550, 350 Pixel //"Ordens de Produção"

	@ 005,005 GET oTexto VAR (STR0025) OF oDlgUpd MEMO PIXEL SIZE 270,20 NO BORDER //"A alteração de Reportado afeta as seguintes Ordens de Produção em Aberto. Deseja efetuar a alteração em alguma destas ordens?"
	oTexto:lReadOnly := .T.

	oPanel3 := TPanel():New( 25, 05, ,oDlgUpd, , , , , , 270, 120, .F.,.T. )	

	oList := TWBrowse():New( 05, 05, 260, 110,,{"",STR0026,STR0027,STR0028},,oPanel3,,,,,,,,,,,,.F.,,.T.,,.F.,,,)//"Código OP" - "Produto" - "Quantidade"

	@ 8, 6 CheckBox oCheckBoxOP Var lToggleCheckBoxOP Prompt "" When Pixel Of oPanel3 Size 015,015 Message ""
	oCheckBoxOP:bChange := {|| MarcaTodos(oList, lToggleCheckBoxOP)}
	lToggleCheckBoxOP := .T.	

	oList:SetArray(aVerGrid)
	oList:bLine := {|| {If(aVerGrid[oList:nAT,1],oOk,oNOK),aVerGrid[oList:nAt,2],aVerGrid[oList:nAT,3],aVerGrid[oList:nAT,4]}}
	oList:bLDblClick := {|| aVerGrid[oList:nAt,1] := !aVerGrid[oList:nAt,1], controlCheckAllState(oCheckBoxOP, aVerGrid)}

	//@ 155,005 Button oBtnDetalhar Prompt STR0033 Size 60,14 Action VisVersao(cProdDV,aVerGrid,oList) Of oDlgUpd Pixel//"Detalhar"
	@ 155,140 Button oBtnCancelar Prompt STR0029 Size 60,14 Action oDlgUpd:End() Of oDlgUpd Pixel//"Cancelar" 
	@ 155,210 Button oBtnAvanca   Prompt STR0030 Size 60,14 Action {|| LibVersao(aVerGrid,cCDCETR,lReport,.T.),oDlgUpd:End()} Of oDlgUpd Pixel//"Confirmar"

	Activate Dialog oDlgUpd Center
Return Nil
//--------------------------------------------------------------
Static Function LibVersao(aVerGrid,cCDCETR,lReport,lValid)

	MsgRun(STR0031,STR0032,{|| AltOperSpl(aVerGrid,cCDCETR,lReport,lValid)}) //"Aguarde..." - "Replicando alteração para operações e splits."

Return Nil
//--------------------------------------------------------------
Static Function AltOperSpl(aVerGrid,cCDCETR,lReport,lValid)
	Local nI
	Local lRet := .T.
	Local lError := .F.
	Local nHandle := 0
	Local cNameFile := ""

	dbSelectArea("CY9")
	CY9->(dbSetOrder(1))
	dbSelectArea("CYY")
	CYY->(dbSetOrder(1))
	dbSelectArea("CYQ")
	CYQ->(dbSetOrder(1))

	For nI := 1 To Len(aVerGrid)
		//Se a ordem de produção tiver sido marcada
		If aVerGrid[nI][1]

			Begin Transaction

				lRet := .T.
				//Operações
				CY9->(dbSeek(xFilial("CY9")+aVerGrid[nI][2]))

				While CY9->(!Eof()) .And. AllTrim(CY9->CY9_NRORPO) == AllTrim(aVerGrid[nI][2])
					If lReport
						If AllTrim(CY9->CY9_CDCETR) == AllTrim(cCDCETR)
							Reclock("CY9",.F.)
							CY9->CY9_LGCERP := lReport
							MsUnlock()
						EndIf
					Else
						If AllTrim(CY9->CY9_CDCETR) == AllTrim(cCDCETR)
							
							If lValid .And. CY9->CY9_LGATED

								If CYQ->(dbSeek( xFilial("CYQ")+aVerGrid[nI][2] )) .And. CYQ->CYQ_TPRPOR == "1"

									If !lError
										cNameFile := AllTrim(cCDCETR) + "-LGCETR-" + Dtos(Date()) + ".log"
										nHandle   := FCreate(cNameFile)
									EndIf

									lError := .T.

									FWrite(nHandle, aVerGrid[nI][2]+PULALINHA)

									Reclock("CYQ",.F.)
									CYQ->CYQ_TPRPOR := "2"
									MsUnlock()

								EndIf

							EndIf

							Reclock("CY9",.F.)
							CY9->CY9_LGCERP := lReport
							MsUnlock()
							
						EndIf
					EndIf
					CY9->(dbSkip())
				End

				//Splits
				CYY->(dbSeek(xFilial("CYY")+aVerGrid[nI][2]))

				If lRet
					While CYY->(!Eof()) .And. AllTrim(CYY->CYY_NRORPO) == AllTrim(aVerGrid[nI][2])
						If AllTrim(CYY->CYY_CDCETR) == AllTrim(cCDCETR)
							Reclock("CYY",.F.)
							CYY->CYY_LGCERP := lReport
							MsUnlock()
						EndIf
						CYY->(dbSkip())
					End
				EndIf

				If !lRet
					DisarmTransaction()
				EndIf

			End Transaction

		EndIf
	Next

	If lValid .And. lError
		FClose(nHandle)
		Help( ,, 'SFCA001', , STR0033+cNameFile+STR0034, 1, 0) //"Algumas das ordens selecionadas passaram a não possuir operação reportada e portanto foi trocado o parametro para reporte por produção. Um log("+cNameFile+") foi criado na pasta local do servidor Protheus contendo todas ordens afetadas."
	EndIf

Return Nil
//---------------------------------------------------------------------
/* A função terá comportamento de toggle se o lFixedBool não foi informado.*/
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
//---------------------------------------------------------------------
/* Controladora do estado de checkbox */
Static Function controlCheckAllState(oCheckBox,aArray)
	
	Local bSeek := {|x| x[1] == .F. }
		
	@lToggleCheckBoxOP := If(aScan(aArray, bSeek) > 0, .F., .T.)
	oCheckBox:Refresh()
	
Return Nil
//-------------------------------------------------------------------
// SFCA001CMM - Commit Formulário SFCA001
//-------------------------------------------------------------------
Static Function SFCA001CMM (oModel)
	Local nOpc		:= oModel:GetOperation()  
	Local cCDCETR	:= oModel:GetValue("CYIMASTER","CYI_CDCETR")
	Local lReport	:= oModel:GetValue("CYIMASTER","CYI_LGCERP")
	Local lReportAnt:= oModel:GetValue("CYIMASTER","TMP_LGCERP")
	Local aOP		:= {}
	Local aVerGrid	:= {}
	Local cQuery

	If FWFormCommit( oModel ) // Salva os campos padrões do model

		//Verifica se possui versões em aberto sem protótipo informado(caso informe protótipo)
		If nOpc == 4 .And. lReport != lReportAnt

			dbSelectArea("CYY")

			cQuery := "SELECT DISTINCT CYQ_NRORPO,CYQ_CDAC,CYQ_QTOR,CYQ_TPRPOR "
			cQuery += " FROM " + RetSqlName( "CYQ" ) + " AS CYQ "
			cQuery += "  INNER JOIN " + RetSqlName( "CY9" ) + " AS CY9 ON CYQ_NRORPO = CY9_NRORPO AND CY9_FILIAL = '" + xFilial("CYQ") + "' AND CY9.D_E_L_E_T_ <> '*' "
			cQuery += "WHERE CYQ.D_E_L_E_T_ <> '*' "
			cQuery += "  AND CYQ_TPST   = '1' "
			cQuery += "  AND CYQ_FILIAL = '" + xFilial("CYQ") + "' "
			//cQuery += "  AND CYQ_TPRPOR = '1' "
			cQuery += "  AND CY9_CDCETR = '" + cCDCETR + "' "

			cTmp := GetNextAlias()

			dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )

			While (cTmp)->(!Eof())
				If (cTmp)->CYQ_TPRPOR == "1"
					aAdd(aOP,{(cTmp)->CYQ_NRORPO,(cTmp)->CYQ_CDAC,(cTmp)->CYQ_QTOR})
				Else
					aAdd(aVerGrid,{.T.,(cTmp)->CYQ_NRORPO})
				EndIf
				(cTmp)->(dbSkip())
			End

			(cTmp)->(dbCloseArea())

			If Len(aOP) > 0
				GridOP(aOP,cCDCETR,lReport)
			EndIf

			LibVersao(aVerGrid,cCDCETR,lReport,.F.)

		EndIf
	EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA001POS
Pós-Validação SFCA001 - Faz a chamada da Integração do Protheus

@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function SFCA001POS(oModel)
Local lRet     := .T.
Local nOpc     := oModel:GetOperation()
Local aArea    := GetArea()
Local aAreaCYA := CYA->(GetArea())
Local aAreaCYI := CYI->(GetArea())
Local aAreaCYB := CYB->(GetArea())
Local aAreaCYC := CYC->(GetArea())
Local aAreaCYH := CYH->(GetArea())
Local aAreaCY9 := CY9->(GetArea())
Local aAreaCZW := CZW->(GetArea())
Local aAreaCZ7 := CZ7->(GetArea())
Local aAreaCYY := CYY->(GetArea())
Local aAreaCZ4 := CZ4->(GetArea())

// Inclusão
If nOpc == 3
	dbSelectArea('CYI')
	CYI->(dbSetOrder(1))
	If CYI->(dbSeek(xFilial('CYI')+oModel:GetValue('CYIMASTER','CYI_CDCETR')))
		SFCMsgErro(STR0013, STR0011) // 'Já existe registro com a chave informada'  ###  'SFCA001'
		lRet := .F.
	EndIf                         
	
	// Carrega uma Área de Produção (integração) - Quando vem do Datasul, não deve preencher automaticamente
	If Empty(oModel:GetValue('CYIMASTER','CYI_CDARPO')) .AND. SFCIntegra(.T.) == 2 .AND. !IsInCallStack("INTEGDEF")
		dbSelectArea('CYA')
		CYA->(dbSetOrder(1))
		If CYA->(dbSeek(xFilial('CYA')))
			oModel:SetValue('CYIMASTER','CYI_CDARPO',CYA->CYA_CDARPO)
		EndIf
		If Empty(oModel:GetValue('CYIMASTER','CYI_CDARPO'))
			SFCMsgErro(STR0012, STR0011) // 'Necessário existir uma Área de Produção válida no módulo Chão de Fábrica. Cadastre ao menos uma Área de Produção no SIGASFC'  ###  'SFCA001'
			lRet := .F.
		EndIf
	Endif
	             
// Alteração
ElseIf nOpc == 4 
	// Verifica se a área de produção relacionada aos operadores das máquinas confere com a área atual
	IF oModel:IsFieldUpdated('CYIMASTER','CYI_CDARPO') .OR. oModel:IsFieldUpdated('CYIMASTER','CYI_TPMOD')
	
		dbSelectArea('CYB')
		CYB->(dbSetOrder(2))
		If CYB->(dbSeek(xFilial('CYB')+oModel:GetValue('CYIMASTER','CYI_CDCETR')))
			dbSelectArea('CYC')
			CYC->(dbSetOrder(1))
		
			While CYB->(!EOF()) .AND. CYB->CYB_CDCETR == oModel:GetValue('CYIMASTER','CYI_CDCETR')
			
				IF oModel:IsFieldUpdated('CYIMASTER','CYI_CDARPO')
				
					If CYC->(dbSeek(xFilial('CYC')+CYB->CYB_CDMQ+'1'))
						dbSelectArea('CYH')
						CYH->(dbSetOrder(2))
							
						While CYC->(!EOF()) .AND. CYC->CYC_CDMQ == CYB->CYB_CDMQ .AND. CYC->CYC_TPRC == '1'
							If CYH->CYH_CDARPO != oModel:GetValue('CYIMASTER','CYI_CDARPO')
								SFCMsgErro(STR0020 + ALLTRIM(CYB->CYB_CDMQ) + ; // 'Máquina deste Centro de Trabalho possui operador com Área de Produção diferente da informada. Máquina:"
								           STR0021 + ALLTRIM(CYC->CYC_CDRC) + ; // 'Operador: '
								           '. ' + STR0022, STR0011) // "Para que a alteração seja possível desvincule o operador da máquina"
								lRet := .F.
								Exit
							EndIf
							CYC->(dbSkip())
						End
					EndIf
				Else
					if oModel:GetValue('CYIMASTER','CYI_TPMOD') > '1' .AND. CYB->CYB_QTOEMQ == 0
						SFCMsgErro(STR0035,STR0011,2) // 'Existem máquinas sem o campo número de operadores preenchido'
						Exit
					Endif
				Endif
				
				If !lRet
					Exit
				EndIf
				
				CYB->(dbSkip())
			End
		EndIf
	EndIf

// Eliminação
ElseIf nOpc == 5 
	dbSelectArea('CYB')
	CYB->(dbSetOrder(2))
	IF CYB->(dbSeek(xFilial('CYB')+oModel:GetValue('CYIMASTER','CYI_CDCETR')))
		SFCMsgErro(STR0014 + ALLTRIM(CYB->CYB_CDMQ), STR0011) //"Registro está sendo usado na Máquina "###"SFCA001"
		lRet := .F.
	Endif
	
	dbSelectArea('CY9')
	CY9->(dbSetOrder(2))
	IF CY9->(dbSeek(xFilial('CY9')+oModel:GetValue('CYIMASTER','CYI_CDCETR')))
		SFCMsgErro(STR0015 + ALLTRIM(CY9->CY9_NRORPO), STR0011) //"Registro está sendo usado em operação da Ordem de Produção "###"SFCA001"
		lRet := .F.
	Endif
	
	dbSelectArea('CZW')
	CZW->(dbSetOrder(2))
	IF CZW->(dbSeek(xFilial('CZW')+oModel:GetValue('CYIMASTER','CYI_CDCETR')))
		SFCMsgErro(STR0016 + ALLTRIM(CZW->CZW_NRSQRP), STR0011) //"Registro está sendo usado no GGF do Apontamento "###"SFCA001"
		lRet := .F.
	Endif
	
	dbSelectArea('CZ7')
	CZ7->(dbSetOrder(2))
	IF CZ7->(dbSeek(xFilial('CZ7')+oModel:GetValue('CYIMASTER','CYI_CDCETR')))
		SFCMsgErro(STR0017 + ALLTRIM(CZ7->CZ7_IDSPTT), STR0011) //"Registro está sendo usado na Parada Geral "###"SFCA001"
		lRet := .F.
	Endif
	
	dbSelectArea('CYY')
	CYY->(dbSetOrder(4))
	IF CYY->(dbSeek(xFilial('CYY')+oModel:GetValue('CYIMASTER','CYI_CDCETR')))
		SFCMsgErro(STR0018 + ALLTRIM(CYY->CYY_NRORPO), STR0011) //"Registro está sendo usado em Split da Ordem de Produção "###"SFCA001"
		lRet := .F.
	Endif
	
	dbSelectArea('CZ4')
	CZ4->(dbSetOrder(2))
	IF CZ4->(dbSeek(xFilial('CZ4')+oModel:GetValue('CYIMASTER','CYI_CDCETR')))
		SFCMsgErro(STR0019, STR0011) //"Registro está sendo usado nos Indicadores de Produção"###"SFCA001"
		lRet := .F.
	Endif
Endif
   	
if SFCIntegra(.T.) == 1 .AND. lRet .AND. !IsInCallStack("A770IntSFC")
	lRet := AUTO770(nOpc,oModel)
Endif

RestArea(aAreaCYI)
RestArea(aAreaCZ4)
RestArea(aAreaCYA)
RestArea(aAreaCYB)
RestArea(aAreaCYC)
RestArea(aAreaCYH)
RestArea(aAreaCY9)
RestArea(aAreaCZW)
RestArea(aAreaCZ7)
RestArea(aAreaCYY)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AUTO770
Rotina para Integração com o Protheus - MATA770

@param   nOpc        Operação Executada
@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function AUTO770(nOpc,oModel)
Local aDadosAuto := {}		// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica 
Local lHelpDark := HelpInDark(.F.)
Local lHelp     := HelpLog(.T.)

Private lMsHelpAuto := .T. // Grava help no log
Private lMsErroAuto := .F.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aosad

If nOpc==3
	aDadosAuto:= {{'HB_COD' 	, oModel:GetValue('CYIMASTER','CYI_CDCETR')	, Nil},;
				  {'HB_NOME'	, oModel:GetValue('CYIMASTER','CYI_DSCETR')	, Nil},;
				  {'HB_HRUT'	, oModel:GetValue('CYIMASTER','CYI_HRUTDY')	, Nil},;
				  {'HB_CC'		, oModel:GetValue('CYIMASTER','CYI_CDCECS') , Nil},;
				  {'HB_HRUTSAB'	, 0						       	   			, Nil}} 
ElseIf nOpc==4
	aDadosAuto:= {{'HB_COD' 	, oModel:GetValue('CYIMASTER','CYI_CDCETR')	, Nil},;
				  {'HB_NOME'	, oModel:GetValue('CYIMASTER','CYI_DSCETR')	, Nil},;
				  {'HB_HRUT'	, oModel:GetValue('CYIMASTER','CYI_HRUTDY')	, Nil},;
				  {'HB_CC'		, oModel:GetValue('CYIMASTER','CYI_CDCECS')	, Nil},;
				  {'HB_HRUTSAB'	, 0 		       	   						, Nil}} 
Else
	aDadosAuto:= {{'HB_COD'     , oModel:GetValue('CYIMASTER','CYI_CDCETR') , Nil}}
EndIf

MSExecAuto({|x,y| MATA770(x,y)},aDadosAuto,nOPc)

If lMsErroAuto 
	lRetorno := .F.
	If !IsTelNet()
		MostraErro()
	Else
		ErroTelnet()
	EndIf
Else
	lRetorno:=.T.         
EndIf  

HelpInDark(lHelpDark)
HelpLog(lHelp) 

Return lRetorno

//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local lRet     := .T.
Local lFound 
Local cXMLRet  := ""    
Local oXML
Local oBusinessContent
Local oBusinessEvent
Local nOpc := 3
Local oModel
Local aArea    := GetArea()
//Local aAreaCYI := CYI->(GetArea())
                           
If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	//ConOut('Envio a partir do programa de carga, ignorando...')
	Return { .T., 'Envio ignorado.' }
EndIf

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE     
      
	  //ConOut(TIME() + ' - TRANSRECEIVE - ' + cTypeMessage + ' -  SFCA001: ' + StrTran(FwNoAccent(cXML), CHR(13)+CHR(10), ''))
	     
	  //  Se mensagem for de Negócio	
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA001 Recebendo Mensagem Business' )
            
			cError := ''
			cWarning := '' 
			
			// Cria um objeto XML a partir da estutura dos dados do Model
			oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning) 
			                                    
			lValid := .F.
			
			If oXML != NIL
				If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
					oBusinessContent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
					oBusinessEvent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_EVENT:TEXT   
					
					lValid := .T.
				ElseIf XmlChildEx(oXML, '_BUSINESSCONTENT') != NIL
					oBusinessContent = oXML:_BusinessContent
					oBusinessEvent = EAI_EVENT_UPSERT   
					
					lValid := .T.
				EndIf
			EndIf
			
            If lValid == .F.
            	Return { lValid, 'Nao foi enviada uma mensagem valida' }	
            EndIf
			        
			// Instancia o modelo	
			oModel := FWLoadModel( 'SFCA001' )
			  
			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYI')
			CYI->(dbSetOrder(1))
			lFound := CYI->(dbSeek(xFilial('CYI')+ oBusinessContent:_Code:TEXT))
			
			// Verifica se a mensagem é de Inclusão/Alteração
			If UPPER(oBusinessEvent) == EAI_EVENT_UPSERT
				// Se foi encontrado, envia como Alteração
				If lFound
					nOpc := 4
				Else 
					// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
					nOpc := 3						
				EndIf
			Else  
				// Apaga o registro  
				nOpc := 5						
			EndIf
            
			// Set a operação e Ativa o Model
			oModel:SetOperation(nOpc)
			oModel:Activate()
            
            // Se operação for diferente de exclusão
			If nOpc # 5
				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					lAssign := oModel:SetValue('CYIMASTER', 'CYI_CDCETR', oBusinessContent:_Code:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_DSCETR', oBusinessContent:_Description:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_TPCE'  , oBusinessContent:_Type:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_NRUNTE', Val(oBusinessContent:_UnitsPerHour:TEXT)) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_CDCL'  , oBusinessContent:_CalendarCode:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_DSCL'  , oBusinessContent:_CalendarDescription:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				If oBusinessContent:_ProductionAreaCode:TEXT <> ''
					lAssign := oModel:SetValue('CYIMASTER', 'CYI_CDARPO', oBusinessContent:_ProductionAreaCode:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYIMASTER', 'CYI_DSARPO', oBusinessContent:_ProductionAreaDescription:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_TPPC'  , oBusinessContent:_ProcessorType:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_CDUNVM', oBusinessContent:_CapacityUnit:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_TPMOD' , oBusinessContent:_MODReportType:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_LGSU'  , SFCXStoX(oBusinessContent:_IsSetup:TEXT, 'L')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_LGEXUT', SFCXStoX(oBusinessContent:_UsesExtraHour:TEXT, 'L')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_LGRPTE', SFCXStoX(oBusinessContent:_ReportOperationTime:TEXT, 'L')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_IDRPCQ', SFCXStoX(oBusinessContent:_QualityControlReport:TEXT, 'N')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_LGOVAT', SFCXStoX(oBusinessContent:_OperationOverlap:TEXT, 'L')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_LGVFAV', SFCXStoX(oBusinessContent:_HasAlternative:TEXT, 'L')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_TPTEAT', oBusinessContent:_TimeTreatmentType:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_QTCG'  , SFCXStoX(oBusinessContent:_LoadQuantity:TEXT, 'N')) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYIMASTER', 'CYI_CDCECS', oBusinessContent:_CostCenterCode:TEXT)  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				
				If XmlChildEx(oBusinessContent, "_RESPONSIBLEEMAIL") != NIL		
					lAssign := oModel:SetValue('CYIMASTER', 'CYI_DSELUS', oBusinessContent:_ResponsibleEmail:TEXT) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				If XmlChildEx(oBusinessContent, "_USEFULDAYHOUR") != NIL
					lAssign := oModel:SetValue('CYIMASTER', 'CYI_HRUTDY', oBusinessContent:_UsefulDayHour:TEXT)        ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf
				
				// Campos que nao estao presentes no xmlschema - verificar
				//oModel:SetValue('CYIMASTER', 'CYI_LGCERP', SFCXStoX(oBusinessContent:_Reported:TEXT, 'L')) 
				//oModel:SetValue('CYIMASTER', 'CYI_QTVMCE', oBusinessContent:_StandardCapacity:TEXT) 
             EndIf
            
            // Validação no Model    
			if oModel:VldData()  
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()    
				
				// Retorna OK
				cXMLRet := 'Mensagem de ' + IF(nOpc == 3,'Criacao', IF(nOpc == 4, 'Alteracao', 'Delecao')) + ' recebida com sucesso.'
			Else
				// Cria TAG com o Erro ocorrido para retornar ao EAI
				aErro := oModel:GetErrorMessage()
				cXMLRet := SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'
				lRet := .F.
			EndIf

			// Desativa o Model
			oModel:DeActivate()

	  // Mensagem é de Response
      ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
            //conout( '+ IntegDef SFCA001 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem é de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA001 Recebendo Mensagem Receipt' )
            Return {.T., '1.000'}
      EndIf
// Chamada é para envio, solicitada pelo MODEL      
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA001 Enviando Mensagem' )
      
      // Busca o Model que está Ativo no momento da chamada
      oModel := FwModelActive()

	  // Cria a estrutura de TAGs BusinessEvent, já identificando se é "Upsert" ou "Delete", e colocando as "Identifications"      
      cXMLRet :=  FWEAIBusEvent( "WorkCenter",oModel:GetOperation(), { { "Code", oModel:GetValue("CYIMASTER", "CYI_CDARPO") } }  )         
       
      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'          


		cXMLRet += '<Code>' 						+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_CDCETR')) 		+ '</Code>'
		cXMLRet += '<Description>' 					+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_DSCETR')) 		+ '</Description>'
		
		// Se a operação for diferente de 5 (Exclusão), manda as informações que não são relacionadas a chave
		If oModel:GetOperation() # 5
			cXMLRet += '<Type>' 						+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_TPCE')) 	+ '</Type>'
			cXMLRet += '<UnitsPerHour>' 				+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_NRUNTE')) 	+ '</UnitsPerHour>'
			cXMLRet += '<CalendarCode>' 				+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_CDCL')) 	+ '</CalendarCode>'
			cXMLRet += '<CalendarDescription>' 			+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_DSCL')) 	+ '</CalendarDescription>'
			cXMLRet += '<ProductionAreaCode>' 			+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_CDARPO')) 	+ '</ProductionAreaCode>'
			cXMLRet += '<ProductionAreaDescription>' 	+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_DSARPO')) 	+ '</ProductionAreaDescription>'
			cXMLRet += '<ProcessorType>' 				+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_TPPC')) 	+ '</ProcessorType>'
			cXMLRet += '<CapacityUnit>' 				+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_CDUNVM')) 	+ '</CapacityUnit>'
			cXMLRet += '<MODReportType>' 				+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_TPMOD')) 	+ '</MODReportType>'
			cXMLRet += '<IsSetup>' 				   		+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_LGSU')) 	+ '</IsSetup>'
			cXMLRet += '<UsesExtraHour>' 				+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_LGEXUT')) 	+ '</UsesExtraHour>'
			cXMLRet += '<ReportOperationTime>' 			+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_LGRPTE')) 	+ '</ReportOperationTime>'
			cXMLRet += '<QualityControlReport>' 		+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_IDRPCQ')) 	+ '</QualityControlReport>'
			cXMLRet += '<OperationOverlap>' 			+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_LGOVAT')) 	+ '</OperationOverlap>'
			cXMLRet += '<HasAlternative>' 				+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_LGVFAV')) 	+ '</HasAlternative>'
			cXMLRet += '<TimeTreatmentType>' 			+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_TPTEAT')) 	+ '</TimeTreatmentType>'
			cXMLRet += '<LoadQuantity>'			  		+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_QTCG')) 	+ '</LoadQuantity>'
			cXMLRet += '<CostCenterCode>' 				+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_CDCECS')) 	+ '</CostCenterCode>'
			cXMLRet += '<ResponsibleEmail>' 			+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_DSELUS')) 	+ '</ResponsibleEmail>'
			cXMLRet += '<UsefulDayHour>' 				+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_HRUTDY')) 	+ '</UsefulDayHour>'   
			// Campos que nao estao presentes no xmlschema - verificar
			// cXMLRet += '<Reported>' 					+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_LGCERP')) 	+ '</Reported>'
			// cXMLRet += '<StandardCapacity>' 			+ SFCXXtoS(oModel:GetValue("CYIMASTER", 'CYI_QTVMCE')) 	+ '</StandardCapacity>'
        EndIf
		                
	    		
      cXMLRet += '</BusinessContent>'
      
EndIf

//RestArea(aAreaCYI)
RestArea(aArea)

//ConOut(TIME() + ' - [Retorno] ' + cXMLRet)
//ConOut(cXMLRet)

Return { lRet, cXMLRet }

Function INTDF_A001( cXML, nTypeTrans, cTypeMessage )            
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)

//-------------------------------------------------------------------
// ValidOrdem - Valida o valor informado no campo Ordem de Produção
//-------------------------------------------------------------------
Static Function ValidOrdem(cNRORPO)

	Local cAliasCYY := ''

	If Empty(cNRORPO)
		Return .T.
	EndIf

	//Valida se a ordem possui alguma split com parametro Reportado ativo
	dbSelectArea("CYQ")
	CYQ->(dbSetOrder(1))

	If CYQ->(dbSeek(xFilial("CYQ")+cNRORPO))
		If CYQ->CYQ_TPRPOR == '1'

			cAliasCYY := GetNextAlias()

			BeginSql Alias cAliasCYY

				SELECT CYY.CYY_LGCERP
				FROM %Table:CYY% CYY
				  INNER JOIN %Table:CY9% CY9 ON CY9.CY9_NRORPO = CYY.CYY_NRORPO AND CY9.CY9_IDAT = CYY.CYY_IDAT
				WHERE CY9.CY9_NRORPO = %Exp:cNRORPO%
				  AND CY9.CY9_LGATED = 'T'
				  AND CY9.%NotDel%
				  AND CYY.%NotDel%

			EndSql

			If (cAliasCYY)->CYY_LGCERP == 'T'
				(cAliasCYY)->(dbCloseArea())
				Return .T.
			EndIf

			(cAliasCYY)->(dbCloseArea())

			/*dbSelectArea("CYY")
			CYY->(dbSetOrder(1))
			If CYY->(dbSeek(xFilial("CYY")+cNRORPO))
				While CYY->CYY_FILIAL+CYY_NRORPO == xFilial("CYY")+cNRORPO
					If CYY->CYY_LGCERP
						lLstSpltRp := .T.
					EndIf
					CYY->(dbSkip())
				End
			EndIf*/

		Else
			Return .T.
		EndIf
	EndIf

Return .F.
