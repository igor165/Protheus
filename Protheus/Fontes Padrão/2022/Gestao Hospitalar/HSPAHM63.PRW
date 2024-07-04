#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "dbtree.ch"
#include "msgraphi.ch"
#Include "ApWizard.ch"

//#INCLUDE "HSPAHM63.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun??o	 ณ HSPAHM63 ณ Autor ณ Rogerio Tabosa		ณ data ณ 14/02/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri??o ณ Contru็ใo de Layout para impressใo de relatorios/fichas    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ Geral                                         			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ 					
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHM63() 
Private aRotina 	:= MenuDef()   
Private cCadastro 	:= OemToAnsi("Layout de Impressใo")

If !Hs_ExisDic({{"T","GTQ"}},.T.)
	Return(nil)
EndIf        
DbSelectArea("GTQ") 
mBrowse( 6, 1, 22, 75,"GTQ",,,,,,)

Return(Nil)                         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun??o    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 10/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri??o ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transa??o a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{OemToAnsi("Pesquisar"), 	"AxPesqui"   	, 0, 1, 0, nil},; //"Pesquisar" 
					 {OemtoAnsi("Visualizar"), 	"HSPM63Atu"		, 0, 2, 0, nil},;    //"Visualizar"
					 {OemToAnsi("Incluir"), 	"HSPM63Atu"  	, 0, 3, 0, nil},; //"Incluir"
					 {OemToAnsi("Alterar"), 	"HSPM63Atu"  	, 0, 4, 0, nil},; //"Alterar"
					 {OemToAnsi("Excluir"),		"HSPM63Atu"  	, 0, 5, 0, nil}}  //"Excluir"   
					 
Return(aRotina)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPM63Atu บAutor  ณMicrosiga           บ Data ณ  14/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑบDesc.     ณ  Inclusao, altera็ใo e exclusao de Layout                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SAUDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPM63Atu(cAlias, nReg, nOpc)  

Local nOpcG  	:= aRotina[nOpc, 4]
Local nOpA 		:= ""
Local nGDOpc 	:= IIf( Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
Local aCposGTQ 	:= {}
Local aMemoGTQ 	:= {}
Local aFolder  	:= {}
Local nCont,nI    	:= 0
Local aTela  	:= {}, aGets := {}, aPObjs := {}, aPGDs := {}, aSize := {}, aObjects := {}
Private oGTT		:= Nil
Private aHGTT := {}, aCGTT := {}
//Local aButtons := {{'FORM',{|| Processa({|| FS_VISUALI(aPPanel[1, 1],aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4])}) } ,"Visualizar"}}
Private oGTS		:= Nil
Private aHGTS := {}, aCGTS := {}
Private oPrinter, oTPageView
Private bKeyF5 := SetKey(VK_F5, {|| FS_PREVIEW(aPPanel[1, 1],aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4])})
Private bKeyF11 := SetKey(VK_F11, {|| FS_VISUALI(10,10,500,500)})
Private cLstCfgF := "" //Configura็ใo da fonte padrใo ultima atribuida
Private aHlpBut	 := {}
Private cTabSix	:= ""
RegToMemory("GTQ", (nOpcG == 3))

//Ajustar consultas padrao, caso necessario
AjustaSXB("LHT","LHTAPR","(LHT->LHT_SITFOL <> 'D' .OR. LHT->LHT_SITFOL <> 'T') .AND. (LHT->LHT_FLAGAP = '1' .OR. LHT->LHT_APFIN = '1')")
//AjustaSXB(cAliasOr,cAliasDest,cFiltro)


DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek("GTQ")
	While !SX3->(EoF()) .And. SX3->X3_ARQUIVO == "GTQ"
		If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			If X3_TIPO <> "M" .And. X3_PROPRI # "U" 
/*				_SetOwnerPrvt("o"+X3_CAMPO)
				aAdd(aMemoGG2, {X3_CAMPO, X3_TITULO, X3_VALID, X3_FOLDER, X3_WHEN, "o"+X3_CAMPO})
			Else*/
				aAdd(aCposGTQ, X3_CAMPO)
			EndIf
		EndIF
		DbSkip()
	End
EndIf

aAdd(aFolder, "Relat๓rio")
aAdd(aFolder, "Macro")
//aAdd(aFolder, "Ult. Visualiza็ใo")

aSize 			:= MsAdvSize(.T.)
 
aObjects := {}

aAdd( aObjects, { 100, 050, .T., .T.,.T.} ) // Grids menores do meio
aAdd( aObjects, { 100, 030, .T., .T.,.T.} ) // Grids maiores abaixo
//aAdd( aObjects, { 100, 020, .T., .T.} )     // MsGet
 
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPPanel := MsObjSize( aInfo, aObjects, .T.)  // ObjSize da tela inteira
 

aObjects := {}	
aAdd( aObjects, { 100, 100, .T., .T.,.T.} )	
//aAdd( aObjects, { 050, 100, .T., .T.} )	
 
aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0, 0 }
aPGets := MsObjSize( aInfo, aObjects, .T., ,.T.)  // Obj Folder de Cima

aObjects := {}	
aAdd( aObjects, { 018, 100, .T., .T.,.T.} )	
aAdd( aObjects, { 082, 100, .T., .T.,.T.} )	
 
aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0, 0 }
aPGAux := MsObjSize( aInfo, aObjects, .T., .T.,.T.)  // Obj Codigo e Controles 

aObjects := {}	
aAdd( aObjects, { 100, 100, .T., .T.} )	
//aAdd( aObjects, { 020, 100, .T., .T.,.T.} )	
 
aInfo  := { aPPanel[1, 2], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4], 0, 0 }
aPGets2 := MsObjSize( aInfo, aObjects, .T., .T.,.T.,.T.) // Obj Enc e Tabelas

/*aObjects := {}	
aAdd( aObjects, { 100, 100, .T., .T., .T.} )
 
aInfo  := { aPPanel[3, 2], aPPanel[3, 2], aPPanel[3, 3], aPPanel[3, 4], 0, 0 }
aPInfo := MsObjSize( aInfo, aObjects, .T., .T.) // Obj  MsGet*/


DEFINE MSDIALOG oDlgM63 TITLE OemToAnsi("Layout de Impressใo") From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
           
oFolEnc := TFolder():New( aPGets[1, 1],  aPGets[1, 2], aFolder, aFolder, oDlgM63,,,, .T., , aPGets[1, 3], aPGets[1, 4] )
oFolEnc:Align := CONTROL_ALIGN_TOP
//oFolEnc:bChange := {|| IIf(oFolEnc:nOption == 3, FS_PREVIEW(aPGets[1, 1],aPGets[1, 2], aPGets[1, 3], aPGets[1, 4]),Nil )}

oGTQCodigo := tMultiget():New(aPGAux[2, 1],aPGAux[2, 2],{|u|if(Pcount()>0,M->GTQ_FUNCAO:=u,M->GTQ_FUNCAO)},oFolEnc:aDialogs[1],aPGAux[2, 3],aPGets[1, 4],,.T.,,,,.T.,,,,,,,{||HS_VldM63()})
//oGTQCodigo:Align := CONTROL_ALIGN_ALLCLIENT

oTScrollBox :=  TScrollBox():New(oFolEnc:aDialogs[1],aPGAux[1, 1],aPGAux[1, 2],aPGAux[1, 4],aPGAux[1, 3],.T.,.T.,.T.)
//oTScrollBox :=  TScrollBox():New(oFolEnc:aDialogs[1],aPGAux[2, 1],aPGAux[2, 2],aPGAux[1, 3],aPGAux[2, 4],.T.,.T.,.T.)

@ aPGAux[1, 1],010 SAY oSay PROMPT "Op็๕es:" SIZE 120,009 OF oTScrollBox PIXEL COLOR CLR_HBLUE //FONT oFont//"="


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBotใo de visualiza็ใo do Relat๓rioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nI := nI + 12
oBtCtrlP1  := tButton():New(aPGAux[1, 1]+ nI, 010, "Visualizar" , oTScrollBox, {|| Processa({|| FS_VISUALI(aPPanel[1, 1],aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4])})}, 065, 010,,,, .T.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณtexto padrใo com possibilidade de configura็ใo da fonteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nI := nI + 12
oBtHelpP11  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("TXT") }, 010, 010,,,, .T.)    
oBtCtrlP11  := tButton():New(aPGAux[1, 1]+ nI, 025, "Texto" , oTScrollBox, {|| FS_TXTPAD("","Texto")}, 050, 010,,,, .T.)
AADD(aHlpBut, {"TXT", 	"Informe o texto que sera exibido no relatorio"+ Chr(10)+;
						"com possibilidade de formata็ใo da fonte"})   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ campo e pergunta relacionada do pergunte ou tabelaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nI := nI + 12
oBtHelpP12  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("CP") }, 010, 010,,,, .T.)    
oBtCtrlP12  := tButton():New(aPGAux[1, 1]+ nI, 025, "Campo/Pergunta" , oTScrollBox, {|| FS_RETCPO(oGTQCodigo,,.T.)}, 050, 010,,,, .T.)

AADD(aHlpBut, {"CP", 	"Informe o campo ou pergunta para que" + Chr(10)+;
						" seu conteudo seja exibido no relat๓rio, "+ Chr(10)+;
						" os campos sใo definidos atrav้s do grid "+ Chr(10)+;
						" de tabelas de dados, e a pergunta pelo campo"+ Chr(10)+;
						" GTQ_CODPER (Pergunta) na aba Dados Gerais"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabe็alho para relatorios que nao sao do tipo imagemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nI := nI + 12
oBtHelpP1  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("IC") }, 010, 010,,,, .T.)    
oBtCtrlP1  := tButton():New(aPGAux[1, 1]+ nI, 025, "Cabe็alho" , oTScrollBox, {|| FS_TXTPAD("#IC", "Cabe็alho","#FC")}, 050, 010,,,, .T.)
AADD(aHlpBut, {"IC", 	"Informe o texto que sera exibido no cabe็alho"+ Chr(10)+;
						"do relatorio.(nใo disponivel para tipo imagem) "})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Detalhes do relat๓rio          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nI := nI + 12
oBtHelpP3  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("DET") }, 010, 010,,,, .T.)    
oBtCtrlP3  := tButton():New(aPGAux[1, 1]+ nI, 025, "Detalhes" , oTScrollBox, {|| FS_WIZDET(M->GTQ_CODPER)}, 050, 010,,,, .T.)

AADD(aHlpBut, {"DET", 	" Wizard para configura็ใo dos detalhes. " + Chr(10)+;
						" ษ recomendavel preenchimento e utiliza็ใo "+ Chr(10)+;
						" de indices para a pesquisa, para utilizar " + Chr(10)+;
						" campos virtuais ้ preciso saber qual tabela"+ Chr(10)+;
						" serแ relacionado para a busca do dado real."})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Rodap้ para relatorios que nao sao do tipo imagem   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nI := nI + 12
oBtHelpP4  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("IR") }, 010, 010,,,, .T.)    
oBtCtrlP4  := tButton():New(aPGAux[1, 1]+ nI, 025, "Rodape" , oTScrollBox, {|| FS_TXTPAD("#IR", "Rodap้","#FR")}, 050, 010,,,, .T.)

AADD(aHlpBut, {"IR", 	"Informe o texto que sera exibido no rodap้ "+ Chr(10)+;
						"do relatorio.(nใo disponivel para tipo imagem) "})


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
	
//ณInsere Box (caixa sem prenchimento) no relat๓rioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
	
nI := nI + 12
oBtHelpP5  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("DB") }, 010, 010,,,, .T.)    
oBtCtrlP5  := tButton():New(aPGAux[1, 1]+ nI, 025, "Box" , oTScrollBox, {|| FS_ObjCoord("#DB", "Desenha box")}, 050, 010,,,, .T.)    

AADD(aHlpBut, {"DB", 	" Insere Box(Caixa sem preenchimento) no relatorio."+ Chr(10)+;
						" (Necessแrio atriubuir coordenadas em pixels) "})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
	
//ณInsere linha no relat๓rioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
	
nI := nI + 12
oBtHelpP6  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("DL") }, 010, 010,,,, .T.)    
oBtCtrlP6  := tButton():New(aPGAux[1, 1]+ nI, 025, "Linha" , oTScrollBox, {|| FS_ObjCoord("#DL", "Desenha linha")}, 050, 010,,,, .T.)

AADD(aHlpBut, {"DL", 	" Insere linha no relatorio."+ Chr(10)+;
						" (Necessแrio atriubuir coordenadas em pixels) "})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
//ณInsere retangulo com preenchimento no relat๓rioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)

nI := nI + 12
oBtHelpP7  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("DR") }, 010, 010,,,, .T.)    
oBtCtrlP7  := tButton():New(aPGAux[1, 1]+ nI, 025, "Retangulo" , oTScrollBox, {|| FS_ObjCoord("#DR" ,"Desenha retangulo com preenchimento",.T.)}, 050, 010,,,, .T.)

AADD(aHlpBut, {"DR", 	" Insere retangulo com preenchimento."+ Chr(10)+;
						" (Necessแrio atriubuir coordenadas em pixels) "})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)

