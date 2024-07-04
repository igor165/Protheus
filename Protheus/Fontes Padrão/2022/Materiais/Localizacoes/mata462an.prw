#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA462A.CH"
#INCLUDE 'FWLIBVERSION.CH'

#DEFINE _RMCONS "A"

Static _lMetric	:= Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ MATA462AN³ Autor ³ Bruno Sobieski Chavez  ³ Data ³ 10.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de la Emision e Gravacion del Remito	           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Faturamento/Localizacoes       						   	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glez³08/07/15³PCREQ-4256³Se elimina la funcion AlteraSX1() y   ³±±
±±³             ³        ³          ³AjustaSX3() que modifican el dicciona-³±±
±±³             ³        ³          ³rio por motivo deadecuacion a fuentes ³±±
±±³             ³        ³          ³nuevas estructuras SX para Version 12.³±±
±±³Jonathan Glez³01/10/15³PCREQ-4262³Se elimina el campo C5_CODMNUN pues no³±±
±±³             ³        ³          ³existe en la tabla SC5.               ³±±
±±³Jonathan Glez³09/10/15³PCDEF-69888³Modificacion a funcion A462ANGera se ³±±
±±³             ³        ³           ³ agregua una difurbacion por pais al ³±±
±±³             ³        ³           ³llamar la rutina PutSF2 cuando se va ³±±
±±³             ³        ³           ³actualizar el campo F2_RUTCLI pues el³±±
±±³             ³        ³           ³campo es solo para Chile.            ³±±
±±³M.Camargo    ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8               ³±±
±±³Jonathan Glez³18/10/16³PCDEF2015_ ³Modificacion a funcion A462ANGera    ³±±
±±³             ³        ³  2016-7827³el campo C5_CODMNUN se cambia por el ³±±
±±³             ³        ³           ³campo C5_CODMUN                      ³±±
±±³M.Camargo    ³09.11.15³SERINN001  ³Implementación de uso FWTemporaryTable±±
±±³             ³        ³-972       ³se remueve uso de CTREE funcion      ³±±
±±³             ³        ³           ³GERATRB()                            ³±±
±±³Dora Vega    ³23/03/17³MMI-4420   ³Merge de replica del issue MMI-4306. ³±±
±±³             ³        ³           ³Hacer un salto de registro en el     ³±±
±±³             ³        ³           ³Punto de Entrada M462VLIT.(ARG)      ³±±
±±³Dora Vega    ³02/05/17³MMI-4509   ³Merge de replica del issue MMI-4398. ³±±
±±³             ³        ³           ³Se agrega a mex dentro de validacion,³±±
±±³             ³        ³           ³sin detonar 460TTSLANC, MV_TTS=N(MEX)³±±
±±³Dora Vega    ³08.06.17³ MMI-6003  ³Cambios en la funcion ChkFolARG para ³±±
±±³             ³        ³ MMI-6016  ³recibir correctamente sucursal. (ARG)³±±
±±³Raul Ortiz M ³22/12/17³DMICNS-652 ³Se agrega Transportadora desde el    ³±±
±±³             ³        ³           ³pedido de Venta. (Arg)               ³±±
±±³M.Camargo    ³05/04/18³DMINA-932  |REPLICA DMINA-594 MEX Se desactiva la³±± 
±±³             ³        ³           ³validacion del parametro MV_TSS,la   ³±±
±±³             ³        ³           ³cual  no permite el uso de contabili-³±±
±±³             ³        ³           ³dad on line cuando el parametro      ³±±
±±³             ³        ³           ³MV_TSS se tiene como S.              ³±±
±±³M.Camargo    ³23/04/18³DMINA-2637 |REPLICA DMINA-932 VEN Se desactiva la³±± 
±±³             ³        ³           ³validacion del parametro MV_TSS,la   ³±±
±±³             ³        ³           ³cual  no permite el uso de contabili-³±±
±±³             ³        ³           ³dad on line cuando el parametro      ³±±
±±³             ³        ³           ³MV_TSS se tiene como S.              ³±±
±±³M.Camargo    ³07/03/17³DMINA-6224 |PER- Se realiza gravacion de campo   ³±± 
±±³             ³        ³           ³F2_TIPONF = C5_TIPONF                ³±±
±±³M.Camargo    ³15/04/19³DMINA-6542 |PER- Se realiza gravacion de campo   ³±± 
±±³             ³        ³           ³F2_SERIE2 = FP_SERIE2                ³±±
±±³ARodriguez   ³04/06/19³DMINA-6593 |Creación de PE M462CPOS para agregar ³±± 
±±³             ³        ³           ³campos virtuales al MarkBrow   PER   ³±±
±±³V.Flores     ³24/09/19³DMINA-7404 |PER- Se realiza grabación de campo   ³±± 
±±³             ³        ³           ³F2_NUMORC = C5_NUMORC                ³±±
±±³A.Sandoval   ³27/11/19³DMINA-7696 |EUA - REPLICA DMINA-932 Se desactiva ³±± 
±±³             ³        ³           |la validacion del parametro MV_TTS   ³±±
±±³             ³        ³           |la cual no permite el uso de conta-  ³±± 
±±³             ³        ³           |bilidad on line cuando esta activado ³±±
±±³             ³        ³           |EUA - Se realiza grabacion de campo  ³±± 
±±³             ³        ³           |F2_TPACTIV = C5_TPACTIV 			   ³±±    
±±³Jose Glez    ³18/06/20³DMINA-9145 |Se agrega validación para la existencia³±±
±±³             ³        ³           |del campo SC6_CCUSTO y SC6_CC para el³±±
±±³             ³        ³           |llenado del campo D2_CCUSTO          ³±±            
±±³Cuauhtémoc   ³21-04-14³DMINA-11649|Se corrige el uso de moneda          ³±±
±±³Olvera       ³        ³             seleccionada. (MEX)                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATA462AN()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 									 	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local nOrdSX3

Local aCpos	:= {}
Local nI	:= 0
Local nX	:= 0
Local lCtbInTran   := .T.
Local nAux := 0
Local lAutomato  :=IsBlind()  //Se inicializa en .T. cuando viene por automatización, en todos los demás casos es .F.

Private aOrd       := {}
Private aVar       := {}
Private nIndex     := 0
Private nOpt1      := 2
Private aListRLock := {}
Private cDescri    := GetDescRem()
Private cMarca	   :=	"  "
Private cNomeArq   := ""
Private aParams	   :=	{}
Private lLocxAuto  := .F.
Private cLocxNFPV := "" 
Private cIdPVArg := "" 
Private oTmpTable	:= Nil
//Ajuste para permitir la inclusión de títulos provisionales de remito
Private aDupl	:= {}

SetMaxCodes(GetNewPar("MV_NUMLOCS",50))
nI       := 0
aInd     :={}
lFiltra  :=.F.
lSelect  :=.F.
cSB6Ant  :=""
c460Index:=''
lGrade   := .F.
aPos     := {  8,  4, 11, 74 }      
Static nOpcao := 0


dbSelectArea("SCN")

aRotina := {{OemToAnsi(STR0001),"A462ANPesq()", 0 , 1},; //"Buscar"
			{(OemToAnsi(STR0069)+cDescri),"A462ANGera(nIndex,cMarca,.F.,,,aParams)", 0 , 3},; //"Gera "+cDescri+
			{(OemToAnsi(STR0081)),"a462ANDivid()", 0 , 3} } //"Selec. parcial"

cCadastro := cDescri //cDescri (Remito, Remision, Guia de Despacho,...)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas           							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros						 ³
//³ mv_par01	  // Filtra j  emitidas 	 - Sim/Nao			 ³
//³ mv_par02 	  // Trazer Ped. Marc  	    - Sim/Nao			 ³
//³ mv_par03	  // De	Pedido									 ³
//³ mv_par04	  // Ate Pedido									 ³
//³ mv_par05	  // De	Cliente									 ³
//³ mv_par06	  // Ate Cliente								 ³
//³ mv_par07	  // De	Loja									 ³
//³ mv_par08	  // Ate Loja									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If  Pergunte("MT462A",.T.)
	If  MV_PAR13 ==2 .and. Recmoeda(dDatabase,MV_PAR14)<=0
		MsgAlert(OemToAnsi(STR0080))
		Return .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao e permitido utilizar Lancamento On-Line com TTS ativado (c/ excecoes)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( MV_PAR11 == 1 .And. !cPaisLoc $ "PTG|ARG|CHI|URU|COL|MEX|EQU|PER|VEN|PAR|BOL|EUA|" )
	
		// Verifica se contabilizacao pode ser executada dentro da transacao
		If cPaisLoc == "PER" 
			lCtbInTran := IIf(FindFunction("CTBINTRAN") .And. CTBINTRAN(1,MV_PAR09==1),.T.,.F.)
		EndIf
		If ( (cPaisLoc <> "RUS") .And. (cPaisLoc <> "PER" .Or. (cPaisLoc == "PER" .And. !lCtbInTran)) )
			HELP(" ",1,"460TTSLANC")
			Return .F.
		EndIf	
	Endif

