#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "LOCXARG.CH"
#INCLUDE "FWBROWSE.CH"

//Array aCfgNf
#Define SnTipo      1
#Define ScCliFor    2
#Define SlFormProp  3
#Define SAliasHead  4
#Define ScEspecie   8
#Define SlRemito   18

#Define _RMCONS 	"A"

Static cPVOld	:= ""
Static cRetOld := ""

/*
±±ºPrograma  ³LDOCORISD  ºAutor  ³Danilo             º Data ³ 07/02/2020  º±±
±±ºDesc.     ³Mostra as faturas que serao amarradas ao documento sendo di-º±±
±±º          ³gitado paras as notas de debito do cliente NDC              º±±
±±º³Parametros³Parametros do array a Rotina:                              º±±
*/
Function LDocOriSd()

Local aArea    		:= GetArea()
Local aSF2			:= SF2->(GetArea())
Local aSD2			:= SD2->(GetArea())
Local aCposF4		:= {}
Local aRecs    		:= {}
Local aRet     		:= {}
Local nI 			:= 0
Local nJ 			:= 0
Local nPosTotal		:= 0
Local nPosTES		:= 0
Local nPosQuant		:= 0
Local nPosQtSegun	:= 0
Local nPosValDesc	:= 0
Local nTaxaNf		:= 0
Local nTaxaPed		:= 0
Local nPorDesc		:= 0
Local nUm			:= 0
Local nSegUm		:= 0
Local nCod			:= 0
Local nLocal		:= 0
Local nQuant		:= 0
Local nNfOri		:= 0
Local nSeriOri		:= 0
Local nItemOri		:= 0
Local nItem			:= 0
Local Tes			:= 0
Local nCf			:= 0
Local nLoteCtl		:= 0
Local nNumLote		:= 0
Local nDtValid		:= 0
Local nVunit		:= 0
Local nTotal		:= 0
Local nQTSegum		:= 0
Local nConta		:= 0
Local nItemCta   	:= 0
Local nCCusto		:= 0
Local nDesc			:= 0
Local nValDesc		:= 0
Local nProvEnt 		:= 0
Local nClVl			:= 0
Local nCliD2		:= 0
Local nLojaD2		:= 0
Local cCampo 		:= ""
Local cCondicao 	:= ""
Local cItem			:= ""
Local cTipoDoc 		:= ""
Local cCliFor		:= M->F2_CLIENTE
Local cLoja  		:= M->F2_LOJA
Local cSeek  		:= ""
Local cWhile 		:= ""
Local cAliasCab		:= ""
Local cAliasItem	:= ""
Local cAliasTRB		:= ""
Local cQuery		:= ""
Local cDoc			:= ""
Local cSerDoc		:= ""
Local cFilSD		:= ""
Local lDescDVIt		:= .T.
Local lD2_PROVENT	:= .F.
Local cFilSB1		:= xFilial("SB1")
Local cFilSD2		:= xFilial("SD2")
Local cFilSF4		:= xFilial("SF4")
Local cDessai		:= SuperGetMV("MV_DESCSAI",.T.,'1')
Local aAreaSF4		:= {}
Local cCentavos		:= Iif(nMoedaNF==1,"MV_CENT",("MV_CENT"+AllTrim(Str(nMoedaNF))))
Local cCtrl			:= CHR(13) + CHR(10)
Local cFunName		:= FunName()
Local cCFO			:= ""

Private aFiltro		:= {}

If Empty(cCliFor) .OR. Empty(cLoja)
	Aviso(cCadastro,STR0006,{STR0001}) //"Complete los datos del encabezado."###"OK"
	Return
EndIf

For nI:=1 to Len(aHeader)
	Do Case
		Case  Alltrim(aHeader[nI][2]) == "D2_UM"
			nUm      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SEGUM"
			nSegUm   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_COD"
			nCod     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOCAL"
			nLocal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QUANT"
			nQuant   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NFORI"
			nNfOri  := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SERIORI"
			nSeriOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEMORI"
			nItemOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEM"
			nItem    := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TES"
			nTes     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CF"
			nCf      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOTECTL"
			nLoteCtl := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NUMLOTE"
			nNumLote := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DTVALID"
			nDtValid := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_PRCVEN"
			nVunit   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TOTAL"
			nTotal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QTSEGUM"
			nQTSegum := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CONTA"
			nConta := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CCUSTO"
			nCCusto := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DESCON"
			nValDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DESC"
			nDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_PROVENT"
			nProvEnt := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEMCC"
			nItemCta := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CLVL"
			nClVl := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CLIENTE"
			nCliD2 := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOJA"
			nLojaD2 := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_UNIADU"
			nUniaduD1 := nI
	Endcase
Next nI
cAliasCab	:= "SF2"
cAliasItem	:= "SD2"
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAliasCab))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAliasCab
	If SX3->X3_BROWSE == "S" .AND. cNivel >= SX3->X3_NIVEL
		AAdd(aCposF4,SX3->X3_CAMPO)
	Endif
	SX3->(DbSkip())
EndDo

If aCfgNF[1] == 2

	cTipoDoc	:= "'01'" //Tipo documento origem 
	cSeek  	:= "'" + xFilial(cAliasCab)+cCliFor+cLoja + "'"
	cWhile 	:= "SF2->(!EOF()) .AND. SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA)== " + cSeek
	cCondicao	:= "Ascan(aFiltro,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_TIPODOC)) > 0"
	cItem		:= aCols[Len(aCols),nItem]

	cAliasTRB := GetNextAlias()
	cQuery := "select distinct D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,D2_TIPODOC,D2_ITEM"
	cQuery += " from " + RetSqlName("SD2") + " SD2 where "
	cQuery += " D2_FILIAL ='" + xFilial("SD2") + "'"
	cQuery += " and D2_CLIENTE = '" + cCliFor + "'"
	cQuery += " and D2_LOJA = '" + cLoja + "'"
	cQuery += " and D2_TIPODOC in (" + cTipoDoc + ")"
	cQuery += " and D2_QUANT > D2_QTDEDEV"
	cQuery += " and SD2.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.F.,.T.)
    DbSelectArea(cAliasTRB)

    While (cAliasTRB)->(!Eof())
    	nI := Ascan(aCols,{|x| x[nNFORI] == (cAliasTRB)->D2_DOC .AND. x[nItemOri] == (cAliasTRB)->D2_ITEM .AND. !x[Len(x)]})
    	If nI == 0
			Aadd(aFiltro, (cAliasTRB)->D2_FILIAL + (cAliasTRB)->D2_DOC + (cAliasTRB)->D2_SERIE + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA + (cAliasTRB)->D2_TIPODOC)
		Endif
		(cAliasTRB)->(DbSkip())
	EndDo
	(cAliasTRB)->(DbCloseArea())
Else
	Return
EndIf

If !Empty(aFiltro)	
	aRet := LocxF4(cAliasCab,2,cWhile,cSeek,aCposF4,,IIf(cTipoDoc =="'50'",GetDescRem(),Iif(cTipoDoc =="'02'", STR0008,STR0007)),cCondicao,.T.,,,,,.F.)  // Retorn ##"Nota de débito" ## "Factura"
Else
	Help(" ",1,"A103F4")
	Return
EndIf
If ValType(aRet)=="A" .AND. Len(aRet)==3
	aRecs := aRet[3]
EndIf
If ValType(aRecs)!="A" .OR. (ValType(aRecs)=="A" .AND. Len(aRecs)==0)
	Return
EndIf
SD2->(DbSetOrder(3))
cFilSD := cFilSD2
ProcRegua(Len(aRecs))