//ณInsere imagem BMP de diretorio no relat๓rioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
nI := nI + 12
oBtHelpP8  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("BM") }, 010, 010,,,, .T.)    
oBtCtrlP8  := tButton():New(aPGAux[1, 1]+ nI, 025, "Imagem" , oTScrollBox, {|| FS_PrtImg("#BM", "Imagem", .F.)}, 050, 010,,,, .T.)

AADD(aHlpBut, {"BM", 	" Insere imagem no relat๓rio."+ Chr(10)+;
						" Recomendแvel utilizar extens๕es 'BMP' e "+ Chr(10)+;
						" imagens no diret๓rio do servidor(DATA)"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
//ณInsere grafico da rotina de indicadores no relat๓rioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
nI := nI + 12
oBtHelpP9  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("GRAF") }, 010, 010,,,, .T.)    
oBtCtrlP9  := tButton():New(aPGAux[1, 1]+ nI, 025, "Grafico" , oTScrollBox, {|| FS_PrtImg("#BM", "Grafico", .T.)}, 050, 010,,,, .T.)

AADD(aHlpBut, {"GRAF", 	" Insere grแfico no relat๓rio."+ Chr(10)+;
						" Necessแrio ter o grafico cadastrado na "+ Chr(10)+;
						" rotina de Cadastro de Indicadores(HSPAHP03),"+ Chr(10)+;
						" e o mesmo possua retorno em sua pesquisa."})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
//ณInsere codigo de barras  no relat๓rioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ)
nI := nI + 12
oBtHelpP10  := tButton():New(aPGAux[1, 1]+ nI, 010, "?", oTScrollBox, {|| FS_HLPBUT("CB") }, 010, 010,,,, .T.)    
oBtCtrlP10  := tButton():New(aPGAux[1, 1]+ nI, 025, "C๓digo de Barras" , oTScrollBox, {|| FS_CODBAR()}, 050, 010,,,, .T.)

AADD(aHlpBut, {"CB", 	" Insere c๓digo de barras no relat๓rio."+ Chr(10)+;
						" Configurar o dado de origem do c๓digo."})

//Desabilita as op็๕es na visualiza็ใo
If nGDOpc == 0 .AND. nOpc <> 5
	oBtCtrlP1:Disable()	
	oBtCtrlP3:Disable()	
	oBtCtrlP4:Disable()		
	oBtCtrlP5:Disable()	
	oBtCtrlP6:Disable()	
	oBtCtrlP7:Disable()	
	oBtCtrlP8:Disable()	
	oBtCtrlP9:Disable()	
	oBtCtrlP10:Disable()	
	oBtCtrlP11:Disable()	
	oBtCtrlP12:Disable()		
EndIf

DbSelectArea("GTR")
DbSetOrder(1)
DbGoTop()
While !Eof() 
	AADD(aHlpBut, {Alltrim(GTR->GTR_CODIGO), GTR->GTR_HELP})
	nI := nI + 12
	&("oBtHelp" + GTR->GTR_CODIGO)  := &("tButton():New("+ Alltrim(Str(aPGAux[2, 1]+ nI))  +", 010, '?', oTScrollBox, {|| FS_HLPBUT('" + Alltrim(GTR->GTR_CODIGO) + "')}, 010, 010,,,, .T.)")    //"Efetiva"
	&("oBtCtrl" + GTR->GTR_CODIGO)  := &("tButton():New("+ Alltrim((Str(aPGAux[2, 1]+ nI)))+", 025, '" + Alltrim(GTR->GTR_DESCR) + "', oTScrollBox, {|| FS_TXTPAD('" + GTR->GTR_CODIGO + "')}, 050, 010,,,, .T.)")    //"Efetiva"
	If nGDOpc == 0
		&("oBtHelp" + GTR->GTR_CODIGO + ":Disable()")
	EndIf
	DbSkip()
EndDo


oGTQMacro := tMultiget():New(aPGets[1, 1],aPGets[1, 2],{|u|if(Pcount()>0,M->GTQ_MACRO:=u,M->GTQ_MACRO)},oFolEnc:aDialogs[2],aPGets[1, 3],aPGets[1, 4],,,,,,.T.)
oGTQMacro:Align := CONTROL_ALIGN_ALLCLIENT

oPrinter := TMsPrinter():New()
oPrinter:SetFile( '\SPOOL\hspahrdr.prt', .F.)

//oPrinter:SetFile( '\SPOOL\' + Alltrim(M->GTQ_FUNCAO), .F.)
//oPrinter:Refresh()
//oTPageView:Show()
/*
oTPageView := TPageView():New( aPGets[1, 1],aPGets[1, 2],aPGets[1, 3],aPGets[1, 4],oPrinter,oFolEnc:aDialogs[3],550,550 )
oTPageView:align:= CONTROL_ALIGN_ALLCLIENT
oTPageView:Show()
oTPageView:nZoom := 150
*/

@ aPPanel[2, 1], aPPanel[2, 2] FOLDER oFolGDs SIZE aPPanel[2, 3], aPPanel[2, 4] Pixel OF oDlgM63 Prompts "Dados Gerais", "Tabelas ", "Permiss๕es"

//RegToMemory("GTQ", (nOpc == 3))

oEnchoi := MsMGet():New("GTQ",nReg,nOpc,,,,aCposGTQ,{aPGets2[1, 1], aPGets2[1, 2], aPGets2[1, 3], aPGets2[1, 4]}, , , , , ,oFolGDs:aDialogs[1])
oEnchoi:oBox:align:= CONTROL_ALIGN_ALLCLIENT 

HS_BDados("GTS", @aHGTS, @aCGTS,,1,, "GTS->GTS_CODLAY = '" + M->GTQ_CODIGO + "'",,,,,,,,,,,,,,,,,,)		    
nGTSArquiv := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_ARQUIV"})
nGTSIndice := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_INDICE"})
nGTSDado   := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_DADO"})
nGTSDesArq   := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_DESARQ"})
nGTSOrdExe   := aScan(aHGTS, {| aVet | AllTrim(aVet[2]) == "GTS_ORDEXE"})

oGTS := MsNewGetDados():New(aPGets2[1, 1], aPGets2[1, 2], aPGets2[1, 3], aPGets2[1, 4], nGDOpc,,,,,, 99999,,,, oFolGDs:aDialogs[2], aHGTS, aCGTS)
oGTS:oBrowse:BlDblClick := {|| FS_DblCGTS(oGTS:oBrowse:nAt, oGTS:oBrowse:nColPos)} 
oGTS:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
oGTS:oBrowse:bGotFocus := {|| cTabSix :=  oGTS:aCols[oGTS:oBrowse:nAt,nGTSArquiv] }

HS_BDados("GTT", @aHGTT, @aCGTT,,1,, "GTT->GTT_CODLAY = '" + M->GTQ_CODIGO + "'",,,,,,,,,,,,,,,,,,)		    
nGTTCodUsu := aScan(aHGTT, {| aVet | AllTrim(aVet[2]) == "GTT_CODUSU"})


oGTT := MsNewGetDados():New(aPGets2[1, 1], aPGets2[1, 2], aPGets2[1, 3], aPGets2[1, 4], nGDOpc,,,,,, 99999,,,, oFolGDs:aDialogs[3], aHGTT, aCGTT)
//oGTT:oBrowse:BlDblClick := {|| FS_DblCGTS(oGTS:oBrowse:nAt, oGTS:oBrowse:nColPos)} 
oGTT:oBrowse:align := CONTROL_ALIGN_ALLCLIENT


ACTIVATE MSDIALOG oDlgM63 ON INIT EnchoiceBar (oDlgM63, {	|| 	nOpA := 1,;
														IIF(Obrigatorio(aGets, aTela) .And. oGTS:TudoOk(),;
														oDlgM63:End(), nOpA := 0)},;
														{|| nOpA := 0, oDlgM63:End()},,)														

If ValType(nOpA) <> "N"	// Caso na inclusao seja clicado no botao "x" superior
	Return()
EndIf

If (nOpA == 1) .And. (nOpcG <> 2)
	Begin Transaction
	FS_GrvEst(nOpcG)
	While __lSx8
		ConfirmSx8()
	End
	End Transaction
	
ElseIf nOpcG <>2
	While __lSx8
		RollBackSxe()
	End
Endif

Return
/*
Static Function FS_PREVIEW(nCoord1,nCoord2, nCoord3, nCoord4)
oPrinter:SetFile( '\SPOOL\' + Alltrim(M->GTQ_FUNCAO), .F.)
oPrinter:Refresh()
FreeObj(oTPageView)
oTPageView := Nil
oTPageView := TPageView():New( nCoord1,nCoord2,nCoord3,nCoord4,oPrinter,oFolEnc:aDialogs[3],800,600 )
oTPageView:align:= CONTROL_ALIGN_ALLCLIENT
oTPageView:Show()
oTPageView:nZoom := 150
Return()     */


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VISUALIบAutor  ณMicrosiga           บ Data ณ  12/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza relatorio                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VISUALI(nCoord1,nCoord2, nCoord3, nCoord4)
Local bBlock   	:= ErrorBlock(), bErro := ErrorBlock( { |e| ChekBug(e) } )      
Local aArea  := GetArea()
Local cNomArq := "HSPM63TMP.txt" 

Private cTitulo  := IIf(Empty(M->GTQ_DESCR),"Constru็ใo de Relat๓rio", Alltrim(M->GTQ_DESCR))
Private cNomerel := "HSPAHM63"
Private Tamanho  := "M"
Private aReturn  := {"Zebrado", 1, "Administra็ใo", 2, 2, 1, "", 1} //"Zebrado"###"Administra็ใo"
Private nLastKey := 0
Private m_pag    := 01
Private nLin     := 0
Private oPrint

If !Empty(M->GTQ_CODPER)
	If !Pergunte(M->GTQ_CODPER, .T.)
		Return()
	EndIf	
EndIf

HS_EXEGTS(oGTS:aCols,nGTSArquiv, nGTSOrdExe, nGTSDado,nGTSIndice)

HS_MacGTQ(M->GTQ_MACRO) // Executa os macros existentes

oGTS:oBrowse:SetFocus() //Tira o foco do memo pra gravar o texto na mem๓ria 
                   
If oPrint <> Nil  // Limpa o objeto
	FreeObj(oPrint)	
	oPrint:Refresh()
EndIf

oPrint := TMSPrinter():New(cTitulo)

FS_GRAVATXT(cNomArq)

//cNomeRel := SetPrint(cAlias, cNomeRel, "", @cTitulo, "", "", "", .T., "", .T., Tamanho, , .T.)
//SetDefault(aReturn, cAlias)
nTipo := If(aReturn[4] == 1, 15, 18)
If nLastKey == 27
	RestArea(aArea)
	Return(Nil)
EndIf

HSPFITXT(cNomArq, IIf(M->GTQ_TIPIMP == "0","1","4"))  //Executa a Funcao que esta cadastrada no PARAMETRO,  para imprimir o protocolo.

oPrint:Preview()

/*
FreeObj(oTPageView)
oTPageView := Nil

//oTPageView := TPageView():New( nCoord1,nCoord2,nCoord3,nCoord4,oPrint,oFolEnc:aDialogs[3],800,600 )
oTPageView:align:= CONTROL_ALIGN_ALLCLIENT
oTPageView:Show()
oTPageView:nZoom := 150
*/
	
oPrint:End()

/*Ms_Flush()
If aReturn[5] == 1
	OurSpool(cNomerel)
EndIf*/

RestArea(aArea)
ErrorBlock(bBlock)
Return()           

Static Function Chekbug(e)
Local cDadosErro := ""
If e:gencode > 0
 	cDadosErro := "Pilha: " + e:ERRORSTACK
	HS_MsgInf("Erro: " + e:Description + Chr(13) + Chr(10) + cDadosErro,"Aten็ใo","Anแlise Indicadores")
	lRetErro:=.F.
EndIf
Break
Return(lRetErro)

