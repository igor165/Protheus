
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA366   บAutor  ณPaulo Carnelossi    บ Data ณ  03/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para Inclusao de Formas de Pagamento para RDA de     บฑฑ
ฑฑบ          ณacordo com local de atendimento x especialidade             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA366()        
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de variaveis...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE aRotina     := MenuDef()							
PRIVATE cCadastro 	:= Fundesc()
PRIVATE aHeader     := {}
PRIVATE aCols       := {}
PRIVATE n           := 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Starta mBrowse...                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BAU->(DBSetOrder(2))
BAU->(mBrowse(06,01,22,75,"BAU",,,20))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fim da Rotina Principal...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA366FPGบAutor  ณPaulo Carnelossi    บ Data ณ  05/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro das formas de pagamento da RDA/Local/Especialidade บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA366FPG(cAlias, nReg, nOpc)
Local oDlg
Local oBrwBAX
Local oBrwBCD
Local oFolder
Local nOpcx := If(nOpc==K_Visualizar,K_Visualizar,0)
Local nOpca := 0

Local aHeaderBAX, cVar:="", nCtd
Local bCodOpe, bCodEsp, bCodLoc

Local aAuxCabBAX, aCabBAX := {}
Local aAuxDadBAX, aDadBAX := {}
Local aVetBAX := {}

Local aCabBCD 	:= {}
Local aDadBCD 	:= {}
Local aTrbBCD 	:= {}
Local bAtuBCD

Local bCancel := {|| PlsEndBrw(), oDlg:End() }
Local bTudoOk := {|| If(PLSA366TOK(), (nOpca := K_OK,PlsEndBrw(), oDlg:End()), nOpca := 0) }


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define fonte...                                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oFont
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aDifSize:= {,,,,35,3,,}//array com dimen็๕es para corre็ใo de telas na versใo 12

PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader := {}
PRIVATE aCols := {}
PRIVATE n
PRIVATE BAX_CODINT
PRIVATE BAX_CODLOC
PRIVATE BAX_CODESP
PRIVATE BAX_DESESP
						
bAtuBCD	:= {||	M->BAX_CODINT := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_CODINT")],;
						M->BAX_CODLOC := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_CODLOC")],;
						M->BAX_CODESP := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_CODESP")],;
						M->BAX_DESESP := oBrwBAX:aCols[oBrwBAX:Linha(),oBrwBAX:FieldPos("BAX_NOMESP")],;
						}

cCadastro 	:= BAU->BAU_CODIGO+"-"+BAU->BAU_NOME

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define fontes utilizadas somente nesta funcao...                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
//monta browse que ira funcionar como listbox
BAX->(DbSetOrder(1))
aHeaderBAX := {"BAX_CODINT", "BAX_CODLOC", "BAX_CODESP"}
aCabBAX := FunHeader("BAX", aHeaderBAX)

If ! BAX->(DbSeek(xFilial("BAX")+BAU->(BAU_CODIGO))) 
    MsgStop("Nใo ha Especialidade cadastrada para esta RDA!")
    Return
Else
	RegToMemory("BAX",.F.)
   Store COLS "BAX" TO aDadBAX FROM aCabBAX VETTRAB aVetBAX ;
   While BAX->(BAX_FILIAL+BAX_CODIGO) == xFilial("BAX")+BAU->BAU_CODIGO
Endif

//preserva os valores originais para utilizacao na execucao dos code blocks
aAuxCabBAX := ACLONE(aCabBAX)
aAuxDadBAX := ACLONE(aDadBAX)

//Operadora
bCodOpe := {|nCtd|cVar := aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODINT"})],;
				Padr(Posicione("BA0",1, xFilial("BA0")+cVar,"BA0_NOMINT"),30)}

InsColuna(aCabBAX, aDadBAX, 2, "BAX", "Desc.Operadora", "BAX_NOMINT", bCodOpe)

//Localidade
bCodLoc := {|nCtd|cVar := BAU->BAU_CODIGO, ;
				cVar += aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODINT"})],;
				cVar += aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODLOC"})],;
				Padr(Posicione("BB8",1, xFilial("BB8")+cVar,"BB8_DESLOC"),30)}

InsColuna(aCabBAX, aDadBAX, 4, "BAX", "Desc.Local", "BAX_NOMLOC", bCodLoc)

