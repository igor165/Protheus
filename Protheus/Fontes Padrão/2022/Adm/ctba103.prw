
// 17/08/2009 -- Filial com mais de 2 caracteres

#Include "Protheus.ch"
#Include "Ctba103.ch"
#Include "Colors.ch"
//Amarracaçao de pacote
STATIC cPictVal
STATIC __cTpSaldo
STATIC nQtdEntid
STATIC _lForcHead := .T.
STATIC _lForcCrTmp := .T.
STATIC _aCampos	:= Nil
STATIC _aAltera	:= Nil
STATIC _aHeadCtb	:= Nil

Static _lNewSemaf := NIL

Static _lCT103ACAP    := ExistBlock("CT103ACAP")
Static _lCT103BTO     := ExistBlock("CT103BTO")
Static _lCT105TOK     := ExistBlock("CT105TOK")
Static _lCT105CHK     := ExistBlock("CT105CHK")
Static _lCTB103EXC    := ExistBlock("CTB103EXC")
Static _lANCTB103GR   := ExistBlock("ANCTB103GR")
Static _lDPCTB103GR   := ExistBlock("DPCTB103GR")
Static _lCt103Carr    := ExistBlock("Ct103Carr")
Static _lVCLOT103     := ExistBlock("VCLOT103")
Static _lCT103BUT     := ExistBlock("CT103BUT")
Static _lVCTB103EST   := ExistBlock("VCTB103EST")
Static _lFLT103ST     := ExistBlock("FLT103ST")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA103   ³ Autor ³ Alvaro Camillo Neto   ³ Data ³ 13.10.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao de Lancamento Contabeis por tipo de saldo         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba103(void)                                              ³±±
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
±±³  Marco A.  ³28/05/18³DMINA-2113 ³Se modifica funcion CTM103ProxDoc(), ³±±
±±³            ³        ³           ³para Numero de Poliza Consecutivo por³±±
±±³            ³        ³           ³mes. (MEX)                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA103()

Local nX		:= 0
Local lUsarCTC      := .F.
Local aLegenda
Local oBrowse

Private aRotina := MenuDef()

Private cCadastro 	:= OemToAnsi(STR0006) // "Lan‡amentos Cont beis - Automaticos"
Private dDataLanc
Private cLote
Private cLoteSub 	:= SuperGetMv("MV_SUBLOTE")
Private cSubLote 	:= cLoteSub
Private lSubLote 	:= Empty(cSubLote)
Private cDoc

Private cFilPad		:= ""
Private aIndexFil	:= {}
Private bFiltraBrw

Private __lCusto	:= .F.
Private __lItem 	:= .F.
Private __lCLVL		:= .F.
Private aCtbEntid	:= NIL

_lForcHead := .T.
_lForcCrTmp := .T.

If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
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

For nX := 5 TO nQtdEntid
	aCtbEntid[1, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"DB } ")  //debito
	aCtbEntid[2, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"CR } ")  //credito
Next 