/*
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TXTPAD บAutor  ณMicrosiga           บ Data ณ  12/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para os controles padr๕es de a็ใo de constru็ใo no   บฑฑ
ฑฑบ          ณrelatorio                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SAUDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TXTPAD(cTag, cTitulo, cFimTag) 
Local cTxtPad 	:= ""
Local lCfg 		:= .F.
Local oDlgM, oTexto
Local nPos := 0, nPosCtrl := 0
Local aTipFontR71 := {"0=Arial","1=Courier New", "2=Times New Roman", "3=Helvetica", "4=Microsoft Sans Serif", "5=Verdana", "6=Tahoma", "7=Andalus", "8=Century", "9=Cordia New"}//Fontes homologadas para a classe TMSPrinter - GC8_TIPFONT
Local aEstFontR71 := {"1=Regular", "2=Italico", "3=Negrito", "4=Sublinhado", "5=Negrito Italico", "6=Negrito Sublinhado", "7=Italico Sublinhado", "8=Negrito Italico Sublinhado"}//GC8_ESTFONT
Local aTamFontR71 := {"6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24"}
Local nPosTip := 0
Local nPosEst := 0
Local nPosTam := 0
Local nOpcM	  := 0
Local cCfgFont:= ""
Local cLgNegr := ".F."
Local cLgItal := ".F."
Local cLgSubl := ".F."   
Local nLbxEstFont, nLbxTipFont, nLbxTamFont, nColorRet

Local cDado1 	:= ""
Local cDado2 	:= ""
Local cStrFull:= ""


Default cTitulo := "Texto" 
Default cTag	:= ""
Default cFimTag	:= ""

If !("#" $ cTag) .AND. !Empty(cTag) // caso nao possua caracter da TAG e nใo esteja em branco ้ porque ้ um botใo de usuแrio GTR
	DbSelectArea("GTR")
	DbSetOrder(1)
	If DbSeek(xFilial("GTR") + cTag)
		lCfg := (GTR->GTR_EXBMEM == "1")
		cTxtPad := GTR->GTR_TEXTO
	EndIf 
ELse 
	lCfg := .T.	
EndIf

If !lCfg 
	cDado1 := Substr(M->GTQ_FUNCAO, 1, oGTQCodigo:nPos) 
	cDado2 := Substr(M->GTQ_FUNCAO, oGTQCodigo:nPos, Len(M->GTQ_FUNCAO))	
	M->GTQ_FUNCAO := ""//    
	oGTQCodigo:refresh()
	oGTQCodigo:nPos := 1
	oGTQCodigo:AppendText( cDado1 + cTxtPad + Chr(10) + cDado2 )
	Return()
EndIf

DEFINE MSDIALOG oDlgM FROM	62,100 TO 510,510 TITLE cTitulo PIXEL 

	@ 006, 008 SAY oSay PROMPT "Informe o texto:"	SIZE 60,009 OF oDlgM PIXEL COLOR CLR_HBLUE 
	oBtCD  := tButton():New(006, 170, "+ Dado", oDlgM, {|| FS_RETCPO(@oTexto,,.T., cTxtPad, .F.),oTexto:Refresh() }, 023, 008,,,, .T.)    		
	@ 015, 008 GET oTexto VAR cTxtPad MEMO When .T. SIZE 185, 060 OF oDlgM PIXEL  

	@ 080,008 LISTBOX oLbxTipFont FIELDS HEADER "Fonte" SIZE 060,060 OF oDlgM PIXEL  //
	oLbxTipFont:SetArray( aTipFontR71 )
	oLbxTipFont:bLine := {|| {aTipFontR71[oLbxTipFont:nAt]}}
	if nPosTip > 0
		oLbxTipFont:nAt := nPosTip
	else
		oLbxTipFont:nAt := 1 	
	endif
	oLbxTipFont:refresh()
	 
	@ 080,077 LISTBOX oLbxEstFont FIELDS HEADER "Estilo" SIZE 060,060 OF oDlgM PIXEL  //
	oLbxEstFont:SetArray( aEstFontR71 )
	oLbxEstFont:bLine := {|| {aEstFontR71[oLbxEstFont:nAt]}}
	if nPosEst > 0
		oLbxEstFont:nAt := nPosEst
	else
		oLbxEstFont:nAt := 1	 	
	endif
	oLbxEstFonte:refresh()
	
	@ 080,147 LISTBOX oLbxTamFont FIELDS HEADER "Tamanho" SIZE 045,060 OF oDlgM PIXEL  //
	oLbxTamFont:SetArray( aTamFontR71 )
	//oLbxTamFont:bChangeGetPos()
	oLbxTamFont:bLine := {|| {aTamFontR71[oLbxTamFont:nAt]} }
	if nPosTam > 0
		oLbxTamFont:nAt := nPosTam
	else
		oLbxTamFont:nAt := 5 	
	endif
	oLbxTamFont:refresh()
  
	oTColorTriangle2 := tColorTriangle():New(145,020,oDlgM,160,60)
	oTColorTriangle2:SetColorIni( 0 ) 

DEFINE SBUTTON FROM 208,70 TYPE 1 ACTION {|| nOpcM := 1, nColorRet := oTColorTriangle2:RetColor(),nLbxTamFont := oLbxTamFont:nAt,;
											 nLbxEstFont := oLbxEstFont:nAt, nLbxTipFont := oLbxTipFont:nAt,;
											 oDlgM:End()} ENABLE OF oDlgM
											 //IIf(!Empty(cTxtPad) .OR. " " $ cTxtPad, oDlgM:End(), nIL)} ENABLE OF oDlgM											  
DEFINE SBUTTON FROM 208,100 TYPE 2 ACTION { ||  nOpcM := 2 , oDlgM:End()} ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED //VALID IIf(Empty(Alltrim(cTxtPad)),.F.,.T.)                                     
                 
If nOpcM == 1
	lOnlyFont := Empty(cTxtPad)  
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ   //nLbxEstFont, nLbxTipFont, nLbxTamFont
	//ณAtribui estilos escolhidos na fonteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 	//TFont():New(aParDF[1],, aParDF[2],, aParDF[3],,,, aParDF[4], aParDF[5]), &("HS_Color(" + aParDF[6] + ")")
	If nLbxEstFont == 3 .OR. nLbxEstFont == 5 .OR. nLbxEstFont == 6 .OR. nLbxEstFont == 8	
		cLgNegr := ".T."
	EndIf
	If nLbxEstFont == 4 .OR. nLbxEstFont == 6 .OR. nLbxEstFont == 7 .OR. nLbxEstFont == 8		
		cLgSubl := ".T."
	EndIf
	If nLbxEstFont == 2 .OR. nLbxEstFont == 5 .OR. nLbxEstFont == 7 .OR. nLbxEstFont == 8		
		cLgItal := ".T."
	EndIf        
	
	cCfgFont := "#DF {'" + Alltrim(SubStr(aTipFontR71[nLbxTipFont],At("=", aTipFontR71[nLbxTipFont])+1,Len(aTipFontR71[nLbxTipFont]))) + "'," +;
				aTamFontR71[nLbxTamFont] + "," + cLgNegr + ","+cLgSubl+","+cLgItal+",'" + Alltrim(Str(nColorRet))  + "'}"

	If Empty(cLstCfgF) .OR. cLstCfgF <> cCfgFont	
		cStrFull += (Chr(10) + cCfgFont + Chr(10))	 
		//oGTQCodigo:AppendText( cCfgFont + Chr(10))
		cLstCfgF := cCfgFont 			
	EndIf
	If "#" $ cTag
		cTxtPad := cTag +" "+ cTxtPad + " "+cFimTag		
	EndIf
	cStrFull += cTxtPad	
	//oGTQCodigo:AppendText( cTxtPad + Chr(10))	
	cDado1 := Substr(M->GTQ_FUNCAO, 1, oGTQCodigo:nPos) 
	cDado2 := Substr(M->GTQ_FUNCAO, oGTQCodigo:nPos, Len(M->GTQ_FUNCAO))	
	M->GTQ_FUNCAO := ""//    
	oGTQCodigo:refresh()
	oGTQCodigo:nPos := 1
	oGTQCodigo:AppendText( cDado1 + cStrFull + cDado2 )	
EndIf			

Return(cTxtPad)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRAVATXTบAutor  ณMicrosiga           บ Data ณ  12/04/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GRAVATXT(cArquivo)

Local cNomArq	:= ""
Local cArqNf        := ""  
Local cCaminho := AllTrim(GetMV("MV_DIRTXT"))  

cNomArq := cCaminho + cArquivo

FErase(cNomArq)
cArqNf:=fCreate(cNomArq)

FWrite(cArqNf,M->GTQ_FUNCAO)

FClose(cArqNf)

Return()



Static Function FS_DblCGTS(nLin, nCol)
	
If oGTS:oBrowse:nColPos == nGTSDado
	oGTS:aCols[nLin, nGTSDado] := FS_DATAIND(oGTS:aCols[nLin, nGTSArquiv],oGTS:aCols[nLin, nGTSIndice], oGTS:aCols[nLin, nGTSDado], oGTS:aCols[nLin, nGTSDesArq], Val(oGTS:aCols[nLin, nGTSOrdExe]),M->GTQ_CODPER)
Else	
	oGTS:EDITCELL( oGTS:OBROWSE, nLin, nCol )
EndIf
oGTS:oBrowse:Refresh()
	
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_DATAIND บ Autor ณ                    บ Data ณ  19/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Insere em Campo Memo campos pre-definidos para o Relatorio บฑฑ
ฑฑบ          ณ de Informe de Rendimento PLSR997                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function FS_DATAIND(cAlias, cIndice, cDadoInd,cDesAlias, nOrdExe, cPerg)
Local aArea  := GetArea()
Local cIndRet := cDadoInd 
Local cStrInd := ""    
Local cCpoInd := ""    
Local nPos := 0, nPosCtrl := 0, nI := 0
Local aCpsInd	:= {}
Local oDlgM, oLbx, oTexto
Local lEdit  := .T.
Local cLabel := ""
Local aHeadCpo 	:= {}
Local aHAlias	:= {}
Local aCpsAlias	:= {}
Local aHCpoVin 	:= {}
Local aCpsVin	:= {}
Local aHPerg 	:= {}
Local aCpsPer	:= {}
Local oTreeTab := Nil   
Local nCps 		:= 0
Local aDadOri	:= {}  
Local cDadOri	:= cDadoInd 
Local nOpcI		:= 2

Local cTexto := ""

DbSelectArea("SX3")	
DbSelectArea("SX2")	

DbSelectArea("SIX")
DbSetOrder(1)
If DbSeek(cAlias+cIndice)   
	cStrInd := Alltrim(SIX->CHAVE)
Else 
	MsgStop("Indice nใo encontrado!","Aten็ใo")
	Return(cDadoInd)
EndIf

If !Empty(cDadoInd)
	If At(")+",cDadoInd) > 0    
		While !Empty(cDadoInd)
			If At(")+",cDadoInd) > 0
				AADD(aDadOri, Substr(cDadoInd, 1, At(")+",cDadoInd)) )
				cDadoInd := Substr(cDadoInd, At(")+",cDadoInd)+2,Len(cDadoInd) ) 
			Else 
				AADD(aDadOri, cDadoInd) 				
				cDadoInd := ""
			EndIf
		EndDo
	ElseIf At("+",cDadoInd) > 0
		While !Empty(cDadoInd)
			If At("+",cDadoInd) > 0
				AADD(aDadOri, Substr(cDadoInd, 1, At("+",cDadoInd)-1))
				cDadoInd := Substr(cDadoInd, At("+",cDadoInd)+1,Len(cDadoInd) ) 
			Else 
				AADD(aDadOri, cDadoInd) 				
				cDadoInd := ""
			EndIf
		EndDo		
	EndIf	
EndIf

While !Empty(cStrInd)                    
	cDadAux := Space(100)
	If (nPos1 := At("+", cStrInd)) > 0
		cCpoInd := Substr(cStrInd, 1, nPos1 - 1)
		cStrInd :=  Substr(cStrInd, nPos1 + 1, Len(cStrInd)) 		
	Else 
		cCpoInd := cStrInd
		cStrInd := ""
	EndIf 

	If !(cAlias $ Substr(cCpoInd,1,3)) .AND. (nPos1:= At("(", cCpoInd)) > 0
		cCpoInd := Alltrim(Substr(cCpoInd,nPos1+1, Len(cCpoInd)-1))
	EndIf
	DbSelectArea("SX3")	
	DbSetOrder(2)
	DbSeek(cCpoInd)
	If "_FILIAL" $ 	cCpoInd
		nCps ++
		cDadAux := PADR("(xFilial('" + cAlias + "'))",100)
		AADD(aCpsInd, {cCpoInd,cDadAux, SX3->X3_TITULO, SX3->X3_DESCRIC, SX3->X3_TIPO, SX3->X3_TAMANHO,.F.})		
	Else
		nCps ++              
		If nCps <= Len(aDadOri)
	   		cDadAux := aDadOri[nCps]
	 	EndIf
		AADD(aCpsInd, {cCpoInd,cDadAux, SX3->X3_TITULO, SX3->X3_DESCRIC, SX3->X3_TIPO, SX3->X3_TAMANHO,.F.})
	EndIf
EndDo

//Header do GRID de Campos
aAdd(aHeadCpo,{"Campo","HSPCAMPO","@!", Len(SX3->X3_CAMPO),0, ,,"C", ,"R",,,,"V",,,.T.})  
aAdd(aHeadCpo,{"Dado","HSPDADO","", 100,0,,,"C",         ,"R",,,,"A",,,.T.}) 
aAdd(aHeadCpo,{"Titulo","HSPTITULO","@!",  Len(SX3->X3_TITULO),0, ,,"C",         ,"R",,,,"V",,,.T.}) 
aAdd(aHeadCpo,{"Descri็ใo","HSPDESCRIC","@!",  Len(SX3->X3_DESCRIC),0, ,,"C",         ,"R",,,,"V",,,.T.})  
aAdd(aHeadCpo,{"Tipo","HSPTIPO","@!",  Len(SX3->X3_TIPO),0, ,,"C",         ,"R",,,,"V",,,.T.}) 
aAdd(aHeadCpo,{"Tamanho","HSPTAMANHO","",  3,0, ,,"C",         ,"R",,,,"V",,,.T.}) 

nCampo := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPCAMPO"})
nDado := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPDADO"})
nTitulo := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPTITULO"})

DEFINE MSDIALOG oDlgIND FROM 62,100 TO 420,780 TITLE "Montagem do Indice" PIXEL //"Complemeto de Informe de Rendimento" //"Complemento de Informe de Rendimento"

Define  FONT oFont NAME "Arial,12," BOLD  
@ 006,010 SAY oSay PROMPT "Campos" + Iif(!Empty(cDesAlias), " tabela: " + cDesAlias,"")	SIZE 200,009 OF oDlgIND PIXEL COLOR CLR_HBLUE FONT oFont//"="

oCampos := MsNewGetDados():New(13, 10, 143, 155,GD_UPDATE,,,,,,,,,, oDlgIND , aHeadCpo, aCpsInd)
oCampos:oBrowse:bGotFocus := {|| oSayHlp:setText("* Posicione no campo para atribuir o dado do indice" ) }
//oCampos:oBrowse:BLDblClick := {|| FS_DblCpo(oCampos, nDado, @cIndRet) }
//oCampos:bLinhaOk 	    := {|| FS_ATRBCPO("",@cIndRet)} 
 
@ 165,030 SAY oSayHlp PROMPT "* Posicione no campo para atribuir o dado do indice (os dois primeiros campos sใo de preenchimento obrigat๓rio)"	SIZE 500,009 OF oDlgIND PIXEL COLOR CLR_HRED //FONT oFont//"="
//================================================================ฟ
//ณ Folder de vinculo do dado					                 ณ
//================================================================ู 	                                           
@ 005, 168 FOLDER oFolVin SIZE 170, 158  OF oDlgIND PIXEL PROMPTS "Campos / Perguntas"
//oFolVin:bSetOption := {|| oSayHlp:setText("* D๊ duplo clique " + IIf(oFolVin:nOption <> 1, "no campo escolhido","na pergunta escolhida") + " para compor o indice no campo (" + Alltrim(oCampos:aCols[oCampos:nAt, nTitulo]) + ")") } 
//oFolVin:Align := CONTROL_ALIGN_ALLCLIENT    

DEFINE DBTREE oTreeTab FROM 05, 05 TO 100, 100 CARGO OF oFolVin:aDialogs[1] Pixel

If nOrdExe > 1 .AND.  Len(oGTS:aCols) >= nOrdExe
	DBADDTREE oTreeTab PROMPT PADR("Tabelas",50) RESOURCE "BMPGROUP" CARGO PADR("Tabelas",100)
	For nI := 1 to Len(oGTS:aCols)
		If Val(oGTS:aCols[nI,nGTSOrdExe]) < nOrdExe
			DBADDTREE oTreeTab PROMPT PADR(oGTS:aCols[nI,nGTSArquiv] + " -> " + oGTS:aCols[nI,nGTSDesArq],50) RESOURCE "PRODUTO" CARGO PADR("Cab|" + oGTS:aCols[nI,nGTSArquiv],100)
			DbSelectArea("SX3")
			DbGoTop()
			DbSetOrder(1)
			If DbSeek(Alltrim(oGTS:aCols[nI,nGTSArquiv]))
				While !Eof() .AND. SX3->X3_ARQUIVO == oGTS:aCols[nI,nGTSArquiv]
					DBADDITEM oTreeTab PROMPT PADR(SX3->X3_CAMPO + " - " + Alltrim(SX3->X3_TITULO) + " (" + Alltrim(SX3->X3_TIPO) + "," + Alltrim(Str(SX3->X3_TAMANHO)) + ")",50)   RESOURCE "BR_WHITE" CARGO PADR(Alltrim(SX3->X3_CAMPO) + "|" + Alltrim(SX3->X3_TITULO) + "|*CPO*",100)
					DbSkip()
				EndDo
			EndIf
			DBENDTREE oTreeTab
		EndIf
	Next nI
	DBENDTREE oTreeTab
EndIf


oTreeTab:bGotFocus := {|| oSayHlp:setText("* D๊ duplo clique no campo ou pergunta escolhido(a) para compor o indice do campo (" + Alltrim(oCampos:aCols[oCampos:nAt, nTitulo]) + ")") } 
oTreeTab:BLDblClick := {|| FS_ATRBCPO(oTreeTab:GetCargo(),@cIndRet) }
oTreeTab:Align := CONTROL_ALIGN_ALLCLIENT

//DEFINE SBUTTON FROM 150,45 TYPE 1 ACTION ( { || .T.,oDlgIND:End() }) ENABLE OF oDlgIND
//DEFINE SBUTTON FROM 150,75 TYPE 2 ACTION ( { || cIndRet := cDadOri ,oDlgIND:End()}) ENABLE OF oDlgIND

DEFINE SBUTTON FROM 150,45 TYPE 1 ACTION {|| nOpcI := 1, FS_ATRBCPO("",@cIndRet), IIf(!Empty(cIndRet), oDlgIND:End(), nIL)} ENABLE OF oDlgIND//Ok
DEFINE SBUTTON FROM 150,75 TYPE 2 ACTION {|| nOpcI := 2, oDlgIND:End()} ENABLE OF oDlgIND	//Cancelar

ACTIVATE MSDIALOG oDlgIND CENTERED //VALID IIf(Empty(Alltrim(cTexto)).OR. !ValidText(cTexto),.F.,.T.)

If nOpcI == 2 
	cIndRet := cDadOri
EndIf

RestArea(aArea)
Return(cIndRet) 
/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ@ฟ
//ณAtribui dado do campo selecionado ao campo do indiceณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ@ู
*/
Static Function FS_ATRBCPO(cCargo, cStrFinal,lWiz)
Local cConcat 	:= ""
Local cAlCon	:= ""
Local cDado 	:= ""
Local nI 
Default lWiz := .F.
If "*PRG*" $ cCargo .OR. "*CPO*" $ cCargo      
	cConcat := Substr(cCargo,1,At("|",cCargo)-1)
	If lWiz 
		If "*CPO*" $ cCargo
			cAlCon := Substr(Alltrim(cConcat),1,At("_",cConcat) - 1)
			If Len(cAlCon) == 2
				cAlCon := "S" + cAlCon
			EndIf 
			cConcat := cAlCon + "->" + cConcat	
		EndIf
		oCampos:aCols[oCampos:nAt, nDado] := cConcat
		Return()
	Else
		cAlCon := Substr(Alltrim(cConcat),1,At("_",cConcat) - 1)
		If Len(cAlCon) == 2
			cAlCon := "S" + cAlCon
		EndIf 
		cConcat := cAlCon + "->" + cConcat
	EndIf
	
	cDado := Alltrim(oCampos:aCols[oCampos:nAt, nDado])
	If Empty(cDado)
		oCampos:aCols[oCampos:nAt, nDado] := "(" + cConcat + ")"
	ElseIf At("(",cDado) > 0 .AND. At(")",cDado) > 0
		oCampos:aCols[oCampos:nAt, nDado] := SubStr(cDado,1, Len(cDado)-1) + "+" + cConcat + ")"
	Else
		oCampos:aCols[oCampos:nAt, nDado] := "(" + cDado + "+" + cConcat + ")"
	EndIf                                               
