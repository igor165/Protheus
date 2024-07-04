#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TMKA510L.CH"

#DEFINE MAXGETDAD 4096

#DEFINE WFTYPE_INFORMATION 		1
#DEFINE WFTYPE_AUTHORIZATION 	2

#DEFINE RULE_APROVADO "1"
#DEFINE RULE_REPROVADO "2"

#DEFINE EVT_ABERTURA 		1
#DEFINE EVT_ATUALIZACAO 	2
#DEFINE EVT_ENCERRAMENTO 	3
#DEFINE EVT_ABERTURAFNC 	4
#DEFINE EVT_TRANSFEQUIPE 	5
#DEFINE EVT_INICIOSLA 		6
#DEFINE EVT_PAUSASLA 		7
#DEFINE EVT_FIMSLA 			8

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA510L      บAutorณVendas Clientes   บ Data ณ  12/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Regras de Monitora็ใo de Chamados do Service Desk          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                            
Function TMKA510L()
Local aCores 	:= {	{"(!Empty(AGC->AGC_FIMVIG) .AND. !Empty(AGC->AGC_INIVIG)) .AND. ((AGC->AGC_FIMVIG < dDataBase) .OR. (AGC->AGC_INIVIG > dDataBase ))", "BR_VERMELHO"     },;// Fora do prazo
   						{"VAL(AGC->AGC_STATUS) == 1", "BR_VERDE"    },;// Ativo
   						{"VAL(AGC->AGC_STATUS) == 2", "BR_CINZA"  	}} // Inativo 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//PRIVATE aAC := { STR0001,STR0002 } //"Abandona","Confirma"

PRIVATE aRotina := MenuDef()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE cCadastro := STR0001 //"Regra de Monitora็ใo de Chamados" 


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
mBrowse( 6, 1,22,75,"AGC",,,,,,aCores)
Return .T.  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA510L      บAutorณVendas Clientes   บ Data ณ  12/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe o cadastro de Regras de Monitoracao de Chamados Ser- บฑฑ
ฑฑบ          ณ-vice Desk.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                    
Function TK510LDialog(cAlias,	nReg,	nOpc)
Local aArea     := GetArea()                            	//Guarda a area atual
Local aPosObj   := {}										//Array com posicao dos objetos
Local aObjects  := {}										//Array com as coordenadas da tela
Local aSize     := {}										//Array com as dimensoes retornadas pelo MsAdvSize()
Local aInfo     := {}										//Array de informacoes de tela
Local aHeadApr  := {}										//Array aHeader de Entidades
Local aColsApr  := {}										//Array aCols de Entidades
Local aHeadRep  := {}										//Array aHeader de Severidade
Local aColsRep  := {}										//Array aCols de Entidades
Local aTitles   := {STR0002,STR0003} 						//Array com os titulos das GetDados //"Aprovado"###"Reprovado"
Local aFldCBAtu := {}										//Array com os folders usados
Local nOpcA     := 0										//Guarda a opcao selecionada (1=gravar;0=cancelar)
Local nSaveSx8 	:= GetSX8Len()								//Numeracao automatica
Local lContinua := .T.										//Indica se continua a execucao da funcao
Local lRet		:= .T.										//Indica o retorno da funcao
Local oDlg													//Objeto Dialog
Local oGetApr												//Objeto GetDados de Aprovado
Local oGetRep   											//Objeto GetDados de Reprovado
Local oFolder												//Objeto Folder

Private aTELA[0][0]
Private aGETS[0]

DEFAULT INCLUI := .F.

If nOpc == 3
	INCLUI := .T.
EndIf
           
//DbSelectArea(cAlias)
//DbGoTo(nReg)    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa as variaveis da Enchoice                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("AGC")
If INCLUI
	RegToMemory( "AGC", .T., .F. )
Else
	If SoftLock("AGC")
		RegToMemory( "AGC", .F., .F. )
	Else
		lContinua	:= .F.
		lRet		:= .F.
	EndIf
EndIf    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Construir aHeader e aCols das 2 Getdadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lContinua
	BuildCols(nOpc,aHeadApr,aColsApr,aHeadRep,aColsRep)
EndIf

If nOpc == 6 // Copiar
	M->AGC_COD := TKNUMERO('AGC','AGC_COD')
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz o calculo automatico de dimensoes de objetos     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize := MsAdvSize()
aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 200, 200, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

EnChoice( "AGC", nReg, nOpc,,,,,aPosObj[1], , 3, , , , , ,.F. )
oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{""},oDlg,,,, .T., .F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],)
oFolder:bSetOption := {|nDst| Tk510FlChg(nDst,oFolder:nOption,oFolder,aFldCBAtu)}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ GetDados de Aprovados (AGD)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetApr := MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1],aPosObj[2,4]-aPosObj[2,2],;
			IIf(!INCLUI.And.!ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
			"Tk530LOkEnt()","Tk530TOkEnt()","+AGD_ITEM"/*inicpos*/,/*alteraveis*/,;
			/*freeze*/,MAXGETDAD,/*fieldok*/,/*superdel*/,;
			/*delok*/,oFolder:aDialogs[1],aHeadApr,aColsApr)
			
