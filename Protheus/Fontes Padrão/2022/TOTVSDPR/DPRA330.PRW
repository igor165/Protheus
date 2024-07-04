#INCLUDE 'DPRA330.CH' 
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} DPRA330
Tela de Importação de Estrutura

@author Ana Carolina Tome Klock
@since 20/01/2012
@version P12
/*/
//-----------------------------------------------------------------
Function DPRA330()
Local oModel, nI, nI2
Local cCDACDV := DG0->DG0_CDACDV
Local cNRVRAC := DG0->DG0_NRVRAC
//Local aTabs	  := { 'aDG0', 'aDG1', 'aDG2', 'aDG3', 'aDG9', 'aDGN' }
//Local cArquiv := ''
Local aValidaDPR := ValidaDPR()
//Local aTemplate := {}
//Local aAtrib    := {}
Local lRet      := .T.
Private oTree
Private aDG3 := {}
Private aDG0 := {}
Private aDG1 := {}
Private aDG9 := {}
Private aDG2 := {}
Private aDGN := {}
Private nEstru := 0 // Variavel para integracao PCP
Default lAutoMacao := .F.

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA330', aValidaDPR[2], 3 )
EndIf

if !lEstrut .AND. !lOperac .AND. !lFicha
	DPRXError( 'DPRA330', 'DPRA330_NAOINF', 3) // É preciso informar quais dados serão importados
Else
	// Produto Desenvolvido
	If nOrigem == 1
		DPRASTRUCT( aValor[1], aValor[2], { lEstrut, lOperac, lAltEstrut, lAltOperac, If (nDesce==2,.T.,.F.), lFicha }, 1 )

	// Integração com Módulo PCP (Protheus)
	ElseIf nOrigem == 2 .And. DPRIntegra() == 1
		lRet := DPRASTRUCT( aValor[1], aValor[2], { lEstrut, lOperac, lAltEstrut, lAltOperac, If (nDesce==2,.T.,.F.), lFicha }, 2, nRoteiro )
		
		If !lRet
			Return .F.
		Endif

	// Integração com Engenharia (Datasul)
	ElseIf nOrigem == 2 .And. DPRIntegra() == 2
		//INTEGDEF( '', 3, 'DPRA330INT' )

	// Integração com Configurador (Datasul)
	ElseIf nOrigem == 3
		//INTEGDEF( '', 3, 'DPRA330INT' )
	EndIf

	// Chama o Modelo para Criar uma Versão
	IF !lAutoMacao
		(aDG0[1])->(dbGoTo(1))
		If AllTrim((aDG0[1])->NIVEL) == '1' .Or. ( nOrigem == 2 .And. DPRIntegra() == 1 )
			dbSelectArea( 'DG0' )
			DG0->( dbSetOrder(1) )
			If DG0->( dbSeek( xFilial('DG0') + cCDACDV + cNRVRAC ) )
				oModel := FwLoadModel( 'DPRA330' )
				oModel:SetOperation( 4 )
				oModel:Activate()
				oModel:GetModel('DG0MASTER'):SetValue( 'DG0_DSVR', DG0->DG0_DSVR )
				FWExecView( '', 'DPRA330', 4,, { || .T. },,,,,,, oModel )
				oModel:DeActivate()
			EndIf
		Else
			DPRXError( 'DPRA330', 'DPRA330_INVAL', 3) // Produto ou Versão invalida.
		EndIf

		// Fecha as tabelas
		aDG0[3]:Delete()
		aDG1[3]:Delete()
		aDG2[3]:Delete()
		aDG3[3]:Delete()
		aDG9[3]:Delete()
		aDGN[3]:Delete()
	ENDIF
Endif

Return .T.
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDG0 := FWFormStruct( 1, 'DG0', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel, nI

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA330', /*bPreValidacao*/, { |oModel| DPRA330POS(oModel) }, { |oModel| DPRA330STS() } , /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DG0MASTER', /*cOwner*/, oStructDG0, /*bPreValidacao*/, /*bPosValidacao*/, /*bLoad*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //'Importação de Versão'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DG0MASTER' ):SetDescription( STR0002 ) // 'Dados da Importação'

// Seta valores para os campos principais
For nI := 1 to Len( oStructDG0:GetFields() )
	oStructDG0:SetProperty(	oStructDG0:GetFields()[nI][3], MODEL_FIELD_OBRIGAT, .F. )
Next
oStructDG0:SetProperty( 'DG0_NRVRAC', MODEL_FIELD_WHEN, { || .T. } )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA330' )
// Cria a estrutura a ser usada na View
Local oStructDG0 := FWFormStruct( 2, 'DG0' )
// Cria uma variável para armazenar a árvore
Local nI

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona um botão nas Ações Relacionadas da View
oView:AddUserButton( STR0003, 'DPRA330', { || DPRA330LEG() } )  // 'Legenda'

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DG0', oStructDG0, 'DG0MASTER' )

// Adiciona no nosso View um controle do tipo FormGrid (antiga newgetdados)
oView:AddOtherObject( 'VIEW_PRO', { |oPanel| oTree := DPRA330STR( oPanel, 4 ) } )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 10 )
oView:CreateHorizontalBox( 'INFERIOR', 90 )

// Cria Folder na view
oView:CreateFolder( 'FOLDER', 'INFERIOR' )

// Cria pastas nas folders
oView:AddSheet( 'FOLDER', 'TAB01', STR0004 )   // 'Processo de Fabricação'

oView:CreateHorizontalBox( 'PRO', 100, , ,'FOLDER', 'TAB01' )

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_DG0', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_PRO', 'PRO' )

// Remove o campo repetido da tela
oStructDG0:SetNoGroups()
While Len( oStructDG0:GetFields() ) != 3
	oStructDG0:RemoveField( oStructDG0:GetFields()[4][1] )
End

// Permite apenas visualizar campos virtuais
oView:GetViewStruct('VIEW_DG0'):SetProperty('DG0_CDACDV', MVC_VIEW_CANCHANGE , .F.)
oView:GetViewStruct('VIEW_DG0'):SetProperty('DG0_NRVRAC', MVC_VIEW_CANCHANGE , .F.)
oView:GetViewStruct('VIEW_DG0'):SetProperty('DG0_DSVR'	, MVC_VIEW_CANCHANGE , .F.)

// Para nao reabrir a tela, após salvar registro
oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
// Regua
//-------------------------------------------------------------------
Function DPRA330STS ()

RptStatus( {|lEnd| DPRA330COM() }, STR0041, STR0042 ) // "Aguarde..." # "Executando rotina..."

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA330LEG
Tela de Legendas

@author Ana Carolina Tome Klock
@since 01/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPRA330LEG()
Default lAutoMacao := .F.

// Cria a legenda que identifica a estrutura
oLegend := FWLegend():New()

// Adiciona descrição para cada legenda
oLegend:Add( { || }, 'RPMDES'  , STR0005 )  // 'Produto Desenvolvido'
oLegend:Add( { || }, 'PMSTASK6' , STR0006 )  // 'Produto Engenharia'
oLegend:Add( { || }, 'PMSTASK4', STR0007 )  // 'Produto Comprado'
oLegend:Add( { || }, 'CLOCK01'    , STR0009 )  // 'Operação'
If DPRIntegra() != 1
	oLegend:Add( { || }, 'DESTINOS', STR0008 )  // 'Componente Alternativo'
	oLegend:Add( { || }, 'DESTINOS', STR0010 )  // 'Operação Alternativa'
EndIf

// Ativa a Legenda
oLegend:Activate()

// Exibe a Tela de Legendas
IF !lAutoMacao
	oLegend:View()
ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA330POS
Valida as informacoes antes de realizar o Commit

@param 		oModel		Modelo de Dados da Versão
@return 	lRet		Retorna se a gravação foi realizada

@author Ana Carolina Tome Klock
@since 07/03/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPRA330POS( oModel )
Local lRet := .T.
Local nI, nJ, nK, oDlg
Local lExibe  := .T.
Local aCampos := {}
Local oCDACDV
Local oCDACDE
//Local lAlterou := .F.
Local aResult := {Space( TamSX3('DG0_CDACDV')[1] ),Space( TamSX3('DG0_CDACDV')[1] ),Space( TamSX3('DG0_CDACDV')[1] )}
Private lWhen := .T.
Private oBTNAlt, oAltera, oPanel