cPictVal  := PesqPict("CT2","CT2_VALOR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna o tipo de saldo dos lançamentos da rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
__cTpSaldo	:= CT103TpSld()

If Empty(__cTpSaldo)
	Return
EndIf

SX5->(dbSetOrder(1))

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

SetKey(VK_F12,{|a,b|AcessaPerg("CTB103B",.T.)})
Pergunte("CTB103B",.F.)


dbSelectArea("CT2")
dbSetOrder(1)
	
oBrowse := FWMBrowse():New()
if MV_PAR01 = 1 
 	lUsarCTC := .T.
endif
                                         
if lUsarCTC

	cFilPad := "CTC_TPSALD = '"+__cTpSaldo+"'"
    oBrowse:SetAlias("CTC")
	oBrowse:SetDescription(STR0006) // "Lan‡amentos Cont beis - Automaticos"
	aLegenda := CtbLegenda("CTC")
	for nX := 1 To Len(aLegenda)
		oBrowse:AddLegend( aLegenda[nX,1],  aLegenda[nX,2] ,  aLegenda[nX,3] )
	next            
	
	If !Empty( cFilPad )
		oBrowse:SetFilterDefault( cFilPad )
	EndIf
	
else           
	cFilPad := "CT2_TPSALD = '"+__cTpSaldo+"'"

    oBrowse:SetAlias("CT2")
	oBrowse:SetDescription(STR0006) // "Lan‡amentos Cont beis - Automaticos"
	aLegenda := CtbLegenda("CT2")
	for nX := 1 To Len(aLegenda)
		oBrowse:AddLegend( aLegenda[nX,1],  aLegenda[nX,2] ,  aLegenda[nX,3] )
	next
	If !Empty( cFilPad )
		oBrowse:SetFilterDefault( cFilPad )
	EndIf
   
endif    
    
oBrowse:Activate()
dbSetOrder(1)

If Select("TMP") > 0
	dbSelectArea("TMP")
	dbCloseArea()
EndIf

If lUsarCTC
	dbSelectArea("CTC")
Else
	dbSelectArea("CT2")
EndIf

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

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT103TpSld³ Autor ³ Alvaro Camillo Neto  ³ Data ³ 13.10.09  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o tipo de saldo dos lançamentos da rotina           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT103TpSld()
Local cTipoSaldo := ""
Local aArea		  := GetArea()
Local aAreaSX6	  := SX6->(GetArea())
Local aPerguntas := {}
Local aRet		  := {}
SaveInter()

cTipoSaldo := SuperGetMv("MV_CT103SL",.F.,"")

//Caso não seja informado o tipo de saldo, abre tela para parametrização
If Empty(cTipoSaldo) .Or. !SX5->(MsSeek( xFilial("SX5") + "SL" + cTipoSaldo ))
	aAdd(aPerguntas,{1,STR0014,Space(1),"@!","NaoVazio()","SLD",,2,.T.}) //"Tipo de Saldo"
	If ParamBox(aPerguntas,STR0014,@aRet) //"Tipo de Saldo"
		cTipoSaldo := aRet[1]
		If SX5->(MsSeek( xFilial("SX5") + "SL" + cTipoSaldo ))
			If !Empty(cTipoSaldo)
				PutMV("MV_CT103SL",cTipoSaldo)
			EndIf
		Else
			Help(" ",1,"CT103NOSL",,STR0049,4)//"Tipo de saldo inválido"
			cTipoSaldo := ""
		EndIf
	Endif
EndIf

cTipoSaldo := AllTrim(cTipoSaldo)

RestInter()
RestArea(aAreaSX6)
RestArea(aArea)
Return cTipoSaldo


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA103Cal³ Autor ³ Alvaro Camillo Neto  ³ Data ³ 13.10.09  ³±±
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
Function Ctba103Cal(cAlias,nReg,nOpc)

Local dDataLanc	:= dDataBase
Local cLote			:= ""
Local	cSubLote		:= ""
Local	cDoc			:= ""
Local CTF_LOCK		:= 0
Local nTotInf		:= 0
Local cCodSeq		:= ""
Local cSegOfi 		:= SuperGetMv( "MV_SEGOFI" , .F. , "0" )
Local lSeqCorr		:= UsaSeqCor("CT2/CTK/CT5")
Local lRet			:= .T.
Local dDataCTF      := CtoD("")
Local aAreaCTF      := {}

If FunName() == "CTBA103" .And. nOpc == 3 .And. !VerSenha(191)
	Return
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Se o alias do BROWSE é o CTC devemos possicionar na CT2 no   ³
³primeiro registro do lote que está na CTC                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
if cAlias = "CTC"
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

If lRet .And. nOpc == 5 .And. lSeqCorr .And. cSegOfi == '5'
	Help(" ",1,"CORRNOEXC")
	lRet := .F.
EndIf  

If lRet .And. (nOpc == 5 .Or. nOpc == 4)
	lRet := CTBValFila(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DATA,.T.)
EndIf

If lRet
	If Ctba103Cap(cAlias,nReg,nOpc,'CTBA103',@dDataLanc,@cLote,@cSubLote,@cDoc,@CTF_LOCK,@nTotInf,@cCodSeq)
		Ctba103Lan(nOpc,dDataLanc,cLote,cSubLote,cDoc,cAlias,nReg,@CTF_LOCK,nTotInf,cCodSeq)
	Else
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
	
	IF nOpc != 3
		Ct102SmltF( Dtos( dDataLanc	) + cLote + cSubLote + cDoc  ) // libera o documento para que o proximo possa usar
	ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Destrava Todos os Registros                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsUnLockAll()
	FreeUsedCode(.T.)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA103Cap³ Autor ³ Alvaro Camillo Neto  ³ Data ³ 13.10.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Capa de Lote                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba103Cap(cAlias,nReg,nOpca,cProg,dDatalanc,cLote,cSubLote³±±
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
Function Ctba103Cap(cAlias,nReg,nOpc,cProg,dDataLanc,cLote,cSubLote,cDoc,CTF_LOCK,nTotInf,cCodSeq)

Local oDlg
Local oDoc
Local oLote
Local oSubLote
Local oInf, oInfLot
Local oLinha
Local oCodSeq

Local aAreaCT2	:= CT2->(GetArea())
Local lContinua := .F.
Local cLinha 	:= ""
Local cTitulo	:= ""
Local nTotInfLot := 0
Local lDigita	:= .F.
Local aCT103ACAP := {}

Local l103Inclui	:= .F.
Local l103Visual	:= .F.
Local l103Altera	:= .F.
Local l103Exclui	:= .F.
Local l103Estorna	:= .F.
Local l103Copia	:= .F.

Local lSeqCorr := ( UsaSeqCor() ) // Controle do Correlativo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nOpc == 2
		l103Visual := .T.
	Case nOpc == 3
		l103Inclui	:= .T.
		lDigita		:= .T.
	Case nOpc ==  4
		l103Altera	:= .T.
	Case nOpc ==  5
		l103Exclui	:= .T.
		l103Visual	:= .T.
	Case nOpc == 6
		l103Estorna	:= .T.
	Case nOpc == 7
		l103Copia	:= .T.
EndCase


dDataLanc	:= dDataBase
cLote		:= CriaVar("CT2_LOTE")
cSubLote	:= If(lSubLote, CriaVar("CT2_SBLOTE"), cLoteSub )
cDoc		:= CriaVar("CT2_DOC")

__lCusto	:= CtbMovSaldo("CTT")
__lItem		:= CtbMovSaldo("CTD")
__lCLVL		:= CtbMovSaldo("CTH")

If lSeqCorr
	cCodSeq := CtbRdia()
EndIf

If l103Inclui .Or. l103Copia .Or. l103Estorna
	
	If ! Empty( cSubLote ) .AND. Len( alltrim( cSubLote )) < 3
		cSubLote := StrZero( cSubLote , 3 )
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para preenchimento do lote/sublote     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _lCT103ACAP
		
		aCT103ACAP := ExecBlock( "CT103ACAP", .F., .F. )
		
		If ValType(aCT103ACAP) == "A" .and. Len(aCT103ACAP) > 0
			
			If !Empty(aCT103ACAP[1])
				cLote := aCT103ACAP[1]
			Endif
			
			If Len(aCT103ACAP) > 1
				If !Empty(aCT103ACAP[2])
					cSubLote := aCT103ACAP[2]
				Endif
			Endif
		Endif
	Endif
Else
	dDataLanc:= CT2->CT2_DATA
	cLote		:= CT2->CT2_LOTE
	cSubLote	:= CT2->CT2_SBLOTE
	cDoc		:= CT2->CT2_DOC
	If lSeqCorr
		cCodSeq := CT2->CT2_DIACTB
	EndIf
Endif

If !l103Visual
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
	
	// se não for inclusão
	// verifica se existe algum usuario concorrente
	If ! l103Inclui .And. ! Ctb102Smlt( Dtos( dDataLanc	) + cLote + cSubLote + cDoc )
		MsgAlert( STR0039 ) // 'Documento em uso por outro usuario!'
		RETURN
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela da capa do lote   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cTitulo := OemToAnsi(STR0007)
	
	If ! l103Exclui
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 33,25 TO 260,369 PIXEL  //"Capa de Lote - Lan‡amentos Cont beis"
		
		@ 001,005 TO 032, 140 OF oDlg PIXEL
		@ 035,005 TO 066, 140 OF oDlg PIXEL
		
		@ 004,008 	SAY OemToAnsi(STR0008) SIZE 55, 7 OF oDlg PIXEL  //"Data Lan‡amento"
		@ 014,008 	MSGET oDataLanc VAR dDataLanc Picture "99/99/99" When lDigita Valid NaoVazio(dDataLanc) .And. ;
		CtbValiDt(nOpc,dDataLanc,,__cTpSaldo) .And. IIf(Empty(cLote),C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,oLote,oSubLote,oDoc,@CTF_LOCK,nOpc,1),.T.);
		.And. CtbMedias(dDataLanc) ;
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
		
		@ 074,005 	SAY OemToAnsi(STR0018) SIZE 60, 7 OF oDlg PIXEL 	//"Total Informado Docto"
		@ 070,080 	MSGET oInf VAR nTotInf  Picture cPictVal;
		When (l103Inclui .Or. l103Altera);
		SIZE 80, 11 OF oDlg PIXEL HASBUTTON
		
		@ 089,005 	SAY OemToAnsi(STR0019) SIZE 60, 7 OF oDlg PIXEL	//"Total Informado Lote"
		@ 085,080 	MSGET oInfLot VAR nTotInfLot Picture cPictVal;
		When .F. SIZE 80, 11 OF oDlg PIXEL HASBUTTON
		
		
		DEFINE SBUTTON FROM 05, 142 TYPE 1 ACTION (lContinua := .T.,;
		Iif(lDigita,Iif(Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK) .And.;
		Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK) .And.;
		Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK,nOpc) .And.;
		c102CapOk(dDataLanc,cLote,cSubLote,cDoc) .And.;
		c103Caplote(dDataLanc,cLote,cSubLote,cDoc,nOpc) .And.;
		CtbProxLin(dDataLanc,cLote,cSubLote,cDoc,@cLinha,@oLinha),;
		oDlg:End(),lContinua := .F.),;
		Iif(c103Caplote(dDataLanc,cLote,cSubLote,cDoc,nOpc) .and. ;
		CtbVldLP(dDataLanc,cLote,cSubLote,cDoc,nOpc) .And.;
		CtbTmpBloq(dDataLanc,cLote,cSubLote,cDoc,nOpc,cProg) .and.;
		CtbValiDt(nOpc,dDataLanc,,__cTpSaldo),;
		oDlg:End(),lContinua := .F.))) ENABLE OF oDlg
		
		DEFINE SBUTTON FROM 19, 142 TYPE 2 ACTION (lContinua := .F.,oDlg:End()) ENABLE OF oDlg
		
		ACTIVATE MSDIALOg oDlg CENTERED
	Else
		// caso for exclusão, passa direto sem a capa do lote
		lContinua := .T.
	EndIf