EndIf
/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta String Final de retorno da fun็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
cStrFinal := ""
For nI := 1 To Len(oCampos:aCols)
	If nI == Len(oCampos:aCols)
		cStrFinal += Alltrim(oCampos:aCols[nI, nDado])
	Else                                     
		cStrFinal += Alltrim(oCampos:aCols[nI, nDado]) + "+"
	EndIf
Next nI
If Substr(cStrFinal,Len(cStrFinal),1) == "+"
	cStrFinal := Substr(cStrFinal,1,Len(cStrFinal)-1)	
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldM63  บAutor  ณMicrosiga           บ Data ณ  04/11/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de Valida็๕es da Tela do Layout                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Saude                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldM63()
Local aArea   := GetArea()
Local lRet    := .T.
Local cCpoVld := ReadVar()   

If cCpoVld $ "M->GTS_ARQUIV"
	DbSelectArea("SX2")
	DbSetOrder(1)
	If !DbSeek(&(cCpoVld))
		HS_MsgInf("Tabela nใo encontrada", "Aten็ใo", "Valida็ใo Layout")
		lRet := .F.
	Else
		oGTS:aCols[oGTS:nAt, nGTSDesArq ] := X2Nome()
	EndIf 
	If aScan(oGTS:aCols, {| aVet | AllTrim(aVet[nGTSArquiv]) == &(cCpoVld)}) > 0   .AND. lRet
		HS_MsgInf("Registro duplicado!", "Aten็ใo", "Valida็ใo Layout")	
		lRet := .F.    
	EndIf
	If lRet
		cTabSix := &(cCpoVld)
	EndIf
ElseIf Alltrim(cCpoVld) == Upper("cAliasWiz")
	DbSelectArea("SX2")
	DbSetOrder(1)
	If !DbSeek(&(cCpoVld))
		HS_MsgInf("Tabela nใo encontrada", "Aten็ใo", "Valida็ใo Layout")
		lRet := .F.
	Else
		cDsTabWiz := X2Nome()	
		DbSelectArea("SX3")	
		DbSetOrder(1)		
		If DbSeek(cAliasWiz)
			aCpsInd := {}
			aCpsSel := {} 
			While !Eof() .AND. SX3->X3_ARQUIVO == cAliasWiz                		
				If "_FILIAL" $ SX3->X3_TITULO
					AADD(aCpsInd, {SX3->X3_CAMPO,"0",PADR("(xFilial('" + cAliasWiz + "'))",100), SX3->X3_TITULO, SX3->X3_DESCRIC, SX3->X3_TIPO, SX3->X3_TAMANHO,.F.})		
				Else
					AADD(aCpsInd, {SX3->X3_CAMPO,"0",SPACE(100), SX3->X3_TITULO, SX3->X3_DESCRIC, SX3->X3_TIPO, SX3->X3_TAMANHO,.F.})
				EndIf
				AADD(aCpsSel, {"LBNO",SX3->X3_CAMPO,SX3->X3_TITULO, SX3->X3_DESCRIC, SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_CONTEXT,SPACE(Len(RetSqlName(cAliasWiz))),SPACE(Len(SX3->X3_CAMPO)),SPACE(100),.F.})				
				DbSkip()
			EndDo
			oCampos:SetArray(aCpsInd) 
			oCampos:Refresh()			
			oCampSel:SetArray(aCpsSel) 
			oCampSel:Refresh()
			If lRet
				cTabSix := cAliasWiz
			EndIf								
		EndIf //  
	EndIf 
ElseIf Alltrim(cCpoVld) $ "M->HSPTABREL"  
	DbSelectArea("SX2")
	DbSetOrder(1)
	If !DbSeek(&(cCpoVld))
		HS_MsgInf("Tabela nใo encontrada", "Aten็ใo", "Valida็ใo Layout")
		lRet := .F.
	Else 
		If &(cCpoVld) == cAliasWiz
			HS_MsgInf("Tabela nใo pode ser igual a de origem", "Aten็ใo", "Valida็ใo Layout")
			lRet := .F.		
		Else
			lRet := .T.
			cSx3CodTab := Alltrim(&(cCpoVld))
		EndIf
	EndIf
ElseIf Alltrim(cCpoVld) $ "M->HSPCMPREL"	
	If Empty(cSx3CodTab)
		HS_MsgInf("Selecione a tabela!", "Aten็ใo", "Valida็ใo Layout")
		Return(.F.)
	EndIf		
	DbSelectArea("SX3")	
	DbSetOrder(2)		
	If !DbSeek(&(cCpoVld))  
		HS_MsgInf("Campo nใo encontrado", "Aten็ใo", "Valida็ใo Layout")
		lRet := .F.	          	
	ElseIf !(cSx3CodTab $ &(cCpoVld))
		HS_MsgInf("Campo nใo faz parte da tabela selecionada!", "Aten็ใo", "Valida็ใo Layout")
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ObjCoordบAutor  ณ Saude             บ Data ณ  17/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abre janela de coordenadas para os objetos Box, Line e Rectบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Saude                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_ObjCoord(cTag, cTitulo, lPaleta)
Local cLinIni 	:= SPACE(4)
Local cColIni 	:= SPACE(4)
Local cLinFim 	:= SPACE(4)
Local cColFim 	:= SPACE(4)
Local cCfgCoord := ""
Local cDado1		:= ""
Local cDado2		:= ""
Local nLin		:= 0  
Local nColorRet	:= 0
/*Local cPixelX	:= ""
Local cPixelY	:= "" */

Default cTitulo := "Coordenadas" 
Default cTag	:= ""     
Default lPaleta := .F.

/*oPrint := TMSPrinter():New(cTitulo)
cPixelX := Alltrim(Str(oPrint:nLogPixelX()))
cPixelY := Alltrim(Str(oPrint:nLogPixelY()))
FreeObj(oPrint)	*/

If lPaleta	
	DEFINE MSDIALOG oDlgM FROM	62,100 TO 300,430 TITLE cTitulo PIXEL 
Else
	DEFINE MSDIALOG oDlgM FROM	62,100 TO 180,430 TITLE cTitulo PIXEL 
