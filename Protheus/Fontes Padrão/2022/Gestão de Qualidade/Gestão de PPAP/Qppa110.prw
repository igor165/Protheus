#INCLUDE "QPPA110.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE GANTT "8"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA110  ³ Autor ³ Eduardo de Souza      ³ Data ³ 31/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cronograma                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA110()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³25.09.01³      ³ Inclusao de Botao para chamada de rela-³±±
±±³              ³        ³      ³ torio e tratamento do mesmo            ³±±
±±³              ³        ³      ³ Melhorias no tratamento de exclusoes   ³±±
±±³              ³        ³      ³ Permissao de inclusao de atividade sem ³±±
±±³              ³        ³      ³ codigo cadastrado                      ³±±
±±³              ³        ³      ³ Acerto de Gatilho para atuliz. de Campo³±±
±±³ Robson Ramiro³18.02.02³VERSAO³ Retirada dos ajustes 609 x 710         ³±±
±±³ Robson Ramiro³24.04.02³META  ³ Troca do Alias da familia SR para QA   ³±±
±±³ Robson Ramiro³18.07.02³XMETA ³ Inclusao de legenda nos itens da       ³±±
±±³              ³        ³      ³ getdados. Melhoria para a reorganizacao³±±
±±³              ³        ³      ³ das atividades.                        ³±±
±±³              ³        ³      ³ Troca do CvKey por GetSXENum           ³±±
±±³ Robson Ramiro³13.08.03³xMeta ³ Alteracao e inclusao nos conceitos de  ³±±
±±³              ³        ³      ³ legenda e prazos para conclusao e troca³±±
±±³              ³        ³      ³ tabela QF SX5 para o arquivo QKZ       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui", 		0, 1,,.F.} ,; 	//"Pesquisar"
					{ OemToAnsi(STR0002), "QPPA110Visu", 	0, 2} ,;    	//"Visualizar"
					{ OemToAnsi(STR0003), "QPPA110Grav", 	0, 3} ,;    	//"Incluir"
					{ OemToAnsi(STR0004), "QPPA110Grav", 	0, 4} ,; 	    //"Alterar"
					{ OemToAnsi(STR0005), "QPPA110Visu", 	0, 5} ,;     	//"Excluir"
					{ OemToAnsi(STR0025), "PPA110Lege", 	0, 6,,.F.} ,;	//"Legenda"
					{ OemToAnsi(STR0029), "QPPR110(.T.)",	0, 8,,.T.} } 	//"Imprimir"

Return aRotina

Function QPPA110
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006) //"Cronograma"
Private lLacuna   := GetMv("MV_QLACUN",,"N") == "S"
Private lIntGPE	   := GetlIntGPE() 
Private lAltUsr   := GetlAltUsr()
 
aCores  := { 	{"QPP110CorB(1) == 1", 'ENABLE'    },; 	// Verde    - Cronograma em dia
				{"QPP110CorB(2) == 2", 'BR_AMARELO'},;	// Amarelo  - Expirando nos proximos dias
				{"QPP110CorB(3) == 3", 'DISABLE'   },;	// Vermelho - Cronograma Atrasado
				{"QPP110CorB(4) == 4", 'BR_CINZA'  } } 	// Cinza	- Cronograma Encerrado

Private aRotina := MenuDef()

DbSelectArea("QKG")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QKG",,,,,,aCores)

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPPA110Visu ³ Autor ³ Eduardo de Souza      ³ Data ³02/08/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizacao \ Exclusao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA110Visu(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPP110                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPA110Visu(cAlias,nReg,nOpc)

Local aButtons    	:= {}
Local aAlter		:= {} 
Local aPosObj		:= {}
Local oSize			:= NIL
Local oDlg			:= NIL
Local oEnchoice 	:= NIL

Private aGets		:= {}
Private aTela		:= {}
Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL

oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 40, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

DbSelectArea("QKG")
RegToMemory("QKG",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice 			                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006); // "Cronograma"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

oEnchoice := Msmget():New("QKG",nReg,nOpc,,,,,aPosObj[1],,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QKP")

QPP110Ahead("QKP")
nUsado	:= Len(aHeader)
QPP110Acols(nOpc)

aAlter := {}
Aadd(aAlter,"QKP_OBS")

// Foi usado a Opcao 4 fixa no nOpc para permitir a visualizacao das observacoes
oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],4,"AllwaysTrue","AllwaysTrue","+QKP_SEQ",.F.,aAlter,,,Len(Acols))

aButtons := { 	{"RELATORIO",	{ || QP110EdTxt( nOpc,QKG->QKG_PECA,QKG->QKG_REV,QKG->QKG_CHAVE ) }	, OemToAnsi(STR0014), OemToAnsi(STR0037) },;		//"Observacoes do Cronograma"###"Obs"
				{"BMPVISUAL",	{ || QPPR110() }														, OemToAnsi(STR0021), OemToAnsi(STR0038) }}	//"Visualizar/Imprimir"###"Vis/Prn"

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,Iif(nOpc==5,{|| QPP110Exc(),oDlg:End()} , {|| oDlg:End()} ),{||oDlg:End()}, , aButtons), AlignObject(oDlg,{oEnchoice:oBox, oGet:oBrowse},1,,{166}),oGet:oBrowse:Refresh())

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPPA110Grav ³ Autor ³ Eduardo de Souza      ³ Data ³31/07/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao do Cronograma                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void QPPA110Grav(ExpC1,ExpN1,ExpN2)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPA110Grav(cAlias,nReg,nOpc)

