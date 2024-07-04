#INCLUDE "TOTVS.CH"
#INCLUDE "QDOA052.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "COLORS.CH" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDOA052    ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 20/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Cadastro de Solicitacoes                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDOA052()                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ SIGAQDO - Controle de Documentos e QDOA050()                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³ Processo reescrito por mudanca conceitual                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³   Data   ³ BOPS ³ Programador ³                 Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 04/01/02 ³ xxxx ³Eduardo S.   ³ Alterado para visualizar docto tambem em html.  ³±±
±±³ 17/01/02 ³ xxxx ³Eduardo S.   ³ Incluido o Botao "Itens Alterados" para J&J     ³±±
±±³ 21/01/02 ³ xxxx ³Eduardo S.   ³ Acerto para gravar antes do ponto QDOAP07       ³±±
±±³ 22/01/02 ³ xxxx ³Eduardo S.   ³ Acerto no envio de e-mail Doctos Existentes.    ³±±
±±³ 23/01/02 ³ xxxx ³Eduardo S.   ³ Incluido o parametro oWord nos Pontos de Entrada³±±
±±³ 08/02/02 ³ xxxx ³Eduardo S.   ³ Incluido o ponto de Entrada QDOAP20 para validar³±±
±±³          ³      ³             ³ antes da Gravacao (Inclusao/Alteracao).         ³±±
±±³ 27/02/02 ³ META ³Eduardo S.   ³ Alterado para gerar Aviso de Solicitacoes       ³±±
±±³ 26/03/02 ³ META ³Eduardo S.   ³ Alteracao utilizando o novo conceito de arquivos³±±
±±³          ³      ³             ³ de Usuarios/Departamentos do Quality.           ³±±
±±³ 30/04/02 ³ xxxx ³Eduardo S.   ³ Acerto para nao permitir a finaliz. da Inclusao/³±±
±±³          ³      ³             ³ Baixa da Solicitacao se nao for feita p/ToolBar.³±±
±±³ 28/06/02 ³ META ³Eduardo S.   ³ Alterado para visualizar Docto Externo.         ³±±
±±³ 03/12/02 ³ xxxx ³Eduardo S.   ³ Alterado para listar corretamente os textos(QA2)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina := {}

Private cFilPend		:= GetMv("MV_QDOPSOL",.F.,"S")

Aadd (aRotina, { OemToAnsi( STR0009 ), "AxPesqui",	    0, 1,,.F.} )  //"Pesquisar"
Aadd (aRotina, { OemToAnsi( STR0010 ), "QD052Visu",	    0, 2 } )  //"Visualizar"
Aadd (aRotina, { OemToAnsi( STR0011 ), "QD052Telas",	0, 3 } )  //"Incluir"
Aadd (aRotina, { OemToAnsi( STR0012 ), "QD052Telas",	0, 4 } )  //"Alterar"
Aadd (aRotina, { OemToAnsi( STR0013 ), "QD052Visu",	    0, 5 } )  //"Excluir"
Aadd (aRotina, { OemToAnsi( STR0014 ), "QD052Baixa",	0, 6 } )  //"Baixar"

//If cFilPend == "N"
//	Aadd (aRotina, { OemToAnsi( STR0083 ), "QD052Sele",	0, 6,,.F.} )  //"Muda Selecao"
//EndIf
Aadd (aRotina, { OemToAnsi( STR0081 ), "QD052Legen",	0, 8,,.F.} )  //"Legenda"

Return aRotina

Function QDOA052()

Local aCores			:= {}

Private cFilPend		:= GetMv("MV_QDOPSOL",.F.,"S")
Private lFunSol 		:= .F.
Private cNomFilial   := Space( 40 )
Private lCdx         := .T.
Private cFilApSol    := Space( FWSizeFilial() )
Private cCodApSol    := Space( 06 )
Private cFilApDes    := Space( FWSizeFilial() )
Private cCodApDes    := Space( 06 )
Private cCadastro    := OemToAnsi( STR0001 ) // "Cadastro de Solicita‡”es"
Private cTpCopia     := OemToAnsi( STR0002 ) // "C¢pia Controlada"
Private cDtEmiss     := CtoD( "  /  /  " , "DDMMYY" )
Private lPendencia   := .f.
Private lCritica     := .f.
Private lIncDepois   := .f.
Private lGeraRev     := .f.
Private lAltDoc      := .t.
Private Inclui			:= .t.
Private lSolicitacao	:= .f.
Private cChkWord		:= "0"
Private aListID		:= {}
Private aListWD		:= {}
Private bCampo			:= { |nCPO| Field( nCPO ) }
Private oWord
Private aRotina		:= MenuDef()
Private lNoCancel   :=.T. 
Private lGerRev		:=.F.


DbSelectArea( "QDP" )
DbSetOrder( 3 )

aCores := {{"QDP->QDP_SITSOL == 'A'", 'ENABLE' },;
				{ "QDP->QDP_SITSOL == 'R'", 'DISABLE'},;
				{ "QDP->QDP_SITSOL == 'E'", 'BR_AMARELO'}}

If cFilPend == "S"
	MsgRun( OemToAnsi( STR0016 ), OemToAnsi( STR0017 ), { || QD052FIL() } ) //"Selecionando Dados" ### "Aguarde..."
	QD052PendSol(.t.) // Verifica se Existe solicitacao em Analise
EndIf 

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'QDP' )
oBrowse:SetDescription( cCadastro )  
oBrowse:AddLegend( "QDP->QDP_SITSOL == 'A'", 'ENABLE', 		STR0078)  // Solicitação Aprovada
oBrowse:AddLegend( "QDP->QDP_SITSOL == 'R'", 'DISABLE', 	STR0079)  // Solicitação Reprovada
oBrowse:AddLegend( "QDP->QDP_SITSOL == 'E'", 'BR_AMARELO',	STR0080)  // Solicitação Em Análise
If cFilPend == "N"
	oBrowse:AddFilter("Muda Seleção","QDP_PENDEN == 'P'")		
EndIf

//mBrowse( 6, 1, 22, 75, "QDP",,,,,,aCores,,,,, .T.)
oBrowse:Activate()

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052Telas ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 14/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Cadastro de Solicitacoes                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDOA052(ExpC1,ExpN1,ExpN2)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpC1 - Alias do Arquivo                                          ³±±
±±³             ³ ExpN1 - Posicao do Registro                                       ³±±
±±³             ³ ExpN2 - Numero Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Telas( cAlias, nReg, nOpc )

Local oDlg
Local oNumSol
Local oDataGera
Local oDataBx
Local oUsrOrig
Local oDepto
Local oDescSol
Local oCombOrd
Local oRazao
Local oBtnAnexo
Local oBtnCria
Local oBtnPesqDoc
Local oFocus
Local oBtnCadDoc
Local oBtnVisDoc
Local oBtnItens
Local nRad01    := 1
Local cFocus    := ""
Local nTamLin   := 70
Local cEspecie	:= ""
Local nC		:= 0
Local lInit		:= .F.
Local cCampo 	:= " "
Local bCampo   := { |nCPO| Field( nCPO ) }
Local aUsrMat  := QA_USUARIO()
Local lApelido := aUsrMat[1]
Local aQPath   := QDOPATH()
Local cQPathTrm:= aQPath[3]
Local cUsrOrig := " "
Local cDepto   := " "
Local cDeptoBx := " "
Local cRespBx  := " "
Local dDataBx  := CTOD("  /  /  ")
Local dDataGera:= dDataBase
Local cRazao   := ""
Local aData    := {}
Local cCombOrd := ""
Local lFecha   := .F.
Local aCombOrd := {	OemToAnsi(STR0057),; // "Em Analise"
							OemToAnsi(STR0058),; // "Aprovado"
							OemToAnsi(STR0059)}  // "Reprovado"
Local cBotao     := GetMv("MV_QBSOL",.f.,"N")
Local cBlocSolEx := GetMv("MV_QDSLDEX",.f.,"2")   // Bloqueio de Solicitacao de novos documentos
Local l_Ap20   := .T.
Local cFilDep  := xFilial("QAD")
Local nPosQDP  := QDP->(RecNo())
Local nT
Local oBtnCDot
Local oFilUsr
Local oMatUsr
Local oDesUsr

Private oRadTipo
Private cMatFil     := aUsrMat[2]
Private cMatCod     := aUsrMat[3]
Private cMatDep     := aUsrMat[4]
Private cNumSol     := Space( 20 )
Private cDocBase	  := Space( 16 )
Private cDescSol    := Space (Tamsx3("QDP_DESSOL")[1])
Private cDocOrigem  := Space( 16 )
Private cRevisao    := Space( 03 )
Private cDocTitulo  := Space( 100 )
Private cTitulo     := Space( 50 )
Private cBtnPesqDoc := ""
Private cTpTxt      := ""
Private nRadTipo	  := 0
Private nUsado      := 0
Private nCnt        := 0
Private axTextos    := {}
Private aTELA[0][0]
Private aGETS[0]
Private aHeader[0]
Private aCols[0]
Private oTipDoc
Private cTipDoc  := SPACE(TamSX3( "QDH_CODTP" )[1])
Private cFilMat  := cFilAnt
Private cFilUsr	 := Space(FWSizeFilial())
Private cCodUsr	 := SPACE(TamSX3("QAA_MAT")[1])
Private cDesUsr	 := SPACE(TamSX3("QAA_NOME")[1])

If Type("cChkWord") <> "C"
	Private cChkWord:= "0"
Endif

DbSelectArea("QDP")
DbSetOrder(3)

If !lApelido
	If nOpc != 2
		Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
		Return .f.
	Endif
Endif

If nOpc == 4
	For nC := 1 To QDP->( FCount() )
		cCampo := Upper( AllTrim( QDP->( FieldName( nC ) ) ) )
		M->&cCampo := QDP->( FieldGet( FieldPos( cCampo ) ) )
	Next

	lInit := .f.
	If M->QDP_PENDEN <> "P"
		Help(" ", 1,"QD52JAPROC") //"Solicitacao ja Processada"
		Return .f.
	EndIf
	
	If !(cMatFil+cMatCod == M->QDP_FILMAT+M->QDP_MAT)
		MsgStop(OemToAnsi(STR0069), OemToAnsi(STR0019)) //"Usuario sem permisao para modificar Solicitacao" ### "Atencao"
		Return .f.
	EndIf
	
	cNumSol  := M->QDP_NUMSEQ
	cDocBase := M->QDP_DTOBAS
	cDescSol := M->QDP_DESSOL
	cUsrOrig := M->QDP_MAT
	cDepto   := M->QDP_DEPTO
	cRespBx  := M->QDP_MATBX
	cDeptoBx := M->QDP_DEPBX
	cCombOrd := M->QDP_SITSOL
	dDataBx  := M->QDP_DTBAIX
	dDataGera:= M->QDP_DTGERA
	cEspecie := Left( M->QDP_TPSOL + Space( 8 ), 8 )
	cRazao   := QA_RecTxt( M->QDP_CHAVE,cEspecie,1,nTamLin,"QA2",@axTextos)
		
	If Alltrim(M->QDP_TPSOL) == "SID"
		nRad01:= 1
	Else
		nRad01:= 2
	EndIf	
	If nRad01 == 2
		cDocOrigem:= M->QDP_DTOORI
		cRevisao  := M->QDP_RV
		cDocTitulo:= M->QDP_TITULO
	EndIf	
	cUsrOrig:= AllTrim(cUsrOrig) +" - "+QA_NUSR(M->QDP_FILMAT,M->QDP_MAT)
	If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD")) 
		cFilDep:= M->QDP_FILMAT
	EndIf
	cDepto:= AllTrim(cDepto)+" - "+QA_NDEPT(M->QDP_DEPTO,.T.,cFilDep)
	
	If nRad01 == 1
		cTipDoc	:=M->QDP_CODTP
		cFilUsr :=M->QDP_FILELA
		cCodUsr :=M->QDP_MATELA			
		cDesUsr :=QA_NUSR(cFilUsr,cCodUsr,.T.)
	Endif
Endif

If nOpc == 3 .or. nOpc == 7
	For nC := 1 TO QDP->( FCount() )
		cCampo := Eval( bCampo,nC )
		lInit  := .f.
		If ExistIni( cCampo )
			lInit := .t.
			M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
	        If ValType( M->&( cCampo ) ) = "C"
	            M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
			EndIf
			If M->&( cCampo ) == NIL
				lInit := .f.
			EndIf
		EndIf
		If !lInit
			M->&( cCampo ) := FieldGet( nC )
			Do Case
				Case ValType( M->&( cCampo ) ) == "C"
					M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
				Case ValType( M->&( cCampo ) ) == "N"
					M->&( cCampo ) := 0
				Case ValType( M->&( cCampo ) ) == "D"
					M->&( cCampo ) := CtoD( "  /  /  " , "DDMMYY" )
				Case ValType( M->&( cCampo ) ) == "L"
					M->&( cCampo ) := .f.
			End
		EndIf
	Next nC

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tela para escolha do tipo de Solicitacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 
		If Alltrim(cBlocSolEx) == "2" // Bloqueia Solicitacao de Documento Novo "2=Nao"
			If !QD052DlgSol(@nRad01)
				QDP->(DbGoto(nPosQDP))
				Return .F.
			EndIf		
		Else
	   		nRad01 := 2      
	 	Endif
	EndIf   

	If nRad01 == 1
		M->QDP_TPSOL := Alltrim( "SID" )
	Elseif nRad01==2
		M->QDP_TPSOL := Alltrim( "SAD" )
	EndIf

	If nOpc == 7
		nRad01 := 2
		DbSelectArea("QDH")
		M->QDP_NUMSEQ:= cNumSol
		M->QDP_TPSOL := "SAD"
		M->QDP_DTOORI:= M->QDH_DOCTO
		M->QDP_RV    := M->QDH_RV
		M->QDP_TITULO:= M->QDH_TITULO	

		cDocOrigem:= M->QDP_DTOORI
		cRevisao  := M->QDP_RV
		cDocTitulo:= M->QDP_TITULO
	EndIf

	If nRad01 == 1
		cNumSol := "SI" + QDO_SEQ("SI_QDP",5,"N")
	Elseif nRad01 == 2
		cNumSol := "SA" + QDO_SEQ("SA_QDP",5,"N")
	EndIf  

	cUsrOrig := AllTrim(cMatCod) +" - "+ aUsrMat[6]
	If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
		cFilDep:= M->QDP_FILMAT
	EndIf
	cDepto:= Alltrim(cMatDep)+" - "+QA_NDEPT(cMatDep,.T.,cFilDep)
	M->QDP_NUMSEQ := cNumSol
	If nRad01 == 1
		M->QDP_TPSOL := Alltrim( "SID" )
		cTipDoc	:=M->QDP_CODTP
		cFilUsr :=M->QDP_FILELA
		cCodUsr :=M->QDP_MATELA			
		cDesUsr :=QA_NUSR(cFilUsr,cCodUsr,.T.)
	Elseif nRad01 == 2
		M->QDP_TPSOL := Alltrim( "SAD" )
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verfica se existe Word³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cChkWord == "0"
	cChkWord:= Qd052Word()
EndIf

If nOpc == 3
	cTitulo := 	OemToAnsi( STR0011 ) + " - " + OemToAnsi( STR0011 ) +" "+; //" Solicita‡„o de Documentos" ### "Incluir"
	If( nRad01==1, OemToAnsi( STR0007 ), OemToAnsi( STR0008 ) )  //"Novos Documentos" ### "Documentos Existentes"
