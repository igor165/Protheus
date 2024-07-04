#INCLUDE "QPPA131.CH"
#INCLUDE "PROTHEUS.CH"

/*/   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA131  ³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³FMEA de Processo (com ListBox)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA131(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 	0, 1,,.F.},;//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA131Incl", 	0, 2},;	 	 //"Visualizar"
					{ OemToAnsi(STR0003), "PPA131Incl", 	0, 3},;		 //"Incluir"
					{ OemToAnsi(STR0004), "PPA131Incl", 	0, 4},;		 //"Alterar"
					{ OemToAnsi(STR0005), "PPA131Incl", 	0, 5},;		 //"Excluir"
					{ OemToAnsi(STR0030), "QPPR130(.T.)",	0, 6,,.F.} }//"Imprimir"

Return aRotina

Function QPPA131
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0006)  //"FMEA de proceso"

Private aRotina := MenuDef()
Private lFMEA4a := GetMV("MV_QVEFMEA",.T.,"3") == "4" 

DbSelectArea("QK7")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QK7",,,,,,)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA131Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³05.09.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA131Incl(ExpC1,ExpN1,ExpN2)                           ³±±
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
Function PPA131Incl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local oEncQK7   := NIL 
Local lOk 		:= .F.
Local aButtons	:= {}
Local aFields   := Iif(!lFMEA4a,{STR0026,STR0031,STR0013,STR0014,STR0016,STR0018,STR0019,STR0021,STR0032,STR0022,STR0013,STR0016,STR0018,STR0019},; //"Seq.","Função","Server", "Class","Ocorr.","Detec","NPR","Responsavel","Nome","Prazo","Sever.","Ocorr","Detec","NPR"
								 {STR0026, STR0031, STR0012, STR0013, STR0015, STR0038, STR0018, STR0023, STR0020, STR0021, STR0039, STR0013, STR0016, STR0018})
Local aSizes    := {20, 20, 20, 20, 20, 20, 35, 40, 60, 40, 20, 20, 20, 35 }
Local bBlock    := {||Afill(Array(Len(aSizes))," ")} 
Local aSize:= aInfo := aObjects := aPosObj :={}
Local oBtn, oBtn2 
Local nY        := 0 
Local nItFMEA 	:= 20
Local nTamTela	:= 0
Local nPsBmp	:= 6		
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
Private oGet19,oGet20,oGet21,oGet22,oGet23, oGet24, oGet25, oGet26, oGet27

Private oGet	:= NIL

SetKey( VK_F5, { || QPP131ADIC(nOpc,.T.,"B") } )                                        
SetKey( VK_F6, { || QPP131MOV("A",nOpc) } )                    
SetKey( VK_F7, { || QPP131MOV("N",nOpc) } )                                       

If nOpc <> 3 .and. nOpc <> 2 .and. !QPPVldAlt(QK7->QK7_PECA,QK7->QK7_REV,QK7->QK7_APRPOR)
	Return
Endif

If lFMEA4a
	nItFMEA := 21
	nTamTela := 1420
	nPsBmp := 6		
	nTaOGets := 23	
Else
	nItFMEA := 20
	nTamTela := 1050
	nPsBmp := 5		
	nTaOGets := 22				
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

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"FMEA de Processo"
						FROM aSize[7],000 To aSize[6],aSize[5] OF oMainWnd PIXEL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Panel Primario                                                  ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
oPanel5:= tPanel():New(000,000,,oDlg,,,,,,aSize[6],aSize[5])
oPanel5:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Panels Secundario                                                 ³    
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
DbSelectArea("QK7")
RegToMemory("QK7",(nOpc==3))
oEncQK7:=MsMGet():New("QK7",nReg,nOpc,,,,,aPosObj[1],,,,,,oPanel,,,,,,,,,)
oEncQK7:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Botoes do Dialog                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aButtons := {  {"BMPINCLUIR",	{ || QPP131ADIC(nOpc,.T.,"B") }	, OemToAnsi(STR0007),STR0033},;	//"Incluir Item"###"Inc Item"
				{"EDIT"		, 	{ || QPP131APRO(nOpc) }	     	, OemToAnsi(STR0008),STR0034},; //"Aprovar / Limpar"###"Apr/Limp"
  			    {"GRAF2D",     { || QPPM040(M->QK7_PECA,M->QK7_REV,"2")} , OemToAnsi(STR0035), OemToAnsi(STR0036)}}  //"Diagrama de Pareto"###"Diag.Par"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Scrool com a tela de receptação das caracteristicas	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oScrollBox := TScrollBox():New(oPanel2,,,,,.T.,.T.,.T.)
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o browse com as linhas das Caracteristicas			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QK8")                              

oBrwCar:= TwBrowse():New(6.5,0.4,386,90,bBlock,aFields,aSizes,oPanel1)
oBrwCar:SetArray(aValues)      
oBrwCar:lMChange      := .F.      
oBrwCar:nClrBackFocus := GetSysColor(13)
oBrwCar:nClrForeFocus := GetSysColor(14) 

oBrwCar:bLine       := {||{aValues[oBrwCar:nAt,nItFMEA],aValues[oBrwCar:nAt,1],aValues[oBrwCar:nAt,5],aValues[oBrwCar:nAt,6],;
				       aValues[oBrwCar:nAt,8],aValues[oBrwCar:nAt,10],aValues[oBrwCar:nAt,11],;
					   aValues[oBrwCar:nAt,16],aValues[oBrwCar:nAt,13],aValues[oBrwCar:nAt,14],;
					   aValues[oBrwCar:nAt,22],aValues[oBrwCar:nAt,17],aValues[oBrwCar:nAt,18],aValues[oBrwCar:nAt,19]}}    


oBrwCar:bLDblClick  := {||{nAtu:=oBrwCar:nAt,QPP131REFR(nOpc)}}   

oBrwCar:Align     := CONTROL_ALIGN_ALLCLIENT 

                                                                            
@ 001,001 MSPANEL oPanel3 PROMPT ""	COLOR CLR_WHITE,CLR_BLACK SIZE nTamTela,013 OF oScrollBox
@ 003	,013 SAY OemToAnsi(STR0026)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Seq."
@ 003	,032 SAY OemToAnsi(STR0046) 	COLOR CLR_WHITE OF oPanel3 PIXEL //"Funcao" 
If lFMEA4a
	@ 003	,59 SAY OemToAnsi(STR0047) COLOR CLR_WHITE OF oPanel3 PIXEL //"Desc.Funcao"
	@ 003	,153 SAY OemToAnsi(STR0040)	COLOR CLR_WHITE OF oPanel3 PIXEL //"Requisito" 
	@ 003	,259 SAY OemToAnsi(STR0041)		COLOR CLR_WHITE OF oPanel3 PIXEL	//"ID
	@ 003	,289 SAY OemToAnsi(STR0011)		COLOR CLR_WHITE OF oPanel3 PIXEL	//"Modo de Falha Potencial"
	@ 003	,382 SAY OemToAnsi(STR0012)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Efeito Potencial da Falha"
	@ 003	,477 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Sever"
	@ 003	,500 SAY OemToAnsi(STR0014) 	COLOR CLR_WHITE OF oPanel3 PIXEL //"Class"
	@ 003	,524 SAY OemToAnsi(STR0015)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Causa/Mecanismo Potencial da Falha"
	@ 003	,617 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Ocorr"
	@ 003	,639 SAY OemToAnsi(STR0017)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Controles Atuais do Processo - P / D"
	@ 003	,735 SAY OemToAnsi(STR0042)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Causas
	@ 003	,773 SAY OemToAnsi(STR0043)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Modos de Falha
	@ 003	,833 SAY OemToAnsi(STR0018)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Detec"
	@ 003	,854 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel3 PIXEL //"NPR"
	@ 003	,876 SAY OemToAnsi(STR0020)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Acoes Recomendadas"
	@ 003	,970 SAY OemToAnsi(STR0021)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Responsavel"
	@ 003	,1073 SAY OemToAnsi(STR0022)  	COLOR CLR_WHITE OF oPanel3 PIXEL //"Prazo"
	@ 003	,1120 SAY OemToAnsi(STR0023)  	COLOR CLR_WHITE OF oPanel3 PIXEL //"Acoes Tomadas"
	@ 003	,1220 SAY OemToAnsi(STR0044)  	COLOR CLR_WHITE OF oPanel3 PIXEL //"Data efetiva
	@ 003	,1260 SAY OemToAnsi(STR0013)	COLOR CLR_WHITE OF oPanel3 PIXEL //"Sever"
	@ 003	,1285 SAY OemToAnsi(STR0016)	COLOR CLR_WHITE OF oPanel3 PIXEL //"Ocorr"
	@ 003	,1302 SAY OemToAnsi(STR0018)  	COLOR CLR_WHITE OF oPanel3 PIXEL //"Detec"
	@ 003	,1322 SAY OemToAnsi(STR0019)	COLOR CLR_WHITE OF oPanel3 PIXEL //"NPR"  
Else
	@ 003	,160 SAY OemToAnsi(STR0011)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Modo de Falha Potencial"
	@ 003	,248 SAY OemToAnsi(STR0012)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Efeito Potencial da Falha"
	@ 003	,341 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Sever"
	@ 003	,357 SAY OemToAnsi(STR0014) 	COLOR CLR_WHITE OF oPanel3 PIXEL //"Class"
	@ 003	,373 SAY OemToAnsi(STR0015)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Causa/Mecanismo Potencial da Falha"
	@ 003	,467 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Ocorr"
	@ 003	,484 SAY OemToAnsi(STR0017)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Controles Atuais do Processo - P / D"
	@ 003	,577 SAY OemToAnsi(STR0018)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Detec"
	@ 003	,595 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel3 PIXEL //"NPR"
	@ 003	,622 SAY OemToAnsi(STR0020)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Acoes Recomendadas"
	@ 003	,716 SAY OemToAnsi(STR0021)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Responsavel"
	@ 003	,813 SAY OemToAnsi(STR0022)  	COLOR CLR_WHITE OF oPanel3 PIXEL //"Prazo"
	@ 003	,855 SAY OemToAnsi(STR0023)  	COLOR CLR_WHITE OF oPanel3 PIXEL //"Acoes Tomadas"
	@ 003	,947 SAY OemToAnsi(STR0013)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Sever"
	@ 003	,963 SAY OemToAnsi(STR0016)		COLOR CLR_WHITE OF oPanel3 PIXEL //"Ocorr"
	@ 003	,981 SAY OemToAnsi(STR0018)  	COLOR CLR_WHITE OF oPanel3 PIXEL //"Detec"
	@ 003	,997 SAY OemToAnsi(STR0019)		COLOR CLR_WHITE OF oPanel3 PIXEL //"NPR"  
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os objetos das Caracteristicas.						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oPanel4 := TPanel():New(15,03,"",oScrollBox, , .T., .T.,,,nTamTela,35,.T.,.T. ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega todas as cacteristicas.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QPP131ADIC(nOpc,oPanel3,"I")

If lFMEA4a

// 20o Get - Item sequencial (1o na tela)
cGet20	:= "aValues[nAtu,21]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}")
bValid	:= {|u| QPP131AtuC(nAtu)}
oGet20 	:= TGet():New( 01, 01, MontaBlock("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}"),oPanel4,12,10,PesqPict("QK8","QK8_SEQ"),bValid,,,,,,.T.,,,)  
oGet20:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",21"

//1o Get - Funcao 
cGet1 	:= "aValues[nAtu,1]"
bBlock 	:= &("{|u|If(Pcount()>0,"+cGet1+":=u,"+cGet1+")}")
bValid	:= {|u| QPP131BSXB(u,nAtu,oGet2,1)}
oGet1 := TGet():New( 01, 25, bBlock,oPanel4,20,10,PesqPict("QK8","QK8_NOPE"),bValid,,,,,,.T.,,,,,,,,,"QPZ")
oGet1:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",01"

//2o Get - Funcao / Requisitos (Memo)
cGet2 	:= "aValues[nAtu,2]"
bBlock 	:= &("{|u|If(Pcount()>0,"+cGet2+":=u,"+cGet2+")}")
bWhen	:= {|u| Empty(aValues[nAtu,2])}
oGet2 := TMultiGet():New(01,57,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,bWhen,.F.,.F.,,,,.F.,,.T.)
oGet2:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",02"


//3o Get - Requisitos (Memo)
cGet23 	:= "aValues[nAtu,3]"
bBlock 	:= &("{|u|If(Pcount()>0,"+cGet23+":=u,"+cGet23+")}")
//bWhen	:= {|u| Empty(aValues[nAtu,1])}
oGet23 := TMultiGet():New(01,151,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet23:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",03"


//ID
cGet27	:= "aValues[nAtu,28]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet27+":=u,"+cGet27+")}")
bValid	:= {|u| QPP131BSXB(u,nAtu,oGet27,3)}
oGet27	:= TGet():New( 01, 245, bBlock,oPanel4,30,10,PesqPict("QK8","QK8_CODRES"),bValid,,,,,,.T.,,,,,,,,,"QPX1")
oGet27:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",28"

// 4o Get - Modo de Falha Potencial
cGet3 	:= "aValues[nAtu,4]"
bBlock 	:= &("{|u|If(Pcount()>0,"+cGet3+":=u,"+cGet3+")}")
oGet3 := TMultiGet():New(01,286,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet3:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",04"

// 5o Get - Efeito Potencial da Falha
cGet4 	:= "aValues[nAtu,5]"
bBlock 	:= &("{|u|If(Pcount()>0,"+cGet4+":=u,"+cGet4+")}")
oGet4 := TMultiGet():New(01,380,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet4:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",05"

// 6o Get - Severidade
cGet5	:= "aValues[nAtu,6]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet5+":=u,"+cGet5+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet5 := TGet():New( 01, 476, bBlock,oPanel4,10,10, PesqPict("QK8","QK8_SEVER"),bValid,,,,,,.T.,,,)
oGet5:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",06"

// 7o Get - Classificacao
cGet6	:= "aValues[nAtu,7]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet6+":=u,"+cGet6+")}")
                                                        
// 8o Get - Causa/Mecanismo Potencial da Falha
cGet7	:= "aValues[nAtu,8]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet7+":=u,"+cGet7+")}")
oGet7 := TMultiGet():New(01,520,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet7:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",08"

// 9o Get - Ocorrencia
cGet8	:= "aValues[nAtu,9]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet8+":=u,"+cGet8+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet8 := TGet():New( 01, 615, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_OCORR"),bValid,,,,,,.T.,,,)  
oGet8:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",09"

// 10o Get - Controles atuais do Processo Prevencao
cGet9	:= "aValues[nAtu,10]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet9+":=u,"+cGet9+")}")
oGet9 := TMultiGet():New(01,637,bBlock,oPanel4,46,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet9:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",10"

// 21o Get - Controles atuais do projeto deteccao (10o na tela)
cGet21	:= "aValues[nAtu,22]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet21+":=u,"+cGet21+")}")
oGet21 := TMultiGet():New(01,685,bBlock,oPanel4,46,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet21:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",22"  

// Causas
cGet24	:= "aValues[nAtu,25]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet24+":=u,"+cGet24+")}")
oGet24 := TMultiGet():New(01,733,bBlock,oPanel4,46,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet24:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",25"  


//Modo de Falha
cGet25	:= "aValues[nAtu,26]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet25+":=u,"+cGet25+")}")
oGet25 := TMultiGet():New(01,781,bBlock,oPanel4,46,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet25:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",26"  


// 10o Get - Deteccao
cGet10	:= "aValues[nAtu,11]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet10+":=u,"+cGet10+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet10 := TGet():New( 01, 833, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_DETEC"),bValid,,,,,,.T.,,,)  
oGet10:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",11"

// 11o Get - NPR
cGet11	:= "aValues[nAtu,12]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet11+":=u,"+cGet11+")}")
oGet11 	:= TGet():New( 01, 850, bBlock,oPanel4,20,10,PesqPict("QK8","QK8_NPR"),,,,,,,.T.,,,,,,,.T.)  
oGet11:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",12"

// 12o Get - Acoes Recomendadas
cGet12	:= "aValues[nAtu,13]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet12+":=u,"+cGet12+")}")
oGet12 	:= TMultiGet():New(01,874,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet12:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",13"

// 13o Get - Responsavel
cGet13	:= "aValues[nAtu,14]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet13+":=u,"+cGet13+")}")
bWhen	:= {|u| Empty(aValues[nAtu,23])}
oGet13 	:= TGet():New( 15, 968, bBlock,oPanel4,100,10,PesqPict("QK8","QK8_RESP"),,,,,,,.T.,,,bWhen)
oGet13:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",14"

// 13(b)o Get - Codigo do Responsavel (22 no array)
cGet22	:= "aValues[nAtu,23]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet22+":=u,"+cGet22+")}")
bValid	:= {|u| QPP131BSXB(u,nAtu,oGet13,2)}
oGet22	:= TGet():New( 01, 968, bBlock,oPanel4,40,10,PesqPict("QK8","QK8_CODRES"),bValid,,,,,,.T.,,,,,,,,,ConSX3("QK8_CODRES"))
oGet22:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",23"

// 14o Get - Prazo
cGet14	:= "aValues[nAtu,15]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet14+":=u,"+cGet14+")}")
oGet14 	:= TGet():New( 01, 1071, bBlock,oPanel4,40,10,,,,,,,,.T.,,,)  
oGet14:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",15"

// 15o Get - Acoes tomadas
cGet15	:= "aValues[nAtu,16]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet15+":=u,"+cGet15+")}")
oGet15 	:= TMultiGet():New(01,1115,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet15:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",16"

//Data Efetiva
cGet26	:= "aValues[nAtu,27]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet26+":=u,"+cGet26+")}")
oGet26 	:= TGet():New( 01, 1213, bBlock,oPanel4,40,10,,,,,,,,.T.,,,)  
oGet26:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",27"

// 16o Get - Severidade 
cGet16	:= "aValues[nAtu,17]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet16+":=u,"+cGet16+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet16 	:= TGet():New( 01, 1265, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_RSEVER"),bValid,,,,,,.T.,,,)       
oGet16:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",17"

// 17o Get - Ocorrencia
cGet17	:= "aValues[nAtu,18]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet17+":=u,"+cGet17+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet17 	:= TGet():New( 01, 1285, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_ROCORR"),bValid,,,,,,.T.,,,)  
oGet17:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",18"

// 18o Get - Deteccao
cGet18	:= "aValues[nAtu,19]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet18+":=u,"+cGet18+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet18 	:= TGet():New( 01, 1305, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_RDETEC"),bValid,,,,,,.T.,,,)  
oGet18:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",19"

// 19o Get - NPR
cGet19	:= "aValues[nAtu,20]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet19+":=u,"+cGet19+")}")
oGet19 	:= TGet():New( 01, 1325, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_RNPR"),,,,,,,.T.,,,,,,,.T.)  
oGet19:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",20"
                                   
@ 001,1350 BUTTON oBtn PROMPT OemToAnsi(STR0024) OF oPanel4 Pixel Size 65,13 ACTION QPP131REMO(nAtu:=oBrwCar:nAt,nOpc,.F.) //"Excluir / Recuperar"
@ 001,0495 BITMAP oBmp REPOSITORY SIZE 030,030 OF oPanel4 NOBORDER PIXEL

Else
// 20o Get - Item sequencial (1o na tela)
cGet20	:= "aValues[nAtu,20]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}")
bValid	:= {|u| QPP131AtuC(nAtu)}
oGet20 	:= TGet():New( 01, 01, MontaBlock("{|u|If(Pcount()>0,"+cGet20+":=u,"+cGet20+")}"),oPanel4,12,10,PesqPict("QK8","QK8_SEQ"),bValid,,,,,,.T.,,,)  
oGet20:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",20"

//1o Get - Funcao / Requisitos (Consulta Padrao)
cGet1 	:= "aValues[nAtu,1]"
bBlock 	:= &("{|u|If(Pcount()>0,"+cGet1+":=u,"+cGet1+")}")
bValid	:= {|u| QPP131BSXB(u,nAtu,oGet2,1)}
oGet1 := TGet():New( 01, 25, bBlock,oPanel4,20,10,PesqPict("QK8","QK8_NOPE"),bValid,,,,,,.T.,,,,,,,,,"QPZ")
oGet1:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",01"

//2o Get - Funcao / Requisitos (Memo)
cGet2 	:= "aValues[nAtu,2]"
bBlock 	:= &("{|u|If(Pcount()>0,"+cGet2+":=u,"+cGet2+")}")
bWhen	:= {|u| Empty(aValues[nAtu,1])}
oGet2 := TMultiGet():New(01,57,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,bWhen,.F.,.F.,,,,.F.,,.T.)
oGet2:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",02"

// 3o Get - Modo de Falha Potencial
cGet3 	:= "aValues[nAtu,3]"
bBlock 	:= &("{|u|If(Pcount()>0,"+cGet3+":=u,"+cGet3+")}")
oGet3 := TMultiGet():New(01,151,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
oGet3:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",03"

// 4o Get - Efeito Potencial da Falha
cGet4 	:= "aValues[nAtu,4]"
bBlock 	:= &("{|u|If(Pcount()>0,"+cGet4+":=u,"+cGet4+")}")
oGet4 := TMultiGet():New(01,245,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
oGet4:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",04"

// 5o Get - Severidade
cGet5	:= "aValues[nAtu,5]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet5+":=u,"+cGet5+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet5 := TGet():New( 01, 339, bBlock,oPanel4,10,10, PesqPict("QK8","QK8_SEVER"),bValid,,,,,,.T.,,,/*<{|X|uWhen(X)}>*/)
oGet5:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",05"