//Especialidade
bCodEsp := {|nCtd|cVar := aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODINT"})],;
				cVar += aAuxDadBAX[nCtd][ASCAN(aAuxCabBAX,{|aVal| aVal[2] == "BAX_CODESP"})],;
				Padr(Posicione("BAQ",1, xFilial("BAQ")+cVar,"BAQ_DESCRI"),30)}

InsColuna(aCabBAX, aDadBAX, 6, "BAX", "Desc.Especialidade", "BAX_NOMESP", bCodEsp)


//monta browse para cadastrar as formas de pagamento para RDAxOperadoraxLocalxEspecial.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Formas de Pagamento RDAxOperadoraxLocalidadexEspecialidade          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Store Header "BCD" TO aCabBCD For .T.
BCD->(DbSetOrder(1))
If ! BCD->(DbSeek(xFilial("BCD")+BAU->BAU_CODIGO))
   If nOpcx == K_Visualizar
      MsgStop("Formas de Pagamento nใo cadastrada!")
      Return
   EndIf   
	Store COLS Blank "BCD" TO aDadBCD FROM aCabBCD
	nOpcx := K_Incluir
	lInclui := .T.
	lAltera := .F.
Else
	Store COLS "BCD" TO aDadBCD FROM aCabBCD VETTRAB aTrbBCD ;
	While BCD->(BCD_FILIAL+BCD_CODIGO) == xFilial("BCD")+BAU->BAU_CODIGO
	If nOpcx != K_Visualizar
		nOpcx := K_Alterar
		lInclui := .F.
		lAltera := .T.
	EndIf	
Endif
If Len(aDadBCD) == 0 
   If nOpcx == K_Visualizar
      MsgStop("Formas de Pagamento nใo cadastrada!")
      Return
   EndIf   
	Store COLS Blank "BCD" TO aDadBCD FROM aCabBCD
	nOpcx := K_Incluir
	lInclui := .T.
	lAltera := .F.
EndIf
						
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define dialogo...                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, Round(aSize[ 3 ] * 0.18, 2), .T., .F., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

SetEnch("")
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel

oBrwBAX := BAX->(TPLSBrw():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][4],aPosObj[1][3],nil,oDlg,nil,{||.t.},nil,nil,nil,.T.,nil,.T.,nil,aCabBAX,aDadBAX,.F.,"BAX",K_Visualizar,"Formas Pagamento RDA",nil,nil,nil,aVetBAX,,,))
oBrwBAX:bGotFocus 	:= {||Eval(oBrwBAX:bLostFocus), oBrwBCD:ForceRefresh(oBrwBAX)}
oBrwBAX:bLostFocus 	:= {||Eval(bAtuBCD)}
oBrwBAX:bChange 		:= {||Eval(oBrwBAX:bLostFocus), oBrwBCD:ForceRefresh(oBrwBAX)} 

@ aPosObj[2][1],aPosObj[2][2] FOLDER oFolder SIZE aPosObj[2][3],aPosObj[2][4] OF oDlg PIXEL PROMPTS "Formas de Pagamento"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TPLSBCD -> FORMAS DE PAGAMENTO                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BCD_CODINT",aHeader)] == M->BAX_CODINT .And. ;
				aCols[nLine,GdFieldPos("BCD_CODLOC",aHeader)] == M->BAX_CODLOC .And. ;
				aCols[nLine,GdFieldPos("BCD_CODESP",aHeader)] == M->BAX_CODESP }
if Val(GetVersao(.F.)) >= 12 //Valida versใo 12
	oBrwBCD := TPLSBrw():New(003,003,aPosObj[2][3]-5,aPosObj[2][4]-15,nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBCD,aDadBCD,.F.,"BCD",nOpcx,"Formas de Pagamento",nil,nil,nil,aTrbBCD,,,bFilter,,,,,,,,,,aDifSize)
Else
	oBrwBCD := TPLSBrw():New(003,003,aPosObj[2][3]-5,aPosObj[2][4]-15,nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabBCD,aDadBCD,.F.,"BCD",nOpcx,"Formas de Pagamento",nil,nil,nil,aTrbBCD,,,bFilter)
Endif


oBrwBCD:oPai    := oBrwBAX
oBrwBCD:aOrigem := {"BAX_CODINT","BAX_CODLOC","BAX_CODESP"}
oBrwBCD:aRelac  := {"BCD_CODINT","BCD_CODLOC","BCD_CODESP"}                      
//oBrwBCD:cVldLine := ''

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bTudoOk,bCancel,K_MsgDel)

