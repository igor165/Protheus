//Atualização de fonte - MSERV-3090
#Include "Protheus.ch"
#Include "Ctba102.ch"
#Include "Colors.ch"
#Include "FWLIBVERSION.CH"

STATIC cPictVal
STATIC nQtdEntid
STATIC lFWCodFil   := FindFunction("FWCodFil")
STATIC cGuarFil    := ""
STATIC _oCTBA1021
STATIC _lAutomato  := .F.
STATIC lPar15 := .F.
STATIC _lUsarCTC

STATIC _aRecCT2  := {}
Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6" //Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6
STATIC _lForcHead := .T.
STATIC _lForcCrTmp := .T.
STATIC _aCampos	:= Nil
STATIC _aAltera	:= Nil
STATIC _aHeadCtb	:= Nil
Static _cT2key  := ""
Static _cProg  := "CTBA102"

Static _lNewSemaf  := NIL  ////o semaforo só será habilitado a partir da 12.1.31. Somente a existencia do cmpo CTF_USADO
Static _lCTB102MB  := ExistBlock("CTB102MB")
Static _lCt102VlEs := ExistBlock("CT102VLES")
Static _lCT102ACAP := ExistBlock("CT102ACAP")
Static _lCT102BTO  := ExistBlock("CT102BTO")
Static _lCT102DLG  := ExistBlock("CT102DLG")
Static _lCT105TOK  := ExistBlock("CT105TOK")
Static _lCT105CHK  := ExistBlock("CT105CHK")
Static _lCTB102EXC := ExistBlock("CTB102EXC")
Static _lANCTB102GR:= ExistBlock("ANCTB102GR")
Static _lDPCTB102GR:= ExistBlock("DPCTB102GR")
Static _lCt102Carr := ExistBlock("Ct102Carr")
Static _lRATONFIL  := ExistBlock("RATONFIL")					////  SE EXISTIR O PE RATONFIL
Static _lCTB102RT  := ExistBlock("CTB102RT")
Static _lFLTESTLT  := ExistBlock("FLTESTLT")
Static _lVCTB102EST:= ExistBlock("VCTB102EST")
Static _lCTB102ESTL:= ExistBlock("CTB102ESTL")
Static _lCT102BUT  := ExistBlock("CT102BUT")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA102   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao de Lancamento Contabeis - Manuais - Automatizado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba102(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Jose Glez  ³        ³  MMI-5346 ³Numero de póliza debe ser consecutivo³±±
±±³            ³        ³           ³por mes.                             ³±±
±±³  Marco A.  ³28/05/18³DMINA-2113 ³Se modifican funciones C102ProxDoc,  ³±±
±±³            ³        ³           ³Ct102GrCTF y Ct102GrCTF para Numero  ³±±
±±³            ³        ³           ³de Poliza Consecutivo por mes. (MEX) ³±±
±±³Alf. Medrano³06/02/20³DMINA-8033 ³En fun ctba102Lan() y Ctba102cap() se³±±
±±³            ³        ³           ³informa dDataCTF contiene fecha con  ³±±
±±³            ³        ³           ³primer día del mes actual, se utiliza³±±
±±³            ³        ³           ³para excluir los num consecutivos de ³±±
±±³            ³        ³           ³de la tabla CTF que no fueron usados ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA102(xAutoCab,xAutoItens,nOpcAuto,lAutomato)

Local nX			:= 0
Local lSeqCorr	  	:= .F.
Local cSeqCorr 		:= Space(10)
Local cFiltro 		:= ""
Local aLegenda      := {}

Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para rotina automatica    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lCt102Auto  := ( ValType(xAutoCab) == "A"  .And. ValType(xAutoItens) == "A" )
Private aAutoCab  	:= {}
Private aAutoItens	:= {}

Private cCadastro 	:= OemToAnsi(STR0006) // "Lan‡amentos Cont beis - Automaticos"
Private dDataLanc
Private cLote
Private cLoteSub 	:= SuperGetMv("MV_SUBLOTE")
Private cSubLote 	:= cLoteSub
Private lSubLote 	:= Empty(cSubLote)
Private cDoc

Private __lCusto	:= .F.
Private __lItem 	:= .F.
Private __lCLVL		:= .F.
Private aCtbEntid

_lForcHead := .T.
_lForcCrTmp := .T.

If lAutomato <> NIL
	_lAutomato	:= lAutomato
Endif

If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If aCtbEntid == NIL
	aCtbEntid := Array(2,nQtdEntid)  //posicao 1=debito  2=credito
EndIf
//DEBITO
aCtbEntid[1,1] := {|| TMP->CT2_DEBITO 	}
aCtbEntid[1,2] := {|| TMP->CT2_CCD		}
aCtbEntid[1,3] := {|| TMP->CT2_ITEMD 	}
aCtbEntid[1,4] := {|| TMP->CT2_CLVLDB 	}
//CREDITO
aCtbEntid[2,1] := {|| TMP->CT2_CREDIT }
aCtbEntid[2,2] := {|| TMP->CT2_CCC		}
aCtbEntid[2,3] := {|| TMP->CT2_ITEMC 	}
aCtbEntid[2,4] := {|| TMP->CT2_CLVLCR 	}

lPar15 := IIf(Alltrim(Posicione("SX1",1,PadR("CTB102",10)+"15","X1_PERGUNT")) <> "",.T.,.F.) 

For nX := 5 TO nQtdEntid
	aCtbEntid[1, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"DB } ")  //debito
	aCtbEntid[2, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"CR } ")  //credito
Next

lSeqCorr := UsaSeqCor("CT2/CTK/CT5") // Controle do Correlativo

If lSeqCorr
	cSeqCorr := CriaVar( "CT2_SEGOFI" )
EndIf


If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros EXCLUSAO/ESTORNO lanc.  ³
//³ mv_par01 // Da data					                         ³
//³ mv_par02 // Até a data										 ³
//³ mv_par03 // Do Lote											 ³
//³ mv_par04 // Até o Lote										 ³
//³ mv_par05 // Do Sublote				   					     ³
//³ mv_par06 // Até o Sublote					                 ³
//³ mv_par07 // Do Documento							         ³
//³ mv_par08 // Ate o Documento                                  ³
//³ mv_par09 // Gerar na data lanc. orig.?                       ³
//³ mv_par10 // Data dos lanc. estorno?                          ³
//³ mv_par11 // Num.lote inic. estorno?                          ³
//³ mv_par12 // Num.sublote inic. estorno?                       ³
//³ mv_par13 // Num.doc. inic. estorno?                          ³
//³ mv_par14 // Imprime relat. inconsist.?                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If _lUsarCTC == Nil
	_lUsarCTC := .F.
EndIf

SetKey(VK_F12,{|a,b|AcessaPerg("CTB102A",.T.)})

Pergunte("CTB102A",.F.)

dbSelectArea("CTK")
dbSetOrder(1)

dbSelectArea("CT2")
dbSetOrder(1)

dbSelectArea("CTC")
dbSetOrder(1)



If lCt102Auto

	If IsInCallStack("CTB102_001") .OR. IsInCallStack("CTB102_002") .or. IsInCallStack("CTB102_005")
		_lAutomato :=  lCt102Auto
	EndIf

	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens

	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"CT2" ,,If(nOpcAuto=6,.T.,nil))
	xAutoCab   := aAutoCab
	xAutoItens := aAutoItens

Else

	oBrowse := FWMBrowse():New()

    _lUsarCTC := (MV_PAR01 == 1)     	

    if _lUsarCTC
	    oBrowse:SetAlias("CTC")
		oBrowse:SetDescription(STR0006) // "Lan‡amentos Cont beis - Automaticos"
		aLegenda := CtbLegenda("CTC")
		for nX := 1 To Len(aLegenda)
			oBrowse:AddLegend( aLegenda[nX,1],  aLegenda[nX,2] ,  aLegenda[nX,3] )
		next
		If !Empty( cFiltro )
			oBrowse:SetFilterDefault( cFiltro )
		EndIf

    else
		//ponto de entrada para usuario filtrar a tabela CT2 na mBrowse
		If _lCTB102MB
			cFiltro := Execblock("CTB102MB",.f.,.f.)
		Endif

	    oBrowse:SetAlias("CT2")
		oBrowse:SetDescription(STR0006) // "Lan‡amentos Cont beis - Automaticos"
		aLegenda := CtbLegenda("CT2")
		for nX := 1 To Len(aLegenda)
			oBrowse:AddLegend( aLegenda[nX,1],  aLegenda[nX,2] ,  aLegenda[nX,3] )
		next
		If !Empty( cFiltro )
			oBrowse:SetFilterDefault( cFiltro )
		EndIf

    endif

   	oBrowse:Activate()
EndIf

dbSetOrder(1)

If Select("TMP") > 0
	dbSelectArea("TMP")
	dbCloseArea()
Endif

If _lUsarCTC
	dbSelectArea("CTC")
Else
	dbSelectArea("CT2")
EndIf

// limpa a o cache do fonte ctba105 quando sair da tela.
ClearCx105()

If ! _lForcCrTmp
	//volta as variaveis static deste fonte ao estado original
	_lForcHead := .T.
	_lForcCrTmp := .T.
	_aCampos	:= Nil
	_aAltera	:= Nil
	_aHeadCtb	:= Nil
	//seta variaveis static ao valor original do fonte ctba105 ref. criação da tabela e aheader do temporario
	Ct105VOrig()
EndIf

SET KEY VK_F12 to

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA102Cal³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a Capa de Lote                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctba102Cal(cAlias,nReg,nOpc)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba102Cal(cAlias,nReg,nOpc)
Local lSeqCorr		:= UsaSeqCor("CT2/CTK/CT5")
Local cSegOfi 		:= SuperGetMv( "MV_SEGOFI" , .F. , "0" )
Local lRet			:= .T.
Local lGestao		:= Iif( lFWCodFil, ( Len(CT2->CT2_FILIAL) > 2 ), .F. )	// Indica se usa Gestao Corporativa
Local aModoCompCT2 := {}
Local cLayoutEmp := FWSM0Layout()
Local cAuxFilCT2 := ""
Local oFiltro :=  GetMBrowse()

Private aFiltro := {}
If _lNewSemaf == NIL
	_lNewSemaf := CTF->(FieldPos('CTF_USADO'))>0
Endif

If FunName() == "CTBA102" .And. nOpc == 3 .And. !VerSenha(191)
	Return
EndIf

If ValType(oFiltro) == "O" .And. oFiltro:OFWFILTER != Nil // oFiltro:OFWFILTER vai ser igual a NIL quando a opção 116 ("MWBrowse - Permite Uso de Filtro") estiver desmarcada no configurador
	If !Empty (oFiltro:OFWFILTER:ACHECKFIL)
		aFiltro := oFiltro:OFWFILTER:ACHECKFIL
	EndIf
EndIf

//Se o alias do BROWSE é o CTC devemos possicionar na CT2 no
//primeiro registro do lote que está na CTC

If !Inclui //trecho acrescentado para tratativa do desposicionamento ao fazer a inclusao, nao deve considerar amarracao entre CT2 x CTC
	If cAlias == "CTC"
		dbSelectArea("CT2")
		dbSetOrder(1)
		if dbSeek(xFilial("CT2")+CTC->(DTOS(CTC_DATA)+CTC_LOTE+CTC_SBLOTE+CTC_DOC))
			cAlias := "CT2"
			nReg := CT2->(Recno())
		else
			Help(" ",1,"CTCSEMCT2")
			lRet:= .F.
		endif
	endif
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Verifica se e lancamento complementar e em caso afirmativo   ³
³verifica se a operacao é valida para esse tipo de lancamento.³
³                                                             ³
³Para lancamento complementar, somente a visualizacao e       ³
³permitida.                                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If CTBLCUso()
	If !(nOpc == 2 .Or. nOpc == 3)
		If Substr(CT2->CT2_ORIGEM,1,9) == "__CTBLC__"
			lRet := .F.
			cMsg := STR0096 + CRLF
			cMsg += STR0097
			MsgStop(cMsg,STR0098)
		Endif
	Endif
Endif

If lRet .And. nOpc == 5 .And. lSeqCorr .And. cSegOfi == '5'
	Help(" ",1,"CORRNOEXC")
	lRet := .F.
EndIf

If lRet .And. (nOpc == 5 .Or. nOpc == 4)
	lRet := CTBValFila(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DATA,.T.)
EndIf


If lRet .And. nOpc == 7 .And. Empty(cGuarFil)
	If lFWCodFil .And. lGestao

	    aAdd(aModoCompCT2, FWModeAccess("CT2",1) )
	    aAdd(aModoCompCT2, FWModeAccess("CT2",2) )
	    aAdd(aModoCompCT2, FWModeAccess("CT2",3) )

 		If Ascan(aModoCompCT2, 'E') > 0

 		    cAuxFilCT2 := CtbAuxFil(cLayoutEmp, aModoCompCT2)

 			If ! Empty(CT2->CT2_FILIAL) .And. CT2->CT2_FILIAL != cAuxFilCT2
				Aviso(STR0060, STR0099 ,{STR0100}) //##"Atenção"##"Cópia não permitida. Cópia somente na filial corrente."##"Fechar"
				lRet := .F.
			EndIf

		EndIf

	Else

 		If ! Empty(CT2->CT2_FILIAL) .And. CT2->CT2_FILIAL != cFilAnt
			Aviso(STR0060, STR0099 ,{STR0100}) //##"Atenção"##"Cópia não permitida. Cópia somente na filial corrente."##"Fechar"
			lRet := .F.
		EndIf

	EndIf

EndIf

If lRet

	If cPictVal == Nil
		cPictVal  := PesqPict("CT2","CT2_VALOR")
	Endif	
	
	If IsBlind() .And. (nOpc == 5 .Or. nOpc == 4)
		dDataLanc := CT2->CT2_DATA
		cLote	  := CT2->CT2_LOTE
		cSubLote  := CT2->CT2_SBLOTE
		cDoc 	  := CT2->CT2_DOC		   
    EndIf     
    Ctba102Cap(cAlias,nReg,nOpc,'CTBA102',@dDataLanc,@cLote,@cSubLote,@cDoc)    

Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA102Cap³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Capa de Lote                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba102Cap(cAlias,nReg,nOpca,cProg,dDatalanc,cLote,cSubLote³±±
±±³          ³ cDoc)                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpC1 = Numero da Opcao do menu                            ³±±
±±³          ³ ExpC2 = Nome do Programa			                          ³±±
±±³          ³ ExpD1 = Data do Lancamento		                          ³±±
±±³          ³ ExpC3 = Numero do Lote  			                          ³±±
±±³          ³ ExpC4 = Numero do Sub-Lote		                          ³±±
±±³          ³ ExpC5 = Numero do Documento		                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba102Cap(cAlias,nReg,nOpc,cProg,dDataLanc,cLote,cSubLote,cDoc)
Local cPadrao
Local oDlg
Local oDoc
Local oLote
Local oSubLote
Local oInf, oInfLot, oHistLote
Local oLinha
Local oCodSeq

Local cCodSeq	:= ""
Local CTF_LOCK	:= 0
Local aAreaCT2	:= CT2->(GetArea())
Local lContinua := .F.
Local cLinha 	:= ""
Local cTitulo	:= ""
Local nTotInf 	:=nTotInfLot := 0
Local lDigita	:= .F.
Local nPosAut	:= 0
Local aCT102ACAP := {}

Local l102Inclui	:= .F.
Local l102Visual	:= .F.
Local l102Altera	:= .F.
Local l102Exclui	:= .F.
Local l102Estorno	:= .F.
Local l102Copia	:= .F.
Local lSeqCorr := UsaSeqCor("CT2/CTK/CT5") // Controle do Correlativo

Local lUseDocHis	:= (cPaisLoc == "ARG") .And. X3USADO("CTC_DOCHIS")
Local cHistLote		:= space(80)
Local aAreaCTF		:= {}
Local lOk := .T.

Local dDataLancX	:= dDataBase
Local cLoteX		:= ''
Local cSubLoteX		:= ''
Local cDocX			:= ''
Local dDataCTF	:= dDataLanc

Private nSaida		:= 0
Private aTotRdpe	:= {{0,0,0,0},{0,0,0,0}}

If _lNewSemaf == NIL
	_lNewSemaf := CTF->(FieldPos('CTF_USADO'))>0
EndIf
//atualiza variaveis caso MV_SUBLOTE for exclusivo, após seleção da filial
cLoteSub := SuperGetMv("MV_SUBLOTE")
cSubLote :=	cLoteSub
lSubLote := Empty(cSubLote)

cPictVal := Iif( cPictVal == NIL, PesqPict("CT2","CT2_VALOR"), cPictVal )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nOpc == 2
		l102Visual := .T.
	Case nOpc == 3
		l102Inclui	:= .T.
		lDigita		:= .T.
	Case nOpc ==  4
		l102Altera	:= .T.
	Case nOpc ==  5
		l102Exclui	:= .T.
		l102Visual	:= .T.
	Case nOpc == 6
		l102Estorno := .T.
		lDigita		:= .T.
	Case nOpc == 7
		l102Copia	:= .T.
		lDigita		:= .T.
EndCase

If !_lAutomato
	dDataLanc	:= dDataBase
	cLote		:= CriaVar("CT2_LOTE")
	cSubLote	:= If(lSubLote, CriaVar("CT2_SBLOTE"), cLoteSub )
	cDoc		:= CriaVar("CT2_DOC")
	cPadrao	:= CriaVar("CT2_LP")
Else
	dDataLanc	:= MV_PAR10
	cLote		:= MV_PAR11
	cSubLote	:= MV_PAR12
	cDoc		:= MV_PAR13
	cPadrao	:= CriaVar("CT2_LP")
Endif

If lSeqCorr
	cCodSeq		:= CtbRdia()
EndIf

If l102Inclui .Or. l102Estorno .Or. l102Copia

	// BOPS 127818 - Problema com o Tamanho do sublote
    If ! Empty( cSubLote ) .AND. Len( alltrim( cSubLote )) < 3
    	cSubLote := StrZero( cSubLote , 3 )
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para preenchimento do lote/sublote     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _lCT102ACAP

		aCT102ACAP := ExecBlock( "CT102ACAP", .F., .F. )

		If ValType(aCT102ACAP) == "A" .and. Len(aCT102ACAP) > 0

			If !Empty(aCT102ACAP[1])
				cLote := aCT102ACAP[1]
			Endif

			If Len(aCT102ACAP) > 1
				If !Empty(aCT102ACAP[2])
					cSubLote := aCT102ACAP[2]
				Endif
			Endif
		Endif
	Endif
Else
	If Type( 'lCt102Auto' ) == "U" .Or. ! lCt102Auto
		dDataLanc	:= CT2->CT2_DATA
		cLote		:= CT2->CT2_LOTE
		cSubLote	:= CT2->CT2_SBLOTE
		cDoc		:= CT2->CT2_DOC
		cPadrao		:= CT2->CT2_LP
		If lSeqCorr
			cCodSeq := CT2->CT2_DIACTB
		EndIf
		If cPaisLoc == "ARG" .And. X3USADO("CTC_DOCHIS")
			cHistLote := CTBA102HCL()
		EndIf

	EndIf

Endif

If l102Altera .Or. l102Visual .Or. l102Exclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os totais da tela          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotInfLot := CtbSaldoLote(cLote,cSubLote,dDataLanc)[3]

	dbSelectArea("CTC")
	dbSetOrder(1)
	If MsSeek(xFilial()+dtos(dDataLanc)+cLote+cSubLote+cDoc+'01')
		nTotInf := CTC->CTC_INF
	Else
		nTotInf := 0
	Endif
EndIf

__lCusto	:= CtbMovSaldo("CTT")
__lItem		:= CtbMovSaldo("CTD")
__lCLVL		:= CtbMovSaldo("CTH")

If Type( 'lCt102Auto' ) == 'U' .or. ! lCt102Auto
	//Se for exclusão de lançamentos contábeis.
	If l102Exclui .And. FwIsInCallStack("CTBA102") .And. !_lAutomato
		If MsgNoYes(STR0086,STR0060)	//Atencao "Deseja realizar a exclusão por lote?"
			If Pergunte("CTB102",.T.)
				Ct102EstLt(nOpc,dDataLanc,cLote,cSubLote,cDoc,nTotInf)
			EndIf
			Return
	    EndIF
	EndIf
ElseIf _lAutomato  // Trecho exclusivo para automação. Verificar changeset 546866
	If l102Exclui .And. FwIsInCallStack("CTBA102") 
		Pergunte("CTB102",.F.)
		Ct102EstLt(nOpc,dDataLanc,cLote,cSubLote,cDoc,nTotInf)
		Return
	Endif  
Endif

If (l102Altera .Or. l102Inclui .Or. l102Estorno .Or. l102Copia .Or. l102Exclui)

	//Se for estorno de lançamento,pergunta se quer estornar por lote.
	If l102Estorno .And. FwIsInCallStack("CTBA102")
		If !_lAutomato
			If MsgNoYes(STR0070,STR0060)	//Atencao "Deseja realizar o estorno por lote?"
				If Pergunte("CTB102",.T.)
					dDataLanc := If(mv_par09==1,dDataLanc,mv_par10)
					cLote := If(Empty(mv_par11), cLote, mv_par11)
					cSubLote := If(Empty(mv_par12), cSubLote, mv_par12)
					cDoc := If(Empty(mv_par13), cDoc, mv_par13)
					If c102CapOk(dDataLanc,cLote,cSubLote,cDoc)  //se lote / sublote nao for informado avisa usuario e retorna
						Ct102EstLt(nOpc,dDataLanc,cLote,cSubLote,cDoc,nTotInf,lSeqCorr,cCodSeq)
					EndIf
				EndIf
				Return
			EndIf
		Else
			Pergunte("CTB102",.F.)
			Ct102EstLt(nOpc,dDataLanc,cLote,cSubLote,cDoc,nTotInf)
			Return
		EndIf
	Endif

	//-------------------------------------------------------------------
	// Se não for inclusão												-
	// Verifica se existe algum usuario concorrente						-
	//-------------------------------------------------------------------
	// As variaveis dDataLanc, cLote, cSubLote ,cDoc não são validadas 	-
	//  pois impactam em outros processos.								-
	//-------------------------------------------------------------------
	If !l102Inclui .AND. ( Type( 'lCt102Auto' ) == "U" .Or. !lCt102Auto )
		dDataLancX	:= dDataLanc
		cLoteX		:= CT2->CT2_LOTE
		cSubLoteX	:= CT2->CT2_SBLOTE
		cDocX		:= CT2->CT2_DOC
	EndIf

	If ! ( l102Inclui .Or. l102Copia ) .And. ! Ctb102Smlt( Dtos( dDataLancX	) + cLoteX + cSubLoteX + cDocX )
		Help("MULTCT2",1,"HELP","CTB102SLMLT",STR0095 ,1,0) //'Documento em uso por outro usuario!'
		RETURN
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela da capa do lote   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cProg == "CTBA101"
		cTitulo := OemToAnsi(STR0030)
	Else
		cTitulo := OemToAnsi(STR0007)
	EndIf

	If Type( 'lCt102Auto' ) == 'U' .or. ! lCt102Auto

  		If ! l102Exclui
			DEFINE MSDIALOG oDlg TITLE cTitulo FROM 33,25 TO If(lUseDocHis,320,260),If(lUseDocHis,569,369) PIXEL  //"Capa de Lote - Lan‡amentos Cont beis"

			@ 001,005 TO 032, 140 OF oDlg PIXEL
			@ 035,005 TO 066, 140 OF oDlg PIXEL

			@ 004,008 	SAY OemToAnsi(STR0008) SIZE 55, 7 OF oDlg PIXEL  //"Data Lan‡amento"
			@ 014,008 	MSGET oDataLanc VAR dDataLanc Picture "99/99/99" When lDigita Valid NaoVazio(dDataLanc) .And. ;
								CtbValiDt(nOpc,dDataLanc) .And.;
								If(Empty(cLote),C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,oLote,oSubLote,oDoc,@CTF_LOCK,nOpc,1),.T.) .And.;
								CtbMedias(dDataLanc) ;
								SIZE 50, 11 OF oDlg PIXEL HASBUTTON

			If lSeqCorr
				@ 004,068   SAY OemToAnsi("Cod. Diario") SIZE 37, 7 OF oDlg PIXEL
			   	@ 014,068   MSGET oCodSeq VAR cCodSeq Pict "!!" Valid VldCodSeq( cCodSeq );
				            F3 "CVL" SIZE 34, 11 OF oDlg PIXEL HASBUTTON When CtbWdia()
			Endif

			@ 038,008 	SAY OemToAnsi(STR0009) SIZE 18, 7 OF oDlg PIXEL  //"Lote"
			@ 048,008 	MSGET oLote VAR cLote Picture "@!" When lDigita ;
							Valid NaoVazio(cLote) .And.;
							C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK)  .And.;
							Ctb101Inf(dDataLanc,cLote,cSubLote,cDoc,oInf,@nTotInf,oInfLot,@nTotInfLot);
							SIZE 32, 11 OF oDlg PIXEL

			@ 038,041   SAY OemToAnsi(STR0028) SIZE 25, 7 OF oDlg PIXEL  //"Sub-Lote"
			@ 048,041   MSGET oSubLote VAR cSubLote Picture "!!!"  F3 "SB";
							WHEN lDigita .And. lSubLote;
							VALID NaoVazio(cSubLote) .And.;
								  C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK)  .And.;
								  Ctb101Inf(dDataLanc,cLote,cSubLote,cDoc,oInf,@nTotInf,oInfLot,@nTotInfLot);
							SIZE 20, 11 OF oDlg PIXEL

			@ 038,068   SAY OemToAnsi(STR0010) SIZE 34, 7 OF oDlg PIXEL //"Documento"
			@ 048,068   MSGET oDoc VAR cDoc Picture "999999" ;
								When lDigita;
								Valid NaoVazio(cDoc) .And.;
								Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,@CTF_LOCK,nOpc) .And.;
								Ctb101Inf(dDataLanc,cLote,cSubLote,cDoc,oInf,@nTotInf,oInfLot,@nTotInfLot);
								SIZE 34, 11 OF oDlg PIXEL

			If cProg != 'CTBA101'
				@ 038,104   SAY OemToAnsi(STR0011) SIZE 37, 7 OF oDlg PIXEL  //"Lcto Padr„o"
			   	@ 048,104   MSGET oPadrao VAR cPadrao Pict "!!!" Valid ValidaLP(cPadrao) .And. CapValLP( cPadrao ) .And. VldAtivLP(cPadrao) ;
				            F3 "CT5" SIZE 34, 11 OF oDlg PIXEL HASBUTTON When lDigita
			Endif

			@ 074,005 	SAY OemToAnsi(STR0034) SIZE 60, 7 OF oDlg PIXEL 	//"Total Informado Docto"
			@ 070,080 	MSGET oInf VAR nTotInf  Picture cPictVal;
			    			When (l102Inclui .Or. l102Altera .Or. l102Estorno .Or. l102Copia);
				    				SIZE 80, 11 OF oDlg PIXEL HASBUTTON

			@ 089,005 	SAY OemToAnsi(STR0025) SIZE 60, 7 OF oDlg PIXEL	//"Total Informado Lote"
			@ 085,080 	MSGET oInfLot VAR nTotInfLot Picture cPictVal;
			    			When .F. SIZE 80, 11 OF oDlg PIXEL HASBUTTON

			If lUseDocHis
				@ 105,005 	SAY OemToAnsi(STR0104) SIZE 60, 7 OF oDlg PIXEL	//"Historico"
				@ 115,005	MSGET oHistLote VAR cHistLote  SIZE 260, 020  OF oDlg PIXEL
			EndIf

			DEFINE SBUTTON FROM 05, 142 TYPE 1 ACTION (lContinua := .T.,;
								Iif(lDigita,Iif(Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK) .And.;
									Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK) .And.;
									Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK,nOpc) .And.;
									c102CapOk(dDataLanc,cLote,cSubLote,cDoc) .And.;
									VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc) .And.;
									CtbProxLin(dDataLanc,cLote,cSubLote,cDoc,@cLinha,@oLinha),;									
									oDlg:End(),lContinua := .F.),;
									Iif(VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc) .and. ;
									CtbVldLP(dDataLanc,cLote,cSubLote,cDoc,nOpc) .And.;
									CtbTmpBloq(dDataLanc,cLote,cSubLote,cDoc,nOpc,cProg) .and.;
									CtbValiDt(nOpc,dDataLanc),;
									oDlg:End(),lContinua := .F.))) ENABLE OF oDlg

			DEFINE SBUTTON FROM 19, 142 TYPE 2 ACTION (lContinua := .F.,oDlg:End()) ENABLE OF oDlg

			ACTIVATE MSDIALOg oDlg CENTERED

			If _lCt102VlEs
  				lContinua := ExecBlock("CT102VLES",.f.,.f.,{dDataLanc,cLote,cSubLote,cDoc })
			EndIf

		Else
			// caso for exclusão, passa direto sem a capa do lote
			lContinua := .T.
		Endif
	Else
		Private aValidGet 	:= {}

		nPosAut := Ascan(aAutoCab,{|x|Upper(Alltrim(x[1])) == "DDATALANC"})
		If nPosAut # 0
			dDataLanc	:= aAutoCab[nPosAut,2]
			Aadd(aValidGet,{"dDataLanc", aAutoCab[nPosAut,2],;
				"NaoVazio(dDataLanc) .And. CtbValiDt("+lTrim(Str(nOpc))+",dDataLanc)",.T.})
		EndIf

		nPosAut := Ascan(aAutoCab,{|x|Upper(Alltrim(x[1])) == "CLOTE"})
 		If nPosAut # 0
			Aadd(aValidGet,{"cLote", aAutoCab[nPosAut,2],"NaoVazio(cLote) ",.T.})
		EndIf

		nPosAut := Ascan(aAutoCab,{|x|Upper(Alltrim(x[1])) == "CSUBLOTE"})
		If nPosAut # 0
			Aadd(aValidGet,{"cSubLote", aAutoCab[nPosAut,2],"NaoVazio(cSubLote) ",.T.})
	    EndIf

		nPosAut := Ascan(aAutoCab,{|x|Upper(Alltrim(x[1])) == "CDOC"})
		If nPosAut # 0
			Aadd(aValidGet,{"cDoc", aAutoCab[nPosAut,2],"NaoVazio(cDoc)",.T.})
		EndIf

		nPosAut := Ascan(aAutoCab,{|x|Upper(Alltrim(x[1])) == "CPADRAO"})
		If nPosAut # 0
			cPadrao	:= aAutoCab[nPosAut,2]
			Aadd(aValidGet,{"cPadrao", aAutoCab[nPosAut,2],"ValidaLP(cPadrao) .And. CapValLP( cPadrao )",.T.})
		EndIf

		nPosAut := Ascan(aAutoCab,{|x|Upper(Alltrim(x[1])) == "CCODSEQ"})
		If nPosAut # 0
			cPadrao	:= aAutoCab[nPosAut,2]
			Aadd(aValidGet,{"cCodSeq", aAutoCab[nPosAut,2], "VldCodSeq( cCodSeq )",.T.})
		EndIf

		nPosAut := Ascan(aAutoCab,{|x|Upper(Alltrim(x[1])) == "NTOTINF"})
		If nPosAut # 0
			nTotInf	:= aAutoCab[nPosAut,2]
			Aadd(aValidGet,{"nTotInf", aAutoCab[nPosAut,2],".T.",.T.})
		EndIf

		nPosAut := Ascan(aAutoCab,{|x|Upper(Alltrim(x[1])) == "NTOTINFLOT"})
		If nPosAut # 0
			nTotInfLot := aAutoCab[nPosAut,2]
			Aadd(aValidGet,{"nTotInfLot", aAutoCab[nPosAut,2],".T.",.T.})
		EndIf
		If funName() == "PROJETOGESPLAN"
			nPosAut := Ascan(aAutoItens[1],{|x|Upper(Alltrim(x[1])) == "CT2_KEY"})
			If nPosAut # 0
				_cT2key := aAutoItens[1,nPosAut,2]
			EndIf
			nPosAut := Ascan(aAutoItens[1],{|x|Upper(Alltrim(x[1])) == "CT2_ROTINA"})
			If nPosAut # 0
				_cProg := aAutoItens[1,nPosAut,2]
			EndIf
		EndIf

		If CT2->(MsVldGAuto(aValidGet)) // Consiste os gets
			cLote 	 := Padr(cLote	  , TamSx3("CT2_LOTE"  )[1])//correcao do tamanho do campos.
			cSubLote := Padr(cSublote , TamSx3("CT2_SBLOTE")[1])
			cDoc	 := Padr(cDoc	  , TamSx3("CT2_DOC"   )[1])

			If nOpc == 3
				If Empty(cLote)
					C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,oLote,oSubLote,oDoc,@CTF_LOCK,nOpc,1)
				Endif

				CtbMedias(dDataLanc)

			    If Empty( cLote ) .or. Empty( cSubLote ) .or. Empty( cDoc )   // verifico se alguma informação do lote não foi informado.
					C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK)
				Endif
			EndIf
		//  If Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,@CTF_LOCK,nOpc)
			If Ctb101Doc(dDataLanc,cLote,@cSubLote,@cDoc,oDoc,@CTF_LOCK,nOpc,@oLote,@oSubLote)
				If lDigita
					If (Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK) .And.;
						Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK) .And.;
						Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK,nOpc) .And.;
						c102CapOk(dDataLanc,cLote,cSubLote,cDoc) .And.;
						VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc).And.;
						CtbProxLin(dDataLanc,cLote,cSubLote,cDoc,@cLinha,))

						lContinua := .T.

					EndIf

				Else
					If (VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc) .and. ;
					CtbVldLP(dDataLanc,cLote,cSubLote,cDoc,nOpc) .And.;
					CtbValiDt(nOpc,dDataLanc))

						lContinua := .T.

					EndIf
				EndIf
			Else
				lContinua := .F.
			EndIf
		Else
			lContinua := .F.
		EndIf
	EndIf