oGetApr:oBrowse:bLostFocus	:= {|| lRetorno := oGetApr:TudoOk(),oFolder:nOption := IIf(lRetorno,oFolder:nOption,1),aColsApr:=IIf(lRetorno,oGetApr:aCols,aColsApr),lRetorno }
aAdd(aFldCbAtu, oGetApr:oBrowse:bLostFocus)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ GetDados de Reprovados (AGD) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetRep := MsNewGetDados():New(0,0,aPosObj[2,3]-aPosObj[2,1],aPosObj[2,4]-aPosObj[2,2],;
			IIF(!INCLUI.And.!ALTERA,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
			"Ft530LOkSev()","Tk530TOkSev()","+AGD_ITEM"/*inicpos*/,/*alteraveis*/,;
			/*freeze*/,MAXGETDAD,/*fieldok*/,/*superdel*/,;
			/*delok*/,oFolder:aDialogs[2],aHeadRep,aColsRep)
			
oGetRep:oBrowse:bLostFocus	:= {|| lRetorno := oGetRep:TudoOk(),oFolder:nOption := IIf(lRetorno,oFolder:nOption,2),aColsRep:=IIf(lRetorno,oGetRep:aCols,aColsRep),lRetorno }
aAdd(aFldCbAtu, oGetRep:oBrowse:bLostFocus)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA := 1,If(Tk510FlChg(0,oFolder:nOption,oFolder,aFldCBAtu) .And. oGetApr:TudoOk() .And. oGetRep:TudoOk(),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},;
											{|| nOpcA := 0, oDlg:End()},,/*aButtons*/)


If nOpcA == 0
	lRet := .F.	
	While (GetSx8Len() > nSaveSx8)
		RollBackSX8()
	End	
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava o registro ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOpc == 3 .OR. nOpc == 4 .OR. nOpc == 5 .OR. nOpc == 6
		Tk510LGrv(nOpc, aHeadApr, aColsApr, aHeadRep, aColsRep)
		While (GetSx8Len() > nSaveSx8)
			ConfirmSX8()
		End
		EvalTrigger()
	EndIf	
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restaura a entrada da rotina ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MsUnLockAll()
FreeUsedCode()
RestArea(aArea)

Return .T.   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510LGrv     บAutorณVendas Clientes   บ Data ณ  16/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava os dados relacionados ao assunto.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Service Desk                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Static Function Tk510LGrv(nOpc, aHeaderApr, aColsApr, aHeaderRep, aColsRep)
Local nItens 	:= 0	// Variavel para controle do Loop
Local nOption	:= 0	
Local aAreaAGC 	:= AGC->(GetArea())
Local aAreaAGD 	:= AGD->(GetArea())  
Local nPosCod	:= 0 
Local nPosItem	:= 0
Local aColsTmp	:= {}
Local aHeadTmp	:= {} 
Local nI 		:= 0
Local lInclui   := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza os dados do cabe็alhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
If nOpc == 3 .OR. nOpc == 6                
	lInclui := .T.
EndIf

RecLock("AGC",lInclui)
If nOpc == 5
	DbDelete()
Else
	For nI := 1 TO AGC->(FCount())
		If (FieldName(nI) == "AGC_FILIAL")
			FieldPut(nI, xFilial("AGC"))
		Else
			FieldPut(nI, M->&(FieldName(nI)))
		EndIf
	Next nI
EndIf
MsUnLock()
FkCommit()
    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava็ใo das informa็๕es ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nOption := 1 To 2  
	If nOption == 1
		aColsTmp := aClone(aColsApr) 
		aHeadTmp := aClone(aHeaderApr)
	Else
		aColsTmp := aClone(aColsRep) 
		aHeadTmp := aClone(aHeaderRep)
	EndIf                      
	nPosItem 	:= aScan(aHeadTmp, {|x| AllTrim(Upper(x[2]))=="AGD_ITEM"})
	For nItens := 1 To Len(aColsTmp)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida็ใo para nใo permitir duplicidadesณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("AGD")
		DbSetOrder(1) // AGD_FILIAL+AGD_COD+AGD_TIPO+AGD_ITEM
		If DbSeek( xFilial("AGD")+M->AGC_COD+AllTrim(Str(nOption))+aColsTmp[nItens][nPosItem] )	
			RecLock("AGD",.F.,.T.)
		Else
			RecLock("AGD", .T.)	
		EndIf
	
		If !aColsTmp[nItens][Len(aColsTmp[nItens])] .AND. nOpc <> 5
			For nI := 1 TO AGD->(FCount())
				If (FieldName(nI) == "AGD_FILIAL")
					FieldPut(nI, xFilial("AGD"))
				ElseIf (FieldName(nI) == "AGD_TIPO")
					FieldPut(nI, AllTrim(Str(nOption)))
				ElseIf (FieldName(nI) == "AGD_COD")
					FieldPut(nI, M->AGC_COD)					
				Else       
					nPosCod	:= aScan(aHeadTmp, {|x| AllTrim(Upper(x[2]))==FieldName(nI)})
					If nPosCod > 0
						FieldPut(nI, aColsTmp[nItens][nPosCod])
					EndIf
				EndIf
			Next nI						
		Else
	
			DbDelete()		
		EndIf
		MsUnlock()                                              	
	
	Next nItens
