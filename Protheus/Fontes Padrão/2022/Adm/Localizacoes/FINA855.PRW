#Include "Fina855.ch"
#Include "Protheus.ch"
#Include "RwMake.ch"
#Include 'FWMVCDef.ch'

#Define _FORNECE  	 1
#Define _LOJA     	 2
#Define _VALOR		 3
#Define _MOEDA		 4
#Define _TIPO    		12
#Define _RETIVA		14
#Define _RETIB		15
#Define _PAGAR   		21
#Define _RETIRIC	23
#Define _RETIR		26
#Define _RETSUSS	24
#Define _RETSLI		25
#Define _RETISI		28
#Define _RETIRC		27
#Define _RETRIE  	29
#Define _RETIGV 	30
#DEFINE _ELEMEN     32 //indica o tamanho para o array ase2

/* Russian Variables */
#Define _BnkCode	 1
#Define _BikCod		 2
#Define _BkName		 3
#Define _DtPlan		 4
#Define _Tppgto		 5
#Define _CorAcc		 6
#Define _Conta		 7
#Define _RcName		 8
#Define _KPPPay		 9
#Define _RecKPP		 10
#Define _Priori		 11
#Define _Reason		 12
#Define _VATRat		 13
#Define _VATAmt		 14
#Define _VATCod 	 15
#Define _PosFornece	 16
#Define _PosLoja	 17
/* Russian Variables */

Static lMod2 := .T.
Static lFWCodFil := .T.
//For Russia
Static aDetailRUS := {}
Static cFilReason := ''
Static aRIvAcm    := Array(3)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FINA855  ณ Autor ณ Marcos Antunes Berto   ณ Data ณ 01.10.11 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri็เo ณ Nova Pr้ Ordem de Pago, conforme requisitos do Roadmap11.5. ณฑฑ
ฑฑณ          ณ Solicitante Filial Argentina.                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador  ณ Data   ณ BOPS     ณ  Motivo da Alteracao                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glezณ06/12/16ณSERINN001-ณSe modifica uso de tablas temporales  ณฑฑ
ฑฑณ             ณ        ณ      122 ณpor motivo de limpieza de CTREE.      ณฑฑ
ฑฑณM.Camargo    ณ13.02.17|MMI-   ณARG Se valida la existencia de una soliciณฑฑ
ฑฑณ             ณ        |4154   ณtud de nota de credito al incluir una    ณฑฑ
ฑฑณ             ณ        |       ณpreorden de Pago mediante el uso del helpณฑฑ
ฑฑณ             ณ        |       ณSOLNCPAB.Esta validaci๓n se agrega dentroณฑฑ
ฑฑณ             ณ        |       ณde la funci๓n A855STit.                  ณฑฑ
ฑฑณLaura Medina ณ15/02/17ณMMI-121 ณSe realiza la replica del llamado TUCD44ณฑฑ
ฑฑณ             ณ        ณ        ณpara considerar en la generacion de la  ณฑฑ
ฑฑณ             ณ        ณ        ณOP el pago a trav้s de CBU.             ณฑฑ
ฑฑณ             ณ        ณ        ณ                                        ณฑฑ
ฑฑณLaura Medina ณ07/03/17ณMMI-4172ณSe agregaron las validaciones para que  ณฑฑ
ฑฑณ             ณ        ณ        ณno permita grabar una pre-orden si esta ณฑฑ
ฑฑณ             ณ        ณ        ณya fue generada en otra sesi๓n.         ณฑฑ
ฑฑณ             ณ        ณ        ณSe incluye solucion del issue MMI-4178  ณฑฑ
ฑฑณ             ณ        ณ        ณ(Error colateral del MMI-4172)          ณฑฑ
ฑฑณRaul Ortiz M ณ13/03/17|MMI-4179ณSe modifica el Orden de lectura de      ณฑฑ
ฑฑณ             ณ        |        ณRetenciones pues no consideraba bien    ณฑฑ
ฑฑณRaul Ortiz M.ณ29/03/17ณMMI-4838ณPago total de IVA en pagos Parciales    ณฑฑ
ฑฑณRaul Ortiz M.ณ30/03/17|MMI-4938ณSe consideran las retenciones generadas ณฑฑ
ฑฑณ             ณ        ณ        ณpor las ordenes de Pago Previas         ณฑฑ
ฑฑณLuis Enriquezณ07/06/17ณTSSERMI01ณ-Merge Main 12.1.16 En m้todo AddIndex ณฑฑ
ฑฑณ             ณ        ณ-96      ณde clase FWTemporaryTable se modifica aณฑฑ
ฑฑณ             ณ        ณ         ณ2 caracteres nombre de indice. (CTREE) ณฑฑ
ฑฑณRoberto Glez.ณ16/06/17ณMMI-5973ณSe agrega a consulta filtros para la    ณฑฑ
ฑฑณ             ณ        ณ        ณfilial y el proveedor al obtener los    ณฑฑ
ฑฑณ             ณ        ณ        ณdatos del registro a visualizar.        ณฑฑ
ฑฑณLaura Medina ณ09/06/17ณMMI-5922ณSe creo los puntos de Entrada:          ณฑฑ
ฑฑณ             ณ        ณ        ณ* FA855Apr - Aprobacion de preOrden Pagoณฑฑ
ฑฑณ             ณ        ณ        ณ* FA855Can - Cancelacion de Aprobacion  ณฑฑ
ฑฑณ             ณ        ณ        ณ             de preOrden Pago           ณฑฑ
ฑฑณRaul Ortiz M ณ08/05/17ณMMI-5667| Modificaciones para mostrar las Ret.   ณฑฑ
ฑฑณ             ณ        ณ        |en pantalla de las Ordenes de Pago      ณฑฑ
#Victor Lopez#28/09/17#MA3A-773|Bug fix                              #
ฑฑณRaul Ortiz M ณ20/12/17ณDMICNS- ณCambios calculo de retenciones de IB    ณฑฑ
ฑฑณ             ณ        ณ673     ณpara tomar en cuenta limites por orden  ณฑฑ
ฑฑณ             ณ        ณ        ณde pago en pagos totales y parciales.ARGณฑฑ
ฑฑณRaul Ortiz   ณ12/03/18ณDMICNS- ณCambios para ganancias en condominios   ณฑฑ
ฑฑณ             ณ        ณ1060    ณvisualzaci๓n - Argentina                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fina855()
Private lMsfil:= .F.
Private aProvLim  := {}
Private a855Cpos  := {}
Private lFA855Cpos := EXISTBLOCK("FA855CPOS")
Private aRetImp855 := {}

cLayoutEmp 	:= FWSM0Layout()
lGestao		:= Iif( lFWCodFil, ( "E" $ cLayoutEmp .And. "U" $ cLayoutEmp ), .F. )	// Indica se usa Gestao Corporativa
If lFWCodFil .And. lGestao
	cCompSE2 := FwModeAccess("SE2",1) + FwModeAccess("SE2",2) + FwModeAccess("SE2",3)
Else
	cCompSE2 := If(Empty(xFilial("SE2")),"CCC","EEE")
Endif

If cCompSE2 == "CCC"
	If !F850MsFil()
		Return()
	Endif
Endif
//Verifica็ใo do processo que esta configurado para ser utilizado no M๓dulo Financeiro (Argentina)
If lMod2
	If !FinModProc()
		Return()
	EndIf
EndIf

//Valida็ใo do dicionแrio de dados para utiliza็ใo da rotina pr้-ordem de pagamento modelo II (Argentina) 
If !( cPaisLoc <> "BRA" )
	Help(" ",1,"F855DCPRE") //"Nใo ้ possํvel utilizar a nova Pr้-Ordem de Pago."|"Atualize o dicionแrio de dados."
	Return
EndIf

Private aRotina := MenuDef()

If lFA855Cpos
	a855Cpos := EXECBLOCK("FA855CPOS",.F.,.F.,)
EndIf

MBrowse(6,1,22,75,"FJK",,,,,,A855Leg())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA855  บAutor  ณ Marylly A. Silva   บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem da tela da pr้-ordem de pagamento                 บฑฑ
ฑฑบ          ณ Dependendo do modo de edi็ใo, jแ atualiza os dados dos     บฑฑ
ฑฑบ          ณ pain้s disponํveis na tela                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855POp(nOpcao)
Local nA 			:= 0
Local aButtons		:= {}
Local nC 			:= MoedFin()
Local cMoedaTx		:= ""
Local bOk			:= {||}
Local cOpcao		:= ""
Local nOpcDados		:= 0
Local aPadPre		:= {}
Local nX			:= 0
Local aDms			:= FWGetDialogSize(oMainWnd)
Local oEnchFor		:= Nil
Local oPanel		:= Nil
Local oPanel1		:= Nil
Local oSubPan1_1	:= Nil
Local oSubPan1_2	:= Nil
Local oPanel_2		:= Nil
Local oFolder		:= Nil
Local oPanel3		:= Nil
Local oSubPan3_1	:= Nil
Local oSubPan3_2	:= Nil
Local aTitles		:= {STR0064,STR0065} // "Pre Ordem" // "Distribuicao Moedas"
Local lContinua		:= .T.
Local lAprova		:= .T.

Private cMarca		:= GetMark()
Private aDados		:= {}
Private aRetTit		:= {}
Private aRet		:= {}
Private lAltera		:= .F.
Private cFilter		:= ""

//Variaveis enchoice - Dados do fornecedor
Private cFornece	:= CriaVar("A2_COD"		,.F.)
Private cLoja		:= CriaVar("A2_LOJA"	,.F.)
Private cRazSocial	:= CriaVar("A2_NOME"	,.F.)
Private cEndosso	:= CriaVar("A2_ENDOSSO"	,.F.)
Private cMoeda		:= If(nOpcao == 1,"01",FJK->FJK_MOEDA)

Private nTitulos	:= 0
Private nTotTit		:= 0
Private nTotRet		:= 0

Private oSay11		:= Nil
Private oSay21		:= Nil
Private oSay31		:= Nil
Private nSigno		:= 1
Private aCols		:= {}

Private oDlg
Private oEnch		:= Nil
Private oGridPreOP	:= Nil
Private oGridTot	:= Nil
Private oBrwTit		:= Nil
Private oBrwRat		:= Nil
Private oGridRet	:= Nil
Private aSE2		:= {}
Private aRecnoSE2	:= {}
Private aTxMoedas	:= {{"",1,PesqPict("SM2","M2_MOEDA1")}}
Private lCalcRet	:= .F.
Private nMoeda		:= 0
Private nDecs		:= 0
Private nCondAgr	:= 1
Private nMoedaCor	:= 1
Private lRetPA		:= .T.
Private nPosRecno	:= cPaisLoc <> "BRA"
Private aColsSavMo	:= {}
Private aSavNumPre	:= {}
Private aOrdem     := {} //JGR
Private oTmpSE2 //JGR
Private oTmpTMP //JGR
Private aTitPreOrd := {}
Private aProvCuit := {}
Private aCCORetNoIns    := {}
Private aSFHNoIns       := {}


Default nOpcao		:= 0

Fa855Temp() //oTmpSE2 //Gera tabela temporaria
F855TmpSel() //oTmpTMP //Cria tabela temporia auxiliar para processo de selecao dos registros

For nA := 2 To nC
	cMoedaTx := Str(nA,IIf(nA <= 9,1,2))
	If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
		Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
	Else
		Exit
	Endif
Next nA

DbSelectArea("SA2")

If nOpcao == 1 //Inclusใo
	//Abre a tela para selecao dos titulos
	lContinua := A855STit(nOpcao)

ElseIf nOpcao == 5 //Aprovacao|Rejeicao Pre-Ordem
	//Abre a tela para selecao dos titulos
	lContinua := FA855SelAp(@lAprova)

ElseIf nOpcao == 6 //Cancelamento Pre-Ordem
	//Abre a tela para selecao dos titulos
	lContinua := FA855SelCa()

Else

	If nOpcao <> 2 //Visualizacao

		Do Case
			Case !Empty(FJK->FJK_DTCANC) //Se estiver reprovada ou cancelada o registro ้ aberto como visualiza็ใo
				nOpcao := 2
				Help(" ",1,"F855PRCANC") //Pre-ordem de pago nใo pode ser manipulada, pois a mesma jแ foi reprovada ou cancelada.|O registro serแ aberto no modo visualiza็ใo.

			Case !Empty(FJK->FJK_ORDPAG) //Se estiver baixada o registro ้ aberto como visualiza็ใo
				nOpcao := 2
				Help(" ",1,"F855PRBAIX") //Pre-ordem de pago nใo pode ser manipulada, pois a mesma jแ foi baixada.|O registro serแ aberto no modo visualiza็ใo.

			Case !Empty(FJK->FJK_DTANLI) .And. nOpcao <> 6 //Se estiver aprovada o registro ้ aberto como visualiza็ใo
				nOpcao := 2
				Help(" ",1,"F855PRAPRV") //Pre-ordem de pago nใo pode ser manipulada, pois a mesma jแ foi aprovada.|O registro serแ aberto no modo visualiza็ใo.

			Case nOpcao == 4 //Alteracao
				lAltera := .T.
		EndCase

	EndIf

	//Recupero os dados da pre-ordem
	A855LeOP()

EndIf

Do Case
	Case nOpcao == 1
		cOpcao := STR0001 //"Inclusใo"
	Case nOpcao == 2
		cOpcao := STR0002 //"Visualiza็ใo"
	Case nOpcao == 3
		cOpcao := STR0003 //"Exclusใo"
	Case nOpcao == 4
		cOpcao := STR0004 //"Altera็ใo"
	Case nOpcao == 5
		cOpcao := If(lAprova,STR0005,STR0086) //"Aprova็ใo"###"Rejeicao"
	Case nOpcao == 6
		cOpcao := STR0006 //"Cancelamento"
EndCase

If lContinua

	oDlg := MSDialog():New(aDms[1],aDms[2],aDms[3],aDms[4],STR0007+" - "+cOpcao,,,,,,,,oMainWnd,.T.) //"Pre-ordem de pagamento"

	//Painel Principal
	oPanel := TPanel():New(000,000,'',oDlg,,.T.,.T.,,,100,100,.T.,.T.)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	//Painel 1
	oPanel1 := TPanel():New(000,000,'',oPanel,,.T.,.T.,,,100,(oPanel:nClientHeight*0.31)/2,.F.,.F.)
	oPanel1:Align := CONTROL_ALIGN_TOP

	//Sub Painel 1 - 1
	oSubPan1_1 := TPanel():New(005,005,'',oPanel1,,.T.,.T.,,,(oPanel1:nClientWidth/4)-7.5,(oPanel1:nClientHeight/2)-10,.F.,.F.)
	FA855GtPOP(@oSubPan1_1,nOpcao)

	//Sub Painel 1 - 2
	oSubPan1_2 := TPanel():New(5,(oPanel1:nClientWidth/4)+2.5,'',oPanel1,,.T.,.T.,,,(oPanel1:nClientWidth/4)-10,(oPanel1:nClientHeight/2)-10,.F.,.F.)
	Fa855EnFor(@oSubPan1_2,nOpcao)

	//Painel 2
	oPanel_2 := TPanel():New(000,000,'',oPanel,,.T.,.T.,,,100,(oPanel:nClientHeight*0.38)/2,.F.,.F.)
	oPanel_2:Align := CONTROL_ALIGN_TOP

	oFolder	:= TFolder():New(000,005,aTitles,,oPanel_2,1,,,.T.,.F.,(oPanel_2:nClientWidth/2)-10,(oPanel_2:nClientHeight/2))

	//Folder 1 - Titulos Pre-OP
	A855BrTit(nOpcao,@oFolder)

	//Folder 2 - Distribuicao Moedas
	FA855GtMoe(nOpcao,@oFolder)

	//Painel 3
	oPanel3 := TPanel():New(000,000,'',oPanel,,.T.,.T.,,,100,100,.F.,.F.)
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT

	//Sub Painel 3 - 1
	oSubPan3_1 := TPanel():New(005,005,'',oPanel3,,.T.,.T.,,,(oPanel3:nClientWidth/4)-7.5,(oPanel3:nClientHeight/2)-35,.F.,.F.)
	Fa855GdRet(@oSubPan3_1)

	//Sub Painel 3 - 2
	oSubPan3_2 := TPanel():New(005,(oPanel3:nClientWidth/4)+2.5,'',oPanel3,,.T.,.T.,,,(oPanel3:nClientWidth/4)-7.5,(oPanel3:nClientHeight/2)-35,.F.,.F.)
	Fa855GtTot(@oSubPan3_2)

	//Botoes
	Do Case
		Case nOpcao == 1 //Inclusao
			If cPaisLoc == "ARG"
				bOk := {|| If(IIf(VldDocPag(),FA855Inclu(),.F.),oDlg:End(),.F.)}
			Else
				bOk := {|| If(FA855Inclu(),oDlg:End(),.F.)}
			EndIf
			aAdd(aButtons,{"NOTE",{|| A855STit(9),FA855Atu("AddTit")},STR0011}) //"Selecionar Titulos"
			If cPaisLoc == 'RUS'
				aAdd(aButtons,{"NOTE",{|| RU06S855(nOpcao) },STR0104}) //Pre-Order Bank
			EndIf
		Case nOpcao == 4 //Alteracao
			bOk := {|| If(FA855Alter(),oDlg:End(),.F.)}
			aAdd(aButtons,{"NOTE",{|| A855STit(9),FA855Atu("AddTit")},STR0011}) //"Selecionar Titulos"
			If cPaisLoc == 'RUS'
				aAdd(aButtons,{"NOTE",{|| RU06S855(nOpcao) },STR0104}) //Pre-Order Bank
			EndIf
		Case nOpcao == 3 //Exclusao
			bOk := {|| A855Excl(),oDlg:End()}
			If cPaisLoc == 'RUS'
				aAdd(aButtons,{"NOTE",{|| RU06S855(nOpcao) },STR0104}) //Pre-Order Bank
			EndIf
		Case nOpcao == 5 //Aprovacao|Rejeicao
			bOk := {||If(lAprova,A855Aprv(),A855Rej()),oDlg:End()}
			If cPaisLoc == 'RUS'
				aAdd(aButtons,{"NOTE",{|| RU06S855(nOpcao) },STR0104}) //Pre-Order Bank
			EndIf
		Case nOpcao == 6 //Cancelamento - Aprova็ใo ou Pre-Ordem
			bOk := {|| A855Canc(),oDlg:End()}
		Case nOpcao == 2 //Visualizacao
			bOk := {|| oDlg:End()}
			If cPaisLoc == 'RUS'
				aAdd(aButtons,{"NOTE",{|| RU06S855(nOpcao) },STR0104}) //Pre-Order Bank
			EndIf
			
		OtherWise
			bOk := {|| oDlg:End()}
	EndCase

	//Finalizar/Cancelar
	bCanc := {|| aEval(aSavNumPre,{|x| x[2] := .F.}),oDlg:End()}

	oDlg:bInit := {|| EnchoiceBar(oDlg,bOK,bCanc,.F.,aButtons)}

	oDlg:Activate()

EndIf

For nX := 1 To Len(aSavNumPre)
	If aSavNumPre[nX][2]
		ConfirmSX8()
	Else
		RollBackSX8()
	EndIf
Next nX

aRetImp855 := {}

If oTmpSE2 <> Nil   //JGR
	oTmpSE2:Delete()
	oTmpSE2 := Nil
Endif

If oTmpTMP <> Nil   //JGR
	oTmpTMP:Delete()
	oTmpTMP := Nil
Endif
	
	If cPaisLoc == 'RUS'
		RU06S855CL()
	Endif
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855GtPOPบ Autor ณ Microsiga          บ Data ณ  20/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria a Grid com os dados da Pre-OP's                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855GtPOP(oSubPan1_1,nOpcao)
Local aHeaderPOp	:= {}
Local aColsPOp		:= {}

//               "cTitulo"             ,"cCampo"    ,"cPicture"                  ,"nTamanho"             ,"nDecimais"            ,"cValida็ใo","cReservado","cTipo","xReservado1","xReservado2"
Aadd(aHeaderPOp,{RetTitle("FJK_FORNEC"),"FORNECEDOR",PesqPict("FJK","FJK_FORNEC"),TamSX3("FJK_FORNEC")[1],TamSX3("FJK_FORNEC")[2],""          ,"๛"         ,"C"    ,""           ,""           ,"", "", ".T."}) //Fornecedor
Aadd(aHeaderPOp,{RetTitle("FJK_LOJA")  ,"LOJA"      ,PesqPict("FJK","FJK_LOJA")  ,TamSX3("FJK_LOJA")[1]  ,TamSX3("FJK_LOJA")[2]  ,""          ,"๛"         ,"C"    ,""           ,""           ,"", "", ".T."}) //Loja
Aadd(aHeaderPOp,{RetTitle("FJK_PREOP") ,"PREOP"     ,PesqPict("FJK","FJK_PREOP") ,TamSX3("FJK_PREOP")[1] ,TamSX3("FJK_PREOP")[2] ,""          ,"๛"         ,"C"    ,""           ,""           ,"", "", ".T."}) //Numero Pre Ordem
Aadd(aHeaderPOp,{STR0081               ,"QTDTIT"    ,""                          ,6                      ,0                      ,""          ,"๛"         ,"N"    ,""           ,""           ,"", "", ".T."}) //"Titulos"
Aadd(aHeaderPOp,{STR0082               ,"VALPREOP"  ,PesqPict("FJK","FJK_VLRPRE"),TamSX3("FJK_VLRPRE")[1],TamSX3("FJK_VLRPRE")[2],""          ,"๛"         ,"N"    ,""           ,""           ,"", "", ".T."}) //Valor

Aadd(aColsPOp,{"","","",0,0,.F.})

//            MsNewGetDados():New(nTop,nLeft,nBottom,nRight,nStyle   ,cLinhaOk     ,cTudoOk      ,cIniCpos,aAlter,nFreeze,nMax,cFieldOk     ,cSuperDel,cDelOk        ,oWnd      ,aHeader   ,aCols   ,uChange,cTela)
oGridPreOP := MsNewGetDados():New(005 ,005  ,090    ,300   ,GD_UPDATE,"AllwaysTrue","AllwaysTrue",""      ,{}    ,000    ,999 ,"AllwaysTrue",""       ,"AllwaysFalse",oSubPan1_1,aHeaderPOp,aColsPOp)
oGridPreOP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGridPreOP:bChange := {|| FA855Atu("GridPreOP")}

FA855AtPOP()

If cPaisLoc == "RUS"
	a855ArrRus(nOpcao)
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa855EnForบ Autor ณ Microsiga          บ Data ณ  19/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria a enchoice com os dados do fornecedor                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa855EnFor(oSubPan1_2,nOpcao)
Local aField	:= {}

//           Titulo ,Campo       ,Tipo,Tamanho                ,Decimal                ,Picture                     ,Valid                                                                                                ,Obrigat,Nivel,Inic Padrใo,F3   ,When,Visual,Chave,Combo,Folder,Nao Alt,PictVar,Gatilho
Aadd(aField,{STR0008,"cFornece"  ,"C" ,TamSX3("A2_COD")[1]    ,TamSX3("A2_COD")[2]    ,PesqPict("SA2","A2_COD")    ,                                                                                                     ,.F.    ,1    ,           ,     ,    ,.T.   ,.F.  ,     ,      ,.F.    ,       ,       }) //"Fornecedor"
Aadd(aField,{STR0009,"cLoja"     ,"C" ,TamSX3("A2_LOJA")[1]   ,TamSX3("A2_LOJA")[2]   ,PesqPict("SA2","A2_LOJA")   ,                                                                                                     ,.F.    ,1    ,           ,     ,    ,.T.   ,.F.  ,     ,      ,.F.    ,       ,       }) //"Loja"
Aadd(aField,{STR0010,"cRazSocial","C" ,TamSX3("A2_NOME")[1]   ,TamSX3("A2_NOME")[2]   ,PesqPict("SA2","A2_NOME")   ,                                                                                                     ,.F.    ,1    ,           ,     ,    ,.T.   ,.F.  ,     ,      ,.F.    ,       ,       }) //"Razใo Social"
Aadd(aField,{STR0062,"cEndosso"  ,"C" ,TamSX3("A2_ENDOSSO")[1],TamSX3("A2_ENDOSSO")[2],PesqPict("SA2","A2_ENDOSSO"),                                                                                                     ,.F.    ,1    ,           ,     ,    ,.T.   ,.F.  ,     ,      ,.F.    ,       ,       }) //"Doc. Terceiros"
Aadd(aField,{STR0063,"cMoeda"    ,"C" ,TamSX3("CTO_MOEDA")[1] ,TamSX3("CTO_MOEDA")[2] ,PesqPict("CTO","CTO_MOEDA") ,{||(ExistCpo("CTO",cMoeda) .And. FinMoedBco(Val(cMoeda)) .And. FA855GrvMo() .And. FA855Atu("Moeda"))},.F.    ,1    ,           ,"CTO",    ,.F.   ,.F.  ,     ,      ,.F.    ,       ,       }) //"Moeda"

oEnch := MsMGet():New(,0,3,,,,,{000,000,090,200},,,,,,oSubPan1_2,,,,,,.T.,aField,,.T.)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA855BrTit บ Autor ณ Marylly A. Silva   บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a tela de sele็ใo de tํtulos que farใo parte da pr้- บฑฑ
ฑฑบ          ณ ordem de pago que estแ sendo manipulada.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A855BrTit(nOpcao,oFolder)
Local aHeaderTit	:= {}
Local aColsTit		:= {}
Local aAlter		:= {}
Local nX			:= {}

Default nOpcao		:= 0

//               X3_TITULO             ,X3_CAMPO    ,X3_PICTURE                  ,X3_TAMANHO             ,X3_DECIMAL             ,X3_VALID                              ,"",X3_TIPO,"",""})
Aadd(aHeaderTit,{RetTitle("E2_TIPO")   ,"E2_TIPO"   ,PesqPict("SE2","E2_TIPO")   ,TamSX3("E2_TIPO")[1]   ,TamSX3("E2_TIPO")[2]   ,""                                    ,"","C"    ,"",""})
Aadd(aHeaderTit,{RetTitle("E2_PREFIXO"),"E2_PREFIXO",PesqPict("SE2","E2_PREFIXO"),TamSX3("E2_PREFIXO")[1],TamSX3("E2_PREFIXO")[2],""                                    ,"","C"    ,"",""})
Aadd(aHeaderTit,{RetTitle("E2_NUM")    ,"E2_NUM"    ,PesqPict("SE2","E2_NUM")    ,TamSX3("E2_NUM")[1]    ,TamSX3("E2_NUM")[2]    ,""                                    ,"","C"    ,"",""})
Aadd(aHeaderTit,{RetTitle("E2_PARCELA"),"E2_PARCELA",PesqPict("SE2","E2_PARCELA"),TamSX3("E2_PARCELA")[1],TamSX3("E2_PARCELA")[2],""                                    ,"","C"    ,"",""})
Aadd(aHeaderTit,{RetTitle("E2_VENCTO") ,"E2_VENCTO" ,PesqPict("SE2","E2_VENCTO") ,TamSX3("E2_VENCTO")[1] ,TamSX3("E2_VENCTO")[2] ,""                                    ,"","D"    ,"",""})
Aadd(aHeaderTit,{RetTitle("E2_SALDO")  ,"E2_SALDO"  ,PesqPict("SE2","E2_SALDO")  ,TamSX3("E2_SALDO")[1]  ,TamSX3("E2_SALDO")[2]  ,""                                    ,"","N"    ,"",""})
Aadd(aHeaderTit,{RetTitle("E2_MOEDA")  ,"MOEDA"     ,"@!"                        ,2                      ,0                      ,""                                    ,"","C"    ,"",""})
Aadd(aHeaderTit,{STR0018+" "+STR0054   ,"VALPRE"    ,PesqPict("SE2","E2_VALOR")  ,TamSX3("E2_VALOR")[1]  ,TamSX3("E2_VALOR")[2]  ,"A855VldVl() .And. FA855Atu('VALPRE')","","N"    ,"",""}) //"Valor para pr้-ordem"###"(na moeda do tํtulo)"
Aadd(aHeaderTit,{STR0068               ,"VALCNV"    ,PesqPict("SE2","E2_VALOR")  ,TamSX3("E2_VALOR")[1]  ,TamSX3("E2_VALOR")[2]  ,""                                    ,"","N"    ,"",""}) //"Valor (Moeda Pr้-Ordem Pago)"
	If cPaisLoc == 'RUS'
		Aadd(aHeaderTit,{STR0119        ,"E2_BASIMP1"    ,PesqPict("SE2","E2_BASIMP1")  ,TamSX3("E2_BASIMP1")[1]  ,TamSX3("E2_BASIMP1")[2]  ,""                                    ,"","N"    ,"",""}) //Tax 1 Base
		Aadd(aHeaderTit,{STR0120        ,"E2_ALQIMP1"    ,PesqPict("SE2","E2_ALQIMP1")  ,TamSX3("E2_ALQIMP1")[1]  ,TamSX3("E2_ALQIMP1")[2]  ,""                                    ,"","N"    ,"",""}) //Tax 1 Rate
		Aadd(aHeaderTit,{STR0121        ,"E2_VALIMP1"    ,PesqPict("SE2","E2_VALIMP1")  ,TamSX3("E2_VALIMP1")[1]  ,TamSX3("E2_VALIMP1")[2]  ,""                                    ,"","N"    ,"",""}) //Tax 1 Amount
		Aadd(aHeaderTit,{STR0122        ,"E2_MDCONTR"    ,PesqPict("SE2","E2_MDCONTR")  ,TamSX3("E2_MDCONTR")[1]  ,TamSX3("E2_MDCONTR")[2]  ,""                                    ,"","C"    ,"",""}) //Contract
	EndIf
If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
	For nX := 1 To Len(a855Cpos)
		Aadd(aHeaderTit,a855Cpos[nX][1])
	Next nX 
Endif
 
If !(cPaisLoc=="ARG" .And. SE2->(ColumnPos("E2_CCR")) > 0  .and. !Empty(MV_PAR10))
	Aadd(aAlter,"VALPRE")
EndIf

If Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
	For nX := 1 To Len(a855Cpos)
		Aadd(aAlter,a855Cpos[nX][1][2])
	Next nX 
EndIf

Aadd(aColsTit,{"","","","",CToD(""),0,"",0,0,0,.F.})

oBrwTit := MsNewGetDados():New(000,000,200,200,If(nOpcao == 1 .Or. nOpcao == 4 ,GD_UPDATE+GD_DELETE,0),"AllwaysTrue","AlwaysTrue","",aAlter,0,999,"AllwaysTrue","","A855VldEx()",oFolder:aDialogs[1],aHeaderTit,aColsTit)
oBrwTit:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	If cPaisLoc == 'RUS' .And. nOpcao == 2
		nPosNum := aScan(aHeaderTit,{|x| x[2] == "E2_NUM"})
		oBrwTit:oBrowse:bLDblClick := {|| If( oBrwTit:oBrowse:ColPos() == nPosNum,  RUF055DbClk(aHeaderTit,oBrwTit:aCols,oBrwTit:oBrowse:nAt), Alert(STR(oBrwTit:oBrowse:ColPos())))}
	EndIF
Return

Function RUF055DbClk(aHead,aArray,nLine)

	Local lRetorno	:= .T.
	Local aAreaSE2 := getArea()
	Local cPayment	:= ''
	Local cPayNum	:= ''
	Local cPrefix	:= ''
	Local cFornec	:= SE2->E2_FORNECE
	Local cParcela	:= ''
	Local cTipo		:= ''
	
	Local nPosPayNum := aScan(aHead,{|x| x[2] == "E2_NUM" })
	Local nPrefix  	:= aScan(aHead,{|x| x[2] == "E2_PREFIXO" })
	Local nParcela 	:= aScan(aHead,{|x| x[2] == "E2_PARCELA" })
	Local nTipo 	:= aScan(aHead,{|x| x[2] == "E2_TIPO" })
	
	
	Private cCadastro := ''
 		cPayNum := aArray[nLine][nPosPayNum]
		cPrefix := aArray[nLine][nPrefix]
		cParcela:= aArray[nLine][nParcela]
		cTipo	:= aArray[nLine][nTipo]
		dbSelectArea('SE2')
		DbSetOrder(1)
		If MsSeek(xFilial('SE2')+cPrefix+cPayNum+cParcela+cTipo+cFornec+cLoja)	
			AxVisual('SE2',SE2->(Recno()),)                                                                              
			lRetorno := .F.
		EndIf
		RestArea(aAreaSE2)

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855GtMoeบ Autor ณ Microsiga          บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta a grid de distribuicao moedas                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Modulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855GtMoe(nOpcao,oFolder)
Local oPanel1		:= Nil
Local oPanel2		:= Nil
Local oSay1		:= Nil
Local oSay2		:= Nil
Local oSay3		:= Nil
Local oArial12		:= TFont():New("Arial",,-12,,.T.)
Local oArial12It	:= TFont():New("Arial",,-12,,.F.,,,,.T.)
Local aHeaderMoe	:= {}
Local aColsMoe		:= {}
Local nI			:= 0
Local nCols			:= 0
Local nX			:= 0
Local cCodPreop		:= GdFieldGet("PREOP",oGridPreOP:nAt,,oGridPreOP:aHeader,oGridPreOP:aCols)

Default nOpcao		:= 0

//------------------------------------------------------
// Campos complementares da grid de distribuicao moedas
//------------------------------------------------------
oPanel1 := TPanel():New(0,0,'',oFolder:aDialogs[2],,.T.,.T.,,,30,30,.F.,.F.)
oPanel1:Align := CONTROL_ALIGN_TOP

oSay1	:= TSay():New(00,01,{|| STR0014+":"	},oPanel1,	,oArial12) // "Valor dos tํtulos"
oSay2	:= TSay():New(01,01,{|| STR0066		},oPanel1,	,oArial12) // "%A Distribuir:"
oSay3	:= TSay():New(01,20,{|| STR0067		},oPanel1,	,oArial12) // "% Distribuido:"

oSay11	:= TSay():New(00,09,{|| 0	},oPanel1,PesqPict("SE2","E2_VALOR"),oArial12It)
oSay21	:= TSay():New(01,07,{|| 100	},oPanel1,PesqPict("FJM","FJM_PERC"),oArial12It)
oSay31	:= TSay():New(01,26,{|| 0	},oPanel1,PesqPict("FJM","FJM_PERC"),oArial12It)

//--------------------------
// Grid Distribuicao Moedas
//--------------------------

DbSelectArea("FJM")
FJM->(DbSetOrder(1))

aHeaderMoe := GetaHeader("FJM")

If nOpcao <> 1 .And. FJM->(MsSeek(XFilial("FJM") + cCodPreop))//Alteracao|Visualizacao|Exclusao
	While FJM->(!Eof()) .And. AllTrim(FJM->(FJM_FILIAL+FJM_PREOP)) == ALLTRIM(XFilial("FJM") + cCodPreop)
		aAdd(aColsMoe,Array(Len(aHeaderMoe)+1))
		nCols ++
		For nI := 1 To Len(aHeaderMoe)
			If (aHeaderMoe[nI][10] != "V")
				aColsMoe[nCols][nI] := FJM->(FieldGet(ColumnPos(aHeaderMoe[nI][2])))
			Else
				aColsMoe[nCols][nI] := CriaVar(aHeaderMoe[nI][2],.T.)
			EndIf
		Next nI
		aColsMoe[nCols][Len(aHeaderMoe)+1] := .F.
	FJM->(DbSkip())
	EndDo
Else //Inclusao|Registro padrao
	Aadd(aColsMoe,Array(Len(aHeaderMoe)+1))
	For nI := 1 To Len(aHeaderMoe)
		aColsMoe[1][nI] := CriaVar(aHeaderMoe[nI][2])

		If cPaisLoc == "ARG" .and. nI == 1
			aColsMoe[1][nI] := cCodPreop
		Endif

	Next nI
	aColsMoe[1][Len(aHeaderMoe)+1] := .F.
EndIf

//-----------------------------------------------
// Salva a estrutura para a quantidade de Pre-OP
//-----------------------------------------------
For nX := 1 To Len(oGridPreOP:aCols)
	Aadd(aColsSavMo,AClone(aColsMoe))
Next nX

oPanel2 := TPanel():New(0,0,'',oFolder:aDialogs[2],,.T.,.T.,,,30,30,.F.,.F.)
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//             MsNewGetDados():New(nTop,nLeft,nBottom,nRight,nStyle                                                           ,cLinhaOk      ,cTudoOk      ,cIniCpos,aAlter,nFreeze,nMax,cFieldOk      ,cSuperDel,cDelOk        ,oWnd   ,aHeader   ,aCols
oBrwRat := MsNewGetDados():New(000 ,000  ,100    ,100   ,If(nOpcao == 1 .Or. nOpcao == 4 ,GD_INSERT+GD_UPDATE+GD_DELETE,0),"FA855VlRat()","AllwaysTrue",""      ,      ,0      ,999 ,"F855AtuRat()",""       ,"FA855DelMo()",oPanel2,aHeaderMoe,aColsMoe)
oBrwRat:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oBrwRat:Refresh()

	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa855GdRetบ Autor ณ Microsiga          บ Data ณ  30/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria a grid das retencoes da pre-ordem de pagamento        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Modulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa855GdRet(oSubPan3_1)
