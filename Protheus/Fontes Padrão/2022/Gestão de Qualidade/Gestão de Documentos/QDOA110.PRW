#INCLUDE "TOTVS.CH"
#INCLUDE "QDOA110.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QDOA110   ³ Autor ³ Newton R. Ghiraldelli   ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Distribuicao de Documentos                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QDOA110( nReg )                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³nReg - Numero do Registro                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SIGAQDO - Generico                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³ Programador ³Alteracao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³27/02/02³ META ³ Eduardo S.  ³ Alterado para gerar aviso de Cancelamento ³±±
±±³        ³      ³             ³ de Documento.                             ³±±
±±³28/02/02³------³ Eduardo S.  ³ Acertado para salvar o Docto HTML no dire-³±±
±±³        ³      ³             ³ torio especificado no param. "MV_QPATHWH".³±±
±±³24/04/02³ META ³ Eduardo S.  ³ Alterado para gerar pendencia de Devolucao³±±
±±³        ³      ³             ³ de Revisao Anterior para Dist. Copia Papel³±±
±±³08/07/02³ META ³ Eduardo S.  ³ Alterado para apresentar a tela de impres-³±±
±±³        ³      ³             ³ sao do protocolo somente quando existirem ³±±
±±³        ³      ³             ³ dados para impressao.                     ³±±
±±³18/07/02³------³ Eduardo S.  ³ Alterado para baixar o aviso "inclusao do ³±±
±±³        ³      ³             ³ questionario" da revisao anterior na dis- ³±±
±±³        ³      ³             ³ tribuicao da nova revisao.                ³±±
±±³22/07/02³------³ Eduardo S.  ³ Alterado para gravar documento html confor³±±
±±³        ³      ³             ³ me definido no parametro "MV_QDHTML".     ³±±
±±³19/09/02³ ---- ³ Eduardo S.  ³ Acerto para nao permitir a distribuicao   ³±±
±±³        ³      ³             ³ com a qtde de dias negativo.              ³±±
±±³03/10/02³060400³ Eduardo S.  ³ Acerto para prever departamento com ate 20³±±
±±³        ³      ³             ³ caracteres na inclusao do destinatario.   ³±±
±±³23/10/02³060642³ Eduardo S.  ³ Alterado para posicionar corretamente na  ³±±
±±³        ³      ³             ³ ultima revisao do docto.                  ³±±
±±³06/01/03³ ---- ³ Eduardo S.  ³ Acerto ao carregar dest. apos ultima pend.³±±
±±³08/01/03³ ---- ³ Eduardo S.  ³ Alterado para permitir pesquisar usuarios ³±±
±±³        ³      ³             ³ de outras filiais na inclusao de destinat.³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOA110(nReg)
                                                       	
Local aData    := {}
Local nT	      := 0
Local aQPath   := QDOPATH()
Local cQPathTrm:= aQPath[3]
Local cTextoD  := aQPath[4]
Local aUsrMat  := QA_USUARIO()
Local lApelido := aUsrMat[1]
Local cMsgIna  :=""
Local oDi 	   := LoaDbitmap( GetResources(), "BR_AZUL" )
Local oCa      := LoaDbitmap( GetResources(), "BR_PRETO" )

Private oQDH
Private oQDG
Private oGet
Private oWord
Private bQDGLine	
Private bQDHLine	
Private nItem     := 2
Private nOpca     := 0
Private cCadastro := ""
Private cTpCopia  := OemToAnsi( STR0001 ) // "Copia Controlada"
Private cNomFilial:= Space( 40 )
Private cFilApSol := Space(FWSizeFilial())//Space( 02 )
Private cCodApSol := Space(TamSx3("QAA_MAT")[1])
Private cFilApDes := Space(FWSizeFilial())//Space( 02 )
Private cCodApDes := Space(TamSx3("QAA_MAT")[1])
Private cNomRece  := " "
Private Inclui    := .f.
Private lAltDoc   := .t.
Private lGeraRev  := .f.
Private lContinua := .f.
Private cDtEmiss  := dDatabase
Private aQDH		:= {}
Private aQDG		:= {}
Private aQDGRegs	:= {}
Private hOK       := LoadBitmap( GetResources(), "LBTIK" )
Private hNo       := LoadBitmap( GetResources(), "LBNO" )
Private cFilMat   := cFilAnt
Private cFilDep   := xFilial("QAD")
Private nQaConPad := 4
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private aInativo := {}
Private lTrat:= GetMv("MV_QDOQDG",.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario atual estacadastrado com apelido no cadastro de responsaveis para poder acessar a funcao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lApelido
		Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual ao apelido do configurador."
		Return .F.
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o usuario atual tem alguma pendencia tipo distribuicao para confirmar se o usuario esta cadastrado como distribuidor de documentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lContinua:= .F.
QD1->(DbSetOrder(3))
	If QD1->(DbSeek(cMatFil+cMatCod+"P"))
		While QD1->(!Eof()) .And. QD1->QD1_FILMAT+QD1->QD1_MAT+QD1->QD1_PENDEN == cMatFil+cMatCod+"P"
			If QD1->QD1_TPPEND == "I  "
				lContinua:= .T.
				Exit
			EndIf
			QD1->(DbSkip())
		EndDo
	EndIf

	If !lContinua
		Help(" ",1,"QD_USRNDST")
		Return .T.
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a selecao dos documentos a serem distribuidos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun(OemToAnsi(STR0002),OemToAnsi(STR0003),{|| QD110LeQDH()}) // "Selecionando Distribui‡”es" ### "Aguarde..."

bQDHLine := { || {	IF(Posicione("QDH",1,aQDH[oQDH:nAt,6]+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4],"QDH_CANCEL") == "S",oCa,oDi),;													
	If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 2 ], CriaVar( "QDH_DOCTP" ) ),;
			If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 3 ], CriaVar( "QDH_DOCTO" ) ),;
				If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 4 ], CriaVar( "QDH_RV" ) ),;
					If( Len( aQDH ) > 0, aQDH[ oQDH:nAt, 5 ], CriaVar( "QDH_TITULO" ) ) } }

					If Len(aQDH) > 0
						QD110MsDlg(nReg)
					Else
						IF Len(aInativo) > 0
							cMsgIna:=""
							For nT:=1 to Len(aInativo)
								cMsgIna+=STR0060+aInativo[nT,1]+STR0061+aInativo[nT,2]+"-"+QA_NUSR(aInativo[nT,1],aInativo[nT,2])+CHR(13) //"Filial: "###" Matricula: "
							Next
							MsgStop(STR0062+CHR(13)+cMsgIna) 		 //"Existem Usuarios Inativos, Utilize a Transferencia no cadastro de Usuarios "
						Endif
						Help(" ", 1,"QDNEDISTR")
						Return .T.
					EndIf

aData:= DIRECTORY(cQPathTrm+"*.CEL")
					For nT:= 1 to Len(aData)
						If File(cQPathTrm+AllTrim(aData[nT,1]))
		FErase(cQPathTrm+AllTrim(aData[nT,1]))
						EndIf
					Next nT

aData  := DIRECTORY(cQPathTrm+"*.DOT")
					For nT:= 1 to Len(aData)
						If File(cQPathTrm+AllTrim(aData[nT,1]))
		FErase(cQPathTrm+AllTrim(aData[nT,1]))
						EndIf
					Next nT

					If File(cQPathTrm+cTextoD)
	FErase(cQPathTrm+cTextoD)
					EndIf

QD1->( dbClearFilter() )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD110MsDlg³ Autor ³ Newton R. Ghiraldelli   ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mostra Dialogo de Distribuicao de Documentos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD110MSDlg(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 - Posicao do Registro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QDOA110                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110MsDlg(nReg)

local aCoors   :={oMainWnd:nTop, oMainWnd:nLeft, oMainWnd:nBottom, oMainWnd:nRight}
Local aInfo    :={aCoors[ 1 ], aCoors[ 2 ], aCoors[ 3 ], aCoors[ 4 ], 4, 4}
Local aObjects :={{ 100, 100, .T., .T. }}
Local aPosObj  := MsObjSize( aInfo, aObjects )
Local cQDG     := ""
Local cQDH     := ""
Local nWebApp  := 0
Local oBtn1
Local oBtn7
Local oDlgM

Default nReg:= 0

If GetRemoteType() == 5
	nWebApp := 27
EndIF

if oApp:lMDI
	DEFINE MSDIALOG oDlgM TITLE OemToAnsi(STR0004) FROM aCoors[1]+35,aCoors[2] TO aCoors[3]-10,aCoors[4]-30 PIXEL
	oDlgM:lMaximized := .T.
else
	DEFINE MSDIALOG oDlgM TITLE OemToAnsi(STR0004) FROM aCoors[1],aCoors[2] TO aCoors[3]-65,aCoors[4]-70 PIXEL
	oDlgM:lMaximized := .T.
endif

//Painel1
oPanel1:=  TPanel():New(0,0,'',oDlgM,, .T., .T.,, ,30,10,.T.,.T. )
oPanel1:Align:= CONTROL_ALIGN_TOP

@ 0.8,7.00 Say OemToAnsi(STR0005) SIZE 100,300 OF oPanel1 COLOR CLR_HBLUE PIXEL // " Documentos "

//Painel2 
oPanel2:=  TPanel():New(0,0,'',oDlgM,, .T., .T.,, ,100,130-nWebApp,.T.,.T. )
oPanel2:Align:= CONTROL_ALIGN_TOP

@ 2.0,2.0 LISTBOX	oQDH VAR	cQDH ;
				FIELDS;
				HEADER " ",	TitSX3("QDH_CODTP")[1],;
							TitSX3("QDH_DOCTO")[1],;
							TitSX3("QDH_RV")[1],;
							TitSX3("QDH_TITULO")[1] ;
				COLSIZES 50,28,50,50,100 ;							
				SIZE 100,(1917/3) OF oPanel2 PIXEL ; 
				WHEN Len( aQDH ) > 0 ;
				ON   CHANGE(aQDG := If(Len(aQDH) > 0 .And. Len(aQDGRegs) > 0,aQDGRegs[oQDH:nAt],{}),oQDG:SetArray(aQDG),oQDG:nAt:= 1,oQDG:bLine:= bQDGLine,oQDG:Refresh())
				
oQDH:SetArray( aQDH )
oQDH:bLine := bQDHLine
	If nReg > 0
	QDH->(dbGoTo(nReg))
		If (nPosQDH := aScan(aQDH,{|X| X[6] + X[3] + X[4] == QDH->QDH_FILIAL + QDH->QDH_DOCTO + QDH->QDH_RV })) > 0
		oQDH:nAt:=nPosQDH
		EndIf
	EndIf
oQDH:Align:= CONTROL_ALIGN_ALLCLIENT

//Painel3 
oPanel3:=  TPanel():New(0,0,'',oDlgM,, .T., .T.,,,40,15,.T.,.T. )
oPanel3:Align:= CONTROL_ALIGN_TOP

DEFINE SBUTTON	oBtn1 FROM 002,003 TYPE 1 ENABLE OF oPanel3 WHEN Len(aQDH) > 0 ;
			ACTION If( QD110VeQDH(),( If( QD110CfDst(), .t.,), If( Len( aQDH ) == 0, oDlgM:End(), .t. ) ) , .f. )			

oBtn1:cToolTip := OemToAnsi(STR0006) // "Distribui Documentos"
IIf(SetMDIChild(),oBtn1:cCaption := OemToAnsi(STR0055),) // "Distribui"

DEFINE SBUTTON	oBtn7 FROM 002,030 TYPE	11 ENABLE OF oPanel3 ACTION QD110Legen() 
oBtn7:cToolTip := OemToAnsi(STR0063) //"Legenda"
IIf(SetMDIChild(),oBtn7:cCaption := OemToAnsi(STR0063),) //"Legenda"

//Painel4 
oPanel4:=  TPanel():New(0,0,'',oDlgM,, .T., .T.,,,30,10,.T.,.T. )
oPanel4:Align:= CONTROL_ALIGN_TOP

@ 0.8,7.00 Say SPACE(2)+OemToAnsi(STR0007) SIZE 100,300 OF oPanel4 COLOR CLR_HBLUE PIXEL // " Destinatarios "

oPanel5:=  TPanel():New(0,0,'',oDlgM,, .T., .T.,, ,100,90-nWebApp,.T.,.T. )
oPanel5:Align:= CONTROL_ALIGN_TOP

@ 150,000 LISTBOX	oQDG VAR cQDG;
				FIELDS;
				HEADER	TiTSX3("QDG_DEPTO")[1],;
							TiTSX3("QDG_MAT")[1],;
							TiTSX3("QAA_NOME")[1],;
							TiTSX3("QDG_CODMAN")[1],;
							TiTSX3("QDG_TPRCBT")[1],;
							TiTSX3("QDG_NCOP")[1] ;
				SIZE 500,500 OF oPanel5	PIXEL	WHEN Len( aQDGRegs ) > 0

oQDG:SetArray( aQDG )
oQDG:bLine := bQDGLine
oQDG:Align := CONTROL_ALIGN_ALLCLIENT

oPanel6:=  TPanel():New(0,0,'',oDlgM,, .T., .T.,, ,20,20,.T.,.T. )
oPanel6:Align:= CONTROL_ALIGN_TOP

DEFINE SBUTTON	oBtn6 FROM 003,003 TYPE 15 ENABLE OF oPanel6 WHEN Len(aQDH) > 0 ;
			ACTION QD110PesqDep(oQDG,aQDGRegs[oQDH:nAt],2)
oBtn6:cToolTip := OemToAnsi(STR0048) // "Pesquisa Depto"
IIf(SetMDIChild(),oBtn6:cCaption := OemToAnsi(STR0056),) // "Pesquisa"

DEFINE SBUTTON	oBtn5 FROM 003,031 TYPE 11 ENABLE OF oPanel6 WHEN Len(aQDH) > 0 ;
			ACTION If(QD110VeQDH(),QD110AlQDG(),.f.)
oBtn5:cToolTip := OemToAnsi(STR0036) // "Altera Destinatário"
IIf(SetMDIChild(),oBtn5:cCaption := OemToAnsi(STR0057),) // "Altera Dest."

DEFINE SBUTTON	oBtn2 FROM 003,059 TYPE 4 ENABLE OF oPanel6 WHEN Len(aQDH) > 0 ;
			ACTION If( QD110VeQDH(),QD110InQDG(), .f. )
oBtn2:cToolTip:= OemToAnsi(STR0008) // "Inclui Destinatário"
IIf(SetMDIChild(),oBtn2:cCaption:= OemToAnsi(STR0058),) // "Inclui Dest"

DEFINE SBUTTON	oBtn3 FROM 003,087 TYPE 3 ENABLE OF oPanel6 WHEN Len(aQDGRegs) > 0 ;
			ACTION If( QD110VeQDH(), QD110ExQDG(), .f. )
oBtn3:cToolTip:= OemToAnsi(STR0009) // "Exclui Destinatário"
IIf(SetMDIChild(),oBtn3:cCaption:= OemToAnsi(STR0059),) // "Exclui Dest"

DEFINE SBUTTON	oBtn4 FROM 003,278 TYPE	2 ENABLE OF oPanel6 ACTION	oDlgM:End() 
oBtn4:cToolTip := OemToAnsi( STR0010 ) // "Cancelar"
oBtn4:Align := CONTROL_ALIGN_RIGHT 

ACTIVATE	MSDIALOG	oDlgM CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110LeQDH  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Monta o array de documentos em status de distribuicao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110LeQDH()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110LeQDH()

Local aReg     := {}
Local aRegs    := {}
Local sStatus  := "I  "
Local lCarrega := .F.   
Local cArea	   := Alias()
Local aStruQDH := {} 
Local cQuery   := ""      
Local nPosCpo  := 0
Local aARea	   := {}

aQDH    := {}
aQDG    := {}
aQDGRegs:= {}       

QDH->(DbSetOrder(3))
QD1->(DbSetOrder(7))              

aARea:=GetArea()
aStruQDH  := QDH->(dbStruct())
cQuery    := "SELECT * "
cQuery    += " FROM "+RetSqlName("QDH")+" QDH "
cQuery    += " WHERE QDH.QDH_OBSOL <> 'S' AND"
cQuery    += " (QDH.QDH_STATUS = 'I  ' OR QDH.QDH_STATUS = 'L  ') "
cQuery    += " AND QDH.D_E_L_E_T_ <> '*'  AND "		

cQuery    += " (EXISTS(SELECT R_E_C_N_O_ FROM " + RetSqlName("QD1") + " QD1 WHERE 	"	
cQuery    += " QD1.QD1_FILIAL = QDH.QDH_FILIAL AND "
cQuery    += " QD1.QD1_DOCTO  = QDH.QDH_DOCTO AND "
cQuery    += " QD1.QD1_RV     = QDH.QDH_RV	  AND "
cQuery    += " QD1.QD1_FILMAT = '"+cMatFil+"' AND "
cQuery    += " QD1.QD1_MAT    = '"+cMatCod+"' AND "				
cQuery    += " QD1.QD1_DEPTO  = '"+cMatDep+"' AND "
cQuery    += " QD1.QD1_TPPEND = 'I  ' AND " 
cQuery    += " QD1.QD1_PENDEN = 'P' AND "                                      
cQuery    += " QD1.D_E_L_E_T_ <> '*')) "

cQuery    += " ORDER BY "+SqlOrder(QDH->(IndexKey()))

cQuery := ChangeQuery(cQuery)		

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBQDH",.F.,.T.)

	For nPosCpo := 1 To Len(aStruQDH)
		If aStruQDH[nPosCpo,2]#"C"
		TcSetField("TRBQDH",aStruQDH[nPosCpo,1],aStruQDH[nPosCpo,2],;
		aStruQDH[nPosCpo,3],aStruQDH[nPosCpo,4])
		EndIf
	Next nPosCpo

TRBQDH->(dbGoTop())

	While TRBQDH->(!Eof())
	aRegs:= QD110LeQDG("TRBQDH")
		If Len(aRegs) > 0
		aReg:= Array(6)
		aReg[1]:= .t.
		aReg[2]:= TRBQDH->QDH_CODTP					
		aReg[3]:= TRBQDH->QDH_DOCTO
		aReg[4]:= TRBQDH->QDH_RV
		aReg[5]:= OemToAnsi( TRBQDH->QDH_TITULO )
		aReg[6]:= TRBQDH->QDH_FILIAL
		AAdd( aQDH, AClone( aReg ) )
		AAdd( aQDGRegs, Aclone( aRegs ))
		EndIF
	TRBQDH->(DbSkip())
	EndDo
TRBQDH->(dbCloseArea())
RestArea(aArea)
lCarrega := .T.

	If Len(aQDH) == 0 .And. !lCarrega
		If FWModeAccess("QDH",3) == "E"
		QDH->(DbGotop())
		Else
		QDH->(DbSeek(xFilial("QDH")+sStatus))
		EndIf

		While QDH->(!Eof())
			If 	(QDH->QDH_STATUS == sStatus .Or. QDH->QDH_STATUS = "L") .And.;
			QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+cMatDep+cMatFil+cMatCod+"I  ")) .And.;
		 	QD1->QD1_PENDEN = "P" .And.;
			(Len(aRegs:= QD110LeQDG("QDH")) > 0)
					If QDH->QDH_OBSOL == "N"
					If Len(aRegs) > 0
					aReg:= Array(6)
					aReg[1]:= .t.
					aReg[2]:= QDH->QDH_CODTP
					aReg[3]:= QDH->QDH_DOCTO
					aReg[4]:= QDH->QDH_RV
					aReg[5]:= OemToAnsi( QDH->QDH_TITULO )
					aReg[6]:= QDH->QDH_FILIAL
			      	AAdd( aQDH, AClone( aReg ) )
			      	AAdd( aQDGRegs, ASort( aRegs,,, { |x, y| x[10]+x[11]+x[2]+x[4]+x[5] < y[10]+y[11]+y[2]+y[4]+y[5]}))
					EndIf
				EndIf
			EndIf
  	 	QDH->(DbSkip())
		EndDo
	EndIf

	IF ExistBlock( "QDOAP28" )  //TAM
	aQDHG:=aClone( ExecBlock( "QDOAP28", .f., .f. ,{ aClone(aQDH), aClone(aQDGRegs) })	)
		IF Len(aQDHG) > 0
		aQDH	:=aQDHG[1]
		aQDGRegs:=aQDHG[2]
		Endif
	Endif

