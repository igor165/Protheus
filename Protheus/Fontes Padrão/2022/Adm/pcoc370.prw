#INCLUDE "pcoc370.ch"
#Include "Protheus.ch"
#include "msgraphi.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออหออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC370  บAutor ณPaulo Carnelossi      บ Data ณ  23/12/05   บฑฑ
ฑฑฬออออออออออุอออออออออสออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta Pre-configurada Cubo Gerencial chamada da rotina deบฑฑ
ฑฑบ          ณdigitacao da planilha orcamentaria - PCOA100                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOC370()
Local aArea := GetArea()
Local aAreaSX2 := SX2->(GetArea())
Local aConsulta := {}
Local cCodigo
Local nPeriodo := 0
Local aPerAux := PcoRetPer()
Local lContinua := .F.

Private aTitSeries := {}

dbSelectArea("SX2")
dbSetOrder(1)
lContinua := dbSeek("AL8") .And. dbSeek("AL9")

RestArea(aAreaSX2)
RestArea(aArea)

If lContinua
	cCodigo := Space(LEN(AL8->AL8_CODIGO))
	If Alltrim(oGd[1]:aHeader[oGd[1]:OBrowse:ColPos][2]) == "AK2_VAL"
	
		C370Carrega(aConsulta)
	    
		If Len(aConsulta) > 0
		
		    If Len(aConsulta)==1
				cCodigo := aConsulta[1, 1]
		    Else
			    cCodigo := C370LstBox(aConsulta)
			EndIf    
		    
		    If !Empty(cCodigo)
				cPeriodo := AllTrim(oGd[1]:aHeader[oGd[1]:OBrowse:ColPos][1])
				nPeriodo := ASCAN(aPerAux, Padr(Subs(cPeriodo,1,8),10)+" - "+Right(cPeriodo,8))
				If nPeriodo > 0
					PCOC370Cons(cCodigo, nPeriodo)
				EndIf
			EndIf
		Else
			nPeriodo := 1
			Aviso(STR0001, STR0002, {"Ok"}) //"Atencao"###"Nao Existem Consultas pre-configuradas"
			
		EndIf	
	
	EndIf
	
	If nPeriodo == 0
		Aviso(STR0001, STR0003, {"Ok"}) //"Atencao"###"Fora do Periodo orcamentario"
	EndIf
Else
	Aviso(STR0001, STR0004, {"Ok"}) //"Atencao"###"Cadastro de Consultas a Cubos Pre-Configurados nao existente!"
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC370Cons  บAutor ณPaulo Carnelossi  บ Data ณ  23/12/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta Pre-configurada Cubo Gerencial passando o codigo e บฑฑ
ฑฑบ          ณnumero periodos a ser processado                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOC370Cons(cCodigo, nPeriodo)
Local aPeriodo := {}
Local aPerCubo
Local aCfgCubo := {}
Local aParametros := {}
Local aPerPla
Local cCodCube
Local cTitCon
Local nQtPeriodo
Local cNivCube
Local nMoeda
Local nX, nY, nZ
Local aMvPar := {}
Local nPerAux
Local aSeqPar := {}
Local lNaoEditPer

aPerPla := PcoRetPer()

dbSelectArea("AL8")
dbSetOrder(1)

cCodigo := PadR(cCodigo, LEN(AL8->AL8_CODIGO))