Elseif nOpc == 4
	cTitulo := 	OemToAnsi( STR0022 ) + " - " + OemToAnsi( STR0012 ) +" "+; //" Solicita‡„o de Documentos" ### "Alterar"
	If( nRad01==1, OemToAnsi( STR0007 ), OemToAnsi( STR0008 ) )  //"Novos Documentos" ### "Documentos Existentes"
Elseif nOpc == 7
	cTitulo := 	OemToAnsi( STR0011 ) + " - " + OemToAnsi( STR0012 ) +" "+ OemToAnsi( STR0008 ) //" Solicita‡„o de Documentos" ### "Alterar" ### "Documentos Existentes"
EndIf

If nRad01 == 1
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 340,625 OF oMainWnd PIXEL // Solicitacoes
Else
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 425,625 OF oMainWnd PIXEL // Solicitacoes
EndIf
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Panel                                                  ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
oPanel:= tSay():New(,,,oDlg)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criado o objeto oFocus porque quando o proximo campo eh³
//³ReadOnly o objeto atual nao perde o focus.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 003, 400 GET oFocus VAR cFocus SIZE 000,000 OF oPanel PIXEL

@ 003, 003 SAY OemToAnsi( STR0024 ) 	SIZE 60, 10 OF oPanel PIXEL // "Nr Solicita‡„o"
@ 002, 037 GET oNumSol VAR cNumSol 		SIZE 85, 10 OF oPanel PIXEL
oNumSol:lReadOnly:= .T.

@ 003, 127 SAY OemToAnsi( STR0052 )	SIZE 30, 10 OF oPanel PIXEL // Data
@ 002, 142 GET oDataGera VAR dDataGera	SIZE 40, 10 OF oPanel PIXEL
oDataGera:lReadOnly:= .T.

@ 003, 187 SAY OemToAnsi( STR0052 )+" "+OemToAnsi( STR0053 ) SIZE 80, 10 OF oPanel PIXEL // Data ## da Baixa
@ 002, 224 GET oDataBx VAR dDataBx		SIZE 40, 10 OF oPanel PIXEL
oDataBx:lReadOnly:= .T.

@ 017, 003 SAY OemToAnsi( STR0025 ) 	SIZE 45, 10 COLOR CLR_HBLUE OF oPanel PIXEL	// "Descri‡„o"
@ 016, 037 GET  oDescSol VAR cDescSol SIZE 145, 10 OF oPanel PIXEL

@ 017, 187 SAY OemToAnsi( STR0029 ) SIZE	020, 010 OF oPanel PIXEL // "Status"
@ 016, 204 COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 060,010 PIXEL OF oPanel

@ 031, 003 SAY OemToAnsi( STR0027 )	SIZE 030, 10 COLOR CLR_HBLUE OF oPanel PIXEL // " Razao "
@ 030, 037 GET oRazao VAR cRazao MEMO NO VSCROLL SIZE 226, 031 OF oPanel PIXEL                      

@ 064, 003 SAY OemToAnsi( STR0060 )	SIZE 030, 10 OF oPanel PIXEL // Solicitante
@ 063, 037 GET oUsrOrig	VAR cUsrOrig   SIZE 105, 10 OF oPanel PIXEL
@ 064, 145 SAY OemToAnsi( STR0061 ) 	SIZE 030, 10 OF oPanel PIXEL // Depto
@ 063, 165 GET oDepto  	VAR cDepto  	SIZE 099, 10 OF oPanel PIXEL
oUsrOrig:lReadOnly:= .T.
oDepto:lReadOnly:= .T.

If nRad01 == 1
	@ 000,265 BUTTON oBtnAnexo PROMPT 	OemToAnsi(STR0054)	SIZE 045, 012 PIXEL OF oPanel; //Anexo
					ACTION ( If ( ExistBlock( "QDOAP10" ), ExecBlock( "QDOAP10", .f., .f., {nOpc,@oWord} ), ;
									(QD052Anexo(nOpc),If(oBtnCria <> Nil,If(Empty(cDocBase),;
									(oBtnCria:Enable() ,oBtnAnexo:bLostFocus := {||""},oBtnCria:bLostFocus:= {||oDescSol:SetFocus(.T.)}),;
									(oBtnCria:Disable(),oBtnCria:bLostFocus  := {||""},oBtnAnexo:bLostFocus := {||oDescSol:SetFocus(.T.)}) ),))))
EndIf

If nRad01 == 2
	DbSelectArea("QDH")
	DbSetOrder(1)
	Qd052FiltQDH()
	If !QDH->(DbSeek(xFilial("QDP")+cDocOrigem+cRevisao))
		DbGotop()
	EndIf
	@ 078, 003 TO 180, 308 LABEL OemToAnsi( STR0005 ) OF oPanel PIXEL //Documentos
	@ 130, 007 	LISTBOX	oQDH;
					FIELDS	QDH->QDH_DOCTO,;
								QDH->QDH_RV,;
								QDH->QDH_TITULO;
					HEADER	OemToAnsi( STR0033 ),; // "Documento"
								OemToAnsi( STR0031 ),; // "Revis„o"
								OemToAnsi( STR0032 );  // "T¡tulo"
					SIZE	296, 075 OF oDlg PIXEL;
					ALIAS	"QDH"
	If nOpc == 7
		oQDH:lReadOnly:= .T.
	EndIf
	
	@ 084, 140 BUTTON oBtnCadDoc PROMPT OemToAnsi( STR0076 ) SIZE 055, 012 PIXEL OF oPanel; // "Pesquisa Docto"
					ACTION (QD050Telas("QDH",QDH->(RecNo()),8), Qd052FiltQDH(), oQDH:Refresh())
	
	@ 084, 195 BUTTON oBtnVisDoc PROMPT OemToAnsi( STR0077 ) SIZE 055, 012 PIXEL OF oPanel; // "Pesquisa Docto"
					ACTION Qd052ViewDoc( QDH->QDH_DOCTO, QDH->QDH_RV )
	
	@ 084, 250 BUTTON oBtnPesqDoc PROMPT OemToAnsi( STR0070 ) SIZE 055, 012 PIXEL OF oPanel; // "Pesquisa Docto"
					ACTION (AxPesqui(),oQDH:Refresh())
	If nOpc == 7
		oBtnPesqDoc:Disable()
	EndIf
	
	@ 001,265 BUTTON oBtnAnexo PROMPT 	OemToAnsi(STR0054)	SIZE 045, 012 PIXEL OF oPanel; //Anexo
					ACTION ( If ( ExistBlock( "QDOAP05" ), ExecBlock( "QDOAP05", .f., .f., {nOpc,@oWord} ), ;
									(QD052Anexo(nOpc),If(oBtnCria <> Nil,If(Empty(cDocBase),;
									(oBtnCria:Enable() ,oBtnAnexo:bLostFocus := {||""},oBtnCria:bLostFocus:= {||oDescSol:SetFocus(.T.)}),;
									(oBtnCria:Disable(),oBtnCria:bLostFocus  := {||""},oBtnAnexo:bLostFocus := {||oDescSol:SetFocus(.T.)}) ),))))
EndIf

//If cChkWord == "1" // Existe Word
	@ 14,265 BUTTON oBtnCria 	PROMPT 	OemToAnsi(STR0055) 	SIZE 045, 012 PIXEL OF oPanel; // Criar
					ACTION  (QD052NewDoc(.F.),oBtnCria:Disable(),IF(oBtnCDot<>Nil,oBtnCDot:Disable(),""),oBtnAnexo:bLostFocus := {||oDescSol:SetFocus(.T.)})
	If !Empty(cDocBase)
		oBtnCria:Disable()
	EndIf                 	
		
	If nRad01 == 1
		@ 078, 003 SAY OemToAnsi( TitSx3("QDH_CODTP")[1] )	SIZE 030, 10 OF oPanel PIXEL 
		@ 078, 037 MSGET oTipDoc VAR cTipDoc F3 'QD2' VALID IF(!Empty(cTipDoc),ExistCpo("QD2",cTipDoc),.T.) SIZE 040, 10  OF oPanel PIXEL
		oTipDoc:BWhen:={|| Empty(cDocBase) }	
	
		@ 026,265 BUTTON oBtnCDot 	PROMPT 	OemToAnsi(STR0089) SIZE 045, 012 PIXEL OF oPanel;  //"Criar Doc/Modelo"
					ACTION  (QD052NewDoc(.T.),oBtnCria:Disable(),oBtnCDot:Disable(),oBtnAnexo:bLostFocus := {||oDescSol:SetFocus(.T.)})
		oBtnCDot:BWhen:={|| Empty(cDocBase) .AND. !Empty(cTipDoc)}			
                                                                            
	    @ 106,003 TO 135,265 LABEL OemToAnsi(STR0090) OF oPanel PIXEL  //"Usuario Elaborador"
		@ 116,006 SAY OemToAnsi( TitSx3("QAA_FILIAL")[1]) 	SIZE 25, 10  OF oPanel PIXEL
		@ 116,033 MSGET oFilUsr VAR cFilUsr SIZE 010,010  F3 "SM0" OF oPanel PIXEL;
						VALID IF(FWModeAccess("QDP") == "E",QA_CHKFIL(cFilUsr,@cFilMat),.T.) WHEN nOpc == 3
		oFilUsr:bChange:={|| cCodUsr:=SPACE(TamSX3("QAA_MAT")[1]),cDesUsr:=SPACE(TamSX3("QAA_NOME")[1]), oMatUsr:Refresh(),oDesUsr:Refresh() }
						
		@ 116,080 SAY OemToAnsi(TitSx3("QAA_MAT")[1]) 	SIZE 25,10  OF oPanel PIXEL
		@ 116,100 MSGET oMatUsr VAR cCodUsr F3 "QAA2" SIZE 55,10 OF oPanel PIXEL ;
		            VALID IF(!Empty(cCodUsr),(IF(Empty(cDesUsr:=QD052VEl(cFilUsr,cCodUsr)),(oMatUsr:Refresh(),oDesUsr:Refresh(),.F.),(oDesUsr:Refresh(),.T.))),.T.) WHEN nOpc == 3
		            		 
		@ 116,164 MSGET oDesUsr VAR cDesUsr SIZE 100,010 OF oPanel PIXEL 
		oDesUsr:lReadOnly:= .T.
						
	EndIf                 	
			
//EndIf

If cBotao == "S"
	@ 026,265 BUTTON oBtnItens PROMPT OemToAnsi(STR0086) SIZE 045, 012 PIXEL OF oPanel; // Itens Alterado
		       ACTION  If(ExistBlock("QDOAP09"),ExecBlock("QDOAP09",.f.,.f.,{nOpc,@oWord}),)
Endif


If nOpc == 3 .Or. nOpc == 7
	oCombOrd:nAt:= 1
Else
	If M->QDP_SITSOL == "E"
		oCombOrd:nAt:= 1
	ElseIf M->QDP_SITSOL == "A"
		oCombOrd:nAt:= 2
	ElseIf M->QDP_SITSOL == "R"
		oCombOrd:nAt:= 3
	EndIf
EndIf
oCombOrd:lReadOnly:= .T.

If oBtnCria == NIL
	oBtnAnexo:bLostFocus := {||oDescSol:SetFocus(.T.)}
ElseIf oBtnCria:LACTIVE == .F.
	oBtnAnexo:bLostFocus := {||oDescSol:SetFocus(.T.)}
Else
	oBtnCria:bLostFocus := {||oDescSol:SetFocus(.T.)}
EndIf

If nOpc == 3 .or. nOpc == 4 
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,; 
		{|| lFecha:= .T.,If(ExistBlock("QDOAP20"),l_Ap20:=ExecBlock("QDOAP20",.f.,.f.,{nOpc,@oWord, QDH->QDH_DOCTO, QDH->QDH_RV}),),;
      	If(l_Ap20,If(QD052GrRvs(nOpc,cRazao,nRad01),(If(ExistBlock("QDOAP06"),ExecBlock("QDOAP06",.f.,.f.,{nOpc,@oWord}),),oDlg:End()),),)},;
		{|| If(nOpc==3,Qd052ApQa4(nRad01),),oDlg:End() } ) VALID lFecha CENTERED 
EndIf 

If nOpc == 7 
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,; 
	   	{|| If(ExistBlock("QDOAP20"),l_Ap20:=ExecBlock("QDOAP20",.f.,.f.,{nOpc,@oWord, cDocOrigem, cRevisao}),),;
		If(l_Ap20,If(QD052GrRvs(3,cRazao,nRad01),(If(ExistBlock("QDOAP07"),ExecBlock("QDOAP07",.f.,.f.,{nOpc,@oWord}),),oDlg:End()),),)},;
	    {|| Qd052ApQa4(nRad01),oDlg:End() } ) CENTERED 
EndIf 

DbSelectArea("QDP")
DbSetOrder(3)
QDP->(DbGoto(nPosQDP))

If Type("oWord") <> "U"
	If !Empty(oWord) .And. oWord <> "-1"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord ) 
	Endif                            
Endif


If File(cQPathTrm+Qd052Arquivo())
	FErase(cQPathTrm+Qd052Arquivo())
Endif
aData  := DIRECTORY(cQPathTrm+"*.CEL")
For nT:= 1 to Len(aData)
	If File(cQPathTrm+AllTrim(aData[nT,1]))
		FErase(cQPathTrm+AllTrim(aData[nT,1]))
   Endif