aQDG:= If( Len( aQDGRegs ) > 0, aQDGRegs[ 1 ], aQDG )

bQDGLine:= { || {	If( Len(aQDG) > 0 .And. Len(aQdg) >= oQDG:nAt, aQDG[oQDG:nAt,11], Space( 09 ) ),;
	If( Len(aQDG) > 0 .And. Len(aQdg) >= oQDG:nAt, aQDG[ oQDG:nAt,  3 ], Space( 06 ) ),;
			If( Len(aQDG) > 0 .And. Len(aQdg) >= oQDG:nAt, aQDG[ oQDG:nAt,  5 ], Space( 30 ) ),;
				If( Len(aQDG) > 0 .And. Len(aQdg) >= oQDG:nAt, aQDG[ oQDG:nAt,  4 ], Space( 15 ) ),;
					If( Len(aQDG) > 0 .And. Len(aQdg) >= oQDG:nAt, aQDG[ oQDG:nAt,  7 ], Space( 20 ) ),;
						If( Len(aQDG) > 0 .And. Len(aQdg) >= oQDG:nAt, aQDG[ oQDG:nAt,  8 ], Space( 06 ) ) } }

QDH->(DbSetOrder(1))  
DbSelectArea(cArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110ExQDH  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz a exclusao e acerto dos array apos a baixa de um documento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110ExQDH()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110ExQDH()

	If Len(aQDH) == 0
	Return .F.
	EndIf

ADel(aQDGRegs, oQDH:nAt)
ASize(aQDGRegs,Len(aQDGRegs)-1)
ADel(aQDH, oQDH:nAt)
ASize(aQDH,Len(aQDH)-1)
oQDH:SetArray(aQDH)
oQDH:bLine := bQDHLine
oQDH:nAT:=1
oQDH:Refresh()

	If Len(aQDGRegs) > 0
	aQDG:= AClone(aQDGRegs[oQDH:nAt])
	Else
	aQDG := {{.T.,Space(09),Space(06),Space(15),Space(30),Space(30),Space(12),Space(05),Space(01),Space(02),Space(09),Space(01),Space(01),Space(02),Space(16),Space(03)}}
	EndIf

oQDG:SetArray( aQDG )
oQDG:bLine := bQDGLine
oQDG:nAT:=1
oQDG:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110VeQDH  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz verificacao e acerto do array de documentos antes de baixar a ³±±
±±³           ³ distribuicao.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110VeQDH()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110VeQDH()

Local aQDHCopia:= aClone(aQDH)
Local nC       := 0
Local nDel     := 0

	While .T.
	nDel:= 0
		For nC:= 1 To Len(aQDHCopia)
			If !aQDHCopia[nC,1]
			ADel(aQDHCopia,nC)
			ASize(aQDHCopia,Len(aQDHCopia)-1)
			nDel++
			Exit
			EndIf
		Next nC
		If nC >= Len(aQDHCopia)+nDel .And. Len(aQDHCopia) <> 0
		Return .T.
		EndIf
		If Len(aQDHCopia) == 0
		Return .F.
		EndIf
	EndDo

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110LeQDG  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta o array de destinatarios referentes ao documento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110LeQDG()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110LeQDG(cAliasQDH)
Local aArea      := {}
Local aReg       := {}
Local aRegs      := {}
Local cQuery     := ""
Local lAltQAD    := .F.
Local nIndQDG    := QDG->(IndexOrd())
Local nRegAux    := 0
Local nRegQDG    := QDG->(Recno())
Local oQLTQueryM := QLTQueryManager():New()

aArea:=GetArea()
        
cQuery    := "SELECT QDG.QDG_FILIAL,QDG.QDG_DOCTO, QDG.QDG_RV, "
cQuery    += "       QDG.QDG_TIPO,  QDG.QDG_FILMAT,QDG.QDG_MAT,   QDG.QDG_CODMAN, "
cQuery    += "       QDG.QDG_TPRCBT,QDG.QDG_NCOP,  QDG.QDG_RECEB, QDG.QDG_DEPTO, "				
cQuery    += "       QAA.QAA_FIM,   QAA.QAA_STATUS,QAA.QAA_INICIO,QAA.QAA_NOME, QAA.QAA_TPRCBT, "			
cQuery    += "       QAD.QAD_DESC,  QAD.QAD_FILMAT,QAD.QAD_MAT,   QAD.QAD_FILIAL,"						

cQuery    += "       ( SELECT QDC.QDC_DESC FROM "+RetSqlName("QDC")+" QDC "
cQuery    += "          WHERE QDG.QDG_TIPO = 'P' AND "

cQuery    += oQLTQueryM:MontaQueryComparacaoFiliais("QDC", "QDG", "QDC", "QDG") + " AND "			

cQuery    += " QDC.QDC_CODMAN = QDG.QDG_CODMAN AND QDC.D_E_L_E_T_ <> '*' ) "
cQuery    += " QDC_DESC "		

cQuery    += ",      ( SELECT QDC.QDC_STATUS FROM "+RetSqlName("QDC")+" QDC "
cQuery    += "          WHERE QDG.QDG_TIPO = 'P' AND "

cQuery    += oQLTQueryM:MontaQueryComparacaoFiliais("QDC", "QDG", "QDC", "QDG") + " AND "			

cQuery    += " QDC.QDC_CODMAN = QDG.QDG_CODMAN AND QDC.D_E_L_E_T_ <> '*' ) "
cQuery    += " QDC_STATUS "		

cQuery    += "  FROM "+RetSqlName("QDG")+" QDG,"+ RetSqlName("QAA")+" QAA, "+RetSqlName("QAD")+" QAD"
cQuery    += " WHERE "
cQuery    += "       QDG.QDG_FILIAL = '"+TRBQDH->QDH_FILIAL+"' AND "
cQuery    += "       QDG.QDG_DOCTO  = '"+TRBQDH->QDH_DOCTO+"' AND "
cQuery    += "       QDG.QDG_RV	  = '"+ TRBQDH->QDH_RV +"' AND "      
cQuery    += "       QDG.QDG_SIT <> 'I' AND "
cQuery    += "       QDG.QDG_RECEB = 'S' AND "		
cQuery    += "       QDG.D_E_L_E_T_ <> '*' AND "							

cQuery    += "       QAA.QAA_FILIAL = QDG.QDG_FILMAT AND "
cQuery    += "       QAA.QAA_MAT    = QDG.QDG_MAT AND "		
cQuery    += "       QAA.D_E_L_E_T_ <> '*' AND "			 

cQuery    += oQLTQueryM:MontaQueryComparacaoFiliaisComCamposEspecificos("QAD", "QAD.QAD_FILIAL", "QAA", "QDG.QDG_FILMAT") + " AND "

cQuery     += " QAD.QAD_CUSTO    = QDG.QDG_DEPTO AND "

cQuery    += oQLTQueryM:MontaQueryComparacaoFiliais("QAD", "QDG", "QAD", "QDG") + " AND "			
		
cQuery    += " QAD.D_E_L_E_T_ <> '*' "			 								
cQuery    += " ORDER BY "+SqlOrder("QDG_FILMAT+QDG_DEPTO+QAD_DESC+QDG_CODMAN+QAA_NOME")

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBQDG",.F.,.T.)

TcSetField("TRBQDG","QAA_INICIO","D")                                    
TcSetField("TRBQDG","QAA_FIM","D")
              
TRBQDG->(DbGotop())	                
        
While !TRBQDG->(Eof())

	If TRBQDG->QDG_TIPO == "P" .AND. (TRBQDG->(QAD_FILMAT+QAD_MAT) != TRBQDG->(QDG_FILMAT+QDG_MAT))
		If QAA->(DbSeek(TRBQDG->(QAD_FILMAT+QAD_MAT)))
			If lTrat
				If ! QA_SitFolh() .or. TRBQDG->QAA_TPRCBT == "4"
					AADD(aInativo,{QAA->QAA_FILIAL,QAA->QAA_MAT})
					TRBQDG->(DbSkip())
					Loop
				Else
					lAltQAD	:=.T.									
				Endif
			Else
				If ! QA_SitFolh()
					AADD(aInativo,{QAA->QAA_FILIAL,QAA->QAA_MAT})
					TRBQDG->(DbSkip())
					Loop
				Else
					lAltQAD	:=.T.									
				Endif
			Endif
		Endif
	Else
		lAltQAD	:=.F.		
		If lTrat
			If !(((Empty(TRBQDG->QAA_FIM) .And. TRBQDG->QAA_STATUS <> "2") .Or.;
				(! Empty(TRBQDG->QAA_FIM) .And. TRBQDG->QAA_FIM >= dDataBase)) .And.;
				(Empty(TRBQDG->QAA_INICIO) .Or. dDataBase >= TRBQDG->QAA_INICIO).And. TRBQDG->QAA_TPRCBT <> "4")			
				
				AADD(aInativo,{TRBQDG->QDG_FILMAT,TRBQDG->QDG_MAT})
				TRBQDG->(DbSkip())
				Loop
			EndIf
		Else
			If !(((Empty(TRBQDG->QAA_FIM) .And. TRBQDG->QAA_STATUS <> "2") .Or.;
				(! Empty(TRBQDG->QAA_FIM) .And. TRBQDG->QAA_FIM >= dDataBase)) .And.;
				(Empty(TRBQDG->QAA_INICIO) .Or. dDataBase >= TRBQDG->QAA_INICIO))			
			
				AADD(aInativo,{TRBQDG->QDG_FILMAT,TRBQDG->QDG_MAT})
				TRBQDG->(DbSkip())
				Loop
			EndIf
		Endif
	EndIf
			
	aReg:= Array(17)			
		
	aReg[ 1]:= .t.
	aReg[ 2]:= TRBQDG->QAD_DESC
	aReg[ 3]:= TRBQDG->QDG_MAT
	aReg[ 4]:= TRBQDG->QDG_CODMAN
	aReg[ 5]:= TRBQDG->QAA_NOME
	aReg[ 6]:= TRBQDG->QDC_DESC                                            			
	aReg[ 7]:= QDXFNDsDtr(TRBQDG->QDG_TPRCBT)
	aReg[ 8]:= TRANSFORM(TRBQDG->QDG_NCOP, "@E 9,999")
	aReg[ 9]:= TRBQDG->QDG_TIPO
	aReg[10]:= TRBQDG->QDG_FILMAT
	aReg[11]:= TRBQDG->QDG_DEPTO
	aReg[12]:= TRBQDG->QDG_RECEB
	aReg[13]:= TRBQDG->QDG_TPRCBT
	aReg[14]:= TRBQDG->QDG_FILIAL
	aReg[15]:= TRBQDG->QDG_DOCTO
	aReg[16]:= TRBQDG->QDG_RV    
	aReg[17]:= TRBQDG->QDC_STATUS
			
	IF lAltQAD
		aReg[10]:=QAA->QAA_FILIAL
		aReg[ 3]:=QAA->QAA_MAT
		aReg[ 5]:=QAA->QAA_NOME 

		QDG->(DbSetOrder(1))
		If QDG->(dbSeek(TRBQDG->(QDG_FILIAL+QDG_DOCTO+QDG_RV+QDG_TIPO+QDG_FILMAT+QDG_DEPTO+QDG_MAT+QDG_CODMAN)))
			nRegAux := QDG->(Recno())
			If !QDG->(dbSeek(TRBQDG->(QDG_FILIAL+QDG_DOCTO+QDG_RV+QDG_TIPO+QAA->QAA_FILIAL+QDG_DEPTO+QAA->QAA_MAT+QDG_CODMAN)))
				QDG->(dbGoTo(nRegAux))
				Begin Transaction
					RecLock("QDG",.F.)
						QDG->QDG_FILMAT := QAA->QAA_FILIAL
						QDG->QDG_MAT    := QAA->QAA_MAT
					QDG->(MsUnLock())
				End Transaction
			Else
				QDG->(dbGoTo(nRegAux))
				Begin Transaction
					RecLock("QDG",.F.)
						QDG->(dbDelete())
					QDG->(MsUnLock())
				End Transaction
				TRBQDG->(DbSkip())
				Loop
			Endif
		Endif
	Endif

	Aadd(aRegs,aReg)
	TRBQDG->(DbSkip())
EndDo
TRBQDG->(dbCloseArea())
RestARea(aArea)

QDG->(DbGoTo(nRegQDG))
QDG->(dbSetOrder(nIndQDG))

Return aRegs

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110InQDG  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Faz a inclusao de um novo destinatario durante a distribuicao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110InQDG()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110InQDG()

Local nItdp  := 1
Local aDeptos:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o Tipo de Destino   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !QD110MsSel(@nItdp)
	Return .F.
	EndIf
	
aRegs:= AClone(aQDGRegs[oQDH:nAt])

	If nItdp == 1
	QD110IncUsr(aRegs)
	ElseIf nItdp == 2
	QD110CarDep(@aDeptos)
	QD110IncPst(aRegs,aDeptos)
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110MsSel  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a tela de selecao Usuarios / Pastas / Nenhum                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110MsSel(ExpN1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Tipo Destino (Usuario/Pasta)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110MsSel(nItdp)

Local oDlg
Local lRet:= .F.

DEFINE MSDIALOG oDlg FROM 000,000 TO 100,200 TITLE OemToAnsi(STR0011) PIXEL // "Destinat rios - Inclus„o"

@ 003,003 TO 035,098 LABEL OemToAnsi(STR0044) OF oDlg PIXEL // "Tipo Destino"
@ 010,010 RADIO oItdp VAR nItdp;
				ITEMS	OemToAnsi(STR0038),; // "Usuarios"
						OemToAnsi(STR0019); // "Pastas"  
				3D SIZE 035,010 OF oDlg PIXEL

DEFINE SBUTTON FROM 037,040 TYPE 1 ENABLE OF oDlg ACTION	(lRet:= .T.,oDlg:End())
DEFINE SBUTTON FROM 037,070 TYPE 2 ENABLE OF oDlg ACTION	(oDlg:End())

ACTIVATE	MSDIALOG oDlg CENTERED

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110ExQDG  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Realiza exclusao de um destinatario durante a fase de distribuicao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110ExQDG()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110ExQDG()

Local aRegs  := {}
Local nOrdQDG:= QDG->(IndexOrd())

	If Len(aQDGRegs) == 0 .Or. Len(aQDG) == 1
	Return .F.
	EndIf

aRegs:= AClone(aQDGRegs[oQDH:nAt])
	If Len(aRegs) > 1
	QDG->(DbSetorder(1))
		If QDG->(DbSeek(aQDG[oQDG:nAt,14]+aQDG[oQDG:nAt,15]+aQDG[oQDG:nAt,16]+aQDG[oQDG:nAt,9]+aQDG[oQDG:nAt,10]+aQDG[oQDG:nAt,11]+aQDG[oQDG:nAt,3]+aQDG[oQDG:nAt,4]))
		Reclock("QDG",.F.)
		QDG->(DbDelete())
		QDG->(MSUnlock())
		FKCOMMIT()
		EndIf
   	QDG->(DbSetOrder(nOrdQDG))
	ADel(aRegs,oQDG:nAt)
	ASize(aRegs,Len(aRegs)-1)
	aQDGRegs[oQDH:nAt]:= AClone(aRegs)
	aQDG:= AClone(aRegs)
	oQDG:SetArray(aQDG)
	oQDG:bLine:= bQDGLine
	oQDG:Refresh()
	aQDH[oQDH:nAt,1]:= AScan(aQDG,{|x| x[1] == .T.}) > 0
	oQDH:SetArray(aQDH)
	oQDH:bLine:= bQDHLine
	oQDH:Refresh() 
	Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Remontar o array de distribuicao - documentos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QD110ExQDH()
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110CfDst  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Realiza a distribuicao do documento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110CfDst()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110CfDst()

Local aQPath   := QDOPATH()
Local cQPath   := aQPath[1]	// Diretorio que contem os .CEL
Local cQPathTrm:= aQPath[3]
Local cQPathHtm:= aQPath[5]
Local cTextoD  := aQPath[4]
Local cTexto    := ""
Local cMvAviso  := GetMV("MV_QAVIREC")
Local cMvAvisoR := GetMV("MV_QAVISOR",.F.,"N") // "Aviso de Recolhimento"
Local cMvProt   := GetMV("MV_QPROT") 
Local cMvProtRe := GetMV("MV_QPROTRE",.F.,"N") // "Protocolo de Recolhimento"
Local nDias		:= 0
Local nDiasT    := GetMV("MV_QDIATR")
Local nC        := 0
Local nQDGRecno := 0
Local nCopias   := 1
Local nRecPro   := 0
Local lCpyS2T   := .F.
Local cFilQAD   := xFilial("QAD")
Local aDiretorio:= {}
Local aData     := {}
Local cArqTmp   := ""
Local nPosDir   := 0
Local nT        := 0
Local nDirHtml  := 0
Local nCopDoc	:= 0
Local lQd1Par	:= .F.
Local cMvQAQuest := GetMv("MV_QAQUEST",.F.,"N")
Local lQdocpUM	 := GetMv("MV_QDOCPUM",.F.,"2")=="1" //Define se imprime apenas uma copia do Documento na Distribuicao 1=Sim 2=Nao
Local lImpri     := .T.
Local aRegsPst	 :={}
Local lPastaIna	 := .F.
Local lNReceb	 := .T.
Local cSvFilAnt	 := cFilAnt
Local cTextoAux  := STRZERO( VAL( QA_SEQU( "QDH", 6, "N" ) ), 6 )  + SubStr( StrZero( year( dDataBase ), 4 ),3 ,2 ) + ".CEL"
Local lStatus    := .F.
Local lQDODISTOK := ExistBlock( "QDODISTREOK" )
Local lQDOATUVA  := ExistBlock( "QDOATUVA" )
Local lQDO110IMP := ExistBlock( "QDO110IMP" )
Local lQDOAP26   := Existblock( "QDOAP26" )
Local lQDORP27   := Existblock( "QDORP27" )
Local lQDORP28   := Existblock( "QDORP28" )
Local lQDOAP19   := ExistBlock( "QDOAP19" )

Private lEditor  := .t.
Private lFim     := .t.
Private lChCopia := .t.
Private cNomRece := ""
Private cDepRece := ""
Private aListID  := {}
Private aListWD  := {}


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe no arquivo QDH o documento selecionado e se este esta em fase de distribuicao ³
	//³Posiciona o registro do arquivo QDH                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDH->(DbSeek(aQDH[oQDH:nAt,6]+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4]))
	QD1->(DbSetOrder(7))
	lQd1Par := 	QDH->QDH_STATUS = "L  " .And.;
			QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+cMatDep+cMatFil+cMatCod+"I  "))

	If 	! QDH->(Found()) .Or. (lQd1Par .And. QD1->QD1_PENDEN = "B")
		QD1->(DbSetOrder(1))
		Return .F.
	EndIf

	If  cFilAnt <> QDH->QDH_FILIAL .AND. FWModeAccess("QDH") == "E" //!Empty(AllTrim(xFilial("QDH")))
	cFilAnt		 := QDH->QDH_FILIAL //Mudo a Variavel publica de Memória como na SuperGetMV
	
	aQPath       := QDOPATH()
	cQPath       := aQPath[1]	// Diretorio que contem os .CEL
	cQPathTrm    := aQPath[3]
	cQPathHtm    := aQPath[5]
	cTextoD      := aQPath[4] 
	
	cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
	EndIf

	nCopDoc	:= If(! GetMv("MV_QDOCPCN", .T., .T.) .And. QDH->QDH_CANCEL = "S", 0, 1)  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a existencia do registro de distribuicao no arquivo QD1 e posiciona o registro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QD1->(DbSetOrder(2))
	If !QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+QDH->QDH_STATUS))
		Return .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a existencia de Questionario e sua Obrigatoridade para impedir a distribuicao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QAG->(DbSetOrder(2))
	IF QDH->QDH_CANCEL == "N" .AND. QDH->QDH_QUEST == "1" .AND. cMvQAQuest == "S"
		If !QAG->(DbSeek(xFILIAL("QAG")+QDH->QDH_DOCTO+QDH->QDH_RV))
			MsgAlert(OemToAnsi(STR0054) , OemToAnsi(STR0027))		
			Return .F.
		EndIf
	ENDIF
                                                          
	DbSelectArea("QDH")
	For nC:= 1 To QDH->(FCount())
		cCampo:= Upper(AllTrim(QDH->(FieldName(nC))))
		M->&cCampo.:= QDH->(FieldGet(nC))
	Next nC

	cTexto:=Alltrim(M->QDH_NOMDOC)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada somente permite distribuir se houver Treinamento, se existe no QAD e se foi concluido
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lQDODISTOK .AND. QDH->QDH_TREINA == '1'
		if !ExecBlock( "QDODISTREOK", .f., .f. ,{ QDH->QDH_FILIAL, QDH->QDH_DOCTO, QDH->QDH_RV })
      		Return .F.
		EndIf
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica, emite a mensagem e exclui as Pastas Inativas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lPastaIna:=.F.
aEval(aQDGRegs[oQDH:nAt],{|x| IF(x[17]=="2",lPastaIna:=.T.,"")})

	IF lPastaIna
		IF MsgYesNo(OemToAnsi(STR0068),OemToAnsi(STR0027)) //"Aten‡„o" //"Existe Pasta Inativa deseja exclui-la do documento ?"
			While lPastaIna
			aRegsPst:= AClone(aQDGRegs[oQDH:nAt])
				For nC:=1 To Len(aRegsPst)
					IF aRegsPst[nC,17]=="2"
						oQDG:nAt:=nC
						QD110ExQDG()
						Exit
					Endif
				Next
				lPastaIna:=.F.
				aEval(aQDGRegs[oQDH:nAt],{|x| IF(x[17]=="2",lPastaIna:=.T.,"")})
				IF Len(aQDGRegs) == 0 .Or. Len(aQDG) == 1
					Exit
				EndIf
			Enddo
			IF lPastaIna
				Return .F.
			Endif
		Else
			Return .F.
		Endif
	Endif

	aEval(aQDGRegs[oQDH:nAt],{|x| IF(x[13]<>"4",lNReceb:=.F.,"")})
	IF lNReceb
		MsgAlert(OemToAnsi(STR0069),OemToAnsi(STR0027)) // ###"Aten‡„o"  //"Nao Existe(m) destinatarios(s) validos cadastrado(s) para o documento "
		Return .F.
	Endif

