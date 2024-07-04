#INCLUDE "QPPA121.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA121  ³ Autor ³ Cleber Souza          ³ Data ³ 05/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³FMEA de Projeto (ListBox)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA121(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³ 									      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  ,	 0, 1,,.F.},; 	//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA121Incl",	 0, 2},; 		//"Visualizar"
					{ OemToAnsi(STR0003), "PPA121Incl",	 0, 3},; 		//"Incluir"
					{ OemToAnsi(STR0004), "PPA121Incl",	 0, 4},; 		//"Alterar"
					{ OemToAnsi(STR0005), "PPA121Incl",	 0, 5},; 		//"Excluir"
					{ OemToAnsi(STR0030), "QPPR120(.T.)",0, 6,,.F.}}	//"Imprimir"

Return aRotina

Function QPPA121
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006)  //"FMEA de Projeto"

Private aRotina := MenuDef()

Private lFMEA4a := GetMV("MV_QVEFMEA",.T.,"3") == "4" //FMEA 4a. EDICAO...

DbSelectArea("QK5")    
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QK5",,,,,,)

Return  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA121Incl  ³ Autor ³ Cleber Souza          ³ Data ³05/10/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA120Incl(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA121Incl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local oEncQK5   := NIL 
Local lOk 		:= .F.
Local aButtons	:= {}
Local aFields   := Iif(!lFMEA4a,{STR0026,STR0013, STR0014,STR0016,STR0018,STR0019,STR0021,STR0031,STR0022,STR0013,STR0016,STR0018,STR0019},;     //"Seq.","Server", "Class","Ocorr.","Detec","NPR","Responsavel","Nome","Prazo","Sever.","Ocorr","Detec","NPR"
							     {STR0026,STR0012,STR0013, STR0015,STR0037,STR0018,STR0038,STR0020,STR0021,STR0023,STR0018,STR0013,STR0018,STR0016})  
Local aSizes    := {20, 20, 20, 20, 20, 35, 40, 60, 40, 20, 20, 20, 35 }

Local bBlock    := {||Afill(Array(Len(aSizes))," ")} 
Local aSize:= aInfo := aObjects := aPosObj :={}
Local oBtn, oBtn2
Local nY        := 0
Local nItFMEA 
Local nTamTela  := 0
Local oPanel		:= NIL
Local oPanel1		:= NIL
Local oPanel2		:= NIL
Local oPanel5		:= NIL

Private oPanel3		:= NIL
Private oPanel4		:= NIL
Private oScrollBox 	:= NIL
Private oBrwCar		:= NIL
Private nLin 		:= 1
Private nCont 		:= 0
Private aValues		:= {}
Private aOGets		:= {} 
Private nAtu        := 1
Private oBmp
Private oGet1,oGet2,oGet3,oGet4,oGet5,oGet6
Private oGet7,oGet8,oGet9,oGet10,oGet11,oGet12
Private oGet13,oGet14,oGet15,oGet16,oGet17,oGet18
Private oGet19,oGet20,oGet21,oGet22, oGet23, oGet24, oGet25
Private oGet	:= NIL   

SetKey( VK_F5, { || QPP121ADIC(nOpc,.T.,"B") } )                                        
SetKey( VK_F6, { || QPP121MOV("A",nOpc) } )                    
SetKey( VK_F7, { || QPP121MOV("N",nOpc) } )                                       

If lFMEA4a
	nItFMEA := 20
	nTamTela := 1356
	nPsBmp := 6		
Else
	nItFMEA := 19
	nTamTela := 1050
	nPsBmp := 5				
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula Dimensoes do Dialog.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize	 := MsAdvSize(.T.)
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }



AAdd( aObjects, { 100, 30, .T., .T. } ) // Dados da Enchoice 
AAdd( aObjects, { 100, 40, .T., .T. } ) // Dados da Getdados 
AAdd( aObjects, { 100, 30, .T., .T. } ) // Dados do Scroll
aPosObj:= MsObjSize( aInfo, aObjects, .T. ,.F.)
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"FMEA de Projeto"
						FROM aSize[7],000 To aSize[6],aSize[5] OF oMainWnd PIXEL    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Panel Primario                                         ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
oPanel5:= tPanel():New(000,000,,oDlg,,,,,,aSize[6],aSize[5])
oPanel5:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Panels Secundario                                      ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
oPanel := tPanel():New(000,000,,oPanel5,,,,,,100,aPosObj[1,3])
oPanel1:= tPanel():New(000,000,,oPanel5,,,,,,100,aPosObj[3,3])
oPanel2:= tPanel():New(000,000,,oPanel5,,,,,,100,aPosObj[2,3]/2)