Next
aData  := DIRECTORY(cQPathTrm+"*.HTM")
For nT:= 1 to Len(aData)
	If File(cQPathTrm+AllTrim(aData[nT,1]))
		QDRemDirHtm(AllTrim(aData[nT,1]),.F.)
   Endif
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052Visu  ³ Autor ³ Eduardo de Souza           ³ Data ³ 06/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Cadastro de Solicitacoes - Visualizar / Excluir                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052Visu(ExpC1,ExpN1,ExpN2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpC1 - Alias do Arquivo                                          ³±±
±±³             ³ ExpN1 - Posicao do Registro                                       ³±±
±±³             ³ ExpN2 - Numero Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Visu( cAlias, nReg, nOpc )

Local oDlg
Local oNumSol
Local oDataGera
Local oDataBx
Local oUsrOrig
Local oDepto
Local oDescSol
Local oCombOrd
Local oRazao
Local oBtnAnexo
Local oBtnCria
Local oBtnMotivo
Local oDocOrigem
Local oRespBx
Local oDeptoBx
Local oRevisao
Local nRad01	:= 1
Local	nTamLin	:= 70
Local cEspecie	:= ""
Local nC			:= 0
Local cCampo 	:= " "
Local aUsrMat  := QA_USUARIO()
Local lApelido := aUsrMat[1]
Local cUsrOrig := " "
Local cDepto   := " "
Local cDeptoBx := " "
Local cRespBx  := " "
Local dDataBx  := CTOD("  /  /  ")
Local dDataGera:= CTOD("  /  /  ")
Local cRazao	:= ""
Local aQPath   := QDOPATH()
Local cQPathTrm:= aQPath[3]
Local cCombOrd := ""
Local aCombOrd := {	OemToAnsi(STR0057),; // "Em Analise"
							OemToAnsi(STR0058),; // "Aprovado"
							OemToAnsi(STR0059)}  // "Reprovado"
Local cBotao   := GetMv("MV_QBSOL",.f.,"N")
Local cFilDep  := xFilial("QAD")
Local oTipDoc
Local cTipDoc  := SPACE(TamSX3( "QDH_CODTP" )[1])
Local oPanel

Private oRadTipo
Private cMatFil     := aUsrMat[2]
Private cMatCod     := aUsrMat[3]
Private cMatDep     := aUsrMat[4]
Private cNumSol     := Space( 20 )
Private cDocBase	  := Space( 16 )
Private cDescSol    := Space (Tamsx3("QDP_DESSOL")[1])
Private cDocOrigem  := Space( 16 )
Private cRevisao    := Space( 03 )
Private cDocTitulo  := Space( 100 )
Private cTitulo     := Space( 50 )
Private cBtnPesqDoc := ""
Private cTpTxt      := ""
Private nRadTipo
Private nUsado      := 0
Private nCnt        := 0
Private aTELA[0][0]
Private aGETS[0]
Private aHeader[0]
Private aCols[0]
Private axTextos    := {}

DbSelectArea("QDP")
DbSetOrder(3)

If !lApelido
	If nOpc != 2
		Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
		Return .f.
	Endif
Endif

For nC := 1 To QDP->( FCount() )
	cCampo := Upper( AllTrim( QDP->( FieldName( nC ) ) ) )
	M->&cCampo := QDP->( FieldGet( FieldPos( cCampo ) ) )
Next

If nOpc == 5
	If M->QDP_PENDEN <> "P"
		Help(" ", 1,"QD52JAPROC") // "Solicitacao ja Processada"
		Return .f.
	EndIf
	
	If !(cMatFil+cMatCod == M->QDP_FILMAT+M->QDP_MAT)
		MsgStop(OemToAnsi(STR0069), OemToAnsi(STR0019)) //"Usuario sem permisao para modificar Solicitacao" ### "Atencao"
		Return .F.
	EndIf
EndIf

cNumSol   := M->QDP_NUMSEQ
cDocBase  := M->QDP_DTOBAS
cDescSol  := M->QDP_DESSOL
cUsrOrig  := M->QDP_MAT
cDepto    := M->QDP_DEPTO
cRespBx   := M->QDP_MATBX
cDeptoBx  := M->QDP_DEPBX
cCombOrd  := M->QDP_SITSOL
dDataBx   := M->QDP_DTBAIX
cEspecie  := Left( M->QDP_TPSOL + Space( 8 ), 8 )
dDataGera := M->QDP_DTGERA
cRazao    := QA_RecTxt( M->QDP_CHAVE,cEspecie,1,nTamLin,"QA2",@axTextos) 

If Alltrim(M->QDP_TPSOL) == "SID"
	nRad01:= 1
Else
	nRad01:= 2
EndIf

If nRad01 == 2
	cDocOrigem:= M->QDP_DTOORI
	cRevisao  := M->QDP_RV
	cDocTitulo:= M->QDP_TITULO
EndIf
cUsrOrig:= AllTrim(cUsrOrig)+" - "+QA_NUSR(M->QDP_FILMAT,M->QDP_MAT)
cRespBx:= AllTrim(cRespBx)+" - "+QA_NUSR(M->QDP_FMATBX,M->QDP_MATBX)

If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
	cFilDep:= M->QDP_FILMAT
EndIf
cDepto:= AllTrim(cDepto)+" - "+QA_NDEPT(M->QDP_DEPTO,.T.,cFilDep)

If FWModeAccess("QAD") == "E"//!Empty(xFilial("QAD"))
	cFilDep:= M->QDP_FMATBX
EndIf
cDeptoBx:= AllTrim(cDeptoBx)+" - "+QA_NDEPT(M->QDP_DEPBX,.T.,cFilDep)

If nOpc == 2
	cTitulo :=	OemToAnsi( STR0022 ) + " - " + OemToAnsi( STR0010 ) +" "+; //" Solicita‡„o de Documentos" ### "Visualizar"
	If( nRad01==1, OemToAnsi( STR0007 ), OemToAnsi( STR0008 ) )  //"Novos Documentos" ### "Documentos Existentes"
Elseif nOpc == 5
	cTitulo := 	OemToAnsi( STR0022 ) + " - " + OemToAnsi( STR0013 ) +" "+; //" Solicita‡„o de Documentos" ### "Excluir"
	If( nRad01==1, OemToAnsi( STR0007 ), OemToAnsi( STR0008 ) )  //"Novos Documentos" ### "Documentos Existentes"
EndIf

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 340,625 OF oMainWnd PIXEL // Solicitacoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Panel                                                  ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
oPanel:= tSay():New(,,,oDlg)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

@ 003, 003 SAY OemToAnsi( STR0024 ) 	SIZE 60, 10 OF oPanel PIXEL // "Nr Solicita‡„o"
@ 002, 037 GET oNumSol VAR cNumSol 		SIZE 85, 10 OF oPanel PIXEL
oNumSol:lReadOnly:= .T.

@ 003, 127 SAY OemToAnsi( STR0052 )	SIZE 30, 10 OF oPanel PIXEL // Data
@ 002, 142 GET oDataGera VAR dDataGera	SIZE 40, 10 OF oPanel PIXEL
oDataGera:lReadOnly:= .T.

@ 003, 186 SAY OemToAnsi( STR0052 )+" "+OemToAnsi( STR0053 ) SIZE 80, 10 OF oPanel PIXEL // Data ## da Baixa
@ 002, 224 GET oDataBx VAR dDataBx		SIZE 40, 10 OF oPanel PIXEL
oDataBx:lReadOnly:= .T.

@ 017, 003 SAY OemToAnsi( STR0025 ) 	SIZE 45, 10 COLOR CLR_HBLUE OF oPanel PIXEL	// "Descri‡„o"
@ 016, 037 GET  oDescSol VAR cDescSol SIZE 145, 10 OF oPanel PIXEL
oDescSol:lReadOnly:= .T.

@ 017, 186 SAY OemToAnsi( STR0029 ) SIZE	020, 010 OF oPanel PIXEL // "Status"
@ 016, 204 COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 060,010 PIXEL OF oPanel
If M->QDP_SITSOL == "E"
	oCombOrd:nAt:= 1
ElseIf M->QDP_SITSOL == "A"
	oCombOrd:nAt:= 2
ElseIf M->QDP_SITSOL == "R"
	oCombOrd:nAt:= 3
EndIf
oCombOrd:lReadOnly:= .T.

@ 031, 003 SAY OemToAnsi( STR0027 )	SIZE 030, 10 COLOR CLR_HBLUE OF oPanel PIXEL // " Razao "
@ 030, 037 GET oRazao VAR cRazao MEMO NO VSCROLL SIZE 226, 031 OF oPanel PIXEL
oRazao:lReadOnly:= .T.

@ 064, 003 SAY OemToAnsi( STR0060 )	SIZE 030, 10 OF oPanel PIXEL // Solicitante
@ 063, 037 GET oUsrOrig	VAR cUsrOrig   SIZE 105, 10 OF oPanel PIXEL
@ 064, 145 SAY OemToAnsi( STR0061 ) 	SIZE 030, 10 OF oPanel PIXEL // Depto
@ 063, 165 GET oDepto  	VAR cDepto  	SIZE 099, 10 OF oPanel PIXEL
oUsrOrig:lReadOnly:= .T.
oDepto:lReadOnly:= .T.

@ 078, 003 SAY OemToAnsi( STR0071 )		SIZE 030, 10 OF oPanel PIXEL // Resp. Baixa
@ 077, 037 GET oRespBx	VAR cRespBx			SIZE 105, 10 OF oPanel PIXEL
@ 078, 145 SAY OemToAnsi( STR0061 )		SIZE 030, 10 OF oPanel PIXEL // Depto
@ 077, 165 GET oDeptoBx 	VAR cDeptoBx  	SIZE 099, 10 OF oPanel PIXEL
oRespBx:lReadOnly:= .T.
oDeptoBx:lReadOnly:= .T.

If nRad01 == 2
	@ 092, 003 SAY OemToAnsi( STR0030 ) SIZE	040, 010 OF oPanel PIXEL // "Doc. Origem"
	@ 091, 037 GET oDocOrigem 	VAR cDocOrigem SIZE 069, 10 OF oPanel PIXEL
	oDocOrigem:lReadOnly:= .T.
	
	@ 092, 111 SAY OemToAnsi( STR0031 )	SIZE 030,010 OF oPanel PIXEL // Revisao
	@ 091, 134 GET oRevisao VAR cRevisao	SIZE 010,010 OF oPanel PIXEL
	oRevisao:lReadOnly:= .T.
	
	@ 107, 003 SAY OemToAnsi( STR0032 ) SIZE 040, 010 OF oPanel PIXEL // Titulo
	@ 106, 037 GET oTitulo VAR cDocTitulo 	 SIZE 158, 010 OF oPanel PIXEL
	oTitulo:lReadOnly:= .T.
EndIf

If nRad01 == 1
	@ 000,265 BUTTON oBtnAnexo PROMPT 	OemToAnsi(STR0054)	SIZE 045, 012 PIXEL OF oPanel; //Anexo
					ACTION ( If ( ExistBlock( "QDOAP10" ), ExecBlock( "QDOAP10", .f., .f., {nOpc,@oWord} ), ;
									(QD052Anexo(nOpc),If(oBtnCria <> Nil,If(Empty(cDocBase),oBtnCria:Enable(),oBtnCria:Disable() ), ) ) ) )

	cTipDoc:=M->QDP_CODTP
	
	@ 091, 003 SAY OemToAnsi( TitSx3("QDH_CODTP")[1] )	SIZE 030, 10 OF oPanel PIXEL 
	@ 091, 037 MSGET oTipDoc VAR cTipDoc F3 'QD2' SIZE 040, 10 OF oPanel PIXEL
	oTipDoc:lReadOnly:= .T.	

	cFilUsr :=M->QDP_FILELA
	cCodUsr :=M->QDP_MATELA			
	cDesUsr:=QA_NUSR(cFilUsr,cCodUsr,.T.)	            		 

    @ 106,003 TO 140,265 LABEL OemToAnsi(STR0090) OF oPanel PIXEL  //"Usuario Elaborador"
	@ 116,006 SAY OemToAnsi( TitSx3("QAA_FILIAL")[1]) 	SIZE 25, 10  OF oPanel PIXEL
	@ 116,033 MSGET oFilUsr VAR cFilUsr SIZE 010,010 F3 "SM0" OF oPanel PIXEL
	oFilUsr:lReadOnly:= .T.	
					
	@ 116,080 SAY OemToAnsi(TitSx3("QAA_MAT")[1]) 	SIZE 25, 10  OF oPanel PIXEL
	@ 116,100 MSGET oMatUsr VAR cCodUsr SIZE 055,010 OF oPanel PIXEL 
	oMatUsr:lReadOnly:= .T.               
	
	@ 116,164 MSGET oDesUsr VAR cDesUsr SIZE 100,010 OF oPanel PIXEL 
	oDesUsr:lReadOnly:= .T.																			

Else
	@ 000,265 BUTTON oBtnAnexo PROMPT 	OemToAnsi(STR0054)	SIZE 045, 012 PIXEL OF oPanel; //Anexo
					ACTION ( If ( ExistBlock( "QDOAP05" ), ExecBlock( "QDOAP05", .f., .f., {nOpc,@oWord} ), ;
									(QD052Anexo(nOpc),If(oBtnCria <> Nil,If(Empty(cDocBase),oBtnCria:Enable(),oBtnCria:Disable() ), ) ) ) )
EndIf

If Empty(cDocBase)
	oBtnAnexo:Disable()
EndIf

@ 013,265 BUTTON oBtnMotivo PROMPT 	OemToAnsi(STR0056)	SIZE 045, 012 PIXEL OF oPanel; //Motivo Reprovacao
					ACTION QD052Motiv(nOpc,,,nRad01)

If M->QDP_SITSOL <> "R"
	oBtnMotivo:Disable()
EndIf    

If cBotao == "S"
	@ 026,265 BUTTON oBtnItens PROMPT OemToAnsi(STR0086) SIZE 045, 012 PIXEL OF oPanel; // Itens Alterado
		       ACTION  If(ExistBlock("QDOAP09"),ExecBlock("QDOAP09",.f.,.f.,{nOpc,@oWord}),)
Endif

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
		{|| If(nOpc==5,(QD052ApSol(nOpc), ( If ( ExistBlock( "QDOAP08" ), ExecBlock( "QDOAP08", .f., .f.,{nOpc,@oWord} ), ) ),oDlg:End()),oDlg:End())},;
		{|| oDlg:End() } ) CENTERED

dbSelectArea("QDP")
DbSetOrder( 3 )