Else
	lContinua := .T.
EndIf

RestArea(aAreaCT2)

Return lContinua

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA103Lan³ Autor ³ Alvaro Camillo Neto  ³ Data ³ 13.10.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta tela de lancamento contabil                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba103Lan(nOpc,dDatalanc,cLote,cSubLote,cDoc,cAlias,nReg, ³±±
±±³          ³ CTF_LOCK,nTotInf)                                          ³±±
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
Function Ctba103Lan(nOpc,dDataMov,cLoteMov,cSubLoteMov,cDocMov,cAlias,nReg,CTF_LOCK,nTotMov,cCodSeq,cArq1,cArq2)

Local aCampos		:= {}
Local aTotais 		:= {{0,0,0,0},{0,0,0,0}}
Local aButton 	:= {}
Local aSize		:= {}

Local lDel 	  		:= .F.

Local nOpcGDB		:= nOpc	//Variavel para carregar a GetDB

Local oDlg,oInf,oFnt,oPanel1,oPanel2,oPanel3

Local cExpFil	:= ""
Local cTxtfil	:= ""
Local cLinhaAlt := "001"

Local l103Inclui	:= .F.
Local l103Visual	:= .F.
Local l103Altera	:= .F.
Local l103Exclui	:= .F.
Local l103Estorna	:= .F.
Local l103Copia	:= .F.

Local lContinua	:= .T.
Local aButBrowse:= {}

Local lOk := .F.
Local nX  := 0
Local lSeqCorr := .F.
Local cSeqCorr := Space(10)
Local aAreaCT2	:= CT2->(GetArea())
Local dDataCTF      := CtoD("")
Local aAreaCTF      := {}

Private oDescEnt,oDig,oDeb,oCred,oGetDB
Private OPCAO
Private aTotRdpe := {{0,0,0,0},{0,0,0,0}}
Private aColsP		:= {}

// Variáveis private para as validações dos fontes CTBA105 e CTBA102
Private dDataLanc	:= dDataMov
Private cLote		:= cLoteMov
Private cSubLote	:= cSubLoteMov
Private cDoc		:= cDocMov
Private nTotInf	:= nTotMov

DEFAULT _lNewSemaf := Iif(GetRPORelease() >= "12.1.031"  .or. CTF->(FieldPos('CTF_USADO')),.T.,.F.) ////o semaforo só será habilitado apartir da 12.1.31

If Type("aHeader") != "A"
	Private aHeader	:= {}
	Private aAltera	:= {}
EndIf

lSeqCorr := ( UsaSeqCor() ) // Controle do Correlativo

IF lSeqCorr
	If (nOpc == 3 .Or. nOpc == 7)
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
		l103Visual := .T.
	Case nOpc == 3
		l103Inclui	:= .T.
		lDel := .T.
		nOpcGDB := 4
	Case nOpc ==  4
		l103Altera	:= .T.
		lDel := .T.
	Case nOpc ==  5
		l103Exclui	:= .T.
	Case nOpc == 6
		l103Estorna	:= .T.
		nOpcGDB := 4
		lDel := .T.
	Case nOpc == 7
		l103Copia	:= .T.
		nOpcGDB := 4
		lDel := .T.
EndCase


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Getdados para Lan‡amentos Cont beis                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l103Estorna .And. !l103Copia

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

	lContinua := Ctb103Carr(nOpc,@dDataLanc,cLote,cSubLote,cDoc,@cLinhaAlt)

Else
	lContinua := .T.
EndIf

//³ Montagem dos botoes da barra de ferramentas                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aButton, {"RECALC"   , { || MsAguarde({|| CtRecRdPe()},STR0041) },STR0020 } )//"Recalculando totais..."#"Rec.Totais"
Aadd( aButton, {"SIMULACAO",{ || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc)}, STR0025+" - <F5>", STR0015	} ) //"Totais do lote e documento (outras moedas)"	"Totais"
Aadd( aButton, {"PREV"     ,{ || CTB105Flt (oGetDb,.F.                   )}, STR0027 ,STR0029                    	} ) //"Inconsistencia Anterior" //"Anterior"
Aadd( aButton, {"NEXT"     ,{ || CTB105Flt (oGetDb,.T.                   )}, STR0030 	,STR0031					} ) //"Proxima Inconsistencia" //"Próxima"

If l103Visual .Or. l103Exclui
	Aadd( aButton, {"CTBLANC"   ,{ || Ctb102Lcto()}, STR0032	,STR0033 } ) //"Detalhes do lançamento posicionado"###"Detalhes"
EndIf

If l103Inclui .Or. l103Altera
	Aadd( aButton, {"CTBREPLA"   ,{ || Ctb102Repla()}, STR0034 ,STR0036		} ) //"Replicar o conteudo do campo posicionado"###"Replicar"
EndIf

aButton := AddToExcel(aButton,{	{"ARRAY",STR0037,{STR0008,STR0009,STR0028,STR0010},{{dDataLanc,cLote,cSubLote,cDoc}}},{"GETDB",STR0038,aHeader,"TMP"} } ) //"Documento"###"Lançamentos"
Aadd( aButton, {"PESQUISA"   ,{ || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil     )}, STR0040 						} ) //"Localizar"

//Ponto de entrada ´para inclusao de botao
IF _lCT103BTO
	aButBrowse := ExecBlock("CT103BTO",.F.,.F.,{aButton})
	
	IF ValType(aButBrowse) == "A" .AND. Len(aButBrowse) > 0
		FOR nX := 1 to len(aButBrowse)
			aAdd(aButton,aButBrowse[nX])
		NEXT
	ENDIF
ENDIF

