#INCLUDE 'DPRA342.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

#DEFINE PULALINHA CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA342
Tela de Liberação de Versão Produto

@author Samantha Preima
@since 01/02/2013
@version P11
/*/
//-------------------------------------------------------------------
Function DPRA342()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA342', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG0')
oBrowse:SetDescription( STR0001 ) // Liberação de Versão Produto
oBrowse:AddFilter( STR0002, "DG0_TPST=='3' .OR. DG0_TPST=='4' .OR. DG0_TPST=='5'", .T., .T.) // Aprovados
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina	:= {}
	Local lFicha	:= .F.
	If FindFunction("DPRFicha")
		lFicha := DPRFicha(1)
	EndIf
	
	aAdd( aRotina, { STR0003, 'PesqBrw'        , 0, 1, 0, NIL } ) // Pesquisar
	aAdd( aRotina, { STR0004, "DPRA342LIB()"   , 0, 2, 0, .F.} )  // Liberar
	aAdd( aRotina, { STR0008, 'VIEWDEF.DPRA300', 0, 2, 0, NIL } ) // Visualizar
	
	If lFicha
		aAdd( aRotina, { STR0034, 'DPRA342P(.T.)', 0, 3, 0, nil } ) // Parâmetros
	Endif
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructDG0 := FWFormStruct( 1, 'DG0', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRA342', /*bPreValidacao*/, /*pos*/, /*commit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DG0MASTER', /*cOwner*/, oStructDG0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0005 ) // Modelo de Dados Versão Desenvolvimento

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DG0MASTER' ):SetDescription( STR0006 ) // Dados Versão Desenvolvimento

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRA342' )
// Cria a estrutura a ser usada na View
Local oStructDG0 := FWFormStruct( 2, 'DG0' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DG0', oStructDG0, 'DG0MASTER' )

// Cria um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_DG0', 'SUPERIOR' )

Return oView

//-------------------------------------------------------------------
Function DPRA342P(lExibe)
Local lRet := .T.

if !Pergunte( 'DPRA342A', lExibe )
	lRet := .F.
Endif

Return LRet
//-------------------------------------------------------------------
Function DPRA342LIB()
	Local lRet		 := .T.
	Local oView	     := FwViewActive()
	Local nQtd		 := 0
	Local lFilho     := .F.
	Local cMens      := ''
	Local cAliasDGP  := GetNextAlias()
	Local cCodRot    := ""
	Local nI         := 0
	Local lRoteiro   := .T.
	Local lDPRQIP    := SuperGetMV('MV_DPRQIP',.F.,.F.)
	Local lRunPCP124 := ExistFunc('PCPA124')
	
	Private lEstrut         := .F.
	Private lOper           := .F.
	Private lMsErroAuto     := .F.
	Private lAutoErrNoFile  := .T. // Para conseguir pegar os erros
	Private lFicha          := .F.
	Private cLog            := ''
	Private aEspec          := {}
	
	If FindFunction("DPRFicha")
		lFicha := DPRFicha(1)
	EndIf
	
	if !DPRA341CRI(DG0->DG0_CDACDV, DG0->DG0_NRVRAC)
		DPRXError('DPRA342', 'DPRA341_CRIT', 3 ) // Produto Desenvolvido não possui todos os critérios verificados
		lRet := .F.
	Else
		// Quando cadastros comparilhados e movimentações exclusivas
		// Verificar se existe pendência para uma filial diferente da filial logada pelo usuário
		if DPRXCOMP(1)
		
			BeginSql Alias cAliasDGP
			    	
				Select * from %Table:DGP% DGP
					WHERE DGP.DGP_CDACDV=%Exp:DG0->DG0_CDACDV% AND
						  DGP.DGP_NRVRAC=%Exp:DG0->DG0_NRVRAC% AND
						  DGP.%NotDel%
			EndSql
			
			IF !Empty((cAliasDGP)->DGP_IDIC) .and. (cAliasDGP)->DGP_FILIAL != xFilial('DGP')
				DPRXError( 'DPRA342', STR0057 + (cAliasDGP)->DGP_FILIAL, 1, STR0058 ) // 'Foi encontrada pendência na filial ' ## 'Acesse o módulo SIGADPR através desta filial.' 
				lRet := .F.
			Endif
			
			(cAliasDGP)->(dbCloseArea())
		Endif
		
		if lRet
	
			dbSelectArea('DG1')
			DG1->(dbSetOrder(3))
			if DG1->(dbSeek(xFilial('DG1')+DG0->DG0_CDACDV+DG0->DG0_NRVRAC+'1'))
				lFilho := .T.
			Endif
		
			Do Case
				Case DG0->DG0_TPST == '3'
					if lFilho
						cMens := STR0019 // 'Esta versão possui apenas estrutura aprovada, somente serão liberadas as estruturas do produto e dos componentes, confirma?'
					Else
						cMens := STR0009 // Esta versão possui apenas estrutura aprovada, somente a estrutura será liberada, confirma?
					Endif
					
					if MSGYESNO(cMens) 
						lEstrut := .T.
					Else
						lRet := .F.
					Endif
				Case DG0->DG0_TPST == '4'
					if lFilho
						cMens := STR0020 // 'Esta versão possui apenas operações aprovadas, somente serão liberadas as operações do produto e dos componentes, confirma?'
					Else
						cMens := STR0010 // Esta versão possui apenas operações aprovadas, somente as operações serão liberadas, confirma?
					Endif
				
					if MSGYESNO(cMens)
						lOper := .T.
					Else
						lRet := .F.
					Endif
				Case DG0->DG0_TPST == '5'
					if lFilho
						cMens := STR0041 // 'Confirma liberação da estrutura e operações do produto e dos componentes?'
					Else
						cMens := STR0011 // Confirma liberação de estrutura e operações desta versão?
					Endif
					
					if MSGYESNO(cMens)
						lEstrut := .T.
						lOper   := .T.
					Else
						lRet := .F.
					Endif
			End Case
			
			If lRet .AND. lDPRQIP .AND. lOper .AND. SuperGetMV('MV_QIPMAT',.F.,'N') == 'N'
				lRet := .F.
				// Tem roteiro gerado, mas parâmetro MV_QIPMAT está desativado. Processo será cancelado.
				DPRXError('DPRA342', 'DPRA342_QIPMAT', 3)
			Endif
			
			IF lRet
				
				// Verifica quantas liberações serão feitas e lista de roteiros
				nQtd := DPRA342DE2(DG0->DG0_CDACDV,DG0->DG0_NRVRAC)
				
				If lRunPCP124
					cCodRot := A124DPCod(Posicione('DG3',1,xFilial('DG3')+DG0->DG0_CDACDV,'DG3_CDACDE'))
				Else
					cCodRot := A632DPCod(Posicione('DG3',1,xFilial('DG3')+DG0->DG0_CDACDV,'DG3_CDACDE'))
				EndIf

				aadd(aEspec,{DG0->DG0_CDACDV, DG0->DG0_NRVRAC, DG0->DG0_CDRT, DG0->DG0_CDRTOG, if(Empty(DG0->DG0_CDRTDE),cCodRot,DG0->DG0_CDRTDE)})
				
				If lDPRQIP .AND. lOper
				
					if Len(aEspec) > 0				
						For nI := 1 to Len(aEspec)
							IF Empty(aEspec[nI][3])
								lRoteiro := .F.
								Exit
							Endif
						Next
					Else
						lRoteiro := .F.
					Endif 
						
					IF lRoteiro // Se todos DG0_CDRT estiverem preenchidos, apresentar msg
						if !MSGYESNO(STR0048) // 'As operações no SIGAQIP podem estar diferentes das operações no SIGADPR. Deseja continuar?'
							lRet := .F.
						Endif
					Endif
				Endif
				
				IF lRet .AND. Len(aEspec) > 0
					lRet := DPRA342DG0(lDPRQIP)
				Endif 
			Endif
		Endif
	Endif

	If lRet
		LibVersao(DG0->DG0_CDACDV, DG0->DG0_NRVRAC,nQtd)	
	Endif
	
	IF oView != NIL .And. oView:isActive()
		oView:Refresh()
	Endif
Return Nil
//-------------------------------------------------------------------
Static Function LibVersao(cProd,cVersao,nQtd)

	Private oDlgProg
	Private nAtuTotal
	Private oMtTotal, oProg
	Private nProg := 0
	Private cProg := Space(100)
	Default lAutomacao := .F.

	If !lAutomacao
		DEFINE DIALOG oDlgProg TITLE STR0051 FROM 0, 0 TO 22, 75 SIZE 410, 150 PIXEL //"Carregando..."
	
		@ 010,010 SAY oSay VAR STR0052 OF oDlgProg PIXEL FONT (TFont():New('Arial', 0, -11, .T., .T.))//"Versões Liberadas:"
		@ 020,010 METER oMtTotal VAR nAtuTotal TOTAL 1000 SIZE 190, 15 OF oDlgProg UPDATE PIXEL
		@  40,010 SAY oProg VAR cProg OF oDlgProg PIXEL

		oMtTotal:nTotal := nQtd
		oMtTotal:Set(nProg)
		SysRefresh()

		ACTIVATE MSDIALOG oDlgProg CENTER ON INIT DPRA342CL(cProd,cVersao)
	EndIf

Return Nil
//-------------------------------------------------------------------
Function DPRA342CL(cProd,cVersao)
	Local nHandle
	Local cArquivo  := "liberação.log"
	Local lRet		:= .T.
	Local lContinuou  := .T. 
	Private aPrdLib := { }

	Begin Transaction
	
		DPRA342Vld(cProd,cVersao)
				
		if(DPRA342Prd())
		   DPRA342DES(cProd,cVersao)

		   If !lAutomacao
		 	   oDlgProg:End()
		   EndIf

   		   If !Empty(cLog)
			   lRet := .F.
			   If !lAutomacao
			   		nHandle := FCreate(GETTEMPPATH() + cArquivo) // gera
			   		FWrite(nHandle, cLog) // imprime
			   		FClose(nHandle) // fecha						
			
			   		ShellExecute("open",GETTEMPPATH() + cArquivo,"","",5) // 5=abre
				EndIf
		   Endif

		   IF !lRet
			   DisarmTransaction()
		   Endif
		Else 
		   oDlgProg:End()
		   lContinuou := .F.
		   DisarmTransaction()
		Endif   
	
	End Transaction
	
	If( lContinuou ) 
	   If lRet
	      DPRXError('DPRA342',STR0050,2) // 'Liberação realizada com sucesso'
	   Else
	      If !lAutomacao
		  		DPRXError('DPRA342',STR0012 + PULALINHA + STR0013 + cArquivo + " em " + GETTEMPPATH(),2) // Foram gerados erros durante o processo. # Gerado arquivo #
		  EndIf
	   EndIf
	Endif

Return Nil

//---------------------------------------------------------------------------
// Exibe lista dos produtos sem especificação
//---------------------------------------------------------------------------
Static Function DPRA342DG0(lDPRQIP)
Local lRet     := .T.
Local cRoteiro := ''
Local lWhen    := .T.
Local cMsg     := ''
Default lDPRQIP := .F.
Default lAutomacao := .F.

if lDPRQIP
	cMsg := STR0059 + STR0060 // 'Os produtos desenvolvidos que não possuem Roteiro Protótipo, estão sem Especificação Processo (QIP). ' ## 'O Roteiro Destino será utilizado para liberação das operações'
Else
	cMsg := STR0060 // 'O Roteiro Destino será utilizado para liberação das operações'
Endif

If !lAutomacao
	DEFINE DIALOG oDlg TITLE STR0042 FROM 180,180 TO 430,800 PIXEL // 'Produtos Desenvolvidos'

	oSay1 := TSay():New(  04, 05, {|| STR0043 }, oDlg,,,,,, .T., CLR_BLACK, CLR_WHITE, 300, 20 ) // 'Os produtos desenvolvidos abaixo não possuem Roteiro Protótipo e estão sem Especificação Processo (QIP), deseja continuar liberação?'

	// Cria Browse
	oBrowse := TCBrowse():New( 23, 05, 240, 70,,{STR0046, STR0047, STR0061, STR0062, STR0063},{75,35,40,40,40},oDlg,,,,,{||},,,,,,,.F.,,.T.,{|| .T. },.T.,,, ) // 'Produto Desenvolvido' ## 'Versão' ## 'Roteiro Prot' ## 'Roteiro Origem' ## 'Roteiro Destino'

	// Seta array para o browse
	oBrowse:SetArray(aEspec)

	// Atualiza valores nos campos
	oBrowse:bChange := { || cRoteiro := aEspec[oBrowse:nAt,5] }

	oBTNAlt := TButton():New( 95, 205, STR0064, oDlg, {|| lWhen := .F., oAltera:Show(), oPanel:Show(), oBTNAlt:Hide(),cRoteiro := aEspec[oBrowse:nAt,5]  },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // 'Alterar'

	oAltera := TGroup():New(  24, 248, 90, 310, '', oDlg,,, .T. )
	oPanel  := TPanel():New(  24, 250, STR0065, oAltera,,,,, CLR_WHITE, 40, 60, .F., .F. ) // 'Alteração'

	oSay1 := TSay():New(  10, 01, {|| STR0066 }, oPanel,,,,,, .T., CLR_BLACK, CLR_WHITE, 50, 20 ) // 'Roteiro Destino'
	@ 18, 01 MsGet oROTEIRO Var cRoteiro Size 40 , 10 Of oPanel Pixel HasButton PICTURE '@!'

	oBTN1 := TButton():New( 35, 01, STR0067, oPanel,{|| aEspec[oBrowse:nAt,5] := cRoteiro, oBrowse:Refresh(),lWhen := .T., oBTNAlt:Show(), oAltera:Hide(), oPanel:Hide()  },30,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // 'Salvar'
	oBTN2 := TButton():New( 50, 01, STR0068, oPanel,{|| cRoteiro := aEspec[oBrowse:nAt,5], lWhen := .T., oBTNAlt:Show(), oAltera:Hide(), oPanel:Hide() },30,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // 'Cancelar 

	oPanel:Hide()
	oAltera:Hide()

	oBrowse:Refresh()

	// Arruma os dados na linha
	oBrowse:bLine := { || { aEspec[oBrowse:nAt,1], aEspec[oBrowse:nAt,2],aEspec[oBrowse:nAt,3],aEspec[oBrowse:nAt,4],aEspec[oBrowse:nAt,5] } }

	oBTN1 := TButton():New( 111, 220, STR0044, oDlg,{|| lRet := .T., oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // 'Continuar'
	oBTN2 := TButton():New( 111, 265, STR0045, oDlg,{|| lRet := .F., oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) // 'Cancelar'
        
	Activate MsDialog oDlg Centered
EndIf

Return lRet

//---------------------------------------------------------------------------
// Desce estrutura para verificar roteiro dos filhos desenvolvidos preenchendo array caso roteiro vazio
// Retorna a quantidade de produtos desenvolvidos encontrados na estrutura completa
//--------------------------------------------------------------------------- 
Static Function DPRA342DE2(cProd, cVers)
	Local aAreaDG1	 := DG1->(GetArea())
	Local aAreaDG0	 := DG0->(GetArea())         
	Local lRunPCP124 := ExistFunc("PCPA124")
	Local cCodRot    := ""
	Local nPos		 := 1
	
	dbSelectArea('DG1')
	DG1->(dbSetOrder(3))
	if DG1->(dbSeek(xFilial('DG1')+cProd+cVers+'1'))
		While DG1->(!EOF()) .AND. DG1->DG1_CDACDV == cProd .AND. DG1->DG1_NRVRAC == cVers .AND. DG1->DG1_LGMTDV == '1'
			dbSelectArea('DG0')
			DG0->(dbSetOrder(1))

			if DG0->(dbSeek(xFilial('DG0')+DG1->DG1_CDMTDV+DG1->DG1_NRVRMT)) .AND. (DG0->DG0_TPST == '4' .OR. DG0->DG0_TPST == '5') .AND. DG9->(dbSeek(xFilial('DG9')+DG1->DG1_CDMTDV+DG1->DG1_NRVRMT))
				If Empty(DG0->DG0_CDRTDE)
					If lRunPCP124
						cCodRot := A124DPCod(Posicione('DG3',1,xFilial('DG3')+DG0->DG0_CDACDV,'DG3_CDACDE'))
					Else
						cCodRot := A632DPCod(Posicione('DG3',1,xFilial('DG3')+DG0->DG0_CDACDV,'DG3_CDACDE'))
					EndIf
				Else
					cCodRot := DG0->DG0_CDRTDE
				EndIf

				aadd(aEspec,{DG0->DG0_CDACDV,DG0->DG0_NRVRAC,DG0->DG0_CDRT,DG0->DG0_CDRTOG,cCodRot})
			Endif
			
			nPos := nPos + DPRA342DE2(DG1->DG1_CDMTDV,DG1->DG1_NRVRMT)
			
			DG1->(dbSkip())
		End
	Endif

	RestArea(aAreaDG1)
	RestArea(aAreaDG0)

Return nPos


//---------------------------------------------------------------------------
// Realizará validação dos produtos e versões que serão liberados, se eles já foram liberados anteriormente e a liberação resultou na solução de 
// uma pendência no DPRA350, alertar o usuário e verificar se deve ou não dar continuidade no processo
//---------------------------------------------------------------------------
Static Function DPRA342Vld(cProd, cVers)
Local aArea   	:= GetArea()
   
   DRAP350PFa(cProd,cVers)      
  
	dbSelectArea('DG1')
	DG1->(dbSetOrder(1))
	DG1->(dbSeek(xFilial('DG1')+cProd+cVers))
	
	While( (!DG1->(eof())) .AND. (DG1->DG1_FILIAL+DG1->DG1_CDACDV+DG1->DG1_NRVRAC==xFilial('DG1')+cProd+cVers))
	   IF DG1->DG1_LGMTDV == '1'
	      DPRA342Vld(DG1->DG1_CDMTDV, DG1->DG1_NRVRMT)
	   Endif
	      
	   DG1->(dbSkip())    	   
	Enddo 
	   
     
  
RestArea(aArea)

ReturN

//----------------------------------------------------------------------------------------------
//Apresenta na tela os produtos associados a pendências e que já foram resolvidos no faturamento
//----------------------------------------------------------------------------------------------
Static Function DPRA342Prd()
Local lRet := .F.
Local nLin := 0
Local oDlg, oQual
Local cCadastro := OemToAnsi(STR0069)	//"Produtos já corrigidos no faturamento"
   
If(Len(aPrdLib)>0)
	Alert(STR0070) //"Alguns produtos já possuem pendências resolvidas, as mesmas não serão alteradas no SIGAFAT"      
   	   
	DEFINE MSDIALOG oDlg TITLE cCadastro From 09,0 To 30.5,74 OF oMainWnd
	@ 0.5,0.5 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(STR0046),OemToAnsi(STR0047),OemToAnsi(STR0071),SIZE 250,150    //"Produto"###"Versão"  //Colocar include
	oQual:SetArray(aPrdLib)
	oQual:bLine := {|| {aPrdLib[oQual:nAT][1],aPrdLib[oQual:nAT][2],aPrdLib[oQual:nAT][3]}}
	oQual:lHScroll := .F.
	DEFINE SBUTTON FROM 50 ,260  TYPE 1 ACTION (lRet := .T., oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 65 ,260  TYPE 2 ACTION (lRet := .F., oDlg:End()) ENABLE OF oDlg	          
   	ACTIVATE MSDIALOG oDlg  
Else       
	lRet := .T.
Endif   

Return lRet

//---------------------------------------------------------------------------
// Desce estrutura para liberar os filhos
//---------------------------------------------------------------------------
Static Function DPRA342DES(cProd, cVers)
Local lRet     := .T.
Local lRunPCP124 := ExistFunc('PCPA124')
Local oModel   := FWLoadModel( 'DPRA342' )
Local oModelRot
Local oMdlRotSG2
Local oModelCZ3
Local aDetalhe := {}
Local aItem    := {}
Local aCab     := {}
Local nPosDG1, nPosDG0, nPosCZ3, nPosDG3
Local cItemPai := ''
Local nOpc     := 3
Local cState   := ''
Local cRot     := ''
Local cModelId   := Iif(lRunPCP124,"PCPA124_CAB","MATA632_CAB")
Local nTam     := TamSX3('B1_COD')[1]
Local nI       := 0
Local nQtd     := 0
Local aDadosSB5 := {}
Local lParam1
Local lParam2
Local aObjetos  := {}
Local aRetorno  := {}
Local lEspec    := .F.
Local aRelac    := {}
Local cFilho    := ''
Local lFoundSB5 := .F.
Local lAltEstru := .F.
Local oJsonEstr
Local aEstru    := {}
Local nIndEstru := 0
Private lMsErroAuto := .F.
Private aRotina     := MenuDef()
Default lAutomacao 	:= .F.

Pergunte('DPRA342A',.F.)

lParam1 := if(MV_PAR01==nil .OR. Empty(MV_PAR01),1,MV_PAR01) == 2
lParam2 := if(MV_PAR02==nil .OR. Empty(MV_PAR02),1,MV_PAR02) == 2

dbSelectArea('DG0')
DG0->(dbSetOrder(1))
DG0->(dbSeek(xFilial('DG0')+cProd+cVers))

Do Case
	Case DG0->DG0_TPST == '3'
		cState := '6'
	Case DG0->DG0_TPST == '4'
		cState := '7'
	Case DG0->DG0_TPST == '5'
		cState := '8'
End Case

If !lAutomacao
	oProg:cCaption := STR0053 + " " + AllTrim(cProd) + " " + STR0047 + " " + AllTrim(cVers) + "." //"Liberando produto x Versão x."
Else
	cState  := '6'
	lOper   := .T.
	lFicha  := .T.
	lEspec  := .T.
	lParam1 := 2
	lParam2 := 2
EndIf

If Empty(cState)
	nProg := nProg + DPRA342DE2(DG0->DG0_CDACDV,DG0->DG0_NRVRAC) - 1
	oMtTotal:Set(nProg)
	SysRefresh()
Else
	nProg++
	If !lAutomacao
		oMtTotal:Set(nProg)
		SysRefresh()
	EndIf
	// Verifica os critérios da versão
	IF !DPRA341CRI(DG0->DG0_CDACDV, DG0->DG0_NRVRAC)
		cLog += STR0014 + ALLTRIM(DG0->DG0_CDACDV) + STR0015 + ALLTRIM(DG0->DG0_NRVRAC) + " - " + STR0016 + PULALINHA // Produto Desenvolvido: # Versão: # Produto Desenvolvido não possui todos os critérios verificados
		lRet := .F.
	Else	
		dbSelectArea('DG3')
		DG3->(dbSetOrder(1))
		DG3->(dbSeek(xFilial('DG3')+DG0->DG0_CDACDV))
		
		cItemPai := PadR(DG3->DG3_CDACDE,nTam)
	
		dbSelectArea('CZ3')
		CZ3->(dbSetOrder(1))
		if !CZ3->(dbSeek(xFilial("CZ3")+cItemPai)) .OR. CZ3->CZ3_CDAC != cItemPai
			aCab := {	{'B1_COD'    , cItemPai			       , Nil},;
						{'B1_DESC'   , AllTrim(DG3->DG3_DSACDE), Nil},;
						{'B1_UM'     , Alltrim(DG3->DG3_CDUNDE), Nil},;
						{'B1_SEGUM'  , AllTrim(DG3->DG3_CDUN2) , Nil},;
						{'B1_CONV'   , DG3->DG3_VLPNUN         , Nil},;
						{'B1_TIPCONV', If(DG3->DG3_TPPNUN == '1', 'M', 'D'), Nil},;
						{'B1_TIPO'   , AllTrim(DG3->DG3_CDFA)  , Nil},;
						{'B1_GRUPO'  , AllTrim(DG3->DG3_CDGE)  , Nil},;
						{'B1_UCOM'   , DG0->DG0_DTULEN         , Nil},;
						{'B1_UCALSTD', DG0->DG0_DTULRO         , Nil},;
						{'B1_CUSTD'  , DG0->DG0_VLPRRO         , Nil},;
						{'B1_UPRC'   , DG0->DG0_VLULEN         , Nil},;
						{'B1_LOCPAD' , AllTrim(DG3->DG3_CDDPPA), Nil},;
						{'B1_FANTASM', IF(DG3->DG3_LGACVI=='1','S',' '), Nil} }

			MSExecAuto( { |x,y| MATA010(x,y) }, aCab, 3)

			If lMsErroAuto
				aAutoErro := GETAUTOGRLOG()
				If !lAutomacao
					cLog      += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0017 + cItemPai + PULALINHA // Produto Desenvolvido: ## Versão: ## Criação Produto:
				
					For nI := 1 to Len(aAutoErro)
						cLog += "   " + aAutoErro[nI] + PULALINHA
					Next

					cLog += PULALINHA

					lRet := .F.
				EndIf
			Else
				dbSelectArea('CZ3')
				CZ3->(dbSetOrder(1))
				CZ3->(dbSeek(xFilial("CZ3")+cItemPai))
			Endif
		Else
			aCab := {	{'B1_COD'    , cItemPai			       , Nil},;
						{'B1_UCOM'   , DG0->DG0_DTULEN         , Nil},;
						{'B1_UCALSTD', DG0->DG0_DTULRO         , Nil},;
						{'B1_CUSTD'  , DG0->DG0_VLPRRO         , Nil},;
						{'B1_UPRC'   , DG0->DG0_VLULEN         , Nil} }

			MSExecAuto( { |x,y| MATA010(x,y) }, aCab, 4)
			if lMsErroAuto
				aAutoErro := GETAUTOGRLOG()
				cLog      += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0049 + cItemPai + PULALINHA // Produto Desenvolvido: ## Versão: ## Alteração Produto:

				For nI := 1 to Len(aAutoErro)
					cLog += "   " + aAutoErro[nI] + PULALINHA
				Next

				cLog += PULALINHA

				lRet := .F.
			Endif
		Endif 
		
		if lRet

			// Atualiza SB5 com informação de família técnica 
			if DPRFicha(2)
				dbSelectArea('SB5')
				SB5->(dbSetOrder(1))
				lFoundSB5 := SB5->(dbSeek(xFilial('SB5')+cItemPai))
			
				if !Empty(DG3->DG3_CDFATD)
			
					aDadosSB5 := {{'B5_COD'   , cItemPai       , NIL},;
									{'B5_CDFATD', DG3->DG3_CDFATD, NIL}}
			
					MSExecAuto({|x,y| Mata180(x,y)},aDadosSB5,if(lFoundSB5,4,3))
					If lMsErroAuto
						MostraErro()
						lRet := .F.
					EndIf
				Endif
			EndIf
		Endif
		// Fim família técnica
		if lRet .AND. lOper
			dbSelectArea('DG9')
			DG9->(dbSetOrder(1))
			if DG9->(dbSeek(xFilial('DG9')+DG0->DG0_CDACDV+DG0->DG0_NRVRAC))
			
				// Busca o código de roteiro informado em tela para cada versão
				cRot := aEspec[aScan(aEspec,{|x| x[1] == DG0->DG0_CDACDV .AND. x[2] == DG0->DG0_NRVRAC} )][5]
			
				// Se tiver QIP e existir ficha para o produto protótipo, então é o QIP quem libera o roteiro
				IF SuperGetMV('MV_DPRQIP',.F.,.F.) .AND. !Empty(DG0->DG0_CDRT)
					dbSelectArea('QP6')
					QP6->(dbSetOrder(2)) // QP6_FILIAL+QP6_PRODUT+QP6_REVI+QP6_CODREC
					if QP6->(dbSeek(xFilial('QP6')+DG0->DG0_CDACPY))
						lEspec := .T.
					Else
						lEspec := .F.
					Endif
				Endif

				if !lEspec

					If lRunPCP124
						oModelRot := FWLoadModel('PCPA124')
					Else
						oModelRot := FWLoadModel('MATA632')
					EndIf
					
					dbSelectArea('SG2')
					SG2->(dbSetOrder(1)) // G2_FILIAL+G2_PRODUTO+G2_CODIGO+G2_OPERAC
					if SG2->(dbSeek(xFilial('SG2')+cItemPai+cRot))					
						
						dbSelectArea('SGF')
						SGF->(dbSetOrder(1))
						IF SGF->(dbSeek(xFilial('SGF')+cItemPai+cRot))
							oModel637 := FwLoadModel('MATA637')
							oModel637:SetOperation(5)
							oModel637:Activate()
					
							If oModel637:VldData()
								oModel637:CommitData()
							Else
								lRet := .F.
									
								aErro := oModelCZ3:GetErrorMessage()
						
								cLog += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0055 + aErro[6] // Produto Desenvolvido: ## Versão: ## 'Erro ao eliminar relação operações x componentes. '
							Endif
								
							oModel637:DeActivate()							
						Endif
						
						SG2->(dbSeek(xFilial('SG2')+cItemPai+cRot))					
						oModelRot:SetOperation(5)
						if oModelRot:Activate()
							if oModelRot:VldData()
								oModelRot:CommitData()
							Else
								aErro := oModelRot:GetErrorMessage()
								cLog += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0035 + cItemPai + STR0018 + PULALINHA // Produto Desenvolvido: ## Versão: ## Produto Engenharia: # Criação Operação:
			
								cLog += STR0025 + " [" + AllToChar( aErro[1] ) + "]" + PULALINHA  	// "   Id do formulário de origem:"
								cLog += STR0026 + " [" + AllToChar( aErro[2] ) + "]" + PULALINHA	// "   Id do campo de origem:     "
								cLog += STR0027 + " [" + AllToChar( aErro[3] ) + "]" + PULALINHA	// "   Id do formulário de erro:  "
								cLog += STR0028 + " [" + AllToChar( aErro[4] ) + "]" + PULALINHA	// "   Id do campo de erro:       "
								cLog += STR0029 + " [" + AllToChar( aErro[5] ) + "]" + PULALINHA	// "   Id do erro:                "
								cLog += STR0030 + " [" + AllToChar( aErro[6] ) + "]" + PULALINHA	// "   Mensagem do erro:          "
								cLog += STR0031 + " [" + AllToChar( aErro[7] ) + "]" + PULALINHA	// "   Mensagem da solução:       "
								cLog += STR0032 + " [" + AllToChar( aErro[8] ) + "]" + PULALINHA	// "   Valor atribuido:           "
								cLog += STR0033 + " [" + AllToChar( aErro[9] ) + "]" + PULALINHA	// "   Valor anterior:            "
			
								lRet := .F.
							Endif
						Else
							aErro := oModelRot:GetErrorMessage()
							cLog += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0035 + cItemPai + STR0018 + PULALINHA // Produto Desenvolvido: ## Versão: ## Produto Engenharia: # Criação Operação:
		
							cLog += STR0025 + " [" + AllToChar( aErro[1] ) + "]" + PULALINHA  	// "   Id do formulário de origem:"
							cLog += STR0026 + " [" + AllToChar( aErro[2] ) + "]" + PULALINHA	// "   Id do campo de origem:     "
							cLog += STR0027 + " [" + AllToChar( aErro[3] ) + "]" + PULALINHA	// "   Id do formulário de erro:  "
							cLog += STR0028 + " [" + AllToChar( aErro[4] ) + "]" + PULALINHA	// "   Id do campo de erro:       "
							cLog += STR0029 + " [" + AllToChar( aErro[5] ) + "]" + PULALINHA	// "   Id do erro:                "
							cLog += STR0030 + " [" + AllToChar( aErro[6] ) + "]" + PULALINHA	// "   Mensagem do erro:          "
							cLog += STR0031 + " [" + AllToChar( aErro[7] ) + "]" + PULALINHA	// "   Mensagem da solução:       "
							cLog += STR0032 + " [" + AllToChar( aErro[8] ) + "]" + PULALINHA	// "   Valor atribuido:           "
							cLog += STR0033 + " [" + AllToChar( aErro[9] ) + "]" + PULALINHA	// "   Valor anterior:            "
		
							lRet := .F.
						Endif
						oModelRot:DeActivate()
					Endif
	
					oModelRot:SetOperation(3)
					if oModelRot:Activate()
	
						If lRunPCP124
							oMdlRotSG2 := oModelRot:GetModel('PCPA124_SG2')
						Else
							oMdlRotSG2 := oModelRot:GetModel('MATA632_SG2')
						EndIf
		
						oModelRot:SetValue(cModelId,'G2_CODIGO' , cRot)
						oModelRot:SetValue(cModelId,'G2_PRODUTO', cItemPai)
		
						nI := 0
		
						While DG9->(!EOF()) .AND. DG9->DG9_CDACDV == DG0->DG0_CDACDV .AND. DG9->DG9_NRVRAC == DG0->DG0_NRVRAC
							nI++
		
							if nI > 1
								oMdlRotSG2:AddLine()
							Endif
							
							oMdlRotSG2:SetValue('G2_OPERAC' , DG9->DG9_CDATET)
							oMdlRotSG2:SetValue('G2_DESCRI' , Substr(DG9->DG9_DSAT,1,TamSX3("G2_DESCRI")[1]))
							oMdlRotSG2:SetValue('G2_RECURSO', ALLTRIM(DG9->DG9_CDMQ))
							oMdlRotSG2:SetValue('G2_FERRAM' , ALLTRIM(DG9->DG9_CDFE))
							oMdlRotSG2:SetValue('G2_TPALOCF', DG9->DG9_TPALFE)
							oMdlRotSG2:SetValue('G2_FORMSTP', DG9->DG9_CDFOSU)
							oMdlRotSG2:SetValue('G2_LOTEPAD', DG9->DG9_NRUNAC)
							oMdlRotSG2:SetValue('G2_CTRAB'  , ALLTRIM(DG9->DG9_CDCETR))
							oMdlRotSG2:SetValue('G2_TPOPER' , If(DG9->DG9_TPTEAT=="3","4",DG9->DG9_TPTEAT))
							oMdlRotSG2:SetValue('G2_TPSOBRE', DG9->DG9_TPTEOV)
							
							nQtd := DPRA342CVA(DG9->DG9_QTTESU,'G2_SETUP', 'DG9_QTTESU')
							if nQtd != DG9->DG9_QTTESU
								lRet := .F.
							Endif
		
							Do Case
								Case DG9->DG9_TPUNTE == '1'
									oMdlRotSG2:SetValue('G2_SETUP', nQtd)
								Case DG9->DG9_TPUNTE == '2'
									oMdlRotSG2:SetValue('G2_SETUP', nQtd / 60)
								Case DG9->DG9_TPUNTE == '3'
									oMdlRotSG2:SetValue('G2_SETUP', nQtd / 3600)
								Case DG9->DG9_TPUNTE == '4'
									oMdlRotSG2:SetValue('G2_SETUP', nQtd * 24)
							End Case
		
							nQtd := DPRA342CVA(DG9->DG9_QTTEMQ,'G2_TEMPAD', 'DG9_QTTEMQ')
							if nQtd != DG9->DG9_QTTEMQ
								lRet := .F.
							Endif
							oMdlRotSG2:SetValue('G2_TEMPAD' , nQtd)
		
							nQtd := DPRA342CVA(DG9->DG9_QTTEOV,'G2_TEMPSOB', 'DG9_QTTEOV')
							if nQtd != DG9->DG9_QTTEOV
								lRet := .F.
							Endif
							oMdlRotSG2:SetValue('G2_TEMPSOB', nQtd)
		
							nQtd := DPRA342CVA(DG9->DG9_QTTEPP,'G2_TEMPEND', 'DG9_QTTEPP')
							if nQtd != DG9->DG9_QTTEPP
								lRet := .F.
							Endif
							oMdlRotSG2:SetValue('G2_TEMPEND', nQtd)
							
							nQtd := DPRA342CVA(DG9->DG9_QTRC,'G2_MAOOBRA', 'DG9_QTRC')
							if nQtd != DG9->DG9_QTRC
								lRet := .F.
							Endif
							oMdlRotSG2:SetValue('G2_MAOOBRA', nQtd)
							
							IF !lRet
								Exit
							Endif
							
							// Busca os alterantivos da operação
							DG2->(dbSetOrder(1))
							if DG2->(dbSeek(xFilial('DG2')+DG9->DG9_IDAT))
								While DG2->(!EOF()) .AND. DG2->DG2_IDAT == DG9->DG9_IDAT
									
									RecLock('SH3',.T.)
									SH3->H3_FILIAL  := xFilial('SH3')
									SH3->H3_PRODUTO := cItemPai
									SH3->H3_CODIGO  := cRot
									SH3->H3_OPERAC  := DG9->DG9_CDATET
									SH3->H3_RECPRIN := DG9->DG9_CDMQ
									SH3->H3_RECALTE := ALLTRIM(DG2->DG2_CDMQ)
									SH3->H3_TIPO    := DG2->DG2_TPMQ
									SH3->H3_EFICIEN := DG2->DG2_VLEF
									SH3->H3_FERRAM  := DG2->DG2_CDFE
									SH3->(MsUnLock())								
									
									DG2->(dbSkip())
								End
							Endif 
		
							DG9->(dbSkip())
						End
						
						if lRet
							if oModelRot:VldData()
								oModelRot:CommitData()
							Else
								aErro := oModelRot:GetErrorMessage()
								cLog += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0035 + cItemPai + STR0018 + PULALINHA // Produto Desenvolvido: ## Versão: ## Produto Engenharia: # Criação Operação:
			
								cLog += STR0025 + " [" + AllToChar( aErro[1] ) + "]" + PULALINHA  	// "   Id do formulário de origem:"
								cLog += STR0026 + " [" + AllToChar( aErro[2] ) + "]" + PULALINHA	// "   Id do campo de origem:     "
								cLog += STR0027 + " [" + AllToChar( aErro[3] ) + "]" + PULALINHA	// "   Id do formulário de erro:  "
								cLog += STR0028 + " [" + AllToChar( aErro[4] ) + "]" + PULALINHA	// "   Id do campo de erro:       "
								cLog += STR0029 + " [" + AllToChar( aErro[5] ) + "]" + PULALINHA	// "   Id do erro:                "
								cLog += STR0030 + " [" + AllToChar( aErro[6] ) + "]" + PULALINHA	// "   Mensagem do erro:          "
								cLog += STR0031 + " [" + AllToChar( aErro[7] ) + "]" + PULALINHA	// "   Mensagem da solução:       "
								cLog += STR0032 + " [" + AllToChar( aErro[8] ) + "]" + PULALINHA	// "   Valor atribuido:           "
								cLog += STR0033 + " [" + AllToChar( aErro[9] ) + "]" + PULALINHA	// "   Valor anterior:            "
			
								lRet := .F.
							Endif
						Endif
						oModelRot:DeActivate()
					Else
						aErro := oModelRot:GetErrorMessage()
						cLog += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0035 + cItemPai + STR0018 + PULALINHA // Produto Desenvolvido: ## Versão: ## Produto Engenharia: # Criação Operação:
	
						cLog += STR0025 + " [" + AllToChar( aErro[1] ) + "]" + PULALINHA  	// "   Id do formulário de origem:"
						cLog += STR0026 + " [" + AllToChar( aErro[2] ) + "]" + PULALINHA	// "   Id do campo de origem:     "
						cLog += STR0027 + " [" + AllToChar( aErro[3] ) + "]" + PULALINHA	// "   Id do formulário de erro:  "
						cLog += STR0028 + " [" + AllToChar( aErro[4] ) + "]" + PULALINHA	// "   Id do campo de erro:       "
						cLog += STR0029 + " [" + AllToChar( aErro[5] ) + "]" + PULALINHA	// "   Id do erro:                "
						cLog += STR0030 + " [" + AllToChar( aErro[6] ) + "]" + PULALINHA	// "   Mensagem do erro:          "
						cLog += STR0031 + " [" + AllToChar( aErro[7] ) + "]" + PULALINHA	// "   Mensagem da solução:       "
						cLog += STR0032 + " [" + AllToChar( aErro[8] ) + "]" + PULALINHA	// "   Valor atribuido:           "
						cLog += STR0033 + " [" + AllToChar( aErro[9] ) + "]" + PULALINHA	// "   Valor anterior:            "
	
						lRet := .F.
					Endif
				Endif
			Endif
		Endif

		// Verifica se existe estrutura para o item
		if lRet
			aRelac := {}
		
			dbSelectArea('DG1')
			DG1->(dbSetOrder(1))
			if DG1->(dbSeek(xFilial('DG1')+DG0->DG0_CDACDV+DG0->DG0_NRVRAC))

				dbSelectArea('SG1')
				SG1->(dbSetOrder(1))
				If SG1->(dbSeek(xFilial('SG1')+cItemPai))
					oJsonEstr := JsonObject():New()
					cRevAtu := PCPREVATU(cItemPai)
					While SG1->(!EOF()) .AND. SG1->G1_COD == cItemPai

						If !Empty(cRevAtu) .And. !(SG1->G1_REVINI <= cRevAtu .And. (SG1->G1_REVFIM >= cRevAtu .Or. SG1->G1_REVFIM = ' '))
							SG1->(dbSkip())
							Loop
						EndIf

						oJsonEstr[AllTrim(SG1->G1_COD)+AllTrim(SG1->G1_COMP)+AllTrim(SG1->G1_TRT)] := Array(4)
						oJsonEstr[AllTrim(SG1->G1_COD)+AllTrim(SG1->G1_COMP)+AllTrim(SG1->G1_TRT)][1] := SG1->G1_COD
						oJsonEstr[AllTrim(SG1->G1_COD)+AllTrim(SG1->G1_COMP)+AllTrim(SG1->G1_TRT)][2] := SG1->G1_COMP
						oJsonEstr[AllTrim(SG1->G1_COD)+AllTrim(SG1->G1_COMP)+AllTrim(SG1->G1_TRT)][3] := SG1->G1_TRT
						oJsonEstr[AllTrim(SG1->G1_COD)+AllTrim(SG1->G1_COMP)+AllTrim(SG1->G1_TRT)][4] := .F. //MARCA SE ESTÁ NA NOVA VERSÃO DA ESTRUTURA
						SG1->(dbSkip())
					EndDo
					lAltEstru := .T.
				Else
					lAltEstru := .F.
				EndIF

				// Le todos os componentes
				While DG1->(!EOF()) .AND. DG1->DG1_CDACDV == DG0->DG0_CDACDV .AND. DG1->DG1_NRVRAC == DG0->DG0_NRVRAC

					IF DG1->DG1_LGMTDV == '1'
						dbSelectArea('DG3')
						DG3->(dbSetOrder(1))
						DG3->(dbSeek(xFilial('DG3')+DG1->DG1_CDMTDV))

						nPosDG1 := DG1->(Recno())
						nPosDG0 := DG0->(Recno())
						nPosCZ3 := CZ3->(Recno())
					Endif

					if lEstrut
						aCab := {{"G1_COD"	, cItemPai	, NIL},;
								 {"ATUREVSB1"	, "S"		, NIL},;
								 {"NIVALT"		, "S"		, NIL},;
								 {"G1_QUANT" , DG0->DG0_QTACEA, NIL}}

						aDetalhe := {}
						
						cFilho := PadR(if(DG1->DG1_LGMTDV == '1',DG3->DG3_CDACDE,DG1->DG1_CDMT),nTam)
						
						cSeqTrt := DG1->DG1_NRSQET
						
						aadd(aDetalhe, {"G1_COD"    , cItemPai              , NIL})
						aadd(aDetalhe, {"G1_COMP"   , cFilho                , NIL})
						aadd(aDetalhe, {"G1_TRT"    , cSeqTrt               , NIL})
						aadd(aDetalhe, {"G1_INI"    , DG1->DG1_DTBG         , NIL})
						aadd(aDetalhe, {"G1_FIM"    , DG1->DG1_DTED         , NIL})
						aadd(aDetalhe, {"G1_FIXVAR" ,IF(DG1->DG1_TPVV == "2","F" ,"V") , NIL})
						
						nQtd := DPRA342CVA(DG1->DG1_QTMT,"G1_QUANT", 'DG1_QTMT')
						if nQtd != DG1->DG1_QTMT
							lRet := .F.
						Endif
						aadd(aDetalhe, {"G1_QUANT", nQtd  , NIL})

						nQtd := DPRA342CVA(DG1->DG1_VLPNLS,"G1_PERDA", 'DG1_VLPNLS')
						if nQtd != DG1->DG1_VLPNLS
							lRet := .F.
						Endif
						aadd(aDetalhe, {"G1_PERDA", nQtd, NIL})

						If lAltEstru .And. oJsonEstr:HasProperty(AllTrim(cItemPai)+AllTrim(cFilho)+AllTrim(cSeqTrt))
							aAdd(aDetalhe, {"LINPOS"  ,"G1_COD+G1_COMP+G1_TRT",cItemPai,cFilho,cSeqTrt})
							oJsonEstr[AllTrim(cItemPai)+AllTrim(cFilho)+AllTrim(cSeqTrt)][4] := .T. //ATUALIZA QUE ESTÁ NA NOVA VERSÃO DA ESTRUTURA
						EndIf
						
						if !lRet
							Exit
						Endif
						
						If !Empty(DG1->DG1_CDATET)
							aadd(aRelac, {cFilho, DG1->DG1_NRSQET, DG1->DG1_CDATET})
						Endif
						
						aadd(aItem,aDetalhe)
					Endif

					IF DG1->DG1_LGMTDV == '1'
						lRet := DPRA342DES(DG1->DG1_CDMTDV, DG1->DG1_NRVRMT)

						DG1->(dbGoTo(nPosDG1))
						DG0->(dbGoTo(nPosDG0))
						CZ3->(dbGoTo(nPosCZ3))
					Endif

					DG1->(dbSkip())
				End
				
				//Busca os itens que já pertenciam a estrutura na engenharia e não estão na nova versão do produto, para que sejam deletados da estrutura na engenharia
				If lAltEstru
					aEstru := oJsonEstr:GetNames()
					For nIndEstru := 1 To Len(aEstru)
						If oJsonEstr[aEstru[nIndEstru]][4] == .F.
							aDetalhe := {}
							aadd(aDetalhe, {"G1_COD"   , oJsonEstr[aEstru[nIndEstru]][1]  , NIL})
							aadd(aDetalhe, {"G1_COMP"  , oJsonEstr[aEstru[nIndEstru]][2]  , NIL})
							aadd(aDetalhe, {"G1_TRT"   , oJsonEstr[aEstru[nIndEstru]][3]  , NIL})
							aAdd(aDetalhe, {"LINPOS"   , "G1_COD+G1_COMP+G1_TRT"          , oJsonEstr[aEstru[nIndEstru]][1],oJsonEstr[aEstru[nIndEstru]][2],oJsonEstr[aEstru[nIndEstru]][3]})
							aAdd(aDetalhe, {"AUTDELETA", "S"                              , NIL})
							aadd(aItem,aDetalhe)
						EndIf
					Next nIndEstru
					FreeObj(oJsonEstr)
				EndIf				

				if lRet .AND. lEstrut

					if lAltEstru
						MSExecAuto({|x,y,z| PCPA200(x,y,z)},aCab,aItem,4)
					Else
						MSExecAuto({|x,y,z| PCPA200(x,y,z)},aCab,aItem,3)
					Endif

					If lMsErroAuto
						aAutoErro := GETAUTOGRLOG()
						cLog      += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0035 + cItemPai + PULALINHA // Produto Desenvolvido: ## Versão: ## Produto Engenharia: ## Atualização Estrutura:

						For nI := 1 to Len(aAutoErro)
							cLog += "   " + aAutoErro[nI] + PULALINHA
						Next

						lRet := .F.

						cLog += PULALINHA
					Elseif lOper .AND. !lEspec .And. Len(aRelac) > 0 // Se está liberando operações e estrutura, deverá liberar também a relação, caso exista						
						lRet := DPRA342SGF(cItemPai, cRot, aRelac)
					Endif
				Endif
			Endif
		Endif

		// Libera ficha
		if lRet .AND. lFicha

			IF lParam1 .AND. lParam2 // 'Cria se existir na Versão' E 'Cria se for herdada à Versão'
				// Cria registro de ficha no PCP com base na versão
				aRetorno := DPRA342CZG(lParam1, lParam2, DG0->DG0_CDACDV, DG0->DG0_NRVRAC, cItemPai)
				lRet     := aRetorno[1]

				if lRet // Se não deu erro

					if !aRetorno[2] // Se não existir, Copia ficha do produto para versão
						aRetorno := DPRA342DGN(DG0->DG0_CDACDV, DG0->DG0_NRVRAC, cItemPai)
						lRet     := aRetorno[1]

						if lRet // Se não deu erro
							// Se existir ficha no produto, Cria registro de ficha no PCP
							lRet := DPRA342CZG(lParam1, lParam2, DG0->DG0_CDACDV, DG0->DG0_NRVRAC, cItemPai)[1]
						Endif
					Endif
				Endif
			Else
				if lParam1 // Cria se existir na Versão

					// Cria registros de ficha da versão no pcp - CZG
					lRet := DPRA342CZG(lParam1, lParam2, DG0->DG0_CDACDV, DG0->DG0_NRVRAC, cItemPai)[1]

				ElseIf lParam2 // Cria se for herdada à Versão

					// Copia registro de ficha do produto para a ficha da versão
					aRetorno := DPRA342DGN(DG0->DG0_CDACDV, DG0->DG0_NRVRAC, cItemPai) // Se conseguir copiar
					lRet     := aRetorno[1]

					if lRet
						// Cria registros de ficha para o pcp - CZG
						lRet := DPRA342CZG(lParam1, lParam2, DG0->DG0_CDACDV, DG0->DG0_NRVRAC, cItemPai)[1]
					Endif
				Endif
			Endif
		Endif

		// Libera conhecimento
		IF lRet
			dbSelectArea('AC9')
			AC9->(dbSetOrder(2))
			if AC9->(dbSeek(xFilial('AC9')+'DG0'+DG0->DG0_FILIAL+DG0->DG0_FILIAL+DG0->DG0_CDACDV+DG0->DG0_NRVRAC))
				While AC9->(!EOF()) .AND. AC9->AC9_ENTIDA == 'DG0' .AND.;
				                          AC9->AC9_FILENT == DG0->DG0_FILIAL .AND.;
				                          ALLTRIM(AC9->AC9_CODENT) == DG0->DG0_FILIAL+DG0->DG0_CDACDV+DG0->DG0_NRVRAC

					aadd(aObjetos,AC9->AC9_CODOBJ)

					AC9->(dbSkip())
				End

				For nI := 1 to Len(aObjetos)
					dbSelectArea('AC9')
					AC9->(dbSetOrder(2))
					if !AC9->(dbSeek(xFilial('AC9')+'SB1'+xFilial('SB1')+cItemPai+aObjetos[nI]))
						RecLock('AC9',.T.)
						AC9->AC9_FILIAL := xFilial('AC9')
						AC9->AC9_FILENT := xFilial('SB1')
						AC9->AC9_ENTIDA := 'SB1'
						AC9->AC9_CODENT := cItemPai
						AC9->AC9_CODOBJ := aObjetos[nI]
						MsUnLock()
					Endif
				Next
			Endif
		Endif

		if lRet
		
			IF lEspec
			    
				dbSelectArea('QP6')
				QP6->(dbSetorder(1)) 
				IF !QP6->(dbseek(xFilial("QP6")+DG3->DG3_CDACDE))
					cRevEng := '00'
				Else
					cRevEng := Soma1(QIPRevRot(cItemPai)[1])
				Endif
		
				// Copia de especificação
				lRet := QIPDupEsp(DG0->DG0_CDACPY,QIPRevRot(DG0->DG0_CDACPY)[1],DG0->DG0_CDRT,DG3->DG3_CDACDE,cRevEng,DG0->DG0_CDRT,DG3->DG3_DSACDE,,,,DG0->DG0_CDRT,,,,,,cRot)
				
				if !lRet
					cLog += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0040 // Produto Desenvolvido: ## Versão: ## Não foi possível duplicar a especificação
				Elseif lOper .AND. lEstrut .AND. Len(aRelac) > 0 // Liberar relacionamento operações x componentes					
					lRet := DPRA342SGF(cItemPai, cRot, aRelac)																				
				Endif
			Endif
			
			if lRet
		
				oModelCZ3 := FWLoadModel( 'SFCC101' )
				oModelCZ3:SetOperation(4)
				oModelCZ3:Activate()
	
				oModelCZ3:SetValue('CZ3MASTER','CZ3_NRVRAC',DG0->DG0_NRVRAC)
	
				If oModelCZ3:VldData()
					oModelCZ3:CommitData()
					//Libera versão pendencia
					If FindFunction("DPRA350LVP")
						lRet := DPRA350LVP(DG0->DG0_CDACDV,DG0->DG0_NRVRAC)
						
						if !lRet
							aLog := GetAutoGRLog()
						
							cLog += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0054 // Produto Desenvolvido: ## Versão: ## 'Erro durante o processo de atualização da pendência de desenvolvimento'
							
							if Len(aLog) > 0
								cLog += PULALINHA + "---------------------ERRO PENDENCIA-----------------------------"
							
								For nI := 1 to Len(aLog)
									cLog += PULALINHA + aLog[nI]
								Next
						 		cLog += PULALINHA + "---------------------FIM ERRO PENDENCIA-------------------------"
						 	Endif
						 	 
						Endif
					EndIf
				Else
					lRet := .F.
					aErro := oModelCZ3:GetErrorMessage()
					
					If !lAutomacao
						cLog += STR0014 + cProd + STR0015 + cVers + ' - ' +; // Produto Desenvolvido: ## Versão:
					        	STR0035 + cItemPai + STR0039 + PULALINHA // Produto Engenharia: ## Alteração Produto Manufatura
			
						cLog += STR0025 + " [" + AllToChar( aErro[1] ) + "]" + PULALINHA  	// "   Id do formulário de origem:"
						cLog += STR0026 + " [" + AllToChar( aErro[2] ) + "]" + PULALINHA	// "   Id do campo de origem:     "
						cLog += STR0027 + " [" + AllToChar( aErro[3] ) + "]" + PULALINHA	// "   Id do formulário de erro:  "
						cLog += STR0028 + " [" + AllToChar( aErro[4] ) + "]" + PULALINHA	// "   Id do campo de erro:       "
						cLog += STR0029 + " [" + AllToChar( aErro[5] ) + "]" + PULALINHA	// "   Id do erro:                "
						cLog += STR0030 + " [" + AllToChar( aErro[6] ) + "]" + PULALINHA	// "   Mensagem do erro:          "
						cLog += STR0031 + " [" + AllToChar( aErro[7] ) + "]" + PULALINHA	// "   Mensagem da solução:       "
						cLog += STR0032 + " [" + AllToChar( aErro[8] ) + "]" + PULALINHA	// "   Valor atribuido:           "
						cLog += STR0033 + " [" + AllToChar( aErro[9] ) + "]" + PULALINHA	// "   Valor anterior:            "
					EndIf
				Endif				
				oModelCZ3:DeActivate()
			Endif
		Endif
		
		IF lRet
			oModel:SetOperation(4)
			oModel:Activate()
			oModel:SetValue('DG0MASTER', 'DG0_TPST'  , cState )
			oModel:SetValue('DG0MASTER', 'DG0_CDRTDE', cRot )
	
			if oModel:VldData()
				if oModel:CommitData()
					if SuperGetMV('MV_DPRHIST',.F.,.F.)
						lRet := DPRA341HIS(DG0->DG0_CDACDV, DG0->DG0_NRVRAC, cState)
					Endif
				Else
					aErro := oModel:GetErrorMessage()
	
					cLog += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0035 + cItemPai + " - " + aErro[6] // Produto Desenvolvido: ## Versão: ## Produto Engenharia: 
	
					lRet := .F.
				Endif
			Else
				aErro := oModel:GetErrorMessage()
				lRet := .F.
			EndIf
		Endif
	Endif
Endif

Return lRet

//---------------------------------------------------------------------------
// DPRA342SGF - Atualiza informações de operações x componentes
//---------------------------------------------------------------------------
Static Function DPRA342SGF(cItemPai, cRot, aRelac)
Local oModel637
Local oModel637DET
Local nI    := 0
Local aErro := {}
Local lRet  := .T.

oModel637 := FwLoadModel('MATA637')
oModel637:SetOperation(3)
oModel637:Activate()

oModel637:SetValue('SGFMASTER','GF_PRODUTO', cItemPai)
oModel637:SetValue('SGFMASTER','GF_ROTEIRO', cRot)

oModel637DET := oModel637:GetModel('SGFDETAIL')

For nI := 1 to Len(aRelac)
	IF nI > 1
		oModel637DET:AddLine()
	Endif
	
	oModel637DET:SetValue('GF_COMP'  , aRelac[nI][1])
	oModel637DET:SetValue('GF_TRT'   , aRelac[nI][2])
	oModel637DET:SetValue('GF_OPERAC', aRelac[nI][3])
Next

If oModel637:VldData()
	oModel637:CommitData()
Else
	lRet := .F.
	
	aErro := oModel637:GetErrorMessage()

	cLog += STR0014 + DG0->DG0_CDACDV + STR0015 + DG0->DG0_NRVRAC + ' - ' + STR0056 + aErro[6] // Produto Desenvolvido: ## Versão: ## 'Erro ao criação da relação operações x componentes. '
Endif 

oModel637:DeActivate()

Return lRet

//---------------------------------------------------------------------------
// DPRA341CVA - Validação de tamanho de campo
//---------------------------------------------------------------------------
Static Function DPRA342CVA(nValor, cCampo, cCampoOrig)
Local aRet    := TamSX3(cCampo)
Local aRetOrg := TamSX3(cCampoOrig)
Local nInt    := Int(nValor)
Local nDec    := nValor - nInt
Local nTeste  := 0

nTeste := Transform(nValor, x3Picture(cCampo))
if Subs(nTeste,1,1) == '*'

	if aRet[1] < aRetOrg[1]
		nInt := alltrim(STR(nInt))
		nInt := Val(Substr(nInt,len(nInt) - ((aRetOrg[1] - (aRetOrg[2] + 1)) - (aRet[1] - (aRet[2] + 1)))+1,aRet[1]))
		nValor := nInt + nDec
	Endif

	if aRet[2] < aRetOrg[2]
		nValor := NOROUND(nValor, aRet[2])
	Endif

	cLog += STR0022 + cCampo + STR0023 + cCampoOrig + STR0024 + PULALINHA // "Os campos " ### " e " ### " possuem formatos diferentes."
Endif

Return nValor

//---------------------------------------------------------------------------
// DPRA342CZG - Cria registro de ficha técnica no PCP (CZG) com base nos
//              registros do DP (DGN e DGO)
//---------------------------------------------------------------------------
Static Function DPRA342CZG(lParam1, lParam2, cProd, cVers, cItemPai)
	Local LRet  := .T.
	Local nI    := 0
	Local aErro := {}
	Local oModelCZG
	Local oModelCZGD
	Local lEncont       := .F.
	Private cParam
	Private cTpAtrib	  := ""
	Private cVlFaixa	  := ""
	Private lEnd        := .F.
	Private aParenteses := {}
	Private cFormula    := ""
	Private cFormNova   := ""
	Private lRetorno    := .F.
	Private nOpVersao   := 0
	Private lWhen       := .T.
	Private cVerFicha   := ""
	Private lEntrou     := .F.
	Private cVLTB       :=  ""
	Private cAbreTela   := 'S'
	Private cExecVald   := 'S'
	Private aTemplates  := {}
	Private aValores    := {}
	Private lValid      := .T.
	Private lExecuta    := .T.
	
	dbSelectArea('DGN')
	DGN->(dbSetOrder(1))
	IF DGN->(dbSeek(xFilial('DGN')+cProd+cVers))
		lEncont	:= .T.
	
		While DGN->(!EOF()) .AND. DGN->DGN_CDACDV == DG0->DG0_CDACDV .AND. DGN->DGN_NRVRAC == DG0->DG0_NRVRAC
	
			dbSelectArea('DGO')
			DGO->(dbSetOrder(1))
			IF DGO->(dbSeek(xFilial('DGO')+DGN->DGN_CDACDV+DGN->DGN_NRVRAC+DGN->DGN_CDMQ+DGN->DGN_CDMD))
	
				if Empty(DGN->DGN_CDMQ)
					cParam := 1
				Else
					cParam := 3
				Endif
	
				oModelCZG := FWLoadModel('PCPA104')
				oModelCZG:SetOperation(3)
				oModelCZG:Activate()
	
				oModelCZG:SetValue('CZGMASTER','CZG_CDAC',cItemPai)
	
				if !Empty(DGN->DGN_CDMQ)
					oModelCZG:SetValue('CZGMASTER','CZG_CDRC',PADR(DGN->DGN_CDMQ,TamSx3("CZG_CDRC")[1],''))
				Endif
	
				oModelCZG:SetValue('CZGMASTER','CZG_CDMD',DGN->DGN_CDMD)
	
				oModelCZGD := oModelCZG:GetModel('CZGDETAIL')
	
				While DGO->(!EOF()) .AND. DGO->DGO_CDACDV == DGN->DGN_CDACDV .AND. DGO->DGO_NRVRAC == DGN->DGN_NRVRAC .AND.;
				                          DGO->DGO_CDMQ   == DGN->DGN_CDMQ   .AND. DGO->DGO_CDMD   == DGN->DGN_CDMD
	
					For nI := 1 to oModelCZGD:GetQtdLine()
						oModelCZGD:GoLine(nI)
	
						if !oModelCZGD:IsDeleted() .AND. oModelCZGD:GetValue('CZG_CDAB') == DGO->DGO_CDAB
	
							cTpAtrib := oModelCZG:GetValue('CZGDETAIL','CZG_TPAB')
	
							Do Case
								Case cTpAtrib == "F" // Flag
									oModelCZGD:SetValue('CZG_VLFG', IF(DGO->DGO_VLFG=='1','1','2'))
								Case cTpAtrib == "C" // Caracter
									oModelCZGD:SetValue('CZG_VLCHAR', DGO->DGO_VLCH)
								Case cTpAtrib == "N" // Número
									oModelCZGD:SetValue('CZG_VLNR', DGO->DGO_VLNR)
								Case cTpAtrib == "D" // Data
									oModelCZGD:SetValue('CZG_VLDT', DGO->DGO_VLDT)
								Case cTpAtrib == "L" // Lista
									if !Empty(DGO->DGO_VLTB)
										oModelCZGD:SetValue('CZG_VLLST', DGO->DGO_VLTB)
									Endif
								Case cTpAtrib == "A" // Faixa
									oModelCZGD:SetValue('CZG_VLFX', DGO->DGO_VLFX)
								Case cTpAtrib == "M" // Memo
									oModelCZGD:SetValue('CZG_VLMEMO', DGO->DGO_VLNV)
								Case cTpAtrib == "O" // Tolerância
									oModelCZGD:SetValue('CZG_VLNR' , DGO->DGO_VLNR)
									oModelCZGD:SetValue('CZG_AFINF', DGO->DGO_VLAFMI)
									oModelCZGD:SetValue('CZG_AFSUP', DGO->DGO_VLAFMX)
								Case cTpAtrib == "T" // Tabela
									oModelCZGD:SetValue('CZG_VLTB', DGO->DGO_VLTBSI)
								Case cTpAtrib == "I" // Imagem
									oModelCZGD:SetValue('CZG_BITMAP', DGO->DGO_BITMAP)
							EndCase
							
							Exit
						Endif
					Next
	
					DGO->(dbSkip())
				End
	
				if oModelCZG:VldData()
					oModelCZG:CommitData()
				Else
					lRet := .F.
					aErro := oModelCZG:GetErrorMessage()
				Endif
			Endif
	
			IF !lRet
	
				cLog += STR0014 + cProd + STR0015 + cVers + ' - ' +; // Produto Desenvolvido: ## Versão:
				        STR0035 + cItemPai + STR0036 + ' - ' + STR0037 + DGN->DGN_CDMD + PULALINHA //Produto Engenharia: ## Criação Ficha Técnica PCP ## Template:
	
				cLog += STR0025 + " [" + AllToChar( aErro[1] ) + "]" + PULALINHA  	// "   Id do formulário de origem:"
				cLog += STR0026 + " [" + AllToChar( aErro[2] ) + "]" + PULALINHA	// "   Id do campo de origem:     "
				cLog += STR0027 + " [" + AllToChar( aErro[3] ) + "]" + PULALINHA	// "   Id do formulário de erro:  "
				cLog += STR0028 + " [" + AllToChar( aErro[4] ) + "]" + PULALINHA	// "   Id do campo de erro:       "
				cLog += STR0029 + " [" + AllToChar( aErro[5] ) + "]" + PULALINHA	// "   Id do erro:                "
				cLog += STR0030 + " [" + AllToChar( aErro[6] ) + "]" + PULALINHA	// "   Mensagem do erro:          "
				cLog += STR0031 + " [" + AllToChar( aErro[7] ) + "]" + PULALINHA	// "   Mensagem da solução:       "
				cLog += STR0032 + " [" + AllToChar( aErro[8] ) + "]" + PULALINHA	// "   Valor atribuido:           "
				cLog += STR0033 + " [" + AllToChar( aErro[9] ) + "]" + PULALINHA	// "   Valor anterior:            "
	
				Exit
			Endif
	
			DGN->(dbSkip())
		End
	Else
		lEncont := .F.
	Endif
	
Return {lRet, lEncont}

//---------------------------------------------------------------------------
// DPRA342DGN - Cria registro de ficha técnica na versão
//---------------------------------------------------------------------------
Static Function DPRA342DGN(cProd, cVers, cItemPai)
	Local lRet         := .T.
	Local cTpAtrib     := ''
	Local nI           := 0
	Local oModelDGN
	Local oModelDGO
	Local aErro        := {}
	Local lEncont      := .F.
	Local nDGN         := 0
	Private aTemplates := {}
	Private lEnd := .f.
	Private lEntrou := .f.
	Private nVlIniFx, nVlFinFx, nVlFaixa
	Private cDGNCDACDV, cDGNCDMQ, cDGNCDMD
	Private cAbreTela := 'S'
	Private cExecVald := 'S'
	Private cFormNova := ""
	
	dbSelectArea('DGN')
	DGN->(dbSetOrder(1))
	
	if DGN->(dbSeek(xFilial('DGN')+cProd+cVers))
		While DGN->(!EOF()) .AND. DGN->DGN_CDACDV == cProd .AND. DGN->DGN_NRVRAC == cVers
			oModelDGN := FWLoadModel('DPRA210')
			oModelDGN:SetOperation(5)
			oModelDGN:Activate()
	
			if oModelDGN:VldData()
				oModelDGN:CommitData()
			Endif
	
			DGN->(dbSkip())
		End
	Endif
	
	DGN->(dbGoTop())
	DGN->(dbSetOrder(1))
	
	IF DGN->(dbSeek(xFilial('DGN')+cProd+PadR("",TamSX3('DG0_NRVRAC')[1])))
		lEncont := .T.
	
		While DGN->(!EOF()) .AND. DGN->DGN_CDACDV == cProd .AND. DGN->DGN_NRVRAC == PadR("",TamSX3('DG0_NRVRAC')[1])
			nDGN := DGN->(RecNo())
	
			oModelDGN := FWLoadModel('DPRA210')
			oModelDGN:SetOperation(3)
			oModelDGN:Activate()
	
			oModelDGN:SetValue('DGNMASTER','DGN_CDACDV',cProd)
			oModelDGN:SetValue('DGNMASTER','DGN_NRVRAC',cVers)
	
			IF !Empty(DGN->DGN_CDMQ)
				oModelDGN:SetValue('DGNMASTER','DGN_CDMQ'  ,DGN->DGN_CDMQ)
			Endif
	
			oModelDGN:SetValue('DGNMASTER','DGN_CDMD'  ,DGN->DGN_CDMD)
	
			dbSelectArea('DGO')
			DGO->(dbSetOrder(1))
			IF DGO->(dbSeek(xFilial('DGO')+DGN->DGN_CDACDV+DGN->DGN_NRVRAC+DGN->DGN_CDMQ+DGN->DGN_CDMD))
	
				oModelDGO := oModelDGN:GetModel('DGODETAIL')
	
				While DGO->(!EOF()) .AND. DGO->DGO_CDACDV == DGN->DGN_CDACDV .AND. DGO->DGO_NRVRAC == DGN->DGN_NRVRAC .AND.;
				                          DGO->DGO_CDMQ   == DGN->DGN_CDMQ   .AND. DGO->DGO_CDMD   == DGN->DGN_CDMD
	
					For nI := 1 to oModelDGO:GetQtdLine()
						oModelDGO:GoLine(nI)
	
						if !oModelDGO:IsDeleted() .AND. oModelDGO:GetValue('DGO_CDAB') == DGO->DGO_CDAB
	
							cTpAtrib := Posicione('CZB',1,xFilial('CZB')+DGO->DGO_CDAB,'CZB_TPAB')
	
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
								Case cTpAtrib == "O" // Tolerância
									oModelDGO:SetValue('DGO_VLNR', DGO->DGO_VLNR)
									oModelDGO:SetValue('DGO_VLAFMI', DGO->DGO_VLAFMI)
									oModelDGO:SetValue('DGO_VLAFMX', DGO->DGO_VLAFMX)
								Case cTpAtrib == "T" // Tabela
									oModelDGO:SetValue('DGO_VLTBSI', DGO->DGO_VLTBSI)
								Case cTpAtrib == "I" // Imagem
									oModelDGO:SetValue('DGO_BITMAP', DGO->DGO_BITMAP)
							EndCase
							
							Exit
						Endif
					Next
	
					DGO->(dbSkip())
				End
			Endif
	
			if oModelDGN:VldData()
				oModelDGN:CommitData()
			Else
				lRet := .F.
				aErro := oModelDGN:GetErrorMessage()
			Endif
	
			if !lRet
	
				cLog += STR0014 + cProd + STR0015 + cVers + ' - ' +; // Produto Desenvolvido: ## Versão:
				        STR0035 + cItemPai + STR0038 + ' - ' + STR0037 + DGN->DGN_CDMD + PULALINHA // Produto Engenharia: ## Criação Ficha Técnica para versão DP ## Template:
	
				cLog += STR0025 + " [" + AllToChar( aErro[1] ) + "]" + PULALINHA  	// "   Id do formulário de origem:"
				cLog += STR0026 + " [" + AllToChar( aErro[2] ) + "]" + PULALINHA	// "   Id do campo de origem:     "
				cLog += STR0027 + " [" + AllToChar( aErro[3] ) + "]" + PULALINHA	// "   Id do formulário de erro:  "
				cLog += STR0028 + " [" + AllToChar( aErro[4] ) + "]" + PULALINHA	// "   Id do campo de erro:       "
				cLog += STR0029 + " [" + AllToChar( aErro[5] ) + "]" + PULALINHA	// "   Id do erro:                "
				cLog += STR0030 + " [" + AllToChar( aErro[6] ) + "]" + PULALINHA	// "   Mensagem do erro:          "
				cLog += STR0031 + " [" + AllToChar( aErro[7] ) + "]" + PULALINHA	// "   Mensagem da solução:       "
				cLog += STR0032 + " [" + AllToChar( aErro[8] ) + "]" + PULALINHA	// "   Valor atribuido:           "
				cLog += STR0033 + " [" + AllToChar( aErro[9] ) + "]" + PULALINHA	// "   Valor anterior:            "
	
				Exit
			Endif
	
			DGN->(dbGoTo(nDGN))
	
			DGN->(dbSkip())
		End
	Else
		lEncont := .F.
	Endif
	
Return {lRet, lEncont}
