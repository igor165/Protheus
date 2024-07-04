// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 23     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "OFIOM260.ch"
#Include "Protheus.ch"
#include "TopConn.ch"

/*/{Protheus.doc} mil_ver
Versao do fonte modelo novo
@author Andre Luis Almeida
@since 05/11/2017
@version undefined

@type function
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007480_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOM260 ³ Autor ³  Thiago               ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Desbloqueio de pecas                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Pecas                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM260(nTipo)

//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR) 
Local nCntTam  := 0
Private lOk260 := .f.
Private nOrig	:= 1
Private nQtd    := 0
Private cOrigem := space(10)

If nTipo == 1 .or. nTipo == nil //Desbloqueia
	DEFINE MSDIALOG oDlgMsg TITLE STR0001 From 10,30 to 18,75 of oMainWnd //"Desbloqueio de Pecas"
Else
	DEFINE MSDIALOG oDlgMsg TITLE STR0017 From 10,30 to 18,75 of oMainWnd //"Desreserva de Pecas"
EndIf

@ 005,010 SAY STR0005 OF oDlgMsg SIZE 150,030 PIXEL COLOR CLR_BLACK
@ 040,040 BUTTON oContinuar PROMPT OemToAnsi(STR0006) OF oDlgMsg SIZE 40,10 PIXEL ACTION (lOk260 := .t.,oDlgMsg:End())
@ 040,100 BUTTON oCancelar PROMPT OemToAnsi(STR0007) OF oDlgMsg SIZE 40,10 PIXEL ACTION (oDlgMsg:End())

ACTIVATE MSDIALOG oDlgMsg

If lOk260
	
	Private cGrupo  := CriaVar("B1_GRUPO")
	Private cCodIte := CriaVar("B1_CODITE")
	nOrig	:= 2
	nOpca := 0   
	aOrigem := {STR0024,STR0025}  
	
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 000, 000 , .F. , .F. } )
	

	// Fator de reducao de 25%
	for nCntTam := 1 to Len(aSizeAut)
		aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.3)
	next
		
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPos  := MsObjSize (aInfo, aObjects,.F.)

	DEFINE MSDIALOG oDlgDes TITLE STR0001 From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5]     of oMainWnd  PIXEL //"Desbloqueio de Pecas"
	    
	@ aPos[1,1]+021,aPos[1,2]+005 SAY STR0002 OF oDlgDes SIZE 45,10 PIXEL COLOR CLR_BLACK //"Grupo"
	@ aPos[1,1]+021,aPos[1,2]+045 MSGET oGrupo VAR cGrupo PICTURE X3Picture("B1_GRUPO") VALID FS_VLGRUPO() F3 "SBM" SIZE 10,4 OF oDlgDes PIXEL COLOR CLR_BLACK
	
	@ aPos[1,1]+033,aPos[1,2]+005 SAY STR0003 OF oDlgDes SIZE 33,20 PIXEL COLOR CLR_BLACK //"Item"
	@ aPos[1,1]+033,aPos[1,2]+045 MSGET oCodIte VAR cCodIte PICTURE X3Picture("B1_CODITE") VALID FS_VLCODI() F3 "B11" SIZE 100,4 OF oDlgDes PIXEL COLOR CLR_BLACK
	
	@ aPos[1,1]+045,aPos[1,2]+005 SAY STR0004 OF oDlgDes SIZE 33,06 PIXEL COLOR CLR_BLACK //"Quantidade"
	@ aPos[1,1]+045,aPos[1,2]+045 MSGET oQtd VAR nQtd PICTURE X3Picture("D3_QUANT") SIZE 50,4 OF oDlgDes PIXEL COLOR CLR_BLACK

	@ aPos[1,1]+057,aPos[1,2]+005 SAY STR0026 OF oDlgDes SIZE 33,06 PIXEL COLOR CLR_BLACK //"Origem"
	@ aPos[1,1]+057,aPos[1,2]+045 MSCOMBOBOX oOrigem VAR cOrigem SIZE 60,50 ITEMS aOrigem OF oDlgDes PIXEL

	//	    @ 050,040 MSGET oQtd VAR nQtd PICTURE X3Picture("D3_QUANT") VALID (FS_VLQTD(nTipo),IIF(nQtd>=0,.T.,.F.)) SIZE 50,4 OF oDlgDes PIXEL COLOR CLR_BLACK
	//		ACTIVATE MSDIALOG oDlgDes CENTER ON INIT EnchoiceBar(oDlgDes, {|| nOpca := 1,FS_VLQTD(nTipo),IIF(nQtd>=0,.T.,.F.),FS_DESBLQ()} , {|| nOpca := 2,oDlgDes:End() })
	ACTIVATE MSDIALOG oDlgDes CENTER ON INIT EnchoiceBar(oDlgDes, {|| nOpca := 1,IIF(nQtd>=0,.T.,.F.),FS_DESBLQ()} , {|| nOpca := 2,oDlgDes:End() })
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DESBLQ   ³ Autor ³ Thiago              ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Desbloqueia Item Bloqueado                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DESBLQ(nTipo)

Local aMovto1 := {}
Local lOk260 := .f.
Local cAntpar01 := mv_par01
Local nQtdori := 0
Local nQtddest := 0
Local lLimpa := .t.

Local aItemMov    := {}
Local oEst        := DMS_Estoque():New()

if !FS_VLQTD(nTipo,.t.)
	Return
Endif

if cOrigem == STR0024
   cOri := "1"
Else
   cOri := "2"
Endif   
nSoma := 0
dbSelectArea("VE6")
dbSetOrder(7)
if dbSeek(xFilial("VE6")+"2"+cOri+cGrupo+cCodIte)  
   While !Eof() .and. xFilial("VE6") == VE6->VE6_FILIAL .and. "2"+cOri+cGrupo+cCodIte == VE6->VE6_INDREG+VE6->VE6_ORIREQ+VE6->VE6_GRUITE+VE6->VE6_CODITE
      nSoma += VE6->VE6_QTDBLQ    
      dbSelectArea("VE6")
      dbSkip()
   Enddo   
Endif
if nSoma < nQtd    
   if cOri == "1"
	   Msginfo(STR0019+Transform(nQtd,"@E 999,999.99")+STR0020+Transform(nSoma,"@E 999,999.99")+STR0022+".",STR0016)
   Else
	   Msginfo(STR0019+Transform(nQtd,"@E 999,999.99")+STR0020+Transform(nSoma,"@E 999,999.99")+STR0023+".",STR0016)
   Endif   
   Return(.f.)
Endif   

DbSelectArea("SB1")
DbSetOrder(7)
If DbSeek(xFilial("SB1")+cGrupo+cCodIte)
	
	If nOrig == 2 //OFIOM260
		cLocalSai  := GetMv("MV_BLQITE")
		cLocalEnt  := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
		cLOCALI2Sai := GetMv("MV_BLQLOC")
	Else // OFIOM110
		if nTipo == 1 //Desbloqueia
			cLocalSai  := GetMv("MV_BLQITE")
			cLocalEnt  := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
			cLOCALI2Sai := GetMv("MV_BLQLOC")
		Else
			cLocalSai  := GetMv("MV_RESITE")
			cLocalEnt  := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
			cLOCALI2Sai := GetMv("MV_RESLOC")
		Endif
	EndIf
	
	//+---------------------------------------------------------------------+
	//¦Movimentacao interna do Item                                         ¦
	//+---------------------------------------------------------------------+
	aItensNew:={}
	
	DbSelectArea("SB5")
	DbSetOrder(1)
	
	DbSeek( xFilial("SB5") + SB1->B1_COD )
	cLOCALI2Ent := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
	
	if ExistBlock("LOCAOM110")
		cLOCALI2Ent := ExecBlock("LOCAOM110",.f.,.f.,{SB1->B1_COD})
	Endif
	
	cLOCALI2Ent := Alltrim(cLOCALI2Ent)
	cLOCALI2Ent += Space(TamSx3("B5_LOCALI2")[1]-Len(cLOCALI2Ent))
	cLOCALI2Sai := Alltrim(cLOCALI2Sai)
	cLOCALI2Sai += Space(TamSx3("B5_LOCALI2")[1]-Len(cLOCALI2Sai))
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	//
	// Adiciona cabecalho com numero do documento e data da transferencia modelo II
	//
	aadd (aItensNew,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})
    //
	aItemMov := oEst:SetItemSD3(SB1->B1_COD          ,; //Código do Produto
								cLocalSai            ,; // Armazém de Origem
								cLocalEnt            ,; // Armazém de Destino
								cLOCALI2Sai          ,; // Localização Origem
								cLOCALI2Ent          ,; // Localização Destino
								nQtd                  ) // Qtd a transferir

	aAdd(aItensNew, aClone(aItemMov))

	lMsErroAuto	 := .F.
	lMsHelpAuto  := .T.
	
	If (ExistBlock("OM260AP"))
		aItensNew := ExecBlock("OM260AP", .f., .f., {aItensNew})
	EndIf

	MsExecAuto({|x| MATA261(x)},aItensNew)
	If lMsErroAuto
		//MostraErro()
		lLimpa := .f.
		DisarmTransaction()
		mv_par01 := cAntpar01
	Else
		DbSelectArea("SB2")
		DbSetOrder(1)
		If DbSeek(xFilial()+SB1->B1_COD+cLocalSai)
			nQtdori := SB2->B2_QATU
		EndIf
		If DbSeek(xFilial()+SB1->B1_COD+cLocalEnt)
			nQtddest := SB2->B2_QATU
		EndIf 
		
		DEFINE MSDIALOG oDlgFim TITLE STR0001 From 15,30 to 22,60 of oMainWnd //"Desbloqueio de Pecas"
		@ 005,010 SAY STR0010 OF oDlgFim SIZE 150,030 PIXEL COLOR CLR_BLACK
		@ 015,010 SAY STR0008+cLocalSai+": "+CValToChar(nQtdori) OF oDlgFim SIZE 150,030 PIXEL COLOR CLR_BLACK
		@ 025,010 SAY STR0008+cLocalEnt+": "+ CValToChar(nQtddest) OF oDlgFim SIZE 150,030 PIXEL COLOR CLR_BLACK
		@ 037,050 BUTTON oFim PROMPT OemToAnsi(STR0009) OF oDlgFim SIZE 25,15 PIXEL ACTION (mv_par01 := cAntpar01,oDlgFim:End())
		ACTIVATE MSDIALOG oDlgFim
	EndIf    
	if cOrigem == STR0024
	   cOri := "1"
	Else
	   cOri := "2"
	Endif   
    dbSelectArea("VE6")
    dbSetOrder(7)
    if dbSeek(xFilial("VE6")+"2"+cOri+cGrupo+cCodIte)
       While !Eof() .and. xFilial("VE6") == VE6->VE6_FILIAL .and. "2"+cOri+cGrupo+cCodIte == VE6->VE6_INDREG+VE6->VE6_ORIREQ+VE6->VE6_GRUITE+VE6->VE6_CODITE
           
          if VE6->VE6_QTDBLQ > 0
             nQtdReq := VE6->VE6_QTDBLQ-nQtd 
             if nQtdReq < 0
	             nQtd -= VE6->VE6_QTDBLQ  
	             RecLock("VE6",.f.)
	             VE6->VE6_QTDBLQ -= VE6->VE6_QTDBLQ
	             MsUnlock()  
	         Else    
	             RecLock("VE6",.f.)
	             VE6->VE6_QTDBLQ -= nQtd
	             MsUnlock()    
	         Endif     
          Endif
          
          dbSelectArea("VE6")
          dbSkip()
       Enddo   
    
	Endif
	DbSelectArea("SB1")
	DbSetOrder(7)
EndIf

//Limpa as variaveis da tela para evitar deixar saldo negativo
if nQtd<>0 .and. lLimpa
	cGrupo := Space(len(SB1->B1_GRUPO))
	cCodIte := Space(len(SB1->B1_CODITE))
	nQtd := 0
	oGrupo:SetFocus()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VLGRUPO  ³ Autor ³ Thiago              ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao no grupo		                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLGRUPO()

Local lRet := .t.

if !SBM->(DbSeek(xFilial("SBM")+cGrupo))
	lRet := .f.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VLCODI   ³ Autor ³ Thiago              ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao no codigo 		                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLCODI()

Local lRet := FG_POSSB1("cCodIte","SB1->B1_CODITE","cGrupo")

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VLQTD    ³ Autor ³ Thiago              ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao na quantidade	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_VLQTD(nTipo,lMensg)

Local lRet := .f.
Local cLoc := GetMv("MV_BLQITE")
Local nSaldoSB2, nQtdReserva

Default lMensg := .t.
Default nTipo := 1

If nOrig == 1
	if nTipo <> 1 //Desreserva
		cLoc := GetMv("MV_RESITE")
	Endif
EndIf

if cOrigem == STR0024
   cOri := "1"
Else
   cOri := "2"
Endif   
nSoma := 0
dbSelectArea("VE6")
dbSetOrder(7)
if dbSeek(xFilial("VE6")+"2"+cOri+cGrupo+cCodIte)  
   While !Eof() .and. xFilial("VE6") == VE6->VE6_FILIAL .and. "2"+cOri+cGrupo+cCodIte == VE6->VE6_INDREG+VE6->VE6_ORIREQ+VE6->VE6_GRUITE+VE6->VE6_CODITE
      nSoma += VE6->VE6_QTDBLQ    
      dbSelectArea("VE6")
      dbSkip()
   Enddo   
Endif
if nSoma < nQtd    
   if cOri == "1"
	   Msginfo(STR0019+Transform(nQtd,"@E 999,999.99")+STR0020+Transform(nSoma,"@E 999,999.99")+STR0022+".",STR0016)
   Else
	   Msginfo(STR0019+Transform(nQtd,"@E 999,999.99")+STR0020+Transform(nSoma,"@E 999,999.99")+STR0023+".",STR0016)
   Endif   
   Return(.f.)
Endif   
dbSelectArea("SB1")
dbSetOrder(7)
if dbSeek(xFilial("SB1")+cGrupo+cCodIte)
	dbSelectArea("SB2")
	dbSetOrder(1)
	if DbSeek(xFilial("SB2")+SB1->B1_COD+cLoc)
		nSaldoSB2 := SALDOSB2()
		if nQtd <= nSaldoSB2
			lRet := .t.
		ElseIf nSaldoSB2 == 0
			If lMensg
				Msginfo(STR0018,STR0016)
			EndIf
			oQtd:SetFocus()
			lRet:= .f.
		ElseIf nQtd > nSaldoSB2
			If lMensg
				Msginfo(STR0019+Transform(nQtd,"@E 999,999.99")+STR0020+Transform(nSaldoSB2,"@E 999,999.99")+".",STR0016)
			EndIf

			oQtd:SetFocus()
			lRet:= .f.
		Endif
	Else
		Msginfo(STR0021,STR0016)
	Endif
Endif

/*
If !lRet .and. !Empty(cGrupo) .and. !Empty(cCodIte)
Msginfo(STR0015,STR0016)//A quantidade informada é maior que a bloqueada e/ou não existe bloqueio para este item.## Atenção
//Limpa as variaveis da tela para evitar deixar saldo negativo
nQtd := 0
oQtd:SetFocus()
EndIF
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\¿
//³PL Shark - Rubens - 15/10/2009                                                  ³
//³Se for desreservar, verificar se o saldo que ficar pendente no almox. de reserva³
//³é suficiente para suprir todas as reservas automaticas                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\Ù
IF lRet .and. GetNewPar("MV_RITEORC","N") == "S" .and. nTipo <> 1 //Desreserva
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula saldo de reserva em aberto de todas as OS's³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQtdReserva := FM_SALDORESV(cGrupo,cCodIte)
	IF nQtdReserva > (nSaldoSB2 - nQtd)
		MsgInfo(STR0011+" " + cLoc + " " + STR0012 + chr(13) + chr(13) + ;
		STR0013+": " + AllTrim(Str(nQtdReserva)) + chr(13) + ;
		STR0014+": " + AllTrim(Str(nSaldoSB2 - nQtd)) ) //Não é possivel desfazer a reserva, pois o saldo disponível que ficará no almoxarifado ###não atende a todas as reservas de orçamento cadastradas###Saldo necessário###Saldo final almox
		lRet := .f.
	ENDIF
ENDIF

if Empty(cGrupo) .and. Empty(cCodIte)
	lRet:= .t.
EndIF

Return(lRet)

/*----------------------------------------------------
 Suavizar a nova verificação de integração com o WMS
------------------------------------------------------*/
Static Function a261IntWMS(cProduto)
Default cProduto := ""
	If FindFunction("IntWMS")
		Return IntWMS(cProduto)
	Else
		Return IntDL(cProduto)
	EndIf
Return