Else
	lContinua := .T.
EndIf

If !lContinua
	aAreaCTF := getArea()
	dbSelectArea("CTF")
	dbSetOrder(1)
	
	// Consecutivo por mes, aplica solo para CTF
	If cPaisLoc == "MEX"
		dDataCTF := StoD( Substr(DtoS(dDataLanc), 1, 6) + "01" )

		If msSeek(xFilial("CTF")+Dtos(dDataCTF)+cLote+cSubLote+cDoc)
			CtbDestrava(CTF->CTF_DATA,CTF->CTF_LOTE,CTF->CTF_SBLOTE,CTF->CTF_DOC,CTF->(recno()))
		EndIf
	Else
		If msSeek(xFilial("CTF")+Dtos(dDataLanc)+cLote+cSubLote+cDoc)
			CtbDestrava(CTF->CTF_DATA,CTF->CTF_LOTE,CTF->CTF_SBLOTE,CTF->CTF_DOC,CTF->(recno()))
		EndIf
	EndIf
	RestARea(aAreaCTF)
EndIf

If lContinua
	RestArea(aAreaCT2)
	If cProg == 'CTBA102'
		lOk := Ctba102Lan(nOpc,dDataLanc,cLote,cSubLote,cDoc,cAlias,nReg,@CTF_LOCK,;
				   cPadrao,nTotInf,cCodSeq,STRTRAN(cHistLote, chr(13)+chr(10), " "))
	Elseif cProg == 'CTBA101'
		Ctba101Lan(cAlias,nReg,nOpc,dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK,;
				   cPadrao,@cLinha,oLinha,oInf,nTotInf,cCodSeq,STRTRAN(cHistLote, chr(13)+chr(10), " "))
		lOk := .T.
	Endif
	If lOk .And. nOpc == 5 .And. _lNewSemaf .And. FindFunction("CtSetRcCTF") //CONFIRMADO EXCLUSAO
		CtSetRcCTF(.T.)  //QUANDO EXCLUIR SETA PARA UNLOCKDOC COLOCAR CAMPO CTF_USADO = 'R' --> PODE SER RECUPERADO ESTE NUMERO
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua //Destrava a CTF
	aAreaCTF := getArea()
	dbSelectArea("CTF")
	dbSetOrder(1)
	If CTF->(msSeek(xFilial("CTF")+Dtos(dDataLanc)+cLote+cSubLote+cDoc))
		CtbDestrava(CTF->CTF_DATA,CTF->CTF_LOTE,CTF->CTF_SBLOTE,CTF->CTF_DOC,CTF->(recno()),/*lSimula*/,/*cTabCTK*/,/*cTabCT2*/,.F.)
	Endif
	RestARea(aAreaCTF)
Endif

MsUnLockAll()

IF ! ( l102Inclui .Or. l102Copia ) 
	Ct102SmltF( Dtos( dDataLanc	) + cLote + cSubLote + cDoc  ) // libera o documento para que o proximo possa usar
ENDIF

FreeUsedCode()

If l102Altera .Or. l102Visual
	RestArea(aAreaCT2)
EndIf

If l102Inclui .And. lContinua
	dbSelectArea("CT2")
	dbSetOrder(1)
	dbGoTop()
	MsSeek( xFilial( "CT2" ) + Dtos(dDataLanc) + cLote + cSubLote + cDoc )
EndIf

/*
 * Integração via Mensagem Única
 */
If lContinua .AND. FWHasEAI("CTBA102",.T.,,.T.) .AND. (Type("lCt102Auto") <> "U" .AND. !lCt102Auto)
	If nOpc == 3 .OR. nOpc == 4 .OR. nOpc == 5 .OR. nOpc == 7
		//Prepara o XML de envio da mensagem única, quebrando para não deixar passar de 900 lançamentos por mensagem
		CT102EAI( dDataLanc, cLote, cSubLote, cDoc,,,nOpc )

		//limpa arquivo temporario para quando voltar para outro documento 
		dbSelectArea( "TMP" )
		If Alias() == "TMP"
			Ctb_ZapTmp() //Zap
		EndIf
		TMP->( dbGotop() )

		dbSelectArea( "CT2" )

	Endif
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA102Lan³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta tela de lancamento contabil                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba102Lan(nOpc,dDatalanc,cLote,cSubLote,cDoc,cAlias,nReg, ³±±
±±³          ³ CTF_LOCK,cPadrao,nTotInf)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da opcao escolhida                          ³±±
±±³          ³ ExpD1 = Data do Lancamento                                 ³±±
±±³          ³ ExpC1 = Numero do Lote                                     ³±±
±±³          ³ ExpC2 = Numero do Sub-Lote                                 ³±±
±±³          ³ ExpC3 = Numero do Documento                                ³±±
±±³          ³ ExpC4 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN5 = Numero do registro                                 ³±±
±±³          ³ ExpN6 = Semaforo para proximo documento                    ³±±
±±³          ³ ExpC7 = Codigo do lancamento padrao                        ³±±
±±³          ³ ExpN8 = Valor Total infomrado                              ³±±
±±³          ³ ExpC9 = Codigo da sequencia do correlativo                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba102Lan(nOpc,dDataLanc,cLote,cSubLote,cDoc,cAlias,nReg,CTF_LOCK,cPadrao,nTotInf,cCodSeq,cHistLote)

Local aCampos		:= {}
Local aAltera		:= {}
Local aTotais 		:= {{0,0,0,0},{0,0,0,0}}
Local aButton		:= {}
Local cArq1
Local cArq2
Local lDel 	  		:= .F.
Local nOpcGDB		:= nOpc	//Variavel para carregar a GetDB
Local oDlg,oInf,oFnt,oHistLote
Local cExpFil		:= ""
Local cTxtfil		:= ""
Local cLinhaAlt := StrZero( 1,Len(CT2->CT2_LINHA) ) //"001"
Local l102Inclui	:= .F.
Local l102Visual	:= .F.
Local l102Altera	:= .F.
Local l102Exclui	:= .F.
Local l102Estorno	:= .F.
Local l102Copia		:= .F.
Local lContinua		:= .T.
Local aButBrowse	:= {}
Local aValDif		:= {}
Local lOk 			:= .F.
Local nX  			:= 0
Local lSeqCorr 		:= .F.
Local cSeqCorr 		:= Space(10)
Local aAreaCTF		:= {}
Local oSize
Local nCtr1stRow
Local nLbl1st1
Local nCmp1st1
Local nLbl1st2
Local nCmp1st2

Local nCtr3rdRow
Local nLbl3rd1
Local nCmp3rd1
Local nLbl3rd2
Local nCmp3rd2
Local nLbl3rd3
Local nCmp3rd3
Local cPreLcto := ""
local nIndLinCpo as numeric
local nIndLinHea as numeric
local dDataCTF := dDataLanc
Local lMsgUnq	:= IsInCallStack("CTBI102")         

Default cHistLote	:= ""
Private oDescEnt,oDig,oDeb,oCred,oGetDB
Private OPCAO

Private aHeader		:= {}
Private aColsP		:= {}
Private __aCT2LC	:= {}

lSeqCorr := UsaSeqCor("CT2/CTK/CT5") // Controle do Correlativo

IF lSeqCorr
	If (nOpc == 3 .Or. nOpc == 7 .or. nOpc == 6)
		cSeqCorr := CTBSQCor( "" , cCodSeq, dDataLanc )
	Else
		cSeqCorr := CT2->CT2_SEGOFI
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nOpc == 2
		l102Visual := .T.
	Case nOpc == 3
		l102Inclui	:= .T.
		nOpcGDB := 4
		lDel := .T.
	Case nOpc ==  4
		l102Altera	:= .T.
		lDel := .T.
	Case nOpc ==  5
		l102Exclui	:= .T.
		l102Visual	:= .T.
	Case nOpc == 6
		l102Estorno := .T.

		If SuperGetMV('MV_CTBDEST', .F., '2') == '2'
			nOpcGDB := 2
			lDel := .F.
   		Else
			nOpcGDB := 4
			lDel := .T.
		EndIf
	Case nOpc == 7
		l102Copia := .T.
		nOpcGDB := 4
		lDel := .T.
EndCase

If FwIsInCallStack("CTBA350")
	//Quando vier do CTBA350-Efetivacao Pre-Lancto - devera forcar a criacao do TMP pois na rotina CTBA350 tb trabalha com TMP (abre CT2 com alias TMP)
	Eval({|| If( Select("TMP") > 0, ( TMP->(dbCloseArea()) ), NIL ) } )
	_lForcHead := .T.
	_lForcCrTmp := .T.
EndIf

If _lForcCrTmp
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Getdados para Lan‡amentos Cont beis                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCampos := Ctb105Head(@aAltera,/*lSimula*/, _lForcHead )
	_aHeadCtb := aClone( aHeader )  //carrega variavel static com clone de aHeader
	_aAltera  := aClone( aAltera )  //carrega variavel stati com clone a aAltera
	Ctb105Cria(aCampos,@cArq1,@cArq2, _lForcCrTmp )
	_aCampos := aClone( aCampos )   //carrega variavel static com clone de aCampos
	Ctb105STmp()                             //FUNCAO CTBA105 PARA SETAR ALIAS TMP
	_lForcHead := .F.
	_lForcCrTmp := .F.
Else
	//carrega as variaveis locais/private com conteudo das variaveis static
	aCampos := aClone( _aCampos )  //esta variavel eh retorno da funcao Ctb105Cria
	aAltera := aClone( _aAltera )  //esta variavel é utilizada  na MSGETDB 
	aHeader := aClone( _aHeadCtb ) //variavel aHeader é utilizada internamente na MSGETDB                              
EndIf

If l102Inclui .And. !Empty(cPadrao)
	CtbEnche(cPadrao,.T.)
Else
	lContinua := Ctb102Carr(nOpc,@dDataLanc,cLote,cSubLote,cDoc,@cLinhaAlt,FunName(),cCodSeq)
EndIf

//-- JRJ 20171114.A Inicio
If Type( 'lCt102Auto' ) == "U"
	lCt102Auto := .F.
EndIf
//-- JRJ 20171114.A Fim

If FwIsInCallStack("CTBA350") .Or. lCt102Auto 		// Se for Efetivacao
	Private __PreLan := .F.							// Ao passar pela CT105TOk(), pode alterar seu conteudo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem dos botoes da barra de ferramentas                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aButton, {"RECALC"   , { || MsAguarde({|| CtRecRdPe()},STR0090) },STR0091 } )//"Recalculando totais..."#"Rec.Totais"
Aadd( aButton, {"SIMULACAO",{ || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc)}, STR0041+" - <F5>", STR0015	} ) //"Totais do lote e documento (outras moedas)"	"Totais"
Aadd( aButton, {"PREV"     ,{ || CTB105Flt (oGetDb,.F.                   )}, STR0047 ,STR0052                    	} ) //"Inconsistencia Anterior" //"Anterior"
Aadd( aButton, {"NEXT"     ,{ || CTB105Flt (oGetDb,.T.                   )}, STR0048 	,STR0053					} ) //"Proxima Inconsistencia" //"Próxima"

If l102Visual .Or. l102Exclui
	Aadd( aButton, {"CTBLANC"   ,{ || Ctb102Lcto()}, STR0054	,STR0055 } ) //"Detalhes do lançamento posicionado"###"Detalhes"
EndIf

If _lUsarCTC == Nil
	_lUsarCTC := .F.
EndIf

If l102Visual .And. _lUsarCTC 
	Aadd( aButton, {"RASTREA"   ,{ || CtbC010Rot("CT2", CT2->(Recno()), 8)}, STR0046	, STR0046 } ) //"Detalhes do lançamento posicionado"###"Detalhes"
EndIf

If l102Inclui .Or. l102Altera .Or. l102Copia
	Aadd( aButton, {"CTBREPLA"   ,{ || Ctb102Repla()}, STR0056 ,STR0057		} ) //"Replicar o conteudo do campo posicionado"###"Replicar"
EndIf

aButton := AddToExcel(aButton,{	{"ARRAY",STR0058,{STR0008,STR0009,STR0028,STR0010},{{dDataLanc,cLote,cSubLote,cDoc}}},{"GETDB",STR0059,aHeader,"TMP"} } ) //"Documento"###"Lançamentos"
Aadd( aButton, {"PESQUISA"   ,{ || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil     )}, STR0049 						} ) //"Localizar"

//Ponto de entrada ´para inclusao de botao
IF _lCT102BTO
	aButBrowse := ExecBlock("CT102BTO",.F.,.F.,{aButton})

	IF ValType(aButBrowse) == "A" .AND. Len(aButBrowse) > 0
		FOR nX := 1 to len(aButBrowse)
			aAdd(aButton,aButBrowse[nX])
		NEXT
	ENDIF
ENDIF

If lContinua
	If Type( 'lCt102Auto' ) == 'U' .or. ! lCt102Auto

		SetKey(VK_F4,{ || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc) })
		SetKey(VK_F5,{ || CTB105Flt (oGetDb,.F.                   ) })
		SetKey(VK_F6,{ || CTB105Flt (oGetDb,.T.                   ) })
		SetKey(VK_F7,{ || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil     ) })

		//Faz o calculo automatico de dimensoes de objetos
		oSize := FwDefSize():New(.T.)

		oSize:lLateral := .F.
		oSize:lProp	:= .T. // Proporcional

		oSize:AddObject( "1STROW" ,  100, 08, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "2NDROW" ,  100, 78, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "3RDROW" ,  100, 14, .T., .T. ) // Totalmente dimensionavel

		oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

		oSize:Process() // Dispara os calculos

		a1stRow :=	{	oSize:GetDimension("1STROW","LININI"),;
						oSize:GetDimension("1STROW","COLINI"),;
						oSize:GetDimension("1STROW","LINEND"),;
						oSize:GetDimension("1STROW","COLEND")}

		a2ndRow := {	oSize:GetDimension("2NDROW","LININI"),;
						oSize:GetDimension("2NDROW","COLINI"),;
						oSize:GetDimension("2NDROW","LINEND"),;
						oSize:GetDimension("2NDROW","COLEND")}

		a3rdRow := {	oSize:GetDimension("3RDROW","LININI"),;
						oSize:GetDimension("3RDROW","COLINI"),;
						oSize:GetDimension("3RDROW","LINEND"),;
						oSize:GetDimension("3RDROW","COLEND")}


		//calculo o centro objeto
		nCtr1stRow := a1stRow[1] + ((a1stRow[3] - a1stRow[1]) / 2)
		nCtr3rdRow := a3rdRow[1] + ((a3rdRow[3] - a3rdRow[1]) / 2)

		//defino as coordenadas das labels e dos campos.
		nLbl3rd1	:= nCtr3rdRow - 18
		nCmp3rd1	:= nCtr3rdRow - 20
		nLbl3rd2	:= nCtr3rdRow - 4
		nCmp3rd2	:= nCtr3rdRow - 6
		nLbl3rd3	:= nCtr3rdRow + 10
		nCmp3rd3	:= nCtr3rdRow + 8

		If lSeqCorr .OR. cPaisLoc == "ARG"
			nLbl1st1 := a1stRow[1] + 6
			nCmp1st1 := a1stRow[1] + 3
			nLbl1st2 := nCtr1stRow + 6
			nCmp1st2 := nCtr1stRow + 3
		Else
			nLbl1st1 := nCtr1stRow - 3
			nCmp1st1 := nCtr1stRow - 6
		EndIf

  If !IsBlind()
		DEFINE MSDIALOG oDlg TITLE cCadastro From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
		oDlg:lMaximized := .T.

		DEFINE FONT oFnt NAME "Arial" SIZE 0, -11 BOLD

		@ nLbl1st1, a1stRow[2] + 000 Say OemToAnsi(STR0008) SIZE 30,9 PIXEl OF oDlg FONT oFnt				//"Data"
		@ nCmp1st1, a1stRow[2] + 023 MSGET dDataLanc Picture "99/99/9999" WHEN .F. PIXEl	SIZE 45,10 OF oDlg HASBUTTON

		@ nLbl1st1, a1stRow[2] + 083 Say OemToAnsi(STR0009) SIZE 30,9 PIXEl OF oDlg FONT oFnt				//"Lote"
		@ nCmp1st1, a1stRow[2] + 101	MSGET oLote VAR cLote Picture "@!" WHEN .F. PIXEl SIZE 32, 10 OF oDlg

	  	@ nLbl1st1, a1stRow[2] + 142 Say OemToAnsi(STR0028) SIZE 40,9 PIXEl OF oDlg FONT oFnt				//"Sub-Lote"
		@ nCmp1st1, a1stRow[2] + 172	MSGET cSubLote Picture "!!!" WHEN .F. PIXEl SIZE 24, 10 OF oDlg

	  	@ nLbl1st1, a1stRow[2] + 212	Say OemToAnsi(STR0010) SIZE 30,9 PIXEl OF oDlg	FONT oFnt			//"Docto"
	  	@ nCmp1st1, a1stRow[2] + 234	MSGET cDoc Picture "999999" WHEN .F. PIXEl SIZE 34, 10 OF oDlg

		If lSeqCorr
	  		@ nLbl1st1, a1stRow[2] + 284	Say OemToAnsi(STR0035) PIXEl OF oDlg SIZE 50,9 FONT oFnt	//"Correlativo"
	 		@ nCmp1st1, a1stRow[2] + 318	MSGET cSeqCorr Picture PesqPict("CT2","CT2_NODIA") WHEN .F. PIXEl SIZE 80, 10 OF oDlg
		EndIf

		If cPaisLoc == "ARG" //Tratamento para o historico na capa do lote
			@ nLbl1st1, a1stRow[2] + If(lSeqCorr,414,284) Say OemToAnsi(STR0033) PIXEl	OF oDlg SIZE 55,9 FONT oFnt	//"Historico"
			@ nCmp1st1, a1stRow[2] + If(lSeqCorr,443,318) MSGET oHistLote VAR cHistLote Picture "@!"  WHEN .F. PIXEL SIZE 260, 10 OF oDlg
		EndIf

		TMP->(dbSetOrder(0))

		Ctb102TamHist()

		OPCAO := nOpc		// variavel para ser usado na LinOk

		nDbRecTMP := TMP->( RECNO() )  // guardo o recno para tratamento da getDB

		oGetDB := MSGetDB():New( a2ndRow[1], a2ndRow[2], a2ndRow[3], a2ndRow[4], nOpcGDB, "CT105LINOK() .AND. VldVlrLanc(.F.)", "CT105TOk() .AND. VldVlrLanc(.T.)", "+CT2_LINHA",lDel,aAltera,,.t., SuperGetMv("MV_NUMMAN"),"TMP","CTBA102Mod()",,,oDlg,,,"CT102DEL")
		
		If cPaisLoc=="RUS"
			// If aHeader dont contain unused fields, the increment position
			// must be according to the temporary alias structure for a proper
			// unique index search
			nIndLinCpo	:= AScan(aCampos, {|x| PADR(x[1], 10) == "CT2_LINHA "})
			nIndLinHea	:= AScan(aHeader, {|x| PADR(x[2], 10) == "CT2_LINHA "})
			If nIndLinCpo <> nIndLinHea
				oGetDB:aInicPos[1][2]	:= nIndLinCpo //CT2_LINHA
			EndIf
		EndIf
		
		Ctb102TamHist(.T.)

		// restauro o posicionamento da getDb
		IF nDbRecTMP <> TMP->( RECNO() )
			TMP->(DbGoTo(nDbRecTMP))
		ENDIF

		aTotais := CtbTotMov()

		aTotRdpe[1][2] := aTotais[1][2] //Valor debito
		aTotRdpe[1][3] := aTotais[1][3] //Valor credito
		aTotRdpe[1][1] := aTotais[1][1] //Valor digitado

		IF FwIsInCallStack("CTBA350")
			cPictVal := Iif( cPictVal == NIL, PesqPict("CT2","CT2_VALOR"), cPictVal )
		EndiF

		@ nLbl3rd1, a3rdRow[2] + 008 SAY OemToAnsi(STR0026)	Of oDlg PIXEL FONT oFnt //"Descri‡„o da Entidade"
		@ nCmp3rd1, a3rdRow[2] + 073 SAY oDescEnt PROMPT space(50) FONT oDlg:oFont PIXEL COLOR CLR_HBLUE Of oDlg

	   	@ nLbl3rd2, a3rdRow[2] + 008 SAY OemToAnsi(STR0021) Of oDlg PIXEL FONT oFnt //"Total Informado :"
	   	@ nLbl3rd3, a3rdRow[2] + 008 SAY OemToAnsi(STR0022) Of oDlg PIXEL FONT oFnt //"Total Digitado  :"
	   	@ nCmp3rd2, a3rdRow[2] + 065 MSGET oInf VAR nTotInf Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL
	   	@ nCmp3rd3, a3rdRow[2] + 065 MSGET oDig VAR aTotRdpe[1][1] Picture cPictVal Of oDlg READONLY SIZE 95,9 PIXEL

	   	@ nLbl3rd2, a3rdRow[2] + 190 SAY OemToAnsi(STR0023) Of oDlg PIXEL FONT oFnt //"Total Debito  :"
	   	@ nLbl3rd3, a3rdRow[2] + 190 SAY OemToAnsi(STR0024) Of oDlg PIXEL FONT oFnt //"Total Credito :"
	   	@ nCmp3rd2, a3rdRow[2] + 240 MSGET oDeb VAR aTotRdPe[1][2] Picture cPictVal Of oDlg READONLY SIZE 95,9 PIXEL
	   	@ nCmp3rd3, a3rdRow[2] + 240 MSGET oCred VAR aTotRdPe[1][3] Picture cPictVal Of oDlg READONLY SIZE 95,9 PIXEL

		//Ponto de entrada para usuario
		If _lCT102DLG
			Execblock("CT102DLG",.f.,.f.)
		Endif

		ACTIVATE MSDIALOG oDlg ON INIT (oGetDB:oBrowse:Refresh(),;
										EnchoiceBar(oDlg,{|| If(VldVlrLanc(.T.) .And. VldBloqEnt(.T.) .AND. Ct105TOK(_lCT105TOK,_lCT105CHK,oGetDB:lModified,,aTotRdpe,nTotInf,,,@aValDif),;
										(lOk := .T.,oDlg:End()),;
										lOk := .F.;
										);
										};
										,{||lOk := .F.,oDlg:End()};
										,,aButton;
										);
										)

		SET KEY VK_F4 to
		SET KEY VK_F5 to
		SET KEY VK_F6 to
		SET KEY VK_F7 to
	 Else
	   lOk := .T.
	 Endif		
   Else
		aTotais	:= Ctb050Tot(dDataLanc,cLote,cSubLote,cDoc)

		If l102Inclui .Or. l102Altera
			nOpcGDB	:= nOpc
			
			If nOpcGDB = 4 .And. IsInCallStack("CTBI102")  //integracao via msg unica em modo de alteracao
				Ctb102_Del()			
			EndIf 
			lOk	:= MsGetDBAuto(	"TMP" , aAutoItens , "CT105LINOK() .AND. VldVlrLanc(.F.)" ,	{|| CT105TOk(,,,.F.) .AND. VldVlrLanc(.T.) } , aAutoCab , nOpcGDB )
			
			If nOpcGDB = 4 .And. IsInCallStack("CTBI102") .And. !lOk //integracao via msg unica em modo de alteracao E FALHOU MSGETDBAUTO
				Ctb102_Rec()			
			EndIf 
			
		ElseIf l102Exclui .OR. l102Estorno
			lOk := TMP->(RecCount()) > 0
		EndIf
	EndIf

	If FwIsInCallStack("CTBA350")	// Se for Efetivacao
		If lOk .And. __PreLan		// Se for Pre-Lan, significa que nao corrigiu o lancamento, portanto, nao gravar
			lOk := .F.
		EndIf
	EndIf
	// RESTAURA O NRO DO DOCUMENTO CASO ABAnDONE A ROTINA
	If !lOk
		aAreaCTF := getArea()
		dbSelectArea("CTF")
		dbSetOrder(1)

		// Consecutivo por mes, aplica solo para CTF
		If cPaisLoc == "MEX"
			dDataCTF := StoD( Substr(DtoS(dDataLanc), 1, 6) + "01" )	

			If msSeek(xFilial("CTF")+Dtos(dDataCTF)+cLote+cSubLote+cDoc)
				CtbDestrava(CTF->CTF_DATA,CTF->CTF_LOTE,CTF->CTF_SBLOTE,CTF->CTF_DOC,CTF->(recno()))
			EndIf							
		Else
			If msSeek(xFilial("CTF")+Dtos(dDataLanc)+cLote+cSubLote+cDoc)
				CtbDestrava(CTF->CTF_DATA,CTF->CTF_LOTE,CTF->CTF_SBLOTE,CTF->CTF_DOC,CTF->(recno()))
			EndIf
		EndIf
		RestARea(aAreaCTF)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a gravação dos lançamentos                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOk .And. (l102Inclui .Or. l102Altera .Or. l102Exclui .Or. l102Estorno .Or. l102Copia)
		If l102Exclui .And. _lCTB102EXC
			lOk := ExecBlock("CTB102EXC",.F.,.F.)
		EndIf

		If lOk .AND. l102Exclui
			lOk := VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc)
		EndIf

		If lOk
			If _lANCTB102GR
				ExecBlock("ANCTB102GR",.F.,.F.,{ nOpc,dDataLanc,cLote,cSubLote,cDoc }  )
			Endif

			CtbChkDif(aValDif)
			
			If lCt102Auto

				cPreLcto := C102AutoPreLan()

			EndIf

			CTBGrava(nOpc,dDataLanc,cLote,cSubLote,cDoc,.F.,"",__lCusto,__lItem,__lCLVL,nTotInf,_cProg,If(lCt102Auto,cPreLcto,),,cEmpAnt,cFilAnt,,,,,,,cSeqCorr,,,,STRTRAN(cHistLote, chr(13)+chr(10), " "),,,,,,,,,,,_cT2key)

			If _lDPCTB102GR
				ExecBlock("DPCTB102GR",.F.,.F.,{ nOpc,dDatalanc,cLote,cSubLote,cDoc } )
			Endif
		EndIf
	Endif