// Monta a tela de datas de vigencia, implantacao e validade
	If !QD110DtVig()
	Return .F.
	EndIf

nDias := M->QDH_DTVIG - dDatabase
	If nDias > nDiasT .And. nDiasT > 0
	nDiasT:= nDias
	EndIf

	IF M->QDH_DTOIE <> "E" .AND. lQdocpUM
	MsgAlert(OemToAnsi(STR0067),OemToAnsi(STR0027)) //"Será impresso apenas uma (1) copia do documento, conforme o parâmetro MV_QDOCPUM." ###"Aten‡„o" 
	Endif


	If !MsgYesNo(OemToAnsi(STR0028),OemToAnsi(STR0027)) // " Confirma Distribui‡„o do Documento ?" ### "Aten‡„o"
	Return .F.
	EndIf

M->QDH_STATUS:= "L  "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura a existencia de destinatarios no arquivo QDH e posiciona o primeiro registro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDG->(DbSetOrder(6))
	If !QDG->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
		Return .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se dois usuarios nao estao tentando executar a baixa do documento ao mesmo tempo e bloqueia um deles ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDH->(DbSeek(aQDH[oQDH:nAt,6]+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4]))
	If (QDH->QDH_STATUS == "L  " .And. ! lQd1Par ) .AND. !SoftLock("QDH")
		MsgAlert(OemToAnsi(STR0041),OemToAnsi(STR0027)) // "Outro usu rio j  est  realizando esta opera‡„o" ### "Aten‡„o" 
		Return .F.
	EndIf

	IF lQDOATUVA
		ExecBlock( "QDOATUVA", .f., .f. ,{ M->QDH_DOCTO, M->QDH_RV })
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a gravacao dos dados nas bases de dados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgRun(OemToAnsi(STR0042),OemToAnsi(STR0003),{|| QD110GrDst(nDiasT, lQd1Par)}) // "Atualizando Distribui‡”es" ### "Aguarde..."

	If M->QDH_DTOIE <> "E"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os ultimos campos do Doc, Salva e Finaliza secao Word ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcessaDoc( { || QdoDocRUsr( lEditor, .F. , ,.T.,, nCopDoc,@lCpyS2T,.F.) } )
		ProcessaDoc( { || QdoDocRUsr( .F. , .T. ,,,, nCopDoc,@lCpyS2T,.F.) } )

		If File(cQPathTrm+cTexto)
			If lCpyS2T
				CpyT2S(cQPathTrm+cTexto,cQPath,.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Copia o Documento em Html para o Servidor     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				cArqTmp := Left(AllTrim(M->QDH_NOMDOC),Len(AllTrim(M->QDH_NOMDOC))-3)+"HTM"
				If File(cQPathTrm+cArqTmp)
					CpyT2S(cQPathTrm+cArqTmp,cQPathHtm,.T.)
					aDiretorio:= QDocDirc(cQpathTrm,"D") //DIRECTORY
					If Len(aDiretorio) > 0
						nPosDir:= ASCAN(aDiretorio,{|X| Substr(AllTrim(M->QDH_NOMDOC),1,8)+"_" $ X[1] })
						If nPosDir > 0
							If (nDirHtml:= MakeDir(cQPathHtm+aDiretorio[nPosDir,1])) == 0
								aData  := QDocDirc(cQPathTrm+aDiretorio[nPosDir,1]) //DIRECTORY							
								For nT:= 1 to Len(aData)
									If File(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]))
							      		CpyT2S(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]),cQPathHtm+aDiretorio[nPosDir,1],.T.)
									Endif
								Next nT
							EndIf
						EndIf
					EndIf
					If File(cQPathTrm+cArqTmp)
						QDRemDirHtm(cArqTmp) // Remove Arquivos Html
					EndIf
				EndIf
			EndIf
			FErase(cQPathTrm+cTexto)
		EndIf

		lImpri := .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada antes da impressao do Documento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQDO110IMP
			If ValType( lImpri := ExecBlock( "QDO110IMP", .F., .F., { lImpri } ) ) <> "L"
				lImpri := .T. // Por  default Imprime
			EndIf
		EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a impressao das copias distribuidas em papel ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDG->(DbSetOrder(1))	
	QDG->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
		While QDG->(!Eof()) .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
			If QDG->QDG_SIT == "I"
			QDG->(DbSkip())
			Loop
			EndIf
			If QDG->QDG_RECEB == "S" .And. QDG->QDG_TPRCBT $ "2,3"
				nQDGRecno:= QDG->(RecNo())
				cFilQDG  := QDG->QDG_FILMAT
				cMatQDG  := QDG->QDG_MAT
				cDepQDG  := QDG->QDG_DEPTO
				If nCopDoc = 0
					nCopias := 0
				Else
					IF lQdocpUM   //Imprime Apenas uma Copia do Doc
						nCopias := 1 
					Else
						nCopias := If(QDG->QDG_NCOP > 0,QDG->QDG_NCOP,1)
					Endif
				Endif
				If !lImpri
					nCopias := 0
				EndIf
				If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
					cFilQAD:= QDG->QDG_FILMAT
				EndIf
				If QDG->QDG_TIPO == "P"
					If QAD->(DbSeek(cFilQAD+QDG->QDG_DEPTO))
						cFilQDG:= QAD->QAD_FILMAT
						cMatQDG:= QAD->QAD_MAT
					EndIf
				EndIf
				QAA->(DbSetOrder(1))
				If QAA->(DbSeek(cFilQDG+cMatQDG) )
					If QA_SitFolh()
						cNomRece:= QAA->QAA_NOME
						cDepRece:= QAA->QAA_CC
						QAD->(DbSeek(cFilQAD+QDG->QDG_DEPTO))
						If QDG->QDG_TIPO == "P"
							cNomRece:= Alltrim(QDG->QDG_CODMAN)+" - "+QDXFNANMAN(QDG->QDG_CODMAN,.T.)+chr(13)+STR0064+QAA->QAA_NOME //"Responsavel: "
						EndIf
						ProcessaDoc({|| QdoDocRUsr(lEditor,.F.,cNomRece,,,nCopias,@lCpyS2T,.F.)})
						lEditor:= .F.   
						ProcessaDoc( { || QdoDocRUsr( .F. , .T. ,,,, nCopDoc,@lCpyS2T,.F.) } )
						IF lQdocpUM
							Exit
						Endif
					EndIf
				EndIf
			QDG->(DbGoTo(nQDGRecno))
			EndIf
		QDG->(DbSkip())	
		EndDo
	Else
		MsgInfo(OemToAnsi(STR0043),OemToAnsi(STR0004)) // "Por este Documento ser de autoria Externa, nao serao impressas as copias do tipo papel" ### "Distribuicao"
	EndIf

	If !lEditor
		ProcessaDoc({|| QdoDocRUsr(.F.,lFim,,,, nCopDoc,@lCpyS2T,.F.)})
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Numero da Revisao Anterior  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRvAnt:= STRZERO(VAL(LEFT(M->QDH_RV,3))-1,3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Pendencia de Devolucao da Revisao Anterior(Copia Papel)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QDG->(DbSetOrder(1))	
	If QDG->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+cRvAnt))
		While QDG->(!Eof()) .And. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == M->QDH_FILIAL+M->QDH_DOCTO+cRvAnt
			If QDG->QDG_SIT == "I"
			QDG->(DbSkip())
			Loop
			EndIf
			If QDG->QDG_RECEB == "S" .And. QDG->QDG_TPRCBT $ "2,3"
			QD110GrDev(QDG->QDG_FILMAT,QDG->QDG_MAT,QDG->QDG_DEPTO,M->QDH_DOCTO,cRvAnt,QDG->QDG_NCOP)
			EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada que Grava Pendencia de Devolucao da Revisao Anterior Outras (Copias)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		                                                                          
			IF lQDOAP26
				If QDG->QDG_RECEB == "S" .And. QDG->QDG_TPRCBT $ EXECBLOCK("QDOAP26",.F.,.F.,{QDG->QDG_FILMAT,QDG->QDG_MAT})
				QD110GrDev(QDG->QDG_FILMAT,QDG->QDG_MAT,QDG->QDG_DEPTO,M->QDH_DOCTO,M->QDH_RV,QDG->QDG_NCOP)		
				ENDIF
			Endif
		QDG->(DbSkip())
		EndDo
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os protocolos referentes a distribuicao				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->QDH_DTOIE == "I"
		If cMvProt == "S"
			If QD110ImpP(M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV) // Verifica se ha dados a serem impressos.
				IF lQDORP27
				EXECBLOCK('QDORP27',.F.,.F.)	    	
				ELSE
				QDOR060(.T.) // Protocolo de Recebimento				
				ENDIF
			EndIf
		EndIf
		If cMvProtRe == "S"
			If QDH->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+cRvAnt))
				If QD110ImpP(M->QDH_FILIAL,M->QDH_DOCTO,cRvAnt) // Verifica se ha dados a serem impressos.
					IF lQDORP28
					EXECBLOCK('QDORP28',.F.,.F.,{M->QDH_DOCTO,M->QDH_RV})	    	
					ELSE
					QDOR063(.t.,M->QDH_DOCTO,M->QDH_RV) // Protocolo de Recolhimento
					ENDIF
					
				EndIf
			EndIf
		EndIf
	Elseif M->QDH_DTOIE == "E"
		If cMvAviso == "S"
			If QD110ImpP(M->QDH_FILIAL,M->QDH_DOCTO,M->QDH_RV) // Verifica se ha dados a serem impressos.
			QDOR061(.t.) // Aviso de Recebimento
			EndIf
		EndIf
		If cMvAvisoR == "S"
			If QDH->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+cRvAnt))
				If QD110ImpP(M->QDH_FILIAL,M->QDH_DOCTO,cRvAnt) // Verifica se ha dados a serem impressos.
				QDOR064(.t.,M->QDH_DOCTO,M->QDH_RV) // Aviso de Recolhimento
				EndIf
			EndIf
		EndIf
	EndIf

	If File(cQPathTrm+cTextoD)
	FErase(cQPathTrm+cTextoD)
	EndIf

	If lQDOAP19
	ExecBlock("QDOAP19",.F.,.F.,{M->QDH_DOCTO,M->QDH_RV})
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Na Integracao com o QMT verificar se  o procedimento foi preenchido.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea("QA5")
DBSetOrder(1)
DBGoTop() // Foi optado por nao usar um indice na QA5 por Documento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procuro pelo Documento nos Procedimentos de Utilizacao e Medicao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While QA5->(!EOF())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o Procedimento tiver  como anexo o  documento que  esta  sendo  alterado,       ³
	//³ devo analisar o  procedimento  verificando se este  esta  apto, ou seja, e a ulti- ³
	//³ ma revisao  vigente  do procedimento e existe  calibração para um  instrumento     ³
	//³ com este procedimento.                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QA5->QA5_DOCTO == M->QDH_DOCTO  .AND. QMT050RevAp(QA5->QA5_NORMA, QA5->QA5_REVPRO, QA5->QA5_CODTAB,M->QDH_DOCTO,M->QDH_RV)
		nRecPro := Recno()
		QMT050NRD() 
		DbGoTo(nRecPro)
		EndIf
	QA5->(DBSkip())
	End