If File(cQPathTrm+Qd052Arquivo())
	FErase(cQPathTrm+Qd052Arquivo())
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052Baixa ³ Autor ³ Eduardo de Souza           ³ Data ³ 06/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Baixa de Solicitacoes                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052Baixa(ExpC1,ExpN1,WxpN2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpC1 - Alias do Arquivo                                          ³±±
±±³             ³ ExpN1 - Posicao do Registro                                       ³±±
±±³             ³ ExpN2 - Numero Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Baixa( cAlias, nReg, nOpc )

Local oDlg
Local oNumSol
Local oDataGera
Local oDataBx
Local oUsrOrig
Local oDepto
Local oDescSol
Local oCombOrd
Local oRazao
Local oBtnAnexo
Local oBtnCria
Local oBtnMotivo
Local oDocOrigem
Local oRevisao
Local oQDP
Local oFocus
Local oBtnCadDoc
Local oBtnVisDoc
Local oAnalise := LoadBitmap( GetResources(), "BR_AMARELO" )
Local oAprovado:= LoadBitmap( GetResources(), "BR_VERDE" )
Local oReprova := LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oBtnItens
Local nRad01	:= 1
Local aQPath   := QDOPATH()
Local cQPathTrm:= aQPath[3]
Local cFocus   := ""
Local cQDP
Local	nTamLin:= 70
Local cEspecie	:= ""
Local nC			:= 0
Local cCampo 	:= " "
Local aUsrMat  := QA_USUARIO()
Local lApelido := aUsrMat[1]
Local lRet		:= .f.
Local cUsrOrig := " "
Local cDepto   := " "
Local dDataBx  := CTOD("  /  /  ")
Local dDataGera:= dDataBase
Local aQDP     := {}
Local cRazao 	:= ""
Local aData    := {}
Local nOrd		:= ""
Local cCombOrd := ""
Local aCombOrd := {	OemToAnsi(STR0057),; // "Em Analise"
							OemToAnsi(STR0058),; // "Aprovado"
							OemToAnsi(STR0059)}  // "Reprovado"
Local cBotao   := GetMv("MV_QBSOL",.f.,"N")
Local cFilDep  := xFilial("QAD")
Local nPosQDP  := QDP->(RecNo())
Local nCnt := 0
Local nT
Local lMvQdoRevd:= GetMv("MV_QDOREVD",.F.,"2") == "1" //1=SIM ; 2=NAO Denife se o Digitador pode Gerar Revisao.							
Local lRespRv   := .F.
Local nOrdQd1   := QD1->(IndexOrd())
Local oTipDoc
Local cTipDoc  	:= SPACE(TamSX3( "QDH_CODTP" )[1])
Local oPanel

Private oRadTipo
Private cMatFil     := aUsrMat[2]
Private cMatCod     := aUsrMat[3]
Private cMatDep     := aUsrMat[4]
Private cNumSol     := Space( 20 )
Private cDocBase	  := Space( 16 )
Private cDescSol    := Space (Tamsx3("QDP_DESSOL")[1])
Private cDocOrigem  := Space( 16 )
Private cRevisao    := Space( 03 )
Private cDocTitulo  := Space( 100 )
Private cTitulo     := Space( 50 )
Private cBtnPesqDoc := ""
Private cTpTxt      := ""
Private nRadTipo
Private nUsado      := 0
Private aTELA[0][0]
Private aGETS[0]
Private aHeader[0]
Private aCols[0]
Private axTextos    := {}
Private oWord

cAlias:= Alias()
nOrd  := IndexOrd()
nReg  := RecNo()

DbSelectArea("QDP")
DbSetOrder(3)

If !lApelido
	If nOpc != 2
		Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
		Return .f.
	Endif
Endif

For nC := 1 To QDP->( FCount() )
	cCampo := Upper( AllTrim( QDP->( FieldName( nC ) ) ) )
	M->&cCampo := QDP->( FieldGet( FieldPos( cCampo ) ) )
Next

cNumSol  := M->QDP_NUMSEQ
cDocBase := M->QDP_DTOBAS
cUsrOrig := M->QDP_MAT
cDepto   := M->QDP_DEPTO
cDescSol := M->QDP_DESSOL
cEspecie := Left( M->QDP_TPSOL + Space( 8 ), 8 )
cRazao   := QA_RecTxt( M->QDP_CHAVE,cEspecie,1,nTamLin,"QA2",@axTextos ) 
dDataGera:= M->QDP_DTGERA
cCombOrd := M->QDP_SITSOL 

cUsrOrig:= AllTrim(cUsrOrig) +" - "+QA_NUSR(M->QDP_FILMAT,M->QDP_MAT)
If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
	cFilDep:= M->QDP_FILMAT
EndIf
cDepto:= AllTrim(cDepto)+" - "+QA_NDEPT(M->QDP_DEPTO,.T.,cFilDep)

If Alltrim(M->QDP_TPSOL) == "SID"
	nRad01:= 1
Else
	nRad01:= 2
EndIf

If nRad01 == 2
	cDocOrigem:= M->QDP_DTOORI
	cRevisao  := M->QDP_RV
	cDocTitulo:= M->QDP_TITULO
EndIf

M->QDP_FMATBX	:= aUsrMat[2]
M->QDP_MATBX 	:= aUsrMat[3]
M->QDP_DEPBX	:= aUsrMat[4]
M->QDP_DTBAIXA	:= dDataBase
dDataBx			:= dDataBase
   
If M->QDP_PENDEN <> "P"
	Help(" ", 1,"QD52JAPROC") //"Solicitacao ja Processada"
	Return .f.
EndIf

If nRad01 == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario atual e o elaborador do documento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "QD0" )
	DbSetOrder( 2 )
	If !(QD0->( DbSeek( M->QDP_FILIAL + M->QDP_DTOORI + M->QDP_RV + "E" + cMatFil + cMatDep + cMatCod ) ) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Permite o Digitador Gerar Revisao Conf.parametro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lMvQdoRevd
			QD1->(DbSetOrder(2))
			IF QD1->(DBSeek(M->QDP_FILIAL + M->QDP_DTOORI + M->QDP_RV+"D  "))
				IF QD1->QD1_FILMAT+QD1->QD1_MAT == cMatFil+cMatCod
					lRespRv:= .T.					
				Endif
			Endif 
			QD1->(DbSetOrder(nOrdQd1))
		Endif                                        
		IF !lRespRv
			MsgAlert( OemToAnsi( STR0044 ), OemToAnsi( STR0019 ) ) //"Usuario atual nao e elaborador deste documento" ### "Aten‡„o"
			Return .f.
		Endif
	Endif
EndIf

cTitulo := 	OemToAnsi( STR0022 ) + " - " + OemToAnsi( STR0014 ) +" "+; //" Solicita‡„o de Documentos" ### "Excluir"
If( nRad01==1, OemToAnsi( STR0007 ), OemToAnsi( STR0008 ) )  //"Novos Documentos" ### "Documentos Existentes"

If nRad01 == 1
	If !ChkPsw(92) // Baixa Solicitacao
		Return .f.
	EndIf

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 340,625 OF oMainWnd PIXEL // Solicitacoes

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Panel                                                  ³    
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
	oPanel:= tSay():New(,,,oDlg)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 017, 186 SAY OemToAnsi( STR0029 ) SIZE	020, 010 OF oPanel PIXEL // "Status"
	@ 016, 204 COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 060,010 PIXEL OF oPanel;
			ON CHANGE If(oBtnMotivo<>Nil,If(oCombOrd:nAt==3,oBtnMotivo:Enable(),oBtnMotivo:Disable()),)

	If M->QDP_SITSOL == "E"
		oCombOrd:nAt:= 1
	ElseIf M->QDP_SITSOL == "A"
		oCombOrd:nAt:= 2
	ElseIf M->QDP_SITSOL == "R"
		oCombOrd:nAt:= 3
	EndIf

	@ 003, 003 SAY OemToAnsi( STR0024 ) 	SIZE 60, 10 OF oPanel PIXEL // "Nr Solicita‡„o"
	@ 002, 037 GET oNumSol VAR cNumSol 		SIZE 85, 10 OF oPanel PIXEL
	oNumSol:lReadOnly:= .T.
	
	@ 003, 127 SAY OemToAnsi( STR0052 )	SIZE 30, 10 OF oPanel PIXEL // Data
	@ 002, 142 GET oDataGera VAR dDataGera	SIZE 40, 10 OF oPanel PIXEL
	oDataGera:lReadOnly:= .T.
	
	@ 003, 186 SAY OemToAnsi( STR0052 )+" "+OemToAnsi( STR0053 ) SIZE 80, 10 OF oPanel PIXEL // Data ## da Baixa
	@ 002, 224 GET oDataBx VAR dDataBx		SIZE 40, 10 OF oPanel PIXEL
	oDataBx:lReadOnly:= .T.
	
	@ 017, 003 SAY OemToAnsi( STR0025 ) 	SIZE 45, 10 COLOR CLR_HBLUE OF oPanel PIXEL	// "Descri‡„o"
	@ 016, 037 GET  oDescSol VAR cDescSol SIZE 145, 10 OF oPanel PIXEL
	oDescSol:lReadOnly:= .T.

	@ 031, 003 SAY OemToAnsi( STR0027 )	SIZE 030, 10 COLOR CLR_HBLUE OF oPanel PIXEL // " Razao "
	@ 030, 037 GET oRazao VAR cRazao MEMO NO VSCROLL SIZE 226, 031 OF oPanel PIXEL
	oRazao:lReadOnly:= .T.
	
	@ 064, 003 SAY OemToAnsi( STR0060 )	SIZE 030, 10 OF oPanel PIXEL // Solicitante
	@ 063, 037 GET oUsrOrig	VAR cUsrOrig   SIZE 105, 10 OF oPanel PIXEL
	@ 064, 145 SAY OemToAnsi( STR0061 ) 	SIZE 030, 10 OF oPanel PIXEL // Depto
	@ 063, 165 GET oDepto  	VAR cDepto  	SIZE 099, 10 OF oPanel PIXEL
	oUsrOrig:lReadOnly:= .T.
	oDepto:lReadOnly:= .T.    
	
	@ 001,265 BUTTON oBtnAnexo PROMPT 	OemToAnsi(STR0054)	SIZE 045, 012 PIXEL OF oPanel; //Anexo
				 ACTION If ( ExistBlock( "QDOAP10" ), ExecBlock( "QDOAP10", .f., .f., {nOpc,@oWord} ), ;
					          QD052Anexo(nOpc) )
   If Empty(cDocBase)
	   oBtnAnexo:Disable()
   Else
   	oBtnAnexo:Enable()
   EndIf
	
	@ 016,265 BUTTON oBtnMotivo PROMPT 	OemToAnsi(STR0056)	SIZE 045, 012 PIXEL OF oPanel; //Motivo Reprovacao
	       ACTION QD052Motiv(nOpc,,,nRad01)	       
	oBtnMotivo:Disable()

	If cBotao == "S"
		@ 027,265 BUTTON oBtnItens PROMPT OemToAnsi(STR0086) SIZE 045, 012 PIXEL OF oPanel; // Itens Alterados
			       ACTION  If(ExistBlock("QDOAP09"),ExecBlock("QDOAP09",.f.,.f.,{nOpc,@oWord}),)
	Endif
    
	cTipDoc	:=M->QDP_CODTP                        
	@ 078, 003 SAY OemToAnsi( TitSx3("QDH_CODTP")[1] )	SIZE 030, 10 OF oPanel PIXEL 
	@ 078, 037 MSGET oTipDoc VAR cTipDoc F3 'QD2' SIZE 040, 10  OF oPanel PIXEL
	oTipDoc:lReadOnly:= .T.
        
	cFilUsr :=M->QDP_FILELA
	cCodUsr :=M->QDP_MATELA			
	cDesUsr:=QA_NUSR(cFilUsr,cCodUsr,.T.)	  
	
 	@ 106,003 TO 135,265 LABEL OemToAnsi(STR0090) OF oPanel PIXEL  //"Usuario Elaborador"
	@ 116,006 SAY OemToAnsi( TitSx3("QAA_FILIAL")[1]) 	SIZE 25, 10  OF oPanel PIXEL
	@ 116,033 MSGET oFilUsr VAR cFilUsr SIZE 010,010 F3 "SM0" OF oPanel PIXEL
	oFilUsr:lReadOnly:= .T.	
					
	@ 116,080 SAY OemToAnsi(TitSx3("QAA_MAT")[1]) 	SIZE 25, 10  OF oPanel PIXEL
	@ 116,100 MSGET oMatUsr VAR cCodUsr SIZE 055,010 OF oPanel PIXEL 
	oMatUsr:lReadOnly:= .T.                    
	
	@ 116,164 MSGET oDesUsr VAR cDesUsr SIZE 100,010 OF oPanel PIXEL 
	oDesUsr:lReadOnly:= .T.																			
	
ElseIf nRad01 == 2
	
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 420,625 OF oMainWnd PIXEL // Solicitacoes
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Panel                                                  ³    
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
	oPanel:= tSay():New(,,,oDlg)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 003, 260 BUTTON oBtnCadDoc PROMPT OemToAnsi( STR0076 ) SIZE 050, 012 PIXEL OF oPanel; // "Pesquisa Docto"
   		 ACTION (QD050Telas("QDH",QDH->(DbSeek(xFilial("QDH")+M->QDP_DTOORI+M->QDP_RV )),8))

	@ 016, 260 BUTTON oBtnVisDoc PROMPT OemToAnsi( STR0077 ) SIZE 050, 012 PIXEL OF oPanel; // "Pesquisa Docto"
   		 ACTION Qd052ViewDoc( M->QDP_DTOORI, M->QDP_RV )

	Qd052aQDP(@aQDP)
	@ 033, 003 TO 161, 309 LABEL OemToAnsi( STR0003 ) OF oPanel PIXEL //Solicitacoes
   	@ 040, 009 LISTBOX oQDP Var cQDP FIELDS HEADER  " ",;
											                   TitSx3("QDP_NUMSEQ")[1],;
											                   TitSx3("QDP_DESSOL")[1],;
											                   TitSx3("QDP_MAT")[1],;
											                   TitSx3("QDP_DTGERA")[1] ;
              SIZE 250, 080 OF oPanel PIXEL;
			     ON      DBLCLICK( QD052Status( @aQDP, oQDP:nAt ), oQDP:Refresh() );
				  ON CHANGE	(QD052AtuCpo( aQDP, oQDP:nAt, @cRazao, @cUsrOrig, @cDepto, cDocBase ),;
		  						 oRazao:Refresh(), oUsrOrig:Refresh(),oDepto:Refresh(),;
				  				 If(Empty(cDocBase),oBtnAnexo:Disable(),oBtnAnexo:Enable()))

	bQDPLine := { || { If(aQDP[oQDP:nAt,1]=="E",(If(oBtnMotivo<>Nil .And. aQDP[oQDP:nRowPos,1]<>"R",oBtnMotivo:DisaBle(),),oAnalise ),;
							  If(aQDP[oQDP:nAt,1]=="A",(If(oBtnMotivo<>Nil .And. aQDP[oQDP:nRowPos,1]<>"R",oBtnMotivo:DisaBle(),),oAprovado),;
							  	 								  (If(oBtnMotivo<>Nil,oBtnMotivo:EnaBle() ,),oReprova ) ) ),;
							  aQDP[oQDP:nAt,5], aQDP[oQDP:nAt,7],aQDP[oQDP:nAt,8], aQDP[oQDP:nAt,9] } }

	oQDP:cToolTip := OemToAnsi( STR0051 ) //"Duplo click para Aprovar / Reprovar Solicita‡„o"
	oQDP:SetArray( aQDP )
	oQDP:bLine := bQDPLine

	For nCnt:= 1 to Len(aQDP)
		If aQDP[nCnt][5] == cNumSol
			oQDP:nAt:= nCnt
			Exit
		EndIf
	Next 
	
	@ 040,262 BUTTON oBtnAnexo PROMPT 	OemToAnsi(STR0054)	SIZE 045, 012 PIXEL OF oPanel; //Anexo
		 ACTION ( If ( ExistBlock( "QDOAP05" ), ExecBlock( "QDOAP05", .f., .f., {nOpc,@oWord} ), ;
			           (QD052Anexo(nOpc),If(oBtnCria <> Nil,If(Empty(cDocBase),oBtnCria:Enable(),oBtnCria:Disable() ), ) ) ) )   

	@ 053,262 BUTTON oBtnMotivo PROMPT 	OemToAnsi(STR0056)	SIZE 045, 012 PIXEL OF oPanel; //Motivo Reprovacao
	       ACTION  QD052Motiv(nOpc, @aQDP, oQDP:nAt,nRad01)

	@ 066,262 BUTTON oBtnLegen  PROMPT 	OemToAnsi(STR0072)	SIZE 045, 012 PIXEL OF oPanel; //Motivo Reprovacao
	       ACTION  QD052Legen()
	oBtnLegen:bLostFocus := {||oQDP:SetFocus(.T.)}

	If cBotao == "S"
		@ 079,262 BUTTON oBtnItens PROMPT OemToAnsi(STR0086) SIZE 045, 012 PIXEL OF oPanel; // Itens Alterados
			       ACTION  If(ExistBlock("QDOAP09"),ExecBlock("QDOAP09",.f.,.f.,{nOpc,@oWord}),)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criado o objeto oFocus porque quando o proximo campo eh³
	//³ReadOnly o objeto atual nao perde o focus.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 066, 400 GET oFocus VAR cFocus SIZE 000,000 OF oPanel PIXEL	 

	@ 005, 003 SAY OemToAnsi( STR0030 ) SIZE	040, 010 OF oPanel PIXEL // "Doc. Origem"
	@ 004, 037 GET oDocOrigem 	VAR cDocOrigem SIZE 069, 10 OF oPanel PIXEL
	oDocOrigem:lReadOnly:= .T.

	@ 005, 111 SAY OemToAnsi( STR0031 )	SIZE 030, 010 OF oPanel PIXEL // Revisao
	@ 004, 134 GET oRevisao VAR cRevisao	SIZE 010, 010 OF oPanel PIXEL
	oRevisao:lReadOnly:= .T.

	@ 019, 003 SAY OemToAnsi( STR0032 ) SIZE 040, 010 OF oPanel PIXEL // Titulo
	@ 018, 037 GET oTitulo VAR cDocTitulo 	 SIZE 158, 010 OF oPanel PIXEL
	oTitulo:lReadOnly:= .T.
				
	@ 129, 003 SAY OemToAnsi( STR0027 )	SIZE 030, 10 COLOR CLR_HBLUE OF oPanel PIXEL // " Razao "
	@ 128, 037 GET oRazao VAR cRazao MEMO NO VSCROLL SIZE 231, 031 OF oPanel PIXEL
	oRazao:lReadOnly:= .T.
	
	@ 165, 003 SAY OemToAnsi( STR0060 )	  SIZE 030, 10 OF oPanel PIXEL // Solicitante
	@ 163, 037 GET oUsrOrig	VAR cUsrOrig  SIZE 105, 10 OF oPanel PIXEL
	@ 165, 145 SAY OemToAnsi( STR0061 )   SIZE 030, 10 OF oPanel PIXEL // Depto
	@ 163, 165 GET oDepto  	VAR cDepto    SIZE 104, 10 OF oPanel PIXEL																																
	oUsrOrig:lReadOnly:= .T.
	oDepto:lReadOnly:= .T.
	
EndIf	

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,	{|| If(ExistBlock( "QDOAP15" ),(lRet:=ExecBlock("QDOAP15", .f., .f., {nOpc,@oWord,oQDP,aQDP }),oDlg:end()),;
																	If(QD052GrvBx( aQDP,If(nRad01==1,oCombOrd:nAt,), nOpc, nRad01,cDocBase,cTipDoc),(lRet:=.T.,oDlg:End(),QD052PendSol(.f.)),(IF(lNoCancel,(IIf(!Empty(oQDP) .And. aQDP[oQDP:nAt][1]=="A",aQDP[oQDP:nAt][1]:="E",),IIf(!Empty(oQDP),oQDP:Refresh(),)),))))},;
																	{|| QD052APQA2(aQDP, nRad01),lRet:= .F.,oDlg:End() } ) VALID lRet CENTERED