Local cAviso		:= ""
Local oMsgRet		:= Nil
Local oPnlAviso		:= Nil
Local aHeaderRet	:= {}
Local aColsRet		:= {}
Local nImposto		:= 0

Private aRecNoSE2	:= {}

If !(cPaisLoc=="ARG" .And. SE2->(ColumnPos("E2_CCR")) > 0  .and. !Empty(MV_PAR10))
	cAviso := STR0021 + " " + STR0022 //"ATENCAO: "###"Os valores de retencoes sao baseados nos dados atuais do sistema (data, dados do fornecedor etc)."
	cAviso += STR0023 //"Portanto, e possํvel que esses valores variem de acordo com a data real do pagamento."
EndIf
oPnlAviso := TPanel():New(000,000,'',oSubPan3_1,,.T.,,,RGB(200,00,00),100,023,.F.,.F.)
	oPnlAviso:Align := CONTROL_ALIGN_BOTTOM
	oMsgRet := TSay():New(001,001,{|| cAviso},oPnlAviso,,,,,,.T.,RGB(250,250,250),,(oPnlAviso:nClientWidth - 2)/2,(oPnlAviso:nClientHeight - 2)/2)
	oMsgRet:lWordWrap := .T.

If cPaisLoc == "ARG" .and. (TableInDic("FVC") .and. FVC->(ColumnPos("FVC_TIPO") * ColumnPos("FVC_EST") * ColumnPos("FVC_CONCEP") * ColumnPos("FVC_VALBAS") * ColumnPos("FVC_DESGR") * ColumnPos("FVC_ALIQ") * ColumnPos("FVC_RETENC")) > 0)
	Fn855GtCpo(@aHeaderRet)
	Aadd(aColsRet,{"","","",0,0,0,0,.F.})
Else 
	//               "cTitulo" ,"cCampo" ,"cPicture"                  ,"nTamanho"             ,"nDecimais"            ,"cValida็ใo","cReservado","cTipo","xReservado1","xReservado2"
	Aadd(aHeaderRet,{STR0024   ,"DESCRET",""                          ,20                     ,0                      ,""          ,"๛"         ,"C"    ,""           ,""           ,"", "", ".T."}) //"Retencao sobre"
	Aadd(aHeaderRet,{STR0025   ,"VALRET" ,PesqPict("FJK","FJK_VLRPRE"),TamSX3("FJK_VLRPRE")[1],TamSX3("FJK_VLRPRE")[2],""          ,"๛"         ,"N"    ,""           ,""           ,"", "", ".T."}) //Valor total da Pre Ordem
	
	Aadd(aColsRet,{"",0,.F.})
EndIf

//          MsNewGetDados():New(nTop,nLeft,nBottom,nRight,nStyle   ,cLinhaOk     ,cTudoOk      ,cIniCpos,aAlter,nFreeze,nMax,cFieldOk     ,cSuperDel,cDelOk        ,oWnd      ,aHeader   ,aCols   )
oGridRet := MsNewGetDados():New(000 ,000  ,100    ,100   ,GD_UPDATE,"AllwaysTrue","AllwaysTrue",""      ,{}    ,000    ,999 ,"AllwaysTrue",""       ,"AllwaysFalse",oSubPan3_1,aHeaderRet,aColsRet)
oGridRet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa855GtTotบ Autor ณ Microsiga          บ Data ณ  20/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria a GetDados com os dados dos totalizadores             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa855GtTot(oSubPan3_2)
Local aHeaderTot	:= {}
Local aColsTot		:= {}

//               "cTitulo","cCampo" ,"cPicture"                  ,"nTamanho"             ,"nDecimais"            ,"cValida็ใo","cReservado","cTipo","xReservado1","xReservado2"
Aadd(aHeaderTot,{STR0083  ,"DESCTOT",""                          ,40                     ,0                      ,""          ,"๛"         ,"C"    ,""           ,""           ,"", "", ".T."}) //"Totalizador"
Aadd(aHeaderTot,{STR0082  ,"VALTOT" ,PesqPict("FJK","FJK_VLRPRE"),TamSX3("FJK_VLRPRE")[1],TamSX3("FJK_VLRPRE")[2],""          ,"๛"         ,"N"    ,""           ,""           ,"", "", ".T."}) //"Valor"

Aadd(aColsTot,{"", 0, .F.})

//         MsNewGetDados():New(nTop,nLeft,nBottom,nRight,nStyle    ,cLinhaOk     ,cTudoOk      ,cIniCpos,aAlter,nFreeze,nMax,cFieldOk     ,cSuperDel,cDelOk        ,oWnd      ,aHeader   ,aCols   ,uChange,cTela)
oGridTot := MsNewGetDados():New(000 ,000  ,100    ,100   ,GD_UPDATE ,"AllwaysTrue","AllwaysTrue",""      ,{}    ,000    ,999 ,"AllwaysTrue",""       ,"AllwaysFalse",oSubPan3_2,aHeaderTot,aColsTot)
oGridTot:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA855VldVl บ Autor ณ Marylly A. Silva   บ Data ณ  08/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recarrega os paineis de totais de valores retidos na pre-  บฑฑ
ฑฑบ          ณ ordem de pago                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Modulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855VldVl()
Local lReturn		:= .T.
Local nValRet		:= 0
Local aTitulos		:= {}

Private aRecNoSE2	:= {}

//------------------------------------------------------------
// Valida se o valor informado eh maior que o saldo do titulo
//------------------------------------------------------------
If GdFieldGet("E2_TIPO") $ MVPAGANT+"|"+MV_CPNEG
	nSigno := -1
Else
	nSigno := 1
EndIf

If cPaisLoc=="ARG" .And. SE2->(ColumnPos("E2_CCR")) > 0  .and. !Empty(MV_PAR10)
	AAdd(aTitulos,{SE2->E2_FILIAL,SE2->E2_FORNECE,SE2->E2_LOJA, SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->(Recno()),M->VALPRE*nSigno,SE2->E2_FORNECE,SE2->E2_LOJA,""})
	MSGALERT(STR0109 , STR0089)
	Return (.F.)
EndIf

If (M->VALPRE * nSigno) > (GdFieldGet("E2_SALDO") * nSigno)
	lReturn := .F.
	MsgAlert(STR0019) //"O valor informado para a pre-ordem e maior que o saldo do titulo."
EndIf

//Valida o uso do sinal na edi็ใo do valor do PA
If GdFieldGet("E2_TIPO") $ MVPAGANT+"|"+MV_CPNEG .And. M->VALPRE > 0
	lReturn := .F.
	MsgAlert(STR0090) //"Para tํtulos que serใo descontados do valor da Pr้-Ordem de Pago, ้ necessแrio informar o sinal (-) para desconto."
EndIf

//-------------------------------------------------------
// Valida se o valor informado eh menor que as retencoes
//-------------------------------------------------------
If lReturn

	SE2->(DbGoTo(oBrwTit:aCols[oBrwTit:nAt][Len(oBrwTit:aHeader)+1]))

	If SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG
		nSigno := -1
	Else
		nSigno := 1
	EndIf

	AAdd(aTitulos,{SE2->E2_FILIAL,SE2->E2_FORNECE,SE2->E2_LOJA, SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->(Recno()),M->VALPRE*nSigno,SE2->E2_FORNECE,SE2->E2_LOJA,"","","","",""})
	
	//-----------------------------
	// Obtem o valor das retencoes
	//-----------------------------
	FA855Reten(aTitulos,,@nValRet)

	//---------------------------------------------------------------
	// Valida se o valor das retencoes eh maior que o valor definido
	//---------------------------------------------------------------
	If nValRet > IIF(cPaisLoc == "ARG", (Round(xMoeda(M->VALPRE,Val(GdFieldGet("MOEDA")),1,,5,,aTxMoedas[Val(GdFieldGet("MOEDA"))][2]),MsDecimais(Val(GdFieldGet("MOEDA")))) * nSigno), (M->VALPRE * nSigno))
		lReturn := .F.
		MsgAlert(STR0020) //"O valor das reten็๕es para a pr้-ordem ้ menor que o saldo a pagar informado."
	EndIf

EndIf

//-------------------------------------------------------------
// Efetiva o valor digitado na Grid para recalculo das janelas
//-------------------------------------------------------------
If lReturn

	GdFieldPut("VALPRE", M->VALPRE)
	GdFieldPut("VALCNV", (XMoeda(GdFieldGet("VALPRE"),Val(GdFieldGet("MOEDA")),Val(cMoeda),dDatabase)))

	//--------------------------------------------------------------
	// Grava o valor informado na tabela auxiliar para reconstrucao
	// dos titulos ao selecionar outra Pre-OP
	//--------------------------------------------------------------
		If FA855SE2->(MsSeek(xFilial("SE2")+cFornece+cLoja+GdFieldGet("E2_PREFIXO")+GdFieldGet("E2_NUM")+GdFieldGet("E2_PARCELA")+GdFieldGet("E2_TIPO")))
		RecLock("FA855SE2",.F.)
		FA855SE2->E2_VALPOP := GdFieldGet("VALPRE") * nSigno //Grava o valor original na tabela temporaria (sem sinal)
		FA855SE2->(MsUnlock())
	EndIf

	oBrwTit:Refresh()
EndIf
	
Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บ Autor ณMarylly A. Silva    บ Data ณ  08/17/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo exclusใo dos dados da pr้-ordem de pago.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855VldEx()
	Local nLinAtiv	:= 0
Local nLin		:= 0
Local lRet		:= .T.
Local cPreForn	:= GdFieldGet("FORNECEDOR",oGridPreOP:nAt,,oGridPreOP:aHeader,oGridPreOP:aCols)
Local cPreLoj	:= GdFieldGet("LOJA",oGridPreOP:nAt,,oGridPreOP:aHeader,oGridPreOP:aCols)
Local cPrePref	:= GdFieldGet("E2_PREFIXO")
Local cPreNum	:= GdFieldGet("E2_NUM")
Local cPreParc	:= GdFieldGet("E2_PARCELA")
Local cPreTipo	:= GdFieldGet("E2_TIPO")
Local lLinDel	:= oBrwTit:aCols[oBrwTit:nAt][Len(oBrwTit:aCols[oBrwTit:nAt])]

//-----------------------------------
// Nao permite deletar todos titulos
//-----------------------------------
If !lLinDel //Tratamento para nใo avaliar a restauracao da linha
	For nLin := 1 To Len(oBrwTit:aCols)
		If !(oBrwTit:aCols[nLin][Len(oBrwTit:aCols[nLin])])
			nLinAtiv++
		EndIf
	Next nLin

	If nLinAtiv == 1
		Help(" ",1,"F855VLTIT",,STR0131, 1, 0)
		lRet := .F.
	EndIf
EndIf

If lRet
	//------------------------------------------
	// Atualiza o registro na tabela temporaria
	//------------------------------------------
	DbSelectArea("FA855SE2")
	FA855SE2->(DbSetOrder(1))  //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If FA855SE2->(MsSeek(xFilial("SE2")+cPreForn+cPreLoj+cPrePref+cPreNum+cPreParc+cPreTipo))
			RecLock("FA855SE2",.F.)
			FA855SE2->E2_DELET := If(Empty(FA855SE2->E2_DELET),"*","")
			FA855SE2->(MsUnlock())
		EndIf
		
	//Troco o status da linha para atualizar as demais telas
	oBrwTit:aCols[oBrwTit:nAt][Len(oBrwTit:aCols[oBrwTit:nAt])] := !lLinDel
	//Atualiza os dados em tela
	FA855Atu("DelTit")
	//Retorno o estado da linha para que o programa delete
	oBrwTit:aCols[oBrwTit:nAt][Len(oBrwTit:aCols[oBrwTit:nAt])] := lLinDel
EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA855STit  บ Autor ณMarylly A. Silva    บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de abertura da tela de filtro e sele็ใo de tํtulos  บฑฑ
ฑฑบ          ณ que serใo utilizados na pr้-ordem de pago.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855STit(nOpcao)
Local bInitBr	:= Nil
Local aButtons	:= {}
Local lRet		:= .T.
Local lConfirm	:= .F.
Local nX		:= 0
Local nContTit	:= 0
Local cForn		:= ""
Local cLoja		:= ""
Local nPosPre	:= 0

//--- Contador de Marcados
Local nMarked   := 0

Private oDlgSel
Private oBrwSTit
Private oOK

Private oNOK
Private lCheck	:= .T.
Private aPagConCBU := {}
Private aPagSinCBU := {}

Default nOpcao := 0

If Pergunte("FIP855",.T.)

	//Filtra a SE2 de acordo com os parametros
	A855SE2()

		If !F855TMP->(Eof())

		oOK		:= LoadBitmap(GetResources(),"wfchk")
		oNOK	:= LoadBitmap(GetResources(),"wfunchk")

		Define MsDialog oDlgSel Title STR0026 From 000,000 To 540,756 Pixel //"Titulos a pagar"

		cMarca := If(ValType(cMarca) == "U","",cMarca)

		oBrwSTit := TCBrowse():New(0,0,10,10,,,,oDlgSel,,,,,{|| A855Mark()},,,,,,,,"F855TMP",.T.,,,,.T.,)
			oBrwSTit:AddColumn(TCColumn():New(""					,{|| Iif(F855TMP->E2_OK == cMarca,oOK,oNOK)}																,					,,,,010,.T.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_PREFIXO"),{|| F855TMP->E2_PREFIXO}																					,					,,,,020,.F.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_NUM")	,{|| F855TMP->E2_NUM}																						,					,,,,020,.F.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_PARCELA"),{|| F855TMP->E2_PARCELA}																					,					,,,,020,.F.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_FORNECE"),{|| F855TMP->E2_FORNECE}																					,					,,,,020,.F.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_LOJA")	,{|| F855TMP->E2_LOJA}																						,					,,,,020,.F.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_NOMFOR")	,{|| F855TMP->E2_NOMFOR}																					,					,,,,020,.F.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_TIPO")	,{|| F855TMP->E2_TIPO}																						,					,,,,020,.F.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_VENCTO")	,{|| F855TMP->E2_VENCTO}																					,					,,,,020,.F.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_VALOR")	,{|| F855TMP->E2_VALOR}																						,"@E 999,999,999.99",,,,020,.F.,.F.,,,,,))
			If cPaisLoc == 'RUS'
				oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_BASIMP1")	,{|| F855TMP->E2_BASIMP1}																						,   ,,,,020,.F.,.F.,,,,,))
				oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_ALQIMP1")	,{|| F855TMP->E2_ALQIMP1}																						,	,,,,020,.F.,.F.,,,,,))
				oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_VALIMP1")	,{|| F855TMP->E2_VALIMP1}																						,   ,,,,020,.F.,.F.,,,,,))
				oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_MDCONTR")	,{|| F855TMP->E2_MDCONTR}																						,   ,,,,020,.F.,.F.,,,,,))
			EndIf
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_SALDO")	,{|| F855TMP->E2_SALDO}																						,"@E 999,999,999.99",,,,020,.F.,.F.,,,,,))
			oBrwSTit:AddColumn(TCColumn():New(RetTitle("E2_MOEDA")	,{|| Lower(AllTrim(GetMV("MV_MOEDA" + AllTrim(Str(If(F855TMP->E2_MOEDA > 0,F855TMP->E2_MOEDA,1))))))}	,""					,,,,020,.F.,.F.,,,,,))
			oBrwSTit:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwSTit:Refresh()

		//Bloco a ser executado ao "Confirmar" a tela -> <CTRL+O>
		bSetConf := { || lConfirm := .T., GetKeys() , SetKey( VK_F3 , Nil ) , oDlgSel:End() }

		//Bloco a ser executado ao "Finalizar" a tela -> <CTRL+X>
		bSetFech := { || lConfirm := .F. ,GetKeys() , SetKey( VK_F3 , Nil ) , oDlgSel:End() }

		//Acoes relacionadas
		aAdd(aButtons,{"Parametros"				,{|| Pergunte("FIP855",.T.),cMarca := GetMark(),A855SE2(),oBrwSTit:DrawSelect()},OemToAnsi(STR0028),OemToAnsi(STR0028)}) //"Parโmetros"
		aAdd(aButtons,{"Marca_Desmarca_Todos"	,{|| F855AtCl(@lCheck)}															,OemToAnsi(STR0069),OemToAnsi(STR0069)}) //"Marca/Desmarca Todos"
		aAdd(aButtons,{"Pesquisa"				,{|| A855BsDoc()}																,OemToAnsi(STR0029),OemToAnsi(STR0029)}) //"Pesquisa"

		//Bloco para montagem da tela de sele็ใo de tํtulos a pagar para composi็ใo da pr้-ordem de pago
		bInitBr := { || EnchoiceBar( oDlgSel , bSetConf , bSetFech , Nil , aButtons )}
		oDlgSel:bInit := bInitBr

		Activate MsDialog oDlgSel Center

		If lConfirm

			F855TMP->(DbGoTop())

			While F855TMP->(!Eof())

				If F855TMP->E2_OK == cMarca

					SCU->(DbSetOrder(2))			 
					If cPaisloc == "ARG" .And. SuperGetMv('MV_SOLNCP') .And. F855TMP->E2_TIPO == MVNOTAFIS ;  
					.And. SCU->(MsSeek(xFilial()+F855TMP->E2_FORNECE+F855TMP->E2_LOJA+F855TMP->E2_NUM+F855TMP->E2_PREFIXO)).And. Empty(SCU->CU_NCRED) 
						HELP(" ",1,"SOLNCPAB") 
					Else 
	              	nMarked ++  // Incrementa Contador 
	
						RecLock("FA855SE2",.T.) 
	
						For nX := 1 To FA855SE2->(FCount()) 
							FA855SE2->(FieldPut(nX,F855TMP->(FieldGet(nX)))) 
						Next nX 
	
						FA855SE2->(MsUnlock()) 
						aAdd(aTitPreOrd,{F855TMP->E2_FORNECE, F855TMP->E2_LOJA, F855TMP->E2_PREFIXO, F855TMP->E2_NUM, F855TMP->E2_RECNO})
					EndIf 
				EndIf

				F855TMP->(DbSkip())
			EndDo

            // Verifica se Confirmou sem marcar nada
			If nMarked > 0

				//-------------------------------------------------
				// Atribui o numero da Pre-OP na tabela temporaria
				//-------------------------------------------------
				FA855SE2->(DbGoTop())
				While FA855SE2->(!Eof())

					cForn	:= FA855SE2->E2_FORNECE
					cLoj	:= FA855SE2->E2_LOJA

					If nOpcao == 1 //Inclusao de Pre-OP
						Aadd(aSavNumPre,{GetSxeNum("FJK","FJK_PREOP"),.T.})
						cNumPreOp := aSavNumPre[Len(aSavNumPre)][1]

					ElseIf nOpcao == 2 //Inclusao de titulo na Pre-OP no processo de alteracao
						Aadd(aSavNumPre,{FJK->FJK_PREOP,.F.})
						cNumPreOp := aSavNumPre[Len(aSavNumPre)][1]

					ElseIf nOpcao == 9 //Adicao de titulos na Pre-OP no processo de inclusao

						cNumPreOp := F855LocNum(cForn,cLoj)

						If Empty(cNumPreOp)
							Aadd(aSavNumPre,{GetSxeNum("FJK","FJK_PREOP"),.T.})
							cNumPreOp := aSavNumPre[Len(aSavNumPre)][1]
						EndIf

					EndIf

					While FA855SE2->(!EOF()) .And. ( FA855SE2->(E2_FORNECE+E2_LOJA) == cForn+cLoj )

						If nOpcao == 1 .Or. Empty(FA855SE2->E2_PREOP)
							RecLock("FA855SE2",.F.)
							FA855SE2->E2_PREOP := cNumPreOp
							FA855SE2->(MsUnlock())
						EndIf

					FA855SE2->(DbSkip())
					EndDo

				EndDo
			Else
				lRet := .F.
				ApMsgAlert( STR0088 ) //"Selecione titulos para a composi็ใo da Pr้-OP"
			EndIf
		Else
			lRet := .F.
		EndIf

	Else
		lRet := .F.
	    Help(" ",1,"F855PRETIT",,STR0130, 1, 0)
	EndIf
Else
	lRet := .F.
EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บ Autor ณ Marylly A. Silva   บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega os tํtulos a pagar pendentes para o fornecedor in- บฑฑ
ฑฑบ          ณ formado na pr้-ordem de pagamento.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855SE2()
	Local lFiltra	:= .F.
Local lMarca	:= .F.
Local cChave 	:= ""
Local cCondicao := ""
Local aSelNat	:= {}
Local cIndex 	:= CriaTrab(Nil,.F.)
Local dDataFim  := ""
Local cRecnos	:= ""
Local nRegistro	:= 0
Local cQuery	:= ""
Local cAliasSE2	:= GetNextAlias()
Local cCampoTab	:= ""
Local nX		:= 0
Local aCols		:= {}
Local lCcr		:= .F.

If cPaisLoc=="ARG" .And. SE2->(ColumnPos("E2_CCR")) > 0 
	lCcr:=.t.
EndIf

//--------------------------------------------------------------------
// Processo de selecao manual das naturezas para composi็ใo do filtro
//--------------------------------------------------------------------
If MV_PAR09 == 1 //Seleciona natureza
	F855SelNat(@aSelNat)
EndIf

cPagaveis	:=	GetSESTipos({|| ES_BXRCOP == "1"},"2")
cPagaveis	:=	If(Empty(cPagaveis),MVNOTAFIS+"|"+MVPAGANT,cPagaveis)

cQuery := "	SELECT "
cQuery += "		E2_FILIAL	,E2_PREFIXO	,E2_NUM		,E2_PARCELA	,E2_TIPO	,E2_NATUREZ	,"
cQuery += "		E2_FORNECE	,E2_LOJA	,E2_NOMFOR	,E2_EMISSAO	,E2_VENCTO	,E2_VENCREA	,"
cQuery += "		E2_VALOR	,E2_SALDO	,E2_OK		,E2_MOEDA	,E2_DATALIB	,E2_PREOK	,"
If cPaisLoc == "RUS"
	cQuery += "		E2_BASIMP1	,E2_ALQIMP1	,E2_VALIMP1 ,E2_MDCONTR	,"
EndIf
cQuery += "		E2_TXMOEDA	,E2_VLBXPAR	,E2_PREOP	,E2_STATLIB	,R_E_C_N_O_ E2_RECNO	"
cQuery += "	FROM " + RETSQLTAB("SE2")
cQuery += "	WHERE E2_FILIAL = '" + XFilial("SE2") + "'"
cQuery += "		AND D_E_L_E_T_	= '' "
If ALTERA
	cQuery += "		AND E2_FORNECE	= '" + FJK->FJK_FORNEC + "'"
	cQuery += "		AND E2_LOJA		= '" + FJK->FJK_LOJA + "'"
Else
	cQuery += "		AND E2_FORNECE	>= '" + MV_PAR03 + "'"
	cQuery += "		AND E2_FORNECE	<= '" + MV_PAR04 + "'"
	cQuery += "		AND E2_LOJA		>= '" + MV_PAR05 + "'"
	cQuery += "		AND E2_LOJA		<= '" + MV_PAR06 + "'"
EndIf
cQuery += "		AND E2_VENCREA	>= '" + DToS(MV_PAR01) + "'"
cQuery += "		AND E2_VENCREA	<= '" + DToS(MV_PAR02) + "'"
cQuery += "		AND E2_NATUREZ	>= '" + MV_PAR07 + "'"
cQuery += "		AND E2_NATUREZ	<= '" + MV_PAR08 + "'"
cQuery += "		AND E2_EMISSAO	<= '" + DToS(dDataBase) + "'"
If !(cPaisLoc $'RUS|ARG|') .Or. (cPaisLoc == 'ARG' .and. !lCcr)  .Or. (cPaisLoc == 'ARG' .and. lCcr .and. Empty(MV_PAR10))
	cQuery += "		AND E2_TIPO		IN " + FormatIn(cPagaveis,"|")
EndIf
cQuery += "		AND E2_SALDO	> 0"
If ALTERA
	cQuery += "	AND (E2_PREOP	= '" + FJK->FJK_PREOP + "'"
	cQuery += "	OR (E2_PREOK	<> 'S' "
	cQuery += "	AND E2_PREOP	= '' ))"
Else
	cQuery += "	AND E2_PREOK	<> 'S' "
	cQuery += "	AND E2_PREOP	= '' "
EndIf

If GetMV("MV_CTLIPAG")
	cQuery += "	AND E2_DATALIB	<> '' "
	cQuery += "	AND E2_STATLIB	IN ('03','05') "
EndIf

If lCcr 
	cQuery += "		AND E2_CCR	= '" + MV_PAR10 + "'"
EndIf

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSE2, .F., .T.)
TcSetField(cAliasSE2, "E2_EMISSAO"	, "D")
TcSetField(cAliasSE2, "E2_VENCTO"	, "D")
TcSetField(cAliasSE2, "E2_VENCREA"	, "D")
TcSetField(cAliasSE2, "E2_DATALIB"	, "D")

//Limpa a tabela temporaria para adicao de mais titulos
F855TMP->(DbGoTop())
While F855TMP->(!Eof())
	RecLock("F855TMP")
	F855TMP->(DbDelete())
	F855TMP->(MsUnlock())
F855TMP->(DbSkip())
EndDo

While (cAliasSE2)->(!Eof())

	If MV_PAR09 == 1
		If Empty(aSelNat)
			Exit
		Else
			If Ascan(aSelNat,{|x| x == (cAliasSE2)->E2_NATUREZ}) == 0
				(cAliasSE2)->(DbSkip())
				Loop
			EndIf
		EndIf
	EndIf

	If FA855SE2->(MsSeek(xFilial("FA855SE2")+(cAliasSE2)->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)))
		(cAliasSE2)->(DbSkip())
		Loop
	EndIf

	//Verifica se o titulo ja foi selecionado
	If oBrwTit != Nil
		aCols := oBrwTit:aCols
	EndIf
	
	If lCcr .And. !Empty(MV_PAR10)
		FVT->(DbSetOrder(1))
		If FVT->(DbSeek(xFilial("FVT")+MV_PAR10+"P"+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA+Subs((cAliasSE2)->E2_TIPO,1,3)+(cAliasSE2)->E2_PREFIXO+(cAliasSE2)->E2_NUM) .and. !(FVT->FVT_STATUS $ "1|2"))
			(cAliasSE2)->(DbSkip())
			Loop
		EndIf	
	EndIf
	
	If aScan(aCols, { |x,y| x[10] == (cAliasSE2)->(E2_RECNO) }) == 0
		
		RecLock("F855TMP",.T.)
			F855TMP->E2_FILIAL	:= XFilial("SE2")
			F855TMP->E2_PREFIXO	:= (cAliasSE2)->E2_PREFIXO
			F855TMP->E2_NUM		:= (cAliasSE2)->E2_NUM
			F855TMP->E2_PARCELA	:= (cAliasSE2)->E2_PARCELA
			F855TMP->E2_TIPO	:= (cAliasSE2)->E2_TIPO
			F855TMP->E2_NATUREZ	:= (cAliasSE2)->E2_NATUREZ
			F855TMP->E2_FORNECE	:= (cAliasSE2)->E2_FORNECE
			F855TMP->E2_LOJA	:= (cAliasSE2)->E2_LOJA
			F855TMP->E2_NOMFOR	:= (cAliasSE2)->E2_NOMFOR
			F855TMP->E2_EMISSAO	:= (cAliasSE2)->E2_EMISSAO
			F855TMP->E2_VENCTO	:= (cAliasSE2)->E2_VENCTO
			F855TMP->E2_VENCREA	:= (cAliasSE2)->E2_VENCREA
			F855TMP->E2_VALOR	:= (cAliasSE2)->E2_VALOR
			If cPaisloc == "RUS"
				F855TMP->E2_BASIMP1	  := (cAliasSE2)->E2_BASIMP1
				F855TMP->E2_ALQIMP1	  := (cAliasSE2)->E2_ALQIMP1
				F855TMP->E2_VALIMP1   := (cAliasSE2)->E2_VALIMP1
				F855TMP->E2_MDCONTR	  := (cAliasSE2)->E2_MDCONTR
			EndIf
			F855TMP->E2_SALDO	:= (cAliasSE2)->E2_SALDO
			If lCcr .and. !Empty(MV_PAR10)
				F855TMP->E2_OK		:= cmarca
			Else
				F855TMP->E2_OK		:= (cAliasSE2)->E2_OK
			Endif
			F855TMP->E2_MOEDA	:= (cAliasSE2)->E2_MOEDA
			F855TMP->E2_DATALIB	:= (cAliasSE2)->E2_DATALIB
			F855TMP->E2_PREOK	:= (cAliasSE2)->E2_PREOK
			F855TMP->E2_TXMOEDA	:= (cAliasSE2)->E2_TXMOEDA
			F855TMP->E2_VLBXPAR	:= (cAliasSE2)->E2_VLBXPAR
			F855TMP->E2_PREOP	:= (cAliasSE2)->E2_PREOP
			F855TMP->E2_STATLIB	:= (cAliasSE2)->E2_STATLIB
			F855TMP->E2_VALPOP	:= (cAliasSE2)->E2_SALDO
			F855TMP->E2_RECNO	:= (cAliasSE2)->E2_RECNO
			
			F855TMP->E2_MOEPOP	:= cMoeda
			F855TMP->E2_DELET	:= ""
		F855TMP->(MsUnlock())
			
	EndIf
	
(cAliasSE2)->(DbSkip())
EndDo

(cAliasSE2)->(DbCloseArea())

F855TMP->(DbGoTop())
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA855  บ Autor ณ Marylly A. Silva   บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para marcar o tํtulo no duplo click sobre a linha doบฑฑ
ฑฑบ          ณ registro do tํtulo a pagar que serแ incluํdo na pr้-ordem  บฑฑ
ฑฑบ          ณ de pagamento.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855Mark()
	
Local lTestCQ := .F.
Local lAbleCQ := GetNewPar( "MV_FINCQ" , .F. )  //Habilita ou nao a Verificacao de Qualidade

If cPaisLoc=="ARG" .And. SE2->(ColumnPos("E2_CCR")) > 0  .and. !Empty(MV_PAR10)
	Return()
EndIf

If cMarca == Nil
	cMarca := ""
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Argentina - Executa a verificacao de Material em Controle de Qualidade ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lAbleCQ

    If !F855TMP->(Eof()) .And. !( F855TMP->E2_TIPO $ MV_CPNEG+"/"+MVPAGANT )

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Nao quero que acione a verificacao se ja estiver marcado ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       If !(F855TMP->E2_OK == cMarca)

          lTestCQ := OnOrRejQA( F855TMP->E2_NUM, F855TMP->E2_PREFIXO, F855TMP->E2_FORNECE, F855TMP->E2_LOJA )

       EndIf

       If !lTestCQ
          //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
          //ณ Titulo Liberado para a Selecao ณ
          //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	      If !F855TMP->(Eof())

             Reclock("F855TMP",.F.)

	         If F855TMP->E2_OK == cMarca
					F855TMP->E2_OK := " "
					A855DelTt()	
					If cPaisloc = "ARG"
						DelCompCBU()
					EndIf
	         Else
					If cPaisloc = "ARG"
						If AddCompCBU()
							F855TMP->E2_OK := cMarca
						EndIf
					Else
						F855TMP->E2_OK := cMarca
					EndIf
	         EndIf

             F855TMP->(MsUnlock())

	      EndIf

       Else

          Aviso( OemToAnsi(STR0021), OemToAnsi(STR0087) , {'Ok'} )  // Atencao # "Este Titulo foi gerado por uma NF, cujos itens se encontram em processo de Inspe็ใo de Qualidade. Nessas condi็๕es, a sele็ใo ้ recusada."

       EndIf

    EndIf

Else

   If !F855TMP->(Eof())

	  Reclock("F855TMP",.F.)

	   If F855TMP->E2_OK == cMarca
			F855TMP->E2_OK := " "
			A855DelTt()	
			If cPaisloc = "ARG"
				DelCompCBU()
			EndIf
	   Else
			If cPaisloc = "ARG"
				If  AddCompCBU()
					If VldDocPag(F855TMP->E2_RECNO, .T.)
						F855TMP->E2_OK := cMarca
					EndIf
				EndIf
			Else
				F855TMP->E2_OK := cMarca
			EndIf
	   EndIf

	   F855TMP->(MsUnlock())

   EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บAutor  ณMicrosiga           บ Data ณ  08/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855BsDoc()
Local oDlg
Local oFornece,oLoja,oRazao,oPrefixo,oNum,oParc
Local cForn		:= CriaVar("A2_COD")
Local cLoj		:= CriaVar("A2_LOJA")
Local cRazao	:= CriaVar("A2_NOME")
Local cPrefixo	:= CriaVar("E2_PREFIXO")
Local cNum		:= CriaVar("E2_NUM")
Local cParc		:= CriaVar("E2_PARCELA")

Local nOpcao := 0

DEFINE MSDIALOG oDlg TITLE STR0070 FROM 3,0 TO 240,500 PIXEL // "Busca de documento"

//FORNECEDOR
@ 05,10 To 45,240 Pixel Of oDlg LABEL OemToAnsi(STR0028)
//DOCUMENTO
@ 50,10 To 90,240 Pixel Of oDlg LABEL OemToAnsi(STR0033)

@ 15,15 SAY OemToAnsi(STR0034) Size 70,08 Pixel Of oDlg  //"Fornecedor"
@ 25,15 MSGET oFornece VAR cForn F3 "SA2" PICTURE PesqPict("SA2","A2_COD") VALID {|| cLoj := SA2->A2_LOJA, cRazao := SA2->A2_NOME} SIZE 12,10 PIXEL OF oDlg

@ 15,55 SAY OemToAnsi(STR0009) Size 70,08 Pixel Of oDlg //"Loja"
@ 25,55 MSGET oLoja VAR cLoj PICTURE PesqPict("SA2","A2_LOJA") SIZE 12,10 PIXEL OF oDlg

@ 15,74 SAY OemToAnsi(STR0010) Size 100,08 Pixel Of oDlg //"Razao Social"
@ 25,74 MSGET oRazao VAR cRazao PICTURE PesqPict("SA2","A2_NOME") SIZE 150,10 PIXEL OF oDlg
oRazao:Disable()

@ 60,15 SAY OemToAnsi(STR0035) Size 70,08 Pixel Of oDlg  //"Prefixo"
@ 70,15 MSGET oPrefixo VAR cPrefixo PICTURE PesqPict("SE2","E2_PREFIXO") SIZE 12,10 PIXEL OF oDlg

@ 60,48 SAY OemToAnsi(STR0036) Size 70,08 Pixel Of oDlg //"Numero"
@ 70,48 MSGET oNum VAR cNum PICTURE PesqPict("SE2","E2_NUM")SIZE 90,10 PIXEL OF oDlg

@ 60,150 SAY OemToAnsi(STR0037) Size 100,08 Pixel Of oDlg //"Parcela"
@ 70,150 MSGET oParc VAR cParc PICTURE PesqPict("SE2","E2_PARCELA") SIZE 20,10 PIXEL OF oDlg

DEFINE SBUTTON FROM 100,185 TYPE 1 ACTION {|| nOpcao := 1,oDlg:End()} ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 100,215 TYPE 2 ACTION {||oDlg:End()} ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTER

If nOpcao == 1 //Confirma

		If !F855TMP->(MsSeek(xFilial("SE2")+cForn+cLoj+cPrefixo+cNum+cParc))
			F855TMP->(DbGoTop())
			MsgAlert(STR0038) //"Nใo foi possivel localizar o tํtulo."
			A855BsDoc() //Abro a tela de pesquisa novamente
		EndIf
		
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บAutor  ณMicrosiga           บ Data ณ  08/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ao deletar um tํtulo a pagar da pr้-ordem de pago, todos osบฑฑ
ฑฑบ          ณ totais da pr้-ordem e de reten็๕es sใo feitas desconside-  บฑฑ
ฑฑบ          ณ rando o tํtulo a pagar excluํdo                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855DelTt(nPos)
	Local nUlt := Len(aDados)

DEFAULT nPos := 0

nPos := aScan(aDados, {|x| x[nPosRecno] == SE2->(Recno()) })

If nPos > 0 .And. Len(aDados) > 0
	aDel(aDados, nPos)
	aSize(aDados,nUlt-1)
EndIf

If nPos > 0 .And. Len(aRetTit) > 0
	aRet[1][2] -= aRetTit[nPos][1][2]
	aRet[2][2] -= aRetTit[nPos][2][2]
	aRet[3][2] -= aRetTit[nPos][3][2]
	aRet[4][2] -= aRetTit[nPos][4][2]
	aRet[5][2] -= aRetTit[nPos][5][2]
	aRet[6][2] -= aRetTit[nPos][6][2]

	aDel(aRetTit, nPos)
	aSize(aRetTit,nUlt-1)
EndIf