dbSelectArea("QD1")
Set Filter To

	If !lStatus
		If M->QDH_STATUS $ "L  |I  "
			If File(cQPathTrm+cTextoAux)
			fErase(cQPathTrm+cTextoAux)		
			EndIf
		Endif
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110GrDst  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Realiza a gravacao da distribuicao do documento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110GrDst(ExpN1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Dias de Validade do Documento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110GrDst(nDiasT, lQd1Par)

Local aData      := {}
Local aDiretorio := {}
Local aQPath     := QDOPATH()
Local aSavQD1    := {}
Local aSavQDH    := {}
Local aTPPEND    := {}
Local aUsrMat    := QA_USUARIO()
Local bCampo     :={|nCPO| Field( nCPO ) }
Local cArqTmp    := ""
Local cChaveQDH  := ""
Local cDepQDG    := TamSx3("QDG_DEPTO")[1]
Local cDescr     := ""
Local cFilQa     := If(FWModeAccess("QAD")=="C",xFilial("QAD"), QDH->QDH_FILDEP)
Local cFilQAD    := xFilial("QAD")
Local cFilQDG    := Space(FWSizeFilial()) //Space(02)
Local cHora      := ""
Local cMatCod    := aUsrMat[3]
Local cMatDep    := aUsrMat[4]
Local cMatFil    := aUsrMat[2]
Local cMatQDG    := TamSx3("QDG_MAT")[1]
Local cQPath     := aQPath[1] // Diretorio que contem os .CEL
Local cQPathHtm  := aQPath[5]
Local cQPathTrm  := aQPath[3]
Local cRv        := ""
Local cUltRv     := ""
Local lCPYS2T    := .F.
Local lEmailCC   := GetMv("MV_QDOEMCC",.F.,"2")=="1" //Define se na distribuicao envia um e-mail de pendencia de leitura com copia para todos os Destinatarios 1=SIM; 2=NAO
Local lFutura    := .F.
Local lGrava     := .T.
Local lQD110PEN  := Existblock( 'QD110PEN' )
Local nC         := 1
Local nDiasF     := GetMV("MV_QDIATR")
Local nH         := 0
Local nOpc       := 4
Local nOrdQAA    := QAA->(IndexOrd())
Local nPosDir    := 0
Local nQDGRecno  := 0
Local nQDHRecno  := 0
Local nT         := 0

Private aUsrMail := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza a baixa do documento gravando as atualizacoes nos arquivo QDH, QD1 e QDG ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizado o QD1 quando for distribuicao conforme QDZ e QAA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QD50DSTATU(cFilQA,nOpc,nOrdQAA)

	nQdhRecno := QDH->(Recno())
	RecLock("QDH",.F.)
	QDH->QDH_STATUS:= M->QDH_STATUS
	QDH->QDH_DTVIG := M->QDH_DTVIG
	QDH->QDH_DTLIM := M->QDH_DTLIM
	QDH->QDH_DTIMPL:= M->QDH_DTIMPL
	QDH->(MsUnlock())
	FKCOMMIT()
	QDG->(DbSetOrder(1))
	QDG->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
		While 	! lQd1Par .And. QDG->(!Eof()) .And.;
			QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV == QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV
				If QDG->QDG_SIT == "I"
	      	QDG->(DbSkip())
	      	Loop
			EndIf
			If QDG->QDG_RECEB == "S" .And. QDG->QDG_TPRCBT <> "4"
			nQDGRecno:= QDG->(RecNo())
			cFilQDG  := QDG->QDG_FILMAT
			cMatQDG  := QDG->QDG_MAT
			cDepQDG  := QDG->QDG_DEPTO
			nCopias  := If(QDG->QDG_NCOP > 0,QDG->QDG_NCOP,1)
			lGrava	 := .T.
				If QDG->QDG_TIPO == "P"
					If FWModeAccess("QAD") == "E" ////!Empty(xFilial("QAD"))
					cFilQAD := QDG->QDG_FILMAT
					EndIf
					If QAD->(DbSeek(cFilQAD+QDG->QDG_DEPTO))
					cFilQDG:= QAD->QAD_FILMAT
					cMatQDG:= QAD->QAD_MAT
					EndIf
				EndIf
			QAA->(DbSetOrder(1))
				If QAA->(DbSeek(cFilQDG+cMatQDG)) .And. QA_SitFolh()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Condicao criada para NAO gerar erro de gravacao no QD1 chave unica	³
				//³	utilizando o campo HRGERA (HORA)									³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				cHora := SubStr(Time(),1,5)
			    QD1->(DbSetOrder(1))			    
					IF QD1->(DbSeek(QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+cDepQDG+cFilQDG+cMatQDG+DTOS(dDataBase)+"L  "))
						While !QD1->(Eof()) .AND. QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV+cDepQDG+cFilQDG+cMatQDG+DTOS(dDataBase)+"L  "==;
	    			QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO+QD1->QD1_FILMAT+QD1->QD1_MAT+DTOS(QD1->QD1_DTGERA)+QD1->QD1_TPPEND
								If QDG->QDG_TIPO == "D" .And. QD1->QD1_PENDEN == "P" // Destinatario
							lGrava := .F. // Se exister QD1 pendente não permite a duplicação
							ElseIf QD1->QD1_HRGERA > cHora
							cHora:= QD1->QD1_HRGERA
							EndIf
						QD1->(DbSkip())
						EndDo
						If cHora >= SubStr(Time(),1,5) .And. lGrava
						cHora:=QSomaH(cHora) //Soma um minuto					
						EndIf
					EndIf
			
					If lGrava
					RecLock("QD1",.T.)
					QD1->QD1_FILIAL := M->QDH_FILIAL
					QD1->QD1_DOCTO  := M->QDH_DOCTO 
					QD1->QD1_RV     := M->QDH_RV      
					QD1->QD1_TPPEND := M->QDH_STATUS     
					QD1->QD1_FMATBX := cMatFil
					QD1->QD1_MATBX  := cMatCod
					QD1->QD1_DEPBX  := cMatDep
					QD1->QD1_FILMAT := cFilQDG
					QD1->QD1_MAT    := cMatQDG
					QD1->QD1_DEPTO  := cDepQDG
					QD1->QD1_DISTNE := "N"
						If QDH->QDH_CANCEL == "S"
							cDescr:= "C" // "Cancelamento"
							QD1->QD1_PENDEN := "B"     
							QD1->QD1_LEUDOC := "S"
							QD1->QD1_DTBAIX := dDataBase     
						Else
							If QDG->QDG_TIPO == "D"
								If QDG->QDG_TPRCBT == "2"
									QD1->QD1_PENDEN := "B"     
									QD1->QD1_LEUDOC := "S"
									QD1->QD1_DTBAIX := dDataBase     						
								Else
									QD1->QD1_PENDEN := "P"     
									QD1->QD1_LEUDOC := "N"
									QD1->QD1_DTBAIX := CTOD("  /  /  ","DDMMYY")
								Endif
							Else
								QD1->QD1_PENDEN := "B"     
								QD1->QD1_LEUDOC := "S"
								QD1->QD1_DTBAIX := dDataBase     						
							EndIf
						EndIf
					QD1->QD1_HRGERA := cHora
					QD1->QD1_DTGERA := dDataBase        			 
					QD1->QD1_CHAVE  := M->QDH_CHAVE
					QD1->QD1_CARGO  := QAA->QAA_CODFUN
					QD1->QD1_TPDIST := QDG->QDG_TPRCBT 
					QD1->(MsUnlock())
					FKCOMMIT()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava Aviso de Cancelamento de Documento                   	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cDescr == "C" // Distribuicao de Docto Cancelamento
						QDS->(DbSetOrder(1))
							If !QDS->(DbSeek(QAA->QAA_FILIAL+QAA->QAA_MAT+"P"+"CAN"+QD1->QD1_DOCTO+QD1->QD1_RV))
							QDXGvAviso("CAN",QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_CC,QD1->QD1_DOCTO,QD1->QD1_RV,,QD1->QD1_FILIAL)
							Endif
						EndIf
					
						If lQD110PEN
						Execblock('QD110PEN',.F.,.F.) // Ponto de Entrada para efetuar tratamento na tabela de pendencias antes do envio do e-mail 	    	
						Endif
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa a emissao dos EMails                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
						If (!Empty(QAA->QAA_EMAIL) .and. QAA->QAA_RECMAI == "1") .and. (QD1->QD1_PENDEN == "P" .Or. cDescr == "C") .and. (QD1->QD1_TPPEND == "L  ")
							IF lEmailCC
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Executa a emissao UM EMail com todos os Destinarios      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								IF Len(aUsrMail) == 0
								fQdoTpMail(@aUsrMail,QD1->QD1_DOCTO,QD1->QD1_RV,M->QDH_TITULO,QAA->QAA_EMAIL,M->QDH_STATUS,M->QDH_FILMAT,QAA->QAA_APELID,"","",cDescr,,M->QDH_CODTP,M->QDH_DTVIG)
								Else
								aUsrMail[1,2]+=";"+Alltrim(QAA->QAA_EMAIL)
								Endif
							Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Executa a emissao dos EMais com UM Destinario             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						   						
							fQdoTpMail(@aUsrMail,QD1->QD1_DOCTO,QD1->QD1_RV,M->QDH_TITULO,QAA->QAA_EMAIL,M->QDH_STATUS,M->QDH_FILMAT,QAA->QAA_APELID,"","",cDescr,,M->QDH_CODTP,M->QDH_DTVIG)										
							Endif
						EndIf
					
						If QDG->QDG_TIPO == "D"
						QD110GrLog( .t., STR0029, "U", QDG->QDG_NCOP, cMatFil, cMatCod, QDG->QDG_FILMAT, QDG->QDG_MAT, QDG->QDG_TPRCBT ) // "Distribui‡„o por Usuario"
						Else
						QD110GrLog( .t., STR0030, "P", 1, cMatFil, cMatCod, QAA->QAA_FILIAL, QAA->QAA_MAT, QDG->QDG_TPRCBT ) // "Distribui‡„o por Pastas"
						EndIf
					EndIf
				Else
				Reclock("QDG",.F.)
				QDG->(DbDelete())
				QDG->(MSUnlock())
				FKCOMMIT()
				EndIf
			QDG->(DbGoTo(nQDGRecno))
			EndIf
		QDG->(DbSkip())	
		EndDo
	QDJ->(DbSetOrder(1))
		If QDJ->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
			While QDJ->(!Eof()) .And. QDJ->QDJ_FILIAL+QDJ->QDJ_DOCTO+QDJ->QDJ_RV == QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV
				If !QDG->(DbSeek(QDJ->QDJ_FILIAL+QDJ->QDJ_DOCTO+QDJ->QDJ_RV+QDJ->QDJ_TIPO+QDJ->QDJ_FILMAT+QDJ->QDJ_DEPTO))
				Reclock("QDJ",.F.)
				QDJ->(DbDelete())
				QDJ->(MSUnlock())   
				FKCOMMIT()
				EndIf
			QDJ->(DbSkip())			
			EndDo
		EndIf
	QDH->(DbSetOrder(1))
	Aadd(aTPPEND,{QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV,"I  "})
	cRv   := QDH->QDH_RV
	cUltRv:= ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda as variaveis do Documento atual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	DbSelectArea("QDH")
		For nH := 1 To FCount()
		aAdd(aSavQDH,{Eval(bCampo,nH),M->&(Eval(bCampo,nH))})
		Next nH
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava - quando a distribuicao for de nova revisao de documento - a nova data de validade da revisao anterior ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cChaveQDH	:= QDH->QDH_FILIAL+QDH->QDH_DOCTO
	lFutura  	:= .F.
		If QDH->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO))
			While !Eof() .And. QDH->QDH_FILIAL + QDH->QDH_DOCTO == cChaveQDH
				If QDH->QDH_RV <> cRv
					If QDH->QDH_OBSOL <> "S"
						If ! lQd1Par
						RecLock("QDH",.F.)
							If M->QDH_DTVIG > dDataBase .And. M->QDH_CANCEL <> "S"
							QDH->QDH_OBSOL := "S"							
							Else
							QDH->QDH_OBSOL := "S"
							Endif
							If lFutura
							QDH->QDH_DTLIM := If(nDiasF == 0, M->QDH_DTVIG-1, M->QDH_DTVIG + nDiasF)
							Else
							QDH->QDH_DTLIM := If(nDiasT == 0, M->QDH_DTVIG-1, M->QDH_DTVIG + nDiasT)
							EndIf
						QDH->(MsUnlock())	
						FKCOMMIT()
						Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Restaura as variaveis de memoria do documento atual	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nH := 1 To Len(aSavQDH)
						M->&(aSavQDH[nH,1]) := aSavQDH[nH,2]
						Next
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza os ultimos campos do Doc, Salva e Finaliza secao Word ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If M->QDH_DTOIE <> "E"
						ProcessaDoc( { || QdoDocRUsr( .T. , .F. , ,.T.,.T.,,@lCpyS2T,.F.) } )
						ProcessaDoc( { || QdoDocRUsr( .F. , .T. ,,,,,@lCpyS2T,.F.) } )
							If File(cQPathTrm+AllTrim(M->QDH_NOMDOC))
								If lCpyS2T
								CpyT2S(cQPathTrm+AllTrim(M->QDH_NOMDOC),cQPath,.T.)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Copia o Documento Html para o Servidor        ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
								cArqTmp := Left(AllTrim(M->QDH_NOMDOC),Len(AllTrim(M->QDH_NOMDOC))-3)+"HTM"
									If File(cQPathTrm+cArqTmp)
						      		CpyT2S(cQPathTrm+cArqTmp,cQPathHtm,.T.)
		      						aDiretorio:= QDocDirc(cQpathTrm,"D") //DIRECTORY
										If Len(aDiretorio) > 0
										nPosDir:= ASCAN(aDiretorio,{|X| Substr(AllTrim(M->QDH_NOMDOC),1,8)+"_" $ X[1] })
											If nPosDir > 0
											MakeDir(cQPathHtm+aDiretorio[nPosDir,1])
											aData  := QDocDirc(cQPathTrm+aDiretorio[nPosDir,1]) //DIRECTORY											
												For nT:= 1 to Len(aData)
													If File(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]))
										      	CpyT2S(cQPathTrm+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]),cQPathHtm+aDiretorio[nPosDir,1],.T.)
													Endif
												Next
											EndIf
										EndIf
										If File(cQPathTrm+cArqTmp)
										QDRemDirHtm(cArqTmp) // Remove Arquivos Html
										EndIf
									EndIf
								EndIf
							FErase(cQPathTrm+AllTrim(M->QDH_NOMDOC))
							lCpyS2T := .F.
							Endif
						EndIf
					EndIf
				Aadd(aTPPEND,{QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV,"L  "})
				EndIf
			
			DbSelectArea("QDH")
			QDH->(DbSkip())
			EndDo
		EndIf
	
	aSavQD1 := QD1->(GetArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Baixa todas as pendencias de Leitura e alguns Avisos existentes das revisoes anteriores ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QD1->(DbSetOrder(2))
		For nC := 1 To Len(aTPPEND)
		QD1->(DbSeek(aTPPEND[nC,1]+aTPPEND[nC,2]))
			While !QD1->(Eof()) .And. QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_TPPEND == aTPPEND[nC,1]+aTPPEND[nC,2]
				If 	QD1->QD1_TPPEND == aTPPEND[nC,2] .And. QD1->QD1_PENDEN == "P"
				RecLock("QD1",.F.)
				QD1->QD1_PENDEN := "B"
				QD1->QD1_DTBAIX := dDataBase
				QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
				QD1->QD1_FMATBX := cMatFil
				QD1->QD1_MATBX  := cMatCod
				QD1->QD1_DEPBX  := cMatDep
				QD1->QD1_DISTNE := "N"
				QD1->(MsUnlock())
				FKCOMMIT()
				EndIf
			QD1->(DbSkip())
			EndDo
		
			IF Right(aTPPEND[nC,1],3) <> cRv //Dif da REVISAO ATUAL
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Baixa o Avisos de Documento Vencido VEN    					   ³
			//³		de Inclusao de Treinamento da Revisao Anterior TRE		   ³
			//³		de Agendado Treinamento para este Documento TI  		   ³
			//³		de Inclusao de Questionario da Revisao Anterior QUE		   ³
			//³		de Existe solicitacao de Alteracao para este Documento SAD ³
			//³Baixa o Aviso de Referencia Anterior       					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QDS->(DbSetOrder(2))
				If QDS->(DbSeek(aTPPEND[nC,1]))
					While QDS->(!Eof()) .And. QDS->QDS_FILIAL+QDS->QDS_DOCTO+QDS->QDS_RV == aTPPEND[nC,1]
											
						IF ALLTRIM(QDS->QDS_TPPEND)$"VEN.TRE.QUE.SAD.TI" .OR. (M->QDH_CANCEL == "S" .AND. ALLTRIM(QDS->QDS_TPPEND)=="REF")
							If QDS->QDS_PENDEN == "P"
							RecLock("QDS",.F.)
							QDS->QDS_PENDEN := "B"
							QDS->QDS_DTBAIX:= dDataBase
							QDS->QDS_HRBAIX:= SubStr(Time(),1,5)
							QDS->QDS_FMATBX := cMatFil
							QDS->QDS_MATBX  := cMatCod
							QDS->QDS_DEPBX  := cMatDep
							QDS->(MsUnlock())
							FKCOMMIT()
							EndIf
						Endif
					QDS->(DbSkip())
					EndDo
				EndIf
			Endif
		Next nC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura as variaveis de memoria do documento atual	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nH := 1 To Len(aSavQDH)
		M->&(aSavQDH[nH,1]) := aSavQDH[nH,2]
		Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Remontar o array de distribuicao - documentos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QD110ExQDH()   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a revisao for de cancelamento, grava o status de cancelado em todas as revisoes anteriores ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDH->(DbSetOrder(1))
		If M->QDH_CANCEL == "S"
			If QDH->(Dbseek(M->QDH_FILIAL+M->QDH_DOCTO))
				While QDH->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO == M->QDH_FILIAL+M->QDH_DOCTO
				RecLock("QDH",.F.)
				QDH->QDH_CANCEL:= "S"
				QDH->(MsUnlock())
				FKCOMMIT()
				QDH->(DbSkip())
				EndDo
			EndIf
		QD1->(DbSetOrder(7))
			If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+cMatDep+cMatFil+cMatCod+"I"))
			RecLock("QD1",.F.)
			QD1->QD1_LEUDOC := "S"
			QD1->(MsUnlock())
			FKCOMMIT()
			EndIf
		EndIf

		If lFutura .And. M->QDH_DTVIG > dDataBase
		QDH->(DbGoto(nQdhRecno))
		QDH->(RecLock("QDH", .F.))
		QDH->QDH_FUTURA := "G"
		QDH->(MsUnLock())
		FKCOMMIT()
		Endif
	
	QD1->(RestArea(aSavQD1))
	
	End Transaction

	If Len(aUsrMail) <> 0
   QaEnvMail(aUsrMail,,,,aUsrMat[5],"2")
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110GrLog  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Grava em arquivo um Log de distribuicao de documentos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110GrLog(EcpL1,ExpC1,ExpC2,ExpN1,ExpC3,ExpC4,ExpC5,ExpC5,ExpC7)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpL1 - Distribuicao S/N                                          ³±±
±±³           ³ ExpC1 - Motivo                                                    ³±±
±±³           ³ ExpC2 - Tipo de distribuicao                                      ³±±
±±³           ³ ExpN1 - Numero de Copias                                          ³±±
±±³           ³ ExpC3 - Filial do distribuidor/solicitante                        ³±±
±±³           ³ ExpC4 - Matricula do distribuidor/solicitante                     ³±±
±±³           ³ ExpC5 - Filial do destinatario                                    ³±±
±±³           ³ ExpC6 - Matricula do destinatario                                 ³±±
±±³           ³ ExpC7 - Tipo de recebimento                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110GrLog(lDistr,cMotLog,cTpDist,nCopias,cFilSol,cMatSol,cFilDes,cMatDes,cTpRcbt)