EndIf

	@ 010, 010 SAY oSay PROMPT "Lin. inicial(px)"	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_HBLUE 
	@ 010, 050 SAY oSay PROMPT "Col. inicial(px)"	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_HBLUE 
	@ 010, 090 SAY oSay PROMPT "Lin. final(px)"	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_HBLUE 	
	@ 010, 130 SAY oSay PROMPT "Col. final(px)"	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_HBLUE 	

	@ 020, 010 MsGet oVlr1 VAR cLinIni Size 30, 009  PICTURE "9999" OF oDlgM Pixel COLOR CLR_BLACK	
	@ 020, 050 MsGet oVlr2 VAR cColIni Size 30, 009  PICTURE "9999" OF oDlgM Pixel COLOR CLR_BLACK	
	@ 020, 090 MsGet oVlr3 VAR cLinFim Size 30, 009  PICTURE "9999" OF oDlgM Pixel COLOR CLR_BLACK	
	@ 020, 130 MsGet oVlr4 VAR cColFim Size 30, 009  PICTURE "9999" OF oDlgM Pixel COLOR CLR_BLACK				

/*	@ 035, 010 SAY oSay PROMPT "Resolu็ใo Vertical Pixels: " + cPixelX	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_HBLUE 	
	@ 035, 080 SAY oSay PROMPT "Resolu็ใo Horizontal Pixels: " + cPixelY	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_HBLUE 	 */	

	If lPaleta	  
		oTColorTriangle2 := tColorTriangle():New(38,008,oDlgM,155,60)
		oTColorTriangle2:SetColorIni( 0 ) 
	EndIf
	nLin := IIf(lPaleta, 104,40)
	DEFINE SBUTTON FROM nLin,73 TYPE 1 ACTION {|| 	nOpcM := 1, IIf(lPaleta,nColorRet := oTColorTriangle2:RetColor(),nColorRet := 0),;
											 		IIf(!Empty(cLinIni) .AND. !Empty(cColIni) .AND.  !Empty(cLinFim) .AND.  !Empty(cColFim), oDlgM:End(), Nil)} ENABLE OF oDlgM 
//	DEFINE SBUTTON FROM nLin,85 TYPE 2 ACTION ( { ||  nOpcM := 2, oDlgM:End()}) ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED 
                 
If !Empty(cLinIni) .AND. !Empty(cColIni) .AND.  !Empty(cLinFim) .AND.  !Empty(cColFim) .AND. nOpcM == 1 	
	cCfgCoord := cTag + IIf(lPaleta, " {","")
	cCfgCoord += " {" + Alltrim(cLinIni) + "," + Alltrim(cColIni) + "," +  Alltrim(cLinFim) + "," + Alltrim(cColFim)
	cCfgCoord += IIf (lPaleta ,"},'" + Alltrim(Str(nColorRet))  + "'}", "}")

	cDado1 := Substr(M->GTQ_FUNCAO, 1, oGTQCodigo:nPos) 
	cDado2 := Substr(M->GTQ_FUNCAO, oGTQCodigo:nPos, Len(M->GTQ_FUNCAO))	
	//oGTQCodigo:AppendText( Chr(10) + cCfgCoord + Chr(10))	
	M->GTQ_FUNCAO := ""//    
	oGTQCodigo:refresh()
	oGTQCodigo:nPos := 1
	oGTQCodigo:AppendText( cDado1 + Chr(10) + cCfgCoord + Chr(10) + cDado2 )	
			
EndIf

Return()    



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ObjCoordบAutor  ณ Saude             บ Data ณ  17/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abre janela de configura็ใo para exibi็ใo de imagens       บฑฑ
ฑฑบ          ณ e grafico no relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Saude                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_PrtImg(cTag, cTitulo, lGraphic)
Local cColIni 	:= SPACE(4)
Local cWidth 	:= SPACE(4)
Local cHeight 	:= SPACE(4)
Local cCfgImg 	:= ""    

Private aItems5  := {"Vermelho","Verde","Azul","Amarelo"}
Private nCombo5  := 0
Private cCombo5  := 0
Private lSelectArq 	:= .T.
Private cDadoImg	:= IIf(lGraphic, SPACE(TamSx3("GTA_CODIND")[1]), SPACE(100))

Default cTitulo := "Imagem" 
Default cTag	:= ""     
Default lGraphic := .F.

	DEFINE MSDIALOG oDlgM FROM	62,100 TO 220,350 TITLE cTitulo PIXEL 

	@ 008, 010 SAY oSay PROMPT "Col. inicial(px)"	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_HBLUE 
	@ 008, 050 SAY oSay PROMPT "Largura(px)"	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_BLACK 	
	@ 008, 090 SAY oSay PROMPT "Altura(px)"	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_BLACK 	

	@ 018, 010 MsGet oVlr2 VAR cColIni Size 30, 009  PICTURE "9999" OF oDlgM Pixel COLOR CLR_BLACK	
	@ 018, 050 MsGet oVlr3 VAR cWidth Size 30, 009  PICTURE "9999" OF oDlgM Pixel COLOR CLR_BLACK	
	@ 018, 090 MsGet oVlr4 VAR cHeight Size 30, 009  PICTURE "9999" OF oDlgM Pixel COLOR CLR_BLACK				

	If lGraphic	  
		@ 030, 010 SAY oSay PROMPT "C๓d. Indicador:"	SIZE 50,009 OF oDlgM PIXEL COLOR CLR_HBLUE 	
		@ 040, 010 MsGet oVlr1 VAR cDadoImg Size 40, 009  VALID FS_VPRTIMG(cDadoImg,lGraphic) F3 "GTA" OF oDlgM Pixel COLOR CLR_BLACK			
		
		@ 030, 055 Say OemToAnsi("Cor:") Size 100, 009 OF oDlgM PIXEL COLOR CLR_BLACK  
		oCombo5 := tComboBox():New(040,055,{|u|if(PCount()>0,nCombo5:=PCount(),nCombo5 := 0)},aItems5,065,20,oDlgM,,,,,,.T.,,,,,,,,,"cCombo5")				
	Else
		@ 030, 010 SAY oSay PROMPT "Imagem:" SIZE 50,009 OF oDlgM PIXEL COLOR CLR_HBLUE 	
		@ 040, 010 MsGet oVlr1 VAR cDadoImg Size 108, 009  VALID FS_VPRTIMG(cDadoImg,lGraphic) F3 "HSSDIR" OF oDlgM Pixel COLOR CLR_BLACK				
	EndIf

	DEFINE SBUTTON FROM 58,50 TYPE 1 ACTION {|| 	nOpcM := 1,;
											 		IIf(!Empty(cColIni) .AND. !Empty(cDadoImg), oDlgM:End(), Nil)} ENABLE OF oDlgM 

ACTIVATE MSDIALOG oDlgM CENTERED 
                 
If !Empty(cColIni) .AND. !Empty(cDadoImg) .AND. nOpcM == 1 	
	If lGraphic
		cDadoImg := HS_IMGGRPH(cDadoImg ,nCombo5) //"\" + cDadoImg + "GrafGTA.bmp" //HS_IMGGRPH(cDadoImg)
	EndIf
	If Empty(cWidth) .OR. Empty(cHeight) // Se os dados de largura ou altura nao forem preenchidos pega o tamanho original
		FS_GETTAMI(cDadoImg, @cWidth,@cHeight)
	EndIf
	cCfgImg += cTag + " {" + Alltrim(cColIni) + ",'" + Alltrim(cDadoImg) + "'," +  Alltrim(cWidth) + "," + Alltrim(cHeight) + ",Nil,Nil}"	
	cDado1 := Substr(M->GTQ_FUNCAO, 1, oGTQCodigo:nPos) 
	cDado2 := Substr(M->GTQ_FUNCAO, oGTQCodigo:nPos, Len(M->GTQ_FUNCAO))	
	//oGTQCodigo:AppendText( Chr(10) + cCfgImg + Chr(10))	
	M->GTQ_FUNCAO := ""//    
	oGTQCodigo:refresh()
	oGTQCodigo:nPos := 1
	oGTQCodigo:AppendText( cDado1 + Chr(10) + cCfgImg + Chr(10) + cDado2 )	
			
EndIf

Return()  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValid do campo Imagem e Codigo do indicadorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function FS_VPRTIMG(cData,lGraph)
Local aArea := GetArea()
Local lRet := .F.

If lGraph
	DbSelectArea("GTA")
	DbSetOrder(1)
	If DbSeek(xFilial("GTA") + cData)
		If Alltrim(GTA->GTA_TIPOIN) $ "23"
			lRet := .T.
		Else
			HS_MsgInf("Sใo permitidos apenas graficos do tipo Pizza e Barra!","Aten็ใo","Valida็ใo Layout")
			lRet := .F.			
		EndIf
	Else
		lRet := .F.
	EndIf
Else 
	lRet := File(cData)
EndIf                   
RestArea(aArea)
Return(lRet)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GETTAMIบAutor  ณ SAUDE              บ Data ณ  17/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ FUNวรO PARA PEGAR O TAMANHO PADRAO DA IMAGEM               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GETTAMI(cImg, cWid, cHei) 
Local oImg 
//Temporario - somente par aobter tamanho da imagem     
DEFINE MSDIALOG oPanTemp TITLE "Temp" FROM 0,0 TO 1000,1000 PIXEL //"Aproveitamento de pagina"
@ 012,012 BITMAP oImg RESNAME cImg PIXEL NOBORDER OF oPanTemp 
oImg:Load( , cImg  )
oImg:lAutosize := .T.
cWid := Alltrim(Str(oImg:nClientWidth))
cHei := Alltrim(Str(oImg:nClientHeight))
FreeObj(oPanTemp)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_IMGGRPHบAutor  ณSaude              บ Data ณ  04/18/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava e retorna imagem de grafico da rotina de indicadores บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_IMGGRPH(cCodInd, nCor)
Local aArea 	:= getArea()
Local cPathRet 	:= "" 
Local aPnl1		:= {} 
Local oGraphEsq  
Local oDlgTmp
Local nI, nRecP1:= 0

//  DEFINIวรO DAS CORES DO PAINEL
nUniCor1 	:= IIf(nCor == 1, CLR_RED,IIf(nCor == 2, CLR_GREEN,IIf(nCor == 3, CLR_HBLUE,CLR_YELLOW)))
nMais1  	:= IIf(nCor == 1, 50,IIf(nCor == 2, 60,IIf(nCor == 3, 0,0)))		
nMenos1 	:= IIf(nCor == 1, 0,IIf(nCor == 2, 0,IIf(nCor == 3, 65,40)))					
	