Local oDlg			:= NIL
Local lOk 			:= .f.
Local aButtons    	:= {}
Local aCposQKG	   	:= {}
Local aPosObj		:= {}

Local oSize			:= NIL
Private aGets		:= {}
Private aTela		:= {}
Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL

aCposQKG := {	"QKG_RESP" }

If nOpc == 4
	If !QPPVldAlt(QKG->QKG_PECA,QKG->QKG_REV)
		Return
	Endif
Endif

oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 40, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos  

DbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice 			                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006); // "Cronograma"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
RegToMemory("QKG",(nOpc == 3))

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

oEnchoice := Msmget():New("QKG",nReg,nOpc,,,,,aPosObj[1],Iif(nOpc == 4,aCposQKG,),,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QKP")
QPP110Ahead("QKP")
nUsado	:= Len(aHeader)
QPP110Acols(nOpc)

oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpc,"QPP110LinOk","QPP110TudOk(nOpc)","+QKP_SEQ",.T.,,,,999)

aButtons := {}

If nOpc == 3
	AADD(aButtons, {"BMPINCLUIR" ,{ || QPPCarQKZ(oGet) }, OemToAnsi(STR0013), OemToAnsi(STR0039) } ) // "Atividades Padrao"###"Incl Ativ"
EndIf

AADD(aButtons, {"RELATORIO"	,	{ || QP110EdTxt( nOpc ) }	, OemToAnsi(STR0014), OemToAnsi(STR0037) } ) //"Observacoes do Cronograma"###"Obs"

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||lOk := QPP110TudOk(nOpc), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons), AlignObject(oDlg,{oEnchoice:oBox, oGet:oBrowse},1,,{166}),oGet:oBrowse:Refresh())