lD2_PROVENT	:=	cPaisLoc == "ARG"
For nI := 1 To Len(aRecs)
	SF2->(MsGoTo(aRecs[nI]))
	SD2->(DbSeek(cFilSD + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
	IncProc("Actualizando ítem " + "(" + SF2->F2_DOC + ")")
	While SD2->D2_FILIAL == cFilSD .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE .AND. SD2->D2_CLIENTE == SF2->F2_CLIENTE .AND. SD2->D2_LOJA == SF2->F2_LOJA
		If SD2->D2_QUANT > SD2->D2_QTDEDEV
        	If Ascan(aCols,{|x| x[nNFORI] == SD2->D2_DOC .AND. x[nItemOri] == SD2->D2_ITEM .AND. !x[Len(x)]}) == 0
				nLenAcols := Len(aCols)
				If !Empty(aCols[nLenAcols,nCod])
					AAdd(aCols,Array(Len(aHeader)+1))
					nLenAcols := Len(aCols)
					cItem := Soma1(cItem)
				Endif
			 	aCols[nLenAcols][Len(aHeader)+1] := .F.
				SB1->(MsSeek(cFilSB1+SD2->D2_COD))
				If (nUm      >  0  ,  aCOLS[nLenAcols][nUm     ] := SD2->D2_UM	,)
				If (nSegUm   >  0  ,  aCOLS[nLenAcols][nSegUm  ] := SB1->B1_SEGUM,)
				If (nCod     >  0  ,  aCOLS[nLenAcols][nCod    ] := SD2->D2_COD,)
				If (nLocal   >  0  ,  aCOLS[nLenAcols][nLocal  ] := SD2->D2_LOCAL,)
				If (nNfOri   >  0  ,  aCOLS[nLenAcols][nNfOri  ] := SD2->D2_DOC,)
				If (nSeriOri >  0  ,  aCOLS[nLenAcols][nSeriOri] := SD2->D2_SERIE,)
				If (nItemOri >  0  ,  aCOLS[nLenAcols][nItemOri] := SD2->D2_ITEM,)
				If (nItem    >  0  ,  aCOLS[nLenAcols][nItem   ] := cItem,)
				If (nConta   >  0  ,  aCOLS[nLenAcols][nConta  ] := SD2->D2_CONTA,)
	   			If (nCCusto  >  0  ,  aCOLS[nLenAcols][nCCusto ] := SD2->D2_CCUSTO,)
			   	If (nItemCta >  0  ,  aCOLS[nLenAcols][nItemCta] := SD2->D2_ITEMCC,)
			   	If (nClVl    >  0  ,  aCOLS[nLenAcols][nClVl]  	:= SD2->D2_CLVL,)
				If (nLoteCtl >  0  ,  aCOLS[nLenAcols][nLoteCtl] := SD2->D2_LOTECTL,)
				If (nNumLote >  0  ,  aCOLS[nLenAcols][nNumLote] := SD2->D2_NUMLOTE,)
				If (nDtValid >  0  ,  aCOLS[nLenAcols][nDtValid] := SD2->D2_DTVALID,)
				If (nQtSegUm >  0  ,  aCOLS[nLenAcols][nQtSegUm] := SD2->D2_QTSEGUM,)
				If (nCliD2   >  0  ,  aCOLS[nLenAcols][nCliD2]   := SD2->D2_CLIENTE,)
				If (nLojaD2  >  0  ,  aCOLS[nLenAcols][nLojaD2]	:= SD2->D2_LOJA,)

				nQtdeDev := SD2->D2_QUANT - SD2->D2_QTDEDEV
				If nQuant > 0
					aCols[nLenAcols,nQuant] := nQtdeDev
				Endif
				If nQtSegUm > 0
					aCols[nLenAcols,nQtSegUm] := ConvUm(SD2->D2_COD,nQtdeDev,0,2)
				Endif
				If nTES <> 0
					aCols[nLenAcols][nTES] := SD2->D2_TES
					aCols[nLenAcols][nCf] := SD2->D2_CF
				EndIf
				nTaxaNF := MaFisRet(,'NF_TXMOEDA')
				nTaxaNF := Iif(nTaxaNF == 0,Recmoeda(dDatabase,M->F1_MOEDA),nTaxaNF)
				If cPaisLoc == "ARG" .And. nProvEnt > 0 .And. lD2_PROVENT
					aCols[nLenAcols,nProvEnt] := SD2->D2_PROVENT
				Endif
				AEval(aHeader,{|x,y| If(aCols[nLenAcols][y]==NIL,aCols[nLenAcols][y]:=CriaVar(x[2]),) })
				MaColsToFis(aHeader,aCols,nLenAcols,"MT100",.T.)
				MaFisAlt("IT_RECORI",SD2->(Recno()),nLenAcols)

			EndIf
		Endif
		SD2->(DbSkip())
	EndDo
Next nI
oGetDados:lNewLine:=.F.
oGetDados:obrowse:refresh()
Eval(bDoRefresh)
AtuLoadQt()
If cPaisLoc == "ARG" 
	MaFisReprocess(2)
EndiF
RestArea(aSD2)
RestArea(aSF2)
RestArea(aArea)

Return

/*
±±ºPrograma  ³ARGNFORIDB  ºAutor  ³Danilo            º Data ³ 08/02/2020  º±±
±±ºDesc.     ³Faz a chamada da Tela de Consulta a NF original             º±±
±±º          ³por item                                                    º±±
*/


Function ARGNFORIDB()

Local bSavKeyF4 := SetKey(VK_F4,Nil)
Local bSavKeyF5 := SetKey(VK_F5,Nil)
Local bSavKeyF6 := SetKey(VK_F6,Nil)
Local bSavKeyF7 := SetKey(VK_F7,Nil)
Local bSavKeyF8 := SetKey(VK_F8,Nil)
Local bSavKeyF9 := SetKey(VK_F9,Nil)
Local bSavKeyF10:= SetKey(VK_F10,Nil)
Local bSavKeyF11:= SetKey(VK_F11,Nil)
Local nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2])=='D2_COD'})
Local nPosLocal := aScan(aHeader,{|x| AllTrim(x[2])=='D2_LOCAL'})
Local nPosTes	:= aScan(aHeader,{|x| AllTrim(x[2])=='D2_TES'})
Local nPLocal	:= aScan(aHeader,{|x| AllTrim(x[2])=='D2_LOCAL'})
Local nRecSD2   := 0
Local lContinua := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua

	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4")+aCols[n][nPosTes])

	If MaFisFound("NF") .And. !Empty(M->F2_CLIENTE) .And. !empty(M->F2_LOJA) //.And. 
		If 	! Empty(aCols[n][nPosCod])
			
			If F4NFORIARG(,,"M->D2_NFORI",M->F2_CLIENTE,M->F2_LOJA,aCols[n][nPosCod],"A465N",aCols[n][nPLocal],@nRecSD2)
				LxA103SD2ToaCols(nRecSD2,n)
			EndIf
		Else
			Help(NIL, NIL, "Item da NF", NIL, "Informar el Producto", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe al producto de la nota para vincular al item"})
		Endif	
	Else
		Help('   ',1,'A103CAB')
	EndIf
Endif
If cPaisLoc == "ARG"
	MaFisReprocess(2)
Endif	
SetKey(VK_F4,bSavKeyF4)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Atualiza o browse de quantidade de produtos.³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
AtuLoadQt(.T.)

Return .T.


/*/
±±ºPrograma  ³F4NfOriArg  ºAutor  ³Danilo             º Data ³ 15/01/2020  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Interface de visualizacao dos documentos de saida            ³±±
±±³          ³que poderão ser vinculados a nota de origem por item         ³±±
±±³Parametros³ExpC1: Nome da rotina chamadora                              ³±±
±±³          ³ExpN2: Numero da linha da rotina chamadora              (OPC)³±±
±±³          ³ExpC4: Nome do campo GET em foco no momento             (OPC)³±±
±±³          ³ExpC5: Codigo do Cliente/Fornecedor                          ³±±
±±³          ³ExpC6: Loja do Cliente/Fornecedor                            ³±±
±±³          ³ExpC7: Codigo do Produto                                     ³±±
±±³          ³ExpC8: Local a ser considerado                               ³±±
±±³          ³ExpN9: Numero do recno do SD1/SD2                            ³±±
/*/
Function F4NfOriArg(cRotina,nLinha,cReadVar,cCliFor,cLoja,cProduto,cPrograma,cLocal,nRecSD2,nRecSD1,dInvDate)

Local aArea     := GetArea()
Local aAreaSF1  := SF1->(GetArea())
Local aAreaSF2  := SF2->(GetArea())
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSD2  := SD2->(GetArea())	
Local aStruTRB  := {}
Local aStruSD1  := {}
Local aStruSD2  := {}
Local aStruSF1  := {}
Local aStruSF2  := {}
Local aValor    := {}
Local aOrdem    := {AllTrim(RetTitle("F2_DOC"))+"+"+AllTrim(RetTitle("F2_SERIE")),AllTrim(RetTitle("F2_EMISSAO"))}
Local aChave    := {}
Local aPesq     := {}
Local aNomInd   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize( .F. )
Local aHeadTRB  := {}
Local aSavHead  := aClone(aHeader)
Local cAliasSD2 := "SD2"
Local cAliasSF2 := "SF2"
Local cAliasSF4 := "SF4"
Local cAliasTRB := "F4NFORI"
Local cNomeTrb  := ""
Local cQuery    := ""
Local cCombo    := ""
Local cTexto1   := ""
Local cTexto2   := ""
Local lRetorno  := .F.
Local lSkip     := .F.
Local cTpCliFor := "C"
Local nX        := 0
Local nY        := 0
Local nSldQtd   := 0
Local nSldQtd2  := 0
Local nSldLiq   := 0
Local nSldBru   := 0
Local nHdl      := GetFocus()
Local nOpcA     := 0
Local nPNfOri   := 0
Local nPSerOri  := 0
Local nPItemOri := 0
Local nPLocal   := 0
Local nPPrUnit  := 0
Local nPPrcVen  := 0
Local nPQuant   := 0
Local nPQuant2UM:= 0
Local nPLoteCtl := 0
Local nPNumLote := 0
Local nPDtValid := 0
Local nPPotenc  := 0
Local nPValor   := 0
Local nPValDesc := 0
Local nPDesc    := 0
Local nPOrigem  := 0
Local nPDespacho:= 0
Local nPTES     := 0
Local nPCf		:= 0
Local nPProvEnt := 0
Local nPConcept := 0
Local nD1Fabric := 0
Local nPPeso	:= 0
Local nFciCod   := 0
Local nPCC      := 0 // Posición Centro de Costo
Local xPesq     := ""
Local oDlg
Local oCombo
Local oGet
Local oGetDb
Local oPanel
Local cFiltraQry:=""
Local lFiltraQry:=ExistBlock('F4NFORI')
Local lUsaNewKey:= TamSX3("F2_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
Local lDescSai  := IIF(cPaisLoc == "BRA",SuperGetMV("MV_DESCSAI",.F.,"2"),SuperGetMV("MV_DESCSAI",.F.,"1")) == "1"
Local cCtrl     := CHR(13) + CHR(10) // Salto de línea para los UUID Relacionados
Local cPreSD        := ""

Local nMoedaOri := 0
Local nMdaConv := 0
Local nTotalOri := 0
Local nTtalConv := 0

DEFAULT cReadVar := ReadVar()
DEFAULT dInvDate := dDataBase

PRIVATE aRotina  := {}

For nX := 1 To 11	// Walk_Thru
	aAdd(aRotina,{"","",0,0})
Next

If ("_NFORI"$cReadVar) .Or. ( lUsaNewKey .And. ("_SERIORI"$cReadVar .Or. "_ITEMORI"$cReadVar )  )
	
	cTpCliFor := "C"
	aChave    := {"D2_DOC+D2_SERIE","D2_EMISSAO"}
	aPesq     := {{Space(Len(SD2->D2_DOC+SD2->D2_SERIE)),"@!"},{Ctod(""),"@!"}}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do arquivo temporario dos itens do SD2                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SD2")
	While !Eof() .And. SX3->X3_ARQUIVO == "SD2"
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
			Trim(SX3->X3_CAMPO) <> "D2_COD" .And.;
				SX3->X3_CONTEXT <> "V"  .And.;
				SX3->X3_TIPO<>"M" ) .Or.;
				Trim(SX3->X3_CAMPO) == "D2_DOC" .Or.;
				Trim(SX3->X3_CAMPO) == "D2_SERIE"  .Or.;
				Trim(SX3->X3_CAMPO) == "D2_EMISSAO" .Or.;
				Trim(SX3->X3_CAMPO) == "D2_TIPO" .Or.;
				Trim(SX3->X3_CAMPO) == "D2_PRUNIT" .Or. ;
				Trim(SX3->X3_CAMPO) == "D2_DESCZFR"
				Aadd(aHeadTrb,{ TRIM(X3Titulo()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					SX3->X3_VALID,;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_ARQUIVO,;
					SX3->X3_CONTEXT,;
					IIf(AllTrim(SX3->X3_CAMPO)$"D2_DOC#D2_SERIE#D2_ITEM#D2_TIPO","00",SX3->X3_ORDEM) })
				aadd(aStruTRB,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,IIf(AllTrim(SX3->X3_CAMPO)$"D2_DOC#D2_SERIE#D2_ITEM","00",SX3->X3_ORDEM)})
		EndIf				
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Walk-Thru                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	ADHeadRec("SD2",aHeadTrb)
	aSize(aHeadTrb[Len(aHeadTrb)-1],11)
	aSize(aHeadTrb[Len(aHeadTrb)],11)
	aHeadTrb[Len(aHeadTrb)-1,11] := "ZX"
	aHeadTrb[Len(aHeadTrb),11]	 := "ZY"
	aadd(aStruTRB,{"D2_ALI_WT","C",3,0,"ZX"})
	aadd(aStruTRB,{"D2_REC_WT","N",18,0,"ZY"})
	aadd(aStruTRB,{"D2_TOTAL2","N",18,2,"ZZ"})
	aHeadTrb := aSort(aHeadTrb,,,{|x,y| x[11] < y[11]})
	aStruTrb := aSort(aStruTrb,,,{|x,y| x[05] < y[05]})

	cNomeTrb := FWOpenTemp(cAliasTRB,aStruTRB,,.T.)
	dbSelectArea(cAliasTRB)
	For nX := 1 To Len(aChave)
		aAdd( aNomInd , StrTran( (SubStr( cNomeTrb, 1 , 7 ) + Chr( 64 + nX ) ), "_" , "") )
		IndRegua(cAliasTRB,aNomInd[nX],aChave[nX])
	Next nX
	dbClearIndex()
	For nX := 1 To Len(aNomInd)
		dbSetIndex(aNomInd[nX])
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao do arquivo temporario com base nos itens do SD2         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFiltraQry
		cFiltraQry	:=	ExecBlock('F4NFORI',.F.,.F.,{"SD2",cPrograma,cClifor,cLoja})
		If ValType(cFiltraQry) <> 'C'
			cFiltraQry	:=	''
		Endif	
	Endif
	dbSelectArea("SF2")
	dbSetOrder(2)

	cAliasSF2 := "F4NFORI_SQL"
	cAliasSD2 := "F4NFORI_SQL"			    
	cAliasSF4 := "F4NFORI_SQL"			    			    
	aStruSF2 := SF2->(dbStruct())
	aStruSD2 := SD2->(dbStruct())
	cQuery := "SELECT SF4.F4_PODER3,SD2.R_E_C_N_O_ SD2RECNO,"
	cQuery += "SF2.F2_FILIAL,SF2.F2_CLIENTE,SF2.F2_LOJA,"
	cQuery += "SF2.F2_TIPO,SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_FILIAL,SD2.D2_COD,"
	cQuery += "SD2.D2_TIPO,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_FILIAL,SD2.D2_CLIENTE,"
	cQuery += "SD2.D2_LOJA,SD2.D2_QTDEDEV,SD2.D2_VALDEV,SD2.D2_ORIGLAN,SD2.D2_TES,SD2.D2_TIPOREM "
	cQuery += ",SD2.D2_TIPODOC "

	For nX := 1 To Len(aStruTRB)
		If !"D2_REC_WT"$aStruTRB[nX][1] .And. !"D2_ALI_WT"$aStruTRB[nX][1] .And. !"D2_TOTAL2"$aStruTRB[nX][1]
			cQuery += ","+aStruTRB[nX][1]
		EndIf
	Next nX
	cQuery += " FROM "+RetSqlName("SF2")+" SF2,"
	cQuery +=  RetSqlName("SD2")+" SD2,"
	cQuery +=  RetSqlName("SF4")+" SF4 "
	cQuery += "WHERE " 
	cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
	cQuery += "SF2.F2_CLIENTE = '"+cCliFor+"' AND "
	cQuery += "SF2.F2_LOJA = '"+cLoja+"' AND "
	cQuery += "SF2.D_E_L_E_T_=' ' AND "
	cQuery += "SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
	cQuery += "SD2.D2_CLIENTE=SF2.F2_CLIENTE AND "
	cQuery += "SD2.D2_LOJA=SF2.F2_LOJA AND "
	cQuery += "SD2.D2_DOC=SF2.F2_DOC AND "
	cQuery += "SD2.D2_SERIE=SF2.F2_SERIE AND "        
	cQuery += "SD2.D2_TIPO=SF2.F2_TIPO AND "
	If IsInCallStack("Documentos") .And. Type("cTipo") == "U"
		cTipo := SDS->DS_TIPO
	EndIf

	cQuery += "F2_TIPO not in('B','D','C') AND " // Tipo da nota de saida		
	cQuery += "SD2.D2_COD='"+cProduto+"' AND "
	cQuery += "SD2.D2_ORIGLAN<>'LF' AND "
	cQuery += "SD2.D_E_L_E_T_=' ' AND "
	cQuery += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "	
	cQuery += "SF4.F4_CODIGO=SD2.D2_TES AND "
	cQuery += "SF4.D_E_L_E_T_=' ' "
	cQuery += "	AND	SF2.F2_EMISSAO <= '" + DTOS(dInvDate) + "' "		
	If !Empty(cFiltraQry)
		cQuery += " AND "+cFiltraQry
	Endif
	cQuery += "ORDER BY "+SqlOrder(SF2->(IndexKey()))
			
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)
						
	For nX := 1 To Len(aStruSD2)
		If aStruSD2[nX][2] <> "C" 
			TcSetField(cAliasSF2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
		EndIf				
	Next nX
	For nX := 1 To Len(aStruSF2)
		If aStruSF2[nX][2] <> "C" 
			TcSetField(cAliasSF2,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
		EndIf				
	Next nX				

	While !Eof() .And. (cAliasSF2)->F2_FILIAL = xFilial("SF2") .And.;
		(cAliasSF2)->F2_CLIENTE == cCliFor .And.;
		(cAliasSF2)->F2_LOJA == cLoja
		lSkip := .F.
		While !Eof() .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
			cProduto == (cAliasSD2)->D2_COD .And.;
			(cAliasSF2)->F2_DOC == (cAliasSD2)->D2_DOC .And.;
			(cAliasSF2)->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
			(cAliasSF2)->F2_CLIENTE == (cAliasSD2)->D2_CLIENTE .And.;
			(cAliasSF2)->F2_LOJA == (cAliasSD2)->D2_LOJA
					
			If (cAliasSD2)->D2_TIPO ==(cAliasSF2)->F2_TIPO .And. ( (cAliasSF4)->F4_PODER3 == "N" .Or. ((cAliasSF4)->F4_PODER3 == "R" .And. (cAliasSD2)->D2_TIPOREM == "A")) .And. !Empty((cAliasSD2)->D2_TES) .And. (cAliasSD2)->D2_ORIGLAN<>"LF" .And. (cAliasSD2)->D2_TIPO<>"D"
												
	      		If Empty(cFiltraQry) .Or. ValType(cFiltraQry) == "C"
	         		If (cAliasSD2)->D2_TIPODOC < "50"
						nSldQtd:= (cAliasSD2)->D2_QUANT-(cAliasSD2)->D2_QTDEDEV
						nSldQtd2:=ConvUm((cAliasSD2)->D2_COD,nSldQtd,0,2)
						nSldBru:= (cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)-(cAliasSD2)->D2_VALDEV
						nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_NFORI"})
						nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_SERIORI"})
						nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="D2_ITEMORI"})
						nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_TOTAL"})
						nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_QUANT"})
						nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_QTSEGUM"})

						For nX := 1 To Len(aCols)
							If nX <> N .And.;
								!aCols[nX][Len(aHeader)+1] .And.;
								aCols[nX][nPNfOri] == (cAliasSD2)->D2_DOC .And.;
								aCols[nX][nPSerOri] == (cAliasSD2)->D2_SERIE .And.;
								aCols[nX][nPItemOri] == (cAliasSD2)->D2_ITEM
								nSldQtd -= aCols[nX][nPQuant]
								nSldBru -= aCols[nX][nPValor]
							EndIf
						Next nX
						nSldQtd2:=ConvUm((cAliasSD2)->D2_COD,nSldQtd,0,2)
						nSldLiq:= nSldBru-A410Arred(nSldBru*((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)/((cAliasSD2)->D2_TOTAL+((cAliasSD2)->D2_DESCON+(cAliasSD2)->D2_DESCZFR)),"C6_VALOR")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o arquivo de trabalho                                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nSldQtd <> 0 .Or. nSldLiq <> 0
							RecLock(cAliasTRB,.T.)
							For nX := 1 To Len(aStruTRB)
								If !(AllTrim(aStruTRB[nX][1]) $ "D2_ALI_WT|D2_REC_WT|D2_TOTAL2")
									(cAliasTRB)->(FieldPut(nX,(cAliasSD2)->(FieldGet(FieldPos(aStruTRB[nX][1])))))
								EndIf	
							Next nX
							(cAliasTRB)->D2_QUANT := a410Arred(nSldQtd,"C6_QTDVEN")
							(cAliasTRB)->D2_QTSEGUM:= a410Arred(nSldQtd2,"C6_UNSVEN")
							(cAliasTRB)->D2_TOTAL := a410Arred(nSldLiq,"C6_VALOR")
							(cAliasTRB)->D2_TOTAL2:= a410Arred(nSldBru,"C6_VALOR")
							(cAliasTRB)->D2_PRCVEN:= a410Arred(nSldLiq/IIf(nSldQtd==0,1,nSldQtd),"C6_PRCVEN")
							If Abs((cAliasTRB)->D2_PRCVEN-(cAliasSD2)->D2_PRCVEN)<= 0.01
								(cAliasTRB)->D2_PRCVEN := (cAliasSD2)->D2_PRCVEN
							EndIf
							(cAliasTRB)->D2_PRUNIT := (cAliasTRB)->D2_PRCVEN
							(cAliasTRB)->D2_REC_WT:= (cAliasSD2)->SD2RECNO
							(cAliasTRB)->D2_ALI_WT := "SD2"
							MsUnLock()
						EndIf
					EndIf
		  		EndIf
			Endif
			dbSelectArea(cAliasSD2)
			dbSkip()
			lSkip := .T.
		EndDo
		If !lSkip
			dbSelectArea(cAliasSF2)
			dbSkip()
		EndIf
	EndDo
	
	(cAliasSF2)->(dbCloseArea())
						
	cPreSD := IIf(cTpCliFor == "C", "D2", "D1")
	If (cAliasTRB)->(LastRec())<>0
		PRIVATE aHeader := aHeadTRB
		xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona registros                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSetOrder(1)
		MsSeek(xFilial("SA1")+cCliFor+cLoja)

		dbSelectArea("SB1")
		dbSetOrder(1)
		MsSeek(xFilial("SB1")+cProduto)
		
		dbSelectArea(cAliasTRB)
		dbGotop()	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula as coordenadas da interface                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize[1] /= 1.5
		aSize[2] /= 1.5
		aSize[3] /= 1.5
		aSize[4] /= 1.3
		aSize[5] /= 1.5
		aSize[6] /= 1.3
		aSize[7] /= 1.5
		
		AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
		AAdd( aObjects, { 100, 060,.T.,.T.} )
		AAdd( aObjects, { 100, 020,.T.,.F.} )
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
		aPosObj := MsObjSize( aInfo, aObjects,.T.)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Interface com o usuario                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Notas Fiscais de Origem"
		@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED
		cTexto1 := AllTrim(RetTitle("F2_CLIENTE"))+"/"+AllTrim(RetTitle("F2_LOJA"))+": "+SA1->A1_COD+"/"+SA1->A1_LOJA+"  -  "+RetTitle("A1_NOME")+": "+SA1->A1_NOME
		@ 002,005 SAY cTexto1 SIZE aPosObj[1,3],008 OF oPanel PIXEL
		cTexto2 := AllTrim(RetTitle("B1_COD"))+": "+SB1->B1_COD+"/"+SB1->B1_DESC
		@ 012,005 SAY cTexto2 SIZE aPosObj[1,3],008 OF oPanel PIXEL	
		
		@ aPosObj[3,1]+00,aPosObj[3,2]+00 SAY OemToAnsi(STR0009) PIXEL //"Buscar por: "
		@ aPosObj[3,1]+12,aPosObj[3,2]+00 SAY OemToAnsi(STR0010) PIXEL //Localizar
		@ aPosObj[3,1]+00,aPosObj[3,2]+40 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 100,044 OF oDlg PIXEL ;
		VALID ((cAliasTRB)->(dbSetOrder(oCombo:nAt)),(cAliasTRB)->(dbGotop()),xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1],.T.)
	  	@ aPosObj[3,1]+12,aPosObj[3,2]+40 MSGET oGet VAR xPesq Of oDlg PICTURE aPesq[(cAliasTRB)->(IndexOrd())][2] PIXEL ;
	  	VALID ((cAliasTRB)->(MsSeek(Iif(ValType(xPesq)=="C",AllTrim(xPesq),xPesq),.T.)),.T.).And.IIf(oGetDb:oBrowse:Refresh()==Nil,.T.,.T.)
	  	
	  	oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,"Allwaystrue","allwaystrue","",.F., , ,.F., ,cAliasTRB)
		
		DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION (nOpcA := 0, oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
		
		If nOpcA == 1
			lRetorno := .T.
			aHeader   := aClone(aSavHead)
				 
			nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_NFORI"})
			nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_SERIORI"})
			nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="D2_ITEMORI"})
			nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_LOCAL"})
			nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_PRCVEN"})
			nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_QUANT"})
			nPQuant2UM:= aScan(aHeader,{|x| AllTrim(x[2])=="D2_QTSEGUM"})
			nPLoteCtl := aScan(aHeader,{|x| AllTrim(x[2])=="D2_LOTECTL"})
			nPNumLote := aScan(aHeader,{|x| AllTrim(x[2])=="D2_NUMLOTE"})
			nPDtValid := aScan(aHeader,{|x| AllTrim(x[2])=="D2_DTVALID"})
			nPPotenc  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_POTENCI"})
			nPValor   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_TOTAL"})
			nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="D2_TES"})
			nPCf     := aScan(aHeader,{|x| AllTrim(x[2])=="D2_CF"})
			nPProvEnt := aScan(aHeader,{|x| AllTrim(x[2])=="D2_PROVENT"})
			nPConcept := aScan(aHeader,{|x| AllTrim(x[2])=="D2_CONCEPT"})
					
			If nPNfOri <> 0
 				aCols[N][nPNfOri] := (cAliasTRB)->D2_DOC
 			EndIf
 			If nPSerOri <> 0
 				aCols[N][nPSerOri] := (cAliasTRB)->D2_SERIE
 			EndIf
			If nPItemOri <> 0
 				aCols[N][nPItemOri] := (cAliasTRB)->D2_ITEM
			EndIf
			If nPLocal <> 0
 				aCols[N][nPLocal] := (cAliasTRB)->D2_LOCAL
 			EndIf
 			If nPQuant <> 0
				aCols[N][nPQuant] := (cAliasTRB)->D2_QUANT
			EndIf
			If nPQuant2UM <> 0
				aCols[N][nPQuant2UM] := (cAliasTRB)->D2_QTSEGUM
			EndIf
			If nPConcept <> 0 
	 			aCols[N][nPConcept] := (cAliasTRB)->D2_CONCEPT
	 		Endif
			If nPLoteCtl <> 0
				aCols[N][nPLoteCtl] := (cAliasTRB)->D2_LOTECTL
			EndIf
			If nPNumLote <> 0
				aCols[N][nPNumLote] := (cAliasTRB)->D2_NUMLOTE
			EndIf
			If nPDtValid <> 0 .Or. npPotenc <> 0
				dbSelectArea("SB8")
				dbSetOrder(3)
				If MsSeek(xFilial("SB8")+cProduto+aCols[N][nPLocal]+aCols[n][nPLoteCtl]+IIf(Rastro(cProduto,"S"),aCols[N][nPNumLote],""))
					If nPDtValid <> 0
						aCols[n][nPDtValid] := SB8->B8_DTVALID
					EndIf
					If npPotenc <> 0	
						aCols[n][nPPotenc] := SB8->B8_POTENCI
					EndIf
				EndIf
			EndIf
			If nPProvEnt <> 0 
		 		aCols[N][nPProvEnt] := (cAliasTRB)->D2_PROVENT
		 	Endif

			If ("_NFORI"$cReadVar)
				&(cReadVar) := (cAliasTRB)->D2_DOC
			EndIf

			If ("_SERIORI"$cReadVar)
				&(cReadVar) := (cAliasTRB)->D2_SERIE
			EndIf

			If ("_ITEMORI"$cReadVar)
				&(cReadVar) := (cAliasTRB)->D2_ITEM
			EndIf
					
			nRecSD2	:= (cAliasTRB)->D2_REC_WT
				
		EndIf
	Else
		HELP(" ",1,"F4NAONOTA")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integridade da rotina                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasTRB)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ARQUIVO TEMPORARIO DE MEMORIA (CTREETMP)                            ³
	//³A funcao MSCloseTemp ira substituir a linha de codigo abaixo:       ³
	//|--> dbCloseArea()                                                   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	FWCloseTemp(cAliasTRB,cNomeTrb)
EndIf
dbSelectArea("SA1")
RestArea(aArea)
SetFocus(nHdl)
Return(lRetorno)

/*Se agregan las siguientes funciones: 
  UpdValImp(), ValCposRG3668(), LocxChkCB(), GetNumCFis(), LocXTipSer() y LocxSELCLI()
  tomadas de la LOCXNF, por tema de espacio en el fuente se mueven. 
*/   
/*Funcion Upd2ValImp usada para validacion de tamano de campos y actualizacion a usado*/
Function Upd2ValImp()
Local aAlqImp  := {"1","2","3","4","5","6"}
Local nX       := 1
Local aDados   := {}
Local cUsado   := ""
Local cPicture := ""
Local nTamanho := ""
Local cMsg     := ""
Local cSalto   := Chr(10) + Chr(13)

Return


Function ValCpoRG3668()
Local lRet    := .T.
Local lValida := .F.
Local cFunName := IIf(Type("cFunName")=="U" .Or.  ValType(cFunName) <> "C"  ,Upper(Alltrim(FunName())),cFunName)
Local lFunc   := (cFunName $ "MATA467N|MATA465N|MATA468N")
Local nI      := 0
Local cMv3668 := SuperGetMV("MV_CFO3668",.T.,"")
	Do case
		Case (cPaisLoc <> "ARG" .or. (cPaisLoc == "ARG" .and. (Empty(cMv3668) .or. Alltrim(cSerie) <> "A")) .or. lFunc == .F.)
			Return lRet
			Case !Empty(cMv3668)
			For nI := 1 To Len(aCols)
				If Alltrim(MaFisRet(nI,"IT_CF")) $ cMv3668 .AND. !MaFisRet(nI,"IT_DELETED")
					lValida := .T.
					exit
				Endif
			Next
	Endcase
	If aCfgNF[SAliasHead] == "SF1" .and. lValida == .T.
		If !((Empty(M->F1_ADIC5) .And. Empty(M->F1_ADIC61) .And. Empty(M->F1_ADIC62) .And. Empty(M->F1_ADIC7)) .Or.;
			(!Empty(M->F1_ADIC5) .And. !Empty(M->F1_ADIC61) .And. !Empty(M->F1_ADIC62) .And. !Empty(M->F1_ADIC7)))
				Aviso( OemToAnsi(STR0002), OemToAnsi(STR0005), {STR0001} )
				lRet := .F.
		ElseIf !Empty(AI0->AI0_DESDE) .And. !Empty(AI0->AI0_HASTA)
			If M->F1_EMISSAO < AI0->AI0_DESDE .Or. M->F1_EMISSAO > AI0->AI0_HASTA
				Aviso( OemToAnsi(STR0002), OemToAnsi(STR0003), {STR0001} )
				lRet := .F.
			EndIf
		Else
			Aviso( OemToAnsi(STR0002), OemToAnsi(STR0004), {STR0001} )
			lRet := .F.
		EndIf
	ElseIf aCfgNF[SAliasHead] == "SF2" .and. lValida == .T.
		If !((Empty(M->F2_ADIC5) .And. Empty(M->F2_ADIC61) .And. Empty(M->F2_ADIC62) .And. Empty(M->F2_ADIC7)) .Or.;
			(!Empty(M->F2_ADIC5) .And. !Empty(M->F2_ADIC61) .And. !Empty(M->F2_ADIC62) .And. !Empty(M->F2_ADIC7)))
				Aviso( OemToAnsi(STR0002), OemToAnsi(STR0005), {STR0001} )
				lRet := .F.
		ElseIf !Empty(AI0->AI0_DESDE) .And. !Empty(AI0->AI0_HASTA)
			If M->F2_EMISSAO < AI0->AI0_DESDE .Or. M->F2_EMISSAO > AI0->AI0_HASTA
				Aviso( OemToAnsi(STR0002), OemToAnsi(STR0003), {STR0001} )
				lRet := .F.
			EndIf
		Else
			Aviso( OemToAnsi(STR0002), OemToAnsi(STR0004), {STR0001} )
			lRet := .F.
		EndIf
	EndIf
	If aCfgNF[SAliasHead] == "SF1"
		M->F1_ADIC5  := Iif(lValida,AI0->AI0_ADIC5 ,Space(TamSX3("AI0_ADIC5")[1]))
		M->F1_ADIC61 := Iif(lValida,AI0->AI0_ADIC61,Space(TamSX3("AI0_ADIC61")[1]))
		M->F1_ADIC62 := Iif(lValida,AI0->AI0_ADIC62,Space(TamSX3("AI0_ADIC62")[1]))
		M->F1_ADIC7  := Iif(lValida,AI0->AI0_ADIC7 ,Space(TamSX3("AI0_ADIC7")[1]))
	ElseIf aCfgNF[SAliasHead] == "SF2"
    	M->F2_ADIC5  := Iif(lValida,AI0->AI0_ADIC5 ,Space(TamSX3("AI0_ADIC5")[1]))
		M->F2_ADIC61 := Iif(lValida,AI0->AI0_ADIC61,Space(TamSX3("AI0_ADIC61")[1]))
		M->F2_ADIC62 := Iif(lValida,AI0->AI0_ADIC62,Space(TamSX3("AI0_ADIC62")[1]))
		M->F2_ADIC7  := Iif(lValida,AI0->AI0_ADIC7 ,Space(TamSX3("AI0_ADIC7")[1]))
	EndIf