If !Empty(cCodInd)
	DbSelectArea("GTA")
	DbSetOrder(1)
	If DbSeek(xFilial("GTA")  + cCodInd) .AND. Alltrim(GTA->GTA_TIPOIN) $ "23"
		nRecP1 := GTA->(Recno())
		aPnl1 := HSPPO020(nRecP1, .F.)
		If aPnl1 <> Nil .AND. Len(aPnl1) > 0  		

			//Temporario - somente par obter a imagem do grafico
			DEFINE MSDIALOG oDlgTmp TITLE "Temp" FROM 180,180 TO 580,700 PIXEL  //"Aproveitamento de pagina"			
			
			oGraphEsq := TMSGraphic():New( 01,01,oDlgTmp,,,,260,184)
			oGraphEsq:SetTitle(Alltrim(GTA->GTA_TITULO),"", CLR_BLACK, A_LEFTJUST, GRP_TITLE  )
			oGraphEsq:SetMargins(2,6,6,6)
			oGraphEsq:SetLegenProp(GRP_SCRRIGHT, CLR_LIGHTGRAY, GRP_AUTO,.T.)

			// Itens do Grแfico   //oGraphic:DelSerie(nSerie)
			nSerie1 := oGraphEsq:CreateSerie( aPnl1[1] )						
			For nI := 1 to Len(aPnl1[3,1])
				oGraphEsq:Add(nSerie1, aPnl1[5,1,nI], Substr(Alltrim(aPnl1[3,1,nI]),1,12), nUniCor1 )
				If GTA->GTA_TIPOIN == "2"
					nUniCor1 += nMais1
					nUniCor1 -= nMenos1		 
				EndIf		
			Next         
			oGraphEsq:SaveToBMP(cCodInd + "GrafGtaAux.bmp","\")
			oGraphEsq:SaveToImage( cCodInd + "GrafGTA.bmp","\","bmp" )
			cPathRet := "\" + cCodInd + "GrafGTA.bmp"  
			FErase("\" + cCodInd + "GrafGtaAux.bmp")
			
			FreeObj(oGraphEsq)			
			FreeObj(oDlgTmp)				
		EndIf
	EndIf
EndIf 

RestArea(aArea)
Return(cPathRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RETCPO บAutor  ณSaude           บ Data ณ  04/18/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ atribui o campo ao Memo principal ap๓s selecionar na lista บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_RETCPO(oObjMem, cVar, lTag, cVarObj, lObjPri)
Local cDado 		:= FS_M63RCPO(lTag)            
Default cVar 		:= ""
Default oObjMem		:= Nil
Default lObjPri		:= .T.

If !Empty(cDado)   
	If oObjMem <> Nil
				
		cDado1 := Substr(IIf(!lObjPri, cVarObj,M->GTQ_FUNCAO), 1, oObjMem:nPos) 
		cDado2 := Substr(IIf(!lObjPri , cVarObj,M->GTQ_FUNCAO), oObjMem:nPos, Len(M->GTQ_FUNCAO))	
		//oObjMem:AppendText( " " + cDado )
		If 	Empty(cVarObj) .AND. lObjPri
			M->GTQ_FUNCAO := ""//
		Else
			cVarObj := ""
		EndIf
		oObjMem:refresh()
		oObjMem:nPos := 1
		oObjMem:AppendText( cDado1 + " " + cDado + " " + cDado2 )		
			
	EndIf
	If Empty(cVar)
		cVar := cDado
	Else
		cVar += cDado	
	EndIf	
EndIf
Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_M63RCPOบAutor  ณSaude           บ Data ณ  04/18/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna campo selecionado da lista disponivel              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    
Static Function FS_M63RCPO(lTag)
Local aArea 	:= getArea()
Local cDado		:= ""       
Local cCargo	:= ""
Local cPerg 	:= M->GTQ_CODPER  
Local nI		:= 0 
Local cTamCpo   := SPACE(3)
Local nOpcI		:= 0

If Empty(cPerg) .AND. Len(oGTS:aCols) == 1
	If Empty(oGTS:aCols[1,nGTSArquiv])
		HS_MSGINF("Nใo existem tabelas/pergunta configuradas!","Aten็ใo","Valida็ใo Layout")
		Return("")
	EndIf
EndIf

DEFINE MSDIALOG oDlgCpo FROM 62,100 TO 380,450 TITLE "Campo/Pergunta" PIXEL 

Define  FONT oFont NAME "Arial,12," BOLD  
//@ 006,010 TO PROMPT "Selecione o dado:" SIZE 200,009 OF oDlgCpo PIXEL COLOR CLR_HBLUE FONT oFont//"="
@ 006, 006 TO 142, 170 Label "Selecione o dado:" OF oDlgCpo PIXEL //COLOR CLR_HBLUE FONT oFont
//================================================================ฟ
//ณ Folder de vinculo do dado					                 ณ
//================================================================ู 	                                           
//@ 005, 168 FOLDER oFolVin SIZE 170, 158  OF oDlgCpo PIXEL PROMPTS "Campos / Perguntas" //@ 165,030 SAY oSayHlp PROMPT "* Posicione no campo para atribuir o dado do indice (os dois primeiros campos sใo de preenchimento obrigat๓rio)"	SIZE 500,009 OF oDlgCpo PIXEL COLOR CLR_HRED //FONT oFont//"="

DEFINE DBTREE oTreeTab FROM 015, 011 TO 137, 167 CARGO OF oDlgCpo Pixel

If Len(oGTS:aCols) > 0 .AND. !Empty(oGTS:aCols[1,nGTSArquiv])
	DBADDTREE oTreeTab PROMPT PADR("Tabelas",50) RESOURCE "BMPGROUP" CARGO PADR("Tabelas",100)
	For nI := 1 to Len(oGTS:aCols)
		
		DBADDTREE oTreeTab PROMPT PADR(oGTS:aCols[nI,nGTSArquiv] + " -> " + oGTS:aCols[nI,nGTSDesArq],70) RESOURCE "PRODUTO" CARGO PADR("Cab|" + oGTS:aCols[nI,nGTSArquiv],100)
		DbSelectArea("SX3")
		DbGoTop()
		DbSetOrder(1)
		If DbSeek(Alltrim(oGTS:aCols[nI,nGTSArquiv]))
			While !Eof() .AND. SX3->X3_ARQUIVO == oGTS:aCols[nI,nGTSArquiv]
				DBADDITEM oTreeTab PROMPT PADR(SX3->X3_CAMPO + " - " + Alltrim(SX3->X3_TITULO) + " (" + Alltrim(SX3->X3_TIPO) + "," + Alltrim(Str(SX3->X3_TAMANHO)) + ")",70)   RESOURCE "BR_WHITE" CARGO PADR(Alltrim(SX3->X3_CAMPO) + "|" + Alltrim(SX3->X3_TITULO) + "(" + Alltrim(SX3->X3_TIPO) + "," + Alltrim(Str(SX3->X3_TAMANHO)) + ")*CPO*",100)
				DbSkip()
			EndDo
		EndIf
		DBENDTREE oTreeTab
		
	Next nI
	DBENDTREE oTreeTab 
EndIf

//oTreeTab:bGotFocus := {|| cCargo := oTreeTab:GetCargo(),IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), cTamCpo := StrZero(Substr(oTreeTab:GetCargo(),At(",",oTreeTab:GetCargo())+1,  At(")",oTreeTab:GetCargo())-1),3),Nil)   } 
oTreeTab:bChange   := {|| cCargo := oTreeTab:GetCargo(),IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), cTamCpo := StrZero(Val(Substr(oTreeTab:GetCargo(),At(",",oTreeTab:GetCargo())+1,  At(")",oTreeTab:GetCargo())-1)),3),Nil), oTam:Refresh()   } 
oTreeTab:BLDblClick := {|| IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), cDado := FS_RETDADO(oTreeTab:GetCargo(), cTamCpo, lTag), Nil), IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), oDlgCpo:End(), Nil)  }


@ 145, 008 SAY oSay PROMPT "Tam.:" SIZE 50,009 OF oDlgCpo PIXEL COLOR CLR_HBLUE 	
@ 145, 024 MsGet oTam VAR cTamCpo Size 30, 009  PICTURE "999" WHEN lTag VALID !Empty(cTamCpo) OF oDlgCpo Pixel COLOR CLR_BLACK	

DEFINE SBUTTON FROM 145,95 TYPE 1 ACTION {|| nOpcI := 1, IIf("*PRG*" $ oTreeTab:GetCargo() .OR. "*CPO*" $ oTreeTab:GetCargo(), oDlgCpo:End(), nIL)} ENABLE OF oDlgCpo//Ok

ACTIVATE MSDIALOG oDlgCpo CENTERED 

If nOpcI == 1 
	cDado := FS_RETDADO(cCargo, cTamCpo,lTag)
EndIf
RestArea(aArea)
Return(cDado)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRetorna o dado do campo formatadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function FS_RETDADO(cCargo, cTam, lTag)
Local cData := "" 
Local cType := ""
Local cAlias:= ""

If "*PRG*" $ cCargo .OR. "*CPO*" $ cCargo
	cData := Substr(cCargo,1,At("|",cCargo)-1) 
	cType := Alltrim(Substr(cCargo  ,At("(",cCargo)+1,  At(",",cCargo)-1))
	If "*CPO*" $ cCargo
		cAlias := Substr(Alltrim(cData),1,At("_",cData) - 1)
		If Len(cAlias) == 2
			cAlias := "S" + cAlias
		EndIf 
		cData := cAlias + "->" + cData	
	EndIf
	If !(cType $ "CM")
		If cType == "N"
			cData := "Alltrim(Str(" + cData + "))"
		ElseIf cType == "D"
			cData := "DtoS(" + cData + ")"
		ElseIf cType == "L"
			Hs_MsgInf("Tipo de dado L๓gico, nใo ้ possivel atribui-lo!","Aten็ใo","Valida็ใo Layout")
			Return("")
		EndIf
	EndIf
	//cData := IIf(lTag,"#A" + StrZero(Val(cTam),3),"") + "  " + cData + " "//+ " PADR(" + cData + "," + cTam + ")"	
	cData := IIf(lTag,"#A" + StrZero(Len(cData),3),"") + "  " + cData + " "//+ " PADR(" + cData + "," + cTam + ")"		
EndIf   

//#A022  PADR(GCY->GCY_NOME,40)                                       
Return(cData)
 
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณWIZARD PARA CRIAวรO DOS DETALHESณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function FS_WIZDET(cPerg)
Local aArea	:= getArea()
Local oWizard, oPanel
Local nIdade := 0
Local nI, nCps := 0
Local aHeadCpo := {}
Local aHeadSel := {}  
Local lChkTit  := .F. 
Local cStrDetails := ""

Private cIndWiz := Space(2)
Private aCpsInd := {}
Private aCpsSel := {}
Private cAliasWiz := Space(3)
Private oCampos, oCampSel 
Private cDsTabWiz := ""
Private cSx3CodTab	:= "" 
Private cCpoSX3    	:= "M->HSPCMPREL"
Private cRetSX3		:= ""