oPanel:Align  := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_BOTTOM
oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice                                               ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QK5")     
RegToMemory("QK5",(nOpc==3))
oEncQK5:=MsMGet():New("QK5",nReg,nOpc,,,,,aPosObj[1],,,,,,oPanel,,,,,,,,,)
oEncQK5:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Botoes do Dialog                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aButtons := {  {"BMPINCLUIR",	{ || QPP121ADIC(nOpc,.T.,"B") }	, OemToAnsi(STR0007), OemToAnsi(STR0032)},;	//"Incluir Item"###"Inc Item"
			   {"EDIT"		, 	{ || QPP121APRO(nOpc) }	     	, OemToAnsi(STR0008), OemToAnsi(STR0033)},;  //"Aprovar / Limpar"###"Apr/Limp"
			   {"GRAF2D"    ,   { || QPPM040(M->QK5_PECA,M->QK5_REV,"1")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scrool com a tela de receptação das caracteristicas	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oScrollBox := TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o browse com as linhas das Caracteristicas			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QK6")                              

oBrwCar:= TwBrowse():New(,,,,bBlock,aFields,aSizes,oPanel1)
oBrwCar:SetArray(aValues)      
oBrwCar:lMChange      := .F.      
oBrwCar:nClrBackFocus := GetSysColor(13)
oBrwCar:nClrForeFocus := GetSysColor(14) 


oBrwCar:bLine       := {||{aValues[oBrwCar:nAt,nItFMEA],aValues[oBrwCar:nAt,4],aValues[oBrwCar:nAt,nPsBmp],;
       					aValues[oBrwCar:nAt,7],aValues[oBrwCar:nAt,9],aValues[oBrwCar:nAt,10],;
					    aValues[oBrwCar:nAt,21],aValues[oBrwCar:nAt,12],aValues[oBrwCar:nAt,13],;
					    aValues[oBrwCar:nAt,15],aValues[oBrwCar:nAt,16],aValues[oBrwCar:nAt,17],aValues[oBrwCar:nAt,18]}}


oBrwCar:bLDblClick  := {||{nAtu:=oBrwCar:nAt,QPP121REFR(nOpc)}}   

oBrwCar:Align     := CONTROL_ALIGN_ALLCLIENT	

@ 001,001 MSPANEL oPanel1 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE nTamTela,013 OF oScrollBox
@ 003	,003 SAY OemToAnsi(STR0026)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Seq."
@ 003	,036 SAY OemToAnsi(STR0010) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Item Funcao"
If lFMEA4a
	@ 003	,130 SAY OemToAnsi(STR0041) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Requisito"
	@ 003	,224 SAY OemToAnsi(STR0011)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Modo de Falha Potencial"
	@ 003	,315 SAY OemToAnsi(STR0012)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Efeito Potencial da Falha"
	@ 003	,411 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
	@ 003	,430 SAY OemToAnsi(STR0014) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Class"
	@ 003	,453 SAY OemToAnsi(STR0015)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Causa/Mecanismo Potencial da Falha"
	@ 003	,552 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
	@ 003	,570 SAY OemToAnsi(STR0017)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Controles Atuais do Projeto - P / D"
	@ 003	,670 SAY OemToAnsi(STR0039)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Causas
	@ 003	,710 SAY OemToAnsi(STR0040)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Modo de Falha
	@ 003	,755 SAY OemToAnsi(STR0018)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
	@ 003	,781 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"
	@ 003	,806 SAY OemToAnsi(STR0020)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Recomendadas"
	@ 003	,901 SAY OemToAnsi(STR0021)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Responsavel"
	@ 003	,1006 SAY OemToAnsi(STR0022)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Prazo"
	@ 003	,1056 SAY OemToAnsi(STR0023)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Tomadas"
    @ 003	,1160 SAY OemToAnsi(STR0042)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Data Efetiva
	@ 003	,1202 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
	@ 003	,1224 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
	@ 003	,1246 SAY OemToAnsi(STR0018)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
	@ 003	,1268 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"
Else
	@ 003	,120 SAY OemToAnsi(STR0011)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Modo de Falha Potencial"
	@ 003	,214 SAY OemToAnsi(STR0012)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Efeito Potencial da Falha"
	@ 003	,305 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
	@ 003	,321 SAY OemToAnsi(STR0014) 	COLOR CLR_WHITE OF oPanel1 PIXEL //"Class"
	@ 003	,337 SAY OemToAnsi(STR0015)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Causa/Mecanismo Potencial da Falha"
	@ 003	,431 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
	@ 003	,448 SAY OemToAnsi(STR0017)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Controles Atuais do Projeto - P / D"
	@ 003	,541 SAY OemToAnsi(STR0018)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
	@ 003	,559 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"
	@ 003	,586 SAY OemToAnsi(STR0020)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Recomendadas"
	@ 003	,680 SAY OemToAnsi(STR0021)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Responsavel"
	@ 003	,777 SAY OemToAnsi(STR0022)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Prazo"
	@ 003	,819 SAY OemToAnsi(STR0023)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Acoes Tomadas"
	@ 003	,911 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Sever"
	@ 003	,927 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel1 PIXEL //"Ocorr"
	@ 003	,945 SAY OemToAnsi(STR0018)  	COLOR CLR_WHITE OF oPanel1 PIXEL //"Detec"
	@ 003	,961 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel1 PIXEL //"NPR"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os objetos das Caracteristicas.						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oPanel3 := TPanel():New(15,03,"",oScrollBox, , .T., .T.,,/*RGB(200,230,247)*/,nTamTela,35,.T.,.T. ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega todas as cacteristicas.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QPP121ADIC(nOpc,oPanel3,"I")

oPanel3:Refresh()

If lFMEA4a
	// 19o Get - Item sequencial (1o na tela)
	cGet19	:= "aValues[nAtu,20]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet19+":=u,"+cGet19+")}")
	bValid	:= {|u| QPP121AtuC(nAtu)}
	oGet19 	:= TGet():New( 01, 01, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_SEQ"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet19:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",20"
	
	// 1o Get - Item Funcao
	cGet1 	:= "aValues[nAtu,1]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet1+":=u,"+cGet1+")}")
	oGet1 := TMultiGet():New(01,30,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet1:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",01"
	
	// 2o Get - Requisito para FMEA 4a Edicao...
	cGet22 	:= "aValues[nAtu,2]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet22+":=u,"+cGet22+")}")
	oGet22 := TMultiGet():New(01,125,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet22:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",02"
	
	// 2o Get - Modo de Falha Potencial
	cGet2 	:= "aValues[nAtu,3]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet2+":=u,"+cGet2+")}")
	oGet2 := TMultiGet():New(01,219,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet2:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",03"
	
	// 3o Get - Efeito Potencial da Falha
	cGet3 	:= "aValues[nAtu,4]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet3+":=u,"+cGet3+")}")
	oGet3 := TMultiGet():New(01,313,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet3:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",04"
	
	// 4o Get - Severidade
	cGet4	:= "aValues[nAtu,6]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet4+":=u,"+cGet4+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet4 := TGet():New( 01,410, bBlock,oPanel3,10,10, PesqPict("QK6","QK6_SEVER"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)
	oGet4:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",06"
	
	// 5o Get - Classificacao
	cGet5	:= "aValues[nAtu,5]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet5+":=u,"+cGet5+")}")
	
	// 6o Get - Causa/Mecanismo Potencial da Falha
	cGet6	:= "aValues[nAtu,7]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet6+":=u,"+cGet6+")}")
	oGet6 := TMultiGet():New(01,451,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet6:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",07"
	
	// 7o Get - Ocorrencia
	cGet7	:= "aValues[nAtu,8]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet7+":=u,"+cGet7+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet7 := TGet():New( 01,549, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_OCORR"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet7:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",08"
	
	// 8o Get - Controles atuais do projeto prevencao
	cGet8	:= "aValues[nAtu,9]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet8+":=u,"+cGet8+")}")
	oGet8 := TMultiGet():New(01,565,bBlock,oPanel3,46,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet8:Cargo := Str(nAtu,3)+",09"
	
	// 20o Get - Controles atuais do projeto deteccao (9o na tela)
	cGet20	:= "aValues[nAtu,21]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}")
	oGet20 := TMultiGet():New(01612,bBlock,oPanel3,46,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet20:Cargo := Str(nAtu,3)+",21"
			// 23o Get - Causa
		cGet23	:= "aValues[nAtu,24]"
		bBlock	:= &("{|u|If(Pcount()>0,"+cGet23+":=u,"+cGet23+")}")
		oGet23 := TMultiGet():New(01,659,bBlock,oPanel3,46,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
		oGet23:Cargo := Str(nAtu,3)+",24"
		
			// 24o Get - Modos de Falha
		cGet24	:= "aValues[nAtu,25]"
		bBlock	:= &("{|u|If(Pcount()>0,"+cGet24+":=u,"+cGet24+")}")
		oGet24 := TMultiGet():New(01,706,bBlock,oPanel3,46,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
		oGet24:Cargo := Str(nAtu,3)+",25"

	
	// 9o Get - Deteccao
	cGet9	:= "aValues[nAtu,10]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet9+":=u,"+cGet9+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet9 := TGet():New( 01,754, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_DETEC"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet9:Cargo := Str(nAtu,3)+",10"
	
	// 10o Get - NPR
	cGet10	:= "aValues[nAtu,11]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet10+":=u,"+cGet10+")}")
	oGet10 	:= TGet():New( 01,774, bBlock,oPanel3,20,10,PesqPict("QK6","QK6_NPR"),,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)  
	oGet10:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",11"
	
	// 11o Get - Acoes Recomendadas
	cGet11	:= "aValues[nAtu,12]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet11+":=u,"+cGet11+")}")
	oGet11 	:= TMultiGet():New(01,803,bBlock,oPanel3,93, 25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet11:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",12"
	
	// 12o Get - Responsavel
	cGet12	:= "aValues[nAtu,13]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet12+":=u,"+cGet12+")}")
	bWhen	:= {|u| Empty(aValues[nAtu,22])}
	oGet12 	:= TGet():New( 15,899, bBlock,oPanel3,100,10,PesqPict("QK6","QK6_RESP"),,,,,,,.T.,,,bWhen)
	oGet12:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",13"
	
	// 12(b)o Get - Codigo do Responsavel (21 no array)
	cGet21	:= "aValues[nAtu,22]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet21+":=u,"+cGet21+")}")
	bValid	:= {|u| QPP121BSXB(u,nAtu,oGet12)}
	oGet21	:= TGet():New( 01,899, bBlock,oPanel3,40,10,PesqPict("QK6","QK6_CODRES"),bValid,,,,,,.T.,,,,,,,,,ConSX3("QK6_CODRES"))
	oGet21:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",22"
	
	// 13o Get - Prazo
	cGet13	:= "aValues[nAtu,14]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet13+":=u,"+cGet13+")}")
	oGet13 	:= TGet():New( 01,1004, bBlock,oPanel3,40,10,,,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet13:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",14"
	
	// 14o Get - Acoes tomadas
	cGet14	:= "aValues[nAtu,15]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet14+":=u,"+cGet14+")}")
	oGet14 	:= TMultiGet():New(01,1054,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet14:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",15"
	      
	// 25o Get - Data Efetiva
	cGet25	:= "aValues[nAtu,26]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet25+":=u,"+cGet25+")}")
	oGet25 	:= TGet():New( 01, 1155, bBlock,oPanel3,40,10,,,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet25:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",26"
	
	// 15o Get - Severidade 
	cGet15	:= "aValues[nAtu,16]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet15+":=u,"+cGet15+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet15 	:= TGet():New( 01,1201, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_RSEVER"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet15:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",16"
	
	// 16o Get - Ocorrencia
	cGet16	:= "aValues[nAtu,17]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet16+":=u,"+cGet16+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet16 	:= TGet():New( 01,1223, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_ROCORR"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet16:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",17"
	
	// 17o Get - Deteccao
	cGet17	:= "aValues[nAtu,18]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet17+":=u,"+cGet17+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet17 	:= TGet():New( 01,1246, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_RDETEC"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet17:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",18"
	
	// 18o Get - NPR
	cGet18	:= "aValues[nAtu,19]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet18+":=u,"+cGet18+")}")
	oGet18 	:= TGet():New( 01,1264, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_RNPR"),,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet18:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",19"  
	
	@ 001,1291 BUTTON oBtn  PROMPT OemToAnsi(STR0024)  OF oPanel3 Pixel Size 65,13 ACTION QPP121REMO(nAtu,nOpc,.F.) //"Excluir / Recuperar"
	@ 001,425 BITMAP oBmp REPOSITORY SIZE 030,030 OF oPanel3 NOBORDER PIXEL
Else

	// 19o Get - Item sequencial (1o na tela)
	cGet19	:= "aValues[nAtu,19]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet19+":=u,"+cGet19+")}")
	bValid	:= {|u| QPP121AtuC(nAtu)}
	oGet19 	:= TGet():New( 01, 01, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_SEQ"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet19:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",19"
	
	// 1o Get - Item Funcao
	cGet1 	:= "aValues[nAtu,1]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet1+":=u,"+cGet1+")}")
	oGet1 := TMultiGet():New(01,20,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet1:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",01"
	
	// 2o Get - Modo de Falha Potencial
	cGet2 	:= "aValues[nAtu,2]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet2+":=u,"+cGet2+")}")
	oGet2 := TMultiGet():New(01,115,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet2:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",02"
	
	// 3o Get - Efeito Potencial da Falha
	cGet3 	:= "aValues[nAtu,3]"
	bBlock 	:= &("{|u|If(Pcount()>0,"+cGet3+":=u,"+cGet3+")}")
	oGet3 := TMultiGet():New(01,209,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet3:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",03"
	
	// 4o Get - Severidade
	cGet4	:= "aValues[nAtu,4]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet4+":=u,"+cGet4+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet4 := TGet():New( 01, 303, bBlock,oPanel3,10,10, PesqPict("QK6","QK6_SEVER"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)
	oGet4:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",04"
	
	// 5o Get - Classificacao
	cGet5	:= "aValues[nAtu,5]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet5+":=u,"+cGet5+")}")
	
	// 6o Get - Causa/Mecanismo Potencial da Falha
	cGet6	:= "aValues[nAtu,6]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet6+":=u,"+cGet6+")}")
	oGet6 := TMultiGet():New(01,335,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet6:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",06"
	                              
	// 7o Get - Ocorrencia
	cGet7	:= "aValues[nAtu,7]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet7+":=u,"+cGet7+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet7 := TGet():New( 01, 429, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_OCORR"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet7:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",07"
	
	// 8o Get - Controles atuais do projeto prevencao
	cGet8	:= "aValues[nAtu,8]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet8+":=u,"+cGet8+")}")
	oGet8 := TMultiGet():New(01,445,bBlock,oPanel3,46,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet8:Cargo := Str(nAtu,3)+",08"
	
	// 20o Get - Controles atuais do projeto deteccao (9o na tela)
	cGet20	:= "aValues[nAtu,20]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}")
	oGet20 := TMultiGet():New(01,492,bBlock,oPanel3,46,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet20:Cargo := Str(nAtu,3)+",20"
	
	// 9o Get - Deteccao
	cGet9	:= "aValues[nAtu,9]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet9+":=u,"+cGet9+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet9 := TGet():New( 01, 539, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_DETEC"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet9:Cargo := Str(nAtu,3)+",09"
	
	// 10o Get - NPR
	cGet10	:= "aValues[nAtu,10]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet10+":=u,"+cGet10+")}")
	oGet10 	:= TGet():New( 01, 555, bBlock,oPanel3,20,10,PesqPict("QK6","QK6_NPR"),,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)  
	oGet10:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",10"
	
	// 11o Get - Acoes Recomendadas
	cGet11	:= "aValues[nAtu,11]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet11+":=u,"+cGet11+")}")
	oGet11 	:= TMultiGet():New(01,581,bBlock,oPanel3,93, 25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet11:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",11"
	
	// 12o Get - Responsavel
	cGet12	:= "aValues[nAtu,12]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet12+":=u,"+cGet12+")}")
	bWhen	:= {|u| Empty(aValues[nAtu,21])}
	oGet12 	:= TGet():New( 15, 675, bBlock,oPanel3,100,10,PesqPict("QK6","QK6_RESP"),,,,,,,.T.,,,bWhen)
	oGet12:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",12"
	
	// 12(b)o Get - Codigo do Responsavel (21 no array)
	cGet21	:= "aValues[nAtu,21]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet21+":=u,"+cGet21+")}")
	bValid	:= {|u| QPP121BSXB(u,nAtu,oGet12)}
	oGet21	:= TGet():New( 01, 675, bBlock,oPanel3,40,10,PesqPict("QK6","QK6_CODRES"),bValid,,,,,,.T.,,,,,,,,,ConSX3("QK6_CODRES"))
	oGet21:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",21"
	
	// 13o Get - Prazo
	cGet13	:= "aValues[nAtu,13]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet13+":=u,"+cGet13+")}")
	oGet13 	:= TGet():New( 01, 775, bBlock,oPanel3,40,10,,,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet13:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",13"
	
	// 14o Get - Acoes tomadas
	cGet14	:= "aValues[nAtu,14]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet14+":=u,"+cGet14+")}")
	oGet14 	:= TMultiGet():New(01,815,bBlock,oPanel3,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
	oGet14:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",14"
	
	// 15o Get - Severidade 
	cGet15	:= "aValues[nAtu,15]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet15+":=u,"+cGet15+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet15 	:= TGet():New( 01, 909, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_RSEVER"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet15:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",15"
	
	// 16o Get - Ocorrencia
	cGet16	:= "aValues[nAtu,16]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet16+":=u,"+cGet16+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet16 	:= TGet():New( 01, 925, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_ROCORR"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet16:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",16"
	
	// 17o Get - Deteccao
	cGet17	:= "aValues[nAtu,17]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet17+":=u,"+cGet17+")}")
	bValid	:= {|u| QPP121CNPR(nAtu,u)}
	oGet17 	:= TGet():New( 01, 941, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_RDETEC"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet17:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",17"
	
	// 18o Get - NPR
	cGet18	:= "aValues[nAtu,18]"
	bBlock	:= &("{|u|If(Pcount()>0,"+cGet18+":=u,"+cGet18+")}")
	oGet18 	:= TGet():New( 01, 957, bBlock,oPanel3,10,10,PesqPict("QK6","QK6_RNPR"),,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
	oGet18:Cargo := Str(nAtu,TamSX3("QK6_ITEM")[1])+",18"  
	
	@ 001,985 BUTTON oBtn  PROMPT OemToAnsi(STR0024)  OF oPanel3 Pixel Size 65,13 ACTION QPP121REMO(nAtu,nOpc,.F.) //"Excluir / Recuperar"
	@ 001,319 BITMAP oBmp REPOSITORY SIZE 030,030 OF oPanel3 NOBORDER PIXEL

Endif

If !Empty(aValues[nAtu,5])
	oBmp:SetBmp(aValues[nAtu,5])
Else
	oBmp:SetBmp("NOTE")
Endif  

If lFMEA4a 
    Aadd(aOGets,oGet1);Aadd(aOGets,oGet22);Aadd(aOGets,oGet2);Aadd(aOGets,oGet3)
	Aadd(aOGets,oBmp);Aadd(aOGets,oGet4);Aadd(aOGets,oGet5);Aadd(aOGets,oGet6)
	Aadd(aOGets,oGet);Aadd(aOGets,oGet7);Aadd(aOGets,oGet8);Aadd(aOGets,oGet20);Aadd(aOGets,oGet23);Aadd(aOGets,oGet24)
	Aadd(aOGets,oGet9);Aadd(aOGets,oGet10);Aadd(aOGets,oGet11);Aadd(aOGets,oGet12)
	Aadd(aOGets,oGet21);Aadd(aOGets,oGet13);Aadd(aOGets,oGet14);Aadd(aOGets,oGet25);Aadd(aOGets,oGet15)
	Aadd(aOGets,oGet16);Aadd(aOGets,oGet17);Aadd(aOGets,oGet18)
Else
	// Carrega objetos na array aOGet
	For nY:=1 to 21
		If nY == 5
			Aadd(aOGets,oBmp)
		Else
			Aadd(aOGets,&("oGet"+Alltrim(Str(nY))))
		EndIf                                              
	Next nY   
Endif
oBmp:Refresh()
oBmp:lTransparent 	:= .T.
oBmp:cToolTip		:= STR0027 //"Duplo Click para escolher caracteristica"
oBmp:BlDblClick		:= {|o| QPPA010BMP(nOpc,nAtu,oBmp,oPanel3,aValues,0)}

If nOpc == 2 .or. nOpc == 5
	oGet1:lReadOnly 	:= .T.
	If lFMEA4a
		oGet22:lReadOnly 	:= .T.
		oGet23:lReadOnly 	:= .T.
		oGet24:lReadOnly 	:= .T.
		oGet25:lReadOnly 	:= .T.
	Endif	
	oGet2:lReadOnly 	:= .T.	
	oGet3:lReadOnly 	:= .T.	
	oGet4:lReadOnly 	:= .T.	
	oGet6:lReadOnly 	:= .T.	
	oGet7:lReadOnly 	:= .T.
	oGet8:lReadOnly 	:= .T.	
	oGet9:lReadOnly 	:= .T.	
	oGet10:lReadOnly 	:= .T.	
	oGet11:lReadOnly 	:= .T.	
	oGet12:lReadOnly 	:= .T.	
	oGet13:lReadOnly 	:= .T.	
	oGet14:lReadOnly 	:= .T.	
	oGet15:lReadOnly 	:= .T.	
	oGet16:lReadOnly 	:= .T.	
	oGet17:lReadOnly 	:= .T.	
	oGet18:lReadOnly 	:= .T.
	oGet19:lReadOnly 	:= .T.
	oGet20:lReadOnly 	:= .T.
	oGet21:lReadOnly 	:= .T.
	oBmp:lReadOnly 		:= .T.
Endif

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := QPP121TudOk(nOpc), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

If lOk 
	If nOpc == 3 .or. nOpc == 4
		QPP121Grav(nOpc,)
	ElseIf nOpc == 5
		QPP121Dele()
	EndIF	
Endif

Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121ADIC³ Autor ³ Cleber Souza          ³ Data ³ 05/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Resultados dos Estudos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121ADIC(ExpN1,ExpL1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpL1 = Diferenciacao se foi inclusao manual				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPP121ADIC(nOpc,oDlg,cTipo)

Local nx 
Local ny
Local bBlock
Local aGets	:= {}
Local cChave
Local axTextos1, axTextos2, axTextos3, axTextos4, axTextos5, axTextos6, axTextos7, axTextos8, axTextos9, axTextos10, axTextos11
Local bValid
Local cEspecie	:= "QPPA120"
Local nTamLin 	:= 17
Local cSeq 		:= Space(TamSX3("QK6_SEQ")[1])
Local lAtu      := .T.    
Local nSaveSX8	:= GetSX8Len()
Local nTamSeq   := TamSX3("QK6_SEQ")[1]
Local nItFMEA 	:= 19
Local nItChv  	:= 22

If (cTipo=="B" .and. (nOpc==2 .or. nOpc==5)) //.Or. IIF(Len(aOGets)>0,Empty(aOGets[1]:cText),.F.) //Valida linha sem Operacao
	Return
EndIF	

If lFMEA4a
	nItFMEA := 20
	nItChv  := 23
Else
	nItFMEA := 19
	nItChv  := 22	
Endif
oPanel3:Refresh()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega todas as cacteristicas.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 2 .or. nOpc == 4 .or. nOpc == 5)
	dbSelectArea("QK6")  
	If DbSeek(xFilial("QK6")+ M->QK5_PECA + M->QK5_REV) .AND. cTipo == "I"
		While QK6->(!EOF()) .and. xFilial("QK6")+ M->QK5_PECA == QK6->QK6_FILIAL + QK6->QK6_PECA 
		
			axTextos1 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"A",1, nTamLin,"QKO",axTextos1) //Item Funcao
			axTextos2 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"B",1, nTamLin,"QKO",axTextos2) //Modo de falha
			axTextos3 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"C",1, nTamLin,"QKO",axTextos3) //Efeito da falha
			axTextos4 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"D",1, If(lFMEA4a,12,nTamLin),"QKO",axTextos4) //Causa/Mecanismo
			axTextos5 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"E",1, 8,"QKO",axTextos5) 	     //Controles atuais Prevencao
			axTextos6 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"F",1, nTamLin,"QKO",axTextos6) //Acoes recomendadas
			axTextos7 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"G",1, nTamLin,"QKO",axTextos7) //Acoes Tomadas
			axTextos8 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"H",1, 8,"QKO",axTextos8) 		 //Controles atuais Deteccao
            
			If lFMEA4a
				axTextos9 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"I",1, 10,"QKO",axTextos9) 		 //Controles atuais Deteccao
				axTextos10 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"J",1, nTamLin,"QKO",axTextos10) 		//Causas
			    axTextos11 := QO_Rectxt(QK6->QK6_CHAVE1,"QPPA120"+"K",1, nTamLin,"QKO",axTextos11) 		//Modo de Falha
				
				aGets := {	axTextos1,axTextos9,axTextos2,axTextos3,QK6->QK6_CLASS,QK6->QK6_SEVER,;
							axTextos4,QK6->QK6_OCORR,axTextos5,QK6->QK6_DETEC,QK6->QK6_NPR,;
							axTextos6,QK6->QK6_RESP,QK6->QK6_PRAZO,axTextos7,QK6->QK6_RSEVER,;
							QK6->QK6_ROCORR,QK6->QK6_RDETEC,QK6->QK6_RNPR,QK6->QK6_SEQ,axTextos8,;
							QK6->QK6_CODRES,QK6->QK6_CHAVE1,axTextos10,axTextos11,QK6->QK6_DATEEF,.T.}
			Else
				aGets := {	axTextos1,axTextos2,axTextos3,QK6->QK6_SEVER,QK6->QK6_CLASS,;
							axTextos4,QK6->QK6_OCORR,axTextos5,QK6->QK6_DETEC,QK6->QK6_NPR,;
							axTextos6,QK6->QK6_RESP,QK6->QK6_PRAZO,axTextos7,QK6->QK6_RSEVER,;
							QK6->QK6_ROCORR,QK6->QK6_RDETEC,QK6->QK6_RNPR,QK6->QK6_SEQ,axTextos8,;
							QK6->QK6_CODRES,QK6->QK6_CHAVE1,.T.}			
			Endif

			Aadd(aValues,aGets)
			axTextos1 := ""
			axTextos2 := ""
			axTextos3 := ""	
			axTextos4 := ""	
			axTextos5 := ""	
			axTextos6 := ""	
			axTextos7 := ""	
			axTextos8 := ""	
			axTextos9 := ""
			axTextos10 := ""
			axTextos11 := ""
			QK6->(dbSkip())
		EndDo       
		lAtu := .F.	
	Endif