If dbSeek(xFilial("AL8")+cCodigo)

	cCodCube := AL8->AL8_CUBE
	cTitCon  := AL8->AL8_TITCON
	nQtPeriodo := AL8->AL8_QTPER
    cNivCube := AL8->AL8_NIVEL
    nMoeda := AL8->AL8_MOEDA

	dbSelectArea("AL9")
	dbSetOrder(1)
	If dbSeek(xFilial("AL9")+cCodigo)
		aAdd(aPeriodo, {cCodCube, AL9->AL9_CONFIG, AL8->AL8_TIPSAL, AL9->AL9_FUNCAO, AL9->AL9_TITSER, aClone(aPerPla), aClone(ARRAY(Len(aPerPla))) })
		aFill(aPeriodo[Len(aPeriodo), 7], .F.)
		nZ := 1
	
		While AL9->(!Eof() .And. AL9_FILIAL+AL9_CODIGO+AL9_CUBE == xFilial("AL9")+cCodigo+cCodCube)
		
			aAdd(aCfgCubo, AL9->AL9_CONFIG)
			If !Empty(AL9->AL9_TITSER)
				aAdd(aTitSeries, AL9->AL9_TITSER)
			Else
				aAdd(aTitSeries, STR0005+StrZero(nZ,2)) //"Serie-"
				nZ++
			EndIf	
			For nX := 1 TO nQtPeriodo
				aPerCubo := Pco370RetPer(AL8->AL8_TIPCON, aPerPla)
				aAdd(aPeriodo, {cCodCube, AL9->AL9_CONFIG, AL8->AL8_TIPSAL, AL9->AL9_FUNCAO, AL9->AL9_TITSER,aClone(aPerCubo), aClone(ARRAY(Len(aPerPla))) })
				aFill(aPeriodo[Len(aPeriodo), 7], .F.)

				aPerPla := aClone(aPerCubo)
			Next	

			AL9->(dbSkip())
			
			If AL9->(!Eof())
				aPerPla := aClone(aPeriodo[1,6])
				aAdd(aPeriodo, {cCodCube, AL9->AL9_CONFIG, AL8->AL8_TIPSAL, AL9->AL9_FUNCAO, AL9->AL9_TITSER, aClone(aPerPla), aClone(ARRAY(Len(aPerPla))) })
				aFill(aPeriodo[Len(aPeriodo), 7], .F.)
			EndIf	

		End
	
	EndIf
    
    //montagem da parambox
	aAdd(aParametros,{ 1 ,STR0006, PadR(cCodCube,LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,""  ,"AL1" ,".F." ,25 ,.F. }) //"Cubo Gerencial"
	aAdd(aMvPar, PadR(cCodCube,LEN(AL3->AL3_CODIGO)))

	For nX := 1 To Len(aCfgCubo)

		aAdd(aParametros,{ 1 ,STR0007,PadR(aCfgCubo[nX], LEN(AL3->AL3_CODIGO))		  ,"@!" 	 ,""  ,"AL3" ,".F." ,25 ,.F. }) //"Configuracao Cubo"
		aAdd(aMvPar, PadR(aCfgCubo[nX], LEN(AL3->AL3_CODIGO)))
	    nPerAux := 1

		For nY := 1 TO Len(aPeriodo)

			If aPeriodo[nY, 2] != aCfgCubo[nX]
				Loop
			EndIf
			
			For nZ := 1 TO Len(aPeriodo[nY, 6])
			
				If nZ == 1
					aAdd(aParametros,{4,STR0008+StrZero(nPerAux++,2),(nZ==nPeriodo),Space(2)+aPeriodo[nY, 6, nZ],120,,.F.}) //"Periodo-"
				Else
					aAdd(aParametros,{4,"",(nZ==nPeriodo),Space(2)+aPeriodo[nY, 6, nZ],120,,.F.})
				EndIf
				
				aAdd(aMvPar, (nZ==nPeriodo))

				//guardar posicao p/ armazenar resposta parambox no array aPeriodo 
				aAdd(aSeqPar, { Len(aParametros), { nY, 7, nZ } })
				
			Next //nZ
			
		Next  //nY
		
	Next //nX
	
	lNaoEditPer := ( Len(aParametros) > 99 )
	
	If lNaoEditPer
		Aviso(STR0001, STR0029, {"Ok"}) //"Atencao"###"Quantidade de periodos nao permitida para edicao . Diminua a quantidade de periodos a visualizar."
	EndIf
	
	//parametros da consulta aos cubos historicos
	If AL8->AL8_EDTPER == "2" .Or. lNaoEditPer .Or. ParamBox(  aParametros ,STR0009,aMvPar,,,.F.) //"Saldos Historicos"
	
		//repassa as respostas (aMvPar) para o array aperiodo
        For nX := 1 TO Len(aMvPar)
            nPos := aScan(aSeqPar, {|x| x[1] == nX})
            If nPos > 0
            	aPeriodo[aSeqPar[nPos,2,1],aSeqPar[nPos,2,2],aSeqPar[nPos,2,3]] := aMvPar[nX] 
            EndIf
        Next
        
        //processa os cubos e exibe tela com os resultados
        C370ProcCons(aPeriodo)
        
    EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPcoSaldoHis ณ Autor ณ Paulo Carnelossi   ณ Data ณ07/12/2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao para retorno do saldo historico do cubo gerencial    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณPcoVerSaldo                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PcoSaldoHis(cConfig,cChave)
Local aRetIni,aRetFim
Local nCrdIni
Local nDebIni
Local nCrdFim
Local nDebFim
Local aRetSaldo := {}

//Registro AL8 Correspondente a consulta deve estar posicionado
nMoeda := If(AL8->AL8_MOEDA == 0, 1, AL8->AL8_MOEDA)

aRetIni := PcoRetSld(cConfig,cChave,aDataIniFim[1])
nCrdIni := aRetIni[1, nMoeda]
nDebIni := aRetIni[2, nMoeda]

aRetFim := PcoRetSld(cConfig,cChave,aDataIniFim[2])
nCrdFim := aRetFim[1, nMoeda]
nDebFim := aRetFim[2, nMoeda]

nSldIni := nCrdIni-nDebIni
nSldFim := nCrdFim-nDebFim
nMovCrd := nCrdFim-nCrdIni
nMovDeb := nDebFim-nDebIni

If AL8->AL8_TIPSAL == "1"
	aAdd(aRetSaldo, nMovCrd-nMovDeb) 
ElseIf AL8->AL8_TIPSAL == "2"
	aAdd(aRetSaldo, nSldFim)
Else
	aAdd(aRetSaldo, nMovCrd-nMovDeb) 
	aAdd(aRetSaldo, nSldFim)
EndIf

Return aRetSaldo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPco370RetPer บAutor ณPaulo Carnelossi  บ Data ณ  23/12/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com os periodos a ser processado na consulta  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pco370RetPer(cTpPeriodo, aPerPla)
Local nQtdDias := 0
Local dDataIni, dDataFin
Local aNewPer

dDataIni := CTOD(Subs(aPerPla[1],1,8))
dDataFin := CTOD(Subs(aPerPla[Len(aPerPla)], 10))

If cTpPeriodo == "1"

	nQtdDias := dDataFin - dDataIni
	aNewPer := PcoRetPer(dDataIni-nQtdDias, dDataIni-1)

Else

	dDataIni := CtoD(Subs(DtoC(dDataIni),1,6)+Str(Year(dDataIni)-1))
	dDataFin := CtoD(Subs(DtoC(dDataFin),1,6)+Str(Year(dDataFin)-1))
	aNewPer := PcoRetPer(dDataIni, dDataFin)

EndIf

Return(aNewPer)

Static Function C370LstBox(aConsulta)
Local oDlg, oListBox
Local cCodCons := Space(Len(AL8->AL8_CODIGO))

DEFINE MSDIALOG oDlg FROM 40,168 TO 380,730 TITLE STR0010 Of oMainWnd PIXEL //"Escolha a consulta a ser visualizada"
	
	@ 0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
	oListBox := TWBrowse():New( 10,10,206,152,,{STR0011,STR0012},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //"Codigo"###"Descricao"
	oListBox:SetArray(aConsulta)
	oListBox:bLine := {|| {aConsulta[oListBox:nAT][1],aConsulta[oListBox:nAT][2]}}
	oListBox:bLDblClick := {|| cCodCons:=aConsulta[oListBox:nAT][1],oDlg:End() }
	
	@ 10,230 BUTTON STR0017 SIZE 45 ,10   FONT oDlg:oFont ACTION (cCodCons:=aConsulta[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL   //"Confirma >>"
	@ 25,230 BUTTON STR0018 SIZE 45 ,10   FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //"<< Cancela"
	
	ACTIVATE MSDIALOG oDlg CENTERED


Return (cCodCons)

Static Function C370Carrega(aConsulta)
Local aArea := GetArea()	

dbSelectArea("AL8")
dbSetOrder(1)
dbSeek(xFilial("AL8"))
While AL8->(!Eof() .And. AL8_FILIAL == xFilial("AL8"))
	aAdd(aConsulta, {AL8->AL8_CODIGO, AL8->AL8_TITCON})
	AL8->(dbSkip())
End		

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณC370ProcCons  ณ Autor ณ Paulo Carnelossi ณ Data ณ07/12/2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao que monta os saldos historicos do cubo gerencial     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณC370ConsHist(oGd,  aDatas, aConfig)                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function C370ProcCons(aPeriodo)

Local aArea := GetArea()
Local aAreaAL4 := AL4->(GetArea())
Local cCfgCube, cCodCube
Local aCpoAKDAK2
Local nPosCO  	:= aScan(oGd[1]:aHeader,{|x| AllTrim(x[2]) == "AK2_CO"})
Local bCtaOrc
Local nPosClasse:= aScan(oGd[1]:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})
Local nPosOper	:= aScan(oGd[1]:aHeader,{|x| AllTrim(x[2]) == "AK2_OPER"})
Local nPosCC	:= aScan(oGd[1]:aHeader,{|x| AllTrim(x[2]) == "AK2_CC"})
Local nPosItCtb := aScan(oGd[1]:aHeader,{|x| AllTrim(x[2]) == "AK2_ITCTB"})
Local nPosClVlr := aScan(oGd[1]:aHeader,{|x| AllTrim(x[2]) == "AK2_CLVLR"})
Local nX, nY
Local aFiltro
Local aProcHist
Local aAuxDados  := {}
Local cPeriodo  := ""
Local cExpr, cChaveR, nProc
Local aDescri	:=	{}
Local lDescri	:=	.T.
Private cTpSaldo, aDataIniFim := {,}
Private cConta, aNiveis := {}

If nPosCO == 0 .And. nMvPar == 1
	bCtaOrc := {||(cArquivx)->XK3_CO}
ElseIf nPosCO == 0 .And. nMvPar == 4
	bCtaOrc := {|| oGd2:aCols[oGd2:nAt,  aScan(oGd2:aHeader,{|x| AllTrim(x[2]) == "XK2_CO"})]}
ElseIf nPosCO > 0
	bCtaOrc := {||oGd[1]:aCols[oGd[1]:nAt,  nPosCO]}
Else
	bCtaOrc := {||""}
EndIf	

cConta := Eval(bCtaOrc)

aCpoAKDAK2 := {;
					{"AKD_FILIAL", xFilial("")},;
					{"AKD_STATUS", "2"},;
					{"AKD_LOTE","999999"},;
					{"AKD_ID",StrZero(1,Len(AKD->AKD_ID))},;
					{"AKD_DATA",dDataBase},;
					{"AKD_CO", Eval(bCtaOrc)},;
					{"AKD_CLASSE", If(nPosClasse>0, oGd[1]:aCols[oGd[1]:nAt,  nPosClasse], "")},;
					{"AKD_OPER", If(nPosOper>0, oGd[1]:aCols[oGd[1]:nAt,  nPosOper], "")},;
					{"AKD_TIPO", "1"},;
					{"AKD_TPSALD", "PR"},;
					{"AKD_VALOR1", PcoPlanVal(oGd[1]:aCols[oGd[1]:nAt][oGd[1]:oBrowse:nColPos], oGd[1]:aCols[oGd[1]:nAt,  nPosClasse])},;
					{"AKD_CODPLA", AK1->AK1_CODIGO},;
					{"AKD_VERSAO", AK1->AK1_VERSAO},;
					{"AKD_CC", If(nPosCC>0, oGd[1]:aCols[oGd[1]:nAt,  nPosCC],"")},;
					{"AKD_ITCTB", If(nPosItCtb>0, oGd[1]:aCols[oGd[1]:nAt,  nPosItCtb], "")},;
					{"AKD_CLVLR", If(nPosClVlr>0, oGd[1]:aCols[oGd[1]:nAt,  nPosClVlr], "")};
				}

For nX := 1 TO Len(aCpoAKDAK2)
	SetPrvt("M->"+aCpoAKDAK2[nX,1])
   	nPosCpo := AKD->(FieldPos(aCpoAKDAK2[nX,1]))
   	If nPosCpo > 0
   		&( "M->"+aCpoAKDAK2[nX,1] ) := aCpoAKDAK2[nX,2]
    EndIf
Next

For nX := 1 TO Len(aPeriodo)

	cCodCube := aPeriodo[nX, 1]
	cCfgCube := aPeriodo[nX, 2]  
	cTpSaldo := aPeriodo[nX, 3]
	cTitSer  := aPeriodo[nX, 5]
	
    For nY := 1 TO Len(aPeriodo[nX, 7])
    	If aPeriodo[nX, 7, nY]
    		cPeriodo := Alltrim(aPeriodo[nX, 6, nY])
    		aDataIniFim[1] := CTOD(Left(cPeriodo, 8))
    		aDataIniFim[2] := CTOD(Right(cPeriodo, 8))
    		
    		aAdd(aAuxDados, { cCodCube, cCfgCube, cTpSaldo, aDataIniFim[1], aDataIniFim[2], cTitSer, NIL })
    		aAdd(aAuxDados[Len(aAuxDados)], 0 )
    		If AL8->AL8_TIPSAL == "3"
	    		aAdd(aAuxDados[Len(aAuxDados)], 0 )
    		EndIf

    		aFiltro		:= {}
			dbSelectArea("AKW")
			dbSetOrder(1)
			MsSeek(xFilial()+cCodCube)
			While !Eof() .And. xFilial()+cCodCube == AKW->AKW_FILIAL+AKW->AKW_COD ;
							.And. AKW->AKW_NIVEL <= AL8->AL8_NIVEL
				cExpr := AKW->AKW_CHAVER
				cExpr := StrTran(cExpr, "AKD->", "M->")
				aAdd(aFiltro,&(cExpr))
				//Carregar as descricoes a primeira vez
				If lDescri
					AAdd(aDescri,{Alltrim(AKW->AKW_DESCRI),&(cExpr)})
				Endif   				
				If !Empty(AL8->AL8_NIVEL).And. AL8->AL8_NIVEL==AKW->AKW_NIVEL
					cExpr := AKW->AKW_CONCCH
					cExpr := StrTran(cExpr, "AKD->", "M->")
					cChaveR := &(cExpr)
				EndIf

				dbSkip()
				
			End
			lDescri	:=	.F.			
			If Empty(aPeriodo[nX, 4])
				aProcHist  := PcoRunCube(cCodCube, If(AL8->AL8_TIPSAL!="3", 1, 2), "PcoSaldoHis", cCfgCube, 0,.F.,aNiveis,aFiltro,aFiltro,.T.,/*aCfgAux*/)
			Else
				cFuncUsr := Alltrim(UPPER(aPeriodo[nX, 4]))
				cFuncUsr := If(Left(cFuncUsr,2)!= "U_", "U_"+cFuncUsr, cFuncUsr)
				aProcHist  := PcoRunCube(cCodCube, If(AL8->AL8_TIPSAL!="3", 1, 2), cFuncUsr, cCfgCube, 0,.F.,aNiveis,aFiltro,aFiltro,.T.,/*aCfgAux*/)
			EndIf
			aAuxDados[Len(aAuxDados), 7] := aClone(aProcHist) 

    		nProc := ASCAN(aProcHist, {|aVal| AllTrim(aVal[9]) == AllTrim(cChaveR)})
    		
    		If Len(aProcHist) > 0 .And. nProc > 0
	    		aAuxDados[Len(aAuxDados),8] := aProcHist[nProc, 2, 1]
	    		If AL8->AL8_TIPSAL == "3"
		    		aAuxDados[Len(aAuxDados),9] := aProcHist[nProc, 2, 2]
	    		EndIf
    		EndIf
    		
    	EndIf
    
    Next

Next

C370ListHistorico(aAuxDados,aDescri)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออัออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณC370ListHistoricoบAutorณPaulo Carnelossiบ Data ณ 23/12/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela de consulta para o cubo gerencial pre-configuradoบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C370ListHistorico(aAuxDados,aDescri)
Local oDlg
Local oPanel, aoPanels := {}, aoGraphic := {}
Local aTitle := {STR0013} //"Data Final"
Local aValues
Local nX, nZ
Local aCores := { CLR_HBLUE, CLR_GREEN, CLR_MAGENTA, CLR_HRED, CLR_CYAN}
Local oFontBold
Local nPos

Private aoListBox := {}
Private aAuxVal := {}

If AL8->AL8_CFGSEP == "1"
	//SEPARANDO AS CONFIGURACOES DE CUBOS
	If AL8->AL8_TIPSAL == "1"
		aAdd(aTitle, STR0014) //"Movimentos"
	ElseIf AL8->AL8_TIPSAL == "2"
		aAdd(aTitle, STR0015) //"Saldo Final"
	Else	
		aAdd(aTitle, STR0014) //"Movimentos"
		aAdd(aTitle, STR0015) //"Saldo Final"
	EndIf
	
	ASORT(aAuxDados,,, { |x, y| x[2]+DTOS(x[5]) < x[2]+DTOS(y[5]) })
	
	For nX := 1 TO Len(aAuxDados)
	
		nPos := ASCAN(aAuxVal, {|aVal| aVal[1] == aAuxDados[nX, 1]+aAuxDados[nX, 2] })
		
		If nPos == 0
	    	aAdd(aAuxVal, { aAuxDados[nX, 1]+aAuxDados[nX, 2], {}, {}, {}, {} } )
	    	nPos := Len(aAuxVal)
	    	aAdd(aAuxVal[nPos, 2], { aAuxDados[nX, 5], aAuxDados[nX, 8] } )
			aAdd(aAuxVal[nPos, 3], aAuxDados[nX, 5])
			aAdd(aAuxVal[nPos, 4], aAuxDados[nX, 8])
			aAdd(aAuxVal[nPos, 5], aClone(aAuxDados[nX, 7]))
		
			If AL8->AL8_TIPSAL == "3"
				aAdd(aAuxVal[nPos, 2, Len(aAuxVal[nPos, 2])], aAuxDados[nX, 9])
			EndIf	    	
	    Else
	    	nPos1 := ASCAN(aAuxVal[nPos,2], {|aVal| aVal[1] == aAuxDados[nX, 5] })
	        If nPos1 == 0
	        	aAdd(aAuxVal[nPos, 2], { aAuxDados[nX, 5], aAuxDados[nX, 8] } )
				aAdd(aAuxVal[nPos, 3], aAuxDados[nX, 5])
				aAdd(aAuxVal[nPos, 4], aAuxDados[nX, 8])
				aAdd(aAuxVal[nPos, 5], aClone(aAuxDados[nX, 7]))
		
				If AL8->AL8_TIPSAL == "3"
					aAdd(aAuxVal[nPos, 2, Len(aAuxVal[nPos, 2])], aAuxDados[nX, 9])
				EndIf
            Else
               Aviso(STR0001, STR0016, {"Ok"}) //"Atencao"###"Erro! Nao encontrado periodo nos valores processados."
            EndIf
		EndIf
		
	Next
	
	ASORT(aAuxVal,,, { |x, y| x[1] < y[1] })
	
	DEFINE FONT oFontBold NAME "Arial" SIZE 0, -12 BOLD
	
	DEFINE MSDIALOG oDlg FROM 10,188 TO 480,730 TITLE STR0009 Of oMainWnd PIXEL //"Saldos Historicos"
	
		@ 0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
		//---------------------------------------
		//painel principal
		//---------------------------------------
		oPanel := TScrollBox():new(oDlg,5,5, 290,270,.T.,.T.,.T.)
	
		nTop := 0
		nLeft := 0
		nAltura  := 120
		nCor := 0
	
		For nZ := 1 TO Len(aAuxVal)
			//----------------------------------------
			// Painel com os 
			//----------------------------------------
			aAdd(aoPanels, TScrollBox():new(oPanel,nTop,nLeft, 240, 360,.T.,.T.,.T.))
			
			nCor++
			If nCor > Len(aCores)
		       nCor := 1
		    EndIf
	
		    If nZ == 1   
				TSay():New( 4,  5, MontaBlock("{|| '"+STR0019+Left(aAuxVal[nZ,1],2)+"-"+Alltrim(Posicione("AL1", 1, xFilial("AL1")+Left(aAuxVal[nZ,1],2), "AL1_DESCRI"))+"' }"), aoPanels[Len(aoPanels)] , ,oFontBold,,,,.T.,aCores[nCor])  //"Cubo : "
				TSay():New( 12, 5, MontaBlock("{|| '"+STR0020+" : "+Alltrim(cConta)+"-"+Alltrim(Posicione("AK5", 1, xFilial("AK5")+cConta, "AK5_DESCRI"))+"' }"), aoPanels[Len(aoPanels)] , ,oFontBold,,,,.T.,aCores[nCor]) //"Conta Orcamentaria"
				nCor++
			EndIf	
	
			TSay():New( 25, 50, MontaBlock("{|| '"+STR0021+" : "+Right(aAuxVal[nZ,1],2)+"-"+Alltrim(Posicione("AL3", 1, xFilial("AL3")+Right(aAuxVal[nZ,1],2), "AL3_DESCRI"))+"' }"), aoPanels[Len(aoPanels)] , ,oFontBold,,,,.T.,aCores[nCor])  //"Configuracao Cubo"
	
			//-------------------------------------------------------
	        //listbox com os saldos
			//-------------------------------------------------------
			aAdd(aoListBox, TWBrowse():New( nTop+35,nLeft+5,110,nAltura,,aTitle,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,))
			aValues := aClone(aAuxVal[nZ, 2])
			ASORT(aValues,,, { |x, y| x[1] < y[1] })
			
			aoListBox[Len(aoListBox)]:SetArray(aValues)
		
			If Len(aAuxVal[nZ, 2]) > 0 .And. Len(aAuxVal[nZ, 2, 1]) > 2
	            cExpr := "{|| { aoListBox["+Str(Len(aoListBox),3)+"]:aArray[aoListBox["+Str(Len(aoListBox),3)+"]:nAt,1], Transform(aoListBox["+Str(Len(aoListBox),3)+"]:aArray[aoListBox["+Str(Len(aoListBox),3)+"]:nAt,2],'@E 999,999,999.99'), Transform(aoListBox["+Str(Len(aoListBox),3)+"]:aArray[aoListBox["+Str(Len(aoListBox),3)+"]:nAt,3],'@E 999,999,999.99') }}"
			Else
	            cExpr := "{|| { aoListBox["+Str(Len(aoListBox),3)+"]:aArray[aoListBox["+Str(Len(aoListBox),3)+"]:nAt,1], Transform(aoListBox["+Str(Len(aoListBox),3)+"]:aArray[aoListBox["+Str(Len(aoListBox),3)+"]:nAt,2],'@E 999,999,999.99') }}"
			EndIf  
			aoListBox[Len(aoListBox)]:bLine := MontaBlock(cExpr)
			
         cExpr := "{|| C370ConsCubo( aAuxVal["+Str(Len(aoListBox),3)+", 5, aoListBox["+Str(Len(aoListBox),3)+"]:nAt], "+Str(Len(aoListBox),3)+")}"
			aoListBox[Len(aoListBox)]:bLDblClick := MontaBlock(cExpr)
		
			//----------------------------------------------------
		    //painel com grafico
		    //---------------------------------------------------
			aAdd( aoPanels, TScrollBox():new(oPanel,nTop+35, nLeft+120, nAltura, 140,.T.,.T.,.T.))
		
			aAdd(aoGraphic, NIL)
			@ 0,0 MSGRAPHIC aoGraphic[Len(aoGraphic)] SIZE 180,nAltura-5 OF aoPanels[Len(aoPanels)]
			aoGraphic[Len(aoGraphic)]:Align := CONTROL_ALIGN_ALLCLIENT
			aoGraphic[Len(aoGraphic)]:oFont := oDlg:oFont
		
			aoGraphic[Len(aoGraphic)]:SetMargins( 10, 10, 10, 10 )
			aoGraphic[Len(aoGraphic)]:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
			aoGraphic[Len(aoGraphic)]:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
			aoGraphic[Len(aoGraphic)]:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
			nSerie := aoGraphic[Len(aoGraphic)]:CreateSerie( 4 )
		
			For nx := 1 TO Len(aValues)
				If AL8->AL8_TIPSAL $ "1;2" 
					aoGraphic[Len(aoGraphic)]:Add(nSerie, aValues[nX, 2], DtoC(aValues[nx, 1]), aCores[nCor])
				Else
					If AL8->AL8_COLGRF = "1"
						aoGraphic[Len(aoGraphic)]:Add(nSerie, aValues[nX, 2], DtoC(aValues[nx, 1]), aCores[nCor])
					Else
						aoGraphic[Len(aoGraphic)]:Add(nSerie, aValues[nX, 3], DtoC(aValues[nx, 1]), aCores[nCor])
					EndIf	
				EndIf	
			Next
			
			aoGraphic[Len(aoGraphic)]:l3D := .F.
		    //-----------------------------------------------------------------------
		                               
		
			nTop += 155
	
		Next
		
		@ nTop+2,215 BUTTON STR0022 SIZE 45 ,10   FONT oDlg:oFont ACTION oDlg:End()  OF oPanel PIXEL //"Fechar"
	   	
	ACTIVATE MSDIALOG oDlg CENTERED

Else

	Pcoc370Grade(aAuxDados,aDescri)
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC370Cons_CuboบAutor ณPaulo Carnelossi  บ Data ณ  23/12/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณParametros para drilldown do valor apresentado na grade da  บฑฑ
ฑฑบ          ณconsulta                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function C370ConsCubo(aProcessa, nLstBox)
//OBSERVACAO: DEVE SER FUNCTION POIS E CHAMADO VIA MACRO 

	aSeries := { aTitSeries[nLstBox] }
	PCOC370PFI(aProcessa,1,,4/*nTpGraph*/,aNiveis,1,NIL/*cDescrChv*/,NIL/*cChaveOri*/, aSeries)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC370PFIบAutor  ณPaulo Carnelossi    บ Data ณ  23/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณdrildow dos valores apresentados na consulta ao cubo        บฑฑ
ฑฑบ          ณgerencial pre-configurado                                   บฑฑ
ฑฑบ          ณbaseado na consulta pcoc330PFI                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOC370PFI(aProcessa,nNivel,cChave,nTpGrafico,aNiveis,nCall,cDescrChv,cChaveOri, aTitSeries, nColuna)

Local oDlg 
Local oView
Local oGraphic
Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local nStep
Local dx
Local nSerie
Local cTexto
Local aSize     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aView		:= {}
Local aChave 	:= {}
Local aChaveOri:= {}
Local nNivCub	:= 0
Local nx
Local cDescri	:= ""
Local aButtons
Local	bEncerra := {|| oDlg:End()}
Local aTabMail	:=	{}
Local cFiltro
Local ny
Local nColor := 1
Local aSeries	:= {}
Local nz
Local nQtSeries

DEFAULT cDescrChv := ""
DEFAULT cChave := ""
DEFAULT cChaveOri := ""
DEFAULT nColuna := 1

If nCall+1 <= Len(aNiveis)
	aButtons := {	{"PMSZOOMIN" ,{|| Eval(oView:blDblClick) },STR0023,STR0024},; //"Drilldown do Cubo"###"Drilldown"
						{"BMPPOST" ,{||PmsGrafMail(oGraphic,cDescri,{cCadastro },aTabMail) },STR0025,STR0026 }; //"Enviar Email"###"Email"
					}
Else
	aButtons := {	{"PMSZOOMIN" ,{|| Eval(oView:blDblClick) },STR0023,STR0024},; //"Drilldown do Cubo"###"Drilldown"
						{"BMPPOST" ,{||PmsGrafMail(oGraphic,cDescri,{cCadastro },aTabMail) },STR0025,STR0026 }; //"Enviar Email"###"Email"
					}
EndIf					

nQtSeries := Len(aTitSeries)

For nx := 1 to Len(aProcessa)
	If aProcessa[nx,8] == nNivel .And. (Empty(cChave) .Or. Padr(aProcessa[nx,1],Len(cChave))==cChave)
		cDescri := AllTrim(aProcessa[nx,5])
		aAdd(aView,{Substr(aProcessa[nx,1],Len(cChave)+1),aProcessa[nx,6]})
		For ny := 1 to Len(aProcessa[nx][2])
		    For nZ := 1 TO nQtSeries
				If AL8->AL8_TIPSAL$"1;2"
					aAdd(aView[Len(aView)], aProcessa[nx][2][ny])
				Else
					If nColuna == ny
						aAdd(aView[Len(aView)], aProcessa[nx][2][ny])
					EndIf	
				EndIf
			Next	
		Next	
		aAdd(aChave,{aProcessa[nx,1]})
		aAdd(aChaveOri,{aProcessa[nx,9]})
		aadd(aTabMail,{Substr(aProcessa[nx,1],Len(cChave)+1),aProcessa[nx,6]})
		For ny := 1 to Len(aProcessa[nx][2])
			aAdd(aTabMail[Len(aTabMail)], Alltrim(Str(aProcessa[nx][2][ny])))
		Next	
	EndIf
Next

If !Empty(aView)
	aSize := MsAdvSize(,.F.,400)
	aObjects := {}
	
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10 
	DEFINE MSDIALOG oDlg TITLE cCadastro + " - "+cDescri From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDlg:lMaximized := .T.
	
	
	oPanel := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,10,If(Empty(cDescrChv),0,11+((nNivel-1)*11)),.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel1 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,40,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,120,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM

	
	@ 3,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel2
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 0, 10, 10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )
	
	For nx := 1 TO nQtSeries
		aAdd(aSeries,Nil	)
		aSeries[Len(aSeries)] := oGraphic:CreateSerie( nTpGrafico )
	Next	

	For nx := 1 to Len(aProcessa)
		If aProcessa[nx,8] == nNivel .And. (Empty(cChave) .Or. Padr(aProcessa[nx,1],Len(cChave))==cChave)
			For ny := 1 TO Len(aProcessa[nx][2])
			    For nZ := 1 TO Len(aSeries)
					If AL8->AL8_TIPSAL$"1;2"
						oGraphic:Add(aSeries[nz],aProcessa[nx][2][ny],Substr(aProcessa[nx,1],Len(cChave)+1),C370Cores(ny))
					Else
						If nColuna == ny
							oGraphic:Add(aSeries[nz],aProcessa[nx][2][ny],Substr(aProcessa[nx,1],Len(cChave)+1),C370Cores(ny))
						EndIf	
					EndIf
				Next	
		    Next
		EndIf
	Next
	oGraphic:l3D := .F.

	aTitle 	:= { cDescri, STR0012 } //"Descricao"
	For nx := 1 TO Len(aTitSeries)
		aAdd(aTitle, aTitSeries[nX])
	Next	

	@ 2,4 SAY STR0024 of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)  //"Drilldown"
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST

	@ 12,2   SAY cDescrChv Of oPanel PIXEL SIZE 640 ,79 FONT oBold
	
	oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aTitle,,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)
	oView:Align := CONTROL_ALIGN_ALLCLIENT
	oView:SetArray(aView)
	If nCall+1 <= Len(aNiveis)
		oView:blDblClick := { || PCOC370PFI(aProcessa,aNiveis[nCall+1],aChave[oView:nAT,1],nTpGrafico,aNiveis,nCall+1,IF(!Empty(cDescrChv),cDescrChv+CHR(13)+CHR(10),"")+Str(nNivel,2,0)+". "+Alltrim(cDescri)+" : "+AllTrim(aView[oView:nAT,1])+" - "+AllTrim(aView[oView:nAT,2]),aChaveOri[oView:nAT,1], aTitSeries) }
	EndIf
	oView:bLine := { || aView[oView:nAT]}

	aButtons := AddToExcel(aButtons,{ {"ARRAY",cDescrChv,aTitle,aView} } )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{||Eval(bEncerra)},, aButtons)
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC370Cores บAutor  ณPaulo Carnelossi    บ Data ณ  25/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna cor para montagem do grafico - para cada serie e    บฑฑ
ฑฑบ          ณdefinida uma cor                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C370Cores(nX)
Local	aCores := { CLR_BLUE, ;
					CLR_CYAN, ;
					CLR_GREEN, ;
					CLR_MAGENTA, ;
					CLR_RED, ;
					CLR_BROWN, ;
					CLR_HGRAY, ;
					CLR_LIGHTGRAY, ;
					CLR_BLACK}
