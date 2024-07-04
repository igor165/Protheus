#INCLUDE "PROTHEUS.CH"
#INCLUDE "QPPA140.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ QPPA140  ณ Autor ณ Eduardo de Souza      ณ Data ณ 24.07.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณComprometimento da Equipe com a Viabilidade                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ QPPA140()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAPPAP                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Robson Ramiroณ06/09/02ณxMETA ณ Troca da QA_CVKEY por GetSXENum        ณฑฑ
ฑฑณ Robson Ramiroณ15/12/03ณ META ณ Compatibilizacoes/Melhorias 811        ณฑฑ
ฑฑณ Robson Ramiroณ01/06/04ณ      ณ Ajuste na chamada de tela 811          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()

Local aRotina := {	{ OemToAnsi(STR0045), "AxPesqui"  , 	0, 1,,.F.},;//"Pesquisar"
					{ OemToAnsi(STR0046), "QPP140Tela", 	0, 2},; 	 //"Visualizar"
					{ OemToAnsi(STR0047), "QPP140Tela", 	0, 3},; 	 //"Incluir"
					{ OemToAnsi(STR0048), "QPP140Tela", 	0, 4},; 	 //"Alterar"
					{ OemToAnsi(STR0049), "QPP140Tela", 	0, 5},; 	 //"Excluir"
					{ OemToAnsi(STR0051), "QPPR140(.T.)",	0, 6,,.T.} }//"Imprimir"

Return aRotina

Function QPPA140
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cCadastro := OemToAnsi(STR0001) // Viabilidade

Private aRotina := MenuDef()

DbSelectArea("QKF")    
DbSetOrder(1)

mBrowse( 6, 1,22,75,"QKF")

Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณQPP140Tela  ณ Autor ณ Eduardo de Souza      ณ Data ณ24.07.01  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Cadastro Comprometimento c/ Viabilidade                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณQPP140Tela(ExpC1,ExpN1,ExpN2)                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Alias do arquivo                                     ณฑฑ
ฑฑณ          ณ ExpN1 = Numero do registro                                   ณฑฑ
ฑฑณ          ณ ExpN2 = Numero da opcao                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QPP140Tela(cAlias,nReg,nOpc)

Local oDlg
Local oNumPc
Local oRev
Local oDataViab
Local oDescrPc
Local oCliente
Local oScrollBox
Local oChk01
Local oChk02
Local oChk03
Local oChk04
Local oChk05
Local oChk06
Local oChk07
Local oChk08
Local oChk09
Local oChk10
Local oChk11
Local oChk12
Local oChk13
Local oChk14
Local oChk15
Local oChk16
Local oChk17
Local oChk18
Local oChk19
Local oChk20
Local oChk21
Local oChk22
Local oChk23
Local oChk24
Local oChk25
Local oChk26
Local oChk27
Local oChk28
Local oChk29
Local oChk30
Local oChk31
Local oChk32
Local oChk33
Local oChk34
Local oChk35
Local oChk36
Local oChk37
Local oChk38
Local oChk39
Local oPanel1
Local oPanel   
Local oDataAprv1
Local oDataAprv2
Local oDataAprv3
Local oDataAprv4
Local oDataAprv5
Local oDataAprv6
Local oMemb1
Local oMemb2
Local oMemb3
Local oMemb4
Local oMemb5
Local oMemb6
Local lOk			:= .F.
Local nLin 			:= 0
Local cChave		:= ""       
Local nI := 0

Private dKFDtViab := dDataBase
Private cKFNumPc  := Space(40)
Private cKFRev	   := Space(2)
Private cKFDescrPc:= Space(150)
Private cKFCliente:= Space(40)    
Private aSize     := MsAdvSize()
Private aObjetos  := {{ 625, 385, .F., .F.}}
Private aInfo     := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
Private aPosObj   := MsObjSize( aInfo, aObjetos, .T. , .T. )      
Private lExecB := ExistBlock("QPP140PER")
Private lChk01	   := .F.
Private lChk02    := .F.
Private lChk03	   := .F.
Private lChk04    := .F.
Private lChk05	   := .F.
Private lChk06    := .F.
Private lChk07	   := .F.
Private lChk08    := .F.
Private lChk09	   := .F.
Private lChk10    := .F.
Private lChk11	   := .F.
Private lChk12    := .F.
Private lChk13	   := .F.
Private lChk14    := .F.
Private lChk15	   := .F.
Private lChk16    := .F.
Private lChk17	   := .F.
Private lChk18    := .F.
Private lChk19	   := .F.
Private lChk20    := .F.
Private lChk21	   := .F.
Private lChk22    := .F.
Private lChk23	   := .F.
Private lChk24    := .F.
Private lChk25	   := .F.
Private lChk26    := .F.
Private lChk27    := .F.
Private lChk28	   := .F.
Private lChk29    := .F.
Private lChk30    := .F.
Private lChk31    := .F.
Private lChk32    := .F.
Private lChk33    := .F.
Private lChk34    := .F.
Private lChk35    := .F.
Private lChk36    := .F.
Private lChk37    := .F.
Private lChk38    := .F.
Private lChk39    := .F.
Private dKFDtAprv1:= dDataBase
Private dKFDtAprv2:= dDataBase
Private dKFDtAprv3:= dDataBase
Private dKFDtAprv4:= dDataBase
Private dKFDtAprv5:= dDataBase
Private dKFDtAprv6:= dDataBase
Private cKFMemb1  := Space(50)
Private cKFMemb2  := Space(50)
Private cKFMemb3  := Space(50)
Private cKFMemb4	:= Space(50)
Private cKFMemb5	:= Space(50)
Private cKFMemb6	:= Space(50)
Private bOk
Private bCancel
Private aButtons	:= {}
If lExecB
	ExecBlock("QPP140PER",.F.,.F.)
Endif
If nOpc == 4
	If !QPPVldAlt(QKF->QKF_PECA,QKF->QKF_REV)
		Return
	Endif
Endif

DbSelectArea("QKF")    
DbSetOrder(1)

If !Inclui
	cKFNumPc   	:= QKF->QKF_PECA
	cKFRev		:= QKF->QKF_REV
	dKFDtViab	:= QKF->QKF_DATA
	QP140Dados( nOpc, @cChave )	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicio da Tela	    										 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM aPosObj[1,1]-45,000 TO aPosObj[1,3],aPosObj[1,4] OF oMainWnd PIXEL // Viabilidade

SetDlg(oDlg)

RegToMemory("QKF",(nOpc == 3))

DEFINE FONT oFnt NAME "Arial" SIZE 5,15 