EndIf

dbSelectArea( "TMP" )
TMP->( dbGotop() )

IF ! Eof() .Or. ! Bof()
	//Reposiciono o registro no ct2
	dbSelectArea( "CT2" )
	CT2->( DbGoTo( TMP->CT2_RECNO ) )
Endif

If !lMsgUnq
	//limpa arquivo temporario para quando voltar para outro documento 
	dbSelectArea( "TMP" )
	If Alias() == "TMP"
		Ctb_ZapTmp() //Zap
	EndIf
	TMP->( dbGotop() )

	dbSelectArea( "CT2" )
EndIf

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lancamento de complementar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If CTBLCUso()
	If (Type("__aCT2LC") == "A") .And. !Empty(__aCT2LC)
		CTBLCGerLC()
	Endif
Endif

Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB102Carr³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega arq. temporario com dados para MSGETDB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB102Carr(nOpc,dDataLanc,cLote,cSubLote,cDoc)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  ExpN1 = Numero da opcao escolhida                         ³±±
±±³          ³  ExpD1 = Data do lancamento                                ³±±
±±³          ³  ExpC1 = Numero do Lote  	                                ³±±
±±³          ³  ExpC2 = Numero do Sub-Lote 	                             ³±±
±±³          ³  ExpC3 = Numero do Documento		                          ³±±
±±³          ³  ExpC4 = Numero da Linha    		                          ³±±
±±³          ³  ExpC5 = Nome da Rotina que esta executando     		     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB102Carr(nOpc,dLanc,cPLote,cPSubLote,cPDoc,cLinhaAlt,cProg,cCodSeq)
Local aSaveArea	 := GetArea()
Local aAreaCT2	 := CT2->(GetArea())
Local cAlias	 := "CT2"
Local cCritConv	 := ""
Local nPos
Local cMoeda
Local nVezes	 := 1
Local nC		 := 0
Local nTamCrit	 := Len(CriaVar("CT2_CONVER"))
Local nCont
Local lContinua	 := .T.
Local dDataLanc  := dLanc
Local cLote 	 := cPLote
Local cSubLote	 := cPSubLote
Local cDoc		 := cPDoc
Local cFilialCT2
Local cAuxEnt
Local cCpoDB
Local cCpoCR
Local nRecnoCT2	 := CT2->( Recno() )
Local lSeqCorr   := .F.
Local cSeqCorr 	 := Space(10)

DEFAULT cCodSeq	 := ''
DEFAULT cLinhaAlt:= StrZero( 1, Len(CT2->CT2_LINHA) )  //"001"
DEFAULT cProg	 := ""

lSeqCorr := UsaSeqCor("CT2/CTK/CT5")// Controle do Correlativo

If Type( 'aFiltro' ) == "U"
	aFiltro := {}
EndIf

If nOpc <> 3						// Visualizacao / Alteracao / Exclusao
	If nOpc == 6 .Or. nOpc == 7 // Estorno/Copia  - Pega as informações do registro posicionado CT2
		dDataLanc 	:= CT2->CT2_DATA
		cLote 	 	:= CT2->CT2_LOTE
		cSubLote	:= CT2->CT2_SBLOTE
		cDoc		:= CT2->CT2_DOC
	EndIf

	dbSelectArea("CT2")
	dbSetOrder(1)

	If !FwIsInCallStack("Ctba102Cop")
		cFilialCT2 := xFilial( "CT2" )
	Else
		cFilialCT2 := cGuarFil
	EndIf

	cLinhaAlt := FieldGet(FieldPos("CT2_LINHA"))

	If MsSeek( cFilialCT2 + Dtos(dDataLanc) + cLote + cSubLote + cDoc )

		If lSeqCorr
			If Empty( cCodSeq )
				cCodSeq	:= CtbRdia()
			EndIf

			If (nOpc == 3 .Or. nOpc == 7 .Or. nOpc == 6)
				cSeqCorr := CTBSQCor( "" ,cCodSeq, dDataLanc )
			Else
				cSeqCorr := CT2->CT2_SEGOFI
			Endif
		EndIf

		While ! Eof() .And. lContinua .And. ;
				CT2->CT2_FILIAL == cFilialCT2 	.And.;
				CT2->CT2_DATA 	== dDataLanc	.And.;
				CT2->CT2_LOTE	== cLote 		.And.;
				CT2->CT2_SBLOTE == cSubLote 	.And.;
				CT2->CT2_DOC 	== cDoc

			//So ira mostrar na Getdb os lancamentos da moeda 01
			If cPaisLoc <> "BOL"
				If CT2->CT2_MOEDLC <> '01'
					dbSkip()
					Loop
				EndIf
			EndIf

			//Se for estorno de lancamento, nao sera considerado os historicos complementares.
			If nOpc == 6 .And. CT2->CT2_DC == "4"
				dbSkip()
				Loop
			EndIf

			dbSelectArea("TMP")
			dbAppend()

			For nCont := 1 To Len(aHeader)
				nPos := FieldPos(aHeader[nCont][2])

				If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
					FieldPut(nPos,(cAlias)->(FieldGet(FieldPos(aHeader[nCont][2]))))
				EndIf
			Next nCont

			TMP->CT2_FILIAL		:= CT2->CT2_FILIAL
			TMP->CT2_DATA		:= CT2->CT2_DATA
			TMP->CT2_LOTE		:= CT2->CT2_LOTE
			TMP->CT2_SBLOTE		:= CT2->CT2_SBLOTE
			TMP->CT2_DOC		:= CT2->CT2_DOC
			TMP->CT2_LINHA		:= CT2->CT2_LINHA
			TMP->CT2_TPSALD		:= CT2->CT2_TPSALD
			TMP->CT2_MOEDLC		:= CT2->CT2_MOEDLC
			TMP->CT2_FLAG 		:= .F.
			TMP->CT2_SEQLAN		:= CT2->CT2_SEQLAN
			TMP->CT2_SEQHIS		:= CT2->CT2_SEQHIS
			TMP->CT2_EMPORI		:= CT2->CT2_EMPORI
			TMP->CT2_FILORI		:= IIf(nOpc==7,cFilAnt,CT2->CT2_FILORI)
			TMP->CT2_KEY		:= CT2->CT2_KEY
			TMP->CT2_RECNO		:= CT2->(Recno())
			cCritConv			:= CT2->CT2_CRCONV
			cMoeda				:= CT2->CT2_MOEDLC
			TMP->CT2_ALI_WT 	:= "CT2"
			TMP->CT2_REC_WT 	:= If(nOpc==7,0,CT2->(Recno()))
			TMP->CT2_HIST		:= CT2->CT2_HIST																	

			If nOpc == 6 // Estorno de Lançamentos
				If CT2->CT2_DC == "1"	// Debito eh trocado pelo credito e vice-versa
					TMP->CT2_DC	:= "2"
				ElseIf CT2->CT2_DC == "2"
					TMP->CT2_DC	:= "1"
				Else
					TMP->CT2_DC	:= "3"
				EndIf
				TMP->CT2_CREDIT	:= CT2->CT2_DEBITO
				TMP->CT2_DEBITO	:= CT2->CT2_CREDIT
				TMP->CT2_CCC	:= CT2->CT2_CCD
				TMP->CT2_CCD	:= CT2->CT2_CCC
				TMP->CT2_ITEMC	:= CT2->CT2_ITEMD
				TMP->CT2_ITEMD	:= CT2->CT2_ITEMC
				TMP->CT2_CLVLCR	:= CT2->CT2_CLVLDB
				TMP->CT2_CLVLDB	:= CT2->CT2_CLVLCR
				TMP->CT2_ATIVCR	:= CT2->CT2_ATIVDE
				TMP->CT2_ATIVDE	:= CT2->CT2_ATIVCR
				TMP->CT2_HIST	:= OemToAnsi( STR0105 )+ " " + DTOC(CT2->CT2_DATA) + " " + CT2->CT2_LOTE+" "+CT2->CT2_SBLOTE+" "+CT2->CT2_DOC+" "+CT2->CT2_LINHA

				If CtbUso( "CT2_DCD" ) .OR. CtbUso( "CT2_DCC" )		//  Digito de Controle
					TMP->CT2_DCC	:= CT2->CT2_DCD
					TMP->CT2_DCD	:= CT2->CT2_DCC
				EndIf

				/* atividades */
				For nC := 1 To 9
					cCpoDB := "CT2_AT" + StrZero(nC,2) + "DB"
					cCpoCR := "CT2_AT" + StrZero(nC,2) + "CR"
					If CT2->(FieldPos(cCpoDB)) > 0 .And. CT2->(FieldPos(cCpoCR)) > 0
						&("TMP->"+cCpoDB )  := &("CT2->"+cCpoCR )
						&("TMP->"+cCpoCR )  := &("CT2->"+cCpoDB )
					EndIf
				Next

				For nCont := 5 to Len(aCtbEntid[1])
					cAuxEnt := &("CT2->"+"CT2_EC"+StrZero(nCont, 2)+"DB" )  //entidade 05 em diante
					&("TMP->"+"CT2_EC"+StrZero(nCont, 2)+"DB" )  := &("CT2->"+"CT2_EC"+StrZero(nCont, 2)+"CR" )
					&("TMP->"+"CT2_EC"+StrZero(nCont, 2)+"CR" )  := cAuxEnt
				Next

			EndIf

			IF _lCt102Carr
				ExecBlock("Ct102Carr",.F.,.F.,{ nOpc,dDataLanc,cLote,cSubLote,cDoc }  )
			Endif

			dbSelectArea("CT2")
			dbSkip()

			While ! Eof().And. lContinua .And. ;
					CT2->CT2_FILIAL == cFilialCT2		.And.;
					CT2->CT2_DATA 	== dDataLanc		.And.;
					CT2->CT2_LOTE 	== cLote 			.And.;
					CT2->CT2_SBLOTE == cSubLote 		.And.;
					CT2->CT2_DOC 	== cDoc				.And.;
					CT2->CT2_TPSALD == TMP->CT2_TPSALD 	.And.;
					CT2->CT2_EMPORI == TMP->CT2_EMPORI 	.And.;
					CT2->CT2_FILORI == TMP->CT2_FILORI	.And.;
					CT2->CT2_LINHA  == TMP->CT2_LINHA  	.And.;
					CT2->CT2_MOEDLC <> cMoeda

				&("TMP->CT2_VALR" + CT2->CT2_MOEDLC ) := CT2->CT2_VALOR

				If CtbUso( "CT2_DTTX" + CT2->CT2_MOEDLC )
					&( "TMP->CT2_DTTX" + CT2->CT2_MOEDLC ) := CT2->CT2_DATATX
				EndIf

				If Len( cCritConv ) <> Val( CT2->CT2_MOEDLC ) - 1
					nMoeAtu	:= Val( CT2->CT2_MOEDLC ) - 1

					For nC := Len( cCritConv ) + 1 TO nMoeAtu
					   cCritConv += "5"
					Next
				Endif

				cCritConv += CT2->CT2_CRCONV
				nVezes ++
				dbSkip()
			EndDo

			If Len(cCritConv) < nTamCrit
				For nC	:= Len(cCritConv)+1 to nTamCrit
					cCritConv += "5"
				Next
    		EndIf

			If TMP->CT2_DC <> '4'
				TMP->CT2_CONVER	:= cCritConv
			EndIf

			// Se for Efetivacao de Lancamentos (CTBA350), alterar o Tipo de Saldo para "1" (Real)
			If cProg == "CTBA350"
				TMP->CT2_TPSALD := "1"
			EndIf

		EndDo
	EndIf
Else
	dbSelectArea("TMP")
	dbAppend()
	For nCont := 1 To Len(aHeader)
		If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
			nPos := FieldPos(aHeader[nCont][2])
			FieldPut(nPos,CriaVar(aHeader[nCont][2],.T.))
		EndIf
	Next nCont

	For nCont	:= 2 to __nQuantas
		If CtbUso("CT2_DTTX"+StrZero(nCont,2))
			&("TMP->CT2_DTTX"+StrZero(nCont,2))	:= dDataLanc
		EndIf
	Next

	TMP->CT2_FLAG := .F.
	TMP->CT2_LINHA:= StrZero( 1, Len(CT2->CT2_LINHA) )  //"001"
	TMP->CT2_ALI_WT := "CT2"
	TMP->CT2_REC_WT := 0
	TMP->CT2_DTCONF := MsDate()
	If lSeqCorr
		TMP->CT2_DIACTB := cCodSeq
	EndIf
EndIf

RestArea(aAreaCT2)
RestArea(aSaveArea)

If CT2->( Recno() ) <> nRecnoCT2
	// efetuo o reposicionamento no CT2 para garantir o posicionamento correto
	CT2->( DbGoTo( nRecnoCT2 ) )
Endif

If Empty( cLinhaAlt )
	cLinhaAlt := FieldGet(FieldPos("CT2_LINHA"))
Endif

dbSelectArea("TMP")
dbSetOrder(2)

IF cLinhaAlt <> StrZero(1,TamSx3("CT2_LINHA")[1])
	TMP->( DbSeek( cLinhaAlt ) )
ELSE
	TMP->( dbGoTop() )
ENDIF

Return lContinua

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBEnche  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche GetDb com Lancamento Padrao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbEnche(cPadrao,lFirst)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cTipo                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Lancamento Padrao                        ³±±
±±³          ³ ExpL1 = Indica se esta entranado pela primeira vez         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTbEnche(cPadrao,lFirst)

Local aSaveArea	:= GetArea()
Local cCampoCT5
Local cCampoTMP
Local cTipo			:= ""
Local cCriter		:= ""
Local nLen			:= 0
Local nLinha		:= Val(TMP->CT2_LINHA)
Local nValor 		:= 0
Local nCont			:= 0
Local nPosCT5		:= 0
Local nPosTMP		:= 0
Local nMoeda		:= 0

Local cDCTMP		:= ""			//// TIPO DO LANCAMENTO ADICIONADO
Local cSeqLan		:= ""			//// SEQUENCIA DE LANÇAMENTO
Local cSeqHis		:= ""			//// SEQUENCIA DE HISTORICO

Local lCarregou
Local cMoedas
Local nMoedas
Local bBlock
Local nQtdCT5		:= 0

If Type("xBuffer") == "U" //protegendo para caso em alguma situação que esteja vindo de outro lugar não sobrescrever o valor
	Private xBuffer := ""  //variavel para não estourar ErrorLog quando usuario tenta utilizar lançamentos relacionados a txt
Endif

If Type("lCt102Auto") == "U"
	lCt102Auto := .F.
EndIf

DbSelectArea("CT5")
DbSetOrder(1)
MsSeek(xFilial()+cPadrao)
While !Eof() .And. CT5->CT5_FILIAL == xFilial() .and. CT5->CT5_LANPAD == cPadrao

	If CT5->CT5_STATUS == "2"
		CT5->(dbSkip())
		Loop
	EndIf

	DbSelectArea("TMP")
	DbSetOrder(1)
	If lFirst
		// Inclui o primeiro o registro ou substitui.
		dbAppend()
		//Estava ocorrendo erro de refresh de tela na Getdb quando carregava o TMP com o objeto ja criado
		If oGetDb <> Nil
			oGetDb:nCount++
		EndIf
	EndIf

	nQtdCT5++

	//------------------------------------------------------------------
	// Adiciona linha no array da execauto se na CT5 houver mais linhas
	//------------------------------------------------------------------
	If lCt102Auto .And. nQtdCT5 > Len(aAutoItens)
		Aadd(aAutoItens,{})

		Aadd(aAutoItens[nQtdCT5], {"CT2_LINHA",StrZero(nQtdCT5,Len(CT2->CT2_LINHA)),Nil})

	EndIf

	For nCont := 1 To Len(aHeader)
		// Carrega definicao do campo do CT5 a partir da aHeader do TMP
		dbSelectArea("CT5")
		If Alltrim(aHeader[nCont][2]) = "CT2_VALOR"
			cCampoCT5 := "CT5_VLR01"
		Else
			cCampoCT5 := "CT5_" + Substr(aHeader[nCont][2],5,Len(aHeader[nCont][2]))
		Endif

		// Procura posicao do campo referente no CTK
		dbSelectArea("TMP")
		If Alltrim(cCampoCT5) == "CT5_VLR01"
			cCampoTMP	:= "CT2_VALOR"
			nPosTmp		:= FieldPos(cCampoTmp)
		Else
			cCampoTMP	:= Alltrim(aHeader[nCont][2])
			nPosTmp 	:= FieldPos(cCampoTmp)
		EndIf

		If nPosTmp > 0
			If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
				// Carrega dado do CT5
				dbSelectArea("CT5")
				nPosCT5 := FieldPos(cCampoCT5)
				If nPosCT5 > 0
					If aHeader[nCont][08] == "N"					// Campo Numerico
						If Alltrim(cCampoTMP) == "CT2_VALOR"
							nValor := If(Valtype(&(&(cCampoCT5)))=="N",&(&(cCampoCT5)),0)
							lCarregou 			:= .F.
							TMP->CT2_VALOR		:= nValor
							If TMP->CT2_VALOR	== 0
								// Carregar o criterio de conversao da conta do Lancamento Padrao
								If CT5->CT5_DC $ "13"
									CarrCriter(CT5->CT5_DEBITO,CT5->CT5_DC,"TMP->CT2_CONVER",dDataLanc)
								ElseIf CT5->CT5_DC $ "23"
									CarrCriter(CT5->CT5_CREDIT,CT5->CT5_DC,"TMP->CT2_CONVER",dDataLanc)
								Else
									cCriter	:= "5"
								Endif
								lCarregou := (CT5->CT5_DC $ "123")
							Else
								cCriter	:= "1"
							EndIf
							//Atualiza os valores em outras moedas, caso nao tenha passado pela funcao CarrCriter()
							If ! lCarregou
								For nMoeda	:= 2 to __nQuantas
									cCampoCT5	:= "CT5->CT5_VLR"+StrZero(nMoeda,2)
									nValor	:= Val(&(cCampoCT5))
									&("TMP->CT2_VALR"+StrZero(nMoeda,2)) := nValor
									If nValor	== 0
										If CT5->CT5_DC $ "13"
											CarrCriter(CT5->CT5_DEBITO,CT5->CT5_DC,"TMP->CT2_CONVER",dDataLanc)
										ElseIf CT5->CT5_DC $ "23"
											CarrCriter(CT5->CT5_CREDIT,CT5->CT5_DC,"TMP->CT2_CONVER",dDataLanc)
										Else
											cCriter	+= "5"
										EndIf
										lCarregou := (CT5->CT5_DC $ "123")
									Else //Criterio Informado
										cCriter	+= "4"
									EndIf
								Next
							EndIf
                            // Se carregou mas no LP tem alguma moeda p/ a qual nao deva-se fazer o lancamento,
                            // atribuir "5" (Sem Conversao) para o criterio desta moeda
							If lCarregou .And. ("2" $ CT5->CT5_MOEDAS)
								cMoedas := AllTrim( CT5->CT5_MOEDAS )
								cCriter := ""
								For nMoedas := 1 to Len( cMoedas )
									If SubStr(cMoedas,nMoedas,1) == "2"
										cCriter += '5'
									Else
										If nMoedas <= Len( AllTrim(TMP->CT2_CONVER) )
											cCriter += SubStr(TMP->CT2_CONVER,nMoedas,1)
										Else // Se o tamanho de CT5->MOEDAS estiver maior que o tamanho de
										     // CT2_CONVER, atribuir "5" tambem
											cCriter += "5"
										EndIf
									EndIf
									lCarregou := .F.
								Next
							Endif
							If ! lCarregou
								TMP->CT2_CONVER	:= cCriter
							EndIf
						Else
							cValor	:= Trim(FieldGet(nPosCT5))
							dbSelectArea("TMP")
							If !Empty(cValor)
								nValor := &(cValor)
								FieldPut(nPosTMP,nValor)
							Else
								FieldPut(nPosTMP,0)
							EndIf
						EndIf
					ElseIf aHeader[nCont][08] == "C"				// Campo Caracter
						If Alltrim(cCampoTMP) == "CT2_TPSALD"
							nLen := Len(CriaVar(cCampoTmp))
							cValor := Alltrim(FieldGet(nPosCT5))
						Else
							nLen := Len(CriaVar(cCampoTmp))
							bBlock := ErrorBlock( { |e| ChecErro(e) } )
							BEGIN SEQUENCE
								cValor := Alltrim(TransLcta(FieldGet(nPosCT5),nLen))
							RECOVER
								cValor := Space(nLen)
							END SEQUENCE
							ErrorBlock(bBlock)
						EndIf
						dbSelectArea("TMP")
						FieldPut(nPosTMP,cValor)
					ElseIf aHeader[nCont][08] == "D"				// Campo Data
						cValor := Alltrim(TransLDta(FieldGet(nPosCT5)))
						dbSelectArea("TMP")
						FieldPut(nPosTMP,cValor)
					EndIf

					//---------------------------------------------------------------------
					// Tratamento para ExecAuto com o campo CPADRAO informado no cabecalho
					//---------------------------------------------------------------------
					If lCt102Auto
						//-----------------------------------------------------------------------
						// Somente adiciona dados, nao altera o que veio informado pela execauto
						//-----------------------------------------------------------------------
						If ( (aHeader[nCont][08] == "N" .And. !Empty(nValor)) .Or. (aHeader[nCont][08] == "C" .And. !Empty(cValor)) ); //Verifica se o campo da CT5 foi preenchido
							.And. AScan( aAutoItens[nQtdCT5], { |x| x[1] == cCampoTMP } ) == 0 //Só usa o valor se o usuário nao informou esse campo na execauto

							Aadd(aAutoItens[nQtdCT5], {cCampoTMP,If(aHeader[nCont][08] == "N",nValor,cValor),Nil})

						EndIf
					EndIf

				EndIf
			EndIf
		EndIf
	Next

	If Empty(TMP->CT2_LINHA)
		nLinha++
		TMP->CT2_LINHA	:= StrZero(nLinha,Len(CT2->CT2_LINHA))
	EndIf
	TMP->CT2_FLAG 	:= .F.
	TMP->CT2_LP		:= cPadrao
	TMP->CT2_ALI_WT := "CT2"
	TMP->CT2_REC_WT := 0
	TMP->CT2_MLTSLD := CT5->CT5_MLTSLD

	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//// BLOCO PARA TRATAMENTO E GRAVACAO DO SEQLAN E SEQHIS NO TMP
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	dbSelectArea("TMP")
	dbSetOrder(2)
	cDCTMP	:= TMP->CT2_DC
	nRecTMP	:= Recno()
	dbSkip(-1) 			//Procuro pela sequencia, para poder calcular a proxima.
	If !Bof() .And. !Eof()
		If cDCTMP == "4"
			cSeqHis	:= StrZero((Val(TMP->CT2_SEQHIS)+1),3)
			cSeqLan	:= TMP->CT2_SEQLAN
		Else
			cSeqHis	:= "001"

			If TMP->CT2_DC == "4"
				While !TMP->(Bof()) .and. TMP->CT2_DC == "4"
					dbSkip(-1)
				End
				cSeqLan 			:= Soma1( TMP->CT2_SEQLAN )
			Else
				cSeqLan 			:= Soma1( TMP->CT2_SEQLAN )
			EndIf
		EndIf
	Else
		cSeqLan 			:= StrZero( 1,Len(CT2->CT2_SEQLAN))
		cSeqHis 			:= '001'
	Endif

	dbGoto(nRecTMP)
	TMP->CT2_SEQLAN		:= cSeqLan
	TMP->CT2_SEQHIS		:= cSeqHis
	/////////////////////////////////////////////////////////////////////////////////////////
	//// FIM DO BLOCO DE GRAVACAO DO SEQLAN E SEQHIS NO TMP
	/////////////////////////////////////////////////////////////////////////////////////////

	// Verifica se havera quebra de historico
	dbSelectArea( "CT5" )
	nTamCt5Hist	:= Iif( GetNewpar( "MV_CT5HIST", .T. ) , Len( Alltrim( CT5->CT5_HIST ) ) ,TamSx3( "CT2_HIST" )[1] )
	cHistorico 	:= Alltrim( TransLcta( CT5->CT5_HIST, nTamCt5Hist ))

	dbSelectArea("TMP")
	nLen := Len(CriaVar("CT2_HIST"))

	If Len(cHistorico) > nLen
		For nCont:= nLen+1 To Len(cHistorico) Step nLen
			cHist := Substr(cHistorico,nCont,nLen)
			cSeqHis	:= StrZero((Val(cSeqHis)+1),3)

			nLinha++
			dbAppend()
			If oGetdb <> Nil
				oGetDb:nCount++
			Endif

			TMP->CT2_DC 	:= "4"
			TMP->CT2_SEQLAN	:= cSeqLan
			TMP->CT2_SEQHIS	:= cSeqHis
			TMP->CT2_HIST	:= cHist
			TMP->CT2_LINHA  := StrZero(nLinha,Len(CT2->CT2_LINHA))
			TMP->CT2_FLAG 	:= .F.
			TMP->CT2_TPSALD	:= CT5->CT5_TPSALD
			lCont 			:= .T.
		Next
	EndIf

	//Indexa pela ordem 2 => TMP->CT2_LINHA
	dbSetorder(2)
	dbSkip()
	If TMP->(Eof())
		lFirst := .T.
	Else
		nLinha	:= Val(TMP->CT2_LINHA)
	EndIf
	//Voltar o indice para ordem 1
	dbSetOrder(1)
	DbSelectArea("CT5")
	dbSetOrder(1)
	DbSkip()

