#INCLUDE "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FISA018.CH"

static oTmpTrbXMl
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISA018   ³ Autor ³ Marcos Kato           ³ Data ³26/07/2010  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apuracao de impostos. Equador     	    			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA018()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Apuracao de impostos                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³26/12/16  ³SERINN001-³creación de tablas temporales se      ³±±
±±³            ³          ³       539³asigna FWTemporaryTable en función    ³±±
±±³            ³          ³          ³GerTRBXML.                            ³±±
±±³Alf. Medrano³12/01/17  ³SERINN001-539³Merge Main vs 12.1.15              ³±±
±±³Jonathan glz³21/02/2018³DMINA-728 ³Se  realiza la replica de los issues  ³±±
±±³            ³          ³          ³dmina-320 y dmina-208 para v12.1.17 y ³±±
±±³            ³          ³          ³dejar las versiones 12 homologadas.   ³±±
±±³Oscar Garcia ³19/06/18 ³DMINA-2432³FQImposto: Query con Union para consi-³±±
±±³            ³          ³          ³derar SF2, relacionar SD1 -> SF1 y SD2³±±
±±³            ³          ³          ³ -> SF2. Leer grupo de preguntas si se³±±
±±³            ³          ³          ³ejecuta desde MATA950.                ³±±
±±³            ³          ³          ³Se cambia la variable n401 por variab-³±±
±±³            ³          ³          ³esn401Vlr y n401Bas para permitir asi-³±±
±±³            ³          ³          ³gnar la base al concepto 401 sin afec-³±±
±±³            ³          ³          ³tar valores a otros conceptos.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISA018()
Local aArea     := GetArea()
Local cCadastro := STR0001//"Apuração de impostos"
Local aSays     := {}
Local aButtons  := {}
Local aProcFil  := {}
Local aTrab     := {}
Local nX        := 0
Local nxOpc     := 0
Local lPerg     := .F.
Local dDataIni  := Ctod("//")
Local dDataFim  := Ctod("//")
Local cDrive    := ""
Local cNorma    := ""
Local cNewFile  := ""
Local cDest     := ""
Local cDir      := ""
Local cExt      := ""