@ aPosObj[1,1],003 SAY OemToAnsi( STR0002 ) SIZE 040,010 COLOR CLR_HBLUE OF oDlg PIXEL      //Num. Peca
@ aPosObj[1,1],035 MSGET oNumPc VAR cKFNumPc ReadOnly F3 "QPP" SIZE 130,005 OF oDlg PIXEL;
		  VALID Q140ValiPc()

If nOpc == 3
	oNumpc:lReadOnly := .F.
Endif

@ aPosObj[1,1],173 SAY OemToAnsi( STR0003 ) SIZE 040,010 COLOR CLR_HBLUE OF oDlg PIXEL		  //Revisao
@ aPosObj[1,1],199 MSGET oRev VAR cKFRev SIZE 003,005 OF oDlg PIXEL;
			  VALID (Q140ValiRv( nOpc ),oDescrPc:Refresh(),oCliente:Refresh())

@ aPosObj[1,1],221 SAY OemToAnsi( STR0004 ) SIZE 040,010 COLOR CLR_HBLUE OF oDlg PIXEL		  //Data
@ aPosObj[1,1],237 MSGET oDataViab VAR dKFDtViab SIZE 040,005 PICTURE PesqPict("QKF", "QKF_DATA") OF oDlg PIXEL;
			  VALID Q140ValiDt()

@ aPosObj[1,1]+36,003 MSPANEL oPanel1 PROMPT "" COLOR CLR_WHITE,CLR_BLACK SIZE 307,010 OF oDlg
@ 003,004 SAY OemToAnsi( STR0007 ) COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL		  //Sim
@ 003,015 SAY OemToAnsi( STR0008 ) COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL		  //Nao
@ 003,140 SAY OemToAnsi( STR0009 ) COLOR CLR_WHITE SIZE 045,010 OF oPanel1 PIXEL		  //CONSIDERACAO

oScrollBox := TScrollBox():new(oDlg,aPosObj[1,1]+045,003, 085,308,.T.,.T.,.T.)

@ 017,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL

@ 007,006 CHECKBOX oChk01 VAR lChk01	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk01,( lChk02:=.F.,oChk02:Refresh()), )
@ 007,015 CHECKBOX oChk02 VAR lChk02	SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk02,( lChk01:=.F.,oChk01:Refresh()), )
@ 007,026 SAY OemToAnsi( STR0010 ) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt // "O Produto esta adequadamente definido (requisito de aplicacao, etc.) para habilitar a avaliacao "
@ 014,029 SAY OemToAnsi( STR0011 )	SIZE 100,010 OF oScrollBox PIXEL FONT oFnt // "da viabilidade?"

@ 029,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
@ 026,006 CHECKBOX oChk03 VAR lChk03 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk03,( lChk04:=.F.,oChk04:Refresh()), )
@ 026,015 CHECKBOX oChk04 VAR lChk04 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk04,( lChk03:=.F.,oChk03:Refresh()), )
@ 026,026 SAY OemToAnsi(STR0012) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt // "As Especificacoes de Desempenho de Engenharia podem ser atendidas, como descritas?"

@ 041,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
@ 038,006 CHECKBOX oChk05 VAR lChk05 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk05,( lChk06:=.F.,oChk06:Refresh()), )
@ 038,015 CHECKBOX oChk06 VAR lChk06 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk06,( lChk05:=.F.,oChk05:Refresh()), )
@ 038,026 SAY OemToAnsi(STR0013) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt // "O Produto pode ser manufaturado de acordo com as tolerancias especificas no desenho?"

@ 053,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
@ 050,006 CHECKBOX oChk07 VAR lChk07 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk07,( lChk08:=.F.,oChk08:Refresh()), )
@ 050,015 CHECKBOX oChk08 VAR lChk08 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk08,( lChk07:=.F.,oChk07:Refresh()), )	
@ 050,026 SAY OemToAnsi(STR0014) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt // "O Produto pode ser manufaturado com Cpk's que atendem as especificacoes?"

@ 065,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
@ 062,006 CHECKBOX oChk09 VAR lChk09 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk09,( lChk10:=.F.,oChk10:Refresh()), )
@ 062,015 CHECKBOX oChk10 VAR lChk10 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk10,( lChk09:=.F.,oChk09:Refresh()), )	
@ 062,026 SAY OemToAnsi(STR0015) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt // "Existe capacidade adequada para a fabricacao do produto?"


@ 077,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
@ 074,006 CHECKBOX oChk11 VAR lChk11 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk11,( lChk12:=.F.,oChk12:Refresh()), )
@ 074,015 CHECKBOX oChk12 VAR lChk12 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk12,( lChk11:=.F.,oChk11:Refresh()), )
@ 074,026 SAY OemToAnsi(STR0016) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt // "O projeto permite o uso de tecnicas eficientes de manuseio de material?"


@ 086,026 SAY OemToAnsi(STR0017)SIZE 270,010 OF oScrollBox PIXEL FONT oFnt // "O Produto pode ser manufaturado sem incorrer em inesperados:"

@ 095,006 CHECKBOX oChk13 VAR lChk13 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk13,( lChk14:=.F.,oChk14:Refresh()), )
@ 095,015 CHECKBOX oChk14 VAR lChk14 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk14,( lChk13:=.F.,oChk13:Refresh()), )
@ 095,045 SAY OemToAnsi(STR0018) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Custos de equipamentos de transformacao?"

@ 104,006 CHECKBOX oChk15 VAR lChk15 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk15,( lChk16:=.F.,oChk16:Refresh()), )
@ 104,015 CHECKBOX oChk16 VAR lChk16 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk16,( lChk15:=.F.,oChk15:Refresh()), )
@ 104,045 SAY OemToAnsi(STR0019) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Custos de ferramental?"

@ 116,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
@ 113,006 CHECKBOX oChk17 VAR lChk17 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk17,( lChk18:=.F.,oChk18:Refresh()), )
@ 113,015 CHECKBOX oChk18 VAR lChk18 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk18,( lChk17:=.F.,oChk17:Refresh()), )
@ 113,045 SAY OemToAnsi(STR0020) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Metodos de manufatura alternativos?"

@ 128,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
@ 125,006 CHECKBOX oChk19 VAR lChk19 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk19,( lChk20:=.F.,oChk20:Refresh()), )
@ 125,015 CHECKBOX oChk20 VAR lChk20 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk20,( lChk19:=.F.,oChk19:Refresh()), )
@ 125,026 SAY OemToAnsi(STR0021) SIZE 270,010 OF oScrollBox PIXEL FONT oFnt // "E necessario controle estatistico do processo para o produto?"