If nX < Len(aCores)
	nCor := aCores[nX]
Else
	nCor := C370Cores(nX/Len(aCores))
EndIf

Return nCor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOC370Grade บAutor ณPaulo Carnelossi  บ Data ณ  23/12/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrade consulta quando nao separa no grafico as configuracoesบฑฑ
ฑฑบ          ณde cubo                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOC370Grade(aAuxDados,aDescri)

Local oDlg 
Local oView
Local oGraphic
Local aSize     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aInfo     := {}
Local oPanel, oPanel1, oPanel2   
Local aTamCols	:=	{}

Local aView		:= {}

Local aArea		:= GetArea()
Local nSerie
Local cTexto

Local nx, nz
Local cDescri	:= ""
Local aButtons
Local bEncerra := {|| oDlg:End()}
Local aSeries	:= {}
Local nQtSeries
Local aTitle := {STR0030}

Local aProcAux := {}
Local	cNome		:=	""
Local	cConteudo:=	""

aButtons := {	{"PMSZOOMIN" ,{|| Eval(oView:blDblClick) },STR0023 ,STR0024} }  //"Drilldown do Cubo"###"Drilldown"

For nx := 1 to Len(aAuxDados)
	nPos := ASCAN(aView, {|aVal| aVal[1] == aAuxDados[nX, 5] })
	If nPos == 0
		aAdd(aView, { aAuxDados[nX, 5]} )
		aAdd(aProcAux, aClone({}))
		nPos := Len(aView)
  	EndIf
  	aAdd(aView[nPos]		, aAuxDados[nX, 8])
  	aAdd(aProcAux[nPos]	, aAuxDados[nX, 7])
  	If AL8->AL8_TIPSAL == "3"
  		aAdd(aView[nPos] , aAuxDados[nX, 9] )
   	aAdd(aProcAux[nPos], aAuxDados[nX, 7])
  	EndIf