DEFINE WIZARD oWizard TITLE "Wizard Detalhes" ;
       	HEADER "Wizard para cria็ใo dos detalhes no layout do relat๓rio " + Iif(!Empty(M->GTQ_DESCR), Alltrim(M->GTQ_DESCR),"") ;
       	MESSAGE "" ;
       	TEXT "Caso seja necessแrio relacionar com alguma tabela, ้ necessแrio defini-la anteriormente no grid de (tabelas)" ;
       	NEXT {||.T.} ;
       	FINISH {|| .T. } ;
		PANEL

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณETAPA SELEวรO DA TABELA E INDICE     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizard ;
          HEADER "Informe a tabela e o indice que serใo pesquisados e exibidos os dados" ;
          MESSAGE "" ;
          BACK {|| .T. } ;
          NEXT {|| (!Empty(cAliasWiz) .AND. !Empty(cIndWiz)) } ;
          FINISH {|| .F. } ;
          PANEL
	oPanel := oWizard:GetPanel(2)
	@ 15,15 SAY "Tabela" SIZE 45,8 PIXEL COLOR CLR_HBLUE OF oPanel
	@ 25,15 MSGET cAliasWiz PICTURE "@!" F3 "HSPSX2" VALID HS_VLDM63() SIZE 40,10 PIXEL COLOR CLR_HBLUE OF oPanel

	@ 40,15 SAY "Indice" SIZE 45,8 PIXEL COLOR CLR_HBLUE OF oPanel
	@ 50,15 MSGET cIndWiz F3 "HSP004" SIZE 40,10 PIXEL OF oPanel

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณETA RELACIONAMENTO DOS DADOS        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizard ;
          HEADER "Relacione campo com dado do tipo(campo/pergunte/valor manual)" ;
          MESSAGE "ษ necessแrio atribuir o dado para os dois primeiros campos do indice por questใo de performance" ;
          BACK {|| .T. } ;
          NEXT {|| ASCAN(oCampos:aCols,{|aVet | !Empty(Alltrim(aVet[3])) }) > 0 } ;
          FINISH {|| .F. } ;
          PANEL    
   	oPanel := oWizard:GetPanel(3)                 

   	@ 005,10 SAY "Campos" + IIf(!Empty(cDsTabWiz), " > " + Alltrim(cDsTabWiz),"") SIZE 100,8 PIXEL COLOR CLR_HBLUE OF oPanel

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHEADER GRID DE DOS CAMPOS DESTINO    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(aHeadCpo,{"Campo","HSPCAMPO","@!", Len(SX3->X3_CAMPO),0, ,,"C", ,"R",    ,,,"V",,,.T.})  
 	aAdd(aHeadCpo,{"Oper.", "HSPOPER", "@!", 1, 0, , , "C", , "R", "0=AND;1=OR",,,"A",,,.F.}) 
	aAdd(aHeadCpo,{"Dado","HSPDADO","", 100,0,,,"C",         ,"R",,,,"A",,"þA",.F.}) 
	aAdd(aHeadCpo,{"Titulo","HSPTITULO","",  Len(SX3->X3_TITULO),0, ,,"C",         ,"R",,,,"V",,,.T.}) 
	aAdd(aHeadCpo,{"Descri็ใo","HSPDESCRIC","@!",  Len(SX3->X3_DESCRIC),0, ,,"C",         ,"R",,,,"V",,,.T.})  
	aAdd(aHeadCpo,{"Tipo","HSPTIPO","@!",  Len(SX3->X3_TIPO),0, ,,"C",         ,"R",,,,"V",,,.T.}) 
	aAdd(aHeadCpo,{"Tamanho","HSPTAMANHO","",  3,0, ,,"C",         ,"R",,,,"V",,,.T.}) 
	
	oCampos := MsNewGetDados():New(13, 10, 133, 150,GD_UPDATE,,,,,,,,,, oPanel , aHeadCpo, aCpsInd)
	nCampo := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPCAMPO"})
	nDado := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPDADO"})
	nTitulo := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPTITULO"})	
	nOper := aScan(aHeadCpo, {| aVet | AllTrim(aVet[2]) == "HSPOPER"})		

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTREE DE  SELEวรO DOS CAMPOS RELAC.   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	@ 005,162 SAY "Relacionamento" SIZE 45,8 PIXEL COLOR CLR_HBLUE  OF oPanel
	DEFINE DBTREE oTreeTab FROM 13, 162 TO 133, 295 CARGO OF oPanel Pixel 

	DBADDTREE oTreeTab PROMPT PADR("Tabelas",50) RESOURCE "BMPGROUP" CARGO PADR("Tabelas",100)
	For nI := 1 to Len(oGTS:aCols)
		DBADDTREE oTreeTab PROMPT PADR(oGTS:aCols[nI,nGTSArquiv] + " -> " + oGTS:aCols[nI,nGTSDesArq],50) RESOURCE "PRODUTO" CARGO PADR("Cab|" + oGTS:aCols[nI,nGTSArquiv],100)
		DbSelectArea("SX3")
		DbGoTop()
		DbSetOrder(1)
		If DbSeek(Alltrim(oGTS:aCols[nI,nGTSArquiv]))
			While !Eof() .AND. SX3->X3_ARQUIVO == oGTS:aCols[nI,nGTSArquiv]
				DBADDITEM oTreeTab PROMPT PADR(SX3->X3_CAMPO + " - " + Alltrim(SX3->X3_TITULO) + " (" + Alltrim(SX3->X3_TIPO) + "," + Alltrim(Str(SX3->X3_TAMANHO)) + ")",50)   RESOURCE "BR_WHITE" CARGO PADR(Alltrim(SX3->X3_CAMPO) + "|" + Alltrim(SX3->X3_TITULO) + "|*CPO*",100)
				DbSkip()
			EndDo
		EndIf
		DBENDTREE oTreeTab

	Next nI
	DBENDTREE oTreeTab

	oTreeTab:BLDblClick := {|| FS_ATRBCPO(oTreeTab:GetCargo(),"",.T.) }		
	  
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณETAPA SELEวรO DOS CAMPOS             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CREATE PANEL oWizard ;
          HEADER "Selecione os campos/colunas que serใo exibidos no relat๓rio" ;
          MESSAGE "Marque o (Titulo Cab) para definir o titulo dos campos como cabe็alho do detalhes" ;
          BACK {|| .T. } ;
          NEXT {|| ASCAN(oCampSel:aCols,{|aVet | aVet[1] == "LBTIK" }) > 0 } ;
          FINISH {|| FS_STRWIZ(@cStrDetails,lChkTit) } ;
          PANEL
	oPanel := oWizard:GetPanel(4)
   
	@ 005,50 SAY "Campos" + IIf(!Empty(cDsTabWiz), " > " + Alltrim(cDsTabWiz),"") SIZE 100,8 PIXEL COLOR CLR_HBLUE OF oPanel
  	oChkTit := tCheckBox():New(005,200  ,"Titulo Cab", {|u|if( pcount()>0,lChkTit := u, lChkTit)}, oPanel,050,010,,{||},,,,,,.T.)     
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHEADER GRID DE SELEวรO DOS CAMPOS    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(aHeadSel,{"","HSPMARK","@BMP", 1,0,.F. ,,"C", ,"V", ,,,"V",,,.T.})  	
	aAdd(aHeadSel,{"Campo","HSPCAMPO","@!", Len(SX3->X3_CAMPO),0, ,,"C", ,"R",    ,,,"V",,,.T.})  
	aAdd(aHeadSel,{"Titulo","HSPTITULO","",  Len(SX3->X3_TITULO),0, ,,"C",         ,"R",,,,"V",,,.T.}) 
	aAdd(aHeadSel,{"Descri็ใo","HSPDESCRIC","@!",  Len(SX3->X3_DESCRIC),0, ,,"C",         ,"R",,,,"V",,,.T.})  
	aAdd(aHeadSel,{"Tipo","HSPTIPO","@!",  Len(SX3->X3_TIPO),0, ,,"C",         ,"R",,,,"V",,,.T.}) 
	aAdd(aHeadSel,{"Tamanho","HSPTAMANHO","999",  3,0, ,,"C",         ,"R",,,,"V",,,.T.})   
	aAdd(aHeadSel,{"Contexto","HSPCONTEXT","",  1,0, ,,"C",         ,"R",,,,"V",,,.F.})   	
	aAdd(aHeadSel,{"Tab.(Virtual)","HSPTABREL","@!", Len(RetSqlName(aArea[1])),0, "HS_VldM63()",,"C","HSPSX2" ,"R",,,,"A",,,.F.})  
	aAdd(aHeadSel,{"Campo(Virtual)","HSPCMPREL","@!", Len(SX3->X3_CAMPO),0, "HS_VldM63()" ,,"C","HSPSX3" ,"R",,,,"A",,,.F.})  		
	aAdd(aHeadSel,{"Relac.(Virtual)","HSPRELVIR","@!",  100,0, ,,"C",         ,"R",,,,"A",,,.F.})   	


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGRID DE SELEวรO DOS CAMPOS DO DETALHEณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oCampSel := MsNewGetDados():New(15, 50, 135, 250,GD_UPDATE,,,,,,,,,, oPanel , aHeadSel, aCpsSel)
	oCampSel:oBrowse:BlDblClick := {|| FS_DbCkSEL() }//{|| oCampSel:aCols[oCampSel:oBrowse:nAT,nMark] := IIf(oCampSel:aCols[oCampSel:oBrowse:nAT,nMark] == "LBNO", "LBTIK","LBNO"), oCampSel:oBrowse:Refresh() , IIf(oCampSel:aCols[oCampSel:oBrowse:nAT,nMark] == "LBTIK",FS_WIZAVIS(),Nil)  } 	
	nCampSel := aScan(aHeadSel, {| aVet | AllTrim(aVet[2]) == "HSPCAMPO"})
	nMark := aScan(aHeadSel, {| aVet | AllTrim(aVet[2]) == "HSPMARK"})
	nTitSel := aScan(aHeadSel, {| aVet | AllTrim(aVet[2]) == "HSPTITULO"})	 
	nContext := aScan(aHeadSel, {| aVet | AllTrim(aVet[2]) == "HSPCONTEXT"}) 
	nTamSel := aScan(aHeadSel, {| aVet | AllTrim(aVet[2]) == "HSPTAMANHO"}) 	
	nCpoVir := aScan(aHeadSel, {| aVet | AllTrim(aVet[2]) == "HSPCMPREL"}) 		
	nTabVir := aScan(aHeadSel, {| aVet | AllTrim(aVet[2]) == "HSPTABREL"}) 			
	nRelVir := aScan(aHeadSel, {| aVet | AllTrim(aVet[2]) == "HSPRELVIR"}) 				
	
ACTIVATE WIZARD oWizard CENTERED

If !Empty(cStrDetails)
	//oGTQCodigo:AppendText( Chr(10) + cStrDetails )
	
	cDado1 := Substr(M->GTQ_FUNCAO, 1, oGTQCodigo:nPos) 
	cDado2 := Substr(M->GTQ_FUNCAO, oGTQCodigo:nPos, Len(M->GTQ_FUNCAO))	
	//oGTQCodigo:AppendText( Chr(10) + cCfgCoord + Chr(10))	
	M->GTQ_FUNCAO := ""//    
	oGTQCodigo:refresh()
	oGTQCodigo:nPos := 1
	oGTQCodigo:AppendText( cDado1 + Chr(10) + cStrDetails + cDado2 )	
	
EndIf
RestArea(aArea)
Return           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DbCkSEL บAutor  ณSaude          z    บ Data ณ 20/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DbCkSEL()
If oCampSel:oBrowse:nColPos == nMark
	oCampSel:aCols[oCampSel:oBrowse:nAT,nMark] := IIf(oCampSel:aCols[oCampSel:oBrowse:nAT,nMark] == "LBNO", "LBTIK","LBNO")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMensagem de aviso para campos virtuaisณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If oCampSel:aCols[oCampSel:oBrowse:nAT,nMark] == "LBTIK" .AND. oCampSel:aCols[oCampSel:oBrowse:nAT,nContext]  == "V"
		HS_MSGINF("O Campo selecionado ้ de contexto Virtual. " +Chr(10)+Chr(10)+;
				" Preencha os campos Tab. (Virutal), Campo(Virtual) e Relac.(Virtual) "+Chr(10)+"Exemplo: " +Chr(10)+;
				 " " + cAliasWiz + "_CODIGO = XXX_CODIGO " + Chr(10)+ "Onde XXX ้ a tabela relacionada.","Aten็ใo","Aviso Detalhes")
	EndIf  
Else	
	oCampSel:EDITCELL( oCampSel:OBROWSE, oCampSel:oBrowse:nAt, oCampSel:oBrowse:nColPos )
EndIf
oCampSel:oBrowse:Refresh()
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_STRWIZ  บAutor  ณSaude          z    บ Data ณ 20/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta a string de retorno completa do Wizard               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                     
//#A300  HS_ItensF("GD7",3, "GD7.GD7_NRSEQG = '000694'",{{"GD7_CODDES", "", "", "", "", 15}, {"GD7_DDESPE","","GA7", "GA7_DESC", "GD7.GD7_CODDES = GA7.GA7_CODPRO", 49}},25)
Static Function FS_STRWIZ(cStrRet,lCabTit)
Local lRet 		:= ASCAN(oCampSel:aCols,{|aVet | aVet[1] == "LBTIK" }) > 0  
Local cStr1		:= "" // Fun็ใo
Local cStr2		:= "" // Relacionamentos
Local cStr3		:= "" // Campos Cab
Local cStr4		:= "" // Campos Det
Local cVirg		:= ""
Local nSumTam	:= 0               
Local nI		:= 0

cStr1 := ' HS_ItensF("' +cAliasWiz+'",' + cIndWiz + ', '
aCpsInd := aClone(oCampos:aCols)
aCpsSel := aClone(oCampSel:aCols)
If !lRet
	Return(.F.)
EndIf

For nI := 1 to Len(aCpsInd)
	If !Empty(aCpsInd[nI, nDado] )
		If Empty(cStr2)
			cStr2 += '"' +cAliasWiz+"."+ aCpsInd[nI, nCampo] + " = "+"'"+'"'+"+"+ Alltrim(aCpsInd[nI, nDado])+"+"+'"'+"'"
		Else
			cStr2 += IIf(aCpsInd[nI, nOper] == "0", " AND ", " OR " ) +cAliasWiz+"."+ aCpsInd[nI, nCampo] + " = "+"'"+'"'+"+"+ Alltrim(aCpsInd[nI, nDado]) + "+"+'"'+"'"+'"'
		EndIf  
	EndIf
Next nI      

For nI := 1 to Len(aCpsSel)
	If aCpsSel[nI, nMark] == "LBTIK" 
		If lCabTit
			cStr3 += PADR(Alltrim(aCpsSel[nI, nTitSel]),aCpsSel[nI, nTamSel])                    
		EndIf
		cVirg := IIf(!Empty(cStr4), ",","")
		cStr4 += IIf(Empty(cStr4), "{","")
		nSumTam += aCpsSel[nI, nTamSel]
		If aCpsSel[nI, nContext] == "V"
			cStr4 += cVirg + '{"' + aCpsSel[nI, nCampSel] + '","","' + Alltrim(aCpsSel[nI, nTabVir]) + '","' + Alltrim(aCpsSel[nI, nCpoVir]) + '","' + Alltrim(aCpsSel[nI, nRelVir]) + '",' + Alltrim(Str(aCpsSel[nI, nTamSel])) + '}'		
		Else
			cStr4 += cVirg + '{"' + aCpsSel[nI, nCampSel] + '","","","","",' + Alltrim(Str(aCpsSel[nI, nTamSel])) + '}'
		EndIf
	EndIf
Next nI
cStr4 += "}," + StrZero(nSumTam,3) + ")" 

If lCabTit   
	cStrRet := cStr3 + Chr(10)
	cStrRet += "#A" + StrZero(Len(cStr1 + cStr2  + cStr4),3) + " " + cStr1 + cStr2 + "," + cStr4
Else
	cStrRet := "#A" + StrZero(Len(cStr1 + cStr2  + cStr4),3) + " " + cStr1 + cStr2 + "," + cStr4
EndIf
Return lRet 