EndDo

dbSelectArea("TMP")
dbSetOrder(2)
dbGoTop()

cTipo := TMP->CT2_DC

RestArea(aSaveArea)

TMP->(dbSetOrder(0))

If oGetDb <> Nil
	oGetDb:oBrowse:Refresh()
EndIf

Return cTipo

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbEscPad ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe lancamento Padrao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbEscPad(lCancel)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Define se confirmou ou cancelou                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbEscPad(lCancel)

Local aSaveArea:= GetArea()
Local aPadrao 	:= {}
Local cRet		:= ""
Local cCodAnt	:= ""
Local cListBox
Local nCont		:= 0
Local nOpca
Local oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array com Lan‡amentos Padronizados                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CT5")
MsSeek(cFilial)
While !Eof() .and. CT5->CT5_FILIAL == xFilial() .And. Val(CT5->CT5_LANPAD) < 500
	IF nCont == 0
		cCodAnt := CT5->CT5_LANPAD
		nCont := 1
		Aadd(aPadrao,CT5_LANPAD+"   "+"   "+CT5_DESC)
	EndIF
	IF cCodAnt != CT5->CT5_LANPAD
		nCont := 0
		Loop
	EndIF
	dbSkip()
EndDO
If Len(aPadrao) == 0
	Return Nil
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha tela para escolhida do Padronizado                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cListBox := aPadrao[1]
nOpca := 0
DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 50 TITLE OemToAnsi(STR0012)		 //"Escolha Lanc Padrao"
@  .5, 2 LISTBOX cListBox ITEMS aPadrao SIZE 150 , 40 Font oDlg:oFont
	DEFINE SBUTTON FROM 055,112   TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 055,139.1 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED
If nOpca == 1
	cRet:=Substr(cListBox,1,3)
Else
	lCancel := .T.
	Return Nil
Endif

RestArea(aSaveArea)

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbEscRat ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe Rateio On-Line                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbEscRat(lCancel)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Matriz com rateios cadastrados no CT9                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Define se confirmou ou cancelou                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbEscRat(lCancel)

Local aRateio	:= {}, aRatEnt := {}
Local aRat		:= {}
Local cCodAnt
Local cListBox
Local oDlg
Local nCont 	:= 0
Local nValRat	:= 0
Local nOpca		:= 0
Local nPos		:= 0
Local cTpEntida := " "
Local lDebito	:= .F.
Local lCredito	:= .F.
Local cHistorico := CriaVar("CT2_HIST")


Private cDebito	 := CriaVar("CT2_DEBITO")
Private cCredito := CriaVar("CT2_CREDIT")

If _lCTB102RT
	nValRat := Execblock("CTB102RT",.f.,.f.)
Endif

If cPictVal == Nil
	cPictVal  := PesqPict("CT2","CT2_VALOR")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array com rateios pr‚-cadastrados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CT9")
dbSetOrder(1)
MsSeek(xFilial())
While !Eof() .and. CT9->CT9_FILIAL == xFilial()
	IF nCont == 0
		If _lRATONFIL					////  SE EXISTIR O PE RATONFIL
			If EXECBLOCK("RATONFIL",.F.,.F.)
				CT9->(dbSkip())			////  NÃO INCLUI NA SELEÇÃO DE RATEIOS
				Loop					////  PASSA PARA O PROXIMO
			Endif
		Endif
		cCodAnt	:= CT9_RAT_ON
		nCont := 1
		Aadd(aRateio, CT9_RAT_ON+" "+CT9_DESC)

		cTpEntida := " "
		lDebito   := Ct100TpRat("1", @cTpEntida, "CT9")
		lCredito  := Ct100TpRat("2", @cTpEntida, "CT9")

		lDebito  := lDebito .And. Empty(CT9->CT9_DEBITO)
		lCredito := lCredito .And. Empty(CT9->CT9_CREDIT)

		Aadd(aRatEnt, { If(cTpEntida == "0", lDebito .OR. lCredito, cTpEntida > "0"), cTpEntida })
	EndIF

	IF cCodAnt != CT9_RAT_ON
		nCont := 0
		Loop
	EndIF
	dbSkip()
EndDO

If Len(aRateio) == 0
	lCancel := .F.
	Return aRat
EndIf

nOpca := 0
cListBox := aRateio[1]
DEFINE MSDIALOG oDlg FROM 5, 5 TO 21, 50 TITLE OemToAnsi(STR0013)  //"Escolha Rateio"
	@  .5,2 	Say OemToAnsi(STR0014)  //"Valor a Ratear : "
	@  .5,9.5 	MSGET nValRat Pict cPictVal Valid Positivo(nValRat)
	@  1.7, 2 	LISTBOX cListBox ITEMS aRateio SIZE 150 , 40 Font oDlg:oFont;
				On Change CtbDigCta(aRateio, cListBox, aRatEnt, oSayDeb, oDebito, oSayCrd, oCredito)

	@ 5.2,2 	Say oSayDeb Prompt STR0031 //"Conta a Debito"
	@ 5.2,12 	MSGET oDebito Var cDebito;
				F3 "CT1" Picture "@!" Valid Ctb105Cta(cDebito) SIZE 070,8
	@ 6.2,2 	Say oSayCrd Prompt STR0032 //"Conta a Credito"
	@ 6.2,12 	MSGET oCredito Var cCredito;
				F3 "CT1" Picture "@!" Valid Ctb105Cta(cCredito) SIZE 070,8
	@ 7.2,0.4	Say STR0033 //"Historico"
	@ 7.2,3.3  	MSGET cHistorico Picture PesqPict("CT2", "CT2_HIST") SIZE 150,8

	CtbDigCta(aRateio, cListBox, aRatEnt, oSayDeb, oDebito, oSayCrd, oCredito)

	DEFINE	SBUTTON FROM 105,110 TYPE 1;
			ACTION 	If(aRatEnt[nPos := Ascan(aRateio, cListBox)][1] .And.;
					! CtbValCta(cDebito, cCredito, aRatEnt[nPos][2]),;
					(nOpca := 0, Help(" ",1,"CT9DEBCRED")),;
					(nOpca := 1,oDlg:End())) ENABLE OF oDlg
	DEFINE 	SBUTTON FROM 105,138 TYPE 2 ACTION (nOpca := 0,oDlg:End()) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

IF nOpca != 0 .And. nValRat > 0
	AADD(aRat,Subs(cListBox,1,6))
	AADD(aRat,nValRat)
	If aRatEnt[nPos][1]
		AADD(aRat,cDebito)
		AADD(aRat,cCredito)
	Else
		AADD(aRat,"")
		AADD(aRat,"")
	Endif
	AADD(aRat,cHistorico)
ElseIf nOpca == 0
	lCancel := .T.
EndIF

Return aRat

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbDigCta ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 06.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita/Desabilita objetos para digitacao da conta        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbDigCta(aRateio, cListBox, aRatEnt, oSayDeb, oDebito,    ³±±
±±³          ³ oSayCrd, oCredito)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F. = Se sim permite a digitacao das contas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRateio  = Matriz do listbox para escolha do usuario       ³±±
±±³          ³ cListBox = Item selecionado                                ³±±
±±³          ³ aRatEnt  = Matriz indicando se permite ou nao digitar cta  ³±±
±±³          ³ oSayDeb  = Objeto say da digitacao a debito                ³±±
±±³          ³ oDebito  = Objeto da digitacao da conta a debito           ³±±
±±³          ³ oSayCrd  = Objeto say da digitacao a credito               ³±±
±±³          ³ oCredito = Objeto da digitacao da conta a credito          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CtbDigCta(aRateio, cListBox, aRatEnt, oSayDeb, oDebito, oSayCrd, oCredito)

Local nPos := Ascan(aRateio, cListBox)

If aRatEnt[nPos][1]
	oSayDeb:Enable()
	oDebito:Enable()
	oSayCrd:Enable()
	oCredito:Enable()
Else
	oSayDeb:Disable()
	oDebito:Disable()
	oSayCrd:Disable()
	oCredito:Disable()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbRateio ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula valores do rateio                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbRateio(cRateio,nValRateio,nTotalDeb,nTotalCrd,cDebito,   ³±±
±±³          ³          cCredito)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Tipo do 1o. registro do rateio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1      = Codigo do Rateio                               ³±±
±±³          ³ExpN1      = Valor do  Rateio                               ³±±
±±³          ³ExpN2      = Valor Total debito                             ³±±
±±³          ³ExpN3      = Valor Total Credito                            ³±±
±±³          ³cDebito    = Valor Total debito                             ³±±
±±³          ³cCredito   = Valor Total Credito                            ³±±
±±³          ³cHistorico = Historico para repetir nas linhas rateio       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbRateio(cRateio,nValRateio,nTotalDeb,nTotalCrd,cDebito,cCredito,cHistorico)

Local cCONVER	:= "1"
Local cValor
Local cTipoRat := "5" 			// Retorno p/ sair do loop de atualizacao da GetDb

Local dValor

Local lFirst	:= .T.
Local lDebito	:= .F.
Local lCredito	:= .F.

//Local nSeq
Local cLinSeq
Local nTotRegTMP	:= 0
Local nValor
Local nValLinha
Local nPerBase
Local nPosCT9
Local nDif			:= 0
Local nRecno
Local nRegDeb, nRegCrd
Local nPosTMP
Local nCont			:= 0

Local cDCTMP		:= ""
Local cSeqLan		:= ""
Local cSeqHis		:= ""
Local nOrdTMP		:= 1
Default cDebito 	:= ""
Default cCredito	:= ""

dbSelectArea("TMP")
nTotRegTMP := RecCount()

dbGoto(nTotRegTMP)
//nSeq	:= Val(TMP->CT2_LINHA)
cLinSeq	:= TMP->CT2_LINHA

dbSelectArea("CT9")
dbSetOrder(1)
If MsSeek(xFilial()+cRateio)
	cMoeda		:= CT9->CT9_MOEDLC
	nPerBase 	:= CT9->CT9_PERBAS
	nValRateio	:= (nValRateio * (nPerBase/100))
	nTotalDeb	:= 0
	nTotalCrd	:= 0
EndIf

While !Eof() .and. CT9->CT9_FILIAL == xFilial() .And. CT9->CT9_RAT_ON == cRateio
   If CT9->CT9_PERCEN > 0
		dbSelectArea("TMP")
		If !lFirst
			cLinSeq := Soma1(cLinSeq)//nSeq++
			dbAppend()
			oGetDb:nCount++
		EndIf

		cCONVER := "1"
		// Carrega campos -> Relacao entre CT9 X TMP (CT2)
		For nPosTMP := 1 To Fcount()
			dbSelectArea("TMP")
			cCampoTMP := FieldName(nPosTMP)

			// Carrega definicao do campo do CT9 a partir do TMP
			dbSelectArea("CT9")
			cCampoCT9 := "CT9_" + Substr(cCampoTMP,5,Len(cCampoTMP))

			If cCampoTMP == "CT2_CONVER"
				If !Empty(dDataLanc)
					For nCont := 1 to len(CT9->CT9_CRITER)
						aPeriodos	:= CtbPeriodos(StrZero(nCont+1,2),dDataLanc,dDataLanc,.F.,.F.)
						If !Empty(aPeriodos[1][1])
							If aPeriodos[1][4] $ "1" .AND. Empty(Substr(TMP->CT2_CONVER,nCont+1,1)) .and. !Substr(CT9->CT9_MOEDAS,nCont+1,1) $ " 2"
								If Empty(Substr(CT9->CT9_CRITER,nCont,1))
									cCONVER += "5"
								Else
									cCONVER += Subs(CT9->CT9_CRITER,nCont,1)
								Endif
							ElseIf !Empty(Substr(TMP->CT2_CONVER,nCont+1,1))
								cCONVER += Substr(TMP->CT2_CONVER,nCont+1,1)
							Else
								cCONVER	+= "5"
							EndIf
						Else
							cCONVER += "5"
						EndIf
					Next
				Else
					cCONVER += &("CT9->CT9_CRITER")
				EndIf
				dbSelectArea("TMP")
				FieldPut(nPosTMP,cCONVER)
			Else
				// Carrega dado do CT9
				dbSelectArea("CT9")
				nPosCT9 := FieldPos(cCampoCT9)
				If nPosCT9 > 0
					dbSelectArea("TMP")
					If ValType(&(cCampoTMP)) == "N"						// Campo Numerico
						dbSelectArea("CT9")
						nValor	:= FieldGet(nPosCT9)
						dbSelectArea("TMP")
						FieldPut(nPosTMP,nValor)
					ElseIf ValType(&(cCampoTMP)) == "C"				// Campo Caracter
						dbSelectArea("CT9")
						cValor := Alltrim(FieldGet(nPosCT9))
						dbSelectArea("TMP")
						FieldPut(nPosTMP,cValor)
					ElseIf ValType(&(cCampoCTK)) == "D"				// Campo Data
						dValor := FieldGet(nPosCT5)
						dbSelectArea("TMP")
						FieldPut(nPosTMP,dValor)
					EndIf
				EndIf
			Endif
		Next

		TMP->CT2_LINHA 	:= cLinSeq //StrZero(nSeq,3)

		If CtbUso("CT2_DCD")						//  Digito de Controle
			If !Empty(TMP->CT2_DEBITO)
				dbSelectArea("CT1")
				dbSetOrder(1)
				If MsSeek(xFilial()+TMP->CT2_DEBITO)
					TMP->CT2_DCD	:= CT1->CT1_DC
				EndIf
				dbSelectArea("CT9")
			EndIf
		EndIf

		If CtbUso("CT2_DCC")						//  Digito de Controle
			If !Empty(TMP->CT2_CREDIT)
				dbSelectArea("CT1")
				dbSetOrder(1)
				If MsSeek(xFilial()+TMP->CT2_CREDIT)
					TMP->CT2_DCC	:= CT1->CT1_DC
				EndIf
				dbSelectArea("CT9")
			EndIf
		EndIf

		If ! Empty(cDebito) .Or. ! Empty(cCredito)
			If ! Empty(cDebito) .And. ! Empty(cCredito)
				//Definido que o tipo de lancamento contabil sera definido por centro de custo, item ou classe de valor
				//na ordem hierarquica acima.
				If !Empty(CT9->CT9_CCD) .Or. !Empty(CT9->CT9_CCC)
					If !Empty(CT9->CT9_CCD) .And. Empty(CT9->CT9_CCC)
						TMP->CT2_DC	:= "1"
					ElseIf Empty(CT9->CT9_CCD) .And. !Empty(CT9->CT9_CCC)
						TMP->CT2_DC	:= "2"
					Else
						TMP->CT2_DC := "3"
					EndIf
				ElseIf !Empty(CT9->CT9_ITEMD) .Or. !Empty(CT9->CT9_ITEMC)
					If !Empty(CT9->CT9_ITEMD) .And. Empty(CT9->CT9_ITEMC)
						TMP->CT2_DC	:= "1"
					ElseIf Empty(CT9->CT9_ITEMD) .And. !Empty(CT9->CT9_ITEMC)
						TMP->CT2_DC	:= "2"
					Else
						TMP->CT2_DC := "3"
					EndIf
				ElseIf !Empty(CT9->CT9_CLVLDB) .Or. !Empty(CT9->CT9_CLVLCR)
					If !Empty(CT9->CT9_CLVLDB) .And. Empty(CT9->CT9_CLVLCR)
						TMP->CT2_DC	:= "1"
					ElseIf Empty(CT9->CT9_CLVLDB) .And. !Empty(CT9->CT9_CLVLCR)
						TMP->CT2_DC	:= "2"
					Else
						TMP->CT2_DC := "3"
					EndIf
				Else 
					//Se nenhuma entidade estiver preenchida, considera tipo de lançamento do cadastro de rateio
					TMP->CT2_DC := CT9->CT9_DC 
				EndIf
			ElseIf ! Empty(cDebito)
				TMP->CT2_DC := "1"
			Else
				TMP->CT2_DC := "2"
			Endif
			If TMP->CT2_DC	$"1/3"
				TMP->CT2_DEBITO := cDebito
				If CtbUso("CT2_DCD")						//  Digito de Controle
					If !Empty(TMP->CT2_DEBITO)
						dbSelectArea("CT1")
						dbSetOrder(1)
						If MsSeek(xFilial()+TMP->CT2_DEBITO)
							TMP->CT2_DCD	:= CT1->CT1_DC
						EndIf
						dbSelectArea("CT9")
					EndIf
				EndIf
			EndIf

			If TMP->CT2_DC	$ "2/3"
				TMP->CT2_CREDIT := cCredito
				If CtbUso("CT2_DCC")						//  Digito de Controle
					If !Empty(TMP->CT2_CREDIT)
						dbSelectArea("CT1")
						dbSetOrder(1)
						If MsSeek(xFilial()+TMP->CT2_CREDIT)
							TMP->CT2_DCC	:= CT1->CT1_DC
						EndIf
						dbSelectArea("CT9")
					EndIf
				EndIf
			EndIF

			If ! Empty(cDebito)
				CT1->(MsSeek(xFilial() + cDebito))
				If CT1->CT1_ACCUST = "2"
					TMP->CT2_CCD := ""
				Endif
				If CT1->CT1_ACITEM = "2"
					TMP->CT2_ITEMD	:= ""
				Endif
				If CT1->CT1_ACCLVL = "2"
					TMP->CT2_CLVLDB	:= ""
				Endif
			Else		// Zero todas as entidades a debito caso nao digite a debito
				TMP->CT2_CCD	:= ""
				TMP->CT2_ITEMD	:= ""
				TMP->CT2_CLVLDB	:= ""
			Endif

			If ! Empty(cCredito)
				CT1->(MsSeek(xFilial() + cCredito))
				If CT1->CT1_ACCUST = "2"
					TMP->CT2_CCC	:= ""
				Endif
				If CT1->CT1_ACITEM = "2"
					TMP->CT2_ITEMC	:= ""
				Endif
				If CT1->CT1_ACCLVL = "2"
					TMP->CT2_CLVLCR	:= ""
				Endif
			Else		// Zero todas as entidades a debito caso nao digite a credito
				TMP->CT2_CCC	:= ""
				TMP->CT2_ITEMC	:= ""
				TMP->CT2_CLVLCR	:= ""
			Endif
		Endif

		If lFirst
			cTipoRat := TMP->CT2_DC
		EndIf

		//////////////////////////////////////////////////////////////////////////////////////////////////////
		//// BLOCO PARA TRATAMENTO E GRAVACAO DO SEQLAN E SEQHIS NO TMP
		//////////////////////////////////////////////////////////////////////////////////////////////////////
		dbSelectArea("TMP")
		nRecTMP	:= Recno()
		nOrdTMP	:= IndexOrd()
		cDCTMP	:= TMP->CT2_DC
		dbSetOrder(2)
		dbSkip(-1) 			//Procuro pela sequencia, para poder calcular a proxima.
		If !Bof() .And. !Eof()
			If cDCTMP == "4"
				cSeqHis	:= StrZero((Val(TMP->CT2_SEQHIS)+1),3)
				cSeqLan	:= TMP->CT2_SEQLAN
			Else
		   		cSeqHis	:= "001"

				If TMP->CT2_DC == "4"
					While !TMP->(Bof()) .and. TMP->CT2_DC == "4"
						dbSkip(-1)
					End
					cSeqLan := Soma1( TMP->CT2_SEQLAN )
				Else
					cSeqLan := Soma1( TMP->CT2_SEQLAN )
				EndIf
			EndIf
		Else
			cSeqLan 			:= StrZero( 1, Len(CT2->CT2_SEQLAN) )  //'001'
			cSeqHis 			:= '001'
   		Endif

		dbGoto(nRecTMP)
		dbSetOrder(nOrdTMP)
		TMP->CT2_SEQLAN		:= cSeqLan
		TMP->CT2_SEQHIS		:= cSeqHis
		/////////////////////////////////////////////////////////////////////////////////////////
		//// FIM DO BLOCO DE GRAVACAO DO SEQLAN E SEQHIS NO TMP
		/////////////////////////////////////////////////////////////////////////////////////////
		// Carrega valor do Rateio
		nPercentual := CT9->CT9_PERCEN
		nValLinha 	:= Round(NoRound((nValRateio * (nPercentual / 100)),3),2)
		If cMoeda ='01'
			TMP->CT2_VALOR := nValLinha
		Else
			&('TMP->CT2_VALR'+cMoeda) := nValLinha
		EndIf
		If ! Empty(cHistorico)
			TMP->CT2_HIST := cHistorico
		Endif

		If TMP->CT2_DC == "1"
			nTotalDeb	+= nValLinha
			nRegDeb 	:= TMP->(Recno())
		EndIf
		If TMP->CT2_DC =="2"
			nTotalCrd	+= nValLinha
			nRegCrd		:= TMP->(Recno())
		EndIf
		If TMP->CT2_DC =="3"
			// Neste caso nao armazeno o numero do registro, pois se houve diferenca somente
			// no debito, nao posso altera-lo uma vez que os valores sao lancados a debito e
			// a credito.
			nTotalCrd += nValLinha
			nTotalDeb += nValLinha
		EndIf

		dbSelectArea("CT9")
		dbSetOrder(1)
		dbSkip()
		nRecno := Recno()
		lFirst := .F.

		IF (Eof() .Or. CT9->CT9_FILIAL != xFilial() .or. CT9->CT9_RAT_ON != cRateio)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se for o £ltimo lan‡amento, acerta arredondamento			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("TMP")

// Bops 15589 - Testar se valor a debito ou a credito foi rateado para lancar diferenca

			lDebito  := .F.
			lCredito := .F.
			If nTotalDeb # 0 .And. nTotalDeb != nValRateio
				lDebito := .T.
			EndIf
			If nTotalCrd # 0 .And. nTotalCrd != nValRateio
				lCredito := .T.
			EndIf
			If lDebito
				nRegTmp := Recno()
				If nRegDeb <> Nil .And. TMP->CT2_DC <> '1'	// Posiciono no registro a debito
					dbGoto(nRegDeb)			// caso nao seja tipo de lacto a debito
				EndIf
				If TMP->CT2_DC <> '3'		// Bops 15303 - Nao altero o valor a debito
					nDif 		:= nValRateio - nTotalDeb	// Somente no teste a credito
					If cMoeda ='01'
						nValor 		:= Round(NoRound((TMP->CT2_VALOR + nDif),3),2)
					Else
						nValor 		:= Round(NoRound((&('TMP->CT2_VALR'+cMoeda) + nDif),3),2)
					EndIf
					nTotalDeb   += nDif
					If cMoeda='01'
						TMP->CT2_VALOR := nValor
					Else
						&('TMP->CT2_VALR'+cMoeda) := nValor
					EndIf
				Endif
				DbGoto(nRegTmp)
			EndIf
			If lCredito
				nRegTmp := Recno()
				If nRegCrd <> Nil .And. TMP->CT2_DC <> '2'	// Posiciono no registro a credito
					dbGoto(nRegCrd)			// caso nao seja tipo de lacto a credito
				EndIf
				nDif 		:= nValRateio - nTotalCrd
				If cMoeda = '01'
					nValor 		:= Round(NoRound((TMP->CT2_VALOR + nDif),3),2)
					TMP->CT2_VALOR := nValor
				Else
					nValor 		:= Round(NoRound((&('TMP->CT2_VALR'+cMoeda) + nDif),3),2)
					&('TMP->CT2_VALR'+cMoeda) := nValor
				EndIf
				nTotalCrd   += nDif
				If TMP->CT2_DC = '3'
					nTotalDeb += nDif
				Endif
				DbGoto(nRegTmp)
			EndIf
		EndIf
		dbSelectArea("CT9")
		dbGoto(nRecno)
		/// EFETUA A CONVERSÃO DOS VALORES DE OUTRAS MOEDAS
		Ctb105Conv(TMP->CT2_VALOR,TMP->CT2_CONVER)
	Else
		dbSelectArea("CT9")
		dbSkip()
	Endif
EndDo

Return cTipoRat

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ct102GrCTF³ Autor ³ Simone Mie Sato		³ Data ³ 20.01.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava arquivo CTF.								  	 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct102GrCtf(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento Contabil                        ³±±
±±³          ³ ExpC1 = Lote do Lancamento Contabil                        ³±±
±±³          ³ ExpC2 = Sub-Lote  do Lancamento Contabil                   ³±±
±±³          ³ ExpC3 = Documento do Lancamento Contabil                   ³±±
±±³          ³ ExpN1 = Semaforo para proximo documento                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK)

Local lRet 		:= .T.
Local aSaveArea	:= GetArea()
Local nCT2Ind	:= CT2->(IndexOrd())
Local nCT2Rec	:= CT2->(Recno())
Local cNameFun	:= FunName()
Local lMsgUnq	:= IsInCallStack("CTBI102")
Local dDataCTF	:= dDataLanc