// 6o Get - Classificacao
cGet6	:= "aValues[nAtu,6]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet6+":=u,"+cGet6+")}")
                                                        
// 7o Get - Causa/Mecanismo Potencial da Falha
cGet7	:= "aValues[nAtu,7]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet7+":=u,"+cGet7+")}")
oGet7 := TMultiGet():New(01,371,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
oGet7:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",07"
                              
// 8o Get - Ocorrencia
cGet8	:= "aValues[nAtu,8]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet8+":=u,"+cGet8+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet8 := TGet():New( 01, 465, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_OCORR"),bValid,,,,,,.T.,,,/*<{|X|uWhen(X)}>*/)  
oGet8:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",08"

// 9o Get - Controles atuais do Processo Prevencao
cGet9	:= "aValues[nAtu,9]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet9+":=u,"+cGet9+")}")
oGet9 := TMultiGet():New(01,481,bBlock,oPanel4,46,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet9:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",09"

// 21o Get - Controles atuais do projeto deteccao (10o na tela)
cGet21	:= "aValues[nAtu,21]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet21+":=u,"+cGet21+")}")
oGet21 := TMultiGet():New(01,528,bBlock,oPanel4,46,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet21:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",21"  

// 10o Get - Deteccao
cGet10	:= "aValues[nAtu,10]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet10+":=u,"+cGet10+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet10 := TGet():New( 01, 575, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_DETEC"),bValid,,,,,,.T.,,,)  
oGet10:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",10"