If DPRIntegra() == 1
	For nJ := 2 to (aDG0[1])->(RecCount())
		(aDG0[1])->( dbGoTo(nJ) )
		If (aDG0[1])->EXIBE
			dbSelectArea(aDG3[1])
			(aDG3[1])->(dbGoTop())
			(aDG3[1])->(dbSetOrder(1))
			(aDG3[1])->(dbSeek((aDG0[1])->DG0_CDACDV))
				
			RecLock( (aDG3[1]), .F. )
			(aDG3[1])->DG3_DSACDV := (aDG3[1])->DG3_DSACDE
			(aDG3[1])->DG3_CDUNDE := (aDG3[1])->DG3_CDUN
			(aDG3[1])->DG3_TPST   := '1'
			(aDG3[1])->DG3_TPEGDV := '1'
					
			dbSelectArea( 'DG3' )
			DG3->( dbSetOrder(2) )
				
			For nK := 1 to len(aCampos)
				If aCampos[nK][2] == (aDG3[1])->DG3_CDACDE
					lExibe := .F.
				Else
					lExibe := .T.
				EndIf
			Next
			
			If lExibe
				
				if ProcFilhos( (aDG0[1])->DG0_CDACDV, (aDG0[1])->DG0_NRVRAC, DPRNvlTree( (aDG0[1])->Nivel,1 ) )
					aAdd( aCampos, { (aDG3[1])->DG3_CDACDV, (aDG3[1])->DG3_CDACDE, SPACE(TamSX3('DG3_CDACPY')[1]), (aDG3[1])->DG3_CDACDV, (aDG3[1])->DG3_CDACDE, SPACE(TamSX3('DG3_CDACPY')[1]) } )
				Endif
			EndIf
				
			MsUnlock()
		EndIf
	Next
	
	If nDesce == 2 .AND. len( aCampos ) > 0
		DEFINE DIALOG oDlg TITLE STR0032 FROM 180,180 TO 500,820 PIXEL   // 'Produtos Protótipos'

		// Cria Browse
		oBrowse := TCBrowse():New( 35 , 05, 200, 90,,{STR0005, STR0033},{85, 85},oDlg,,,,,{||},,,,,,,.F.,,.T.,{|| IF(lWhen,.T.,.F.) },.T.,,, )  // 'Produto Desenvolvido' ### 'Destino'
		
		// Seta array para o browse
		oBrowse:SetArray(aCampos)

		// Arruma os dados na linha
		oBrowse:bLine := { || { aCampos[oBrowse:nAt,4], aCampos[oBrowse:nAt,5] } }
		
		// Atualiza valores nos campos
		oBrowse:bChange := { || aResult[1] := aCampos[oBrowse:nAt,4], aResult[2] := aCampos[oBrowse:nAt,5] }
		
		oBTNAlt := TButton():New( 130, 160, STR0048, oDlg, {|| lWhen := .F., oAltera:Show(), oPanel:Show(), oBTNAlt:Hide(),aResult[1] := aCampos[oBrowse:nAt,4], aResult[2] := aCampos[oBrowse:nAt,5] },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // Alterar
		
		oAltera := TGroup():New(  40, 210, 127, 310, STR0050, oDlg,,, .T. ) // 'Alteração'
		oPanel  := TPanel():New(  40, 214, STR0050, oAltera,,,,, CLR_WHITE, 90, 80, .F., .F. ) // 'Alteração'
		
		oSay1 := TSay():New(  15, 01, {|| STR0005 }, oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // 'Produto Desenvolvido'
		oSay2 := TSay():New(  40, 01, {|| STR0033 }, oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // 'Destino'
		@ 23, 01 MsGet oCDACDV Var aResult[1] Size 90 , 10 Of oPanel Pixel HasButton PICTURE x3picture('DG0_CDACDV')
		@ 48, 01 MsGet oCDACDE Var aResult[2] Size 90 , 10 Of oPanel Pixel HasButton PICTURE x3picture('DG3_CDACDE')
		
		oBTN1 := TButton():New( 70, 01, STR0047, oPanel,{|| DPRA330SAL(aCampos, aResult) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // Salvar
		oBTN2 := TButton():New( 70, 46, STR0036, oPanel,{|| aResult[1] := aCampos[oBrowse:nAt,4], aResult[2] := aCampos[oBrowse:nAt,5], lWhen := .T., oBTNAlt:Show(), oAltera:Hide(), oPanel:Hide() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

		oPanel:Hide()
		oAltera:Hide()
        
		Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || lRet := .T., oDlg:End() }, { || lRet := .F., oDlg:End() } )
	EndIf

	If lRet
		
		(aDG3[1])->(dbSetOrder(1))
		
		For nI := 1 to len(aCampos)
			if (aDG3[1])->(dbSeek(aCampos[nI,1]))
				RecLock( (aDG3[1]), .F. )
				(aDG3[1])->DG3_DVNOVO := aCampos[nI,4]
				(aDG3[1])->DG3_DENOVO := aCampos[nI,5]
				MsUnlock()
			Endif 
		Next
		
		(aDG0[1])->(dbSetOrder(4))
		
		For nI := 1 to len(aCampos)
			if (aDG0[1])->(dbSeek(aCampos[nI,1]))
				RecLock( (aDG0[1]), .F. )
				(aDG0[1])->DG0_DVNOVO := aCampos[nI,4]
				(aDG0[1])->DG0_DENOVO := aCampos[nI,5]
				MsUnlock()
			Endif 
		Next		
	Else
		DPRXError( 'DPRA330', 'DPRA330_CANCEL',3)
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
// Salva informação nos campos
//-------------------------------------------------------------------
Static Function DPRA330SAL(aCampos, aResult)
Local lRet := .T.
Default lAutoMacao := .F.

dbSelectArea('DG3')
DG3->(dbSetOrder(1))
IF DG3->(dbSeek(xFilial('DG3')+aResult[1])) .AND. DG3->DG3_CDACDE != aResult[2]
	if MSGYESNO(STR0051 + ALLTRIM(aResult[1]) + STR0052 + DG3->DG3_CDACDE + STR0053) // 'Já existe um Produto Desenvolvido com o código ' ## ' e produto destino ' ## '. Deseja prosseguir utilizando o Produto Destino original?'
		lRet := .T.
		aCampos[oBrowse:nAt,4] := aCampos[oBrowse:nAt,1]
		aCampos[oBrowse:nAt,5] := aCampos[oBrowse:nAt,2]
		aResult[1] := aCampos[oBrowse:nAt,1]
		aResult[2] := aCampos[oBrowse:nAt,2]
	Else
		lRet := .F.
	Endif
Else
	IF !lAutoMacao
		aCampos[oBrowse:nAt,5] := aResult[2]
	ENDIF
Endif
     
dbSelectArea('DG3')
DG3->(dbSetOrder(2))
IF DG3->(dbSeek(xFilial('DG3')+aResult[2])) .AND. DG3->DG3_CDACDV != aResult[1]
	if MSGYESNO(STR0054 + ALLTRIM(aResult[2]) + STR0055 + DG3->DG3_CDACDV + STR0056) // 'Já existe um Produto Destino com o código ' ## ' e produto desenvolvido ' ## ' . Deseja prosseguir utilizando o Produto Desenvolvido original?'
		lRet := .T.
		aCampos[oBrowse:nAt,4] := aCampos[oBrowse:nAt,1]
		aCampos[oBrowse:nAt,5] := aCampos[oBrowse:nAt,2]
		aResult[1] := aCampos[oBrowse:nAt,1]
		aResult[2] := aCampos[oBrowse:nAt,2]
	Else
		lRet := .F.
	Endif
Else
	IF !lAutoMacao
		aCampos[oBrowse:nAt,4] := aResult[1]
	ENDIF
Endif

IF lRet
	lWhen := .T.
	IF !lAutoMacao
		oBTNAlt:Show()
		oAltera:Hide()
		oPanel:Hide()
	ENDIF
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcFilhos
Procura por estrutura ou roteiro relacionados a versao

@param 		cCDACDV		Código do Produto Desenvolvido
@param		cNRVRAC		Número da Versão
@param		cNivel		Nível dos filhos
@return 	lRet		Retorna se possui filhos

@author Ana Carolina Tome Klock
@since 07/03/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function ProcFilhos( cCDACDV, cNRVRAC, cNivel )
Local lExibe := .F.

// Procura estrutura
(aDG1[1])->(dbSetOrder(1))
If (aDG1[1])->( dbSeek( cNivel+cCDACDV+cNRVRAC) )
	While (aDG1[1])->( !EOF() )
		If (aDG1[1])->NIVEL      == cNivel   .And. ;			
		   (aDG1[1])->DG1_CDACDV == cCDACDV  .And. ;
		   (aDG1[1])->DG1_NRVRAC == cNRVRAC  .And. ;
		   (aDG1[1])->EXIBE
			lExibe := .T.
			Exit
		EndIf
		(aDG1[1])->(dbSkip())
	End
EndIf

// Procura operações
(aDG9[1])->(dbSetOrder(1))
If !lExibe .And. (aDG9[1])->( dbSeek( cNivel+cCDACDV+cNRVRAC) )
	While (aDG9[1])->( !EOF() )
		If (aDG9[1])->NIVEL      == cNivel   .And. ;
		   (aDG9[1])->DG9_CDACDV == cCDACDV  .And. ;
		   (aDG9[1])->DG9_NRVRAC == cNRVRAC  .And. ;
		   (aDG9[1])->EXIBE
			lExibe := .T.
			Exit
		EndIf
		(aDG9[1])->(dbSkip())
	End
EndIf

// Procura ficha técnica
(aDGN[1])->(dbSetOrder(1))
If !lExibe .And. (aDGN[1])->( dbSeek( cNivel+cCDACDV) )
	While (aDGN[1])->( !EOF() )
		If (aDGN[1])->NIVEL      == cNivel   .And. ;
		   (aDGN[1])->DGN_CDACDV == cCDACDV  .And. ;
		   (aDGN[1])->EXIBE
			lExibe := .T.
			Exit
		EndIf
		(aDGN[1])->(dbSkip())
	End
EndIf

Return lExibe

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA330COM
Grava as informações obtidas no DPR

@param 		oModel		Modelo de Dados da Versão
@return 	lRet		Retorna se a gravação foi realizada

@author Ana Carolina Tome Klock
@since 14/09/2012
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPRA330COM( oModel )
Local cCDACDV := DG0->DG0_CDACDV
Local cNRVRAC := DG0->DG0_NRVRAC
Local aCampos := {}
Local lRet		:= .T.
Local cChave, nOpc, nCount
Local nI, nJ, nK, nL, nAux
Local cNivel, lExibe
Local oModelDGN
Local oModelDG9
Local cProduto := ''
Local aNaoATT  := ''
Local nPos     := 0
Local nDG0Pos  := 2
Local cProdUN, cProdDesc, cDG3_CDGE, cDG3_LGACVI

Private aTemplates := {}
Private lEnd := .f.
Private lEntrou := .f.
Private nVlIniFx, nVlFinFx, nVlFaixa
Private cDGNCDACDV, cDGNCDMQ, cDGNCDMD
Private cAbreTela := 'S'
Private cExecVald := 'S'
Private cFormNova := ""
Default lAutoMacao := .F.

IF !lAutoMacao
	SetRegua(2)
ENDIF

// Instancia o modelo
oModelDG3  := FWLoadModel( 'DPRA100' )
oModelDG0  := FWLoadModel( 'DPRA300' )
oModelDG1  := oModelDG0:GetModel( 'DG1DETAIL' )
oModelDG9  := oModelDG0:GetModel( 'DG9DETAIL' )
oModelDG2R := oModelDG0:GetModel( 'DG2DETREC' )
oModelDG2F := oModelDG0:GetModel( 'DG2DETFER' )
oModelDGN  := FWLoadModel( 'DPRA210' )

// Verifica se o parâmetro foi informado
/*If Empty( SuperGetMV('MV_DPRPROT',.F.,'') )
	DPRXError('DPRA330', 'Parâmetro MV_DPRPROT não pode estar em branco.', 'Informe um valor válido no parâmetro MV_DPRPROT para continuar.')
	Return .F.
EndIf

// Verifica se não existe nenhum produto igual ao protótipo
For nI := 1 to len( aDG3 )
	If (aDG3[nI][1] == SuperGetMV('MV_DPRPROT',.F.,'')) .And. aDG3[nI][ len(aDG3[nI]) ]
		DPRXError('DPRA330', 'Parâmetro MV_DPRPROT não pode ser igual ao produto importado: ' + AllTrim(aDG3[nI][1]), 'Informe um valor válido no parâmetro MV_DPRPROT para continuar.')
		Return .F.
	EndIf
Next

// Verifica se o produto foi cadastrado na CZ3 (Chao de Fabrica)
dbSelectArea( 'CZ3' )
For nI := 1 to len( aDG3 )
	If !dbSeek( xFilial('CZ3') + Upper(aDG3[nI][1]) ) .And. aDG3[nI][ len(aDG3[nI]) ]
		DPRXError('DPRA330', 'O produto de engenharia ' + AllTrim(aDG3[nI][1]) + ' ainda não foi importado via SFC.', 'Importe o produto antes de continuar.')
		Return .F.
	// Verifica se possui a filial preenchida
	ElseIf Empty( aDG3[nI][11] ) .And. aDG3[nI][ len(aDG3[nI]) ]
		DPRXError('DPRA330', 'Filial não pode estar em branco', 'Informe um estabelecimento para o produto ' + AllTrim(aDG3[nI][1]))
		Return .F.
	EndIf
Next */

BEGIN TRANSACTION

// Ajusta as versões que estão sendo utilizadas
(aDG0[1])->(dbSetOrder(1))
(aDG0[1])->( dbGoTo( nDG0Pos ))
While (aDG0[1])->( !EOF() )
	IF !lAutoMacao
		cNivel := DPRNvlTree( (aDG0[1])->Nivel,1 )
	
		lExibe := ProcFilhos( (aDG0[1])->DG0_CDACDV, (aDG0[1])->DG0_NRVRAC, cNivel )

		// Apaga versão
		If !lExibe
			If (aDG3[1])->( dbSeek( (aDG0[1])->DG0_CDACDV ) )
			
				RecLock( (aDG3[1]), .F.)
				(aDG3[1])->EXIBE := .F.
				MsUnlock()
			EndIf
			
			RecLock( (aDG0[1]), .F.)
			(aDG0[1])->EXIBE := .F.
			MsUnlock()
		EndIf
	ENDIF
	
	(aDG0[1])->(dbSkip())	
End

// Cria novos produtos desenvolvidos
For nI := 2 to (aDG3[1])->( RecCount() )
	(aDG3[1])->( dbGoTo(nI) )
	IF !lAutoMacao
		if (aDG3[1])->EXIBE

			dbSelectArea( 'CZ3' )
			dbSelectArea( 'DG3' )
			DG3->( dbSetOrder( 1 ) )
		
			// Se foi encontrado, trata como Alteração
			If DG3->( dbSeek( xFilial('DG3') + (aDG3[1])->DG3_DVNOVO ) )
				nOpc 	:= 4
			// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
			else
				nOpc 	:= 3
				nCount := 1
			EndIf
			
			if nOpc == 3
				//Se o parametro "Descrição e UN do Produto Destino" usa a descrição e unidade da CZ3
				If lDescUN .AND. CZ3->( dbSeek(xFilial('CZ3')+(aDG3[1])->DG3_DVNOVO ))
					cProdUN   := CZ3->CZ3_CDUN
					cProdDesc := CZ3->CZ3_DSAC
					cDG3_CDGE := CZ3->CZ3_CDFA
				else
					cProdUN   := (aDG3[1])->DG3_CDUN
					cProdDesc := (aDG3[1])->DG3_DSACDE
					cDG3_CDGE := (aDG3[1])->DG3_CDGE
					cDG3_LGACVI := (aDG3[1])->DG3_LGACVI
				EndIf
				
				if cDG3_LGACVI == " "
					cDG3_LGACVI := 'N'
				EndIf
				
				// TODO: Importar Criterios
				// TODO: Importar Tutorial
			
				// Set a operação e Ativa o Model
				oModelDG3:SetOperation( nOpc )
				oModelDG3:Activate()
				
				oModelDG3:SetValue('DG3MASTER', 'DG3_CDACDV', AllTrim((aDG3[1])->DG3_DVNOVO))
				oModelDG3:SetValue('DG3MASTER', 'DG3_CDACDE', AllTrim((aDG3[1])->DG3_DENOVO))
				oModelDG3:SetValue('DG3MASTER', 'DG3_DSACDV', AllTrim(cProdDesc)            )
				oModelDG3:SetValue('DG3MASTER', 'DG3_CDUN'  , AllTrim(cProdUN)              )
				oModelDG3:SetValue('DG3MASTER', 'DG3_LGACVI', '0') // Colocar no dic como não obrigatório
			
				// Carrega valores nos campos
				aCampos := ACLONE(oModelDG3:GetModel('DG3MASTER'):GetStruct():GetFields())
				
				// Campos que não devem ser atualizados
				aNaoATT := {'DG3_CDACDV', 'DG3_CDACDE', 'DG3_DSACDV', 'DG3_CDUN', 'DG3_LGACVI'}
				
				For nJ := 1 to Len(aNaoATT)
					nPos := ASCAN(aCampos, { |x| AllTrim(x[3]) ==  AllTrim(aNaoATT[nJ]) } )
					
					if nPos > 0
						ADEL(aCampos,nPos)
					Endif
				Next
				
				ASIZE(aCampos,Len(aCampos) - Len(aNaoATT)) // Remover as posições dos campos retirados
				
				For nJ := 3 To Len( aDG3[2] )-1
					If aScan(aCampos, { |x| AllTrim(x[3]) ==  AllTrim(aDG3[2,nJ,1]) } )  > 0
						If oModelDG3:GetModel('DG3MASTER'):CanSetValue( aDG3[2,nJ,1] )
							oModelDG3:LoadValue('DG3MASTER', aDG3[2,nJ,1], (aDG3[1])->&(aDG3[2,nJ,1]) )
						EndIf
					EndIf
				Next
			
				// Validação no Model
				If oModelDG3:VldData()
					// Caso nao ocorra erros, efetiva os dados no banco
					oModelDG3:CommitData()
				Else
					DPRXError('DPRA100', oModelDG3:GetErrorMessage()[6] )
					lRet := .F.
				EndIf
			
				// Desativa o Model
				oModelDG3:DeActivate()
			EndIf
		Endif
	ENDIF
Next

if lRet

	// Apaga componentes e operações do pai
	(aDG0[1])->( dbGoTo(1) )
	dbSelectArea( 'DG0' )
	DG0->( dbSetOrder(1) )
	If DG0->( dbSeek( xFilial('DG0')+cCDACDV+cNRVRAC ) )		
	
		oModelDG0:SetOperation( 4 )
		oModelDG0:Activate()

		// Apaga componentes
		For nI := 1 To oModelDG0:GetModel('DG1DETAIL'):Length()
			oModelDG0:GetModel('DG1DETAIL'):GoLine(nI)
			oModelDG0:GetModel('DG1DETAIL'):DeleteLine()
		Next

		// Apaga operações
		For nI := 1 To oModelDG0:GetModel('DG9DETAIL'):Length()
			oModelDG0:GetModel('DG9DETAIL'):GoLine(nI)
			oModelDG0:GetModel('DG9DETAIL'):DeleteLine()
		Next
		
		oModelDG0:SetValue('DG0MASTER','DG0_CDRTOG',(aDG0[1])->DG0_CDRTOG)

		// Validação no Model
		If oModelDG0:VldData()
			// Caso nao ocorra erros, efetiva os dados no banco--
			oModelDG0:CommitData()
		Else
			DPRXError('DPRA300', oModelDG0:GetErrorMessage()[6] )
			lRet := .F.
		EndIf

		// Desativa o Model
		oModelDG0:DeActivate()

		// Altera a versão do pai
		If !Empty((aDG0[1])->DG0_CDACDV)
			RecLock( (aDG0[1]), .F. )
			(aDG0[1])->DG0_CDACDV := cCDACDV
			(aDG0[1])->DG0_NRVRAC := cNRVRAC
			MsUnlock()
		EndIf
	EndIf
Endif

If lRet
	// Apaga as ficha técnicas relacionadas à versão
	(aDG0[1])->( dbGoTo(1) )
	dbSelectArea( 'DGN' )
	DGN->( dbSetOrder(1) )
	If DGN->( dbSeek( xFilial('DGN')+cCDACDV+cNRVRAC ) )
		While DGN->(!EOF()) .AND. DGN->DGN_CDACDV == cCDACDV .AND. DGN->DGN_NRVRAC == cNRVRAC
			
			oModelDGN:SetOperation( 5 )
			oModelDGN:Activate()

			If oModelDGN:VldData()
				// Caso nao ocorra erros, efetiva os dados no banco
				oModelDGN:CommitData()
			Else
				DPRXError('DPRA330', oModelDGN:GetErrorMessage()[6] )
				lRet := .F.
			EndIf

			// Desativa o Model
			oModelDGN:DeActivate()

			DGN->(dbSkip())
		End
	Endif
Endif

// Cria novas versões para os produtos
if lRet
	For nI := 2 to (aDG0[1])->( RecCount() )
		(aDG0[1])->( dbGoTo(nI) )
		IF !lAutoMacao
			If (aDG0[1])->EXIBE

				// Set a operação e Ativa o Model
				oModelDG0:SetOperation( 3 )
				oModelDG0:Activate()
				
				RecLock( (aDG0[1]), .F. )
				(aDG0[1])->DG0_NRVRAC := DPRA300NRV( (aDG0[1])->DG0_DVNOVO, 'DG3_CDACDV' )

				// Ajusta componentes
				if nDesce == 2 
					IF nOrigem == 1 // DPR
						For nK := 1 to (aDG1[1])->( RecCount() )
							(aDG1[1])->( dbGoTo(nK) )
							
							RecLock( (aDG1[1]), .F. )
							IF Empty((aDG1[1])->DG1_LGMTDV)
								(aDG1[1])->DG1_LGMTDV := '0'
							Endif
													
							IF Empty((aDG1[1])->DG1_CDMT) 
													
								IF AllTrim((aDG1[1])->NIVEL) == AllTrim((aDG0[1])->NIVEL) .AND.;
								Alltrim((aDG1[1])->CHAVE) == Alltrim((aDG0[1])->CHAVE) .AND.;
								AllTrim((aDG1[1])->DG1_CDMTDV) == AllTrim((aDG0[1])->DG0_CDACDV)
										
									(aDG1[1])->DG1_LGMTDV := '1'
									(aDG1[1])->DG1_CDMT   := ''
									(aDG1[1])->DG1_CDMTDV := (aDG0[1])->DG0_DVNOVO
									(aDG1[1])->DG1_NRVRMT := (aDG0[1])->DG0_NRVRAC
								Endif
							Endif
							
							MsUnlock()
						Next
					Else
						For nK := 1 to (aDG1[1])->( RecCount() )
							(aDG1[1])->( dbGoTo(nK) )
							
							RecLock( (aDG1[1]), .F. )
							IF Empty((aDG1[1])->DG1_LGMTDV)
								(aDG1[1])->DG1_LGMTDV := '0'
							Endif
																
							IF AllTrim((aDG1[1])->NIVEL) == AllTrim((aDG0[1])->NIVEL) .AND.;
							Alltrim((aDG1[1])->CHAVE) == Alltrim((aDG0[1])->CHAVE) .AND.;
							AllTrim((aDG1[1])->DG1_CDMT) == AllTrim((aDG0[1])->DG0_CDACDV)
								
								(aDG1[1])->DG1_LGMTDV := '1'
								(aDG1[1])->DG1_CDMT   := ''
								(aDG1[1])->DG1_CDMTDV := (aDG0[1])->DG0_DVNOVO
								(aDG1[1])->DG1_NRVRMT := (aDG0[1])->DG0_NRVRAC
							Endif
							
							MsUnlock()
						Next
					Endif
				Endif
				
				// Atualiza número da versão			
				(aDG0[1])->DG0_CDACDV := (aDG0[1])->DG0_DVNOVO			
				MsUnlock()
				
				// Carrega valores nos campos
				aCampos := oModelDG0:GetModel('DG0MASTER'):GetStruct():GetFields()
				For nJ := 1 To Len( aDG0[2] )-1
					If aScan(aCampos, { |x| AllTrim(x[3]) ==  AllTrim(aDG0[2,nJ,1]) } )  > 0
						If oModelDG0:GetModel('DG0MASTER'):CanSetValue( aDG0[2,nJ,1] ) .AND.;
						aDG0[2,nJ,1] != 'DG0_CDACPY' .AND.;
						aDG0[2,nJ,1] != 'DG0_DSVR'
							oModelDG0:LoadValue('DG0MASTER', aDG0[2,nJ,1], (aDG0[1])->&(aDG0[2,nJ,1]) )
						EndIf
					EndIf
				Next			
				
				//Valida se encontrou o produto na DG3
				If nOrigem == 1 // PROTOTIPO
					cProduto := POSICIONE("DG3",1,xFilial("DG3")+(aDG0[1])->DG0_CDACDV, "DG3_DSACDV") 
				Else // PCP
					cProduto := POSICIONE("SB1",1,xFilial("SB1")+(aDG0[1])->DG0_CDACDV, "B1_DESC") 
				EndIf 

				If Empty(cProduto)
					oModelDG0:SetErrorMessage('DG0MASTER', 'DG0_DSVR' , 'DG0MASTER' , 'DG0_DSVR' , 'Erro', STR0072 + (aDG0[1])->DG0_CDACDV + STR0073 , '') //'O Produto ' ## ' não foi encontrado.'
				Else 
					oModelDG0:SetValue('DG0MASTER', 'DG0_DSVR',	cProduto )
				EndIf			

				// Validação no Model
				If oModelDG0:VldData()
					// Caso nao ocorra erros, efetiva os dados no banco
					oModelDG0:CommitData()
				Else
					DPRXError('DPRA300', oModelDG0:GetErrorMessage()[6] )
					lRet := .F.
				EndIf

				// Desativa o Model
				oModelDG0:DeActivate()

			EndIf
		ENDIF
	Next
Endif

IF !lAutoMacao
	IncRegua()
ENDIF

if lRet

	// Adiciona os filhos de cada versão
	For nI := 1 to (aDG0[1])->( RecCount() )
		(aDG0[1])->( dbGoTo(nI) )

		IF !lAutoMacao
			If (aDG0[1])->EXIBE

				// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
				dbSelectArea('DG0')
				DG0->( dbSetOrder(1) )

				// Se foi encontrado, envia como Alteração
				If DG0->( dbSeek( xFilial('DG0') + (aDG0[1])->DG0_CDACDV + (aDG0[1])->DG0_NRVRAC ) )

					// Set a operação e Ativa o Model
					oModelDG0:SetOperation( 4 )
					oModelDG0:Activate()

					// Ajusta versão para sempre estar aberta
					oModelDG0:GetModel('DG0MASTER'):SetValue('DG0_TPST'  , '1')
					oModelDG0:GetModel('DG0MASTER'):SetValue('DG0_QTACEA', (aDG0[1])->DG0_QTACEA)

					If DPRIntegra() == 1
						IF nOrigem == 1
							cChave := AllTrim((aDG0[1])->CHAVE) + DPRA330BUS(2,(aDG0[1])->DG0_CDACDV) + (aDG0[1])->DG0_NROLD
						Else
							cChave := SubStr( (aDG0[1])->CHAVE , 1, (TamSX3("DG0_CDACDV")[1]+TamSX3("DG0_NRVRAC")[1])*(Val((aDG0[1])->NIVEL)-1) )
							cChave += POSICIONE( aDG3[1], 1, DPRA330BUS(2,(aDG0[1])->DG0_CDACDV), 'DG3_CDACDE')
						Endif
					EndIf

					// Define Componentes
					For nJ := 1 To (aDG1[1])->( RecCount() )
						(aDG1[1])->( dbGoTo(nJ) )

						If (aDG1[1])->EXIBE .And. AllTrim((aDG1[1])->NIVEL) == cValToChar(Val((aDG0[1])->NIVEL)+1) .And. ;
							( AllTrim(Substr( AllTrim((aDG1[1])->CHAVE), 1, len(cChave))) == AllTrim(cChave) .Or. Val((aDG1[1])->NIVEL) == 2 )
							
							if (aDG0[1])->DG0_CDACDV == (aDG1[1])->DG1_CDMTDV
								lRet := .F.	   						
								DPRXError('DPRA330', STR0071 ) // 'Componente possui o mesmo código do produto desenvolvido' 
							
								Exit
							Endif	   					

							// Carrega valores nos campos
							aCampos := oModelDG0:GetModel('DG1DETAIL'):GetStruct():GetFields()
							For nK := 1 to Len( aDG1[2] )
								If aScan(aCampos, { |x| AllTrim(x[3]) == AllTrim(aDG1[2,nK,1]) } )  > 0
									If oModelDG1:CanSetValue( aDG1[2,nK,1] )
										oModelDG1:LoadValue( aDG1[2,nK,1], (aDG1[1])->&(aDG1[2,nK,1]) )
									EndIf
								EndIf
							Next

							oModelDG1:AddLine()
						EndIf
					Next
					
					if !lRet
						Exit
					Endif

					// Define Atividades
					nAux := 0
					For nJ := 1 To (aDG9[1])->( RecCount() )
						(aDG9[1])->( dbGoTo(nJ) )

						If (aDG9[1])->EXIBE .And. AllTrim((aDG9[1])->NIVEL) == cValToChar(Val((aDG0[1])->NIVEL)+1) .And. ;
							( AllTrim(Substr( (aDG9[1])->CHAVE, 1, len(cChave))) == AllTrim(cChave) .Or. Val((aDG9[1])->NIVEL) == 2 )

							// Carrega valores nos campos
							aCampos := oModelDG0:GetModel('DG9DETAIL'):GetStruct():GetFields()
							For nK := 1 to Len( aDG9[2] )
								If aScan(aCampos, { |x| AllTrim(x[3]) ==  AllTrim(aDG9[2,nK,1]) } )  > 0
									If oModelDG9:CanSetValue( aDG9[2,nK,1] ) .and.;
									Alltrim(aDG9[2,nK,1]) != 'DG9_IDAT' .and.;
									Alltrim(aDG9[2,nK,1]) != 'DG9_CDAVDV' .AND.;
									Alltrim(aDG9[2,nK,1]) != 'DG9_NRVRAC'
										oModelDG9:LoadValue( aDG9[2,nK,1], (aDG9[1])->&(aDG9[2,nK,1]) )
									EndIf
								EndIf
							Next
							
							// Incluir alternativos do Roteiro
							if (aDG2[1])->( RecCount() ) > 0							
								if nOrigem == 1
									cChaveAlter := PadR(cValToChar(Val((aDG9[1])->NIVEL)+1),4, " ")+(aDG9[1])->DG9_CDACDV+(aDG9[1])->DG9_NRVRAC+(aDG9[1])->DG9_IDAT
									(aDG2[1])->(dbSetOrder(2))
								Else
									cChaveAlter := PadR(cValToChar(Val((aDG9[1])->NIVEL)+1),4, " ")+(aDG9[1])->DG9_CDRT+(aDG9[1])->DG9_CDATET
								Endif 
								
								if (aDG2[1])->(dbSeek(cChaveAlter))
									While (aDG2[1])->(!EOF()) .AND. (aDG2[1])->NIVEL == PadR(cValToChar(Val((aDG9[1])->NIVEL)+1),4, " ") .AND. ;
																		((nOrigem == 2 .AND. (aDG2[1])->DG2_CDRT == (aDG9[1])->DG9_CDRT .AND. (aDG2[1])->DG2_CDAT == (aDG9[1])->DG9_CDATET) .OR.;
																		nOrigem == 1 .AND. (aDG2[1])->DG2_CDACDV == (aDG9[1])->DG9_CDACDV .AND. (aDG2[1])->DG2_NRVRAC == (aDG9[1])->DG9_NRVRAC .AND. (aDG2[1])->DG2_IDAT == (aDG9[1])->DG9_IDAT)
										
										IF Empty((aDG2[1])->DG2_CDFE)
											oModelDG2R:SetValue( 'DG2_CDMQ', (aDG2[1])->DG2_CDMQ )
											oModelDG2R:SetValue( 'DG2_TPMQ', (aDG2[1])->DG2_TPMQ )
											oModelDG2R:SetValue( 'DG2_VLEF', (aDG2[1])->DG2_VLEF )
											
											oModelDG2R:AddLine()
										Else
											oModelDG2F:SetValue( 'DG2_CDFE', (aDG2[1])->DG2_CDFE )
											
											oModelDG2F:AddLine()								
										Endif
									
										(aDG2[1])->(dbSkip())
									End
								Endif							
							Endif
							
							oModelDG9:AddLine()
						EndIf
					Next

					// Validação no Model
					If oModelDG0:VldData()
						// Caso nao ocorra erros, efetiva os dados no banco
						oModelDG0:CommitData()
					Else
						DPRXError('DPRA330', oModelDG0:GetErrorMessage()[6] )
						lRet := .F.
					EndIf
					oModelDG0:Deactivate()

					// Cria Ficha
					// Quando versão não liberada, não considerar a versão         
					IF (aDG0[1])->DG0_TPST < '6'
						cChave := Substr(cChave,1,len(cChave) - 10)
					Endif
					
					For nJ := 1 to (aDGN[1])->( RecCount() )
						(aDGN[1])->( dbGoTo(nJ) )

						If (aDGN[1])->EXIBE .And. AllTrim((aDGN[1])->NIVEL) == cValToChar(Val((aDG0[1])->NIVEL)+1) .And. ;
						(AllTrim(Substr( (aDGN[1])->CHAVE, 1, len(cChave))) == AllTrim(cChave) .Or. Val((aDGN[1])->NIVEL) == 2 )

							oModelDGN:SetOperation(3)
							oModelDGN:Activate()

							oModelDGN:SetValue('DGNMASTER','DGN_CDACDV', (aDG0[1])->DG0_CDACDV)
							oModelDGN:SetValue('DGNMASTER','DGN_NRVRAC', (aDG0[1])->DG0_NRVRAC)
							oModelDGN:SetValue('DGNMASTER','DGN_CDMQ'  , (aDGN[1])->DGN_CDMQ)
							if oModelDGN:SetValue('DGNMASTER','DGN_CDMD'  , (aDGN[1])->DGN_CDMD)
								

								oModelDGO := oModelDGN:GetModel('DGODETAIL')
		
								if nOrigem == 1 // DP
									cProduto := DPRA330BUS(2,(aDGN[1])->DGN_CDACDV)
								
									dbSelectArea('DGO')
									DGO->(dbSetOrder(1))
									IF DGO->(dbSeek(xFilial('DGO')+cProduto+(aDGN[1])->DGN_NRVROR+(aDGN[1])->DGN_CDMQ+(aDGN[1])->DGN_CDMD))
										While DGO->(!EOF()) .AND. DGO->DGO_CDACDV == cProduto            .AND. DGO->DGO_NRVRAC == (aDGN[1])->DGN_NRVROR .AND.;
																DGO->DGO_CDMQ   == (aDGN[1])->DGN_CDMQ .AND. DGO->DGO_CDMD   == (aDGN[1])->DGN_CDMD
		
											For nK := 1 to oModelDGO:GetQtdLine()
												oModelDGO:GoLine(nK)
		
												if !oModelDGO:IsDeleted() .AND. oModelDGO:GetValue('DGO_CDAB') == DGO->DGO_CDAB
		
													cTpAtrib := Posicione('CZB',1,xFilial('CZB')+oModelDGO:GetValue('DGO_CDAB'),'CZB_TPAB')
		
													Do Case
														Case cTpAtrib == "F" // Flag
															oModelDGO:SetValue('DGO_VLFG', DGO->DGO_VLFG)
														Case cTpAtrib == "C" // Caracter
															oModelDGO:SetValue('DGO_VLCH', DGO->DGO_VLCH)
														Case cTpAtrib == "N" // Número
															oModelDGO:SetValue('DGO_VLNR', DGO->DGO_VLNR)
														Case cTpAtrib == "D" // Data
															oModelDGO:SetValue('DGO_VLDT', DGO->DGO_VLDT)
														Case cTpAtrib == "L" // Lista
															oModelDGO:SetValue('DGO_VLTB', DGO->DGO_VLTB)
														Case cTpAtrib == "A" // Faixa
															oModelDGO:SetValue('DGO_VLFX', DGO->DGO_VLFX)
														Case cTpAtrib == "M" // Memo
															oModelDGO:SetValue('DGO_VLNV', DGO->DGO_VLNV)
														Case cTpAtrib == "R" // Fórmula
															oModelDGO:LoadValue('DGO_VLFO', DGO->DGO_VLFO)
															oModelDGO:LoadValue('DGO_VLNR', DGO->DGO_VLNR)
														Case cTpAtrib == "T" // Tabela
															oModelDGO:SetValue('DGO_VLTBSI', DGO->DGO_VLTBSI)
														Case cTpAtrib == "I" // Imagem
															oModelDGO:SetValue('DGO_BITMAP',DGO->DGO_BITMAP)
														Case cTpAtrib == "O" // Tolerância
															oModelDGO:SetValue('DGO_VLNR'  , DGO->DGO_VLNR)
															oModelDGO:SetValue('DGO_VLAFMI', DGO->DGO_VLAFMI)
															oModelDGO:SetValue('DGO_VLAFMX', DGO->DGO_VLAFMX)
													EndCase
												Endif
											Next
		
											DGO->(dbSkip())
										End
									Endif
								Elseif nOrigem == 2 // PCP
									aAtributos := Get_Atributo_Ficha_Tecnica(DPRA330BUS(2,(aDGN[1])->DGN_CDACDV), (aDGN[1])->DGN_CDMQ, , (aDGN[1])->DGN_CDMD, (aDGN[1])->DGN_VRFH, )
		
									For nL := 1 to Len(aAtributos)
		
										For nK := 1 to oModelDGO:GetQtdLine()
											oModelDGO:GoLine(nK)
		
											if !oModelDGO:IsDeleted() .AND. oModelDGO:GetValue('DGO_CDAB') == aAtributos[nL][6]
		
												cTpAtrib := Posicione('CZB',1,xFilial('CZB')+oModelDGO:GetValue('DGO_CDAB'),'CZB_TPAB')
		
												Do Case
													Case cTpAtrib == "F" // Flag
														oModelDGO:SetValue('DGO_VLFG', if(aAtributos[nL][7] == '1','1','0'))
													Case cTpAtrib == "C" // Caracter
														oModelDGO:SetValue('DGO_VLCH', aAtributos[nL][7])
													Case cTpAtrib == "N" // Número
														oModelDGO:SetValue('DGO_VLNR', aAtributos[nL][7])
													Case cTpAtrib == "D" // Data
														oModelDGO:SetValue('DGO_VLDT', aAtributos[nL][7])
													Case cTpAtrib == "L" // Lista
														oModelDGO:LoadValue('DGO_VLTB', aAtributos[nL][7])
														oModelDGO:LoadValue('DGO_VLNR', aAtributos[nL][8])
													Case cTpAtrib == "A" // Faixa
														oModelDGO:SetValue('DGO_VLFX', aAtributos[nL][7])
													Case cTpAtrib == "M" // Memo
														oModelDGO:SetValue('DGO_VLNV', aAtributos[nL][7])
													Case cTpAtrib == "R" // Fórmula
														oModelDGO:LoadValue('DGO_VLFO', aAtributos[nL][7])
														oModelDGO:LoadValue('DGO_VLNR', aAtributos[nL][8])
													Case cTpAtrib == "T" // Tabela
														oModelDGO:SetValue('DGO_VLTBSI', aAtributos[nL][7])
													Case cTpAtrib == "I" // Imagem
														oModelDGO:SetValue('DGO_BITMAP', aAtributos[nL][7])
													Case cTpAtrib == "O" // Tolerância
														oModelDGO:SetValue('DGO_VLNR'  , aAtributos[nL][7])
														oModelDGO:SetValue('DGO_VLAFMI', aAtributos[nL][8])
														oModelDGO:SetValue('DGO_VLAFMX', aAtributos[nL][9])
												EndCase
											Endif
										Next nK
									Next nL
								Endif

								If oModelDGN:VldData()
									// Caso nao ocorra erros, efetiva os dados no banco
									oModelDGN:CommitData()
								Else
									DPRXError('DPRA330', oModelDGN:GetErrorMessage()[6] )
									lRet := .F.
								EndIf
							Else
								oModelDGN:VldData()
								DPRXError('DPRA330', 'Template não pode ser utilizado para este produto.'+;
											' Produto: ' + ALLTRIM((aDG0[1])->DG0_CDACDV) + ;
											' Template: ' + ALLTRIM((aDGN[1])->DGN_CDMD)+;
											CHR(13)+CHR(10)+oModelDGN:GetErrorMessage()[6];
										)
								lRet := .F.
							Endif
							
							oModelDGN:Deactivate()
						Endif
					Next
				EndIf
			EndIf
		ENDIF
	Next
Endif

IF !lAutoMacao
	IncRegua()
ENDIF

if lRet
	MsgInfo(STR0043, STR0044) // 'Processamento Finalizado' ## 'Fim'
Else
	MsgInfo(STR0045, STR0046) // 'Processamento Abortado' ## 'Erro'
Endif

IF !lRet
	DisarmTransaction()
Endif

END TRANSACTION

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA330BUS
Tela de Seleção

@author Samantha Preima
@since 12/03/2014
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA330BUS(nTipo,cMaterial)
Local cCodigo := ''
Local nI      := 0

if nTipo == 1 // Busca código novo
	For nI := 1 to (aDG3[1])->( RecCount() )
		(aDG3[1])->( dbGoTo(nI) )
		
		if (aDG3[1])->DG3_CDACDV == cMaterial
			cCodigo := (aDG3[1])->DG3_DVNOVO
			Exit
		Endif
	Next
Else // Busca código anterior
	For nI := 1 to (aDG3[1])->( RecCount() )
		(aDG3[1])->( dbGoTo(nI) )
		
		if (aDG3[1])->DG3_DVNOVO == cMaterial
			cCodigo := (aDG3[1])->DG3_CDACDV
			Exit
		Endif
	Next
Endif

if Empty(cCodigo)
	cCodigo := cMaterial
Endif

Return cCodigo

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA330SEL
Tela de Seleção

@author Ana Carolina Tome Klock
@since 29/06/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA330SEL()
Local cCDACDV		:= DG0->DG0_CDACDV
Local cNRVRAC		:= DG0->DG0_NRVRAC
Local aArea			:= DG0->( GetArea() )
Local aMenu 		:= { STR0011 } // 'Desenvolvedor Produto'
Local oDlg, oOrigem, oImport, oEstrut, oDPR, oPCP, oMEN, oMCF, oRoteiro
Local lIntPCP		:= If(DPRIntegra() == 1, .T., .F.)
Local oMenuOrig, oMenuEstru
Private nOrigem 	:= nDesce := 1
Private nRoteiro    := 1
Private lEstrut  	:= lOperac := .T.
Private lDescUN 	:= lFicha  := .F.
Private lAltEstrut 	:= lAltOperac := .F.
Private aEstrut  	:= { STR0016, STR0017 }   // 'Apenas 1º nível' ## 'Desce níveis'
Private aValor  	:= { Space( TamSX3('DG0_CDACDV')[1] ), Space( TamSX3('DG0_NRVRAC')[1] ), '', '' }
Private aRoteiro    := { STR0058, STR0059, STR0060, STR0061 } // 'Primeiro', 'Último', 'Padrão', 'Todos'
Default lAutoMacao  := .F.

// Permite importar apenas se estiver aberta
If DG0->DG0_TPST == '1'    // linha, coluna

	IF !lAutoMacao
		oDlg := MsDialog():New( 0, 0, 400, 605, STR0012,,,,, CLR_BLACK, CLR_WHITE,,, .T. ) // 'Seleção Importação'
		
		oOrigem  := TGroup():New(  35,  05,  180, 130, STR0013, oDlg,,, .T. )  // 'Origem'
		oImport  := TGroup():New(  35, 135,  100, 300, STR0014, oDlg,,, .T. )  // 'Importar'
		oEstrut  := TGroup():New(  105, 135, 180, 300, STR0015, oDlg,,, .T. )  // 'Estrutura'
		oRoteiro := TGroup():New(  105, 220, 170, 300, STR0062, oDlg,,, .T. )  // 'Roteiro'
		oDPR 	 := TPanel():New(  42,  8, , oOrigem,,,,, CLR_WHITE, 100, 100, .F., .F. )
		oPCP 	 := TPanel():New(  42,  8, , oOrigem,,,,, CLR_WHITE, 100, 100, .F., .F. )
		oMEN 	 := TPanel():New(  42,  8, , oOrigem,,,,, CLR_WHITE, 100, 130, .F., .F. )
		oMCF 	 := TPanel():New(  42,  8, , oOrigem,,,,, CLR_WHITE, 100, 100, .F., .F. )

		nAjuste := 15 
		// Origem: Desenvolvedor de Produtos
		TSay():New( 24 + nAjuste, 01, {|| STR0018	}, oDPR,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 )  // 'Produto Desenvolvido'
		TSay():New( 46 + nAjuste, 01, {|| STR0019	}, oDPR,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 )  // 'Versão'
		@ 32+ nAjuste,01 MsGet oCDACDV Var aValor[1] F3 "DG0005"       PICTURE "@!" 	Size 90, 10 Of oDPR Pixel HasButton
		@ 54+ nAjuste,01 MsGet oNRVRAC Var aValor[2] 			 				 	Size 90, 10 Of oDPR Pixel HasButton

		// Ajustes conforme integração
		If lIntPCP
			// Origem: PCP
			aAdd( aMenu, STR0020 ) 	// 'PCP'
			TSay():New( 24+ nAjuste, 01, {|| STR0021	}, oPCP,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 )  // 'Produto'
			@ 32+ nAjuste,01 MsGet oCDACDV Var aValor[1] F3 "CZ3001"   PICTURE "@!" 	Size 90, 10 Of oPCP Pixel HasButton
		Else
			// Origem: Engenharia
			aAdd( aMenu, STR0022 ) // 'Engenharia'
			TSay():New( 39, 01, {|| STR0021	}, oMEN,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // 'Produto'
			TSay():New( 61, 01, {|| STR0023	}, oMEN,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // 'Referência'
			TSay():New( 83, 01, {|| STR0024	}, oMEN,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // 'Roteiro'
			TSay():New( 104, 01, {|| STR0025	}, oMEN,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // 'Lista'
			@ 47,01 MsGet oCDACDV Var aValor[1] F3 "CZ3001"   PICTURE "@!"	Size 90, 10 Of oMEN Pixel HasButton
			@ 69,01 MsGet oCDREFE Var aValor[2] 							Size 90, 10 Of oMEN Pixel HasButton
			@ 91,01 MsGet oCDROTE Var aValor[3]             				Size 90, 10 Of oMEN Pixel HasButton
			@ 112,01 MsGet oCDLIST Var aValor[4]   		  					Size 90, 10 Of oMEN Pixel HasButton

			// Origem: Configurador
			aAdd( aMenu, STR0026 ) // 'Configurador Produto'
			TSay():New( 39, 01, {|| STR0021	}, oMCF,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 )  // 'Produto'
			TSay():New( 61, 01, {|| STR0027	}, oMCF,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // 'Configuração'
			@ 47,01 MsGet oCDACDV Var aValor[1] F3 "CZ3001"   PICTURE "@!" 	Size 90, 10 Of oMCF Pixel HasButton
			@ 69,01 MsGet oCONFIG Var aValor[2] 							Size 90, 10 Of oMCF Pixel HasButton
		EndIf

		// Menu da Estrutura
		oMenuEstru := TRadMenu():Create( oEstrut,, 115, 140, aEstrut,,,,,,,,100,12,,,,.T.)
		oMenuEstru:bSetGet := { |nOpc| If(PCount()==0, nDesce, nDesce := nOpc ) }
		
		// Menu de Roteiro
		oMenuRot := TRadMenu():Create( oRoteiro,, 115, 225, aRoteiro,,,,,,,,100,12,,,,.T.)
		oMenuRot:bSetGet := { |nOpc| If(PCount()==0, nRoteiro, nRoteiro := nOpc ) }
		
		oMenuRot:SetOption(1)

		// Menu da Origem
		oMenuOrig 	:= TRadMenu():Create( oOrigem, , 43, 10, aMenu,,,,,,,, 100, 12,,,,.T.,.F.) //TRadMenu():New( 23, 10, aMenu, , oOrigem,,,,,,,, 100, 12,,,, .F.)
		oMenuOrig:bSetGet := { |nOpc| If(PCount()==0, nOrigem, nOrigem := nOpc) }
		oMenuOrig:bChange := { | | 	If( nOrigem == 1,	EVal( { || oDPR:Show(), oPCP:Hide(), oMEN:Hide(), oMCF:Hide(), oMenuRot:Hide(), oRoteiro:Hide() } ) ,;
						If(nOrigem == 2 .And.  lIntPCP,	EVal( { || oDPR:Hide(), oPCP:Show(), oMEN:Hide(), oMCF:Hide(), oMenuRot:Show(), oRoteiro:Show() } ) ,;
						If(nOrigem == 2 .And. !lIntPCP,	EVal( { || oDPR:Hide(), oPCP:Hide(), oMEN:Show(), oMCF:Hide() } ) ,;
														EVal( { || oDPR:Hide(), oPCP:Hide(), oMEN:Hide(), oMCF:Show() } )))) }
		oMenuOrig:SetOption(1)

		@ 70, 10 Checkbox oCheck6 Var lDescUN PROMPT STR0066 Size 100, 10 Pixel Of oOrigem //Descrição e UN do Produto Destino
		
		// Menu da Importação
		@ 45,140 Checkbox oCheck1 Var lEstrut  	 	 PROMPT STR0015	Size 100, 10 Pixel Of oImport   // 'Estrutura'
		//Somente apresenta a o botão se o ficha estiver ativo e a versão for maior ou igual que 11 release 9
		If FindFunction("DPRFicha") .AND. DPRFicha(1)
			@ 60,140 Checkbox oCheck5 Var lFicha  	 	 PROMPT STR0063	Size 100, 10 Pixel Of oImport // 'Ficha Técnica'
		Endif
		@ 60,140 Checkbox oCheck3 Var lOperac		 PROMPT STR0028	Size 100, 10 Pixel Of oImport	// 'Operação' 
		If DPRIntegra() == 2
			@ 90,140 Checkbox oCheck2 Var lAltEstrut PROMPT STR0029	Size 100, 10 Pixel Of oImport  	// 'Estrutura Alternativa'
			@ 105,140 Checkbox oCheck4 Var lAltOperac PROMPT STR0030	Size 100, 10 Pixel Of oImport	// 'Operação Alternativa'
		EndIf

		// Ativação da janela de seleção
		Activate MsDialog oDlg Centered On Init EnchoiceBar( oDlg, { || RestArea(aArea), If( cCDACDV == aValor[1] .And. cNRVRAC == aValor[2] .And. nOrigem == 1, ;
																		alert(STR0039), ; // 'A versão informada deve ser diferente da versão posicionada'
																		DPRA330() ) }, { || oDlg:End() } )
	ENDIF
Else
	DPRXError('DPRA330', 'DPRA330_ABERTA', 3 )

EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA330STR
Cria uma TreeView para a Estrutura do Item Selecionado

@param 		oPanel		Owner da TreeView
@param		nOpera		Número da operação

@author Ana Carolina Tome Klock
@since 20/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA330STR( oPanel )
Local aCoords  := oPanel:GetClientRect()

// Cria a Tree
oTree := DbTree():New( 0, 0, (aCoords[4]/2), (aCoords[3]/2), oPanel, , , .T.)

(aDG0[1])->( dbGoTo(1) )
If AllTrim((aDG0[1])->NIVEL) == '1'
	oTree:BeginUpdate()

	// Adiciona o item pai na estrutura
	oTree:AddItem( (aDG0[1])->PROMP, (aDG0[1])->CARGO, (aDG0[1])->IMAGE, (aDG0[1])->IMAGE )

	// Adiciona os itens filhos na estrutura
	DPRASEARCH( oTree, 1, { lEstrut, lOperac, lAltEstrut, lAltOperac, If (nDesce==2,.T.,.F.), lFicha },,nOrigem )

	// Término da contrução da Tree
	oTree:EndUpdate()
	oTree:EndTree()
EndIf

Return oTree

//-------------------------------------------------------------------
/*Static Function INTEGDEF(cXml, nTypeTrans, cTypeMessage)
Local lRet       	:= .T.
Local cXMLRet    	:= ''
Local cError 	 	:= ''
Local cWarning 	:= ''
Local oXML, oMessage, oFWEAI

// Se for requisitado pelo DPRA330
If cTypeMessage == 'DPRA330INT'

	// Se for um configurado, altera os parâmetros
	If nOrigem == 3
		aDatasul[1] := aConfig[1]
		aDatasul[2] := aConfig[2]
		aDatasul[3] := ' '
		aDatasul[4] := ' '
	EndIf

	// Montagem da mensagem
	oFWEAI := FWEAI():New()
	oFWEAI:SetFuncCode( 'GetItemVersion' )
 	oFWEAI:SetFuncDescription( 'GetItemVersion' )
  	oFWEAI:SetTypeMessage( 'BusinessMessage' )
   	oFWEAI:SetSendChannel( 'EAI' )
   	oFWEAI:SetDocType( '1' )
   	oFWEAI:GetTransactions( 1 )
   	oFWEAI:Activate()
   	cXMLRet :=  FWEAIBusEvent( 'GetItemVersion', 3, { { 'ItemSource', If(nOrigem==2, '1', '3') } }  )
	cXMLRet += '<BusinessContent>'
	cXMLRet += '<ItemSource>' 			+ If ( nOrigem==2, '1', '3')	+ '</ItemSource>'
	cXMLRet += '<ItemCode>' 				+ aDatasul[1]  					+ '</ItemCode>'
	cXMLRet += '<ReferenceCode>' 		+ aDatasul[2]						+ '</ReferenceCode>'
	cXMLRet += '<RoutingCode>' 	    	+ aDatasul[3]						+ '</RoutingCode>'
	cXMLRet += '<ComponentListCode>'   + aDatasul[4]						+ '</ComponentListCode>'
	cXMLRet += '<ConfigurationCode>'	+ aDatasul[2]						+ '</ConfigurationCode>'
	cXMLRet += '<ListOfAttributes>'
	dbSelectArea('DGB')
	If dbSeek( xFilial('DGB') )
		While DGB->(!EOF())
			cXMLRet += '<Attribute>'
			cXMLRet += '<AttributeSource>' 	+ DGB->DGB_CDTB   + '</AttributeSource>'
			cXMLRet += '<AttributeCode>' 	+ DGB->DGB_DSABDE + '</AttributeCode>'
			cXMLRet += '</Attribute>'
			DGB->(dbSkip())
		End
	EndIf
	cXMLRet += '</ListOfAttributes>'
	cXMLRet += '</BusinessContent>'
	oFWEAI:AddLayout( 'GetItemVersion', '1.000', '', cXMLRet )
	oFWEAI:Save()
	oFWEAI:BuildBusiness()

	// Envia a mensagem e aguarda resposta
   	oMessage := WSEAIDatasul():New()
   	oMessage:_HEADOUT := { "Authorization: Basic "+ Encode64(SuperGetMv('MV_EAIUSER',.F.,'')+":"+ SuperGetMv('MV_EAIPASS',.F.,'')) }
	oMessage:_URL := SuperGetMv('MV_EAIURL2',.F.,'')
	oMessage:cINMSG := oFWEAI:cXML
	oMessage:ReceiveMessage()
	cXml := oMessage:CRECEIVEMESSAGERESULT

	// Cria um objeto XML a partir da estutura dos dados do Model
	oXML := XmlParser(FwNoAccent(cXml), '_', @cError, @cWarning)

	// Inicia a montagem dos arrays
	If oXML != NIL
		If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
			oBusinessContent := oXML:_TOTVSMessage:_ResponseMessage

			If XmlChildEx(oBusinessContent, "_RETURNCONTENT") != NIL
				oBusinessContent := oBusinessContent:_ReturnContent
				DPRXINTREE( oBusinessContent )
	   		EndIf
   		EndIf
	EndIf

	If len( aDG0 ) == 0
		aAdd( aDG0, { aDatasul[1], '0000000000' } )
	Else
		aDG0[1][len(aDG0[1])-3] := .T.
	EndIf
EndIf

Return { lRet, cXMLRet }*/