Private cPerg     := "FISA018"

	aAdd(aSays,STR0002) //"Esta rotina tem a finalidade de efetuar a apuração dos impostos calculados pelo sistema:"
	aAdd(aSays,STR0003) //"Imposto sobre Valor Agregado (IVA) e Imposto por consumo especiais (ICE)."
	aAdd(aSays,STR0004) //""

	aAdd(aButtons,{5,.T.,{ || lPerg := Pergunte(cPerg,.T.) }})
	aAdd(aButtons,{1,.T.,{ || nxOpc := 1,FechaBatch()      }})
	aAdd(aButtons,{2,.T.,{ || nxOpc := 0,FechaBatch()      }})
	FormBatch(cCadastro,aSays,aButtons)

	//*****************************************************************
	//Parametros FISA018
	//*****************************************************************
	//MV_PAR01 - Tipo Imposto
	//MV_PAR02 - Data Inicial
	//MV_PAR03 - Data Final
	//MV_PAR04 - Gera Titulo
	//MV_PAR05 - Data Vencimento do Titulo
	//MV_PAR06 - Arquivo do Periodo Anterior
	//MV_PAR07 - Gera XML
	//MV_PAR08 - Instrucao Normativa
	//MV_PAR09 - Arquivo Destino
	//MV_PAR10 - Diretorio
	//MV_PAR11 - CFOs Transferencia nao objeto IVA
	//MV_PAR12 - CFOs Aquisicoes nao objeto IVA
	//MV_PAR13 - CFOs Ajuste por devolucao de IVA ou IVA rejeitado
	//MV_PAR14 - CFOs IVA presuntivo de salas de jogos ou outros jogos de azar
	//MV_PAR15 - Mora / Interesses
	//MV_PAR16 - Multa / Juros
	//*****************************************************************
	If nxOpc == 1
		If !lPerg
			lPerg := Pergunte(cPerg,.T.)
		Endif
		If (MV_PAR01==1 .And. Upper(Alltrim(MV_PAR08))=="EQU104IV") .Or. (MV_PAR01==2 .And. Upper(Alltrim(MV_PAR08))=="EQU105IC")
			If (MV_PAR01==1 .And. (Empty(MV_PAR06) .Or. ".IV"$Alltrim(Upper(MV_PAR06)))) .Or. (MV_PAR01==2 .And. (Empty(MV_PAR06) .Or. ".IC"$Alltrim(Upper(MV_PAR06))))
				dDataIni := MV_PAR02
				dDataFim := MV_PAR03
				cNorma   := AllTrim(MV_PAR08)+ ".INI"
				cDest    := AllTrim(MV_PAR09)
				cDir     := If(Empty(MV_PAR10),"C:\",AllTrim(MV_PAR10))

				cNewFile := cDir + cDest

				SplitPath(cNewFile,@cDrive,@cDir,@cDest,@cExt)

				cDir := cDrive + cDir
				cDest+= cExt
				cDirRec:= cDir
				Makedir(cDirRec)

				aProcFil := { .F. , cFilAnt }

				DbSelectArea("SX3")
				DbSetOrder(1)
				Processa({ || ProcNorma(cNorma,cDest,cDirRec,aProcFil,@aTrab) })

				// Ferase no array aTrab
				For nX := 1 to Len(aTrab)
					Ferase(AllTrim(aTrab[nX][1]))
				Next
				DbSelectArea("SF3")
				DbSetOrder(1)
			Else
				Aviso(STR0005,STR0150,{STR0007})//"Atencao"###"Informe Arquivo periodo anterior valido de acordo com o Imposto"###"OK"
			Endif
		Else
			Aviso(STR0005,STR0006,{STR0007})//"Atencao"###"Informe INI valido de acordo com o Imposto"###"OK"
		Endif
	Endif

	If oTmpTrbXMl <> Nil
		oTmpTrbXMl:Delete()
		oTmpTrbXMl := Nil
	Endif

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQImposto ³ Autor ³ Marcos Kato     		³ Data ³18/11/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impostos IVA ou ICE                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQImposto()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum       	         								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aArray                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos de Compra                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQImposto(aDadGer)
Local nAlqIVA := nBasIVA := nVlrIVA := 0
Local nAlqRV0 := nBasRV0 := nVlrRV0 := 0
Local nAlqRV1 := nBasRV1 := nVlrRV1 := 0
Local nAlqRV2 := nBasRV2 := nVlrRV2 := 0
Local nAlqICE := nBasICE := nVlrICE := 0
Local nImpPag := nMorInt := nMulJur := 0

Local n303    := n399 := 0
Local n401Vlr := n401Bas := n402 := n403 := n404 := n405 := n406 := n407 := n408 := n409 := 0
Local n411    := n412 := n413 := n414 := n415 := n416 := n417 := n418 := n419 := 0
Local n421    := n422 := n429 := 0
Local n431    := n432 := n433 := n434 := 0
Local n443    := n444 := 0
Local n480    := n481 := n482 := n483 := n484 := n485 := 0
Local n499    := 0
Local n501    := n502 := n503 := n504 := n505 := n506 := n507 := n509 := 0
Local n511    := n512 := n513 := n514 := n515 := n516 := n517 := n518 := n519 := 0
Local n521    := n522 := n523 := n524 := n525 := n529 := 0
Local n531    := n532 := n533 := n534 := 0
Local n543    := n544 := 0
Local n553    := n554 := 0
Local n601    := n602 := n605 := n607 := n609 := 0
Local n611    := n615 := n617 := n619 := 0
Local n621    := 0
Local n699    := 0
Local n721    := n723 := n725 := 0
Local n727    := n729 := n731 := 0 // RET IVA al 70 y 100%
Local n500    := 0
Local n510    := 0
Local n520    := 0
Local n799    := 0
Local n859    := 0
Local n890    := n897 := n898 := n899 := 0
Local n901    := n902 := n903 := n904 := n905 := n906 := n907 := n909 := 0
Local n911    := n913 := n915 := n917 := n919 := 0
Local n999    := 0

Local nMoeda	 :=	IIf(Type("nMoedaCor")=="U",1,nMoedaCor)
Local nNCC       := 0
Local nCont      := 0
Local nPos       := 0
Local nlGetDOpc  := 2
Local c101       := c102 := c104 := ""
Local c198       := c199 := ""
Local c201       := c202 := ""
Local c301       := c302 := ""
Local c908       := c910 := c912 := c914 := c916 := c918 := cNotaAnt := Space(7)
Local c921       := c922 := ""
Local cQuery     := ""
Local cUFCliFor  := ""
Local cTipImp    := ""
Local cNomPadr   := ""
Local cVersao    := ""
Local cVerFor    := ""
Local cArqAnt    := ""
Local cTipDec    := ""
Local cCodPrd    := ""
Local lRise      := .F.
Local lArqAnt    := .F.
Local lGerTit    := .F.
Local lGerXML    := .F.
Local lExclTit   := .T.
Local llMonGet   := .T.
Local lConfirma  := .F.
Local aImpIVAICE := {}
Local aLogApuImp := {}
Local oScroll    := NIL
Local oFont      := TFont():New("Arial",,-11,,.T.)
Local cVarImp    := ""
Local lFisa018	:= (AllTrim(FunName()) == "FISA018")
Local cPerg		:= "FISA018"
Private cNomTxt  := ""
Private cImpDesc := ""
Private aTitulos := {}
Private aHeader	  := {}
Private apTabApu := {}
Private apAlter  := {"OBSERV"}

If !lFisa018
	Pergunte(cPerg,.F.)
Endif

GerTRBXML() 

	cTipImp  := Iif(MV_PAR01==1,"IVA","ICE")
	cImpDesc := Iif(cTipImp=="IVA",STR0008,STR0009)//"Imposto sobre Valor Agregado"###"Imposto por Consumo Especiais"
	cNomTxt  := "A"+GravaData(MV_PAR02,.F.,1)+GravaData(MV_PAR03,.F.,1)+cEmpAnt+cFilAnt+"."+Iif(cTipImp=="IVA","IV","IC")
	lGerTit  := Iif(MV_PAR04==1,.T.,.F.)
	lArqAnt  := Iif(!Empty(MV_PAR06),.T.,.F.)
	cArqAnt  := Alltrim(MV_PAR06)
	lGerXML  := Iif(MV_PAR07==1,.T.,.F.)
	cNomPadr := AllTrim(MV_PAR09)

	//Mes da geracao da declaracao
	c101 := Substr(Dtos(MV_PAR02),5,2)

	//Ano da geracao da declaracao
	c102 := Substr(Dtos(MV_PAR02),1,4)

	//******************************************************************************************
	//aDadGer[1][1]- Tipo Declaração(IVA|ICE)
	//aDadGer[1][2]- Versao do Formulario(IVA)|Imposto Pago(ICE)
	//aDadGer[1][3]- Numero Formulario(IVA)|Numero Formulario(ICE)
	//aDadGer[1][4]- Codigo da Versao do Formulario(IVA)|Versao do Formulario(ICE)
	//aDadGer[1][5]- Imposto Pago(IVA)|Codigo da Versao do Formulario(ICE)
	//aDadGer[1][6]- Num.ID Repr.Legal(IVAICE)
	//aDadGer[1][7]- Mora / Interesses(IVA)|RUC Contador(ICE)
	//aDadGer[1][8]- RUC Contador(IVA)
	//aDadGer[1][9]- Multa / Juros(IVA)
	//******************************************************************************************
	//Tipo Declaracao
	cTipDec := aDadGer[1][1]
	//Versao Formulario
	cVerFor := Iif(cTipImp=="IVA",aDadGer[1][2],aDadGer[1][4])
	//Num.formulario
	c104 := ""
	If Substr(cTipDec,1,1)=="S"
		c104 := aDadGer[1][3]
	Endif
	//Codigo Versao
	cVersao := Iif(cTipImp=="IVA",aDadGer[1][4],aDadGer[1][5])
	//Imposto Pago
	nImpPag := Iif(cTipImp=="IVA",aDadGer[1][5],aDadGer[1][2])
	//ID Representante Legal
	c198 := aDadGer[1][6]
	//RUC Contador
	c199 := Iif(cTipImp=="IVA",aDadGer[1][8],aDadGer[1][7])
	If cTipImp == "IVA" .And. Len(aDadGer[1])>8
		//Mora / Interesses
		nMorInt := aDadGer[1][7]
		//Multa / Juros
		nMulJur := aDadGer[1][9]
	Endif

	If Empty(cNomPadr)
		If cTipImp == "IVA"
			cNomPadr := "104"
		Else
			cNomPadr := "105"
		Endif
		If Substr(cTipDec,1,1) == "O"
	    	cNomPadr += "ORI_"
		Else
	    	cNomPadr += "SUS_"
		Endif
		cNomPadr += Substr(CMONTH(MV_PAR02),1,3)
		cNomPadr += Substr(Dtos(MV_PAR02),1,4)
	Endif
	cNomPadr += ".xml"

	DbSelectArea("SM0")
	c201 := SM0->M0_CGC 		//Ruc Empresa
	c202 := SM0->M0_NOMECOM   //Razao Social Empresa
	c301 := Alltrim(MV_PAR17) //Produto

	If !Empty(c301)
		c302 := Alltrim(Posicione("SB1",1,xFilial("SB1")+AvKey(c301,"B1_COD"),"B1_DESC"))//Descricao do Produto
	Endif
	c921 := ""
	c922 := ""

	aAdd(aLogApuImp,"")
	aAdd(aLogApuImp,STR0010+":")//"Parametros:"
	aAdd(aLogApuImp,"")
	aAdd(aLogApuImp,STR0011+":"+cTipImp)//"Tipo Imposto"
	aAdd(aLogApuImp,STR0012+":"+Dtoc(MV_PAR02))//"Data Inicial"
	aAdd(aLogApuImp,STR0013+":"+Dtoc(MV_PAR03))//"Data Final"
	aAdd(aLogApuImp,STR0014+":"+Iif(lGerTit,STR0015,STR0016))//"Gera Titulo"###"Sim"###"Nao"
	aAdd(aLogApuImp,STR0017+":"+Dtoc(MV_PAR05))//"Data Vencimento do Titulo"
	aAdd(aLogApuImp,STR0018+":"+cArqAnt)//"Arquivo do Periodo Anterior"
	aAdd(aLogApuImp,STR0019+":"+Iif(lGerXML,STR0015,STR0016))//"Gera XML:"###"Sim"###"Nao"
	aAdd(aLogApuImp,STR0020+":"+Alltrim(MV_PAR08))//"Instrucao Normativa"
	aAdd(aLogApuImp,STR0021+":"+Alltrim(MV_PAR09))//"Arquivo Destino"
	aAdd(aLogApuImp,STR0022+":"+Alltrim(MV_PAR10))//"Diretorio"
	aAdd(aLogApuImp,STR0023+":")//"CFOs Transferencia nao objeto IVA"
	aAdd(aLogApuImp,Alltrim(MV_PAR11))
	aAdd(aLogApuImp,STR0024+":")//"CFOs Aquisicoes nao objeto IVA"
	aAdd(aLogApuImp,Alltrim(MV_PAR12))
	aAdd(aLogApuImp,STR0025+":")//"CFOs Ajuste por devolucao de IVA ou IVA rejeitado"
	aAdd(aLogApuImp,Alltrim(MV_PAR13))
	aAdd(aLogApuImp,STR0026+":")//"CFOs IVA presuntivo de salas de jogos ou outros jogos de azar"
	aAdd(aLogApuImp,Alltrim(MV_PAR14))
	aAdd(aLogApuImp,STR0027+":"+Alltrim(Transform(MV_PAR15,"@E 999,999,999.99")))//"Mora / Interesses"
	aAdd(aLogApuImp,STR0028+":"+Alltrim(Transform(MV_PAR16,"@E 999,999,999.99")))//"Multa / Juros"
	aAdd(aLogApuImp,STR0029+":"+Alltrim(c301))//"Produto"
	aAdd(aLogApuImp,"")

	aImpIVAICE := {}

	aHeader:= {}
	aAdd(aHeader,{STR0030,"ITEM"	,"@!"				,03,2,"","","C","",""}) //"Item"
	aAdd(aHeader,{STR0031,"ITMAPUR"	,"@!"               ,60,2,"","","C","",""}) //"Item da Apuração"
	aAdd(aHeader,{STR0032,"VALOR" 	,"@R 999,999,999.99",14,2,"","","N","",""}) //"Valor"
	aAdd(aHeader,{STR0033,"OBSERV"	,"@!"				,50,0,"","","C","",""}) //"Observações"

	If File(cNomTXT) .And. !ApMsgYesNo(STR0034) //"Este periodo ja foi apurado. Deseja refazer?"
		MsgRun(STR0038,,{|| lExclTit := ApurTXT(Alltrim(cNomTXT))}) //"Cancelando apuração anterior..."
		If !lExclTit
			ApMsgStop(STR0036,STR0037) //"Apenas será possível excluir o título gerado e baixado anteriormente se for estornado."###"Apuração de impostos"
			Return nil
		Endif
	Else
		cCPolvr:= fgetCpo("SF3")
		
		cQuery := "SELECT "
		CQuery += "F1_DOC, F1_SERIE, F1_VALMERC,"
		cQuery += "F3_TIPOMOV,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_EXENTAS,F3_CFO,F3_NFISCAL,F3_CONCEPT,F3_EMISSAO,F3_TES,F3_SERIE,F3_TIPO,"
		cQuery += cCPolvr
		cQuery += " F4_ATUATF,F4_CLASMOV,FC_IMPOSTO,FC_INCIMP "
		cQuery += " FROM " + RetSqlName("SF3") + " SF3"
		cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON "
		cQuery += " F4_FILIAL = '" + xFilial("SF4") + "' "
		cQuery += " AND F4_CODIGO=F3_TES "
		cQuery += " AND SF4.D_E_L_E_T_='' "
		cQuery += " INNER JOIN " + RetSqlName("SFC") + " SFC ON "
		cQuery += " FC_FILIAL = '" + xFilial("SFC") + "' "
		cQuery += " AND FC_TES=F3_TES "
		cQuery += " AND SFC.D_E_L_E_T_='' "
		If cTipImp=="ICE"
			cQuery += " AND FC_IMPOSTO = 'ICE' "
		Else
			cQuery += " AND (FC_IMPOSTO IN ('IVT','IVA')  OR (FC_IMPOSTO LIKE 'RV%')) "
		Endif
		cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1 ON "
		cQuery += " F1_DOC=F3_NFISCAL AND F1_SERIE=F3_SERIE AND F1_FORNECE=F3_CLIEFOR AND F1_LOJA=F3_LOJA AND F1_TIPO=F3_TIPO "
		cquery += " AND SF1.D_E_L_E_T_=' ' AND F1_FILIAL= '" + xFilial("SF1") + "' "
		cQuery += " LEFT JOIN " + RetSqlName("SD1") + " SD1 ON "
		cQuery += " D1_FILIAL = '" + xFilial("SD1") + "' "
		cQuery += " AND D1_DOC=F1_DOC "
		cQuery += " AND D1_SERIE=F1_SERIE "
		cQuery += " AND D1_FORNECE=F1_FORNECE "
		cQuery += " AND D1_LOJA=F1_LOJA "
		cQuery += " AND D1_TES=F3_TES "
		cQuery += " AND D1_COD='" + c301 + "' "
		cQuery += " AND SD1.D_E_L_E_T_='' "
		cQuery += " WHERE SF3.D_E_L_E_T_='' "
		cQuery += " AND F3_FILIAL = '" + xFilial("SF3") + "' "
		If Empty(MV_PAR03)
			cQuery += " AND F3_EMISSAO >= '" + Dtos(MV_PAR02) + "' "
		Else
			cQuery += " AND F3_EMISSAO BETWEEN '" + Dtos(MV_PAR02) + "' AND '" + Dtos(MV_PAR03) + "' "
		Endif
	
		cQuery += "UNION "
		
		cQuery += "SELECT "
		CQuery += "F2_DOC AS F1_DOC, F2_SERIE AS F1_SERIE, F2_VALMERC AS F1_VALMERC,"
		cQuery += "F3_TIPOMOV,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_EXENTAS,F3_CFO,F3_NFISCAL,F3_CONCEPT,F3_EMISSAO,F3_TES,F3_SERIE,F3_TIPO,"
		cQuery += cCPolvr	
		cQuery += " F4_ATUATF,F4_CLASMOV,FC_IMPOSTO,FC_INCIMP "
		cQuery += " FROM " + RetSqlName("SF3") + " SF3"
		cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON "
		cQuery += " F4_FILIAL = '" + xFilial("SF4") + "' "
		cQuery += " AND F4_CODIGO=F3_TES "
		cQuery += " AND SF4.D_E_L_E_T_='' "
		cQuery += " INNER JOIN " + RetSqlName("SFC") + " SFC ON "
		cQuery += " FC_FILIAL = '" + xFilial("SFC") + "' "
		cQuery += " AND FC_TES=F3_TES "
		cQuery += " AND SFC.D_E_L_E_T_='' "
		If cTipImp=="ICE"
			cQuery += " AND FC_IMPOSTO = 'ICE' "
		Else
			cQuery += " AND (FC_IMPOSTO IN ('IVT','IVA')  OR (FC_IMPOSTO LIKE 'RV%')) "
		Endif
		cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON "
		cQuery += " F2_DOC=F3_NFISCAL AND F2_SERIE=F3_SERIE AND F2_CLIENTE=F3_CLIEFOR AND F2_LOJA=F3_LOJA AND F2_TIPO=F3_TIPO "
		cquery += " AND SF2.D_E_L_E_T_=' ' AND F2_FILIAL= '" + xFilial("SF2") + "' "
		cQuery += " LEFT JOIN " + RetSqlName("SD2") + " SD2 ON "
		cQuery += " D2_FILIAL = '" + xFilial("SD2") + "' "
		cQuery += " AND D2_DOC=F2_DOC "
		cQuery += " AND D2_SERIE=F2_SERIE "
		cQuery += " AND D2_CLIENTE=F2_CLIENTE "
		cQuery += " AND D2_LOJA=F2_LOJA "
		cQuery += " AND D2_TES=F3_TES "
		cQuery += " AND D2_COD='" + c301 + "' "
		cQuery += " AND SD2.D_E_L_E_T_='' "
		cQuery += " WHERE SF3.D_E_L_E_T_='' "
		cQuery += " AND F3_FILIAL = '" + xFilial("SF3") + "' "
		If Empty(MV_PAR03)
			cQuery += " AND F3_EMISSAO >= '" + Dtos(MV_PAR02) + "' "
		Else
			cQuery += " AND F3_EMISSAO BETWEEN '" + Dtos(MV_PAR02) + "' AND '" + Dtos(MV_PAR03) + "' "
		Endif
		cQuery += " ORDER BY F3_TIPOMOV, F3_EMISSAO, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE ,F3_TES,F3_CONCEPT "

		If Select("IMPOSTO")>0
			DbSelectArea("IMPOSTO")
			IMPOSTO->(DbCloseArea())
		Endif

		TcQuery cQuery New Alias "IMPOSTO"

		DbSelectArea("IMPOSTO")
		Do While IMPOSTO->(!Eof())
			cUFCliFor:=""
			nAlqIVA:=nBasIVA:=nVlrIVA:=0
			nAlqRV0:=nBasRV0:=nVlrRV0:=0
			nAlqRV1:=nBasRV1:=nVlrRV1:=0
			nAlqRV2:=nBasRV2:=nVlrRV2:=0
			nAlqICE:=nBasICE:=nVlrICE:=0

			DbSelectArea("SFB")
			SFB->(DbSetOrder(1))
			If SFB->(DbSeek(xFilial("SFB")+AvKey(IMPOSTO->FC_IMPOSTO,"FB_CODIGO")))
				If Alltrim(IMPOSTO->FC_IMPOSTO) $ "IVA|IVT"
					nAlqIVA:=&("IMPOSTO->F3_ALQIMP"+Alltrim(SFB->FB_CPOLVRO))
					nBasIVA:=&("IMPOSTO->F3_BASIMP"+Alltrim(SFB->FB_CPOLVRO))
					nVlrIVA:=&("IMPOSTO->F3_VALIMP"+Alltrim(SFB->FB_CPOLVRO))
				Else
					cVarImp := SFB->FB_CODRET
					nBasIVA:=&("IMPOSTO->F3_BASIMP"+Alltrim(SFB->FB_CPOLVRO))
					nVlrRV0 := &("IMPOSTO->F3_VALIMP"+Alltrim(SFB->FB_CPOLVRO))
					nVlrIVA := &("IMPOSTO->F3_BASIMP"+Alltrim(SFB->FB_CPOLVRO))
				Endif
			Else
				If Alltrim(IMPOSTO->FC_IMPOSTO) $ "IVA|IVT"
					nAlqIVA:=IMPOSTO->F3_ALQIMP1
					nBasIVA:=IMPOSTO->F3_BASIMP1
					nVlrIVA:=IMPOSTO->F3_VALIMP1
				ElseIf Substr(IMPOSTO->FC_IMPOSTO,1,2)=="RV"
					nVlrRV0:= 0
			    Endif
			Endif

			If cTipImp $ "IVA|IVT"
				If IMPOSTO->F3_TIPOMOV=="V"
					cUFCliFor:=Alltrim(Posicione("SA1",1,xFilial("SA1")+IMPOSTO->F3_CLIEFOR+IMPOSTO->F3_LOJA,"A1_EST"))
					//********************************************************************************
					//Resumo de Vendas e outras operacoes do periodo da declaracao
					//********************************************************************************

					//Valor Bruto - Vendas Locais excluindo ativos fixos gravados com aliquota 12%
					If cUFCliFor<>"EX" .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="N" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDC|NCE"
						n401Vlr+=nVlrIVA
						n401Bas+=nBasIVA
					Endif
					//Valor Bruto - Vendas de ativos fixos gravados com aliquota 12%
					If cUFCliFor<>"EX" .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="S" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDC|NCE"
						n402+=nVlrIVA
					Endif
					//Valor Bruto - Vendas Locais excluindo ativos fixos gravados com aliquota 0% que não dão direito a crédito
					If cUFCliFor<>"EX" .And. IMPOSTO->F3_EXENTAS>0 .And. IMPOSTO->F4_ATUATF=="N"  .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDC|NCE"
						n403+=nVlrIVA
					Endif
					//Valor Bruto - Vendas Locais de ativos fixos gravados com aliquota 0% que não dão direito a crédito
					If cUFCliFor<>"EX" .And. IMPOSTO->F3_EXENTAS>0 .And. IMPOSTO->F4_ATUATF=="S"  .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDC|NCE"
						n404+=nVlrIVA
					Endif
					//Valor Bruto - Vendas Locais excluindo ativos fixos gravados com aliquota 0% que dão direito a crédito
					If cUFCliFor<>"EX" .And. nAlqIVA==0 .And. nBasIVA>0 .And. IMPOSTO->F4_ATUATF=="N" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDC|NCE"
						n405+=nVlrIVA
					Endif
					//Valor Bruto - Vendas Locais de ativos fixos gravados com aliquota 0% que dão direito a crédito
					If cUFCliFor<>"EX" .And. nAlqIVA==0 .And. nBasIVA>0 .And. IMPOSTO->F4_ATUATF=="S".And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDC|NCE"
						n406+=nVlrIVA
					Endif
					//Valor Bruto - Vendas Exportacoes de Bens
					If cUFCliFor=="EX" .And. IMPOSTO->F4_CLASMOV$" B" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDC|NCE"
						n407+=nVlrIVA
					Endif
					//Valor Bruto - Vendas Exportacoes de Servicos
					If cUFCliFor=="EX" .And. IMPOSTO->F4_CLASMOV=="S" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDC|NCE"
						n408+=nVlrIVA
					Endif

					//Valor Liquido - Vendas Locais excluindo ativos fixos gravados com aliquota 12%
					If cUFCliFor<>"EX" .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="N" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE"
						n411+=nVlrIVA
					Endif
					//Valor Liquido - Vendas de ativos fixos gravados com aliquota 12%
					If cUFCliFor<>"EX" .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="S" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE"
						n412+=nVlrIVA
					Endif
					//Valor Liquido - Vendas Locais excluindo ativos fixos gravados com aliquota 0% que não dão direito a crédito
					If cUFCliFor<>"EX" .And. IMPOSTO->F3_EXENTAS>0 .And. IMPOSTO->F4_ATUATF=="N"  .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE"
						n413+=nVlrIVA
					Endif
					//Valor Liquido - Vendas Locais de ativos fixos gravados com aliquota 0% que não dão direito a crédito
					If cUFCliFor<>"EX" .And. IMPOSTO->F3_EXENTAS>0 .And. IMPOSTO->F4_ATUATF=="S"  .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE"
						n414+=nVlrIVA
					Endif
					//Valor Liquido - Vendas Locais excluindo ativos fixos gravados com aliquota 0% que dão direito a crédito
					If cUFCliFor<>"EX" .And. nAlqIVA==0 .And. nBasIVA>0 .And. IMPOSTO->F4_ATUATF=="N" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE"
						n415+=nVlrIVA
					Endif
					//Valor Liquido - Vendas Locais de ativos fixos gravados com aliquota 0% que dão direito a crédito
					If cUFCliFor<>"EX" .And. nAlqIVA==0 .And. nBasIVA>0 .And. IMPOSTO->F4_ATUATF=="S" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE"
						n416+=nVlrIVA
					Endif
					//Valor Liquido - Vendas Exportacoes de Bens
					If cUFCliFor=="EX" .And. IMPOSTO->F4_CLASMOV$" B" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE"
						n417+=nVlrIVA
					Endif
					//Valor Liquido - Vendas Exportacoes de Servicos
					If cUFCliFor=="EX" .And. IMPOSTO->F4_CLASMOV=="S" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE"
						n418+=n408+nVlrIVA
					Endif

					//Transferencia nào objeto de IVA
					If nBasIVA>0 .And. !Empty(MV_PAR11)
						If Alltrim(IMPOSTO->F3_ESPECIE)$"NCC|NDE" .And. ALLTRIM(IMPOSTO->F3_CFO)$Alltrim(MV_PAR11)
							n431+=nVlrIVA
						Endif
					Endif
					//Nao sera tratado, apos a importaao infpormar manualmente(Informativos)
					n432:=0
					n433:=0
					n434:=0
					n443:=0
					n444:=0
					//********************************************************************************
					//Resumo Impositivo: Agente de Retencao
					//********************************************************************************
				    //Retencoes do IVA que tenha efetuadas no periodo
					If (nVlrRV0+nVlrRV1+nVlrRV2)>0
				 		n609+=nVlrRV0+nVlrRV1+nVlrRV2
					Endif

					If Alltrim(IMPOSTO->F3_ESPECIE)$"NCC" .And. nNCC<4
						If cNotaAnt<> IMPOSTO->F3_NFISCAL
							nNcc++
						EndIf
						If nNcc==1
							c908:=IMPOSTO->F3_NFISCAL
							n909:=n909+nVlrIva
						ElseIf nNcc==2
							c910:=IMPOSTO->F3_NFISCAL
							n911:=n911+nVlrIva
						ElseIf nNcc==3
							c912:=IMPOSTO->F3_NFISCAL
							n913:=n913+nVlrIva
						ElseIf nNcc==4
							c914:=IMPOSTO->F3_NFISCAL
							n915:=n915+nVlrIva
						Endif
					cNotaAnt:=IMPOSTO->F3_NFISCAL
					Endif

				ElseIf IMPOSTO->F3_TIPOMOV == "C"
					DbSelectArea("SA2")
					SA2->(DbSetOrder(1))
					If DbSeek(xFilial("SA2")+AvKey(IMPOSTO->F3_CLIEFOR,"A2_COD")+AvKey(IMPOSTO->F3_LOJA,"A2_LOJA"))
						cUFCliFor := Alltrim(SA2->A2_EST)
						If SA2->(FieldPos("A2_RISE"))>0
							lRise := .F.
							If SA2->A2_RISE $ "1S"//1-Sim ou S=Sim|2-Nao ou N=Nao
								lRise := .T.
							Endif
						EndIf
					Endif
					//********************************************************************************
					//Resumo das aquisicoes e pagamentos do período da declaracao
					//********************************************************************************
					If IMPOSTO->FC_IMPOSTO == "IVA"
						//Valor Bruto - Aquisicoes e pagamento excluindo ativos fixos gravados com aliquota 12%(com direito a credito)
						If cUFCliFor<>"EX" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDP|NCI" .And. nBasIVA > 0 .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="N" .And. !lRise
							// Buscar ValMer del Documento
							n500+=IMPOSTO->F1_VALMERC //nBasIVA
							n520+= nVlrIVA
						Endif
						//Valor Bruto - Aquisicoes e pagamento de ativos fixos gravados com aliquota 12%(com direito a credito)
						If cUFCliFor<>"EX" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDP|NCI" .And. nVlrIVA > 0 .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="S" .And. !lRise
							n502+=nVlrIVA
						Endif
						//Valor Bruto - Aquisicoes e pagamento com aliquota 12%(sem direito a credito)
						If cUFCliFor<>"EX" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDP|NCI" .And. IMPOSTO->F3_EXENTAS>0 .And. !lRise
							n503+=nVlrIVA
						Endif
						//Valor Bruto - Importacao de bens excluidos ativos fixos gravados com aliquota 12%
						If cUFCliFor=="EX" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDP|NCI" .And. IMPOSTO->F4_CLASMOV$" B" .And. IMPOSTO->F4_ATUATF=="N" .And. !lRise
							n504+=nVlrIVA
						Endif
						//Valor Bruto - Importacao de atiavos fixos gravados com aliquota 12%
						If cUFCliFor=="EX" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDP|NCI" .And. nVlrIVA > 0 .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="S" .And. !lRise
							n505+=nVlrIVA
						Endif
						//Valor Bruto - Importacao de bens incluindo ativos fixos gravados com aliquota 0%
						If cUFCliFor=="EX" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDP|NCI" .And. nVlrIVA > 0 .And. nAlqIVA > 0 .And. IMPOSTO->F4_CLASMOV$" B" .And. !lRise
							n506+=nVlrIVA
						Endif
						//Valor Bruto - Aquisicoes e pagamentos incluindo ativos fixos gravdos com aliquota 0%
						If cUFCliFor=="EX" .And. Alltrim(IMPOSTO->F3_ESPECIE)$"NF|NDP|NCI" .And. nVlrIVA==0 .And. nBasIVA>0 .And. !lRise
							n507+=nVlrIVA
						Endif

						//Valor Liquido - Aquisicoes e pagamento excluindo ativos fixos gravados com aliquota 12%(com direito a credito)
						If cUFCliFor<>"EX" .And. Alltrim(IMPOSTO->F3_ESPECIE)<>"NCP|NDI" .And. nBasIVA > 0 .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="N"
							n510+=nBasIVA
						Endif
						//Valor Liquido - Aadquisicoes e pagamento de ativos fixos gravados com aliquota 12%(com direito a credito)
						If cUFCliFor <> "EX" .And. Alltrim(IMPOSTO->F3_ESPECIE) <> "NCP|NDI" .And. nVlrIVA > 0 .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="S"
							n512 += nVlrIVA
						Endif
						//Valor Liquido - Aquisicoes e pagamento com aliquota 12%(sem direito a credito)
						If cUFCliFor <> "EX" .And. Alltrim(IMPOSTO->F3_ESPECIE) $ "NCP|NDI" .And. IMPOSTO->F3_EXENTAS>0
							n513 += nVlrIVA
						Endif
						//Valor Liquido - Importacao de bens excluidos ativos fixos gravados com aliquota 12%
						If cUFCliFor == "EX" .And. Alltrim(IMPOSTO->F3_ESPECIE) $ "NCP|NDI" .And. IMPOSTO->F4_CLASMOV $ " B" .And. IMPOSTO->F4_ATUATF=="N"
							n514 += nVlrIVA
						Endif
						//Valor Liquido - Importacao de ativos fixos gravados com aliquota 12%
						If cUFCliFor == "EX" .And. Alltrim(IMPOSTO->F3_ESPECIE) $ "NCP|NDI" .And. nVlrIVA > 0 .And. nAlqIVA > 0 .And. IMPOSTO->F4_ATUATF=="S"
							n515 += nVlrIVA
						Endif
						//Valor Liquido - Importacao de bens incluindo ativos fixos gravados com aliquota 0%
						If cUFCliFor == "EX" .And. Alltrim(IMPOSTO->F3_ESPECIE) $ "NCP|NDI" .And. nVlrIVA > 0 .And. nAlqIVA > 0 .And. IMPOSTO->F4_CLASMOV$" B"
							n516 += nVlrIVA
						Endif
						//Valor Liquido - Aquisicoes e pagamentos incluindo ativos fixos gravdos com aliquota 0%
						If cUFCliFor == "EX" .And. Alltrim(IMPOSTO->F3_ESPECIE) $"NCP|NDI" .And. nVlrIVA == 0 .And. nBasIVA > 0
							n517 += nVlrIVA
						Endif
						//Valor Liquido - Aquisicoes Contribuintes RISE
						If nVlrIVA > 0 .And. Alltrim(IMPOSTO->F3_ESPECIE) $ "NCP|NDI" .And. lRise
							n518 -= nVlrIVA
						Endif
						If nVlrIVA > 0 .And. !(Alltrim(IMPOSTO->F3_ESPECIE) $ "NCP|NDI") .And. lRise
							n518 += nVlrIVA
						Endif
						//Aquisicoes nao objetos de IVA
						If nBasIVA > 0 .And. !Empty(MV_PAR12)
							If Alltrim(IMPOSTO->F3_ESPECIE) $ "NCP|NDI" .And. ALLTRIM(IMPOSTO->F3_CFO) $ Alltrim(MV_PAR12)
								n531 += nVlrIVA
							Endif
						Endif
						//Nao sera tratado pelo sistema por ser informativo.devera ser informado manualmente.
						n532 := 0
						n533 := 0
						n534 := 0
						n543 := 0
						n544 := 0

						//********************************************************************************
						//Resumo Impositivo: Agente de Retencao
						//********************************************************************************
						//Ajuste por devolucao de IVA ou IVA rejeitado que gera credito no mês
						If nBasIVA > 0 .And. !Empty(MV_PAR13)
							If ALLTRIM(IMPOSTO->F3_CFO) $ Alltrim(MV_PAR13)
								n611 += nVlrIVA
							Endif
						Endif
						If nBasIVA > 0 .And. !Empty(MV_PAR14)
							If ALLTRIM(IMPOSTO->F3_CFO) $ Alltrim(MV_PAR14)
								n621 += nVlrIVA
							Endif
						Endif
					EndIf
					//********************************************************************************
					//Agente de Retencao do IVA
					//********************************************************************************
					//Retencoes do IVA 30%
					If nVlrRV0 > 0
						Do case
							case cVarImp $ "721" // RET IVA AL 10%
								n721 += nVlrRV0
							Case cVarImp $ "723" // RET IVA AL 20%
								n723 += nVlrRV0
							Case cVarImp $ "725" // RET IVA AL 30%
								n725 += nVlrRV0
							case cVarImp $ "727" // RET IVA AL 50%
								n727 += nVlrRV0
							Case cVarImp $ "729" // RET IVA AL 70%
								n729 += nVlrRV0
							Case cVarImp $ "731"  // RET IVA AL 100%
								n731 += nVlrRV0
						End case
					EndIF

					c916 := Space(7)
					n917 := 0
					c918 := Space(7)
					n919 := 0
			    Endif
			Else
				cCodPrd := Iif(!Empty(IMPOSTO->D1_COD),IMPOSTO->D1_COD,IMPOSTO->D2_COD)
				If IMPOSTO->F3_TIPOMOV == "V" .And. nVlrICE > 0 .And. c301 == Alltrim(cCodPrd)
					n399 += nVlrICE
					n303 += nBasICE
				Endif

				If Alltrim(IMPOSTO->F3_ESPECIE) $ "NCC" .And. nNCC < 4
						If cNotaAnt <> IMPOSTO->F3_NFISCAL
							nNcc++
						EndIf
						If nNcc == 1
							c908 := IMPOSTO->F3_NFISCAL
							n909 := n909 + nVlrICE
						ElseIf nNcc == 2
							c910 := IMPOSTO->F3_NFISCAL
							n911 := n911 + nVlrICE
						ElseIf nNcc == 3
							c912 := IMPOSTO->F3_NFISCAL
							n913 := n913 + nVlrICE
						ElseIf nNcc == 4
							c914 := IMPOSTO->F3_NFISCAL
							n915 := n915 + nVlrICE
						Endif
					cNotaAnt := IMPOSTO->F3_NFISCAL
				Endif
			Endif
			IMPOSTO->(DbSkip())
		End
		//********************************************************************************
		//Totalizador - Resumo de Vendas e outras operacoes do periodo da declaracao
		//********************************************************************************
		//Valor Bruto - Valor Liquido
		n411 := n401Vlr - n411
		n412 := n402 - n412
		n413 := n403 - n413
		n414 := n404 - n414
		n415 := n405 - n415
		n416 := n406 - n416
		n417 := n407 - n417
		n418 := n408 - n418
		//Imposto Gerado - Vendas Locais excluindo ativos fixos gravados com aliquota 12%
		n421 := ( n411 / 100 ) * 12
		//Imposto Gerado - Vendas Locais de ativos fixos gravados com aliquota 12%
		n422 := ( n412 / 100 ) * 12
		//Totalizador Valor Bruto - Vendas e Outras operacoes
		n409 := n401Vlr + n402 + n403 + n404 + n405 + n406 + n407 + n408
		//Totalizador Valor Neto - Vendas e Outras operacoes
		n419 := n411 + n412 + n413 + n414 + n415 + n416 + n417 + n418
		//Totalizador - Imposto Gerado
		n429 := n421 + n422
		//********************************************************************************
		//Apuracao do IVA no mês - Saídas
		//********************************************************************************
		//Total Transferencia gravadas a 12% deste mês
		n480 := n419
		//Total Transferencia gravadas a 12% deste mês, a crédito(que ainda não pagaram)-Campo nao sera tratado pelo sistema, sera efetuado manualmente
		n481 := 0
		//Total Imposto Gerado
		n482 := n429
		If lArqAnt
			//Imposto a apurar do período anterior
			n483 := FPerAnt(cArqAnt,"429")
		Endif
		//Imposto a apurar deste mês
		n484 := n429
		//Imposto a transportar para o proximo mês
		n485 := n482 - n484
		//Total do Imposto a liquidar neste mês
		n499 := n483 + n484

		//********************************************************************************
		//Resumo das aquisicoes e pagamentos do período da declaracao
		//********************************************************************************
		//Totalizador Aquisicoes de pagamentos - Valor Bruto
		n509 := n500 + n501 + n502 + n503 + n504 + n505 + n506 + n507
		//Valor Bruto - Valor Liquido
		n511 := n501 - n511
		n512 := n502 - n512
		n513 := n503 - n513
		n514 := n504 - n514
		n515 := n505 - n515
		n516 := n506 - n516
		n517 := n507 - n517
		//Totalizador Aquisicoes de pagamentos - Valor Neto
		n519 := n510 + n511 + n512 + n513 + n514 + n515 + n516 + n517 + n518
		//Imposto Gerado - Aquisicoes e pagamentos excluindos ativos fixos gravados com aliquotas 12%(com direito a credito)

		n521 := ( n511 * nAlqIVA ) / 100 // 12
		//Imposto Gerado - Aquisicoes e pagamentos de ativos fixos gravados com aliquotas 12%(com direito a credito)
		n522 := ( n512 / 100 ) * 12
		//Imposto Gerado - Aquisicoes e pagamentos com aliquotas 12%(sem direito a credito)
		n523 := ( n513 / 100 ) * 12
		//Imposto Gerado - Importacao de bens excluindos ativos fixos gravados com aliquotas 12%
		n524 := ( n514 / 100 ) * 12
		//Imposto Gerado - Importacao de bens de ativos fixos gravados com aliquotas 12%
		n525 := ( n515 / 100 ) * 12
		//Totalizador do Imposto
		n529 := n520 + n521 + n522 + n523 + n524 + n525

		//Credito tributario aplicado no periodo
		n554 := ( n521 + n522 + n524 + n525 ) * n553
		//********************************************************************************
		//Resumo Impositivo: Agente de Retencao
		//********************************************************************************
		//Imposto a pagar
		If n499 - n554 > 0
			n601 := n499 - n554
		Endif
		//Credito do Periodo
		If n499 - n554 < 0
			n602 := n499 - n554
		Endif
		If lArqAnt
			//Saldo do periodo anterior:Aquisicao e Importacao
			n605 := FPerAnt(cArqAnt,"615")
			//saldo do periodo anterior:Retencao de IVA
			n607 := FPerAnt(cArqAnt,"617")
		Endif
		//Credito para o proximo periodo - por aquisicoes e importacoes
		n615 := 0
		//Credito para o proximo periodo - por retencoes de IVA
		n617 := 0
		//Subtotal a Pagar
		If (( n601 - n602 - n605 - n607 - n609 ) + n611) > 0
			n619 := ( n601 - n602 - n605 - n607 - n609 ) + n611
		Endif
		//Total imposto a pagar por percepcao
		n699 := n619 + n621

		//********************************************************************************
		//Agente de Retencao do IVA
		//********************************************************************************
		//Total do Imposto a pagar por retencao
		n799 := n721 + n723 + n725 + N727 + N729 + N731 // sumatorias de ret de IVA
		//Total consolidado do IVA
		n859 := n699 + n799
		//Se a opcao do Wizard for Substitutiva
		If Substr(cTipDec,1,1) == "S"
			//Imposto pago
			n897 := nImpPag
			//Mora / Interesses
			n898 := nMorInt
			//Multa / Juros
			n899 := nMulJur
			//Pagamento efetuado
			n890 := n897 + n898 + n899
		Endif
		//Total de Imposto a Pagar
		n902 := n859 - n897
		//Interesses por Mora
		n903 := MV_PAR15
		//Multas
		n904 := MV_PAR16
		//Total a Pagar
		n999 := n902 + n903 + n904
		//Mediantes Notas de Credito
		n907 := (n909 + n911 + n913 + n915)*(12/100)
		//Mediante Compensacoes
		n906 := n917 + n919
		//Mediante cheque, debito bancario, efetivo ou outras formas de pagamento
		n905 := n999 - n906 - n907

		//Atualiza com o codigo do produto ICE
		If cTipImp == "ICE" .And. SB1->(FieldPos("B1_CODICE"))>0
			c301 := Alltrim(Posicione("SB1",1,xFilial("SB1")+AvKey(c301,"B1_COD"),"B1_CODICE"))//Descricao do Produto
		Endif

		If cTipImp $ "IVA|IVT"
			aAdd(apTabApu,{""     ,STR0039                    ,        ,Space(20),.F.}) //"Resumo de vendas e outras operações do período da declaração"
			aAdd(apTabApu,{"401"  ,STR0040+STR0042            ,n401Bas ,Space(20),.F.}) //"Vlr.Bruto"###"Vendas locais excluindo ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"402"  ,STR0040+STR0043            ,n402    ,Space(20),.F.}) //"Vlr.Bruto"###"Vendas de ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"403"  ,STR0040+STR0044            ,n403    ,Space(20),.F.}) //"Vlr.Bruto"###"Vendas locais excluindo ativos fixos gravados com alíquota 0% que não dão direito a crédito"
			aAdd(apTabApu,{"404"  ,STR0040+STR0045            ,n404    ,Space(20),.F.}) //"Vlr.Bruto"###"Vendas de ativos fixos gravados com alíquota 0% que não dão direito a crédito"
			aAdd(apTabApu,{"405"  ,STR0040+STR0046            ,n405    ,Space(20),.F.}) //"Vlr.Bruto"###"Vendas locais excluindo ativos fixos gravados com alíquota 0% que dão direito a crédito"
			aAdd(apTabApu,{"406"  ,STR0040+STR0047            ,n406    ,Space(20),.F.}) //"Vlr.Bruto"###"Vendas de ativos fixos gravados com alíquota 0% que dão direito a crédito"
			aAdd(apTabApu,{"407"  ,STR0040+STR0048            ,n407    ,Space(20),.F.}) //"Vlr.Bruto"###""Vendas exportações de Bens"
			aAdd(apTabApu,{"408"  ,STR0040+STR0049            ,n408    ,Space(20),.F.}) //"Vlr.Bruto"###""Vendas exportações de serviços"
			aAdd(apTabApu,{"409"  ,STR0051+STR0040            ,n409    ,Space(20),.F.}) //"Totalizador - Vendas e outras operações"###"Vlr.Bruto"
			aAdd(apTabApu,{"411"  ,STR0041+STR0042            ,n411    ,Space(20),.F.}) //"Vlr.Liquido"###"Vendas locais excluindo ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"412"  ,STR0041+STR0043            ,n412    ,Space(20),.F.}) //"Vlr.Liquido"###"Vendas de ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"413"  ,STR0041+STR0044            ,n413    ,Space(20),.F.}) //"Vlr.Liquido"###"Vendas locais excluindo ativos fixos gravados com alíquota 0% que não dão direito a crédito"
			aAdd(apTabApu,{"414"  ,STR0041+STR0045            ,n414    ,Space(20),.F.}) //"Vlr.Liquido"###"Vendas de ativos fixos gravados com alíquota 0% que não dão direito a crédito"
			aAdd(apTabApu,{"415"  ,STR0041+STR0046            ,n415    ,Space(20),.F.}) //"Vlr.Liquido"###"Vendas locais excluindo ativos fixos gravados com alíquota 0% que dão direito a crédito"
			aAdd(apTabApu,{"416"  ,STR0041+STR0047            ,n416    ,Space(20),.F.}) //"Vlr.Liquido"###"Vendas de ativos fixos gravados com alíquota 0% que dão direito a crédito"
			aAdd(apTabApu,{"417"  ,STR0041+STR0048            ,n417    ,Space(20),.F.}) //"Vlr.Liquido"###""Vendas exportações de Bens"
			aAdd(apTabApu,{"418"  ,STR0041+STR0049            ,n418    ,Space(20),.F.}) //"Vlr.Liquido"###""Vendas exportações de serviços"
			aAdd(apTabApu,{"419"  ,STR0051+STR0041            ,n419    ,Space(20),.F.}) //"Totalizador - Vendas e outras operações"###"Vlr.Liquido"
			aAdd(apTabApu,{"421"  ,STR0140+STR0052            ,n421    ,Space(20),.F.}) //"Imposto gerado"###"Vlr.Liquido"
			aAdd(apTabApu,{"422"  ,STR0140+STR0053            ,n422    ,Space(20),.F.}) //"Imposto gerado"###"Vlr.Liquido"
			aAdd(apTabApu,{"429"  ,STR0054                    ,n429    ,Space(20),.F.}) //"Totalizador - Imposto gerado"
			aAdd(apTabApu,{"431"  ,STR0055                    ,n431    ,Space(20),.F.}) //"Transferência não objeto de IVA"

			aAdd(apTabApu,{"434"  ,STR0156                   ,n434    ,Space(20),.F.}) //"Transferência não objeto de IVA"
			aAdd(apTabApu,{"444"  ,STR0157                   ,n444    ,Space(20),.F.}) //"Transferência não objeto de IVA"

			aAdd(apTabApu,{""     ,STR0056                    ,        ,Space(20),.F.}) //"Apuração do IVA no mês - Saída"
			aAdd(apTabApu,{"480"  ,STR0057                    ,n480    ,Space(20),.F.}) //"Total transferência gravadas a 12% deste mês"
			aAdd(apTabApu,{"481"  ,STR0058                    ,n481    ,Space(20),.F.}) //"Total transferência gravadas a 12% deste mês, a crédito"
			aAdd(apTabApu,{"482"  ,STR0059                    ,n482    ,Space(20),.F.}) //"Total - Imposto gerado"
			aAdd(apTabApu,{"483"  ,STR0060                    ,n483    ,Space(20),.F.}) //"Imposto a apurar do período anterior"
			aAdd(apTabApu,{"484"  ,STR0061                    ,n484    ,Space(20),.F.}) //"Imposto a apurar deste mês"
			aAdd(apTabApu,{"485"  ,STR0062                    ,n485    ,Space(20),.F.}) //"Imposto a transportar para o próximo mês"
			aAdd(apTabApu,{"499"  ,STR0063                    ,n499    ,Space(20),.F.}) //"Total do imposto a liquidar neste mês"
			aAdd(apTabApu,{""     ,STR0064                    ,        ,Space(20),.F.}) //"Resumo das aquisições e pagamentos do período da declaração"
			aAdd(apTabApu,{"500"  ,STR0040+ STR0163+"-"+STR0067+STR0065,n500    ,Space(20),.F.}) //Vlr.bruto###"Aquisições e pagamentos excluindo ativos fixos gravados com alíquota 12%"###"(com direito a crédito)"
			aAdd(apTabApu,{"502"  ,STR0040+"-"+STR0068+STR0065,n502    ,Space(20),.F.}) //Vlr.bruto###"Aquisições e pagamentos de ativos fixos gravados com alíquota 12%"###"(com direito a crédito)"
			aAdd(apTabApu,{"503"  ,STR0040+"-"+STR0069+STR0066,n503    ,Space(20),.F.}) //Vlr.bruto###"Aquisições e pagamentos com alíquota 12%"###"(sem direito a crédito)"
			aAdd(apTabApu,{"504"  ,STR0040+"-"+STR0070        ,n504    ,Space(20),.F.}) //Vlr.bruto###"Importação de bens excluindo ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"505"  ,STR0040+"-"+STR0071        ,n505    ,Space(20),.F.}) //Vlr.bruto###"Importação de ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"506"  ,STR0040+"-"+STR0072        ,n506    ,Space(20),.F.}) //Vlr.bruto###"Importação de bens incluindo ativos fixos gravados com alíquota 0%"
			aAdd(apTabApu,{"507"  ,STR0040+"-"+STR0073        ,n507    ,Space(20),.F.}) //Vlr.bruto###"Aquisições e pagamentos incluindo ativos fixos gravados com alíquota 0%"
			aAdd(apTabApu,{"509"  ,STR0074+"-"+STR0040        ,n509    ,Space(20),.F.}) //"Totalizador - Aquisições e pagamentos"###Vlr.bruto
			aAdd(apTabApu,{"510"  ,STR0041+"-"+STR0067+STR0065 ,n510    ,Space(20),.F.}) //Vlr.Liquido###"Aquisições e pagamentos excluindo ativos fixos gravados com alíquota 12%"###"(com direito a crédito)"
			aAdd(apTabApu,{"512"  ,STR0041+"-"+STR0068+STR0065,n512    ,Space(20),.F.}) //Vlr.Liquido###"Aquisições e pagamentos de ativos fixos gravados com alíquota 12%"###"(com direito a crédito)"
			aAdd(apTabApu,{"513"  ,STR0041+"-"+STR0069+STR0066,n513    ,Space(20),.F.}) //Vlr.Liquido###"Aquisições e pagamentos com alíquota 12%"###"(sem direito a crédito)"
			aAdd(apTabApu,{"514"  ,STR0041+"-"+STR0070        ,n514    ,Space(20),.F.}) //Vlr.Liquido###"Importação de bens excluindo ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"515"  ,STR0041+"-"+STR0071        ,n515    ,Space(20),.F.}) //Vlr.Liquido###"Importação de ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"516"  ,STR0041+"-"+STR0072        ,n516    ,Space(20),.F.}) //Vlr.Liquido###"Importação de bens incluindo ativos fixos gravados com alíquota 0%"
			aAdd(apTabApu,{"517"  ,STR0041+"-"+STR0073        ,n517    ,Space(20),.F.}) //Vlr.Liquido###"Aquisições e pagamentos incluindo ativos fixos gravados com alíquota 0%"
			aAdd(apTabApu,{"518"  ,STR0041+"-"+STR0075        ,n518    ,Space(20),.F.}) //Vlr.Liquido###"Aquisições contribuintes RISE"
			aAdd(apTabApu,{"519"  ,STR0074+"-"+STR0041        ,n519    ,Space(20),.F.}) //"Totalizador - Aquisições e pagamentos"###Vlr.Liquido
			aAdd(apTabApu,{"520"  ,STR0140+"-"+STR0067+STR0065,n520    ,Space(20),.F.}) //"Imposto gerado"###"Aquisições e pagamentos excluindo ativos fixos gravados com alíquota 12%"###"(com direito a crédito)"
			aAdd(apTabApu,{"522"  ,STR0140+"-"+STR0068+STR0065,n522    ,Space(20),.F.}) //"Imposto gerado"###"Aquisições e pagamentos de ativos fixos gravados com alíquota 12%"###"(com direito a crédito)"
			aAdd(apTabApu,{"523"  ,STR0140+"-"+STR0069+STR0066,n523    ,Space(20),.F.}) //"Imposto gerado"###"Aquisições e pagamentos com alíquota 12%"###"(sem direito a crédito)"
			aAdd(apTabApu,{"524"  ,STR0140+"-"+STR0070        ,n524    ,Space(20),.F.}) //"Imposto gerado"###"Importação de bens excluindo ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"525"  ,STR0140+"-"+STR0071        ,n525    ,Space(20),.F.}) //"Imposto gerado"###"Importação de ativos fixos gravados com alíquota 12%"
			aAdd(apTabApu,{"529"  ,STR0054                    ,n529    ,Space(20),.F.}) //"Totalizador - Imposto gerado"
			aAdd(apTabApu,{"531"  ,STR0076                    ,n531    ,Space(20),.F.}) //"Aquisições não objeto de IVA"

			aAdd(apTabApu,{"532"  ,STR0153                   ,n532    ,Space(20),.F.}) //"Transferência não objeto de IVA"
			aAdd(apTabApu,{"543"  ,STR0155                   ,n543    ,Space(20),.F.}) //"Transferência não objeto de IVA"
			aAdd(apTabApu,{"544"  ,STR0159                   ,n544    ,Space(20),.F.}) //"Transferência não objeto de IVA"

			aAdd(apTabApu,{"554"  ,STR0078                    ,n554    ,Space(20),.F.}) //"Crédito tributário aplicado no período"
			aAdd(apTabApu,{""     ,STR0079                    ,        ,Space(20),.F.}) //"Resumo impositivo: Agente de percepção do IVA"
			aAdd(apTabApu,{"601"  ,STR0080                    ,n601    ,Space(20),.F.}) //"Imposto a pagar"
			aAdd(apTabApu,{"602"  ,STR0081                    ,n602    ,Space(20),.F.}) //"Crédito do período"
			aAdd(apTabApu,{"605"  ,STR0082+":"+STR0083        ,n605    ,Space(20),.F.}) //"Saldo período anterior"###"por aquisições e importações"
			aAdd(apTabApu,{"607"  ,STR0082+":"+STR0084        ,n607    ,Space(20),.F.}) //"Saldo período anterior"###"retenção de IVA"
			aAdd(apTabApu,{"609"  ,STR0085                    ,n609    ,Space(20),.F.}) //"Retenção do IVA que tenham sido efetuadas no período"
			aAdd(apTabApu,{"611"  ,STR0086                    ,n611    ,Space(20),.F.}) //"Ajuste por devolução de IVA ou IVA rejeitado que gera crédito no mês"
			aAdd(apTabApu,{"615"  ,STR0087+":"+STR0083        ,n615    ,Space(20),.F.}) //"Credito para o próximo período"###"por aquisições e importações"
			aAdd(apTabApu,{"617"  ,STR0087+":"+STR0084        ,n617    ,Space(20),.F.}) //"Credito para o próximo período"###"retenção de IVA"
			aAdd(apTabApu,{"619"  ,STR0088                    ,n619    ,Space(20),.F.}) //"Subtotal a pagar"
			aAdd(apTabApu,{"621"  ,STR0089                    ,n621    ,Space(20),.F.}) //"IVA presuntivo de salas de jogos(bingos)ou outros jogos de azar."
			aAdd(apTabApu,{"699"  ,STR0090                    ,n699    ,Space(20),.F.}) //"Total do imposto a pagar por percepção"
			aAdd(apTabApu,{""     ,STR0141                    ,        ,Space(20),.F.}) //"Agente de retenção IVA"
			aAdd(apTabApu,{"721"  ,STR0160                    ,n721    ,Space(20),.F.}) //"Retenções de IVA 10%"
			aAdd(apTabApu,{"723"  ,STR0161                    ,n723    ,Space(20),.F.}) //"Retenções de IVA 20%"
			aAdd(apTabApu,{"725"  ,STR0091                    ,n725    ,Space(20),.F.}) //"Retenções de IVA 30%"
			aAdd(apTabApu,{"727"  ,STR0091                    ,n727    ,Space(20),.F.}) //"Retenções de IVA 50%"
			aAdd(apTabApu,{"729"  ,STR0092                    ,n729    ,Space(20),.F.}) //"Retenções de IVA 70%"
			aAdd(apTabApu,{"731"  ,STR0093                    ,n731    ,Space(20),.F.}) //"Retenções de IVA 100%"
			aAdd(apTabApu,{"799"  ,STR0094                    ,n799    ,Space(20),.F.}) //"Total do imposto a pagar por retenções"
			aAdd(apTabApu,{"859"  ,STR0095                    ,n859    ,Space(20),.F.}) //"Total consolidado do IVA"
			aAdd(apTabApu,{"890"  ,STR0097+STR0096            ,n890    ,Space(20),.F.}) //"Pagamento feito"###"(substitutiva)"
			aAdd(apTabApu,{"897"  ,STR0098+STR0096            ,n897    ,Space(20),.F.}) //"Imposto pago"###"(se substitutiva)"
			aAdd(apTabApu,{"898"  ,STR0027+STR0096            ,n898    ,Space(20),.F.}) //"Mora / Interesses"###"(se substitutiva)"
			aAdd(apTabApu,{"899"  ,STR0028+STR0096            ,n899    ,Space(20),.F.}) //"Multa / Juros"###"(se substitutiva)"
			aAdd(apTabApu,{"902"  ,STR0100                    ,n902    ,Space(20),.F.}) //"Total de imposto a pagar"
			aAdd(apTabApu,{"903"  ,STR0101                    ,n903    ,Space(20),.F.}) //"Interesses por Mora"
			aAdd(apTabApu,{"904"  ,STR0102                    ,n904    ,Space(20),.F.}) //"Multas"
			aAdd(apTabApu,{"999"  ,STR0103                    ,n999    ,Space(20),.F.}) //"Total a pagar"
			aAdd(apTabApu,{"905"  ,STR0104                    ,n905    ,Space(20),.F.}) //"Mediante cheque, débito bancário, efetivo ou outras formas de pagamento"
			aAdd(apTabApu,{"906"  ,STR0105                    ,n906    ,Space(20),.F.}) //"Mediante compensações"
		Else
			aAdd(apTabApu,{""     ,STR0137,                   ,        ,Space(20),.F.})//"Identificacao do Imposto"
			aAdd(apTabApu,{"303"  ,STR0117                    ,n303    ,Space(20),.F.})//"Base de Calculo"
			aAdd(apTabApu,{"399"  ,STR0118                    ,n399    ,Space(20),.F.})//"ICE a pagar"
			aAdd(apTabApu,{""     ,STR0138                    ,        ,Space(20),.F.})//"Valores a Pagar"
			aAdd(apTabApu,{"901"  ,STR0080                    ,n901    ,Space(20),.F.})//"Imposto a Pagar"
			aAdd(apTabApu,{"902"  ,STR0100                    ,n902    ,Space(20),.F.})//"Total do imposto a Pagar"
			aAdd(apTabApu,{"903"  ,STR0101                    ,n903    ,Space(20),.F.})//"Interesses por Mora"
			aAdd(apTabApu,{"904"  ,STR0102                    ,n904    ,Space(20),.F.})//"Multa"
			aAdd(apTabApu,{"999"  ,STR0139                    ,n999    ,Space(20),.F.})//"Total do Pagamento"
			aAdd(apTabApu,{"905"  ,STR0104                    ,n905    ,Space(20),.F.}) //"Mediante cheque, débito bancário, efetivo ou outras formas de pagamento"
		Endif

		aAdd(apTabApu,{"907"  ,STR0106                    ,n907    ,Space(20),.F.}) //"Mediante notas de crédito"
		aAdd(apTabApu,{""     ,STR0107                    ,        ,Space(20),.F.}) //"Detalhes das notas de crédito"
		aAdd(apTabApu,{"908"  ,STR0108+Space(1)+c908      ,        ,Space(20),.F.}) //"Número Nota de Crédito"
		aAdd(apTabApu,{"909"  ,STR0109                    ,n909    ,Space(20),.F.}) //"Valor das nota de crédito"
		aAdd(apTabApu,{"910"  ,STR0108+Space(1)+c910      ,        ,Space(20),.F.}) //"Número Nota de Crédito"
		aAdd(apTabApu,{"911"  ,STR0109                    ,n911    ,Space(20),.F.}) //"Valor das nota de crédito"
		aAdd(apTabApu,{"912"  ,STR0108+Space(1)+c912      ,        ,Space(20),.F.}) //"Número Nota de Crédito"
		aAdd(apTabApu,{"913"  ,STR0109                    ,n913    ,Space(20),.F.}) //"Valor das nota de crédito"
		aAdd(apTabApu,{"915"  ,STR0109                    ,n915    ,Space(20),.F.}) //"Valor das nota de crédito"
		aAdd(apTabApu,{"916"  ,STR0151+Space(1)+c916      ,        ,Space(20),.F.}) //"Número Nota de Crédito"
		aAdd(apTabApu,{"917"  ,STR0152                    ,n917    ,Space(20),.F.}) //"Valor das nota de crédito"
		aAdd(apTabApu,{"918"  ,STR0151+Space(1)+c918      ,        ,Space(20),.F.}) //"Número Nota de Crédito"
		aAdd(apTabApu,{"919"  ,STR0152                    ,n919    ,Space(20),.F.}) //"Valor das nota de crédito"

	Endif

	Define MsDialog oDlgApur Title STR0001 From 000,000 TO 600,800 Pixel //"Apuração de impostos"

		@ 005,005 Group oGrpImps To 195,392 Label STR0001 Of oDlgApur Pixel 	//"Apuração de Impostos"

		oGetDadosImp := MsNewGetDados():New(030,010,187,387,nlGetDOpc,"AllwaysTrue","AllWaysTrue",,apAlter,,Len(apTabApu),"AllWaysTrue",,"AllWaysTrue",oGrpImps,aHeader,apTabApu)
		oGetDadosImp:LEDITLINE:= .F.

		@ 200,005 Group oGrpImps To 250,392 Label STR0142 Of oDlgApur Pixel	//"Informações Complementares"
		If cTipImp == "ICE"
			@ 210,010 ScrollBox oScroll VERTICAL BORDER Size 35,377 Pixel Of oDlgApur

			@ 005,010 Say STR0115 Pixel Of oScroll //"Código do produto"
			@ 005,090 Say c301 Font oFont Pixel Of oScroll

			@ 020,010 Say STR0116 Pixel Of oScroll //"Descrição do produto"
			@ 020,090 Say c302 Font oFont Pixel Of oScroll
		EndIf

		oBtn02 := SButton():New(280,330,1, {|| lConfirma:=.T.,oDlgApur:End()	},,llMonGet)
		oBtn03 := SButton():New(280,360,2, {|| oDlgApur:End()         		},,.T.)

	Activate MsDialog oDlgApur Centered

	aImpIVAICE := {}
	For nCont := 1 To 200
		aAdd(aImpIVAICE,"")
	Next

	If lConfirma
		//Gera XML
		If lGerXML

			aAdd( aLogApuImp , STR0146 + Space(1) + cTipImp )                                   //"Geração XML refrente a apuração"
			aImpIVAICE[1] := STR0120                                                             //001-"<?xml version='1.0' encoding='ISO-8859-1'?>"
			aImpIVAICE[2] := STR0121 + '"' + Alltrim(cVerFor) + '"' + STR0133                            //002-"<formulario version="###">"                     ***Versao formulario***
			aImpIVAICE[3] := STR0122                                                             //003-"<cabecera>"
			aImpIVAICE[4] := STR0123+Alltrim(cVersao) + STR0124                            //004-"<codigo_version>"###"</codigo_version>          ***Cod.Versao formulario***
			aImpIVAICE[5] := STR0125+Alltrim(c201) + STR0126                                       //005-"<ruc>"###"</ruc>"-->Ruc Contador
			aImpIVAICE[6] := STR0127+Alltrim( str( nMoeda ) ) + STR0128                                //006-"<codigo_moneda>"###"</codigo_moneda>-->Moeda
			aImpIVAICE[7] := STR0129                                                             //007-"</cabecera>"
			aImpIVAICE[8] := STR0130                                                             //008-"<detalle>"

			If cTipImp $ "IVA|IVT"
				aImpIVAICE[9]  := STR0131+'"31"' +STR0133+Alltrim(Substr(cTipDec,1,1))+STR0132     //009-"<campo numero = '"###">"###"</campo>"           ***Tipo Declaracao***
				aImpIVAICE[10] := STR0131+'"101"'+STR0133+Alltrim(c101)+STR0132                   //010-"<campo numero = '"###">"###"</campo>"           ***Mês da Geracao
				aImpIVAICE[11] := STR0131+'"102"'+STR0133+Alltrim(c102)+STR0132                   //011-"<campo numero = '"###">"###"</campo>"           ***Ano da Geracao
				aImpIVAICE[12] := STR0131+'"104"'+STR0133+Alltrim(c104)+STR0132                   //012-"<campo numero = '"###">"###"</campo>"           ***Num.formulario
				aImpIVAICE[13] := STR0131+'"198"'+STR0133+Alltrim(c198)+STR0132                   //013-"<campo numero = '"###">"###"</campo>"           ***ID Representante Legal
				aImpIVAICE[14] := STR0131+'"199"'+STR0133+Alltrim(c199)+STR0132                   //014-"<campo numero = '"###">"###"</campo>"           ***RUC Contador
				aImpIVAICE[15] := STR0131+'"201"'+STR0133+Alltrim(c201)+STR0132                   //015-"<campo numero = '"###">"###"</campo>"           ***RUC Empresa(Sigamat)
				aImpIVAICE[16] := STR0131+'"202"'+STR0133+Alltrim(c202)+STR0132                   //016-"<campo numero = '"###">"###"</campo>"           ***Razao Social(Sigamat)			aAdd(aImpIVAICE,STR0131+'"401"'+STR0133+Transform(n401,"@E 999,999,999.99")+STR0132) //017-"<campo numero = '"###">"###"</campo>"           ***Valor Bruto - Vendas Locais excluindo ativos fixos gravados com aliquota 12%
				nPos := 16

				If Len(oGetDadosImp:ACOLS) > 0
					For nCont := 1 To Len(oGetDadosImp:ACOLS)
						If !Empty(oGetDadosImp:ACOLS[nCont][1])
							nPos++
							If oGetDadosImp:ACOLS[nCont][1] == "434"
								aImpIVAICE[nPos] := STR0131+'"434"'+STR0133+alltrim(StrTran(Transform(n434,"@E 999999999.99"),",","."))+STR0132 //"<campo numero = '"###">"###"</campo>"           ***Nao tratado no Sistema(Informativo)

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "444"
								aImpIVAICE[nPos] := STR0131+'"444"'+STR0133+alltrim(StrTran(Transform(n444,"@E 999999999.99"),",","."))+STR0132 //"<campo numero = '"###">"###"</campo>"           ***Nao tratado no Sistema(Informativo)

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "532"
								aImpIVAICE[nPos] := STR0131+'"532"'+STR0133+alltrim(StrTran(Transform(n532,"@E 999999999.99"),",","."))+STR0132 //"<campo numero = '"###">"###"</campo>"           ***Nao sera tratado pelo sistema por ser informativo.Devera ser informado manualmente.

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "543"
								aImpIVAICE[nPos] := STR0131+'"543"'+STR0133+alltrim(StrTran(Transform(n543,"@E 999999999.99"),",","."))+STR0132 //"<campo numero = '"###">"###"</campo>"           ***Nao sera tratado pelo sistema por ser informativo.Devera ser informado manualmente.

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "544"
								aImpIVAICE[nPos] := STR0131+'"544"'+STR0133+alltrim(StrTran(Transform(n544,"@E 999999999.99"),",","."))+STR0132 //-"<campo numero = '"###">"###"</campo>"           ***Nao sera tratado pelo sistema por ser informativo.Devera ser informado manualmente.

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "908"
								aImpIVAICE[nPos] := STR0131+'"908"'+STR0133+Alltrim(c908)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***Numero Nota de Credito 1

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "910"
								aImpIVAICE[nPos] := STR0131+'"910"'+STR0133+Alltrim(c910)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***Numero Nota de Credito 2

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "912"
								aImpIVAICE[nPos] := STR0131+'"912"'+STR0133+Alltrim(c912)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***Numero Nota de Credito 3

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "916"
								aImpIVAICE[nPos] := STR0131+'"916"'+STR0133+Alltrim(c916)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***Numero da Compensacao 1

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "917"
								aImpIVAICE[nPos] := STR0131+'"917"'+STR0133+alltrim(StrTran(Transform(n917,"@E 999999999.99"),",","."))+STR0132 //"<campo numero = '"###">"###"</campo>"           ***Valor da Compensacao 1

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "918"
								aImpIVAICE[nPos] := STR0131+'"918"'+STR0133+Alltrim(c918)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***Numero da  Compensacao 2

							ElseIf oGetDadosImp:ACOLS[nCont][1] == "919"
								aImpIVAICE[nPos] := STR0131+'"919"'+STR0133+alltrim(StrTran(Transform(n919,"@E 999999999.99"),",","."))+STR0132 //"<campo numero = '"###">"###"</campo>"           ***Valor da  Compensacao 2
							Else
								aImpIVAICE[nPos] := STR0131+'"'+oGetDadosImp:ACOLS[nCont][1]+'"'+STR0133+AllTrim(StrTran(Transform(oGetDadosImp:ACOLS[nCont][3],"@E 999999999.99"),",","."))+STR0132//"<campo numero = '"###">"###"</campo>"
							Endif
						Endif
					Next
				Endif
			Else
				aImpIVAICE[9]  := STR0131+'"101"'+STR0133+Alltrim(c101)+STR0132                       //009-"<campo numero = '"###">"###"</campo>"           ***Mês da Geracao
				aImpIVAICE[10] := STR0131+'"102"'+STR0133+Alltrim(c102)+STR0132                       //010-"<campo numero = '"###">"###"</campo>"           ***Ano da Geracao
				aImpIVAICE[11] := STR0131+'"31"' +STR0133+Alltrim(Substr(cTipDec,1,1))+STR0132         //011-"<campo numero = '"###">"###"</campo>"           ***Tipo Declaracao***
				aImpIVAICE[12] := STR0131+'"104"'+STR0133+Alltrim(c104)+STR0132                       //012-"<campo numero = '"###">"###"</campo>"           ***Num.formulario
				aImpIVAICE[13] := STR0131+'"201"'+STR0133+Alltrim(c201)+STR0132                       //013-"<campo numero = '"###">"###"</campo>"           ***RUC Empresa(Sigamat)
				aImpIVAICE[14] := STR0131+'"202"'+STR0133+Alltrim(c202)+STR0132                       //014-"<campo numero = '"###">"###"</campo>"           ***Razao Social(Sigamat)
				aImpIVAICE[15] := STR0131+'"302"'+STR0133+Alltrim(c302)+STR0132                       //015-"<campo numero = '"###">"###"</campo>"           ***Descricao do Produto
				aImpIVAICE[16] := STR0131+'"301"'+STR0133+Alltrim(c301)+STR0132                       //016-"<campo numero = '"###">"###"</campo>"           ***Codigo do Produto
				nPos := 16
				If Len(oGetDadosImp:ACOLS) > 0
					For nCont := 1 To Len(oGetDadosImp:ACOLS)
						If !Empty(oGetDadosImp:ACOLS[nCont][1])
							nPos++
							If oGetDadosImp:ACOLS[nCont][1] == "198"
								aImpIVAICE[nPos] := STR0131+'"198"'+STR0133+Alltrim(c198)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***ID Representante Legal
							ElseIf oGetDadosImp:ACOLS[nCont][1] == "199"
								aImpIVAICE[nPos] := STR0131+'"199"'+STR0133+Alltrim(c199)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***RUC Contador
							ElseIf oGetDadosImp:ACOLS[nCont][1] == "908"
								aImpIVAICE[nPos] := STR0131+'"908"'+STR0133+Alltrim(c908)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***Numero Nota de Credito 1
							ElseIf oGetDadosImp:ACOLS[nCont][1] == "910"
								aImpIVAICE[nPos] := STR0131+'"910"'+STR0133+Alltrim(c910)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***Numero Nota de Credito 2
							ElseIf oGetDadosImp:ACOLS[nCont][1] == "912"
								aImpIVAICE[nPos] := STR0131+'"912"'+STR0133+Alltrim(c912)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***Numero Nota de Credito 3
							ElseIf oGetDadosImp:ACOLS[nCont][1] == "914"
								aImpIVAICE[nPos] := STR0131+'"914"'+STR0133+Alltrim(c914)+STR0132                       //"<campo numero = '"###">"###"</campo>"           ***Numero Nota de Credito 4
							Else
								aImpIVAICE[nPos] := STR0131+'"'+oGetDadosImp:ACOLS[nCont][1]+'"'+STR0133+AllTrim(StrTran(Transform(oGetDadosImp:ACOLS[nCont][3],"@E 999999999.99"),",","."))+STR0132//"<campo numero = '"###">"###"</campo>"
							Endif
						Endif
					Next
				Endif
			Endif
			nPos++
			aImpIVAICE[nPos]:= STR0134                                                             //"</detalle>"
			nPos++
			aImpIVAICE[nPos]:= STR0135                                      	                     //"</formulario>"
		Endif
		If Len(aImpIVAICE) > 0
			For nCont:=1 To (Len(aImpIVAICE))
				If !Empty(aImpIVAICE[nCont])
					aAdd(aLogApuImp,aImpIVAICE[nCont])
					DbSelectArea("TRBXML")
					//TRBXML->(DbGoTop())
					RecLock("TRBXML",.T.)
					TRBXML->LINXML := Alltrim(aImpIVAICE[nCont])
					TRBXML->(MsUnlock())
				Endif
			Next
			aAdd(aLogApuImp,"") 	                                                           //""
			aAdd(aLogApuImp,STR0145)                                                           //"Nome do XML criado:"
			aAdd(aLogApuImp,cNomPadr)                                                          //Nome do Arquivo XML
		Endif
		LogEQUTRep(aLogApuImp,STR0136)

		If lGerTit
			MsgRun(STR0147,,{|| IIf(n999>0,aTitulos := GrvTitLoc(n999),Nil) }) //"Gerando titulo de apuração..."
		Endif

		MsgRun(STR0148,,{|| CriarArq(cNomTxt,oGetDadosImp:ACOLS,aTitulos) })//"Gerando Arquivo apuração de imposto..."

	Endif

Return cNomPadr
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GerTRBXML³ Autor ³ Marcos Kato           ³ Data ³29/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criacao do Arquivo Temporario XML                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GerTRBXML()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                      								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                     				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ IPM  			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerTRBXML()
Local aStrutXML := {}

	aStrutXML:={}
	AADD(aStrutXML,{"LINXML"	,"C",200,0})//Codigo de Regimen de Perception

	If Select("TRBXML")>0
		DbSelectArea("TRBXML")
		TRBXML->(DbCloseArea())
	Endif

	oTmpTrbXMl:= FWTemporaryTable():New("TRBXML")
	oTmpTrbXMl:SetFields( aStrutXML )
	//Creacion de la tabla
	oTmpTrbXMl:Create()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FPerant   ³ Autor ³ Marcos Kato           ³ Data ³28/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função que busca o resultado do Periodo anterior indicado  ³±±
±±³ 		 | no paramentro por meio do Codigo     	    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FPerant(cod)		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nResultado - Resultado do Arquivo Anterior                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Impostos			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FPerAnt(cArq,cCod)
Local cBuffer	:= ""
Local nResAnt	:= 0
Default cArq	:= ""
Default cCod	:= ""

	If !Empty(cArq)
		FT_FUSE(cArq)
		FT_FGOTOP()
		If File(cArq)
			While !FT_FEOF()
				cBuffer := FT_FREADLN()
				If Substr(cBuffer,9,3) == cCod
					nResAnt := Val(StrTran(Substr(cBuffer,072,22),".",""))
					Exit
				EndIf
				FT_FSKIP()
			EndDo
		EndIf
		FT_FUSE()
	Endif
Return nResAnt

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriarArq  ³ Autor ³ Marcos Kato           ³ Data ³29/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o arquivo TXT com os valores que constam na getdados  ³±±
±±³          ³ e no array do Titulo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriarArq 		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum										              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TXT  				                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriarArq(cArq,aImp,aTit)
Local cCRLF		:= Chr(13)+Chr(10)
Local nHdl		:= 0
Local nlCont	:= 0
Local cLinha	:= ""

	nHdl := fCreate(cArq)
	If nHdl <= 0
		ApMsgStop(STR0149) // "Ocorreu um erro ao criar o arquivo"
	Endif

	nlCont := 0
	For nlCont := 1 to Len(aImp)
		cLinha := "IMP"									 					+ Space(5) // Clausula que indica a linha
		cLinha += aImp[nlCont][1]			 								+ Space(5) // Codigo de linha
		cLinha += Padr(aImp[nlCont][2],50)								    + Space(5) // Descrição da linha
		cLinha += Transform(aImp[nlCont][3],"@E 999,999,999,999,999.99")	+ Space(5) // Valor da linha
		cLinha += Padr(aImp[nlCont][4],50)                              	+ Space(5) // Observação da linha

		cLinha += cCRLF
		fWrite(nHdl,cLinha)
	Next nlCont

	If Len(aTit) > 0
		cLinha := "TIT"												+ Space(5) // Clausula que indica o tipo de linha
		cLinha += Padr(aTit[1],10)									+ Space(5) // Prefixo
		cLinha += Padr(aTit[2],20)									+ Space(5) // Numero
		cLinha += Padr(aTit[3],5)									+ Space(5) // Parcela
		cLinha += Padr(aTit[4],5)									+ Space(5) // Tipo
		cLinha += Padr(aTit[5],10)									+ Space(5) // Fornecedor
		cLinha += Padr(aTit[6],5)									+ Space(5) // Loja
		cLinha += Transform(aTit[8],"@E 999,999,999,999,999.99")	+ Space(5) // Valor do Imposto
		cLinha += cCRLF
		fWrite(nHdl,cLinha)
	Endif

	If nHdl > 0
		fClose(nHdl)
	Endif

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ApurTXT   ³ Autor ³ Marcos Kato           ³ Data ³29/07/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Excluir o titulo de apuração para o governo,no financeiro  ³±±
±±³          ³ e carrega a apuracao anterior							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ApurTXT() 		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum								  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet- Se .T. Foi excluido. Se .F. não foi possivel excluir ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ler o TXT			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ApurTXT(cNomArq)
Local   lRet        := .T.
Local   cBuffer     := ""
Local   aDadosSE2   := {}

Private lMsErroAuto := .F.

	If File(cNomArq)
		FT_FUSE(cNomArq)
		FT_FGOTOP()
		Do While !FT_FEOF()
			cBuffer := FT_FREADLN()
			If Substr(cBuffer,1,3) = "TIT"
				aAdd(aDadosSE2,{"E2_FILIAL" ,xFilial("SE2"),nil})
				aAdd(aDadosSE2,{"E2_PREFIXO",Substr(cBuffer,09,TamSX3("E2_PREFIXO")[1])	,nil})
				aAdd(aDadosSE2,{"E2_NUM"    ,Substr(cBuffer,24,TamSX3("E2_NUM")[1])		,nil})
				aAdd(aDadosSE2,{"E2_PARCELA",Substr(cBuffer,49,TamSX3("E2_PARCELA")[1])	,nil})
				aAdd(aDadosSE2,{"E2_TIPO"   ,Substr(cBuffer,59,TamSX3("E2_TIPO")[1])	,nil})
				aAdd(aDadosSE2,{"E2_FORNECE",Substr(cBuffer,69,TamSX3("E2_FORNECE")[1])	,nil})
				aAdd(aDadosSE2,{"E2_LOJA"   ,Substr(cBuffer,84,TamSX3("E2_LOJA")[1])	,nil})

				aArea := GetArea()
					DbSelectArea("SE2")
					SE2->(DbSetOrder(1))//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
					SE2->(DbGoTop())
					If SE2->(DbSeek(xFilial("SE2")+AvKey(aDadosSE2[2][2],"E2_PREFIXO")+AvKey(aDadosSE2[3][2],"E2_NUM")+AvKey(aDadosSE2[4][2],"E2_PARCELA")+;
						AvKey(aDadosSE2[5][2],"E2_TIPO")+AvKey(aDadosSE2[6][2],"E2_FORNECE")+AvKey(aDadosSE2[7][2],"E2_LOJA")))
						MsExecAuto({|x,y,z| FINA050(x,y,z)},aDadosSE2,,5)
						If lMsErroAuto
			       			MostraErro()
			       			lRet := .F.
				  		Endif
					Endif
				RestArea(aArea)
			ElseIf Substr(cBuffer,1,3) = "IMP"
				aAdd(apTabApu,{	Substr(cBuffer,009,03) 			,; 	// Codigo da linha
								Iif(Empty(Substr(cBuffer,009,03)),Substr(cBuffer,014,50),Substr(cBuffer,017,50)),; 	// Descricao da linha
								Val(StrTran(StrTran(Substr(cBuffer,072,22),".",""),",",".")),;// Valor da linha
								Substr(cBuffer,099,50) 			,; 	// Observações da linha
								.F.	})
			Endif
			FT_FSKIP()
		EndDo
		FT_FUSE()
		If lRet
			fErase(cNomArq)
		Endif
	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³LocEQUTRepº Autor ³ Marcos Kato        º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Montagem do relatorio Arquivo Magnetico          		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LogEQUTRep(aLogEqu,cTitulo)
Local oReport
Local aArea	  := GetArea()

Default cTitulo := ""
Default aLogEqu := {}

	If Len(aLogEqu)>0
		oReport := LOCEQULOG(aLogEqu,cTitulo) //TREPORT
		oReport:PrintDialog()
	Endif

RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocEQULog ºAutor  ³Marcos Kato         º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Estrtura do Relatorio em TREPORT                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LOCEQULOG(aLogArq,cTitulo)
Local oReport
Local oSection
Local cPerg  	:= ""
Local aOrd		:= {}
Local cDesc	  	:= cTitulo

	//³Criacao dos componentes de impressao
	DEFINE REPORT oReport NAME "APURIMP" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| LocEquImp(oReport,aLogArq)} DESCRIPTION cDesc TOTAL IN COLUMN
   	oReport:SetPortrait(.T.)//Impressao Retrato

	// oSection = usado para montar o cabeçalho do relatorio
	DEFINE SECTION oSection OF oReport TITLE OemToAnsi(cTitulo) ORDERS aOrd TABLE "" TOTAL IN COLUMN
	DEFINE CELL NAME "LISTA" OF oSection TITLE "" SIZE 200//"RESULTADO DO LOG ARQUIVO MAGNETICO"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocArgImp ºAutor  ³Marcos Kato         º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Detalhe do Relatorio em TREPORT                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LocEQUImp(oReport,aLogArq)