Return(lRet)

/*
±±ºDesc.     ³Validacao do Codigo de Barras da Nota Fical                 º±±
±±ºParametros³ cAlias        - Alias do Arquivo (SF1,SF2)                 º±±
±±º          ³ cTexto        - Codigo de Barras                           º±±
±±º          ³ lValidaDv     - Se valida o DV do Codigo de Barras         º±±
±±º          ³ cFieldSERIE   - Memoria do Campo SERIE                     º±±
±±º          ³ cFieldESPECIE - Memoria do Campo ESPECIE                   º±±
±±ºUso       ³ Validacao do codigo de barras X Campos da Tela             º±±*/
Function LocxCh2kCB(cTexto, lValidaDv, cFieldESPECIE)
Local lValido		:= .F., lErro:=.F.
Local aAreaAtu		:= GetArea()
Local aVTipoCompr	:= {}
Local aPHelpEsp		:={}
Local aPHelpPor		:={}
Local aPHelpEng		:={}
Local aSHelpEsp		:={}
Local aSHelpPor		:={}
Local aSHelpEng		:={}
Local cValAnt		:=""
Local cCodFor		:=""
Local aCliente		:={}
Local aClienteTMP	:={}
Local cCliente		:=IIf(aCfgNf[SAliasHead]=="SF1","_FORNECE","_CLIENTE")
Local aDados 		:=	{'','','','',Ctod('')}
//  existe el campo Codigo de barras e se esta sendo utilizado na tela, caso negativo retorna Normal.
If Type("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_CODBAR")=="U" .or. IsIncallStack("Fina560")
	Return .T.
Endif

If Empty(cTexto)
	Return .T.
Endif

DEFAULT lValidaDV:= .T.

If Len(AllTrim(cTexto)) == 40
	If lValidaDv
		If LocXCMod10(SubStr(cTexto,1,39)) # SubStr(cTexto,40,1)
			Help(" ",1,"LOCXNF0013")
			Return lValido
		Endif
	Endif
	aVTipoCompr	:=	MT991SETpC(aCfgNF[SAliasHead],SubStr(cTexto,12,2))
	RestArea(aAreaAtu)
	If Substr(aVTipoCompr[2],1,2)==Substr(cFieldESPECIE,1,2)
		DbSelectArea(aCfgNf[ScCliFor])
		DbSetOrder(3)
		If DbSeek(xFilial(aCfgNf[ScCliFor])+Substr(cTexto,1,11))
			aAdd(aCliente,{ &(aCfgNf[ScCliFor]+"->"+PrefixoCpo(aCfgNf[ScCliFor])+"_CGC"),;
							&(aCfgNf[ScCliFor]+"->"+PrefixoCpo(aCfgNf[ScCliFor])+"_COD"),;
							&(aCfgNf[ScCliFor]+"->"+PrefixoCpo(aCfgNf[ScCliFor])+"_LOJA")};
			)
			While !EOF() .AND. xFilial(aCfgNf[ScCliFor])== &(aCfgNf[ScCliFor]+"->"+PrefixoCpo(aCfgNf[ScCliFor])+"_FILIAL").AND.;
				 &(aCfgNf[ScCliFor]+"->"+PrefixoCpo(aCfgNf[ScCliFor])+"_CGC")==aCliente[1][1]
				DbSkip()
				If &(aCfgNf[ScCliFor]+"->"+PrefixoCpo(aCfgNf[ScCliFor])+"_CGC")==aCliente[1][1]
					aAdd(aCliente,{ &(aCfgNf[ScCliFor]+"->"+PrefixoCpo(aCfgNf[ScCliFor])+"_CGC"),;
									&(aCfgNf[ScCliFor]+"->"+PrefixoCpo(aCfgNf[ScCliFor])+"_COD"),;
									&(aCfgNf[ScCliFor]+"->"+PrefixoCpo(aCfgNf[ScCliFor])+"_LOJA")};
					)
				Endif
			End Do
			If Len(aCliente)>1
				aClienteTMP	:=LocxSELCLI(aCliente[1][1])
				If !Empty(aClienteTMP)
					aCliente:={}
					aAdd(aCliente,{aClienteTmp[1],aClienteTmp[2],aClienteTmp[3]})
				Else
					aCliente:={}
				Endif
			Endif
			If !Empty(aCliente)
				cValAnt		:=	{&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+cCliente), &("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_LOJA")}
				&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+cCliente)	:=	aCliente[1][2]
				&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_LOJA")	    :=	aCliente[1][3]
				If (lErro:=!LocxVldGet(PrefixoCpo(aCfgNf[SAliasHead])+cCliente))
					&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+cCliente):=	cValAnt[1]
					&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_LOJA")	:=	cValAnt[2]
					Help(" ",1,"LOCXNF0006")
				Endif
				If !lErro
					If (lErro:=!LocxVldGet(PrefixoCpo(aCfgNf[SAliasHead])+"_LOJA"))
						&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+cCliente):=	cValAnt[1]
						&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_LOJA")	:=	cValAnt[2]
						Help(" ",1,"LOCXNF0007")
					Endif
				Endif
				RestArea(aAreaAtu)
				If !lErro
					cValAnt:=&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_DOC")
					&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_DOC")	:=	Substr(cTexto,14,4) + PadL(" ",8)
					If !lErro
						cValAnt	:=&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_CAI")
						&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_CAI"):=Substr(cTexto,18,14)
						If (lErro:=!LocxVldGet(PrefixoCpo(aCfgNf[SAliasHead])+'_CAI'))
							&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_CAI"):=cValAnt
							Help(" ",1,"LOCXNF0009")
						Endif
						If !lErro
							cValAnt			:=	&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_VENCAI")
							&("M->"+PrefixoCpo(aCfgNf[SAliasHead])+"_VENCAI"):=	CToD(Substr(cTexto,38,2)+"/"+Substr(cTexto,36,2)+"/"+Substr(cTexto,32,4))
							If (lErro	:=	!LocxVldGet(PrefixoCpo(aCfgNf[SAliasHead])+"_CAI"))
								&("M->"+PrefixoCpo(SAliasHead)+"_VENCAI"):=	cValAnt
								Help(" ",1,"LOCXNF0011")
							Endif
						Endif
					Endif
				Endif
				lValido:=!lErro //Codigo de Barras da NF OK
			Else
				Help(" ",1,"LOCXNF0006")
			Endif
		Else
			RestArea(aAreaAtu)
			Help(" ",1,"LOCXNF0003")
		Endif
	Else
		Help(" ",1,"LOCXNF0004")
	Endif
Else
	Help(" ",1,"LOCXNF0005")
Endif
Return lValido

/*
±±ºDesc.     ³Rotina para buscar o numero do documento quando usa impressoº±±
±±º          ³ra fiscal Hasar (Loc. Argentina)                            º±±
*/
Function GetNum2CFis(cSerie,cEspecie)
Local cNumNota := ""
Local cRet	   := ""
Local aRet     := {}
Local nRet     := 0
Local cPdv     := Space(TamSx3("L1_PDV")[1])

iRetorno := IFPegPDV(nHdlECF, @cPdv)
If L010AskImp(.F.,iRetorno)
   Return (.F.)
EndIf

nRet := IFStatus(nHdlECF, '17', @cRet)

If nRet == 1
   Return( .F. )
EndIf
aRet := LjStr2Array( cRet )

Do Case
	Case AllTrim(cSerie) == "A" .AND. AllTrim(cEspecie)$"NCC|NCE|NCP|NCI"
		cNumNota := cPdv + StrZero( Val( aRet[8] )+1, 8 )
	Case AllTrim(cSerie)$"B|C" .AND. AllTrim(cEspecie)$"NCC|NCE|NCP|NCI"
	    cNumNota := cPdv + StrZero( Val( aRet[7] )+1, 8 )
	Case AllTrim(cSerie) == "A" .AND. AllTrim(cEspecie)$"NF|CF|NDC|NDE|NDI|NDP"
	    cNumNota := cPdv + StrZero( Val( aRet[5] )+1, 8 )
	Case AllTrim(cSerie)$"B|C" .AND. AllTrim(cEspecie)$"NF|CF|NDC|NDE|NDI|NDP"
		cNumNota := cPdv + StrZero( Val( aRet[3] )+1, 8 )
	OtherWise
		cNumNota := cPdv + StrZero( Val( aRet[9] )+1, 8 )
EndCase
Return(cNumNota)

Function LocX2TipSer(cAlias,cTipoDoc)
Local cCodSerie  := "   "
Local cTipo      := ""
Local cCliPro 	:= "" 
Local cLoj 		:= ""
If Subs(cTipoDoc,1,1) <> "R"

	IF cPaisLoc == "ARG"
		IF TYPE("aCfgNf") == "A" .and. len(aCfgNf)  > 0 
			//Verifico se os campos de memoria do cabeçalho das faturas estão preenchidos.
			IF aCfgNf[4] == "SF1"
				If !EMPTY(M->F1_FORNECE) .AND. !EMPTY(M->F1_LOJA) 
					cCliPro := M->F1_FORNECE
					cLoj	:= M->F1_LOJA
				EndIF
			ElseIF aCfgNf[4] == "SF2"
				If !EMPTY(M->F2_CLIENTE) .AND. !EMPTY(M->F2_LOJA)
					cCliPro := M->F2_CLIENTE
					cLoj	:= M->F2_LOJA
				EndIF
			EndIF
		EndIF
		// Caso os campos de memoria do cabeçalho das faturas estão preenchido
		// Posiciono no registro correto, através do Codigo+Loja utilizados no cabeçalho. 
		IF !EMPTY(cCliPro) .and. !EMPTY(cLoj)	
			dbSelectArea(cAlias)
			dbSetOrder(1)
			MsSeek(xFilial(cAlias)+cCliPro+cLoj)
		EndIF
	EndIF
	
	If cAlias =="SA1"
		cTipo	:= SA1->A1_TIPO
	Else
		cTipo	:= SA2->A2_TIPO
	EndIf	


	If(cAlias == "SA2" .AND. cPaisLoc == "ARG" .AND. dDataBase >= SA2->A2_DTINISM .AND. dDataBase < SA2->A2_DTFIMSM )
		cCodSerie    := "M  "
	Else
		If cTipo $ "N|I"
		   cCodSerie    := "A  "
		ElseIf cTipo $ "F|S"
		   cCodSerie    := "B  "
		ElseIf cTipo $ "M|X" .And.  cAlias == "SA2"
		   cCodSerie    := "C  "
		ElseIf cTipo $ "M" .And.  cAlias == "SA1"
		   cCodSerie    := "C  "
		ElseIf cTipo $ "X" .And.  cAlias == "SA1"
		   cCodSerie    := "B  "
		ElseIf cTipo == "E"
		   cCodSerie    := "E  "
		Endif
	EndIf
Else
	cCodSerie    := "R  "
EndIf
//Pto de Entrada para alterar a serie da nf (faturas de entrada mata101)
cPe	:=	LocxPE(45)
If !Empty(cPE)
	cCodSerie := ExecBlock(cPe,.F.,.F.,{cTipoDoc, cTipo, cCodSerie})
Endif
Return (cCodSerie)


/*
±±ºDesc.     ³Selecao do Fornec.                                             º±±
±±º          ³Todos os Fornec.es listados possuem o mesmo CGC.               º±±
±±ºUso       ³ Selecao de Fornec., caso exista mais de um fornec. com        º±±
±±º          ³ o mesmo CGC da NF.                                    		 º±±*/
Function Locx2SELCLI( cCGC)
Local ni,oCol,nTitulos,oForm ,oCBX, cIndice
Local nOrdSA,nSA,nOrdSX3
Local aCliente	:= {}
Local lRet			:=	.T.
Local aRateioGan  :=	{}
Local aAreaSA
Private cFiltro:="", cTitulo
Private cForm:= Space(9)
Private oDlgForn,nOpca,cAlias:=Alias()
Private oBrwForn
Private nIndice := 1

DbSelectArea("SX3")
nOrdSX3:=IndexOrd()
DbSetOrder(2)
DbSelectArea(aCfgNf[ScCliFor])
nSA:=Select(aCfgNf[ScCliFor])
nOrdSA:=Indexord()
DbSetorder(3)
cFiltro:=PrefixoCpo(aCfgNF[ScCliFor])+"_FILIAL == '" + xFilial(aCfgNF[ScCliFor]) + "' .AND. "+PrefixoCpo(aCfgNF[ScCliFor])+"_CGC=='" + cCGC + "'"
MSFilter(cFiltro)
nOpca:=0
cTitulo:=IIf(aCfgNF[ScCliFor]=="SA1",STR0011,STR0012)

DEFINE MSDIALOG oDlgForn FROM  0,0 TO 280,500 PIXEL TITLE cTitulo OF oMainWnd
	oBrwForn:=TCBrowse():New(5,5,241,100,,,,oDlgForn,,,,,{|nRow,nCol,nFlags|nOpca:=1,oDlgForn:End()},,,,,,,.F.,,.T.,,.F.,)

	SX3->(MsSeek(PrefixoCpo(aCfgNF[ScCliFor])+"_COD"))
	oCol:=TCColumn():New(Trim(x3titulo()),FieldWBlock(PrefixoCpo(aCfgNF[ScCliFor])+"_COD",nSA),,,,,,.F.,.F.,,,,.F.,)
	oBrwForn:ADDCOLUMN(oCol)

	SX3->(MsSeek(PrefixoCpo(aCfgNF[ScCliFor])+"_LOJA"))
	oCol:=TCColumn():New(Trim(x3titulo()),FieldWBlock(PrefixoCpo(aCfgNF[ScCliFor])+"_LOJA",nSA),,,,,,.F.,.F.,,,,.F.,)
	oBrwForn:ADDCOLUMN(oCol)

	SX3->(MsSeek(PrefixoCpo(aCfgNF[ScCliFor])+"_NOME"))
	oCol:=TCColumn():New(Trim(x3titulo()),FieldWBlock(PrefixoCpo(aCfgNF[ScCliFor])+"_NOME",nSA),,,,,,.F.,.F.,,,,.F.,)
	oBrwForn:ADDCOLUMN(oCol)

DEFINE SBUTTON FROM 115,185 TYPE 1 ACTION (nOpca:=1,oDlgForn:End()) PIXEL ENABLE OF oDlgForn
DEFINE SBUTTON FROM 115,217 TYPE 2 ACTION (nOpca:=0,oDlgForn:End()) PIXEL ENABLE OF oDlgForn

ACTIVATE MSDIALOG oDlgForn CENTERED

If nOpca==1
	aAreaSA	:=	&(aCfgNF[ScCliFor]+"->(GetArea())")
	RestArea(aAreaSA)
	aCliente	:=	{&(aCfgNF[ScCliFor]+"->"+PrefixoCpo(aCfgNF[ScCliFor])+"_CGC"),;
					&(aCfgNF[ScCliFor]+"->"+PrefixoCpo(aCfgNF[ScCliFor])+"_COD"),;
					&(aCfgNF[ScCliFor]+"->"+PrefixoCpo(aCfgNF[ScCliFor])+"_LOJA");
					}
Endif
DbSelectArea(aCfgNF[ScCliFor])
DbClearFilter()

DbSetOrder(nOrdSA)
SX3->(DbSetOrder(nOrdSX3))
dbSelectArea(cAlias)
Return aCliente

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GRAVACCºAutor  ³Microsiga           º Data ³  28/11/20   º±±
*/
Function GRAVACC(cCliFor,cAlias,cEspecie)
	Local aArea:= GetArea()
	Local cNumCC:=Iif(cAlias=="SF1",SF1->F1_CC,SF2->F2_CC)
	Local cTpCC:=Iif(cCliFor=="SA1","R","P")
	Local cCod:=Iif(cAlias=="SF1",SF1->F1_FORNECE,SF2->F2_CLIENTE)
	Local cLoja:=Iif(cAlias=="SF1",SF1->F1_LOJA,SF2->F2_LOJA)
	Local cNum:=Iif(cAlias=="SF1",SF1->F1_DOC,SF2->F2_DOC)
	Local cSerie:=Iif(cAlias=="SF1",SF1->F1_SERIE,SF2->F2_SERIE)
	Local dDTEmis:=Iif(cAlias=="SF1",SF1->F1_EMISSAO,SF2->F2_EMISSAO)
	Local dDataCC:=dDTEmis
	Local cMoeda:=AllTrim(str(Iif(cAlias=="SF1",SF1->F1_MOEDA,SF2->F2_MOEDA)))
	Local nVlDoc:=Iif(cAlias=="SF1",SF1->F1_VALBRUT,SF2->F2_VALBRUT)
	Local nValAc:=0
	Local cEspecie:=Iif(cAlias=="SF1",SF1->F1_ESPECIE,SF2->F2_ESPECIE)

	Default cCliFor  := ""
	Default cAlias   := ""
	Default cEspecie := ""
	//GRAVA CABECALHO CC
	If AllTrim(cEspecie)=="NF"
		DBSelectArea("FVS")
		RecLock("FVS",.T.)
		Replace FVS_FILIAL With xFilial("FVS")
		Replace FVS_CODCC   With cNumCC	
		Replace FVS_TIPO  With cTpCC
		Replace FVS_CODIGO   With cCod	
		Replace FVS_LOJA   With cLoja
		Replace FVS_DESC   With "testE"	
		Replace FVS_DTCRIA  With dDataCC
		Replace FVS_MOEDA   With cMoeda	
		Replace FVS_VLTOT   With nVlDoc
		Replace FVS_STATUS   With "1"	
		MsUnLock()	
	EndIf
	// GRAVA ITEM CC
	DBSelectArea("FVT")
	RecLock("FVT",.T.)
		Replace FVT_FILIAL With xFilial("FVS")
		Replace FVT_CODCC   With cNumCC	
		Replace FVT_TIPO  With cTpCC
		Replace FVT_CODIGO   With cCod	
		Replace FVT_LOJA   With cLoja
		Replace FVT_ESPECIE   With cEspecie	
		Replace FVT_SERIE  With cSerie
		Replace FVT_DOC   With 	cNum
		Replace FVT_EMIS   With dDTEmis 
		Replace FVT_DTAFIP  With dDTEmis
		Replace FVT_VALOR   With nVlDoc	
		Replace FVT_STATUS   With "1"	
	MsUnLock()	

	If AllTrim(cEspecie)<> "NF"
		DBSelectArea("FVS")
		DbSetOrder(1)
		If MsSeek(xFilial("FVS")+cNumCC+cTpCC+cCod+cLoja)
			nValAc:=FVS->FVS_VLTOT+nVlDoc
			RecLock("FVS",.F.)
			Replace FVS_VLTOT    With nValAc
			MsUnLock()
		EndIf
	EndIf	
	RestArea(aArea)

Return()

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MVerifCCºAutor  ³Microsiga           º Data ³  28/11/20   º±±
*/
Function MVerifCC(cAlias,cEspecie,cSerie,cNumDoc,cCliForn,cLoja,cCuentaC)

	Local cTipoCR:="P"
	Local cAliasAt:=GetArea()
	Local lRet:=.T.
	
	Default cAlias   := ""
	Default cEspecie := ""
	Default cSerie   := ""
	DEfault cNumDoc  := ""
	Default cCliForn := ""
	Default cLoja    := ""
	Default cCuentaC := ""
	
	If (cAlias=="SF2" .And. AllTrim(cEspecie)=="NF") .or. AllTrim(cEspecie)$ ("NDC|NCC")
		cTipoCR:="R"
	EndIf
	DbSelectARea("FVT")
	DbSetOrder(1)
	If DbSeek(xFilial("FVT")+cCuentaC+cTipoCR+cCliForn+cLoja+Subs(cEspecie,1,3)+cSerie+cNumDoc) .and. !( FVT->FVT_STATUS $ "1|2")
		MsgAlert(STR0013,STR0014) //"No es posible borrar el documento debido a su estatus en la cuenta corriente"##"Estatus cuenta corriente"
		lRet:=.F.
	EndIf
	RestArea(cAliasAt)
