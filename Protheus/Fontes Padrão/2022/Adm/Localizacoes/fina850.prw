#INCLUDE "FINA850.CH"   
#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWLIBVERSION.CH' 

Static lFWCodFil := .T. 

//Posicoes do Array ASE2
#DEFINE _FORNECE		1
#DEFINE _LOJA     		2
#DEFINE _VALOR    		3
#DEFINE _MOEDA    		4
#DEFINE _SALDO    		5
#DEFINE _SALDO1   	6
#DEFINE _EMISSAO		7  	
#DEFINE _VENCTO   	8
#DEFINE _PREFIXO  	9
#DEFINE _NUM     		10
#DEFINE _PARCELA 		11
#DEFINE _TIPO    		12
#DEFINE _RECNO   		13
#DEFINE _RETIVA  		14
#DEFINE _RETIB   		15
#DEFINE _NOME    		16

#DEFINE _JUROS  		17
#DEFINE _DESCONT 		18
#DEFINE _NATUREZ 		19
#DEFINE _ABATIM  		20
#DEFINE _PAGAR   		21
#DEFINE _MULTA   		22
#DEFINE _RETIRIC 		23
#DEFINE _RETSUSS 		24
#DEFINE _RETSLI  		25
#DEFINE _RETIR   		26
#DEFINE _RETIRC  		27 //Portugal
#DEFINE _RETISI  		28
#DEFINE _RETRIE  		29 //Angola
#DEFINE _RETIGV  		30 //PERU
#DEFINE _CBU     		31 //Controle de CBU - Argentina
#DEFINE _NRCHQ   		32 //EQUADOR

#DEFINE _ELEMEN		Iif( cPaisLoc $ 'RUS' , 36 , 32 ) //indica o tamanho para o array ase2

// RUSSIA
#DEFINE _BASIMP1	33
#DEFINE _ALQIMP1    34
#DEFINE _VALIMP1    35
#DEFINE _MDCONTR    36

// RUSSIA
#Define _FJRBnkCod		1 
#Define _FJRBIKCod 		2 
#Define _FJRConta  		3 
#Define _FJRBkName 		4 
#Define _FJRExtNmb 		5 
#Define _FJRPriori 		6 
#Define _FJRReason 		7 
#Define _FJRCORACC 		8 
#Define _FJRRcName 		9 
#Define _FJRKPPPay 		10
#Define _FJRRecKPP 		11
#Define _FJRVATCod 		12
#Define _FJRVATRat 		13
#Define _FJRVATAmt 		14
#Define _CHFDIR_FJR		15
#Define _CHFACC_FJR		16
#Define _CSHR_FJR		17
#Define _CSHNMB_FJR		18
#Define _ATTACH_FJR		19
#Define _PSSPRT_FJR		20
#Define _PorFornece		21
#Define _PorLoja		22


//Posicoes do ListBox
#DEFINE H_OK			1
#DEFINE H_FORNECE		2
#DEFINE H_LOJA			3
#DEFINE H_NOME			4
#DEFINE H_NF			5
#DEFINE H_NCC_PA		6
#DEFINE H_TOTAL		7

//ARG
#DEFINE H_RETGAN		8
#DEFINE H_RETIB		10
#DEFINE H_RETSUSS		11
#DEFINE H_RETSLI		12
#DEFINE H_RETISI		13
#DEFINE H_CBU			14
//URU
#DEFINE H_RETIRIC		8 //Mesma posicao que as Ganancias pq so eh utilizado no Uruguai.
#DEFINE H_RETIR		11 //Mesma posicao que as SUSS pq so eh utilizado no Uruguai.
// INI Portugal
#DEFINE H_RETIRC		8 //Mesma posicao que as Ganancias pq so eh utilizado EM portugal.
#DEFINE H_RETIVA		9 //ARG Tambem
#DEFINE H_DESPESAS	10
//FIM PORTUGAL

//ANGOLA
#DEFINE H_RETRIE		8 //A confirmar - Posicao do imposto RIE de Angola
//Fim Angola
//PERU
#DEFINE H_RETIGV		8 //A confirmar - Posicao do imposto IGV DO PERU
//Fim PERU

#DEFINE H_TOTALVL		15
#DEFINE H_PORDESC		16
#DEFINE H_TOTRET		17
#DEFINE H_DESCVL		18
#DEFINE H_EDITPA		19
#DEFINE H_VALORIG		20
#DEFINE H_NATUREZA	21
#DEFINE H_UNICOCHQ	22
#DEFINE H_MULTICHQ	23

#DEFINE H_TERC			24

#DEFINE _PA_VLANT		01
#DEFINE _PA_MOEANT	02
#DEFINE _PA_VLATU		03
#DEFINE _PA_MOEATU	04
         
Static aDet850RUS := {}
Static cFilReason := ''
Static nPosTipo,nPosTpDoc,nPosMoeda,nPosMPgto,nPosNum,nPosPrefix,nPosBanco,nPosAge,nPosConta,nPosTalao,nPosEmi,nPosVcto,nPosVlr,nPosParc,nPosVlrE1,nPosMoedaE1
Static lF850Tit,lF850Ret
Static cAgente,nMVCUSTO
Static nDel		:=0
Static lF850ChS	:= ExistBlock("F085aChS") .and. ExecBlock("F085aChS",.F.,.F.)
Static lF850TxPg  := ExistBlock("F850TxPg")
Static lF850ObNat  := ExistBlock("F850ObNat") 
Static lFWCodFil	:= .T.
STATIC lMod2		:= .T.
Static _lMetric	:= Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuno    ณ FINA850    ณ Autor ณ Marcello Gabriel       ณ Data ณ 18.10.11 ณฑฑ
ฑฑณDescri็เo ณ Nova Ordem de Pago, conforme requisitos do Roadmap11.5.       ณฑฑ
ฑฑณ          ณ Solicitante Filial Argentina.                                 ณฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ณฑฑ
ฑฑณ PROGRAMADOR ณ DATA   ณ BOPS     ณ  MOTIVO DA ALTERACAO                   ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Fina850(nOper, aCabOP ,aDocPg, aFormaPg, lOPRotAut)
Local cPerg			:= "FIN850P"
Local nA			:= 0
Local aCores			:= {}
Local aAreaSX3			:= {}
Local aCpoMrk			:= {}
Local lRet			:= .T.
Local nNumTb		:= 14 // n๚mero de tablas asignadas al arreglo aCtbTmp en la funci๓n A850CpArq
Local nJ 			:= 0

Default nOper			:= 1

Default lOPRotAut		:= .F.
Private lMsg			:= Iif(lOPRotAut, .F., .T.)
Private lMsErroAuto		:= .F.
Private aNaturez		:= {}
Private cAliasTmp		:= ""
Private cArqTemp		:= ""
Private lMarca		:= .T.
Private lWsFeCred	:= SuperGetMV( "MV_WSFECRD", .F., .F. )
Private cIndex,cKey,cChave,nIndex
Private lBxParc			:= Iif(cPaisLoc <> "BRA" ,.T.,.F.)
Private aRatCond		:= {}
Private lCCRArg			:= Iif(!lOPRotAut,(cPaisLoc == "ARG" .And. Val(substr(cReleaseRPO,6,3)) >= 25),Iif(cPaisLoc == "ARG",.T.,.F.))

//Declaracao de variaveis onde serao carregadas as perguntas
Private dDatade,dDataAte,cForDe,cForAte,cBcoChq,cAgeChq,cCtaChq,nCondAgr,cNatDe,cNatAte,lVldNat,cContCor
Private nMoedChq,nDiasChq,nLimite,lFiltra,lDigita,lAglutina,lGeraLanc

Private cMarcaE1		:= GetMark()
Private cMarcaE2

//Declaracao das variaveis integracao contabil
Private cArquivo		:= ""
Private nHdlPrv			:= 1
Private nTotalLanc		:= 0
Private cLoteCom		:= ""
Private nLinha			:= 2
Private lLancPad70		:= .F.
Private lSmlCtb			:= .F.

//VAriavel para compatibilidade com a Enchoice da AxVisual
Private aTela[0][0],aGets[0]
Private cDocCred		:= ''

//Declaracao de vairaveis de uso geral
Private lRetPA			:= (GetNewPar("MV_RETPA","N") == "S")
Private nDecs			:= MsDecimais(1)
Private nMoedaCor		:= 1
Private lBaixaChq		:= .F.
Private aCerts			:= {}
Private aIndexADC		:= {}
Private aRecNoSE2		:= {}
Private nPosDeb
Private cCodDiario		:= ""
Private lGeraDCam		:= (GetNewPar("MV_DIFCAMP","N") == "S")
Private lTemMon			:= .F.
Private aRetIvAcm		:= Array(3)
Private cGrpSNF			:= ""
Private cGrpSPA			:= ""
Private cGrpSF2			:= ""
Private nNumPa
Private aCert			:= {}
Private aRetencao		:= {} //Array para exibicao de impostos com base no Configurador de Imposto FRM X FRN
Private nFlagMOD		:= 0
Private nCtrlMOD		:= 0
Private lFindITF		:= .T.
PRIVATE nFinLmCH		:= SuperGetMV("MV_FINLMCH",.F.,0.00)
Private aRotina			:= {}
Private cBancoCh		:= ""
Private cContaCh		:= ""
Private cAgenCh			:= ""
Private cTalaoCh		:= ""
Private cEletrCh		:= " 2" //Branco ou 2 - Nใo (DEFAULT)

Private lMsfil			:= .F.
Private oTmpTable 
Private aOrdem := {}

Private nTotBSUSS		:= 0
Private nLimiteSUSS		:= 0
Private aTotIva			:= {}
Private lDelPg	:= .F.
Private aPagConCBU	:= {}
Private aPagSinCBU	:= {}
Private aHeaderRet := {}
Private aCposRet	:= {}
Private aGetRet	  := {}
Private aColsRet	  := {}
Private aRetPos		:= {}
Private nMoeBan := 1
Private aProvLim  := {}
private cNomObjT := "oTmpTab"
private nVlrMont	:= 0
Private lVlrAlt   := .F.
Private aProvCuit := {}
Private lAutomato := .F. 
Private aCCORetNoIns    := {}
Private aSFHNoIns       := {}
Private aRetImp855      := {}

If cPaisloc $ "ARG|MEX|PAR|BOL|CHI"
    lAutomato := isBlind()
Endif  
//Declara las variables conforme el n๚mero de tablas asignadas al arreglo aCtbTmp en funci๓n A850CpArq
For nJ := 1  to nNumTb 
	Private &(cNomObjT + alltrim(str(nJ))) := NIL
Next

If Type("cFunName") == "U"
	Private cFunName := "FINA850"
EndIf

If Type("aTxMoedas") == "U"
	Private aTxMoedas 		:= {}
EndIf
If (cPaisLoc $ 'RUS|', aTxMoedas	:= F850TxMoed(),)

cTxtRotAut := ""


// Verifica็ใo do processo que esta configurado para ser utilizado no M๓dulo Financeiro (Argentina)
If lMod2
	If !FinModProc(lMsg,@cTxtRotAut)
		lMsErroAuto	:= .T.
		lRet := .F.
	EndIf
EndIf

// verifica o uso das tabelas compartilhadas
If cPaisLoc == "ARG" .AND. lRet
	If !F850MsFil(lOPRotAut)
		lMsErroAuto	:= .T.
		lRet := .F.
	Endif
Endif

FINLoad() //Carrega a tabela Modos de Pago padrใo

If SX6->(MsSeek(xfilial("SX6")+"MV_MDCFIN"))
	lTemMon 	:= Iif(!Empty(GETMV("MV_MDCFIN")),.T.,.F.)
EndIf

If cAgente == Nil
	cAgente	:= GETMV("MV_AGENTE")
Endif

If nMVCusto == Nil
	nMVCusto	:= Val(GetMv("MV_MCUSTO"))
Endif

//Verifica se a moeda escolhida para o limite de credito esta em uso.
If Empty(GetMv("MV_MOEDA"+StrZero(nMVCusto,1))) .AND. lRet
	If lOPRotAut
		cTxtRotAut += OemToAnsi(STR0142)
		lMsErroAuto := .T.
	Else
		MsgAlert(OemToAnsi(STR0142))
	EndIf
	lRet := .F.
EndIf

/*
+-Preguntas---------------------------------+
ฆ  Mv_par01    ฟDel Vencimiento   ?         ฆ
ฆ  Mv_par02    ฟHasta Vencimiento ?         ฆ
ฆ  Mv_par03    ฟDel Proveedor     ?         ฆ
ฆ  Mv_par04    ฟHasta Proveedor   ?         ฆ
ฆ  Mv_par05    ฟExibir ?  Tํtulos/Pre-Ordensฆ
ฆ  Mv_par06    ฟFiltra Generadas  ?         ฆ
ฆ  Mv_par07    ฟMuestra Asientos  ?         ฆ
ฆ  Mv_par08    ฟAglomera Asientos ?         ฆ
ฆ  Mv_par09    ฟAsientos On-Line  ?         ฆ
ฆ  Mv_par10    Agrupar OP's por             ฆ
ฆ  Mv_par11    Para saldo gerar   ?         ฆ
ฆ  Mv_par12    Natureza de  ?               ฆ
ฆ  Mv_par13    Natureza ate ?               ฆ
ฆ  Mv_par14    Sel. Manual de Naturezas?    ฆ
ฆ  Mv_par15    Imprime Comprovante?         ฆ
ฆ  Mv_par15    P/ Argentina Conta Corrente? ฆ
ฆ  Mv_par16    Nome rotina comprovante?     ฆ
+-------------------------------------------+
*/

If !Pergunte(cPerg, !lOPRotAut) .AND. lRet
	lRet := .F.
EndIf

If lRet
	dDatade	:= mv_par01
	dDataAte	:= mv_par02
	cForDe		:= mv_par03
	cForAte	:= mv_par04
	lShowPOrd	:= (mv_par05==2) // .t. se mostra apenas pre-ordens
	lFiltra	:= (mv_par06==1)
	lDigita	:= (mv_par07==1)
	lAglutina	:= (mv_par08==1)
	lGeraLanc	:= (mv_par09==1)
	nCondAgr	:= mv_par10
	cNatDe		:= mv_par12
	cNatAte		:= mv_par13
	lVldNat		:= Iif(mv_par14 = 1,.T.,.F.)
	If lCCRArg
		cContCor	:= mv_par15
	Else
		cContCor := ""
	Endif
	If cPaisLoc == "ARG" .And. lRetPA 
		cDocCred	:=	IIf((mv_par11$MVPAGANT),MVPAGANT,'')
	Else
		cDocCred	:=	IIf(Empty(mv_par11).Or. !(mv_par11$MV_CPNEG+"|"+MVPAGANT),'',mv_par11)
	Endif

	If Empty(cDocCred)
		Help(" ",1,"A085SALDO")
		Return
	Endif

	cCadastro	:= OemToAnsi(STR0006)  //"Generacion de la Orden de Pago Automatica"
	aRotina 	:= MenuDef(@nFlagMOD,@nCtrlMOD)

 	If lOPRotAut

		lRet	:=	F850ARotAu(nOper, aCabOP ,aDocPg, aFormaPg)
	Else
		If nOper == 1
			If lShowPOrd
				cMarcaE2 := GetMark(.T.,"SE2","E2_OK")
				F850PreOP()
			Else

				// Monta a tela de sele็ใo de naturezas especํficas
				If lVldNat
					F850SelNat()
				EndIf

				// Filtra a SE2
				F850SE2Tmp(.T.)

				DbSelectArea("SE2")
				SE2->(dbSetOrder(1))

				cMarcaE2 := GetMark()

				aAdd(aCpoMrk,{"E2_OK",,,})

				dbSelectArea("SX3")
				aAreaSX3 := SX3->(GetArea())
				SX3->(dbSetOrder(1))
				If SX3->(MsSeek("SE2"))
					While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SE2"
						If SX3->X3_BROWSE == "S" .And. AllTrim(SX3->X3_CAMPO) <> "E2_OK" .AND.!AllTrim(SX3->X3_CONTEXT) == "V"
							aAdd(aCpoMrk, {SX3->X3_CAMPO,,IIF(cPaisLoc $ "ARG",SX3->X3_TITSPA,X3Titulo()),SX3->X3_PICTURE})
						EndIf
						SX3->(dbSkip())
					EndDo
				EndIf
				SX3->(RestArea(aAreaSX3))
				//Legenda do Browse
				aAdd(aCores, { 'LOTE == "S"'	 		, "BR_PRETO" } ) 		//Titulo em Lote
				aAdd(aCores, { 'APROVADO == "S"' 	, "BR_VERDE" } ) 		//Baixa Aprovada
				aAdd(aCores, { 'APROVADO == "N"'	, "BR_VERMELHO" })	//Baixa Bloqueada

				If ExistBlock("F850URET")
					aCores := ExecBlock("F850URET",.F.,.F.)
				EndIf

				dbSelectArea(cAliasTmp)
				(cAliasTmp)->(dbGoTop())
				
				If !empty(cContCor) .And. lWsFeCred
					aSize(aRecNoSE2,0)
					F850MarkAll(@nFlagMOD,@nCtrlMOD,cAliasTmp,.F.)
					lMarca := .F.
					MarkBrow(cAliasTmp,"E2_OK","APROVADO=='N'",aCpoMrk,,cMarcaE2,"F850MarkAll(@nFlagMOD,@nCtrlMOD,cAliasTmp)",,,,"F850Mark(,@nFlagMOD,@nCtrlMOD,.T.)",,,,aCores)
				Else
					MarkBrow(cAliasTmp,"E2_OK","APROVADO=='N'",aCpoMrk,,cMarcaE2,"F850MarkAll(@nFlagMOD,@nCtrlMOD,cAliasTmp)",,,,"F850Mark(,@nFlagMOD,@nCtrlMOD,cAliasTmp)",,,,aCores)
				Endif
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Desbloquear os registros locados pela sele็ใo do Usario no MarkBrowse ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				DbSelectArea("SE2")
				SE2->(dbSetOrder(1))
				DbUnlockAll()
				If oTmpTable <> Nil   //leem
					oTmpTable:Delete()  //leem
					oTmpTable := Nil //leem
				EndIf //leem
			Endif
		ElseIf nOper == 2
			SelPago()

		EndIf
	EndIf
EndIf

Return lRet

/*
ฑฑบPrograma  ณF850SelNatบAutor  ณMarcos Berto        บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processo de selecao manual das naturezas no filtro dos     บฑฑ
ฑฑบ          ณ titulos para composicao da Pre-OP                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - Argentina                                        บฑฑ
*/
Function F850SelNat()
Local aButtons	:= {}
Local bInitBr	:= Nil
Local cArqTmp	:= ""
Local cMarcaSED	:= ""
Local lRet		:= .T.
Local lConfirm	:= .F.
Local nCountNat	:= 0
Local oDlgSel
Local oBrwNat
Local oOK
Local oNOK
//---------------------------------
// Cria a tabela temporaria da SED
//---------------------------------
cArqTmp := F850SEDTmp()

//-------------------------------------------------------------------------
// Carrega a tabela temporaria com os registros que atendem aos parametros
//-------------------------------------------------------------------------
F850SEDCg()

If SEDTEMP->(!Eof())

	cMarcaSED := GetMark()

	oOK 	:= LoadBitmap(GetResources(),"wfchk")
	oNOK	:= LoadBitmap(GetResources(),"wfunchk")

	Define MsDialog oDlgSel Title "Naturezas" From 000,000 To 300,500 Pixel //"Naturezas"

	oBrwNat := TCBrowse():New(0,0,10,10,,,,oDlgSel,,,,,{|| F850SEDMrk(cMarcaSED)},,,,,,,,"SEDTEMP",.T.,,,,.T.,)
	oBrwNat:AddColumn(TCColumn():New("  ",{|| If(SEDTEMP->ED_OK == cMarcaSED,oOK,oNOK)} ,,,,,010,.T.,.F.,,,,,))
	oBrwNat:AddColumn(TCColumn():New(RetTitle("ED_CODIGO")	,{|| SEDTEMP->ED_CODIGO},PesqPict("SED","ED_CODIGO"),,,,020,.F.,.F.,,,,,))
	oBrwNat:AddColumn(TCColumn():New(RetTitle("ED_DESCRIC"),{|| SEDTEMP->ED_DESCRIC},PesqPict("SED","ED_DESCRIC"),,,,020,.F.,.F.,,,,,))
	oBrwNat:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwNat:Refresh()

	//Bloco a ser executado ao "Confirmar" a tela -> <CTRL+O>
	bSetConf := { || lConfirm := .T., GetKeys() , SetKey( VK_F3 , Nil ) , oDlgSel:End() }

	//Bloco a ser executado ao "Finalizar" a tela -> <CTRL+X>
	bSetFech := { || lConfirm := .F. ,GetKeys() , SetKey( VK_F3 , Nil ) , oDlgSel:End() }

	//Acoes relacionadas
	aAdd(aButtons,{"Marca_Desmarca_Todos",{|| F850MrkIn(cMarcaSED)},"Inverte","Inverte"}) //"Marca/Desmarca Todos"

	//Bloco para montagem da tela de sele็ใo de naturezas
	bInitBr := { || EnchoiceBar( oDlgSel , bSetConf , bSetFech , Nil , aButtons )}
	oDlgSel:bInit := bInitBr

	Activate MsDialog oDlgSel Center

	If lConfirm
		//------------------------------------------------------
		// Grava os registros selecionados na tabela temporaria
		//------------------------------------------------------
		SEDTEMP->(DbGoTop())
		While SEDTEMP->(!Eof())
			If SEDTEMP->ED_OK == cMarcaSED
				aAdd(aNaturez,SEDTEMP->ED_CODIGO)
			EndIf
			SEDTEMP->(DbSkip())
		EndDo
	EndIf
EndIf

If oTmpTable <> Nil   //leem
	oTmpTable:Delete()  //leem
	oTmpTable := Nil //leem
EndIf //leem

Return
/*
ฑฑบPrograma  ณF850SEDTmpบ Autor ณ Marcos Berto       บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera a tabela temporaria com base na SED                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Financeiro                                                 บฑฑ
*/
Function F850SEDTmp()

Local cNomeArq	:= "SEDTEMP"
Local aStruct	:= {}

DbSelectArea("SED")

AAdd(aStruct,{"ED_OK","C", 02,0}) //Adiciona o campo para marcacao na MarkBrow
AAdd(aStruct,{"ED_CODIGO","C", TamSX3("ED_CODIGO")[1],0})
AAdd(aStruct,{"ED_DESCRIC","C", TamSX3("ED_DESCRIC")[1],0})

//Creacion de Objeto
oTmpTable := FWTemporaryTable():New(cNomeArq) //leem
oTmpTable:SetFields( aStruct ) //leem

aOrdem	:=	{"ED_CODIGO"} //leem 

oTmpTable:AddIndex("I2", aOrdem) //leem

oTmpTable:Create() //leem	

Return cNomeArq

/*
ฑฑบPrograma  ณF850SEDCg บAutor  ณMarcos Berto        บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alimenta a tabela temporaria com as naturezas que atendem  บฑฑ
ฑฑบ          ณ ao filtro                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFiananceiro                                                 บฑฑ
*/
Function F850SEDCg()

Local cAliasSED	:= GetNextAlias()

cQuery := "SELECT ED_CODIGO,ED_DESCRIC FROM " + RetSqlTab("SED")
cQuery += "WHERE "
cQuery += "ED_FILIAL ='"+xFilial("SED") + "' AND "
cQuery += "ED_CODIGO >='"+cNatDe+"' AND "
cQuery += "ED_CODIGO <='"+cNatAte+ "' AND "
cQuery += "ED_TIPO IN (' ','2') AND "
cQuery += "D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSED, .F., .T.)

DbSelectArea(cAliasSED)

While (cAliasSED)->(!Eof())

	RecLock("SEDTEMP",.T.)
		SEDTEMP->ED_OK 		:= Space(2)
		SEDTEMP->ED_CODIGO	:= (cAliasSED)->ED_CODIGO
		SEDTEMP->ED_DESCRIC	:= (cAliasSED)->ED_DESCRIC
	SEDTEMP->(MsUnlock())

	(cAliasSED)->(DbSkip())

EndDo

(cAliasSED)->(DbCloseArea())

SEDTEMP->(DbGoTop())

Return

/*
ฑฑบPrograma  ณF850SEDMrkบAutor  ณMarcos Berto        บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para marcar a natureza no duplo click para definicaoบฑฑ
ฑฑบ          ณ do filtro dos titulos para montagem da Pre-OP              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Financeiro                                                 บฑฑ
*/
Function F850SEDMrk(cMarcaSED)

DEFAULT cMarcaSED := ""

If SEDTEMP->(!Eof())
	Reclock("SEDTEMP",.F.)
	If SEDTEMP->ED_OK == cMarcaSED
		SEDTEMP->ED_OK := " "
	Else
		SEDTEMP->ED_OK := cMarcaSED
	EndIf
	SEDTEMP->(MsUnlock())
EndIf

Return

/*
ฑฑบPrograma  ณ F850MrkInบ Autor ณ Marcos Berto       บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca ou Desmarca todos os tํtulos na sele็ใo de tํtulos a บฑฑ
ฑฑบ          ณ a pagar da pr้-ordem de pagamento.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFinanceiro                                                  บฑฑ
*/
Function F850MrkIn(cMarcaSED)

Local aArea 		:= GetArea()
Local aAreaSED	:= SEDTEMP->(GetArea())
DEFAULT cMarcaSED	:= 	""

SEDTEMP->(dbGoTop())

While !SEDTEMP->(Eof())
	Reclock("SEDTEMP",.F.)
	If SEDTEMP->ED_OK == cMarcaSED
		SEDTEMP->ED_OK := " "
	Else
		SEDTEMP->ED_OK := cMarcaSED
	EndIf
	SEDTEMP->(MsUnlock())
	SEDTEMP->(DbSkip())
EndDo

RestArea(aArea)
RestArea(aAreaSED)

Return

/*
ฑฑบPrograma  ณF850SE2Tmpบ Autor ณ Marcos Berto       บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o arquivo temporario que serแ utilizado na MarkBrowseบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFinanceiro                                                  บฑฑ
*/
Function F850SE2Tmp(lNew)

Local aStruct	:= {}
Local aIndices	:= GetIndices("SE2")
Local cAliasSE2	:= GetNextAlias()
Local cCampo	:= ""
Local cQuery 	:= ""
Local cPagaveis	:=	""
Local lLibTit	:= SuperGetMv("MV_CTLIPAG")
Local nX 		:= 0
Local nY        := 0
Local nPosCampo	:= 0
Local nPosNat	:= 0
Local nValPend	:= 0
Local xConteudo	:= Nil
Local cFltUsr :=""
Local lTrfWeCred := .F.
Local lContCorr	:= .F.
//Usa novo Alias (.T.) ou Atualiza็ใo (.F.)
DEFAULT lNew := .T.

If lNew
	cAliasTmp := GetNextAlias()
Else
	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbCloseArea())
EndIf
If !Empty(cContCor)
	lContCorr	:= .T.
Endif
If cPaisLoc == "ARG" .And. lWsFeCred
	lTrfWeCred:= .T.
Endif
cPagaveis	:= GetSESTipos({|| ES_BXRCOP == "1"},"2|3")
cPagaveis	:= Iif(Empty(cPagaveis),MVNOTAFIS+"|"+MVPAGANT+"|"+MVFATURA+"|NDP|NCP|NDI|NCI",cPagaveis)

cQuery	:= "SELECT " + Iif(lTrfWeCred .And. lContCorr ," FVT.FVT_CODCC, FVT.FVT_STATUS, SE2.","") + "* FROM "
cQuery	+= RetSqlName("SE2")+" SE2 "
If lTrfWeCred .And. lContCorr
	cQuery	+= " LEFT JOIN "+ RetSqlName("FVT") + " FVT "
	cQuery	+= " ON SE2.E2_CCR = FVT.FVT_CODCC " 
	cQuery	+= " AND SE2.E2_NUM = FVT_DOC "
	cQuery	+= " AND SE2.E2_PREFIXO = FVT_SERIE "
	cQuery	+=  "AND SE2.E2_TIPO = FVT_ESPECI "
Endif
cQuery	+= "WHERE "
cQuery	+= "E2_FILIAL = '"+xFilial("SE2")+"' AND "
cQuery	+= "E2_FORNECE BETWEEN '"+cForDe+"' AND '"+cForAte+"' AND "
If cPaisLoc <> 'RUS'
	cQuery	+= "E2_TIPO IN "+FormatIn(cPagaveis,"|")+" AND "
EndIf
cQuery	+= "E2_VENCREA >= '"+dTos(dDataDe)+"' AND "
cQuery	+= "E2_VENCREA <= '"+dTos(dDataAte)+"' AND "
cQuery += "E2_NATUREZ BETWEEN '"+cNatDe+"' AND '"+cNatAte+"' AND "
cQuery += "E2_PREOK <> 'S' AND "
// Filtra titulos que nao foram liberados pelo FINA580
If ( lLibTit )
	cQuery +=  "E2_DATALIB <> '' AND "
Endif
If lFiltra //mv_par06
	cQuery += "E2_SALDO > 0 AND "
EndIf

If ExistBlock("A850ABRW")
	cFltUsr	:=	ExecBlock("A850ABRW",.F.,.F.)
Endif
If !Empty(cFltUsr)
	cQuery := cQuery+cFltUsr+" AND "
Endif
If SE2->(ColumnPos("E2_CCR")) > 0
	cQuery += "E2_CCR = '"  + cContCor + "' AND "
Endif
cQuery += "SE2.D_E_L_E_T_ = '' "
If lTrfWeCred .And. lContCorr
	cQuery += "AND FVT.FVT_STATUS <> '3' "
	cQuery += "ORDER BY E2_FILIAL,E2_NUM,E2_FORNECE,E2_LOJA,E2_VENCREA"
Else
	cQuery += "ORDER BY E2_FILIAL,E2_FORNECE,E2_LOJA,E2_VENCREA"
Endif

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSE2, .F., .T.)

//Cria a estrutura para o arquivo temporแrio
dbSelectArea("SE2")
aStruct := SE2->(dbStruct())
aAdd(aStruct,{"E2_RECNO","N",9,0}) //Adiciona o recno para controle
aAdd(aStruct,{"APROVADO","C",1,0})
aAdd(aStruct,{"LOTE","C",1,0})

aOrdem := {}

//Creacion de Objeto
oTmpTable := FWTemporaryTable():New(cAliasTmp) //leem
oTmpTable:SetFields( aStruct ) //leem

//leem
For nX := 1 to Len(aIndices)
	cOrdem := ""
	If aIndices[nX][2] == "S"
		aAux := StrTokArr(alltrim(aIndices[nX][1]),"+")
			For nY := 1 to Len(aAux)
				If At("(",aAux[nY]) > 0
					nPosIni := At("(",aAux[nY])+1
					nPosFim := RAt(")",aAux[nY]) - nPosIni
					cAux := SubStr(aAux[nY],nPosIni,nPosFim)
					aAux[nY] := alltrim(cAux)
				EndIf
			Next nY		
		oTmpTable:AddIndex("I3" + Alltrim(Str(nX)), aAux) 
	EndIf
Next nX

oTmpTable:Create() //leem

dbSelectArea(cAliasSE2)
(cAliasSE2)->(dbGoTop())
//Alimenta o arquivo temporแrio
While !(cAliasSE2)->(Eof())
	nPosNat := aScan(aNaturez,{|x| x == (cAliasSE2)->E2_NATUREZ})
	If nPosNat > 0 .Or. !lVldNat
		Reclock(cAliasTmp,.T.)
			For nX := 1 to Len(aStruct)
			If aStruct[nX,2] == "L"
				LOOP
				Else
				cCampo    := aStruct[nX,1]
				If cCampo <> "E2_RECNO" .And. cCampo <> "APROVADO" .And. cCampo <> "LOTE"
					xConteudo := (cAliasSE2)->&cCampo
					nPosCampo := (cAliasTmp)->(ColumnPos(cCampo))
				EndIf
				If (cAliasSE2)->E2_SALDO = 0
					(cAliasTmp)->APROVADO 	:= "N"
				ElseIf !Empty((cAliasSE2)->E2_NUMBOR)
					(cAliasTmp)->APROVADO 	:= "S"
					(cAliasTmp)->LOTE 		:= "S"
				ElseIf (cAliasSE2)->E2_SALDO > 0
					(cAliasTmp)->APROVADO := "S"
				EndIf
				If nPosCampo > 0 .And. cCampo <> "E2_RECNO" .And. cCampo <> "APROVADO" .And. cCampo <> "LOTE"
					If TamSX3(cCampo)[3]=="D"
						xConteudo := StoD(xConteudo)
					EndIf
					(cAliasTmp)->(FieldPut(nPosCampo,xConteudo))
				ElseIf cCampo == "E2_RECNO"
					(cAliasTmp)->E2_RECNO := (cAliasSE2)->R_E_C_N_O_
				EndIf
			Endif
			Next nX
		(cAliasTmp)->(MsUnlock())
	EndIf
	(cAliasSE2)->(dbSkip())
EndDo

If !empty(cContCor) .And. lTrfWeCred
	F850MarkAll(nFlagMOD,nCtrlMOD)
Endif

DbSelectArea(cAliasSE2)
(cAliasSE2)->(dbCloseArea())

Return

/*
ฑฑบPrograma  ณF850PgAut บAutor  ณBruno Sobieski      บFecha ณ  01/16/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao de ordem de pagamento multiple.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
*/
Function F850PgAut(nFlagMOD,nCtrlMOD)
Local aSE2			:= {}
Local nC			:= 0
Local nI			:= 0
Local nX			:= 0
Local lImpCert		:= (GetNewPar("MV_CERTRET","N") == "S")
Local lF850ltSE2	:= ExistBlock("F085ARRSE2")
Local aAuxSE2		:= {}
Local lRoadMap115	:= .T.	//Analisar se e viavel substituir por um parametro ou campo de controle.

// variaveis privadas usadas no F850Tela
Private aPagos	:= {}
Private aPagosOrig := {}
Private oDlg,oLBx,cListBox,oValPag,oMsg1
Private aSizes
Private aFields,oBrw
Private nValOrdens	:=	0	,nNumOrdens:=0,oNumOrdens,oValOrdens
Private oDataTxt1,oTipo
Private oDataTxt2
Private oPagar,nPagar
Private oChkBox
Private oDataVenc,oDataVenc1
Private oCbx1,oCbx2
Private aCtrChEQU 	:= {}
Private aConsTRF := { .T. , "" }
Private lProcCCR		:= .F.

//Variaves relativas ao multimoeda (usadas no F850Tela)
Private oMoeda
Private oCbx
Private cMoeda			:= MV_MOEDA1
Private aMoeda			:= {}
Private cBanco			:= Criavar("A6_COD")
Private cAgencia		:= Criavar("A6_AGENCIA")
Private cConta			:= Criavar("A6_NUMCON")
Private cProv			:= Criavar("A2_EST")
Private cCF			:= Criavar("F4_CODIGO")
Private cSerie		:= Criavar("F2_SERIE")
Private nGrpSus		:= Criavar("FF_GRUPO")
Private cZnGeo			:= Criavar("FF_ITEM")
Private cNumOp			:= Iif(cPaisLoc == "ARG" ,Criavar("EK_NUMOPER"),"")
Private nTotAnt		:= Iif(cPaisLoc == "ARG" ,Criavar("EK_TOTANT")  ,"")
Private cDebMed		:= ""
Private aDebMed		:= {}
Private cDebInm		:= {}
Private aDebInm		:= {}
Private dDataVenc		:= dDataBase
Private dDataVenc1	:= dDataBase
Private cTes			:= Criavar("F4_CODIGO")
Private aHeader1		:= {}
Private nBaseRet		:= 0 //Base para reten็ใo de PA Automatico
Private nSaldoCCr		:= 0
Private nBaseRG         := 0 //Base para reten็ใo de PA Automatico para CO

Private nValSobra		:= 0.00
Private nTotPag		:= 0.00
Private oMod
Private cMod			:= ""
Private nTotNeg		:= 0.00
Private aFormasPgto	:= {}
Private nVlrPagar		:= 0
Private oVlrPagar
Private oRegSFK

Private oUnico
Private oMultiplo

//Pagamento eletr๔nico - (usadas no F850Tela)
Private oPgtoElt
Private cPgtoElt		:= STR0048 //Default = NรO
Private cOpcElt		:= ""
Private lVldRet := .T. 

Private cDConcep := Iif(SEK->(ColumnPos("EK_DCONCEP"))>0,space(255),"")
Private lPagoCBU := .F.
// Verifica se pode ser incluido mov. com essa data
If !(dtMovFin(dDataBASE,,"1") )
	Return .F.
EndIf
nMoedaCor := 1
//Carregar combo com as moedas
Aadd(aMoeda,MV_MOEDA1)
For nC	:= 2		To Len(aTxMoedas)
	Aadd(aMoeda,aTxMoedas[nC][1])
Next

//Forco para que seja inclusao
aRotina[3][4]	:=	3
//Carrega o Array SE2 com todas as informacoes do pagamento
Processa({|| F850Se2(@aSE2)})

If lF850ltSE2
	aAuxSE2 := ExecBlock("F085ARRSE2",.F.,.F.,{aSE2})
	If ValType(aAuxSE2) = "A"
		aSE2 := aClone(aAuxSE2)
	Endif
Endif

If Len(aSE2) > 0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PcoIniLan("000313")

	//Monta interface com o Usuario
	If lRoadMap115 .and. cPaisLoc == "ARG"
		lOk := F850Tela(@aSE2,@nFlagMOD,@nCtrlMOD,@aCtrChEQU,lRoadMap115)
	Else
		lOk := F850Tela(@aSE2,@nFlagMOD,@nCtrlMOD,@aCtrChEQU)
	EndIf
	//Chamada da fun็ใo de transmissใo
	If cPaisLoc == 'ARG' .And. lWsFeCred .And. !Empty(mv_par15) .And. oRegSFK <> Nil .And. lOk
		If lShowPOrd .And. !Empty(cContCor) .And. nVlrPagar == 0  
			lOk := .T.
		Else
			If FindFunction("ConsCCArg")
				aConsTRF := ConsCCArg(cContCor)
			Endif
			If valtype(aConsTRF) == "A"
				If aConsTRF[1]
					If FindFunction("TrFOpCred")
						lOk := TrFOpCred(oRegSFK,aSE2)
						lProcCCR := lOk
					Endif	  	
				Else
					If FindFunction("TrfOPArg")
						lOk := TrfOPArg(oRegSFK)
						lProcCCR := lOk
					Endif	 
				Endif
			Endif	
		Endif	
	Endif
	If lOk	// Gravacao

		Processa({|| F850Grava(aSE2,,,,@nFlagMOD,@nCtrlMOD) })

		IF cPaisLoc == "ARG" .And. Len(aCert) > 0  .And. lImpCert
			F850AtuSFF(aCert,.F.)
		EndIf
		aRetencao := {}
		aRetIvAcm := Array(3)
	Else
		//Cancela as reten็ใos calculadas com base no Conf. de Impostos
		If cPaisLoc $ "DOM|COS"
			F850CanRet()
		EndIf
		aRetencao := {}
		aRetIvAcm := Array(3)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza a gravacao dos lancamentos do SIGAPCO ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PcoFinLan("000313")

Endif
If !(lShowPOrd)
	MarkBRefresh()
Endif

//Forco para que seja visualizacao e nao voltar
aRotina[3][4]	:=	2

Return( .F. )

/*
ฑฑบPrograma  ณF850GravaบAutor  ณLeonardo Gentile    บFecha ณ  01/15/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGravacao da orden de PAGO                                   บฑฑ
*/
Function F850Grava(aSE2,lPa,aRecAdt,lMonotrb,nFlagMOD,nCtrlMOD,cSolFun,lOPRotAut)
Local nA,nI,nJ,nK
Local aTitPags			:= Array(MoedFin())
Local cSeq				:= ""
Local nRegs			:= 0
Local aNums			:= {}
Local nMoedaPag 		:= 1, cFilSX6
Local lBaixaChqTmp 	:= .F.
Local lPagoInf			:= .F.
Local cQuery			:= ""
Local lExiste			:= .F.
Local cKeyImp			:= ""
Local cAlias			:= ""
Local nMoedaRet		:= 1
Local aMoedasPg		:= { 1 }
Local aAreaSA2			:= {}
Local aAreaSE2			:= {}
Local cFilterSE2		:= {}
Local aAreaSEF			:= {}
Local aAreaSEK			:= {}
Local cFilter			:= ''
Local lExterno			:= .F.
Local ny				:= 1
Local nx				:= 1
Local aConGan			:= {}
Local aRateioGan		:= {}
Local aConGanRat		:= {}
Local nC				:= 1
local cGrSUSS			:= Alltrim( nGrpSus ) + Alltrim( cZnGeo )
Local aFlagCTB			:= {}
Local lUsaFlag			:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/ )
Local aTmp1			:= {}
Local aTmpIB			:= {}
Local nBaseITF			:= 0
Local lFindITF			:= .T.
Local aHdlPrv			:= {}
Local lCBU				:= .F.
Local nValMoed1			:= 0
Local cPrefix			:= " "
Local nNum				:= 0
Local cParcela			:= " "
Local cTipoDoc			:= " "
Local nFornec			:= 0
Local nVlrRet			:= 0
Local nPosPgto			:= 0
Local lF850NoShw		:= .F.
Local nColig			:= GetNewPar("MV_RMCOLIG",0)
Local lMsgUnica			:= IsIntegTop()
Local nOrdPag			:= 0
Local cPadrao			:= ""
Local lF850TxMo 	:= ExistBlock("F850TxMo")
Local lReIvSU		:= cPaisLoc == "ARG" .and. (GetNewPar("MV_RETIVA","N") == "S" .and. GetNewPar("MV_RETSUSS","N") == "S")
Local lBaretIS		:= .F.
Local aNump  := {}
Local nTotRetIb			:= 0
Local nSldProv          := 0
Local nVlrOrig           := 0

//Simula็ใo Contabil
Local nSmOrdPag			:= 1
Local nSmLiq			:= 1
Local nVlLanc			:= 0

/* Reestruturacao da SE5 */
Local cCposSE5			:= ""
Local cIDDoc			:= ""
Local cChaveTit			:= ""
Local lRet				:= .T.
Local cAliasSE5			:= ""
Local cIDFK2			:= ""
Local cIdMetric     := ""
Local cSubRutina    := ""

Private cIDProc			:= ""
Private oModBxE2		:= Nil
Private oFKABxE2		:= Nil
Private oFK2BxE2		:= Nil
Private oFK6BxE2		:= Nil
Private oModBxE1		:= Nil
Private oFKABxE1		:= Nil
Private oFK1BxE1		:= Nil
Private oModMovBco		:= Nil
Private oFKAMovBco		:= Nil
Private oFK5MovBco		:= Nil
/*-*/

Private cLiquid			:= ""
Private cOrdPago		:= ""
Private aRatAFR 		:= {}
Private aTitImp			:= {}

If ExistBlock("F085NOSHW")
	lF850NoShw := ExecBlock("F085NOSHW",.F.,.F.)
	If ValType(lF850NoShw) != "L"
		lF850NoShw := .F.
	EndIf
EndIf

If lF850Tit == Nil
	lF850Tit	:= ExistBlock("A085ATIT")
Endif

DEFAULT aRecADT		:=	{}
DEFAULT lMonotrb 	:= .F.
Default cSolFun		:= ""
If lOPRotAut
	cOpcElt		:= ""
	cDebMed		:= ""
	cDebInm		:= ""
	nPosTipo		:=	1
	nPosTpDoc		:=	0
	nPosNum		:=	3
	nPosPrefix		:=	2
	nPosMoeda		:=	6
	nPosMPgto		:=	6
	nPosBanco		:=	9
	nPosAge		:=	10
	nPosConta		:=	11
	nPosTalao		:=	12
	nPosVlr		:=	5
	nPosEmi		:=	7
	nPosVcto		:=	8
	nPosDeb		:=	0
	nPosParc		:=	4
	nPosVlrE1		:=	7
	nPosMoedaE1	:=	8
EndIf

//+---------------------------------------------------------+
//ฆ Generar asientos contables                              ฆ
//+---------------------------------------------------------+
If lGeraLanc .Or. lSmlCtb
	//+--------------------------------------------------------------+
	//ฆ Nao Gerar os lancamento Contabeis On-Line                    ฆ
	//+--------------------------------------------------------------+
	lLancPad70 := VerPadrao("570")
EndIf
If lLancPad70
	//+--------------------------------------------------------------+
	//ฆ Posiciona numero do Lote para Lancamentos do Financeiro      ฆ
	//+--------------------------------------------------------------+
	dbSelectArea("SX5")
	MsSeek(xFilial()+"09FIN")
	cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
EndIf
If lLancPad70
	nHdlPrv := HeadProva( cLoteCom,;
	"PAGO011",;
	substr( cUsuario, 7, 6 ),;
	@cArquivo )

	If nHdlPrv <= 0
		Help(" ",1,"A100NOPROV")
	EndIf
	aHdlPrv := { nHdlPrv, "570", "FINA850", "PAGO011", cLoteCom }
Else
	aHdlPrv := {}
EndIf
lPa	:=	Iif(lPa==Nil,.F.,lPa)

If	lPa
	nRegs	:=	1
Else
	aEval( aSE2, {|x,y| nRegs+=Len( aSE2[y][1])}  )
Endif

ProcRegua(2*Len(aSE2)+nRegs)
/*
Modelos para baixa de contas a pagar (reestruturacao SE5)*/
oModBxE2 := FWLoadModel("FINM020")
oFKABxE2 := oModBxE2:GetModel("FKADETAIL")
oFK2BxE2 := oModBxE2:GetModel("FK2DETAIL")
oFK6BxE2 := oModBxE2:GetModel("FK6DETAIL")

oModBxE1 := FWLoadModel("FINM010")
oFKABxE1 := oModBxE1:GetModel("FKADETAIL")
oFK1BxE1 := oModBxE1:GetModel("FK1DETAIL")

oModMovBco := FWLoadModel("FINM030")
oFKAMovBco := oModMovBco:GetModel("FKADETAIL")
oFK5MovBco := oModMovBco:GetModel("FK5DETAIL")

nI := 0
lRet := .T.
While lRet .And. (ni < Len(aPagos))

	nI++

	If lF850TxMo
		aTxMoedas := ExecBlock("F850TxMo",.F.,.F.,{aPagos, aSE2,aTxMoedas,ni})
	EndIf

	If aPagos[ni][H_OK] <> 1  // se !ok
		Loop
	EndIf

	Begin Transaction
	//Flag CBU
	lCBU := Iif(cPaisLoc == "ARG",aPagos[ni][H_CBU],.F.)

	//Inicializar array dos valores Baixados
	For nA	:=	1	To	Len(aTitPags)
		aTitPags[nA]	:=	0
	Next

	If !lSmlCtb
		// pega novo numero de ordem de pago

		cOrdPago := StrZero(Val(GetSxeNum("SEK","EK_ORDPAGO")),TamSx3("EK_ORDPAGO")[1])

		// rDMAKE PARA ALTERAR A NUMERACAO DA oRDEM DE PAGO
		If ExistBlock("A085NORP")
			cOrdPago :=	ExecBlock("A085NORP",.F.,.F.,cOrdPago)
		Endif

		aCerts	:={}  // Redefinir o array dos doctos de retencoes

		SEK->(DbSetOrder(1))
		lExiste := SEK->(MsSeek(xFilial("SEK")+cOrdPago,.F.))
		If __lSx8
			If !lExiste
				ConfirmSx8()
			Else
				RollBackSX8()
				Final(OemToAnsi(STR0156),OemToAnsi(STR0157))
			EndIf
		EndIf
		cLiquid	:= Soma1(GetMv("MV_NUMLIQ"),6)
		/*
		Obtencao do ID do processo da ordem de pago (reestruturacao SE5)*/
		cIDProc := GetSXENum('FKA','FKA_IDPROC')
	Else
		// Atribuo uma numera็ใo invแlida para a Simula็ใo de Ordem de Pago
		cOrdPago	:= StrZero(nSmOrdPag,TamSx3("EK_ORDPAGO")[1])
		cLiquid	:= StrZero(nSmLiq,TamSx3("E5_NUMLIQ")[1])

		nSmOrdPag++
		nSmLiq++
		cIDProc := "OP_SIMULCTB"
	EndIf

	cFilSX6  	:= SX6->X6_FIL
	lPagoInf	:= .F.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDeterminar se o pago foi feito em uma unica moeda, para gravar ณ
	//ณtodas as retencoes nessa moeda (BOPS 76135)                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nMoedaRet	:=	1
	aMoedasPg	:=	GetMoedPag(aSE2[nI][3])
	If Len(aMoedasPg)>1 .Or. Len(aMoedasPg) == 0
		nMoedaRet	:=	1
	Else
		nMoedaRet	:= Iif(ValType(aMoedasPg[1])<>"N",Val(aMoedasPg[1]),aMoedasPg[1])    // Bruno
	Endif

	nJ := 0
	While lRet .And. (nj < Len( aSE2[ni][1]))
		nJ++
		IncProc()
		cCposSE5 := ""
		If !(aSE2[ni][1][nj][_TIPO] $ MVABATIM ) .And. aSE2[ni][1][nj][_PAGAR] > 0
			SE2->(DbSetOrder(1))
			If Empty(aSE2[ni][1][nj][_PARCELA])
				aSE2[ni][1][nj][_PARCELA]  := space(TamSX3("E2_PARCELA")[1])
			EndIf
			SE2->(MsSeek(xFilial("SE2")+aSE2[ni][1][nj][_PREFIXO]+aSE2[ni][1][nj][_NUM]+aSE2[ni][1][nj][_PARCELA]+;
			aSE2[ni][1][nj][_TIPO]+aSE2[ni][1][nj][_FORNECE]+aSE2[ni][1][nj][_LOJA]))
			cSeq:=FaNxtSeqBx("SE2")

			If 	cPaisLoc $ "DOM|COS"
				If lPa	.And. !Empty(aPagos[nI,H_NATUREZA])
					//Gera็ใo das Reten็๕es de Impostos
					If 	!SE2->E2_TIPO $ "CH |PA "
						F850GerRet("9", aPagos[nI,H_NATUREZA], aSE2[ni][1][nj][3], aSE2[ni][1][nj][_PREFIXO], aSE2[ni][1][nj][_NUM], aSE2[ni][1][nj][_FORNECE])
					EndIf
					F850GerRet("2", aPagos[nI,H_NATUREZA], aSE2[ni][1][nj][3], aSE2[ni][1][nj][_PREFIXO], aSE2[ni][1][nj][_NUM], aSE2[ni][1][nj][_FORNECE])
				Else
					cFatGer     := F850FatGer(SE2->E2_NATUREZ)
					nVlrRet 	:= F850PesAbt()
					If nVlrRet  > 0 .And. cFatGer == "2" .And. Empty(SE2->E2_BAIXA)  .And. SE2->E2_VALLIQ == 0 .And. aSE2[ni][1][nj][3] < SE2->E2_VALOR
						aSE2[ni][1][nj][3] := aSE2[ni][1][nj][3] + nVlrRet
					EndIf
					If 	!SE2->E2_TIPO $ "CH |PA "
						//Gera็ใo das Reten็๕es de Impostos
						F850GerRet("2", aSE2[ni][1][nj][19], aSE2[ni][1][nj][3], aSE2[ni][1][nj][_PREFIXO], aSE2[ni][1][nj][_NUM], aSE2[ni][1][nj][_FORNECE])
					EndIf
				EndIf
			Endif
			/*
			ID para a FK2 utilizado tambem para os valores acessorios (juros, multas etc) */
			cIDFK2 := FWUUIDV4()

			oModBxE2:SetOperation(MODEL_OPERATION_INSERT)
			oModBxE2:Activate()
			oModBxE2:SetValue("MASTER","E5_GRV",.T.)
			oModBxE2:SetValue("MASTER","IDPROC",cIDProc)

			If lRet .And. cOpcElt <> "1"
				SE2->(MsGoTo(aSE2[ni][1][nj][_RECNO]))
				cCposSE5 += "{"
				cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
				cCposSE5 += "{'E5_PREFIXO','" + aSE2[ni][1][nj][_PREFIXO] + "'},"
				cCposSE5 += "{'E5_NUMERO','" + aSE2[ni][1][nj][_NUM    ] + "'},"
				cCposSE5 += "{'E5_PARCELA','" + aSE2[ni][1][nj][_PARCELA] + "'},"
				cCposSE5 += "{'E5_CLIFOR','" + aSE2[ni][1][nj][_FORNECE] + "'},"
				cCposSE5 += "{'E5_LOJA','"  + aSE2[ni][1][nj][_LOJA   ] + "'},"
				cCposSE5 += "{'E5_BENEF','" + aSE2[ni][1][nj][_NOME   ] + "'},"
				cCposSE5 += "{'E5_DOCUMEN','" + cOrdPago + "'},"
				cCposSE5 += "{'E5_TIPO','" + aSE2[ni][1][nj][_TIPO   ] + "'},"
				cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
				cCposSE5 += "{'E5_VLDESCO'," + AllTrim(Str(aSE2[ni][1][nj][_DESCONT])) + "},"
				cCposSE5 += "{'E5_VLMULTA'," + AllTrim(Str(aSE2[ni][1][nj][_MULTA  ])) + "},"
				cCposSE5 += "{'E5_VLJUROS'," + Alltrim(Str(aSE2[ni][1][nj][_JUROS  ])) + "}"
				cCposSE5 += "}"

				cChaveTit := xFilial("SE2") + "|"
				cChaveTit += aSE2[ni][1][nj][_PREFIXO] + "|"
				cChaveTit += aSE2[ni][1][nj][_NUM] + "|"
				cChaveTit += aSE2[ni][1][nj][_PARCELA] + "|"
				cChaveTit += aSE2[ni][1][nj][_TIPO] + "|"
				cChaveTit += aSE2[ni][1][nj][_FORNECE] + "|"
				cChaveTit += aSE2[ni][1][nj][_LOJA]

				cIdDoc := FINGRVFK7("SE2", cChaveTit)

				oFKABxE2:SetValue("FKA_IDORIG",cIDFK2)
				oFKABxE2:SetValue("FKA_TABORI","FK2")

				oFK2BxE2:SetValue("FK2_DATA", dDataBase)
				oFK2BxE2:SetValue("FK2_NATURE",aSE2[ni][1][nj][_NATUREZ])
				oFK2BxE2:SetValue("FK2_VENCTO",SE2->E2_VENCREA)
				oFK2BxE2:SetValue("FK2_RECPAG","P")
				oFK2BxE2:SetValue("FK2_TPDOC","BA")
				oFK2BxE2:SetValue("FK2_MOEDA",StrZero( aSE2[ni][1][nj][_MOEDA  ],2))
				oFK2BxE2:SetValue("FK2_VALOR",Abs( aSE2[ni][1][nj][_PAGAR]))
				If aSE2[ni][1][nj][_MOEDA] == 1
					oFK2BxE2:SetValue("FK2_VLMOE2",aSE2[ni][1][nj][_PAGAR])
				Else
					oFK2BxE2:SetValue("FK2_VLMOE2",Abs( Round(xMoeda(aSE2[ni][1][nj][_PAGAR],aSE2[ni][1][nj][_MOEDA],1,,5,aTxMoedas[aSE2[ni][1][nj][_MOEDA]][2]),MsDecimais(1))))
				Endif
				oFK2BxE2:SetValue("FK2_HISTOR",STR0073)
				oFK2BxE2:SetValue("FK2_MOTBX","NOR")
				oFK2BxE2:SetValue("FK2_FILORI",SE2->E2_FILORIG)
				oFK2BxE2:SetValue("FK2_TXMOED",aTxMoedas[SE2->E2_MOEDA][2])
				oFK2BxE2:SetValue("FK2_CCUSTO",SE2->E2_CCUSTO)
				oFK2BxE2:SetValue("FK2_ORIGEM","FINA850")
				oFK2BxE2:SetValue("FK2_SEQ",cSeq)
				oFK2BxE2:SetValue("FK2_IDDOC",cIdDoc)
				oFK2BxE2:SetValue("FK2_ORDREC",cOrdPago)
				oFK2BxE2:SetValue("FK2_DOC",cOrdPago)
				If !lUsaFlag
					oFK2BxE2:SetValue("FK2_LA", "S")
				EndIf
			EndIf

			If aSE2[ni][1][nj][_JUROS  ] > 0 .And. cOpcElt <> "1"  // existem juros
				If !Empty(cCposSE5)
					cCposSE5 += "|"
				Endif
				cCposSE5 += "{"
				cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
				cCposSE5 += "{'E5_DATA',dDataBase},"
				cCposSE5 += "{'E5_NATUREZ','" + aSE2[ni][1][nj][_NATUREZ] + "'},"
				cCposSE5 += "{'E5_PREFIXO','" + aSE2[ni][1][nj][_PREFIXO] + "'},"
				cCposSE5 += "{'E5_NUMERO','" + aSE2[ni][1][nj][_NUM    ] + "'},"
				cCposSE5 += "{'E5_TIPO','" + aSE2[ni][1][nj][_TIPO   ] + "'},"
				cCposSE5 += "{'E5_PARCELA','" + aSE2[ni][1][nj][_PARCELA] + "'},"
				cCposSE5 += "{'E5_CLIFOR','" + aSE2[ni][1][nj][_FORNECE] + "'},"
				cCposSE5 += "{'E5_LOJA','"  + aSE2[ni][1][nj][_LOJA   ] + "'},"
				cCposSE5 += "{'E5_BENEF','" + aSE2[ni][1][nj][_NOME   ] + "'},"
				cCposSE5 += "{'E5_DOCUMEN','" + cOrdPago + "'},"
				cCposSE5 += "{'E5_ORDREC','" + cOrdPago + "'},"
				cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
				cCposSE5 += "{'E5_VLMOED2'," + AllTrim(Str(aSE2[ni][1][nj][_JUROS])) + "},"
				cCposSE5 += "{'E5_MOEDA','" + StrZero(aSE2[ni][1][nj][_MOEDA  ],2) + "'},"
				cCposSE5 += "{'E5_TXMOEDA'," + AllTrim(Str(aTxMoedas[aSE2[ni][1][nj][_MOEDA  ]][2])) + "},"
				cCposSE5 += "{'E5_SEQ','" + cSeq + "'},"
				If !lUsaFlag
					cCposSE5 += "{'E5_LA','S'},"
				EndIF
				cCposSE5 += "{'E5_MOTBX','NOR'}"
				cCposSE5 += "}"

				If !oFK6BxE2:IsEmpty()
					oFK6BxE2:AddLine()
				Endif

				oFK6BxE2:SetValue("FK6_IDORIG",cIDFK2)
				oFK6BxE2:SetValue("FK6_TABORI","FK2")
				oFK6BxE2:SetValue("FK6_RECPAG","P")
				oFK6BxE2:SetValue("FK6_HISTOR",STR0071)			 //"Interes pago sobre titulo"
				oFK6BxE2:SetValue("FK6_TPDOC","JR")
				oFK6BxE2:SetValue("FK6_VALCAL",Round(xMoeda(aSE2[ni][1][nj][_JUROS],aSE2[ni][1][nj][_MOEDA],1,,5,aTxMoedas[aSE2[ni][1][nj][_MOEDA]][2]),MsDecimais(1)))
				oFK6BxE2:SetValue("FK6_VALMOV",Round(xMoeda(aSE2[ni][1][nj][_JUROS],aSE2[ni][1][nj][_MOEDA],1,,5,aTxMoedas[aSE2[ni][1][nj][_MOEDA]][2]),MsDecimais(1)))
			EndIf

			If lRet .And. aSE2[ni][1][nj][_MULTA  ] > 0 .And. cOpcElt <> "1" //Existe Multa
				If !Empty(cCposSE5)
					cCposSE5 += "|"
				Endif
				cCposSE5 += "{"
				cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
				cCposSE5 += "{'E5_DATA',dDataBase},"
				cCposSE5 += "{'E5_NATUREZ','" + aSE2[ni][1][nj][_NATUREZ] + "'},"
				cCposSE5 += "{'E5_PREFIXO','" + aSE2[ni][1][nj][_PREFIXO] + "'},"
				cCposSE5 += "{'E5_NUMERO','" + aSE2[ni][1][nj][_NUM    ] + "'},"
				cCposSE5 += "{'E5_TIPO','" + aSE2[ni][1][nj][_TIPO   ] + "'},"
				cCposSE5 += "{'E5_PARCELA','" + aSE2[ni][1][nj][_PARCELA] + "'},"
				cCposSE5 += "{'E5_CLIFOR','" + aSE2[ni][1][nj][_FORNECE] + "'},"
				cCposSE5 += "{'E5_LOJA','"  + aSE2[ni][1][nj][_LOJA   ] + "'},"
				cCposSE5 += "{'E5_BENEF','" + aSE2[ni][1][nj][_NOME   ] + "'},"
				cCposSE5 += "{'E5_DOCUMEN','" + cOrdPago + "'},"
				cCposSE5 += "{'E5_ORDREC','" + cOrdPago + "'},"
				cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
				cCposSE5 += "{'E5_VLMOED2'," + AllTrim(Str(aSE2[ni][1][nj][_MULTA])) + "},"
				cCposSE5 += "{'E5_MOEDA','" + StrZero(aSE2[ni][1][nj][_MOEDA  ],2) + "'},"
				cCposSE5 += "{'E5_TXMOEDA'," + AllTrim(Str(aTxMoedas[aSE2[ni][1][nj][_MOEDA  ]][2])) + "},"
				cCposSE5 += "{'E5_SEQ','" + cSeq + "'},"
				If !lUsaFlag
					cCposSE5 += "{'E5_LA','S'},"
				EndIF
				cCposSE5 += "{'E5_MOTBX','NOR'}"
				cCposSE5 += "}"

				If !oFK6BxE2:IsEmpty()
					oFK6BxE2:AddLine()
				Endif

				oFK6BxE2:SetValue("FK6_IDORIG",cIDFK2)
				oFK6BxE2:SetValue("FK6_TABORI","FK2")
				oFK6BxE2:SetValue("FK6_RECPAG","P")
				oFK6BxE2:SetValue("FK6_HISTOR",STR0144)		// "Multa sobre Pago de Titulo"
				oFK6BxE2:SetValue("FK6_TPDOC","MT")
				oFK6BxE2:SetValue("FK6_VALCAL",Round(xMoeda(aSE2[ni][1][nj][_MULTA],aSE2[ni][1][nj][_MOEDA],1,,5,aTxMoedas[aSE2[ni][1][nj][_MOEDA]][2]),MsDecimais(1)))
				oFK6BxE2:SetValue("FK6_VALMOV",Round(xMoeda(aSE2[ni][1][nj][_MULTA],aSE2[ni][1][nj][_MOEDA],1,,5,aTxMoedas[aSE2[ni][1][nj][_MOEDA]][2]),MsDecimais(1)))
			Endif

			If lRet .And. aSE2[ni][1][nj][_DESCONT] > 0  .And. cOpcElt <> "1" // existem descontos
				If !Empty(cCposSE5)
					cCposSE5 += "|"
				Endif
				cCposSE5 += "{"
				cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
				cCposSE5 += "{'E5_DATA',dDataBase},"
				cCposSE5 += "{'E5_NATUREZ','" + aSE2[ni][1][nj][_NATUREZ] + "'},"
				cCposSE5 += "{'E5_PREFIXO','" + aSE2[ni][1][nj][_PREFIXO] + "'},"
				cCposSE5 += "{'E5_NUMERO','" + aSE2[ni][1][nj][_NUM    ] + "'},"
				cCposSE5 += "{'E5_TIPO','" + aSE2[ni][1][nj][_TIPO   ] + "'},"
				cCposSE5 += "{'E5_PARCELA','" + aSE2[ni][1][nj][_PARCELA] + "'},"
				cCposSE5 += "{'E5_CLIFOR','" + aSE2[ni][1][nj][_FORNECE] + "'},"
				cCposSE5 += "{'E5_LOJA','"  + aSE2[ni][1][nj][_LOJA   ] + "'},"
				cCposSE5 += "{'E5_BENEF','" + aSE2[ni][1][nj][_NOME   ] + "'},"
				cCposSE5 += "{'E5_DOCUMEN','" + cOrdPago + "'},"
				cCposSE5 += "{'E5_ORDREC','" + cOrdPago + "'},"
				cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
				cCposSE5 += "{'E5_VLMOED2'," + AllTrim(Str(aSE2[ni][1][nj][_DESCONT])) + "},"
				cCposSE5 += "{'E5_MOEDA','" + StrZero(aSE2[ni][1][nj][_MOEDA  ],2) + "'},"
				cCposSE5 += "{'E5_TXMOEDA'," + AllTrim(Str(aTxMoedas[aSE2[ni][1][nj][_MOEDA  ]][2])) + "},"
				cCposSE5 += "{'E5_SEQ','" + cSeq + "'},"
				If !lUsaFlag
					cCposSE5 += "{'E5_LA','S'},"
				EndIF
				cCposSE5 += "{'E5_MOTBX','NOR'}"
				cCposSE5 += "}"

				If !oFK6BxE2:IsEmpty()
					oFK6BxE2:AddLine()
				Endif

				oFK6BxE2:SetValue("FK6_IDORIG",cIDFK2)
				oFK6BxE2:SetValue("FK6_TABORI","FK2")
				oFK6BxE2:SetValue("FK6_RECPAG","P")
				oFK6BxE2:SetValue("FK6_HISTOR",STR0072)		// ""Descuento sobre pago de titulo""
				oFK6BxE2:SetValue("FK6_TPDOC","DC")
				oFK6BxE2:SetValue("FK6_VALCAL",Round(xMoeda(aSE2[ni][1][nj][_DESCONT],aSE2[ni][1][nj][_MOEDA],1,,5,aTxMoedas[aSE2[ni][1][nj][_MOEDA]][2]),MsDecimais(1)))
				oFK6BxE2:SetValue("FK6_VALMOV",Round(xMoeda(aSE2[ni][1][nj][_DESCONT],aSE2[ni][1][nj][_MOEDA],1,,5,aTxMoedas[aSE2[ni][1][nj][_MOEDA]][2]),MsDecimais(1)))
			EndIf

			oModBxE2:SetValue("MASTER","E5_CAMPOS",cCposSE5)
			If oModBxE2:VldData()
				oModBxE2:CommitData()
				SE2->(MsGoTo(aSE2[ni][1][nj][_RECNO]  ))
				cQuery := "select R_E_C_N_O_ from " + RetSQLName("SE5")
				cQuery += " where E5_IDORIG = '" + cIDFK2 + "'"
				cQuery += " and D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasSE5 := GetNextAlias()
				DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSE5,.F.,.T.)
				While !((cAliasSE5)->(Eof()))
					SE5->(DbGoTo( (cAliasSE5)->R_E_C_N_O_))
					
					RecLock("SE5",.F.)
					SE5->E5_TXMOEDA := aTxMoedas[SE2->E2_MOEDA][2]
					MsUnlock()
					
					If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, { "E5_LA", "S", "SE5", SE5->(Recno()), 0, 0, 0} )
					Endif
					If lFindITF .And. FinProcITF( SE5->( RecNo() ),1 ) .and. lRetCkPG(3,,SE5->E5_BANCO)//verifico se esse lancamento deve compor a base de calculo para o imposto ITF
						nBaseITF += Abs( aSE2[ni][1][nj][_PAGAR])
					EndIf
						If SE2->E2_TIPO $ MV_CPNEG+"/"+MVPAGANT
							aTitPags[SE2->E2_MOEDA]	-=	SE5->E5_VALOR
							If lReIvSU .and. SE2->E2_TIPO $ MVPAGANT
								lBaretIS := .T.	
							Endif 
						Else
							aTitPags[SE2->E2_MOEDA]	+=	SE5->E5_VALOR
						Endif
					(cAliasSE5)->(DBSkip())
				Enddo
				DbSelectArea(cAliasSE5)
				DbCloseArea()

			Else
				cLog := cValToChar(oModBxE2:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModBxE2:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModBxE2:GetErrorMessage()[6])
				Help( ,,"ORDPAG",,cLog, 1, 0 )
				lRet := .F.
			Endif
			oModBxE2:DeActivate()
			lProcCCR := Iif(!lOPRotAut,lProcCCR,.F.)

			If cPaisLoc == "ARG" .And. lProcCCR
				RecLock("FVS", .F.)
					FVS->FVS_OP := cOrdpago
				MsUnlock()
			Endif
			If lRet
				nRECSEKdiario:= SEK->(Recno())

				RecLock("SEK",.T.)
				SEK->EK_TIPODOC		:= "TB" //Titulo bajado
				SEK->EK_FILIAL		:= xFilial("SEK")
				SEK->EK_VALORIG		:= aSE2[ni][1][nj][_VALOR  ]
				SEK->EK_EMISSAO   	:= dDataBase
				SEK->EK_PREFIXO		:= aSE2[ni][1][nj][_PREFIXO]
				SEK->EK_NUM			:= aSE2[ni][1][nj][_NUM    ]
				SEK->EK_PARCELA   	:= aSE2[ni][1][nj][_PARCELA]
				SEK->EK_TIPO      		:= aSE2[ni][1][nj][_TIPO   ]
				SEK->EK_FORNECE   	:= aSE2[ni][1][nj][_FORNECE]
				SEK->EK_LOJA      		:= aSE2[ni][1][nj][_LOJA   ]
				SEK->EK_MOEDA     		:= Alltrim(Str( aSE2[ni][1][nj][_MOEDA  ]))
				SEK->EK_SALDO     		:= aSE2[ni][1][nj][_PAGAR  ]
				SEK->EK_VALOR     		:= Abs( aSE2[ni][1][nj][_PAGAR  ])
				SEK->EK_VENCTO    	:= aSE2[ni][1][nj][_VENCTO ]
				SEK->EK_JUROS     		:= aSE2[ni][1][nj][_JUROS  ]
				SEK->EK_DESCONT   	:= aSE2[ni][1][nj][_DESCONT]
				SEK->EK_ORDPAGO   	:= cOrdpago
				SEK->EK_SEQ       		:= cSeq
				SEK->EK_DTDIGIT   	:= dDataBase
				SEK->EK_FORNEPG		:= aPagos[ni][H_FORNECE]
				SEK->EK_LOJAPG		:= aPagos[ni][H_LOJA]
				SEK->EK_NATUREZ	:= aPagos[nI,H_NATUREZA]
				If cPaisLoc == "ARG"
					SEK->EK_PGCBU	:= Iif(cPaisLoc == "ARG",aPagos[ni][H_CBU],.F.)
					SEK->EK_MULTA	:= aSE2[ni][1][nj][_MULTA]
					If lProcCCR .And. SEK->(ColumnPos("EK_CCR")) > 0
						SEK->EK_CCR := mv_par15
					Endif
				EndIf
				If cPaisLoc $ "ARG/RUS"
					If cOpcElt <> "1"
						SEK->EK_EFTVAL := "1" //Movimento Efetivado
					Else
						SEK->EK_EFTVAL := "2" //Movimento Pendente
					EndIf
				
				Endif

				F850GrvTx()
				SEK->EK_VLMOED1   := Round(xMoeda(SEK->EK_VALOR,Val(SEK->EK_MOEDA),1,,5,aTxMoedas[val(SEK->EK_MOEDA)][2]),MsDecimais(1))
				MsUnlock()

				//----------------------------------------------------------
				// Salva os dados na tabela Cabe็alho da Ordem de Pago (FJR)
				//----------------------------------------------------------
				DbSelectArea("FJR")
				DbSetOrder(1)
				If !MsSeek(XFilial("FJR")+SEK->EK_ORDPAGO)
					RecLock("FJR",.T.)
					FJR->FJR_FILIAL	:= XFilial("FJR")
					FJR->FJR_ORDPAG	:= SEK->EK_ORDPAGO
					FJR->FJR_EMISSA	:= SEK->EK_EMISSAO
					FJR->FJR_NATURE	:= SEK->EK_NATUREZ
					FJR->FJR_FORNEC	:= SEK->EK_FORNEPG
					FJR->FJR_LOJA		:= SEK->EK_LOJAPG
					FJR->FJR_CANCEL	:= SEK->EK_CANCEL
					FJR->FJR_DOCREC	:= SEK->EK_DOCREC
					If cPaisLoc $ "ARG|RUS|"
						FJR->FJR_PGTELT	:= SEK->EK_PGTOELT
					EndIf
					If cPaisLoc == "RUS"
						If Len(aDet850RUS) > 0  .and. ( ni >0 ) 
					nPos := ni
						FJR->FJR_BNKCOD := aDet850RUS[nPos][_FJRBnkCod]         // aDet850RUS[nPos][_FJRBnkCod]   :=  cFJRBnkCod  
						FJR->FJR_BIKCOD := aDet850RUS[nPos][_FJRBIKCod]         // aDet850RUS[nPos][_FJRBIKCod]   :=  cFJRBIKCod  
						FJR->FJR_BKNAME := aDet850RUS[nPos][_FJRBkName]         // aDet850RUS[nPos][_FJRConta ]   :=  cFJRConta   
						FJR->FJR_EXTNMB := AllTrim(Str(Val(SEK->EK_ORDPAGO)))//aDet850RUS[nPos][_FJRExtNmb]         // aDet850RUS[nPos][_FJRBkName]   :=  cFJRBkName  
						FJR->FJR_PRIORI := aDet850RUS[nPos][_FJRPriori]         // aDet850RUS[nPos][_FJRExtNmb]   :=  cFJRExtNmb  
						FJR->FJR_REASON := aDet850RUS[nPos][_FJRReason]         // aDet850RUS[nPos][_FJRPriori]   :=  cFJRPriori  
						FJR->FJR_CONTA  := aDet850RUS[nPos][_FJRCORACC]         // aDet850RUS[nPos][_FJRReason]   :=  cFJRReason  
						FJR->FJR_RCNAME := aDet850RUS[nPos][_FJRRcName]         // aDet850RUS[nPos][_FJRCORACC]   :=  cFJRCORACC  
						FJR->FJR_KPPPAY := aDet850RUS[nPos][_FJRKPPPay]         // aDet850RUS[nPos][_FJRRcName]   :=  cFJRRcName  
						FJR->FJR_RECKPP := aDet850RUS[nPos][_FJRRecKPP]         // aDet850RUS[nPos][_FJRKPPPay]   :=  cFJRKPPPay  
						FJR->FJR_VATCOD := aDet850RUS[nPos][_FJRVATCod]         // aDet850RUS[nPos][_FJRRecKPP]   :=  cFJRRecKPP  
						FJR->FJR_VATRAT := aDet850RUS[nPos][_FJRVATRat]         // aDet850RUS[nPos][_FJRVATCod]   :=  cFJRVATCod  
						FJR->FJR_VATAMT := aDet850RUS[nPos][_FJRVATAmt]         // aDet850RUS[nPos][_FJRVATRat]   :=  cFJRVATRat  
						                                      //  aDet850RUS[nPos][_FJRVATAmt]   :=  cFJRVATAmt  
						FJR->FJR_CHFDIR := aDet850RUS[nPos][_CHFDIR_FJR]       //  aDet850RUS[nPos][_CHFDIR_FJR]  :=  ๑CHFDIR_FJR 
						FJR->FJR_CHFACC := aDet850RUS[nPos][_CHFACC_FJR]       //  aDet850RUS[nPos][_CHFACC_FJR]  :=  ๑CHFACC_FJR 
						FJR->FJR_CSHR   := aDet850RUS[nPos][_CSHR_FJR	]      //     aDet850RUS[nPos][_CSHR_FJR	]  :=  ๑CSHR_FJR	
						FJR->FJR_CSHNMB := aDet850RUS[nPos][_CSHNMB_FJR]       //  aDet850RUS[nPos][_CSHNMB_FJR]  :=  ๑CSHNMB_FJR 
						FJR->FJR_ATTACH := aDet850RUS[nPos][_ATTACH_FJR]       //  aDet850RUS[nPos][_ATTACH_FJR]  :=  ๑ATTACH_FJR 
						FJR->FJR_PSSPRT := aDet850RUS[nPos][_PSSPRT_FJR]       //  aDet850RUS[nPos][_PSSPRT_FJR]  :=  ๑PSSPRT_FJR 
						
						EndIf
					EndIf
					FJR->(MsUnlock())
				EndIf

				If aSE2[ni][1][nj][_MOEDA] == 1
					nValMoed1 += aSE2[ni][1][nj][_PAGAR]
				Else
					nValMoed1 += Round(xMoeda(Abs(aSE2[ni][1][nj][_PAGAR]),aSE2[ni][1][nj][_MOEDA],1,,5,aTxMoedas[aSE2[ni][1][nj][_MOEDA]][2]),MsDecimais(1))
				Endif

				If ExistBlock("A085ATIT")
					ExecBLock("A085ATIT",.F.,.F.)
				Endif
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !lSmlCtb
					PcoDetLan("000313","01","FINF850")
				Endif
				//Gravar reten็oes de IVA e Ingresos Brutos
				F850GravRet(aSE2[ni][1][nj],aPagos[ni][2],aPagos[ni][3],aSE2[ni][1][nj][_PARCELA],.F.,@aTitPags,nMoedaRet,,lCBU,aPagos[nI,H_NATUREZA],lPa,,lOPRotAut)
			Endif
		EndIf
	Enddo

	If lRet
		If cPaisLoc == "ARG" .And. !lMonotrb
			If lReIvSU .and. lBaretIS .and. len(aPagos[ni]) > 11
				aTitPags[SE2->E2_MOEDA]	+=  Val(aPagos[ni][H_RETIVA]) + Val(aPagos[ni][H_RETSUSS])
			Endif
			//Gravar reten็ใo de gananacias  e IB 
			F850GravRet(aSE2[nI,2],aPagos[ni][2],aPagos[ni][3],,.T.,@aTitPags,nMoedaRet,,lCBU,aPagos[nI,H_NATUREZA],lPa,,lOPRotAut)
		Endif
		If cPaisLoc $ "ARG|ANG"
			If Len(aSE2[nI,1]) > 0
				If lRetPa .And. ((SE2->E2_TIPO $ MVPAGANT) .Or. aSE2[ni][1][1][_PAGAR] = 0)
					F850GravRet(aSE2[nI,1,1],aPagos[ni][2],aPagos[ni][3],/*aSE2[ni][1][1][_PARCELA]*/,.F.,@aTitPags,nMoedaRet,.T.,lCBU,aPagos[nI,H_NATUREZA],lPa,,lOPRotAut)
				EndIf
			EndIf
		EndIf
	Endif
	/*
	pagamento com documentos proprios*/
	nK := 0
	While lRet .And. (nk < Len( aSE2[ni][3][2]))
		nK++
		If !Empty(aSE2[ni][3][2][nK][nPosTipo])
			nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(aSE2[ni][3][2][nK][nPosTipo])})
			nLenAcol := Len(aSE2[ni][3][2][nK]) - 1
			If aFormasPgto[nPosPgto,4] == "1"   // debito mediato
				lBaixaChqTmp	:=	lBaixaChq
				If Type("nPosDeb")=="N" .And. nPosDeb > 0
					lBaixaChq	:=	IIf(aSE2[ni][3][2][nk][nPosDeb]=="0",.F.,.T.)
				Endif
				lRet := GravaPagos( 2, aSE2[ni][3][2][nK][nPosBanco], aSE2[ni][3][2][nK][nPosAge], aSE2[ni][3][2][nK][nPosConta],aSE2[ni][3][2][nK][nPosNum],;
				aPagos[ni][H_FORNECE], aPagos[ni][H_LOJA],aPagos[ni][H_NOME],aSE2[ni][3][2][nK][nPosMPgto],aSE2[ni][3][2][nK][nPosVlr],;
				aSE2[ni][3][2][nK][nPosEmi],aSE2[ni][3][2][nK][nPosVcto],aFormasPgto[nPosPgto,2],,,aSE2[ni][3][2][nK][nPosParc],nBaseITF, aHdlPrv,;
				lCBU,lPa,aSE2[ni,3,2,nK,nLenAcol],,nValMoed1,aPagos[ni][H_VALORIG],aPagos[nI,H_NATUREZA],aSE2[ni][3][2][nK][nPosPrefix],aFormasPgto[nPosPgto,1],aSE2[ni][3][2][nK][nPosTalao])
				lBaixaChq := lBaixaChqTmp
			ElseIf aFormasPgto[nPosPgto,4] == "2"    // debito inmediato
				lRet := GravaPagos( 3, aSE2[ni][3][2][nK][nPosBanco], aSE2[ni][3][2][nK][nPosAge], aSE2[ni][3][2][nK][nPosConta],aSE2[ni][3][2][nK][nPosNum],;
				aPagos[ni][H_FORNECE], aPagos[ni][H_LOJA],aPagos[ni][H_NOME],aSE2[ni][3][2][nK][nPosMPgto],aSE2[ni][3][2][nK][nPosVlr],;
				aSE2[ni][3][2][nK][nPosEmi],aSE2[ni][3][2][nK][nPosVcto],,aFormasPgto[nPosPgto,2],,aSE2[ni][3][2][nK][nPosParc],nBaseITF, aHdlPrv,;
				lCBU,lPa,aSE2[ni,3,2,nK,nLenAcol],,nValMoed1,aPagos[ni][H_VALORIG],aPagos[nI,H_NATUREZA],aSE2[ni][3][2][nK][nPosPrefix],aFormasPgto[nPosPgto,1],aSE2[ni][3][2][nK][nPosTalao])
			Endif
			// Acumular os valores pagos moeda por moeda.
			If cOpcElt <> "1" .Or. lPa 
				If  cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPA 
					aTitPags[1]-=aSE2[ni][3][2][nK][nPosVlr]
				Else 
					aTitPags[aSE2[ni][3][2][nK][nPosMPgto]] -= aSE2[ni][3][2][nK][nPosVlr]
				EndIf	
			EndIf
		EndIf
	Enddo
	/*
	pagamento com documentos de terceiros*/
	If lRet .And. Len(aSE2[ni][3][3]) > 0
		nLenAcol := Len(aSE2[ni][3][3][1]) - 1
		nK := 0
		While lRet .And. (nK < Len(aSE2[ni][3][3]))
			nK++
			lRet := GravaPagos(4,"","","","",aPagos[ni][H_FORNECE],aPagos[ni][H_LOJA],aPagos[ni][H_NOME],0,0,Ctod("//"),Ctod("//"),,,aSE2[ni,3,3,nK,nLenAcol - 1],,nBaseITF,aHdlPrv,lCBU,lPa,aSE2[ni,3,3,nK,nLenAcol],,nValMoed1,aPagos[ni][H_VALORIG],aPagos[nI,H_NATUREZA],"   ")
			// Acumular os valores pagos moeda por moeda.
			aTitPags[aSE2[ni][3][3][nK][nPosMoedaE1]] -= aSE2[ni][3][3][nK][nPosVlrE1]
		Enddo
	Endif
	/*_*/
	If lRet
		F850CmpMoed(@aTitPags)
		For nA	:=	1	To	Len(aTitPags)
			IF cPaisLoc == "ARG" .and. lSmlCtb .and. !lPa .and. aTitPags[nA] < 0  
				aTitPags[nA] := aTitPags[nA] * -1 
			EndIf 
			If aTitPags[nA] < 0  // GERA PA - PAGO ANTECIPADO
				DbSelectArea("SEK")
				RecLock("SEK",.T.)
				SEK->EK_FILIAL	:= xFilial("SEK")
				SEK->EK_TIPODOC	:= "PA" //Pago adelantado
				SEK->EK_NUM    	:= cOrdPago
				SEK->EK_PARCELA	:= ALLTrim(STR(nA))
				SEK->EK_TIPO   	:= cDocCred
				SEK->EK_FORNECE	:= aPagos[ni][H_FORNECE]
				SEK->EK_LOJA   	:= aPagos[ni][H_LOJA   ]
				SEK->EK_EMISSAO	:= dDataBase
				SEK->EK_VENCTO 	:= dDataBase
				If GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPA  
					SEK->EK_VALOR  	:= Abs(aTitPags[nA])
					SEK->EK_SALDO  	:= Abs(aTitPags[nA])
					SEK->EK_VLMOED1	:= Abs(aTitPags[nA])
				Else 
					SEK->EK_VALOR  	:= Abs(aTitPags[nA])
					SEK->EK_SALDO  	:= Abs(aTitPags[nA])
					SEK->EK_VLMOED1	:= Round(xMoeda(Abs(aTitPags[nA]),nMoedaRet,1,,5,aTxMoedas[nMoedaRet][2]),MsDecimais(1))
				EndIf	
				SEK->EK_MOEDA  	:= Alltrim(Str(nMoedaRet))
				SEK->EK_ORDPAGO	:= cOrdpago
				SEK->EK_DTDIGIT	:= dDataBase
				SEK->EK_FORNEPG	:= aPagos[ni][H_FORNECE]
				SEK->EK_LOJAPG 	:= aPagos[ni][H_LOJA]
				If cPaisLoc == "ARG"
					SEK->EK_NUMOPER := cNumOp
					SEK->EK_TOTANT := nTotAnt
					SEK->EK_GRPSUS := cGrSUSS
				EndIf
				If cPaisLoc $ "ARG/COS"
					If Type("cCF")<>"U"
						SEK->EK_TES := cCF
					EndIf
				EndIf
				If cPaisLoc $ "ARG/COS"
					If Type("cProv")<>"U"
						SEK->EK_PROV := cProv
					EndIf
				EndIf
				If cPaisLoc $ "ARG/"
					SEK->EK_PGCBU	:= aPagos[ni][H_CBU]
				Endif
				If cPaisLoc <> "BRA"
					If 	cPaisLoc $ "DOM|COS|ARG" .And. lPa
						If IsInCallStack("SELPAGO")  //valida se o PA foi gerado pela rotina de gerar PA
							SEK->EK_NATUREZ := cNatureza
						Else
							SEK->EK_NATUREZ := aPagos[nI,H_NATUREZA]
						Endif
					Else
						SEK->EK_NATUREZ := aPagos[nI,H_NATUREZA]
					EndIf
				EndIf
				If cPaisLoc $ "ARG/"
					SEK->EK_SOLFUN := cSolFun
				Endif
				F850GrvTx()
				MsUnlock()

				//----------------------------------------------------------
				// Salva os dados na tabela Cabe็alho da Ordem de Pago (FJR)
				//----------------------------------------------------------
				DbSelectArea("FJR")
				DbSetOrder(1)
				If !MsSeek(XFilial("FJR")+SEK->EK_ORDPAGO)
					RecLock("FJR",.T.)
					FJR->FJR_FILIAL	:= XFilial("FJR")
					FJR->FJR_ORDPAG	:= SEK->EK_ORDPAGO
					FJR->FJR_EMISSA	:= SEK->EK_EMISSAO
					FJR->FJR_NATURE	:= SEK->EK_NATUREZ
					FJR->FJR_FORNEC	:= SEK->EK_FORNEPG
					FJR->FJR_LOJA		:= SEK->EK_LOJAPG
					FJR->FJR_CANCEL	:= SEK->EK_CANCEL
					FJR->FJR_DOCREC	:= SEK->EK_DOCREC
					If cPaisLoc $ "ARG|RUS|"
						FJR->FJR_PGTELT	:= SEK->EK_PGTOELT
					EndIf
					If cPaisLoc == "RUS" .And. !Empty(aDet850RUS)
						nPos := ni
						FJR->FJR_BNKCOD := aDet850RUS[nPos][_FJRBnkCod]         // aDet850RUS[nPos][_FJRBnkCod]   :=  cFJRBnkCod  
						FJR->FJR_BIKCOD := aDet850RUS[nPos][_FJRBIKCod]         // aDet850RUS[nPos][_FJRBIKCod]   :=  cFJRBIKCod  
						FJR->FJR_BKNAME := aDet850RUS[nPos][_FJRBkName]         // aDet850RUS[nPos][_FJRConta ]   :=  cFJRConta   
						FJR->FJR_EXTNMB := SEK->EK_ORDPAGO       // aDet850RUS[nPos][_FJRBkName]   :=  cFJRBkName  
						FJR->FJR_PRIORI := aDet850RUS[nPos][_FJRPriori]         // aDet850RUS[nPos][_FJRExtNmb]   :=  cFJRExtNmb  
						FJR->FJR_REASON := aDet850RUS[nPos][_FJRReason]         // aDet850RUS[nPos][_FJRPriori]   :=  cFJRPriori  
						FJR->FJR_CONTA  := aDet850RUS[nPos][_FJRCORACC]         // aDet850RUS[nPos][_FJRReason]   :=  cFJRReason  
						FJR->FJR_RCNAME := aDet850RUS[nPos][_FJRRcName]         // aDet850RUS[nPos][_FJRCORACC]   :=  cFJRCORACC  
						FJR->FJR_KPPPAY := aDet850RUS[nPos][_FJRKPPPay]         // aDet850RUS[nPos][_FJRRcName]   :=  cFJRRcName  
						FJR->FJR_RECKPP := aDet850RUS[nPos][_FJRRecKPP]         // aDet850RUS[nPos][_FJRKPPPay]   :=  cFJRKPPPay  
						FJR->FJR_VATCOD := aDet850RUS[nPos][_FJRVATCod]         // aDet850RUS[nPos][_FJRRecKPP]   :=  cFJRRecKPP  
						FJR->FJR_VATRAT := aDet850RUS[nPos][_FJRVATRat]         // aDet850RUS[nPos][_FJRVATCod]   :=  cFJRVATCod  
						FJR->FJR_VATAMT := aDet850RUS[nPos][_FJRVATAmt]         // aDet850RUS[nPos][_FJRVATRat]   :=  cFJRVATRat    
						FJR->FJR_CHFDIR := aDet850RUS[nPos][_CHFDIR_FJR]       //  aDet850RUS[nPos][_CHFDIR_FJR]  :=  ๑CHFDIR_FJR 
						FJR->FJR_CHFACC := aDet850RUS[nPos][_CHFACC_FJR]       //  aDet850RUS[nPos][_CHFACC_FJR]  :=  ๑CHFACC_FJR 
						FJR->FJR_CSHR   := aDet850RUS[nPos][_CSHR_FJR	]      //     aDet850RUS[nPos][_CSHR_FJR	]  :=  ๑CSHR_FJR	
						FJR->FJR_CSHNMB := aDet850RUS[nPos][_CSHNMB_FJR]       //  aDet850RUS[nPos][_CSHNMB_FJR]  :=  ๑CSHNMB_FJR 
						FJR->FJR_ATTACH := aDet850RUS[nPos][_ATTACH_FJR]       //  aDet850RUS[nPos][_ATTACH_FJR]  :=  ๑ATTACH_FJR 
						FJR->FJR_PSSPRT := aDet850RUS[nPos][_PSSPRT_FJR]       //  aDet850RUS[nPos][_PSSPRT_FJR]  :=  ๑PSSPRT_FJR 
						
						
					EndIf
					FJR->(MsUnlock())
				EndIf

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !lSmlCtb
					PcoDetLan("000313","02","FINA850")
				Endif

				//Nใo gera o registro do tํtulo, somente quando a Ordem for efetivada
				If cOpcElt <> "1"
					dbSelectArea("SE2")
					RecLock("SE2",.T.)
					SE2->E2_FILIAL	:= xFilial("SE2")
					SE2->E2_NUMLIQ 	:= cLiquid
					SE2->E2_NUM    	:= cOrdPago
					SE2->E2_PARCELA	:= AllTrim(STR(nA))
					SE2->E2_TIPO   	:= cDocCred
					If 	cPaisLoc $ "DOM|COS|ARG" .And. lPa
						If IsInCallStack("SELPAGO")  //valida se o PA foi gerado pela rotina de gerar PA
							SE2->E2_NATUREZ := cNatureza
							SE2->E2_CODAPRO := cAprov
						Else
							SE2->E2_NATUREZ := aPagos[nI,H_NATUREZA]
						Endif
					EndIf
					SE2->E2_FORNECE	:= aPagos[ni][H_FORNECE]
					SE2->E2_LOJA   	:= aPagos[ni][H_LOJA   ]
					SE2->E2_NOMFOR 	:= aPagos[ni][H_NOME   ]
					SE2->E2_EMISSAO	:= dDataBase
					SE2->E2_EMIS1  	:= dDataBase
					SE2->E2_VENCTO 	:= dDataBase
					SE2->E2_VENCORI	:= dDataBase
					SE2->E2_VENCREA	:= DataValida(dDataBase,.T.)
					SE2->E2_VALOR 	:= Abs(aTitPags[nA])
					SE2->E2_SALDO  	:= Abs(aTitPags[nA])
					SE2->E2_VLCRUZ 	:= Round(xMoeda(Abs(aTitPags[nA]),nMoedaRet,1,,5,aTxMoedas[nMoedaRet][2]),MsDecimais(1))
					SE2->E2_MOEDA  	:= nMoedaRet
					SE2->E2_TXMOEDA 	:= aTxMoedas[nMoedaRet][2]//GRAVA A TAXA DA MOEDA DO PA
					SE2->E2_STATLIB	:= '03' //Ja foi liberado na solicita็ใo de fundo.
					SE2->E2_CODAPRO	:=	FJA->FJA_CODAPR
					SE2->E2_DATALIB	:= FJA->FJA_DTOPER

					//Dados para Inclusao de adiantamento via pedido de compras
					aRecAdt := {SE2->(RECNO()),SE2->E2_VALOR}

					aAreaSA2:= SA2->(GetArea())
					SA2->(DbSetOrder(1))
					SA2->(MsSeek(xFilial("SA2")+aPagos[ni][H_FORNECE]+ aPagos[ni][H_LOJA   ]) )
					If !(IsInCallStack("SELPAGO"))
						IF !(cPaisLoc$"DOM|COS")
							SE2->E2_NATUREZ	:=  Iif( Empty(SA2->A2_NATUREZ), &(GetMv("MV_2DUPNAT")) , SA2->A2_NATUREZ )
						ELSE
							IF Empty(aPagos[nI,H_NATUREZA])
								SE2->E2_NATUREZ	:=  Iif( Empty(SA2->A2_NATUREZ), &(GetMv("MV_2DUPNAT")) , SA2->A2_NATUREZ )
							else
								SE2->E2_NATUREZ := aPagos[nI,H_NATUREZA]
							Endif
						Endif
					Endif
					SA2->(RestArea(aAreaSA2))

					SE2->E2_SITUACA	:= "0"
					SE2->E2_ORDPAGO	:= cOrdpago
					SE2->E2_ORIGEM 	:= "FINA850"
					SE2->E2_FILORIG   := cFilAnt
					If !lUsaFlag
						SE2->E2_LA        	:= "S"
					EndIf
					//Integra็ใo Protheus X TOP - Argentina  e Mexico
					If !lMsgUnica .and. nColig >0 .and. IntePMS() .and.  MsgYesNo(OemToAnsi(STR0350)+" "+"("+cDocCred+")"+" "+AllTrim(SE2->E2_NUM)+" " +OemToAnsi(STR0351)+" "+;
						GetMv("MV_SIMB1")+" "+ AllTrim(Transform(SE2->E2_VLCRUZ,PesqPict("SE2","E2_VLCRUZ")))+ " " + OemToAnsi(STR0352))//"Deseja associar o  Titulo" "de valor" "a um projeto?"
						PMSFI850()
					endif
					MsUnlock()

					If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, { "E2_LA", "S", "SE2", SE2->( RecNo() ), 0, 0, 0} )
					EndIf

					If ExistBlock("A085ATIT")
						ExecBLock("A085ATIT",.F.,.F.)
					Endif
				EndIf
			EndIf
		Next
	Endif

	// Calculo e grava็ใo de Ganacias e Ingressos Brutos para os PAดs gerados devido a inser็ใo
	// de um valor maior do que do que o valor total da ordem de pago

	If lRet .And. cPaisLoc=="ARG" .And. (SE2->E2_TIPO $ MVPAGANT) .And. lRetPA .And. !lPa
		nTotal:= 0
		nTotImp:=0
		cChave:= SE2->E2_FORNECE+SE2->E2_LOJA

		aConGan	:=	{{SA2->A2_AGREGAN,Round(xMoeda(nBaseRet,nMoedaCor,1,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(1)),'',cChave,If(lMSFil,SE2->E2_MSFIL,"")}}
		RateioCond(@aRateioGan)

		For nY	:=	1	To Len(aConGan)
			For nX:= 1 To Len(aRateioGan)
				AAdd(aConGanRat,{aConGan[nY][1],aConGan[nY][2]*aRateioGan[nX][4],aConGan[nY][3],aRateioGan[nX][2]+aRateioGan[nX][3]})
			Next
		Next

		For nY := 1 TO Len(aConGanRat)
			nPosGan   := ASCAN(aConGan,{|x|  x[1]+x[3]+x[4] == aConGanRat[nY][1]+aConGanRat[nY][3]+aConGanRat[nY][4] })
			If nPosGan==0
				Aadd(aConGan,aClone(aConGanRat[nY]))
			Endif
		Next
		aSE21:={}
		nSigno  :=   1 //  Iif(SE2->E2_TIPO $MV_CPNEG+"/"+MVPAGANT,-1,1)
		aTmp	:=	ARGRetGN(cAgente,,aConGan,aSE2[1][1][1][1],aSE2[1][1][1][2],,lOPRotAut,lPa)
		AaddSE2(1,aSE21,.T.)
		nTotRetIb	:= 0
		If Len(aSE2[1][1][1][_RETIB]) > 0

			aConfProv := CheckConfIB(SE2->E2_FORNECE,SE2->E2_LOJA,Iif(Type("cPrvEnt") == "U",cProv,cPrvEnt),If(lMsFil,SE2->E2_MSFIL," "))

			For nX := 1 to Len(aConfProv)
				aTmp1:=	ARGRetIB(cAgente,nSigno,Iif(cPaisLoc=="ARG" .And. aConfProv[nX][1] == "CO",nBaseRG,nBaseRet),aSE2[1][1][1][15][1][11],aConfProv[nX][1],.T.,,aConfProv[nX],,,,,,,,,,,lOPRotAut)
				If Len(aTmp1) > 0
					aTmp1[1][1]:=""

					For nY := 1 to Len(aTmp1)
						aAdd(aTmpIB, Array(12))
						aTmpIB[Len(aTmpIb)] := aTmp1[nY]
						nTotRetIb += aTmp1[nY][6]
					Next nY

					aTmp1   := {}
				EndIf
			Next nX

			aSE21[1,1,1,_RETIB]	:=aClone(aTmpIB)
			F850GravRet(aSE21[1,1,1],aPagos[ni][2],aPagos[ni][3],,.F.,@aTitPags,nMoedaRet,,aPagos[ni][H_CBU],aPagos[nI,H_NATUREZA],lPa,,lOPRotAut)
		EndIf

		aSE21[1][2]	:=	ACLONE(aTmp)
		F850GravRet(aSE21[1,2],aPagos[ni][2],aPagos[ni][3],,.T.,@aTitPags,nMoedaRet,,aPagos[ni][H_CBU],aPagos[nI,H_NATUREZA],lPa,.T.,lOPRotAut)
		nTotRetGn:= Iif(Len(aTmp)>0,aTmp[1][4],0)
		RecLock("SE2",.F.)
		Replace SE2->E2_VALOR With SE2->E2_VALOR + nTotRetGn + nTotRetIb
		Replace SE2->E2_SALDO With  SE2->E2_VALOR
		Replace SE2->E2_VLCRUZ With  SE2->E2_SALDO
		MsUnlock()

		dbSelectArea("SEK")
		SEK->(DbSetOrder(1))
		If SEK->(MsSeek(xFilial("SEK")+SE2->E2_NUM+SE2->E2_TIPO))
			RecLock("SEK",.F.)
			Replace SEK->EK_VALOR With SEK->EK_VALOR + nTotRetGn + nTotRetIb
			Replace SEK->EK_SALDO With  SEK->EK_VALOR
			Replace SEK->EK_VLMOED1 With  SEK->EK_VALOR
			MsUnlock()
		EndIf
	EndIf
	//Ajuste de Valores para a Reten็ใo do PA
	If lRet .And. cPaisLoc $ "DOM|COS"  .And. lPa .And. !Empty(aPagos[nI,H_NATUREZA])
		//Gera็ใo das Reten็๕es de Impostos
		If SE2->E2_TIPO	<>	"CH"
			F850GerRet("9", aPagos[nI,H_NATUREZA], SE2->E2_VALOR, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE)
		EndIf
		F850GerRet("2", aPagos[nI,H_NATUREZA], SE2->E2_VALOR, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE)
		nVlrRet 	:= F850PesAbt()
		//Ajustar Valor do CH (SE2)
		cPrefix  := SE2->E2_PREFIXO
		nNum     := SE2->E2_NUM
		nFornec  := SE2->E2_FORNECE
		cParcela := " "
		cTipoDoc := "CH"
		aAreaSE2 := SE2->(GetArea())
		cFilterSE2	:= SE2->(dbFilter())
		dbSelectArea("SE2")
		SE2->(dbClearFilter()) //limpa o filtro para selecao das parcelas ja baixadas.
		SE2->(dbGoTop())
		SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		SE2->(MsSeek(xFilial("SE2")+AvKey(cPrefix,"E2_PREFIXO")+AvKey(nNum,"E2_NUM")+AvKey(cParcela,"E2_PARCELA")+AvKey(cTipoDoc,"E2_TIPO")+AvKey(nFornec,"E2_FORNECE")))
		Do while xFilial() == SE2->E2_FILIAL .And. cPrefix==SE2->E2_PREFIXO .And. nNum==SE2->E2_NUM .AND. SE2->(!EOF())
			If ALLTRIM(SE2->E2_TIPO) $ "CH|PA"
				RecLock("SE2",.F.)
				Replace SE2->E2_VALOR  With  SE2->E2_VALOR - nVlrRet
				Replace SE2->E2_SALDO  With  SE2->E2_VALOR
				Replace SE2->E2_VLCRUZ With  SE2->E2_VALOR
				MsUnlock()
			Else
				Replace	SE2->E2_ORDPAGO With cOrdpago
			EndIf
			SE2->(DbSkip())
		Enddo

		SE2->(RestArea(aAreaSE2))
		Set Filter to &cFilterSE2 //aplica o filtro novamente

		//Ajustar Valor do CH (SEF)
		aAreaSEF:= SEF->(GetArea())
		SEF->(DbSetOrder(3))  //EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
		SEF->(MsSeek(xFilial("SEF")+AvKey(cPrefix,"EF_PREFIXO")+AvKey(nNum,"EF_TITULO")))
		Do while xFilial() == SEF->EF_FILIAL .And. cPrefix==SEF->EF_PREFIXO .And. nNum==SEF->EF_NUM .AND. SEF->(!EOF())
			If ALLTRIM(SEF->EF_TIPO) $ "CH|PA"
				RecLock("SEF",.F.)
				Replace SEF->EF_VALOR  With  SE2->E2_VALOR
				MsUnlock()
			EndIf
			SEF->(DbSkip())
		Enddo
		SEF->(RestArea(aAreaSEF))

		//Ajustar Valor do CH (SEK)
		aAreaSEK:= SEK->(GetArea())
		SEK->(DbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
		SEK->(MsSeek(xFilial("SEK")+AvKey(nNum,"EK_ORDPAGO")))
		Do while xFilial() == SEK->EK_FILIAL .And. AllTrim(nNum)==SEK->EK_ORDPAGO .AND. SEK->(!EOF())
			If ALLTRIM(SEK->EK_TIPO) $ "CH|PA"
				RecLock("SEK",.F.)
				Replace SEK->EK_VALOR  	With  SE2->E2_VALOR
				Replace SEK->EK_VLMOED1 With  SE2->E2_VALOR
				If ALLTRIM(SEK->EK_TIPO) == "PA"
					Replace SEK->EK_SALDO  	With  SE2->E2_VALOR
				EndIf
				MsUnlock()
			EndIf
			SEK->(DbSkip())
		EndDo
		SEK->(RestArea(aAreaSEK))

		aPagos[nI][H_TOTALVL] := aPagos[nI][H_TOTALVL] - nVlrRet

	EndIf

	If lRet
		If cOpcElt <> "1"
			If cPaisLoc == "ARG"
				If aPagos[ni][H_VALORIG] > 0 .And. aPagos[ni][H_VALORIG] > (aPagos[ni][H_TOTALVL] + aPagos[ni][H_DESCVL] + aPagos[ni][H_TOTRET])
					nVlrOrig := (aPagos[ni][H_TOTALVL] + aPagos[ni][H_DESCVL] + aPagos[ni][H_TOTRET])
					nVlrOrig := xMoeda(aPagos[ni][H_VALORIG],1,nMoedaCor,,5,aTxMoedas[nMoedaCor][2]) - nVlrOrig
					nSldProv := (aPagos[ni][H_TOTALVL] + aPagos[ni][H_DESCVL] + aPagos[ni][H_TOTRET]) - nVlrOrig
				Else
					nSldProv := aPagos[ni][H_DESCVL] + aPagos[ni][H_TOTALVL] + aPagos[ni][H_TOTRET]
				EndIf
				AtuaSaldos( aSE2[ni], nSldProv, aPagos[nI][H_FORNECE], aPagos[nI][H_LOJA], @nFlagMOD, @nCtrlMOD, .T.)
			Else
				AtuaSaldos( aSE2[ni], aPagos[ni][H_DESCVL]+aPagos[ni][H_TOTALVL]+IIf(cPaisLoc$"ARG|ANG|EQU|DOM",aPagos[ni][H_TOTRET],0);
				,aPagos[nI][H_FORNECE],aPagos[nI][H_LOJA],@nFlagMOD,@nCtrlMOD, .T.)
			EndIf
		Else
			//Atualiza somente o n๚mero da Ordem de Pago
			dbSelectArea("SE2")
			aAreaSE2 := SE2->(GetArea())
			For nX	:=	1 to Len(aSE2[nI][1])
				If !Empty(aSE2[nI][1][nX][_RECNO])
					SE2->(dbGoto(aSE2[nI][1][nX][_RECNO]))
					RecLock("SE2",.F.)
					Replace E2_ORDPAGO With cOrdPago
					SE2->(MsUnlock())
				EndIf
			Next nX
			SE2->(RestArea(aAreaSE2))
		EndIf

		//Grava os tํtulos de reten็๕es
		If !lSmlCtb
			For nX := 1 to Len(aTitImp)
				fGerTaxaCP(aTitImp[nX][1],aTitImp[nX][2],aTitImp[nX][3],aTitImp[nX][4],aTitImp[nX][5],aTitImp[nX][6],aTitImp[nX][7],aTitImp[nX][8],aTitImp[nX][9],aTitImp[nX][10],aTitImp[nX][11],aTitImp[nX][12],aTitImp[nX][13],aTitImp[nX][14])
			Next nX
		EndIf

		/* Quando a ordem de pago for referente a um adiantamento (PA), deve-se atualizar a solicita็ใo de fundo */
		If lPA
			FA585PAGTO(cSolFun,SEK->EK_ORDPAGO,"P",SEK->EK_FORNECE,SEK->EK_LOJA)
		Endif

		//+---------------------------------------------------------+
		//ฆ Atualiza parametro do Ultimo n๚mero da Liquida็ไo...    ฆ
		//+---------------------------------------------------------+
		If !lSmlCtb

			PUTMV("MV_NUMLIQ", cLiquid)
		EndIf
		aNump:={}
		If GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPA 
			AAdd(aNums,{cOrdPago,aPagos[nI][H_FORNECE],aPagos[nI][H_LOJA],aPagos[nI][H_NOME],Round(xMoeda(aPagos[nI][H_TOTALVL],1,nMoedaRet,,5,aTxMoedas[nMoedaRet][2],aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet)),lCBU})
			AAdd(aNump,{cOrdPago,aPagos[nI][H_FORNECE],aPagos[nI][H_LOJA],aPagos[nI][H_NOME],Round(xMoeda(aPagos[nI][H_TOTALVL],1,nMoedaRet,,5,aTxMoedas[nMoedaRet][2],aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet)),lCBU})
		Else
			AAdd(aNums,{cOrdPago,aPagos[nI][H_FORNECE],aPagos[nI][H_LOJA],aPagos[nI][H_NOME],aPagos[nI][H_TOTALVL],lCBU})
			AAdd(aNump,{cOrdPago,aPagos[nI][H_FORNECE],aPagos[nI][H_LOJA],aPagos[nI][H_NOME],aPagos[nI][H_TOTALVL],lCBU})
		EndIf	
	Endif

	If lRet .And. nHdlPrv > 0 .and. lGeraLanc .And. (cOpcElt <> "1" .Or. lSmlCtb)

		//+--------------------------------------------------+
		//ฆ Gera Lancamento Contab. para Orden de Pago.      ฆ
		//+--------------------------------------------------+
		If lGeraLanc
			SEK->(DbSetOrder(1))
			SEK->(MsSeek(xFilial("SEK")+cOrdPago,.F.))
			nRECSEKdiario := SEK->(Recno())
			SA2->(DbsetOrder(1))
			SA2->(MsSeek(xFilial("SA2")+SEK->EK_FORNECE+SEK->EK_LOJA) )
			aArea := SEK->(GetArea()) //Pega area para depois restaurar e gravar
			//os registros originais do SEK no SI2 - Chile -
			//08/05/02 - Jose Aurelio
			DbSelectArea("SEK")
			Do while !SEK->(EOF()).And.SEK->EK_ORDPAGO==cOrdPago
				

				Do Case
					Case SEK->EK_TIPODOC == "TB" .And. SEK->(EK_TIPO) $ MV_CPNEG+"/"+MVPAGANT .And. VerPadrao("5B9")
						lLancPad70 := .T.
						aHdlPrv := { nHdlPrv, "5B9", "FINA850", "PAGO011", cLoteCom }
						cPadrao:= "5B9"
					Case SEK->EK_TIPODOC == "TB" .And. !SEK->(EK_TIPO $ MV_CPNEG+"/"+MVPAGANT) .And. VerPadrao("5BA")
						lLancPad70 := .T.
						aHdlPrv := { nHdlPrv, "5BA", "FINA850", "PAGO011", cLoteCom }
						cPadrao:= "5BA"
					Case SEK->EK_TIPODOC == "PA" .And. VerPadrao("5BB")
						lLancPad70 := .T.
						aHdlPrv := { nHdlPrv, "5BB", "FINA850", "PAGO011", cLoteCom }
						cPadrao := "5BB"
					Case SEK->EK_TIPODOC == "CP" .And. SEK->(EK_TIPO $ cDebMed) .And. VerPadrao("5BC")
						lLancPad70 := .T.
						aHdlPrv := { nHdlPrv, "5BC", "FINA850", "PAGO011", cLoteCom }
						cPadrao := "5BC"
					Case SEK->EK_TIPODOC == "CP" .and. SEK->(EK_TIPO $ cDebInm) .And. VerPadrao("5BD")
						lLancPad70 := .T.
						aHdlPrv := { nHdlPrv, "5BD", "FINA850", "PAGO011", cLoteCom }
						cPadrao := "5BD"
					Case SEK->EK_TIPODOC == "CT" .And. VerPadrao("5BE")
						lLancPad70 := .T.
						aHdlPrv := { nHdlPrv, "5BE", "FINA850", "PAGO011", cLoteCom }
						cPadrao := "5BE"
					Case SEK->EK_TIPODOC == "RG" .And. VerPadrao("5BF")
						lLancPad70 := .T.
						aHdlPrv := { nHdlPrv, "5BF", "FINA850", "PAGO011", cLoteCom }
						cPadrao := "5BF"
					Otherwise
						lLancPad70 := VerPadrao("570")
						aHdlPrv := { nHdlPrv, "570", "FINA850", "PAGO011", cLoteCom }
						cPadrao := "570"
				EndCase

				If lLancPad70

					SA6->(DbsetOrder(1))
					SA6->(MsSeek(xFilial("SA6")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA,.F.))

					Do Case
						Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")) )
							cAlias := "SF2"
						Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")) )
							cAlias := "SF2"
						Otherwise
							cAlias := "SF1"
					EndCase
					cKeyImp := 	xFilial(cAlias)	+;
					SEK->EK_NUM		+;
					SEK->EK_PREFIXO	+;
					SEK->EK_FORNECE	+;
					SEK->EK_LOJA
					If ( cAlias == "SF1" )
						cKeyImp += SE1->E1_TIPO
					Endif
					If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, { "EK_LA", "S", "SEK", SEK->( RecNo() ), 0, 0, 0} )
					EndIf

					Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")

					nVlLanc:= DetProva( 	nHdlPrv,;
					cPadrao,;
					"FINA850" /*cPrograma*/,;
					cLoteCom,;
					/*@nLinha*/,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					@aFlagCTB,;
					/*aTabRecOri*/,;
					/*aDadosProva*/,;
					lSmlCtb,;
					Iif(lSmlCtb,cTabCTK,"CTK"),;
					Iif(lSmlCtb,cTabCT2,"CT2"),;
					Iif(lSmlCtb,cTabCV3,"CV3"))
					If nVlLanc == 0 .and. cPaisLoc == "ARG" .And. Len(aFlagCTB) > 0 .And. Len(aFlagCTB[Len(aFlagCTB)]) >= 2
						aFlagCTB[Len(aFlagCTB)][2]:= ""
					EndiF
					nTotalLanc := nTotalLanc + nVlLanc
				EndIf
				SEK->(DbSkip())
			EndDo
			RestArea(aArea)
		Endif
		If lLancPad70
			//+-----------------------------------------------------+
			//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
			//+-----------------------------------------------------+
			RodaProva(  nHdlPrv,;
			nTotalLanc )

			//+-----------------------------------------------------+
			//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
			//+-----------------------------------------------------+
			If UsaSeqCor()
				aDiario := {}
				aDiario := {{"SEK",nRECSEKdiario,cCodDiario,"EK_NODIA","EK_DIACTB"}}
			Else
				aDiario := {}
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Envia para Lancamento Contabil                      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lLanctOk := cA100Incl( 	cArquivo,;
			nHdlPrv,;
			3 /*nOpcx*/,;
			cLoteCom,;
			Iif(lSmlCtb,.F.,lDigita),;
			Iif(lSmlCtb,.F.,lAglutina),;
			/*cOnLine*/,;
			/*dData*/,;
			/*dReproc*/,;
			@aFlagCTB,;
			/*aDadosProva*/,;
			aDiario,;
			/*aTpSaldo*/,;
			lSmlCtb,;
			Iif(lSmlCtb, cTabCTK, "CTK"),;
			Iif(lSmlCtb, cTabCT2, "CT2"),;
			Iif(lSmlCtb, cTabCTF, "CTF"))

			SET KEY VK_F4 to
			SET KEY VK_F5 to
			SET KEY VK_F6 to
			SET KEY VK_F7 to

			If lLanctOk .And. !lUsaFlag
				SEK->(DbSetOrder(1))
				SEK->(MsSeek(xFilial("SEK")+cOrdPago))
				Do while xFilial("SEK") == SEK->EK_FILIAL .And. cOrdPago==SEK->EK_ORDPAGO.AND.SEK->(!EOF())
					RecLock("SEK",.F.)
					Replace SEK->EK_LA With "S"
					MsUnLock()
					SEK->(DbSkip())
				Enddo
			EndIf
		EndIf
	Endif
	If ExistBlock("A085AFOP")
		ExecBLock("A085AFOP",.F.,.F.,aNump)
	Endif
	//Gera diferen็a de cambio automatica

	If lRet .And. cPaisLoc $ "ANG/ARG/EQU/HAI/RUS"
		aAreaAtu:=GetArea()

			DbSelectArea("SE2")

			#IFDEF TOP
				If !(lShowPOrd)
					cFilter		:=	DbFilter()
					DbClearFilter()
				Endif
			#ELSE
				aAreaSE2	:=	GetArea()
			#ENDIF

				For Nc:=1  to  Len(aSE2[ni][1])
					cForn 		:= aSE2[nI][1][nC][01]
					cLoja		:= aSE2[nI][1][nC][02]
					cPrefixo	:= aSE2[nI][1][nC][09]
					nNum      	:= aSE2[nI][1][nC][10]
					cParcela	:= aSE2[nI][1][nC][11]
					cTipo  		:= aSE2[nI][1][nC][12]
					cMoeda		:= aSE2[nI][1][nC][04]
					SE2->(dbSetOrder(6))
					SE2->(MsSeek(xFilial("SE2")+cForn+cLoja+cPrefixo+nNum+cParcela+cTipo))
					If xFilial()==SE2->E2_FILIAL .And. nNum==SE2->E2_NUM .AND. cPrefixo==SE2->E2_PREFIXO .And. cParcela==SE2->E2_PARCELA .AND. SE2->(!EOF());
					.And. SE2->E2_CONVERT <> 'N' .And. cPaisLoc$"ARG|RUS|" .And. lGeraDCam .And. lTemMon .And. !lPa
						lExterno:=.T.

						lExecAut := .F.
						Pergunte("FIN84A",.F.)
						MV_PAR01 := 0
						MV_PAR07 := 2
						MV_PAR08 := 1
						aArea := GetArea()
						If !Empty(nMoedaCor := Val(Subs(GetMv("MV_MDCFIN"), 1, 2)))
							If !Empty(GetMv("MV_MOEDA" + Alltrim(Str(nMoedaCor))))
								If SE2->E2_MOEDA <> nMoedaCor
									MV_PAR11 := nMoedaCor
									cmoeda := aSE2[nI][1][nC][04]
									nTxaAtual := aTxMoedas[nMoedaCor][2]
									nMoedaTit := aTxMoedas[cmoeda][2]
									FA084GDif(.F.,,,lExterno)
									lExecAut := .T.
								EndIf
							EndIf
							RestArea(aArea)
						EndIf
						If lExecAut
							RecLock('SE2',.F.)
							Replace E2_DTDIFCA	With dDataBase
							MsUnLock()
						EndIf
					EndIf
				Next nC

			DbSelectArea("SE2")

			#IFDEF TOP
				If !(lShowPOrd)
					SET FILTER TO &cFilter.
				Endif
			#ELSE
				RestArea(aAreaSE2)
			#ENDIF
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDesmarca itens apos a finaliazacao da transacao  ณ
	//ณpois todos os registros foram deslocados         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea('SE2')
	For nA := 1 To Len(aRecNoSE2)
		MsGoTo(aRecNoSE2[nA][08])
		If IsMark("E2_OK",cMarcaE2,.F.)
			RecLock("SE2",.F.)
			Replace E2_OK With "  "
			nCtrlMOD-=1     //controle de sele็ใo no browse para Natureza/ITF
			If nCtrlMOD==0
				nFlagMOD:=0
			Endif
			MsUnlock()
		Endif
	Next nI
	If !lSmlCtb
		If lRet
			ConfirmSX8()
		Else
			RollBackSX8()
		Endif
	Endif

	//------------------------------
	// Atualiza a pre-ordem de pago
	//------------------------------
	If lRet .And. lShowPOrd .And. (Type("cAliasPOP") != "U" .And. Select(cAliasPOP) > 0)

		DbSelectArea(cAliasPOP)
		(cAliasPOP)->(DbSetOrder(1))
		(cAliasPOP)->(DbGoTop())
		While !((cAliasPOP)->(EOF()))
			DbSelectArea("SEK")
			SEK->(DbSetOrder(RetOrder("SEK", "EK_FILIAL+EK_FORNECE+EK_LOJA+DTOS(EK_DTDIGIT)"))) //2
			MsSeek(xFilial("SEK")+(cAliasPOP)->FJK_FORNEC+(cAliasPOP)->FJK_LOJA+ DTOS(dDataBase))
			While xFilial("SEK")+(cAliasPOP)->FJK_FORNEC+(cAliasPOP)->FJK_LOJA+ DTOS(dDataBase);
				== (SEK->EK_FILIAL + SEK->EK_FORNECE + SEK->EK_LOJA + DTOS(SEK->EK_DTDIGIT))

				For nOrdPag := 1 To Len(aNump)
		
					If 	alltrim(SEK->EK_ORDPAGO) == alltrim(aNump[nOrdPag][1])
									//nCondAgr = 2 -Agrupado por proveedor, no debe considerar la LOJA-
			
						If iIF(nCondAgr==2,(cAliasPOP)->(MsSeek(aNump[nOrdPag][2])),(cAliasPOP)->(MsSeek(aNump[nOrdPag][2]+aNump[nOrdPag][3])))
			                
							While (cAliasPOP)->(!Eof()) .And. Iif(nCondAgr==2,(cAliasPOP)->(FJK_FORNEC) == aNump[nOrdPag][2],(cAliasPOP)->(FJK_FORNEC+FJK_LOJA) == aNump[nOrdPag][2]+aNump[nOrdPag][3])
						
								If (cAliasPOP)->FJK_OK == cMarcaFJK
			
								//----------------------------------------------------------------
								// Grava o numero da ordem na FJK e remove os dados da pre do SE2
								//----------------------------------------------------------------
									A855OrdPag(aNump[nOrdPag][2], Iif(nCondAgr==2,(cAliasPOP)->FJK_LOJA,aNump[nOrdPag][3]), (cAliasPOP)->FJK_PREOP, aNump[nOrdPag][1])
			
								//---------------------------------------------------------
								// Atualiza a tabela temporaria para atualizacao do browse
								//---------------------------------------------------------
									RecLock(cAliasPOP,.F.)
									(cAliasPOP)->FJK_ORDPAG	:= aNump[nOrdPag][1]
									(cAliasPOP)->FJK_OK		:= CriaVar("FJK_OK",.F.)
									(cAliasPOP)->E2_RECNO	:= CriaVar("FJK_OK",.F.)
									(cAliasPOP)->(MsUnLock())
			
								EndIf
							(cAliasPOP)->(DbSkip())
							EndDo
						EndIf		
		
					EndIf
		
				Next nOrdPag
				SEK->(DBSKIP())
			EndDo
			(cAliasPOP)->(DBSKIP())
		EndDo

	EndIf
	/*-*/
	If !lRet
		DisarmTrans()
	Endif

	End Transaction
MsUnlockAll()
Enddo

aCCORetNoIns    := {}
aSFHNoIns       := {}
aRetImp855      := {}

If lRet
	If Len(aNums) > 0 .And. !lSmlCtb
		If !lF850NoShw  .AND. !lOPRotAut//Controle do usuแrio quanto a exibi็ใo da tela de confirma็ใo de oden de pago
			F850Show(aNums,oMainWnd,aSE2,IIf(lPa, .T., lShowPOrd))
		EndIf
	EndIf
Endif

If ExistBlock("A085AFIM")
	ExecBLock("A085AFIM",.F.,.F.,aNums)
Endif

If lRet
	If ExistBlock("A085AFM2")
		ExecBlock("A085AFM2",.F.,.F.,{aNums})
	EndIf
Endif

// ************************
// Retira sele็ใo do SE2 *
// ************************
For nA := 1 To Len(aRecNoSE2)
	MsGoTo(aRecNoSE2[nA][08])
	If IsMark("E2_OK",cMarcaE2,.F.)
		RecLock("SE2",.F.)
		Replace E2_OK With "  "
		MsUnLock()
	EndIf
Next nA //Next nI

//Atualiza os registros do TRB para atualiza็ใo da MarkBrowse
If !lShowPOrd .And. !lSmlCtb .And. (Type("cAliasTmp") != "U" .And. !Empty(cAliasTmp) .And. Select(cAliasTmp) > 0)
	F850AtuTRB()
EndIf

	


Pergunte("FIN850P",.F.)
aRecnoSE2	:=	{}
aPagConCBU := {}
aPagSinCBU := {}
Return()

/*
ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
ฐฐ+-----------------------------------------------------------------------+ฐฐ
ฐฐฐFun็เo    ฐ ProcOrdPag Autor ฐ Bruno Sobieski        ฐ Data ฐ 23.02.99 ฐฐฐ
ฐฐ+----------+------------------------------------------------------------ฐฐฐ
ฐฐฐDescri็เo ฐ Funcion Ppal de generacion de orden de pago.               ฐฐฐ
ฐฐ+-----------------------------------------------------------------------+ฐฐ
ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
*/
Function F850SE2(aSE2,lNaoMarca,lFinr995, aRecno, lOPRotAut)
Local nControl 	:= 0
Local nZ,nA,nY,nB
Local aConGan  	:= {}
Local aAreaSe2, nTotOrden	:= 0
Local cAgente		:= GETMV("MV_AGENTE")
Local nSigno   	:= 1
Local lEOFIND		:=	.F.
Local aTmp			:= {}
Local aTmp1		:= {}
Local nSaldo		:= 0
Local aValZona		:= {}
Local lNewOp 		:= .T.
Local cCondAgr
Local cFilSE2
Local aOrdPg 		:= {}
Local nI:=0, nX:=0 ,nR:=0 ,nM:=0 , nQ :=0
Local aRateioGan	:=	{}
Local nPropImp 	:= 1
Local nVLCalcRet 	:= 0
Local nValTotBas	:= 0
Local nTotSuss		:= 0
Local nProp		:= 1
Local lMonotrb 	:= .F. //Fornecedor monotribustista
Local aIVA 		:= {}
Local aGan 		:= {}
Local aIB			:= {}
Local aSUSS 		:= {}
Local lGMnParc 	:= .T. //Controle de baixas parciais de Ganancia - titulos pacelados
Local nTTit 		:= 0
Local lPropIB		:= Iif(GetMV("MV_PROPIB",.F.,1)==2,.T.,.F.)
Local lPropIVA		:= Iif(GetMV("MV_PROPIVA",.F.,2)==2,.T.,.F.)
Local aParc		:= {}
Local cChave		:= ""
Local cFilterSE2	:= ""
Local nRecnoSE2	:= 0
Local nAliqigv 	:= 0  //aliquota para calculo de retencao do igv
Local aCalcigv  	:= {} //array para calculo do igv para compensa็ao
Local lSub      	:= .f.
Local lSom      	:= .f.
Local nBaseIGV 	:= 0
Local aConfProv	:= {}
Local aTmpIb		:= {}
Local lContCBU 	:= .F.
Local lCalcSus 	:= .T.
Local nAcumul  	:= 0
Local nIB		 	:= 0
Local nIC			:= 0
Local aIBAcum 	:= {}
Local nPosAcIB 	:= 0
Local nRetIVNC 	:= 0
Local nRetRetPO 	:= 0
Local nh 			:= 0
Local nIB 			:= 0
Local nIBx 		:= 0
Local lCalcIB 	:= .T.
//Republica Dominicana
Local cNroCert  	:= " "
Local cPrefixo  	:= " "
Local nNum			:= 0
Local nValBase		:= 0
Local nValImp   	:= 0
Local nValRet   	:= 0
Local aImpCalc		:={}
Local aSaveArea1 	:= GetArea()
Local nPosSE2		:= 0
Local nVlrPOP		:= 0

//Pagamento Eletronico
Local nValLot  	:= 0
Local nf :=0
Local ng :=0
Local lSUSSPrim := .F.
Local lIIBBTotal := .F.
Local lRetPAOR := .F.
local nTBasAcS := 0
Local lPrimaVez := .T.
Local aAreaSFE := {}
Local nTotOP := 0
Local nTotVlvACs := 0
Local nVlrprop  := 0
Local cPreOP	:= ""
Local cChavePOP	:= ""
Local nPosSUSS	:= 0
Local cSerieDoc	:= ""
Local aSLIMIN	:= {}
Local nXProv := 0
Local nConcepGan := 0
Local lTpCalSus := .F.
Local nTotSus := 0
Local nMinSus := 0
Local aLimSus := {} 
Local cForSus := ""
Local cLojSus := ""

DEFAULT lFinr995  := .F.
DEFAULT lNaoMarca := .F.
Default lOPRotAut	:= .F.

Private cFornece  := ""
Private cLoja     	:= ""
Private cPrvEnt   := ""
Private aSFEIGV   := {}
Private lRetenPOP := .F.
Private lCtaCte	  := .F.

If lOPRotAut
	aRecNoSE2 := aRecno
EndIf

If lNaoMarca .And. lFinr995
	lRetPAOR := lRetPA 
	lRetPA := Nil
EndIf

If lFinr995
	lShowPOrd  	:= .T.
Endif

//Executa a efetiva็ใo da marca efetuada em tabela temporแria
If !lShowPOrd  .AND. !lOPRotAut
	F850EfSE2()
EndIf

lBxParc := IIf( Type("lBxParc")=="U", Iif(cPaisLoc <> "BRA" ,.T.,.F.), lBxParc)

//Se nao existirem os campos necessarios agrupa pagamentos por cliente+filial
If !lOPRotAut
	DbSelectArea("SEK")
EndIf
aSE2		:= {}
DbClearFilter()
DbSelectArea("SE2")
DbSetOrder(6)
cFilSE2:=xFilial("SE2")

//Ordena o array de acordo com a ordem 6...
aSort(aRecNoSE2,,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[1]+y[2]+y[3]+y[4]+y[5]+y[6]+[7]})

//Prepara o array aOrdPg para possam ser montadas as Ordens de Pago...
If lShowPOrd
	Aadd(aOrdPg,{cFilSE2,aRecnoSE2[1,2],aRecnoSE2[1,3],{},,Iif(ValType(aRecnoSE2[1,16]) == "C" ,aRecnoSE2[1,16],"")})
	aEval(aRecNoSE2,{|x,y| MArray(y,cFilSE2,nCondAgr,@aOrdPg)})
Else
	aEval(aRecNoSE2,{|x,y| MArray(y,cFilSE2,nCondAgr,@aOrdPg)})
Endif

 //Verifica se existem faturas com e sem CBU em uma mesma sele็ใo.
 //Obs.: Os dados serใo separados para que sejam geradas Ordens de Pago diferentes
If cPaisLoc == "ARG"
	F850ChkCBU(@aOrdPg)
	lContCBU := .T.
Endif

ProcRegua(Len(aRecNoSE2))
If lRetPA == Nil
	lRetPA := (GetNewPar("MV_RETPA","N") == "S")
EndIf
SA2->( dbSetOrder(1) )
SA2->( MsSeek(xFilial("SA2")+cFornece+cLoja) )
lMonotrb := Iif(SA2->A2_TIPO == "M" .And. cPaisLoc $ "ARG" ,.T.,.F.)

If lRetPA .And. cPaisLoc == "ARG" .And. !lMonotrb
	nProp		:= F850PrIS(aOrdPg) //propor็ใo para IVA e SUSS
EndIf
For nI := 1 To Len(aOrdPg)
	aIBAcum := {}
	lIIBBTotal := .F.
	cFornece	:= aOrdPg[nI][02]
	If nCondAgr == 2 //Filial + Fornecedor
		cLoja		:= ARECNOSE2[nI][03]
	Else
		cLoja		:= aOrdPg[nI][03]
	EndIf
	If lShowPOrd .and. Funname() == "FINA847"
		cPreOP		:= aOrdPg[nI][06]
		cChavePOP	:=  cPreOP + cFornece + cLoja
		lCtaCte		:= .F.
	EndIf
	SA2->( dbSetOrder(1) )
	If lMsFil .And. !Empty(xFilial("SA2")) .And. (nCondAgr <> 3) .And. xFilial("SF1") == xFilial("SA2")
		SE2->(DbGoTo(aOrdPg[nI][4][1]))
		SA2->(MsSeek(SE2->E2_MSFIL+cFornece+cLoja) )
	Else
		SA2->( MsSeek(xFilial("SA2") + PadR( cFornece, TAMSX3( "A2_COD" )[1] ) + PadR( cLoja , TAMSX3( "A2_LOJA" )[1] ) ) )
	Endif
	If !RateioCond(@aRateioGan)
		aSE2 :=	 {}
		
		If lNaoMarca .And. lFinr995 
			lRetPA := lRetPAOR
		EndIf
		
		Return .F.
	Endif
	lMonotrb := Iif(SA2->A2_TIPO == "M" .And. cPaisLoc $ "ARG" ,.T.,.F.)
	If lF850TxPg
		aTxMoedas := ExecBlock("F850TxPg",.F.,.F.,{aOrdPg,ni,aTxMoedas})
	Endif
	nTotOrden := 0
	aConGan   := {}
	nControl++
	If cPaisLoc <> "RUS" .and. !(lShowPOrd .and. Funname() == "FINA847" .and. lCtaCte)
		CalcAcIB (@aIBAcum, nI, aOrdPg, nControl, lShowPOrd, lBxParc, nPropImp, aRecnoSE2, lNaoMarca, Iif(Funname() $ "FINA855|FINR851", "", cMarcaE2), lMsFil, lRetPA, aParc, lPropIB, cAgente, aIB, lSUSSPrim, @lIIBBTotal,lOPRotAut)
		If lIIBBTotal
			aIBAcum := {}
			lSUSSPrim := .T.
			CalcAcIB (@aIBAcum, nI, aOrdPg, nControl, lShowPOrd, lBxParc, nPropImp, aRecnoSE2, lNaoMarca, Iif(Funname() $ "FINA855|FINR851", "", cMarcaE2), lMsFil, lRetPA, aParc, lPropIB, cAgente, aIB, lSUSSPrim, @lIIBBTotal,lOPRotAut)
			lIIBBTotal := .F.
			lSUSSPrim := .F.	
		EndIf
	Endif
	For nX := 1 To Len(aOrdPg[nI][4])
		IncProc()
		DbSelectArea('SE2')
		DbGoTo(aOrdPg[nI][4][nX])

		nPosSE2 := Ascan(aRecnoSE2,{|ase2| ase2[8] == aOrdPg[nI][4][nX]})

		nVlrPOP := If(nPosSE2 > 0,aRecnoSE2[nPosSE2,9],0)

		If lNaoMarca .Or. IsMark("E2_OK",cMarcaE2,.F.) .OR. lOPRotAut
			If (nCondAgr >= 2) .And. (E2_FORNECE+E2_LOJA != PadR( cFornece, TAMSX3( "E2_FORNECE" )[1] ) + PadR( cLoja , TAMSX3( "E2_LOJA" )[1] ))
				cFornece := E2_FORNECE
				cLoja    := E2_LOJA
				SA2->( dbSetOrder(1) )
				If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
					SA2->( MsSeek(SE2->E2_MSFIL+cFornece+cLoja) )
				Else
					SA2->( MsSeek(xFilial("SA2")+cFornece+cLoja) )
				Endif
			EndIf

			// Correcao do Saldo a maior em Porto Rico
			If cPaisLoc == "POR" .and. E2_SALDO > E2_VALOR
				nSaldo	:= Saldotit(E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_NATUREZ,;
							"P",E2_FORNECE,E2_MOEDA,,E2_LOJA,)
				GeraTXT(E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,Str(E2_SALDO),Str(nSaldo))
				Reclock("SE2")
				E2_SALDO	:= nSaldo
				MsUnlock()
			EndIf

			nSigno  :=      Iif(SE2->E2_TIPO $MV_CPNEG+"/"+MVPAGANT,-1,1)

			If lShowPOrd
				nTotOrden   += Round(xMoeda(nVlrPOP,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]) * nSigno,MsDecimais(1))
			Else

				//Valida se existem movimentos pendentes de efetiva็ใo
				If cPaisLoc $ "ARG"
					nValLot := F850RecPgt(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA)
				Else
					nValLot := 0
				EndIf

				If lBxParc .and. SE2->E2_VLBXPAR >0 .And.  SE2->E2_VLBXPAR <=SE2->E2_SALDO
					nTotOrden   += Round(xMoeda(SE2->E2_VLBXPAR-nValLot,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]) * nSigno,MsDecimais(1))
				Else
					nTotOrden   += Round(xMoeda(SE2->E2_SALDO-nValLot,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]) * nSigno,MsDecimais(1))
				EndIf
			Endif

			//Valor base de calculo
			If lBxParc .and. (If (cPaisLoc == "ARG",SE2->E2_VALOR <> SE2->E2_SALDO,.T.) .and. SE2->E2_VLBXPAR >0) .And.  SE2->E2_VLBXPAR <=SE2->E2_SALDO
				nValBase := SE2->E2_VLBXPAR - nValLot
			Else
				nValBase := SE2->E2_SALDO - nValLot
			EndIf

			AaddSE2( nControl, @aSE2, , aRecNoSE2 )
			aAdd(aImpCalc,{})
			If SF1->(ColumnPos("F1_LIQGR")) > 0 .And. SF2->(ColumnPos("F2_LIQGR")) > 0
				If F850VerifG(lMsFil, If(lMsFil, SE2->E2_MSFIL, " "), SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_TIPO)
					Loop
				EndIf
			EndIf
			
			cSerieDoc := ""
			If !(cPaisLoc $ "ANG")	 
				aArea:=GetArea()
				dbSelectArea("SF1")
				dbSetOrder(1)
				If lMsFil
					nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
					SF1->(dbGoTo(nRecSF1))
				Else
					nRecSF1 := FINBuscaNF(,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
					SF1->(dbGoTo(nRecSF1))
				EndIf
				cSerieDoc := SE2->E2_PREFIXO
				cChave := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
				SD1->(DbSetOrder(1))
				If lMsFil
					SD1->(MsSeek(SF1->F1_MSFIL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				Else
					SD1->(MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				EndIf

				If SD1->(Found())
					If cPaisLoc $ "ARG" .And. !Empty(SD1->D1_PROVENT)
						cPrvEnt := SD1->D1_PROVENT
					ElseIf cPaisLoc $ "ARG" .And. !Empty(SF1->F1_PROVENT)
						cPrvEnt := SF1->F1_PROVENT
					EndIf
				EndIf
				RestArea(aArea)
				If lMonotrb
					//Verifica as retencoes parciais ja realizadas.
					dbSelectArea("SEK")
			   		dbGoTop()
			   		dbSetOrder(6)

			   		//Posiciona nas ordens de pago referente ao titulo
			   		If SEK->(MsSeek(xFilial("SEK")+SE2->E2_PREFIXO+SE2->E2_NUM))
			   			While SEK->(!Eof()) .and. SE2->E2_PREFIXO+SE2->E2_NUM == SEK->EK_PREFIXO+SEK->EK_NUM
			   				If SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_TIPO == SEK->EK_FORNECE+SEK->EK_LOJA+SEK->EK_TIPO
			   					dbSelectArea("SFE")
			   					dbGoTop()
			   					dbSetOrder(2)
	
			   					//posiciona de registro de imposto referente a ordem de pago
			   					If SFE->(MsSeek(xFilial("SFE")+SEK->EK_ORDPAGO))
			   						While SFE->(!Eof()) .And. SFE->FE_ORDPAGO == SEK->EK_ORDPAGO
			   							If(SFE->FE_TIPO = "I")
			   								aAdd(aIVA, {SFE->FE_CFO, SFE->FE_RETENC, SFE->FE_PARCELA })
			   							ElseIf(SFE->FE_TIPO = "G") .And. lGMnParc .And. Empty(SFE->FE_DTESTOR)
			   								aAdd(aGan, {SFE->FE_CONCEPT, SFE->FE_RETENC})
			   							ElseIf(SFE->FE_TIPO = "B")  .And. cPrvEnt == "CF"
			   								aAdd(aIB, {SFE->FE_NFISCAL, SFE->FE_SERIE, SFE->FE_EST, SFE->FE_RETENC})
			   							Endif
			   							SFE->(dbSkip())
			   						Enddo
			   					Endif
			   				EndIf
			   				SEK->(dbSkip())
			   			Enddo
			   			lGMnParc := .F.
			   		Endif

				  	//Monta o array das parcelas
				 	nRecnoSE2	:= SE2->(Recno())
				 	cChave		:= SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
				 	cFilterSE2	:= SE2->(dbFilter())
				 	dbSelectArea("SE2")
				 	SE2->(dbClearFilter()) //limpa o filtro para selecao das parcelas ja baixadas.
				 	SE2->(dbGoTop())

				 	If SE2->(MsSeek(cChave))
					 	While SE2->(!Eof()) .And. xFilial("SE2")+SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cChave
							If !Empty(SE2->E2_PARCELA)
								aAdd(aParc,SE2->E2_PARCELA)
							Endif
					 		SE2->(dbSkip())
					 	Enddo
					 Endif

				 	Set Filter to &cFilterSE2 //aplica o filtro novamente
				 	SE2->(dbGoTo(nRecnoSE2))

			  	Endif

				//Acumular bases para retencao de ganancias...
				If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
					If lMonotrb .And. Len(aGan) > 0
						F850AcRe2(@aConGan,nSigno,SE2->E2_VALOR,aRateioGan,,lMonotrb)
					Else
						If lShowPOrd
							F850AcRe2(@aConGan,nSigno,nVlrPOP,aRateioGan,,lMonotrb)
						Else
							F850AcRe2(@aConGan,nSigno,nValBase,aRateioGan,,lMonotrb)
						Endif
					EndIf
					nTTit := 2 //SD2/SF2
				Else
					If lMonotrb .And. Len(aGan) > 0 .And. !SE2->E2_TIPO $ MVCHEQUE
						F850AcRet(@aConGan,nSigno,SE2->E2_VALOR,aRateioGan,lMonotrb)
					Else
						If (lMonotrb .And. !SE2->E2_TIPO $ MVCHEQUE) .Or. !lMonotrb
							If lShowPOrd
								F850AcRet(@aConGan,nSigno,nVlrPOP,aRateioGan,lMonotrb)
							Else
								F850AcRet(@aConGan,nSigno,nValBase,aRateioGan,lMonotrb)
							Endif
						EndIf
				    EndIf
				    nTTit := 1 //SD1/SF1
				Endif
				IF cPaisLoc == "ARG" .And. nControl >=1 .And. Len(aSE2) >= nControl  .And. Len(aSE2[nControl])>=1 .And. Len(aSE2[nControl][1]) > 0

					nConcepGan := aScan(aConGan,{ |x| x[1] == "07" })
					If cPaisLoc == "ARG" .And. FindFunction("F850PCuit") .And. (subs(cAgente,1,1) == "S" .Or. nConcepGan > 0)
						For nXProv := 1 To Len(aRateioGan)
							F850PCuit(aRateioGan[nXProv][2], aRateioGan[nXProv][3], @aProvCuit)
						Next nXProv
					EndIf

						//+----------------------------------------------------------------+
						//ฐ Generar la Retenci๓n de Ganancias.                             ฐ
						//+----------------------------------------------------------------+
						If lMonotrb .And. (Len(aConGan) > 0)
							aTmp	:=	ARGRetGNMnt(cAgente,1,aConGan,cFornece,cLoja,SE2->E2_NUM,SE2->E2_PREFIXO,,nTTit,cChavePOP)
			
							//Realizando os ajustes de Ganancia, quando realizada a baixa parcial
							If Len(aGan) > 0
								For nX := 1 to Len(aGan)
									For nA := 1 to Len(aTmp)
								 		If (aGan[nX][1] == aTmp[nA][7]) .And. (aTmp[nA][5] >= aGan[nX][2])
								 			aTmp[nA][5] -= aGan[nX][2]
								 		Endif
			
								 		//Ajuste para gravacao da retencao como NORET
								 		If aTmp[nA][5] == 0
								 			aDel(aTmp,nA)
								 			aSize(aTmp, Len(aTmp)-1)
								 		Endif
									Next nA
								Next nX
							Endif
			
							aGan := {}
						Else
							aTmp	:=	ARGRetGN(cAgente,1,aConGan,cFornece,cLoja,cChavePOP,lOPRotAut,.F., nValBase)
						Endif

						aSE2[nControl][2]	:=	ACLONE(aTmp)
						For nQ := 1 to Len(aSE2[nControl][2])
							aAdd (aImpCalc,{"GAN",aSE2[nControl][2][nQ][4]})
						Next nQ

				ElseIf     nControl >=1 .And. Len(aSE2) >= nControl  .And. Len(aSE2[nControl])>=1  .And.   Len(aSE2[nControl][1]) == 0
						nControl--
				Endif 
				lCalcIVA:=.T.
				
				//Estrutura condicional que vai identificar se o fornecedor ้ isento de reten็ใo de IVA
				If (cPaisloc == "ARG" .and. (Alltrim(SE2->E2_TIPO) == "PA" .or. SA2->A2_AGENRET == "S" .and. AllTrim(cSerieDoc) <> "M"))  .or. (cPaisLoc == "RUS")
					lCalcIVA := .F.
				Else
					lCalcIVA := .T.
				EndIF
				
				If !Empty(SE2->E2_PARCELA)
					For nf:=1 to Len(aSE2)
						For ng:=1 to Len(aSE2[nf][1])  
							If aSE2[nf][1][ng][1] ==SE2->E2_FORNECE .And.  aSE2[nf][1][ng][2] == SE2->E2_LOJA .And. aSE2[nf][1][ng][9] ==SE2->E2_PREFIXO; 
								.And.	aSE2[nf][1][ng][10]== SE2->E2_NUM .And. aSE2[nf][1][ng][12]==SE2->E2_TIPO .And.  aSE2[nf][1][ng][11]<>SE2->E2_PARCELA ;
								.And. Len(aSE2[nf][1][ng][_RETIVA])> 0  
									lCalcIVA:=.F.
							EndIf	  	
						Next ng
					Next nf
				EndIf	
				aTmp   := {}
				If lCalcIVA
					//+----------------------------------------------------------------+
					//ฐ Generar las Retenci๓n de IVA.                                  ฐ
					//+----------------------------------------------------------------+
					If lMonotrb
						If (Len(aParc) > 1 .And. SE2->E2_PARCELA == aParc[1] .And. !lPropIVA) .Or. Len(aParc) == 0 .Or. (lPropIVA .And. Len(aParc) > 1)
							If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
								If Len(aIVA) > 0
									aTmp	:=	ArgRetIM2(cAgente,nSigno,SE2->E2_VALOR,nProp,,,,,lOPRotAut)
								Else
									If lShowPOrd
										aTmp := ArgRetIM2(cAgente,nSigno,nVlrPOP,nProp,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_EMISSAO,lOPRotAut)
									Else
										aTmp	:=	ArgRetIM2(cAgente,nSigno,nValBase,nProp,,,,,lOPRotAut)
									Endif
								Endif
							 Else
								If Len(aIVA) > 0
									aTmp	:=	ArgRetIM(cAgente,nSigno,SE2->E2_VALOR,,,,nProp,,,,,,,lOPRotAut)
								Else
									If lShowPOrd
										aTmp	:=	ArgRetIM(cAgente,nSigno,nVlrPOP,,,,nProp,,,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_EMISSAO,lOPRotAut)
									Else
										aTmp	:=	ArgRetIM(cAgente,nSigno,nValBase,,,,nProp,,,,,,,lOPRotAut)
									Endif
								Endif
							Endif
						Else
							aTmp := {}
						Endif
					ElseIf (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
						If lShowPOrd
		   					aTmp	:=	ArgRetIV2(cAgente,nSigno,nVlrPOP,nProp,,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_EMISSAO,lOPRotAut)
		   				Else
							aTmp	:=	ArgRetIV2(cAgente,nSigno,nValBase,nProp,,,,,,lOPRotAut)
						Endif
					Else
						If lShowPOrd
					   		aTmp	:=	ArgRetIVA(cAgente,nSigno,nVlrPOP,,,,nProp,,,,,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_EMISSAO,lOPRotAut)
						Else
							aTmp	:=	ArgRetIVA(cAgente,nSigno,nValBase,,,,nProp,,,,,,,,,lOPRotAut)
						Endif
					Endif
				EndIf
				//+------------------------------------------------------------------------+
				//ฐ Caso a variavel aTmp seja logica significa que a rotina de ordem       ฐ
				//ฐ de pago tem que ser abortada porque a data de vencimento da observacao ฐ
				//ฐ (Campo A2_VRETIVA) ja esta vencida e o usuario tem que informar        ฐ
				//ฐ uma nova data...                                                       ฐ
				//+------------------------------------------------------------------------+
				If ValType(aTmp) == "L" .And. !aTmp
					aSE2 := {}
					
					If lNaoMarca .And. lFinr995 
						lRetPA := lRetPAOR
					EndIf
					
					Return
				EndIf
				//Realizando os ajustes de IVA, quando realizada a baixa parcial
				If lMonotrb
					If Len(aIVA) > 0
						For nZ := 1 to Len(aIVA)
							For nA := 1 to Len(aTmp)
						 		If (AllTrim(aIVA[nZ][1]) == AllTrim(aTmp[nA][9])) .And. (aTmp[nA][6] >= aIVA[nZ][2]) .And. (Empty(SE2->E2_PARCELA) .Or. (!Empty(SE2->E2_PARCELA) .And. SE2->E2_PARCELA == aIVA[nZ][3]))
						 			aTmp[nA][6] -= aIVA[nZ][2]
						 		Endif
							Next nA
						Next nZ
					Endif
				Endif

				aIVA:={}
				If Len(aTmp) > 0
					aSE2[nControl][1][Len(aSE2[nControl][1])][_RETIVA]	:=aClone(aTmp)
					For nQ := 1 to Len (aSE2[nControl][1][Len(aSE2[nControl][1])][_RETIVA])
						aAdd(aImpCalc[Len(aSE2[nControl][1])],{"IVA",aSE2[nControl][1][Len(aSE2[nControl][1])][_RETIVA][nQ][6]})
					Next nQ	
				Endif
				aTmp   := {}
				//+----------------------------------------------------------------+
				//ฐ Generar las Retenci๓n de IB.                                   ฐ
				//+----------------------------------------------------------------+
				nPosAcIB := aScan(aIBAcum, {|x| x[1] == aOrdPg[nI][4][nX]})
				If nPosAcIB > 0 .or. (lShowPOrd .and. Funname() == "FINA847" .and. lCtaCte)
					aConfProv := CheckConfIB(SE2->E2_FORNECE,SE2->E2_LOJA,cPrvEnt,If(lMsFil,SE2->E2_MSFIL," "))
					
				    For nB := 1 to Len(aConfProv)
				    	If (lShowPOrd .and. Funname() == "FINA847") .and. lCtaCte
				    		If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
				    			aTmp	:=	ARGRetIB2(cAgente,nSigno,nVlrPOP,nPropImp,aConfProv[nB], lSUSSPrim, @lIIBBTotal, , , ,.F.,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_EMISSAO,lOPRotAut)
				    		Else
				    			aTmp	:=	ARGRetIB(cAgente,nSigno,nVlrPOP,,,,nPropImp,aConfProv[nB], lSUSSPrim, @lIIBBTotal, , , ,.F.,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_EMISSAO,lOPRotAut)
				    		EndIf
				    	Else
					    	nPosAcIB := aScan(aIBAcum, {|x| x[1] == aOrdPg[nI][4][nX] .And. AllTrim(x[4]) == AllTrim(aConfProv[nB][1]) .And. AllTrim(x[5]) == AllTrim(SE2->E2_TIPO)})
					    	If nPosAcIB > 0 
					    		lCalcIB := .T.
								If !Empty(SE2->E2_PARCELA) .and. aConfProv[nB][5] == "2"
									For nIB := 1 To Len(aSE2[1][1])
										If aSE2[nControl][1][nIB][1] ==SE2->E2_FORNECE .And.  aSE2[nControl][1][nIB][2] == SE2->E2_LOJA .And. aSE2[nControl][1][nIB][9] ==SE2->E2_PREFIXO; 
											.And.	aSE2[nControl][1][nIB][10]== SE2->E2_NUM .And. aSE2[nControl][1][nIB][12]==SE2->E2_TIPO .And.  aSE2[nControl][1][nIB][11]<>SE2->E2_PARCELA ;
												.And. Len(aSE2[nControl][1][nIB][_RETIB])> 0  
												//For nIBx := 1 To Len(aSE2[1][1][nIB][_RETIB])
													lCalcIB := .F.
												//EndIf
											EndIf
									Next nIB
								EndIF
								IF lRetPA .Or. !(SE2->E2_TIPO $ MVPAGANT)  .and. lCalcIB
									If aConfProv[nB][4] <> "M" .Or. (aConfProv[nB][4] == "M" .And. ((Len(aParc) > 1 .And. SE2->E2_PARCELA == aParc[1] .And. !lPropIB) .Or. Len(aParc) == 0 .Or. (lPropIB .And. Len(aParc) > 1)))
										If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
										    If Len(aIB) > 0 .And. aConfProv[nB][4] == "M" .And. cPrvEnt == "CF"									    		
										    	aTmp	:=	ARGRetIB2(cAgente,nSigno,SE2->E2_VALOR,nPropImp,aConfProv[nB],lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
										    Else
												If lShowPOrd
													aTmp	:=	ARGRetIB2(cAgente,nSigno,nVlrPOP,nPropImp,aConfProv[nB],  lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
												Else
													aTmp	:=	ARGRetIB2(cAgente,nSigno,nValBase,nPropImp,aConfProv[nB], lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
												Endif


											Endif
										Else
											If Len(aIB) > 0 .And. aConfProv[nB][4] == "M" .And. cPrvEnt == "CF"
												aTmp	:=	ARGRetIB(cAgente,nSigno,SE2->E2_VALOR,,,,nPropImp,aConfProv[nB],lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
										 	Else
												If lShowPOrd
													aTmp	:=	ARGRetIB(cAgente,nSigno,nVlrPOP,,,,nPropImp,aConfProv[nB],  lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
												Else
													aTmp	:=	ARGRetIB(cAgente,nSigno,nValBase,,,,nPropImp,aConfProv[nB], lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
												Endif


											Endif
										Endif
									Else
										aTmp := {}
									Endif


								Endif
			
								//Realizando os ajustes de IB, quando realizada a baixa parcial
								If aConfProv[nB][4] == "M" .And. cPrvEnt == "CF"
									If Len(aIB) > 0
										For nZ := 1 to Len(aIB)
											For nA := 1 to Len(aTmp)
										 		If (aIB[nZ][1] == aTmp[nA][1]) .And. (aIB[nZ][2] == aTmp[nA][2]) .And. (aIB[nZ][3] == aTmp[nA][9]) .And. (aTmp[nA][5] >= aIB[nZ][4])
										 			aTmp[nA][5] -= aIB[nZ][4]
										 		Endif
											Next nA
										Next nZ
									Endif
								Endif
			
								aIB := {}
			
							EndIf
						EndIf
						If Len(aTmp) > 0
							For nA := 1 to Len(aTmp)
								aAdd(aTmpIB, Array(12))
								aTmpIB[Len(aTmpIb)] := aTmp[nA]
							Next nA
	
							aTmp   := {}
	
						Endif
					Next nB
				EndIf

				If Len(aTmpIB) > 0
					aSE2[nControl][1][Len(aSE2[nControl][1])][_RETIB]	:= aClone(aTmpIB)
					For nQ:= 1 to Len (aSE2[nControl][1][Len(aSE2[nControl][1])][_RETIB])
						aAdd(aImpCalc[Len(aSE2[nControl][1])],{"IB",aSE2[nControl][1][Len(aSE2[nControl][1])][_RETIB][nQ][5]})
					Next nQ
					aTmpIB := {}
				Else
					aTmpIB := {}
					aSE2[nControl][1][Len(aSE2[nControl][1])][_RETIB] := aClone(aTmpIB)
				Endif

				If (cPaisloc == "ARG" .and. Alltrim(SE2->E2_TIPO) == MVPAGANT) .or. (cPaisLoc == "RUS")
					lCalcSus := .F.
				Else
					lCalcSus := .T.
				EndIF

				//+----------------------------------------------------------------+
				//ฐ Generar las Retenci๓n de SUSS.                                   ฐ
				//+----------------------------------------------------------------+
				aTmp   := {}
				If lCalcSus
						If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
							If lShowPOrd
						   		aTmp	:=	ARGRetSU2(cAgente,nSigno,nVlrPOP,nProp,aSUSS,aImpCalc,Len(aSE2[nControl][1]),cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_EMISSAO,lOPRotAut)
						 	Else
								aTmp	:=	ARGRetSU2(cAgente,nSigno,nValBase,nProp,aSUSS,aImpCalc,Len(aSE2[nControl][1]),,,,,lOPRotAut)
							Endif
						Else
							If lShowPOrd 
								aTmp	:=	ARGRetSUSS(cAgente,nSigno,nVlrPOP,,nProp,aSUSS,aImpCalc,Len(aSE2[nControl][1]),,,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_EMISSAO,lOPRotAut)
							Else
								aTmp	:=	ARGRetSUSS(cAgente,nSigno,nValBase,,nProp,aSUSS,aImpCalc,Len(aSE2[nControl][1]),,,,,,,lOPRotAut)
							EndIf 
						Endif
						If Len(aTmp) > 0
							aSE2[nControl][1][Len(aSE2[nControl][1])][_RETSUSS] := aClone(aTmp)
	
							//Ajuste para o cแlculo de SUSS quando mais de 1 tํtulo for selecionado
							For nZ := 1 to Len(aTmp)
								aAdd(aSUSS, aTmp[nZ])
							Next nZ
							For nQ:= 1 to Len (aSE2[nControl][1][Len(aSE2[nControl][1])][_RETSUSS])
								aAdd(aImpCalc[Len(aSE2[nControl][1])],{"SUSS",aSE2[nControl][1][Len(aSE2[nControl][1])][_RETSUSS][nQ][6]})
							Next nQ
						Endif
						aTemp := {}
				Endif
				
				lSUSSPrim := .T.
				aTmp   := {}
				//Si el calculo de IIBB se calcula total y es para argentina, realiza el calculo despu้s del SUSS 
				If lIIBBTotal .And. cPaisLoc == "ARG" .and. !(lShowPOrd .and. Funname() == "FINA847" .and. lCtaCte)
					//+----------------------------------------------------------------+
					//ฐ Generar las Retenci๓n de IB.                                   ฐ
					//+----------------------------------------------------------------+
					nPosAcIB := aScan(aIBAcum, {|x| x[1] == aOrdPg[nI][4][nX]})
					If nPosAcIB > 0
						aConfProv := CheckConfIB(SE2->E2_FORNECE,SE2->E2_LOJA,cPrvEnt,If(lMsFil,SE2->E2_MSFIL," "))
						
					    For nB := 1 to Len(aConfProv)
					    	nPosAcIB := aScan(aIBAcum, {|x| x[1] == aOrdPg[nI][4][nX] .And. AllTrim(x[4]) == AllTrim(aConfProv[nB][1]) .And. AllTrim(x[5]) == AllTrim(SE2->E2_TIPO)})
							If nPosAcIB > 0
								IF lRetPA .Or. !(SE2->E2_TIPO $ MVPAGANT)
									If aConfProv[nB][4] <> "M" .Or. (aConfProv[nB][4] == "M" .And. ((Len(aParc) > 1 .And. SE2->E2_PARCELA == aParc[1] .And. !lPropIB) .Or. Len(aParc) == 0 .Or. (lPropIB .And. Len(aParc) > 1)))
										If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
											If Len(aIB) > 0 .And. aConfProv[nB][4] == "M" .And. cPrvEnt == "CF"
												 aTmp	:=	ARGRetIB2(cAgente,nSigno,SE2->E2_VALOR,nPropImp,aConfProv[nB],lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)	
										    Else
												If lShowPOrd
													aTmp	:=	ARGRetIB2(cAgente,nSigno,nVlrPOP,nPropImp,aConfProv[nB],  lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
												Else
													aTmp	:=	ARGRetIB2(cAgente,nSigno,nValBase,nPropImp,aConfProv[nB], lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
												Endif
											Endif
										Else 
											If Len(aIB) > 0 .And. aConfProv[nB][4] == "M" .And. cPrvEnt == "CF"
										    	aTmp	:=	ARGRetIB(cAgente,nSigno,SE2->E2_VALOR,,,,nPropImp,aConfProv[nB],lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)	
										 	Else
												If lShowPOrd
													aTmp	:=	ARGRetIB(cAgente,nSigno,nVlrPOP,,,,nPropImp,aConfProv[nB],  lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
												Else				 
													aTmp	:=	ARGRetIB(cAgente,nSigno,nValBase,,,,nPropImp,aConfProv[nB], lSUSSPrim, @lIIBBTotal, , , ,aIBAcum[nPosAcIB][6],,,,,lOPRotAut)
												Endif
											Endif
										Endif
									Else
										aTmp := {}
									Endif                                      
								Endif
								
								//Realizando os ajustes de IB, quando realizada a baixa parcial
								If aConfProv[nB][4] == "M" .And. cPrvEnt == "CF"
									If Len(aIB) > 0
										For nZ := 1 to Len(aIB)
											For nA := 1 to Len(aTmp)                   
										 		If (aIB[nZ][1] == aTmp[nA][1]) .And. (aIB[nZ][2] == aTmp[nA][2]) .And. (aIB[nZ][3] == aTmp[nA][9]) .And. (aTmp[nA][5] >= aIB[nZ][4])
										 			aTmp[nA][5] -= aIB[nZ][4] 
										 		Endif
											Next nA
										Next nZ
									Endif
								Endif
								
								aIB := {}
								
								If Len(aTmp) > 0
									
									For nA := 1 to Len(aTmp)
										aAdd(aTmpIB, Array(12))
										aTmpIB[Len(aTmpIb)] := aTmp[nA]
									Next nA 
									
									aTmp   := {}
									
								Endif
							EndIf
						Next nB
					EndIf
					
					If Len(aTmpIB) > 0                       
						aSE2[nControl][1][Len(aSE2[nControl][1])][_RETIB]	:= aClone(aTmpIB)
						aTmpIB := {}
					Else
						aTmpIB := {}
						aSE2[nControl][1][Len(aSE2[nControl][1])][_RETIB] := aClone(aTmpIB)
					Endif
					lSUSSPrim := .F.
					lIIBBTotal := .F.
				EndIf
				
				//+----------------------------------------------------------------+
				//ฐ Generar las Retenci๓n de Servicio de Limpeza de Inmueble.      ฐ
				//+----------------------------------------------------------------+
				aTmp   := {}
				If !lMonotrb
					If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
						If lShowPOrd
							aTmp	:=	ARGRetSL2(cAgente,nSigno,nVlrPOP,,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,lOPRotAut)
						Else
							aTmp	:=	ARGRetSL2(cAgente,nSigno,nValBase,,,,,lOPRotAut)
						Endif
					Else
						If lShowPOrd
							aTmp	:=	ARGRetSLI(cAgente,nSigno,nVlrPOP,,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,lOPRotAut)
						Else
							aTmp	:=	ARGRetSLI(cAgente,nSigno,nValBase,,,,,lOPRotAut)
						Endif
					Endif
					If Len(aTmp) > 0
						aSE2[nControl][1][Len(aSE2[nControl][1])][_RETSLI] :=aClone(aTmp)
					Endif
				Endif
				//+----------------------------------------------------------------+
				//ฐ Generar las Retenci๓n por inspecci๓n de Seguridad e Higiene    ฐ
				//+----------------------------------------------------------------+

				aTmp   := {}
				If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
					If lShowPOrd
						aTmp	:=	ARGSegF2(cAgente,nSigno,nVlrPOP,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,@aSLIMIN,lOPRotAut)
					Else
						aTmp	:=	ARGSegF2(cAgente,nSigno,nValBase,,,,@aSLIMIN,lOPRotAut)
					Endif
				Else
					If lShowPOrd
						aTmp	:=	ARGSegF1(cAgente,nSigno,nVlrPOP,cChavePOP,SE2->E2_NUM,SE2->E2_PREFIXO,@aSLIMIN,lOPRotAut)
					Else
						aTmp	:=	ARGSegF1(cAgente,nSigno,nValBase,,,,@aSLIMIN,lOPRotAut)
					Endif
				Endif
				aSE2[nControl][1][Len(aSE2[nControl][1])][_RETISI] :=aClone(aTmp)

				//Pago com CBU - Sim/Nใo
				aSE2[nControl][1][Len(aSE2[nControl][1])][_CBU] := Iif(lContCBU .And. Len(aOrdPg[nI]) > 4, aOrdPg[nI][5], .F.)
				aTmp := {}
			Endif

			//ANGOLA
			If cPaisLoc == "ANG"
				//+----------------------------------------------------------------+
				//ฐ Retencao do Imposto sobre Empreitadas                          ฐ
				//+----------------------------------------------------------------+
				If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
					If lShowPOrd
   						aTmp	:=	CalcRetRIE(nVlrPOP,.T.,nSigno)
					Else
						aTmp	:=	CalcRetRIE(nValBase,.T.,nSigno)
					Endif
				Else
					If lShowPOrd
						aTmp	:=	CalcRetRIE(nVlrPOP,,nSigno)
					Else
						aTmp	:=	CalcRetRIE(nValBase,,nSigno)
					Endif
				Endif
				If Len(aTmp) > 0
					aSE2[nControl][1][Len(aSE2[nControl][1])][_RETRIE]	:=aClone(aTmp)
				Endif
			Endif
	    Endif
	Next nX
Next nI

// Verifica se teve calculo de reten็ใo do SUSS para titulos NF
// Caso nao tenha calculo retencao para NF deve ser zerado as reten็ใo calculadas para notas de credito
If cPaisLoc == "ARG" .And.  Len(aSuss) > 0
	
	aSort(aSuss, , , {|x, y| x[11] + x[12] < y[11] + y[12]}) // garanto que o Fornec + loja estejam em sequencia.
	cForSus := aSuss[1][11]
	cLojSus := aSuss[1][12]
	For nI := 1 to Len(aSuss) // Verifico todos os itens gerados no FINRETSUS
		IF cForSus == aSuss[nI][11] .and. cLojSus == aSuss[nI][12]
			nTotSus += aSuss[nI][3] // Soma da base tributavel por Fornec + loja
			nMinSus := aSuss[nI][15] // Valor do minimo tributavel sempre ้ igual pro mesmo Fornec + loja
		Else
			IF nTotSus <= nMinSus 
				aadd(aLimSus,{cForSus,cLojSus}) // Array com todos Fornec + loja que nใo superarm o minimo tributavel
			EndIF
			cForSus := aSuss[nI][11]
			cLojSus := aSuss[nI][12]
			nTotSus := aSuss[nI][3]
			nMinSus := aSuss[nI][15]
		EndIF
	Next nI
	IF ABS(nTotSus) <= nMinSus
		aadd(aLimSus,{cForSus,cLojSus}) //Valida็ใo para o ultimo registro.
	EndIF

	IF Len(aLimSus) > 0 .and. Len(aSe2) > 0  .and. Len(aSe2[1][1]) > 0 
		For nI := 1 to Len(aLimSus) //Caso o array aLimSus esteja maior que zero
			For nY := 1 to Len(aSe2[1][1]) // apago os valores de reten็ใo para os fonecedores que nใo superam o minimo.
				IF aLimSus[nI][1] == aSe2[1][1][nY][1] .and.  aLimSus[nI][2] == aSe2[1][1][nY][2]
					aSe2[1][1][nY][_RETSUSS] := {}
				EndIF
			Next nY			
		Next nI
	EndIF

	For nI := 1 To Len(aOrdPg)
		cFor := aOrdPg[nI][02]
		cLojFor    := aOrdPg[nI][03] 
		nTotOP:= 0    
		lPrimaVez:= .T.
		nTBasAcS:= 0 
		nTotVlvACs:= 0
		nVlrprop:= 0
 		For nY:= 1 To Len(aSuss)
			IF (Alltrim(aSuss[nY][8])=="4" .or. Alltrim(aSuss[nY][8])=="1") .and. IIf(!Empty(cFor) .and. !Empty(aSuss[nY][11]) ,cFor==aSuss[nY][11],.T.)   .And. IIf(!Empty(cLojFor) .and. !Empty(aSuss[nY][12]) ,cLojFor==aSuss[nY][12],.T.)  
				
				If lPrimaVez .And. SFE->(MsSeek(xFilial("SFE")+cFor+cLojFor))
					aAreaSFE:= SFE->(GetArea())
					cChaveSFE := SFE->FE_FILIAL+cFor+cLojFor
					If nCondAgr == 1
						While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
							If Alltrim(aSuss[nY][8])=="4" .and. (!(SFE->FE_TIPO $"U|S") .Or. !Empty(SFE->FE_DTESTOR))
								SFE->(dbSkip())
								Loop
							ElseIf Alltrim(aSuss[nY][8])=="1" .And. (!(SFE->FE_TIPO $"U|S") .Or. !Empty(SFE->FE_DTESTOR))
								SFE->(dbSkip())
								Loop
							EndIf
							
							If  Alltrim(SFE->FE_CONCEPT) $ "1|4" .and. Alltrim(SFE->FE_TIPO)=="S" 
						
								nTBasAcS += SFE->FE_VALBASE	
								nTotVlvACs+= SFE->FE_VALBASE	
															
							Endif
							
							SFE->(dbSkip())
						EndDo
					ElseIf nCondAgr == 2
						While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE
							If Alltrim(aSuss[nY][8])=="4" .and. (!(SFE->FE_TIPO $"U|S") .Or. !Empty(SFE->FE_DTESTOR))
								SFE->(dbSkip())
								Loop
							ElseIf Alltrim(aSuss[nY][8])=="1" .And. (!(SFE->FE_TIPO $"U|S") .Or. !Empty(SFE->FE_DTESTOR))
								SFE->(dbSkip())
								Loop
							EndIf
							If  Alltrim(SFE->FE_CONCEPT) $ "1|4" .and. Alltrim(SFE->FE_TIPO)=="S" 
						
								nTBasAcS += SFE->FE_VALBASE	
								nTotVlvACs+= SFE->FE_VALBASE	
															
							Endif
							SFE->(dbSkip())
						EndDo
					Else
						While !SFE->(Eof())
							If Alltrim(aSuss[nY][8])=="4" .and. (!(SFE->FE_TIPO $"U|S") .Or. !Empty(SFE->FE_DTESTOR))
								SFE->(dbSkip())
								Loop
							ElseIf Alltrim(aSuss[nY][8])=="1" .And. (!(SFE->FE_TIPO $"U|S") .Or. !Empty(SFE->FE_DTESTOR))
								SFE->(dbSkip())
								Loop
							EndIf
							If  Alltrim(SFE->FE_CONCEPT) $ "1|4" .and. Alltrim(SFE->FE_TIPO)=="S" 
						
								nTBasAcS += SFE->FE_VALBASE	
								nTotVlvACs+= SFE->FE_VALBASE	
															
							Endif
							SFE->(dbSkip())
						EndDo
					Endif	
					lPrimaVez :=.F.
					SFE->(RestArea(aAreaSFE))
				EndIf
				nTotOP+= aSuss[nY][3]
			EndIf	
			IF !lTpCalSus
				lTpCalSus := IIF(aSuss[nY][9] == "1",.T.,.F.)	
			EndIF   
		Next nY

		
		//Acumula Base Conceito 4		
				   
		If (nTBasAcS + nTotOP) >= nLimiteSUSS   .and.  nTBasAcS <  nLimiteSUSS
			For nX := 1 to Len(aSe2)  
				 For nZ := 1 To Len(aSe2[nX,1])
				 	If (aSe2[nX,1,nZ,_TIPO] $ MVPAGANT + "/"+ MV_CPNEG) .And. Len(aSe2[nX,1,nZ,_RETSUSS]) > 0 .And. Alltrim(aSe2[nX,1,nZ,_RETSUSS][1][8]) == '4';
				 		.and. aSe2[nX,1,nZ,_FORNECE]== cFor .and. IIf(!Empty(cLojFor) .and. !Empty(aSe2[nX,1,nZ,_LOJA]) ,aSe2[nX,1,nZ,_LOJA]  ==cLojFor,.T.)

						For nY:= 1 To Len(aSuss)
					 		If aSuss[nY][6] > 0
					 			nTotSuss += aSuss[nY][6]	   
					 		EndIf
					   Next nY    
						If nTotSuss =0
							aSe2[nX,1,nZ,_RETSUSS][1][6]:=0
						EndIf
				 	EndIf
				 	If  nTBasAcS >0 .and. Len(aSe2[nX,1,nZ,_RETSUSS]) > 0
				 		If (aSe2[nX,1,nZ,_RETSUSS][1][3] - aSe2[nX,1,nZ,_RETSUSS][1][6]  ) >  nTBasAcS
				 			aSe2[nX,1,nZ,_RETSUSS][1][6] := aSe2[nX,1,nZ,_RETSUSS][1][6]  + (nTBasAcS * (aSe2[nX,1,nZ,_RETSUSS][1][7] /100) )
							nTBasAcS:=0
						Else
							If nZ <> Len(aSe2[nX,1])
								nVlrprop:= nTBasAcS -  aSe2[nX,1,nZ,_RETSUSS][1][3]
							Else
								nVlrprop:= nTBasAcS
							EndIf
							aSe2[nX,1,nZ,_RETSUSS][1][6] := aSe2[nX,1,nZ,_RETSUSS][1][6]  + (nVlrprop* (aSe2[nX,1,nZ,_RETSUSS][1][7] /100) )
							nTBasAcS-=nVlrprop				 			
				 	    EndIf
				 	EndIf
				 NExt nZ
			Next nX
		ElseIf  nTBasAcS <  nLimiteSUSS
			For nX := 1 to Len(aSe2)  
				 For nZ := 1 To Len(aSe2[nX,1])
				  	nPosSUSS := ascan(aSuss,{|x| x[11] == cFor})
					If Len(aSe2[nX,1,nZ,_RETSUSS]) > 0 .And. (Alltrim(aSe2[nX,1,nZ,_RETSUSS][1][8]) == '1' .or. Alltrim(aSe2[nX,1,nZ,_RETSUSS][1][8]) == '4')	.and. IIf(!Empty(cFor) .and. !Empty(aSe2[nX,1,nZ,_FORNECE]) ,cFor==aSe2[nX,1,nZ,_FORNECE],.T.) .and. IIf(!Empty(cLojFor) .and. !Empty(aSe2[nX,1,nZ,_LOJA]) ,aSe2[nX,1,nZ,_LOJA]  ==cLojFor,.T.) .and. Alltrim(aSe2[nX,1,nZ,_RETSUSS][1][14]) <> 'NCP'
						aSe2[nX,1,nZ,_RETSUSS][1][6]:=0  
						aSe2[nX,1,nZ,_RETSUSS][1][4]:=0    
					EndIf						
				 Next nZ
			Next nX
		EndIf
		
	Next nI
	IF !lOPRotAut .and. lTpCalSus .and. cPaisLoc == "ARG"
		FWAlertInfo(STR0448, "TIPCALCSUS") // De acuerdo a los cambios presentados en la RG (AFIP) 1784/2004 de Base Imponible para la Retenci๓n de SUSS, la opci๓n FF_TPCALC=1 deja de funcionar y no calcularแ el SUSS, por lo que recomendamos evaluar el cambio en la configuraci๓n correspondiente
	EndIF
EndIF
// Verifica a aplicacao de retencao de ingresos brutos, sobre o total dos pagamentos efetuados.
If cPaisLoc == "ARG"
   For nX := 1 to Len(aSe2)
	  lNewOp := .T.
	  For nZ := 1 To Len(aSe2[nX,1])
		If Len(aSe2[nX,1,nZ,_RETIB]) > 0
			For nA := 1 To Len(aSe2[nX,1,nZ,_RETIB])
				If lNewOp
					AAdd(aValZona,{})
					AAdd(aValZona[nX],{	aSe2[nX,1,nZ,_RETIB,nA,09],; //Zona Fiscal
					aSe2[nX,1,nZ,_RETIB,nA,03],; //Base da Retencao
					aSe2[nX,1,nZ,_RETIB,nA,11],; //CFO COMPRA
					aSe2[nX,1,nZ,_RETIB,nA,12]}) //CFO VENDA

					lNewOp := .F.
				Else
					If !Empty(aValZona[nX])
						nPosZona := Ascan(aValZona[nX],{|x| x[1]==aSe2[nX,1,nZ,_RETIB,nA,9] .And. x[3]==aSe2[nX,1,nZ,_RETIB,nA,11] .And. x[4]==aSe2[nX,1,nZ,_RETIB,nA,12]})
					Else
						nPosZona := 0
					EndIf
					If nPosZona == 0
						AAdd(aValZona[nX],{	aSe2[nX,1,nZ,_RETIB,nA,09],; //Zona Fiscal
						aSe2[nX,1,nZ,_RETIB,nA,03],; //Base da Retencao
						aSe2[nX,1,nZ,_RETIB,nA,11],; //CFO COMPRA
						aSe2[nX,1,nZ,_RETIB,nA,12],; //CFO VENDA
						aSe2[nX,1,nZ,_RETIB,nA,26]})// minimo ret
					Else
						aValZona[nX][nPosZona][2] += aSe2[nX,1,nZ,_RETIB,nA,3]
					Endif
				EndIf
			Next nA
		Else
			If lNewOp
				AAdd(aValZona,{})
				nPosZona := 0
				lNewOP   := .F.
			Else
				If !Empty(aValZona[nX])
					nPosZona := Ascan(aValZona[nX],{|x| x[1] == StrZero(nX,2)})
				Else
					AAdd(aValZona,{})
					nPosZona := 0
				EndIf
			EndIf

			If nPosZona == 0
				AAdd(aValZona[nX],{StrZero(nX,2),0,"",""})
			EndIf

		EndIf
	Next nZ

	  If Len(aValZona) > 0
		For nY = 1 To Len(aValZona[nX])
			If aValZona[nX][nY][1] == "CR"
				nVLCalcRet :=0
				nValTotBas:=0
				SFE->(DbSetOrder(4))
				If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA))
					cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA
					While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
						If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
							!(SFE->FE_TIPO $"B")
							SFE->(dbSkip())
							Loop
						EndIf
							nVLCalcRet += (SFE->FE_VALBASE * (SFE->FE_ALIQ/100))- SFE->FE_RETENC
							nValTotBas:=nValTotBas+ SFE->FE_VALBASE
							SFE->(dbSkip())
					EndDo
				EndIf
			EndIf

		Next nY
	  EndIf
   Next nX
EndIf
//Entre Rios
// Total Base IB por Fornecedor
aValForn:={}
lPrima:= .T.
For nX := 1 to Len(aSe2)
 For nZ := 1 To Len(aSe2[nX,1])
		If Len(aSe2[nX,1,nZ,_RETIB]) > 0
			For nA := 1 To Len(aSe2[nX,1,nZ,_RETIB])
				If  aSe2[nX,1,nZ,_RETIB,nA,09]=="ER" .and.  aSe2[nX,1,nZ,_RETIB,nA,03] >0				
					If !lPrima
						nPos := Ascan(aValForn,{|x| x[1]==aSe2[nX,1,nZ,1] .And. x[2]==aSe2[nX,1,nZ,2]})
					EndIf 
					If lPrima .or. npos== 0
						nVLCalcRet :=0
						nVlTotBas:=0
						If SFE->(MsSeek(xFilial("SFE")+aSe2[nX,1,nZ,1]+aSe2[nX,1,nZ,2]))
							cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA
							While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA								
								If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or. !(SFE->FE_TIPO $"B")
									SFE->(dbSkip())
									Loop
								EndIf
								nVLCalcRet += (SFE->FE_VALBASE * (SFE->FE_ALIQ/100))- SFE->FE_RETENC
								nVlTotBas:=nVlTotBas+ SFE->FE_VALBASE
								SFE->(dbSkip())
							EndDo
						EndIf						
						AAdd(aValForn,;						
						{aSe2[nX,1,nZ,1],; //Cod.For
						aSe2[nX,1,nZ,2],; //Loja Forn
						aSe2[nX,1,nZ,_RETIB,nA,3]+nVlTotBas,;// Valor da Base ret por documento
						aSe2[nX,1,nZ,_RETIB,nA,5]+nVLCalcRet})// Valor Ret Ac						
						lPrima := .F.
					Else
						aValForn[npos][3]:=aValForn[npos][3]+aSe2[nX,1,nZ,_RETIB,nA,3]
						aValForn[npos][4]:=aValForn[npos][4]+aSe2[nX,1,nZ,_RETIB,nA,5]
					EndIf
				EndIf
			Next(nA)
		EndIf
	Next(nZ)
Next(nX)
If Len(aValForn)>0
	For nX := 1 to Len(aSe2)
	 	For nZ := 1 To Len(aSe2[nX,1])
			If Len(aSe2[nX,1,nZ,_RETIB]) > 0
				For nA := 1 To Len(aSe2[nX,1,nZ,_RETIB])
					If  aSe2[nX,1,nZ,_RETIB,nA,09]=="ER" .and.  aSe2[nX,1,nZ,_RETIB,nA,03] >0
							nPos := Ascan(aValForn,{|x| x[1]==aSe2[nX,1,nZ,1] .And. x[2]==aSe2[nX,1,nZ,2]})							
						If nPos>0 .and.  aValForn[npos][3] < aSe2[nX,1,nZ,_RETIB,nA,26] 
							aSe2[nX,1,nZ,_RETIB,nA,5]:=0
							aSe2[nX,1,nZ,_RETIB,nA,6]:=0
						EndIf
					Endif
				Next(nA)
			EndIf
		Next(nZ)
	Next(nX)				
EndIf

If cPaisLoc == "ARG" .And. IIf (Len(aSE2)== 0,.F.,Len(aSE2[1][1][1][_RETIB]) > 0) 
	If aSE2[1][1][1][_RETIB][1][22] == 2
		For nIB := 1 To Len(aSE2[1][1])  
		If Len(aSE2[1][1][nIB] ) >= _RETIB .and.  len(aSE2[1][1][nIB][_RETIB])>=1 .and. Len(aSE2[1][1][nIB][_RETIB][1]) >= 21
			If aSE2[1][1][nIB][_RETIB][1][21] <> 0 
	 			nAcumul += aSE2[1][1][nIB][15][1][5]
	 		Endif		
	 	EndIf				
		Next nIB

			If Len(aSE2[1][1]) >= 1 .and.  len(aSE2[1][1][1])>= _RETIB .and. Len(aSE2[1][1][1][_RETIB]) >= 1 ;
					.and. Len(aSE2[1][1][1][_RETIB][1])>=21
				If nAcumul < aSE2[1][1][1][_RETIB][1][21]
					For nIC := 1 To Len (aSE2[1][1])
					If Len(aSE2[1][1][nIC] ) >=  _RETIB .and. Len(aSE2[1][1][nIC][_RETIB])>=1 .and.;
						Len(aSE2[1][1][nIC][_RETIB][1])>=5
						aSE2[1][1][nIC][_RETIB][1][5] := 0
					Endif
				Next nIC
			Endif
		Endif	
	Endif
Endif

If Len(aSLIMIN) > 0
	For nM	:= 1 To Len (aSLIMIN)
		If aSLIMIN[nM][3] >= F850Mins(aSE2[1], _RETISI, aSLIMIN, nM, .F.)
			F850Mins(@aSE2[1], _RETISI, aSLIMIN, nM, .T.)
		EndIf
	Next(nM)
EndIf

If lNaoMarca .And. lFinr995 
	lRetPA := lRetPAOR
EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850Tela บAutor  ณBruno Sobieski      บ Data ณ  18.10.00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a tela como os detalhes das ordens de pago calculadas บฑฑ
ฑฑบ          ณ para o usuario confirmar ou modificar os dados gerados.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850Tela(aSE2,nFlagMOD,nCtrlMOD,aCtrChEQU,lRoadMap115)
//Variaveis da tela principal
Local oOk			:= LoadBitMap(GetResources(), "LBOK")
Local oNo			:= LoadBitMap(GetResources(), "LBNO")
Local oNever		:= LoadBitMap(GetResources(), "DISABLE")
Local oPreco		:= LoadBitMap(GetResources(), "PRECO")

//Variaveis para valores temporarios
Local nA,nC,nP

//Buttons
Local aButtons	  := {}

//Variaveis para posicionamento na tela.
Local nHoriz		:= 0
Local y				:= 765
Local x				:= 430
Local x1			:= 050
Local y1			:= 004
Local x2			:= 358
Local y2			:= 120
Local nPos1		:= 0
Local nPos2		:= 0
Local nPos3		:= 0
Local	nIVSUS	:= 0
Local nAux			:= 0
Local lLimpaFor	:= .F.
Local 	lExisPA	:= .F.
Local 	lReIvSU	:= (cPaisLoc=="ARG" .and. GetNewPar("MV_RETIVA","N") == "S" .and. GetNewPar("MV_RETSUSS","N") == "S")
Local nXPagar	    :=	0
Local cModelo     	:= "1"
Local cCliente    	:= CriaVar("E1_CLIENTE")
Local cLoja       	:= CriaVar("E1_LOJA")
Local aTipoDocto 	:= {}
Local cTipoDocto 	:= ""
Local oDebitar
Local lDebitar    	:= .F.
Local nPercDesc   := 0.00
Local nValorDesc  := 0.00
Local nValorPago	:= 0.00
Local nX         	:= 0
Local nY          	:= 0
Local aCampos     	:= {}
Local aIVA 		:= {}
Local aGan 		:= {}
Local aIB			:= {}
Local aSUSS 		:= {}
Local aTits       	:= {}
Local nPos        	:= 1
Local oDlg,oFntMoeda
Local lConfirmo	:= .F.
Local oFolderPg,oRetGan,oRetISI,oRetIB,oRetIVA,oRetIric,oRetIr,oPagar,oRetSUSS,oRetSLI,oRetIRC,oRetRIE,oRetIGV
Local oFolder
Local aCpos		:= {}
Local nJuros,nDesc,nMulta
Local aSE2Tmp	    := {}
Local nFolder     	:= 1
Local nHdl			:= 0
Local bZeraRets	:= {|| F850ZeraRet(@nRetIva,@nRetGan,@nRetIB,@nRetIric,@nRetSUSS,@nRetSLI,@nRetIr,@nRetIrc,@nRetIGV,@nRetIR4)}
Local aDescontos	:= {} 	//Variavel para guardar os descontos por item se o campo E2_DESCONT nao estiver em uso. O valor e necessario PAra calculo de retencoes. BRuno
Local nSalPos 		:= 0
Local nPosVlr     	:= 0
Local aRateioGan  := {}
Local nRetRIE 		:= 0  	//ANGOLA
Local lVisualiza  := .F.
Local aCols		:= {}
Local nCntPagos   := 0
Local nLenACol		:= 0
Local aCposSE2		:= {}
Local aCpos3os		:= {}
Local aCposPg		:= {}
Local cDocPg		:= ""
Local aGet			:= {}
Local aGetPg		:= {}
Local aAreaSA2		:= {}

Local oSayPorc
Local oSayVlDesc
Local oSayVlPg
Local oSayNat
Local oSaySld
Local oSayTerc
Local oSayProp
Local oSayDesc
Local nOldIVA 		:= 0
Local nValPag		:= 0
DEFAULT lRoadMap115 	:= .F.

PRIVATE lGetVencto  			:= .F.
PRIVATE oValBrut,nPorDesc	:=	0
PRIVATE oValLiq,oPorDesc ,oValDesc
PRIVATE oNatureza
PRIVATE cNatureza		:= Iif(cPaisLoc <> "BRA",Criavar("EK_NATUREZ"),Criavar("ED_CODIGO"))
PRIVATE lRetenc	   	:= .T.
PRIVATE aHeader3os	:= {}
PRIVATE aCols3os		:= {}
PRIVATE aHeaderSE2	:= {}
PRIVATE aColsSE2    	:= {}
PRIVATE aHeaderPG		:= {}
PRIVATE aColsPG		:= {}
PRIVATE aColsPgMs		:= {}
PRIVATE aPagoMass		:= {}
PRIVATE aPagar	  		:= {}
Private aVlPA			:= {0,0,0,0}
PRIVATE bRecalc	  	:= {||}
PRIVATE bAtuOP			:= {||}
PRIVATE lF4 			:= .F. //ativar ou nao a tecla F4 para a seleca do fornecedor quando as OP's estiverem agrupadas
PRIVATE nNulo			:= 0
PRIVATE nOlbxAtAnt	:= 0
PRIVATE aTipoTerc		:= {}
PRIVATE aDoc3osUtil	:= {}
PRIVATE aSaldos		:= {}
PRIVATE oGetDad0
PRIVATE oGetDad1
PRIVATE oGetDad2
PRIVATE oGetDad3
PRIVATE bFnReLd		:= {||}

/*_*/
PRIVATE nRetIva		:= 0
PRIVATE nRetGan		:= 0
PRIVATE nRetISI		:= 0
PRIVATE nTotNF			:= 0
PRIVATE nRetib			:= 0
PRIVATE nRetIric		:= 0
PRIVATE nRetIr			:= 0
PRIVATE nRetIRC		:= 0
PRIVATE nRetSUSS		:= 0
PRIVATE nRetSLI		:= 0
PRIVATE nRetIGV		:= 0
PRIVATE nRetIR4		:= 0
PRIVATE nRetAbt		:= 0
PRIVATE nTotNcc		:= 0
PRIVATE nValBrut		:= 0
PRIVATE nValLiq		:= 0
PRIVATE nValDesc		:= 0
PRIVATE nValDesp		:= 0
PRIVATE nValPagar       := 0 
/*_*/
PRIVATE nSaldoPgOP	:= 0
PRIVATE nTotDocTerc	:= 0
PRIVATE nTotDocProp	:= 0
PRIVATE oSaldoPgOP
PRIVATE oTotDocTerc
PRIVATE oTotDocProp

PRIVATE nUnico 	   	:= 0
PRIVATE nMultiplo 	:= 0

PRIVATE aUnico			:= {OemToAnsi(STR0243) ,OemToAnsi(STR0239),OemToAnsi(STR0240),OemToAnsi(STR0241)}
PRIVATE aMultiplo		:= {OemToAnsi(STR0243),OemToAnsi(STR0244)}
PRIVATE aVlrEdit       := Array(Len(aSe2[1][1]),.F.)

/*
Array que cont้m os talonแrios, caso o informado no Pago Massivo
nใo contenha a quantidade de cheques necessแria.
*/
PRIVATE aTaloesMs 	:= {}
PRIVATE oDConcep

aSaldos	:=	Array(MoedFin()+1)

aVlPA[_PA_MOEATU] := 1

nPagar := 4

If nCondAgr>1  //Adicionar botao para a relacao de fornecedores
	Aadd(aButtons,{'POSCLI' ,{|| F850FORN(@aSE2) },OemToAnsi(trim(STR0054))+" (F4)",OemToAnsi(STR0054)}) //"Proveedor"
Endif

Aadd(aButtons,{'RECALC' ,{|| F850SmlCtb(@aSE2)},STR0259,STR0259}) //Simula็ใo Contแbil

aAdd(aButtons, {'RECALC',{|| F850PgMas(@aSE2)},STR0354 ,STR0354 }) //Pago Massivo
If cPaisLoc == "RUS"
	aAdd(aButtons,{"RECALC",{|| RU06S850("AddTit") },STR0413})
EndIf
/*
Verifica as formas de pagamento*/
aDebMed := {}
aDebInm := {}
aTipoTerc := {}
aTipoDocto := {}
aadd(aTipoDocto,STR0438)
cTipoDocto  := aTipoDocto[1]
cDocPg := ""
aFormasPgto := Fin025Tipo()
For nC := 1 To Len(aFormasPgto)
	If aFormasPgto[nC,5] $ "13" .And. aFormasPgto[nC,7]		//documentos de terceiros
		Aadd(aTipoTerc,Aclone(aFormasPgtop[nC]))
		Aadd(aTipoDocto,aFormasPgto[nC,3])
	Endif
	If aFormasPgto[nC,5] $ "23"
		If aFormasPgto[nC,4] == "1"		//gera movimento bancario
			Aadd(aDebInm,aFormasPgto[nC,1])
		Else
			Aadd(aDebMed,aFormasPgto[nC,1])
		Endif
		If !Empty(cDocPg)
			cDocPg += ";"
		Endif
		cDocPg += (AllTrim(aFormasPgto[nC,1]) + "=" + Alltrim(aFormasPgto[nC,3]))
	Endif
Next
If Len(aDebMed) ==	0
	aDebMed	:=	{MVCHEQUE}
Endif
cDebMed	:=	aDebMed[1]
If Len(aDebInm) ==	0
	If Ascan(aDebmed,"TF") = 0
		AAdd(aDebInm,"TF")
	EndIf
	If Ascan(aDebMed,"EF") = 0
		AAdd(aDebInm,"EF")
	EndIf
	If Len(aDebInm) ==	0
		AAdd(aDebInm,"")
	EndIf
Endif
cDebInm	:=	aDebInm[1] + Iif(Len(aDebInm) > 1,"|" + aDebInm[2],"")

// Fun็ใo que monta o array aPagos a partir do array aSE2.
F850Ordens(aSE2)


If cPaisLoc ==	"ARG"
	aSizes	:=	{5	,30                ,25				   ,90				  ,60	  								,20,				,60				 ,60				,60					,60				   ,60			       ,60                ,60				,60                     ,30}
	aFields	:=	{" ",OemToAnsi(STR0054),OemToAnsi(STR0055),OemToAnsi(STR0056),OemToAnsi(RetTitle("A2_ENDOSSO")),OemToAnsi(STR0057),OemToAnsi(STR0058),OemToAnsi(STR0062),OemToAnsi(STR0059),OemToAnsi(STR0060),OemToAnsi(STR0061),OemToAnsi(STR0150),OemToAnsi(STR0158),OemToAnsi("Ret. Municipal"),OemToAnsi(STR0202)}
ElseIf cPaisLoc ==	"ANG"
	aSizes	:=	{5	 ,30					  ,25						,90					 ,60		    ,60				,60 ,60			}
	aFields	:=	{" ",OemToAnsi(STR0054),OemToAnsi(STR0055),OemToAnsi(STR0056),OemToAnsi(STR0057),OemToAnsi(STR0058),OemToAnsi(STR0192),OemToAnsi(STR0062)}
ElseIf cPaisLoc == "EQU"
	aSizes	:=	{5	 ,30			   ,25				  ,90				 ,60		        ,60	                          ,60			           ,60                     ,60                             ,60                }
	aFields	:=	{" ",OemToAnsi(STR0054),OemToAnsi(STR0055),OemToAnsi(STR0056),OemToAnsi(STR0057),OemToAnsi(STR0241),OemToAnsi(STR0242),OemToAnsi(STR0243),OemToAnsi(STR0244),OemToAnsi(STR0062)}
ElseIf cPaisLoc $ "DOM|COS"
	aSizes	:=	{5	 	,30					,25					,90					 	,60		    		,60	   				,60					,60					}
	aFields	:=	{" "	,OemToAnsi(STR0054)	,OemToAnsi(STR0055)	,OemToAnsi(STR0056)		,OemToAnsi(STR0057)	,OemToAnsi(STR0058)	,OemToAnsi(STR0098)	,OemToAnsi(STR0062)	}
Else
	aSizes	:=	{5	 ,30					  ,25						,90					 ,60		    ,60	   ,60			}
	aFields	:=	{" ",OemToAnsi(STR0054),OemToAnsi(STR0055),OemToAnsi(STR0056),OemToAnsi(STR0057),OemToAnsi(STR0058),OemToAnsi(STR0062)}
Endif

oBrw	:= GetMbrowse()
nHoriz := oMainWnd:nClientWidth
nOpc	:= 0

If Type("nHoriz")=="N".And.nHoriz < 800
	y 	:= 615
	x	:= 290
	x1	:= 030
	y1	:= 004
	x2	:= 290
	y2	:= 090
Endif

nPos1 := (x2-y1 + 09)
nPos2 := (x2-y1 + 09) * 0.20
nPos3 := (x2-y1 + 09) * 0.80

If ExistBlock("A085DEFS")
	ExecBlock("A085DEFS",.F.,.F.,"1")
Endif

If lF4
   SetKey(VK_F4,{||F850FORN(@aSE2)})
Endif

aSize:= FwGetDialogsize(oMainWnd)
aSize[3] -= 30
aSize[4] -= 30

bAtuOP := {|| F850AtuOP(@aSE2)}

If cPaisLoc == "ARG"
	bRecalc	:=	{ || F850Recal(@aSE2,@aRateioGan),F850AtuOP(@aSE2)}
ElseIf cPaisLoc $ "ANG"
	bRecalc	:=	{ || 	aSE2Tmp	:=	F850Recal(nPos,@aSE2,nPosJuros,nPosDesc,@nRetIva,@oRetIva,@nRetIB,@oRetIB,;
	@nRetGan,@oRetGan,@nRetISI,@oRetISI,aDescontos,@nRetIric,@oRetIric,;
	@nRetSUSS,@oRetSUSS,@nRetSLI,@oRetSLI,@nValBrut,@oValBrut,,,,/*@nRetIr*/,/*@oRetIr*/,/*@nRetIrc*/,/*@oRetIrc*/,/*nValDesp*/,nRetRIE,oRetRIE)}
ElseIf cPaisLoc $ "EQU"
	bRecalc	:=	{ || 	aSE2Tmp	:=	F850Recal(nPos,@aSE2,nPosJuros,nPosDesc,@nRetIva,@oRetIva,@nRetIB,@oRetIB,;
	@nRetGan,@oRetGan,@nRetISI,@oRetISI,aDescontos,@nRetIric,@oRetIric,;
	@nRetSUSS,@oRetSUSS,@nRetSLI,@oRetSLI,@nValBrut,@oValBrut,,,,;
	/*@nRetIr*/,/*@oRetIr*/,/*@nRetIrc*/,/*@oRetIrc*/,/*nValDesp*/,nRetRIE,oRetRIE,@nRetIGV,oRetIGV,@nRetIR4)}
Else
	bRecalc := {|| F850AtuOP(@aSE2)}
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Abrir a tabela de Talonario e Historico de Cheques.     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("FRE")
dbSelectArea("FRF")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializar o aHeader e o aCols do folder 1.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aHeaderSE2 := {}
aGet       := {}
dbSelectArea("SX3")
//Se o usuario tem acesso ao campo e esta em uso incluir o campo em primeiro lugar
//para permitir mudar o valor por pagar. Bruno
dbSetOrder(2)
MsSeek("E2_PAGAR")
If Found() .And. X3Uso(x3_usado)  .And. cNivel >= X3_NIVEL
	AADD(aHeaderSE2,{TRIM(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldP()",X3_USADO, X3_TIPO, , X3_CONTEXT } )
	AADD(aGet,X3_CAMPO)

	AADD(aHeaderSE2,{ OemToAnsi(STR0174),"NVLMDINF",X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VlM()",X3_USADO, X3_TIPO, , X3_CONTEXT } )
	AADD(aGet,"NVLMDINF")
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPonto de entrada para customizar as colunas na opcao Modificar OP    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock("F085HEAD")
	aCampos	:=	ExecBLock("F085HEAD",.F.,.F.)
Endif
//Carregar os demais campos no aHeader
aCposSE2 := {"E2_MULTA","E2_JUROS","E2_DESCONT","E2_FORNECE","E2_LOJA","E2_TIPO","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_VENCTO","E2_VALOR","E2_SALDO","E2_MOEDA"}

If cPaisLoc == "RUS"
	aadd( aCposSE2, "E2_BASIMP1")
	aadd( aCposSE2, "E2_ALQIMP1")
	aadd( aCposSE2, "E2_VALIMP1")
	aadd( aCposSE2, "E2_MDCONTR")
Endif

aGet := {"E2_PAGAR","NVLMDINF","E2_JUROS","E2_MULTA","E2_DESCONT"}
For nC := 1 To Len(aCposSE2)
	If SX3->(MsSeek(PadR(aCposSE2[nC],Len(SX3->X3_CAMPO))))
		aAdd(aHeaderSE2,{ TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT })
	Endif
Next
For nC := 1 To Len(aCampos)
	If SX3->(MsSeek(PadR(aCampos[nC],Len(SX3->X3_CAMPO))))
		aAdd(aHeaderSE2,{ TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,X3_TAMANHO, X3_DECIMAL, X3_VALID,X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT })
	Endif
Next

If cPaisLoc == "ARG"
	For nP	:=	1	To	Len(aGan)
		nRetGan	+=	Round(xMoeda(aGan[nP][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Next nP
Endif

nValLiq	:= (nValBrut - nTotNcc)-(nValDesc+nRetGan+nRetIb+nRetIVA+nRetIric+nRetSUSS+nRetSLI+nRetIr+nRetIRC+nRetIGV+nRetIR4) + nValDesp

If 	cPaisLoc == "EQU"
	For nP	:=	1	To	Len(aTits)
		nValBrut	:= aTits[1][3]
	Next
EndIf
nPorDesc   := aPagos[nPos][H_PORDESC]

nUsado := Len(aHeaderSE2)
aColsSE2 := {}

SA2->(DbSetOrder(1))
SA2->(MsSeek(xFilial()+aPagos[nPos][H_FORNECE]+aPagos[nPos][H_LOJA]))

If !RateioCond(@aRateioGan)
	aSE2	:=	{}
	Return .F.
Endif
aHeaderPg := {}
aColsPg := {}
aCposPg := {"EK_TIPO","EK_BANCO","EK_AGENCIA","EK_CONTA","EK_MOEDA","EK_TALAO","FRE_TIPO","EK_PREFIXO","EK_NUM","EK_PARCELA","EK_EMISSAO","EK_VENCTO","EK_MOEDA","NPORVLRPG","EK_VALOR"}
aGetPg := {"EK_TIPO","EK_BANCO","EK_AGENCIA","EK_MOEDA","EK_TALAO","EK_PREFIXO","EK_NUM","EK_PARCELA","EK_EMISSAO","EK_VENCTO","NPORVLRPG","EK_VALOR"}
nAux := 0
DbSelectArea("SX3")
DbSetOrder(2)
For nC := 1 To Len(aCposPg)
	If SX3->(MsSeek(PadR(aCposPg[nC],Len(SX3->X3_CAMPO))))
		Do Case
			Case aCposPg[nC] == "EK_TIPO"
				Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldTipo()",X3_USADO,X3_TIPO,"FJSP",X3_ARQUIVO,"","","","","","",.F.})
			Case aCposPg[nC] == "EK_TALAO"
				If cPaisLoc =="ARG" .AND. SXB->(MsSeek(PADR("F850AR", Len(SXB->XB_ALIAS))))
					Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldTalao()",X3_USADO,X3_TIPO,"F850AR",X3_ARQUIVO,"","","","","","",.F.})
				Else
					Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldTalao()",X3_USADO,X3_TIPO,"FRE850",X3_ARQUIVO,"","","","","","",.F.})
				EndIF
			Case aCposPg[nC] == "FRE_TIPO"
				Aadd(aHeaderPg,{Alltrim(X3Descric()),X3_CAMPO,"",Len(SX3->X3_DESCRIC),0,"F850Vlds()",X3_USADO,"C","",X3_ARQUIVO,"","","","","","",.F.})
			Case aCposPg[nC] == "EK_VENCTO"
				Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldVct()",X3_USADO,X3_TIPO,"",X3_ARQUIVO,"","","","","","",.F.})
			Case aCposPg[nC] == "EK_VALOR"
				Aadd(aHeaderPg,{STR0439,"NPORVLRPG","@E 999.99",6,2,"Positivo().And.F850VlPg()",X3_USADO,"N","",X3_ARQUIVO,"","","","","","",.F.})
				Aadd(aHeaderPg,{Alltrim(STR0174),X3_CAMPO   ,X3_PICTURE ,X3_TAMANHO,X3_DECIMAL,"Positivo().And.F850VlPg()",X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO})
			Case aCposPg[nC] == "EK_MOEDA"
				nAux++
				If nAux == 1
					Aadd(aHeaderPg,{Alltrim(STR0307),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850Vlds()",X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO}) //"Moeda banco"
				Else
					Aadd(aHeaderPg,{AllTrim(X3TITULO()),"MOEDAPGTO",X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850Vlds()",X3_USADO,"N","",X3_ARQUIVO,,"nMoedaCor"})
				Endif
			OtherWise
				Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850Vlds()",X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO})
		EndCase
	Endif
Next
/*
tabela para documentos de terceiros */
aHeader3os := {}
aCols3os := {}
aCpos3os := {"E1_TIPO","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_EMISSAO","E1_VENCREA","E1_SALDO","E1_MOEDA","E1_CLIENTE","E1_LOJA","E1_NOMCLI"}

//--------------------------------------------------
//--- Requisitos Entidades Bancarias - Julho de 2012
//--------------------------------------------------
  If cPaisLoc == "ARG"

     Aadd( aCpos3os, "E1_BCOCHQ" )
     Aadd( aCpos3os, "E1_AGECHQ" )
     Aadd( aCpos3os, "E1_CTACHQ" )
     Aadd( aCpos3os, "E1_POSTAL" )

  EndIf

DbSelectArea("SX3")
DbSetOrder(2)
For nC := 1 To Len(aCpos3os)
	If SX3->(MsSeek(PadR(aCpos3os[nC],Len(SX3->X3_CAMPO))))
		Aadd(aHeader3os,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"AllwaysTrue()",X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO})
	Endif
	If aCpos3os[nC] == "E1_SALDO"
		nPosVlrE1 := nC
	ElseIf aCpos3os[nC] == "E1_MOEDA"
		nPosMoedaE1 := nC
	Endif
Next

If Len(aHeaderRet) == 0 .and. cPaisLoc == "ARG" .and. CCO->(ColumnPos("CCO_TPCALR"))> 0 
	aCposRet := {"FE_TIPO","FE_EST","FE_CONCEPT","CCO_TPCALR","FE_VALBASE","FE_DESGR","FE_ALIQ","FE_RETENC","FE_NROCERT"}
	If CCO->(ColumnPos("CCO_TPCALR"))> 0 .and. SFE->(ColumnPos("FE_TPCALR"))> 0
		aGetRet  := {"FE_VALBASE","FE_ALIQ","FE_DESGR"}
	EndIf
	Fn850GtCpo(aCposRet,@aHeaderRet)
EndIf
aColsRet	:= {}

/*_*/
nUnico := aPagos[1,H_UNICOCHQ]
nMultiplo := aPagos[1,H_MULTICHQ]

DEFINE MSDIALOG oDlg FROM aSize[2],0 TO aSize[3],aSize[4] of oMainWnd PIXEL TITLE OemToAnsi(STR0063) //"Representa็ใo grแfica do Fluxo de Caixa"

	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:lLateral := .F.
	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:lProp := .T.
	oSize:Process()

	oMasterPanel := TPanel():New(oSize:GetDimension("MASTER","LININI"),;
								 oSize:GetDimension("MASTER","COLINI"),;
								,oDlg,,,,,,oSize:GetDimension("MASTER","LINFIN"),;
								oSize:GetDimension("MASTER","COLFIN"),,)
	oMasterPanel:Align := CONTROL_ALIGN_ALLCLIENT
	nLinIni := oSize:GetDimension("MASTER","LININI") * 0.5

/*--- Parte superior da OP com os dados das ordens de pago ------------------------------------------------------------------------------------------------*/
	oPnlOP := TPanel():New(0,0,"",oMasterPanel,,,,,,aSize[4],aSize[3] * 0.4,,)
	oPnlOP:Align := CONTROL_ALIGN_TOP
	oPnlOP:nHeight := aSize[3] * 0.5
	/*_*/
	oPnlOrd := TPanel():New(0,0,"",oPnlOP,,,,,,aSize[4],oPnlOP:nHeight * 0.35,.T.,.T.)
	oPnlOrd:Align := CONTROL_ALIGN_TOP
	oPnlOrd:nHeight := oPnlOP:nHeight * 0.20

	@ nLinIni + 000,006 SAY OemToAnsi(STR0064)  Size 70,08 			PIXEL OF 	oPnlOrd  	//"Ordenes de Pago     : "
	@ nLinIni + 000,070 SAY oNumOrdens Var nNumOrdens 				PIXEL OF 	oPnlOrd	COLOR CLR_BLUE//"Ordenes de Pago     : "

	@ nLinIni + 000,160 SAY OemToAnsi(STR0065)  Size 70,08 			PIXEL OF 	oPnlOrd   	//"Total a Desembolsar : "
	@ nLinIni + 000,250 SAY oValOrdens Var nValOrdens  Size 80,08 	PIXEL OF	oPnlOrd	PICTURE PesqPict("SE2","E2_PAGAR",17,nDecs) COLOR CLR_BLUE //"Ordenes de Pago     : "

	@ nLinIni + 000,316 SAY OemtoAnsi(STR0068) SIZE 50, 07 			PIXEL OF 	oPnlOrd    //"Exibir valores em : "
	@ nLinIni - 005,370 COMBOBOX oCBX VAR cMoeda ITEMS aMoeda ON CHANGE (nMoedaCor:=oCBX:nAt,nDecs:=MsDecimais(nMoedaCor),aPagosOrig:=aClone(aPagos),F850AtuVl(@oValOrdens,@nValOrdens,@aPagos,aSE2),F850Click(@aSE2,@aDescontos,,oFolder,@aPagos)) SIZE 50,50 OF oPnlOrd PIXEL

	If cPaisLoc $ "ARG/RUS"
		@ nLinIni + 000,450 SAY OemtoAnsi(STR0372) SIZE 70, 07 	PIXEL OF 	oPnlOrd //Pgto. Elet?
		@ nLinIni - 005,490 COMBOBOX oPgtoElt VAR cPgtoElt ITEMS {STR0047,STR0048} ON CHANGE F850VldElt(oPgtoElt:nAt,oFolder,aSE2) SIZE 30,50 OF oPnlOrd PIXEL
	EndIf

/* browser com as ops a serem geradas*/
	oLbx := TWBrowse():New(0,0,10,10,,aFields,aSizes,oPnlOP,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx:SetArray(aPagos)
	If cPaisLoc == "ARG"
		oLbx:bLine := { || {If(aPagos[oLbx:nAt,1]>0,oOk,If(aPagos[oLbx:nAt,1]<0,oNo,oNever)),aPagos[oLbx:nAT][2],aPagos[oLbx:nAT][3],aPagos[oLbx:nAT][4],aPagos[oLbx:nAt][H_TERC],aPagos[oLbx:nAT][5],aPagos[oLbx:nAT][6],aPagos[oLbx:nAT][7],aPagos[oLbx:nAT][8],aPagos[oLbx:nAT][9],aPagos[oLbx:nAT][10],aPagos[oLbx:nAT][11],aPagos[oLbx:nAT][12],aPagos[oLbx:nAT][13],Iif(aPagos[oLbx:nAT][14],STR0047,STR0048)}}
	ElseIf cPaisLoc == "ANG"
		oLbx:bLine 		:= { || {If(aPagos[oLbx:nAt,1]>0,oOk,If(aPagos[oLbx:nAt,1]<0,oNo,oNever)),aPagos[oLbx:nAT][2],aPagos[oLbx:nAT][3],aPagos[oLbx:nAT][4],aPagos[oLbx:nAT][5],aPagos[oLbx:nAT][6],aPagos[oLbx:nAT][H_RETRIE],aPagos[oLbx:nAT][H_TOTAL]}}
	ElseIf cPaisLoc == "EQU"
	   	oLBx:bLine 		:= { || {If(aPagos[oLBx:nAt,1]>0,oOk,If(aPagos[oLBx:nAt,1]<0,oNo,oNever)),;
   		aPagos[oLBx:nAT][H_FORNECE],;
	   	aPagos[oLBx:nAT][H_LOJA],;
	   	aPagos[oLBx:nAT][H_NOME],;
	   	TransForm(aPagos[oLBx:nAT][H_NF    ],Tm(aPagos[oLBx:nAT][H_NF    ],16,nDecs)),;
	   	TransForm(aPagos[oLBx:nAT][H_NCC_PA],Tm(aPagos[oLBx:nAT][H_NCC_PA],16,nDecs)),;
	   	TransForm(aPagos[oLBx:nAT][H_TOTRET],Tm(aPagos[oLBx:nAT][H_TOTRET],16,nDecs)),;
	   	TransForm(aPagos[oLBx:nAT][H_DESCVL],Tm(aPagos[oLBx:nAT][H_DESCVL],16,nDecs)),;
	   	TransForm(aPagos[oLBx:nAT][H_MULTAS],Tm(aPagos[oLBx:nAT][H_MULTAS],16,nDecs)),;
	   	TransForm(aPagos[oLBx:nAT][H_TOTAL ],Tm(aPagos[oLBx:nAT][H_TOTAL ],16,nDecs))}}
	ElseIf cPaisLoc $ "DOM|COS"
		oLBx:bLine 		:= { || {If(aPagos[oLBx:nAt,1]>0,oOk,If(aPagos[oLBx:nAt,1]<0,oNo,oNever)),;
								  aPagos[oLBx:nAT][H_FORNECE],;
								  aPagos[oLBx:nAT][H_LOJA],;
								  aPagos[oLBx:nAT][H_NOME],;
								  aPagos[oLBx:nAT][H_NF],;
								  aPagos[oLBx:nAT][H_NCC_PA],;
								  TransForm(aPagos[oLBx:nAT][H_TOTRET],Tm(aPagos[oLBx:nAT][H_TOTRET],16,nDecs)),;
								  aPagos[oLBx:nAT][H_TOTAL]}}
	Else
		oLbx:bLine := { || {If(aPagos[oLbx:nAt,1]>0,oOk,If(aPagos[oLbx:nAt,1]<0,oNo,oNever)),aPagos[oLbx:nAT][2],aPagos[oLbx:nAT][3],aPagos[oLbx:nAT][4],aPagos[oLbx:nAT][5],aPagos[oLbx:nAT][6],aPagos[oLbx:nAT][7]}}
	Endif
	oLbx:bLDblClick	:= { || F850DClick(oFolder) }
	oLbx:bChange := { || F850Click(@aSE2,@aDescontos,,oFolder,@aPagos) }
	oLbx:Align :=  CONTROL_ALIGN_ALLCLIENT
	oLbx:Refresh()
	/*_*/
	oPnlSep9 := TPanel():New(0,0,"",oMasterPanel,,,,,RGB(00,00,00),aSize[4],aSize[3],,)
	oPnlSep9:Align := CONTROL_ALIGN_TOP
	oPnlSep9:nHeight := 1
/*
--- Detalhe da ordem de pago ----------------------------------------------------------------------------------------------------------------------------*/
	/*Painel principal*/
	oPnlTP := TPanel():New(0,0,"",oMasterPanel,,,,,,aSize[4],aSize[3],,)
	oPnlTP:Align := CONTROL_ALIGN_TOP
	/*Painel dos dados da OP*/
	oPnlDOP := TPanel():New(0,0,"",oPnlTP,,,,,,oPnlTP:nWidth*0.07,aSize[3],,)
	oPnlDOP:Align := CONTROL_ALIGN_RIGHT
	/*Painel dos dados editaveis*/
	oPnlEdit := TPanel():New(0,0,"",oPnlDOP,,,,,,oPnlTP:nWidth,oPnlTP:nHeight*0.07,,)
	oPnlEdit:Align := CONTROL_ALIGN_TOP
	/*Painel dos totalizadores*/
	oPnlTot := TPanel():New(0,0,"",oPnlDOP,,,,,,oPnlTP:nWidth,oPnlTP:nHeight*0.06,,)
	oPnlTot:Align := CONTROL_ALIGN_TOP
	/*Painel dos tํtulos e formas de pagamento*/
	oPnlDetOP := TPanel():New(0,0,"",oPnlTP,,,,,,oPnlTP:nWidth*0.18,aSize[3],,)
	oPnlDetOP:Align := CONTROL_ALIGN_LEFT
	/* titulo do detalhe */
	oPnlDetTit := TPanel():New(0,0,STR0232,oPnlTP,,.T.,,,,,,,)
	oPnlDetTit:Align := CONTROL_ALIGN_TOP
	oPnlDetTit:nWidth := oPnlTP:nWidth
	oPnlDetTit:nHeight := oPnlTP:nHeight * 0.015
/* painel superior do detalhe */
	oSayPorc 				:= TSay():Create(oPnlEdit)
	oSayPorc:cName 		:= "oSayPorc"
	oSayPorc:cCaption 	:= STR0127
	oSayPorc:nLeft 		:= 10
	oSayPorc:nTop 			:= 30
	oSayPorc:nWidth 		:= 66
	oSayPorc:nHeight 		:= 17

	@14,60 MSGET oPorDesc var nPorDesc picture "@E 99.99" pixel of oPnlEdit size 08,08 Valid (F850VldDe(1,@aDescontos,bZeraRets,(nValDesp-nRetIva-nRetIRC)) .And. Eval(bAtuOP) .And. F850Click(@aSE2,@aDescontos,.T.,oFolder,@aPagos))

	/* campo para o valor do desconto */
	oSayVlDesc 			:= TSay():Create(oPnlEdit)
	oSayVlDesc:cName 		:= "oSayVlDesc"
	oSayVlDesc:cCaption 	:= STR0128
	oSayVlDesc:nLeft 		:= 10
	oSayVlDesc:nTop 		:= 58
	oSayVlDesc:nWidth 	:= 200
	oSayVlDesc:nHeight 	:= 17

	@28,60 MSGET oValDesc var nValDesc picture Tm(nValDesc,19,nDecs) pixel of oPnlEdit size 08,08 Valid (F850VldDe(2,@aDescontos,bZeraRets,(nValDesp-nRetIva-nRetIRC)) .And. Eval(bAtuOP) .And. F850Click(@aSE2,@aDescontos,.T.,oFolder,@aPagos)) ;
	WHEN !(lVisualiza .Or. lShowPOrd) HASBUTTON
	oValDesc:nWidth = 100

	/* campo para o valor a pagar */
	oSayVlPg 				:= TSay():Create(oPnlEdit)
	oSayVlPg:cName 		:= "oSayVlPg"
	oSayVlPg:cCaption 	:= STR0164
	oSayVlPg:nLeft 		:= 10
	oSayVlPg:nTop 			:= 89
	oSayVlPg:nWidth 		:= 200
	oSayVlPg:nHeight 		:= 17

	@42,60 MSGET oVlrPagar Var nVlrPagar Valid (F850SaldVl(@aSE2) .and. IIf(cPaisLoc == "ARG", F850AtuOP(@aSE2), F850AtuOP())) Picture TM(nVlrPagar,16,nDecs) SIZE 60,09 OF oPnlEdit PIXEL WHEN !(lVisualiza .Or. lShowPOrd)

	/* campo para a natureza financeira */
	oSayNat 				:= TSay():Create(oPnlEdit)
	oSayNat:cName 			:= "oSayNat"
	oSayNat:cCaption 		:= STR0207
	oSayNat:nLeft 			:= 10
	oSayNat:nTop 			:= 117
	oSayNat:nWidth 		:= 200
	oSayNat:nHeight 		:= 17

	@57,60 MSGET oNatureza var cNatureza F3 "SED" PIXEL of oPnlEdit SIZE 08,08 Valid F850VldMD(1,cNatureza,@cMod,nFlagMOD) WHEN !(lVisualiza) HASBUTTON
	oNatureza:nWidth := 100

/* Folder principal para os detalhes de pagamento e titulos*/
	If cPaisLoc == "ARG"
		@ 004,004 FOLDER oFolder OF oPnlDetOP PROMPT OemToAnsi(STR0237),OemToAnsi(STR0245),OemToAnsi(STR0298),OemToAnsi(STR0098) PIXEL SIZE aSize[4]*0.18, aSize[3] * 0.17 //"Tํtulos/Doc. Terceiros/Doc. Pr๓prio/Retenciones
	Else
		@ 004,004 FOLDER oFolder OF oPnlDetOP PROMPT OemToAnsi(STR0237),OemToAnsi(STR0245),OemToAnsi(STR0298) PIXEL SIZE aSize[4]*0.18, aSize[3] * 0.17 //"Tํtulos/Doc. Terceiros/Doc. Pr๓prio
	EndIf
	oFolder:Align := CONTROL_ALIGN_TOP
	oFolder:aDialogs[1]:oFont := oDlg:oFont
	oFolder:aDialogs[2]:oFont := oDlg:oFont
	If cPaisLoc == "ARG"
		oFolder:aDialogs[4]:oFont := oDlg:oFont
	EndIf
/* browser com os titulos selecionados para a ordem de pago */
	oGetDad0 := MsNewGetDados():New(23,04,117,623,IIf(lVisualiza .Or. lShowPOrd,Nil,GD_UPDATE),"AllwaysTrue()","AllwaysTrue()",,aGet,/*freeze*/,,"F850FldOk1(bRecalc)",/*superdel*/,"F850DelOk()",oFolder:aDialogs[1],aHeaderSE2,aColsSE2)
	oGetDad0:SetArray(aColsSE2)
	oGetDad0:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetDad0:oBrowse:Refresh()
/* documentos de terceiros */
	oPnlDTerc := TPanel():New(0,0,"",oFolder:aDialogs[2],,.T.,,,,aSize[4],aSize[3],,)
	oPnlDTerc:Align := CONTROL_ALIGN_TOP
	oPnlDTerc:nHeight := oPnlDetOP:nHeight * 0.05
	/*_*/
	oPnlSep16 := TPanel():New(0,0,"",oFolder:aDialogs[2],,.T.,,,,aSize[4],aSize[3],,)
	oPnlSep16:Align := CONTROL_ALIGN_TOP
	oPnlSep16:nHeight := 5
	/* Painel para documentos de terceiros */
	oPnlTerc := TPanel():New(0,0,"",oPnlDTerc,,.T.,,,,aSize[4],aSize[3],,)
	oPnlTerc:Align := CONTROL_ALIGN_LEFT
	/*_*/
	@ 03,03 Group oGrpTerc TO 005,50 PIXEL OF oPnlTerc //LABEL OemToAnsi(STR0245)	//"Documentos de Terceiros"
	oGrpTerc:Align := CONTROL_ALIGN_RIGHT
	oGrpTerc:nWidth := oPnlTerc:nWidth - 3

	/*Totalizadores*/
	oSaySld  := TSay():New(3,5, {|| AllTrim(STR0030) + "  "},oPnlTot,,,,,,.T.,,,200,10,,,,,,)
	oSayTerc := TSay():New(13,5, {|| Alltrim(STR0245) + ": "},oPnlTot,,,,,,.T.,,,200,10,,,,,,)
	oSayProp := TSay():New(23,5, {|| Alltrim(STR0308) + ": "},oPnlTot,,,,,,.T.,,,200,10,,,,,,) //"Documentos pr๓prios"

	oSaldoPgOP  := TSay():New(3,80, {|| Transform(nSaldoPgOP,PesqPict("SE2","E2_VALOR"))},oPnlTot,,,,,,.T.,,,200,10,,,,,,)
	oTotDocTerc := TSay():New(13,80, {|| Transform(nTotDocTerc,PesqPict("SE2","E2_VALOR"))},oPnlTot,,,,,,.T.,,,200,10,,,,,,)
	oTotDocProp := TSay():New(23,80, {|| Transform(nTotDocProp,PesqPict("SE2","E2_VALOR"))},oPnlTot,,,,,,.T.,,,200,10,,,,,,) //"Documentos pr๓prios"

	If cPaisLoc != "ARG"
		/*_*/
		@ 10,005 SAY OemToAnsi(STR0123)	SIZE 40,09 OF oPnlTerc PIXEL					//"Cliente"
		@ 10,065 SAY OemToAnsi(STR0246)	SIZE 20,09 OF oPnlTerc PIXEL					//"Local"
		@ 10,095 SAY OemToAnsi(STR0247)	SIZE 60,09 OF oPnlTerc PIXEL					//"Tipo de Documento"
		/*_*/
		@ 17,005 MSGET cCliente F3 "SA1" VALID (If(!Empty(cCLiente),ExistCpo("SA1",cCliente),.T.)) WHEN !(lVisualiza) HASBUTTON SIZE 50,09 OF oPnlTerc PIXEL
		@ 17,065 MSGET cLoja  VALID (If(!Empty(cCLiente) .And. !Empty(cLoja),ExistCpo("SA1",cCliente+cLoja),.T.)) SIZE 08,09 Of oPnlTerc PIXEL WHEN !(lVisualiza)
		/* ComboBox para selecionar a data do debito do titulo de debito diferido*/
		@ 17,095 COMBOBOX oTipDocto VAR cTipoDocto ITEMS aTipoDocto SIZE 60,50 OF oPnlTerc PIXEL WHEN !(lVisualiza)
		/* Botใo de Filtro */
		DEFINE SBUTTON FROM 17,200 Type 17 Action F850FilDT(cCliente,cLoja,If(oTipDocto:nAt == 1,"*",aTipoTerc[oTipDocto:nAt - 1,2])) OF oPnlTerc PIXEL ENABLE
	Else
		oTButton1 := TButton():New( 005, 005, OemToAnsi(STR0340),oGrpTerc,{||F850FilDT()},70,012,,,.F.,.T.,.F.,,.F.,,,.F. ) //Selecionar Documentos
	EndIf

/* browser para documento de terceiros */
	oGetDad2 := MsNewGetDados():New(61,04,117,623,If(lVisualiza,Nil,GD_DELETE),"AllwaysTrue()","AllwaysTrue()",,,/*freeze*/,,"AllwaysTrue()",/*superdel*/,"F850DelPg(2)",oFolder:aDialogs[2],aHeader3os,aCols3os)
	oGetDad2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetDad2:SetArray(aCols3os)
	oGetDad2:oBrowse:Disable()
	oGetDad2:oBrowse:Refresh()
/* folder 3 */
/* browser para formas de pagamento com documentos proprios */
	oGetDad1 := MsNewGetDados():New(61,04,aSize[3]*0.22,623,IIf(lVisualiza,Nil,GD_INSERT+GD_UPDATE+GD_DELETE),"F850LnOK()","F850LnOK()",,aGetPg,/*freeze*/,,"F850FldOk2(.F.)",/*superdel*/,"F850DelPg(1)",oFolder:aDialogs[3],aHeaderPg,aColsPg)
	oGetDad1:oBrowse:Align := CONTROL_ALIGN_TOP
	oGetDad1:bChange := {|| F850LinPgto(),F850Lin()}
	oGetDad1:SetArray(aColsPg)
	oGetDad1:oBrowse:Refresh()

	oPnlFPag := TPanel():New(0,0,"",oFolder:aDialogs[3],,.T.,,,,aSize[4],aSize[3],,)
	oPnlFPag:Align := CONTROL_ALIGN_TOP
	oPnlFPag:nHeight := oPnlDetOP:nHeight * 0.07
	/*_*/
	oPnlSep15 := TPanel():New(0,0,"",oFolder:aDialogs[3],,.T.,,,,aSize[4],aSize[3],,)
	oPnlSep15:Align := CONTROL_ALIGN_TOP
	oPnlSep15:nHeight := 5
	/*_*/
	oPnlSep10 := TPanel():New(0,0,"",oPnlFPag,,.T.,,,,aSize[4],aSize[3],,)
	oPnlSep10:Align := CONTROL_ALIGN_TOP
	oPnlSep10:nHeight := 5
/* criterios de vencimento para um documento */
	oPnlUVct := TPanel():New(0,0,"",oPnlFPag,,.T.,,,,aSize[4],aSize[3],,)
	oPnlUVct:Align := CONTROL_ALIGN_LEFT
	oPnlUVct:nWidth := aSize[4]/2 - 3
	/*_*/
	@ 03,03 Group oGrpUnico TO 10,10 PIXEL OF oPnlUVct LABEL OemToAnsi(STR0238) 	//"Criterio para data de vencimento com um unico vencimento."
	oGrpUnico:Align := CONTROL_ALIGN_RIGHT
	oGrpUnico:nWidth := oPnlUVct:nWidth - 03
	/*_*/
	@ 013,006  COMBOBOX oUnico	 VAR nUnico SIZE oGrpUnico:nWidth/3,09 ITEMS aUnico; //"Primeiro Vencimento"###"Ultimo Vencimento"###"Ponderado dos Vencimentos"///
	ON CHANGE (F850VctoCheque(oUnico:nAt,oMultiplo:nAt),F850Lin()) OF oPnlUVct PIXEL
	oUnico:bSetGet := {|u| If (PCount()==0,nUnico,nUnico:=u)}
	oUnico:bValid := {|| F850VldVct(oUnico:nAt,oMultiplo:nAt)}
/* criterio de vencimento para multiplos documentos*/
	oPnlMVct := TPanel():New(0,0,"",oPnlFPag,,.T.,,,,aSize[4],aSize[3],,)
	oPnlMVct:Align := CONTROL_ALIGN_LEFT
	oPnlMVct:nWidth := aSize[4]/2 - 3
	/*_*/
	@ 03,03 Group oGrpMult TO 10,10 PIXEL OF oPnlMVct LABEL OemToAnsi(STR0242) 	//"Crit้rio para data de vencimento com multiplos vencimentos."
	oGrpMult:Align := CONTROL_ALIGN_RIGHT
	oGrpMult:nWidth := oPnlMVct:nWidth - 03
	/*_*/
	@ 13,06  COMBOBOX oMultiplo VAR nMultiplo SIZE oGrpMult:nWidth/3,09 ITEMS aMultiplo;		//OemToAnsi(STR0243)###"Calcular automaticamente"
	ON CHANGE (F850VctoCheque(oUnico:nAt,oMultiplo:nAt),F850Lin()) OF oPnlMVct PIXEL
	oMultiplo:bSetGet := {|u| If (PCount()==0,nMultiplo,nMultiplo:=u)}
	oMultiplo:bValid  := {|| F850VldVct(oUnico:nAt,oMultiplo:nAt)}
	
	/*Retenciones*/
	If cPaisLoc == "ARG" .and. CCO->(ColumnPos("CCO_TPCALR"))> 0
		bFnReLd := { || Fn850ReLd(@aSE2) }
		If Len(aColsRet) == 0
			aAdd(aColsRet,{"","","","",0,0,0,0,"",.F.})
		EndIf
		oGetDad3 := MsNewGetDados():New(61,04,aSize[3]*.3,623,IIf(lVisualiza,Nil,GD_UPDATE),"AllwaysTrue()","AllwaysTrue()",,aGetRet,/*freeze*/,,"Fn850EdCpo()",/*superdel*/,/*cDelOk*/,oFolder:aDialogs[4],aHeaderRet,aColsRet)
		oGetDad3:oBrowse:Align := CONTROL_ALIGN_TOP
		oGetDad3:SetArray(aColsRet)
		oGetDad3:oBrowse:Refresh()
		
		oPnlRet := TPanel():New(0,0,"",oFolder:aDialogs[4],,.T.,,,,aSize[4],aSize[3],,)
		oPnlRet:Align := CONTROL_ALIGN_TOP
		oPnlRet:nHeight := oPnlDetOP:nHeight * 0.07	
		/*_*/
		oPnlSep17 := TPanel():New(0,0,"",oFolder:aDialogs[4],,.T.,,,,aSize[4],aSize[3],,)
		oPnlSep17:Align := CONTROL_ALIGN_TOP
		oPnlSep17:nHeight := 5
	EndIF
	

ACTIVATE MSDIALOG oDlg  CENTERED ON INIT (EnchoiceBar(oDlg,{|| If(F850VldOPs(@aSE2),(nOpc := 1,oDlg:End()),)},{ || (nOpc := 0,F850DelAbt(SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM),oDlg:End())},,aButtons))

If Len(aDoc3osUtil) > 0
	AEval(aDoc3osUtil,{|x,y| SE1->(MsRUnlock(x))})
	aDoc3osUtil := {}
EndIf
If lF4
	SetKey(VK_F4,)
Endif

//Alimenta o obto com os dados do acols
If cPaisLoc == 'ARG' .And. lWsFeCred
	oRegSFK := oGetDad1
Endif

Return (nOpc == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA850   บAutor  ณMicrosiga           บFecha ณ  09/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VldOPs(aSE2, lPA, lOPRotAut)
Local lRet	 		:= .T.
Local lVldVcto		:= .F.
Local nLenAcol		:= 0
Local nLin			:= 0
Local nErro1		:= 0
Local aTextoVld		:= {}
Local aCheques		:= {}
Local cTexto		:= ""
Local cMsgSaldo		:= ""
Local oDlg			:= Nil
Local oMsg			:= Nil
Local nPosText 		:= 0
Local nLinha 		:= 0
Local nSaldo 		:= 0
Local nPosLinAct 	:= 0
Local lGenPA     	:= .F.
Local nSaldPgTer 	:= 0
Local nSlTer     	:= 0
Local nloopt     	:= 0
Local nDocTer    	:= 0
Local nDocPro    	:= 0
Local aAreaFJK	 	:= {}
Local aAreaTmp	 	:= {}
Local cTipo 		:= ""
Local nPosTipo		:= 0	
Default lPA 		:= .F.
Default lOPRotAut	:= .F.

If lOPRotAut
	 nTotDocTerc   := 0
endif

If !lOPRotAut
	nPosTipo	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
	nPosTpDoc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPODOC"})
	nPosNum		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_NUM"})
	nPosPrefix	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PREFIXO"})
	nPosMoeda	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
	nPosMPgto	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})
	nPosBanco	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
	nPosAge		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
	nPosConta	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
	nPosTalao	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})
	nPosVlr		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})
	nPosEmi		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
	nPosVcto	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
	nPosDeb		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_DEBITO"})
	nPosParc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PARCELA"})

	/*_*/
	If lPA
		aSE2[1,3] := {4,aClone(oGetDad1:aCols),aClone(oGetDad2:aCols),0,0,aVlPA[_PA_VLATU],aVlPA[_PA_MOEATU]}
	Else
		aSE2[oLbx:nAt,3] := {4,aClone(oGetDad1:aCols),aClone(oGetDad2:aCols),0,0,aVlPA[_PA_VLATU],aVlPA[_PA_MOEATU]}
	Endif
EndIf

aTextoVld := {}

//valida os dados referentes a pagamento com documentos proprios
If lRet
	if lPA .And. !lOPRotAut
	  If lVlrAlt .Or. nTotDocTerc>0
		if  nSaldoPgOP != 0

			cMsgSaldo := ""
			cMsgSaldo := OemToAnsi( STR0104 + GetMv("MV_SIMB"+Alltrim(Str(nMoedaCor)))+ Alltrim(Transform(nSaldoPgOP,PesqPict("SE2","E2_VALOR"))) + STR0105 + If(!lOPRotAut,CRLF + STR0341,"")) //"Faltan "
			Aadd(aTextoVld,{cFornece,cLoja,{},{}})
			nPosText :=  Len(aTextoVld)
			  //" o su equivalente en otra moneda, para pagar los titulos escogidos. Se deseja pagar este valor altera, na aba tํtulos, o valor a pagar."
			Aadd(aTextoVld[nPosText,3],AllTrim(cMsgSaldo) + "." )
			lRet := .F.
		EndIf
   	  Else
			lRet := .F.
			Help(NIL, NIL, STR0440 , NIL, STR0441, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0442})
	  EndIf
		If lRet
			lRet := F850Ench(@aSE2,lPA,cNatureza)
		Endif

		If lRet .And. ExistBLock('A850PAOK')
			lRet	:=	ExecBlock('A850PAOK',.F.,.F.,aClone(aSE2))
		Endif
		If  lRet .And. cPaisloc == "ARG"
			lRet := F850VldBAC(aSE2,@aTextoVld,lPA)  //Validaci๓n: Banco, Agencia y Cuenta
		Endif
		If  lRet .And. cPaisloc == "ARG"
			lRet := F850LnOK() //Validaci๓n Tipo de titulo. 
		Endif

	Else
		If  cPaisloc == "ARG" .And. len(aPagos) >0 
		   	For nSlTer:= 1  to len(aPagos)   
		   		nDocPro := 0    
		   		nDocTer := 0 
		   		For nloopt := 1 to len(aSE2[nSlTer,3,2])    
		   			nDocPro+= aSE2[nSlTer,3,2,nloopt,15]
		   		Next nloopt 
		   		For nloopt := 1 to len(aSE2[nSlTer,3,3])    
		   			nDocTer+= aSE2[nSlTer,3,3,nloopt,7]
		   		Next nloopt 
		   		
		   		nSaldPgTer := aPagos[nSlTer,H_TOTALVL] - (nDocTer + nDocPro)
				   	If  nSaldPgTer < 0 .And. Len(aSE2[nSlTer,3,3]) > 0 .And. cPaisloc == "ARG"
						If  AllTrim(aSE2[nSlTer,3,3,1,1]) == "CH"
							lRet := F850Tudok(2,nPagar,lPa,Nil,Nil,cNatureza,aCtrChEQU,nSaldPgTer,aSE2[nSlTer])
							lGenPA := lRet
						EndIf
					Endif   
			Next nSlTer
		Endif
		If !lOPRotAut
			If  Len(oGetDad1:aCols) > 0 .And. !Empty(oGetDad1:aCols[1])                  
				lRet := F850VldProp(aSE2,@aTextoVld,lPA)
				If  lRet  .And. cPaisloc == "ARG" //Solo valide si lo demแs esta correcto.
					lRet := F850VldBAC(aSE2,@aTextoVld,lPA)  //Validaci๓n: Banco, Agencia y Cuenta  
				Endif
			EndIf
		EndIf
		If  ExistFunc("F850SLDOP")
			If !lOPRotAut
				nPosLinAct := nOlbxAtAnt
			EndIf
			
			For nLinha := 1 To Len(aPagos)
				If aPagos[nLinha ,H_OK] = 1 // Marcado
					If (nSaldo := F850SldOP(aSE2, aPagos, nLinha, lOPRotAut)) != 0
						If  Iif(cPaisloc== "ARG", !(nSaldo<0 .And. lGenPA), .T.)
							cMsgSaldo := ""
							cMsgSaldo := OemToAnsi( STR0104 + GetMv("MV_SIMB"+Alltrim(Str(nMoedaCor)))+ Alltrim(Transform(nSaldo,PesqPict("SE2","E2_VALOR"))) + STR0105 + If(!lOPRotAut,CRLF + STR0341,"")) //"Faltan "
							Aadd(aTextoVld,{aPagos[nLinha,H_FORNECE],aPagos[nLinha,H_LOJA],{},{}})
							nPosText :=  Len(aTextoVld)
							//" o su equivalente en otra moneda, para pagar los titulos escogidos. Se deseja pagar este valor altera, na aba tํtulos, o valor a pagar."
							If lOPRotAut
								cTxtRotAut += cMsgSaldo
							EndIf
							Aadd(aTextoVld[nPosText,3],AllTrim(cMsgSaldo) + "." )
							lVldRet:= .F.
							lRet := .F.
						EndIf
					EndIf
				EndIf
			Next
			If !lOPRotAut
				nOlbxAtAnt := nPosLinAct
			EndIf
			
			
			If lRet
				lRet := F850Ench(@aSE2, lPA,cNatureza, , lOPRotAut)
			Endif
		EndIf
		If cPaisLoc == "ARG" .And. lShowPOrd .And. (Type("cAliasPOP") != "U" .And. Select(cAliasPOP) > 0)
			aAreaFJK := FJK->(GetArea())
			aAreaTmp := (cAliasPOP)->(GetArea())
			DbSelectArea(cAliasPOP)
			(cAliasPOP)->(DbSetOrder(2))
			(cAliasPOP)->(DbGoTop())
			If (cAliasPOP)->(DbSeek(cMarcaFJK))
				While !((cAliasPOP)->(EOF())) .and. ((cAliasPOP)->FJK_OK) == AllTrim(cMarcaFJK)
					FJK->(dbGoTo((cAliasPOP)->FJKREG))
					If Empty(FJK->FJK_DTANLI) .Or. !Empty(FJK->FJK_DTCANC) .Or. !Empty(FJK->FJK_ORDPAG)
						Aadd(aTextoVld,{(cAliasPOP)->FJK_FORNEC,(cAliasPOP)->FJK_LOJA,{},{}})
						Aadd(aTextoVld[Len(aTextoVld),3],STR0287 + ": " + FJK->FJK_PREOP )
						Aadd(aTextoVld[Len(aTextoVld),3],Replace(AllTrim(STR0286), " de", "") )
						lRet := .F. 
					EndIf
					(cAliasPOP)->(DbSkip())
				Enddo
			EndIf
			FJK->(RestArea(aAreaFJK))
			(cAliasPOP)->(RestArea(aAreaTmp))
		EndIf
	Endif
Endif

If  lRet .And. cPaisloc == "ARG"
	lRet := F850LnOK() //Validaci๓n Tipo de titulo, somente quando for OP
Endif

//exibe as ordens de pago que possuem inconsistencias
If !lRet
	If cPaisLoc == "ARG" .and. nPosTipo > 0 .and. len(aSE2[1][3][2]) > 0 
		cTipo := aSE2[1][3][2][len(aSE2[1][3][2])][nPosTipo]
	Endif
	aCheques := SEF->(DbRLockList())
	For nLin := 1 To Len(aCheques)
		SEF->(DbGoTo(aCheques[nLin]))
		SEF->(DbRUnLock(aCheques[nLin]))
	Next
	For nLin := 1 To Len(aTextoVld)
		If !Empty(aTextoVld[nLin,2])
			cTexto += Replicate("-",150)
			cTexto += CRLF
			cTexto += aTextoVld[nLin,1] + "/" + aTextoVld[nLin,2]
			cTexto += CRLF
			For nErro1 := 1 To Len(aTextoVld[nLin,3])
				cTexto += aTextoVld[nLin,3,nErro1]
				cTexto += CRLF
			Next
			cTexto += Replicate("-",150)
			cTexto += CRLF
			cTexto += CRLF		
		Endif
	Next
	If lOPRotAut
		cTxtRotAut += cTexto
		AutoGrLog(cTxtRotAut)
		lMsErroAuto := .T.
	ElseIf !Empty(cTexto)
		If (!Empty(cTipo) .and. cPaisLoc == "ARG") .or. cPaisLoc != "ARG"
			oDlg := TDialog():New(0,0,400,600,STR0309,,,,,,,,,.T.,,,,,) //"Inconsist๊ncias"
				oMsg := TMultiGet():New(0,0,{|u| cTexto},oDlg,100,100,,,,,,.T.,cTexto,,{|| .T.},.F.,.T.,.T.,,,,,)
				oMsg:Align := CONTROL_ALIGN_ALLCLIENT
			oDlg:Activate(,,,.T.)
		Endif
	EndIf
EndIf

If (cPaisLoc $ "ARG|RUS") .And. (lRet)
	lRet := VldDocPag()
EndIf


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VLDPROPบAutor  ณMicrosiga          บFecha ณ  09/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VldProp(aSE2,aTextoVld,lPA, lOPRotAut)

Local aAreaFJS		:= {}
Local aAreaSA6		:= {}

Local lRet			:= .T.
Local lCont		:= .F.
Local nLin			:= 0
Local nLenAcol		:= 0
Local nLenSE2		:= 0
Local nSE2			:= 0
Local nPorc		:= 0
Local nPosPorc		:= 0
Local nPosPgto		:= 0
Local nLenVld		:= 0
Local cTipoInt		:= ""
Local lVldDtVcto

Default lPA		:= .F.
Default aTextoVld	:= {}
Default lOPRotAut	:= .F.

If !lOPRotAut
	nPosTipo	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
	nPosTpDoc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPODOC"})
	nPosNum	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_NUM"})
	nPosMoeda	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
	nPosMPgto	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})
	nPosBanco	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
	nPosAge	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
	nPosConta	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
	nPosTalao	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})
	nPosVlr	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})
	nPosEmi	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
	nPosVcto	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
	nPosDeb	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_DEBITO"})
	nPosParc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PARCELA"})
	/*_*/
	nPosPorc   := Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "NPORVLRPG"})
	/*_*/
Else
	nPosTipo		:=	1
	nPosTpDoc		:=	0
	nPosNum		:=	3
	nPosPrefix		:=	2
	nPosMoeda		:=	6
	nPosMPgto		:=	6
	nPosBanco		:=	9
	nPosAge		:=	10
	nPosConta		:=	11
	nPosTalao		:=	12
	nPosVlr		:=	5
	nPosEmi		:=	7
	nPosVcto		:=	8
	nPosDeb		:=	0
	nPosParc		:=	4
	nPosVlrE1		:=	7
	nPosMoedaE1	:=	8
EndIf

nLenSE2 := Len(aSE2)
nSE2 := 0
While (nSE2 < nLenSE2)
	nSE2++
	nLin := 0
	lCont := .T.
	If !aSE2[nSE2][5]
		Loop
	EndIf

	If aPagos[nSE2,1] <> 1
		Loop
	EndIf

	If lPA
		Aadd(aTextoVld,{cFornece,cLoja,{},{}})
	Else
		Aadd(aTextoVld,{aPagos[nSE2,H_FORNECE],aPagos[nSE2,H_LOJA],{},{}})
	Endif
	nLenVld := Len(aTextoVld)
	nLenAcol := Len(aSE2[nSE2,3,2])
	If nLenAcol == 0
		Aadd(aTextoVld[nLenVld,3],AllTrim(STR0310) + "." )//"Nใo possui formas de pagamento definidas"
	Else
		While (nLin < nLenAcol) .And. lCont
			nLin++

			If !lOPRotAut
				nPorc += aSE2[nSE2,3,2,nLin,nPosPorc]
			EndIf

			nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(aSE2[nSE2,3,2,nLin,nPosTipo])})
			If nPosPgto > 0
				cTipoint := AllTrim(aFormasPgto[nPosPgto,2])
			Endif
			If !Empty(aSE2[nSE2,3,2,nLin,nPosTipo]) .OR. !Empty(aSE2[nSE2,3,2,nLin,nPosBanco]) .OR. !Empty(aSE2[nSE2,3,2,nLin,nPosAge]) .OR.;
			 !Empty(aSE2[nSE2,3,2,nLin,nPosConta]) .OR. !Empty(aSE2[nSE2,3,2,nLin,nPosVcto]) .OR. !Empty(aSE2[nSE2,3,2,nLin,nPosNum]);
			 .OR. Iif (cPaisloc != "MEX",(!Empty(aSE2[nSE2,3,2,nLin,nPosTalao])),.T.)  // caso o pagamento seja integralmente com documentos de terceiros, nenhum desses campos sera preenchido
				Do Case
					Case !Empty(aSE2[nSE2,3,2,nLin,nPosVlr]) .and.  Empty(aSE2[nSE2,3,2,nLin,nPosTipo])
						lRet := .F.
						lCont := .F.
						Aadd(aTextoVld[nLenVld,3],AllTrim(STR0311) + "." ) //"Ha itens que nใo possuem a forma de pagamento definida"
					Case !Empty(aSE2[nSE2,3,2,nLin,nPosVlr]) .and. (Empty(aSE2[nSE2,3,2,nLin,nPosBanco]) .Or. Empty(aSE2[nSE2,3,2,nLin,nPosAge]) .Or. Empty(aSE2[nSE2,3,2,nLin,nPosConta]))
						lRet := .F.
						lCont := .F.
						Aadd(aTextoVld[nLenVld,3],AllTrim(STR0003))
					Case !Empty(aSE2[nSE2,3,2,nLin,nPosVlr]) .and. Empty(aSE2[nSE2,3,2,nLin,nPosVcto])
						lRet := .F.
						lCont := .F.
						Aadd(aTextoVld[nLenVld,3],AllTrim(STR0312) + "." ) //"Ha formas de pagamento com documento pr๓prio nใo possuem a data de vencimento informada"
					Case cTipoInt <> "CH"
						If !Empty(aSE2[nSE2,3,2,nLin,nPosVlr]) .and. (Empty(aSE2[nSE2,3,2,nLin,nPosNum]))
							lRet := .F.
							lCont := .F.
							Aadd(aTextoVld[nLenVld,3],AllTrim(STR0313) + ".") // "Ha formas de pagamento com documento pr๓prio que nใo possuem o n๚mero do documento informado"
						Endif
					Case cTipoInt == "CH"
						If (Empty(aSE2[nSE2,3,2,nLin,nPosTalao]))
							lRet := .F.
							lCont := .F.
							Aadd(aTextoVld[nLenVld,3],AllTrim(STR0314) + ".") // "Ha formas de pagamento com cheques pr๓prios que nใo possuem o n๚mero do talใo correspondente"
						Endif
				EndCase
			ElseIf nSaldoPgOP > 0
				Aadd(aTextoVld[nLenVld,3],STR0357) //Existem dados de configura็ใo em branco
				lRet := .F.
				lCont := .F.
			EndIf

			lVldDtVcto := Iif(lOPRotAut,;
								F850VldVct(nUnico,nMultiplo,.F.,aSE2[nSE2,3,2],.T.),;
								F850VldVct(oUnico:nAt,oMultiplo:nAt,.F.,aSE2[nSE2,3,2]))

			//Valida as datas de vencimento informadas
			If !lVldDtVcto
				lRet	:= .F.
				lCont 	:= .F.
				Aadd(aTextoVld[nLenVld,3],AllTrim(STR0370)) //Data de vencimento calculada/informada invแlida. Verifique outra forma de cแlculo ou informe uma data vแlida.
			EndIf

			//Valida็ใo do tipo de movimento do banco
			If lRet
				If !FA850TpBco(aSE2[nSE2,3,2,nLin,nPosTipo],aSE2[nSE2,3,2,nLin,nPosBanco],aSE2[nSE2,3,2,nLin,nPosAge],aSE2[nSE2,3,2,nLin,nPosConta],.F.)
					Aadd(aTextoVld[nLenVld,3],STR0375 + " " + AllTrim(Str(nLin))+".")		//"Hay un tipo de banco que no es vแlido para el modo de pago en la linea"
					lRet	:=	.F.
					lCont	:= .F.
				EndIf
			EndIf

		Enddo
	Endif
EndDo
If (nSE2 <= nLenSE2) 
	lRet := .T.
Elseif !Empty (aSE2[nSE2,3,2,nLin,nPosEmi])
	lRet := .T.	
EndIf

If lRet .And. Empty(cNatureza)
	nLenVld := Len(aTextoVld)
	If nLenVld ==0
		Aadd(aTextoVld,{aPagos[nSE2,H_FORNECE],aPagos[nSE2,H_LOJA],{},{}})
		nLenVld:=1
	EndIf
	Aadd(aTextoVld[nLenVld,3],"Modalidad en Blanco" + " " )		//"Hay un tipo de banco que no es vแlido para el modo de pago en la linea"
	lRet	:=	.F.
	lCont	:= .F.
	if (cPaisloc == "ARG"	.and.  (Empty(aTextoVld[nLenVld,1]) .or. Empty(aTextoVld[nLenVld,2]))) 
		lRet	:=	.T.
		lCont	:= .T.
	endif
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850Ench บAutor  ณBruno Sobieski      บ Data ณ  08.01.01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da tela principal.                                บฑฑ
ฑฑบ          ณVerifica a forma de pagamento dos titulos. Deve ser informadaบฑฑ
ฑฑบ			 ณuma forma de pagamento diferenciada para cada um dos titulos,บฑฑ
ฑฑบ			 ณe ou um pagamento generico para um ou mais titulos que nao	บฑฑ
ฑฑบ			 ณestiverem na condicao de pago diferenciado.                 	บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                    บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850Ench(aSE2, lPA, cNatureza, nValOrdens, lOPRotAut)
Local lBcoOk 			:=	.T.
Local lRet 			:=	.T.
Local lNegativo 		:=	.F.
Local aSoluEsp			:=	{}
Local aSoluPor			:=	{}
Local aSoluEng			:=	{}
Local aCheques			:=	{}
Local nTotalIVA		:=	0
Local nA 				:=	0
Local nB 				:=	0
Local nC 				:=	0
Local nX				:=	1
Local nOpc				:=	0
Local cCalcITF			:=	SuperGetMv("MV_CALCITF",.F.,"2")
Local cQrySEF			:=	""
Local lLckSEF			:=	.F.
Local cTmpSef			:=	""
Local nXRec			:=	0
Local nRecnoSEF		:=	0
Local nLenAcol			:=	0
Local nPosTercei		:=	0
Local nPosAgenc		:=	0
Local nPosConta		:=	0
Local nPosVencto		:=	0
Local nPosPgto			:=	0
/*_*/
Local aTaloes			:=	{}
Local nPosChq			:=	0
Local nPosE1Emi			:= 0
Local nPosE1Ven			:= 0


DEFAULT cNatureza		:=	""
DEFAULT nValOrdens		:=	0
DEFAULT lPA				:=	.F.
DEFAULT lOPRotAut		:=	.F.



If !lOPRotAut
	nPosTipo	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
	nPosTpDoc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPODOC"})
	PosNum		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_NUM"})
	nPosMoeda	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
	nPosMPgto	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})
	nPosBanco	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
	nPosAge		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
	nPosConta	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
	nPosTalao	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})
	nPosVlr		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})
	nPosEmi		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
	nPosVcto	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
	nPosDeb		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_DEBITO"})
	nPosParc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PARCELA"})
	nPosE1Emi 	:= Ascan(oGetDad2:aHeader,{|X| Alltrim(X[2]) == "E1_EMISSAO"})
    nPosE1Ven	:= Ascan(oGetDad2:aHeader,{|X| Alltrim(X[2]) == "E1_VENCREA"})

	If lPA
		aSE2[1,3] := {4,aClone(oGetDad1:aCols),aClone(oGetDad2:aCols),0,0,aVlPA[_PA_VLATU],aVlPA[_PA_MOEATU]}
	Else
		aSE2[oLbx:nAt,3] := {4,aClone(oGetDad1:aCols),aClone(oGetDad2:aCols),0,0,aVlPA[_PA_VLATU],aVlPA[_PA_MOEATU]}
	Endif

	nLenAcol := Len(oGetDad1:aCols[1]) + 1
EndIf

For nx:=1 to Len(aSE2)
	If  aSE2[nx][3]==NIL .Or. aSE2[nx][3][1]==4 .And. aSE2[nx][3][5] > 0
		If nX<= Len(aPagos) .And. aPagos[nX][1] == 1
			lBcoOk:=.F.
		EndIf
	EndIf
Next

SA6->(DbSetOrder(1))
For nA := 1 To Len(aSE2)
	If (aPagos[nA][H_TOTALVL] < 0) .And. aPagos[nA][1] == 1
		lNegativo := .T.
		Exit
	EndIf
Next nA

//Definir variaveis...
If lOPRotAut
	nPosTipo	:=	1
	nPosTpDoc	:=	0
	nPosNum	:=	3
	nPosPrefix	:=	2
	nPosMoeda	:=	6
	nPosMPgto	:=	6
	nPosBanco	:=	9
	nPosAgenc	:=	10
	nPosConta	:=	11
	nPosTalao	:=	12
	nPosVlr	:=	5
	nPosEmi	:=	7
	nPosVcto	:=	8
	nPosDeb	:=	0
	nPosParc	:=	4
	nLenAcol	:=	Len(aSE2[1][3][2][1]) + 1
Else
	nPosTipo  	:= GDFieldPos("EK_TIPO",		oGetDad1:aHeader)
	nPosTercei	:= GDFieldPos("EK_TERCEIR",	oGetDad1:aHeader)
	nPosBanco 	:= GDFieldPos("EK_BANCO",	oGetDad1:aHeader)
	nPosAgenc 	:= GDFieldPos("EK_AGENCIA",	oGetDad1:aHeader)
	nPosConta 	:= GDFieldPos("EK_CONTA",	oGetDad1:aHeader)
	nPosTalao 	:= GDFieldPos("EK_TALAO",	oGetDad1:aHeader)
	nPosVencto	:= GDFieldPos("EK_VENCTO",	oGetDad1:aHeader)
	nPosNum   	:= GDFieldPos("EK_NUM",		oGetDad1:aHeader)
EndIf

aCheques 	:= {}
aTaloes  	:= {}

For nA 	:= 1 To Len(aSE2)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณValidacao do valor da retencao de IVA, ณ
			//ณimpede valores de retencao negativos.  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		If ( cPaisLoc == "ARG" )
			nTotalIVA := 0
			If !lPA
				For nB := 1 To Len(aSE2[nA][1])
					For nC := 1 to Len(aSE2[nA][1][nB][_RETIVA])
						nTotalIVA := nTotalIVA + aSE2[nA][1][nB][_RETIVA][nC][6]
					Next nC
				Next nB
				If aRetIvAcm[3] <> Nil .And. Len(aRetIvAcm)>2 .And. Len(aRetIvAcm[3]) > 0
	           	For nX:= 1 to Len(aRetIvAcm[3])
						nTotalIVA +=  aRetIvAcm[3][nX][6]
	           	Next Nx

				EndIF
				If ( nTotalIVA < 0 )

					Help(" ",1,"A085RETIVA")

					lRet := .F.
					Exit
				Endif
			Endif
		EndIf
		/*
		verifica o uso de cheques nos pagamentos com documentos proprios */
		For nB := 1 To Len(aSE2[nA][3][2])
			nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(aSE2[nA,3,2,nB,nPosTipo])})
			If nPosPgto > 0 .And. AllTrim(aFormasPgto[nPosPgto,2]) == "CH"
				cBanco		:= aSE2[nA,3,2,nB,nPosBanco]
				cAgencia	:= aSE2[nA,3,2,nB,nPosAgenc]
				cConta		:= aSE2[nA,3,2,nB,nPosConta]
				cNumTalao	:= aSE2[nA,3,2,nB,nPosTalao]
				nPosChq 	:= Ascan(aTaloes,{|talao| talao[1] == cBanco .And. talao[2] == cAgencia .And. talao[3] == cConta .And. talao[4] == cNumTalao})
				/*
				reserva de espaco para o recno do registro na tabela sef*/
				nLenAcol := Len(aSE2[nA,3,2,nB]) + 1
				Asize(aSE2[nA,3,2,nB],nLenAcol)
				aIns(aSE2[nA,3,2,nB],nLenAcol - 1)
				aSE2[nA,3,2,nB,nLenAcol - 1] := 0
				/*_*/
				If nPosChq == 0
					Aadd(aTaloes,{cBanco,cAgencia,cConta,cNumTalao,{}})
					nPosChq	:=	Len(aTaloes)
				Endif
				Aadd(aTaloes[nPosChq,5],{nA,nB})
			Endif
		Next
	Next nA

//Caso nao tenha sido informado o banco e o exista retencao de IVA
//deve ser liberada a gravacao...
If lRet
	If !lBcoOk
		If cPaisLoc == "ARG"
			For nA := 1 To Len(aSE2)
				If (aPagos[nA][H_TOTALVL] <= 0) .And. (DesTrans(aPagos[nA][H_RETIVA],nDecs) > 0)
					lBcoOk := .T.
					Exit
				EndIf
			Next nA
		EndIf
		//Caso o saldo da OP seja igual a zero(situacao: o total das PAs equivale ao total
		//das NFs a pagar) nao deve validar se foi digitado o banco, ou seja, se o saldo
		//para qq. fornecedor for maior a zero, deve validar o banco
		lBcoOk := .T.
		For nA := 1 to Len(aPagos)
			If (aPagos[nA][H_TOTALVL] > 0)
				lBcoOk  := .F.
				Exit
			EndIf
		Next nA
	EndIf
	If  !lBcoOk .And. Empty(cBanco+cAgencia+cConta) .and. cPaisLoc <> "ARG"
		Help("",1,"BCOBRANCO")
		lRet := .F.
	ElseIf !lBcoOk .And. !SA6->(MsSeek(xFilial()+cBanco+cAgencia+cConta)) .and. cPaisLoc <> "ARG"
		Help("",1,"BCONAOCAD")
		lRet := .F.
	ElseIf nNumOrdens < 1 .and. !lOPRotAut// nao se selecionou nenhum fornecedor (titulos)
		Help("",1,"SEMORDPAG")
		lRet := .F.
	ElseIf lNegativo
		Help("",1,"NEGATIVO")
		lRet := .F.
	Else
		nOpc := 1
		If nCondAgr>1  //Verificar se todas as OP's possuem fornecedor
			nG:=1
			nN:=Len(aPagos)
			While nG<=nN .and. nOpc==1
				If aPagos[nG][H_OK]==1
					If Empty(aPagos[nG][H_LOJA])
						nOpc:=0
					Endif
				Endif
				nG++
			Enddo
			If nOpc==0
				If lOPRotAut
					AutoGrLog(OemToAnsi(STR0141))
					lMsErroAuto := .T.
				Else
					MsgAlert(OemToAnsi(STR0141))  //"Existem pagamentos sem fornecedor. Selecione o fornecedor com F4."
				EndIf
				lRet := .F.
			Endif
		Endif
	Endif
Endif
If lRet .and. aSE2[1][3] == Nil
	lRet:=lRetCkPG(0,cDebInm,cBanco,nPagar)
Endif
If lRet .And. UsaSeqCor()
	cCodDiario := CTBAVerDia()
EndIf

If lRet .And. ExistBLock('A085TUDOK')
	lRet	:=	ExecBlock('A085TUDOK',.F.,.F.,aClone(aSE2))
Endif
If lRet .and. cPaisLoc$"DOM|COS" .and. Empty(cNatureza) .and. AllTrim(cCalcITF) == "1"
	If lOPRotAut
		AutoGrLog(STR0218) //"O campo Natureza e obrigat๓rio!"
		lMsErroAuto := .F.
	Else
		MsgAlert(STR0218)
	EndIf
	lRet :=	.F.
Endif

//reserva os cheques para pagamentos
If lRet
	nA := 0
	nC := Len(aTaloes)
	lLckSEF := .T.
	nLenAcol--
	While (nA < nC) .And. lLckSEF
		nA++
		cTmpSEF := GetNextAlias()
		cQrySEF	:= "Select EF_BANCO,EF_CONTA,EF_AGENCIA,EF_TALAO,EF_PREFIXO,EF_NUM,R_E_C_N_O_"
		cQrySEF	+= " from " + RetSqlName("SEF") + " SEF"
		cQrySEF += " where EF_FILIAL = '" + xFilial("SEF") + "'"
		cQrySEF += " and EF_CART = 'P'"
		cQrySEF	+= " and EF_BANCO = '" + aTaloes[nA,1] + "'"
		cQrySEF += " and EF_AGENCIA = '" + aTaloes[nA,2] + "'"
		cQrySEF += " and EF_CONTA = '" + aTaloes[nA,3] + "'"
		cQrySEF += " and EF_TALAO = '" + aTaloes[nA,4] + "'"
		cQrySEF += " and EF_STATUS = '00' AND EF_LIBER = 'S'"
		cQrySEF	+= " and D_E_L_E_T_ = ''"
		cQrySEF += " order by EF_BANCO,EF_AGENCIA,EF_CONTA,EF_TALAO,EF_PREFIXO,EF_NUM"
		cQrySEF	:= ChangeQuery(cQrySEF)
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQrySEF),cTmpSEF,.F.,.T.)
		(cTmpSEF)->(dbGoTop())
		nXrec := Len(aTaloes[nA,5])
		nX := 0
		While (nX < nXrec) .And. !((cTmpSEF)->(EOF()))
			SEF->(DbGoTo((cTmpSEF)->R_E_C_N_O_))
			If SEF->(DbRLock((cTmpSEF)->R_E_C_N_O_))
				nX++
				aSE2[aTaloes[nA,5,nX,1],3,2,aTaloes[nA,5,nX,2],nPosNum] := (cTmpSEF)->EF_NUM
				/*
				armazena o recno da tabela sef no espaco reservado anteriormente*/
				aSE2[aTaloes[nA,5,nX,1],3,2,aTaloes[nA,5,nX,2],nLenAcol] := (cTmpSEF)->R_E_C_N_O_
			Endif
			(cTmpSEF)->(dbSkip())
		Enddo
		dbSelectArea(cTmpSEF)
		DbCloseArea()
		If nX < nXrec
			lLckSEF := .F.

			If lOPRotAut
				cTxtRotAut += STR0226 + CRLF + CRLF
			Else
				MsgAlert(STR0226)  //"Nใo foi encontrado cheque disponivel para este pagamento!"
			Endif

			lRet:=.F.
			aCheques := SEF->(DbRLockList())
			For nC := 1 To Len(aCheques)
				SEF->(DbGoTo(aCheques[nC]))
				SEF->(DbRUnLock(aCheques[nC]))
			Next
		Endif
	Enddo
Endif
If ExistBlock("F85ASDBCO")
	lRet:= ExecBlock("F85ASDBCO",.F.,.F.,{cBanco,cAgencia,cConta,nValOrdens})
Endif
If lPa
	For nx:=1 to Len(aSE2[1,3,2])
		If aSE2[1,3,2,nx,nPosVlr] > 0 .and.;
			(aSE2[1,3,2,nx,nPosVcto])< (aSE2[1,3,2,nx,nPosEmi])		
				lRet:= .F.
				MsgAlert("La fecha de Vecimento debe ser igual o mayor que la fecha de emisi๓n")
			Exit
		Endif
	Next 
	For nx:=1 to Len(aSE2[1,3,3])
		If (aSE2[1,3,3,nx,nPosE1Ven])< (aSE2[1,3,3,nx,nPosE1Emi])		
			lRet:= .F.
			MsgAlert("La fecha de Vecimento debe ser igual o mayor que la fecha de emisi๓n")
			Exit
		EndIf
	Next	
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850TudokบAutor  ณBruno Sobieski      บ Data ณ  04/11/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a digitacao dos titulos no pagamento parcial         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850Tudok(nOpc,nPagar,lPa,nLiquido,oObj,cNatureza,aCtrChEQU,nSaldoPgOP,aSE2)
Local lRet		:=	.T.
Local nDel
Local nLines	:=	0
Local lMoedaOk	:=	.T.
Local nMoedaCol	:=	1
Local nTotalCol	:=	0
Local nPosMoe		:=	Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
Local nPosValor 	:=	Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})
Local nX		:= 0
Local nValorTit:= 0
Local oDlg1
Local nBaseImp
Local cCalcITF   := SuperGetMv("MV_CALCITF",.F.,"2")
Local lLckSEF := .F.
Local cQrySEF
Local cTMPSEF
Local nRecnoSEF
Local lF850NOPA := Existblock("F085ANOPA")
Local cCodFor := aSE2[1][1][1]
Local cLojaFor := aSE2[1][1][2]

Private oTes,oBaseImp

Default aCtrChEQU	:=	{}
Default nSaldoPgOP := 0
Default aSE2 := {}

If lF850ChS .and. nPagar==1
	nPagar++
Endif
If cPaisLoc $ "EQU|DOM|COS" .and. nOpc==2
	If Len(aCtrChEQU)==0
		Aadd(aCtrChEQU,{0,""})
	Else
		SEF->(MsUnlock())
		aCtrChEQU:={}
		Aadd(aCtrChEQU,{0,""})
	Endif
Endif
If lRetPA == Nil
	lRetPA := (GetNewPar("MV_RETPA","N") == "S")
EndIf

lPa	:=	If(lPa==Nil,.F.,lPa)
nLiquido:=	If(nLiquido==Nil,0,nLiquido)
nValor := IIf( Type("NVALOR")=="U", 1, nValor)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacao da digitacao dos saldos a pagar dos titulos escolhidosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nVlrPagar <= 0
	Help(" ",1,"VALNEG")
	lRet := .F.
EndIf

If Type("cFornece")<>"U" .and. Type("cLoja")<>"U"
	If  Empty(cFornece) .or. Empty(cLoja)
		Help(" ",1,"Obrigat")
		lRet := .F.
	Else
		SA2->(DbsetOrder(1))
		If !(SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja) ))
			Help( " ", 1, "NOFORNEC",, STR0389 , 1, 0 ) 
			lRet := .F.
		EndIf
	EndIf
EndIf
If nOpc	==	1 .and. lRet
	If	nValLiq	<	0 .And. lRet
		MsgAlert(STR0103) //"Escoja un valor mayor (o igual) que cero."
		lRet	:=	.F.
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidacao dos titulos entregues para o pago na seleccao de ณ
	//ณpagamento diferenciado.                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nOpc == 2 .and. lRet
	If Len(oGetDad1:aCols) == 0 .And. Len(oGetDad2:aCols) == 0
		Help("",1,"NoCols")
		lRet	:=	.F.
	ElseIf !lPA	.And. nSaldoPgOP > 0 .and. !lRetPA
		lRet	:=	MsgYesNo(OemToAnsi(STR0104 + GetMv("MV_SIMB"+Alltrim(Str(nMoedaCor)))+ TransForm(nSaldoPgOP,Tm(nSaldoPgOP,18,nDecs)) +; //"Faltan "
		STR0105+CHR(13)+CHR(10)+; //" o su equivalente en otra moneda, para pagar los titulos escogidos."
		STR0106+CHR(13)+CHR(10)+; //"Si confirma, la diferencia sera paga de la forma escogida para el resto de las OP."
		STR0107),OemToAnsi(STR0040)) //"?Desea confirmar ? "###"Confirmar"
	ElseIf  !lPa .And. nSaldoPgOP < 0	.and. !lRetPA
		If lF850NOPA
			lRet := ExecBlock("F085ANOPA",.F.,.F.,{nSaldoPgOP})
		Else
			lRet	:=	MsgYesNo(OemToAnsi(STR0109+ GetMv("MV_SIMB"+Alltrim(Str(nMoedaCor))) + TransForm(nSaldoPgOP*-1,Tm(nSaldoPgOP,18,nDecs)) +; //"Sobran "
			STR0110+CHR(13)+CHR(10)+; //" o sus equivalentes en otras monedas, para pagar los titulos escogidos."
			STR0111+CHR(13)+CHR(10)+; //"Si confirma, seran generados PA por la diferencia "
			STR0107),OemToAnsi(STR0108)) //"?Desea confirmar ? "###"Confirmar"
		Endif
	ElseIf  !lPa .And. lRetPA .And. nSaldoPgOP <> 0
		For nX:=1 to Len(aSE2[3][3])
			nValorTit:= nValorTit+ IIF(ValType(aSE2[3][3][nX][nPosValor]) == "C", Val(aSE2[3][3][nX][nPosValor]),aSE2[3][3][nX][nPosValor])
		Next
		If nSaldoPgOP < 0
			lRet	:=	MsgYesNo(OemToAnsi(STR0109+ GetMv("MV_SIMB"+Alltrim(Str(nMoedaCor))) + TransForm(nSaldoPgOP*-1,Tm(nSaldoPgOP,18,nDecs)) +; //"Sobran "
			STR0110+CHR(13)+CHR(10)+; //" o sus equivalentes en otras monedas, para pagar los titulos escogidos."
			STR0111+CHR(13)+CHR(10)+; //"Si confirma, seran generados PA por la diferencia "
			STR0107),OemToAnsi(STR0108)) //"?Desea confirmar ? "###"Confirmar"
		ElseIf nSaldoPgOP > 0
			lRet	:=	MsgYesNo(OemToAnsi(STR0104 + GetMv("MV_SIMB"+Alltrim(Str(nMoedaCor)))+ TransForm(nSaldoPgOP,Tm(nSaldoPgOP,18,nDecs)) +; //"Faltan "
			STR0105+CHR(13)+CHR(10)+; //" o su equivalente en otra moneda, para pagar los titulos escogidos."
			STR0106+CHR(13)+CHR(10)+; //"Si confirma, la diferencia sera paga de la forma escogida para el resto de las OP."
			STR0107),OemToAnsi(STR0040)) //"?Desea confirmar ? "###"Confirmar"
		EndIf
	ElseIf lRetPA	.And. lPA
		nTotalCol := nTotDocProp + nTotDocTerc
		If nTotalCol <> nVlrPagar
			AVISO(STR0163, STR0162+"."+CRLF+"Informar valores para el pago por el total de "+GetMv("MV_SIMB1")+TransForm(nLiquido,PesqPict("SE2","E2_VALOR"))+".",{"OK"},2  ) //" Valores dos titulos informados esta diferente do valor total da Op"###"Valor"
			lRet	:=	.F.
		Endif
	Endif
Endif

If Type("aSaldos")<>"U" .And. !lPa .And. nSaldoPgOP < 0	.and. lRetPA .And. lRet
	DEFINE MSDIALOG oDlg1 FROM 30,40  TO 200,400 TITLE OemToAnsi(STR0189) Of oMainWnd PIXEL  // "Orden de pago del proveedor "

	//Titulos por pagar
	@ 05,004 To 80,175 Pixel Of  oDlg1

	@ 10,015 SAY OemToAnsi(STR0190)SIZE 250, 7 OF oDlg1 PIXEL
	@ 20,015 SAY OemToAnsi(STR0191) SIZE 250, 7 OF oDlg1 PIXEL


	@ 40,006 SAY OemToAnsi(STR0184) SIZE 30, 7 OF oDlg1 PIXEL COLOR CLR_HBLUE //Codigo Fiscal
	@ 40,025 MSGET cTes	F3 "SF4" Picture "@S3"  Valid F850ImpTes(@nBaseRet,Iif(Type(cCodFor)<> "U",cCodFor,""),Iif(Type(cLojaFor)<> "U",cLojaFor,""),@nBaseRG) SIZE 15, 7 PIXEL OF oDlg1 // WHEN nPagar<>4

	@ 40,75 SAY OemToAnsi(STR0159) SIZE 45, 7 OF oDlg1 PIXEL COLOR CLR_HBLUE //Provincia
	@ 40,119 MSGET cProv F3 "12" Picture "@!" Valid F850ImpTes(@nBaseRet,Iif(Type(cCodFor)<> "U",cCodFor,""),Iif(Type(cLojaFor)<> "U",cLojaFor,""),@nBaseRG)  SIZE 15, 7 PIXEL OF oDlg1 // WHEN nPagar<>4

	@ 55,006 SAY SubStr(OemToAnsi(STR0124), 1, 5) SIZE 45, 7 OF oDlg1 PIXEL COLOR CLR_HBLUE //Serie
	@ 55,025 MSGET cSerie Picture "@!" Valid F850ImpTes(@nBaseRet,Iif(Type(cCodFor) != "U",cCodFor,""),Iif(Type(cLojaFor) != "U",cLojaFor,""),@nBaseRG)  SIZE 15, 7 PIXEL OF oDlg1 // WHEN nPagar<>4

	DEFINE SBUTTON FROM 67,070  Type 1 Action If((!Empty(cTes) .And. !Empty(cProv) .And. !Empty(cSerie)),(nOpca := 1,oDlg1:End()),HELP(" ",1,"OBRIGAT",,SPACE(45),3,0)) ENABLE PIXEL OF oDlg1
	Activate Dialog oDlg1 CENTERED
EndIf
If  nOpc==2 .and. cPaisLoc $ "ARG|EQU|DOM|COS"
	If	nPagar==2 .and. lRet .and. cPaisLoc $ "ARG|EQU|DOM|COS"
		cTMPSEF	:=	Alias()
		If Select("TMPSEF")>0
			TMPSEF->(DbCloseArea())
		Endif
		#IFDEF TOP
			cQrySEF	:="SELECT EF_CART,EF_TALAO,EF_PREFIXO,EF_NUM,EF_STATUS,EF_LIBER,R_E_C_N_O_ "
			cQrySEF	+="FROM "+RETSQLNAME("SEF")+" WHERE EF_FILIAL='"+xFILIAL("SEF")+"' AND EF_CART='P' AND "
			cQrySEF	+="EF_BANCO='"+cBanco+"' AND EF_AGENCIA='"+cAgencia+"' AND EF_CONTA='"+cConta+"' AND EF_STATUS='00' AND EF_LIBER='S' "
			cQrySEF	+="AND D_E_L_E_T_ = '' ORDER BY EF_CART,EF_TALAO,EF_PREFIXO,EF_NUM "
			cQrySEF	:= ChangeQuery(cQrySEF)
		#ELSE
			cQrySEF	:=	SEF->EF_FILIAL==xFILIAL("SEF") .AND. SEF->EF_CART=='P' .AND. SEF->EF_BANCO==cBanco .AND. SEF->EF_AGENCIA==cAgencia .AND. ;
							SEF->EF_CONTA==cConta .AND. SEF->EF_STATUS=='00' .AND. SEF->EF_LIBER='S'
		#ENDIF
		dbUseArea(.F., "TOPCONN", TCGenQry(,,cQrySEF), "TMPSEF", .T., .T.)
		DbSelectArea("TMPSEF")
		TMPSEF->(DbGoTop())
		nXrec := 0
		While !TMPSEF->(EOF())
		   	nRecnoSEF	:=	TMPSEF->R_E_C_N_O_
		   	TMPSEF->(DbGoTo(nRecnoSEF))
		   	If !EMPTY(TMPSEF->EF_TALAO) .and. !EMPTY(TMPSEF->EF_NUM) .and. TMPSEF->EF_STATUS=="00" .and. TMPSEF->EF_LIBER=="S" //.and. TMPSEF->(DbRlock(nRecnoSEF))
	   			If nXRec<=Len(aCtrChEQU)
	   				aCtrChEQU[(nXRec+1)][1]:=nRecnoSEF
	   				aCtrChEQU[(nXRec+1)][2]:=TMPSEF->EF_NUM
					nXRec++
					If 	nXRec=Len(aCtrChEQU)
						lLckSEF := .T.
						Exit
		   			Endif
	   			Endif
	   		Endif
	   		TMPSEF->(DbSkip())
	   	Enddo
	   	If 	!lLckSEF
		   	If 	Len(aCtrChEQU)>1
		   		MsgAlert(STR0225) //"Nใo ha quantidade suficiente de cheques disponiveis para os pagamentos!"
		   		SEF->(MsUnlock())
		   	Else
			   	MsgAlert(STR0226) //"Nใo foi encontrado cheque disponivel para este pagamento!"
	     	Endif
		   	TMPSEF->(DbCloseArea())
		   	lRet:=.F.
   	   	Endif
	   	DbSelectArea(cTMPSEF)
	Endif
Endif
If lRet
	lRet:=lRetCkPG(1,cDebInm,SA6->A6_COD,nPagar)
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850FldOk1บAutor ณBruno Sobieski      บ Data ณ  10/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a digitacao do campo  e o total para a nova moeda dgiบฑฑ
ฑฑบ          ณ tada.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850FldOk1(bRecalc)
Local cCampo		:= ReadVar()
Local nPos 		:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])==Alltrim(Substr(cCampo,4))})
Local nPosTipE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_TIPO"   })
Local nPosMoeE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_MOEDA"  })
Local nPosPagE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_PAGAR"  })
Local nPosSalE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_SALDO"  })
Local nPosMulE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_MULTA"  })
Local nPosJurE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_JUROS"  })
Local nPosDesE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_DESCONT"})
Local nPosValE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_VALOR"  })
Local nPosVlMod	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="NVLMDINF"  })
Local lRet			:= .T.
Local nSigno		:= 0
Local nX			:= 0

//Zerar descontos de cabecalho quando se modifica alguma campo de valor da linha
If (Alltrim(oGetDad0:aHeader[nPos][2]) == "E2_PAGAR" .Or. AllTrim(oGetDad0:aHeader[nPos][2]) == "E2_JUROS" .Or. AllTrim(oGetDad0:aHeader[nPos][2]) == "E2_MULTA" .Or. AllTrim(oGetDad0:aHeader[nPos][2]) = "E2_DESCONT") 
	nValDesc	:=	0
	nPorDesc	:=	0
	For nX:=1	To	Len(oGetDad0:aCols)//Zerar somente o desconto da linha corrente.
		If nX == N
		DO CASE
		CASE Alltrim(cCampo) $"M->E2_PAGAR" .and. cPaisLoc =="ARG"
			oGetDad0:aCols[nX][nPosPagE2]:= M->E2_PAGAR
			nValPagar := M->E2_PAGAR
		CASE Alltrim(cCampo) $"M->E2_JUROS" .and. cPaisLoc =="ARG"
			oGetDad0:aCols[nX][nPosJurE2]:= M->E2_JUROS	
		CASE Alltrim(cCampo) $"M->E2_MULTA" .and. cPaisLoc =="ARG"
			oGetDad0:aCols[nX][nPosMulE2]:= M->E2_MULTA
		CASE Alltrim(cCampo) $"M->E2_DESCONT" .and. cPaisLoc =="ARG"
			oGetDad0:aCols[nX][nPosDesE2]:= M->E2_DESCONT
		ENDCASE
		
		oGetDad0:aCols[nX][nPosVlMod] := Round(xMoeda(oGetDad0:aCols[nX][nPosPagE2],oGetDad0:aCols[nX][nPosMoeE2],nMoedaCor,,5,aTxMoedas[oGetDad0:aCols[n][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Else
			nValDesc += oGetDad0:aCols[nX][nPosDesE2]
		Endif
	Next nX
	If Empty(nValPagar)
		nValPagar := oGetDad0:aCols[n][nPosPagE2]
	Endif	
Endif
If	oGetDad0:aCols[n][nPosTipE2]	$	MV_CPNEG+"/"+MVPAGANT
	//Se o titulo diminui do valor total, so posso editar o campo E2_PAGAR
	If (oGetDad0:aHeader[nPos][2] == "E2_DESCONT" .Or. 	Trim(oGetDad0:aHeader[nPos][2]) == "E2_JUROS" .Or. Trim(oGetDad0:aHeader[nPos][2]) == "E2_MULTA" )
		lRet	:=	.F.
	Else
		nValLiq := 0
		oGetDad0:aCols[n][nPosSalE2]+= oGetDad0:aCols[n][nPosPagE2]  
		oGetDad0:aCols[n][nPosSalE2]-= oGetDad0:aCols[n][nPosPagE2]
		Aeval(oGetDad0:aCols,{|x,y|,Iif(oGetDad0:aCols[y][nPosTipE2] $	MV_CPNEG+"/"+MVPAGANT,nValLiq -= Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)),nValLiq += Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))})
	Endif
Else
	nSigno	:=	IIf(oGetDad0:aHeader[nPos][2] == "E2_DESCONT",-1,1)

	If nSigno < 0
		If (aPagar[n] - &(cCampo)) < 0
			Help("",1,"DESC>SALDO")
			lRet	:=	.F.
		Else
			nValDesc 	+=	Round(xMoeda(&(cCampo)-oGetDad0:aCols[n][nPos],oGetDad0:aCols[n][nPosMoeE2],nMoedaCor,,5,aTxMoedas[oGetDad0:aCols[n][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			//Zerar o percentagem de desconto pois o desconto comeca a ser individual (Nota por Nota)...
			nPorDesc	:=	0
			oGetDad0:aCols[n][nPosPagE2] := (nValPagar + oGetDad0:aCols[n][nPosJurE2] + oGetDad0:aCols[n][nPosMulE2]) - (M->E2_DESCONT)
			If oGetDad0:aCols[n][nPosPagE2] < 0
				oGetDad0:aCols[n][nPosSalE2] := oGetDad0:aCols[n][nPosSalE2] + oGetDad0:aCols[n][nPosPagE2]
				oGetDad0:aCols[n][nPosPagE2] := 0
			EndIf
			oGetDad0:aCols[n][nPosVlMod] := Round(xMoeda(oGetDad0:aCols[n][nPosPagE2],oGetDad0:aCols[n][nPosMoeE2],nMoedaCor),MsDecimais(nMoedaCor))

			nValLiq := 0
			Aeval(oGetDad0:aCols,{|x,y|,Iif(oGetDad0:aCols[y][nPosTipE2] $	MV_CPNEG+"/"+MVPAGANT,nValLiq -= Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)),nValLiq += Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))})
			nValLiq	+=	nValDesp
		Endif
	Else
		//Atualizar oGetDad0:aCols , antes de acabar a validacao, para que seja recalculado o desconto
		//de acordo com a Porcentagem do cabe็alho
		If Alltrim(cCampo) $"M->E2_PAGAR|M->NVLMDINF"
			If Alltrim(cCampo)== "M->E2_PAGAR"
				nDiff	:=	Round(xMoeda(M->E2_PAGAR ,oGetDad0:aCols[n][nPosMoeE2]	,nMoedaCor	,,5,aTxMoedas[oGetDad0:aCols[n][nPosMoeE2]][2],	aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))-;
				Round(xMoeda(oGetDad0:aCols[n][1]	,oGetDad0:aCols[n][nPosMoeE2]	,nMoedaCor	,,5,aTxMoedas[oGetDad0:aCols[n][nPosMoeE2]][2],	aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Else
				nDiff	:=	M->NVLMDINF-oGetDad0:aCols[n][nPosVlMod]
			EndIf
			nValBrut	+= nDiff
			oGetDad0:aCols[n][nPosSalE2]-= (aPagar[n] + oGetDad0:aCols[n][nPosJurE2] + oGetDad0:aCols[n][nPosMulE2]) - (oGetDad0:aCols[n][nPosPagE2] + oGetDad0:aCols[n][nPosDesE2])
			oGetDad0:aCols[n][nPosPagE2]:= Iif(Alltrim(cCampo)== "M->E2_PAGAR",M->E2_PAGAR,oGetDad0:aCols[n][nPosPagE2])
			oGetDad0:aCols[n][nPosSalE2]+= (aPagar[n]+ oGetDad0:aCols[n][nPosJurE2]+ oGetDad0:aCols[n][nPosMulE2]) - (oGetDad0:aCols[n][nPosPagE2] + oGetDad0:aCols[n][nPosDesE2])
		ElseIf cCampo == "M->E2_JUROS"
			oGetDad0:aCols[n][nPosPagE2] := (nValPagar + M->E2_JUROS + oGetDad0:aCols[n][nPosMulE2]) - (oGetDad0:aCols[n][nPosDesE2])
			oGetDad0:aCols[n][nPosVlMod] := Round(xMoeda(oGetDad0:aCols[n][nPosPagE2],oGetDad0:aCols[n][nPosMoeE2],nMoedaCor),MsDecimais(nMoedaCor))
			nDiff	:=	Round(xMoeda(&(cCampo)		,oGetDad0:aCols[n][nPosMoeE2]	,nMoedaCor	,,5,aTxMoedas[oGetDad0:aCols[n][nPosMoeE2]][2],	aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))-;
			Round(xMoeda(oGetDad0:aCols[n][nPos]	,oGetDad0:aCols[n][nPosMoeE2]	,nMoedaCor	,,5,aTxMoedas[oGetDad0:aCols[n][nPosMoeE2]][2],	aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			nValBrut	+=	nDiff
		ElseIf cCampo == "M->E2_MULTA"
			oGetDad0:aCols[n][nPosPagE2] := (nValPagar + oGetDad0:aCols[n][nPosJurE2] + M->E2_MULTA) - (oGetDad0:aCols[n][nPosDesE2])
			nDiff	:=	Round(xMoeda(&(cCampo)		,oGetDad0:aCols[n][nPosMoeE2]	,nMoedaCor	,,5,aTxMoedas[oGetDad0:aCols[n][nPosMoeE2]][2],	aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))-;
			Round(xMoeda(oGetDad0:aCols[n][nPos]	,oGetDad0:aCols[n][nPosMoeE2]	,nMoedaCor	,,5,aTxMoedas[oGetDad0:aCols[n][nPosMoeE2]][2],	aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			oGetDad0:aCols[n][nPosVlMod] := Round(xMoeda(oGetDad0:aCols[n][nPosPagE2],oGetDad0:aCols[n][nPosMoeE2],nMoedaCor),MsDecimais(nMoedaCor))
			nValBrut	+=	nDiff
		EndIf
		If oGetDad0:aCols[n][nPosPagE2] < 0
			oGetDad0:aCols[n][nPosSalE2] := oGetDad0:aCols[n][nPosSalE2] + oGetDad0:aCols[n][nPosPagE2]
			oGetDad0:aCols[n][nPosPagE2] := 0
		EndIf
		nValLiq := 0
		Aeval(oGetDad0:aCols,{|x,y|,Iif(oGetDad0:aCols[y][nPosTipE2] $	MV_CPNEG+"/"+MVPAGANT,nValLiq -= Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)),nValLiq += Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))})
		nValLiq	+=	nValDesp
	EndIf
Endif

If lRet
	If (Alltrim(oGetDad0:aHeader[nPos][2]) $ "E2_DESCONT,E2_JUROS,E2_MULTA" )
		oGetDad0:Cargo := AllTrim(oGetDad0:aHeader[nPos][2]) + "|" + AllTrim(Str(&(ReadVar())))
	Endif
	Eval(bRecalc)
Endif
oValDesc:Refresh()
oPorDesc:Refresh()
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850FldOk2บAutor ณBruno Sobieski      บ Data ณ  10/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a digitacao dos itens do aCols do pagamento diferenciบฑฑ
ฑฑบ          ณ ado de Ordens de Pago                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850FldOk2(lPA)

Local aAreaFJS	:= {}

Local cCampo	:=	ReadVar()
Local nPos 	:=	Ascan(oGetDad1:aHeader,{ |x| Alltrim(x[2])=="EK_TIPO"})
Local nPosTp 	:=	Ascan(oGetDad1:aHeader,{ |x| Alltrim(x[2])=="EK_TIPO"})
Local nPosVlr 	:=	Ascan(oGetDad1:aHeader,{ |x| Alltrim(x[2])=="EK_VALOR"})
Local nPosBco 	:=	Ascan(oGetDad1:aHeader,{ |x| Alltrim(x[2])=="EK_BANCO"})
Local nPosAge 	:=	Ascan(oGetDad1:aHeader,{ |x| Alltrim(x[2])=="EK_AGENCIA"})
Local nPosCta	:=	Ascan(oGetDad1:aHeader,{ |x| Alltrim(x[2])=="EK_CONTA"})
Local lRet		:=	.T.
Local nMoeda	:=	1

Default lPA	:= .F.

nPosMoeda := Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2])=="EK_MOEDA"})
nPosMPgto := Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2])=="MOEDAPGTO"})

If lPa
	If lRet .and. cPaisLoc$"DOM|COS"
		If lRet .and. cCampo == "M->EK_TIPO"
			If RTRIM(M->EK_TIPO) == "EF" .and. oGetDad1:aCols[n][nPosVlr] >= nFinLmCH
				Help(" ",1,"HELP",STR0229,STR0230,1,0)//"F850 - LIMITE ITF","Pagamento disponivel apenas com Cheque ou Transfer๊ncia Bancแria."
				lRet:=.F.
			Endif
			If lRet .and. RTRIM(M->EK_TIPO) == "EF" .and. !Empty(oGetDad1:aCols[n][nPosBco])
				If !(oGetDad1:aCols[n][nPosBco] $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")) .or. !IsCaixaLoja(oGetDad1:aCols[n][nPosBco]))
					MsgAlert(STR0215+oGetDad1:aCols[n][nPosBco]+STR0231)  //" nใo recebe lan็amento do tipo EF."
					lRet:=.F.
				Endif
			Endif
		Endif
		If lRet .and. cCampo == "M->EK_VALOR"
			If M->EK_VALOR >= nFinLmCH .and. Rtrim(oGetDad1:aCols[n][nPosTp]) == "EF"
				Help(" ",1,"HELP",STR0229,STR0230,1,0) //"F850 - LIMITE ITF","Pagamento disponivel apenas com Cheque ou Transfer๊ncia Bancแria."
				lRet:=.F.
			Endif
		Endif
		If lRet .and. cCampo == "M->EK_BANCO"
			If !Empty(M->EK_BANCO) .and.  !(M->EK_BANCO $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")) .or. IsCaixaLoja(M->EK_BANCO))
				If Rtrim(oGetDad1:aCols[n][nPosTp]) == "EF"
					MsgAlert(STR0215+M->EK_BANCO+STR0231) //" nใo recebe lan็amento do tipo EF."
					lRet:=.F.
				Endif
			Endif
		Endif
	Endif
	If lRet	.And. !Empty(oGetDad1:aCols[n][nPos])
		If (cCampo $ "M->EK_VALOR|M->NPORVLRPG") .And. !Empty( oGetDad1:aCols[n][nPosMoeda])
			F850SalPa(Iif(lPa,Nil,oSaldo)	,lPa)

		ElseIf cCampo == "M->EK_TIPO"
			//Valida o Movimento de tipo Outros Projeto: M11.7CTR01 Requisito: 1421.5
			lRet := FA850TpBco(M->EK_TIPO,oGetDad1:aCols[n][nPosBco],oGetDad1:aCols[N][nPosAge],oGetDad1:aCols[N][nPosCta],.T.)

		ElseIf cCampo == "M->EK_BANCO"	.And. SA6->A6_COD==&(cCampo)
			nMoeda	:=	 Iif(SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
			nMoeBan := Iif(SA6->(ColumnPos("A6_MOEDAP")) > 0 .And. SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
			oGetDad1:aCols[n][nPosMoeda]	:=	Alltrim(Str(MAX(nMoeBan,1)))
			F850SalPa(Iif(lPa,Nil,oSaldo)	,lPa)

			//Verifica se a moeda do banco eh a mesma da solicitacao de fundo
			If lRet .And. lSolicFundo
			    If !Empty(cSolFun)
					If GetAdvFVal("FJA","FJA_MOEDA",xFilial("FJA")+cSolFun,4,"",.T.) != STRZERO(nMoeBan,TamSX3("FJA_MOEDA")[1])
						lRet:=.F.
						Help(" ",1,"HELP",,STR0344,1,0) //"Moeda do banco divergente da solicitacao de fundo"
					EndIf
				EndIf
			EndIf

			//Valida o Movimento de tipo Outros Projeto: M11.7CTR01 Requisito: 1421.5
			lRet := FA850TpBco(oGetDad1:aCols[n][nPosTp],M->EK_BANCO,oGetDad1:aCols[N][nPosAge],oGetDad1:aCols[N][nPosCta],.T.)

		ElseIf cCampo == "M->EK_AGENCIA"
			//Valida o Movimento de tipo Outros Projeto: M11.7CTR01 Requisito: 1421.5
			lRet := FA850TpBco(oGetDad1:aCols[n][nPosTp],oGetDad1:aCols[n][nPosBco],M->EK_AGENCIA,oGetDad1:aCols[N][nPosCta],.T.)

		ElseIf cCampo == "M->EK_CONTA"
			//Valida o Movimento de tipo Outros Projeto: M11.7CTR01 Requisito: 1421.5
			lRet := FA850TpBco(oGetDad1:aCols[n][nPosTp],oGetDad1:aCols[n][nPosBco],oGetDad1:aCols[N][nPosAge],M->EK_CONTA,.T.)

		Endif
	Endif
Else
	If lRet .and. cPaisLoc$"DOM|COS"
		If lRet .and. cCampo == "M->EK_TIPO"
			If RTRIM(M->EK_TIPO) == "EF" .and. oGetDad1:aCols[n][nPosVlr] >= nFinLmCH
				Help(" ",1,"HELP",STR0229,STR0230,1,0) //"F850 - LIMITE ITF","Pagamento disponivel apenas com Cheque ou Transfer๊ncia Bancแria."
				lRet:=.F.
			Endif
			If lRet .and. RTRIM(M->EK_TIPO) == "EF" .and. !Empty(oGetDad1:aCols[n][nPosBco])
				If !(oGetDad1:aCols[n][nPosBco] $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")) .or. !IsCaixaLoja(oGetDad1:aCols[n][nPosBco]))
					MsgAlert(STR0215+oGetDad1:aCols[n][nPosBco]+STR0231) //" nใo recebe lan็amento do tipo EF."
					lRet:=.F.
				Endif
			Endif
		Endif
		If lRet .and. cCampo == "M->EK_VALOR"
			If M->EK_VALOR >= nFinLmCH .and. Rtrim(oGetDad1:aCols[n][nPosTp]) == "EF"
				Help(" ",1,"HELP",STR0229,STR0230,1,0)//"F850 - LIMITE ITF","Pagamento disponivel apenas com Cheque ou Transfer๊ncia Bancแria."
				lRet:=.F.
			Endif
		Endif
		If lRet .and. cCampo == "M->EK_BANCO"
			If !Empty(M->EK_BANCO) .and.  !(M->EK_BANCO $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")) .or. IsCaixaLoja(M->EK_BANCO))
				If Rtrim(oGetDad1:aCols[n][nPosTp]) == "EF"
					MsgAlert(STR0215+M->EK_BANCO+STR0231) //" nใo recebe lan็amento do tipo EF."
					lRet:=.F.
				Endif
			Endif
		Endif
	Endif
	If lRet
		If cCampo	==	"M->EK_VALOR" .And. !Empty( oGetDad1:aCols[n][nPosMoeda])
			F850Saldos(oGetDad1:aCols[n][nPosVlr],	Val(oGetDad1:aCols[n][nPosMoeda]), 1,,lPa)
			oGetDad1:aCols[n][nPosVlr]	:=	&(cCampo)
			F850Saldos(oGetDad1:aCols[n][nPosVlr],	Val(oGetDad1:aCols[n][nPosMoeda]), -1,,lPa)

		ElseIf cCampo == "M->EK_TIPO"
			//Valida o Movimento de tipo Outros Projeto: M11.7CTR01 Requisito: 1421.5
				lRet := FA850TpBco(M->EK_TIPO,oGetDad1:aCols[n][nPosBco],oGetDad1:aCols[N][nPosAge],oGetDad1:aCols[N][nPosCta],.T.)

		ElseIf cCampo == "M->EK_BANCO"	.And. SA6->A6_COD==&(cCampo)
			F850Saldos(oGetDad1:aCols[n][nPosVlr], Val(	oGetDad1:aCols[n][nPosMoeda]), 1,,lPa)
			lRet := CarregaSA6(M->EK_BANCO,oGetDad1:aCols[N][nPosAge],oGetDad1:aCols[N][nPosConta],.T.)
			nMoeda	:=	Iif( SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
			nMoeBan := Iif(SA6->(ColumnPos("A6_MOEDAP")) > 0 .And. SA6->A6_MOEDAP>0, SA6->A6_MOEDAP, SA6->A6_MOEDA)
			oGetDad1:aCols[n][nPosMoeda]	:=	Alltrim(Str(MAX(nMoeBan,1)))
			F850Saldos(oGetDad1:aCols[n][nPosVlr],	Val(oGetDad1:aCols[n][nPosMoeda]), -1,,lPa)

			//Valida o Movimento de tipo Outros Projeto: M11.7CTR01 Requisito: 1421.5
			If lRet
				lRet := FA850TpBco(oGetDad1:aCols[n][nPosTp],M->EK_BANCO,oGetDad1:aCols[N][nPosAge],oGetDad1:aCols[N][nPosCta],.T.)
		  	EndIf
			
			If cPaisLoc $ "ARG"
				lRet := !CCBLOCKED(M->EK_BANCO,aCols[n][nPosAge],aCols[n][nPosCta])
				
				If !lRet
					aCols[n][nPosBco]:=	Space(TamSx3("EK_BANCO")[1])
					aCols[n][nPosAge]	:=	Space(TamSx3("EK_AGENCIA")[1])
					aCols[n][nPosCta]	:=	Space(TamSx3("EK_CONTA")[1])
				EndIf
								
			EndIf
			
		ElseIf cCampo == "M->EK_AGENCIA"	.And. sA6->A6_AGENCIA==&(cCampo)
			F850Saldos(oGetDad1:aCols[n][nPosVlr], Val(	oGetDad1:aCols[n][nPosMoeda]), 1,,lPa)
			lRet := CarregaSA6(oGetDad1:aCols[N][nPosBanco],M->EK_AGENCIA,oGetDad1:aCols[N][nPosConta],.T.)
			nMoeda	:=	Iif( SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
			oGetDad1:aCols[n][nPosMoeda]	:=	Alltrim(Str(MAX(nMoeda,1)))
			F850Saldos(oGetDad1:aCols[n][nPosVlr],	Val(oGetDad1:aCols[n][nPosMoeda]), -1,,lPa)

			//Valida o Movimento de tipo Outros Projeto: M11.7CTR01 Requisito: 1421.5
			lRet := FA850TpBco(oGetDad1:aCols[n][nPosTp],oGetDad1:aCols[n][nPosBco],M->EK_AGENCIA,oGetDad1:aCols[N][nPosCta],.T.)

			If cPaisLoc $ "ARG"
				lRet := !CCBLOCKED(aCols[n][nPosBco],M->EK_AGENCIA,aCols[n][nPosCta]) 
				If !lRet
					aCols[n][nPosAge]:=	Space(TamSx3("EK_BANCO")[1])
					aCols[n][nPosAge]	:=	Space(TamSx3("EK_AGENCIA")[1])
					aCols[n][nPosCta]	:=	Space(TamSx3("EK_CONTA")[1])
				EndIf
			EndIf


		ElseIf cCampo == "M->EK_CONTA"	.And. SA6->A6_NUMCON==&(cCampo)
			F850Saldos(oGetDad1:aCols[n][nPosVlr], Val(	oGetDad1:aCols[n][nPosMoeda]), 1,,lPa)
			lRet := CarregaSA6(oGetDad1:aCols[N][nPosBanco],oGetDad1:aCols[N][nPosAge],M->EK_CONTA,.T.)
			nMoeda	:=	Iif(SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
			oGetDad1:aCols[n][nPosMoeda]	:=	Alltrim(Str(MAX(nMoeda,1)))
			F850Saldos(oGetDad1:aCols[n][nPosVlr],	Val(oGetDad1:aCols[n][nPosMoeda]), -1,,lPa)

			//Valida o Movimento de tipo Outros Projeto: M11.7CTR01 Requisito: 1421.5
			lRet := FA850TpBco(oGetDad1:aCols[n][nPosTp],oGetDad1:aCols[n][nPosBco],oGetDad1:aCols[N][nPosAge],M->EK_CONTA,.T.)

			If cPaisLoc $ "ARG"
				lRet := !CCBLOCKED(aCols[n][nPosBco],aCols[n][nPosAge],M->EK_CONTA) 
				If !lRet
					aCols[n][nPosAge]:=	Space(TamSx3("EK_BANCO")[1])
					aCols[n][nPosAge]	:=	Space(TamSx3("EK_AGENCIA")[1])
					aCols[n][nPosCta]	:=	Space(TamSx3("EK_CONTA")[1])
				EndIf
			EndIf
		Endif
	Endif
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850RecalบAutor  ณBruno Sobieski      บ Data ณ  10/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRecalcula as retencoes                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850Recal(aSE2,aRateioGan, lOPRotAut)
Local nPosJuros
Local nPosDesc
Local aTmp			:= {}
Local aConGan		:= {}
Local aSE2Tmp		:= {}
Local cFornece		:= ""
Local cLoja		:= ""
Local lNewOp 		:= .T.
Local aValZona		:= {}
Local cZona    	:= ""
Local nA		:= 0
Local nP		:= 0
Local nZ		:= 0
Local nX		:= 0
Local nY		:= 0
Local nI		:= 0
Local nM		:= 0
Local nT        := 0
Local nVlrAux		:= 0
Local nPosSep		:= 0
Local cCpo			:= ""
Local nPropImp		:= 1
Local nProp		:= 1
Local lMonotrb 	:= .F.
Local lCalcIVA	:= .T.
Local lReIvSU  	:= (cPaisLoc == "ARG" .and. GetNewPar("MV_RETIVA","N") == "S" .and. GetNewPar("MV_RETSUSS","N") == "S")
Local nValPag  	:= 0
Local nOldIVA  	:= 0
Local nTotImp 		:= 0
Local nTotSuss		:= 0
Local nImpAux		:= 0
Local nRedut		:= 1/(10^MsDecimais(nMoedaCor)) //valor redutor - diferen็a de centavos
Local nBaseSUSS 	:= 0
Local aImpCalc		:= {}
Local aSUSS		:= {}
Local aTmpIB		:= {}
Local nTTit		:=0
Local lSUSSPrim := .F.
Local lIIBBTotal 	:= .F.
Local nRetTot 	:= 0
Local aIBAcum 	:= {}
Local lCalIBPar 	:= .T.
Local lCalIBTot 	:= .T.
Local nPosIIBB 	:= 0
Local nTotOP 		:= 0
Local nTotBasAnt := 0
Local nTotRetAnT := 0
Local nPosTipo	:= 0 
Local nPosPagE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_PAGAR"  })
Local nPosDesE2	:= Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_DESCONT"})
Local aSLIMIN := {} 
Local nf:=0
Local nTotSus := 0
Local nMinSus := 0
Local aLimSus := {} 
Local cForSus := ""
Local cLojSus := ""
Local nSumPag := 0
Local nPagoT  :=0

Default lOPRotAut	:= .F.
lModPA				:= .F.

If !lOPRotAut
	aSE2Tmp		:= aClone(aSE2[oLbx:nAt])
	nPosJuros		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_JUROS"})
	nPosDesc		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_DESCONT"})
	nPosTipo		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_TIPO"})
Else
	aSE2Tmp		:= aClone(aSE2[1])
EndIf

cFornece 		:= aSE2Tmp[1][1][_FORNECE]
cLoja 			:= aSE2Tmp[1][1][_LOJA]

//Verifica se o fornecedor e monotributista
dbSelectArea("SA2")
dbGoTop()
dbSetOrder(1)
If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
	SE2->(DbGoTo(aSE2Tmp[1][1][_RECNO]))
	SA2->(MsSeek(SE2->E2_MSFIL+cFornece+cLoja))
Else
	SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja))
Endif
If SA2->(Found())
	lMonotrb := Iif(SA2->A2_TIPO == "M" .And. cPaisLoc $ "ARG" ,.T.,.F.)
Endif
ProcRegua(Len(aSE2Tmp))
DbSelectArea("SE2")
nTotVL:=0
nTotPA:=0
nTotNF:=0
aTotIva:={}
If lRetPA == Nil
	lRetPA := (GetNewPar("MV_RETPA","N") == "S")
EndIf
If Type("nValDesc")=="U"
	nValDesc:=0
EndIf
If lRetPa .And. cPaisLoc == "ARG" .And. Type("oGetDad0:aCols")<>"U" .And. !lMonotrb .And. !lOPRotAut
	For ni:=1 to len(oGetDad0:aCols)
		If (oGetDad0:aCols[ni][nPosTipo]$ (MVPAGANT + "/"+ MV_CPNEG))
			nTotPA += oGetDad0:aCols[ni][1]
		Else
			nTotNF += oGetDad0:aCols[ni][1]
		EndIf
	Next
	nPropImp:= (nTotNF-nTotPA)/nTotNF
EndIf

aImpCalc := ARRAY(Len(aSE2Tmp[1]),0)
For nA:=1	To	Len(aSE2Tmp[1])
	SE2->(MsGoto(aSE2Tmp[1][nA][_RECNO]))

	If !lOPRotAut
		_nJuros := If(nPosJuros > 0, oGetDad0:aCols[nA][nPosJuros],0)
		_nDescont := If(nPosDesc > 0, oGetDad0:aCols[nA][nPosDesc],0)
		If !Empty(oGetDad0:Cargo)
			nPosSep := AT("|",oGetDad0:Cargo)
			If nPosSep > 0
				cCpo := Alltrim(Substr(oGetDad0:Cargo,1,nPosSep - 1))
				nVlrAux := Val(Alltrim(Substr(oGetDad0:Cargo,nPosSep + 1)))
				nPosSep := AT("_",cCpo)
				cCpo := "_n" + Substr(cCpo,nPosSep + 1)
				&(cCpo) := nVlrAux
			Endif
		Endif
		aSE2Tmp[1][nA][_PAGAR  ]		:= oGetDad0:aCols[nA][1]
		aSE2Tmp[1][nA][_JUROS  ]		:= _nJuros
		aSE2Tmp[1][nA][_DESCONT] 	:= _nDescont
	EndIf

	If SF1->(ColumnPos("F1_LIQGR")) > 0 .And. SF2->(ColumnPos("F2_LIQGR")) > 0
		If F850VerifG(lMsFil, If(lMsFil, SE2->E2_MSFIL, " "), SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_TIPO)
			Loop
		EndIf
	EndIf

	If cPaisLoc == "ARG"
		aArea:=GetArea()
		dbSelectArea("SF1")
		dbSetOrder(1)
		If lMsFil
			nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
			SF1->(dbGoTo(nRecSF1))
		Else
			nRecSF1 := FINBuscaNF(,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
			SF1->(dbGoTo(nRecSF1))
		EndIf
		cChave := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		SD1->(DbSetOrder(1))
		If lMsFil
			SD1->(MsSeek(SF1->F1_MSFIL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		Else
			SD1->(MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		EndIf
		cPrvEnt:=""
		If  cPaisLoc == "ARG" .And. !Empty(SD1->D1_PROVENT)
			cPrvEnt := SD1->D1_PROVENT
		ElseIf  cPaisLoc == "ARG" .And.  !Empty(SF1->F1_PROVENT)
			cPrvEnt := SF1->F1_PROVENT
		EndIf
		RestArea(aArea)
		nRetTot := 0
		//Acumular bases para retencao de ganancias...
		IF lRetPA .Or. !(SE2->E2_TIPO $ MVPAGANT)
			If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
				F850AcRe2(@aConGan,-1,oGetDad0:aCols[nA][nPosPagE2],aRateioGan)
				nTTit:= 2
			Else
				F850AcRet(@aConGan,,oGetDad0:aCols[nA][nPosPagE2],aRateioGan,lMonotrb)
				nTTit:= 1
			Endif
		Endif
		
		If !lMonotrb
			aTmp	:=	ARGRetGN(cAgente,,aConGan,cFornece,cLoja,,lOPRotAut,.F., aSE2Tmp[1][nA][_PAGAR])
		Else
			aTmp	:=	ARGRetGNMnt(cAgente,1,aConGan,cFornece,cLoja,SE2->E2_NUM,SE2->E2_PREFIXO,,nTTit,,lOPRotAut)  
		EndIf		
		aSE2Tmp[2]	:=	ACLONE(aTmp)
		
		For nI := 1 to Len(aTmp)
			aAdd(aImpCalc, {"GAN", aSE2Tmp[2][nI][4]})
			nRetTot += aSE2Tmp[2][nI][4]
		Next
		
		
		//+----------------------------------------------------------------+
		//ฐ Generar las Retenci๓n de IB.                                   ฐ
		//+----------------------------------------------------------------+		
		If lCalIBPar
			aIBAcum := {}
			ReCalAcmIB (@aIBAcum, aSE2Tmp, 1, lMsFil, lRetPA, cAgente, lSUSSPrim, @lIIBBTotal, @aImpCalc, @nRetTot, lOPRotAut)
			lCalIBPar := .F.
		EndIf
		
		If !lIIBBTotal
			nPosIIBB := aScan(aIBAcum, {|xIB| xIB[2] == aSE2Tmp[1][nA]})
			If nPosIIBB > 0
				aSE2Tmp[1][nA][_RETIB] := aClone(aIBAcum[nPosIIBB][3])
			EndIf
		EndIf
		
		//+----------------------------------------------------------------+
		//ฐ Generar las Retenci๓n de IVA.                                  ฐ
		//+----------------------------------------------------------------+

		If cPaisloc == "ARG" .and. (Alltrim(SE2->E2_TIPO) $ MVPAGANT  .or. SA2->A2_AGENRET == "S" ) //GSA
			lCalcIVA := .F.
		Else
			lCalcIVA := .T.
		EndIF
		
		If lCalcIVA .And. !Empty(SE2->E2_PARCELA) .And. cPaisloc == "ARG"
			If !Empty(aSE2Tmp)
				For nf:=1 to Len(aSE2Tmp[1]) 
					If aSE2Tmp[1][nf][1] ==SE2->E2_FORNECE .And.  aSE2Tmp[1][nf][2] == SE2->E2_LOJA .And. aSE2Tmp[1][nf][9] ==SE2->E2_PREFIXO; 
						.And.	aSE2Tmp[1][nf][10]== SE2->E2_NUM .And. aSE2Tmp[1][nf][12]==SE2->E2_TIPO .And.  aSE2Tmp[1][nf][11]<>SE2->E2_PARCELA;
						.And. Len(aSE2Tmp[1][nf][_RETIVA])> 0  
						lCalcIVA:=.F.
					EndIf	  	
				Next nf
			EndIf
		EndIf
			
		If lCalcIVA
			If !lMonotrb
				If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
					aTmp	:=	ARGRetIV2(cAgente,-1,aSE2Tmp[1][nA][_PAGAR ]+ nRetTot,nProp,,,,,,lOPRotAut)
				Else
					nRetTot := xMoeda(nRetTot,1,aSE2TMP[1][1][4],dDataBase,2) 
					aTmp	:=	ArgRetIVA(cAgente,,aSE2Tmp[1][nA][_PAGAR  ],,,,nProp,,nA,,Iif(lReIvSU,aSE2Tmp[1][nA][_PAGAR],0),,,,lOPRotAut)
				Endif
			Endif
		Else
			aSize(aTmp,0)
		Endif 
		If Len(aTmp) > 0 
			aSE2Tmp[1][nA][_RETIVA]	:=aClone(aTmp)
			aTmpIVA	:= aClone(aTmp)

			For nI := 1 to Len(aTmp)
				aAdd(aImpCalc[nA], {"IVA", aSE2Tmp[1][nA][_RETIVA][nI][6]})
				nRetTot += aSE2Tmp[1][nA][_RETIVA][nI][6]
			Next

		Endif
		
		//+----------------------------------------------------------------+
		//ฐ Generar las Retenci๓n de Servicio de Inmueble.                 ฐ
		//+----------------------------------------------------------------+
		If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
			aTmp	:=	ARGRetSL2(cAgente,-1,aSE2Tmp[1][nA][_PAGAR],,,,,lOPRotAut)
		Else
			aTmp	:=	ARGRetSLI(cAgente,,aSE2Tmp[1][nA][_PAGAR],,,,,lOPRotAut)
		Endif
		If Len(aTmp) > 0 
			aSE2Tmp[1][nA][_RETSLI] :=aClone(aTmp)

			For nI := 1 to Len(aTmp)
				aAdd(aImpCalc[nA], {"SLI", aSE2Tmp[1][nA][_RETSLI][nI][6]})
			Next

		Endif
		//+----------------------------------------------------------------+
		//ฐ Generar las Retenci๓n por inspecci๓n de Seguridad e Higiene    ฐ
		//+----------------------------------------------------------------+

		If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
			aTmp	:=	ARGSegF2(cAgente,-1,aSE2Tmp[1][nA][_PAGAR],,,,@aSLIMIN,lOPRotAut)
		Else
			aTmp	:=	ARGSegF1(cAgente,,aSE2Tmp[1][nA][_PAGAR],,,,@aSLIMIN,lOPRotAut)
		Endif
		If Len(aTmp) > 0 
			aSE2Tmp[1][nA][_RETISI] :=aClone(aTmp)

			For nI := 1 to Len(aTmp)
				aAdd(aImpCalc[nA],{"M", aSE2Tmp[1][nA][_RETISI][nI][4]})
			Next

		Endif
	EndIf

	If cPaisLoc == "ANG"
		//+----------------------------------------------------------------+
		//ฐ Retencoes de Imposto sobre Empreitadas	                      ฐ
		//+----------------------------------------------------------------+
		If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
			aTmp	:=	CalcRetRIE(aSE2Tmp[1][nA][_PAGAR ],.T.,-1)
		Else
			aTmp	:=	CalcRetRIE(aSE2Tmp[1][nA][_PAGAR ])
		Endif
		If Len(aTmp) > 0
			aSE2Tmp[1][nA][_RETRIE]	:=aClone(aTmp)
		Endif

	Endif
	
	nValPag += Round(xMoeda(IIF(aSE2Tmp[1][nA][_TIPO] $ MVPAGANT + "/" + MV_CPNEG, -1 * aSE2Tmp[1][nA][_PAGAR], aSE2Tmp[1][nA][_PAGAR]),aSE2Tmp[1][nA][_MOEDA],1,,5,,aTxMoedas[aSE2Tmp[1][nA][_MOEDA]][2]),MsDecimais(1))
	
Next
If cPaisLoc	==	"ARG"
	//Recalcular ganacias
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSoma no nValBrut o valor dos PAs se houverem  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lModPA
		F850AcRe2(@aConGan,1,nValBrut,aRateioGan,.T.)
	ElseIf aSE2Tmp[3] <> Nil.And. aSE2TMP[3][1] ==4 .And. aSE2TMP[3][6] > 0
		F850AcRe2(@aConGan,1,Round(xMoeda(aSE2TMP[3][6],aSE2TMP[3][7],nMoedaCor,,5,aTxMoedas[aSE2TMP[3][7]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)),aRateioGan,.T.)
	EndIf

	//Tratamento para monotributista - Nใo recalculo o imposto - retenho o valor na 1a. oportunidade
	If lMonotrb .And. nRetIva+nRetGan+nRetIB > nValPag

		//Recuperando o valor total em aliquotas para a proporcionaliza็ใo
		//Ganancia
		For nA := 1 to Len (aSE2Tmp[2])
			nTotImp += aSE2Tmp[2][nA][4]
		Next nA

		//IVA
		For nA := 1 to Len(aSE2Tmp[1])
			For nI := 1 to Len(aSE2Tmp[1][nA][_RETIVA])

				nTotImp += aSE2Tmp[1][nA][_RETIVA][nI][4]

			Next nI
		Next nA

		//IB
		For nA := 1 to Len(aSE2Tmp[1])
			For nI := 1 to Len(aSE2Tmp[1][nA][_RETIB])

				nTotImp += aSE2Tmp[1][nA][_RETIB][nI][6]

			Next nI
		Next nA

		//Calculando a proporcionaliza็ใo da Ganancia
		For nA := 1 to Len(aSE2Tmp[2])

			aSE2Tmp[2][nA][5] := Round((nValPag * aSE2Tmp[2][nA][4])/nTotImp,MsDecimais(nMoedaCor)) //Valor a ser retido na baixa
			nImpAux += aSE2Tmp[2][nA][5]

			//Tratamento para possivel diferenca de centavos
			While nImpAux > nValPag
				aSE2Tmp[2][nA][5] -= nRedut
				nImpAux -= nRedut
			Enddo

		Next nA

		//Calculando a proporcionaliza็ใo do IVA
		For nA := 1 to Len(aSE2Tmp[1])
			For nI := 1 to Len(aSE2Tmp[1][nA][_RETIVA])
				If !Empty(aSE2Tmp[1][nA][_RETIVA][nI][4])

					aSE2TMP[1][nA][_RETIVA][nI][6] := Round((nValPag * aSE2Tmp[1][nA][_RETIVA][nI][4])/nTotImp,MsDecimais(nMoedaCor))
					nImpAux += aSE2TMP[1][nA][_RETIVA][nI][6]

					//Tratamento para possivel diferenca de centavos
					While nImpAux > nValPag
						aSE2TMP[1][nA][_RETIVA][nI][6] -= nRedut
						nImpAux -= nRedut
					Enddo

				Endif
			Next nI
		Next nA

		//Calculando a proporcionaliza็ใo do IB
		For nA := 1 to Len(aSE2Tmp[1])
			For nI := 1 to Len(aSE2Tmp[1][nA][_RETIB])
				If !Empty(aSE2Tmp[1][nA][_RETIB][nI][6])

					aSE2TMP[1][nA][_RETIB][nI][5] := Round((nValPag * aSE2Tmp[1][nA][_RETIB][nI][6])/nTotImp,MsDecimais(nMoedaCor))
					nImpAux += aSE2TMP[1][nA][_RETIB][nI][5]

					//Tratamento para possivel diferenca de centavos
					While nImpAux > nValPag
						aSE2TMP[1][nA][_RETIB][nI][5] -= nRedut
						nImpAux -= nRedut
					Enddo

				Endif
			Next nI
		Next nA

	Endif

	//Generar las Retenci๓n de SUSS.
	For nA := 1 to Len(aSE2Tmp[1])
		SE2->(MsGoto(aSE2Tmp[1][nA][_RECNO]))
		If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
			aTmp	:=	ARGRetSU2(cAgente,-1,aSE2Tmp[1][nA][_PAGAR],nProp,aSUSS,aImpCalc,nA,,,,,lOPRotAut)
		Else
			aTmp	:=	ARGRetSUSS(cAgente,,aSE2Tmp[1][nA][_PAGAR],,nProp,aSUSS,aImpCalc,nA,,,,,,,lOPRotAut)
		Endif
		If Len(aTmp) > 0
			aSE2Tmp[1][nA][_RETSUSS] :=aClone(aTmp)

			//Ajuste para o cแlculo de SUSS - conceito 4 - quando mais de 1 tํtulo for selecionado
			For nX := 1 to Len(aTmp)
				aAdd(aSUSS, aTmp[nX])
				aAdd(aImpCalc[nA], {"SUSS", aSE2Tmp[1][nA][_RETSUSS][nX][6]})
			Next nX
		Else
			aSE2Tmp[1][nA][_RETSUSS] :=aClone(aTmp)
		Endif
		aTemp := {}
	Next nA
	lSUSSPrim := .T.
	
	If lIIBBTotal .And. cPaisLoc == "ARG"
		For nA:=1	To	Len(aSE2Tmp[1])
			If lCalIBTot
				aIBAcum := {}
				ReCalAcmIB (@aIBAcum, aSE2Tmp, 1, lMsFil, lRetPA, cAgente, lSUSSPrim, @lIIBBTotal, @aImpCalc, @nRetTot, lOPRotAut)
				lCalIBTot := .F.
			EndIf
			
			nPosIIBB := aScan(aIBAcum, {|xIB| xIB[2] == aSE2Tmp[1][nA]})
			If nPosIIBB > 0
				aSE2Tmp[1][nA][_RETIB] := aClone(aIBAcum[nPosIIBB][3])
			EndIf
		Next nA
	EndIf
Endif

If cPaisLoc == "ARG" .And.  Len(aSuss) > 0

	aSort(aSuss, , , {|x, y| x[11] + x[12] < y[11] + y[12]}) // garanto que o Fornec + loja estejam em sequencia.
	cForSus := aSuss[1][11]
	cLojSus := aSuss[1][12]
	For nI := 1 to Len(aSuss) // Verifico todos os itens gerados no FINRETSUS
		IF cForSus == aSuss[nI][11] .and. cLojSus == aSuss[nI][12]
			nTotSus += aSuss[nI][3] // Soma da base tributavel por Fornec + loja
			nMinSus := aSuss[nI][15] // Valor do minimo tributavel sempre ้ igual pro mesmo Fornec + loja
		Else
			IF nTotSus <= nMinSus 
				aadd(aLimSus,{cForSus,cLojSus}) // Array com todos Fornec + loja que nใo superarm o minimo tributavel
			EndIF
			cForSus := aSuss[nI][11]
			cLojSus := aSuss[nI][12]
			nTotSus := aSuss[nI][3]
			nMinSus := aSuss[nI][15]
		EndIF
	Next nI
	IF ABS(nTotSus) <= nMinSus
		aadd(aLimSus,{cForSus,cLojSus}) //Valida็ใo para o ultimo registro.
	EndIF

	IF Len(aLimSus) > 0 .and. Len(aSe2) > 0  .and. Len(aSe2[1][1]) > 0 
		For nI := 1 to Len(aLimSus) //Caso o array aLimSus esteja maior que zero
			For nY := 1 to Len(aSe2[1][1]) // apago os valores de reten็ใo para os fonecedores que nใo superam o minimo.
				IF aLimSus[nI][1] == aSe2[1][1][nY][1] .and.  aLimSus[nI][2] == aSe2[1][1][nY][2]
					aSe2[1][1][nY][_RETSUSS] := {}
					aSE2Tmp[1][nY][_RETSUSS] := {}
				EndIF
			Next nY			
		Next nI
	EndIF

	cFor := cFornece
	cLojFor    := cLoja 
	nTotOP:= 0    
	lPrimaVez:= .T.
	nTBasAcS:= 0 
	nTotVlvACs:= 0
	nVlrprop:= 0 
	For nY:= 1 To Len(aSuss)
		IF (Alltrim(aSuss[nY][8])=="4" .or. Alltrim(aSuss[nY][8])=="1")
		
			If lPrimaVez .and. (Alltrim(aSuss[nY][8])=="4" .or. Alltrim(aSuss[nY][8])=="1") .And. SFE->(MsSeek(xFilial("SFE")+cFor+cLojFor))
				aAreaSFE:= SFE->(GetArea())
				cChaveSFE := SFE->FE_FILIAL+cFor+cLojFor
				While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
					If Alltrim(aSuss[nY][8])=="4" .and. (!(SFE->FE_TIPO $"U|S") .Or. !Empty(SFE->FE_DTESTOR))
						SFE->(dbSkip())
						Loop
					ElseIf Alltrim(aSuss[nY][8])=="1" .And. (!(SFE->FE_TIPO $"U|S") .Or. !Empty(SFE->FE_DTESTOR))
						SFE->(dbSkip())
						Loop
					EndIf
					
					If  Alltrim(SFE->FE_CONCEPT) $ "1|4" .and. Alltrim(SFE->FE_TIPO)=="S" 
						
						nTBasAcS += SFE->FE_VALBASE	
						nTotVlvACs+= SFE->FE_VALBASE	
															
					Endif
					SFE->(dbSkip())
				EndDo
				lPrimaVez :=.F.
				SFE->(RestArea(aAreaSFE))
			EndIf
		
			nTotOP+= aSuss[nY][3]
		EndIf		   
	Next nY
	If (nTBasAcS + nTotOP) >= nLimiteSUSS   .and.  nTBasAcS <  nLimiteSUSS
		For nX := 1 to Len(aSE2Tmp[1])  
		 	If (aSE2Tmp[1,nX,_TIPO] $ MVPAGANT + "/"+ MV_CPNEG) .And. Len(aSE2Tmp[1,nX,_RETSUSS]) > 0 .And. Alltrim(aSE2Tmp[1,nX,_RETSUSS][1][8]) == '4'
				For nY:= 1 To Len(aSuss)
			 		If aSuss[nY][6] > 0
			 			nTotSuss+= aSuss[nY][6]		   
			 		EndIf
			   Next nY    
				If nTotSuss = 0
					aSE2Tmp[1,nX,_RETSUSS][1][6]:=0
				EndIf
		 	EndIf		 	
		 	If  nTBasAcS >0 .and. Len(aSE2Tmp[1,nX,_RETSUSS]) > 0	 	
				If (aSE2TMP[1][nX][_RETSUSS][1][3] - aSE2TMP[1][nX][_RETSUSS][1][6]  ) >  nTBasAcS
					aSE2TMP[1][nX][_RETSUSS][1][6] := aSE2TMP[1][nX][_RETSUSS][1][6]  + (nTBasAcS * (aSE2TMP[1][nX][_RETSUSS][1][7] /100) )
					nTBasAcS:=0
				Else
					If nx <> Len(aSe2[nX,1])
						nVlrprop:= nTBasAcS -  aSE2TMP[1][nX][_RETSUSS][1][3]
					Else
						nVlrprop:= nTBasAcS
					EndIf
					aSE2TMP[1][nX][_RETSUSS][1][6] := aSE2TMP[1][nX][_RETSUSS][1][6]  + (nVlrprop* (aSE2TMP[1][nX][_RETSUSS][1][7] /100) )
					nTBasAcS-=nVlrprop				 			
				EndIf
			EndIf		 	
		Next nX
	ElseIf  nTBasAcS <  nLimiteSUSS
		For nX := 1 to Len(aSE2Tmp[1]) 
			If Len(aSE2Tmp[1,nX,_RETSUSS]) > 0 .and. Len(aSE2Tmp[1,nX,_RETSUSS][1])>= 6 .and. (Alltrim(aSE2Tmp[1,nX,_RETSUSS][1][8])=="1" .or. Alltrim(aSE2Tmp[1,nX,_RETSUSS][1][8])=="4")
				aSE2Tmp[1,nX,_RETSUSS][1][6]:=0
			EndIf
		Next nX 	

	EndIf	
EndIF


// Verifica a aplicacao de retencao de ingresos brutos, sobre o total dos pagamentos efetuados.
lNewOp := .T.
If cPaisLoc	==	"ARG"
	For nX := 1 to Len(aSE2Tmp[1])
		If Len(aSE2Tmp[1,nX,_RETIB]) > 0
			For nA := 1 To Len(aSE2Tmp[1,nX,_RETIB])
				If lNewOP
					AAdd(aValZona,{})
					Aadd(aValZona[1],{	aSE2Tmp[1,nX,_RETIB,nA,09],; //Zona Fiscal
					aSE2Tmp[1,nX,_RETIB,nA,03],; //Valor da Retencao
					aSE2Tmp[1,nX,_RETIB,nA,11],; //CFO COMPRA
					aSE2Tmp[1,nX,_RETIB,nA,12]}) //CFO VENDA

					lNewOp := .F.
				Else
					If !Empty(aValZona[1])
						nPosZona := Ascan(aValZona[1],{|x| x[1]==aSE2Tmp[1,nX,_RETIB,nA,9] .And. x[3]==aSE2Tmp[1,nX,_RETIB,nA,11] .And. x[4]==aSE2Tmp[1,nX,_RETIB,nA,12]})
					Else
						AAdd(aValZona,{})
						nPosZona := 0
					EndIf

					If nPosZona == 0
						Aadd(aValZona[1],{	aSE2Tmp[1,nX,_RETIB,nA,09],; //Zona Fiscal
						aSE2Tmp[1,nX,_RETIB,nA,03],; //Valor da Retencao
						aSE2Tmp[1,nX,_RETIB,nA,11],; //CFO COMPRA
						aSE2Tmp[1,nX,_RETIB,nA,12]}) //CFO VENDA
					Else
						aValZona[1][nPosZona][2] += aSE2Tmp[1,nX,_RETIB,nA,03]
					Endif
				EndIf
			Next nA
		Else
			If lNewOP
				AAdd(aValZona,{})
				nPosZona := 0
				lNewOP   := .F.
			Else
				If !Empty(aValZona[1])
					nPosZona := Ascan(aValZona[1],{|x| x[1] == StrZero(Len(aValZona),2)})
				Else
					AAdd(aValZona,{})
					nPosZona := 0
				EndIf
			EndIf

			If nPosZona == 0
				AAdd(aValZona[1],{StrZero(Len(aValZona),2),0,"",""})
			EndIf
		EndIf
	Next nX

	If Len(aValZona) > 0
		For nY = 1 To Len(aValZona[1])			
			SFF->(DbSetOrder(5))
			If SFF->(MsSeek(xFilial()+"IBR"+aValZona[1][nY][3]+aValZona[1][nY][1]))
				If SFF->FF_IMPORTE > 0
					lVerificaSFF:= Iif(SFF->FF_ZONFIS $ "ER",.T.,.F. )
		  			nTotRetAnT := 0
					nTotBasAnt := 0  					
					If  lVerificaSFF  					
						SFE->(dbSetOrder(4))
						If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA))
							cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA
							While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
								If  SFE->FE_EST <> aValZona[1][nY][1] .or. Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
									!(SFE->FE_TIPO $"B")
									SFE->(dbSkip())
									Loop
								EndIf
								nTotRetAnT += SFE->FE_RETENC
								nTotBasAnt += SFE->FE_VALBASE
								SFE->(dbSkip())
							End
						EndIf
					Endif 
					If (aValZona[1][nY][2]+ nTotBasAnt < SFF->FF_IMPORTE) .And. (aValZona[1][nY][2] <> 0  )
						For nZ := 1 To Len(aSE2Tmp[1])
							nA := aScan(aSE2Tmp[1,nZ,_RETIB],{|x| x[11] == aValZona[1][nY][03]})
							If nA > 0
								aSE2Tmp[1,nZ,_RETIB,nA,5] := 0
							EndIf
						Next nZ
					EndIf
				EndIf
			EndIf
		Next nY
	EndIf
Endif

If Len(aSLIMIN) > 0
	For nM	:= 1 To Len (aSLIMIN)
		If aSLIMIN[nM][3] >= F850Mins(aSE2Tmp, _RETISI, aSLIMIN, nM, .F.)
			F850Mins(@aSE2Tmp, _RETISI, aSLIMIN, nM, .T.)
		EndIf
	Next(nM)
EndIf

/*_*/
nRetIva	:= 0
nRetIB	 	:= 0
nRetGan	:= 0
nRetISI	:= 0
nRetIric 	:= 0
nRetIr	 	:= 0
nRetIrc	:= 0
nRetSUSS 	:= 0
nRetSLI  	:= 0
nTotNCC  	:= 0
For nA	:=	1	To	Len(aSE2TMP[1])
	If aSE2TMP[1][nA][_TIPO] $ MVPAGANT + "/" + MV_CPNEG
		nTotNCC += Round(xMoeda(aSE2TMP[1][nA][_PAGAR],aSE2TMP[1][nA][_MOEDA],nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Endif
	If cPaisLoc == "ARG"
		For nP	:=	1	To	Len(aSE2TMP[1][nA][_RETIB])
			nRetib	+=	Round(xMoeda(aSE2TMP[1][nA][_RETIB ][nP][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next
		For nP	:=	1	To	Len(aSE2TMP[1][nA][_RETIVA])
			nRetiva	+=	Round(xMoeda(aSE2TMP[1][nA][_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nP
		For nP	:=	1	To	Len(aSE2TMP[1][nA][_RETSUSS])
			nRetSUSS+=	Round(xMoeda(aSE2TMP[1][nA][_RETSUSS][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nP
		For nP	:=	1	To	Len(aSE2TMP[1][nA][_RETSLI])
			nRetSLI +=	Round(xMoeda(aSE2TMP[1][nA][_RETSLI][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nP
		// Zarate
		For nP	:=	1	To	Len(aSE2TMP[1][nA][_RETISI])
			nRetISI +=	Round(xMoeda(aSE2TMP[1][nA][_RETISI][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nP
	Endif
	//ANGOLA
	If cPaisLoc == "ANG"
		For nP	:=	1	To	Len(aSE2TMP[1][nA][_RETRIE])
			nRetRIE	+=	Round(xMoeda(aSE2TMP[1][nA][_RETRIE ][nP][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next
	Endif
Next nA
If cPaisLoc == "ARG"
	For nP	:=	1	To	Len(aSE2Tmp[2])
		nRetGan	+=	Round(xMoeda(aSE2Tmp[2][nP][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Next nP

	/************************************************************************/
	//Calculo cumulativo de IVA - reten็ใo de documentos que nใo sใo desta OP
	/************************************************************************/
	nRetIva := 0

	For nA := 1 to Len(aSE2TMP[1])
		For nP := 1 to Len(aSE2TMP[1][nA][_RETIVA])
			nRetIVA +=	Round(xMoeda(aSE2TMP[1][nA][_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nP
	Next nA
	
	nRetTot := nRetIva + nRetGan + nRetIB
	If Len(aSE2TMP[1]) > 1 .And. Len(aRetIvAcm)> 1 .And. aRetIvAcm[2] <> Nil .And.  Len(aRetIvAcm[2]) > 0
		For nT := 1 to Len(aSE2TMP[1])
			nPagoT :=  IIF(aSE2TMP[1][nT][_TIPO] $ MVPAGANT + "/" + MV_CPNEG, -1 * aSE2TMP[1][nT][_PAGAR], aSE2TMP[1][nT][_PAGAR])
			nSumPag += Round(xMoeda(nPagoT,aSE2TMP[1][nT][_MOEDA],1,,5,,aTxMoedas[aSE2TMP[1][nT][_MOEDA]][2]),MsDecimais(1))
		Next
	EndIf
	F850DocIVA(cFornece,cLoja,IIF(nSumPag > 0, nSumPag, Round(xMoeda(aSE2TMP[1][1][_PAGAR],aSE2TMP[1][1][_MOEDA],1,,5,,aTxMoedas[aSE2TMP[1][1][_MOEDA]][2]),MsDecimais(1))),nRetTot)
	If aRetIvAcm[3] <> Nil .And. Len(aRetIvAcm)>2 .And. Len(aRetIvAcm[3]) > 0
		For nP := 1 to Len(aRetIvAcm[3])
			nRetIVA +=	Round(xMoeda(aRetIvAcm[3][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nP
	EndIf

	nOldIva := nRetIVA
	nRetIVA := 0
	
	//Proporcionaliza as baixas parciais
	F850PropIV(nValPag,nOldIVA,@aSE2TMP,(nRetGan + nRetIB + nRetSUSS))
	
	//Atualiza o IVA novamente
	For nA := 1 to Len(aSE2TMP[1])
		For nP := 1 to Len(aSE2TMP[1][nA][_RETIVA])
			nRetIVA	+=	Round(xMoeda(aSE2TMP[1][nA][_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nP
	Next nA

	If aRetIvAcm[3] <> Nil .And. Len(aRetIvAcm)>2 .And. Len(aRetIvAcm[3]) > 0
		For nP := 1 to Len(aRetIvAcm[3])
			nRetIVA+=	Round(xMoeda(aRetIvAcm[3][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nP
	EndIf

	nOldIva := 0
	nTotOP	 := nValPag
	nValPag := 0

EndIf

If cPaisLoc == "ARG"
	nTotOP :=  nTotOP - (nRetIva + nRetIB + nRetGan + nRetISI  + nRetSUSS + nRetSLI)
	nValLiq		:= nValBrut - nValDesc - nTotNCC - (nRetIva + nRetIB + nRetGan + nRetISI  + nRetSUSS + nRetSLI)
	//ANGOLA
ElseIf cPaisLoc == "ANG"
	nValLiq		:=	nValBrut - nValDesc - nRetRIE
EndIf

If !lOPRotAut
	aSE2[oLbx:nAt] := aClone(aSE2Tmp)
Else
	aSE2[1] := aClone(aSE2Tmp)
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850Vlds บAutor  ณBruno Sobieski      บ Data ณ  10/17/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacoes da digitacao dos titulos usados para pagar       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850Vlds(aDebMed,aDebInm,lPa)
Local lRet			:= .T.
Local cVar			:= ReadVar()
Local lMoedaP		:= .T.
Local aChq			:= {}
Local nX			:= 0
Local nPosPgto	:= 0

Default  lPa    := .F. 

nPosTipo	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
nPosTpDoc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPODOC"})
nPosNum		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_NUM"})
nPosMoeda	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
nPosMPgto	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})
nPosBanco	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAge		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
nPosTalao	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})
nPosVlr		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})
nPosEmi		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
nPosVcto	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
nPosDeb		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_DEBITO"})
nPosParc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PARCELA"})

If cVar	==	"M->EK_TIPO"
	If Alltrim(oGetDad1:aCols[n][nPosTpDoc]) == "1"	.And. Ascan(aDebMed,Alltrim(M->EK_TIPO)) == 0
		Help( " ",1, "No SES")
		lRet	:=	.F.
	ElseIf Alltrim(oGetDad1:aCols[n][nPosTpDoc]) == "2"	.And. Ascan(aDebInm,Alltrim(M->EK_TIPO)) == 0
		Help( " ",1, "No SES")
		lRet	:=	.F.
	ElseIf 	Empty(oGetDad1:aCols[n][nPosTpDoc])
		Help( " ",1, "TipoDeb")
		lRet	:=	.F.
	Endif
ElseIf cVar == "M->EK_BANCO"	
	If  cPaisloc != "ARG"
		lRet:= CarregaSA6(M->EK_BANCO,oGetDad1:aCols[N][nPosAge],oGetDad1:aCols[N][nPosConta],.T.)      
		If  cPaisLoc == "BRA" .And. SA6->A6_MOEDA > 0
			cMoeda := SA6->A6_MOEDA
		EndIf
	Else
		If  lPa .And. cPaisLoc == "ARG" .And. !lSolicFundo
			If cVar == "M->EK_BANCO"  .and. !Empty(M->EK_BANCO)
				If  !SA6->(MsSeek(xFilial("SA6")+M->EK_BANCO+ oGetDad1:aCols[n][nPosAge]+ oGetDad1:aCols[n][nPosConta]))
					SA6->(MsSeek(xFilial("SA6")+M->EK_BANCO)) //Forzar posicionarse con el primer registro del Banco
				Endif
			EndIf
			lRet := CarregaSA6(M->EK_BANCO,Iif(M->EK_BANCO==SA6->A6_COD,SA6->A6_AGENCIA, ""),Iif(M->EK_BANCO == SA6->A6_COD,SA6->A6_NUMCON,""),.T.)
		Else
			lRet := CarregaSA6(M->EK_BANCO,"","",.T.) 
		Endif 
		If  lRet .And. lPa .And. cPaisLoc == "ARG" .And. !lSolicFundo .And. (SA6->A6_MOEDA != nMoedaTCor) //Opci?n: Generar PA (Validar que el banco sea de la misma moneda)
			Aviso( OemToAnsi(STR0223), OemToAnsi(STR0446) , {'Ok'} )  //"Moneda del banco diferente a la informada."
			lRet := .F.
		Endif   
		If  lRet 
			oGetDad1:aCols[N][nPosAge]		:= Iif(Empty( oGetDad1:aCols[N][nPosAge] ),   SA6->A6_AGENCIA, oGetDad1:aCols[N][nPosAge] )
			oGetDad1:aCols[N][nPosConta]	:= Iif(Empty( oGetDad1:aCols[N][nPosConta] ), SA6->A6_NUMCON, oGetDad1:aCols[N][nPosConta] )   
			If  !SA6->(MsSeek(xFilial("SA6")+M->EK_BANCO+ oGetDad1:aCols[N][nPosAge]+ oGetDad1:aCols[N][nPosConta]))
				 SA6->(MsSeek(xFilial("SA6")+M->EK_BANCO)) //Forzar posicionarse con el primer registro del Banco
				 oGetDad1:aCols[N][nPosAge]   := SA6->A6_AGENCIA
				 oGetDad1:aCols[N][nPosConta] := SA6->A6_NUMCON
			Endif
			
		End
	Endif 	
	//Pagamento Eletronico
	If cPaisLoc == "ARG" .And. cOpcElt == "1"
		lRet := F850VldBco(M->EK_BANCO,oGetDad1:aCols[N][nPosAge],oGetDad1:aCols[N][nPosConta],n)
	EndIf
	// Valida se conta estแ bloqueada
	IF lRet .and. cPaisLoc == "ARG" .And. !Empty(oGetDad1:aCols[N][nPosAge]) .and. !Empty(oGetDad1:aCols[N][nPosConta])
		lRet := !CCBLOCKED(M->EK_BANCO,oGetDad1:aCols[N][nPosAge],oGetDad1:aCols[N][nPosConta]) 
		IF !lRet
			oGetDad1:aCols[N][nPosAge]   := Space(TamSx3("EK_AGENCIA")[1])
			oGetDad1:aCols[N][nPosConta] := Space(TamSx3("EK_CONTA")[1])
			oGetDad1:oBrowse:Refresh()
		EndIf
	EndIF

ElseIf cVar == "M->EK_AGENCIA"
	If  cPaisloc != "ARG"            
		lRet := CarregaSA6(oGetDad1:aCols[N][nPosBanco],M->EK_AGENCIA,oGetDad1:aCols[N][nPosConta],.T.)         
	Else  
		lRet := CarregaSA6(oGetDad1:aCols[N][nPosBanco],M->EK_AGENCIA,"",.T.)
		If  lRet 
			oGetDad1:aCols[N][nPosConta]	:= Iif(Empty( oGetDad1:aCols[N][nPosConta] ), SA6->A6_NUMCON, oGetDad1:aCols[N][nPosConta] )   
			If  !SA6->(MsSeek(xFilial("SA6")+oGetDad1:aCols[N][nPosBanco]+ M->EK_AGENCIA+ oGetDad1:aCols[N][nPosConta]))
				 SA6->(MsSeek(xFilial("SA6")+oGetDad1:aCols[N][nPosBanco]+ M->EK_AGENCIA)) //Forzar posicionarse con el primer registro del Banco
				 oGetDad1:aCols[N][nPosConta] := SA6->A6_NUMCON
			Endif
			
		End
	Endif	
	//Pagamento Eletronico
	If cPaisLoc == "ARG" .And. cOpcElt == "1"
		lRet := F850VldBco(oGetDad1:aCols[N][nPosBanco],M->EK_AGENCIA,oGetDad1:aCols[N][nPosConta],n)
	EndIf
	// Valida se conta estแ bloqueada
	IF lRet .and. cPaisLoc == "ARG" .And. !Empty(oGetDad1:aCols[N][nPosBanco]) .and. !Empty(oGetDad1:aCols[N][nPosConta])
		lRet := !CCBLOCKED(oGetDad1:aCols[N][nPosBanco],M->EK_AGENCIA,oGetDad1:aCols[N][nPosConta]) 
	EndIF

ElseIf cVar == "M->EK_CONTA"	
	lRet:= CarregaSA6(oGetDad1:aCols[N][nPosBanco],oGetDad1:aCols[N][nPosAge],M->EK_CONTA,.T.)
	//Pagamento Eletronico
	If cPaisLoc == "ARG" .And. cOpcElt == "1"
		lRet := F850VldBco(oGetDad1:aCols[N][nPosBanco],oGetDad1:aCols[N][nPosAge],M->EK_CONTA,n)
	EndIf
		// Valida se conta estแ bloqueada
	IF lRet .and. cPaisLoc == "ARG" .And. !Empty(oGetDad1:aCols[N][nPosBanco]) .and. !Empty(oGetDad1:aCols[N][nPosAge])
		lRet := !CCBLOCKED(oGetDad1:aCols[N][nPosBanco],oGetDad1:aCols[N][nPosAge],M->EK_CONTA) 
	EndIF
ElseIf cVar == "M->EK_VENCTO" .And. Type("nPosDeb")=="N" .And.  nPosDeb > 0
	//se alterar a data de vencimento pra uma data menor do que a data base
	//o status de debito na hora eh marcado como 1-"Nao"
	If (Empty(M->EK_VENCTO) .Or. !(M->EK_VENCTO<=dDataBase))
		oGetDad1:aCols[n][nPosDeb]	:= "2"
	Endif
ElseIf cVar == "M->EK_DEBITO"
	//verifica se o tipo de documento e debito mediato, se a data de
	//vencimento e menor do que a data base e se a data de vencimento esta preenchida
	If (nPagar<>4) .Or. (oGetDad1:aCols[n][1]<>"1") .Or. (oGetDad1:aCols[n][7] > dDataBase .Or. Empty(oGetDad1:aCols[n][7]))
		lRet	:=	.F.
	Endif
ElseIf cVar == "M->EK_EMISSAO"
	nPosPgto := Ascan(aFormasPgto,{|x| AllTrim(x[1]) == AllTrim(oGetDad1:aCols[n][nPosTipo])})
	If nPosPgto > 0
		If aFormasPgto[nPosPgto,8] <> "2"
			oGetDad1:aCols[n][nPosVcto]	:= M->EK_EMISSAO
		EndIf
	EndIf
Endif


Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850LnOk บAutor  ณBruno Sobieski      บ Data ณ  10/17/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLinha OK   da digitacao dos titulos usados para pagar       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850LnOK(oSaldo,lPa)
Local lRet		:=	.T.
Local nPosTp	:= 0
Local nPosBc	:= 0
Local lTipo		:= .F.
Local lBanco    := .F.
Default  lPa 	:= .F.
Default oSaldo	:= Nil 

iF cPaisLoc == "ARG" .and. !lAutomato
	nPosBc := Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
	nPosTp := Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
	lBanco := IIF(oGetDad1:Acols[oGetDad1:nAt][nPosBc] == NIL .or. Empty(oGetDad1:Acols[oGetDad1:nAt][nPosBc]), IIF(M->EK_BANCO == NIL .or. Empty(M->EK_BANCO) , .F.,.T.),.T. )
	lTipo := IIF(oGetDad1:Acols[oGetDad1:nAt][nPosTp] == NIL .or. Empty(oGetDad1:Acols[oGetDad1:nAt][nPosTp]), IIF(M->EK_TIPO == NIL .or. Empty(M->EK_TIPO) , .F.,.T.),.T. )
	IF nPosTp > 0 .and. !lTipo .AND. lBanco
		lRet := .F.
		MsgAlert(STR0449)
	EndIF
EndIf

// Ponto de entrada para a valida็ใo do acols
If lRet .And. ExistBlock("F085AVAL")
	lRet:=ExecBlock("F085AVAL",.F.,.F.)	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณF850SaldosบAutor  ณBruno Sobieski      บ Data ณ  10/17/00  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณLinha OK   da digitacao dos titulos usados para pagar       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850Saldos(nValor,nMoeda,nSinal,oSaldo,lPa)
Local nPosMoe		:=	Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
Local nPosValor 	:=	Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})
Local nX
lPa	:=	Iif(lPa==Nil,.F.,lPa)
If lRetPA == Nil
	lRetPA := (GetNewPar("MV_RETPA","N") == "S")
EndIf

aSaldos[nMoeda] += nValor * nSinal
aSaldos[Len(aSaldos)]	+=	Round(xMoeda(nValor,nMoeda,nMoedaCor,,5,aTxMoedas[nMoeda][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)) * nSinal

// Arredonda o total em moeda corrente. (Apresentava msg de saldo insuficiente por problema de arredondamento.) // Guilherme
aSaldos[Len(aSaldos)] := Round(aSaldos[Len(aSaldos)],MsDecimais(nMoedaCor))

If lPa .And. !lRetPA
	nValor	:=	aSaldos[Len(aSaldos)] * nSinal
    oVlrPagar:Refresh()
Endif

If Type("oSaldo")<> "U" .And. oSaldo <> Nil
	oSaldo:Refresh()
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850tuVlบAutor  ณBruno Sobieski      บ Data ณ  10/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o Array do listbox e o total para a nova moeda digiบฑฑ
ฑฑบ          ณ tada.                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850AtuVl(oValOrdens,nValOrdens,aPagos,aSE2)
Local 	nA,nC,nP,nX,nY
Local	lExisPA	:= .F.
Local	nIVSUS	:= 0
Local	lReIvSU	:= (cPaisLoc=="ARG" .and. GetNewPar("MV_RETIVA","N") == "S" .and. GetNewPar("MV_RETSUSS","N") == "S")
Local   nValAct := 0
Local   nValDif := 0
Local   nValTot := 0
nValOrdens	:=	0
nDecs	:=	MsDecimais(nMoedaCor)

//CARREGAR ARRAY PARA USAR NA LISTBOX.
For nA	:=	1	To Len(aSE2)
	//INICIALIZAR ARRAY COM OS DADOS PIRNCIPAIS
	aPagos[nA][H_NCC_PA]	:=	0
	aPagos[nA][H_NF    ]	:=	0
	aPagos[nA][H_TOTALVL]	:=	0
	aPagos[nA][H_VALORIG]	:=	0
	aPagos[nA][H_TOTRET ]	:=	0
	aPagos[nA][H_DESCVL]	:=	0
	If cPaisLoc	==	"ARG"
		aPagos[nA][H_RETIB]  :=	0
		aPagos[nA][H_RETIVA] :=	0
		aPagos[nA][H_RETGAN] :=	0
		aPagos[nA][H_RETSUSS]:=	0
		aPagos[nA][H_RETSLI] :=	0
		aPagos[nA][H_RETISI] :=	0
	//ANGOLA
	ElseIf cPaisLoc	==	"ANG"
		aPagos[nA][H_RETRIE]  :=0
	ElseIf cPaisLoc $ "COS|DOM"
		aPagos[nA][H_TOTRET ] := 0
	Endif
	//CARREGAR COM OS VALORES DE NOTAS PARA SER PAGAS, NNC , PAS, E NO CASO DE ARGENTINA
	//AS RETENCOES DE IMPOSTOS DE IB E IVA.
	For nC	:=	1	To Len(aSE2[nA][1])
  		If aSE2[nA][1][nC][_TIPO] $ MVPAGANT + "/" + MV_CPNEG
  			lExisPA := lReIvSU .and. aSE2[nA][1][nC][_TIPO] $ MVPAGANT
			aPagos[nA][H_NCC_PA]	+= Round(xMoeda(aSE2[nA][1][nC][_PAGAR],aSE2[nA][1][nC][_MOEDA],nMoedaCor,,5,aTxMoedas[aSE2[nA][1][nC][_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		 	aPagos[nA][H_VALORIG]	+= Round(xMoeda(aSE2[nA][1][nC][_PAGAR],aSE2[nA][1][nC][_MOEDA],1,,5,aTxMoedas[aSE2[nA][1][nC][_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Else
			aPagos[nA][H_VALORIG]	+= Round(xMoeda(aSE2[nA][1][nC][_PAGAR]+aSE2[nA][1][nC][_DESCONT],aSE2[nA][1][nC][_MOEDA],1,,5,aTxMoedas[aSE2[nA][1][nC][_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			aPagos[nA][H_NF]		+= Round(xMoeda(aSE2[nA][1][nC][_PAGAR]+aSE2[nA][1][nC][_DESCONT],aSE2[nA][1][nC][_MOEDA],nMoedaCor,,5,aTxMoedas[aSE2[nA][1][nC][_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			aPagos[nA][H_NCC_PA]	+= Round(xMoeda(aSE2[nA][1][nC][_DESCONT],aSE2[nA][1][nC][_MOEDA],nMoedaCor,,5,aTxMoedas[aSE2[nA][1][nC][_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Endif
		If cPaisLoc == "ARG"
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETIB])
				aPagos[nA][H_RETIB]		+= Round(xMoeda(aSE2[nA][1][nC][_RETIB][nP][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETIVA])
				aPagos[nA][H_RETIVA]	+= Round(xMoeda(aSE2[nA][1][nC][_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next 

			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETSUSS])
				aPagos[nA][H_RETSUSS]	+= Round(xMoeda(aSE2[nA][1][nC][_RETSUSS][nP][6],1,nMoedaCor,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETSLI])
				aPagos[nA][H_RETSLI]	+= Round(xMoeda(aSE2[nA][1][nC][_RETSLI][nP][6],1,nMoedaCor,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETISI])
				aPagos[nA][H_RETISI]	+= Round(xMoeda(aSE2[nA][1][nC][_RETISI][nP][6],1,nMoedaCor,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
		//ANGOLA
		ElseIf cPaisLoc == "ANG"
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETRIE])
				aPagos[nA][H_RETRIE]	+= Round(xMoeda(aSE2[nA][1][nC][_RETRIE ][nP][6],1,nMoedaCor,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
		ElseIf cPaisLoc == "EQU"
			For nP	:=	1	To	1
		   		aSE2[nA][1][nC][_RETIR] := SomaAbat(aSE2[nA][1][nC][9],aSE2[nA][1][nC][10],aSE2[nA][1][nC][11],"P",aSE2[nA][1][nC][4],aSE2[nA][1][nC][7],aSE2[nA][1][nC][1])
				aPagos[nA][H_RETIR]		:= Round(xMoeda(aSE2[nA][1][nC][_RETIR],1,nMoedaCor,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
		Endif
	Next nC
	If cPaisLoc	==	"ARG"
		//Atualiza o IVA Acumulado
		If aRetIvAcm[3] <> Nil .And. Len(aRetIvAcm)>2 .And. Len(aRetIvAcm[3]) > 0
			For nP := 1 to Len(aRetIvAcm[3])
				aPagos[nA][H_RETIVA]	+=	Round(xMoeda(aRetIvAcm[3][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
		EndIf
		For nC:=	1	To Len(aSE2[nA][2])
			aPagos[nA][H_RETGAN]		+=	Round(xMoeda(aSE2[nA][2][nC][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nC
		aPagos[nA][H_TOTALVL] := aPagos[nA][H_NF]-aPagos[nA][H_NCC_PA]-;
		aPagos[nA][H_RETIB]-aPagos[nA][H_RETGAN]-;
		aPagos[nA][H_RETIVA]-aPagos[nA][H_RETSUSS]-;
		aPagos[nA][H_RETSLI]-aPagos[nA][H_RETISI]
		//ANGOLA
	ElseIf cPaisLoc == "ANG"
		aPagos[nA][H_TOTALVL]	:=	aPagos[nA][H_NF]-aPagos[nA][H_NCC_PA]-aPagos[nA][H_RETRIE]
	ElseIf cPaisLoc == "EQU"
		aPagos[nA][H_TOTALVL]	:=	aPagos[nA][H_NF]-aPagos[nA][H_NCC_PA]-aPagos[nA][H_RETIR]
	Else
		aPagos[nA][H_TOTALVL]	:=	aPagos[nA][H_NF]-aPagos[nA][H_NCC_PA]
	Endif
	If cPaisLoc	==	"ARG"

		IF lExisPA
			nIVSUS	+= 	(aPagos[nA][H_RETIVA] + aPagos[nA][H_RETSUSS])
		Endif 

		aPagos[nA][H_TOTRET]	:=	aPagos[nA][H_RETIB]+aPagos[nA][H_RETIVA]+aPagos[nA][H_RETGAN]
		aPagos[nA][H_RETIB]		:=	TransForm(aPagos[nA][H_RETIB]  ,Tm(aPagos[nA][H_RETIB ] ,16,nDecs))
		aPagos[nA][H_RETGAN]	:=	TransForm(aPagos[nA][H_RETGAN] ,Tm(aPagos[nA][H_RETGAN] ,16,nDecs))
		aPagos[nA][H_RETIVA]	:=	TransForm(aPagos[nA][H_RETIVA] ,Tm(aPagos[nA][H_RETIVA] ,16,nDecs))
		aPagos[nA][H_RETSUSS]	:=	TransForm(aPagos[nA][H_RETSUSS],Tm(aPagos[nA][H_RETSUSS],16,nDecs))
		aPagos[nA][H_RETSLI]	:=	TransForm(aPagos[nA][H_RETSLI] ,Tm(aPagos[nA][H_RETSLI] ,16,nDecs))
		aPagos[nA][H_RETISI]	:=	TransForm(aPagos[nA][H_RETISI] ,Tm(aPagos[nA][H_RETISI] ,16,nDecs))
	//ANGOLA
	ElseIf cPaisLoc	==	"ANG"
		aPagos[nA][H_TOTRET]	:=	aPagos[nA][H_RETRIE]
		aPagos[nA][H_RETRIE]	:=	TransForm(aPagos[nA][H_RETRIE]  ,Tm(aPagos[nA][H_RETRIE ] ,16,nDecs))
	ElseIf cPaisLoc $ "COS|DOM"
		//Array aRetencao - Preenchido na fun็ใo fa050CalcRet() - Cแlculo de reten็ใo com Conf. de Impostos
		If Len(aRetencao) > 0
			For nX := 1 to Len(aRetencao)
				If aRetencao[nX][6] == aPagos[nA][H_FORNECE ] .And. aRetencao[nX][7] == aPagos[nA][H_LOJA ]
					For nY := 1 to Len(aRetencao[nX][8])
						If aRetencao[nX][8][nY][3] == "1"
							aPagos[nA][H_TOTRET ] += aRetencao[nX][8][nY][2]
							aPagos[nA][H_NF     ] += aPagos[nA][H_TOTRET ]
						ElseIf aRetencao[nX][8][nY][3] == "2"
							aPagos[nA][H_NCC_PA ] += aRetencao[nX][8][nY][2]
							aPagos[nA][H_TOTALVL] -= aRetencao[nX][8][nY][2]
						EndIf
					Next nY
				EndIf
			Next nX
		Else
			aPagos[nA][H_TOTRET ] := 0
		EndIf
	Endif

	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe o pagamento tem opcao de diferenciado, somar o total excedido ณ
	//ณ(PA) no H_TOTALVL                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/
	
	
	If aSE2[nA][3] <> Nil .And.  aSE2[nA][3][1] == 4
		If aSE2[nA][3][6] > 0
		    nValTot := Replace(AllTrim(aPagos[nA][H_TOTAL]), ",", "")
		    nValTot := Val(nValTot)
			If aSE2[nA][3][6] < nValTot
				nValDif := nValTot - aSE2[nA][3][6]
			Endif
			nValAct := aSE2[nA][3][6] + nValDif  - aPagos[nA][H_NCC_PA]
		End if
		If cPaisLoc=="ARG" .AND. aPagos[nA][H_TOTALVL] <> nValAct
			aPagos[nA][H_TOTALVL] 	+=	Round(xMoeda(aSE2[nA][3][6],aSE2[nA][3][7],nMoedaCor,,5,aTxMoedas[aSE2[nA][3][7]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Elseif cPaisLoc=="ARG" .AND. aPagos[nA][H_TOTALVL] == nValAct
			aPagos[nA][H_TOTALVL] 	:=	Round(xMoeda(nValAct,aSE2[nA][3][7],nMoedaCor,,5,aTxMoedas[aSE2[nA][3][7]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Elseif cPaisLoc<>"ARG"
			aPagos[nA][H_TOTALVL] 	+=	Round(xMoeda(aSE2[nA][3][6],aSE2[nA][3][7],nMoedaCor,,5,aTxMoedas[aSE2[nA][3][7]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Endif	
	Endif

	IF lExisPA
		aPagos[nA][H_TOTALVL] += nIVSUS
	Endif 	

	//A factura so eh desconsiderada caso a retencao de IVA e o total a ser 
	//pago sejam menores que zero. Isso eh valido somente para Argentina.
	If (aPagos[nA][H_TOTALVL] < 0) .And. Iif(cPaisLoc=="ARG",DesTrans(aPagos[nA][H_RETIVA],nDecs) <= 0,.T.)
		aPagos[nA][1] := 0
	Else
		nValOrdens	+=	aPagos[nA][H_TOTALVL]
	Endif
	aPagos[nA][H_DESCVL]	:=	aPagos[nA][H_NCC_PA ]
	aPagos[nA][H_NF    ]	:=	TransForm(aPagos[nA][H_NF     ],Tm(aPagos[nA][H_NF]     ,16,nDecs))
	aPagos[nA][H_NCC_PA]	:=	TransForm(aPagos[nA][H_NCC_PA ],Tm(aPagos[nA][H_NCC_PA] ,16,nDecs))
	aPagos[nA][H_TOTAL ]	:=	TransForm(aPagos[nA][H_TOTALVL],Tm(aPagos[nA][H_TOTALVL],18,nDecs))

	IF lExisPA
		aPagos[nA][H_TOTAL ]	:=	TransForm(aPagos[nA][H_TOTALVL],Tm(aPagos[nA][H_TOTALVL] ,18,nDecs))
	Endif 	


Next nA

If cPaisLoc == "ARG" .and. CCO->(ColumnPos("CCO_TPCALR"))> 0
	/*Retenciones*/
	aColsRet := {}
	aRetPos := {}
	Fn850GtRet(@aColsRet,aSE2)
	If Empty(aColsRet)
		Aadd(aColsRet,Array(Len(oGetDad3:aHeader)))
		For nP := 1 To Len(oGetDad3:aHeader)
			aColsRet[1,nP] := Criavar(AllTrim(oGetDad3:aHeader[nP,2]))
		Next nP
	EndIf
	oGetDad3:SetArray(aColsRet)	
	/*Fin Retenciones*/
	
	oGetDad3:oBrowse:Refresh()
EndIf


oLbx:Refresh()
oValOrdens:refresh(.T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850SetMoบAutor  ณAlexandre Silva     บ Data ณ  11.01.02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfigura as taxas das moedas.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850SetMo()

Local   lConfirmo   := .F.
Local   aCabMoed	:= {}
Local   aTamMoed	:= {23,25,30,30}
Local   aCpsMoed    := {"cMoeda","nTaxa"}
Local	aTmp1		:= {}
Private nQtMoedas   := Moedfin()
Private aLinMoed	:= {}
Private oBMoeda

If cPaisloc == 'RUS'
	aTxMoedas	:= F850TxMoed()
EndIf

aTmp1	     := aTxMoedas[1]
aLinMoed    :=	aClone(aTxMoedas)
aDel(aLinMoed,1)
aSize(aLinMoed,Len(aLinMoed)-1)

Posicione("SX3",2,"EL_MOEDA","X3_TITULO")
Aadd(aCabMoed,X3Titulo())
Aadd(aCabMoed,STR0118)

If nQtMoedas > 1
	Define MSDIALOG oDlg From 50,250 TO 212,480 TITLE STR0118 PIXEL //"Tasas"

		oBMoeda:=TwBrowse():New(04,05,01,01,,aCabMoed,aTamMoed,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

		oBMoeda:SetArray(aLinMoed)
		oBMoeda:bLine 	:= { ||{aLinMoed[oBMoeda:nAT][1],;
		Transform(aLinMoed[oBMoeda:nAT][2],PesqPict("SM2","M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)),TamSx3("M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)))[1]))}}

		oBMoeda:bLDblClick   := {||EdMoeda(),oBMoeda:ColPos := 1,oBMoeda:SetFocus()}
		oBMoeda:lHScroll     := .F.
		oBMoeda:lVScroll     := .T.
		oBMoeda:nHeight      := 112
		oBMoeda:nWidth	      := 215
		obMoeda:AcolSizes[1]	:= 50

	DEFINE  SButton FROM 064,50 TYPE 1 Action (lConfirmo := .T. , oDlg:End() ) ENABLE OF oDlg  PIXEL
	DEFINE  SButton FROM 064,80 TYPE 2 Action (,oDlg:End() ) ENABLE OF oDlg  PIXEL
	Activate MSDialog oDlg
Else
	Help("",1,"NoMoneda")
EndIf

If lConfirmo
	AAdd(aLinMoed,{})
	aIns(aLinMoed,1)
	aLinMoed[1]	:=	aClone(aTmp1)
	aTxMoedas	:=	aClone(aLinMoed)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850cRetบAutor  ณMicrosiga           บ Data ณ  10/17/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAcumula os valores base de calculo de retencao por Conceito.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850AcRet(aConGanOri,nSigno,nSaldo,aRateioGan,lMonotrb)
Local nRateio
Local nRatValImp
Local nValMerc
Local nTotOrden
Local nPosGan,cConc
Local nX,nY,nMoeda   	:=	1
Local aConGan			:=	{}
Local aConGanRat		:=	{}
Local lCalcGN 			:=	.T.
Local nI				:=	1
Local nVlrTotal		:=	0
Local aImpInf 			:=	{}
Local lTESNoExen := .F.
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')
Local nTamItm			:= TAMSX3("FF_ITEM")[1]
Local nPosIVC	:= 0
Local nAliqIVC	:= 1
Local aTesNf  := {}
Local nPosTes   := 0
DEFAULT nSigno			:=	1
DEFAULT lMonotrb 		:=	.F.
Default aRateioGan	:=	{}
Default aConGanOri	:=	{}

//As retencoes sao calculadas com a taxa do dํa e nao com a taxa variavel....
//Bruno.
If ExistBlock("F0851IMP")
	lCalcGN:=ExecBlock("F0851IMP",.F.,.F.,{"GN"})
EndIf

If lCalcGN

//+----------------------------------------------------------------+
//ฐ Obter o Valor do Imposto e Base baseando se no rateio do valor ฐ
//ฐ do titulo pelo total da Nota Fiscal.                           ฐ
//+----------------------------------------------------------------+
If !(SE2->E2_TIPO $ MV_CPNEG)
	dbSelectArea("SF1")
	dbSetOrder(1)
	If lMsFil
			nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
			SF1->(dbGoTo(nRecSF1))
	Else
			nRecSF1 := FINBuscaNF(xFilial("SF1", SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
			SF1->(dbGoTo(nRecSF1))
	EndIf
	While Alltrim(SF1->F1_ESPECIE)<>Alltrim(SE2->E2_TIPO).And.!Eof()
		SF1->(DbSkip())
		Loop
	Enddo

	If Alltrim(SF1->F1_ESPECIE)==Alltrim(SE2->E2_TIPO).And.;
		Iif(lMsFil, SF1->F1_MSFIL,xFilial("SF1",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA==;
				F1_FILIAL+F1_DOC+PadR(F1_SERIE,nTamSer)+F1_FORNECE+F1_LOJA

		nMoeda      := Max(SF1->F1_MOEDA,1)

		If cPaisLoc<>"ARG"
			nRateio := 1
		else
			nRateio := ( SF1->F1_VALMERC - SF1->F1_DESCONT ) / SF1->F1_VALBRUT
		Endif

		nRatValImp	:= ( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) / Round(xMoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) )
		nValMerc 	:= ( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) * nRateio )
		If SF1->F1_FRETE > 0
			MV_FRETLOC := GetNewPar("MV_FRETLOC","IVA162GAN06")
			cConc   := Alltrim(Subs( MV_FRETLOC, At("N",MV_FRETLOC)+1))
			nPosGan := ASCAN(aConGan,{|x| x[1]==cConc.And. x[3]==''})
			If nPosGan<>0
				aConGan[nPosGan][2]:=aConGan[nPosGan][2]+(Round(xMoeda(SF1->F1_FRETE,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))*nRatValimp)
			Else
				Aadd(aConGan,{cConc,Round(xMoeda(SF1->F1_FRETE,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))*nRatValimp,''})
			Endif
		EndIf
		If SF1->F1_DESPESA >  0
			MV_GASTLOC  := GetNewPar("MV_GASTLOC","IVA112GAN06")
			cConc   := Alltrim(Subs( MV_GASTLOC, At("N",MV_GASTLOC)+1))
			nPosGan := ASCAN(aConGan,{|x| x[1]==cConc.And. x[3]==''})
			If nPosGan<>0
				aConGan[nPosGan][2]:=aConGan[nPosGan][2]+Round(xMoeda(SF1->F1_DESPESA,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))*nRatValimp
			Else
				Aadd(aConGan,{cConc,Round(xMoeda(SF1->F1_DESPESA,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))*nRatValimp,''})
			Endif
		EndIf

		SD1->(DbSetOrder(1))
		If lMsFil
			SD1->(MsSeek(SF1->F1_MSFIL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		Else
			SD1->(MsSeek(xFilial("SD1",SE2->E2_FILORIG)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		EndIf
		If SD1->(Found())
			Do while Iif(lMsFil, SD1->D1_MSFIL,xFilial("SD1",SE2->E2_FILORIG))==SD1->D1_FILIAL.And.SF1->F1_DOC==SD1->D1_DOC.AND.;
				SF1->F1_SERIE==SD1->D1_SERIE.AND.SF1->F1_FORNECE==SD1->D1_FORNECE;
				.AND.SF1->F1_LOJA==SD1->D1_LOJA.And.!SD1->(EOF())

				IF AllTrim(SD1->D1_ESPECIE)<>AllTrim(SE2->E2_TIPO)
					SD1->(DbSkip())
					Loop
				Endif
					If Len(aTesNf) > 0
						nPosTes := aScan(aTesNf,{|x| x[1] == SD1->D1_TES})
					EndIf
					If nPosTes == 0
						aImpInf := TesImpInf(SD1->D1_TES)
						aAdd(aTesNf, {SD1->D1_TES, aImpInf})
					Else
						aImpInf := aClone(aTesNf[nPosTes][2])
					EndIf
					lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
					If !lTESNoExen
						SD1->(DbSkip())
						Loop
					Else
						nPosIVC := aScan(aImpInf,{|x| "IVC" $ AllTrim(x[1])})
						nAliqIVC := 1
						If nPosIVC > 0
							nAliqIVC := 1 + (aImpInf[nPosIVC][9]/100)
						EndIf
					EndIf
					SFF->(DbSetOrder(2))
					If SFF->(MsSeek(xfilial("SFF")+Pad(SF1->F1_SERIE,nTamItm ) )) .and. Round(xMoeda(( SF1->F1_VALMERC - SF1->F1_DESCONT ),SF1->F1_MOEDA,1,,,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) > SFF->FF_FXDE
			 			nVlrTotal:= 0
			 			If cPaisLoc == "ARG"
							For nI := 1 To Len(aImpInf)
					  			If(Trim(aImpInf[nI][01])$ SFF->FF_INCIMP)
									If aImpInf[nI][03] <> "3"
										nVlrTotal+=SD1->(FieldGet(ColumnPos(aImpInf[nI][02])))
									EndIf
								EndIf
							Next nI
						Endif
						nPosGan:=ASCAN(aConGan,{|x| x[1]==Pad(SF1->F1_SERIE, nTamItm ) })
						If nPosGan<>0
							aConGan[nPosGan][2]:=aConGan[nPosGan][2]+(Round(xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC+nVlrTotal),SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp)
						Else
							Aadd(aConGan,{Pad(SF1->F1_SERIE,nTamItm),Round(xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC+nVlrTotal),SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp,''})
						Endif
					Else
						SB1->(DbSetOrder(1))
						SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD1->D1_MSFIL,xFilial("SB1")) + SD1->D1_COD))
						If SB1->(Found()) .And. ((!lMonotrb .And. !Empty(SB1->B1_CONCGAN)) .Or. (cPaisLoc <> "BRA" .And. !Empty(SB1->B1_CMONGAN) .And. lMonotrb))
							cConc2	:=	''
							If cPaisLoc <> "BRA" .AND.SB1->B1_CONCGAN=='02'
								cConc2	:=	SB1->B1_CONCGAN
							Endif

							aAreaAtu:=GetArea()
							aAreaSFF:=SFF->(GetArea())
							dbSelectArea("SFF")
							dbSetOrder(2)
							If MsSeek(xFilial("SFF")+Iif(lMonotrb .And. cPaisLoc <> "BRA" ,SB1->B1_CMONGAN,SB1->B1_CONCGAN)+'GAN')
								nVlrTotal:= 0
								nVlrTotIt:=0
								If cPaisLoc == "ARG"
									For nI := 1 To Len(aImpInf)
				  						If(Trim(aImpInf[nI][01])$ SFF->FF_INCIMP)
											If aImpInf[nI][03] <> "3"
										   		nVlrTotal+=SD1->(FieldGet(ColumnPos(aImpInf[nI][02])))
											EndIf
										EndIf

									Next nI
								EndIf
							Endif

							RestArea(aAreaAtu)
							SFF->(RestArea(aAreaSFF))

							nPosGan:=ASCAN(aConGan,{|x| x[1]==Iif(lMonotrb .And. cPaisLoc == "ARG" ,SB1->B1_CMONGAN,SB1->B1_CONCGAN) .And. x[3]==cConc2})

							If nPosGan<>0
								aConGan[nPosGan][2]:=aConGan[nPosGan][2]+(Round(xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC+nVlrTotal)/nAliqIVC,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp)
							Else
								Aadd(aConGan,{Iif(lMonotrb .And. cPaisLoc == "ARG" ,SB1->B1_CMONGAN,SB1->B1_CONCGAN),Round(xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC+nVlrTotal)/nAliqIVC,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp,cConc2})
							Endif

						Else
							For nY := 1 To Len(aRateioGan)
								aAreaAtu:=GetArea()
								aAreaSFF:=SFF->(GetArea())
								dbSelectArea("SFF")
								dbSetOrder(2)
								If MsSeek(xFilial("SFF")+aRateioGan[nY][5]+'GAN')
									nVlrTotal:= 0
									nVlrTotIt:=0
									If cPaisLoc == "ARG"
										For nI := 1 To Len(aImpInf)
					  						If(Trim(aImpInf[nI][01])$ SFF->FF_INCIMP)
												If aImpInf[nI][03] <> "3"
											   		nVlrTotal+=SD1->(FieldGet(ColumnPos(aImpInf[nI][02])))
												EndIf
											EndIf

										Next nI
									EndIf
								Endif

								RestArea(aAreaAtu)
								SFF->(RestArea(aAreaSFF))
								nPosGan:=ASCAN(aConGanRat,{|x| x[1]==aRateioGan[nY][5] .And. x[3]==''.And. x[4] == aRateioGan[nY][2]+aRateioGan[nY][3] .And. If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"),x[5] == aRateioGan[nY][2]+aRateioGan[nY][6],.T.)})
								If nPosGan>0
									aConGanRat[nPosGan][2]+=(Round(xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC+nVlrTotal),SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp)* aRateioGan[nY][4]
								Else
									If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
										Aadd(aConGanRat,{aRateioGan[nY][5],(Round(xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC+nVlrTotal)/nAliqIVC,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp)* aRateioGan[nY][4],'',aRateioGan[nY][2]+aRateioGan[nY][3],aRateioGan[nY][6]})
									Else
										Aadd(aConGanRat,{aRateioGan[nY][5],(Round(xMoeda((SD1->D1_TOTAL-SD1->D1_VALDESC+nVlrTotal)/nAliqIVC,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp)* aRateioGan[nY][4],'',aRateioGan[nY][2]+aRateioGan[nY][3]})
									Endif
								Endif
						Next
					Endif
				EndIf
				SD1->(DbSkip())
			Enddo
		Else
			For nY := 1 To Len(aRateioGan)
				nPosGan:=ASCAN(aConGanRat,{|x| x[1]==aRateioGan[nY][5] .And. x[3]==''.And. x[4] == aRateioGan[nY][2]+aRateioGan[nY][3] .And. If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"),x[5] == aRateioGan[nY][2]+aRateioGan[nY][6],.T.)})
				If nPosGan<>0
					aConGanRat[nPosGan][2]+= nValMerc * aRateioGan[nY][4]
				Else
					If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
						Aadd(aConGanRat,{aRateioGan[nY][5],nValMerc*aRateioGan[nY][4],'',aRateioGan[nY][2]+aRateioGan[nY][3],aRateioGan[nY][6]})
					Else
						Aadd(aConGanRat,{aRateioGan[nY][5],nValMerc*aRateioGan[nY][4],'',aRateioGan[nY][2]+aRateioGan[nY][3]})
					Endif
				Endif
			Next
		Endif
	Else
		nValMerc	 := Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1))
		For nY := 1 To Len(aRateioGan)
			nPosGan:=ASCAN(aConGanRat,{|x| x[1]==aRateioGan[nY][5] .And. x[3]==''.And. x[4] == aRateioGan[nY][2]+aRateioGan[nY][3] .And. If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"),x[5] == aRateioGan[nY][2]+aRateioGan[nY][6],.T.)})
			If nPosGan<>0
				aConGanRat[nPosGan][2]+= nValMerc * aRateioGan[nY][4]
			Else
			 	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
					Aadd(aConGanRat,{aRateioGan[nY][5],nValMerc*aRateioGan[nY][4],'',aRateioGan[nY][2]+aRateioGan[nY][3],aRateioGan[nY][6]})
				Else
					Aadd(aConGanRat,{aRateioGan[nY][5],nValMerc*aRateioGan[nY][4],'',aRateioGan[nY][2]+aRateioGan[nY][3]})
				Endif
			Endif
		Next
	EndIf
Endif

//Faz o rateio dos condominos
For nY	:=	1	To Len(aConGan)
	For nX:= 1 To Len(aRateioGan)
		If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
			AAdd(aConGanRat,{aConGan[nY][1],aConGan[nY][2]*aRateioGan[nX][4],aConGan[nY][3],aRateioGan[nX][2]+aRateioGan[nX][3],aRateioGan[nY][6]})
		Else
			AAdd(aConGanRat,{aConGan[nY][1],aConGan[nY][2]*aRateioGan[nX][4],aConGan[nY][3],aRateioGan[nX][2]+aRateioGan[nX][3]})
		Endif
	Next
Next

//Distribue os acumulados ja rateados no array de acumulados total
For nY := 1 TO Len(aConGanRat)

	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
		nPosGan   := ASCAN(aConGanOri,{|x|  x[1]+x[3]+x[4]+x[5] == aConGanRat[nY][1]+aConGanRat[nY][3]+aConGanRat[nY][4]+aConGanRat[nY][5]})
	Else
		nPosGan   := ASCAN(aConGanOri,{|x|  x[1]+x[3]+x[4] == aConGanRat[nY][1]+aConGanRat[nY][3]+aConGanRat[nY][4]})
	EndIf

	If nPosGan<>0
		aConGanOri[nPosGan][2]	+= aConGanRat[nY][2]
	Else
		Aadd(aConGanOri,aClone(aConGanRat[nY]))
	Endif
Next
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VldPบAutor  ณBruno Sobieski      บ Data ณ  10/17/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a digitacao do valor por pagar                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VldP()
Local nPosValor		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(X[2])=="E2_VALOR"})
Local nPosSaldo		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(X[2])=="E2_SALDO"})
Local nPosMulta		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_MULTA"})
Local nPosJuros		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_JUROS"})
Local nPosDesco		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_DESCONT"})
Local nPosPagar		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_PAGAR"})
Local nPosVl		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="NVLMDINF"})
Local nPosMoeda		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_MOEDA"})
Local nVlrParcial	:= &(ReadVar())
Local nValorSaldo	:= 0
Local lRet			:= .T.

nValorSaldo := Iif(oGetDad0:aCols[oGetDad0:nAt][nPosSaldo]>0,oGetDad0:aCols[oGetDad0:nAt][nPosSaldo],0) //+ oGetDad0:aCols[oGetDad0:nAt][nPosPagar]
If	nVlrParcial  > (nValorSaldo + oGetDad0:aCols[oGetDad0:nAt][nPosJuros] + oGetDad0:aCols[oGetDad0:nAt][nPosMulta]) - oGetDad0:aCols[oGetDad0:nAt][nPosDesco]
	MsgStop(OemToAnsi(STR0119)) //"El valor tipeado es MAYOR que el saldo"
	lRet:=.F.
ElseIf nVlrParcial < 0
	MsgStop(OemToAnsi(STR0120)) //"El valor debe ser MAYOR o IGUAL a 0"
	lRet:=.F.
EndIf
If lRet
	oGetDad0:aCols[oGetDad0:nAt][nPosVl] := Iif(oGetDad0:aCols[oGetDad0:nAt][nPosVl]>=0,Round(xMoeda(nVlrParcial,oGetDad0:aCols[oGetDad0:nAt][nPosMoeda],nMoedaCor,,5,aTxmoedas[oGetDad0:aCols[oGetDad0:nAt][nPosMoeda]][2],aTxmoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)),0)
	oGetDad0:aCols[oGetDad0:nAt,nPosVl] := oGetDad0:aCols[oGetDad0:nAt][nPosVl]
	oGetDad0:oBrowse:Refresh()
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaPagosบAutor  ณLeonardo Gentile    บ Data ณ  04/01/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFazer todo o tratamento de gravacao dos registros referente บฑฑ
ฑฑบ          ณaos pagos (por default ou diferenciado)                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaPagos( nPagar, cBanco, cAgencia, cConta, cNumChq, cFornece, cLoja, cNome,nMoeda, nTotal, dDtEmis,;
dDtVcto, cDebMed, cDebInm, nRegSE1,cParcela,nBaseITF,aHdlPrv,lCBU,lPa,nRecEQU,cChqEQU,nValMoed1,nValMOrig,cNatureza,cPrefixo,cModPago,cTalao)

Local cSeqFRF		:= ""
Local nMoedaBco		:= 1
Local nSize			:= 0
Local aArea			:= {}
Local nValorTit		:= 0
Local lChMed		:= .F.
Local lChInMed		:= .F.
Local lFindITF		:= .T.
Local lRet			:= .T.
Local cFiltroSe2	:= ""
Local nSeqSXE		:= 0
Local cCposSE5		:= ""
Local cLog			:= ""
Local cIDDoc		:= ""
Local cChaveTit		:= ""
Local cIDSEF		:= ""
Local cRedNome      := ""

DEFAULT lPa		:= .F.
DEFAULT lCBU		:= .F.
DEFAULT nValMoed1	:= 0
DEFAULT cNatureza	:= Space(TamSX3("ED_CODIGO")[1])
DEFAULT cModPago	:= ""
DEFAULT cTalao		:= ""

cBanco   := If( cBanco	=nil, "", cBanco)
cAgencia := If( cAgencia=nil, "", cAgencia)
cConta   := If( cConta	=nil, "", cConta)
cNumChq  := If( cNumChq	=nil, "", cNumChq)
cParcela := If( cParcela=nil, "", cParcela)
If !Empty(cBanco)
	SA6->(DbSetOrder(1))
	SA6->(MsSeek(xFilial()+cBanco+cAgencia+cConta))
	nMoedaBco	:=	Iif(SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
	nMoedaBco	:=	Max(nMoedaBco,1)
Endif
SA2->(DbSetOrder(1))
If  SA2->(MsSeek(xFilial()+cFornece+cLoja))
	cRedNome := SA2->A2_NREDUZ
Endif

If ValType(nRecEQU) != "N"
	nRecEQU := 0
EndIf

/*
Pegar a numero que vou usar para numerar os documentos gerados.*/
If (nPagar == 2 .Or. nPagar == 3 .OR. (nPagar ==1 .AND. cPaisLoc $ "ARG|EQU|DOM|COS")) .And. (Empty(cNumChq) .Or.Substr(cNumChq,1,1)=='*')
	If ExistBlock("A850NUM")
		cNumChq	:=	ExecBlock("A850NUM",.F.,.F.,{nPagar,cFornece,cLoja,dDtVcto})
		If ExistBlock("A850PRECH")
			cFiltroSE2 :=	SE2->(DbFilter())  // Salva o filtro para que possa ser consultado todo o SE2 no RDMAKE
	 		SE2->(dbClearFilter())
			cPrefixo :=	ExecBlock("A850PRECH",.F.,.F.,{cNumChq,cFornece,cLoja,cBanco,cAgencia,cConta})
			DbSelectArea("SE2")
			SET FILTER TO &cFiltroSE2  // Restaura o filtro original
		EndIF
	Else
		aArea	:=GetArea()
		DbSelectArea("SA6")                                                                                                                                                                              
		cCampo	:=	"A6_NUM"+Iif(nPagar==2,cDebMed,cDebInm)
		If SA6->(ColumnPos(cCampo)) > 0
			nSize	:=	Len(Alltrim(&cCampo.))
			nSize	:=	If(nSize == 0,TamSX3("E2_NUM")[1],nSize)
			cNumChq	:=	&cCampo
			Reclock("SA6",.F.)
			Replace &cCampo	With StrZero(Val(&cCampo.)+1,nSize)
			MsUnLock()
		Else
			cNumChq	:=	cOrdPago
		Endif
		RestArea(aArea)
	Endif
Endif
/*
VALIDACAO PARA VERIFICAR SE ESTE NUMERO DE CHEQUE JA ESTA CADASTRADO NO SE2, E CASO ESTEJA
AUMENTAR O NUMERO DA PARCELA PARA NAO GERAR DUPLICIDADE*/
If TableInDic("__SE2") .and. !(cPaisLoc $ "ARG|EQU|DOM|COS")
	dbSelectArea("SE2")
	dbSetOrder(1)
	dbGotop()
	Do While ! Eof()
		If __SE2->(MsSeek(xFilial("SE2")+ cPrefixo + cNumChq + If(!Empty(cParcela),cParcela,space(TamSX3("E2_PARCELA")[1])) + cDebMed + cFornece + cLoja))
			If Empty(cParcela)
				cParcela := GetMV("MV_1DUP")
			Else
				Soma1( cParcela,, .T. )
			Endif
			Loop
		Else
			Exit
		Endif
	Enddo
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravar os debitos inmediatos (Transferencias, Cash, Cartao de debito, etc).ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If 	nPagar == 3 .And. nTotal > 0 .And. !(AllTrim(cDebInm) $ MVCHEQUE) .And. cOpcElt <> "1"
	oModMovBco:SetOperation(MODEL_OPERATION_INSERT)
	oModMovBco:Activate()
	oModMovBco:SetValue("MASTER","E5_GRV",.T.)
	oModMovBco:SetValue("MASTER","IDPROC",cIDProc)

	cCposSE5 := "{"
	cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
	cCposSE5 += "{'E5_VENCTO',dDataBase},"
	cCposSE5 += "{'E5_TIPO','" + cDebInm + "'},"
	cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
	cCposSE5 += "{'E5_PREFIXO',''},"
	cCposSE5 += "{'E5_NUMERO','" + cNumChq + "'},"
	cCposSE5 += "{'E5_PARCELA','" + cParcela + "'},"
	cCposSE5 += "{'E5_CLIFOR','" + cFornece + "'},"
	cCposSE5 += "{'E5_LOJA','"  + cLoja + "'},"
	cCposSE5 += "{'E5_BENEF','" + Iif(!Empty(cNome),cNome,cRedNome)  + "'},"
	cCposSE5 += "{'E5_MOTBX','NOR'}"
	cCposSE5 += "}"

	oModMovBco:SetValue("MASTER","E5_CAMPOS",cCposSE5)
	oFKAMovBco:SetValue("FKA_IDORIG",FWUUIDV4())
	oFKAMovBco:SetValue("FKA_TABORI","FK5")

	oFK5MovBco:SetValue("FK5_VALOR",Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,aTxMoedas[nMoeda][2],aTxMoedas[nMoedaBco][2]),MsDecimais(nMoedaBco)))
	oFK5MovBco:SetValue("FK5_RECPAG","P")
	oFK5MovBco:SetValue("FK5_HISTOR",STR0099+ ' ' + cOrdPago)		 //"Ord. pago "
	oFK5MovBco:SetValue("FK5_DATA",dDataBase)
	oFK5MovBco:SetValue("FK5_NATURE",cNatureza)
	oFK5MovBco:SetValue("FK5_TPDOC","VL")
	//Gravar a moeda2 em moeda 1 para facilitar a contabilizacao
	If lPa
		oFK5MovBco:SetValue("FK5_VLMOE2",Round(xMoeda(nTotal,nMoeda,1,,5,aTxMoedas[nMoeda][2]),5))
	Else
		oFK5MovBco:SetValue("FK5_VLMOE2",nValMOrig)
  	EndIf
	oFK5MovBco:SetValue("FK5_ORDREC",cOrdPago)
	oFK5MovBco:SetValue("FK5_BANCO",cBanco)
	oFK5MovBco:SetValue("FK5_AGENCI",cAgencia)
	oFK5MovBco:SetValue("FK5_CONTA",cConta)
	oFK5MovBco:SetValue("FK5_NUMCH",If(cPaisLoc $ "ARG|EQU|DOM|COS",cChqEQU,cNumChq))
	oFK5MovBco:SetValue("FK5_MOEDA",StrZero(nMoedaBco,2))
	oFK5MovBco:SetValue("FK5_DTDISP",dDtVcto)
	oFK5MovBco:SetValue("FK5_LA","S")
	oFK5MovBco:SetValue("FK5_FILORI",SubString(cFilAnt,1,len(FK5->FK5_FILIAL)))
	oFK5MovBco:SetValue("FK5_ORIGEM","FINA850")
	oFK5MovBco:SetValue("FK5_TXMOED",aTxMoedas[nMoedaBco][2])

	If oModMovBco:VldData()
		oModMovBco:CommitData()

		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")
		IF lPa
	   		if lFindITF .And. FinProcITF( SE5->( RecNo() ),1 ) .and. lRetCkPG(3,,SE5->E5_BANCO)
	      		nBaseITF:=if(nBaseITF=0,SE5->E5_VALOR,nBaseITF)
	     	else
	   		   	nBaseITF:=0
	   		endif
	  	Else
	   		if lFindITF .And. FinProcITF( SE5->( RecNo() ),1 ) .and. lRetCkPG(3,,SE5->E5_BANCO)
	      		nBaseITF+=SE5->E5_VALOR
	   		endif
		endif
		//verifico se o sistema esta parametrizado corretamente para efetuar lancamento do imposto ITF
		If lFindITF .AND. nBaseITF > 0 .AND. FinProcITF( SE5->( RecNo() ),1 ).AND. lRetCkPG(3,,SE5->E5_BANCO)
			//faco o lancamento do imposto ITF na movimentacao bancaria e retorno os dados para contabilizacao
			FinProcITF( SE5->( RecNo() ), 3, nBaseITF , .F., aHdlPrv,  )
		EndIf
	Else
		cLog := cValToChar(oModMovBco:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oModMovBco:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oModMovBco:GetErrorMessage()[6])
		Help( ,,"ORDPAG_DBIM",,cLog, 1, 0 )
		lRet := .F.
	Endif
	oModMovBco:DeActivate()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravar os debitos mediatos (Cheques, Letras, Etc), e os cheques de deb. inmediato. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf nPagar <> 4

	If nPagar	==	2	.And.	Trim(cDebMed) == Trim(MVCHEQUE)
		lChMed := .T.
	EndIf

	If nPagar	==	3	.And.	Trim(cDebInm) == Trim(MVCHEQUE)
		lChInMed := .T.
	EndIf

	If	(nPagar == 1 .Or. lChMed .Or. lChInMed).And. nTotal > 0

		SEF->(DbGoTo(nRecEQU))
		If SEF->(Recno()) == nRecEQU
			cPrefixo := SEF->EF_PREFIXO
			RecLock("SEF",.F.)
			SEF->EF_VALOR   := Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,aTxMoedas[nMoeda][2],aTxMoedas[nMoedaBco][2]),MsDecimais(nMoedaBco))
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava o numero do cheque somente se for pagamento diferenciado          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			SEF->EF_BENEF	:= cNome
			SEF->EF_VENCTO	:= dDtVcto
			SEF->EF_DATA	:= dDtEmis
			SEF->EF_HIST 	:= STR0099+cOrdPago //"Ord. pago "
			SEF->EF_LIBER 	:= If(nPagar==1,GetMV("MV_LIBCHEQ"),"S")
			SEF->EF_FORNECE	:= cFornece
			SEF->EF_LOJA	:= cLoja
			SEF->EF_LA     	:= "S"
			SEF->EF_SEQUENC	:= PadL("1",TamSX3("EF_SEQUENC")[1],"0")
			SEF->EF_PARCELA	:= cParcela

			If lChInMed
				SEF->EF_STATUS	:= "04"
				SEF->EF_REFTIP	:= "LP"
			Else
				SEF->EF_STATUS	:=	"02"
			EndIf

			SEF->EF_ORDPAGO	:= cOrdPago
			SEF->EF_IDSEF	:= FWUUIDV4()

			If nPagar==1 .AND. !(cPaisLoc $ "ARG|EQU|DOM|COS")   // cheque pre-impresso
				SEF->EF_TITULO  := cOrdPago
				SEF->EF_TIPO    :="ORP"
			Else
				SEF->EF_TITULO  := cOrdPago
				SEF->EF_TIPO    := Trim(MVCHEQUE)
			Endif
			SEF->EF_ORIGEM 	:= "FINA850"

			SEF->(MsUnlock())

			If lSmlCtb
				cSeqFRF := StrZero(++nSeqSXE,TamSX3("FRF_SEQ")[1])
			Else
				cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
			Endif
		    RecLock("FRF",.T.)
		    FRF->FRF_FILIAL		:= xFilial("FRF")
		    FRF->FRF_BANCO		:= SEF->EF_BANCO
		    FRF->FRF_AGENCIA		:= SEF->EF_AGENCIA
		    FRF->FRF_CONTA		:= SEF->EF_CONTA
		    FRF->FRF_NUM			:= SEF->EF_NUM
		    FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
		    FRF->FRF_CART			:= "P"
		    FRF->FRF_DATPAG		:= dDataBase
		    FRF->FRF_MOTIVO		:= "99"
		    FRF->FRF_DESCRI		:= STR0227 //"CHEQUE VINCULADO A PAGAMENTO"
		    FRF->FRF_SEQ			:= cSeqFRF
		    FRF->FRF_FORNEC		:= cFornece
		    FRF->FRF_LOJA			:= cLoja
		    FRF->FRF_NUMDOC		:= cOrdPago
		    FRF->(MsUnLock())

			//Confirma a numera็ใo do historico
			If !lSmlCtb
			    ConfirmSX8()
			Endif

			//Se for cheque que gera movimento bancแrio, gera o hist๓rico de liquida็ใo
			If lChInMed .And. cOpcElt <> "1"

				If lSmlCtb
					cSeqFRF := StrZero(++nSeqSXE,TamSX3("FRF_SEQ")[1])
				Else
					cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
				Endif
			    RecLock("FRF",.T.)
			    FRF->FRF_FILIAL		:= xFilial("FRF")
			    FRF->FRF_BANCO		:= SEF->EF_BANCO
			    FRF->FRF_AGENCIA		:= SEF->EF_AGENCIA
			    FRF->FRF_CONTA		:= SEF->EF_CONTA
			    FRF->FRF_NUM			:= SEF->EF_NUM
			    FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
			    FRF->FRF_CART			:= "P"
			    FRF->FRF_DATPAG		:= dDataBase
			    FRF->FRF_MOTIVO		:= "10"
			    FRF->FRF_DESCRI		:= STR0368 //"CHEQUE COMPENSADO"
			    FRF->FRF_SEQ			:= cSeqFRF
			    FRF->FRF_FORNEC		:= cFornece
			    FRF->FRF_LOJA			:= cLoja
			    FRF->FRF_NUMDOC		:= cOrdPago
			    FRF->(MsUnLock())

				If !lSmlCtb
			    	ConfirmSX8()
				Endif

			EndIf

		Endif
Endif

	If (nPagar ==2 .OR. (nPagar ==1 .AND. cPaisLoc $ "ARG|EQU|DOM|COS") .Or. lChInMed) .And. nTotal > 0 .And. cOpcElt <> "1"  // debito mediato (CH)
		dbSelectArea("SE2")
		// GERAR SE2

		RecLock("SE2",.T.)
		SE2->E2_FILIAL	:= xFilial("SE2")
		SE2->E2_FILORIG  := cFilAnt
		SE2->E2_NUMLIQ	:= cLiquid
		If SEF->(Recno()) == nRecEQU
			If cPaisLoc $ "EQU|DOM|COS"
				SE2->E2_NUMBCO		:=	cChqEQU
			Else
				SE2->E2_NUMBCO		:= cNumChq
			EndIf
			SE2->E2_PREFIXO	:=	SEF->EF_PREFIXO
			cPrefixo := SEF->EF_PREFIXO
		Endif
		SE2->E2_NUM   		:= cNumChq
		SE2->E2_PREFIXO 	:= cPrefixo
		SE2->E2_TIPO 		:= Iif(lChInMed,cDebInm,cDebMed)
		SE2->E2_NATUREZ 	:= cNatureza
		SE2->E2_FORNECE	:= cFornece
		SE2->E2_LOJA  		:= cLoja
		SE2->E2_NOMFOR 	:= Iif(!Empty(cNome),cNome,cRedNome)  
		SE2->E2_EMISSAO	:= dDtEmis
		SE2->E2_EMIS1 		:= dDtEmis
		SE2->E2_VENCTO	:= dDtVcto
		SE2->E2_VENCREA	:= DataValida(dDtVcto,.T.)
		nValorTit			:= Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,aTxMoedas[nMoeda][2],aTxMoedas[nMoedaBco][2]),MsDecimais(nMoedaBco))
		SE2->E2_VALOR   	:= nValorTit
		SE2->E2_VENCORI	:= DataValida(dDtVcto,.T.)
		SE2->E2_PARCELA 	:=cParcela
		If lBaixaChq .Or. lChInMed
			SE2->E2_VALLIQ   := nValorTit
			SE2->E2_SALDO    := 0
			SE2->E2_BAIXA    := dDataBase
			SE2->E2_MOVIMEN  := dDataBase
			SE2->E2_BCOPAG   := cBanco
		Else
			SE2->E2_SALDO    := nValorTit
		Endif
		SE2->E2_VLCRUZ 	:= Round(xMoeda(nTotal,nMoedaBco,1,,5,aTxMoedas[nMoeda][2]),MsDecimais(1))
		SE2->E2_MOEDA   	:= nMoedaBco
		SE2->E2_SITUACA  	:= "0"
		SE2->E2_PORTADO  	:= cBanco
		SE2->E2_BCOCHQ   	:= cBanco
		SE2->E2_AGECHQ   	:= cAgencia
		SE2->E2_CTACHQ   	:= cConta
		SE2->E2_ORDPAGO  	:= cOrdpago
		SE2->E2_ORIGEM 	:= "FINA850"
		SE2->E2_LA       	:=  "S"
		SE2->E2_TXMOEDA := aTxMoedas[Max(nMoedaBco,1)][2]//GRAVA A TAXA DA MOEDA DO PA
		SE2->E2_DATALIB:= dDtEmis
		If !Empty(cPrefixo)
			SE2->E2_PREFIXO   	:= cPrefixo
		EndIf
		MsUnlock()
		FKCommit()

		If (lBaixaChq .and. !(cPaisLoc $ "ARG|EQU|DOM|COS")) .Or. lChInMed
			oModBxE2:SetOperation(MODEL_OPERATION_INSERT)
			oModBxE2:Activate()
			oModBxE2:SetValue("MASTER","E5_GRV",.T.)
			oModBxE2:SetValue("MASTER","IDPROC",cIDProc)

			cCposSE5 := "{"
			cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
			cCposSE5 += "{'E5_TIPO','" + If(lChInMed,cDebInm,cDebMed) + "'},"
			cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'},"
			cCposSE5 += "{'E5_PREFIXO','" + cPrefixo + "'},"
			cCposSE5 += "{'E5_NUMERO','" + cNumChq + "'},"
			cCposSE5 += "{'E5_PARCELA','" + cParcela + "'},"
			cCposSE5 += "{'E5_CLIFOR','" + cFornece + "'},"
			cCposSE5 += "{'E5_LOJA','"  + cLoja + "'},"
			cCposSE5 += "{'E5_BENEF','" + Iif(!Empty(cNome),cNome,cRedNome) + "'},"
			cCposSE5 += "{'E5_BANCO','" + cBanco + "'},"
			cCposSE5 += "{'E5_AGENCIA','" + cAgencia + "'},"
			cCposSE5 += "{'E5_CONTA','" + cConta + "'},"
			cCposSE5 += "{'E5_DTDISPO',Ctod('" + Dtoc(dDtVcto) + "')}"
			cCposSE5 += "}"

			cChaveTit := xFilial("SE2") + "|"
			cChaveTit += cPrefixo + "|"
			cChaveTit += cNumChq + "|"
			cChaveTit += cParcela + "|"
			cChaveTit += Iif(lChInMed,cDebInm,cDebMed) + "|"
			cChaveTit += cFornece + "|"
			cChaveTit += cLoja
			cIdDoc := FINGRVFK7("SE2", cChaveTit)

			oModBxE2:SetValue("MASTER","E5_CAMPOS",cCposSE5)
			oFKABxE2:SetValue("FKA_IDORIG",FWUUIDV4())
			oFKABxE2:SetValue("FKA_TABORI","FK2")

			oFK2BxE2:SetValue("FK2_VALOR",Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,aTxMoedas[nMoeda][2],aTxMoedas[nMoedaBco][2]),MsDecimais(nMoedaBco)))
			oFK2BxE2:SetValue("FK2_RECPAG","P")
			oFK2BxE2:SetValue("FK2_HISTOR",STR0140)		// "DEBITO CC"
			oFK2BxE2:SetValue("FK2_DATA",dDataBase)
			oFK2BxE2:SetValue("FK2_TPDOC","VL")
			//Gravar a moeda2 em moeda 1 para facilitar a contabilizacao
			If lPa
				oFK2BxE2:SetValue("FK2_VLMOE2",Round(xMoeda(nTotal,nMoeda,1,,5,aTxMoedas[nMoeda][2]),5))
			Else
				oFK2BxE2:SetValue("FK2_VLMOE2",nValMOrig)
		  	EndIf
			oFK2BxE2:SetValue("FK2_SEQ",PadL("1",TamSX3("E5_SEQ")[1],"0"))
			oFK2BxE2:SetValue("FK2_MOEDA",StrZero(nMoedaBco,2))
			oFK2BxE2:SetValue("FK2_NATURE",cNatureza)
			oFK2BxE2:SetValue("FK2_TXMOED",aTxMoedas[nMoedaBco][2])
			oFK2BxE2:SetValue("FK2_MOTBX",If(lChInMed,"NOR","DEB"))
			oFK2BxE2:SetValue("FK2_FILORI",cFilAnt)
			oFK2BxE2:SetValue("FK2_IDDOC",cIdDoc)
			oFK2BxE2:SetValue("FK2_ORIGEM","FINA850")

			If oModBxE2:VldData()
				oModBxE2:CommitData()

				AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")
				//verifico se o sistema esta parametrizado corretamente para efetuar lancamento do imposto ITF
				If lFindITF .And. nBaseITF > 0 .AND. FinProcITF( SE5->( RecNo() ),1 ) .AND. lRetCkPG(3,,SE5->E5_BANCO)
					//faco o lancamento do imposto ITF na movimentacao bancaria e retorno os dados para contabilizacao
					FinProcITF( SE5->( RecNo() ), 3, nBaseITF , .F., aHdlPrv  )
				EndIf
			Else
				cLog := cValToChar(oModBxE2:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModBxE2:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModBxE2:GetErrorMessage()[6])
				Help( ,,"ORDPAG_DBMEBXCH",,cLog, 1, 0 )
				lRet := .F.
			Endif
			oModBxE2:DeActivate()
		Else
			Reclock("SA2",.F.)
			SA2->A2_SALDUP	:= SA2->A2_SALDUP  + Round(xMoeda(nValorTit,nMoedaBco,1,,5,aTxMoedas[nMoedaBco][2]),MsDecimais(1))
			SA2->A2_SALDUPM	:= SA2->A2_SALDUPM + Round(xMoeda(nValorTit,nMoedaBco,nMVCusto,,5,aTxMoedas[nMoedaBco][2],aTxMoedas[nMVCusto][2]),MsDecimais(nMVCusto))
			MsUnlock()
		EndIf
	EndIf
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBaixar cheques de terceiros aplicados no pagamentoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*
	atualiza o controle de cheques recebidos*/
	If !Empty(nRecEQU)
		SEF->(DbGoTo(nRecEQU))
		If SEF->(Recno()) == nRecEQU
			RecLock("SEF",.F.)
			//If Empty(SEF->EF_IDSEF)
				cIDSEF := FWUUIDV4()
			//	SEF->EF_IDSEF := cIDSEF
			//Else
			//	cIDSEF := SEF->EF_IDSEF
			//Endif
			Replace SEF->EF_ORDPAGO	With cOrdPago
			Replace SEF->EF_STATUS	With "09"
			SEF->(MsUnLock())
			/*
			registra o movimento no arquivo de historicos*/
			If lSmlCtb
				cSeqFRF := StrZero(++nSeqSXE,TamSX3("FRF_SEQ")[1])
			Else
				cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
			Endif
			RecLock("FRF",.T.)
			FRF->FRF_FILIAL	:= xFilial("FRF")
			FRF->FRF_BANCO	:= SEF->EF_BANCO
			FRF->FRF_AGENCI	:= SEF->EF_AGENCIA
			FRF->FRF_CONTA	:= SEF->EF_CONTA
			FRF->FRF_NUM		:= SEF->EF_NUM
			FRF->FRF_PREFIX	:= SEF->EF_PREFIXO
			FRF->FRF_CART		:= "P"
			FRF->FRF_DATPAG	:= dDataBase
			FRF->FRF_MOTIVO	:= "99"
			FRF->FRF_DESCRI	:= STR0227 //"CHEQUE VINCULADO A PAGAMENTO"
			FRF->FRF_SEQ		:= cSeqFRF
			FRF->FRF_FORNEC	:= cFornece
			FRF->FRF_LOJA		:= cLoja
			FRF->FRF_NUMDOC	:= cOrdPago
			FRF->(MsUnLock())
			ConfirmSX8()
		Endif
	Endif

	If nRegSE1 # nil
		SE1->( MsGoto( nRegSE1))
		If !SE1->(Eof())
			oModBxE1:SetOperation(MODEL_OPERATION_INSERT)
			oModBxE1:Activate()
			oModBxE1:SetValue("MASTER","E5_GRV",.T.)
			oModBxE1:SetValue("MASTER","IDPROC",cIDProc)
			cCposSE5 := "{"
			cCposSE5 += "{'E5_DTDIGIT',dDataBase},"
			cCposSE5 += "{'E5_PREFIXO','" + SE1->E1_PREFIXO + "'},"
			cCposSE5 += "{'E5_NUMERO','" + SE1->E1_NUM + "'},"
			cCposSE5 += "{'E5_BCOCHQ','" + SE1->E1_BCOCHQ + "'},"
			cCposSE5 += "{'E5_AGECHQ','" + SE1->E1_AGECHQ + "'},"
			cCposSE5 += "{'E5_CTACHQ','" + SE1->E1_CTACHQ + "'},"
			cCposSE5 += "{'E5_PARCELA','" + SE1->E1_PARCELA + "'},"
			cCposSE5 += "{'E5_CLIFOR','" + SE1->E1_CLIENTE + "'},"
			cCposSE5 += "{'E5_LOJA','" + SE1->E1_LOJA + "'},"
			cCposSE5 += "{'E5_BENEF','" + cFornece+cLoja + "'},"
			cCposSE5 += "{'E5_TIPO','" + SE1->E1_TIPO + "'},"
			cCposSE5 += "{'E5_NUMLIQ','" + cLiquid + "'}"
			cCposSE5 += "}"

			cChaveTit := xFilial("SE1") + "|"
			cChaveTit += SE1->E1_PREFIXO + "|"
			cChaveTit += SE1->E1_NUM + "|"
			cChaveTit += SE1->E1_PARCELA + "|"
			cChaveTit += SE1->E1_TIPO + "|"
			cChaveTit += SE1->E1_CLIENTE + "|"
			cChaveTit += SE1->E1_LOJA
			cIdDoc := FINGRVFK7("SE1", cChaveTit)

			oModBxE1:SetValue("MASTER","E5_CAMPOS",cCposSE5)
			If Empty (cIDSEF)
				cIDSEF := FWUUIDV4()
			EndIf
			
			oFKABxE1:SetValue("FKA_IDORIG",cIDSEF)
			oFKABxE1:SetValue("FKA_TABORI","FK1")

			oFK1BxE1:SetValue("FK1_RECPAG","R")
			oFK1BxE1:SetValue("FK1_HISTOR",STR0100+cOrdPago)		 //"Entregado OP "
			oFK1BxE1:SetValue("FK1_DATA",SE1->E1_EMISSAO)
			oFK1BxE1:SetValue("FK1_NATURE",SE1->E1_NATUREZ)
			oFK1BxE1:SetValue("FK1_VENCTO",SE1->E1_VENCTO)
			oFK1BxE1:SetValue("FK1_TPDOC","BA")
			oFK1BxE1:SetValue("FK1_MOTBX","LIQ")
			oFK1BxE1:SetValue("FK1_VLMOE2",SE1->E1_VALOR)
			oFK1BxE1:SetValue("FK1_SEQ",PadL("1",TamSX3("E5_SEQ")[1],"0"))
			oFK1BxE1:SetValue("FK1_DOC",cOrdpago)
			oFK1BxE1:SetValue("FK1_ORDREC",cOrdPago)
			oFK1BxE1:SetValue("FK1_MOEDA",StrZero(SE1->E1_MOEDA,2))
			oFK1BxE1:SetValue("FK1_VALOR",SE1->E1_VLCRUZ)
			oFK1BxE1:SetValue("FK1_IDDOC",cIdDoc)
			oFK1BxE1:SetValue("FK1_FILORI",SE1->E1_FILORIG)
			oFK1BxE1:SetValue("FK1_ORIGEM","FINA850")
			oFK1BxE1:SetValue("FK1_LA","S")

			If oModBxE1:VldData()
				oModBxE1:CommitData()
				RecLock("SEK",.T.)
				SEK->EK_FILIAL   := xFilial("SEK")
				SEK->EK_TIPODOC  := "CT" //CHEQUE Tercero
				SEK->EK_PREFIXO  := SE1->E1_PREFIXO
				SEK->EK_NUM      := SE1->E1_NUM
				SEK->EK_PARCELA  := SE1->E1_PARCELA
				SEK->EK_TIPO     := SE1->E1_TIPO
				SEK->EK_VALOR    := SE1->E1_VALOR
				SEK->EK_SALDO    := SE1->E1_SALDO
				SEK->EK_MOEDA    := AllTrim( Str(SE1->E1_MOEDA))
				SEK->EK_BANCO    := SE1->E1_BCOCHQ
				SEK->EK_AGENCIA  := SE1->E1_AGECHQ
				SEK->EK_CONTA    := SE1->E1_CTACHQ
				SEK->EK_ENTRCLI  := SE1->E1_CLIENTE
				SEK->EK_LOJCLI   := SE1->E1_LOJA
				SEK->EK_EMISSAO  := SE1->E1_EMISSAO
				SEK->EK_VENCTO   := SE1->E1_VENCTO
				SEK->EK_VLMOED1  := Round(xMoeda( SE1->E1_VALOR,SE1->E1_MOEDA,1, dDataBase,5,aTxMoedas[SE1->E1_MOEDA][2]),MsDecimais(1))
				SEK->EK_ORDPAGO  := cOrdpago
				SEK->EK_DTDIGIT  := dDataBase
				SEK->EK_FORNECE  := cFornece
				SEK->EK_LOJA     := cLoja
				SEK->EK_FORNEPG := cFornece
				SEK->EK_LOJAPG := cLoja
				If cPaisLoc == "ARG"
					SEK->EK_PGCBU := lCBU
				Endif
				If cPaisLoc <> "BRA"
					SEK->EK_NATUREZ := cNatureza
				Endif
				F850GrvTx()
				MsUnlock()
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !lSmlCtb
					PcoDetLan("000313","03","FINA850")
				Endif
			Else
				cLog := cValToChar(oModBxE1:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModBxE1:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModBxE1:GetErrorMessage()[6])
				Help( ,,"ORDPAG_DBDT",,cLog, 1, 0 )
				lRet := .F.
			Endif
			oModBxE1:DeActivate()
		EndIf
	EndIf
EndIf

If nPagar <> 4
	//Nao pode ser gravado documento com valor ZERO...
	If nTotal > 0
		RecLock("SEK",.T.)
		SEK->EK_FILIAL	:= xFilial("SEK")
		SEK->EK_TIPODOC	:= "CP"     //CHEQUE PROPIO
		SEK->EK_NUM		:= If( nPagar > 1	 , cNumChq, cOrdPago)
		If nPagar == 1 .AND. cPaisLoc $ "ARG|EQU|DOM|COS"
			SEK->EK_TIPO := cDebMed
		Else
			SEK->EK_TIPO := If(nPagar == 3,cDebInm,If(nPagar=2,cDebMed,"CA"))
		EndIf
		SEK->EK_FORNECE	:= cFornece
		SEK->EK_LOJA   	:= cLoja
		SEK->EK_EMISSAO	:= dDtEmis
		SEK->EK_VENCTO 	:= dDtVcto
		If  GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG" .And. nMoedaBco <> 1 .and. lPA 
			SEK->EK_VALOR  	:= Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,aTxMoedas[nMoeda][2],aTxMoedas[nMoedaBco][2]),MsDecimais(nMoedaBco))
			SEK->EK_VLMOED1	:= Round(xMoeda(nTotal,nMoedaBco,nMoedaBco,,5,aTxMoedas[nMoeda][2]),MsDecimais(1))
		Else
			SEK->EK_VALOR  	:= Round(xMoeda(nTotal,nMoeda,nMoedaBco,,5,aTxMoedas[nMoeda][2],aTxMoedas[nMoedaBco][2]),MsDecimais(nMoedaBco))
			SEK->EK_VLMOED1	:= Round(xMoeda(nTotal,nMoeda,1,,5,aTxMoedas[nMoeda][2],aTxMoedas[nMoedaBco][2]),MsDecimais(1))
		EndIf	
		SEK->EK_MOEDA 	:= AllTrim( Str( nMoedaBco))
		SEK->EK_BANCO 	:= cBanco
		SEK->EK_AGENCIA	:= cAgencia
		SEK->EK_CONTA 	:= cConta
		SEK->EK_ORDPAGO	:= cOrdpago
		SEK->EK_DTDIGIT	:= dDataBase
		SEK->EK_FORNEPG := cFornece
		SEK->EK_LOJAPG  := cLoja
		SEK->EK_PARCELA :=cParcela
		SEK->EK_PREFIXO := cPrefixo
		If cPaisLoc <> "BRA"
			IF cPaisLoc == "ARG" 
				SEK->EK_TALAO	:= cTalao
			Else 
				SEK->EK_TALAO	:= FRE->FRE_TALAO // alterado dia 19/01/12 por Caio Quiqueto dos Santos
			EndIF
			SEK->EK_NATUREZ := cNatureza
		Endif
		If cPaisLoc == "ARG"
			SEK->EK_PGCBU := lCBU
		EndIf
		If cPaisLoc $ "ARG|RUS|"			
			SEK->EK_PGTOELT := cOpcElt
			SEK->EK_MODPAGO := cModPago
		Endif
		If ExistBlock("A850PRECH")
			SEK->EK_PREFIXO := cPrefixo
		EndIf
		F850GrvTx()
		MsUnlock()
		IF (ExistBlock("F850GRA"))
			ExecBlock("F850GRA",.f.,.f.)
		Endif

		If cPaisLoc $ "ARG|RUS|"
			//-------------------------------------------
			// Atualizao cabecalho da Ordem de Pagamento
			//-------------------------------------------
			DbSelectArea("FJR")
			DbSetOrder(1) //FJR_FILIAL+FJR_ORDPAG
			If MsSeek(XFilial("FJR")+SEK->EK_ORDPAGO)
				RecLock("FJR",.F.)
				FJR->FJR_PGTELT := cOpcElt
				FJR->(MsUnlock())
			EndIf
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !lSmlCtb
			PcoDetLan("000313","04","FINA850")
		Endif
	EndIf
EndIf

If ExistBlock("A850PAG")
	ExecBLock("A850PAG",.F.,.F.)
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuaSaldosบAutor  ณLeonardo Gentile    บ Data ณ  06/01/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao dos saldos dos regs. do SE2, SE1, SA1, SA2      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuaSaldos( aDocs, nValorFor, cFornece, cLoja, nFlagMOD, nCtrlMOD, lOPRotAut )
Local nMVCusto		:=	Val(GetMv("MV_MCUSTO"))
Local nAux			:= 0
Local aLockSE2		:= {}
Local cTitulo		:= ""
Local cForne		:= ""
Local nX			:= 0
Local nLenAcol		:= 0
Local nValPag		:= 0
Local nDAtraso      := 0
Local nAuxDRet      := 0
Default nCtrlMOD	:= 0
dbSelectArea("SE2")

aLockSE2 := DbRLockList()
For nX	:=	1	TO Len( aDocs[1] )
	If !Empty(aDocs[1][nx][_RECNO] )
		MsGoto( aDocs[1][nx][_RECNO])
		nAux := Ascan(aLockSE2,Recno())
		RecLock("SE2",.F.)
		If cPaisLoc	==	"EQU"
			aDocs[1][nX][_ABATIM]    := aDocs[1][nX][3] - aDocs[1][nX][18] -	aDocs[1][nX][21]
		EndIf
		nValPag := Abs( aDocs[1][nX][_PAGAR]+aDocs[1][nX][_ABATIM]+ aDocs[1][nX][_DESCONT] - aDocs[1][nX][_JUROS] - aDocs[1][nX][_MULTA])
		Replace E2_SALDO   	With E2_SALDO - Abs( aDocs[1][nX][_PAGAR]+aDocs[1][nX][_ABATIM]+ aDocs[1][nX][_DESCONT] - aDocs[1][nX][_JUROS] - aDocs[1][nX][_MULTA])
		Replace E2_OK      	With "  "
	    nCtrlMOD-=1
	    If nCtrlMOD==0
	       nFlagMOD:=0
	    Endif
		If cPaisLoc <> "BRA" .and. E2_VLBXPAR >0  .And.  SE2->E2_VLBXPAR <=SE2->E2_SALDO
			Replace E2_VLBXPAR With  E2_VLBXPAR - Abs( aDocs[1][nX][_PAGAR]+aDocs[1][nX][_ABATIM]+ aDocs[1][nX][_DESCONT] - aDocs[1][nX][_JUROS] - aDocs[1][nX][_MULTA])
			If E2_VLBXPAR == 0
				Replace E2_PREOK With " "
			EndIf
		EndIf
		Replace E2_MOVIMEN 	With dDataBase
		Replace E2_ORDPAGO 	With cOrdPago
		Replace E2_DESCONT 	With Abs( aDocs[1][nX][_DESCONT])
		Replace E2_MULTA		With Abs( aDocs[1][nX][_MULTA])
		Replace E2_JUROS		With Abs( aDocs[1][nX][_JUROS])
		Replace E2_VALLIQ   	With Abs( aDocs[1][nX][_PAGAR])
		Replace E2_BAIXA		With If(lOPRotAut, dDataBase, dDataVenc1)

		//Verifica se existe solicitacao de NCP e caso exista atualiza o campo CU_DTBAIXA...
		If cPaisLoc <> "BRA"
			A055AtuDtBx("1",SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_BAIXA)
		EndIf
		//+--------------------------------------------------------------+
		//ฆ Baixar titulos de abatimento se for baixa total              ฆ
		//+--------------------------------------------------------------+

		IF cPaisLoc $ "ARG|EQU|DOM|COS"
			F850AtuAbt(cOrdPago)
		EndIF
		IF SE2->E2_SALDO > 0.And.SE2->E2_SALDO == aDocs[1][nX][_ABATIM].And.!(SE2->E2_TIPO$ MV_CPNEG)
			Reclock("SE2",.F.)
			Replace	E2_SALDO	With	0
			MsUnlock()
	        aLockSE2 := DbRLockList()
		    cTitulo  := xfilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
			cForne   := SE2->E2_FORNECE+SE2->E2_LOJA
		    dbSelectArea("SE2")
			DbSetOrder(1)
			DbClearFilter()
			MsSeek(cTitulo)
			While !SE2->(EOF()) .And. cTitulo  == SE2->E2_FILIAL+SE2->E2_PREFIXO+	SE2->E2_NUM+SE2->E2_PARCELA
				If SE2->E2_FORNECE+SE2->E2_LOJA == cForne .And. SE2->E2_TIPO $ MVABATIM
					nAux := Ascan(aLockSE2,Recno())
					If nAux==0
					   RecLock("SE2",.F.)
					Endif
					Replace E2_SALDO    With 0
					Replace E2_BAIXA    With dDataBase
					Replace E2_MOVIMEN  With dDataBase
					SE2->(MsUnLock())
				EndIf
				dbSkip()
			Enddo
		Endif
		MsGoto( aDocs[1][nx][_RECNO])
		If E2_SALDO == 0
			Replace E2_BAIXA   With dDataBase
		EndIf
		MsUnlock(SE2->(Recno()))
		/*-*/
		If cPaisLoc <> "ARG" .And. (lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"))
			SA2->(DbSetOrder(1))
			If SA2->(MsSeek(SE2->E2_MSFIL + SE2->E2_FORNECE + SE2->E2_LOJA))
				Reclock("SA2",.F.)
				SA2->A2_SALDUP	:= SA2->A2_SALDUP  - Round(xMoeda(nValPag,nMoedaCor,1,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(1))
				SA2->A2_SALDUPM	:= SA2->A2_SALDUPM - Round(xMoeda(nValPag,nMoedaCor,nMVCusto,,5,aTxMoedas[nMoedaCor][2],aTxMoedas[nMVCusto][2]),MsDecimais(nMVCusto))
				SA2->(MsUnlock())
			Endif
			DbSelectArea("SE2")
		Endif
		If cPaisLoc == "ARG"
			nAuxDRet := dDataBase - SE2->E2_VENCTO
			If nAuxDRet > nDAtraso
				nDAtraso := nAuxDRet
			EndIf
		EndIf
	Endif
Next

If aDocs[3] <> Nil .And. aDocs[3][1] == 4
	If !Empty(aDocs[3][3])
		nLenAcol := Len(aDocs[3][3][1]) - 2
		For nX	:=	1	To  Len(aDocs[3][3])
			If aDocs[3][3][nX][nLenAcol] > 0
				DbSelectArea("SE1")
				MsGoTo(aDocs[3][3][nX][nLenAcol])
				RecLock("SE1",.F.)
				Replace E1_SALDO     With  0
				Replace E1_BAIXA     With  dDatabase
				Replace E1_MOVIMEN   With  dDatabase
				Replace E1_STATUS    With  "B"
				If cPaisLoc == "ARG"
					Replace E1_FORNECE	With cFornece
					Replace E1_LOJAFOR	With cLoja
				EndIf
				MsUnlock(Recno())
				SA1->(DbSetOrder(1))
				SA1->(MsSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA))
				IF SA1->(FOUND())
					AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,aTxMoedas[SE1->E1_MOEDA][2],SE1->E1_EMISSAO)
				EndIf
			EndIf
		Next nX
	Endif
EndIf
If cPaisLoc == "ARG" .And. (lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"))
	SA2->(DbSetOrder(1))
	If SA2->(MsSeek(SE2->E2_MSFIL + SE2->E2_FORNECE + SE2->E2_LOJA))
		Reclock("SA2",.F.)
		SA2->A2_SALDUP	:= SA2->A2_SALDUP  - Round(xMoeda(nValorFor,nMoedaCor,1,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(1))
		SA2->A2_SALDUPM	:= SA2->A2_SALDUPM - Round(xMoeda(nValorFor,nMoedaCor,nMVCusto,,5,aTxMoedas[nMoedaCor][2],aTxMoedas[nMVCusto][2]),MsDecimais(nMVCusto))
		If nValorFor > 0 .And. SA2->A2_MATR < nDAtraso
			SA2->A2_MATR := nDAtraso
		EndIf
		SA2->(MsUnlock())
	Endif
	DbSelectArea("SE2")
ElseIf !(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"))
	DbSelectArea("SA2")
	DbSetOrder(1)
	MsSeek(xFilial("SA2")+cFornece+cLoja)
	If Found()
		Reclock("SA2",.F.)
		SA2->A2_SALDUP	:= SA2->A2_SALDUP  - Round(xMoeda(nValorFor,nMoedaCor,1,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(1))
		SA2->A2_SALDUPM	:= SA2->A2_SALDUPM - Round(xMoeda(nValorFor,nMoedaCor,nMVCusto,,5,aTxMoedas[nMoedaCor][2],aTxMoedas[nMVCusto][2]),MsDecimais(nMVCusto))
		If cPaisLoc == "ARG" .And. nValorFor > 0 .And. SA2->A2_MATR < nDAtraso
			SA2->A2_MATR := nDAtraso
		EndIf
		MsUnlock()
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850MarkAll บAutor  ณBruno Sobieski   บFecha ณ  01/09/01   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de marca Tudo definida aqui para usar a F850Mark    บฑฑ
ฑฑบ          ณ e tratar os locks do SE2.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850MarkAll(nFlagMOD,nCtrlMOD,cAlias1,lIni)
Local nRecno		:=	Recno()
Local aArea		:= GetArea()
Local cMFecrd	:= GetMark()

DEFAULT nFlagMOD 	:= 0
DEFAULT cAlias1		:= ""
Default lIni :=.F.

DbSelectArea(cAliasTmp)
(cAliasTmp)->(dbSetOrder(1))
(cAliasTmp)->(DbClearFilter())

(cAliasTmp)->(MsSeek(xFilial("SE2")))
If cPaisLoc$"DOM|COS"
   (cAliasTmp)->(dbGoTop())
   If nFlagMOD==0
      If lFindITF .And. FinProcITF(SE5->(RECNO()),1,,,,,(cAlias)->E2_NATUREZ)
         MsgAlert(STR0210)//"Sera selecionado apenas Titulos sem incid๊ncia de ITF.")
       Else
         MsgAlert(STR0209)//"Sera selecionado apenas Titulos sem incid๊ncia de ITF.")
      Endif
     Else
      If nFlagMOD==1
         nFlagMOD:=22
         MsgAlert(STR0209)//"Sera selecionado apenas Titulos sem incid๊ncia de ITF.")
       Else
         nFlagMOD:=11
         MsgAlert(STR0210)//"Sera selecionado apenas Titulos com incid๊ncia de ITF.")
      Endif
   Endif
Endif
While !(cAliasTmp)->(EOF())
	//Pois o click na bMarkAll, chama tanto a markall como a makr
	If !lFiltra
		If (cAliasTmp)->E2_SALDO > 0 .And. (cAliasTmp)->E2_FILIAL == xFilial("SE2")
			F850Mark(.T.,@nFlagMOD,@nCtrlMOD)
		EndIf
	Else
		If (!empty(cContCor) .And. lWsFeCred .And. !IsMark("E2_OK",cMFecrd,.F.) .And. lIni) .Or. (!empty(cContCor) .And. lWsFeCred .And. lMarca)  
			F850Mark(.T.,@nFlagMOD,@nCtrlMOD,lIni) 
		Else
			F850Mark(.T.,@nFlagMOD,@nCtrlMOD)
		Endif
	EndIf
	(cAliasTmp)->(dbSkip())
Enddo
dbSelectArea(cAliasTmp)
(cAliasTmp)->(dbSetOrder(1))

RestArea(aArea)
(cAliasTmp)->(MsGoTo(nRecno))

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850Mark บAutor  ณBruno Sobieski      บFecha ณ  01/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de marca da MarkBrowse, definida aqui para tratar os บฑฑ
ฑฑบ          ณ locks do SE2 a efeitos ad concorrencia de processos.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850Mark(lAll,nFlagMOD,nCtrlMOD,lIni)
Local lRet	:=	.F.
Local nX	:=	0
Local lValid
Local aHelpEspP
Local aHelpPorP
Local aHelpEngP
Local lGrpSF2:=.T.
Local lGrpSPA:=.T.
Local lGrpSNF:=.T.
Local cGrupoPA:=""
Local cGrupo :=""
Local nNum
Local lValida:=.T.
Local lTestCQ := .F.
Local lAbleCQ := GetNewPar( "MV_FINCQ" , .F. )  //Habilita ou nao a Verificacao de Qualidade
Local lWsFeCred := SuperGetMV( "MV_WSFECRD", .F., .F. ) 
Local cNatdig := ' '
Local aPostit := Getarea()
Local cChvSE2 := ' '
Local lOK := .F.
Local lMRet 	:=.T.
Local nValOP	:= 0

DEFAULT nFlagMOD 	:= 0
DEFAULT lIni 		:= .T.

lAll	:=	Iif(lAll==Nil,.F.,lAll)

DbSelectArea(cAliasTmp)

If (cAliasTmp)->APROVADO == "N"
	Return
EndIf
If !empty(cContCor) .And. lWsFeCred .And. !Empty((cAliasTmp)->E2_OK) .and. lIni 
	Return ()
Endif
//Valida se ha saldo com OPs eletr๔nicas
If cPaisLoc $ "ARG"

	nValOP += (cAliasTmp)->E2_SALDO
	nValOP -= F850RecPgt((cAliasTmp)->E2_PREFIXO,(cAliasTmp)->E2_NUM,(cAliasTmp)->E2_PARCELA,(cAliasTmp)->E2_TIPO,(cAliasTmp)->E2_FORNECE,(cAliasTmp)->E2_LOJA)

	If nValOP = 0
		Alert(STR0373) //"O saldo deste tํtulo esta comprometido em Ordens de Pago eletr๔nicas."
		Return
	EndIf

EndIf

dbSelectArea(cAliasTmp)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณO titulo que teve seu ajuste de saldo por dif. de cambio nao pode ser baixado emณ
//ณdata anterior ao ajuste, porque senao o ajuste feito seria sobre o saldo errado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cPaisLoc == "ARG"
	If (cAliasTmp)->E2_DTDIFCA >= dDataBase
		If !lAll
			Help('',1,'BXDIFCAMB')
			Return
		Endif
	Endif
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Argentina - Executa a verificacao de Material em Controle de Qualidade ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cPaisLoc == "ARG" .And. lAbleCQ

	If !((cAliasTmp)->E2_TIPO $ MV_CPNEG+"/"+MVPAGANT)

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Nao quero que acione a verificacao se ja estiver marcado ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       If IsMark( "E2_OK", cMarcaE2, .F. )

          lTestCQ := .F.

       Else

          lTestCQ := OnOrRejQA( (cAliasTmp)->E2_NUM, (cAliasTmp)->E2_PREFIXO, (cAliasTmp)->E2_FORNECE, (cAliasTmp)->E2_LOJA )

       EndIf

       If lTestCQ
          //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
          //ณ Titulo NAO Liberado para a Selecao ณ
          //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

          Aviso( OemToAnsi(STR0223), OemToAnsi(STR0367) , {'Ok'} )  // Atencao # "Este Titulo foi gerado por uma NF, cujos itens se encontram em processo de Inspe็ใo de Qualidade. Nessas condi็๕es, a sele็ใo ้ recusada."

          Return

       EndIf

	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Caso esteja ligado o controle de solicitacao de notas de credito e exista alguma ณ
//ณ pendencia para este titulo                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SCU->(DbSetOrder(2))
If cPaisloc <> "BRA" .And. SuperGetMv('MV_SOLNCP') .And. (cAliasTmp)->E2_TIPO == MVNOTAFIS ;
		.And. SCU->(MsSeek(xFilial()+(cAliasTmp)->E2_FORNECE+(cAliasTmp)->E2_LOJA+(cAliasTmp)->E2_NUM+(cAliasTmp)->E2_PREFIXO)).And. Empty(SCU->CU_NCRED)
	If !lAll
		HELP(" ",1,"SOLNCPAB")
	Endif
Else
	If IsMark("E2_OK",cMarcaE2,.F.)
		RecLock(cAliasTmp,.F.)
		Replace E2_OK With "  "
        nCtrlMOD-=1
        If nCtrlMOD==0
           If nFlagMOD=22
              nFlagMOD:=2
             Elseif nFlagMOD=11
              nFlagMOD:=1
             Else
              nFlagMOD:=0
           Endif
        Endif
		MsRUnLock((cAliasTmp)->E2_RECNO)
		nX := aScan(aRecNoSE2,{|x| x[8] == (cAliasTmp)->E2_RECNO})
		aDel(aRecNoSE2, nX)
		aSize(aRecNoSE2, Len(aRecNoSE2)-1)
		If cPaisloc = "ARG"
			If SA2->(MsSeek( xFilial( "SA2" ) + (cAliasTmp)->E2_FORNECE + (cAliasTmp)->E2_LOJA, .F. ))
				If VldFchCBU()
					If Len(aPagConCBU) > 0
						nLoop := aScan(aPagConCBU,{|x| x[5] == (cAliasTmp)->E2_RECNO})
						aDel(aPagConCBU, nLoop)
						aSize(aPagConCBU, Len(aPagConCBU)-1)
						nLoop := 0
					EndIf
				Else
					If Len(aPagSinCBU) > 0
						nLoop := aScan(aPagSinCBU,{|x| x[5] == (cAliasTmp)->E2_RECNO})
						aDel(aPagSinCBU, nLoop)
						aSize(aPagSinCBU, Len(aPagSinCBU)-1)
						nLoop := 0
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		lValid := F850MrKb(lAll)
		If nFlagMOD=11
		   nFlagMOD:=1
		Endif
		If nFlagMOD=22
		   nFlagMOD:=2
		Endif
		If lValid
			For nX	:=	0	To 1 STEP 0.2
				If (cAliasTmp)->(MsRLock())
				   IF CPAISLOC$"DOM|COS"
				      if nFlagMOD==0
				         lMRet:=	.T.
				         If lFindITF .And. FinProcITF( SE5->(RECNO()),1,,,,,(cAliasTmp)->E2_NATUREZ )
				            nFlagMOD:=1
				           Else
				            nFlagMOD:=2
				         Endif
				        Else
				         If nFlagMOD==1
  				            If lFindITF .And. FinProcITF( SE5->(RECNO()),1,,,,,(cAliasTmp)->E2_NATUREZ )
  				               lMRet:=	.T.
  				              Else
  				               lMRet:=	.F.
  				            Endif
  				          Else
  				            If lFindITF .And. FinProcITF( SE5->(RECNO()),1,,,,,(cAliasTmp)->E2_NATUREZ )
  				               lMRet:=	.F.
  				              Else
  				               lMRet:=	.T.
  				            Endif
				         Endif
				      Endif
				   Endif
				   If (cPaisLoc $ "ARG|RUS") .And. (lMRet)
				   		lMRet := VldDocPag((cAliasTmp)->E2_RECNO)
				   EndIf
				   If lMRet
						RecLock(cAliasTmp,.F.)
				  		Replace E2_OK With cMarcaE2
						nX	:=	1
						lRet:=	.T.
						AAdd(aRecNoSE2,{(cAliasTmp)->E2_FILIAL,(cAliasTmp)->E2_FORNECE,(cAliasTmp)->E2_LOJA,;
						(cAliasTmp)->E2_PREFIXO,(cAliasTmp)->E2_NUM,(cAliasTmp)->E2_PARCELA,;
						(cAliasTmp)->E2_TIPO,(cAliasTmp)->E2_RECNO,0,"","","","","","",""})
				      nCtrlMOD+=1
				      If nCtrlMOD==0
				         nFlagMOD:=0
				      Endif
					 Else
					   IF CPAISLOC$"DOM|COS"
					      If nFlagMOD==1 .AND. !lAll
				            MsgAlert(STR0211)//"Selecione apenas Titulos com incid๊ncia de ITF.")
				         Endif
					      If nFlagMOD==2 .AND. !lAll
				            MsgAlert(STR0212)//"Selecione apenas Titulos sem incid๊ncia de ITF.")
				         Endif
				   	 ENDIF
				       EXIT
				    Endif
				  Else
					Inkey(0.2)
				Endif
			Next
			If !lRet .And. !lAll .AND. lMRet
				MsgAlert(OemToAnsi(STR0130)) //"El titulo esta en uso y no puede ser marcado en este momento"
			Endif
		EndIf
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850CmpMoบAutor  ณBruno Sobieski      บFecha ณ  01/10/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao recursiva para aplicar os valores recebidos em moeda บฑฑ
ฑฑบ          ณdiferente a dos titulos, nestes mesmos titulos.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850CmpMoed(aTitPags)
Local nA,nP,nPago	:=	0

For nA	:= 1	To Len(aTitPags)
	If aTitPags[nA]	>	0
		For nP	:=	1	To Len(aTitPags)
			If aTitPags[nA]	>	0
				If aTitPags[nP]	<	0
					nPago	:=	Round(xMoeda(aTitPags[nP],nP,nA,,MsDecimais(nA)+1,aTxMoedas[nP][2],aTxMoedas[nA][2] ),MsDecimais(nA) )
					//NP e o valor nPago e sempre negativo
					If Abs(nPago) > aTitPags[nA]
						aTitPags[nP]	+=	Round(xMoeda(aTitPags[nA],nA,nP,,MsDecimais(nP)+1,aTxMoedas[nA][2],aTxMoedas[nP][2] ),MsDecimais(nP) )
						aTitPags[nA]	:=	0
					ElseIf Abs(nPago) <  aTitPags[nA]
						aTitPags[nA]	+=	nPago
						aTitPags[nP]	:=	0
					Else
						aTitPags[nA]	:=	0
						aTitPags[nP]	:=	0
					Endif
				Endif
			Else
				Exit
			Endif
		Next
	Endif
Next
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VldDeบAutor  ณMicrosiga           บFecha ณ  01/12/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a digitacao do % de desconto e do valor de desconto. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850VldDe(nOpc,aDescontos,bZeraRets,nValAdic)
Local nPosTipE2	:=	Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_TIPO"})
Local nPosMoeE2	:=	Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_MOEDA"})
Local nPosPagE2	:=	Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_PAGAR"})
Local nPosJurE2	:=	Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_JUROS"})
Local nPosMulE2	:=	Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_MULTA"})
Local nPosSalE2	:=	Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_SALDO"})
Local nPosDesE2	:=	Ascan(oGetDad0:aHeader,{ |x| Alltrim(x[2])=="E2_DESCONT"})
Local nTotNet	:=	0
Local nTotBrut	:=	0
Local nValAnt	:=	0
Local lRet		:=.T.
Local nX		:= 0
Local nP        := 	0
Local nValOri	:=	0
Local nRetAbt   := 	0

DEFAULT nValAdic	:=	0

nPosDesc := nPosDesE2

If nOpc	==	2	// Valor
	If nValDesc >= nValBrut
		lRet	:=	.F.
		Help("",1,"No 100 %")
	Else
		If cPaisLoc $ "ARG"
			Eval(bZeraRets)
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRatear o Total do desconto nas Notas Fiscaisณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPorDesc:=	(nValDesc * 100 ) / nValBrut
		For nX:=1	To	Len(oGetDad0:aCols)
			nValOri	:=	(oGetDad0:aCols[nX][1] + oGetDad0:aCols[nX][nPosDesc] /*+ oGetDad0:aCols[nX][nPosJurE2] + oGetDad0:aCols[nX][nPosMulE2]*/)
			If cPaisLoc == "EQU"
				oGetDad0:aCols[nX][1]  += oGetDad0:aCols[nX][17]
			EndIf
			If !oGetDad0:aCols[nX][Len(oGetDad0:aCols[nX])]  .And. !(oGetDad0:aCols[nX][nPosTipE2] $ MVPAGANT+"/"+MV_CPNEG)
				aDescontos[nX]	:=	Round(((oGetDad0:aCols[nX][1] + oGetDad0:aCols[nX][nPosDesc] + oGetDad0:aCols[nX][nPosJurE2] + oGetDad0:aCols[nX][nPosMulE2])*nPorDesc /100),nDecs)
			Endif
			If cPaisLoc == "EQU"
				nValOri       := oGetDad0:aCols[nX][1]  + aDescontos[nX]
				nRetAbt       := oGetDad0:aCols[nX][17]
			EndIf
			oGetDad0:aCols[nX][nPosDesc]  :=  aDescontos[nX]
			oGetDad0:aCols[nX][nPosPagE2] := nValOri - aDescontos[nX]
			oGetDad0:aCols[nX][nPosSalE2] := (aPagar[nX] + oGetDad0:aCols[nX][nPosJurE2] + oGetDad0:aCols[nX][nPosMulE2]) - (aDescontos[nX]+ oGetDad0:aCols[nX][nPosPagE2])
			oGetDad0:aCols[nX][nPosDesc]  :=  aDescontos[nX]
			If oGetDad0:aCols[nX][nPosPagE2] < 0
				oGetDad0:aCols[nX][nPosSalE2]+= oGetDad0:aCols[nX][nPosPagE2]
	 			oGetDad0:aCols[nX][nPosPagE2]:= 0
			Endif
			If cPaisLoc == "EQU"
				nValOri       := oGetDad0:aCols[nX][15]
				oGetDad0:aCols[nX][1]  := nValOri - oGetDad0:aCols[nX][19] - nRetAbt
				oGetDad0:aCols[nX][2]  := nValOri - oGetDad0:aCols[nX][19] - nRetAbt
			EndIf
		Next
		nValLiq := 0
		Aeval(oGetDad0:aCols,{|x,y|,Iif(oGetDad0:aCols[y][nPosTipE2] $	MV_CPNEG+"/"+MVPAGANT,nValLiq -= Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)),nValLiq += Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))})
		nValLiq	+=	nValAdic

		oPorDesc:Refresh()
		oValDesc:Refresh()
		oGetDad0:SetArray(oGetDad0:aCols)
		oGetDad0:oBrowse:Refresh()
		oGetDad0:Refresh()
	Endif
Else
	nValDesc	:=	0
	If cPaisLoc $ "ARG"
		Eval(bZeraRets)
	Endif
	For nX:=1	To	Len(oGetDad0:aCols)
		If !oGetDad0:aCols[nX][Len(oGetDad0:aCols[nX])]  .And. !(oGetDad0:aCols[nX][nPosTipE2] $ MVPAGANT+"/"+MV_CPNEG) .And.  nPorDesc <> 0
			If cPaisLoc == "EQU"
				oGetDad0:aCols[nX][1]  := oGetDad0:aCols[nX][15]-oGetDad0:aCols[nX][nPosDesc]-oGetDad0:aCols[nX][nPosJurE2]-oGetDad0:aCols[nX][nPosMulE2]
				oGetDad0:aCols[nX][2]  := oGetDad0:aCols[nX][1]
				nRetAbt       := oGetDad0:aCols[nX][17]
			EndIf
 			If nPosDesc > 0
				nValOri					:=	oGetDad0:aCols[nX][1]+oGetDad0:aCols[nX][nPosDesc]//+oGetDad0:aCols[nX][nPosJurE2]+oGetDad0:aCols[nX][nPosMulE2])
				oGetDad0:aCols[nX][nPosDesc]	:=	Round(nValOri* nPorDesc / 100,nDecs)
				nValDesc 			+=	Round(xMoeda(oGetDad0:aCols[nX][nPosDesc],oGetDad0:aCols[nX][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[nX][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2],nDecs),MsDecimais(nMoedaCor))
				aDescontos[nX]		:=	Round(oGetDad0:aCols[nX][nPosDesc],nDecs)
			Else
				nValDesc 			+=	Round(xMoeda(nValBrut,oGetDad0:aCols[nX][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[nX][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2],MsDecimais(nMoedaCor)) * nPorDesc / 100,nDecs)
				aDescontos[nX]		:=	Round(oGetDad0:aCols[nX][nPosPagE2]* nPorDesc / 100,nDecs)
			Endif
			oGetDad0:aCols[nX][nPosDesc]	:= Round(xMoeda(oGetDad0:aCols[nX][nPosDesc],nMoedaCor,oGetDad0:aCols[nX][nPosMoeE2],,nDecs+1,aTxMoedas[nMoedaCor][2],aTxMoedas[oGetDad0:aCols[nX][nPosMoeE2]][2]),MsDecimais(nMoedaCor))
		Endif
		If nPorDesc == 0
			oGetDad0:aCols[nX][nPosDesc]  := 0
			oGetDad0:aCols[nX][nPosPagE2] += aDescontos[nX]
			oGetDad0:aCols[nX][nPosSalE2] += oGetDad0:aCols[nX][nPosJurE2]+oGetDad0:aCols[nX][nPosMulE2]
		ElseIf cPaisLoc == "EQU"
			oGetDad0:aCols[nX][nPosPagE2] 	:= oGetDad0:aCols[nX][15] - nRetAbt - aDescontos[nX]
			oGetDad0:aCols[nX][2]  			:= oGetDad0:aCols[nX][1]
		Else
			oGetDad0:aCols[nX][nPosPagE2] := 	nValOri - aDescontos[nX]
			oGetDad0:aCols[nX][nPosSalE2] +=	oGetDad0:aCols[nX][nPosPagE2]
		EndIf
		If oGetDad0:aCols[nX][nPosPagE2] < 0
			oGetDad0:aCols[nX][nPosSalE2]+= oGetDad0:aCols[nX][nPosPagE2]
 			oGetDad0:aCols[nX][nPosPagE2]:= 0
		EndIf
	Next
	nValLiq := 0
	Aeval(oGetDad0:aCols,{|x,y|,Iif(oGetDad0:aCols[y][nPosTipE2] $	MV_CPNEG+"/"+MVPAGANT,nValLiq -= Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)),nValLiq += Round(xMoeda(oGetDad0:aCols[y][nPosPagE2],oGetDad0:aCols[y][nPosMoeE2],nMoedaCor,,nDecs+1,aTxMoedas[oGetDad0:aCols[y][nPosMoeE2]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))})
	nValLiq	+=	nValAdic
	oGetDad0:Refresh()
Endif

lRetenc	:=	.F.
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850PgAdiบAutor  ณBruno Sobieski      บFecha ณ  01/16/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPagamento adiantado(PA).                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850PgAdi(lIncAdt,cCodFor,cLojFor,aRecAdt,cSolic)
//Wilson incluido cSolic em 28/12/11
Local aCpos	:=	{}
Local oPagar
Local oGetDad,oDlg
local OBROWSE
Local lConfirmo	:=	.F.
Local cTmp	:=	""
Local cBox	:=	""
Local cContBox1	:=	"1="+OemToAnsi(STR0138)+";2="+OemToAnsi(STR0086)+";3="+OemToAnsi(STR0139) //Debito Mediato#Debito Inmediato#Cheques de Terceros
Local cContBox2	:=	""
Local oBAnco,oAgencia,oConta
Local oProv
Local oCF
Local oFnt
Local oObj
Local oDataTxt1,oTipo
Local oDataTxt2
Local oChkBox
Local oDataVenc,oDataVenc1
Local oCbx1,oCbx2
Local oAliqigv
Local nX,nP
Local oFor	,	cFor	:=""
Local oMod	,	cMod	:=""
Local oRet,nRet	:=	0,oLiquido,aConGan
Local oRetIB, nRetIB:=0
Local oRetIVA, nRetIVA:=0
Local oRetSUSS, nRetSUSS:=0
Local nBaseRIE:=nAliqRIE:=nRetRIE:=0
LOCAL nRetIGV :=0
Local nRetIR  := 0
Local aSE2		:=	{}
Local aSize	:= {}
Local nMoedaPag	:=	1
Local nA		:= 0
Local cPerg		:= "FIN850P"
Local aRotinaOld:= If(Type("aRotina")=="A",aClone(aRotina),{})
Local aHeaderOld:= If(Type("aHeader")=="A",aClone(aHeader),{})
Local aColsOld  := If(Type("aCols")=="A",aClone(aCols),{})
Local nOld      := If(Type("n")=="N",n,1)
Local nBaseIGV  := 0 // valor base para caculo da reten็ao do igv
Local nAliqIGV  := 0 // aliquota para calculo do valor do igv a ser retido
Local aButtons	 := If(cPaisLoc=="ARG",	{ 	{"NOTE"   ,{||   F850ImpPA(,@aSE2,@cFor,@oFor,oRet,@nRet,nVlrPagar,@nLiquido,oLiquido,@nRetIb,oRetIb,@nRetIva,oRetIva,@nRetSuss,oRetSuss)},OemToAnsi(STR0189)}},{})
Local nImpRet      := 0
Local nI           := 0
Local nC			:= 0
Local lCBU		   := .F.
Local nMinCBU	   := GetMV("MV_MINCBU",.F.,0)
Local lMonotrb	   := .F.
Local lImpCert     := (GetNewPar("MV_CERTRET","N") == "S")
Local nXPagar	   := 0
Local lOculta		:= .F.
Local lF85NoInfo	:= ExistBlock("F85NOINFO")
Local aCols3os		:= {}
Local aColsPg		:= {}
Local cCliente		:= CriaVar("E1_CLIENTE")
Local cLojaCli		:= CriaVar("E1_LOJA")
Local aTipoDocto	:= {}
Local cTipoDocto	:= ""
Local nUnico		:= 0
Local nMultiplo		:= 0
Local oSolFun
Local aUnico		:= {OemToAnsi(STR0243) ,OemToAnsi(STR0239),OemToAnsi(STR0240),OemToAnsi(STR0241)}
Local aMultiplo 	:= {OemToAnsi(STR0243),OemToAnsi(STR0244)}

//Pagamento Eletronico
Local oPnlSep3
Local oPnlPgElt

Private oPgtoElt
Private cPgtoElt	:= STR0048 //Default = NรO
Private cOpcElt	:= ""
Private oPnlMoeda
Private oMoedaPA
Private cMoedaPA   := ""
Private cMoedaTemp := ""
Private nMoedaTCor := 1

Private lImpVal	   := .F.
Private dDataVenc  := dDataBase
Private dDataVenc1 := dDataBase
Private nValor	   := 0, oValor, oMsg1, oValpag, oSaldo
Private aPagos	   := {}
Private cBanco	   := Criavar("A6_COD"),cAgencia	:=	Criavar("A6_AGENCIA"),cConta:=Criavar("A6_NUMCON")
Private cProv	   := Criavar("A2_EST")
Private cCF	       := Criavar("F4_CODIGO")
Private nGrpSus    := Criavar("FF_GRUPO")
Private cZnGeo     := Criavar("FF_ITEM")
Private cSerieNF   := Criavar("FF_SERIENF")  
Private cNumOp     := Iif(cPaisLoc == "ARG" ,Criavar("EK_NUMOPER"),"")
Private nTotAnt    := Iif(cPaisLoc == "ARG" ,Criavar("EK_TOTANT")  ,"")
Private aDebMed	   := {}	,	aDebInm:={}
Private nPagar	   := 4
Private nLiquido	:= 0
Private aRecChqTer := {}
Private aSaldos	   := Array(MoedFin()+1)
Private cFornece   := CriaVar("E2_FORNECE")
Private oFornece
Private cLoja      := CriaVar("E2_LOJA")
Private oLoja
Private oNatureza
Private cNatureza	:=Iif(cPaisLoc <> "BRA",Criavar("EK_NATUREZ"),Criavar("ED_CODIGO"))
Private aCtrChEQU	:= {}
Private cDebMed		:= ""
Private cDebInm		:= ""
Private nNumOrdens	:= 1
Private nVlrNeto		:= 0
Private cAprov   := ""
Private oAprov

Private aPagar	    := {}
Private aVlPA		:= {0,0,0,0}
Private bRecalc	    := {||}
Private bAtuOP		:= {||}
Private aTipoTerc	:= {}
Private aDoc3osUtil	:= {}
Private oGetDad0
Private oGetDad1
Private oGetDad2
/*_*/
Private nSaldoPgOP	:= 0
Private nTotDocTerc	:= 0
Private nTotDocProp	:= 0
Private oSaldoPgOP
Private oTotDocTerc
Private oTotDocProp
/*_*/
Private lSolicFundo	:= GetMV("MV_FINCTAL",.F.,"1") == "2"
Private cSolFun		:= cSolic

DEFAULT aRecAdt	:= {}
DEFAULT cCodFor	:= ""
DEFAULT cLojFor	:= ""
DEFAULT lIncAdt	:= .F.
DEFAULT cSolic	:= "" //Wilson em 28/12/11

If lF85NoInfo
	lOculta := ExecBlock("F85NOINFO",.F.,.F.)
EndIf

If  cPaisLoc == "ARG" .And. !lSolicFundo
	If  Type("aMoeda") == "U"	
		aMoeda := {}
		Aadd(aMoeda,MV_MOEDA1)
		For nC:= 2 To Len(aTxMoedas)
			Aadd(aMoeda,aTxMoedas[nC][1])
		Next
	Endif
Endif

//ANGOLA - Inclusao de adiantamento para relacionar com pedido
//Variแveis Private declaradas no inicio do FINF850 e necessแrias para a
//chamada direta desta fun็ใo.
//NAO TRASFORME EM LOCAL !!!!
If lIncAdt
	aTxMoedas	:= F850TxMoed()
	aRotina		:= MenuDef(@nFlagMOD,@nCtrlMOD)
	aRecNoSE2	:= {}
	lRetPA		:=	(GetNewPar("MV_RETPA","N") == "S")
	cFornece		:= cCodFor
	cLoja			:= cLojFor
	lBaixaChq	:=	.F.
	cForDe   	:= cCodFor
	cForAte  	:= cCodFor
	nDecs			:=	MsDecimais(1)
	cDocCred		:= SuperGetMV("MV_TPADTCD",.T.,Substr(MVPAGANT,1,3))

	//Posiciono SA2 para obter nome do fornecedor
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja))
	cFor			:= SA2->A2_NREDUZ //SA2->A2_NOME

	//Carrega pergunte para obter variaveis de contabilizacao
	Pergunte(cPerg,.F.)
	lDigita	:= (mv_par07==1)
	lAglutina	:= (mv_par08==1)
	lGeraLanc	:= (mv_par09==1)
	cArquivo	:= ""
	nHdlPrv	:= 1
	nTotalLanc	:= 0
	cLoteCom	:= ""
	lLancPad70	:= .F.

	If lGeraLanc
		lLancPad70 := VerPadrao("570")
	EndIf

	If nMVCusto == Nil
		nMVCusto	:=	Val(GetMv("MV_MCUSTO"))
	Endif

Endif

If Type("lRetPA") == "U"
	lRetPA := (GetNewPar("MV_RETPA","N") == "S")
EndIf


aFill(aSaldos,0)
AAdd(aSE2,{{},{},{4,{},{},0,0,0,1},{},.F.})
// Verifica se pode ser incluido mov. com essa data
If !(dtMovFin(dDataBase) )
	Return  .F.
EndIf
nMoedaCor	:=	1
//Forco para que seja inclusao
//aRotina[4][4]	:=	3
/*
Verifica as formas de pagamento*/
aDebMed := {}
aDebInm := {}
aTipoTerc := {}
aTipoDocto := {"Todos"}
cTipoDocto  := aTipoDocto[1]
cDocPg := ""
aFormasPgto := Fin025Tipo()
For nC := 1 To Len(aFormasPgto)
	If aFormasPgto[nC,5] $ "13" .And. aFormasPgto[nC,7]		//documentos de terceiros
		Aadd(aTipoTerc,Aclone(aFormasPgtop[nC]))
		Aadd(aTipoDocto,aFormasPgto[nC,3])
	Endif
	If aFormasPgto[nC,5] $ "23"
		If aFormasPgto[nC,4] == "1" //gera movimento bancario
			Aadd(aDebInm,aFormasPgto[nC,1])
		Else   
			Aadd(aDebMed,aFormasPgto[nC,1])
		Endif
		If !Empty(cDocPg)
			cDocPg += ";"
		Endif
		cDocPg += (AllTrim(aFormasPgto[nC,1]) + "=" + Alltrim(aFormasPgto[nC,3]))
	Endif
Next
If Len(aDebMed) ==	0
	aDebMed	:=	{MVCHEQUE}
Endif
If cPaisLoc<>"PER"
   cDebMed	:=	aDebMed[1]
Endif
If Len(aDebInm) ==	0
	If Ascan(aDebmed,"TF") = 0
		AAdd(aDebInm,"TF")
	EndIf
	If Ascan(aDebMed,"EF") = 0
		AAdd(aDebInm,"EF")
	EndIf
	If Len(aDebInm) ==	0
		AAdd(aDebInm,"")
	EndIf
Endif
If cPaisLoc<>"PER"
   cDebInm	:=	aDebInm[1] + Iif(Len(aDebInm) > 1,"|" + aDebInm[2],"")
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializar o aHeader e o aCols.            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aHeaderPg := {}
aColsPg := {}
aCposPg := {"EK_TIPO","EK_BANCO","EK_AGENCIA","EK_CONTA","EK_MOEDA","EK_TALAO","FRE_TIPO","EK_PREFIXO","EK_NUM","EK_PARCELA","EK_EMISSAO","EK_VENCTO","EK_MOEDA","NPORVLRPG","EK_VALOR"}
aGetPg := {"EK_TIPO","EK_BANCO","EK_AGENCIA","EK_MOEDA","EK_TALAO","EK_PREFIXO","EK_NUM","EK_PARCELA","EK_EMISSAO","EK_VENCTO","NPORVLRPG","EK_VALOR"}
nAux := 0
DbSelectArea("SX3")
DbSetOrder(2)
For nC := 1 To Len(aCposPg)
	If SX3->(MsSeek(PadR(aCposPg[nC],Len(SX3->X3_CAMPO))))
		Do Case
			Case aCposPg[nC] == "EK_TIPO"
				Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldTipo(.T.)",X3_USADO,X3_TIPO,"FJSP",X3_ARQUIVO,"","","","","","",.F.})
			Case aCposPg[nC] == "EK_TALAO"
				If cPaisLoc =="ARG" .AND. SXB->(MsSeek(PADR("F850AR", Len(SXB->XB_ALIAS))))
					Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldTalao()",X3_USADO,X3_TIPO,"F850AR",X3_ARQUIVO,"","","","","","",.F.})
				Else
					Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldTalao()",X3_USADO,X3_TIPO,"FRE850",X3_ARQUIVO,"","","","","","",.F.})
				EndIf
			Case aCposPg[nC] == "FRE_TIPO"
				Aadd(aHeaderPg,{Alltrim(X3Descric()),X3_CAMPO,"",Len(SX3->X3_DESCRIC),0,"F850Vlds()",X3_USADO,"C","",X3_ARQUIVO,"","","","","","",.F.})
			Case aCposPg[nC] == "EK_VALOR"
				Aadd(aHeaderPg,{STR0315,"NPORVLRPG","@E 999.99",6,2,"Positivo().And.F850VlPg()",X3_USADO,"N","",X3_ARQUIVO,"","","","","","",.F.}) //"% Pgto"
				Aadd(aHeaderPg,{Alltrim(STR0174),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"Positivo().And.F850VlPg()",X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO})
			Case aCposPg[nC] == "EK_MOEDA"
				nAux++
				If nAux == 1
					Aadd(aHeaderPg,{Alltrim(STR0307),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850Vlds()",X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO}) //"Moeda banco"
				Else
					Aadd(aHeaderPg,{AllTrim(X3Titulo()),"MOEDAPGTO",X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850Vlds()",X3_USADO,"N","",X3_ARQUIVO,,"nMoedaCor"})
				Endif
			Case aCposPg[nC] == "EK_VENCTO" //Validaci๓n para fecha de vencimiento.
				Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldVct()",X3_USADO,X3_TIPO,"",X3_ARQUIVO,"","","","","","",.F.})		
			Case aCposPg[nC] == "EK_BANCO"  .And. cPaisLoc == "ARG" .And. !lSolicFundo .And. IsInCallStack("SELPAGO")
				Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850Vlds(,,.T.)",X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO})
			OtherWise 
				Aadd(aHeaderPg,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850Vlds()",X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO})
		EndCase
	Endif
Next
Aadd(aColsPg,Array(Len(aHeaderPg)+1))
For nC := 1 To Len(aHeaderPg)
	If aHeaderPg[nC,2] == "NPORVLRPG"
		aColsPg[1,nC] := 0
	ElseIf aHeaderPg[nC,2] == "MOEDAPGTO"
		aColsPg[1,nC] := nMoedaCor
	Else
		aColsPg[1,nC] := Criavar(AllTrim(aHeaderPg[nC,2]))
	Endif
Next
aColsPg[1,Len(aColsPg[1])] := .F.
/*
tabela para documentos de terceiros */
aHeader3os := {}
aCols3os := {}
aCpos3os := {"E1_TIPO","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_EMISSAO","E1_VENCREA","E1_SALDO","E1_MOEDA","E1_CLIENTE","E1_LOJA","E1_NOMCLI"}
DbSelectArea("SX3")
DbSetOrder(2)
For nC := 1 To Len(aCpos3os)
	If SX3->(MsSeek(PadR(aCpos3os[nC],Len(SX3->X3_CAMPO))))
		Aadd(aHeader3os,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"AllwaysTrue()",X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO})
	Endif
	If aCpos3os[nC] == "E1_SALDO"
		nPosVlrE1 := nC
	ElseIf aCpos3os[nC] == "E1_MOEDA"
		nPosMoedaE1 := nC
	Endif
Next

If Len(aHeaderRet) == 0 .and. cPaisLoc == "ARG" .and. CCO->(ColumnPos("CCO_TPCALR"))> 0
	aCposRet := {"FE_TIPO","FE_EST","FE_CONCEPT","CCO_TPCALR","FE_VALBASE","FE_DESGR","FE_ALIQ","FE_RETENC","FE_NROCERT"}
	If CCO->(ColumnPos("CCO_TPCALR"))> 0 .and. SFE->(ColumnPos("FE_TPCALR"))> 0
		aGetRet  := {"FE_VALBASE","FE_ALIQ","FE_DESGR"}
	EndIf
	Fn850GtCpo(aCposRet,@aHeaderRet)
	
	Aadd(aColsRet,Array(Len(aHeaderRet)+1))
	For nC := 1 To Len(aHeaderRet)
		aColsRet[1,nC] := Criavar(AllTrim(aHeaderRet[nC,2]))
	Next
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PcoIniLan("000313")

aSize:= FwGetDialogsize(oMainWnd)
aSize[3] *= 1
aSize[4] *= 1
nVlrPagar := 0
nUnico := 1
nMultiplo := 1
DEFINE FONT oFnt  NAME "Arial" SIZE 09,11 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[3],aSize[4] TITLE OemToAnsi(STR0137) Of oMainWnd PIXEL  // "Pagos Anticipados"

	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:lLateral := .F.
	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:lProp := .T.
	oSize:Process()

	oMasterPanel := TPanel():New(oSize:GetDimension("MASTER","LININI"),;
								 oSize:GetDimension("MASTER","COLINI"),;
								,oDlg,,,,,,oSize:GetDimension("MASTER","LINEND"),;
								oSize:GetDimension("MASTER","COLEND"),,)
	oMasterPanel:Align := CONTROL_ALIGN_ALLCLIENT
	nLinIni := oSize:GetDimension("MASTER","LININI") * 0.5

/*
--- painel superior do PA ---------------------------------------------------------------------------------------------------------*/
	oPnlSep0 := TPanel():New(0,0,'',oMasterPanel,, .T., .T.,,RGB(00,00,00),50,50,.F.,.F. )
	oPnlSep0:Align := CONTROL_ALIGN_TOP
	oPnlSep0:nHeight := 1
	/*_*/
	oPnlSup := TPanel():New(0,0,"",oMasterPanel,,,,,,aSize[4],aSize[3],,)
	oPnlSup:Align := CONTROL_ALIGN_TOP
	oPnlSup:nHeight := aSize[3] * 0.1
	/*_*/
	oPnlSep5 := TPanel():New(0,0,'',oMasterPanel,, .T., .T.,,RGB(00,00,00),50,50,.F.,.F. )
	oPnlSep5:Align := CONTROL_ALIGN_TOP
	oPnlSep5:nHeight := 1
	/*_*/
	oPnlSep := TPanel():New(0,0,'',oMasterPanel,, .T., .T.,,,50,50,.F.,.F. )
	oPnlSep:Align := CONTROL_ALIGN_TOP
	oPnlSep:nHeight := 20
	/*_*/
	oPnlSep6 := TPanel():New(0,0,'',oMasterPanel,, .T., .T.,,RGB(00,00,00),50,50,.F.,.F. )
	oPnlSep6:Align := CONTROL_ALIGN_TOP
	oPnlSep6:nHeight := 1
/* campo para a solicitacao de fundo */
	If lSolicFundo
		oPnlSolFundo := TPanel():New(0,0," " + Alltrim(STR0299),oPnlSup,,.F.,.F.,,,50,50,,)//"Solicita็ใo de fundo"
		oPnlSolFundo:Align := CONTROL_ALIGN_LEFT
		oPnlSolFundo:nWidth :=  aSize[4] / 6
		/*_*/
		//Wilson
		@ 15,005 MSGET oSolFun var cSolFun SIZE 50,09 OF oPnlSolFundo PIXEL WHEN .F.
	Endif
	/*_*/
	oPnlSep1 := TPanel():New(0,0,'',oPnlSup,, .T., .T.,,RGB(0,0,0),50,50,.F.,.F. )
	oPnlSep1:Align := CONTROL_ALIGN_LEFT
	oPnlSep1:nWidth :=   1
/* campo para o fornecedor */
	oPnlForn := TPanel():New(0,0," " + AllTrim(STR0054),oPnlSup,,.F.,.F.,,,50,50,,)
	oPnlForn:Align := CONTROL_ALIGN_LEFT
	oPnlForn:nWidth :=  aSize[4] / 2
	/*_*/
	@ 15,05 MSGET oFornece var cFornece F3 "FOR" SIZE 40,07 Valid  F850VldPA(1,cFornece,@cFor,oFor,,,,,,,cLoja) .And. F850VldRet(1,cFornece,@cFor,oFor,oRet,@nRet,nVlrPagar,@nLiquido,oLiquido,@aSE2,cLoja,cCF,cProv,oRetIB,@nRetIB,cZnGeo,nGrpSus,nTotAnt,oRetIVA,@nRetIVA,oRetSUSS,@nRetSuss,nBaseRIE,nAliqRIE,nAliqIGV,oAliqigv,nBaseIGV,,.T.) PIXEL of oPnlForn HASBUTTON When !lIncAdt .And. !lSolicFundo
	@ 15,47 MSGET oLoja var cLoja Size 10,07 Valid (ExistCpo("SA2",cFornece+cLoja) .And. F850VFor(cFornece,cLoja) .And. F850VldPA(1,cFornece,@cFor,oFor,,,,,,,cLoja) .And. F850VldRet(1,cFornece,@cFor,oFor,oRet,@nRet,nVlrPagar,@nLiquido,oLiquido,@aSE2,cLoja,cCF,cProv,oRetIB,@nRetIB,cZnGeo,nGrpSus,nTotAnt,oRetIVA,@nRetIVA,oRetSUSS,@nRetSuss,nBaseRIE,nAliqRIE,nAliqIGV,oAliqigv,nBaseIGV,,.T.)) PIXEL of oPnlForn When !lIncAdt .And. !lSolicFundo
	@ 30,05 SAY oFor Var cFor  Size 150,16 PIXEL of oPnlForn COLOR CLR_BLUE FONT oFnt
	IF lSolicFundo

		@00,230 SAY OemToAnsi(STR0406)  Size 150,16 PIXEL of oPnlForn  // Aprovador
		@15,230 MSGET oAprov var cAprov PIXEL of oPnlForn SIZE 08,08 WHEN .F. 
		oAprov:nWidth := 100

		cNatureza:=FJA->FJA_NATURE

	Endif
	@00,120 SAY OemToAnsi(STR0207)  Size 150,16 PIXEL of oPnlForn  //FONT oFnt
	@15,120 MSGET oNatureza var cNatureza F3 "SED" PIXEL of oPnlForn SIZE 08,08 Valid F850VldMD(1,cNatureza,@cMod,nFlagMOD) WHEN !(lSolicFundo) HASBUTTON
	oNatureza:nWidth := 100
	/*_*/
	oPnlSep2 := TPanel():New(0,0,'',oPnlSup,, .T., .T.,,RGB(0,0,0),50,50,.F.,.F. )
	oPnlSep2:Align := CONTROL_ALIGN_LEFT
	oPnlSep2:nWidth :=   1
/* campo para o valor do PA */
	oPnlVlrPA := TPanel():New(0,0," " + Alltrim(STR0069),oPnlSup,,.F.,.F.,,,50,50,,)
	oPnlVlrPA:Align := CONTROL_ALIGN_LEFT
	oPnlVlrPA:nWidth :=  aSize[4] / 6
	/*_*/
	@ 15,05 MSGET oVlrPagar var nVlrPagar SIZE 60,07 Valid (F850VldPA(2,cFornece,@cFor,oFor,,,,,,,cLoja) .and. F850VldRet(1,cFornece,@cFor,oFor,oRet,@nRet,nVlrPagar,@nLiquido,oLiquido,@aSE2,cLoja,cCF,cProv,oRetIB,@nRetIB,cZnGeo,nGrpSus,nTotAnt,oRetIVA,@nRetIVA,oRetSUSS,@nRetSuss,nBaseRIE,nAliqRIE,nAliqIGV,oAliqigv,nBaseIGV,,.T.) );
	PICTURE PesqPict("SE2","E2_VALOR") PIXEL of oPnlVlrPA HASBUTTON When !lSolicFundo
	//Atualiza os dados
	If(lSolicFundo,F850SolFun(cSolFun),Nil)
/* Pagamento Eletronico */

	If cPaisLoc $ "ARG|RUS"

		oPnlSep3 := TPanel():New(0,0,'',oPnlSup,, .T., .T.,,RGB(0,0,0),50,50,.F.,.F. )
		oPnlSep3:Align := CONTROL_ALIGN_LEFT
		oPnlSep3:nWidth :=   1

		oPnlPgElt := TPanel():New(0,0," " + Alltrim(STR0372),oPnlSup,,.F.,.F.,,,50,50,,)
		oPnlPgElt:Align := CONTROL_ALIGN_LEFT
		oPnlPgElt:nWidth :=  aSize[4] / 6

		@ 15,05 COMBOBOX oPgtoElt VAR cPgtoElt ITEMS {STR0047,STR0048} ON CHANGE F850VldElt(oPgtoElt:nAt,oFolderPg,aSE2) SIZE 30,15 OF oPnlPgElt PIXEL

	EndIf
	
	If  cPaisloc $ "ARG" .And. !lSolicFundo
		oPnlMoeda := TPanel():New(0,0," " + Alltrim(STR0445),oPnlSup,,.F.,.F.,,,50,50,,) //"Moneda : "
		oPnlMoeda:Align := CONTROL_ALIGN_LEFT
		oPnlMoeda:nWidth :=  aSize[4] / 6
		/*_*/	
		@ 15,05 COMBOBOX oMoedaPA VAR cMoedaPA ITEMS aMoeda ON CHANGE (nMoedaTCor:=oMoedaPA:nAt/*,nDecs:=MsDecimais(nMoedaCor),*/) SIZE 50,15 Valid (F850VldPA(3,cFornece,@cFor,oFor,,,,,,aSE2,cLoja) .And. F850VldRet(1,cFornece,@cFor,oFor,oRet,@nRet,nVlrPagar,@nLiquido,oLiquido,@aSE2,cLoja,cCF,cProv,oRetIB,@nRetIB,cZnGeo,nGrpSus,nTotAnt,oRetIVA,@nRetIVA,oRetSUSS,@nRetSuss,nBaseRIE,nAliqRIE,nAliqIGV,oAliqigv,nBaseIGV,,.T.) ) OF oPnlMoeda PIXEL
	Endif
/*
--- painel para formas de pagamento do PA ----------------------------------------------------------------------------------------*/
	oPnlFPg := TPanel():New(0,0,"",oMasterPanel,,,,,,aSize[4],aSize[3],,)
	oPnlFPg:Align := CONTROL_ALIGN_ALLCLIENT
/* painel para o resumo das formas de pagamento */
	oPnlResPg := TPanel():New(0,0,"",oPnlFPg,,.F.,.F.,,,50,50,,)
	oPnlResPg:Align := CONTROL_ALIGN_TOP
	oPnlResPg:nHeight :=  oPnlFPg:nHeight * 0.01
	/* campo para saldo a pagar */
	oPnlSaldPg := TPanel():New(0,0,"",oPnlResPg,,.F.,.F.,,RGB(240,240,240),50,50,,)
	oPnlSaldPg:Align := CONTROL_ALIGN_LEFT
	oPnlSaldPg:nWidth :=  aSize[4] / 3
	oSaldoPgOP := TSay():New(00,00, {|| " " + AllTrim(STR0030) + "  " + Transform(nSaldoPgOP,PesqPict("SE2","E2_VALOR"))},oPnlSaldPg,,,,,,.T.,,,60,10,,,,,,)
	oSaldoPgOP:Align := CONTROL_ALIGN_TOP
	/*_*/
	oPnlSep4 := TPanel():New(0,0,'',oPnlResPg,, .T., .T.,,RGB(0,0,0),50,50,.F.,.F. )
	oPnlSep4:Align := CONTROL_ALIGN_LEFT
	oPnlSep4:nWidth :=   1
	/* campo para total em documentos de terceiros */
	oPnlDocTerc := TPanel():New(0,0,"",oPnlResPg,,.F.,.F.,,RGB(240,240,240),50,50,,)
	oPnlDocTerc:Align := CONTROL_ALIGN_LEFT
	oPnlDocTerc:nWidth :=    aSize[4] / 3
	oTotDocTerc := TSay():New(00,00, {|| " " + Alltrim(STR0245) + ": " + Transform(nTotDocTerc,PesqPict("SE2","E2_VALOR"))},oPnlDocTerc,,,,,,.T.,,,60,10,,,,,,)
	oTotDocTerc:Align := CONTROL_ALIGN_TOP
	/*_*/
	oPnlSep12 := TPanel():New(0,0,"",oPnlResPg,, .T., .T.,,RGB(0,0,0),50,50,.F.,.F. )
	oPnlSep12:Align := CONTROL_ALIGN_LEFT
	oPnlSep12:nWidth := 1
	/* campo para total em documentos de terceiros */
	oPnlDocProp := TPanel():New(0,0,"",oPnlResPg,,.F.,.F.,,RGB(240,240,240),50,50,,)
	oPnlDocProp:Align := CONTROL_ALIGN_LEFT
	oPnlDocProp:nWidth :=  aSize[4] / 3
	oTotDocProp := TSay():New(00,00, {|| " " + Alltrim(STR0308) + ": " + Transform(nTotDocProp,PesqPict("SE2","E2_VALOR"))},oPnlDocProp,,,,,,.T.,,,60,10,,,,,,) //"Documentos pr๓prios"
	oTotDocProp:Align := CONTROL_ALIGN_TOP
	/*_*/
	oPnlSep11 := TPanel():New(0,0,'',oPnlFPg,, .T., .T.,,RGB(00,00,00),50,50,.F.,.F. )
	oPnlSep11:Align := CONTROL_ALIGN_TOP
	oPnlSep11:nHeight := 1
/* Folder para formas de pagamento */
	@ 004,004 FOLDER oFolderPg OF oPnlFPg PROMPT OemToAnsi(STR0245),(STR0298)  PIXEL SIZE 630,140 //"Documentos de terceiros"###"Documentos pr๓prios"
	oFolderPg:Align := CONTROL_ALIGN_ALLCLIENT
/* folder 1 */
/* documentos de terceiros */
	oPnlDTerc := TPanel():New(0,0,"",oFolderPg:aDialogs[1],,.T.,,,,aSize[4],aSize[3],,)
	oPnlDTerc:Align := CONTROL_ALIGN_TOP
	oPnlDTerc:nHeight := oPnlFPg:nHeight * 0.05
	/*_*/
	oPnlSep16 := TPanel():New(0,0,"",oFolderPg:aDialogs[1],,.T.,,,,aSize[4],aSize[3],,)
	oPnlSep16:Align := CONTROL_ALIGN_TOP
	oPnlSep16:nHeight := 5
	/* Painel para documentos de terceiros */
	oPnlTerc := TPanel():New(0,0,"",oPnlDTerc,,.T.,,,,aSize[4],aSize[3],,)
	oPnlTerc:Align := CONTROL_ALIGN_LEFT
	oPnlTerc:nWidth := aSize[4] - 10
	/*_*/
	@ 03,03 Group oGrpTerc TO 045,623 PIXEL OF oPnlTerc LABEL OemToAnsi(STR0245)	//"Documentos de Terceiros"
	oGrpTerc:Align := CONTROL_ALIGN_RIGHT
	oGrpTerc:nWidth := oPnlTerc:nWidth - 3

	/* Botใo de Filtro */
	oTButton2 := TButton():New( 015, 005, OemToAnsi(STR0340),oPnlTerc,{||F850FilDT(cCliente,cLojaCli,"*",.T.)},70,012,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Selecionar Documentos"

/* browser para documento de terceiros */
	oGetDad2 := MsNewGetDados():New(61,04,117,623,GD_DELETE,"AllwaysTrue()","AllwaysTrue()",,,/*freeze*/,,"AllwaysTrue()",/*superdel*/,"F850DelPg(2,.T.)",oFolderPg:aDialogs[1],aHeader3os,aCols3os)
	oGetDad2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetDad2:SetArray(aCols3os)
	oGetDad2:oBrowse:Refresh()
/* (sub) folder 2 */
/* Painel para documentos proprios*/
	oPnlFPag := TPanel():New(0,0,"",oFolderPg:aDialogs[2],,.T.,,,,aSize[4],aSize[3],,)
	oPnlFPag:Align := CONTROL_ALIGN_TOP
	oPnlFPag:nHeight := oPnlFPg:nHeight * 0.07
	/*_*/
	oPnlSep15 := TPanel():New(0,0,"",oFolderPg:aDialogs[2],,.T.,,,,aSize[4],aSize[3],,)
	oPnlSep15:Align := CONTROL_ALIGN_TOP
	oPnlSep15:nHeight := 5
	/*_*/
	oPnlSep10 := TPanel():New(0,0,"",oPnlFPag,,.T.,,,,aSize[4],aSize[3],,)
	oPnlSep10:Align := CONTROL_ALIGN_TOP
	oPnlSep10:nHeight := 5
/* criterios de vencimento para um documento */
	oPnlUVct := TPanel():New(0,0,"",oPnlFPag,,.T.,,,,aSize[4],aSize[3],,)
	oPnlUVct:Align := CONTROL_ALIGN_LEFT
	oPnlUVct:nWidth := aSize[4]/2 - 3
	/*_*/
	@ 03,03 Group oGrpUnico TO 10,10 PIXEL OF oPnlUVct LABEL OemToAnsi(STR0238) 	//"Criterio para data de vencimento com um unico vencimento."
	oGrpUnico:Align := CONTROL_ALIGN_RIGHT
	oGrpUnico:nWidth := oPnlUVct:nWidth - 3
	/*_*/
	@ 006,006  COMBOBOX oUnico	 VAR nUnico SIZE oGrpUnico:nWidth/3 ,09 ITEMS aUnico; 				//"Primeiro Vencimento"###"Ultimo Vencimento"###"Ponderado dos Vencimentos"
	ON CHANGE (F850VctoCheque(oUnico:nAt,oMultiplo:nAt),F850Lin()) OF oPnlUVct PIXEL WHEN .F.
	oUnico:bSetGet := {|u| If (PCount()==0,nUnico,nUnico:=u)}
/* criterio de vencimento para multiplos documentos*/
	oPnlMVct := TPanel():New(0,0,"",oPnlFPag,,.T.,,,,aSize[4],aSize[3],,)
	oPnlMVct:Align := CONTROL_ALIGN_LEFT
	oPnlMVct:nWidth := aSize[4]/2 - 10
	/*_*/
	@ 09,09 Group ogrpMult TO 045,410 PIXEL OF oPnlMVct LABEL OemToAnsi(STR0242) 	//"Crit้rio para data de vencimento com multiplos vencimentos."
	ogrpMult:Align := CONTROL_ALIGN_RIGHT
	ogrpMult:nWidth := oPnlMVct:nWidth - 03
	/*_*/
	@ 13,06  COMBOBOX oMultiplo	 VAR nMultiplo 	SIZE ogrpMult:nWidth/3,09	ITEMS aMultiplo; 									//"Preencher manualmente"###"Calcular automaticamente"
	ON CHANGE (F850VctoCheque(oUnico:nAt,oMultiplo:nAt),F850Lin()) OF oPnlMVct  PIXEL WHEN .F.
	oMultiplo:bSetGet := {|u| If (PCount()==0,nMultiplo,nMultiplo:=u)}
	/* browser para formas de pagamento com documentos proprios */
	oGetDad1 := MsNewGetDados():New(61,04,117,623,GD_INSERT+GD_UPDATE+GD_DELETE,"F850LnOK()","F850LnOK()",,aCposPg,/*freeze*/,,"F850FldOk2(.T.)",/*superdel*/,"F850DelPg(1,.T.)",oFolderPg:aDialogs[2],aHeaderPg,aColsPg)
	nPosMPgto	:= Ascan(oGetDad1:AALTER,{|x| Alltrim(x) == "EK_MOEDA"})
	WHILE nPosMPgto != 0
		aDel(oGetDad1:AALTER,nPosMPgto)
		aSize(oGetDad1:AALTER, Len(aCposPg)-1) 			 	
		nPosMPgto	:= Ascan(oGetDad1:AALTER,{|x| Alltrim(x) == "EK_MOEDA"})
	EndDo
	
		
	oGetDad1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetDad1:bChange := {|| F850LinPgto(,.T.),F850Lin()}
	oGetDad1:SetArray(aColsPg)
	oGetDad1:oBrowse:Refresh()
ACTIVATE MSDIALOG oDlg  CENTERED ON INIT (EnchoiceBar(oDlg,{|| If(F850CmplPA(@aSE2,cFornece,cLoja,cFor,nVlrPagar,nLiquido,nRet,nRetIb,nRetIva,nRetSuss,nRetIR,nRetRIE,nRetIGV) .And. F850VldOPs(@aSE2,.T.) .and. F850VldMD(1,cNatureza,@cMod,nFlagMOD),(lConfirmo := .T.,oDlg:End()),)},{ || (nOpc := 0,F850DelAbt(SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM),lConfirmo := .F.,oDlg:End())},,aButtons))
/*_*/
If lConfirmo
	aPagos[1][H_NATUREZA] := cNatureza
	Processa({|| F850Grava(aSE2,.T.,,lMonotrb,@nFlagMOD,@nCtrlMOD,cSolFun) })
	IF cPaisLoc == "ARG" .And. Len(aCert) > 0  .And. lImpCert
		F850AtuSFF(aCert,.T.)
	EndIf
Else
	If Len(aDoc3osUtil) > 0
		AEval(aDoc3osUtil,{|x,y| SE1->(MsRUnlock(x))})
		aDoc3osUtil := {}
	EndIf
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a gravacao dos lancamentos do SIGAPCO ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PcoFinLan("000313")
aRotina:= aClone(aRotinaOld)
aHeader:= aClone(aHeaderOld)
aCols  := aClone(aColsOld)
n	   := nOld

//Filtra a SE2 novamente
If !lShowPOrd .And. (Type("cAliasTmp") != "U" .And. !Empty(cAliasTmp) .And. Select(cAliasTmp) > 0)
	F850SE2Tmp(.F.)
	MarkBRefresh()
EndIf

Return( .F. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850CMPLPAบAutor  ณMicrosiga           บFecha ณ  09/22/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850CmplPA(aSE2,cFornece,cLoja,cFor,nValor,nLiquido,nRet,nRetIb,nRetIva,nRetSuss,nRetIR,nRetRIE,nRetIGV,lOPRotAut)

Local nI		:= 0
Local lCBU		:= .F.
Local nSaldo	:= 0
Local nMoeBco := 0
Local nMoePgt := 0
Local nLoop := 0
Local nMinCBU	:= GetMV("MV_MINCBU",.F.,0)

If lOPRotAut
	For nI := 1 To Len( aSE2[1][3][2] )
		nSaldo += aSE2[1][3][2][nI][5]
	Next nI

	For nI := 1 To Len( aSE2[1][3][3] )
		nSaldo += aSE2[1][3][3][nI][7]
	Next nI
Else
	nSaldo += aSaldos[Len(aSaldos)]
EndIf

aPagos	:=	{{1,cFornece,cLoja,cFor,0,0,0,0,0,0,0,0,0,0,0,0,0,0,.F.,0,"",0,0}}
If cPaisLoc == "ANG"
	nRetRIE	:= If(lRetPA,nValor-nLiquido,0)
Endif
If cPaisLoc == "ARG"
	//Verifica se o fornecedor atualizado e monotributista
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja))
	aPagos[1][H_NOME ] := Iif(!Empty(aPagos[1][H_NOME ]),aPagos[1][H_NOME ],SA2->A2_NREDUZ)
	lMonotrb := Iif(SA2->A2_TIPO == 'M' .And. cPaisLoc == "ARG" ,.T.,.F.)
	//Verifica็ใo de CBU
	If cPaisLoc == "ARG"
		If (dDataBase > SA2->A2_CBUINI .And.  dDataBase< SA2->A2_CBUFIM) .And. nValor > nMinCBU
			lCBU := .T.
		Endif
	Endif
Endif
If cPaisLoc == "ARG" .And. !lOPRotAut
	nMoeBco	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
	nMoePgt	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})
	If nMoeBco > 0 .And. nMoePgt > 0
		For nLoop := 1 To Len(oGetDad1:aCols)
			If Val(oGetDad1:aCols[nLoop][nMoeBco]) != oGetDad1:aCols[nLoop][nMoePgt]
				oGetDad1:aCols[nLoop][nMoePgt] := Val(oGetDad1:aCols[nLoop][nMoeBco])
			EndIf
		Next
	EndIf
EndIf
If !lOPRotAut
	aSE2[1][3]	:=	{4,aClone(oGetDad1:aCols),aClone(oGetDad2:aCols)}
EndIf

aPagos[1][H_TOTALVL]	:=	nSaldo  + 	nRet + nRetIB + nRetIva + nRetSuss +nRetIGV + nRetIR
aPagos[1][H_CBU]		:=	Iif(cPaisLoc == "ARG",lCBU,.F.)
aPagos[1][H_TOTAL ] 	:=	TransForm(aPagos[1][H_TOTALVL],Tm(aPagos[1][H_TOTALVL] ,18,nDecs))
aPagos[1][H_TOTRET]	:=	nRet +nRetIB + nRetIva + nRetSuss + nRetRIE + nRetIGV
aPagos[1][H_RETGAN]	:=	TransForm(nRet,Tm(nRet,16,nDecs))
aPagos[1][H_RETIVA]	:=	TransForm(nRetIva,Tm(nRetIva,16,nDecs))
aPagos[1][H_RETIB ]	:=	TransForm(nRetIB,Tm(nRetIB,16,nDecs))
aPagos[1][H_RETSUSS]	:=	TransForm(nRetSuss,Tm(nRetSuss,16,nDecs))
aPagos[1][H_RETRIE]	:=	TransForm(nRetRIE,Tm(nRetRIE,16,nDecs))
aPagos[1][H_RETIGV]	:=	TransForm(nRetIGV,Tm(nRetIGV,16,nDecs))
aPagos[1][H_RETIR]	:=	TransForm(nRetIR,Tm(nRetIR,16,nDecs))
aPagos[1][H_TOTAL ]	:=	"0"
aPagos[1][H_TOTALVL]+=	(nRet + nRetIB + nRetIva + nRetSuss+nRetRIE+nRetIGV+nRetIR) * -1
aCert:={}

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850SolFunบAutor  ณMicrosiga           บFecha ณ  09/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850SolFun(cSolic)
Local aArea		:= GetArea()
Local lRet		:= .F.

Default cSolic	:= ""

DbSelectArea("FJA")
DbSetOrder(4)	 //FJA_FILIAL+FJA_SOLFUN
If MsSeek(xFilial("FJA") + cSolic)
	If FJA_ESTADO <> "2"
	   MsgAlert(STR0317) // "Solicita็ใo nใo aprovada."
	   lRet := .F.
	Else
		cFornece := FJA_FORNEC
		cLoja    := FJA_LOJA 
		cAprov   := FJA_CODAPROV
		nVlrPagar:= FJA_VALOR
		nVlrNeto := FJA_VALOR
		cNatureza:= FJA_NATURE    
		oNatureza:Refresh() 
		oFornece:Refresh()
		oLoja:Refresh()
  	    oVlrPagar:refresh()
		lRet:=.T.
	Endif
Else
	MsgAlert(STR0318) // "Solicita็ใo de fundo nใo encontrada."
	lRet := .F.
Endif
RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VldPAบAutor  ณBruno Sobieski      บFecha ณ  01/17/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o fornecedor na digitacao do Paganmento adiantado   บฑฑ
ฑฑบ          ณ e atualiza os objetos referidos .                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850VldPA(nOpc,cFornece,cFor,oFor,oRet,nRet,nValor,nLiquido,oLiquido,aSE2,cLoja,cCF,cProv,oRetIB,nRetIB,cZnGeo,nGrpSus,nTotAnt,oRetIVA,nRetIVA,oRetSUSS,nRetSuss)
Local lRet		:= .F.
Local cPesquisa	:= ""

Default nTotAnt:=0

If lRetPA == Nil
	lRetPA := (GetNewPar("MV_RETPA","N") == "S")
EndIf

If !Empty(cLoja)
	cPesquisa	:= cFornece+cLoja
Else
	cPesquisa	:=cFornece
EndIf

SA2->(DbSetOrder(1))
If nOpc	==	1	//validacao do fornecedor
	If SA2->(MsSeek(xFilial("SA2")+cPesquisa)) .AND. cFornece >= cForDe .And.cFornece <= cForAte
		cFor:= SA2->A2_NREDUZ //SA2->A2_NOME
		oFor:SetText(cFor)
		oFor:Refresh()
		lRet:= .T.
	Else
		Help( " ", 1, "NOFORNEC",, STR0389 , 1, 0 ) 
		lRet	:=	.F.
	Endif
ElseIf nOpc == 2
	If nVlrPagar <= 0
		lRet := .F.
	Else
		nSaldoPg := nVlrPagar
		oSaldoPgOP:Refresh()
		F850AtuProp()
		lRet := .T.
	Endif
ElseIf  nOpc == 3
	If  cMoedaPA  <> cMoedaTemp  
		cMoedaTemp  := cMoedaPA
		F850AtuProp(,,,.T.,aSE2)
		lRet  := .T. 
	Endif
Endif
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ShowPO   บ Autor ณ Armando P. Waitemanบ Data ณ  16/01/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para a geracao de tela com a lista de todas as      บฑฑ
ฑฑบ          ณ ordens de pagto geradas.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function F850Show(aList,oBrw,aSE2,lPreOp)
Local nTotalPago	:= 0
Local nX 			:= 0
Local nSE2			:= 0
Local nLenDoc		:= 0
Local a850BTN		:= {}
Local aHeader		:= {}
Local aSize			:= {}
Local aDocs			:= {}
Local aSizeWnd		:= {}
Local oDlg
Local oLbx
Local oFnt
Local oBtnAux
Local oPnlOP
Local oPnlTitDoc
Local oPnlDoc
Local oPnlSep1
Local oPnlSep2
Local oPnlSep3
Local oPnlTot
Local oBrwDoc
Local oPnlBtn
Local nPosList:=0
Default lPreOp := .F.

DEFINE FONT oFnt  NAME "Arial" SIZE 09,11 BOLD

For nX	:=	1	To	Len(aList)
    nTotalPago	+=	aList[nX][5]
Next

For nSE2 := 1 To Len(aSE2)
	If aPagos[nSE2,1] <> -1
		For nX := 1 To Len(aSE2[nSE2,3,2])
			Aadd(aDocs,{})
			nLenDoc := Len(aDocs)
			If Len(aSE2[nSE2,1])>=1 .and. Len(aSE2[nSE2,1,1])>=1 
			nPosList:= aScan(alist,{|x| x[2]+x[3] == aSE2[nSE2,1,1,1]+aSE2[nSE2,1,1,2]})
				If nPosList == 0 .And. nSE2 <> 0
					nPosList:= nSE2
				Endif	
			Else
				nPosList:= nSE2
			EndIf 
			Aadd(aDocs[nLenDoc],aList[nPosList,1])
			Aadd(aDocs[nLenDoc],aList[nPosList,2])
			Aadd(aDocs[nLenDoc],aList[nPosList,3])
			Aadd(aDocs[nLenDoc],aSE2[nSE2,3,2,nX,nPosBanco])
			Aadd(aDocs[nLenDoc],aSE2[nSE2,3,2,nX,nPosAge])
			Aadd(aDocs[nLenDoc],aSE2[nSE2,3,2,nX,nPosConta])
			Aadd(aDocs[nLenDoc],aSE2[nSE2,3,2,nX,nPosTalao])
			Aadd(aDocs[nLenDoc],aSE2[nSE2,3,2,nX,nPosTipo])
			Aadd(aDocs[nLenDoc],aSE2[nSE2,3,2,nX,nPosNum])
			Aadd(aDocs[nLenDoc],aSE2[nSE2,3,2,nX,nPosVcto])
			Aadd(aDocs[nLenDoc],aSE2[nSE2,3,2,nX,nPosVlr])
		Next
	EndIf
Next nSE2
aSizeWnd:= FwGetDialogsize(oBrw)
aSizeWnd[3] *= 0.5		//altura
aSizeWnd[4] *= 0.5		//largura
DEFINE MsDialog  oDlg FROM  0,0 To aSizeWnd[3],aSizeWnd[4] Title OemToAnsi(STR0132) PIXEL Of oBrw  //"Ordenes de pago generadas"
	oPnlOP := TPanel():New(0,0,"",oDlg,,,,,,aSizeWnd[4],aSizeWnd[3],,)
		oPnlOP:Align := CONTROL_ALIGN_TOP
		oPnlOP:nHeight := aSizeWnd[3] * 0.45
	oPnlSep1 := TPanel():New(0,0,"",oDlg,,,,,RGB(00,00,00),aSizeWnd[4],aSizeWnd[3],,)
		oPnlSep1:Align := CONTROL_ALIGN_TOP
		oPnlSep1:nHeight := 3
	oPnlDoc := TPanel():New(0,0,"",oDlg,,,,,,aSizeWnd[4],aSizeWnd[3],,)
		oPnlDoc:Align := CONTROL_ALIGN_TOP
		oPnlDoc:nHeight := aSizeWnd[3] * 0.45
		oPnlTitDoc := TPanel():New(0,0,STR0319,oPnlDoc,,.T.,,,,aSizeWnd[4],aSizeWnd[3],,) // "Documentos gerados para pagamento"
			oPnlTitDoc:Align := CONTROL_ALIGN_TOP
			oPnlTitDoc:nHeight := oPnlDoc:nHeight * 0.1
		oPnlSep2 := TPanel():New(0,0,"",oPnlDoc,,,,,RGB(00,00,00),aSizeWnd[4],aSizeWnd[3],,)
		oPnlSep2:Align := CONTROL_ALIGN_TOP
		oPnlSep2:nHeight := 1
	oPnlSep3 := TPanel():New(0,0,"",oDlg,,,,,RGB(00,00,00),aSizeWnd[4],aSizeWnd[3],,)
		oPnlSep3:Align := CONTROL_ALIGN_TOP
		oPnlSep3:nHeight := 2
	oPnlTot := TPanel():New(0,0,"",oDlg,,,,,,aSizeWnd[4],aSizeWnd[3],,)
		oPnlTot:Align := CONTROL_ALIGN_TOP
		oPnlTot:nHeight := aSizeWnd[3] * 0.1
		oPnlBtn := TPanel():New(0,0,"",oPnlTot,,,,,,aSizeWnd[4],aSizeWnd[3],,)
			oPnlBtn:Align := CONTROL_ALIGN_RIGHT
			oPnlBtn:nWidth := aSizeWnd[4] * 0.1
	/*
	relacao de ordens de pago */
	If cPaisLoc == "ARG"
		//"Nro OP","Proveedor","Sucursal","Nombre","Valor Pago"
		aHeader := {STR0134,STR0054,STR0055,STR0056,STR0135,STR0202}
		aSize   := {35,35,18,90,60,30}
	Else
		aHeader := {STR0134,STR0054,STR0055,STR0056,STR0135}
		aSize   := {35,35,18,90,60}
	Endif
	oLBx := TWBrowse():New( 07,07,270,120,,aHeader,aSize,oPnlOP,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbx:Align := CONTROL_ALIGN_ALLCLIENT
	// Define o conte๚do do listbox
	oLbx:SetArray(aList)
	// Define as colunas que serใo impressas e a ordem (Fixo para cinco colunas)
	oLbx:bLine:={ || {aList[oLbx:nAt,1],aList[oLbx:nAt,2],aList[oLbx:nAt,3],aList[oLbx:nAt,4],TransForm(aList[oLbx:nAt,5],TM(aList[oLbx:nAt,5],19,MsDecimais(nMoedaCor))),Iif(aList[oLbx:nAt,6],STR0047,STR0048)} }
	/*
	relacao dos documentos gerados para pagamento */
	oBrwDoc := TCBrowse():New(0,0,10,10,,,,oPnlDoc,,,,,,,,,,,,,,.T.,,,,.T.,)
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_ORDPAGO"),{|| aDocs[oBrwDoc:nAt,1]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_FORNECE"),{|| aDocs[oBrwDoc:nAt,2]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_LOJA"),{|| aDocs[oBrwDoc:nAt,3]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_BANCO"),{|| aDocs[oBrwDoc:nAt,4]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_AGENCIA"),{|| aDocs[oBrwDoc:nAt,5]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_CONTA"),{|| aDocs[oBrwDoc:nAt,6]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_TALAO"),{|| aDocs[oBrwDoc:nAt,7]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_TIPO"),{|| aDocs[oBrwDoc:nAt,8]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_NUM"),{|| aDocs[oBrwDoc:nAt,9]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_VENCTO"),{|| aDocs[oBrwDoc:nAt,10]},,,,,050,.F.,.F.,,,,,))
		oBrwDoc:AddColumn(TCColumn():New(RetTitle("EK_VALOR"),{|| aDocs[oBrwDoc:nAt,11]},PesqPict("SEK","EK_VALOR"),,,,050,.F.,.F.,,,,,))
		oBrwDoc:SetArray(aDocs)
		oBrwDoc:Align :=  CONTROL_ALIGN_ALLCLIENT
	/*_*/
	@05,03 SAY OemToAnsi(STR0133) Size 60,10 PIXEL of oPnlTot FONT oFnt  //"Total Pago : "
	@05,80 SAY nTotalPago Picture	TM(nTotalPago,19,MsDecimais(nMoedaCor)) Size 80,10 Of oPnlTot PIXEL FONT oFnt
	/*
	 PE para permitir ao usuario incluir objetos na tela.*/
	If ExistBlock( "A085BTN" )
		a850BTN := ExecBlock( "A085BTN" )
		oBtnAux := TButton():New( 135, a850BTN[1], a850BTN[2], oPnlTot, { || NIL }, 32, 10,,, .F., .T., .F.,, .F.,,, .F. )
		oBtnAux:bAction := { || &( a850BTN[3] ) }
	EndIf
	/*_*/
	Define SBUTTON FROM  05,00 Type 1 Of oPnlBtn PIXEL ENABLE Action oDlg:End()
Activate Dialog oDlg CENTERED


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAaddSE2   บAutor  ณBruno Sobieski      บ Data ณ  10/17/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclui um novo Item no array de notas para serem pagas      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AaddSE2(nControl,aSE2,lFake, aRecnoSE2)
Local x,y
Local cFatGer := " "
Local nVlrRet := 0
Local nPosSE2 := 0
Local nValLot := 0

lBxParc := IIf( Type("lBxParc")=="U", Iif(cPaisLoc <> "BRA",.T.,.F.), lBxParc)
DEFAULT lFake	:=	.F.
/*
A estrutura do array eh a seguinte

Cada elemento do aSE2 e uma ordem de pagamento, e dentro desta
matriz temos, por um lado (posi'cao 1) as retencoes de GANACIAS (argentina)
e o outro elemento eh um array com os dados de cada nota

aSE2[1][1]			:= Array com as notas da ordem de pagamento
	aSE2[1][1][1]	:= Array com os dados da nota 1
	aSE2[1][1][2]	:= Array com os dados da nota 1
	...
	aSE2[1][2][1]	:= Array com retencoes de ganancias para o primer conceito
	aSE2[1][2][2]	:= Array com retencoes de ganancias para o segundo conceito
	...
	aSE2[1][3][1]	:= Tipo (Cheque pre-impresso == 1,Debito mediato == 2,,Debito Inmediato == 3,Informado == 4
	aSE2[1][3][2]	:= Outras informacoes do pagamento
	aSE2[1][3][3]	:= Outras informacoes do pagamento
	aSE2[1][3][4]	:= Outras informacoes do pagamento
	...
	aSE2[1][4]		:= Array com despesas
	aSE2[1][5]		:= indica se ha titulos vencidos
*/
x  := nControl

If x > Len(aSE2)
	AAdd(aSE2,{{Array(_ELEMEN)},{},{4,{},{},0,0,0,1},{},.F.})
	y  := 1
Else
	AAdd(aSE2[x][1],Array(_ELEMEN))
	y  := Len(aSE2[x][1])
Endif
If !lFake
	nPosSE2 := Ascan(aRecnoSE2,{|ase2| ase2[8] == SE2->(RECNO())})
	aSE2[x][1][y][_FORNECE]	:= SE2->E2_FORNECE
	aSE2[x][1][y][_LOJA] 		:= SE2->E2_LOJA
	aSE2[x][1][y][_NOME]		:= SE2->E2_NOMFOR
	aSE2[x][1][y][_MOEDA]	:= SE2->E2_MOEDA
	aSE2[x][1][y][_EMISSAO]	:= SE2->E2_EMISSAO
	aSE2[x][1][y][_VENCTO]	:= SE2->E2_VENCTO
	aSE2[x][1][y][_PREFIXO]	:= SE2->E2_PREFIXO
	aSE2[x][1][y][_NUM]		:= SE2->E2_NUM
	aSE2[x][1][y][_PARCELA]	:= SE2->E2_PARCELA
	aSE2[x][1][y][_TIPO]		:= SE2->E2_TIPO
	aSE2[x][1][y][_NATUREZ]	:= SE2->E2_NATUREZ
	aSE2[x][1][y][_RECNO]	:= SE2->(RECNO())
	aSE2[x][1][y][_RETIVA]	:= {}
	aSE2[x][1][y][_RETIB]	:= {}
	aSE2[x][1][y][_VALOR]	:= SE2->E2_VALOR
	If cPaisLoc == "RUS"
		aSE2[x][1][y][_BASIMP1]		:= SE2->E2_BASIMP1//0
		aSE2[x][1][y][_ALQIMP1]		:= SE2->E2_ALQIMP1//0
		aSE2[x][1][y][_VALIMP1]		:= SE2->E2_VALIMP1//0
		aSE2[x][1][y][_MDCONTR]		:= SE2->E2_MDCONTR//""
	EndIf

	// verifica se ha titulos vencidos, pois caso haja, os vencimentos dos cheques deverao ser informados pelo usuario
	If aSE2[x,1,y,_VENCTO] < dDataBase
		aSE2[x,5] := .T.
	Endif
	If cPaisLoc $ "DOM|COS"
		cFatGer    := F850FatGer(SE2->E2_NATUREZ)
		nVlrRet 	:= F850PesAbt()
		If nVlrRet  > 0 .And. cFatGer == "2" .And. Empty(SE2->E2_BAIXA)  .And. SE2->E2_VALLIQ == 0  .And. !SE2->E2_TIPO	$ 	"CH |PA "
			RecLock("SE2",.F.)
			Replace SE2->E2_VALOR With SE2->E2_VALOR 	+ nVlrRet
			Replace SE2->E2_SALDO With  SE2->E2_SALDO 	+ nVlrRet
			Replace SE2->E2_VLCRUZ With  SE2->E2_VLCRUZ	+ nVlrRet
			MsUnlock()
			F850DelAbt(xFilial("SE2")+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM)
		EndIf
		/* Gera็ใo das Reten็๕es de Impostos - Republica Dominicana */
		/* Function fa050CalcRet(cCarteira, cFatoGerador)           */
		/* 1-Contas a Pagar ou 3-Ambos e Fato Gerador 2-Baixa       */
		If 	!SE2->E2_TIPO	$ 	"CH |PA "
			fa050CalcRet("'1|3'", "2", SE2->E2_NATUREZA, SE2->E2_VALOR, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE)
		EndIf
	EndIf
	//Reten็๕es do Equador ocorrem na Origem
	If	cPaisLoc $ "DOM|COS|EQU" //.Or. (cPaisLoc == "DOM" .And. SE2->E2_TIPO == MVPAGANT)
		aSE2[x][1][y][_ABATIM]	:= 0
	Else
		aSE2[x][1][y][_ABATIM]	:= SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,,SE2->E2_FORNECE)
	EndIf
	If lShowPOrd
		aSE2[x][1][y][_PAGAR]	:= aRecnoSE2[nPosSE2,9] - aSE2[x][1][y][_ABATIM ]
		aSE2[x][1][y][_SALDO1]	:= Round(xMoeda(aRecnoSE2[nPosSE2,9],SE2->E2_MOEDA,1,,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
		aSE2[x][1][y][_SALDO]	:= aRecnoSE2[nPosSE2,9]
	Else
		//Valida se existem movimentos pendentes de efetiva็ใo
		If cPaisLoc $ "ARG"
			nValLot := F850RecPgt(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA)
		EndIf

		If lBxParc .and. SE2->E2_VLBXPAR >0   .And.  SE2->E2_VLBXPAR <=SE2->E2_SALDO
			aSE2[x][1][y][_PAGAR]	:= SE2->E2_VLBXPAR - aSE2[x][1][y][_ABATIM ] - nValLot
			aSE2[x][1][y][_SALDO1]	:= Round(xMoeda(SE2->E2_VLBXPAR - aSE2[x][1][y][_ABATIM ] - nValLot,SE2->E2_MOEDA,1,,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
			aSE2[x][1][y][_SALDO]	:=  SE2->E2_VLBXPAR - nValLot
		Else
			aSE2[x][1][y][_PAGAR]	:= SE2->E2_SALDO - aSE2[x][1][y][_ABATIM ] - nValLot
			aSE2[x][1][y][_SALDO1]	:= Round(xMoeda(SE2->E2_SALDO - aSE2[x][1][y][_ABATIM ] - nValLot,SE2->E2_MOEDA,1,,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
			aSE2[x][1][y][_SALDO]	:= SE2->E2_SALDO - nValLot
		EndIf
	EndIf
	If Empty(SE2->E2_BAIXA)
		aSE2[x][1][y][_DESCONT]	:= SE2->E2_DESCONT
		aSE2[x][1][y][_MULTA]	:= SE2->E2_MULTA
		aSE2[x][1][y][_JUROS]	:= SE2->E2_JUROS
	Else
		aSE2[x][1][y][_DESCONT]	:= 0
		aSE2[x][1][y][_MULTA]	:= 0
		aSE2[x][1][y][_JUROS]	:= 0
	EndIf
	aSE2[x][1][y][_RETIRIC]	:= {}
	aSE2[x][1][y][_RETSUSS]	:= {}
	aSE2[x][1][y][_RETSLI]	:= {}
	aSE2[x][1][y][_RETIR]	:= {}
	aSE2[x][1][y][_RETIRC]	:= {}
	aSE2[x][1][y][_RETISI]	:= {}
	aSE2[x][1][y][_RETRIE]	:= {}	//ANGOLA
	aSE2[x][1][y][_RETIGV]	:= {}	//PERU
	aSE2[x][1][y][_RETIR]	:= {}	//PERU
Else
	aSe2[x][1][y][_FORNECE]	:= ""//SE2->E2_FORNECE
	aSE2[x][1][y][_LOJA]		:= ""//SE2->E2_LOJA
	aSE2[x][1][y][_NOME]		:= ""//SE2->E2_NOMFOR
	aSE2[x][1][y][_MOEDA]	:= ""//SE2->E2_MOEDA
	aSE2[x][1][y][_EMISSAO]	:= ""//SE2->E2_EMISSAO
	aSE2[x][1][y][_VENCTO]	:= ""//SE2->E2_VENCTO
	aSE2[x][1][y][_PREFIXO]	:= ""//SE2->E2_PREFIXO
	aSE2[x][1][y][_NUM]		:= ""//SE2->E2_NUM
	aSE2[x][1][y][_PARCELA]	:= ""//SE2->E2_PARCELA
	aSE2[x][1][y][_TIPO]		:= ""//SE2->E2_TIPO
	aSE2[x][1][y][_NATUREZ]	:= ""//SE2->E2_NATUREZ
	aSE2[x][1][y][_RECNO]	:= ""//SE2->(RECNO())
	aSE2[x][1][y][_RETIVA]	:= {}
	aSE2[x][1][y][_RETIB]	:= {}
	aSE2[x][1][y][_VALOR]	:= 0 //SE2->E2_VALOR
	aSE2[x][1][y][_PAGAR]	:= 0
	aSE2[x][1][y][_ABATIM]	:= 0
	aSE2[x][1][y][_SALDO]	:= 0 //SE2->E2_SALDO
	aSE2[x][1][y][_SALDO1]	:= 0
	If cPaisLoc == "RUS"
		aSE2[x][1][y][_BASIMP1] := 0
		aSE2[x][1][y][_ALQIMP1] := 0
		aSE2[x][1][y][_VALIMP1] := 0
		aSE2[x][1][y][_MDCONTR]	:= ""
	EndIf
	aSE2[x][1][y][_DESCONT]	:= 0
	aSE2[x][1][y][_MULTA]	:= 0
	aSE2[x][1][y][_JUROS]	:= 0
	aSE2[x][1][y][_RETIRIC]	:= {}
	aSE2[x][1][y][_RETSUSS]	:= {}
	aSE2[x][1][y][_RETSLI]	:= {}
	aSE2[x][1][y][_RETIR]	:= {}
	aSE2[x][1][y][_RETISI]	:= {}
	aSE2[x][1][y][_RETRIE]	:= {}	//ANGOLA
	aSE2[x][1][y][_RETIGV]	:= {}	//peru
	aSE2[x][1][y][_RETIR]	:= {}	//peru
Endif
If ExistBlock("F085AALE2")
	aSE2[x][1][y]:=ExecBlock("F085AALE2",.F.,.F.,{aSE2[x][1][y]})
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850FORN บAutor  ณMarcello Gabriel    บ Data ณ  22/03/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria uma janela com a lista de fornecedores                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850FORN(aSE2)
Local ni,oCol,nTitulos,oForm ,oCBX, cIndice
Local nOrdSA2,nSA2,nOrdSX3
Local cCodForn:= Space(30)
Local aSE2Tmp
Local lRet			:=	.T.
Local aRateioGan  :=	{}
Local aAreaSA2
Private cFiltro,cTitulo
Private cForm:= Space(9)
Private oDlgForn,nOpca,cAlias:=Alias()
Private oBrwForn
Private nIndice := 1
DbSelectArea("SX3")
nOrdSX3:=IndexOrd()
DbSetOrder(2)
DbSelectArea("SA2")
nSA2:=Select("SA2")
nOrdSA2:=Indexord()
DbSetorder(1)
If nCondAgr==2
	cFiltro := "A2_COD='" + aPagos[oLbx:nAT][H_FORNECE] + "'"
	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
		cFiltro += " .And. A2_FILIAL = '" + SE2->E2_MSFIL + "'"
	Endif
   #IFDEF TOP
           MSFilter(cFiltro)
   #ELSE
        Dbsetfilter({|| &cFiltro},cFiltro)
   #ENDIF
   SA2->(DbGoTop())
Else
	SA2->(MsSeek(xFilial("SA2")))
Endif
nOpca:=0
cTitulo:=STR0054
If nCondAgr==2
	cTitulo+=" "+aPagos[oLbx:nAT][H_FORNECE]
	DEFINE MSDIALOG oDlgForn FROM  0,0 TO 250,500 PIXEL TITLE cTitulo OF oMainWnd
	oBrw:=TCBrowse():New(5,5,241,100,,,,oDlgForn,,,,,{|nRow,nCol,nFlags|nOpca:=1,oDlgForn:End()},,,,,,,.F.,,.T.,,.F.,)
   	If nCondAgr>2
      		SX3->(MsSeek("A2_COD"))
      		oCol:=TCColumn():New(Trim(x3titulo()),FieldWBlock("A2_COD",nSA2),,,,,,.F.,.F.,,,,.F.,)
      		oBrw:ADDCOLUMN(oCol)
   	Endif
   	SX3->(MsSeek("A2_LOJA"))
   	oCol:=TCColumn():New(Trim(x3titulo()),FieldWBlock("A2_LOJA",nSA2),,,,,,.F.,.F.,,,,.F.,)
   	oBrw:ADDCOLUMN(oCol)
   	SX3->(MsSeek("A2_NREDUZ"))
   	oCol:=TCColumn():New(Trim(x3titulo()),FieldWBlock("A2_NREDUZ",nSA2),,,,,,.F.,.F.,,,,.F.,)
   	oBrw:ADDCOLUMN(oCol)
   	DEFINE SBUTTON FROM 110,185 TYPE 1 ACTION (nOpca:=1,oDlgForn:End()) PIXEL ENABLE OF oDlgForn
   	DEFINE SBUTTON FROM 110,217 TYPE 2 ACTION (nOpca:=0,oDlgForn:End()) PIXEL ENABLE OF oDlgForn
	ACTIVATE MSDIALOG oDlgForn CENTERED
	If nOpca==1
		aAreaSA2	:=	SA2->(GetArea())
		If RateioCond(@aRateioGan)
			RestArea(aAreaSA2)
	   		aPagos[oLbx:nAT][H_FORNECE]	:=	SA2->A2_COD
	   		aPagos[oLbx:nAT][H_LOJA]		:=	SA2->A2_LOJA
			aPagos[oLbx:nAT][H_NOME]		:=	SA2->A2_NREDUZ
			F850Recal( @aSE2, aRateioGan )
		Endif
		RestArea(aAreaSA2)
		oLbx:refresh()
	Endif
Else
	If ConPad1(,,,"SA2")
		aAreaSA2	:=	SA2->(GetArea())
		If RateioCond(@aRateioGan)
			RestArea(aAreaSA2)
			aPagos[oLbx:nAT][H_FORNECE]	:=	SA2->A2_COD
			aPagos[oLbx:nAT][H_LOJA]	:=	SA2->A2_LOJA
			aPagos[oLbx:nAT][H_NOME]	:=	SA2->A2_NREDUZ
			F850Recal( @aSE2, aRateioGan )
		Endif
		RestArea(aAreaSA2)
		oLbx:refresh()
	EndIf

Endif
DbSelectArea("SA2")
If nCondAgr==2
	DbClearFilter()
Endif
DbSetOrder(nOrdSA2)
SX3->(DbSetOrder(nOrdSX3))
dbSelectArea(cAlias)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ GERATXT  บ Autor ณ Jose Novaes Romeu  บ Data ณ  05/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gravacao de arquivo de LOG quando o saldo for maior que o  บฑฑ
ฑฑบ          ณ valor do titulo a pagar. Somente para localizacao "POR".   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GeraTxt(cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja,cSaldoAnt,cSaldo)

Local cArqTxt	:= "ERRORPAG.LOG"
Local cEOL		:= "CHR(13)+CHR(10)"
Local nMode		:= 1
Local nTamLin	:= 80
Local cLin, nHdl
Local aFil		:= FWArrFilAtu( cEmpAnt, cFilAnt )

cEOL := &cEOL
nHdl := fOpen(cArqTxt,nMode)

If nHdl == -1
	nHdl := fCreate(cArqTxt)
Endif

If nHdl <> -1
	fSeek(nHdl,0,2)
	cLin	:= Padr( aFil[1]+cFilial+"/"+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo+;
			"/"+cFornece+"/"+cLoja+"/"+cSaldoAnt+"/"+cSaldo,nTamLin)+cEOL
	fWrite(nHdl,cLin)
	fClose(nHdl)
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ GravaRet บ Autor ณ Bruno Sobieski     บ Data ณ  27/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gravacao das retencoes de impostos  (argentina)            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function F850GravRet(aRets,cFornece,cLoja,cParcela,lGan,aTitPags,nMoedaRet,lGerPA,lCBU,cNatureza,lPAd,lPaExced,lOPRotAut)
Local nX			:= 0
Local cNroCert		:= ""
Local cNroCert1		:= ""
Local aArea			:= {}
Local cConcAnt		:= ''
Local aValGan		:= {}  // Guilherme
Local nPosVal		:= 0   // Guilherme
Local nS			:= 0
Local nItensc		:= GETMV("MV_ITENSC",.F.,0)
Local nC			:= 0
Local nImporte		:= 0
Local nContGan		:= 0
Local nValRet		:= 0
Local lPrimV		:= .F.
Local nImpIV		:= 0
Local cChave1		:=	""
Local lTitRet		:=	GetNewPar("MV_TITRET",.F.)
Local lMonot		:= .F.
Local lReSaIV		:= (cPaisLoc == "ARG" .and. GetNewPar("MV_RETIVA","N") == "S" .and. GetNewPar("MV_RETSUSS","N") == "S")
Local cTitPai		:= Rtrim(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
Local aAreaSX5		:= {}
Local cFilSX5		:= XFILIAL("SX5")
Local nContIva 		:= 0
Local nPosImp		:= 0
Local aVlRetIB		:= {}
Local aAreaSA2		:= {}
Local aAreaSF1 		:= SF1->(GetArea())
Local aAreaSF2		:= SF2->(GetArea())
Local nTamSer 		:= SerieNfId('SF1',6,'F1_SERIE')
Local nY
Local cImposto 		:= ""
Local cCFC 			:= ""
Local nSFEValImp 	:= 0
Local nSFERetenc 	:= 0
Local nSFEValBas 	:= 0
Local cTmpMun 		:= ""
Local cQryMun 		:= ""
Local cEstMun 		:= ""
Local aSA2Area 		:= {}
Local cCodApro 		:= ""
Default lGerPa		:= .F.
Default lCBU		:= .F.
Default cNatureza	:= Space(TamSX3("ED_CODIGO")[1])
Default lPAd		:=.T.
Default lPaExced 	:= .F.
Default lOPRotAut  	:= .F.

If lF850Ret == Nil
	lF850Ret	:=	ExistBlock("F850RET")
Endif

If cPaisLoc == "ARG"
	If !lGan
	
		If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA850" .and. ExistFunc("F855DelRet")
			F855DelRet(FJK->FJK_PREOP,cFornece,cLoja,aRets[10],lGan)
		EndIf

		//Forn. Monot.
		dbSelectArea("SA2")
		aAreaSA2 := SA2->(GetArea())
		SA2->(dbSetOrder(1))
		If SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja))
			lMonot := Iif(SA2->A2_TIPO == 'M',.T.,.F.)
		EndIf
		SA2->(RestArea(aAreaSA2))

		//Adiciona as reten็๕es acumuladas de IVA para criar os certificados de reten็ใo
		If Type("aRetIvAcm[3]") == "A"
			For nX := 1 to Len(aRetIvAcm[3])
				aAdd(aRets[_RETIVA],aRetIvAcm[3][nX])
			Next nX
		EndIf

		For nX	:= 1	To Len(aRets[_RETIVA])
			If aRets[_RETIVA][nX][6] != 0
				cChave1	:=	""
				cNroCert	:=	F850GetCert("IVA  ",cFornece+cLoja+"IVA")
				RecLock("SFE",.T.)
				FE_FILIAL	:=	xFilial("SFE")
				FE_NROCERT	:=	cNroCert
				FE_EMISSAO  :=	dDataBase
				FE_FORNECE  :=	cFornece
				FE_LOJA     :=	cLoja
				FE_TIPO     :=	"I"
				FE_ORDPAGO  :=	cOrdPago
				FE_PARCELA	:=	cParcela
				FE_NFISCAL 	:=	aRets[_RETIVA][nX][1]
				SerieNFID("SFE",1,"FE_SERIE",FE_EMISSAO,FE_TIPO,aRets[_RETIVA][nX][2])	
				FE_VALBASE	:=	aRets[_RETIVA][nX][3]
				FE_VALIMP	:=	aRets[_RETIVA][nX][4]
				FE_PORCRET	:=	aRets[_RETIVA][nX][5]
				FE_RETENC	:=	aRets[_RETIVA][nX][6]
				If  Len(aRets[_RETIVA][nX]) >= 10
					FE_ALIQ   	:=	aRets[_RETIVA][nX][10]
				EndIf	
				If len(aRets[_RETIVA][nX]) >8 .And. cPaisLoc $ "ANG|ARG|COS|EQU|HAI"
					FE_CFO	:=	Iif(aRets[_RETIVA][nX][9] > '500' .And. lMonot,Iif(aRets[_RETIVA][nX][10] <> Nil,aRets[_RETIVA][nX][10],aRets[_RETIVA][nX][9]),aRets[_RETIVA][nX][9])
					cChave1	:=	SFE->FE_CFO
				EndIf
				If len(aRets[_RETIVA][nX]) >8 .And. ColumnPos("FE_CFO")>0
					FE_CFO	   := aRets[_RETIVA][nX][11]
					FE_CFORI  := aRets[_RETIVA][nX][9]
					cChave1	:=	SFE->FE_CFO	
				EndIf  
				FE_NUMOPER  :=  cNumOP
				If SFE->(ColumnPos("FE_TPCALR"))>0
					SFE->FE_TPCALR  :=  "A"
				EndIf
				MsUnLock()
				METRET850("IVA")
				If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA850" .and. ExistFunc("F855IncRet")
					F855IncRet("I",FJK->FJK_PREOP,aRets[_RETIVA][nX],cFornece,cLoja,cParcela)
				EndIf
				nPos:=AScan(aCert,{|x| x[1]==Padr(cNroCert,TamSx3("FE_NROCERT")[1],"") .And. x[2]=="I" .And. x[3]==cChave1})
				If nPos = 0
					AAdd(aCert,{Padr(cNroCert,TamSx3("FE_NROCERT")[1],""),"I",cChave1})
				EndIf

				lProcCCR := Iif(!lOPRotAut,lProcCCR,(SEK->(ColumnPos("EK_CCR")) > 0))
				RecLock("SEK",.T.)
				SEK->EK_FILIAL  := xFilial("SEK")
				SEK->EK_TIPODOC := "RG" //Retencion Generada
				SEK->EK_NUM     := cNroCert
				SEK->EK_TIPO    := "IV-"
				SEK->EK_EMISSAO	:= dDataBase
				SEK->EK_VLMOED1 := aRets[_RETIVA][nX][6]
				SEK->EK_VALOR   := Round(xMoeda(aRets[_RETIVA][nX][6],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet)) 
				SEK->EK_SALDO   := Round(xMoeda(aRets[_RETIVA][nX][6],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
				SEK->EK_VENCTO  := dDataBase
				SEK->EK_FORNECE := cFornece
				SEK->EK_LOJA    := cLoja
				SEK->EK_MOEDA	:= StrZero(nMoedaRet,TamSx3("EK_MOEDA")[1]) //"01"
				SEK->EK_ORDPAGO := cOrdPago
				SEK->EK_DTDIGIT := dDataBase
				SEK->EK_NUMOPER  :=  cNumOP
				If cPaisLoc == "ARG"
			   		SEK->EK_FORNEPG:= cFornece
		   			SEK->EK_LOJAPG:= cLoja
					SEK->EK_PGCBU:= lCBU
					If lProcCCR .And. SEK->(ColumnPos("EK_CCR")) > 0
						SEK->EK_CCR := mv_par15
					Endif
				Endif
				If cPaisLoc <> "BRA"
				   SEK->EK_NATUREZ:= cNatureza
				Endif
				F850GrvTx()
				MsUnlock()

				nValRet += SEK->EK_VALOR

				//Grava o n๚mero da OP no documento para IVA acumulado
	    		If Subs(cAgente,2,1) == "S" .AND. LEN(aRets[_RETIVA][nX]) >= 12 .and. lReSaIV
					dbSelectArea("SF1")
					SF1->(dbSetOrder( RETORDEM("SF1","F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO") ))
					If SF1->(MsSeek(xFilial("SF1")+aRets[_RETIVA][nX][1]+aRets[_RETIVA][nX][2]+cFornece+cLoja))
						RecLock("SF1",.F.)
						If Empty(SF1->F1_RETIVA)
							SF1->F1_RETIVA := aRets[_RETIVA][nX][12]
							SF1->F1_SALIVA := aRets[_RETIVA][nX][12]
							lPrimV	:= .T.
						ElseIf lPrimV	== .T.
							nImpIV	:= (SF1->F1_RETIVA - SF1->F1_SALIVA)
							SF1->F1_RETIVA += aRets[_RETIVA][nX][12]
							SF1->F1_SALIVA += aRets[_RETIVA][nX][12]
						Endif
						SF1->F1_SALIVA -= IIF(aRets[_RETIVA][nX][6] <0,aRets[_RETIVA][nX][6]*-1,aRets[_RETIVA][nX][6])
						SF1->(MsUnLock())
					EndIf
					nImpIV := 0
					dbSelectArea("SF2")
					SF2->(dbSetOrder( RETORDEM("SF2","F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO") ))
					If SF2->(MsSeek(xFilial("SF2")+aRets[_RETIVA][nX][1]+aRets[_RETIVA][nX][2]+cFornece+cLoja))
						RecLock("SF2",.F.)
						If Empty(SF2->F2_RETIVA)
							SF2->F2_RETIVA := aRets[_RETIVA][nX][12]
							SF2->F2_SALIVA := aRets[_RETIVA][nX][12]
							lPrimV	:= .T.
						ElseIf lPrimV	== .T.
							nImpIV	:= (SF2->F2_RETIVA - SF2->F2_SALIVA)
							SF2->F2_RETIVA += aRets[_RETIVA][nX][12]
							SF2->F2_SALIVA += aRets[_RETIVA][nX][12]
						Endif 
						SF2->F2_SALIVA -= IIF(aRets[_RETIVA][nX][6] <0,aRets[_RETIVA][nX][6]*-1,aRets[_RETIVA][nX][6])
						SF2->(MsUnLock())
					EndIf
	    		EndIf
				If cOpcElt <> "1"
					aTitPags[1]	-=	aRets[_RETIVA][nX][6]
				EndIf
				If lF850Ret
					ExecBLock("F850RET",.F.,.F.,"IVA")
				Endif

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !lSmlCtb
					PcoDetLan("000313","05","FINF850")
				Endif
			EndIf
		Next
		If Subs(cAgente,2,1) == "N"
			dbSelectArea("SF1")
			SF1->(dbSetOrder(1))
			If SF1->(MsSeek(xFilial("SF1")+aRets[10]+aRets[9]+cFornece+cLoja))
				RecLock("SF1",.F.)
				If Alltrim(SF1->F1_ORDPAGO) == ""
					F1_ORDPAGO := cOrdPago
				EndIf
				SF1->(MsUnLock())
			EndIf
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1))
			If SF2->(MsSeek(xFilial("SF2")+aRets[10]+aRets[9]+cFornece+cLoja))
				RecLock("SF2",.F.)
				If Alltrim(SF2->F2_ORDPAGO) == ""
					F2_ORDPAGO := cOrdPago
				EndIf
				SF2->(MsUnLock())
			EndIf
		EndIf
		//Grava reten็ใo de IVA da Ordem de Pago
		If lTitRet .And. nValRet > 0
			nPosImp := aScan(aTitImp, {|x| x[10] == "IVA" })
			If nPosImp > 0
				aTitImp[nPosImp][7] += nValRet
			Else
				If  nMoedaRet <> 1 .and. GETMV("MV_FINCTAL") == "2" .And.lPAd 
					cCodApro:= FA050Aprov(1)
					aAdd(aTitImp,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValRet, cOrdPago, dDataBase, "IVA", 1,,,cCodApro})
				Else
					aAdd(aTitImp,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValRet, cOrdPago, dDataBase, "IVA", 1,,,Iif(SE2->(ColumnPos("E2_CODAPRO"))>0,SE2->E2_CODAPRO,"")})
				EndIf	
			EndIf
			nValRet := 0
		EndIf

		//Grava o n๚mero da Ordem de Pago nas notas que geraram IVA acumulado
	 	If aRetIvAcm[2] <> Nil
			For nX := 1 to Len(aRetIvAcm[2])
				If aRetIVAcm[2][nX][3]
					nContIva++
				Else
					Loop
				EndIf

				If Len(aRetIVAcm) > 0
					If Len(aRetIVAcm[3][nContIva]) > 0
						If aRetIVAcm[2][nX][2] == "SF1"
							dbSelectArea("SF1")
							SF1->(dbGoTo(aRetIVAcm[2][nX][1]))
							RecLock("SF1",.F.)
							If Alltrim(SF1->F1_ORDPAGO) == ""
								F1_ORDPAGO := cOrdPago
							EndIf
							SF1->(MsUnLock())
						Else
					 		dbSelectArea("SF2")
							SF2->(dbGoTo(aRetIVAcm[2][nX][1]))
							RecLock("SF2",.F.)
							If Alltrim(SF2->F2_ORDPAGO) == ""
								F2_ORDPAGO := cOrdPago
							EndIf
							SF2->(MsUnLock())
						EndIf
					EndIf
				EndIf
			Next
			nContIva := 0
		EndIf
		SF1->(RestArea(aAreaSF1))
		SF2->(RestArea(aAreaSF2))
		aRetIVAcm := Array(3) //Zero as reten็๕es
		

		nLimite:= Iif(ValType(aRets[_RETIB])=="A",Len(aRets[_RETIB]),0)
		 For nX   	:= 1	To Len(aRets[_RETIB])
			If aRets[_RETIB][nX][3] != 0

				If aRets[_RETIB][nX][5] != 0
					cNroCert	:=	F850GetCert("IB "+aRets[_RETIB][nX][9],cFornece+cLoja+"IB "+aRets[_RETIB][nX][9])
			   Else
					cNroCert	:= "NORET"
				EndIf
				
				nSFEValBas := aRets[_RETIB][nX][3]
				If Len(aRets[_RETIB][nX])>= 29 
					If AllTrim(aRets[_RETIB][nX][29]) == "I"
						nSFEValImp := aRets[_RETIB][nX][6]
						nSFERetenc := aRets[_RETIB][nX][6]
					Else
						nSFEValImp := Iif(aRets[_RETIB][nX][17],(aRets[_RETIB][nX][5]*aRets[_RETIB][nX][19])/aRets[_RETIB][nX][4],aRets[_RETIB][nX][5])
						nSFERetenc := Iif(aRets[_RETIB][nX][17],(aRets[_RETIB][nX][5]*aRets[_RETIB][nX][19])/aRets[_RETIB][nX][4],aRets[_RETIB][nX][5])
					EndIf
				Else
					nSFEValImp := Iif(aRets[_RETIB][nX][17],(aRets[_RETIB][nX][5]*aRets[_RETIB][nX][19])/aRets[_RETIB][nX][4],aRets[_RETIB][nX][5])
					nSFERetenc := Iif(aRets[_RETIB][nX][17],(aRets[_RETIB][nX][5]*aRets[_RETIB][nX][19])/aRets[_RETIB][nX][4],aRets[_RETIB][nX][5])
				EndIf
				
				If lPAd 
					If  GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG" .And. nMoedaRet <> 1  
						nSFEValBas 	:= Round(xMoeda(nSFEValBas,1,1,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						nSFEValImp 	:= Round(xMoeda(nSFEValImp,1,nMoedaRet,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						nSFERetenc  := Round(xMoeda(nSFERetenc,1,nMoedaRet,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
					ElseIf  IsInCallStack("F850PgAdi") .And. nMoedaRet <> 1 .and. lPAd .And. !lSolicFundo 
						nSFEValBas 	:= nSFEValBas 
						nSFEValImp 	:= nSFEValImp 
						nSFERetenc  := nSFERetenc 
					Else
						nSFEValBas 	:= Round(xMoeda(nSFEValBas,nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						nSFEValImp 	:= Round(xMoeda(nSFEValImp,nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						nSFERetenc  := Round(xMoeda(nSFERetenc,nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
					EndIf
				EndIf
				
				cChave1	:=	""
				RecLock("SFE",.T.)
				FE_FILIAL	:=	xFilial("SFE")
				FE_NROCERT	:=	cNroCert
				FE_EMISSAO  :=	dDataBase
				FE_FORNECE  :=	cFornece
				FE_LOJA     :=	cLoja
				FE_TIPO     :=	"B"
				FE_ORDPAGO  :=	cOrdPago
				FE_PARCELA	:=	cParcela
				If lGerPa
					FE_NFISCAL 	:=	" "
				Else
					FE_NFISCAL 	:=	aRets[_RETIB][nX][1]
				EndIf
				SerieNFID("SFE",1,"FE_SERIE",FE_EMISSAO,FE_TIPO,aRets[_RETIB][nX][2])	
				FE_VALBASE	:=	nSFEValBas
				FE_ALIQ   	:=	Iif(aRets[_RETIB][nX][17],aRets[_RETIB][nX][4]-aRets[_RETIB][nX][20],aRets[_RETIB][nX][4])
				If  GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPAd 
					FE_VALIMP := Round(xMoeda(nSFEValImp,nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
					FE_RETENC := Round(xMoeda(nSFERetenc,nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
				Else
					FE_VALIMP := nSFEValImp
					FE_RETENC := nSFERetenc
				EndIf	
				FE_EST      :=  aRets[_RETIB][nX][9]
				FE_CFO      :=  aRets[_RETIB][nX][11]
				FE_CONCEPT	:=  aRets[_RETIB][nX][14]
				FE_DEDUC	:=  aRets[_RETIB][nX][15]
				FE_PORCRET	:=  aRets[_RETIB][nX][16]
				If SFE->(ColumnPos("FE_TPCALR"))>0
					SFE->FE_TPCALR  :=  Iif(Len(aRets[_RETIB][nX])>28,aRets[_RETIB][nX][29],"A")
				EndIf
				MsUnLock()
				METRET850("IBR-"+aRets[_RETIB][nX][9])
				If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA850" .and. ExistFunc("F855IncRet")
					F855IncRet("B",FJK->FJK_PREOP,aRets[_RETIB][nX],cFornece,cLoja,cParcela)
				EndIf
                
				If aRets[_RETIB][nX][17]  //Generar Retencion Adicional
				
					nSFEValBas := aRets[_RETIB][nX][3]
					nSFEValImp := Iif(aRets[_RETIB][nX][17],(aRets[_RETIB][nX][5]*aRets[_RETIB][nX][20])/aRets[_RETIB][nX][4],aRets[_RETIB][nX][5])
					nSFERetenc := Iif(aRets[_RETIB][nX][17],(aRets[_RETIB][nX][5]*aRets[_RETIB][nX][20])/aRets[_RETIB][nX][4],aRets[_RETIB][nX][5])
				    
					If lPAd 
 						nSFEValBas	:=	Round(xMoeda(nSFEValBas,nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						nSFEValImp	:=	Round(xMoeda(nSFEValImp,nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						nSFERetenc	:=	Round(xMoeda(nSFERetenc,nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
					EndIf
					
					RecLock("SFE",.T.)
					FE_FILIAL   :=	xFilial("SFE")
					FE_NROCERT  :=	cNroCert
					FE_EMISSAO  :=	dDataBase
					FE_FORNECE  :=	cFornece
					FE_LOJA     :=	cLoja
					FE_TIPO     :=	"B"
					FE_ORDPAGO  :=	cOrdPago
					FE_PARCELA  :=	cParcela
					If lGerPa
						FE_NFISCAL 	:=	" "
					Else
						FE_NFISCAL 	:=	aRets[_RETIB][nX][1]
					EndIf
					FE_SERIE	:=	aRets[_RETIB][nX][2]
					FE_VALBASE	:=	nSFEValBas
					FE_ALIQ   	:=	Round(xMoeda(Iif(aRets[_RETIB][nX][17],aRets[_RETIB][nX][20],aRets[_RETIB][nX][4]),nMoedaRet,1,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
					FE_VALIMP	:=	nSFEValImp
					FE_RETENC	:=	nSFERetenc
					FE_EST	:=	aRets[_RETIB][nX][9]
					FE_CFO	:=	aRets[_RETIB][nX][18]
					FE_CONCEPT	:=  aRets[_RETIB][nX][14]
					FE_DEDUC	:=  aRets[_RETIB][nX][15]
					FE_PORCRET	:=  aRets[_RETIB][nX][16]
					MsUnLock()
				Endif  
				nPos:=AScan(aCert,{|x| x[1]==Padr(cNroCert,TamSx3("FE_NROCERT")[1],"") .And. x[2]=="B" })
				If nPos = 0
					AAdd(aCert,{Padr(cNroCert,TamSx3("FE_NROCERT")[1],""),"B",SFE->FE_EST })
				EndIf
				RecLock("SEK",.T.)
				SEK->EK_FILIAL  := xFilial("SEK")
				SEK->EK_TIPODOC := "RG" //Retencion Generada
				SEK->EK_NUM     := cNroCert
				SEK->EK_TIPO    := "IB-"
				SEK->EK_EMISSAO	:= dDataBase
				If  cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPAd .And. ((GETMV("MV_FINCTAL") == "2") .OR. (IsInCallStack("F850PgAdi") .And. !lSolicFundo))  				
					SEK->EK_VLMOED1 := nSFEValImp 
					SEK->EK_VALOR   := nSFEValImp
					SEK->EK_SALDO   := nSFEValImp
				Else 
					SEK->EK_VLMOED1 := nSFEValImp 
					SEK->EK_VALOR   := Round(xMoeda(nSFEValImp,1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
					SEK->EK_SALDO   := Round(xMoeda(nSFEValImp,1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
				EndIf	
				SEK->EK_VENCTO  := dDataBase
				SEK->EK_FORNECE := cFornece
				SEK->EK_LOJA    := cLoja  
				SEK->EK_MOEDA	:= StrZero(Iif((lPad .And. IsInCallStack("F850PgAdi") .And. !lSolicFundo),1,nMoedaRet),TamSx3("EK_MOEDA")[1])
				SEK->EK_ORDPAGO := cOrdPago
				SEK->EK_DTDIGIT := dDataBase
				SEK->EK_EST 	  := aRets[_RETIB][nX][9]
				If cPaisLoc <> "BRA"
			   		SEK->EK_FORNEPG:= cFornece
		   			SEK->EK_LOJAPG:= cLoja
				   SEK->EK_NATUREZ:= cNatureza
				Endif
				If cPaisLoc == "ARG"
					SEK->EK_PGCBU:= lCBU
					If !lPAd
						If lProcCCR .And. SEK->(ColumnPos("EK_CCR")) > 0
							SEK->EK_CCR := mv_par15
						Endif
					Endif	
				Endif
				F850GrvTx()
				MsUnlock()

				If !Empty(aRets[_RETIB][nX][17]) .And. !Empty(aRets[_RETIB][nX][18])
					aAdd(aVlRetIB,{SEK->EK_VALOR,aRets[_RETIB][nX][17],aRets[_RETIB][nX][18]})
				EndIf

				If cOpcElt <> "1"
					If GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPAd
						aTitPags[1]	-= nSFEValImp 
					ElseIf  IsInCallStack("F850PgAdi")  .And. nMoedaRet <> 1  .and. lPAd .And. !lSolicFundo
						aTitPags[1]	-=  Round(xMoeda(nSFEValImp,1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
					Else
						aTitPags[1]	-=	aRets[_RETIB][nX][5]
					EndIf	
				EndIf
				If lF850Ret
					ExecBLock("F850RET",.F.,.F.,"IB")
				Endif
				//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
				If !lSmlCtb
					PcoDetLan("000313","05","FINF850")
				Endif
			EndIf
		Next

		//Reten็ใo de IB da Ordem de Pago
		If lTitRet
			For nX := 1 to Len(aVlRetIB)
				nPosImp := aScan(aTitImp, {|x| x[10] == "IIB" })
				If nPosImp > 0
					aTitImp[nPosImp][7] += aVlRetIB[nX][1]
				Else
					aAdd(aTitImp,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, aVlRetIB[nX][1], cOrdPago, dDataBase, "IIB", 1,,,Iif(SE2->(ColumnPos("E2_CODAPRO"))>0,SE2->E2_CODAPRO,"")})
				EndIf
			Next nX
			aVlRetIB := {}
		EndIf

		For nX   	:= 1	To Len(aRets[_RETSUSS])
			If aRets[_RETSUSS][nX][3] != 0
				aRatSUSS := F850RatSuss(cFornece,cLoja)
				For nS:=1 to Len(aRatSUSS)
					If aRets[_RETSUSS][nX][6] != 0
						If aRatSUSS[nS][4]== .T.
							cNroCert	:=	F850GetCert("US   ",aRatSUSS[nS][1]+aRatSUSS[nS][2]+"US "+aRets[_RETSUSS][nX][8] )
						Else
							cNroCert	:=	F850GetCert("SU   ",aRatSUSS[nS][1]+aRatSUSS[nS][2]+"SU "+aRets[_RETSUSS][nX][8] )
						EndIf
					Else
						cNroCert	:= "NORET"
					EndIf
					RecLock("SFE",.T.)
					FE_FILIAL	:=	xFilial("SFE")
					FE_NROCERT	:=	cNroCert
					FE_EMISSAO  :=	dDataBase
					FE_FORNECE  :=	aRatSUSS[nS][1]
					FE_LOJA     :=	aRatSUSS[nS][2]
					FE_TIPO     :=	Iif(aRatSUSS[nS][4]== .T. ,"U","S")
					FE_ORDPAGO  :=	cOrdPago
					FE_PARCELA	:=	cParcela
					FE_NFISCAL 	:=	aRets[_RETSUSS][nX][1]
					SerieNFID("SFE",1,"FE_SERIE",FE_EMISSAO,FE_TIPO,aRets[_RETSUSS][nX][2])	
					FE_VALBASE	:=	aRets[_RETSUSS][nX][3] * aRatSUSS[nS][3]
					FE_VALIMP	:=	aRets[_RETSUSS][nX][4] * aRatSUSS[nS][3]
					FE_PORCRET	:=	aRets[_RETSUSS][nX][5]
					FE_RETENC	:=  aRets[_RETSUSS][nX][6] * aRatSUSS[nS][3]
					FE_FORCOND := cFornece
					FE_NUMOPER  :=  cNumOP
					FE_LOJCOND := cLoja
					FE_ALIQ   	:= aRets[_RETSUSS][nX][7]
					FE_CONCEPT	:= aRets[_RETSUSS][nX][8]
					If SFE->(ColumnPos("FE_TPCALR"))>0
						SFE->FE_TPCALR  :=  "A"
					EndIf
					If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA850" .and. ExistFunc("F855IncRet")
						F855IncRet("S",FJK->FJK_PREOP,aRets[_RETSUSS][nX],cFornece,cLoja,cParcela)
					EndIf 

					MsUnLock()
					METRET850("SUSS")
					nPos:=AScan(aCert,{|x| x[1]==Padr(cNroCert,TamSx3("FE_NROCERT")[1],"") .And. x[2]=="S"})
					If nPos = 0
						AAdd(aCert,{Padr(cNroCert,TamSx3("FE_NROCERT")[1],""),"S",ALLTRIM(aRets[_RETSUSS][nX][8])+aRets[_RETSUSS][nX][10]})
					EndIf
					If aRets[_RETSUSS][nX][6] != 0
						RecLock("SEK",.T.)
						SEK->EK_FILIAL  := xFilial("SEK")
						SEK->EK_TIPODOC := "RG" //Retencion Generada
						SEK->EK_NUM     := cNroCert
						SEK->EK_TIPO    := Iif(aRatSUSS[nS][4]== .T. ,"SS-","SU-")
						SEK->EK_EMISSAO	:= dDataBase
						SEK->EK_VLMOED1 := aRets[_RETSUSS][nX][6]* aRatSUSS[nS][3]
						SEK->EK_VALOR   := Round(xMoeda((aRets[_RETSUSS][nX][6]* aRatSUSS[nS][3]),1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						SEK->EK_SALDO   := Round(xMoeda((aRets[_RETSUSS][nX][6]* aRatSUSS[nS][3]),1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						SEK->EK_VENCTO  := dDataBase
						SEK->EK_FORNECE := aRatSUSS[nS][1]
						SEK->EK_LOJA    := aRatSUSS[nS][2]
						SEK->EK_MOEDA	:= StrZero(nMoedaRet,TamSx3("EK_MOEDA")[1]) //"01"
						SEK->EK_ORDPAGO := cOrdPago
						SEK->EK_DTDIGIT := dDataBase
						If cPaisLoc <> "BRA"
					   		SEK->EK_FORNEPG:= cFornece
				   			SEK->EK_LOJAPG:= cLoja
						Endif
						If cPaisLoc == "ARG"
							EK_NUMOPER  :=  cNumOP
							SEK->EK_PGCBU:= lCBU
							SEK->EK_NROCERT:= cNroCert
							If !lPAd
								lProcCCR := Iif(!lOPRotAut,lProcCCR,(SEK->(ColumnPos("EK_CCR")) > 0))
								If lProcCCR .And. SEK->(ColumnPos("EK_CCR")) > 0
									SEK->EK_CCR := mv_par15
								Endif
							Endif	
						Endif
						F850GrvTx()
						MsUnlock()

						If lReSaIV
												    
							dbSelectArea("SF1")
							SF1->(dbSetOrder( RETORDEM("SF1","F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO") ))
							If SF1->(MsSeek(xFilial("SF1")+aRets[_RETSUSS][nX][1]+aRets[_RETSUSS][nX][2]+cFornece+cLoja))
								RecLock("SF1",.F.)
								If Empty(SF1->F1_RETSUSS)
									SF1->F1_RETSUSS := aRets[_RETSUSS][nX][13]
									lPrimV	:= .T.
								ElseIf lPrimV	== .T.
									SF1->F1_RETSUSS += aRets[_RETSUSS][nX][13]
								Endif 
								If Empty(SF1->F1_SALSUSS)
									SF1->F1_SALSUSS := SF1->F1_RETSUSS - IIF(aRets[_RETSUSS][nX][6] <0,aRets[_RETSUSS][nX][6]*-1,aRets[_RETSUSS][nX][6])
								Else
									SF1->F1_SALSUSS -= IIF(aRets[_RETSUSS][nX][6] <0,aRets[_RETSUSS][nX][6]*-1,aRets[_RETSUSS][nX][6])
								Endif 
								SF1->(MsUnLock())
							EndIf
		
							dbSelectArea("SF2")
							SF2->(dbSetOrder( RETORDEM("SF2","F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO") ))
							If SF2->(MsSeek(xFilial("SF2")+aRets[_RETSUSS][nX][1]+aRets[_RETSUSS][nX][2]+cFornece+cLoja))
								RecLock("SF2",.F.)
								If Empty(SF2->F2_RETSUSS)
									SF2->F2_RETSUSS := aRets[_RETSUSS][nX][13]
									lPrimV	:= .T.
								ElseIf lPrimV	== .T.
									SF2->F2_RETSUSS += aRets[_RETSUSS][nX][13]
								Endif 
								If Empty(SF2->F2_SALIVA)
									SF2->F2_SALSUSS := SF2->F2_RETSUSS - IIF(aRets[_RETSUSS][nX][6] <0,aRets[_RETSUSS][nX][6]*-1,aRets[_RETSUSS][nX][6])
								Else
									SF2->F2_SALSUSS -= IIF(aRets[_RETSUSS][nX][6] <0,aRets[_RETSUSS][nX][6]*-1,aRets[_RETSUSS][nX][6])
								Endif 
								SF2->(MsUnLock())
							EndIf
						Endif

						nValRet += SEK->EK_VALOR

			 	  		If lF850Ret
							ExecBLock("F850RET",.F.,.F.,"SUSS")
						Endif
						//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
						If !lSmlCtb
							PcoDetLan("000313","05","FINF850")
						Endif
					EndIf
				Next
				If cOpcElt <> "1"
					aTitPags[1]	-=	aRets[_RETSUSS][nX][6]
				EndIf
			EndIf
		Next

		//Reten็ใo de SUSS da Ordem de Pago
		If lTitRet .And. nValRet > 0
			nPosImp := aScan(aTitImp, {|x| x[10] == "SUS" })
			If nPosImp > 0
				aTitImp[nPosImp][7] += nValRet
			Else
				aAdd(aTitImp,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValRet, cOrdPago, dDataBase, "SUS", 1,,,Iif(SE2->(ColumnPos("E2_CODAPRO"))>0,SE2->E2_CODAPRO,"")})
			EndIf
			nValRet := 0
		EndIf

		For nX 	:= 1 To Len(aRets[_RETSLI])
			If aRets[_RETSLI][nX][6] != 0
				cNroCert	:=	F850GetCert("SI   ",cFornece+cLoja+"SI ")
				RecLock("SFE",.T.)
				FE_FILIAL	:=	xFilial("SFE")
				FE_NROCERT	:=	cNroCert
				FE_EMISSAO  :=	dDataBase
				FE_FORNECE  :=	cFornece
				FE_LOJA     :=	cLoja
				FE_TIPO     :=	"L"
				FE_ORDPAGO  :=	cOrdPago
				FE_PARCELA	:=	cParcela
				FE_NFISCAL 	:=	aRets[_RETSLI][nX][1]
				SerieNFID("SFE",1,"FE_SERIE",FE_EMISSAO,FE_TIPO,aRets[_RETSLI][nX][2])
				FE_VALBASE	:=	aRets[_RETSLI][nX][3]
				FE_VALIMP	:=	aRets[_RETSLI][nX][4]
				FE_PORCRET	:=	aRets[_RETSLI][nX][5]
				FE_RETENC	:=	aRets[_RETSLI][nX][6]
				MsUnLock()
				METRET850("SLI")
				RecLock("SEK",.T.)
				SEK->EK_FILIAL  := xFilial("SEK")
				SEK->EK_TIPODOC := "RG" //Retencion Generada
				SEK->EK_NUM     := cNroCert
				SEK->EK_TIPO    := "SL-"
				SEK->EK_EMISSAO	:= dDataBase
				SEK->EK_VLMOED1 := aRets[_RETSLI][nX][6]
				SEK->EK_VALOR   := Round(xMoeda(aRets[_RETSLI][nX][6],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
				SEK->EK_SALDO   := Round(xMoeda(aRets[_RETSLI][nX][6],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
				SEK->EK_VENCTO  := dDataBase
				SEK->EK_FORNECE := cFornece
				SEK->EK_LOJA    := cLoja
				SEK->EK_MOEDA	:= StrZero(nMoedaRet,TamSx3("EK_MOEDA")[1]) //"01"
				SEK->EK_ORDPAGO := cOrdPago
				SEK->EK_DTDIGIT := dDataBase
				If cPaisLoc <> "BRA"
			   		SEK->EK_FORNEPG:= cFornece
		   			SEK->EK_LOJAPG:= cLoja
					SEK->EK_NATUREZ:= cNatureza
				Endif
				If cPaisLoc == "ARG"
					SEK->EK_PGCBU:= lCBU
					If !lPAd
						lProcCCR := Iif(!lOPRotAut,lProcCCR,(SEK->(ColumnPos("EK_CCR")) > 0))
						If lProcCCR .And. SEK->(ColumnPos("EK_CCR")) > 0
							SEK->EK_CCR := mv_par15
						Endif
					Endif	
				Endif
				F850GrvTx()
				MsUnlock()

				nValRet += SEK->EK_VALOR

				If cOpcElt <> "1"
					aTitPags[1]	-=	aRets[_RETSLI][nX][6]
				EndIf
				If lF850Ret
					ExecBLock("F850RET",.F.,.F.,"SIL")
				Endif
				//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
				If !lSmlCtb
					PcoDetLan("000313","05","FINF850")
				Endif
			EndIf
		Next

		//Reten็ใo de SLI da Ordem de Pago
		If lTitRet .And. nValRet > 0
			nPosImp := aScan(aTitImp, {|x| x[10] == "SLI" })
			If nPosImp > 0
				aTitImp[nPosImp][7] += nValRet
			Else
				aAdd(aTitImp,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValRet, cOrdPago, dDataBase, "SLI", nMoedaRet,,, SE2->E2_CODAPRO })
			EndIf
			nValRet := 0
		EndIf

		// nใo Gera ISI para PA
		If !lGerPA
			For nX   	:= 1	To Len(aRets[_RETISI])
				If aRets[_RETISI][nX][3] != 0
					For nY := 1 To Len(aRets[_RETISI][nX][8])
						If aRets[_RETISI][nX][8][nY][3] != 0
							cNroCert	:=	F850GetCert("SIS "/*+aRets[_RETISI][nX][9]*/,cFornece+cLoja+"SIS "/*+aRets[_RETISI][nX][9]*/)
						Else
							cNroCert	:= "NORET"
						EndIf
	
						//Obtiene el codigo de la provincia correspondiente al codigo del muncipio que se dia de alta.
						aSA2Area := SA2->(GetArea())
						SA2->(DbSelectArea("SA2"))
						SA2->(DbSetOrder(RetOrdem("SA2","A2_FILIAL+A2_COD+A2_LOJA"))) //1 
						SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja))
						
						cTmpMun := GetNextAlias()
						cQryMun := "SELECT EST.X5_CHAVE	AS MUNCOD "
						cQryMun += "FROM " + RetSqlName("SX5") + " EST "
						cQryMun += "INNER JOIN " + RetSqlName("SX5") + " MUN ON UPPER(EST.X5_DESCSPA) = UPPER(MUN.X5_DESCSPA) "
						cQryMun += "WHERE EST.X5_FILIAL = '" + xFilial("SX5") + "' AND EST.X5_TABELA = '12' "
						cQryMun += "AND MUN.X5_FILIAL = '" + xFilial("SX5") + "' AND MUN.X5_TABELA = 'S1' "
						cQryMun += "AND MUN.X5_CHAVE = '" + SA2->A2_RET_MUN + "'"
						cQryMun := ChangeQuery(cQryMun)
						DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryMun ),cTmpMun,.F.,.T.)
						(cTmpMun)->(dbGoTop())
				
						While !((cTmpMun)->(EOF()))
							cEstMun := (cTmpMun)->MUNCOD
							(cTmpMun)->(dbSkip())
						Enddo
						DbCloseArea()
						SA2->(RestArea(aSA2Area))
	
						RecLock("SFE",.T.)
						FE_FILIAL		:=	xFilial("SFE")
						FE_NROCERT		:=	cNroCert
						FE_EMISSAO		:=	dDataBase
						FE_FORNECE		:=	cFornece
						FE_LOJA		:=	cLoja
						FE_TIPO		:=	"M" 
						FE_ORDPAGO		:=	cOrdPago
						FE_PARCELA		:=	cParcela
						If lGerPa
							FE_NFISCAL 	:=	" "
						Else
							FE_NFISCAL 	:=	aRets[_RETISI][nX][1]
						EndIf
						SerieNFID("SFE",1,"FE_SERIE",FE_EMISSAO,FE_TIPO,aRets[_RETISI][nX][2])
						FE_VALBASE	:=	aRets[_RETISI][nX][3]
						FE_ALIQ   	:=	aRets[_RETISI][nX][8][nY][1]
						FE_VALIMP	:=	aRets[_RETISI][nX][8][nY][3]
						FE_RETENC	:=	aRets[_RETISI][nX][8][nY][3]
						FE_CFO		:=	aRets[_RETISI][nX][8][nY][4]
						If Empty(cEstMun) 
							FE_EST := aRets[_RETISI][nX][9]
						Else
							FE_EST := cEstMun
						EndIf
						FE_RET_MUN	:=	aRets[_RETISI][nX][10]
						If SFE->(ColumnPos("FE_TPCALR"))>0
							SFE->FE_TPCALR  :=  "A"
						EndIf

						MsUnLock()
						METRET850("ISI"+(Iif (Empty(cEstMun),aRets[_RETISI][nX][9] ,cEstMun) ) )
						nPos:=AScan(aCert,{|x| x[1]==Padr(cNroCert,TamSx3("FE_NROCERT")[1],"") .And. x[2]=="M" .And. x[3]==cChave1})
						If nPos = 0
							AAdd(aCert,{Padr(cNroCert,TamSx3("FE_NROCERT")[1],""),"M",cChave1, aRets[_RETISI][nX][8]})
						EndIf    
				    
						cImposto := Alltrim(aRets[_RETISI][nX][8][nY][2])
						cCFC := aRets[_RETISI][nX][8][nY][4]
					    npos:=0
					    If Len(aCert[Len(aCert)]) >=4
					    	nPos:=AScan(aCert[Len(aCert)][4],{|x| x[2] == cImposto .And. x[4]== cCFC}) //
						EndIf
						If nPos == 0 .And. Len(aCert[Len(aCert)]) >=4
							aAdd(aCert[Len(aCert)][4],{0,0,0,0})
							aCert[Len(aCert)][4][Len(aCert[Len(aCert)][4])][1] := aRets[_RETISI][nX][8][nY][1]
							aCert[Len(aCert)][4][Len(aCert[Len(aCert)][4])][2] := aRets[_RETISI][nX][8][nY][2]
							aCert[Len(aCert)][4][Len(aCert[Len(aCert)][4])][3] := aRets[_RETISI][nX][8][nY][3]
							aCert[Len(aCert)][4][Len(aCert[Len(aCert)][4])][4] := aRets[_RETISI][nX][8][nY][4]
						Endif

						RecLock("SEK",.T.)
						SEK->EK_FILIAL  := xFilial("SEK")
						SEK->EK_TIPODOC := "RG" //Retencion Generada
						SEK->EK_NUM     := cNroCert
						SEK->EK_TIPO    := "SI-"
						SEK->EK_EMISSAO	:= dDataBase
						SEK->EK_VLMOED1 := aRets[_RETISI][nX][8][nY][3]
						SEK->EK_VALOR   := Round(xMoeda(aRets[_RETISI][nX][8][nY][3],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						SEK->EK_SALDO   := Round(xMoeda(aRets[_RETISI][nX][8][nY][3],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
						SEK->EK_VENCTO  := dDataBase
						SEK->EK_FORNECE := cFornece
						SEK->EK_LOJA    := cLoja
						SEK->EK_MOEDA	:= StrZero(nMoedaRet,TamSx3("EK_MOEDA")[1]) //"01"
						SEK->EK_ORDPAGO := cOrdPago
						SEK->EK_DTDIGIT := dDataBase
						If cPaisLoc <> "BRA"
							SEK->EK_FORNEPG:= cFornece
							SEK->EK_LOJAPG:= cLoja
						SEK->EK_NATUREZ:= cNatureza
						Endif
						If cPaisLoc == "ARG"
							SEK->EK_PGCBU:= lCBU
							If !lPAd
								lProcCCR := Iif(!lOPRotAut,lProcCCR,(SEK->(ColumnPos("EK_CCR")) > 0))
								If lProcCCR .And. SEK->(ColumnPos("EK_CCR")) > 0
									SEK->EK_CCR := mv_par15
								Endif
							Endif	
						Endif
						F850GrvTx()
						MsUnlock()

						nValRet += SEK->EK_VALOR

						If cOpcElt <> "1"
							aTitPags[1]	-=	aRets[_RETISI][nX][8][nY][3]
						EndIf
						If lF850Ret
							ExecBLock("F850RET",.F.,.F.,"SIS")
						Endif
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If !lSmlCtb
							PcoDetLan("000313","05","FINF850")
						Endif
					Next
				EndIf
			Next

			//Reten็ใo de ISI da Ordem de Pago
			If lTitRet .And. nValRet > 0
				nPosImp := aScan(aTitImp, {|x| x[10] == "M" })
				If nPosImp > 0
					aTitImp[nPosImp][7] += nValRet
				Else
					aAdd(aTitImp,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValRet, cOrdPago, dDataBase, "M", nMoedaRet,,,Iif(SE2->(ColumnPos("E2_CODAPRO"))>0,SE2->E2_CODAPRO,"")})
				EndIf
				nValRet := 0
			EndIf

		EndIf
	Else
		If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA850" .and. ExistFunc("F855DelRet")
			F855DelRet(FJK->FJK_PREOP,cFornece,cLoja,"",.T.)
		EndIf
		If Len(aRatCond) >0
			aRets:= F850CalcRet(aRatCond,aRets)
		EndIf
		aSort(aRets,,,{|x,y| x[7]<=y[7] })
		For nX := 1	To Len(aRets)
			// Guilherme
			// Carrega Array con valores de Retencao, totalizando por CERTIFICADO.
			If aRets[nX][5] <> 0 .Or. aRets[nX][12] == .T.
				cNroCert	:=	F850GetCert("GANAN",cFornece+cLoja+"GANAN"+Str(nx,1),.F.)
				nPosVal := AScan(aValGan,{|x| x[1] == cNroCert} )
				If Len(aValGan) = 0 .Or. ( nPosVal == 0)
					nContGan ++
					AAdd(aValGan,{cNroCert,0})
					cNroCert1:=	cNroCert
				ElseIf nPosVal > 0
					nContGan := nPosVal
				Endif
				aValGan[nContGan][2] += aRets[nX][5]
			Else
				cNroCert	:=	'NORET'
			EndIf

			If cNroCert1 == "NORET"
				cNroCert1:=	cNroCert
			Endif
			If Alltrim(cNroCert) <> "NORET"
				AAdd(aCert,{Padr(cNroCert,TamSx3("FE_NROCERT")[1],""),"G"})
			Endif
			
			SFE->(RecLock("SFE",.T.))
			SFE->FE_FILIAL	:=	xFilial("SFE")
			SFE->FE_NROCERT	:=	cNroCert
			SFE->FE_EMISSAO  :=	dDataBase
			SFE->FE_FORNECE  :=	cFornece
			SFE->FE_LOJA     :=	cLoja
			SFE->FE_TIPO     :=	"G"
			SFE->FE_ORDPAGO  :=	cOrdPago
			SFE->FE_VALBASE	:=	aRets[nX][2]
			SFE->FE_ALIQ   	:=	aRets[nX][3]
			SFE->FE_VALIMP	:=	aRets[nX][4]
			SFE->FE_RETENC	:=	aRets[nX][5]
			SFE->FE_DEDUC  	:=	aRets[nX][6]
			SFE->FE_CONCEPT	:=	aRets[nX][7]
			SFE->FE_PORCRET	:=	aRets[nX][8]
			SFE->FE_CONCEP2	:=	aRets[nX][9]
			SFE->FE_FORCOND  :=	aRets[nX][10]
			SFE->FE_LOJCOND  :=	aRets[nX][11]
			If SFE->(ColumnPos("FE_TPCALR"))>0
				SFE->FE_TPCALR  :=  "A"
			EndIf
				
			If lPaExced
				SFE->FE_ESPECIE := "PA"
			EndIf

			SFE->(MsUnLock())
			METRET850("GAN")
			If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA850" .and. ExistFunc("F855IncRet")
				F855IncRet("G",FJK->FJK_PREOP,aRets[nX],cFornece,cLoja,"")
			EndIf
		Next

		//Grava um titulo por CERTIFICADO de retencao  // Guilherme
		For nX := 1 To Len(aValGan)
			RecLock("SEK",.T.)
			SEK->EK_FILIAL  := xFilial("SEK")
			SEK->EK_TIPODOC := "RG" //Retencion Generada
			SEK->EK_NUM     := cNroCert1
			SEK->EK_TIPO    := "GN-"
			SEK->EK_EMISSAO := dDataBase
			If lPad
				If GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPAd 
					SEK->EK_VLMOED1 := Round(xMoeda(aValGan[nX][2],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
					SEK->EK_VALOR   := Round(xMoeda(aValGan[nX][2],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
					SEK->EK_SALDO   := Round(xMoeda(aValGan[nX][2],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))				
				Else 
					IF  IsInCallStack("F850PgAdi") .And. !lSolicFundo .And. nMoedaRet <> 1 .and. lPAd
						SEK->EK_VLMOED1 := aValGan[nX][2]
						SEK->EK_VALOR   := aValGan[nX][2]
						SEK->EK_SALDO   := aValGan[nX][2]	
					Else
						SEK->EK_VLMOED1 := xMoeda(aValGan[nX][2],nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2],aTxMoedas[1][2])
						SEK->EK_VALOR   := xMoeda(aValGan[nX][2],nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2],aTxMoedas[1][2])
						SEK->EK_SALDO   := xMoeda(aValGan[nX][2],nMoedaRet,1,,3,aTxMoedas[nMoedaRet][2],aTxMoedas[1][2])
					Endif
				EndIf	
			Else	
				SEK->EK_VLMOED1 := aValGan[nX][2]
				SEK->EK_VALOR   := Round(xMoeda(aValGan[nX][2],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
				SEK->EK_SALDO   := Round(xMoeda(aValGan[nX][2],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
			EndIf
			SEK->EK_VENCTO  := dDataBase
			SEK->EK_FORNECE := cFornece
			SEK->EK_LOJA    := cLoja
			If GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPAd 
				SEK->EK_MOEDA	:= StrZero(nMoedaRet,TamSx3("EK_MOEDA")[1])
			Else			
				SEK->EK_MOEDA	:= StrZero(Iif(!lPad,nMoedaRet,1),TamSx3("EK_MOEDA")[1])
			EndIf
			SEK->EK_ORDPAGO := cOrdPago
			SEK->EK_DTDIGIT := dDataBase
			If cPaisLoc <> "BRA"
		   		SEK->EK_FORNEPG:= cFornece
	   			SEK->EK_LOJAPG:= cLoja
			   SEK->EK_NATUREZ:= cNatureza
			Endif
			If cPaisLoc == "ARG"
				SEK->EK_PGCBU:= lCBU
				If !lPAd
					lProcCCR := Iif(!lOPRotAut,lProcCCR,(SEK->(ColumnPos("EK_CCR")) > 0))
					If lProcCCR .And. SEK->(ColumnPos("EK_CCR")) > 0
						SEK->EK_CCR := mv_par15
					Endif
				Endif	
			Endif
			F850GrvTx()
			MsUnlock()

			nValRet += SEK->EK_VALOR

			If cOpcElt <> "1"
				If  cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPAd  .And. ((GETMV("MV_FINCTAL") == "2") .OR.  (IsInCallStack("F850PgAdi") .And. !lSolicFundo ) )
					aTitPags[1]	-= Round(xMoeda(aValGan[nX][2],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
				Else
					aTitPags[1]	-=	aValGan[nX][2]
				EndIf	
			EndIf
			If lF850Ret
				ExecBLock("F850RET",.F.,.F.,"GAN")
			Endif
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Grava os lancamentos nas contas orcamentarias SIGAPCO    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !lSmlCtb
				PcoDetLan("000313","05","FINF850")
			Endif
		Next

		//Reten็ใo de Ganancias da Ordem de Pago
		If lTitRet .And. nValRet > 0
			nPosImp := aScan(aTitImp, {|x| x[10] == "GAN" })
			If nPosImp > 0
				aTitImp[nPosImp][7] += nValRet
			Else
				If GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG" .And. nMoedaRet <> 1 .and. lPAd 
					cCodApro:= FA050Aprov(1)
					aAdd(aTitImp,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValRet, cOrdPago, dDataBase, "GAN", 1,,,Iif(SE2->(ColumnPos("E2_CODAPRO"))>0,cCodApro,"")})
				Else
					aAdd(aTitImp,{SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValRet, cOrdPago, dDataBase, "GAN", 1,,,Iif(SE2->(ColumnPos("E2_CODAPRO"))>0,SE2->E2_CODAPRO,"")})
				EndIf					
			EndIf
			nValRet := 0
		EndIf

	Endif
ElseIf cPaisLoc=="ANG"
	If !lGan
		For nX	:= 1	To Len(aRets[_RETRIE])
			If aRets[_RETRIE][nX][6] != 0
				cNroCert	:=	F850GetCert("RIE  ",cFornece+cLoja+"RIE")
				RecLock("SFE",.T.)
				FE_FILIAL	:=	xFilial("SFE")
				FE_NROCERT	:=	cNroCert
				FE_EMISSAO  :=	dDataBase
				FE_FORNECE  :=	cFornece
				FE_LOJA     :=	cLoja
				FE_TIPO     :=	"3"
				FE_ORDPAGO  :=	cOrdPago
				FE_PARCELA	:=	cParcela
				If lGerPA
					FE_NFISCAL 	:=	cOrdPago
					SerieNFID("SFE",1,"FE_SERIE",FE_EMISSAO,FE_TIPO,"PA")
				Else
					FE_NFISCAL 	:=	aRets[_RETRIE][nX][1]
					SerieNFID("SFE",1,"FE_SERIE",FE_EMISSAO,FE_TIPO,aRets[_RETRIE][nX][2])
				Endif
				FE_VALBASE	:=	aRets[_RETRIE][nX][3]
				FE_VALIMP	:=	aRets[_RETRIE][nX][4]
				FE_PORCRET	:=	aRets[_RETRIE][nX][5]
				FE_RETENC	:=	aRets[_RETRIE][nX][6]
				MsUnLock()

				RecLock("SEK",.T.)
				SEK->EK_FILIAL  := xFilial("SEK")
				SEK->EK_TIPODOC := "RG" //Retencion Generada
				SEK->EK_NUM     := cNroCert
				SEK->EK_TIPO    := "IE-"
				SEK->EK_EMISSAO	:= dDataBase
				SEK->EK_VLMOED1 := aRets[_RETRIE][nX][6]
				SEK->EK_VALOR   := Round(xMoeda(aRets[_RETRIE][nX][6],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
				SEK->EK_SALDO   := Round(xMoeda(aRets[_RETRIE][nX][6],1,nMoedaRet,,3,,aTxMoedas[nMoedaRet][2]),MsDecimais(nMoedaRet))
				SEK->EK_VENCTO  := dDataBase
				SEK->EK_FORNECE := cFornece
				SEK->EK_LOJA    := cLoja
				SEK->EK_MOEDA	:= StrZero(nMoedaRet,TamSx3("EK_MOEDA")[1]) //"01"
				SEK->EK_ORDPAGO := cOrdPago
				SEK->EK_DTDIGIT := dDataBase
		   		SEK->EK_FORNEPG:= cFornece
	   			SEK->EK_LOJAPG:= cLoja
				If cPaisLoc <> "BRA"
				   SEK->EK_NATUREZ:= cNatureza
				Endif
				F850GrvTx()
				MsUnlock()
				nValRet := SEK->EK_VALOR
				aTitPags[1]	-=	aRets[_RETRIE][nX][6]
				If lF850Ret
					ExecBLock("F850RET",.F.,.F.,"IVA")
				Endif
			EndIf
		Next
		//Reten็ใo de RIE da Ordem de Pago
		F850TitRet(aTitImp,nValRet,cOrdPago,dDataBase,nMoedaRet,"RIE")
	Endif
EndIf

Return aCert

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ F850GetCertบAutor  ณMicrosiga           บ Data ณ    /  /   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณPega os numeros de certificados de retencao                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850GetCert(cImposto,cChave,lReUsa)
Local cNroCert	:=	""
Local nPosCert	:=	0
Local nCNROCERT	:= 0
Local nTamCpoCert := TamSx3("FE_NROCERT")[1]

DEFAULT lReUsa	:=	.T.

If lReUsa
	nPosCert :=	Ascan(aCerts,{|x| X[1] == cChave } )
Endif
If nPosCert > 0
	Return  aCerts[nPosCert][2]
Endif

DO CASE
	CASE cPaisLoc=="PER"
		DbSelectArea("SX5")
		IF !MsSeek(xFilial("SX5")+"99"+cImposto,.F.)
			RecLock("SX5", .T.)
				SX5->X5_TABELA 	:= '99'
				SX5->X5_FILIAL 	:= xFilial("SX5")
				SX5->X5_CHAVE  	:= cImposto
				SX5->X5_DESCRI 	:= '00000001'
				SX5->X5_DESCSPA := '00000001'
				SX5->X5_DESCENG := '00000001'
				cNroCert       	:= '00000001'
			MsUnLock()
		Else
			cNroCert := StrZero(Val(X5DESCRI())+1,8)
			Reclock("SX5",.F.)
			SX5->X5_DESCRI 	:= StrZero(Val(cNroCert),8)
			SX5->X5_DESCSPA := StrZero(Val(cNroCert),8)
			SX5->X5_DESCENG := StrZero(Val(cNroCert),8)
			MsUnLock()
		EndIf
	OTHERWISE
		If  cPaisloc == "ARG" .and. !(Empty(GetMv("MV_CERT"+alltrim(SUBSTR(cImposto,1,3)),.F.,"")))
			nNROCERT := Val(GetMv("MV_CERT"+alltrim(SUBSTR(cImposto,1,3))))
			cNroCert := StrZero(nNROCERT,TamSx3("FE_NROCERT")[1])
			PUTMV( "MV_CERT"+alltrim(SUBSTR(cImposto,1,3)), SOMA1( cNroCert ))

		Else 			
			DbSelectArea("SX5")
			IF ! MsSeek(xFilial("SX5")+"99"+cImposto,.F.)
				RecLock("SX5", .T.)
				SX5->X5_TABELA 	:= '99'
				SX5->X5_FILIAL 	:= xFilial("SX5")
				SX5->X5_CHAVE  	:= cImposto
				SX5->X5_DESCRI 	:= StrZero(1,nTamCpoCert)
				SX5->X5_DESCSPA := StrZero(1,nTamCpoCert)
				SX5->X5_DESCENG := StrZero(1,nTamCpoCert)
				cNroCert       	:= StrZero(1,nTamCpoCert)
				MsUnLock()
			Else
				cNroCert := StrZero(Val(X5DESCRI())+1,nTamCpoCert)
				Reclock("SX5",.F.)
				SX5->X5_DESCRI 	:= StrZero(Val(cNroCert),nTamCpoCert)
				SX5->X5_DESCSPA := StrZero(Val(cNroCert),nTamCpoCert)
				SX5->X5_DESCENG := StrZero(Val(cNroCert),nTamCpoCert)
				MsUnLock()
			EndIf
		EndIf
ENDCASE

AAdd(aCerts,{cChave,cNroCert})

Return cNroCert

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณF850ZeraRetบAutor  ณBruno Sobieski      บ Data ณ  07/29/01 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณZera os valores de retencoes cuando ้ mudado algum dado que บฑฑ
ฑฑบ          ณdetermina que as retencoes devem ser recalculadas           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850 (Argentina)                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850ZeraRet(nRetIva,nRetGan,nRetIB,nRetIric,nRetSUS,nRetSLI,nRetIr,nRetIRC,nRetISI,nRetIR4)

nRetIva		:=	0
nRetIB		:=	0
nRetGan		:=	0
nRetIric    :=  0
nRetIrc    	:=  0
nRetIr    	:=  0
nRetSUSS    :=  0
nRetSLI 	:=  0
nValLiq		:=	nValBrut - nValDesc
lRetenc		:= .F.
Return()

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Static Function EdMoeda()

oBMoeda:ColPos := 1
lEditCell(@aLinMoed,oBMoeda,PesqPict("SM2","M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)),9),2)
aLinMoed[oBMoeda:nAT][2] := obMoeda:Aarray[oBMoeda:nAT][2]

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850MRKB บAutor  ณSergio S. Fuzinaka  บFecha ณ  20/01/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacion de proveedores Observados por DGI - MarkBrowse   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFINF850()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850MRKB(lAll)

Local aArea     	:= GetArea()
Local lRet      	:= .T.
Local lExistCpo 	:= cPaisLoc == "ARG"

// Executa PE para validacao da MarkBrowse...
If ExistBlock("A085MRKB")
	lRet := ExecBLock("A085MRKB",.F.,.F.,lAll)
Endif
If lExistCpo
	If lRet
		dbSelectArea( "SA2" )
		dbSetOrder ( 1 )
		If !Empty(xFilial("SA2")) .And. lMsFil .And. xFilial("SF1") == xFilial("SA2")
			MsSeek( (cAliasTmp)->E2_MSFIL + (cAliasTmp)->E2_FORNECE + (cAliasTmp)->E2_LOJA, .F. )
		Else
			MsSeek( xFilial( "SA2" ) + (cAliasTmp)->E2_FORNECE + (cAliasTmp)->E2_LOJA, .F. )
		Endif
		If !SA2->( Found() )
			MsgStop( OemToAnsi(STR0146) )
			lRet := .F.
		Else
			If SA2->A2_PORIVA < 100.00 .And. (Empty(SA2->A2_IVPCCOB) .Or. Dtos(SA2->A2_IVPCCOB) < Dtos(dDataBase))
				MsgAlert( OemToAnsi(STR0155) + CRLF + CRLF + ; //"La fecha de validad para la reducci๓n del porcentaje de la retenci๓n del IVA del proveedor ya se ha vencido. "
				OemToAnsi(STR0147) )
				lRet := .F.
			EndIf

			If lRet .And. !Empty(SA2->A2_IVRVCOB) .And. SA2->A2_IVRVCOB < dDataBase
				MsgAlert( OemToAnsi(STR0146) + CRLF + CRLF + ;
				OemToAnsi(STR0147) )
				lRet := .F.
			EndIf
		EndIf
	Endif

Endif

If lRet .and. !lAll
	If !Empty(xFilial("SA2")) .And. lMsFil .And. xFilial("SF1") == xFilial("SA2")
		lRet := MsSeek( (cAliasTmp)->E2_MSFIL + (cAliasTmp)->E2_FORNECE + (cAliasTmp)->E2_LOJA, .F. )
	Else
		lret:=ExistCpo("SA2",(cAliasTmp)->E2_FORNECE + (cAliasTmp)->E2_LOJA)
	Endif
ElseIf lRet
	lRet:= Iif(SA2->A2_MSBLQL == "1",.F.,.T.)
EndIf

If lRet .And. cPaisloc = "ARG"
	If VldFchCBU()
		lRet := VldPagCBU(1)
		If lRet
			aAdd(aPagConCBU, {(cAliasTmp)->E2_NUM, (cAliasTmp)->E2_PREFIXO, (cAliasTmp)->E2_FORNECE, (cAliasTmp)->E2_LOJA, (cAliasTmp)->E2_RECNO})
		EndIf
	Else
		lRet := VldPagCBU(2)
		If lRet
			aAdd(aPagSinCBU, {(cAliasTmp)->E2_NUM, (cAliasTmp)->E2_PREFIXO, (cAliasTmp)->E2_FORNECE, (cAliasTmp)->E2_LOJA, (cAliasTmp)->E2_RECNO})
		EndIf
	EndIf
EndIf


RestArea( aArea )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VFOR บAutor  ณSergio S. Fuzinaka  บFecha ณ  20/01/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacion de proveedores Observados por DGI - MsGet        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFINF850()                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850VFOR(cFornece,cLoja)

Local aArea     := GetArea()
Local lRet      := .T.
Local lExistCpo := cPaisLoc == "ARG"

// Executa PE validacao do MsGet
If ExistBlock("A085VFOR")
	lRet := ExecBlock("A085VFOR",.F.,.F.,{cFornece,cLoja})
Endif

If lExistCpo

	If lRet
		dbSelectArea( "SA2" )
		dbSetOrder ( 1 )
		MsSeek( xFilial( "SA2" ) + cFornece + cLoja, .F. )
		If !SA2->( Found() )
			MsgStop( OemToAnsi(STR0147) )
			lRet := .F.
		Else
			If SA2->A2_PORIVA < 100.00 .And. (Empty(SA2->A2_IVPCCOB) .Or. Dtos(SA2->A2_IVPCCOB) < Dtos(dDataBase))
				MsgAlert( OemToAnsi(STR0155) + CRLF + CRLF + ; //"La fecha de validad para la reducci๓n del porcentaje de la retenci๓n del IVA del proveedor ya se ha vencido. "
				OemToAnsi(STR0147) )
				lRet := .F.
			EndIf

			If lRet .And. !Empty(SA2->A2_IVRVCOB) .And. SA2->A2_IVRVCOB < dDataBase
				MsgAlert( OemToAnsi(STR0146) + CRLF + CRLF + ;
				OemToAnsi(STR0147) )
				lRet := .F.
			EndIf
		EndIf
	Endif

Endif

RestArea( aArea )

Return( lRet )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850AcRe2บAutor  ณMicrosiga           บ Data ณ  10/17/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAcumula os valores base de calculo de retencao por Conceito.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850AcRe2(aConGanOri,nSigno,nSaldo,aRateioGan,lPa,lMonotrb)
Local nRateio
Local nRatValImp
Local nValMerc
Local nTotOrden
Local nPosGan,cConc
Local nX,nY,nMoeda   := 1
Local aConGan	:=	{}
Local aConGanRat	:=	{}
Local lCalcGan := .T.
Local nVlrTotal:=0
Local nI:=1
Local aImpInf := {}
Local lTESNoExen := .F.
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')
Local nTamItm	:= TAMSX3("FF_ITEM")[1]
Local nRecPA := 0
Local nPosIVC := 0
Local nAliqIVC := 1
Local aTesNf  := {}
Local nPosTes := 0
DEFAULT nSigno	:=	-1
DEFAULT lPA		:=	.F.
DEFAULT lMonotrb := .F.

If lRetPA == Nil
	lRetPA := (GetNewPar("MV_RETPA","N") == "S")
EndIf

//If SE2->E2_TIPO <> MVPAGANT
	//As retencoes sao calculadas com a taxa do dํa e nao com a taxa variavel....
	//Bruno.

	//+----------------------------------------------------------------+
	//ฐ Obter o Valor do Imposto e Base baseando se no rateio do valor ฐ
	//ฐ do titulo pelo total da Nota Fiscal.                           ฐ
	//+----------------------------------------------------------------+
	If ExistBlock("F0851IMP")
		lCalcGan:=ExecBlock("F0851IMP",.F.,.F.,{"GN2"})
	EndIf

If lCalcGan
	If SE2->E2_TIPO $ MVPAGANT .And. lRetPA
		nRatPa	:=	(nSaldo/SE2->E2_VALOR)
		//Procurar no SFE qual foi a base utilizada para calculo da retencao
		DbSelectArea("SFE")
		DbSetOrder(2)
		If MsSeek(xFilial("SFE")+ Substr(SE2->E2_NUM,1,Len(SFE->FE_ORDPAGO))+"G")
			While ! SFE->(EOF()) .And. (xFilial("SFE")+ Substr(SE2->E2_NUM,1,Len(SFE->FE_ORDPAGO))+"G") == (FE_FILIAL + FE_ORDPAGO + FE_TIPO)
				If !Empty(SFE->FE_ESPECIE) 
					nRecPA := SFE->(Recno())
					Exit
				EndIf
				SFE->(dbSkip())
			Enddo
		Endif
		
		If nRecPA > 0
			SFE->(dbGoTo(nRecPA))
			For nY := 1 To Len(aRateioGan)
				nPosGan:=ASCAN(aConGanRat,{|x| x[1]==aRateioGan[nY][5] .And. x[3]==''.And. x[4] == aRateioGan[nY][2]+aRateioGan[nY][3] .And. If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"),x[5] == aRateioGan[nY][2]+aRateioGan[nY][6],.T.)})
				If nPosGan<>0
					aConGanRat[nPosGan][2]+= SFE->FE_VALBASE *nRatPA * aRateioGan[nY][4]  * nSigno
				Else
					Aadd(aConGanRat,{aRateioGan[nY][5],SFE->FE_VALBASE * nRatPA * aRateioGan[nY][4]* nSigno,'',aRateioGan[nY][2]+aRateioGan[nY][3]})
				Endif
			Next
		Else
			SFE->(dbGoTop())
			If MsSeek(xFilial("SFE")+ Substr(SE2->E2_NUM,1,Len(SFE->FE_ORDPAGO))+"G")
				For nY := 1 To Len(aRateioGan)
					nPosGan:=ASCAN(aConGanRat,{|x| x[1]==aRateioGan[nY][5] .And. x[3]==''.And. x[4] == aRateioGan[nY][2]+aRateioGan[nY][3] .And. If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"),x[5] == aRateioGan[nY][2]+aRateioGan[nY][6],.T.)})
					If nPosGan<>0
						aConGanRat[nPosGan][2]+= SFE->FE_VALBASE *nRatPA * aRateioGan[nY][4]  * nSigno
					Else
						Aadd(aConGanRat,{aRateioGan[nY][5],SFE->FE_VALBASE * nRatPA * aRateioGan[nY][4]* nSigno,'',aRateioGan[nY][2]+aRateioGan[nY][3]})
					Endif
				Next
			Endif
		EndIf
	Else
	If !lPa
		dbSelectArea("SF2")
		dbSetOrder(1)
		If lMsFil
			nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
			SF2->(dbGoTo(nRecSF2))
		Else
			nRecSF2 := FINBuscaNF(xFilial("SF2", SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
			SF2->(dbGoTo(nRecSF2))
		EndIf
		While Alltrim(SF2->F2_ESPECIE)<>Alltrim(SE2->E2_TIPO).And.!Eof()
			SF2->(DbSkip())
			Loop
		Enddo
	Endif

	If !lPa .And. Alltrim(SF2->F2_ESPECIE)==Alltrim(SE2->E2_TIPO).And.;
		Iif(lMsfil,SF2->F2_MSFIL,xFilial("SF2", SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA==;
		F2_FILIAL+F2_DOC+PadR(F2_SERIE,nTamSer)+F2_CLIENTE+F2_LOJA

		nMoeda      := Max(SF2->F2_MOEDA,1)

		If cPaisLoc<>"ARG"
			nRateio := 1
		else
			nRateio     := SF2->F2_VALMERC / SF2->F2_VALBRUT
		Endif

		nRatValImp	:= ( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) / Round(xMoeda(SF2->F2_VALBRUT,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) )
		nValMerc 	:= ( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) * nRateio )
		If SF2->F2_FRETE > 0
			MV_FRETLOC := GetNewPar("MV_FRETLOC","IVA162GAN06")
			cConc   := Alltrim(Subs( MV_FRETLOC, At("N",MV_FRETLOC)+1))
			nPosGan := ASCAN(aConGan,{|x| x[1]==cConc.And.x[3]==''})
			If nPosGan<>0
				aConGan[nPosGan][2]:=aConGan[nPosGan][2]+((Round(xMoeda(SF2->F2_FRETE,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))*nRatValimp) * nSigno)
			Else
				Aadd(aConGan,{cConc,(Round(xMoeda(SF2->F2_FRETE,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))*nRatValimp)*nSigno,''})
			Endif
		EndIf
		If SF2->F2_DESPESA >  0
			MV_GASTLOC  := GetNewPar("MV_GASTLOC","IVA112GAN06")
			cConc   := Alltrim(Subs( MV_GASTLOC, At("N",MV_GASTLOC)+1))
			nPosGan := ASCAN(aConGan,{|x| x[1]==cConc.And.x[3]==''})
			If nPosGan<>0
				aConGan[nPosGan][2]:=aConGan[nPosGan][2]+(Round(xMoeda(SF2->F2_DESPESA,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))*nRatValimp)*nSigno
			Else
				Aadd(aConGan,{cConc,(Round(xMoeda(SF2->F2_DESPESA,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))*nRatValimp) * nSigno,''})
			Endif
		EndIf

		SD2->(DbSetOrder(3))
		If lMsfil
			SD2->(MsSeek(SF2->F2_MSFIL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		Else
			SD2->(MsSeek(xFilial("SD2",SE2->E2_FILORIG)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		EndIf
		If SD2->(Found())
			Do while Iif(lMsFil,SD2->D2_MSFIL,xFilial("SD2",SE2->E2_FILORIG))==SD2->D2_FILIAL.And.SF2->F2_DOC==SD2->D2_DOC.AND.;
				SF2->F2_SERIE==SD2->D2_SERIE.AND.SF2->F2_CLIENTE==SD2->D2_CLIENTE;
				.AND.SF2->F2_LOJA==SD2->D2_LOJA.And.!SD2->(EOF())

				IF AllTrim(SD2->D2_ESPECIE)<>AllTrim(SE2->E2_TIPO)
					SD2->(DbSkip())
					Loop
				Endif
					If Len(aTesNf) > 0
						nPosTes := aScan(aTesNf,{|x| x[1] == SD2->D2_TES})
					EndIf
					If nPosTes == 0
						aImpInf := TesImpInf(SD2->D2_TES)
						aAdd(aTesNf, {SD2->D2_TES, aImpInf})
					Else
						aImpInf := aClone(aTesNf[nPosTes][2])
					EndIf
					lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
					If !lTESNoExen
						SD2->(DbSkip())
						Loop
					Else
						nPosIVC := aScan(aImpInf,{|x| "IVC" $ AllTrim(x[1])})
						nAliqIVC := 1
						If nPosIVC > 0
							nAliqIVC := 1 + (aImpInf[nPosIVC][9]/100)
						EndIf
					EndIf
					SFF->(DbSetOrder(2))
					If SFF->(MsSeek(xfilial("SFF")+Pad(SF2->F2_SERIE,nTamItm)) )  .and. Round(xMoeda(SF2->F2_VALMERC,SF2->F2_MOEDA,1,,,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) > SFF->FF_FXDE
						nVlrTotal:= 0
						If cPaisLoc == "ARG"
							For nI := 1 To Len(aImpInf)
					  			If(Trim(aImpInf[nI][01])$ SFF->FF_INCIMP)
									If aImpInf[nI][03] <> "3"

										nVlrTotal+=SD2->(FieldGet(ColumnPos(aImpInf[nI][02])))
									EndIf
								EndIf
							Next nI
                        EndIf
			  		 	nPosGan:=ASCAN(aConGan,{|x| x[1]==Pad(SF2->F2_SERIE,nTamItm)} ) 
						If nPosGan<>0
							aConGan[nPosGan][2]:=aConGan[nPosGan][2]+((Round(xMoeda((SD2->D2_TOTAL+nVlrTotal),SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp)* nSigno)
						Else
							Aadd(aConGan,{Pad(SF2->F2_SERIE,nTamItm),Round(xMoeda((SD2->D2_TOTAL+nVlrTotal),SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp* nSigno,''})
						Endif
					Else
					SB1->(DbSetOrder(1))
					SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD2->D2_MSFIL,xFilial("SB1")) + SD2->D2_COD))
					If SB1->(Found()) .And. ((!lMonotrb .And. !Empty(SB1->B1_CONCGAN)) .Or. (cPaisLoc == "ARG" .And. !Empty(SB1->B1_CMONGAN) .And. lMonotrb))
						cConc2	:=	''
						If cPaisLoc == "ARG" .AND.SB1->B1_CONCGAN=='02'
			              	cConc2	:=	SB1->B1_CONCGAN
						Endif

						aAreaAtu:=GetArea()
						aAreaSFF:=SFF->(GetArea())
						dbSelectArea("SFF")
						dbSetOrder(2)
						If MsSeek(xFilial("SFF")+Iif(lMonotrb .And. cPaisLoc == "ARG" ,SB1->B1_CMONGAN,SB1->B1_CONCGAN)+'GAN')
							nVlrTotal:= 0
							If cPaisLoc == "ARG"
								For nI := 1 To Len(aImpInf)
			  						If(Trim(aImpInf[nI][01])$ SFF->FF_INCIMP)
										If aImpInf[nI][03] <> "3"
									   		nVlrTotal+=SD2->(FieldGet(ColumnPos(aImpInf[nI][02])))
										EndIf
									EndIf
								Next nI
						   EndIf
						Endif

						RestArea(aAreaAtu)
						SFF->(RestArea(aAreaSFF))

						nPosGan:=ASCAN(aConGan,{|x| x[1]==SB1->B1_CONCGAN .And. x[3]==cConc2})

						If nPosGan<>0
							aConGan[nPosGan][2]:=aConGan[nPosGan][2]+((Round(xMoeda(SD2->D2_TOTAL/nAliqIVC,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp) * nSigno)
						Else
							Aadd(aConGan,{Iif(lMonotrb .And. cPaisLoc == "ARG" ,SB1->B1_CMONGAN,SB1->B1_CONCGAN),(Round(xMoeda(SD2->D2_TOTAL/nAliqIVC,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) * nRatValImp ) * nSigno,cConc2})
						Endif
					Else

							For nY := 1 To Len(aRateioGan)
								nPosGan:=ASCAN(aConGanRat,{|x| x[1]==aRateioGan[nY][5] .And. x[3]=='' .And. x[4] == aRateioGan[nY][2]+aRateioGan[nY][3] .And. If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"),x[5] == aRateioGan[nY][2]+aRateioGan[nY][6],.T.)})
								If nPosGan<>0
									aConGanRat[nPosGan][2] += (Round(xMoeda((SD2->D2_TOTAL + nVlrTotal), SF2->F2_MOEDA, 1, , 5, aTxMoedas[Max(SF2->F2_MOEDA, 1)][2]), MsDecimais(1)) * nRatValImp) * aRateioGan[nY][4] * nSigno
								Else
									If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
										Aadd(aConGanRat,{aRateioGan[nY][5],(Round(xMoeda((SD2->D2_TOTAL + nVlrTotal)/nAliqIVC, SF2->F2_MOEDA, 1, , 5, aTxMoedas[Max(SF2->F2_MOEDA, 1)][2]), MsDecimais(1)) 	* nRatValImp) * aRateioGan[nY][4] * nSigno, '', aRateioGan[nY][2] + aRateioGan[nY][3], aRateioGan[nY,6]})
								    Else
										Aadd(aConGanRat,{aRateioGan[nY][5],(Round(xMoeda((SD2->D2_TOTAL + nVlrTotal)/nAliqIVC, SF2->F2_MOEDA, 1, , 5, aTxMoedas[Max(SF2->F2_MOEDA, 1)][2]), MsDecimais(1)) 	* nRatValImp) * aRateioGan[nY][4] * nSigno, '', aRateioGan[nY][2] + aRateioGan[nY][3]})
									Endif
								Endif
							Next
						Endif
					EndIf
					SD2->(DbSkip())
				Enddo
			Else
				For nY := 1 To Len(aRateioGan)
					nPosGan:=ASCAN(aConGanRat,{|x| x[1]==aRateioGan[nY][5] .And. x[3]==''.And. x[4] == aRateioGan[nY][2]+aRateioGan[nY][3] .And. If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"),x[5] == aRateioGan[nY][2]+aRateioGan[nY][6],.T.)})
					If nPosGan<>0
						aConGanRat[nPosGan][2]+= nValMerc * aRateioGan[nY][4]  * nSigno
					Else
						If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
							Aadd(aConGanRat,{aRateioGan[nY][5],(nValMerc+nVlrTotal)*aRateioGan[nY][4]* nSigno,'',aRateioGan[nY][2]+aRateioGan[nY][3],aRateioGan[nY][6]})
						Else
							Aadd(aConGanRat,{aRateioGan[nY][5],(nValMerc+nVlrTotal)*aRateioGan[nY][4]* nSigno,'',aRateioGan[nY][2]+aRateioGan[nY][3]})
						Endif
					Endif
				Next
			Endif
		Else
			If lPa
				nValMerc	 := nSaldo
			Else
				nValMerc	 := Iif( lRetPA,Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)),0)
			Endif
			For nY := 1 To Len(aRateioGan)

				aAreaAtu:=GetArea()
				aAreaSFF:=SFF->(GetArea())
				dbSelectArea("SFF")
				dbSetOrder(2)
				If MsSeek(xFilial("SFF")+aRateioGan[nY][5]+'GAN')
					nVlrTotal:= 0
					nVlrTotIt:=0
					If cPaisLoc == "ARG"
						For nI := 1 To Len(aImpInf)
							If(Trim(aImpInf[nI][01])$ SFF->FF_INCIMP)
									If aImpInf[nI][03] <> "3"
								   		nVlrTotal+=SD2->(FieldGet(ColumnPos(aImpInf[nI][02])))
									EndIf
							EndIf
						Next nI
			   		EndIf
				Endif

			RestArea(aAreaAtu)
			SFF->(RestArea(aAreaSFF))

				nPosGan:=ASCAN(aConGanRat,{|x| x[1]==aRateioGan[nY][5] .And. x[3]==''.And. x[4] == aRateioGan[nY][2]+aRateioGan[nY][3] .And. If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2"),x[5] == aRateioGan[nY][2]+aRateioGan[nY][6],.T.)})
				If nPosGan<>0
					aConGanRat[nPosGan][2]+= (nValMerc+nVlrTotal) * aRateioGan[nY][4]  * nSigno
				Else
					If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
						Aadd(aConGanRat,{aRateioGan[nY][5],(nValMerc+nVlrTotal)*aRateioGan[nY][4]* nSigno,'',aRateioGan[nY][2]+aRateioGan[nY][3],aRateioGan[nY][6]})
					Else
						Aadd(aConGanRat,{aRateioGan[nY][5],(nValMerc+nVlrTotal)*aRateioGan[nY][4]* nSigno,'',aRateioGan[nY][2]+aRateioGan[nY][3]})
					Endif
				Endif
			Next
		EndIf
	Endif
	//Faz o rateio dos condominos
	For nY	:=	1	To Len(aConGan)
		For nX:= 1 To Len(aRateioGan)
			If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
				AAdd(aConGanRat,{aConGan[nY][1],aConGan[nY][2]*aRateioGan[nX][4],aConGan[nY][3],aRateioGan[nX][2]+aRateioGan[nX][3],aRateioGan[nY][6]})
			Else
				AAdd(aConGanRat,{aConGan[nY][1],aConGan[nY][2]*aRateioGan[nX][4],aConGan[nY][3],aRateioGan[nX][2]+aRateioGan[nX][3] })
			Endif
		Next
	Next

	//Distribue os acumulados ja rateados no array de acumulados total
	For nY := 1 TO Len(aConGanRat)
		nPosGan   := ASCAN(aConGanOri,{|x|  x[1]+x[3]+x[4] == aConGanRat[nY][1]+aConGanRat[nY][3]+aConGanRat[nY][4] })
		If nPosGan<>0
			aConGanOri[nPosGan][2]	+= aConGanRat[nY][2]
		Else
			Aadd(aConGanOri,aClone(aConGanRat[nY]))
		Endif
	Next
EndIf
Return



/*
ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
ฐฐ+-----------------------------------------------------------------------+ฐฐ
ฐฐ|Fun็เo    | MArray     | Autor | Julio Cesar         | Data | 03.09.03 |ฐฐ
ฐฐ+----------+-------------------------------------------------------------ฐฐ
ฐฐ|Descricao | Monta o array com os registros utilizados na Ordem de Pago |ฐฐ
ฐฐ+----------+------------------------------------------------------------|ฐฐ
ฐฐ|Uso       | FINF850                                                   |ฐฐ
ฐฐ+-----------------------------------------------------------------------+ฐฐ
ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
*/
Static Function MArray(nI,cFilSE2,nCondAgr,aOrdPg)

Local nX := 0

Do Case
	Case nCondAgr <= 1 //Filial + Fornecedor + Loja
		nX := aScan(aOrdPg,{|x| x[1] == cFilSE2 .And. x[2] == aRecNoSE2[nI][2] .And. x[3] == aRecNoSE2[nI][3]})
	Case nCondAgr == 2 //Filial + Fornecedor
		nX := aScan(aOrdPg,{|x| x[1] == cFilSE2 .And. x[2] == aRecNoSE2[nI][2]})
	OtherWise //Filial
		nX := aScan(aOrdPg,{|x| x[1] == cFilSE2})
EndCase

If nX == 0
	Do Case
		Case nCondAgr <= 1 //Filial + Fornecedor + Loja
			AAdd(aOrdPg,{aRecNoSE2[nI][1],aRecNoSE2[nI][2],aRecNoSE2[nI][3],{aRecNoSE2[nI][8]},,aRecNoSE2[nI][16]})
		Case nCondAgr == 2 //Filial + Fornecedor
			AAdd(aOrdPg,{aRecNoSE2[nI][1],aRecNoSE2[nI][2],"",{aRecNoSE2[nI][8]},,aRecNoSE2[nI][16]})
		OtherWise //Filial
			AAdd(aOrdPg,{aRecNoSE2[nI][1],"","",{aRecNoSE2[nI][8]},,aRecNoSE2[nI][16]})
	EndCase
Else
	AAdd(aOrdPg[nX][4],aRecNoSE2[nI][8])
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณF850GrvTx  บAutor  ณCristiano Denardi   บ Data ณ22.01.2004 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณGrava taxa da Moeda em SEK para qdo existirem campos        บฑฑ
ฑฑบDesc.     ณcorrespondentes ( da moeda 2 ate n informada)               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850GrvTx()

Local nTx := 0

For nTx := 2 To Len(aTxMoedas)
	If ( SEK->(ColumnPos("EK_TXMOE"+StrZero(nTx,2))) > 0 )
		SEK->&("EK_TXMOE"+StrZero(nTx,2)) := aTxMoedas[nTx][2]
	Endif
Next nTx

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณF850Pesq   บAutor  ณPaulo Augusto       บ Data ณ20.02.2004 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa a tea de Fornecedor que e acionada via F4          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบVariaveis ณlIndice: Se muda o Indice                                   บฑฑ
ฑฑบ          ณcPesq: Chave de Pesquisa ou indice selecionado              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850Pesq(lIndice,cPesq)
Local nRec:=Sa2->(Recno())
If lIndice
	SA2->(DbSetOrder(cPesq))
Else
	If !(SA2->(MsSeek(xFilial("SA2")+Alltrim(cPesq ))))
		SA2->(DbGoto(nRec))
	EndIf
EndIf
oBrwForn:Refresh()

Return

Function RateioCond(aRateio)

Local cCodCond	:=	''
Local lRet		:=	.T.
Local nTotRat	:=	0
Local nX			:=	0
Local cConcGan	:=	Iif(SA2->A2_TIPO == "M" .And. cPaisLoc == "ARG" ,SA2->A2_CMONGAN,SA2->A2_AGREGAN)
Local cFornece	:=	SA2->A2_COD
Local cLoja		:=	SA2->A2_LOJA
Local cFilFor	:= SA2->A2_FILIAl
Local lCalcRetTo := .F.
aRatCond:={}
aRateio	:=	{}
lCalcRetTo:= If (SA2->(ColumnPos("A2_CALRETT")) > 0,Iif(!Empty(SA2->A2_CALRETT),SA2->A2_CALRETT,.F.),lCalcRetTo)

If cPaisLoc == "ARG" .And.SA2->A2_CONDO == "1"
	cCodCond := SA2->A2_CODCOND
	DbSelectArea("SA2")
	DbSetOrder(1)
	MsSeek(xFilial("SA2")+cCodCond)
	//*FAZ RATEIO ENTRE OS CONDOMINOS*//
	While !EOF() .And. xFilial("SA2") == SA2->A2_FILIAL .And. Substr(SA2->A2_COD,1,Len(cCodCond)) == cCodCond
		If cCodCond == SA2->A2_CODCOND .and. SA2->A2_CONDO =="2"//*SE CONDOMINO*//
			AAdd(aRateio,{A2_CONDO,A2_COD,A2_LOJA,A2_PERCCON/100,Iif(A2_TIPO == "M" .And. cPaisLoc == "ARG" ,A2_CMONGAN,A2_AGREGAN) })
			If lCalcRetTo
				AAdd(aRatCond,{A2_CONDO,A2_COD,A2_LOJA,A2_PERCCON/100,Iif(A2_TIPO == "M" .And. cPaisLoc == "ARG" ,A2_CMONGAN,A2_AGREGAN) })
			EndIf
		Endif
		DbSkip()
	Enddo
	If Len(aRateio)==0//*CASO NAO SEJAM ACHADOS CONDOMINOS*//
		AAdd(aRateio,{'',cFornece,cLoja,1,cConcGan,cFilFor})
	Endif
Else
	AAdd(aRateio,{'',cFornece,cLoja,1,cConcGan,cFilFor})
Endif

For nX:= 1 To Len(aRateio)
	nTotRat	+=	aRateio[nX][4]
Next
If Round(nTotRat,0) <> 1
	Help(" ",1,"F850COND")
	lRet	:=	.F.
Endif
If lCalcRetTo
	aRateio:={}
	AAdd(aRateio,{'',cFornece,cLoja,1,cConcGan,cFilFor})
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINF850  บAutor  ณMicrosiga           บFecha ณ  12-16-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850When()
Local lRet := .T.
If Substr(ReadVar(),4,9) == "EK_DEBITO"
	lRet	:=	(aCols[n][1]=="1").And.(aCols[n][7] <= dDataBase .And. !Empty(aCols[n][7]))
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINF850  บAutor  ณBruno Sobieski      บFecha ณ  12-16-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a moeda do pagamento                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetMoedPag(aPgtos)
Local aMoedas	:=	{}
Local nK	:=	0
//Local nPosMoeda	:=	Iif(nPosMoeda == Nil, Ascan(oGetDad1:aHeader,{ |x| Alltrim(x[2])=="EK_MOEDA"}), nPosMoeda)

If aPgtos == Nil   // default, sem pago diferenciado
	SA6->(MsSeek(xFilial()+cBanco+cAgencia+cConta))
	aMoedas	:=	{Max(Iif( SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA),1)}
Else
	If aPgtos[1]	<> 4
		SA6->(MsSeek(xFilial()+aPgtos[2]+aPgtos[3]+aPgtos[4]))
		aMoedas	:=	{Max(Iif(SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA),1)}
	Else
		For nk := 1 to Len(aPgtos[2])
			If Ascan(aMoedas,aPgtos[2][nK][nPosMPgto])==0
				AAdd(aMoedas,aPgtos[2][nK][nPosMPgto])
			Endif
		Next
	EndIf
EndIf
Return(AClone(aMoedas))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณF850SaldVl บAutor  ณPaulo Augusto       บ Data ณ  28/02/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao da digitacao do valor informado                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850SaldVl(aSe2)
Local aRateioGan	:= {}
Local nP			:= 0
Local lRet			:= .T.

If nVlrPagar < aPagos[oLbx:nAt,H_TOTALVL]
	Aviso(STR0163,STR0166 + STR0167 + STR0168,{"OK"} ) //"Valor"###"Este campo so devera ser"###"informado quando o valor "###"a pagar for maior que o total"
	nVlrPagar := aPagos[oLbx:nAt,H_TOTALVL]
	oVlrPagar:Refresh()
	lRet := .F.
Else
	aVlPA[_PA_VLATU] := nVlrPagar
	If aVlPA[_PA_VLANT] <> aVlPA[_PA_VLATU] .Or. aVlPA[_PA_MOEANT] <> aVlPA[_PA_MOEATU]
		If aVlPA[_PA_MOEANT]>0
			F850Saldos(aVlPA[_PA_VLANT],	aVlPA[_PA_MOEANT], -1)
		EndIf
		If aVlPA[_PA_MOEATU] > 0
			F850Saldos(aVlPA[_PA_VLATU],	aVlPA[_PA_MOEATU],  1)
	    EndIf
		For nP	:=	1	To	Len(aSE2[oLbx:nAt][2])
			F850Saldos(aSE2[oLbx:nAt][2][nP][5],1, 1)
		Next nP
		cFornece :=	aPagos[oLbx:nAt][H_FORNECE]
		cLoja    := aPagos[oLbx:nAt][H_LOJA]

		SA2->( dbSetOrder(1) )
		SA2->( MsSeek(xFilial("SA2")+cFornece+cLoja) )
		If !RateioCond(@aRateioGan)
			aSE2	:=	{}
		Endif

		nValorPA1	:=	Round(xMoeda(aVlPA[_PA_VLATU],aVlPA[_PA_MOEATU],1,,5,aTxMoedas[aVlPA[_PA_MOEATU]][2]),MsDecimais(1))

		F850Recal(@aSE2,aRateioGan)
		For nP	:=	1	To	Len(aSE2[oLbx:nAt][2])
			F850Saldos(aSE2[oLbx:nAt][2][nP][5],1, -1)
		Next nP

		aVlPA[_PA_MOEANT]	:=	aVlPA[_PA_MOEATU]
		aVlPA[_PA_VLANT]	:=	aVlPA[_PA_VLATU]
	EndIf
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850DelLn บAutor  ณMicrosiga           บFecha ณ  09/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850DelLn(n1,n2,n3,n4)
Local nPosVlr	:=	Ascan(aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})

nDel := nDel +1

nPosMoeda	:=	Ascan(aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})

If(nDel%2)==0
	Return()
EndIf

If aCols[n][Len(aCols[n])]
	F850Saldos(aCols[n][nPosVlr],	Val(aCols[n][nPosMoeda]), -1)
Else
	F850Saldos(aCols[n][nPosVlr],	Val(aCols[n][nPosMoeda]), 1)
Endif

If Type("oSaldo")<> "U" .And. oSaldo <> Nil
	oSaldo:Refresh()
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณF850SalPa บAutor  ณPaulo Augusto       บ Data ณ  04/03/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณLinha OK   da digitacao dos titulos usados para pagar       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850SalPa(oSaldo,lPa)
Local nPosMoe		:=	Ascan(aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
Local nPosValor 	:=	Ascan(aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})
Local nX
Local aSldTmp	:=	aClone(aSaldos)
lPa	:=	Iif(lPA=Nil,.F.,lPA)
If lRetPA == Nil
	lRetPA := (GetNewPar("MV_RETPA","N") == "S")
EndIf
If lPa
	aFill(aSldTmp,0)
Endif
For nX	:=	1	To	Len(aCols)
	If Val(aCols[nX][nPosMoe])	>	0 .And. !aCols[nX][Len(aCols[nX])]
		aSldTmp[Val(aCols[nX][nPosMoe])]	+=	aCols[nX][nPosValor] * Iif(lPa,1,-1)
	Endif
Next
aSaldos[Len(aSaldos)]	:=	0
For nX	:=	1	To	Len(aTxMoedas)
	If lPa .And. !lRetPa
		aSaldos[Len(aSaldos)]	+=	Round(xMoeda(aSldTmp[nX],nX,nMoedaCor,,5,aTxMoedas[nX][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Else
		aSaldos[Len(aSaldos)]	+=	Round(xMoeda(aSldTmp[nX],nX,nMoedaCor,,5,aTxMoedas[nX][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Endif
Next

// Arredonda o total em moeda corrente. (Apresentava msg de saldo insuficiente por problema de arredondamento.) // Guilherme
aSaldos[Len(aSaldos)] := Round(aSaldos[Len(aSaldos)],MsDecimais(nMoedaCor))
If lPa .And. !lRetPA
	nValor	:=	aSaldos[Len(aSaldos)]
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณF850CalRetบAutor  ณPaulo Augusto       บ Data ณ  04/04/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRecalculo das Retencoes para Sujeitos Multiplos             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850CalcRet(aRatCond,aRets)

Local aRetCond := {}
Local nI:=1
Local nValBase:= 0
Local nValImp := 0
Local nValRet := 0
Local nValDedu:= 0

For nI:= 1 to Len(aRatCond)

	nValBase:=aRets[1][2] * aRatCond[nI][4]
	nValImp :=aRets[1][4] * aRatCond[nI][4]
	nValRet :=aRets[1][5] * aRatCond[nI][4]
	nValDedu:=aRets[1][6] * aRatCond[nI][4]

	If aRatCond[nI][4] > 0
		Aadd(aRetCond,{"",nValBase,aRets[1][3],nValImp,nValRet,nValDedu,aRets[1][7],aRets[1][8],aRets[1][9],aRatCond[nI][2],aRatCond[nI][3]})
	EndIf

Next

Return(aRetCond)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850RatSussบAutor  ณPaulo Augusto     บFecha ณ  04/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rateio do SUSS Lei 1784                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850RatSuss(cFornece,cLoja)
Local aAreaSA2:= SA2->(GetArea())
Local aRateio:= {}
Local lLey1784 :=.F.

DbSelectArea("SA2")
DbSetOrder(1)
MsSeek(xFilial("SA2")+cFornece+cLoja)
If SA2->(ColumnPos("A2_PROVEMP")) > 0  .and. SA2->A2_PROVEMP == 1
	lLey1784 :=.T.
EndIf

If cPaisLoc == "ARG" .And.SA2->A2_CONDO == "1"
	cCodCond := SA2->A2_CODCOND
	DbSelectArea("SA2")
	DbSetOrder(1)
	MsSeek(xFilial("SA2")+cCodCond)
	//*FAZ RATEIO ENTRE OS CONDOMINOS*//
	While !EOF() .And. xFilial("SA2") == SA2->A2_FILIAL .And. cCodCond == SA2->A2_CODCOND
		If SA2->A2_CONDO =="2"//*SE CONDOMINO*//
		   AAdd(aRateio,{A2_COD,A2_LOJA,A2_PERCCON/100,lLey1784})
		Endif
		DbSkip()
	Enddo
Endif

If Len(aRateio)==0 /*CASO NAO SEJAM ACHADOS CONDOMINOS*/
	AAdd(aRateio,{cFornece,cLoja,1,lLey1784})
Endif

RestArea(aAreaSA2)

Return(aRateio)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VlM  บAutor  ณPaulo Augusto       บ Data ณ  14/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a digitacao do valor da moeda selecionada            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VlM()
Local nPosVl		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2]) == "NVLMDINF"})
Local nPosMoeda		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2]) == "E2_MOEDA"})
Local nPosPagar		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2]) == "E2_PAGAR"})
Local nPosValor		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(X[2]) == "E2_VALOR"})
Local nPosSaldo		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(X[2]) == "E2_SALDO"})
Local nPosMulta		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2]) == "E2_MULTA"})
Local nPosJuros		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2]) == "E2_JUROS"})
Local nPosDesco		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2]) == "E2_DESCONT"})
Local nPosVlParc	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2]) == "E2_VLBXPAR"})
Local nVlrParcial	:= 0
Local nValorSaldo	:= 0
Local nVlrInf		:= 0
Local nValorInf		:= 0
Local cVar			:= ""
Local lRet			:= .T.

cVar := ReadVar()
nVlrParcial	:= &(cVar)
Do Case
	Case cVar == "M->NVLMDINF"
		lBxParc := IIf( Type("lBxParc")=="U", Iif(cPaisLoc <> "BRA",.T.,.F.), lBxParc)
		If nPosSaldo > 0 .or. nPosVlParc >0
			nValorInf := Iif(aCols[n][nPosVl]>=0,Round(xMoeda(nVlrParcial,nMoedaCor,aCols[n][nPosMoeda],,5,aTxmoedas[nMoedaCor][2],aTxmoedas[aCols[n][nPosMoeda]][2]),MsDecimais(aCols[n][nPosMoeda])),0)
			nValorSaldo := Iif(aCols[n][nPosValor]>0,aCols[n][nPosValor],0) //+ aCols[n][nPosPagar]
		 	If lBxParc .And. nPosVlParc > 0
				nValorSaldo :=Iif(aCols[n][nPosVlParc] > 0,aCols[n][nPosVlParc],nValorSaldo)
			EndIf
			If	nValorInf  > (nValorSaldo + aCols[n][nPosJuros]+ aCols[n][nPosMulta]) - aCols[n][nPosDesco]
				MsgStop(OemToAnsi(STR0119)) //"El valor tipeado es MAYOR que el saldo"
				lRet:=.F.
			ElseIf nValorInf < 0
				MsgStop(OemToAnsi(STR0120)) //"El valor debe ser MAYOR o IGUAL a 0"
				lRet:=.F.
			EndIf
		Else
			MsgStop(OemToAnsi(STR0129)) //"Habilite el campo E2_SALDO via configurador"
			lRet:=.F.
		Endif
EndCase
If lRet
	oGetDad0:aCols[oGetDad0:nAt][nPosPagar] := Iif(oGetDad0:aCols[oGetDad0:nAt][nPosVl]>=0,Round(xMoeda(nVlrParcial,nMoedaCor,oGetDad0:aCols[oGetDad0:nAt][nPosMoeda],,5,aTxmoedas[nMoedaCor][2],aTxmoedas[oGetDad0:aCols[oGetDad0:nAt][nPosMoeda]][2]),MsDecimais(nMoedaCor)),0)
	oGetDad0:oBrowse:Refresh()
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VLM   บAutor  ณMicrosiga           บFecha ณ  08/25/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VlPg()
Local nPosVlPg	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "EK_VALOR"})
Local nPosPorPg	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "NPORVLRPG"})
Local nLenAcol	:= 0
Local nValorAux	:= 0
Local nValorVar	:= 0
Local nPorcPg	:= 0
Local nDif		:= 0
Local nDecs		:= 0
Local nPgto		:= 0
Local nPorc		:= 0
Local nTtlPg	:= 0
Local cVar		:= ""
Local lRet		:= .T.
Local nPorPorPg := 0 
Local nPgAux	:= 0
Local lReCal    := .T.

nPosTipo	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
nPosTpDoc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPODOC"})
nPosNum		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_NUM"})
nPosMoeda	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
nPosMPgto	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})
nPosBanco	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAge		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
nPosTalao	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})
nPosVlr		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})
nPosEmi		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
nPosVcto	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
nPosDeb		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_DEBITO"})
nPosParc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PARCELA"})

If  cPaisloc == "ARG"
	nPorPorPg   := Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "NPORVLRPG"})       
Endif

cVar := ReadVar()
nValorVar := &(cVar)
Do Case
	Case cVar == "M->NPORVLRPG"
	 If  cPaisloc == "ARG" .And. ( M->NPORVLRPG==oGetDad1:aCols[oGetDad1:nAt,nPosPorPg])
	  lReCal:= .F.	
	 EndIf
	 If lRecal
		If nValorVar == 0 .Or. nValorVar > 100
			lRet := .F.
		Else
			nPorc := 0
			nTtlPg := 0
    		nLenAcol := Len(oGetDad1:aCols)
		    For nPgto := 1 To nLenAcol
		    	If nPgto == oGetDad1:nAt
		    		nPorc += nValorVar
		    	Else
			    	nPorc += oGetDad1:aCols[nPgto,nPosPorPg]
			    	nTtlPg += oGetDad1:aCols[nPgto,nPosVlPg]
			    Endif
		    Next
		    
		    If nPorc > 100
		    	MsgAlert(STR0320,STR0223) //"O valor para pagamento ultrapassa 100%."
		    	lRet := .F.
		    Elseif Iif(cPaisloc !="ARG",.F.,nSaldoPgOP <=0 .And. (nValorVar > oGetDad1:aCols[oGetDad1:nAt,nPorPorPg] .And. oGetDad1:aCols[oGetDad1:nAt,nPorPorPg]!=0 ))    
			    MsgAlert(STR0320,STR0223) //"O valor para pagamento ultrapassa 100%."
			    lRet := .F.
		    Else
				nTotDocProp -= oGetDad1:aCols[oGetDad1:nAt,nPosVlPg]
				If Type("nVlrNeto") <> 'N'
					nVlrNeto:= nVlrPagar
				EndIf  

				nVlrPg := nVlrPagar - nTotDocTerc - (nVlrPagar - nVlrNeto) 		//valor a pagar descontando-se os documentos de terceiros
				nValorAux := Round(nVlrPg * (nValorVar / 100),MsDecimais(nMoedaCor))
				nTtlPg += nValorAux
				oGetDad1:aCols[oGetDad1:nAt,nPosVlPg] := nValorAux
				nTotDocProp += oGetDad1:aCols[oGetDad1:nAt,nPosVlPg]
				
			    //Ajusta os valores para prevenir diferencas geradas por arredondamento, quando atingir 100%
			    If nPorc == 100
			    	If cPaisLoc <> "ARG"
			    	  	F850AtuProp(.T.)
 				    Else
 				         If (nVlrPagar - (nTotDocTerc + nTotDocProp) -(nVlrPagar - nVlrNeto))<>0
	 				     	 If MsgYesNo(STR0444,STR0443)
		 				       F850AtuProp(.T.)
		 				     Else
		 				       F850AtuProp(.T.,0,.T.)
		 				     EndIf
	 				     EndIf
 				    EndIf
				Endif
				lVlrAlt := .T.

				nSaldoPgOP := nVlrPagar - (nTotDocTerc + nTotDocProp) -(nVlrPagar - nVlrNeto)
				oSaldoPgOP:Refresh()
				oTotDocProp:Refresh()
			Endif
		Endif
	 EndIf
	Case cVar == "M->EK_VALOR"
	 If  cPaisloc == "ARG" .And. ( M->EK_VALOR==oGetDad1:aCols[oGetDad1:nAt,nPosVlPg])
	  lReCal:= .F.	
	 EndIf
	 If lRecal
		If nValorVar == 0
			lRet := .F.
		Else
			nPorc := 0
			nTtlPg := 0
			nLenAcol := Len(oGetDad1:aCols)
			For nPgto := 1 To nLenAcol
				If nPgto == oGetDad1:nAt
					nTtlPg += nValorVar
				Else
					nPorc += oGetDad1:aCols[nPgto,nPosPorPg]
					nTtlPg += oGetDad1:aCols[nPgto,nPosVlPg]
				Endif
			Next
			If nTtlPg > (nVlrPagar - nTotDocTerc)
				lRet := .F.
				MsgAlert( STR0321 + ".",STR0223) // "O valor para pagamento ultrapassa o valor da OP"
			Else
				nTotDocProp -= oGetDad1:aCols[oGetDad1:nAt,nPosVlPg]
				if cPaisLoc == "ARG" .and. IsInCallStack("F850PgAdi") .and. nLiquido <> 0
					nPgAux := nLiquido // verifica se possui ou nใo reten็๕es
				Else
					nPgAux := nVlrPagar
				EndIF
				nPorcPg := Round((nValorVar / (nPgAux - nTotDocTerc) * 100),2)
				oGetDad1:aCols[oGetDad1:nAt,nPosPorPg] := nPorcPg
				nTotDocProp += nValorVar
			    /*_*/
				If Type("nVlrNeto") <> 'N'
					nVlrNeto:= nVlrPagar
				EndIf 
				lVlrAlt := .T. 
				
				IF cPaisLoc == "ARG" .and. IsInCallStack("F850PgAdi")
					F850AtuProp(.T.,0,.T.)
				Else
					nSaldoPgOP := nVlrPagar - (nTotDocTerc + nTotDocProp)-(nVlrPagar - nVlrNeto)
					oSaldoPgOP:Refresh()
					oTotDocProp:Refresh()
				EndIF
			Endif
		Endif
	 Endif	
EndCase
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva     ณ Data ณ21/11/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados         ณฑฑ
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
*/
Static Function MenuDef(nFlagMOD,nCtrlMOD)
Local lF850BT	:= ExistBlock("F085ABT")
Local aRotina	:= {}	
Local cAliVis:= alias() 

If Type("lShowPOrd") <> "L"
	lShowPOrd := .F.
Endif

aRotina	:= {	{ OemToAnsi(STR0007),'F850Busca()'																				,0,1},;	//"Buscar"
				{ OemToAnsi(STR0009),If(lShowPOrd,"F850POPVis()",'Eval({||SE2->(DBGOTO((cAliasTmp)->E2_RECNO)) , AxVisual("SE2", (cAliasTmp)->E2_RECNO,2)})'),0 ,2},;         //"Visualizar"
				{ OemToAnsi(STR0010),If(lShowPOrd,"F850POPSel(@nFlagMOD,@nCtrlMOD)",'F850PgAut(@nFlagMOD,@nCtrlMOD)')	,0,3},;	// Pago Automatico
				{ OemToAnsi(STR0136),'SelPago()',0 ,3 },;	// Generar PA
				{ OemToAnsi(STR0070),'Fa085SetMo()',0,1}}		// Modificar tasas
					//{ OemToAnsi(STR0136),'SelPago()'																				,0,3},;	// Generar PA

If ExistBlock("F850ADLE")
	Aadd(aRotina,{"Leyenda","PE850Leg",0,3,0 ,.F.})
EndIf

If lF850BT
	aRotina := Execblock ("F085ABT",.F.,.F.,aRotina)
EndIf
If lShowPOrd
	Aadd(aRotina,{"Legenda","F850POPLeg",0,3,0 ,.F.})
Endif
Return(aRotina)


/*
ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
ฐฐ+-----------------------------------------------------------------------+ฐฐ
ฐฐฐFun็เo    ฐ Despesas   ฐ Autor ฐ Bruno Sobieski      ฐ Data ฐ 18.05.08 ฐฐฐ
ฐฐ+----------+------------------------------------------------------------ฐฐฐ
ฐฐฐDescri็เo ฐ Manutencao de Despesas e Taxas       (Portugal)            ฐฐฐ
ฐฐ+----------+------------------------------------------------------------ฐฐฐ
ฐฐฐUso       ฐ PAGO007                                                    ฐฐฐ
ฐฐ+-----------------------------------------------------------------------+ฐฐ
ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
*/
Static Function F850Desp(aSE2,nMoeda,nOp)
Local cComboMoe	:=	""
Local oDlg,oGrp1,oSBtn2,oSBtn3,oSay4,oGrp7, nX
Local nOpcao := 0
Local nTotal	:= 0
Private aCols
Private aHeader
Private oTotal

oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := STR0182 //"Despesas do pagamento"
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 499
oDlg:nHeight := 241
oDlg:lShowHint := .F.
oDlg:lCentered := .F.

oGrp1 := TGROUP():Create(oDlg)
oGrp1:cName := "oGrp1"
oGrp1:cCaption := "Totais"
oGrp1:nLeft := 6
oGrp1:nTop := 1
oGrp1:nWidth := 481
oGrp1:nHeight := 37
oGrp1:lShowHint := .F.
oGrp1:lReadOnly := .F.
oGrp1:Align := 0
oGrp1:lVisibleControl := .T.

oSay4 := TSAY():Create(oDlg)
oSay4:cName := "oSay4"
oSay4:cCaption := STR0183+aMoeda[nMoeda]+")"//"Total de despesas (em "
oSay4:nLeft := 23
oSay4:nTop := 16
oSay4:nWidth := 154
oSay4:nHeight := 17
oSay4:lShowHint := .F.
oSay4:lReadOnly := .F.
oSay4:Align := 0
oSay4:lVisibleControl := .T.
oSay4:lWordWrap := .F.
oSay4:lTransparent := .F.

oTotal := TSAY():Create(oDlg)
oTotal:cName := "oTotal"
nTotal	:=	0
For nX:= 1 To Len(aSE2[nOp,4])
	nTotal	+=	 Round(xMoeda(aSE2[nOp,4,nX,2],Val(aSE2[nOp,4,nX,3]),nMoeda,dDataBase,5,aTxMoedas[Val(aSE2[nOp,4,nX,3])][2],aTxMoedas[nMoeda][2]),MsDecimais(nMoeda))
Next
oTotal:cCaption := TransForm(nTotal,'@E 999,999,999.99')
oTotal:nLeft := 200
oTotal:nTop := 16
oTotal:nWidth := 150
oTotal:nHeight := 17
oTotal:lShowHint := .F.
oTotal:lReadOnly := .F.
oTotal:Align := 0
oTotal:lVisibleControl := .T.
oTotal:lWordWrap := .F.
oTotal:lTransparent := .F.

oGrp7 := TGROUP():Create(oDlg)
oGrp7:cName := "oGrp7"
oGrp7:cCaption := STR0180 //"Despesas"
oGrp7:nLeft := 6
oGrp7:nTop := 38
oGrp7:nWidth := 481
oGrp7:nHeight := 146
oGrp7:lShowHint := .F.
oGrp7:lReadOnly := .F.
oGrp7:Align := 0
oGrp7:lVisibleControl := .T.

oSBtn2 := SBUTTON():Create(oDlg)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "oSBtn2"
oSBtn2:nLeft := 368
oSBtn2:nTop := 188
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 1
oSBtn2:bAction:= {|| nOpcao := 1, oDlg:End()}

oSBtn3 := SBUTTON():Create(oDlg)
oSBtn3:cName := "oSBtn3"
oSBtn3:cCaption := "oSBtn3"
oSBtn3:nLeft := 432
oSBtn3:nTop := 188
oSBtn3:nWidth := 52
oSBtn3:nHeight := 22
oSBtn3:lShowHint := .F.
oSBtn3:lReadOnly := .F.
oSBtn3:Align := 0
oSBtn3:lVisibleControl := .T.
oSBtn3:nType := 2
oSBtn3:bAction:= {|| nOpcao := 0, oDlg:End()}

aHeader	:=	{}
For nX := 1 To Len(aMoeda)
	cComboMoe	+= StrZero(nX,1)+"="+aMoeda[nX]+";"
Next
cComboMoe	:=	Left(cComboMoe,Len(cComboMoe)-1)
DbSelectArea("SX3")
DbSetOrder(2)
MsSeek('EK_TPDESP')

AADD(aHeader,{ TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_F3, X3_ARQUIVO, X3CBOX() } )
MsSeek('EK_VALOR')
AADD(aHeader,{ TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, "Positivo().And. F850VldDesp("+Str(nMoeda,2)+",@oTotal)",;
		X3_USADO, X3_TIPO, X3_F3, X3_ARQUIVO, X3CBOX() } )
MsSeek('EK_MOEDA')
AADD(aHeader,{ TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, "NAOVAZIO().And. F850VldDesp("+Str(nMoeda,2)+",@oTotal)",;
		X3_USADO, X3_TIPO, X3_F3, X3_ARQUIVO, cComboMoe } )

If Len(aSE2[nOP,4]) > 0
	aCols := aClone(aSE2[nOP,4])
Else
	aCols	:=	Array(1,Len(aHeader)+1)
	aCols[1,1]	:=	"  "
	aCols[1,2]	:=	0
	aCols[1,3]	:=	"1"
	aCols[1,4]	:=	.F.
Endif
oGetD := MsNewGetDados():New(25,6,88,240,3,"F850DspLok()","AllwaysTrue()","EK_MOEDA",/*acpos*/,/*freeze*/,100,,/*superdel*/,/*delok*/,oDlg,@aHeader,@aCols)

Activate Dialog oDlg CENTERED

If nOpcao == 1
	aSE2[nOP,4] := {}
	For nX := 1 To Len(oGetd:aCols)
		If !oGetd:aCols[nX,Len(oGetd:aCols[nX]) ] .And. oGetd:aCols[nX,2] > 0
			AAdd(aSE2[nOP,4],oGetd:aCols[nX])
		Endif
	Next
Endif

Return

Function F850VldDesp(nMoeda,oTotal)
Local nTotal	:=	0
Local nX
Local lRet	:=	.T.
If lRet .And. !("EK_TPDESP"$ReadVar())
	For nX:= 1 to Len(aCols)
		If !aCols[nX,Len(aCols[nX]) ]
			IF n==nX
				If "EK_MOEDA" $ READVAR()
					nMoeAtu := 	Val(M->EK_MOEDA)
					nValAtu	:=	aCols[nX,2]
				Else
					nMoeAtu := 	Val(aCols[nX,3])
					nValAtu	:=	M->EK_VALOR
				Endif
			Else
				nMoeAtu := 	Val(aCols[nX,3])
				nValAtu	:=	aCols[nX,2]
	  	Endif
			nTotal	+=	 Round(xMoeda(nValAtu,nMoeAtu,nMoeda,dDataBase,5,aTxMoedas[nMoeAtu][2],aTxMoedas[nMoeda][2]),MsDecimais(nMoeda))
		Endif
	Next
	oTotal:SetText(TransForm(nTotal,'@E 999,999,999.99'))
Endif
Return lRet

Function F850DspLok()
Local lRet		:=	.T.
If !aCols[n,Len(aCols[n])]
	If Empty(aCols[n,1]) .Or.Empty(aCols[n,2]).Or. Empty(aCols[n,3])
		Help(" ",1,'OBRIGAT')
		lRet	:=	.F.
	Endif
Endif
Return lRet

Function F850PrNFPA(aOrdPg)
Local nTotPA :=0
Local nTotNF:=0
Local nTotCr:=0
Local nX:=0
Local nI:=0
Local nPropImp:= 1
Local nPosSE2	:= 0
Local nVlrPOP	:= 0
For nI := 1 To Len(aOrdPg)

	For nX := 1 To Len(aOrdPg[nI][4])
		DbSelectArea('SE2')
		MsGoTo(aOrdPg[nI][4][nX])
		nPosSE2 := Ascan(aRecnoSE2,{|ase2| ase2[8] == aOrdPg[nI][4][nX]})
		nVlrPOP := If(nPosSE2 > 0,aRecnoSE2[nPosSE2,9],0)
		cFornece := E2_FORNECE
		cLoja    := E2_LOJA
		If (SE2->E2_TIPO $ MVPAGANT)
			If lShowPOrd
				nTotPA   += Round(xMoeda(nVlrPOP,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
			Else
  			If lBxParc .and. SE2->E2_VLBXPAR > 0  .And.  SE2->E2_VLBXPAR <=SE2->E2_SALDO
 				nTotPA   += Round(xMoeda(SE2->E2_VLBXPAR,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
 			Else
  				nTotPA   += Round(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
 	   		EndIf
	 	   	Endif
		ElseIf (SE2->E2_TIPO$MV_CPNEG)
			If lShowPOrd
 				nTotCr   += Round(xMoeda(nVlrPOP,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
			Else
  			If lBxParc .and. SE2->E2_VLBXPAR > 0  .And.  SE2->E2_VLBXPAR <=SE2->E2_SALDO
 				nTotCr   += Round(xMoeda(SE2->E2_VLBXPAR,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
 			Else
  				nTotCr   += Round(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
 	   		EndIf
			Endif
		Else
			If lShowPOrd
   				nTotNF   += Round(xMoeda(nVlrPOP,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
			Else
  			If lBxParc .and. SE2->E2_VLBXPAR > 0  .And.  SE2->E2_VLBXPAR <=SE2->E2_SALDO
   				nTotNF   += Round(xMoeda(SE2->E2_VLBXPAR,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
  			Else
   				nTotNF   += Round(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
	  			EndIf
  			EndIf
		EndIf
	Next
	nPropImp:=(nTotNF-(nTotPA+nTotCr) )/(nTotNF-nTotCr)

Next

Return nPropImp


Function F850PegaAliq(cFornece,cLoja)
Local nX
Local nAliq := 0
Local aAreaSFH := {}

Private aImpVarSD1 := {0,0,0,0,0,{},cProv}
Private cSerie	:=	"A  "
Private aHeader := {}

DEFAULT cFornece := ""
DEFAULT cLoja    := ""

aImpVarSD1[1] := 1 			//nQuant
aImpVarSD1[2] := 1 			//nPrcVen
aImpVarSD1[3] := nVlrPagar	//nValorItem
aImpVarSD1[4] := 0.00
aImpVarSD1[5] := 0.00
aImpVarSD1[6] := {}
CalcTesXIp( "E",nVlrPagar /*nTotBaseImp*/, nVlrPagar/*nValorItem*/, ""/*cProduto*/, /*nPosCols*/, 1 /*nPosRow*/, "RAPIDA"/*cVenda*/ ,/*nDescontos*/,/*nDescTot*/,1 /*nMaxArray*/,/*aUltItem*/)
For nX:= 1 To Len(aImpVarSD1[6])
	If aImpVarSD1[6,nX,4] > 0
		If (!("IB"$aImpVarSD1[6,nX,1])) .AND. ("IV"$aImpVarSD1[6,nX,1])
			If aImpVarSD1[6,nX,2] > 0
				nAliq += aImpVarSD1[6,nX,2]
			Else
				dbSelectArea("SFH")
				aAreaSFH := SFH->(GetArea())
				SFH->(dbSetOrder(1))

				If SFH->(MsSeek(xFilial("SFH")+cFornece+cLoja+aImpVarSD1[6,nX,1]))
					nAliq += SFH->FH_ALIQ
				Else
					nAliq += 0
				Endif       

				SFH->(RestArea(aAreaSFH))
			Endif
			
		Elseif (aImpVarSD1[6,nX,20] == cProv .Or. !Empty(aImpVarSD1[6,nX,20])) .And. "IB"$aImpVarSD1[6,nX,1]

			If aImpVarSD1[6,nX,2] > 0
				nAliq += aImpVarSD1[6,nX,2]
			Else

				dbSelectArea("SFH")
				aAreaSFH := SFH->(GetArea())
				SFH->(dbSetOrder(1))

				If SFH->(MsSeek(xFilial("SFH")+cFornece+cLoja+aImpVarSD1[6,nX,1]+aImpVarSD1[6,nX,20]))
					nAliq += SFH->FH_ALIQ
				Else
					nAliq += 0
				Endif

				SFH->(RestArea(aAreaSFH))
			Endif
		Elseif  !Empty(aImpVarSD1[6,nX,1])
			If aImpVarSD1[6,nX,2] > 0
				nAliq += aImpVarSD1[6,nX,2]
			EndIF
		Endif		
	EndIf
Next
Return nAliq


Function F850ImpPA(oObj,aSE2,cFor,oFor,oRet,nRet,nValor,nLiquido,oLiquido,nRetIb,oRetIb,nRetIva,oRetIva,nRetSuss,oRetSuss)
Local nX,nA,nP,nC
Local oDlg,oFntMoeda
Local lConfirmo	:=	.F.
Local aCpos
Local aConGan
Local oGetDad1
Local nHdl
Local lMonotrb := .F.

Local oRetGan
Private	oTotAnt,nValDesc	:=	0,nPorDesc	:=	0,nTotNCC:=0
Private	oNumOp ,oPorDesc ,oValDesc ,oZnGeo,oGrpSus

If cPaisLoc == "ARG"
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja))
Endif

DEFINE MSDIALOG oDlg FROM 30,40  TO 250,550 TITLE OemToAnsi(STR0189) Of oObj PIXEL  // "Orden de pago del proveedor "

//Titulos por pagar
@ 37,004 To 75,250 Pixel Of  oDlg LABEL OemToAnsi(STR0089)

@ 45,006 SAY OemToAnsi(STR0185)  	Size 70,08  Of oDlg Pixel COLOR CLR_HBLUE  //"Numero da operacao
@ 45,050 MSGET oNumOp  Var cNumOp    Valid F850NumOp(cNumOp,nTotAnt)Size 60,08 Pixel Of oDlg

@ 45,145 SAY OemToAnsi(STR0184) SIZE 30, 7 OF oDlg PIXEL COLOR CLR_HBLUE //TES
@ 45,185 MSGET oCF   VAR cCF	F3 "SF4" Picture "@S3"  Valid (ExistCpo("SF4",cCF) .And. F850VldRet(1,cFornece,@cFor,oFor,oRet,@nRet,nValor,@nLiquido,oLiquido,@aSE2,cLoja,cCF,cProv,oRetIB,@nRetIB,cZnGeo,nGrpSus,nTotAnt,oRetIVA,@nRetIVA,oRetSUSS,@nRetSuss,,,,,,,.T.)) SIZE 15, 7 PIXEL OF oDlg // WHEN nPagar<>4

@ 58,006 SAY OemToAnsi(STR0159) SIZE 45, 7 OF oDlg PIXEL COLOR CLR_HBLUE //Provincia
@ 58,050 MSGET oProv   VAR cProv F3 "12" Picture "@!" Valid F850VldRet(1,cFornece,@cFor,oFor,oRet,@nRet,nValor,@nLiquido,oLiquido,@aSE2,cLoja,cCF,cProv,oRetIB,@nRetIB,cZnGeo,nGrpSus,nTotAnt,oRetIVA,@nRetIVA,oRetSUSS,@nRetSuss,,,,,,,.T.) SIZE 15, 7 PIXEL OF oDlg // WHEN nPagar<>4
	
If cPaisloc == "ARG"
	@ 58,145 SAY OemToAnsi(STR0402) SIZE 45, 7 OF oDlg PIXEL //Serie NF
	@ 58,195 MSGET oSerieNF VAR cSerieNF Picture "@!" Valid F850VldRet(1,cFornece,@cFor,oFor,oRet,@nRet,nValor,@nLiquido,oLiquido,@aSE2,cLoja,cCF,cProv,oRetIB,@nRetIB,cZnGeo,nGrpSus,nTotAnt,oRetIVA,@nRetIVA,oRetSUSS,@nRetSuss,,,,,,,.T.) SIZE 15, 7 PIXEL OF oDlg // WHEN nPagar<>4
EndIf
	@ 75,004 To 100,250 Pixel Of oDlg LABEL OemToAnsi(STR0098) // "&Recalc. Ret."
	@ 85,006 SAY OemToAnsi("Ganancias : ")  		Size 40,08 Pixel Of  oDlg
	@ 85,050 SAY oRet VAR nRet Size 60,08 PIXEL OF oDlg Picture Tm(nRet,19,nDecs)  COLOR CLR_BLUE

	@ 85,110 SAY OemToAnsi("Ingresos Brutos : ") Size 40,08 Pixel Of  oDlg
	@ 85,154 SAY oRetIB Var nRetIB  Size 60,08 Pixel Of  oDlg Picture Tm(nRetIB,19,nDecs)  COLOR CLR_BLUE

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(F850TudoOk(cNumOp,nTotAnt,cZnGeo,nGrpSus,cCF,cProv),oDlg:End(),nOpca := 0)},{||oDlg:End()})

Return .T.

// Funcao para verificar se ja exiuste o numero de operacao informado
// caso exista o valor total da operacao(valor utilizado ocmo base de calculo)
// nao podera ser diferente do valor da opera็ใo original.
Function F850NumOp()

DbSelectArea("SEK")
SEK->(dbSetOrder(2))
If SEK->(MsSeek(xFilial("SEK")+cFornece+cLoja))    //criar um indide com numero da operacao
	cChaveSEK := xFilial("SEK")+SEK->EK_FORNECE+SEK->EK_LOJA
	While !SEK->(Eof()) .And. cChaveSEK == SEK->EK_FILIAL+SEK->EK_FORNECE+SEK->EK_LOJA
		If SEK->EK_TIPODOC =="PA"  .And. SEK->EK_NUMOPER == cNumOp
			lCont:= MSGYESNO(STR0403 ,STR0309 )
			If lCont
				nTotAnt:=SEK->EK_TOTANT
			Else
				cNumOp := Space(TamSx3("EK_NUMOPER")[1])
				nTotAnt:= 0
			EndIf	
		EndIf
		SEK->(dbSkip())
	End
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VldRetบAutor  ณAna PAula			 บFecha ณ  10/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula reten็๕es de IVA, SUSS, IB e Ganancias na inclussใoบฑฑ
ฑฑบ          ณ de pagamentos antecipados quando o parametro MV_RETPA=S    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FinF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VldRet(nOpc,cFornece,cFor,oFor,oRet,nRet,nValor,nLiquido,oLiquido,aSE2,cLoja,cCF,cProv,oRetIB,nRetIB,cZnGeo,nGrpSus,nTotAnt,oRetIVA,nRetIVA,oRetSUSS,nRetSuss,nBaseRIE,nAliqRIE,nAliqIGV,oAliqIGV,nBaseIGV,lOPRotAut,lPA)
Local aConGan		:= {}
Local aTmp			:= {}  
Local aTmp1		:= {}
Local aTmpSus 		:= {}
Local aTmpIva 		:= {}
Local aTmpIB		:= {}
Local aRateioGan  := {}
Local aConGanRat  := {}
Local nX,nY
Local nXProv      := 0

Local nA			:= 0
Local lRetem		:= .T.
Local lCalcSus		:= .F.
Local lCalcIb  	:= .F.
Local lCalcGan 	:= .F.
Local lMonotrb 	:= .F.

Local nLiquP 		:= 0

Local nMoedSol := 0
Local lMoedaCam     := IsInCallStack("F850PgAdi") .And. cPaisLoc == "ARG" .And. !lSolicFundo  .And. nMoedaTCor!=nMoedaCor
Local nConcepGan    := 0

Default nTotAnt	:= 0
DEfault nBaseRIE	:= 0
DEfault nAliqRIE 	:= 0
DEfault nBaseIGV 	:= 0
DEfault nAliqIGV 	:= 0
Default lOPRotAut	:= .F.
Default lPA  	    := .F.

lMonotrb := Iif(SA2->A2_TIPO == 'M' .And. cPaisLoc == "ARG" ,.T.,.F.)
If  lRetPA .And. nValor > 0 .And. cPaisLoc == "ARG" .and. !Empty(cCF)
	SA6->(DbsetOrder(1))
 	If SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
		nMoedaCor := SA6->A6_MOEDA
	EndIf
	SF4->(DbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4")+cCF))
 	nTotPImp:= F850PegaAliq(cFornece,cLoja)
 	cCFOP := SF4->F4_CF
	If  GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG"
 		nMoedSol:= Val(SubStr(FJA->FJA_MOEDA,2,2))
 		nBaseImp:= Round(xMoeda(nValor/(nTotPImp/100+1),nMoedSol,1,,5,aTxMoedas[nMoedSol][2]),MsDecimais(1))
 		nValor  := Round(xMoeda(nValor,nMoedSol,1,,5,aTxMoedas[nMoedSol][2]),MsDecimais(1))
 	Else 
 		nBaseImp:= Round((nValor/(nTotPImp/100+1)),MsDecimais(1))
 		If  lMoedaCam
 			nBaseImp:= Round(xMoeda(nBaseImp,nMoedaTCor,1,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)) //Se convierte a la moneda
 		Endif
 	EndIf
	aConGan	:=	{{Iif(lMonotrb, SA2->A2_CMONGAN, SA2->A2_AGREGAN),Round(xMoeda(nBaseImp,nMoedaCor,1,,5,aTxMoedas[nMoedaCor][2]),MsDecimais(1)),'',cFornece+cLoja}}
    RateioCond(@aRateioGan)

	For nY	:=	1 To Len(aConGan)
		For nX := 1 To Len(aRateioGan)
			AAdd(aConGanRat,{aConGan[nY][1],aConGan[nY][2]*aRateioGan[nX][4],aConGan[nY][3],aRateioGan[nX][2]+aRateioGan[nX][3]})
		Next
	Next

	For nY := 1 To Len(aConGanRat)
		nPosGan   := ASCAN(aConGan,{|x|  x[1]+x[3]+x[4] == aConGanRat[nY][1]+aConGanRat[nY][3]+aConGanRat[nY][4] })
		If nPosGan==0
			Aadd(aConGan,aClone(aConGanRat[nY]))
		Endif
	Next

	nConcepGan := aScan(aConGan,{ |x| x[1] == "07" })
	If cPaisLoc == "ARG" .And. FindFunction("F850PCuit") .And. (subs(cAgente,1,1) == "S" .Or. nConcepGan > 0)
		For nXProv := 1 To Len(aRateioGan)
			F850PCuit(aRateioGan[nXProv][2], aRateioGan[nXProv][3], @aProvCuit, .T.)
		Next nXProv
	EndIf
	
	nSigno  :=   1 

	If lMonotrb
		aTmp		:=	ARGRetGNMnt(cAgente,,aConGan,cFornece,cLoja,,,.T.,,,lOPRotAut)
	Else
		aTmp		:=	ARGRetGN(cAgente,,aConGan,cFornece,cLoja,,lOPRotAut,lPA)
	Endif

	//Calculo de IIBB
	aConfProv := CheckConfIB(cFornece,cLoja,cProv,SA2->A2_FILIAL)

	For nX := 1 To Len(aConfProv)
		If cPaisLoc == "ARG" .And. aConfProv[nX][1] == "CO"
			aTmp1	:= ARGRetIB(cAgente,nSigno,Iif(lMoedaCam,Round(xMoeda(nValor,nMoedaTCor,1,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nValor),SF4->F4_CF,cProv, .T.,, aConfProv[nX],,,,,,,,,,,lOPRotAut)
		Else
			aTmp1	:= ARGRetIB(cAgente,nSigno,nBaseImp,SF4->F4_CF,cProv,.T.,,aConfProv[nX],,,,,,,,,,,lOPRotAut)
		Endif
		If Len(aTmp1) > 0

			For nY := 1 To Len(aTmp1)
				aAdd(aTmpIB, Array(12))
				aTmpIB[Len(aTmpIb)] := aTmp1[nY]
			Next nY

			aTmp1   := {}
		Endif
	Next nX

	nRet	 	:=	0	//Retencao de Ganancias
	nRetIB		:=	0	//Retencao de IIBB
	nRetIVA	:=	0	//Retencao de IVA
	nRetSUSS	:=	0	//Retencao de SUSS

	AaddSE2(1,aSE2,.T.)
	aSE2[1,1,1,_RETIVA]	:= aClone(aTmpIva)
 	aSE2[1][2]				:= ACLONE(aTmp)
	aSE2[1,1,1,_RETIB]	:= aClone(aTmpIB)
	aSE2[1,1,1,_RETSUSS] := aClone(aTmpSus)

	SFF->(DbSetOrder(5))
	SFF->(MsSeek(xFilial()+"IBR"+SF4->F4_CF+cProv))
	If (Iif(lMoedaCam,Round(xMoeda(nValor,nMoedaTCor,1,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nValor)  < SFF->FF_IMPORTE) .And. (nValor <> 0)
		nA := aScan(aSe2[1,1,1,_RETIB],{|x| x[11] == SF4->F4_CF}) //busca codigo fiscal
		If nA > 0
			aSe2[1,1,1,_RETIB,nA,5] := 0
		EndIf
	EndIf

	For nX	:=	1	To	Len(aSE2[1][2])
		nRet	+=	Round(xMoeda(aSE2[1][2][nX][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Next
 	For nX	:=	1	To	Len(aSE2[1,1,1,_RETIB])
  		nRetIB	+=	Round(xMoeda(aSE2[1][1][1][15][nX][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Next
	For nX	:=	1	To	Len(aSE2[1,1,1,_RETIVA])
  		nRetIVA	+=	Round(xMoeda(aSE2[1][1][1][14][nX][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Next

	For nX	:=	1	To	Len(aSE2[1,1,1,_RETSUSS])
  		nRetSUSS	+=	Round(xMoeda(aSE2[1][1][1][24][nX][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Next

	// IVA
	nLiquido:=nValor
	
		// Ganancia
	If  (Iif(lMoedaCam,Round(xMoeda(nLiquido,nMoedaTCor,1,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nLiquido)) - nRet >=0  .And. lRetem
		nLiquido:= nLiquido - Iif(lMoedaCam,Round(xMoeda(nRet,nMoedaCor,nMoedaTCor,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nRet) 	
		nVlrNeto := nLiquido	
		
		lCalcGAN:=.T.
	ElseIf  nLiquido >0
		nLiquP:= nLiquido - Iif(lMoedaCam,Round(xMoeda(nRet,nMoedaCor,nMoedaTCor,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nRet)
		nRet := Iif(lMoedaCam,Round(xMoeda(nRet,nMoedaCor,nMoedaTCor,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nRet) -(nLiquP*(-1)  )
		nLiquido:=nLiquido - nRet
		nVlrNeto := nLiquido
		If  lMoedaCam
			nRet := Round((xMoeda(nRet,nMoedaTCor,1,,5,aTxMoedas[nMoedaTCor][2])/(nTotPImp/100+1)),MsDecimais(1))
		Endif 
		aSE2[1][2][1][5]:= Round(xMoeda(nRet,nMoedaCor,1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)) 
		
		lRetem := .F.
		lCalcGAN:=.T.
	EndIf

	// Ingresso Bruto
	If  (Iif(lMoedaCam,Round(xMoeda(nLiquido,nMoedaTCor,1,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nLiquido)) - nRetIB >=0  .And. lRetem
		nLiquido:= nLiquido - Iif(lMoedaCam,Round(xMoeda(nRetib,nMoedaCor,nMoedaTCor,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nRetib) 
		nVlrNeto := nLiquido
		lCalcIb:=.T.
	ElseIf  nLiquido >0	.And. aSE2[1][1][1][15][1][5] != Nil
		nLiquP:= nLiquido - Iif(lMoedaCam,Round(xMoeda(nRetIb,nMoedaCor,nMoedaTCor,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nRetIb) 
		nRetib := Iif(lMoedaCam,Round(xMoeda(nRetIb,nMoedaCor,nMoedaTCor,,5,aTxMoedas[nMoedaTCor][2]),MsDecimais(1)),nRetIb) -(nLiquP*(-1)   )
		nLiquido:=nLiquido - nRetib
		nVlrNeto := nLiquido
		If  lMoedaCam
			nRetib := Round((xMoeda(nRetib,nMoedaTCor,1,,5,aTxMoedas[nMoedaTCor][2])/(nTotPImp/100+1)),MsDecimais(1))
		Endif 
		aSE2[1][1][1][15][1][5]:= Round(xMoeda(nRetib,nMoedaCor,1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)) 
		
		lRetem := .F.
		lCalcIb:=.T.
	EndIf

	// Acertar valores dos arrays de reten็๕es zerados
	If !lCalcGan
		For nX	:=	1	To	Len(aSE2[1][2])
			aSE2[1][2][nX][5]:=0
			nRet:=0
		Next
	EndIf
 	If !lCalcIb
 		For nX	:=	1	To	Len(aSE2[1,1,1,_RETIB])
  			aSE2[1][1][1][15][nX][5]:=0
  			nRetIb:=0
		Next
	EndIf
	If !lCalcSus
		For nX	:=	1	To	Len(aSE2[1,1,1,_RETSUSS])
  			aSE2[1][1][1][24][nX][6]:=0
			nRetSuss:=0
		Next
	EndIf

	If !lOPRotAut
		If oRet <> Nil .And. !lSmlCtb
			oRet:Refresh()
		Endif

		If oRetIB <> Nil.And. !lSmlCtb
			oRetIB:Refresh()
		Endif

		If oRetIVA <> Nil.And. !lSmlCtb
			oRetIVA:Refresh()
		Endif

		If oRetSuss <> Nil .And. !lSmlCtb
			oRetSuss:Refresh()
		Endif
	EndIf

ElseIf lRetPA .AND. nValor > 0 .AND. cPaisLoc == "ANG"
	If !lOPRotAut
		oAliqigv:Refresh()
	EndIf
	aSE2	:=	{}
	AaddSE2(1,aSE2,.T.)
	aSFERIE := {}
	AAdd(aSFERIE,array(8))
	aSFERIE[Len(aSFERIE)][1] := ""
	aSFERIE[Len(aSFERIE)][2] := "PA"
	aSFERIE[Len(aSFERIE)][3] := Round(nBaseRIE,MsDecimais(1)) 	//FE_VALBASE
	aSFERIE[Len(aSFERIE)][4] := Round(nBaseRIE * nAliqRIE/100,MsDecimais(1))	//FE_VALIMP
	aSFERIE[Len(aSFERIE)][5] := 100
	aSFERIE[Len(aSFERIE)][6] := aSFERIE[Len(aSFERIE)][4]
	aSFERIE[Len(aSFERIE)][7] := nBaseRIE
	aSFERIE[Len(aSFERIE)][8] := dDataBase

	aSE2[1,1,1,_RETRIE]	:= aClone(aSFERIE)
	nLiquido:= nValor - aSE2[1,1,1,_RETRIE,1,6]

ElseIf (cPaisloc == "ARG" .And. !lRetPA .And. lPA) .And. (nValor > 0 )
	 nVlrNeto:= nValor
Endif

If !lOPRotAut
	If oLiquido <> NIL .AND. !lSmlCtb
		oLiquido:Refresh()
	EndIF
	If cPaisloc == "ARG" .AND. !lRetPa .And. oLiquido <> NIL .AND. !lSmlCtb
		nLiquido:=nValor
		oLiquido:Refresh()
	EndIf
	If Valtype(nVlrNeto) == "N" .and. nVlrNeto > 0
		If  GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG"
			nSaldoPgOP := F850AtuProp()
			nVlrNeto := Round(xMoeda(nLiquido,1,nMoedSol,,5,aTxMoedas[nMoedSol][2]),MsDecimais(1))
		Endif	
		nSaldoPgOP := nVlrPagar - (nTotDocTerc + nTotDocProp) - (nVlrPagar - nVlrNeto)
	EndIf
EndIf

Return .T.

Function F850TudoOk()
Local lRet:= .T.

If Empty (cNumOp) .Or. Empty (cCF) .Or. Empty(cProv)
	Help(" ",1,"Obrigat")
	lRet:=.F.
EndIf

If Empty (cZnGeo) .And. !Empty(nGrpSus)

	Help(" ",1,"OBRIZNGEO")
	lRet:=.F.
EndIf

If !Empty (cZnGeo) .And. Empty(nGrpSus)
	Help(" ",1,"OBRIGATPOBRA")
	lRet:=.F.
EndIf

Return lRet

// Proporcionaliza็ใo para reten็๕es de IVA e SUSS
Function F850PrIS(aOrdPg)
Local nTotPA :=0
Local nTotNF:=0
Local nX:=0
Local nI:=0
Local nProp:= 1
Local nPosSE2	:= 0
Local nVlrPOP	:= 0
For nI := 1 To Len(aOrdPg)
	For nX := 1 To Len(aOrdPg[nI][4])
		DbSelectArea('SE2')
		MsGoTo(aOrdPg[nI][4][nX])
		nPosSE2 := Ascan(aRecnoSE2,{|ase2| ase2[8] == aOrdPg[nI][4][nX]})
		nVlrPOP := If(nPosSE2 > 0,aRecnoSE2[nPosSE2,9],0)
		cFornece := E2_FORNECE
		cLoja    := E2_LOJA
		SEK->(DbsetOrder(1))
		SEK->(MsSeek(xFilial("SE2")+SE2->E2_NUM+SE2->E2_TIPO) )
		If (SE2->E2_TIPO $ MVPAGANT)
  			nTotPA   += 0 // Round(xMoeda(SEK->EK_TOTANT,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
 	   	Else
			If lShowPOrd
   				nTotNF   += Round(xMoeda(nVlrPOP,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
			Else
	  			If lBxParc .and. SE2->E2_VLBXPAR > 0   .And.  SE2->E2_VLBXPAR <=SE2->E2_SALDO
	   				nTotNF   += Round(xMoeda(SE2->E2_VLBXPAR,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
	  			Else
	   				nTotNF   += Round(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,dDataBase,5,aTxMoedas[SE2->E2_MOEDA][2]),MsDecimais(1))
	  			EndIf
	  		Endif
		EndIf
	Next
	nProp:=(nTotNF-nTotPA)/nTotNF
Next

Return nProp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850ImpTesบAutor  ณ Ana Paula          บ Data ณ  07/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula base de calculo para PA automatico abatendo os      บฑฑ
ฑฑบ          ณ impostos relacionados na TES informada                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850ImpTes(nBaseImp,cFornece,cLoja,nBaseRG)
Local nTotImp := 0
Private aHeader:={}

DEFAULT cFornece := ""
DEFAULT cLoja    := ""
DEFAULT nBaseRG  := 0

aArea:=GetArea()

SF4->(DbSetOrder(1))
SF4->(MsSeek(xFilial("SF4")+cTes))

If cPaisLoc == "ARG"
	nSaldo := nSaldoPgOP * -1
Else
	nSaldo := aSaldos[Len(aSaldos)] * -1
EndIf

nTotImp:= F850PegaAliq(cFornece,cLoja)
nBaseRG := nSaldo
nBaseRet:= Round((nSaldo/(nTotImp/100+1)),MsDecimais(1))

If oBaseImp != Nil
	oBaseImp:Refresh()
EndIf

Restarea(aArea)
Return .T.




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850CheckLim  บAutor  ณBruno S./Marcos บ Data ณ  15/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realizaza a verificacao das operacoes dos ultimos 12 meses,บฑฑ
ฑฑบ          ณ pagos ou nใo                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850CheckLim(cConcepto,aCF,cFornece,nMinimo,cDoc,cSerie,nMinUnit,cImposto,lPa,nSD,cFilOr)
Local cDataIni	:=	""
Local cDataFim	:= 	""
Local dDataTmp	:=	dDataBase
Local nCompras	:=	0
Local nI   		:= 0
Local lRet := .F.
#IFDEF TOP
	Local cQuery	:=	""
	Local cAlias	:=	""
#ELSE
	Local nValMax 	:= 0
	Local nValAux 	:= 0
	Local nMoeda	:= 1
#ENDIF

DEFAULT lPa := .F.
DEFAULT nSd := 1
DEFAULT cFilOr := ""

//Considera 12 meses retroativo, a partir do penultimo mes do fato gerador - para Ingresos Brutos.
If cImposto == "IB"
	dDataTmp := Ctod("01/"+StrZero(Month(dDataBase)-1,2)+"/"+Str(Iif(Month(dDataBase)==12,Year(dDataBase)-1,Year(dDataBase)),4))-1
Endif

cDataFim := Dtos(dDataTmp)
If cImposto == "IB"
	dDataTmp++
	cDataIni :=	Str(Year(dDataTmp)-1,4)+StrZero(Month(dDataTmp),2)+StrZero(Day(dDataTmp),2)
Else // Para IVA e GN sera considerado o mes da ordem de pago + os 11 meses anteriores

	IF  (Month(dDataTmp) - 11) <= 0
		cDataIni := Str(Year(dDataTmp)-1,4) + StrZero(Month(dDataTmp)+1,2)+ "01
	Else
		cDataIni := Str(Year(dDataTmp),4) + StrZero(Month(dDataTmp)-11,2)+ "01"
	EndIf
EndIf

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ	1a. Validacao                                       ณ
//ณ		Cosas muebles - Preco unitario superior a $870  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
#IFDEF TOP
If (cConcepto == "G2" .Or. cConcepto == "I2" .Or. cConcepto == "B2") .And. !lPa
	
	If nSD == 1	.And. cImposto == "IB"
		cQuery 	:=  "SELECT D1_VUNIT, F1_MOEDA FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SB1")+" SB1 , "+RetSqlName("SF1")+" SF1 "
		cQuery	+=	" WHERE"
		
		If !lMsFil
			cQuery	+=	" D1_FILIAL = '"+xFilial("SD1")+"' AND "
			cQuery	+=	" F1_FILIAL = '"+xFilial("SF1")+"' AND "
			cQuery	+=	" B1_FILIAL = '"+xFilial("SB1")+"' AND "
		Else
			cQuery	+=	" F1_FILIAL = D1_FILIAL AND "
			If xFilial('SB1') == xFilial('SD1')
				cQuery  +=  " D1_FILIAL  = B1_FILIAL AND "
			Endif
		Endif
		
		If cImposto == "IVA" .Or. cImposto == "IB"
			cQuery += "("
			For nI := 1 to Len(aCF)
				cQuery  +=  " D1_CF    = '"+aCF[nI][1]+"' "
				
				If nI == Len(aCF)
					cQuery += ") AND "
				Else
					cQuery += " OR "
				Endif
			Next nI
		Elseif cImposto == "GAN"
			cQuery  +=  " B1_CMONGAN    = '"+cConcepto+"' AND "
		Endif
		cQuery	+=	" D1_FORNECE 	= '"+cFornece+"' AND " //NAO INCLUIR A LOJA
		cQuery	+=	" D1_SERIE      = '"+cSerie+"' AND "
		cQuery	+=	" D1_DOC        = '"+cDoc+"' AND "
		
		cQuery  += " D1_COD     = B1_COD AND "
		cQuery  += " D1_FORNECE = F1_FORNECE AND "
		cQuery  += " D1_SERIE   = F1_SERIE AND "
		cQuery  += " D1_DOC     = F1_DOC AND "
		
		cQuery	+=	" SB1.D_E_L_E_T_ = '' AND "
		cQuery	+=	" SD1.D_E_L_E_T_ = '' AND "
		cQuery	+=	" SF1.D_E_L_E_T_ = '' "
		
		cQuery 	:= 	ChangeQuery(cQuery)
		cAlias	:=	GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
		
		While !Eof()
			If xMoeda(D1_VUNIT,F1_MOEDA,1,dDataBase) > nMinUnit .And. nMinUnit > 0
				lRet := .T.
				Exit
			Endif
			dbSkip()
		Enddo
		
		DbCloseArea()
		
	Elseif nSD == 2 .And. cImposto == "IB"
		
		cQuery 	:=  "SELECT D2_PRCVEN, F2_MOEDA FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SB1")+" SB1 , "+RetSqlName("SF2")+" SF2 "
		cQuery	+=	" WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND "
		
		If !lMsFil
			cQuery	+=	" D2_FILIAL = '"+xFilial("SD2")+"' AND "
			cQuery	+=	" F2_FILIAL = '"+xFilial("SF2")+"' AND "
			cQuery	+=	" B1_FILIAL = '"+xFilial("SB1")+"' AND "
		Else
			cQuery	+=	" F2_FILIAL = D2_FILIAL AND "
			If xFilial('SB1') == xFilial('SD2')
				cQuery  +=  " D2_FILIAL  = B1_FILIAL AND "
			Endif
		Endif
		
		If cImposto == "IVA" .Or. cImposto == "IB"
			cQuery += "("
			For nI := 1 to Len(aCF)
				cQuery  +=  " D2_CF    = '"+aCF[nI][2]+"' "
				
				If nI == Len(aCF)
					cQuery += ") AND "
				Else
					cQuery += " OR "
				Endif
			Next nI
		Elseif cImposto == "GAN"
			cQuery  +=  " B1_CMONGAN    = '"+cConcepto+"' AND "
		Endif
		cQuery	+=	" D2_CLIENTE 	= '"+cFornece+"' AND " //NAO INCLUIR A LOJA
		cQuery	+=	" D2_SERIE      = '"+cSerie+"' AND "
		cQuery	+=	" D2_DOC        = '"+cDoc+"' AND "
		
		cQuery  += " D2_COD     = B1_COD AND "
		cQuery  += " D2_CLIENTE = F2_CLIENTE AND "
		cQuery  += " D2_SERIE   = F2_SERIE AND "
		cQuery  += " D2_DOC     = F2_DOC AND "
		
		cQuery	+=	" SB1.D_E_L_E_T_ = '' AND "
		cQuery	+=	" SD2.D_E_L_E_T_ = '' AND "
		cQuery	+=	" SF2.D_E_L_E_T_ = '' "
		
		cQuery 	:= 	ChangeQuery(cQuery)
		cAlias	:=	GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
		
		While !Eof()
			If xMoeda(D2_PRCVEN,F2_MOEDA,1,dDataBase) > nMinUnit .And. nMinUnit > 0
				lRet := .T.
				Exit
			Endif
			dbSkip()
		Enddo
		
		DbCloseArea()
		
	Endif
	
Endif

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ	2a. Validacao                                                   ณ
//ณ		a. Locaciones - Soma superior a $72.000 (concepto = G1)     ณ
//ณ		b. Cosas muebles - Soma superior a $144.000 (concepto = G2) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

If !lRet .And. (!cImposto == "IB" .Or. (cImposto == "IB" .And. cConcepto == "B2") )
	//Somar acumulado
	cQuery	:=	" SELECT SUM(D1_TOTAL) D1_TOTAL, F1_MOEDA FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF1")+" SF1, "+RetSqlName("SB1")+" SB1 "
	cQuery	+=	" WHERE "
	If !lMsFil
		cQuery	+=	" D1_FILIAL = '"+xFilial("SD1")+"' AND "
		cQuery	+=	" F1_FILIAL = '"+xFilial("SF1")+"' AND "
		cQuery	+=	" B1_FILIAL = '"+xFilial("SB1")+"' AND "
	Else
		cQuery	+=	" F1_FILIAL = D1_FILIAL AND "
		If xFilial('SB1') == xFilial('SD1')
			cQuery  +=  " D1_FILIAL  = B1_FILIAL AND "
		Endif
	Endif
	cQuery	+=	" D1_FORNECE 	= '"+cFornece+ "' AND " //NAO INCLUIR A LOJA
	cQuery	+=	" F1_SERIE 		= D1_SERIE AND "
	cQuery	+=	" F1_DOC 		= D1_DOC AND "
	cQuery	+=	" F1_ESPECIE 	= D1_ESPECIE AND "
	cQuery	+=	" F1_LOJA 		= D1_LOJA AND "
	cQuery	+=	" F1_FORNECE	= D1_FORNECE AND "
	cQuery	+=	" F1_FILIAL		= D1_FILIAL AND "
	cQuery  +=  " D1_COD        = B1_COD AND "
	
	cQuery	+=	" D1_TIPO IN ('C','N') AND "
	cQuery +=	" D1_ESPECIE IN ('NF','NDP','NCI') AND"
	
	If cImposto == "IVA" .Or. cImposto == "IB"
		cQuery += "("
		For nI := 1 to Len(aCF)
			cQuery  +=  " D1_CF    = '"+aCF[nI][1]+"' "
			
			If nI == Len(aCF)
				cQuery += ") AND "
			Else
				cQuery += " OR "
			Endif
		Next nI
	Elseif cImposto == "GAN"
		cQuery  +=  " B1_CMONGAN    = '"+cConcepto+"' AND "
	Endif
	
	cQuery	+=	" D1_EMISSAO between '"+cDataIni+"' AND '"+cDataFim+"' AND "
	
	cQuery	+=	" SF1.D_E_L_E_T_ = '' AND "
	cQuery	+=	" SB1.D_E_L_E_T_ = '' AND "
	cQuery	+=	" SD1.D_E_L_E_T_ = '' "
	cQuery	+=	" GROUP BY F1_MOEDA "
	
	cQuery 	:= 	ChangeQuery(cQuery)
	cAlias	:=	GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	While !Eof()
		nCompras +=	xMoeda(D1_TOTAL,F1_MOEDA,1,dDataBase)
		DbSkip()
	EndDo
	
	DbCloseArea()
	
	cQuery	:=	" SELECT SUM(D2_TOTAL) D2_TOTAL, F2_MOEDA FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF2")+" SF2, "+RetSqlName("SB1")+" SB1 "
	cQuery	+=	" WHERE "
	If !lMsFil
		cQuery	+=	" D2_FILIAL = '"+xFilial("SD2")+"' AND "
		cQuery	+=	" F2_FILIAL = '"+xFilial("SF2")+"' AND "
		cQuery	+=	" B1_FILIAL = '"+xFilial("SB1")+"' AND "
	Else
		cQuery	+=	" F2_FILIAL = D2_FILIAL AND "
		If xFilial('SB1') == xFilial('SD2')
			cQuery  +=  " D2_FILIAL  = B1_FILIAL AND "
		Endif
	Endif
	cQuery	+=	" D2_CLIENTE 	= '"+cFornece+ "' AND " //NAO INCLUIR A LOJA
	cQuery	+=	" F2_SERIE 		= D2_SERIE AND "
	cQuery	+=	" F2_DOC 		= D2_DOC AND "
	cQuery	+=	" F2_ESPECIE 	= D2_ESPECIE AND "
	cQuery	+=	" F2_LOJA 		= D2_LOJA AND "
	cQuery	+=	" F2_CLIENTE	= D2_CLIENTE AND "
	cQuery	+=	" F2_FILIAL		= D2_FILIAL AND "
	cQuery  +=  " D2_COD        = B1_COD AND "
	
	cQuery	+=	" D2_TIPO = 'D' AND "
	cQuery += " D2_ESPECIE IN ('NCP','NDI') AND"
	
	If cImposto == "IVA" .Or. cImposto == "IB"
		cQuery += "("
		For nI := 1 to Len(aCF)
			cQuery  +=  " D2_CF    = '"+aCF[nI][2]+"' "
			
			If nI == Len(aCF)
				cQuery += ") AND "
			Else
				cQuery += " OR "
			Endif
			
		Next nI
	Elseif cImposto == "GAN"
		cQuery  +=  " B1_CMONGAN    = '"+cConcepto+"' AND "
	Endif
	
	cQuery	+=	" D2_EMISSAO between '"+cDataIni+"' AND '"+cDataFim+"' AND "
	
	cQuery	+=	" SF2.D_E_L_E_T_ = '' AND "
	cQuery	+=	" SB1.D_E_L_E_T_ = '' AND "
	cQuery	+=	" SD2.D_E_L_E_T_ = '' "
	cQuery	+=	" GROUP BY F2_MOEDA "
	cQuery 	:= 	ChangeQuery(cQuery)
	cAlias	:=	GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	
	While !Eof()
		nCompras -=	xMoeda(D2_TOTAL,F2_MOEDA,1,dDataBase)
		DbSkip()
	EndDo
	DbCloseArea()
	
	//Verificacao dos titulos inserido manualmente - Ganancia
	If cConcepto $ "G1|G2"
		cQuery := " SELECT SUM(E2_VALOR) E2_VALOR, E2_MOEDA  FROM "+RetSqlName("SE2")+" SE2 ,"+RetSqlName("SA2")+" SA2 "
		cQuery += " WHERE "
		
		If !EMPTY(xFilial('SA2'))
			cQuery	+=	" E2_FILIAL = '"+xFilial("SE2")+"' AND "
		Endif
		
		cQuery += " E2_FORNECE = '"+cFornece+"' AND "
		cQuery += " E2_TIPO <> '" + MVCHEQUE + "' AND "
		cQuery += " A2_CMONGAN = '"+cConcepto+"' AND "
		cQuery += " A2_COD = E2_FORNECE AND "
		cQuery += " E2_EMISSAO BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND "
		
		cQuery += " NOT EXISTS ( "
		cQuery += " SELECT D1_SERIE, D1_DOC FROM "+RetSqlName("SD1")+" SD1 "
		cQuery += " WHERE "
		
		If xFilial('SE2') == xFilial('SD1')
			cQuery	+=	" E2_FILIAL = D1_FILIAL AND "
		ElseIf lMsFil
			cQuery	+=	" E2_MSFIL = D1_FILIAL AND "
		ENDIF
		
		cQuery += " D1_EMISSAO BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' AND "
		cQuery += " D1_FORNECE = '"+cFornece+"' AND "
		cQuery += " "+SerieNFID("SD1",3,"D1_SERIE")+" = E2_PREFIXO AND "
		cQuery += " D1_DOC     = E2_NUM AND "
		
		cQuery += " SD1.D_E_L_E_T_ = ' ' "
		
		cQuery += " GROUP BY D1_DOC, D1_SERIE ) AND "
		
		cQuery += " SE2.D_E_L_E_T_ = ' ' "
		
		cQuery += " GROUP BY E2_MOEDA "
		
		cQuery 	:= 	ChangeQuery(cQuery)
		cAlias	:=	GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
		While !Eof()
			nCompras +=	xMoeda(E2_VALOR,E2_MOEDA,1,dDatabase)
			DbSkip()
		EndDo
		
		DbCloseArea()
	Endif
	
	lRet := nCompras >= nMinimo
	Endif

#ELSE

	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ	1a. Validacao                                       ณ
	//ณ		Cosas muebles - Preco unitario superior a $870  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/
	If (cConcepto == "G2" .Or. cConcepto == "I2" .Or. cConcepto == "B2") .And. !lPa
		If nSD == 1	.And. cImposto == "IB"

			dbSelectArea("SD1")
			dbGoTop()
			If lMsFil
				SD1->(MsSeek(cFilOr+cDoc+cSerie+cFornece))
			Else
				SD1->(MsSeek(xFilial("SD1")+cDoc+cSerie+cFornece))
			EndIf
			If SD1->(FOUND())
				While !Eof() .And.;
					   SD1->D1_FILIAL == Iif(lMsFil,SD1->D1_MSFIL,xFilial("SD1")) .And. SD1->D1_DOC == cDoc .And.;
					   SD1->D1_SERIE == cSerie .And. SD1->D1_FORNECE == cFornece

						dbSelectArea("SF1")
						dbGoTop()
		   				dbSetOrder(1)
						If lMsFil
							SF1->(MsSeek(cFilOr+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO))
						Else
							SF1->(MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO))
						EndIf
						If SF1->(Found())
							nMoeda := SF1->F1_MOEDA
						Endif

						//Ganancia
					   If cImposto == "GAN"
							dbSelectArea("SB1")
							dbGoTop()
							dbSetOrder(1)

							If SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD1->D1_MSFIL,xFilial("SB1")) + SD1->D1_COD))
								If SB1->B1_CMONGAN == cConcepto

									nValAux := xMoeda(SD1->D1_VUNIT,nMoeda,1,dDataBase)

									If nValAux > nValMax
										nValMax := nValAux
									Endif

								Endif
							Endif
						ElseIf cImposto == "IVA" .Or. cImposto == "IB"

							For nI := 1 to Len(aCF)

								If 	aCF[nI][1] == SD1->D1_CF
										nValAux := xMoeda(SD1->D1_VUNIT,nMoeda,1,dDataBase)

										If nValAux > nValMax
											nValMax := nValAux
										Endif
								Endif
							Next nI
						Endif
				SD1->(dbSkip())
				Enddo
			Endif

		Elseif nSD == 2 .And. cImposto == "IB"

			dbSelectArea("SD2")
			dbGoTop()
			dbSetOrder(1)

			If lMsfil
				SD2->(MsSeek(cFilOr+cDoc+cSerie+cFornece))
			Else
				SD2->(MsSeek(xFilial("SD2")+cDoc+cSerie+cFornece))
			EndIf

			If SD2->(Found())
				While !Eof() .And.;
					   SD2->D2_FILIAL == Iif(lMsfil,SD2->D2_MSFIL,xFilial("SD2")) .And. SD2->D2_DOC == cDoc .And.;
					   SD2->D2_SERIE == cSerie .And. SD2->D2_CLIENTE == cFornece

						dbSelectArea("SF2")
						dbGoTop()
						dbSetOrder(1)
						If lMsFil
							SF2->(MsSeek(SD2->D2_MSFIL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_TIPO))
			         Else
							SF2->(MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_TIPO))
			         EndIf
						If SF2->(FOUND())
							nMoeda := SF2->F2_MOEDA
						Endif

						//Ganancia
					   If cImposto == "GAN"
							dbSelectArea("SB1")
							dbGoTop()
							dbSetOrder(1)

							If SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD2->D2_MSFIL,xFilial("SB1")) + SD2->D2_COD))
								If SB1->B1_CMONGAN == cConcepto

									nValAux := xMoeda(SD2->D2_PRCVEN,nMoeda,1,dDataBase)

									If nValAux > nValMax
										nValMax := nValAux
									Endif

								Endif
							Endif
						ElseIf cImposto == "IVA" .Or. cImposto == "IB"

							For nI := 1 to Len(aCF)

								If 	aCF[nI][2] == SD2->D2_CF
										nValAux := xMoeda(SD2->D2_PRCVEN,nMoeda,1,dDataBase)

										If nValAux > nValMax
											nValMax := nValAux
										Endif
								Endif
							Next nI
						Endif
				SD1->(dbSkip())
				Enddo
			Endif

		Endif

		If nValMax > nMinUnit .And. nMinUnit > 0
			lRet := .T.
		Endif

	Endif

	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ	2a. Validacao                                                   ณ
	//ณ		a. Locaciones - Soma superior a $72.000 (concepto = G1)     ณ
	//ณ		b. Cosas muebles - Soma superior a $144.000 (concepto = G2) ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/

	If !lRet .And. (!cImposto == "IB" .Or. (cImposto == "IB" .And. cConcepto == "B2") )

		//Faturas de entrada
		dbSelectArea("SD1")
		dbGoTop()
		dbSetOrder(10)

		If lMsFil
			SD1->(MsSeek(cFilOr+cFornece))
		Else
			SD1->(MsSeek(xFilial("SD1")+cFornece))
		EndIf
		If SD1->(FOUND())
			While !Eof() .And.;
				   SD1->D1_FILIAL == Iif(lMsFil,SD1->D1_MSFIL,xFilial("SD1")) .And. SD1->D1_FORNECE == cFornece

				If (SD1->D1_EMISSAO >= Stod(cDataIni) .And. SD1->D1_EMISSAO <= Stod(cDataFim))

					dbSelectArea("SF1")
					dbGoTop()
	   				dbSetOrder(1)

					If lMsFil
						SF1->(MsSeek(SD1->D1_MSFIL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO))
					Else
						SF1->(MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO))
					EndIf
					If SF1->(Found())
						nMoeda := SF1->F1_MOEDA
					Endif

					//Ganancia
					If cImposto == "GAN"
						dbSelectArea("SB1")
						dbGoTop()
						dbSetOrder(1)

						If SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD1->D1_MSFIL,xFilial("SB1")) + SD1->D1_COD))
							If SB1->B1_CMONGAN == cConcepto

								nCompras += xMoeda(SD1->D1_TOTAL,nMoeda,1,dDatabase)

							Endif
						Endif
					ElseIf cImposto == "IVA" .Or. cImposto == "IB"

						For nI := 1 to Len(aCF)

							If 	aCF[nI][1] == SD1->D1_CF

								nCompras += xMoeda(SD1->D1_TOTAL,nMoeda,1,dDatabase)

							Endif
						Next nI
					Endif
				Endif
			SD1->(dbSkip())
			Enddo
		Endif


		//Notas de Credito
		dbSelectArea("SD2")
		dbGoTop()
		dbSetOrder(9)
		If lMsFil
			SD2->(MsSeek(cFilOr+cFornece))
		Else
			SD2->(MsSeek(xFilial("SD2")+cFornece))
		EndIf
		If SD2->(Found())
			While !Eof() .And. SD2->D2_FILIAL == Iif(lMsFil,SD2->D2_MSFIL,xFilial("SD2")) .And. SD2->D2_CLIENTE == cFornece

				If (SD2->D2_EMISSAO >= Stod(cDataIni) .And. SD2->D2_EMISSAO <= Stod(cDataFim))

					dbSelectArea("SF2")
					dbGoTop()
	   				dbSetOrder(1)

					If lMsFil
		   				SF2->(MsSeek(SD2->D2_MSFIL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_TIPO))
	   				Else
		   				SF2->(MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_TIPO))
	   				EndIf

					If SF2->(Found())
						nMoeda := SF2->F2_MOEDA
					Endif

					//Ganancia
					If cImposto == "GAN"
						dbSelectArea("SB1")
						dbGoTop()
						dbSetOrder(1)

						If SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD2->D2_MSFIL,xFilial("SB1")) + SD2->D2_COD))
							If SB1->B1_CMONGAN == cConcepto

								nCompras -= xMoeda(SD2->D2_TOTAL,nMoeda,1,dDatabase)

							Endif
						Endif
					ElseIf cImposto == "IVA" .Or. cImposto == "IB"

						For nI := 1 to Len(aCF)

							If 	aCF[nI][2] == SD2->D2_CF

								nCompras -= xMoeda(SD2->D2_TOTAL,nMoeda,1,dDatabase)

							Endif
						Next nI
					Endif
				Endif
			SD2->(dbSkip())
			Enddo
		Endif

		//Titulos manuais
		dbSelectArea("SE2")
		dbGoTop()
		dbSetOrder(6)

		If lMsFil
			SE2->(MsSeek(cFilOr+cFornece))
		Else
			SE2->(MsSeek(xFilial("SE2")+cFornece))
		EndIf
		If SE2->(Found())
			While !Eof() .And. SE2->E2_FILIAL == Iif(lMsFil,cFilOr,xFilial("SE2")) .And. SE2->E2_FORNECE == cFornece

				If (SE2->E2_EMISSAO >= Stod(cDataIni) .And. SE2->E2_EMISSAO <= Stod(cDataFim))

					nMoeda := SE2->E2_MOEDA

						dbSelectArea("SD1")
						dbGoTop()
						dbSetOrder(1)

						If lMsFil
							SD1->(MsSeek(SE2->E2_MSFIL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE))
						Else
							SD1->(MsSeek(xFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE))
						EndIf

						If !Found()

							nCompras += xMoeda(SE2->E2_VALOR,nMoeda,1,dDatabase)

						Endif
				Endif
			SE2->(dbSkip())
			Enddo
		Endif

		lRet := nCompras >= nMinimo

	Endif

#ENDIF


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850TxMoed บAutor  ณTotvs              บ Data ณ  27/08/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializar Array com as cotacoes e Nomes de Moedas segundo บฑฑ
ฑฑบ          ณo arquivo SM2                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850TxMoed(aTxMoedas)

Local nC := MoedFin()
Local nA := 0
//Local aTxMoedas := {}
Local cMoedaTx	:= ""
DEFAULT aTxMoedas 	:= 	{}

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA moeda 1 e tambem inclusa como um dummy, nao vai ter uso,            ณ
//ณmas simplifica todas as chamadas a funcao xMoeda, ja que posso        ณ
//ณpassara a taxa usando a moeda como elemento do Array atxMoedas        ณ
//ณExemplo xMoeda(E1_VALOR,E1_MOEDA,1,dDataBase,,aTxMoedas[E1_MOEDA][2]) ณ
//ณBruno - Paraguay 25/07/2000                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
//Inicializar Array com as cotacoes e Nomes de Moedas segundo o arquivo SM2
Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
For nA	:=	2	To nC
	cMoedaTx	:=	Str(nA,IIf(nA <= 9,1,2))
	If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
		Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
	Else
		Exit
	Endif
Next

Return aTxMoedas
/*
ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
ฐฐ+-----------------------------------------------------------------------+ฐฐ
ฐฐฐFun็เo    ฐ CalcRetRIE ฐ Autor ฐ Jose Lucas          ฐ Data ฐ 25.06.98 ฐฐฐ
ฐฐ+----------+------------------------------------------------------------ฐฐฐ
ฐฐฐDescri็เo ฐ Calcular e Gerar Retencoes sobre Imposto sobre Empreitada  ฐฐฐ
ฐฐ+----------+------------------------------------------------------------ฐฐฐ
ฐฐฐUso       ฐ PAGO007                                                    ฐฐฐ
ฐฐ+-----------------------------------------------------------------------+ฐฐ
ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
*/
Static Function CalcRetRIE(nSaldo,lPa,nSigno)
Local aSFERIE  	:= {}
Local nTotBase	:=	0
Local nTotImp	:=	0
Local nMoedaNF	:=	1
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')

DEFAULT nSaldo 	:= 	0
DEFAULT lPa		:=	.F.
DEFAULT nSigno 	:= 	1

aArea:=GetArea()

If !lPa
	dbSelectArea("SF1")
	dbSetOrder(1)

	nRecSF1 := FINBuscaNF(,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
	SF1->(dbGoTo(nRecSF1))

	SA2->( dbSetOrder(1) )
	SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Retencao do Imposto sobre Empreitada                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	While Alltrim(SF1->F1_ESPECIE) <> AllTrim(SE2->E2_TIPO).And.!EOF()
		SF1->(DbSkip())
		Loop
	Enddo

	If AllTrim(SF1->F1_ESPECIE)==Alltrim(SE2->E2_TIPO).And.;
			xFilial("SF1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA==;
			F1_FILIAL+F1_DOC+PadR(F1_SERIE,nTamSer)+F1_FORNECE+F1_LOJA

		nProp := Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,5),MsDecimais(1))/Round(xMoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,SF1->F1_DTDIGIT,5),MsDecimais(1))
		nTotBase	:=	SF1->F1_BASIMP3 * nProp
		nTotImp		:=	SF1->F1_VALIMP3 * nProp
		nMoedaNF	:=	SF1->F1_MOEDA

		If nTotBase > 0
			AAdd(aSFERIE,array(8))
			aSFERIE[Len(aSFERIE)][1] := SF1->F1_DOC
			aSFERIE[Len(aSFERIE)][2] := SF1->F1_SERIE
			aSFERIE[Len(aSFERIE)][3] := Round(xMoeda(nTotBase,nMoedaNF,1,,5,aTxMoedas[Max(nMoedaNF,1)][2]),MsDecimais(1)) * nSigno	//FE_VALBASE
			aSFERIE[Len(aSFERIE)][4] := Round(xMoeda(nTotImp ,nMoedaNF,1,,5,aTxMoedas[Max(nMoedaNF,1)][2]),MsDecimais(1)) * nSigno	//FE_VALIMP
			aSFERIE[Len(aSFERIE)][5] := 100
			aSFERIE[Len(aSFERIE)][6] := aSFERIE[Len(aSFERIE)][4]
			aSFERIE[Len(aSFERIE)][7] := SE2->E2_VALOR
			aSFERIE[Len(aSFERIE)][8] := SE2->E2_EMISSAO
		Endif

	Endif
Else
	If SE2->E2_TIPO $ MVPAGANT
		nTotPA := 0
		//PROCURA A RETENCAO GERADA PARA O PA
		nSaldoOri	:=	nSaldo
		nSaldo		:=	Round(xMoeda(nSaldo ,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1))
		SFE->(DbsetOrder(4))
		nRecSFE := FINBuscaNF(,PADR(SE2->E2_ORDPAGO,Len(SFE->FE_NFISCAL)),"PA ",SE2->E2_FORNECE,SE2->E2_LOJA,"SFE",.F.)		
		If	nRecSFE > 0 
			SFE->(dbGoTo(nRecSFE))
 			nTotPA   += (nSaldoOri/SE2->E2_VALOR)*(SFE->FE_VALBASE/SE2->E2_VLCRUZ) * SFE->FE_RETENC
			If nTotPA > 0
				AAdd(aSFERIE,array(8))
				aSFERIE[Len(aSFERIE)][1] := SFE->FE_NFISCAL
				aSFERIE[Len(aSFERIE)][2] := SFE->FE_SERIE
				aSFERIE[Len(aSFERIE)][3] := nSaldo
				aSFERIE[Len(aSFERIE)][4] := nTotPa * -1
				aSFERIE[Len(aSFERIE)][5] := 100
				aSFERIE[Len(aSFERIE)][6] := nTotPa * -1
				aSFERIE[Len(aSFERIE)][7] := SE2->E2_VALOR
				aSFERIE[Len(aSFERIE)][8] := SE2->E2_EMISSAO
			Endif
		Endif
    Else
		dbSelectArea("SF2")
		dbSetOrder(1)

		nRecSF2 := FINBuscaNF(,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.) 
		SF2->(dbGoTo(nRecSF2))

		SA2->( dbSetOrder(1) )
		SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Retencao do Imposto sobre Empreitada                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		While Alltrim(SF2->F2_ESPECIE) <> AllTrim(SE2->E2_TIPO).And.!EOF()
			SF2->(DbSkip())
			Loop
		Enddo

		If AllTrim(SF2->F2_ESPECIE)==Alltrim(SE2->E2_TIPO).And.;
				xFilial("SF2")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA==;
				F2_FILIAL+F2_DOC+PadR(F2_SERIE,nTamSer)+F2_FORNECE+F2_LOJA

			nProp := Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,5),MsDecimais(1))/Round(xMoeda(SF2->F2_VALBRUT,SF2->F2_MOEDA,1,SF2->F2_DTDIGIT,5),MsDecimais(1))
			nTotBase	:=	SF1->F1_BASIMP3 * nProp
			nTotImp		:=	SF1->F1_VALIMP3 * nProp
			nMoedaNF	:=	SF1->F1_MOEDA

			If nTotBase > 0
				AAdd(aSFERIE,array(8))
				aSFERIE[Len(aSFERIE)][1] := SF2->F2_DOC
				aSFERIE[Len(aSFERIE)][2] := SF2->F2_SERIE
				aSFERIE[Len(aSFERIE)][3] := Round(xMoeda(nTotBase,nMoedaNF,1,,5,aTxMoedas[Max(nMoedaNF,1)][2]),MsDecimais(1)) * nSigno	//FE_VALBASE
				aSFERIE[Len(aSFERIE)][4] := Round(xMoeda(nTotImp ,nMoedaNF,1,,5,aTxMoedas[Max(nMoedaNF,1)][2]),MsDecimais(1)) * nSigno	//FE_VALIMP
				aSFERIE[Len(aSFERIE)][5] := 100
				aSFERIE[Len(aSFERIE)][6] := aSFERIE[Len(aSFERIE)][4]
				aSFERIE[Len(aSFERIE)][7] := SE2->E2_VALOR
				aSFERIE[Len(aSFERIE)][8] := SE2->E2_EMISSAO
			Endif

		Endif
    Endif
Endif
RestArea(aArea)

Return aSFERIE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณCheckConfIB  บAutor  ณMarcos Berto        บ Data ณ14/04/10  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณConfigura็ใo de calculo de IIBB - SFH - CCO                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CheckConfIB(cFornecedor, cLoja, cProvincia,cFilFor)
Local nI		:= 0
Local aConfProv	:= {}
Local cTipoForn	:= ""
Local lFindSfh :=.F.

Default cProvincia	:= ""
Default cFilFor		:= xFilial("SA2")

nI := 1
If cPaisLoc $ "ARG/"
	CCO->(DbSetOrder(1))
	CCO->(MsSeek(xFilial("CCO")))
	While CCO->(!Eof()) .And. CCO->CCO_FILIAL == xFilial("CCO")
			SFH->(DbSetOrder(1))
			SFH->(MsSeek(xFilial()+cFornecedor+cLoja+"IBR"+CCO->CCO_CODPROV))
			aAdd(aConfProv, Array(7))
			If SFH->(Found())
				aConfProv[nI][1] := SFH->FH_ZONFIS //Provincia
				aConfProv[nI][2] := CCO->CCO_AGRET //Agente de reten็ใo
				aConfProv[nI][3] := CCO->CCO_TPRET //Tipo de reten็ใo
				While !lFindSfh .and. (SFH->FH_FORNECE ==cFornecedor .and. SFH->FH_LOJA == cLoja .and. SFH->FH_IMPOSTO =="IBR" .and. SFH->FH_ZONFIS == CCO->CCO_CODPROV) .and. !SFH->(Eof())
					If SFH->(ColumnPos("FH_TIPO")) > 0 .And. !Empty(SFH->FH_TIPO) .And. Iif(!Empty(SFH->FH_INIVIGE),dDataBase>=SFH->FH_INIVIGE,.T.) .And. Iif(!Empty(SFH->FH_FIMVIGE),dDataBase<=SFH->FH_FIMVIGE,.T.)
						lFindSfh:=.T.
						Exit
					Endif
					SFH->(dbSkip())
				EndDo
				If lFindSfh
					cTipoForn := SFH->FH_TIPO
				Else
				//Caso o tipo nใo seja informado na amarra็ใo, o fornecedor deve ser tratado como No Inscripto (N)
					cTipoForn := "N"
				Endif

				aConfProv[nI][4] := cTipoForn //Tipo
				aConfProv[nI][5] := IIF(CCO->(ColumnPos("CCO_TPCALC"))>0,CCO->CCO_TPCALC,"1") //Tipo de Calculo 1 o "" por couta, 2 por total
				aConfProv[nI][6] := IIF(CCO->(ColumnPos("CCO_TPCALR"))>0,IIF(Empty(CCO->CCO_TPCALR),"A",CCO->CCO_TPCALR),"A") //Tipo de Calculo 1 o "" por couta, 2 por total
				aConfProv[nI][7] := IIF(CCO->(ColumnPos("CCO_TPLIMR")) > 0 .And. CCO->CCO_TPLIMR == "5", "5", "0") //Si tipo de limite igual a 5, pasa el valor 5, de lo contrario 0. 		
			Else
				aConfProv[nI][1] := CCO->CCO_CODPRO//Provincia
				aConfProv[nI][2] := CCO->CCO_AGRET //Agente de reten็ใo
				aConfProv[nI][3] := CCO->CCO_TPRET //Tipo de reten็ใo
				aConfProv[nI][4] := "N" //Caso nใo exista a amarra็ใo de exce็๕es, o fornecedor deve ser tratado como No Inscripto (N)
				aConfProv[nI][5] := IIF(CCO->(ColumnPos("CCO_TPCALC"))>0,CCO->CCO_TPCALC,"1") //Tipo de Calculo 1 o "" por couta, 2 por total
				aConfProv[nI][6] := IIF(CCO->(ColumnPos("CCO_TPCALR"))>0,IIF(Empty(CCO->CCO_TPCALR),"A",CCO->CCO_TPCALR),"A") //Tipo de Calculo 1 o "" por couta, 2 por total
				aConfProv[nI][7] := IIF(CCO->(ColumnPos("CCO_TPLIMR")) > 0 .And. (CCO->CCO_TPLIMR == "5" .or. CCO->CCO_TPLIMR == "0"), CCO->CCO_TPLIMR, " ") //Si tipo de limite igual a 5, pasa el valor 5, de lo contrario 0.
			Endif
			nI++
		CCO->(DbSkip())
	EndDo
Endif

//Configura็ใo padrใo -> cadastro de Fornecedor - SA2
If Len(aConfProv) == 0
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	If !Empty(xFilial("SA2")) .And. lMsFil .And. xFilial("SF1") == xFilial("SA2")
		SA2->(MsSeek(cFilFor+cFornecedor+cLoja))
	Else
		SA2->(MsSeek(xFilial("SA2")+cFornecedor+cLoja))
	Endif
	If SA2->(Found())
		aAdd(aConfProv,{cProvincia, Iif(SA2->A2_RETIB == "S", "1", "2"), "1", SA2->A2_TIPO,"2","A","0"})
	Endif
Endif

Return aConfProv

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณF850ChkCBU  บAutor  ณMarcos Berto        บ Data ณ26/04/10  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณVerifica os tํtulos gerados dentro do periodo de controle   บฑฑ
ฑฑบ          ณde CBU.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850ChkCBU(aOrdPg)
Local nI			:= 0
Local nX			:= 0
Local aAreaSE2 := {}
Local aAreaSA2 := {}
Local aAreaSF1 := {}
Local aAreaSF2 := {}
Local aRecnoCBU := {}
Local aRecnoNCBU := {}
Local aNewOrdPg := {}
Local nMinCBU	:= GetMV("MV_MINCBU",.F.,0)
Local nValMerc	:= 0

Default aOrdPg := {}

dbSelectArea("SA2")
aAreaSA2 := SA2->(GetArea())

dbSelectArea("SE2")
aAreaSE2 := SE2->(GetArea())

For nI := 1 to Len(aOrdPg)
	aRecnoCBU := {}
	aRecnoNCBU := {}
	SA2->(dbSetOrder(1))
	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2") .And. (nCondAgr <> 3)
		SE2->(dbGoTo(aOrdPg[nI][4][1]))
		SA2->(MsSeek(SE2->E2_MSFIL+aOrdPg[nI][2]+aOrdPg[nI][3]))
	Else
		SA2->(MsSeek(xFilial("SA2")+aOrdPg[nI][2]+aOrdPg[nI][3]))
	Endif
	If SA2->(Found())
		If Empty(SA2->A2_CBUINI) .And. Empty(SA2->A2_CBUFIM)
			aAdd(aNewOrdPg, {aOrdPg[nI][1], aOrdPg[nI][2], aOrdPg[nI][3], aOrdPg[nI][4], .F.,aOrdPg[nI][6] } )
		Else
			For nX := 1 to Len(aOrdPg[nI][4])
				SE2->(dbGoTo(aOrdPg[nI][4][nX]))

				If SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG
					dbSelectArea("SF2")
					aAreaSF2 := SF2->(GetArea())
					SF2->(dbSetOrder(1))
					If lMsFil
						SF2->(MsSeek(SE2->E2_MSFIL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
					Else
						SF2->(MsSeek(xFilial("SF2")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
					Endif
					If SF2->(Found())
						nValMerc := xMoeda(SF2->F2_VALMERC,SF2->F2_MOEDA,1,SE2->E2_EMISSAO,MsDecimais(1))
					Else
						nValMerc := xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,MsDecimais(1))
					Endif
				Else
					dbSelectArea("SF1")
				   	aAreaSF1 := SF1->(GetArea())
					SF1->(dbSetOrder(1))
					If lMsFil
						SF1->(MsSeek(xFilial("SF1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
					Else
						SF1->(MsSeek(xFilial("SF1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
					Endif
					If SF1->(Found())
						nValMerc := xMoeda(SF1->F1_VALMERC,SF1->F1_MOEDA,1,SE2->E2_EMISSAO,MsDecimais(1))
					Else
						nValMerc := xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,MsDecimais(1))
					Endif
				Endif

				If (SE2->E2_EMISSAO >= SA2->A2_CBUINI .And.  SE2->E2_EMISSAO <= SA2->A2_CBUFIM) .And. nValMerc >= nMinCBU
					aAdd(aRecnoCBU, aOrdPg[nI][4][nX])
				Else
					aAdd(aRecnoNCBU, aOrdPg[nI][4][nX])
				Endif
			Next nX

			If Len(aRecnoCBU) > 0
				aAdd(aNewOrdPg, { aOrdPg[nI][1], aOrdPg[nI][2], aOrdPg[nI][3], aRecnoCBU, .T., aOrdPg[nI][6]} )
			Endif

			If Len(aRecnoNCBU) > 0
				aAdd(aNewOrdPg, { aOrdPg[nI][1], aOrdPg[nI][2], aOrdPg[nI][3], aRecnoNCBU, .F., aOrdPg[nI][6]} )
			Endif
		Endif
	Endif
Next nI

//Remonta o array aOrdPg
If Len(aNewOrdPg) > 0
	aOrdPg := aNewOrdPg
Endif

RestArea(aAreaSA2)
RestArea(aAreaSE2)
If Len(aAreaSF2) > 0
	RestArea(aAreaSF2)
Endif
If Len(aAreaSF1) > 0
	RestArea(aAreaSF1)
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VldMD บAutor  ณMicrosiga           บFecha ณ  09/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VldMD(nOpc,cNatureza,cMod,nFMOD,lOPRotAut)
Local lRet			:= .T.
Local cPesquisa	:=""
Local cCalcITF   	:= SuperGetMv("MV_CALCITF",.F.,"2")

Default nFMOD :=0

lF850ObNat  := ExistBlock("F850ObNat")   

If lF850ObNat
	lRet:= ExecBlock("F850ObNat",.F.,.F.,{cNatureza})
Else
	cPesquisa	:=xFilial("SED")+PadR(cNatureza, TAMSX3("ED_CODIGO")[1])
	If nOpc	==	1 .and.	!Empty(cNatureza)
		SED->(DbSetOrder(1))
		If SED->(MsSeek(cPesquisa))
			cMod:= SED->ED_DESCRIC
			if cPaisLoc$"DOM|COS"
				If nFMOD==0
					lRet:= .T.
				Else
					If (cPaisLoc$"DOM|COS" .and. ALLTRIM(STR(nFMOD))==If(F850ACITF(cNatureza),"1","2"))
						lRet:= .T.
					Else
						If lOPRotAut
							If nFMOD==1
								cTxtRotAut += STR0213 //"Os Titulos selecionados incidem ITF, selecione uma Natureza com incidencia de ITF.")
							Else
								cTxtRotAut += STR0214 //"Os Titulos selecionados nใo incidem ITF, selecione uma Natureza sem incidencia de ITF.")
							Endif
							AutoGrLog(cTxtRotAut)
							lMsErroAuto := .F.
						Else
							If nFMOD==1
								MsgAlert(STR0213)
							Else
								MsgAlert(STR0214)
							Endif
						EndIf
						lRet:= .F.
					Endif
				Endif
			Endif
		Else
			If !Empty(cNatureza)
				If lOPRotAut
					AutoGrLog(STR0208)//"A natureza selecionada nao existe."
					lMsErroAuto := .F.
				Else
					MsgAlert(STR0208)
				EndIf
			Endif
			lRet :=	 .F.
		Endif
	Endif
	If (lRet .and. cPaisLoc$"DOM|COS" .and. Empty(cNatureza) .and. AllTrim(cCalcITF) == "1") .Or. ((IsInCallStack("SELPAGO")) .and. Empty(cNatureza))
		If lOPRotAut
			AutoGrLog(STR0218) //"O campo Natureza e obrigat๓rio!"
			lMsErroAuto := .F.
		Else
			MsgAlert(STR0218)
		EndIf
		lRet := .F.
	Endif

	//294 - Natureza sintetica/Analitica
	If lRet .and. !FinVldNat( .F., cNatureza )
		lRet := .F.
	Endif

	If lRet .and. !(ExistCpo("SED",cNatureza)) 
		lRet := .F.
	Endif

	If lRet .and. !(IsInCallStack("SELPAGO") )
		If lOPRotAut
			aPagos[1,H_NATUREZA] := cNatureza
		Else
			aPagos[oLbx:nAt,H_NATUREZA] := cNatureza
		Endif
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlRetCkPG  บAutor  ณMicrosiga           บFecha ณ  09/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function lRetCkPG(n,cDebInm,cBanco,nPagar,nVlrDOM)
Local lRetCx:=.T.

Default nVlrDOM := 0

If lF850ChS .and. nPagar==1
	nPagar++
Endif

If cPaisLoc$"DOM|COS"
   If Empty(cBanco) .and. nPagar<>4
      lRetCx:=.F.
   Endif
   If n==0
      If !Empty(cBanco) .and. cBanco $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")) .or. IsCaixaLoja(cBanco)
         If nPagar=3 .and. cDebInm="TF"
            lRetCx:=.F.
              MsgAlert(STR0215+cBanco+STR0216)
          Elseif nPagar=1 .or. nPagar=2
            lRetCx:=.F.
            MsgAlert(STR0215+cBanco+STR0217)
         Endif
      Else
        If !Empty(cBanco) .and.  nPagar=3 .and. cDebInm="EF"
           lRetCx:=.F.
			  MsgAlert(STR0215+cBanco+ STR0322 ) // " no recibe asientos del tipo EF."
        Endif
      Endif
     Elseif n==1
      If !Empty(cBanco) .and. cBanco $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
         If nPagar=3 .and. cDebInm="TF"
            lRetCx:=.F.
            MsgAlert(STR0215+cBanco+STR0216)
          Elseif nPagar=1 .or. nPagar=2
            lRetCx:=.F.
            If(cBanco $ GetMv("MV_CARTEIR"),lRetCx:=.F.,MsgAlert(STR0215+cBanco+STR0217))
         Endif
      Else
        If !Empty(cBanco) .and. nPagar=3 .and. cDebInm="EF"
           lRetCx:=.F.
			  MsgAlert(STR0215+cBanco+ STR0322 ) // " no recibe asientos del tipo EF."
        Endif
      Endif
     Elseif n==2
      If !Empty(cBanco) .and. cBanco $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
         If nPagar=2 .and. cDebInm="TF"
            lRetCx:=.F.
            MsgAlert(STR0215+cBanco+STR0216)
          Elseif nPagar=1
            lRetCx:=.F.
            MsgAlert(STR0215+cBanco+STR0217)
         Endif
      Else
        If !Empty(cBanco) .and. nPagar=3 .and. cDebInm="EF"
           lRetCx:=.F.
			  MsgAlert(STR0215+cBanco+ STR0322 ) // " no recibe asientos del tipo EF."
        Endif
      Endif
     Elseif n==3
      If cBanco $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
         lRetCx:=.F.
      Endif
   Endif
   If cPaisLoc$"DOM|COS" .and. n==0 .and. lRetCx //passa aqui tb no informar do pa
   	If nVlrDOM >= nFinLmCH .and. nPagar=3 .and. cDebInm="EF"
   		Help(" ",1,"HELP",STR0229,STR0230,1,0)//"F850 - LIMITE ITF","Pagamento disponivel apenas com Cheque ou Transfer๊ncia Bancแria."
         lRetCx:=.F.
      Endif
   Endif
Endif
Return(lRetCx)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850RetIR บAutor  ณMicrosiga           บFecha ณ  09/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850RetIR(nBase,cNat,lPA)
Local nLenIR	:= 0
Local nPercBas	:= 0
Local nBaseCalc	:= 0
Local cNatur	:= ""
Local aRetIR	:= {}
Local nBasIr := SED->ED_IRALIQ
Local lCalcIR:= .F.
Local nPosSE2	:= 0
Local nVlrPOP	:= 0

Default cNat	:= ""
Default nBase	:= 0
Default lPA		:= .F.

nPosSE2 := 0 //Ascan(aRecnoSE2,{|ase2| ase2[8] == aOrdPg[nI][4][nX]})
nVlrPOP := If(nPosSE2 > 0,aRecnoSE2[nPosSE2,9],0)

If cPaisLoc == "PER"
	If lPA
		cNatur := cNat
	Else
		cNatur := SE2->E2_NATUREZ
	Endif
	If !Empty(cNatur)
		If SED->(MsSeek(xFilial("SED") + cNatur))
			If SED->ED_IRALIQ <> 0
				If lPA
					nBaseCalc := Round(xMoeda(nBase,nMoedaCor,1,dDataBase,5,),MsDecimais(1))
				Else
					If nBase == 0
						If lShowPOrd
							nBaseCalc := Round(xMoeda(nVlrPOP,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1))
						Else
							If lBxParc .and. SE2->E2_VLBXPAR > 0 .And.  SE2->E2_VLBXPAR <= SE2->E2_SALDO
								nBaseCalc := Round(xMoeda(SE2->E2_VLBXPAR,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1))
							Else
								nBaseCalc := Round(xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1))
							Endif
						Endif
					Else
						nBaseCalc := Round(xMoeda(nBase,nMoedaCor,1,dDataBase,5,),MsDecimais(1))
					Endif
				Endif

				IF ExistBlock("F085ABIRF")
					nBasIr := ExecBlock("F085ABIRF",.f.,.f.)
					lCalcIR:= .T.  // Se existir o ponto de entrada nใo sera verificado o Minimo para calculo do IR
					IF valtype (nBasIr) <> "N"
						nBasIr := SED->ED_IRALIQ
					EndIF
				Else
					nBasIr 	:= SED->ED_IRALIQ
					If nBaseCalc >= SED->ED_VALMIN
						lCalcIR:= .T.
					EndIf
				EndIf

				If lCalcIR .and. nBasIr > 0 // So sera gerado registro de retencao se a aliquota for maior que zero.
					Aadd(aRetIR,array(11))
					nLenIR := Len(aRetIR)
					If SED->ED_BASELIQ > 0
						nPercBas := SED->ED_BASELIQ / 100
						nPercBas := Min(1,nPercBas)
						nBaseCalc := Round(nBaseCalc * nPercBas,MsDecimais(1))
					Endif

					aRetIR[nLenIR,01] := If(lPA,"",SE2->E2_NUM)
					aRetIR[nLenIR,02] := If(lPA,"PA",SE2->E2_PREFIXO)
					aRetIR[nLenIR,03] := nBaseCalc		//FE_VALBASE
					aRetIR[nLenIR,04] := Round((nBaseCalc * nBasIr / 100),MsDecimais(1))	//FE_VALIMP
					aRetIR[nLenIR,05] := nPercBas * 100
					aRetIR[nLenIR,06] := aRetIR[Len(aRetIR)][4]
					aRetIR[nLenIR,07] := nBaseCalc
					aRetIR[nLenIR,08] := dDataBase
					aRetIR[nLenIR,09] := SED->ED_IRALIQ
					aRetIR[nLenIR,10] := If(lPA," ",SE2->E2_TIPO)
					aRetIR[nLenIR,11] := SED->ED_VALMIN
				Endif
			Endif
		Endif
	Endif
Endif
Return(Aclone(aRetIR))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850AtuSFFบAutor  ณAna Paula           บ Data ณ  22/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChamada do assinante de certificado                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850AtuSFF(aCert,lIncPa)
Local nX:= 1
Local oDlg
Local oCodAss
Local oNome
Local lCertGn:= ExistBlock("CERTGAN")
Local lCertIb:= ExistBlock("CERTIB")
Local lCertIvSus:= ExistBlock("CERTIVSUS")
Local lCertrmun := ExistBlock("CERTRMUN")
Local nOpc := 0

Private cCodAss	:=	FIZ->FIZ_COD //Criavar("FIZ_COD")
Private cNome := FIZ->FIZ_NOME

Default lIncPa := .F.

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0204) FROM 178,181 TO 280,437 PIXEL //"Codigo do Diario"

@ 003,003 TO 038,125 LABEL "" PIXEL OF oDlg

@ 008,007 Say OemToAnsi(STR0205) Size 063,008 COLOR CLR_BLACK PIXEL OF oDlg //"Informe o codigo do diario"
@ 008,030 MSGET oCodAss VAR cCodAss VALID ExistCpo("FIZ",cCodAss) F3 "FIZ" SIZE 060,009 OF oDlg PIXEL HASBUTTON
@ 020,007 Say OemToAnsi(STR0206) Size 063,008 COLOR CLR_BLACK PIXEL OF oDlg //"Informe o codigo do diario"
@ 020,030 MSGET oNome VAR cNome When .F. Size 090,008 PIXEL OF oDlg //"Informe o codigo do diario"

Define SBUTTON FROM 040, 040 Type 1 ENABLE OF oDlg Action (nOpc := 1,oDlg:End())
Define SBUTTON FROM 040, 073 Type 2 ENABLE OF oDlg Action (nOpc := 0,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpc == 1

	For nX:= 1 To len(aCert)
		DbSelectArea("SFE")
		DbSetOrder(9)
		MsSeek(xFilial("SFE")+aCert[nX][1]+aCert[nX][2])
		Do while !SFE->(EOF()).And.SFE->FE_NROCERT==aCert[nX][1]
	 		RecLock("SFE",.F.)
	 		Replace SFE->FE_CODASS with cCodAss
			MsUnlock()
			SFE->(DBSKIP())
	 	EndDo
	  	If aCert[nX][2] $ "G" .And. lCertGn
	  		ExecBlock("CERTGAN",.F.,.F.,{aCert[nX],cCodAss})
		ElseIf aCert[nX][2] $ "I|S" .And. lCertIvSus
			ExecBlock("CERTIVSUS",.F.,.F.,{aCert[nX],cCodAss,lIncPa})
  		ElseIf aCert[nX][2] $ "B" .And. lCertIb
  			ExecBlock("CERTIB",.F.,.F.,{aCert[nX],cCodAss,lIncPa})
		ElseIf aCert[nX][2] $ "M" .And. lCertrmun
			ExecBlock("CERTRMUN",.F.,.F.,{aCert[nX],cCodAss,lIncPa})	
		EndIf
	Next

	aCert:= {}
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F850DtVenc  บAutor  ณ Jos้ Lucas     บ Data ณ  01/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validar a data de vencimento do cheque informado.          บฑฑ
ฑฑบ          ณ Obs: Redefinir no cliente se ้ permitido cheque com vencto บฑฑ
ฑฑบ          ณ      futura.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850DtVenc(dDataVenc)
Local aArea := GetArea()
Local lRet      := .T.
Local lF850DtV := ExistBlock("FA085DTV")

If lF850DtV
   lRet := ExecBlock("FA085DTV",.F.,.F.,{dDataVenc})
Else
	If (dDataVenc >= dDataBase)
   		lRet := .T.
   	Else
   		MsgAlert(STR0228,STR0223)
   		lRet := .F.
   	EndIf
EndIf
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  F850atuAbt บAutor  ณPaulo Leme         บ Data ณ  02/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Baixa de Abatimentos Localiza็๕es				          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850AtuAbt(cOrdPago)
Local aAreaAtu  := {}
Local cChaveSE2	:= ""
Local lImposto  := .F.
Local cChaveSFE := ""
Local cBco      := ""
Local cAge      := ""
Local cCta      := ""
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')
aAreaAtu 	:= GetArea()
cChaveSE2 	:= SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM

#IFDEF TOP
	EndFilBrw("SE2",aIndexADC)
#ENDIF


dbSelectArea("SE2")
SE2->(DbSetOrder(6))

If ( SE2->(MsSeek(cChaveSE2)))
  cChaveSE2 := xFilial("SE2")+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM

  While !SE2->(Eof()) .And. cChaveSE2 == xFilial("SE2")+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM

		If cPaisLoc $ "DOM|COS"
		    lImposto  := F850AbtImp(SE2->E2_NATUREZ, SE2->E2_TIPO)
  	    EndIf

  		If 	(SE2->E2_TIPO $ MVABATIM .Or. lImposto) .And. Empty(E2_BAIXA)
		    RecLock("SE2",.F.)
			Replace E2_SALDO		With 0
			Replace E2_BAIXA 		With dDataBase
			Replace E2_MOVIMEN 	With dDataBase
			Replace E2_ORDPAGO  	With cOrdpago
			SE2->(MsUnLock())
			//Atualiza SFE
			SEK->(DbSetOrder(1)) //EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM+EK_PARCELA+EK_TIPO+EK_SEQ
			SEK->(MsSeek(xFilial("SEK")+AvKey(cOrdpago,"EK_ORDPAGO")))
			Do while xFilial() == SEK->EK_FILIAL .And. AllTrim(cOrdpago)==SEK->EK_ORDPAGO .AND. SEK->(!EOF())
				If ALLTRIM(SEK->EK_TIPODOC) $ "CP"
					cBco      := SEK->EK_BANCO
					cAge      := SEK->EK_AGENCIA
					cCta      := SEK->EK_CONTA
				EndIf
				SEK->(DbSkip())
			Enddo
			SFE->(dbSetOrder(4))
			If SFE->(MsSeek(xFilial("SFE")+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_NUM+SE2->E2_PREFIXO))
				cChaveSFE := xFilial("SFE")+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_NUM+SE2->E2_PREFIXO
				While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+PadR(SFE->FE_SERIE,nTamSer) // ALVARO
					RecLock("SFE",.F.)
					If Empty(FE_ORDPAGO)
						FE_ORDPAGO  :=  cOrdpago
					EndIf
					FE_BANCO    :=	cBco
					FE_AGENCIA  :=	cAge
					FE_NUMCOM   := 	cCta
					SFE->(MsUnLock())
					SFE->(dbSkip())
				Enddo
			EndIf
  		EndIf
   		SE2->(dbSkip())
  EndDo
Endif

RestArea(aAreaAtu)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ F850VigSFH บ Autor ณ Gustavo Henrique บ Data ณ  18/02/11  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Faz a validacao de uma data com o periodo de vigencia      บฑฑ
ฑฑบ          ณ de Ingressos Brutos                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VigSFH( dData )

Local lRet := .F.

Default dData := dDataBase

If dData >= SFH->FH_INIVIGE
	lRet := .T.
EndIf

If lRet .And. !Empty( SFH->FH_FIMVIGE )
	lRet := ( dData <= SFH->FH_FIMVIGE )
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑ
ฑฑณFun…o	 ณ F850CITF ณ Autor ณ Wagner Montenegro	ณ Data ณ 11.05.11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณDescri…o ณ Verifica a Natureza possui configura็ใo c/ Aliquota de ITF  ณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณRetorno	 ณ L๓gico       											               ณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณUso		 ณ Localiza็ใo Rep. Dominicana                                 ณฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTIOn F850ACITF(cNatureza)
Local aAreaDOM 	:= GetArea()
Local nAliqITF		:= 0
Local lDomDtVld	:= .F.
FRM->(DbSetOrder(3))
If SED->ED_USO $ "24" .and. (FRM->(MsSeek(xFilial("FRM")+"ITF"+Space(TamSX3("FRM_SIGLA")[1]-3)+"1"+"2")) .OR. FRM->(MsSeek(xFilial("FRM")+"ITF"+Space(TamSX3("FRM_SIGLA")[1]-3)+"3"+"2"))) .or.;
 	SED->ED_USO $ "13" .and. (FRM->(MsSeek(xFilial("FRM")+"ITF"+Space(TamSX3("FRM_SIGLA")[1]-3)+"2"+"2")) .OR. FRM->(MsSeek(xFilial("FRM")+"ITF"+Space(TamSX3("FRM_SIGLA")[1]-3)+"3"+"2")))
 	While !FRM->(EOF()) .and. FRM->FRM_FILIAL==xFilial("FRM") .and. FRM->FRM_SIGLA==("ITF"+Space(TamSX3("FRM_SIGLA")[1]-3))
		If FRM->FRM_MSBLQL <> "1" .and. FRM->FRM_BLOQ <> "1" .and. FRM->FRM_SEQ <> "000" .and. (SED->ED_USO $ "24" .and. FRM->FRM_CARTEI $ "13" .or. SED->ED_USO $ "13" .and. FRM->FRM_CARTEI $ "23") .and. FRM->FRM_INIVIG <= dDataBase .and. FRM->FRM_FIMVIG >= dDataBase
	  		lDomDtVld:=.T.
	  		Exit
		Else
		   FRM->(DbSkip())
  		Endif
  	Enddo
   If lDomDtVld
      FRN->(DbSetOrder(2))
      If FRN->(MsSeek(xFilial("FRN")+SED->ED_CODIGO+FRM->FRM_COD+FRM->FRM_SEQ))
      	While !FRN->(EOF()) .and. FRN->FRN_FILIAL==xFilial("FRN") .AND. FRN->FRN_CODNAT==SED->ED_CODIGO .AND. FRN->FRN_IMPOST==FRM->FRM_COD .AND. FRN->FRN_SEQ==FRM->FRM_SEQ
      		If FRN->FRN_MSBLQL == "2"
      			If !Empty(FRN->FRN_CONCEP)
      				If CCR->(MsSeek(xFilial("CCR")+FRN->FRN_CONCEP))
      					If CCR->CCR_REDUC > 0
	      					nAliqITF := CCR->CCR_ALIQ - (CCR->CCR_ALIQ * (CCR->CCR_REDUC / 100))
      					Else
				      		nAliqITF := CCR->CCR_ALIQ / 100
				      	Endif
			      	Else
		      			nAliqITF := FRM->FRM_ALIQ / 100
		      		Endif
		      	Else
		      		nAliqITF := FRM->FRM_ALIQ / 100
		      	Endif
		      	lDomITF:=.T.
		      	Exit
		      Endif
		      FRN->(DbSkip())
		 	Enddo
		Endif
	Endif
Endif
RestArea(aAreaDOM)
Return(If(nAliqITF>0,.T.,.F.))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑ
ฑฑณFun…o	 ณ F850TOT ณ Autor ณ Wagner Montenegro	ณ Data ณ 11.05.11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณDescri…o ณ Verifica se valor de pagto ้ > que Limite p/ pgto em especieณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณRetorno	 ณ L๓gico       											               ณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณUso		 ณ Localiza็ใo Rep. Dominicana                                 ณฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTIOn F850TOT(aPgs)
Local lRet := .T.
Local nX
Local nSomaT:=0
For nX := 1 to Len(aPgs)
	nSomaT+=DesTrans(aPgs[nX,7])
Next
If nSomaT >= nFinLmCH
//	Help(" ",1,"HELP","F850 - LIMITE ITF","Pagamento disponivel apenas com Cheque ou Transfer๊ncia Bancแria.",1,0)
	lRet:=.F.
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑ
ฑฑณFun็ใo	 ณ fq850GetImposณ Autor ณ Jos้ Lucas		ณ Data ณ 15.05.11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณDescri…o ณ Retornar array com valor base, aliquota e imposto para as   ณฑ
ฑฑณ          ณ reten็๕es de IVA, ISRL เ partir dos valores gerados pela NF ณฑ
ฑฑณ          ณ de Compras.                                                 ณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณParametrosณ ExpC1 := Sigla da reten็ใo definida na tabela SFB-Impostos  ณฑ
ฑฑณ          ณ          Exemplo: "RV", "RIR"                               ณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณRetorno	 ณ ExpA1 {Valor Base,Aliquota,Valor do Imposto}				   ณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณUso		 ณ Localiza็ใo Venezuela                                       ณฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850GetImpos(cSiglaImp,cAlias)
LOCAL aSavArea  := GetArea()
LOCAL aImposto  := {0.00,0.00,0.00}
LOCAL cCpoVBase := ""
LOCAL cCpoImpos := ""
LOCAL nValBase  := 0.00
LOCAL nValImpos := 0.00

SFB->(dbSetOrder(1))
If SFB->(MsSeek(xFilial("SFB")+cSiglaImp))
	While SFB->(!Eof()) .and. SFB->FB_FILIAL == xFilial("SFB") .and. AllTrim(cSiglaImp) $ SFB->FB_CODIGO
		If cAlias == "SD1"
			cCpoVBase := "SD1->D1_BASIMP"+AllTrim(SFB->FB_CPOLVRO)
   			cCpoImpos := "SD1->D1_VALIMP"+AllTrim(SFB->FB_CPOLVRO)
   		Else
			cCpoVBase := "SD2->D2_BASIMP"+AllTrim(SFB->FB_CPOLVRO)
   			cCpoImpos := "SD2->D2_VALIMP"+AllTrim(SFB->FB_CPOLVRO)
   		EndIF
   		nValBase  := &(cCpoVBase)
        nValImpos := &(cCpoImpos)
        If nValImpos > 0
        	aImposto[1] := nValBase
        	aImposto[2] := SFB->FB_ALIQ
			aImposto[3] := nValImpos
		EndIf
		SFB->(dbSkip())
	End
EndIf
RestArea(aSavArea)
Return aImposto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑ
ฑฑณFun็ใo	 ณ F850GetConceptณ Autor ณ Jos้ Lucas		ณ Data ณ 15.05.11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณDescri…o ณ Retornar o codigo do conceito de reten็ใo de ISRL เ partir  ณฑ
ฑฑณ          ณ do campo D1_CONCEPT do item da NF de Compras.               ณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณParametrosณ ExpC1 := Numero da Nota Fiscal                              ณฑ
ฑฑณ          ณ ExpC2 := Serie da Nota Fiscal                               ณฑ
ฑฑณ          ณ ExpC3 := C๓digo do Fornecedor                               ณฑ
ฑฑณ          ณ ExpC4 := Loja do Fornecedor                                 ณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณRetorno	 ณ ExpC5 := Conceito                        				   ณฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑ
ฑฑณUso		 ณ Localiza็ใo Venezuela                                       ณฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850GetConcept(cNFiscal,cSerie,cFornece,cLoja)
LOCAL aSavArea  := GetArea()
LOCAL cConceito := ""

SD1->(dbSetOrder(1))
If SD1->(MsSeek(xFilial("SD1")+cNFiscal+cSerie+cFornece+cLoja))
	While SD1->(!Eof()) .and. SD1->D1_FILIAL == xFilial("SD1") .and.;
		  SD1->D1_DOC == cNFiscal .and. SD1->D1_SERIE == cSerie .and. SD1->D1_FORNECE == cFornece .and. SD1->D1_LOJA == cLoja
		If !Empty(SD1->D1_CONCEPT)
			cConceito := SD1->D1_CONCEPT
		EndIf
		SD1->(dbSkip())
	End
EndIf
RestArea(aSavArea)
Return cConceito
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ F850GerRet บ Autor ณ Paulo Leme       บ Data ณ  05/04/11  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ //Gera็ใo das Reten็๕es de Impostos  - Republica Dominicanaบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850GerRet(cFatoGer, cNatur, nValor, cPrefixo, nNum, cFornec)

/* Gera็ใo das Reten็๕es de Impostos - Republica Dominicana */
/* Function fa050CalcRet(cCarteira, cFatoGerador)           */
/* 1-Contas a Pagar ou 3-Ambos e Fato Gerador 2-Baixa       */
//	fa050CalcRet("'1|3'", "9", "S")
fa050CalcRet("'1|3'", cFatoGer, cNatur, nValor, cPrefixo, nNum, cFornec, .T., cOrdPago)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  F850PesAbt  บAutor  ณPaulo Leme         บ Data ณ  05/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pesquisa de Abatimentos Localiza็๕es				          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850PesAbt()
Local aAreaAtu  := {}
Local aAreaSe2  := {}
Local cChaveSE2	:= ""
Local cFiltAux	:= ""
Local nVlrRet 	:= 0
Local lImposto  := .F.

aAreaAtu 	:= GetArea()
aAreaSe2 	:= SE2->(GetArea())
cChaveSE2 	:= SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM

#IFDEF TOP
	cFiltAux		:=	DbFilter()
	DbClearFilter()
#ENDIF


dbSelectArea("SE2")
SE2->(DbSetOrder(6))
lRet := .F.
If ( SE2->(MsSeek(cChaveSE2)))
  While !SE2->(Eof()) .And. cChaveSE2 == xFilial("SE2")+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
  	    If cPaisLoc $ "DOM|COS"
		    lImposto  := F850AbtImp(SE2->E2_NATUREZ, SE2->E2_TIPO)
  	    EndIf

  		If 	SE2->E2_TIPO $ MVABATIM .Or. lImposto
  			nVlrRet += SE2->E2_VALOR
  		EndIf
		SE2->(dbSkip())
  		Loop
  EndDo
Endif
#IFDEF TOP
	SET FILTER TO &cFiltAux
#ENDIF
RestArea(aAreaSe2)
RestArea(aAreaAtu)

Return nVlrRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  F850AbtImp บAutor  ณPaulo Leme          บ Data ณ  05/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  IDENTIFICA IMPOSTO - ITBIS - ISR - REP DOM                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850AbtImp(cNatur, cTipo)
Local lRet := .F.
FRN->( DbSetOrder(2) )
If 	FRN->( MsSeek(xFilial("FRN") + cNatur ) )
	FRM->( DbSetOrder(2) )
	If FRM->( MsSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ ) )
	   If FRM->FRM_APLICA == "1"
	      lRet := .T.
	   EndIf
	EndIf
EndIf
If cPaisLoc $ "DOM|COS" .And. !cTipo $ "IT |ISR|IR"
   lRet := .F.
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  F850DelAbt  บAutor  ณPaulo Leme         บ Data ณ  25/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Deleta Abatimentos Localiza็๕es				          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850DelAbt(cChaveSE2)
Local aAreaAtu  := {}
Local cFiltAux	:= ""
Local nVlrRet 	:= 0
Local lImposto  := .F.
Local nI:=1

aAreaAtu 	:= GetArea()
//cChaveSE2 	:= SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM

dbSelectArea("SE2")
#IFDEF TOP
	cFiltAux		:=	DbFilter()
	SET FILTER TO
	DbClearFilter()
#ENDIF

SE2->(DbSetOrder(6))

lRet := .F.
If (SE2->(MsSeek(cChaveSE2)))
  While !SE2->(Eof()) .And. cChaveSE2 == xFilial("SE2")+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
  	    If cPaisLoc $ "DOM|COS"
		    lImposto  := F850AbtImp(SE2->E2_NATUREZ, SE2->E2_TIPO)
  	    EndIf

  		If 	SE2->E2_TIPO $ MVABATIM .Or. lImposto
		   	RecLock("SE2")
			SE2->(DbDelete())
			MsUnlock()
  		EndIf
		SE2->(dbSkip())
		Loop
  EndDo
Endif
#IFDEF TOP
	SET FILTER TO &cFiltAux
#ENDIF

If Len(aDoc3osUtil) > 0

	For nI:=1 to Len(aDoc3osUtil)
		SE1->(DbGoto(aDoc3osUtil[nI] ) )
		RecLock("SE1",.F.)
		Replace SE1->E1_OK With ""
		MsUnLock()
	Next(nI)

EndIf

RestArea(aAreaAtu)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  F850FatGer  บAutor  ณPaulo Leme         บ Data ณ  25/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Identifica Fato Gerador da Reten็ใo 1-Emissao ou 2-Baixa  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINF850                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850FatGer(cNatur)
Local cFatGer := "1"

FRN->( DbSetOrder(2) )
If 	FRN->( MsSeek( xFilial("FRN") + cNatur ) )
	While 	!FRN->( Eof() ) .And. FRN->(xFilial("FRN") + FRN_CODNAT) 	== 	xFilial('FRN') 	+ cNatur
		If 	FRN->FRN_MSBLQL	<>	'1'
			FRM->( DbSetOrder(2) )
			FRM->( MsSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ ) )
			While 	!FRM->( Eof() ) .And. FRM->(xFilial("FRM") + FRM->FRM_COD + FRM->FRM_SEQ) 	== 	xFilial('FRM') 	+ FRN->FRN_IMPOST + FRN->FRN_SEQ
				//1-Contas a Pagar ou 3-Ambos e Fato Gerador 2-Emissao.
			    If 	FRM->FRM_CARTEI	   	$ 	"1|3"
					cFatGer	:= FRM->FRM_FATGER
					Exit
				EndIf
				FRM->( DbSkip() )
			EndDo
		EndIf
		If 	cFatGer	<> " "
			Exit
		EndIf
		FRN->( DbSkip() )
	EndDo
EndIf
Return cFatGer

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ F850Cheques ณ Autor ณ Jose Lucas       ณ Data ณ 08/08/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Preencher matriz dos cheques de terceiros disponiveis para ณฑฑ
ฑฑณ          ณ posterior sele็ใo na fun็ใo MsSelect().                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ExpA := F850Cheques()			                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpA := Array com cheques de terceiros disponiveis.	      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINF850                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function F850GrvSEF()
Local aSavArea   := GetArea()
Local cQuery     := ""
Local cTipo      := IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)
Local aTamSaldo  := TamSX3("E1_SALDO")

cTipo := StrTran(cTipo,"|","','")

If Select("QRYCHQ") > 0
	QRYCHQ->(dbCloseArea())
EndIf
cQuery := ""
cQuery += "SELECT DISTINCT "
cQuery += "E1_SITUACA, "
cQuery += "E1_PREFIXO, "
cQuery += "E1_NUM, "
cQuery += "E1_PARCELA, "
cQuery += "E1_CLIENTE, "
cQuery += "E1_LOJA, "
cQuery += "E1_SALDO, "
cQuery += "E1_MOEDA, "
cQuery += "E1_EMISSAO, "
cQuery += "E1_VENCTO, "
cQuery += "E1_TIPO "
cQuery += " FROM "
cQuery += RetSqlName("SE1") + " SE1 ,"
cQuery += RetSqlName("SEL") + " SEL "
cQuery += " WHERE "
cQuery += " SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += " AND SEL.EL_FILIAL = '"+xFilial("SEL")+"' "
cQuery += " AND SE1.E1_PREFIXO = SEL.EL_PREFIXO "
cQuery += " AND SE1.E1_NUM = SEL.EL_NUMERO "
cQuery += " AND SE1.E1_PARCELA = SEL.EL_PARCELA "
cQuery += " AND SE1.E1_TIPO = SEL.EL_TIPO "
cQuery += " AND SE1.E1_CLIENTE = SEL.EL_CLIENTE "
cQuery += " AND SE1.E1_LOJA = SEL.EL_LOJA "
cQuery += " AND SE1.E1_TIPO IN ('"+cTipo+"')"
cQuery += " AND SE1.E1_SITUACA IN (' ','0','1')
cQuery += " AND SE1.E1_SALDO > 0 "
cQuery += " AND SEL.EL_TERCEIR <> '2' "
cQuery += " AND SE1.D_E_L_E_T_ <> '*' "
cQuery += " AND SEL.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY E1_VENCTO, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE,E1_LOJA "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRYCHQ",.T.,.F.)

TcSetField("QRYCHQ","E1_EMISSAO"  ,"D",08,0)
TcSetField("QRYCHQ","E1_VENCTO"   ,"D",08,0)
TcSetField("QRYCHQ","VENCTOREAL"  ,"D",08,0)
TcSetField("QRYCHQ","E1_SALDO"    ,"N",aTamSaldo[1],aTamSaldo[2])

QRYCHQ->(dbGoTop())

While QRYCHQ->(!Eof())
	RecLock("SEF",.T.)
	EF_FILIAL  := xFilial("SEF")
	EF_PREFIXO := QRYCHQ->E1_PREFIXO
	EF_NUM 	   := QRYCHQ->E1_NUM
	EF_PARCELA := QRYCHQ->E1_PARCELA
	EF_VALOR   := QRYCHQ->E1_SALDO
	EF_DATA	   := QRYCHQ->E1_EMISSAO
	EF_VENCTO  := QRYCHQ->E1_VENCTO
	EF_TIPO    := QRYCHQ->E1_TIPO
	EF_CLIENTE := QRYCHQ->E1_CLIENTE
	EF_LOJA    := QRYCHQ->E1_LOJA
	EF_STATUS  := "01"
	EF_CART    := "R"
	MsUnLock()
	QRYCHQ->(dbSkip())
End

RestArea(aSavArea)
Return


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณF850FilDT ณ Autor ณ Jose Lucas            ณ Data ณ 09/08/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Filtrar os documentos de Terceiros.						  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ F850FilDT()			    		                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ 														      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINF850                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function F850FilDT(cCliente,cLojaCli,cTipo,lPA)
Local cQuery		:= ""
Local cAliasSE1		:= ""
Local cCpo			:= ""
Local cRegSE1		:= ""
Local nPosTipo		:= 0
Local cTipoCh		:= ""
Local cFilFRF		:= ""
Local cEndosso		:= ""
Local cForn			:= ""
Local cLojaF		:= ""
Local nPosVenc		:= 0
Local nPosVlr		:= 0
Local nPosMoeda		:= 0
Local nDocs			:= 0
Local nCpo			:= 0
Local nLen3os		:= 0
Local nLenDoc		:= 0
Local nLenACols		:= 0
Local nLenDoc1		:= 0
Local nX			:= 0
Local lSelecao		:= .F.
Local lEndosso		:= .T.
Local lCtrlCheck	:= cPaisLoc $ "ANG/ARG/AUS/COS/DOM/EQU/EUA/HAI/PAD/PAN/POR/SAL/TRI"
Local aArea			:= {}
Local aDoc3os		:= {}
Local aCols3os		:= {}
Local oDlg3os
Local oBrw3os
Local oOk			:= LoadBitMap(GetResources(), "LBOK")
Local oNo			:= LoadBitMap(GetResources(), "LBNO")
Local cPergunte 	:= "FIN850A"
Local cOrderBy		:= ""
Local nMoedaArg		:= 1
Local nPosSaldo		:= 0
Local nPosMArg		:= 0
Local lIncluiReg    := .F.
Local oDocSelTer    := Nil
Local nDocSelTer	:= 0
Local oPnlTot		:= Nil
Local nMoedaSele	:= 0
Local aAreaFJS		:= {}
Local cTabFJS		:= ""
Local cTabSEL		:= RetSqlName("SEL")
Local lTabFJS		:= .T.
Local cFilFJS		:= XFILIAL("FJS")
Local cQryFJS		:= ""
Local cAlsFJS		:= ""
Local cTxtFJS		:= ""
Local lNoTerc		:= .F.
Local nPosPrefix	:= aScan(oGetDad2:aHeader,{ |aCpo| AllTrim(aCpo[2]) == "E1_PREFIXO" })
Local nPosNumero	:= aScan(oGetDad2:aHeader,{ |aCpo| AllTrim(aCpo[2]) == "E1_NUM" })
Local nPosParcel	:= aScan(oGetDad2:aHeader,{ |aCpo| AllTrim(aCpo[2]) == "E1_PARCELA" })
Local nPosClient	:= aScan(oGetDad2:aHeader,{ |aCpo| AllTrim(aCpo[2]) == "E1_CLIENTE" })
Local nPosLoja		:= aScan(oGetDad2:aHeader,{ |aCpo| AllTrim(aCpo[2]) == "E1_LOJA" })
Local lDicEndossa	:= .F.
Local lUsaCmc7		:= SuperGetMv("MV_CMC7FIN") == "S"
Local aCheque		:= {}
Local lJaUsado	 	:= .F.
Local cOrderQry  := ""
Local lF850FilCh  := ExistBlock('F850FILCH')
Local aDoF850		:=	{}

Default cCliente	:= ""
Default cLojaCli	:= ""
Default cTipo		:= "*"
Default lPA			:= .F.

DbSelectArea("SEL")
lDicEndossa := .T.

oOk := LoadBitMap(GetResources(),"LBOK")
oNo := LoadBitMap(GetResources(),"LBNO")
aArea := GetArea()
/*_*/
If lPA
	cForn := cFornece
	cLojaF := cLoja
Else
	cForn 	:= aPagos[oLbx:nAt,H_FORNECE]
	cLojaF := aPagos[oLbx:nAt,H_LOJA]
Endif
/*
Verifica as formas de pagamento correspondentes a cheques*/
cTipoCh := ""
For nX := 1 To Len(aFormasPgto)
	If aFormasPgto[nx,2] == "CH"
		If !Empty(cTipoCh)
			cTipoCh += ","
		Endif
		cTipoCh += "'" + aFormasPgto[nX,1] + "'"
	Endif
Next
/*
verifica se o fornecedor da op aceita documentos de terceiros */
lSelecao := .T.
If !Empty(cTipoCh)
	If cTipo $ cTipoCh .OR. cTipo == "*"
		If cPaisLoc <> "BRA"
			cEndosso := Posicione("SA2",1,xFilial("SA2") + cForn + cLojaF,"A2_ENDOSSO")
			If cEndosso <> "1"
				MsgAlert(STR0291 + ".",STR0223)//"O fornecedor desta OP nใo aceita cheques de terceiros"
				lSelecao := .F.
			Endif
		Endif
	EndIf
Endif

//Ajuste para valida็ใo do tipo interno de cheque
If !Empty(cTipoCh)
	cTipoCh += ","
EndIf

cTipoCh += "'"+ MVCHEQUE +"'"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Requisitos Entidades Bancarias - Julho de 2012 ณ
//ณ O Pergunte eh alterado para FIN850B            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  If cPaisLoc == "ARG"
     cPergunte := "FIN850B"
     /*
     +-Preguntas---------------------------------+
     ฆ  Mv_par10    ฟConsidera Abaixo ?          ฆ
     ฆ  Mv_par11    ฟBanco Cheque ?              ฆ
     ฆ  Mv_par12    ฟAgencia Cheque ?            ฆ
     ฆ  Mv_par13    ฟConta Cheque ?              ฆ
     ฆ  Mv_par14    ฟCodigo Postal ?             ฆ
     +-------------------------------------------+
     */
  EndIf
//ฺฤฤฤฤฤฤฤฟ
//ณ F I M ณ
//ภฤฤฤฤฤฤฤู

/*
+-Preguntas---------------------------------+
ฆ  Mv_par01    ฟModo de Pago                ฆ
ฆ  Mv_par02    ฟMoneda                      ฆ
ฆ  Mv_par03    ฟValor Inicial               ฆ
ฆ  Mv_par04    ฟValor Final                 ฆ
ฆ  Mv_par05    ฟCliente                     ฆ
ฆ  Mv_par06    ฟLoja                        ฆ
ฆ  Mv_par07    ฟDocumento                   ฆ
ฆ  Mv_par08    ฟDel Vencimiento             ฆ
ฆ  Mv_par09    ฟHasta Vencimiento           ฆ
+-------------------------------------------+
*/
If lUsaCmc7 .and. cPaisloc == "ARG" .and. MsgYesNo(STR0388,STR0387)		//"Deseja utilizar a leitora de cheques?"###"Leitura de cheques"

	While .T.
		aCheque := FinCmc7Tc(.F.)
		lJaUsado := .F.
		If Len(aCheque) > 0
			//Localizo o CHEQUE no SEF
			SEF->(dbSetorder(6))//EF_FILIAL+EF_CART+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO
			If SEF->(MsSeek(xFilial("SEF")+"R"+aCheque[1]+aCheque[2]+aCheque[5]+aCheque[4])) .and. SEF->EF_ENDOSSA == "1"
				//Localizo o TITULO no SE1
				SE1->(DbSetOrder(2))
				If SE1->(MsSeek(xFilial("SE1")+SEF->(EF_CLIENTE+EF_LOJACLI+EF_PREFIXO+EF_NUM+EF_PARCELA+EF_TIPO)))
					//Valido se o titulo pode ser selecionado
					If SE1->E1_SALDO > 0 .AND. SE1->E1_SITUACA $ " /1/0" .AND. Empty(SE1->E1_NUMBOR) .AND. !(SE1->E1_TIPO $ "NCC/NDC/NCI/NCE")

						//Tento travar o registro
						If SE1->(MsRlock())

							//Verifico se o cheque ja foi utilizado em leitura anterior
							If aScan(oGetDad2:aCols,{ |aDocTerc| SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_CLIENTE+E1_LOJA == aDocTerc[nPosPrefix]+aDocTerc[nPosNumero]+aDocTerc[nPosParcel]+aDocTerc[nPosClient]+aDocTerc[nPosLoja]) } ) > 0
								lJaUsado := .T.
							EndIf

							If aScan(aDoc3os,{ |aDocTerc| SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_CLIENTE+E1_LOJA == aDocTerc[nPosPrefix+1]+aDocTerc[nPosNumero+1]+aDocTerc[nPosParcel+1]+aDocTerc[nPosClient+1]+aDocTerc[nPosLoja+1]) } ) > 0
								lJaUsado := .T.
							EndIf

							If !lJaUsado
								Aadd(aDoc3os,{})
								nLenDoc := Len(aDoc3os)
								Aadd(aDoc3os[nLenDoc],.F.)
								nLen3os := Len(oGetDad2:aHeader)
								For nCpo := 1 To nLen3os
									cCpo := oGetDad2:aHeader[nCpo,2]
									Aadd(aDoc3os[nLenDoc],SE1->&(cCpo))
									Do Case
										Case AllTrim(oGetDad2:aHeader[nCpo,2]) == "E1_SALDO"
											nPosVlr := nCpo
										Case AllTrim(oGetDad2:aHeader[nCpo,2]) == "E1_MOEDA"
											nPosMoeda := nCpo
										Case AllTrim(oGetDad2:aHeader[nCpo,2]) == "E1_VENCREA"
											nPosVenc := nCpo
										Case AllTrim(oGetDad2:aHeader[nCpo,2]) == "E1_TIPO"
											nPosTipo := nCpo
									EndCase
								Next
								Aadd(aDoc3os[nLenDoc],SE1->(RECNO()))
								Aadd(aDoc3os[nLenDoc],SEF->(RECNO()))
								nLenDoc1 := Len(aDoc3os[1])
								lSelecao := .T.
								F850VldDoc3o(@aDoc3os,nLenDoc,nPosTipo+1,nPosVenc+1,@nDocSelTer,,SE1->E1_MOEDA)
							Else
									Help(" ",1,"A850LCUSADO",,STR0381+CRLF+STR0382,1,0) //"Este cheque ja foi utilizado anteriormente neste processo."###"Por favor, verifique a situa็ใo do cheque"
							Endif
						Else
							Help(" ",1,"A850LCUSD",,STR0383,1,0)		//"Este cheque nใo pode ser utilizado pois esta sendo utilizado em outro terminal"
						Endif
					Else
						Help(" ",1,"A850LCSIT",,STR0384+CRLF+STR0382,1,0)		//"Este cheque nใo pode ser utilizado."###"Por favor, verifique a situa็ใo do cheque"
					Endif
				Else
					Help(" ",1,"A850LCTIT",,STR0384+CRLF+STR0382,1,0)			//"Este cheque nใo pode ser utilizado."###"Por favor, verifique a situa็ใo do cheque"
				Endif
			Else
				Help(" ",1,"A850LCCHQ",,STR0385+CRLF+STR0382,1,0)		//"O cheque nใo foi encontrado ou nใo recebeu endosso."###"Por favor, verifique a situa็ใo do cheque"
			Endif
		Endif

		If !MsgYesNo(STR0386,STR0387)		//"Deseja realizar nova leitura de cheque?"###"Leitura de cheques"
			Exit
		Endif
	EndDo

Else
	If ExistBlock("F850CHPDT")
		aDoF850	:=	ExecBlock("F850CHPDT",.F.,.F.)
		aDoc3os	:= aDoF850[2]
	Else
		If lSelecao
			If !Pergunte(cPergunte,.T.)
				Return nil
			EndIf
			
			If  cPaisLoc == "ARG" .And. IsInCallStack("F850PgAdi")  .And. lPA .And. !lSolicFundo
				If  Empty(MV_PAR02) .Or. MV_PAR02 != nMoedaTCor 
					Aviso( OemToAnsi(STR0223), OemToAnsi(STR0446) , {'Ok'} )  //"Moneda del banco diferente a la informada."
					Return Nil
				Endif
			Endif	
	
			If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
				If MV_PAR03 > MV_PAR04
					MsgAlert(STR0346) // "O valor final nใo pode ser menor que o valor inicial."
					Return Nil
				EndIf
			EndIf
			If !Empty(MV_PAR08) .AND. !Empty(MV_PAR09)
				If MV_PAR08 > MV_PAR09
					MsgAlert(STR0347) // "O vencimento final nใo pode ser menor que o vencimento inicial."
					Return Nil
				EndIf
			EndIf
	
			//Valida se a moeda selecionada eh diferente da solicitacao de fundo
			If lPA
				If ValType(cSolFun) == "C" .And. !Empty(cSolFun)
					If StrZero(MV_PAR02,TAMSX3('FJA_MOEDA')[1]) != GetAdvFVal("FJA","FJA_MOEDA",xFilial("FJA")+cSolFun,4,"",.T.)
						MsgAlert(STR0345) //"Moeda selecionada diferente da moeda da solicita็ใo."
						Return Nil
					EndIf
				EndIf
			EndIf
	
			If lTabFJS
				DbSelectArea("FJS")
				aAreaFJS := FJS->(GetArea())
				cTabFJS := RetSqlName("FJS")
	
				/*
				 * Busca dos tipos internos contidos na tabela Modo de pago para filtro dos tํtulos a receber
				 */
				cQryFJS := " SELECT "
				cQryFJS += " 	FJS.FJS_TIPOIN "
				cQryFJS += " FROM " + cTabFJS + " FJS "
				cQryFJS += " WHERE "
				cQryFJS += "	" + RetSqlCond("FJS")
				cQryFJS += " AND (FJS.FJS_TERCEI = '2' OR  FJS.FJS_TERCEI = '3')"
				cQryFJS += " GROUP BY FJS.FJS_TIPOIN "
				cQryFJS += " ORDER BY FJS.FJS_TIPOIN "
				cQryFJS := ChangeQuery(cQryFJS)
	
				cAlsFJS := GetNextAlias()
	
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryFJS),cAlsFJS, .T., .T.)
	
				While (cAlsFJS)->(!Eof())
					If EMPTY(cTxtFJS)
						cTxtFJS := " '" + (cAlsFJS)->FJS_TIPOIN + "' "
					Else
						cTxtFJS += ", '" + (cAlsFJS)->FJS_TIPOIN + "' "
					EndIf
					(cAlsFJS)->(DbSkip())
				EndDo
	
				//Atribui vazio aos tipos que aceitam documento de terceiro
				//-- acerto para Query, caso nใo haja nenhum Modo de Pago que aceite doc. de terceiros
				If Empty(cTxtFJS)
					cTxtFJS := "''"
				EndIf
	
				(cAlsFJS)->(DbCloseArea())
				RestArea(aAreaFJS)
			EndIf
	
			/*
			Verificar os documentos ja incluidos na lista de documentos de terceiros para que sejam desconsiderados na query*/
			nLen3os := Len(aDoc3osUtil)
			cRegSE1 := ""
			If nLen3os > 0
				For nDocs := 1 To nLen3os
					If nDocs > 1
						cRegSE1 += ","
					Endif
					cRegSE1 += AllTrim(Str(aDoc3osUtil[nDocs]))
				Next
			Endif
			nLen3os := Len(oGetDad2:aHeader)
			cQuery := "select SE1.R_E_C_N_O_ REGSE1"
			For nCpo := 1 To nLen3os
				cQuery += ","
				cQuery += oGetDad2:aHeader[nCpo,2]
				Do Case
					Case AllTrim(oGetDad2:aHeader[nCpo,2]) == "E1_SALDO"
						nPosVlr := nCpo
					Case AllTrim(oGetDad2:aHeader[nCpo,2]) == "E1_MOEDA"
						nPosMoeda := nCpo
					Case AllTrim(oGetDad2:aHeader[nCpo,2]) == "E1_VENCREA"
						nPosVenc := nCpo
					Case AllTrim(oGetDad2:aHeader[nCpo,2]) == "E1_TIPO"
						nPosTipo := nCpo
				EndCase
			Next
			cQuery += ", SE1.E1_ORIGEM" //Inclui a origem para validar registros Recibo X Movimento Bancแrio
			lCtrlCheck := cPaisLoc $ "ANG/ARG/AUS/COS/DOM/EQU/EUA/HAI/PAD/PAN/PAR/POR/SAL/TRI"
			If lCtrlCheck
				cQuery += ",EF_BANCO,EF_AGENCIA,EF_CONTA,EF_CART,EF_TERCEIR,EF_ENDOSSA,SEF.R_E_C_N_O_ REGSEF"
				If lDicEndossa
					cQuery += ",SEL.EL_ENDOSSA, SEL.EL_TERCEIR "
				EndIf
				cQuery += ",EL_VERSAO, EL_RECIBO "
			Endif
			cQuery += " from " + RetSqlName("SE1") + " SE1"
			If lCtrlCheck
				cQuery += " LEFT JOIN " + cTabSEL + " SEL "
				cQuery += " ON SEL.EL_PREFIXO = SE1.E1_PREFIXO AND SEL.EL_NUMERO = SE1.E1_NUM AND SEL.EL_PARCELA = SE1.E1_PARCELA "
				cQuery += " AND SEL.EL_CLIENTE = SE1.E1_CLIENTE AND SEL.EL_LOJA = SE1.E1_LOJA AND SEL.EL_CANCEL != 'T' AND SEL.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN " + RetSqlName("SEF") + " SEF"
				cQuery += " on (SEF.EF_FILIAL = '"+xFilial("SEF")+"' "
				cQuery += " and SE1.E1_PREFIXO = SEF.EF_PREFIXO"
				cQuery += " and SE1.E1_NUM = SEF.EF_NUM"
				cQuery += " and SE1.E1_PARCELA = SEF.EF_PARCELA"
				cQuery += " and SE1.E1_TIPO = SEF.EF_TIPO"
				cQuery += " and SEF.EF_TIPO in ("+ cTipoCh +")"
				cQuery += " and SE1.E1_CLIENTE = SEF.EF_CLIENTE"
				cQuery += " and SEF.EF_CART = 'R'"
				cQuery += " and SEF.EF_ENDOSSA = '1'"
				cQuery += " and SEF.EF_STATUS = '01') "
				cQuery += " AND SEF.D_E_L_E_T_ = ' '"
			Endif
			cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
	
			cOrderBy := ""
			If Empty(MV_PAR01) .And. Empty(MV_PAR02) .And. Empty(MV_PAR03) .And. Empty(MV_PAR04) .And. Empty(MV_PAR05) .And. Empty(MV_PAR06) .And. Empty(MV_PAR07) .And. Empty(MV_PAR08)
				cOrderBy :=  "E1_SALDO DESC,E1_VENCREA"
			EndIf
	
			/*
			Verificar os documentos ja incluidos na lista de documentos de terceiros para que sejam desconsiderados na query*/
			If !Empty(cRegSE1)
				cQuery += " and SE1.R_E_C_N_O_ not in (" + cRegSE1 + ")"
			Endif
	
			/*_*/
	
			//Verifica Parโmetros
			If !Empty(MV_PAR01) //Forma de Pagamento (Tipo de Documento )
				DbSelectArea("FJS")
				If FJS->(MsSeek(cFilFJS + PadR(MV_PAR01,TamSX3("E1_TIPO")[1]) ))
					If (FJS->FJS_TERCEI = '2' .Or.  FJS->FJS_TERCEI = '3')
						cQuery 	+= " AND E1_TIPO = '" + PadR(FJS->FJS_TIPOIN,Len(SE1->E1_TIPO)) + "'"
					Else
						cQuery 	+= " AND SE1.E1_TIPO IN ('')" //Invalida o Modo de Pago para que nใo sejam exibidos docs.
						lNoTerc := .T.
					EndIf
					cOrderBy 	+=  IIf(Len(cOrderBy) > 0,",","")  + "E1_TIPO"
				EndIf
			Else
				If lTabFJS
					cQuery 		+= " AND SE1.E1_TIPO IN (" + cTxtFJS + ") "
					cOrderBy 	+=  IIf(Len(cOrderBy) > 0,",","")  + "E1_TIPO"
				EndIf
			EndIf
	
			If !Empty(MV_PAR02)//Moeda
				nMoedaSele := MV_PAR02
				cOrderBy +=  IIf(Len(cOrderBy) > 0,",","") +  "E1_MOEDA"
			Else
				nMoedaSele := 1
			EndIf
			If !Empty(MV_PAR03)
				//cQuery += " and E1_SALDO >= " +  xMoeda(MV_PAR03,nMoedaArg,1,dDataBase)
				cOrderBy +=  IIf(Len(cOrderBy) > 0,",","") +  "E1_SALDO"
			EndIf
			If !Empty(MV_PAR04)
				//cQuery += " and E1_SALDO <== " +  xMoeda(MV_PAR04,nMoedaArg,1,dDataBase)
				If Empty(MV_PAR03)
					cOrderBy +=  IIf(Len(cOrderBy) > 0,",","") +  "E1_SALDO"
				EndIf
			EndIf
			If !Empty(MV_PAR05)
				cQuery += " and E1_CLIENTE = '" + MV_PAR05 + "'"
			EndIf
			If !Empty(MV_PAR06)
				cQuery += " and E1_LOJA = '" + MV_PAR06 + "'"
			Endif
			If !Empty(MV_PAR07)
				cQuery += " and E1_NUM = '" + MV_PAR07 + "'"
			Endif
			cOrderBy +=  IIf(Len(cOrderBy) > 0,",","") +  "E1_CLIENTE,E1_LOJA,E1_NUM"
			If !Empty(MV_PAR08)
				cQuery += " and E1_VENCREA >= '" + DTOS(MV_PAR08) + "'"
				cOrderBy +=  IIf(Len(cOrderBy) > 0,",","") +  "E1_VENCREA DESC"
			EndIf
			If !Empty(MV_PAR09)
				cQuery += " and E1_VENCREA <= '" + DTOS(MV_PAR09) + "'"
				If Empty(MV_PAR08)
					cOrderBy +=  IIf(Len(cOrderBy) > 0,",","") +  "E1_VENCREA DESC"
				EndIf
			EndIf
	
		    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		    //ณ Requisitos Entidades Bancarias - Julho de 2012 ณ
		    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		    If cPaisLoc == "ARG"
	
		       //--- Verifica se deve levar em conta os Parametros de Entidades Bancarias
			   If MV_PAR10 == 1
	
		          If Empty( MV_PAR11 )  // Empty( cBcoChq )
	
		             If !Empty( MV_PAR14 )   // !Empty( cPostal )
		                 cQuery += " And E1_POSTAL = '" + MV_PAR14 + "'"
		             EndIf
	
		          Else
	
		             cQuery += " And E1_BCOCHQ = '" + MV_PAR11 + "'"
		             cQuery += " And E1_AGECHQ = '" + MV_PAR12 + "'"
	
		          EndIf
	
		       EndIf
	
		    EndIf
			cQuery += " and E1_SALDO > 0"
			cQuery += " and E1_SITUACA in (' ','1','0')"
			//Exclui da listagem os cheques que nใo estao em border๔
			cQuery += " and E1_NUMBOR = '' "
			cQuery += " and SE1.D_E_L_E_T_=''"
			If !Empty(cCliente)
				cQuery += " and E1_CLIENTE = '" + cCliente + "'"
				If !Empty(cLojaCli)
					cQuery += " and E1_LOJA = '" + cLojaCli + "'"
				Endif
			Endif
	
			If cTipo == "*"
				cQuery += " and E1_TIPO <> 'NCC'"
				cQuery += " and E1_TIPO <> 'NDC'"
				cQuery += " and E1_TIPO <> 'NCI'"
				cQuery += " and E1_TIPO <> 'NCE'"
			Else
				cQuery += " and E1_TIPO = '" + PadR(cTipo,TamSX3("E1_TIPO")[1]) + "'"
			Endif
	
			cQuery += " and E1_MOEDA = " + STR(MV_PAR02)
	
			If lF850FilCh .And. cPaisLoc == "ARG"
				cOrderQry := ExecBlock("F850FILCH",.F.,.F.,{cOrderQry})	
			Else
				cOrderQry := " order by E1_TIPO,E1_CLIENTE,E1_LOJA,E1_VENCREA,E1_PREFIXO,E1_PARCELA,E1_NUM"
			EndIf
			cQuery += cOrderQry
			
			cQuery := ChangeQuery(cQuery)
			cAliasSE1 := GetNextAlias()
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasSE1, .T., .T.)
			TCSetField(cAliasSE1,"E1_VENCREA","D",8,0)
			TCSetField(cAliasSE1,"E1_EMISSAO","D",8,0)
			DbSelectArea(cAliasSE1)
			(cAliasSE1)->(DbGoTop())
			nLenDoc := 0
			cFilFRF := xFilial("FRF")
			FRF->(DbSetOrder(1))
			While !((cAliasSE1)->(Eof()))
	
				If aScan(oGetDad2:aCols,{ |aDocTerc| (cAliasSE1)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_CLIENTE+E1_LOJA == aDocTerc[nPosPrefix]+aDocTerc[nPosNumero]+aDocTerc[nPosParcel]+aDocTerc[nPosClient]+aDocTerc[nPosLoja]) } ) > 0
					(cAliasSE1)->(DbSkip())
					Loop
				EndIf
	
				//Verifica se e a ultima vercao do recibo
				If !Empty((cAliasSE1)->EL_VERSAO)
					If Alltrim((cAliasSE1)->EL_VERSAO) <> Alltrim(F841VERSA((cAliasSE1)->EL_RECIBO))
						(cAliasSE1)->(DbSkip())
						Loop
					EndIf
				EndIf
	
				lSelecao := .T.
				If lCtrlCheck
					If (cAliasSE1)->E1_TIPO $ cTipoCh .Or. (cAliasSE1)->E1_TIPO $ MVCHEQUE
						If lEndosso
							lSelecao := !(FRF->(MsSeek(cFilFRF + (cAliasSE1)->EF_BANCO + (cAliasSE1)->EF_AGENCIA + (cAliasSE1)->EF_CONTA + (cAliasSE1)->E1_PREFIXO + PadR((cAliasSE1)->E1_NUM,TamSX3("EF_NUM")[1])+"11")))
						Else
							lSelecao := .F.
						Endif
	
						If lDicEndossa
							If  (cAliasSE1)->EL_ENDOSSA == '2' .And. AllTrim((cAliasSE1)->E1_ORIGEM) == "FINA840"
								lSelecao := .F.
							ElseIf (cAliasSE1)->EF_ENDOSSA <> '1' .And. AllTrim((cAliasSE1)->E1_ORIGEM) == "FINA100"
								lSelecao := .F.
							EndIf
						Endif
					EndIf
				Endif
	
				If lSelecao
					lIncluiReg := .T.
					nPosSaldo := Ascan(oGetDad2:aHeader,{|aCpo| AllTrim(aCpo[2]) == "E1_SALDO" })
					nPosMArg := Ascan(oGetDad2:aHeader,{|aCpo| AllTrim(aCpo[2]) == "E1_MOEDA" })
					If  !Empty(MV_PAR03)
						lIncluiReg := xMoeda((cAliasSE1)->&(oGetDad2:aHeader[nPosSaldo,2]),(cAliasSE1)->&(oGetDad2:aHeader[nPosMArg,2]),nMoedaArg,dDataBase) >= MV_PAR03
					EndIf
					If  !Empty(MV_PAR04)
						lIncluiReg := lIncluiReg .And. xMoeda((cAliasSE1)->&(oGetDad2:aHeader[nPosSaldo,2]),(cAliasSE1)->&(oGetDad2:aHeader[nPosMArg,2]),nMoedaArg,dDataBase) <= MV_PAR04
					EndIf
					If lIncluiReg
						Aadd(aDoc3os,{})
						nLenDoc := Len(aDoc3os)
						Aadd(aDoc3os[nLenDoc],.F.)
						For nCpo := 1 To nLen3os
							cCpo := oGetDad2:aHeader[nCpo,2]
							Aadd(aDoc3os[nLenDoc],(cAliasSE1)->&(cCpo))
						Next
						Aadd(aDoc3os[nLenDoc],(cAliasSE1)->REGSE1)
						Aadd(aDoc3os[nLenDoc],(cAliasSE1)->REGSEF)
					EndIf
				Endif
				(cAliasSE1)->(DbSkip())
			Enddo
			
			If Select(cAliasSE1) > 0   
				DbSelectArea(cAliasSE1)
				DbCloseArea()
			EndIf
			
		Endif
		
	Endif
	lSelecao := .F.
	If ExistBlock("F850CHPDT")
		nLenDoc	:= Len(aDoc3os)
		nMoedaSele	:= aDoF850[1]
		nLen3os	:= Len(oGetDad2:aHeader)
		nPosMoeda := 	Ascan(oGetDad2:aHeader,{|X| Alltrim(X[2]) == "E1_MOEDA"})
		nPosVlr	:= 	Ascan(oGetDad2:aHeader,{|X| Alltrim(X[2]) == "E1_SALDO"})
	Endif
	If nLenDoc >0
		nLenDoc1 := Len(aDoc3os[1])	//ultima posicao possui o recno do registros na SE1
		DbSelectArea("SE1")
		oDlg3os := TDialog():New(0,0,600,1200,STR0324,,,,,,,,,.T.,,,,,) // "Documentos de terceiros"
		oPnlTot:= TPanel():New(170,80,"",oDlg3os,,,,,,100,10)
		oPnlTot:Align :=  CONTROL_ALIGN_BOTTOM
		oPnlTot:nHeight := 30
		oDocSelTer := TSay():New(00,00, {|| " " + 'Total Selecionado (en  ' + Lower(AllTrim(GetMV("MV_MOEDA" + CValToChar(nMoedaSele))))  +  ') : ' + "   " + Transform(nDocSelTer,PesqPict("SE2","E2_VALOR"))},oPnlTot,,,,,,.T.,,,150,10,,,,,,)
		oBrw3os := TCBrowse():New(0,0,10,10,,,,oDlg3os,,,,,,,,,,,,,"",.T.,,,,.T.,)
		oBrw3os:AddColumn(TCColumn():New("  ",{|| If(aDoc3os[oBrw3os:nAt,1],oOk,oNo)},,,,,010,.T.,.F.,,,,,))
		For nCpo := 1 To nLen3os
			oBrw3os:AddColumn(TCColumn():New(&("RetTitle('" + oGetDad2:aHeader[nCpo,2] + "')"),&("{|| aDoc3os[oBrw3os:nAt," + AllTrim(Str(nCpo+1)) + "]}"),PesqPict("SE1",oGetDad2:aHeader[nCpo,2]),,,,020,.F.,.F.,,,,,))
			If nCpo == nPosMArg
				oBrw3os:AddColumn(TCColumn():New(AllTrim(STR0174),&("{|| FA850CNVAL(aDoc3os[oBrw3os:nAt," + AllTrim(Str(nPosSaldo+1)) +"],aDoc3os[oBrw3os:nAt," + AllTrim(Str(nPosMArg+1)) +"]," + AllTrim(Str(nMoedaSele)) +")}"),PesqPict("SE1",oGetDad2:aHeader[nPosSaldo,2]),,,,020,.F.,.F.,,,,,))
			EndIf
		Next
		oBrw3os:bLDblClick := {|| F850VldDoc3o(@aDoc3os,oBrw3os:nAt,nPosTipo+1,nPosVenc+1,@nDocSelTer,@oDocSelTer,nMoedaSele)}	//somar 1 pela coluna usada para marcacao
		oBrw3os:SetArray(aDoc3os)
		oBrw3os:Align :=  CONTROL_ALIGN_ALLCLIENT
		oDlg3os:bInit := {|| EnchoiceBar(oDlg3os,{|| lSelecao := .T.,oDlg3os:End()},{||lSelecao := .F.,oDlg3os:End()})}
		oDlg3os:Activate(,,,.T.)
	Else
		MsgAlert(Iif(lNoTerc,STR0349,STR0226),STR0223)
		lSelecao := .F.
	Endif
	/*_*/
Endif

If lSelecao
	If   cPaisloc =="ARG" .AND.  nVlrPagar==nTotDocProp
		 MsgAlert(STR0293)
	Else
		aCols3os := Aclone(oGetDad2:aCols)
		For nDocs := 1 To nLenDoc
			If aDoc3os[nDocs,1]
				//Reservar o documento no se1 para evitar o uso por outro usuario
				SE1->(DbGoTo(aDoc3os[nDocs,nLenDoc1 - 1]))
				lSelecao := .F.
				nX := 0

				If !IsMark("E1_OK",cMarcaE1)
					While !lSelecao .And. nX < 2
						nX += 0.25
						If SE1->(MsRlock(aDoc3os[nDocs,nLenDoc1 - 1]))
							lSelecao := .T.
							Replace SE1->E1_OK With cMarcaE1
						Endif
					Enddo
				EndIf
				
				If !lSelecao
					MsgAlert(OemToAnsi(STR0113)) //"El cheque esta en uso y no puede ser marcado"
				Else
					Aadd(aCols3os,Array(nLen3os + 3))
					nLenACols := Len(aCols3os)
					aCols3os[nLenACols,nLen3os + 1] := aDoc3os[nDocs,nLenDoc1-1] //a anti-penultima coluna da acos da msnewgetdados possusira o recno do registro para uso posterior
					aCols3os[nLenACols,nLen3os + 2] := aDoc3os[nDocs,nLenDoc1] //a penultima coluna da acos da msnewgetdados possusira o recno na tabela sef (controle de cheques)
					Aadd(aDoc3osUtil,aDoc3os[nDocs,nLenDoc1 - 1]) //acrescentar a array de controle de terceiros o recno para descarta-lo nas proximas selecoes
					aCols3os[nLenACols,nLen3os + 3] := .F.
					For nCpo := 1 To nLen3os
						aCols3os[nLenACols,nCpo] := aDoc3os[nDocs,nCpo + 1]
					Next
					nTotDocTerc += Round(xMoeda(aCols3os[nLenACols,nPosVlr],aCols3os[nLenACols,nPosMoeda],nMoedaCor,,5,aTxMoedas[aCols3os[nLenACols,nPosMoeda]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				EndIf
			Endif
		Next
	
		oGetDad2:SetArray(Aclone(aCols3os))
		If Len(aCols3os) > 0
			oGetDad2:oBrowse:Enable()
		EndIf
		oGetDad2:Refresh()
		F850AtuProp(,,.T.)       //validar el documento propio
		If Type("nVlrNeto") <> 'N'
			nVlrNeto := nVlrPagar
		EndIf                                                                
		nSaldoPgOP := nVlrPagar - (nTotDocTerc + nTotDocProp) - (nVlrPagar - nVlrNeto)
		oSaldoPgOP:Refresh()
		oTotDocTerc:Refresh()
	Endif
Endif

RestArea(aArea)
Pergunte("FIN850P",.F.)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VldDoc3oบAutor  ณMicrosiga           บFecha ณ  09/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VldDoc3o(aDoc3os,nPos,nPosTipo,nPosVcto,nValSel,oObjetoTmp,nMoedaSel)
Local nPosDoc := 0
Local nPosMoeda := 	Ascan(oGetDad2:aHeader,{|X| Alltrim(X[2]) == "E1_MOEDA"}) +1
Local nPosSaldo	:= 	Ascan(oGetDad2:aHeader,{|X| Alltrim(X[2]) == "E1_SALDO"}) +1
Local nValTemp := 0
Local lAtuVl	:= .T.	
Local nDiasTer   :=  GetNewPar("MV_DTCHTER",30)
Default oObjetoTmp := Nil
Default nValSel := 0

aDoc3os[nPos,1] := !aDoc3os[nPos,1]
If aDoc3os[nPos,1]
	nPosDoc := Ascan(aFormasPgto,{|pgto| Alltrim(pgto[1]) == AllTrim(aDoc3os[nPos,nPosTipo])})
	If nPosDoc > 0 .And. AllTrim(aFormasPgto[nPosDoc,2]) == "CH"
		If (aDoc3os[nPos,nPosVcto] + nDiasTer) < dDataBase
		    MsgAlert(STR0257+ AllTrim(Str(nDiasTer)) + STR0447  ,STR0223) 	//"Fecha de vencimiento del cheque de Terceros mayor que 30 dias."###"Atenci๓n"
			aDoc3os[nPos,1] := .F.
			lAtuVl:=.F.
		Endif
	Endif
Endif

If oObjetoTmp != Nil .And. lAtuVl
	nValTemp := FA850CNVAL(aDoc3os[nPos,nPosSaldo],aDoc3os[nPos,nPosMoeda],nMoedaSel)
	If aDoc3os[nPos,1]
		nValSel += nValTemp
	Else
		nValSel -= nValTemp
	EndIf
	oObjetoTmp:Refresh()
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850AtuProบAutor  ณMicrosiga           บFecha ณ  08/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850AtuProp(lCentavos, nItemNao, lEsTercer, lMoedaPA, aSE2)
Local nDoc		:= 0
Local nVlrAux	:= 0
Local nPorc		:= 0
Local nDif		:= 0
Local nDecs		:= 0
Local nLenAcols	:= 0
Local nPosVlPg	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "EK_VALOR"})
Local nPosMoeda	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "EK_MOEDA"})
Local nPosPorPg	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "NPORVLRPG"})
Local nPgAux 	:= 0
Local lNegativo := .F. 

Default lCentavos := .F.
Default nItemNao := 0
Default lEsTercer := .F.
Default lMoedaPA  := .F. 
Default aSE2      := {}

If  Type("nVlrNeto") == 'N' .And. IsInCallStack("F850VldRet") .And. GETMV("MV_FINCTAL") == "2" .And. cPaisLoc == "ARG"
	nMoedSol:= Val(SubStr(FJA->FJA_MOEDA,2,2))
	nVlrNeto := Round(xMoeda(nVlrNeto ,1,nMoedSol,,5,aTxMoedas[nMoedSol][2]),MsDecimais(nMoedSol))
EndIF

If !lEsTercer //No aplica para argentina (rehacer valores, dependiendo )
	nTotDocProp := 0
	nLenAcols := Len(oGetDad1:aCols)
	nVlrPg := nVlrPagar - nTotDocTerc
	
	IF Procname(1) == "F850VLDPA"
		If	nVlrPagar <> nVlrMont .Or. lMoedaPA
			nVlrMont := nVlrPagar
			If nLenAcols > 0
				For nDoc := 1 To Len(oGetDad1:aCols)
					oGetDad1:aCols[nDoc,nPosPorPg] := 0
					oGetDad1:aCols[nDoc,nPosVlPg] := 0
				Next nDoc	
				oGetDad1:oBrowse:Refresh()
			EndIf
		EndIf
	ENDIF
		
	If nLenAcols > 0
		For nDoc := 1 To Len(oGetDad1:aCols)
			If !lCentavos
				If nDoc != nItemNao
					nPorc += oGetDad1:aCols[nDoc,nPosPorPg]
					nVlrAux := Round(nVlrPg * (oGetDad1:aCols[nDoc,nPosPorPg] / 100),MsDecimais(Val(oGetDad1:aCols[nDoc,nPosMoeda])))
					oGetDad1:aCols[nDoc,nPosVlPg] := nVlrAux
					nTotDocProp += nVlrAux
				EndIf
			Else
				nTotDocProp += oGetDad1:aCols[nDoc,nPosVlPg]
			EndIf
		Next nDoc
	
		If nPorc == 100 .Or. lCentavos
			If Type("nVlrNeto") <> 'N'
				nVlrNeto:= nVlrPagar
			EndIf  	
			nVlrPg := (nVlrPagar-(nVlrPagar-nVlrNeto) - nTotDocTerc)
			nDif := nVlrPg - nTotDocProp   
			
			If nDif != 0
				nLenAcol := Len(oGetDad1:aCols)
    			nDecs := 1 / (10 ** MsDecimais(nMoedaCor)) * If(nDif < 0,-1,1)
    			lNegativo:=  IIf(nDif < 0 .And. (IsInCallStack("F850VldRet") .OR. IsInCallStack("F850VLDPA")) .And. cPaisLoc == "ARG",.T.,.F.)  
    			While (Iif(lNegativo, nDif<0, nDif != 0))  
  			    	nP := 0
			    	While (Iif(lNegativo, nDif<0, nDif != 0)) .And. (nP < nLenAcol)
		    			nP++
		    			If nP != nItemNao
				    		nTotDocProp -= oGetDad1:aCols[nP,nPosVlPg]
				    		oGetDad1:aCols[nP,nPosVlPg] += nDecs
				    		nTotDocProp += oGetDad1:aCols[nP,nPosVlPg]
				    		nDif -= nDecs
			    		EndIf
		    		EndDo
		    	EndDo
		    	If  lNegativo   
		    		nTotDocProp := Round(nTotDocProp,2)
		    	Endif
			EndIf
		EndIf
	EndIf
EndIf

If  lMoedaPA .And. cPaisLoc == "ARG"
	If  nLenAcols > 0
		F850VldElt(3,oFolderPg,aSE2)
	Endif
Endif

If Type("nVlrNeto") == 'N'

	If nVlrNeto == 0
		nVlrNeto := nVlrPagar - (nTotDocTerc + nTotDocProp)
	Else
		If nVlrNeto <> nVlrPagar .and. cPaisLoc == "ARG" .and. IsInCallStack("F850PgAdi") .and. nLiquido == 0 
			nVlrNeto := nVlrPagar  
		EndIf				        
	
	EndIf

	if cPaisLoc == "ARG" .and. IsInCallStack("F850PgAdi") .and. nLiquido <> 0
		nPgAux := nLiquido // verifica se possui ou nใo reten็๕es
		nSaldoPgOP := Round(nPgAux - (nTotDocTerc + nTotDocProp) - (nPgAux - nVlrNeto),2)
	Else
		nPgAux := nVlrPagar
		nSaldoPgOP := nPgAux - (nTotDocTerc + nTotDocProp) - (nPgAux - nVlrNeto)
	EndIF
	
Else
	nSaldoPgOP := nVlrPagar - (nTotDocTerc + nTotDocProp)
EndIf

oTotDocProp:Refresh()
oSaldoPgOP:Refresh()
oGetDad1:oBrowse:Refresh()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850DELPG บAutor  ณMicrosiga           บFecha ณ 29/08/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850DelPg(nFPg,lPA)
Local nPosVlr	:= 0
Local nPosPg	:= 0
Local nPosPgto	:= 0
Local nPosMoeda	:= 0
Local nReg3o	:= 0
Local nP		:= 0
Local lChq		:= .F.

Default nFPg	:= 0
Default lPA		:= .F.

Do Case
	Case nFPg == 1
		If Len(oGetDad1:aCols) > 0
			lChq := .F.
			nPosPg := Ascan(oGetDad1:aHeader,{|acabec| Alltrim(acabec[2]) == "EK_TIPO"})
			nPosVlr := Ascan(oGetDad1:aHeader,{|acabec| Alltrim(acabec[2]) == "EK_VALOR"})
			If nPosVlr > 0
				nTotDocProp -= oGetDad1:aCols[oGetDad1:nAt,nPosVlr]
				nSaldoPgOP := nVlrPagar - (nTotDocTerc + nTotDocProp)
			Endif
			If Len(oGetDad1:aCols) > 1
				nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(oGetDad1:aCols[oGetDad1:nAt,nPosPG])})
				lChq := (nPosPgto > 0 .And. AllTrim(aFormasPgto[nPosPgto,2]) == "CH")
				Adel(oGetDad1:aCols,oGetDad1:nAt)
				Asize(oGetDad1:aCols,Len(oGetDad1:aCols) - 1)
			Else
				For nP := 1 To Len(oGetDad1:aHeader)
					If oGetDad1:aHeader[nP,2] == "NPORVLRPG"
						oGetDad1:aCols[1,nP] := 0
					ElseIf oGetDad1:aHeader[nP,2] == "MOEDAPGTO"
						oGetDad1:aCols[1,nP] := nMoedaCor
					ElseIf allTrim(oGetDad1:aHeader[nP,2]) == "EK_VENCTO"
						oGetDad1:aCols[1,nP] := Criavar(AllTrim(oGetDad1:aHeader[Ascan(oGetDad1:aHeader,{|X| Alltrim(x[2]) == "EK_EMISSAO"}),2]))
					Else
						oGetDad1:aCols[1,nP] := Criavar(AllTrim(aHeaderPg[nP,2]))
					Endif
				Next
			Endif
			If !lPA
				If lChq
					F850VctoCheque()
				Endif
			Endif
			oGetDad1:Refresh()
			oTotDocProp:Refresh()
			oSaldoPgOP:Refresh()
		Endif
	Case nFPg == 2
		If Len(oGetDad2:aCols) > 0
			nPosVlr := Ascan(oGetDad2:aHeader,{|acabec| Alltrim(acabec[2]) == "E1_SALDO"})
			nPosMoeda := Ascan(oGetDad2:aHeader,{|acabec| Alltrim(acabec[2]) == "E1_MOEDA"})
			If nPosVlr > 0
				nTotDocTerc -= Round(xMoeda(oGetDad2:aCols[oGetDad2:nAt,nPosVlr],oGetDad2:aCols[oGetDad2:nAt,nPosMoeda],nMoedaCor,,5,aTxMoedas[oGetDad2:aCols[oGetDad2:nAt,nPosMoeda]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				F850AtuProp()
			Endif
			
			//Retirar da array de controle o recno do documento de terceiro
			If Len(aDoc3osUtil) >0
				nReg3o := oGetDad2:aCols[oGetDad2:nAt,Len(oGetDad2:aCols[oGetDad2:nAt]) - 2]	//penultima posicao posui o recno no arquivo SE1
				nPosVlr := Ascan(aDoc3osUtil,nReg3o)
				If nPosVlr > 0
					SE1->(DbGoTo(aDoc3osUtil[nPosVlr]))
					Replace SE1->E1_OK With ""
					SE1->(MsRUnlock(aDoc3osUtil[nPosVlr]))
					Adel(aDoc3osUtil,nPosVlr)
					Asize(aDoc3osUtil,Len(aDoc3osUtil) - 1)
				Endif
			Endif
			Adel(oGetDad2:aCols,oGetDad2:nAt)
			Asize(oGetDad2:aCols,Len(oGetDad2:aCols) - 1)
			lDelPg := .T.
			If Len(aDoc3osUtil) <= 0
				oGetDad2:oBrowse:Disable()
			EndIf
			oGetDad2:Refresh()
			oTotDocTerc:Refresh()
			oSaldoPgOP:Refresh()
		Endif
EndCase

F850Lin()
Return(.F.)

Function F850FldOk0()
Local lRet := .F.
Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ F850Click    ณ Autor ณ Jose Lucas       ณ Data ณ 15/08/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Processar a็๕es ap๓s doble click do browse superior, remon-ณฑฑ
ฑฑณ          ณ tando a aCols da getdados do folder 1.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ExpA2 := F850Cick(ExpO,ExpA1,ExpA2)                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ 														      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINF850                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function F850Click(aSE2,aDescontos,lAtuProp,oFolder,aPagos)
Local aSavArea		:= GetArea()
Local nSE2			:= 0
Local nUsado		:= 0
Local nLenAcol		:= 0
Local nP			:= 0
Local nPorc		:= 0
Local nDig			:= 0
Local nVlrPg		:= 0
Local nValorTit	:= 0
Local nPosPorPg	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2])=="NPORVLRPG"})
Local nPosVlrPg	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(X[2])=="EK_VALOR"})
Local nPosVlr3o	:= Ascan(oGetDad2:aHeader,{|x| Alltrim(X[2])=="E1_SALDO"})
Local nPosM3o		:= Ascan(oGetDad2:aHeader,{|x| Alltrim(x[2])=="E1_MOEDA"})
Local nPosValor	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(X[2])=="E2_VALOR"})
Local nPosSaldo	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(X[2])=="E2_SALDO"})
Local nPosMulta	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_MULTA"})
Local nPosJuros	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_JUROS"})
Local nPosDesco	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_DESCONT"})
Local nPosPagar	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_PAGAR"})
Local nPosVl		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="NVLMDINF"})
Local nPosMoeda	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_MOEDA"})
Local nPosForne	:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_FORNECE"})
Local nPosLoja		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_LOJA"})
Local nPosTipo		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_TIPO"})
Local nPosPref		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_PREFIXO"})
Local nPosNum		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_NUM"})
Local nPosParc		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_PARCELA"})
Local nPosVenc		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_VENCTO"})
Local aColsSE2		:= {}
Local aColsPg		:= {}
Local lRet			:= .T.
Local nValorPago	:=0
Local nValorPagar	:=0
Local nCfgElt		:= 0
Local nPosBasimp := 0
Local nPosAlqimp := 0 
Local nPosValimp := 0
Local nPosMdCont := 0

Default lAtuProp	:= .F.

If cPaisLoc == "RUS"
	nPosBasimp		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_BASIMP1"})
	nPosAlqimp		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_ALQIMP1"})
	nPosValimp		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_VALIMP1"})
	nPosMdCont		:= Ascan(oGetDad0:aHeader,{|x| Alltrim(x[2])=="E2_MDCONTR"})
Endif

nPosMPgto	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2])=="MOEDAPGTO"})

If Type("oGetDad0") <> "U"
	aColsSE2 := {}
	aPagar := {}
	aFill(aSaldos,0)
	nUsado   := Len(oGetDad0:aHeader)
	/*_*/
	nRetIva		:= 0
	nRetGan		:= 0
	nRetISI		:= 0
	nTotNF		:= 0
	nRetib		:= 0
	nRetIric	:= 0
	nRetIr		:= 0
	nRetIRC		:= 0
	nRetSUSS	:= 0
	nRetSLI		:= 0
	nRetIGV		:= 0
	nRetIR4		:= 0
	nRetAbt		:= 0
	nTotNcc		:= 0
	nValBrut	:= 0
	nValLiq		:= 0
	nPorDesc	:= 0
	nValDesc	:= 0
	nRetGan		:= 0
	nValDesp	:= 0

	If ValType(oFolder) <> "U"
		If cPaisLoc $ "RUS|ARG"
			If Type("oPgtoElt") <> "U"
				nCfgElt := oPgtoElt:nAt
			Else
				nCfgElt := 2
			EndIf

			If aPagos[oLbx:nAt,H_OK] = 1 .And. nCfgElt = 2
				oFolder:ShowPage(2)
	    		oFolder:ShowPage(3)
	    	ElseIf aPagos[oLbx:nAt,H_OK] = 1 .And. nCfgElt = 1
	    		oFolder:HidePage(2)
		    	oFolder:ShowPage(3)
	    	Else
		    	oFolder:HidePage(2)
		    	oFolder:HidePage(3)
		   EndIf
		Else
			If aPagos[oLbx:nAt,H_OK] = 1
				oFolder:ShowPage(2)
	    		oFolder:ShowPage(3)
	    	Else
		    	oFolder:HidePage(2)
		    	oFolder:HidePage(3)
		    EndIf
		EndIf
	EndIf

	If lVldRet
		If nOlbxAtAnt > 0
			aSE2[nOlbxAtAnt][3] := {4,aClone(oGetDad1:aCols),aClone(oGetDad2:aCols),0,0,aVlPA[_PA_VLATU],aVlPA[_PA_MOEATU]}
		Else
			aSE2[oLBx:nAt][3] := {4,aClone(oGetDad1:aCols),aClone(oGetDad2:aCols),0,0,aVlPA[_PA_VLATU],aVlPA[_PA_MOEATU]}
		Endif
	EndIf
	
	If Len(OGETDAD1:ACols) <> 0 
		aSE2[nOlbxAtAnt][3,2]	:=	Aclone(OGETDAD1:ACols)
	EndIf
	
	If Len(OGETDAD2:ACols) <> 0 .OR. ( lDelPg .AND.  nOlbxAtAnt <> 0)
		aSE2[nOlbxAtAnt][3,3]	:=	Aclone(OGETDAD2:ACols)
		lDelPg := .F.
	EndIf
	
	nOlbxAtAnt := oLbx:nAt
	aColsPg := Aclone(aSE2[nOlbxAtAnt][3,2])
	nPorc := 0
	nVlrPg := 0
	If Empty(aColsPg)
		Aadd(aColsPg,Array(Len(oGetDad1:aHeader)+1))
		For nP := 1 To Len(oGetDad1:aHeader)
			If oGetDad1:aHeader[nP,2] == "NPORVLRPG"
				aColsPg[1,nP] := 0
			ElseIf oGetDad1:aHeader[nP,2] == "MOEDAPGTO"
				aColsPg[1,nP] := nMoedaCor
			ElseIf oGetDad1:aHeader[nP,2] == "FRECHQ"
				aColsPg[1,nP] := Space(20)
			ElseIf allTrim(oGetDad1:aHeader[nP,2]) == "EK_VENCTO" .AND. Empty(Criavar(AllTrim(oGetDad1:aHeader[nP,2])))
				aColsPg[1,nP] := Criavar(AllTrim(oGetDad1:aHeader[Ascan(oGetDad1:aHeader,{|X| Alltrim(x[2]) == "EK_EMISSAO"}),2]))			
			Else
				aColsPg[1,nP] := Criavar(AllTrim(oGetDad1:aHeader[nP,2]))
			Endif
		Next
		aColsPg[1,Len(aColsPg[1])] := .F.
	Else
		For nP := 1 To Len(aColsPg)
			nPorc += aColsPg[nP,nPosPorPg]
			aColsPg[nP,nPosVlrPg] := Round(xMoeda(aColsPg[nP,nPosVlrPg],aColsPg[nP,nPosMPgto],nMoedaCor,,,aTxMoedas[aColsPg[nP,nPosMPgto],2],aTxMoedas[nMoedaCor,2]),MsDecimais(nMoedaCor))
			aColsPg[nP,nPosMPgto] := nMoedaCor
			nVlrPg += aColsPg[nP,nPosVlrPg]
		Next
	Endif
	nTotDocProp := nVlrPg
	oGetDad1:SetArray(aColsPg)
	//oGetDad1:oBrowse:Refresh()
	oGetDad1:Refresh()
	
	If cPaisLoc == "ARG" .and. CCO->(ColumnPos("CCO_TPCALR"))> 0
		/*Retenciones*/
		aColsRet := {}
		aRetPos := {}
		Fn850GtRet(@aColsRet,aSE2)
		If Empty(aColsRet)
			Aadd(aColsRet,Array(Len(oGetDad3:aHeader)))
			For nP := 1 To Len(oGetDad3:aHeader)
				aColsRet[1,nP] := Criavar(AllTrim(oGetDad3:aHeader[nP,2]))
			Next nP
		EndIf
		oGetDad3:SetArray(aColsRet)
		oGetDad3:oBrowse:Refresh()	
		/*Fin Retenciones*/
	EndIF
	
	/*_*/
	aCols3os := Aclone(aSE2[nOlbxAtAnt][3,3])
	oGetDad2:SetArray(aCols3os)
	oGetDad2:oBrowse:Refresh()
	/*_*/
	nVlrPagar	:= 0
	nSaldoPgOP	:= 0
	nTotDocTerc	:= 0
	oSaldoPgOP:Refresh()
	oTotDocTerc:Refresh()
	oTotDocProp:Refresh()
	/*_*/
	nUnico := aPagos[oLbx:nAt,H_UNICOCHQ]
	nMultiplo := aPagos[oLbx:nAt,H_MULTICHQ]
	oUnico:Select(nUnico)
	oMultiplo:Select(nMultiplo)
	//oUnico:SetDisable(aSE2[oLbx:nAt,5])
	//oMultiplo:SetDisable(aSE2[oLbx:nAt,5])
	/*_*/
	nPorDesc :=	aPagos[oLbx:nAt,H_PORDESC]
	If cPaisLoc != 'MEX' .and. !Empty(aPagos[oLbx:nAt,H_NATUREZA])
		cNatureza := aPagos[oLbx:nAt,H_NATUREZA]
	EndIf
	
	aDescontos := {}
	/*_*/

	For nSE2 := 1 To Len(aSE2[oLbx:nAt,1])
		Aadd(aColsSE2,Array(Len(oGetDad0:aHeader)+1))
		nLenACol := Len(aColsSE2)
		aColsSE2[nLenAcol,nPosPagar]	:= aSE2[oLbx:nAt,1,nSE2,_PAGAR]
		aColsSE2[nLenAcol,nPosMulta]	:= aSE2[oLbx:nAt,1,nSE2,_MULTA]
		aColsSE2[nLenAcol,nPosJuros]	:= aSE2[oLbx:nAt,1,nSE2,_JUROS]
		aColsSE2[nLenAcol,nPosDesco]	:= aSE2[oLbx:nAt,1,nSE2,_DESCONT]
		aColsSE2[nLenAcol,nPosForne]	:= aSE2[oLbx:nAt,1,nSE2,_FORNECE]
		aColsSE2[nLenAcol,nPosLoja]		:= aSE2[oLbx:nAt,1,nSE2,_LOJA]
		aColsSE2[nLenAcol,nPosTipo]		:= aSE2[oLbx:nAt,1,nSE2,_TIPO]
		aColsSE2[nLenAcol,nPosPref]		:= aSE2[oLbx:nAt,1,nSE2,_PREFIXO]
		aColsSE2[nLenAcol,nPosNum]		:= aSE2[oLbx:nAt,1,nSE2,_NUM]
		aColsSE2[nLenAcol,nPosParc]		:= aSE2[oLbx:nAt,1,nSE2,_PARCELA]
		aColsSE2[nLenAcol,nPosValor]	:= aSE2[oLbx:nAt,1,nSE2,_VALOR]
		aColsSE2[nLenAcol,nPosSaldo]	:= aSE2[oLbx:nAt,1,nSE2,_SALDO] - (aSE2[oLbx:nAt,1,nSE2,_MULTA]) + aSE2[oLbx:nAt,1,nSE2,_JUROS] - aSE2[oLbx:nAt,1,nSE2,_DESCONT]
		aColsSE2[nLenAcol,nPosMoeda]	:= aSE2[oLbx:nAt,1,nSE2,_MOEDA]
		aColsSE2[nLenAcol,nPosVenc]		:= aSE2[oLbx:nAt,1,nSE2,_VENCTO]
		If cPaisLoc == 'RUS'
			aColsSE2[nLenAcol,nPosBasimp]		:= aSE2[oLbx:nAt,1,nSE2,_BASIMP1]
			aColsSE2[nLenAcol,nPosAlqimp]		:= aSE2[oLbx:nAt,1,nSE2,_ALQIMP1]
			aColsSE2[nLenAcol,nPosValimp]		:= aSE2[oLbx:nAt,1,nSE2,_VALIMP1]
			aColsSE2[nLenAcol,nPosMdCont]		:= aSE2[oLbx:nAt,1,nSE2,_MDCONTR]
		EndIf
		aColsSE2[nLenAcol,nPosVl]		:= Round(xMoeda(aColsSE2[nLenAcol,nPosPagar],aColsSE2[nLenAcol,nPosMoeda],nMoedaCor,,5,aTxmoedas[aColsSE2[nLenAcol,nPosMoeda]][2],aTxmoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		aColsSE2[nLenAcol,Len(oGetDad0:aHeader)+1] := .F.
		/*_*/
		Aadd(aPagar,aColsSE2[nLenAcol,nPosPagar] + aColsSE2[nLenAcol,nPosDesco] - (aColsSE2[nLenAcol,nPosJuros] + aColsSE2[nLenAcol,nPosMulta]))
		Aadd(aDescontos,aColsSE2[nLenAcol,nPosDesco])
		/*_*/
		nValorTit += Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_VALOR],aSE2[oLbx:nAt,1,nSE2,_MOEDA],nMoedaCor,,5,aTxMoedas[aSE2[oLbx:nAt,1,nSE2,_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		/*_*/
		//Calcular os Totais
		If aSE2[oLbx:nAt,1,nSE2,_TIPO] $ MVPAGANT + "/" + MV_CPNEG
			nTotNcc	+=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_PAGAR],aSE2[oLbx:nAt,1,nSE2,_MOEDA],nMoedaCor,,5,aTxmoedas[aSE2[oLbx:nAt,1,nSE2,_MOEDA]][2],aTxmoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Else
			nValBrut+=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_PAGAR] + aSE2[oLbx:nAt,1,nSE2,_DESCONT],aSE2[oLbx:nAt,1,nSE2,_MOEDA],nMoedaCor,,5,aTxmoedas[aSE2[oLbx:nAt,1,nSE2,_MOEDA]][2],aTxmoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			nValLiq	+=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_PAGAR ],aSE2[oLbx:nAt,1,nSE2,_MOEDA],nMoedaCor,,5,aTxmoedas[aSE2[oLbx:nAt,1,nSE2,_MOEDA]][2],aTxmoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			nValDesc+=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_DESCONT],aSE2[oLbx:nAt,1,nSE2,_MOEDA],nMoedaCor,,5,aTxmoedas[aSE2[oLbx:nAt,1,nSE2,_MOEDA]][2],aTxmoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		EndIf
		//Carregar retencoes para informar no cabecalho...
		If cPaisLoc	==	"ARG"
			For nP	:=	1	To	Len(aSE2[oLbx:nAt,1,nSE2,_RETIB])
				nRetib	+=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_RETIB][nP][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				aSaldos[1]	-=	aSE2[oLbx:nAt,1,nSE2,_RETIB,nP,5]
			Next
			For nP	:=	1	To	Len(aSE2[oLbx:nAt,1,nSE2,_RETIVA])
				nRetiva	+=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				aSaldos[1]	-=	aSE2[oLbx:nAt,1,nSE2,_RETIVA,nP,6]
			Next
			For nP	:=	1	To	Len(aSE2[oLbx:nAt,1,nSE2,_RETSUSS])
				nRetSUSS +=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_RETSUSS][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				aSaldos[1] -= aSE2[oLbx:nAt,1,nSE2,_RETSUSS][nP][6]
			Next
			For nP	:=	1	To	Len(aSE2[oLbx:nAt,1,nSE2,_RETSLI])
				nRetSLI +=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_RETSLI][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				aSaldos[1]	-=	aSE2[oLbx:nAt,1,nSE2,_RETSLI][nP][6]
			Next
			For nP	:=	1	To	Len(aSE2[oLbx:nAt,1,nSE2,_RETISI])
				nRetISI +=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_RETISI][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				aSaldos[1]	-=	aSE2[oLbx:nAt,1,nSE2,_RETISI ][nP][6]
			Next
			//ANGOLA
			//Carregar retencoes para informar no cabecalho...
		ElseIf cPaisLoc	==	"ANG"
			For nP	:=	1	To	Len(aSE2[oLbx:nAt,1,nSE2,_RETRIE])
				nRetRie	+=	Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_RETRIE][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				aSaldos[1]	-=	aSE2[oLbx:nAt,1,nSE2,_RETRIE][nP][5]
			Next
		Endif
		/*_*/
		aSaldos[aSE2[oLbx:nAt,1,nSE2,_MOEDA]] += aSE2[oLbx:nAt,1,nSE2,_PAGAR] * (If(aSE2[oLbx:nAt,1,nSE2,_TIPO] $ MVPAGANT+"/"+MV_CPNEG,-1,1))
		If aVlPA[_PA_VLANT] > 0
			nValorPago += Round(xMoeda(aSE2[oLbx:nAt,1,nSE2,_PAGAR],aSE2[oLbx:nAt,1,nSE2,_MOEDA],aVlPA[_PA_MOEANT],,5,aTxMoedas[aSE2[oLbx:nAt,1,nSE2,_MOEDA]][2],aTxMoedas[aVlPA[_PA_MOEANT]][2]),MsDecimais(aVlPA[_PA_MOEANT]))
		EndIf
	Next
	If cPaisLoc == "ARG"
		For nP := 1 To Len(aSE2[oLbx:nAt,2])
			nRetGan	+=	Round(xMoeda(aSE2[oLbx:nAt,2,nP,5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			aSaldos[1]	-=	aSE2[oLbx:nAt,2,nP,5]
		Next
	Endif
	/*_*/
	nValLiq	:= (nValBrut - nTotNcc) - (nValDesc + nRetGan + nRetIb + nRetIVA + nRetIric + nRetSUSS + nRetSLI + nRetIr + nRetIRC + nRetIGV + nRetIR4) + nValDesp
	/*_*/
	aVlPA[_PA_VLANT]	:=	aSE2[oLbx:nAt,3,6]
	aVlPA[_PA_VLATU]	:=	aSE2[oLbx:nAt,3,6]
	aVlPA[_PA_MOEANT]	:=	aSE2[oLbx:nAt,3,7]
	aVlPA[_PA_MOEATU]	:=	aSE2[oLbx:nAt,3,7]
	/*_*/
	If aVlPA[_PA_VLANT] <> 0
		If nValorPago >0
			aSaldos[aVlPA[_PA_MOEANT]]  := 0
			If nValorTit >0
				nValDif := nValorTit - (nValorPago - nRetGan)
			Else
				nValDif := aSaldos[aVlPA[_PA_MOEANT]] - ( nValorPago - aVlPA[_PA_VLANT])
			EndIf
		Else
			aSaldos[aVlPA[_PA_MOEANT]]  += aVlPA[_PA_VLANT]
		EndIf
	Else
		aSaldos[nMoedaCor] -= nValorTit
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalculo o saldo total na moeda corrente e guardo na ultima ณ
	//ณposicao do array de saldos                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nP	:=	1	To Len(aTxMoedas)
		aSaldos[Len(aSaldos)] += Round(xMoeda(aSaldos[nP],nP,nMoedaCor,,5,aTxMoedas[nP][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Next
    /*_*/
    nVlrPagar := aPagos[oLbx:nAt,H_TOTALVL]
    /*_*/
    For nP := 1 To Len(aCols3os)
		nTotDocTerc += Round(xMoeda(oGetDad2:aCols[nP,nPosVlr3o],oGetDad2:aCols[nP,nPosM3o],nMoedaCor,,5,aTxMoedas[oGetDad2:aCols[nP,nPosM3o]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
    Next
    /*
	ajusta as diferencas de centavos em documentos proprios */
    If nPorc == 100
	    F850AtuProp(!lAtuProp)
	Endif
    nSaldoPgOP := aPagos[oLbx:nAt,H_TOTALVL] - (nTotDocTerc + nTotDocProp)

   	oVlrPagar:Refresh()
	oSaldoPgOP:Refresh()
	oTotDocTerc:Refresh()
	oTotDocProp:Refresh()
	/*_*/
	oGetDad1:Refresh()
	oGetDad2:Refresh()
	/*_*/
	oGetDad0:SetArray(aColsSE2)
	oGetDad0:oBrowse:Refresh()
	oGetDad0:oBrowse:SetFocus()
Endif
oLbx:SetFocus()
RestArea(aSavArea)
Return(lRet)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ F850DClick   ณ Autor ณ Jose Lucas       ณ Data ณ 15/08/11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Processar a็๕es ap๓s doble click do browse superior, remon-ณฑฑ
ฑฑณ          ณ tando a aCols da getdados do folder 1.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ExpA2 := F850DCick()                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ 														      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINF850                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function F850DClick(oFolder)
Local nNoMarcados	:= 0
Local nCntPagos		:= 0
Local lRet			:= .T.

If (mv_par05==2)

	MsgAlert( STR0348, STR0326 )  // "Atenci๓n"
	Return

EndIf

aPagos[oLbx:nAt,H_OK] := aPagos[oLBx:nAt,H_OK] * -1

If Len(aPagos) > 1
	For nCntPagos := 1 To Len(aPagos)
		If aPagos[nCntPagos][H_OK] == -1 //Somente registros nใo marcados.
			nNoMarcados++
		EndIf
	Next nCntPagos
    If Len(aPagos) == nNoMarcados
		MsgAlert( STR0325 , STR0326 ) // "Seleccione por lo menos un proveedor" // "Atenci๓n"
		lRet := .F.
	EndIf
EndIf

nNumOrdens:=nNumOrdens+aPagos[oLBx:nAt,H_OK]
nValOrdens:=nValOrdens+(aPagos[oLBx:nAt,H_TOTALVL]*aPagos[oLBx:nAt,H_OK])
oNumOrdens:Refresh()
oValOrdens:Refresh()
If lRet
	SysRefresh()
Endif

If ValType("oFolder") <> "U"
	If aPagos[oLbx:nAt,H_OK] = 1
	   	If cOpcElt <> "1"
	   		oFolder:ShowPage(2)
	   	EndIf
    	oFolder:ShowPage(3)
	Else
    	oFolder:HidePage(2)
    	oFolder:HidePage(3)
    EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F850DelOk บAutor  ณ Jose Lucas       บ Data ณ  15/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da MsGetDados do objeto oGetDad0 atrav้s por meioบฑฑ
ฑฑบ          ณ do metodo cDelOk                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINa850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850DelOk()
Local lRet	     := .T.
Local nI	     := 0
Local nNumTitFor := 0
Local nPosForn   := Ascan(oGetDad0:aHeader,{|x| AllTrim(x[2]) == "E2_FORNECE"})
Local nPosLoja   := Ascan(oGetDad0:aHeader,{|x| AllTrim(x[2]) == "E2_LOJA"})

If ! GDDeleted(n,oGetDad0:aHeader,oGetDad0:aCols)
	cFornece := oGetDad0:aCols[n][nPosForn]
	cLoja    := oGetDad0:aCols[n][nPosLoja]
	For nI := 1 To Len(oGetDad0:aCols)
		If oGetDad0:aCols[nI][nPosForn] == cFornece .and. oGetDad0:aCols[n][nPosLoja] == cLoja .and.;
			! GDDeleted(nI,oGetDad0:aHeader,oGetDad0:aCols)
           nNumTitFor ++
        EndIf
    Next nI
    If nNumTitFor == 1 //Apenas um tํtulo por fornecedor na GetDados, nใo permitir apagar!
	 	//Help( " ", 1, "FA085DELOK" )
    	MsgAlert( STR0327 , STR0326 )  // "Atenci๓n"
    	lRet := .F.
    EndIf
EndIf
oGetDad0:oBrowse:Refresh()
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA850   บAutor  ณMicrosiga           บFecha ณ  08/22/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850AtuOP(aSE2, lOPRotAut)
Local nC			:= 0
Local nA			:= 0
Local nP			:= 0
Local nPos			:= 0
Local nVlrAux		:= 0
Local nPosSep		:= 0
Local nPosJuros	:= 0
Local nPosMulta	:= 0
Local nPosDesc		:= 0
Local nIVSUS	:= 0
Local cCpo			:= ""
Local 	lExisPA	:= .F.
Local 	lReIvSU	:= (cPaisLoc=="ARG" .and. GetNewPar("MV_RETIVA","N") == "S" .and. GetNewPar("MV_RETSUSS","N") == "S")
Local lValorDif := .T.
Local cCampo    := ReadVar()
Default lOPRotAut	:= .F.

_nJuros := 0
_nMulta := 0
_nDescont := 0

If cPaisLoc == "ARG" 
	Do Case
		Case cCampo == "NPORDESC" 
			If aPagos[oLbx:nAt][H_PORDESC] == M->NPORDESC
				lValorDif := .F.
			Endif
		Case cCampo == "NVALDESC" 
			If (aPagos[oLbx:nAt][H_DESCVL] == M->NVALDESC) .OR. (Val(aPagos[oLbx:nAt][H_NCC_PA]) > 0)  
				lValorDif := .F.
			Endif
		Case cCampo == "NVLRPAGAR" 
			If Type("aVlPA")=="A" .AND. !Empty(aVlPA[1]) .AND. !Empty(aVlPA[3])
				If aVlPA[1] == aVlPA[3]
					lValorDif := .F.
				Endif
			EndIf 
	EndCase
Endif
IF lValorDif
If !lOPRotAut
	nPos := oLbx:nAt
	nPosJuros := Ascan(oGetDad0:aHeader,{|se2| AllTrim(se2[2]) == "E2_JUROS"})
	nPosMulta := Ascan(oGetDad0:aHeader,{|se2| AllTrim(se2[2]) == "E2_MULTA"})
	nPosDesc  := Ascan(oGetDad0:aHeader,{|se2| AllTrim(se2[2]) == "E2_DESCONT"})
	For nA:=1	To	Len(aSE2[nPos][1])
		_nJuros := If(nPosJuros > 0, oGetDad0:aCols[nA][nPosJuros],0)
		_nMulta := If(nPosMulta > 0, oGetDad0:aCols[nA][nPosMulta],0)
	 	If nPosDesc	> 0
			_nDescont := oGetDad0:aCols[nA][nPosDesc]
		Else
			_nDescont := (oGetDad0:aCols[nA][1] * nPorDesc /100)
		EndIf
		If !Empty(oGetDad0:Cargo)
			nPosSep := AT("|",oGetDad0:Cargo)
			If nPosSep > 0
				If oGetDad0:nAt == nA
					cCpo := Alltrim(Substr(oGetDad0:Cargo,1,nPosSep - 1))
					nVlrAux := Val(Alltrim(Substr(oGetDad0:Cargo,nPosSep + 1)))
					nPosSep := AT("_",cCpo)
					cCpo := "_n" + Substr(cCpo,nPosSep + 1)

					&(cCpo) := nVlrAux
					oGetDad0:Cargo := Nil
				Endif

			Endif
		Endif

		If (aSE2[nPos][1][nA][_TIPO] $ MVPAGANT + "/"+ MV_CPNEG)
			nDescont := 0
		EndIf
		aSE2[nPos][1][nA][_PAGAR]	:= oGetDad0:aCols[nA][1] - (Iif(aSE2[nPos][1][nA][_DESCONT] > 0 .AND. nPorDesc > 0.00,_nMulta+_nJuros,0)  /*- aSE2[nPos][1][nA][_DESCONT]*/ + nRetAbt)
		aSE2[nPos][1][nA][_JUROS]	:= _nJuros
		aSE2[nPos][1][nA][_MULTA]	:= _nMulta
		aSE2[nPos][1][nA][_DESCONT]	:= _nDescont
	Next

	nValOrdens	-=	aPagos[nPos][H_TOTALVL]
Else
	nPos := 1
EndIf

aPagos[nPos][H_NCC_PA]	:=	0
aPagos[nPos][H_NF]		:=	0
aPagos[nPos][H_TOTALVL]	:=	0
aPagos[nPos][H_VALORIG]	:=	0
aPagos[nPos][H_TOTRET ]	:=	0
aPagos[nPos][H_DESCVL]	:=	0

If cPaisLoc == "ARG"
	aPagos[nPos][H_RETIB]	:=	0
	aPagos[nPos][H_RETIVA]	:=	0
	aPagos[nPos][H_RETGAN]	:=	0
	aPagos[nPos][H_RETSUSS]	:=	0
	aPagos[nPos][H_RETSLI]	:=	0
	aPagos[nPos][H_RETISI]	:=	0
	//ANGOLA
ElseIf cPaisLoc == "ANG"
	aPagos[nPos][H_RETRIE]	:=	0
Endif
/*
carregar com os valores de notas para ser pagas, nnc , pas, e no caso de argentina as retencoes de impostos de ib e iva.*/
For nC	:=	1	To Len(aSE2[nPos][1])
	If aSE2[nPos][1][nC][_TIPO] $ MVPAGANT + "/" + MV_CPNEG
		lExisPA := lReIvSU .and. aSE2[nPos][1][nC][_TIPO] $ MVPAGANT
		aPagos[nPos][H_NCC_PA] += Round(xMoeda(aSE2[nPos][1][nC][_PAGAR],aSE2[nPos][1][nC][_MOEDA],nMoedaCor,,5,aTxMoedas[aSE2[nPos][1][nC][_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		aPagos[nPos][H_VALORIG] += Round(xMoeda(aSE2[nPos][1][nC][_PAGAR],aSE2[nPos][1][nC][_MOEDA],1,,5,aTxMoedas[aSE2[nPos][1][nC][_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Else
		aPagos[nPos][H_VALORIG] += Round(xMoeda(aSE2[nPos][1][nC][_PAGAR]+aSE2[nPos][1][nC][_DESCONT],aSE2[nPos][1][nC][_MOEDA],1,,5,aTxMoedas[aSE2[nPos][1][nC][_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		aPagos[nPos][H_NF] += Round(xMoeda(aSE2[nPos][1][nC][_PAGAR]+aSE2[nPos][1][nC][_DESCONT],aSE2[nPos][1][nC][_MOEDA],nMoedaCor,,5,aTxMoedas[aSE2[nPos][1][nC][_MOEDA]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Endif
	If cPaisLoc == "ARG"
		For nP	:=	1	To	Len(aSE2[nPos][1][nC][_RETIB])
			aPagos[nPos][H_RETIB]	+=	Round(xMoeda(aSE2[nPos][1][nC][_RETIB ][nP][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next
		For nP	:=	1	To	Len(aSE2[nPos][1][nC][_RETIVA])
			aPagos[nPos][H_RETIVA]	+=	Round(xMoeda(aSE2[nPos][1][nC][_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next
		For nP	:=	1	To	Len(aSE2[nPos][1][nC][_RETSUSS])
			aPagos[nPos][H_RETSUSS]	+= Round(xMoeda(aSE2[nPos][1][nC][_RETSUSS][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next
		For nP	:=	1	To	Len(aSE2[nPos][1][nC][_RETSLI])
			aPagos[nPos][H_RETSLI]	+= Round(xMoeda(aSE2[nPos][1][nC][_RETSLI][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next
		For nP	:=	1	To	Len(aSE2[nPos][1][nC][_RETISI])
			aPagos[nPos][H_RETISI]	+= Round(xMoeda(aSE2[nPos][1][nC][_RETISI][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next
		//ANGOLA
	ElseIf cPaisLoc == "ANG"
		For nP	:=	1	To	Len(aSE2[nPos][1][nC][_RETRIE])
			aPagos[nPos][H_RETRIE]	+=	Round(xMoeda(aSE2[nPos][1][nC][_RETRIE ][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next
	Endif
Next nC
/*_*/
If cPaisLoc	==	"ARG"
	//Atualiza o IVA Acumulado
	If aRetIvAcm[3] <> Nil .And. Len(aRetIvAcm)>2 .And. Len(aRetIvAcm[3]) > 0
		For nP := 1 to Len(aRetIvAcm[3])
			aPagos[nPos][H_RETIVA]	+=	Round(xMoeda(aRetIvAcm[3][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next
	EndIf
	For nC:=	1	To Len(aSE2[nPos][2])
		aPagos[nPos][H_RETGAN]	+=	Round(xMoeda(aSE2[nPos][2][nC][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
	Next nC
	aPagos[nPos][H_TOTALVL]	:=	aPagos[nPos][H_NF]-aPagos[nPos][H_NCC_PA] - aPagos[nPos][H_RETIB]-aPagos[nPos][H_RETGAN] - aPagos[nPos][H_RETIVA]-aPagos[nPos][H_RETSUSS]-;
	aPagos[nPos][H_RETSLI]-aPagos[nPos][H_RETISI]
	//ANGOLA
ElseIf cPaisLoc == "ANG"
	aPagos[nPos][H_TOTALVL]	:=	aPagos[nPos][H_NF]-aPagos[nPos][H_NCC_PA]-aPagos[nPos][H_RETRIE]
Else
	aPagos[nPos][H_TOTALVL]	:=	aPagos[nPos][H_NF]-aPagos[nPos][H_NCC_PA]
Endif
If cPaisLoc	==	"EQU"
	If	aPagos[nPos][H_TOTALVL] !=	aPagos[nPos][H_VALORIG]
		aPagos[nPos][H_TOTALVL]	+= 	nRetAbt
	EndIf
EndIf
If cPaisLoc	==	"ARG"
	If lExisPA
		nIVSUS	+= 	(aPagos[nPos][H_RETIVA] + aPagos[nPos][H_RETSUSS])
	Endif
	aPagos[nPos][H_TOTRET]	:=	aPagos[nPos][H_RETIB]+aPagos[nPos][H_RETIVA]+aPagos[nPos][H_RETGAN]
	aPagos[nPos][H_RETIB]	:=	TransForm(aPagos[nPos][H_RETIB]  ,Tm(aPagos[nPos][H_RETIB ] ,16,nDecs))
	aPagos[nPos][H_RETGAN]	:=	TransForm(aPagos[nPos][H_RETGAN] ,Tm(aPagos[nPos][H_RETGAN] ,16,nDecs))
	aPagos[nPos][H_RETIVA]	:=	TransForm(aPagos[nPos][H_RETIVA] ,Tm(aPagos[nPos][H_RETIVA] ,16,nDecs))
	aPagos[nPos][H_RETSUSS]	:=	TransForm(aPagos[nPos][H_RETSUSS],Tm(aPagos[nPos][H_RETSUSS],16,nDecs))
	aPagos[nPos][H_RETSLI]	:=	TransForm(aPagos[nPos][H_RETSLI] ,Tm(aPagos[nPos][H_RETSLI] ,16,nDecs))
	aPagos[nPos][H_RETISI]	:=	TransForm(aPagos[nPos][H_RETISI] ,Tm(aPagos[nPos][H_RETISI] ,16,nDecs))
ElseIf cPaisLoc	==	"ANG"
	aPagos[nPos][H_TOTRET]	:=	aPagos[nPos][H_RETRIE]
	aPagos[nPos][H_RETRIE]	:=	TransForm(aPagos[nPos][H_RETRIE]  ,Tm(aPagos[nPos][H_RETRIE ] ,16,nDecs))
ElseIf cPaisLoc	==	"EQU"
	aPagos[nPos][H_RETIR]	:=  nRetAbt
Endif
If aPagos[nPos][1] == 0
	nNumOrdens++
Endif
//A factura so eh desconsiderada caso a retencao de IVA e o total a ser pago sejam menores que zero. Isso so eh valido para Argentina.
If (aPagos[nPos][H_TOTALVL]	< 0) .And. Iif(cPaisLoc=="ARG",DesTrans(aPagos[nPos][H_RETIVA],nDecs) <= 0,.T.)
	aPagos[nPos][1]	:=	0
	nNumOrdens--
Else
	aPagos[nPos][1]	:=	1
	nValOrdens	+=	aPagos[nPos][H_TOTALVL]
Endif
aPagos[nPos][H_DESCVL]		:= aPagos[nPos][H_NCC_PA ]
aPagos[nPos][H_NF    ]		:= TransForm(aPagos[nPos][H_NF     ],Tm(aPagos[nPos][H_NF],16,nDecs))
aPagos[nPos][H_NCC_PA]		:= TransForm(aPagos[nPos][H_NCC_PA ],Tm(aPagos[nPos][H_NCC_PA],16,nDecs))
aPagos[nPos][H_TOTAL ]		:= TransForm(aPagos[nPos][H_TOTALVL],Tm(aPagos[nPos][H_TOTALVL],18,nDecs))
If !lOPRotAut
	aPagos[nPos][H_PORDESC]		:= nPorDesc
EndIf
aPagos[nPos][H_NATUREZA]		:= cNatureza

IF lExisPA
	aPagos[nPos][H_TOTAL ]	:=	TransForm(aPagos[nPos][H_TOTALVL]+nIVSUS,Tm(aPagos[nPos][H_TOTALVL] ,18,nDecs))
	aPagos[nPos][H_TOTALVL] +=	nIVSUS
Endif 	

If !lOPRotAut
	F850AtuVl(@oValOrdens,@nValOrdens,@aPagos,aSE2)

	nVlrPagar := aPagos[nPos,H_TOTALVL]
	oLbx:Refresh()
	oValOrdens:Refresh()

	oVlrPagar:Refresh()
	F850AtuProp()
EndIf
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850POPVisบAutor  ณMicrosiga           บFecha ณ 28/09/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850POPVis()
Local aArea	:= {}
Local aFJK	:= {}
Local aFJL	:= {}

aArea := GetArea()
DbSelectArea("FJL")
aFJL := GetArea()
DbSelectArea("FJK")
aFJK := GetArea()
FJK->(DbGoTo((cAliasPOP)->FJKREG))
/*
executa a a rotina do programa de pre-ordem de pago - arquivo FINA855.PRW*/
A855POP(2)
RestArea(aFJL)
RestArea(aFJK)
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850POPSELบAutor  ณMicrosiga           บFecha ณ 10/08/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850POPSel( nFlagMOD, nCtrlMOD, aFornec )
Local aArea		:= GetArea()
Local aAreaSE2		:= SE2->(GetArea())
Local cFilSE2		:= xFilial("SE2")
Local cFilFJL		:= xFilial("FJL")
Local lAviso		:= .F.

aRecnoSE2 := {}

If Type("cMarcaFJK") == "U"
	cMarcaFJK := ""
EndIf

SE2->(DbSetOrder(1))
FJL->(DbSetOrder(2)) // Filial + Pre-Ordem + Fornecedor + Loja + Prefixo + Numero + Parcela + Tipo

(cAliasPOP)->(DbGoTop())
While (cAliasPOP)->(!Eof())

	//Verifica se o registro foi selecionado
	If !Empty((cAliasPOP)->FJK_OK)

		//Verifica se o registro foi aprovado
		If  Empty((cAliasPOP)->FJK_ORDPAG) .And. Empty((cAliasPOP)->FJK_DTCANC) .And.;
			!Empty((cAliasPOP)->FJK_DTANLI) .And. (cAliasPOP)->FJK_OK == cMarcaFJK

			FJK->(DbGoTo((cAliasPOP)->FJKREG))
			If FJL->(MsSeek(cFilFJL + (cAliasPOP)->(FJK_PREOP )))
				While !(FJL->(Eof())) .And. (FJL->FJL_FILIAL == cFilFJL)
					If (FJL->FJL_PREOP == FJK->FJK_PREOP) .And. SE2->(MsSeek(cFilSE2 + FJL->FJL_PREFIX + FJL->FJL_NUM + FJL->FJL_PARCEL + FJL->FJL_TIPO + FJL->FJL_FORNEC + FJL->FJL_LOJA))
						SCU->(DbSetOrder(2))
						If cPaisloc <> "BRA" .And. SuperGetMv('MV_SOLNCP') .And. SE2->E2_TIPO == MVNOTAFIS ;
						   .And. SCU->(MsSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_NUM+SE2->E2_PREFIXO)).And. Empty(SCU->CU_NCRED)
						   
							HELP(" ",1,"SOLNCPAB")
						Else
							AAdd(aRecNoSE2,{SE2->E2_FILIAL,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->(RecNo()),FJL->FJL_VLRPRE,FJK->FJK_FORNEC,FJK->FJK_LOJA,"","","","",FJK->FJK_PREOP})
							RecLock("SE2",.F.)
							SE2->E2_OK := cMarcaE2
							SE2->(MsUnLock())
						Endif

					Endif
				FJL->(DbSkip())
				Enddo
			Endif
		Else
			lAviso := .T.

			//Remove a marca
			RecLock(cAliasPOP,.F.)
			(cAliasPOP)->FJK_OK := ""
			(cAliasPOP)->(MsUnlock())

		EndIf

    EndIf

(cAliasPOP)->(DbSkip())
EndDo

If lAviso
	If lMsg
		MsgInfo( STR0328 , STR0329 ) // "Operacao permitida apenas para pre ordens aprovadas." // "Preordem"
	Else
		cTxtRotAut		+= STR0328
		lMsErroAuto	:= .T.
	EndIf
EndIf

If !Empty(aRecnoSE2)
	F850PgAut(@nFlagMOD,@nCtrlMOD)
Endif

RestArea(aAreaSE2)
RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850PreOP บAutor  ณMicrosiga           บFecha ณ  08/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850PreOP()
Local aArea			:= GetArea()
Local aCpos			:= {}
Local aCores		:= {}
Local cArqTmp		:= ""
Local cQuery		:= ""
Local cAliasFJK		:= ""
Local aCamposMrk	:= {}
Local cFiltroUsr    := ""

Private cAliasPOP	:= ""
Private cMarcaFJK	:= ""

/*_*/
Aadd(aCores,{"Empty(FJK_DTCANC) .And. !Empty(FJK_DTANLI) .And. Empty(FJK_ORDPAG)"	,"ENABLE"})
Aadd(aCores,{"Empty(FJK_DTCANC) .And. Empty(FJK_DTANLI) .And. Empty(FJK_ORDPAG)"	,"BR_AMARELO"})
Aadd(aCores,{"Empty(FJK_DTCANC) .And. !Empty(FJK_ORDPAG)"							,"BR_AZUL"})
Aadd(aCores,{"!Empty(FJK_DTCANC)"													,"DISABLE"})
/*_*/
//Campos para montagem da MarkBrow
Aadd(aCamposMrk,{"FJK_OK"		,,""					,PesqPict("FJK","FJK_OK")		})
Aadd(aCamposMrk,{"FJK_FORNEC"	,,RetTitle("FJK_FORNEC"),PesqPict("FJK","FJK_FORNEC")	})
Aadd(aCamposMrk,{"FJK_LOJA"		,,RetTitle("FJK_LOJA")	,PesqPict("FJK","FJK_LOJA")		})
Aadd(aCamposMrk,{"A2_NOME"		,,RetTitle("A2_NOME")	,PesqPict("FJK","A2_NOME")		})
Aadd(aCamposMrk,{"FJK_PREOP"	,,RetTitle("FJK_PREOP")	,PesqPict("FJK","FJK_PREOP")	})
Aadd(aCamposMrk,{"FJK_ORDPAG"	,,RetTitle("FJK_ORDPAG"),PesqPict("FJK","FJK_ORDPAG")	})
Aadd(aCamposMrk,{"FJK_DTDIG"	,,RetTitle("FJK_DTDIG")	,PesqPict("FJK","FJK_DTDIG")	})
Aadd(aCamposMrk,{"FJK_DTANLI"	,,RetTitle("FJK_DTANLI"),PesqPict("FJK","FJK_DTCANC")	})
Aadd(aCamposMrk,{"FJK_DTCANC"	,,RetTitle("FJK_DTCANC"),PesqPict("FJK","FJK_DTCANC")	})
If cPaisLoc == "RUS"
	Aadd(aCamposMrk,{"FJK_BNKCOD"	,,RetTitle("FJK_BNKCOD"),PesqPict("FJK","FJK_BNKCOD")	})
	Aadd(aCamposMrk,{"FJK_BIKCOD"	,,RetTitle("FJK_BIKCOD"),PesqPict("FJK","FJK_BIKCOD")	})
	Aadd(aCamposMrk,{"FJK_BKNAME"	,,RetTitle("FJK_BKNAME"),PesqPict("FJK","FJK_BKNAME")	})
	Aadd(aCamposMrk,{"FJK_TPPGTO"	,,RetTitle("FJK_TPPGTO"),PesqPict("FJK","FJK_TPPGTO")	})
	Aadd(aCamposMrk,{"FJK_CONTA"	,,RetTitle("FJK_CONTA" ),PesqPict("FJK","FJK_CONTA"	)	})
	Aadd(aCamposMrk,{"FJK_RCNAME"	,,RetTitle("FJK_RCNAME"),PesqPict("FJK","FJK_RCNAME")	})
	Aadd(aCamposMrk,{"FJK_KPPPAY"	,,RetTitle("FJK_KPPPAY"),PesqPict("FJK","FJK_KPPPAY")	})
	Aadd(aCamposMrk,{"FJK_RECKPP"	,,RetTitle("FJK_RECKPP"),PesqPict("FJK","FJK_RECKPP")	})
	Aadd(aCamposMrk,{"FJK_PRIORI"	,,RetTitle("FJK_PRIORI"),PesqPict("FJK","FJK_PRIORI")	})
	Aadd(aCamposMrk,{"FJK_REASON"	,,RetTitle("FJK_REASON"),PesqPict("FJK","FJK_REASON")	})
	Aadd(aCamposMrk,{"FJK_VATCOD"	,,RetTitle("FJK_VATCOD"),PesqPict("FJK","FJK_VATCOD")	})
	Aadd(aCamposMrk,{"FJK_VATRAT"	,,RetTitle("FJK_VATRAT"),PesqPict("FJK","FJK_VATRAT")	})
	Aadd(aCamposMrk,{"FJK_VATAMT"	,,RetTitle("FJK_VATAMT"),PesqPict("FJK","FJK_VATAMT")	})
Endif
/*_*/
//Campos para geracao da tabela temporaria
Aadd(aCpos,{"FJK_OK"		,"C",TamSX3("FJK_OK")[1]		,TamSX3("FJK_OK")[2]		})
Aadd(aCpos,{"E2_RECNO"  ,"C",TamSX3("FJK_OK")[1]		,TamSX3("FJK_OK")[2]		})
Aadd(aCpos,{"FJK_FORNEC"	,"C",TamSX3("FJK_FORNEC")[1],TamSX3("FJK_FORNEC")[2]	})
Aadd(aCpos,{"FJK_LOJA"	,"C",TamSX3("FJK_LOJA")[1]	,TamSX3("FJK_LOJA")[2]	})
Aadd(aCpos,{"A2_NOME"	,"C",TamSX3("A2_NOME")[1]	,TamSX3("A2_NOME")[2]	})
Aadd(aCpos,{"FJK_PREOP"	,"C",TamSX3("FJK_PREOP")[1]	,TamSX3("FJK_PREOP")[2]	})
Aadd(aCpos,{"FJK_ORDPAG"	,"C",TamSX3("FJK_ORDPAG")[1],TamSX3("FJK_ORDPAG")[2]	})
Aadd(aCpos,{"FJK_DTDIG"	,"D",TamSX3("FJK_DTDIG")[1]	,TamSX3("FJK_DTDIG")[2]	})
Aadd(aCpos,{"FJK_DTANLI"	,"D",TamSX3("FJK_DTANLI")[1],TamSX3("FJK_DTANLI")[2]	})
Aadd(aCpos,{"FJK_DTCANC"	,"D",TamSX3("FJK_DTCANC")[1],TamSX3("FJK_DTCANC")[2]	})
If cPaisLoc == "RUS"
	Aadd(aCpos,{"FJK_BNKCOD"	,"C",TamSX3("FJK_BNKCOD")[1],TamSX3("FJK_BNKCOD")[2]	})                                                                                          
	Aadd(aCpos,{"FJK_BIKCOD"	,"C",TamSX3("FJK_BIKCOD")[1],TamSX3("FJK_BIKCOD")[2]	})
	Aadd(aCpos,{"FJK_BKNAME"	,"C",TamSX3("FJK_BKNAME")[1],TamSX3("FJK_BKNAME")[2]	})
	Aadd(aCpos,{"FJK_TPPGTO"	,"C",TamSX3("FJK_TPPGTO")[1],TamSX3("FJK_TPPGTO")[2]	})
	Aadd(aCpos,{"FJK_CONTA"		,"C",TamSX3("FJK_CONTA" )[1],TamSX3("FJK_CONTA")[2]	})
	Aadd(aCpos,{"FJK_RCNAME"	,"C",TamSX3("FJK_RCNAME")[1],TamSX3("FJK_RCNAME")[2]	})
	Aadd(aCpos,{"FJK_KPPPAY"	,"C",TamSX3("FJK_KPPPAY")[1],TamSX3("FJK_KPPPAY")[2]	})
	Aadd(aCpos,{"FJK_RECKPP"	,"C",TamSX3("FJK_RECKPP")[1],TamSX3("FJK_RECKPP")[2]	})
	Aadd(aCpos,{"FJK_PRIORI"	,"C",TamSX3("FJK_PRIORI")[1],TamSX3("FJK_PRIORI")[2]	})
	Aadd(aCpos,{"FJK_REASON"	,"C",TamSX3("FJK_REASON")[1],TamSX3("FJK_REASON")[2]	})
	Aadd(aCpos,{"FJK_VATCOD"	,"C",TamSX3("FJK_VATCOD")[1],TamSX3("FJK_VATCOD")[2]	})
	Aadd(aCpos,{"FJK_VATRAT"	,"C",TamSX3("FJK_VATRAT")[1],TamSX3("FJK_VATRAT")[2]	})
	Aadd(aCpos,{"FJK_VATAMT"	,"N",TamSX3("FJK_VATAMT")[1],TamSX3("FJK_VATAMT")[2]	})
Endif
Aadd(aCpos,{"FJKREG"		,"N",10						,0							})

//Creacion de Objeto 
cAliasPOP := "FJKTMP"
oTmpTable := FWTemporaryTable():New(cAliasPOP) //leem
oTmpTable:SetFields( aCpos ) //leem

aOrdem	:=	{"FJK_FORNEC","FJK_LOJA","FJK_PREOP"} //leem

oTmpTable:AddIndex("I1", aOrdem) //leem

If cPaisLoc == "ARG"
	aOrdem := {"FJK_OK"}
	oTmpTable:AddIndex("I2", aOrdem)
EndIf

oTmpTable:Create() //leem
cQuery := "select "
If cPaisLoc == 'RUS'
	cQuery += "FJK.FJK_BNKCOD,FJK.FJK_BIKCOD,FJK.FJK_BKNAME,FJK.FJK_DTPLAN,FJK.FJK_TPPGTO,"
	cQuery += "FJK.FJK_CONTA ,FJK.FJK_RCNAME,FJK.FJK_KPPPAY,FJK.FJK_RECKPP,FJK.FJK_PRIORI,"
	cQuery += "FJK.FJK_REASON,FJK.FJK_VATRAT,FJK.FJK_VATAMT,FJK.FJK_VATCOD, "
EndIf
cQuery += " FJK.FJK_FORNEC,FJK.FJK_LOJA,FJK.FJK_PREOP,FJK.FJK_ORDPAG,FJK.FJK_DTDIG,FJK.FJK_DTANLI,FJK.FJK_DTCANC,FJK.R_E_C_N_O_,SA2.A2_NOME from " + RetSQLName("FJK") + " FJK, " + RetSQLName("SA2") + " SA2"
cQuery += " where FJK_FILIAL = '" + xFilial("FJK") + "'"
cQuery += " and FJK_FORNEC >= '" + cForDe + "'"
cQuery += " and FJK_FORNEC <= '" + cForAte + "'"
cQuery += " and FJK_DTCANC = ''"
cQuery += " and FJK_DTANLI <> ''"
If cPaisLoc == 'RUS'
	cQuery += " and FJK_DTPLAN >= '"+ dTos(dDatade)  +"'"	
	cQuery += " and FJK_DTPLAN <= '"+ dTos(dDataAte) +"'"	
EndIf
If lFiltra   //considerar somente pre-ordens nao efetivadas
	cQuery += " and FJK_ORDPAG = ''"
Endif
cQuery += " and FJK.D_E_L_E_T_=''"
cQuery += " and  A2_FILIAL = '" + xFilial("SA2") + "'"
cQuery += " and A2_COD = FJK_FORNEC"
cQuery += " and A2_LOJA = FJK_LOJA"
cQuery += " and SA2.D_E_L_E_T_=''"

If ExistBlock("F850FLPRE")
	cFiltroUsr :=  ExecBlock("F850FLPRE",.F.,.F.)
Endif
If !Empty(cFiltroUsr)
	cQuery += " AND "+cFiltroUsr
Endif

cAliasFJK := GetNextAlias()
cQuery:= ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasFJK,.F.,.T.)
TCSetField(cAliasFJK,"FJK_DTCANC","D",8,0)
TCSetField(cAliasFJK,"FJK_DTANLI","D",8,0)
TCSetField(cAliasFJK,"FJK_DTDIG","D",8,0)
DbSelectArea(cAliasFJK)
(cAliasFJK)->(DbGoTop())
While !((cAliasFJK)->(Eof()))
	RecLock(cAliasPOP,.T.)
	Replace (cAliasPOP)->FJK_FORNEC	With (cAliasFJK)->FJK_FORNEC
	Replace (cAliasPOP)->FJK_LOJA	With (cAliasFJK)->FJK_LOJA
	Replace (cAliasPOP)->A2_NOME	With (cAliasFJK)->A2_NOME
	Replace (cAliasPOP)->FJK_PREOP	With (cAliasFJK)->FJK_PREOP
	Replace (cAliasPOP)->FJK_ORDPAG	With (cAliasFJK)->FJK_ORDPAG
	Replace (cAliasPOP)->FJK_DTDIG	With (cAliasFJK)->FJK_DTDIG
	Replace (cAliasPOP)->FJK_DTANLI	With (cAliasFJK)->FJK_DTANLI
	Replace (cAliasPOP)->FJK_DTCANC	With (cAliasFJK)->FJK_DTCANC
	Replace (cAliasPOP)->FJKREG		With (cAliasFJK)->R_E_C_N_O_
	(cAliasPOP)->(MsUnLock())
	(cAliasFJK)->(DbSkip())
Enddo
DbSelectArea(cAliasFJK)
DbCloseArea()
/*_*/
DbSelectArea(cAliasPOP)
(cAliasPOP)->(DbGoTop())
cMarcaFJK := GetMark()
cAliasTmp:= cAliasPOP
MarkBrow(cAliasPOP,"FJK_OK",,aCamposMrk,,cMarcaFJK,"F850MrkFJK()",.F.,,,Iif(cPaisloc = "ARG","F850MrkUNK()",),,,,aCores)

/*_*/
If oTmpTable <> Nil   //leem
	oTmpTable:Delete()  //leem
	oTmpTable := Nil //leem
EndIf //leem

RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINF850  บAutor  ณMicrosiga           บFecha ณ  08/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850POPLeg()
Local aLeg	:= {}

Aadd(aLeg,{"ENABLE", STR0330 }) // "Aprovadas"
Aadd(aLeg,{"BR_AZUL", STR0332 }) // "Efetivadas"
/*_*/
BrwLegenda(cCadastro, STR0334 ,aLeg)//"Status das pr้-ordens de pago"
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850MrkFJKบAutor  ณMicrosiga           บ Data ณ  07/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca todos os itens da MarkBrow                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850MrkFJK()
Local aAreaAnt := GetArea()
Local lMarca   := NIL

Default cMarcaFJK := ""

(cAliasPOP)->(DbGoTop())
While (cAliasPOP)->(!Eof())

	If cPaisLoc == "ARG"
		F850MrkUNK(.T.)
	Else
		lMarca := ((cAliasPOP)->FJK_OK == cMarcaFJK)
	
		RecLock(cAliasPOP,.F.)
		(cAliasPOP)->FJK_OK := If(lMarca,"",cMarcaFJK )
		(cAliasPOP)->(MsUnLock())
	EndIf

(cAliasPOP)->(DbSkip())
EndDo

MarkBRefresh()
RestArea(aAreaAnt)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850MrkUNKบAutor  ณMicrosiga           บ Data ณ  03/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca un registro                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850MrkUNK(lAll)   
Local aAreaAnt := GetArea()  
Local aAreaSE2:=  SE2->(GetArea())         
Local aAreaFJL:=  FJL->(GetArea())  
Local lRet     := .T.
Local lMarca   := .T.

Default lAll := .F.

SE2->(DbSetOrder(1))
FJL->(DbSetOrder(2)) // Filial + Pre-Ordem + Fornecedor + Loja + Prefixo + Numero + Parcela + Tipo


If Type("cMarcaFJK") == "U"
	cMarcaFJK := ""
EndIf

lMarca := ((cAliasPOP)->FJK_OK == cMarcaFJK) //Verificar si el registro esta marcado
	

If  FJL->(MsSeek(xFilial("FJL") + (cAliasPOP)->(FJK_PREOP )))
	While !(FJL->(Eof())) .And. (FJL->FJL_FILIAL == xFilial("FJL")) 
		If (FJL->FJL_PREOP == (cAliasPOP)->FJK_PREOP) .And. SE2->(MsSeek(xFilial("SE2") + FJL->FJL_PREFIX + FJL->FJL_NUM + FJL->FJL_PARCEL + FJL->FJL_TIPO + FJL->FJL_FORNEC + FJL->FJL_LOJA))
			If VldFchCBU(.T.)     
				If  !lMarca //No esta marcado, verificar si se debe marcar
					lRet := VldPagCBU(1)
					If lRet
						aAdd(aPagConCBU, {SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->( RecNo() )})
					EndIf   
				Else //Desmarcar el registro 
					If Len(aPagConCBU) > 0
						nLoop := aScan(aPagConCBU,{|x| x[5] == SE2->( RecNo() )})
						aDel(aPagConCBU, nLoop)
						aSize(aPagConCBU, Len(aPagConCBU)-1)
						nLoop := 0
					EndIf	
				Endif
			Else      
				If !lMarca
					lRet := VldPagCBU(2)
					If lRet
						aAdd(aPagSinCBU, {SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->( RecNo() )})
					EndIf   
				Else 
					If Len(aPagSinCBU) > 0
						nLoop := aScan(aPagSinCBU,{|x| x[5] == SE2->( RecNo() )})
						aDel(aPagSinCBU, nLoop)
						aSize(aPagSinCBU, Len(aPagSinCBU)-1)
						nLoop := 0
					EndIf
				Endif
			EndIf
			If (cPaisLoc $ "ARG|RUS") .And. (lRet)
				lMarca := ((cAliasPOP)->FJK_OK == cMarcaFJK)
				If !lMarca
					lRet := VldDocPag(SE2->(RecNo()), lAll)
				EndIf
			EndIf
			Exit
		Endif	
	FJL->(DbSkip())
	Enddo   

	If lRet        
		lMarca := ((cAliasPOP)->FJK_OK == cMarcaFJK)
		RecLock(cAliasPOP,.F.)
		(cAliasPOP)->FJK_OK := If(lMarca,"",cMarcaFJK )
		(cAliasPOP)->(MsUnLock())
	Endif
	MarkBRefresh()	
   
EndIf        	


RestArea(aAreaAnt)  
RestArea(aAreaSE2)     
RestArea(aAreaFJL)   

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA850MarkChq บAutor  ณ Jose Lucas     บ Data ณ  17/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marcar e desmarcar todos os cheques do objeto Markbrow.    บฑฑ
ฑฑบ          ณ 					                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ fA850MarkChq()						                      ณฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ 														      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fA850bAll(cMarca,lInverte,oDlg)
Local nReg := RecNo()
dbGoTop()
dbEval({|| TRB->OK := If(Empty(TRB->OK) .and. TRB->VENCREA <= ( dDataBase + 30 ), "x", " ")})
dbGoto(nReg)
oMark:oBrowse:Refresh()
oDlg:Refresh()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F850VctoCheque  บAutor  ณ Jose Lucas  บ Data ณ  17/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualizar os objetos e vetores เ partir das mudan็as dos   บฑฑ
ฑฑบ          ณ crit้rios de vencimentos e aplica็ใo de descontos          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ F850VctoCheque()	                 	                      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpC1 = cMarca										      ณฑฑ
ฑฑณ          ณ ExpC1 = lInverte										      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VctoCheque(nUnico,nMultiplo,aSE2,nPosSE2)
Local aSavArea		:= GetArea()
Local aAux				:= Array(8)
Local lRet				:= .T.
Local dDtEmissao		:= dDataBase
Local dDtVencto		:= dDataBase
Local nA				:= 0
Local nB				:= 0
Local nC				:= 0
Local nCheques		:= 0
Local nPosPgto		:= 0
Local nLenAcol		:= 0
Local nPosFornec		:= 0
Local nPosLoja		:= 0
Local nPosPrefix		:= 0
Local nPosNum			:= 0
Local nPosParcel		:= 0
Local nPosValor		:= 0
Local nPosVencto		:= 0
Local nPosVenRea		:= 0
Local nPosVenCh		:= 0
Local nPosVlrCh		:= 0
Local nPosTipoPg		:= 0
Local nNumerario		:= 0.00
Local nTotValor		:= 0.00
Local nMediaPond		:= 0
Local aVenctos		:= {}
Local aCheques		:= {}
Local aPagares		:= {}
Local nPagares		:= 0
Local nUsado			:= 0
Local cObjPg			:= ""

Default nUnico		:= oUnico:nAt
Default nMultiplo		:= oMultiplo:nAt
Default aSE2			:= {}
Default nPosSE2		:= 0

If IsInCallStack("F850PgMas")
	cObjPg := "oGetPgMs"
Else
	cObjPg := "oGetDad1"
EndIf


nPosFornec		:= GDFieldPos("E2_FORNECE"	,oGetDad0:aHeader)
nPosLoja		:= GDFieldPos("E2_LOJA"	  	,oGetDad0:aHeader)
nPosPrefix		:= GDFieldPos("E2_PREFIXO"	,oGetDad0:aHeader)
nPosNum			:= GDFieldPos("E2_NUM"		,oGetDad0:aHeader)
nPosParcel		:= GDFieldPos("E2_PARCELA"	,oGetDad0:aHeader)
nPosValor		:= GDFieldPos("E2_VALOR"  	,oGetDad0:aHeader)
nPosVencto		:= GDFieldPos("E2_VENCTO" 	,oGetDad0:aHeader)
nPosVenRea		:= GDFieldPos("E2_VENCREA"	,oGetDad0:aHeader)
nPosVenCh		:= GDFieldPos("EK_VENCTO"	,&cObjPg:aHeader)
nPosVlrCh		:= GDFieldPos("EK_VALOR"		,&cObjPg:aHeader)
nPosTipoPg		:= GDFieldPos("EK_TIPO"		,&cObjPg:aHeader)

nUsado			:= Len(&cObjPg:aHeader)

nLenAcol := Len(&cObjPg:aCols)
For nC := 1 To nLenAcol
	nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(&cObjPg:aCols[nC,nPosTipoPg])})
	If nPosPgto > 0
		If AllTrim(aFormasPgto[nPosPgto,2]) $ "CH" .And. aFormasPgto[nPosPgto,8] == "2"
			Aadd(aCheques,nC)
		ElseIf AllTrim(aFormasPgto[nPosPgto,2]) $ "DC" //Pagar้
			Aadd(aPagares,nC)
		EndIf
	Endif
Next
nCheques := Len(aCheques)
If nCheques > 0
	If Len(aSE2) > 0
		If nPosSE2 == 0
			nPosSE2 := 1
			nB	:= Len(aSE2)
		Else
			nB	:= nPosSE2
		EndIf

		For nA := nPosSE2 to nB
			For nC := 1 to Len(aSE2[nA][1])
				aAux[1] := aSE2[nA,1,nC,_PREFIXO]
				aAux[2] := aSE2[nA,1,nC,_NUM]
				aAux[3] := aSE2[nA,1,nC,_PARCELA]
				aAux[4] := aSE2[nA,1,nC,_FORNECE]
				aAux[5] := aSE2[nA,1,nC,_LOJA]
				aAux[6] := aSE2[nA,1,nC,_VALOR]
				aAux[7] := aSE2[nA,1,nC,_EMISSAO]
				aAux[8] := aSE2[nA,1,nC,_VENCTO]
				aAdd(aVenctos,aAux)
				aAux := Array(8)
			Next nC
		Next nA
		aVenctos := aSort( aVenctos,,,{ |x,y| DTOS(x[8]) < DTOS(y[8]) } )
	ElseIf !Empty(oGetDad0:aCols)
		For nA := 1 To Len(oGetDad0:aCols)
			AADD(aVenctos,{oGetDad0:aCols[nA][nPosPrefix],oGetDad0:aCols[nA][nPosNum],oGetDad0:aCols[nA][nPosParcel],oGetDad0:aCols[nA][nPosFornec],;
			               oGetDad0:aCols[nA][nPosLoja],oGetDad0:aCols[nA][nPosValor],oGetDad0:aCols[nA][nPosVencto],oGetDad0:aCols[nA][nPosVencto]})
		Next nA
		aVenctos := aSort( aVenctos,,,{ |x,y| x[4]+x[5]+DTOS(x[8]) < y[4]+y[5]+DTOS(y[8]) } )
	Endif
	If nCheques == 1
		If nUnico == 2		//Pela 1a. data de vencimento
			dDtVencto := aVenctos[1][8]
		ElseIf nUnico == 3	//Pela ๚ltima data de vencimento
			dDtVencto := aVenctos[Len(aVenctos)][8]
		ElseIf nUnico == 4			//Pela data ponderada (vencimento m้dio)
			For nA := 1 To Len(aVenctos)
				nNumerario += aVenctos[nA][6] * (aVenctos[nA][8] - dDatabase)
				nTotValor  += aVenctos[nA][6]
			Next nA
			If nNumerario > 0 .and. nTotValor > 0
				nMediaPond += Round(nNumerario/nTotValor,0)
			EndIf
			dDtVencto := dDtEmissao + nMediaPond
		ElseIf nUnico == 1 //Preenchimento Manual
			If !Empty(&cObjPg:aCols[aCheques[1],nPosVenCh])
				dDTVencto := &cObjPg:aCols[aCheques[1],nPosVenCh]
			EndIf
		EndIf
		&cObjPg:aCols[aCheques[1],nPosVenCh] := dDTVencto
	Else
		If nMultiplo == 2
			nA := 0
			nC := 0
			nLenAcol := Len(aVenctos)
			While (nA < nLenAcol) .And. (nC < nCheques)
				nA++
				nC++
				&cObjPg:aCols[aCheques[nC],nPosVenCh] := aVenctos[nA,8]
			Enddo
		Endif
	Endif
	&cObjPg:Refresh()
Endif

nPagares := Len(aPagares)
If nPagares > 0
	If !Empty(oGetDad0:aCols)
		For nA := 1 To Len(oGetDad0:aCols)
			AADD(aVenctos,{oGetDad0:aCols[nA][nPosPrefix],oGetDad0:aCols[nA][nPosNum],oGetDad0:aCols[nA][nPosParcel],oGetDad0:aCols[nA][nPosFornec],;
			               oGetDad0:aCols[nA][nPosLoja],oGetDad0:aCols[nA][nPosValor],oGetDad0:aCols[nA][nPosVencto],oGetDad0:aCols[nA][nPosVencto]})
		Next nA
		aVenctos := aSort( aVenctos,,,{ |x,y| x[4]+x[5]+DTOS(x[8]) < y[4]+y[5]+DTOS(y[8]) } )
	Endif
	If nPagares == 1
		If nUnico == 2		//Pela 1a. data de vencimento
			dDtVencto := aVenctos[1][8]
		ElseIf nUnico == 3	//Pela ๚ltima data de vencimento
			dDtVencto := aVenctos[Len(aVencPagr)][8]
		ElseIf	 nUnico == 4		//Pela data ponderada (vencimento m้dio)
			For nA := 1 To Len(aVenctos)
				nNumerario += aVenctos[nA][6] * (aVenctos[nA][8] - dDatabase)
				nTotValor  += aVenctos[nA][6]
			Next nA
			If nNumerario > 0 .and. nTotValor > 0
				nMediaPond += Round(nNumerario/nTotValor,0)
			EndIf
			dDtVencto := dDtEmissao + nMediaPond
		EndIf
		&cObjPg:aCols[aPagares[1],nPosVenCh] := dDTVencto
	Else
		If nMultiplo == 2
			nA := 0
			nC := 0
			nLenAcol := Len(aVenctos)
			While (nA < nLenAcol) .And. (nC < nPagares)
				nA++
				nC++
				&cObjPg:aCols[aPagares[nC],nPosVenCh] := aVenctos[nA,8]
			Enddo
		Endif
	Endif
	&cObjPg:Refresh()
Endif

/*_*/
aPagos[oLbx:nAt,H_UNICOCHQ] := nUnico
aPagos[oLbx:nAt,H_MULTICHQ] := nMultiplo
/*_*/
RestArea(aSavArea)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F850VldVct      บAutor  ณ Marcos Berto  บ Data ณ  30/08/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo das datas de vencimento dos cheques				 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ F850VldVct()	                 	                             ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function F850VldVct(nUnico, nMultiplo, lOK, aDados, lOPRotAut)

Local aVctos 		:=	{}
Local aDocs		:=	{}
Local cCampo		:=	ReadVar()
Local dDtVcto
Local lRet			:=	.T.
Local lValid 		:=	.F.
Local lDispensa	:=	.F.
Local lVldGrv		:=	.F.
Local nX			:=	0
Local nDias		:=	0
Local nPosPgto		:=	0

DEFAULT nUnico		:=	0
DEFAULT nMultiplo	:=	0
DEFAULT lOk		:=	.F.
DEFAULT aDados		:=	{}
Default lOPRotAut	:=	.F.

If IsInCallStack("F850PgMas")
	cObjPg := "oGetPgMs"
	aDocs 	:= oGetPgMs:aCols

	//Dispensa a valida็ใo do cแlculo automatico por OP quando for Pago Massivo - Data em Branco
	If nUnico > 1 .Or. nMultiplo > 1
		lDispensa := .T.
	EndIf
ElseIf Len(aDados) > 0
	cObjPg 	:= "oGetDad1"
	aDocs 		:= aDados
	lVldGrv 	:= .T.
Else
	cObjPg := "oGetDad1"
	aDocs 	:= oGetDad1:aCols
EndIf

If lOPRotAut
	nPosTipo	:= 1
	nPosEmi	:= 7
	nPosVcto	:= 8
Else
	nPosTipo	:= Ascan(&cObjPg:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
	nPosEmi	:= Ascan(&cObjPg:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
	nPosVcto	:= Ascan(&cObjPg:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
Endif

If Type("aFormasPgto") == "A"
	If cCampo == "M->EK_VENCTO"
		nPosPgto := Ascan(aFormasPgto,{|x| AllTrim(x[1]) == AllTrim(&cObjPg:aCols[&cObjPg:nAt,nPosTipo])})
		If nPosPgto > 0
			aAdd(aVctos,{&cObjPg:nAt,aFormasPgto[nPosPgto,2],aFormasPgto[nPosPgto,8]}) //Valida somente a data que esta sendo editada
			lValid := .T.
		EndIf
	Else
		For nX := 1 to Len(aDocs)
			nPosPgto := Ascan(aFormasPgto,{|x| AllTrim(x[1]) == AllTrim(aDocs[nX,nPosTipo])})
			If nPosPgto > 0
				aAdd(aVctos,{nX,aFormasPgto[nPosPgto,2],aFormasPgto[nPosPgto,8]}) //Posi็ใo em que deve ser validada a data calculada ou informada
			EndIf
		Next nX

		//Preenchidos so serao validado ao informar a data
		If lOk .Or. lVldGrv
			lValid := .T.
		ElseIf Len(aVctos) = 1 .And. nUnico > 1
			lValid := .T.
		ElseIf Len(aVctos) > 1 .And. nMultiplo > 1
			lValid := .T.
		EndIf

	EndIf
EndIf

If !lDispensa
	For nX:= 1 to Len(aVctos)

		If cCampo == "M->EK_VENCTO"
			dDtVcto := M->EK_VENCTO
		Else
			dDtVcto := aDocs[aVctos[nX][1],nPosVcto]
		EndIf

		Do Case
			Case lValid .And. aVctos[nX][2] $ MVCHEQUE .And. AllTrim(aVctos[nX][3]) == "2"
				nDias :=  dDtVcto - aDocs[aVctos[nX][1],nPosEmi]

				If (nDias >= 1) .And. (nDias <= 360)
					lRet := .T.
				Else
					lRet := .F.
					Exit
				EndIf
			Case aVctos[nX][2] $ MVCHEQUE .And. AllTrim(aVctos[nX][3]) == "1" .And. dDtVcto <> aDocs[aVctos[nX][1],nPosEmi]
				lRet := .F.
				Exit
			Case !(aVctos[nX][2] $ MVCHEQUE) .And. AllTrim(aVctos[nX][3]) == "2" .And. dDtVcto <= aDocs[aVctos[nX][1],nPosEmi]
				lRet := .F.
				Exit
			Case !(aVctos[nX][2] $ MVCHEQUE) .And. AllTrim(aVctos[nX][3]) == "1" .And. dDtVcto <> aDocs[aVctos[nX][1],nPosEmi]
				lRet := .F.
				Exit
			Case Empty(aVctos[nX][3]) .And. dDtVcto < aDocs[aVctos[nX][1],nPosEmi]
				lRet := .F.
				Exit
		EndCase

	Next nX
EndIf

If (!lRet .And. !lVldGrv) .OR. ( cPaisLoc == "ARG" .and. cCampo == "M->EK_VENCTO" .and. (  ;
	( &cCampo <  Criavar(AllTrim(oGetDad1:aHeader[Ascan(oGetDad1:aHeader,{|X| Alltrim(x[2]) == "EK_EMISSAO"}),2])) .AND. Posicione("FJS",1,xFilial("FJS")+oGetDad1:aCols[oGetDad1:NAT,Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})],"FJS_TPVAL") !='2' )      .OR.  ;
	( &cCampo <= Criavar(AllTrim(oGetDad1:aHeader[Ascan(oGetDad1:aHeader,{|X| Alltrim(x[2]) == "EK_EMISSAO"}),2])) .AND. Posicione("FJS",1,xFilial("FJS")+oGetDad1:aCols[oGetDad1:NAT,Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})],"FJS_TPVAL") =='2' )  )  )
	MsgAlert(STR0370,STR0223) //Data de vencimento calculada/informada invแlida. Verifique outra forma de cแlculo ou informe uma data vแlida.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA8503TudOk     บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consistir o aCols da MsNewGetDados (aHeaderTRB)  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA8503TudOk(ExpO,ExpA)		                      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpO = Objeto oGetData								      ณฑฑ
ฑฑณ          ณ ExpA = aArray aHeaderTRB								      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fA8503TudOk(oGetData,aHeaderTRB)
Local nA := 0
Local nPosVencRea := GDFieldPos("E2_VENCREA" ,aHeaderTRB)
Local lRet        := .T.
For nA := 1 To Len(oGetData:aCols)
	If Empty(oGetData:aCols[nA][nPosVencRea])
		MsgAlert(STR0250,STR0223) 	//"Informe a data de vencimento"###"Aten็ใo"
		lRet := .F.
	EndIf
Next nA
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA8503TudOk     บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consistir o aCols da MsNewGetDados (aHeaderTRB)  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA8503TudOk(ExpO,ExpA)		                      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpO = Objeto oGetData								      ณฑฑ
ฑฑณ          ณ ExpA = aArray aHeaderTRB								      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fA8504TudOk(cBanco,cAgencia,cConta,cNumTalao)
Local lRet        := .T.
If Empty(cBanco) .and. Empty(cAgencia) .and. Empty(cConta) .and. Empty(cNumTalao)
	lRet := .F.
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA8501LinOk     บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consistir a linha digitada na MsNewGetDados (aHeaderSE2)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA8501LinOk(ExpO,ExpA)		                      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpO = Objeto oGetDad0								      ณฑฑ
ฑฑณ          ณ ExpA = aArray aHeaderSE2								      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fA8501LinOk(oGetDad0,aHeaderSE2)
Local lRet := .T.
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA8501TudOk     บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consistir o aCols da MsNewGetDados (aHeaderSE2)			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA8501TudOk(ExpO,ExpA)		                      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpO = Objeto oGetDad0								      ณฑฑ
ฑฑณ          ณ ExpA = aArray aHeaderSE2								      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fA8501TudOk(oGetDad0,aHeaderSE2)
Local lRet := .T.
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA8502LinOk     บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consistir a linha digitada na MsNewGetDados (aHeaderSEK)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA8502LinOk(ExpO,ExpA)		                      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpO = Objeto oGetDad0								      ณฑฑ
ฑฑณ          ณ ExpA = aArray aHeaderSEK								      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fA8502LinOk(oGetDad1,aHeaderSEK)
Local lRet := .T.
Local nPosTipo  := GDFieldPos("EK_TIPO")
Local nPosBanco := GDFieldPos("EK_BANCO")
Local nPosAgenc := GDFieldPos("EK_AGENCIA")
Local nPosConta := GDFieldPos("EK_CONTA")
Local nPosTalao := GDFieldPos("EK_TALAO")
Local nLinha	:= oGetDad1:oBrowse:nAt

If Empty(oGetDad1:aCols[nLinha][nPosTipo])
	MsgAlert(STR0254,STR0223) //"Informe o modo de pago."###"Atenci๓n"
	lRet := .F.
EndIf
If Empty(oGetDad1:aCols[nLinha][nPosBanco]) .or. Empty(oGetDad1:aCols[nLinha][nPosAgenc]) .or. Empty(oGetDad1:aCols[nLinha][nPosConta])
	MsgAlert(STR0255,STR0223) //"Informe Banco, Agencia e Conta."###"Atenci๓n"
	lRet := .F.
EndIf
If oGetDad1:aCols[nLinha][nPosTipo] == "CH " .and. Empty(oGetDad1:aCols[nLinha][nPosTalao])
	MsgAlert(STR0256,STR0223) //"Informe o numero do Talใo"###"Atenci๓n"
	lRet := .F.
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA8502TudOk     บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consistir o aCols da MsNewGetDados (aHeaderSEK)			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA8502TudOk(ExpO,ExpA)		                      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpO = Objeto oGetDad1								      ณฑฑ
ฑฑณ          ณ ExpA = aArray aHeaderSEK								      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fA8502TudOk(oGetDad1,aHeaderSEK)
Local lRet := .T.
Local nPosBanco := GDFieldPos("EK_BANCO")
Local nPosAgenc := GDFieldPos("EK_AGENCIA")
Local nPosConta := GDFieldPos("EK_CONTA")
Local nPosTalao := GDFieldPos("EK_TALAO")
Local nPosVl 	:=  GDFieldPos("EK_VALOR")
Local nA   := 0

For nA := 1 To Len(oGetDad1:aCols)
	If !(Empty(oGetDad1:aCols[nA][nPosVl])) .and. Empty(oGetDad1:aCols[nA][nPosTipo])
		MsgAlert(STR0254,STR0223) //"Informe o modo de pago."###"Atenci๓n"
		lRet := .F.
	EndIf
	If !(Empty(oGetDad1:aCols[nA][nPosVl])) .and. (Empty(oGetDad1:aCols[nA][nPosBanco]) .or. Empty(oGetDad1:aCols[nA][nPosAgenc]) .or. Empty(oGetDad1:aCols[nA][nPosConta]))      
		MsgAlert(STR0255,STR0223) //"Informe Banco, Agencia e Conta."###"Atenci๓n"
		lRet := .F.
	EndIf
	If oGetDad1:aCols[nA][nPosTipo] == "CH " .and. Empty(oGetDad1:aCols[nA][nPosTalao])
		MsgAlert(STR0256,STR0223) //"Informe o numero do Talใo"###"Atenci๓n"
		lRet := .F.
	EndIf
Next nA
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA850VldTipo    บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validar o tipo da tabela de Modo de Pagos.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA850VldTipo()				                      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ 														      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VldTipo(lPA)
Local nPos		  := 0
Local aSavArea  := GetArea()
Local cTipo	  := &(ReadVar())
Local lRet      := .T.

Default lPA	  := .F.

FJS->(dbSetOrder(1))
If ! FJS->(MsSeek(xFilial("FJS")+cTipo))
	MsgAlert(STR0251,STR0223) //"Modo de pagamento nใo cadastrado."###"Atenci๓n"
	lRet := .F.
Else
	If !(FJS->FJS_CARTE $ "23")
		MsgAlert( STR0335 + "." + CRLF + STR0336 + ".",STR0223) // "Forma de pagamento nใo permitida" // "Utilize apenas formas permitidas para carteira a pagar"
		lRet := .F.
	ElseIf !IsInCallStack("F850PgMas")
		F850LinPgto(cTipo,lPA)
		lRet := .T.
	Endif

	//Valida o tipo informado
	If cPaisLoc $ "ARG|RUS|" .And. Type("cOpcElt") <> "U"
		If (FJS->FJS_PGTELT == "1" .And. cOpcElt <> "1") .Or. (FJS->FJS_PGTELT <> "1" .And. cOpcElt == "1")
			MsgAlert( STR0335 + ".",STR0223) // "Forma de pagamento nใo permitida"
			lRet := .F.
		EndIf
	EndIf

	//Variแvel cTalaoCh utilizada para o filtro dos talonarios por tipo configurado
	If Type("cTalaoCh") == "C" .And. cPaisLoc <> "BRA"
		If FJS->FJS_TPVAL == "2"
			If cPaisLoc $ "ARG|RUS|"
				If FJS->FJS_PGTELT == "1" //Sim
					cTalaoCh := "4" //Cheque eletronico diferido
				Else
					cTalaoCh := "3" //Cheque diferido
				EndIf
			Else
				cTalaoCh := "3" //Cheque diferido
			EndIf
		ElseIf FJS->FJS_TPVAL == "1"
			If cPaisLoc $ "ARG|RUS|"
				If FJS->FJS_PGTELT == "1" //Sim
					cTalaoCh := "2" //Cheque eletronico comum
				Else
					cTalaoCh := "1" //Cheque comum
				EndIf
			Else
				cTalaoCh := "1" //Cheque comum
			EndIf
		Else
			cTalaoCh := "" //Se nใo foi cadastrado o tipo do valor, nใo exibe talonarios
		EndIf
	EndIf

EndIf

If cPaisLoc == "ARG" .And. !lPA .And. !lPagoCBU
	If Len(aPagConCBU) > 0
		MsgAlert(STR0405, STR0223)
		lPagoCBU := .T.
	EndIf
EndIf

If lRet .and. cPaisLoc == "ARG"
	lRet := F850LnOK() //Validaci๓n Tipo de titulo.
EndIF

RestArea(aSavArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850LinPgtoบAutor  ณMicrosiga          บFecha ณ  09/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850LinPgto(cTipo,lPA)
Local nPosCpo	:= 0
Local nPosDoc	:= 0
Local nPosMoedPgto:=0
Local nDel		:= 0

Default cTipo	:= ""
Default lPA		:= .F.

F850Lin()
nPosMoedPgto :=Ascan(oGetDad1:aHeader,{|acabec| Alltrim(acabec[2]) == "MOEDAPGTO"})
If  oGetDad1:aCols[oGetDad1:nAt,nPosMoedPgto] == 0 
	oGetDad1:aCols[oGetDad1:nAt,nPosMoedPgto]:=1     
	oGetDad1:Refresh()
Endif 
If Empty(cTipo)
	nPosCpo := Ascan(oGetDad1:aHeader,{|acabec| Alltrim(acabec[2]) == "EK_TIPO"})
	If nPosCpo <> 0
		cTipo := oGetDad1:aCols[oGetDad1:nAt,nPosCpo]
	Endif
Endif
/*_*/
nPosDoc := Ascan(aFormasPgto,{|pgto| Alltrim(pgto[1]) == AllTrim(cTipo)})
nDel := 0
If nPosDoc > 0 .And. AllTrim(aFormasPgto[nPosDoc,2]) == "CH"
	nPosCpo := Ascan(oGetDad1:aAlter,"EK_NUM")
	If nPosCpo > 0
		Adel(oGetDad1:aAlter,nPosCpo)
		nPosCpo := Ascan(oGetDad1:aHeader,{|acabec| Alltrim(acabec[2]) == "EK_NUM"})
		oGetDad1:aCols[oGetDad1:nAt,nPosCpo] := Space(TamSX3("EK_NUM")[1])
		nDel++
	Endif
	nPosCpo := Ascan(oGetDad1:aAlter,"EK_PREFIXO")
	If nPosCpo > 0
		Adel(oGetDad1:aAlter,nPosCpo)
		nPosCpo := Ascan(oGetDad1:aHeader,{|acabec| Alltrim(acabec[2]) == "EK_PREFIXO"})
		oGetDad1:aCols[oGetDad1:nAt,nPosCpo] := Space(TamSX3("EK_PREFIXO")[1])
		nDel++
	Endif
	nPosCpo := Ascan(oGetDad1:aAlter,"EK_PARCELA")
	If nPosCpo > 0
		Adel(oGetDad1:aAlter,nPosCpo)
		nPosCpo := Ascan(oGetDad1:aHeader,{|acabec| Alltrim(acabec[2]) == "EK_PARCELA"})
		oGetDad1:aCols[oGetDad1:nAt,nPosCpo] := Space(TamSX3("EK_PARCELA")[1])
		nDel++
	Endif
	If nDel > 0
		Asize(oGetDad1:aAlter,Len(oGetDad1:aAlter) - nDel)
	Endif
	nPosCpo := Ascan(oGetDad1:aAlter,"EK_TALAO")
	If nPosCpo == 0
		Aadd(oGetDad1:aAlter,"EK_TALAO")
	Endif
	If !lPA
		F850VctoCheque()
	Endif
Else
	nPosCpo := Ascan(oGetDad1:aAlter,"EK_TALAO")
	If nPosCpo > 0
		Adel(oGetDad1:aAlter,nPosCpo)
		Asize(oGetDad1:aAlter,Len(oGetDad1:aAlter) - 1)
		nPosCpo := Ascan(oGetDad1:aHeader,{|acabec| Alltrim(acabec[2]) == "EK_TALAO"})
		oGetDad1:aCols[oGetDad1:nAt,nPosCpo] := Space(TamSX3("EK_TALAO")[1])
	Endif
	nPosCpo := Ascan(oGetDad1:aAlter,"EK_NUM")
	If nPosCpo == 0
		Aadd(oGetDad1:aAlter,"EK_NUM")
	Endif
	nPosCpo := Ascan(oGetDad1:aAlter,"EK_PREFIXO")
	If nPosCpo == 0
		Aadd(oGetDad1:aAlter,"EK_PREFIXO")
	Endif
	nPosCpo := Ascan(oGetDad1:aAlter,"EK_PARCELA")
	If nPosCpo == 0
		Aadd(oGetDad1:aAlter,"EK_PARCELA")
	Endif
	nPosCpo := Ascan(oGetDad1:aHeader,{|acabec| Alltrim(acabec[2]) == "FRE_TIPO"})
	If nPosCpo > 0
		oGetDad1:aCols[oGetDad1:nAt,nPosCpo] := Space(Len(SX3->X3_DESCRIC))
	Endif

Endif
Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA850VldTalao   บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validar o tipo da tabela de Modo de Pagos.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA850VldTalao(ExpC1,ExpC2,ExpC3)			          ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpC1 = cBanco										      ณฑฑ
ฑฑณ          ณ ExpC2 = cAgencia										      ณฑฑ
ฑฑณ          ณ ExpC3 = cConta										      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VldTalao()
Local aSavArea 	:= GetArea()
Local cNumTalao 	:= &(ReadVar())
Local nPosTipo 	:= GDFieldPos("EK_TIPO")
Local nPosBanco 	:= GDFieldPos("EK_BANCO")
Local nPosAgenc 	:= GDFieldPos("EK_AGENCIA")
Local nPosConta 	:= GDFieldPos("EK_CONTA")
Local nPosTalao 	:= GDFieldPos("EK_TALAO")
Local nPosTipCh	:= GDFieldPos("FRE_TIPO")
Local nPosNum		:= GDFieldPos("EK_NUM")
Local nPosPref	:= GDFieldPos("EK_PREFIXO")
Local nPosVenc  := GDFieldPos("EK_VENCTO")
Local lRet      	:= .T.

cBanco		:= oGetDad1:aCols[oGetDad1:nAt,nPosBanco]
cAgencia	:= oGetDad1:aCols[oGetDad1:nAt,nPosAgenc]
cConta		:= oGetDad1:aCols[oGetDad1:nAt,nPosConta]
cNumTalao	:= &(ReadVar())

nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(aCols[oGetDad1:nAt,nPosTipo])})

dbselectArea("FRE")
FRE->(dbSetOrder(3)) // Filial + Banco + Ag๊ncia + Conta + Talใo
If !FRE->(MsSeek(xFilial("FRE")+cBanco+cAgencia+cConta+cNumTalao))

		MsgAlert(STR0337 , STR0223 ) //"Talใo de cheques nใo cadastrado."###"Atenci๓n" //
		lRet := .F.
ElseIf (FRE->FRE_TIPO $ "1|2" .And. aFormasPgto[nPosPgto][8] == "2") .Or.;  // 1 e 2 = Comum / Eletronico
		(FRE->FRE_TIPO $ "3|4" .And. aFormasPgto[nPosPgto][8] == "1")       // 3 = Diferido

		MsgAlert( STR0338 , STR0223 ) // "Chequera no disponible"
		lRet := .F.
Else
	If !(FRE->FRE_STATUS $ "2 ")
		MsgAlert( STR0338 , STR0223 ) // "Chequera no disponible"
		lRet := .F.
	Else
		lRet := .T.
		If nPosTipCh > 0
			oGetDad1:aCols[oGetDad1:nAt,nPosTipCh] := Lower(X3COMBO("FRE_TIPO",FRE->FRE_TIPO))
		Endif
	Endif
EndIf

if cPaisLoc == "ARG" .and. AllTrim(aCols[oGetDad1:nAt,nPosTipo]) == "CHD"
	aCols[oGetDad1:nAt,nPosVenc] := aCols[oGetDad1:nAt,nPosVenc] +1
endif

RestArea(aSavArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA850   บAutor  ณMicrosiga           บ Data ณ  08/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850SmlCtb(aSE2)
Local oDlg
Local oBrwTit
Local oSayData
Local oSayDeb
Local oSayCred
Local oGetData
Local oGetDeb
Local oGetCred
Local oPnlPri
Local oPnlDet
Local oFont

Local lLancPad		:= VerPadrao("570")

Local aCloneRec 	:= {}
Local aDados		:= {}
Local aSmlCtb		:= {}
Local nDebt			:= 0
Local nCred			:= 0
Local dData			:= dDataBase
Local nOpc 			:= 0
Local nLinha		:= 0 


Private aCtbTmp		:= {}
Private cTabSEK		:= ""
Private cTabSE2		:= ""
Private cTabSA2		:= ""
Private cTabSFE		:= ""
Private cTabSEF		:= ""
Private cTabCTK		:= ""
Private cTabCT2		:= ""
Private cTabCTF		:= ""
Private cTabSE5		:= ""
Private cTabCV3		:= ""
Private cTabFJK		:= ""
Private cIndSEK		:= ""
Private cIndSE2		:= ""
Private cIndSA2		:= ""
Private cIndSFE		:= ""
Private cIndSEF		:= ""
Private cIndCTK		:= ""
Private cIndCT2		:= ""
Private cIndCTF		:= ""
Private cIndSE5		:= ""
Private cIndCV3		:= ""
Private cIndFJK		:= ""

DEFAULT aSE2 := {}

nPosTipo	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
nPosTpDoc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPODOC"})
nPosNum	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_NUM"})
nPosPrefix	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PREFIXO"})
nPosMoeda	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
nPosMPgto	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})
nPosBanco	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAge	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
nPosTalao	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})
nPosVlr	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})
nPosEmi	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
nPosVcto	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
nPosDeb	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_DEBITO"})
nPosParc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PARCELA"})


Do Case
	Case VerPadrao("5B9")
		lLancPad := .T.
	Case VerPadrao("5BA")
		lLancPad := .T.
	Case VerPadrao("5BB")
		lLancPad := .T.
	Case VerPadrao("5BC")
		lLancPad := .T.
	Case VerPadrao("5BD")
		lLancPad := .T.
	Case VerPadrao("5BE")
		lLancPad := .T.
	Case VerPadrao("5BF")
		lLancPad := .T.
	Otherwise
		lLancPad := VerPadrao("570")
EndCase

If !lLancPad
	MsgStop( STR0339 ) // "Nใo existe lan็amento padrใo cadastrado para a contabiliza็ใo. Verifique o cadastro de lan็amentos."
Else
	lSmlCtb := .T.
	//Atualiza o array aSE2 com as formas de pagamento selecionadas
	aSE2[oLBx:nAt][3] := {4,aClone(oGetDad1:aCols),aClone(oGetDad2:aCols),0,0,aVlPA[_PA_VLATU],aVlPA[_PA_MOEATU]}
	aCloneSE2 := aClone(aSE2)
	aCloneRec := aClone(aRecnoSE2)

	Processa({|| A850CpArq(@aSE2) })

		//Grava a Ordem de Pagamento
		Processa({|| F850Grava(aSE2,,,,@nFlagMOD,@nCtrlMOD,,) })

	//Monta o array com os dados da CT2
	dbSelectArea("CTK")
	CTK->(dbGoTop())

	While !CTK->(Eof())
		dData := dDataBase

		aSmlCtb := Array(17)

		aSmlCtb[1] := Iif(Empty(CT2->CT2_LOTE),CriaVar("CT2->CT2_LOTE"),CT2->CT2_LOTE)
		aSmlCtb[2] := Iif(Empty(CT2->CT2_SBLOTE),CriaVar("CT2->CT2_SBLOTE"),CT2->CT2_SBLOTE)
		aSmlCtb[3] := Iif(Empty(CT2->CT2_DOC),CriaVar("CT2->CT2_DOC"),CT2->CT2_DOC)
		nLinha := nLinha+1
		aSmlCtb[4] := STRZERO(nLinha,TAMSX3("CT2_LINHA")[1])
		Do Case
			Case CTK->CTK_DC == "1"
				aSmlCtb[5] := STR0262
				nDebt += CTK->CTK_VLR01
			Case CTK->CTK_DC == "2"
				aSmlCtb[5] := STR0261
				nCred += CTK->CTK_VLR01
			Case CTK->CTK_DC == "3"
				aSmlCtb[5] := STR0263
				nCred += CTK->CTK_VLR01
				nDebt += CTK->CTK_VLR01
			Otherwise
				aSmlCtb[5] := CriaVar("CTK->CTK_DC")
		EndCase

		aSmlCtb[6] := Iif(Empty(CTK->CTK_DEBITO),CriaVar("CTK->CTK_DEBITO"),CTK->CTK_DEBITO)
		aSmlCtb[7] := Iif(Empty(CTK->CTK_CREDIT),CriaVar("CTK->CTK_CREDIT"),CTK->CTK_CREDIT)
		aSmlCtb[8] := Iif(Empty(CTK->CTK_VLR01),CriaVar("CTK->CTK_VLR01"),CTK->CTK_VLR01)
		aSmlCtb[9] := Lower(AllTrim(GetMV("MV_MOEDA" + AllTrim(Str(Max(Val(CTK->CTK_MOEDLC),1))))))
		aSmlCtb[11] := Iif(Empty(CTK->CTK_HIST),CriaVar("CTK->CTK_HIST"),CTK->CTK_HIST)
		aSmlCtb[12] := Iif(Empty(CTK->CTK_CCD),CriaVar("CTK->CTK_CCD"),CTK->CTK_CCD)
		aSmlCtb[13] := Iif(Empty(CTK->CTK_CCC),CriaVar("CTK->CTK_CCC"),CTK->CTK_CCC)
		aSmlCtb[14] := Iif(Empty(CTK->CTK_ITEMD),CriaVar("CTK->CTK_ITEMD"),CTK->CTK_ITEMD)
		aSmlCtb[15] := Iif(Empty(CTK->CTK_ITEMC),CriaVar("CTK->CTK_ITEMC"),CTK->CTK_ITEMC)
		aSmlCtb[16] := Iif(Empty(CTK->CTK_CLVLDB),CriaVar("CTK->CTK_CLVLDB"),CTK->CTK_CLVLDB)
		aSmlCtb[17] := Iif(Empty(CTK->CTK_CLVLCR),CriaVar("CTK->CTK_CLVLCR"),CTK->CTK_CLVLCR)

		aAdd(aDados,aSmlCtb)
		aSmlCtb := {}

		CTK->(dbSkip())
	EndDo

	If nCred == 0 .And. nDebt == 0 //Nใo gerou lan็amentos
		Help(" ",1,"F850SIMCT")
	Else
		oDlg := MSDIALOG():Create()
			oDlg:cName := "oDlg"
			oDlg:cCaption := STR0258//"Simula็ใo da contabiliza็ใo da ordem de pago"
			oDlg:nLeft := 0
			oDlg:nTop := 0
			oDlg:nWidth := 1200
			oDlg:nHeight := 600
			oDlg:lShowHint := .F.
			oDlg:lCentered := .T.

		    oFont := TFont():New(,,14,,.T.)

			oPnlPri := TPanel():New(0,0,"",oDlg,,,,,,10,10,,)
			oPnlPri:Align := CONTROL_ALIGN_TOP
			oPnlPri:nHeight := 200

			oSayData 	:= TSay():New(10,05,{|| STR0260 /*"Data "*/	},oPnlPri,,oFont,,,,.T.,,,100,,,,,,,)
			oSayCred	:= TSay():New(10,90,{|| STR0261 /*"Cr้dito "*/ },oPnlPri,,oFont,,,,.T.,,,100,,,,,,,)
			oSayDeb 	:= TSay():New(10,210,{|| STR0262 /*"D้bito "*/	},oPnlPri,,oFont,,,,.T.,,,100,,,,,,,)

			oGetData := TGET():Create(oDlg)
			oGetData:cName := "oGetData"
			oGetData:bSetGet := {|u| dData }
			oGetData:nLeft := 50
			oGetData:nTop := 18
			oGetData:nWidth := 100
			oGetData:nHeight := 21
			oGetData:lShowHint := .F.
			oGetData:lReadOnly := .T.
			oGetData:Align := 0
			oGetData:lVisibleControl := .T.
			oGetData:lPassword := .F.
			oGetData:lHasButton := .F.
			oGetData:Disable()

			oGetCred := TGET():Create(oDlg,,,,,,"@E 999,999,999.99")
			oGetCred:cName := "oGetCred"
			oGetCred:bSetGet := {|u| nCred }
			oGetCred:nLeft := 250
			oGetCred:nTop := 18
			oGetCred:nWidth := 150
			oGetCred:nHeight := 21
			oGetCred:lShowHint := .F.
			oGetCred:lReadOnly := .T.
			oGetCred:Align := 0
			oGetCred:lVisibleControl := .T.
			oGetCred:lPassword := .F.
			oGetCred:lHasButton := .F.
			oGetCred:Disable()

			oGetDeb := TGET():Create(oDlg,,,,,,"@E 999,999,999.99")
			oGetDeb:cName := "oGetDeb"
			oGetDeb:bSetGet := {|u| nDebt }
			oGetDeb:nLeft := 490
			oGetDeb:nTop := 18
			oGetDeb:nWidth := 150
			oGetDeb:nHeight := 21
			oGetDeb:lShowHint := .F.
			oGetDeb:lReadOnly := .T.
			oGetDeb:Align := 0
			oGetDeb:lVisibleControl := .T.
			oGetDeb:lPassword := .F.
			oGetDeb:lHasButton := .F.
			oGetDeb:Disable()

			oPnlDet := TPanel():New(0,0,"",oDlg,,,,,,10,10,,)
			oPnlDet:Align := CONTROL_ALIGN_BOTTOM
			oPnlDet:nHeight := 500

			oBrwTit := TCBrowse():New(0,0,10,10,,,,oPnlDet,,,,,,,,,,,,,"CT2",.T.,,,,.T.,.T.)
				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_LINHA"),{|| aDados[oBrwTit:nAt][4]},,,,,TamSx3("CT2_LINHA")[1],.F.,.F.,,,,,))
				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_DC"),{|| aDados[oBrwTit:nAt][5]},,,,,TamSx3("CT2_DC")[1],.F.,.F.,,,,,))

				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_DEBITO"),{|| aDados[oBrwTit:nAt][6]},,,,,TamSx3("CT2_DEBITO")[1],.F.,.F.,,,,,))
				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_CREDIT"),{|| aDados[oBrwTit:nAt][7]},,,,,TamSx3("CT2_CREDIT")[1],.F.,.F.,,,,,))
				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_VALOR"),{|| aDados[oBrwTit:nAt][8]},"@E 999,999,999.99",,,,TamSx3("CT2_VALOR")[1],.F.,.F.,,,,,))

				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_MOEDLC"),{|| aDados[oBrwTit:nAt][9]},,,,,020,.F.,.F.,,,,,))
				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_CCD"),{|| aDados[oBrwTit:nAt][12]},,,,,TamSx3("CT2_CCD")[1],.F.,.F.,,,,,))
				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_CCC"),{|| aDados[oBrwTit:nAt][13]},,,,,TamSx3("CT2_CCC")[1],.F.,.F.,,,,,))

				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_ITEMD"),{|| aDados[oBrwTit:nAt][14]},,,,,TamSx3("CT2_ITEMD")[1],.F.,.F.,,,,,))
				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_ITEMC"),{|| aDados[oBrwTit:nAt][15]},,,,,TamSx3("CT2_ITEMC")[1],.F.,.F.,,,,,))

				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_CLVLDB"),{|| aDados[oBrwTit:nAt][16]},,,,,TamSx3("CT2_CLVLDB")[1],.F.,.F.,,,,,))
				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_CLVLCR"),{|| aDados[oBrwTit:nAt][17]},,,,,TamSx3("CT2_CLVLCR")[1],.F.,.F.,,,,,))
				oBrwTit:AddColumn(TCColumn():New(RetTitle("CT2_HIST"),{|| aDados[oBrwTit:nAt][11]},,,,,TamSx3("CT2_HIST")[1],.F.,.F.,,,,,))

				oBrwTit:Align :=  CONTROL_ALIGN_ALLCLIENT
				oBrwTit:SetArray(aDados)
				oBrwTit:nScrollType := 1
				oBrwTit:Refresh()
		oDlg:Activate()
	EndIf

	Processa({|| A850RtArq() })

	//Recupero os arrays original
	aSE2 		:= aClone(aCloneSE2)
	aRecnoSE2 	:= aClone(aCloneRec)
	lSmlCtb := .F.
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA085A  บAutor  ณMicrosiga           บ Data ณ  09/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A850CpArq(aSE2)
Local aStru			:= {}
Local cChave		:= ""
Local cFil			:= ""
Local cFilSEF		:= ""
Local nX			:= 0
Local nY			:= 0
Local nI			:= 0
Local nLenAcol		:= 0
Local cDriver		:= ""
Local aIndex		:= {}
Local nPosSA2		:= 0
Local nPosSE2		:= 0
Local nPosFKB		:= 0
Local cChaveSA2		:= ""
Local cChaveSE2		:= ""
Local aCloneSE2 	:= {}
Local aTaloes		:= {}
Local aFKs			:= {}
Local cAliasFK		:= ""
Local cTabFK		:= ""
Local cIndFK		:= ""
Local cTmpTable := ""
Local aIndices		:= {}
Local cInd	:= "1"
Local aChave := {}
Local aValRep := {}
local aValOk := {}
Local nJ	:= 0
Local nULin := 0
Local nZ := 0
Local nColT := 0
Local nVant := 0
Local nLimit := 0	
Local lVan:= .F.

DEFAULT aSE2   		:= {}


dbSelectArea("SIX")
SIX->(dbSetOrder(1))

#IFDEF TOP
	cDriver := "TOPCONN"
#ELSE
	cDriver := "DBFCDX"
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSA2 - Fornecedorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru 	:= SA2->(dbStruct())
cTabSA2	:= FINNextAlias()
#IFDEF TOP
	cIndSA2 := ""
#ELSE
	cIndSA2	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("SA2")

cFil := ""
If Select("SA2") > 0
	aAreaTmp := SA2->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"SA2",aStru,"__SA2",cTabSA2,cIndSA2,aIndices,cFil,aAreaTmp,cFilter,cDriver})
nPosSA2 := Len(aCtbTmp)
aIndex := {}


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSE1 - Contas a Receber ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aIndex  := {}
aStru 	:= SE1->(dbStruct())
cTabSE1	:= FINNextAlias()
#IFDEF TOP
	cIndSE1 := ""
#ELSE
	cIndSE1	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("SE1")

cFil := ""
If Select("SE1") > 0
	aAreaTmp := SE1->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"SE1",aStru,"__SE1",cTabSE1,cIndSE1,aIndices,cFil,aAreaTmp,cFilter,cDriver})
nPosSE1 := Len(aCtbTmp)
aIndex := {}


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSE2 - Contas a Pagarณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru 	:= SE2->(dbStruct())
cTabSE2	:= FINNextAlias()
#IFDEF TOP
	cIndSE2 := ""
#ELSE
	cIndSE2	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("SE2")

cFil := ""
If Select("SE2") > 0
	aAreaTmp := SE2->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"SE2",aStru,"__SE2",cTabSE2,cIndSE2,aIndices,cFil,aAreaTmp,cFilter,cDriver})
nPosSE2 := Len(aCtbTmp)
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSE5 - Movimenta็ใo Bancแriaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru 	:= SE5->(dbStruct())
cTabSE5	:= FINNextAlias()
#IFDEF TOP
	cIndSE5 := ""
#ELSE
	cIndSE5	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("SE5")

cFil := ""
If Select("SE5") > 0
	aAreaTmp := SE5->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"SE5",aStru,"__SE5",cTabSE5,cIndSE5,aIndices,cFil,aAreaTmp,cFilter,cDriver})
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFKs - Movimento bancarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aFKs,"FK1")
Aadd(aFKs,"FK2")
Aadd(aFKs,"FK3")
Aadd(aFKs,"FK4")
Aadd(aFKs,"FK5")
Aadd(aFKs,"FK6")
Aadd(aFKs,"FK7")
Aadd(aFKs,"FK8")
Aadd(aFKs,"FK9")
Aadd(aFKs,"FKA")
Aadd(aFKs,"FKB")
For nI := 1 To Len(aFKs)
	aIndex := {}
	cAliasFK := aFKs[nI]
	aStru 	:= (cAliasFK)->(dbStruct())
	cTabFK	:= FINNextAlias()
	#IFDEF TOP
		cIndFK := ""
	#ELSE
		cIndFK	:= CriaTrab(Nil,.F.)
	#ENDIF
	SIX->(dbGoTop())
	aIndices := GetIndices(cAliasFK)

	cFil := ""
	If Select(cAliasFK) > 0
		aAreaTmp := (cAliasFK)->(GetArea())
		cFilter := dbFilter()
	Else
		aAreaTmp := Nil
		cFilter := Nil
	EndIf
	AADD(aCtbTmp,{cAliasFK,aStru,"__" + cAliasFK,cTabFK,cIndFK,aIndices,cFil,aAreaTmp,cFilter,cDriver})
	If cAliasFK == "FKB"
		nPosFKB := Len(aCtbTmp)
	Endif
Next
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSEK - Ordem de Pagoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru 	:= SEK->(dbStruct())
cTabSEK	:= FINNextAlias()
#IFDEF TOP
	cIndSEK := ""
#ELSE
	cIndSEK	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("SEK")

cFil := ""
If Select("SEK") > 0
	aAreaTmp := SEK->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"SEK",aStru,"__SEK",cTabSEK,cIndSEK,aIndices,cFil,aAreaTmp,cFilter,cDriver})
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSFE - Certificados de Reten็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru 	:= SFE->(dbStruct())
cTabSFE	:= FINNextAlias()
#IFDEF TOP
	cIndSEK := ""
#ELSE
	cIndSEK	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("SFE")

cFil := ""
If Select("SFE") > 0
	aAreaTmp := SFE->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"SFE",aStru,"__SFE",cTabSFE,cIndSFE,aIndices,cFil,aAreaTmp,cFilter,cDriver})
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSEF - Cheques				 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru 	:= SEF->(dbStruct())
cFilSEF := xFilial("SEF")
cTabSEF	:= FINNextAlias()
#IFDEF TOP
	cIndSEF := ""
#ELSE
	cIndSEF	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("SEF")

cFil := ""
If Select("SEF") > 0
	aAreaTmp := SEF->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"SEF",aStru,"__SEF",cTabSEF,cIndSEF,aIndices,cFil,aAreaTmp,cFilter,cDriver})
nPosSEF := Len(aCtbTmp)
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFJK - Pre-Ordem de Pagoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru 	:= FJK->(dbStruct())
cTabFJK	:= FINNextAlias()
#IFDEF TOP
	cIndFJK := ""
#ELSE
	cIndFJK	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("FJK")

cFil := ""
If Select("FJK") > 0
	aAreaTmp := FJK->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"FJK",aStru,"__FJK",cTabFJK,cIndFJK,aIndices,cFil,aAreaTmp,cFilter,cDriver})
aIndex := {}


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFRF - Historico de cheques  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aIndex := {}
aStru 	:= FRF->(dbStruct())
cTabFRF	:= FINNextAlias()
#IFDEF TOP
	cIndFRF := ""
#ELSE
	cIndFRF	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("FRF")

cFil := ""
If Select("FRF") > 0
	aAreaTmp := FRF->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"FRF",aStru,"__FRF",cTabFRF,cIndFRF,aIndices,cFil,aAreaTmp,cFilter,cDriver})
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCT2 - Lan็amentos Contแbeisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru := CT2->(dbStruct())
cTabCT2	:= FINNextAlias()
#IFDEF TOP
	cIndCT2	:= ""
#ELSE
	cIndCT2	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("CT2")

cFil := ""
If Select("CT2") > 0
	aAreaTmp := CT2->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"CT2",aStru,"__CT2",cTabCT2,cIndCT2,aIndices,cFil,aAreaTmp,cFilter,cDriver})
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCTF - Numera็ใo de Doc.	  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru := CTF->(dbStruct())
cTabCTF	:= FINNextAlias()
#IFDEF TOP
	cIndCTF	:= ""
#ELSE
	cIndCTF	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("CTF")

cFil := ""
If Select("CTF") > 0
	aAreaTmp := CTF->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"CTF",aStru,"__CTF",cTabCTF,cIndCTF,aIndices,cFil,aAreaTmp,cFilter,cDriver})
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCTK - Arquivo de Contra-Provaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru := CTK->(dbStruct())
cTabCTK	:= FINNextAlias()
#IFDEF TOP
	cIndCTK	:= ""
#ELSE
	cIndCTK	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("CTK")

cFil := ""
If Select("CTK") > 0
	aAreaTmp := CTK->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"CTK",aStru,"__CTK",cTabCTK,cIndCTK,aIndices,cFil,aAreaTmp,cFilter,cDriver})
aIndex := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCV3 - Rastreio ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aStru := CV3->(dbStruct())
cTabCV3	:= FINNextAlias()
#IFDEF TOP
	cIndCV3	:= ""
#ELSE
	cIndCV3	:= CriaTrab(Nil,.F.)
#ENDIF
SIX->(dbGoTop())
aIndices := GetIndices("CV3")

cFil := ""
If Select("CV3") > 0
	aAreaTmp := CV3->(GetArea())
	cFilter := dbFilter()
Else
	aAreaTmp := Nil
	cFilter := Nil
EndIf
AADD(aCtbTmp,{"CV3",aStru,"__CV3",cTabCV3,cIndCV3,aIndices,cFil,aAreaTmp,cFilter,cDriver})
aIndex := {}

//Abre o alias original com outro nome e o fecha para tabelas temporแrias DBFCDX
For nX := 1 To Len(aCtbTmp)
	If Select(aCtbTmp[nX,3]) > 0
		dbSelectArea(aCtbTmp[nX,3])
		dbCloseArea()
	EndIf

	ChkFile(aCtbTmp[nX,1], .F. , aCtbTmp[nX,3])
	dbSelectArea(aCtbTmp[nX,1])
	dbCloseArea()
Next nX

ProcRegua(2*Len(aCtbTmp))

//Cria o arquivo temporแrio
For nx := 1 To Len(aCtbTmp)
	cTmpTable :=  cNomObjT + alltrim(str(nX)) // nombre de variable temporal dinแmica declarada en func Fina840
	cInd := "1"
	&(cTmpTable ):= FWTemporaryTable():New(aCtbTmp[nX,1]) //nombre de archivo
	&(cTmpTable ):SetFields( aCtbTmp[nX,2] ) //estructura de archivo
	
	//Obtiene ํndices 
	aIndices := aClone(aCtbTmp[nX,6])
	//Recorre el ํndice y excluye las funciones de conversi๓n de datos que pueda contener el campo
	For nY := 1 to Len(aIndices)				
		aChave := STRTOKARR ( ALLTRIM(aIndices[nY][1]) , "+" )	
		For nJ := 1 to Len(aChave)
			IF SUBSTR(ALLTRIM (UPPER(aChave[nJ])),0,5) == "DTOS("
				aChave[nJ] := STRTRAN(UPPER(aChave[nJ]),"DTOS(","")
				aChave[nJ] := STRTRAN(UPPER(aChave[nJ]),")","")
			ELSEIF SUBSTR(ALLTRIM (UPPER(aChave[nJ])),0,4) == "STR("
				aChave[nJ] := STRTRAN(UPPER(aChave[nJ]),"STR(","")
				aChave[nJ] := STRTRAN(UPPER(aChave[nJ]),",3)","")
			EndIf
		Next nJ
		
		AADD(aValRep, aChave)
		//Valida que ํndice no est้ repetido en su secuencia	
		nULin := Len(aValRep)  
		For nZ := 1 To nULin
			IF nULin > 1 .and. nULin != nZ
				nColT:= Len(aValRep[nULin])
				nVant:= Len(aValRep[nZ])
		
				If nColT >= nVant
					nLimit := nVant
				Else
					nLimit := nColT
				EndIf
		
				for nI := 1 To nLimit
					If aValRep[nZ ,nI] == aValRep[nULin ,nI] 
						AADD(aValOk,.T.)
					Else
						AADD(aValOk,.F.)
					EndIf
				NexT nI	
		
				If ascan(aValOk,{|x| x = .F. }) == 0
					lVan:= .T. 
				EndIF
				aValOk := {}  
			EndIf		
		Next nZ

		If (!lVan .OR. nULin == 1) 
			&(cTmpTable):AddIndex( cInd, aChave)
			cInd := Soma1(cInd,5)
		EndIf
		lVan:= .F.
	Next nY 
	aValRep := {}
	//Crea la tabla 
	&(cTmpTable):Create()
	If aCtbTmp[nX,1] == "CTK"
		cTabCTK := &(cTmpTable):GetRealName()
	ElseIf aCtbTmp[nX,1] == "CT2"
		cTabCT2 := &(cTmpTable):GetRealName()
	EndIf
	
Next nX


//Preenche a tabela SE2 - CONTAS A PAGAR
If Len(aPagos) > 0

	For nX := 1 to Len(aPagos)
		If aPagos[nX][H_OK] <> 1
			Loop
		EndIf

		cChaveSA2 := aPagos[nX][H_FORNECE]
		cChaveSA2 += aPagos[nX][H_LOJA]

		dbSelectArea(aCtbTmp[nPosSA2,3])
		If (aCtbTmp[nPosSA2,3])->(MsSeek(xFilial("SA2")+cChaveSA2))	//FORNECE+LOJA
			RecLock("SA2",.T.)
			For nI := 1 To Len(aCtbTmp[nPosSA2,2])
				SA2->&(aCtbTmp[nPosSA2,2,nI,1]) := (aCtbTmp[nPosSA2,3])->&(aCtbTmp[nPosSA2,2,nI,1])
			Next nI
			MsUnlock()
		EndIf
		/*
		duplica os registros da tabela SE2 (titulos a pagar) para contabilizacao*/
		For nY := 1 to Len(aSE2[nX][1])

			cChaveSE2 := aSE2[nX][1][nY][_PREFIXO]
			cChaveSE2 += aSE2[nX][1][nY][_NUM]
			cChaveSE2 += aSE2[nX][1][nY][_PARCELA]
			cChaveSE2 += aSE2[nX][1][nY][_TIPO]
			cChaveSE2 += aSE2[nX][1][nY][_FORNECE]
			cChaveSE2 += aSE2[nX][1][nY][_LOJA]

			dbSelectArea(aCtbTmp[nPosSE2,3])
			If (aCtbTmp[nPosSE2,3])->(MsSeek(xFilial("SE2")+cChaveSE2))	//PREFIXO+NUM+PARCELA+TIPO+FORNECE+LOJA
				RecLock("SE2",.T.)
				For nI := 1 To Len(aCtbTmp[nPosSE2,2])
					SE2->&(aCtbTmp[nPosSE2,2,nI,1]) := (aCtbTmp[nPosSE2,3])->&(aCtbTmp[nPosSE2,2,nI,1])
				Next nI
				//Atribuo o Recno Original do SE2
				aSE2[nX][1][nY][_RECNO] := SE2->(Recno())
				aRecnoSE2[nX][08] := SE2->(Recno())
				MsUnlock()
			EndIf
		Next nY
		/*
		duplica os registros da tabela SE1 (documentos de terceiros) para contabilizacao
		e na tabela de controle de cheques (SEF) se necessario */
		If !Empty(aSE2[nX,3,3])
			nLenAcol := Len(aSE2[nX,3,3,1]) - 1
			For nY := 1 to Len(aSE2[nX,3,3])
				/*
				documentos a receber */
				DbSelectArea(aCtbTmp[nPosSE1,3])
				(aCtbTmp[nPosSE1,3])->(DbGoTo(aSE2[nX,3,3,nY,nLenAcol - 1]))
				RecLock("SE1",.T.)
				For nI := 1 To Len(aCtbTmp[nPosSE1,2])
					SE1->&(aCtbTmp[nPosSE1,2,nI,1]) := (aCtbTmp[nPosSE1,3])->&(aCtbTmp[nPosSE1,2,nI,1])
				Next nI
				MsUnlock()
				/* Atribuo o Recno Original do SE1 */
				aSE2[nX,3,3,nY,nLenAcol - 1] := SE1->(Recno())
				/*
				controle de cheques */
				DbSelectArea(aCtbTmp[nPosSEF,3])
				(aCtbTmp[nPosSEF,3])->(DbGoTo(aSE2[nX,3,3,nY,nLenAcol]))
				RecLock("SEF",.T.)
				For nI := 1 To Len(aCtbTmp[nPosSEF,2])
					SEF->&(aCtbTmp[nPosSEF,2,nI,1]) := (aCtbTmp[nPosSEF,3])->&(aCtbTmp[nPosSEF,2,nI,1])
				Next nI
				MsUnlock()
				/* Atribuo o Recno Original do SEF */
				aSE2[nX,3,3,nY,nLenAcol] := SEF->(Recno())
			Next nY
		Endif
		/*
		duplica os registros da tabela SEF (controle de cheques) para contabilizacao de pagamentos com cheques proprios */
		If !Empty(aSE2[nX,3,2])
			DbSelectArea(aCtbTmp[nPosSEF,3])
			DbSetOrder(1)
			For nY := 1 To Len(ASE2[nX,3,2])
				nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(aSE2[nX,3,2,nY,nPosTipo])})
				If nPosPgto > 0 .And. AllTrim(aFormasPgto[nPosPgto,2]) == "CH"
					If (Ascan(aTaloes,{|talao| talao[1] == aSE2[nX,3,2,nY,nPosBanco] .And. talao[2] == aSE2[nX,3,2,nY,nPosAge] .And. talao[3] == aSE2[nX,3,2,nY,nPosConta] .And. talao[4] == aSE2[nX,3,2,nY,nPosTalao]})) == 0
						Aadd(aTaloes,{aSE2[nX,3,2,nY,nPosBanco],aSE2[nX,3,2,nY,nPosAge],aSE2[nX,3,2,nY,nPosConta],aSE2[nX,3,2,nY,nPosTalao]})
						If (aCtbTmp[nPosSEF,3])->(MsSeek(cFILSEF + aSE2[nX,3,2,nY,nPosBanco] + aSE2[nX,3,2,nY,nPosAge] + aSE2[nX,3,2,nY,nPosConta]))
							While !((aCtbTmp[nPosSEF,3])->(Eof())) .And. (aCtbTmp[nPosSEF,3])->EF_FILIAL == cFILSEF .And. (aCtbTmp[nPosSEF,3])->EF_BANCO == aSE2[nX,3,2,nY,nPosBanco] .And. (aCtbTmp[nPosSEF,3])->EF_AGENCIA == aSE2[nX,3,2,nY,nPosAge] .And. (aCtbTmp[nPosSEF,3])->EF_CONTA == aSE2[nX,3,2,nY,nPosConta]
								If (aCtbTmp[nPosSEF,3])->EF_CART == "P" .And. (aCtbTmp[nPosSEF,3])->EF_TALAO == aSE2[nX,3,2,nY,nPosTalao]
									If (aCtbTmp[nPosSEF,3])->EF_STATUS == "00" .And. (aCtbTmp[nPosSEF,3])->EF_LIBER == "S"
										RecLock("SEF",.T.)
										For nI := 1 To Len(aCtbTmp[nPosSEF,2])
											SEF->&(aCtbTmp[nPosSEF,2,nI,1]) := (aCtbTmp[nPosSEF,3])->&(aCtbTmp[nPosSEF,2,nI,1])
										Next nI
										MsUnlock()
									Endif
								Endif
								(aCtbTmp[nPosSEF,3])->(DbSkip())
							Enddo
						Endif
					Endif
				Endif
			Next
		Endif
	Next nX
	SE2->(dbGoTop())
	/*
	duplica os registros da tabela FKB (tipos de movimentos) para contabilizacao*/
	DbSelectArea(aCtbTmp[nPosFKB,3])
	DbGoTop()
	While !Eof()
		RecLock("FKB",.T.)
		For nI := 1 To Len(aCtbTmp[nPosFKB,2])
			FKB->&(aCtbTmp[nPosFKB,2,nI,1]) := (aCtbTmp[nPosFKB,3])->&(aCtbTmp[nPosFKB,2,nI,1])
		Next nI
		DbSelectArea(aCtbTmp[nPosFKB,3])
		DbSkip()
	Enddo
EndIf
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA085A  บAutor  ณMicrosiga           บ Data ณ  09/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A850RtArq()

Local nX := 0

ProcRegua(2*Len(aCtbTmp))

//Excluo os alias temporแrios e recupero os originais
If (aCtbTmp != Nil) .And. (ValType(aCtbTmp) == "A")

	For nX := 1 To Len(aCtbTmp)

		IncProc()

		If Select(aCtbTmp[nX,1]) > 0
			dbSelectArea(aCtbTmp[nX,1])
			dbCloseArea()
			#IFDEF TOP
				//Exclui a tabela temporแria na base de dados
				TCDelFile(aCtbTmp[nX,4])
			#ELSE
				//Apaga os arquivos de trabalho e indices dos arquivos
				If File(aCtbTmp[nX,4]+GetDBExtension())
					Ferase(aCtbTmp[nX,4]+GetDBExtension())		//Apaga os arquivos temporแrios locais
					Ferase(aCtbTmp[nX,4]+OrdBagExt())			//Apaga os arquivos de ํndices
					Ferase(aCtbTmp[nX,5]+OrdBagExt())			//Apaga os arquivos de ํndices
					Ferase(aCtbTmp[nX,4]+".fpt")				//Apaga os arquivos temporแrios locais de tabelas com campos MEMO (BLOB)
				EndIf
			#ENDIF
		EndIf
		//Restaura o alias original
		If Select(aCtbTmp[nX,3]) > 0
			ChkFile(aCtbTmp[nX,3], .F. , aCtbTmp[nX,1])
			dbSelectArea(aCtbTmp[nX,3])
			dbCloseArea()
			dbSelectAreA(aCtbTmp[nX,1])
			If (aCtbTmp[nX,8] != Nil) .And. (ValType(aCtbTmp[nX,8]) == "A")
				RestArea(aCtbTmp[nX,8])
			EndIf
		EndIf
	Next nX
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINNextAliasบAutor  ณAlvaro Camillo Neto บ Data ณ  15/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProte็ใo para retornar o pr๓ximo alias disponivel no Banco    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FINNextAlias()
Local cNextAlias	:= ""
Local aArea			:= GetArea()

While .T.
	cNextAlias := GetNextAlias()
	If !TCCanOpen(cNextAlias) .And. Select(cNextAlias) == 0
		Exit
	EndIf
EndDo
RestArea(aArea)
Return(cNextAlias)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA850CNVALบAutor  ณMicrosiga           บ Data ณ  08/26/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA850CNVAL(nSaldo,nMoedade,nMoedapa)

Local nRet := 0

nRet := xMoeda(nSaldo,nMoedade,nMoedapa,dDataBase)

Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA085A  บAutor  ณMicrosiga           บ Data ณ  01/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850CanRet()

Local nX := 0
Local nY := 0

dbSelectArea("SE2")
SE2->(dbSetOrder(1))

//Array aRetencao - Preenchido na fun็ใo fa050CalcRet()

If Len(aRetencao) > 0

	For nX := 1 to Len(aRetencao)
		If SE2->(MsSeek(aRetencao[nX][1]+aRetencao[nX][2]+aRetencao[nX][3]+aRetencao[nX][4]+aRetencao[nX][5]+aRetencao[nX][6]+aRetencao[nX][7]))
			For nY := 1 to Len(aRetencao[nX][8])
				If aRetencao[nX][8][nY][3] == "1"
					RecLock("SE2",.F.)
					SE2->E2_VALOR    += aRetencao[nX][8][nY][2]
					SE2->E2_SALDO    += aRetencao[nX][8][nY][2]
					SE2->E2_VLCRUZ   += aRetencao[nX][8][nY][2]
					SE2->(MsUnlock())
				EndIf
			Next nY
		EndIf
	Next nX

EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณPARAMBOX  บAutor  ณ Wilson P. de Godoi    s บ Data ณ 28/12/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณMonta selecao por data das Solicitacooes de Pagto Liberadas   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function SelPago()

Local aPergs := {}
Local dDataDe  := Date()
Local dDataAte := Date()
Local lRet := .T.
Private aRet   := {}

If GetNewPar("MV_FINCTAL","1")=="2"
   aAdd( aPergs ,{1,STR0272,dDataDe,"@D",'.T.',,'.T.',60,.T.})   //"Data Previsใo De : "
   aAdd( aPergs ,{1,STR0273,dDataAte,"@D",'!Empty(mv_par02)',,'.T.',60,.T.}) //"Data Previsใo Ate: "

   If ParamBox(aPergs ,STR0271,aRet)  //"Filtro Data Prev."
	 If !(Processa({|| SelSolic(aRet) }))
	 	lret:=.F.
   EndIf
   EndIf
Else
F850PgAdi()
Endif
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณPARAMBOX  บAutor  ณ Wilson P. de Godoi    s บ Data ณ 28/12/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณMonta selecao por data das Solicitacooes de Pagto Liberadas   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function SelSolic(aRet)

Local aPergs := {}
Local dDataDe  := aRet[1]
Local dDataAte := aRet[2]
Local oBrowse
Local aBrowse:= {}
Local lExiste:= .F.
Local cSolic:=""
Local cFornec:=""
Local cLoja:=""
Local aArea:= GetArea()
Local aAreaFJA

DbSelectArea("FJA")
aAreaFJA:=FJA->(GetArea())
DbSetOrder(2)
DbGotop()

	cTMPFJA	:=	Alias()
	If Select("TMPFJA")>0
		TMPFJA->(DbCloseArea())
	Endif
	#IFDEF TOP
		cQryFJA := "SELECT DISTINCT R_E_C_N_O_ FROM "+RETSQLNAME("FJA")
		cQryFJA += " WHERE "
		cQryFJA += "FJA_DATAPR >= '"+dtos(dDataDe) +"' AND "
		cQryFJA += "FJA_DATAPR <= '"+dtos(dDataAte)+"' AND "
		cQryFJA += "FJA_ESTADO = '2' AND "
		cQryFJA += "FJA_DATAPR <> '' AND "
		cQryFJA += "D_E_L_E_T_ = '' "
		cQryFJA += "ORDER BY R_E_C_N_O_"
		cQryFJA := ChangeQuery(cQryFJA)
	#ELSE
		cQryFJA	:=	FJA->FJA_FILIAL==xFILIAL("FJA") .AND. (FJA->FJA_DATAPR >= dDataDe .AND. FJA->FJA_DATAPR >= dDataAte)
	#ENDIF
	dbUseArea(.F., "TOPCONN", TCGenQry(,,cQryFJA), "TMPFJA", .T., .T.)
	DbSelectArea("TMPFJA")
	TMPFJA->(DbGoTop())
	While !TMPFJA->(EOF())
		DbSelectArea("FJA")
		MsGoTo(TMPFJA->(R_E_C_N_O_))
		Aadd(aBrowse, {FJA->FJA_SOLFUN,FJA->FJA_FORNEC,FJA->FJA_LOJA,transform(FJA->FJA_VALOR,'@E 9,999,999,999.99'),FJA->FJA_DATAPR,FJA->FJA_MOEDA,FJA->FJA_CODAPR})
   		TMPFJA->(DbSkip())
   	Enddo
	TMPFJA->(DbCloseArea())

	if !Empty(aBrowse)
 	    DEFINE DIALOG oDlg TITLE STR0265 FROM 180,180 TO 600,700 PIXEL  //"Tela de Sele็ใo de Solicita็ใo de Fundos"
		//'Cod.da Solic','Fornecedor','Loja','Valor','Dt.PrevPagto'
		oBrowse := TWBrowse():New( 01 , 01, 262,209,,{STR0266,STR0267,STR0268,STR0269,STR0270,STR0343,STR0406},{40,30,20,20,40,20,30},; //Aprovador
                                 oDlg,,,,,{||},{||},,,,,,.F.,,.T.,,.F.,,, )
 	    oBrowse:SetArray(aBrowse)
	        //
	    oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],;
	                         aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07] } }

	   oBrowse:bLDblClick := {|| cSolic:=aBrowse[oBrowse:nAt][1],F850PgAdi(,cFornec,cLoja,,cSolic),oDlg:End(),oBrowse:End()}


		ACTIVATE DIALOG oDlg CENTERED

	Else
	    MsgAlert(STR0264)//"Nใo Foram Encontrados Solicita็๕es deste Periodo!"
	Endif
	aRotina[4][4]	:=	3

RestArea(aArea)
RestArea(aAreaFJA)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850Lin   บAutor  ณMicrosiga           บ Data ณ  15/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFu็ใo que verifica se existem multiplos pagamentos ou nao   บฑฑ
ฑฑบ          ณna get dados para habilitar o combobox correspondente       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F850Lin(lNewTela)

Local nCheques 	:= 0
Local nPagares 	:= 0
Local nLenAcol	:= 0
Local nC 			:= 0
Local nPosPgto	:= 0
Local nPosTipoPg	:= 0
Local nDel			:= 0
Local nPosCpo		:= 0
Local nPosTipInt	:= 0
Local cObjPg		:= ""
Local cPlnUn		:= ""
Local cPlnMp		:= ""
Local cCfgMov		:= ""

DEFAULT lNewTela := .F. //Valida tela corrente ou nova tela (Tela Pago Massivo X Tela OP)

//Verifica os objetos que serใo manipulados - Configura็ใo Individual X Pago Massivo
If IsInCallStack("F850PgMas") .And. !lNewTela
	cObjPg := "oGetPgMs"
	cPlnUn	:= "oPVencUnMs"
	cPlnMp	:= "oPVencMpMs"
Else
	cObjPg := "oGetDad1"
	cPlnUn	:= "oPnlUVct"
	cPlnMp	:= "oPnlMVct"
EndIf

nPosEmi	:= Ascan(&cObjPg:aHeader,{|x| Alltrim(x[2]) == "EK_EMISSAO"})
nPosVcto	:= Ascan(&cObjPg:aHeader,{|x| Alltrim(x[2]) == "EK_VENCTO"})

&cObjPg:oBrowse:bEditCol := {||F850Lin()}
If Type ("N") # "U" .Or. lNewTela
	If Type("oGetDad0") =="O"
		oUnico:SetDisable(.F.)
		oMultiplo:SetDisable(.F.)
	Else
		oUnico:SetDisable(.T.)
		oMultiplo:SetDisable(.T.)
	Endif

	nLenAcol := Len(&cObjPg:aCols)
	nPosTipoPg:= GDFieldPos("EK_TIPO",&cObjPg:aHeader)

	For nC := 1 To nLenAcol
		If Type("M->EK_TIPO") # "U" .And. nC == &cObjPg:nAt
			nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(M->EK_TIPO)})
		Else
			nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(&cObjPg:aCols[nC,nPosTipoPg])})
		EndIf

		If nPosPgto > 0
			//Para o calculo de vencimento, valida se o Modo de Pago e do tipo mov. diferido
			If aFormasPgto[nPosPgto,8] == "2"
				If AllTrim(aFormasPgto[nPosPgto,2]) $ "CH"
					nCheques ++
				ElseIf AllTrim(aFormasPgto[nPosPgto,2]) $ "DC" //Pagara
					nPagares ++
				EndIf
			EndIf

			//Salva a conf. de movimento do Modo de Pago da linha posicionada
			If AllTrim(&cObjPg:aCols[nC,nPosTipoPg]) == AllTrim(&cObjPg:aCols[&cObjPg:nAt][nPosTipoPg])
				cCfgMov := aFormasPgto[nPosPgto,8]
			EndIf

		Endif
	Next

	If Type("M->EK_TIPO") # "U" .And. (nPosTipInt := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim (M->EK_TIPO)})) > 0 .AND. AllTrim(aFormasPgto[nPosTipInt][2]) $"CH|"
		If nCheques > 1 .And. cCfgMov == "2"
			&cPlnUn:lVisible:= .F.
			&cPlnMp:lVisible := .T.
			If oMultiplo:nAt > 1
				nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
				If nPosCpo > 0
					Adel(&cObjPg:aAlter,nPosCpo)
					nDel++
				EndIf
			Else
				nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
				If nPosCpo == 0
					Aadd(&cObjPg:aAlter,"EK_VENCTO")
				Endif
			Endif
		ElseIf cCfgMov == "2" //Somente exibe a opcao de vencimento de cheques quando o Modo de Pago e do tipo que mov. diferido
			&cPlnUn:lVisible:= .T.
			&cPlnMp:lVisible := .F.
			If oUnico:nAt > 1
				nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
				If nPosCpo > 0
					Adel(&cObjPg:aAlter,nPosCpo)
					nDel++
				EndIf
			Else
				nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
				If nPosCpo == 0
					Aadd(&cObjPg:aAlter,"EK_VENCTO")
				Endif
			Endif
		ElseIf cCfgMov == "1"
			&cPlnUn:lVisible:= .F.
			&cPlnMp:lVisible := .F.

			nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")

			If nPosCpo > 0
				Adel(&cObjPg:aAlter,nPosCpo)
				nDel++
			EndIf

			&cObjPg:aCols[&cObjPg:nAt][nPosVcto] := &cObjPg:aCols[&cObjPg:nAt][nPosEmi]

		Endif
	ElseIf (nPosTipInt := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(&cObjPg:aCols[&cObjPg:nAt,nPosTipoPg]) }) ) > 0 .AND. AllTrim(aFormasPgto[nPosTipInt][2]) $"CH|"
		If nCheques > 1 .And. cCfgMov == "2"
			&cPlnUn:lVisible:= .F.
			&cPlnMp:lVisible := .T.
			If oMultiplo:nAt > 1
				nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
				If nPosCpo > 0
					Adel(&cObjPg:aAlter,nPosCpo)
					nDel++
				EndIf
			Else
					nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
					If nPosCpo == 0
						Aadd(&cObjPg:aAlter,"EK_VENCTO")
					Endif
			Endif
		ElseIf cCfgMov == "2" //Somente exibe a opcao de vencimento de cheques quando o Modo de Pago e do tipo mov. diferido
			&cPlnUn:lVisible:= .T.
			&cPlnMp:lVisible := .F.
			If oUnico:nAt >1
				nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
				If nPosCpo > 0
					Adel(&cObjPg:aAlter,nPosCpo)
					nDel++
				EndIf
			Else
				nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
				If nPosCpo == 0
					Aadd(&cObjPg:aAlter,"EK_VENCTO")
				Endif
			Endif
		ElseIf cCfgMov == "1"
			&cPlnUn:lVisible:= .F.
			&cPlnMp:lVisible := .F.

			nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")

			If nPosCpo > 0
				Adel(&cObjPg:aAlter,nPosCpo)
				nDel++
			EndIf

			&cObjPg:aCols[&cObjPg:nAt][nPosVcto] := &cObjPg:aCols[&cObjPg:nAt][nPosEmi]

		Endif

	ElseIf Type("M->EK_TIPO") # "U"
		&cPlnUn:lVisible := .F.
		&cPlnMp:lVisible := .F.
	ElseIf (Type ("M->EK_TIPO") == "U" .And. (nPosTipInt := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(&cObjPg:aCols[&cObjPg:nAt,nPosTipoPg]) })) > 0 .AND. AllTrim(aFormasPgto[nPosTipInt][2]) # "|CH|PGR|") .OR. nPosTipInt == 0
		&cPlnUn:lVisible := .F.
		&cPlnMp:lVisible := .F.
	ElseIf cCfgMov == "2" //Somente exibe a opcao de vencimento de cheques quando o Modo de Pago e do tipo mov. diferido
		&cPlnUn:lVisible:= .T.
		&cPlnMp:lVisible := .T.
		nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
		If nPosCpo == 0
			Aadd(&cObjPg:aAlter,"EK_VENCTO")
		Endif
	ElseIf cCfgMov == "1"
		&cPlnUn:lVisible:= .F.
		&cPlnMp:lVisible := .F.

		nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")

		If nPosCpo > 0
			Adel(&cObjPg:aAlter,nPosCpo)
			nDel++
		EndIf

		&cObjPg:aCols[&cObjPg:nAt][nPosVcto] := &cObjPg:aCols[&cObjPg:nAt][nPosEmi]

	Endif
ElseIf Type("oMultiplo") # "U" .And. oMultiplo:lVisible == .T.
	If oMultiplo:nAt # 1
		nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
		If nPosCpo > 0
			Adel(&cObjPg:aAlter,nPosCpo)
			nDel++
		EndIf
	Else
		nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
		If nPosCpo == 0
			Aadd(&cObjPg:aAlter,"EK_VENCTO")
		Endif
	Endif

ElseIf Type("oUnico") # "U" .And. oUnico:lVisible == .T.
	If oUnico:nAt # 1
		nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
		If nPosCpo > 0
			Adel(&cObjPg:aAlter,nPosCpo)
			nDel++
		EndIf
	Else
		nPosCpo := Ascan(&cObjPg:aAlter,"EK_VENCTO")
		If nPosCpo == 0
			Aadd(&cObjPg:aAlter,"EK_VENCTO")
		Endif
	Endif
EndIf
If nDel > 0
		Asize(&cObjPg:aAlter,Len(&cObjPg:aAlter) - nDel)
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA850VldTalao   บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validar o tipo da tabela de Modo de Pagos.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA850VldTalao(ExpC1,ExpC2,ExpC3)			          ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpC1 = cBanco										      ณฑฑ
ฑฑณ          ณ ExpC2 = cAgencia										      ณฑฑ
ฑฑณ          ณ ExpC3 = cConta										      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850FILTalao()
Local nPosBanco := 0
Local nPosAgenc := 0
Local nPosConta := 0
Local cObjPg	  := ""
Local lRet 	  := .T.

If IsInCallStack("F850PgMas")
	cObjPg := "oGetPgMs"
Else
	cObjPg := "oGetDad1"
EndIf

nPosBanco := Ascan(&cObjPg:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAgenc := Ascan(&cObjPg:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta := Ascan(&cObjPg:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})

cBancoCh 	:= AllTrim(&cObjPg:aCols[&cObjPg:nAt,nPosBanco])
cAgenCh 	:= AllTrim(&cObjPg:aCols[&cObjPg:nAt,nPosAgenc])
cContaCh 	:= AllTrim(&cObjPg:aCols[&cObjPg:nAt,nPosConta])

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fA850VldTalao   บAutor  ณ Jose Lucas  บ Data ณ  30/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validar o tipo da tabela de Modo de Pagos.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณSintaxe   ณ ExpL := fA850VldTalao(ExpC1,ExpC2,ExpC3)			          ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณ ExpC1 = cBanco										      ณฑฑ
ฑฑณ          ณ ExpC2 = cAgencia										      ณฑฑ
ฑฑณ          ณ ExpC3 = cConta										      ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850TalaoOK()
Local lRet 		:= .T.
Local aArea := GetArea()
Local cTalao := ""
Local nOpca     := 0	

Private nRegFRE := ""

aListBox  := {}

If IsInCallStack("F850PgMas")
	cObjPg := "oGetPgMs"
Else
	cObjPg := "oGetDad1"	
EndIf

nPosBanco := Ascan(&cObjPg:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAgenc := Ascan(&cObjPg:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta := Ascan(&cObjPg:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})

cBancoCh 	:= AllTrim(&cObjPg:aCols[&cObjPg:nAt,nPosBanco])
cAgenCh 	:= AllTrim(&cObjPg:aCols[&cObjPg:nAt,nPosAgenc])
cContaCh 	:= AllTrim(&cObjPg:aCols[&cObjPg:nAt,nPosConta])

		cTmpSEF := GetNextAlias()
		cQrySEF	:= "Select FRE_BANCO,FRE_AGENCI,FRE_CONTA,FRE_TALAO,FRE.R_E_C_N_O_ NUMREG"
		cQrySEF	+= " from " + RetSqlName("SEF") + " SEF"
		cQrySEF	+= " INNER JOIN " + RetSqlName("FRE") + " FRE ON EF_TALAO = FRE_TALAO AND EF_AGENCIA = FRE_AGENCI AND EF_BANCO = FRE_BANCO AND EF_CONTA = FRE_CONTA "
		cQrySEF += " where EF_FILIAL = '" + xFilial("SEF") + "'"
		cQrySEF += " and EF_CART = 'P'"
		cQrySEF	+= " and EF_BANCO = '" + cBancoCh + "'"
		cQrySEF += " and EF_AGENCIA = '" + cAgenCh + "'"
		cQrySEF += " and EF_CONTA = '" + cContaCh + "'"		
		cQrySEF += " and EF_STATUS = '00' AND EF_LIBER = 'S'"
		cQrySEF += " and EF_TIPO = 'CH'"
		cQrySEF += " and FRE_TIPO IN (" + IIF(FJS->FJS_TPVAL == '1' .or. Empty(FJS->FJS_TPVAL), "'1','2'","'3','4'") + ")"
		cQrySEF	+= " and SEF.D_E_L_E_T_ = ''"
		cQrySEF	+= " and FRE.D_E_L_E_T_ = ''"
		cQrySEF += " GROUP BY FRE_BANCO,FRE_AGENCI,FRE_CONTA,FRE_TALAO,FRE.R_E_C_N_O_"
		cQrySEF	:= ChangeQuery(cQrySEF)
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQrySEF),cTmpSEF,.F.,.T.)
		
(cTmpSEF)->(dbGoTop())  

While !(cTmpSEF)->(Eof())  

	Aadd(aListBox,{(cTmpSEF)->FRE_BANCO,(cTmpSEF)->FRE_AGENCI,(cTmpSEF)->FRE_CONTA,(cTmpSEF)->FRE_TALAO,(cTmpSEF)->NUMREG})

	(cTmpSEF)->(dbSkip())  

EndDo

(cTmpSEF)->(dbCloseArea())  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPermite selecionar o movimento a ser alterado caso tiver mais que um movimento na viagem - Rota mesclada ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aListBox) > 0

	DEFINE MSDIALOG oDlgLB TITLE "Consulta Estandar -  Tal๓n de Cheques" FROM C(178),C(181) TO C(400),C(693) PIXEL 
	
		@ C(025),C(004) 	LISTBOX oListBox                  													; 
							FIELDS  HEADER "Banco  ","Agencia   ","Cuenta ","Tal๓n";
							SIZE    C(250),C(92)              													;   
							OF 		oDlgLb																		; 
							PIXEL	ColSizes 10,20,40,25,50,20,40,25,50																; 

		oListBox:SetArray(aListBox)
		oListBox:bLine := {|| {aListBox[oListBox:nAT,1],aListBox[oListBox:nAT,2],aListBox[oListBox:nAT,3],aListBox[oListBox:nAT,4]}}
	
	
	ACTIVATE MSDIALOG oDlgLB CENTERED ON INIT EnchoiceBar(oDlgLB, {|| (nOpca:=1,nRegFRE:= aListBox[oListBox:nAT,5],oDlgLB:End())},{|| oDlgLB:End()})
EndIf
RestArea(aArea) 
If (nOpca == 1)
	FRE->(DbGoto(nRegFRE))
	lRet:= .T.
Else	
	lRet:= .F.
EndIf		

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ Ver850FJN  ณ Autor ณ Carlos Eduardo Chigres      ณ Data ณ 05/07/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Validacao das variaveis MV_PAR11 , MV_PAR12 e MV_PAR14, na         ณฑฑ
ฑฑณ          ณ digitacao do Pergunte FIN850A.                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Pergunte FIN850A                          			              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ             ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Programador  ณ Data   ณ BOPS ณ          Manutencoes efetuadas                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ      ณ                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ver850FJN( cVariab )

//--- Retorno
Local lRet := .T.

//--- Ambiente
Local aOrigin  := GetArea()
Local aFJN     := FJN->( GetArea() )

//--- Genericas
Local nOrder   := 1   // Order Default de Busca na FJN, Filial + Banco + Agencia
Local cFilFJN  := xFilial( "FJN" )
Local cConten  := &(Readvar())
Local cChave   := " "
Local lFullKey := .F.


 //--- Testo qual variavel esta sendo editada
 If Upper( cVariab ) == "MV_PAR11"

    If !Empty( cConten )
       cChave := cFilFJN + cConten
    EndIf

 ElseIf Upper( cVariab ) == "MV_PAR12"

    If !Empty( cConten )
       lFullKey := .T.
       cChave := cFilFJN + MV_PAR11 + cConten
    EndIf

 ElseIf cVariab == "MV_PAR14"

    nOrder := 2    // Pesquisa por Filial + Codigo Postal
    cChave := cFilFJN + cConten

 EndIf

 //--- Existe chave preenchida para a busca ??
 If !Empty( cChave )

    dbSelectArea( "FJN" )
    //--- Filial + Banco + Agencia
    dbSetOrder( nOrder )

    lRet := MsSeek( cChave )

    If lRet
       If lFullKey
          MV_PAR14 := FJN->FJN_POSTAL
       EndIf
    Else
       Help(" ",1,"REGNOIS")
    EndIf

    RestArea( aFJN )
    RestArea( aOrigin )

 EndIf

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F850PgMasบAutor  ณ Marcos Berto       บ Data ณ  30/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem da tela de Pago Massivo				              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850PgMas(aSE2)

Local bOK 			:= Nil
Local bCancel 	:= Nil
Local bPgMs		:= Nil

Local lRet			:= .T.

Local nX			:= 0
Local nAux			:= 0

Local oGrpUnico
Local oGrpMult

PRIVATE oDlgPgMs
PRIVATE oPnlPgMs
PRIVATE oPVencUnMs
PRIVATE oPVencMpMs
PRIVATE oGetPgMs

PRIVATE aCposPgMs 	:= {}
PRIVATE aHeadPgMs 	:= {}
PRIVATE aGetPgMs 		:= {}

//Configura็ใo original dos objetos para sele็ใo de datas de vencimento
PRIVATE oUnAux
PRIVATE oMpAux

DEFAULT aSE2 := {}

oDlgPgMs := MSDIALOG():Create()
oDlgPgMs:cName := "oDlgMs"
oDlgPgMs:cCaption := STR0354  //"Pago Massivo"
oDlgPgMs:nLeft := 0
oDlgPgMs:nTop := 0
oDlgPgMs:nWidth := 756
oDlgPgMs:nHeight := 430
oDlgPgMs:lShowHint := .F.
oDlgPgMs:lCentered := .T.

oSize := FwDefSize():New(.T.,,,oDlgPgMs)
oSize:lLateral := .F.
oSize:AddObject("MASTER2",100,100,.T.,.T.)
oSize:lProp := .T.
oSize:Process()

oMasterMass := TPanel():New(oSize:GetDimension("MASTER2","LININI"),;
							 oSize:GetDimension("MASTER2","COLINI"),;
							,oDlgPgMs,,,,,,oSize:GetDimension("MASTER2","LINFIN"),;
							oSize:GetDimension("MASTER2","COLFIN"),,)
oMasterMass:Align := CONTROL_ALIGN_ALLCLIENT

bPgMs		:= {|| oDlgPgMs:End(),F850AtMs(@aSE2,oUnico:nAt,oMultiplo:nAt),oMultiplo := oMpAux, oUnico := oUnAux}
bOk 		:= {|| lRet := F850VldPgM(oUnico:nAt,oMultiplo:nAt),Iif(lRet,Eval(bPgMs),.F.) }
bCancel 	:= {|| RU06S850CL(),oDlgPgMs:End(),oMultiplo := oMpAux, oUnico := oUnAux }

oDlgPgMs:bInit := {|| EnchoiceBar(oDlgPgMs,bOK,bCancel,.F.)}

//Painel da configura็ใo do Pago Massivo
oPnlPgMs := TPanel():New(0,0,"",oMasterMass/*oDlgPgMs*/,,,,,,/*Widht*/,/*Height*/,,)
oPnlPgMs:Align := CONTROL_ALIGN_TOP
oPnlPgMs:nHeight := oDlgPgMs:nHeight * 0.65

//Painel da configura็ใo da regra de cแlculo de Vencimento de Cheques - Unico
oPVencUnMs := TPanel():New(0,0,"",oMasterMass/*oDlgPgMs*/,,,,,,,,,)
oPVencUnMs:Align   := CONTROL_ALIGN_BOTTOM
oPVencUnMs:nHeight := oDlgPgMs:nHeight * 0.25
oPVencUnMs:nWidth  := oDlgPgMs:nWidth

//Painel da configura็ใo da regra de cแlculo de Vencimento de Cheques - Multiplo
oPVencMpMs := TPanel():New(0,0,"",oMasterMass/*oDlgPgMs*/,,,,,,,,,)
oPVencMpMs:Align   := CONTROL_ALIGN_BOTTOM
oPVencMpMs:nHeight := oDlgPgMs:nHeight * 0.25
oPVencMpMs:nWidth  := oDlgPgMs:nWidth

aCposPgMs := {"EK_TIPO","EK_BANCO","EK_AGENCIA","EK_CONTA","EK_MOEDA","EK_TALAO","FRE_TIPO","EK_PREFIXO","EK_NUM","EK_PARCELA","EK_EMISSAO","EK_VENCTO","EK_MOEDA","NPORVLRPG"}

//Monta o cabe็alho
DbSelectArea("SX3")
DbSetOrder(2)
For nX := 1 To Len(aCposPgMs)
	If SX3->(MsSeek(PadR(aCposPgMs[nX],Len(SX3->X3_CAMPO))))
		Do Case
			Case aCposPgMs[nX] == "EK_TIPO"
				Aadd(aHeadPgMs,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldTipo()",X3_USADO,X3_TIPO,"FJSP",X3_ARQUIVO,"","","","","","",.F.})
			Case aCposPgMs[nX] == "EK_TALAO"
				If cPaisLoc =="ARG" .and. SXB->(MsSeek(PADR("F850AR", Len(SXB->XB_ALIAS))))
					Aadd(aHeadPgMs,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850ValTal()",X3_USADO,X3_TIPO,"F850AR",X3_ARQUIVO,"","","","","","",.F.})
				Else
					Aadd(aHeadPgMs,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850ValTal()",X3_USADO,X3_TIPO,"FRE850",X3_ARQUIVO,"","","","","","",.F.})
				EndIf
			Case aCposPgMs[nX] == "FRE_TIPO"
				Aadd(aHeadPgMs,{Alltrim(X3Descric()),X3_CAMPO,"",Len(SX3->X3_DESCRIC),0,/*Valid*/,X3_USADO,"C","",X3_ARQUIVO,"","","","","","",.F.})
			Case aCposPgMs[nX] == "EK_VENCTO"
				Aadd(aHeadPgMs,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"F850VldVct()",X3_USADO,X3_TIPO,"",X3_ARQUIVO,"","","","","","",.F.})
			Case aCposPgMs[nX] == "EK_MOEDA"
				nAux++
				If nAux == 1
					Aadd(aHeadPgMs,{Alltrim(STR0307),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,/*Valid*/,X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO}) //"Moeda banco"
				Else
					Aadd(aHeadPgMs,{AllTrim(X3Titulo()),"MOEDAPGTO",X3_PICTURE,X3_TAMANHO,X3_DECIMAL,/*Valid*/,X3_USADO,"N","",X3_ARQUIVO,,"nMoedaCor"})
				Endif
			OtherWise
				Aadd(aHeadPgMs,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,/*Valid*/,X3_USADO,X3_TIPO,X3_F3,X3_ARQUIVO})
		EndCase
	ElseIf aCposPgMs[nX] == "NPORVLRPG"
		Aadd(aHeadPgMs,{STR0355 /*% Pgto*/,"NPORVLRPG","@E 999.99",6,2,/*Valid*/,X3_USADO,"N","",X3_ARQUIVO,"","","","","","",.F.})
	Endif
Next

//Campos Editแveis
aGetPgMs := {"EK_TIPO","EK_BANCO","EK_AGENCIA","EK_MOEDA","EK_TALAO","EK_PREFIXO","EK_NUM","EK_PARCELA","EK_EMISSAO","EK_VENCTO","NPORVLRPG"}

//Verifica se ja existe configuracao anterior para Pago Massivo
If Type("aPagoMass") == "A"
	If Len(aPagoMass) > 0
		aColsPgMs := aPagoMass
	EndIf
EndIf

oGetPgMs := MsNewGetDados():New(3,3,116,373,GD_INSERT+GD_UPDATE+GD_DELETE,"F850LnMsOk()","AllwaysTrue()",,aGetPgMs,/*freeze*/,,"F850PgMsOk()",/*superdel*/,"F850DlPgMs()",oPnlPgMs,aHeadPgMs,aColsPgMs,{|| F850Lin()})

//Criterios de vencimento para um documento
@ 001,002 Group oGrpUnico TO 045,100 PIXEL OF oPVencUnMs LABEL OemToAnsi(STR0238) 	//"Criterio para data de vencimento com um unico vencimento."
oGrpUnico:nWidth  := oPVencUnMs:nWidth - 15
oGrpUnico:nHeight := oPVencUnMs:nHeight - 43

//Variแvel auxiliar para restaurar a configura็ใo original do objeto oUnico
oUnAux := oUnico

@ 16,006  COMBOBOX oUnico	 VAR nUnico SIZE oGrpUnico:nWidth/3,09 ITEMS aUnico;  //"Primeiro Vencimento"###"Ultimo Vencimento"###"Ponderado dos Vencimentos"///
ON CHANGE (F850DFPgMs(oUnico:nAt),F850Lin()) OF oGrpUnico PIXEL
oUnico:bSetGet := {|u| If (PCount()==0,nUnico,nUnico:=u)}

//Sera habilitado mediante selecao de Modo de Pago = Cheque
oPVencUnMs:lVisible:= .F.

//Criterios de vencimento para multiplos documentos
@ 01,002 Group oGrpMult TO 045,410 PIXEL OF oPVencMpMs LABEL OemToAnsi(STR0242) 	//"Crit้rio para data de vencimento com multiplos vencimentos."
oGrpMult:nWidth  := oPVencMpMs:nWidth - 15
oGrpMult:nHeight := oPVencMpMs:nHeight - 43

//Variแvel auxiliar para restaurar a configura็ใo original do objeto oUnico
oMpAux := oMultiplo

@ 16,006  COMBOBOX oMultiplo VAR nMultiplo SIZE oGrpMult:nWidth/3,09 ITEMS aMultiplo;		//OemToAnsi(STR0243)###"Calcular automaticamente"
ON CHANGE (F850DFPgMs(oMultiplo:nAt),F850Lin()) OF oGrpMult PIXEL
oMultiplo:bSetGet := {|u| If (PCount()==0,nMultiplo,nMultiplo:=u)}

//Sera habilitado mediante selecao de Modo de Pago = Cheque
oPVencMpMs:lVisible:= .F.

oDlgPgMs:Activate()
If cPaisLoc == 'RUS'
	RU06S850CL()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850VldPgMบAutor  ณMarcos Berto        บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a configura็ใo de Pago Massivo				           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850VldPgM(nUnico,nMultiplo)

Local lRet 	:= .T.
Local lAux 	:= .T.
Local nX		:= 0

DEFAULT nUnico 		:= 0
DEFAULT nMultiplo 	:= 0

//Valida a data de vencimento
If lRet
	lRet := F850VldVct(nUnico,nMultiplo,.T.)
EndIf

//Valida os itens digitados
If lRet
	For nX := 1 to Len(oGetPgMs:aCols)
		lAux := F850LnMsOk(nX)
		If !lAux
			lRet := lAux
			Exit
		EndIf
	Next nX
EndIf


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850DFPgMsบAutor  ณMarcos Berto        บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIguala a data de vencimento de cheque diferido com a emissaoบฑฑ
ฑฑบ          ณpara que na atribuicao do pago massivo seja recalculada ind.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850DFPgMs(nOpSel)

Local nX		 := 0
Local nPosPgto := 0

DEFAULT nOpSel := 0

nPosTipo	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
nPosEmi	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
nPosVcto	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})

If nOpSel > 1
	For nX := 1 to Len(oGetPgMs:aCols)

		nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(oGetPgMs:aCols[nX][nPosTipo])})

		If nPosPgto > 0
			oGetPgMs:aCols[nX][nPosVcto] := oGetPgMs:aCols[nX][nPosEmi]
		EndIf
	Next nX

	MsgInfo(STR0369)

EndIf

oGetPgMs:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850PgMsOkบAutor  ณMarcos Berto        บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a digitacao dos itens do aCols do pagamento          บฑฑ
ฑฑบ          ณ massivo                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850PgMsOk()

Local aAreaFJS 	:= {}

Local cCampo		:=	ReadVar()

Local lRet			:=	.T.

Local nX			:= 0
Local nMoeda		:= 1
Local nPorcTot	:= 0
Local nPosPorPg 	:= 0
Local nPosTpTal	:= 0
Local nPosPgto	:= 0

nPosTipo	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
nPosBanco	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAge	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
nPosMoeda	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
nPosTalao	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})
nPosTpTal	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "FRE_TIPO"})
nPosPrefix	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_PREFIXO"})
nPosNum	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_NUM"})
nPosParc	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_PARCELA"})
nPosEmi	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
nPosVcto	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
nPosPorPg	:= Ascan(oGetPgMs:aHeader,{|x| Alltrim(x[2]) == "NPORVLRPG"})
nPosMPgto 	:= Ascan(oGetPgMs:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})


//Valida็ใo especifica - Costa Rica e Rep. Dominicana --> Pagamento efetivo
If lRet .and. cPaisLoc $ "DOM|COS"
	If cCampo == "M->EK_TIPO"
		If RTRIM(M->EK_TIPO) == "EF" .and. !Empty(oGetPgMs:aCols[n][nPosBanco])
			If !(oGetPgMs:aCols[n][nPosBanco] $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")) .or. !IsCaixaLoja(oGetPgMs:aCols[n][nPosBanco]))
				MsgAlert(STR0215+oGetPgMs:aCols[n][nPosBanco]+STR0231) //" nใo recebe lan็amento do tipo EF."
				lRet:=.F.
			Endif
		Endif
	Endif
	If cCampo == "M->EK_BANCO"
		If !Empty(M->EK_BANCO) .and.  !(M->EK_BANCO $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")) .or. IsCaixaLoja(M->EK_BANCO))
			If Rtrim(oGetPgMs:aCols[n][nPosTipo]) == "EF"
				MsgAlert(STR0215+M->EK_BANCO+STR0231) //" nใo recebe lan็amento do tipo EF."
				lRet:=.F.
			Endif
		Endif
	Endif
Endif

//Valida se o banco esta bloqueado 
If lRet .AND. cPaisLoc == "ARG" .AND.  cCampo == "M->EK_BANCO"  .and. !Empty(M->EK_BANCO)
	If  !SA6->(MsSeek(xFilial("SA6")+M->EK_BANCO+ oGetPgMs:aCols[n][nPosAge]+ oGetPgMs:aCols[n][nPosConta]))
			SA6->(MsSeek(xFilial("SA6")+M->EK_BANCO)) //Forzar posicionarse con el primer registro del Banco
			oGetPgMs:aCols[n][nPosAge]   := SA6->A6_AGENCIA
			oGetPgMs:aCols[n][nPosConta] := SA6->A6_NUMCON
	Endif
	lRet := !CCBLOCKED(M->EK_BANCO,oGetPgMs:aCols[n][nPosAge],oGetPgMs:aCols[n][nPosConta])
	IF !lRet
		M->EK_BANCO := Space(TamSx3("EK_BANCO")[1])
		oGetPgMs:aCols[n][nPosAge] := Space(TamSx3("EK_AGENCIA")[1])
		oGetPgMs:aCols[n][nPosConta] := Space(TamSx3("EK_CONTA")[1])
		oGetPgMs:oBrowse:Refresh()
	EndIf
ElseIf lRet .and. cPaisLoc == "ARG" .And. cCampo == "M->EK_AGENCIA"  .and. !Empty(M->EK_AGENCIA)

	lRet := CarregaSA6(oGetPgMs:aCols[N][nPosBanco],M->EK_AGENCIA,"",.T.)
	If  lRet 
		oGetPgMs:aCols[N][nPosConta]	:= Iif(Empty( oGetPgMs:aCols[N][nPosConta] ), SA6->A6_NUMCON, oGetPgMs:aCols[N][nPosConta] )   
		If  !SA6->(MsSeek(xFilial("SA6")+oGetPgMs:aCols[N][nPosBanco]+ M->EK_AGENCIA+ oGetPgMs:aCols[N][nPosConta]))
				SA6->(MsSeek(xFilial("SA6")+oGetPgMs:aCols[N][nPosBanco]+ M->EK_AGENCIA)) //Forzar posicionarse con el primer registro del Banco
				oGetPgMs:aCols[N][nPosConta] := SA6->A6_NUMCON
				oGetPgMs:oBrowse:Refresh()
		Endif
		lRet := !CCBLOCKED(oGetPgMs:aCols[n][nPosBanco], M->EK_AGENCIA, oGetPgMs:aCols[n][nPosConta])
	EndIf
EndIf

//Valida็ใo campos da conf. de Pago Massivo
If lRet
	//Valida็ใo do Modo de Pago informado
	If cCampo == "M->EK_TIPO"
		dbSelectArea("FJS")
		FJS->(dbSetOrder(1))
		If FJS->(MsSeek(xFilial("FJS")+M->EK_TIPO))

			If FJS->FJS_TIPOIN $ MVCHEQUE
				oGetPgMs:aCols[n][nPosTalao] := CriaVar("EK_TALAO")
				oGetPgMs:aCols[n][nPosTpTal] := ""
			EndIf

			//Zera os campos na altera็ใo de cada modo de pago
			For nX := 1 To Len(oGetPgMs:aHeader)
				If AllTrim(oGetPgMs:aHeader[nX,2]) == "NPORVLRPG"
					oGetPgMs:aCols[n,nX] := 0
				ElseIf AllTrim(oGetPgMs:aHeader[nX,2]) == "MOEDAPGTO"
					oGetPgMs:aCols[n,nX] := nMoedaCor
				ElseIf AllTrim(oGetPgMs:aHeader[nX,2]) == "EK_VENCTO" .Or. AllTrim(oGetPgMs:aHeader[nX,2]) == "EK_EMISSAO"
					oGetPgMs:aCols[n,nX] := dDataBase
				ElseIf AllTrim(oGetPgMs:aHeader[nX,2]) <> "EK_TIPO"
					oGetPgMs:aCols[n,nX] := Criavar(AllTrim(aHeadPgMs[nX,2]))
				Endif
			Next

			F850HDPg(FJS->FJS_TIPOIN)
			F850Lin()
		Else
			Help( " ",1, "NO SES")
			lRet := .F.
			EndIf
	EndIf

	//Valida็ใo do Talonแrio
	If cCampo == "M->EK_TALAO"

		nPosPgto := Ascan(aFormasPgto,{|pgto| AllTrim(pgto[1]) == AllTrim(oGetPgMs:aCols[n][nPosTipo])})

		If !Empty(oGetPgMs:aCols[n][nPosBanco]) .And. !Empty(oGetPgMs:aCols[n][nPosAge]) .And. !Empty(oGetPgMs:aCols[n][nPosConta]) .And. nPosPgto > 0
			dbSelectArea("FRE")
			FRE->(dbSetOrder(3))
			If FRE->(MsSeek(xFilial("FRE")+oGetPgMs:aCols[n][nPosBanco]+oGetPgMs:aCols[n][nPosAge]+oGetPgMs:aCols[n][nPosConta]+M->EK_TALAO))

                If (FRE->FRE_TIPO $ "1|2" .And. aFormasPgto[nPosPgto][8] == "2") .Or.;  // 1 e 2 = Comum / Eletronico
                   (FRE->FRE_TIPO $ "3|4" .And. aFormasPgto[nPosPgto][8] == "1")        // 3 = Diferido

					MsgAlert( STR0338 , STR0223 ) // "Chequera no disponible"
					lRet := .F.

				ElseIf FRE->FRE_STATUS == "1"
					MsgAlert( STR0338 , STR0223 ) // "Chequera no disponible"
					lRet := .F.
				Else
					oGetPgMs:aCols[n][nPosTpTal] := Lower(X3COMBO("FRE_TIPO",FRE->FRE_TIPO))
				EndIf
			EndIf
		Else
			MsgAlert(STR0255, STR0223) //Irforme Banco, Ag๊ncia e Conta
			lRet := .F.
		EndIf
	EndIf

	//Valida็ใo do Banco (Ag๊ncia e Conta bloqueadas para edi็ใo)
	If cCampo == "M->EK_BANCO"
		lRet := CarregaSA6(M->EK_BANCO,oGetPgMs:aCols[n][nPosAge],oGetPgMs:aCols[n][nPosConta],.T.)
		nMoeBan := Iif(SA6->(ColumnPos("A6_MOEDAP")) > 0 .And. SA6->A6_MOEDAP>0,SA6->A6_MOEDAP,SA6->A6_MOEDA)
		oGetPgMs:aCols[n][nPosAge]		:=	SA6->A6_AGENCIA
		oGetPgMs:aCols[n][nPosConta]	:=	SA6->A6_NUMCON
		oGetPgMs:aCols[n][nPosMoeda]	:=	Alltrim(Str(MAX(nMoeBan,1)))

		If cPaisLoc == "ARG" .And. cOpcElt == "1"
			lRet := F850VldBco(M->EK_BANCO,oGetPgMs:aCols[n][nPosAge],oGetPgMs:aCols[n][nPosConta],n)
		EndIf

		//Valida็ใo do tipo do mov. do banco
		If lRet
			lRet := FA850TpBco(oGetPgMs:aCols[n][nPosTipo],M->EK_BANCO,oGetPgMs:aCols[n][nPosAge],oGetPgMs:aCols[n][nPosConta],.T.)
		EndIf

	Endif

	//Valida็ใo da emissใo
	If cCampo == "M->EK_EMISSAO"
		If M->EK_EMISSAO < dDataBase
			MsgAlert(STR0356, STR0223) //Data de Emissใo Invแlida
			lRet := .F.
		Else
			oGetPgMs:aCols[n][nPosVcto] := M->EK_EMISSAO
		EndIf
	EndIf

	//Valida็ใo do vencimento
	If cCampo == "M->EK_VENCTO"
		If M->EK_VENCTO < oGetPgMs:aCols[n][nPosEmi]
			MsgAlert(STR0228, STR0223) //Data de Vencimento Invแlida
			lRet := .F.
		EndIf
	EndIf

	//Valida็ใo da porcentagem
	If cCampo == "M->NPORVLRPG"

		nPorcTot := M->NPORVLRPG

		//Verifica se a somat๓ria ultrapassa 100%
		For nX := 1 to Len(oGetPgMs:aCols)
			If nX <> n
				nPorcTot += oGetPgMs:aCols[nX][nPosPorPg]
			EndIf
		Next nX

		If nPorcTot > 100
			MsgAlert(STR0294, STR0223) //O valor para pagamento ultrapassa 100%.
			lRet := .F.
		EndIf

	EndIf

Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF850LnMsOkบAutor  ณMarcos Berto        บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a linha digitada do Pago Massivo   		          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F850LnMsOk(nPos)

Local lRet := .T.

Local cCfgMov	 := ""
Local cTipoIn	 := ""
Local cTpTalao := ""

DEFAULT nPos := 0

nPosTipo	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
nPosBanco	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAge	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
nPosMoeda	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
nPosTalao	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})
nPosTpTal	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "FRE_TIPO"})
nPosPrefix	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_PREFIXO"})
nPosNum	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_NUM"})
nPosParc	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_PARCELA"})
nPosEmi	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
nPosVcto	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
nPosPorPg	:= Ascan(oGetPgMs:aHeader,{|x| Alltrim(x[2]) == "NPORVLRPG"})
nPosMPgto 	:= Ascan(oGetPgMs:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})

//Caso nใo seja valida็ใo do Browse, atribui o item posicionado.
If nPos == 0
	nPos := n
EndIf


//Tipo Interno e Conf. de Movimento
dbSelectArea("FJS")
FJS->(dbSetOrder(1))
If FJS->(MsSeek(xFilial("FJS")+oGetPgMs:aCols[nPos][nPosTipo]))
	If cPaisLoc <> "BRA"
		CfgMov := FJS->FJS_TPVAL
	EndIf
	cTipoIn := FJS->FJS_TIPOIN
EndIf

Do Case 
	Case cTipoIn $ MVCHEQUE

		If 	Empty(oGetPgMs:aCols[nPos][nPosBanco]) 	.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosAge]) 		.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosConta]) 	.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosTalao]) 	.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosEmi]) 		.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosVcto]) 		.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosPorPg])

			Alert(STR0357) //"Existem dados de configura็ใo em branco."
			lRet := .F.

		EndIf

	//Se nใo for do tipo cheque, mas for do tipo diferido
	Case cCfgMov == "2"

		If 	Empty(oGetPgMs:aCols[nPos][nPosBanco]) 	.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosAge]) 		.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosConta]) 	.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosPrefix]) 	.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosNum]) 		.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosEmi]) 		.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosVcto]) 		.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosPorPg])

			Alert(STR0357) //"Existem dados de configura็ใo em branco."
			lRet := .F.

		EndIf

	Otherwise

		If 	Empty(oGetPgMs:aCols[nPos][nPosBanco]) 	.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosAge]) 		.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosConta]) 	.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosEmi]) 		.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosVcto]) 	.Or.;
			Empty(oGetPgMs:aCols[nPos][nPosPorPg])

			Alert(STR0357) //"Existem dados de configura็ใo em branco."
			lRet := .F.

		EndIf
EndCase

Return (lRet)

/*
ฑฑบPrograma  ณF850DlPgMsบAutor ณMarcos Berto         บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa a exclusใo de linha do Pago Massivo   		      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850DlPgMs()

Local lChq		:= .F.
Local nX		:= 0
Local nPosTl	:= 0
Local nQtdCfg	:= 0

nPosTipo	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
nPosBanco	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAge	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})

If nPosTipo > 0 .And. Len(oGetPgMs:aCols) > 0

	//Verifica se existe mais de um Modo de Pago configurado para o mesmo banco
	For nX := 1 to Len(oGetPgMs:aCols)
		If	oGetPgMs:aCols[n][nPosBanco] == oGetPgMs:aCols[nX][nPosBanco] .And.;
			oGetPgMs:aCols[n][nPosAge] == oGetPgMs:aCols[nX][nPosAge] .And.;
			oGetPgMs:aCols[n][nPosConta] == oGetPgMs:aCols[nX][nPosConta]

			nQtdCfg++

		EndIf
	Next nX

	If AllTrim(oGetPgMs:aCols[n][nPosTipo]) $ MVCHEQUE

		lChq := .T.

		//Exclui os taloes configurados somente se houver uma ๚nica configura็ใo para o mesmo banco
		If Type("aTaloesMs") == "A" .And. nQtdCfg == 1
			nPosTl := Ascan(aTaloesMs,{|x| AllTrim(x[1]) == AllTrim(oGetPgMs:aCols[n][nPosBanco]) .And. AllTrim(x[2]) == AllTrim(oGetPgMs:aCols[n][nPosAge]) .And. AllTrim(x[3]) == AllTrim(oGetPgMs:aCols[n][nPosConta])})

			If nPosTl > 0
				aDel(aTaloesMs,nPosTl)
				Asize(aTaloesMs,Len(aTaloesMs)-1)
			EndIf

		EndIf

	EndIf
EndIf

If Len(oGetPgMs:aCols) > 1
	Adel(oGetPgMs:aCols,oGetPgMs:nAt)
	Asize(oGetPgMs:aCols,Len(oGetPgMs:aCols) - 1)
Else
	For nX := 1 To Len(oGetPgMs:aHeader)
		If AllTrim(oGetPgMs:aHeader[nX,2]) == "NPORVLRPG"
			oGetPgMs:aCols[1,nX] := 0
		ElseIf AllTrim(oGetPgMs:aHeader[nX,2]) == "MOEDAPGTO"
			oGetPgMs:aCols[1,nX] := nMoedaCor
		Else
			oGetPgMs:aCols[1,nX] := Criavar(AllTrim(aHeadPgMs[nX,2]))
		Endif
	Next
Endif

//Recalcula o vencimento de cheques
If lChq
	F850VctoCheque()
EndIf

oGetPgMs:Refresh()

Return

/*
ฑฑบPrograma  ณF850HDPg  บ Autor ณ Marcos Berto       บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Habilita/desabilita os itens de tela						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFinanceiro					                              บฑฑ
*/
Function F850HDPg(cTipoIn)

Local nPosCpo := 0
Local nAux 	:= 0
Local nX 		:= 0

Local aEnable		:= {}
Local aDisable 	:= {}

DEFAULT cTipoIn := ""


//Tratamento para o Modo de Pago - CHEQUE
If cTipoIn $ MVCHEQUE
	//Desabilita a edi็ใo dos dados do tํtulo e Habilita a sele็ใo do Talonแrio
	aAdd(aEnable, "EK_TALAO")
	aAdd(aDisable,"EK_PREFIXO")
	aAdd(aDisable,"EK_NUM")
	aAdd(aDisable,"EK_PARCELA")
Else
	//Desabilita a sele็ใo do Talonแrio e Habilita a edi็ใo dos dados do tํtulo
	aAdd(aDisable,"EK_TALAO")
	aAdd(aEnable,	"EK_PREFIXO")
	aAdd(aEnable, "EK_NUM")
	aAdd(aEnable, "EK_PARCELA")
	aAdd(aEnable, "EK_VENCTO")
EndIf

For nX := 1 to Len(aDisable)
	nPosCpo := Ascan(oGetPgMs:aAlter,aDisable[nX])
	If nPosCpo > 0
		Adel(oGetPgMs:aAlter,nPosCpo)
		nAux++
	EndIf
Next nX

Asize(oGetPgMs:aAlter,Len(oGetPgMs:aAlter) - nAux)
nAux := 0

For nX := 1 to Len(aEnable)
	nPosCpo := Ascan(oGetPgMs:aAlter,aEnable[nX])
	If nPosCpo = 0
		Aadd(oGetPgMs:aAlter,aEnable[nX])
	EndIf
Next nX

Return

/*
ฑฑบPrograma  ณF850ValTalบAutor  ณMarcos Berto        บ Data ณ  01/08/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o talonแrio selecionado para o Pago Massivo     บฑฑ
ฑฑบ          ณ possui a quantidade de cheques necessแria                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850ValTal()

Local aTalaoAux	:= {}

Local cBanco 		:= ""
Local cAgencia 	:= ""
Local cConta 		:= ""
Local cTalao 		:= ""
Local cTipo 		:= ""
Local cTipoTal		:= ""

Local cQuery 		:= ""
Local cAlias		:= ""

Local lRet			:= .T.
Local lNewTalao	:= .F.

Local nA			:= 0
Local nX			:= 0
Local nY			:= 0
Local nChCfg		:= 0
Local nChExt		:= 0
Local nPosTl		:= 0
Local nPosCfgBc	:= 0

nPosTipo	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
nPosBanco	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAge	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta	:= Ascan(oGetPgMs:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
nPosTalao	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})

If nPosBanco > 0 .And. nPosAge > 0 .And. nPosConta > 0 .And. nPosTipo > 0

	cBanco 		:= oGetPgMs:aCols[n][nPosBanco]
	cAgencia 	:= oGetPgMs:aCols[n][nPosAge]
	cConta 		:= oGetPgMs:aCols[n][nPosConta]
	cTalao 		:= M->EK_TALAO

	cQuery := "SELECT COUNT(SEF.EF_STATUS) NCHEQUES FROM "
	cQuery += RetSQLName("SEF") + " SEF "
	cQuery += "WHERE "
	cQuery += "SEF.EF_FILIAL = '"+xFilial("SEF")+"' AND "
	cQuery += "SEF.EF_BANCO = '"+cBanco+"' AND "
	cQuery += "SEF.EF_AGENCIA = '"+cAgencia+"' AND "
	cQuery += "SEF.EF_CONTA = '"+cConta+"' AND "
	cQuery += "SEF.EF_TALAO = '"+cTalao+"' AND "
	cQuery += "SEF.EF_STATUS = '00' AND " //Cheques nใo usado --> status = 00
	cQuery += "SEF.D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)
	cAlias	:=	GetNextAlias()
	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
	If (cAlias)->(!Eof()) .And. Type("aPagos") == "A"

		dbSelectArea("FRE")
		FRE->(dbSetOrder(3))
		If FRE->(MsSeek(xFilial("FRE")+cBanco+cAgencia+cConta+cTalao))
			cTipoTal := FRE->FRE_TIPO

			//Verifica a quantidade de linhas configuradas com cheque
			For nX := 1 to Len(oGetPgMs:aCols)
				nPosPgto := Ascan(aFormasPgto,{|x| AllTrim(x[1]) == AllTrim(oGetPgMs:aCols[nX,nPosTipo])})
				If nPosPgto > 0
					If aFormasPgto[nPosPgto][2] $ MVCHEQUE
						If 	(cTipoTal $ "1|2" .And. aFormasPgto[nPosPgto][8] == "1") .Or.;
							(cTipoTal $ "3|4" .And. aFormasPgto[nPosPgto][8] == "2")

							nChCfg++

						EndIf
					EndIf
				EndIf
			Next nX

			nPosCfgBc 	:= Ascan(aTaloesMs,{|x| Alltrim(x[1]) == AllTrim(cBanco) .And. Alltrim(x[2]) == AllTrim(cAgencia) .And. Alltrim(x[3]) == AllTrim(cConta)})

			If nPosCfgBc > 0
				nPosTl := Ascan(aTaloesMs[nPosCfgBc][4],{|x| Alltrim(x[1]) == AllTrim(cTalao)})
			EndIf

			//Verifica quantos cheques de outros talonแrios ja foram selecionados
			If nPosCfgBc > 0
				For nA := 1 to Len(aTaloesMs[nPosCfgBc][4])
					If 	aTaloesMs[nPosCfgBc][4][nA][1] <> cTalao .And.;
						aTaloesMs[nPosCfgBc][4][nA][2] == cTipoTal

						nChExt+= aTaloesMs[nPosCfgBc][4][nA][3]

					EndIf
				Next nA
			EndIf

			/*
			Adiciona o talonแrio no array para controle de taloes extras.
			aTaloesMs[n][1] 			= Banco
			aTaloesMs[n][2] 			= Agencia
			aTaloesMs[n][3] 			= Conta
			aTaloesMs[n][4] 			= Array de taloes
				aTaloesMs[n][1][1] 		= Talao connfigurado na tela de Pago Massivo
				aTaloesMs[n][4][2] 		= Talao extra 1
				aTaloesMs[n][4][...]	= Talao extra N
			*/

			//Talonแrio, Tipo Tal, Cheques Disp., Cheques "usados"
			If nPosCfgBc > 0 .And. nPosTl == 0
				aAdd(aTaloesMs[nPosCfgBc][4],{cTalao,cTipoTal,(cAlias)->NCHEQUES,0})
			ElseIf nPosCfgBc == 0
				aAdd(aTalaoAux,{cTalao,cTipoTal,(cAlias)->NCHEQUES,0})
				aAdd(aTaloesMs,{cBanco,cAgencia,cConta,aTalaoAux})
			EndIf

			If 	((cAlias)->NCHEQUES + nChExt) < (Len(aPagos) * nChCfg)
				//"Qtd. de Cheques insuficiente"
				//"Nใo ha cheques suficientes no talonario selecionado. Deseja selecionar outros talonarios do mesmo banco?"
				lNewTalao := MsgYesNo(STR0358,STR0359)

				If lNewTalao

					//Exibe tela para sele็ใo de dos talonแrios
					lRet := F850ExtTln(cBanco,cAgencia,cConta,cTalao,(cAlias)->NCHEQUES,cTipoTal)
				Else
					lRet := .F.
				EndIf
			EndIf
		Else
			MsgAlert(STR0337,STR0223) //"Talใo de cheques nใo cadastrado."###"Atenci๓n" //
			lRet := .F.
		EndIf
	Else
		MsgAlert(STR0360,STR0223) //"Talonario nใo possui cheques disponํveis, selecione outro cheque"
		lRet := .F.
	EndIf
	(cAlias)->(dbCloseArea())

EndIf

Return(lRet)

/*
ฑฑบPrograma  ณF850ExtTlnบAutor ณMarcos Berto         บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona os talonแrios extras para compor o Pago Massivo   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850ExtTln(cBanco,cAgencia,cConta,cTalao,nCheques,cTipoTal)

Local aNTalao		:= {}
Local aAux			:= {}
Local aButtons	:= {}

Local bOk
Local bCancel

Local cQuery 		:= ""
Local cAlias		:= ""

Local lRet			:= .T.

Local oBrwTalao
Local oDlgTalao
Local oOK
Local oNOK

DEFAULT cBanco 	:= ""
DEFAULT cAgencia 	:= ""
DEFAULT cConta 	:= ""
DEFAULT cTalao 	:= ""
DEFAULT cTipoTal 	:= ""
DEFAULT nCheques 	:= 0

cQuery := "SELECT FRE_BANCO,FRE_AGENCI,FRE_CONTA,FRE_TALAO,FRE_TIPO,COUNT(EF_STATUS) QTDCHDISP FROM "
cQuery += RetSQLName("FRE") + " FRE, "
cQuery += RetSQLName("SEF") + " SEF "
cQuery += "WHERE "

cQuery += "FRE_FILIAL = '"+xFilial("FRE")+"' AND "
cQuery += "FRE_BANCO = '"+cBanco+"' AND "
cQuery += "FRE_AGENCI = '"+cAgencia+"' AND "
cQuery += "FRE_CONTA = '"+cConta+"' AND "
cQuery += "FRE_TALAO <> '"+cTalao+"' AND "
cQuery += "FRE_TIPO = '"+cTipoTal+"' AND "
cQuery += "EF_FILIAL = '"+xFilial("SEF")+"' AND "
cQuery += "EF_STATUS = '00' AND " //Cheques disponํveis para uso

cQuery += "FRE_BANCO = EF_BANCO AND "
cQuery += "FRE_AGENCI = EF_AGENCIA AND "
cQuery += "FRE_CONTA = EF_CONTA AND "
cQuery += "FRE_TALAO = EF_TALAO AND "

cQuery += "FRE.D_E_L_E_T_ = '' AND "
cQuery += "SEF.D_E_L_E_T_ = '' "

cQuery += "GROUP BY FRE_BANCO,FRE_AGENCI,FRE_CONTA,FRE_TALAO,FRE_TIPO"

cQuery := ChangeQuery(cQuery)
cAlias	:=	GetNextAlias()
dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
While (cAlias)->(!Eof())

	//verifica se o talonario ja foi selecionado
	nPosCfgBc 	:= Ascan(aTaloesMs,{|x| Alltrim(x[1]) == AllTrim((cAlias)->FRE_BANCO) .And. Alltrim(x[2]) == AllTrim((cAlias)->FRE_AGENCI) .And. Alltrim(x[3]) == AllTrim((cAlias)->FRE_CONTA)})

	If nPosCfgBc > 0
		nPosTl := Ascan(aTaloesMs[nPosCfgBc][4],{|x| Alltrim(x[1]) == AllTrim((cAlias)->FRE_TALAO)})

		If nPosTl > 0
			aAdd(aAux,.T.)
		Else
			aAdd(aAux,.F.)
		EndIf
	Else
		aAdd(aAux,.F.)
	EndIf
	aAdd(aAux,(cAlias)->FRE_BANCO)
	aAdd(aAux,(cAlias)->FRE_AGENCI)
	aAdd(aAux,(cAlias)->FRE_CONTA)
	aAdd(aAux,(cAlias)->FRE_TALAO)
	aAdd(aAux,Lower(X3COMBO("FRE_TIPO",(cAlias)->FRE_TIPO)))
	aAdd(aAux,(cAlias)->QTDCHDISP)
	aAdd(aAux,(cAlias)->FRE_TIPO)

	aAdd(aNTalao,aAux)
	aAux := {}

	(cAlias)->(dbSkip())

EndDo

(cAlias)->(dbCloseArea())

If Len(aNTalao) > 0
	oOK		:= LoadBitmap(GetResources(),"wfchk")
	oNOK	:= LoadBitmap(GetResources(),"wfunchk")

	oDlgTalao := MSDIALOG():Create()
	oDlgTalao:cName := "oDlgTalao"
	oDlgTalao:cCaption := STR0361 //"Sele็ใo de Talonแrios Extras"
	oDlgTalao:nLeft := 0
	oDlgTalao:nTop := 0
	oDlgTalao:nWidth := 470
	oDlgTalao:nHeight := 300
	oDlgTalao:lShowHint := .F.
	oDlgTalao:lCentered := .T.

	bOk 		:= {|| lRet := F850ExTlVl(aNTalao,nCheques,cBanco,cAgencia,cConta,cTalao),Iif(lRet,oDlgTalao:End(),.F.)}
	bCancel 	:= {|| oDlgTalao:End(),lRet := .F.}

	aAdd(aButtons, {"PENDENTE",{|| F850AlExTl(@aNTalao)},STR0363,STR0363}) //Inverte Marca

	oDlgTalao:bInit := {|| EnchoiceBar(oDlgTalao,bOK,bCancel,.F.,aButtons)}

	dbSelectArea("FRE")
	oBrwTalao := TCBrowse():New(0,0,10,10,,,,oDlgTalao,,,,,{|| F850MkExTl(@aNTalao,oBrwTalao:nAt)},,,,,,,,"FRE",.T.,,,,.T.,)
	oBrwTalao:AddColumn(TCColumn():New("  ",{|| Iif(aNTalao[oBrwTalao:nAt][1],oOK,oNOK)},,,,"LEFT",010,.T.,.F.,,,,,))
	oBrwTalao:AddColumn(TCColumn():New(RetTitle("FRE_BANCO"),{|| aNTalao[oBrwTalao:nAt][2]},,,,"LEFT",020,.F.,.F.,,,,,))
	oBrwTalao:AddColumn(TCColumn():New(RetTitle("FRE_AGENCI"),{|| aNTalao[oBrwTalao:nAt][3]},,,,"LEFT",020,.F.,.F.,,,,,))
	oBrwTalao:AddColumn(TCColumn():New(RetTitle("FRE_CONTA"),{|| aNTalao[oBrwTalao:nAt][4]},,,,"LEFT",020,.F.,.F.,,,,,))
	oBrwTalao:AddColumn(TCColumn():New(RetTitle("FRE_TALAO"),{|| aNTalao[oBrwTalao:nAt][5]},,,,"LEFT",020,.F.,.F.,,,,,))
	oBrwTalao:AddColumn(TCColumn():New(RetTitle("FRE_TIPO"),{|| aNTalao[oBrwTalao:nAt][6]},,,,"LEFT",040,.F.,.F.,,,,,))
	oBrwTalao:AddColumn(TCColumn():New(STR0362 /*Cheques Disponํveis*/,{|| aNTalao[oBrwTalao:nAt][7]},,,,"LEFT",020,.F.,.F.,,,,,))
	oBrwTalao:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwTalao:SetArray(aNTalao)
	oBrwTalao:Refresh()

	oDlgTalao:Activate()

Else
	//"Nao ha outros talonarios deste banco para compor o Pago Massivo."
	//"Selecione outro banco ou forma de pagamento."
	Alert(STR0364+" "+STR0365)
	lRet := .F.
EndIf

Return lRet

/*
ฑฑบPrograma  ณF850AlExTlบAutor ณMarcos Berto         บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona todos os talonแrios						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850AlExTl(aDados)

Local nX 		 := 0
Local lMarca	 := .T.

DEFAULT aDados := {}

For nX := 1 to Len(aDados)

	If aDados[nX][1] == lMarca
		aDados[nX][1] := !lMarca
	Else
		aDados[nX][1] := lMarca
	EndIf

Next nX

Return

/*
ฑฑบPrograma  ณF850MkExTlบAutor  ณMarcos Berto        บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca o talonแrio extra								      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850MkExTl(aDados,nPos)

DEFAULT aDados := {}
DEFAULT nPos	 := 0

If Len(aDados) > 0 .And. nPos > 0

	If aDados[nPos][1]
		aDados[nPos][1] := .F.
	Else
		aDados[nPos][1] := .T.
	EndIf

EndIf

Return

/*
ฑฑบPrograma  ณF850ExTlVlบAutor ณMarcos Berto         บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o talonแrio extra								      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850ExTlVl(aDados,nCheques,cBanco,cAgencia,cConta,cTalao)

Local lRet 	:= .T.

Local nX 		:= 0
Local nQtdeCh := 0
Local nQtdCfg	:= 1

DEFAULT aDados 	:= {}
DEFAULT nCheques 	:= 0
DEFAULT cBanco 	:= ""
DEFAULT cAgencia 	:= ""
DEFAULT cConta 	:= ""
DEFAULT cTalao 	:= ""

nQtdeCh := nCheques

For nX := 1 to Len(aDados)
	If aDados[nX][1]
		nQtdeCh += aDados[nX][7]
		nQtdCfg++
	EndIf
Next nX

If Type("aPagos") == "A"
	If nQtdeCh < (Len(aPagos) * nQtdCfg)
		Alert(STR0366) //"A quantidade de cheques selecionada nao e suficiente para a conf. do Pago Massivo."
		lRet := .F.
	Else
		//Atribui os talonarios selecionados para distribuicao
		F850ExTlOk(aDados,cBanco,cAgencia,cConta,cTalao)
	EndIf
EndIf

Return lRet

/*
ฑฑบPrograma  ณF850ExTlOkบAutor  ณMarcos Berto        บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os talonแrios extras							      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850ExTlOk(aDados,cBanco,cAgencia,cConta,cTalao)

Local nX 		:= 0
Local nPosBco	:= 0

DEFAULT aDados 	:= {}
DEFAULT cBanco 	:= ""
DEFAULT cAgencia 	:= ""
DEFAULT cConta 	:= ""
DEFAULT cTalao 	:= ""

If Type("aTaloesMs") == "A"

	nPosBco := Ascan(aTaloesMs,{|x| Alltrim(x[1]) == AllTrim(cBanco) .And. Alltrim(x[2]) == AllTrim(cAgencia) .And. Alltrim(x[3]) == AllTrim(cConta)})

	If nPosBco > 0
		For nX := 1 to Len(aDados)
			If aDados[nX][1]
				//Talonแrio, Cod. Tipo, Cheques Disp. e Cheques "usados"
				aAdd(aTaloesMs[nPosBco][4],{aDados[nX][5],aDados[nX][8],aDados[nX][7],0})
			EndIf
		Next nX
	EndIf
EndIf

Return

/*
ฑฑบPrograma  ณF850AtMs บAutor ณMarcos Berto          บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtribui o Pago Massivo configurado para todas as Ordens     บฑฑ
ฑฑบ          ณ de Pago                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850AtMs(aSE2,nVlUn,nVlMult)

Local aAuxTal		:= {}
Local aAuxPM 		:= {}
Local aDadosProp 	:= {}

Local cTpTalao	:= ""

Local lTalOrig	:= .F.
Local lAltera		:= .F.

Local nA := 0
Local nI := 0
Local nX := 0
Local nY := 0

Local nChUsado	:= 0
Local nChDif		:= 0

Local nPosTl		:= 0
Local nPosCfgBc	:= 0
Local nPosPorPg 	:= 0
Local nPosTpTal	:= 0
Local nPosPgto	:= 0

Local nPosVlr3o	:= Ascan(oGetDad2:aHeader,{|x| Alltrim(X[2])=="E1_SALDO"})
Local nPosM3o		:= Ascan(oGetDad2:aHeader,{|x| Alltrim(x[2])=="E1_MOEDA"})

Local nSaldoOld	:= nSaldoPgOP
Local nPropOld	:= nTotDocProp

Local nVlrProp	:= 0
Local nVlrPg		:= 0
Local nValPgOP	:= 0
Local nValTcOP	:= 0
Local nValorAux	:= 0

DEFAULT aSE2 		:= {}
DEFAULT nVlUn 	:= 0
DEFAULT nVlMult 	:= 0

//Verifica as posi็๕es do array original
nPosTipo	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})
nPosBanco	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAge	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
nPosMoeda	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_MOEDA"})
nPosTalao	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TALAO"})
nPosTpTal	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "FRE_TIPO"})
nPosPrefix	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PREFIXO"})
nPosNum	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_NUM"})
nPosParc	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_PARCELA"})
nPosEmi	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_EMISSAO"})
nPosVcto	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VENCTO"})
nPosPorPg	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "NPORVLRPG"})
nPosMPgto 	:= Ascan(oGetDad1:aHeader,{|x| Alltrim(x[2]) == "MOEDAPGTO"})
nPosVlr	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})

//Zera a distribui็ใo de talonแrios
If Type("aTaloesMs") == "A"
	For nX := 1 to Len(aTaloesMs)
		For nY := 1 to Len(aTaloesMs[nX][4])
			aTaloesMs[nX][4][nY][4] := 0
		Next nY
	Next nX
EndIf

//Verifica a quantidade de cheques diferidos - calculo dos vencimentos unico ou multiplo
For nX := 1 to Len(oGetPgMs:aCols)
	nPosPgto := Ascan(aFormasPgto,{|x| AllTrim(x[1]) == AllTrim(oGetPgMs:aCols[nX][nPosTipo])})
	If nPosPgto > 0
		If aFormasPgto[nPosPgto][2] $ MVCHEQUE .And. aFormasPgto[nPosPgto][8] == "2"
			nChDif++
		EndIf
	EndIf
Next nX

If Type("aColsPgMs") == "A"

	//Percorre o array de Ordens de Pago, calculando e distribuindo os valores do Modo de Pago
	For nX := 1 to Len(aSE2)

		If Len(aSE2[nX][3][2]) > 0
			lAltera := .T.
		Else
			lAltera := .F.
		EndIf

		//Zera a configura็ใo anterior
		aSE2[nX][3][2] := {}

		For nI := 1 to Len(oGetPgMs:aCols)

			//Inicializa o array de acordo com a estrutura da configura็ใo original de Pagos com Doc. Proprio
			aAuxPM := Array(Len(oGetDad1:aHeader)+1)

			//Calcula o valor de acordo com a % configurada
			nValPgOP	:= aPagos[nX,H_TOTALVL]
			nValTcOP	:= 0
			If aSE2[nX][1][1][_FORNECE] == aPagos[oLbx:nAt][H_FORNECE] .And. aSE2[nX][1][1][_LOJA] == aPagos[oLbx:nAt][H_LOJA]
				For nY := 1 to Len(oGetDad2:aCols)
					nValTcOP	+= Round(xMoeda(oGetDad2:aCols[nY,nPosVlr3o],oGetDad2:aCols[nY,nPosM3o],nMoedaCor,,5,aTxMoedas[oGetDad2:aCols[nY,nPosM3o]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				Next nY
			ElseIf Len(aSE2[nX][3][3]) > 0
				For nY := 1 to Len(aSE2[nX][3][3])
					nValTcOP	+= Round(xMoeda(aSE2[nX][3][3][nY][nPosVlr3o],aSE2[nX][3][3][nY][nPosM3o],nMoedaCor,,5,aTxMoedas[aSE2[nX][3][3][nY][nPosM3o]][2],aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				Next nY
			EndIf

			nVlrPg := nValPgOP - nValTcOP
			nValorAux := Round(nVlrPg * (oGetPgMs:aCols[nI][nPosPorPg] / 100),MsDecimais(nMoedaCor))

			aAuxPM[nPosTipo] 		:= oGetPgMs:aCols[nI][nPosTipo]
			aAuxPM[nPosBanco] 	:= oGetPgMs:aCols[nI][nPosBanco]
			aAuxPM[nPosAge] 		:= oGetPgMs:aCols[nI][nPosAge]
			aAuxPM[nPosConta] 	:= oGetPgMs:aCols[nI][nPosConta]
			aAuxPM[nPosMoeda] 	:= oGetPgMs:aCols[nI][nPosMoeda]
			//Valida qual o talonario sera distribuido --> Talonarios extras
			If Type("aTaloesMs") == "A" .And. !Empty(oGetPgMs:aCols[nI][nPosTalao])

				//Verifica se o talonario informado possui cheque disponivel
				nPosCfgBc 	:= Ascan(aTaloesMs,{|x| Alltrim(x[1]) == AllTrim(oGetPgMs:aCols[nI][nPosBanco]) .And. Alltrim(x[2]) == AllTrim(oGetPgMs:aCols[nI][nPosAge]) .And. Alltrim(x[3]) == AllTrim(oGetPgMs:aCols[nI][nPosConta])})

				If nPosCfgBc > 0
					nPosTl 	:= Ascan(aTaloesMs[nPosCfgBc][4],{|x| Alltrim(x[1]) == AllTrim(oGetPgMs:aCols[nI][nPosTalao])})
				EndIf

				If nPosTl > 0
					If aTaloesMs[nPosCfgBc][4][nPosTl][4] < aTaloesMs[nPosCfgBc][4][nPosTl][3]
						aAuxPM[nPosTalao] := aTaloesMs[nPosCfgBc][4][nPosTl][1] //Talonแrio
						aAuxPM[nPosTpTal] := Lower(X3COMBO("FRE_TIPO",aTaloesMs[nPosCfgBc][4][nPosTl][2]))	//Tipo Talonario
						aTaloesMs[nPosCfgBc][4][nPosTl][4]++
						lTalOrig := .T. //Utiliza o Talonario Original configurado
					Else
						lTalOrig := .F.
					EndIf
				Else
					lTalOrig := .F.
				EndIf

				dbSelectArea("FRE")
				FRE->(dbSetOrder(3))
				If FRE->(MsSeek(xFilial("FRE")+oGetPgMs:aCols[nI][nPosBanco]+oGetPgMs:aCols[nI][nPosAge]+oGetPgMs:aCols[nI][nPosConta]+oGetPgMs:aCols[nI][nPosTalao]))
					cTpTalao := FRE->FRE_TIPO
				EndIf

				//Se o talonario configurado ja nao possui mais cheques, utiliza os extras selecionados
				If !lTalOrig
					If Len(aTaloesMs) > 0
						For nY := 1 to Len(aTaloesMs)
							If 	aTaloesMs[nY][1] == oGetPgMs:aCols[nI][nPosBanco] .And.;
								aTaloesMs[nY][2] == oGetPgMs:aCols[nI][nPosAge] .And.;
								aTaloesMs[nY][3] == oGetPgMs:aCols[nI][nPosConta]

								For nA := 1 to Len(aTaloesMs[nY][4])
									If 	aTaloesMs[nY][4][nA][4] < aTaloesMs[nY][4][nA][3] .And.;
										aTaloesMs[nY][4][nA][2] == cTpTalao

										aAuxPM[nPosTalao] := aTaloesMs[nY][4][nA][1] //Talonแrio
										aAuxPM[nPosTpTal] := Lower(X3COMBO("FRE_TIPO",aTaloesMs[nPosCfgBc][4][nPosTl][2]))	//Tipo Talonแrio
										aTaloesMs[nY][4][nA][4]++ //Atualiza a quantidade de cheques usados
										Exit

									Else
										Loop
									EndIf
								Next nA
								Exit
							EndIf
						Next nY
					Else
						aAuxPM[nPosTalao] := oGetPgMs:aCols[nI][nPosTalao]
						aAuxPM[nPosTpTal] := oGetPgMs:aCols[nI][nPosTpTal]
					EndIf
				EndIf

				cTpTalao := ""

			Else
				aAuxPM[nPosTalao] := oGetPgMs:aCols[nI][nPosTalao]
				aAuxPM[nPosTpTal] := oGetPgMs:aCols[nI][nPosTpTal]
			EndIf
			aAuxPM[nPosPrefix] 	:= oGetPgMs:aCols[nI][nPosPrefix]
			aAuxPM[nPosNum] 		:= oGetPgMs:aCols[nI][nPosNum]
			aAuxPM[nPosParc] 		:= oGetPgMs:aCols[nI][nPosParc]
			aAuxPM[nPosEmi] 		:= oGetPgMs:aCols[nI][nPosEmi]

			//Calcula os Vencimentos por Ordem de Pago
			nPosPgto := Ascan(aFormasPgto,{|x| AllTrim(x[1]) == AllTrim(oGetPgMs:aCols[nI][nPosTipo])})
			If nPosPgto > 0
				//Recalculo de datas para cheques diferidos - por Ordem de Pago
				If aFormasPgto[nPosPgto][2] $ MVCHEQUE .And. aFormasPgto[nPosPgto][8] == "2"
					//Calcula a data de vencimento da OP
					If (nVlUn > 1 .And. nChDif = 1) .Or. (nVlMult > 1 .And. nChDif > 1)
						F850VctoCheque(nVlUn,nVlMult,aSE2,nX)
					EndIf
					aAuxPM[nPosVcto] 	:= oGetPgMs:aCols[nI][nPosVcto]
				Else
					aAuxPM[nPosVcto] 	:= oGetPgMs:aCols[nI][nPosVcto]
				EndIf
			EndIf

			aAuxPM[nPosMPgto] 	:= oGetPgMs:aCols[nI][nPosMPgto]
			aAuxPM[nPosPorPg] 	:= oGetPgMs:aCols[nI][nPosPorPg]
			aAuxPM[nPosVlr] 		:= nValorAux
			aAuxPM[Len(aAuxPM)]	:= .F. //Flag de exclusใo desmarcado

			//Acumula o valor dos doc. pr๓prios
			nVlrProp += nValorAux

			//Montagem de array auxiliar para exibi็ใo dos dados da OP posicionada
			aAdd(aDadosProp,aAuxPM)

			//Atribui o pagamento configurado
			aAdd(aSE2[nX][3][2],aAuxPM)

		Next nI

		//Atualiza o array da Ordem que estiver posicionada
		If aSE2[nX][1][1][_FORNECE] == aPagos[oLbx:nAt][H_FORNECE] .And. aSE2[nX][1][1][_LOJA] == aPagos[oLbx:nAt][H_LOJA]

			//Zera a configura็ใo existente de pagamento com documentos proprios
			aColsPg := aDadosProp

			oGetDad1:SetArray(aColsPg)
			oGetDad1:Refresh()
			F850Lin(.T.)

			//Ajusto o valor distribuํdo anteriormente
			If lAltera
				nSaldoPgOP 	+= nPropOld
				nTotDocProp 	-= nPropOld
			EndIf

			//Atualizo o saldo e o valor do pagamento com doc. proprios
			nSaldoPgOP 	-= nVlrProp
			nTotDocProp 	+= nVlrProp

			oSaldoPgOP:Refresh()
			oTotDocProp:Refresh()

		EndIf

		nVlrProp	:= 0
		aDadosProp	:= {}

	Next nX

	For nX := 1 to Len(aPagos)
		aPagos[nX,H_UNICOCHQ] := nVlUn
		aPagos[nX,H_MULTICHQ] := nVlMult
	Next nX

	//Recupera a data de Pago Massivo - Vencimento = Emissao (informativa)
	If (nVlUn > 1 .And. nChDif = 1) .Or. (nVlMult > 1 .And. nChDif > 1)
		For nX := 1 to Len(oGetPgMs:aCols)
			nPosPgto := Ascan(aFormasPgto,{|x| AllTrim(x[1]) == AllTrim(oGetPgMs:aCols[nX][nPosTipo])})
			If nPosPgto > 0
				If aFormasPgto[nPosPgto][2] $ MVCHEQUE .And. aFormasPgto[nPosPgto][8] == "2"
					oGetPgMs:aCols[nX][nPosVcto] := oGetPgMs:aCols[nX][nPosEmi]
				EndIf
			EndIf
		Next nX
	EndIf

	If Type("aPagoMass") == "A"
		aPagoMass := oGetPgMs:aCols
	EndIf

EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F850EfSE2
Efetiva a marca na SE2 a partir da sele็ใo efetuada na tabela temporแria

@author    Marcos Berto
@version   11.5
@since     01/08/2012

/*/
//------------------------------------------------------------------------------------------

Function F850EfSE2()

Local aAreaTmp := {}

If Type("cAliasTmp") <> "U"
	dbSelectArea(cAliasTmp)
	aAreaTmp := (cAliasTmp)->(GetArea())
	(cAliasTmp)->(dbGoTop())
	While !(cAliasTmp)->(Eof())
		If (cAliasTmp)->E2_OK == cMarcaE2
			dbSelectArea("SE2")
			SE2->(dbGoTo((cAliasTmp)->E2_RECNO))
			RecLock("SE2",.F.)
			SE2->E2_OK := cMarcaE2
			SE2->(MsUnlock())
		EndIf
		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(RestArea(aAreaTmp))
EndIf

Return

/*
ฑฑบPrograma  ณF850AtuTRBบAutor  ณMarcos Berto        บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Eefetiva a marca no TRB a partir do processamento dos      บฑฑ
ฑฑบ          ณ registros			                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850AtuTRB()

Local aStruct 	:= {}
Local aIndices 	:= {}
Local cCampo 		:= ""
Local nX 			:= 0
Local nY			:= 0
Local nPosCampo 	:= 0
Local xConteudo	:= Nil

dbSelectArea(cAliasTmp)
aStruct 	:= SE2->(dbStruct())
aIndices 	:= GetIndices("SE2")
GeraIndice(cArqTemp,cAliasTmp,aIndices,1,.T.)

For nX := 1 to Len(aRecNoSE2)
	//FILIAL+PREFIXO+NUM+PARCELA+TIPO+FORNECE+LOJA
	If (cAliasTmp)->(MsSeek(aRecNoSE2[nX][1]+aRecNoSE2[nX][4]+aRecNoSE2[nX][5]+aRecNoSE2[nX][6]+aRecNoSE2[nX][7]+aRecNoSE2[nX][2]+aRecNoSE2[nX][3]))

		SE2->(dbGoTo(aRecNoSE2[nX][8]))

		//Atualizo o registro com os dados que foram modificados no processamento da OP
		Reclock(cAliasTmp,.F.)
			For nY := 1 to Len(aStruct)
				cCampo    := aStruct[nY,1]
				xConteudo := SE2->&cCampo
				nPosCampo := (cAliasTmp)->(ColumnPos(cCampo))

				If nPosCampo > 0
					(cAliasTmp)->(FieldPut(nPosCampo,xConteudo))
				EndIf
			Next nY

			If SE2->E2_SALDO = 0
				(cAliasTmp)->APROVADO 	:= "N"
			ElseIf !Empty(SE2->E2_NUMBOR)
				(cAliasTmp)->APROVADO	:= "S"
				(cAliasTmp)->LOTE 		:= "S"
			ElseIf SE2->E2_SALDO > 0
				(cAliasTmp)->APROVADO 	:= "S"
			EndIf

		(cAliasTmp)->(MsUnlock())

	EndIf
Next nX

Return

/*
ฑฑบPrograma  ณF850Busca บAutor  ณMarcos Berto        บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa do Browse         								  บฑฑ
ฑฑบ          ณ 		                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Function F850Busca()

Local aAux			:= {}
Local aBusca 		:= {}
Local aOrdem 		:= {}
Local aIndices 	:= {}
Local bOk			:= Nil
Local cAux			:= ""
Local cCampo 		:= ""
Local cOrdem 		:= ""
Local nX			:= 0
Local nY			:= 0
Local nPos			:= 0
Local nOpc			:= 0
Local nPosIni		:= 0
Local nPosFim		:= 0
Local oDlgBsc
Local oOrdem

If lShowPOrd
	cOrdem += AllTrim(RetTitle("FJK_FORNEC"))+"+"
	cOrdem += AllTrim(RetTitle("FJK_LOJA"))+"+"
	cOrdem += AllTrim(RetTitle("FJK_PREOP"))

	cCampo := Space(TamSX3("FJK_FORNEC")[1]+TamSX3("FJK_LOJA")[1]+TamSX3("FJK_PREOP")[1])

	Aadd(aOrdem,cOrdem)
	aAdd(aBusca,{cCampo,1})

Else
	aIndices := GetIndices("SE2")

	For nX := 1 to Len(aIndices)

		cOrdem := ""
		cCampo := ""

		If aIndices[nX][2] == "S"
			aAux := StrTokArr(aIndices[nX][1],"+")

			For nY := 1 to Len(aAux)
				If AllTrim(aAux[nY]) <> "E2_FILIAL"

					If At("(",aAux[nY]) > 0
						nPosIni := At("(",aAux[nY])+1
						nPosFim := RAt(")",aAux[nY]) - nPosIni

						cAux := SubStr(aAux[nY],nPosIni,nPosFim)
					Else
						cAux := aAux[nY]
					EndIf

					cOrdem += AllTrim(RetTitle(cAux))+Iif(nY <> Len(aAux),"+","")
					cCampo += Space(TamSX3(cAux)[1])
				EndIf
			Next nY

			Aadd(aOrdem,cOrdem)
			aAdd(aBusca,{cCampo,nX})
		EndIf
	Next nX

EndIf

If Len(aBusca) > 0
	cCampo := aBusca[1][1] //Posiciona no primeiro registro
	nPos 	:= aBusca[1][2] //Posiciona no primeiro registro
	cOrdem := aOrdem[1]
EndIf

bOk 	:= {|| F850Local(cCampo,nPos),oDlgBsc:End()}


DEFINE MSDIALOG oDlgBsc FROM 00,00 TO 70,400 PIXEL TITLE OemToAnsi(STR0007) //Busca
@ 02,02 COMBOBOX oOrdem VAR cOrdem ITEMS aOrdem ON CHANGE(cCampo := aBusca[oOrdem:nAt][1], nPos := aBusca[oOrdem:nAt][2]) SIZE 165,44 OF oDlgBsc PIXEL
@ 15,02 GET cCampo SIZE 165,10 OF oDlgBsc PIXEL
DEFINE SBUTTON FROM 02,170 TYPE 1 OF oDlgBsc ENABLE ACTION Eval(bOk)
DEFINE SBUTTON FROM 15,170 TYPE 2 OF oDlgBsc ENABLE ACTION oDlgBsc:End()
ACTIVATE DIALOG oDlgBsc

Return

/*
ฑฑบPrograma  ณF850Local บAutor  ณMarcos Berto        บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa do Browse         								  บฑฑ
ฑฑบ          ณ 		                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA850                                                    บฑฑ
*/
Static Function F850Local(cBusca,nOrdem)

Local aIndices

DEFAULT cBusca 	:= ""
DEFAULT nOrdem 	:= 0

If lShowPOrd
	DbSelectArea(cAliasPOP)
	(cAliasPOP)->(dbGoTop())
	(cAliasPOP)->(MsSeek(cBusca))
Else
	aIndices := GetIndices("SE2")
	GeraIndice(cArqTemp,cAliasTmp,aIndices,nOrdem)

	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGoTop())
	IF Empty(cArqTemp)
		(cAliasTmp)->(dbSetOrder(nOrdem))	
	EndIF
	(cAliasTmp)->(MsSeek(xFilial("SE2")+AllTrim(cBusca)))

EndIf

Return

/*
ฑฑบPrograma  ณGetIndicesบAutor  ณ Marcos Berto	    บ Data ณ  01/10/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ OBTEM OS INDICES DAS TABELAS                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
*/
Static Function GetIndices(cAlias)

Local aIndices	:= {}
Local aAreaSIX	:= {}

dbSelectArea("SIX")
aAreaSIX := SIX->(GetArea())
SIX->(dbSetOrder(1))
If SIX->(MsSeek(cAlias+"1"))
	aIndices := {}
	While !(SIX->(EOF())) .AND.  SIX->INDICE == cAlias
		AADD(aIndices,{SIX->CHAVE,SIX->SHOWPESQ})
		SIX->(DBSkip())
	Enddo
EndIf
SIX->(RestArea(aAreaSIX))

Return(aIndices)

/*
ฑฑบPrograma  ณGeraIndiceบAutor  ณ Marcos Berto	    บ Data ณ  01/10/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ GERA OS INDICES DAS TABELAS TEMPORARIAS                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
*/
Static Function GeraIndice(cArq,cAlias,aIndices,nPos,lNVld)

DEFAULT cArq 		:= ""
DEFAULT cAlias	:= ""
DEFAULT aIndices	:= {}
DEFAULT nPos		:= 0
DEFAULT lNVld		:= .F.

dbSelectArea(cAlias)

If Len(aIndices) > 0 .And. nPos > 0 .and. !Empty(cArq)
	If aIndices[nPos][2] == "S" .Or. lNVld
		dbCreateIndex(cArq+OrdBagExt(),aIndices[nPos][1],{|| aIndices[nPos][1] } )
		dbClearIndex()
		dbSetIndex(cArq+OrdBagExt())
	EndIf
EndIf

Return Nil

/*/{Protheus.doc} F850VldElt
Fun็ใo para valida็ใo/edi็ใo de objetos de tela dos pagamentos eletr๔nicos

@author    Marcos Berto
@version   11.7
@since     21/09/2012

@param nOpc		Op็ใo selecionada para pagamento eletronico (1-Sim/2-Nใo)
@param oFolder	Objeto do Folder que deve ser habilitado/desabilitado
@param aSE2		Estrutura da Ordem de Pago

/*/
Function F850VldElt(nOpc,oFolder,aSE2)

Local nX 		:= 0

DEFAULT nOpc 	:= 0
DEFAULT aSE2	:= {}

For nX := 1 to Len(aSE2)

	//Zera a configura็ใo anterior
	aSE2[nX][3][2] := {}
	aSE2[nX][3][3] := {}

Next nX

//Zera a configura็ใo corrente
aColsPg	:= {}
aCols3os 	:= {}
aPagoMass	:= {}

//Zera configura็ใo de documento pr๓prio corrente
Aadd(aColsPg,Array(Len(aHeaderPg)+1))
For nX := 1 To Len(aHeaderPg)
	If aHeaderPg[nX,2] == "NPORVLRPG"
		aColsPg[1,nX] := 0
	ElseIf aHeaderPg[nX,2] == "MOEDAPGTO"
		aColsPg[1,nX] := nMoedaCor
	Else
		aColsPg[1,nX] := Criavar(AllTrim(aHeaderPg[nX,2]))
	Endif
Next
aColsPg[1,Len(aColsPg[1])] := .F.

oGetDad1:SetArray(aColsPg)
oGetDad1:Refresh()

oGetDad2:SetArray(aCols3os)
oGetDad2:Refresh()

//Habilita ou desabilita os folders - Doc. Terc. e Doc. Proprios
If IsInCallStack("F850PgAdi") //Pagamento Antecipado
	If nOpc = 1 //Pgto Elet. = SIM
		oFolderPg:HidePage(1)
		oFolderPg:ShowPage(2)
	Elseif nOpc == 2 .Or. nOpc == 3
		oFolderPg:ShowPage(1)
		oFolderPg:ShowPage(2)
	EndIf
Else //Pago automแtico
	If nOpc = 1 //Pgto Elet. = SIM
		oFolder:HidePage(2)
		oFolder:ShowPage(3)
	ElseIf nOpc = 2 //Pgto Elet. = Nใo
		oFolder:ShowPage(2)
		oFolder:ShowPage(3)
	EndIf
EndIf

If  nOpc != 3
	cOpcElt := Str(nOpc,1)
Else
	nTotDocTerc := 0
Endif

Return

/*/{Protheus.doc} F850VldBco
Fun็ใo que valida o uso de um mesmo banco para pagamento eletr๔nico

@author    Marcos Berto
@version   11.7
@since     21/09/2012

@param cBcoAt	Banco informado
@param cAgeAt	Agencia informada
@param cCtaAt	Conta informada
@param nPos	Posicao do grid de doc. proprios que esta sendo editada

@return lVldBco Banco validado (T/F)

/*/
Function F850VldBco(cBcoAt,cAgeAt,cCtaAt,nPos)

Local cObjPg 		:= ""

Local lVldBco		:= .T.

Local nX			:= 0

DEFAULT cBcoAt 	:= ""
DEFAULT cAgeAt 	:= ""
DEFAULT cCtaAt 	:= ""

DEFAULT nPos	:= 0

//Verifica os objetos que serใo manipulados - Configura็ใo Individual X Pago Massivo
If IsInCallStack("F850PgMas")
	cObjPg := "oGetPgMs"
Else
	cObjPg := "oGetDad1"
EndIf

nPosBanco := Ascan(&cObjPg:aHeader,{|x| Alltrim(x[2]) == "EK_BANCO"})
nPosAgenc := Ascan(&cObjPg:aHeader,{|x| Alltrim(x[2]) == "EK_AGENCIA"})
nPosConta := Ascan(&cObjPg:aHeader,{|x| Alltrim(x[2]) == "EK_CONTA"})

For nX := 1 to Len(&cObjPg:aCols)
	If	(AllTrim(&cObjPg:aCols[nX,nPosBanco]) <> AllTrim(cBcoAt) .Or.;
		 AllTrim(&cObjPg:aCols[nX,nPosAgenc]) <> AllTrim(cAgeAt) .Or.;
		 AllTrim(&cObjPg:aCols[nX,nPosConta]) <> AllTrim(cCtaAt)) .And.;
		 nPos <> nX

		lVldBco := .F.
		MsgAlert(STR0371) //O banco informado e diferente daquele configurado para outros pagamentos electronicos. Seleccione o mesmo Banco/Balcใo/Conta.", "O banco informado e diferente do configurado para outros pagamentos eletronicos. Selecione o mesmo Banco/Agencia/Conta."
		Exit

	EndIf
Next nX

Return lVldBco

/*/{Protheus.doc} F850GetElt
Fun็ใo para montagem de filtro de modo de pago --> Eletr๔nico Sim/Nใo

@author    Marcos Berto
@version   11.7
@since     21/09/2012
/*/
Function F850GetElt()
If Type("oPgtoElt") <> "U"
	If oPgtoElt:nAt = 1
		cEletrCh := "1" //1-Sim
	Else
		cEletrCh := " 2" //Branco ou 2-Nใo
	EndIf
EndIf

Return .T.

/*/{Protheus.doc} F850RecPgt
Fun็ใo para recuperar os pagamentos nใo efetivados por lotes de tํtulos a pagar

@author    Marcos Berto
@version   11.7
@since     10/10/2012

@param cPrefixo	Prefixo do Tํtulo a Pagar
@param cNumero	Numero do Tํtulo a Pagar
@param cParcela	Parcela do Tํtulo a Pagar
@param cTipo		Tipo do Tํtulo a Pagar
@param cFornece	Fornecedor do Tํtulo a Pagar
@param cLoja		Loja do Tํtulo a Pagar

@return nValLote	Valor ainda nใo efetivado pelo Lote

/*/
Function F850RecPgt(cPrefixo,cNumero,cParcela,cTipo,cFornece,cLoja)

Local aAreaSEK	:= {}
Local nValLote 	:= 0
Local nRecSEK		:= 0

DEFAULT cPrefixo	:= ""
DEFAULT cNumero	:= ""
DEFAULT cParcela	:= ""
DEFAULT cTipo		:= ""
DEFAULT cFornece	:= ""
DEFAULT cLoja		:= ""

If cPaisLoc $ "ARG/"
	dbSelectArea("SEK")
	nRecSEK := SEK->(Recno())
	aAreaSEK := SEK->(GetArea())
	SEK->(dbSetOrder(6))
	If SEK->(MsSeek(xFilial("SEK")+cPrefixo+cNumero+cParcela+cTipo+cFornece+cLoja+"TB"))
		While 	SEK->EK_FILIAL == xFilial("SEK") .And. SEK->EK_PREFIXO == cPrefixo .And.;
				SEK->EK_NUM == cNumero 	.And. SEK->EK_PARCELA == cParcela .And.;
				SEK->EK_TIPO == cTipo 	.And. SEK->EK_FORNECE == cFornece .And.;
				SEK->EK_LOJA == cLoja 	.And. SEK->EK_TIPODOC == "TB"

			//Procura os registros que ainda nใo movimentaram o saldo to tํtulo (E2_SALDO)
			If SEK->EK_EFTVAL == "2" .And. !SEK->EK_CANCEL
				nValLote += SEK->EK_VALOR + SEK->EK_DESCONT - SEK->EK_MULTA - SEK->EK_JUROS
			EndIf

			SEK->(dbSkip())
		EndDo
	EndIf
EndIf

Return nValLote

/*
ฑฑบPrograma  ณPMSFi850  บAutor  ณJandir Deodato      บFecha ณ 04/09/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Caso a integra็ใo com o Totvs Obras e Projetos esteja      บฑฑ
ฑฑบ              ligada chama a tela de rateio do projeto.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
*/
Static Function PMSFi850()
Local aArea
Local bPMSDlgF85	:= {||PmsDlgFI(3,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA)}//integra็ใo pms
aArea:=GetArea()
M->E2_NUM 		:= SE2->E2_NUM
M->E2_PREFIXO := SE2->E2_PREFIXO
M->E2_FORNECE := SE2->E2_FORNECE
M->E2_LOJA		:=SE2->E2_LOJA
M->E2_ORIGEM	:=SE2->E2_ORIGEM
M->E2_VALOR	:=SE2->E2_VALOR
M->E2_MOEDA	:=SE2->E2_MOEDA
M->E2_TXMOEDA	:=SE2->E2_TXMOEDA
Eval(bPmsDlgF85)
PmsWriteFI(1,"SE2")
RestArea(aArea)
Return

/*
ฑฑบPrograma  ณF850GeraVencบAutor  ณAna Paula Nasci     Data ณ  01/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para gerar a data de vencimento dos titulos de       บฑฑ
ฑฑบ          ณreten็ใo de IVA para o Paraguai, segundo tabela oficial que บฑฑ
ฑฑบ          ณestabelece o dia de acordo com o ultimo digito do RUC       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA085A                                                   บฑฑ

*/
Function F850GeraVenc(cPrefixo,cImp)
Local nTamRuc		:= Len(SM0->M0_CGC)
Local dDataVenc	:= Ctod("//")
Local cDigRuc		:= Subs(SM0->M0_CGC,nTamRuc,1)
Local cAux			:= ""
Local cMsg			:= ""

DEFAULT cPrefixo	:= ""
DEFAULT cImp		:= ""

If cPaisLoc == "PER"

	If !Empty(cImp)
		//procura por uma data especifica para o imposto
		cAux := FR0Chave("PE4",Substr(Dtos(dDataBase),1,6),cImp,"01")
		If Empty(cAux)
			//se nao encontrar uma data especifica, procura por uma padrใo ("uso geral")
			cAux := FR0Chave("PE4",Substr(Dtos(dDataBase),1,6),"","01")
		Endif
	Else
		//se nao informado o imposto, procura por uma data de "uso geral"
		cAux := FR0Chave("PE4",Substr(Dtos(dDataBase),1,6),"","01")
	Endif
	dDataVenc := Ctod(cAux)
	If Empty(dDataVenc)
		dDataVenc := dDataBase
		//se a data nao e valida, ou a tabela PE4 esta errada ou ela nao existe na FR0
		cMsg += AllTrim(STR0245)
		cMsg += ": " + Strzero(Month(dDataBase),2) + "/" + Strzero(Year(dDataBase),4) + "." + CRLF
		cMsg += AllTrim(STR0246) + "."
		MsgAlert(cMsg,STR0223)
	Endif
Endif

Return(dDataVenc)

/*
ฑฑบPrograma  ณFINA850   บAutor  ณMicrosiga           บFecha ณ  12/18/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
*/
Function F850MsFil(lOPRotAut)
Local lRet			:= .T.
Local cCompSE2		:= ""
Local cCompart		:= ""
Local cLayoutEmp	:= ""
Local lGestao		:= .F.
Local aTabComp		:= {}
Local nA			:= 0
Local lRotAuto		:=.T.


Default lOPRotAut		:= .F.

lMsfil := SF1->(ColumnPos("F1_MSFIL")) > 0
lMsfil := lMSFil .And. SF2->(ColumnPos("F2_MSFIL")) > 0
lMsFil := lMsFil .And. (SD1->(ColumnPos("D1_MSFIL")) > 0)
lMsFil := lMsFil .And. (SD2->(ColumnPos("D2_MSFIL")) > 0)
lMsFil := lMsFil .And. (SE2->(ColumnPos("E2_MSFIL")) > 0)
aTabComp := {}
Aadd(aTabComp,{"SB1","A"})
Aadd(aTabComp,{"SA2","C"})
Aadd(aTabComp,{"SF1","E"})
Aadd(aTabComp,{"SD1","E"})
Aadd(aTabComp,{"SF2","E"})
Aadd(aTabComp,{"SD2","E"})
Aadd(aTabComp,{"SE4","C"})
Aadd(aTabComp,{"SEK","C"})
Aadd(aTabComp,{"SFE","C"})
Aadd(aTabComp,{"SFH","C"})
Aadd(aTabComp,{"SFF","A"})
cLayoutEmp 	:= FWSM0Layout()
lGestao		:= Iif( lFWCodFil, ( "E" $ cLayoutEmp .And. "U" $ cLayoutEmp ), .F. )	// Indica se usa Gestao Corporativa
If lFWCodFil .And. lGestao
	/* SE2 */
	cCompSE2 := FwModeAccess("SE2",1) + FwModeAccess("SE2",2) + FwModeAccess("SE2",3)
	lMsFil := lMsFil .And. (cCompSE2 == "CCC")
	/* SE4 */
	cCompSE2 := FwModeAccess("SE4",1) + FwModeAccess("SE4",2) + FwModeAccess("SE4",3)
	lMsFil := lMsFil .And. (cCompSE2 == "CCC")
	/* SEK */
	cCompSE2 := FwModeAccess("SEK",1) + FwModeAccess("SEK",2) + FwModeAccess("SEK",3)
	lMsFil := lMsFil .And. (cCompSE2 == "CCC")
	/* SF1 */
	cCompart := FwModeAccess("SF1",1) + FwModeAccess("SF1",2) + FwModeAccess("SF1",3)
	lMsFil := lMsFil .And. (cCompart == "EEE")
	/* SD1 */
	cCompart := FwModeAccess("SD1",1) + FwModeAccess("SD1",2) + FwModeAccess("SD1",3)
	lMsFil := lMsFil .And. (cCompart == "EEE")
	/* SF2 */
	cCompart := FwModeAccess("SF2",1) + FwModeAccess("SF2",2) + FwModeAccess("SF2",3)
	lMsFil := lMsFil .And. (cCompart == "EEE")
	/* SD2 */
	cCompart := FwModeAccess("SD2",1) + FwModeAccess("SD2",2) + FwModeAccess("SD2",3)
	lMsFil := lMsFil .And. (cCompart == "EEE")
	/* SB1 */
	cCompart := FwModeAccess("SB1",1) + FwModeAccess("SB1",2) + FwModeAccess("SB1",3)
	lMsFil := lMsFil .And. (cCompart == "CCC")
	/* SFF */
	cCompart := FwModeAccess("SFF",1) + FwModeAccess("SFF",2) + FwModeAccess("SFF",3)
	lMsFil := lMsFil .And. (cCompart == "CCC")
	/* SA2 */
	cCompart := FwModeAccess("SA2",1) + FwModeAccess("SA2",2) + FwModeAccess("SA2",3)
	lMsFil := lMsFil .And. (cCompart == "CCC")
	/* SFE */
	cCompart := FwModeAccess("SFE",1) + FwModeAccess("SFE",2) + FwModeAccess("SFE",3)
	lMsFil := lMsFil .And. (cCompart == "CCC")
	/* SFH */
	cCompart := FwModeAccess("SFH",1) + FwModeAccess("SFH",2) + FwModeAccess("SFH",3)
	lMsFil := lMsFil .And. (cCompart == "CCC")
	/*-*/
	If (cCompSE2 == "CCC") .And. !lMsFil
		lRet := .F.
	Endif
Else
	lMsFil := lMsFil .And. !Empty(xFilial("SF1"))
	lMsFil := lMsFil .And. !Empty(xFilial("SD1"))
	lMsFil := lMsFil .And. !Empty(xFilial("SF2"))
	lMsFil := lMsFil .And. !Empty(xFilial("SD2"))
	lMsFil := lMsFil .And. Empty(xFilial("SB1"))
	lMsFil := lMsFil .And. Empty(xFilial("SE2"))
	lMsFil := lMsFil .And. Empty(xFilial("SE4"))
	lMsFil := lMsFil .And. Empty(xFilial("SEK"))
	lMsFil := lMsFil .And. Empty(xFilial("SA2"))
	lMsFil := lMsFil .And. Empty(xFilial("SFE"))
	lMsFil := lMsFil .And. Empty(xFilial("SFH"))
	lMsFil := lMsFil .And. Empty(xFilial("SFF"))
	If Empty(xFilial("SE2")) .And. !lMsFil
		lRet := .F.
	Endif
Endif
If !lRet
	cCompart := STR0376 + CRLF + CRLF		//"A tabela de contas a pagar (SE2) esta em modo compartilhado. Para utiliza-la dessa forma e necessario que as tabelas abaixo estejam com o compartilhamento configurado da seguinte forma:"
	For nA := 1 To Len(aTabComp)
		SX2->(MsSeek(aTabComp[nA,1]))
		cCompart += aTabComp[nA,1] + " (" + Alltrim(X2Nome()) + ") - " + If(aTabComp[nA,2] == "C",STR0378,If(aTabComp[nA,2] == "E",STR0379,STR0380)) + CRLF		//"Completamente compartilhada","Completamente exclusiva","Completamente compartilhada ou completamente exclusiva"
	Next
	cCompart += CRLF
	cCompart += STR0377	//"Antes de usar a ordem de pago, verifique o compartilhamento das tabelas acima. E se o campo reservado 'Filial de inclusao' (_MSFIL) foi habilitado para as tabelas SE2, SF1, SF2, SD1, SD2."

	If lOPRotAut
		cTxtRotAut += cCompart
	Else
		MsgStop(cCompart,STR0223)
	EndIf

Endif

Return(lRet)
/*
ฑฑบPrograma  ณFA850TpBcoบAutor  ณMicrosiga           บ Data ณ  05/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o tipo de banco do modo de pago (FJS)e do banco(SA6)บฑฑ
ฑฑบ          ณ Projeto: M11.7CTR01 Requisito: 1421.5                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - Argentina                                        บฑฑ

*/
Static Function FA850TpBco(cTipModPag,cCodBanco,cCodAgenc,cCodConta,lExibMsg)
Local lRet			:= .T.
Local aSaveArea 	:= GetArea()
Local cFJSTipBco	:= ""
Local cSA6TipBco	:= ""

Default cTipModPag	:= CriaVar("FJS_TIPO"	,.F.)
Default cCodBanco	:= CriaVar("A6_COD"		,.F.)
Default cCodAgenc	:= CriaVar("A6_AGENCIA"	,.F.)
Default cCodConta	:= CriaVar("A6_NUMCON"	,.F.)
Default lExibMsg	:= .T.

//Verifica se os campos existem na base
If cPaisLoc $ "ANG|ARG|AUS|COS|DOM|EQU|EUA|HAI|PAD|PAN|POR|SAL|TRI"

	//Verifica se todos campos estao preenchidos
	If !Empty(cTipModPag) .And. !Empty(cCodBanco) .And. !Empty(cCodAgenc) .And. !Empty(cCodConta)

		cFJSTipBco := GetAdvFVal("FJS","FJS_TIPBCO"	,XFilial("FJS")+cTipModPag						,1,"")
		cSA6TipBco := GetAdvFVal("SA6","A6_TIPBCO"	,XFilial("SA6")+cCodBanco+cCodAgenc+cCodConta	,1,"")
		If !Empty(cFJSTipBco) .And. (cFJSTipBco <> cSA6TipBco)
			lRet := .F.
			If(lExibMsg,Help(" ",1,"SA6TIPBCO"),Nil)
		EndIf

	EndIf

EndIf

RestArea(aSaveArea)

Return(lRet)

/*/{Protheus.doc} F850Ordens
Fun็ใo que monta o aPagos a partir do aSE2.
@author Lucas de Oliveira
@since 20/03/2014
@version 1.0
/*/
Function F850Ordens(aSE2)
Local nP			:=	0
Local nC			:=	0
Local nY			:=	0
Local nX			:=	0
Local nA			:=	0
Local nT            :=  0
Local nValPag		:=	0
Local nOldIva		:=	0
Local nIVSUS		:= 0
Local lExisPA		:= .F.
Local lReIvSU		:= (cPaisLoc=="ARG" .and. GetNewPar("MV_RETIVA","N") == "S" .and. GetNewPar("MV_RETSUSS","N") == "S")
Local lLimpaFor	:= .F.
Local nLoja := 0
Local cLojaAux := ""
Local nSumRet	:=0
Local nSumPag   :=0
Local nPagoT 	:=0

//CARREGAR ARRAY PARA USAR NA LISTBOX.
For nA	:=	1	To Len(aSE2)
	//INICIALIZAR ARRAY COM OS DADOS PRiNCIPAIS
	AAdd(aPagos,{1,aSE2[nA][1][1][_FORNECE],aSE2[nA][1][1][_LOJA],aSE2[nA][1][1][_NOME],0,0,0,0,0,0,0,0,0,0,0,0,0,0,.F.,0,Space(TamSX3("ED_CODIGO")[1]),1,1,""})

	//VERIFICAR O USO DA TECLA F4
	If nCondAgr>1
		nAux:=Len(aPagos)
		If nCondAgr==2
			If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
				SE2->(DbGoTo(aSE2[nA][1][1][_RECNO]))
				SA2->(MsSeek(SE2->E2_MSFIL+aSE2[nA][1][1][_FORNECE]))
			Else
				SA2->(MsSeek(xfilial("SA2")+aSE2[nA][1][1][_FORNECE]))
			Endif
			lLimpaFor	:=.F.
			For nLoja := 1 to Len(aSE2[nA,1])
				If nLoja == 1
					cLojaAux := aSE2[nA,1,nLoja][_LOJA]
				ElseIf aSE2[nA,1,nLoja][_LOJA] <> cLojaAux
					lLimpaFor := .T.
				EndIf
			Next nLoja
			
			If lLimpaFor
				aPagos[nAux][H_LOJA]:=""
				aPagos[nAux][H_NOME]:=""
				If !lF4
					lF4:=.T.
				Endif
			EndIf
		Else
			If SA2->(Reccount())>0
				aPagos[nAux][H_FORNECE]:=""
				aPagos[nAux][H_LOJA]:=""
				aPagos[nAux][H_NOME]:=""
				If !lF4
					lF4:=.T.
				Endif
			Endif
		Endif
		//LIMPA O IMPOSTO DE GANANCIAS QUANDO NAO
		//TIVER UM FORNECEDOR ESCOLHIDO PARA AS OP's.
		If cPaisLoc = "ARG" .And. Empty(aPagos[nAux][H_FORNECE])
			aSE2[nA][2] := {}
		Endif
	Endif

	//Atualiza informa็ใo do documento de terceiro - ARGENTINA
	If cPaisLoc $ "ARG"
		dbSelectArea("SA2")
		aAreaSA2 := SA2->(GetArea())
		SA2->(dbSetOrder(1))
		If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
			SE2->(DbGoTo(aSE2[nA][1][1][_RECNO]))
			SA2->(MsSeek(SE2->E2_MSFIL+aSE2[nA][1][1][_FORNECE]+aSE2[nA][1][1][_LOJA]))
		Else
			SA2->(MsSeek(xFilial("SA2")+aSE2[nA][1][1][_FORNECE]+aSE2[nA][1][1][_LOJA]))
		Endif
		If SA2->(Found())
			If SA2->A2_ENDOSSO == "1"
				aPagos[nA][H_TERC] := STR0047
			Else
				aPagos[nA][H_TERC] := STR0048
			EndIf
		EndIf
		SA2->(RestArea(aAreaSA2))
	EndIf

	//CARREGAR COM OS VALORES DE NOTAS PARA SER PAGAS, NNC , PAS, E NO CASO DE ARGENTINA
	//AS RETENCOES DE IMPOSTOS DE IB E IVA.
	For nC	:=	1	To Len(aSE2[nA][1])
		
		If aSE2[nA][1][nC][_TIPO] $ MVPAGANT + "/" + MV_CPNEG
			lExisPA := lReIvSU .and. aSE2[nA][1][nC][_TIPO] $ MVPAGANT
			nValPag -= IIf(aSE2[nA][1][nC][_MOEDA] == 1,aSE2[nA][1][nC][_PAGAR], Round(xMoeda(aSE2[nA][1][nC][_PAGAR],aSE2[nA][1][nC][_MOEDA],1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))
		Else
			nValPag += IIf(aSE2[nA][1][nC][_MOEDA] == 1,aSE2[nA][1][nC][_PAGAR], Round(xMoeda(aSE2[nA][1][nC][_PAGAR],aSE2[nA][1][nC][_MOEDA],1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))       
		EndIf
		If aSE2[nA][1][nC][_TIPO] $ MVPAGANT + "/" + MV_CPNEG
			aPagos[nA][H_NCC_PA]	+=	aSE2[nA][1][nC][_SALDO1]
			aPagos[nA][H_VALORIG]	+= Round(xMoeda(aSE2[nA][1][nC][_SALDO1],nMoedaCor,1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))  
		Else
			aPagos[nA][H_NF]		+=	aSE2[nA][1][nC][_SALDO1]
			aPagos[nA][H_VALORIG]	+= Round(xMoeda(aSE2[nA][1][nC][_SALDO1],nMoedaCor,1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Endif
		If !(cPaisLoc $ "ANG")
			If cPaisLoc == "ARG"
				For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETIB])
					aPagos[nA][H_RETIB]		+=	Round(xMoeda(aSE2[nA][1][nC][_RETIB ][nP][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				Next
			EndIf
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETIVA])
				aPagos[nA][H_RETIVA]	+=	Round(xMoeda(aSE2[nA][1][nC][_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETSUSS])
				aPagos[nA][H_RETSUSS]	+= Round(xMoeda(aSE2[nA][1][nC][_RETSUSS][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETSLI])
				aPagos[nA][H_RETSLI]	+=	Round(xMoeda(aSE2[nA][1][nC][_RETSLI][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETISI])
				aPagos[nA][H_RETISI]	+=	Round(xMoeda(aSE2[nA][1][nC][_RETISI][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next

			aPagos[nA][H_CBU] := aSE2[nA][1][nC][_CBU]

		Endif
		//ANGOLA
		If cPaisLoc == "ANG"
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETRIE])
				aPagos[nA][H_RETRIE]		+=	Round(xMoeda(aSE2[nA][1][nC][_RETRIE][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
		Endif
		//Republica Dominicana e Costa Rica
		If 	cPaisLoc $ "DOM|COS" .And. aSE2[nA][1][nC][12]	<> MVPAGANT
			aPagos[nA][H_TOTALVL]	-= SomaAbat(aSE2[nA][1][nC][9],aSE2[nA][1][nC][10],aSE2[nA][1][nC][11],"P",aSE2[nA][1][nC][4],aSE2[nA][1][nC][7],aSE2[nA][1][nC][1])
		EndIf
		If cPaisLoc == "EQU"
			If 	aSE2[nA][1][nC][12]	== "NF "
				nAbatimentos += SomaAbat(aSE2[nA][1][nC][9],aSE2[nA][1][nC][10],aSE2[nA][1][nC][11],"P",aSE2[nA][1][nC][4],aSE2[nA][1][nC][7],aSE2[nA][1][nC][1])
				aPagos[nA][H_TOTALVL] -= nAbatimentos
			EndIf
		EndIf
	Next nC
	If cPaisLoc	==	"ARG"
		For nC:=	1	To Len(aSE2[nA][2])
			aPagos[nA][H_RETGAN]		+=	Round(xMoeda(aSE2[nA][2][nC][5],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
		Next nC
		aPagos[nA][H_RETIB]		:=	aPagos[nA][H_RETIB]
		aPagos[nA][H_RETGAN]		:=	aPagos[nA][H_RETGAN]
		aPagos[nA][H_RETSUSS]		:=	aPagos[nA][H_RETSUSS]
		aPagos[nA][H_RETSLI]		:=	Max(aPagos[nA][H_RETSLI],0)
		If aPagos[nA][H_RETISI] < 0
			aPagos[nA][H_RETISI]		:=	aPagos[nA][H_RETISI]
		Else
			aPagos[nA][H_RETISI]		:=	Max(aPagos[nA][H_RETISI],0)
		EndIf	
		
		nSumRet := aPagos[nA][H_RETIB] + aPagos[nA][H_RETGAN] + aPagos[nA][H_RETIVA]
		/************************************************************************/
		//Calculo cumulativo de IVA - reten็ใo de documentos que nใo sใo desta OP
		/************************************************************************/
		If Len(aSE2[nA][1]) > 1 .And. Len(aRetIvAcm)> 1 .And. aRetIvAcm[2] <> Nil .And.  Len(aRetIvAcm[2]) > 0
			For nT := 1 to Len(aSE2[nA][1])
				nPagoT := IIF(aSE2[nA][1][nT][_TIPO] $ MVPAGANT + "/" + MV_CPNEG, -1 * aSE2[nA][1][nT][_PAGAR], aSE2[nA][1][nT][_PAGAR])
				nSumPag += Round(xMoeda(nPagoT,aSE2[nA][1][nT][_MOEDA],1,,5,,aTxMoedas[aSE2[nA][1][nT][_MOEDA]][2]),MsDecimais(1))
			Next
		EndIf
		F850DocIVA(aSE2[nA][1][1][_FORNECE],aSE2[nA][1][1][_LOJA],IIF(nSumPag > 0, nSumPag, Round(xMoeda(aSE2[nA][1][1][_PAGAR],aSE2[nA][1][1][_MOEDA],1,,5,,aTxMoedas[aSE2[nA][1][1][_MOEDA]][2]),MsDecimais(1))),nSumRet)

		If aRetIvAcm[3] <> Nil .And. Len(aRetIvAcm)>2 .And. Len(aRetIvAcm[3]) > 0
			For nP := 1 to Len(aRetIvAcm[3])
				aPagos[nA][H_RETIVA]	+=	Round(xMoeda(aRetIvAcm[3][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
		EndIf

		nOldIva += aPagos[nA][H_RETIVA]

		//Atualiza o IVA novamente
		aPagos[nA][H_RETIVA] := 0
		F850PropIV(nValPag,nOldIVA,@aSE2[nA],(aPagos[nA][H_RETIB] + aPagos[nA][H_RETGAN] + aPagos[nA][H_RETSUSS]))
		For nC := 1 to Len(aSE2[nA][1])
			For nP	:=	1	To	Len(aSE2[nA][1][nC][_RETIVA])
				aPagos[nA][H_RETIVA]	+=	Round(xMoeda(aSE2[nA][1][nC][_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next nP
		Next nC

		If aRetIvAcm[3] <> Nil .And. Len(aRetIvAcm)>2 .And. Len(aRetIvAcm[3]) > 0
			For nP := 1 to Len(aRetIvAcm[3])
				aPagos[nA][H_RETIVA]	+=	Round(xMoeda(aRetIvAcm[3][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
			Next
		EndIf

		aPagos[nA][H_RETIVA] :=	aPagos[nA][H_RETIVA]

		nOldIva := 0
		nValPag := 0

		aPagos[nA][H_TOTALVL]	:=	aPagos[nA][H_NF]-aPagos[nA][H_NCC_PA]-;
		aPagos[nA][H_RETIB]-aPagos[nA][H_RETGAN]-;
		aPagos[nA][H_RETIVA]-aPagos[nA][H_RETSUSS]-;
		aPagos[nA][H_RETSLI]-aPagos[nA][H_RETISI]
	ElseIf cPaisLoc	==	"ANG"
		aPagos[nA][H_RETRIE] 		:=	Max(aPagos[nA][H_RETRIE],0)
		aPagos[nA][H_TOTALVL]	:=	aPagos[nA][H_NF]-aPagos[nA][H_NCC_PA]-aPagos[nA][H_RETRIE]
 	ElseIf cPaisLoc	$ "DOM|COS"
 		aPagos[nA][H_TOTALVL]	+=	aPagos[nA][H_NF] - aPagos[nA][H_NCC_PA]
 	ElseIf cPaisLoc	==	"EQU"
 		aPagos[nA][H_TOTALVL]	+=	aPagos[nA][H_NF] - aPagos[nA][H_NCC_PA]
	Else
		aPagos[nA][H_TOTALVL]	:=	aPagos[nA][H_NF]-aPagos[nA][H_NCC_PA]
	Endif
	If cPaisLoc	==	"ARG"

		IF lExisPA
			nIVSUS	+= 	(aPagos[nA][H_RETIVA] + aPagos[nA][H_RETSUSS])
		Endif
	
		aPagos[nA][H_TOTRET]		:=	aPagos[nA][H_RETIB]+aPagos[nA][H_RETIVA]+aPagos[nA][H_RETGAN]+aPagos[nA][H_RETSUSS]+aPagos[nA][H_RETSLI]
		aPagos[nA][H_RETIB]		:=	TransForm(aPagos[nA][H_RETIB]  ,Tm(aPagos[nA][H_RETIB ] ,16,nDecs))
		aPagos[nA][H_RETGAN]		:=	TransForm(aPagos[nA][H_RETGAN] ,Tm(aPagos[nA][H_RETGAN] ,16,nDecs))
		aPagos[nA][H_RETIVA]		:=	TransForm(aPagos[nA][H_RETIVA] ,Tm(aPagos[nA][H_RETIVA] ,16,nDecs))
		aPagos[nA][H_RETSUSS]	:=	TransForm(aPagos[nA][H_RETSUSS],Tm(aPagos[nA][H_RETSUSS],16,nDecs))
		aPagos[nA][H_RETSLI]		:=	TransForm(aPagos[nA][H_RETSLI] ,Tm(aPagos[nA][H_RETSLI] ,16,nDecs))
		aPagos[nA][H_RETISI]		:=	TransForm(aPagos[nA][H_RETISI] ,Tm(aPagos[nA][H_RETISI] ,16,nDecs))
		//ANGOLA
	ElseIf cPaisLoc == "ANG"
		aPagos[nA][H_TOTRET]		:=	aPagos[nA][H_RETRIE]
		aPagos[nA][H_RETRIE]		:=	TransForm(aPagos[nA][H_RETRIE],Tm(aPagos[nA][H_RETRIE],16,nDecs))
	ElseIf cPaisLoc $ "DOM|COS"
		//Array aRetencao - Preenchido na fun็ใo fa050CalcRet() - Cแlculo de reten็ใo com Conf. de Impostos
		If Len(aRetencao) > 0
			For nX := 1 to Len(aRetencao)
				If aRetencao[nX][6] == aPagos[nA][H_FORNECE ] .And. aRetencao[nX][7] == aPagos[nA][H_LOJA ]
					For nY := 1 to Len(aRetencao[nX][8])
						If aRetencao[nX][8][nY][3] == "1"
							aPagos[nA][H_TOTRET ] += aRetencao[nX][8][nY][2]
						ElseIf aRetencao[nX][8][nY][3] == "2"
							aPagos[nA][H_NCC_PA ] += aRetencao[nX][8][nY][2]
							aPagos[nA][H_TOTALVL] -= aRetencao[nX][8][nY][2]
						EndIf
					Next nY
				EndIf
			Next nX
		Else
			aPagos[nA][H_TOTRET ] := 0
		EndIf
	ElseIf cPaisLoc == "EQU"
		aPagos[nA][H_TOTRET 	]	:= nAbatimentos
 		aPagos[nA][H_TOTALVL	]	:= aPagos[nA][H_NF] - aPagos[nA][H_NCC_PA] - aPagos[nA][H_TOTRET] - aPagos[nA][H_DESCVL] + aPagos[nA][H_MULTAS]
		aPagos[nA][H_NF		] 	:= aPagos[nA][H_NF     	]
		aPagos[nA][H_NCC_PA	] 	:= aPagos[nA][H_NCC_PA 	]
		aPagos[nA][H_TOTRET 	] 	:= aPagos[nA][H_TOTRET 	]
		aPagos[nA][H_DESCVL 	] 	:= aPagos[nA][H_DESCVL 	]
		aPagos[nA][H_MULTAS 	] 	:= aPagos[nA][H_MULTAS 	]
		aPagos[nA][H_TOTAL  	] 	:= aPagos[nA][H_TOTALVL	]
	Endif

	If	cPaisLoc $ "DOM|COS"
		If 	aPagos[nA][H_TOTALVL]	<	0
			aPagos[nA][1]				:=	0
			aPagos[nA][H_TOTALVL]	:=  0
		Else
			nValOrdens 				+=	aPagos[nA][H_TOTALVL]
			nNumOrdens++
		Endif
	Else
		IF cPaisLoc == "ARG"
			If 	aPagos[nA][H_TOTALVL]	<	0 .and. !lExisPA .and. nIVSUS <> 0 
				aPagos[nA][1]	:=	0
			Else
				nValOrdens 				+=	aPagos[nA][H_TOTALVL]
				nNumOrdens++
			Endif
		Else 
			If 	aPagos[nA][H_TOTALVL]	<	0
				aPagos[nA][1]				:=	0
			Else
				nValOrdens 				+=	aPagos[nA][H_TOTALVL]
				nNumOrdens++
			Endif
		Endif
	EndIf

	If cPaisLoc $ "DOM|COS"
		aPagos[nA][H_NF		] 	+=  aPagos[nA][H_TOTRET] //Somo as retencoes ja descontadas
	EndIf
	If cPaisLoc <> "EQU"
		aPagos[nA][H_DESCVL	]	:=	aPagos[nA][H_NCC_PA ]
		aPagos[nA][H_NF    	]	:=	TransForm(aPagos[nA][H_NF     ],Tm(aPagos[nA][H_NF]    ,16,nDecs))
		aPagos[nA][H_NCC_PA	]	:=	TransForm(aPagos[nA][H_NCC_PA ],Tm(aPagos[nA][H_NCC_PA],16,nDecs))
		aPagos[nA][H_TOTAL 	]	:=	TransForm(aPagos[nA][H_TOTALVL],Tm(aPagos[nA][H_TOTALVL] ,18,nDecs))

		IF lExisPA
			aPagos[nA][H_TOTAL ]	:=	TransForm(aPagos[nA][H_TOTALVL]+nIVSUS,Tm(aPagos[nA][H_TOTALVL] ,18,nDecs))
			aPagos[nA][H_TOTALVL] += nIVSUS
		Endif 	
	EndIf
	/*
	verifica se ha titulos vencidos, pois caso haja, os vencimentos dos cheques deverao ser informados pelo usuario */
	If aSE2[nA,5]
		aPagos[nA,H_UNICOCHQ] := 1
		aPagos[nA,H_MULTICHQ] := 1
	Else
		aPagos[nA,H_UNICOCHQ] := 1
		aPagos[nA,H_MULTICHQ] := 1
	Endif
Next nA

Return


/*
ฑฑบPrograma  ณF850VldBACบAutor  ณMicrosiga           บ Data ณ  13/02/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida Banco, Agencia y Cuenta.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ*/
Function F850VldBAC(aSE2,aTextoVld,lPA)
Local lRet		:= .T.
Local lCont		:= .F.
Local nLin		:= 0
Local nLenAcol	:= 0
Local nLenSE2	:= 0
Local nSE2		:= 0
Local nPorc		:= 0
Local nPosPorc	:= 0
Local nPosPgto	:= 0
Local nLenVld	:= 0
Local cTipoInt	:= ""
Local nLenTAcol := 0    
Local nTLin     := 0   
Local nPosFpago := 0
Local nVlrTit   := 0

Default lPA		:= .F.
Default aTextoVld	:= {}

nPosBanco	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_BANCO"})
nPosAge		:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_AGENCIA"})
nPosConta	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_CONTA"})
nPosFpago 	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_TIPO"})  
nVlrTit 	:= Ascan(oGetDad1:aHeader,{|X| Alltrim(X[2]) == "EK_VALOR"})

nLenSE2 := Len(aSE2)
nSE2 := 0
While (nSE2 < nLenSE2) 
	nTLin := 0
	nSE2++
	nLin := 0
	lCont := .T.
	If  aPagos[nSE2,1] <> 1
		Loop	
	EndIf
	
	If lPA
		Aadd(aTextoVld,{cFornece,cLoja,{},{}})
	Else
		Aadd(aTextoVld,{aPagos[nSE2,H_FORNECE],aPagos[nSE2,H_LOJA],{},{}})		
	Endif
	nLenTAcol := Len(aSE2[nSE2,1])
	If  nLenTAcol >0 
		While (nTLin < nLenTAcol) .And. lCont
			nTLin++
			If  Alltrim(aSE2[nSE2,1,nTLin,12]) == Alltrim(MVPAGANT) .Or. (Len(aSE2[nSE2,3,3]) > 0 .And. Len(aSE2[nSE2,3,2]) == 1 .And. Empty(aSE2[nSE2,3,2,1,nPosFpago]) .And. Empty(aSE2[nSE2,3,2,1,nVlrTit]))
				lCont := .F.  
				Exit			
			Endif			
		Enddo
	Endif
	nLenVld := Len(aTextoVld)
	nLenAcol := Len(aSE2[nSE2,3,2])
	If nLenAcol == 0
		Aadd(aTextoVld[nLenVld,3],AllTrim(STR0310) + "." )//"Nใo possui formas de pagamento definidas"
	Else
		While (nLin < nLenAcol) .And. lCont
			nLin++
			If !(Empty(aSE2[nSE2,3,2,nLin,nVlrTit]))  .and. (   (Empty(aSE2[nSE2,3,2,nLin,nPosBanco]) .OR. Empty(aSE2[nSE2,3,2,nLin,nPosAge]) .OR. Empty(aSE2[nSE2,3,2,nLin,nPosConta])) .AND. (cPaisloc == "ARG"))         
					lRet := .F.
					lCont := .F.
					Aadd(aTextoVld[nLenVld,3],AllTrim(STR0255))			
			Endif			
		Enddo
	Endif
EndDo

Return(lRet)

  //บDescricao ณ Validacion de fechas para pagos a traves de CBU            บ
Static Function VldFchCBU(lEsPreOP)
Local lPagCBU := .T.                   
Local cFchICBU := ctod("//")      
Local cFchFCBU := ctod("//")
Default lEsPreOP := .F.    

	If  lEsPreOP //Orden de Pago Previa 
		cFchICBU := POSICIONE("SA2",1,XFILIAL("SA2")+(cAliasPOP)->FJK_FORNEC+(cAliasPOP)->FJK_LOJA,"A2_CBUINI")   
		cFchFCBU := POSICIONE("SA2",1,XFILIAL("SA2")+(cAliasPOP)->FJK_FORNEC+(cAliasPOP)->FJK_LOJA,"A2_CBUFIM")
	Else         
		cFchICBU := SA2->A2_CBUINI      
		cFchFCBU := SA2->A2_CBUFIM	
	Endif
	If !Empty(cFchICBU) .And. !Empty(cFchFCBU)      
		If  Iif(!lEsPreOP,!((cAliasTmp)->E2_EMISSAO >= cFchICBU .And. (cAliasTmp)->E2_EMISSAO <= cFchFCBU),!(SE2->E2_EMISSAO >= cFchICBU .And. SE2->E2_EMISSAO <= cFchFCBU))  
			lPagCBU := .F.
		EndIf
	Else
		lPagCBU := .F.
	EndIf     
	
Return lPagCBU

  //บDescricao ณ Validacion de pagos a traves de CBU                        บ
Static Function VldPagCBU(nTipoCBU)
Local lPagCBU := .T.
	If nTipoCBU == 1
		If Len(aPagSinCBU) > 0 
			MessageBox(STR0405,"",16)
			lPagCBU := .F.
		ElseIf Len(aPagConCBU) == 0 
			MsgAlert(STR0405, STR0223)
		EndIf
	Else
		If Len(aPagConCBU) > 0 
			MessageBox(STR0405,"",16)
			lPagCBU := .F.
		EndIf
	EndIf
Return lPagCBU

  //บDescricao ณ Valida el documento, para saber si debe mandar el mensaje  บ
Static Function VldDocPag(nRecNoSE2, lAll)
Local lRet  := .T.
Local nLoop := 0
	
Default nRecNoSE2 := 0
Default lAll      := .F.
	
	DbSelectArea("SE2")
	SE2->(dbSetOrder(6))
	If nRecNoSE2 == 0
		For nLoop := 1 To Len(aRecNoSE2)
			SE2->(dbGoto(aRecNoSE2[nLoop][8]))
			If SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == aRecNoSE2[nLoop][1]+aRecNoSE2[nLoop][2]+aRecNoSE2[nLoop][3]+aRecNoSE2[nLoop][4]+aRecNoSE2[nLoop][5]
				If lShowPOrd
					If !Empty(SE2->E2_ORDPAGO) .And. SE2->E2_SALDO == 0
						lRet  := .F.
					EndIf
				Else
					If !Empty(SE2->E2_PREOK) .Or. (!Empty(SE2->E2_ORDPAGO) .And. SE2->E2_SALDO == 0)
						lRet  := .F.
					EndIf
				EndIf
			EndIf
		Next
		If !lRet
			If Len(aRecNoSE2) == 1
				MsgAlert(OemToAnsi(STR0407))
			Else
				MsgAlert(OemToAnsi(STR0408))
			EndIf
		EndIf
	Else
		SE2->(dbGoto(nRecNoSE2))
		If lShowPOrd
			If SE2->(E2_FORNECE+E2_LOJA) == (cAliasPOP)->(FJK_FORNEC+FJK_LOJA)
				If !Empty(SE2->E2_ORDPAGO) .And. SE2->E2_SALDO == 0
					lRet  := .F.
					If !lAll
						MsgAlert(OemToAnsi(STR0407))
					EndIf
				EndIf
			EndIf
		Else
			If SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == (cAliasTmp)->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
				If !Empty(SE2->E2_PREOK) .Or. (!Empty(SE2->E2_ORDPAGO) .And. SE2->E2_SALDO == 0)
					lRet  := .F.
					MsgAlert(OemToAnsi(STR0407))
				EndIf
			EndIf
		EndIf
	EndIf
Return (lRet)

///Funci๓n: ReCalAcmIB
///Autor: Juan Roberto Gonzแlez Rivas
///Fecha: 05/12/2016
///Desc: Fuci๓n para recalcular el acumulado por SFF o CCO para la retenci๓n de IIBB.
Static Function ReCalAcmIB (aIBAcum, aSE2Tmp, nPropImp, lMsFil, lRetPA, cAgente, lSUSSPrim, lIIBBTotal, aImpCalc, nRetTot, lOPRotAut)
	Local aIBArSE2 := SE2->(GetArea())
	Local aArea := {}
	Local nNF := 0
	Local nSigno := 0
	Local cPrvEnt := ""
	Local nB := 0
	Local aTmp := {}
	Local aTmpIB := {}
	Local aTmpMin := {}
	Local aTmpIBMin := {}
	Local nX := 0
	Local nI := 0
	Local aCCO := {}
	Local aSFF := {}
	Local aCCOOt := {}
	Local aSFFOt := {}
	Local aIBAcumTmp := {}
	Local nXt := 0
	Local lComp := .F.
	Local aCCOLim := {}	
	Local lCalcIB := .T.
	Local nIB	:= 0
	Local aImpCalAux := aClone(aImpCalc)
	Local nVlrPag	 := 0
	
	Default lOPRotAut := .F.

	For nNF := 1 To Len(aSE2Tmp[1])
		DbSelectArea('SE2')
		MsGoTo(aSE2Tmp[1][nNF][_RECNO])
		If SF1->(ColumnPos("F1_LIQGR")) > 0 .And. SF2->(ColumnPos("F2_LIQGR")) > 0
			If F850VerifG(lMsFil, If(lMsFil, SE2->E2_MSFIL, " "), SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_TIPO)
				Loop
			EndIf
		EndIf
		cFornece := aSE2Tmp[1][1][_FORNECE]
		cLoja := aSE2Tmp[1][1][_LOJA]
		nSigno := Iif(SE2->E2_TIPO $ MV_CPNEG + "/" + MVPAGANT, -1, 1)		
		aArea:=GetArea()
		dbSelectArea("SF1")
		dbSetOrder(1)
		If lMsFil
			SF1->(MsSeek(SE2->E2_MSFIL + SE2->E2_NUM + SE2->E2_PREFIXO + SE2->E2_FORNECE + SE2->E2_LOJA))
		Else
			SF1->(MsSeek(xFilial("SF1") + SE2->E2_NUM + SE2->E2_PREFIXO + SE2->E2_FORNECE + SE2->E2_LOJA))
		EndIf
		SD1->(DbSetOrder(1))
		If lMsFil
			SD1->(MsSeek(SF1->F1_MSFIL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
		Else
			SD1->(MsSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
		EndIf
		If SD1->(Found())
			If SD1->(ColumnPos("D1_PROVENT")) > 0 .And. !Empty(SD1->D1_PROVENT)
				cPrvEnt := SD1->D1_PROVENT
			ElseIf SF1->(ColumnPos("F1_PROVENT")) > 0 .And. !Empty(SF1->F1_PROVENT)
				cPrvEnt := SF1->F1_PROVENT
			EndIf
		EndIf
		RestArea(aArea)	
		aConfProv := CheckConfIB(SE2->E2_FORNECE, SE2->E2_LOJA, cPrvEnt, If(lMsFil, SE2->E2_MSFIL, " "))		
		For nB := 1 To Len(aProvLim)
			aProvLim[nB][2] := .T.
		Next nB		
		For nB := 1 To Len(aConfProv)
			lCalcIB := .T.
			If aConfProv[nB][4] != "M" .Or. (aConfProv[nB][4] == "M" .And.cPrvEnt != "CF")
				If !Empty(SE2->E2_PARCELA) .and. aConfProv[nB][5] == "2"
					For nIB := 1 To Len(aSE2Tmp[1])
						If aSE2Tmp[1][nIB][1] ==SE2->E2_FORNECE .And.  aSE2Tmp[1][nIB][2] == SE2->E2_LOJA .And. aSE2Tmp[1][nIB][9] ==SE2->E2_PREFIXO; 
							.And.	aSE2Tmp[1][nIB][10]== SE2->E2_NUM .And. aSE2Tmp[1][nIB][12]==SE2->E2_TIPO .And.  aSE2Tmp[1][nIB][11]<>SE2->E2_PARCELA ;
								.And. Len(aSE2Tmp[1][nIB][_RETIB])> 0  
									lCalcIB := .F.
							EndIf
					Next nIB
				EndIF
				If !lOPRotAut
					nVlrPag	:= oGetDad0:aCols[nNF][1]
				Else
					nVlrPag	:= aSE2Tmp[1][nNF][_VALOR]
				EndIF
				
				If  lCalcIB 
					If (SE2->E2_TIPO $ MVPAGANT + "/" + MV_CPNEG)
						aTmp :=	ARGRetIB2(cAgente, nSigno, nVlrPag, nPropImp, aConfProv[nB], lSUSSPrim, @lIIBBTotal, aImpCalAux,,nNF,,,,,,lOPRotAut)
					Else
						aTmp := ARGRetIB(cAgente, nSigno, nVlrPag, , , , nPropImp, aConfProv[nB], lSUSSPrim, @lIIBBTotal, aImpCalAux,,nNF,,,,,,lOPRotAut)
					Endif
				EndIf
			Endif			
			If Len(aTmp) > 0
				For nX := 1 to Len(aTmp)
					aAdd(aTmpIB, Array(12))
					aTmpIB[Len(aTmpIb)] := aClone(aTmp[nX])
					aAdd(aTmpIBMin, Array(12))
					aTmpIBMin[Len(aTmpIBMin)] := aClone(aTmp[nX])
					aAdd(aImpCalAux[nNF], {"IB", aTmp[nX][6]})
				Next nX				
				aTmp   := {}
				aTmpMin := {}
			Endif
		Next nB
		If Len(aTmpIB) > 0
			aAdd(aIBAcum, {nNF, aSE2Tmp[1][nNF], aClone(aTmpIB), AllTrim(SE2->E2_TIPO)})
			aAdd(aIBAcumTmp, {nNF, aSE2Tmp[1][nNF], aClone(aTmpIBMin), AllTrim(SE2->E2_TIPO)})			
			aTmpIB := {}
			aTmpIBMin := {}
		Else
			aTmpIB := {}
			aTmpIBMin := {}
			aAdd(aIBAcum, {nNF, aSE2Tmp[1][nNF], aClone(aTmpIB), AllTrim(SE2->E2_TIPO)})
			aAdd(aIBAcumTmp, {nNF, aSE2Tmp[1][nNF], aClone(aTmpIBMin), AllTrim(SE2->E2_TIPO)})
		Endif
	Next nNF	
	//Recopila la informaci๓n por CCO o SFF
	For nNF := 1 To Len(aIBAcum)
		For nB := 1 To Len(aIBAcum[nNF][3])
			//Si es por CCO
			If aIBAcum[nNF][3][nB][25] == "CCO"
				//Valida que la manera de obtenci๓n de mํnimo sea diferente de 0 y que exista un monto y que sea mayor de 0 para el monto mํnimo.
				If aIBAcum[nNF][3][nB][27] != 0 .And. (!Empty(aIBAcum[nNF][3][nB][26]) .Or. aIBAcum[nNF][3][nB][26] > 0)					
					nPosTipo := Ascan(aCCO, {|xT| xT[2] == aIBAcum[nNF][3][nB][9]})
					//Si ya existe un registro para esa provincia, se a๑ade el monto de base y retenci๓n.
					If nPosTipo > 0
						aCCO[nPosTipo][3] += aIBAcumTmp[nNF][3][nB][3] //Iif(lComp, aIBAcum[nNF][3][nB][3], aIBAcumTmp[nNF][3][nB][3])
						aCCO[nPosTipo][4] += aIBAcumTmp[nNF][3][nB][5] //Iif(lComp, aIBAcum[nNF][3][nB][5], aIBAcumTmp[nNF][3][nB][5]) 
						aCCO[nPosTipo][7] += aIBAcumTmp[nNF][3][nB][28] * (Iif(aIBAcum[nNF][3][nB][13] $ MVPAGANT + "/"+ MV_CPNEG .And. cPaisLoc == "ARG",-1,1)) //Iif(lComp, aIBAcum[nNF][3][nB][5], aIBAcumTmp[nNF][3][nB][5])
					Else
						//Si no existe, lo crea.
						aAdd(aCCO, {aIBAcumTmp[nNF][3][nB][27], aIBAcumTmp[nNF][3][nB][9], aIBAcumTmp[nNF][3][nB][3], aIBAcumTmp[nNF][3][nB][5], aIBAcumTmp[nNF][3][nB][26], .T., aIBAcumTmp[nNF][3][nB][28]})
					EndIf
				EndIf
			ElseIf aIBAcum[nNF][3][nB][25] == "SFF"
				//Valida que la manera de obtenci๓n de mํnimo sea diferente de 0 y que exista un monto y que sea mayor de 0 para el monto mํnimo.
				If !Empty(aIBAcum[nNF][3][nB][26]) .Or. aIBAcum[nNF][3][nB][26] > 0
					nPosTipo := Ascan(aSFF, {|xT| xT[1] == aIBAcum[nNF][3][nB][11] +"|"+ aIBAcum[nNF][3][nB][12] .And. xT[5] == aIBAcum[nNF][3][nB][9] .And. xT[3] == aIBAcum[nNF][3][nB][26] })
					//Si ya existe un registro para esa provincia, se a๑ade el monto de base y retenci๓n.
					If nPosTipo > 0
						aSFF[nPosTipo][2] += aIBAcumTmp[nNF][3][nB][3] 
					Else 
						//Si no existe, lo crea.
						aAdd(aSFF, {aIBAcumTmp[nNF][3][nB][11]+"|"+aIBAcumTmp[nNF][3][nB][12], aIBAcumTmp[nNF][3][nB][3], aIBAcumTmp[nNF][3][nB][26], .T., aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][27], aIBAcum[nNF][3][nB][28]})						
					EndIf
				EndIf
			EndIf			
			//Si hay limite calculable por CCO
			If aIBAcum[nNF][3][nB][30]
				nPosTipo := Ascan(aCCOLim, {|xT| xT[1] == aIBAcum[nNF][3][nB][9]})				
				If nPosTipo > 0
					aCCOLim[nPosTipo][2] += aIBAcum[nNF][3][nB][3]
				Else //Si no existe, lo crea.
					Aadd(aCCOLim, {aIBAcumTmp[nNF][3][nB][9], aIBAcumTmp[nNF][3][nB][3], aIBAcumTmp[nNF][3][nB][31], aIBAcumTmp[nNF][3][nB][32], aIBAcumTmp[nNF][3][nB][33],})				
				EndIf
			EndIf			
		Next nB
	Next nNF	
	//Realiza los calculos para validar los montos
	If Len(aCCO) > 0
		For nXt := 1 To Len(aCCO)
			If aCCO[nXt][1] == 1 //Base Imponible Mํnima
				aCCO[nXt][6] := Iif(ABS(aCCO[nXt][3]) >= ABS(aCCO[nXt][5]), .T., .F.)
			ElseIf aCCO[nXt][1] == 2 //Retenci๓n Mํnima
				aCCO[nXt][6] := Iif(ABS(aCCO[nXt][4]) >= ABS(aCCO[nXt][5]), .T., .F.)
			ElseIf aCCO[nXt][1] == 3 //Base Imponible Mํnima + Impuestos
				aCCO[nXt][6] := Iif(ABS(aCCO[nXt][7]) >= ABS(aCCO[nXt][5]), .T., .F.)
			EndIf
		Next nXt
	EndIf	
	If Len(aSFF) > 0
		//Valida si el tipo de retenci๓n mํnima es 3, para lo que se usarแ la base imponible mแs impuestos, de lo contrario solamente la base imponible.
		For nXt := 1 To Len(aSFF)
			//Valida si el tipo de retenci๓n mํnima es 3, para lo que se usarแ la base imponible mแs impuestos, de lo contrario solamente la base imponible.
			If aSFF[nXt][6] == 3
				If aSFF[nXt][7] != 0
					aSFF[nXt][4] := Iif(ABS(aSFF[nXt][7]) >= ABS(aSFF[nXt][3]), .T., .F.)
				Else
					aSFF[nXt][4] := .F.
				EndIf
			Else
				If aSFF[nXt][5]$ "ER"
					aSFF[nXt][4] :=  .T.
				Else
					aSFF[nXt][4] := Iif(ABS(aSFF[nXt][2]) >= ABS(aSFF[nXt][3]), .T., .F.)
				EndIf
			EndIF
		Next nXt
	EndIf	
	//Recopila la informaci๓n por CCO o SFF
	For nNF := 1 To Len(aIBAcum)
		For nB := 1 To Len(aIBAcum[nNF][3])
			//Si es por CCO
			If aIBAcum[nNF][3][nB][25] == "CCO"
				//Valida que la manera de obtenci๓n de mํnimo sea diferente de 0 y que exista un monto y que sea mayor de 0 para el monto mํnimo.
				If aIBAcum[nNF][3][nB][27] != 0 .And. (!Empty(aIBAcum[nNF][3][nB][26]) .Or. aIBAcum[nNF][3][nB][26] > 0)
					nPosTipo := Ascan(aCCO, {|xT| xT[2] == aIBAcum[nNF][3][nB][9]})
					//Si ya existe un registro para esa provincia, se a๑ade el monto de base y retenci๓n.
					If nPosTipo > 0
						If !aCCO[nPosTipo][6]
							aIBAcum[nNF][3][nB][5] := 0
							aIBAcum[nNF][3][nB][6] := 0
						Else
							aAdd(aImpCalc[nNF], {"IB", aIBAcum[nNF][3][nB][5]})
							nRetTot += aIBAcum[nNF][3][nB][5]
						EndIf
					EndIf
				Else
					If Len(aCCOLim) > 0
						nPosTipo := Ascan(aCCOLim, {|xT| xT[1] == aIBAcum[nNF][3][nB][9]})						
						If nPosTipo > 0
							If !aCCOLim[nPosTipo][6]
								aIBAcum[nNF][3][nB][5] := 0
								aIBAcum[nNF][3][nB][6] := 0
							EndIf
						EndIf
					EndIf
					aAdd(aImpCalc[nNF], {"IB", aIBAcum[nNF][3][nB][5]})
					nRetTot += aIBAcum[nNF][3][nB][5]
				EndIf
			ElseIf aIBAcum[nNF][3][nB][25] == "SFF"
				//Valida que la manera de obtenci๓n de mํnimo sea diferente de 0 y que exista un monto y que sea mayor de 0 para el monto mํnimo.
				If !Empty(aIBAcum[nNF][3][nB][26]) .Or. aIBAcum[nNF][3][nB][26] > 0
					nPosTipo := Ascan(aSFF, {|xT| xT[1] == aIBAcum[nNF][3][nB][11] +"|"+ aIBAcum[nNF][3][nB][12] .And. xT[5] == aIBAcum[nNF][3][nB][9] .And. xT[3] == aIBAcum[nNF][3][nB][26] })
					//Si ya existe un registro para esa provincia, se a๑ade el monto de base y retenci๓n.
					If nPosTipo > 0
						If !aSFF[nPosTipo][4]
							aIBAcum[nNF][3][nB][5] := 0
							aIBAcum[nNF][3][nB][6] := 0
						Else
							aAdd(aImpCalc[nNF], {"IB", aIBAcum[nNF][3][nB][5]})
							nRetTot += aIBAcum[nNF][3][nB][5]
						EndIf
					EndIf
				Else
					If Len(aCCOLim) > 0
						nPosTipo := Ascan(aCCOLim, {|xT| xT[1] == aIBAcum[nNF][3][nB][9]})						
						If nPosTipo > 0
							If !aCCOLim[nPosTipo][6]
								aIBAcum[nNF][3][nB][5] := 0
								aIBAcum[nNF][3][nB][6] := 0
							EndIf
						EndIf
					EndIf
					aAdd(aImpCalc[nNF], {"IB", aIBAcum[nNF][3][nB][5]})
					nRetTot += aIBAcum[nNF][3][nB][5]
				EndIf
			Else
				If Len(aCCOLim) > 0
					nPosTipo := Ascan(aCCOLim, {|xT| xT[1] == aIBAcum[nNF][3][nB][9]})					
					If nPosTipo > 0
						If !aCCOLim[nPosTipo][6]
							aIBAcum[nNF][3][nB][5] := 0
							aIBAcum[nNF][3][nB][6] := 0
						EndIf
					EndIf
				EndIf				
				aAdd(aImpCalc[nNF], {"IB", aIBAcum[nNF][3][nB][5]})
				nRetTot += aIBAcum[nNF][3][nB][5]
			EndIf
		Next nB
	Next nNF	
	RestArea(aIBArSE2)
Return
///Funci๓n: CalcAcIB
///Autor: Juan Roberto Gonzแlez Rivas
///Fecha: 10/01/2016
///Desc: Fuci๓n parka calcular el acumulado por SFF o CCO para la retenci๓n de IIBB.
Static Function CalcAcIB (aIBAcum, nI, aOrdPg, nControl, lShowPOrd, lBxParc, nPropImp, aRecnoSE2, lNaoMarca, cMarcaE2, lMsFil, lRetPA, aParc, lPropIB, cAgente, aIB, lSUSSPrim, lIIBBTotal,lOPRotAut )
	Local aIBArSE2 := SE2->(GetArea())
	Local aArea := {}
	Local aCCO := {}
	Local aSFF := {}
	Local aCCOOtros := {}
	Local aSFFOtros := {}
	Local nNF := 0
	Local nSigno := 0
	Local nValLot := 0
	Local nValBase := 0
	Local cPrvEnt := ""
	Local nPosSE2 := 0
	Local nVlrPOP := 0
	Local nB := 0
	Local aTmp := {}
	Local nZ := 0
	Local nA := 0
	Local aTmpIB := {}
	Local nPosTipo := 0
	Local nXt := 0
	Local aRetCor := {}
	Local lCouta	:= .T.
	Local aCouta  := {}
	Local nPosCuo := 0
	Local aCCOLim := {}	
	Local lNoCalc := .F.
	Local lIsMark	:= .F.
	Default lOPRotAut	:= .F.
	aProvLim := {}	
	For nNF := 1 To Len(aOrdPg[nI][4])
		DbSelectArea('SE2')
		MsGoTo(aOrdPg[nI][4][nNF])
		If SF1->(ColumnPos("F1_LIQGR")) > 0 .And. SF2->(ColumnPos("F2_LIQGR")) > 0 
			lNoCalc := F850VerifG(lMsFil, If(lMsFil, SE2->E2_MSFIL, " "), SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_TIPO)
			DbSelectArea('SE2')
			MsGoTo(aOrdPg[nI][4][nNF])
		EndIf
		nPosSE2 := Ascan(aRecnoSE2,{|j| j[8] == aOrdPg[nI][4][nNF]})
		nVlrPOP := If(nPosSE2 > 0, aRecnoSE2[nPosSE2,9], 0)
		If lNaoMarca .Or. IsMark("E2_OK", cMarcaE2, .F.) .Or. lOPRotAut
			If !lShowPOrd .And. cPaisLoc = "ARG"
				nValLot := F850RecPgt(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA)
			Endif			
			nSigno := Iif(SE2->E2_TIPO $ MV_CPNEG + "/" + MVPAGANT, -1, 1)			
			//Valor base de calculo
			If lBxParc .And. SE2->E2_VLBXPAR > 0 .And. SE2->E2_VLBXPAR <= SE2->E2_SALDO
				nValBase := SE2->E2_VLBXPAR - nValLot
			Else
				nValBase := SE2->E2_SALDO - nValLot
			EndIf			
			aArea:=GetArea()
			dbSelectArea("SF1")
			dbSetOrder(1)
			If lMsFil
				SF1->(MsSeek(SE2->E2_MSFIL + SE2->E2_NUM + SE2->E2_PREFIXO + SE2->E2_FORNECE + SE2->E2_LOJA))
			Else
				SF1->(MsSeek(xFilial("SF1") + SE2->E2_NUM + SE2->E2_PREFIXO + SE2->E2_FORNECE + SE2->E2_LOJA))
			EndIf
			SD1->(DbSetOrder(1))
			If lMsFil
				SD1->(MsSeek(SF1->F1_MSFIL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
			Else
				SD1->(MsSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
			EndIf
			If SD1->(Found())
				If SD1->(ColumnPos("D1_PROVENT")) > 0 .And. !Empty(SD1->D1_PROVENT)
					cPrvEnt := SD1->D1_PROVENT
				ElseIf SF1->(ColumnPos("F1_PROVENT")) > 0 .And. !Empty(SF1->F1_PROVENT)
					cPrvEnt := SF1->F1_PROVENT
				EndIf
			EndIf
			RestArea(aArea)		
			If !lNoCalc		
			aConfProv := CheckConfIB(SE2->E2_FORNECE, SE2->E2_LOJA, cPrvEnt, If(lMsFil, SE2->E2_MSFIL, " "))			
			For nB := 1 To Len(aConfProv)
				If lRetPA .Or. !(SE2->E2_TIPO $ MVPAGANT)
					If aConfProv[nB][4] != "M" .Or. (aConfProv[nB][4] == "M" .And. ((Len(aParc) > 1 .And. SE2->E2_PARCELA == aParc[1] .And. !lPropIB) .Or. Len(aParc) == 0 .Or. (lPropIB .And. Len(aParc) > 1)))
						If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
							aTmp := ARGRetIB2(cAgente, nSigno,Iif(lShowPOrd,nVlrPOP,SE2->E2_SALDO), nPropImp, aConfProv[nB], lSUSSPrim, @lIIBBTotal,,,,,,,,,lOPRotAut)
						Else
							aTmp := ARGRetIB(cAgente, nSigno,Iif(lShowPOrd,nVlrPOP,SE2->E2_SALDO), , , , nPropImp, aConfProv[nB], lSUSSPrim, @lIIBBTotal,,,,,,,,,lOPRotAut)
						Endif
					Else
						aTmp := {}
					Endif
				Endif				
				//Realizando os ajustes de IB, quando realizada a baixa parcial
				If aConfProv[nB][4] == "M" .And. cPrvEnt == "CF"
					If Len(aIB) > 0
						For nZ := 1 to Len(aIB)
							For nA := 1 to Len(aTmp)
								If (aIB[nZ][1] == aTmp[nA][1]) .And. (aIB[nZ][2] == aTmp[nA][2]) .And. (aIB[nZ][3] == aTmp[nA][9]) .And. (aTmp[nA][5] >= aIB[nZ][4])
									aTmp[nA][5] -= aIB[nZ][4]
								Endif
							Next nA
						Next nZ
					Endif
				Endif				
				aIB := {}				
				If Len(aTmp) > 0
					For nA := 1 to Len(aTmp)
						aAdd(aTmpIB, Array(12))
						aTmpIB[Len(aTmpIb)] := aTmp[nA]
					Next nA					
					aTmp   := {}
				Endif
			Next nB	
			EndIf
			If Len(aTmpIB) > 0
				aAdd(aIBAcum, {nControl, aOrdPg[nI][4][nNF], aClone(aTmpIB), Iif(lShowPOrd .and. nVlrPOP != nValBase, .T., .F.), AllTrim(SE2->E2_TIPO),.T.})
				aTmpIB := {}
			Else
				aTmpIB := {}
				aAdd(aIBAcum, {nControl, aOrdPg[nI][4][nNF], aClone(aTmpIB), Iif(lShowPOrd .and. nVlrPOP != nValBase, .T., .F.), AllTrim(SE2->E2_TIPO),.F.})
			Endif
		EndIf
	Next nNF	
	//Recopila la informaci๓n por CCO o SFF
	For nNF := 1 To Len(aIBAcum)
		For nB := 1 To Len(aIBAcum[nNF][3])
			//Si es por CCO
			If aIBAcum[nNF][3][nB][25] == "CCO"
				//Valida que la manera de obtenci๓n de mํnimo sea diferente de 0 y que exista un monto y que sea mayor de 0 para el monto mํnimo.
				If aIBAcum[nNF][3][nB][27] != 0 .And. (!Empty(aIBAcum[nNF][3][nB][26]) .Or. aIBAcum[nNF][3][nB][26] > 0)
					nPosTipo := Ascan(aCCO, {|xT| xT[2] == aIBAcum[nNF][3][nB][9]})
					//Si ya existe un registro para esa provincia, se a๑ade el monto de base y retenci๓n.
					If nPosTipo > 0
						aCCO[nPosTipo][3] += aIBAcum[nNF][3][nB][3]
						aCCO[nPosTipo][4] += aIBAcum[nNF][3][nB][5]
						aCCO[nPosTipo][7] += aIBAcum[nNF][3][nB][28] *(Iif(aIBAcum[nNF][3][nB][13] $ MVPAGANT + "/"+ MV_CPNEG .And. cPaisLoc == "ARG",-1,1))
					Else //Si no existe, lo crea.
						aAdd(aCCO, {aIBAcum[nNF][3][nB][27], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][3], aIBAcum[nNF][3][nB][5], aIBAcum[nNF][3][nB][26], .T., aIBAcum[nNF][3][nB][28]})
					EndIf
				EndIf
			ElseIf aIBAcum[nNF][3][nB][25] == "SFF"
				//Valida que la manera de obtenci๓n de mํnimo sea diferente de 0 y que exista un monto y que sea mayor de 0 para el monto mํnimo.
				If !Empty(aIBAcum[nNF][3][nB][26]) .Or. aIBAcum[nNF][3][nB][26] > 0
					nPosTipo := Ascan(aSFF, {|xT| xT[1] == aIBAcum[nNF][3][nB][11] +"|"+ aIBAcum[nNF][3][nB][12] .And. xT[5] == aIBAcum[nNF][3][nB][9] .And. xT[3] == aIBAcum[nNF][3][nB][26] })
					//Si ya existe un registro para esa provincia, se a๑ade el monto de base y retenci๓n.
					If nPosTipo > 0
						aSFF[nPosTipo][2] += aIBAcum[nNF][3][nB][3]
					Else //Si no existe, lo crea.
						aAdd(aSFF, {aIBAcum[nNF][3][nB][11]+"|"+aIBAcum[nNF][3][nB][12], aIBAcum[nNF][3][nB][3], aIBAcum[nNF][3][nB][26], .T., aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][27], aIBAcum[nNF][3][nB][28]})
					EndIf
				EndIf
			EndIf
			//Si hay limite calculable por CCO
			If aIBAcum[nNF][3][nB][30]
				nPosTipo := Ascan(aCCOLim, {|xT| xT[1] == aIBAcum[nNF][3][nB][9]})
				
				If nPosTipo > 0
					aCCOLim[nPosTipo][2] += aIBAcum[nNF][3][nB][3]
				Else //Si no existe, lo crea.
					Aadd(aCCOLim, {aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][3], aIBAcum[nNF][3][nB][31], aIBAcum[nNF][3][nB][32], aIBAcum[nNF][3][nB][33],})				
				EndIf
			EndIf
		Next nB
	Next nNF	
	//Realiza los calculos para validar los montos
	If Len(aCCO) > 0
		For nXt := 1 To Len(aCCO)
			If aCCO[nXt][1] == 1 //Base Imponible Mํnima
				aCCO[nXt][6] := Iif(ABS(aCCO[nXt][3]) >= ABS(aCCO[nXt][5]), .T., .F.)
			ElseIf aCCO[nXt][1] == 2 //Retenci๓n Mํnima
				aCCO[nXt][6] := Iif(ABS(aCCO[nXt][4]) >= ABS(aCCO[nXt][5]), .T., .F.)
			ElseIf aCCO[nXt][1] == 3 //Base Imponible Mํnima + Impuestos
				aCCO[nXt][6] := Iif(ABS(aCCO[nXt][7]) >= ABS(aCCO[nXt][5]), .T., .F.)
			EndIf
		Next nXt
	EndIf	
	If Len(aSFF) > 0
		For nXt := 1 To Len(aSFF)
			//Valida si el tipo de retenci๓n mํnima es 3, para lo que se usarแ la base imponible mแs impuestos, de lo contrario solamente la base imponible.
			If aSFF[nXt][6] == 3
				If aSFF[nXt][7] != 0
					aSFF[nXt][4] := Iif(ABS(aSFF[nXt][7]) >= ABS(aSFF[nXt][3]), .T., .F.)
				Else
					aSFF[nXt][4] := .F.
				EndIf
			Else
				If aSFF[nXt][5]$ "ER"
					aSFF[nXt][4] :=  .T.
				Else
					aSFF[nXt][4] := Iif(ABS(aSFF[nXt][2]) >= ABS(aSFF[nXt][3]), .T., .F.)
				EndIf
			EndIF
		Next nXt
	EndIf	
	If Len(aCCOLim) > 0
		For nXt := 1 To Len(aCCOLim)
			//Valida si el tipo de retenci๓n mํnima es 3, para lo que se usarแ la base imponible mแs impuestos, de lo contrario solamente la base imponible.
			If (aCCOLim[nXt][2] + aCCOLim[nXt][5]) >= aCCOLim[nXt][3]
				aCCOLim[nXt][6] := .T.
				Aadd(aProvLim, {aCCOLim[nXt][1], .T.})
			Else
				aCCOLim[nXt][6] := .F.
			EndIf
		Next nXt
	EndIf
	//Recopila la informaci๓n por CCO o SFF
	For nNF := 1 To Len(aIBAcum)
		For nB := 1 To Len(aIBAcum[nNF][3])
			//Si es por CCO
			If aIBAcum[nNF][3][nB][25] == "CCO"
				//Valida que la manera de obtenci๓n de mํnimo sea diferente de 0 y que exista un monto y que sea mayor de 0 para el monto mํnimo.
				If aIBAcum[nNF][3][nB][27] != 0 .And. (!Empty(aIBAcum[nNF][3][nB][26]) .Or. aIBAcum[nNF][3][nB][26] > 0)
					nPosTipo := Ascan(aCCO, {|xT| xT[2] == aIBAcum[nNF][3][nB][9]})
					//Si ya existe un registro para esa provincia, se a๑ade el monto de base y retenci๓n.
					If nPosTipo > 0
						If !aCCO[nPosTipo][6]
							aIBAcum[nNF][3][nB][5] := 0
							aIBAcum[nNF][3][nB][6] := 0
						Else
							If Abs(aIBAcum[nNF][3][nB][5]) > 0
								//Si hay limite calculable por CCO
								If aIBAcum[nNF][3][nB][30] 
									nPosTipo := Ascan(aCCOLim, {|xT| xT[1] == aIBAcum[nNF][3][nB][9]})									
									If nPosTipo > 0
										If !aCCOLim[nPosTipo][6]
											aIBAcum[nNF][3][nB][5] := 0
											aIBAcum[nNF][3][nB][6] := 0
											aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .T.})
										Else
											//Si se supera el limite y la retencion es mayor de 0.
											If Abs(aIBAcum[nNF][3][nB][5]) > 0 
												aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .F.})
											EndIf
										EndIf
									EndIf
								Else
									aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .F.})
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					//Si es mayor que 0 la retencion
					If Abs(aIBAcum[nNF][3][nB][5]) > 0
						//Si hay limite calculable por CCO
						If aIBAcum[nNF][3][nB][30] 
							nPosTipo := Ascan(aCCOLim, {|xT| xT[1] == aIBAcum[nNF][3][nB][9]})							
							If nPosTipo > 0
								If !aCCOLim[nPosTipo][6]
									aIBAcum[nNF][3][nB][5] := 0
									aIBAcum[nNF][3][nB][6] := 0
									aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .T.})
								Else
									//Si se supera el limite y la retencion es mayor de 0.
									If Abs(aIBAcum[nNF][3][nB][5]) > 0 
										aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .F.})
									EndIf
								EndIf
							EndIf
						Else
							aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .F.})
						EndIf
					EndIf
				EndIf
			ElseIf aIBAcum[nNF][3][nB][25] == "SFF"
				//Valida que la manera de obtenci๓n de mํnimo sea diferente de 0 y que exista un monto y que sea mayor de 0 para el monto mํnimo.
				If !Empty(aIBAcum[nNF][3][nB][26]) .Or. aIBAcum[nNF][3][nB][26] > 0
					nPosTipo := Ascan(aSFF, {|xT| xT[1] == aIBAcum[nNF][3][nB][11] +"|"+ aIBAcum[nNF][3][nB][12] .And. xT[5] == aIBAcum[nNF][3][nB][9] .And. xT[3] == aIBAcum[nNF][3][nB][26] })
					//Si ya existe un registro para esa provincia, se a๑ade el monto de base y retenci๓n.
					If nPosTipo > 0
						If !aSFF[nPosTipo][4]
							aIBAcum[nNF][3][nB][5] := 0
							aIBAcum[nNF][3][nB][6] := 0
						Else 
							//Si es mayor que 0 la retencion
							If Abs(aIBAcum[nNF][3][nB][5]) > 0
								//Si hay limite calculable por CCO
								If aIBAcum[nNF][3][nB][30] 
									nPosTipo := Ascan(aCCOLim, {|xT| xT[1] == aIBAcum[nNF][3][nB][9]})									
									If nPosTipo > 0
										If !aCCOLim[nPosTipo][6]
											aIBAcum[nNF][3][nB][5] := 0
											aIBAcum[nNF][3][nB][6] := 0
											aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .T.})
										Else
											//Si se supera el limite y la retencion es mayor de 0.
											If Abs(aIBAcum[nNF][3][nB][5]) > 0 
												aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .F.})
											EndIf
										EndIf
									EndIf
								Else
									aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .F.})
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					//Si es mayor que 0 la retencion o si en la posicion 30 tiene activo el calculo de Limite por CCO.
					If Abs(aIBAcum[nNF][3][nB][5]) > 0
						//Si hay limite calculable por CCO
						If aIBAcum[nNF][3][nB][30]
							nPosTipo := Ascan(aCCOLim, {|xT| xT[1] == aIBAcum[nNF][3][nB][9]})							
							If nPosTipo > 0
								If !aCCOLim[nPosTipo][6]
									aIBAcum[nNF][3][nB][5] := 0
									aIBAcum[nNF][3][nB][6] := 0
									aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .T.})
								Else
									//Si se supera el limite y la retencion es mayor de 0.
									If Abs(aIBAcum[nNF][3][nB][5]) > 0 
										aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .F.})
									EndIf
								EndIf
							EndIf
						Else
							aAdd(aRetCor,{ aIBAcum[nNF][2], aIBAcum[nNF][3][nB][1], aIBAcum[nNF][3][nB][2], aIBAcum[nNF][3][nB][9], aIBAcum[nNF][3][nB][13], .F.})
						EndIf
					EndIf
				EndIf
			EndIf
		Next nB
	Next nNF	
	RestArea(aIBArSE2)
	aIBAcum := aClone(aRetCor)
Return

/*
บPrograma  ณFn850GtCpoบAutor  ณRaul Ortiz Medina   บ Data ณ  08/05/17   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Utilizada para obtener las propiedades de los campos para  บ
บ          ณ el grid de Retenciones                                     บ
ฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA850                                                    บ
*/
Static Function Fn850GtCpo(aCpos, aHeader)
Local nX := 0

	DbSelectArea("SX3")
	DbSetOrder(2)
	For nX := 1 To Len(aCpos)
		If SX3->(MsSeek(PadR(aCpos[nX],Len(SX3->X3_CAMPO))))
			Aadd(aHeader,{AllTrim(X3TITULO()),X3_CAMPO,Iif(AllTrim(aCpos[nX]) == "FE_CONCEPT", SPACE(Len(X3_PICTURE)), X3_PICTURE),X3_TAMANHO,X3_DECIMAL,"",X3_USADO,X3_TIPO,X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,"Fn850EdtRt()"})
		Endif
	Next nX
Return
/*
บPrograma  ณFn850GtRetบAutor  ณRaul Ortiz Medina   บ Data ณ  08/05/17   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Carga las retenciones para la pesta๑a correspondiente	  	  บ
บ          ณ                                                            บ
ฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA850                                                    บ
*/
Static Function Fn850GtRet(aColsR,aSE2)
Local nX := 0
Local nY := 0
Local nT    := 0
Local nZ    := 0
Local nPos := 0
Local nPosR := 0
Local cProv	:= ""
Local nP	:= 0
Local nSumPag := 0
Local nSumRet := 0
Local nSumIva := 0
Local nSumSuss := 0
Local nValPag := 0
Local nSumIb  := 0
Local nSumGan := 0
Local nOldIva := 0
Local nPagoT  := 0
	
	For nX := 1 To Len(aSE2[oLbx:nAt][1])

		If aSE2[oLbx:nAt][1][nX][_PAGAR] > 0 
			If aSE2[oLbx:nAt][1][nX][_TIPO] $ MVPAGANT + "/" + MV_CPNEG
				nValPag -= IIf(aSE2[oLbx:nAt][1][nX][_MOEDA] == 1,aSE2[oLbx:nAt][1][nX][_PAGAR], Round(xMoeda(aSE2[oLbx:nAt][1][nX][_PAGAR],aSE2[oLbx:nAt][1][nX][_MOEDA],1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))
			Else
				nValPag += IIf(aSE2[oLbx:nAt][1][nX][_MOEDA] == 1,aSE2[oLbx:nAt][1][nX][_PAGAR], Round(xMoeda(aSE2[oLbx:nAt][1][nX][_PAGAR],aSE2[oLbx:nAt][1][nX][_MOEDA],1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))  
			EndIf
		EndIf
	
		If Len(aSE2[oLbx:nAt][1][nX][_RETIVA]) > 0
			For nY := 1 To Len(aSE2[oLbx:nAt][1][nX][_RETIVA])
				nPos := ASCAN(aColsR,{|x|x[1] == "I" .and. x[7]== aSE2[oLbx:nAt][1][nX][_RETIVA][nY][10] })
				If nPos > 0
					aColsR[nPos][5] += aSE2[oLbx:nAt][1][nX][_RETIVA][nY][3]
					aColsR[nPos][8] += aSE2[oLbx:nAt][1][nX][_RETIVA][nY][6]
				Else
					aAdd(aColsR,{"I","","","A",aSE2[oLbx:nAt][1][nX][_RETIVA][nY][3],0,aSE2[oLbx:nAt][1][nX][_RETIVA][nY][10],aSE2[oLbx:nAt][1][nX][_RETIVA][nY][6],"",.F.})
				EndIf
				nSumIva += aSE2[oLbx:nAt][1][nX][_RETIVA][nY][6]
			Next nY
		EndIf
			
		If Len(aSE2[oLbx:nAt][1][nX][_RETIB]) > 0
			For nY := 1 To Len(aSE2[oLbx:nAt][1][nX][_RETIB])
				nPos := ASCAN(aColsR,{|x|x[1] == "B" .and. x[2]== aSE2[oLbx:nAt][1][nX][_RETIB][nY][9] .and. x[7]== aSE2[oLbx:nAt][1][nX][_RETIB][nY][4] })
				If nPos > 0
					aColsR[nPos][5] += aSE2[oLbx:nAt][1][nX][_RETIB][nY][3]
					aColsR[nPos][8] += aSE2[oLbx:nAt][1][nX][_RETIB][nY][6]
					nPosR := ASCAN(aRetPos,{|x|x[2] == nPos})
					aAdd(aRetPos[nPosR][3],{nX,nY,aSE2[oLbx:nAt][1][nX][_RETIB][nY][3]})
					aRetPos[nPosR][4][1] += aSE2[oLbx:nAt][1][nX][_RETIB][nY][3]
					aRetPos[nPosR][5][1] += aSE2[oLbx:nAt][1][nX][_RETIB][nY][3]
				Else
					aAdd(aColsR,{"B",aSE2[oLbx:nAt][1][nX][_RETIB][nY][9],aSE2[oLbx:nAt][1][nX][_RETIB][nY][14],aSE2[oLbx:nAt][1][nX][_RETIB][nY][29],aSE2[oLbx:nAt][1][nX][_RETIB][nY][3],0,aSE2[oLbx:nAt][1][nX][_RETIB][nY][4],aSE2[oLbx:nAt][1][nX][_RETIB][nY][6],"",.F.})
					aAdd(aRetPos,{aSE2[oLbx:nAt][1][nX][_RETIB][nY][9],Len(aColsR),{},{aSE2[oLbx:nAt][1][nX][_RETIB][nY][3],1,0,0},{aSE2[oLbx:nAt][1][nX][_RETIB][nY][3],0,0,0}})
					aAdd(aRetPos[Len(aRetPos)][3],{nX,nY,aSE2[oLbx:nAt][1][nX][_RETIB][nY][3]})
				EndIF
				nSumIb += aSE2[oLbx:nAt][1][nX][_RETIB][nY][6]
			Next nY
		EndIf
		
		If Len(aSE2[oLbx:nAt][1][nX][_RETSUSS]) > 0
			For nY := 1 To Len(aSE2[oLbx:nAt][1][nX][_RETSUSS])
				nPos := ASCAN(aColsR,{|x|x[1] == "S" .and. x[3]== aSE2[oLbx:nAt][1][nX][_RETSUSS][nY][8] .and. x[7]== aSE2[oLbx:nAt][1][nX][_RETSUSS][nY][7] })
				If nPos > 0
					aColsR[nPos][5] += aSE2[oLbx:nAt][1][nX][_RETSUSS][nY][3]
					aColsR[nPos][8] += aSE2[oLbx:nAt][1][nX][_RETSUSS][nY][6]
				Else
					aAdd(aColsR,{"S","",aSE2[oLbx:nAt][1][nX][_RETSUSS][nY][8],"A",aSE2[oLbx:nAt][1][nX][_RETSUSS][nY][3],0,aSE2[oLbx:nAt][1][nX][_RETSUSS][nY][7],aSE2[oLbx:nAt][1][nX][_RETSUSS][nY][6],"",.F.})
				EndIf
				nSumSuss += aSE2[oLbx:nAt][1][nX][_RETSUSS][nY][6] 
			Next nY
		EndIf
		
		If Len(aSE2[oLbx:nAt][1][nX][_RETSLI]) > 0
			For nY := 1 To Len(aSE2[oLbx:nAt][1][nX][_RETSLI])
				nPos := ASCAN(aColsR,{|x|x[1] == "L" })
				If nPos > 0
					If aSE2[oLbx:nAt][1][nX][_RETSLI][nY][6] < 0
						aColsR[nPos][5] -= ABS(aSE2[oLbx:nAt][1][nX][_RETSLI][nY][3])
					Else
						aColsR[nPos][5] += aSE2[oLbx:nAt][1][nX][_RETSLI][nY][3]
					EndIf
					aColsR[nPos][8] += aSE2[oLbx:nAt][1][nX][_RETSLI][nY][6]
				Else
					aAdd(aColsR,{"L","","","A",aSE2[oLbx:nAt][1][nX][_RETSLI][nY][3],0,aSE2[oLbx:nAt][1][nX][_RETSLI][nY][5],aSE2[oLbx:nAt][1][nX][_RETSLI][nY][6],"",.F.})
				EndIf
			Next nY
		EndIf
		
		If Len(aSE2[oLbx:nAt][1][nX][_RETISI]) > 0
			For nY := 1 To Len(aSE2[oLbx:nAt][1][nX][_RETISI])
				If Len(aSE2[oLbx:nAt][1][nX][28][nY][8])>0 .and. !Empty(aSE2[oLbx:nAt][1][nX][28][nY][8][1][2])
					cProv := POSICIONE("SFB",1,xFilial("SFB")+aSE2[oLbx:nAt][1][nX][_RETISI][nY][8][1][2],"FB_ESTADO")
				Else
					cProv := aSE2[oLbx:nAt][1][nX][_RETISI][nY][9]
				EndIf
				For nZ := 1 To Len(aSE2[oLbx:nAt][1][nX][_RETISI][nY][8])
					nPos := ASCAN(aColsR,{|x|x[1] == "M" .and. x[2]== cProv .and. IIF (Len(aSE2[oLbx:nAt][1][nX][_RETISI][nY][8]) > 0, x[7]== aSE2[oLbx:nAt][1][nX][_RETISI][nY][8][nZ][1], .F.) })
					If nPos > 0
						aColsR[nPos][5] += aSE2[oLbx:nAt][1][nX][_RETISI][nY][3]
						aColsR[nPos][8] += aSE2[oLbx:nAt][1][nX][_RETISI][nY][8][nZ][3]
					Else
						IF (Len(aSE2[oLbx:nAt][1][nX][_RETISI][nY][8]) > 0)
							aAdd(aColsR,{"M",cProv,"","A",aSE2[oLbx:nAt][1][nX][_RETISI][nY][3],0,aSE2[oLbx:nAt][1][nX][_RETISI][nY][8][nZ][1],aSE2[oLbx:nAt][1][nX][_RETISI][nY][8][nZ][3],"",.F.})
						EndIf
					EndIf
				Next nZ
			Next nY
		EndIf

	Next nX

	For nX := 1 To Len(aSE2[oLbx:nAt][2])
		If aSE2[oLbx:nAt][2][nX][2] < 0 .or. aSE2[oLbx:nAt][2][nX][5] <= 0
			aAdd(aColsR,{"G","",aSE2[oLbx:nAt][2][nX][7],"A",0,0,aSE2[oLbx:nAt][2][nX][3],0,"",.F.})
		Else
			aAdd(aColsR,{"G","",aSE2[oLbx:nAt][2][nX][7],"A",aSE2[oLbx:nAt][2][nX][2],0,aSE2[oLbx:nAt][2][nX][3],aSE2[oLbx:nAt][2][nX][5],"",.F.})
		EndIf
		nSumGan += aSE2[oLbx:nAt][2][nX][5]
	Next nX 
	
	If Len(aSE2[oLbx:nAt][1]) > 1 .And. Len(aRetIvAcm)> 1 .And. aRetIvAcm[2] <> Nil .And.  Len(aRetIvAcm[2]) > 0
		For nT := 1 to Len(aSE2[oLbx:nAt][1])
			nPagoT := IIF(aSE2[oLbx:nAt][1][nT][_TIPO] $ MVPAGANT + "/" + MV_CPNEG, -1 * aSE2[oLbx:nAt][1][nT][_PAGAR], aSE2[oLbx:nAt][1][nT][_PAGAR])
			nSumPag += Round(xMoeda(nPagoT,aSE2[oLbx:nAt][1][nT][_MOEDA],1,,5,,aTxMoedas[aSE2[oLbx:nAt][1][nT][_MOEDA]][2]),MsDecimais(1))
		Next
	EndIf
	nSumRet := nSumIb + nSumIva + nSumGan
	F850DocIVA(aSE2[oLbx:nAt][1][1][_FORNECE],aSE2[oLbx:nAt][1][1][_LOJA],IIF(nSumPag > 0, nSumPag, Round(xMoeda(aSE2[oLbx:nAt][1][1][_PAGAR],aSE2[oLbx:nAt][1][1][_MOEDA],1,,5,,aTxMoedas[aSE2[oLbx:nAt][1][1][_MOEDA]][2]),MsDecimais(1))),nSumRet)

	If aRetIvAcm[3] <> Nil .And. Len(aRetIvAcm)>2 .And. Len(aRetIvAcm[3]) > 0
		For nP := 1 to Len(aRetIvAcm[3])
			nPos := ASCAN(aColsR,{|x|x[1] == "I" .and. x[7] == aRetIvAcm[3][nP][10]})
			If nPos > 0
				aColsR[nPos][8] += aRetIvAcm[3][nP][6]
				nSumIva += aRetIvAcm[3][nP][6]
			EndIf
		Next
	EndIf

	nOldIVA := nSumIva

	If Len(aColsR) > 0
		For nZ := 1 to Len(aColsR)
			If aColsR[nZ] != Nil .And. aColsR[nZ][1] == "I"
				aColsR[nZ][5] := 0
				aColsR[nZ][8] := 0
			EndIf
		Next
	EndIf
	
	//Proporcionaliza as baixas parciais
	F850PropIV(nValPag,nOldIVA,@aSE2[oLbx:nAt],(nSumGan + nSumIb + nSumSuss))
	
	//Atualiza o IVA novamente
	For nX := 1 To Len(aSE2[oLbx:nAt][1])
		If Len(aSE2[oLbx:nAt][1][nX][_RETIVA]) > 0
			For nY := 1 To Len(aSE2[oLbx:nAt][1][nX][_RETIVA])
				nPos := ASCAN(aColsR,{|x|x[1] == "I" .and. x[7]== aSE2[oLbx:nAt][1][nX][_RETIVA][nY][10] })
				If nPos > 0
					aColsR[nPos][5] += aSE2[oLbx:nAt][1][nX][_RETIVA][nY][3]
					aColsR[nPos][8] += aSE2[oLbx:nAt][1][nX][_RETIVA][nY][6]
				EndIf
			Next nY
		EndIf
	Next nX

	If aRetIvAcm[3] <> Nil .And. Len(aRetIvAcm)>2 .And. Len(aRetIvAcm[3]) > 0
		For nP := 1 to Len(aRetIvAcm[3])
			nPos := ASCAN(aColsR,{|x|x[1] == "I" .and. x[7] == aRetIvAcm[3][nP][10]})
			If nPos > 0
				aColsR[nPos][5] += aRetIvAcm[3][nP][3]
				aColsR[nPos][8] += aRetIvAcm[3][nP][6]
			EndIf
		Next
	EndIf
	
	If Len(aColsR) == 0
		aAdd(aColsR,{"","","","",0,0,0,0,"",.F.})
	EndIf
Return

/*
บPrograma  ณFn850EdtRtบAutor  ณRaul Ortiz Medina   บ Data ณ  08/05/17   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Utilizada en el When para verificar si se podrแ modificar  บ
บ          ณ la linea seleccionada del grid de Retenciones              บ
ฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA850                                                    บ
*/
Function Fn850EdtRt()
Local nAt := oGetDad3:nAt
Local lRet := .F.
	If oGetDad3:acols[nAt][4] == "I"
		lRet := .T.
	EndIf
Return lRet

/*
บPrograma  ณFn850EdCpoบAutor  ณRaul Ortiz Medina   บ Data ณ  08/05/17   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Utilizada para realizar la actualizaci๓n de los valores delบ
บ          ณ grid de Retenciones al realizar una modificaci๓n           บ
ฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA850                                                    บ
*/
Function Fn850EdCpo(aSE2)
Local nAt 		:= oGetDad3:nAt
Local cCampo	:= ReadVar()
Local nValor 	:= &(cCampo)
Local nPos		:= 0

	If cCampo == "M->FE_VALBASE"
		nPos := ASCAN(aRetPos,{|x|x[2] == nAt})
		If nPos > 0 						
			aRetPos[nPos][4][2] := nValor / IIf(aRetPos[nPos][4][1] == 0 .And. aRetPos[nPos][5][1] !=0, aRetPos[nPos][5][1], aRetPos[nPos][4][1])
			If (aRetPos[nPos][4][1] == 0 .And. aRetPos[nPos][5][1] ==0)
			 	oGetDad3:aCols[nAt][8]	:= 0
				aRetPos[nPos][4][1] 	:= 0
				&cCampo := 0
			Else
				oGetDad3:aCols[nAt][8]	:= (nValor * (1 - Iif(oGetDad3:aCols[nAt][6]>0,oGetDad3:aCols[nAt][6]/100,oGetDad3:aCols[nAt][6])) * oGetDad3:aCols[nAt][7]) / 100
				aRetPos[nPos][4][1]		:= nValor
			Endif
			aRetPos[nPos][4][3] := oGetDad3:aCols[nAt][7]
		EndIf
	ElseIf cCampo == "M->FE_ALIQ"
		oGetDad3:aCols[nAt][8] := (oGetDad3:aCols[nAt][5] * (1 - Iif(oGetDad3:aCols[nAt][6]>0,oGetDad3:aCols[nAt][6]/100,oGetDad3:aCols[nAt][6])) * nValor) / 100
		nPos := ASCAN(aRetPos,{|x|x[2] == nAt})
		If nPos > 0 
			aRetPos[nPos][4][3] := nValor
		EndIf	
	ElseIf cCampo == "M->FE_DESGR"
		oGetDad3:aCols[nAt][8] := (oGetDad3:aCols[nAt][5] * (1 - Iif(nValor>0,nValor/100,nValor)) * oGetDad3:aCols[nAt][7]) / 100
		nPos := ASCAN(aRetPos,{|x|x[2] == nAt})
		If nPos > 0 
			aRetPos[nPos][4][4] := nValor
		EndIf
	EndIf
	
	oGetDad3:oBrowse:Refresh()
	
	Eval(bFnReLd)
	
Return .T.

/*
บPrograma  ณFn850ReLd บAutor  ณRaul Ortiz Medina   บ Data ณ  08/05/17   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Utilizada para realizar la actualizaciones de los valores  บ
บ          ณ de la OP                                                   บ
ฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA850                                                    บ
*/
Function Fn850ReLd(aSE2)
Local nPos		:= 0
Local nX		:= 0
Local nY 		:= 0
Local nAt 		:= oGetDad3:nAt
Local nRtIb 	:= 0
Local nRtIbN	:= 0
Local nTotDoc   := 0
Local cCampo	:= ReadVar()
		

	If oGetDad3:acols[nAt][4] == "I"
		nPos := ASCAN(aRetPos,{|x|x[2] == nAt})
		
		For nX := 1 To Len(aRetPos[nPos][3])
			nRtIb += aSE2[1][1][aRetPos[nPos][3][nX][1]][_RETIB][aRetPos[nPos][3][nX][2]][6]
			If  aRetPos[nPos][4,2] >= 0  .And. cCampo == "M->FE_VALBASE"  //Base
				aSE2[1][1][aRetPos[nPos][3][nX][1]][_RETIB][aRetPos[nPos][3][nX][2]][3] := ;
				IIf(aSE2[1][1][aRetPos[nPos][3][nX][1]][_RETIB][aRetPos[nPos][3][nX][2]][3] == 0 .And. aRetPos[nPos][5][1] !=0,;
				 	aRetPos[nPos][3][nX][3], ;
				 	aSE2[1][1][aRetPos[nPos][3][nX][1]][_RETIB][aRetPos[nPos][3][nX][2]][3] )* aRetPos[nPos][4,2] //Base
			EndIf
			If  aRetPos[nPos][4,3] >= 0     //Alicuota
				aSE2[1][1][aRetPos[nPos][3][nX][1]][_RETIB][aRetPos[nPos][3][nX][2]][4] := aRetPos[nPos][4,3] 
			EndIf
			aSE2[1][1][aRetPos[nPos][3][nX][1]][_RETIB][aRetPos[nPos][3][nX][2]][6] := (aSE2[1][1][aRetPos[nPos][3][nX][1]][_RETIB][aRetPos[nPos][3][nX][2]][3] * (1 - Iif (aRetPos[nPos][4,4] > 0,aRetPos[nPos][4,4]/100,aRetPos[nPos][4,4])) * aSE2[1][1][aRetPos[nPos][3][nX][1]][_RETIB][aRetPos[nPos][3][nX][2]][4])/100 //Retencion
			nRtIbN += aSE2[1][1][aRetPos[nPos][3][nX][1]][_RETIB][aRetPos[nPos][3][nX][2]][6]
		Next nY
		aRetPos[nPos][4,3] := 0
		nValLiq += nRtIb - nRtIbN
		nRetIb += nRtIbN - nRtIb
		nSaldoPgOP	+= nRtIb - nRtIbN
		nVlrPagar += nRtIb - nRtIbN
		aPagos[oLbx:nAt][H_RETIB] := Transform(nRetIb,Tm(aPagos[oLbx:nAt][H_RETIB ] ,16,nDecs))
		aPagos[oLbx:nAt][H_TOTALVL] += nRtIb - nRtIbN
		aPagos[oLbx:nAt][H_TOTAL] := Transform(aPagos[oLbx:nAt][H_TOTALVL],Tm(aPagos[oLbx:nAt][H_TOTALVL] ,18,nDecs))
		aPagos[oLbx:nAt][H_TOTRET] += nRtIb - nRtIbN	
	EndIf
	oLbx:aArray[1][7] := Transform(nValLiq,PesqPict("SE2","E2_VALOR"))
	oLbx:aArray[1][10] := Transform(nRetIb,Tm(nRetIB,19,nDecs))
	oLbx:Refresh()
	oSaldoPgOP:cCaption := Transform(nSaldoPgOP,PesqPict("SE2","E2_VALOR"))
	oSaldoPgOP:cTitle := Transform(nSaldoPgOP,PesqPict("SE2","E2_VALOR"))
	oSaldoPgOP:Refresh()
	oVlrPagar:Refresh()
	
	F850AtuProp()

Return .T.
/*/{Protheus.doc} RU06S850
(Function for Payment Order)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function RU06S850(cPar)
Local oDlg

Local aPriori as array 
Local cPrioriCBx :=""
Local oFJRExtNmb,oFJRPriori,oFJRBnkCod,oFJRBIKCod,oFJRCORACC,oFJRBkName,oFJRConta,oFJRRcName,;
oFJRVATCod,oFJRVATRat,oFJRVATAmt,oFJRReason,oFJRKPPPay,oFJRRecKPP,oCHFDIR,oCHFACC,oCSHR,oCSHNMB,oATTACH,oPSSPRT
Local aAreaSA2 :=SA2->(getArea()) 
Local cFornecRus 
Local cLojaRus  
Local lChange := .T. 
Private cFJRBnkCod  := CriaVar("FJR_BNKCOD")//'Bank Code'1
Private cFJRBIKCod  := CriaVar("FJR_BIKCOD")//'BIK Code'2
Private cFJRConta   := CriaVar("FJR_CONTA") //'Bank Account'
Private cFJRBkName  := CriaVar("FJR_BKNAME")//'Bank Name'4
Private cFJRExtNmb  := CriaVar("FJR_EXTNMB")//'External Number'5
Private cFJRPriori  := CriaVar("FJR_PRIORI")//'Priority of Payment'
Private cFJRReason  := CriaVar("FJR_REASON")//'Reason for Payment'
Private cFJRCORACC  := CriaVar("FJR_CORACC")//'Corresponding Account'3
Private cFJRRcName  := CriaVar("FJR_RCNAME")//"Receiver' s Name"
Private cFJRKPPPay  := CriaVar("FJR_KPPPAY")//'Payer’s KPP'
Private cFJRRecKPP  := CriaVar("FJR_RECKPP")//"Receiver’s KPP"
Private cFJRVATCod  := CriaVar("FJR_VATCOD")//"VAT Code"
Private cFJRVATRat  := CriaVar("FJR_VATRAT")//'VAT Rate'
Private cFJRVATAmt  := CriaVar("FJR_VATAMT")//'VAT Amount'
Private ๑CHFDIR_FJR := CriaVar("FJR_CHFDIR")	//Chief Director
Private ๑CHFACC_FJR := CriaVar("FJR_CHFACC")	//Chief Accountant
Private ๑CSHR_FJR	:= CriaVar("FJR_CSHR")		//Cashier
Private ๑CSHNMB_FJR := CriaVar("FJR_CSHNMB")	//Cash Book Number
Private ๑ATTACH_FJR := CriaVar("FJR_ATTACH")	//Attachment
Private ๑PSSPRT_FJR := CriaVar("FJR_PSSPRT")	//Passport Data
Default aPagos := {}

If  Empty(aDet850RUS)
	a850ArrRus()
EndIf

If !Empty(aPagos)
	cFornecRus :=  aPagos[oLBx:nAT][2]
	cLojaRus := aPagos[oLBx:nAT][3] 
Else 

	cFornecRus := SE2->E2_FORNECE
	cLojaRus := SE2->E2_LOJA 
EndIf 

 nOpc :=0                 
cPrioriCBx := RU99SX3("FJR_PRIORI")
aPriori := StrTokArr(cPrioriCBx, ";" )
If cPar == "Changeable"
	lChange := .F.
EndIf
SA2->(dbSetOrder(1))
If MsSeek(xFilial('SA2')+cFornecRus+cLojaRUS)
	If Empty(cFJRRecKPP) 
		cFJRRecKPP := SA2->A2_KPP
	EndIf
EndIf
RestArea(aAreaSA2)

	 a850getVar(,lChange) 
DEFINE MSDIALOG oDlg TITLE STR0413 FROM 3,0 TO 500,560 PIXEL 

@ 05,10 To 240,275 Pixel Of oDlg LABEL OemToAnsi(STR0413)

@ 15,15 SAY OemToAnsi(STR0414) Size 60,08 Pixel Of oDlg  
@ 25,15 MSGET oFJRBnkCod VAR cFJRBnkCod F3 "FIL" PICTURE PesqPict("FJR","FJR_BNKCOD") valid RUSgetBK850(cFJRBnkCod,cFJRBIKCod) WHEN lChange SIZE 20,10 PIXEL OF oDlg
 
@ 15,47 SAY OemToAnsi(STR0415) Size 60,08 Pixel Of oDlg 
@ 25,45 MSGET oFJRBIKCod VAR cFJRBIKCod PICTURE  PesqPict("FJR","FJR_BIKCOD") WHEN .F. SIZE 30,10 PIXEL OF oDlg
oFJRBIKCod:Disable()

@ 15,85 SAY OemToAnsi(STR0421 ) Size 80,08 Pixel Of oDlg 
@ 25,85 MSGET oFJRConta VAR cFJRConta PICTURE PesqPict("FJR","FJR_CONTA")WHEN .F. SIZE 80,10 PIXEL OF oDlg
 oFJRConta:Disable()

@ 15,170 SAY OemToAnsi(STR0417) Size 60,08 Pixel Of oDlg 
@ 25,170 MSGET oFJRBkName VAR cFJRBkName PICTURE PesqPict("FJR","FJR_BKNAME")WHEN .F. SIZE 100,10 PIXEL OF oDlg
oFJRBkName:Disable()

@ 40,15 SAY OemToAnsi(STR0416) Size 80,08 Pixel Of oDlg 
@ 50,15 MSGET oFJRCORACC VAR cFJRCORACC PICTURE PesqPict("FJR","FJR_CORACC")WHEN .F. SIZE 90,10 PIXEL OF oDlg

@ 40,110 SAY OemToAnsi(STR0418) Size 100,08 Pixel Of oDlg 
@ 50,110 MSGET oFJRExtNmb VAR cFJRExtNmb PICTURE PesqPict("FJR","FJR_EXTNMB") WHEN lChange SIZE 60,10 PIXEL OF oDlg

Iif (Empty(cFJRPriori),cFJRPriori := aPriori[5],cFJRPriori)
@ 40,180 SAY OemToAnsi(STR0419 ) Size 70,08 Pixel Of oDlg 
@ 50,180 MSCOMBOBOX oFJRPriori VAR cFJRPriori  ITEMS aPriori WHEN lChange SIZE 50,10 PIXEL OF oDlg

@ 65,15 SAY OemToAnsi(STR0422 ) Size 90,08 Pixel Of oDlg 
@ 75,15 MSGET oFJRRcName VAR cFJRRcName PICTURE PesqPict("FJR","FJR_RCNAME") WHEN lChange SIZE 125,10 PIXEL OF oDlg

@ 65,150 SAY OemToAnsi(STR0424 ) Size 80,08 Pixel Of oDlg 
@ 75,150 MSGET oFJRRecKPP VAR cFJRRecKPP PICTURE PesqPict("FJR","FJR_RECKPP") WHEN lChange SIZE 50,10 PIXEL OF oDlg

@ 65,210 SAY OemToAnsi(STR0423) Size 80,08 Pixel Of oDlg 
@ 75,210 MSGET oFJRKPPPay VAR cFJRKPPPay PICTURE PesqPict("FJR","FJR_KPPPAY") WHEN lChange SIZE 50,10 PIXEL OF oDlg

@ 90,15 SAY OemToAnsi(STR0425 ) Size 60,08 Pixel Of oDlg 
@ 100,15 MSGET oFJRVATCod VAR cFJRVATCod F3 "F30" PICTURE PesqPict("FJR","FJR_VATCOD") valid {||FillRsn850(), GetVatC850(cFJRVATCod) } WHEN lChange SIZE 50,10 PIXEL OF oDlg

@ 90,70 SAY OemToAnsi(STR0426) Size 60,08 Pixel Of oDlg 
@ 100,70 MSGET oFJRVATRat VAR cFJRVATRat PICTURE PesqPict("FJR","FJR_VATRAT") valid FillRsn850()  WHEN .F. SIZE 20,10 PIXEL OF oDlg

@ 90,105 SAY OemToAnsi(STR0427) Size 60,08 Pixel Of oDlg 
@ 100,100 MSGET oFJRVATAmt VAR cFJRVATAmt PICTURE PesqPict("FJR","FJR_VATAMT") valid FillRsn850() WHEN lChange SIZE 50,10 PIXEL OF oDlg

@ 90,160 SAY OemToAnsi(STR0428) Size 60,08 Pixel Of oDlg 
@ 100,160 MSGET oCHFDIR VAR ๑CHFDIR_FJR F3 "F42DIR" PICTURE PesqPict("FJR","FJR_CHFDIR") WHEN lChange SIZE 80,10 PIXEL OF oDlg

@ 115,15 SAY OemToAnsi(STR0429) Size 60,08 Pixel Of oDlg 
@ 125,15 MSGET oCHFACC VAR ๑CHFACC_FJR F3 "F42ACC" PICTURE PesqPict("FJR","FJR_CHFACC") WHEN lChange SIZE 50,10 PIXEL OF oDlg

@ 115,75 SAY OemToAnsi(STR0430) Size 80,08 Pixel Of oDlg 
@ 125,75 MSGET oCSHR VAR ๑CSHR_FJR F3 "F42CSH" PICTURE PesqPict("FJR","FJR_CSHR") WHEN lChange SIZE 80,10 PIXEL OF oDlg

@ 115,160 SAY OemToAnsi(STR0431) Size 60,08 Pixel Of oDlg 
@ 125,160 MSGET oCSHNMB VAR ๑CSHNMB_FJR PICTURE PesqPict("FJR","FJR_CSHNMB") WHEN lChange SIZE 80,10 PIXEL OF oDlg

@ 140,15 SAY OemToAnsi(STR0432) Size 60,08 Pixel Of oDlg 
@ 150,15 MSGET oATTACH VAR ๑ATTACH_FJR PICTURE PesqPict("FJR","FJR_ATTACH") WHEN lChange SIZE 90,10 PIXEL OF oDlg

@ 140,125 SAY OemToAnsi(STR0433) Size 60,08 Pixel Of oDlg 
@ 150,125 MSGET oPSSPRT VAR ๑PSSPRT_FJR PICTURE PesqPict("FJR","FJR_PSSPRT") WHEN lChange SIZE 90,10 PIXEL OF oDlg

@ 170,15 SAY OemToAnsi(STR0420 ) Size 80,08 Pixel Of oDlg 
oFJRReason := tMultiget():new( 180, 15, {| u | if( pCount() > 0, cFJRReason := u, cFJRReason ) },oDlg, 255, 30, , , , , , .T.,,,{||lChange},,,,/*{|| RUSlengstr()}*/ )

DEFINE SBUTTON FROM 220,195 TYPE 1 ACTION {||oDlg:End(), nOpc := 1} ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 220,235 TYPE 2 ACTION {||oDlg:End()} ENABLE OF oDlg PIXEL
ACTIVATE MSDIALOG oDlg CENTER

If nOpc == 1 .and. lChange
	a850SetVar()
Endif

Return
/*/{Protheus.doc} RU06S850CL
(Function for Payment Order to clear value)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function RU06S850CL()
aDet850RUS :={}
Return .T.
/*/{Protheus.doc} RU99SX3
(Function for Payment Order to take value from combobox)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Static Function RU99SX3(cField)
Local cFieldRes :=""
Local aAreaSX3 := SX3->(getArea())

DbSelectArea("SX3")
SX3->(dbSetOrder(2))
SX3->(MsSeek(cField))
cFieldRes := X3Cbox()
RestArea(aAreaSX3)
Return cFieldRes
/*/{Protheus.doc} FillRsn850
(Function for Payment Order to fill the Reason)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function FillRsn850()
Local lRet := .T.
Local nI :=0
Local cPosFornece :=""
Local cPosLoja :=""
Local cNumDoc :=""
Local nSumm :=0
Local cNumDocDt :=""
Local cNumberCon :=""
Local cPrevContr :=""
Local cRate :=""
Local cPart1 :=""
Local cPart2 :=""
Local cPart3 :=""

lRet := .T.
cPosFornece := aPagos[oLBx:nAt, 2]
cPosLoja := aPagos[oLBx:nAt, 3]
cNumDoc := ""
nSumm := 0
cNumDocDt := ""
cNumberCon := ""
cPrevContr := ""
cRate := ""
cPart1 := ""
cPart2 := ""
cPart3 := ""

For nI := 1 To Len(oGetDad0:aCols)
	If (cPosFornece + cPosLoja == oGetDad0:aCols[nI, 6] + oGetDad0:aCols[nI, 7])
		cNumDoc := Iif(!Empty(oGetDad0:aCols[nI, 9]), AllTrim(oGetDad0:aCols[nI, 9]) + "/" + AllTrim(oGetDad0:aCols[nI, 10]), AllTrim(oGetDad0:aCols[nI, 10]))
		
		If (Empty(cFJRVATAmt))
			nSumm += oGetDad0:aCols[nI, 18]
		Else
			nSumm := cFJRVATAmt
		Endif
		
		cNumDocDt += Iif(Empty(cNumDocDt), "", ", ") + cNumDoc + " " + AllTrim(STR0434) + " " + StrTran(DToC(oGetDad0:aCols[nI, 12]), "/", ".")
		
		If (Empty(cNumberCon))
			cNumberCon += AllTrim(oGetDad0:aCols[nI, 19])
			cPrevContr := AllTrim(oGetDad0:aCols[nI, 19])
		Else
			If (cPrevContr != AllTrim(oGetDad0:aCols[nI, 19]))
				cNumberCon += ", " + AllTrim(oGetDad0:aCols[nI, 19])
			Endif
		Endif		
		If (Empty(cFJRVATCod))
			cRate := AllTrim(Str(oGetDad0:aCols[nI, 17])) + " %"
		Else
			GetVatC850(cFJRVATCod) 
			cRate := cFJRVATRat
		Endif
	Endif
Next nI
	If (AllTrim(cFJRVATCod) == "0006" .or. Alltrim(cFJRVATCod) == '')
		cPart3 := ''
	Else
		cPart3 := AllTrim(STR0437) + " " + AllTrim(cRate) + " - " + AllTrim(Str(nSumm, 15, 2))
	Endif
//Only for empty Reason created by Documents. Created by Pre Order fild from PreOrder Reason.
If (Empty(cFJRReason))
	cPart1 := AllTrim(STR0435) + " " + cNumberCon + " " + AllTrim(STR0436) + " " + cNumDocDt + CRLF	
	If (Empty(cFilReason))
		cPart2 := ""
	Else
		cPart2 := AllTrim(cFilReason) + CRLF
		cPart1 := ""
	Endif	
	If ((Len(cPart1) + Len(cPart2) > 209) .And. (Len(cPart1) > Len(cPart3)))
		cPart1 := AllTrim(SubStr(cPart1, 1, (207 - Len(cPart3))))
		Help(" ", 1, "F855LENREASON") // "The size of field must be less than 210 symbols"
	Endif	
Else 
	nVATup := at(STR0437,cFJRReason)
	If nVATup > 0
	cPart1 := SubStr(cFJRReason,1,nVATup-1)
	Else
	cPart1 := cFJRReason
	EndIf
	cPart2 := ''
Endif
cFJRReason := cPart1 + cPart2 + cPart3
cFJRVATAmt := nSumm
cFJRVATRat := cRate

Return(lRet)
/*/{Protheus.doc} RUSgetBK850
(Function for Payment Order to take value from combobox)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function RUSgetBK850(cBnkCode,cBIK,nCount)
Local aAreaFIL := FIL->(getArea())
Local aAreaF45 := F45->(getArea())
Local aAreaSA2 := SA2->(getArea())		
Local cFornece 
Local cLoja   
Default aPagos := {}
Default nCount := oLbx:nAt

If !Empty(aPagos)
	cFornece := aPagos[nCount][2]
	cLoja    := aPagos[nCount][3]
Else 
	cFornece := FJR->FJR_FORNEC
	cLoja    := FJR->FJR_LOJA	
EndIf

SA2->(DbSetOrder(1))
If SA2->(MsSeek(xFilial('SA2')+cFornece+cLoja))
	If Empty(cFJRRecKPP) 
		cFJRRecKPP := SA2->A2_KPP
	EndIf 
EndIf

cFilReason := ''
FIL->(dbSetOrder(1))
If FIL->(MsSeek(xFilial('FIL') + cFornece + cLoja ))
    While FIL->(FIL_FORNEC+FIL_LOJA ) == cFornece+cLoja
       
        If cFJRBnkCod <> FIL->FIL_BANCO 
        	FIL->(dbSkip())
        	Loop
        Else
			cFJRBkName := FIL->FIL_BKNAME
			cFJRBIKCod := FIL->FIL_AGENCI
            cFJRConta  := FIL->FIL_CONTA
            If Empty(cFJRRcName)
            	cFJRRcName := FIL->FIL_NMECOR
            	If empty(FIL->FIL_NMECOR)
            	    cFJRRcName := SA2->A2_NOME
            	EndIf
            EndIf
            If !Empty(FIL->FIL_REASON)       
            	cFilReason := FIL->FIL_REASON
            Else 
            	cFilReason := ''
            EndIf
			Exit	
		Endif
		FIL->(dbSkip())
	EndDo
	
EndIf


F45->(dbSetOrder(1))
If F45->(MsSeek(xFilial('F45') + cFJRBIKCod))
	cFJRCORACC := F45->F45_CORRAC
EndIf

RestArea(aAreaF45)
RestArea(aAreaFIL)
RestArea(aAreaSA2)

Return .T.
/*/{Protheus.doc} GetVatC850
(Function for Payment Order to get VATRat by VATCode)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function GetVatC850(cFJRVATCod as char)
Local aAreaF30 := F30->(getArea())

F30->(dbSetOrder(1))
If F30->(MsSeek(xFilial('F30')+cFJRVATCod))
	cFJRVATRat := F30->F30_DESC
EndIf

RestArea(aAreaF30)
 
Return
/*/{Protheus.doc} a850ArrRus
(Function for Payment Order )
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function a850ArrRus()       
Local nCount :=0
Local cFornece 
Local cLoja  
Local nPagos

Default  aPagos := {}           

If !Empty(aPagos)
		nPagos	 := Len(aPagos)

Else 
		nPagos	 := 1
EndIf 

aDet850RUS := {}

For nCount := 1 to nPagos

	cFJRBnkCod 	:=	CriaVar("FJR_BNKCOD")	//'Bank Code'1              
	cFJRBIKCod 	:=	CriaVar("FJR_BIKCOD")	//'BIK Code'2               
	cFJRConta  	:=	CriaVar("FJR_CONTA"	) 	//'Bank Account'            
	cFJRBkName 	:=	CriaVar("FJR_BKNAME")	//'Bank Name'4              
	cFJRExtNmb 	:=	CriaVar("FJR_EXTNMB")	//'External Number'5        
	cFJRPriori 	:=	CriaVar("FJR_PRIORI")	//'Priority of Payment'     
	cFJRReason 	:=	""						//'Reason for Payment'      
	cFJRCORACC 	:=	CriaVar("FJR_CORACC")	//'Corresponding Account'3  
	cFJRRcName 	:=	CriaVar("FJR_RCNAME")	//"Receiver' s Name"        
	cFJRKPPPay 	:=	CriaVar("FJR_KPPPAY")	//'Payer’s KPP'             
	cFJRRecKPP 	:=	CriaVar("FJR_RECKPP")	//"Receiver’s KPP"          
	cFJRVATCod 	:=	CriaVar("FJR_VATCOD")	//"VAT Code"                
	cFJRVATRat 	:=	CriaVar("FJR_VATRAT")	//'VAT Rate'                
	cFJRVATAmt 	:=	CriaVar("FJR_VATAMT")	//'VAT Amount'              
	๑CHFDIR_FJR	:=	CriaVar("FJR_CHFDIR")	//Chief Director       
	๑CHFACC_FJR	:=	CriaVar("FJR_CHFACC")	//Chief Accountant     
	๑CSHR_FJR	:=	CriaVar("FJR_CSHR"	)	//Cashier              
	๑CSHNMB_FJR	:=	CriaVar("FJR_CSHNMB")	//Cash Book Number     
	๑ATTACH_FJR	:=	CriaVar("FJR_ATTACH")	//Attachment           
	๑PSSPRT_FJR	:=	CriaVar("FJR_PSSPRT")	//Passport Data  
	cFJRPriori := ''

	If !Empty(aPagos)
		cFornece := aPagos[nCount][2]
		cLoja    := aPagos[nCount][3]
	Else
		cFornece := ''
		cLoja    := ''
	EndIf
	If select("FJKTMP") > 0
		findFJK(nCount)
	Else
		iif(Empty(SE2->E2_FORBCO),cFJRBnkCod := '001',cFJRBnkCod := SE2->E2_FORBCO)
		RUSgetBK850(,,nCount)
	EndIf
	AAdd(aDet850RUS,{cFJRBnkCod,cFJRBIKCod,cFJRConta,cFJRBkName,cFJRExtNmb,cFJRPriori;
		,cFJRReason ,cFJRCORACC ,cFJRRcName,cFJRKPPPay,cFJRRecKPP,cFJRVATCod,cFJRVATRat,;
		cFJRVATAmt,๑CHFDIR_FJR,๑CHFACC_FJR,๑CSHR_FJR,๑CSHNMB_FJR,๑ATTACH_FJR,๑PSSPRT_FJR ,cFornece,cLoja})
	a850getVar(nCount,)
Next nCount                                                                                                                                                                                               
Return 
/*/{Protheus.doc} findFJK
(Function for Payment Order )
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
function findFJK(nPagos)
Local aAreaFJK := FJK->(getArea())
Local Result := ''
Local Number := ''
	FJKTMP->(DbGoTop())
	While FJKTMP->(!Eof())
		If  FJKTMP->(FJK_FORNEC+FJK_LOJA)<> (aPagos[nPagos][2]+aPagos[nPagos][3])
			FJKTMP->(DbSkip())
			Loop
		EndIf
		If Empty(FJKTMP->FJK_OK)
			FJKTMP->(DbSkip())
			Loop
		EndIf
		Number := FJKTMP->FJK_PREOP
		If !Empty(Number)
			FJKTMP->(DbSkip())
		EndIf
	EndDo

FJK->(dbSetOrder(1))
If FJK->(MsSeek(xFilial('FJK')+(aPagos[nPagos][2]+aPagos[nPagos][3])+Number))
	cFJRBnkCod := FJK->FJK_BNKCOD
	cFJRReason := FJK->FJK_REASON
	cFJRVATCod := FJK->FJK_VATCOD
	cFJRVATRat := FJK->FJK_VATRAT
	cFJRVATAmt := FJK->FJK_VATAMT
	cFJRBIKCod := FJK->FJK_BIKCOD
	cFJRConta  := FJK->FJK_CONTA
	cFJRBkName := FJK->FJK_BKNAME
	cFJRPriori := FJK->FJK_PRIORI
	cFJRRecKPP := FJK->FJK_RECKPP
	cFJRKPPPay := FJK->FJK_KPPPAY
	cFJRRcName := FJK->FJK_RCNAME
	
EndIf
RestArea(aAreaFJK)
Return

/*/{Protheus.doc} a850setVar
(Function for Payment Order )
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function a850setVar()                                                                 
Local nLine := oLbx:nAt                                
                                                                                     
nPos := aScan(aDet850RUS, {|x| x[_PorFornece] == aPagos[oLBx:nAT][2] .and. x[_PorLoja] == aPagos[oLBx:nAT][3] /*.and. x[_PorPreop] == cPreop*/})
                                                    
aDet850RUS[nPos][_FJRBnkCod]   :=  cFJRBnkCod                                                 
aDet850RUS[nPos][_FJRBIKCod]   :=  cFJRBIKCod                                                 
aDet850RUS[nPos][_FJRConta ]   :=  cFJRConta                                                  
aDet850RUS[nPos][_FJRBkName]   :=  cFJRBkName                                                 
aDet850RUS[nPos][_FJRExtNmb]   :=  cFJRExtNmb                                                 
aDet850RUS[nPos][_FJRPriori]   :=  cFJRPriori                                                 
aDet850RUS[nPos][_FJRReason]   :=  cFJRReason                                                 
aDet850RUS[nPos][_FJRCORACC]   :=  cFJRCORACC                                                 
aDet850RUS[nPos][_FJRRcName]   :=  cFJRRcName                                                 
aDet850RUS[nPos][_FJRKPPPay]   :=  cFJRKPPPay                                                 
aDet850RUS[nPos][_FJRRecKPP]   :=  cFJRRecKPP                                                 
aDet850RUS[nPos][_FJRVATCod]   :=  cFJRVATCod  
aDet850RUS[nPos][_FJRVATRat]   :=  cFJRVATRat                                                 
aDet850RUS[nPos][_FJRVATAmt]   :=  cFJRVATAmt                                                 
aDet850RUS[nPos][_CHFDIR_FJR]  :=  ๑CHFDIR_FJR  
aDet850RUS[nPos][_CHFACC_FJR]  :=  ๑CHFACC_FJR                                               
aDet850RUS[nPos][_CSHR_FJR	]  :=  ๑CSHR_FJR	                                                
aDet850RUS[nPos][_CSHNMB_FJR]  :=  ๑CSHNMB_FJR  
aDet850RUS[nPos][_ATTACH_FJR]  :=  ๑ATTACH_FJR  
aDet850RUS[nPos][_PSSPRT_FJR]  :=  ๑PSSPRT_FJR  
aDet850RUS[nPos][_PorFornece]  :=  aPagos[nLine][2] 
aDet850RUS[nPos][_PorLoja	]  :=  aPagos[nLine][3]
                          
Return   

/*/{Protheus.doc} a850getVar
(Function for PaylChangeOrder )

@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function a850getVar(nLine,lChange)
Local nPos :=0
Local nCount
If lChange
	nCount := oLBx:nAT
	nPos := aScan(aDet850RUS, {|x| x[_PorFornece] == aPagos[nCount][2],x[_PorLoja] == aPagos[nCount][3]})
	If nPos > 0		          
		iif( Empty(aDet850RUS[nCount][_FJRBnkCod] ),  cFJRBnkCod 	:=	CriaVar("FJR_BNKCOD"),cFJRBnkCod  := aDet850RUS[nCount][_FJRBnkCod] )
		iif( Empty(aDet850RUS[nCount][_FJRBIKCod] ),  cFJRBIKCod 	:=	CriaVar("FJR_BIKCOD"),cFJRBIKCod  := aDet850RUS[nCount][_FJRBIKCod] )
		iif( Empty(aDet850RUS[nCount][_FJRConta]  ),  cFJRConta  	:=	CriaVar("FJR_CONTA"	),cFJRConta   := aDet850RUS[nCount][_FJRConta]  )
		iif( Empty(aDet850RUS[nCount][_FJRBkName] ),  cFJRBkName 	:=	CriaVar("FJR_BKNAME"),cFJRBkName  := aDet850RUS[nCount][_FJRBkName] )
		iif( Empty(aDet850RUS[nCount][_FJRExtNmb] ),  cFJRExtNmb 	:=	CriaVar("FJR_EXTNMB"),cFJRExtNmb  := aDet850RUS[nCount][_FJRExtNmb] )
		iif( Empty(aDet850RUS[nCount][_FJRPriori] ),  cFJRPriori 	:=	CriaVar("FJR_PRIORI"),cFJRPriori  := aDet850RUS[nCount][_FJRPriori] )
		iif( Empty(aDet850RUS[nCount][_FJRReason] ),  cFJRReason 	:=	""					 ,cFJRReason  := aDet850RUS[nCount][_FJRReason] )
		iif( Empty(aDet850RUS[nCount][_FJRCORACC] ),  										 ,cFJRCORACC  := aDet850RUS[nCount][_FJRCORACC] )
		iif( Empty(aDet850RUS[nCount][_FJRRcName] ),  cFJRRcName 	:=	CriaVar("FJR_RCNAME"),cFJRRcName  := aDet850RUS[nCount][_FJRRcName] )
		iif( Empty(aDet850RUS[nCount][_FJRKPPPay] ),  cFJRKPPPay 	:=	CriaVar("FJR_KPPPAY"),cFJRKPPPay  := aDet850RUS[nCount][_FJRKPPPay] )
		iif( Empty(aDet850RUS[nCount][_FJRRecKPP] ),  cFJRRecKPP 	:=	CriaVar("FJR_RECKPP"),cFJRRecKPP  := aDet850RUS[nCount][_FJRRecKPP] )
		iif( Empty(aDet850RUS[nCount][_FJRVATCod] ),  cFJRVATCod 	:=	CriaVar("FJR_VATCOD"),cFJRVATCod  := aDet850RUS[nCount][_FJRVATCod] )
		iif( Empty(aDet850RUS[nCount][_FJRVATRat] ),  cFJRVATRat 	:=	CriaVar("FJR_VATRAT"),cFJRVATRat  := aDet850RUS[nCount][_FJRVATRat] )
		iif( Empty(aDet850RUS[nCount][_FJRVATAmt] ),  cFJRVATAmt 	:=	CriaVar("FJR_VATAMT"),cFJRVATAmt  := aDet850RUS[nCount][_FJRVATAmt] )
		iif( Empty(aDet850RUS[nCount][_CHFDIR_FJR]),  ๑CHFDIR_FJR	:=	CriaVar("FJR_CHFDIR"),๑CHFDIR_FJR := aDet850RUS[nCount][_CHFDIR_FJR])
		iif( Empty(aDet850RUS[nCount][_CHFACC_FJR]),  ๑CHFACC_FJR	:=	CriaVar("FJR_CHFACC"),๑CHFACC_FJR := aDet850RUS[nCount][_CHFACC_FJR])
		iif( Empty(aDet850RUS[nCount][_CSHR_FJR]  ),  ๑CSHR_FJR		:=	CriaVar("FJR_CSHR"	),๑CSHR_FJR	  := aDet850RUS[nCount][_CSHR_FJR]  )
		iif( Empty(aDet850RUS[nCount][_CSHNMB_FJR]),  ๑CSHNMB_FJR	:=	CriaVar("FJR_CSHNMB"),๑CSHNMB_FJR := aDet850RUS[nCount][_CSHNMB_FJR])
		iif( Empty(aDet850RUS[nCount][_ATTACH_FJR]),  ๑ATTACH_FJR	:=	CriaVar("FJR_ATTACH"),๑ATTACH_FJR := aDet850RUS[nCount][_ATTACH_FJR])
		iif( Empty(aDet850RUS[nCount][_PSSPRT_FJR]),  ๑PSSPRT_FJR	:=	CriaVar("FJR_PSSPRT"),๑PSSPRT_FJR := aDet850RUS[nCount][_PSSPRT_FJR])

	Endif
	FillRsn850()
Else
	If  Empty(aDet850RUS)
		a850ArrRus()
	EndIf
	nCount := 1
		iif( Empty(aDet850RUS[nCount][_FJRBnkCod] ),  cFJRBnkCod 	:=	FJR->FJR_BNKCOD ,cFJRBnkCod  := aDet850RUS[nCount][_FJRBnkCod] )
		iif( Empty(aDet850RUS[nCount][_FJRBIKCod] ),  cFJRBIKCod 	:=	FJR->FJR_BIKCOD ,cFJRBIKCod  := aDet850RUS[nCount][_FJRBIKCod] )
		iif( Empty(aDet850RUS[nCount][_FJRConta]  ),  cFJRConta  	:=	FJR->FJR_CONTA	,cFJRConta   := aDet850RUS[nCount][_FJRConta]  )
		iif( Empty(aDet850RUS[nCount][_FJRBkName] ),  cFJRBkName 	:=	FJR->FJR_BKNAME ,cFJRBkName  := aDet850RUS[nCount][_FJRBkName] )
		iif( Empty(aDet850RUS[nCount][_FJRExtNmb] ),  cFJRExtNmb 	:=	FJR->FJR_EXTNMB ,cFJRExtNmb  := aDet850RUS[nCount][_FJRExtNmb] )
		iif( Empty(aDet850RUS[nCount][_FJRPriori] ),  cFJRPriori 	:=	FJR->FJR_PRIORI ,cFJRPriori  := aDet850RUS[nCount][_FJRPriori] )
		iif( Empty(aDet850RUS[nCount][_FJRReason] ),  cFJRReason 	:=	FJR->FJR_REASON	,cFJRReason  := aDet850RUS[nCount][_FJRReason] )
		iif( Empty(aDet850RUS[nCount][_FJRCORACC] ),  									,cFJRCORACC  := aDet850RUS[nCount][_FJRCORACC] )
		iif( Empty(aDet850RUS[nCount][_FJRRcName] ),  cFJRRcName 	:=	FJR->FJR_RCNAME ,cFJRRcName  := aDet850RUS[nCount][_FJRRcName] )
		iif( Empty(aDet850RUS[nCount][_FJRKPPPay] ),  cFJRKPPPay 	:=	FJR->FJR_KPPPAY ,cFJRKPPPay  := aDet850RUS[nCount][_FJRKPPPay] )
		iif( Empty(aDet850RUS[nCount][_FJRRecKPP] ),  cFJRRecKPP 	:=	FJR->FJR_RECKPP ,cFJRRecKPP  := aDet850RUS[nCount][_FJRRecKPP] )
		iif( Empty(aDet850RUS[nCount][_FJRVATCod] ),  cFJRVATCod 	:=	FJR->FJR_VATCOD ,cFJRVATCod  := aDet850RUS[nCount][_FJRVATCod] )
		iif( Empty(aDet850RUS[nCount][_FJRVATRat] ),  cFJRVATRat 	:=	FJR->FJR_VATRAT ,cFJRVATRat  := aDet850RUS[nCount][_FJRVATRat] )
		iif( Empty(aDet850RUS[nCount][_FJRVATAmt] ),  cFJRVATAmt 	:=	FJR->FJR_VATAMT ,cFJRVATAmt  := aDet850RUS[nCount][_FJRVATAmt] )
		iif( Empty(aDet850RUS[nCount][_CHFDIR_FJR]),  ๑CHFDIR_FJR	:=	FJR->FJR_CHFDIR ,๑CHFDIR_FJR := aDet850RUS[nCount][_CHFDIR_FJR])
		iif( Empty(aDet850RUS[nCount][_CHFACC_FJR]),  ๑CHFACC_FJR	:=	FJR->FJR_CHFACC ,๑CHFACC_FJR := aDet850RUS[nCount][_CHFACC_FJR])
		iif( Empty(aDet850RUS[nCount][_CSHR_FJR]  ),  ๑CSHR_FJR		:=	FJR->FJR_CSHR	,๑CSHR_FJR	 := aDet850RUS[nCount][_CSHR_FJR]  )
		iif( Empty(aDet850RUS[nCount][_CSHNMB_FJR]),  ๑CSHNMB_FJR	:=	FJR->FJR_CSHNMB ,๑CSHNMB_FJR := aDet850RUS[nCount][_CSHNMB_FJR])
		iif( Empty(aDet850RUS[nCount][_ATTACH_FJR]),  ๑ATTACH_FJR	:=	FJR->FJR_ATTACH ,๑ATTACH_FJR := aDet850RUS[nCount][_ATTACH_FJR])
		iif( Empty(aDet850RUS[nCount][_PSSPRT_FJR]),  ๑PSSPRT_FJR	:=	FJR->FJR_PSSPRT ,๑PSSPRT_FJR := aDet850RUS[nCount][_PSSPRT_FJR])
EndIf
RUSgetBK850(cFJRBnkCod,cFJRBIKCod)
Return

Static Function F850Mins(aMins, nPosRet, aSLIMIN, nPosMin, lLimpia)
Local nN 		:= 0
Local nM 		:= 0
Local nTotal	:= 0 

	For nN := 1 To Len(aMins[1])
 		If Len(aMins[1,nN,nPosRet]) > 0
 			For nM := 1 To Len(aMins[1,nN,nPosRet])
 				If aSLIMIN[nPosMin][2] == aMins[1,nN,nPosRet][nM][10]
 					If !lLimpia
 						nTotal += aMins[1,nN,nPosRet][nM][3]
 					Else
	 					aMins[1,nN,nPosRet][nM][3] := 0
	 					aMins[1,nN,nPosRet][nM][4] := 0
	 					aMins[1,nN,nPosRet][nM][5] := 0
	 					aMins[1,nN,nPosRet][nM][6] := 0
	 					aMins[1,nN,nPosRet][nM][8] := {}
	 				EndIf
 				EndIf
 			Next(nM)
 		EndIf
 	Next(nN)
 	
Return nTotal

Static Function F850VerifG(lMsFil, cMsFil, cNum, cPrefix, cClifor, cLoja, cTipo)
Local lRet   	:= .F.
Local cSF		:= Iif(cTipo $ "NCP","SF2","SF1" )
Local nRecSF	:= 0
Local aAreaSF	:= {}
Local cTipGr	:= 0
Local aAreaSE2	:= SE2->(GetArea())


	aAreaSF	:= &(cSF)->(GetArea())
	dbSelectArea(cSF)
	dbSetOrder(1)
	If lMsFil
		nRecSF := FINBuscaNF(cMsFil,cNum,cPrefix,cClifor,cLoja,cSF,.T.)
		&(cSF)->(dbGoTo(nRecSF))
	Else
		nRecSF := FINBuscaNF(,cNum,cPrefix,cClifor,cLoja,cSF,.T.)
		&(cSF)->(dbGoTo(nRecSF))
	EndIf
	
	cTipGr := &(cSF + "->"+Substr(cSF,2)+"_LIQGR")
	
	If	cTipGr == "2"
		lRet := .T.
	EndIf

	SE2->(RestArea(aAreaSE2))
	 &(cSF)->(RestArea(aAreaSF))
	 
Return lRet

/*/{Protheus.doc} F850PCuit
Obtiene los c๓digos de proveedor asociados a un mismo CUIT

@param cFornece: C๓digo de proveedor seleccionado
@param cLoja: C๓digo de loja del proveedor seleccionado
@param aProvCuit: Array con Cuits para orden de pago

@author Luis Arturo Samaniego Guzman
@since  01/06/2021
@return	Nil
/*/
Static Function F850PCuit(cFornece, cLoja, aProvCuit)
Local aAreaProv := SA2->(GetArea())
Local nPosCuit  := 0
Local cCuitProv := ""

Default aProvCuit := {}

	dbSelectAreA("SA2")
	SA2->(dbSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
	If SA2->(MsSeek(xFilial("SA2") + cFornece + cLoja))
		cCuitProv := SA2->A2_CGC
		If Len(aProvCuit) > 0
			nPosCuit := aScan(aProvCuit,{ |cuit| cuit[1] == cCuitProv })
		EndIf
	EndIf
	If !Empty(cCuitProv) .And. nPosCuit == 0
		dbSelectAreA("SA2")
		SA2->(dbSetOrder(3)) //A2_FILIAL + A2_CGC
		SA2->(dbGoTop())
		If SA2->(MsSeek(xFilial("SA2") + cCuitProv))
			While !(SA2->(Eof())) .And. (SA2->A2_FILIAL == xFilial("SA2") .And. SA2->A2_CGC == cCuitProv)
				If nPosCuit > 0
					aAdd(aProvCuit[nPosCuit][2],{SA2->A2_COD, SA2->A2_LOJA})
				Else
					aAdd(aProvCuit, { SA2->A2_CGC, {{SA2->A2_COD, SA2->A2_LOJA}} })
					nPosCuit := Len(aProvCuit)
				EndIf
				SA2->(dbSkip())
			End
		Endif
	Else
		If Empty(cCuitProv) 
			aProvCuit := {}
			aAdd(aProvCuit, { SA2->A2_CGC, {{SA2->A2_COD, SA2->A2_LOJA}} })
		EndIf
	EndIf

	SA2->(RestArea(aAreaProv))
Return

/*/{Protheus.doc} LibMetF850
valida fecha de la LIB para ser utilizada en Telemetria
@type       Function
@author     adrian.perez
@since      2021
@version    12.1.27
@return     _lMetric, l๓gico, si la LIB puede ser utilizada para Telemetria
/*/
Static Function LibMetF850()

If _lMetric == Nil 
	_lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
EndIf

Return _lMetric

/*/{Protheus.doc} METRET850
	@type  Static Function
	@author adrian.perez
	@since 06/10/2021
	@param   cTipoRet,caracter, tipo de retencion generada
	@return nil
/*/
Static Function METRET850(cTipoRet)

	If LibMetF850() 
		cIdMetric   := "financeiro-protheus_quantida-de-retencoes-ordpago_total"
		cSubRutina  := "fina850-retenciones-"+cTipoRet
		If lAutomato
			cSubRutina  += "-auto"
		EndIf
		FwCustomMetrics():setSumMetric(cSubRutina,cIdMetric,1, /*dDateSend*/, /*nLapTime*/, "FINA850")
	EndIf
	
Return NIL
/*/{Protheus.doc} PE850Leg
	(Descripci๓n de leyendas)
	@type  Static Function
	@author Eli Salatiel 
	@since 12/07/2022
	@return null
/*/
Function PE850Leg()
	Local aLeg := {}
	aLeg := Execblock("F850ADLE",.F.,.F.)
	BrwLegenda(cCadastro, STR0334 ,aLeg)//"Estatus de las ordenes de pago"
Return