Local oSection := oReport:Section(1)
Local nCont    := 0

	oSection:Init()
		For nCont:=1 To Len(aLogArq)
		  	oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
		    oSection:Cell("LISTA"	):SetBlock({||aLogArq[nCont]})
			oSection:PrintLine()
		Next
	oSection:Finish()
Return Nil

/*/{Protheus.doc} fGetCpo
  Obtiene los campos VALIMP,BASEIMP Y ALQIMP de la tabla dada
  @type function
  @author mayra.camargo
  @since 23/08/2017
  @version 1.0
  @param cTabla, character, Tabla a la cuál se le buscará los campos VALIMP,BASEIMP Y ALQIMP
  @return cCPolvr, ${return_description}
/*/
Static Function fGetCpo(cTabla)
Local aArea 	:= getArea()
Local cCPolvr	:= ""

	dbSelectArea("SX3")
	SX3->(dbSetOrder(1)) // X3_ARQUIVO + X3_ORDEM

	If SX3->(dbSeek(cTabla))
		While SX3->(!eof())  .and. SX3->X3_ARQUIVO == cTabla
			If "_VALIMP" $ SX3->X3_CAMPO .OR. "_ALQIMP" $ SX3->X3_CAMPO .OR. "_BASIMP" $ SX3->X3_CAMPO
				cCPolvr	+= X3_CAMPO + ","
			EndIF
			SX3->(dbSkip())
		Enddo
	EndIF

	RestArea(aArea)
Return cCPolvr