Return(lRet)

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldCC ºAutor  ³Microsiga           º Data ³  28/11/20   º±±
*/              
Function  VldCC(cCod,cLoja,cCC,cRg1415)
	Local aAreaAt:=GetArea()
	Local lRet:=.T.
	
	Default cCod := ""
	Default cLoja := ""
	Default cCC := ""
	Default cRg1415 := ""
	
	DbSelectArea("FVS")
	DbSetOrder(1)
	If Val(cRg1415) > 200 .and. !(MsSeek(xFilial("FVS")+ cCC+"P"+cCod+cLoja) )  
		lRet:=.F.
		MsgAlert(STR0015, STR0016) //"Cuenta corriente no pertenece a este Proveedor"##"Cuenta corriente"
	EndIf
	If Val(cRg1415) < 200 .and. !Empty(cCC)
		lRet:=.F.
		MsgAlert(STR0017, STR0016) //"No debe informarse una Cuenta corriente para este Código de RG1415"##"Cuenta corriente"
	EndIf
	RestArea(aAreaAt)
Return(lRet)

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VlMiPyme ºAutor  ³Microsiga         º Data ³  28/11/20   º±±
*/
Function VlMiPyme(cAlias,lItem)

	Local lRet :=.t.
	Local aArea:=GetArea()
	Local nValor:= MaFisRet(,'NF_TOTAL')
	Local lfn998 := FwIsInCallStack("FINA998")
	Local nPos   := 0
	Local nVlRG  := 0
	Local cCpoRg :=Iif(cAlias == "SF2","F2_RG1415","F1_RG1415")
	Default cAlias:=""
	Default lItem := .T.  
	
	If lfn998
		nPos := Ascan(aAutoCab,{|x|Alltrim(x[1])==cCpoRg})
		If nPos > 0
			nVlRG := Val(aAutoCab[nPos][2])
		Endif
	Else
		nVlRG:= Val(M->&(cCpoRg))
	Endif
	
	If  ( GetNewPar("MV_TAMEMP",'1') $ "1"	 .and. SA1->A1_TAMEMP $ "2|3|4"  ) ;
		.AND.SA1->(ColumnPos("A1_CLAFISC") > 0) .and. !Empty(SA1->A1_CLAFISC) .and.  nValor <> 0 ;
		.and. SX5->(MsSeek(xFilial("SX5")+"WG"+SA1->A1_CLAFISC))
		If lItem .and. nVlRG < 200  .and.  nValor >  Val(X5Descri())
			lRet:= .F.
			MsgStop(STR0018, STR0022) //"No es posible agregar más ítems debido a la clasificación del Cliente vs. Valor mínimo para Documento no Pyme"##"Documento no Pyme"
		ElseIf !lItem
			If  nVlRG > 200  .and.  nValor <  Val(X5Descri())
				lRet:= .F.
				MsgStop(STR0019, STR0021) //"201 No es posible confirmar el documento debido a que el Valor total es menor que el mínimo para el Documento Pyme"##"Documento Pyme"
			Endif
		EndIf
	EndIf

	RestArea(aArea)     
Return(lRet)

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VlCCPyme ºAutor  ³Microsiga         º Data ³  28/11/20   º±±
*/
Function VlCCPyme(cAlias)

	Local lRet :=.t.
	Local aArea:=GetArea()
	Local nValor:= MaFisRet(,'NF_TOTAL')
	Local cCampoRG :=""
	Default cAlias:=""

	If cAlias == "SF2"
		nVlRG:= Val(M->F2_RG1415)
	Else
		nVlRG:= Val(M->F1_RG1415)
	End	
	If ( GetNewPar("MV_TAMEMP",'1') $ "2|3|4" ) ;
		.AND. SF1->(ColumnPos("F1_CC")) > 0 .and. SF2->(ColumnPos("F2_CC")) > 0 
		If cAlias == "SF2" .AND. Empty(M->F2_CC) .and. nVlRG > 200 
			lRet:= .F.
			MsgStop(STR0023,STR0016) //"Número de cuenta corriente es obligatorio para el documento MIPYME"##"Cuenta corriente"
		ElseIf cAlias == "SF2"  .AND. !Empty(M->F2_CC) .and.  nVlRG < 200 
			lRet:= .F.
			MsgStop(STR0024,STR0016) //"Número de cuenta corriente no debe informarse para un documento no MIPYME"##"Cuenta corriente"
		ElseIf cAlias == "SF1"  .AND. Empty(M->F1_CC)  .and.  nVlRG > 200 
			lRet:= .F.
			MsgStop(STR0023,STR0016) //"Número de cuenta corriente es obligatorio para el documento MIPYME"##"Cuenta corriente"
		ElseIf cAlias == "SF1"  .AND. !Empty(M->F1_CC) .and.  nVlRG < 200 
			lRet:= .F.
			MsgStop(STR0024,STR0016) //"Número de cuenta corriente no debe informarse para un documento no MIPYME"##"Cuenta corriente"
		EndIf
	EndIf

	RestArea(aArea)     
Return(lRet)     

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExcluiCCr ºAutor  ³Microsiga        º Data ³  28/11/20   º±±
*/
Function ExcluiCCr(cAlias,nRecno)

	Local lRet		:= .T.
	Local cCodCC	:= "" 
	Local cTPFVS	:= ""
	Local cCodFor	:= ""
	Local cLoja	:= ""
	Local cDocFVT := ""
	Local cCrFilial := ""
	Local cEntSai	:= Substr(cAlias,3,3)
	local nContCCr:= 0
	Local nRecFVT := 0
	Local nRecFVS := 0
	Local cAliasFVT	:= GetNextAlias()
	Local lContinua := .F.

	Default cAlias	:= ""
	Default nRecno	:= 0
	If cEntSai == "1"
		If (SF1->(ColumnPos("F1_CC")) > 0 .And. !Empty((cAlias)->F1_CC) ) 
			lContinua := .T.
		Endif
	ElseIf cEntSai == "2" 	
		If (SF2->(ColumnPos("F2_CC")) > 0 .And. !Empty((cAlias)->F2_CC))
			lContinua := .T.
		Endif
	Endif
	
	If lContinua	
		dbSelectArea(cAlias)
		(cAlias)->(MsGoto(nRecno)) 
		If cEntSai == "1" .AND. ("NF" $ (cAlias)->F1_ESPECIE)
			dbSelectArea('FVS')
			DbSetOrder(1)
			//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
			If MsSeek(xFilial('FVS')+ (cAlias)->F1_CC ) 		
				If 	!(FVS->FVS_STATUS $ "3|4|5") 
					nRecFVS :=  FVS->(Recno())
					cCrFilial := FVS_FILIAL
					cCodCC := FVS->FVS_CODCC
					cTPFVS := FVS->FVS_TIPO
					cCodFor := FVS->FVS_CODIGO
					cLoja := FVS->FVS_LOJA	
					cQuery := "SELECT * "
					cQuery += " FROM "+RetSqlName("FVT")+" FVT "
					cQuery += " WHERE "
					cQuery += " FVT.FVT_FILIAL ='" + cCrFilial + "' AND "
					cQuery += " FVT.FVT_CODCC ='"+ cCodCC +"' AND "
					cQuery += " FVT.D_E_L_E_T_ =' ' "
					cQuery += " ORDER BY FVT_DOC "
					cQuery := ChangeQuery(cQuery)
						
					DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasFVT, .F., .T.)
					DbSelectArea(cAliasFVT)
					While (cAliasFVT)->(!Eof())//!(cAliasFVT)->(EOF()) 
						If Alltrim((cAliasFVT)->FVT_ESPECI) == "NF"
							nRecFVT := (cAliasFVT)->R_E_C_N_O_
						Endif
						nContCCr ++
						(cAliasFVT)->(DbSkip())
						//cDocFVT := FVT->FVT_DOC
					Enddo 
					If nContCCr == 1
						FVT->(MsGoto(nRecFVT))
						// Apaga registro do item da conta corrente
						RecLock("FVT",.F.)
						DbDelete()
						MsUnlock()
						//Apaga Cabeçalho conta corrente
						FVS->(MsGoto(nRecFVS))
						RecLock("FVS",.F.)
						DbDelete()
						MsUnlock()
						
						lRet := .T.
					Else
						MSGINFO(STR0025) //"La Factura tiene notas de débito y crédito vinculadas a la cuenta corriente y no podrá borrarse."
						lRet := .F.	
					Endif								
				Endif
				(cAliasFVT)->(dbCloseArea())	
			Endif	
		ElseIf cEntSai == "1" .AND. ("NDP" $ (cAlias)->F1_ESPECIE)
			dbSelectArea('FVS')
			DbSetOrder(1)
			//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
			If MsSeek(xFilial('FVS')+ (cAlias)->F1_CC ) 		
				cCrFilial := FVS_FILIAL
				cCodCC := FVS->FVS_CODCC	
				cTPFVS := FVS->FVS_TIPO
				cCodFor := FVS->FVS_CODIGO
				cLoja := FVS->FVS_LOJA	
				dbSelectArea('FVT')
				DbSetOrder(1)
				//FVT_FILIAL + FVT_CODCC + FVT_TIPO + FVT_CODIGO + FVT_LOJA + FVT_ESPECI + FVT_SERIE + FVT_DOC					
				MsSeek(xFilial('FVT')+ cCodCC + cTPFVS + cCodFor + cLoja + "NDP" + (cAlias)->F1_SERIE + (cAlias)->F1_DOC) 
				If !(FVT->FVT_STATUS $ "3|4|5")
					// Apaga registro do item da conta corrente
					RecLock("FVT",.F.)
					DbDelete()
					MsUnlock()
					lRet := .T.
				Else
					MSGINFO(STR0026) //"La Factura tiene movimientos en la cuenta corriente y no podrá borrarse."
					lRet := .F.	
				Endif									
			Endif
		ElseIf cEntSai == "2" .And. ("NCP" $ (cAlias)->F2_ESPECIE)	
			dbSelectArea('FVS')
			DbSetOrder(1)
			//FVS_FILIAL + FVS_CODCC + FVS_TIPO + FVS_CODIGO + FVS_LOJA
			If MsSeek(xFilial('FVS')+ (cAlias)->F2_CC ) 		
				cCrFilial := FVS_FILIAL
				cCodCC := FVS->FVS_CODCC	
				cTPFVS := FVS->FVS_TIPO
				cCodFor := FVS->FVS_CODIGO
				cLoja := FVS->FVS_LOJA	
				dbSelectArea('FVT')
				DbSetOrder(1)
				//FVT_FILIAL + FVT_CODCC + FVT_TIPO + FVT_CODIGO + FVT_LOJA + FVT_ESPECI + FVT_SERIE + FVT_DOC					
				MsSeek(xFilial('FVT')+ cCodCC + cTPFVS + cCodFor + cLoja + "NCP" + (cAlias)->F2_SERIE + (cAlias)->F2_DOC) 
				If !(FVT->FVT_STATUS $ "3|4|5")
					// Apaga registro do item da conta corrente
					RecLock("FVT",.F.)
					DbDelete()
					MsUnlock()
					lRet := .T.
				Else
					MSGINFO(STR0026) //"La Factura tiene movimientos en la cuenta corriente y no podrá borrarse."
					lRet := .F.	
				Endif									
			Endif
		Endif
	Endif
Return lRet

/*±±ºPrograma  ³AVldNum ºAutor  ³ Ventas/CRM	     ºFecha ³  05/04/2021 º±±
±±ºDesc.     ³ Valida la numeración, buscando siempre la última           º±±
±±º          ³ numeración que se utilizó y compararla con                 º±±
±±º          ³ la numeración disponible en la tabla SX5.		          º±±*/

Static Function AVldNum(cSerNfs,cNumSx5,cEspecie,cPontoVend)
Local aAlias	:= GetArea()
Local cNumAux 	:= ""
Local cAliasNew := ""
Local cQuery	:= ""
Local lNumDif	:= .F.
Local lMT467N   := Type("cFunName")<>"U" .And. cFunName $ "MATA467N"

If  TamSX3("F2_SERIE")[1] == 14 //Projeto Chave Unica - TIago Silva
	cSerNfs:=SerieNfId("SF2",4,"F2_SERIE",dDataBase,cEspecie,cSerNfs,)
Endif

If AllTrim(cEspecie) $ "NF|NDC|NCE"
	#IFDEF TOP
		cAliasNew := GetNextAlias()
		cQuery := "SELECT MAX(F2_DOC) F2_DOC FROM " + RetSqlName( "SF2" )
		cQuery += " WHERE F2_FILIAL = '" + xFilial( "SF2" ) + "' AND "
		cQuery += "	F2_SERIE = '"+cSerNfs+"' AND "
		cQuery += " F2_EMISSAO = '"+DTOS(dDataBase)+"' AND D_E_L_E_T_ = ' ' AND F2_FORMUL = 'S'"
		If (cPaisLoc == "ARG") .And. !Empty( cPontoVend )
			cQuery += " AND F2_PV = '" + cPontoVend + "'
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
		dbSelectArea(cAliasNew)
		If !(Eof()) .And. !Empty((cAliasNew)->F2_DOC)
			cNumAux := (cAliasNew)->F2_DOC
			If lMT467N .And. cNumSx5 >= Soma1(cNumAux,TamSX3("F2_DOC")[1])
				cNumSx5 := Soma1(cNumAux,TamSX3("F2_DOC")[1])
				lNumDif := .F.
			ElseIf cNumSx5 <> Soma1(cNumAux,TamSX3("F2_DOC")[1]) .And. !lMT467N
				cNumSx5 := Soma1(cNumAux,TamSX3("F2_DOC")[1])
				lNumDif := .F.
			EndIf
		Else
			(cAliasNew)->(dbCloseArea())
			cAliasNew := GetNextAlias()
			cQuery := "SELECT MAX(F2_DOC) F2_DOC FROM " + RetSqlName( "SF2" )
			cQuery += " WHERE F2_FILIAL = '" + xFilial( "SF2" ) + "' AND F2_SERIE = '"+cSerNfs+"' AND "
			cQuery += "F2_EMISSAO < '"+DTOS(dDataBase)+"' AND D_E_L_E_T_ = ' ' AND F2_FORMUL = 'S'"
			If (cPaisLoc == "ARG") .And. !Empty( cPontoVend )
				cQuery += " AND F2_PV = '" + cPontoVend + "'
			EndIf
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
			dbSelectArea(cAliasNew)
			If !(Eof()) .And. !Empty((cAliasNew)->F2_DOC)
				cNumAux := (cAliasNew)->F2_DOC
				If lMT467N .And. cNumSx5 >= Soma1(cNumAux,TamSX3("F2_DOC")[1])
					cNumSx5 := Soma1(cNumAux,TamSX3("F2_DOC")[1])
					lNumDif := .F.
				ElseIf cNumSx5 <> Soma1(cNumAux,TamSX3("F2_DOC")[1]) .And. !lMT467N
					cNumSx5 := Soma1(cNumAux,TamSX3("F2_DOC")[1])
					lNumDif := .F.
				EndIf
			EndIf
		EndIf
		If Select(cAliasNew) <> 0
			(cAliasNew)->(dbCloseArea())
		EndIf
	#ENDIF
ElseIf AllTrim(cEspecie) $ "NCC|NDE"
	#IFDEF TOP
		cAliasNew := GetNextAlias()
		cQuery := "SELECT MAX(F1_DOC) F1_DOC FROM " + RetSqlName( "SF1" )
		cQuery += " WHERE F1_FILIAL = '" + xFilial( "SF1" ) + "' AND "
		cQuery += "	F1_SERIE = '"+cSerNfs+"' AND "
		cQuery += " F1_EMISSAO = '"+DTOS(dDataBase)+"' AND D_E_L_E_T_ = ' ' AND F1_FORMUL = 'S'"
		If (cPaisLoc == "ARG") .And. !Empty( cPontoVend )
			cQuery += " AND F1_PV = '" + cPontoVend + "'
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
		dbSelectArea(cAliasNew)
		If !(Eof()) .And. !Empty((cAliasNew)->F1_DOC)
			cNumAux := (cAliasNew)->F1_DOC
			If cNumSx5 <> Soma1(cNumAux,TamSX3("F1_DOC")[1])
				cNumSx5 := Soma1(cNumAux,TamSX3("F1_DOC")[1])
				lNumDif := .F.
			EndIf
		Else
			(cAliasNew)->(dbCloseArea())
			cAliasNew := GetNextAlias()
			cQuery := "SELECT MAX(F1_DOC) F1_DOC FROM " + RetSqlName( "SF1" )
			cQuery += " WHERE F1_FILIAL = '" + xFilial( "SF1" ) + "' AND F1_SERIE = '"+cSerNfs+"' AND "
			cQuery += "F1_EMISSAO < '"+DTOS(dDataBase)+"' AND D_E_L_E_T_ = ' ' AND F1_FORMUL = 'S'"
			If (cPaisLoc == "ARG") .And. !Empty( cPontoVend )
				cQuery += " AND F1_PV = '" + cPontoVend + "'
			EndIf
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
			dbSelectArea(cAliasNew)
			If !(Eof()) .And. !Empty((cAliasNew)->F1_DOC)
				cNumAux := (cAliasNew)->F1_DOC
				If cNumSx5 <> Soma1(cNumAux,TamSX3("F1_DOC")[1])
					cNumSx5 := Soma1(cNumAux,TamSX3("F1_DOC")[1])
					lNumDif := .F.
				EndIf
			EndIf
		EndIf
		If Select(cAliasNew) <> 0
			(cAliasNew)->(dbCloseArea())
		EndIf
	#ENDIF

EndIf

RestArea(aAlias)
Return lNumDif

/*/{Protheus.doc} ANumExis
	@type  Function
	@author Carlos Espinoza
	@since 04/05/2022
	@param	cSerNf - serie del documento de salida,
			cNum - número de documento del documento de salida, 
			cPontoVend - punto de venta del documento de salida.
	@return lNumExist, regresa .T. si el número de documento existe en la tabla SF2
/*/
Function ANumExis(cSerNf,cNum,cPontoVend)
Local aAlias	:= GetArea()
Local cAliasNew := ""
Local lNumExist	:= .F.
Local nNumRegs := 0

Default cSerNf := ""
Default cNum := ""
Default cPontoVend := ""

cAliasNew := GetNextAlias()
BeginSql Alias cAliasNew
	SELECT F2_DOC
	FROM %Table:SF2% SF2
	WHERE SF2.F2_FILIAL = %Exp:(xFilial("SF2"))%
	AND SF2.F2_SERIE = %Exp:cSerNf%
	AND SF2.F2_FORMUL = "S"
	AND SF2.F2_PV = %Exp:cPontoVend%
	AND SF2.F2_DOC = %Exp:cNum%
	AND SF2.%NotDel%
EndSql

Count To nNumRegs

If nNumRegs > 0
	lNumExist := .T. //Retorna .T. si existe registro en la tabla SF2
EndIf

If Select(cAliasNew) <> 0
	(cAliasNew)->(dbCloseArea())
EndIf

RestArea(aAlias)
Return lNumExist


/*/{Protheus.doc} AVldFecNf
	@type  Function
	@author Carlos Espinoza
	@since 06/05/2022
	@param	cSerNf - serie del documento de salida,
			cNum - número de documento del documento de salida, 
			cPontoVend - punto de venta del documento de salida.
	@return lFchVld, regresa .T. si la secuencia del número de documento está dentro del rango a la fecha emisión del documento anterior y posterior
/*/
Function AVldFecNf(cSerNf,cNum,cPontoVend)
Local aAlias	:= GetArea()
Local cAliasNew := ""
Local cFchAnt := ""
Local cFchPos := ""
Local cFchAct := DTOS(dDataBase)
Local lFchVld := .F.

Default cSerNf := ""
Default cNum := ""
Default cPontoVend := ""

cAliasNew := GetNextAlias()
BeginSql Alias cAliasNew
	SELECT F2_EMISSAO
	FROM %Table:SF2% SF21
	WHERE SF21.F2_FILIAL = %Exp:(xFilial("SF2"))%
	AND SF21.F2_DOC <= %Exp:cNum%
	AND SF21.F2_SERIE = %Exp:cSerNf%
	AND SF21.F2_FORMUL = "S"
	AND SF21.F2_PV = %Exp:cPontoVend%
	AND SF21.%NotDel% ORDER BY SF21.F2_DOC DESC
EndSql