If Type( 'lCt102Auto' ) == "U"
	lCt102Auto := .F.
EndIf

If cPaisLoc == "MEX"
	If !CT2ValDoc(xFilial("CT2"),dDataLanc,cLote,cSubLote,cDoc)
		If cNameFun != "CTBA101"
			lRet := .F.
		Endif
	Endif
Else
	dbSelectArea("CT2")
	dbSetOrder(1)//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
	If MsSeek(xFilial("CT2")+dtos(dDataLanc)+cLote+cSubLote+cDoc)
		If cNameFun != "CTBA101"
			lRet := .F. // SE ENCONTROU CT2 COM A CHAVE (JÁ RETORNA .f. NA VALIDACAO)
		Endif
	Endif
EndIf

If lRet
	If cPaisLoc == "MEX" // Consecutivo por mes, aplica solo para CTF
		dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
	EndIf
	dbSelectArea("CTF")			/// EFETUA NOVAMENTE A CHECAGEM DO CTF
	dbSetOrder(1) //CTF_FILIAL+DTOS(CTF_DATA)+CTF_LOTE+CTF_SBLOTE+CTF_DOC	/// PARA GARANTIR CASO POR ALGUM MOTIVO NÃO TENHA GRAVADO O CTF
	If !MsSeek(xFilial("CTF")+dtos(dDataCTF)+cLote+cSubLote+cDoc)
		LockDoc(dDataCTF,cLote,cSubLote,cDoc,@CTF_LOCK)	// Trava documento no Semaforo
	Else
		If !lMsgUnq .AND. !lCt102Auto // Proteção Mensagem Unica
			If CTF->(DBRLock())
				If Empty(CTF_LINHA)
					CTF_LOCK := CTF->(Recno())	/// SE NÃO ESTIVER "LOCADO" USA O NUMERO (RLOCK PARA RETORNAR .F. SE NÃO CONSEGUIU O HANDLE
				Else
					If cNameFun != "CTBA101"
						Help("",1,"EXISTCHAV")/// NÃO ESTA LOCADO MAS O NUMERO DE LINHA ESTA PREENCHIDO
						lRet := .F.  		///A chave ja existe, mostra help
					Else
						CTF_LOCK := CTF->(Recno())	/// USA O NUMERO (RLOCK PARA RETORNAR .F. SE NÃO CONSEGUIU O HANDLE
					Endif
				Endif
			Else
				Help("",1,"USEDCODE")/// SE ESTÁ "LOCADO" INDICA USO POR OUTRO USUARIO
				lRet := .F.  		///Se achou e esta bloqueado, mostra Help de acordo com a chave de valida‡„o
			Endif
		Else
			lRet := .T.
		EndIf
	Endif
Endif

CT2->(dbSetOrder(nCT2Ind))
CT2->(dbGoTo(nCT2Rec))
RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programaa ³C102ExbCta³Autor  ³ Simone Mie Sato		³ Data ³ 12.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao da conta contabil na MSGETDB				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C102ExbCta(cConta)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Conta Contabil		                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C102ExbCta(cConta)

Local cDesc := ""

dbSelectArea("CT1")
dbSetOrder(1)
If MsSeek(xFilial()+cConta)
	If CT1->CT1_CLASSE == "1"  .or. cDesc == Nil
		cDesc := Space(25)
	ElseIf CT1->CT1_CLASSE == "2"
		If cConta == Nil .Or. Empty(cConta)
			cDesc := Space(25)
		Else
			cDesc := CT1->CT1_DESC01
		EndIf
	EndIf
EndIf

IF Type("oDescEnt")="O"
	oDescEnt:SetText(OemToAnsi(cDesc))
	oDescEnt:Refresh()
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³C102ExbCC ³Autor  ³ Simone Mie Sato		³ Data ³ 12.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao do Centro de Custo na MSGETDB			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³C102ExbCC(cCusto)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Centro de Custo					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C102ExbCC(cCusto)

Local cDesc := ""

DbSelectArea("CTT")
DbSetOrder(1)
If MsSeek(xFilial("CTT")+cCusto)
	If CTT->CTT_CLASSE == "1"  .or. cDesc == Nil
		cDesc := Space(25)
	ElseIf CTT->CTT_CLASSE == "2"
		If cCusto == Nil .Or. Empty(cCusto)
			cDesc := Space(25)
		Else
			cDesc := CTT->CTT_DESC01
		EndIf
	EndIf
EndIf


IF Type("oDescEnt")="O"
	oDescEnt:SetText(OemToAnsi(cDesc))
	oDescEnt:Refresh()
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³C102ExbIt ³Autor  ³ Simone Mie Sato		³ Data ³ 12.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao do Item Contabil   na MSGETDB			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³C102ExbIt(cItem)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Item Contabil  					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C102ExbIt(cItem)

Local cDesc := ""


DbSelectArea("CTD")
DbSetOrder(1)
If MsSeek(xFilial("CTD")+cItem)
	If CTD->CTD_CLASSE == "1"  .or. cDesc == Nil
		cDesc := Space(25)
	ElseIf CTD->CTD_CLASSE == "2"
		If cItem == Nil .Or. Empty(cItem)
			cDesc := Space(25)
		Else
			cDesc := CTD->CTD_DESC01
		EndIf
	EndIf
EndIf


IF Type("oDescEnt")="O"
	oDescEnt:SetText(OemToAnsi(cDesc))
	oDescEnt:Refresh()
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³C102ExbCV ³Autor  ³ Simone Mie Sato		³ Data ³ 12.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao da Classe de Valor na MSGETDB			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³C102ExbCV(cClVl)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Classe de Valor					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C102ExbCV(cClVl)

Local cDesc := ""

DbSelectArea("CTH")
DbSetOrder(1)
If MsSeek(xFilial("CTH")+cClVl)
	If CTH->CTH_CLASSE == "1"  .or. cDesc == Nil
		cDesc := Space(25)
	ElseIf CTH->CTH_CLASSE == "2"
		If cClVl == Nil .Or. Empty(cClVl)
			cDesc := Space(25)
		Else
			cDesc := CTH->CTH_DESC01
		EndIf
	EndIf
EndIf

IF Type("oDescEnt")="O"
	oDescEnt:SetText(OemToAnsi(cDesc))
	oDescEnt:Refresh()
Endif

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C102ProxDoc³ Autor ³ Simone Mie Sato       ³ Data ³17.04.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Sugere proximo documento,quando altera o num. do lote.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³C102ProxDoc(dDataLanc,cLote,cSubLote,cDoc,oLote,oSublote,oDoc³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA102                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento                                  ³±±
±±³          ³ ExpC1 = Numero do Lote do Lancamento                        ³±±
±±³          ³ ExpC2 = Numero do Sub-Lote do Lancamento                    ³±±
±±³          ³ ExpC3 = Numero do documento do Lancamento                   ³±±
±±³          ³ ExpO1 = Objeto do Lote                                      ³±±
±±³          ³ ExpO2 = Objeto do Sub-Lote                                  ³±±
±±³          ³ ExpO3 = Objeto do Documento                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function C102ProxDoc(dDataLanc,cLote,cSubLote,cDoc,oLote,oSubLote,oDoc,CTF_LOCK)

Local aSaveArea := GetArea()
Local cKeyCTF   := ""
Local nIndCT2	:= CT2->(IndexOrd())
Local nRecCT2	:= CT2->(Recno())
Local dDataCTF	:= dDataLanc
Local cKeyCT2   := xFilial("CTF")+Dtos(dDataLanc)+cLote+cSubLote
Local lExecauto := (IsBlind() .and. INCLUI .and. !Empty(cDoc))

// Consecutivo por mes, aplica solo para CTF
If cPaisLoc == "MEX"
	dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
EndIf

dbSelectArea("CTF")
cKeyCTF := xFilial("CTF")+Dtos(dDataCTF)+cLote+cSubLote	//// CHAVE PARCIAL DO CTF

If CTF_LOCK > 0							/// INDICA ALTERACAO/EXCLUSAO
	DbGoto(CTF_LOCK)
	If cKeyCTF == CTF->(CTF_FILIAL+dtos(CTF_DATA)+CTF_LOTE+CTF_SBLOTE)
		CT2->(DbSetOrder(1))
		If !CT2->(MsSeek(cKeyCT2+cDoc))		//// SE NÃO ENCONTRAR CT2 INDICA QUE NÃO HOUVE GRAVAÇÃO COM A MESMA CHAVE
			CT2->(dbSetOrder(nIndCT2))
			CT2->(dbGoTo(nRecCT2))
			RestArea(aSaveArea)
			Return .T.						//// ENTÃO SÓ RETORNA .T. INDICANDO QUE A CHAVE É VALIDA
		Else
			UnLockDoc(@CTF_LOCK)			//// LIBERA O REGISTRO POIS JÁ EXISTE LANÇAMENTO NO CT2 (DE OUTRO USUÁRIO POIS AINDA ESTOU NA TELA)
		Endif
	Else
		CtbDestrava(CTF->CTF_DATA,CTF->CTF_LOTE,CTF->CTF_SBLOTE,CTF->CTF_DOC,@CTF_LOCK)		///	(MAS CHECA SE OUTRO USUÁRIO NAO GRAVOU CT2 COM O MESMO NUMERO PARA NÃO DELETAR INDEVIDO)
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o Numero do Proximo documento contabil                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK,,,,lExecauto)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o N§ do Doc estourou, incrementa o lote         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLote := CtbInc_Lot(cLote, cModulo)
	
Enddo
///LockDoc(dDataLanc,cLote,cSubLote,cDoc, @CTF_LOCK ) /// FOI PARA A PROXDOC

If ValType(oLote) == "O" .And. ValType(oSubLote) == "O" .And. ValType(oDoc) == "O"
	oLote:Refresh()	;oSubLote:Refresh();oDoc:Refresh()		// Atualiza a Tela
EndIf

CT2->(dbSetOrder(nIndCT2))		//// VOLTA A POSICAO ORIGINAL NO CT2 - INDICE
CT2->(dbGoTo(nRecCT2))			//// VOLTA A POSICAO ORIGINAL NO CT2 - REGISTRO

RestArea(aSaveArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontHistInt³ Autor ³ Simone Mie Sato       ³ Data ³04.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a tela de Historico Inteligente na Getdb.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontHistInt(cHp)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cTexto                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Historico Padrao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MontHistInt(cHp)

Local aSaveArea  := GetArea()
Local cTexto	 :=""
Local oDlg
Local oMemo2
Local aFormat 	 := {}


	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0027) ;  // "Historico Inteligente"
							FROM 80,1 to 250,400 PIXEL

	oMemo2:=MsHGet():New(01,01,144,80,oDlg,aFormat)
	oMemo2:oBox :NSTYLE := 7 // Ativa o Scroll Horizontal

	While !Eof() .And. CT8->CT8_HIST == cHP .And. CT8->CT8_IDENT == 'I'
		Aadd(aFormat,CT8->CT8_DESC)
		dbSkip()
	Enddo

	oMemo2:Restart(aFormat)
	oMemo2:Show()

	cTexto:=oMemo2:GetText()

DEFINE SBUTTON FROM 05, 150 TYPE 1 ACTION (nOpca := 1,;
					Iif(GTmpHisInt(dDataLanc,cLote,cSubLote,cDoc,cHp,cTexto,oMemo2),oDlg:End(),nOpca:=0)) ENABLE OF oDlg

DEFINE SBUTTON FROM 18, 150 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
ACTIVATE MSDIALOg oDlg CENTERED

RestArea(aSaveArea)

Return(cTexto)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GTmpHisInt ³ Autor ³ Simone Mie Sato       ³ Data ³04.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava o historico Inteligente no arq. temp. da GETDB		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GTmpHisInt(dData,cLote,cSubLote,cDoc,cHp,cTexto,oMemo2)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA102                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento                                 ³±±
±±³          ³ ExpC1 = Numero do Lote do Lancamento                       ³±±
±±³          ³ ExpC2 = Numero do Sub-Lote do Lancamento                   ³±±
±±³          ³ ExpC3 = Numero do documento do Lancamento                  ³±±
±±³          ³ ExpC4 = Codigo do Historico Padrao                         ³±±
±±³          ³ ExpC5 = Conteudo do Historico                              ³±±
±±³          ³ ExpO1 = Objeto Memo                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GTmpHisInt(dData,cLote,cSubLote,cDoc,cHp,cTexto,oMemo2)

Local nTamHist		:= Len(CriaVar("CT2_HIST"))
Local cDescricao	:= ""
Local nPasso		:= 0
Local nContaLinhas	:= 1		// Para o loop de gravacao de lancamento - Contador de linhas
Local cSeqLan 		:= ""
Local cSeqHis		:= "001"
Local cMoeda		:= TMP->CT2_MOEDLC
Local cTpSaldo		:= TMP->CT2_TPSALD
Local cSeqLanOfi 	:= ""
Local cSeqHisOfi 	:= ""
Local nRecAnt		:= 0
Local cProxLin		:= ""
Local nRecTmp		:= 0
Local nOrdTMP		:= 1
Local nContador	:= 0
Local cTxtPasso

cTexto		:= oMemo2:GetText()
cTexto		:= strtran(cTexto, chr(13), ' ')
cTexto		:= strtran(cTexto, chr(10), ' ')
cTxtPasso	:= cTexto
nLinTotal	:= LinhaHist( cTexto , nTamHist )
cLinha 		:= TMP->CT2_LINHA

For nContador := 1 To nLinTotal

	cDescricao 	:= MemoLine(cTexto, nTamHist, nContador)

	If Empty( cDescricao )
		Loop
	EndIf
	nPasso++
Next nContador

nLinTotal 	:= nPasso				// Numero total de linhas do lancamento
nPasso		:= 0

While nContaLinhas <= nLinTotal

	cDescricao 	:= MemoLine(cTexto, nTamHist, nPasso)

	nPasso++						//  Contador para leitura do Memoline

	If Empty(cDescricao)
		Loop
	EndIf

	If nContaLinhas == 1		// Grava primeira linha de informacoes -> debito/credito etc
		dbSelectArea("TMP")
		nRecTMP	:= Recno()
		nOrdTMP := IndexOrd()
		dbSetOrder(2)
		If TMP->CT2_DC <> "4"
			dbSkip(-1) 			//Procuro pela sequencia, para poder calcular a proxima.
			If !Bof() .And. !Eof()
				If TMP->CT2_DC == "4"
					While TMP->CT2_DC == "4"
						dbSkip(-1)
						If TMP->( Bof() .Or. Eof() )
							EXIT
						ENDIF
					End
					cSeqLan	:= Soma1( TMP->CT2_SEQLAN )
				Else
					cSeqLan := Soma1( TMP->CT2_SEQLAN )
				EndIf
				dbGoto(nRecTMP)
			Else
				cSeqLan := StrZero( 1, Len(CT2->CT2_SEQLAN ) ) //'001'
			Endif
			cSeqHis	:= "001"
		Else
			cSeqLan := TMP->CT2_SEQLAN
			cSeqHis := TMP->CT2_SEQHIS
		Endif

		TMP->CT2_HP			:= cHp
		TMP->CT2_HIST		:= cDescricao
		TMP->CT2_SEQLAN		:= cSeqLan
		TMP->CT2_SEQHIS		:= cSeqHis
		cSeqLanOfi			:= TMP->CT2_SEQLAN
		cSeqHisOfi			:= TMP->CT2_SEQHIS
		dbSetOrder(nOrdTMP)
	Else		// Continuacao de historico
  		dbSelectArea("TMP")
		nRecAnt := Recno()
 		nRecTMP := TMP->(RecCount())	//Total de Reg. gravados no Arq. Temporario

  		dbSkip()					//Pulo p/prox. p/ verificar se eh hist.complem.
		If  !Eof() 		         	//Se nao for fim de arquivo
			If TMP->CT2_DC == '4' .And. TMP->CT2_SEQLAN == cSeqLanOfi
				cProxLin:= TMP->CT2_LINHA
			Else
				TMP->(dbGoTo(nRecTmp))
				cProxLin := Soma1(TMP->CT2_LINHA)
				dbAppend()
				oGetDb:nCount++
			Endif
			cSeqLan := cSeqLanOfi
		Else //	Se for fim de arquivo, volto p/ o registro anterior.
			dbSkip(-1)
			cProxLin := Soma1(TMP->CT2_LINHA)
			dbAppend()
			oGetDb:nCount++
		Endif

		TMP->CT2_FILIAL		:= xFilial()
		TMP->CT2_DATA		:= dData
		TMP->CT2_LOTE		:= cLote
		TMP->CT2_SBLOTE		:= cSubLote
		TMP->CT2_DOC		:= cDoc
		TMP->CT2_LINHA		:= cProxLin
		TMP->CT2_FILORI		:= cFilAnt
		TMP->CT2_EMPORI		:= Substr( cNumEmp, 1, 2 )
		TMP->CT2_HIST		:= cDescricao
		TMP->CT2_DC			:= "4"				// Continuacao de Historico
		TMP->CT2_SEQHIS		:= StrZero(VAL(cSeqHis)+1,3)
		TMP->CT2_SEQLAN		:= cSeqLan
		TMP->CT2_MOEDLC		:= cMoeda
		TMP->CT2_TPSALD		:= cTpSaldo
		TMP->CT2_ROTINA		:= "CTBA102"		// Indica qual o programa gerador
		TMP->CT2_MANUAL		:= "1"				// Lancamento manual
		TMP->CT2_AGLUT		:= "2"				// Nao aglutina
		cSeqHis				:= TMP->CT2_SEQHIS
	EndIf

	nContaLinhas++
EndDo

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ctb050ImpT ³ Autor ³ Simone Mie Sato       ³ Data ³ 09.02.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra totalizadores                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ca050ImpT()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ctb050ImpT()

oDig:Refresh()
oDeb:Refresh()
oCred:Refresh()

Return("")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb102TamHist³ Autor ³ Wagner Mobile Costa ³ Data ³ 30.01.02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera o tamanho do aHeader para montagem do GetDb          ³±±
±±³          ³Para apresentacao correta no Grid                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb102TamHist(lRestaura)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lRestaura = Indica se volta conteudo para do aHeader       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb102TamHist(lRestaura)

Local nPosHist := Ascan(aHeader,{|x|Alltrim(x[2]) = "CT2_HIST"})

DEFAULT lRestaura := .F.

If nPosHist > 0 .And. lRestaura
	aHeader[nPosHist][4] := TamSx3("CT2_HIST")[1]
ElseIf nPosHist > 0
	aHeader[nPosHist][4] += 10
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb102VlRt³ Autor ³ Simone Mie Sato       ³ Data ³ 06.11.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche com o valor a ser rateado.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb102VlRt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Matriz com rateios cadastrados no CT9                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Define se confirmou ou cancelou                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb102VlRt()

Local aSaveArea	:= GetArea()
Local oDlg
Local nValRat	:= 0
Local nOpca		:= 0

nOpca := 0

If cPictVal == Nil
	cPictVal  := PesqPict("CT2","CT2_VALOR")
Endif

DEFINE MSDIALOG oDlg FROM 5, 5 TO 10, 40 TITLE OemToAnsi(STR0013)  //"Escolha Rateio"
@  .5,2 	Say OemToAnsi(STR0014)  //"Valor a Ratear : "
@  .5,7.5 	MSGET nValRat Pict cPictVal Valid Positivo(nValRat)

DEFINE	SBUTTON FROM 25,40 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE 	SBUTTON FROM 25,70 TYPE 2 ACTION (nOpca := 0,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aSaveArea)

Return(nValRat)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb102OutM³ Autor ³ Simone Mie Sato       ³ Data ³ 01.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra os totais de lote/documento de outras moedas.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb102OutM()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc)

Local aSaveArea	:= GetArea()
Local nMoedas	:= 0
Local nDocDeb	:= 0
Local nDocCrd	:= 0
Local nLoteDeb	:= 0
Local nLoteCrd	:= 0
Local nTotLotDeb:= 0
Local nTotLotCrd:= 0
Local nTotDocDeb:= 0
Local nTotDocCrd:= 0
Local nRegTmp	:= TMP->(Recno())

Local cPictVal	:= ""

Local oValores
Local oDlg
Local aArea		:={}
Local aDecCols 	:={}
Local nCont:=1
Local nDecMaior := 0
Local nTamCampo	:=17
Local aColsP	:= {}


Private oDescMoeda
Private oDifLote
Private oDifDoc

aArea:= GetArea()
dbSelectArea("CTO")
dbSetOrder(1)
For nCont := 1 to __nQuantas
	If dbSeek(xFilial("CTO")+StrZero(nCont,2))
		aAdd(aDecCols,CTO->CTO_DECIM)
		If nDecMaior < CTO->CTO_DECIM
			nDecMaior := CTO->CTO_DECIM
		EndIf
	Else
		aAdd(aDecCols,2)
		If nDecMaior < 2
			nDecMaior := 2
		EndIf
	EndIf
Next

RestArea(aArea)

cPictVal:=CTB102Pict(nTamCampo,nDecMaior)

//Na tela de totais de lote e documento de outras moedas, desabilita a tecla F5
SET KEY VK_F5 to
SET KEY VK_F4 to

For nMoedas	:= 1 to __nQuantas
	cMoedAtu := StrZero(nMoedas,2)

	aRetCT6 := CtbSaldoLote(cLote,cSublote,dDataLanc,cMoedAtu)

	If !Empty(aRetCT6[1]) .Or. !Empty(aRetCT6[2])
		nLoteDeb	+= aRetCT6[1]
		nLoteCrd	+= aRetCT6[2]
	Else					/// Caso tenha algum problema com atualização do CT6
		dbSelectArea("CT2") /// Totaliza Lote pelo proprio CT2.
		aAreaCt2 := GetArea()
		cFilCt2 := xFilial("CT2")
		dbSetOrder(1)
		If dbSeek(cFilCt2+DTOS(dDataLanc)+cLote+cSublote,.F.)

			While CT2->(!Eof()) .and. CT2->CT2_FILIAL == cFilCt2 .AND. CT2->CT2_DATA == dDataLanc .AND.;
				CT2->CT2_LOTE == cLote .AND. CT2->CT2_SBLOTE == cSubLote

				If CT2->CT2_MOEDLC == cMoedAtu
					If CT2->CT2_DC$("1/3")
						nLoteDeb += CT2->CT2_VALOR
					EndIf
					If CT2->CT2_DC$("2/3")
						nLoteCrd += CT2->CT2_VALOR
					EndIf
				EndIf

				CT2->(dbSkip())
			EndDo
		Else
			nLoteDeb	:= 0
			nLoteCrd	:= 0
		EndIf
		RestArea(aAreaCt2)
	EndIf

	//Subtrair do total do lote o valor do documento corrente, pois esse documento sera somado
	//a partir do TMP => GetDb.

	nTotLotDeb	:= Round(nLoteDeb,aDecCols[nMoedas])
	nTotLotCrd	:= Round(nLoteCrd,aDecCols[nMoedas])

	dbSelectArea("TMP")
	dbGotop()
	While !Eof()
		If !TMP->CT2_FLAG	//Se a linha nao estiver deletada
			If TMP->CT2_DC $ "1/3"
				If cMoedAtu == '01'
					nTotDocDeb	+= TMP->CT2_VALOR
				Else
					nTotDocDeb	+= &("TMP->CT2_VALR"+cMoedAtu)
				EndIf
			EndIf

			If TMP->CT2_DC $ "2/3"
				If cMoedAtu == '01'
					nTotDocCrd	+= TMP->CT2_VALOR
				Else
					nTotDocCrd	+= &("TMP->CT2_VALR"+cMoedAtu)
				EndIf
			EndIf
		EndIf
		dbSkip()
	EndDo

	nTotDocDeb	:= Round(nTotDocDeb,aDecCols[nMoedas])
	nTotDocCrd	:= Round(nTotDocCrd,aDecCols[nMoedas])

	AADD(aColsP,{cMoedAtu,nTotDocDeb,nTotDocCrd,nTotLotDeb,nTotLotCrd})

	nTotDocDeb	:= 0
	nTotDocCrd	:= 0
	nTotLotDeb	:= 0
	nTotLotCrd	:= 0
	nDocDeb		:= 0
	nDocCrd		:= 0
	nLoteDeb	:= 0
	nLoteCrd	:= 0
Next

//ListBox para mostrar os valores em outras moedas
DEFINE MSDIALOG oDlg FROM	88,31 TO 310,700 TITLE STR0041 PIXEL  //"Totais do lote e documento (outras moedas)"

@ 1.4, 028 MSGET dDataLanc	When .F. SIZE 40, 10 OF oDlg PIXEL
@ 1.4, 090 MSGET cLote    	When .F. SIZE 20, 10 OF oDlg PIXEL
@ 1.4, 150 MSGET cSubLote	When .F. SIZE 10, 10 OF oDlg PIXEL
@ 1.4, 210 MSGET cDoc     	When .F. SIZE 20, 10 OF oDlg PIXEL

@ 3.8, 010 SAY STR0008+ ": "    SIZE 21, 7 OF oDlg PIXEL  COLOR CLR_HBLUE//"Data"
@ 3.8, 075 SAY STR0009+ ": "    SIZE 22, 7 OF oDlg PIXEL  COLOR CLR_HBLUE//"Lote"
@ 3.8, 125 SAY STR0028+ ": "    SIZE 55, 7 OF oDlg PIXEL  COLOR CLR_HBLUE//"SubLote
@ 3.8, 190 SAY STR0010+ ": "    SIZE 23, 7 OF oDlg PIXEL  COLOR CLR_HBLUE//"Documento"

nAddWidth := 3	//10
@ 1.3,.9 LISTBOX oValores VAR cValores Fields;
	HEADER STR0019,;				//"Moeda"
	STR0042 + STR0016,; 			//"Total doc. Debito"
	STR0042 + STR0017,;				//"Total doc. Credito"
	STR0043 + STR0016,;  			//"Total Lote Debito"
	STR0043 + STR0017,;  			//"Total Lote Debito"
	COLSIZES 20,;
	GetTextWidth(0,"BBBBBBBB")+nAddWidth,;
	GetTextWidth(0,"BBBBBBBB")+nAddWidth,;
	GetTextWidth(0,"BBBBBBBB")+nAddWidth,;
	GetTextWidth(0,"BBBBBBBB")+nAddWidth,;
	SIZE 300,80 OF oDlg
	oValores:SetArray(aColsP)
	oValores:bLine := { || {aColsP[oValores:nAt,1],;
							Trans(aColsP[oValores:nAt,2],cPictVal),;
							Trans(aColsP[oValores:nAt,3],cPictVal),;
							Trans(aColsP[oValores:nAt,4],cPictVal),;
							Trans(aColsP[oValores:nAt,5],cPictVal)}}

@ 100, 010 SAY STR0044   SIZE 100, 7 OF oDlg PIXEL  COLOR CLR_HBLUE//"Diferenca em "
@ 100, 070 SAY STR0045   SIZE 10, 7 OF oDlg PIXEL  COLOR CLR_HBLUE//" do "
@ 100, 085 SAY UPPER(STR0010)   + ": " SIZE 60, 7 OF oDlg PIXEL  COLOR CLR_HBLUE//" Lote "
@ 100, 170 SAY UPPER(STR0009)   + ": " SIZE 60, 7 OF oDlg PIXEL  COLOR CLR_HBLUE//" Docto "

//			cMoeda				 ,oDlg,lInit,nDocDeb				,nDocCrd				,nLoteDeb				,nLoteCrd
Ctb102AtuM(aColsP[oValores:nAt,1],oDlg,.T.	,aColsP[oValores:nAt,2],aColsP[oValores:nAt,3]	,aColsP[oValores:nAt,4]	,aColsP[oValores:nAt,5])