If nOpca == K_OK .And. nOpcx != K_Visualizar
	aChave := {}
	aadd(aChave,{"BCD_CODIGO",BAU->BAU_CODIGO})
	oBrwBCD:Grava(aChave)
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInsColuna บAutor  ณPaulo Carnelossi    บ Data ณ  03/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInserir uma coluna nos arrays aCabAlias, aDadAlias para uso บฑฑ
ฑฑบ          ณna browse da classe plsbrw                                  บฑฑ
ฑฑบ          ณsomente colunas caracteres, criando campo virtual - Visual  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InsColuna(aCab, aDad, nPos, cAlias, cTitle, cCampo, bRotFun)
Local nTamCpo, nCtd

ASIZE(aCab,Len(aCab)+1)
AINS(aCab, nPos)

For nCtd := 1 TO LEN(aDad)
	ASIZE(aDad[nCtd], Len(aDad[nCtd])+1)
	AINS(aDad[nCtd], nPos)
	aDad[nCtd][nPos] := Eval(bRotFun, nCtd)
	nTamCpo := Len(aDad[nCtd][nPos])
Next	

/*
[ 1] := SX3->X3_TITULO
[ 2] := SX3->X3_CAMPO
[ 3] := SX3->X3_PICTURE
[ 4] := SX3->X3_TAMANHO
[ 5] := SX3->X3_DECIMAL
[ 6] := SX3->X3_VALID
[ 7] := SX3->X3_USADO
[ 8] := SX3->X3_TIPO
[ 9] := SX3->X3_ARQUIVO
[10] := SX3->X3_CONTEXT
*/

aCab[nPos] := {}
aAdd(aCab[nPos], cTitle)
aAdd(aCab[nPos], cCampo)
aAdd(aCab[nPos], "@!")
aAdd(aCab[nPos], nTamCpo)
aAdd(aCab[nPos], 0)
aAdd(aCab[nPos], "")
aAdd(aCab[nPos], "")
aAdd(aCab[nPos], "C")
aAdd(aCab[nPos], cAlias)
aAdd(aCab[nPos], "V")

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFunHeader บAutor  ณPaulo Carnelossi    บ Data ณ  03/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDevolver um array contendo somente os campos desejados no   บฑฑ
ฑฑบ          ณalias determinado com array enviado como argumento          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FunHeader(cAlias, aHeader)
Local aAuxCab, nPos, cCampo, nCtd
Local aCab := {}

Store Header cAlias TO aAuxCab For .T.

For nCtd := 1 TO Len(aHeader)
    cCampo := aHeader[nCtd]
    nPos := ASCAN(aAuxCab,{|aVal| aVal[2] == cCampo})
    If nPos > 0
    	aAdd(aCab, aAuxCab[nPos])
    EndIf
Next

Return(aCab)

Static Function PLSA366TOK()

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSA366C บAutor  ณHelio F. R. Lecchi  บ Data ณ  24/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se e para calcular com ou sem UTV                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA366C()
Local nRetC := 0

If M->BCE_TIPPAG=="2" 
	If AllTrim(M->BCD_UNICON) $ PLSCHMP()
		nRetC := M->BCE_QTDAPT * M->BCE_VLRPAG * Posicione("BFM",1,xFilial("BFM")+M->BCE_CODINT+M->BCE_ANOPAG+M->BCE_MESPAG,"BFM_VALRDA")   
	Else
		nRetC := M->BCE_QTDAPT * M->BCE_VLRPAG   
	Endif	
Else
	nRetC := M->BCE_VLRPAG
Endif

Return(nRetC)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Darcio R. Sporl       ณ Data ณ04/01/2007ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01	    ,'AxPesqui'			, 0 ,K_Pesquisar , 0, .F.},;
						{ "Vis.Formas Pg"	,'PLSA366FPG'		, 0 ,K_Visualizar, 0, Nil},;
						{ "Formas Pagto"	,'PLSA366FPG'		, 0 ,K_Alterar   , 0, Nil} }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de Entrada p/ incluir nova op็ใo do usuแrio no aRotina        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If ExistBlock("PL366BOT")
	aRotAdic := ExecBlock("PL366BOT", .F., .F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIF
EndIF

Return(aRotina)