If lOk
	Q110Grav(nOpc)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP110Ahead³ Autor ³Eduardo de Souza      ³ Data ³ 31/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP110Ahead(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA110/QPPC010                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPP110Ahead(cAlias,lPend)

Local aStruAlias := FWFormStruct(3, cAlias,, .F.)[3]
Local nX

Default lPend := .F.

aHeader := {}
nUsado 	:= 0

If !Empty(GetSX3Cache("QKP_LEGEND","X3_CAMPO"))
	If X3Uso(GetSX3Cache("QKP_LEGEND","X3_USADO")) .and. cNivel >= GetSX3Cache("QKP_LEGEND","X3_NIVEL")
		nUsado++
		aAdd(aHeader, Q110GetSX3("QKP_LEGEND", "", "") )
	Endif
Endif

If !Empty(GetSX3Cache("QKP_SEQ","X3_CAMPO"))
	If X3Uso(GetSX3Cache("QKP_SEQ","X3_USADO")) .and. cNivel >= GetSX3Cache("QKP_SEQ","X3_NIVEL")
		nUsado++
		aAdd(aHeader, Q110GetSX3("QKP_SEQ", "", "") )
	Endif
Endif

For nX := 1 To Len(aStruAlias)
	
	If (AllTrim(aStruAlias[nX,1])) == "QKP_LEGEND" .or. (AllTrim(aStruAlias[nX,1])) == "QKP_SEQ"
		Loop
	Endif

	If lPend .and. (AllTrim(aStruAlias[nX,1]) == "QKP_MAT" .or. AllTrim(aStruAlias[nX,1]) == "QKP_NOME")
		Loop
	Endif

	If X3Uso(GetSX3Cache(aStruAlias[nX,1],"X3_USADO"))  .and. cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL")
		nUsado++
		aAdd(aHeader, Q110GetSX3(aStruAlias[nX,1], "", "") )
	Endif

	If lPend .and. (AllTrim(aStruAlias[nX,1]) == "QKP_PECA" .or. AllTrim(aStruAlias[nX,1]) == "QKP_REV")
		nUsado++
		aAdd(aHeader, Q110GetSX3(aStruAlias[nX,1], "", "") )
	Endif	
Next nX 

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QPP110Acols³ Autor ³Eduardo de Souza      ³ Data ³ 31/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP110Acols()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao no mBrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPP110Acols(nOpc)

Local nI   := 0
Local nPos := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols               					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3
	aCols := Array(1,nUsado+1)
	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			If Alltrim(Upper(aHeader[nI,2])) == "QKP_LEGEND"
				aCols[1,nI] := LoadBitmap( GetResources(), "BR_AMARELO" )
			Else
				aCols[1,nI] := Space(aHeader[nI,4])
			Endif	
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := CtoD("  /  /  ")
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QKP_SEQ" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	aCols[1,nUsado+1] := .F.
Else
	DbSelectArea("QKP")
	DbSetOrder(2)
	DbSeek(xFilial()+QKG->QKG_PECA+QKG->QKG_REV)
	While QKP->(!Eof()) .and. xFilial() == QKG->QKG_FILIAL .and.;
		QKP->QKP_PECA+QKP->QKP_REV == QKG->QKG_PECA+QKG->QKG_REV
		
		aAdd(aCols,Array(nUsado+1))
		For nI := 1 to nUsado
			If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				If AllTrim(Upper(aHeader[nI,2])) == "QKP_LEGEND"
					aCols[Len(aCols),nI] := LoadBitmap( GetResources(), Alltrim(QKP->QKP_LEGEND) )
				Else
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))				
				Endif	
			Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				If cCpo == "QKP_LEGEND"
					aCols[Len(aCols),nI] := LoadBitmap( GetResources(), Alltrim(QKP->QKP_LEGEND) )
				Else
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Endif	
			Endif
		Next nI
		aCols[Len(aCols),nUsado+1] := .F.
		DbSkip()
	Enddo
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Como a cor esta ligada ao registro atualizo antes de exibir a tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI = 1 To Len(aCols)
	QPP110CorIt(nI)
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q110Grav   ³ Autor ³ Eduardo de Souza     ³ Data ³ 02/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao do Cronograma - Incl./Alter.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q10Grav(ExpN1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao no mBrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Q110Grav(nOpc)

Local nIt
Local nCont
Local nNumSeq  		:= 1
Local nPosDel  		:= Len(aHeader) + 1
Local nCpo
Local bCampo   		:= { |nCPO| Field(nCPO) }
Local lGraOk   		:= .T.   // Indica se todas as gravacoes obtiveram sucesso
Local nPosSEQ	    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QKP_SEQ"})
Local nPosAtiv 		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_ATIV"	})
Local cEspecie 		:= "QPPA110 " 


DbSelectArea("QKG")
DbSetOrder(1)

Begin Transaction
If Inclui
	RecLock("QKG",.T.)
Else
	RecLock("QKG",.F.)
Endif

For nCont := 1 To FCount()
	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QKG"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif
Next nCont

QKG->QKG_FILRES := cFilAnt
QKG->QKG_REVINV := Inverte(QKG->QKG_REV)
MsUnLock()
If Inclui
	FKCOMMIT()
EndIf

DbSelectArea("QKP")
DbSetOrder(2)
// Excluo registros pois na alteracao pode haver duplicacao
If lLacuna	
    DbSeek(xFilial("QKP")+ M->QKG_PECA + M->QKG_REV + "001",.T.)
    While !Eof() .And. xFilial("QKG")+ M->QKG_PECA + M->QKG_REV == xFilial("QKP")+ QKP->QKP_PECA + QKP->QKP_REV
        RecLock("QKP",.F.)
        DbDelete() 
        MsUnlock()
        QKP->(DbSkip())
    End
EndIf
For nIt := 1 To Len(aCols)
	If !aCols[nIt, nPosDel] .and. !Empty(aCols[nIt,nPosAtiv])  // Verifica se o item foi deletado
		If Altera
			If !lLacuna	
				If DbSeek(xFilial("QKP")+ M->QKG_PECA + M->QKG_REV + StrZero(nIt,Len(QKP->QKP_SEQ)))
					RecLock("QKP",.F.)
				Else
					RecLock("QKP",.T.)
				Endif
			Else
				RecLock("QKP",.T.)
			EndIf
		Else
			RecLock("QKP",.T.)
		Endif
		
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
				QKP->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos  nao informados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QKP->QKP_FILIAL		:= xFilial("QKG")
		QKP->QKP_PECA		:= M->QKG_PECA
		QKP->QKP_REV 	 	:= M->QKG_REV
		QKP->QKP_FILMAT		:= cFilAnt
		QKP->QKP_REVINV 	:= Inverte(QKP->QKP_REV)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens do acols                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se MV_QLACUN estiver com "S" nao vai refazer sequencia       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lLacuna
			QKP->QKP_SEQ := StrZero(nNumSeq,Len(QKP->QKP_SEQ))
		Else 
			QKP->QKP_SEQ := aCols[nIt,nPosSeq]		
		EndIf
		
		nNumSeq++
		MsUnlock()
	Else
		If DbSeek(xFilial("QKP")+ M->QKG_PECA + M->QKG_REV + aCols[nIt,nPosSeq])
			If !Empty(QKP->QKP_CHAVE)
				QO_DelTxt(QKP->QKP_CHAVE,cEspecie)    //QPPXFUN
			Endif

			RecLock("QKP",.F.)
			DbDelete() 
			MsUnlock()
		Endif
	Endif
Next nIt
FKCOMMIT()

End Transaction

If ExistBlock("QP110INCL")
	ExecBlock("QP110INCL",.F.,.F.,{QKG->QKG_FILIAL,QKG->QKG_PECA,QKG->QKG_REV})			
Endif

Return lGraOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPPA110Exc  ³ Autor ³ Eduardo de Souza      ³ Data ³04/08/01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclusao														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA110Exc()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA110                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPP110Exc()

Local cEspecie	:= "QPPA110"

DbSelectArea("QKG")
DbSetOrder(1)
If DbSeek(xFilial("QKG")+ QKG->QKG_PECA + QKG->QKG_REV)
	If MsgYesNo(STR0008,STR0009) // "Tem certeza que deseja Excluir este Registro" ### "Atencao"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Deleta Atividades do Cronograma					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("QKP")
		DbSetOrder(2)
		If DbSeek(xFilial("QKP") + QKG->QKG_PECA + QKG->QKG_REV)
			Do While QKP->QKP_FILIAL+QKP->QKP_PECA+QKP->QKP_REV == QKG->QKG_FILIAL+QKG->QKG_PECA+QKG->QKG_REV
				If !Empty(QKP->QKP_CHAVE)
					QO_DelTxt(QKP->QKP_CHAVE,cEspecie+" ")    //QPPXFUN
				Endif

				RecLock("QKP",.F.)
				QKP->(DbDelete())
				MsUnlock()
				FKCOMMIT()
				QKP->(DbSkip())
			Enddo
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Deleta Cabecalho do Cronograma			           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("QKG")

		If !Empty(QKG->QKG_CHAVE)
			QO_DelTxt (QKG->QKG_CHAVE,cEspecie+"A")    //QPPXFUN
		Endif

		RecLock("QKG",.F.)
		QKG->(DbDelete())
		MsUnlock()
		FKCOMMIT()
	Endif
Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QPP110TudOk³ Autor ³ Eduardo de Souza     ³ Data ³ 02/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP110TudOk                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPP110TudOk(nOpc)

Local lRet   	 	:= .T.
Local nIt 		 	:= 0
Local nTot		 	:= 0
Local nPosDel 	 	:= Len(aHeader) + 1
Local nPosAtiv	 	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_ATIV" })

lRet:= QPP110LinOk()

If lRet

	For nIt := 1 To Len(aCols)
		If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosAtiv])
			nTot ++
		Endif
		QPP110CorIt(nIt)
	Next nIt
	
	If Empty(M->QKG_PECA) .Or. Empty(M->QKG_REV) .Or. nTot == Len(aCols) .Or. Empty(aCols[n,nPosAtiv]) .and. !aCols[n, nPosDel]
		Help("", 1, "QPP110OBRI") //"Existem campos obrigatorios nao informados" 
		lRet:=.F.
	EndIf
	
	If lRet
		lRet := Q110ValiRv(nOpc)
	Endif

Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q110ValiRvºAutor  ³Eduardo de Souza    º Data ³  01/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se Peca/Revisao ja esta cadastrada                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Q110ValiRv(ExpN1)											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 - Numero da opcao do Cadastro                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA110                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q110ValiRv( nOpc )