oValores:bChange := {|| Ctb102AtuM(aColsP[oValores:nAt,1],oDlg,.F.,aColsP[oValores:nAt,2],;
		aColsP[oValores:nAt,3],	aColsP[oValores:nAt,4],aColsP[oValores:nAt,5])}

ACTIVATE MSDIALOG oDlg  CENTERED

dbSelectArea("TMP")
dbGoto(nRegTmp)

aColsP	:= {}

//SetKey( VK_F5 , { || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc) })
SetKey( VK_F5 , { || CTB105Flt (oGetDb,.F.                   ) })
SetKey( VK_F4 , { || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc) })

RestArea(aSaveArea)

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb102AtuM³ Autor ³ Simone Mie Sato       ³ Data ³ 02.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza rodape da tela de totais de lote/doc outrs moedas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb102AtuM()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb102AtuM(cMoeda,oDlg,lInit,nDocDeb,nDocCrd,nLoteDeb,nLoteCrd)

Local aSaveArea		:= GetArea()
Local cDescMoeda	:= ""
Local nDifLote		:= 0
Local nDifDoc		:= 0

If cPictVal == Nil
	cPictVal  := PesqPict("CT2","CT2_VALOR")
Endif

dbSelectArea("CTO")
dbSetOrder(1)
If MsSeek(xFilial()+cMoeda)
    cDescMoeda	:= CTO->CTO_DESC
EndIf

nDifDoc	:= nDocCrd-nDocDeb
nDifLote:= nLoteCrd-nLoteDeb

If lInit
	@ 100,50  SAY oDescMoeda PROMPT cDescMoeda SIZE 100, 7 OF oDlg PIXEL  COLOR CLR_RED//"Diferenca em "
	@ 100,110 SAY oDifDoc	PROMPT nDifDoc Picture cPictVal SIZE 100, 20 OF oDlg PIXEL COLOR CLR_RED
	@ 100,200 SAY oDifLote  VAR nDifLote Picture cPictVal SIZE 100, 20 OF oDlg PIXEL COLOR CLR_RED
Else
	oDescMoeda:SetText(cDescMoeda)
	oDescMoeda:Refresh()
	oDifLote:SetText(nDifLote)
	oDifLote:Refresh()
	oDifDoc:SetText(nDifDoc)
	oDifDoc:Refresh()
EndIf

RestArea(aSaveArea)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb102PictM³ Autor ³ Paulo Augusto        ³ Data ³ 11.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria Picture de um campo numerico                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB102Pict(nTamCampo,nDecMaior)                             ³±±
±±³          ³nTamCampo = Tamanho Total do Campo                          ³±±
±±³          ³nDecimais = Qtd. de casas decimais                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CTB102Pict(nTamCampo,nDecimais)

Local nTam:= nTamCampo
Local nDec:= nDecimais
Local nTamInt:= 0
Local nValInt:= 0
Local nMascInt:= 0
Local nMascPor:=0
Local cPicture :="@E "
Local nI :=1

nTamInt:= nTam - nDec
nValInt:= nTamInt / 3
nMascInt:= Int(nValInt)
nMascPor:=Round((nValInt - nMascInt)*3,1)

If nMascPor >0
	cPicture :=cPicture  + Replicate("9",nMascPor)+ ","
EndIf

For nI:=1 to nMascInt
	cPicture :=  cPicture + "999"
	If nI <> nMascInt
    	cPicture :=  cPicture + ","
	EndIf
Next
If  nDec > 0
	cPicture :=  cPicture + "." + Replicate("9",nDec)
EndIf

Return(cPicture)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb102Alert ³ Autor ³ Edson Maricate       ³ Data ³ 17.12.2005        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alerta ao usuário sobre a confirmação dos lançamentos contábeis      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb102Alert                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaCtb 			                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb102Alert()
Local lRet := .T.

If !IsBlind()
	lRet := Aviso(STR0060,STR0061,{STR0062,STR0063},2) == 1 //"Atenção!"###"Confirma exclusão dos lançamentos selecionados ?"###"Sim"###"Não"
Else
	lRet := .T.
EndIf

Return (lRet)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb102Lcto  ³ Autor ³ Edson Maricate       ³ Data ³ 17.12.2005        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chama a função de visualização do lançamento posicionado na GetDB     ³±±
±±³          ³utilizando a tela de visualização do CTBA101.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb102Lcto                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaCtb 			                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb102Lcto()
Local aArea		:= GetArea()
Local aAreaCT2	:= CT2->(GetArea())

dbSelectArea("CT2")
dbSetOrder(1)
MsGoto(TMP->CT2_RECNO)		// Posiciono no RECNO do CT2
CTBA101(2)						// Chama o CTBA101 para visualização


RestArea(aAreaCT2)
RestArea(aArea)
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb102Repla ³ Autor ³ Edson Maricate       ³ Data ³ 17.12.2005        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Replicar o conteudo do campo posicionado nas linhas da GetDb         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb102Repla                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb 			                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb102Repla()
Local aArea	:= GetArea()
Local aAreaTMP	:= TMP->(GetArea())
Local nRecTmp	:= TMP->(Recno())
Local aRet	:= {}
Local cCampo := AllTrim(aHeader[oGetDB:oBrowse:nColPos][2])
Local cConteudo := TMP->(&cCampo)
Local nPosCpo	:= TMP->(FieldPos(cCampo))

/// GUARDA CONTEUDO DOS MV_PAR JÁ ABERTOS (SE HOUVER) - Chamada de ParamBox na tela função CTb102Repla (muda os mv_pars)
Local aMvPars := GuardPars()

dbSelectArea("TMP")
If !(cCampo$"CT2_LINHA|CT2_DC")
	If Parambox({ 	{5, STR0064, .F., 160,,.F.},; //"Replicar conteúdo do campo em todas linhas anteriores"
						{5, STR0065, .T., 160,,.F.},; //"Replicar conteúdo do campo em todas linhas abaixo"
						{7, STR0066,"CT2",""}		}, STR0067+AllTrim(aHeader[oGetDB:oBrowse:nColPos][1]), aRet)  //"Condição"###"Replicar "


		If Aviso(STR0060,STR0068,{STR0062,STR0063},2)==1 //"Atenção!"###"Confirma substituição do conteúdo nos campos selecionados ?"###"Sim"###"Não"
			If aRet[1]
				dbSelectArea("TMP")
				dbSetOrder(0)
				dbGotop()
				While !Eof() .And. RecNo() <= nRecTmp
					If !Empty(aRet[3]) .And. !&(aRet[3])
						dbSkip()
						Loop
					EndIf
					If TMP->CT2_DC == "4" // Continuação de historico
						If UPPER(cCampo) <> "CT2_TPSALD"
							dbSkip()
							Loop
						EndIf
					Endif
					RecLock("TMP",.F.)
					FieldPut(nPosCpo,cConteudo)
					If TMP->(FieldPos('MODIFIED')) > 0
						TMP->MODIFIED := 1
					Endif
					If (cCampo $ "CT2_DC,CT2_DEBITO,CT2_CREDIT,CT2_CCD,CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_CLVLDB,CT2_CLVLCR,CT2_TPSALD,CT2_DTLP";
						.Or.  "CT2_VLR" $ cCampo) .And. TMP->(FieldPos('ATUSALDO')) > 0
						TMP->ATUSALDO := 1
					Endif

					MsUnlock()
					dbSkip()
				End
			EndIf
			If aRet[2]
				dbSelectArea("TMP")
				dbSetOrder(0)
				dbGoto(nRecTmp)
				While !Eof()
					If !Empty(aRet[3]) .And. !&(aRet[3])
						dbSkip()
						Loop
					EndIf
					If TMP->CT2_DC == "4" // Continuação de historico
						If UPPER(cCampo) <> "CT2_TPSALD"
							dbSkip()
							Loop
						EndIf
					Endif
					RecLock("TMP",.F.)
					FieldPut(nPosCpo,cConteudo)
					If TMP->(FieldPos('MODIFIED')) > 0
						TMP->MODIFIED := 1
					Endif
					If (cCampo $ "CT2_DC,CT2_DEBITO,CT2_CREDIT,CT2_CCD,CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_CLVLDB,CT2_CLVLCR,CT2_TPSALD,CT2_DTLP";
						.Or.  "CT2_VLR" $ cCampo) .And. TMP->(FieldPos('ATUSALDO')) > 0
						TMP->ATUSALDO := 1
					Endif
					MsUnlock()
					dbSkip()
					If (cCampo $ "CT2_VALOR,CT2_VLR01,CT2_VLR02,CT2_VLR03,CT2_VLR04,CT2_VLR05")
                    	ValidaValor(cConteudo)
                    Endif
				End
			EndIf
			oGetDB:oBrowse:Refresh()
		EndIf
	EndIf
EndIf

RestPars(aMvPars)

RestArea(aAreaTMP)
RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ct102EstLt  ³ Autor ³ Simone Mie Sato      ³ Data ³ 03.06.2006        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Estorno de Lote de Lancamentos contabeis								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct102EstLt                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaCtb 			                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct102EstLt(nOpc,dDataLanc,cLote,cSubLote,cDoc,nTotInf,lSeqCorr,cCodSeq)

Local aSaveArea	:= GetArea()
Local aCampos		:= {}
Local aAltera		:= {}
Local aQuais		:= {}
Local aAuxQuais 	:= {}
Local aDocRej		:= {} // Documentos rejeitados
Local cArq1		:= ""
Local cArq2		:= ""
Local cCadastro	:= STR0071	//"Estorno de lancamento por lote"
Local cVarQ 	:= "  "
Local cDescInc	:= ""
Local dDtIniEst	:= mv_par01
Local dDtFimEst	:= mv_par02
Local cLoteIni	:= mv_par03
Local cLoteFim	:= mv_par04
Local cSbLotIni	:= mv_par05
Local cSbLotFim	:= mv_par06
Local cDocIni	:= mv_par07
Local cDocFim	:= mv_par08
Local lDataOri	:= Iif(mv_par09 == 1,.T.,.F.)
Local dDataEst	:= CTOD("  /  /  ")
Local lDataOk 	:= .T.
Local cTpSaldo	:= ""
Local nOpca
Local nContDoc	:= 0
Local lRet		:= .T.
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
Local oNo 		:= LoadBitmap( GetResources(), "LBNO")
Local oDlg
Local oQual
Local lVldTps 	:= SuperGetMv("MV_CTBCTG",.T.,.F.) // Habilita validação por amarração entre calendário x moeda x tipo de saldo
Local aPeriodo	:= {}
Local cPerioro	:= ""

Private lImpRel	:= Iif(mv_par14 == 1,.T.,.F.)
Private oDescEnt,oDig,oDeb,oCred,oGetDB
Private OPCAO

Private aHeader	:= {}
Private aColsP	:= {}
Private __aCT2LC:= {}

Default lSeqCorr := .F.
Default cCodSeq  := ' '

//Se não for para gerar o lançamento de estorno na mesma data do lançamento original,será gerado
//na data preenchida na pergunta "Data dos lanc. estorno"
If !lDataOri
	dDataEst	:= mv_par10
EndIf

//Criar arquivo de trabalho para relatorio de inconsistencia.
IF lImpRel
 Ct102CrRel()
EndIF

If lVldTps
	cQuery := " SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD, MIN(R_E_C_N_O_) MINRECNO "
Else
	cQuery := " SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC, MIN(R_E_C_N_O_) MINRECNO "
EndIf
cQuery += " FROM "+RetSqlName("CT2")
cQuery += " WHERE CT2_FILIAL = 	'"+xFilial("CT2")+"' "
If dDtIniEst == dDtFimEst
	cQuery += "   AND CT2_DATA 	 = '"+DTOS(dDtIniEst)+"' "
Else
	cQuery += "   AND CT2_DATA 	 >= '"+DTOS(dDtIniEst)+"' "
	cQuery += "   AND CT2_DATA 	 <= '"+DTOS(dDtFimEst)+"' "
EndIf
If cLoteIni == cLoteFim
	cQuery += "   AND CT2_LOTE 	 = '"+cLoteIni+"' "
Else
	cQuery += "   AND CT2_LOTE 	 >= '"+cLoteIni+"' "
	cQuery += "   AND CT2_LOTE 	 <= '"+cLoteFim+"' "
EndIf
If cSbLotIni == cSbLotFim
	cQuery += "   AND CT2_SBLOTE = '"+cSbLotIni+"' "
Else
	cQuery += "   AND CT2_SBLOTE >= '"+cSbLotIni+"' "
	cQuery += "   AND CT2_SBLOTE <= '"+cSbLotFim+"' "
EndiF
If cDocIni == cDocFim
	cQuery += "   AND CT2_DOC 	 = '"+cDocIni+"' "
Else
	cQuery += "   AND CT2_DOC 	 >= '"+cDocIni+"' "
	cQuery += "   AND CT2_DOC 	 <= '"+cDocFim+"' "
EndIf

// filtra os lancamentos complementares
If CTBLCUso()
	cQuery += "   AND CT2_ROTINA <> '__CTBLC__ '"
Endif

cQuery += "   AND D_E_L_E_T_ = ' ' "
If lVldTps
	cQuery += "   GROUP BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD"
	cQuery += "   ORDER BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD"
Else
	cQuery += "   GROUP BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC"
	cQuery += "   ORDER BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC"
EndIf

cQuery := ChangeQuery(cQuery)

If Select("CT2ESTLT") > 0
	dbSelectArea("CT2ESTLT")
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CT2ESTLT",.T.,.T.)

TcSetField("CT2ESTLT","CT2_DATA","D",8					  ,0)
TcSetField("CT2ESTLT","MINRECNO","N",17 				  ,0)

dbSelectArea("CT2ESTLT")

While CT2ESTLT->(!Eof())

	dbSelectArea("CT2")
	CT2->(dbGoto(CT2ESTLT->MINRECNO))

	If lVldTps
		cTpSaldo := CT2->CT2_TPSALD
	Else
		cTpSaldo := ""
	EndIf
	//Se for para gerar o lançamento de estorno na mesma data do lançamento original
	If nOpc == 5  //exclusao
		cPerioro := Alltrim(STR(Month(CT2->CT2_DATA))) + Alltrim(STR(Year(CT2->CT2_DATA)))
		If !(aScan(aPeriodo,{|x|x == cPerioro }) > 0)
			dDataEst	:= CT2->CT2_DATA
			lDataOk 	:= CtbValiDt(nOpc,dDataEst,,cTpSaldo,lVldTps)
			AADD(aPeriodo, cPerioro)
		EndIf
	ElseIf 	nOpc == 6  //estorno

		If lDataOri
			dDataEst	:= CT2->CT2_DATA
			lDataOk 	:= CtbValiDt(nOpc,dDataEst,,cTpSaldo,lVldTps)
		Else
			dDataEst	:= mv_par10
			lDataOk 	:= CtbValiDt(nOpc,dDataEst,,cTpSaldo,lVldTps)
		EndIf
		If lSeqCorr
			//tratamento para bloquear a inclusão do estorno
			If !CTBVlSeqCr(dDataEst,.F.)
				lDataOk	:= .F.
			EndIf
		EndIf

	EndIf

	//Verificação da Data.
	If lDataOk
		If _lFLTESTLT
			lRet := ExecBlock("FLTESTLT",.F.,.F.)
			If lRet
				Aadd(aQuais,{.T.,DTOC(CT2->CT2_DATA)+SPACE(1)+CT2->CT2_LOTE+SPACE(1)+CT2->CT2_SBLOTE+SPACE(1)+CT2->CT2_DOC})
			EndIf
		Else
			Aadd(aQuais,{.T.,DTOC(CT2->CT2_DATA)+SPACE(1)+CT2->CT2_LOTE+SPACE(1)+CT2->CT2_SBLOTE+SPACE(1)+CT2->CT2_DOC})
		EndIF
	Else
		cDescInc	:=  IIF(lVldTps,STR0106,STR0075)+STR0008+": "+DTOC(dDataEst)+IIF(lVldTps," "+STR0107+cTpSaldo,"")    //"Período bloqueado.Verficar calendário contábil. "
		If aScan(aDocRej ,{ | Doc | Doc == DTOC(CT2->CT2_DATA)+SPACE(1)+CT2->CT2_LOTE+SPACE(1)+CT2->CT2_SBLOTE+SPACE(1)+CT2->CT2_DOC } ) <= 0
			Aadd(aDocRej,DTOC(CT2->CT2_DATA)+SPACE(1)+CT2->CT2_LOTE+SPACE(1)+CT2->CT2_SBLOTE+SPACE(1)+CT2->CT2_DOC)
		EndIf
		iF lImpRel	
			Ct102GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,cDescInc)
		EndIf	
	EndIf
	CT2ESTLT->(dbSkip())
EndDo

For nContDoc := 1 To Len(aQuais)
	If aScan(aDocRej,{ | Doc | Doc == aQuais[nContDoc][2] } ) <= 0
		Aadd(aAuxQuais,{.T.,aQuais[nContDoc][2]})
	EndIf
Next nContDoc

aQuais := aAuxQuais

dbSelectArea("CT2ESTLT")
dbCloseArea()