F855RecMoed()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บAutor  ณMicrosiga           บ Data ณ  08/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855LeOP()
Local aItem		:= {}
Local cQuery	:= ""
Local cAliasQry	:= "PREOPQRY"
Local nX		:= 0
Local aAreaSE2	:= Eval({|| DbSelectArea("SA2"), SA2->(GetArea())})
Local cCpo855   := ""
Local nLoop     := 0

aDados := {}

DbSelectArea("FJL")
	
#IFDEF TOP
	If TcSrvType()<>"AS/400"
		cQuery := "SELECT"
		If cPaisloc == "RUS"
			cQuery += "SE2.E2_BASIMP1,SE2.E2_ALQIMP1	,SE2.E2_VALIMP1 ,E2_MDCONTR	,"
		Endif
		
		If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
			For nLoop := 1 To Len(a855Cpos)
				cCpo855 += " " + a855Cpos[nLoop][2][1] + ", "
			Next nLoop
			cQuery += cCpo855
		EndIf
		cQuery += "FJL.FJL_FORNEC, FJL.FJL_LOJA, SE2.E2_NOMFOR, FJL.FJL_TIPO, FJL.FJL_PREFIX, FJL.FJL_NUM, FJL.FJL_PARCEL, SE2.E2_VENCTO, SE2.E2_MOEDA, SE2.E2_TXMOEDA, FJL.FJL_VALOR, FJL.FJL_VLRPRE, FJL.FJL_VLCONV, SE2.R_E_C_N_O_ RECNOSE2 "
		cQuery += " FROM "
		cQuery += RetSqlTab("FJL")+", "
		cQuery += RetSqlTab("SE2")

		cQuery += " WHERE "

		cQuery += "FJL.FJL_PREOP ='" + FJK->FJK_PREOP + "' AND "
		cQuery += "SE2.E2_FORNECE = '" + FJK->FJK_FORNEC + "' AND "
		cQuery += "SE2.E2_FILIAL = '" + FJK->FJK_FILIAL + "' AND "
		cQuery += "SE2.E2_FORNECE = FJL.FJL_FORNEC AND "
		cQuery += "SE2.E2_LOJA = FJL.FJL_LOJA AND "
		cQuery += "SE2.E2_PREFIXO = FJL.FJL_PREFIX AND "
		cQuery += "SE2.E2_NUM = FJL.FJL_NUM AND "
		cQuery += "SE2.E2_PARCELA = FJL.FJL_PARCEL AND "
		cQuery += "SE2.E2_TIPO = FJL.FJL_TIPO AND "

		cQuery += "SE2.D_E_L_E_T_ = '' AND "
		cQuery += "FJL.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
		TcSetField(cAliasQry, "E2_VENCTO" , "D")

		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())

		While !(cAliasQry)->(Eof())

			SE2->(DbGoTo((cAliasQry)->RECNOSE2))

			RecLock("FA855SE2",.T.)
				FA855SE2->E2_FILIAL		:= XFilial("SE2")
				FA855SE2->E2_PREFIXO	:= SE2->E2_PREFIXO
				FA855SE2->E2_NUM		:= SE2->E2_NUM
				FA855SE2->E2_PARCELA	:= SE2->E2_PARCELA
				FA855SE2->E2_TIPO		:= SE2->E2_TIPO
				FA855SE2->E2_NATUREZ	:= SE2->E2_NATUREZ
				FA855SE2->E2_FORNECE	:= SE2->E2_FORNECE
				FA855SE2->E2_LOJA		:= SE2->E2_LOJA
				FA855SE2->E2_NOMFOR		:= SE2->E2_NOMFOR
				FA855SE2->E2_EMISSAO	:= SE2->E2_EMISSAO
				FA855SE2->E2_VENCTO		:= SE2->E2_VENCTO
				FA855SE2->E2_VENCREA	:= SE2->E2_VENCREA
				FA855SE2->E2_VALOR		:= SE2->E2_VALOR
				If cPaisloc == "RUS"
					FA855SE2->E2_BASIMP1	:= SE2->E2_BASIMP1
					FA855SE2->E2_ALQIMP1	:= SE2->E2_ALQIMP1
					FA855SE2->E2_VALIMP1	:= SE2->E2_VALIMP1
					FA855SE2->E2_MDCONTR	:= SE2->E2_MDCONTR
				EndIf
				FA855SE2->E2_SALDO		:= SE2->E2_SALDO
				FA855SE2->E2_OK			:= SE2->E2_OK
				FA855SE2->E2_MOEDA		:= SE2->E2_MOEDA
				FA855SE2->E2_DATALIB	:= SE2->E2_DATALIB
				FA855SE2->E2_PREOK		:= SE2->E2_PREOK
				FA855SE2->E2_TXMOEDA	:= SE2->E2_TXMOEDA
				FA855SE2->E2_VLBXPAR	:= SE2->E2_VLBXPAR
				If cPaisloc == "RUS" .And. Empty(SE2->E2_PREOP)
					E2_PREOP := FJK->FJK_PREOP
				Else 
					FA855SE2->E2_PREOP := SE2->E2_PREOP
				Endif
				FA855SE2->E2_STATLIB	:= SE2->E2_STATLIB
				FA855SE2->E2_MOEPOP		:= cMoeda
				FA855SE2->E2_VALPOP		:= (cAliasQry)->FJL_VLRPRE
				FA855SE2->E2_RECNO		:= SE2->(Recno())
				FA855SE2->E2_DELET		:= ""
				If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
					For nLoop := 1 To Len(a855Cpos)
						FA855SE2->&(a855Cpos[nLoop][1][2]) := (cAliasQry)->&(a855Cpos[nLoop][2][1])
					Next
				EndIf
			FA855SE2->(MsUnlock())

		(cAliasQry)->(DbSkip())
		EndDo

	EndIf
#ELSE
	DbSelectArea("FJL")
	FJL->(dbSetOrder(1))

	If FJL->(MsSeek(xFilial("FJL")+FJK->FJK_PREOP))

		SE2->(DbSetOrder(1))

		While !FJL->(!Eof()) .And. FJL->(FJL_FILIAL+FJL_PREOP) == xFilial("FJL")+FJK->FJK_PREOP

			If SE2->(MsSeek(xFilial("SE2")+FJL->(FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO+FJL_FORNEC+FJL_LOJA)))

				RecLock("FA855SE2",.T.)
					FA855SE2->E2_FILIAL	:= XFilial("SE2")
					FA855SE2->E2_PREFIXO	:= SE2->E2_PREFIXO
					FA855SE2->E2_NUM		:= SE2->E2_NUM
					FA855SE2->E2_PARCELA	:= SE2->E2_PARCELA
					FA855SE2->E2_TIPO		:= SE2->E2_TIPO
					FA855SE2->E2_NATUREZ	:= SE2->E2_NATUREZ
					FA855SE2->E2_FORNECE	:= SE2->E2_FORNECE
					FA855SE2->E2_LOJA		:= SE2->E2_LOJA
					FA855SE2->E2_NOMFOR	:= SE2->E2_NOMFOR
					FA855SE2->E2_EMISSAO	:= SE2->E2_EMISSAO
					FA855SE2->E2_VENCTO	:= SE2->E2_VENCTO
					FA855SE2->E2_VENCREA	:= SE2->E2_VENCREA
					FA855SE2->E2_VALOR	:= SE2->E2_VALOR
					If cPaisloc == "RUS"
						FA855SE2->E2_BASIMP1	:= SE2->E2_BASIMP1
						FA855SE2->E2_ALQIMP1	:= SE2->E2_ALQIMP1
						FA855SE2->E2_VALIMP1	:= SE2->E2_VALIMP1
						FA855SE2->E2_MDCONTR	:= SE2->E2_MDCONTR
					EndIf
					FA855SE2->E2_SALDO	:= SE2->E2_SALDO
					FA855SE2->E2_OK		:= SE2->E2_OK
					FA855SE2->E2_MOEDA	:= SE2->E2_MOEDA
					FA855SE2->E2_DATALIB	:= SE2->E2_DATALIB
					FA855SE2->E2_PREOK	:= SE2->E2_PREOK
					FA855SE2->E2_TXMOEDA	:= SE2->E2_TXMOEDA
					FA855SE2->E2_VLBXPAR	:= SE2->E2_VLBXPAR
					FA855SE2->E2_PREOP	:= SE2->E2_PREOP
					FA855SE2->E2_STATLIB	:= SE2->E2_STATLIB
					FA855SE2->E2_MOEPOP	:= cMoeda
					FA855SE2->E2_VALPOP	:= FJL->FJL_VLRPRE
					FA855SE2->E2_RECNO	:= SE2->(Recno())
					FA855SE2->E2_DELET	:= ""
				FA855SE2->(MsUnlock())

			EndIf

		FJL->(DbSkip())
		EndDo

	EndIf
#ENDIF

FA855SE2->(DbGoTop())

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf

SE2->(RestArea(aAreaSE2))
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บ Autor ณ Marylly A. Silva   บ Data ณ  08/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recalcula todos os impostos da pr้-ordem de pagamento de   บฑฑ
ฑฑบ          ณ modifica็๕es aplicadas na pr้-ordem de pagamento           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855RecRet(cOrdPago)
Local nOldRec		:= 0
Local nA			:= 0
Local nX			:= 0
Local nY			:= 0
Local nPos			:= 0
Local nDecs		:= 2
Local nMoeda		:= 1
Local aItem		:= {}
Local cDesImp		:= ""
Local lEfet		:= .F.
Local nImposto	:= 0

Private aRecNoSE2	:= {}
Private aRetIvAcm	:= Array(3)

DEFAULT cOrdPago  := ""
	cOrdPago  :=FJK->FJK_PREOP

//Verifica se a Pre-Ordem foi efetivada
If !Empty(cOrdPago)
	lEfet := .T.
EndIf

If !lEfet //Caso a Pre-Ordem nao tenha sido efetivada, recalcula os impostos
	aRecNoSE2 := {}

	DbSelectArea("SE2")
	nOldRec := SE2->(Recno())

	For nX := 1 to Len(aDados)
		SE2->(dbGoTo(aDados[nX][nPosRecno]))

		If aDados[nX][4] $ MVPAGANT+"|"+MV_CPNEG
			nSigno := -1
		Else
			nSigno := 1
		EndIf

		AAdd(aRecNoSE2,{SE2->E2_FILIAL,SE2->E2_FORNECE,SE2->E2_LOJA, SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,aDados[nX][nPosRecno],aDados[nX][11]*nSigno,cFornece,cLoja})
	Next nX

	F850Se2(@aSE2,.T.,.T.)

	If Len(aSE2) > 0
		For nA:=1	To Len(aSE2)

			nRetGan	:=	0

			For nX	:=	1	To Len(aSE2[nA][1])

				nMoeda	:= aSE2[nA][1][nX][_MOEDA]
				nDecs	:= MsDecimais(nMoeda)

				If nX == Len(aSE2[nA][1])
					For nY:= 1	To Len(aSE2[nA][2])
						nImposto += aSE2[nA][2][nY][5]
					Next nY
				EndIf

				aAdd(aItem, {STR0039,nImposto}) //"Ganancias"
				nImposto := 0

				For nY	:=	1	To	Len(aSE2[nA][1][nX][_RETIVA])
					nImposto	+= aSE2[nA][1][nX][_RETIVA][nY][6]
				Next

				aAdd(aItem, {STR0040,nImposto}) //"IVA"
				nImposto := 0

				For nY	:=	1	To	Len(aSE2[nA][1][nX][_RETIB])
					nImposto	+=	aSE2[nA][1][nX][_RETIB ][nY][5]
				Next

				aAdd(aItem, {STR0041,nImposto}) //"IB"
				nImposto := 0

				For nY	:=	1	To	Len(aSE2[nA][1][nx][_RETSUSS])
					nImposto	+=	aSE2[nA][1][nX][_RETSUSS][nY][6]
				Next

				aAdd(aItem, {STR0042,nImposto}) //"SUSS"
				nImposto := 0

				For nY	:=	1	To	Len(aSE2[nA][1][nx][_RETSLI])
					nImposto	+=	aSE2[nA][1][nX][_RETSLI][nY][6]
				Next

				aAdd(aItem, {STR0043,nImposto}) //"SLI"
				nImposto := 0

				For nY	:=	1	To	Len(aSE2[nA][1][nx][_RETISI])
					nImposto	+=	aSE2[nA][1][nX][_RETISI][nY][6]
				Next

				aAdd(aItem, {STR0044,nImposto}) //"ISI"
				nImposto := 0

				//Incluir um novo registro de reten็ใo para a Dados
				aAdd(aRetTit,aItem)
				aItem := {}
			Next

		Next

		SE2->(dbGoTo(nOldRec))

		//Ordena o Array a Dados
		aSort(aDados,,,{|x,y| x[1]+x[2]+x[5]+x[6]+x[7]+x[4] < y[1]+y[2]+y[5]+y[6]+y[7]+y[4]})

	EndIf
Else //Pre-ordens efetivadas considerarao os valores retidos.

	dbSelectArea("SEK")
	SEK->(dbSetOrder(1))

	If SEK->(MsSeek(xFilial("SEK")+cOrdPago+"RG"))

		aItem := Array(6)

		While !SEK->(Eof()) .And. SEK->(EK_FILIAL+EK_ORDPAGO+EK_TIPODOC) == xFilial("SEK")+cOrdPago+"RG"

			Do Case
				Case SEK->EK_TIPO == "GN-"
					nPos := 1
					cDesImp := STR0039
				Case SEK->EK_TIPO == "IV-"
					nPos := 2
					cDesImp := STR0040
				Case SEK->EK_TIPO == "IB-"
					nPos := 3
					cDesImp := STR0041
				Case SEK->EK_TIPO == "SU-"
					nPos := 4
					cDesImp := STR0042
				Case SEK->EK_TIPO == "SL-"
					nPos := 5
					cDesImp := STR0043
				Case SEK->EK_TIPO == "SI-"
					nPos := 6
					cDesImp := STR0044
			EndCase

			nMoeda := Val(SEK->EK_MOEDA)

			If aItem[nPos] == Nil
				aItem[nPos] := {cDesImp, Round(xMoeda(SEK->EK_VALOR,nMoeda,1),nDecs)}
			Else
				aItem[nPos][2] += Round(xMoeda(SEK->EK_VALOR,nMoeda,1),nDecs)
			EndIf

			SEK->(dbSkip())
		EndDo

		//Incluo um unico registro na aRetTit referente เs retencoes da Ordem de Pago
		aAdd(aRetTit,aItem)

	EndIf

	SEK->(dbCloseArea())
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855Incluบ Autor ณ Microsiga          บ Data ณ  03/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a inclusao da Pre-OP                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855Inclu()
Local nX 		:= 0
Local nJ		:= 0
Local lReturn 	:= .T.
Local nPosMoeda	:= GDFieldPos("FJM_MOEDA",oBrwRat:aHeader)
Local nLinPreOP	:= 0
Local nPosForn	:= GDFieldPos("FORNECEDOR"	,oGridPreOP:aHeader)
Local nPosLoja	:= GDFieldPos("LOJA"		,oGridPreOP:aHeader)
Local nPosPreOP	:= GDFieldPos("PREOP" 		,oGridPreOP:aHeader)
Local nPosValPOP:= GDFieldPos("VALPREOP"	,oGridPreOP:aHeader)
Local nPosNum		:= 0
Local nLoop         := 0
Local lREt			:= .T.
Local cURL			:= (PadR(GetNewPar("MV_ARGFEUR","http://"),250))
Local lWsFeCred	:= SuperGetMV( "MV_WSFECRD", .F., .F. ) 

//Salva pois as atualizacao nao reflete na versao final do array
aColsSavMo[oGridPreOP:nAt] := AClone(oBrwRat:aCols)

//chamada do metodo webservice wsfecred
If cPaisLoc == 'ARG' .And. lWsFeCred .And. !Empty(mv_par10)
	dbSelectArea("SX1")
	dbSetOrder(1)

	If SX1->(MsSeek('FIP855    '+ '11'))
		lREt := TrfFeCred(mv_par11)	
	Else
		lREt := TrfFeCred()
	Endif	
	SX1->(dbCloseArea())
Endif

If lREt
	DbSelectArea("FJK")
	FJK->(DbSetOrder(1)) //FJK_FILIAL+FJK_FORNEC+FJK_LOJA+FJK_PREOP
	
	For nLinPreOP := 1 To Len(oGridPreOP:aCols)
	
		If FJK->(!MsSeek(XFilial("FJK")+oGridPreOP:aCols[nLinPreOP][nPosForn]+oGridPreOP:aCols[nLinPreOP][nPosLoja]+oGridPreOP:aCols[nLinPreOP][nPosPreOP])) .And. !GDDeleted(nLinPreOP,oGridPreOP:aHeader,oGridPreOP:aCols)
	
			Begin Transaction
	
				//-----------------------------------
				// FJK - Cabecalho Pre-Ordem de Pago
				//-----------------------------------
				RecLock("FJK",.T.)
					FJK->FJK_FILIAL	:= XFilial("FJK")
					FJK->FJK_PREOP	:= oGridPreOP:aCols[nLinPreOP][nPosPreOP]
					FJK->FJK_DTDIG	:= dDataBase
					FJK->FJK_FORNEC	:= oGridPreOP:aCols[nLinPreOP][nPosForn]
					FJK->FJK_LOJA	:= oGridPreOP:aCols[nLinPreOP][nPosLoja]
					FJK->FJK_MOEDA	:= cMoeda
					FJK->FJK_VLRPRE	:= oGridPreOP:aCols[nLinPreOP][nPosValPOP]
					FJK->FJK_VLCONV := xMoeda(oGridPreOP:aCols[nLinPreOP][nPosValPOP],1,Val(cMoeda),dDataBase)
					If cPaisloc == "ARG" .And. FJK->(ColumnPos("FJK_CCR")) > 0 .and. !Empty(MV_PAR10)
						FJK->FJK_CCR := MV_PAR10
						FJK->FJK_DTANLI := dDataBase
					Endif
					
					If cPaisLoc == 'RUS'
						
						FJK->FJK_BNKCOD := aDetailRUS[nLinPreOP][_BnkCode]
						FJK->FJK_BIKCOD := aDetailRUS[nLinPreOP][_BikCod]
						FJK->FJK_BKNAME := aDetailRUS[nLinPreOP][_BkName]
						FJK->FJK_DTPLAN := aDetailRUS[nLinPreOP][_DtPlan]
						FJK->FJK_TPPGTO := aDetailRUS[nLinPreOP][_Tppgto]
						FJK->FJK_CONTA  := aDetailRUS[nLinPreOP][_Conta]
						FJK->FJK_RCNAME := aDetailRUS[nLinPreOP][_RcName]
						FJK->FJK_KPPPAY := aDetailRUS[nLinPreOP][_KPPPay]
						FJK->FJK_RECKPP := aDetailRUS[nLinPreOP][_RecKPP]
						FJK->FJK_PRIORI := aDetailRUS[nLinPreOP][_Priori]
						FJK->FJK_REASON := aDetailRUS[nLinPreOP][_Reason]
						FJK->FJK_VATRAT := aDetailRUS[nLinPreOP][_VATRat]
						FJK->FJK_VATAMT := aDetailRUS[nLinPreOP][_VATAmt]
						FJK->FJK_VATCOD := aDetailRUS[nLinPreOP][_VATCod]
						
					EndIf
				FJK->(MsUnlock())
				
				If cPaisLoc == 'ARG' .And. lWsFeCred 
					RecLock("FVS", .F.)
						FVS->FVS_PREOP := FJK->FJK_PREOP
					MsUnlock()
				Endif
				//-------------------------------
				// FJL - Itens Pre-Ordem de Pago
				//-------------------------------
				DbSelectArea("FJL")
					If FA855SE2->(MsSeek(xFilial("SE2")+oGridPreOP:aCols[nLinPreOP][nPosForn]+oGridPreOP:aCols[nLinPreOP][nPosLoja]))
						While FA855SE2->(!Eof()) .And. FA855SE2->(E2_FORNECE+E2_LOJA) == oGridPreOP:aCols[nLinPreOP][nPosForn]+oGridPreOP:aCols[nLinPreOP][nPosLoja]
							
							SE2->(DbGoTo(FA855SE2->E2_RECNO))
							
							//Verifica se o tํtulo foi excluido da pre-ordem
							If FA855SE2->E2_DELET <> "*"
								
								If FA855SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG
									nSigno := -1
								Else
									nSigno := 1
								EndIf
								
								RecLock("FJL",.T.)
								FJL->FJL_FILIAL	:= XFilial("FJL")
								FJL->FJL_PREOP	:= oGridPreOP:aCols[nLinPreOP][nPosPreOP]
								FJL->FJL_PREFIX	:= FA855SE2->E2_PREFIXO
								FJL->FJL_NUM		:= FA855SE2->E2_NUM
								FJL->FJL_PARCEL	:= FA855SE2->E2_PARCELA
								FJL->FJL_TIPO		:= FA855SE2->E2_TIPO
								FJL->FJL_FORNEC	:= FA855SE2->E2_FORNECE
								FJL->FJL_LOJA		:= FA855SE2->E2_LOJA
								FJL->FJL_VALOR	:= FA855SE2->E2_SALDO
								FJL->FJL_VLRPRE	:= FA855SE2->E2_VALPOP
								FJL->FJL_VLCONV	:= XMoeda(FA855SE2->E2_VALPOP,FA855SE2->E2_MOEDA,Val(cMoeda),dDataBase)
								If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
									For nLoop := 1 To Len(a855Cpos)
										FJL->&(a855Cpos[nLoop][2][1]) := FA855SE2->&(a855Cpos[nLoop][1][2])
									Next
								EndIf
								FJL->(MsUnlock())
								
								If TableInDic("FVC")
									nPosNum := ASCAN(aRetImp855[nLinPreOP][1][1],{|x|x[10]==FA855SE2->E2_NUM .and. AllTrim(x[11]) == AllTrim(FA855SE2->E2_PARCELA)})
									If nPosNum > 0
										DbSelectArea("FVC")
										//Gravado de IVA, SUSS, IIBB
										F855GravRet(oGridPreOP:aCols[nLinPreOP][nPosPreOP],aRetImp855[nLinPreOP][1][1][nPosNum],FA855SE2->E2_FORNECE,FA855SE2->E2_LOJA,FA855SE2->E2_PARCELA)
									EndIf
								EndIf
								
								//-----------------------------
								// Atualiza os dados do titulo
								//-----------------------------
								RecLock("SE2",.F.)
								SE2->E2_PREOP	:= oGridPreOP:aCols[nLinPreOP][nPosPreOP]
								SE2->E2_PREOK	:= "S"
								SE2->E2_VLBXPAR := FA855SE2->E2_VALPOP * nSigno
								SE2->E2_OK		:= ""
								SE2->(MsUnLock())
								
							Else
								RecLock("SE2",.F.)
								SE2->E2_PREOP	:= ""
								SE2->E2_PREOK	:= " "
								SE2->E2_VLBXPAR	:= 0
								SE2->E2_OK		:= ""
								SE2->(MsUnLock())
							EndIf
							
							FA855SE2->(DbSkip())
						EndDo
					EndIf
					
				//Gravado de Gan
				If TableInDic("FVC")
					F855GravRet(oGridPreOP:aCols[nLinPreOP][nPosPreOP],aRetImp855[nLinPreOP][1][2],oGridPreOP:aCols[nLinPreOP][nPosForn],oGridPreOP:aCols[nLinPreOP][nPosLoja],"",.T.)
				EndIf
	
				//------------------------------------
				// FJM - Rateio da Pre-ordens de pago
				//------------------------------------
				DbSelectArea("FJM")
				oBrwRat:aCols := AClone(aColsSavMo[nLinPreOP])
	
				For nX := 1 to Len(oBrwRat:aCols)
					If !Empty(oBrwRat:aCols[nX][nPosMoeda]) .And. !GDDeleted(nX,oBrwRat:aHeader,oBrwRat:aCols)
						FJM->(RecLock("FJM",.T.))
						FJM->FJM_FILIAL	:= XFilial("FJM")
						FJM->FJM_PREOP	:= oGridPreOP:aCols[nLinPreOP][nPosPreOP]
						For nJ:=1 To Len(oBrwRat:aHeader)
							FJM->(FieldPut(ColumnPos(oBrwRat:aHeader[nJ,2]),oBrwRat:aCols[nX,nJ]))
						Next nJ
						FJM->(MsUnLock())
					EndIf
				Next nX
	
				ConfirmSX8()
	
			End Transaction
	
			IF EXISTBLOCK("FA855INC")
				EXECBLOCK("FA855INC",.F.,.F.,{oGridPreOP , nLinPreOP})
			Endif 
		Else
			Help(" ",1,"RECNO")
		EndIf
	
	Next nLinPreOP

Else
	msginfo( STR0142 )
	lReturn := .F.
Endif

aCCORetNoIns    := {}
aSFHNoIns       := {}

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855Alterบ Autor ณ Microsiga          บ Data ณ  03/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a alteracao da Pre-OP                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855Alter()
Local nX 		:= 0
Local nJ		:= 0
Local lReturn 	:= .T.
Local nPosMoeda	:= GDFieldPos("FJM_MOEDA",oBrwRat:aHeader)
Local nLinPreOP	:= oGridPreOP:nAt
Local nPosForn	:= GDFieldPos("FORNECEDOR"	,oGridPreOP:aHeader)
Local nPosLoja	:= GDFieldPos("LOJA"		,oGridPreOP:aHeader)
Local nPosPreOP	:= GDFieldPos("PREOP"		,oGridPreOP:aHeader)
Local nPosValPOP:= GDFieldPos("VALPREOP"	,oGridPreOP:aHeader)
Local nSinal	:= 1
Local nLoop     := 0

//Salva pois as atualizacoes nao refletem na versao final do array
aColsSavMo[oGridPreOP:nAt] := AClone(oBrwRat:aCols)

DbSelectArea("FJK")
FJK->(DbSetOrder(1)) //FJK_FILIAL+FJK_FORNEC+FJK_LOJA+FJK_PREOP
If FJK->(MsSeek(XFilial("FJK")+oGridPreOP:aCols[nLinPreOP][nPosForn]+oGridPreOP:aCols[nLinPreOP][nPosLoja]+oGridPreOP:aCols[nLinPreOP][nPosPreOP]))

	Begin Transaction

		//-----------------------------------
		// FJK - Cabecalho Pre-Ordem de Pago
		//-----------------------------------
		RecLock("FJK",.F.)
		FJK->FJK_MOEDA	:= cMoeda
		FJK->FJK_VLRPRE	:= oGridPreOP:aCols[nLinPreOP][nPosValPOP]
		FJK->FJK_VLCONV := xMoeda(oGridPreOP:aCols[nLinPreOP][nPosValPOP],1,Val(cMoeda),dDataBase)
			If cPaisLoc == 'RUS'
				FJK->FJK_BNKCOD := aDetailRUS[nLinPreOP][_BnkCode]
				FJK->FJK_BIKCOD := aDetailRUS[nLinPreOP][_BikCod]
				FJK->FJK_BKNAME := aDetailRUS[nLinPreOP][_BkName]
				FJK->FJK_DTPLAN := aDetailRUS[nLinPreOP][_DtPlan]
				FJK->FJK_TPPGTO := aDetailRUS[nLinPreOP][_Tppgto]
				FJK->FJK_CONTA  := aDetailRUS[nLinPreOP][_Conta]
				FJK->FJK_RCNAME := aDetailRUS[nLinPreOP][_RcName]
				FJK->FJK_KPPPAY := aDetailRUS[nLinPreOP][_KPPPay]
				FJK->FJK_RECKPP := aDetailRUS[nLinPreOP][_RecKPP]
				FJK->FJK_PRIORI := aDetailRUS[nLinPreOP][_Priori]
				FJK->FJK_REASON := aDetailRUS[nLinPreOP][_Reason]
				FJK->FJK_VATRAT := aDetailRUS[nLinPreOP][_VATRat]
				FJK->FJK_VATAMT := aDetailRUS[nLinPreOP][_VATAmt]
				FJK->FJK_VATCOD := aDetailRUS[nLinPreOP][_VATCod]
			EndIf
		FJK->(MsUnlock())

		//-------------------------------
		// FJL - Itens Pre-Ordem de Pago
		//-------------------------------
		DbSelectArea("FJL")
		DbSetOrder(2) //FJL_FILIAL+FJL_PREOP+FJL_FORNEC+FJL_LOJA+FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO
			If FA855SE2->(MsSeek(xFilial("SE2")+oGridPreOP:aCols[nLinPreOP][nPosForn]+oGridPreOP:aCols[nLinPreOP][nPosLoja]))
				While FA855SE2->(!Eof()) .And. FA855SE2->(E2_FORNECE+E2_LOJA) == oGridPreOP:aCols[nLinPreOP][nPosForn]+oGridPreOP:aCols[nLinPreOP][nPosLoja]
					
					If FJL->(MsSeek(xFilial("FJL")+oGridPreOP:aCols[nLinPreOP][nPosPreOP]+FA855SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)))
						
						If FA855SE2->E2_DELET != "*"
							
							//-------------------------
							// Atualizacao do registro
							//-------------------------
							If FA855SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG
								nSigno := -1
							Else
								nSigno := 1
							EndIf
							
							FJL->(RecLock("FJL",.F.))
							FJL->FJL_VLRPRE	:= FA855SE2->E2_VALPOP
							
							If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
								For nLoop := 1 To Len(a855Cpos)
									FJL->&(a855Cpos[nLoop][2][1]) := FA855SE2->&(a855Cpos[nLoop][1][2])
								Next nX
							EndIf
							
							FJL->(MsUnlock())
							
							If TableInDic("FVC")
								F855DelRet(FJL->FJL_PREOP,FJL->FJL_FORNEC,FJL->FJL_LOJA,FJL->FJL_NUM)
								nPosNum := ASCAN(ASE2[1][1],{|x|x[10]==FA855SE2->E2_NUM})
								If nPosNum > 0
									DbSelectArea("FVC")
									F855GravRet(oGridPreOP:aCols[nLinPreOP][nPosPreOP],ASE2[1][1][nPosNum],FA855SE2->E2_FORNECE,FA855SE2->E2_LOJA,FA855SE2->E2_PARCELA)
								EndIf
							EndIf
							
							//Atualiza o vinculo com a Pre-OP
							SE2->(DbGoTo(FA855SE2->E2_RECNO))
							RecLock("SE2",.F.)
							SE2->E2_PREOP	:= oGridPreOP:aCols[nLinPreOP][nPosPreOP]
							SE2->E2_PREOK	:= "S"
							SE2->E2_VLBXPAR	:= FA855SE2->E2_VALPOP * nSigno
							SE2->E2_OK		:= ""
							SE2->(MsUnlock())
							
						Else
							
							If TableInDic("FVC")
								F855DelRet(FJL->FJL_PREOP,FJL->FJL_FORNEC,FJL->FJL_LOJA,FJL->FJL_NUM)
							EndIF
							
							//----------------------------
							// Exclusao da linha deletada
							//----------------------------
							RecLock("FJL",.F.)
							FJL->(DbDelete())
							FJL->(MsUnlock())
							
							//Remocao do vinculo com a Pre-OP
							SE2->(DbGoTo(FA855SE2->E2_RECNO))
							RecLock("SE2",.F.)
							SE2->E2_PREOP 	:= ""
							SE2->E2_PREOK 	:= " "
							SE2->E2_VLBXPAR := 0
							SE2->E2_OK 		:= ""
							SE2->(MsUnlock())
						EndIf
						
					ElseIf FA855SE2->E2_DELET != "*"
						
						//----------------------
						// Inclusao de registro
						//----------------------
						If FA855SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG
							nSinal := -1
						Else
							nSinal := 1
						EndIf
						
						RecLock("FJL",.T.)
						FJL->FJL_FILIAL	:= XFilial("FJL")
						FJL->FJL_PREOP	:= oGridPreOP:aCols[nLinPreOP][nPosPreOP]
						FJL->FJL_PREFIX	:= FA855SE2->E2_PREFIXO
						FJL->FJL_NUM	:= FA855SE2->E2_NUM
						FJL->FJL_PARCEL	:= FA855SE2->E2_PARCELA
						FJL->FJL_TIPO	:= FA855SE2->E2_TIPO
						FJL->FJL_FORNEC	:= FA855SE2->E2_FORNECE
						FJL->FJL_LOJA	:= FA855SE2->E2_LOJA
						FJL->FJL_VALOR	:= FA855SE2->E2_SALDO
						FJL->FJL_VLRPRE	:= FA855SE2->E2_VALPOP
						FJL->FJL_VLCONV	:= XMoeda(FA855SE2->E2_VALPOP,FA855SE2->E2_MOEDA,Val(cMoeda),dDataBase)
						FJL->(MsUnlock())
						
						//-----------------------------
						// Atualiza os dados do titulo
						//-----------------------------
						SE2->(DbGoTo(FA855SE2->E2_RECNO))
						RecLock("SE2",.F.)
						SE2->E2_PREOP	:= oGridPreOP:aCols[nLinPreOP][nPosPreOP]
						SE2->E2_PREOK	:= "S"
						SE2->E2_VLBXPAR := FA855SE2->E2_VALPOP * nSigno
						SE2->E2_OK		:= ""
						SE2->(MsUnLock())
					EndIf
					
					FA855SE2->(DbSkip())
				EndDo
			EndIf
			
		If TableInDic("FVC")
			//Borrado de registros de ganancias
			F855DelRet(oGridPreOP:aCols[nLinPreOP][nPosPreOP],oGridPreOP:aCols[nLinPreOP][nPosForn],oGridPreOP:aCols[nLinPreOP][nPosLoja],"",.T.)
			//Gravado de registros de ganancias
			F855GravRet(oGridPreOP:aCols[nLinPreOP][nPosPreOP],ASE2[1][2],oGridPreOP:aCols[nLinPreOP][nPosForn],oGridPreOP:aCols[nLinPreOP][nPosLoja],"",.T.)
		EndIf 

		//------------------------------------
		// FJM - Rateio da Pre-ordens de pago
		//------------------------------------
		DbSelectArea("FJM")
		DbSetOrder(1) //FJM_FILIAL+FJM_PREOP+FJM_MOEDA

		oBrwRat:aCols := AClone(aColsSavMo[nLinPreOP])

		For nX := 1 to Len(oBrwRat:aCols)
			If !Empty(oBrwRat:aCols[nX][nPosMoeda])
				If FJM->(MsSeek(XFilial("FJM") + PadR(oGridPreOP:aCols[nLinPreOP][nPosPreOP],12) + GdFieldGet("FJM_MOEDA",nX,,oBrwRat:aHeader,oBrwRat:aCols)))
					FJM->(RecLock("FJM",.F.))
					If !GDDeleted(nX,oBrwRat:aHeader,oBrwRat:aCols)
						For nJ:=1 To Len(oBrwRat:aHeader)
							FJM->(FieldPut(ColumnPos(oBrwRat:aHeader[nJ,2]),oBrwRat:aCols[nX,nJ]))
						Next nJ
					Else
						FJM->(DbDelete())
					EndIf
				ElseIf !GDDeleted(nX,oBrwRat:aHeader,oBrwRat:aCols)
					FJM->(RecLock("FJM",.T.))
					FJM->FJM_FILIAL	:= XFilial("FJM")
					FJM->FJM_PREOP	:= oGridPreOP:aCols[nLinPreOP][nPosPreOP]
					For nJ:=1 To Len(oBrwRat:aHeader)
						FJM->(FieldPut(ColumnPos(oBrwRat:aHeader[nJ,2]),oBrwRat:aCols[nX,nJ]))
					Next nJ
					FJM->(MsUnLock())
				EndIf
			EndIf
		Next nX

	End Transaction
Else
	Help(" ",1,"RECNO")
EndIf
	
Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บAutor  ณ Marylly A. Silva   บ Data ณ  08/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetiva็ใo da Pr้-Ordem de pago para uma Ordem de Pago     บฑฑ
ฑฑบ          ณ (FINA850)                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855OrdPag(cFornOrd,cLojOrd,cPreOrd,cOrdPago)
Local aAreaFJK		:=	FJK->(GetArea())
Local aAreaFJL		:=	FJL->(GetArea())
Local aAreaSE2		:=	SE2->(GetArea())

Default cFornOrd	:= ""
Default cLojOrd		:= ""
Default cPreOrd		:= ""
Default cOrdPago	:= ""

DbSelectArea("FJK")
FJK->(DbSetOrder(1))
If FJK->(MsSeek(xFilial("FJK")+cFornOrd+cLojOrd+cPreOrd))
	RecLock("FJK",.F.)
	FJK->FJK_ORDPAG := cOrdPago
	FJK->(MsUnlock())
	//Exclui referencia SE2
	DbSelectArea("FJL")
	FJL->(DbSetOrder(1)) //FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP
	If FJL->(MsSeek(XFilial("FJL")+cFornOrd+cLojOrd+cPreOrd))
		While !FJL->(Eof()) .And. FJL->(FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP) == XFilial("FJL")+cFornOrd+cLojOrd+cPreOrd
			DbSelectArea("SE2")
			SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			If SE2->(MsSeek(xFilial("SE2")+FJL->(FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO+FJL_FORNEC+FJL_LOJA)))
				RecLock("SE2",.F.)
				SE2->E2_PREOP	:= CriaVar("E2_PREOP",.F.)
				SE2->E2_PREOK	:= CriaVar("E2_PREOK",.F.)
				SE2->E2_VLBXPAR	:= CriaVar("E2_VLBXPAR",.F.)
				SE2->(MsUnlock())
			EndIf
		FJL->(DbSkip())
		EndDo
	EndIf