Local cCodSeq:= StrZero(Val(QA_SEQU(QDH->QDH_DOCTO+QDH->QDH_RV+"LOG",6,"N")),6) 

QDE->(DbSetOrder(1))
	If !QDE->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV+cCodSeq))
	RecLock("QDE",.T.)
	QDE->QDE_FILIAL := QDH->QDH_FILIAL
	QDE->QDE_DOCTO  := QDH->QDH_DOCTO
	QDE->QDE_RV     := QDH->QDH_RV
	QDE->QDE_SEQ    := cCodSeq
	QDE->QDE_CONTR  := If( lDistr, "S", "N" )
	QDE->QDE_DATA   := dDataBase
	QDE->QDE_MOTIVO := cMotLog
	QDE->QDE_NCOP   := nCopias
	QDE->QDE_OBSOL  := QDH->QDH_OBSOL
	QDE->QDE_TPDIST := cTpDist
	QDE->QDE_FILSOL := cFilSol
	QDE->QDE_MATSOL := cMatSol
	QDE->QDE_FILDES := cFilDes
	QDE->QDE_MATDES := cMatDes
	QDE->QDE_TPRCBT := cTpRcbt
	QDE->(MsUnlock())
	FKCOMMIT()
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110DtVig  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a tela de data de distribuicao, vigencia e validade         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110DtVig()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110DtVig()

Local oDlg
Local oDtVig
Local oDtImpl
Local oDtLim
Local oQtdDias
Local dDtVig  := If(QDH->QDH_STATUS <> "L  ", dDatabase, QDH->QDH_DTVIG)
Local dDtImpl := If(QDH->QDH_STATUS <> "L  ", dDatabase, QDH->QDH_DTIMPL)
Local dDtLimi := If(QDH->QDH_STATUS <> "L  ", CToD( "  /  /  ","DDMMYY" ), QDH->QDH_DTLIM)
Local nQtdDias:= 1
Local nOpc1   := 0  
Local cConsDtImpl := GetMv("MV_QDHDTIM",.f.,"2")   // Habilita Calculo a partir da data de Implantacao 1=Sim / 2=Nao   
				    
QD2->(DbSeek(xFilial("QD2")+QDH->QDH_CODTP))
	If (nQtdDias:= QD2->QD2_QDIASV) > 0
	dDtLimi := (dDtImpl+QD2->QD2_QDIASV)
	EndIf

DEFINE MSDIALOG oDlg	FROM 000,000 TO 180,205 TITLE OemToAnsi(STR0031) PIXEL // "Distribui‡„o"

@ 001,004 TO 070,100 OF oDlg PIXEL

@ 010,010 SAY OemToAnsi(STR0032) SIZE 70,10 OF oDlg PIXEL // "Dt Vigˆncia"
@ 025,010 SAY OemToAnsi(STR0033) SIZE 70,10 OF oDlg PIXEL // "Dt Implanta‡„o"
@ 040,010 SAY OemToAnsi(STR0034) SIZE 70,10 OF oDlg PIXEL // "Dias Validade"
@ 055,010 SAY OemToAnsi(STR0035) SIZE 70,10 OF oDlg PIXEL // "Dt  Validade"

@ 010,055 	MSGET oDtVig VAR dDtVig PICTURE "@D" SIZE 043,008 OF oDlg PIXEL;
			WHEN QDH->QDH_STATUS <> "L  "

@ 025,055 	MSGET oDtImpl VAR dDtImpl	PICTURE "@D" SIZE 043,008 OF oDlg PIXEL;
			VALID dDtImpl <= dDtVig WHEN QDH->QDH_STATUS <> "L  "

@ 040,055 	MSGET oQtdDias VAR nQtdDias PICTURE "9999" SIZE 027,008 OF oDlg PIXEL;
           	VALID If(nQtdDias >= 0,;
           	(dDtLimi:= If(nQtdDias > 0, ;
	if(Alltrim(cConsDtImpl)=="2",dDtVig+nQtdDias,dDtImpl+nQtdDias),;
           	CToD("  /  /  ","DDMMYY")),oDtLim:Refresh()),.F.);
			WHEN QDH->QDH_STATUS <> "L  "

@ 055,055 	MSGET oDtLim VAR dDtLimi PICTURE	"@D" SIZE 043,008 OF oDlg PIXEL;
			WHEN QDH->QDH_STATUS <> "L  "
			
// PE para permitir digitar a data da validade sobrepondo o numero de dias.
			if existblock("QDODVLDOC")
	oDtLim:lReadOnly:= .F.
		Else
	oDtLim:lReadOnly:= .T.
		EndIf

DEFINE SBUTTON FROM 75,35 TYPE 1 ENABLE OF oDlg ACTION (nOpc1:=1,oDlg:End())
DEFINE SBUTTON FROM 75,65 TYPE 2 ENABLE OF oDlg	ACTION oDlg:End()