//Monta LISTBOX com os lotes/docs escolhidos pelo usuario para serem estornados.
If Len(aQuais) > 0 .And. VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc)

	nOpca := 0

	If !_lAutomato
		DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,40 OF oMainWnd

		DEFINE FONT oFnt1	NAME "Arial" 			Size 10,12 BOLD
		@ 0.3,.5 Say STR0071 FONT oFnt1 COLOR CLR_RED	  //"Estorno de lancamento por lote"

		@ 13,04 BUTTON STR0072 PIXEL OF oDlg SIZE 50,11; //"Inverte Selecao"
		ACTION (	aEval(oQual:aArray, {|e| 	e[1] := ! e[1] }),;
		oQual:Refresh())

		@ 2,.5  LISTBOX oQual VAR cVarQ Fields HEADER "",STR0073; //"Data/Lote/Sublote/Documento"
		SIZE 150,100 ON DBLCLICK ;
		(aQuais:=CT102Troca(oQual:nAt,aQuais),oQual:Refresh()) NOSCROLL	//"Lotes a serem estornados"
		oQual:SetArray(aQuais)
		oQual:bLine := { || {if(aQuais[oQual:nAt,1],oOk,oNo),aQuais[oQual:nAt,2]}}

		DEFINE SBUTTON FROM 130.5,80	TYPE 1 ACTION (nOpca := 1,IF(ct102OK(aQuais),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
		DEFINE SBUTTON FROM 130.5,110	TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

		ACTIVATE MSDIALOG oDlg CENTERED

	Else
		nOpca	:= 1
	Endif

	If nOpca == 1

		If _lVCTB102EST // opção de validação do estorno do lançamento
			If ! ExecBlock("VCTB102EST",.F.,.F.,{dDataLanc,cLote,cSubLote,cDoc,nTotInf})
			   Return .F.
			EndIF
		EndIf

		//Criar arquivo de trabalhO TMP => alimentar GETDB
		If _lForcCrTmp
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Getdados para Lan‡amentos Cont beis                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCampos := Ctb105Head(@aAltera,/*lSimula*/, _lForcHead )
			_aHeadCtb := aClone( aHeader )  //carrega variavel static com clone de aHeader
			_aAltera  := aClone( aAltera )  //carrega variavel stati com clone a aAltera
			Ctb105Cria(aCampos,@cArq1,@cArq2, _lForcCrTmp )
			_aCampos := aClone( aCampos )   //carrega variavel static com clone de aCampos
			Ctb105STmp()                             //FUNCAO CTBA105 PARA SETAR ALIAS TMP
			_lForcHead := .F.
			_lForcCrTmp := .F.
		Else
			//carrega as variaveis locais/private com conteudo das variaveis static
			aCampos := aClone( _aCampos )  //esta variavel eh retorno da funcao Ctb105Cria
			aAltera := aClone( _aAltera )  //esta variavel é utilizada  na MSGETDB 
			aHeader := aClone( _aHeadCtb ) //variavel aHeader é utilizada internamente na MSGETDB                              
		EndIf
	
		lFirtP := .T.
		lGrvF  := .T.
	
		fwMsgRun(,{||Ct102estFor(nOpc,dDataLanc,cLote,cSubLote,cDoc,nTotInf,aQuais,aCampos,lSeqCorr,cCodSeq)},"Processando","Excluindo Registros..")
			
		//no caso de estorno em lote fecha o arquivo TMP pois CTBA190 cria outro TMP e seta variaveis para recriar TMP de lancto 
		dbSelectArea( "TMP" )
		dbCloseArea()
		_lForcHead := .T.
		_lForcCrTmp := .T.

		dbSelectArea( "CT2" )
		
		If lPar15
			If MV_PAR16 == 1 
				fwMsgRun(,{||	CTBA190(.T.,dDtIniEst,Iif (!lDataOri .And. (dDataEst > dDtFimEst), dDataEst, dDtFimEst)	,cFilAnt,cFilAnt,'1',.F.) },"Processando","Recalculando Saldo .. " )
			EndIF
		EndIF
		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Lancamento de complementar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If CTBLCUso()
			If (Type("__aCT2LC") == "A") .And. !Empty(__aCT2LC)
				CTBLCGerLC()
			Endif
		Endif

		DeleteObject(oOk)
		DeleteObject(oNo)
	EndIf
Else
	If !IsBlind()					///Caso nao tenha selecionado nenhum registro.
		MsgInfo(STR0088,STR0076)
	EndIf
	lImpRel := .F.
EndIf

If lImpRel
	C102ImpRel()
EndIf
If _oCTBA1021 <> Nil
	_oCTBA1021:Delete()
	_oCTBA1021 := Nil
Endif

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   Ct102estFor ³ Autor ³ Microsiga										 ³ Data ³  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função de exclusão dos dados do grava				               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ct102estFor(nOpc,dDataLanc,cLote,cSubLote,cDoc,nTotInf,aQuais,aCampos,lSeqCorr,cCodSeq)

Local nCont := 0
Local dDataOri:= "" 
Local nSomaPos:= 0
Local cLoteOri:= ""
Local cSbloteOri := ""
Local cDocOri:= ""
Local cChaveOri:= ""
Local lContinua:= .T.
Local lDataOri	:= Iif(mv_par09 == 1,.T.,.F.)
Local dDataEst	:= CTOD("  /  /  ")
Local cLoteEst	:= mv_par11
Local cSubLtEst	:= mv_par12
Local cDocEst	:= mv_par13
Local CTF_LOCK	:= 0
Local lFirst	:= .T.
Local lRpcOk	:= .T.
Local lOk		:= .T.
Local cLinhaAlt	:= Replicate("0",Len(CT2->CT2_LINHA)-1)+"1"
Local cModoClr	:= Alltrim(GetNewPar("MV_CTBAPLA","1"))	//"1"=Inativo,"2"=Pergunta,"3"=Automatico c/Alertas,"4"=Automático sem alertas
Local lContab := .T.
Local lEaiCt102 := FwIsInCallStack("CTBI102")
Local lImpRel  := IiF(MV_PAR14 == 1,.T.,.F.)
Local cDocAux 	:= ""
Local cLoteAux 	:= ""
Local cSubLtAux 	:= ""

Local dDataAux 	:= CTOD(" / / ")
Local cSeqCorr  := ""


Default nOpc := 0 
Default dDataLanc := cTOD("  /  /    ")
Default cLote := ""
Default cSubLote := ""
Default cDoc     := ""
Default nTotInf := 0 
Default aQuais := {}
Default aCampos := {}
Default lSeqCorr := .F.
Default cCodSeq :=' '

If lSeqCorr .and. nOpc == 6
	cSeqCorr := CTBSQCor( "" ,cCodSeq, dDataLanc )
Endif



	For nCont	:= 1 to Len(aQuais)
	
			If aQuais[nCont][1]
				dDataOri	:= CTOD(Subs(aQuais[nCont][2],1,10))

				nSomaPos := 0
				If ( Len( Dtoc( dDataOri ) ) == 10 ) // data com 10 posicoes ( xx/xx/xxxx )
					nSomaPos := 2	// seto a variavel de soma para 2
				Endif

				cLoteOri	:= Subs( aQuais[nCont][2], 10 + nSomaPos, 6 )
				cSbloteOri	:= Subs( aQuais[nCont][2], 17 + nSomaPos, 3 )
				cDocOri		:= Subs( aQuais[nCont][2], 21 + nSomaPos, 6 )

				cChaveOri	:= xFilial( "CT2" ) + DTOS( dDataOri ) + cLoteOri + cSbloteOri + cDocOri    // chave de busca do documento contabil

				//Se for para gerar o lançamento de estorno na mesma data do lançamento original
				If lDataOri
					dDataEst	:= dDataOri
				Else
					dDataEst	:= mv_par10
				EndIf

				dbSelectArea("CT2")
				dbSetOrder(1)
				If MsSeek(cChaveOri)
					cLoteOri	:= ''
					cSbloteOri	:= ''
					cDocOri		:= ''

					If  _lCTB102ESTL
						lOk := ExecBlock("CTB102ESTL",.F.,.F.,{nOpc})
					EndIf

					If lOk
						cLoteOri	:= CT2->CT2_LOTE
						cSbLoteOri	:= CT2->CT2_SBLOTE
						cDocOri		:= CT2->CT2_DOC

						//Verificar se existe alguma entidade bloqueada do documento
						//O nOpc eh passado como 5 de proposito, para entrar na validacao.
						If nOpc ==5 .Or. (nOpc == 6 .And. CtbTmpBloq(dDataOri,cLoteOri,cSbLoteOri,cDocOri,5,.F.))

							If  CtbVldLP(dDataOri,cLoteOri,cSbLoteOri,cDocOri,nOpc,.F.)

								If nOpc == 6	//Se for estorno de lançamento contabil por lote
									lContinua := Ctb102Carr(nOpc,@dDataEst,cLoteEst,cSubLtEst,cDocEst,@cLinhaAlt,funName(),cCodSeq)
								Else
									lContinua := Ctb102Carr(nOpc,CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,@cLinhaAlt)
								EndIf

								//Validacao das entidades contábeis => estorno de lançamentos contábeis
								//Na exclusão, nao verifica.
								If nOpc == 6
									lRpcOk	:= CTB105Rpc(.F.)
								Else
									lRpcOk	:= .T.
								EndIf

								If lRpcOK

									If  _lANCTB102GR
										If nOpc == 6
											ExecBlock("ANCTB102GR",.F.,.F.,{ nOpc,dDataEst,cLoteEst,cSubLtEst,cDocEst }  )
										Else
											ExecBlock("ANCTB102GR",.F.,.F.,{ nOpc,CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC }  )
										EndIf
									Endif

									If nOpc == 6
										
										lContinua := Ctb102PxEst( @dDataEst,@cLoteEst,@cSubLtEst,@cDocEst,@CTF_LOCK)
										
										lContab    := !(lPar15 .and. MV_PAR15 == 2)
										
										lCtba190   := (lPar15 .and. MV_PAR16==1 )
										
										If lContinua
											CTBGrava(nOpc,dDataEst ,cLoteEst,cSubLtEst,cDocEst,.F.,"",__lCusto,__lItem,__lCLVL,nTotInf,'CTBA102',,,cEmpAnt,cFilAnt,,,,cModoClr,,,cSeqCorr,,,,,,,,,,,.F.,lFirst,lContab,lCtba190)	
										EndIF
										
										CTF->(dbGoto(CTF_LOCK))
										If Intransact()
									    	CTF->(MsUnlock())
										Else
											CTF->(MsRUnlock())
										Endif
										lFirst:= .F.
										cDescInc	:= STR0082 + space(1)+STR0008+":"+DTOC(dDataEst)+space(1)+STR0009+":"+cLoteEst+space(1)+STR0083+":"+cSubLtEst+space(1)+STR0010+":"+cDocEst//"Estorno gerado com sucesso."
									Else
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ BOPS 00000117527 - Tratamento para nao repetir as mensagens de confir ³
										//³ mação de exclusão para cada documento na função CT2ClearLA()          ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										IF cModoClr == "2" .OR. cModoClr == "3" // 2- Perguntar ou 3- Automático com Alertas
											IF ! MSGYesNo( STR0092, STR0093 ) //"Exibir mensagens de atualização de flags de contabilização durante o processamento?" - // Exclusão por Lote
												cModoClr := "4"   // 4- Automático sem alertas
											ENDIF
										ENDIF

									  	dDataAux := CT2->CT2_DATA
										cLoteAux := CT2->CT2_LOTE
									 	cSubLtAux := CT2->CT2_SBLOTE
										cDocAux := CT2->CT2_DOC
										lContab := !(lPar15 .and. MV_PAR15 == 2)
										lCtba190 := (lPar15  .and. MV_PAR16 == 1)
										
										If _lNewSemaf == NIL
											_lNewSemaf := CTF->(FieldPos('CTF_USADO'))>0
										EndIf
										//funcao para exclusao poder ser usado CTF novamente msm numero
										If nOpc == 5 .And. _lNewSemaf  //exclusao - colocado aqui tb pois qdo soh tem moeda 01 a destrava eh chamada dentro da CtbGrava
											If FindFunction("CtSetRcCTF") //CONFIRMADO EXCLUSAO - VERSAO 12.1.33
												CtSetRcCTF(.T.)  //QUANDO EXCLUIR SETA PARA UNLOCKDOC COLOCAR CAMPO CTF_USADO = 'R' --> PODE SER RECUPERADO ESTE NUMERO
											EndIf
										Endif

										CTBGrava(nOpc,dDataAux,cLoteAux,cSubLtAux,cDocAux,.F.,"",__lCusto,__lItem,__lCLVL,nTotInf,'CTBA102',,,cEmpAnt,cFilAnt,,,,cModoClr,,,,,,,,,,,,,,.F.,lFirst,lContab,lCtba190)
										lFirst:= .F.
										cDescInc	:= STR0087 //"Exclusão realizada com sucesso."
										//funcao para verificar se existe CTF e caso ainda tenha 
										//excluir ou marcar como recuperavel o numero na versao 12.1.33
										Ct102RcCTF(nOpc, dDataAux,cLoteAux,cSubLtAux,cDocAux)
								   		//Envia a mensagem única de Exclusão
								   		If lEaiCt102
											CT102EAI( dDataAux, cLoteAux, cSubLtAux, cDocAux,,, nOpc )											
										EndIf	
									EndIf
									//Grava no arq. de trabalho que o estorno foi gerado com sucesso.
									iF lImpRel
										Ct102GrInc(DTOC(dDataOri),cLoteOri,cSbLoteOri,cDocOri,cDescInc)
									EndIf	
								Else
									cDescInc	:= STR0084 //"Verificar se as entidades contábeis estão corretas."
									//Grava no arq. de trabalho que o estorno foi gerado com sucesso.
									If nOpc == 6
										iF lImpRel
											Ct102GrInc(DTOC(dDataOri),cLoteOri,cSbLoteOri,cDocOri,cDescInc)
										EndIF	
									Else
										iF lImpRel
											Ct102GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,cDescInc)
										EndIf
									EndIf
								EndIf

								//limpa arquivo temporario para quando voltar para outro documento 
								dbSelectArea( "TMP" )
								If Alias() == "TMP"
									Ctb_ZapTmp() //Zap
								EndIf
								TMP->( dbGotop() )

								dbSelectArea( "CT2" )
								
								If _lDPCTB102GR
									If nOpc == 6
										ExecBlock("DPCTB102GR",.F.,.F.,{ nOpc,dDataEst,cLoteEst,cSubLtEst,cDocEst } )
									Else
										ExecBlock("DPCTB102GR",.F.,.F.,{ nOpc,dDataAux,cLoteAux,cSubLtAux,cDocAux } )											
									EndIf
								Endif
							Else
								cDescInc	:= STR0089 //"Lançcamentos de apuração nao poderão ser excluidos ou estornados.
								//Grava no arq. de trabalho que o estorno foi gerado com sucesso.
								If lImpRel
									Ct102GrInc(DTOC(dDataOri),cLoteOri,cSbLoteOri,cDocOri,cDescInc)
								endIf							
							EndIf
						Else
							cDescInc	:= STR0085 //"Verificar se alguma das entidades conta´beis está bloqueada."
							//Grava no arq. de trabalho que o estorno foi gerado com sucesso.
							If lImpRel
								Ct102GrInc(DTOC(dDataOri),cLoteOri,cSbLoteOri,cDocOri,cDescInc)
							EndIF
						EndIf
					Endif
				EndIf
			EndIf
		Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct102Ok   ³ Autor  ³ Simone Mie Sato		    ³ Data 06.02.06³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Confirma processamento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct102Ok(aQuais)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 = Array   contendo os lotes 	                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct102OK(aQuais)

Local lQuais	:= .F.
Local nCont

For nCont := 1 to Len(aQuais)
	IF aQuais[nCont][1]
		lQuais := .t.
		Exit
	Endif
Next

If !lQuais
	HELP (" ",1,"C210S/ARQ")				// Nao selecionou nenhum arquivo
	Return .F.
Endif

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct102troca³ Autor  ³ Simone Mie Sato         ³ Data 06.02.06³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Troca marcador entre x e branco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct102Troca(nIt,aArray)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ aArray                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpN1 = Numero da posicao                                  ³±±
±±³           ³ ExpA1 = Array contendo as empresas a serem consolidadas    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct102Troca(nIt,aArray)

aArray[nIt,1] := !aArray[nIt,1]

Return aArray

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct102CrRel³ Autor  ³ Simone Mie Sato         ³ Data 07.02.06³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Cria arquivo te trabalho p/rel. de inconsistencia.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct102CrRel()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ 	                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct102CrRel()

Local aSaveArea	:= GetArea()
Local aCampos	:= {{"DDATA","C",10,0},;
					 {"LOTE","C",Len(CriaVar("CT2_LOTE")),0},;
					 {"SUBLOTE","C",Len(CriaVar("CT2_SBLOTE")),0},;
 					 {"DOC","C",Len(CriaVar("CT2_DOC")),0},;
					 {"DESCINC","C",120,0}}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Crio arq. de trab. p/ gravar as inconsistencias.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If _oCTBA1021 <> Nil
	_oCTBA1021:Delete()
	_oCTBA1021	:= Nil
Endif

//Cria o Objeto do FwTemporaryTable
_oCTBA1021 := FwTemporaryTable():New("TRB")

//Cria a estrutura do alias temporario
_oCTBA1021:SetFields(aCampos)

//Adiciona o indicie na tabela temporaria
_oCTBA1021:AddIndex("1",{"DDATA","LOTE","SUBLOTE","DOC"})

//Criando a Tabela Temporaria
_oCTBA1021:Create()

RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct102GrInc³ Autor ³ Simone Mie Sato       ³ Data ³ 07.02.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as Inconsistencias no Arq. de Trabalho.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct102GrInc(dData,cLote,cSublote,cDoc,cDescInc)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba102                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data                                                ³±±
±±³          ³ ExpC1 = Lote                                                ³±±
±±³          ³ ExpC2 = SubLote                                             ³±±
±±³          ³ ExpC3 = Documento                                           ³±±
±±³          ³ ExpC4 = Descricao da Inconsistentcia                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct102GrInc(dData,cLote,cSubLote,cDoc,cDescInc)

Local aSaveArea:= GetArea()

dbSelectArea("TRB")
Reclock("TRB",.T.)
TRB->DDATA		:= dData
TRB->LOTE		:= cLote
TRB->SUBLOTE	:= cSubLote
TRB->DOC		:=	cDoc
TRB->DESCINC	:=	cDescInc
MsUnlock()

RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C102ImpRel³ Autor ³ Simone Mie Sato       ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime o Relatorio Final.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C102ImpRel()		  							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum       	  							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba102                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function C102ImpRel()

PRIVATE Tamanho		:="M"
PRIVATE aLinha		:= {}
PRIVATE nomeProg 	:= "CTBA102"
PRIVATE cString   	:= "CT2"
PRIVATE titulo    	:= STR0076  //"Log Validacao Estorno/Exclusão por Lote"
PRIVATE cDesc1    	:= STR0077  //"Este relatório irá imprimir o relatório de inconsistências
PRIVATE cDesc2    	:= STR0078	//"dos lançamentos que deveriam ser excluídos/estornados."
PRIVATE aReturn   	:= { STR0079, 1, STR0080, 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do Cabecalho.                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                       				  //          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
                      				  //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
PRIVATE cabec1    	:= STR0081		  // DATA    LOTE     SUBLOTE      DOC      INCONSISTENCIA
PRIVATE cabec2    	:= " "


li 			:= 80
m_pag			:= 1

wnrel	:= "CTBA102"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,,,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif


SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif


RptStatus({|lEnd| CTR102Imp(@lEnd,wnRel,cString,Titulo)})

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctr102Imp ³Autor  ³ Simone Mie Sato       ³ Data ³ 07.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime o Relatorio Final.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctr102Imp()       							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum             							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba350                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Acao do CodeBlock                                  ³±±
±±³          ³ ExpC1 = Nome do relatorio                                  ³±±
±±³          ³ ExpC2 = Mensagem                                           ³±±
±±³          ³ ExpC3 = Titulo                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ctr102Imp(lEnd,wnRel,cString,Titulo)

Local Li := 80

dbSelectArea("TRB")
dbGotop()

SetRegua(RecCount())
If RecCount() <> 0
	While !Eof()
		If Li > 55
			Cabec(titulo,cabec1,cabec2,NomeProg,Tamanho)
			Li := 10
		Endif
		IncRegua()
		@ Li,01 PSAY TRB->DDATA
		@ Li,13 PSAY TRB->LOTE
		@ Li,25 PSAY TRB->SUBLOTE
		@ Li,33 PSAY TRB->DOC
		@ Li,44 PSAY TRB->DESCINC
		Li += 1
		dbSkip()
	End
Else
	If Li > 55
		Cabec(titulo,cabec1,cabec2,NomeProg,Tamanho)
		Li := 10
	Endif
	@ Li,44 PSAY STR0088	//"Nenhum lote foi excluido ou estornado."
	Li++
EndIf

If ( Select( "TRB" ) <> 0 )
	dbSelectArea ( "TRB" )
	dbCloseArea ()
Endif

If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
EndIf

MS_FLUSH()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados    		  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aCT102BUT
Local aRotina
Local nX := 1


aRotina := {	{STR0001 ,"AxPesqui"   , 0 , 1,,.F.},; // "Pesquisar"
			 	{STR0002 ,"Ctba102Cal" , 0 , 2     },; // "Visualizar"
			 	{STR0003 ,"Ctba102Cal" , 0 , 3, 191},; // "Incluir"
				{STR0004 ,"Ctba102Cal" , 0 , 4     },; // "Alterar"
				{STR0005 ,"Ctba102Cal" , 0 , 5     },; // "Excluir"
				{STR0050 ,"Ctba102Cal" , 0 , 4     },; // "Estornar"
				{STR0051 ,"Ctba102Cal" , 0 , 3     },; // "Copiar"
				{STR0046 ,"CtbC010Rot" , 0 , 2     },; // "Rastrear"
				{STR0119 ,"CtbLctExtp" , 0 , 4     },; // "Lct.Extemp"
				{STR0122 ,"CTBS470" , 0 , 4     },; // "Lct. Transf. Saldo"
				{STR0108 ,"Ctba102Cop" , 0 , 4     } } // "Cópia Filial"

If Alltrim(GetNewPar("MV_CTBAPLA","1"))	> "1"
	aAdd(aRotina,{STR0069	,"CTBShowFLG(Nil)"	, 0 , 6})  // "Log Exclusao"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOPS 00000125001 - Ponto de Entrada para adicao de botoes no Browse   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF _lCT102BUT
	aCT102BUT := ExecBlock("CT102BUT",.F.,.F.,aRotina)

	IF ValType(aCT102BUT) == "A" .AND. Len(aCT102BUT) > 0
		FOR nX := 1 to len(aCT102BUT)
			aAdd(aRotina,aCT102BUT[nX])
		NEXT
	ENDIF
ENDIF

Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb102HeaderWTºAutor  ³Paulo Carnelossi  º Data ³ 20/03/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar no aheader os campos ALIAS _ALI_WT / _REC_WT para    º±±
±±º          ³utilizar nas getdados que nao possa utilizar fillgetdados() º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb102HeaderWT(cAlias, aHeader)
Local aArea := GetARea()
Local aAreaSX3 := SX3->(GetArea())
Local cUsado

dbSelectArea("SX3")
dbSetOrder(2)
cAlias := Alltrim(cAlias)

If SX3->(DbSeek(cAlias+"_FILIAL"))
	cUsado := SX3->X3_USADO

	AADD( aHeader, { STR0117, cAlias+"_ALI_WT", "", 09, 0,, cUsado, "C", cAlias, "V"} )
	AADD( aHeader, { STR0118, cAlias+"_REC_WT", "", 09, 0,, cUsado, "N", cAlias, "V"} )
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA105   ºAutor  ³Marcos S. Lobo      º Data ³  01/17/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Guarda os MV_Pars carregados na memoria quando executado    º±±
±±º          ³do CTBA105/CTBA102 (botão Ct102Repla tem 'ParamBox')        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GuardPars()

Local aMvPars := {}

aAdd(aMvPars,MV_PAR01)
aAdd(aMvPars,MV_PAR02)
aAdd(aMvPars,MV_PAR03)
aAdd(aMvPars,MV_PAR04)
aAdd(aMvPars,MV_PAR05)
aAdd(aMvPars,MV_PAR06)
aAdd(aMvPars,MV_PAR07)
aAdd(aMvPars,MV_PAR08)
aAdd(aMvPars,MV_PAR09)
aAdd(aMvPars,MV_PAR10)
aAdd(aMvPars,MV_PAR11)
aAdd(aMvPars,MV_PAR12)
aAdd(aMvPars,MV_PAR13)
aAdd(aMvPars,MV_PAR14)
aAdd(aMvPars,MV_PAR15)
aAdd(aMvPars,MV_PAR16)
aAdd(aMvPars,MV_PAR17)
aAdd(aMvPars,MV_PAR18)
aAdd(aMvPars,MV_PAR19)
aAdd(aMvPars,MV_PAR20)
aAdd(aMvPars,MV_PAR21)
aAdd(aMvPars,MV_PAR22)
aAdd(aMvPars,MV_PAR23)
aAdd(aMvPars,MV_PAR24)
aAdd(aMvPars,MV_PAR25)
aAdd(aMvPars,MV_PAR26)
aAdd(aMvPars,MV_PAR27)
aAdd(aMvPars,MV_PAR28)
aAdd(aMvPars,MV_PAR29)
aAdd(aMvPars,MV_PAR30)
aAdd(aMvPars,MV_PAR31)
aAdd(aMvPars,MV_PAR32)
aAdd(aMvPars,MV_PAR33)
aAdd(aMvPars,MV_PAR34)
aAdd(aMvPars,MV_PAR35)
aAdd(aMvPars,MV_PAR36)
aAdd(aMvPars,MV_PAR37)
aAdd(aMvPars,MV_PAR38)
aAdd(aMvPars,MV_PAR39)
aAdd(aMvPars,MV_PAR40)

Return(aMvPars)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA102   ºAutor  ³Marcos S. Lobo      º Data ³  01/17/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Restaura os Mv_Pars que estavam carregados na memoria no fimº±±
±±º          ³do CTBA105/CTBA102 (botão Ct102Repla tem 'ParamBox')        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RestPars(aMvPars)

Local nPar
DEFAULT aMvPars := {}

/// Restaura o conteudo do MV_PARs (existe um ParamBox no CTBA105).
For nPar := 1 To Len(aMvPars)
	&("MV_PAR"+strzero(int(nPar),2)) := aMvPars[nPar]
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA102   ºAutor  ³Microsiga           º Data ³  02/29/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LinhaHist( cTexto , nTamHist )
Local nLinha

nLinha := 0

If nTamHist < Len( cTexto )
	nLinha := Int( Len( cTexto ) / nTamHist )
Endif

nLinha++

Return nLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA102   ºAutor  ³Microsiga           º Data ³  02/29/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctba102Mod()
Local cVar	:=	ReadVar()

If TMP->(FieldPos('MODIFIED')) > 0
	TMP->MODIFIED := 1
Endif

If (Substr(cVar,4)$ "CT2_DC,CT2_DEBITO,CT2_CREDIT,CT2_CCD,CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_CLVLDB,CT2_CLVLCR,CT2_TPSALD,CT2_DTLP";
	.Or.  "CT2_VLR" $ cVar) .And. TMP->(FieldPos('ATUSALDO')) > 0
	TMP->ATUSALDO := 1
Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbAuxFil ºAutor  ³Microsiga           º Data ³  28/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta conteudo a ser gravado no campo filial da tabela de   º±±
±±º          ³acordo com layout e modo de compartilhamento quando em      º±±
±±º          ³ambiente com gestao corporativa                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbAuxFil(cLayoutEmp, aModoComp)
Local cAuxFil := ""
Local nPosEmpresa := At("E",cLayoutEmp)
Local nPosUnidade := At("U",cLayoutEmp)
Local nPosFilial := At("F",cLayoutEmp)
Local nTamFilial := Len(Alltrim(cLayoutEmp))
Local aLayFil := {NIL,NIL,NIL}
If nPosEmpresa > 0
	aLayFil[1] := CtbCtdStr("E",cLayoutEmp,nPosEmpresa)
EndIf
If nPosUnidade > 0
	aLayFil[2] := CtbCtdStr("U",cLayoutEmp,nPosUnidade)
EndIf
If nPosFilial > 0
	aLayFil[3] := CtbCtdStr("F",cLayoutEmp,nPosFilial)
EndIf
//Empresa
If aModoComp[1] == 'E' .And. aLayFil[1] != NIL
	cAuxFil += Subs( cFilAnt, nPosEmpresa, aLayFil[1] )
Else
	If aLayFil[1] != NIL
		cAuxFil += Space( aLayFil[1] )
	EndIf
EndIf
//Unidade de Negocio
If aModoComp[2] == 'E' .And. aLayFil[2] != NIL
	cAuxFil += Subs( cFilAnt, nPosUnidade, aLayFil[2] )
Else
	If aLayFil[2] != NIL
		cAuxFil += Space( aLayFil[2] )
	EndIf
EndIf
//Filial
If aModoComp[3] == 'E' .And. aLayFil[3] != NIL
	cAuxFil += Subs(cFilAnt, nPosFilial, aLayFil[3] )
Else
	If aLayFil[3] != NIL
		cAuxFil += Space( aLayFil[3] )
	EndIf
EndIf

Return(PadR(cAuxFil, nTamFilial))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbCtdStr ºAutor  ³Microsiga           º Data ³  10/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Conta quantas strings tem cadas segmento do layout quando   º±±
±±º          ³utiliza gestao corporativa                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbCtdStr(cString,cLayout,nPos)
Local nCount := 0
While Subs(cLayout,nPos,1) == cString
	nCount++
	nPos++
EndDo
Return(nCount)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C102VldHCLºAutor  ³Marcos R. Pires     º Data ³  23/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a quantidade de caracteres digitadas no campo Histo-º±±
±±º          ³ rico (CTC_DOCHIS) da capa do lote.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C102VldHCL(cHistLot)
Local lRet			:= .T.
Local nTamCpoHis	:= TAMSX3("CTC_DOCHIS")[1]

cHistLot := AllTrim(cHistLot)

If Len(cHistLot) > nTamCpoHis
	lRet := .F.
	Help(" ",1,"CT2HIST",,STR0101 + AllTrim(STR(nTamCpoHis)) + STR0102 + CRLF +STR0103 + AllTrim(STR(Len(cHistLot))),1,0)//"O campo Historico excedeu o limite de: "###" caracteres."##"Quantidade digitada: "
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA102HCLºAutor  ³Marcos R. Pires     º Data ³  05/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o Historico da capa do lote                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA102HCL()
Local aSaveArea := GetArea()
Local aSaveCTC	:= CTC->(GetArea())
Local nTamCpoHis	:= TAMSX3("CTC_DOCHIS")[1]
Local cRet		:= ""

cRet := Posicione("CTC",1,xFilial("CTC")+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC,"CTC_DOCHIS")
cRet := STRTRAN(cRet, chr(13)+chr(10), " ")
cRet := PadR(cRet,nTamCpoHis)

RestArea(aSaveArea)
RestArea(aSaveCTC)

Return(cRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programaa ³C102ExEnt³Autor  ³ Ana Paula				³ Data ³ 27.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe descricao da conta contabil na MSGETDB				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C102ExEnt(cPlano,cEntContab)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
Function C102ExEnt(cPlano,cEntContab)

Local cDesc := Space(25)

DbSelectArea("CV0")
DbSetOrder(1)
If MsSeek(xFilial("CV0")+cPlano+cEntContab)
	If cEntContab == Nil .Or. Empty(cEntContab)
		cDesc := Space(25)
	Else
		cDesc := CV0->CV0_DESC
	EndIf
EndIf

IF Type("oDescEnt")="O"
	oDescEnt:SetText(OemToAnsi(cDesc))
	oDescEnt:Refresh()
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³C102PxEst³Autor  ³ Rodrigo dos Santos		³ Data ³ 08/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o proximo documento do estorno de lote				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³AP                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/
Function Ctb102PxEst( dDataEst,cLoteEst,cSubLtEst,cDocEst,CTF_LOCK )
Local cKeyCTF	:= xFilial("CTF")+dtos(dDataEst)+cLoteEst+cSubLtEst
Local lRet		:= .T.
Local dDataCTF	:= dDataEst

	If cPaisLoc == "MEX"		// Consecutivo por mes, aplica solo para CTF
		dDataCTF := StoD( Substr(DtoS(dDataCTF), 1, 6) + "01" )
		cKeyCTF	:= xFilial("CTF")+dtos(dDataCTF)+cLoteEst+cSubLtEst
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o Numero do Proximo documento contabil                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While !ProxDoc(dDataEst,cLoteEst,cSubLtEst,@cDocEst,@CTF_LOCK)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o N§ do Doc estourou, incrementa o lote         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLoteEst := CtbInc_Lot(cLoteEst, cModulo)

	Enddo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CT102EAI
Funcao que prepara as informação para o envio da mensagem de lançamentos
contábeis, quebrando o XML para não ultrapassar 900 lançamentos

@author	Pedro Alencar
@since		17/03/2014
@version	MP11.90
/*/
//-------------------------------------------------------------------
Function CT102EAI (dDataLanc, cLote, cSubLote, cDoc, cHist, cOriginCod, nOpc)
Local aAreaCT2 		    := CT2->( GetArea() )
Local cEvent 			:= ""
Local nCount 			:= 0
Local aDados 			:= {}
Local nY 				:= 0
Local nZ                := 0 //Controle de FOR
Local cCT2ValInt 		:= ""
Local cXMLRet 	    	:= ""
Local nMax 		    	:= 40
Local cCampoDeb 		:= ""
Local cCampoCred		:= ""
Local aAux				:= {}
Local lContaGer 		:= .F.
Local lAllEnt           := .F. //Utiliza Todas as Entidades Adicionais ?
Local lCTBA030 	    	:= FWHasEAI("CTBA030",.T.,,.T.)
Local lCTBA040    		:= FWHasEAI("CTBA040A",,,.T.) .OR. FWHasEAI("CTBA040",,,.T.)
Local lCTBA060 	    	:= FWHasEAI("CTBA060",,,.T.)
Local lCTBA800a 		:= FWHasEAI("CTBA800A",,,.T.)
Local cEntGer			:= SuperGetMV("MV_CTBCGER",.F.,"")
Local nTamFil			:= TamSx3("CT2_FILIAL")[1]
Local aResult           := {}
Local nTotalXML         := 0
Local nXMLAtual         := 1
Local cVersion          := FWXX4Version('ACCOUNTINGENTRY') //Versão da Mensagem Única
Local aEntCtb           := CarrEntCtb() //array de verificação das entidades contabeis adicionais, com 5 posicoes
Local lExistCT2 		:= .F. //Flag para controle de itens ativos na CT2

Default cOriginCod   	:= AllTrim(cModulo)
Default cHist			:= ""
Default nOpc			:= 0

//Pelo fato da rotina ser projetada sem tratar versão, foi implementado o tratamente a partir da versão 3.000
//Se for versão 3.x utilizará todas as Entidades Adicionais
If cVersion = "3."
	lAllEnt := .T.
Else
	dbSelectArea("CT0")
	CT0->(dbSetOrder(1)) //CT0_FILIAL+CT0_ID
	If !Empty(cEntGer)
		If CT0->(dbSeek(xFilial("CT0") + cEntGer))
			lContaGer 	:= .T.
			cCampoDeb := "CT2_EC"+cEntGer+"DB"
			cCampoCred:= "CT2_EC"+cEntGer+"CR"
		EndIf
	EndIf
EndIf

If nOpc == 5
	cEvent := 'delete'	
Else
	cEvent := 'upsert'	
EndIf

//InternalId do Lançamento Contábil
cCT2ValInt := C102MntInt( cFilAnt, DTOS(dDataLanc), cLote, cSubLote, cDoc )
//
//Se for insert ou update
If cEvent == 'upsert'
	FWHasEAI("CTBA102",,,.T.)			
	CT2->(dbSetOrder(1)) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
				
	If CT2->( MsSeek( xFilial("CT2") + dToS(dDataLanc) + cLote + cSubLote + cDoc ) )
		//Grava todas as linhas de lançamentos em um vetor
		While CT2->(!EOF()) .AND. CT2->CT2_FILIAL == xFilial("CT2") .AND. CT2->CT2_DATA ==  dDataLanc ;
			.AND. CT2->CT2_LOTE == cLote .AND. CT2->CT2_SBLOTE == cSubLote .AND. CT2->CT2_DOC == cDoc

			If CT2->CT2_MOEDLC == "01"
				aAux := {}
				aAdd(aAux,CT2->CT2_LINHA)
				aAdd(aAux,CT2->CT2_DC)
				aAdd(aAux,CT2->CT2_DATA)
				aAdd(aAux,CT2->CT2_TPSALD)
				aAdd(aAux,CT2->CT2_MOEDLC)
				aAdd(aAux,CT2->CT2_DEBITO)
				aAdd(aAux,CT2->CT2_CREDIT)
				aAdd(aAux,CT2->CT2_VALOR)
				aAdd(aAux,CT2->CT2_HP)
				aAdd(aAux,CT2->CT2_HIST)
				aAdd(aAux,CT2->CT2_CCD)
				aAdd(aAux,CT2->CT2_CCC)
				aAdd(aAux,CT2->CT2_ITEMD)
				aAdd(aAux,CT2->CT2_ITEMC)
				aAdd(aAux,CT2->CT2_CLVLDB)
				aAdd(aAux,CT2->CT2_CLVLCR)
				//Todas as Entidades Adicionais
				If lAllEnt
					For nY := 01 To Len(aEntCtb)
						If (aEntCtb[nY, 01])
							AAdd(aAux, CT2->&(aEntCtb[nY, 02])) //Débito
							AAdd(aAux, CT2->&(aEntCtb[nY, 03])) //Crédito
						Else
							AAdd(aAux, "") //Débito
							AAdd(aAux, "") //Crédito
						EndIf
					Next nY
				ElseIf lContaGer
					aAdd(aAux,CT2->&(cCampoDeb))
					aAdd(aAux,CT2->&(cCampoCred))
				EndIf

				aAdd(aAux, .F.) //Item deletado

				aAdd(aDados,aAux)

				lExistCT2 := .T. //Encontrou CT2
			EndIf

			CT2->( DbSkip() )
		EndDo
	EndIf

	//Se for Alteracao, verifica se existem itens deletados para envio
	If nOpc == 4 //Alteracao		
		If lExistCT2 //Verifica se encontrou CT2 ativa para envio de Inclusao/Alteracao
					                                                     
			TMP->(dbGoTo(1)) //Posiciona no primeiro registro do arquivo temporario

			While TMP->(!EOF())
				//Verifica se gravou Recno da CT2 e não encontrou registro contábil, significa que item foi deletado na alteração		 
				If TMP->CT2_RECNO <> 0 .And.;										
					!CT2->(MsSeek(TMP->(CT2_FILIAL+DToS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC)))	
						
					aAux := {}
					aAdd(aAux,TMP->CT2_LINHA)
					aAdd(aAux,TMP->CT2_DC)
					aAdd(aAux,TMP->CT2_DATA)
					aAdd(aAux,TMP->CT2_TPSALD)
					aAdd(aAux,TMP->CT2_MOEDLC)
					aAdd(aAux,TMP->CT2_DEBITO)
					aAdd(aAux,TMP->CT2_CREDIT)
					aAdd(aAux,TMP->CT2_VALOR)
					aAdd(aAux,TMP->CT2_HP)
					aAdd(aAux,TMP->CT2_HIST)
					aAdd(aAux,TMP->CT2_CCD)
					aAdd(aAux,TMP->CT2_CCC)
					aAdd(aAux,TMP->CT2_ITEMD)
					aAdd(aAux,TMP->CT2_ITEMC)
					aAdd(aAux,TMP->CT2_CLVLDB)
					aAdd(aAux,TMP->CT2_CLVLCR)

					//Todas as Entidades Adicionais
					If lAllEnt
						For nY := 01 To Len(aEntCtb)
							If (aEntCtb[nY, 01])
								AAdd(aAux, TMP->&(aEntCtb[nY, 02])) //Débito
								AAdd(aAux, TMP->&(aEntCtb[nY, 03])) //Crédito
							Else
								AAdd(aAux, "") //Débito
								AAdd(aAux, "") //Crédito
							EndIf
						Next nY
					ElseIf lContaGer
						aAdd(aAux,TMP->&(cCampoDeb))
						aAdd(aAux,TMP->&(cCampoCred))
					EndIf

					aAdd(aAux, .T.) //Item deletado
					aAdd(aDados,aAux)				
				EndIf				
		
				TMP->( DbSkip() )
			EndDo
		Else //Se nao encontrou itens ativos na CT2, trata mensagem como exclus?o
			nOpc := 5 //Altera evento para Delete pois n?o todos itens foram deletados na alteraç?o
			CT102EAI (dDataLanc, cLote, cSubLote, cDoc, cHist, cOriginCod, nOpc) //Chama novamente envio como evento Delete
		EndIf		
	EndIf

	CT2->( RestArea(aAreaCT2) )		

	aSort(aDados,,,{|x,y| x[1] < y[1]}) //Ordena itens

	nXMLAtual:= 1
	nTotalXML:= Int((Len(aDados)/ nMax)) + IIF((Len(aDados) % nMax) > 0,1,0)
	nCount := 0
	For nY := 1 to Len(aDados)

		//Se for a primeira vez, coloca o cabeçalho do lançamento na mensagem
		If nCount == 0

			cXMLRet := '<BusinessEvent>'
			cXMLRet +=     '<Entity>AccountingEntry</Entity>'
			cXMLRet +=     '<Event>' + cEvent + '</Event>'
			cXMLRet +=     '<Identification>'
			cXMLRet +=         '<key name="InternalId">'	+  cCT2ValInt	+	'</key>'
			cXMLRet +=     '</Identification>'
			cXMLRet += '</BusinessEvent>'

			cXMLRet += '<BusinessContent>'
			cXMLRet +=	   '<CompanyId>'					+	cEmpAnt												+	'</CompanyId>'
			cXMLRet +=	   '<BranchId>'					+	cFilAnt												+	'</BranchId>'
			cXMLRet +=	   '<CompanyInternalId>'			+	cEmpAnt+"|"+cFilAnt									+	'</CompanyInternalId>'
			cXMLRet +=	   '<OriginCode>'					+	cOriginCod												+	'</OriginCode>'
			cXMLRet +=	   '<PeriodStartDate>'			+	Transform(dToS(dDataLanc),"@R 9999-99-99")    	+	'</PeriodStartDate>'
			cXMLRet +=	   '<PeriodEndDate>'				+	Transform(dToS(dDataLanc),"@R 9999-99-99")	    +	'</PeriodEndDate>'
			cXMLRet +=	   '<BatchNumber>'				+	cLote        										    +	'</BatchNumber>'
			cXMLRet +=	   '<SubLot>'						+	cSubLote       										+	'</SubLot>'

			/*Esse tratamento serve para integração do RH Protheus com o Contabil Logix.*/
			cXMLRet +=	   '<TotalNumberOfMessages>'	+	StrZero(nTotalXML,4)									+	'</TotalNumberOfMessages>'
			cXMLRet +=	   '<CurrentMessageNumber>'		+	StrZero(nXMLAtual,4)								+	'</CurrentMessageNumber>'

			cXMLRet +=	   '<Document>'					+	cDoc         											+	'</Document>'
			cXMLRet +=	   '<InternalId>'					+	cCT2ValInt												+	'</InternalId>'

			cXMLRet +=	   '<Entries>'

		EndIf

		//Envia as linhas de lançamentos
		cXMLRet +=	      '<Entry>'
		cXMLRet +=	         '<Item>'							+	AllTrim(aDados[nY][1])   						    +	'</Item>'
		cXMLRet +=	         '<ItemType>'					+	AllTrim(aDados[nY][2])	    			  			+	'</ItemType>'
		cXMLRet +=	         '<EntryNumber>'					+	AllTrim(cEmpAnt) + xFilial("CT2") + DTOS(aDados[nY][3]) + AllTrim(cLote) + AllTrim(cSubLote) + AllTrim(cDoc) + AllTrim(aDados[nY][1]) + '</EntryNumber>'
		cXMLRet +=	         '<MovementDate>'				+	Transform(dToS(aDados[nY][3]),"@R 9999-99-99")	+	'</MovementDate>'
		cXMLRet +=	         '<BalanceType>'					+	AllTrim(aDados[nY][4])  						    	+	'</BalanceType>'
		cXMLRet +=	         '<CurrencyCode>'				+	AllTrim(aDados[nY][5])	    						+	'</CurrencyCode>'
		cXMLRet +=	         '<CurrencyInternalId>'			+	AllTrim(cEmpAnt) + '|' + Padr(xFilial("CTO"),nTamFil) + '|' + AllTrim(aDados[nY][5]) +	'</CurrencyInternalId>'
		cXMLRet +=	         '<DebitAccountCode>'			+	AllTrim(aDados[nY][6])								+	'</DebitAccountCode>'
		cXMLRet +=	         '<DebitAccountInternalId>'	+	Iif(!Empty(aDados[nY][6]), AllTrim(cEmpAnt) + '|' + Padr(xFilial("CT1"),nTamFil) + '|' + AllTrim(aDados[nY][6]), '') + '</DebitAccountInternalId>'
		cXMLRet +=	         '<CreditAccountCode>'			+	AllTrim(aDados[nY][7])  								+	'</CreditAccountCode>'
		cXMLRet +=	         '<CreditAccountInternalId>'	+	Iif(!Empty(aDados[nY][7]	), AllTrim(cEmpAnt) + '|' + Padr(xFilial("CT1"),nTamFil) + '|' + AllTrim(aDados[nY][7]), '') + '</CreditAccountInternalId>'
		cXMLRet +=	         '<EntryValue>'					+	CVALTOCHAR(aDados[nY][8]	)							+	'</EntryValue>'

		if(Empty(cHist))
			cXMLRet +=	      '<HistoryCode>'				+	aDados[nY][9]									+	'</HistoryCode>'
		else
			cXMLRet +=	      '<HistoryCode>'				+	cHist											+	'</HistoryCode>'
		endIf

		cXMLRet +=	         '<ComplementaryHistory>'		+	aDados[nY][10]										+	'</ComplementaryHistory>'
		//Tratamento dos centros de custos utilizando ou não a msg CTBI030 - Centro de Curso
		cXMLRet +=	         '<CostCenterCode>'				+	AllTrim(aDados[nY][11])							    + 	'</CostCenterCode>'
		cXMLRet +=	         '<CostCenterDebitInternalId>'	+	IIf(!Empty(aDados[nY][11]) .AND. lCTBA030, IntCusExt(cEmpAnt, xFilial("CTT"), aDados[nY][11])[2], '')	+ 	'</CostCenterDebitInternalId>'
		cXMLRet +=	         '<CostCenterCreditCode>'		+	AllTrim(aDados[nY][12])								+	'</CostCenterCreditCode>'
		cXMLRet +=	         '<CostCenterCreditInternalId>' +	Iif(!Empty(aDados[nY][12]) .AND. lCTBA030, IntCusExt(cEmpAnt, xFilial("CTT"), aDados[nY][12])[2], '')	+ 	'</CostCenterCreditInternalId>'

		cXMLRet +=	         '<AccountingItemDebitCode>'				+	AllTrim(aDados[nY][13])							    + 	'</AccountingItemDebitCode>'
		cXMLRet +=	         '<AccountingItemDebitInternalId>'	+	IIf(!Empty(aDados[nY][13]) .AND. lCTBA040, AllTrim(cEmpAnt) + '|' + Padr(xFilial("CTD"),nTamFil) + '|' + AllTrim(aDados[nY][13]), '') 	+ 	'</AccountingItemDebitInternalId>'
		cXMLRet +=	         '<AccountingItemCreditCode>'		+	AllTrim(aDados[nY][14])								+	'</AccountingItemCreditCode>'
		cXMLRet +=	         '<AccountingItemCreditInternalId>' +	Iif(!Empty(aDados[nY][14]) .AND. lCTBA040, AllTrim(cEmpAnt) + '|' + Padr(xFilial("CTD"),nTamFil) + '|' + AllTrim(aDados[nY][14]), '') + 	'</AccountingItemCreditInternalId>'

		cXMLRet +=	         '<ClassValueDebitCode>'				+	AllTrim(aDados[nY][15])							    + 	'</ClassValueDebitCode>'
		cXMLRet +=	         '<ClassValueDebitInternalId>'	+	IIf(!Empty(aDados[nY][15]) .AND. lCTBA060, C060MntInt( xFilial("CTH"), aDados[nY][15]), '')	+ 	'</ClassValueDebitInternalId>'
		cXMLRet +=	         '<ClassValueCreditCode>'		+	AllTrim(aDados[nY][16])								+	'</ClassValueCreditCode>'
		cXMLRet +=	         '<ClassValueCreditInternalId>' +	Iif(!Empty(aDados[nY][16]) .AND. lCTBA060, C060MntInt( xFilial("CTH"), aDados[nY][16]), '')	+ 	'</ClassValueCreditInternalId>'

		//Verifica se utiliza todas as Entidades Adicionais
		If lAllEnt
			//Percorre o restante do array preenchendo as entidades adicionais
			nEntAux := 05 //Auxiliar de Entidade Adicional
			For nZ := 17 To Len(aDados[nY])-1 //Desconsidera a ultima posicao do array, indica se item está deletado
				//Verifica se é debito ou crédito
				If !(Mod(nZ, 02) == 0) //Débito
					//Verifica se possui contéudo
					If !(Empty(aDados[nY, nZ]))
						cXMLRet +=	         '<ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Debit>' + AllTrim(aDados[nY][nZ]) + '</ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Debit>'
						cXMLRet +=	         '<ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'DebitInternalId>' + IntGerExt(cEmpAnt, FWxFilial("CV0"), StrZero(nEntAux, 02), aDados[nY][nZ])[2] + '</ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'DebitInternalId>'
					Else
						cXMLRet +=	         '<ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Debit/>'
						cXMLRet +=	         '<ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'DebitInternalId/>'
					EndIf
				Else //Crédito
					//Verifica se possui contéudo
					If !(Empty(aDados[nY, nZ]))
						cXMLRet +=	         '<ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Credit>' + AllTrim(aDados[nY][nZ]) + '</ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Credit>'
						cXMLRet +=	         '<ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'CreditInternalId>' + IntGerExt(cEmpAnt, FWxFilial("CV0"), StrZero(nEntAux, 02), aDados[nY][nZ])[2] + '</ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'CreditInternalId>'
					Else
						cXMLRet +=	         '<ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Credit/>'
						cXMLRet +=	         '<ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'CreditInternalId/>'
					EndIf
					//Somando a Entidade Adicional
					nEntAux ++
				EndIf
			Next nZ
		ElseIf lContaGer
			cXMLRet +=	         '<ManagerialAccountingEntityDebit>'				+	AllTrim(aDados[nY][17])							    + 	'</ManagerialAccountingEntityDebit>'
			cXMLRet +=	         '<ManagerialAccountingEntityDebitInternalId>'	+	IIf(!Empty(aDados[nY][17]) .AND. lCTBA800A, IntGerExt(cEmpAnt, xFilial("CV0"), cEntGer, aDados[nY][17])[2], '')	+ 	'</ManagerialAccountingEntityDebitInternalId>'
			cXMLRet +=	         '<ManagerialAccountingEntityCredit>'		+	AllTrim(aDados[nY][18]) +	'</ManagerialAccountingEntityCredit>'
			cXMLRet +=	         '<ManagerialAccountingEntityCreditInternalId>' +	Iif(!Empty(aDados[nY][18]) .AND. lCTBA800a, IntGerExt(cEmpAnt, xFilial("CV0"), cEntGer, aDados[nY][18])[2], '')	+ 	'</ManagerialAccountingEntityCreditInternalId>'
		EndIf
		
		cXMLRet +=	         '<ItemDeleted>' + IIF(aDados[nY][Len(aDados[nY])], "1", "2") + '</ItemDeleted>'
		cXMLRet +=	     '</Entry>'

		nCount++

		//Verifica se as linhas de lançamentos ultrapassaram o limite definido ou se já chegou no final dos
		//lançamentos e envia a mensagem chamando a IntegDef
		If nCount >= nMax .OR. ( (nY) >= Len(aDados) )
			cXMLRet +=	  '</Entries>'
			cXMLRet += '</BusinessContent>'
			nCount := 0
			nXMLAtual++

			aResult := FwIntegDef( 'CTBA102', , , cXMLRet, 'CTBA102' )
		EndIf
	Next nY

Else //Se for 'delete'
	//Se opcao exclusao, verifica se existe CT2, necessário caso aç?o de exclus?o n?o foi confirmada	
	CT2->(dbSetOrder(1))
	
	If !CT2->( MsSeek( xFilial("CT2") + dToS(dDataLanc) + cLote + cSubLote + cDoc ) )
		CFGA070Mnt(, "CT2", "CT2_DOC",, cCT2ValInt, .T.) // excluindo da XXF

		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>AccountingEntry</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'
		cXMLRet +=     '<Identification>'
		cXMLRet +=         '<key name="InternalId">'	+	cCT2ValInt	+	'</key>'
		cXMLRet +=     '</Identification>'
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
		cXMLRet +=	   '<CompanyId>'					+	cEmpAnt												+	'</CompanyId>'
		cXMLRet +=	   '<BranchId>'					+	cFilAnt												+	'</BranchId>'
		cXMLRet +=	   '<CompanyInternalId>'			+	cEmpAnt+"|"+cFilAnt									+	'</CompanyInternalId>'
		cXMLRet +=	   '<OriginCode>'					+	cOriginCod												+	'</OriginCode>'
		cXMLRet +=	   '<PeriodStartDate>'			+	Transform(dToS(dDataLanc),"@R 9999-99-99")    	+	'</PeriodStartDate>'
		cXMLRet +=	   '<PeriodEndDate>'				+	Transform(dToS(dDataLanc),"@R 9999-99-99")	    +	'</PeriodEndDate>'
		cXMLRet +=	   '<BatchNumber>'				+	cLote        										    +	'</BatchNumber>'
		cXMLRet +=	   '<SubLot>'						+	cSubLote       										+	'</SubLot>'
		cXMLRet +=	   '<Document>'					+	cDoc         											+	'</Document>'
		cXMLRet +=	   '<InternalId>'					+	cCT2ValInt												+	'</InternalId>'
		cXMLRet +=	   '<Entries></Entries>'
		cXMLRet += '</BusinessContent>'

		//Informado o quinto parâmetro "cFunName" para que o ResponseMessage retorne para o adapter correto,
		//no caso da integração ser chamada por outra rotina
		aResult := FwIntegDef( 'CTBA102', , , cXMLRet, 'CTBA102' )
	EndIf
Endif

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Chamada da Mensagem Unica de Lançamentos Contabéis

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@author marylly.araujo
@since 14/11/2013
@version MP11.90
/*/
//-------------------------------------------------------------------

STATIC FUNCTION IntegDef( cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aRet := {}

aRet := CTBI102( cXml, cTypeTrans, cTypeMsg, cVersion, cTransac )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctba102Cop
Função de copia por filial
@author Mayara Alves
@since  24/04/2014
@param cAlias - tabela
@param nReg	- registro
@param nOpc	- opc. menu

@version 12
/*/
//-------------------------------------------------------------------
Function Ctba102Cop(cAlias,nReg,nOpc)
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local nCop		:= 7	//Copia
Local aPergs	:= {}
Local aRet		:= {}
Local cCopFil	:= Space(FWSizeFilial())

If _lNewSemaf == NIL
	_lNewSemaf :=  CTF->(FieldPos('CTF_USADO'))>0
EndIf

SaveInter()

Aadd( aPergs ,{1,STR0110 + ": " ,cCopFil,"" ,"","SM0","",50,.T.})//"Filial"

If ParamBox(aPergs ,STR0109,aRet)//"Copia para Filial"
	DbSelectArea("SM0")
	DbSetOrder(1)
	If SM0->(DbSeek(cEmpAnt+aRet[1]))
		cGuarFil	:= cFilAnt
		cFilAnt		:= aRet[1]

		//Chama função como copia
		Ctba102Cal(cAlias,nReg,nCop)

		cFilAnt		:= cGuarFil
		cGuarFil	:= ""
	Else
		Help(" ",1,"CTA102FIL",,STR0111,1,0) //"Filial não existe."
	EndIf
EndIf

RestInter()

RestArea(aAreaSM0)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ChecErro ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 17.11.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina verificadora do erro                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChecErro()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .F./Nenhum                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA080                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION ChecErro(e)
	Help(" ",1,"ERR_FORM",,e:Description,3,1)
	BREAK
Return()

//------------------------------------------------------------------------------------
/*/{Protheus.doc} C102AutoPreLan
Função que retorna se haverá pré-lançamento durante a execução da rotina automática.
As premissas que são levadas em consideração:
	=> Não foi passado um nenhum dado para o campo CT2_TPSALD (caso seja informado este dado,
	ele possui precedência sobre o parâmetro MV_PRELAN)
	=> Se não há informação do CT2_TPSALD e o conteúdo do MV_PRELAN for "S" ou "D" (mas com
	documento inconsistente)
@author Fernando Radu Muscalu
@since  12/09/2018

@return cPreLcto	- Tipo: Caractere. "S" -> pré-lançamento; "N" - não é pré-lançamento

@version 12
/*/
//----------------------------------------------------------------------------------------
Static Function C102AutoPreLan()

Local cPreLcto	:= ""

Local nI		:= 0

Local lHasTpSald:= .f.

For nI := 1 to Len(aAutoItens)

	If ( aScan(aAutoItens[nI],{|x| Alltrim(Upper(x[1])) == "CT2_TPSALD" }) > 0 )
		lHasTpSald := .t.
		Exit
	EndIf

Next nI

If ( !lHasTpSald .And. ( SuperGetMv("MV_PRELAN") == "S" .Or. ( SuperGetMv("MV_PRELAN") <> "S" .and. __PreLan)) )
	cPreLcto	:= "S"
Else
	cPreLcto	:= "N"
EndIf

Return(cPreLcto)

/**
	Carrega Array com informações dos Campos de Entidades Contábeis
**/
Static Function CarrEntCtb()
	Local aRetEnt := {} //Array de Retorno
	Local nQtdEnt := 05 //Quantidade de Entidades Adicionais
	Local nE      := 0 //Controle de FOR
	Local cCpoDeb := '' //Campo Entidade Débito
	Local cCpoCrd := '' //Campo Entidade Crédito

	//Verificando se campos existem
	DBSelectArea('CT2')
	For nE := 01 To nQtdEnt
		//Compondo Campos
		cCpoDeb := 'CT2_EC' + StrZero(nE + 04, 02) + 'DB' //Débito
		cCpoCrd := 'CT2_EC' + StrZero(nE + 04, 02) + 'CR' //Crédito
		If (FieldPos(cCpoDeb) > 0 .AND. FieldPos(cCpoCrd) > 0)
			AAdd(aRetEnt, {.T., cCpoDeb, cCpoCrd})
		Else
			AAdd(aRetEnt, {.F., "", ""})
		EndIf
	Next nE

Return aRetEnt


//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb102Save
Função para adicionar os recnos dos registros na alteração por mensagem unica
utiliza array estatico _aRecCT2 
@author Totvs
@since  18/10/2018

@version 12
/*/
//-------------------------------------------------------------------

Function Ctb102Save(nRecnoCT2)

aAdd( _aRecCT2, nRecnoCT2 )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb102_Del
Função de exclusao  de registros na alteração por mensagem unica
utiliza array estatico _aRecCT2 alimentado na funcao Ctb102Save() 
@author Totvs
@since  18/10/2018

@version 12
/*/
//-------------------------------------------------------------------

Function Ctb102Clear()

_aRecCT2 := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb102_Del
Função de exclusao  de registros na alteração por mensagem unica
utiliza array estatico _aRecCT2 alimentado na funcao Ctb102Save() 
@author Totvs
@since  18/10/2018

@version 12
/*/
//-------------------------------------------------------------------

Function Ctb102_Del()
Local nX

If Len(_aRecCT2) > 0
	For nX := 1 TO Len(_aRecCT2)
		
		CT2->( dbGoto(_aRecCT2[nX]) )
		CT2->( Reclock("CT2", .F., .T. ) )
		CT2->( dbDelete() )
		CT2->( MsUnlock() )

	Next nX
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}Ctb102_Rec
Função de recuperacao de registros na alteração por mensagem unica
utiliza array estatico _aRecCT2 alimentado na funcao Ctb102Save() 
@author Totvs
@since  18/10/2018

@version 12
/*/
//-------------------------------------------------------------------

Function Ctb102_Rec()
Local nX

If Len(_aRecCT2) > 0
	For nX := 1 TO Len(_aRecCT2)
		
		CT2->( dbGoto(_aRecCT2[nX]) )
		CT2->( Reclock("CT2", .F., .T. ) )
		CT2->( DBRecall() )
		CT2->( MsUnlock() )

	Next nX
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc}VldAtivLP
Verifica se existe pelo menos uma sequencia ativa no LP
@author Totvs
@since  10/08/2020

@version 12
/*/
//-------------------------------------------------------------------
Static Function VldAtivLP(cPadrao)
Local aArea 	:=  GetArea()
Local aAreaCT5 	:=  GetArea()
Local lRet 		:= .F.

DEFAULT cPadrao := ""

If Empty(cPadrao)
	lRet := .T.
Else
	CT5->(dbSetOrder(1))
	If CT5->(dbSeek(xFilial("CT5")+cPadrao))
		While !CT5->(Eof()) .And. CT5->CT5_LANPAD == cPadrao
			If CT5->CT5_STATUS == "1"
				lRet := .T.
				Exit
			EndIf
			CT5->(dbSkip())
		EndDo
	EndIf
EndIf

If !lRet
	Help(" ",1,"NOATIVLP",,STR0121,1,0) //"Deve existir pelo menos uma sequência ativa no LP informado"
EndIf

RestArea(aAreaCT5)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} CTB102Metrics
	
	CTB102Metrics - Função utilizada para metricas no CTBR400

	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function CTB102Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""
Local cIdMetric  := ""
Local dDateSend := CtoD("") 
Local nLapTime := 0
Local nTotal := 0

Default cEvent := ""
Default nStart := Seconds()
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//Só capturar metricas se a versão da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)
	
	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01" .And. nQtdReg > 0  //Evento 01 -   Quantidade de clientes que utilizam lançamentos do tipo extemporâneo no ecd

	
		If cSubEvent == '001' 			
			cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCTBA102",cFunBkp)
			SetFunName(cFunMet)
			
			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			cSubRoutine := Alltrim(cSubRoutine)
			cIdMetric  := "contabilidade-gerencial-protheus_lancamento-contabil-extemporaneo-qtd_total"
			nTotal := nQtdReg 
			dDateSend := LastDay( Date() )

			// Metrica
			FWCustomMetrics():SetSumMetric(cSubRoutine, cIdMetric, ntotal, dDateSend, nLapTime)

		EndIf

	//Evento 02 -  Lançamento-contábil-transferencia-de-saldos-qtd
	ElseIf cEvent == "02" .And. nQtdReg > 0  //Quantidade de utilizaç?o de lançamentos do tipo de transfer?ncia de saldos ecd

		If cSubEvent == '001'

			cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCTBA102",cFunBkp)
			SetFunName(cFunMet)
			
			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			cSubRoutine := Alltrim(cSubRoutine)			
			cIdMetric  := "contabilidade-gerencial-protheus_lancamento-contabil-transferencia-de-saldos-qtd_total"
			nTotal := nQtdReg //cTotal na função SetMetric espera parametro do tipo caractere						
			dDateSend := LastDay( Date() )
			FWCustomMetrics():SetSumMetric(cSubRoutine, cIdMetric, nTotal, dDateSend, nLapTime)
		EndIf

	EndIf

	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc}Ct102RcCTF
Verifica se existe CTF quando exclusao e feita em lote e 
a funcao CtbDestrava marca com R para se quiser poder usar o msm numero novamente
funcao para verificar se existe CTF e caso ainda tenha 
excluir ou marcar como recuperavel o numero na versao 12.1.33

@author Totvs
@since  09/12/2020

@version 12
/*/
//-------------------------------------------------------------------
Static Function Ct102RcCTF(nOpc, dDataLanc,cLote,cSubLote,cDoc)
Local cAliasAnt

If nOpc == 5 .And. _lNewSemaf  //exclusao em lote 
	cAliasAnt := Alias()
	dbSelectArea("CTF")
	If dbSeek(xFilial("CTF")+Dtos(dDataLanc)+cLote+cSubLote+cDoc) .And. (CTF->CTF_USADO = 'S' .or. Empty(CTF->CTF_USADO))
		CTF_LOCK := CTF->(Recno())
		If FindFunction("CtSetRcCTF") //CONFIRMADO EXCLUSAO - VERSAO 12.1.33
			CtSetRcCTF(.T.)  //QUANDO EXCLUIR SETA PARA UNLOCKDOC COLOCAR CAMPO CTF_USADO = 'R' --> PODE SER RECUPERADO ESTE NUMERO
		EndIf
		CtbDestrava(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK)
	EndIf
	dbSelectArea(cAliasAnt)
EndIf

Return