// 11o Get - NPR
cGet11	:= "aValues[nAtu,11]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet11+":=u,"+cGet11+")}")
oGet11 	:= TGet():New( 01, 591, bBlock,oPanel4,20,10,PesqPict("QK8","QK8_NPR"),,,,,,,.T.,,,,,,,.T.)  
oGet11:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",11"

// 12o Get - Acoes Recomendadas
cGet12	:= "aValues[nAtu,12]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet12+":=u,"+cGet12+")}")
oGet12 	:= TMultiGet():New(01,617,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,,.F.,.F.,,,,.F.,,.T.)
oGet12:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",12"

// 13o Get - Responsavel
cGet13	:= "aValues[nAtu,13]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet13+":=u,"+cGet13+")}")
bWhen	:= {|u| Empty(aValues[nAtu,22])}
oGet13 	:= TGet():New( 15, 711, bBlock,oPanel4,100,10,PesqPict("QK8","QK8_RESP"),,,,,,,.T.,,,bWhen)
oGet13:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",13"

// 13(b)o Get - Codigo do Responsavel (22 no array)
cGet22	:= "aValues[nAtu,22]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet22+":=u,"+cGet22+")}")
bValid	:= {|u| QPP131BSXB(u,nAtu,oGet13,2)}
oGet22	:= TGet():New( 01, 711, bBlock,oPanel4,40,10,PesqPict("QK8","QK8_CODRES"),bValid,,,,,,.T.,,,,,,,,,ConSX3("QK8_CODRES"))
oGet22:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",22"