If (cAliasNew)->(!EoF())
	cFchAnt := (cAliasNew)->F2_EMISSAO
EndIf

If Select(cAliasNew) <> 0
	(cAliasNew)->(dbCloseArea())
EndIf

cAliasNew := GetNextAlias()

BeginSql Alias cAliasNew
	SELECT F2_EMISSAO
	FROM %Table:SF2% SF22
	WHERE SF22.F2_FILIAL = %Exp:(xFilial("SF2"))%
	AND SF22.F2_DOC >= %Exp:cNum%
	AND SF22.F2_SERIE = %Exp:cSerNf%
	AND SF22.F2_FORMUL = "S"
	AND SF22.F2_PV = %Exp:cPontoVend%
	AND SF22.%NotDel% ORDER BY SF22.F2_DOC
EndSql

If (cAliasNew)->(!EoF())
	cFchPos := (cAliasNew)->F2_EMISSAO
EndIf

If Select(cAliasNew) <> 0
	(cAliasNew)->(dbCloseArea())
EndIf

If (!Empty(cFchAnt) .And. !Empty(cFchPos) .And. cFchAct >= cFchAnt .And. cFchAct <= cFchPos) ;
	.Or. (Empty(cFchAnt) .And. !Empty(cFchPos) .And. cFchAct <= cFchPos) ;
	.Or. (!Empty(cFchAnt) .And. Empty(cFchPos) .And. cFchAct >= cFchAnt) ;
	.Or. (Empty(cFchAnt) .And. Empty(cFchPos))
	lFchVld := .T.
EndIf

RestArea(aAlias)
Return lFchVld

/*/{Protheus.doc} VldSerProd
	@type  Function
	@author Arturo Samaniego
	@since 12/11/2021
	@param	cProducto - Codigo producto,
			cLocal - Almacen producto, 
			cLocaliz - Ubicación producto.
	@return lSerProd, Logico, Regresa .T. si existe registro con número de serie.
	/*/
Function VldSerProd(cProducto, cLocal, cLocaliz)
Local aArea := GetArea()
Local cTemp := GetNextAlias()
Local lSerProd := .F.
Local nNumRegs := 0

Default cProducto := ""
Default cLocal    := ""
Default cLocaliz  := ""

	BeginSql Alias cTemp
		SELECT SBF.BF_PRODUTO, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_NUMSERI
		FROM %Table:SBF% SBF
		WHERE SBF.BF_FILIAL = %Exp:XFILIAL("SBF")%
		AND SBF.BF_PRODUTO = %Exp:cProducto% 
		AND SBF.BF_LOCAL = %Exp:cLocal% 
		AND SBF.BF_LOCALIZ = %Exp:cLocaliz% 
		AND SBF.BF_NUMSERI <> ''
		AND SBF.BF_QUANT > 0
		AND SBF.%notDel%
	EndSql

	Count To nNumRegs

	If nNumRegs > 0
        lSerProd := .T. //Retorna .T. si existe registro en SBF con número de serie
	EndIf

	(cTemp)->(dbCloseArea())
	RestArea(aArea)

Return lSerProd 

/*/{Protheus.doc} WmsEsIntM2
//Funcion destinada a Mercado Internacional - Borra ordem de serviço WMS
@author raul.medina
@since 12/2021
@version 1.0

@type function
/*/
Function WmsEsIntM2()
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cAliasSD2 := ""
Local aArea 	:= GetArea()	
	If lWmsNew
		cAliasSD2 := GetNextAlias()
		BeginSQL Alias cAliasSD2
			SELECT SD2.R_E_C_N_O_ RECNOSD2
			  FROM %Table:SD2% SD2
			 WHERE SD2.D2_FILIAL = %xFilial:SD2%
			   AND SD2.D2_DOC = %Exp:SF2->F2_DOC%
			   AND SD2.D2_SERIE = %Exp:SF2->F2_SERIE%
			   AND SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE%
			   AND SD2.D2_LOJA = %Exp:SF2->F2_LOJA%
			   AND SD2.%NotDel%
		EndSql
		While (cAliasSD2)->(!EoF())
			SD2->(DbGoTo((cAliasSD2)->RECNOSD2))
			lRet := WmsDelDCF("1","SD2")
			(cAliasSD2)->(DbSkip())
		EndDo
		(cAliasSD2)->(DbCloseArea())
	EndIf
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} TudoOkArg
//Funcion destinada a validaciones para Argentina en el tudook.
@author raul.medina
@since 07/2022
@version 1.0
@param cAliasC,cAliasI,cAliasCF,aCabNotaOri,aCpItensOri,aCitensOri,nLinha,cTipDoc,lFormP,aGetsTela,lTela,aCfgNF,nMoedaNF,nMoedaCor,nTaxa,cNFiscal,cSerie
@type function
/*/
Function TudoOkArg(cAliasC,cAliasI,cAliasCF,aCabNotaOri,aCpItensOri,aCitensOri,nLinha,cTipDoc,lFormP,aGetsTela,lTela,aCfgNF,nMoedaNF,nMoedaCor,nTaxa,cNFiscal,cSerie)
Local lRet		:= .T.
Local lVldExp	:= .F.
Local cTipoNFe	:= ""
Local cSF       := IIf(cAliasC == "SF2", "F2", "F1")
Local lMVCdcLoc := SuperGetMV( "MV_CDCLOC", .F., .F. ) //Paramentro consulta factura AFIP
Local cPrefix  	:= IIf(!Empty(cAliasC),cAliasC+"->"+PrefixoCpoc(cAliasC),"") //Prefixo do arquivo de cabecalho
Local cCliFor  	:= ""
Local cLoja    	:= ""
Local cAgente 	:= GetNewPar("MV_AGENTE", "   ")
Local nPos		:= 0
Local aCabNota 	:= aClone(aCabNotaOri)
Local cFunName	:= IIf(Type("cFunName")=="U" .Or. cFunName == Nil,Upper(Alltrim(FunName())),cFunName)	//Funcao Origem
Local aAreaA2	:= SA2->(GetArea())

	If SF1->(Columnpos("F1_IMPNOCF")) > 0 .AND. SF2->(Columnpos("F2_IMPNOCF")) > 0 .And. aCfgNF[SnTipo] >= 6 .aND. aCfgNF[SnTipo] <= 10 
		If  xMoeda(IIF(&("M->" + cSF + "_IMPNOCF") == NIL,0, &("M->" + cSF + "_IMPNOCF")),nMoedaNF,1,dDataBase,,nTaxa) > xMoeda(MaFisRet(,"NF_BASEDUP"),nMoedaNF,1,dDataBase,,nTaxa)
			Aviso(STR0027,STR0028,{STR0001})  //"ATENCIÓN" //"El Monto impuestos no computable como crédito fiscal es mayor que el valor del documento." //"OK"
			lRet := .F.
		Else
			lRet := .T.
		Endif
	EndIf
	If cFunName != "FISA828" .and. SF1->(Columnpos("F1_FEFIDDE")) > 0 .AND. SF2->(Columnpos("F2_FEFIDDE")) > 0 .and. SF1->(Columnpos("F1_FEFIHTA")) > 0 .and. SF2->(Columnpos("F2_FEFIHTA")) > 0 .and. (aCfgNF[SnTipo] == 4 .or. aCfgNF[SnTipo] == 2)
		If Empty(&("M->" + cSF + "_FEFIHTA")) .Or. Empty(&("M->" + cSF + "_FEFIDDE"))
			If  Empty(&("M->" + cSF + "_FEFIDDE")) 
				MsgAlert(STR0029) //"Complete el campo del encabezado: De Fecha."
				lRet := .F.
			Elseif Empty(&("M->" + cSF + "_FEFIHTA"))
				MsgAlert(STR0030) //"Complete el campo del encabezado: A Fecha."
				lRet := .F.
			EndIf 
		Elseif &("M->" + cSF + "_FEFIHTA") >= &("M->" + cSF + "_FEFIDDE")
			if &("M->" + cSF + "_FEFIHTA") <= &("M->" + cSF + "_EMISSAO") .and. &("M->" + cSF + "_FEFIDDE") <= &("M->" + cSF + "_EMISSAO")
				lRet := .T. 
			else
				MsgAlert(STR0031) //"El período informado en los campos De Fecha y A Fecha, no deben ser mayores que la Fecha de emisión de este documento"
				lRet := .F.
			endif
		ElseIf &("M->" + cSF + "_FEFIHTA") < &("M->" + cSF + "_FEFIDDE")
			MsgAlert(STR0032) //"La fecha informada en el campo A Fecha, no debe ser inferior a la fecha informada en el campo De Fecha"
			lRet := .F.
		Endif
	Endif

	If FunName()$ "MATA462AN|MATA462N"
		AtuNumNF(cNFiscal,cSerie)
	EndIf

	SFP->(DbSetOrder(6))
	lVldExp := .F.
	cTipoNFe:= ""
	If  cAliasC == "SF1"
		cTipoNFe := Iif(Alltrim( M->F1_ESPECIE)=="NF","1",Iif(Alltrim( M->F1_ESPECIE)=="NCC","4","5"))
		lVldExp  := Iif( SFP->(MsSeek(xfilial("SFP")+cfilant+cTipoNFe+M->F1_SERIE+Subs(M->F1_DOC,1,4)) ).And.  !Empty(SFP->FP_NFEEX) .And. SFP->FP_NFEEX$"1|2"  ,.T.,.F.)
	Else
		cTipoNFe := Iif(Alltrim( M->F2_ESPECIE)=="NF","1",Iif(Alltrim( M->F2_ESPECIE)=="NCC","4","5"))
		lVldExp  := Iif( SFP->(MsSeek(xfilial("SFP")+cfilant+cTipoNFe+M->F2_SERIE+Subs(M->F2_DOC,1,4)) ).And.  !Empty(SFP->FP_NFEEX) .And. SFP->FP_NFEEX$"1|2",.T.,.F.)
	EndIf

	If cAliasC == "SF1"
		If  lRet .And. lVldExp
			If Strzero(aCfgNF[SnTipo],2)$"01|02|04"
				If  Empty(M->F1_IDIOMA) .OR.  Empty(M->F1_INCOTER)  .OR.  Empty(M->F1_TPVENT) .OR.  Empty(M->F1_PAISENT)
					MsgStop(STR0033,STR0027) //Complete los campos referentes a la Fact. de Export. //"ATENCIÓN"
					lRet := .F.
					EndIf
			EndIf
		EndIf

		If  lRet;
			.And. Valtype(aCfgNF[SlFormProp]) == "L" .And.  Valtype(aCfgNf[SlRemito])=="L";
			.And. !aCfgNf[SlRemito] .And. aCfgNF[SlFormProp]
			If  Empty(M->F1_TPVENT)
				MsgStop(STR0034,STR0027) //El campo de tipo de venta está en blanco //"ATENCIÓN"
				lRet := .F.
			EndIf
		EndIf
	ElseIf cAliasC == "SF2"
		If  lRet .And. lVldExp .And. !(funname()$ "FINA935|FISA828")
			If Strzero(aCfgNF[SnTipo],2)$"01|02|04"
				If  Empty(M->F2_IDIOMA) .OR.  Empty(M->F2_INCOTER)  .OR.  Empty(M->F2_TPVENT) .OR.  Empty(M->F2_PAISENT)
					MsgStop(STR0033,STR0027) //Complete los campos referentes a la Fact. de Export. //"ATENCIÓN"
					lRet := .F.
					EndIf
			EndIf
		EndIf
		If  lRet;
				.And. Valtype(aCfgNF[SlFormProp]) == "L" .And.  Valtype(aCfgNf[SlRemito])=="L";
				.And. !aCfgNf[SlRemito] .And. aCfgNF[SlFormProp]
			If  Empty(M->F2_TPVENT)
				MsgStop(STR0034,STR0027) //El campo de tipo de venta está en blanco //"ATENCIÓN"
				lRet := .F.
			ElseIf M->F2_TPVENT $ "S|A";
				.And.  (Empty(M->F2_FECDSE) .OR. Empty(M->F2_FECHSE))
				MsgStop(STR0035,STR0027) //Fecha ref. a servicios en blanco ## "ATENCIÓN"
				lRet:=.F.
			EndIf
		EndIf
	EndIf
	

	If FunName() <> "MATA143"
		If lRet .AND. SubStr(cAgente,6,1) == "S" .AND.;
			aCfgNF[SnTipo] == 10
			If M->F1_VALSUSS > 	Abs(xMoeda(MaFisRet(,"NF_BASEDUP"),nMoedaNF,nMoedaCor,dDataBase,,nTaxa))
				Aviso(STR0027,STR0036,{STR0001}) //"ATENCAO"###"El valor informado para el S.U.S.S. es mayor que el total de la factura"###"OK"
				lRet := .F.
			EndIf
		EndIf
	EndIf
	//Verifica si el valor informado para SUSS no es mayor que el monto de la NCP
	If lRet .And. aCfgNF[SnTipo] == 7 .and. SubStr(cAgente,6,1) == "S" .And. SF2->(ColumnPos("F2_VALSUSS")) > 0
		If M->F2_VALSUSS > Abs(xMoeda(MaFisRet(, "NF_BASEDUP"), nMoedaNF, nMoedaCor, dDataBase, , nTaxa))
			Aviso(STR0027, STR0036, {STR0001}) //"ATENCAO"###"El valor informado para el S.U.S.S. es mayor que el total de la factura"###"OK"
			lRet := .F.
		EndIf
	EndIf

	If lRet .and. cAliasCF == "SA2"
		//cCliFor
		nPos := Ascan(aCabNota[1], IIf(cAliasC=="SF1","F1_FORNECE","F2_CLIENTE"))
		IIf(nPos>0,cCliFor:=aCabNota[2][nPos],"")
		//cLoja
		nPos := Ascan(aCabNota[1], AllTrim(PrefixoCpo(cAliasC)+"_LOJA"))
		IIf(nPos>0,cLoja:=aCabNota[2][nPos],"")

		SA2->(DBSetOrder(1))
		SA2->(MSSeek(xFilial("SA2")+cCliFor+cLoja))
		
		If Strzero(aCfgNF[SnTipo],2)$ "10|09"
			If lRet  .And.  Upper(Alltrim(M->F1_SERIE))=="M"
				If !Empty(SA2->A2_DTINISM) .And. !Empty(SA2->A2_DTFIMSM) .And. (M->F1_EMISSAO < SA2->A2_DTINISM .or. M->F1_EMISSAO > SA2->A2_DTFIMSM)
					MsgAlert(STR0037,STR0027) //Documento de serie M fuera del período liberado##"ATENCIÓN"
					lRet  := .F.
				EndIf
			EndIf

			// Validade CAI
			If lRet  .And. !Empty(M->F1_VENCAI)
				lRet  :=VenctoCAI(M->F1_EMISSAO,M->F1_VENCAI)
			EndIf

			// Obrigatoriedade do CAI
			If lRet
				If SA2->A2_OBRICAI=="1" .And. Empty(M->F1_CAI)
					MsgAlert(STR0038,"CAI") //Número de CAI obligatorio para este Proveedor
					lRet  := .F.
				EndIf
			EndIf	
		EndIf

		If aCfgNf[SnTipo]  ==7
			If lRet .And.  Upper(Alltrim(M->F2_SERIE))=="M"
				If !Empty(SA2->A2_DTINISM) .And. !Empty(SA2->A2_DTFIMSM) .And. (M->F2_EMISSAO < SA2->A2_DTINISM .or. M->F2_EMISSAO > SA2->A2_DTFIMSM)
					MsgAlert(STR0037,STR0027) //Documento de serie M fuera del período liberado##"ATENCIÓN"
					lRet  := .F.
				EndIf
			EndIf
			
			If lRet .And.  !Empty(M->F2_VENCAI)
				lRet  := VenctoCAI(M->F2_EMISSAO,M->F2_VENCAI)
			EndIf
			
			If lRet
				If SA2->A2_OBRICAI=="1" .And. Empty(M->F2_CAI)
					MsgAlert(STR0038,"CAI") //Número de CAI obligatorio para este Proveedor
					lRet  := .F.
				EndIf
			EndIf
		EndIf
		
		
		//Consulta Metodo comprobante constatar
		If lRet .and. lMVCdcLoc .And. Valtype(aCfgNF[SlFormProp]) == "L" .And.  Valtype(aCfgNf[SlRemito])=="L";
			.And. !aCfgNf[SlRemito] .And. !aCfgNF[SlFormProp] .And. SA2->A2_OBRICAI=="1"
			If cAliasC == "SF1"
				If Empty(M->F1_CODAUT)
					MSGINFO(STR0039) //Código de autorización no informado
					lRet:= .F.
				Endif
				If lRet  .And.  SF1->(ColumnPos("F1_MODCONS")) > 0
					If ( !Empty(M->F1_CAI) .And. AllTrim(M->F1_CODAUT) <> AllTrim(M->F1_CAI))
						lRet:=.F.
						MSGINFO(STR0040) //El campo CAI contiene un valor diferente del campo Cód. Aut
					EndIf
					If lRet .And. (!Empty(M->F1_CAE) .And. M->F1_MODCONS $ "2"  .And. AllTrim(M->F1_CODAUT) <> AllTrim(M->F1_CAE))
						lRet := .F.
						MSGINFO(STR0041) //El campo CAE contiene un valor diferente del campo Cód. Aut
					EndIf
				EndIf
			ElseIf cAliasC == "SF2"
				If Empty(M->F2_CODAUT)
					MSGINFO(STR0039)  //Código de autorización no informado
					lRet:= .F.
				Endif
				If lRet  .And.  SF2->(ColumnPos("F2_MODCONS")) > 0
					If ( !Empty(M->F2_CAI) .And. AllTrim(M->F2_CODAUT) <> AllTrim(M->F2_CAI))
						lRet:=.F.
						MSGINFO(STR0040) //El campo CAI contiene un valor diferente del campo Cód. Aut
					EndIf
					If lRet .And. (!Empty(M->F2_CAE) .And. M->F2_MODCONS $ "2"  .And. AllTrim(M->F2_CODAUT) <> AllTrim(M->F2_CAE))
						lRet := .F.
						MSGINFO(STR0041) //El campo CAE contiene un valor diferente del campo Cód. Aut
					EndIf
				EndIf
			Endif
		EndIf
	EndIf
	
	//Caso o fornec. seja de alguma cidade ou provincia que esteja no parametro MV_RETIIBB valida para que
	//o mesmo seja obrigado a informar ocampo F1_PROVENT ou F2_PROVENT
	If lRet .AND. aCfgNF[SnTipo] <= 10
		If cAliasC == "SF1"
			If Empty(M->F1_PROVENT) .AND. (SA2->A2_EST$GetMV("MV_RETIIBB",,"CF|BA"))
				Aviso(STR0027,STR0042,{STR0001}) //"ATENCIÓN"###"Es necesario informar la ciudad o provincia de entrega del producto o prestación de servicio"###"OK"
				lRet := .F.
			EndIf
		Else
			If Empty(M->F2_PROVENT) .AND. (SA2->A2_EST$GetMV("MV_RETIIBB",,"CF|BA"))
				Aviso(STR0027,STR0042,{STR0001}) //"ATENCIÓN"###"Es necesario informar la ciudad o provincia de entrega del producto o prestación de servicio"###"OK"
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet .and. !aCfgNf[SlRemito]
		If funname() <> "MATA143"
			If lRet .AND. aCfgNF[SlFormProp] 
				lRet := VlMiPyme(aCfgNF[SAliasHead],.F.)
			EndIf
			If lRet .AND. !aCfgNF[SlFormProp]
				lRet := VlCCPyme(aCfgNF[SAliasHead])
			EndIf
		EndIf
		If lRet .And. (RIGHT(cPrefix,2) $ 'F1|F2|')
			lRet := LocXVal(RIGHT(cPrefix,2) + "_DOC",.F.)
		EndIf
	EndIf

	If lRet
		lRet := ValCposRG3668()
	EndIf

	If lRet .And. FindFunction("Compcont") .And. lMVCdcLoc .And. !aCfgNf[SlFormProp]
		If cAliasC == "SF1" .And. (MaFisRet(,'NF_TOTAL') <> M->F1_VALCONS .And. M->F1_VALCONS<>0 ) .And. (Alltrim(aCfgNf[ScEspecie]) $ "NF|NDP") .And. SA2->(ColumnPos("A2_OBRICAI"))>0 .And. SA2->A2_OBRICAI == "1"
			If M->F1_MODCONS == "1"
				lRet := .F.
				MSGINFO(STR0046) //"Valores diferentes en los campos Valor consulta y Total de la factura"
			Else
				lRet := Compcont(cAliasC,cAliasCF,aGetsTela,aCfgNF)
			Endif
		ElseIf cAliasC == "SF1" .And. (Alltrim(aCfgNf[ScEspecie]) $ "NF|NDP")  .And. SA2->(ColumnPos("A2_OBRICAI"))>0 .And. SA2->A2_OBRICAI == "1"
			lRet := Compcont(cAliasC,cAliasCF,aGetsTela,aCfgNF)
			If lRet .And. M->F1_MODCONS $ "1" .And. !Empty(M->F1_CODAUT)
				M->F1_CAI := M->F1_CODAUT
			ElseIf M->F1_MODCONS == "2" .And. !Empty(M->F1_CODAUT)
				M->F1_CAE := M->F1_CODAUT
			EndIf
		Endif
		If    cAliasC == "SF2" .And. (MaFisRet(,'NF_TOTAL') <> M->F2_VALCONS) .And. (Alltrim(aCfgNf[ScEspecie]) $ "NCP") .And. SA2->(ColumnPos("A2_OBRICAI"))>0 .And. SA2->A2_OBRICAI == "1"
			If M->F2_MODCONS == "1"
				lRet := .F.
				MSGINFO(STR0046) //"Valores diferentes en los campos Valor consulta y Total de la factura"
			Else
				lRet := Compcont(cAliasC,cAliasCF,aGetsTela,aCfgNF)
			Endif
		Elseif cAliasC == "SF2" .And. (Alltrim(aCfgNf[ScEspecie]) $ "NCP")   .And. SA2->(ColumnPos("A2_OBRICAI"))>0 .And. SA2->A2_OBRICAI == "1"
			lRet := Compcont(cAliasC,cAliasCF,aGetsTela,aCfgNF)
			If lRet .And. M->F2_MODCONS $ "1" .And. !Empty(M->F2_CODAUT)
				M->F2_CAI := M->F2_CODAUT
			ElseIf M->F2_MODCONS == "2" .And. !Empty(M->F2_CODAUT)
				M->F2_CAE := M->F2_CODAUT
			EndIf
		Endif
	Endif

	RestArea(aAreaA2)

Return lRet 

/*/{Protheus.doc} ArgLinOk
//Funcion destinada a validaciones para Argentina en la funcion NfLinok.
@author raul.medina
@since 07/2022
@version 1.0
@param cAliasI,aCposIOri,cAliasCF,aDadosIOri,cTipDoc,nLinha,lFormP,l103Class,aCfgNf
@type function
/*/
Function ArgLinOk(cAliasI,aCposIOri,cAliasCF,aDadosIOri,cTipDoc,nLinha,lFormP,l103Class,aCfgNf)
Local lRet			:= .T.
Local nI 			:= 0
Local nPosTes		:= 0
Local nPosQuant		:= 0
Local nPosVUnit		:= 0
Local nPosTotal		:= 0
Local nPosEspecie	:= 0
LOCAL cFilSF4		:= xFilial("SF4")
Local aAreaF4		:= SF4->(GetArea())
Local nTamTotal 	:= TamSX3("D1_TOTAL")[2]+1
Local aDadosI		:= aClone(aDadosIOri)
Local aCposI		:= aClone(aCposIOri)

	nPosTes 	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_TES' })
	nPosQuant 	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_QUANT' })
	nPosVUnit 	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+IIf(cAliasI=="SD1","_VUNIT","_PRCVEN") })
	nPosTotal	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_TOTAL'})
	nPosEspecie	:= aScan(aCposI,{|x| AllTrim(x) == PrefixoCpo(cAliasI)+'_ESPECIE'})


	For nI := IIf(nLinha>0,nLinha,1) to IIf(nLinha>0,nLinha,Len(aDadosI))

		If aDadosI[nI][Len(aDadosI[nI])]
			Loop
		EndIf

		If !l103Class
			If lRet .And. nPosTes > 0 .And. nPosQuant > 0 .And. MaTesSel(aDadosI[nI][nPosTes]) .And. aDadosI[nI][nPosQuant] > 0
				Aviso(STR0027,STR0049,{STR0001}) //"ATENCIÓN" ## "¡Cantidad no válida! Verifique el campo Cant. en cero (F4_QTDZERO) en el archivo de TES." ## "OK"
				lRet := .F.
			EndIf
		EndIf

		If nPosTes>0 .AND. nPosQuant>0 .AND. nPosVUnit>0 .AND. nPosTotal>0 .AND.;
			lRet .And. Iif(MaTesSel(aDadosI[nI][nPosTes]).And.aDadosI[nI][nPosQuant]==0,aDadosI[nI][nPosVUnit]<>aDadosI[nI][nPosTotal],;
			(Abs(Abs(aDadosI[nI][nPosTotal] - (aDadosI[nI][nPosVUnit]*aDadosI[nI][nPosQuant])) - (1/(10**(Iif(nTamTotal==0,1,nTamTotal)-1)))/   IIF (nTamTotal==0 ,1,  2)) > (1/(10**(Iif(nTamTotal==0,1,nTamTotal)-1))) / IIF(nTamTotal==0,1,2))) .and. !l103Class
			Aviso(STR0027,STR0047,{STR0001}) //"ATENCIÓN" ## "Inconsistencia en los valores del documento" ## "OK"
			lRet := .F.
		EndIf

		If lRet .and. SF4->(ColumnPos( "F4_CANJE" )) > 0 .and. SF2->(ColumnPos( "F2_CANJE" )) > 0 .and. lCliente .and. aCfgNF[SAliasHead]=="SF2"
			If (nPosTes>0) .And. (SF4->(MsSeek(cFilSF4+aDadosI[nI][nPostes]))) 
				If !(AllTrim(SF4->F4_CANJE) == AllTrim(M->F2_CANJE)) .or. (AllTrim(SF4->F4_CANJE) == "" .and. M->F2_CANJE == "1") .and. aDadosI[nI][nPosEspecie] == "NF"
					Aviso(STR0027,STR0050,{STR0001})//"ATENCIÓN" ## "Los campos 'Canje' de la TES y del documento deben ser iguales (Normal o Canje)" ## "OK"
					lRet := .F.
				EndIf
			EndIf
		EndIf

	Next

	If lRet .and. !aCfgNf[SlRemito] .AND. aCfgNF[SlFormProp]
		lRet := VlMiPyme(aCfgNF[SAliasHead],.t.)
	EndIf

	RestArea(aAreaF4)

Return lRet

/*/{Protheus.doc} FilPVArg
Función utilizada para filtrar SX5 con las series que determinado PV posee.
@author raul.medina
@since 07/2022
@version 1.0

