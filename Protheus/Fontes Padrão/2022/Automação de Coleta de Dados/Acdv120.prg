#INCLUDE "Acdv120.ch" 
#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDV120    ³ Autor ³ Ricardo             ³ Data ³ 17/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Conferencia de mercadoria conforme pre-nota                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACD                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/              
Function ACDV120()
Local cVolume := Space(TamSx3("CB0_VOLUME")[1])
Local lBranco := .T.
Local lUsa07  := UsaCB0("07")
Local bKey09
Local bKey24
Local nX := 0
Local lAV120FIM := .T.
Local lACD120TEL:=	ExistBlock("ACD120TEL")
Local lACD120FIM:=  ExistBlock("AV120FIM")
Local aStru		 := {}
Local oTempTable	 := NIL
Local lVolta := .F.

Private lLocktmp  := .F.
Private cEtiqProd := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
Private cNota     := Space(TamSx3("F1_DOC")[1])
Private cSerie    := Space(SerieNfId("SF1",6,"F1_SERIE"))
Private cFornec   := Space(TamSx3("F1_FORNECE")[1])
Private cLoja     := Space(TamSx3("F1_LOJA")[1])
Private nTamChave := Len(cNota+cSerie+cFornec+cLoja)
Private nQtdEtiq  := 1
Private aConf     := {}
Private cCondSF1  := "03"   // variavel utilizada na consulta Sxb 'CBW'
Private cCodOpe   := CBRetOpe()
Private aLog      := {}
Private cProgImp  := "ACDV120"
Private lForcaQtd :=GetMV("MV_CBFCQTD",,"2") =="1"
Private ItIguais:= .F.

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If GetMv("MV_CONFFIS")<>"S"
	VTAlert(STR0045,STR0010,.T.,4000)  //"Favor habilitar a conferencia fisica atraves do parametro MV_CONFFIS"###"Aviso"
	Return .F.
EndIf

If Empty(cCodOpe)
	VTAlert(STR0028,STR0010,.T.,4000)  //"Operador nao cadastrado"###"Aviso"
	Return .F.
EndIf

aStru := {	{"NUMRF","C",03,00},;
			{"CHAVE","C",19,00}}
			
oTempTable := FWTemporaryTable():New( "TMP" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"CHAVE"} )
oTempTable:Create()