EndIf
                                                      
If lAtu
	If Len(aValues) > 0
		aValues := Asort(aValues,,,{|x,y| x[nItFMEA] < y[nItFMEA]}) // Ordena por ordem de Itens
		cSeq := Val(aValues[Iif(nAtu > 0,Len(aValues),1), nItFMEA])+1
		If nTamSeq == 5
			cSeq := StrZero(QPP121PrDe(cSeq),5)
		Else
			cSeq := StrZero(QPP121PrDe(cSeq),3)
		Endif
	Else
		If nTamSeq == 5 
			cSeq := "00010"
		Else
			cSeq := "010"
		Endif
	Endif

	If lFMEA4a
		aGets := {	axTextos1,axTextos9,axTextos2,axTextos3,Space(02),Space(02),;
					axTextos4,Space(02),axTextos5,Space(02),Space(04),;
					axTextos6,Space(30),CtoD(" / / "),axTextos7,Space(02),;
					Space(02),Space(02),Space(04),cSeq,axTextos8,Space(10),;
					Space(08),axTextos10,axTextos11,CtoD(" / / "),.T.}
	Else
		aGets := {	axTextos1,axTextos2,axTextos3,Space(02),Space(02),;
					axTextos4,Space(02),axTextos5,Space(02),Space(04),;
					axTextos6,Space(30),CtoD(" / / "),axTextos7,Space(02),;
					Space(02),Space(02),Space(04),cSeq,axTextos8,Space(10),;
					Space(08),.T.}
	Endif			

	Aadd(aValues,aGets)