Next nOption

RestArea(aAreaAGC)
RestArea(aAreaAGD)
Return Nil        

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTk510FlChgณAutor  ณ Vendas Clientes       ณ Data ณ10.03.2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณRotina de controle da troca de folder                        ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpN1: Folder de destino                                     ณฑฑ
ฑฑณ          ณExpN2: Folder atual                                          ณฑฑ
ฑฑณ          ณExpO3: Objeto do Folder                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                       ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณEsta rotina tem como objetivo exibir/controlar os folders do ณฑฑ
ฑฑณ          ณcadastro 								                       ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ MP10								                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Tk510FlChg(nFldDst,nFldAtu,oFolder,aCodeBlock)

Local lRetorno := .T.			//Indica retorno da funcao
DEFAULT nFldDst := IIf(oFolder<>Nil,oFolder:nOption,1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza os objetos do folder de destino                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(aCodeBlock) .And. nFldAtu<=Len(aCodeBlock) .And. !Empty(aCodeBlock[nFldAtu])
	lRetorno := Eval(aCodeBlock[nFldAtu])
EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณBuildCols บAutor  ณ Vendas Clientes    บ Data ณ  10/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo responsavel pela construcao do aHeader e aCols da   บฑฑ
ฑฑบ          ณ rotina                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuildCols(nOpc,aHeadEnt,aColsEnt,aHeadSev,aColsSev) 
Local cSeek		:= ""					//Conteudo do seek para a FillGetDados
Local cWhile	:= ""					//Expressao de condicao para FillGetDados
Local cQuery	:= ""					//Expressao de query a ser executada
Local lQuery    := .F.					//Indica se usa query (TOP)
Local nPosItem	:= 0

//ฺฤฤฤฤฤฤฤฤฤฟ
//ณAprovadosณ
//ภฤฤฤฤฤฤฤฤฤู

#IFDEF TOP
	If aScan(aHeadEnt, {|x| x[8] == "M"} ) == 0
		lQuery := .T.
		cQuery := "SELECT * "
		cQuery += "FROM "+RetSqlName("AGD")+" AGD "
		cQuery += "WHERE AGD.AGD_FILIAL='" + xFilial("AGD") + "' AND "
		cQuery += "AGD.AGD_COD='" + M->AGC_COD + "' AND " 
		cQuery += "AGD.AGD_TIPO='1' AND "
		cQuery += "AGD.D_E_L_E_T_= ' ' "
		
		cQuery := ChangeQuery(cQuery)
	Else
#ENDIF
		DbSelectArea("AGD")
		DbSetOrder(1)
		DbSeek(xFilial("AGD")+M->AGC_COD+"1")
#IFDEF TOP
	EndIf
#ENDIF
 
cSeek  := xFilial("AGD")+M->AGC_COD+RULE_APROVADO
cWhile := "AGD->AGD_FILIAL + AGD->AGD_COD + AGD->AGD_TIPO"
DbSelectArea("AGD")
DbCloseArea()
FillGetDados(	nOpc			, "AGD"						,1				,cSeek,; 
				{||&(cWhile)}	, /*{|| bCond,bAct1,bAct2}*/,{"AGD_CODRES"}/*aNoFields*/	,/*aYesFields*/,; 
		   		/*lOnlyYes*/	,cQuery						,/*bMontAcols*/	,IIf(nOpc<>3,.F.,.T.),; 
				aHeadEnt		,aColsEnt 					,/*bafterCols*/ , /*bBeforeCols*/,;
				/*bAfterHeader*/, "AGD")
        
nPosItem 	:= aScan(aHeadEnt, {|x| AllTrim(Upper(x[2]))=="AGD_ITEM"})
If nOpc == 3
	If Len(aColsEnt) >= nPosItem
		aColsEnt[Len(aColsEnt), nPosItem] := "001"	
	EndIf       
Else
	If Len(aColsEnt) == 1 .AND. Len(aColsEnt) >= nPosItem		
		If Empty(aColsEnt[Len(aColsEnt), nPosItem])
			aColsEnt[Len(aColsEnt), nPosItem] := "001"	
		EndIf
	EndIf	
EndIf

If lQuery
	DbSelectArea("AGD") 
	DbCloseArea()
	ChkFile("AGD")
EndIf


aHeader :={}
aCols   :={}

//ฺฤฤฤฤฤฤฤฤฤฤฟ
//ณReprovadosณ
//ภฤฤฤฤฤฤฤฤฤฤู

#IFDEF TOP
	If aScan(aHeadEnt, {|x| x[8] == "M"} ) == 0
		lQuery := .T.
		cQuery := "SELECT * "
		cQuery += "FROM "+RetSqlName("AGD")+" AGD "
		cQuery += "WHERE AGD.AGD_FILIAL='" + xFilial("AGD") + "' AND "
		cQuery += "AGD.AGD_COD='" + M->AGC_COD + "' AND "
		cQuery += "AGD.AGD_TIPO='2' AND "
		cQuery += "AGD.D_E_L_E_T_= ' ' "
		
		cQuery := ChangeQuery(cQuery)
	Else
#ENDIF
		DbSelectArea("AGD")
		DbSetOrder(1)
		DbSeek(xFilial("AGD")+M->AGC_COD+"2")
#IFDEF TOP
	EndIf
#ENDIF
 
cSeek  := xFilial("AGD")+M->AGC_COD+RULE_REPROVADO
cWhile := "AGD->AGD_FILIAL + AGD->AGD_COD + AGD->AGD_TIPO"
DbSelectArea("AGD")
DbCloseArea()

FillGetDados(	nOpc					, "AGD"						,1			,cSeek,; 
				{||&(cWhile)}			, /*{||bCond,bAct1,bAct2}*/	,/*aNoFields*/,; 
		   		/*aYesFields*/			, /*lOnlyYes*/				,cQuery		, /*bMontAcols*/,;
		   		IIf(nOpc<>3,.F.,.T.)	, aHeadSev					,aColsSev 	, /*bAfterCols*/,;
		   		/*bBeforeCols*/			,/*bAfterHeader*/			,"AGD" )

nPosItem 	:= aScan(aHeadSev, {|x| AllTrim(Upper(x[2]))=="AGD_ITEM"})
If nOpc == 3
	If Len(aColsSev) >= nPosItem
		aColsSev[Len(aColsSev), nPosItem] := "001"	
	EndIf   
Else
	If Len(aColsSev) == 1 .AND. Len(aColsSev) >= nPosItem		
		If Empty(aColsSev[Len(aColsSev), nPosItem])
			aColsSev[Len(aColsSev), nPosItem] := "001"	
		EndIf
	EndIf		
EndIf

If lQuery
	dbSelectArea("AGD")
	dbCloseArea()
	ChkFile("AGD")
EndIf
                                                           
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510LLegendaบAutor  ณVendas Clientes  บ Data ณ  12/09/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegendas do cadastro                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณService DEsk                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK510LLegenda()
BrwLegenda(cCadastro,"Legenda",	{	{"BR_VERMELHO"	,STR0004	},; // "Fora do Prazo"
									{"BR_VERDE"		,STR0005	},; // "Ativo"
									{"BR_CINZA"		,STR0006	}}) // "Inativo"


Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |MenuDef   ณ Autor ณ Vendas Clientes       ณ Data ณ08/12/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de defini็ใo do aRotina                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRotina   retorna a array com lista de aRotina             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGATMK                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef() 

Local aRotina:=	{   { STR0007 	,"AxPesqui" 		, 0 , 1 , , .F.},;    		// "Pesquisar"
					{ STR0008 	,"TK510LDialog"		, 0 , 2 , , .T.},;    		// "Visualizar"
					{ STR0009 	,"TK510LDialog"		, 0 , 3 , , .T.},;    		// "Incluir"
					{ STR0010 	,"TK510LDialog"		, 0 , 4, 82 , .T.},;  		// "Alterar"
					{ STR0011 	,"TK510LDialog"		, 0 , 5, 3 , .T.},;   		// "Excluir"
					{ STR0012	,"TK510LDialog"		, 0 , 6, 3 , .T.},;   		// "Copiar"					
					{ STR0013	,"TK510LLegenda" 	, 0 ,2 , , .T. }} 	   		//"Legenda"
					
Return(aRotina)					


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510LRegMon บAutor  ณVendas Clientes  บ Data ณ  16/09/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca atrav้s do evento as regras de Monitoramento de Chama-บฑฑ
ฑฑบ          ณ-dos do Service Desk.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณService DEsk                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                    
Function TK510LRegMon(	nEvento,	cCodChamado,	cCodEnt,	cCodSB1,;
						cSevCod,	cCodOri,		cCodEfe,	cCodCat,;	
						cCodCau,	cCodGrupo )
Local lRet := .F.
Local cQuery := ""
Local cAlias := "AGC"
Local aAreaAGC := AGC->(GetArea())

If Select("AGC") > 0
	DbSelectArea("AGC")
	DbCloseArea()
EndIf

cQuery := "SELECT * " 
cQuery += "FROM "+RetSqlName("AGC")+" AGC  WHERE "
cQuery += "AGC.AGC_FILIAL = '" + xFilial("AGC") + "' AND "
cQuery += "(AGC.AGC_CODENT = '" + cCodEnt + "' OR AGC.AGC_CODENT = '') AND "
cQuery += "(AGC.AGC_CODSB1 = '" + cCodSB1 + "' OR AGC.AGC_CODSB1 = '') AND "	
cQuery += "(AGC.AGC_SEVCOD = '" + cSevCod + "' OR AGC.AGC_SEVCOD = '') AND "
cQuery += "(AGC.AGC_CODORI = '" + cCodOri + "' OR AGC.AGC_CODORI = '') AND "
cQuery += "(AGC.AGC_CODEFE = '" + cCodEfe + "' OR AGC.AGC_CODEFE = '') AND "
cQuery += "(AGC.AGC_CODCAT = '" + cCodCat + "' OR AGC.AGC_CODCAT = '') AND "
cQuery += "(AGC.AGC_CODCAU = '" + cCodCau + "' OR AGC.AGC_CODCAU = '') AND "
cQuery += " AGC.AGC_EVENTO = '" + AllTrim(Str(nEvento)) + "'  AND "
If nEvento == EVT_TRANSFEQUIPE
	cQuery += "(AGC.AGC_GRUPO  = '" + cCodGrupo + "' OR AGC.AGC_GRUPO  = '') AND "
EndIf
cQuery += "(AGC.AGC_INIVIG <= '" + DtoS(dDataBase) + "' OR AGC.AGC_INIVIG = '') AND "
cQuery += "(AGC.AGC_FIMVIG >= '" + DtoS(dDataBase) + "' OR AGC.AGC_FIMVIG = '') AND "
cQuery += "AGC.AGC_STATUS = '1' AND "
cQuery += "AGC.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY AGC.AGC_COD "	

cQuery	:= ChangeQuery(cQuery)   
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)	