ACTIVATE	MSDIALOG oDlg CENTERED

		If nOpc1 == 1
	M->QDH_DTCAD := dDatabase
	M->QDH_DTVIG := dDtVig
	M->QDH_DTIMPL:= dDtImpl
	M->QDH_DTLIM := dDtLimi
		EndIf

Return If(nOpc1 == 1,.T.,.F.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110CkDep  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Valida departamento                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³QD110CkDep(ExpC1,ExpC2,ExpC3)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Codigo do departamento                                    ³±±
±±³			  ³ ExpC2 - Filial do Departamento                                    ³±±
±±³ 			  ³ ExpC3 - Nome do Departamento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110CkDep(cDepto,cFilDes,cNDepto)

Local cFilCC:= xFilial("QAD")

	If Empty(cDepto)
	Return .T.
	EndIf

	If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
	cFilCC:= cFilDes
	EndIf

	If !QAD->(DbSeek(cFilCC+cDepto))
  	Help(" ",1,"QD050CCNE")	// Depto nao Existe
	Return .F.
	EndIf

cNDepto:= QA_NDEPT(cDepto,.T.,cFilCC)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110CkUsr  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Funcao de Validacao da existencia de Usuario/Pastas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110CkUsr(ExpC1,ExpC2,ExpC3,ExpC4,ExpN1,ExpC5,ExpL1)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Filial do Usuario                                         ³±±
±±³           ³ ExpC2 - Codigo do Usuario                                         ³±±
±±³           ³ ExpC3 - Nome do usuario                                           ³±±
±±³           ³ ExpC4 - Departamento do Usuario                                   ³±±
±±³           ³ ExpN1 - Tipo de distribuicao                                      ³±±
±±³           ³ ExpC5 - Nome do departamento do usuario                           ³±±
±±³           ³ ExpL1 - Valida o departamento		                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110CkUsr(cFilUsr,cCodMat,cUsu,cDepto,nTipo,cNDepto,lCkDepto)

Local cFilCC:= xFilial("QAD")
Local cFilPst:= xFilial("QDC")
Local bValid := {}

Default lCkDepto := .T.

	If lCkDepto // Considera o departamento na validação
	bValid := {|x| x[ 10 ] + x[ 3 ] + x[ 11 ] + x[ 9 ] == cFilUsr+cCodMat+cDepto+"D"}
	Else
	bValid := {|x| x[ 10 ] + x[ 3 ] + x[ 9 ] == cFilUsr+cCodMat+"D"}
	EndIf

	If nTipo == 1	// Departamento
		If FWModeAccess("QAD") == "E" ////!Empty(xFilial("QAD"))
		cFilCC:= cFilUsr
		EndIF
	
		If !QA_CHKMAT(cFilUsr,cCodMat)
		Return .F.
		EndIf
	cUsu   := QAA->QAA_NOME
	cDepto := QAA->QAA_CC
	cNDepto:= QA_NDEPT(cDepto,.T.,cFilCC)

		If Ascan(aQDG, bValid) > 0
		Help(" ",1,"QD050FJE") // Usuario ja cadastrado
		Return .F.
		EndIf
	Else	// Pasta
		If FWModeAccess("QDC") == "E" ////!Empty(xFilial("QDC"))
		cFilPst:= cFilUsr
		EndIf
		If !QDC->(DbSeek(cFilPst+cCodMat))
	 	Help(" ",1,"QD050PNE")	// Pasta nao Existe
		Return .F.
		EndIf
	EndIf

Return .T.                               

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³FCAR_DIS    ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Atualiza array de Pendencias                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ FCAR_DIS()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FCAR_DIS()

Local cTitulo:= ""
Local aUsrMat:= QA_USUARIO()
Local cMatFil:= aUsrMat[2]
Local cMatCod:= aUsrMat[3]

aPenden := {}
QD1->(DbSetOrder(3))
	If QD1->(DbSeek(cMatFil+cMatCod))
		While QD1->(!Eof()) .And. QD1->QD1_FILMAT+QD1->QD1_MAT == cMatFil+cMatCod
			If QD1->QD1_TPPEND == "I  " .And. QD1->QD1_PENDEN == "P"
			cTitulo:= Space(50)
			QDH->(DbSetOrder(1))
				If QDH->(DbSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
				cTitulo:= QDH->QDH_TITULO
				EndIf
			AADD(aPenden,{"N",QD1->QD1_DOCTO,QD1->QD1_RV,cTitulo,QD1->(Recno())})	
			EndIf
		QD1->(DbSkip())
		EndDo
	aPenden:= aSort(aPenden,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
	EndIf

QD1->(DbSetOrder(1))

Return                   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110AlQDG  ³ Autor ³ Newton R. Ghiraldelli      ³ Data ³ 23/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta a tela de alteracao de destinatarios                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110AlQDG()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110AlQDG()

Local oDlg
Local oItem
Local oItCp
Local oItdp
Local oDepto
Local oNDepto
Local oUsu
Local oCopias
Local oFilUsr
Local oCodMat
Local oPasta
Local cUsu   := Space(40)
Local cCodMat:= Space(Len(QAA->QAA_MAT))
Local cFilUsr:= xFilial("QAA")
Local cFilCC := xFilial("QAD")
Local cDepto := Space(Len(QDG->QDG_DEPTO))
Local cNDepto:= Space(30)
Local cPasta := Space(Len(QDG->QDG_CODMAN))
Local nOpc1  := 0
Local nItem  := 1
Local nItCp  := 1
Local nItdp  := 1
Local nCopias:= 1
Local nOrdQDG:= QDG->(IndexOrd())
Local aNovItens:={}
Local aCobItens:={}
Local cItCp		:=""
Local I			:=1
aRegs:= AClone(aQDGRegs[oQDH:nAt])

DEFINE MSDIALOG oDlg FROM 000,000 TO 264,377 TITLE OemToAnsi(STR0037) PIXEL // "Destinat rios - Altera‡„o"

nItem  := If(aRegs[oQDG:nAt,12] == "S",1,2)
nItdp  := If(aRegs[oQDG:nAt,9 ] == "D",1,2)
nItCp  := Val(aRegs[oQDG:nAt,13])
cFilUsr:= aRegs[oQDG:nAt,10]
cCodMat:= aRegs[oQDG:nAt,3]
cDepto := aRegs[oQDG:nAt,11]
nCopias:= Val(aRegs[oQDG:nAt,8])
cPasta := aRegs[oQDG:nAt,4]

	If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
	cFilCC:= cFilUsr
	EndIf

cNDepto:= QA_NDEPT(cDepto,.T.,cFilCC)

	If nItdp == 1
	cUsu:= QA_NUSR(cFilUsr,cCodMat,.T.)
	ElseIf nItdp == 2
	cUsu:= QDXFNANMAN(cPasta,.T.)
	EndIf

@ 003,003 TO 132,186 OF oDlg PIXEL

@ 010,006 SAY OemToAnsi(STR0012) SIZE 035,007 OF oDlg PIXEL  //"Filial"
@ 009,040 MSGET oFilUsr VAR cFilUsr SIZE 050,008 OF oDlg PIXEL
oFilUsr:lReadOnly:= .T.

	If nItdp == 1
	@ 009,094 MSGET oCodMat VAR cCodMat SIZE 055,008 OF oDlg PIXEL
	oCodMat:lReadOnly:= .T.
	ElseIf nItdp == 2
	@ 009,094 MSGET oPasta VAR cPasta SIZE 055,008 OF oDlg PIXEL
	oPasta:lReadOnly:= .T.
	EndIf

@ 009,151 RADIO oItdp VAR nItdp;
          		ITEMS OemToAnsi( STR0038 ),; // "Usu rios"
  			   		   OemToAnsi( STR0019 );  // "Pastas"
          SIZE 030,008 OF oDlg PIXEL
oItdp:lReadOnly:= .T.

@ 034,006 SAY OemToAnsi(STR0013) SIZE 035,007 OF oDlg PIXEL  //"Usu rio/Pasta"	
@ 033,040 MSGET oUsu VAR cUsu SIZE 144,008 OF oDlg PIXEL
oUsu:lReadOnly:= .T.

@ 048,006 SAY OemToAnsi(STR0014) SIZE 035,007 OF oDlg PIXEL //"Depto"
@ 047,040 MSGET oDepto VAR cDepto SIZE 070,008 OF oDlg PIXEL
oDepto:lReadOnly:= .T.

@ 062,040 MSGET oNDepto VAR cNDepto SIZE 144,008 OF oDlg PIXEL
oNDepto:lReadOnly:= .T.

@ 077,006 SAY OemToAnsi(STR0015) SIZE 035,007 OF oDlg PIXEL //"Nr. C¢pias"	
@ 076,040 MSGET oCopias VAR nCopias PICTURE '9999' SIZE 024,008 OF oDlg PIXEL;
				VALID nCopias > 0 WHEN IF(aRegs[oQDG:nAt,9 ] == "D",nItCp<>1,.T.)

	If Len (aQDG) > 0
	@ 094,006 SAY OemToAnsi(STR0016) SIZE 035,007 OF oDlg PIXEL  //"Recebe Docto"
	@ 093,045 RADIO oItem VAR nItem;
						ITEMS	OemToAnsi( STR0020 ),; // "Sim"
								OemToAnsi( STR0021 );  // "N„o"
					3D SIZE 025,007 OF oDlg PIXEL
	EndIf

	IF ExistBlock("QDOAP21")
		If nItdp == 1
		aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{1,OemToAnsi(STR0022)},{2,OemToAnsi(STR0023)},{3,OemToAnsi(STR0024)},{4,OemToAnsi(STR0025)}})	
		ElseIf nItdp == 2
		aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{2,OemToAnsi(STR0023)},{4,OemToAnsi(STR0025)}})	
		nItCp:= IF(nItCp<=2,nItCp / 2,nItCp-2)		
		Endif
	aCobItens:={}
		FOR I:=1 TO LEN(aNovItens)
		AADD(aCobItens,aNovItens[I,2])
		NEXT
	cItCp:= aNovItens[nItCp,2]
	
	@ 077,095 SAY OemToAnsi(STR0017) SIZE 035,007 OF oDlg PIXEL // "Tipo Copias"
	@ 077,125 	COMBOBOX oItCp VAR cItCp ;
					ITEMS aCobItens ;
					SIZE 45,10 ON CHANGE nItCp:=oItCp:nat  OF oDlg PIXEL    
	Else
		If nItdp == 1
		@ 077,095 SAY OemToAnsi(STR0017) SIZE 035,007 OF oDlg PIXEL //"Tipo C¢pia"	
	    @ 077,125 RADIO oItCp VAR nItCp;
					ITEMS	OemToAnsi(STR0022),; // "Eletr“nica"
							OemToAnsi(STR0023),; // "Papel"
							OemToAnsi(STR0024),; // "Ambos"
							OemToAnsi(STR0025);  // "Nao Recebe"
					3D SIZE 050,007 OF oDlg PIXEL
		ElseIf nItdp == 2
		nItCp:= nItCp / 2
		@ 077,095 SAY OemToAnsi(STR0017) SIZE 035,007 OF oDlg PIXEL //"Tipo C¢pia"
		@ 077,125 RADIO oItCp VAR nItCp;
						ITEMS	OemToAnsi(STR0023),; // "Papel"
								OemToAnsi(STR0025);  // "Nao Recebe"
						3D SIZE 050,007 OF oDlg PIXEL
		Endif

	oItCp:BCHANGE:={|| IF(aRegs[oQDG:nAt,9 ]=="D",(nCopias:=IF(nItCp==1,nCopias:=1,nCopias), oCopias:Refresh(),oCopias:SetFocus()),"") }
	EndIf

DEFINE SBUTTON FROM 118,125 TYPE 1 ENABLE OF oDlg ACTION	(nOpc1:=1,oDlg:End())
DEFINE SBUTTON FROM 118,155 TYPE 2 ENABLE OF oDlg ACTION	oDlg:End()

ACTIVATE	MSDIALOG oDlg CENTERED

	If nOpc1 = 1
	aRegs[oQDG:nAt, 8]:= Transform( nCopias, "@E 9,999" )
	aRegs[oQDG:nAt,12]:= If( nItem == 1, "S", "N" )
		If nItdp == 2
			IF ExistBlock("QDOAP21")
	    	nItCp+= IF( nItCp==1 ,1 ,2 )      
			ELSE
			nItCp := nItCp * 2
			Endif
		EndIf
	aRegs[oQDG:nAt,13]:= Str( nItCp, 1 )
	aRegs[oQDG:nAt, 7]:= QDXFNDsDtr( Str( nItCp, 1 ) )
	aQDGRegs[oQDH:nAt]:= AClone( aRegs )
	aQDG:= aClone(aRegs)
	oQDG:SetArray(aQDG)
	oQDG:bLine:= bQDGLine
	oQDG:Refresh()
	aQDH[oQDH:nAt,1]:= AScan( aQDG, { |x| x[ 1 ] == .t. } ) > 0
	oQDH:SetArray(aQDH)
	oQDH:bLine:= bQDHLine
	oQDH:Refresh()
	QDG->(DbSetOrder(3))
		If QDG->(DbSeek(aRegs[oQDG:nAt,14 ]+aRegs[oQDG:nAt,15]+aRegs[oQDG:nAt,16]+cFilUsr+cDepto+cCodMat+cPasta))
		Reclock("QDG",.F.)
		QDG->QDG_NCOP  := Val(aRegs[oQDG:nAt, 8])
		QDG->QDG_TPRCBT:= aRegs[oQDG:nAt,13]
		QDG->QDG_RECEB := aRegs[oQDG:nAt,12]
		QDG->(MsUnlock())
		FKCOMMIT()
		EndIf
	QDG->(DbSetOrder(nOrdQDG))   
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110IncUsr ³ Autor ³ Eduardo de Souza           ³ Data ³ 18/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz a inclusao de Usuario Destino                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110IncUsr(ExpA1)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os Destinatarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110IncUsr(aRegs)

Local oDlg
Local oItem
Local oItCp
Local oDepto
Local oUsuario
Local oCopias
Local oMatUsr
Local cDepto := Space(Len(QDG->QDG_DEPTO))
Local cUsu   := Space(40)
Local cNDepto:= Space(30)
Local cFilUsr:= xFilial("QAA")
Local cFilCC := xFilial("QAD")
Local nOpc1  := 0
Local nItem  := 1
Local nItCp  := 1
Local nCopias:= 1
Local aReg   := {}
Local cMatUsr:= Space(TamSx3("QAA_MAT")[1])
Local nItdp  := 1
Local nPos	 := 0
Local I		 := 0
Local nOrdQDG:= QDG->(IndexOrd())

cFilMat:= cFilAnt

DEFINE MSDIALOG oDlg FROM 000,000 TO 260,377 TITLE OemToAnsi(STR0011) PIXEL // "Usuarios - Inclus„o"

@ 003,003 TO 125,190 OF oDlg PIXEL

@ 010,006 SAY OemToAnsi(STR0012) SIZE 055,007 OF oDlg PIXEL //"Filial-C¢digo"
@ 009,040 MSGET cFilUsr	PICTURE '@!' F3 "SM0" SIZE 055,008 OF oDlg PIXEL;
				VALID QA_CHKFIL(cFilUsr,@cFilMat)

@ 009,100 MSGET oMatUsr VAR cMatUsr PICTURE '@!' F3 "QDE" SIZE 055,008 OF oDlg PIXEL;
				VALID If(QD110CkUsr(cFilUsr,cMatUsr,@cUsu,@cDepto,nItdp,@cNDepto,.F.),(oNDepto:Refresh(),oUsuario:Refresh(),oDepto:Refresh()),.F.)

@ 024,006 SAY OemToAnsi(STR0039) SIZE 035,007 OF oDlg PIXEL //"Usuario"
@ 023,040 MSGET oUsuario VAR cUsu PICTURE	'@!' SIZE 144,008 OF oDlg PIXEL
oUsuario:lReadOnly:= .T.