Endif

If cTipo == "I"
	nAtu         := 1
	oBrwCar:nAt  := 1
Else 
	nAtu         := Len(aValues)
	oBrwCar:nAt  := Len(aValues)
EndIf	
oBrwCar:Refresh()
                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza BMP da Tela.										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oBmp)=="O"
	If !Empty(aValues[nAtu,5])
		oBmp:SetBmp(aValues[nAtu,5])
	Else
		oBmp:SetBmp("NOTE")
	EndIf
	oBmp:Refresh()			
EndIf	

If Empty(aValues[nAtu,nItChv])
	cChave := GetSXENum("QK6", "QK6_CHAVE1",,3)
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	aValues[nAtu,nItChv] := cChave

Endif                     

If (nOpc == 3 .or. nOpc == 4) .AND. ValType(oGet1)<>"U"
	
	If lFMEA4a
		nTamAr := 23
	Else
		nTamAr := 21	
	Endif

	oPanel3:SetColor(CLR_BLACK,CLR_WHITE)
	oBrwCar:SetColor(CLR_BLACK,CLR_WHITE)
	aValues[nAtu,Len(aValues[nAtu])] := .T.
	For ny := 1 To nTamAr 		
		If aOGets[ny] <> Nil
			aOGets[ny]:SetColor(CLR_BLACK,CLR_WHITE)
			aOGets[ny]:lReadOnly := .F.
		Endif
	Next ny 
	oBrwCar:lReadOnly := .F.
	oGet1:lReadOnly 	:= .F.	
	oGet2:lReadOnly 	:= .F.	
	oGet3:lReadOnly 	:= .F.	
	oGet4:lReadOnly 	:= .F.	
	oGet6:lReadOnly 	:= .F.	
	oGet7:lReadOnly 	:= .F.
	oGet8:lReadOnly 	:= .F.	
	oGet9:lReadOnly 	:= .F.	
	oGet10:lReadOnly 	:= .F.	
	oGet11:lReadOnly 	:= .F.	
	oGet12:lReadOnly 	:= .F.	
	oGet13:lReadOnly 	:= .F.	
	oGet14:lReadOnly 	:= .F.	
	oGet15:lReadOnly 	:= .F.	
	oGet16:lReadOnly 	:= .F.	
	oGet17:lReadOnly 	:= .F.	
	oGet18:lReadOnly 	:= .F.
	oGet19:lReadOnly 	:= .F.
	oGet20:lReadOnly 	:= .F.
	oGet21:lReadOnly 	:= .F.
	oBmp:lReadOnly 		:= .F.