@type function
/*/
Function FilPVArg()
Local cRet 		:= ""
Local cIdPV		:= ""
Local nPosIni 	:= 0
Local cCombo  	:= ""
Local cFilSFP 	:= xFilial("SFP")
Local AreaSX3 	:= {}
local nCount  	:= 0
Local cSFPEsp	:= ""

If Funname()== "FINA096" .and. Type("cEspecie") <>"C"
	cEspecie:= "NDC"
EndIf

If Type("cEspecDoc") =="C" .and. cEspecDoc $ "RFD"
	AreaSX3 := GetArea()
		SX3->(dbSetOrder(2))
		SX3->(dbSeek("FP_ESPECIE"))
		nPosIni := At(AllTrim(cEspecie),AllTrim(SX3->X3_CBOX))
		cCombo := Substr(AllTrim(SX3->X3_CBOX),nPosIni-2,1)
	RestArea(AreaSX3)
EndIf

If   Type("cEspecie") =="C" .and. (cLocxNFPV <> "") .And. (cPVOld <> cLocxNFPV)
	cRet := "(''==X5_CHAVE)"
	If AllTrim(cEspecie) == "NF"
		cSFPEsp := "1"
	ElseIf AllTrim(cEspecie) == "NCI"
		cSFPEsp := "2"
	ElseIf AllTrim(cEspecie) == "NDI"
		cSFPEsp := "3"
	ElseIf AllTrim(cEspecie) == "NCC"
		cSFPEsp := "4"
	ElseIf AllTrim(cEspecie) == "NDC"
		cSFPEsp := "5"
	ElseIf AllTrim(cEspecie) == "RFN" .or. AllTrim(cEspecie) == "RTS" .or. AllTrim(cEspecie) == "RCD"
		cSFPEsp := "6"
	ElseIf AllTrim(cEspecie) == "RFD" .or. AllTrim(cEspecie) == "RCD"
		cSFPEsp := "7"
	ElseIf AllTrim(cEspecie) == "RET"
		cSFPEsp := "8"
	EndIf
	cPVOld := cLocxNFPV
	cIdPV := POSICIONE("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
	("SFP")->(DbSetOrder(9))
	If ("SFP")->(MsSeek(xFilial("SFP")+cLocxNFPV))
		cRet := ""
		While (SFP->(!EOF())) .And. (SFP->FP_PV = cLocxNFPV)
			If Type("cEspecDoc") =="C" .and. cEspecDoc $ "RFD"
				If AllTrim(SFP->FP_ESPECIE) == AllTrim(cCombo) .AND. dDataBase <= SFP->FP_DTAVAL
					If cRet == ""
						cRet := "("
					Else
						cRet += " .OR. "
					EndIf
					cRet += "'" + AllTrim(SFP->FP_SERIE) + cIdPV + "' $ X5_CHAVE"
				EndIf
			Else
				If AllTrim(SFP->FP_ESPECIE) == cSFPEsp .or. AllTrim(SFP->FP_ESPECIE) == ""
					If cRet == ""
						cRet := "("
					Else
						cRet += " .OR. "
					EndIf
					cRet += "'" + AllTrim(SFP->FP_SERIE) + cIdPV + "' $ X5_CHAVE"
				EndIf
			EndIf
			SFP->( DBSkip() )
		EndDo
		If cRet <> ""
			cRet += ")"
		EndIf
		cRetOld := cRet
	EndIf
Else
	cRet := Iif(Empty(cRetOld),"(''==X5_CHAVE)",cRetOld)
EndIf

If Type("cEspecDoc") =="C" .and.   cEspecDoc $ "RFD"
	cRet := Iif(Empty(cRetOld),"(''==X5_CHAVE)",cRetOld)
EndIF

If Empty(cRet)
	Return(.f.)
Else
	Return &cRet
EndIf

/*/{Protheus.doc} ArgRG1415
Função utilizada para preencer o campo correspondente ao RG1415 nas
tabelas SF1 e SF2.
@author raul.medina
@since 07/2022
@version 1.0
@param aNfs,cFilAnt,lLocxAuto,dDemissao
@type function
/*/
Function ArgRG1415(aNfs)
Local cCmp 		:= ReadVar()
Local cPrefixo 	:= ""
Local cAlias 	:=""
Local cSerie	:=  ""
Local cEspec	:= ""
Local cPV		:= ""
Local cSerieP	:=""
Local cModulo 	:= " "
Local cRG1415	:=""
Local lret		:= .T.
Local lMata468n	:= .F.
Local cCAEA		:= ""
Local dCAEAVENC	:= CTOD("\\")
Local dDemis	:= dDatabase
Local cNFiscal	:=""
Local nVlrDoc	:= 0
Default anfs	:={}

	If  FunName() $ "MATA468N|MATA461|MATA460B"   .And. Len(aNfs)>0
		lMata468n:=.t.
	EndIf

	If MaFisFound()
		cTpCliFor := MaFisRet(,"NF_CLIFOR")
		cModulo := Iif(cTpCliFor == "F",'2','1')
		cSerie	:= MaFisRet(,"NF_SERIENF")
	EndIf

	If lMata468n
		cPrefixo := "F2"
		cAlias 	:= "SF2"
		cSerie	:=  aNfs[1] // SubStr(&("M->"+ cPrefixo + "_SERIE"),1,1)
		cEspec	:= aNfs[9]
		cPV	:= Subs(aNfs[2],1, TamSx3( "F2_PV")[1])
		cSerieP:=aNfs[1]
		cModulo := "1"
		nVlrDoc	:= aNfs[14]
		cRG1415:= LxNFRG1415(cAlias, cSerie, cEspec,cPV,cSerieP, nVlrDoc, .T.)
	Else
		cPrefixo := SubStr(cCmp, AT("_", cCmp)-2, 2)
		cAlias := "S" + cPrefixo
		cSerieP	:= Padr(&("M->" + cPrefixo + "_SERIE"),Tamsx3("F2_SERIE")[1])
		cEspec	:= &("M->" + cPrefixo + "_ESPECIE")
		cPV	:= ""
		cSerie:=cSerieP
		cNFiscal:= &("M->" + cPrefixo + "_DOC")
		cModulo := Iif( cAlias == "SF1", '2','1')
		cCampo:= "M->"+ cPrefixo + "_PV"
		If Type(cCampo)=='C'
			cPV:= SubStr(&("M->"+ cPrefixo + "_PV"),1,TamSx3( cPrefixo + "_PV")[1] )
		EndIf

		cRG1415:= LxNFRG1415(cAlias, cSerie, cEspec,cPV,cSerieP)
		cPrefixo := SubStr(cCmp, AT("_", cCmp)-2, 2)
	EndIf

	If !lMata468n
		lRet  := VldNFCAEA(cFilAnt,cSerie,cNFiscal,lLocxAuto,cEspec,dDemissao,@cCaea,@dCAEAVENC)
	EndIf

	If lRet .And. ( (cModulo <>"2" .And. Alltrim(cEspec) $ ("NF") ) .or. Alltrim(cEspec) $ ("NDC|NCC")) .and. SA1->(ColumnPos("A1_TAMEMP") > 0 )
		If Val(cRG1415) >= 200 .and. !( ( GetNewPar("MV_TAMEMP",'1') == "1"	 .and. SA1->A1_TAMEMP $ "2|3|4" ) .Or. ( GetNewPar("MV_TAMEMP",'1') $ "3|4" .and. SA1->A1_TAMEMP $ "4" ) )
			lret:=.F.
			MsgAlert(OemToAnsi(STR0043)+ " : " + cSerieP + OemToAnsi(STR0044),OemToAnsi(STR0045)) //"Serie" ## "es una serie de documento del tipo FCE, y por clasificación del cliente no es posible utilizarla. Verifique la correcta clasificación." ## "Documento FCE"
		EndIf
	EndIf
	If lMata468n .and. ( GetNewPar("MV_TAMEMP",'1') $ "1" .And.  SA1->(ColumnPos("A1_TAMEMP") > 0 ) .and. SA1->A1_TAMEMP $ "2|3|4"  ) ;
		.And. SA1->(ColumnPos("A1_CLAFISC") > 0) .and. !Empty(SA1->A1_CLAFISC) .and.  nVlrDoc <> 0 .and. SX5->(MsSeek(xFilial("SX5")+"WG"+SA1->A1_CLAFISC))
		If Val(cRG1415) >= 200
			lret:= nVlrDoc > Val(X5Descri())
			If !lret
				MsgAlert(OemToAnsi(STR0043)+ " : " + cSerieP + OemToAnsi(STR0044),OemToAnsi(STR0045)) //"Serie" ## "es una serie de documento del tipo FCE, y por clasificación del cliente no es posible utilizarla. Verifique la correcta clasificación." ## "Documento FCE"
			EndIf
		EndIf
		If Val(cRG1415) <  200
			lret:= nVlrDoc < Val(X5Descri())
			If !lret
				MsgAlert("<200"+OemToAnsi(STR0043)+ " : " + cSerieP + OemToAnsi(STR0044),OemToAnsi(STR0045)) //"Serie" ## "es una serie de documento del tipo FCE, y por clasificación del cliente no es posible utilizarla. Verifique la correcta clasificación." ## "Documento FCE"
			EndIf
		EndIf
	EndIf

	If !lMata468n
		&('M->' + cPrefixo + '_RG1415') := cRG1415
	EndIf


Return lret


/*/{Protheus.doc} ArgRG1415
Função utilizada para preencer o campo correspondente ao RG1415 nas
tabelas SF1 e SF2.
@author raul.medina
@since 07/2022
@version 1.0
@param cAlias, cSerie, cEspec,cPV,cSerieP,nVlrDoc,lMata468n
@type function
/*/
Function xNFRG1415(cAlias, cSerie, cEspec,cPV,cSerieP,nVlrDoc,lMata468n)
Local cPrefixo 	:= SubStr(cAlias,2,2)
Local cModulo 	:= Iif( cAlias == "SF1", '2','1')
Local cCmpCtrl 	:= ""
Local nPosIni 	:= 0
Local cRet 		:= ""
Local cTpCliFor := "C"
Local cRg1415SFP:=""
Local aAreaAtu	:=GetArea()
Local aAreaSFP	:=SFP->(GetArea())
Local aAreaDBB	:= {}
Local cEspecP	:=""
Local cEspcP	:= ""
Local cCampo	:= "M->"+ cPrefixo + "_PV"
Local lretVl 	:= .F.


Default cSerieP		:= &(cAlias + '->' + cPrefixo + '_SERIE')
Default cPV			:= ""
Default	cEspec		:= &(cAlias + '->' + cPrefixo + '_ESPECIE')
Default nVlrDoc		:= 0
Default lMata468n	:= .F.

If Type(cCampo)=='C'
	cPV:= &(cAlias + '->' + cPrefixo + '_PV')
EndIf

If MaFisFound()
	cTpCliFor := MaFisRet(,"NF_CLIFOR")
	cModulo := Iif(cTpCliFor == "F",'2','1')
	cSerieP:=  Iif(Empty(cSerieP),Padr(&("M->" + cPrefixo + "_SERIE"),Tamsx3("F2_SERIE")[1]),cSerieP) //    &("M->" + cPrefixo + "_SERIE")
	cCampo:= &("M->"+ cPrefixo + "_PV")
	If Type("cCampo") <> "U"  .and.   ValType(cCampo) == 'C'
		cPV	:= SubStr(&("M->"+ cPrefixo + "_PV"),1,TamSx3( cPrefixo + "_PV")[1] )
	EndIf
EndIf

cEspcP:=Alltrim(cEspec)

//Verifica os campos F1/F2_LIQPROD por conta dos tipos de comprovante
//com comprovante igual a "Cuenta de Venta y Producto Líquido".
If ((&(cAlias + '->(FieldPos("' + cPrefixo + '_LIQPROD"))')) > 0)
	If cModulo == '1' .And. cEspec == '1'
		cCmpCtrl := Iif(&(cAlias + '->' + cPrefixo + '_LIQPROD') == '1', '1', '2')
	Else
		If cModulo == '2' .And. cEspec == '1'
			If (&(cAlias + '->' + cPrefixo + '_LIQPROD') == '1')
				cCmpCtrl := '1'
			EndIf
		ElseIf (cAlias == "SF1")
			If SF1->F1_TIPO == "C" .AND. SF1->F1_TIPODOC $ "13/14"
				cCmpCtrl := '3'
			EndIf
		Else
			cCmpCtrl := '2'
		EndIf
	EndIf
Else
	cCmpCtrl := '2'
EndIf

If cModulo == '1' .and. SA1->(ColumnPos("A1_TAMEMP") > 0)
	If  ( GetNewPar("MV_TAMEMP",'1') == "1"	 .and. SA1->A1_TAMEMP $ "2|3|4"  ) .Or.  ( GetNewPar("MV_TAMEMP",'1') $ "3|4" .and. SA1->A1_TAMEMP $ "4" )
		If lMata468n .and.  SA1->(ColumnPos("A1_CLAFISC") > 0) .and. !Empty(SA1->A1_CLAFISC) .and.  nVlrDoc <> 0 .and. SX5->(MsSeek(xFilial("SX5")+"WG"+SA1->A1_CLAFISC))
			lretVl:= nVlrDoc >= Val(X5Descri())
		EndIf
		If lretVl
			cCmpCtrl := '4'
		Endif
	EndIf
EndIf

cEspec := Iif(Len(cEspec)<3, cEspec + ' ', cEspec)
//Busca o RG1415

("CFG")->(DbSetOrder(2))
If ("CFG")->(MsSeek(xFilial("CFG") + cModulo + cEspec + cCmpCtrl + cSerie))
	cRet :=  CFG->CFG_RG1415
EndIf

If FwIsInCallStack("MATA143") .And. DBB->(FieldPos("DBB_RG1415"))>0 
	aAreaDBB	:=DBB->(GetArea())
	dbSelectArea("DBB")
	DBB->(dbGoTop())
	dbSetOrder(1)
	If DBB->(MsSeek(xFilial("DBB") +SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA) )
		If !Empty(DBB->DBB_RG1415)
			cRet :=  DBB->DBB_RG1415
		EndIf
	EndIf
	DBB->(RestArea(aAreaDBB))
EndIf

If  SFP->(ColumnPos("FP_RG1415")) > 0
	cEspecP:=""

	Do Case
		Case cEspcP == "NF"
			cEspecP := "1"
		Case cEspcP == "NCC"
			cEspecP := "4"
		Case cEspcP == "NDC"
			cEspecP := "5"
	EndCase
	dbSelectArea("SFP")
	SFP->(dbGoTop())
	dbSetOrder(5)
	If SFP->(DbSeek(xFilial("SFP")+cFilAnt+cSerieP+cEspecP+cPV) )
		If !Empty(SFP->FP_RG1415)
			cRet :=  SFP->FP_RG1415
		EndIf
	EndIf
	SFP->(RestArea(aAreaSFP))
	RestArea(aAreaAtu)
EndIf

Return cRet

/*/{Protheus.doc} LArgVldSer
Função utilizada para validar se a série informada pode ser utilizada;
Baseando-se na regra de relacionamento entre o ponto de venda e a SFP.
Rotina usada no controle de ponto de venda - Argentina. 
Función llamada por LNF2VldSer
@author raul.medina
@since 07/2022
@version 1.0
@param cLocxNFPV
@type function
/*/
Function LArgVldSer(cLocxNFPV)
Local lRet 		:= .F.
Local cCmp 		:= ReadVar()
Local cSerie	:= SubStr(&(cCmp),1,TamSX3("FP_SERIE")[1])
Local nTamSFP 	:= TamSX3("FP_SERIE")[1]

	If cLocxNFPV <> ""
		("SFP")->(DbSetOrder(9))
		If ("SFP")->(MsSeek(xFilial("SFP")+cLocxNFPV))
			While (SFP->(!EOF())) .And. (SFP->FP_PV = cLocxNFPV)
				If Alltrim(cSerie) == Alltrim(SubStr(SFP->FP_SERIE,1,nTamSFP)) .And. SFP->FP_ATIVO <> "2"
					lRet := .T.
				EndIf

				SFP->( DBSkip() )
			EndDo
		EndIf
	EndIf

	If !(lRet)
		Alert(STR0059)//"No existe relacionamiento entre el punto de venta y la serie informada."
	EndIf

Return lRet


/*/{Protheus.doc} GrvCabDoc
	(Incluye información en el encabezado del documento)
	@type  Function
	@author Arturo Samaniego
	@since 06/07/2022
	@param aCabNota,aCabNotaOri,aCfgNf
	@return Nil
	/*/
Function GrvCabDoc(aCabNota,aCabNotaOri,aCfgNf)
Local nAdic5 := 0
Local nAdic61 := 0
Local nAdic62 := 0
Local nAdic7 := 0
Local cCfo := SuperGetMV("MV_CFO3668",.T.,"")
Local cFunName := FunName()
Local nPosSerie  := 0
Local nPosEspec  := 0
Local nPosRG1415 := 0
Local cAlias     := ""

Default aCabNota    := {}
Default aCabNotaOri := {}

	cAlias := aCfgNf[SAliasHead]

	If !Empty(cAlias) 
		If !Empty(cCfo) .and. (cFunName $ "MATA467N|MATA465N|MATA468N")
			nAdic5  := Ascan(aCabNotaOri[1],PrefixoCpo(cAlias)+ "_ADIC5")
			nAdic61 := Ascan(aCabNotaOri[1],PrefixoCpo(cAlias)+ "_ADIC61")
			nAdic62 := Ascan(aCabNotaOri[1],PrefixoCpo(cAlias)+ "_ADIC62")
			nAdic7  := Ascan(aCabNotaOri[1],PrefixoCpo(cAlias)+ "_ADIC7")

			If nAdic5 > 0 .and. cAlias == "SF1"
				If aCabNota[2][nAdic5] <> M->F1_ADIC5 .and. M->F1_ADIC5 == Space(TamSX3("AI0_ADIC5")[1])
					aCabNota[2][nAdic5]   	:= M->F1_ADIC5
					aCabNotaOri[2][nAdic5]	:= M->F1_ADIC5

					aCabNota[2][nAdic61]   	:= M->F1_ADIC61
					aCabNotaOri[2][nAdic61]	:= M->F1_ADIC61

					aCabNota[2][nAdic62]   	:= M->F1_ADIC62
					aCabNotaOri[2][nAdic62]	:= M->F1_ADIC62

					aCabNota[2][nAdic7]   	:= M->F1_ADIC7
					aCabNotaOri[2][nAdic7]	:= M->F1_ADIC7
				Endif
			ElseIf nAdic5 > 0 .and. cAlias == "SF2"
				If aCabNota[2][nAdic5] <> M->F2_ADIC5 .and. M->F2_ADIC5 == Space(TamSX3("AI0_ADIC5")[1])
					aCabNota[2][nAdic5]   	:= M->F2_ADIC5
					aCabNotaOri[2][nAdic5]	:= M->F2_ADIC5

					aCabNota[2][nAdic61]   	:= M->F2_ADIC61
					aCabNotaOri[2][nAdic61]	:= M->F2_ADIC61

					aCabNota[2][nAdic62]   	:= M->F2_ADIC62
					aCabNotaOri[2][nAdic62]	:= M->F2_ADIC62

					aCabNota[2][nAdic7]   	:= M->F2_ADIC7
					aCabNotaOri[2][nAdic7]	:= M->F2_ADIC7
				Endif
			Endif
		Endif

		If cFunName == "MATA143"
			nPosSerie := Ascan(aCabNota[1],"F1_SERIE")
			nPosEspec := Ascan(aCabNota[1],"F1_ESPECIE")
			nPosRG1415 := Ascan(aCabNota[1],"F1_RG1415")

			aCabNota[2][nPosRG1415] := LxNFRG1415("SF1", aCabNota[2][nPosSerie], aCabNota[2][nPosEspec],,,,.F.)
		EndIf
	EndIf

Return

/*/{Protheus.doc} ArgActSF2
	(Actualiza SF2 para Argentina)
	@type  Function
	@author Arturo Samaniego
	@since 07/07/2022
	@param lContFol,aCols,aHeader
	@return Nil
	/*/
Function ArgActSF2(lContFol,aCols,aHeader)
Local aAreaSB5 := {}
Local nValcot  := 0
Local nZ       := 0
Local lSb5 	   := .F.
Local cMVDesc	:= GetNewPar('MV_DESCSAI','1')
Local nCod		:= 0
Local nTotal	:= 0
Local nDescont	:= 0

Default lContFol := .F.

	If lContFol
		SF2->F2_CAI := SFP->FP_CAI
		SF2->F2_VENCAI := SFP->FP_DTAVAL
	EndIf

	If SF2->(ColumnPos("F2_VALCOT")) > 0
		nCod		:= ASCAN(aHeader, {|x| AllTrim(x[2]) == "D2_COD"})
		nTotal		:= ASCAN(aHeader, {|x| AllTrim(x[2]) == "D2_TOTAL"})
		nDescont	:= ASCAN(aHeader, {|x| AllTrim(x[2]) == "D2_DESCON"})
		aAreaSB5 := GetArea()
		DbSelectArea("SB5")
		SB5->(DbSetorder(1))
		For nZ := 1 to Len(aCols)
			lSb5 := SB5->(MsSeek(xFilial("SB5") + acols[nZ, nCod]))
			If !lSb5 .Or. AllTrim(SB5->B5_TPORIG) != "O"
				nValcot += acols[nZ, nTotal]
				If  cMVDesc =='2' .And. acols[nZ, nDescont] > 0
					nValcot -= acols[nZ, nDescont]
				EndIf
			EndIf
		Next nZ
		SF2->F2_VALCOT := nValcot
		RestArea(aAreaSB5)
	EndIf
	
Return

/*/{Protheus.doc} ArgActItem
	(Actualiza ítem SD1/SD2 para Argentina)
	@type  Function
	@author Arturo Samaniego
	@since 07/07/2022
	@version version
	@param cAlias, cTipo, cDescSai, oArrayTes
	@return Nil
	/*/
Function ArgActItem(cAlias, cTipo, cDescSai, oArrayTes)
Local cFilSFB := xFilial("SFB")
Local aAreaSD := {}
Local nX        := 0
Local nT_VUNIT	:= TamSX3("D1_VUNIT")[2]

Default cAlias := ""
Default cTipo  := ""
Default cDescSai := ""
Default oArrayTes := NIL

	If cAlias == "SD1" .AND. cTipo == "D" .And. cDescSai == "2" .And. ALLTRIM(M->F1_ESPECIE) == "RFD"
		SD1->D1_TOTAL  := SD1->D1_TOTAL - SD1->D1_VALDESC
		SD1->D1_VUNIT  := NoRound(SD1->D1_TOTAL/SD1->D1_QUANT,nT_VUNIT)
	EndIf

	If cAlias=="SD1"
		If oArrayTes:oTes[SD1->D1_TES] == Nil
			oArrayTes:AddTes(SD1->D1_TES)
			aAreaSD := GetArea()
			SFC->(DBGoTop())
			SFC->(dbSetOrder(1))
			SFB->(dbSetOrder(1))
			If SFC->(MsSeek(xFilial("SFC") + SD1->D1_TES))
				Do While SFC->(!Eof()) .And. SD1->D1_TES == SFC->FC_TES
					If SFB->(MsSeek(cFilSFB+SFC->FC_IMPOSTO))
						If SFB->FB_DESGR <> 0 .And. ExisteCampo("D1_DESGR"+SFB->FB_CPOLVRO,.T.)[1]
							&("SD1->D1_DESGR"+SFB->FB_CPOLVRO) := SFB->FB_DESGR
							oArrayTes:AddImpuesto(SD1->D1_TES, SFC->FC_IMPOSTO, SFB->FB_CPOLVRO, SFB->FB_DESGR)
						EndIf
					EndIf
					SFC->(dbSkip())
				EndDo
			EndIf
			RestArea(aAreaSD)
		Else
			For nX := 1 To Len(oArrayTes:oTes[SD1->D1_TES]['Impuestos'])
				&("SD1->D1_DESGR"+oArrayTes:oTes[SD1->D1_TES]['Impuestos'][nX]['FB_CPOLVRO']) := oArrayTes:oTes[SD1->D1_TES]['Impuestos'][nX]['FB_DESGR']
			Next nX
		EndIf
	EndIf
	If cAlias=="SD2" .And. Alltrim(SD2->D2_ESPECIE) == "NCP"
		If oArrayTes:oTes[SD2->D2_TES] == Nil
			oArrayTes:AddTes(SD2->D2_TES)
			aAreaSD := GetArea()
			SFC->(DBGoTop())
			SFC->(dbSetOrder(1))
			SFB->(dbSetOrder(1))
			If SFC->(MsSeek(xFilial("SFC") + SD2->D2_TES))
				Do While SFC->(!Eof()) .And. SD2->D2_TES == SFC->FC_TES
					If SFB->(MsSeek(cFilSFB+SFC->FC_IMPOSTO))
						If SFB->FB_DESGR <> 0 .And. ExisteCampo("D2_DESGR"+SFB->FB_CPOLVRO,.T.)[1]
							&("SD2->D2_DESGR"+SFB->FB_CPOLVRO) := SFB->FB_DESGR
							oArrayTes:AddImpuesto(SD2->D2_TES, SFC->FC_IMPOSTO, SFB->FB_CPOLVRO, SFB->FB_DESGR)
						EndIf
					EndIf
					SFC->(dbSkip())
				EndDo
			EndIf
			RestArea(aAreaSD)
		Else
			For nX := 1 To Len(oArrayTes:oTes[SD2->D2_TES]['Impuestos'])
				&("SD2->D2_DESGR"+oArrayTes:oTes[SD2->D2_TES]['Impuestos'][nX]['FB_CPOLVRO']) := oArrayTes:oTes[SF4->F4_CODIGO]['Impuestos'][nX]['FB_DESGR']
			Next nX
		EndIf
	Endif

Return

/*/{Protheus.doc} ArgGeraLF
	(Libro Fiscal Argentina)
	@type  Function
	@author Arturo Samaniego
	@since 08/07/2022
	@version version
	@param lFolios,aCfgNF
	@return Nil
	/*/
Function ArgGeraLF(lFolios,aCfgNF)
Local aAreaAnt := {}
Local aSF3 := {}
Local cKey  := ""
Local cAlias := aCfgNF[SAliasHead]

Default lFolios := .F.

	If SF4->F4_GERALF == "1"
		aAreaAnt := GetArea()
		DbSelectArea("SF3")
		aSF3 :=	GetArea()
		SF3->(DbSetOrder(1))
		If cAlias == 'SF1'
			cKey := xFilial('SF3') + SF1->(Dtos(F1_DTDIGIT) + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)			
		Else
			cKey := xFilial('SF3') + SF2->(Dtos(F2_DTDIGIT) + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
		Endif
		SF3->(MsSeek(cKey))
		While !SF3->(EOF()) .and. SF3->(F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) ==  cKey
			If SF3->F3_ESPECIE == IIF(cAlias == 'SF1', SF1->F1_ESPECIE, SF2->F2_ESPECIE)
				SF3->(RecLock("SF3",.F.))
				If cAlias == 'SF1'
					If lFolios
						Replace F3_PV With SF1->F1_PV
					EndIf
					Replace F3_RG1415 With SF1->F1_RG1415
				Else
					If lFolios
						Replace F3_PV With SF2->F2_PV
					EndIf
					Replace F3_RG1415 With SF2->F2_RG1415
				EndIf
				SF3->(MsUnlock())
			Endif
			SF3->(DbSkip())
		End
		RestArea(aSF3)
		RestArea(aAreaAnt)
	EndIf
Return


/*/{Protheus.doc} ArgGRemTrf
	(Incluye campos para remito de transferencia - Argentina)
	@type  Function
	@author Arturo Samaniego
	@since 08/07/2022
	@param aCposSD1, lRastro, lWmsNew
	@return Nil
	/*/
Function ArgGRemTrf(aCposSD1, lRastro, lWmsNew)
Default aCposSD1 := {}
Default lRastro := .F.
Default lWmsNew := .F.

	If ValType(aCposSD1) == "A"
		If lWmsNew .And. Funname() == "MATA462TN"
			AADD(aCposSD1[1], "D1_SERVIC"); AADD(aCposSD1[2], 'Posicione("SB5",1,xFilial("SB5")+SD2->D2_COD,"B5_SERVENT") ')
			AADD(aCposSD1[1], "D1_ENDER"); AADD(aCposSD1[2], 'Posicione("SB5",1,xFilial("SB5")+SD2->D2_COD,"B5_ENDECD") ')
		EndIf
	EndIf
Return

/*/{Protheus.doc} ArgVlCruz
	(Genera valor cruzado SE1/SE2)
	@type  Function
	@author Arturo Samaniego
	@since 08/07/2022
	@param cAliasFin, nMoedaNF, nTaxa
	@return nVlCruz
	/*/
Function ArgVlCruz(cAliasFin, nMoedaNF, nTaxa)
Local nVlCruz := 0

	If cAliasFin == "SE1"
		If nMoedaNF == 1
			nVlCruz := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,SE1->E1_EMISSAO,MsDecimais(1)+1,IIF(nMoedaNF==SE1->E1_MOEDA,0,nTaxa)),MsDecimais(1))
		Else
			nVlCruz := Round(xMoeda(SE1->E1_VALOR, SE1->E1_MOEDA, 1, SE1->E1_EMISSAO, MsDecimais(1)+1, IIF(nMoedaNF==SE1->E1_MOEDA,nTaxa,0), ), MsDecimais(1))
		EndIf
	Else
		nVlCruz := Round(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,MsDecimais(1)+1,nTaxa),MsDecimais(1))
	EndIf
Return nVlCruz


/*/{Protheus.doc} Tes_Impuesto
	(TES con Impuestos)
	@author Arturo Samaniego
	@since 11/07/2022
	/*/
Class Tes_Impuesto
	Data oTes As Objetc

	Method New() Constructor
    Method AddTes()
	Method AddImpuesto()
EndClass


Method New(cTes) Class Tes_Impuesto
	Self:oTes := JsonObject():New()
Return Self

Method AddTes(cTes) Class Tes_Impuesto
	Self:oTes[cTes] := JsonObject():New()
	Self:oTes[cTes]['Impuestos'] := {}
Return Self


Method AddImpuesto(cTes, cCod, cCpoLF, nDesGR) Class Tes_Impuesto
Local oImpuesto :=  JsonObject():New()

	oImpuesto['FB_CODIGO'] := Alltrim(cCod)
	oImpuesto['FB_CPOLVRO'] := Alltrim(cCpoLF)
	oImpuesto['FB_DESGR']  := nDesGR

	aAdd(Self:oTes[cTes]['Impuestos'], oImpuesto)
Return Self


/*/{Protheus.doc} VldSitComp
	(Constatación de Comprobante AFIP)
	@type  Function
	@author Arturo Samaniego
	@since 08/07/2022
	@param cAliasC,cAliasCF,aGetsTela,aCfgNF,lvalcons
	@return lVld
	/*/
Function VldSitComp(cAliasC,cAliasCF,aGetsTela,aCfgNF,lvalcons)
Local lVld		:= .F.
Local lMVCdcLoc := SuperGetMV( "MV_CDCLOC", .F., .F. )
Local cURL		:= (PadR(GetNewPar("MV_ARGNEUR","http://"),250))
Local cIdEnt		:= ""
Local cMod := ""
Local cCbteNro := ""
Local cAutoriz := ""
Local cDocNr := ""
Local cErro:=""
Local cMsg := ""
Local cMensagem := ""
Local cResult := ""
Local cCbteTipo := ""
Local cTpDocRcp := ""
Local lControl := .T.
Local cSerie := ""
Local cEspdoc := ""
Local cTeste1 := ""
Local cTeste3 := ""
Local nComp := 0
Local lExecute := .T.

Private oWS
Private oWsE

Default cAliasC:= ""
Default cAliasCF := ""
Default aGetsTela := {}
Default aCfgNF := {}
Default lvalcons := .F.

//"NF" - FACTURA
//"NDP" - NOTA DEB.
//"NCP" - NOTA CRED.
If cAliasC == "SF1"
	cSerie := Alltrim(M->F1_SERIE)
	cEspdoc := Alltrim(M->F1_ESPECIE)
Else
	cSerie := Alltrim(M->F2_SERIE)
	cEspdoc := Alltrim(M->F2_ESPECIE)
Endif
cCbteTipo := Rettpdoc(cSerie,cEspdoc,cAliasC) //Retorna o tipo do documento

SX5->(DbSetOrder(1) )
If SX5->(MsSeek(xFilial("SX5") + "OC" + SA2->A2_AFIP))
	cTpDocRcp := SubStr(SX5->X5_DESCRI,1,2)
Endif

If cAliasC == "SF1" .And. (Empty(M->F1_CODAUT) .OR. Empty(M->F1_MODCONS)) .And. lMVCdcLoc
	MSGINFO(STR0060) //"Verifique la cumplimentación de los campos Mod. Cons y Cód Aut."
	lControl := .F.
Elseif cAliasC == "SF2" .And. (Empty(M->F2_CODAUT) .OR. Empty(M->F2_MODCONS)) .And. lMVCdcLoc
	MSGINFO(STR0060) //"Verifique la cumplimentación de los campos Mod. Cons y Cód Aut."
	lControl := .F.
Endif

If lMVCdcLoc .And. !aCfgNf[3] .And. lControl
 	cIdEnt  := StaticCall( Locxnf2, GetIdEnt)

	//Metodo que verifica se o solicitação para consulta esta valida
	oWs := WSWSFEV1():New()

	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL)+"/WSFEV1.apw"

	oWSE:= WSNFESLOC():New()

	cData:=	 FsDateConv(Date(),"YYYYMMDD")
	cData := SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7)

	oWSE:CDATETIMEGER:=cData+"T00:00:00"
	oWSE:cDATETIMEEXP:=cData+"T23:59:59"

	oWsE:cUserToken := "TOTVS"
	oWsE:cID_ENT    := cIdEnt
	oWSE:_URL       := AllTrim(cURL)+"/NFESLOC.apw"
	oWsE:cCWSSERVICE  := "wscdc"
	oWSE:GETAUTHREM()

	If GetWscError(1) == "" .Or. "005" $ GetWscError(1) .Or. "005" $ GetWscError(3)

		lExecute:=.T.
		cTeste1 := GetWscError(1)
		cTeste3 := GetWscError(3)

		If cTeste1 == Nil .Or. cTeste3 == Nil
			lExecute:=.F.
			nComp:=1
			While nComp < 5 .And. !lExecute
				oWSE:GETAUTHREM()
				cTeste1 := GetWscError(1)
				cTeste3 := GetWscError(3)
				If cTeste1 <> Nil .And. cTeste3 <> Nil
					lExecute:=.T.
				EndIf
				nComp:=nComp+1
			EndDo
		Endif

		//Método que realiza a consulta na AFIP.
		oWS := WSNFESLOC() :New()
		oWs:cUSERTOKEN := "TOTVS"
		oWs:cID_ENT    	:= cIdEnt
		oWs:CCUIT			:= IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
		oWS:CCBTEMODO		:= "5" //WSCDC - Deve ser 5 para gravar os campos de autorização no TSS função GetAutInfo()
		oWS:_URL       	:= AllTrim(cURL)+"/NFESLOC.apw"

		If cAliasC == "SF1"
			oWs:CCUITEMISOR	:= (cAliasCF)->A2_CGC
			oWs:CPTOVTA		:= SubStr(M->F1_DOC,1,4)
			oWs:CCBTETIPO		:= cCbteTipo
			oWs:CCBTENRO		:= SubStr(M->F1_DOC,5,12)
			oWs:CCBTEFCH		:= DTOS(M->F1_EMISSAO)
			oWs:cIMPTOTAL		:= IIF(lvalcons,cValToChar(M->F1_VALCONS),cValToChar(MaFisRet(,'NF_TOTAL')) )
			oWs:CCODAUTORIZACION := M->F1_CODAUT
			oWs:CDOCTIPORECEPTOR	:= cTpDocRcp
			oWs:CDOCNRORECEPTOR	:= IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"") //Cod Valid = "30696155190"
			oWs:CMODCONSULT	:= M->F1_MODCONS
		Elseif cAliasC == "SF2"
			oWs:CCUITEMISOR	:= (cAliasCF)->A2_CGC
			oWs:CPTOVTA		:= SubStr(M->F2_DOC,1,4)
			oWs:CCBTETIPO		:= cCbteTipo
			oWs:CCBTENRO		:= SubStr(M->F2_DOC,5,12)
			oWs:CCBTEFCH		:= DTOS(M->F2_EMISSAO)
			oWs:cIMPTOTAL		:= IIF(lvalcons,cValToChar(M->F2_VALCONS),cValToChar(MaFisRet(,'NF_TOTAL')))
			oWs:CCODAUTORIZACION := M->F2_CODAUT
			oWs:CDOCTIPORECEPTOR	:= cTpDocRcp
			oWs:CDOCNRORECEPTOR	:= IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
			oWs:CMODCONSULT	:= M->F2_MODCONS
		Endif

		If oWs:COMPROBANTECONSTATAR()
			cMod     := oWs:oWSCOMPROBANTECONSTATARRESULT:CCBTEMODO
			cCbteNro := oWs:oWSCOMPROBANTECONSTATARRESULT:CCBTENRO
			cAutoriz := oWs:oWSCOMPROBANTECONSTATARRESULT:CCODAUTORIZACION
			cDocNr   := oWs:oWSCOMPROBANTECONSTATARRESULT:CDOCNRORECEPTOR
			cErro    := oWs:oWSCOMPROBANTECONSTATARRESULT:CERROCODIGO
			cMsg     := oWs:oWSCOMPROBANTECONSTATARRESULT:CERROMSG
			cResult  := oWs:oWSCOMPROBANTECONSTATARRESULT:CRESULTADO

			If " - " $ cErro
				cErro:= SUBSTR(cErro,1,Len(cErro)-2)
			Endif

			While  " / " $ cMsg
				cMsg:= STRTRAN(cMsg," / ",+ CRLF + "" )
			Enddo

			If cResult == "R"
				cMensagem += STR0051 + cCbteNro+CRLF //Nro Comprobante
				cMensagem += STR0052 + cAutoriz +CRLF //Cod. Aut
				cMensagem += STR0053 + CRLF + cErro + CRLF //Codigo do erro
				cMensagem += STR0054 + CRLF + cMsg + CRLF //Mensagem de erro
				cMensagem += STR0055 //cResult
				Aviso(STR0056, cMensagem,{"OK"},3)
				lVld:= .F.
			ElseIf cResult == "A"
				cMensagem += STR0051 + cCbteNro+CRLF //Nro Comprobante
				cMensagem += STR0052 + cAutoriz +CRLF //Cod. Aut
				cMensagem += STR0057 //cResult
				Aviso(STR0056, cMensagem,{"OK"},3)
				lVld:= .T.
			Else
				cMensagem += STR0058
				Aviso(STR0056, cMensagem,{"OK"},3)
				lVld:= .F.
			Endif
		Endif
	Else
		MsgInfo(GetWscError(1))
	Endif
Elseif !lControl
	lVld:= .F.
Else
	lVld:= .T.
Endif
Return lVld

/*/{Protheus.doc} VldSitComp
	(Obtiene código de entidad para envío a TSS)
	@type  Function
	@author Arturo Samaniego
	@since 08/07/2022
	@param cCodFil,cAviso,lAviso
	@return cIdEnt
	/*/
Function fIdEntidad(cCodFil,cAviso,lAviso)
Local aArea	:= GetArea()
Local cIdEnt	:= ""
Local cURL		:= (PadR(GetNewPar("MV_ARGNEUR","http://"),250))
Local oWs

Default cCodFil	:= ""
Default cAviso		:= ""
Default lAviso		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oWs:=WSNFECFGLOC():New()
oWS:cUSERTOKEN := "TOTVS"
oWS:_URL       := AllTrim(cURL)+"/NFECFGLOC.apw"
oWs:oWSEMPRESA:cCUIT       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
oWS:oWSEMPRESA:cCODFIL 	   := FWGETCODFILIAL
oWS:oWSEMPRESA:cINSCRPROVI := SM0->M0_INSC
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWs:oWSEMPRESA:cCODPROVINC := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCP         := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_PAIS   := "063"
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:CNUM        := SM0->M0_CIDENT
oWs:oWSEMPRESA:cREGMUN     := ""  // rEGIME mUN
oWs:oWSEMPRESA:cDDN        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
oWS:_URL := AllTrim(cURL)+"/NFECFGLOC.apw"

If  oWS:ADMEMPLOC()
	cIdEnt  := oWS:CADMEMPLOCRESULT
Elseif lAviso
	Aviso("NFEE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
Else
	cAviso := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
EndIf

oWs := Nil
DelClassIntF()

RestArea(aArea)
Return(cIdEnt)

/*/{Protheus.doc} fObtTipDoc
	(Obtiene tipo de documento para enviar a la AFIP)
	@type  Function
	@author Arturo Samaniego
	@since 08/07/2022
	@param cSerie,cTipo,cAliasC
	@return cTipoDoc
	/*/
Function fObtTipDoc(cSerie,cTipo,cAliasC)
Local nTipo    := 1
Local cTipoDoc :="032"

Default cSerie := ""
Default cTipo  := ""
Default cAliasC:=" "

If ALLTRIM(UPPER(cTipo))$"NF"
	nTipo :=1
Elseif ALLTRIM(UPPER(cTipo))$"NDP|NCI"
	nTipo :=2
ElseIf ALLTRIM(UPPER(cTipo))$"NCP|NDI"
	nTipo :=3
EndIf

Do Case
Case nTipo == 1 .And. Alltrim(cSerie)$ "A"
	cTipoDoc="1"
Case nTipo == 1 .And. Alltrim(cSerie)$ "B"
	cTipoDoc="6"
Case nTipo == 1 .And. Alltrim(cSerie)$ "C"
	cTipoDoc="11"
Case nTipo == 1 .And. Alltrim(cSerie)$ "M"
	cTipoDoc="51"
Case nTipo == 2 .And. Alltrim(cSerie)$ "A"
	cTipoDoc="2"
Case nTipo == 2 .And. Alltrim(cSerie)$ "B"
	cTipoDoc="7"
Case nTipo == 2 .And. Alltrim(cSerie)$ "C"
	cTipoDoc="12"
Case nTipo == 2 .And. Alltrim(cSerie)$ "M"
	cTipoDoc="52"
Case nTipo == 3 .And. Alltrim(cSerie)$ "A"
	cTipoDoc="3"
Case nTipo == 3 .And. Alltrim(cSerie)$ "B"
	cTipoDoc="8"
Case nTipo == 3 .And. Alltrim(cSerie)$ "C"
	cTipoDoc="13"
Case nTipo == 3 .And. Alltrim(cSerie)$ "M"
	cTipoDoc="53"
EndCase
	
If cAliasC =="SF1"  .And.  SF1->(ColumnPos("F1_RG1415")) > 0 .And. !Empty(M->F1_RG1415)
	cTipoDoc=Alltrim(M->F1_RG1415)
ElseIf cAliasC =="SF2"  .And.  SF2->(ColumnPos("F2_RG1415")) > 0 .And. !Empty(M->F2_RG1415)
	cTipoDoc=Alltrim(M->F2_RG1415)
EndIf

Return (cTipoDoc)

/*/{Protheus.doc} fAfipCons
	(Validación de campo F1_VALCONS y F2_VALCONS)
	@type  Function
	@author Arturo Samaniego
	@since 08/07/2022
	@param __aCpTela, aCfgNF
	@return lCons
	/*/
Function fAfipCons(__aCpTela, aCfgNF)
Local aCmpnf := {}
Local nTipo := 0
Local aPergs := {}
Local aCpTela := {}
Local lvalcons := .T.
Private lCons := .T.

nTipo := 10

aCpTela := __aCpTela
aCmpnf := MontaCfgNf(nTipo,aPergs,.T.)
If Empty(aCfgNF)
	Return .F.
EndIf

If SubStr(aCpTela[6][1],1,2) == "F1" .And. (Alltrim(aCfgNf[8]) $ "NF|NDP") .And. SA2->(ColumnPos("A2_OBRICAI"))>0 .And. SA2->A2_OBRICAI == "1"
	If (! Empty (F1_VALCONS) .and. F1_VALCONS > 0)
		lvalcons := .T.
		lCons := Compcont(aCmpnf[4],aCmpnf[2],aCpTela,aCmpnf,lvalcons)
	Endif
ElseIf SubStr(aCpTela[6][1],1,2) == "F2" .And. (Alltrim(aCfgNf[8]) $ "NCP") .And. SA2->(ColumnPos("A2_OBRICAI"))>0 .And. SA2->A2_OBRICAI == "1"
	If (! Empty (F2_VALCONS) .and. F2_VALCONS > 0 )
		lvalcons := .T.
		lCons := Compcont("SF2","SA2",aCpTela,aCmpnf,lvalcons)
	Endif
Endif
Return lCons

/*/{Protheus.doc} xCliForARG
	Función para asignar valor en encabezado
	@type  Function
	@author Arturo Samaniego
	@param cFunname, nPosCliFor, nPosLoja, aHeader, aCols, bRefresh, aCfgNf,_nTotOper_, _aValItem_
	@since 15/07/2022
	/*/
Function xCliForARG(cFunname, nPosCliFor, nPosLoja, aHeader, aCols, bRefresh, aCfgNf,_nTotOper_, _aValItem_)
Local nDPedido   := 0
Local nDRemito   := 0
Local nDifProv   := 0
Local nPosProv   := 0
Local nX         := 0
Local cProvAnt   := ""
Local cProv      := ""
Local cCpo       := ""
Local cSerie     := ""
Local dIni       := CTOD("//")
Local lAltProv   := .T. //Indica se deve atualizar ou nao prov.entrega nos itens com a prov.do cabec.

Default cFunname   := Funname()
Default nPosCliFor := 0
Default nPosLoja   := 0

	If (cFunname == "MATA101N")  .and. (READVAR() == "M->F1_FORNECE" .or. READVAR() == "M->F1_LOJA")
		nDPedido  := Ascan(aHeader, { |x| AllTrim(x[2])=="D1_PEDIDO"	})
		nDRemito  := Ascan(aHeader, { |x| AllTrim(x[2])=="D1_REMITO"	})
		If (nDPedido * nDRemito * nPosCliFor * nPosLoja) <> 0
			nDifProv := Ascan(aCols,{|x| (!Empty(x[nDPedido]) .or. Iif(Funname() == "MATA101N",!Empty(x[nDRemito]),.F.) ) .and. (x[nPosCliFor] <> M->F1_FORNECE .or. x[nPosLoja] <> M->F1_LOJA)})

			If nDifProv > 0
				LOCXATUBASE(aHeader,@aCols)
				Eval(bRefresh)
			EndIf
		EndIf
	EndIf
	If (cFunname == "MATA102N") .and. (READVAR() == "M->F1_FORNECE" .or. READVAR() == "M->F1_LOJA")
		nDPedido  := Ascan(aHeader, { |x| AllTrim(x[2])=="D1_PEDIDO"	})
		If (nDPedido * nPosCliFor * nPosLoja) <> 0
			nDifProv := Ascan(aCols,{|x| (!Empty(x[nDPedido])) .and. (x[nPosCliFor] <> M->F2_FORNECE .or. x[nPosLoja] <> M->F2_LOJA)})

			If nDifProv > 0
				LOCXATUBASE(aHeader,@aCols)
				Eval(bRefresh)
			EndIf
		EndIf
	EndIf

	If aCfgNf[SAliasHead] == "SF2"
		cProvAnt := M->F2_PROVENT
	Else
		cProvAnt := M->F1_PROVENT
	Endif
	If aCfgNf[ScCliFor] == "SA2"
		cProv := SA2->A2_EST
	Else
		cProv := SA1->A1_EST
	Endif

	//³Ponto de Entrada p/ permitir ou nao alterar as provincias dos itens/cabecalho c/ a prov. do Forn/Cli/cabec. ³

	cPe	:=	LocxPE(55)
	If !Empty(cPe)
		lAltProv := Execblock(cPE,.F.,.F.,{READVAR(),cProvAnt,cProv})
		If ValType(lAltProv) <> "L"
			lAltProv := .T.
		EndIf
	EndIf

	If aCfgNf[SAliasHead] == "SF2"
		If lAltProv .Or. Empty(M->F2_PROVENT)
			M->F2_PROVENT := cProv
		EndIf
	Else
		If lAltProv .Or. Empty(M->F1_PROVENT)
			M->F1_PROVENT := cProv
		EndIf
	Endif
	cCpo := If(aCfgNf[SAliasHead] == "SF2","D2_PROVENT","D1_PROVENT")
	nPosProv := Ascan(aHeader,{|x| Alltrim(x[2]) == cCpo})
	MaFisAlt("NF_PROVENT",cProv)
	For nX := 1 To Len(aCols)
		If lAltProv .Or. Empty(aCols[nX,nPosProv])
			aCols[nX,nPosProv] := cProv
		EndIf
		MaFisAlt("IT_PROVENT",aCols[nX,nPosProv],nX)
	Next
	If cFunname == "FINA100" .And. aCfgNf[SAliasHead] == "SF1" .And. aCfgNf[ScCliFor] == "SA2" .And.  !aCfgNf[SlFormProp]
		cSerie:= LocXTipSer(aCfgNf[ScCliFor],aCfgNf[ScEspecie]) // Trazer a serie automat.  para o documento
		MaFisAlt("NF_SERIENF",cSerie)
		M->F1_SERIE	:=	cSerie
	Endif
	//Tratamento de IB para monotributistas - Argentina AGIP 177/2009 ³
	_nTotOper_ := 0
	_aValItem_ := {}
	If aCfgNf[SnTipo] == 1		//fatura
		If SA1->A1_TIPO == "M"
			dIni := (M->F2_EMISSAO + 1) - 365
			_nTotOper_ := RetTotOper(SA1->A1_COD,SA1->A1_LOJA,"C",dIni,M->F2_EMISSAO,1)
		Endif
	Endif
	If Type('oGetDados:oBrowse') == "O"
		oGetDados:oBrowse:Refresh()
	Endif

	If cPaisLoc == "ARG" .And. StrZero(aCfgNf[SnTipo],2) $ "01|02|03|04|05|06|07|08|09|10" .And. !lLocxAuto
		VldNFApoc(aCfgNf[ScCliFor], aCfgNf[SAliasHead])
	EndIf

	If cPaisLoc == "ARG" .And. aCfgNf[ScCliFor] == "SA1"
		DbSelectArea("AI0")
		AI0->(DbSetOrder(1))  //AI0_FILIAL+AI0_CODCLI+AI0_LOJA
		IF AI0->( DbSeek(XFILIAL("AI0")+SA1->A1_COD+SA1->A1_LOJA) )
			If aCfgNf[SAliasHead] == "SF1"
				M->F1_ADIC5  := AI0->AI0_ADIC5
				M->F1_ADIC61 := AI0->AI0_ADIC61
				M->F1_ADIC62 := AI0->AI0_ADIC62
				M->F1_ADIC7  := AI0->AI0_ADIC7
			ElseIf aCfgNf[SAliasHead] == "SF2"
				M->F2_ADIC5  := AI0->AI0_ADIC5
				M->F2_ADIC61 := AI0->AI0_ADIC61
				M->F2_ADIC62 := AI0->AI0_ADIC62
				M->F2_ADIC7  := AI0->AI0_ADIC7
			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} xVldNFApoc
	Validaciones para facturas apocrifas
	@type  Function
	@author Luis Samaniego
	@since 07/2022
	@param cTipContr,cTblSF
	@return lRet
	/*/