Local cCodCli 	:= ""
Local cLojaCli 	:= ""
Local lRet   	:= .t.

DbSelectArea("QKG")
DbSetOrder(1) //QKF_FILIAL+QKF_PECA+QKF_REV
If DbSeek(xFilial("QKG")+M->QKG_PECA+M->QKG_REV) .And. nOpc == 3 // Se encontrar e for Inclusao
	lRet:= .f.
	Help("", 1, "Q140PCEXIS")	// "Numero de Revisao ja cadastrada para esta Peca "
Else
	lRet:= .t.
EndIf

If lRet
	DbSelectArea("QK1")
	DbSetOrder(1) // QK1_FILIAL+QK1_PECA+QK1_REV
	If DbSeek(xFilial("QK1")+M->QKG_PECA+M->QKG_REV)
		M->QKG_DESCPC := QK1->QK1_DESC
		cCodCli  := QK1->QK1_CODCLI
		cLojaCli := Qk1->QK1_LOJCLI
		DbSelectArea("SA1")
		DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
		If DbSeek(XFilial("SA1")+cCodCli+cLojaCli)
			M->QKG_CLIENT := SA1->A1_NOME
		EndIf
	Else
		lRet:= .F.
		Help("", 1, "Q140RVPCNC")	// "Revisao para esta Peca nao existe"
		M->QKG_DESCPC := " "
		M->QKG_CLIENT := " "
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q110ValiPcºAutor  ³Eduardo de Souza    º Data ³  01/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se Peca existe 									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³Q110ValiPc(ExpN1)											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA110                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q110ValiPc()

Local lRet:= .T.

DbSelectArea("QK1")
DbSetOrder(1) // QK1_FILIAL+QK1_PECA+QK1_REV

If !Empty(M->QKG_PECA)
	If !DbSeek(xFilial("QK1")+M->QKG_PECA)
		lRet:= .F.
		Help("", 1, "Q140PCNC") // "Peca nao Cadastrada"
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QPP110LinOk³ Autor ³ Eduardo de Souza     ³ Data ³ 01/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP110LinOk                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPP110LinOk

Local lRet       := .t.
Local nCont      := 0
Local nPosAtiv   := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QKP_ATIV"   })
Local nPosDel    := Len(aHeader) + 1        
Local nPosSEQ	 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QKP_SEQ"}) 

If aCols[ n, nUsado + 1 ]  = .f.
	If nPosAtiv # 0
		Aeval( aCols, { |X| If( X[nPosDel]==.F. .And. X[ nPosAtiv ] == aCols[ N, nPosAtiv ] , nCont ++, nCont ) } )
		If nCont > 1
			Help( " ", 1, "QPP110JAEX") // "Informacao ja cadastrada"
			lRet:= .F.
		EndIf
	EndIf
	
	If Empty(aCols[n,nPosAtiv  ]) .And. !aCols[n, nPosDel]
		lRet := .F.
		Help("", 1, "QPP110OBRI") // "Existem campos obrigatorios nao informados"
	EndIf
EndIf

If lLacuna
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a Sequencia ja existe ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCont := 0
	aEval( aCols, { |x| Iif(x[nPosDel] == .F. .and. x[nPosSEQ] == aCols[n, nPosSEQ], nCont++, nCont)})
	If nCont > 1
		Help(" ", 1, "QPP110JAEX") // "Informacao ja cadastrada"
		lRet := .F.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Re-Organiza o Acols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		aCols := aSort(aCols,,,{|x,y| x[nPosSEQ]+x[nPosAtiv] < y[nPosSEQ]+y[nPosAtiv]}) 
		oGet:oBrowse:Refresh()    
	Endif
EndIf
	
QPP110CorIt()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPDescPc ºAutor  ³Eduardo de Souza    º Data ³  03/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza Descricao da Peca                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ QPPDescPc(ExpC1,ExpC2,ExpL1)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 = Numero da Peca                                     º±±
±±º          ³ ExpC2 = Numero da Revisao                                  º±±
±±º          ³ ExpL1 = Indica se e' gatilho                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA110                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPDescPc(cNumPc,cRev, lGatilho)