If File(cQPathTrm+Qd052Arquivo())
	FErase(cQPathTrm+Qd052Arquivo())
Endif
aData  := DIRECTORY(cQPathTrm+"*.CEL")
For nT:= 1 to Len(aData)
	If File(cQPathTrm+AllTrim(aData[nT,1]))
		FErase(cQPathTrm+AllTrim(aData[nT,1]))
   Endif
Next
aData  := DIRECTORY(cQPathTrm+"*.HTM")
For nT:= 1 to Len(aData)
	If File(cQPathTrm+AllTrim(aData[nT,1]))
		QDRemDirHtm(AllTrim(aData[nT,1]))
   Endif
Next

DbSelectArea(cAlias)
DbSetOrder(nOrd)
QDP->(DbGoto(nPosQDP))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052ApSol ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 14/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Executa a exclusao da solicitacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052ApSol(ExpN1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpN1 - Opcao do Browse                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052ApSol(nOpc)
Local aUsrMail	:= {}
Local aUsrMat 	:= QA_USUARIO()
Local aDiv    	:= {}
Local cPerm     := "N"

If M->QDP_PENDEN != "P"
	MsgAlert( OemToAnsi( STR0035 ), OemToAnsi( STR0019 ) ) // "Solicita‡„o j  atendida. Imposs¡vel de ser excluida !" ### "Aten‡„o"
	Return .t.
EndIf

If MsgYesNo( OemToAnsi( STR0037 ),OemToAnsi( STR0019 ) ) // "Confirma Exclusao ? " ### "Aten‡„o"
	DbSelectArea( "QDP" )
	If ExistBlock("QDOAP14")
		If !ExecBlock("QDOAP14",.f.,.f.,{nOpc,@oWord})
			Return .t.
		EndIf
	EndIf
	Reclock( "QDP", .f. )
	QDP->( DbDelete() )
	QDP->( MsUnlock() )
	CursorWait()
	If M->QDP_TPSOL == "SAD"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envia email avisando todos os Elaboradores do Docto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := QAA->(RecNo())
		nOrd := QAA->(IndexOrd())
		QAA->(dbSetOrder(1))
		If QD0->(DbSeek(M->QDP_FILIAL+M->QDP_DTOORI+M->QDP_RV+"E"))
			While QD0->(!Eof()) .And. M->QDP_FILIAL+M->QDP_DTOORI+M->QDP_RV+"E" == QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT
				IF QD0->QD0_FLAG<>"I"
					If QAA->(dbSeek(QD0->QD0_FILMAT+QD0->QD0_MAT))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Baixa o Aviso de Alteracao de Documento    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						QDS->(DbSetOrder(1))
						If QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"SAD"+M->QDP_DTOORI+M->QDP_RV+M->QDP_NUMSEQ))
							RecLock("QDS",.F.)
							QDS->QDS_PENDEN := "B"
							QDS->QDS_DTBAIX:= dDataBase
							QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
							QDS->QDS_FMATBX := cMatFil
							QDS->QDS_MATBX  := cMatCod
							QDS->QDS_DEPBX  := cMatDep
							QDS->(MsUnlock())
							QDS->(DbSkip())
						EndIf
						cMail := Trim(QAA->QAA_EMAIL)
						cEnv  := QAA->QAA_RECMAI
						cApel := Trim(QAA->QAA_APELID)
						If !Empty(cMail) .and. cEnv == "1"
		               		aDiv:= {{M->QDP_NUMSEQ,DTOC(M->QDP_DTGERA),M->QDP_FMATBX,M->QDP_MATBX,DTOC(M->QDP_DTBAIX),M->QDP_DEPBX}}
									fQdoTpMail(@aUsrMail,M->QDP_DTOORI,M->QDP_RV,M->QDP_TITULO,cMail,AllTrim(M->QDP_TPSOL)+AllTrim(Str(nOpc)),M->QDP_FILMAT,cApel,"","",M->QDP_DESSOL,aDiv)
						EndIf
					EndIf
				Endif
				QD0->(DbSkip())
			EndDo
			QAA->(dbGoTo(nPos))
			QAA->(dbSetOrder(nOrd))
            IF Len(aUsrMail) > 0
				QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
			Endif	
			aUsrMail := {}
		EndIf
	ElseIf M->QDP_TPSOL == "SID"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envia email avisando todos usuarios que tem acesso a Baixa de Solicitacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := QAA->(RecNo())
		nOrd := QAA->(IndexOrd())
		IF FWModeAccess("QDP")=="E" .AND. !Empty(cCodUsr) //!Empty(cFilUsr)
			If QAA->(DbSeek(cFilUsr+cCodUsr))
				If !Empty(QAA->QAA_LOGIN) .And. QA_SitFolh()		
					QDS->(DbSetOrder(1))
					If QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"SID"+Space(16)+Space(3)+M->QDP_NUMSEQ))
						RecLock("QDS",.F.)
						QDS->QDS_PENDEN := "B"
						QDS->QDS_DTBAIX:= dDataBase
						QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
						QDS->QDS_FMATBX := cMatFil
						QDS->QDS_MATBX  := cMatCod
						QDS->QDS_DEPBX  := cMatDep
						QDS->(MsUnlock())
						QDS->(DbSkip())
					EndIf
					cMail:= Trim(QAA->QAA_EMAIL)
					IF QAA->QAA_RECMAI == "1" .AND. !Empty(cMail)
						cApel:= Trim(QAA->QAA_APELID)
						aDiv := {{M->QDP_NUMSEQ,DTOC(M->QDP_DTGERA),M->QDP_FMATBX,M->QDP_MATBX,DTOC(M->QDP_DTBAIX),M->QDP_DEPBX}}
						fQdoTpMail(@aUsrMail,,,,cMail,AllTrim(M->QDP_TPSOL)+AllTrim(Str(nOpc)),,cApel,"","",M->QDP_DESSOL,aDiv)
					Endif							
                Endif
			Endif
		Else
			PswUpper( .t. )
			PswOrder( 2 )
			QAA->(dbSetOrder(1))
			If QAA->(DbSeek(cMatFil))
				While QAA->(!Eof()) .And. QAA->QAA_FILIAL == cMatFil
					If !Empty(QAA->QAA_LOGIN) .And. QA_SitFolh()
						
						cUser := QAA->QAA_LOGIN
						If PswSeek( cUser )
							aRet:= PswRet(2)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se usuario tem acesso para baixar Solicitacao³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							IF LEN(aRet) == 1
								cPerm := SubStr(aRet[1,5],92,1)
							ELSE
								cPerm := SubStr(aRet[2,5],92,1)
							ENDIF
							If cPerm == "S"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Baixa o Aviso de Inclusao de Documento     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								QDS->(DbSetOrder(1))
								If QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"SID"+Space(16)+Space(3)+M->QDP_NUMSEQ))
									RecLock("QDS",.F.)
									QDS->QDS_PENDEN := "B"
									QDS->QDS_DTBAIX:= dDataBase
									QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
									QDS->QDS_FMATBX := cMatFil
									QDS->QDS_MATBX  := cMatCod
									QDS->QDS_DEPBX  := cMatDep
									QDS->(MsUnlock())
									QDS->(DbSkip())
								EndIf
								cMail:= Trim(QAA->QAA_EMAIL)
								IF QAA->QAA_RECMAI == "1" .AND. !Empty(cMail)
									cApel:= Trim(QAA->QAA_APELID)
			                    	aDiv := {{M->QDP_NUMSEQ,DTOC(M->QDP_DTGERA),M->QDP_FMATBX,M->QDP_MATBX,DTOC(M->QDP_DTBAIX),M->QDP_DEPBX}}
									fQdoTpMail(@aUsrMail,,,,cMail,AllTrim(M->QDP_TPSOL)+AllTrim(Str(nOpc)),,cApel,"","",M->QDP_DESSOL,aDiv)
								Endif
							EndIf
						EndIf
					EndIf
					QAA->(DbSkip())
				EndDo    
			Endif
		Endif
		QAA->(dbGoTo(nPos))
		QAA->(dbSetOrder(nOrd))
  		IF Len(aUsrMail) > 0
			QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
		Endif	
		aUsrMail := {}		
	Endif
	CursorArrow()
	QA_DelTxt( M->QDP_CHAVE, Left( M->QDP_TPSOL + Space( 8 ),8 ) )
Endif

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052GrvBx ³ Autor ³ Eduardo de Souza           ³ Data ³ 12/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Grava a Baixa da Solicitacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052GrvBx(ExpA1,ExpN1,ExpN2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpA1 - Array contendo as solicitacoes referente ao docto.        ³±±
±±³             ³ ExpN1 - Opcao do ComboBox                                         ³±±
±±³             ³ ExpN2 - Opcao do Browse                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052GrvBx( aQDP, nAtComb, nOpc, nRad01, cDocBase,cTipDoc )

Local nC
Local cRev
Local lGera       	:= .f.
Local lBaixa      	:= .f.
Local aUsrMat     	:= QA_USUARIO()
Local lRet			:= .F.
Local lContinua   	:= .T.
Local aUsrMail		:= {}
Local cEspecie		:= "QD052MOT"
Local nOrdQDP		:= 0
Local nPosQDP		:= 0
Local aDiv			:= {}         
Local aQPath   		:= QDOPATH()
Local cQPathTrm		:= aQPath[3]

Private lRevisao    := .F.
Private cMatFil    	:= aUsrMat[2]
Private cMatCod    	:= aUsrMat[3]
Private cMatDep    	:= aUsrMat[4]

Private cCadastro  	:= OemToAnsi( STR0022 ) //" Solicita‡„o de Documentos"
Private cFilMat    	:= cFilAnt
Private cDocto     	:= " "
Private cInterno	:= "E"
Private lIncDepois 	:= .f.
Private lAltDoc    	:= .t.
Private lGeraRev   	:= .f.
Private aListID    	:= {}
Private aListWD    	:= {}
Private lTrat:= GetMv("MV_QDOQDG",.T.,.F.)

IF nAtComb == 2 //1=Em Analise, 2=Aprovado, 3=Reprovado
	IF MSGYESNO((STR0091), (STR0005)) // O Documento Solicitado será feito com a opção Interno?
		cInterno := "I"
	ENDIF
ENDIF

If Type("lQdBlorv") == "U"
	Private lQdBlorv :=  GetMv("MV_QDBLORV",.F.,"2")=="1" //1=SIM ; 2=NAO Define o Bloqueio do botao Gera Revisao quando a Solicitacoes pendentes 
Endif 

If nRad01 == 1
	If nAtComb <> 1
		If nAtComb == 2
			M->QDP_SITSOL:= "A"
		ElseIf nAtComb == 3
			M->QDP_SITSOL:= "R"
		EndIf
		
		If M->QDP_SITSOL == "R"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se foi digitado Motivo da Reprovacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "QA2" )
			DbSetOrder( 1 )
			If QA2->(DbSeek(xFilial()+cEspecie+M->QDP_CHAVE))
				If Empty(QA2->QA2_TEXTO)
					Help(" ", 1,"QD052MOTRE") //"Motivo da Reprovacao, Preenchimento obrigat¢rio !."
					lContinua := .F.
					lNoCancel:=.F.
				EndIf
			Else
				Help(" ", 1,"QD052MOTRE") //"Motivo da Reprovacao, Preenchimento obrigat¢rio !."
				lContinua := .F.
				lNoCancel:=.F.
			EndIf
		EndIf
		
		If lContinua
			If M->QDP_SITSOL == "A"
				Inclui  := .t.
				QA_DelTxt( M->QDP_CHAVE, cEspecie )
				nOrdQDP:= QDP->(IndexOrd())
				nPosQDP:= QDP->(RecNo())
				// Cria um novo documento
										    
			    IF !Empty(cTipDoc) .AND. !Empty(cDocBase)				   						
					If QD050Telas( "QDH",, 10 ) == 1				
						lBaixa:= .t.
					EndIf
				Else
					If QD050Telas( "QDH",, 3 ) == 1				
						lBaixa:= .t.
					EndIf
				Endif	                      
				
				QDP->(dbGoTo(nPosQDP))
				QDP->(dbSetOrder(nOrdQDP))
			Else
				lBaixa:= .t.
			EndIf
			
			If lBaixa
				CursorWait()
				DbSelectArea("QDP")
				RecLock( "QDP", .F. )
				QDP->QDP_PENDEN := "B"
				QDP->QDP_SITSOL := M->QDP_SITSOL
				QDP->QDP_DTBAIX := dDataBase
				QDP->QDP_HRBAIX := SubStr( Time(), 1, 5 )
				QDP->QDP_FMATBX := cMatFil
				QDP->QDP_MATBX  := cMatCod
				QDP->QDP_DEPBX  := cMatDep
				MsUnlock()
				lRet:= .T.
				
				If File(cQPathTrm+Qd052Arquivo())
					FErase(cQPathTrm+Qd052Arquivo())
				Endif
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Baixa o Aviso de Inclusao de Documento     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QDS->(DbSetOrder(2))
				If QDS->(DbSeek(xFilial("QDH")+Space(16)+Space(3)+"SID"+M->QDP_NUMSEQ+"P"))
					While QDS->(!Eof()) .And. QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV+QDS->QDS_TPPEND+QDS->QDS_CHAVE+QDS->QDS_PENDEN == xFilial("QDH")+Space(16)+Space(3)+"SID"+M->QDP_NUMSEQ+"P"
						RecLock("QDS",.F.)
						QDS->QDS_PENDEN := "B"
						QDS->QDS_DTBAIX:= dDataBase
						QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
						QDS->QDS_FMATBX := cMatFil
						QDS->QDS_MATBX  := cMatCod
						QDS->QDS_DEPBX  := cMatDep
						QDS->(MsUnlock())
						QDS->(DbSkip())
					EndDo
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Envia email avisando a Baixa para o usuario responsavel pela Solicitacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := QAA->(RecNo())
				nOrd := QAA->(IndexOrd())
				QAA->(dbSetOrder(1))
				If QAA->(DbSeek(M->QDP_FILMAT+M->QDP_MAT))
					If !Empty(QAA->QAA_EMAIL) .And. QAA->QAA_RECMAI == "1"	 .And. QA_SitFolh()
						aDiv:= {{M->QDP_NUMSEQ,DTOC(M->QDP_DTGERA),M->QDP_FMATBX,M->QDP_MATBX,DTOC(M->QDP_DTBAIX),M->QDP_DEPBX}}
						fQdoTpMail(@aUsrMail,,,,Trim(QAA->QAA_EMAIL),AllTrim(M->QDP_TPSOL)+AllTrim(Str(nOpc)),,Trim(QAA->QAA_APELID),"","",M->QDP_DESSOL,aDiv)
					EndIf
					QAA->(dbGoTo(nPos))
					QAA->(dbSetOrder(nOrd))
				EndIf 
				IF Len(aUsrMail) > 0 
					QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
				Endif	
				aUsrMail := {}
				CursorArrow()
			EndIf 
			If Type("oWord") <> "U"
				If !Empty(oWord) .And. oWord <> "-1"
					OLE_CloseFile( oWord )
					OLE_CloseLink( oWord )
				Endif
			Endif
		EndIf
	Else
		Help(" ", 1,"QD052STAT") //"Somente e possivel Baixar Solicitacao com o Status de APROVADO ou REPROVADO"
		lRet:= .F.
	Endif
	