// 14o Get - Prazo
cGet14	:= "aValues[nAtu,14]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet14+":=u,"+cGet14+")}")
oGet14 	:= TGet():New( 01, 811, bBlock,oPanel4,40,10,,,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
oGet14:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",14"

// 15o Get - Acoes tomadas
cGet15	:= "aValues[nAtu,15]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet15+":=u,"+cGet15+")}")
oGet15 	:= TMultiGet():New(01,851,bBlock,oPanel4,93,25,,.F.,,,,.T.,,.F.,/*bWhen*/,.F.,.F.,,,,.F.,,.T.)
oGet15:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",15"

// 16o Get - Severidade 
cGet16	:= "aValues[nAtu,16]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet16+":=u,"+cGet16+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet16 	:= TGet():New( 01, 945, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_RSEVER"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)       
oGet16:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",16"

// 17o Get - Ocorrencia
cGet17	:= "aValues[nAtu,17]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet17+":=u,"+cGet17+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet17 	:= TGet():New( 01, 961, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_ROCORR"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
oGet17:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",17"

// 18o Get - Deteccao
cGet18	:= "aValues[nAtu,18]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet18+":=u,"+cGet18+")}")
bValid	:= {|u| QPP131CNPR(nAtu,u)}
oGet18 	:= TGet():New( 01, 977, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_RDETEC"),bValid,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/)  
oGet18:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",18"

// 19o Get - NPR
cGet19	:= "aValues[nAtu,19]"
bBlock	:= &("{|u|If(Pcount()>0,"+cGet19+":=u,"+cGet19+")}")
oGet19 	:= TGet():New( 01, 993, bBlock,oPanel4,10,10,PesqPict("QK8","QK8_RNPR"),,,,,,,.T.,,,/* <{|X|uWhen(X)}>*/,,,,.T.)  
oGet19:Cargo := Str(nAtu,TamSX3("QK8_SEQ")[1])+",19"
                                   
@ 001,1021 BUTTON oBtn PROMPT OemToAnsi(STR0024) OF oPanel4 Pixel Size 65,13 ACTION QPP131REMO(nAtu:=oBrwCar:nAt,nOpc,.F.) //"Excluir / Recuperar"
@ 001,0355 BITMAP oBmp REPOSITORY SIZE 030,030 OF oPanel4 NOBORDER PIXEL
Endif

If lFMEA4a
	If !Empty(aValues[nAtu,7])
		oBmp:SetBmp(aValues[nAtu,7])
	Else
		oBmp:SetBmp("NOTE")
	Endif  
Else
	If !Empty(aValues[nAtu,6])
		oBmp:SetBmp(aValues[nAtu,6])
	Else
		oBmp:SetBmp("NOTE")
	Endif  
Endif

// Carrega objetos na array aOGet
For nY:=1 to nTaOGets
	If nY == nPsBmp
		Aadd(aOGets,oBmp)
	Else
		Aadd(aOGets,&("oGet"+Alltrim(Str(nY))))
	EndIf
Next nY

oBmp:Refresh()
oBmp:lTransparent 	:= .T.
oBmp:cToolTip		:= STR0027 //"Duplo Click para escolher caracteristica"
oBmp:BlDblClick		:= {|o| QPPA010BMP(nOpc,nAtu,oBmp,oPanel4,aValues,If(lFMEA4a,2,1))}

If nOpc == 2 .or. nOpc == 5
	oGet1:lReadOnly 	:= .T.
	oGet2:lReadOnly 	:= .T.	
	oGet3:lReadOnly 	:= .T.	
	oGet4:lReadOnly 	:= .T.	
	oGet5:lReadOnly 	:= .T.
//	oGet6:lReadOnly := .T.	
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
	oGet22:lReadOnly 	:= .T.
	oBmp:lReadOnly 		:= .T.
	If lFMEA4a
		oGet23:lReadOnly 	:= .T.
		oGet24:lReadOnly 	:= .T.	
		oGet25:lReadOnly 	:= .T.	
		oGet25:lReadOnly 	:= .T.	
		oGet27:lReadOnly 	:= .T.	
		
	Endif
Endif

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := QPP131TudOk(nOpc), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

If lOk 
	If nOpc == 3 .or. nOpc == 4
		QPP131Grav(nOpc,)
	ElseIf nOpc == 5
		QPP131Dele()
	EndIF	
Endif

Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP131ADIC³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Resultados dos Estudos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131ADIC(ExpN1,ExpL1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±³          ³ ExpL1 = Diferenciacao se foi inclusao manual				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP131ADIC(nOpc,oDlg,cTipo)

Local nx
Local bBlock
Local aGets	:= {}
Local cChave
Local axTextos1, axTextos2, axTextos3, axTextos4
Local axTextos5, axTextos6, axTextos7, axTextos8, axTextos9, axTextos10, axTextos11
Local bValid
Local cEspecie	:= "QPPA130"
Local nTamLin 	:= 17
Local cSeq 		:= Space(TamSX3("QK8_SEQ")[1])
Local lAtu      := .T.  
Local nSaveSX8	:= GetSX8Len()
Local nTamSeq   := TamSX3("QK8_SEQ")[1]
Local nItFMEA   := 20
Local nPsChv	:= 23

If lFMEA4a
	nItFMEA   := 21
	nPsChv	  := 24
Endif

If (cTipo=="B" .and. (nOpc==2 .or. nOpc==5)) //.Or. IIF(Len(aOGets)>0,Empty(aOGets[1]:cText),.F.) //Valida linha sem Operacao
	Return
EndIF	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega todas as cacteristicas.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 2 .or. nOpc == 4 .or. nOpc == 5)
	dbSelectArea("QK8")  
	If DbSeek(xFilial("QK8")+ M->QK7_PECA + M->QK7_REV) .AND. cTipo == "I"
		While QK8->(!EOF()) .and. xFilial("QK8")+ M->QK7_PECA == QK8->QK8_FILIAL + QK8->QK8_PECA
			axTextos1 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"A",1, nTamLin,"QKO",axTextos1) //Item Funcao
			axTextos2 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"B",1, nTamLin,"QKO",axTextos2) //Modo de falha
			axTextos3 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"C",1, If(lFMEA4a,15,nTamLin),"QKO",axTextos3) //Efeito da falha	
			axTextos4 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"D",1, If(lFMEA4a,14,nTamLin),"QKO",axTextos4) //Causa/Mecanismo
			axTextos5 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"E",1, 8,"QKO",axTextos5) 		//Controles atuais Prevencao
			axTextos6 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"F",1, nTamLin,"QKO",axTextos6) //Acoes recomendadas
			axTextos7 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"G",1, nTamLin,"QKO",axTextos7) //Acoes Tomadas
			axTextos8 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"H",1, 8,"QKO",axTextos8) 		//Controles atuais Deteccao 
            If lFMEA4a
				axTextos9 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"I",1, nTamLin,"QKO",axTextos9) 		//Controles atuais Deteccao	
					axTextos10 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"J",1, nTamLin,"QKO",axTextos10) 		//Causas
					axTextos11 := QO_Rectxt(QK8->QK8_CHAVE1,"QPPA130"+"K",1, nTamLin,"QKO",axTextos11) 		//Modos de Falha 
					
					aGets := {	QK8->QK8_NOPE,axTextos1,axTextos9,axTextos2,axTextos3,QK8->QK8_SEVER,QK8->QK8_CLASS,;
							axTextos4,QK8->QK8_OCORR,axTextos5,QK8->QK8_DETEC,QK8->QK8_NPR,;
							axTextos6,QK8->QK8_RESP,QK8->QK8_PRAZO,axTextos7,QK8->QK8_RSEVER,;
							QK8->QK8_ROCORR,QK8->QK8_RDETEC,QK8->QK8_RNPR,QK8->QK8_SEQ,;
							axTextos8,QK8->QK8_CODRES,QK8->QK8_CHAVE1,axTextos10,axTextos11,QK8->QK8_DATEEF,QK8->QK8_ID,.T.} 
            Else
				aGets := {	QK8->QK8_NOPE,axTextos1,axTextos2,axTextos3,QK8->QK8_SEVER,QK8->QK8_CLASS,;
							axTextos4,QK8->QK8_OCORR,axTextos5,QK8->QK8_DETEC,QK8->QK8_NPR,;
							axTextos6,QK8->QK8_RESP,QK8->QK8_PRAZO,axTextos7,QK8->QK8_RSEVER,;
							QK8->QK8_ROCORR,QK8->QK8_RDETEC,QK8->QK8_RNPR,QK8->QK8_SEQ,;
							axTextos8,QK8->QK8_CODRES,QK8->QK8_CHAVE1,.T.} 
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
			QK8->(dbSkip())
		EndDo       
		lAtu := .F.	
	Endif