bkey09 := VTSetKey(09,{|| Informa()},STR0037) //"Informacoes"
bKey24 := VTSetKey(24,{|| Estorna()},STR0038) //"Estorno"
While .T.
	VTClear()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para montagem da tela de conferencia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lACD120TEL
		ExecBlock("ACD120TEL",.F.,.F.,{lUsa07})
	Else
		if lVT100B
			lLocktmp := .F.
			lForcaQtd := .T.
			If lUsa07
				@ 0,0 vtSay STR0001 vtGet cVolume pict '@!' Valid !Empty(cVolume) .and. AV120VldVol(cVolume) When /*(Empty(cVolume) .or. VtLastkey()==5) .and.*/ ! lLocktmp .and. iif(lVolta,(VTKeyBoard(chr(13)),.T.),.T.) //"Volume"
			EndIf
		
			If CPAISLOC != "PTG"
				@ 1,00 VTSAY STR0002 VTGet cNota   pict '@!' Valid VldNota(cNota) F3 'CBW'									When !lUsa07 /*.and.(Empty(cNota).or. VtLastkey()==5)*/  .and. ! lLocktmp .and. iif(lVolta,(VTKeyBoard(chr(13)),.T.),.T.)//'Nota '
				@ 1,14 VTSAY '-'     VTGet cSerie  pict '@!' Valid Empty(cSerie) .or. VldNota(@cNota,@cSerie,,,.T.)		When !lUsa07 /*.and.((Empty(cSerie) .and. lBranco) .or. VtLastkey()==5)*/  .and. ! lLocktmp .and. iif(lVolta,(VTKeyBoard(chr(13)),.T.),.T.)
				@ 2,00 VTSAY STR0003 VTGet cFornec pict '@!' Valid VldNota(cNota,cSerie,cFornec) F3 'FOR'					When !lUsa07 /*.and.(Empty(cFornec) .or. VtLastkey()==5)*/  .and. ! lLocktmp .and. iif(lVolta,(VTKeyBoard(chr(13)),lVolta := .F.,.T.),.T.)//'Forn '
				@ 2,14 VTSAY '-'     VTGet cLoja   pict '@!' Valid (lBranco := .f.,VldNota(cNota,cSerie,cFornec,cLoja))	When !lUsa07 /*.and.(Empty(cLoja) .or. VtLastkey()==5 )*/  .and. ! lLocktmp
				VtRead
					
							
				If !(vtLastKey() == 27)
					// Segunda tela------------------------------------------------
					VTClear()
					If !UsaCB0("01") // Quando usa CB0 a conferencia e feita pela quantidade total
						@ 0,00 VTSAY STR0004  //"Quantidade"
						@ 1,00 VTGet nQtdEtiq pict CBPictQtde() Valid nQtdEtiq > 0 when (lForcaQtd .or. VTLastkey() == 5) .and. iif(vtRow() == 1 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
					EndIf
					
					@ 2,00 VTSAY STR0005  //"Produto"
					@ 3,00 vtGet cEtiqProd pict '@!' Valid VTLastkey() == 5 .or. AV120VldPrd(cEtiqProd)  F3 "CBZ"
				endif
			
			Else
				@ 1,00 VTSAY STR0002 VTGet cNota   pict '@!' Valid VldNota(cNota) F3 'CBW'				When !lUsa07 /*.and.(Empty(cNota).or. VtLastkey()==5)*/  .and. ! lLocktmp  .and. iif(lVolta,(VTKeyBoard(chr(13)),.T.),.T.) //'Nota '
				@ 2,00 VTSAY STR0046 VTGet cSerie  pict '@!' Valid Empty(cSerie) .or. VldNota(@cNota,@cSerie,,,.T.)				When !lUsa07 /*.and.((Empty(cSerie) .and. lBranco) .or. VtLastey()==5)*/  .and. ! lLocktmp .and. iif(lVolta,(VTKeyBoard(chr(13)),.T.),.T.)
				@ 3,00 VTSAY STR0003 VTGet cFornec pict '@!' Valid VldNota(cNota,cSerie,cFornec) F3 'FOR'					When !lUsa07 /*.and. (Empty(cFornec) .or. VtLastkey()==5)*/  .and. ! lLocktmp .and. iif(lVolta,(VTKeyBoard(chr(13)),lVolta := .F.,.T.),.T.) //'Forn '
				@ 3,14 VTSAY '-'     VTGet cLoja   pict '@!' Valid (lBranco := .f.,VldNota(cNota,cSerie,cFornec,cLoja))	When !lUsa07 /*.and. (Empty(cLoja) .or. VtLastkey()==5 )*/  .and. ! lLocktmp
				VTRead
				VTClear()
				If lUsa07
				//@ 0,0 VTSAY STR0001+cVolume
				EndIf
				@ 1,00 VTSAY cNota
				@ 2,00 VTSAY STR0046+cSerie
				@ 3,00 VTSAY STR0003+cFornec
				@ 3,14 VTSAY '-'+cLoja
				VTInkey(0)
				VTClear
				@ 0,00 VTSAY STR0004  //"Quantidade"
				@ 1,00 VTGet nQtdEtiq pict CBPictQtde() Valid nQtdEtiq > 0 when (lForcaQtd .or. VTLastkey() == 5) .and. iif(vtRow() == 1 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
				@ 2,00 VTSAY STR0005  //"Produto"
				@ 3,00 VTGet cEtiqProd pict '@!' Valid VTLastkey() == 5 .or. AV120VldPrd(cEtiqProd)  F3 "CBZ"
			Endif
		Else //Se não possui o parametro executa rotina abaixo
			If lUsa07
				@ 0,0 vtSay STR0001 vtGet cVolume pict '@!' Valid !Empty(cVolume) .and. AV120VldVol(cVolume) When (Empty(cVolume) .or. VtLastkey()==5) .and. ! lLocktmp //"Volume"
			EndIf

			If CPAISLOC != "PTG"
				@ 1,00 VTSAY STR0002 VTGet cNota   pict '@!' Valid VldNota(cNota) F3 'CBW'								When !lUsa07 .and.(Empty(cNota).or. VtLastkey()==5)  .and. ! lLocktmp //'Nota '
				@ 1,14 VTSAY '-'     VTGet cSerie  pict '@!' Valid Empty(cSerie) .or. VldNota(@cNota,@cSerie,,,.T.)				When !lUsa07 .and.((Empty(cSerie) .and. lBranco) .or. VtLastkey()==5)  .and. ! lLocktmp
				@ 2,00 VTSAY STR0003 VTGet cFornec pict '@!' Valid VldNota(cNota,cSerie,cFornec) F3 'FOR'					When !lUsa07 .and.(Empty(cFornec) .or. VtLastkey()==5)  .and. ! lLocktmp //'Forn '
				@ 2,14 VTSAY '-'     VTGet cLoja   pict '@!' Valid (lBranco := .f.,VldNota(cNota,cSerie,cFornec,cLoja))	When !lUsa07 .and.(Empty(cLoja) .or. VtLastkey()==5 )  .and. ! lLocktmp
				If !UsaCB0("01") // Quando usa CB0 a conferencia e feita pela quantidade total 
					@ 3,00 VTSAY STR0004  //"Quantidade"
					@ 4,00 VTGet nQtdEtiq pict CBPictQtde() Valid nQtdEtiq > 0 when (lForcaQtd .or. VTLastkey() == 5)
				EndIf
				@ 5,00 VTSAY STR0005  //"Produto"
				@ 6,00 vtGet cEtiqProd pict '@!' Valid VTLastkey() == 5 .or. AV120VldPrd(cEtiqProd)  F3 "CBZ"
			Else
				@ 1,00 VTSAY STR0002
				@ 2,00 VTGet cNota   pict '@!' Valid VldNota(cNota) F3 'CBW'				When !lUsa07 .and.(Empty(cNota).or. VtLastkey()==5)  .and. ! lLocktmp //'Nota '
				@ 3,00 VTSAY STR0046 VTGet cSerie  pict '@!' Valid Empty(cSerie) .or. VldNota(@cNota,@cSerie,,,.T.)				When !lUsa07 .and.((Empty(cSerie) .and. lBranco) .or. VtLastkey()==5)  .and. ! lLocktmp
				@ 4,00 VTSAY STR0003 VTGet cFornec pict '@!' Valid VldNota(cNota,cSerie,cFornec) F3 'FOR'					When !lUsa07 .and.(Empty(cFornec) .or. VtLastkey()==5)  .and. ! lLocktmp //'Forn '
				@ 4,14 VTSAY '-'     VTGet cLoja   pict '@!' Valid (lBranco := .f.,VldNota(cNota,cSerie,cFornec,cLoja))	When !lUsa07 .and.(Empty(cLoja) .or. VtLastkey()==5 )  .and. ! lLocktmp
				VTRead
				VTClear()
				If lUsa07
					@ 0,0 VTSAY STR0001+cVolume
				EndIf
				@ 1,00 VTSAY cNota
				@ 2,00 VTSAY STR0046+cSerie
				@ 3,00 VTSAY STR0003+cFornec
				@ 3,14 VTSAY '-'+cLoja
				@ 4,00 VTSAY STR0004  //"Quantidade"
				@ 5,00 VTGet nQtdEtiq pict CBPictQtde() Valid nQtdEtiq > 0 when (lForcaQtd .or. VTLastkey() == 5)
				@ 6,00 VTSAY STR0005  //"Produto"
				@ 7,00 VTGet cEtiqProd pict '@!' Valid VTLastkey() == 5 .or. AV120VldPrd(cEtiqProd)  F3 "CBZ"
			Endif
		Endif //Fim do if do MV_RF4X20
		VTRead
	Endif
	if lVolta
		Loop
	Endif

	If Empty(cNota+cSerie+cFornec+cLoja)
		Exit
	EndIf
	If	! VTYesNo(STR0006,STR0007,.T.) //"Sair da conferencia?"###"ATENCAO"
		Loop
	EndIf
	TravaTmp(.f.)
	If	RetQtdConf() == 0
		If	VTYesNo(STR0008,STR0007,.T.) //"Finaliza o processo de conferencia da nota?"###"ATENCAO"
			StatusSF1(cNota,cSerie,cFornec,cLoja)   
			If lACD120FIM
			    lAV120FIM := ExecBlock("AV120FIM",.F.,.F.,{cNota,cSerie,cFornec,cLoja})
			    lAV120FIM := If( ValType(lAV120FIM)=="L",lAV120FIM,.T.)
			 
			   If !lAV120FIM
			       TravaTMP()
			       Loop
			    Endif
			EndIf
		Else
			VTAlert(STR0009,STR0010,.T.,4000) //"Nota permanece em conferencia"###"Aviso"
		EndIf
		Exit
	Else
		VTAlert(STR0009,STR0010,.T.,4000) //"Nota permanece em conferencia"###"Aviso"
		Exit
	EndIf
EndDo
For nX:= 1 to Len(aLog)
	CbLog("05",aLog[nX])
Next
If	ExistBlock("AV120SAICF")
	ExecBlock("AV120SAICF")
EndIf

vtsetkey(09,bkey09)
vtsetkey(24,bkey24)
oTempTable:Delete()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV120   ºAutor  ³Ricardo             º Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a etiqueta de volume                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AV120VldVol(cVolume)
Local aVolume := {}

aVolume := CBRetEti(cVolume,"07") //Volume

If Empty(aVolume)
	VTBeep(2)
	VTAlert(STR0011,STR0010,.T.,4000) //"Etiqueta invalida."###"Aviso"
	VTKeyBoard(chr(20)) //Limpa o get
	Return .F.
EndIf
cNota   := aVolume[2]
cSerie  := aVolume[3]
cFornec := aVolume[4]
cLoja   := aVolume[5]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica e atualiza o status da identificacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF1")
SF1->(dbSetOrder(1))
If ! SF1->(dbSeek(xFilial("SF1")+cNota+cSerie+cFornec+cLoja))
	VTBeep(2)
	VTAlert(STR0012,STR0010,.T.,4000)   //"Nota fiscal nao cadastrada"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
If SF1->F1_STATCON == "1" //Conferida
	VTBeep(2)
	VTAlert(STR0013,STR0010,.T.,4000) //"Esta nota ja foi conferida."###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
RecLock("SF1",.F.)
SF1->F1_STATCON := "3" //Em conferencia
SF1->F1_QTDCONF := RetQtdConf()+1
MsUnlock()
TravaTMP()

VTGetRefresh("cNota")
VTGetRefresh("cSerie")
VTGetRefresh("cFornec")
VTGetRefresh("cLoja")
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldNota()

@author Totvs
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function VldNota(cNota,cSerie,cFornec,cLoja,lSerie)

Local cTPConffis := SuperGetMV("MV_TPCONFF",.F.,"1")
Default cNota	:= ""
Default cSerie	:= ""
Default cFornec	:= ""
Default cLoja	:= "" 
Default lSerie	:= .F.

If Len(cNota+cSerie+cFornec+cLoja) < nTamChave
	Return .t.
EndIf

If VtLastkey() == 05
	Return .t.
EndIf

If lSerie
	CBMULTDOC("SF1",cNota,@cSerie)
EndIf

If Empty(cNota)
	VTKeyBoard(chr(23))
	Return .f.
EndIf

SF1->(DbSetOrder(1))
If ! SF1->(DbSeek(xFilial("SF1")+cNota+cSerie+cFornec+cLoja))
	VTBEEP(2)
	VTAlert(STR0012,STR0010,.T.,4000) //"Nota fiscal nao cadastrada"###"Aviso"
	VTClearBuffer()
	VTKeyBoard(chr(20))
	Return .f.
EndIf

SA2->(dbSetOrder(1))
If cPaisLoc == "BRA"
	If  (SA2->(dbSeek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA))) .And. SA2->A2_CONFFIS == "2" .And. SF1->F1_TIPO == "N") .Or. ;
		(SF1->F1_TIPO == "B" .And. (SuperGetMV("MV_CONFFIS",.F.,"N") == "S") .And. (cTPConffis == "2")) .or.;
		( SA2->A2_CONFFIS == "0" .And. SF1->F1_TIPO == "N" .And. cTPConffis == "2")	
		VTAlert(STR0049,STR0020,.T.,4000)//"O fornecedor esta configurado para conferencia fisica em Notas Fiscais de Entrada!" ### "Aviso"   
		Return .F.
	Endif
EndIf

If SF1->F1_STATUS == "B" // Bloqueada
   VTBeep(2)
   VTAlert(STR0047,STR0010,.T.,4000) //"Nota fiscal bloqueada"###"Aviso"
   VTKeyBoard(chr(20))
   Return .F.
EndIf
If SF1->F1_STATCON == "1" //Conferida
   VTBeep(2)
   VTAlert(STR0013,STR0010,.T.,4000) //"Esta nota ja foi conferida."###"Aviso"
   VTKeyBoard(chr(20))
   Return .F.
EndIf
If ExistBlock("AV120NFE")
   lVldNFE := ExecBlock("AV120NFE",.F.,.F.)
   lVldNFE := If(ValType(lVldNFE)=="L",lVldNFE,.T.)
   If !lVldNFE
      Return .F.
   Endif
Endif           
TravaTMP()
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV120   ºAutor  ³Ricardo             º Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a etiqueta de produto, interna ou do forncedor      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AV120VldPrd()
Local aProd
Local cProduto  := Space(TamSx3("B1_COD")[1])
Local nQE       := 0 //quantidade por embalagem
Local nSaldo    := 0
Local lCodInt   := .T.
Local nCopias   := 0
Local nSaldoDist:= 0
Local cTipId    := ""
Local cLote     := Space(TamSx3("D1_LOTECTL")[1])
Local dValid    := cTod('')
Local aTela
Local lPesqSA5  := SuperGetMv("MV_CBSA5",.F.,.F.)
Local lVld2UM   := SuperGetMv("MV_CBV2UM",.F.,.F.)
//--- Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))
Local lForcaImp := .F.
Local nOpcao    := 0
Local cEtiqRet  := ""
Local lAC120VLD := .T.