ElseIf nRad01 == 2
	lContinua:= .T.
	For nC:= 1 to Len(aQDP)
		If aQDP[nC][1] == "A"
			lGera := .T.
			QA_DelTxt( aQDP[nC][6], cEspecie )
		ElseIf aQDP[nC][1] == "R" .And. lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se foi digitado Motivo da Reprovacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "QA2" )
			DbSetOrder( 1 )
			If QA2->(DbSeek(xFilial()+"QD052MOT"+aQDP[nC][6]))
				If Empty(QA2->QA2_TEXTO)
					Help(" ", 1,"QD052MOTRE") //"Motivo da Reprovacao, Preenchimento obrigat¢rio !."
					lContinua:= .F.
				Else
					lBaixa:= .T.
				EndIf
			Else
				Help(" ", 1,"QD052MOTRE") //"Motivo da Reprovacao, Preenchimento obrigat¢rio !."
				lContinua:= .F.
			EndIf
		EndIf
	Next nC
	
	If lContinua
		If lGera
			cDocto := M->QDP_DTOORI
			cRev   := M->QDP_RV
			Dbselectarea( "QDH" )
			DbSetOrder( 1 )
			
			Set Filter To // Limpa Filtro QDH
			IF QDH->( DbSeek( xFilial( "QDH" ) + cDocto + cRev ) )
				lQdBlorv:=.F. //Define como NAO o Bloqueio do botao Gera Revisao quando a Solicitacoes pendentes 				
				lBaixa:= QD050GerRv() //Gera Nova Revisao
			Endif
		EndIf
		
		If lBaixa
			CursorWait()
			nPos := QAA->(RecNo())
			nOrd := QAA->(IndexOrd())
			DbSelectArea( "QDP" )
			DbSetOrder( 1 )
			For nC:= 1 to Len(aQDP)
				If aQDP[nC][1] <> "E"
					If QDP->(DbSeek(xFilial("QDP")+M->QDP_DTOORI+M->QDP_RV+aQDP[nC][5]))
						RecLock( "QDP", .f. )
						QDP->QDP_PENDEN := "B"
						QDP->QDP_SITSOL := aQDP[nC][1]
						QDP->QDP_DTBAIX := dDataBase
						QDP->QDP_HRBAIX := SubStr( Time(), 1, 5 )
						QDP->QDP_FMATBX := cMatFil
						QDP->QDP_MATBX	 := cMatCod
						QDP->QDP_DEPBX  := cMatDep
						MsUnlock()
					EndIf
					
					If aQDP[nC][1] <> "E"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Baixa o Aviso de Alteracao de Documento    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						QDS->(DbSetOrder(2))
						If QDS->(DbSeek(aQDP[nC,2]+aQDP[nC,3]+aQDP[nC,4]+"SAD"+aQDP[nC,5]+"P"))
							While QDS->(!Eof()) .And. QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV+QDS->QDS_TPPEND+QDS->QDS_CHAVE+QDS->QDS_PENDEN == aQDP[nC,2]+aQDP[nC,3]+aQDP[nC,4]+"SAD"+aQDP[nC,5]+"P"
								RecLock("QDS",.F.)
								QDS->QDS_PENDEN := "B"
								QDS->QDS_DTBAIX:= dDataBase
								QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
								QDS->QDS_FMATBX := cMatFil
								QDS->QDS_MATBX  := cMatCod
								QDS->QDS_DEPBX  := cMatDep
								QDS->(MsUnlock())
								QDS->(DbSkip())
							EndDo
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Envia email avisando a Baixa para o usuario responsavel pela Solicitacao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QAA->(dbSetOrder(1))
					If QAA->(DbSeek(aQDP[nC,10]+aQDP[nC,8]))
						If !Empty(QAA->QAA_EMAIL) .And. 	QAA->QAA_RECMAI == "1"	.And. QA_SitFolh()
							aDiv:= {{M->QDP_NUMSEQ,DTOC(QDP->QDP_DTGERA),QDP->QDP_FMATBX,QDP->QDP_MATBX,DTOC(QDP->QDP_DTBAIX),QDP->QDP_DEPBX}}
							fQdoTpMail(@aUsrMail,QDP->QDP_DTOORI,QDP->QDP_RV,QDP->QDP_TITULO,Trim(QAA->QAA_EMAIL), AllTrim(QDP->QDP_TPSOL)+AllTrim(Str(nOpc)),;
							aQDP[nC,10],Trim(QAA->QAA_APELID),"","",aQDP[nC,7],aDiv)
						EndIf
					EndIf
				EndIf
			Next nC
			lRet:= .T.         
			IF Len(aUsrMail) > 0
				QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
			Endif	
			aUsrMail := {}
			QAA->(dbGoTo(nPos))
			QAA->(dbSetOrder(nOrd))
			CursorArrow()
		Else
			Help(" ", 1,"QD052STAT") //"Somente e possivel Baixar Solicitacao com o Status de APROVADO ou REPROVADO"
			lRet:= .F.
		EndIf
	EndIf

	If Type("oWord") <> "U"
		If !Empty(oWord) .And. oWord <> "-1"
			OLE_CloseFile( oWord )
			OLE_CloseLink( oWord )
		Endif
	Endif

	If File(cQPathTrm+Qd052Arquivo())
		FErase(cQPathTrm+Qd052Arquivo())
	Endif
	
	If ExistBlock("QDOAP03")
		ExecBlock("QDOAP03", .f., .f., {nOpc,@oWord} )
	Endif
	
	QDP->(DbSetOrder(3))
	
Endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052GrRvs ³ Autor ³ Newton Rogerio Ghiraldelli ³ Data ³ 14/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Grava Solicitacao                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052GrRvs(ExpN1,ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpN1 - Opcao do Browse                                           ³±±
±±³             ³ ExpC1 - Razao da Solicitacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052GrRvs( nOpc, cRazao, nRad01 )

Local nC
Local nPos
Local cChave
Local lLock    	:= .t.
Local bCampo   	:= { |nCPO| Field( nCPO ) }
Local aUsrMail 	:= {}
Local nOrd     	:= 0
Local cEnv     	:= ""
Local cApel    	:= ""
Local cMail    	:= ""
Local aUsrMat  	:= QA_USUARIO()
Local cMatFil  	:= aUsrMat[2]
Local cMatCod  	:= aUsrMat[3]
Local cMatDep  	:= aUsrMat[4]
Local aRet		:= {" "}
Local cDocAnt	:= ""
Local cRvAnt 	:= ""
Local cTituAnt 	:= ""
Local cDesAnt  	:= ""
Local lDocAnt  	:= .F.
Local aDiv     	:= {}
Local aQPath   	:= QDOPATH()
Local cQPath   	:= aQPath[1]
Local cQPathTrm	:= aQPath[3]
Local cPerm     := "N"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Grava Memo Razao 		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QD052Razao( nOpc, cRazao, nRad01 )

If Empty(cDescSol) .Or. Empty(cRazao)
	Help(" ", 1,"QDOBRIG")
	lRet:= .F.
	Return lRet
EndIf

cDocBase := AllTrim(cDocBase)
If !Empty(cDocBase)
	_CopyFile( cDocBase, cQPathTrm + Qd052Arquivo())
	CpyT2S(cQPathTrm + Qd052Arquivo(),cQPath)
	If File(cQPathTrm + Qd052Arquivo())
		FErase(cQPathTrm + Qd052Arquivo())
	Endif
	cDocBase := Qd052Arquivo()
Endif

cDesAnt			:= M->QDP_DESSOL
M->QDP_DTOBAS	:= cDocBase
M->QDP_DESSOL	:= cDescSol
M->QDP_MAT   	:= cMatCod
M->QDP_PENDEN	:= "P"
M->QDP_SITSOL	:= "E"

If nRad01 == 1    
	M->QDP_CODTP:= cTipDoc              
	M->QDP_FILELA:= cFilUsr
	M->QDP_MATELA:= cCodUsr	
ElseIf nRad01 == 2
	If nOpc == 3 .Or. nOpc == 4
		cDocAnt := M->QDP_DTOORI
		cRvAnt  := M->QDP_RV
		cTituAnt:= M->QDP_TITULO
		M->QDP_DTOORI:= QDH->QDH_DOCTO
		M->QDP_RV    := QDH->QDH_RV
		M->QDP_TITULO:= QDH->QDH_TITULO
	Else
		M->QDP_DTOORI := cDocOrigem
		M->QDP_RV     := cRevisao
		M->QDP_TITULO := cDocTitulo
	EndIf
EndIf

If ( nOpc==3, lLock:=.t., lLock:=.f. )
Begin Transaction
cChave := M->QDP_FILIAL + M->QDP_NUMSEQ + M->QDP_TPSOL
DbSelectArea( "QDP" )
RecLock( "QDP", lLock, lLock )
For nC := 1 TO FCount()
	FieldPut( nC, M->&( Eval( bCampo,nC ) ) )
Next
lRet := .t.
End Transaction

CursorWait()
If M->QDP_TPSOL == "SID"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia email avisando todos usuarios que tem acesso a Baixa de Solicitacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3
		nPos := QAA->(RecNo())
		nOrd := QAA->(IndexOrd())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Envia email avisando todos usuarios que tem acesso a Baixa de Solicitacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !Empty(cFilUsr) .AND. !Empty(cCodUsr) 
			QAA->(dbSetOrder(1))
			If QAA->(DbSeek(cFilUsr+cCodUsr))
				If !Empty(QAA->QAA_LOGIN) .And. QA_SitFolh()					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava Aviso de Solicitacao de Novo Documento               	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					QDS->(DbSetOrder(1))
					If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"SID"+Space(16)+Space(3)+M->QDP_NUMSEQ))
						QDXGvAviso("SID",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,Space(16),Space(3),M->QDP_NUMSEQ,xFilial("QDH"))
					EndIf
					cMail:= Trim(QAA->QAA_EMAIL)
					IF QAA->QAA_RECMAI == "1" .AND. !Empty(cMail)
						cApel:= Trim(QAA->QAA_APELID)
						aDiv := {{ M->QDP_NUMSEQ,DTOC(M->QDP_DTGERA),M->QDP_FMATBX,M->QDP_MATBX,DTOC(M->QDP_DTBAIX),M->QDP_DEPBX }}
						fQdoTpMail(@aUsrMail,,,,cMail,AllTrim(M->QDP_TPSOL)+AllTrim(Str(nOpc)),,cApel,"","",M->QDP_DESSOL,aDiv)
					Endif
				Endif
			Endif		
		Else
			PswUpper( .t. )
			PswOrder( 2 )
			QAA->(dbSetOrder(1))
			If QAA->(DbSeek(cMatFil))
				While QAA->(!Eof()) .And. QAA->QAA_FILIAL == cMatFil
					If !Empty(QAA->QAA_LOGIN) .And. QA_SitFolh()  
						cUser := QAA->QAA_LOGIN
						If PswSeek( cUser )
							aRet:= PswRet(2)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se usuario tem acesso para baixar Solicitacao³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							IF LEN(aRet) == 1
								cPerm := SubStr(aRet[1,5],92,1)
							ELSE
								cPerm := SubStr(aRet[2,5],92,1)
							ENDIF
							If cPerm == "S"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Grava Aviso de Solicitacao de Novo Documento               	³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
								QDS->(DbSetOrder(1))
								If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"SID"+Space(16)+Space(3)+M->QDP_NUMSEQ))
									QDXGvAviso("SID",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,Space(16),Space(3),M->QDP_NUMSEQ,xFilial("QDH"))
								EndIf
								cMail:= Trim(QAA->QAA_EMAIL)
								IF QAA->QAA_RECMAI == "1" .AND. !Empty(cMail)
									cApel:= Trim(QAA->QAA_APELID)
									aDiv := {{ M->QDP_NUMSEQ,DTOC(M->QDP_DTGERA),M->QDP_FMATBX,M->QDP_MATBX,DTOC(M->QDP_DTBAIX),M->QDP_DEPBX }}
									fQdoTpMail(@aUsrMail,,,,cMail,AllTrim(M->QDP_TPSOL)+AllTrim(Str(nOpc)),,cApel,"","",M->QDP_DESSOL,aDiv)								
								EndIf
							Endif	
						EndIf
					EndIf
					QAA->(DbSkip())
				EndDo
			EndIf
	    Endif
		IF Len(aUsrMail) > 0
			QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
		Endif				
		aUsrMail := {}
		QAA->(dbGoTo(nPos))
		QAA->(dbSetOrder(nOrd))
	EndIf
ElseIf M->QDP_TPSOL == "SAD"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia email avisando todos os Elaboradores do Docto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos := QAA->(RecNo())
	nOrd := QAA->(IndexOrd())
	QAA->(dbSetOrder(1))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando for Selecionado outro Docto no ListBox, envia email para os Elabo-³
	//³radores do docto anterior avisando que a solicitacao foi cancelada.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 4 .And. cDocAnt+cRvAnt <> M->QDP_DTOORI+M->QDP_RV
		If QD0->(DbSeek(xFilial("QD0")+cDocAnt+cRvAnt+"E"))
			While QD0->(!Eof()) .And. xFilial("QD0")+cDocAnt+cRvAnt+"E" == QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT
			    IF QD0->QD0_FLAG<>"I"
					If QAA->(dbSeek(QD0->QD0_FILMAT+QD0->QD0_MAT))	
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Baixa o Aviso de Alteracao de Documento    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						QDS->(DbSetOrder(1))
						If QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"SAD"+cDocAnt+cRvAnt+M->QDP_NUMSEQ))
							RecLock("QDS",.F.)
							QDS->QDS_PENDEN := "B"
							QDS->QDS_DTBAIX:= dDataBase
							QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
							QDS->QDS_FMATBX := cMatFil
							QDS->QDS_MATBX  := cMatCod
							QDS->QDS_DEPBX  := cMatDep
							QDS->(MsUnlock())
							QDS->(DbSkip())
						EndIf
						cMail := Trim(QAA->QAA_EMAIL)
						cEnv  := QAA->QAA_RECMAI
						cApel := Trim(QAA->QAA_APELID)
						If !Empty(cMail) .and. cEnv == "1"
		               aDiv:= {{M->QDP_NUMSEQ,DTOC(M->QDP_DTGERA),M->QDP_FMATBX,M->QDP_MATBX,DTOC(M->QDP_DTBAIX),M->QDP_DEPBX}}
							fQdoTpMail(@aUsrMail,cDocAnt,cRvAnt,cTituAnt,cMail,"SAD5",M->QDP_FILMAT,cApel,"","",cDesAnt,aDiv)
						EndIf
					EndIf
				Endif
				QD0->(DbSkip())
			EndDo
			lDocAnt:= .T.
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia email para os Elaboradores do Docto atual informando da Solicitacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .Or. lDocAnt
		If QD0->(DbSeek(M->QDP_FILIAL+M->QDP_DTOORI+M->QDP_RV+"E"))
			While QD0->(!Eof()) .And. M->QDP_FILIAL+M->QDP_DTOORI+M->QDP_RV+"E" == QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV+QD0->QD0_AUT	
			    IF QD0->QD0_FLAG<>"I"
					If QAA->(dbSeek(QD0->QD0_FILMAT+QD0->QD0_MAT))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava Aviso de Solicitacao de Alteracao de Documento       	³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
						QDS->(DbSetOrder(1))
						If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"SAD"+M->QDP_DTOORI+M->QDP_RV+M->QDP_NUMSEQ))
							QDXGvAviso("SAD",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,M->QDP_DTOORI,M->QDP_RV,M->QDP_NUMSEQ,M->QDP_FILIAL)
		   				EndIf
						cMail := Trim(QAA->QAA_EMAIL)
						cEnv  := QAA->QAA_RECMAI
						cApel := Trim(QAA->QAA_APELID)
						If !Empty(cMail) .and. cEnv == "1"
		               		aDiv:= {{ M->QDP_NUMSEQ,DTOC(M->QDP_DTGERA),M->QDP_FMATBX,M->QDP_MATBX,DTOC(M->QDP_DTBAIX),M->QDP_DEPBX }}
							fQdoTpMail(@aUsrMail,M->QDP_DTOORI,M->QDP_RV,M->QDP_TITULO,cMail,AllTrim(M->QDP_TPSOL)+AllTrim(Str(nOpc)),M->QDP_FILMAT,cApel,"","",M->QDP_DESSOL,aDiv)
						EndIf
					EndIf
				Endif
				QD0->(DbSkip())
			EndDo
			QAA->(dbGoTo(nPos))
			QAA->(dbSetOrder(nOrd))
			IF Len(aUsrMail) > 0
				QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
			Endif	
			aUsrMail := {}
		EndIf
	EndIf