EndIf
                                                      
If lAtu
	If Len(aValues) > 0
		aValues := Asort(aValues,,,{|x,y| x[nItFMEA] < y[nItFMEA]}) // Ordena por ordem de Itens
		cSeq := Val(aValues[Iif(nAtu > 0,Len(aValues),1), nItFMEA])+1
		If nTamSeq == 5
			cSeq := StrZero(QPP131PrDe(cSeq),5)
		Else
			cSeq := StrZero(QPP131PrDe(cSeq),3)
		Endif
	Else
			If nTamSeq == 5 
				cSeq := "00010"
			Else
				cSeq := "010"
			Endif
	Endif
	If lFMEA4a
		aGets := {	Space(06),axTextos1,axTextos9,axTextos2,axTextos3,Space(02),Space(03),;
					axTextos4,Space(02),axTextos5,Space(02),Space(04),;
					axTextos6,Space(30),CtoD(" / / " ),axTextos7,Space(02),;
					Space(02),Space(02),Space(04),cSeq,axTextos8,Space(10),;
					Space(08),Space(10),Space(10),CtoD(" / / " ),Space(08),.T.} 
	Else
		aGets := {	Space(06),axTextos1,axTextos2,axTextos3,Space(02),Space(03),;
					axTextos4,Space(02),axTextos5,Space(02),Space(04),;
					axTextos6,Space(30),CtoD(" / / " ),axTextos7,Space(02),;
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
	If !Empty(aValues[nAtu,6])
		oBmp:SetBmp(aValues[nAtu,6])
	Else
		oBmp:SetBmp("NOTE")
	EndIf
	oBmp:Refresh()			
EndIf	

If Empty(aValues[nAtu,nPsChv])
	cChave := GetSXENum("QK8", "QK8_CHAVE1",,3)
	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End
	aValues[nAtu,nPsChv] := cChave
Endif  

oScrollBox:Reset() 
oPanel4:Refresh()  
oScrollBox:Refresh()

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP131TUDOK³ Autor ³ Cleber Souza         ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Inclusao                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131TUDOK()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc - Opcao do aRotina                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPP131TUDOK(nOpc)

Local lRetorno	:= .T.
Local nIt
Local nTot
Local nCont, nCont2
Local cComp
Local nItFMEA := 20
Local cMsg := ""

If lFMEA4a
	nItFMEA := 21
Endif


For nIt := 1 To Len(aValues)
	If !aValues[nIt, Len(aValues[nIt])] // Item deletado
		nTot++
	Endif
Next nIt

If Empty(M->QK7_PECA) .or. Empty(M->QK7_REV) .or. nTot == Len(aValues)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

If nOpc <> 5
	For nIt := 1 to  Len(aValues)
		If lFMEA4a
			If Empty(aValues[nIt,1]) 
				cMsg += STR0050+ Chr(13) + Chr(10) // Funcao / Requisitos Código
			Endif
		
			If Empty(aValues[nIt,2])
				cMsg += STR0051+ Chr(13) + Chr(10) // Função / Requisitos Descrição
			EndIf
			
			If Empty(aValues[nIt,3])
				cMsg += STR0040+ Chr(13) + Chr(10) // Requisitos
			Endif
			
			If Empty(aValues[nIt,4])
				cMsg += STR0011+ Chr(13) + Chr(10) // Modo de Falha Potencial
			Endif
			
			If Empty(aValues[nIt,5])
				cMsg += STR0012+ Chr(13) + Chr(10)  // Efeito Potencial da Falha
			Endif
			
			If Empty(aValues[nIt,8])
				cMsg += STR0015+ Chr(13) + Chr(10) // Causa/Mecanismo Potencial da Falha
			Endif
			
			If Empty(aValues[nIt,10])
				cMsg += STR0048+ Chr(13) + Chr(10) // Controles atuais do Processo Prevenção
			Endif
			
			If Empty(aValues[nIt,16])
				cMsg += STR0023+ Chr(13) + Chr(10) // Acoes tomadas
			Endif
			
			If Empty(aValues[nIt,25])
				cMsg += STR0042+ Chr(13) + Chr(10) // Causas
			Endif
			
			If Empty(aValues[nIt,26])
				cMsg += STR0043+ Chr(13) + Chr(10) // Modo de Falha
			Endif
			
			If Empty(aValues[nIt,22])
				cMsg += STR0017+ Chr(13) + Chr(10) // Controles atuais do projeto detecção
			Endif
		Else
			If Empty(aValues[nIt,1]) 
				cMsg += STR0050+ Chr(13) + Chr(10) // Funcao / Requisitos Código
			Endif
		
			If Empty(aValues[nIt,2])
				cMsg += STR0051+ Chr(13) + Chr(10) // Função / Requisitos Descrição
			EndIf
			
			If Empty(aValues[nIt,3]) 
				cMsg += STR0011+ Chr(13) + Chr(10) // Modo de Falha Potencial
			Endif
			
			If Empty(aValues[nIt,4]) 
				cMsg += STR0012+ Chr(13) + Chr(10) // Efeito Potencial da Falha
			Endif
			
			If Empty(aValues[nIt,7]) 
				cMsg += STR0015+ Chr(13) + Chr(10) // Causa/Mecanismo Potencial da Falha
			Endif
			
			If Empty(aValues[nIt,9]) 
				cMsg += STR0017+ Chr(13) + Chr(10) // Controles atuais do Processo Prevenção
			Endif
			
			If Empty(aValues[nIt,21])
				cMsg += STR0017+ Chr(13) + Chr(10) // Controles atuais do projeto detecção
			Endif
			
			If Empty(aValues[nIt,12])
				cMsg += STR0020+ Chr(13) + Chr(10) // Ações Recomendadas
			Endif
			
			If Empty(aValues[nIt,15])
				cMsg += STR0023+ Chr(13) + Chr(10) // Ações Tomadas
			Endif
		Endif
		
	Next 
Endif

If !Empty(cMsg)
	MSGALERT( cMsg, STR0049 ) // Obrigatório os campos abaixo:
	return .F.
Endif

If INCLUI
	If !ExistChav("QK7",M->QK7_PECA+M->QK7_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QK7_PECA+M->QK7_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

For nCont := 1 To Len(aValues)
	If aValues[nCont,Len(aValues[nCont])] // Item nao deletado
		
		cComp := aValues[nCont,nItFMEA]
		
		If Empty(cComp)
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

If nOpc == 4
	If !Empty(M->QK7_APRPOR)
		If Alltrim(M->QK7_APRPOR) <> Alltrim(cUserName)
			lRetorno := .f.
		Endif
	Endif		
Endif

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP131GRAV ³ Autor ³ Cleber Souza         ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao dos dados - inclusao/alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131GRAV(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QPP131Grav(nOpc)

Local nIt     
Local nCont
Local nNumItem
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk 		:= .T.   // Indica se todas as gravacoes obtiveram sucesso
Local cEspecie		:= "QPPA130"
Local axTextos1		:= {}
Local axTextos2		:= {}
Local axTextos3		:= {}
Local axTextos4		:= {}
Local axTextos5		:= {}
Local axTextos6		:= {}
Local axTextos7		:= {}
Local axTextos8		:= {}
Local cAtividade	:= "02    " // Definido no SX5 - QF
Local nTamLin 		:= 17
Local nItFMEA		:= 20

If lFMEA4a
	nItFMEA	:= 21
Endif

Begin Transaction

DbSelectArea("QK7")
DbSetOrder(1)

If INCLUI
	RecLock("QK7",.T.)
Else
	RecLock("QK7",.F.)
Endif

For nCont := 1 To FCount()

	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QK7"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif

Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos nao informados                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QK7->QK7_REVINV := Inverte(QK7->QK7_REV)

MsUnLock()

If !Empty(QK7->QK7_DATA) .and. !Empty(QK7->QK7_APRPOR)
	QPP_CRONO(QK7->QK7_PECA,QK7->QK7_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif

DbSelectArea("QK8")
DbSetOrder(1)


aValues := Asort(aValues,,,{|x,y| x[nItFMEA] < y[nItFMEA]}) // Ordena por ordem de Itens
	
For nIt := 1 To Len(aValues)

	If aValues[nIt,Len(aValues[nIt])] // Verifica se item foi excluido Item Excluido

		If ALTERA
			If DbSeek(xFilial("QK8")+ M->QK7_PECA + M->QK7_REV + StrZero(nIt,TamSX3("QK8_SEQ")[1]))
				RecLock("QK8",.F.)
			Else
				DbSetOrder(4)
				If !DbSeek(xFilial("QK8")+ M->QK7_PECA + M->QK7_REV + aValues[nIt,nItFMEA] )
					RecLock("QK8",.T.)
				Else 
					RecLock("QK8",.F.)
				EndIf      
				DbSetOrder(1)
			Endif
		Else	                   
			RecLock("QK8",.T.)
		Endif
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Campos Chave nao informados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK8->QK8_FILIAL	:= xFilial("QK8")
		QK8->QK8_PECA 	:= M->QK7_PECA
		QK8->QK8_REV 	:= M->QK7_REV
		QK8->QK8_REVINV	:= Inverte(QK7->QK7_REV)
		QK8->QK8_FILRES	:= cFilAnt
                                                                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de itens                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QK8->QK8_ITEM 	:= StrZero(nIt,TamSX3("QK8_SEQ")[1])
		QK8->QK8_NOPE  	:= aValues[nIt,01]
		If lFMEA4a
			QK8->QK8_SEVER 	:= aValues[nIt,06]
			QK8->QK8_CLASS 	:= aValues[nIt,07]
			QK8->QK8_OCORR 	:= aValues[nIt,09]
			QK8->QK8_DETEC 	:= aValues[nIt,11]
			QK8->QK8_NPR   	:= aValues[nIt,12]
			QK8->QK8_RESP	:= aValues[nIt,14]
			QK8->QK8_PRAZO 	:= aValues[nIt,15]
			QK8->QK8_RSEVER	:= aValues[nIt,17]
			QK8->QK8_ROCORR	:= aValues[nIt,18]
			QK8->QK8_RDETEC	:= aValues[nIt,19]
			QK8->QK8_RNPR	:= aValues[nIt,20]
			QK8->QK8_SEQ	:= aValues[nIt,21]
			QK8->QK8_CODRES	:= aValues[nIt,23]
				QK8->QK8_DATEEF	:= aValues[nIt,27]
				QK8->QK8_ID		:= aValues[nIt,28]
					
			If !Empty(aValues[nIt,2]) // Funcao 
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos1 := QPP131GTXT(nIt,nTamLin,"A")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"A",1,@axTextos1) 	//QPPXFUN
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")
			Endif
	
			If !Empty(aValues[nIt,3]) // Requisitos
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos9 := QPP131GTXT(nIt,nTamLin,"I")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"I",1,@axTextos9) 	//QPPXFUN
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"I")
			Endif
	
			If !Empty(aValues[nIt,4]) // Modo de falha
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos2 := QPP131GTXT(nIt,nTamLin,"B")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"B",1,@axTextos2)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")
			Endif
	
			If !Empty(aValues[nIt,5]) // Efeito da falha
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos3 := QPP131GTXT(nIt,15,"C")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"C",1,@axTextos3)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")
			Endif
			
			If !Empty(aValues[nIt,8]) // Causa/Mecanismo Potencial da Falha
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos4 := QPP131GTXT(nIt,14,"D")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"D",1,@axTextos4) 
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")
			Endif
			
			If !Empty(aValues[nIt,10]) // Controles atuais do projeto prevencao
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos5 := QPP131GTXT(nIt,8,"E")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"E",1,@axTextos5)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")
			Endif
	
			If !Empty(aValues[nIt,16]) // Controles atuais do projeto deteccao
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos8 := QPP131GTXT(nIt,8,"H")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"H",1,@axTextos8)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"H")
			Endif
			
				If !Empty(aValues[nIt,25]) // CAUSAS
					QK8->QK8_CHAVE1	:= aValues[nIt,24]
		 			axTextos10 := QPP131GTXT(nIt,8,"J")
					QO_GrvTxt(aValues[nIt,24],cEspecie+"J",1,@axTextos10)
				ElseIf ALTERA
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"J")
				Endif
				
				If !Empty(aValues[nIt,26]) // Controles atuais do projeto deteccao
					QK8->QK8_CHAVE1	:= aValues[nIt,24]
		 			axTextos11 := QPP131GTXT(nIt,8,"K")
					QO_GrvTxt(aValues[nIt,24],cEspecie+"K",1,@axTextos11)
				ElseIf ALTERA
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"K")
				Endif
	
			If !Empty(aValues[nIt,13])
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos6 := QPP131GTXT(nIt,nTamLin,"F")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"F",1,@axTextos6)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")
			Endif
	
			If !Empty(aValues[nIt,22]) 
				QK8->QK8_CHAVE1	:= aValues[nIt,24]
	 			axTextos7 := QPP131GTXT(nIt,nTamLin,"G")
				QO_GrvTxt(aValues[nIt,24],cEspecie+"G",1,@axTextos7)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")
			Endif
		Else
			QK8->QK8_SEVER 	:= aValues[nIt,05]
			QK8->QK8_CLASS 	:= aValues[nIt,06]
			QK8->QK8_OCORR 	:= aValues[nIt,08]
			QK8->QK8_DETEC 	:= aValues[nIt,10]
			QK8->QK8_NPR   	:= aValues[nIt,11]
			QK8->QK8_RESP	:= aValues[nIt,13]
			QK8->QK8_PRAZO 	:= aValues[nIt,14]
			QK8->QK8_RSEVER	:= aValues[nIt,16]
			QK8->QK8_ROCORR	:= aValues[nIt,17]
			QK8->QK8_RDETEC	:= aValues[nIt,18]
			QK8->QK8_RNPR	:= aValues[nIt,19]
			QK8->QK8_SEQ	:= aValues[nIt,20]
			QK8->QK8_CODRES	:= aValues[nIt,22]
						
			If !Empty(aValues[nIt,2]) // Funcao / Requisitos
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos1 := QPP131GTXT(nIt,nTamLin,"A")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"A",1,@axTextos1) 	//QPPXFUN
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")
			Endif
	
			If !Empty(aValues[nIt,3]) // Modo de falha
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos2 := QPP131GTXT(nIt,nTamLin,"B")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"B",1,@axTextos2)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")
			Endif
	
			If !Empty(aValues[nIt,4]) // Efeito da falha
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos3 := QPP131GTXT(nIt,nTamLin,"C")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"C",1,@axTextos3)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")
			Endif
			
			If !Empty(aValues[nIt,7]) // Causa/Mecanismo Potencial da Falha
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos4 := QPP131GTXT(nIt,nTamLin,"D")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"D",1,@axTextos4) 
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")
			Endif
			
			If !Empty(aValues[nIt,9]) // Controles atuais do projeto prevencao
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos5 := QPP131GTXT(nIt,8,"E")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"E",1,@axTextos5)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")
			Endif
	
			If !Empty(aValues[nIt,21]) // Controles atuais do projeto deteccao
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos8 := QPP131GTXT(nIt,8,"H")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"H",1,@axTextos8)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"H")
			Endif
	
			If !Empty(aValues[nIt,12])
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos6 := QPP131GTXT(nIt,nTamLin,"F")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"F",1,@axTextos6)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")
			Endif
	
			If !Empty(aValues[nIt,15]) 
				QK8->QK8_CHAVE1	:= aValues[nIt,23]
	 			axTextos7 := QPP131GTXT(nIt,nTamLin,"G")
				QO_GrvTxt(aValues[nIt,23],cEspecie+"G",1,@axTextos7)
			ElseIf ALTERA
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")
			Endif		
		Endif
		MsUnlock()
    Else
 		If DbSeek(xFilial("QK8")+ M->QK7_PECA + M->QK7_REV + StrZero(nIt,TamSX3("QK8_SEQ")[1]))
 			If !Empty(QK8->QK8_CHAVE1)
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")    //QPPXFUN
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"H")
				If lFMEA4a
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"I")	
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"J")				
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"K")	
				Endif
			Endif

			DbSelectArea("QK8")	
			RecLock("QK8",.F.)
			DbDelete()
			MsUnLock()
		Else
			DbSetOrder(4)
			If DbSeek( xFilial("QK8")+ M->QK7_PECA + M->QK7_REV + aValues[nIt,nItFMEA] )
	 			If !Empty(QK8->QK8_CHAVE1)
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")    //QPPXFUN
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")
					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"H")
					If lFMEA4a
						QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"I")	
						QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"J")
	 					QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"K")
					Endif
				Endif
	
				DbSelectArea("QK8")	
				RecLock("QK8",.F.)
				DbDelete()
				MsUnLock()
			EndIf
			DbSetOrder(1)
		Endif
	Endif