Next
For nX := 1 To Len(aDescri)
	cNome		+=	"+"+Alltrim(aDescri[nX][1])
	cConteudo+=	If(Empty(aDescri[nX][2]), '+ Todos/as', "+"+Alltrim(aDescri[nX][2]))
Next
cDescri	:=	Substr(cNome,2) + " : " + Substr(cConteudo,2)

If !Empty(aView)
	aSize := MsAdvSize(,.F.,400)
	aObjects := {}
	
	AAdd( aObjects, { 100, 100 , .T., .T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10 
	DEFINE MSDIALOG oDlg TITLE cCadastro + " - "+cDescri From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDlg:lMaximized := .T.
	If Len(aTitSeries)>1
		cDescrChv := aTitSeries[1]
	Else
		cDescrChv := ""
	EndIf	
	oPanel := TPanel():New(20,0,'',oDlg, , .T., .T.,,,10,25,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP

	oPanel1 := TPanel():New(45,0,'',oDlg, , .T., .T.,,,40,40,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel2 := TPanel():New(0,0,'',oDlg, , .T., .T.,,,40,120,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	
	@ 3,2 MSGRAPHIC oGraphic SIZE aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-30 OF oPanel2
	oGraphic:Align := CONTROL_ALIGN_ALLCLIENT
	oGraphic:oFont := oFont
	
	oGraphic:SetMargins( 0, 10, 10,10 )
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetLegenProp( GRP_SCRRIGHT, CLR_WHITE, GRP_SERIES, .F. )

	nQtSeries := Len(aTitSeries)
	For nx := 1 TO nQtSeries
		aAdd(aSeries,Nil	)
		aSeries[Len(aSeries)] := oGraphic:CreateSerie( 4/*nTpGrafico*/ )
	Next	

	For nx := 1 to Len(aView)
		For nz := 1 TO Len(aTitSeries)
		    If AL8->AL8_TIPSAL == "3"
		    	If AL8->AL8_COLGRF == "1"
					oGraphic:Add(aSeries[nz],aView[nx][nz*2],Dtoc(aView[nx][1]),C370Cores(nz))
				Else
					oGraphic:Add(aSeries[nz],aView[nx][nz*2+1],Dtoc(aView[nx][1]),C370Cores(nz))
				EndIf		
			Else
				oGraphic:Add(aSeries[nz],aView[nx][nz+1],Dtoc(aView[nx][1]),C370Cores(nz))
			EndIf	
	    Next
	Next
	oGraphic:l3D := .F.

	For nx := 1 TO Len(aTitSeries)
		If AL8->AL8_TIPSAL == "1"
			aAdd(aTitle, STR0014+"-["+Alltrim(aTitSeries[nX])+"]")   //"Movimentos"
		ElseIf AL8->AL8_TIPSAL == "2"
			aAdd(aTitle, STR0015+"-["+Alltrim(aTitSeries[nX])+"]")  //"Saldo Final"
		ElseIf AL8->AL8_TIPSAL == "3"
			aAdd(aTitle, STR0014+"-["+Alltrim(aTitSeries[nX])+"]")  //"Movimentos"
			aAdd(aTitle, STR0015+"-["+Alltrim(aTitSeries[nX])+"]")  //"Saldo Final"
        EndIf
	Next
	
	@ 2,4 SAY STR0006+" : "+Left(aAuxDados[1,1],2)+"-"+Alltrim(Posicione("AL1", 1, xFilial("AL1")+Left(aAuxDados[1,1],2), "AL1_DESCRI")) of oPanel SIZE 120,9 PIXEL FONT oBold COLOR RGB(80,80,80)  //"Cubo Gerencial"
	@ 3,3 BITMAP oBar RESNAME "MYBAR" Of oPanel SIZE BrwSize(oDlg,0)/2,8 NOBORDER When .F. PIXEL ADJUST
//	@ 12,2   SAY STR0020+" : "+Alltrim(cConta)+"-"+Alltrim(Posicione("AK5", 1, xFilial("AK5")+cConta, "AK5_DESCRI")) Of oPanel PIXEL SIZE 640 ,79 FONT oBold  //"Conta Orcamentaria"
	@ 12,2   SAY cDescri Of oPanel PIXEL SIZE 640 ,79 FONT oBold  //"Conta Orcamentaria"
   For nX:=1 To Len(aTitle)
		Aadd(aTamCols, Len(aTitle[nX]) * 12 )   
   Next
	oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aTitle,aTamCols,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)
  	oView:Align := CONTROL_ALIGN_ALLCLIENT
	oView:SetArray(aView)
	oView:blDblClick := { || C370Cons_Cubo(oView, aView, aProcAux) }
	oView:bLine := { || aView[oView:nAT] }
	
	aButtons := AddToExcel(aButtons,{ {"ARRAY",cDescrChv,aTitle,aView} } )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Eval(bEncerra)},{||Eval(bEncerra)},, aButtons)
	
EndIf

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC370Cons_CuboบAutor ณPaulo Carnelossi  บ Data ณ  23/12/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณParametros para drilldown do valor apresentado na grade da  บฑฑ
ฑฑบ          ณconsulta                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C370Cons_Cubo(oView, aView, aProcAux)
Local aParam := {}
Local aTpSaldo := { STR0014,  STR0015 } //"Movimentos"###"Saldo Final"
Local aProcessa 
Local nColuna 
If AL8->AL8_TIPSAL == "3
	If ParamBox( {	{3,STR0021,1,aTitSeries,130,"",.F.},; //"Configuracao Cubo"
					{3,STR0027,1,aTpSaldo,130,"",.F.} },; //"Tipo de Saldo"
					STR0028,@aParam)  //"Parametros Drilldown"
		aProcessa := aClone(aProcAux[oView:nAt, (aParam[1]*2)-If(aParam[2]==1,1,0)])
		aSeries := {aTitSeries[aParam[1]]}
		nColuna := aParam[2]
		PCOC370PFI(aProcessa,1,,4/*nTpGraph*/,aNiveis,1,NIL/*cDescrChv*/,NIL/*cChaveOri*/, aSeries, nColuna)
	EndIf
Else
	If ParamBox( {	{3,STR0021,1,aTitSeries,130,"",.F.} },; //"Configuracao Cubo"
					STR0028,@aParam)  //"Parametros Drilldown"
		aProcessa := aClone(aProcAux[oView:nAt, aParam[1]])
		aSeries := {aTitSeries[aParam[1]]}
		PCOC370PFI(aProcessa,1,,4/*nTpGraph*/,aNiveis,1,NIL/*cDescrChv*/,NIL/*cChaveOri*/, aSeries)
	EndIf
EndIf	

Return