Function xVldNFApoc(cTipContr,cTblSF)
Local cCpoVar := ReadVar()
Local cContrib := ""
Local cFactApoc := ""

	If ("_LOJA" $ cCpoVar)
		If cTblSF == "SF1"
			cContrib := Alltrim(M->F1_FORNECE)
		Else
			cContrib := Alltrim(M->F2_CLIENTE)
		EndIf
	Else
		cContrib :=  Alltrim(&cCpoVar)
	EndIf

	If cContrib <> cFactApoc
		If cTipContr == "SA1"
			If SA1->A1_SITUACA == "4"
				MSGINFO(STR0061, STR0062 )
			EndIf
		ElseIf cTipContr == "SA2"
			If SA2->A2_SITUACA == "4"
				MSGINFO(STR0061, STR0062 )
			EndIf
		EndIf
		If cTblSF == "SF1"
			If Alltrim(M->F1_LOJA) != ""
				cFactApoc := cContrib
			EndIf
		Else
			If Alltrim(M->F2_LOJA) != ""
				cFactApoc := cContrib
			EndIf
		EndIf
	EndIf
Return


/*/{Protheus.doc} xValidaVig
	Función para validaciones de vigencia.
	@type  Function
	@author Luis Samaniego
	@since 07/2022
	@param dFechaO,dFechaV
	@return lRet
	/*/