While (cAlias)->(!EOF())
	lRet := .T.
   	TK510LSendWF((cAlias)->AGC_COD, (cAlias)->AGC_WFTEMP, cCodChamado)
	(cAlias)->(DbSkip())
End                    

(cAlias)->(DbCloseArea())
DbSelectArea("AGC")
DbSetOrder(1)

RestArea(aAreaAGC)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510LSendWF บAutor  ณVendas Clientes  บ Data ณ  16/09/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณNotifica os usuแrios a partir da Regra de Monitora็ใo encon-บฑฑ
ฑฑบ          ณ-trada.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณService DEsk                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                    
Function TK510LSendWF(cCodRegra, cCodWFTemplate, cCodChamado)
Local lRet := .F.

If Tk510LocHtmlWF(cCodWFTemplate)
	lRet := SendWFTemplate(cCodWFTemplate, cCodChamado, cCodRegra)
EndIf

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSendWFTemplateบAutorณVendas Clientes   บ Data ณ  18/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia o Template associado ao atendimento.              	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/        
Static Function SendWFTemplate(cCodTemplate, cCodChamado, cCodRegra)
Local oWFTemplate
Local oWFInfo 
Local lRet 			:= .F.                  
Local nItem 		:= 0 				//Controle do Loop
Local nOcoPos 		:= 0				//Armazena a posicao do campo Ocorrencia
Local oItem								//Objeto contendo a linha do item que serแ enviado no email.
Local nHeader 		:= 0 				//Controle do Loop no aHeader
Local aCBoxOption	:= {}				// Pesquisa opcoes do campo no dicionario  
Local cBoxValue		:= ""          
Local aAreaADE		:= ADE->(GetArea())  
Local aAreaADF		:= ADF->(GetArea())
Local nPosCodSU9	:= 0  
Local lInsertAct	:= .T.
Local aAreaSU9		:= SU9->(GetArea()) 
Local cCodADE		:= ADE->ADE_CODIGO 
Local nPosCodItem	:= 0 
Local nI			:= 0
Local aWFs			:= {}
Local nCount		:= 0
Local cFirstWFCod	:= ""                                  
Local cCodUser 		:= RetCodUsr()
Local cAttMemberFn	:= "AttIsMemberOf"
Local lTK510LCa		:= ExistBlock("TK510LCa")//Ponto de entrada para customizar os campos de cabe็alho para WorkFlow
Local lRetPECab		:=.T.
Local lTK510LIt		:= ExistBlock("TK510LIt")//Ponto de entrada para customizar os campos dos itens para WorkFlow	
Local lRetPEIte		:=.T.                                  