EndIf

RestArea(aAreaSE2)
RestArea(aAreaFJL)
RestArea(aAreaFJK)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA855VldBr บAutor  ณMicrosiga           บ Data ณ  08/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855VldBr(lMensagem)
Local lReturn	:= .T.

DEFAULT lMensagem := .F.

//Valida a compensa็ใo
If lReturn
	If (nTotTit - nTotRet) < 0
		lReturn := .F.
		If lMensagem
			MsgAlert(STR0046) //"O valor da pre-ordem de pago deve ser maior que 0."
		EndIf
	EndIf
EndIf

Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บ Autor ณ Marylly A. Silva   บ Data ณ  08/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche a data de anแlise da pr้-ordem de pagamento       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855Aprv()
Local nX := 0
Local cFornPre	:= ""
Local cLojaPre	:= ""
Local cCodPre	:= ""
Local lFA855Apr := EXISTBLOCK("FA855Apr")

DbSelectArea("FJK")
FJK->(dbSetOrder(1))
For nX := 1 To Len(oGridPreOP:aCols)

	cFornPre	:= GdFieldGet("FORNECEDOR"	,nX,,oGridPreOP:aHeader,oGridPreOP:aCols)
	cLojaPre	:= GdFieldGet("LOJA"		,nX,,oGridPreOP:aHeader,oGridPreOP:aCols)
	cCodPre		:= GdFieldGet("PREOP"		,nX,,oGridPreOP:aHeader,oGridPreOP:aCols)

	If FJK->(MsSeek(xFilial("FJK")+cFornPre+cLojaPre+cCodPre))
		RecLock("FJK",.F.)
		FJK->FJK_DTANLI := dDataBase
		FJK->(MsUnlock())
		If  lFA855Apr
			EXECBLOCK("FA855Apr",.F.,.F.)
		Endif
	EndIf

Next nX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บ Autor ณMarylly A. Silva    บ Data ณ  08/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche a data de rejei็ใo da pr้-ordem de pagamento      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855Rej()
Local nX := 0
Local cFornPre	:= ""
Local cLojaPre	:= ""
Local cCodPre	:= ""

dbSelectArea("FJK")
FJK->(dbSetOrder(1))
For nX := 1 To Len(oGridPreOP:aCols)

	cFornPre	:= GdFieldGet("FORNECEDOR"	,nX,,oGridPreOP:aHeader,oGridPreOP:aCols)
	cLojaPre	:= GdFieldGet("LOJA"		,nX,,oGridPreOP:aHeader,oGridPreOP:aCols)
	cCodPre		:= GdFieldGet("PREOP"		,nX,,oGridPreOP:aHeader,oGridPreOP:aCols)

	If FJK->(MsSeek(xFilial("FJK")+cFornPre+cLojaPre+cCodPre))
		//----------------------------------
		// Remove a referencia com o titulo
		//----------------------------------
		DbSelectArea("FJL")
		FJL->(DbSetOrder(1))
		If FJL->(MsSeek(xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)))
			While FJL->(!Eof()) .And. FJL->(FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP) == xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)
				DbSelectArea("SE2")
				DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If MsSeek(XFilial("SE2")+FJL->(FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO+FJL_FORNEC+FJL_LOJA))
					RecLock("SE2",.F.)
					SE2->E2_PREOP	:= ""
					SE2->E2_PREOK	:= " "
					SE2->E2_VLBXPAR	:= 0
					SE2->E2_OK		:= ""
					SE2->(MsUnlock())
				EndIf
			FJL->(DbSkip())
			EndDo
		EndIf

		RecLock("FJK",.F.)
			FJK->FJK_DTCANC := dDataBase
		FJK->(MsUnlock())
	EndIf

Next nX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บ Autor ณ Marylly A. Silva   บ Data ณ  08/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancela a aprova็ใo ou rejeita a pr้-ordem de pagamento    บฑฑ
ฑฑบ          ณ caso nใo tenha ocorrido a aprova็ใo anteriormente          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855Canc()
Local nX := 0
Local cFornPre	:= ""
Local cLojaPre	:= ""
Local cCodPre	:= ""
Local lFA855Can := EXISTBLOCK("FA855Can")

DbSelectArea("FJK")
FJK->(dbSetOrder(1))
For nX := 1 To Len(oGridPreOP:aCols)

	cFornPre	:= GdFieldGet("FORNECEDOR"	,nX,,oGridPreOP:aHeader,oGridPreOP:aCols)
	cLojaPre	:= GdFieldGet("LOJA"		,nX,,oGridPreOP:aHeader,oGridPreOP:aCols)
	cCodPre		:= GdFieldGet("PREOP"		,nX,,oGridPreOP:aHeader,oGridPreOP:aCols)

	If FJK->(MsSeek(xFilial("FJK")+cFornPre+cLojaPre+cCodPre))

		If !Empty(FJK->FJK_DTANLI)
			RecLock("FJK",.F.)
			FJK->FJK_DTANLI := CToD("  /  /  ")
			FJK->(MsUnlock())
			If  lFA855Can
				EXECBLOCK("FA855Can",.F.,.F.)                                            
			Endif
		Else

			//----------------------------------
			// Remove a referencia com o titulo
			//----------------------------------
			DbSelectArea("FJL")
			FJL->(DbSetOrder(1))
			If FJL->(MsSeek(xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)))
				While FJL->(!Eof()) .And. FJL->(FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP) == xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)
					DbSelectArea("SE2")
					DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
					If MsSeek(XFilial("SE2")+FJL->(FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO+FJL_FORNEC+FJL_LOJA))
						RecLock("SE2",.F.)
						SE2->E2_PREOP	:= ""
						SE2->E2_PREOK	:= " "
						SE2->E2_VLBXPAR	:= 0
						SE2->E2_OK		:= ""
						SE2->(MsUnlock())
					EndIf
				FJL->(DbSkip())
				EndDo
			EndIf
			
			//Al cancelar la Orden de Pago Previa se borran los registros correspondientes de las Retenciones
			If TableInDic("FVC")
				DBSELECTAREA("FVC")
				FVC->(DBSETORDER(1)) //FVC_FILIAL+FVC_PREOP+FVC_TIPO
				If FVC->(MsSeek(xFilial("FVC")+FJK->FJK_PREOP))
					While FVC->(!Eof()) .and. FJK->FJK_PREOP == FVC->FVC_PREOP
						RecLock("FVC",.F.)
						FVC->(DbDelete())
						FVC->(MsUnlock())
						FVC->(DbSkip())
					Enddo
				EndIf
			EndIf

			RecLock("FJK",.F.)
			FJK->FJK_DTCANC := dDataBase
			FJK->(MsUnlock())
		EndIf

	EndIf

Next nX

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA855Excl  บAutor  ณMicrosiga           บ Data ณ  08/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de exclusao da Pre-OP                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855Excl()
Local nLinPreOP	:= oGridPreOP:nAt
Local nPosForn	:= GDFieldPos("FORNECEDOR"	,oGridPreOP:aHeader)
Local nPosLoja	:= GDFieldPos("LOJA"		,oGridPreOP:aHeader)
Local nPosPreOP	:= GDFieldPos("PREOP"		,oGridPreOP:aHeader)

SE2->(DbSetOrder(1))

DbSelectArea("FJK")
FJK->(DbSetOrder(1)) //FJK_FILIAL+FJK_FORNEC+FJK_LOJA+FJK_PREOP
If FJK->(MsSeek(XFilial("FJK")+oGridPreOP:aCols[nLinPreOP][nPosForn]+oGridPreOP:aCols[nLinPreOP][nPosLoja]+oGridPreOP:aCols[nLinPreOP][nPosPreOP]))

	Begin Transaction
		//-------------------------------
		// FJL - Itens Pre-Ordem de Pago
		//-------------------------------
		DbSelectArea("FJL")
		DbSetOrder(1) //FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP
		If FJL->(MsSeek(xFilial("FJL") + FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)))
			While FJL->(!Eof()) .And. FJL->(FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP) == xFilial("FJL")+FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)

				// Remove o vinculo com a SE2
				If SE2->(MsSeek(xFilial("SE2")+FJL->(FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO+FJL_FORNEC+FJL_LOJA)))
					RecLock("SE2",.F.)
					SE2->E2_PREOP	:= ""
					SE2->E2_PREOK	:= " "
					SE2->E2_VLBXPAR	:= 0
					SE2->E2_OK		:= ""
					SE2->(MsUnlock())
				EndIf
				
				//Borrado de Retenci๓n de IVA, SUSS, IIBB
				If TableInDic("FVC")
					F855DelRet(FJL->FJL_PREOP,FJL->FJL_FORNEC,FJL->FJL_LOJA,FJL->FJL_NUM)
				EndIf

				RecLock("FJL",.F.)
				FJL->(DbDelete())
				FJL->(MsUnlock())

			FJL->(DbSkip())
			EndDo
		EndIf
		
		//Borrado de Retenci๓n de Ganancias
		If TableInDic("FVC")
			F855DelRet(oGridPreOP:aCols[nLinPreOP][nPosPreOP],oGridPreOP:aCols[nLinPreOP][nPosForn],oGridPreOP:aCols[nLinPreOP][nPosLoja],"",.T.)
		EndIf

		//------------------------------------
		// FJM - Rateio da Pre-ordens de pago
		//------------------------------------
		DbSelectArea("FJM")
		DbSetOrder(1) //FJM_FILIAL+FJM_PREOP+FJM_MOEDA
		If FJM->(MsSeek(xFilial("FJM")+FJK->FJK_PREOP))
			While FJM->(!Eof()) .And. FJM->(FJM_FILIAL+FJM_PREOP) == xFilial("FJM")+FJK->FJK_PREOP
				FJM->(RecLock("FJM",.F.))
				FJM->(DbDelete())
				FJM->(MsUnLock())
			FJM->(DbSkip())
			EndDo
		EndIf

		//-----------------------------------
		// FJK - Cabecalho Pre-Ordem de Pago
		//-----------------------------------
		RecLock("FJK",.F.)
		FJK->(DbDelete())
		FJK->(MsUnlock())

	End Transaction

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บ Autor ณMicrosiga           บ Data ณ  29/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se a moeda informada na pr้-ordem de pagamento eh   บฑฑ
ฑฑบ          ณ utilizada por algum banco                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FinMoedBco(nMoeda,cFilMoeda)
Local lRet			:= .F.
Local aArea			:= GetArea()
Local aAreaSA6		:= Eval({|| DbSelectArea("SA6"), SA6->(GetArea())})

Default nMoeda		:= 1
Default cFilMoeda	:= xFilial("SA6")

SA6->(DbSetOrder(1))
SA6->(MsSeek(cFilMoeda))
While SA6->(!EOF()) .And. cFilMoeda == SA6->A6_FILIAL
	If SA6->A6_MOEDA == nMoeda
		lRet := .T.
		Exit
	EndIf
	SA6->(DbSkip())
EndDo

If !lRet
	Help(" ",1,"NOMOEDABCO",,STR0073,1,0) // "Nใo existe banco utilizando moeda selecionada. Selecione outra moeda"
EndIf

RestArea(aAreaSA6)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA855  บ Autor ณ Marylly A. Silva   บ Data ณ  12/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os valores convertidos nos tํtulos selecinados na บฑฑ
ฑฑบ          ณ pr้-ordem de pagamento e valores da distribui็ใo de moedas บฑฑ
ฑฑบ          ณ na altera็ใo da moeda da pr้-ordem de pagamento ou na      บฑฑ
ฑฑบ          ณ atualiza็ใo de sele็ใo de tํtulos a pagar da pr้-ordem de  บฑฑ
ฑฑบ          ณ pagamento.												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F855AtuRat()
Local lRet			:= .T.
Local lBrwRat		:= (ValType(oBrwRat) != "U")
Local lBrwTit		:= (ValType(oBrwTit) != "U")
Local nLinCol		:= oBrwRat:oBrowse:nAt
Local nPosMoeda		:= GDFieldPos("FJM_MOEDA"	,oBrwRat:aHeader)
Local nPosPerc		:= GDFieldPos("FJM_PERC"	,oBrwRat:aHeader)
Local nPosVlConv	:= GDFieldPos("FJM_VLCONV"	,oBrwRat:aHeader)
Local nPosTaxa		:= GDFieldPos("FJM_TAXA"	,oBrwRat:aHeader)
Local nPosVlMdOP	:= GDFieldPos("FJM_VLMDOP"	,oBrwRat:aHeader)
Local nPercRateio	:= 0
Local nMoedRateio	:= 0
Local nPosValPre	:= 0
Local nPosVlCv		:= 0
Local nPosVlPre		:= 0
Local nPosVlPrCv	:= 0
Local nMoedTit		:= 0
Local cVariavel		:= ReadVar()
Local nPosLinha		:= 0
Local aAreaSE2		:= {}
Local cFilSE2		:= XFilial("SE2")
Local nValPreOP		:= oGridPreOP:aCols[oGridPreOP:nAt][GDFieldPos("VALPREOP",oGridPreOP:aHeader)]
Local nI			:= 0
Local nTotalPerc	:= 0

If lBrwRat .And. (INCLUI .Or. ALTERA) .And. Len(oBrwRat:aCols) > 0

	//--------------------
	// Alteracao da moeda
	//--------------------
	
	If AllTrim(cVariavel) == "M->FJM_MOEDA" .And. !GdDeleted(nLinCol,oBrwRat:aHeader,oBrwRat:aCols) .And. GdFieldGet("FJM_MOEDA") != M->FJM_MOEDA

		If cPaisLoc == "ARG" .and. nLinCol > 1
			oBrwRat:aCols[nLinCol][1]:= oBrwRat:aCols[1][1]
		Endif

		If (nPosLinha := aScan(oBrwRat:aCols,{|x| x[nPosMoeda] == M->FJM_MOEDA})) > 0 .And. !GdDeleted(nPosLinha,oBrwRat:aHeader,oBrwRat:aCols)
			MsgAlert(STR0074) // "Moeda jแ informada na distribu็ใo da pr้-ordem de pago."
			lRet := .F.
		Else
			nPercRateio	:= GdFieldGet("FJM_PERC")/100
			nMoedRateio	:= Val(M->FJM_MOEDA)

			GDFieldPut("FJM_TAXA"	,RecMoeda(dDataBase,nMoedRateio))
			GDFieldPut("FJM_VLCONV"	,XMoeda(nValPreOP,1,nMoedRateio, dDataBase, 4, , GdFieldGet("FJM_TAXA",nLinCol)) * nPercRateio)
			GDFieldPut("FJM_MOEDA"	,M->FJM_MOEDA)
		EndIf

	//-------------------------
	// Alteracao do percentual
	//-------------------------
	ElseIf AllTrim(cVariavel) == "M->FJM_PERC" .And. !GDDeleted(nLinCol,oBrwRat:aHeader,oBrwRat:aCols) .And. GdFieldGet("FJM_PERC") != M->FJM_PERC
		For nI := 1 To Len(oBrwRat:aCols)
			If !GdDeleted(nI,oBrwRat:aHeader,oBrwRat:aCols) .And. nI != nLinCol
				nTotalPerc 	+= GdFieldGet("FJM_PERC",nI)
			EndIf
		Next nI

		If (nTotalPerc+M->FJM_PERC) > 100
			Help(" ", 1,"F855PERC",, STR0072,1,0) // "Porcentagem informada acima da porcentagem a ser ditribuida"
			lRet := .F.
		EndIf

		If lRet
			// % a distribuir
			oSay21:cTitle := Transform(100 - (nTotalPerc+M->FJM_PERC),PesqPict("FJM","FJM_PERC"))
			oSay21:Refresh()

			//% distribuido
			oSay31:cTitle := Transform((nTotalPerc+M->FJM_PERC),PesqPict("FJM","FJM_PERC"))
			oSay31:Refresh()

			nPercRateio	:= (M->FJM_PERC)/100
			nMoedRateio	:= Val(GdFieldGet("FJM_MOEDA"))

			GDFieldPut("FJM_VLCONV"	,XMoeda(nValPreOP,1,nMoedRateio,dDataBase,4,,GdFieldGet("FJM_TAXA",nLinCol)) * nPercRateio)
			GDFieldPut("FJM_VLMDOP"	,xMoeda(nValPreOP,1,Val(cMoeda),dDatabase) * nPercRateio)
			GDFieldPut("FJM_PERC"	,M->FJM_PERC)
		EndIf

	//-------------------
	// Alteracao da taxa
	//-------------------
	ElseIf AllTrim(cVariavel) == "M->FJM_TAXA" .And. GdFieldGet("FJM_TAXA") != M->FJM_TAXA
		nMoedRateio	:= Val(GdFieldGet("FJM_MOEDA"))
		nPercRateio	:= GdFieldGet("FJM_PERC")/100

		If  M->FJM_TAXA <= 0
			MsgAlert(STR0079) //"O valor da taxa informada ้ invแlido."
			lRet := .F.
		ElseIf oBrwRat:aCols[nLinCol][nPosMoeda] == cMoeda .Or. Val(oBrwRat:aCols[nLinCol][nPosMoeda]) == 1
			MsgAlert(STR0080) //"A taxa da moeda nใo pode ser alterada."
			lRet := .F.
		Else
			GDFieldPut("FJM_VLCONV"	,XMoeda(nValPreOP,1,nMoedRateio,dDataBase,4,,M->FJM_TAXA) * nPercRateio)
			GDFieldPut("FJM_TAXA"	,M->FJM_TAXA)
		EndIf
	EndIf

	oBrwRat:Refresh()

	//--------------------------------------
	// Armazena a estrutura de distribuicao
	// ao navegar entre as Pre-OP's
	//--------------------------------------
	aColsSavMo[oGridPreOP:nAt] := AClone(oBrwRat:aCols)

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F855AtCl บ Autor ณ Marylly A. Silva   บ Data ณ  13/01/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca ou Desmarca todos os tํtulos na sele็ใo de tํtulos a บฑฑ
ฑฑบ          ณ a pagar da pr้-ordem de pagamento.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F855AtCl(lCheck)

Local aArea		:= GetArea()
Local aAreaCSE2 := F855TMP->(GetArea())

Local lTestCQ := .F.
Local lAbleCQ := GetNewPar( "MV_FINCQ" , .F. )  //Habilita ou nao a Verificacao de Qualidade

If cPaisLoc=="ARG" .And. SE2->(ColumnPos("E2_CCR")) > 0  .and. !Empty(MV_PAR10)
	Return Nil
EndIf

F855TMP->( DbGoTop() )

While !F855TMP->(Eof())

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Argentina - Executa a verificacao de Material em Controle de Qualidade ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   If lAbleCQ

      lTestCQ := .F.
      //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
      //ณ Nao quero que acione a verificacao se ja estiver marcado ณ
      //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
      If F855TMP->E2_OK != cMarca

         lTestCQ := OnOrRejQA( F855TMP->E2_NUM, F855TMP->E2_PREFIXO, F855TMP->E2_FORNECE, F855TMP->E2_LOJA )

      EndIf

      If !lTestCQ
         //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
         //ณ Titulo Liberado para a Selecao ณ
         //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	     Reclock("F855TMP",.F.)

           If F855TMP->E2_OK != cMarca
		      F855TMP->E2_OK := cMarca
	       Else
		      F855TMP->E2_OK := CriaVar("E2_OK",.F.)
	       EndIf

         F855TMP->(MsUnlock())

      EndIf

   Else

		Reclock("F855TMP",.F.)

       If F855TMP->E2_OK != cMarca
		   If cPaisLoc == "ARG"
        		If VldDocPag(F855TMP->E2_RECNO, .F.)
					F855TMP->E2_OK := cMarca
				EndIf
        	Else
		   		F855TMP->E2_OK := cMarca
		   	EndIf
	    Else
		   F855TMP->E2_OK := CriaVar("E2_OK",.F.)
	    EndIf

      F855TMP->(MsUnlock())

   EndIf

   F855TMP->( DbSkip() )

EndDo

RestArea(aArea)
RestArea(aAreaCSE2)

oBrwSTit:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บAutor  ณMicrosiga           บ Data ณ  05/23/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F855RecMoed()
Local nLinCol		:= 0
Local nPosVlMdOP	:= 0
Local nPosVlConv	:= 0
Local nPosTaxa		:= 0
Local nPosPerc		:= 0
Local nPosMoeda		:= 0

If ValType(OBRWRAT) != "U"
	nPosVlMdOP	:= aScan(oBrwRat:aHeader,{ | x | AllTrim(x[2]) == "FJM_VLMDOP" })
	nPosVlConv	:= aScan(oBrwRat:aHeader,{ | x | AllTrim(x[2]) == "FJM_VLCONV" })
	nPosTaxa	:= aScan(oBrwRat:aHeader,{ | x | AllTrim(x[2]) == "FJM_TAXA" })
	nPosPerc	:= aScan(oBrwRat:aHeader,{ | x | AllTrim(x[2]) == "FJM_PERC" })
	nPosMoeda	:= aScan(oBrwRat:aHeader,{ | x | AllTrim(x[2]) == "FJM_MOEDA" })


	For nLinCol := 1 To Len(oBrwRat:aCols)
		If !oBrwRat:aCols[nLinCol][Len(oBrwRat:aHeader)+1]
			nPercRateio	:= oBrwRat:aCols[nLinCol][nPosPerc]/100
			nMoedRateio	:= Iif(!EMPTY(oBrwRat:aCols[nLinCol][nPosMoeda]),VAL(oBrwRat:aCols[nLinCol][nPosMoeda]),0)

			oBrwRat:aCols[nLinCol][nPosVlMdOP]	:= xMoeda(nTotTit,1,Val(cMoeda),dDatabase) * nPercRateio
			oBrwRat:aCols[nLinCol][nPosTaxa] 	:= RecMoeda(dDataBase,nMoedRateio)
			oBrwRat:aCols[nLinCol][nPosVlConv]	:= xMoeda(oBrwRat:aCols[nLinCol][nPosVlMdOP],Val(cMoeda), nMoedRateio, ddatabase, 4, , oBrwRat:aCols[nLinCol][nPosTaxa])
		EndIf
	Next nLinCol

	oBrwRat:Refresh()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa855Temp บ Autor ณ Microsiga          บ Data ณ  26/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria a tabela temporaria FA855SE2 para manipulacao dos     บฑฑ
ฑฑบ          ณ titulos                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa855Temp()
Local aStruct	:= {}
Local nX        := 0

AAdd( aStruct, {"E2_FILIAL"		,"C", TamSX3("E2_FILIAL")[1]	,TamSX3("E2_FILIAL")[2]		} )
AAdd( aStruct, {"E2_PREFIXO"	,"C", TamSX3("E2_PREFIXO")[1]	,TamSX3("E2_PREFIXO")[2]	} )
AAdd( aStruct, {"E2_NUM"		,"C", TamSX3("E2_NUM")[1]		,TamSX3("E2_NUM")[2]		} )
AAdd( aStruct, {"E2_PARCELA"	,"C", TamSX3("E2_PARCELA")[1]	,TamSX3("E2_PARCELA")[2]	} )
AAdd( aStruct, {"E2_TIPO"		,"C", TamSX3("E2_TIPO")[1]		,TamSX3("E2_TIPO")[2]		} )
AAdd( aStruct, {"E2_NATUREZ"	,"C", TamSX3("E2_NATUREZ")[1]	,TamSX3("E2_NATUREZ")[2]	} )
AAdd( aStruct, {"E2_FORNECE"	,"C", TamSX3("E2_FORNECE")[1]	,TamSX3("E2_FORNECE")[2]	} )
AAdd( aStruct, {"E2_LOJA"		,"C", TamSX3("E2_LOJA")[1]		,TamSX3("E2_LOJA")[2]		} )
AAdd( aStruct, {"E2_NOMFOR"		,"C", TamSX3("E2_NOMFOR")[1]	,TamSX3("E2_NOMFOR")[2]		} )
AAdd( aStruct, {"E2_EMISSAO"	,"D", TamSX3("E2_EMISSAO")[1]	,TamSX3("E2_EMISSAO")[2]	} )
AAdd( aStruct, {"E2_VENCTO"		,"D", TamSX3("E2_VENCTO")[1]	,TamSX3("E2_VENCTO")[2]		} )
AAdd( aStruct, {"E2_VENCREA"	,"D", TamSX3("E2_VENCREA")[1]	,TamSX3("E2_VENCREA")[2]	} )
AAdd( aStruct, {"E2_VALOR"		,"N", TamSX3("E2_VALOR")[1]		,TamSX3("E2_VALOR")[2]		} )
	If cPaisLoc == 'RUS'
		AAdd( aStruct, {"E2_BASIMP1"	,"N", TamSX3("E2_BASIMP1")[1]	,TamSX3("E2_BASIMP1")[2]	} )
		AAdd( aStruct, {"E2_ALQIMP1"	,"N", TamSX3("E2_ALQIMP1")[1]	,TamSX3("E2_ALQIMP1")[2]	} )
		AAdd( aStruct, {"E2_VALIMP1"	,"N", TamSX3("E2_VALIMP1")[1]	,TamSX3("E2_VALIMP1")[2]	} )
		AAdd( aStruct, {"E2_MDCONTR"	,"C", TamSX3("E2_MDCONTR")[1]	,TamSX3("E2_MDCONTR")[2]	} )
	EndIf
AAdd( aStruct, {"E2_SALDO"		,"N", TamSX3("E2_SALDO")[1]		,TamSX3("E2_SALDO")[2]		} )
AAdd( aStruct, {"E2_OK"			,"C", TamSX3("E2_OK")[1]		,TamSX3("E2_OK")[2]			} )
AAdd( aStruct, {"E2_MOEDA"		,"N", TamSX3("E2_MOEDA")[1]		,TamSX3("E2_MOEDA")[2]		} )
AAdd( aStruct, {"E2_DATALIB"	,"D", TamSX3("E2_DATALIB")[1]	,TamSX3("E2_DATALIB")[2]	} )
AAdd( aStruct, {"E2_PREOK"		,"C", TamSX3("E2_PREOK")[1]		,TamSX3("E2_PREOK")[2]		} )
AAdd( aStruct, {"E2_TXMOEDA"	,"N", TamSX3("E2_TXMOEDA")[1]	,TamSX3("E2_TXMOEDA")[2]	} )
AAdd( aStruct, {"E2_VLBXPAR"	,"N", TamSX3("E2_VLBXPAR")[1]	,TamSX3("E2_VLBXPAR")[2]	} )
AAdd( aStruct, {"E2_PREOP"		,"C", TamSX3("E2_PREOP")[1]		,TamSX3("E2_PREOP")[2]		} )
AAdd( aStruct, {"E2_STATLIB"	,"C", TamSX3("E2_STATLIB")[1]	,TamSX3("E2_STATLIB")[2]	} )
AAdd( aStruct, {"E2_RECNO"		,"N", 09						,0					   		} )
AAdd( aStruct, {"E2_DELET"		,"C", 01						,0					  		} )
AAdd( aStruct, {"E2_VALPOP"		,"N", TamSX3("E2_SALDO")[1]		,TamSX3("E2_SALDO")[2]		} )
AAdd( aStruct, {"E2_MOEPOP"		,"C", 2							,0					  		} )

If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
	For nX := 1 To Len(a855Cpos)
		Aadd(aStruct,{a855Cpos[nX][1][2], a855Cpos[nX][1][8], a855Cpos[nX][1][4], a855Cpos[nX][1][5]})
	Next nX 
EndIf

aOrdem	:=	STRTOKARR ( ALLTRIM( SE2->(IndexKey(6)) ) , "+" )//JGR
oTmpSE2 := FWTemporaryTable():New("FA855SE2") //JGR
oTmpSE2:SetFields( aStruct )
oTmpSE2:AddIndex("I1", aOrdem)
oTmpSE2:Create()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855Atu  บ Autor ณ Microsiga          บ Data ณ  26/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os Objetos.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855Atu(cProcesso)
Local lRet			:= .T.

Default cProcesso	:= ""

Do Case
	//------------------------------------
	// Abertura da tela ou adicao/remocao
	// de titulos via MarkBrowse
	//------------------------------------
	Case cProcesso == "AddTit"

		FA855AtPOP()	//Atualiza a grid de dados da Pre-OP

		FA855AtFor()	//Atualiza os dados do fornecedor

		FA855AtTit()	//Atualiza a grid dos titulos

		Fa855AtRet()	//Atualiza a grid retencoes

		Fa855AtTot()	//Atualiza a grid totalizadores

		FA855AtMoe()	//Atualiza a grid distribuicao moedas

	//--------------------------------
	// Navegacao na grid Fornecedores
	//--------------------------------
	Case cProcesso == "GridPreOP"

		FA855AtFor()	//Atualiza os dados do fornecedor

		FA855AtTit()	//Atualiza a grid dos titulos

		Fa855AtRet()	//Atualiza a grid retencoes

		Fa855AtTot()	//Atualiza a grid totalizadores

		FA855AtMoe()	//Atualiza a grid distribuicao moedas

	//-----------------------------------
	// Definicao da moeda para conversao
	//-----------------------------------
	Case cProcesso == "Moeda"

		FA855AtTit()	//Atualiza a grid dos titulos

		Fa855AtTot()	//Atualiza a grid totalizadores

		FA855AtMoe()	//Atualiza a grid distribuicao moedas

	//----------------------------------------
	// Alteracao do valor de titulo da Pre-OP
	//----------------------------------------
	Case cProcesso == "VALPRE"

		FA855AtPre()	//Atualiza os dados da Pre-OP

		Fa855AtRet()	//Atualiza a grid retencoes

		Fa855AtTot()	//Atualiza a grid totalizadores

		FA855AtMoe()	//Atualiza a grid distribuicao moedas

	//------------------------------
	// Remocao de titulos da Pre-OP
	//------------------------------
	Case cProcesso == "DelTit"

		FA855AtPOP()	//Atualiza a grid de dados da Pre-OP

		Fa855AtRet()	//Atualiza a grid retencoes

		Fa855AtTot()	//Atualiza a grid totalizadores

		FA855AtMoe()	//Atualiza a grid distribuicao moedas

EndCase

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855AtPreบ Autor ณ Microsiga          บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os dados da grid Pre-OP                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855AtPre()
Local nValTit		:= 0
Local nX			:= 0
Local nValRet		:= 0
Local aTitulos		:= {}
Local nSinal		:= 1
Local nPosRecSE2	:= Len(oBrwTit:aHeader)+1
Local nValPreOP		:= 0

For nX := 1 To Len(oBrwTit:aCols)

	If !(oBrwTit:aCols[nX][Len(oBrwTit:aCols[nX])])

		SE2->(DbGoTo(oBrwTit:aCols[nX][nPosRecSE2]))

		If SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG
			nSinal := -1
		Else
			nSinal := 1
		EndIf

		//------------------------------------
		// Armazena o valor total dos titulos
		//------------------------------------
		nValTit += (XMoeda(GdFieldGet("VALPRE",nX),Val(GdFieldGet("MOEDA",nX)),1,dDataBase))

		AAdd(aTitulos,{SE2->E2_FILIAL,SE2->E2_FORNECE,SE2->E2_LOJA, SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->(Recno()),GdFieldGet("VALPRE",nX)*nSinal,SE2->E2_FORNECE,SE2->E2_LOJA,"","","","",""})
	EndIf

Next nX

//-----------------------------
// Obtem o valor das retencoes
//-----------------------------
FA855Reten(aTitulos,,@nValRet)

//----------------------------
// Efetua o calculo da Pre-OP
//----------------------------
nValPreOp := nValTit - nValRet

GdFieldPut("VALPREOP",nValPreOp,oGridPreOP:nAt,oGridPreOP:aHeader,oGridPreOP:aCols)

oGridPreOP:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855AtForบ Autor ณ Microsiga          บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os dados da enchoice fornecedor                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855AtFor()
Local aArea		:= GetArea()
Local aAreaSA2	:= Eval({||DbSelectArea("SA2"),SA2->(GetArea())})

SA2->(DbSetOrder(1))
If MsSeek(XFilial("SA2")+oGridPreOP:aCols[oGridPreOP:nAt][1]+oGridPreOP:aCols[oGridPreOP:nAt][2])
	cFornece	:= SA2->A2_COD
	cLoja		:= SA2->A2_LOJA
	cRazSocial	:= SA2->A2_NOME
	cEndosso	:= X3Combo("A2_ENDOSSO",SA2->A2_ENDOSSO)
EndIf

	If FA855SE2->(MsSeek(XFilial("SE2")+oGridPreOP:aCols[oGridPreOP:nAt][1]+oGridPreOP:aCols[oGridPreOP:nAt][2]))
		While FA855SE2->(!Eof()) .And. FA855SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA) == XFilial("SE2")+oGridPreOP:aCols[oGridPreOP:nAt][1]+oGridPreOP:aCols[oGridPreOP:nAt][2]
			If FA855SE2->E2_PREOP == oGridPreOP:aCols[oGridPreOP:nAt][3]
				cMoeda := FA855SE2->E2_MOEPOP
				Exit
			EndIf
			FA855SE2->(DbSkip())
		EndDo
	EndIf

oEnch:Refresh()

RestArea(aAreaSA2)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855AtTitบ Autor ณ Microsiga          บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os dados da grid de titulos                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855AtTit()
Local cCodPre := GdFieldGet("PREOP",oGridPreOP:nAt,,oGridPreOP:aHeader,oGridPreOP:aCols)
Local nX := 0
Local aColsAnt := oBrwTit:aCols

If FA855SE2->(MsSeek(XFilial("SE2")+oGridPreOP:aCols[oGridPreOP:nAt][1]+oGridPreOP:aCols[oGridPreOP:nAt][2]))
	
	oBrwTit:aCols := {}
	
	While FA855SE2->(!Eof()) .And. FA855SE2->(E2_FORNECE+E2_LOJA) == oGridPreOP:aCols[oGridPreOP:nAt][1]+oGridPreOP:aCols[oGridPreOP:nAt][2]
		
		If !INCLUI .And. FA855SE2->E2_PREOP != cCodPre
			FA855SE2->(DbSkip())
			Loop
		EndIf
		
		If FA855SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG
			nSigno := -1
		Else
			nSigno := 1
		EndIf
		If cPaisLoc == "RUS"
			Aadd(oBrwTit:aCols,{FA855SE2->E2_TIPO																,;//Tipo
			FA855SE2->E2_PREFIXO															,;//Prefixo
			FA855SE2->E2_NUM																,;//Numero
			FA855SE2->E2_PARCELA															,;//Parcela
			FA855SE2->E2_VENCTO																,;//Vencimenro
			FA855SE2->E2_SALDO * nSigno														,;//Saldos
			StrZero(FA855SE2->E2_MOEDA,2)													,;//Moeda
			FA855SE2->E2_VALPOP * nSigno													,;//Valor Pre-Ordem
			xMoeda(FA855SE2->E2_VALPOP,FA855SE2->E2_MOEDA,Val(cMoeda),dDataBase) * nSigno	,;//Valor Convertido
			FA855SE2->E2_BASIMP1													,;
				FA855SE2->E2_ALQIMP1													,;
				FA855SE2->E2_VALIMP1													,;
				FA855SE2->E2_MDCONTR													,;
				FA855SE2->E2_RECNO																,;//RECNO
			.F.})																			//Exclusao - .T. ou .F.
		Else
			Aadd(oBrwTit:aCols,{FA855SE2->E2_TIPO																,;//Tipo
			FA855SE2->E2_PREFIXO															,;//Prefixo
			FA855SE2->E2_NUM																,;//Numero
			FA855SE2->E2_PARCELA															,;//Parcela
			FA855SE2->E2_VENCTO																,;//Vencimenro
			FA855SE2->E2_SALDO * nSigno														,;//Saldos
			StrZero(FA855SE2->E2_MOEDA,2)													,;//Moeda
			FA855SE2->E2_VALPOP * nSigno													,;//Valor Pre-Ordem
			xMoeda(FA855SE2->E2_VALPOP,FA855SE2->E2_MOEDA,Val(cMoeda),dDataBase) * nSigno	})//Valor Convertido
			If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
				For nX := 1 To Len(a855Cpos)
					Aadd(oBrwTit:aCols[Len(oBrwTit:aCols)],FA855SE2->&(a855Cpos[nX][1][2]))//Space(a855Cpos[nX][1][4])
				Next nX
			EndIf
			Aadd(oBrwTit:aCols[Len(oBrwTit:aCols)],FA855SE2->E2_RECNO)						  //RECNO
			Aadd(oBrwTit:aCols[Len(oBrwTit:aCols)],IIF ( aScan(aColsAnt, { |x,y| x[10] == FA855SE2->E2_RECNO }) != 0, aColsAnt[aScan(aColsAnt, { |x,y| x[10] == FA855SE2->E2_RECNO }),11] , .F. ))
		EndIf
		
		FA855SE2->(DbSkip())
	EndDo
	
	oBrwTit:Refresh()
	
EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855AtRetบ Autor ณ Microsiga          บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os dados da grid de retencoes                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855AtRet()
Local nPosRecSE2	:= Len(oBrwTit:aHeader)+1
Local nPosValTit	:= AScan(oBrwTit:aHeader,{|x| AllTrim(x[2]) == "VALPRE"})
Local nX			:= 0
Local aTitulos		:= {}
Local aRetencoes	:= {}

For nX := 1 To Len(oBrwTit:aCols)

	//------------------------
	// Desconsidera deletados
	//------------------------
	If oBrwTit:aCols[nX][Len(oBrwTit:aCols[nX])]
		Loop
	EndIf

	SE2->(DbGoTo(oBrwTit:aCols[nX][nPosRecSE2]))

	If SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG
		nSigno := -1
	Else
		nSigno := 1
	EndIf

		AAdd(aTitulos,{ ;
			SE2->E2_FILIAL, ;
			SE2->E2_FORNECE, ;
			SE2->E2_LOJA, ;
			SE2->E2_PREFIXO, ;
			SE2->E2_NUM, ;
			SE2->E2_PARCELA, ;
			SE2->E2_TIPO, ;
			SE2->(Recno()), ;
			oBrwTit:aCols[nX][nPosValTit]*nSigno, ;
			SE2->E2_FORNECE, ;
			SE2->E2_LOJA, ;
			IIf(cPaisLoc == "RUS", SE2->E2_BASIMP1, Nil), ;
			IIf(cPaisLoc == "RUS", SE2->E2_ALQIMP1, Nil), ;
			IIf(cPaisLoc == "RUS", SE2->E2_VALIMP1, Nil), ;
			SE2->E2_MDCONTR,;
			""})
		
	Next nX

oGridRet:aCols := {}

FA855Reten(aTitulos,@aRetencoes,,.T.)

For nX := 1 To Len(aRetencoes)
	If cPaisLoc == "ARG" .and. (TableInDic("FVC") .and. FVC->(ColumnPos("FVC_TIPO") * ColumnPos("FVC_EST") * ColumnPos("FVC_CONCEP") * ColumnPos("FVC_VALBAS") * ColumnPos("FVC_DESGR") * ColumnPos("FVC_ALIQ") * ColumnPos("FVC_RETENC")) > 0)
		aAdd(oGridRet:aCols,{aRetencoes[nX][1],aRetencoes[nX][2],aRetencoes[nX][3],aRetencoes[nX][4],aRetencoes[nX][5],aRetencoes[nX][6],aRetencoes[nX][7],.F.})
	Else
		aAdd(oGridRet:aCols,{aRetencoes[nX][1],aRetencoes[nX][2],.F.}) //Descricao|Valor
	EndIf
Next nX
	
	oGridRet:Refresh()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855AtTotบ Autor ณ Microsiga          บ Data ณ  31/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os dados da grid Totais.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855AtTot()
Local cMoePeso		:= Lower(AllTrim(GetMV("MV_MOEDA1",.T.,"PESO")))
Local cMoedConv		:= Lower(AllTrim(GetMV("MV_MOEDA"+CValToChar(Val(cMoeda)),.T.,"PESO")))
Local nValTit		:= 0
Local nValRet		:= 0
Local nValPreOp		:= 0
Local nX			:= 0
Local nPosValTit	:= AScan(oBrwTit:aHeader,{|x| AllTrim(x[2]) == "VALPRE"})
Local nPosMoeTit	:= AScan(oBrwTit:aHeader,{|x| AllTrim(x[2]) == "MOEDA"})
Local nPosRecno		:= Len(oBrwTit:aHeader) + 1
Local nPosValRet	:= AScan(oGridRet:aHeader,{|x| AllTrim(x[2]) == "VALRET"})

oGridTot:aCols := {}

If cPaisLoc == "ARG" .and. (TableInDic("FVC") .and. FVC->(ColumnPos("FVC_TIPO") * ColumnPos("FVC_EST") * ColumnPos("FVC_CONCEP") * ColumnPos("FVC_VALBAS") * ColumnPos("FVC_DESGR") * ColumnPos("FVC_ALIQ") * ColumnPos("FVC_RETENC")) > 0)
	nPosValRet	:= AScan(oGridRet:aHeader,{|x| AllTrim(x[2]) == "FVC_RETENC"})
EndIf

//---------------------------------------------
// Calcula o valor total dos titulos da Pre-OP
//---------------------------------------------
For nX := 1 To Len(oBrwTit:aCols)

	// Desconsidera linhas deletadas
	If oBrwTit:aCols[nX][Len(oBrwTit:aCols[nX])]
		Loop
	EndIf

	SE2->(DbGoTo(oBrwTit:aCols[nX][nPosRecno]))
	nValTit += XMoeda(oBrwTit:aCols[nX][nPosValTit],Val(oBrwTit:aCols[nX][nPosMoeTit]),1,dDataBase,SE2->E2_TXMOEDA)

Next nX

Aadd(oGridTot:aCols,{STR0014 + "("			+ STR0015 + " " + cMoePeso	+ ")", nValTit									, .F.}) //"Valor dos titulos"###"em"
Aadd(oGridTot:aCols,{STR0014 + "("+STR0084+ " "	+ STR0015 + " " + cMoedConv	+ ")", XMoeda(nValTit,1,Val(cMoeda),dDataBase)	, .F.}) //"Valor dos titulos"###"conv."###"em"

//-----------------------------------------------
// Calcula o valor total das retencoes da Pre-OP
//-----------------------------------------------
For nX := 1 To Len(oGridRet:aCols)
	nValRet += oGridRet:aCols[nX][nPosValRet]
Next nX
Aadd(oGridTot:aCols,{STR0016 + "("			+ STR0015 + " " + cMoePeso	+ ")", nValRet									, .F.}) //"Retencoes"###"em"
Aadd(oGridTot:aCols,{STR0016 + "("+STR0084+ " "	+ STR0015 + " " + cMoedConv	+ ")", XMoeda(nValRet,1,Val(cMoeda),dDataBase)	, .F.}) //"Retencoes"###"conv."###"em"

//---------------------------------
// Calcula o valor total da Pre-OP
//---------------------------------
nValPreOp := nValTit - nValRet
Aadd(oGridTot:aCols,{STR0017 + "("			+ STR0015 + " " + cMoePeso	+ ")", nValPreOp									, .F.}) //"Total da pre-ordem"###"em"
Aadd(oGridTot:aCols,{STR0017 + "("+STR0084+ " "	+ STR0015 + " " + cMoedConv	+ ")", XMoeda(nValPreOp,1,Val(cMoeda),dDataBase)	, .F.}) //"Total da pre-ordem"###"conv."###"em"

oGridTot:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A855Leg  บ Autor ณ Marylly A. Silva   บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda da situa็ใo das pr้-ordens de pagamento.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A855Leg(nReg)
Local uRetorno := .T.
Local aLegenda := {}

aLegenda := {	{"BR_AMARELO"	,STR0050},;	//Original
				{"BR_VERDE"		,STR0051},;	//Aprovada
				{"BR_VERMELHO"	,STR0052},;	//Reprovada ou cancelada
				{"BR_AZUL"		,STR0053}}	//Efetivada

If nReg == Nil
	uRetorno := {}
	aAdd(uRetorno,{"Empty(FJK_ORDPAG) .And. Empty(FJK_DTCANC) .And. Empty(FJK_DTANLI)"	, aLegenda[1][1]}) //Original
	aAdd(uRetorno,{"!Empty(FJK_DTANLI) .And. Empty(FJK_DTCANC) .And. Empty(FJK_ORDPAG)"	, aLegenda[2][1]}) //Aprovada
	aAdd(uRetorno,{"!Empty(FJK_DTCANC)"													, aLegenda[3][1]}) //Reprovada ou cancelada
	aAdd(uRetorno,{"!Empty(FJK_ORDPAG)"													, aLegenda[4][1]}) //Efetivada
Else
	BrwLegenda(STR0007, STR0007, aLegenda) //"Pr้-ordem de pagamento"
EndIf

Return(uRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บ Autor ณ Marylly A. Silva   บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Menu (aRotina) da pr้-ordem de pagamento modelo II         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}
Local lWsFeCred	:= SuperGetMV( "MV_WSFECRD", .F., .F. ) 

If cPaisLoc == "ARG" .And. lWsFeCred .And. FindFunction("FeCredAmb")
	aRotina := {{ OemToAnsi(STR0056),'PesqBrw'		,0 ,1		},;	//"Buscar"
				{ OemToAnsi(STR0057),'A855POp(1)'	,0 ,3		},;	//"Incluir"
				{ OemToAnsi(STR0058),'A855POp(2)'	,0 ,2		},;	//"Visualizar"
				{ OemToAnsi(STR0135),'FeCredAmb'	,0 ,2		},;	//"Confg. Amb. WSFeCred
				{ OemToAnsi(STR0059),'A855POp(4)'	,0 ,4		},;	//"Alterar"
				{ OemToAnsi(STR0060),'A855POp(3)'	,0 ,2		},;	//"Excluir"
				{ OemToAnsi(STR0005),'A855POp(5)'	,0 ,2		},;	//"Aprova็ใo"
				{ OemToAnsi(STR0031),'A855POp(6)'	,0 ,2		},;	//"Cancelar"
				{ OemToAnsi(STR0061),'A855Leg'		,0 ,7,,.F.	}}	//"Legenda"
Else
	aRotina := {{ OemToAnsi(STR0056),'PesqBrw'		,0 ,1		},;	//"Buscar"
			{ OemToAnsi(STR0057),'A855POp(1)'	,0 ,3		},;	//"Incluir"
			{ OemToAnsi(STR0058),'A855POp(2)'	,0 ,2		},;	//"Visualizar"
			{ OemToAnsi(STR0059),'A855POp(4)'	,0 ,4		},;	//"Alterar"
			{ OemToAnsi(STR0060),'A855POp(3)'	,0 ,2		},;	//"Excluir"
			{ OemToAnsi(STR0005),'A855POp(5)'	,0 ,2		},;	//"Aprova็ใo"
			{ OemToAnsi(STR0031),'A855POp(6)'	,0 ,2		},;	//"Cancelar"
			{ OemToAnsi(STR0061),'A855Leg'		,0 ,7,,.F.	}}	//"Legenda"
	
Endif
If cPaisloc == "RUS"
	aAdd(aRotina,{ OemToAnsi(STR0128),'MSDOCUMENT'	,0 ,4,,.F.	})	//"Documents"
	aAdd(aRotina,{ OemToAnsi(STR0129),'RUpayorderOpen'	,0 ,4,,.F.	})// view payment order
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855AtMoeบ Autor ณ Microsiga          บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a grid de distribuicao moedas                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855AtMoe(lLinDelet)
Local nPosMoeda		:= GDFieldPos("FJM_MOEDA",oBrwRat:aHeader)
Local nPosPerc		:= GDFieldPos("FJM_PERC",oBrwRat:aHeader)
Local nPosTaxa		:= GDFieldPos("FJM_TAXA",oBrwRat:aHeader)
Local nValPreOP		:= GdFieldGet("VALPREOP",oGridPreOP:nAt,,oGridPreOP:aHeader,oGridPreOP:aCols)
Local nLin			:= 0
Local nPercRateio	:= 0
Local cMoedaRat		:= ""
Local nTaxa			:= 0
Local nTotPerc		:= 0
Local nValConv		:= 0
Local nX			:= 0
Local nI			:= 0

Default lLinDelet	:= .F. //Variavel utilizada para controle da funcao de deletacao de linha

//--------------------------------------
// Atribui a estrutura de distribuicao
// ao navegar entre as Pre-OP's
//--------------------------------------
For nX := 1 To Len(oGridPreOP:aCols)
	If nX > Len(aColsSavMo)
		Aadd(aColsSavMo,{Array(Len(oBrwRat:aHeader)+1)})
		For nI := 1 To Len(oBrwRat:aHeader)
			aColsSavMo[nX][1][nI] := CriaVar(oBrwRat:aHeader[nI][2])
		Next nI
		aColsSavMo[nX][1][Len(oBrwRat:aHeader)+1] := .F.
	EndIf
Next nX

oBrwRat:aCols := AClone(aColsSavMo[oGridPreOP:nAt])

If (INCLUI .Or. ALTERA) .And. Len(oBrwRat:aCols) > 0

	For nLin := 1 To Len(oBrwRat:aCols)

		If !Empty(oBrwRat:aCols[nLin][nPosMoeda])

			// Tratamento para a funcao de exclusao de linhas da MsNewGetDados
			If (lLinDelet .And. oBrwRat:nAt == nLin)
				If oBrwRat:aCols[nLin][Len(oBrwRat:aHeader)+1]
					aColsSavMo[oGridPreOP:nAt][nLin][Len(oBrwRat:aHeader)+1]:= .F.
				Else
					aColsSavMo[oGridPreOP:nAt][nLin][Len(oBrwRat:aHeader)+1]:= .T.
					Loop
				EndIf
			ElseIf oBrwRat:aCols[nLin][Len(oBrwRat:aHeader)+1]
				Loop
			EndIf

			//Moeda do Rateio
			cMoedaRat := oBrwRat:aCols[nLin][nPosMoeda]

			//Porcentagem
			nPercRateio := oBrwRat:aCols[nLin][nPosPerc]/100

			//Taxa
			nTaxa := oBrwRat:aCols[nLin][nPosTaxa]

			//Valor convertido
			nValConv := (XMoeda(nValPreOP,1,Val(cMoedaRat),dDatabase,4,,nTaxa)) * nPercRateio
			GDFieldPut("FJM_VLCONV",nValConv,nLin,oBrwRat:aHeader,oBrwRat:aCols)

			//Valor convertido moeda OP
			nValConv := (XMoeda(nValPreOP,1,Val(cMoeda),dDatabase)) * nPercRateio
			GDFieldPut("FJM_VLMDOP",nValConv,nLin,oBrwRat:aHeader,oBrwRat:aCols)

			//Acumulador do percentual
			nTotPerc += oBrwRat:aCols[nLin][nPosPerc]

		EndIf

	Next nLin

	//------------------------------------------------
	// Atualiza as informacoes exibidas acima da grid
	//------------------------------------------------
	//Valor dos titulos
	oSay11:cTitle := Transform(nValPreOP,PesqPict("SE2","E2_VALOR"))
	oSay11:Refresh()
	// % a distribuir
	oSay21:cTitle := Transform(100 - nTotPerc,PesqPict("FJM","FJM_PERC"))
	oSay21:Refresh()
	//% distribuido
	oSay31:cTitle := Transform((nTotPerc),PesqPict("FJM","FJM_PERC"))
	oSay31:Refresh()

EndIf

oBrwRat:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855AtMoeบ Autor ณ Microsiga          บ Data ณ  01/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a grid de distribuicao moedas                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855Reten(aTitulos,aRetencoes,nValTotRet,lAtual)
Local nX			:= 0
Local nA			:= 0
Local nY			:= 0
Local nP			:= 0
Local nValGananc	:= 0
Local nValIVA		:= 0
Local nValIB		:= 0
Local nValSUSS		:= 0
Local nValSLI		:= 0
Local nValIRIC		:= 0
Local nValIR		:= 0
Local nValISI		:= 0
Local nOldIva		:= 0
Local nValPag		:= 0
Local nValIRC		:= 0
Local nValRIE		:= 0
Local nValIGV   	:= 0
Local nTotPOp		:= 0
Local lCalcAcm 	:= Subs(GETMV("MV_AGENTE"),2,1) == "N"
Local aReten		:= {}
Local lCalc		:= .T.
Local lRetenD		:= cPaisLoc == "ARG" .and. (TableInDic("FVC") .and. FVC->(ColumnPos("FVC_TIPO") * ColumnPos("FVC_EST") * ColumnPos("FVC_CONCEP") * ColumnPos("FVC_VALBAS") * ColumnPos("FVC_DESGR") * ColumnPos("FVC_ALIQ") * ColumnPos("FVC_RETENC")) > 0)
Local nPos			:= 0
Local cProv         := ""
Local nLinPreOP     := 0
Local nPosProv      := 0
Local nSumPag 		:= 0
Local nT    		:= 0
Local nPagoT  		:= 0
Local nVlMoe1IBB	:= 0
Local nVlMoe1GAN	:= 0
Local nVlMoe1SUS	:= 0
Local nVlMoe1IVA	:= 0

Default aTitulos		:= {}
Default aRetencoes	:= {}
Default nValTotRet	:= 0
Default lAtual		:= .F.

Private aRecNoSE2		:= {}
Private aRetIvAcm		:= Array(3)
Private nTotBSUSS		:= 0
Private nLimiteSUSS	:= 0

aRetencoes := {}
nValTotRet := 0

aRecNoSE2 := AClone(aTitulos)

If !inclui .and. !altera .and. TableInDic("FVC")
	lCalc := !F855Ret(FJK->FJK_PREOP,@aReten,@aRetencoes)
EndIf

F850Se2(@aSE2,.T.,.T.)

If Len(aSE2) > 0

	For nA:=1 To Len(aSE2)

		For nX := 1 To Len(aSE2[nA][1])

			If aSE2[nA][1][nX][_TIPO] $ MVPAGANT + "/" + MV_CPNEG
				nValPag -= IIf(aSE2[nA][1][nX][_MOEDA] == 1,aSE2[nA][1][nX][_PAGAR], Round(xMoeda(aSE2[nA][1][nX][_PAGAR],aSE2[nA][1][nX][_MOEDA],1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))
			Else
				nValPag += IIf(aSE2[nA][1][nX][_MOEDA] == 1,aSE2[nA][1][nX][_PAGAR], Round(xMoeda(aSE2[nA][1][nX][_PAGAR],aSE2[nA][1][nX][_MOEDA],1,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor)))
			EndIf
			
			If cPaisLoc == "ARG" 
				//-----------
				// Ganancias
				//-----------
				If lCalc
					If nX == Len(aSE2[nA][1])
						For nY:= 1	To Len(aSE2[nA][2])
							nValGananc += xMoeda(aSE2[nA][2][nY][5],nMoedaCor,aSE2[nA][1][nX][4],,5,,aTxMoedas[aSE2[nA][1][nX][4]][2])//Feita a atualiza??o para ser usada a posi??o da moeda da nota
							nVlMoe1GAN += aSE2[nA][2][nY][5]
							If lRetenD 
								If aSE2[nA][2][nY][2] < 0 .or. aSE2[nA][2][nY][5] <= 0 
									aAdd(aRetencoes,{"G","",aSE2[nA][2][nY][7],0,0,aSE2[nA][2][nY][3],0,.F.})
								Else
									aAdd(aRetencoes,{"G","",aSE2[nA][2][nY][7],aSE2[nA][2][nY][2],0,aSE2[nA][2][nY][3],aSE2[nA][2][nY][5],.F.})
								EndIf
							EndIf
						Next nY
					EndIf
				Else
					nValGananc := aReten[4]
				EndIf
				
				If lCalc
					//-----
					// IVA
					//-----
					For nY := 1 To Len(aSE2[nA][1][nX][_RETIVA])					
						If !lCalcAcm
							nValIVA += xMoeda(aSE2[nA][1][nX][_RETIVA][nY][6],nMoedaCor,aSE2[nA][1][nX][4],,5,,aTxMoedas[aSE2[nA][1][nX][4]][2])
							If lRetenD 
								nPos := ASCAN(aRetencoes,{|x|x[1] == "I" .and. x[6]== aSE2[nA][1][nX][_RETIVA][nY][10] })
								If nPos > 0
									aRetencoes[nPos][4] += aSE2[nA][1][nX][_RETIVA][nY][3]
									aRetencoes[nPos][7] += aSE2[nA][1][nX][_RETIVA][nY][6]
								Else
									aAdd(aRetencoes,{"I","","",aSE2[nA][1][nX][_RETIVA][nY][3],0,aSE2[nA][1][nX][_RETIVA][nY][10],aSE2[nA][1][nX][_RETIVA][nY][6],.F.})
								EndIf
							EndIf
						Else
							nVlMoe1IVA += aSE2[nA][1][nX][_RETIVA][nY][6]
						EndIf
					Next nY
				Else
					nValIVA := aReten[1]
				EndIf
				
				//----
				// IB
				//----
				If lCalc
					For nY := 1 To Len(aSE2[nA][1][nX][_RETIB])
						nValIB += xMoeda(aSE2[nA][1][nX][_RETIB ][nY][5],nMoedaCor,aSE2[nA][1][nX][4],,5,,aTxMoedas[aSE2[nA][1][nX][4]][2]) 
						nVlMoe1IBB += aSE2[nA][1][nX][_RETIB ][nY][5]
						If lRetenD
							nPos := ASCAN(aRetencoes,{|x|x[1] == "B" .and. x[2]== aSE2[nA][1][nX][_RETIB][nY][9] .and. x[6]== aSE2[nA][1][nX][_RETIB][nY][4] })
							If nPos > 0
								aRetencoes[nPos][4] += aSE2[nA][1][nX][_RETIB][nY][3]
								aRetencoes[nPos][7] += aSE2[nA][1][nX][_RETIB][nY][6]
							Else
								aAdd(aRetencoes,{"B",aSE2[nA][1][nX][_RETIB][nY][9],aSE2[nA][1][nX][_RETIB][nY][14],aSE2[nA][1][nX][_RETIB][nY][3],0,aSE2[nA][1][nX][_RETIB][nY][4],aSE2[nA][1][nX][_RETIB][nY][6],.F.})
							EndIf
						EndIf
					Next nY
				Else
					nValIB := aReten[2]
				EndIf
				
				//------
				// SUSS
				//------
				If lCalc
					For nY := 1 To Len(aSE2[nA][1][nx][_RETSUSS])
						nValSUSS += xMoeda(aSE2[nA][1][nX][_RETSUSS][nY][6],nMoedaCor,aSE2[nA][1][nX][4],,5,,aTxMoedas[aSE2[nA][1][nX][4]][2]) 
						nVlMoe1SUS += aSE2[nA][1][nX][_RETSUSS][nY][6]
						If lRetenD
							nPos := ASCAN(aRetencoes,{|x|x[1] == "S" .and. x[3]== aSE2[nA][1][nX][_RETSUSS][nY][8] .and. x[6]== aSE2[nA][1][nX][_RETSUSS][nY][7] })
							If nPos > 0
								aRetencoes[nPos][4] += aSE2[nA][1][nX][_RETSUSS][nY][3]
								aRetencoes[nPos][7] += aSE2[nA][1][nX][_RETSUSS][nY][6]
							Else
								aAdd(aRetencoes,{"S","",aSE2[nA][1][nX][_RETSUSS][nY][8],aSE2[nA][1][nX][_RETSUSS][nY][3],0,aSE2[nA][1][nX][_RETSUSS][nY][7],aSE2[nA][1][nX][_RETSUSS][nY][6],.F.})
							EndIf
						EndIf
					Next nY
				Else
					nValSUSS := aReten[3]
				EndIf
				
				//-----
				// SLI
				//-----
				If lCalc
					For nY := 1 To Len(aSE2[nA][1][nx][_RETSLI])
						nValSLI += xMoeda(aSE2[nA][1][nX][_RETSLI][nY][6],nMoedaCor,aSE2[nA][1][nX][4],,5,,aTxMoedas[aSE2[nA][1][nX][4]][2]) 
						If lRetenD
							nPos := ASCAN(aRetencoes,{|x|x[1] == "L" })
							If nPos > 0
								aRetencoes[nPos][4] += aSE2[nA][1][nX][_RETSLI][nY][3]
								aRetencoes[nPos][7] += aSE2[nA][1][nX][_RETSLI][nY][6]
							Else
								aAdd(aRetencoes,{"L","","",aSE2[nA][1][nX][_RETSLI][nY][3],0,0,aSE2[nA][1][nX][_RETSLI][nY][6],.F.})
							EndIf
						EndIf
					Next nY
				Else
					nValSLI := aReten[5]
				EndIf
				//-----
				// ISI
				//-----
				If lCalc
					For nY := 1 To Len(aSE2[nA][1][nx][_RETISI])
						nValISI += xMoeda(aSE2[nA][1][nX][_RETISI][nY][6],nMoedaCor,aSE2[nA][1][nX][4],,5,,aTxMoedas[aSE2[nA][1][nX][4]][2]) 
						If lRetenD
							If  Len(aSE2[nA][1][nX][28][nY][8])>0 .and. !Empty(aSE2[nA][1][nX][28][nY][8][1][2])
								cProv := POSICIONE("SFB",1,xFilial("SFB")+aSE2[nA][1][nX][_RETISI][nY][8][1][2],"FB_ESTADO")
							Else
								cProv := aSE2[nA][1][nX][_RETISI][nY][9]
							EndIf 
							nPos := ASCAN(aRetencoes,{|x|x[1] == "M" .and. x[2]== aSE2[nA][1][nX][_RETISI][nY][9] .and. IIF (Len(aSE2[nA][1][nX][_RETISI][nY][8]) > 0, x[6]== aSE2[nA][1][nX][_RETISI][nY][8][1][1], .F.) })
							If nPos > 0
								aRetencoes[nPos][4] += aSE2[nA][1][nX][_RETISI][nY][3]
								aRetencoes[nPos][7] += aSE2[nA][1][nX][_RETISI][nY][6]
							Else
								IF (Len(aSE2[nA][1][nX][_RETISI][nY][8]) > 0)
									aSE2[nA][1][nX][_RETISI][nY][9] := cProv
									aAdd(aRetencoes,{"M",aSE2[nA][1][nX][_RETISI][nY][9],"",aSE2[nA][1][nX][_RETISI][nY][3],0,aSE2[nA][1][nX][_RETISI][nY][8][1][1],aSE2[nA][1][nX][_RETISI][nY][6],.F.})
								EndIf
							EndIf
						EndIf
					Next nY
				Else
					nValISI := aReten[6]
				EndIf
			EndIf
			If cPaisLoc $ "URU|BOL"
				//-----
				// IRIC
				//-----
				For nY := 1 To Len(aSE2[nA][1][nX][_RETIRIC])
					nValIRIC += aSE2[nA][1][nX][_RETIRIC][nY][6]
				Next nY
				//-----
				// IR
				//-----
				For nY := 1 To Len(aSE2[nA][1][nX][_RETIR])
					nValIR += aSE2[nA][1][nX][_RETIR][nY][6]
				Next nY
			EndIf
			If !lCalcAcm .and. cPaisLoc $ "PTG"
				For nY := 1 To Len(aSE2[nA][1][nX][_RETIVA])
					nValIVA += aSE2[nA][1][nX][_RETIVA][nY][6]
				Next nY
				If cPaisLoc == "PTG"
					For nY := 1 To Len(aSE2[nA][1][nX][_RETIRC])
						nValIRC += aSE2[nA][1][nX][_RETIRC][nY][6]
					Next nY
				EndIf
			EndIf
			If cPaisLoc == "ANG"
				//----
				// RIE
				//----
				For nY := 1 To Len(aSE2[nA][1][nX][_RETRIE])
					nValRIE += aSE2[nA][1][nX][_RETRIE][nY][5]
				Next nY
			EndIf
			If cPaisLoc == "PER"
				//----
				// IGV
				//----
				For nY := 1 To Len(aSE2[nA][1][nX][_RETIGV])
					nValIGV += aSE2[nA][1][nX][_RETIGV][nY][5]
				Next nY
				//-----
				// IR
				//-----
				For nY := 1 To Len(aSE2[nA][1][nX][_RETIR])
					nValIR += aSE2[nA][1][nX][_RETIR][nY][6]
				Next nY
			EndIf
		Next nX
	Next nA


	/************************************************************************/
	//Calculo cumulativo de IVA - reten็ใo de documentos que nใo sใo desta OP
	/************************************************************************/
	nTotPOp := nValPag
	If !(!inclui .and. !altera .and. TableInDic("FVC"))
		nValIVA := 0
		For nA:=1 To Len(aSE2)

			If Len(aSE2[nA][1]) > 1 .And. Len(aRetIvAcm)> 1 .And. aRetIvAcm[2] <> Nil .And.  Len(aRetIvAcm[2]) > 0 .And. cPaisLoc == "ARG"
				For nT := 1 to Len(aSE2[nA][1])
					nPagoT := IIF(aSE2[nA][1][nT][_TIPO] $ MVPAGANT + "/" + MV_CPNEG, -1 * aSE2[nA][1][nT][_PAGAR], aSE2[nA][1][nT][_PAGAR])
					nSumPag += Round(xMoeda(nPagoT,aSE2[nA][1][nT][_MOEDA],1,,5,,aTxMoedas[aSE2[nA][1][nT][_MOEDA]][2]),MsDecimais(1))
				Next
			EndIf
			F850DocIVA(aSE2[nA][1][1][_FORNECE],aSE2[nA][1][1][_LOJA],IIF((nSumPag > 0) .And. (cPaisLoc == "ARG"), nSumPag, Round(xMoeda(aSE2[nA][1][1][_PAGAR],aSE2[nA][1][1][_MOEDA],1,,5,,aTxMoedas[aSE2[nA][1][1][_MOEDA]][2]),MsDecimais(1))), (nVlMoe1IBB + nVlMoe1IVA + nVlMoe1GAN))

			For nX := 1 To Len(aSE2[nA][1])
				For nP	:=	1	To	Len(aSE2[nA][1][nX][_RETIVA])
					nValIVA	+=	Round(xMoeda(aSE2[nA][1][nX][_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
				Next nP
			Next nX

			If Len(aRetIvAcm[3]) > 0
				For nP := 1 to Len(aRetIvAcm[3])
					nValIVA	+=	aRetIvAcm[3][nP][6]
				Next
			EndIf

		    nOldIva += nValIVA

			//Porporcionaliza as baixas menores que o acumulado de IVA
			F850PropIV(nValPag-(nVlMoe1GAN + nVlMoe1IBB + nVlMoe1SUS),nOldIVA,@aSE2[nA])
			//Zera o IVA calculado para recomposi็ใo
			nValIVA := 0
			For nX :=1 to Len(aRetencoes)
				if aRetencoes[nX][1] == "I"
					aRetencoes[nX][4] := 0  
					aRetencoes[nX][7] := 0  
				EndIf
			Next
						
			For nX := 1 To Len(aSE2[nA][1])
				For nP	:=	1	To	Len(aSE2[nA][1][nX][_RETIVA])
					nValIVA	+=	Round(xMoeda(aSE2[nA][1][nX][_RETIVA][nP][6],1,nMoedaCor,,5,,aTxMoedas[nMoedaCor][2]),MsDecimais(nMoedaCor))
					nPos := ASCAN(aRetencoes,{|x|x[1] == "I" .and. x[6]== aSE2[nA][1][nX][_RETIVA][nP][10] })
					If nPos > 0
						aRetencoes[nPos][4] += aSE2[nA][1][nX][_RETIVA][nP][3]
						aRetencoes[nPos][7] += aSE2[nA][1][nX][_RETIVA][nP][6]
					Else
						aAdd(aRetencoes,{"I","","",aSE2[nA][1][nX][_RETIVA][nP][3],0,aSE2[nA][1][nX][_RETIVA][nP][10],aSE2[nA][1][nX][_RETIVA][nP][6],.F.})
					Endif
				Next nP
			Next nX

			If Len(aRetIvAcm[3]) > 0
				For nP := 1 to Len(aRetIvAcm[3])
					nValIVA	+=	aRetIvAcm[3][nP][6]
					nPos := ASCAN(aRetencoes,{|x| x[1] == "I" .and. x[6] == aRetIvAcm[3][nP][10]})				    
					If nPos > 0
						aRetencoes[nPos][4] += aRetIvAcm[3][nP][3]
						aRetencoes[nPos][7] += aRetIvAcm[3][nP][6]
					EndIf
				Next
			EndIf

			nTotPOp := nValPag
			nValPag := 0
			nOldIva := 0

			If ValType(aRIvAcm) != "U" .And. ValType(aRetIvAcm) != "U" .And. Len(aRetIvAcm)> 1 .And. aRetIvAcm[3] <> Nil .And. cPaisLoc == "ARG"
				aRIvAcm := aRetIvAcm
			EndIf
		Next nA
	EndIf

	If cPaisLoc == "ARG"
		nTotPOp := nTotPOp - (nValGananc + nValIVA + nValIB + nValSUSS + nValSLI + nValISI)
		nValTotRet := nValGananc + nValIVA + nValIB + nValSUSS + nValSLI + nValISI
	ElseIf cPaisLoc $ "URU|BOL"
		nValTotRet := nValIRIC + nValIR
	ElseIf cPaisLoc = "PTG"
		nValTotRet := nValIVA + nValIRC
	ElseIf cPaisLoc = "ANG"
		nValTotRet := nValRIE
	ElseIf cPaisLoc = "PER"
		nValTotRet := nValIGV	 + nValIR
	EndIf
EndIf

For nLinPreOP := 1 To Len(aRetImp855)
	nPosProv := aScan(aRetImp855[nLinPreOP][1][1], {|x,y| x[1]==aSE2[1][1][1][1] .And. x[2] == aSE2[1][1][1][2]})
	If nPosProv > 0
		aRetImp855[nLinPreOP] := AClone(aSE2)
		Exit
	EndIf
Next
If nPosProv == 0
	Aadd(aRetImp855,AClone(aSE2))
EndIf

If cPaisLoc == "ARG"
	If lRetenD
		If Len(aRetencoes) == 0
			Aadd(aRetencoes,{"","","",0,0,0,0,.F.})
		EndIf
	Else
		Aadd(aRetencoes,{STR0039,nValGananc}) //"Ganancias"
		Aadd(aRetencoes,{STR0040,nValIVA	}) //"IVA"
		Aadd(aRetencoes,{STR0041,nValIB		}) //"IB"
		Aadd(aRetencoes,{STR0042,nValSUSS	}) //"SUSS"
		Aadd(aRetencoes,{STR0043,nValSLI	}) //"SLI"
		Aadd(aRetencoes,{STR0044,nValISI	}) //"ISI"
	EndIf
ElseIf cPaisLoc $ "URU|BOL"
	Aadd(aRetencoes,{STR0092,nValIRIC	}) //"IRIC"
	Aadd(aRetencoes,{STR0098,nValIR		}) //"IR"
ElseIf cPaisLoc == "PTG"
	Aadd(aRetencoes,{STR0040,nValIVA	}) //"IVA"
	Aadd(aRetencoes,{STR0097,nValIRC	}) //"IRC"
ElseIf cPaisLoc == "ANG"
	Aadd(aRetencoes,{STR0095,nValRIE	}) //"RIE"
ElseIf cPaisLoc == "PER"
	Aadd(aRetencoes,{STR0096,nValIGV	}) //"IGV"
	Aadd(aRetencoes,{STR0098,nValIR		}) //"IR"
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855VlRatบAutor  ณMicrosiga           บ Data ณ  03/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os dados da Distribuicao Moeda                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855VlRat()
Local lRet		:= .T.
Local nLinha	:= oBrwRat:nAt

If INCLUI .Or. ALTERA
	If !Empty(GdFieldGet("FJM_MOEDA")) .And. !GdDeleted(nLinha,oBrwRat:aHeader,oBrwRat:aCols)
		If Empty(GdFieldGet("FJM_PERC"))
			lRet := .F.
			MsgAlert(STR0078) //"Informe um percentual para o item do rateio."
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855VlRatบAutor  ณMicrosiga           บ Data ณ  03/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os dados da Distribuicao Moeda                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855DelMo()
Local lRet		:= .T.
Local nX		:= 0
Local nTotPer	:= 0

For nX := 1 To Len(oBrwRat:aCols)

	If !GdDeleted(nX,oBrwRat:aHeader,oBrwRat:aCols) .And. nX != oBrwRat:nAt

		If GdFieldGet("FJM_MOEDA",nX) == GdFieldGet("FJM_MOEDA",oBrwRat:nAt)
			lRet := .F.
			MsgAlert(STR0074) // "Moeda jแ informada na distribu็ใo da pr้-ordem de pago."
			Exit
		EndIf

		nTotPer += GdFieldGet("FJM_PERC",nX)

	EndIf

Next nX

If (nTotPer + GdFieldGet("FJM_PERC",oBrwRat:nAt)) > 100
	lRet := .F.
	Help(" ", 1,"F855PERC",, STR0072,1,0) // "Porcentagem informada acima da porcentagem a ser ditribuida"
EndIf

//Atualiza os dados na tela
If lRet
	FA855AtMoe(.T.)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855SelApบ Autor ณMarylly A. Silva    บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de abertura da tela de filtro e sele็ใo de tํtulos  บฑฑ
ฑฑบ          ณ que serใo utilizados na pr้-ordem de pago.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855SelAp(lAprova)
Local bInitBr	:= Nil
Local aButtons	:= {}
Local lRet		:= .T.
Local lConfirm	:= .F.
Local nX		:= 0
Local nLoop     := 0

//--- Contador de Marcados
Local nMarked := 0

Private oDlgSel
Private oBrwSTit
Private oOK
Private oNOK
Private lCheck	:= .T.
Private oTmpFJK
Private aOrdem     := {} //JGR

Default lAprova	:= .T.

If Pergunte("FIN855AP",.T.)

	//---------------------------------
	// Cria a tabela temporaria da FJK
	//---------------------------------
	FA855FJKTe() //JGR

	//-------------------------------------------------------------------------
	// Carrega a tabela temporaria com os registros que atendem aos parametros
	//-------------------------------------------------------------------------
	FA855FJKCa()

	If FJKTEMP->(!Eof())

		oOK		:= LoadBitmap(GetResources(),"wfchk")
		oNOK	:= LoadBitmap(GetResources(),"wfunchk")

		Define MsDialog oDlgSel Title STR0026 From 000,000 To 540,756 Pixel //"Titulos a pagar"

		If cMarca == Nil
			cMarca := ""
		EndIf

		oBrwSTit := TCBrowse():New(0,0,10,10,,,,oDlgSel,,,,,{|| FA855FJKMa()},,,,,,,,"FJKTEMP",.T.,,,,.T.,)
		oBrwSTit:AddColumn(TCColumn():New("  "                  ,{|| If(FJKTEMP->FJK_OK == cMarca,oOK,oNOK)},                            ,,,,010,.T.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_FORNEC"),{|| FJKTEMP->FJK_FORNEC}                   ,                            ,,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_LOJA")  ,{|| FJKTEMP->FJK_LOJA}                     ,                            ,,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_PREOP") ,{|| FJKTEMP->FJK_PREOP}                    ,                            ,,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_MOEDA") ,{|| FJKTEMP->FJK_MOEDA}                    ,""                          ,,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_VLRPRE"),{|| FJKTEMP->FJK_VLRPRE}                   ,PesqPict("FJK","FJK_VLRPRE"),,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_VLCONV"),{|| FJKTEMP->FJK_VLCONV}                   ,PesqPict("FJK","FJK_VLCONV"),,,,020,.F.,.F.,,,,,))
		oBrwSTit:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwSTit:Refresh()

		//Bloco a ser executado ao "Confirmar" a tela -> <CTRL+O>
		bSetConf :=	{|| If(F855VldSel(),(lConfirm := .T., lAprova := .T., GetKeys() , SetKey( VK_F3 , Nil ), oDlgSel:End()),Nil)}

		//Bloco a ser executado ao "Finalizar" a tela -> <CTRL+X>
		bSetFech := { || lConfirm := .F. ,GetKeys() , SetKey( VK_F3 , Nil ) , oDlgSel:End() }

		//Acoes relacionadas
		aAdd(aButtons,{"Parametros"				,{|| Pergunte("FIN855AP",.T.),cMarca := GetMark(),FA855FJKCa(),oBrwSTit:DrawSelect()}						,OemToAnsi(STR0028),OemToAnsi(STR0028)}) //"Parโmetros"
		aAdd(aButtons,{"Marca_Desmarca_Todos"	,{|| FA855AtCl(@lCheck)}																					,OemToAnsi(STR0069),OemToAnsi(STR0069)}) //"Marca/Desmarca Todos"
		aAdd(aButtons,{"Rejeitar"				,{|| If(F855VldSel(),(lConfirm := .T., lAprova := .F., GetKeys(), SetKey(VK_F3,Nil), oDlgSel:End()),Nil)}	,OemToAnsi(STR0055),OemToAnsi(STR0055)}) //"Rejeitar"
		aAdd(aButtons,{"Pesquisa"				,{|| F855PsqPre()}																					  		,OemToAnsi(STR0029),OemToAnsi(STR0029)}) //"Pesquisa"

		//Bloco para montagem da tela de sele็ใo de tํtulos a pagar para composi็ใo da pr้-ordem de pago
		bInitBr := { || EnchoiceBar( oDlgSel , bSetConf , bSetFech , Nil , aButtons )}
		oDlgSel:bInit := bInitBr

		Activate MsDialog oDlgSel Center

		If lConfirm
			//------------------------------------------------------
			// Grava os registros selecionados na tabela temporaria
			//------------------------------------------------------
			FJKTEMP->(DbGoTop())
			While FJKTEMP->(!Eof())

				If FJKTEMP->FJK_OK == cMarca

                   nMarked ++  // Incrementa Contador

					//--------------------------------------------
					// Define se as Pre-Ordens serao visualizadas
					//--------------------------------------------
					If MV_PAR09 == 2 //Nao

						DbSelectArea("FJK")
						DbSetOrder(1)
						If MsSeek(XFilial("FJK")+FJKTEMP->(FJK_FORNEC+FJK_LOJA+FJK_PREOP))
							If lAprova
								RecLock("FJK",.F.)
								FJK->FJK_DTANLI := dDataBase
								FJK->(MsUnlock())
							Else
								//----------------------------------
								// Remove a referencia com o titulo
								//----------------------------------
								DbSelectArea("FJL")
								FJL->(DbSetOrder(1))
								If FJL->(MsSeek(xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)))
									While FJL->(!Eof()) .And. FJL->(FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP) == xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)
										DbSelectArea("SE2")
										DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
										If MsSeek(XFilial("SE2")+FJL->(FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO+FJL_FORNEC+FJL_LOJA))

											RecLock("SE2",.F.)
											SE2->E2_PREOP	:= ""
											SE2->E2_PREOK	:= " "
											SE2->E2_VLBXPAR	:= 0
											SE2->E2_OK		:= ""
											SE2->(MsUnlock())

										EndIf
									FJL->(DbSkip())
									EndDo
								EndIf
								//Rejeita a Pre-OP
								RecLock("FJK",.F.)
								FJK->FJK_DTCANC := dDataBase
								FJK->(MsUnlock())
							EndIf

						EndIf

					Else

						DbSelectArea("FJK")
						DbSetOrder(1)
						If MsSeek(XFilial("FJK")+FJKTEMP->(FJK_FORNEC+FJK_LOJA+FJK_PREOP))
							//----------------------------------------------------
							// Alimenta a tabela temporaria para montagem da tela
							//----------------------------------------------------
							DbSelectArea("FJL")
							FJL->(DbSetOrder(1))
							If FJL->(MsSeek(xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)))
								While FJL->(!Eof()) .And. FJL->(FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP) == xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)
									DbSelectArea("SE2")
									DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
									If MsSeek(XFilial("SE2")+FJL->(FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO+FJL_FORNEC+FJL_LOJA))
											
											RecLock("FA855SE2",.T.)
											FA855SE2->E2_FILIAL		:= XFilial("SE2")
											FA855SE2->E2_PREFIXO	:= SE2->E2_PREFIXO
											FA855SE2->E2_NUM		:= SE2->E2_NUM
											FA855SE2->E2_PARCELA	:= SE2->E2_PARCELA
											FA855SE2->E2_TIPO		:= SE2->E2_TIPO
											FA855SE2->E2_NATUREZ	:= SE2->E2_NATUREZ
											FA855SE2->E2_FORNECE	:= SE2->E2_FORNECE
											FA855SE2->E2_LOJA		:= SE2->E2_LOJA
											FA855SE2->E2_NOMFOR		:= SE2->E2_NOMFOR
											FA855SE2->E2_EMISSAO	:= SE2->E2_EMISSAO
											FA855SE2->E2_VENCTO		:= SE2->E2_VENCTO
											FA855SE2->E2_VENCREA	:= SE2->E2_VENCREA
											FA855SE2->E2_VALOR		:= SE2->E2_VALOR
											If cPaisloc == "RUS"
												FA855SE2->E2_BASIMP1	:= SE2->E2_BASIMP1
												FA855SE2->E2_ALQIMP1	:= SE2->E2_ALQIMP1
												FA855SE2->E2_VALIMP1	:= SE2->E2_VALIMP1
												FA855SE2->E2_MDCONTR	:= SE2->E2_MDCONTR
											EndIf
											FA855SE2->E2_SALDO		:= SE2->E2_SALDO
											FA855SE2->E2_OK			:= SE2->E2_OK
											FA855SE2->E2_MOEDA		:= SE2->E2_MOEDA
											FA855SE2->E2_DATALIB	:= SE2->E2_DATALIB
											FA855SE2->E2_PREOK		:= SE2->E2_PREOK
											FA855SE2->E2_TXMOEDA	:= SE2->E2_TXMOEDA
											FA855SE2->E2_VLBXPAR	:= SE2->E2_VLBXPAR
											FA855SE2->E2_PREOP		:= SE2->E2_PREOP
											FA855SE2->E2_STATLIB	:= SE2->E2_STATLIB
											FA855SE2->E2_VALPOP		:= FJL->FJL_VLRPRE
											FA855SE2->E2_RECNO		:= SE2->(Recno())
											FA855SE2->E2_MOEPOP		:= FJK->FJK_MOEDA
											If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
												For nLoop := 1 To Len(a855Cpos)
													FA855SE2->&(a855Cpos[nLoop][1][2]) := FJL->&(a855Cpos[nLoop][2][1])
												Next
											EndIf
											FA855SE2->E2_DELET		:= ""
										FA855SE2->(MsUnlock())

									EndIf
								FJL->(DbSkip())
								EndDo
							EndIf

						EndIf

					EndIf

				EndIf   // Fim do Teste de Marcado

			FJKTEMP->(DbSkip())
			EndDo

            If nMarked == 0   // Opa ... Confirmou sem marcar nada
			   lRet := .F.
            EndIf

			If ( MV_PAR09 == 2 ) .And. ( nMarked > 0 )
				lRet := .F. //Retorna falso para nao exibir a tela
				MsgAlert(STR0085) //"Processo concluido"
			EndIf

			FA855SE2->(DbGoTop())

		Else
			lRet := .F.
		EndIf

	Else
		lRet := .F.
		Help(" ",1,"F855PRETIT") //"Nใo existem tํtulos que atendam aos parโmetros informados."|"Verifique a configura็ใo de parโmetros."
	EndIf

	If oTmpFJK <> Nil   //jgr
		oTmpFJK:Delete()  //jgr
		oTmpFJK := Nil //jgr
	Endif //jgr