Local cArea   	 := Alias()
Local nOrdem  	 := IndexOrd()
Local cDescPc 	 := ""
Default lGatilho := .t.

If ValType("INCLUI") == "U"
	Private Inclui := .F.
Endif

If !Inclui .or. lGatilho   // Se Inic. Padrao ou gatilho
	dbSelectArea("QK1")
	QK1->(dbSetOrder(1))
	If DbSeek(xFilial("QK1")+cNumPc+cRev)
		cDescPc := Padr(QK1->QK1_DESC,150)
	Endif
Endif
dbSelectArea( cArea )
dbSetOrder( nOrdem )

Return ( cDescPc )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPClienteºAutor  ³Eduardo de Souza    º Data ³  03/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza Nome do Cliente                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ QPPCliente(ExpC1,ExpC2,ExpL1)                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 = Numero da Peca                                     º±±
±±º          ³ ExpC2 = Numero da Revisao                                  º±±
±±º          ³ ExpL1 = Indica se e' gatilho                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA110                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPCliente(cNumPc,cRev, lGatilho)

Local cArea   	 := Alias()
Local nOrdem  	 := IndexOrd()
Local cCliente	 := ""
Default lGatilho := .t.


If ValType("INCLUI") == "U"
	Private Inclui := .F.
Endif


If !Inclui .or. lGatilho   // Se Inic. Padrao ou gatilho
	dbSelectArea("QK1")
	QK1->(dbSetOrder(1))
	If DbSeek(xFilial("QK1")+cNumPc+cRev)
		cCodCli  := QK1->QK1_CODCLI
		cLojaCli := Qk1->QK1_LOJCLI
		DbSelectArea("SA1")
		DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
		If DbSeek(xFilial("SA1")+cCodCli+cLojaCli)
			cCliente := Padr(SA1->A1_NOME,40)
		EndIf
	EndIf
EndIf
dbSelectArea( cArea )
dbSetOrder( nOrdem )