@ 140,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
@ 137,006 CHECKBOX oChk21 VAR lChk21 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk21,( lChk22:=.F.,oChk22:Refresh()), )
@ 137,015 CHECKBOX oChk22 VAR lChk22 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk22,( lChk21:=.F.,oChk21:Refresh()), )
@ 137,026 SAY OemToAnsi(STR0022) SIZE 270,010 OF oScrollBox PIXEL FONT oFnt // "O controle estatistico do processo esta sendo atualmente utilizado em produtos similares?"


@ 149,026 SAY OemToAnsi(STR0023)SIZE 270,010 OF oScrollBox PIXEL FONT oFnt // "Onde for utilizado controle estatistico do processo em produtos similiares:"

@ 158,006 CHECKBOX oChk23 VAR lChk23 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk23,( lChk24:=.F.,oChk24:Refresh()), )
@ 158,015 CHECKBOX oChk24 VAR lChk24 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk24,( lChk23:=.F.,oChk23:Refresh()), )
@ 158,045 SAY OemToAnsi(STR0024) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Os processos estao sob controle e estaveis?"

@ 170,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL    
@ 167,006 CHECKBOX oChk25 VAR lChk25 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk25,( lChk26:=.F.,oChk26:Refresh()), )
@ 167,015 CHECKBOX oChk26 VAR lChk26 SIZE 008,008 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk26,( lChk25:=.F.,oChk25:Refresh()), )
@ 167,045 SAY OemToAnsi(STR0025) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Os Cpk's sao maiores que 1,33?"


nLin := 185   
If lExecB
	For nI := 2 to Len(aObjetos)    
		If  nI == 2
			if !Empty (aObjetos[2][1])
				@ aObjetos[nI][1]+3,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
				@ aObjetos[nI][1],006 CHECKBOX oChk30 VAR lChk30 SIZE 008,008 OF oScrollBox PIXEL;
				 	 		ON CLICK If( lChk30,( lChk31:=.F.,oChk31:Refresh()), )
				@ aObjetos[nI][1],015 CHECKBOX oChk31 VAR lChk31 SIZE 008,008 OF oScrollBox PIXEL;
			 		 		ON CLICK If( lChk31,( lChk30:=.F.,oChk30:Refresh()), )
				@ aObjetos[nI][1],045 SAY aObjetos[2][2] SIZE 150,010 OF oScrollBox PIXEL FONT oFnt 
				
			EndIf
		EndIf
		If  nI == 3
			if !Empty (aObjetos[3][1])
				@ aObjetos[nI][1]+3,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
				@ aObjetos[nI][1],006 CHECKBOX oChk32 VAR lChk32 SIZE 008,008 OF oScrollBox PIXEL;
				 	 		ON CLICK If( lChk32,( lChk33:=.F.,oChk33:Refresh()), )
				@ aObjetos[nI][1],015 CHECKBOX oChk33 VAR lChk33 SIZE 008,008 OF oScrollBox PIXEL;
			 		 		ON CLICK If( lChk33,( lChk32:=.F.,oChk32:Refresh()), )
				@ aObjetos[nI][1],045 SAY aObjetos[3][2] SIZE 150,010 OF oScrollBox PIXEL FONT oFnt 
				
			End If
		EndIf
		if nI == 4
			if !Empty (aObjetos[4][1])
				@ aObjetos[nI][1]+3,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
				@ aObjetos[nI][1],006 CHECKBOX oChk34 VAR lChk34 SIZE 008,008 OF oScrollBox PIXEL;
				 	 		ON CLICK If( lChk34,( lChk35:=.F.,oChk35:Refresh()), )
				@ aObjetos[nI][1],015 CHECKBOX oChk35 VAR lChk35 SIZE 008,008 OF oScrollBox PIXEL;
			 		 		ON CLICK If( lChk35,( lChk34:=.F.,oChk34:Refresh()), )
				@ aObjetos[nI][1],045 SAY aObjetos[4][2] SIZE 150,010 OF oScrollBox PIXEL FONT oFnt 
				
			End If
		EndIf
		if nI == 5
			if !Empty (aObjetos[5][1])
				@ aObjetos[nI][1]+3,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
				@ aObjetos[nI][1],006 CHECKBOX oChk36 VAR lChk36 SIZE 008,008 OF oScrollBox PIXEL;
				 	 		ON CLICK If( lChk36,( lChk37:=.F.,oChk37:Refresh()), )
				@ aObjetos[nI][1],015 CHECKBOX oChk37 VAR lChk37 SIZE 008,008 OF oScrollBox PIXEL;
			 		 		ON CLICK If( lChk37,( lChk36:=.F.,oChk36:Refresh()), )
				@ aObjetos[nI][1],045 SAY aObjetos[5][2] SIZE 150,010 OF oScrollBox PIXEL FONT oFnt 
			
			End If
		EndIf
		if nI == 6
			if !Empty (aObjetos[6][1])
				@ aObjetos[nI][1]+3,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL
				@ aObjetos[nI][1],006 CHECKBOX oChk38 VAR lChk38 SIZE 008,008 OF oScrollBox PIXEL;
				 	 		ON CLICK If( lChk38,( lChk39:=.F.,oChk39:Refresh()), )
				@ aObjetos[nI][1],015 CHECKBOX oChk39 VAR lChk39 SIZE 008,008 OF oScrollBox PIXEL;
			 		 		ON CLICK If( lChk39,( lChk38:=.F.,oChk38:Refresh()), )
				@ aObjetos[nI][1],045 SAY aObjetos[6][2] SIZE 150,010 OF oScrollBox PIXEL FONT oFnt 
			

			End If
		EndIf
	Next nI
	nLin := aObjetos[1][1]
EndIf

@ 002,003 TO nLin,025    	OF oScrollBox PIXEL // Coluna 1
@ 002,003 TO nLin,014.5  	OF oScrollBox PIXEL // Coluna 2
@ 002,003 TO nLin,296		OF oScrollBox PIXEL // Coluna 3

