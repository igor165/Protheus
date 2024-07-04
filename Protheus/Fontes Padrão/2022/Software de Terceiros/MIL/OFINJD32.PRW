#include "tbiconn.ch"
#include "PROTHEUS.CH"
#include "OFINJD32.CH"
#include "fileio.ch"
#include "topconn.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  08/10/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006952_7"

/*/{Protheus.doc} OFINJD32 " Gestão Cache Inventário e PMM "
	Controla cache do inventário e geração de PMM

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  08/10/2015
/*/
Function OFINJD32()
	Private oDialog,oMssInv,lstMeses,oGrp12,olblQtdReg,oLblProcs,olblComp,oBtnReproc,oBtnProc,oBtnCls
	Private oCache   := DMS_CacheB2():New()
	Private oDPM     := DMS_DPM():New()
	Private oUtil    := DMS_Util():New()
	Private aMeses   := {}
	Private oVerde   := LoadBitmap( GetResources() , "BR_VERDE"    )  // Operacao Normal
	Private oVerm    := LoadBitmap( GetResources() , "BR_VERMELHO" )  // Operacao com problema detectado
	Private oAmarel  := LoadBitmap( GetResources() , "BR_AMARELO"  )
	Private oLogger  := DMS_Logger():New()

	oDialog := MSDIALOG():Create()
	oDialog:cName           := "oDialog"
	oDialog:cCaption        := STR0005 /*"Gestão de Cache Inventário"*/
	oDialog:nLeft           := 0
	oDialog:nTop            := 0
	oDialog:nWidth          := 781
	oDialog:nHeight         := 575
	oDialog:lShowHint       := .F.
	oDialog:lCentered       := .F.

	oMssInv := TGROUP():Create(oDialog)
	oMssInv:cName           := "oMssInv"
	oMssInv:cCaption        := "Meses Inventário"
	oMssInv:nLeft           := 4
	oMssInv:nTop            := 4
	oMssInv:nWidth          := 280
	oMssInv:nHeight         := 363
	oMssInv:lShowHint       := .F.
	oMssInv:lReadOnly       := .F.
	oMssInv:Align           := 0
	oMssInv:lVisibleControl := .T.

    lstMeses := TWBrowse():New(10, 5, 134, 170,,,,oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
    lstMeses:AddColumn( TCColumn():New( ""     , { || gtStatusCache(aMeses[lstMeses:nAt]) },,,,"LEFT", 20,.T.,.F.,,,,.F.,) ) //"Status"
    lstMeses:AddColumn( TCColumn():New( "Data" , { || DTOC(aMeses[lstMeses:nAt])          },,,,"LEFT", 50,.F.,.F.,,,,.F.,) ) //"Data"
    lstMeses:nAt     := 1

	oGrp12 := TGROUP():Create(oDialog)
	oGrp12:cName           := "oGrp12"
	oGrp12:cCaption        := ""
	oGrp12:nLeft           := 4
	oGrp12:nTop            := 369
	oGrp12:nWidth          := 281
	oGrp12:nHeight         := 160
	oGrp12:lShowHint       := .F.
	oGrp12:lReadOnly       := .F.
	oGrp12:Align           := 0
	oGrp12:lVisibleControl := .T.

	olblQtdReg := TSAY():Create(oDialog)
	olblQtdReg:cName           := "olblQtdReg"
	olblQtdReg:cCaption        := "Qtd. Total: 100999"
	olblQtdReg:cMsg            := "Quantidade de peças em cache."
	olblQtdReg:nLeft           := 22
	olblQtdReg:nTop            := 395
	olblQtdReg:nWidth          := 200
	olblQtdReg:nHeight         := 17
	olblQtdReg:lShowHint       := .F.
	olblQtdReg:lReadOnly       := .F.
	olblQtdReg:Align           := 0
	olblQtdReg:lVisibleControl := .T.
	olblQtdReg:lWordWrap       := .F.

	oLblProcs := TSAY():Create(oDialog)
	oLblProcs:cName           := "oLblProcs"
	oLblProcs:cCaption        := "Qtd. Processada: 100000"
	oLblProcs:nLeft           := 22
	oLblProcs:nTop            := 419
	oLblProcs:nWidth          := 199
	oLblProcs:nHeight         := 17
	oLblProcs:lShowHint       := .F.
	oLblProcs:lReadOnly       := .F.
	oLblProcs:Align           := 0
	oLblProcs:lVisibleControl := .T.
	oLblProcs:lWordWrap       := .F.
	oLblProcs:lTransparent    := .F.

	olblComp := TSAY():Create(oDialog)
	olblComp:cName := "olblComp"
	olblComp:cCaption := "Porc. Completo: 10%"
	olblComp:nLeft := 22
	olblComp:nTop := 443
	olblComp:nWidth := 200
	olblComp:nHeight := 17
	olblComp:lShowHint := .F.
	olblComp:lReadOnly := .F.
	olblComp:Align := 0
	olblComp:lVisibleControl := .T.
	olblComp:lWordWrap := .F.
	olblComp:lTransparent := .F.

	oBtnReproc := TBUTTON():Create(oDialog)
	oBtnReproc:cName := "oBtnReproc"
	oBtnReproc:cCaption := STR0006 /*"Reprocessar"*/
	oBtnReproc:bAction := {|| Processa( {|lAbort| OJD32ReProc(aMeses[lstMeses:nAt]) }, STR0011 /*"Limpeza"*/, "", .T. ) }
	oBtnReproc:nLeft := 288
	oBtnReproc:nTop := 8
	oBtnReproc:nWidth := 140
	oBtnReproc:nHeight := 22
	oBtnReproc:lShowHint := .F.
	oBtnReproc:lReadOnly := .F.
	oBtnReproc:Align := 0
	oBtnReproc:lVisibleControl := .T.
	//oBtnReproc:nType := 1

	oBtnProc := TBUTTON():Create(oDialog)
	oBtnProc:cName := "oBtnProc"
	oBtnProc:cCaption := STR0007 /*"Processa"*/
	oBtnProc:bAction := {|| Processa( {|lAbort| OJD32ContExC(aMeses[lstMeses:nAt]) }, STR0011 /*"Limpeza"*/, "", .T. )  }
	oBtnProc:nLeft := 288
	oBtnProc:nTop := 31
	oBtnProc:nWidth := 140
	oBtnProc:nHeight := 22
	oBtnProc:lReadOnly := .F.
	oBtnProc:Align := 0
	oBtnProc:lVisibleControl := .T.
	//oBtnProc:nType := 1

	oBtnCls := TBUTTON():Create(oDialog)
	oBtnCls:cName := "oBtnCls"
	oBtnCls:cCaption := STR0008 /*"Limpa"*/
	oBtnCls:bAction := {|| OJD32ClrCache(aMeses[lstMeses:nAt]) }
	oBtnCls:nLeft := 288
	oBtnCls:nTop := 55
	oBtnCls:nWidth := 140
	oBtnCls:nHeight := 22
	oBtnCls:lShowHint := .F.
	oBtnCls:lReadOnly := .F.
	oBtnCls:Align := 0
	oBtnCls:lVisibleControl := .T.
	//oBtnCls:nType := 1

	oBtnCls := TBUTTON():Create(oDialog)
	oBtnCls:cName := "oBtnCls"
	oBtnCls:cCaption := STR0012 /*"Gerar PMM"*/
	oBtnCls:bAction := {|| OJD32GerPMM(aMeses[lstMeses:nAt]) }
	oBtnCls:nLeft := 288
	oBtnCls:nTop := 79
	oBtnCls:nWidth := 140
	oBtnCls:nHeight := 22
	oBtnCls:lShowHint := .F.
	oBtnCls:lReadOnly := .F.
	oBtnCls:Align := 0
	oBtnCls:lVisibleControl := .T.
	//oBtnCls:nType := 1


	oBtnCls := TBUTTON():Create(oDialog)
	oBtnCls:cName := "oBtnCls"
	oBtnCls:cCaption := STR0014 /* "Ger. PMM 12 Meses"*/
	oBtnCls:bAction := {|| OJD32Ger12PMM(aMeses[lstMeses:nAt]) }
	oBtnCls:nLeft := 288
	oBtnCls:nTop := 103
	oBtnCls:nWidth := 140
	oBtnCls:nHeight := 22
	oBtnCls:lShowHint := .F.
	oBtnCls:lReadOnly := .F.
	oBtnCls:Align := 0
	oBtnCls:lVisibleControl := .T.
	//oBtnCls:nType := 1

	aMeses := last12M()
	lstMeses:SetArray( aMeses )
  lstMeses:Refresh()

	lDlgAtivo := .T.
	oDialog:Activate()
Return

/*/{Protheus.doc} last12M
    Retornar ultimos 12 meses em data e em array, todas no ultimo dia do mês

    @author Vinicius Gati
    @since  08/10/2015
/*/
Static Function last12M()
	Local aLast12M := {}
	d12MesesAnt := oUtil:RemoveMeses(ddatabase, 12)
	d12MesesAnt := oUtil:UltimoDia(YEAR(d12MesesAnt), MONTH(d12MesesAnt))

	aAdd(aLast12M, d12MesesAnt)

	Do While LEN(aLast12M) < 13
		dData := aLast12M[LEN(aLast12M)]
		dData := oUtil:AddMeses( dData, 1 )
		dData := oUtil:UltimoDia( YEAR(dData), MONTH(dData) )
		aAdd(aLast12M, dData)
	End Do
Return aLast12M

/*/{Protheus.doc} UpdateInfos
    Retornar ultimos 12 meses em data e em array, todas no ultimo dia do mês

    @author Vinicius Gati
    @since  08/10/2015
/*/
Static Function UpdateInfos()
	Local nPerc := 0
	Local oCacheData := oCache:GetInfo(aMeses[lstMeses:nAt])
	Local bBlock := ""
	nPerc := (oCacheData:GetValue('QTD_PROC')*100)/oCacheData:GetValue('QTD_REGS')
	ErrorBlock({ |e| "" })


	//BEGIN SEQUENCE
	oLblProcs:cCaption  :=  STR0009 /*"Qtd. Processada: "*/ + STR(oCacheData:GetValue('QTD_PROC'))
	olblQtdReg:cCaption :=  STR0010 /*"Qtd. Registros:"  */ + STR(oCacheData:GetValue('QTD_REGS'))
	//olblComp:cCaption   :=  STR0011 /*"Progresso:"       */ + STR(ALLTRIM(TRANSFORM(nPerc, '@E 99.99'))) + "% (" + TRANSFORM(oCacheData:GetValue('TOTAL'),"@E 999,999,999.99") + ")"
	olblComp:cCaption   :=  STR0011 /*"Progresso:"       */ + ALLTRIM(TRANSFORM(nPerc, '@E 999.99')) + "% (" + TRANSFORM(oCacheData:GetValue('TOTAL'),"@E 999,999,999.99") + ")"

	/*
	RECOVER
		ErrorBlock(bBlock)
	END SEQUENCE
	*/

Return .T.

/*/{Protheus.doc} gtStatusCache
    Retornar ultimos 12 meses em data e em array, todas no ultimo dia do mês

    @author Vinicius Gati
    @since  08/10/2015
/*/
Static Function gtStatusCache(dData)
	Local oCacheData := oCache:GetInfo(dData)
	UpdateInfos()
	Do Case
	Case "OK" $ oCacheData:GetValue('STATUS')
		Return oVerde
	CASE "PARCIAL"  $ oCacheData:GetValue('STATUS')
		Return oAmarel
	End Case
Return oVerm

/*/{Protheus.doc} OJD32ClrCache
    Limpa todos os dados do mês em cache

    @author Vinicius Gati
    @since  08/10/2015
/*/
Static Function OJD32ClrCache(dData)
	If MsgNoYes(STR0002 /*"Tem certeza que deseja excluir todos os dados em cache do mês selecioado?"*/, STR0001 /* "Atenção" */)
		oCache:Clear(dData)
	Else
		ALERT(STR0003 /*"Operação abortada"*/)
	EndIf
Return .T.

/*/{Protheus.doc} OJD32ReProc
    Limpa a data e todos os dados em cache e inicia processo do mês

    @author Vinicius Gati
    @since  08/10/2015
/*/
Static Function OJD32ReProc(dData)
	If MsgNoYes(STR0004 /*"Tem certeza que deseja excluir os dados e iniciar o processamento? Este processo é lento."*/, STR0001 /* "Atenção" */)
		oCache:Clear(dData)
		oCache:CacheToPMM( YEAR(dData), Month(dData) )
		oLogger:LogToTable({                        ;
			{'VQL_AGROUP'     , 'OFINJD25'        },; // gravar como 25 mesmo varios pontos pegam como 25
			{'VQL_TIPO'       , 'MES_COMPLETO'    },;
			{'VQL_DADOS'      , DTOS(dData)       } ;
		})
	Else
		ALERT(STR0003 /*"Operação abortada"*/)
	EndIf
Return .T.

/*/{Protheus.doc} OJD32ContExC
    Inicia o processo de cache no mês selecionado

    @author Vinicius Gati
    @since  08/10/2015
/*/
Static Function OJD32ContExC(dData)
	//oCache:PrepareToProc(dData, , .F.) // o boolean é pra forçar ou não refazer tudo desde o inicio ou continuar o que está fazendo
	oCache:CacheToPMM( YEAR(dData), Month(dData) )
	oLogger:LogToTable({                        ;
		{'VQL_AGROUP'     , 'OFINJD25'        },; // gravar como 25 mesmo varios pontos pegam como 25
		{'VQL_TIPO'       , 'MES_COMPLETO'    },;
		{'VQL_DADOS'      , DTOS(dData)       } ;
	})
Return .T.

/*/{Protheus.doc} OJD32GerPMM
    Gera PMM do mês selecionado

    @author Vinicius Gati
    @since  09/10/2015
/*/
Function OJD32GerPMM(dData, lAuto)
	If oCache:GetInfo(dData):GetValue('STATUS') == 'OK'
		OFINJD09( , dData ) // geração de PMM para Mês selecionado
	Else
		if ! lAuto
			Alert(STR0013) // "PMM ainda não pode ser gerado, é necessário gerar o cache por scheduler (recomendado) ou clicando em processar."
		endif
	EndIf
Return .F.

/*/{Protheus.doc} OJD32Ger12PMM
    Gera PMM de 12 meses

    @author Vinicius Gati
    @since  09/10/2015
/*/
Function OJD32Ger12PMM()
	local nX := 1
	For nX:= 1 to Len(aMeses)
		OJD32GerPMM( aMeses[nX], .T. )
	Next
Return .F.