Next nIt

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Evito lixo na base pois a estruturação desta tabela esta comprometida. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
DbSelectArea("QK8")
DbSetOrder(1)
DbGoTop()
If DbSeek(xFilial("QK8")+ M->QK7_PECA + M->QK7_REV )
	While !Eof() .and. ;
		M->QK7_PECA + M->QK7_REV == QK8->QK8_PECA + QK8->QK8_REV
		If aScan(aValues, { |x| x[nItFMEA] == QK8->QK8_SEQ }) <= 0
			RecLock("QK8",.F.)
			DbDelete()
			MsUnLock()
        EndIf
		QK8->(DbSkip())
	EndDo
EndIf

End Transaction
				
Return lGraOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP131GTXT  ³ Autor ³ Cleber Souza        ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transformacao do campo memo para gravacao no QKO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131GTXT(ExpN1,ExpN2,ExpC1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Item  									  ³±±
±±³          ³ ExpN2 = Tamanho da linha 								  ³±±
±±³          ³ ExpC1 = Tipo a ser gerado     							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function QPP131GTXT(nIt, nTamlin, cTipo)

Local cDescricao
Local nLinTotal
Local nPasso
Local axTextos := {}
Local nLi
Local nPos
Local nLocal
Local lSepSil := .F.

cDescricao := ""

If lFMEA4a
	Do Case 
		Case cTipo == "A" ; nLocal := 2
		Case cTipo == "B" ; nLocal := 4
		Case cTipo == "C" ; nLocal := 5
		Case cTipo == "D" ; nLocal := 8		
		Case cTipo == "E" ; nLocal := 10
		Case cTipo == "F" ; nLocal := 13
		Case cTipo == "G" ; nLocal := 16
		Case cTipo == "H" ; nLocal := 22 
		Case cTipo == "I" ; nLocal := 3		
		Case cTipo == "J" ; nLocal := 25		
		Case cTipo == "K" ; nLocal := 26	
	Endcase
Else
	Do Case 
		Case cTipo == "A" ; nLocal := 2
		Case cTipo == "B" ; nLocal := 3
		Case cTipo == "C" ; nLocal := 4
		Case cTipo == "D" ; nLocal := 7		
		Case cTipo == "E" ; nLocal := 9
		Case cTipo == "F" ; nLocal := 12
		Case cTipo == "G" ; nLocal := 15
		Case cTipo == "H" ; nLocal := 21
	Endcase
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
±±³Funcao    ³QPP131REM1³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui Item                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131REMO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Linha que esta posicionado						  ³±±
±±³          ³ ExpN2 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPP131REMO(nx,nOpc,lInv)
Local ny 
Local lAtu := IIF(lInv,!aValues[nx,Len(aValues[nx])],aValues[nx,Len(aValues[nx])])
Local nTamAr := 22

If lFMEA4a
	nTamAr := 23
Endif

If nOpc == 3 .or. nOpc == 4

	If lAtu
		oPanel4:SetColor(CLR_WHITE,CLR_HGRAY)
		For ny := 1 To Len(aOGets)
			If aOGets[ny] <> Nil
				aOGets[ny]:SetColor(CLR_WHITE,CLR_HGRAY)
				aOGets[ny]:lReadOnly := .T.
			Endif
		Next ny
		oBrwCar:SetColor(CLR_BLACK,CLR_WHITE)
		aValues[nx,Len(aValues[nx])] := .F.
    Else
		oPanel4:SetColor(CLR_BLACK,CLR_WHITE)
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
±±³Funcao    ³ QPP131DELE ³ Autor ³ Cleber Souza        ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131DELE(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP131Dele()

Local cEspecie := "QPPA130"

DbSelectArea("QK8")
DbSetOrder(1)
	
If DbSeek(xFilial("QK8") + QK7->QK7_PECA + QK7->QK7_REV)

	Do While !Eof() .and. ;
		QK7->QK7_PECA + QK7->QK7_REV == QK8_PECA + QK8_REV
		
		If !Empty(QK8->QK8_CHAVE1)
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"A")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"B")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"C")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"D")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"E")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"F")    //QPPXFUN
			QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"G")    //QPPXFUN 
			If lFMEA4a
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"I")    //QPPXFUN
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"J")    //QPPXFUN
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie+"K")    //QPPXFUN
			Endif	
		EndIf		 
		
		DbSelectArea("QK8")
		RecLock("QK8",.F.)
		DbDelete()
		MsUnLock()
		
		DbSkip()
		
	Enddo