EndIf

oPanel3:Refresh()
oScrollBox:Reset() 
oPanel3:Refresh()  
oScrollBox:Refresh()
oPanel3:Refresh()

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121TUDOK³ Autor ³ Cleber Souza         ³ Data ³ 05/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Inclusao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121TUDOK()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Opcao do aRotina									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPP121TUDOK(nOpc)

Local lRetorno	:= .T.
Local nIt
Local nTot
Local nCont, nCont2
Local cComp
Local nItFMEA := 19

If lFMEA4a
	nItFMEA := 20
Endif

For nIt := 1 To Len(aValues)
	If !aValues[nIt, Len(aValues[nIt])] // Item deletado
		nTot++
	Endif
Next nIt

If Empty(M->QK5_PECA) .or. Empty(M->QK5_REV) .or. nTot == Len(aValues)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

If INCLUI
	If !ExistChav("QK5",M->QK5_PECA+M->QK5_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QK5_PECA+M->QK5_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

For nCont := 1 To Len(aValues)
	If aValues[nCont,Len(aValues[nCont])] // Item nao deletado
		
		cComp := aValues[nCont,nItFMEA]
		
		If Empty(aValues[nCont,nItFMEA])
			lRetorno := .F.
			Help(" ",1,"QPPSEQFMEA") // "Exite Sequencia sem numeracao !"
			Exit
		Endif

		For nCont2 := 1 To Len(aValues)
		
			If cComp == aValues[nCont2,nItFMEA] .and. nCont <> nCont2 .and. ;
				aValues[nCont2,Len(aValues[nCont2])]

				lRetorno := .F.
				nCont := nCont2 := Len(aValues)
				Help(" ",1,"QPPSEQDUPL") // "Exite Sequencia duplicada !, altere-a"
			Endif

		Next nCont2

	Endif

Next nCont

Return lRetorno  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121Grav  ³ Autor ³ Cleber Souza        ³ Data ³ 05/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao dos dados - inclusao/alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121Grav(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP121Grav(nOpc)

Local nIt     
Local nCont
Local nNumItem
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk 		:= .T.   // Indica se todas as gravacoes obtiveram sucesso
Local cEspecie		:= "QPPA120"
Local axTextos1		:= {}
Local axTextos2		:= {}
Local axTextos3		:= {}
Local axTextos4		:= {}
Local axTextos5		:= {}
Local axTextos6		:= {}
Local axTextos7		:= {}
Local axTextos8		:= {}
Local axTextos9		:= {}
Local cAtividade	:= "01    " // Definido no SX5 - QF
Local nTamLin		:= 17
Local nItFMEA 		:= 19
Local nItChv		:= 22 

Begin Transaction

DbSelectArea("QK5")
DbSetOrder(1)

If INCLUI
	RecLock("QK5",.T.)
Else
	RecLock("QK5",.F.)
Endif

For nCont := 1 To FCount()

	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QK5"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif

Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos nao informados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QK5->QK5_REVINV := Inverte(QK5->QK5_REV)

MsUnLock()

If !Empty(QK5->QK5_DATA) .and. !Empty(QK5->QK5_APRPOR)
	QPP_CRONO(QK5->QK5_PECA,QK5->QK5_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif

If lFMEA4a
	nItFMEA := 20
Else
	nItFMEA := 19
Endif


DbSelectArea("QK6")
DbSetOrder(1)


aValues := Asort(aValues,,,{|x,y| x[nItFMEA] < y[nItFMEA]}) // Ordena por ordem de Itens
	
For nIt := 1 To Len(aValues)

	If aValues[nIt,Len(aValues[nIt])] // Verifica se item foi excluido Item Excluido

		If ALTERA
		
			If DbSeek(xFilial("QK6")+ M->QK5_PECA + M->QK5_REV + StrZero(nIt,TamSX3("QK6_ITEM")[1]))
				RecLock("QK6",.F.)
			Else
				QK6->(DbSetOrder(4))
				If !DbSeek(xFilial("QK6")+ M->QK5_PECA + M->QK5_REV + aValues[nIt,nItFMEA] )
					RecLock("QK6",.T.)
				Else 
					RecLock("QK6",.F.)					
				EndIf      
				DbSetOrder(1)
			Endif
		Else	                   
			RecLock("QK6",.T.)
		Endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos Chave nao informados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK6->QK6_FILIAL	:= xFilial("QK6")
		QK6->QK6_PECA 	:= M->QK5_PECA
		QK6->QK6_REV	:= M->QK5_REV
		QK6->QK6_REVINV	:= Inverte(QK5->QK5_REV)
		QK6->QK6_FILRES	:= cFilAnt
                                                                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK6->QK6_ITEM 	:= StrZero(nIt,TamSX3("QK6_ITEM")[1])
		If lFMEA4a
			QK6->QK6_SEVER 	:= aValues[nIt,06]
			QK6->QK6_CLASS 	:= aValues[nIt,05]
			QK6->QK6_OCORR 	:= aValues[nIt,08]
			QK6->QK6_DETEC 	:= aValues[nIt,10]
			QK6->QK6_NPR   	:= aValues[nIt,11]
			QK6->QK6_RESP	:= aValues[nIt,13]
			QK6->QK6_PRAZO 	:= aValues[nIt,14]
			QK6->QK6_RSEVER	:= aValues[nIt,16]
			QK6->QK6_ROCORR	:= aValues[nIt,17]
			QK6->QK6_RDETEC	:= aValues[nIt,18]
			QK6->QK6_RNPR	:= aValues[nIt,19]
			QK6->QK6_SEQ	:= aValues[nIt,20]
			QK6->QK6_CODRES	:= aValues[nIt,22]
			QK6->QK6_DATEEF	:= aValues[nIt,26]

			If !Empty(aValues[nIt,1]) // Item funcao
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos1 := QPP121GTxt(nIt,nTamLin,"A")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"A",1,@axTextos1) 	//QPPXFUN
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")
			Endif

			If !Empty(aValues[nIt,2]) // Item funcao
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos9 := QPP121GTxt(nIt,nTamLin,"I")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"I",1,@axTextos9) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"I")
			Endif
	
			If !Empty(aValues[nIt,3]) // Modo de falha
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos2 := QPP121GTxt(nIt,nTamLin,"B")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"B",1,@axTextos2) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
			Endif
	
			If !Empty(aValues[nIt,4]) // Efeito da falha
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos3 := QPP121GTxt(nIt,nTamLin,"C")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"C",1,@axTextos3) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
			Endif
			
			If !Empty(aValues[nIt,7]) // Causa/Mecanismo Potencial da Falha
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos4 := QPP121GTxt(nIt,nTamLin,"D")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"D",1,@axTextos4) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
			Endif
			
			If !Empty(aValues[nIt,9]) // Controles atuais do projeto prevencao
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos5 := QPP121GTxt(nIt,8,"E")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"E",1,@axTextos5) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
			Endif
	
			If !Empty(aValues[nIt,21]) // Controles atuais do projeto deteccao
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos5 := QPP121GTxt(nIt,8,"H")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"H",1,@axTextos5) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
			Endif
			
			If !Empty(aValues[nIt,24]) // Causas
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos8 := QPP121GTxt(nIt,8,"J")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"J",1,@axTextos8) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"J")
			Endif
			
			If !Empty(aValues[nIt,25]) // Modos de Falha
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos9 := QPP121GTxt(nIt,8,"K")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"K",1,@axTextos9) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"K")
			Endif
	        
			If !Empty(aValues[nIt,12]) // Acoes Recomendadas
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos6 := QPP121GTxt(nIt,nTamLin,"F")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"F",1,@axTextos6) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
			Endif
	
			If !Empty(aValues[nIt,15]) // Acoes tomadas
				QK6->QK6_CHAVE1	:= aValues[nIt,23]
	 			axTextos7 := QPP121GTxt(nIt,nTamLin,"G")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"G",1,@axTextos7) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
			Endif

		Else
			QK6->QK6_SEVER 	:= aValues[nIt,04]
			QK6->QK6_CLASS 	:= aValues[nIt,05]
			QK6->QK6_OCORR 	:= aValues[nIt,07]
			QK6->QK6_DETEC 	:= aValues[nIt,09]
			QK6->QK6_NPR   	:= aValues[nIt,10]
			QK6->QK6_RESP	:= aValues[nIt,12]
			QK6->QK6_PRAZO 	:= aValues[nIt,13]
			QK6->QK6_RSEVER	:= aValues[nIt,15]
			QK6->QK6_ROCORR	:= aValues[nIt,16]
			QK6->QK6_RDETEC	:= aValues[nIt,17]
			QK6->QK6_RNPR	:= aValues[nIt,18]
			QK6->QK6_SEQ	:= aValues[nIt,19]
			QK6->QK6_CODRES	:= aValues[nIt,21]
	
			If !Empty(aValues[nIt,1]) // Item funcao
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos1 := QPP121GTxt(nIt,nTamLin,"A")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"A",1,@axTextos1) 	//QPPXFUN
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")
			Endif
	
			If !Empty(aValues[nIt,2]) // Modo de falha
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos2 := QPP121GTxt(nIt,nTamLin,"B")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"B",1,@axTextos2) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
			Endif
	
			If !Empty(aValues[nIt,3]) // Efeito da falha
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos3 := QPP121GTxt(nIt,nTamLin,"C")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"C",1,@axTextos3) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
			Endif
			
			If !Empty(aValues[nIt,6]) // Causa/Mecanismo Potencial da Falha
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos4 := QPP121GTxt(nIt,nTamLin,"D")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"D",1,@axTextos4) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
			Endif
			
			If !Empty(aValues[nIt,8]) // Controles atuais do projeto prevencao
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos5 := QPP121GTxt(nIt,8,"E")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"E",1,@axTextos5) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
			Endif
	
			If !Empty(aValues[nIt,20]) // Controles atuais do projeto deteccao
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos5 := QPP121GTxt(nIt,8,"H")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"H",1,@axTextos5) 	
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
			Endif
	
			If !Empty(aValues[nIt,11]) // Acoes Recomendadas
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos6 := QPP121GTxt(nIt,nTamLin,"F")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"F",1,@axTextos6) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
			Endif
	
			If !Empty(aValues[nIt,14]) // Acoes tomadas
				QK6->QK6_CHAVE1	:= aValues[nIt,22]
	 			axTextos7 := QPP121GTxt(nIt,nTamLin,"G")
				QO_GrvTxt(aValues[nIt,22],cEspecie+"G",1,@axTextos7) 
			ElseIf ALTERA
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
			Endif
		Endif
		MsUnlock()
    Else
 		If DbSeek(xFilial("QK6")+ M->QK5_PECA + M->QK5_REV + StrZero(nIt,TamSX3("QK6_ITEM")[1]))
 			If !Empty(QK6->QK6_CHAVE1)
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")	//QPPXFUN
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
				If lFMEA4a                              
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"I")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"J")				
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"K")
				Endif
			Endif

			DbSelectArea("QK6")	
			RecLock("QK6",.F.)
			DbDelete()
			MsUnlock()
		Else
	 		DbSetOrder(4)
	 		If DbSeek(xFilial("QK6")+ M->QK5_PECA + M->QK5_REV + aValues[nIt,nItFMEA])
	 			If !Empty(QK6->QK6_CHAVE1)
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")	//QPPXFUN
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
					QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
					If lFMEA4a                              
						QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"I")
						QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"J")				
						QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"K")
					Endif
				Endif
	
				DbSelectArea("QK6")	
				RecLock("QK6",.F.)
				DbDelete()
				MsUnlock()
	        EndIf
	        DbSetOrder(1)
		Endif
	Endif