Else
	lRet := .F.
EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บ Autor ณ Marylly A. Silva   บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alimenta a tabela temporaria com as Pre-OP que atendem ao  บฑฑ
ฑฑบ          ณ filtro.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855FJKCa()
Local nX		:= 0
Local cAliasFJK	:= GetNextAlias()
Local cCampoTab	:= ""
//---------------------------
// MV_PAR01 - Fornecedor de
// MV_PAR02 - Fornecedor ate
// MV_PAR03 - Loja de
// MV_PAR04 - Loja ate
// MV_PAR05 - Data de
// MV_PAR06 - Data ate
// MV_PAR07 - Pre-Ordem de
// MV_PAR08 - Pre-Ordem ate
// MV_PAR09 - Exibe detalhe
// MV_PAR10 - Moeda
//------------------------------

cQuery := "SELECT * FROM " + RetSqlTab("FJK")
cQuery += "	WHERE "
cQuery += "		FJK_FILIAL	='" + XFilial("FJK")		+ "' AND "
cQuery += "		FJK_FORNEC	>='" + MV_PAR01				+ "' AND "
cQuery += "		FJK_FORNEC	<='" + MV_PAR02				+ "' AND "
cQuery += "		FJK_LOJA	>='" + MV_PAR03				+ "' AND "
cQuery += "		FJK_LOJA	<='" + MV_PAR04				+ "' AND "
cQuery += "		FJK_DTDIG	>='" + DToS(MV_PAR05)		+ "' AND "
cQuery += "		FJK_DTDIG	<='" + DToS(MV_PAR06)		+ "' AND "
cQuery += "		FJK_PREOP	>='" + MV_PAR07				+ "' AND "
cQuery += "		FJK_PREOP	<='" + MV_PAR08				+ "' AND "
cQuery += "		FJK_MOEDA	='"  + StrZero(MV_PAR10,2)	+ "' AND "
cQuery += "		FJK_DTCANC	=	' ' AND " //Filtra registro reprovado ou cancelado
cQuery += "		FJK_ORDPAG	=	' ' AND " //Filtra registro baixado
cQuery += "		FJK_DTANLI	=	' ' AND " //Filtra registro aprovados
cQuery += "		D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasFJK, .F., .T.)
TcSetField(cAliasFJK, "FJK_DTDIG"	, "D")
TcSetField(cAliasFJK, "FJK_DTANLI"	, "D")
TcSetField(cAliasFJK, "FJK_DTCANC"	, "D")

DbSelectArea(cAliasFJK)
(cAliasFJK)->(DbGoTop())

//------------------------------------------------------------
// Zera a tabela FJKTEMP caso os parametros sejam redefinidos
//------------------------------------------------------------
FJKTEMP->(DbGoTop())
While FJKTEMP->(!Eof())
	RecLock("FJKTEMP",.F.)
	FJKTEMP->(DbDelete())
	FJKTEMP->(MsUnlock())
FJKTEMP->(DbSkip())
EndDo

While (cAliasFJK)->(!Eof())

	RecLock("FJKTEMP",.T.)
	For nX := 1 To FJK->(FCount())

		If AllTrim(FJKTEMP->(FieldName(nX))) == "FJK_FILIAL"
			FJKTEMP->(FieldPut(nX,XFilial("FJKTEMP")))
		ElseIf AllTrim(FJKTEMP->(FieldName(nX))) == "FJK_OK"
			FJKTEMP->(FieldPut(nX,CriaVar("FJK_OK",.F.)))
		Else
			cCampoTab := FJKTEMP->(FieldName(nX))
			FJKTEMP->(FieldPut(nX,(cAliasFJK)->(&cCampoTab)))
		EndIf

	Next nX
	FJKTEMP->(MsUnlock())

(cAliasFJK)->(DbSkip())
EndDo

(cAliasFJK)->(DbCloseArea())

FJKTEMP->(DbGoTop())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855FJKTeบ Autor ณ Microsiga          บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera a tabela temporaria com base na FJK                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855FJKTe()
Local aStruct	:= {}

DbSelectArea("FJK")
aStruct := FJK->(DbStruct())

aOrdem	:=	STRTOKARR ( ALLTRIM( FJK->(IndexKey(1)) ) , "+" ) //JGR
oTmpFJK := FWTemporaryTable():New("FJKTEMP") //JGR
oTmpFJK:SetFields( aStruct )
oTmpFJK:AddIndex("I1", aOrdem)
oTmpFJK:Create()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINA855  บ Autor ณ Marylly A. Silva   บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para marcar o tํtulo no duplo click sobre a linha doบฑฑ
ฑฑบ          ณ registro do tํtulo a pagar que serแ incluํdo na pr้-ordem  บฑฑ
ฑฑบ          ณ de pagamento.											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855FJKMa()

Local lCcr		:= .F.
	
If cPaisLoc=="ARG" .And. SE2->(ColumnPos("E2_CCR")) > 0 
	lCcr:=.t.
EndIf

If  lCcr .And.!Empty(MV_PAR10)
	FJKTEMP->FJK_OK := cMarca
Else

	If cMarca == Nil
		cMarca := ""
	EndIf

	If FJKTEMP->(!Eof())
		Reclock("FJKTEMP",.F.)
		If FJKTEMP->FJK_OK == cMarca
			FJKTEMP->FJK_OK := " "
		Else
			FJKTEMP->FJK_OK := cMarca
		EndIf
		FJKTEMP->(MsUnlock())
	EndIf
Endif	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F855AtCl บ Autor ณ Marylly A. Silva   บ Data ณ  13/01/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca ou Desmarca todos os tํtulos na sele็ใo de tํtulos a บฑฑ
ฑฑบ          ณ a pagar da pr้-ordem de pagamento.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855AtCl(lCheck)
	
Local aArea		:= GetArea()
Local aAreaFJK	:= FJKTEMP->(GetArea())

FJKTEMP->( DbGoTop() )

While !FJKTEMP->(Eof())

	Reclock("FJKTEMP",.F.)

	If lCheck
		FJKTEMP->FJK_OK := cMarca
	Else
		FJKTEMP->FJK_OK := " "
	EndIf

	FJKTEMP->(MsUnlock())
	FJKTEMP->(DbSkip())
EndDo

lCheck := !lCheck

RestArea(aArea)
RestArea(aAreaFJK)

oBrwSTit:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855SelApบ Autor ณMarylly A. Silva    บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de abertura da tela de filtro e sele็ใo de tํtulos  บฑฑ
ฑฑบ          ณ que serใo cancelados na pr้-ordem de pago.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855SelCa()
Local bInitBr	:= Nil
Local aButtons	:= {}
Local lRet		:= .T.
Local lConfirm	:= .F.
Local nX		:= 0
Local nMarked   := 0
Local lAprova	:= .T.
Local nLoop     := 0

Private oDlgSel
Private oBrwSTit
Private oOK
Private oNOK
Private lCheck	:= .T.
Private oTmpFJK
Private aOrdem     := {} //JGR

If Pergunte("FIN855CN",.T.)

	//---------------------------------
	// Cria a tabela temporaria da FJK
	//---------------------------------
	FA855FJKTe() //jgr

	//-------------------------------------------------------------------------
	// Carrega a tabela temporaria com os registros que atendem aos parametros
	//-------------------------------------------------------------------------
	FA855FJKCN()

	If FJKTEMP->(!Eof())

		oOK		:= LoadBitmap(GetResources(),"wfchk")
		oNOK	:= LoadBitmap(GetResources(),"wfunchk")

		Define MsDialog oDlgSel Title STR0026 From 000,000 To 540,756 Pixel //"Titulos a pagar"

		If cMarca == Nil
			cMarca := ""
		EndIf

		oBrwSTit := TCBrowse():New(0,0,10,10,,,,oDlgSel,,,,,{|| FA855FJKMa()},,,,,,,,"FJKTEMP",.T.,,,,.T.,)
		oBrwSTit:AddColumn(TCColumn():New("  "					,{|| If(FJKTEMP->FJK_OK == cMarca,oOK,oNOK)},                            ,,,,010,.T.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_FORNEC"),{|| FJKTEMP->FJK_FORNEC}                   ,                            ,,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_LOJA")	,{|| FJKTEMP->FJK_LOJA}                     ,                            ,,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_PREOP")	,{|| FJKTEMP->FJK_PREOP}                    ,                            ,,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_MOEDA")	,{|| FJKTEMP->FJK_MOEDA}                    ,""                          ,,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_VLRPRE"),{|| FJKTEMP->FJK_VLRPRE}                   ,PesqPict("FJK","FJK_VLRPRE"),,,,020,.F.,.F.,,,,,))
		oBrwSTit:AddColumn(TCColumn():New(RetTitle("FJK_VLCONV"),{|| FJKTEMP->FJK_VLCONV}                   ,PesqPict("FJK","FJK_VLCONV"),,,,020,.F.,.F.,,,,,))
		oBrwSTit:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwSTit:Refresh()

		//Bloco a ser executado ao "Confirmar" a tela -> <CTRL+O>
		bSetConf :=	{ || If(F855VldSel(),(lConfirm := .T., GetKeys() , SetKey( VK_F3 , Nil ) , oDlgSel:End()),Nil)}

		//Bloco a ser executado ao "Finalizar" a tela -> <CTRL+X>
		bSetFech := { || lConfirm := .F. ,GetKeys() , SetKey( VK_F3 , Nil ) , oDlgSel:End() }

		//Acoes relacionadas
		aAdd(aButtons,{"Parametros"				,{|| Pergunte("FIN855CN",.T.),cMarca := GetMark(),FA855FJKCN(),oBrwSTit:DrawSelect()}	,OemToAnsi(STR0028),OemToAnsi(STR0028)}) //"Parโmetros"
		aAdd(aButtons,{"Marca_Desmarca_Todos"	,{|| FA855AtCl(@lCheck)}																,OemToAnsi(STR0069),OemToAnsi(STR0069)}) //"Marca/Desmarca Todos"
		aAdd(aButtons,{"Pesquisa"				,{|| F855PsqPre()}																		,OemToAnsi(STR0029),OemToAnsi(STR0029)}) //"Pesquisa"

		//Bloco para montagem da tela de sele็ใo de tํtulos a pagar para composi็ใo da pr้-ordem de pago
		bInitBr := { || EnchoiceBar( oDlgSel , bSetConf , bSetFech , Nil , aButtons )}
		oDlgSel:bInit := bInitBr

		Activate MsDialog oDlgSel Center

		If lConfirm
			//------------------------------------------------------
			// Grava os registros selecionados na tabela temporaria
			//------------------------------------------------------
            nMarked := 0    // Conta quantos foram marcados

			FJKTEMP->(DbGoTop())
			While FJKTEMP->(!Eof())

				If FJKTEMP->FJK_OK == cMarca

                    nMarked ++  // Incrementa Contador

					//--------------------------------------------
					// Define se as Pre-Ordens serao visualizadas
					//--------------------------------------------
					If MV_PAR09 == 2 //Nao

						DbSelectArea("FJK")
						DbSetOrder(1)
						If MsSeek(XFilial("FJK")+FJKTEMP->(FJK_FORNEC+FJK_LOJA+FJK_PREOP))
							If MV_PAR11 == 2 //Cancela a aprovacao da Pre-Ordem

								RecLock("FJK",.F.)
								FJK->FJK_DTANLI := CToD("  /  /  ")
								FJK->(MsUnlock())
							Else
								//----------------------------------
								// Remove a referencia com o titulo
								//----------------------------------
								DbSelectArea("FJL")
								FJL->(DbSetOrder(1))
								If FJL->(MsSeek(xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)))
									While FJL->(!Eof()) .And. FJL->(FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP) == xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)
										DbSelectArea("SE2")
										DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
										If MsSeek(XFilial("SE2")+FJL->(FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO+FJL_FORNEC+FJL_LOJA))

											RecLock("SE2",.F.)
											SE2->E2_PREOP	:= ""
											SE2->E2_PREOK	:= " "
											SE2->E2_VLBXPAR	:= 0
											SE2->E2_OK		:= ""
											SE2->(MsUnlock())

										EndIf
									FJL->(DbSkip())
									EndDo
								EndIf
								
								//Al cancelar la Orden de Pago Previa se borran los registros correspondientes de las Retenciones
								If TableInDic("FVC")
									DBSELECTAREA("FVC")
									FVC->(DBSETORDER(1)) //FVC_FILIAL+FVC_PREOP+FVC_TIPO
									If FVC->(MsSeek(xFilial("FVC")+FJK->FJK_PREOP))
										While FVC->(!Eof()) .and. FJK->FJK_PREOP == FVC->FVC_PREOP
											RecLock("FVC",.F.)
											FVC->(DbDelete())
											FVC->(MsUnlock())
											FVC->(DbSkip())
										Enddo
									EndIf
								EndIf
								
								//Cancela a Pre-OP
								RecLock("FJK",.F.)
								FJK->FJK_DTCANC := dDataBase
								FJK->(MsUnlock())
							EndIf
						EndIf

					Else

						DbSelectArea("FJK")
						DbSetOrder(1)
						If MsSeek(XFilial("FJK")+FJKTEMP->(FJK_FORNEC+FJK_LOJA+FJK_PREOP))
							//----------------------------------------------------
							// Alimenta a tabela temporaria para montagem da tela
							//----------------------------------------------------
							DbSelectArea("FJL")
							FJL->(DbSetOrder(1))
							If FJL->(MsSeek(xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)))
								While FJL->(!Eof()) .And. FJL->(FJL_FILIAL+FJL_FORNEC+FJL_LOJA+FJL_PREOP) == xFilial("FJL")+ FJK->(FJK_FORNEC+FJK_LOJA+FJK_PREOP)
									DbSelectArea("SE2")
									DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
									If MsSeek(XFilial("SE2")+FJL->(FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO+FJL_FORNEC+FJL_LOJA))

										RecLock("FA855SE2",.T.)
											FA855SE2->E2_FILIAL		:= XFilial("SE2")
											FA855SE2->E2_PREFIXO	:= SE2->E2_PREFIXO
											FA855SE2->E2_NUM		:= SE2->E2_NUM
											FA855SE2->E2_PARCELA	:= SE2->E2_PARCELA
											FA855SE2->E2_TIPO		:= SE2->E2_TIPO
											FA855SE2->E2_NATUREZ	:= SE2->E2_NATUREZ
											FA855SE2->E2_FORNECE	:= SE2->E2_FORNECE
											FA855SE2->E2_LOJA		:= SE2->E2_LOJA
											FA855SE2->E2_NOMFOR	:= SE2->E2_NOMFOR
											FA855SE2->E2_EMISSAO	:= SE2->E2_EMISSAO
											FA855SE2->E2_VENCTO	:= SE2->E2_VENCTO
											FA855SE2->E2_VENCREA	:= SE2->E2_VENCREA
											FA855SE2->E2_VALOR	:= SE2->E2_VALOR
											If cPaisloc == "RUS"
												FA855SE2->E2_BASIMP1	:= SE2->E2_BASIMP1
												FA855SE2->E2_ALQIMP1	:= SE2->E2_ALQIMP1
												FA855SE2->E2_VALIMP1	:= SE2->E2_VALIMP1
												FA855SE2->E2_MDCONTR	:= SE2->E2_MDCONTR
											EndIf
											FA855SE2->E2_SALDO	:= SE2->E2_SALDO
											FA855SE2->E2_OK		:= SE2->E2_OK
											FA855SE2->E2_MOEDA	:= SE2->E2_MOEDA
											FA855SE2->E2_DATALIB	:= SE2->E2_DATALIB
											FA855SE2->E2_PREOK	:= SE2->E2_PREOK
											FA855SE2->E2_TXMOEDA	:= SE2->E2_TXMOEDA
											FA855SE2->E2_VLBXPAR	:= SE2->E2_VLBXPAR
											FA855SE2->E2_PREOP	:= SE2->E2_PREOP
											FA855SE2->E2_STATLIB	:= SE2->E2_STATLIB
											FA855SE2->E2_VALPOP	:= FJL->FJL_VLRPRE
											FA855SE2->E2_RECNO	:= SE2->(Recno())
											FA855SE2->E2_MOEPOP	:= FJK->FJK_MOEDA
											If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
												For nLoop := 1 To Len(a855Cpos)
													FA855SE2->&(a855Cpos[nLoop][1][2]) := FJL->&(a855Cpos[nLoop][2][1])
												Next
											EndIf
											FA855SE2->E2_DELET	:= ""
										FA855SE2->(MsUnlock())

									EndIf
								FJL->(DbSkip())
								EndDo
							EndIf

						EndIf

					EndIf

				EndIf

			FJKTEMP->(DbSkip())
			EndDo

            If nMarked == 0   // Opa ... Confirmou sem marcar nada
				lRet := .F.
			EndIf

			If ( MV_PAR09 == 2 ) .And. ( nMarked > 0 )
				lRet := .F. //Retorna falso para nao exibir a tela
				MsgAlert(STR0085) //"Processo concluido"
			EndIf

			FA855SE2->(DbGoTop())

		Else
			lRet := .F.
		EndIf

	Else
		lRet := .F.
		Help(" ",1,"F855PRETIT") //"Nใo existem tํtulos que atendam aos parโmetros informados."|"Verifique a configura็ใo de parโmetros."
	EndIf

	If oTmpFJK <> Nil   //jgr
		oTmpFJK:Delete()  //jgr
		oTmpFJK := Nil //jgr
	Endif //jgr

Else
	lRet := .F.
EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA855   บ Autor ณ Marylly A. Silva   บ Data ณ  08/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alimenta a tabela temporaria com as Pre-OP que atendem ao  บฑฑ
ฑฑบ          ณ filtro.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855FJKCN()
Local nX		:= 0
Local cAliasFJK	:= GetNextAlias()
Local cCampoTab	:= ""

//------------------------------
// MV_PAR01 - Fornecedor de
// MV_PAR02 - Fornecedor ate
// MV_PAR03 - Loja de
// MV_PAR04 - Loja ate
// MV_PAR05 - Data de
// MV_PAR06 - Data ate
// MV_PAR07 - Pre-Ordem de
// MV_PAR08 - Pre-Ordem ate
// MV_PAR09 - Exibe detalhe
// MV_PAR10 - Moeda
// MV_PAR11 - Cancela
//------------------------------

cQuery := "SELECT * FROM " + RetSqlTab("FJK")
cQuery += "	WHERE "
cQuery += "		FJK_FILIAL	='" + XFilial("FJK")		+ "' AND "
cQuery += "		FJK_FORNEC	>='" + MV_PAR01				+ "' AND "
cQuery += "		FJK_FORNEC	<='" + MV_PAR02				+ "' AND "
cQuery += "		FJK_LOJA	>='" + MV_PAR03				+ "' AND "
cQuery += "		FJK_LOJA	<='" + MV_PAR04				+ "' AND "
cQuery += "		FJK_DTDIG	>='" + DToS(MV_PAR05)		+ "' AND "
cQuery += "		FJK_DTDIG	<='" + DToS(MV_PAR06)		+ "' AND "
cQuery += "		FJK_PREOP	>='" + MV_PAR07				+ "' AND "
cQuery += "		FJK_PREOP	<='" + MV_PAR08				+ "' AND "
cQuery += "		FJK_MOEDA	='"  + StrZero(MV_PAR10,2)	+ "' AND "
cQuery += "		FJK_DTCANC	=	' ' AND " //Filtra registro reprovado ou cancelado
cQuery += "		FJK_ORDPAG	=	' ' AND " //Filtra registro baixado
If MV_PAR11 == 1 //Cancela Pre-Ordem no status original
	cQuery += "	FJK_DTANLI	=	' ' AND " //Filtra registro aprovados
Else //Cancela Pre-Ordem no status aprovada
	cQuery += "	FJK_DTANLI	<>	' ' AND " //Filtra registro aprovados
EndIf

cQuery += "		D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasFJK, .F., .T.)
TcSetField(cAliasFJK, "FJK_DTDIG"	, "D")
TcSetField(cAliasFJK, "FJK_DTANLI"	, "D")
TcSetField(cAliasFJK, "FJK_DTCANC"	, "D")

DbSelectArea(cAliasFJK)
(cAliasFJK)->(DbGoTop())

//------------------------------------------------------------
// Zera a tabela FJKTEMP caso os parametros sejam redefinidos
//------------------------------------------------------------
FJKTEMP->(DbGoTop())
While FJKTEMP->(!Eof())
	RecLock("FJKTEMP",.F.)
	FJKTEMP->(DbDelete())
	FJKTEMP->(MsUnlock())
FJKTEMP->(DbSkip())
EndDo

While (cAliasFJK)->(!Eof())

	RecLock("FJKTEMP",.T.)
	For nX := 1 To FJK->(FCount())

		If AllTrim(FJKTEMP->(FieldName(nX))) == "FJK_FILIAL"
			FJKTEMP->(FieldPut(nX,XFilial("FJKTEMP")))
		ElseIf AllTrim(FJKTEMP->(FieldName(nX))) == "FJK_OK"
			FJKTEMP->(FieldPut(nX,CriaVar("FJK_OK",.F.)))
		Else
			cCampoTab := FJKTEMP->(FieldName(nX))
			FJKTEMP->(FieldPut(nX,(cAliasFJK)->(&cCampoTab)))
		EndIf

	Next nX
	FJKTEMP->(MsUnlock())

(cAliasFJK)->(DbSkip())
EndDo

(cAliasFJK)->(DbCloseArea())

FJKTEMP->(DbGoTop())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855GrvMoบAutor  ณMicrosiga           บ Data ณ  08/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava na tabela temporaria a moeda definida para a Pre OP  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA855GrvMo()
	
	If FA855SE2->(MsSeek(XFilial("SE2")+oGridPreOP:aCols[oGridPreOP:nAt][1]+oGridPreOP:aCols[oGridPreOP:nAt][2]))
		While FA855SE2->(!Eof()) .And. FA855SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA) == XFilial("SE2")+oGridPreOP:aCols[oGridPreOP:nAt][1]+oGridPreOP:aCols[oGridPreOP:nAt][2]
			If FA855SE2->E2_PREOP == oGridPreOP:aCols[oGridPreOP:nAt][3]
				RecLock("FA855SE2",.F.)
				FA855SE2->E2_MOEPOP := cMoeda
				FA855SE2->(MsUnlock())
			EndIf
			FA855SE2->(DbSkip())
		EndDo
	EndIf
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA855AtPOPบAutor  ณMicrosiga           บ Data ณ  08/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza os dados da grid de Pre-Ordem de pagamento        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaFin - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA855AtPOP()
Local cForn			:= ""
Local cLoj			:= ""
Local cNumPreOp		:= ""
Local nNumTit		:= 0
Local nValTit		:= 0
Local nSinal		:= 1
Local nValRet		:= 0
Local nValPreOP		:= 0
Local aTitulos		:= 0

oGridPreOP:aCols := {}
FA855SE2->(DbGoTop())
While FA855SE2->(!EOF())

	cForn		:= FA855SE2->E2_FORNECE
	cLoj		:= FA855SE2->E2_LOJA
	nNumTit		:= 0
	nValTit		:= 0
	nValRet		:= 0
	nValPreOP	:= 0
	aTitulos	:= {}

	cNumPreOp	:= FA855SE2->E2_PREOP

	While FA855SE2->(!EOF()) .And. FA855SE2->E2_PREOP == cNumPreOp
		//--------------------------------
		// Desconsidera titulos deletados
		//--------------------------------
		If !Empty(FA855SE2->E2_DELET)
			FA855SE2->(DbSkip())
			Loop
		EndIf

		//------------------------------------------
		// Conta o numero de titulos por fornecedor
		//------------------------------------------
		nNumTit++

		//-----------------------------------------------------------
		// Armazena os titulos para realizar o calculo das retencoes
		//-----------------------------------------------------------
		If FA855SE2->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG
			nSinal := -1
		Else
			nSinal := 1
		EndIf
		SE2->(DbGoTo(FA855SE2->E2_RECNO))
		AAdd(aTitulos,{SE2->E2_FILIAL,SE2->E2_FORNECE,SE2->E2_LOJA, SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->(Recno()),FA855SE2->E2_VALPOP,SE2->E2_FORNECE,SE2->E2_LOJA,"","","","",""})

		//------------------------------------
		// Armazena o valor total dos titulos
		//------------------------------------
		nValTit += (XMoeda(FA855SE2->E2_VALPOP,FA855SE2->E2_MOEDA,1,dDataBase,FA855SE2->E2_TXMOEDA)* nSinal)

	FA855SE2->(DbSkip())
	EndDo

	//---------------------------------
	// Obtem o valor das das retencoes
	//---------------------------------
	FA855Reten(aTitulos,,@nValRet)

	//----------------------------
	// Efetua o calculo da Pre-OP
	//----------------------------
	nValPreOp := nValTit - nValRet

	Aadd(oGridPreOP:aCols,{cForn,cLoj,cNumPreOp,nNumTit,nValPreOp,.F.})

EndDo

oGridPreOP:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF855PsqPreบAutor  ณMicrosiga           บ Data ณ  08/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F855PsqPre()
Local oDlg
Local oFornece,oLoja,oRazao,oNum,oMoeda
Local cForn	 	:= CriaVar("A2_COD")
Local cLoj	 	:= CriaVar("A2_LOJA")
Local cRazao 	:= CriaVar("A2_NOME")
Local cNum 		:= CriaVar("FJK_PREOP")
Local cMoeda 	:= CriaVar("FJK_MOEDA")

Local nOpcao := 0

DEFINE MSDIALOG oDlg TITLE STR0070 FROM 3,0 TO 240,500 PIXEL // "Busca de documento"

//FORNECEDOR
@ 05,10 To 45,240 Pixel Of oDlg LABEL OemToAnsi(STR0028)
//DOCUMENTO
@ 50,10 To 90,240 Pixel Of oDlg LABEL OemToAnsi(STR0033)

@ 15,15 SAY OemToAnsi(STR0034) Size 70,08 Pixel Of oDlg //"Fornecedor"
@ 25,15 MSGET oFornece VAR cForn F3 "SA2" PICTURE PesqPict("SA2","A2_COD") VALID {|| cLoj := SA2->A2_LOJA, cRazao := SA2->A2_NOME} SIZE 12,10 PIXEL OF oDlg

@ 15,55 SAY OemToAnsi(STR0009) Size 70,08 Pixel Of oDlg //"Loja"
@ 25,55 MSGET oLoja VAR cLoj PICTURE PesqPict("SA2","A2_LOJA") SIZE 12,10 PIXEL OF oDlg

@ 15,74 SAY OemToAnsi(STR0010) Size 100,08 Pixel Of oDlg //"Razao Social"
@ 25,74 MSGET oRazao VAR cRazao PICTURE PesqPict("SA2","A2_NOME") SIZE 150,10 PIXEL OF oDlg
oRazao:Disable()

@ 60,15 SAY OemToAnsi(STR0036) Size 70,08 Pixel Of oDlg //"Numero"
@ 70,15 MSGET oNum VAR cNum PICTURE PesqPict("FJK","FJK_PREOP")SIZE 90,10 PIXEL OF oDlg

@ 60,117 SAY OemToAnsi(STR0063) Size 100,08 Pixel Of oDlg //"Moeda"
@ 70,117 MSGET oMoeda VAR cMoeda PICTURE PesqPict("FJK","FJK_MOEDA") SIZE 20,10 PIXEL OF oDlg

DEFINE SBUTTON FROM 100,185 TYPE 1 ACTION {|| nOpcao := 1,oDlg:End()} ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 100,215 TYPE 2 ACTION {||oDlg:End()} ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTER

If nOpcao == 1 //Confirma

	If !FJKTEMP->(MsSeek(xFilial("FJKTEMP")+cForn+cLoj+cNum+cMoeda))
		FJKTEMP->(DbGoTop())
		MsgAlert(STR0038) //"Nใo foi possivel localizar o tํtulo."
		F855PsqPre() //Abro a tela de pesquisa novamente
	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF855SelNatบAutor  ณMicrosiga           บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processo de selecao manual das naturezas no filtro dos     บฑฑ
ฑฑบ          ณ titulos para composicao da Pre-OP                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F855SelNat(aSelNat)
Local bInitBr	:= Nil
Local aButtons	:= {}
Local lRet		:= .T.
Local lConfirm	:= .F.
Local cMarcaSED	:= ""

Private oDlgSel
Private oBrwSTit
Private oOK
Private oNOK
Private lCheck	:= .T.
Private oTmpSED
Private aOrdem     := {} //JGR

//---------------------------------
// Cria a tabela temporaria da SED
//---------------------------------
F855SEDTmp()

//-------------------------------------------------------------------------
// Carrega a tabela temporaria com os registros que atendem aos parametros
//-------------------------------------------------------------------------
F855SEDCar()

If SEDTEMP->(!Eof())

	cMarcaSED := GetMark()

	oOK		:= LoadBitmap(GetResources(),"wfchk")
	oNOK	:= LoadBitmap(GetResources(),"wfunchk")

	Define MsDialog oDlgSel Title STR0089 From 000,000 To 540,500 Pixel //"Naturezas"

	oBrwSTit := TCBrowse():New(0,0,10,10,,,,oDlgSel,,,,,{|| F855SEDMrk(cMarcaSED)},,,,,,,,"SEDTEMP",.T.,,,,.T.,)
	oBrwSTit:AddColumn(TCColumn():New("  "					,{|| If(SEDTEMP->ED_OK == cMarcaSED,oOK,oNOK)}	,								,,,,010,.T.,.F.,,,,,))
	oBrwSTit:AddColumn(TCColumn():New(RetTitle("ED_CODIGO")	,{|| SEDTEMP->ED_CODIGO}						,PesqPict("SED","ED_CODIGO")	,,,,040,.F.,.F.,,,,,))
	oBrwSTit:AddColumn(TCColumn():New(RetTitle("ED_DESCRIC"),{|| SEDTEMP->ED_DESCRIC}						,PesqPict("SED","ED_DESCRIC")	,,,,100,.F.,.F.,,,,,))
	oBrwSTit:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwSTit:Refresh()

	//Bloco a ser executado ao "Confirmar" a tela -> <CTRL+O>
	bSetConf := { || lConfirm := .T., GetKeys() , SetKey( VK_F3 , Nil ) , oDlgSel:End() }

	//Bloco a ser executado ao "Finalizar" a tela -> <CTRL+X>
	bSetFech := { || lConfirm := .F. ,GetKeys() , SetKey( VK_F3 , Nil ) , oDlgSel:End() }

	//Acoes relacionadas
	aAdd(aButtons,{"Marca_Desmarca_Todos"	,{|| F855AtuCli(cMarcaSED)}	,OemToAnsi(STR0069),OemToAnsi(STR0069)}) //"Marca/Desmarca Todos"

	//Bloco para montagem da tela de sele็ใo de tํtulos a pagar para composi็ใo da pr้-ordem de pago
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
				Aadd(aSelNat,SEDTEMP->ED_CODIGO)
			EndIf

		SEDTEMP->(DbSkip())
		EndDo
	EndIf

EndIf

If oTmpSED <> Nil   //jgr
	oTmpSED:Delete()  //jgr
	oTmpSED := Nil //jgr
Endif //jgr

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF855SEDTmpบ Autor ณ Microsiga          บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera a tabela temporaria com base na SED                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F855SEDTmp()
Local aStruct	:= {}

AAdd(aStruct,{"ED_OK"		,"C", 02						,0}) //Adiciona o campo para marcacao na MarkBrow
AAdd(aStruct,{"ED_CODIGO"	,"C", TamSX3("ED_CODIGO")[1]	,0})
AAdd(aStruct,{"ED_DESCRIC"	,"C", TamSX3("ED_DESCRIC")[1]	,0})

aOrdem	:=	{"ED_CODIGO"} //JGR
oTmpSED := FWTemporaryTable():New("SEDTEMP") //JGR
oTmpSED:SetFields( aStruct )
oTmpSED:AddIndex("I1", aOrdem)
oTmpSED:Create()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF855SEDCarบAutor  ณMicrosiga           บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Alimenta a tabela temporaria com as naturezas que atendem  บฑฑ
ฑฑบ          ณ ao filtro                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F855SEDCar()
Local cAliasSED	:= GetNextAlias()

//-------------------------------
// FIP855
// MV_PAR01 - Vencimento De
// MV_PAR02 - Vencimento Ate
// MV_PAR03 - Fornecedor De
// MV_PAR04 - Fornecedor Ate
// MV_PAR05 - Loja De
// MV_PAR06 - Loja Ate
// MV_PAR07 - Natureza De
// MV_PAR08 - Natureza Ate
// MV_PAR09 - Seleciona Natureza
//-------------------------------

cQuery := "SELECT ED_CODIGO,ED_DESCRIC FROM " + RetSqlTab("SED")
cQuery += "	WHERE "
cQuery += "		ED_FILIAL	='"		+ XFilial("SED")	+ "' AND "
cQuery += "		ED_CODIGO	>='"	+MV_PAR07			+ "' AND "
cQuery += "		ED_CODIGO	<='"	+MV_PAR08			+ "' AND "
cQuery += "     ED_TIPO IN (' ','2') AND "
cQuery += "		D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSED, .F., .T.)

DbSelectArea(cAliasSED)

While (cAliasSED)->(!Eof())

	RecLock("SEDTEMP",.T.)

	SEDTEMP->ED_OK		:= Space(2)
	SEDTEMP->ED_CODIGO	:= (cAliasSED)->ED_CODIGO
	SEDTEMP->ED_DESCRIC	:= (cAliasSED)->ED_DESCRIC

	SEDTEMP->(MsUnlock())

(cAliasSED)->(DbSkip())
EndDo

(cAliasSED)->(DbCloseArea())

SEDTEMP->(DbGoTop())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF855SEDMrkบAutor  ณMicrosiga           บ Data ณ  15/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para marcar a natureza no duplo click para definicaoบฑฑ
ฑฑบ          ณ do filtro dos titulos para montagem da Pre-OP              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F855SEDMrk(cMarcaSED)

If cMarcaSED == Nil
	cMarcaSED := ""
EndIf

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F855AtCl บ Autor ณ Marylly A. Silva   บ Data ณ  13/01/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca ou Desmarca todos os tํtulos na sele็ใo de tํtulos a บฑฑ
ฑฑบ          ณ a pagar da pr้-ordem de pagamento.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M๓dulo Financeiro (Argentina)                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F855AtuCli(cMarcaSED)
Local aArea		:= GetArea()
Local aAreaSED	:= SEDTEMP->(GetArea())

SEDTEMP->(DbGoTop())
While !SEDTEMP->(Eof())
	Reclock("SEDTEMP",.F.)
	If SEDTEMP->ED_OK != cMarcaSED
		SEDTEMP->ED_OK := cMarcaSED
	Else
		SEDTEMP->ED_OK := Space(2)
	EndIf
	SEDTEMP->(MsUnlock())
SEDTEMP->(DbSkip())
EndDo

RestArea(aArea)
RestArea(aAreaSED)

oBrwSTit:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF855TmpSelบAutor  ณMicrosiga           บ Data ณ  16/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tabela temporia auxiliar para selecao dos titulos para a   บฑฑ
ฑฑบ          ณ Pre-OP                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN - Argentina                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F855TmpSel()
Local aStruct	:= {}
Local nX        := 0

AAdd( aStruct, {"E2_FILIAL"		,"C", TamSX3("E2_FILIAL")[1]	,TamSX3("E2_FILIAL")[2]		} )
AAdd( aStruct, {"E2_PREFIXO"	,"C", TamSX3("E2_PREFIXO")[1]	,TamSX3("E2_PREFIXO")[2]	} )
AAdd( aStruct, {"E2_NUM"		,"C", TamSX3("E2_NUM")[1]		,TamSX3("E2_NUM")[2]		} )
AAdd( aStruct, {"E2_PARCELA"	,"C", TamSX3("E2_PARCELA")[1]	,TamSX3("E2_PARCELA")[2]	} )
AAdd( aStruct, {"E2_TIPO"		,"C", TamSX3("E2_TIPO")[1]		,TamSX3("E2_TIPO")[2]		} )
AAdd( aStruct, {"E2_NATUREZ"	,"C", TamSX3("E2_NATUREZ")[1]	,TamSX3("E2_NATUREZ")[2]	} )
AAdd( aStruct, {"E2_FORNECE"	,"C", TamSX3("E2_FORNECE")[1]	,TamSX3("E2_FORNECE")[2]	} )
AAdd( aStruct, {"E2_LOJA"		,"C", TamSX3("E2_LOJA")[1]		,TamSX3("E2_LOJA")[2]		} )
AAdd( aStruct, {"E2_NOMFOR"		,"C", TamSX3("E2_NOMFOR")[1]	,TamSX3("E2_NOMFOR")[2]		} )
AAdd( aStruct, {"E2_EMISSAO"	,"D", TamSX3("E2_EMISSAO")[1]	,TamSX3("E2_EMISSAO")[2]	} )
AAdd( aStruct, {"E2_VENCTO"		,"D", TamSX3("E2_VENCTO")[1]	,TamSX3("E2_VENCTO")[2]		} )
AAdd( aStruct, {"E2_VENCREA"	,"D", TamSX3("E2_VENCREA")[1]	,TamSX3("E2_VENCREA")[2]	} )
AAdd( aStruct, {"E2_VALOR"		,"N", TamSX3("E2_VALOR")[1]		,TamSX3("E2_VALOR")[2]		} )
If cPaisLoc == "RUS"
	AAdd( aStruct, {"E2_BASIMP1"	,"N", TamSX3("E2_BASIMP1")[1]	,TamSX3("E2_BASIMP1")[2]	} )
	AAdd( aStruct, {"E2_ALQIMP1"	,"N", TamSX3("E2_ALQIMP1")[1]	,TamSX3("E2_ALQIMP1")[2]	} )
	AAdd( aStruct, {"E2_VALIMP1"	,"N", TamSX3("E2_VALIMP1")[1]	,TamSX3("E2_VALIMP1")[2]	} )
	AAdd( aStruct, {"E2_MDCONTR"	,"C", TamSX3("E2_MDCONTR")[1]	,TamSX3("E2_MDCONTR")[2]	} )
EndIf
AAdd( aStruct, {"E2_SALDO"		,"N", TamSX3("E2_SALDO")[1]		,TamSX3("E2_SALDO")[2]		} )
AAdd( aStruct, {"E2_OK"			,"C", TamSX3("E2_OK")[1]		,TamSX3("E2_OK")[2]			} )
AAdd( aStruct, {"E2_MOEDA"		,"N", TamSX3("E2_MOEDA")[1]		,TamSX3("E2_MOEDA")[2]		} )
AAdd( aStruct, {"E2_DATALIB"	,"D", TamSX3("E2_DATALIB")[1]	,TamSX3("E2_DATALIB")[2]	} )
AAdd( aStruct, {"E2_PREOK"		,"C", TamSX3("E2_PREOK")[1]		,TamSX3("E2_PREOK")[2]		} )
AAdd( aStruct, {"E2_TXMOEDA"	,"N", TamSX3("E2_TXMOEDA")[1]	,TamSX3("E2_TXMOEDA")[2]	} )
AAdd( aStruct, {"E2_VLBXPAR"	,"N", TamSX3("E2_VLBXPAR")[1]	,TamSX3("E2_VLBXPAR")[2]	} )
AAdd( aStruct, {"E2_PREOP"		,"C", TamSX3("E2_PREOP")[1]		,TamSX3("E2_PREOP")[2]		} )
AAdd( aStruct, {"E2_STATLIB"	,"C", TamSX3("E2_STATLIB")[1]	,TamSX3("E2_STATLIB")[2]	} )
AAdd( aStruct, {"E2_RECNO"		,"N", 09						,0					   		} )
AAdd( aStruct, {"E2_DELET"		,"C", 01						,0					  		} )
AAdd( aStruct, {"E2_VALPOP"		,"N", TamSX3("E2_SALDO")[1]		,TamSX3("E2_SALDO")[2]		} )
AAdd( aStruct, {"E2_MOEPOP"		,"C", 2							,0					  		} )

If     Type ("lFA855Cpos") == "L"   .And.     lFA855Cpos  .And.  Type("a855Cpos") == "A" .And. Len(a855Cpos) > 0
	For nX := 1 To Len(a855Cpos)
		Aadd(aStruct,{a855Cpos[nX][1][2], a855Cpos[nX][1][8], a855Cpos[nX][1][4], a855Cpos[nX][1][5]})
	Next nX 
EndIf

aOrdem	:=	STRTOKARR ( ALLTRIM( SE2->(IndexKey(6)) ) , "+" ) //JGR
oTmpTMP := FWTemporaryTable():New("F855TMP") //JGR
oTmpTMP:SetFields( aStruct )
oTmpTMP:AddIndex("I1", aOrdem)
oTmpTMP:Create()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหอออออออออออหอออออหอออออออออออออออออออออออหออออออหอออออออออออปฑฑ
ฑฑบFuncao    บ OnOrRejQA บAutorบ Fernando Joly Siquini บ Data บ 08/22/12  บฑฑ
ฑฑฬออออออออออฮอออออออออออสอออออสอออออออออออออออออออออออสออออออสอออออออออออนฑฑ
ฑฑบDescicao  บ Verifica se uma NFE possui algum produto que ainda esteja  บฑฑ
ฑฑบ          บ no CQ ou que tenha passado pelo CQ e tenha sido rejeitado  บฑฑ
ฑฑฬออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       บ AP                                                         บฑฑ
ฑฑฬออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosบ ExpC1 - Numero do Documento de Entrada                     บฑฑ
ฑฑบ          บ ExpC2 - Serie do Documento de Entrada                      บฑฑ
ฑฑบ          บ ExpC3 - Codigo do Fornecedor                               บฑฑ
ฑฑบ          บ ExpC4 - Loja do Fornecedor                                 บฑฑ
ฑฑฬออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno  บ Logico - Verdadeiro se algum produto da NFE possuir saldo  บฑฑ
ฑฑบ          บ no CQ ou se possui qualquer quantidade rejeitada; Caso     บฑฑ
ฑฑบ          บ contrario o retorno sera Falso                             บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function OnOrRejQA(cDocOri, cSerieOri, cFornec, cLoja)
	
//--- Ambiente
Local aAreaAnt := GetArea()

//--- Retorno
Local lRet := .F.
Local lAux := .F.

//--- Genericas
Local cCondicao := ""
Local nCountRej := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Levantamento de Registros em Baixas de CQ ณ
//ณ D7_TIPO = 1 sao Itens em Analise          ณ
//ณ D7_TIPO = 2 sao Rejeitados                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

#IFDEF TOP

	BeginSQL Alias "SD7TMP"
		SELECT * FROM  %Table:SD7% SD7
		WHERE SD7.D7_FILIAL = %xFilial:SD7%
		AND SD7.D7_DOC = %Exp:cDocOri%
		AND SD7.D7_SERIE = %Exp:cSerieOri%
		AND SD7.D7_FORNECE = %Exp:cFornec%
		AND SD7.D7_LOJA = %Exp:cLoja%
		AND (SD7.D7_LIBERA = ' '
		OR  SD7.D7_TIPO = 2)
		AND SD7.D7_ESTORNO = ' '
		AND SD7.%NotDel%
	EndSQL

	If SD7TMP->(!Eof())

       dbSelectArea( "SD7TMP" )

       //--- Quantos registros estao na condicao Rejeitados ??
       DbEval( { || nCountRej++ }, { || SD7TMP->D7_TIPO == 2 }, , , )

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ O Ponto de Decisao : a principio, retorna ณ
       //ณ true para bloquear o pagamento do titulo. ณ
       //ณ SE existirem Rejeitados, aciona a busca   ณ
       //ณ pela Nota Fiscal de Devolucao.            ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
         //
         If nCountRej > 0   //-- Se tiver rejeitado qualquer quantidade
            //
	        lAux := ChkOnNDF( cFornec, cLoja, cSerieOri, cDocOri )
            //
            //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
            //ณ Retorno TRUE para ChkOnNDF significa que existe  ณ
            //ณ Nota de Debito gerada Contra o Fornecedor para   ณ
            //ณ para este DOC + SERIE, por conta de Rejeicao     ณ
            //ณ em processo de Inspecao de Qualidade.            ณ
            //ณ >> Nesse caso, LIBERA o titulo para PAGAMENTO !! ณ
            //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
            lRet := !lAux
            //
         Else

            lRet := .T.           // Bloqueia Pagamento !

         EndIf

	EndIf

	SD7TMP->( dbCloseArea() )

#ELSE

	cCondicao := "SD7->D7_FILIAL == '" +xFilial("SD7") +"' .And. SD7->D7_DOC = '" +cDocOri +"' .And. "
	cCondicao += "SD7->D7_SERIE == '" +cSerieOri +"' .And. SD7->D7_FORNECE = '" +cFornec+"' .And. SD7->D7_LOJA = '" +cLoja+"' .And. "
	cCondicao += "(SD7->D7_LIBERA == ' ' .Or. SD7->D7_TIPO = 2) .AND. SD7->D7_ESTORNO = ' ' .AND. D_E_L_E_T_=' ' "

    dbSelectArea( "SD7" )

	SD7->(dbSetFilter({|| &cCondicao},cCondicao))

	If SD7->(!Eof())

       //--- Quantos registros estao na condicao Rejeitados ??
       DbEval( { || nCountRej++ }, { || SD7->D7_TIPO == 2 }, , , )

         //
         If nCountRej > 0   //-- Se tiver rejeitado qualquer quantidade
            //
	        lAux := ChkOnNDF( cFornec, cLoja, cSerieOri, cDocOri )
            //
            //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
            //ณ Retorno TRUE para ChkOnNDF significa que existe  ณ
            //ณ Nota de Debito gerada Contra o Fornecedor para   ณ
            //ณ para este DOC + SERIE, por conta de Rejeicao     ณ
            //ณ em processo de Inspecao de Qualidade.            ณ
            //ณ >> Nesse caso, LIBERA o titulo para PAGAMENTO !! ณ
            //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
            lRet := !lAux
            //
         Else

            lRet := .T.           // Bloqueia Pagamento !

         EndIf

	EndIf

    dbClearFilter()
    RetIndex("SD7")

#ENDIF

RestArea( aAreaAnt )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออหออออออออออออออออออออออออหออออออหอออออออออออปฑฑ
ฑฑบFuncao    บ ChkOnNDF บAutorบ Carlos Eduardo Chigres บ Data บ 08/22/12  บฑฑ
ฑฑฬออออออออออฮออออออออออสอออออสออออออออออออออออออออออออสออออออสอออออออออออนฑฑ
ฑฑบDescricao บ Verifica se existe um Titulo NDF gerado por Rejeicao       บฑฑ
ฑฑบ          บ para o mesmo E2_NUM e E2_PREFIXO.                          บฑฑ
ฑฑฬออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       บ AP                                                         บฑฑ
ฑฑฬออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosบ ExpC1 - Codigo do Fornecedor                               บฑฑ
ฑฑบ          บ ExpC2 - Loja do Fornecedor                                 บฑฑ
ฑฑบ          บ ExpC3 - Serie do Documento de Entrada                      บฑฑ
ฑฑบ          บ ExpC4 - Numero do Documento de Entrada                     บฑฑ
ฑฑฬออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno  บ Logico - Verdadeiro se encontrar Nota de Debito gerada     บฑฑ
ฑฑบ          บ contra o Fornecedor, para o mesmo DOC + SERIE, por conta   บฑฑ
ฑฑบ          บ de Rejeicao em Processo de Inspecao de Qualidade.          บฑฑ
ฑฑศออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChkOnNDF( cFornece, cLoja, cSerieOri, cDocOri )
//---- Retorno
Local lFind    := .F.
Local aAreaAnt := GetArea()
Local aAreaSD2 := SD2->( GetArea() )
Local cChave   := xFilial("SD2") + cDocOri + cSerieOri

  dbSelectArea("SD2")
  //--- D2_FILIAL + D2_NFORI + D2_SERIORI
  dbSetOrder(10)

  lFind := MsSeek( cChave )

RestArea( aAreaSD2 )
RestArea( aAreaAnt )

Return( lFind )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF855LocNumบAutor  ณMicrosiga           บ Data ณ  27/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe codigo de Pre-OP para o fornecedor e    บฑฑ
ฑฑบ          ณ loja que esta sendo adicionado na Pre-OP                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F855LocNum(cPreOPFor,cPreOPLoj)
Local cNroPreOP	:= ""
Local aSaveArea	:= GetArea()
Local aSaveTMP	:= FA855SE2->(GetArea())

FA855SE2->(DbSetOrder(1))
	If FA855SE2->(MsSeek(XFilial("SE2")+cPreOPFor+cPreOPLoj))
		While FA855SE2->(!EOF()) .And. ( FA855SE2->(E2_FORNECE+E2_LOJA) == cPreOPFor+cPreOPLoj )
			If !Empty(FA855SE2->E2_PREOP)
				cNroPreOP := FA855SE2->E2_PREOP
				Exit
			EndIf
			FA855SE2->(DbSkip())
		EndDo
	EndIf

RestArea(aSaveTMP)
RestArea(aSaveArea)

Return(cNroPreOP)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF855VldSelบAutor  ณMicrosiga           บ Data ณ  27/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se houve selecao de algum registro                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F855VldSel()
Local lRet		:= .F.
Local aSaveArea	:= GetArea()
Local aSaveTMP	:= FJKTEMP->(GetArea())

DbSelectArea("FJKTEMP")
FJKTEMP->(DbGoTop())

While FJKTEMP->(!Eof())

	If FJKTEMP->FJK_OK == cMarca
		lRet := .T.
		Exit
	EndIf

FJKTEMP->(DbSkip())
EndDo

If !lRet
	MsgAlert(STR0091) //"Nenhum registro foi selecionado."
EndIf

RestArea(aSaveTMP)
RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAddCompCBUบAutor  ณLuis Samaniego      บ Data ณ 22/02/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Agrupar comprobantes a pagar a traves de CBU               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AddCompCBU()
Local lRet := .F.

	If VldFchCBU()
		lRet := VldPagCBU(1)
		If lRet
			aAdd(aPagConCBU, {F855TMP->E2_NUM, F855TMP->E2_PREFIXO, F855TMP->E2_FORNECE, F855TMP->E2_LOJA, RecNo()})
		EndIf
	Else
		lRet := VldPagCBU(2)
		If lRet
			aAdd(aPagSinCBU, {F855TMP->E2_NUM, F855TMP->E2_PREFIXO, F855TMP->E2_FORNECE, F855TMP->E2_LOJA, RecNo()})
		EndIf
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDelCompCBUบAutor  ณLuis Samaniego      บ Data ณ 22/02/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Excluye comprobantes a pagar a traves de CBU               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DelCompCBU()
Local nLoop := 0

	If SA2->(MsSeek( xFilial( "SA2" ) + F855TMP->E2_FORNECE + F855TMP->E2_LOJA, .F. ))
		If VldFchCBU()
			If Len(aPagConCBU) > 0
				nLoop := aScan(aPagConCBU,{|x| x[5] == RecNo()})
				aDel(aPagConCBU, nLoop)
				aSize(aPagConCBU, Len(aPagConCBU)-1)
				nLoop := 0
			EndIf
		Else
			If Len(aPagSinCBU) > 0
				nLoop := aScan(aPagSinCBU,{|x| x[5] == RecNo()})
				aDel(aPagSinCBU, nLoop)
				aSize(aPagSinCBU, Len(aPagSinCBU)-1)
				nLoop := 0
			EndIf
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldFchCBU บAutor  ณLuis Samaniego      บ Data ณ 22/02/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacion de fechas para pagos a traves de CBU            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldFchCBU()
Local lPagCBU := .T.
	If SA2->(MsSeek( xFilial( "SA2" ) + F855TMP->E2_FORNECE + F855TMP->E2_LOJA, .F. ))
		If !Empty(SA2->A2_CBUINI) .And. !Empty(SA2->A2_CBUFIM)
			If !(F855TMP->E2_EMISSAO >= SA2->A2_CBUINI .And. F855TMP->E2_EMISSAO <= SA2->A2_CBUFIM)
				lPagCBU := .F.
			EndIf
		Else
			lPagCBU := .F.
		EndIf
	EndIf
Return lPagCBU

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldPagCBU บAutor  ณLuis Samaniego      บ Data ณ 22/02/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacion de pagos a traves de CBU                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldPagCBU(nTipoCBU)
Local lPagCBU := .T.
	If nTipoCBU == 1
		If Len(aPagSinCBU) > 0 
			MessageBox(STR0100,"",16)
			lPagCBU := .F.
		ElseIf Len(aPagConCBU) == 0 
			MsgAlert(STR0100, STR0021)
		EndIf
	Else
		If Len(aPagConCBU) > 0 
			MessageBox(STR0100,"",16)
			lPagCBU := .F.
		EndIf
	EndIf
Return lPagCBU

/*ษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บDescricao ณ Valida el documento, para saber si debe mandar el mensaje  บ
  ศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/
Static Function VldDocPag(nRecNoSE2, lAll)
Local lRet  := .T.
Local nLoop := 0
	
Default nRecNoSE2 := 0
Default lAll      := .F.
	
	DbSelectArea("SE2")
	SE2->(dbSetOrder(6))
	If nRecNoSE2 == 0
		For nLoop := 1 To Len(aTitPreOrd)
			SE2->(dbGoto(aTitPreOrd[nLoop][5]))
			If SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == aTitPreOrd[nLoop][1]+aTitPreOrd[nLoop][2]+aTitPreOrd[nLoop][3]+aTitPreOrd[nLoop][4]
				If !Empty(SE2->E2_PREOK) .Or. (!Empty(SE2->E2_ORDPAGO) .And. SE2->E2_SALDO == 0)
					lRet  := .F.
				EndIf
			EndIf
		Next
		If !lRet
			If Len(aTitPreOrd) == 1
				MsgAlert(OemToAnsi(STR0101))
			Else
				MsgAlert(OemToAnsi(STR0102))
			EndIf
		EndIf
	Else
		SE2->(dbGoto(nRecNoSE2))
		If SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == F855TMP->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
			If !Empty(SE2->E2_PREOK) .Or. (!Empty(SE2->E2_ORDPAGO) .And. SE2->E2_SALDO == 0)
				lRet  := .F.
				If lAll
					MsgAlert(OemToAnsi(STR0101))
				EndIf
			EndIf
		EndIf
	EndIf
Return (lRet)



/*
ษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณF855GravRetบAutor  ณRaul Ortiz Medina   บ Data ณ  31/01/17   บ
ฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Realiza la gravaci๓n de los valores de Retenciones de una   บ
บ          ณ Orden de Pago Previa                                        บ
ฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA855                                                     บ
ศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Static Function F855GravRet(cPreOP,aSE2TMP,cFornec,cLoj,cParcel,lGan)
Local nX	   	  := 0
Local aRatCond  := {}
Local aRet		  := {}
Local aRatCond  := {}
Default aSE2TMP := {}
Default cFornec := ""
Default cLoj	  := ""
Default cParcel := ""
Default lGan	  := .F.
	
	If !lGan
		//Retenciones de IVA
		If ValType(aSE2TMP[_RETIVA]) == "A"
			For nX := 1 To Len(aSE2TMP[_RETIVA])
				If aSE2TMP[_RETIVA][nX][6] != 0 
					F855IncRet("I",cPreOP,aSE2TMP[_RETIVA][nX],cFornec,cLoj,cParcel)
				EndIf			
			Next nX
		EndIf
		
		//Retenciones de IIBB
		If ValType(aSE2TMP[_RETIB]) == "A"
			For nX := 1 To Len(aSE2TMP[_RETIB])
				If aSE2TMP[_RETIB][nX][3] != 0
					F855IncRet("B",cPreOP,aSE2TMP[_RETIB][nX],cFornec,cLoj,cParcel)
				EndIf			
			Next nX
		EndIf
		
		//Retenciones de SUSS
		If ValType(aSE2TMP[_RETSUSS]) == "A"
			For nX := 1 To Len(aSE2TMP[_RETSUSS])
				If aSE2TMP[_RETSUSS][nX][3] != 0
					F855IncRet("S",cPreOP,aSE2TMP[_RETSUSS][nX],cFornec,cLoj,cParcel)
				EndIf			
			Next nX
		EndIf
		
		
		//Retenciones de SLI
		If ValType(aSE2TMP[_RETSLI]) == "A"
			For nX := 1 To Len(aSE2TMP[_RETSLI])
				If aSE2TMP[_RETSLI][nX][3] != 0
					F855IncRet("L",cPreOP,aSE2TMP[_RETSLI][nX],cFornec,cLoj,cParcel)
				EndIf			
			Next nX
		EndIf
		
		//Retenciones de ISI
		If ValType(aSE2TMP[_RETISI]) == "A"
			For nX := 1 To Len(aSE2TMP[_RETISI])
				If aSE2TMP[_RETISI][nX][3] != 0
					F855IncRet("M",cPreOP,aSE2TMP[_RETISI][nX],cFornec,cLoj,cParcel)
				EndIf			
			Next nX
		EndIf
		
		
	Else
		
		//Retenciones de GANANCIAS
		If ValType(aSE2TMP) == "A"
			RateioCond(@aRatCond,cFornec,cLoj)
			/*If Len(aRatCond) >0
				aSE2TMP := F850CalcRet(aRatCond,aSE2TMP)
			EndIf*/
			aSort(aSE2TMP,,,{|x,y| x[7]<=y[7] })
			For nX := 1 To Len(aSE2TMP)
				F855IncRet("G",cPreOP,aSE2TMP[nX],cFornec,cLoj,cParcel)
			Next nX
		EndIf
		
	EndIf

Return

/*
ษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณF855IncRet บAutor  ณRaul Ortiz Medina   บ Data ณ  31/01/17   บ
ฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Realiza el borrado de los valores de Retenciones de una     บ
บ          ณ Orden de Pago Previa                                        บ
ฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA855                                                     บ
ศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Function F855IncRet(cTipo,cPreOP,aRet,cFornec,cLoj,cParcel)
Local aRatSUSS := {}
Local aConRat	 := {}
Local nRets	 := 1
Local nX		 := 1

	IF cTipo == "S"
		aRatSUSS := F850RatSuss(cFornec,cLoj)
		nRets	  := Len(aRatSUSS)
	ElseIf cTipo == "M"
		nRets := Len(aRet[8])
	EndIf

	For nX := 1 To nRets
		RecLock("FVC",.T.)
			FVC_FILIAL		:=	xFilial("FVC")
			FVC_PREOP		:= cPreOP
			FVC_FORNEC 	:= cFornec
			FVC_LOJA		:= cLoj
			FVC_TIPO		:= cTipo
			If cTipo <> "G"
				FVC_NFISC		:= aRet[1]
				FVC_SERIE		:= aRet[2]
				FVC_PARCEL		:= cParcel
				FVC_DEDUC 		:= aRet[6]
				If cTipo == "I"
					FVC_CFO		:= aRet[11]   
					FVC_VALBAS		:= aRet[3]
					FVC_ALIQ		:= aRet[10]
					FVC_PORCR 		:= aRet[5]
					FVC_RETENC		:= aRet[6]
					//FVC_RETENC		:= aRet[4]
				ElseIF cTipo == "B"
					FVC_CONCEP		:= aRet[14]
					FVC_CFO		:= aRet[11]  
					FVC_VALBAS		:= aRet[3]
					FVC_ALIQ		:= Iif(aRet[17],aRet[4]-aRet[20],aRet[4])
					FVC_DEDUC 		:= aRet[15]
					FVC_PORCR 		:= aRet[16]
					FVC_EST   		:= aRet[9]
					FVC_RETENC		:= Iif(aRet[17],(aRet[5]*aRet[19])/aRet[4],aRet[5])
				ElseIF cTipo == "S"
					If aRatSUSS[nX][4]== .T.
						FVC_TIPO	:= "U"
					EndIf
					FVC_FORNEC 	:= aRatSUSS[nX][1]
					FVC_LOJA		:= aRatSUSS[nX][2]
					FVC_CONCEP		:= aRet[8] 
					FVC_VALBAS		:= aRet[3] * aRatSUSS[nX][3]
					FVC_ALIQ		:= aRet[7]
					FVC_PORCR 		:= aRet[5]
					FVC_RETENC		:= aRet[6] * aRatSUSS[nX][3]
					FVC_FORCON		:= cFornec
					FVC_LOJCON   	:=	cLoj
				ElseIf cTipo == "L"
					FVC_VALBAS 	:= aRet[3] 
					FVC_PORCR 	:= aRet[5]
					FVC_RETENC 	:= aRet[6]
				ElseIf cTipo == "M"
					//FVC_CONCEP -> CONCEPT
					If  FVC->(ColumnPos("FVC_RET_MN")) > 0
						FVC_RET_MN	:= aRet[10]
					EndIf
					FVC_CFO 	:= aRet[8][nRets][4]
					FVC_VALBAS 	:= aRet[3]
					FVC_ALIQ 	:= aRet[8][nRets][1]
					FVC_EST 	:= aRet[9]
					FVC_RETENC 	:= aRet[8][nRets][3]
				EndIF
			Else
				FVC_VALBAS		:= aRet[2]
				FVC_ALIQ		:= aRet[3]
				FVC_RETENC		:= aRet[5]
				FVC_DEDUC 		:= aRet[6]
				FVC_CONCEP		:= aRet[7]
				FVC_PORCR 		:= aRet[8]
				FVC_FORCON		:= aRet[10]
				FVC_LOJCON   	:= aRet[11]  
			EndIf
		FVC->(MsUnlock())	
	Next nX

	//Incluye la retenci๓n de documentos acumulados que no tuvieron calculo de retenci๓n de IVA Limpieza
	If ValType(aRIvAcm) != "U" .And. cTipo == "I" .And. aRIvAcm[3] <> Nil .And. cPaisLoc == "ARG"
		For nX := 1 to Len(aRIvAcm[3])
			RecLock("FVC",.T.)
				FVC_FILIAL		:=	xFilial("FVC")
				FVC_PREOP		:= cPreOP
				FVC_FORNEC 		:= cFornec
				FVC_LOJA		:= cLoj
				FVC_TIPO		:= cTipo
				FVC_CFO			:= aRIvAcm[3][nX][11]   
				FVC_VALBAS		:= aRIvAcm[3][nX][3]
				FVC_ALIQ		:= aRIvAcm[3][nX][10]
				FVC_PORCR 		:= aRIvAcm[3][nX][5]
				FVC_RETENC		:= aRIvAcm[3][nX][6]
			FVC->(MsUnlock())	
		Next nX

		aRIvAcm := Array(3)
	EndIf
	
Return

/*
ษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณF855DelRet บAutor  ณRaul Ortiz Medina   บ Data ณ  31/01/17   บ
ฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Realiza el borrado de los valores de Retenciones de una     บ
บ          ณ Orden de Pago Previa                                        บ
ฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA855                                                     บ
ศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Function F855DelRet(cPreOP,cFornec,cLoja,cNFis,lGan) 
Local lResult	:= 0
Default lGan 	:= .F.

	DbSelectArea("FVC")
	DbSetOrder(2) //FVC_FILIAL+FVC_PREOP+FVC_FORNEC+FVC_LOJA
	If FVC->(MsSeek(xFilial("FVC") + cPreOP + cFornec + cLoja ))
		cStrSql := "DELETE FROM "+ RETSQLNAME("FVC") 
		cStrSql += " WHERE FVC_FILIAL = '"+xFilial("FVC")+"' AND"
		cStrSql += " FVC_PREOP = '"+cPreOP+"' AND"
		cStrSql += " FVC_FORNEC = '"+cFornec+"' AND"
		cStrSql += " FVC_LOJA = '"+cLoja+"' AND"
		If !lGan
			cStrSql += " FVC_NFISC = '"+cNFis+"'"
		Else
			cStrSql += " FVC_TIPO = 'G'"
		EndIf
		            
		lResult := TCSQLEXEC(cStrSql)
		If lResult < 0
		   While FVC->(!Eof()) .and. (FVC->(FVC_PREOP+FVC_FORNEC+FVC_LOJA) == cPreOP + cFornec + cLoja) .and. Iif(!lGan,FVC->FVC_NFISC==cNFis,AllTrim(FVC->FVC_TIPO) == "G")
		
				RecLock("FVC",.F.)
				FVC->(DbDelete())
				FVC->(MsUnlock())
				
				FVC->(DbSkip())
			EndDo
		EndIf
	EndIf

Return

Static Function RateioCond(aRateio,cFornece,cLoja)
Local aAreaA2		:= {}
Local cCodCond	:=	'' 
Local lRet		:=	.T.
Local nTotRat	:=	0
Local nX			:=	0
Local aHelpEsp,aHelpPor,aHelpEng
Local cConcGan	:=	""             
Local lCalcRetTo := .F.
Local cFilFor	:= ""
aRatCond:={}
aRateio	:=	{}
aAreaA2 := SA2->(GetArea())

SA2->(DbSetOrder(1))
SA2->(MsSeek( xFilial( "SA2" ) + cFornece + cLoja, .F. ))

cFilFor := SA2->A2_FILIAl
cConcGan	:= Iif(SA2->A2_TIPO == "M" .And. SA2->(ColumnPos("A2_CMONGAN"))>0,SA2->A2_CMONGAN,SA2->A2_AGREGAN)                        
lCalcRetTo:= If (SA2->(ColumnPos("A2_CALRETT")) > 0,Iif(!Empty(SA2->A2_CALRETT),SA2->A2_CALRETT,.F.),lCalcRetTo)

If SA2->(ColumnPos("A2_CODCOND")*ColumnPos("A2_CONDO")*ColumnPos("A2_PERCCON")) > 0 .And.SA2->A2_CONDO == "1" 
	cCodCond := SA2->A2_CODCOND		   
	DbSelectArea("SA2")
	DbSetOrder(1)
	MsSeek(xFilial("SA2")+cCodCond)
	//*FAZ RATEIO ENTRE OS CONDOMINOS*//
	While !EOF() .And. xFilial("SA2") == SA2->A2_FILIAL .And. Substr(SA2->A2_COD,1,Len(cCodCond)) == cCodCond			
		If cCodCond == SA2->A2_CODCOND .and. SA2->A2_CONDO =="2"//*SE CONDOMINO*//
		   AAdd(aRateio,{A2_CONDO,A2_COD,A2_LOJA,A2_PERCCON/100,Iif(A2_TIPO == "M" .And. SA2->(ColumnPos("A2_CMONGAN"))>0,A2_CMONGAN,A2_AGREGAN) })
		   If lCalcRetTo
		   		AAdd(aRatCond,{A2_CONDO,A2_COD,A2_LOJA,A2_PERCCON/100,Iif(A2_TIPO == "M" .And. SA2->(ColumnPos("A2_CMONGAN"))>0,A2_CMONGAN,A2_AGREGAN) })
		   	EndIf	
		Endif
		DbSkip()
	Enddo
	MsSeek(xFilial("SA2")+cCodCond)	
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
	aHelpEsp	:=	{"El prorrateo entre condominos es "," incorrecto, verifique los datos."}
	aHelpPor	:=	{"O rateio entre condominos e "," incorreto, verifique os dados."}
	aHelpEng	:=	{"",""}
	PutHelp("PF850COND",aHelpPor,aHelpEng,aHelpEsp,.F.)
	Help(" ",1,"F850COND")
	lRet	:=	.F.