/*
+------------------------------------------------------------------+
| Parametros do MSBAR                                              |
+------------------------------------------------------------------+
| 01 cTypeBar String com o tipo do codigo de barras                |
|    "EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"                    |
|    "INT25","MAT25,"IND25","CODABAR","CODE3_9"                    |
| 02 nRow           Numero da Linha em centimentros                |
| 03 nCol           Numero da coluna em centimentros               |
| 04 cCode          String com o conteudo do codigo                |
| 05 oPr            Objeto Printer                                 |
| 06 lcheck        Se calcula o digito de controle                 |
| 07 Cor            Numero da Cor, utilize a "common.ch"           |
| 08 lHort          Se imprime na Horizontal                       |
| 09 nWidth        Numero do Tamanho da barra em centimetros       |
| 10 nHeigth        Numero da Altura da barra em milimetros        |
| 11 lBanner        Se imprime o linha em baixo do codigo          |
| 12 cFont          String com o tipo de fonte                     |
| 13 cMode          String com o modo do codigo de barras CODE128  |
+------------------------------------------------------------------+
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_CBAGRV บ Autor ณ Saude              บ Data ณ Junho/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava as alteracoes do posicionamento e configuracoes do   บฑฑ
ฑฑบ          ณ codigo de barras                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CODBAR()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao das variaveis locais                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nOpca3 	:= 0
Local aArea  	:= GetArea()
Local cPosVert	:= 0
Local cPosHoriz	:= 0

Local cTamVert  := 0
Local cTamHoriz := 0
Local cPosicao  := "H"
Local cDigito   := "N"
Local cDadCB	:= Space(100)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao das variaveis privadas                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aItems5  := {"CODE128","EAN13","EAN8","UPCA","SUP5","INT25","MAT25","IND25","CODABAR","CODE3_9"}
Private cCombo5  := 0
Private nPosicao := 2
Private nDigito  := 2
Private cFieldOk  := "AllwaysTrue()"

DEFINE MSDIALOG oDlgCBar TITLE "C๓digo de barra" FROM 000,000 TO 300,415 OF oMainWnd PIXEL //"C๓digo de barra"

	@ 015, 003 Say OemToAnsi("Configuracoes do posicionamento") Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_RED   // "Configuracoes do posicionamento"
	@ 025, 003 Say OemToAnsi("Centimetros na vertical") Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   // "Centimetros na vertical"
	@ 034, 003 MSGet oEditVertical var cPosVert Size 100, 009 OF oDlgCBar Picture "99.999" PIXEL COLOR CLR_BLACK Valid &cFieldOk
	@ 025, 105 Say OemToAnsi("Centimetros na horizontal") Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   // "Centimetros na horizontal"
	@ 034, 105 MSGet oEditHorizontal var cPosHoriz Size 100, 009 OF oDlgCBar Picture "99.999" PIXEL COLOR CLR_BLACK Valid &cFieldOk
	
	@ 048, 003 Say OemToAnsi("Configuracoes do tamanho") Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_RED   // "Configuracoes do tamanho"
	@ 058, 003 Say OemToAnsi("Altura da barra(cm)") Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   
	@ 067, 003 MSGet oEditVertical var cTamVert Size 100, 009 OF oDlgCBar Picture "99.999" PIXEL COLOR CLR_BLACK Valid &cFieldOk
	@ 058, 105 Say OemToAnsi("Espa็amento das barras") Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE  
	@ 067, 105 MSGet oEditHorizontal var cTamHoriz Size 100, 009 OF oDlgCBar Picture "99.999" PIXEL COLOR CLR_BLACK Valid &cFieldOk

	@ 091, 003 Say OemToAnsi("Tipo do c๓digo de barra") Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   // "Tipo do c๓digo de barra"
	oCombo5 := tComboBox():New(100,003,{|u|if(PCount()>0,cCombo5:=u,cCombo5)},aItems5,100,20,oDlgCBar,,,,,,.T.,,,,,,,,,"cCombo5")

	@ 091, 105 Say OemToAnsi("C๓digo/conte๚do") Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   
	@ 100, 105 MSGet oCodBar var cDadCB Size 88, 009 OF oDlgCBar PIXEL COLOR CLR_BLACK Valid &cFieldOk
	oBtF3Cpo  := tButton():New(100, 195, "?", oDlgCBar, {|| FS_RETCPO(,@cDadCB,.F.),oCodBar:Refresh() }, 010, 010,,,, .T.)    	
	
	@ 125, 003 RADIO oVisual VAR nPosicao PROMPT OemToAnsi("Imprime na vertical"),OemToAnsi("Imprime na horizontal") SIZE  100,9 OF oDlgCBar PIXEL ;  // "Imprime na vertical" ### "Imprime na horizontal"
	ON CHANGE (cPosicao := Iif(nPosicao==1,"V","H"))
	If cPosicao == "V"
		nPosicao := 1
	Else
		nPosicao := 2
	EndIf
	
	@ 125, 105 RADIO oDigito VAR nDigito PROMPT OemToAnsi("Calcula dํgito"),OemToAnsi("Nใo calcula dํgito") SIZE  100,9 OF oDlgCBar PIXEL ;  // "Calcula dํgito" ### "Nใo calcula dํgito"
	ON CHANGE (cDigito := Iif(nDigito==1,"S","N"))
	If cDigito == "S"
		nDigito := 1
	Else
		nDigito := 2
	EndIf     
	
ACTIVATE MSDIALOG oDlgCBar CENTERED ON INIT EnchoiceBar(oDlgCBar, {|| nOpca3 := 2, Iif(!Empty(cDadCB),oDlgCBar:End(),Nil)},{|| nOpca3 := 1,oDlgCBar:End()})

If nOpca3 == 2 .AND. !Empty(cDadCB)
	cTextBar := "#CB { '" + Alltrim(cCombo5) + "'," + Alltrim(Str(cPosVert)) + "," +  Alltrim(Str(cPosHoriz)) + "," +  Alltrim(cDadCB) + ",, " + Iif(nDigito == 1,".T.",".F.") +",, " + Iif(nPosicao == 2,".T.",".F.") + "," + Alltrim(Str(cTamVert)) + "," + Alltrim(Str(cTamHoriz)) + " , .F., 'TAHOMA', 'B', .F. }"
	//oGTQCodigo:AppendText( cTextBar + Chr(10))
	
	cDado1 := Substr(M->GTQ_FUNCAO, 1, oGTQCodigo:nPos) 
	cDado2 := Substr(M->GTQ_FUNCAO, oGTQCodigo:nPos, Len(M->GTQ_FUNCAO))	
	//oGTQCodigo:AppendText( Chr(10) + cCfgCoord + Chr(10))	
	M->GTQ_FUNCAO := ""//    
	oGTQCodigo:refresh()
	oGTQCodigo:nPos := 1
	oGTQCodigo:AppendText( cDado1 + cTextBar + Chr(10) + cDado2 )
EndIf


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_HLPBUT บAutor  ณMicrosiga           บ Data ณ  03/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Help dos bot๕es                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SAUDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_HLPBUT(cCodTag)
Local nPosHlp 	:= aScan(aHlpBut, {| aVet | AllTrim(aVet[1]) == cCodTag}) 
Local cTxthlp	:= ""
Local nOpcH		:= 0

If nPosHlp > 0
	cTxthlp := aHlpBut[nPosHlp,2]
EndIf

DEFINE MSDIALOG oDlgH FROM	62,100 TO 250,400 TITLE "Help" PIXEL 

//	@ 006, 008 SAY oSay PROMPT "Informe o texto:"	SIZE 60,009 OF oDlgH PIXEL COLOR CLR_HBLUE 
	@ 006, 006 GET oTexto VAR cTxthlp MEMO When .F. SIZE 140, 070 OF oDlgH PIXEL  
	
DEFINE SBUTTON FROM 080,060 TYPE 1 ACTION {|| nOpcH := 1, oDlgH:End() } ENABLE OF oDlgH 	

ACTIVATE MSDIALOG oDlgH CENTERED       
											 
Return()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEXECUTA O MACRO POR LINHAณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Function HS_MacGTQ(cCamMac)
Local nForMem := 0
For nForMem := 1 To MLCount(cCamMac)	
	&(MemoLine(cCamMac,, nForMem))	
Next nForMem
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_EXEGTSบAutor  ณMicrosiga           บ Data ณ  05/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
 Function HS_EXEGTS(aColGts, nPosArquiv, nPosOrdExe, nPosDado, nPosIndice )
Local nI 		:= 0  
Local cDadoInd	:= ""     
If Len(aColGts) > 0 .AND. !Empty(aColGts[1,nPosArquiv]) 
	aSort( aColGts,,,{|x,y| x[nPosOrdExe] < y[nPosOrdExe] })	// Ordena a execu็ใo
	For nI := 1 To Len(aColGts)                         
		If !Empty(aColGts[nI,nPosDado]) .AND. !Empty(aColGts[nI,nPosIndice])
			DbSelectArea(aColGts[nI,nPosArquiv]) //Abre o arquivo cadastrado
			DbGoTop()
			DbSetOrder(Val(aColGts[nI,nPosIndice])) // Indice escolhido
			cDadoInd := &(aColGts[nI,nPosDado])						
		EndIf
	Next nI
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvEst  บAutor  ณMicrosiga          บ Data ณ  03/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de grava็ใo dos dados                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SAUDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GrvEst(nOpcG)
Local lAchou 	:= .T.
Local cNomArq := "HSPM63" + M->GTQ_CODIGO + ".TXT"

DbselectArea("GTQ")
DbsetOrder(1) //GG2_FILIAL+GG2_CODPAR
lAchou := DbSeek(xFilial("GTQ") + M->GTQ_CODIGO)

If nOpcG == 3 .or. nOpcG == 4   // INCLUSAO ou ALTERACAO
	FS_GRAVATXT(cNomArq)
	RecLock("GTQ", !lAchou)
	HS_GRVCPO("GTQ")
	GTQ->GTQ_FILIAL  := xFilial("GTQ")
	MsUnlock()
	
	FS_GrvGD("GTS", 1, oGTS, nGTSArquiv, nOpcG)	
	FS_GrvGD("GTT", 1, oGTT, nGTTCodUsu, nOpcG)		
Else // EXCLUSAO	
	FS_GDExc("GTS", 1)	
	FS_GDExc("GTT", 1)		
	RecLock("GTQ", .F., .T.)
	DbDelete()
	MsUnlock()
	WriteSx2("GTQ")
EndIf
Return()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤhฟ
//ณGRAVA O GRIDณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤhู
Static Function FS_GrvGD(cAlias, nOrdem, oGet, nPosArq, nOpcG)

Local nFor     := 0, nPosACols := 0
Local lAchou   := .F.
Local cPrefixo :=  cAlias + "->" + PrefixoCpo(cAlias)

DbSelectArea(cAlias)
DbSetOrder(nOrdem)

For nFor :=1 To Len(oGet:aCols)	
	lAchou := DbSeek(xFilial(cAlias) + M->GTQ_CODIGO + oGet:aCols[nFor, nPosArq])
	If oGet:aCols[nFor, Len(oGet:aHeader)+1 ]== .T.  // Se a linha esta deletada na get e achou o registro no banco
		If lAchou .And. nOpcG <> 3
			RecLock(cAlias, .F., .F. )
			DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		EndIf
	Else
		RecLock(cAlias, !lAchou )
		HS_GRVCPO(cAlias, oGet:aCols, oGet:aHeader, nFor)
		&(cPrefixo + "_FILIAL") := xFilial(cAlias)
		&(cPrefixo + "_CODLAY") := M->GTQ_CODIGO
		MsUnlock()
	EndIf
Next
Return()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ฟ
//ณEXCLUI ITENS DO GRIDณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ ู
Static Function FS_GDExc(cAlias,nOrdem)
Local cPrefixo :=  cAlias + "->" + PrefixoCpo(cAlias)

DbSelectArea(cAlias)
DbSetOrder(nOrdem)
DbSeek(xFilial(cAlias) + M->GTQ_CODIGO)
While !Eof() .And. &(cPrefixo + "_FILIAL") = xFilial(cAlias) .And. &(cPrefixo + "_CODLAY") = M->GTQ_CODIGO
	RecLock(cAlias, .F., .F. )
	DbDelete()
	MsUnlock()
	WriteSx2(cAlias)
	DbSkip()
End
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjusteSXB บAutor ณPablo Gollan Carrerasบ Data ณ  26/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAE_SVIAG                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AjustaSXB(cAliasOr,cAliasDest,cFiltro)

Local aAreaXB	:= SXB->(GetArea())
Local lRet		:= .T.
Local aCampos	:= {}
Local ni		:= 0       
Local aStru		:= {}
Local nPos		:= 0
Local nRecno	:= 0

dbSelectArea("SXB")
SXB->(dbSetOrder(1))
If !SXB->(dbSeek(cAliasDest))
	If SXB->(dbSeek(cAliasOr))
		//Montando a lista de campos / valores
		aStru := SXB->(dbStruct())
		Do While !SXB->(Eof()) .AND. AllTrim(SXB->XB_ALIAS) == cAliasOr
			nRecno := SXB->(Recno())
			aCampos := Array(0)
			For ni := 1 to Len(aStru)
				aAdd(aCampos,{aStru[ni][1],SXB->(FieldGet(FieldPos(aStru[ni][1])))})
			Next ni	
			Do Case 
				Case SXB->XB_TIPO == "6" //Filtro       
					Reclock("SXB",.T.,.T.)
					SXB->XB_ALIAS := cAliasDest					
					For ni := 2 to Len(aCampos)
						nPos := SXB->(FieldPos(aCampos[ni][1]))
						If aCampos[ni][1] == "XB_CONTEM"
							FieldPut(nPos,cFiltro)
						Else
							FieldPut(nPos,aCampos[ni][2])
						Endif
					Next ni  
					MsUnlock()
				Otherwise
					Reclock("SXB",.T.,.T.)
					SXB->XB_ALIAS := cAliasDest				
					For ni := 2 to Len(aCampos)
						nPos := SXB->(FieldPos(aCampos[ni][1]))
						FieldPut(nPos,aCampos[ni][2])
					Next ni
					MsUnlock()
			EndCase               
			SXB->(dbGoto(nRecno))
			SXB->(dbSkip())
		EndDo
	Endif
Else
	//Verificar filtro
	If SXB->(dbSeek(cAliasDest + "6"))
		If SXB->XB_CONTEM # cFiltro
			Reclock("SXB",.F.,.T.)
			SXB->XB_CONTEM := cFiltro
			MsUnlock()
		Endif
	Endif
Endif                                      
RestArea(aAreaXB)

Return lRet