Private nQtdEtiq2 :=nQtdEtiq
Private cItemPd := " "
Private aItensDP:= {}
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If Empty(cEtiqProd)
	Return .f.
EndIf
If ! CBLoad128(@cEtiqProd)
	VTkeyBoard(chr(20))
	Return .f.
EndIf

If ExistBlock("AC120VLD") 
	lAC120VLD := ExecBlock("AC120VLD",.F.,.F.,{cEtiqProd})  
	lAC120VLD := If(ValType(lAC120VLD)=="L",lAC120VLD,.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para criar produto no CB0 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If UsaCB0("01") .and. ExistBlock("AV120CB0")
	cEtiqRet  := ExecBlock("AV120CB0",.F.,.F.,{cEtiqProd})
	cEtiqProd := If(ValType(cEtiqRet)=="C",cEtiqRet,cEtiqProd)
EndIf

If lAC120VLD
	Begin sequence
		dbSelectArea("SA5")
		SA5->(dbSetorder(8)) //A5_CODBAR
		If lPesqSA5 .and. SA5->(dbSeek(xFilial("SA5")+cFornec+cLoja+Padr(AllTrim(cEtiqProd),Tamsx3("B1_COD")[1])))
			cProduto := SA5->A5_PRODUTO
			nQE      := CBQtdEmb(cProduto)
			If Empty(nQE)
				Break
			EndIf
			If CBProdUnit(cProduto)
				If ! Vld2Um(cProduto,@nQE,@nOpcao)
					Break
				EndIf
			EndIf
			nQtdEtiq2 := nQtdEtiq2*nQE
			lCodInt := .F.
		Else
			cTipId := CBRetTipo(cEtiqProd)
			If UsaCB0("01") .And. cTipId=="01"
				aProd := CBRetEti(cEtiqProd,"01") //Produto
				If Len(aProd) == 0
					VTBeep(2)
					VTAlert(STR0011,STR0010,.T.,4000) //"Etiqueta invalida."###"Aviso"
					Break
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se etiqueta ja tem dados da nota  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cProduto := aProd[1]
				If PesqCBE(CB0->CB0_CODETI)
					VTBeep(2)
					VTAlert(STR0015,STR0010,.T.,4000)  //"Etiqueta ja lida"###"Aviso"
					Break
				EndIf
				If ! CBProdUnit(cProduto)
					nQE := CBQtdEmb(cProduto)
					If Empty(nQE)
						Break
					EndIf
					If nQE # aProd[2]
						VTBeep(2)
						VTAlert(STR0016,STR0010,.T.,4000)  //"Quantidade nao confere!"###"Aviso"
						Break
					EndIf
				EndIf
				nQtdEtiq2 := aProd[2]
				cLote     := aProd[16]
				dValid    := aProd[18]
				lCodInt   := .t.
			ElseIf !UsaCB0("01") .And. cTipId $ "EAN8OU13-EAN14-EAN128"  //-- nao tem codigo interno e tera'que ser impresso a etiqueta de identificacao
				aProd := CBRetEtiEan(cEtiqProd)
				If Empty(aProd) .or. Empty(aProd[2])
					VTBeep(2)
					VTAlert(STR0011,STR0010,.T.,4000)  //"Etiqueta invalida."###"Aviso"
					Break
				EndIf
				cProduto := aProd[1]
				nQE := aProd[2]
				If ! CBProdUnit(cProduto)
					nQE := CBQtdEmb(cProduto)
					If Empty(nQE)
						Break
					EndIf
				Else
					If (cTipId == "EAN8OU13"  .and. UsaCB0("01")) .or. lVld2UM
						If ! Vld2Um(cProduto,@nQE,@nOpcao)
							Break
						EndIf
					EndIf
				EndIf
				nQtdEtiq2 := nQtdEtiq2*nQE
				lCodInt   := .F.
				cLote     := aProd[3]
				dValid    := aProd[4]
			Else
				VTBeep(2)
				VTAlert(STR0029,STR0010,.T.,4000) //"Aviso"###"Etiqueta invalida"
				Break
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o produto pertence a nota³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		If ! SD1->(dbSeek(xFilial("SD1")+cNota+cSerie+cFornec+cLoja+cProduto))
			If  ! ExistBlock("AV120QTD") //verificar somente a existencia
				VTBeep(2)
				VTAlert(STR0017,STR0010,.T.,4000) //"Produto nao pertence a nota."###"Aviso"
				Break
			EndIf
		EndIf
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial('SB1')+cProduto))
		If Empty(cLote) .or. Empty(dValid)
			If SB1->B1_PRVALID > 0 
				dValid := dDatabase+SB1->B1_PRVALID
			EndIf
			If ! CBRastro(cProduto,@cLote,,@dValid,.t.)
				VTKeyboard(chr(20))
				Break
			EndIf
			If ! AjustadValid(cProduto,cLote,@dValid)
				VTAlert(STR0030,STR0010,.T.,4000) //"Aviso"###"Data invalida"
				Break
			EndIf
		EndIf
	  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para validar a etiqueta lida.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("A120PROD")
			lProd := Execblock("A120PROD",.F.,.F.,{cEtiqProd})  
			If ValType(lProd) == "L" .And. !lProd
				Break
			EndIf
		EndIf
		If !UsaCB0('01') .And. !UsrDataCtr()
			If VldProdIg(cNota,cSerie,cFornec,cLoja,cProduto,cLote,dValid)
				TelDocSel(cNota,cSerie,cFornec,cLoja,cProduto,cLote,dValid)
			EndIf
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna o saldo que pode ser conferido³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSaldo := QtdAConf(cProduto,cLote,dValid)
		If nSaldo == 0
			If ! ExistBlock("AV120QTD")  //-- verificar somente a existencia
				VTBeep(2)
				VTAlert(STR0018,STR0010,.T.,4000) //"Produto excede a nota."###"Aviso"
				Break
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Distribui a quantidade no SD1        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCodInt //-- Codigo interno
			If nQtdEtiq2 > nSaldo
				If	ExistBlock("AV120QTD")
					ExecBlock("AV120QTD",.F.,.F.,{cProduto,nQtdEtiq2,1,cEtiqProd})
				Else
					VTBeep(2)
					VTAlert(STR0018,STR0010,.T.,4000) //"Produto excede a nota."###"Aviso"
					Break
				EndIf
			Else
				GravaCBE(CB0->CB0_CODETI,cProduto,nQtdEtiq2,cLote,dValid)
				DistQtdConf(cProduto,nQtdEtiq2,,,,cNota,cSerie,cFornec,cLoja)
			EndIf
		Else //-- Cod fornecedor
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+cProduto))
	
			If nQtdEtiq2 <= nSaldo .OR. ABS(QtdComp(nQtdEtiq2-nSaldo)) <= nToler1UM
				nSaldoDist:=nQtdEtiq2
				nCopias   :=Int(nQtdEtiq2/nQE)
			ElseIf nQtdEtiq2 > nSaldo
				nSaldoDist:=nSaldo
				nCopias   :=Int(nSaldo/nQE)
				If	ExistBlock("AV120QTD")
					ExecBlock("AV120QTD",.F.,.F.,{cProduto,nQE,nQtdEtiq2-nCopias,nil})
				Else
					VTBeep(2)
					VTAlert(STR0018,STR0010,.T.,4000) //"Produto excede a nota."###"Aviso"
					Break
				EndIf
			EndIf
			If	ExistBlock("CBVLDIRE")
				lForcaImp := ExecBlock("CBVLDIRE",.F.,.F.,{cEtiqProd,cNota,cSerie,cFornec,cLoja,cLote,dvalid,nOpcao,nQtdEtiq2})
				lForcaImp := If(ValType(lForcaImp)=="L",lForcaImp,.F.)
			EndIf
			If Usacb0("01") .or. lForcaImp  //-- origem do codigo eh pelo fornecedor
				If nCopias > 0 .and. ExistBlock('IMG01')
					aTela:= VtSave()
					VtClear()
					CB5SetImp(CBRLocImp("MV_IACD03"),.T.)
					VtAlert(STR0039+Str(nCopias,3)+STR0040+CB5->CB5_CODIGO,STR0041,.t.,3000,3) //"Imprimindo "###" etiqueta(s) no local :"###"Impressao"
	
					ExecBlock("IMG01",,,{nQE,cCodOpe,,nCopias,cNota,cSerie,cFornec,cLoja,,,,cLote,'',dValid})
	
					MSCBClosePrinter()
					VTRestore(,,,,aTela)
				EndIf
			Else
				GravaCBE(Space(10),cProduto,nQtdEtiq2,cLote,dValid)
			EndIf
			DistQtdConf(cProduto,nSaldoDist,,cLote,dValid,cNota,cSerie,cFornec,cLoja) //-- distribui quant dentro da nota
		EndIf
		If	ExistBlock("AV120VLD")
			Execblock("AV120VLD",.F.,.F.,{cEtiqProd,lForcaImp})
		EndIf
	    
		If lForcaQtd
			If lVT100B
				VtSay(3,0,Space(19))
			Else
				VtSay(6,0,Space(19))
			Endif
			cEtiqProd:= IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			nQtdEtiq := 1
			VtGetSetFocus('nQtdEtiq')
			Return .F.
		EndIf 
		
	End Sequence