Endif
CursorArrow()
QDP->(DbSetOrder( 3 ))

If ExistBlock("QDOAP01")
	ExecBlock("QDOAP01", .f., .f., {nOpc,@oWord} )
Endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052Razao ³ Autor ³ Eduardo de Souza           ³ Data ³ 04/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Grava o texto da razao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052Razao(ExpN1,ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpN1 - Opcao do Browse                                           ³±±
±±³             ³ ExpC1 - Razao da Solicitacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOR052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Razao( nOpc, cRazao, nRad01 )

Local lFlag
Local cSol  := Space( 03 )
Local nOrder:= QDP->( IndexOrd() )
Local nLi	:= 1

Private	axTextos := {}

If ( ( nOpc <> 2 .and. nOpc <> 5 ), lFlag:=.t., lFlag:=.f. )
	
If nOpc == 2 .or. nOpc == 5 .Or. nOpc == 6
	cSol := M->QDP_TPSOL
Elseif nOpc == 3 .or. nOpc == 4
	If nRad01 == 1
		cSol := "SID"
	Elseif nRad01 == 2
		cSol := "SAD"
	EndIf
EndIf

If Empty( M->QDP_CHAVE )
	M->QDP_CHAVE := Left( cSol + Space( 8 ),8 ) + M->QDP_NUMSEQ
   M->QDP_CHAVE := QA_CvKey( M->QDP_CHAVE, "QDP", 2, "QDH", 2, .T., { "SAD","SID"} )
	QDP->( DbSetOrder( nOrder ) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza vetor com o texto digitado		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := ascan(axTextos, {|x| x[1] == nLi })
If nPos == 0
	Aadd(axTextos, { nLi, cRazao } )
Else
	axTextos[nPos][2] := cRazao
Endif

QA_GrvTxt( M->QDP_CHAVE, Left( cSol + Space( 8 ),8 ), 1, @axtextos,,65)

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052NewDoc³ Autor ³ Eduardo de Souza           ³ Data ³ 04/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Cria link com o Word para criar docto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052NewDoc()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052NewDoc(lUsaDot)

Local cEditor 	  := "TMsOleWord97"
Local aQPath      := QDOPATH()
Local cQPathD     := aQPath[2]
Local cQPathTrm   := aQPath[3]
Local cTextoD     := aQPath[4]
Local cMvSalvaDoc := GETMV("MV_QSAVEDC",.F.,1) // 1-Padrao Salva como DOC
Local cMvSave     := IIf( GetMV("MV_QSAVPSW",.F.,"1") == "1","CELEWIN400","" ) // "Verifica se insere senha ou nao

DEFAULT cInterno  := "I"

If !File(cQPathTrm+cDocBase)

    IF lUsaDot 
    	IF Empty(cTipDoc) 
    	 	Help( " ", 1, "QD_DOTNEXT" )
	      	Return .f.    	
    	Endif
    	
    	IF QD2->(DbSeek(xFilial( "QD2" ) +cTipDoc))
			If !Empty( QD2->QD2_MODELO )
				cTextoD := Alltrim( QD2->QD2_MODELO )
				If (TamSx3("QD2_MODELO")[1]) == 12
					If !File(cQPathD + Alltrim(QD2->QD2_MODELO))
						cTextoD := Alltrim( QD2->QD2_MODELO )	+ "X"
					Else
						cTextoD := Alltrim( QD2->QD2_MODELO )
					Endif                                             
				Else
					cTextoD := Alltrim( QD2->QD2_MODELO )				
				Endif
			EndIf
	   	Endif
	   	
	   	If !File( cQPathTrm + cTextoD )
			CpyS2T(cQPathD+cTextoD,cQPathTrm,.T.)
		   	If !File( cQPathTrm + cTextoD )
		      	Help( " ", 1, "QD_DOTNEXT" )
		      	Return .f.
			Endif
	   	EndIf
    Endif
    If Type("oWord") <> "U"
		If !Empty(oWord) .And. oWord <> "-1"
			OLE_CloseFile( oWord )
			OLE_CloseLink( oWord )
		EndIf
	Endif

	oWord := OLE_CreateLink( cEditor )           
	IF lUsaDot
		OLE_NewFile( oWord, ( cQPathTrm + cTextoD ) )
	Else		
		OLE_NewFile ( oWord )
	Endif

	IF cMvSalvaDoc == 1 
		If cInterno == "I"
			OLE_SaveAsFile( oWord, ( cQPathTrm+AllTrim(M->QDP_NUMSEQ)+".DOC" ), cMvSave, cMvSave, .f., oleWdFormatDocument )
			cDocBase:= AllTrim(M->QDP_NUMSEQ)+".DOC"
			M->QDP_ARQDOC := cDocBase
		Else
			OLE_SaveAsFile( oWord, ( cQPathTrm+AllTrim(M->QDP_NUMSEQ)+".CEL" ), cMvSave, cMvSave, .f., oleWdFormatDocument )
			cDocBase:= AllTrim(M->QDP_NUMSEQ)+".CEL"
			M->QDP_ARQDOC := cDocBase
		Endif
	Else
		OLE_SaveAsFile( oWord, ( cQPathTrm+AllTrim(M->QDP_NUMSEQ)+".CEL" ), cMvSave, cMvSave, .f., oleWdFormatDocument )
		cDocBase:= AllTrim(M->QDP_NUMSEQ)+".CEL"
		M->QDP_ARQDOC := cDocBase
	EndIF
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052Anexo ³ Autor ³ Eduardo de Souza           ³ Data ³ 04/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Anexa Documento                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052Anexo(ExpN1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpC1 - Numero da Opcao no Browse                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Anexo(nOpc)

Local oDlg, oBtn1, oBtn2, oBtn3
Local cFile		:= ""
Local cFileTmp 	:= ""
Local nOpc1 	:= 0
Local nTrm     	:= 0
Local aQPath   	:= QDOPATH()
Local cQPath   	:= aQPath[1]
Local cQPathTrm	:= aQPath[3]

If Empty(cDocBase)
	cFile := Trim(cGetFile(PADR(OemToAnsi(STR0065),27)+"|*.DOC|"+;		// "Documentos Anexos(*.Doc)"
	PADR(OemToAnsi(STR0066),27)+"|*.TXT|"+;    // "Arquivos Texto(*.Txt)"
	PADR(OemToAnsi(STR0067),27)+"|*.*|" ,;     // "Todos Arquivos(*.*)"
	OemToAnsi(STR0068),0,,.T.,49))			// "Selecione Diretorio e Arquivo"
	
	M->QDP_ARQDOC := AllTrim(cFile)
	
	If !Empty(cFile)
		
		If AT(":",cFile) > 0
			__CopyFile(cFile,cQPathTrm + Qd052Arquivo())
			If !File(cQPathTrm + Qd052Arquivo())
				Help(" ",1,"QDNCOPIOU") // "Nao foi possivel copiar o Documento  Anexo a esta Solicitacao."
				Return
			Endif
		Else
			If !CpyS2T(cFile,cQPathTrm,.T.)
				Help(" ",1,"QDNCOPIOU") //"Nao foi possivel copiar o Documento  Anexo a esta Solicitacao."
				Return
			Endif
			cFileTmp := ""
			For nTrm:= Len(cFile) to 1 STEP -1
				If SubStr(cFile,nTrm,1) == "\"
					Exit
				Endif
				cFileTmp := SubStr(cFile,nTrm,1)+cFileTmp
			Next
			
			__CopyFile(cQPathTrm+cFileTmp,cQPathTrm + Qd052Arquivo())
			If File(cQPathTrm+cFileTmp)
				FErase(cQPathTrm+cFileTmp)
			Endif
		Endif
		
		cDocBase := Qd052Arquivo()
		
		If File(cQPathTrm+cDocBase).And. ;
			MsgYesNo(OemToAnsi(STR0064),OemToAnsi(STR0019))	     	//"Deseja Visualizar o Documento Agora?" ### "Aten‡ao"
			FSOLOPENDOC(cDocBase)
		Endif
	Endif
Else
	DEFINE MSDIALOG oDlg FROM 221,051 TO 320,420 TITLE OemToAnsi(STR0019) PIXEL	// "Aten‡ao"
	@ 000, 000 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL
	@ 006, 050 SAY  OemToAnsi(STR0062) OF oDlg PIXEL	// "Consta um Documento anexo a Esta Solicitacao."
	@ 013, 050 SAY  OemToAnsi(STR0063) OF oDlg PIXEL	// "Deseja Visualiza-lo ou Exclui-lo ?"
	
	DEFINE SBUTTON oBtn1 FROM 030, 090 TYPE 15  ENABLE  OF oDlg ACTION ( nOpc1 := 1, oDlg:End() )
	DEFINE SBUTTON oBtn2 FROM 030, 120 TYPE 3 OF oDlg ACTION ( nOpc1 := 2, oDlg:End() )
	If nOpc == 2 .Or. nOpc == 5 .Or. nOpc == 6
		oBtn2:Disable()
	Else
		oBtn2:Enable()
	EndIf
	DEFINE SBUTTON oBtn3 FROM 030, 150 TYPE 2   ENABLE  OF oDlg ACTION ( nOpc1 := 3, oDlg:End() )
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpc1 == 1		// Visualizar
		QdoCamCel(cQPath, @cQPathTrm, AllTrim(cDocBase))
		If !File(cQPathTrm+AllTrim(cDocBase))
			Help(" ",1,"QDNCOPIOU") //"Nao foi possivel copiar o Documento  Anexo a esta Solicitacao."
			Return
		Endif
		
		If File(cQPathTrm+cDocBase)
			FSOLOPENDOC(cDocBase,cQPathTrm)
		Endif
		
	ElseIf nOpc1 == 2	// Excluir
		cDocBase := Space(Len(M->QDP_DTOBAS))
	Endif
Endif
  
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FSOLOPENDOC³ Autor ³ Eduardo de Souza     				³ Data ³ 05/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para Visualizar o Documento              				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSOLOPENDOC(ExpC1)                                         				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do Arquivo anexo                              				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA052                                                    				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FSOLOPENDOC(cFile,cQPathTrm)

Local cQPathTxt := GetPvProfString( GetEnvServer(), "StartPath", "ERROR", GetADV97() )
Local cRootPath  := GetPvProfString( GetEnvServer(), "RootPath", "ERROR", GetADV97() )

cQPathTxt += IIF( RIGHT(cQPathTxt,1) != "\", "\", "" )
cRootPath := IIF( RIGHT(cRootPath,1) == "\",SubStr(cRootPath,1,Len(cRootPath)-1), cRootPath)

MsgRun( OemToAnsi( STR0082 ), OemToAnsi( STR0017 ), {|| QSOL52ANEXO(cFile,cQPathTrm)}) //"Executando Abertura do Anexo" ### "Aguarde..."

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QSOL52ANEXO³ Autor ³ Eduardo de Souza               ³ Data ³ 05/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para visualizar arquivo anexo           			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qsol52ANEXO(ExpC1)                                          		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do arquivo a ser aberto                       				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA052                                                    				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QSOL52ANEXO(cFile,cQPathTrm)

Local aQPath      := QDOPATH()
Local cDir        := ""
Local cDocBase    := ""
Local cDrive      := ""
Local cEditor     := "TMsOleWord97"
Local cMvSave     := IIf( GetMV("MV_QSAVPSW",.F.,"1") == "1","CELEWIN400","" ) // "Verifica se insere senha ou nao
Local cParam      := ""
Local lRemotp     := GetRemoteType() == 2 //Checa se o Remote e Linux 

DEFAULT cQPathTrm := aQPath[3]

IF lRemotp
	cFile:=Lower(cFile)
Endif	               

cDocBase := cQPathTrm + AllTrim(cFile)

If Empty(cFile) .Or. !File(cDocBase)
	Return Nil
Endif

If Type("cChkWord") = "U" .OR. cChkWord == "0"
	cChkWord:= Qd052Word()
EndIf

If (".CEL" $ cDocBase .Or. ".DOC" $ cDocBase .Or. ".SOL" $ cDocBase) .And. cChkWord == "1" // Existe Word

	If Type("oWord") <> "U"
		If !Empty(oWord) .And. oWord <> "-1"
			OLE_CloseFile( oWord )
			OLE_CloseLink( oWord )
		EndIf
	Endif

	oWord := OLE_CreateLink( cEditor )
	OLE_SetProperty( oWord, oleWdVisible,   .f. )
	OLE_SetProperty( oWord, oleWdPrintBack, .t. )
	OLE_SetProperty( oWord, oleWdLeft,   000 )
	OLE_SetProperty( oWord, oleWdTop,    090 )
	OLE_SetProperty( oWord, oleWdWidth,  480 )
	OLE_SetProperty( oWord, oleWdHeight, 250 )
	OLE_OpenFile( oWord, cDocBase, .F., cMvSave, cMvSave )
	OLE_SetProperty( oWord, oleWdVisible, .t. )
Else
	SplitPath(cDocBase, @cDrive, @cDir )
	cDir := Alltrim(cDrive) + Alltrim(cDir)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a chamada do aplicativo associado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRemotp                   
		WinExec(QA_EXTQLX(cDocBase)+" "+STUFF(cDocBase,AT(cDrive,cDocBase),Len(cDrive),""))
	Else
		ShellExecute("open",cDocBase,cParam,cDir, 1 )	
	Endif
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052DlgSol³ Autor ³ Eduardo de Souza           ³ Data ³ 06/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Tela para escolha do tipo de solicitacao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052DlgSol(ExpN1)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros   ³ ExpN1 = Opcao do Radio "1 - Docto Novo"  - "2 - Docto Existente"  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052DlgSol(nRad01)

Local oDlgSol
Local oBtn01
Local oBtn02
Local lFecha := .f.
Local lRet   := .f.
Local oRad01                                  // Objeto de Radio Button

DEFINE MSDIALOG oDlgSol FROM 0,0 TO 100,295 TITLE OemToAnsi( STR0003 ) OF oMainWnd PIXEL // "Solicita‡”es"

@ 003, 005 TO 045,100 LABEL OemToAnsi( STR0006 ) OF oDlgSol PIXEL // " Tipo "

@ 010, 013 RADIO oRad01 VAR nRad01 ITEMS OemToAnsi( STR0007 ),OemToAnsi( STR0008 ); // "Novos Documentos" ### "Documentos Existentes"
				3D SIZE 080,015 WHEN nRad01 == 1 OF oDlgSol PIXEL

DEFINE SBUTTON oBtn01 FROM 015, 112 TYPE 1 ENABLE OF oDlgSol;
			ACTION  ( lFecha:=.t.,lRet:= .T., oDlgSol:End() )

DEFINE SBUTTON oBtn02 FROM 030, 112 TYPE 2 ENABLE OF oDlgSol;
			ACTION  ( lFecha:=.t.,lRet:= .f.,oDlgSol:End() )

ACTIVATE MSDIALOG oDlgSol VALID lFecha CENTERED

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052Word  ³ Autor ³ Eduardo de Souza           ³ Data ³ 06/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Verifica se usuario possui Word                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDOA052()                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Word()

Local oWord
Local cEditor:= "TMsOleWord97"
Local cRet   := "0"

CursorWait()              

IF !QDOChkRmt() //Checa se o Remote e Linux   
	oWord := OLE_CreateLink( cEditor )
	If oWord <> "-1"
		cRet:= "1" // Existe Word
	Else
		cRet:= "2" // Nao existe Word
	EndIf
	OLE_CloseLink( oWord )	
Endif	                           

CursorArrow()
Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ Qd052aQDP  ³ Autor ³ Eduardo de Souza           ³ Data ³ 10/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Carrega Array de Solicitacoes                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ Qd052aQDP(ExpA1)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros   ³ ExpA1 - Array contendo as solicitacoes referente ao Docto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function	Qd052aQDP(aQDP)

Local nCnt:= 1

aQDP:= {}
DbSelectArea("QDP")
DbSetOrder(1)
If DbSeek(xFilial("QDP")+cDocOrigem+cRevisao)
	While !Eof() .And. xFilial("QDP")+cDocOrigem+cRevisao == QDP->QDP_FILIAL+QDP->QDP_DTOORI+QDP->QDP_RV
		If QDP->QDP_PENDEN == "P"
			Aadd( aQDP, { QDP->QDP_SITSOL, QDP->QDP_FILIAL, QDP->QDP_DTOORI, QDP->QDP_RV, QDP->QDP_NUMSEQ, QDP->QDP_CHAVE,;
			QDP->QDP_DESSOL, QDP->QDP_MAT, DtoC( QDP->QDP_DTGERA ),QDP->QDP_FILMAT ,QDP->QDP_DEPTO, QDP->QDP_DTOBAS } )
			nCnt++
		EndIf
		QDP->(DbSkip())
	EndDo
EndIf

DbSetOrder(3)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052Status³ Autor ³ Eduardo de Souza           ³ Data ³ 11/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Status da Solicitacao                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052Status(ExpA1,ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros   ³ ExpA1 - Array contendo as solicitacoes referente ao Docto         ³±±
±±³             ³ ExpN1 - Opcao do Combo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Status( aQDP, nAt )

If aQDP[nAt][1] == "E"
	aQDP[nAt][1]:= "A"
ElseIf aQDP[nAt][1] == "A"
	aQDP[nAt][1]:= "R"
ElseIf aQDP[nAt][1] == "R"
	aQDP[nAt][1]:= "E"
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD052AtuCpo³ Autor ³ Eduardo de Souza           ³ Data ³ 11/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Atuliza campos comforme array                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD052AtuCpo(ExpA1,ExpN1,ExpC1,ExpC2,ExpC3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros   ³ ExpA1 - Array contendo as solicitacoes referente ao Docto         ³±±
±±³             ³ ExpN1 - Opcao do Combo                                            ³±±
±±³             ³ ExpC1 - Razao da Solicitacao                                      ³±±
±±³             ³ ExpC2 - Usuario Solicitante                                       ³±±
±±³             ³ ExpC3 - Depto do Usuario Solicitante                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA052.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052AtuCpo( aQDP, nAt, cRazao, cUsrOrig, cDepto )

Local cEspecie:= Left( M->QDP_TPSOL + Space( 8 ), 8 )
Local nTamLin := 70
Local cFilDep := xFilial("QAD")

cDocBase:= aQDP[nAt][12]
cRazao  := QA_RecTxt( aQDP[nAt][6],cEspecie,1,nTamLin,"QA2",@axTextos )
cUsrOrig:= AllTrim(aQDP[nAt][8])+" - "+QA_NUSR(aQDP[nAt][10],aQDP[nAt][8])

If FWModeAccess("QA2") == "E" //!Empty(xFilial("QAD"))
	cFilDep:= AllTrim(aQDP[nAt][10])
EndIf
cDepto:= AllTrim(aQDP[nAt][11])+" - "+QA_NDEPT(aQDP[nAt][11],.T.,cFilDep)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD052Motiv ³ Autor ³Eduardo de Souza              ³ Data ³ 11/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Motivo da Reprovacao                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD052Motiv(ExpN1,ExpA1,ExpN2)            								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Opcao do Browse                                             ³±±
±±³           ³ ExpA1 - Array contento as Solicitacoes referente ao Docto           ³±±
±±³           ³ ExpN2 - Opcao do ComboBox                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA052.PRW                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Motiv( nOpc, aQDP, nAt, nRad01 )

Local cCabec   := ""
Local cTitulo  := ""
Local cEspecie := ""
Local cCod     := ""
Local cChave   := ""
Local nTamLin  := TamSX3( "QA2_TEXTO" )[1]
Local lEdit    := .T.
Local axTextos := {}
Local lRet     := .t.

cEspecie := "QD052MOT"
cTitulo  := OemtoAnsi( STR0056 ) // "Mot. Reprovacao"
cCabec   := ""

If nOpc == 2 .Or. nOpc == 5
	lEdit:= .F.
EndIf

If nOpc == 2 .Or. nOpc == 5 .Or. nRad01 == 1
	cCod  := M->QDP_NUMSEQ
	cChave:= M->QDP_CHAVE
Else
	cCod:= aQDP[nAt][5]
	cChave := aQDP[nAt][6]
EndIf

If QA_TEXTO( cChave, cEspecie, nTamlin, cTitulo, cCod, @axtextos, 1, cCabec, lEdit )
	QA_GrvTxt( cChave, cEspecie, 1, @axtextos )
EndIf

DbselectArea( "QDP" )
DbSetOrder( 3 )

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD052APQA2 ³ Autor ³Eduardo de Souza              ³ Data ³ 12/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Apaga Motivo da Reprovacao                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD052APQA2(ExpN1, ExpA1)    													   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Opcao do Browse                                             ³±±
±±³           ³ ExpA1 - Array com as Solicitacoes referente ao Docto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA052.PRW                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052APQA2(aQDP, nRad01)

Local nCnt:= 0

If nRad01 == 1
	QA_DelTxt( M->QDP_CHAVE, "QD052MOT" )
ElseIf nRad01 == 2
	For nCnt:= 1 to Len(aQDP)
		QA_DelTxt( aQDP[nCnt][6], "QD052MOT" )
	Next nCnt
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³Qd052FiltQDH³ Autor ³Eduardo de Souza              ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Filtra arquivo QDH no ListBox                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ Qd052FiltQDH( )           													   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA052.PRW                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qd052FiltQDH()

Local cFiltro:= " "

DbSelectArea("QDH")
DbSetOrder(1)

cFiltro := 'QDH_CANCEL <> "S" .And. QDH_OBSOL <> "S" .And. QDH_STATUS == "L  "'
If FWModeAccess("QDH") == "E" //!Empty(xFilial("QDH"))
	cFiltro += ' .And. QDH->QDH_FILIAL = "'+xFilial("QDH")+'"'
Endif
Set Filter to &(cFiltro)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³Qd052ViewDoc³ Autor ³Eduardo de Souza              ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Visualiza Docto selecionado no listbox                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ Qd052ViewDoc(ExpC1,cExpC2)         										   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Codigo Docto                                                ³±±
±±³           ³ ExpC2 - Revisao Docto                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA052.PRW                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qd052ViewDoc(cDocto, cRv)

Local nI		   := 0

DbSelectArea("QDH")
DbSetOrder(1)
If QDH->(DbSeek( xFilial("QDH")+cDocto+cRv))
	For nI := 1 To FCount()
		M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
	Next nI	
	Inclui:= .F.
	QdoDocCon()
EndIf
DbSelectArea("QDH")
DbSetOrder(1)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD052Legen ³ Autor ³Eduardo de Souza              ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cria uma janela contendo a legenda da mBrowse da Solicitacao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD052Legen( )              													   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA052.PRW                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Legen()
Local aLegenda := {}

Aadd( aLegenda, {'BR_AMARELO', OemtoAnsi(STR0080)} )	// "Em Analise"
Aadd( aLegenda, {'ENABLE'    , OemtoAnsi(STR0078)} ) 	// "Aprovado"
Aadd( aLegenda, {'DISABLE'   , OemtoAnsi(STR0079)} )	// "Reprovado"

BrwLegenda(cCadastro,OemtoAnsi(STR0081),aLegenda) 	// "Legenda"

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD052APQA4 ³ Autor ³Eduardo de Souza              ³ Data ³ 17/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Apaga Numero Sequencial da Solicitacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD052APQA4(ExpN1, ExpA1)    													   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Opcao do Browse                                             ³±±
±±³           ³ ExpA1 - Array com as Solicitacoes referente ao Docto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA052.PRW                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052APQA4(nRad01)

Local cAlias
Local nTam
Local nValor
Local cChave
Local cValor

cAlias := Alias()

If nRad01 == 1
	cChave := xFilial( "QA4" ) + "SI_QDP"
ElseIf nRad01 == 2
	cChave := xFilial( "QA4" ) + "SA_QDP"
Endif

DbSelectArea("QA4")
DbSetOrder(1)

If DbSeek( cChave )
	
	cValor := Space( 05 )
	nValor := Val( Alltrim( QA4_CHAVE ) )
	nTam   := Len( Alltrim( QA4_CHAVE ) )
	
	If nValor > 0 .and. Val(SUBS(cNumSol,3)) == Val( Alltrim( QA4_CHAVE ) )
		nValor := nValor - 1
	Endif
	
	DbSelectArea("QDP")
	DbSetOrder( 3 )
	
	cValor := "00000"
	If nRad01 == 1
		cChave := xFilial( "QDP" ) + "SI" + SubStr( cValor, 1, ( Len( cValor ) - nTam ) ) + Alltrim( Str( nValor ) )
	ElseIf nRad01 == 2
		cChave := xFilial( "QDP" ) + "SA" + SubStr( cValor, 1, ( Len( cValor ) - nTam ) ) + Alltrim( Str( nValor ) )
	Endif
	
	cValor := Space( 05 )
	Reclock("QA4")
	QA4->QA4_CHAVE := SubStr( cValor, 1, ( Len( cValor ) - nTam ) ) + Alltrim( Str( nValor ) )
	MsUnlock()
Endif

DbSelectArea("QDP")
DbSetOrder( 3 )

DbSelectArea( cAlias )

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD052Sele ³ Autor ³Eduardo de Souza                 ³ Data ³ 19/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Filtra os Lancamtos Pendentes/Baixados da Solicitacao         			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD052Sele()                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA052                                                       			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Sele()

dbSelectArea("QDP")

lFunSol := !lFunSol

If !lFunSol
	DbSeek(xFilial("QDP")) 
	cFilter:=''	
Else
	MsgRun( OemToAnsi( STR0016 ), OemToAnsi( STR0017 ), { || QD052FIL() } ) //"Selecionando Dados" ### "Aguarde..."
	QD052PendSol(.T.) // Verifica se Existe solicitacao em Analise
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD052FIL   ³ Autor ³Eduardo de Souza        			³ Data ³ 19/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Filtra os Lactos Pendentes                                    			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD052FIL()                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA052                                                       			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052FIL()
Local cFiltro := "QDP_PENDEN = 'P'"
cfilter:=cFiltro
dbSelectArea("QDP")
Set Filter to &(cFiltro)
QDP->(DbGotop())

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD052PendSol³ Autor ³Eduardo de Souza        			³ Data ³ 19/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe Lancamentos de Solicitacao em analise      			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QD052PendSol()                                                			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA052                                                       			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052PendSol(lHelp)

QDP->(DbSeek(xFilial()))
If QDP->(Eof())
	If cFilPend == "N"
		If lHelp
			Help(" ", 1,"QD052NPEND") //"Nao existe Solicitacao de Alteracao em Analise"
		EndIf

		lFunSol:= .F.
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD052Arquivo³ Autor ³Wagner Mobile Costa   		  ³ Data ³ 22/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Retorna o nome do arquivo da solicitacao                     			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Qd052Arquivo()                                               			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA052                                                      			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD052Arquivo()

Return AllTrim(M->QDP_NUMSEQ)+ "." + Subs(M->QDP_ARQDOC, Rat(".",	M->QDP_ARQDOC) + 1,;
	   															Len(M->QDP_ARQDOC))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD052Ela  ºAutor  ³Telso Carneiro      º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Usuario conforme permissao no configurador para     º±±
±±º          ³ baixa de Solicitacoes                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SXB (QAAELB)                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QD052Ela(cUser,cFilUsr,cCodUsr)      
Local nI	:= 1
Local lRet	:= .F.
Local aUsr	:= {}
Local aGrp	:= {}

IF cUser==NIL .AND. cFilUsr <> NIL .AND. cCodUsr <> NIL
	cUser:=POSICIONE("QAA",1,cFilUsr+cCodUsr,"QAA_LOGIN")	
Endif

PswUpper(.T.)
PswOrder(2)
If PswSeek(cUser,.T.)
	aUsr := PswRet()
	If !aUsr[2][11] // Priorizar configuracao do grupo
		lRet := SubStr(aUsr[2][5],92,1) == "S" .Or. aUsr[1,1] == '000000'
	EndIf
	If !Empty(aUsr[1][10]) // Grupos do usuario
		PswOrder(1)  
		While nI <= Len(aUsr[1][10]) .And. !lRet 
			aGrp:=strtokarr(FWSFGroup(aUsr[1][10][nI],'PROTHEUSACCESS','GR__ACESSO',.T.),";")
			If (lRet := iif(aGrp[92] = 'T',.T.,.F.) ) == .t.
				exit
			EndIf
			nI++
		EndDo
	EndIf
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD052VEl  ºAutor  ³Telso Carneiro      º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Usuario conforme permissao no configurador para     º±±
±±º          ³ baixa de Solicitacoes                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SXB (QAAELB)                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QD052VEl(cFilUsr,cCodUsr)
Local cRet:= ""   //Local aRet:={}
Local cUSer:=""
Local lRet:=.F.

IF FWModeAccess("QDP")=="E" .OR. !Empty(cCodUsr) //!Empty(cFilUsr)
	QAA->(DbSetOrder(1))
	IF QAA->(DBSeek(cFilUsr+cCodUsr))
		cUser:= QAA->QAA_LOGIN
		cRet := QAA->QAA_APELID
		lRet := QD052Ela(cUser)
		IF !lRet
			HELP(" ",1,"SEMPERM")
			cRet:=""
		Endif
	Else
		Help(" ",1,"QD050FNE")	// "Funcionario/Usuario nao Existe"
	Endif
Endif
	
Return(cRet)