Endif

DbSelectArea("QK7")

RecLock("QK7",.F.)
DbDelete()
MsUnLock()
				
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPP131CNPR  ³ Autor ³ Cleber Souza       ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o NPR                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131CNPR(Exp1N)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Linha do array em que esta posicionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP131CNPR(nx,u)

Local cPos
Local lRetorno := .T.
Local nNPRMAX	:= GetMv("MV_NPRMAX")

If Empty(u:cText)
	Return .T.
EndIf

If !(u:cText$"  1 2 3 4 5 6 7 8 9 10")
	lRetorno := .F.
Endif
          
cPos := Right(u:Cargo,2)

If lRetorno
	If lFMEA4a
		If cPos == "11"
			aValues[nx,12] := Str(Val(aValues[nx, 6])*Val(aValues[nx, 9])*Val(aValues[nx, 11]),4)
			If Val(aValues[nx,12]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,12]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Else
			aValues[nx,20] := Str(Val(aValues[nx,17])*Val(aValues[nx,18])*Val(aValues[nx,19]),4)
			If Val(aValues[nx,20]) > nNPRMAX
				MessageDlg(STR0028 +aValues[nx,20]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
			Endif
		Endif
	Else
	If cPos == "10"
		aValues[nx,11] := Str(Val(aValues[nx, 5])*Val(aValues[nx, 8])*Val(aValues[nx, 10]),4)
		If Val(aValues[nx,11]) > nNPRMAX
			MessageDlg(STR0028 +aValues[nx,11]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
		Endif
	Else
		aValues[nx,19] := Str(Val(aValues[nx,16])*Val(aValues[nx,17])*Val(aValues[nx,18]),4)
		If Val(aValues[nx,19]) > nNPRMAX
			MessageDlg(STR0028 +aValues[nx,19]+ STR0029,,2) //"O NPR Calculado de "###" esta acima do limite !"
		Endif
	Endif
	Endif
	oPanel4:Refresh()
Endif

Return lRetorno    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP131REFR³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Refresh dos objetos do FMEA          	     	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131REFR()			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPP131REFR(nOpc)  

Local nY :=0  
Local nItFMEA := 20
Local nPsBmp  := 6

If lFMEA4a
	nItFMEA := 21 
	nPsBmp  := 7
Endif

nAtu:=oBrwCar:nAt // Atualizo a posição

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a linha esta excluida ou naum.					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QPP131REMO(nAtu,nOpc,.T.)

For nY:=1 to Len(aOGets) 
	If aOGets[nY] <> NIL
		aOGets[nY]:SetFocus()
		aOGets[nY]:Refresh()
	Endif	
Next nY

aOGets[nItFMEA]:SetFocus()
IF !Empty(aValues[nAtu,nPsBmp])
	oBmp:SetBmp(aValues[nAtu,nPsBmp])
Else
	oBmp:SetBmp("NOTE")
EndIF
oBmp:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP131APRO³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova / Limpa                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131APRO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QPP131APRO(nOpc)

If nOpc == 3 .or. nOpc == 4
	If nOpc == 4
		If !Empty(M->QK7_APRPOR)
			If Alltrim(M->QK7_APRPOR) == Alltrim(cUserName)
				M->QK7_DATA 	:= Iif(Empty(M->QK7_DATA), dDataBase, CtoD(" / / "))
				M->QK7_APRPOR	:= Iif(Empty(M->QK7_APRPOR), cUserName, Space(40))		
			Else
				MessageDlg(OemToAnsi(STR0035),,2) //"Usuario logado nao e o responsavel pela aprovacao da FMEA de Processo. Para consultar FMEA escolha a opcao Visualizar."		
				//Desabilitar panel para nao permitir edicao qdo responsavel for diferente do usuario logado... 
				oPanel4:lReadOnly := .t.
			Endif
		Else
			M->QK7_DATA 	:= Iif(Empty(M->QK7_DATA), dDataBase, CtoD(" / / "))
			M->QK7_APRPOR	:= Iif(Empty(M->QK7_APRPOR),cUserName, Space(40))		
		Endif	
	Else
		M->QK7_DATA 	:= Iif(Empty(M->QK7_DATA), dDataBase, CtoD(" / / "))
		M->QK7_APRPOR	:= Iif(Empty(M->QK7_APRPOR),cUserName, Space(40))
	Endif	
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP131BSXB  ³ Autor ³ Cleber Souza        ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizacao de descricao com retorno da consulta           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131BSXB(u,nx,oGet,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Get  									  ³±±
±±³          ³ ExpN1 = Linha do Array 									  ³±±
±±³          ³ ExpO2 = Objeto do Get 								      ³±±
±±³          ³ ExpN2 = Opcao QKK ou QAA									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP131BSXB(u,nx,oGet,nOpc)

Local lReturn := .T.
Local nPsBMP  := 6  
Local aArea		 := {}
Local nCont      := 0   
Local lSBOPE  := If(GetMv("MV_QDSBOPE",.F.,1) == 1,.T.,.F.)//Define se o simbolo da operacao será atribuido automaticamente
// ao campo classificacao da severidade se ele nao for definido. 1=SIM 2=NAO 


If lFMEA4a
	nPsBMP  := 7
Endif

If nOpc == 1
	If !Empty(u:cText) 
		QKK->(DbSetOrder(2))
		If (QKK->(DbSeek(xFilial()+M->QK7_PECA+M->QK7_REV+u:cText)))
			aValues[nx,2] := QKK->QKK_DESC
			oGet:lReadOnly := .T.
			If lSBOPE
				If Empty(aValues[nx,nPsBMP])
					aValues[nx,nPsBMP] := QKK->QKK_SBOPE
					oBmp:SetBmp(aValues[nx,nPsBMP])
					oBmp:Refresh()
				EndIf	
			EndIf
		Else
			lReturn := .F.
		Endif
	Else
		oGet:lReadOnly := .F.
	Endif
Elseif nOpc == 2
	If !Empty(u:cText)
		QAA->(DbSetOrder(1))
		If (QAA->(DbSeek(cFilAnt+u:cText)))
			If lFMEA4a
				aValues[nx,14]	:= QAA->QAA_NOME 
			Else
				aValues[nx,13]	:= QAA->QAA_NOME
			Endif	
			oGet:lReadOnly	:= .T.
		Else
			lReturn := .F.
		Endif
	Else
		oGet:lReadOnly := .F.
	Endif
//Validação do Campos ID
Elseif nOpc == 3 .and. !Empty(aValues[nx,28])
        
        aArea := QKM->(GetArea())
		DbselectArea("QKM")
		DbgoTop()                      
		DbsetOrder(2)//FILIAL+ PECA+ REVISAOINVERTIDA +ITEM	
		If Dbseek(xFilial()+M->QK7_PECA+Inverte(M->QK7_REV))
			lReturn := .F.
		   While !Eof()   .AND. QKM_PECA+QKM_REVINV==M->QK7_PECA+Inverte(M->QK7_REV)
		   		IF QKM_NOPE == aValues[nx][1] .AND. QKM_NCAR == aValues[nx][28]
		   		 		lReturn := .T.
	   		 			nCont++
		   		EndIf
		   		DbSkip()
		   EndDo           
		   If nCont <= 0
				MsgAlert(STR0045)//"Não existe amarração para esta Peça , Funçao e Categoria no cadastro de Plano de controle")
					lReturn := .F.
		   Endif
		else
	   		lReturn := .F.
				If nCont <= 0
				MsgAlert(STR0045)//"Não existe amarração para esta Peça , Funçao e Categoria no cadastro de Plano de controle")
					lReturn := .F.
				Endif
			Endif 
		
		RestArea(aArea)
Endif


Return lReturn

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPP131AtuC  ³ Autor ³ Cleber Souza       ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o campo com Zeros a Esquerda                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131AtuC(Exp1N)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Linha do array em que esta posicionado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP131AtuC(nx)

Local lRetorno := .T.
Local nCont
Local nTamSeq   := TamSX3("QK8_SEQ")[1]
Local nItFMEA   := 20

If lFMEA4a
	nItFMEA   := 21
Endif

If !Empty(aValues[nx,nItFMEA]) 
	If nTamSeq == 5
		aValues[nx,nItFMEA] := StrZero(Val(aValues[nx, nItFMEA]),5)
    Else
		aValues[nx,nItFMEA] := StrZero(Val(aValues[nx, nItFMEA]),3)
	Endif

	For nCont := 1 To Len(aValues)
		If aValues[nx,nItFMEA] == aValues[nCont,nItFMEA] .and. nx <> nCont .and. ;
			aValues[nCont,Len(aValues[nCont])]
			lRetorno := .F.
			Help(" ",1,"QPPSEQDUPL") // "Exite Sequencia duplicada !, altere-a"

			Exit
		Endif
	Next nCont
Endif

oPanel4:Refresh()

Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP131PrDe³ Autor ³ Cleber Souza          ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Acha a Proxima dezena para seguencia (que ainda nao existe ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131PrDe(Exp1N)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Valor inicial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP131PrDe(nSeed)

Local nRetorno
Local nCont
Local lLoop := .T.
Local nItFMEA := 20

If lFMEA4a
	nItFMEA := 21
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
±±³Funcao    ³QPP131MOV   ³ Autor ³ Cleber Souza        ³ Data ³ 04/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Movimentação entre as caracteristicas.			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP131MOV(cTipo,nOpc)	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo da Mov.   									  ³±±
±±³          ³ ExpN1 = Opcao QK5										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPP131MOV(cTipo,nOpc)
      
If cTipo == "N"
	If nAtu < Len(aValues)
		nAtu 		:= nAtu+1  
		oBrwCar:nAt := nAtu
		oBrwCar:Refresh()
		QPP131REFR(nOpc)
	EndIf
Else
	If nAtu > 1
		nAtu 		:= nAtu-1  
		oBrwCar:nAt := nAtu
		oBrwCar:Refresh()
		QPP131REFR(nOpc)
	EndIf
EndIF                   

Return          