EndIf
	
nQtdEtiq := 1
VTGetRefresh("nQtdEtiq")
VTKeyBoard(chr(20))
Return .F.

/*/{Protheus.doc} UsrDataCtr
	Indica se os dados do produto lido são de responsabilidade do cliente por meio dos P.E
	@type  Static Function
	@author SQUAD Entradas
	@since 22/10/2019
	@version P12.1.25
	@return lRet, Boolean, .T. significa que o usuário tem total controle dos dados do produto lido, 
					realizando o desvio de outras validações.
/*/
Static Function UsrDataCtr()

	Local lRet := ExistBlock("CBRETTIPO") .Or.;
	              ExistBlock("CBRETEAN")

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Vld2Um    ºAutor  ³TOTVS               º Data ³  01/01/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao  de Unidade de Medida                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Vld2Um(cProduto,nQE,nOpcao)
Local aTela,aOpcao
Local nSeg2    := 0
Local nVar     := 0
Local nQeAux   :=nQE
Local nTam     := 0
Local nI       := 0
Local lAV120UM := ExistBlock("AV120UM")
Local aRetPE   := {}
Local aConv    := {}
Local lRet     := .T.
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

SB1->(DbSetOrder(1))
SB1->(DBSeek(xFilial('SB1')+cProduto))
/*
If Empty(SB1->B1_UM) .OR. Empty(SB1->B1_SEGUM) .OR. SB1->B1_UM == SB1->B1_SEGUM
	Return .t.
EndIf
*/

aTela:= VTSave()
VTClear()

@ 0,0 VTSay STR0031 //"Selecione a unidade"
@ 1,0 VTSay STR0032 //"de medida?"
If Empty(SB1->B1_SEGUM) .OR. SB1->B1_UM == SB1->B1_SEGUM
	aOpcao:= {}
	aAdd(aOpcao,SB1->B1_UM   +'-'+Posicione('SAH',1,xFilial("SAH")+SB1->B1_UM		,"AH_UMRES"))
	If GetNewPar("MV_SELVAR","1") =="1"
		aadd(aOpcao,STR0042) //"??-Variavel"
		nVar := 2
	EndIf
Else
	aOpcao:= {}
	nSeg2 := 2
	aAdd(aOpcao,SB1->B1_UM   +'-'+Posicione('SAH',1,xFilial("SAH")+SB1->B1_UM		,"AH_UMRES"))
	aAdd(aOpcao,SB1->B1_SEGUM+'-'+Posicione('SAH',1,xFilial("SAH")+SB1->B1_SEGUM	,"AH_UMRES"))
	If GetNewPar("MV_SELVAR","1") =="1"
		aAdd(aOpcao,STR0042)  //"??-Variavel"
		nVar := 3
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para informar mais unidades de medida ³
//³Parametros: Nenhum                                     ³
//³Retorno   : Array (subArray de 3 itens)                ³
//³          : 1 . Unidade de Medida                      ³
//³          : 2 . Desc. da Unidade de Medida             ³
//³          : 3 . Fator de Conversao                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAV120UM
	nTam   := Len(aOpcao)
	aRetPE := Execblock("AV120UM",.F.,.F.,{cProduto})
	If ValType(aRetPE)=="A"
		For nI := 1 To Len(aRetPE)
			If Len(aRetPE[nI])==3
				aAdd(aOpcao,aRetPE[nI,1]+'-'+aRetPE[nI,2])
				aAdd(aConv,aRetPE[nI,3])
			EndIf
		Next
	EndIf
EndIf

nOpcao:=VTaChoice(2,0,5,VTMaxCol(),aOpcao)

If Empty(nOpcao)
	lRet := .f.
Else
	If nOpcao == nSeg2
		nQE := ConvUm(cProduto,nQE,nQE,1)
	ElseIf nOpcao == nVar
		If lVT100B
			VTClear
			@ 0,0 VtSay STR0043 //"Quantidade Variavel"
			@ 1,0 VtGet nQE Pict CBPictQtde()
		Else
			@ 5,0 VtSay STR0043 //"Quantidade Variavel"
			@ 6,0 VtGet nQE Pict CBPictQtde()
		Endif
		VTRead
		If VtLastKey() == 27
			VtRestore(,,,,aTela)
			lRet := .f.
		EndIf
		If (! Empty(SB1->B1_SEGUM) .and. Mod(nQE,SB1->B1_CONV) # 0) .or. (Mod(nQE,nQeAux) # 0 )
			VtAlert(STR0044,STR0010,.t.,4000) //"Quantidade Informada invalida"###"Aviso"
			VtRestore(,,,,aTela)
			lRet := .f.
		EndIf
	ElseIf lAV120UM .And. nOpcao > nTam
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para informar mais unidades de medida ³
		//³Continuacao da implementacao acima.                    ³
		//³Se usuario selecionou Unidade de Medida inform. no PE  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nI  := nOpcao - nTam
		nQE := aConv[nI]
	EndIf
EndIf
VtRestore(,,,,aTela)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV120   ºAutor  ³Ricardo             º Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o saldo que pode se conferido do produto            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QtdAConf(cProd,cLote,dValid)
Local nSaldo := 0
Local aAreaSD1 := SD1->(GetArea())

Default cLote := Space(TamSx3("D1_LOTECTL")[1])
Default dValid:= cTod('')

If ItIguais
	dbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	SF1->(dbSeek(xFilial("SF1")+cNota+cSerie+cFornec+cLoja))
	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cProd+cItemPd))
	While ! SD1->(Eof()) .and. ;
		xFilial("SD1")  == SD1->D1_FILIAL .and.;
		SD1->D1_DOC     == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and.;
		SD1->D1_FORNECE == SF1->F1_FORNECE .and.;
		SD1->D1_LOJA    == SF1->F1_LOJA .and. SD1->D1_COD == cProd .And. SD1->D1_ITEM == cItemPd
		If SD1->D1_QTDCONF < SD1->D1_QUANT
			nSaldo += (SD1->D1_QUANT - SD1->D1_QTDCONF)
		EndIf
		SD1->(dbSkip())
	EndDo
Else
	dbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	SF1->(dbSeek(xFilial("SF1")+cNota+cSerie+cFornec+cLoja))
	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cProd))
	While ! SD1->(Eof()) .and. xFilial("SD1")  == SD1->D1_FILIAL .and. SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and.;
		SD1->D1_FORNECE == SF1->F1_FORNECE .and.SD1->D1_LOJA    == SF1->F1_LOJA .and. SD1->D1_COD == cProd
		
		If SD1->D1_QTDCONF < SD1->D1_QUANT
			nSaldo += (SD1->D1_QUANT - SD1->D1_QTDCONF)
		EndIf
		SD1->(dbSkip())
	EndDo
EndIf		
	
RestArea(aAreaSD1)
Return nSaldo
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV120   ºAutor  ³Ricardo             º Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Distribui a quantidade nos itens do SD1                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DistQtdConf(cProd,nQtd,lEstorna,cLote,dValid,cNota,cSerie,cFornec,cLoja,lAcdMob)
Local nSaldo 	:= nQtd
Local nSaldoItem:= 0
Local nQtdBx 	:= 0
Local nPos 		:= 0
Local aAreaSD1:= SD1->(GetArea())
Local lAV120SD1 	:= ExistBlock("AV120SD1")
 
DEFAULT lEstorna:= .f.
Default cLote := Space(TamSx3("D1_LOTECTL")[1])
Default dValid:= cTod('')
Default lAcdMob := .F.