Next nIt

End Transaction
				
Return lGraOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121GTxt  ³ Autor ³ Cleber Souza        ³ Data ³ 05/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transformacao do campo memo para gravacao no QKO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121GTxt(ExpN1,ExpN2,ExpC1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Item  									  ³±±
±±³          ³ ExpN2 = Tamanho da linha 								  ³±±
±±³          ³ ExpC1 = Tipo a ser gerado     							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP121GTxt(nIt, nTamlin, cTipo)

Local cDescricao := ""
Local nLinTotal
Local nPasso
Local axTextos   := {}
Local nLi
Local nPos
Local nLocal
Local lSepSal := .F.

If lFMEA4a
	Do Case
		Case cTipo == "A" ; nLocal := 1
		Case cTipo == "B" ; nLocal := 3
		Case cTipo == "C" ; nLocal := 4
		Case cTipo == "D" ; nLocal := 7		
		Case cTipo == "E" ; nLocal := 9
		Case cTipo == "F" ; nLocal := 12
		Case cTipo == "G" ; nLocal := 15
		Case cTipo == "H" ; nLocal := 21
		Case cTipo == "J" ; nLocal := 24
		Case cTipo == "K" ; nLocal := 25
		
	EndCase
Else
	Do Case
		Case cTipo == "A" ; nLocal := 1
		Case cTipo == "B" ; nLocal := 2
		Case cTipo == "C" ; nLocal := 3
		Case cTipo == "D" ; nLocal := 6		
		Case cTipo == "E" ; nLocal := 8
		Case cTipo == "F" ; nLocal := 11
		Case cTipo == "G" ; nLocal := 14
		Case cTipo == "H" ; nLocal := 20
	EndCase
Endif

If cTipo == "I"
	nLocal := 2
Endif

If ChkFile("QAL")
	lSepSal := .T.
Endif
			
nLinTotal  := MlCount( aValues[nIt,nLocal] , nTamLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza vetor com o texto digitado		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPasso := 1 to nLinTotal
	cDescricao += MemoLine( aValues[nIt,nLocal], nTamLin, nPasso ) + Chr(13)+Chr(10)	
Next nPasso
		
nLi := 1

nPos := ascan(axTextos, {|x| x[1] == nLi })

If nPos == 0
	Aadd(axTextos, { nLi, cDescricao } )
Else
	axTextos[nPos][2] := cDescricao
Endif

Return(axTextos)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121REM1³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui Item                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121REMO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Linha que esta posicionado						  ³±±
±±³          ³ ExpN2 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPP121REMO(nx,nOpc,lInv)
Local ny 
Local lAtu := IIF(lInv,!aValues[nx,Len(aValues[nx])],aValues[nx,Len(aValues[nx])])

If nOpc == 3 .or. nOpc == 4
	If lFMEA4a
		nTamAr := 23	
	Else
		nTamAr := 21	
	Endif

	If lAtu
		oPanel3:SetColor(CLR_WHITE,CLR_HGRAY)
		For ny := 1 To Len(aOGets)
			If aOGets[ny] <> Nil
				aOGets[ny]:SetColor(CLR_WHITE,CLR_HGRAY)
				aOGets[ny]:lReadOnly := .T.
			Endif
		Next ny
		oBrwCar:SetColor(CLR_BLACK,CLR_WHITE)
		aValues[nx,Len(aValues[nx])] := .F.
    Else
		oPanel3:SetColor(CLR_BLACK,CLR_WHITE)
		For ny := 1 To nTamAr 		
			If aOGets[ny] <> Nil
				aOGets[ny]:SetColor(CLR_BLACK,CLR_WHITE)
				aOGets[ny]:lReadOnly := .F.
			Endif
		Next ny
		oBrwCar:SetColor(CLR_BLACK,CLR_WHITE)
		aValues[nx,Len(aValues[nx])] := .T.
	Endif
Endif

Return  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPP121Dele ³ Autor ³ Cleber Souza        ³ Data ³ 05/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121Dele(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QPP121Dele()

Local cEspecie 	:= "QPPA120"

DbSelectArea("QK6")
DbSetOrder(1)
	
If DbSeek(xFilial("QK6") + QK5->QK5_PECA + QK5->QK5_REV)

	Do While !Eof() .and. ;
		QK5->QK5_PECA + QK5->QK5_REV == QK6_PECA + QK6_REV
		
		If !Empty(QK6->QK6_CHAVE1)
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"A")    //QPPXFUN
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"B")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"C")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"D")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"E")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"F")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"G")
			QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"H")
			If lFMEA4a
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"I")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"J")
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie+"K")
			Endif
		EndIf		 
		
		DbSelectArea("QK6")
		RecLock("QK6",.F.)
		DbDelete()
		MsUnLock()
		DbSkip()
	Enddo