Private INCLUI := .F.
Private ALTERA := .T.

RegToMemory("ADE",.F.)
                   
DbSelectArea("ADE")
DbSetOrder(1)                    						
lRet := DbSeek(xFilial("ADE")+cCodADE)			
If lRet        
	oWFTemplate := WFTemplate():New()
	lRet := oWFTemplate:load(cCodTemplate)     

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNao exibe tela para envio deณ
	//ณanexo para o usuario.       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lRet
		oWFTemplate:lAttachFile := .F.
	EndIf
EndIf
If lRet
	aWFs := oWFTemplate:buildWF(cCodUser, .T.)	
	     
	If ValType(aWFs) != "A"
		aWFs:= {aWFs}
	EndIf	
	
	For nCount := 1 To Len( aWFs )
		oWFInfo := aWFs[nCount]
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Montagem do cabe็alho do atendimento |
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("ADE")
		While !EOF() .AND. SX3->X3_ARQUIVO == "ADE"
			lRetPECab:=.T.
			If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
				If lTK510LCa
					lRetPECab:=ExecBlock("TK510lCa",.F.,.F.,SX3->X3_CAMPO)
					lRetPECab:=IIf(ValType(lRetPECab)<>"L",.F.,lRetPECab)
				EndIf 
				If SX3->X3_CONTEXT == "V" .AND. lRetPECab				
					If AllTrim(SX3->X3_CAMPO) == "ADE_INCIDE"			
						oWFInfo:Header:addField(X3Titulo(), MSMM(ADE->ADE_CODINC,TamSx3("ADE_INCIDE")[1]))									
					Else
						oWFInfo:Header:addField(X3Titulo(), CriaVar(SX3->X3_CAMPO,.T.))									
					EndIf
				Else   
					If Empty(SX3->X3_CBOX) .AND. lRetPECab
						oWFInfo:Header:addField(X3Titulo(), Eval(&("{||ADE->"+SX3->X3_CAMPO+"}"),""))		
					Else
						aCBoxOption	:= TkSx3Box(SX3->X3_CAMPO)													
						If Eval(&("{||ADE->"+SX3->X3_CAMPO+"}")) $ "1234567890" .AND. Val(Eval(&("{||ADE->"+SX3->X3_CAMPO+"}"))) <= Len(aCBoxOption)						
							cBoxValue := aCBoxOption[Val(&("ADE->"+SX3->X3_CAMPO))]	 					
						Else
							cBoxValue := ""	
						EndIf					
						oWFInfo:Header:addField(X3Titulo(), cBoxValue)												
					EndIf					
				EndIf
			EndIf
			DbSkip()	
		End  
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Montagem dos itens do atendimento 	 |
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	 
		DbSelectArea("ADF")
		DbSetOrder(1)
		If DbSeek( xFilial("ADF")+ADE->ADE_CODIGO )	
			While ADF->(!EOF()) .AND.;
				ADF->ADF_CODIGO == ADE->ADE_CODIGO	  
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Verifica se a ocorr๊ncia utilizada na linha ณ
				//ณdo atendimento pode ser exibida pelo cliente ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				lInsertAct := .T.				
				SU9->(DbSetOrder(2))
				If 	!Empty(ADF->ADF_CODSU9) 	.AND.;
					SU9->(DbSeek( xFilial("SU9") + ADF->ADF_CODSU9))
				 
					If SU9->U9_VISIVEL == "2"
						lInsertAct := .F.
					EndIf				
				EndIf				
				If lInsertAct
					oItem := WFItens():new()   	
					DbSelectArea("SX3")
					DbSetOrder(1)
					DbSeek("ADF")
					While !EOF() .AND. SX3->X3_ARQUIVO == "ADF"
						lRetPEIte:=.T.
						If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
							If lTK510LIt
								lRetPEIte:=ExecBlock("TK510LIt",.F.,.F.,SX3->X3_CAMPO)
								lRetPEIte:=IIf(ValType(lRetPEIte)<>"L",.F.,lRetPEIte)
							EndIf 
							If SX3->X3_CONTEXT == "V" .AND. lRetPEIte 				
								If AllTrim(SX3->X3_CAMPO) == "ADF_OBS"			
									oItem:addField(X3Titulo(), MSMM(ADF->ADF_CODOBS,TamSx3("ADF_OBS")[1]))									
								ElseIf	AllTrim(SX3->X3_CAMPO) == "ADF_NMSU9"                              
									oItem:addField(X3Titulo(), POSICIONE("SU9", 2, xFilial("SU9")+ADF->ADF_CODSU9,"U9_DESC"))									
								ElseIf 	AllTrim(SX3->X3_CAMPO) == "ADF_NMSUQ"                              
									oItem:addField(X3Titulo(), POSICIONE("SUQ", 1, xFilial("SUQ")+ADF->ADF_CODSUQ,"UQ_DESC"))									
								Else
									oItem:addField(X3Titulo(), CriaVar(SX3->X3_CAMPO,.T.))									
								EndIf
							Else
								If Empty(SX3->X3_CBOX) .AND. lRetPEIte
									oItem:addField(X3Titulo(), Eval(&("{||ADF->"+SX3->X3_CAMPO+"}"),""))		
								Else
									aCBoxOption	:= TkSx3Box(SX3->X3_CAMPO)													
									If Eval(&("{||ADF->"+SX3->X3_CAMPO+"}")) $ "1234567890" .AND. Val(Eval(&("{||ADF->"+SX3->X3_CAMPO+"}"))) <= Len(aCBoxOption)						
										cBoxValue := aCBoxOption[Val(&("ADF->"+SX3->X3_CAMPO))]	 					
									Else
										cBoxValue := ""	
									EndIf					
									oItem:addField(	X3Titulo(), cBoxValue)												
								EndIf					
							EndIf
						EndIf
						DbSkip()	
					End  	
					ADF->(DbSkip())  
					oWFInfo:addRow(oItem)
				EndIf			
			End					
		EndIf
	Next
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Envio do WorkFlow   |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aWFs) > 0
		oWFTemplate:fillFields(@aWFs[1] , cCodUser, @aWFs )
	EndIf	
	
	For nCount := 1 To Len( aWFs )
		oWFInfo := aWFs[nCount]
		// Se for multiaprova็ใo, serใo enviados vแrios workflows, se jแ foi enviado um, anota o registro de workflow que encabe็a a lista de workflows
		If !Empty(cFirstWFCod) .And. &cAttMemberFn.( oWFInfo, "CLOTEAPR" )
			oWFInfo:cLoteApr := cFirstWFCod
		EndIf
		oWFInfo:start()
		
		If oWFInfo:wfType==WFTYPE_AUTHORIZATION 
			oWFInfo:codeBlockWhenReplied:codeBlock := "TK510LRETWF('" + cCodChamado + "|" + cCodRegra + "|')"			
		EndIf		
		oWFInfo:save()   
		
		// Se for o primeiro workflow anota o id dele
		If Empty(cFirstWFCod) .And. &cAttMemberFn.( oWFInfo, "ID" )
			cFirstWFCod := oWFInfo:id
		EndIf
	Next