Function xValidaVig(dFechaO,dFechaV)
Local aDias     := {31,28,31,30,31,30,31,31,30,31,30,31}
Local nMes      := Month(dFechaO)
Local nMesD     := nMes + 2
Local nDias     := 0
Local nMesAux   := 0
Local nAnio     := Year(dFechaO)
Local nAnioAux  := 0
Local lRet      := .F.
Local dFechaAux := CTOD("//")

	For nMes:= nMes to nMesD
		If nMes > 12
			nMesAux := nMes - 12
			nAnioAux := nAnio + 1
		Else
			nMesAux := nMes
			nAnioAux := nAnio
		EndIf

		If nMesAux == 2
			If Mod(nAnioAux,4) == 0
				If Mod(nAnioAux,100) == 0
					If Mod(nAnioAux,400) == 0
						nDias += 29
					Else
						nDias += aDias[nMesAux]
					EndIf
				Else
					nDias += 29
				EndIf
			Else
				nDias += aDias[nMesAux]
			EndIf
		Else
			nDias += aDias[nMesAux]
		EndIf
	Next

	dFechaAux := dFechaO + nDias

	If dFechaV >= dFechaO .and. dFechaV < dFechaAux
		lRet := .T.
	EndIf

Return lRet


/*/{Protheus.doc} ArgxDelNF
	Ejecutada durantes la anulación de de documentos.
	@type  Function
	@author raul.medina
	@since 07/2022
	@param lRet, nRecno
	@return lRet
	/*/
Function ArgxDelNF(lRet, nRecno)

DEFAULT lRet	:= .T.

	If Type("cFunName")<>"U"
		//Se actualiza el campo X5_DESCRI en la tabla SX5 si el número de documento borrado es menor a lo que se encuentra en la tabla SX5
		If lRet .and. ( cFunName $ "MATA467N") .And. !IsInCallStack("LOCXANULA")
			dbSelectArea("SX5")
			If MsSeek(xFilial("SX5")+"01"+AllTrim(SF2->F2_SERIE)+POSICIONE("CFH",1, xFilial("CFH")+SF2->F2_PV,"CFH_IDPV"))
				If Alltrim(SF2->F2_DOC) < LocConvNota(Alltrim(X5_DESCRI),TamSX3("F2_DOC")[1])
					RecLock("SX5",.F.)
						Replace X5_DESCRI  with SF2->F2_DOC
						Replace X5_DESCSPA with SF2->F2_DOC
						Replace X5_DESCENG with SF2->F2_DOC
					MsUnlock()
				EndIf
			EndIf
		EndIf

		If lRet .and. cFunname == "MATA462N" .and. IsInCallStack("LocXAnula") .and. SF2->(FieldPos("F2_OBSERV"))>0 .And. SF2->(FieldPos("F2_DTCANC"))>0 
			SF2->(DbGoTO(nRecno))
			If  SFH->(!EOF())
				RecLock("SF2",.F.)
					SF2->F2_OBSERV  := "REMITO ANULADO"
					SF2->F2_DTCANC  := Date()
				MsUnlock()
			EndIf
		EndIf
	EndIf

Return lRet