If !fwisincallstack("put") .And. !lAcdMob
	nPos 		:= AScan(aConf,{|x|AllTrim(x[1])==AllTrim(cProd)})
	If nPos == 0
		aadd(aConf,{cProd,0})
		nPos := Len(aConf)
	EndIf
	If ItIguais
		dbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(xFilial("SD1")+cNota+cSerie+cFornec+cLoja+cProd+cItemPd))
		While SD1->(! Eof() .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+cItemPd == ;
				xFilial("SD1")+cNota+cSerie+cFornec+cLoja+cProd+cItemPd)
			If ! lEstorna
				nSaldoItem := SD1->D1_QUANT-SD1->D1_QTDCONF
			Else
				nSaldoItem := SD1->D1_QTDCONF
			EndIf
			If Empty(nSaldoItem)
				SD1->(dbSkip())
				Loop
			EndIf
			nQtdBx := nSaldo
			If	nSaldoItem < nQtdBx
				nQtdBx := nSaldoItem
			EndIf
			RecLock("SD1",.F.)
			If	! lEstorna
				SD1->D1_QTDCONF+=nQtdBx
				aConf[nPos,2]+=nQtdBx
			Else
				SD1->D1_QTDCONF-=nQtdBx
				aConf[nPos,2]-=nQtdBx
			EndIf
			nSaldo -=nQtdBx
	     	MsUnLock()
			//-- Ponto de Entrada após gravação da tabela SD1 (Itens NF)
			If	lAV120SD1
				ExecBlock("AV120SD1",.F.,.F.,{lEstorna})
			EndIf
			If	Empty(nSaldo)
				Exit
			EndIf
			SD1->(dbSkip())
		EndDo
	Else
		dbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(xFilial("SD1")+cNota+cSerie+cFornec+cLoja+cProd))
		While SD1->(! Eof() .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD == ;
				xFilial("SD1")+cNota+cSerie+cFornec+cLoja+cProd)
			If ! lEstorna
				nSaldoItem := SD1->D1_QUANT-SD1->D1_QTDCONF
			Else
				nSaldoItem := SD1->D1_QTDCONF
			EndIf
			If Empty(nSaldoItem)
				SD1->(dbSkip())
				Loop
			EndIf
			nQtdBx := nSaldo
			If	nSaldoItem < nQtdBx
				nQtdBx := nSaldoItem
			EndIf
			RecLock("SD1",.F.)
			If	! lEstorna
				SD1->D1_QTDCONF+=nQtdBx
				aConf[nPos,2]+=nQtdBx
			Else
				SD1->D1_QTDCONF-=nQtdBx
				aConf[nPos,2]-=nQtdBx
			EndIf
			nSaldo -=nQtdBx
			MsUnLock()
			//-- Ponto de Entrada após gravação da tabela SD1 (Itens NF)
			If	lAV120SD1
				ExecBlock("AV120SD1",.F.,.F.,{lEstorna})
			EndIf
			If	Empty(nSaldo)
				Exit
			EndIf
			SD1->(dbSkip())
		EndDo
	EndIf
Else
	
	SD1->(DbOrderNickName("ACDSD101"))
	If SD1->(dbSeek(xFilial("SD1")+cNota+cSerie+padr(cFornec,TamSX3("D1_FORNECE")[01])+padr(cLoja,TamSX3("D1_LOJA")[01])+padr(cProd,TamSX3("D1_COD")[01])+padr(cLote,TamSX3("D1_LOTECTL")[01])))
		While SD1->(!Eof() .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_LOTECTL) ==;
					xFilial("SD1")+cNota+cSerie+padr(cFornec,TamSX3("D1_FORNECE")[01])+padr(cLoja,TamSX3("D1_LOJA")[01])+padr(cProd,TamSX3("D1_COD")[01])+padr(cLote,TamSX3("D1_LOTECTL")[01]) )
		
			nSaldoItem := SD1->D1_QUANT-SD1->D1_QTDCONF
		
			If Empty(nSaldoItem)
				SD1->(dbSkip())
				Loop
			EndIf
			nQtdBx := nSaldo
			If	nSaldoItem < nQtdBx
				nQtdBx := nSaldoItem
			EndIf
			RecLock("SD1",.F.)
			SD1->D1_QTDCONF+=nQtdBx	
			nSaldo -=nQtdBx
			SD1->(MsUnLock())
			
			If	Empty(nSaldo)
				Exit
			EndIf
			SD1->(dbSkip())
		EndDo
	EndIf
Endif
// Limpa variaveis utilizadas na função VldProdIg -
ItIguais:= .F.
aItensDP:= {}

RestArea(aAreaSD1)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACDV120   ºAutor  ³Ricardo             º Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza status do cabecalho da nota(SF1)                  º±±
±±º          ³ F1_STACON -> 0 - Pendente                                  º±±
±±º          ³              1 - Conferido                                 º±±
±±º          ³              2 - Divergente                                º±±
±±º          ³              3 - Em conferencia                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function StatusSF1(cNota,cSerie,cFornec,cLoja,lAcdMob)
Local lSai := .F.
Local lImpEtiq := .F.
Local lClaCfDv := SuperGetMv("MV_CLACFDV",.F.,.F.)
Default lAcdMob := .F.

dbSelectArea("SF1")
SF1->(dbSetOrder(1))
If SF1->(dbSeek(xFilial("SF1")+cNota+cSerie+cFornec+cLoja))
	dbSelectArea("SD1")
	SD1->(dbSetOrder(1))
	If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		While ! SD1->(Eof()) .and. xFilial("SD1") == D1_FILIAL .and.;
				SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and. SD1->D1_FORNECE == SF1->F1_FORNECE .and.;
				SD1->D1_LOJA == SF1->F1_LOJA
			lImpEtiq := CBImpEti(SD1->D1_COD)
			If fwisincallstack("put") .or. lAcdMob
				If SD1->D1_QUANT <> SD1->D1_QTDCONF .And. lImpEtiq //Divergente
					RecLock("SF1",.F.)
					SF1->F1_STATCON := "2"
					SF1->F1_QTDCONF := SF1->F1_QTDCONF+1
					SF1->(MsUnlock())
					lSai := .T.
					Exit
				EndIf
			Else
				If SD1->D1_QUANT > SD1->D1_QTDCONF .And. lImpEtiq //Divergente
					RecLock("SF1",.F.)
					SF1->F1_STATCON := "2"
					SF1->F1_QTDCONF := RetQtdConf()
					SF1->(MsUnlock())
					VTAlert(STR0019,STR0020,.t.,4000) //'Conferencia com divergencia'###'Aviso'
					lSai := .T.
					Exit
				EndIf			
			Endif
			If !lImpEtiq
				RecLock("SD1",.F.)
				SD1->D1_QTDCONF := SD1->D1_QUANT
				SD1->(MsUnlock())
			EndIf
			SD1->(dbSkip())
		EndDo
		If	!lSai
			RecLock("SF1",.F.)
			SF1->F1_STATCON := "1" //Conferido
			SF1->(MsUnlock())
			AjustaRec(cNota,cSerie,cFornec,cLoja)
		ElseIf lClaCfDv	// Permite classificar nota com divergencia, ajusta os itens conforme foram conferidos
			AjustaRec(cNota,cSerie,cFornec,cLoja)
		EndIf
	EndIf
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaRec ºAutor  ³TOTVS               º Data ³  17/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza a tabela SD1 Conforme a CBE			              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AjustaRec(cNota,cSerie,cFornec,cLoja)
Local aItens    := {}
Local nPosFil   := 0
Local nPosDoc   := 0
Local nPosSerie := 0
Local nPosForn  := 0
Local nPosLoja  := 0
Local nPosCod   := 0
Local nPos2     := 0
Local nLenIte   := 0
Local uVar
Local cItem     := ""
Local lInclui   := .T.
Local nQtdBaixa := 0
Local lDif      := .F.
Local nSaldoCBE := 0
Local nX        := 0
Local nY        := 0
Local nSaldoSD1 := 0
Local nSldColD1 := 0
Local nDesc	  := 0
Local nValDesc  := 0
Local lImpEtiq  := .F.
Local aItemD1   := {}
Local nPosItem  := 0
Local nDescItem := 0
Local nValdesco := 0
Local nItemD1	:= SD1->(FieldPos('D1_ITEM'))
Local nTamValDsc:= TamSX3("D1_VALDESC")[2]
Local lSDS      := .F.
Local cNotaSDS  := ""
Local lClaCfDv  := SuperGetMv("MV_CLACFDV",.F.,.F.)
Local lAchouSD1 := .F.
Local lConferido:= .F.
Local cChaveSD1 := ""

If	GetMv("MV_RASTRO") # "S"
	Return
EndIf

cNotaSDS := cNota + cSerie + cFornec + cLoja
lSDS := !COLFINSDS(1,cNotaSDS)

SD1->(dbSetOrder(1))
SD1->(dbSeek(xFilial('SD1')+cNota+cSerie+cFornec+cLoja))
While SD1->( !Eof() .And. xFilial('SD1')+cNota+cSerie+cFornec+cLoja == D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
	aAdd(aItens,{})
	For nX:= 1 to SD1->(FCount())
		aAdd(aItens[len(aItens)],SD1->(FieldGet(nX)))
	Next
	aAdd(aItens[len(aItens)],SD1->D1_QUANT) //-- SALDO
	nSaldoSD1 := SD1->D1_QUANT
	nDesc	   := SD1->D1_DESC
	nValDesc  := SD1->D1_VALDESC
	nPosItem  := AScan(aItemD1,{|x| x[1]+x[2]+x[3] == SD1->(D1_ITEM+D1_COD+D1_LOTECTL)})
	If nPosItem == 0
		aAdd(aItemD1,{ SD1->D1_ITEM, SD1->D1_COD, SD1->D1_LOTECTL })
	EndIf
	lImpEtiq  := CBImpEti(SD1->D1_COD)

	// Verifica se o produto foi conferido e atualiza SD1 de acordo com a CBE
	lConferido := .F.
	CBE->(DbSetOrder(2))
	If CBE->(DbSeek(xFilial("CBE") + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD)))
		lConferido := .T.
	EndIf

	If lImpEtiq .Or. lConferido
		RecLock("SD1",.F.)
		SD1->(dbDelete())
		MsUnlock()
	Else
		cItem := SD1->D1_ITEM	
	EndIf
	SD1->(dbSkip())