EndIf    

RestArea(aAreaADE)
RestArea(aAreaADF)
RestArea(aAreaSU9)
Return lRet        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510RETWF    บAutorณVendas Clientes   บ Data ณ  18/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recebe o retorno do workflow de aprovacao.              	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Function TK510LRETWF()                    
Local cCodigo 	:= ""
Local nPos		:= 0 
Local nPosFim	:= 0
Local lTK510WFRE:= ExistBlock("TK510LWFRE") 
Local cCodResposta := ParamIXB[2]

DbSelectArea("SKW")
nPos := At("TK510LRETWF('", SKW->KW_CODEBLK)
If nPos > 0 
	cCodigo := SubStr(SKW->KW_CODEBLK, nPos+13)
	nPos 	:= At("|", cCodigo)
	nPosFim := RAt("|')", cCodigo)  
	
	If nPos > 0
		cCodRegra :=  SubStr(cCodigo, nPos+1, TamSX3("AGC_COD")[1])
		cCodigo := SubStr(cCodigo, 1, nPos-1)		
		
		conout(STR0014 + cCodigo + STR0015 + cCodRegra + ", KW_CODIGO = " + SKW->KW_CODIGO)        //  "Recebeu o retorno do workflow de Monitora็ใo de Chamados do Service Desk: " ##", Regra: "
		TK510LProcRP(cCodRegra, cCodigo, SKW->KW_AUTORIZ, SKW->KW_EMAIL, SKW->KW_OBS, cCodResposta)	
		
		If lTK510WFRE
			ExecBlock("TK510LWFRE", .F., .F., {cCodigo, SKW->KW_CODIGO})											
		EndIf		
	Else
		cCodigo := ""
		conout(STR0016 + " KW_CODIGO = " + SKW->KW_CODIGO) // "Nใo foi possํvel registrar o retorno do chamado Service Desk."
	EndIf	
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510LProcRP บAutor  ณVendas Clientes  บ Data ณ  16/09/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa a resposta recebida do Workflow de Aprova็ใo.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณService DEsk                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    
Static Function TK510LProcRP(cCodRegra, cCodChamado, cCodResposta, cEmailAprov, cResposta, cKeyResposta)
Local aArea 		:= GetArea()
Local cTipo 		:= "" 
Local cObs			:= ""
Local cCodSU9 		:= ""
Local cCodSU9Def	:= ""
Local lUpdate		:= .F.
Local cHeadSKW		:= ""
Local nAuthStatus	:= ""
Local cMetMemberFn	:= "MethIsMemberOf"