Endif

DbSelectArea("QK5")

RecLock("QK5",.F.)
DbDelete()
MsUnLock()
				
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPP121CNPR  ³ Autor ³ Cleber Souza       ³ Data ³ 05/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o NPR                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121CNPR(Exp1N)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Linha do array em que esta posicionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP121CNPR(nx,u)

Local cPos
Local lRetorno	:= .T.
Local nNPRMAX	:= GetMv("MV_NPRMAX")

If Empty(u:cText)
	Return .T.
EndIf

If !(Alltrim(u:cText)$"  1 2 3 4 5 6 7 8 9 10")
	lRetorno := .F.
Endif
          
cPos := Right(u:Cargo,2)

If lRetorno
	If lFMEA4a
		If cPos == "10" 
			aValues[nx,11] := Str(Val(aValues[nx, 6])*Val(aValues[nx, 8])*Val(aValues[nx, 10]),4)
			If Val(aValues[nx,11]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,11]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Else
			aValues[nx,19] := Str(Val(aValues[nx,16])*Val(aValues[nx,17])*Val(aValues[nx,18]),4)
			If Val(aValues[nx,19]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,19]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Endif
	Else
		If cPos == "09" 
			aValues[nx,10] := Str(Val(aValues[nx, 4])*Val(aValues[nx, 7])*Val(aValues[nx, 9]),4)
			If Val(aValues[nx,10]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,10]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Else
			aValues[nx,18] := Str(Val(aValues[nx,15])*Val(aValues[nx,16])*Val(aValues[nx,17]),4)
			If Val(aValues[nx,18]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,18]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Endif
	Endif
	oPanel3:Refresh()