@ nLin,006 SAY OemToAnsi(STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Membro da Equipe / Cargo"
@ nLin+8,006 MSGET oMemb1 VAR cKFMemb1 SIZE 160,005 OF oScrollBox PIXEL
@ nLin,221 SAY OemToAnsi( STR0004 ) SIZE 040,010 OF oScrollBox PIXEL		     //Data
@ nLin+8,221 MSGET oDataAprv1 VAR dKFDtAprv1 SIZE 040,005 PICTURE PesqPict("QKF", "QKF_DTAP1") OF oScrollBox PIXEL

@ nLin+18,006 SAY OemToAnsi(STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Membro da Equipe / Cargo"
@ nLin+25,006 MSGET oMemb2 VAR cKFMemb2 SIZE 160,005 OF oScrollBox PIXEL
@ nLin+18,221 SAY OemToAnsi( STR0004 ) SIZE 040,010 OF oScrollBox PIXEL		  	  //Data
@ nLin+25,221 MSGET oDataAprv2 VAR dKFDtAprv2 SIZE 040,005 PICTURE PesqPict("QKF", "QKF_DTAP2") OF oScrollBox PIXEL

@ nLin+35,006 SAY OemToAnsi(STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Membro da Equipe / Cargo"
@ nLin+43,006 MSGET oMemb3 VAR cKFMemb3 SIZE 160,005 OF oScrollBox PIXEL
@ nLin+35,221 SAY OemToAnsi( STR0004 ) SIZE 040,010 OF oScrollBox PIXEL		  	  //Data
@ nLin+43,221 MSGET oDataAprv3 VAR dKFDtAprv3 SIZE 040,005 PICTURE PesqPict("QKF", "QKF_DTAP3") OF oScrollBox PIXEL

@ nLin+53,006 SAY OemToAnsi(STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Membro da Equipe / Cargo"
@ nLin+61,006 MSGET oMemb4 VAR cKFMemb4 SIZE 160,005 OF oScrollBox PIXEL
@ nLin+53,221 SAY OemToAnsi( STR0004 ) SIZE 040,010 OF oScrollBox PIXEL		     //Data
@ nLin+61,221 MSGET oDataAprv4 VAR dKFDtAprv4 SIZE 040,005 PICTURE PesqPict("QKF", "QKF_DTAP4") OF oScrollBox PIXEL

@ nLin+71,006 SAY OemToAnsi(STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Membro da Equipe / Cargo"
@ nLin+79,006 MSGET oMemb5 VAR cKFMemb5 SIZE 160,005 OF oScrollBox PIXEL
@ nLin+71,221 SAY OemToAnsi( STR0004 ) SIZE 040,010 OF oScrollBox PIXEL		     //Data
@ nLin+79,221 MSGET oDataAprv5 VAR dKFDtAprv5 SIZE 040,005 PICTURE PesqPict("QKF", "QKF_DTAP5") OF oScrollBox PIXEL

@ nLin+89,006 SAY OemToAnsi(STR0042) SIZE 150,010 OF oScrollBox PIXEL FONT oFnt // "Membro da Equipe / Cargo"
@ nLin+97,006 MSGET oMemb6 VAR cKFMemb6 SIZE 160,005 OF oScrollBox PIXEL
@ nLin+89,221 SAY OemToAnsi( STR0004 ) SIZE 040,010 OF oScrollBox PIXEL		     //Data
@ nLin+97,221 MSGET oDataAprv6 VAR dKFDtAprv6 SIZE 040,005 PICTURE PesqPict("QKF", "QKF_DTAP6") OF oScrollBox PIXEL

oPanel:= tPanel():New(aPosObj[1,1]+134,003,,oDlg,,,,,,310,aPosObj[1,2]+43)

@ 001,001 TO 45,308 LABEL OemToAnsi(STR0031) OF oPanel PIXEL // "Conclusao"

@ 011,006 CHECKBOX oChk27 VAR lChk27 SIZE 038,010 OF oPanel PIXEL PROMPT OemToAnsi(STR0026); // "Viavel"
			 	 ON CLICK (Q140Conclu(),If(lChk27,( lChk28:=.F.,lChk29:=.F. ), ),;
			 	 				oChk27:Refresh(),oChk28:Refresh(),oChk29:Refresh() )						

@ 011,054 SAY OemToAnsi(STR0028) SIZE 250,010 OF oPanel PIXEL // "O produto pode ser produzido conforme especificado, sem revisoes."

@ 021,006 CHECKBOX oChk28 VAR lChk28 SIZE 038,010 OF oPanel PIXEL PROMPT OemToAnsi(STR0026); // "Viavel"
			 	 ON CLICK (Q140Conclu(),If( lChk28,( lChk27:=.F.,lChk29:=.F. ), ),;
			 	 				oChk27:Refresh(),oChk28:Refresh(),oChk29:Refresh() )						

@ 021,054 SAY OemToAnsi(STR0029) SIZE 250,010 OF oPanel PIXEL // "Alteracoes sao recomendaveis (veja anexo)"

@ 031,006 CHECKBOX oChk29 VAR lChk29 SIZE 038,010 OF oPanel PIXEL PROMPT OemToAnsi(STR0027); // "Nao viavel"
			 	 ON CLICK (Q140Conclu(),If( lChk29,( lChk27:=.F.,lChk28:=.F. ), ),;
			 	 				oChk27:Refresh(),oChk28:Refresh(),oChk29:Refresh() )

@ 031,054 SAY OemToAnsi(STR0030) SIZE 250,010 OF oPanel PIXEL //"Revisao de projeto requerida para a manufatura do produto dentro dos requisitos especificados."

@ aPosObj[1,1]+13,003 SAY OemToAnsi( STR0005 ) SIZE 040,010 OF oDlg PIXEL		  //Descr. Peca
@ aPosObj[1,1]+13,035 MSGET oDescrPc VAR cKFDescrPc SIZE 235,005 OF oDlg PIXEL
oDescrPc:lReadOnly:= .T.

@ aPosObj[1,1]+24,003 SAY OemToAnsi( STR0006 ) SIZE 040,010 OF oDlg PIXEL		  //Cliente
@ aPosObj[1,1]+24,035 MSGET oCliente VAR cKFCliente SIZE 130,005 OF oDlg PIXEL
oCliente:lReadOnly:= .T.

If nOpc == 2 .Or. nOpc == 5
	oNumPc:lReadOnly:= .T.
	oRev:lReadOnly:= .T.
	oDataViab:lReadOnly:= .T.
	oDescrPc:lReadOnly:= .T.
	oCliente:lReadOnly:= .T.
	oChk01:lReadOnly:= .T.
	oChk02:lReadOnly:= .T.
	oChk03:lReadOnly:= .T.
	oChk04:lReadOnly:= .T.
	oChk05:lReadOnly:= .T.
	oChk06:lReadOnly:= .T.
	oChk07:lReadOnly:= .T.
	oChk08:lReadOnly:= .T.
	oChk09:lReadOnly:= .T.
	oChk10:lReadOnly:= .T.
	oChk11:lReadOnly:= .T.
	oChk12:lReadOnly:= .T.
	oChk13:lReadOnly:= .T.
	oChk14:lReadOnly:= .T.
	oChk15:lReadOnly:= .T.
	oChk16:lReadOnly:= .T.
	oChk17:lReadOnly:= .T.
	oChk18:lReadOnly:= .T.
	oChk19:lReadOnly:= .T.
	oChk20:lReadOnly:= .T.
	oChk21:lReadOnly:= .T.
	oChk22:lReadOnly:= .T.
	oChk23:lReadOnly:= .T.
	oChk24:lReadOnly:= .T.
	oChk25:lReadOnly:= .T.
	oChk26:lReadOnly:= .T.
	oChk27:lReadOnly:= .T.
	oChk28:lReadOnly:= .T.
	oChk29:lReadOnly:= .T. 
	If lExecB		
		For nI := 2 to Len(aObjetos) 
			If  nI == 2
				oChk30:lReadOnly:= .T.
				oChk31:lReadOnly:= .T.
			EndIf
			If  nI == 3
				oChk32:lReadOnly:= .T.
				oChk33:lReadOnly:= .T.
			EndIf
			If  nI == 4
				oChk34:lReadOnly:= .T.
				oChk35:lReadOnly:= .T.
			EndIf
			If  nI == 5
				oChk36:lReadOnly:= .T.
				oChk37:lReadOnly:= .T.
			EndIf
			If  nI == 6
				oChk38:lReadOnly:= .T.
				oChk39:lReadOnly:= .T.
			EndIf
		Next nI
	EndIf
	oDataAprv1:lReadOnly:= .T.
	oDataAprv2:lReadOnly:= .T.
	oDataAprv3:lReadOnly:= .T.
	oDataAprv4:lReadOnly:= .T.
	oDataAprv5:lReadOnly:= .T.
	oDataAprv6:lReadOnly:= .T.
	oMemb1:lReadOnly:= .T.
	oMemb2:lReadOnly:= .T.
	oMemb3:lReadOnly:= .T.
	oMemb4:lReadOnly:= .T.
	oMemb5:lReadOnly:= .T.
	oMemb6:lReadOnly:= .T.
	SysRefresh()
ElseIf nOpc == 4
	oNumPc:lReadOnly:= .T.
	oRev:lReadOnly:= .T.
	oDataViab:lReadOnly:= .T.
	oDescrPc:lReadOnly:= .T.
	oCliente:lReadOnly:= .T.
	SysRefresh()
EndIf


aAdd(aButtons,{"RELATORIO", {|| QP140EdTxt(nOpc, @cChave)} , OemToAnsi( STR0052 ) } )    //"Comentarios/Explicacoes" STR0039 Alterado para "Comentar" STR0052

If nOpc == 2 .or. nOpc == 5
	aAdd(aButtons,{"BMPVISUAL", {|| QPPR140()} , OemToAnsi( STR0051 ) } )    //"Visualizar/Imprimir" STR0050 Alterado para "Imprimir" STR0051
Endif

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ || If(nOpc==2, oDlg:End(),;
   		 		  If(nOpc==3, (Q140ValChk(nOpc, @lOk),If(lOk,(QPP140Grv( nOpc, cChave ),oDlg:End()),)),;
 		 		  If(nOpc==4, (QPP140Grv(nOpc, cChave),oDlg:End()),;
 		 		  If(nOpc==5, (QPP140Exc(cChave),oDlg:End()),))))},{|| (If(nOpc==3,Q140DelQKO(cChave),),oDlg:End())},,aButtons)CENTERED //@cChave, @lOk, nOpc, oDlg,


If nOpc == 3 .and. lOk 
	QPP140TELA("QKF",0,3)
Endif	

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	  ณ QPP140Bar  ณ Autor ณ Eduardo de Souza           ณ Data ณ 25/07/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao  ณ Monta Tollbar da tela de Viabilidade                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	  ณ QPP140Bar(ExpC1, ExpL1, ExpL2, ExpN1, ExpO1)                      ณฑฑ                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametros ณ ExpC1 = Chave de Ligacao                                     	  ณฑฑ
ฑฑณ           ณ ExpL1 = .T. (Inclusao) - .F. (Visualizacao/Alteracao/Exclusao)    ณฑฑ
ฑฑณ           ณ ExpL2 = .T. Tudo Validado                                   	  ณฑฑ
ฑฑณ           ณ ExpN1 = Numero da opcao do Cadastro                          	  ณฑฑ
ฑฑณ           ณ ExpO1 = Objeto oDlg                                        		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		  ณ QPPA140                                                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function QPP140Bar(cChave, lOk, nOpc, oDlg )
Local oBar
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oBtn6
Local oBtn7
Local oBtComent
Local oBtCan
Local oBtVisual
           
DEFINE BUTTONBAR oBar SIZE 25, 25 3D TOP OF oDlg

DEFINE BUTTON oBtn1 RESOURCE "S4WB005N" OF oBar;
       ACTION NaoDisp();
       TOOLTIP  OemToAnsi(STR0032) // "Recortar"

DEFINE BUTTON oBtn2 RESOURCE "S4WB006N" OF oBar;
       ACTION NaoDisp();
       TOOLTIP OemToAnsi(STR0033) // "Copiar"

DEFINE BUTTON oBtn3 RESOURCE "S4WB007N" OF oBar;
       ACTION   NaoDisp();
       TOOLTIP OemToAnsi(STR0034) // "Colar"

DEFINE BUTTON oBtn4 RESOURCE "S4WB008N" OF oBar;
       ACTION Calculadora();
       TOOLTIP  OemToAnsi(STR0035) // "Calculadora..."

oBtn4:cTitle := Subs(STR0035,1,4)

DEFINE BUTTON oBtn6 RESOURCE "S4WB010N" OF oBar;
       ACTION OurSpool();
       TOOLTIP OemToAnsi(STR0037) // "Spool"

DEFINE BUTTON oBtn7 RESOURCE "S4WB016N" OF oBar;
       ACTION   HelProg();
       TOOLTIP OemToAnsi(STR0038) //"Ajuda"

DEFINE BUTTON oBtComent RESOURCE "RELATORIO" OF oBar;
       ACTION QP140EdTxt(nOpc, @cChave);       
       TOOLTIP OemToAnsi(STR0039) // "Comentarios/Explicacoes"

oBtComent:cTitle := STR0052 //"Comentar"

If nOpc == 2 .or. nOpc == 5
	DEFINE BUTTON oBtVisual RESOURCE "BMPVISUAL" OF oBar ACTION QPPR140();
						TOOLTIP OemToAnsi(STR0050) //"Visualizar/Imprimir"
	oBtVisual:cTitle := STR0036
Endif

DEFINE BUTTON oBtOK RESOURCE "OK" OF oBar;
 		 ACTION If(nOpc==2, oDlg:End(),;
 		 		  If(nOpc==3, (Q140ValChk(nOpc, @lOk),If(lOk,(QPP140Grv( nOpc, cChave ),oDlg:End()),)),;
 		 		  If(nOpc==4, (QPP140Grv(nOpc, cChave),oDlg:End()),;
 		 		  If(nOpc==5, (QPP140Exc(cChave),oDlg:End()), ) ) ) );
       TOOLTIP OemToAnsi(STR0040) // "Ok"

DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar;
       ACTION (If(nOpc==3,Q140DelQKO(cChave),),oDlg:End());
       TOOLTIP OemToAnsi(STR0041) // "Cancelar"
       
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQPP140Grv บAutor  ณEduardo de Souza    บ Data ณ  26/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Dados                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณQP140Grv(ExpN1, ExpC1)								      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 - Numero da opcao do Cadastro                        บฑฑ
ฑฑบ          ณ ExpC1 - Chave de Ligacao                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QPPA140.PRW                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function QPP140Grv( nOpc, cChave )

Local cAtividade 	:= "03 " // Definido no ID - QKZ
Local nI := 0

DbSelectArea("QKF")    
DbSetOrder(1)

Begin Transaction
	If nOpc == 3
		RecLock("QKF",.T.)
	Else
		RecLock("QKF",.F.)
	EndIf
	QKF->QKF_FILIAL:= xFilial("QKF")
	QKF->QKF_PECA  := cKFNumPc
   	QKF->QKF_REV   := cKFRev
   	QKF->QKF_DATA  := dKFDtViab
	QKF->QKF_Q01   := If (lChk01,"1",If(lChk02,"2"," "))
	QKF->QKF_Q02   := If (lChk03,"1",If(lChk04,"2"," "))
	QKF->QKF_Q03   := If (lChk05,"1",If(lChk06,"2"," "))
	QKF->QKF_Q04   := If (lChk07,"1",If(lChk08,"2"," "))
	QKF->QKF_Q05   := If (lChk09,"1",If(lChk10,"2"," "))
	QKF->QKF_Q06   := If (lChk11,"1",If(lChk12,"2"," "))
	QKF->QKF_Q07   := If (lChk13,"1",If(lChk14,"2"," "))
	QKF->QKF_Q08   := If (lChk15,"1",If(lChk16,"2"," "))
	QKF->QKF_Q09   := If (lChk17,"1",If(lChk18,"2"," "))
	QKF->QKF_Q10   := If (lChk19,"1",If(lChk20,"2"," "))
	QKF->QKF_Q11   := If (lChk21,"1",If(lChk22,"2"," "))
	QKF->QKF_Q12   := If (lChk23,"1",If(lChk24,"2"," "))
	QKF->QKF_Q13   := If (lChk25,"1",If(lChk26,"2"," "))
	QKF->QKF_CONC  := If (lChk27,"1",If(lChk28,"2",If(lChk29,"3"," ")))		
	QKF->QKF_CHAVE := cChave
	QKF->QKF_REVINV:= Inverte(cKFRev)
	If lExecB
		For nI := 2 to Len(aObjetos) 
			If  nI == 2	
	   		   	QKF->&(aObjetos[2][3]) := If (lChk30,"1",If(lChk31,"2"," "))   
   		  	EndIf   	
			If  nI == 3		   
   	   			QKF->&(aObjetos[3][3]) := If (lChk32,"1",If(lChk33,"2"," "))   
   		  	EndIf   	
			If  nI == 4	   
	   	   		QKF->&(aObjetos[4][3]) := If (lChk34,"1",If(lChk35,"2"," "))   
   		  	EndIf   	
			If  nI == 5	   	   
	   		   	QKF->&(aObjetos[5][3]) := If (lChk36,"1",If(lChk37,"2"," "))   
   		  	EndIf   	
			If  nI == 6	   	   
   		   		QKF->&(aObjetos[6][3]) := If (lChk38,"1",If(lChk39,"2"," "))  
   		  	EndIf
   	    Next nI	   
	EndIf
	If !Empty(cKFMemb1)
		QKF->QKF_MEMB1:= cKFMemb1      
		QKF->QKF_DTAP1:= dKFDtAprv1
	EndIf
	If !Empty(cKFMemb2)
		QKF->QKF_MEMB2:= cKFMemb2		
		QKF->QKF_DTAP2:= dKFDtAprv2
	EndIf
	If !Empty(cKFMemb3)
		QKF->QKF_MEMB3:= cKFMemb3
		QKF->QKF_DTAP3:= dKFDtAprv3
	EndIf
	If !Empty(cKFMemb4)
		QKF->QKF_MEMB4:= cKFMemb4
		QKF->QKF_DTAP4:= dKFDtAprv4
	EndIf
	If !Empty(cKFMemb5)
		QKF->QKF_MEMB5:= cKFMemb5		
		QKF->QKF_DTAP5:= dKFDtAprv5
	EndIf
	If !Empty(cKFMemb6)
		QKF->QKF_MEMB6:= cKFMemb6		
		QKF->QKF_DTAP6:= dKFDtAprv6
	EndIf		
	MsUnlock()    
	FKCOMMIT()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza Cronograma "QPPA110", caso exista.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(QKF->QKF_CONC)
		QPP_CRONO(QKF->QKF_PECA,QKF->QKF_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
	Endif   

End Transaction   

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQP140DadosบAutor  ณEduardo de Souza    บ Data ณ  26/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega dados                								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณQP140Dados(ExpN1, ExpC1)									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 - Numero da opcao do Cadastro                        บฑฑ
ฑฑบ          ณ ExpC1 - Chave de Ligacao                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QPPA140                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function QP140Dados( nOpc, cChave ) 

Local nI := 0
DbSelectArea("QKF")
DbSetOrder(1)

If DbSeek(xFilial("QKF")+cKFNumPc+cKFRev) 
   Q140ValiRv( nOpc ) // Carrega a variavel cKFDescrPc e cKFCliente
	If !Empty(QKF->QKF_Q01)
		If QKF->QKF_Q01 == "1"
			lChk01:= .T.
		Else
			lChk02:= .T.
		EndIf
	EndIf
	If !Empty(QKF->QKF_Q02)
		If QKF->QKF_Q02 == "1"
			lChk03:= .T.
		Else
			lChk04:= .T.
		EndIf
	EndIf	
	If !Empty(QKF->QKF_Q03)
		If QKF->QKF_Q03 == "1"
			lChk05:= .T.
		Else
			lChk06:= .T.
		EndIf
	EndIf	    
	If !Empty(QKF->QKF_Q04)
		If QKF->QKF_Q04 == "1"
			lChk07:= .T.
		Else
			lChk08:= .T.
		EndIf
	EndIf	
	If !Empty(QKF->QKF_Q05)
		If QKF->QKF_Q05 == "1"
			lChk09:= .T.
		Else
			lChk10:= .T.
		EndIf
	EndIf
	If !Empty(QKF->QKF_Q06)
		If QKF->QKF_Q06 == "1"
			lChk11:= .T.
		Else
			lChk12:= .T.
		EndIf
	EndIf      	
	If !Empty(QKF->QKF_Q07)
		If QKF->QKF_Q07 == "1"
			lChk13:= .T.
		Else
			lChk14:= .T.
		EndIf
	EndIf
	If !Empty(QKF->QKF_Q08)
		If QKF->QKF_Q08 == "1"
			lChk15:= .T.
		Else
			lChk16:= .T.
		EndIf
	EndIf	
	If !Empty(QKF->QKF_Q09)
		If QKF->QKF_Q09 == "1"
			lChk17:= .T.
		Else
			lChk18:= .T.
		EndIf
	EndIf	
	If !Empty(QKF->QKF_Q10)
		If QKF->QKF_Q10 == "1"
			lChk19:= .T.
		Else
			lChk20:= .T.
		EndIf
	EndIf	
	If !Empty(QKF->QKF_Q11)
		If QKF->QKF_Q11 == "1"
			lChk21:= .T.
		Else
			lChk22:= .T.
		EndIf
	EndIf
	If !Empty(QKF->QKF_Q12)
		If QKF->QKF_Q12 == "1"
			lChk23:= .T.
		Else
			lChk24:= .T.
		EndIf
	EndIf      	
	If !Empty(QKF->QKF_Q13)
		If QKF->QKF_Q13 == "1"
			lChk25:= .T.
		Else
			lChk26:= .T.
		EndIf
	EndIf   	
	If !Empty(QKF->QKF_CONC)
		If QKF->QKF_CONC == "1"
			lChk27:= .T.
		ElseIf QKF->QKF_CONC == "2"
			lChk28:= .T.
		Else
			lChk29:= .T.
		EndIf
	EndIf  
	If lExecB
		For nI := 2 to Len(aObjetos) 
			If  nI == 2	
				If !Empty(QKF->&(aObjetos[2][3]))
					If QKF->&(aObjetos[2][3]) == "1"
						lChk30:= .T.
					Else
						lChk31:= .T.
					EndIf
				EndIf 
   		  	EndIf   	
			If  nI == 3		   
				If !Empty(QKF->&(aObjetos[3][3]))
					If QKF->&(aObjetos[3][3]) == "1"
						lChk32:= .T.
					Else
						lChk33:= .T.
					EndIf
				EndIf   
   		  	EndIf   	
			If  nI == 4	   
				If !Empty(QKF->&(aObjetos[4][3]))
					If QKF->&(aObjetos[4][3]) == "1"
						lChk34:= .T.
					Else
						lChk35:= .T.
					EndIf
				EndIf 
   		  	EndIf   	
			If  nI == 5	   	   
				If !Empty(QKF->&(aObjetos[5][3]))
					If QKF->&(aObjetos[5][3]) == "1"
						lChk36:= .T.
					Else
						lChk37:= .T.
					EndIf
				EndIf 
   		  	EndIf   	
			If  nI == 6	   	   
				If !Empty(QKF->&(aObjetos[6][3]))
					If QKF->&(aObjetos[6][3]) == "1"
						lChk38:= .T.
					Else
						lChk39:= .T.
					EndIf
				EndIf 
   		  	EndIf
   	    Next nI	 	
	EndIf
   dKFDtAprv1:= QKF->QKF_DTAP1
   dKFDtAprv2:= QKF->QKF_DTAP2
   dKFDtAprv3:= QKF->QKF_DTAP3
   dKFDtAprv4:= QKF->QKF_DTAP4
   dKFDtAprv5:= QKF->QKF_DTAP5
   dKFDtAprv6:= QKF->QKF_DTAP6
   cKFMemb1	 := QKF->QKF_MEMB1
   cKFMemb2	 := QKF->QKF_MEMB2
   cKFMemb3	 := QKF->QKF_MEMB3
   cKFMemb4	 := QKF->QKF_MEMB4
   cKFMemb5	 := QKF->QKF_MEMB5
   cKFMemb6	 := QKF->QKF_MEMB6
   cChave    := QKF->QKF_CHAVE
EndIf

Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณQPP140Exc   ณ Autor ณ Eduardo de Souza      ณ Data ณ27.07.01  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Exclusao														ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณQ140Exc(ExpC1)                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 - Numero da chave de ligacao                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ QPPA140                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QPP140Exc(cChave)

DbSelectArea("QKF")
DbSetOrder(1)
If DbSeek(xFilial("QKF")+cKFNumPc+cKFRev) 
	If MsgYesNo(STR0043,STR0044) // "Tem certeza que deseja Excluir este Registro" ### "Atencao"
		RecLock("QKF",.F.)
		QKF->(DbDelete())
		MsUnlock()
		FKCOMMIT()
		Q140DelQKO(cChave)
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ140ValiRvบAutor  ณEduardo de Souza    บ Data ณ  26/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se Peca/Revisao ja esta cadastrada                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณQ140ValChk(ExpN1, ExpL1)									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 - Numero da opcao do Cadastro                        บฑฑ
ฑฑบ          ณ ExpL1 - .T. Tudo Validado                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QPPA140                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Q140ValiRv( nOpc, lRet )

Local cCodCli := ""
Local cLojaCli:= ""
Default lRet  := .t.

DbSelectArea("QKF")
DbSetOrder(1) //QKF_FILIAL+QKF_PECA+QKF_REV
If DbSeek(xFilial("QKF")+cKFNumPc+cKFRev) .And. nOpc == 3 // Se encontrar e for Inclusao
	lRet:= .f.	
	Help("", 1, "Q140PCEXIS")	// "Numero de Revisao ja cadastrada para esta Peca "
Else
	lRet:= .t.	
EndIf

If lRet
	DbSelectArea("QK1") 
	DbSetOrder(1) // QK1_FILIAL+QK1_PECA+QK1_REV
	If DbSeek(xFilial("QK1")+cKFNumPc+cKFRev)
		cKFDescrPc:= QK1->QK1_DESC
		cCodCli := QK1->QK1_CODCLI
		cLojaCli:= Qk1->QK1_LOJCLI
		DbSelectArea("SA1") 
		DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
		If DbSeek(XFilial("SA1")+cCodCli+cLojaCli)
	   	cKFCliente:= SA1->A1_NOME
	 	EndIf	
	Else
		lRet:= .F.	
		Help("", 1, "Q140RVPCNC")	// "Revisao para esta Peca nao existe"
		cKFDescrPc:= " "
   	cKFCliente:= " "
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ140ValiPcบAutor  ณEduardo de Souza    บ Data ณ  26/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se Peca existe 									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QPPA140                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Q140ValiPc()
Local lRet:= .T.

DbSelectArea("QK1") 
DbSetOrder(1) // QK1_FILIAL+QK1_PECA+QK1_REV

If !Empty(cKFNumPc)
	If !DbSeek(xFilial("QK1")+cKFNumPc)
		lRet:= .F.	
		Help("", 1, "Q140PCNC") // "Peca nao Cadastrada"
	EndIf                             
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ140ValChkบAutor  ณEduardo de Souza    บ Data ณ  28/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se existe pelo menos um checkbox selecionado		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณQ140ValChk(ExpN1, ExpL1)									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 - Numero da opcao do Cadastro                        บฑฑ
ฑฑบ          ณ ExpL1 - .T. Tudo Validado                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QPPA140                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Q140ValChk(nOpc, lRet)

If lChk01==.t. .Or. lChk02==.t. .Or. lChk03==.t. .Or. lChk04==.t. .Or. lChk05==.t. .Or.;
	lChk06==.t. .Or. lChk07==.t. .Or. lChk08==.t. .Or. lChk09==.t. .Or. lChk10==.t. .Or.;
	lChk11==.t. .Or. lChk12==.t. .Or. lChk13==.t. .Or. lChk14==.t. .Or. lChk15==.t. .Or.;
	lChk16==.t. .Or. lChk17==.t. .Or. lChk18==.t. .Or. lChk19==.t. .Or. lChk20==.t. .Or.;
	lChk21==.t. .Or. lChk22==.t. .Or. lChk23==.t. .Or. lChk24==.t. .Or. lChk25==.t. .Or. lChk26==.t.
	lRet:= .t.
	Q140ValiRv(nOpc, @lRet)	
Else
	If lExecB 
		lRet:= .f.
		If lChk30==.t. .Or. lChk31==.t. .Or. lChk32==.t. .Or. lChk33==.t. .Or. lChk34==.t. .Or.;
		   lChk35==.t. .Or. lChk36==.t. .Or. lChk37==.t. .Or. lChk38==.t. .Or. lChk39==.t.
				lRet:= .t.
		Else
			Help("", 1, "Q140CHK")	// "Deve ser preenchido ao menos uma pergunta para incluir o comprometimento da equipe com a viabilidade"			
		EndIf
	Else         
		lRet:= .f.
		Help("", 1, "Q140CHK")	// "Deve ser preenchido ao menos uma pergunta para incluir o comprometimento da equipe com a viabilidade"	
	Endif
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ140ValiDtบAutor  ณEduardo de Souza    บ Data ณ  28/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se Campo Data de Viabilidade                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QPPA140                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Q140ValiDt()
Local lRet:= .T.

If Empty(dKFDtViab)
	lRet:= .F.	
	Help("", 1, "Q140DTVIAB")	// "Data do cadastro do Comprometimento da equipe com a viabilidade deve e obrigatorio"
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao	  ณ QP140EdTxt ณ Autor ณ  Eduardo de Souza          ณ Data ณ 28/07/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao  ณ Abra a janela para digitacao do comentario/explicacao             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	  ณ QP140EdTxt( ExpN1, ExpC1, ExpL1 )                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametros ณ ExpN1 - Numero da opcao do Cadastro (Incluir/Alterar/Excluir)     ณฑฑ
ฑฑณ           ณ ExpC1 - Chave de ligacao                                          ณฑฑ
ฑฑณ           ณ ExpL1 - .T. Inclusao - .F. (Alteracao/Visualizacao/Exclusao)      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		  ณ QPPA140()                                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function QP140EdTxt( nOpc, cChave )
Local cCabec    := ""
Local cTitulo   := ""
Local cCod      := "Peca: " + cKFNumPc + " Rev: " + cKFRev
Local cEspecie  := "QPPA140 "
Local nTamLin   := TamSX3( "QKO_TEXTO" )[1]
Local lEdit     := .f.
Local axTextos  := {}
Local nSaveSX8	:= GetSX8Len()

DbSelectArea("QKF")
DbSetOrder(1)

If Empty( cKFNumPc ) .Or. Empty( cKFRev )
   Return .f.
EndIf

Titulo := OemtoAnsi( STR0039 )  // "Comentarios/Explicacoes"
cCabec := OemtoAnsi( STR0039 )  // "Comentarios/Explicacoes"

If Empty(cChave)
	cChave := GetSXENum("QKF", "QKF_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	If !Inclui
 		RecLock( "QKF", .f. )
		QKF->QKF_CHAVE := cChave
  		MsUnLock()
  		FKCOMMIT()
	Endif
Else
	If !Inclui
		cChave := QKF->QKF_CHAVE
	EndIf
EndiF

If nOpc <> 2 .And. nOpc <> 5
   lEdit := .t.
EndIf

If QO_TEXTO( cChave, cEspecie, nTamlin, cTitulo, cCod, @axtextos, 1, cCabec, lEdit )
   QO_GrvTxt( cChave, cEspecie, 1, @axtextos )
EndIf

Return .t.
           
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณQ140DelQKO  ณ Autor ณ Eduardo de Souza      ณ Data ณ28.07.01  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Deleta Comentarios do QKO                 					ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณQ140DelQKO(ExpC1)                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 - Numero da chave de ligacao                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ QPPA140                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Q140DelQKO(cChave)

Local cEspecie := "QPPA140 "

QO_DelTxt(cChave,cEspecie)    //QPPXFUN

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQ140ConcluบAutor  ณEduardo de Souza    บ Data ณ  30/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se todas as perguntas estao preenchidas para poder seบฑฑ
ฑฑบDesc.     ณlecionar a opcao de conclusao                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณQ140ValChk()            									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QPPA140                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Q140Conclu()

If	(lChk01 == .t. .Or. lChk02 == .t.) .And. (lChk03 == .t. .Or. lChk04 == .t.) .And.;
	(lChk05 == .t. .Or. lChk06 == .t.) .And. (lChk07 == .t. .Or. lChk08 == .t.) .And.;
	(lChk09 == .t. .Or. lChk10 == .t.) .And. (lChk11 == .t. .Or. lChk12 == .t.) .And.;
	(lChk13 == .t. .Or. lChk14 == .t.) .And. (lChk15 == .t. .Or. lChk16 == .t.) .And.;
	(lChk17 == .t. .Or. lChk18 == .t.) .And. (lChk19 == .t. .Or. lChk20 == .t.) .And.;
	(lChk21 == .t. .Or. lChk22 == .t.) .And. (lChk23 == .t. .Or. lChk24 == .t.) .And.;
	(lChk25 == .t. .Or. lChk26 == .t.)
	lRet:= .t.
Else
	lRet:= .f.
	Help("", 1, "Q140CONCL")	// "Responda todas as Perguntas "
	lChk27:= .F.
	lChk28:= .F.
	lChk29:= .F.
EndIf

Return lRet