Private INCLUI := .F.
Private ALTERA := .T.

If &cMetMemberFn.( WFTemplate():New(), "GETHEADWF" )  

	If !Empty(SKW->KW_MODELO)
		oWFTemplate := WFTemplate():New()
									
		If oWFTemplate:load(SKW->KW_MODELO)
			cHeadSKW := oWFTemplate:getHeadWF(SKW->KW_CODIGO)
			nAuthStatus := oWFTemplate:authStatus(SKW->KW_CODIGO)
			If nAuthStatus == 1					
				cTipo := RULE_APROVADO  
				cCodSU9Def := "TMK004"
				lUpdate := .T.
			ElseIf nAuthStatus == 2
				cTipo := RULE_REPROVADO
				cCodSU9Def := "TMK005"
				lUpdate := .T.
			ElseIf nAuthStatus == 3
				lUpdate := .F.
			EndIf
			
			cObs := oWFTemplate:getResume( SKW->KW_CODIGO )
		EndIF						
	Else				
		lUpdate := .T.
		If cCodResposta == "1"
			cTipo := RULE_APROVADO  
			cCodSU9Def := "TMK004"
		Else
			cTipo := RULE_REPROVADO
			cCodSU9Def := "TMK005"
		EndIf	
	
		cObs += STR0017 + SKW->KW_EMAIL + CRLF // "E-mail do aprovador: "	                                                                      
		cObs += STR0018 + SKW->KW_OBS //"Comentแrio do aprovador: "
	EndIf
	
	If lUpdate
		DbSelectArea("AGD")        
		DbSetOrder(1)
		If DbSeek( xFilial("AGD")+cCodRegra+cTipo )
			
			While AGD->(!EOF()) .AND.;
				AGD->AGD_COD == cCodRegra .AND.;
				AGD->AGD_TIPO == cTipo
			
				If AGD->AGD_TIPO == RULE_REPROVADO .AND. (!Empty(AGD->AGD_CODRES) .AND. AllTrim(AGD->AGD_CODRES)<>AllTrim(cKeyResposta))
					AGD->(DbSkip())                   
					Loop
				EndIf      
		        
			   	DbSelectArea("ADE")
				DbSetOrder(1)
				DbSeek(xFilial("ADE")+cCodChamado)        
		        
		        If !Empty(AGD->AGD_CODBLK)
			        Eval( &("{||" + AGD->AGD_CODBLK + "}") )
			 	EndIf    
		
				cCodSU9 := cCodSU9Def	 	
			 	If !Empty(AGD->AGD_CODSU9)
			 		cCodSU9 := AGD->AGD_CODSU9	 	 
			 	EndIf        
			 	
				TkUpdCall(	/*cFil*/,;
							AGD->AGD_CODSUQ/*cCodAction*/,;
							/*cCodReview*/,;	
							cObs,;
							/*cTPACAO*/,;	
							TkOperador(),;	
							Posicione("SU7", 1, xFilial("SU7")+TkOperador(), "U7_POSTO"),;		
							"",;
							/*dPrazo*/,;		
							dDatabase,;		
							cCodChamado,;
							cCodSU9)		
				
				AGD->(DbSkip())
			End
		EndIf
	EndIf 