@ 038,006 SAY OemToAnsi(STR0014) SIZE 035,007 OF oDlg PIXEL //"Depto"
@ 037,040 MSGET oDepto VAR cDepto PICTURE	'@!' SIZE 070,008 OF oDlg PIXEL
oDepto:lReadOnly:= .T.

@ 052,040 MSGET oNDepto VAR cNDepto PICTURE '@!' SIZE 144,008 OF oDlg PIXEL
oNDepto:lReadOnly:= .T.

@ 067,006 SAY OemToAnsi(STR0015) SIZE 35,07 OF oDlg PIXEL //"Nr C¢pias"
@ 066,040 MSGET oCopias VAR nCopias PICTURE '9999' SIZE 024,008 OF oDlg PIXEL ;
				VALID nCopias > 0 WHEN IF(aRegs[oQDG:nAt,9 ] == "D",nItCp<>1,.T.)

@ 084,006 SAY OemToAnsi(STR0016) SIZE 035,007 OF oDlg PIXEL //"Recebe Docto"
@ 083,045 RADIO oItem VAR nItem ;
				ITEMS OemToAnsi(STR0020),; // "Sim"
				      OemToAnsi(STR0021);  // "N„o"
			 3D SIZE	025,007 OF oDlg PIXEL;

	IF ExistBlock("QDOAP21")
	aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{1,OemToAnsi(STR0022)},{2,OemToAnsi(STR0023)},{3,OemToAnsi(STR0024)},{4,OemToAnsi(STR0025)}})	
	aCobItens:={}
		FOR I:=1 TO LEN(aNovItens)
		AADD(aCobItens,aNovItens[I,2])
		NEXT
	cItCp:= aNovItens[nItCp,2]
	
	@ 067,095 SAY OemToAnsi(STR0017) SIZE 035,007 OF oDlg PIXEL // "Tipo Copias"
	@ 067,125 	COMBOBOX oItCp VAR cItCp ;
	ITEMS aCobItens ;
	SIZE 45,10 ON CHANGE nItCp:=oItCp:nat  OF oDlg PIXEL
	Else
	@ 067,095 SAY OemToAnsi(STR0017) SIZE 035,007 OF oDlg PIXEL //"Tipo C¢pias"
	@ 067,125 RADIO oItCp VAR nItCp ;
				ITEMS OemToAnsi(STR0022),; // "&Eletronica"
						OemToAnsi(STR0023),; // "&Papel"
						OemToAnsi(STR0024),; // "&Ambos"
						OemToAnsi(STR0025);  // "Nao &Recebe"
				3D SIZE 050,007 OF oDlg PIXEL
	oItCp:BCHANGE:={|| IF(aRegs[oQDG:nAt,9 ]=="D",(nCopias:=IF(nItCp==1,nCopias:=1,nCopias), oCopias:Refresh(),oCopias:SetFocus()),"") }                          
	Endif

DEFINE SBUTTON FROM 109,130 TYPE 1 ENABLE OF oDlg;
			ACTION (If(QD110VldDest(aQDH,oQDH,cFilUsr,cDepto,cMatUsr),(nOpc1:= 1,oDlg:End()),.F.))
			
DEFINE SBUTTON FROM 109,160 TYPE 2 ENABLE	OF	oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc1 = 1 .And. !Empty(cMatUsr)
		If FWModeAccess("QAD") == "E" //!Empty(xFilial("QAD"))
		cFilCC:= cFilUsr
		EndIf
	nPos := Ascan(aQDG,{|x| x[14] + x[15] + x[16] + x[ 10 ] + x[ 3 ] + x[ 11 ] + x[ 9 ] ==;
			aQDH[oQDH:nAt,6]+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4]+cFilUsr+cMatUsr+cDepto+"D"})
	
	aReg:= Array(17)			
	
	aReg[ 1]:= .T.
	aReg[ 2]:= QA_NDEPT(cDepto,.T.,cFilCC)
	aReg[ 3]:= cMatUsr
	aReg[ 4]:= Space(15)
	aReg[ 5]:= QA_NUSR(cFilUsr,cMatUsr,.T.)
	aReg[ 7]:= QDXFNDsDtr(Str(nItCp,1))
	aReg[ 8]:= Transform(nCopias, "@E 9,999")
	aReg[ 9]:= If(nItdp == 1,"D","P")
	aReg[10]:= cFilUsr
	aReg[11]:= cDepto
	aReg[12]:= "S"
	aReg[13]:= Str(nItCp, 1)
	aReg[14]:= aQDH[oQDH:nAt,6]
	aReg[15]:= aQDH[oQDH:nAt,3]
	aReg[16]:= aQDH[oQDH:nAt,4]
		If nPos > 0
		aQDG[nPos] := AClone(aReg)
		Else
		Aadd(aQDG,aReg)
		Endif
	aQDG:= ASort(aQDG,,, { |x, y| x[10]+x[11]+x[2]+x[4]+x[5] < y[10]+y[11]+y[2]+y[4]+y[5]})
	aQDGRegs[oQDH:nAt]:= AClone(aQDG)
	oQDG:SetArray(aQDG)
	oQDG:bLine:= bQDGLine
	oQDG:Refresh()
	aQDH[oQDH:nAt,1]:= ( AScan( aQDG, { |x| x[ 1 ] == .t. } ) > 0 )
	oQDH:SetArray(aQDH)
	oQDH:bLine := bQDHLine
	oQDH:Refresh()
	
		Begin Transaction
	QDG->(DbSetOrder(1))
			If QDG->(DbSeek(aQDH[oQDH:nAt,6]+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4]+aReg[ 9]+cFilUsr+cDepto+cMatUsr))
		Reclock("QDG", .F. )
			Else
		Reclock("QDG", .T. )		
			Endif
	QDG->QDG_FILIAL:= aReg[14]
	QDG->QDG_DOCTO := aReg[15]
	QDG->QDG_RV    := aReg[16]
	QDG->QDG_FILMAT:= aReg[10]
	QDG->QDG_DEPTO := aReg[11]
	QDG->QDG_MAT   := aReg[ 3]
	QDG->QDG_NCOP  := Val(aReg[8])
	QDG->QDG_TPRCBT:= aReg[13]
	QDG->QDG_RECEB := aReg[12]
	QDG->QDG_TIPO  := aReg[ 9]
	QDG->QDG_SIT   := " "
	QDG->(MsUnlock())
	FKCOMMIT()
	
			If !QDJ->(DbSeek(aReg[14]+aReg[15]+aReg[16]+aReg[9]+aReg[10]+aReg[11]))
		Reclock("QDJ", .T. )
		QDJ->QDJ_FILIAL:= aReg[14]
		QDJ->QDJ_DOCTO := aReg[15]
		QDJ->QDJ_RV    := aReg[16]
		QDJ->QDJ_FILMAT:= aReg[10]
		QDJ->QDJ_DEPTO := aReg[11]
		QDJ->QDJ_TIPO  := aReg[ 9]
		QDJ->(MsUnlock())
		FKCOMMIT()
			EndIf
		End Transaction
	EndIf
	
QDG->(DbSetOrder(nOrdQDG))	

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110VldDest³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Verifica se destinatario esta cadastrado                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110VldDest()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo dados do documento                         ³±±
±±³           ³ ExpO1 - Objeto ListBox Documentos                                 ³±±
±±³           ³ ExpC1 - Filial do Destinatario                                    ³±±
±±³           ³ ExpC2 - Departamento do Destinatario                              ³±±
±±³           ³ ExpC3 - Matricula do Destinatario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110VldDest(aQDH,oQDH,cFilUsr,cDepto,cMatUsr)

Local lRet   := .T.
Local nOrdQDG:= QDG->(IndexOrd())

QDG->(DbSetOrder(3))

	If 	QDG->(DbSeek(aQDH[oQDH:nAt,6]+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4]+cFilUsr+cDepto+cMatUsr)) .And.;
	Ascan(aQDG,{|x| x[14] + x[15] + x[16] + x[ 10 ] + x[ 3 ] + x[ 11 ] + x[ 9 ] ==;
					aQDH[oQDH:nAt,6]+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4]+cFilUsr+cMatUsr+cDepto+"D"}) > 0
	MsgAlert(OemToAnsi(STR0040),OemtoAnsi(STR0027)) //"Este destino j  foi cadastrado" ### "Aten‡„o"
	lRet:= .F.
		EndIf

QDG->(DbSetOrder(nOrdQDG))

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ QD110CarDep³ Autor ³ Eduardo de Souza           ³ Data ³ 11/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Carrega Departamentos para Selecao no Cadastro de Usuarios/Pastas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QD110CarDep(ExpA1)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro  ³ ExpA1 - Array Contendo Departamentos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110CarDep(aDeptos)

QAD->(DbSetOrder(1))
QAD->(Dbgotop())
QAD->(DbSeek(iif(FWModeAccess("QAD")=="C",xFilial("QAD"),'')))
	While QAD->(!Eof())
	Aadd(aDeptos,{"N",QAD->QAD_FILIAL,QAD->QAD_CUSTO,QAD->QAD_DESC,"N"})
	QAD->(DbSkip())
	EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD110IncPst³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz a inclusao de Destinatario tipo pasta                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110IncPst()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os Destinatarios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110IncPst(aRegs,aDeptos)

Local oDeptos
Local oDlg
Local oBtn1
Local oBtn2
Local oFilPst
Local oCodPst
Local oDescr
Local oItCp
Local oItem
Local oCopias
Local oOk    := LoadBitmap( GetResources(), "ENABLE" )
Local oNo    := LoadBitmap( GetResources(), "LBNO" )
Local cCodPst:= Space(TamSX3("QDC_CODMAN")[1])
Local cDescr := Space(TamSX3("QDC_DESC")[1])
Local nItCp  := 1
Local nItem  := 1
Local nCopias:= 1
Local bQADLine1
Local bQADLine2  
Local aNovItens:={}
Local aCobItens:={}
Local cItCp	   :=""
Local I			:=1
Local lRet := .T.
Private cFilPst:= xFilial("QDC")
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0011) FROM 000,000 TO 425,425 OF oMainWnd PIXEL //"Destinatarios - Inclusao"

@ 034,003 TO 103,210 OF oDlg PIXEL

	If FWModeAccess("QDC") == "E" //!Empty(cFilPst)
	@ 038,006 SAY OemToAnsi(STR0012) SIZE 035,007 OF oDlg PIXEL //"Filial-C¢digo"
	@ 037,040 MSGET oFilPst VAR cFilPst PICTURE '@!' F3 "SM0" SIZE 035,008 OF oDlg PIXEL;
					VALID QA_CHKFIL(cFilPst)

	@ 037,091 MSGET oCodPst VAR cCodPst PICTURE '@!' F3 "QDC1" SIZE 055,008 OF oDlg PIXEL;
					VALID If(QA_CHKMAN(cFilPst,cCodPst),(cDescr:= QDC->QDC_DESC,;
							QD110PtxDep(@aDeptos,cFilPst,cCodPst),oDescr:Refresh(),oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh()),;
							(oDescr:Refresh(),.F.))
							
	@ 038,120 SAY OemToAnsi(STR0015) SIZE 035,007 OF oDlg PIXEL //"Nr. C¢pias"	
	@ 037,154 MSGET oCopias VAR nCopias PICTURE '9999' SIZE 024,008 OF oDlg PIXEL;
					VALID nCopias > 0
	
	Else
	@ 038,006 SAY OemToAnsi(STR0019) SIZE 035,007 OF oDlg PIXEL //"Pastas"
	@ 037,040 MSGET oCodPst VAR cCodPst PICTURE '@!' F3 "QDC" SIZE 055,008 OF oDlg PIXEL;
					VALID If(QA_CHKMAN(cFilPst,cCodPst),(cDescr:= QDC->QDC_DESC,;
							QD110PtxDep(@aDeptos,cFilPst,cCodPst),oDescr:Refresh(),oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh()),;
							(oDescr:Refresh(),.F.))
							
	@ 038,106 SAY OemToAnsi(STR0015) SIZE 035,007 OF oDlg PIXEL //"Nr. C¢pias"	
	@ 037,140 MSGET oCopias VAR nCopias PICTURE '9999' SIZE 024,008 OF oDlg PIXEL;
					VALID nCopias > 0
								
	EndIf


@ 061,006 SAY OemToAnsi(STR0047) SIZE 035,007 OF oDlg PIXEL //"Descricao"
@ 060,040 MSGET oDescr VAR cDescr PICTURE	 '@!' SIZE 144,008 OF oDlg PIXEL
oDescr:lReadOnly:= .T.

@ 074,006 SAY OemToAnsi(STR0016) SIZE 035,007 OF oDlg PIXEL //"Recebe Docto"
@ 073,045 RADIO oItem VAR nItem ;
				ITEMS OemToAnsi(STR0020),; // "Sim"
						OemToAnsi(STR0021);  // "N„o"
			 3D SIZE	025,007 OF oDlg PIXEL;

	IF ExistBlock("QDOAP21")
	aNovItens:=ExecBlock("QDOAP21",.F.,.F.,{{2,OemToAnsi(STR0023)},{4,OemToAnsi(STR0025)}})
	aCobItens:={}
		FOR I:=1 TO LEN(aNovItens)
		AADD(aCobItens,aNovItens[I,2])
		NEXT
	cItCp:= aNovItens[nItCp,2]
	
	@ 074,095 SAY OemToAnsi(STR0017) SIZE 035,007 OF oDlg PIXEL // "Tipo Copias"
	@ 073,125 	COMBOBOX oItCp VAR cItCp ;
					ITEMS aCobItens ;
					SIZE 45,10 ON CHANGE nItCp:=oItCp:nat  OF oDlg PIXEL    
	ELSE
	@ 074,095 SAY OemToAnsi(STR0017) SIZE 035,007 OF oDlg PIXEL //"Tipo C¢pias"
	@ 073,125 RADIO oItCp VAR nItCp;
					ITEMS	OemToAnsi(STR0023),; // "Papel"
						OemToAnsi(STR0025);  // "N„o Recebe"
					3D SIZE 50,07 OF oDlg PIXEL
	Endif

@ 102,003 TO 174,210 LABEL OemToAnsi(STR0045) OF oDlg PIXEL //"Departamentos"
@ 110,007 LISTBOX oDeptos FIELDS;
             HEADER  " ", ;
                     OemToAnsi(STR0046),; // "Fil/Cod" 
                     OemToAnsi(STR0047) ; // "Descricao"
             SIZE 200,060 OF oDlg PIXEL;
             ON DBLCLICK QDO110Cl(oDeptos,@aDeptos)

bQADLine1 := {|| {If(aDeptos[oDeptos:nAt,1] == "S",oOk, oNo),aDeptos[oDeptos:nAt,2]+" - "+aDeptos[oDeptos:nAt,3],aDeptos[oDeptos:nAt,4]}}
bQADLine2 := {|| {oNo,Space(18),Space(25) }}
oDeptos:SetArray(aDeptos)
oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2)
oDeptos:SetFocus(.t.)
oDeptos:Refresh()

@ 176,006 BUTTON oBtn1 PROMPT OemToAnsi(STR0049) SIZE 067,011 OF oDlg PIXEL; //"Marcar/Desmarcar todos"
				ACTION (QD110MRDep(@aDeptos),oDeptos:SetArray(aDeptos),oDeptos:bLine:= If(Len(aDeptos)>0,bQADLine1,bQADLine2),oDeptos:Refresh())
				