Endif

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121REFR³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Refresh dos objetos do FMEA          	     	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121REFR()			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPP121REFR(nOpc)  

Local nY :=0  
Local nItFMEA := 19

If lFMEA4a
	nItFMEA := 20
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a linha esta excluida ou naum.					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QPP121REMO(nAtu,nOpc,.T.)

For nY:=1 to Len(aOGets) 
	If aOGets[nY] <> NIL
		aOGets[nY]:SetFocus()
		aOGets[nY]:Refresh()
	Endif	
Next nY

aOGets[1]:SetFocus()

IF !Empty(aValues[nAtu,5])
	oBmp:SetBmp(aValues[nAtu,5])
Else
	oBmp:SetBmp("NOTE")
EndIF
oBmp:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121APRO³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova / Limpa                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121APRO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPP121APRO(nOpc)

If nOpc == 3 .or. nOpc == 4

	If nOpc == 4
		If !Empty(M->QK5_APRPOR)
			If Alltrim(M->QK5_APRPOR) == Alltrim(cUserName)
				M->QK5_DATA 	:= Iif(Empty(M->QK5_DATA), dDataBase, CtoD(" / / "))
				M->QK5_APRPOR	:= Iif(Empty(M->QK5_APRPOR), cUserName, Space(40))		
			Else
				MessageDlg(OemToAnsi(STR0034),,2)	//"Usuario logado nao e o responsavel pela aprovacao da FMEA de Processo. Para consultar FMEA escolha a opcao Visualizar."      	
				//Desabilitar panel para nao permitir edicao qdo responsavel for diferente do usuario logado... 
				oPanel3:lReadOnly := .t.
			Endif
		Else
			M->QK5_DATA 	:= Iif(Empty(M->QK5_DATA), dDataBase, CtoD(" / / "))
			M->QK5_APRPOR	:= Iif(Empty(M->QK5_APRPOR),cUserName, Space(40))
		Endif	
	Else
		M->QK5_DATA 	:= Iif(Empty(M->QK5_DATA), dDataBase, CtoD(" / / "))
		M->QK5_APRPOR	:= Iif(Empty(M->QK5_APRPOR),cUserName, Space(40))
	Endif	

Endif

Return .T.  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPP121AtuC  ³ Autor ³ Cleber Souza       ³ Data ³ 05/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o campo com Zeros a Esquerda                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121AtuC(Exp1N)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Linha do array em que esta posicionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP121AtuC(nx)

Local lRetorno := .T.
Local nCont
Local nItFMEA := 19

If lFMEA4a
	nItFMEA := 20
Endif

If !Empty(aValues[nx,nItFMEA])
    If TamSX3("QK6_SEQ")[1] == 5
		aValues[nx,nItFMEA] := StrZero(Val(aValues[nx, nItFMEA]),5)
	Else
	    aValues[nx,nItFMEA] := StrZero(Val(aValues[nx, nItFMEA]),3)
	EndIf

	For nCont := 1 To Len(aValues)
		If aValues[nx,nItFMEA] == aValues[nCont,nItFMEA] .and. nx <> nCont .and. ;
			aValues[nCont,Len(aValues[nCont])]
			lRetorno := .F.
			Help(" ",1,"QPPSEQDUPL") // "Exite Sequencia duplicada !, altere-a"

			Exit
		Endif
	Next nCont
Endif

oPanel3:Refresh()

Return lRetorno 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121PrDe³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Acha a Proxima dezena para seguencia (que ainda nao existe ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121PrDe(Exp1N)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Valor inicial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP121PrDe(nSeed)

Local nRetorno
Local nCont
Local lLoop := .T.
Local nItFMEA := 19

If lFMEA4a
	nItFMEA := 20
Endif

Do While lLoop

	lLoop := .F.
	nRetorno := (nSeed - Mod(nSeed,10)) + 10
	For nCont := 1 To Len(aValues)
		If nRetorno == Val(aValues[nCont,nItFMEA]) .and. aValues[nCont,Len(aValues[nCont])]
			lLoop := .T.
			Exit
		Endif
	Next nCont

Enddo

Return nRetorno      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121BSXB  ³ Autor ³ Cleber Souza        ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizacao de descricao com retorno da consulta           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121BSXB(u,nx,oGet,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Get  									  ³±±
±±³          ³ ExpN1 = Linha do Array 									  ³±±
±±³          ³ ExpO2 = Objeto do Get 								      ³±±
±±³          ³ ExpN2 = Opcao QKK ou QAA									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP121BSXB(u,nx,oGet,nOpc)

Local lReturn := .T.

If !Empty(u:cText)
	QAA->(DbSetOrder(1))
	If (QAA->(DbSeek(cFilAnt+u:cText)))
		If lFMEA4a
			aValues[nx,13]	:= QAA->QAA_NOME
		Else
			aValues[nx,12]	:= QAA->QAA_NOME
		Endif	
		oGet:lReadOnly	:= .T.
	Else
		lReturn := .F.
	Endif
Else
	oGet:lReadOnly := .F.
Endif

Return lReturn     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP121MOV   ³ Autor ³ Cleber Souza        ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Movimentação entre as caracteristicas.			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP121MOV(cTipo,nOpc)	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo da Mov.   									  ³±±
±±³          ³ ExpN1 = Opcao QK5										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA121                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP121MOV(cTipo,nOpc)
      
If cTipo == "N"
	If nAtu < Len(aValues)
		nAtu 		:= nAtu+1  
		oBrwCar:nAt := nAtu
		oBrwCar:Refresh()
		QPP121REFR(nOpc)
	EndIf
Else
	If nAtu > 1
		nAtu 		:= nAtu-1  
		oBrwCar:nAt := nAtu
		oBrwCar:Refresh()
		QPP121REFR(nOpc)
	EndIf
EndIF                   

Return