Else
	If cCodResposta == "1"
		cTipo := RULE_APROVADO  
		cCodSU9Def := "TMK004"
	Else
		cTipo := RULE_REPROVADO
		cCodSU9Def := "TMK005"
	EndIf	

	DbSelectArea("AGD")
	DbSetOrder(1)
	If DbSeek( xFilial("AGD")+cCodRegra+cTipo )

		cObs += STR0017 	+ cEmailAprov + CRLF // "E-mail do aprovador: "	                                                                      
		cObs += STR0018 + CRLF + cResposta //"Comentแrio do aprovador: "
	
		While AGD->(!EOF()) .AND.;
			AGD->AGD_COD == cCodRegra .AND.;
			AGD->AGD_TIPO == cTipo
		
	
			If AGD->AGD_TIPO == RULE_REPROVADO .AND. (!Empty(AGD->AGD_CODRES) .AND. AllTrim(AGD->AGD_CODRES)<>AllTrim(cKeyResposta))
				AGD->(DbSkip())                   
				Loop
			EndIf      
        
		   	DbSelectArea("ADE")
			DbSetOrder(1)
			DbSeek(xFilial("ADE")+cCodChamado)        
        
	        If !Empty(AGD->AGD_CODBLK)
		        Eval( &("{||" + AGD->AGD_CODBLK + "}") )
		 	EndIf    

			cCodSU9 := cCodSU9Def	 	
		 	If !Empty(AGD->AGD_CODSU9)
		 		cCodSU9 := AGD->AGD_CODSU9	 	 
		 	EndIf        
	 	
			TkUpdCall(	/*cFil*/,;
						AGD->AGD_CODSUQ/*cCodAction*/,;
						/*cCodReview*/,;	
						cObs,;
						/*cTPACAO*/,;	
						TkOperador(),;	
						Posicione("SU7", 1, xFilial("SU7")+TkOperador(), "U7_POSTO"),;		
						"",;
						/*dPrazo*/,;		
						dDatabase,;		
						cCodChamado,;
						cCodSU9)		
		
			AGD->(DbSkip())
		End
	EndIf
EndIf

RestArea(aArea)
Return Nil                                