End

nLenIte := Len(aItens[1])
cItem := IIF(Empty(cItem),Space(Len(SD1->D1_ITEM)),cItem)
nPosCod := SD1->(FieldPos('D1_COD'))

CBE->(dbSetOrder(2))
CBE->(dBSeek(xFilial('CBE')+cNota+cSerie+cFornec+cLoja))
While CBE->(!EOF() .And. xFilial('CBE')+cNota+cSerie+cFornec+cLoja == CBE_FILIAL+CBE_NOTA+CBE_SERIE+CBE_FORNEC+CBE_LOJA)
	nSaldoCBE := CBE->CBE_QTDE  
	

	While nSaldoCBE > 0.00

		nPos2 := aScan(aItens,{|x| x[nPosCod]== CBE->CBE_CODPRO .And. x[nLenIte] > 0 })
		If nPos2 == 0
			Exit
		ElseIf lSDS
			nSldColD1 := aItens[nPos2,nLenIte]
		EndIf

		nQtdBaixa := aItens[nPos2,nLenIte]
		If	nQtdBaixa > nSaldoCBE
			nQtdBaixa := nSaldoCBE
		EndIf
      //-- Recebe os valores de Descontos do item 
        
       nDescItem	:= SD1->(FieldPos('D1_DESC'))
       nValdesco 	:= SD1->(FieldPos('D1_VALDESC'))   
       nDesc	   := aItens[nPos2,nDescItem]
	   nValDesc  := aItens[nPos2,nValdesco]


		//-- Pesquisa na procura de algum registro com o mesmo numero de LOTE
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(xFilial('SD1')+cNota+cSerie+cFornec+cLoja+CBE->CBE_CODPRO))
		lInclui:= .t.
		While SD1->( !Eof() .and. xFilial('SD1')+cNota+cSerie+cFornec+cLoja+CBE->CBE_CODPRO ==;
			D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD)
			If !Empty(CBE->CBE_LOTECT) .And. CBE->CBE_LOTECT # SD1->D1_LOTECTL
				SD1->(dbSkip())
				Loop
			EndIf
			lDif := .F.
			For nX := 1 to SD1->(FCount())
				If AllTrim(SD1->(FieldName(nX))) $ "D1_QUANT/D1_QTDCONF/D1_TOTAL/D1_ITEM/D1_DTVALID/D1_LOTECTL/D1_QTSEGUM" // campos ignorados
					Loop
				EndIf
				If SD1->(FieldGet(nX)) # aItens[nPos2,nX]
					lDif := .T.
					Exit
				EndIf
			Next
			If !lDif
				lInclui := .f.
				Exit
			EndIf
			SD1->(dBSkip())
		EndDo
		If lInclui
			RecLock("SD1",.t.)
			If UsaCB0('01')
				nPosItem := AScan(aItemD1,{|x| x[1]+x[2]+x[3] == CB120EtCB0(,CBE->CBE_CODETI)+CBE->(CBE_CODPRO+CBE_LOTECT)})			
		   EndIf
			If nPosItem > 0
				cItem := aItemD1[nPosItem,1]
			Else
				cItem := Iif(lSDS .And. nSldColD1 == 0,aItens[nPos2,nItemD1],Soma1(cItem,Len(cItem)))
			EndIf

			For nX:= 1 to SD1->(FCount())
				If SD1->(FieldName(nX)) == "D1_LOTECTL"
					uVar := CBE->CBE_LOTECT
				ElseIf SD1->(FieldName(nX)) == "D1_QUANT" .OR. SD1->(FieldName(nX)) == "D1_QTDCONF"
					uVar := nQtdBaixa
				ElseIf SD1->(FieldName(nX)) == "D1_QTSEGUM"
					uVar := ConvUm(CBE->CBE_CODPRO,nQtdBaixa,0,2)
				ElseIf SD1->(FieldName(nX)) == "D1_DTVALID"
					uVar := CBE->CBE_DTVLD
				ElseIf SD1->(FieldName(nX)) == "D1_ITEM"
					uVar := cItem
				ElseIf SD1->(FieldName(nX)) == "D1_TOTAL"
					uVar := SD1->D1_QUANT*SD1->D1_VUNIT
				ElseIf SD1->(FieldName(nX)) == "D1_DESC"
					uVar := nDesc / SD1->D1_QUANT * nQtdBaixa
				ElseIf SD1->(FieldName(nX)) == "D1_VALDESC"
					uVar := Round( ( nValDesc * Round( ( nQtdBaixa * 100 ) / ( nSaldoSD1 ), nTamValDsc ) ) / 100, nTamValDsc )
				Else
					uVar := aItens[nPos2,nX]
				EndIf
				SD1->(FieldPut(nX,uVar))
			Next
		Else
			RecLock("SD1",.f.)
			SD1->D1_QUANT   += nQtdBaixa
			SD1->D1_QTSEGUM += ConvUm(CBE->CBE_CODPRO,nQtdBaixa,0,2)
			SD1->D1_QTDCONF := SD1->D1_QUANT
			SD1->D1_TOTAL   := SD1->D1_QUANT*SD1->D1_VUNIT
			If UsaCB0('01')
				CB120EtCB0(SD1->D1_ITEM,CBE->CBE_CODETI)
			EndIf			
		EndIf
		SD1->(MsUnlock())
		aItens[nPos2,nLenIte] -= nQtdBaixa
		nSaldoCBE -= nQtdBaixa

		If lSDS
			//Remove item já processado do array aItens
			If aItens[nPos2,nLenIte] <= 0
				Adel(aItens,nPos2)
				aSize(aItens,Len(aItens)-1)
			EndIf
		EndIf

	EndDo
	CBE->(DbSkip())
EndDo
CBE->(DbSetOrder(1))

// Caso esteja configurado para classificar NF com divergencia e a conferencia foi a menor, inclui as sobras para devolucao
If lClaCfDv
	nPosFil   := SD1->(FieldPos("D1_FILIAL"))
	nPosDoc   := SD1->(FieldPos("D1_DOC"))
	nPosSerie := SD1->(FieldPos("D1_SERIE"))
	nPosForn  := SD1->(FieldPos("D1_FORNECE"))
	nPosLoja  := SD1->(FieldPos("D1_LOJA"))
	For nX := 1 To Len(aItens)
		If aItens[nX][Len(aItens[nX])] > 0
			cChaveSD1 := SD1->( aItens[nX][nPosFil]  +;
								aItens[nX][nPosDoc]  +;
								aItens[nX][nPosSerie]+;
								aItens[nX][nPosForn] +;
								aItens[nX][nPosLoja] +;
								aItens[nX][nPosCod])
			SD1->(DbSetOrder(1))
			lAchouSD1 := SD1->(DbSeek(cChaveSD1))

			If lAchouSD1	// Posiciona no ultimo item do produto conferido
				While !SD1->(Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD) == cChaveSD1
					SD1->(DbSkip())
				End
				SD1->(DbSkip(-1))
			EndIf

			RecLock("SD1", !lAchouSD1)
			For nY := 1 To Len(aItens[nX])-1
				cCampo := SD1->(FieldName(nY))
				If cCampo == "D1_ITEM"
					If !lAchouSD1
						cItem := Soma1(cItem,Len(cItem))
						SD1->(FieldPut(nY, cItem))
					EndIf
				ElseIf cCampo == "D1_QUANT"
					nQtdOrig := aItens[nX][nY]
					If !lAchouSD1
						SD1->(FieldPut(nY, aItens[nX][Len(aItens[nX])]))
					Else
						SD1->(FieldPut(nY, aItens[nX][Len(aItens[nX])] + SD1->D1_QUANT))
					EndIf
				ElseIf cCampo == "D1_TOTAL"
					SD1->(FieldPut(nY, SD1->D1_QUANT * SD1->D1_VUNIT))
				ElseIf cCampo == "D1_VALDESC"
					SD1->(FieldPut(nY, Round(aItens[nX][nY] * Round(( SD1->D1_QUANT * 100 ) / nQtdOrig, nTamValDsc) / 100, nTamValDsc )))
				ElseIf !lAchouSD1
					SD1->(FieldPut(nY, aItens[nX][nY]))
				EndIf
			Next nY
			MsUnlock()
		EndIf
	Next nX
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Informa    ³ Autor ³ Eduardo Motta       ³ Data ³ 28/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra produtos que ja foram lidos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Informa()
Local aCab,aSize,aSave := VTSAVE()
VTClear()
aCab  := {STR0005,STR0004} //"Produto"###"Quantidade"
aSize := {10,16}
VTaBrowse(0,0,7,19,aCab,aConf,aSize)
VtRestore(,,,,aSave)
Return