If lContinua
	
	SetKey(VK_F4,{ || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc) })
	SetKey(VK_F5,{ || CTB105Flt (oGetDb,.F.                   ) })
	SetKey(VK_F6,{ || CTB105Flt (oGetDb,.T.                   ) })
	SetKey(VK_F7,{ || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil     ) })
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize(,.F.,400)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
	oDlg:lMaximized := .T.
	
	oPanel1 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,200,35,.T.,.T. )
	oPanel1:Align := CONTROL_ALIGN_TOP
	
	oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,200,40,.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanel3 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,200,60,.T.,.T. )
	oPanel3:Align := CONTROL_ALIGN_BOTTOM
	
	
	DEFINE FONT oFnt 	NAME "Arial" SIZE 0, -11 BOLD
	
	@ 12 ,5  	Say OemToAnsi(STR0008) SIZE 30,9 PIXEl OF oPanel1 FONT oFnt					//"Data"
	@ 11 ,23  	MSGET dDataLanc  Picture "99/99/9999" WHEN .F.	PIXEl;
	SIZE 45, 10 OF oPanel1 HASBUTTON
	
	@ 12 ,83   	Say OemToAnsi(STR0009) SIZE 30,9 PIXEl	OF oPanel1 FONT oFnt				//"Lote"
	@ 11 ,101	MSGET oLote VAR cLote Picture "@!" WHEN .F. PIXEl SIZE 32, 10 OF oPanel1
	
	@ 12 ,142  	Say OemToAnsi(STR0028) SIZE 40,9 PIXEl	OF oPanel1 FONT oFnt				//"Sub-Lote"
	@ 11 ,172	MSGET cSubLote Picture "!!!" WHEN .F. PIXEl;
	SIZE 24, 10 OF oPanel1
	
	@ 12 ,212	Say OemToAnsi(STR0010) SIZE 30,9 PIXEl	OF oPanel1	FONT oFnt			//"Docto"
	@ 11 ,234	MSGET cDoc Picture "999999" WHEN .F.  PIXEl;
	SIZE 34, 10 OF oPanel1
	
	If lSeqCorr
		@ 12 ,284	Say OemToAnsi(STR0035) PIXEl	OF oPanel1 SIZE 50,9 FONT oFnt	//"Correlativo"
		@ 11 ,318	MSGET cSeqCorr Picture PesqPict("CT2","CT2_NODIA") WHEN .F.  PIXEl;
		SIZE 80, 10 OF oPanel1
	EndIf
	
	TMP->(dbSetOrder(0))
	
	Ctb102TamHist()
	
	OPCAO := nOpc		// variavel para ser usado na LinOk
	
	nDbRecTMP := TMP->( RECNO() )  // guardo o recno para tratamento da getDB
	
	oGetDB := 	MSGetDB():New( 034, 005, 226, 415, nOpcGDB,"CT105LINOK() .AND. VldVlrLanc(.F.)", "CT103TpSal() .And. CT105TOk() .AND. VldVlrLanc(.T.)", "+CT2_LINHA",lDel,aAltera,,.t., SuperGetMv("MV_NUMMAN"),"TMP","CTBA102Mod()",,,oPanel2,,,"CT102DEL")
	oGetDB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	Ctb102TamHist(.T.)
	
	// restauro o posicionamento da getDb
	IF nDbRecTMP <> TMP->( RECNO() )
		oGetDB:Goto( nDbRecTMP )
	ENDIF
	
	aTotais		:= CtbTotMov()
	
	aTotRdpe[1][2]		:= aTotais[1][2] //Valor debito
	aTotRdpe[1][3]		:= aTotais[1][3] //Valor credito
	aTotRdpe[1][1]		:= aTotais[1][1] //Valor digitado
	
	@ 6  ,8   	SAY OemToAnsi(STR0026)	Of oPanel3 PIXEL 	FONT oFnt		//"Descri‡„o da Entidade"
	@ 6  ,73 	SAY oDescEnt PROMPT space(50) FONT oDlg:oFont PIXEL COLOR CLR_HBLUE	Of oPanel3
	
	@ 20 ,8  	SAY OemToAnsi(STR0021) Of oPanel3 PIXEL	FONT oFnt				//"Total Informado :"
	@ 40 ,8  	SAY OemToAnsi(STR0022) Of oPanel3 PIXEL	FONT oFnt				//"Total Digitado  :"
	@ 21 ,65 	MSGET oInf 	VAR nTotInf 	Picture cPictVal Of oPanel3 READONLY SIZE 95 ,9 PIXEL
	@ 41 ,65 	MSGET oDig 	VAR aTotRdpe[1][1]	Picture cPictVal Of oPanel3 READONLY SIZE 95 ,9 PIXEL
	@ 20 ,190 	SAY OemToAnsi(STR0023) Of oPanel3 PIXEL	FONT oFnt				//"Total Debito  :"
	@ 40 ,190	SAY OemToAnsi(STR0024) Of oPanel3 PIXEL FONT oFnt				//"Total Credito :"
	@ 21 ,240	MSGET oDeb 	VAR aTotRdPe[1][2]	Picture cPictVal Of oPanel3 READONLY SIZE 95 ,9 PIXEL
	@ 41 ,240	MSGET oCred VAR aTotRdPe[1][3] Picture cPictVal Of oPanel3 READONLY SIZE 95 ,9 PIXEL
	
	
	ACTIVATE MSDIALOG oDlg ON INIT (oGetDB:oBrowse:Refresh(),;
	EnchoiceBar(oDlg,{|| If( VldVlrLanc(.T.) .AND. CT103TpSal() .And. Ct105TOK(_lCT105TOK,_lCT105CHK,oGetDB:lModified,,aTotRdpe,nTotInf,,__cTpSaldo),;
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a gravação dos lançamentos                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOk .And. (!l103Visual)
		If l103Exclui .And. _lCTB103EXC
			lOk := ExecBlock("CTB103EXC",.F.,.F.)
		EndIf
		
		If lOk
			If _lANCTB103GR
				ExecBlock("ANCTB103GR",.F.,.F.,{ nOpc,dDataLanc,cLote,cSubLote,cDoc }  )
			Endif
			
			//funcao para exclusao poder ser usado CTF novamente msm numero
			If nOpc == 5 .And. _lNewSemaf  //exclusao - colocado aqui tb pois qdo soh tem moeda 01 a destrava eh chamada dentro da CtbGrava
				If FindFunction("CtSetRcCTF") //CONFIRMADO EXCLUSAO - VERSAO 12.1.33
					CtSetRcCTF(.T.)  //QUANDO EXCLUIR SETA PARA UNLOCKDOC COLOCAR CAMPO CTF_USADO = 'R' --> PODE SER RECUPERADO ESTE NUMERO
				EndIf
			Endif

			CTBGrava(nOpc,dDataLanc,cLote,cSubLote,cDoc,.F.,"",__lCusto,__lItem,__lCLVL,nTotInf,'CTBA103',,,cEmpAnt,cFilAnt,,,,,,,cSeqCorr)
			
			If _lDPCTB103GR
				ExecBlock("DPCTB103GR",.F.,.F.,{ nOpc,dDatalanc,cLote,cSubLote,cDoc } )
			Endif
			//funcao para exclusao poder ser usado CTF novamente msm numero
			If nOpc == 5 .And. _lNewSemaf  //exclusao
				Ct103RcCTF(dDataLanc,cLote,cSubLote,cDoc)
			Endif

		EndIf

	ElseIf ! lOk  .And. l103Inclui .And. _lNewSemaf //Se cancelar na Inclusao deve voltar CTF_USADO para X
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
EndIf

//limpa arquivo temporario para quando voltar para outro documento 
dbSelectArea( "TMP" )
If Alias() == "TMP"
	Ctb_ZapTmp() //Zap
EndIf
TMP->( dbGotop() )

dbSelectArea( "CT2" )

RestArea(aAreaCT2)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB103Carr³ Autor ³ Alcaro Camillo Neto   ³ Data ³ 26.10.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega arq. temporario com dados para MSGETDB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB103Carr(nOpc,dDataLanc,cLote,cSubLote,cDoc)             ³±±
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
Static Function CTB103Carr(nOpc,dLanc,cPLote,cPSubLote,cPDoc,cLinhaAlt)
Local aSaveArea	 	:= GetArea()
Local aAreaCT2	 		:= CT2->(GetArea())
Local cAlias	 		:= "CT2"
Local cCritConv	 	:= ""
Local nPos
Local cMoeda
Local nVezes	 		:= 1
Local nC		 			:= 0
Local nTamCrit	 		:= Len(CriaVar("CT2_CONVER"))
Local nCont
Local lContinua		:= .T.
Local dDataLanc		:= dLanc
Local cLote 	 		:= cPLote
Local cSubLote	 		:= cPSubLote
Local cDoc		 		:= cPDoc
Local cFilialCT2

Local lCt103Carr := _lCt103Carr
Local nRecnoCT2	 := CT2->( Recno() )

Local lSeqCorr   := .F.
Local cSeqCorr 	 := Space(10)

DEFAULT cLinhaAlt:= "000"


lSeqCorr := ( UsaSeqCor() ) // Controle do Correlativo

If nOpc <> 3						// Visualizacao / Alteracao / Exclusao
	
	dDataLanc 	:= CT2->CT2_DATA
	cLote 	 	:= CT2->CT2_LOTE
	cSubLote		:= CT2->CT2_SBLOTE
	cDoc			:= CT2->CT2_DOC
	
	dbSelectArea("CT2")
	dbSetOrder(1)
	
	cFilialCT2 := xFilial( "CT2" )
	cLinhaAlt := FieldGet(FieldPos("CT2_LINHA"))
	
	If MsSeek( cFilialCT2 + Dtos(dDataLanc) + cLote + cSubLote + cDoc )
		
		If lSeqCorr
			
			If (nOpc == 3)
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
			If CT2->CT2_MOEDLC <> '01'
				dbSkip()
				Loop
			EndIf
			

			If ALLTRIM(CT2->CT2_TPSALD) != ALLTRIM(__cTpSaldo)
				dbSkip()
				Loop
			EndIf

			RecLock("TMP",.T.)
			
			For nCont := 1 To Len(aHeader)
				nPos := FieldPos(aHeader[nCont][2])
				If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
					FieldPut(nPos,(cAlias)->(FieldGet(FieldPos(aHeader[nCont][2]))))
				EndIf
			Next nCont
			
			TMP->CT2_FLAG 		:= .F.
			TMP->CT2_SEQLAN	:= CT2->CT2_SEQLAN
			TMP->CT2_SEQHIS	:= CT2->CT2_SEQHIS
			TMP->CT2_EMPORI	:= CT2->CT2_EMPORI
			TMP->CT2_FILORI	:= CT2->CT2_FILORI
			TMP->CT2_KEY		:= CT2->CT2_KEY
			TMP->CT2_RECNO		:= CT2->(Recno())
			cCritConv			:= CT2->CT2_CRCONV
			cMoeda				:= CT2->CT2_MOEDLC
			TMP->CT2_ALI_WT 	:= "CT2"
			TMP->CT2_REC_WT 	:= If(nOpc==7,0,CT2->(Recno()))
			TMP->CT2_TPSALD	:= __cTpSaldo
			
			IF lCt103Carr
				ExecBlock("Ct103Carr",.F.,.F.,{ nOpc,dDataLanc,cLote,cSubLote,cDoc }  )
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

			MsUnlock()
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
	
	TMP->CT2_FLAG 		:= .F.
	TMP->CT2_LINHA		:= "001"
	TMP->CT2_ALI_WT 	:= "CT2"
	TMP->CT2_REC_WT 	:= 0
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

IF cLinhaAlt <> "001"
	TMP->( DbSeek( cLinhaAlt ) )
ELSE
	TMP->( dbGoTop() )
ENDIF


Return lContinua

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³c103Caplote³ Autor ³ Alvaro Camillo Neto  ³ Data ³ 13.10.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Para chamar o ponto de Entrada VLCPLOTE				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³c103Caplote(dDataLanc,cLote,cSubLote,cDoc,nOpc)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA103                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data do Lancamento                                 ³±±
±±³          ³ ExpC1 = Numero do Lote do Lancamento                       ³±±
±±³          ³ ExpC2 = Numero do Sub-Lote do Lancamento                   ³±±
±±³          ³ ExpC3 = Numero do documento do Lancamento                  ³±±
±±³          ³ ExpN1 = Numero da opcao escolhida                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function c103Caplote(dDataLanc,cLote,cSubLote,cDoc,nOpc)

Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA VCLOT103                            ³
//³ Criado para poder verificar se o lancamento vindo de ³
//³ outro modulo podera ser alterado ou nao. Podera ser	 ³
//³ chamado na inclusao ou alteracao.                    ³
//³ ParamIxb:Data,Lote,Sub-Lote,Doc, nOpc.   	         ³
//³ Devera retornar .T. ou .F., pois sera utilizado na   ³
//³ validacao do botao OK.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If _lVCLOT103
	lRet := ExecBlock("VCLOT103",.F.,.F.,{dDataLanc,cLote,cSubLote,cDoc,nOpc})
Endif

Return(lRet)

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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
Local aCT103BUT
Local aRotina
Local nX := 1

aRotina := { 	{STR0001 ,"AxPesqui"  	, 0 , 1,,.F.},; // "Pesquisar"
				{STR0002 ,"Ctba103Cal"	, 0 , 2     },; // "Visualizar"
				{STR0003, "Ctba103Cal"  , 0 , 3, 191},; // "Incluir" 
				{STR0004 ,"Ctba103Cal"	, 0 , 4     },; // "Alterar"
				{STR0005 ,"Ctba103Cal"	, 0 , 5     },; // "Excluir"
				{STR0011 ,"Ctbm103"		, 0 , 3     },; // "Copiar"
				{STR0052, "CtbLctExtp"  , 0 , 4     },; // "Lct.Extemp"
				{STR0053, "CTBS470"  , 0 , 4     },; // "Lct. Transf. Saldo"
				{STR0013 ,"CtbC010Rot"	, 0 , 2     } } // "Rastrear"

IF _lCT103BUT
	aCT103BUT := ExecBlock("CT103BUT",.F.,.F.,aRotina)
	
	IF ValType(aCT103BUT) == "A" .AND. Len(aCT103BUT) > 0
		FOR nX := 1 to len(aCT103BUT)
			aAdd(aRotina,aCT103BUT[nX])
		NEXT
	ENDIF
ENDIF

Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb103HeaderWTºAutor  ³Paulo Carnelossi  º Data ³ 20/03/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar no aheader os campos ALIAS _ALI_WT / _REC_WT para    º±±
±±º          ³utilizar nas getdados que nao possa utilizar fillgetdados() º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb103HeaderWT(cAlias, aHeader)
Local aArea := GetARea()
Local aAreaSX3 := SX3->(GetArea())
Local cUsado

dbSelectArea("SX3")
dbSetOrder(2)
cAlias := Alltrim(cAlias)

If SX3->(DbSeek(cAlias+"_FILIAL"))
	cUsado := SX3->X3_USADO
	
	AADD( aHeader, { "Alias WT", cAlias+"_ALI_WT", "", 09, 0,, cUsado, "C", cAlias, "V"} )
	AADD( aHeader, { "Recno WT", cAlias+"_REC_WT", "", 09, 0,, cUsado, "N", cAlias, "V"} )
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTBM103  ³ Autor ³ Alvaro Camillo Neto  ³ Data ³ 13.10.09  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função que copia os lançamentos do range selecionado para  º±±
±±º          ³ o tipo de saldo parametrizado da rotina                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial - Movimentacoes                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ctbm103(cAlias,nReg,nOpc)

Local aArea       := GetArea()
Local cPerg       := "CTB103A"
Local CTF_LOCK		:= 0
Local nTotInf     := 0
Local cCodSeq     := 0
Local lRet			:= .T.
Local dDataLanc	:= CtoD("")
Local cLote			:= ""
Local cSubLote		:= ""
Local cDoc 			:= ""
Local lDefTop 		:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)

Private aHeader	:= {}
Private aAltera	:= {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros Cópia lanc.  			  ³
//³ mv_par01 // Tipo de Cópia				                          ³
//³ mv_par02 // Saldo de Origem		                             ³
//³ mv_par03 // Da data					                             ³
//³ mv_par04 // Até a data										           ³
//³ mv_par05 // Do Lote											           ³
//³ mv_par06 // Até o Lote										           ³
//³ mv_par07 // Do Sublote				   					           ³
//³ mv_par08 // Até o Sublote					              			  ³
//³ mv_par09 // Do Documento							        			  ³
//³ mv_par10 // Ate o Documento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Retira o filtro caso seja DBF
If !lDefTop
	EndFilBrw("CT2",aIndexFil)
EndIf
//Guarda variaveis dos parametros em memoria
If Ctba103Cap(cAlias,nReg,3,'CTBA103',@dDataLanc,@cLote,@cSubLote,@cDoc,@CTF_LOCK,@nTotInf,@cCodSeq)
	If Pergunte(cPerg,.T.)
		nOpc := IIF(mv_par01 == 1, 7 , 6 )
		Processa( { || lRet :=CTM103Sel(nOpc,dDataLanc,cLote,cSubLote,cDoc,nTotInf,cCodSeq) },, STR0017) //"Selecionando lançamentos"
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Reposiciona o filtro caso seja DBF
If !lDefTop
	Eval(bFiltraBrw)
EndIf

MsUnLockAll()
FreeUsedCode(.T.)
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTM103Sel³ Autor ³ Alvaro Camillo Neto  ³ Data ³ 13.10.09 ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Seleciona os registro que irão compor a tela de cópia      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTM103Sel(nOpc,dDataEst,cLoteEst,cSubLtEst,cDocEst,nTotInf,cCodSeq)

Local aArea		:= GetArea()
Local aAreaCT2	:= CT2->( GetArea() )
Local aAreaCT7	:= CT7->( GetArea() )
Local nCont		:= 0
Local lRet		:= .T.
Local cCadastro:= STR0042 //"Cópia de movimentos"
Local aQuais	:= {}
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
Local oNo 		:= LoadBitmap( GetResources(), "LBNO")
Local oDlg
Local oQual
Local aCampos
Local cTipSalOri	:= MV_PAR02
Local dDataOri 	:= CtoD("") 
Local cLoteOri 	:= ""
Local cSbloteOri 	:= ""
Local cDocOri		:= ""
Local cLinOri		:= ""
Local cLinhaAlt   := "" 
Local nLinha		:= 0
Local lContinua	:= .T.
Local CTF_LOCK		:= 0 
Local cArq1			:= ""
Local cArq2			:= ""

CT2->( dbSetOrder( 1 ) ) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC

aQuais := CT103Lotes()
//Monta LISTBOX com os lotes/docs escolhidos pelo usuario para serem estornados.

If Len(aQuais) > 0
	
	nOpca := 0
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,40 OF oMainWnd
	
	DEFINE FONT oFnt1	NAME "Arial" 			Size 10,12 BOLD
	@ 0.3,.5 Say cCadastro FONT oFnt1 COLOR CLR_RED	  //"Estorno de lancamento por lote"
	
	@ 13,04 BUTTON STR0043 PIXEL OF oDlg SIZE 50,11; //"Inverte Selecao"
	ACTION (	aEval(oQual:aArray, {|e| 	e[1] := ! e[1] }),;
	oQual:Refresh())
	
	@ 2,.5  LISTBOX oQual VAR cVarQ Fields HEADER "",STR0044; //"Data/Lote/Sublote/Documento"
	SIZE 150,100 ON DBLCLICK ;
	(aQuais:=CT103Troca(oQual:nAt,aQuais),oQual:Refresh()) NOSCROLL	//"Lotes a serem estornados"
	oQual:SetArray(aQuais)
	oQual:bLine := { || {if(aQuais[oQual:nAt,1],oOk,oNo),aQuais[oQual:nAt,2]}}
	
	DEFINE SBUTTON FROM 130.5,80	TYPE 1 ACTION (nOpca := 1,IF(ct103OK(aQuais),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 130.5,110	TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpca == 1
		
		If _lVCTB103EST // opção de validação do estorno do lançamento
			If ! ExecBlock("VCTB103EST",.F.,.F.,{dDataLanc,cLote,cSubLote,cDoc,nTotInf})
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
		
		ProcRegua( 0 )
		
		CT2->( dbSetOrder( 1 ) ) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
		
		nCont := 1
		While nCont <= Len(aQuais)
			If aQuais[nCont][1]
				IncProc( STR0046 + aQuais[nCont][2] )// "Processando Lançamento Nº.: "
				If lContinua
					dDataOri	:= CTOD(Subs(aQuais[nCont][2],1,10))
					nSomaPos := 0
					If ( Len( Dtoc( dDataOri ) ) == 10 ) // data com 10 posicoes ( xx/xx/xxxx )
						nSomaPos := 2	// seto a variavel de soma para 2
					Endif
					cLoteOri	:= Subs( aQuais[nCont][2], 10 + nSomaPos, 6 )
					cSbloteOri	:= Subs( aQuais[nCont][2], 17 + nSomaPos, 3 )
					cDocOri		:= Subs( aQuais[nCont][2], 21 + nSomaPos, 6 )
					cLinOri		:= "001"
				EndIf

				cChaveOri	:= xFilial( "CT2" ) + DTOS( dDataOri ) + cLoteOri + cSbloteOri + cDocOri + cLinOri // chave de busca do documento contabil
				
				If CT2->(MsSeek( cChaveOri  )) 
					lContinua := CT103CarEst(nOpc,@dDataOri,@cLoteOri,@cSbloteOri,@cDocOri,@cLinOri,@cLinhaAlt,cTipSalOri,@nLinha,cCodSeq)
					If lContinua // Não Passou o limite de linha do documento
						nCont++
					Else
						nLinha 		:= 0
						cLinhaAlt	:= ""
						// Apresenta tela
						TMP->(dbGoTop())
						Ctba103Lan(nOpc,dDataEst,cLoteEst,cSubLtEst,cDocEst,"CT2",CT2->(recno()),@CTF_LOCK,nTotInf,cCodSeq,cArq1,cArq2)
						// Pega um novo numero de documento para o lote
						CTM103ProxDoc( dDataEst,@cLoteEst,@cSubLtEst,@cDocEst , @CTF_LOCK )
						//Limpar arquivo de trabalhO TMP => alimentar GETDB
						//limpa arquivo temporario para quando voltar para outro documento 
						dbSelectArea( "TMP" )
						If Alias() == "TMP"
							Ctb_ZapTmp() //Zap
						EndIf
						TMP->( dbGotop() )

						dbSelectArea( "CT2" )
					EndIf
				Else
					lContinua := .T.
					nCont++
				EndIf
			Else
				lContinua := .T.
				nCont++
			EndIf
		End
		
		If Select("TMP") > 0 
			TMP->(dbGoTop())
			If TMP->(!Eof())
				// Apresenta tela
				Ctba103Lan(nOpc,dDataEst,cLoteEst,cSubLtEst,cDocEst,"CT2",CT2->(recno()),@CTF_LOCK,nTotInf,cCodSeq,cArq1,cArq2)	
			EndIf	
		EndIf
		
		DeleteObject(oOk)
		DeleteObject(oNo)		
	Else
		lRet := .F.
	EndIf
Else
	Aviso( STR0006, STR0045, { "Ok" } )		// "Não foram encontrados movimentos no período informado."
	lRet := .F.
EndIf

//limpa arquivo temporario para quando voltar para outro documento 
If Select("TMP") > 0
	dbSelectArea( "TMP" )
	If Alias() == "TMP"
		Ctb_ZapTmp() //Zap
	EndIf
	TMP->( dbGotop() )
EndIf

dbSelectArea( "CT2" )

RestArea( aAreaCT7  )
RestArea( aAreaCT2 )
RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT103LotesºAutor  ³Alvaro Camillo Neto º Data ³  22/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona os lotes que o usuario poderá escolher para       º±±
±±º          ³realizar a operação                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT103Lotes(nOpc)
Local aQuais	:= {}
Local aArea		:= GetArea()
Local dDtIniEst:= mv_par03
Local dDtFimEst:= mv_par04
Local cLoteIni	:= mv_par05
Local cLoteFim	:= mv_par06
Local cSbLotIni:= mv_par07
Local cSbLotFim:= mv_par08
Local cDocIni	:= mv_par09
Local cDocFim	:= mv_par10
Local cTipSalOri := mv_par02
Local cQuery	:= ""
Local lDefTop 	:= IfDefTopCTB()// verificar se pode executar query (TOPCONN)

If lDefTop
	cQuery := " SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,MIN(R_E_C_N_O_) MINRECNO "
	cQuery += " FROM "+RetSqlTab("CT2")
	cQuery += " WHERE " + RetSQLCond("CT2")
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
	cQuery += "   AND CT2_TPSALD =  '"+cTipSalOri+"' "
	cQuery += "   GROUP BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC"
	cQuery += "   ORDER BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC"
	
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
		
		If _lFLT103ST
			lRet := ExecBlock("FLT103ST",.F.,.F.)
			If lRet
				Aadd(aQuais,{.T.,DTOC(CT2->CT2_DATA)+SPACE(1)+CT2->CT2_LOTE+SPACE(1)+CT2->CT2_SBLOTE+SPACE(1)+CT2->CT2_DOC})
			EndIf
		Else
			Aadd(aQuais,{.T.,DTOC(CT2->CT2_DATA)+SPACE(1)+CT2->CT2_LOTE+SPACE(1)+CT2->CT2_SBLOTE+SPACE(1)+CT2->CT2_DOC})
		EndIF
		
		CT2ESTLT->(dbSkip())
	EndDo
EndIf
RestArea(aArea)
Return aQuais

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTM103ProxDocDoc³ Autor ³ Alvaro Camillo Neto  ³ Data ³ 13.10.09 ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera proxima numeracao de documento para gravar no novo    º±±
±±º          ³ Lancamento. Caso estoure a numeracao de documento,         º±±
±±º          ³ incrementa numero de lote.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPD1 - Data do lancamento a ser gravado                   º±±
±±º          ³ EXPC2 - Numero do lote                                     º±±
±±º          ³ EXPC3 - Numero do sub-lote                                 º±±
±±º          ³ EXPC4 - Numero do documento                                º±±
±±º          ³ EXPC5 - Numero do RECNO da tabela de numeracao de doctos.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTM103ProxDoc( dDataLanc, cLote, cSubLote, cDoc, CTF_LOCK )

Default CTF_LOCK := 0

// Verifica o Numero do Proximo documento contabil
Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o N§ do Doc estourou, incrementa o lote         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLote := CtbInc_Lot(cLote, "CTB", .T.) // True para forcar chave pelo modulo CTB
Enddo

FreeUsedCode(.T.)  //libera codigos ainda travados

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT103TpSalºAutor  ³Alvaro Camillo Neto º Data ³  21/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava o tipo de saldo parametrizado nas linhas do arquivo   º±±
±±º          ³temporário                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA103                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CT103TpSal()
Local aArea 	:= GetArea()
Local aAreaTMP := TMP->(GetArea())

TMP->(dbGoTop())

While TMP->(!Eof())
	RecLock("TMP",.F.)
	TMP->CT2_TPSALD := __cTpSaldo
	MsUnlock()
	TMP->(dbSkip())
End

RestArea(aAreaTMP)
RestArea(aArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct103Troca³ Autor  ³ Simone Mie Sato         ³ Data 06.02.06³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Troca marcador entre x e branco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct103Troca(nIt,aArray)                                     ³±±
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
Static Function Ct103Troca(nIt,aArray)

aArray[nIt,1] := !aArray[nIt,1]

Return aArray

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct103Ok   ³ Autor  ³ Simone Mie Sato		    ³ Data 06.02.06³±±                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Confirma processamento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct103Ok(aQuais)                                            ³±±
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
Static Function Ct103OK(aQuais)

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CT103CarEst³ Autor ³ Alcaro Camillo Neto   ³ Data ³ 26.10.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega arq. temporario com dados para MSGETDB das opcoes  ³±±
±±³          ³ de cópia e estorno do lançamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT103CarEst(nOpc,dDataLanc,cLote,cSubLote,cDoc)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CT103CarEst(nOpc,dDataLanc,cLote,cSubLote,cDoc,cLinha,cLinhaAlt,cTipSalOri,nLinha,cCodSeq)
Local aSaveArea	 	:= GetArea()
Local aAreaCT2	 	:= CT2->(GetArea())
Local cAlias	 	:= "CT2"
Local cCritConv	 	:= ""
Local nPos
Local cMoeda
Local nVezes	 	:= 1
Local nC		 	:= 0
Local nTamCrit	 	:= Len(CriaVar("CT2_CONVER"))
Local nCont
Local lContinua		:= .T.		
Local cFilialCT2 	:= xFilial( "CT2" )
Local nMaxLin	  	:= CtbLinMax()
Local lSeqCorr   	:= .F.
Local cSeqCorr		:= Space(10)
Local cAuxEnt
Local cCpoDB
Local cCpoCR

DEFAULT cLinhaAlt	:= ""
DEFAULT cTipSalOri	:= ""
DEFAULT nLinha		:= 0

cLinhaAlt:= IIF(Empty(cLinhaAlt) , "000", cLinhaAlt )

lSeqCorr := UsaSeqCor() // Controle do Correlativo

dbSelectArea("CT2")
dbSetOrder(1)

If MsSeek( cFilialCT2 + Dtos(dDataLanc) + cLote + cSubLote + cDoc + cLinha )
	
	If lSeqCorr
		
		If nOpc == 7
			cSeqCorr := CTBSQCor( "" ,cCodSeq, dDataLanc )
		Else
			cSeqCorr := CT2->CT2_SEGOFI
		Endif
		
	EndIf
	                                                                                                                                        
	While !Eof() .And. ;
		CT2->CT2_FILIAL == cFilialCT2 	.And.;
		CT2->CT2_DATA 	== dDataLanc	.And.;
		CT2->CT2_LOTE	== cLote 		.And.;
		CT2->CT2_SBLOTE == cSubLote 	.And.;
		CT2->CT2_DOC 	== cDoc .And. nLinha < nMaxLin  
		
		//So ira mostrar na Getdb os lancamentos da moeda 01
		If CT2->CT2_MOEDLC <> '01'
			dbSkip()
			Loop
		EndIf
		
		If ALLTRIM(CT2->CT2_TPSALD) != ALLTRIM(cTipSalOri)
			dbSkip()
			Loop
		EndIf
		
		//Se for estorno de lancamento, nao sera considerado os historicos complementares.
		If nOpc == 6 .And. CT2->CT2_DC == "4"
			dbSkip()
			Loop
		EndIf
		
		RecLock("TMP",.T.)
		
		For nCont := 1 To Len(aHeader)
			nPos := FieldPos(aHeader[nCont][2])
			If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
				FieldPut(nPos,(cAlias)->(FieldGet(FieldPos(aHeader[nCont][2]))))
			EndIf
		Next nCont
		
		nLinha ++
		TMP->CT2_FLAG 		:= .F.
		TMP->CT2_SEQLAN	:= CT2->CT2_SEQLAN
		TMP->CT2_SEQHIS	:= CT2->CT2_SEQHIS
		TMP->CT2_EMPORI	:= CT2->CT2_EMPORI
		TMP->CT2_FILORI	:= CT2->CT2_FILORI
		TMP->CT2_KEY		:= CT2->CT2_KEY
		TMP->CT2_RECNO		:= CT2->(Recno())
		cCritConv			:= CT2->CT2_CRCONV
		cMoeda				:= CT2->CT2_MOEDLC
		TMP->CT2_ALI_WT 	:= "CT2"
		TMP->CT2_REC_WT 	:= If(nOpc==7,0,CT2->(Recno()))
		TMP->CT2_TPSALD	:= cTipSalOri
		
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
			TMP->CT2_CCC		:= CT2->CT2_CCD
			TMP->CT2_CCD		:= CT2->CT2_CCC
			TMP->CT2_ITEMC		:= CT2->CT2_ITEMD
			TMP->CT2_ITEMD		:= CT2->CT2_ITEMC
			TMP->CT2_CLVLCR	:= CT2->CT2_CLVLDB
			TMP->CT2_CLVLDB	:= CT2->CT2_CLVLCR
			TMP->CT2_ATIVDE	:= CT2->CT2_ATIVCR
			TMP->CT2_ATIVCR	:= CT2->CT2_ATIVDE
			TMP->CT2_HIST		:= OemToAnsi( STR0048 )+ DTOC(CT2->CT2_DATA) + " " + CT2->CT2_LOTE+" "+CT2->CT2_SBLOTE+" "+CT2->CT2_DOC+" "+CT2->CT2_LINHA
			
			If CtbUso( "CT2_DCD" ) .OR. CtbUso( "CT2_DCC" )		//  Digito de Controle
				TMP->CT2_DCC	:= CT2->CT2_DCD
				TMP->CT2_DCD	:= CT2->CT2_DCC
			Endif

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
		
		dbSelectArea("CT2")
		dbSkip()
		
		While ! Eof() .And. ;
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
		
		cLinhaAlt := Soma1(cLinhaAlt)
		TMP->CT2_LINHA		:= cLinhaAlt
		MsUnlock()
	EndDo
	// Guarda a ultima linha do documento + 1
	CT2->(dbSkip(-1))
	cLinha 		:= Soma1(CT2->CT2_LINHA)
	lContinua   := nLinha < nMaxLin
EndIf

dbSelectArea("TMP")
dbSetOrder(2)
IF cLinhaAlt != "000"
	TMP->( DbSeek( cLinhaAlt ) )
ELSE
	TMP->( dbGoTop() )
ENDIF

RestArea(aAreaCT2)
RestArea(aSaveArea)

Return lContinua


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbLinMax ºAutor  ³Alvaro Camillo Neto º Data ³  08/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o numero máximo de linha do lançamento             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbLinMax()
Local nRet := 0
Local nMv_NumLin	:= SuperGetMv("MV_NUMLIN" , .T. , 999 )

If nMv_NumLin >= 35658  //limite estabelecido em razao do tamanho campo CT2_LINHA  = 3 e utilizar a funcao Soma1() para incremento
	nRet := 35658
Else
	nRet := nMv_NumLin
EndIf

Return(nRet)

//-------------------------------------------------------------------
/*/{Protheus.doc}Ct103RcCTF
Verifica se existe CTF quando da exclusao  e 
a funcao CtbDestrava marca com R para se quiser poder usar o msm numero novamente
funcao para verificar se existe CTF e caso ainda tenha 
excluir ou marcar como recuperavel o numero na versao 12.1.33

@author Totvs
@since  09/12/2020

@version 12
/*/
//-------------------------------------------------------------------
Static Function Ct103RcCTF(dDataLanc,cLote,cSubLote,cDoc)
Local cAliasAnt

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

Return