If (cPaisLoc == "ARG")
    nAux := MV_PAR01
 	If !Pergunte("PVXARG",.T.)
		Return .F.
	Endif
	cLocxNFPV := MV_PAR01
	cIdPVArg := POSICIONE("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
	If !F083ExtSFP(MV_PAR01, .T.)
		Return .F.
	EndIf
	MV_PAR01 := nAux
EndIf

	Processa({|| GeraTrb(@aCpos) } )
	aParams	:=	{mv_par09,mv_par10,mv_par11,mv_par12,mv_par13,mv_par14}
	TRB->(DbSetOrder(1))
	If Len(aCpos) > 0
		If !lAutomato 
		    MarkBrow("TRB","C9_OK","C9_BLEST+C9_BLCRED+C9_REMITO",aCpos  ,.F.,cMarca,"Processa({| | a462nMrkAll()})",,"x462ANFilial","x462ANFilial","a462NMrk()")
	    Else // Ingresa si viene por script de autmatización
	       A462ANGera(nIndex,cMarca,.F.,,,aParams)
	  Endif
	EndIf

	For nX := 1 To Len(aListRlock)
		SC9->(DbGoTo(aListRlock[nX]))
		SC9->(MsUnLock())
	Next nX

	DbSelectArea("TRB")
	DbCloseArea()
	Ferase(cNomeArq + GetDbExtension())
	Ferase(cNomeArq+OrdBagExt())
	For nI:=1 To Len(aOrd)
		Ferase(aVar[nI]+OrdBagExt())
	Next
EndIf
SetMaxCodes(20)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A462ANGera   ³ Autor ³ Bruno Sobieski    ³ Data ³ 11.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do Remito automatico								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A462ANGera()							                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA462                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A462ANGera(_nIndex,_cMarca,lAtm,aRECSC9,lCarga,aParams)

Local cCliFor, cLoja
Local lAgrupa 		:= .T.
Local nSC9			:=	1
Local aArea			:= {} 
Local bWhile
Local nOrder 		:= IndexOrd()
Local cChave		:=	""
Local nTotalItem 	:= GETMV("MV_NUMITEN")
Local aSC9			:=	{}
Local lRetGravacao	:=.F.
Local aPergs		:=	{}
Local nX:=0,nI:=0,nY:=0
Local aRems			:=	{}
Local nTipoGer		:=	1
Local nMoedSel		:=	1
Local nDescUnit 	:= 0
Local nDesctotal	:= 0
Local nValTot		:= 0
Local nPrecoVenda	:= 0
Local nPrecoUnit	:= 0
Local aTotPes		:= {}
Local nValAux		:= 0
Local nIndeniz      := 0
Local lUsoTxMoe		:= .F.		// Verifica se o campo C5_TXMOEDA esta em uso
Local nC5Descont 	:= 0
Local cTpdpind 		:= GetNewPar("MV_TPDPIND","1")
Local aTotaFat		:= {}
Local aSemPermiss	:= {}		// Array para armazenar os pedidos de Vendas que o usuário não tem premissão para gerar Remito
Local cSemPermiss	:= ""		// String para armazenar os pedidos de Vendas que não foram gerado o Remito devido a falta de permissão
Local aAprRem       := {}      // Remitos que precisam de codigo de liberacao
Local lRemLoc		:= .F.		// Indica se o remito eh localizado - Release 11.5 - Chile - F2CHI
Local lIntACD		:= SuperGetMV("MV_INTACD",.F.,"0") == "1" 
Local lItemLoop		:= .F.
Local nAux := 0
Local _lLocItem := ExistBlock("LOCITEM2")
Local cNomeFun := FUNNAME()
Local lRetPV		 := .T.
Local nPrc := 0 
Local nBasImp1		as Numeric
Local nValImp1		as Numeric
Local nGross1		as Numeric
Local nNet1			as Numeric 
Local nTxMoeda		as Numeric
Local cClie			AS CHARACTER
Local cBranch		AS CHARACTER
Local cOrder		AS CHARACTER
Local lFormLib		:= .F.
Local lAutomato  := IsBlind() //Se inicializa en .T. cuando viene por automatización, en todos los demás casos es .F.
Local cIdMetric     := ""
Local cSubRutina    := ""
Local lGenera       := .T.
Local cProvFE		:= SuperGetMV("MV_PROVFE",,"")
Local aDatosSFP        := {}
Local lValCp        := SuperGetMV("MV_VALGREQ",,.F.)

Private aHeader		:=	{}
Private aHeadSF2	:=	{}
Private aSF2		:=	{}
Private aSD2		:=	{}
Private aCols		:={}
Private nPosRef		:=	0
Private nItemAtu	:=	0
Private aRef		:=	{}
Private cEspecDoc   := "RFN"
If type("cLocxNFPV") == "U"
	Private cLocxNFPV := ""
EndIf

If cPaisLoc == "GUA"
   Private cNumResol   := Space(TamSX3("FQ_RESOLUC")[1])	
EndIf
//(27/09/18): F2_DTSAIDA
If cPaisloc == "RUS"
	Private dDtSaida AS DATE
EndIf

If GetMV("MV_ULMES") >= dDataBase
   	Help( " ", 1, "FECHTO" )
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o campo C5_TXMOEDA esta em uso.                 ³
//³ Se o campo C5_TXMOEDA estiver em uso, estiver zerado e a    ³
//³ a taxa da moeda do pedido nao estiver cadastrada no cadastro³
//³ de moedas, nao permite a geracao do remito.                 ³
//³ Considerando parametro "Factura Pedido por la"? preenchido  ³
//³ com "Moneda do Pedido"										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('SX3')
DbSetOrder(2)
If DbSeek("C5_TXMOEDA")
	If X3Uso(X3_USADO)
		lUsoTxMoe := .T.
	EndIf
EndIf

DbSelectArea('SX3')
DbSetOrder(1)
DbSeek('SD2')
While X3_ARQUIVO == 'SD2' .And. !EOF()
	AADD(aHeader,{ TRIM(X3Titulo()), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO,X3_CONTEXT } )
	dbSkip()
Enddo


DbSeek('SF2')
While X3_ARQUIVO == 'SF2' .And. !EOF()
	AADD(aHeadSF2, X3_CAMPO)
	dbSkip()
Enddo


If lAtm == NIL
	lAtm:=.F.
Endif
If lCarga == NIL
	lCarga :=.F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de Variaveis...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _nIndex == Nil
	_nIndex  := 1
Endif


lDigita    := (aParams[1]==1)
lAglutina  := (aParams[2]==1)
lGeraLanc  := (aParams[3]==1)
lAgrupa	  := (aParams[4]==1)
nTipoGer	:=	aParams[5]  // 1 - Moeda Pedido  / 2- Moeda Selecionada
nMoedSel	:=	aParams[6]  // 1 - Moeda 1  / 2- - Moeda 2 /...

If cPaisloc == "RUS"
	dDtSaida	:= dDatabase
	nBasImp1	:= 0
	nValImp1	:= 0
	nGross1		:= 0
	nNet1		:= 0
EndIf

IF lAtm
	bWhile 	:= { || nSC9	<=	Len(aRecSC9) }
	SC9->(DbGoTo(aRecSC9[nSC9]))
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varrer o SC9 respeitando o intervalo e o filtro e gravar na area          ³
	//³ temporaria, porque a indregua no client ‚ mais r pida do que no banco TOP.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bWhile 	:= { || 	(!TRB->(EOF()))}

	DbSelectArea("TRB")
	DbSetOrder(_nIndex)
	DbSeek(xFilial("SC9"))
	SC9->(DbGoTo(TRB->RECNO))	
	

	
	//Localizacao Colombia. Codigo de Aprovacao do Remito	
	If cPaisLoc == "COL" .AND. SC9->(FieldPos("C9_APRREM")) > 0 .AND. SA1->(FieldPos("A1_APRREM")) > 0 .AND. SD2->(FieldPos("D2_APRREM")) > 0	
		While Eval( bWhile )                                                                                           
			//Verifica se está marcado e se será necessaria liberacao
			If IIF(!lAtm,IsMark("C9_OK"),.T.) .And. Empty(SC9->C9_BLEST+SC9->C9_BLCRED+SC9->C9_REMITO+SC9->C9_APRREM)
			 	Aadd(aAprRem,TRB->RECNO) //joga na array pq havera manipulacao de registros na divisao de qtds parciais
			EndIf 
			DbSelectArea("TRB")
			DbSkip()
			DbSelectArea('SC9')
			DbGoTo(TRB->RECNO)				
		EndDo
		DbSelectArea('TRB')
		DbGoTop()		
		While !(TRB->(EOF()))  			
			If AScan(aAprRem, TRB->RECNO) > 0
				a462ANDivid(.T.) //Chama tela de selecao parcial para o item caso C9_APRREM esteja vazio
				If a462GetOp() == 0 //Caso tenha cancelado, desmarca do browse para nao gerar o remito
					RecLock("TRB",.F.)
					TRB->C9_OK := "  "						
					MsUnlock()
					DbSelectArea("SC9")
					DbGoTo(TRB->RECNO)					
					RecLock("SC9",.F.)															
					SC9->C9_OK := "  "											
					MsUnlock()
					DbSelectArea('TRB')									
				EndIf
			EndIf             			
			dbSkip() 
			DbSelectArea('SC9')
			DbGoTo(TRB->RECNO)				
			DbSelectArea('TRB')				
		EndDo	
		DbSelectArea("TRB")
		DbGoTop()	
		DbSetOrder(_nIndex)
		DbSeek(xFilial("SC9"))
		SC9->(DbGoTo(TRB->RECNO))			
	EndIf	               	
Endif

cChave	:=	'StrZero(Max(SC5->C5_MOEDA,1),2)+If(Empty(SC5->C5_TIPOREM),"0",SC5->C5_TIPOREM)+SC5->C5_TIPO+SC9->C9_CLIENTE+SC9->C9_LOJA'+IIf(lCarga,'+SC9->C9_CARGA','')+IIf(!lAgrupa,'+SC9->C9_PEDIDO','')
If cPaisLoc == "COL" .And. SC5->(FieldPos('C5_CODMUN')) > 0
	cChave	+=	"+SC5->C5_CODMUN"
Endif
If SC5->(FieldPos('C5_PROVENT')) > 0
	cChave	+=	"+SC5->C5_PROVENT"
Endif

If cPaisLoc == "ARG" .And. SC5->(ColumnPos('C5_CANJE')) > 0
	cChave	+=	"+SC5->C5_CANJE"
Endif
If cPaisLoc == "RUS" .And. lAgrupa
	cChave += "+SC5->C5_F5QCODE" 
EndIf

If cPaisLoc == "ARG" .And. SC5->(ColumnPos('C5_CLIENT')) > 0
	cChave	+=	"+SC5->C5_CLIENT"
Endif

If cPaisLoc == "ARG" .And. SC5->(ColumnPos('C5_LOJAENT')) > 0
	cChave	+=	"+SC5->C5_LOJAENT"
Endif


DbSelectArea("SC9")
If       SF1->(ColumnPos("F1_FORMLIB")) > 0 .and.  SF2->(ColumnPos("F2_FORMLIB")) > 0 .and.  SF3->(ColumnPos("F3_FORMLIB")) > 0
	lFormLib:=.t.	
EndIf

If (cPaisLoc == "ARG" .or. (cPaisLoc == "URU")) .and. _lLocItem
	 nTotalItem := LocNumIt2(SF2->F2_SERIE,cNomeFun)
Endif

While Eval( bWhile )
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for automatico (lAtm = .T.) so vou procesar os registros recebidos no³
	//³aRecSC9, por isso nao preciso fazer verificacoes . Bruno                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
   If !lAutomato
	If !lAtm	.And. (!IsMark("C9_OK") .Or. !Empty(SC9->(C9_BLEST+C9_BLCRED+C9_REMITO)))
		DbSelectArea("TRB")
		DbSkip()
		DbSelectArea('SC9')
		DbGoTo(TRB->RECNO)
		Loop
	Endif
   Else // Ingresa por script de automatización
    If !lAtm	.And. (!SC9->C9_OK <> Nil .Or. !Empty(SC9->(C9_BLEST+C9_BLCRED+C9_REMITO)))  
        DbSelectArea("TRB")
		DbSkip()
		DbSelectArea('SC9')
		DbGoTo(TRB->RECNO)
		Loop
    EndIf
   EndIf
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial()+SC9->C9_PEDIDO)

	DbSelectArea("SC9")
	IF cPaisLoc== "ARG" .AND. FindFunction("AcdFatOsep") .AND. !(AcdFatOsep("SC9", ))
		RETURN .F.
	ENDIF
	If IIF (!lAutomato,IIF(!lAtm,IsMark("C9_OK"),.T.) .And. Empty(SC9->C9_BLEST+SC9->C9_BLCRED+SC9->C9_REMITO), (IIF(!lAtm,.T.,.T.) .And. Empty(SC9->C9_BLEST+SC9->C9_BLCRED+SC9->C9_REMITO)))
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o usuario tem premissao para alterar o ³
		//³pedido de venda usando campo C5_CATPV            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DBSelectArea("SC5")
		DBSetOrder(1)
		If cPaisLoc <> "BRA" .AND. DBSeek(xFilial("SC5") + SC9->C9_PEDIDO)
			If FieldPos("C5_CATPV") > 0 .AND. !Empty(SC5->C5_CATPV)
				If AliasIndic("AGS") //Tabela que relaciona usuario com os Tipos de Pedidos de vendas que ele tem acesso
					DBSelectArea("AGS")
					DBSetOrder(1)
					If DBSeek(xFilial("AGS") + __cUserId) //Se não encontrar o usuário na tabela, permite ele alterar o pedido
						If !DBSeek(xFilial("AGS") + __cUserId + SC5->C5_CATPV) //Verifica se o usuario tem premissao
							If ASCAN(aSemPermiss, {|x| x == SC9->C9_PEDIDO}) = 0
								AADD(aSemPermiss,SC9->C9_PEDIDO)
							EndIf
							TRB->(DBSkip())
							Loop
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		// Se o TTS estiver ativado nao e preciso esta validacao pois o DisarmTransaction nao deixa gravado SF2 sem SD2. 
		If !__TTSInUse .And. lUsoTxMoe .And. nTipoGer == 1 .And. SC5->C5_MOEDA > 1 .And. SC5->C5_TXMOEDA == 0 .And. Recmoeda(dDatabase,nMoedSel) == 0
			If !lAtm
				DbSelectArea('TRB')
				dbSkip()
				DbSelectArea('SC9')
				DbGoTo(TRB->RECNO)
				Loop
			Else
				DbSelectArea('SC9')
				If ++nSC9 <=	Len(aRecSC9)
					SC9->(DbGoTo(aRecSC9[nSC9]))
					Loop
				Else
					Exit
				Endif
			Endif
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravar o arquivo de Remitos a partir de SC9.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		dbSelectArea("SC5")
		dbSetOrder(1)
		MsSeek( xFilial("SC5")+ SC9->C9_PEDIDO )
		
		If  ExistBlock("M462VLIT")
   			lItemLoop := ExecBlock("M462VLIT",.F.,.F.)
   			If !lItemLoop
   				++nSC9
				Loop
   			EndIf
   		EndIf
		//calcular o valor total e o peso total do pedido
		a462anToPe(SC9->C9_PEDIDO,@aTotPes,@aTotaFat)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Posiciona o item do pedido no arquivo  SC6          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		dbSetOrder(1)
		MsSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avaliar se a chave já está no array de remitos.³
		//³e se nao estorou o numero de itens.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPosRef	:=	Ascan(aRef,{|x|  x == &(cChave)+"OK" } )) == 0 
			AAdd(aREF,&(cChave)+"OK")				
			Aadd(aSD2,{})
			Aadd(aSC9,{})
			Aadd(aSF2,Array(Len(aHeadSF2)))       
			nPosRef	:=	Len(aRef)
			If cPaisLoc == "RUS"		//function of dialog for F2_DTSAIDA
				If !lAgrupa .AND. !(cClie == SC9->C9_CLIENTE .AND. cBranch == SC9->C9_LOJA .AND. cOrder == SC9->C9_PEDIDO)
					dDtSaida := RU05XDTSAI(SC9->C9_PEDIDO, SC9->C9_CLIENTE, SC9->C9_LOJA)	
					cOrder	:= SC9->C9_PEDIDO
					cClie	:= SC9->C9_CLIENTE
					cBranch	:= SC9->C9_LOJA
				ElseIf lAgrupa .And. !(cClie == SC9->C9_CLIENTE .AND. cBranch == SC9->C9_LOJA)
					dDtSaida := RU05XDTSAI(SC9->C9_PEDIDO, SC9->C9_CLIENTE, SC9->C9_LOJA)	
					cOrder	:= SC9->C9_PEDIDO
					cClie	:= SC9->C9_CLIENTE
					cBranch	:= SC9->C9_LOJA
				EndIf	
			EndIf
		ElseIf Len(aSD2[nPosRef] ) == nTotalItem
			aRef[nPosRef]	:=	Substr(aRef[nPosRef],1,Len(aRef[nPosRef])-2)
			AAdd(aREF,&(cChave)+"OK")				
			Aadd(aSD2,{})
			Aadd(aSC9,{})
			Aadd(aSF2,Array(Len(aHeadSF2)))         
			nPosRef	:=	Len(aRef)
			If cPaisLoc == "RUS"
				If !(cClie == SC9->C9_CLIENTE .AND. cBranch == SC9->C9_LOJA)
					dDtSaida := RU05XDTSAI(SC9->C9_PEDIDO, SC9->C9_CLIENTE, SC9->C9_LOJA)	
					cOrder	:= SC9->C9_PEDIDO
					cClie	:= SC9->C9_CLIENTE
					cBranch	:= SC9->C9_LOJA
				EndIf
			EndIf
		Endif
	
		AAdd(aSD2[nPosRef],Array(Len(aHeader )+1))		

		For nX:=1 To Len(aHeader)
			aSD2[nPosRef][Len(aSD2[nPosRef])][nX]	:=	CriaVar(aHeader[nX][2],.F.)
		Next
		aSD2[nPosRef][Len(aSD2[nPosRef])][Len(aHeader)+1]	:=	.F.

		nItemAtu	:=	Len(aSD2[nPosRef])		
		AAdd(aSC9[nPosRef],If(lAtm,SC9->(Recno()),TRB->(Recno()) ))

		dbSelectArea("SB1") 
		dbSetOrder(1)
		MsSeek( xFilial("SB1")+SC9->C9_PRODUTO )

		DbSelectArea("SC9")
		dbSetOrder(1)
	
		//Posiciona Cliente ou Fornecedor de acordo com o tipo de pedido
		If SC5->C5_TIPO$"DB"
			dbSelectArea("SA2")
			dbSetOrder(1)
			MsSeek( xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI )
			cCliFor:=A2_COD
			cLoja  :=A2_LOJA
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			MsSeek( xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI )
			cCliFor:=A1_COD
			cLoja  :=A1_LOJA
		Endif
	
	
		dbSelectArea("SC6")
		dbSetOrder(1)
		MsSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Release 11.5 - Chile - F2CHI                                      ³
		//³Para pedido gerado no SIGALOJA, gerar Guia de Despacho especifica.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If GetRpoRelease ("R5") .AND. ;
			SuperGetMv("MV_CTRLFOL",,.F.) .AND.;
			cPaisLoc == "CHI" .AND.;
			SC5->(FieldPos("C5_ORCRES")) > 0 .AND. ;
			!Empty(SC5->C5_ORCRES) .AND. ;
			(Type("lAtm") == "U" .OR. !lAtm)		
			
	   		lRemLoc:= a462GdpChi(cCliFor ,cLoja,nMoedSel,nTipoGer)
		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o Remito nao eh localizado    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRemLoc		
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Incluir Remitos de Saida                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			PutSD2('D2_CLIENTE'  ,cCliFor)
			PutSD2('D2_LOJA'     ,cLoja)
			PutSD2('D2_EMISSAO'  ,dDataBase)
			PutSD2('D2_COD'  		,SC9->C9_PRODUTO)
			PutSD2('D2_UM'       ,SC6->C6_UM)
			PutSD2('D2_QUANT'    ,SC9->C9_QTDLIB)
			PutSD2('D2_QTDAFAT'  ,IIf(SC5->C5_TIPOREM $ ' 01'+_RMCONS,SC9->C9_QTDLIB,0))
			PutSD2('D2_SEGUM'    ,SC6->C6_SEGUM)
			PutSD2('D2_QTSEGUM'  ,(SC6->C6_UNSVEN * (GetSD2('D2_QTDAFAT') / SC6->C6_QTDVEN)))
			PutSD2('D2_LOCAL'    ,SC6->C6_LOCAL)
			PutSD2('D2_PEDIDO'   ,SC9->C9_PEDIDO)
			PutSD2('D2_ITEMPV'  	,SC9->C9_ITEM)
			PutSD2('D2_SEQUEN'  	,SC9->C9_SEQUEN)
			PutSD2('D2_NUMSEQ'   ,ProxNum())
			
			If SC5->C5_TIPOREM == _RMCONS
				PutSD2('D2_TES'      ,Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_TESENV") )
			Else
				PutSD2('D2_TES'      ,SC6->C6_TES)
				SF4->(dbSetOrder(1))
				SF4->(MsSeek( xFilial("SF4")+SC6->C6_TES ))			
			Endif
			
			If Alltrim(Funname()) == "MATA462AN" .And. GetNewPar('MV_DESCSAI','1') =='2'
				PutSD2('D2_DESCON'   ,SC6->C6_VALDESC)
			Endif
			//Grava CC.
			IF cPaisloc <> "BRA"
				If SC6->(ColumnPos("C6_CCUSTO")) > 0 .and. SC6->(ColumnPos("C6_CC")) > 0 
					If SC6->C6_CC <> ""
						PutSD2('D2_CCUSTO'   ,SC6->C6_CC)
					Else
						PutSD2('D2_CCUSTO'   ,SC6->C6_CCUSTO)
					EndIF
				Elseif SC6->(ColumnPos("C6_CC")) > 0 	
					PutSD2('D2_CCUSTO'   ,SC6->C6_CC)
				Elseif SC6->(ColumnPos("C6_CCUSTO")) > 0 	
					PutSD2('D2_CCUSTO'   ,SC6->C6_CCUSTO)
				Endif
			Else
				PutSD2('D2_CCUSTO'   ,SC6->C6_CC)
			EndIF
			PutSD2('D2_CF'       ,SC6->C6_CF)
			PutSD2('D2_GERANF'   ,Iif(SA1->A1_CONFREM == "1","N",If(Empty(SC6->C6_GERANF),"S", SC6->C6_GERANF)))
			PutSD2('D2_TP'     	 ,SB1->B1_TIPO)
			PutSD2('D2_AGREG'    ,SC9->C9_AGREG)
			PutSD2('D2_GRUPO'    ,SC9->C9_GRUPO)
			PutSD2('D2_SEQUEN'   ,SC9->C9_SEQUEN)
			PutSD2('D2_NUMSERI'  ,SC6->C6_NUMSERI)
			PutSD2('D2_COMIS1'   ,SC6->C6_COMIS1)		
			PutSD2('D2_COMIS2'   ,SC6->C6_COMIS2)		
			PutSD2('D2_COMIS3'   ,SC6->C6_COMIS3)		
			PutSD2('D2_COMIS4'   ,SC6->C6_COMIS4)		
			PutSD2('D2_COMIS5'   ,SC6->C6_COMIS5)
			PutSD2('D2_CODFAB'	 ,SC6->C6_CODFAB)
			PutSD2('D2_LOJAFA'	 ,SC6->C6_LOJAFA)	
			if cPaisLoc == "RUS"
				PutSD2('D2_DESCRI'	 ,SB1->B1_DESC )
				PutSD2('D2_FDESC'	 ,SC6->C6_FDESC)
			EndIf
			//Provincia de entrega		
			If cPaisLoc == "ARG"
				If SD2->(FieldPos("D2_PROVENT")) > 0 .And. SC6->(FieldPos("C6_PROVENT")) > 0
					PutSD2('D2_PROVENT'	,SC6->C6_PROVENT)
				Endif
			Endif
			
			// Calculo Valores Moeda do Pedido
			If Alltrim(Funname()) == "MATA462AN" .And. GetNewPar('MV_DESCSAI','1') =='2' .or. ((cPaisLoc $ "PAR|MEX") .and. (SC6->C6_PRUNIT == 0))
				nPrc := SC6->C6_PRCVEN + SC6->C6_VALDESC / SC6->C6_QTDVEN
				nDescUnit   := Max((nPrc - SC6->C6_PRCVEN),0)
			Else
				nDescUnit   := Max((SC6->C6_PRUNIT - SC6->C6_PRCVEN),0)
			Endif 
			nDesctotal  := A410Arred(GetSD2('D2_QUANT') * nDescUnit,"D2_DESCON",If(cPaisLoc=="CHI",If(nTipoGer==2,nMoedSel,SC5->C5_MOEDA),NIL))
			//nValTot		:= SC6->C6_PRCVEN + IIf(GetNewPar('MV_DESCSAI','1') =='1',0,nDescUnit)
			nPrecoVenda	:= SC9->C9_PRCVEN + IIf(GetNewPar('MV_DESCSAI','1') =='1',0,nDescUnit)
			nPrecoUnit	:= SC6->C6_PRUNIT

			//Desconto referente a indenizacao
			nIndeniz := 0
			If SC5->C5_PDESCAB <> 0
				nIndeniz    := SC9->C9_PRCVEN * (SC5->C5_PDESCAB/100)
				nPrecoVenda := nPrecoVenda - Iif(GetNewPar('MV_DESCSAI','1') == '2',0,nIndeniz)
				nValTot     := nValTot - Iif(GetNewPar('MV_DESCSAI','1') == '2',0,nIndeniz)
				nDesctotal	+= (GetSD2('D2_QUANT') * nIndeniz)
			Endif
	
			// Calculo referente ao rateio do campo C5_DESCONT
			nC5Descont := 0
	  		If SC5->C5_DESCONT <> 0
				If (cTpdpind == "2" .And. SF4->F4_DUPLIC=="S") .Or. (cTpdpind == "1")
					nPos := AScan(aTotaFat,{|x| x[1] == SC5->C5_NUM })
					If nPos > 0
						nC5Descont:= a410Arred((SC9->C9_QTDLIB * SC9->C9_PRCVEN * SC5->C5_DESCONT) / aTotaFat[nPos,2],"D2_DESCON")					
						nC5Descont:= nC5Descont / SC9->C9_QTDLIB
					EndIf
					nPrecoVenda := nPrecoVenda - Iif(GetNewPar('MV_DESCSAI','1') == '2',0,nC5Descont)
					nValTot     := nValTot - Iif(GetNewPar('MV_DESCSAI','1') == '2',0,nC5Descont)
					nDesctotal	+= (GetSD2('D2_QUANT') * nC5Descont)
				EndIf
			EndIf  
					
			If nTipoGer == 2   // Converte Valores
				If SuperGetMV("MV_ARREFAT")== "S"     // Arredonda Valores
					nValTot		:= 	xMoeda(nValTot    ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_TOTAL") [2]+1)
					nDesctotal	:= 	xMoeda(nDesctotal ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_DESCON")[2]+1)
					nPrecoVenda	:= 	xMoeda(nPrecoVenda,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_PRCVEN")[2]+1)
					nPrecoUnit	:= 	xMoeda(nPrecoUnit ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_PRUNIT")[2]+1)				
					nIndeniz	:= 	xMoeda(nIndeniz   ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_PRUNIT")[2]+1)				
					nC5Descont	:= 	xMoeda(nC5Descont ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_PRUNIT")[2]+1)
					nValTot		:= 	Round(nValTot    ,TamSx3("D2_TOTAL") [2])   
					nDesctotal	:= 	Round(nDesctotal ,TamSx3("D2_DESCON")[2]) 
					nPrecoVenda :=	Round(nPrecoVenda,TamSx3("D2_PRCVEN")[2])            
					nPrecoUnit	:= 	Round(nPrecoUnit ,TamSx3("D2_PRUNIT")[2]) 				
					nIndeniz	:= 	Round(nIndeniz   ,TamSx3("D2_PRUNIT")[2]) 				
				Else   // Trunca Valores
					nValTot		:= 	xMoeda(nValTot    ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_TOTAL") [2])
					nDesctotal	:= 	xMoeda(nDesctotal ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_DESCON")[2])
					nPrecoVenda	:= 	xMoeda(nPrecoVenda,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_PRCVEN")[2])
					nPrecoUnit	:= 	xMoeda(nPrecoUnit ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_PRUNIT")[2])				
					nIndeniz	:= 	xMoeda(nIndeniz   ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_PRUNIT")[2])				
					nC5Descont	:= 	xMoeda(nC5Descont ,SC5->C5_MOEDA,nMoedSel,dDatabase,TamSx3("D2_PRUNIT")[2])
				EndIf
			EndIf
			If cPaisLoc == "ARG" .and. nPrecoUnit != 0
				nDesctotal := A410Arred(GetSD2('D2_QUANT') * SC6->C6_PRUNIT,"D2_DESCON") - A410Arred( GetSD2('D2_QUANT') * SC6->C6_PRCVEN,"D2_TOTAL")
				PutSD2('D2_TOTAL'  	,A410Arred(GetSD2('D2_QUANT') * nPrecoUnit ,"D2_TOTAL"))
				PutSD2('D2_PRCVEN'	,nPrecoUnit)
			Else		
				PutSD2('D2_TOTAL'  	,A410Arred(GetSD2('D2_QUANT') * nPrecoVenda ,"D2_TOTAL",If(cPaisLoc=="CHI",If(nTipoGer==2,nMoedSel,SC5->C5_MOEDA),NIL)))
				PutSD2('D2_PRCVEN'	,nPrecoVenda)
		    EndIf
			PutSD2('D2_DESC'	, SC6->C6_DESCONT)
			PutSD2('D2_DESCON'	,nDesctotal	) 
		    PutSD2('D2_PRUNIT'  ,nPrecoUnit)

			//Ajuste para permitir la inclusión de títulos provisionles de remito
			If cPaisLoc == "EUA"
				PutSF2('F2_COND'  	,SC5->C5_CONDPAG)
				PutSF2('F2_PREFIXO'	,'')
			EndIf

			//(16/07/18):VAT values
			If cPaisLoc == "RUS"
				nTxMoeda := Recmoeda(dDtSaida,SC5->C5_MOEDA)
				PutSD2('D2_ALQIMP1', SC6->C6_ALQIMP1)
				PutSD2('D2_BASIMP1', SC6->C6_BASIMP1)
				PutSD2('D2_VALIMP1', SC6->C6_VALIMP1)
				PutSD2('D2_VALBRUT', SC6->C6_BASIMP1 + SC6->C6_VALIMP1)
				PutSD2('D2_BSIMP1M', xMoeda(SC6->C6_BASIMP1,SC5->C5_MOEDA,1,dDtSaida,,nTxMoeda))
				PutSD2('D2_VLIMP1M', xMoeda(SC6->C6_VALIMP1,SC5->C5_MOEDA,1,dDtSaida,,nTxMoeda))
				PutSD2('D2_TOTALM' , xMoeda(SC6->C6_VALOR,SC5->C5_MOEDA,1,dDtSaida,,nTxMoeda))
				PutSD2('D2_VLBRUTM', xMoeda(SC6->C6_BASIMP1 + SC6->C6_VALIMP1,SC5->C5_MOEDA,1,dDtSaida,,nTxMoeda))
				nBasImp1	+=	SC6->C6_BASIMP1
				nValImp1	+=	SC6->C6_VALIMP1
				nGross1		+=	SC6->C6_BASIMP1 + SC6->C6_VALIMP1
				nNet1		+=	SC6->C6_VALOR
			Endif
			
			PutSF2('F2_CARGA'  	,SC9->C9_CARGA)
			PutSF2('F2_SEQCAR' 	,SC9->C9_SEQCAR)
			PutSF2('F2_MOEDA'  	,Iif(nTipoGer == 1,SC5->C5_MOEDA,nMoedSel)  )
			If cPaisloc == "RUS"
				PutSF2('F2_TXMOEDA'	, nTxMoeda)
			Else
				PutSF2('F2_TXMOEDA'	, Iif(nTipoGer == 1.And.SC5->C5_TXMOEDA>0,SC5->C5_TXMOEDA,Recmoeda(dDatabase,nMoedSel)))
			EndIf
			PutSF2('F2_NATUREZ' 	,SC5->C5_NATUREZ)
			If SC5->(FieldPos('C5_CODMUN')) > 0 .And.SF2->(FieldPos('F2_CODMUN')) >0 
				PutSF2('F2_CODMUN' 	,SC5->C5_CODMUN)
			Endif
			If SC5->(FieldPos('C5_PROVENT')) > 0 .And.SF2->(FieldPos('F2_PROVENT')) >0 
				PutSF2('F2_PROVENT' 	,SC5->C5_PROVENT)
			Endif
			PutSF2('F2_VEND1' ,SC5->C5_VEND1)
			PutSF2('F2_VEND2' ,SC5->C5_VEND2)
			PutSF2('F2_VEND3' ,SC5->C5_VEND3)
			PutSF2('F2_VEND4' ,SC5->C5_VEND4)
			PutSF2('F2_VEND5' ,SC5->C5_VEND5)
					
			PutSF2('F2_CLIENTE' ,cCliFor)
			PutSF2('F2_LOJA'    ,cLoja)
			PutSF2('F2_EMISSAO' ,dDataBase)
			PutSF2('F2_TIPOREM' ,SC5->C5_TIPOREM)
			PutSF2('F2_TIPO'    ,SC5->C5_TIPO)

			If cPaisloc == "RUS"
				PutSF2('F2_DTSAIDA' ,dDtSaida)
			EndIf
			
			If cPaisLoc $ "ARG|PER"
				If SF2->(ColumnPos("F2_TRANSP")) > 0 .And. SC5->(ColumnPos("C5_TRANSP")) > 0
					PutSF2('F2_TRANSP', SC5->C5_TRANSP) //Peso Bruto
				EndIf					
			EndIf
	
			If cPaisLoc $ "EUA"
				If SF2->(ColumnPos("F2_TPACTIV")) > 0 .And. SC5->(ColumnPos("C5_TPACTIV")) > 0
					PutSF2('F2_TPACTIV', SC5->C5_TPACTIV) //Tipo actividad
				EndIf					
			EndIf
			If cPaisLoc == "COL"
				If SF2->(FieldPos("F2_CODMUN")) > 0 .And. SC5->(FieldPos("C5_CODMUN")) > 0
					PutSF2('F2_CODMUN'	,SC5->C5_CODMUN)
				Endif
				If SF2->(FieldPos("F2_TIPOPE")) > 0 .And. SC5->(FieldPos("C5_TIPOPE")) > 0
					PutSF2('F2_TIPOPE'	,SC5->C5_TIPOPE)
				EndIf				
			Endif

			If cPaisLoc == "ARG"
				If FunName() <> "MATA460B"
				PutSF2('F2_PV'      ,cLocxNFPV) //Punto de venta
				Endif

				If SF2->(FieldPos("F2_PROVENT")) > 0 .And. SC5->(FieldPos("C5_PROVENT")) > 0
					PutSF2('F2_PROVENT'	,SC5->C5_PROVENT) //Provincia de entrega
				Endif

				If SF2->(ColumnPos("F2_CLIENT")) > 0 .And. SC5->(ColumnPos("C5_CLIENT")) > 0
					PutSF2('F2_CLIENT'	,SC5->C5_CLIENT) //Cliente de la entrega    
				EndIf

				If SF2->(ColumnPos("F2_LOJENT")) > 0 .And. SC5->(ColumnPos("C5_LOJAENT")) > 0
					PutSF2('F2_LOJENT'	,SC5->C5_LOJAENT) //Codigo Tienda de Entrega 
				EndIf
		
			Endif

			If SF2->(ColumnPos("F2_CANJE")) > 0 .And. SC5->(ColumnPos("C5_CANJE")) > 0 .And. cPaisLoc == "ARG"
				PutSF2('F2_CANJE'	,SC5->C5_CANJE) //CANJE
			Endif
			
			If cPaisloc == "PTG"
				PutSF2('F2_DIACTB'    ,mv_par15)
			EndIf      
			If cPaisLoc $ "PAR"
				If SF2->(ColumnPos("F2_INCOTER")) > 0 .And. SC5->(ColumnPos("C5_INCOTER")) > 0
					PutSF2('F2_INCOTER'	,SC5->C5_INCOTER) //Condición de la operación
				EndIf	
				If SF2->(ColumnPos("F2_TIPONF")) > 0 .And. SC5->(ColumnPos("C5_TIPONF")) > 0
					PutSF2('F2_TIPONF'	,SC5->C5_TIPONF) //Tipo Factura
				EndIf
				If SF2->(ColumnPos("F2_FECDSE")) > 0 .And. SC5->(ColumnPos("C5_FECDSE")) > 0
					PutSF2('F2_FECDSE'	,SC5->C5_FECDSE) //Fecha de inicio de traslado
				EndIf
				If SF2->(ColumnPos("F2_TPTRANS")) > 0 .And. SC5->(ColumnPos("C5_TPTRANS")) > 0
					PutSF2('F2_TPTRANS', SC5->C5_TPTRANS) //Tipo de Factura
				Endif
				If SF2->(ColumnPos("F2_FECHSE")) > 0 .And. SC5->(ColumnPos("C5_FECHSE")) > 0
					PutSF2('F2_FECHSE'	,SC5->C5_FECHSE) //Fecha de fin de traslado
				EndIf
				If SF2->(ColumnPos("F2_MOTEMIR")) > 0 .And. SC5->(ColumnPos("C5_MODTRAD")) > 0
					PutSF2('F2_MOTEMIR', SC5->C5_MODTRAD) //Tipo de Factura
				Endif
				
				If SF2->(ColumnPos("F2_VEICULO")) > 0 .And. SC5->(ColumnPos("C5_VEICULO")) > 0
					PutSF2('F2_VEICULO'	,SC5->C5_VEICULO) //Vehículo del traslado
				EndIf
				
				If SF2->(ColumnPos("F2_TRANSP")) > 0 .And. SC5->(ColumnPos("C5_TRANSP")) > 0
					PutSF2('F2_TRANSP'	,SC5->C5_TRANSP) //Motivo de Traslado - Guía de Remisión
				EndIf
				If SF2->(ColumnPos("F2_TPRESFL")) > 0 .And. SC5->(ColumnPos("C5_TPRESFL")) > 0
					PutSF2('F2_TPRESFL'	,SC5->C5_TPRESFL) //Motivo de Traslado - Guía de Remisión
				EndIf
			EndIf
			If cPaisLoc == "PER"
				If SF2->(ColumnPos("F2_NUMORC")) > 0 .And. SC5->(ColumnPos("C5_NUMORC")) > 0
					PutSF2('F2_NUMORC'	,SC5->C5_NUMORC) //Tipo Factura
				EndIf
				If SF2->(ColumnPos("F2_TIPONF")) > 0 .And. SC5->(ColumnPos("C5_TIPONF")) > 0
					PutSF2('F2_TIPONF'	,SC5->C5_TIPONF) //Tipo Factura
				EndIf	
				If SF2->(ColumnPos("F2_MODTRAD")) > 0 .And. SC5->(ColumnPos("C5_MODTRAD")) > 0
					PutSF2('F2_MODTRAD'	,SC5->C5_MODTRAD) //Motivo de Traslado - Guía de Remisión
				EndIf			
				If SF2->(ColumnPos("F2_VEICULO")) > 0 .And. SC5->(ColumnPos("C5_VEICULO")) > 0
					PutSF2('F2_VEICULO'	,SC5->C5_VEICULO) //Vehículo del traslado
				EndIf	
				If SF2->(ColumnPos("F2_PBRUTO")) > 0 .And. SC5->(ColumnPos("C5_PBRUTO")) > 0
					PutSF2('F2_PBRUTO'	,SC5->C5_PBRUTO) //Peso Bruto
				EndIf
				If SF2->(ColumnPos("F2_FECDSE")) > 0 .And. SC5->(ColumnPos("C5_FECDSE")) > 0
					PutSF2('F2_FECDSE'	,SC5->C5_FECDSE) //Fecha de inicio de traslado
				EndIf	
				If SF2->(ColumnPos("F2_UUIDREL")) > 0 .And. SC5->(ColumnPos("C5_UUIDREL")) > 0
					PutSF2('F2_UUIDREL'	,SC5->C5_UUIDREL) //Documentos relacionados
				EndIf	
				If SF2->(ColumnPos("F2_CLIENT")) > 0 .And. SC5->(ColumnPos("C5_CLIENT")) > 0
					PutSF2('F2_CLIENT'	,SC5->C5_CLIENT) //Documentos relacionados
				EndIf
				If SF2->(ColumnPos("F2_LOJENT")) > 0 .And. SC5->(ColumnPos("C5_LOJAENT")) > 0
					PutSF2('F2_LOJENT'	,SC5->C5_LOJAENT) //Documentos relacionados
				EndIf
				If SF2->(ColumnPos("F2_TPDOC")) > 0 .And. SC5->(ColumnPos("C5_TPDOC")) > 0
					If !Empty(SC5->C5_TPDOC)
						PutSF2('F2_TPDOC', SC5->C5_TPDOC)
					Else
						PutSF2('F2_TPDOC', "01")
					EndIf
				EndIf
			EndIf
			If cPaisLoc == "MEX"
				If SF2->(ColumnPos("F2_RELSAT")) > 0 .And. SC5->(ColumnPos("C5_RELSAT")) > 0
					PutSF2('F2_RELSAT'	,SC5->C5_RELSAT)
				EndIf
				If SF2->(ColumnPos("F2_USOCFDI")) > 0 .And. SC5->(ColumnPos("C5_USOCFDI")) > 0
					PutSF2('F2_USOCFDI'	,SC5->C5_USOCFDI)
				EndIf		
				If SF2->(ColumnPos("F2_UUIDREL")) > 0 .And. SC5->(ColumnPos("C5_UUIDREL")) > 0
					PutSF2('F2_UUIDREL'	,SC5->C5_UUIDREL)
				EndIf	
				If SF2->(ColumnPos("F2_TPCOMPL")) > 0
					PutSF2('F2_TPCOMPL','N')
				EndIf
				If SF2->(ColumnPos("F2_TPDOC")) > 0 .And. SC5->(ColumnPos("C5_TPDOC")) > 0
					PutSF2('F2_TPDOC'	,SC5->C5_TPDOC)
				EndIf
			EndIf
			If cPaisLoc == "ARG"
				If SF2->(ColumnPos("F2_TPVENT"))>0 .And. SC5->(ColumnPos("C5_TPVENT"))>0
					PutSF2('F2_TPVENT',  SC5->C5_TPVENT)
				EndIf	

				If SF2->(ColumnPos("F2_FECDSE"))>0 .And. SC5->(ColumnPos("C5_FECDSE"))>0
					PutSF2('F2_FECDSE',	 SC5->C5_FECDSE)
				EndIf

				If SF2->(ColumnPos("F2_FECHSE"))>0 .And.  SC5->(ColumnPos("C5_FECHSE"))>0
					PutSF2('F2_FECHSE', SC5->C5_FECHSE)				
				EndIf
	
			EndIf
			If cPaisLoc == "EQU"
				If SF2->(ColumnPos("F2_OBS")) > 0 .And. SC5->(ColumnPos("C5_MODTRAS")) > 0
					PutSF2('F2_OBS'	,SC5->C5_MODTRAS) //Motivo de Traslado - Guía de Remisión
				EndIf
				If SF2->(ColumnPos("F2_VEICULO")) > 0 .And. SC5->(ColumnPos("C5_VEICULO")) > 0
					PutSF2('F2_VEICULO'	,SC5->C5_VEICULO) //Vehículo del traslado - Guía de Remisión
				EndIf
				If SF2->(ColumnPos("F2_FECDSE")) > 0 .And. SC5->(ColumnPos("C5_FECDSE")) > 0
					PutSF2('F2_FECDSE'	,SC5->C5_FECDSE) //Fecha de inicio de traslado - Guía de Remisión
				EndIf
				If SF2->(ColumnPos("F2_RUTDOC")) > 0 .And. SC5->(ColumnPos("C5_RUTA")) > 0
					PutSF2('F2_RUTDOC'	,SC5->C5_RUTA) //Ruta Traslado - Guía de Remisión
				EndIf
				If SF2->(ColumnPos("F2_FECANTF")) > 0 .And. SC5->(ColumnPos("C5_FECENT")) > 0
					PutSF2('F2_FECANTF'	,SC5->C5_FECENT) //Fecha Entrega/Fin - Guía de Remisión
				EndIf
				If SF2->(ColumnPos("F2_TRANSP")) > 0 .And. SC5->(ColumnPos("C5_TRANSP")) > 0
					PutSF2('F2_TRANSP'	,SC5->C5_TRANSP) //Transportadora - Guía de Remisión
				EndIf
				If SF2->(ColumnPos("F2_NFAGREG")) > 0 .And. SC5->(ColumnPos("C5_NFSUBST")) > 0
					PutSF2('F2_NFAGREG'	,SC5->C5_NFSUBST) //Documento Sustento - Guía de Remisión
				EndIf
				If SF2->(ColumnPos("F2_SERMAN")) > 0 .And. SC5->(ColumnPos("C5_SERSUBS")) > 0
					PutSF2('F2_SERMAN'	,SC5->C5_SERSUBS) //Serie Documento Sustento - Guía de Remisión
				EndIf
			Endif
			// Se o pedido não utilizou a moeda 1 e a moeda do remito (F2_MOEDA) for igual a moeda 1
			If SC5->C5_MOEDA <> 1 .AND. (nTipoGer <> 1 .AND. nMoedSel == 1)		   
				
				If SF2->(Fieldpos("F2_REFTAXA")) > 0				
					PutSF2('F2_REFTAXA', 	SC5->C5_TXMOEDA)							
				EndIf
				
				If SF2->(Fieldpos("F2_REFMOED")) > 0
					PutSF2('F2_REFMOED',	SC5->C5_MOEDA)
				EndIf
			EndIf
	
			If SF2->(FieldPos("F2_RUTCLI")) > 0
				PutSF2('F2_RUTCLI',SA1->A1_CGC)
			EndIf
			
			If lFormLib
				PutSF2('F2_FORMLIB',"")
			EndIf
			nValAux:=GetSF2('F2_VALMERC',nPosRef)
			nValAux:=If(nValAux==Nil,0,nValAux)
			nValAux+=GetSD2("D2_TOTAL")
			PutSF2('F2_VALMERC'  ,nValAux)
			
			nValAux:=GetSF2('F2_DESCONT',nPosRef)
			nValAux:=If(nValAux==Nil,0,nValAux)
			nValAux+=GetSD2("D2_DESCON")
			IF cPaisLoc == "PAR" .and. SF2->(ColumnPos("F2_DESCONT"))>0  .and. SC5->(ColumnPos("C5_DESCONT"))>0  .and. SC5->C5_DESCONT >0 
				PutSF2('F2_DESCONT'  ,SC5->C5_DESCONT)
			Else
				PutSF2('F2_DESCONT'  ,nValAux)
			EndIf
			
			nValAux:=GetSF2('F2_DESCCAB',nPosRef)
			nValAux:=If(nValAux==Nil,0,nValAux)
			nValAux+=(nIndeniz*SC9->C9_QTDLIB)+(nC5Descont*SC9->C9_QTDLIB)
			PutSF2('F2_DESCCAB'  ,nValAux)
			
			//calcular os valores do frete, seguro e despesas 
			aGastos:={}
			aGastos:=a462ANGast(nPosRef,@aTotPes)
			PutSF2('F2_FRETE'    ,aGastos[1])
			PutSF2('F2_SEGURO'   ,aGastos[2])
			PutSF2('F2_DESPESA'  ,aGastos[3])
	
			If GetNewPar('MV_DESCSAI','1') == '2'
				PutSF2('F2_VALBRUT'  ,(GetSF2('F2_VALMERC',nPosRef)+aGastos[1]+aGastos[2]+aGastos[3])-GetSF2('F2_DESCONT',nPosRef))
			Else
				PutSF2('F2_VALBRUT'  ,(GetSF2('F2_VALMERC',nPosRef)+aGastos[1]+aGastos[2]+aGastos[3]))
	        EndIf

			//(14/07/18): VAT values
			If cPaisLoc == "RUS"
				PutSF2('F2_BASIMP1', nBasImp1)
				PutSF2('F2_VALIMP1', nValImp1)
				PutSF2('F2_BSIMP1M', xMoeda(nBasImp1,SC5->C5_MOEDA,1,dDtSaida,,nTxMoeda))
				PutSF2('F2_VLIMP1M', xMoeda(nValImp1,SC5->C5_MOEDA,1,dDtSaida,,nTxMoeda))
				PutSF2('F2_VLBRUTM', xMoeda(nGross1,SC5->C5_MOEDA,1,dDtSaida,,nTxMoeda))
				PutSF2('F2_VLMERCM', xMoeda(nNet1,SC5->C5_MOEDA,1,dDtSaida,,nTxMoeda)) 

				PutSF2('F2_CONUNI' 	, SC5->C5_CONUNI)
	   			PutSF2('F2_CNORVEN'	, SC5->C5_CNORVEN)
	   			PutSF2('F2_CNORCOD'	, SC5->C5_CNORCOD)
	   			PutSF2('F2_CNORBR' 	, SC5->C5_CNORBR)
	   			PutSF2('F2_CNEECLI' , SC5->C5_CNEECLI)
	   			PutSF2('F2_CNEECOD'	, SC5->C5_CNEECOD)
	   			PutSF2('F2_CNEEBR' 	, SC5->C5_CNEEBR)
			EndIf

			If SF2->(FieldPos("F2_LIQPROD")) > 0 .And. SC5->(FieldPos("C5_LIQPROD")) > 0
				PutSF2('F2_LIQPROD'	,SC5->C5_LIQPROD)
			Endif

			PutSD2('D2_TIPOREM'  ,SC5->C5_TIPOREM)
			PutSD2('D2_IDENTB6'	,SC9->C9_IDENTB6)
			PutSD2('D2_LOTECTL'	,SC9->C9_LOTECTL)
			PutSD2('D2_NUMLOTE' ,If(Rastro(SC9->C9_PRODUTO,"L"),"",SC9->C9_NUMLOTE))
			PutSD2('D2_DTVALID'  ,SC9->C9_DTVALID)
			PutSD2('D2_EDTPMS'	,SC9->C9_EDTPMS)
			PutSD2('D2_PROJPMS'  ,SC9->C9_PROJPMS)
			PutSD2('D2_TASKPMS'  ,SC9->C9_TASKPMS)

			//Pregunta de punto de venta.
			If cPaisLoc == "ARG" .and. IsInCallStack("MATA410") .and. lRetPV .and. PROCNAME(1)<> "MA410PVNFS"
			    nAux := MV_PAR01
			 	If !Pergunte("PVXARG", .T.)
					Return .F.
				Endif
				cLocxNFPV := MV_PAR01
				cIdPVArg := POSICIONE("CFH", 1, xFilial("CFH") + cLocxNFPV, "CFH_IDPV")
				If !F083ExtSFP(MV_PAR01, .T.)
					Return .F.
				EndIf
				MV_PAR01 := nAux
			EndIf
			If cPaisLoc == "ARG" .and. SF2->(Fieldpos("F2_PV")) > 0	.and. alltrim(cLocxNFPV) <> "" 
				PutSF2('F2_PV'	,cLocxNFPV)
			EndIf
			lRetPV:= .F.
	    EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄX¿
	//³Se for Automatico so pulo para o proximo registro indicado no array aRecSC9,³
	//³senao, fazo um DbSkip no arquivo de trabalho.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄXÙ
	If !lAtm
		DbSelectArea('TRB')
		dbSkip()
		DbSelectArea('SC9')
		DbGoTo(TRB->RECNO)
	Else
		DbSelectArea('SC9')
		If ++nSC9 <=	Len(aRecSC9)
			SC9->(DbGoTo(aRecSC9[nSC9]))
		Else
			Exit
		Endif
	Endif
	DbSelectArea('SC9')
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravação dos remitos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1	To Len(aSF2)
	
	aCols	:=	aClone(aSD2[nX])
	aPergs:=	{.F.,lGeraLanc,lDigita,lAglutina,.T.}	                         
	If GetSF2("F2_TIPO",nX)=="B"
	    SA2->(DbSetOrder(1))
	    SA2->(MsSeek(xFilial()+aSF2[nX][Ascan(aHeadSF2,{|x| Alltrim(x)=="F2_CLIENTE"})]+aSF2[nX][Ascan(aHeadSF2,{|x| Alltrim(x)=="F2_LOJA"})]))
	Else
	    SA1->(DbSetOrder(1))
	    SA1->(MsSeek(xFilial()+aSF2[nX][Ascan(aHeadSF2,{|x| Alltrim(x)=="F2_CLIENTE"})]+aSF2[nX][Ascan(aHeadSF2,{|x| Alltrim(x)=="F2_LOJA"})]))
	Endif		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega o proximo numero do SX5³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case cPaisLoc == "CHI"	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Release 11.5 - Chile - F2CHI                   ³
			//³Utilizar numeracao do controle de formularios  ³
			//³com especie do tipo GDP (GUIA DE DESPACHO)     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRemLoc				
				aNum:=	a462NumGdp()
			Else
				aNum:=	PegaNum()		
			Endif
		Otherwise
			aNum	:=	PegaNum()
	EndCase	
	lRetGravacao	:=	.F.
	If !Empty(aNum[2])
		aSF2[nX][Ascan(aHeadSF2,{|x| Alltrim(x)=="F2_SERIE"})]	:=	aNum[1]
		aSF2[nX][Ascan(aHeadSF2,{|x| Alltrim(x)=="F2_DOC"  })]	:=	aNum[2]

		//Ajuste para permitir la inclusión de títulos provisionales de remito
		If cPaisLoc == "EUA"
			aSF2[nX][Ascan(aHeadSF2,{|x| Alltrim(x)=="F2_PREFIXO"})] := aSF2[nX][Ascan(aHeadSF2,{|x| Alltrim(x)=="F2_SERIE"})]
		EndIf

		If cPaisLoc $ "PER|PAR" .AND. SF2->(ColumnPos("F2_SERIE2")) > 0
			DbSelectArea("SFP")  
			SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
			If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+aNum[1]+'6'))
				If cPaisLoc == "PAR"
			    	PutSF2('F2_SERIE2'	,SFP->FP_SERIE2)
			    	If SF2->(ColumnPos("F2_NUMTIM")) > 0 
			    		PutSF2('F2_NUMTIM'	,SFP->FP_CAI)
         			EndIf
			    Else
			    	If !Empty(SFP->FP_SERIE2)
			    		PutSF2('F2_SERIE2'	,SFP->FP_SERIE2)
			    	Else
			    		Aviso(STR0007,STR0101,{"OK"})// "No se encontró registro de Serie en Control de Formularios. Serie 2 quedará vacío. "		    		
			    	EndIf
			    EndIf
		    Else
		    	If cPaisLoc <> "PAR"
		    		Aviso(STR0007,STR0101,{"OK"})	 // "No se encontró registro de Serie en Control de Formularios. Serie 2 quedará vacío. "
		    	EndIf
		   	EndIf 			
		EndIf
		if cPaisLoc $ "EQU" .And. lValCp
			If SF2->(ColumnPos("F2_ESTABL")) > 0 .And. SF2->(ColumnPos("F2_PTOEMIS")) > 0
				aDatosSFP := M462GETSFP(CFILANT,aNum[1],'6')
				If !Empty(aDatosSFP[1]) .And.!Empty(aDatosSFP[2])
					PutSF2('F2_ESTABL'	,aDatosSFP[1])
					PutSF2('F2_PTOEMIS'	,aDatosSFP[2])
				Elseif !Empty(cProvFE) .And. cProvFE == "STUPENDO"
					Aviso(STR0007,STR0102,{"OK"})
					lGenera := .F.
				EndIf
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para permitir alteração dos arrays que³
		//³contem os dados a serem gravados.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If ExistBlock("M462GRV")
   			ExecBlock("M462GRV",.F.,.F.,{aHeadSF2,aSF2,aHeader,aCols,aNum,aPergs,nX})
   		EndIf		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava o remito³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFormLib
			cFormLib:=PesqForm()
			lAchouf3l:= VldFormL(cFormLib)
			If lAchouf3l
				aSF2[nX][Ascan(aHeadSF2,{|x| Alltrim(x)=="F2_FORMLIB"  })]	:=	cFormLib
			Else
				lGenera:=.F.
			EndIf
		EndIf
		
		If lGenera
			If !lAtm
			  If !lAutomato
				MsAguarde( {|| MsProcTxt(OemToAnsi(STR0078)+aNum[1]+"/"+aNum[2]),lRetGravacao := GravaNfGeral({aHeadSF2,aSF2[nX]},aCols,HeaderCpos(),IIf(GetSF2("F2_TIPO",nX)=="B",52,50),aClone(aPergs),,.F.,,,,aNum[2])},OemToAnsi(STR0079)) // "Gravando documento" , "Gravando registros..."
		      Else // Ingresa cuando viene por script de automatización
			    lRetGravacao := GravaNfGeral({aHeadSF2,aSF2[nX]},aCols,HeaderCpos(),IIf(GetSF2("F2_TIPO",nX)=="B",52,50),aClone(aPergs),,.F.,,,,aNum[2])
			  Endif
			Else	
				lRetGravacao := GravaNfGeral({aHeadSF2,aSF2[nX]},aCols,HeaderCpos(),IIf(GetSF2("F2_TIPO",nX)=="B",52,50),aClone(aPergs),,.F.,,,,aNum[2])
			EndIf	
	
		   	If lRetGravacao                      
		   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chamada para integracao com o modulo ACD		  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lIntACD .And. FindFunction("CBMSD2460")
					CBMSD2460()
				EndIf
				If lFormLib
					ATuTabFL(cFormLib)
				EndIf
		   		AAdd(aRems,aClone(aNum))
				
				//Ajuste para permitir la inclusión de títulos provisionales de Remito
				If cPaisLoc == "EUA" .And. FindFunction("MATA476FIN")
					MATA476FIN()
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Destravar os registros do SC9 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nY	:=	1	To Len(aSC9[nX])
					If lAtm
						SC9->(DbGoTo(aSC9[nX][nY]))
						If RecLock("SC9",.F.)
							DbSelectArea('SC9')
							Replace C9_OK With "  "
							MsUnLock()
						Endif
					Else
						TRB->(DbGoTo(aSC9[nX][nY]))
						a462NMrk(Nil,.T.)
					Endif                
				Next
				//Metrica numero de items por remito
				If LibMt462an()
					cIdMetric   := "faturamento-protheus_media-itenes-remito-pedido_average"
					cSubRutina  := "mata462an-media-items"
					If lAutomato
						cSubRutina  += "-auto"
					EndIf
					FWCustomMetrics():setAverageMetric(cSubRutina, cIdMetric, Len(aCols), /*dDateSend*/, /*nLapTime*/,"MATA462AN")
				EndIf
			Endif
		EndIf	
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para manipulacao dos remitos apos a   ³
//³gravacao.                                              ³
//³Parametros: aRems                                      ³
//³            Array com as serie e numeros dos remitos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("M462FIM")
        ExecBlock("M462FIM",.F.,.F.,{aRems})
EndIf		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for automático nao existe arquivo de trabalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAtm
	DbSelectArea('TRB')
	DbSetOrder( nOrder )
	dbGoTop()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ For‡ar o array aRotina para dribar a funcao ExecBrow. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRotina[2][4] := 1
	
	//Verifica se houve algum Pedido que não foi gerado devido a falta de permissão pelo campo C5_CATPV
	If Len(aSemPermiss) > 0
		For nI = 1 To Len(aSemPermiss)
			cSemPermiss += aSemPermiss[nI]
			If nI < Len(aSemPermiss)
				cSemPermiss += ", "
			EndIf
		Next
		Alert(STR0089 + " (" + cSemPermiss + ") " + STR0090)//"Os Remitos {" + cSemPermiss + "} não puderam ser gerados porque esse usuário não tem permissão para gerar remitos com esse tipo."
	EndIf
Endif

Return aClone(aRems)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PegaNum     ³ Autor ³ Bruno Sobieski     ³ Data ³ 10.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pega o numero do remito de vendas.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MatARem                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function PegaNum()
Local cSerie      := Iif(FindFunction("U_M462SER"),ExecBlock("M462SER",.F.,.F.),"R  ")
Local cNumero
Local aRet	      :=	{Nil,Nil}
Local aRetGuiaT   := {Nil,Nil}  // Apenas para PTG
Local lGuiaT   := .T.
Local lSeqEspecie := SuperGetMV("MV_SEQESPE",,.F.)
Local cTabela     := IIf(lSeqEspecie,"AC","01")
Local cChaveSX5   := ""
Local aAreaG		:= GetArea()
Local lSFP 		:= .F.
Local nConse		:= 0
Private lVldForm := .f.
//Declara variable si no existe.
lLocxAuto  := IIf(Type("lLocxAuto") != "U", lLocxAuto, .F.)
	
	//Busca pelo tipo 2(Nota de Remissao) - Loc. El Salvador
	If cPaisLoc == "SAL"
	   If DbSeek( xFilial("SX5")+"01"+"2",.T.)   
	      cSerie  := SX5->X5_CHAVE   
	   EndIf
ElseIf cPaisLoc == "PTG"
    //aRetGuiaT := SerGuiaT()  Funciones no Compiladas en RPO
    cSerie := aRetGuiaT[1]
    lGuiaT := aRetGuiaT[2]
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Chama rotina para validar se a serie se refere ao processo de capacitacao e se esta ok para uso ³
    //³de acordo com a filial logada.                                                                  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
    If !lGuiaT 
        aRet := {Nil,Nil}   
        Return aRet
	EndIf
EndIf
If cPaisLoc ==  "ARG" 
	DBSELECTAREA("SFP")
	SFP->(DbSetOrder(RetOrder("SFP", "FP_FILIAL+FP_PV")))
	IF dbSeek(xFilial("SFP") + cLocxNFPV,.F.)
		While !EOF() .AND. SFP->FP_FILIAL == xFilial("SFP") .AND. SFP->FP_PV == cLocxNFPV .AND. !lSFP
			If "6" == SFP->FP_ESPECIE 
				nConse	:= SFP->FP_NUMINI
				cSerie := SFP->FP_SERIE
				lSFP := .T.				
			EndIf 
			SFP->(dbskip())
		Enddo
	EndIf
EndIf
RestArea(aAreaG) 
cChaveSX5   := IIf(lSeqEspecie,cEspecDoc+cSerie,cSerie)
	DbSelectArea("SX5")
	DbSetOrder(1)
If DbSeek( xFilial("SX5")+cTabela+ alltrim(cChaveSX5)+ Iif(cPaisLoc=="ARG",cIdPVArg,""),.F. ) .or. lSFP
	   
	   cNumero := Padr(LocConvNota(IIf(cPaisLoc == "RUS", SX5->X5_DESCRI, X5Descri())),TamSX3('F2_DOC')[1])
	   
	   If cPaisLoc == "ARG" .AND. FunName() <> "MATA460B" 
	      cNumero := cLocxNFPV + SubStr(cNumero, TamSX3("FP_PV")[1]+1 , TamSX3('F2_DOC')[1]-TamSX3("FP_PV")[1] )
      If !DbSeek( xFilial("SX5")+cTabela+alltrim(cChaveSX5)+cIdPVArg,.F. )
			cNumero := LocConvNota(nConse-1,TamSX3('F2_DOC')[1])
	      EndIf
      If ChkFolARG( SubStr(cNumEmp, Len(FWGrpCompany()) + 1, TamSX3("FP_FILUSO")[1]), cSerie, cNumero, ,lLocxAuto, cEspecDoc, cLocxNFPV)
         aRet	:=	{cSerie,cNumero}
	   EndIf	
	Else
      aRet	:=	{cSerie,cNumero}
    If (cPaisLoc == "PTG") .and. !VldCtrForm(cSerie,cEspecDoc,@cNumero,1)
        aRet := {Nil,Nil}
    Else
        aRet := {cSerie,cNumero} 
	Endif

   EndIf
Else
	If cPaisLoc == "ARG"
		Aviso(STR0007,STR0100 + ' "'+cLocxNFPV+'"',{"OK"})
	Else
		Aviso(STR0007,STR0099 + ' "'+cSerie+'"',{"OK"})
	EndIf
Endif
lSFP := .F.
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ x462Filial³ Autor ³ Ivan PC		       	 ³ Data ³ 21/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar a Filial de SC9 para tratamento da MarkBrowse	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA462AN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function x462ANFilial()
Return( xFilial("SC9") )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A462ANPesq³ Autor ³ Lucas                 ³ Data ³ 09.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Pesquisar Pedidos a Remitir...               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A462ANPesq(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA462AN                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function A462ANPesq(cAlias,nReg,nOpcx)

	Local oDlg		:= Nil
	Local nOpca		:= 0
	Local bSav12	:= SetKey(VK_F12)
	Local cCampo	:= ""
	Local cOrd		:= ""
	Local oCbx		:= Nil
	Local nOpt1		:= 0
	Local nI		:= 0
	Local aStruct	:= {}
	Local aAreaTRB	:= GetArea()
	
	cAlias := Alias()
	
	SetKey( VK_F12, {||nil} )
	
	cOrd := aOrd[2]
	cCampo:=SPACE(40)
	
	For ni:=1 to Len(aOrd)
		aOrd[nI] := OemToAnsi(aOrd[nI])
	Next
	
	If IndexOrd() >= Len(aOrd)
		cOrd := aOrd[Len(aOrd)]
		nOpt1 := Len(aOrd)
	ElseIf IndexOrd() <= 1
		cOrd := aOrd[1]
		nOpt1 := 1
	Else
		nOpt1 := IndexOrd()
		cOrd := aOrd[nOpt1]
	EndIf
	
	DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 50 TITLE OemToAnsi(STR0001) //"Buscar"
	@ 0.6,1.3 COMBOBOX oCBX VAR cOrd ITEMS aOrd  SIZE 165,44  ON CHANGE (nOpt1:=oCbx:nAt)  OF oDlg FONT oDlg:oFont
	@ 2.1,1.3	MSGET cCampo SIZE 165,10
	DEFINE SBUTTON FROM 055,122	TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 055,149.1 TYPE 2 ACTION (DbSelectArea(cAlias),oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpca == 0
		SetKey(VK_F12,bSav12)
		Return 0
	EndIf
	
	dbSelectArea(cAlias)
	nReg := RecNo()
	dbSetOrder( nOpt1)
	dbSeek(xFilial("SC9")+Alltrim(cCampo),.T.)
	If ! Found()
		dbGoto( nReg )
		Help(" ",1,"PESQ01")
	EndIf
	lRefresh := .t.
	SetKey(VK_F12,bSav12)
	dbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a462nMrkAll  ºAutor  ³Gilson da Silva  ºFecha ³  08/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de marca Tudo definida aqui para usar a a486aMark    º±±
±±º          ³ e tratar os locks do SC9                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a462nMrkAll()
Local nRecno	:=	0

DbSelectArea("TRB")
ProcRegua(Reccount())
nRecno	:=	Recno()
DbGoTop()

While !EOF()
	IncProc()
	a462nMrk(.T.)
	DbSelectArea("TRB")
	DbSkip()
Enddo
DbGoTo(nRecno)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a462nMark ºAutor  ³Gilson da Silva     ºFecha ³  08/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de marca da MarkBrowse, definida aqui para tratar os º±±
±±º          ³ locks do SC9     a efeitos ad concorrencia de processos.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a462nMrk(lAll,lAtu)
Local lRet     :=  .F.
Local nX       :=  0
Local nPosLock := 0
Local cMsg     :=  OemToAnsi(STR0036)//"El pedido esta en uso y no puede ser marcado en este momento"
Local lShwHlp  :=  .F.      
Local lM462Mrk := ExistBlock("M462MARKB")
Local lContinua := .T.

DEFAULT lAll :=  .F.
DEFAULT lAtu :=  .F.

lShwHlp := !lAll

If lM462Mrk
    If ValType( lContinua := ExecBlock("M462MARKB",.F.,.F.) ) <> "L"
        lContinua := .T.
    EndIf
EndIf

If lContinua

    DbSelectArea("SC9")
    
	//Este DbSkip é para garantir a re-leitura do registro no TOP
    DbSkip()
    dbGoto(TRB->RECNO)
    If C9_OK == cMarca
		RecLock("SC9",.F.)
		Replace C9_OK 	 		With "  "
		If (!Empty(C9_NFISCAL) .Or. !Empty(C9_REMITO))
			Replace C9_BLCRED 	 	With "10"
			Replace C9_BLEST 	 	With "10"
		Endif
		MsUnLock()
		nPosLock	:=	Ascan(aListRlock,SC9->(Recno()))
		If (nPosLock > 0)
			Adel(aListRlock,nPosLock)
		EndIf
		aSize(aListRlock,Len(aListRlock)-1)
		RecLock("TRB",.F.)
		Replace TRB->C9_OK		With "  "
		If lAtu
			Replace TRB->C9_NFISCAL	With SC9->C9_NFISCAL
			Replace TRB->C9_BLCRED	With SC9->C9_BLCRED
			Replace TRB->C9_BLEST	With SC9->C9_BLEST
			Replace TRB->C9_REMITO	With SC9->C9_REMITO
			Replace TRB->C9_SERIREM With SC9->C9_SERIREM
			Replace TRB->C9_ITEMREM With SC9->C9_ITEMREM
			Replace TRB->C9_DTREMIT With SC9->C9_DTREMIT
		Endif
		MsUnlock()
		lRet:= .T.
    Else
        For nX	:=	0	To 1 STEP 0.2
            If Empty(C9_NFISCAL+C9_BLEST+C9_BLCRED+C9_REMITO)
                If C9_OK <> cMarca .And. RecLock("SC9",.F.)
                    AAdd(aListRlock,SC9->(Recno()))
                    Replace C9_OK 		With cMarca
					SC9->(MsUnlock())
                    RecLock("TRB",.F.)
                    Replace TRB->C9_OK 	With cMarca
                    TRB->(MsUnlock())
                    nX := 1
                    lRet:=	.T.
                Else
                    Inkey(0.2)
                Endif
            Else
			//Atualizar o TRB para o usuario perceber porque o PEDIDO nao pode ser marcado
                RecLock("TRB",.F.)
                Replace TRB->C9_NFISCAL	With SC9->C9_NFISCAL
                Replace TRB->C9_BLCRED	With SC9->C9_BLCRED
                Replace TRB->C9_BLEST	With SC9->C9_BLEST
                Replace TRB->C9_REMITO	With SC9->C9_REMITO
                Replace TRB->C9_SERIREM With SC9->C9_SERIREM
                Replace TRB->C9_ITEMREM With SC9->C9_ITEMREM
                Replace TRB->C9_DTREMIT With SC9->C9_DTREMIT
                MsUnlock()
                lShwHlp	:=	.F.
                Exit
            Endif
        Next
	
    EndIf

    If !lRet.And.lShwHlp
    	MsgAlert(cMsg)
    Endif

EndIf


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraTRB    ³ Autor ³ Gilson                ³ Data ³ 14/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria temporario a partir dos parametros escolhidos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA462AN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION GERATRB(aCpos)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cQuery :=""
Local aStruTRB := {}
Local nj := 0
Local nI := 0
Local nPedIni 	:=	0, nPedFim := 0, nPosCpo := 0, nCount := 0
Local lQuery	:=	.F.
Local cCondicao:= ''
Local cUserCond:= ''
Local lM462AN	:=	ExistBlock('M462NFLT')
Local aIndx	:= {}
Local aInd	:= {}
Local lM462Cpos	:= ExistBlock('M462CPOS')
Local aCamposPE	:= {}
Local aCamposV	:= {}
Local cCamposV	:= ""

lFiltra  := If( mv_par01==1,.T.,.F. )  // Filtra ja emitida
lInverte := If( mv_par02==1,.T.,.F. )  // Traz os pedidos marcados

If Select("TRB") <> 0
	dbSelectArea("TRB")
	dbCloseArea()
EndIf

dbSelectArea("SC9")
dbSetOrder(1)

cMarca := GetMark(,'SC9','C9_OK')

If lM462Cpos
	// PE para configurar campos virtuales a mostrar en el browse principal
	If Valtype(aCamposPE := ExecBlock("M462CPOS",.F.,.F.)) == "A"
		cCamposV := SX3Virtual(aCamposPE, aCamposV)
	Endif
EndIf

#IFDEF TOP
	If TcSrvType() != "AS/400"
		lQuery	:=	.T.
		dbSelectArea("SC9")
		aStruTRB:= DbStruct()

		cQuery:="SELECT  "
		For nj:=1 To Len(aStruTRB)
			cQuery += aStruTRB[nj][1]+","
		Next

		Aadd(aStruTRB,{"RECNO","N",10,0})
		
		If Valtype(aCamposV) == "A" .And. Len(aCamposV) > 0
			For nj := 1 To Len(aCamposV)
				aAdd(aStruTRB , {aCamposV[nj,1], aCamposV[nj,2], aCamposV[nj,3], aCamposV[nj,4]})
			Next
		EndIf
		
		oTmpTable := FWTemporaryTable():New("TRB") // mc
		oTmpTable:SetFields(aStruTRB) //MC	

		DbSelectArea("SIX")
		DbSetOrder(1)
		DbSeek("SC9")
		Do While SIX->(!Eof()) .AND. SIX->INDICE=="SC9"
			Aadd(aVar,SubStr(CriaTrab(Nil,.F.),1,7)+AllTrim(SIX->ORDEM))
			cChave := SIX->CHAVE
			aInd := strTokArr(ALLTRIM(cChave),"+")
			aAdd(aIndx,aInd)
			aAdd(aOrd,SIX->DESCRICAO)
			DbSkip()
		EndDo

		For nI := 1 To len(aIndx) //Len(aVar)
			oTmpTable:AddIndex("IN" + ALLTRIM(STR(nI)), aIndx[nI]) //MC
		Next nI
		oTmpTable:Create() //MC

		cQuery += "SC9.R_E_C_N_O_ RECNO"
		cQuery += "  FROM "+	RetSqlName("SC9") + " SC9 ,"+RetSqlName("SC5") + " SC5 "
		cQuery += "  WHERE C9_PEDIDO BETWEEN '"+mv_par03+"' And '"+mv_par04+"'"
		cQuery += "	  	AND C9_CLIENTE BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
		cQuery += "	  	AND C9_LOJA BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'"
		cQuery += "	  	AND C9_REMITO ='"+Space(Len(C9_REMITO))+"'"
		cQuery += " 	AND C9_FILIAL ='"+xFilial("SC9")+"' "
		cQuery += " 	AND C5_FILIAL ='"+xFilial("SC5")+"' "
		cQuery += " 	AND C9_PEDIDO = C5_NUM "
		cQuery+=  " AND (C5_DOCGER = '2' OR C5_DOCGER = ' ')"
		If lFiltra
			cQuery += " AND C9_BLEST ='"+Space(Len(C9_BLEST))+"'"
			cQuery += " AND C9_BLCRED = '"+Space(Len(C9_BLCRED))+"'"
		EndIf
		If lM462AN	
			cUserCond	:=	ExecBlock('M462NFLT',.F.,.F.,cQuery)
		Endif
		If !Empty(cUserCond)
			cQuery		+=	" AND ("+ cUserCond +")"
		Endif
		cQuery+= "   AND SC9.D_E_L_E_T_ <> '*' "
		cQuery+= "   AND SC5.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY "+ SqlOrder(SC9->(IndexKey()))

		Sql2Trb(cQuery, aStruTRB, 'TRB', aCamposV, cCamposV)

		If lInverte
			DbSelectArea("TRB")
			DbGoTop()
			While !EOF()
				DbSelectArea("SC9")
				DbGoto(TRB->RECNO)
				If RecLock("SC9",.F.)
					AAdd(aListRLock,SC9->(Recno()))
					Replace C9_OK    WITH cMarca
					RecLock("TRB",.F.)
					Replace C9_OK    WITH cMarca
					MsUnLock()
				Endif
				DbSelectArea("TRB")
				DbSkip()
			Enddo
		EndIf
		dbSelectArea("TRB")
		DbSetOrder(2)
		nIndex := IndexOrd()
		dbGoTop()
	EndIf
#ENDIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no Arquivo Temporario         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BOF() .and. EOF()
		DbSelectArea("TRB")
		cMsg := OemToAnsi(STR0075)
		MsgStop( cMsg )
		Return .F.
	EndIf

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SC9")
	aCpos	:=	{}
	Aadd(aCpos,{"C9_OK"," "," "})
	While !EOF() .And. X3_ARQUIVO=="SC9"
		If X3uso(X3_USADO) .And. cNivel >= X3_NIVEL .And. X3_BROWSE=="S" .And. X3_CAMPO != "C9_OK" .And. (X3_CONTEXT <> "V" .Or. Trim(X3_CAMPO) $ cCamposV)
			AAdd(aCpos,{X3_CAMPO," ",Trim(X3Titulo()),X3_PICTURE})
		Endif
		DbSkip()
	Enddo
	IF cPaisLoc == "ARG"
		DbSelectArea("TRB")
		DbSetOrder(1)
		nIndex := IndexOrd()
		DbGoTop()
	Else
		DbSelectArea("TRB")
		DbSetOrder(2)
		nIndex := IndexOrd()
		DbGoTop()
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PutSD2    ºAutor  ³Bruno Sobieski      ºFecha ³  07/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava o conteudo do xValor no array de referencia do SD2    º±±
±±º          ³dependendo co campo cCpo                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PutSD2(cCpo,xValor)
	
aSD2[nPosRef][nItemAtu][AScan(aHeader,{|x| Alltrim(x[2])==cCpo})]	:=	xValor	

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PutSF2    ºAutor  ³Bruno Sobieski      ºFecha ³  07/08/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava o conteudo do xValor no array de referencia do SF2    º±±
±±º          ³dependendo co campo cCpo                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PutSF2(cCpo,xValor)
	
aSF2[nPosRef][AScan(aHeadSF2,{|x| Alltrim(x)==cCpo})]	:=	xValor	

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³GetSD2      ºAutor  ³Bruno Sobieski    º Date ³  24.06.02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega o valor de um campo no array aSD2.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ MATA462N                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetSD2(cCampo)
Local xRet	
If aSD2 <> Nil
	xRet	:=	aSD2[nPosRef][nItemAtu][AScan(aHeader,{|x| Alltrim(x[2])==cCampo})]
Else
	xRet	:=	Criavar(cCampo)
Endif
Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³GetSF2      ºAutor  ³Bruno Sobieski    º Date ³  24.06.02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega o valor de um campo no array aSF2.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUse       ³ MATA462AN                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetSF2(cCampo,nPos)
Local xRet
If aSF2 <> Nil
	xRet	:=	aSF2[nPos][AScan(aHeadSF2,{|x| Alltrim(x)==cCampo})]
Else
	xRet	:=	Criavar(cCampo)
Endif
Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A462ANGASTºAutor  ³Microsiga           ºFecha ³  30/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o valor do frete, seguro, gastos para o pedido      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA462AN                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a462anGast(nPos,aTotais)

	Local aRet		:= {}
	Local cRat		:= ""
	Local nRat		:= 0
	
	aRet:={GetSF2("F2_FRETE",nPos),GetSF2("F2_SEGURO",nPos),GetSF2("F2_DESPESA",nPos)}
	For nRat:=1 To Len(aRet)
		aRet[nRat]:=If(aRet[nRat]==Nil,0,aRet[nRat])
	Next
	If SC5->C5_FRETE>0 .Or. SC5->C5_SEGURO>0 .Or. SC5->C5_DESPESA>0
		cRat:=Upper(GetNewPar("MV_RATDESP","FR=1;DESP=1;SEG=1"))
		nPosPed:=Ascan(aTotais,{|x| x[1]==SC5->C5_NUM})
		SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		//frete
		If cPaisLoc == "PER"
			If SC5->C5_FRETE>0
				nRat:=Val(Substr(cRat,AT("FR=",cRat)+3,1))
				If nRat==1  //valor
					aRet[1]+=(SC5->C5_FRETE * (SC9->C9_QTDLIB*SC6->C6_PRCVEN/aTotais[nPosPed][2]))
				Else
					aRet[1]+=(SC5->C5_FRETE * (SC9->C9_QTDLIB*SB1->B1_PESO/aTotais[nPosPed][3]))
				Endif
			Endif
		Else     
			If SC5->C5_FRETE>0 .And. SC5->C5_TPFRETE=="F"
				nRat:=Val(Substr(cRat,AT("FR=",cRat)+3,1))
				If nRat==1  //valor
					aRet[1]+=(SC5->C5_FRETE * (SC9->C9_QTDLIB*SC6->C6_PRCVEN/aTotais[nPosPed][2]))
				Else
					aRet[1]+=(SC5->C5_FRETE * (SC9->C9_QTDLIB*SB1->B1_PESO/aTotais[nPosPed][3]))
				Endif
			Endif	
	    Endif
		//seguro
		If SC5->C5_SEGURO>0
			nRat:=Val(Substr(cRat,AT("SEG=",cRat)+4,1))
			If nRat==1  //valor
				aRet[2]+=(SC5->C5_SEGURO * (SC9->C9_QTDLIB*SC6->C6_PRCVEN/aTotais[nPosPed][2]))
			Else
				aRet[2]+=(SC5->C5_SEGURO * (SC9->C9_QTDLIB*SB1->B1_PESO/aTotais[nPosPed][3]))
			Endif
		endif
		//gastos
		If SC5->C5_DESPESA>0
			nRat:=Val(Substr(cRat,AT("DESP=",cRat)+5,1))
			If nRat==1  //valor
				aRet[3]+=(SC5->C5_DESPESA * (SC9->C9_QTDLIB*SC6->C6_PRCVEN/aTotais[nPosPed][2]))
			Else
				aRet[3]+=(SC5->C5_DESPESA * (SC9->C9_QTDLIB*SB1->B1_PESO/aTotais[nPosPed][3]))
			Endif
		endif
	endif
	
Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a462anTopeºAutor  ³Microsiga           ºFecha ³  30/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o peso total e o valor total de um pedido,          º±±
±±º          ³retornando o valor no parametro aTotais passado por refer.  º±±
±±º          ³1a posicao = pedido                                         º±±
±±º          ³2a posicao = valor total                                    º±±
±±º          ³3a posicao = peso total                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA462AN                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a462anToPe(cPedido,aTotais,aTotaFat)		
Local cFilSC6 	:= xFilial("SC6")
Local nPos 		:= 0
Local nPos2		:= 0
Local cTpdpind	:= GetNewPar("MV_TPDPIND","1")

nPos:=Ascan(aTotais,{|x| x[1]==cPedido})
If nPos==0
	Aadd(aTotais,{cPedido,0,0})
	nPos:=Len(aTotais)
	SC6->(dbSetOrder(1))
	SC6->(MsSeek(cFilSC6+cPedido))
	While SC6->C6_NUM==cPedido .And. SC6->C6_FILIAL==cFilSC6
		aTotais[nPos][2]+=SC6->C6_QTDVEN*SC6->C6_PRCVEN		
		SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		aTotais[nPos][3]+=SC6->C6_QTDVEN*SB1->B1_PESO
		// Calcula total do pedido para rateio do campo C5_DESCONT
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+SC6->C6_TES))
		If (cTpdpind == "2" .And. SF4->F4_DUPLIC=="S") .Or. (cTpdpind == "1")
			nPos2 := AScan(aTotaFat,{|x| x[1] == SC6->C6_NUM })
			If nPos2 > 0
				aTotaFat[nPos2,2] += SC6->C6_QTDVEN*SC6->C6_PRCVEN
			Else
				AADD(aTotaFat,{SC9->C9_PEDIDO,SC6->C6_QTDVEN*SC6->C6_PRCVEN})
			EndIf
		EndIf
		SC6->(DbSkip())
	Enddo
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a462ANDivid ³ Autor ³ Kleber Dias Gomes  ³ Data ³ 12/04/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Dividir a quantidade a faturar.                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³  ExpL1 - .T. para marcar os registros SC9 apos a Divisao   ³±±
±±³          ³ (Default).F. para nao marcar os registros SC9 apos Divisao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Uso       ³ MATA462AN                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a462ANDivid(lMarcar)

Local aArea     := GetArea()
Local aAreaTRB  := TRB->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local cCadDivSc9:= 0
Local cRetCGC   := ""
Local cProvincia:= ""
Local cSujFiscal:= ""
Local nQtdeLib  := 0
Local nQtdeOrig := 0
Local nPrecTotal:= 0
Local nOpca     := 0                        
Local cCodLiber := ""  //Codigo de Liberacao Loc. Colombia     
Local aRetPE    := {}
Default lMarcar := .F. //Define se deve marcar no Markbrowse quando houver divisao do SC9. Loc. Colombia.
a462SetOp(0) //Inicializa nOpcao com 0 para recuperar quando a funcao for chamada por A462ANGera

dbSelectArea("TRB")
SC9->(DbGoTo(TRB->RECNO))

If IsMark("C9_OK") .And. Empty(TRB->C9_BLEST+TRB->C9_BLCRED+TRB->C9_REMITO)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar o arquivo de Remitos a partir de SC9.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC5")
	dbSetOrder(1)
	MsSeek( xFilial("SC5")+ SC9->C9_PEDIDO )

	nQtdeOrig := TRB->C9_QTDLIB
	nQtdeLib  := nQtdeOrig
	nPrecTotal:= TRB->C9_PRCVEN  * nQtdeLib
	cCadDivSc9:= STR0093 + " " + GetDescRem() //"Seleccione cantidad por generar remito" ou "Seleccione cantidad por generar factura"

	If SC5->C5_TIPO$"DB"
		SA2->( MsSeek(xFilial("SA2")+TRB->C9_CLIENTE+TRB->C9_LOJA) )
		cRetCGC   := RetTitle("A2_CGC")
	Else
		SA1->( MsSeek(xFilial("SA1")+TRB->C9_CLIENTE+TRB->C9_LOJA) )
		cRetCGC   := RetTitle("A1_CGC")
	Endif

	SX5->( MsSeek(xFilial("SX5")+"SF"+If(SC5->C5_TIPO$"DB",SA2->A2_TIPO,SA1->A1_TIPO)) )
	cSujFiscal := X5Descri()
	
	SX5->( MsSeek(xFilial("SX5")+"12"+If(SC5->C5_TIPO$"DB",SA2->A2_EST,SA1->A1_EST)) )
	cProvincia := X5Descri()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para permitir utilizar tela especifica³
	//³para a selecao parcial de de produtos a remeter        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M462SLP")
		aRetPE  := ExecBlock("M462SLP",.F.,.F.,{nOpca,nQtdeOrig,nQtdeLib})
		If ValType(aRetPe) == "A" .and. ( Len(aRetPe) == 2 ) .and. ( ValType(aRetPe[1]) == "N" ) .and. ( ValType(aRetPe[2]) == "N" ).and. ( aRetPe[2] > 0 )
			
			If a462AnQtde(aRetPE[2],nPrecTotal)
		   		nOpca 	 := aRetPE[1]
				nQtdeLib := aRetPE[2] 
			Endif
				
		Else 
			Aviso(STR0007,STR0098,{"OK"})	//##Atenção##"Valores retornados pelo ponto de entrada(M462SLP) são inválidos, verifique a documentação no TDN."
		EndIf
	Else
		DEFINE MSDIALOG oDlg FROM  09,0 TO 25,76 TITLE cCadDivSc9 OF oMainWnd
	
		@ 001, 002 TO 057, 267 OF oDlg   PIXEL
		@ 058, 002 TO 119, 267 OF oDlg   PIXEL
	
		@ 007, 005 SAY RetTitle("C5_CLIENTE") SIZE 21, 7 OF oDlg PIXEL
		If SC5->C5_TIPO$"DB"
			@ 016, 004 MSGET SA2->A2_COD When .F.  SIZE 23, 11 OF oDlg PIXEL
		Else
			@ 016, 004 MSGET SA1->A1_COD When .F.  SIZE 23, 11 OF oDlg PIXEL
		Endif
	
		@ 007, 029 SAY RetTitle("C5_LOJA") SIZE 16, 7 OF oDlg PIXEL
		If SC5->C5_TIPO$"DB"
			@ 016, 029 MSGET SA2->A2_LOJA When .F. SIZE 16, 11 OF oDlg PIXEL
		Else
			@ 016, 029 MSGET SA1->A1_LOJA When .F. SIZE 16, 11 OF oDlg PIXEL
		Endif
	
		@ 007, 048 SAY RetTitle("A1_NOME")	SIZE 20, 7 OF oDlg PIXEL
		If SC5->C5_TIPO$"DB"
			@ 016, 048 MSGET SA2->A2_NOME When .F. SIZE 107, 11 OF oDlg PIXEL
		Else
			@ 016, 048 MSGET SA1->A1_NOME When .F. SIZE 107, 11 OF oDlg PIXEL
		Endif
	
		@ 007, 158 SAY cRetCGC  	SIZE 20, 7 OF oDlg PIXEL
		If SC5->C5_TIPO$"DB"
			@ 016, 158 MSGET SA2->A2_CGC Picture pesqpict("SA2","A2_CGC") When .F. SIZE 53, 11 OF oDlg PIXEL
		Else
			@ 016, 158 MSGET SA1->A1_CGC Picture pesqpict("SA1","A1_CGC") When .F. SIZE 53, 11 OF oDlg PIXEL
		Endif
	
		@ 007, 214 SAY RetTitle("A1_TEL") SIZE 30, 7 OF oDlg PIXEL
		If SC5->C5_TIPO$"DB"
			@ 016, 214 MSGET SA2->A2_TEL When .F.  SIZE 50, 11 OF oDlg PIXEL
		Else
			@ 016, 214 MSGET SA1->A1_TEL When .F.  SIZE 50, 11 OF oDlg PIXEL
		Endif
	
		@ 031, 005 SAY cDescri SIZE 21, 7 OF oDlg PIXEL
		@ 039, 004 MSGET TRB->C9_PEDIDO Picture pesqpict("SC9","C9_PEDIDO") When .F. SIZE 42, 11 OF oDlg PIXEL
		
		@ 031, 048 SAY OemToAnsi(STR0083) SIZE 25, 7 OF oDlg PIXEL //"Sujeto Fiscal"
		@ 039, 048 MSGET cSujFiscal When .F. SIZE 107, 11 OF oDlg PIXEL
		
		@ 031, 158 SAY OemToAnsi(STR0092) SIZE 35, 7 OF oDlg PIXEL //"Provincia" ou "Estado" dependendo da localizacao
		@ 039, 158 MSGET cProvincia When .F. SIZE 80, 11 OF oDlg PIXEL
		
		@ 067, 005 SAY RetTitle("C6_ITEM") SIZE 15, 7 OF oDlg PIXEL
		@ 076, 005 MSGET TRB->C9_ITEM SIZE 16, 11 Picture "@!" When .F. OF oDlg PIXEL
		
		@ 067, 027 SAY RetTitle("C6_PRODUTO") SIZE 50, 7 OF oDlg PIXEL
		@ 076, 027 MSGET TRB->C9_PRODUTO SIZE 68, 11 Picture "@!" When .F. OF oDlg PIXEL
		
		@ 067, 100 SAY OemToAnsi(STR0085) SIZE 50, 7 OF oDlg PIXEL //"Preco Mercaderia"
		@ 076, 100 MSGET TRB->C9_PRCVEN SIZE 50, 11 Picture "@R 9999999.9999" When .F. OF oDlg PIXEL
		
		@ 067, 157 Say OemToAnsi(STR0086) SIZE 50, 7 OF oDlg PIXEL //"Preco Total"
		@ 076, 157 MSGET nPrecTotal SIZE 68, 11 Picture "@R 9999999.9999" When .F. OF oDlg PIXEL
		
		@ 092, 005 SAY RetTitle("C6_LOCAL") SIZE 27, 7 OF oDlg PIXEL  //"Deposito"
		@ 101, 005 MSGET TRB->C9_LOCAL SIZE 15,11 Picture "@!" When .F. OF oDlg PIXEL
		
		@ 092, 030 SAY RetTitle("C6_LOTECTL") SIZE 40, 7 OF oDlg PIXEL  //"Lote"
		@ 101, 030 MSGET TRB->C9_LOTECTL SIZE 33,11 Picture "@!" When .F. OF oDlg PIXEL
		
		@ 092, 070 SAY RetTitle("C6_NUMLOTE") SIZE 37, 7 OF oDlg PIXEL  //"SubLote"
		@ 101, 070 MSGET TRB->C9_NUMLOTE SIZE 23,11 Picture "@!" When .F. OF oDlg PIXEL
		
		@ 092, 100 SAY OemToAnsi(STR0087) SIZE 50, 7 OF oDlg PIXEL  //"Quantidade Original"
		@ 101, 100 MSGET nQtdeOrig SIZE 52,11 Picture "@R 9999999.9999" When .F. OF oDlg PIXEL
		
		@ 092, 156 Say OemToAnsi(STR0088) SIZE 70, 7 OF oDlg PIXEL  //"Quantidade a Faturar"
		@ 101, 156 MSGET nQtdeLib SIZE 50,11 Picture "@R 9999999.9999" Valid a462AnQtde(nQtdeLib,@nPrecTotal) OF oDlg PIXEL
	
		If cPaisLoc == "COL" .AND. SC9->(FieldPos("C9_APRREM")) > 0
			cCodLiber := TRB->C9_APRREM	
			@ 092, 220 Say STR0091 SIZE 60, 7 OF oDlg PIXEL  //"Codigo da Liberacao"
			@ 101, 220 MSGET cCodLiber SIZE 42,11 Picture "@!" OF oDlg PIXEL	
		EndIf
			
		DEFINE SBUTTON FROM 004, 270 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
		DEFINE SBUTTON FROM 020, 270 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg
	EndIf	

	a462SetOp(nOpca)
	If nOpca == 1 
		//Localizacao Colombia Grava C9_APRREM caso nao haja divisao do SC9
		If cPaisLoc == "COL" .AND. SC9->(FieldPos("C9_APRREM")) > 0	   
			RecLock("SC9")					
			SC9->C9_APRREM := cCodLiber	
			SC9->(MsUnlock())
		EndIf	
		If nQtdeLib <> TRB->C9_QTDLIB
			a462ADivSC9("TRB",nQtdeLib,lMarcar,cCodLiber)
		EndIf	
	EndIf
	dbSelectArea("TRB")
EndIf

RestArea(aAreaTRB)
RestArea(aAreaSC9)
RestArea(aAreaSC5)
RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a462ADivSC9³ Autor ³Kleber Dias Gomes     ³ Data ³11/04/2007  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina quebra da quantidade do SC9.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias com os itens da liberacao do pedido de venda     ³±±
±±³          ³ExpM2: Quantidade a dividir do item da lib. do pedido de venda³±±
±±³          ³ExpL3: Devera marcar apos divisao do SC9 .T. ou .F. (Default) ³±±
±±³          ³ExpC4: Codigo de Liberacao (Loc. Colombia)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a462ADivSC9(cAliasTrb,nQtdNew,lMarcar,cCodLiber)

Local aArea       := GetArea()
Local aAreaSC5    := SC5->(GetArea())
Local aAreaSC6    := SC6->(GetArea())
Local aAreaSC9    := SC9->(GetArea())
Local aAreaTRB    := (cAliasTRB)->(GetArea())
Local aSaldos     := {}
Local aOldSC6     := Array(6)
Local aClone      := {}
Local nX          := 0
Local cPedido     := (cAliasTRB)->C9_PEDIDO
Local cItem       := (cAliasTRB)->C9_ITEM
Local cLiberOk    := ""
Default cCodLiber := "" //Codigo de Liberacao. Loc. Colombia                              
Default lMarcar   := .F. //Define se deve marcar no Markbrowse quando houver divisao do SC9. Loc. Colombia

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa o registro no SC9                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC9")
dbSetOrder(1)
If MsSeek(xFilial("SC9")+cPedido+cItem+(cAliasTRB)->C9_SEQUEN+(cAliasTRB)->C9_PRODUTO) .And. SoftLock("SC9")
	dbSelectArea("SC5")
	dbSetOrder(1)
	MsSeek(xFilial("SC5")+cPedido)

	dbSelectArea("SC6")
	dbSetOrder(1)
	MsSeek(xFilial("SC6")+cPedido+cItem)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento da divisao do item de pedido de venda liberado           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aSaldos,{})
	aadd(aSaldos[1],SC9->C9_LOTECTL)
	aadd(aSaldos[1],SC9->C9_NUMLOTE)
	aadd(aSaldos[1],SC6->C6_LOCALIZ)
	aadd(aSaldos[1],SC6->C6_NUMSERI)
	aadd(aSaldos[1],nQtdNew)
	aadd(aSaldos[1],SC9->C9_POTENCI)
	aadd(aSaldos[1],SC9->C9_DTVALID)
	aadd(aSaldos,{})
	aadd(aSaldos[2],SC9->C9_LOTECTL)
	aadd(aSaldos[2],SC9->C9_NUMLOTE)
	aadd(aSaldos[2],SC6->C6_LOCALIZ)
	aadd(aSaldos[2],SC6->C6_NUMSERI)
	aadd(aSaldos[2],SC9->C9_QTDLIB-nQtdNew)
	aadd(aSaldos[2],SC9->C9_POTENCI)
	aadd(aSaldos[2],SC9->C9_DTVALID)

	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trava registro para atualizacao do pedido de venda                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SC5")
	RecLock("SC6")
	RecLock("SC9")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o status do pedido quanto a liberacao                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLiberOk := SC5->C5_LIBEROK
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Divide o SC9 pela quantidades informadas                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SC9->(a460Estorna())
	For nX := 1 To Len(aSaldos)
		aOldSC6[1] := SC6->C6_LOTECTL
		aOldSC6[2] := SC6->C6_NUMLOTE
		aOldSC6[3] := SC6->C6_LOCALIZ
		aOldSC6[4] := SC6->C6_NUMSERI
		aOldSC6[5] := SC6->C6_DTVALID
		aOldSC6[6] := SC6->C6_POTENCI

		SC6->C6_LOTECTL := aSaldos[nX][1]
		SC6->C6_NUMLOTE := aSaldos[nX][2]
		SC6->C6_LOCALIZ := aSaldos[nX][3]
		SC6->C6_NUMSERI := aSaldos[nX][4]
		SC6->C6_POTENCI := aSaldos[nX][6]
		SC6->C6_DTVALID := aSaldos[nX][7]

		MaLibDoFat(SC6->(RecNo()),aSaldos[nX][5],.T.,.T.,.F.,.F.,.F.,.F.)
							
		SC6->C6_LOTECTL := aOldSC6[1]
		SC6->C6_NUMLOTE := aOldSC6[2]
		SC6->C6_LOCALIZ := aOldSC6[3]
		SC6->C6_NUMSERI := aOldSC6[4]
		SC6->C6_DTVALID := aOldSC6[5]
		SC6->C6_POTENCI := aOldSC6[6]
	Next nX
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna o status do pedido de venda quanto a liberacao                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SC5")
	SC5->C5_LIBEROK := 	cLiberOk
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o arquivo temporario com os novos itens criados               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasTRB)
	For nX := 1 To FCount()
		aadd(aClone,FieldGet(nX))
	Next nX

	dbSelectArea("SC9")
	dbSetOrder(1)
	MsSeek(xFilial("SC9")+cPedido+cItem)

	While !Eof() .And. xFilial("SC9") == SC9->C9_FILIAL .And.;
		cPedido == SC9->C9_PEDIDO .And.;
		cItem == SC9->C9_ITEM

		If Empty(SC9->C9_BLCRED+SC9->C9_BLEST)
			dbSelectArea(cAliasTRB)
			dbSetOrder(1)
			If MsSeek(xFilial("SC9")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN)
			   RecLock(cAliasTRB,.F.)
			Else
				If !Empty(SC9->C9_REMITO)
						dbSelectArea("SC9")
						dbSkip()
						Loop
				EndIf
				RecLock(cAliasTRB,.T.)
				For nX := 1 To FCount()
					FieldPut(nX,aClone[nX])
				Next nX        			
			EndIf                                       
			(cAliasTRB)->C9_OK     := SC9->C9_OK			   			
			(cAliasTRB)->C9_SEQUEN := SC9->C9_SEQUEN
			(cAliasTRB)->C9_QTDLIB := SC9->C9_QTDLIB
			(cAliasTRB)->RECNO     := SC9->(Recno())                  			
			//Grava codigo da liberacao, localizacao colombia
			If cPaisLoc == "COL" .AND. SC9->(FieldPos("C9_APRREM")) > 0					
				//Localizacao Colombia, marcar ultimo C9 Gerado no browse				
				If (SC9->C9_QTDLIB == nQtdNew)			                 
					RecLock("SC9")				
					If lMarcar
						(cAliasTRB)->C9_OK	:= cMarca
						SC9->C9_OK			:= cMarca
						lMarcar				:= .F.
					EndIf				
					If (!Empty(cCodLiber))
						SC9->C9_APRREM := cCodLiber 					
						cCodLiber := ""				
					EndIf                                               					 						
					SC9->(MsUnlock())
				EndIf		
			EndIf
			TRB->(MsUnlock())
		EndIf

		dbSelectArea("SC9")
		dbSkip()
	EndDo		
	MsUnLock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta do arquivo temporario os itens as sequencias que foram perdidas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasTRB)
	dbSetOrder(1)
	MsSeek(xFilial("SC9")+cPedido+cItem)
	While !Eof() .And. xFilial("SC9") == (cAliasTRB)->C9_FILIAL .And.;
		cPedido == (cAliasTRB)->C9_PEDIDO .And.;
		cItem == (cAliasTRB)->C9_ITEM
		dbSelectArea("SC9")
		dbSetOrder(1)
		If !MsSeek(xFilial("SC9")+(cAliasTRB)->C9_PEDIDO+(cAliasTRB)->C9_ITEM+(cAliasTRB)->C9_SEQUEN) .Or.;
			!Empty(SC9->C9_BLCRED+SC9->C9_BLEST)
			RecLock(cAliasTRB,.F.)
			dbDelete()
			MsUnLock()
		EndIf

		dbSelectArea(cAliasTRB)
		dbSkip()
	EndDo
	End Transaction
EndIf


RestArea(aAreaTRB)
RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a462AnQtde³ Autor ³ Kleber Dias Gomes     ³ Data ³ 13/04/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validar a quantidade do Remito a ser Faturada...           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA462An - Generaci¢n de Remitos.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a462AnQtde(nQtdeLib,nPrecTotal)
LOCAL lRet := .T.

If nQtdeLib > TRB->C9_QTDLIB
	HELP("",1,"QTNODISP")
	lRet  := .F.
Else
	nPrecTotal:= ( nQtdeLib * TRB->C9_PRCVEN )
EndIf

Return( lRet.And.nQtdeLib > 0 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a462GetOp ³ Autor ³ CRM Vendas            ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retornar a variavel static nOpcao como resultado da funcao ³±±
±±³          ³ a462ANDivid para detectar qual botao foi acionado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA462An - Generaci¢n de Remitos.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a462GetOp()
Return nOpcao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a462SetOp ³ Autor ³ CRM Vendas            ³ Data ³ 05/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Setar a variavel static nOpcao como resultado da funcao    ³±±
±±³          ³ a462ANDivid para detectar qual botao foi acionado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: 1 - OK                                               ³±±
±±³          |       0 - Cancelar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA462An - Generaci¢n de Remitos.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a462SetOp(nOpt)
	nOpcao := nOpt
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a462GdpChi³ Autor ³ Leandro Nogueira      ³ Data ³ 01/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Montar array do SF2 e SD2 com os dados da GUIA DE DESPACHO  ³±±
±±³          ³especifica para o Chile, com todos os valores zerados 	  ³±±
±±³          ³Release 11.5 - Chile - F2CHI						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: 1 - OK                                               ³±±
±±³          |       0 - Cancelar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA462An - Generaci¢n de Remitos.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a462GdpChi (cCliFor	,cLoja	,nMoedSel,nTipoGer)
				
Local lRet := .F.

DEFAULT cCliFor		:= ""
DEFAULT cLoja		:= ""
DEFAULT nMoedSel   	:= 1
DEFAULT	nTipoGer	:= 1


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Incluir SD2     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
PutSD2('D2_CLIENTE' ,cCliFor)
PutSD2('D2_LOJA'    ,cLoja)
PutSD2('D2_EMISSAO' ,dDataBase)
PutSD2('D2_COD'  	,SC9->C9_PRODUTO)
PutSD2('D2_UM'      ,SC6->C6_UM)
PutSD2('D2_QUANT'   ,SC9->C9_QTDLIB)
PutSD2('D2_QTDAFAT' ,IIf(SC5->C5_TIPOREM $ ' 01'+_RMCONS,SC9->C9_QTDLIB,0))
PutSD2('D2_SEGUM'   ,SC6->C6_SEGUM)
PutSD2('D2_QTSEGUM' ,(SC6->C6_UNSVEN * (GetSD2('D2_QTDAFAT') / SC6->C6_QTDVEN)))
PutSD2('D2_LOCAL'   ,SC6->C6_LOCAL)
If cPaisLoc == "RUS"
   PutSD2('D2_FDESC'	 ,SC6->C6_FDESC)	
EndIf
PutSD2('D2_PEDIDO'  ,SC9->C9_PEDIDO)
PutSD2('D2_ITEMPV'  ,SC9->C9_ITEM)
PutSD2('D2_SEQUEN'  ,SC9->C9_SEQUEN)
PutSD2('D2_NUMSEQ'  ,ProxNum())
	
If SC5->C5_TIPOREM == _RMCONS
	PutSD2('D2_TES' ,Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_TESENV") )
Else
	PutSD2('D2_TES' ,SC6->C6_TES)
	SF4->(dbSetOrder(1))
	SF4->(MsSeek( xFilial("SF4")+SC6->C6_TES ))			
Endif
	
PutSD2('D2_CF'      ,SC6->C6_CF)
PutSD2('D2_GERANF'  ,"N")
PutSD2('D2_TP'     	,SB1->B1_TIPO)
PutSD2('D2_AGREG'   ,SC9->C9_AGREG)
PutSD2('D2_GRUPO'   ,SC9->C9_GRUPO)
PutSD2('D2_SEQUEN'  ,SC9->C9_SEQUEN)
PutSD2('D2_NUMSERI' ,SC6->C6_NUMSERI)
PutSD2('D2_COMIS1'  ,SC6->C6_COMIS1)		
PutSD2('D2_COMIS2'  ,SC6->C6_COMIS2)		
PutSD2('D2_COMIS3'  ,SC6->C6_COMIS3)		
PutSD2('D2_COMIS4'  ,SC6->C6_COMIS4)		
PutSD2('D2_COMIS5'  ,SC6->C6_COMIS5)		
PutSD2('D2_TIPOREM' ,SC5->C5_TIPOREM)
PutSD2('D2_IDENTB6'	,SC9->C9_IDENTB6)
PutSD2('D2_LOTECTL'	,SC9->C9_LOTECTL)
PutSD2('D2_NUMLOTE' ,If(Rastro(SC9->C9_PRODUTO,"L"),"",SC9->C9_NUMLOTE))
PutSD2('D2_DTVALID' ,SC9->C9_DTVALID)
PutSD2('D2_EDTPMS'	,SC9->C9_EDTPMS)
PutSD2('D2_PROJPMS' ,SC9->C9_PROJPMS)
PutSD2('D2_TASKPMS' ,SC9->C9_TASKPMS)
PutSD2('D2_TOTAL'  	,0)
PutSD2('D2_PRCVEN'	,0)
PutSD2('D2_DESC'	,0)
PutSD2('D2_DESCON'	,0) 
PutSD2('D2_PRUNIT'  ,0)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Incluir SF2     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PutSF2('F2_CARGA'  	,SC9->C9_CARGA)
PutSF2('F2_SEQCAR' 	,SC9->C9_SEQCAR)
PutSF2('F2_MOEDA'  	,Iif(nTipoGer == 1,SC5->C5_MOEDA,nMoedSel)  )
PutSF2('F2_TXMOEDA'	,Iif(nTipoGer == 1.And.SC5->C5_TXMOEDA>0,SC5->C5_TXMOEDA,Recmoeda(dDatabase,nMoedSel)))
PutSF2('F2_NATUREZ' ,SC5->C5_NATUREZ)
If SC5->(FieldPos('C5_CODMUN')) > 0 .And.SF2->(FieldPos('F2_CODMUN')) >0 
	PutSF2('F2_CODMUN'	,SC5->C5_CODMUN)
Endif
If SC5->(FieldPos('C5_PROVENT')) > 0 .And.SF2->(FieldPos('F2_PROVENT')) >0 
	PutSF2('F2_PROVENT'	,SC5->C5_PROVENT)
Endif
PutSF2('F2_VEND1' 	,SC5->C5_VEND1)
PutSF2('F2_VEND2' 	,SC5->C5_VEND2)
PutSF2('F2_VEND3' 	,SC5->C5_VEND3)
PutSF2('F2_VEND4' 	,SC5->C5_VEND4)
PutSF2('F2_VEND5' 	,SC5->C5_VEND5)
		
PutSF2('F2_CLIENTE'	,cCliFor)
PutSF2('F2_LOJA'   	,cLoja)
PutSF2('F2_EMISSAO'	,dDataBase)
PutSF2('F2_TIPOREM'	,SC5->C5_TIPOREM)
PutSF2('F2_TIPO'   	,SC5->C5_TIPO)

// Se o pedido não utilizou a moeda 1 e a moeda do remito (F2_MOEDA) for igual a moeda 1
If SC5->C5_MOEDA <> 1 .AND. (nTipoGer <> 1 .AND. nMoedSel == 1)		   	
	If SF2->(Fieldpos("F2_REFTAXA")) > 0				
		PutSF2('F2_REFTAXA', 	SC5->C5_TXMOEDA)							
	EndIf
	
	If SF2->(Fieldpos("F2_REFMOED")) > 0
		PutSF2('F2_REFMOED',	SC5->C5_MOEDA)
	EndIf
EndIf

If SF2->(FieldPos("F2_RUTCLI")) > 0
	PutSF2('F2_RUTCLI',SA1->A1_CGC)
EndIf

PutSF2('F2_VALMERC'  ,0)
PutSF2('F2_DESCONT'  ,0)
PutSF2('F2_DESCCAB'  ,0)
PutSF2('F2_FRETE'    ,0)
PutSF2('F2_SEGURO'   ,0)
PutSF2('F2_DESPESA'  ,0)
PutSF2('F2_VALBRUT'  ,0)

lRet := .T.
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a462NumGdp  ³ Autor ³ Leandro Nogueira	³ Data ³ 01/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pega o numero da Guia de Despacho						  ³±±
±±³			 ³ Release 11.5 - Chile - F2CHI								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MatARem                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a462NumGdp()
Local aRet	      :=  {Nil,Nil}
Local lSerieOk	  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar na tabela SFP os controles de formularios³
//³com especie 8 - Guia de Despacho                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SFP")
DbSetOrder(6)
DbSeek(xFilial("SFP") + cFilAnt + "5")
While !SFP->(Eof()) .AND. xFilial("SFP") == SFP->FP_FILIAL .AND. SFP->FP_FILUSO == cFilAnt 
	If SFP->FP_ESPECIE == "5"
		DbSelectArea("SX5")
		DbSetOrder(1)
		If DbSeek( xFilial("SX5")+"01"+SFP->FP_SERIE,.F. )		
			If 	ChkFolCHI(cFilAnt	,SFP->FP_SERIE,AllTrim(X5Descri()), "5",;
							NIL		,.F.)                             
							
				aRet		:=	{SFP->FP_SERIE,AllTrim(X5Descri())}
				lSerieOk 	:= .T.
				Exit 	
			EndIf    	
		EndIf
	EndIf
	SFP->(dbSkip())
End              

If !lSerieOk 
	Aviso(STR0007,STR0094,{"OK"})//"Atencao"#'Não foi encontrada uma série válida ,verifique se existe um controle de formuláros válido para espécie Guia de Despacho.O Processo será cancelado.'					
EndIf

Return aRet


// Russia_R5

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SX3Virtual  ³ Autor ³ ARodriguez         ³ Data ³ 04/06/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Arreglo de campos virtuales con inicializador Browse		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array de campos virtuales por agregar a MarkBrow() ³±±
±±³          ³ ExpA2 = Array de campos virtuales para crear tabla temporal³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC3 = String de campos virtuales						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SX3Virtual(aCamposPE, aCamposV)
	Local aArea		:= GetArea()
	Local aAreaSX3	:= GetArea("SX3")
	Local cCamposV	:= ""
	Local xN		:= 0

	DbSelectArea("SX3")
	DbSetOrder(2)

	For xN := 1 to Len(aCamposPE)
		If DbSeek(aCamposPE[xN])
			If X3uso(X3_USADO) .And. cNivel >= X3_NIVEL .And. X3_BROWSE == "S" .And. X3_CONTEXT == "V" .And. !Empty(X3_INIBRW)
				AAdd(aCamposV, {X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL, Alltrim(X3_INIBRW)} )
				cCamposV += Trim(X3_CAMPO) + "|"
			EndIf
		EndIf
	Next xN

	RestArea(aAreaSX3)
	RestArea(aArea)
Return cCamposV

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Sql2Trb     ³ Autor ³ ARodriguez         ³ Data ³ 04/06/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria temporario a partir de uma Query					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Query a ser processada							  ³±±
±±³          ³ ExpA2 = Array com estrutura do arquivo temporario		  ³±±
±±³          ³ ExpC3 = Nome do alias para o arquivo temporario			  ³±±
±±³          ³ ExpA4 = Array con campos virtuales						  ³±±
±±³          ³ ExpC5 = String con campos virtuales						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TOPCONNECT (copiada de SqlToTrb)                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Sql2Trb( cQuery, aStruTmp, cAliasTmp, aCamposV, cCamposV )
Local nI		:= 0
Local nJ        := 0
Local nF        := 0
Local nG        := 0
Local nTotalRec := 0
Local aStruQry 	:= {}

Default aCamposV := {}
Default cCamposV := ""

cQuery := ChangeQuery(cQuery)
MsAguarde({|| dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .F., .T.)}, STR0005)

For nJ := 1 to Len(aStruTmp)
	If !(aStruTmp[nJ,2] $ 'CM')
		TCSetField("TMP", aStruTmp[nJ,1], aStruTmp[nJ,2],aStruTmp[nJ,3],aStruTmp[nJ,4])
	EndIf
Next nJ

nTotalRec	:= TMP->(RecCount())
aStruQry	:= TMP->(DbStruct())
nF			:= Len(aStruQry)
nG			:= Len(aCamposV)
TMP->(DbGoTop())
ProcRegua( nTotalRec )

While ! TMP->(Eof())
	IncProc()
	(cAliasTmp)->(DbAppend())
	For nI := 1 To nF
		If aStruQry[nI,2] <> 'M' .And. !(Trim(aStruQry[nI,1]) $ cCamposV)
			(cAliasTmp)->(FieldPut(FieldPos(aStruQry[nI,1]),TMP->(FieldGet(TMP->(FieldPos(aStruQry[nI,1]))))))
		Endif
	Next nI

	// Llenar contenido de campos virtuales
	For nI := 1 To nG
		SC9->( DbGoto(TMP->RECNO) )
			
		bBlock := ErrorBlock( { |e| ChecErro(e) } )
		BEGIN SEQUENCE
			xResult := &(aCamposV[nI,5])
		RECOVER
			xResult := ""
		END SEQUENCE
		ErrorBlock(bBlock)
			
		If !Empty(xResult)
			(cAliasTmp)->(FieldPut(FieldPos(aCamposV[nI,1]), xResult))
		EndIf
	Next nI
	
	TMP->(DbSkip())
End

TMP->(dbCloseArea())
DbSelectArea(cAliasTmp)
Return Nil

/*/{Protheus.doc} LibMt462an
Función utilizada para validar la fecha de la LIB para ser utilizada en Telemetria
@type       Function
@author     Faturación
@since      2021
@version    12.1.27
@return     _lMetric, lógico, si la LIB puede ser utilizada para Telemetria
/*/
Static Function LibMt462an()

If _lMetric == Nil 
	_lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
EndIf

Return _lMetric

/*/{Protheus.doc} M462GETSFP
	Obtiene datos de tabla Control de Formularios (SFP)
	@type  Function
	@author eduardo.manriquez
	@since 26/03/2022
	@version 1.0
	@param cFilAnt  , Caracter , Filial donde se usa la serie.
	@param cSerie , Caracter , Serie del documento.
	@param cEspecie , Caracter , Especie de documento.
	@return aDatos, arreglo, Arreglo que contiene el punto de emisión y establecimiento
	@example
	M462GETSFP(cFilAnt,cSerie,cEspecie)
	@see (links_or_references)
/*/
Static Function M462GETSFP(cFilAnt,cSerie,cEspecie)
	Local aArea    := GetArea()
	Local cPtoEmi  := ""
	Local cEstabl  := ""
	Local aDatos   := {}
	Default cFilAnt := ""
	Default cSerie  := ""
	Default cEspecie:= ""
	
	DbSelectArea("SFP")
	SFP->(DbSetOrder(5)) //FP_FILIAL+FP_FILUSO+FP_SERIE+FP_CAI+FP_ESPECIE
	If (SFP->(MSSeek(xFilial("SFP") + cFilAnt + cSerie+cEspecie)))
		cPtoEmi := SFP->FP_PTOEMIS
		cEstabl := SFP->FP_ESTABL
	EndIf
	aDatos := {cPtoEmi,cEstabl}
	RestArea(aArea)		
Return aDatos