Static Function Estorna()
Local aTela
Local cEtiqueta
aTela := VTSave()
VTClear()
cEtiqueta := Space(20)
nQtdePro  := 1
@ 00,00 VtSay Padc(STR0023,VTMaxCol())   //"Estorno da Leitura"
If ! UsaCB0('01')
	@ 1,00 VTSAY  STR0024
	@ 1,05 VTGet nQtdePro   pict CBPictQtde() when VTLastkey() == 5  //'Qtde. '
EndIf
@ 02,00 VtSay STR0025 //"Etiqueta:"
@ 03,00 VtGet cEtiqueta pict "@!" Valid VldEstorno(cEtiqueta,nQtdePro)
VtRead
vtRestore(,,,,aTela)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldEstorno ³ Autor ³ TOTVS				³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o Estorno						                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEstorno(cEtiqProd,nQtdProd)
Local aProd
Local cProduto := Space(TamSx3("B1_COD")[1])
Local nQE   := 0 //quantidade por embalagem
Local lCodInt 	:= .T.
Local cTipId 	:= ""
Local cLote 	:= Space(TamSx3("D1_LOTECTL")[1])
Local dValid	:= ctod('') 
If Empty(cEtiqProd)
	Return .f.
EndIf
If ! CBLoad128(@cEtiqProd)
	VTkeyBoard(chr(20))
	Return .f.
EndIf

Begin sequence
	dbSelectArea("SA5")
	SA5->(dbSetorder(8)) //A5_CODBAR
	If UsaCB0("01") .and. SA5->(dbSeek(xFilial("SA5")+cFornec+cLoja+Padr(AllTrim(cEtiqProd),Tamsx3("B1_COD")[1])))
 		cProduto := SA5->A5_PRODUTO
		nQE      :=CBQtdEmb(cProduto)
		If Empty(nQE)
			Break
		EndIf
		nQtdProd := nQtdProd*nQE
		lCodInt := .F.
	Else
		cTipId:=CBRetTipo(cEtiqProd)
		If UsaCB0("01") .And. cTipId=="01"
			aProd := CBRetEti(cEtiqProd,"01")  	//Produto
			If Empty(aProd)
				VTBeep(2)
				VTAlert(STR0011,STR0010,.T.,4000)  //"Etiqueta invalida."###"Aviso"
				Break
			EndIf
			cProduto := aProd[1]
			nQE      := aProd[2]
			cLote    := aProd[16]
			dValid   := aProd[18]
			nQtdProd := nQE
			lCodInt := .t.
		ElseIf !UsaCB0("01") .And. cTipId $ "EAN8OU13-EAN14-EAN128"  //-- nao tem codigo interno e tera'que ser impresso a etiqueta de identificacao
			aProd := CBRetEtiEan(cEtiqProd)
			If Empty(aProd) .or. Empty(aProd[2])
				VTBeep(2)
				VTAlert(STR0011,STR0010,.T.,4000)  //"Etiqueta invalida."###"Aviso"
				Break
			EndIf
			cProduto := aProd[1]
			nQE := 1
			If ! CBProdUnit(cProduto)
				nQE := CBQtdEmb(cProduto)
				If Empty(nQE)
					Break
				EndIf
			EndIf
			nQtdProd := nQtdProd*nQE*aProd[2]
			cLote    := aProd[3]
			dValid   := aProd[4]
			lCodInt  := .F.
		Else
			VTBeep(2)
			VTAlert(STR0029,STR0010,.T.,4000) //"Aviso"###"Etiqueta invalida"
			Break
		EndIf
	EndIf
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial('SB1')+cProduto))
	If Empty(cLote) .or. Empty(dValid)
		dValid := dDatabase+SB1->B1_PRVALID
		If ! CBRastro(cProduto,@cLote,,@dValid,.t.)
			VTKeyboard(chr(20))
			Break
		EndIf
	EndIf

	nPos :=AScan(aConf,{|x|AllTrim(x[1])==AllTrim(cProduto) })
	If nPos ==0
		VTBeep(2)
		VTAlert(STR0026,STR0010,.T.,4000)  //"Produto nao conferido."###"Aviso"
		Break
	EndIf
	If nQtdProd > aConf[nPos,2]
		VTBeep(2)
		VTAlert(STR0027,STR0010,.T.,4000)  //"Quantidade invalida."###"Aviso"
		Break
	EndIf
	If ! VTYesNo(STR0033,STR0007,.t.)   //"Confirma o estorno?"###"ATENCAO"
		Break
	EndIf
	If Usacb0('01')
		GravaCBE(CB0->CB0_CODETI,cProduto,nQtdProd,cLote,dValid,.t.)
	Else
		GravaCBE(Space(10),cProduto,nQtdProd,cLote,dValid,.t.)
	EndIf
	DistQtdConf(cProduto,nQtdProd,.t.,,,cNota,cSerie,cFornec,cLoja)
End Sequence
VTKeyBoard(chr(20))
Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GravaCBE   ³ Autor ³ TOTVS				³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a Tabela CBE					                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GravaCBE(cID,cProduto,nQtde,cLote,dValid,lEstorno)
Local nPos
Local cIdAux := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
Static aCB0  :={} 


DEFAULT lEstorno := .f.
CBE->(DbSetOrder(1))
cID := Padr(cID,10)
If	! lEstorno
	If	CBE->(DBSeek(xFilial("CBE")+cID+cNota+cSerie+cFornec+cLoja+cProduto+cLote+dtos(dValid)))
		If ! UsaCB0("01")
			RecLock("CBE",.f.)
			CBE->CBE_CODUSR	:= cCodOpe
			CBE->CBE_DATA	:= dDatabase
			CBE->CBE_HORA	:= Time()
			CBE->CBE_QTDE   += nQtde
			CBE->(MsUnLock())
		EndIf
	Else
		RecLock("CBE",.t.)
		CBE->CBE_FILIAL	:= xFilial("CBE")
		CBE->CBE_NOTA	:= cNota
		SerieNfId("CBE",1,"CBE_SERIE",,,cSerie)
		CBE->CBE_FORNEC	:= cFornec
		CBE->CBE_LOJA	:= cLoja
		CBE->CBE_CODPRO	:= cProduto
		CBE->CBE_QTDE	:= nQtde
		CBE->CBE_LOTECT	:= cLote
		CBE->CBE_CODUSR	:= cCodOpe
		CBE->CBE_DTVLD	:= dValid
		CBE->CBE_CODETI	:= cID
		CBE->CBE_DATA	:= dDatabase
		CBE->CBE_HORA	:= Time()
		CBE->(MsUnLock())
		
		If Usacb0("01")
			aAdd(aCB0,CB0->CB0_CODETI) //-- Codigo da Etiqueta	
			CBGrvEti("01",{,nQtde,cCodOpe,cNota,cSerie,cFornec,cLoja,NIL,NIL,NIL,NIL,NIL,,,,cLote,NIL,dValid},cID)	
		EndIf
		nPos:= Ascan(aLog,{|x| x[1]+x[3]+x[4]+x[5]+x[6]+x[7]+x[9] == cProduto+cLote+cNota+cSerie+cFornec+cLoja+cID}) 
		If nPos == 0
			cIdAux := cID
			If Usacb0("01")
				cIdAux := CB0->CB0_CODETI
			EndIf
			aadd(aLog,{cProduto,nQtde,cLote,cNota,cSerie,cFornec,cLoja,NIL,cIDAux})
		Else
			aLog[nPos,2] += nQtde
		EndIf
	EndIf
Else
	If	CBE->(DBSeek(xFilial("CBE")+cID+cNota+cSerie+cFornec+cLoja+cProduto+cLote+dtos(dvalid)))
		RecLock("CBE",.f.)
		CBE->CBE_QTDE   -= nQtde
		If	Empty(CBE->CBE_QTDE)
			CBE->(DbDelete())
		EndIf
		CBE->(MsUnLock())
		If	Usacb0("01")
			CBGrvEti("01",{,,cCodOpe,"","","","",NIL,NIL,NIL,NIL,NIL,,,,"",NIL,ctod("  /  /  ")},cID)
		EndIf

		nPos:= Ascan(aLog,{|x| x[1]+x[3]+x[4]+x[5]+x[6]+x[7]+x[9] == cProduto+cLote+cNota+cSerie+cFornec+cLoja+cID}) 
		If	nPos > 0
			aLog[nPos,2] -= nQtde
		EndIf
	EndIf
EndIf
//-- Ponto de Entrada após gravação da tabela CBE (Etiquetas lidas receb.)
If	ExistBlock("AV120CBE")
	ExecBlock("AV120CBE",.F.,.F.,{lEstorno})
EndIf
Return .t.

Function PesqCBE(cID)
CBE->(DbSetOrder(1))
Return CBE->(DBSeek(xFilial("CBE")+cID))


Static Function AjustadValid(cProduto,cLote,dValid)
Local lDif:= .f.
Local lUsaCb0 := UsaCB0("01")
Local nRecCB0 :=0
Local dDtAnt
Local aDados

If lUsaCb0
	nRecCB0 := CB0->(RecNo())
EndIf

If ! Rastro(cProduto,'L')
	Return .t.
EndIf