Return ( cCliente )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QPPNUSR  ³ Autor ³ Eduardo de Souza      ³ Data ³ 03/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher o nome do usuario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPNUSR(ExpC1,ExpC2,ExpL1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Filial                                   ³±±
±±³          ³ ExpC2 = Codigo do Funcionario                              ³±±
±±³          ³ ExpL1 = Indica se e' gatilho                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPNUSR(cCodFI,cCodDe,lGatilho)

Local cArea  	 := Alias()
Local nOrdem 	 := IndexOrd()
Local cNome  	 := ""
Default lGatilho := .t.

If ValType("INCLUI") == "U"
	Private Inclui := .F.
Endif

// Verifica se o arquivo QAA est  aberto
If !Inclui .or. lGatilho   // Se Inic. Padrao ou gatilho
	dbSelectArea("QAA")
	QAA->(dbSetOrder(1))
	If dbSeek(cCodFI + cCodDe)
		cNome := Padr(QAA->QAA_NOME,40)
	Endif
Endif

dbSelectArea( cArea )
dbSetOrder( nOrdem )

Return ( cNome )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QP110EdTxt ³ Autor ³  Eduardo de Souza          ³ Data ³ 04/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Abra a janela para digitacao da observacao do cronograma          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QP110EdTxt( ExpN1, ExpC1, ExpC2, ExpC3 )                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - Opcao do mBrowse										  ³±±
±±³           ³ ExpC1 - Numero da Peca                                            ³±±
±±³           ³ ExpC2 - Numero da Revisao                                         ³±±
±±³           ³ ExpC3 - Chave de Ligacao                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QPPA110                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QP110EdTxt( nOpc, cNumPc, cRev, cChave)

Local cCabec    := ""
Local cTitulo   := ""
Local cEspecie  := "QPPA110"
Local nTamLin   := TamSX3( "QKO_TEXTO" )[1]
Local lEdit     := .f.
Local axTextos  := {}
Local cCod      := ""
Local nSaveSX8	:= GetSX8Len()

Default cNumPc  := M->QKG_PECA
Default cRev    := M->QKG_REV
Default cChave  := M->QKG_CHAVE

cCod  := STR0026 + AllTrim(cNumPc) + STR0027 + cRev //"Peca: "###" - Rev: "

DbSelectArea("QKG")
DbSetOrder(1)

If Empty( cNumPc ) .Or. Empty( cRev )
	Help("", 1, "QPP110CABE") // "Preencha o Cabecalho do Cronograma para atualizar as Atividades Padrao"
	Return .f.
EndIf

Titulo := OemtoAnsi( STR0014 )  // "Observacoes do Cronograma"
cCabec := OemtoAnsi( STR0014 )  // "Observacoes do Cronograma"

If Empty(cChave)
	cChave := GetSXENum("QKG", "QKG_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	If !Inclui
		RecLock( "QKG", .F. )
		QKG->QKG_CHAVE := cChave
		MsUnLock()
		FKCOMMIT()
	Endif
	M->QKG_CHAVE:= cChave
Else
	If !Inclui
		cChave := QKG->QKG_CHAVE
	EndIf
EndiF

If nOpc <> 2 .And. nOpc <> 5
	lEdit := .t.
EndIf

If QO_TEXTO( cChave, cEspecie+"A", nTamlin, cTitulo, cCod, @axtextos, 1, cCabec, lEdit )
	QO_GrvTxt( cChave, cEspecie+"A", 1, @axtextos )
EndIf

Return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPP110OBS ³ Autor ³ Eduardo de Souza      ³ Data ³ 06/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra Observacoes da Atividade           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPP110OBS(ExpN1)                               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA110													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramir ³27.08.01³----- ³ Alteracao do retorno da funcao         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPP110Obs(nOpc)

Local cChave  	:= ""
Local cCabec 	:= ""
Local cTitulo 	:= ""//OemToAnsi(STR0007) //"Observacao da Atividade"
Local nTamLin 	:= TamSX3("QKO_TEXTO")[1]
Local nPosChave := aScan(aHeader,{ |x| AllTrim(x[2]) == "QKP_CHAVE"  } )
Local cEspecie  := "QPPA110 "   //Para gravacao de textos
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()

If !Inclui
	M->QKG_PECA := QKG->QKG_PECA
	M->QKG_REV  := QKG->QKG_REV
EndIf

If INCLUI .Or. ALTERA
	lEdit := .T.
Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos
cCabec		:= OemToAnsi(STR0007) //"Observacao da Atividade"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/obtem a chave de ligacao com o texto da Peca/Rv     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aCols[n,nPosChave]) .and. lEdit
	cChave := GetSXENum("QKP", "QKP_CHAVE",,5)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	aCols[n,nPosChave] := cChave
Else
	cChave := aCols[n,nPosChave]
EndIf

If !Empty(M->QKG_PECA)
	cInf := STR0026 + AllTrim(M->QKG_PECA) + STR0027 + M->QKG_REV + " - " + OemToAnsi(STR0010) + StrZero(n,Len(QKP->QKP_SEQ)) //"Item: " //"Peca: "###" - Rev: "
Else
	cInf := STR0028 //"Atividades Pendentes"
Endif

If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	QO_GrvTxt(cChave,cEspecie,1,@axTextos)
Endif	

Return .F.

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPCarQKZ ³ Autor ³ Robson Ramiro Oliveira³ Data ³ 13/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega vetor com as atividades padroes    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPPCarQKZ(oGet)                                 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da Getdados                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA110													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPPCarQKZ(oGet)

Local lRet		 	:= .T.
Local nCnt		 	:= 1
Local nPosCodAti	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_CODATI"	})
Local nPosAtiv   	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_ATIV"		})
Local nPosPComp  	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_PCOMP"		})
Local nPosObs    	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_OBS"		})
Local nPosSEQ		:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_SEQ"		})
Local nPosLEGEND	:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QKP_LEGEND"	})
Local nI

If Inclui
	If Empty(M->QKG_PECA) .or. Empty(M->QKG_REV) .or. Empty(M->QKG_DATA)
		lRet := .f.
		Help("", 1, "QPP110CABE") // "Preencha o Cabecalho do Cronograma para atualizar as Atividades Padrao"
	Else
		If Len(aCols) == 1.and. Empty(aCols[1][nPosCodAti]) .and. Empty(aCols[1][nPosAtiv])  .or. (len(acols) == 1 .and. acols[1,len(aheader)+1])
			If MsgYesNo(STR0011,STR0012) // "Deseja utilizar as Atividades do Cronograma Padrao" ### " Atividades"
				DbSelectArea("QKZ")
				DbSetOrder(1)
				If DbSeek(xFilial())
					aCols := {}

					Do While !Eof() .AND. xFilial("QKZ") = QKZ->QKZ_FILIAL
						aAdd(aCols,Array(nUsado+1))
						For nI = 1 To Len(aHeader)
							If aHeader[nI,8] == "C"
								aCols[Len(aCols),nI] := Space(aHeader[nI,4])
							ElseIf aHeader[nI,8] == "N"
								aCols[Len(aCols),nI] := 0
							ElseIf aHeader[nI,8] == "D"
								aCols[Len(aCols),nI] := CtoD("  /  /  ")
							ElseIf aHeader[nI,8] == "M"
								aCols[Len(aCols),nI] := ""
							Else
								aCols[Len(aCols),nI] := .F.
							Endif
						Next nI

						aCols[nCnt][nPosCodAti]		:= QKZ->QKZ_COD
						aCols[nCnt][nPosAtiv]		:= QaxIdioma("QKZ->QKZ_DESC","QKZ->QKZ_DESCEN","QKZ->QKZ_DESCSP")
						aCols[nCnt][nPosObs]		:= "<< Enter >>"
						aCols[nCnt][nPosPComp]		:= "0"
						aCols[nCnt][nPosSEQ	]		:= StrZero(nCnt,Len(QKP->QKP_SEQ))
						aCols[nCnt][nPosLEGEND]		:= "ENABLE"
						aCols[Len(aCols),nUsado+1]	:= .F.

						nCnt++
						QKZ->(DbSkip())
					Enddo
				Endif
			Endif
		Else
			lRet:= .f.
			Help("", 1, "QPP110Acol") // "Para utilizar o preenchimento de atividades padrao, nao devera ter nenhuma atividade preenchida"
		Endif
	Endif
Endif

oGet:ForceRefresh()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPP110CorB ³ Autor ³Eduardo de Souza        ³ Data ³ 08/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Retorna o numero da opcao correspondente a cor da situacao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QPP110CorB(ExpN1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero Referente a Cor								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QPPA110                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³13.08.03³      ³ Alteracao e inclusao nos conceitos       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPP110CorB(nOpcQKP)

Local nRet	:= nOpcQKP
Local nDias	:= GetMv("MV_QNDIAS")
Local cRet	:= ""

If nOpcQKP == 1 .Or. nOpcQKP == 2 .Or. nOpcQKP == 3 .or. nOpcQKP == 4
	DbSelectArea("QKP")
	DbSetOrder(2)
	If DbSeek(xFilial("QKP")+QKG->QKG_PECA+QKG->QKG_REV)
		While QKP->(!Eof()) .And. 	QKG->QKG_FILIAL+QKG->QKG_PECA+QKG->QKG_REV ==;
												QKP->QKP_FILIAL+QKP->QKP_PECA+QKP->QKP_REV
			
			If !Empty(QKP->QKP_DTINI) .and. !Empty(QKP->QKP_DTFIM) .and. QKP->QKP_PCOMP == "4"
				cRet+= "4"
			Elseif Empty(QKP->QKP_DTINI) .or. Empty(QKP->QKP_DTPRA)
				cRet+= "1"
			Elseif DtoS(dDataBase) >= DtoS(QKP->QKP_DTINI) .and. DtoS(dDataBase) <= DtoS(QKP->QKP_DTPRA);
					.and. (QKP->QKP_DTPRA - dDataBase) > nDias
				cRet+= "1"
			Elseif DtoS(dDataBase) > DtoS(QKP->QKP_DTPRA) .and. !Empty(QKP->QKP_DTPRA)
				cRet+= "3"
				Exit
			Elseif (QKP->QKP_DTPRA - dDataBase) <= nDias
				cRet+= "2"
			Else
				cRet+= "1"
			Endif
			
			QKP->(DbSkip())
		EndDo
	EndIf

	If "3"$cRet
		nRet := 3
	Elseif "2"$cRet
		nRet := 2
	Elseif "1"$cRet
		nRet := 1
	Elseif "4"$cRet
		nRet := 4
	Endif
EndIf

DbSelectArea("QKG")
Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QPP110Email³ Autor ³Eduardo de Souza        ³ Data ³ 08/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Dispara email para responsavel da atividade                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QPP110Email(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero Referente a Cor								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QPPA110                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPP110Email()

Local nMvDias  := GetMV("MV_QPPEMAI")
Local cEmail   := GetMV("MV_RELACNT")
Local dDtAtual := dDataBase
Local aUsrMail := {}
Local nOrdQAA 
Local nRegQAA 

DbSelectArea("QKG")
DbSetOrder(1)
DbGoTop()

Do While QKG->(!Eof()) 
	DbSelectArea("QKP")
	DbSetOrder(2)
	If DbSeek(xFilial("QKP")+QKG->QKG_PECA+QKG->QKG_REV)
		Do While QKP->(!Eof()) .And. 	QKG->QKG_FILIAL+QKG->QKG_PECA+QKG->QKG_REV ==;
										QKP->QKP_FILIAL+QKP->QKP_PECA+QKP->QKP_REV
			
			If (nMvDias == (QKP->QKP_DTPRA - dDtAtual)) .Or. ;
				(!Empty(QKP->QKP_DTPRA) .And. !Empty(QKP->QKP_DTINI);
			 	.And.  nMvDias > (QKP->QKP_DTPRA - QKP->QKP_DTINI))

         		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	         	//³ Envia email para o usuario Resp. da Atividade	    ³
	         	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				nOrdQAA:=QAA->(IndexOrd())
				nRegQAA:=QAA->(Recno())
				QAA->(DbSetOrder(1))             

				If QAA->(DbSeek( QKP->QKP_FILMAT + QKP->QKP_MAT ))
					If !Empty(QAA->QAA_EMAIL) .And. (QKP->QKP_AVEMAI <> "S")

						QPPEmail(@aUsrMail, QKP->QKP_PECA,QKP->QKP_REV,QKP->QKP_DTINI,QKP->QKP_DTPRA,;
			   						QKP->QKP_ATIV, QAA->QAA_EMAIL,QKP->QKP_FILMAT,QAA->QAA_APELID,QKP->QKP_MAT,"")

			  			RecLock("QKP",.F.)
			   	  		QKP->QKP_AVEMAI:= "S"
			   	  		MsUnlock()
				   	EndIf
				EndIf   

				QAA->(dbSetOrder(nOrdQAA))
				QAA->(dbGoTo(nRegQAA))
			EndIf

			QKP->(DbSkip())
		EndDo
	EndIf

	QKG->(DbSkip())
EndDo
FKCOMMIT()

If Len(aUsrMail) > 0
	QaEnvMail(aUsrMail,,,,cEmail)
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QPPEMail    ³ Autor ³ Eduardo de Souza      ³ Data ³08/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia eMail para o Usuario Comunicando as Atividades         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPEMail(@aUsrMail,cDocto,cRv,cAtividade,cMail,cFilMat,      ³±±
±±³          ³ cApelido,cCodMat,cAttach)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 1 aUsrMail  :retorna todos os dados referente aos emails     ³±±
±±³          ³ 2 cDocto    :Numero da Peca                                  ³±±
±±³          ³ 3 cRv       :Numero da Revisao da Peca                       ³±±
±±³          ³ 4 dDataIni  :Data Inicial                                    ³±±
±±³          ³ 5 dDataPra  :Data Prazo                                      ³±±
±±³          ³ 6 cAtividade:Atividade do Cronograma                         ³±±
±±³          ³ 7 cMail     :eMail do Responsavel                            ³±±
±±³          ³ 8 cFilMat   :Codigo da Filial                                ³±±
±±³          ³ 9 cApelido  :Nome do Usuario                                 ³±±
±±³          ³10 cCodMat   :Codigo do Usuario                               ³±±
±±³          ³11 cAttach   :Arquivo anexado no email                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/           
Function QPPEMail(aUsrMail,cPeca,cRev,dDataIni,dDataPra,cAtividade,cMail,cFilMat,cApelido,cCodMat,cAttach)

Local cMsg		:= ""     
Local cSubject	:= ""
Local aMsg		:= {}
Local nQAARecno := QAA->(Recno())
Local nQAAOrd	:= QAA->(IndexOrd())

Default cAttach	:= "" 
Default cCodMat := ""

cSubject := Trim(cPeca)+"-" + Trim(Posicione("QK1",1,xFilial("QK1")+cPeca+cRev,"QK1_DESC")) + "-" +Trim(cRev)+"-"+Trim(cAtividade)+" - "+DTOC(dDataBase)

cMsg := cApelido
cMsg := OemToAnsi(STR0016) + " " + DToC(dDataIni) + " " + OemToAnsi(STR0017)+ " " + DToC(dDataPra)
cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)    
cMsg += OemToAnsi(STR0018) + " " + cPeca   + " " + Trim(Posicione("QK1",1,xFilial("QK1")+cPeca+cRev,"QK1_DESC")) + " " + OemToAnsi(STR0019) + " " + cRev
cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)    
cMsg += OemToAnsi(STR0020) + " " + cAtividade  
cMsg += CHR(13) + CHR(10) + CHR(13) + CHR(10)    
cMsg += CHR(13) + CHR(10) 
cMsg += OemToAnsi(STR0015)  //"Mensagem gerada Automaticamente pelo Modulo SIGAPPAP"

aMsg:=  { { cSubject,cMsg,cAttach } }     

aadd(aUsrMail,{ AllTrim(cApelido),Trim(cMail),aMsg })

QAA->(dbSetOrder(nQAAOrd))
QAA->(dbGoTo(nQAARecno))

Return nil			

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPValPra ºAutor  ³Eduardo de Souza    º Data ³  09/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se Data Prazo eh superior que a Inicial              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³QPPValPra()     											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA110                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPValPra()

Local lRet		:= .T.
Local nPosDtIni := aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTINI"  })

If M->QKP_DTPRA < Acols[n][nPosDtIni] .And. !Empty(M->QKP_DTPRA)
	lRet := .F.
	Help("", 1, "QPP110PRA") // "Data prazo nao pode ser inferior que a Data Inicio"
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPValFim ºAutor  ³Eduardo de Souza    º Data ³  09/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se Data Final eh superior que a Inicial              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³QPPValFim()      											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA110                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QPPValFim()

Local lRet		:= .T.
Local nPosDtIni := aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTINI"  })

If M->QKP_DTFIM < Acols[n][nPosDtIni] .And. !Empty(M->QKP_DTFIM)
	lRet := .F.
	Help("", 1, "QPP110FIM") // "Data Final nao pode ser inferior que a Data Inicial"
EndIf

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA110Lege ³ Autor ³ Robson Ramiro A.Olive³ Data ³ 04.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA110Lege

Local aLegenda := {	{ 'ENABLE',		OemtoAnsi(STR0022)	},;  	//"Cronograma em dia"
					{ 'BR_AMARELO',	OemtoAnsi(STR0023)	},;  	//"Prazo para conclusao expirando"
					{ 'DISABLE',	OemtoAnsi(STR0024)	},;		//"Cronograma Atrasado"
					{ 'BR_CINZA',	OemtoAnsi(STR0031) } } 		//"Cronograma Concluido"

BrwLegenda(cCadastro,STR0025,aLegenda) //"Legenda"

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPP110CorIt³ Autor ³Robson Ramiro A. Oliveir³ Data ³ 18/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a cor correspondente ao status                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QPP110CorIt(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da linha ou do contador   					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QPPA110                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPP110CorIt(nIt)

Local nRet
Local nDias := GetMv("MV_QNDIAS")
Local aCor 	:= {	"ENABLE" 	,;	// Verde    - Em dia
					"BR_AMARELO",;	// Amarelo  - Expirando nos proximos dias
					"DISABLE"	,; 	// Vermelho - Item Atrasado
					"BR_CINZA"	 }	// Cinza 	- Concluido
					
Local nPosDTINI		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTINI"	})
Local nPosDTFIM		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTFIM"	})
Local nPosDTPRA		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_DTPRA"	})
Local nPosPCOMP		:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_PCOMP"	})
Local nPosLEGEND	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKP_LEGEND"	})

Default nIt := n

If !Empty(aCols[nIt,nPosDTINI]) .and. !Empty(aCols[nIt,nPosDTFIM]) .and. aCols[nIt,nPosPCOMP] == "4"
	nRet := 4
Elseif Empty(aCols[nIt,nPosDTINI]) .or. Empty(aCols[nIt,nPosDTPRA])
	nRet := 1
Elseif DtoS(dDataBase) >= DtoS(aCols[nIt,nPosDTINI]) .and. DtoS(dDataBase) <= DtoS(aCols[nIt,nPosDTPRA]);
		.and. (aCols[nIt,nPosDTPRA] - dDataBase) > nDias
	nRet := 1
Elseif DtoS(dDataBase) > DtoS(aCols[nIt,nPosDTPRA]) .and. !Empty(aCols[nIt,nPosDTPRA])
	nRet := 3
Elseif (aCols[nIt,nPosDTPRA] - dDataBase) <= nDias
	nRet := 2
Else
	nRet := 1
Endif

aCols[nIt,nPosLEGEND] := aCor[nRet]

Return
//--------------------Q110GetSX3-------------------------------------------------
/*/{Protheus.doc} Q215GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 18/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q110GetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_ARQUIVO'),;
              GetSx3Cache(cCampo,'X3_CONTEXT') }
Return aHeaderTmp