@ 176,075 BUTTON oBtn2 PROMPT OemToAnsi(STR0048) SIZE 050,011 OF oDlg PIXEL; //"Pesquisa Depto"
				ACTION QD110PesqDep(@oDeptos,aDeptos,1)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lRet:=QD110VPt(cCodPst),If (lRet,(QD110GrPst(aDeptos,nItCp,cFilPst,cCodPst,nCopias),oDlg:End()),)},{|| oDlg:End()}) // "Atualizando Destinatarios..." ### "Aguarde..."

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD110GrPst ³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Faz a gravacao do Destinatario tipo pasta                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110GrPst(ExpA1,ExpN1,ExpC1,ExpC2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os Destinatarios                           ³±±
±±³           ³ ExpN1 - Numero de Copias                                          ³±±
±±³           ³ ExpC1 - Filial da Pasta                                           ³±±
±±³           ³ ExpC2 - Codigo da Pasta                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110GrPst(aDeptos,nItCp,cFilPst,cCodPst,nCopias)

Local nCnt:= 0
Local cFilRes:= ""

Private cCodMat:= Space(TamSx3("QAA_MAT")[1])

CursorWait()
aDeptos:= aSort(aDeptos,,,{ |x,y| x[1] > y[1] } ) 
	IF ExistBlock("QDOAP21")
   	nItCp+= IF( nItCp==1 ,1 ,2 )      
	ELSE
	nItCp := nItCp * 2
	Endif
	For nCnt:= 1 To Len(aDeptos)
		If aDeptos[nCnt,1] == "S"
			If QAD->(DbSeek(aDeptos[nCnt,2]+aDeptos[nCnt,3]))
			cFilRes:= QAD->QAD_FILMAT
			cCodMat:= QAD->QAD_MAT
			CursorArrow()
				While Empty(cCodMat)
				cCodMat:= Qd053InQDG(cCodPst,aDeptos[nCnt,2],aDeptos[nCnt,3],cFilRes)
					If cCodMat == NIL
					cCodMat:= Space(10)
					EndIf
				EndDo
			CursorWait()
			EndIf
		QDG->(DbSetOrder(3))
			If !QDG->(DbSeek(aQDH[oQDH:nAt,6]+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4]+cFilRes+aDeptos[nCnt,3]+cCodMat+cCodPst))

			aReg:= Array(17)			
			
			aReg[ 1]:= .T.
			aReg[ 2]:= aDeptos[nCnt,4]
			aReg[ 3]:= cCodMat
			aReg[ 4]:= cCodPst
			aReg[ 5]:= QA_NUSR(cFilRes,cCodMat,.T.)
			aReg[ 6]:= QDXFNANMAN(cCodPst,.T.,cFilPst)
			aReg[ 7]:= QDXFNDsDtr(Str(nItCp,1))
			aReg[ 8]:= Transform(nCopias, "@E 9,999")
			aReg[ 9]:= "P"
			aReg[10]:= cFilRes //aDeptos[nCnt,2]
			aReg[11]:= aDeptos[nCnt,3]
			aReg[12]:= "S"
			aReg[13]:= Str(nItCp,1)
			aReg[14]:= aQDH[oQDH:nAt,6]
			aReg[15]:= aQDH[oQDH:nAt,3]
			aReg[16]:= aQDH[oQDH:nAt,4]

				If FWModeAccess("QDC") == "E" //!Empty(xFilial("QDC"))
				cFilPst:= QDG->QDG_FILIAL
				EndIf
	    	aReg[17]:= Posicione("QDC",1,cFilPst+QDG->QDG_CODMAN,"QDC_STATUS")
		    			
			Aadd(aQDG,aReg)
			aQDG:= ASort(aQDG,,, { |x, y| x[10]+x[11]+x[2]+x[4]+x[5] < y[10]+y[11]+y[2]+y[4]+y[5]})
			aQDGRegs[oQDH:nAt]:= AClone(aQDG)
				
				Begin Transaction
			Reclock("QDG",.T.)
			QDG->QDG_FILIAL:= aReg[14]
			QDG->QDG_DOCTO := aReg[15]
			QDG->QDG_RV    := aReg[16]
			QDG->QDG_FILMAT:= aReg[10]
			QDG->QDG_DEPTO := aReg[11]
			QDG->QDG_MAT   := aReg[ 3]
			QDG->QDG_NCOP  := Val(aReg[8])
			QDG->QDG_TPRCBT:= aReg[13]
			QDG->QDG_RECEB := aReg[12]
			QDG->QDG_TIPO  := aReg[ 9]
			QDG->QDG_CODMAN:= aReg[ 4]
			QDG->(MsUnlock())
			FKCOMMIT()			
					If !QDJ->(DbSeek(aReg[14]+aReg[15]+aReg[16]+aReg[9]+aReg[10]+aReg[11]))
				Reclock("QDJ", .T.)
				QDJ->QDJ_FILIAL:= aReg[14]
				QDJ->QDJ_DOCTO := aReg[15]
				QDJ->QDJ_RV    := aReg[16]
				QDJ->QDJ_FILMAT:= aReg[10]
				QDJ->QDJ_DEPTO := aReg[11]
				QDJ->QDJ_TIPO  := aReg[ 9]
				QDJ->(MsUnlock())
				FKCOMMIT()
					EndIf
				End Transaction
			EndIf
		Else
		Exit
		EndIf
	Next nCnt

oQDG:SetArray(aQDG)
oQDG:bLine := bQDGLine
oQDG:Refresh()
aQDH[oQDH:nAt,1]:= (AScan(aQDG,{|x| x[1] == .T.}) > 0)
oQDH:SetArray(aQDH)
oQDH:bLine:= bQDHLine
oQDH:Refresh()
aDeptos:= aSort(aDeptos,,,{ |x,y| x[2]+x[3] < y[2]+y[3] } ) 

CursorArrow()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³QD110PesqDep³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Pesquisa Departamento                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110PesqDep(ExpO1,ExpA1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 - Objeto Departamentos                                      ³±±
±±³           ³ ExpA1 - Array contendo os departamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110PesqDep(oDeptos,aDeptos,nTpPesq)

Local oDlg2
Local oFilCC
Local oCodDep
Local cFilCC := xFilial("QAD")
Local cCodDep:= Space(TamSx3("QAD_CUSTO")[1])
Local cDesDep:= Space(25)
Local nOpcao1:= 0
Local nPos   := 0
Local nPosFil:= If(nTpPesq == 1,2,10)
Local nPosDep:= If(nTpPesq == 1,3,11)

DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0048) FROM 000,000 TO 110,310 OF oMainWnd PIXEL //"Pesquisa Depto"

@ 003,003 TO 040,153 LABEL OemToAnsi(STR0045) OF oDlg2 PIXEL //"Departamento"

@ 010,006 MSGET oFilCC VAR cFilCC PICTURE "@!" F3 "SM0" SIZE 055,008 OF oDlg2 PIXEL;
          VALID QA_CHKFIL(cFilCC,@cFilDep) WHEN FWModeAccess("QAD")=="E" //! Empty(cFilCC)

@ 010,070 MSGET oCodDep VAR cCodDep PICTURE '@!' F3 "QDD" SIZE 044,008 OF oDlg2 PIXEL;
				VALID If(Empty(cDesDep:= QA_NDEPT(cCodDep,.T.,cFilCC)),;
						(Help(" ",1,"QD050CCNE"),oDesDep:Refresh(),.F.),; // "Depto nao existe"
						(oDesDep:Refresh(),.T.))

@ 025,006 MSGET oDesDep VAR cDesDep SIZE 100,008 OF oDlg2 PIXEL
oDesDep:lReadOnly:= .T.

DEFINE SBUTTON FROM 041,095 TYPE 1 ENABLE OF oDlg2;
			ACTION (nOpcao1:= 1,oDlg2:End())

DEFINE SBUTTON FROM 041,125 TYPE 2 ENABLE OF oDlg2;
			ACTION oDlg2:End()

ACTIVATE MSDIALOG oDlg2 CENTERED	

	If nOpcao1 == 1
		If If 	(FWModeAccess("QAD") == "C",;
		nPos:= aScan(aDeptos,{|x| x[nPosDep] == cCodDep} ),;
		nPos:= aScan(aDeptos,{|x| x[nPosFil]+x[nPosDep] == cFilCC+cCodDep} )) > 0
		oDeptos:nAt:= nPos
		oDeptos:Refresh()
			EndIf
		If nPos == 0 .And. nTpPesq == 2
		Help(" ",1,"QD053DEPNE") //"Departamento Destino nao cadastrado neste Documento"
		EndIf
	EndIf
 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o     ³ QDO110Cl   ³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o  ³ Tratar o click da pergunte                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ QDO110Cl(ExpO1,ExpA1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 - Objeto Depto                                              ³±±
±±³           ³ ExpA1 - Array contendo Departamentos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDO110Cl(oDeptos,aDeptos)

	If aDeptos[oDeptos:nAt,1] == "S"
		If aDeptos[oDeptos:nAt,5] <> "S"
		aDeptos[oDeptos:nAt,1]:= "N"
		Else
		Help(" ",1,"QD110NEXC") // "Destino ja Cadastrado, para exclui-lo utilize o botao - Exclui Destinatarios"
		EndIf
	Else
	aDeptos[oDeptos:nAt,1]:= "S"
	EndIf
oDeptos:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD110MRDep ³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Marca/Desmarca os Departamentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110MRDep(ExpA1)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os departamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110MRDep(aDeptos)

Local nCnt      := 0
Local nC        := 0

	If Len(aDeptos) > 0
	nC:= Ascan(aDeptos,{ |X| x[1]+x[5] == "S"+"N" } )
		For nCnt:= 1 to Len(aDeptos)
			If nC <> 0
				If aDeptos[nCnt,5] <> "S"
				aDeptos[nCnt,1]:= "N"
				EndIf
			Else
			aDeptos[nCnt,1]:= "S"
			EndIf
		Next nCnt
	EndIf

Return aDeptos

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD110PtxDep³ Autor ³ Eduardo de Souza           ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Marca Departamentos de acordo com amarracao do cadastro de Pastas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD110PtxDep(ExpA1)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo os departamentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110PtxDep(aDeptos,cFilPst,cCodPst)

Local nCnt:= 0
Local nOrdQDG:= QDG->(IndexOrd())

	For nCnt:= 1 To Len(aDeptos)
	aDeptos[nCnt,1]:= "N"
	Next nCnt

QDG->(DbSetOrder(5))	
	If QDG->(DbSeek(aQDH[oQDH:nAt,6]+cCodPst+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4]))
		While QDG->(!Eof()) .And. QDG->QDG_FILIAL+QDG->QDG_CODMAN+QDG->QDG_DOCTO+QDG->QDG_RV == aQDH[oQDH:nAt,6]+cCodPst+aQDH[oQDH:nAt,3]+aQDH[oQDH:nAt,4]
			If QDG->QDG_RECEB == "S"
				If (nPos:= aScan(aDeptos,{|x| x[2]+x[3] == QDG->QDG_FILMAT+QDG->QDG_DEPTO})) > 0
				aDeptos[nPos,1]:= "S"
				aDeptos[nPos,5]:= "S"
				Endif
			Endif
		QDG->(DbSkip())
		EndDo
	Else
	QDT->(DbSetOrder(2))
		If QDT->(DbSeek(cFilPst+cCodPst))
			While QDT->(!Eof()) .And. QDT->QDT_FILCOD+QDT->QDT_CODMAN == cFilPst+cCodPst
				If (nPos:= aScan(aDeptos,{|x| x[2]+x[3] == QDT->QDT_FILDEP+QDT->QDT_DEPTO})) > 0
				aDeptos[nPos,1]:= "S"
				EndIf
			QDT->(DbSkip())
			EndDo
		EndIf
	QDT->(DbSetOrder(1))	
	EndIf

QDG->(DbSetOrder(nOrdQDG))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD110GrDev ³ Autor ³ Eduardo de Souza ³ Data ³ 23/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Gera Pendencia de Devolucao de Revisao Anterior         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD110GrDev(ExpC1,ExpC2,ExpX3,ExpX4,ExpC5,ExpN1)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros  ³ ExpC1 - Filial do Usuario                               ³±±
±±³             ³ ExpC2 - Matricula do Usuario                            ³±±
±±³             ³ ExpC3 - Departamento do Usuario                         ³±±
±±³             ³ ExpC4 - Documento                                       ³±±
±±³             ³ ExpC5 - Revisao do Documento                            ³±±
±±³             ³ ExpN1 - Numero de Copias                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA110                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110GrDev(cFilUsr,cMatUsr,cDepUsr,cDocto,cRv,nCopias)

QDU->(DbSetOrder(1))
	If QDU->(DbSeek(xFilial("QDU")+cDocto+cRv+cFilUsr+cMatUsr))
	nCopias:= QDU->QDU_NCOP + nCopias
	RecLock("QDU",.F.)
	QDU->QDU_NCOP  := nCopias
	QDU->QDU_COPPEN:= nCopias
	QDU->(MsUnlock())
	FKCOMMIT()
	Else
	RecLock("QDU",.T.)
	QDU->QDU_FILIAL:= xFilial("QDU")
	QDU->QDU_DTGERA:= dDataBase
	QDU->QDU_HRGERA:= SubStr(Time(),1,5)
	QDU->QDU_PENDEN:= "P"
	QDU->QDU_FILMAT:= cFilUsr
	QDU->QDU_MAT   := cMatUsr
	QDU->QDU_DEPTO := cDepUsr
	QDU->QDU_DOCTO := cDocto
	QDU->QDU_RV    := cRv
	QDU->QDU_NCOP  := nCopias
	QDU->QDU_COPPEN:= nCopias
	QDU->(MsUnlock())
	FKCOMMIT()
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QD110ImpP  ³ Autor ³ Eduardo de Souza ³ Data ³ 08/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Verifica se ha dados para impressao do protocolo.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QD110ImpP()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOA110                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD110ImpP(cDocFil,cDocCod,cDocRv)

Local cFiltro	:= ""
Local cTipPro  := GETMV("MV_QDOTPPR") // Parametro para impressao de somente copias em papel ou nao

cFiltro:= 'QD1->QD1_FILIAL == "'+cDocFil+ '".And. '
cFiltro+= 'QD1->QD1_DOCTO == "' +cDocCod+ '".And. '
cFiltro+= 'QD1->QD1_RV == "'    +cDocRv + '".And. '
cFiltro+= 'QD1->QD1_TPPEND == "L  "'

	If cTipPro == "S"
	cFiltro+= '.And. QD1->QD1_TPDIST $ "2,3"'
	Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada Para tratamento do filtro com outras tipos de Copias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                    
		IF EXISTBLOCK("QDOAP25")
		cFiltro+= '.And. QD1->QD1_TPDIST $ "'+EXECBLOCK("QDOAP25",.F.,.F.)+'"'	    
		ENDIF
	Endif

DbSelectArea("QD1")
DbSetOrder(1)
Set Filter To &(cFiltro)
DbGotop()

	If QDH->(DbSeek(cDocFil+cDocCod+cDocRv))
		If QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
			While QD1->(!Eof()) .And. QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV == cDocFil+cDocCod+cDocRv
			Return .T.
			EndDo
		EndIf
	EndIf

Set Filter To

Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD110Legen ³ Autor ³ Telso Carneiro       ³ Data ³15/06/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria uma janela contendo a legenda da ListBox              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD110Legen                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QD110Legen()

Local aLegenda := { 	{'BR_AZUL'   , OemtoAnsi(STR0065) },; //"Elaboracao com Distribuicao Pendente"
						{'BR_PRETO'  , OemtoAnsi(STR0066)} }   //"Documento cancelado"

BrwLegenda(cCadastro,STR0063,aLegenda) 	  //"Legenda"

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QD110VPt ºAutor  ³Denis Martins	     º Data ³  08/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para verificar o preenchimento da pasta quando o des º±±
±±º          ³tino for Pasta.											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOA110                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QD110VPt(cCoPat)

	Local lRetorno := .T.

	If Empty(cCoPat)
		MessageDlg(STR0070) //Escolha uma pasta para relacionar ao departamento.
		lRetorno := .F.
	Endif

Return lRetorno