Endif
If lCalcRetTo   
	aRateio:={}
	AAdd(aRateio,{'',cFornece,cLoja,1,cConcGan,cFilFor})
EndIf
RestArea(aAreaA2)
Return lRet

/*
ษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณF855Ret    บAutor  ณRaul Ortiz Medina   บ Data ณ  03/02/17   บ
ฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Realiza el acumulado de los valores de Retenciones de una   บ
บ          ณ Orden de Pago Previa                                        บ
ฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
บUso       ณ FINA855                                                     บ
ศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Static Function F855Ret(cProp,aReten,aRetencoes)
Local lFound := .F.
Local nPos 	:= 0

	aReten := {0,0,0,0,0,0} //IVA,IIBB,SUSS,GAN,SLI,ISI

	DBSELECTAREA("FVC")
	FVC->(DBSETORDER(1)) //FVC_FILIAL+FVC_PREOP+FVC_TIPO
	If FVC->(MsSeek(xFilial("FVC")+ cProp))
		While FVC->(!Eof()) .and. FVC->FVC_PREOP == cProp
			If AllTrim(FVC->FVC_TIPO) == "I"
				aReten[1] += FVC->FVC_RETENC
				nPos := ASCAN(aRetencoes,{|x|x[1] == "I" .and. x[6]== FVC->FVC_ALIQ })
				If nPos > 0
					aRetencoes[nPos][4] += FVC->FVC_VALBAS
					aRetencoes[nPos][7] += FVC->FVC_RETENC
				Else
					aAdd(aRetencoes,{"I","","",FVC->FVC_VALBAS,0,FVC->FVC_ALIQ,FVC->FVC_RETENC,.F.})
				EndIf
			ElseIf AllTrim(FVC->FVC_TIPO) == "B"
				aReten[2] += FVC->FVC_RETENC
				nPos := ASCAN(aRetencoes,{|x|x[1] == "B" .and. x[2]== FVC->FVC_EST .and. x[6]== FVC->FVC_ALIQ })
				If nPos > 0
					aRetencoes[nPos][4] += FVC->FVC_VALBAS
					aRetencoes[nPos][7] += FVC->FVC_RETENC
				Else
					aAdd(aRetencoes,{"B",FVC->FVC_EST ,"",FVC->FVC_VALBAS,0,FVC->FVC_ALIQ,FVC->FVC_RETENC,.F.})
				EndIf
			ElseIf AllTrim(FVC->FVC_TIPO) == "U" .or. AllTrim(FVC->FVC_TIPO) == "S"
				aReten[3] += FVC->FVC_RETENC
				nPos := ASCAN(aRetencoes,{|x|x[1] == "S" .and. x[3]== FVC->FVC_CONCEP .and. x[6]== FVC->FVC_ALIQ })
				If nPos > 0
					aRetencoes[nPos][4] += FVC->FVC_VALBAS
					aRetencoes[nPos][7] += FVC->FVC_RETENC
				Else
					aAdd(aRetencoes,{"S","",FVC->FVC_CONCEP,FVC->FVC_VALBAS,0,FVC->FVC_ALIQ,FVC->FVC_RETENC,.F.})
				EndIf
			ElseIf AllTrim(FVC->FVC_TIPO) == "G"
				aReten[4] += FVC->FVC_RETENC
				aAdd(aRetencoes,{"G","",FVC->FVC_CONCEP,FVC->FVC_VALBAS,0,FVC->FVC_ALIQ,FVC->FVC_RETENC,.F.})
			ElseIf AllTrim(FVC->FVC_TIPO) == "L"
				aReten[5] += FVC->FVC_RETENC
				nPos := ASCAN(aRetencoes,{|x|x[1] == "L"})
				If nPos > 0
					aRetencoes[nPos][4] += FVC->FVC_VALBAS
					aRetencoes[nPos][7] += FVC->FVC_RETENC
				Else
					aAdd(aRetencoes,{"L",,"",FVC->FVC_VALBAS,0,0,FVC->FVC_RETENC,.F.})
				EndIf
			ElseIf AllTrim(FVC->FVC_TIPO) == "M"
				aReten[6] += FVC->FVC_RETENC
				nPos := ASCAN(aRetencoes,{|x|x[1] == "M" .and. x[2]== FVC->FVC_EST .and. x[6]== FVC->FVC_ALIQ })
				If nPos > 0
					aRetencoes[nPos][4] += FVC->FVC_VALBAS
					aRetencoes[nPos][7] += FVC->FVC_RETENC
				Else
					aAdd(aRetencoes,{"M",FVC->FVC_EST ,"",FVC->FVC_VALBAS,0,FVC->FVC_ALIQ,FVC->FVC_RETENC,.F.})
				EndIf
			EndIf
			FVC->(DbSkip())
		Enddo
		lFound := .T.
	EndIF

Return lFound

/*
////////////////////////////////////////////////////////////////////////
Programa  *Fn855GtCpo*Autor  *Raul Ortiz Medina   * Data *  08/05/17   *
////////////////////////////////////////////////////////////////////////
Desc.     * Utilizada para obtener las propiedades de los campos para  *
          * el grid de Retenciones                                     *
////////////////////////////////////////////////////////////////////////
Uso       * FINA855                                                    *
////////////////////////////////////////////////////////////////////////
*/
Static Function Fn855GtCpo(aHeader)
Local nX := 0
Local aCpos := {"FVC_TIPO","FVC_EST","FVC_CONCEP","FVC_VALBASE","FVC_DESGR","FVC_ALIQ","FVC_RETENC"}

	DbSelectArea("SX3")
	DbSetOrder(2)
	For nX := 1 To Len(aCpos)
		If SX3->(MsSeek(PadR(aCpos[nX],Len(SX3->X3_CAMPO))))
			Aadd(aHeader,{AllTrim(X3TITULO()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"",X3_USADO,X3_TIPO,X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO,"Fn850EdtRt()"})
		Endif
	Next nX
Return

/*/{Protheus.doc}
(Function for Pre-Order)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function RU06S855(nOpcao)
Local oDlg
Local aTppgto:={}
Local aPriori :={}
Local cTppgtoCBX:=""
Local cPrioriCBx:=""
Local oBnkCod :=Nil
Local oBIKCod :=Nil
Local oCorAcc:=Nil
Local oBkName:=Nil
Local oDtPlan:=Nil
Local oTppgto :=Nil
Local oConta :=Nil
Local oRcName :=Nil
Local oKPPPay :=Nil
Local oRecKPP :=Nil
Local oPriori :=Nil
Local oReason :=Nil
Local oVATRat :=Nil
Local oVATAmt :=Nil
Local oVATCod :=Nil

	
Local lNew := .T.
Local aAreaSA2 :=SA2->(getArea())
Local aAreaFJK :=FJK->(getArea())
Local nOpc :=0
Local lApprove := .F.
	
Private cBnkCod := CriaVar("FJK_BNKCOD")//'Bank Code'
Private cBIKCod := CriaVar("FJK_BIKCOD")//'BIK Code'
Private cCorAcc := CriaVar("FJK_CORACC")//'Corresponding Account'
Private cBkName := CriaVar("FJK_BKNAME")//'Bank Name'
Private dDtPlan := CriaVar("FJK_DTPLAN")//'Planned Day of Payment'
Private cTppgto := CriaVar("FJK_TPPGTO")//'Type of Payment'
Private cConta  := CriaVar("FJK_CONTA") //'Bank Account'
Private cRcName := CriaVar("FJK_RCNAME")//"Receiver' s Name"
Private cKPPPay := CriaVar("FJK_KPPPAY")//"Payer’s KPP"
Private cRecKPP := CriaVar("FJK_RECKPP")//"Receiver’s KPP"
Private cPriori := CriaVar("FJK_PRIORI")//"Priority of Payment"
Private cReason := ""//CriaVar("FJK_REASON")//'Reason for Payment'
Private cVATCod := CriaVar("FJK_VATCOD")//"Priority of Payment"
Private cVATRat := CriaVar("FJK_VATRAT")//'VAT Rate'
Private nVATAmt := CriaVar("FJK_VATAMT")//'VAT Amount'
Default dDtPlan := dDataBase 
lNew := nOpcao==1 .Or. nOpcao==4
nOpc := 0
a855GetVar(nOpcao)  // get all values of array
	
	
cTppgtoCBx := RU99SX3("FJK_TPPGTO")
cPrioriCBx := RU99SX3("FJK_PRIORI")
	
aTppgto := StrTokArr(cTppgtoCBX, ";" )
aPriori := StrTokArr(cPrioriCBx, ";" )
	
dbSelectArea('SA2')
dbSetOrder(1)
If MsSeek(xFilial('SA2')+cFornece+cLoja)
	If Empty(cRecKPP)
		cRecKPP := SA2->A2_KPP
	EndIf
	//cRcName := SA2->A2_NOME
EndIf
	
RestArea(aAreaSA2)

	
DEFINE MSDIALOG oDlg TITLE STR0104 FROM 3,0 TO 390,570 PIXEL
	
	@ 05,10 To 185,280 Pixel Of oDlg LABEL OemToAnsi(STR0104)
	
	
	@ 15,15 SAY OemToAnsi(STR0105) Size 60,08 Pixel Of oDlg
	@ 25,15 MSGET oBnkCod VAR cBnkCod F3 "FIL" PICTURE PesqPict("FJK","FJK_BNKCOD" ) valid RUSgetBK(cBnkCod,cBIKCod) WHEN lNew SIZE 20,10 PIXEL OF oDlg
	
	@ 15,47 SAY OemToAnsi(STR0106) Size 60,08 Pixel Of oDlg
	@ 25,45 MSGET oBIKCod VAR cBIKCod PICTURE PesqPict("FJK","FJK_BIKCOD") WHEN .F. SIZE 20,10 PIXEL OF oDlg
	//oBIKCod:Disable()
	@ 15,87 SAY OemToAnsi(STR0111 ) Size 80,08 Pixel Of oDlg
	@ 25,85 MSGET oConta VAR cConta PICTURE PesqPict("FJK","FJK_CONTA") WHEN .F. SIZE 90,10 PIXEL OF oDlg
	//oCorAcc:Disable()
	@ 15,180 SAY OemToAnsi(STR0108) Size 60,08 Pixel Of oDlg
	@ 25,180 MSGET oBkName VAR cBkName PICTURE PesqPict("FJK","FJK_BKNAME")  WHEN .F. SIZE 90,10 PIXEL OF oDlg
	//oBkName:Disable()
	
	@ 40,15 SAY OemToAnsi(STR0107) Size 80,08 Pixel Of oDlg
	@ 50,15 MSGET oCorAcc VAR cCorAcc PICTURE PesqPict("FJK","FJK_CORACC") WHEN .F. SIZE 80,10 PIXEL OF oDlg
	Iif (Empty(cTppgto),cTppgto := aTppgto[2],cTppgto)	
	@ 40,100 SAY OemToAnsi(STR0110 ) Size 70,08 Pixel Of oDlg
	@ 50,100 MSCOMBOBOX oTppgto VAR cTppgto ITEMS aTppgto WHEN lNew SIZE 60,10 PIXEL OF oDlg
	Iif (Empty(cPriori),cPriori := aPriori[5],cPriori)
	@ 40,170 SAY OemToAnsi(STR0115) Size 80,08 Pixel Of oDlg
	@ 50,170 MSCOMBOBOX oPriori VAR cPriori  ITEMS aPriori WHEN lNew SIZE 50,10 PIXEL OF oDlg

	
	@ 65,15 SAY OemToAnsi(STR0112) Size 90,08 Pixel Of oDlg
	@ 75,15 MSGET oRcName VAR cRcName PICTURE PesqPict("FJK","FJK_RCNAME") WHEN lNew SIZE 150,10 PIXEL OF oDlg
	
	@ 65,170 SAY OemToAnsi(STR0114) Size 80,08 Pixel Of oDlg
	@ 75,170 MSGET oRecKPP VAR cRecKPP PICTURE PesqPict("FJK","FJK_RECKPP") WHEN lNew SIZE 50,10 PIXEL OF oDlg
	
	@ 65,225 SAY OemToAnsi(STR0113) Size 80,08 Pixel Of oDlg
	@ 75,225 MSGET oKPPPay VAR cKPPPay PICTURE PesqPict("FJK","FJK_KPPPAY") WHEN lNew SIZE 50,10 PIXEL OF oDlg
	
	@ 90,15 SAY OemToAnsi(STR0109) Size 100,08 Pixel Of oDlg
	@ 100,15 MSGET oDtPlan VAR dDtPlan PICTURE PesqPict("FJK","FJK_DTPLAN") WHEN lNew SIZE 60,10 PIXEL OF oDlg
	
	@ 90,80 SAY OemToAnsi(STR0127) Size 60,08 Pixel Of oDlg
	@ 100,80 MSGET oVATCod VAR cVATCod F3 "F30" PICTURE PesqPict("FJK","FJK_VATCOD") valid {||FillReason(),GetVatCod(cVATCod)} WHEN lNew SIZE 30,10 PIXEL OF oDlg
	
	@ 90,115 SAY OemToAnsi(STR0117) Size 60,08 Pixel Of oDlg
	@ 100,115 MSGET oVATRat VAR cVATRat PICTURE PesqPict("FJK","FJK_VATRAT") valid FillReason() WHEN .F. SIZE 50,10 PIXEL OF oDlg
	
	@ 90,170 SAY OemToAnsi(STR0118) Size 60,08 Pixel Of oDlg
	@ 100,170 MSGET oVATAmt VAR nVATAmt PICTURE PesqPict("FJK","FJK_VATAMT") valid FillReason() WHEN lNew SIZE 80,10 PIXEL OF oDlg
	
	@ 115,15 SAY OemToAnsi(STR0116 ) Size 80,08 Pixel Of oDlg
	//@ 125,15 MSGET oReason VAR cReason PICTURE PesqPict("FJK","FJK_REASON")SIZE 210,20 FONT oBold PIXEL OF oDlg
	oReason := tMultiget():new( 125, 15, {| u | if( pCount() > 0, cReason := u, AllTrim(cReason) ) },oDlg, 255, 40, , , , , , .T.,,,{||lNew},,,,{|| RUSlengstr()} )


	DEFINE SBUTTON FROM 170,185 TYPE 1 ACTION  {||oDlg:End(), nOpc := 1} ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM 170,225 TYPE 2 ACTION {||oDlg:End()} ENABLE OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTER
	
If nOpc == 1
	a855SetVar()
Endif
	
Return

/*/{Protheus.doc}
(Function for Pre-Order to get VATRat by VATCode)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function GetVatCod(VATCode as char)
	Local nLine 		:= oGridPreOP:nAt
	Local cPosFornece 	:=  oGridPreOP:aCols[nLine][1]
	Local cPosLoja  	:=  oGridPreOP:aCols[nLine][2]
	Local aAreaF30 := getArea()
	dbSelectArea('F30')
	dbSetOrder(1)
	If MsSeek(xFilial('F30')+VATCode)
		cVATRat := F30->F30_DESC
	EndIf
	RestArea(aAreaF30)
	
Return
/*/{Protheus.doc}
(Function for Pre-Order to fill the Reason)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function FillReason()
	Local nSumm			:=0
	Local cNumberCon	:=''
	Local cNumDoc		:=''
	Local nLine 		:= oGridPreOP:nAt
	Local cPosFornece 	:=  oGridPreOP:aCols[nLine][1]
	Local cPosLoja  	:=  oGridPreOP:aCols[nLine][2]
	Local nVATup 			:= 0
	
	FA855SE2->(DbGoTop())
	While FA855SE2->(!Eof())
		
		If FA855SE2->(E2_FORNECE+E2_LOJA) <> cPosFornece+cPosLoja
			FA855SE2->(DbSkip())
			Loop
		EndIf
		If !Empty(FA855SE2->E2_DELET)
			FA855SE2->(DbSkip())
			Loop
		EndIf
		If nVATAmt == 0
			nSumm += FA855SE2->E2_VALIMP1
		Else
			nSumm := nVATAmt
		EndIf
		If cNumDoc==''
			cNumDoc += iif(!Empty(Alltrim(FA855SE2->E2_PREFIXO)),Alltrim(FA855SE2->E2_PREFIXO)+'/' + Alltrim(FA855SE2->E2_NUM),Alltrim(FA855SE2->E2_NUM))+ " " + STR0126 + " " + StrTran(DTOC(FA855SE2->E2_EMISSAO),"/",".")
		Else
			cNumDoc +=', '+ iif(!Empty(Alltrim(FA855SE2->E2_PREFIXO)),Alltrim(FA855SE2->E2_PREFIXO)+'/' + Alltrim(FA855SE2->E2_NUM),Alltrim(FA855SE2->E2_NUM))+ " " + STR0126 + " " + StrTran(DTOC(FA855SE2->E2_EMISSAO),"/",".")
		EndIf
		
		If cNumberCon=''
			cNumberCon += Alltrim(FA855SE2->E2_MDCONTR)
			cPrevContr:= Alltrim(FA855SE2->E2_MDCONTR)
		Else
			If cPrevContr != Alltrim(FA855SE2->E2_MDCONTR)
				cNumberCon += ', '+ Alltrim(FA855SE2->E2_MDCONTR)
			EndIf
		EndIf
		
		FA855SE2->(DbSkip())
	EndDo
	
	If cVATCod == '0006' .or. Alltrim(cVATCod) == ''
		cPart3:=   ''
	Else
		cPart3 :=  STR0125+" "+ Alltrim(cVATRat)+ ' - '+ Alltrim(Str(nSumm,15,2))
	Endif
	
If Empty(cReason)
	If Empty(cFilReason)
		cPart2:= ''
		cPart1:= STR0123+" "+ Alltrim(cNumberCon)+" "+STR0124+" "+ Alltrim(cNumDoc) + '.' + CRLF
	Else
		cPart2 := Alltrim(cFilReason) + CRLF
		cPart1 := ''
	EndIf
	If (len(cPart1)+ len(cPart3))>209 .And. len(cPart1)> len(cPart3)
		cPart1:= AllTrim(SubStr(cPart1,1,(207- len(cPart3))))
		Help( " ", 1, "F855LENREASON" )//The size of field must be less than 210 symbols
	EndIf

Else 
	nVATup = at(STR0125,cReason)
	If nVATup > 0
	cPart1 := SubStr(cReason,1,nVATup-1)
	Else
	cPart1 := cReason
	EndIf
	cPart2 := ''
Endif	
cReason:=cPart1 + cPart2 + cPart3
	nVATAmt:= nSumm
Return
/*/{Protheus.doc}
(Function for Pre-Order to print help for Reason)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function RUSlengstr()
	Local lLength :=.F.
	lLength := len(cReason)<211
	If !lLength
		Help( " ", 1, "F855LENREASON" )//The size of field must be less than 210 symbols
	EndIf
Return lLength

/*/{Protheus.doc}
(Function for Pre-Order to clear value)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function RU06S855CL()
	
	aDetailRus := {}
	
Return .T.

/*/{Protheus.doc}
(Function for Pre-Order to take value from combobox)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Static Function RU99SX3(cField)
	Local cFieldRes :=""
	Local aArea := getArea()
	Local aAreaSX3 := SX3->(getArea())
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	SX3->(MsSeek(cField))
	cFieldRes := X3Cbox()
		
	RestArea(aAreaSX3)
	RestArea(aArea)
	
Return cFieldRes

/*/{Protheus.doc}
(Function for Pre-Order to take value from combobox)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function RUSgetBK(cBnkCode,cBIK)
	Local aAreaF45 := getArea()
	Local aAreaFIL := getArea()
	
	dbSelectArea('FIL')
	FIL->(dbSetOrder(1))
	If FIL->(MsSeek(xFilial('FIL') + cFornece + cLoja ))
		While FIL->(FIL_FORNEC+FIL_LOJA) == cFornece+cLoja
			If FIL->FIL_BANCO == cBnkCod
				cBIKCod := FIL->FIL_AGENCI
				cConta     := FIL->FIL_CONTA
				If Empty(cRcName)
					cRcName := FIL->FIL_NMECOR
				EndIf
				If Empty(FIL->FIL_NMECOR)
					cRcName := SA2->A2_NOME
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
	
	dbSelectArea('F45')
	dbSetOrder(1)
	If MsSeek(xFilial('F45') + cBIKCod)
		cCorAcc := F45->F45_CORRAC
		cBkName := F45->F45_NAME
	EndIf
	RestArea(aAreaFIL)
	RestArea(aAreaF45)
	
Return .T.

/*/{Protheus.doc}
(Function for Pre-Order to take value for screen Pre-Order)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function a855getVar(nOpcao,nLine)
	Local nPos :=0
	Local aAreaFJK :={}
	Local nLine :=0
	Local cFor :=""
	Local cLojr :=""
	Local cPrePayOrdr :=""
	
	Default nOpcao := 0
	Default nLine := 0
	/*
	DOCUMENTATION ABOUT MAIN ARRAY (STATIC) OF DETAILS:
	aDetailRUS[x][1]	= 	cBnkCod   -- use DEFINE _BnkCode
	aDetailRUS[x][2] 	= 	cBIKCod   -- use DEFINE _BikCod
	aDetailRUS[x][3] 	= 	cBkName   -- use DEFINE _BkName
	aDetailRUS[x][4] 	= 	dDtPlan   -- use DEFINE _DtPlan
	aDetailRUS[x][5] 	= 	cTppgto   -- use DEFINE _Tppgto
	aDetailRUS[x][6] 	= 	cCorAcc   -- use DEFINE _CorAcc
	aDetailRUS[x][7] 	= 	cConta    -- use DEFINE _Conta
	aDetailRUS[x][8] 	= 	cRcName   -- use DEFINE _RcName
	aDetailRUS[x][9] 	= 	cKPPPay   -- use DEFINE _KPPPay
	aDetailRUS[x][10] 	= 	cRecKPP   -- use DEFINE _RecKPP
	aDetailRUS[x][11] 	= 	cPriori   -- use DEFINE _Priori
	aDetailRUS[x][12] 	= 	cReason   -- use DEFINE _Reason
	aDetailRUS[x][13] 	= 	cVATRat   -- use DEFINE _VATRat
	aDetailRUS[x][14] 	= 	nVATAmt   -- use DEFINE _VATAmt
	aDetailRUS[x][15] 	=	cFornece  -- use DEFINE _PosFornece
	aDetailRUS[x][16] 	=	cLoja     -- use DEFINE _PosLoja
	*/
If nOpcao == 1 //insert
	
	nPos := aScan(aDetailRus, {|x| x[_PosFornece] == cFornece .and. x[_PosLoja] == cLoja})
	
	If nPos > 0
		iif( Empty(aDetailRUS[nPos][_BnkCode]),cBnkCod := CriaVar("FJK_BNKCOD"),cBnkCod := aDetailRUS[nPos][_BnkCode])
		iif( Empty(aDetailRUS[nPos][_BikCod] ),cBIKCod := CriaVar("FJK_BIKCOD"),cBIKCod := aDetailRUS[nPos][_BikCod] )
		iif( Empty(aDetailRUS[nPos][_BkName] ),cCorAcc := CriaVar("FJK_CORACC"),cBkName := aDetailRUS[nPos][_BkName] )
		iif( Empty(aDetailRUS[nPos][_DtPlan]),dDtPlan := CriaVar("FJK_DTPLAN"),dDtPlan := aDetailRUS[nPos][_DtPlan])
		iif( Empty(aDetailRUS[nPos][_Tppgto]),cTppgto := CriaVar("FJK_TPPGTO"),cTppgto := aDetailRUS[nPos][_Tppgto])
		iif( Empty(aDetailRUS[nPos][_Conta] ),cConta  := CriaVar("FJK_CONTA")  ,cConta  := aDetailRUS[nPos][_Conta] )
		iif( Empty(SE2->E2_FORBCO),cBnkCod,cBnkCod := SE2->E2_FORBCO)
		iif( Empty(aDetailRUS[nPos][_RcName]),cRcName := CriaVar("FJK_RCNAME") ,cRcName := aDetailRUS[nPos][_RcName])
		iif( Empty(aDetailRUS[nPos][_KPPPay]),cKPPPay := CriaVar("FJK_KPPPAY") ,cKPPPay := aDetailRUS[nPos][_KPPPay])
		iif( Empty(aDetailRUS[nPos][_RecKPP]),cRecKPP := CriaVar("FJK_RECKPP") ,cRecKPP := aDetailRUS[nPos][_RecKPP])
		iif( Empty(aDetailRUS[nPos][_Priori]),cPriori := CriaVar("FJK_PRIORI") ,cPriori := aDetailRUS[nPos][_Priori])
		iif( Empty(aDetailRUS[nPos][_Reason]),cReason := ""					   ,cReason := aDetailRUS[nPos][_Reason])
		iif( Empty(aDetailRUS[nPos][_VATCod]),cVATCod := CriaVar("FJK_VATCOD") ,cVATCod := aDetailRUS[nPos][_VATCod])
		iif( Empty(aDetailRUS[nPos][_VATRat]),cVATRat := CriaVar("FJK_VATRAT") ,cVATRat := aDetailRUS[nPos][_VATRat])
		iif( Empty(aDetailRUS[nPos][_VATAmt]), nVATAmt := CriaVar("FJK_VATAMT"),nVATAmt := aDetailRUS[nPos][_VATAmt])
	Endif
	FillReason()
ElseIf nOpcao == 5 .Or. nOpcao == 2
	aAreaFJK 	:= FJK->(getArea())
	If nLine == 0
		nLine 	:= oGridPreOP:nAt
	Endif
	cFor 		:= oGridPreOP:aCols[nLine][1]
	cLoj		:= oGridPreOP:aCols[nLine][2]
	cPrePayOrd	:= oGridPreOP:aCols[nLine][3]
	dbSelectArea('FJK')
	dbSetOrder(1)
	If MsSeek(xFilial('FJK')+cFor+cLoj+cPrePayOrd)
		cBnkCod := FJK->FJK_BNKCOD
		cBIKCod := FJK->FJK_BIKCOD
		cBkName := FJK->FJK_BKNAME
		dDtPlan := FJK->FJK_DTPLAN
		cTppgto := FJK->FJK_TPPGTO
		cConta  := FJK->FJK_CONTA
		cRcName := FJK->FJK_RCNAME
		cKPPPay := FJK->FJK_KPPPAY
		cRecKPP := FJK->FJK_RECKPP
		cPriori := FJK->FJK_PRIORI
		cReason := FJK->FJK_REASON
		cVATCod := FJK->FJK_VATCOD
		cVATRat := FJK->FJK_VATRAT
		nVATAmt := FJK->FJK_VATAMT
	EndIf
	
	RestArea(aAreaFJK)
Else
	
	aAreaFJK 	:= FJK->(getArea())
	If nLine == 0
		nLine 		:= oGridPreOP:nAt
	Endif
	cFor 		:= oGridPreOP:aCols[nLine][1]
	cLoj		:= oGridPreOP:aCols[nLine][2]
	cPrePayOrd	:= oGridPreOP:aCols[nLine][3]
	dbSelectArea('FJK')
	dbSetOrder(1)
	If MsSeek(xFilial('FJK')+cFor+cLoj+cPrePayOrd)
		
		iif( Empty(aDetailRUS[nLine][_BnkCode]),cBnkCod := FJK->FJK_BNKCOD,cBnkCod := aDetailRUS[nLine][_BnkCode])
		iif( Empty(aDetailRUS[nLine][_BikCod]) ,cBIKCod := FJK->FJK_BIKCOD,cBIKCod := aDetailRUS[nLine][_BikCod])
		iif( Empty(aDetailRUS[nLine][_BkName]) ,cBkName := FJK->FJK_BKNAME,cBkName := aDetailRUS[nLine][_BkName])
		iif( Empty(aDetailRUS[nLine][_DtPlan]) ,dDtPlan := FJK->FJK_DTPLAN,dDtPlan := aDetailRUS[nLine][_DtPlan])
		iif( Empty(aDetailRUS[nLine][_Tppgto]) ,cTppgto := FJK->FJK_TPPGTO, cTppgto := aDetailRUS[nLine][_Tppgto])
		iif( Empty(aDetailRUS[nLine][_Conta])  ,cConta  := FJK->FJK_CONTA ,cConta  := aDetailRUS[nLine][_Conta] )
		iif( Empty(aDetailRUS[nLine][_RcName]) ,cRcName := FJK->FJK_RCNAME,cRcName := aDetailRUS[nLine][_RcName])
		iif( Empty(aDetailRUS[nLine][_KPPPay]) ,cKPPPay := FJK->FJK_KPPPAY,cKPPPay := aDetailRUS[nLine][_KPPPay])
		iif( Empty(aDetailRUS[nLine][_RecKPP]) ,cRecKPP := FJK->FJK_RECKPP,cRecKPP := aDetailRUS[nLine][_RecKPP])
		iif( Empty(aDetailRUS[nLine][_Priori]) ,cPriori := FJK->FJK_PRIORI,cPriori := aDetailRUS[nLine][_Priori])
		iif( Empty(aDetailRUS[nLine][_Reason]) ,cReason := FJK->FJK_REASON,cReason := aDetailRUS[nLine][_Reason])
		iif( Empty(aDetailRUS[nLine][_VATCod]) ,cVATCod := FJK->FJK_VATCOD,cVATCod := aDetailRUS[nLine][_VATCod])
		iif( Empty(aDetailRUS[nLine][_VATRat]) ,cVATRat := FJK->FJK_VATRAT,cVATRat := aDetailRUS[nLine][_VATRat])
		iif( Empty(aDetailRUS[nLine][_VATAmt]) ,nVATAmt := FJK->FJK_VATAMT,nVATAmt := aDetailRUS[nLine][_VATAmt])
	EndIf
	
	RestArea(aAreaFJK)
Endif


	RUSgetBK(cBnkCod,cBIKCod)
	
Return
/*/{Protheus.doc}
(Function for Pre-Order to remember list of Pre-Order)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function a855setVar(nOpcao,n)
	Local nLine :=0
	Local aAreaFJK := FJK->(getArea())
	If nOpcao == 5 
		nPos := nLine:= n
	Else
		nPos := aScan(aDetailRus, {|x| x[_PosFornece] == cFornece .and. x[_PosLoja] == cLoja})
		nLine := oGridPreOP:nAt
	EndIf
	aDetailRUS[nPos][_BnkCode] :=  cBnkCod
	aDetailRUS[nPos][_BikCod]  :=  cBIKCod
	aDetailRUS[nPos][_BkName]  :=  cBkName
	aDetailRUS[nPos][_DtPlan]  :=  dDtPlan
	aDetailRUS[nPos][_Tppgto]  :=  cTppgto
	aDetailRUS[nPos][_Conta]   :=  cConta
	aDetailRUS[nPos][_RcName]  :=  cRcName
	aDetailRUS[nPos][_KPPPay]  :=  cKPPPay
	aDetailRUS[nPos][_RecKPP]  :=  cRecKPP
	aDetailRUS[nPos][_Priori]  :=  cPriori
	aDetailRUS[nPos][_Reason]  :=  cReason
	aDetailRUS[nPos][_VATCod]  :=  cVATCod
	aDetailRUS[nPos][_VATRat]  :=  cVATRat
	aDetailRUS[nPos][_VATAmt]  :=  nVATAmt
	aDetailRUS[nPos][_PosFornece]  :=  oGridPreOP:aCols[nLine][1]
	aDetailRUS[nPos][_PosLoja]  :=  oGridPreOP:aCols[nLine][2]
Return
/*/{Protheus.doc}
(Function for Pre-Order to create fields and array)
@type function
@author Andrey Filatov
@since 12/05/2017
@version 1.0
/*/
Function a855ArrRus(nOpcao)
	Local nCount :=0
	Local aAreaFJK := getArea()
	
	// Lets inicializate all variables always. If Insert, it is already done here, if it not Insert, we will have "private" variables to be filled in function a855getVar
	
	cBnkCod := CriaVar("FJK_BNKCOD")//'Bank Code'
	cBIKCod := CriaVar("FJK_BIKCOD")//'BIK Code'
	cCorAcc := CriaVar("FJK_CORACC")//'Corresponding Account'
	cBkName := CriaVar("FJK_BKNAME")//'Bank Name'
	dDtPlan := CriaVar("FJK_DTPLAN")//'Planned Day of Payment'
	cTppgto := CriaVar("FJK_TPPGTO")//'Type of Payment'
	cConta  := CriaVar("FJK_CONTA") //'Bank Account'
	cRcName := CriaVar("FJK_RCNAME")//"Receiver' s Name"
	cKPPPay := CriaVar("FJK_KPPPAY")//"Payer’s KPP"
	cRecKPP := CriaVar("FJK_RECKPP")//"Receiver’s KPP"
	cPriori := CriaVar("FJK_PRIORI")//"Priority of Payment"
	cReason := ""//CriaVar("FJK_REASON")//'Reason for Payment'
	cVATCod := CriaVar("FJK_VATCOD")//'VAT Cod'
	cVATRat := CriaVar("FJK_VATRAT")//'VAT Rate'
	nVATAmt := CriaVar("FJK_VATAMT")//'VAT Amount'
	cTppgto := ''
	cPriori := ''
	For nCount := 1 to Len(oGridPreOP:aCols)
		
		AAdd(aDetailRUS,{cBnkCod,cBIKCod,cBkName,dDtPlan,cTppgto,cCorAcc,cConta,cRcName,cKPPPay,cRecKPP,cPriori,cReason,cVATRat,nVATAmt,cVATCod,oGridPreOP:aCols[nCount][1],oGridPreOP:aCols[nCount][2]})
		If nOpcao <> 1  //if it is not a insert, I need to fill all positions of this array, before open Pre Order screen (get from FJK)
			a855getVar(nOpcao,nCount)
		Endif
		If nOpcao == 5 
			a855setVar(nOpcao,nCount)
		Endif
	Next nCount
	
Return

/*/{Protheus.doc}
(Function for Pre-Order to view payment order if it exist)
@type function
@author Andrey Filatov
@since 04/07/2017
@version 1.0
/*/
Function RUpayorderOpen()
	Local aAreaFJR := getArea()
	Local cPaymentOr := ''
	If !Empty(FJK->FJK_ORDPAG)
		cPaymentOr := FJK->FJK_ORDPAG
		dbSelectArea('FJR')
		DbSetOrder(1)
		If MsSeek(xFilial('FJR')+cPaymentOr)
			FWExecView(STR0002,"FINA847",MODEL_OPERATION_VIEW,,{|| .T.})
		EndIf
	EndIf
	RestArea(aAreaFJR)
Return