CBE->(DbSetOrder(2))
CBE->(DBSeek(xFilial('CBE')+cNota+cSerie+cFornec+cLoja+cProduto))
While CBE->(!EOF() .AND. xFilial('CBE')+cNota+cSerie+cFornec+cLoja+cProduto ==;
								CBE_FILIAL+CBE_NOTA+CBE_SERIE+CBE_FORNEC+CBE_LOJA+CBE_CODPRO)
	If CBE->CBE_LOTECT == cLote .and. CBE->CBE_DTVLD # dValid
		dDtAnt := CBE->CBE_DTVLD
		lDif := .t.
		Exit
	EndIf
	CBE->(DbSkip())
End
CBE->(DbSetOrder(1))
If ! lDif
	Return .t.
EndIf
If ! VTYesNo(STR0034+dtoc(dDtAnt)+STR0035+dtoc(dValid)+"?",STR0036,.T.) //"Ajusta a validade de "###" para "###"Validade diferente"
	dValid := dDtAnt
	Return .t.
EndIf
CBE->(DbSetOrder(2))
CBE->(DBSeek(xFilial('CBE')+cNota+cSerie+cFornec+cLoja+cProduto))
While CBE->(!EOF() .AND. xFilial('CBE')+cNota+cSerie+cFornec+cLoja+cProduto ==;
							CBE_FILIAL+CBE_NOTA+CBE_SERIE+CBE_FORNEC+CBE_LOJA+CBE_CODPRO)
	If CBE->CBE_LOTECT == cLote .and. CBE->CBE_DTVLD # dValid
		RecLock("CBE",.f.)
		CBE->CBE_DTVLD  := dValid
		CBE->(MsUnLock())
		If ! empty(CBE->CBE_CODETI)
			aDados := CBRetEti(CBE->CBE_CODETI,"01")
			aDados[18] := dValid
			CBGrvEti("01",aDados,CBE->CBE_CODETI)
		EndIf
	EndIf
	CBE->(DbSkip())
End
CBE->(DbSetOrder(1))
If lUsaCb0
	CB0->(DbGoto(nRecCB0))
EndIf
Return .t.

Static Function RetQtdConf()
Local cChave := SF1->(xFilial("SF1")+cNota+cSerie+cFornec+cLoja)
Local nQtdConf:=0
TMP->(DbSeek(cChave))
While ! TMP->(Eof()) .and. TMP->CHAVE == cChave
	If ! Tmp->(RLock())
		nQtdConf++
	Else
		Tmp->(DbDelete())
		Tmp->(DbUnlock())
	EndIf
	Tmp->(DbSkip())
End
Return nQtdConf

Static function TravaTmp(lTrava)

DEFAULT lTrava:= .T.
If lTrava
	RecLock("SF1",.F.)
	SF1->F1_STATCON := "3" //-- Em conferencia
	SF1->F1_QTDCONF := RetQtdConf()+1
	MsUnlock()
	RecLock("TMP",.T.)
	TMP->NUMRF :=VTNUMRF()
	TMP->CHAVE := cNota+cSerie+cFornec+cLoja
	TMP->(MsUnlock())
	RecLock("TMP",.f.)
	lLocktmp:= .t.
Else
	If lLocktmp
		TMP->(DbDelete())
		TMP->(MsUnlock())
		lLocktmp := .f.
		RecLock("SF1",.F.)
		SF1->F1_QTDCONF := RetQtdConf()
		MsUnlock()
	EndIf
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CB120EtCB0 ³ Autor ³ Isaias Florencio    ³ Data ³ 17/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o item da etiqueta conferida, se necessario.      ³±±
±±³          ³ Tambem retorna o numero do item da etiqueta                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDV120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CB120EtCB0(cItemSD1,cEtiqCBE)
Local aAreaCB0   := CB0->(GetArea())
Local cItem      := ""
Default cItemSD1 := ""

If !Empty(cItemSD1)
	If cItemSD1 <> Posicione("CB0",1,xFilial("CB0")+cEtiqCBE,"CB0_ITNFE")
		RecLock("CB0",.F.)
		CB0->CB0_ITNFE := SD1->D1_ITEM
		MsUnlock()
	EndIf
Else
	cItem := Posicione("CB0",1,xFilial("CB0")+cEtiqCBE,"CB0_ITNFE")
EndIf	

RestArea(aAreaCB0)
Return cItem

// ------------------------------------------------------------------------------------
/*/{Protheus.doc} VldProdIg
Verifica se existe produtos iguais, caso tenha verifique a 
localização por LOTE ou por QUANTIDADE Não localizando segue fluxo antigo.

@param: cNota,cSerie,cFornec,cLoja,cProd

@author: André Maximo
@since:  24/03/2016
/*/
// -------------------------------------------------------------------------------------

Function VldProdIg(cNota,cSerie,cFornec,cLoja,cProd,cLote,dValid)
	
Local aAreaSD1:= SD1->(GetArea())
Local aAreaSF1:= SF1->(GetArea())
Local nContLote := 0
Local nContProd := 0 
Local nLtigual  := 0 
Local nX        := 0
Local nY		  := 0 

Default cNota   := " "
Default cSerie  := " "
Default cFornec := " "
Default cLoja   := " "
Default cProd   := " "
Default cLote 	:= Space(TamSx3("D1_LOTECTL")[1])
Default dValid	:= ctod('') 


dbSelectArea("SF1")
SF1->(dbSetOrder(1))
SF1->(dbSeek(xFilial("SF1")+cNota+cSerie+cFornec+cLoja))
dbSelectArea("SD1")
SD1->(dbSetOrder(1))
SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cProd))
	
While ! SD1->(Eof()) .and. ;
	xFilial("SD1")  == D1_FILIAL .and.;
	SD1->D1_DOC     == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and.;
	SD1->D1_FORNECE == SF1->F1_FORNECE .and.;
	SD1->D1_LOJA    == SF1->F1_LOJA .and. SD1->D1_COD == cProd
	// Quantas vezes localizou o produto
		nContProd++	
	// Verifica se localizou lote	
	If !Empty(SD1->D1_LOTECTL) 
	    nContLote++ 
   EndIf
   aAdd(aItensDP,{SD1->D1_ITEM,SD1->D1_COD,SD1->D1_QUANT,SD1->D1_LOTECTL,SD1->D1_DTVALID})
   SD1->(dbSkip())
Enddo

If 	nContProd >= 2 .And. nContLote > 0 
	ItIguais := .T.
EndIf

If nContProd >= 2
	 If nContLote == nContProd .And. Len(aItensDP)>0
	//Verifica se o lote repete em todos os itens 
		For nX := 1 to Len(aItensDP)
			For nY := 1 to Len (aItensDP)
				If ((aItensDP[nX][4] == aItensDP[nY][4]) .And. (nX <> nY))
					nLtigual++
				EndIF
			Next
			If nLtigual == Len(aItensDP)
				// Ativou Localização por Lote
				ItIguais := .F.
			EndIf
		Next			
	 EndIf
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSF1)

Return(ItIguais)


// -------------------------------------------------------------------------------------
/*/{Protheus.doc} TelDocSel
Tela de Seleção de Produtos iguais 

@param: 
@author: André Maximo 
@since:  12/09/2016
/*/
// -------------------------------------------------------------------------------------

Static function TelDocSel(cNota,cSerie,cFornec,cLoja,cProd,cLote)

Local aAreaSD1:= SD1->(GetArea())
Local aTela:= VtSave()
Local aFields := {"D1_ITEM","D1_QUANT","D1_LOTECTL"}
Local aSize   := {4,4,TamSx3("D1_LOTECTL")[1]}
Local aHeader := {'ITEM','QUANT','LOTE'} 
Local cTop,cBottom
Local nRecno

Default cNota   := " "
Default cSerie  := " "
Default cFornec := " "
Default cLoja   := " "
Default cProd   := " "
Default cLote 	:= Space(TamSx3("D1_LOTECTL")[1])


dbSelectArea("SD1")
SD1->(dbSetOrder(1))
cCodDoc:= SD1->(xFilial("SD1")+cNota+cSerie+cFornec+cLoja+cProd)

If SD1->(dbSeek(cCodDoc))
	nRecno := SD1->(Recno())
	ctop	:= SD1->(xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD)
	cBottom:= SD1->(xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD)
	VtClear()
	If VTModelo()=="RF"
		@ 0,0 VTSay STR0051 //Itens igual
		@ 1,0 VTSay STR0005 +': '+cProd  //Produtos
		@ 2,0 VTSay STR0052 //Iguais.
		nRecno := VTDBBrowse(3,0,VTMaxRow(),VTMaxCol(),"SD1",aHeader,aFields,aSize,,"'"+cTop+"'","'"+cBottom+"'")
	Else
		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxCol(),"SD1",aHeader,aFields,aSize,,"'"+cTop+"'","'"+cBottom+"'")
	EndIf
	If VtLastkey() == 27
		VTRestore(,,,,aTela)
		Return
	EndIf
	cItemPd:=SD1->D1_ITEM

EndIf

RestArea(aAreaSD1)

VTRestore(,,,,aTela)

Return 
