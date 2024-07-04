#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FINC320.CH"
#INCLUDE "REPORT.CH"

#Define nTamN1	 2												//XX
#Define nTamN2	 nTamN1 + 1 + Len(AllTrim(FwGrpCompany()))		//XX.XX
#Define nTamN3	 nTamN2 + 1 + Len(AllTrim(FWCompany()))			//XX.XX.X
#Define nTamN4	 nTamN3 + 1 + Len(AllTrim(FWUnitBusiness()))	//XX.XX.X.XX
#Define nTamN5	 nTamN4 + 1 + Len(AllTrim(FWFilial()))			//XX.XX.X.XX.XX

Static _oFINC3201
Static _oFINC3202

//Alterado FSW - 05/11 (CNI) - Adaptacao da rotina para apresentar dados utilizando Tree e tReport para relatorio.

// PACOTE FNC 00000018102010
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FINC320   บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosicao Geral Contas Receber Consolidada                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINC320()

	Private oFolder		:= Nil
	Private aTmpTabs	:= {}
	Private aMarks		:= {}
	Private aPanels		:= {}
	Private aCampos		:= {}
	Private aCpos		:= {}
	Private oWizard 	:= Nil
	Private aIndexCab	:= {}
	Private aGetD 		:= Nil
	Private aSM0		:= AdmAbreSM0()
	Private cFilExpr	:= ""
	Private cTblOficial	:= ""
	Private nGruGC 		:= Len(FwGrpCompany())
	Private nEmpGC		:= Len(FWCompany())
	Private nUnidGC		:= Len(FWUnitBusiness())
	Private nFilGC 		:= Len(FWFilial())
	Private cTipos		:= ""

	FC320MTRB(aSM0)

	aCpos:=	{{"TRB_OK"		,""	,STR0001			,""},;	//"OK"
				{"TRB_GRUPO"	,""	,STR0002			,""},;	//"Grupo"
				{"TRB_EMP"		,""	,STR0003			,""},;	//"Empresa"
				{"TRB_UNID"	,""	,STR0004			,""},;	//"Unid.Org."
				{"TRB_FILEMP"	,""	,OemToAnsi(STR0005)	,""}}	//"Filial"

	FC320WZD()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC320Wzd()บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de telas geradas atraves do Wizard                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320WZD()

	Local cMarca		:= GetMark ()
	Local lInverte		:= .F.
	Local lMark			:= .F.

	Local c2Procura		:= Space(50)
	Local o2Procura
	Local aList			:= {}
	Local aList2		:= {}
	Local oFont
	Local oMSSelect
	Local nIndBox

	Local alPergs		:= {}
	Local alRetEmp		:= {}
	Local alGrpEmp		:= {}
	Local nlI			:= 0

	//////////////////////////////////////////
	//Variaveis de usa na tela 3- parametros//
	//////////////////////////////////////////
	Local nlTela		:= 0

	Local alOpc1		:= {STR0006		,STR0007}								//"1=Filial"##"2=Empresa"
	Local alOpc2		:= {STR0008		,OemToAnsi(STR0009),OemToAnsi(STR0010)}	//"1=Baixa"##"2=Digita็ใo"##"3=Disponibilidade"
	Local alOpc3		:= {STR0011		,OemToAnsi(STR0012)}					//"1=Sim"##"2=Nใo"
	Local alOpc4		:= {STR0013		,OemToAnsi(STR0014)}					//"1=Considera"##"2=Nใo Considera"
	Local alOpc5		:= {STR0015		,STR0016,STR0017,STR0018,STR0019}		//"1=Moeda1"##"2=Moeda2"##"3=Moeda3"##"4=Moeda4"##"5=Moeda5"
	Local alOpc6		:= {STR0020		,OemToAnsi(STR0021)}					//"1=Converter"##"2=Nใo Imprimir"
	Local clPicDat		:= CtoD("//")

	Private aIndBox		:= {STR0002,STR0003,STR0022,STR0005}					//Grupo##Empresa##Unidade##Filial
	Private apRet		:= Array(1,1)

	Define FONT oFont NAME "Arial" SIZE 0, -11
	Define FONT oFontB NAME "Arial" SIZE 0, -11 BOLD

	DEFINE WIZARD oWizard TITLE OemToAnsi(STR0023);	//"Resumo Geral do Contas  a Pagar"
		HEADER OemToAnsi(STR0024);					//"Parametriza็ใo Resumo Geral do Contas  a Pagar"
		MESSAGE "";
		TEXT OemToAnsi(STR0025) +;					//"Esta rotina define os parโmetros necessแrios para o Resumo Geral do Contas a Receber."
		CRLF +;
		OemToAnsi(STR0027);							//"Informe todos os parโmetros corretamente e defina como serแ o processamento da consulta."
		NEXT {||.T.} ;
		FINISH {|| .T. } ;
		PANEL

		//Segunda Pagina
		CREATE PANEL oWizard ;
		HEADER OemToAnsi(STR0030) ;					//"Sele็ใo das Empresas do Grupo"
		MESSAGE STR0031 ;							//"Selecione as empresas"
		BACK {|| .T. } ;
		NEXT {|| alRetEmp := FC320VRFOK(), alGrpEmp := alRetEmp[1], alRetEmp[2]  } ;
		FINISH {|| .T. } ;
		PANEL

		@25,05 TO 132,282 LABEL STR0032 OF oWizard:oMPanel[2] PIXEL	//"Grupo de Empresas"
		oMSSelect	:=	MsSelect():New (cTblOficial, "TRB_OK",,aCpos, @lInverte, @cMarca, {40, 10, 126, 276},,,oWizard:oMPanel[2])
		oMSSelect:oBrowse:lHasMark 	:= 	.f.
		oMSSelect:oBrowse:lCanAllMark	:=	.f.

		oChkMark 					:= TCHECKBOX():Create(oWizard:oMPanel[2])
		oChkMark:cName 				:= "oChkMark"
		oChkMark:cCaption 			:= STR0033 //'Selecionar Todos '
		oChkMark:nLeft 				:= 10
		oChkMark:nTop 				:= 05
		oChkMark:nWidth				:= 120
		oChkMark:nHeight 			:= 60
		oChkMark:lShowHint 			:= .F.
		oChkMark:lReadOnly 			:= .F.
		oChkMark:Align 				:= 0
		oChkMark:cVariable 			:= "lMark"
		oChkMark:bSetGet 			:= {|u| If(PCount()>0,lMark:=u,lMark) }
		oChkMark:bChange 			:= {||FC320MARC(lMark, cMarca ), oMSSelect:oBrowse:Refresh() }
		oChkMark:lVisibleControl	:= .T.

		oIndBox 				:= TCOMBOBOX():Create(oWizard:oMPanel[2])
		oIndBox:cName 			:= "oIndBox"
		oIndBox:cCaption 		:= "Indice"
		oIndBox:nLeft 			:= 05
		oIndBox:nTop 			:= 30
		oIndBox:nWidth 			:= 200
		oIndBox:nHeight 		:= 21
		oIndBox:lShowHint 		:= .F.
		oIndBox:lReadOnly 		:= .F.
		oIndBox:Align 			:= 0
		oIndBox:cVariable 		:= "nIndBox"
		oIndBox:bSetGet 		:= {|u| If(PCount()>0,nIndBox:=u,nIndBox) }
		oIndBox:aItems 			:= aIndBox
		oIndBox:nAt 			:= 1
		oIndBox:bChange			:= {|| (cTblOficial)->( dbSetOrder(oIndBox:nAt ) ) }
		oIndBox:lVisibleControl	:= .T.

		TSay ():New (17, 150, {||STR0034}, oWizard:oMPanel[2],,oFont,.F.,.F.,.F., .T.,,, 100, 10, .F., .F., .F., .F., .F.)	//"Pesquisar"
		o2Procura := TGet ():New (15, 176, {|u| Iif(PCount()==0,c2Procura,c2Procura:=u)}, oWizard:oMPanel[2], 100, 9, "@!",{||FC320FIND(2,oMSSelect,c2Procura,aList2)},,,,,, .T.)

		//Terceira Pagina
		CREATE PANEL oWizard ;
		HEADER OemToAnsi(STR0035) ;		//"Parโmetros"
		MESSAGE OemToAnsi(STR0036) ; 	//"Informe os parโmetros"
		BACK {|| (cTblOficial)->(DbGoTop()), .T. } ;
		NEXT {|| .T. } ;
		FINISH {|| MsgRun(STR0054,STR0055 ,{||FC320DRILL(alGrpEmp)}),.T. } ; //"Gerando Drill-Down de Visualizacao"##"Aguarde"
		PANEL

		aADD(alPergs ,{2,STR0038,'',alOpc2,70,'Pertence("123")'	,.F.}) //"Lista baixas pela data da"
		aADD(alPergs ,{2,STR0039,'',alOpc3,40,'Pertence("12")'	,.F.}) //'Seleciona Tipos'

		aADD(alPergs ,{1,STR0040,'','@!','','','',40,.F.}) //'Prefixo Inicial'
		aADD(alPergs ,{1,STR0041,'','@!','','','',40,.F.}) //'Prefixo Final'

		aADD(alPergs ,{2,STR0042,'',alOpc3,40,'Pertence("12")'		,.F.}) //'Considera Juros'
		aADD(alPergs ,{2,STR0043,'',alOpc4,70,'Pertence("12")'		,.F.}) //"TES dos Pedidos de Venda"
		aADD(alPergs ,{2,STR0044,'',alOpc3,40,'Pertence("12")'		,.F.}) //'Comp๕e Saldo Retroativo'
		aADD(alPergs ,{2,STR0045,'',alOpc5,70,'Pertence("12345")'	,.F.}) //'Qual Moeda'
		aADD(alPergs ,{2,STR0046,'',alOpc6,70,'Pertence("12")'		,.F.}) //'Outras Moedas'
		aADD(alPergs ,{2,STR0047,'',alOpc4,70,'Pertence("12")'		,.F.}) //'Considera Abatimentos'
		aADD(alPergs ,{2,STR0048,'',alOpc4,70,'Pertence("12")'		,.F.}) //'Considera Pedidos de Vendas'

		aADD(alPergs ,{1,STR0049,clPicDat,'@!','','','',50,.F.}) //'Data Base'

		aADD(alPergs ,{2,OemToAnsi(STR0050),'',alOpc3,40,'Pertence("12")', .F.})//'Tit.Emissใo Futura'
		
		If (TableInDic('FKD') .And.	TableInDic('FKC'))
			aADD(alPergs ,{2,STR0130,'',alOpc3,40,'Pertence("12")'		,.F.}) //'Considera Valores Acess๓rios'
		Endif 
		
		If Len(apRet[1]) == 1
			apRet[1] := Array(Len(alPergs))
			For nlI := 1 to Len(apRet[1])
			apRet[1][nlI] := Space(03)
			Next nlI
		EndIf
		apRet[1][8]  := Space(02)
		apRet[1][12] := Date()

		ParamBox(alPergs ,STR0051,apRet[1],,, .T.,,,oWizard:oMPanel[3],, .F.,)

	ACTIVATE WIZARD oWizard CENTERED

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC320MTrb บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Trabalho                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320MTRB(aTrb)

	Local aCampos	:=	{}
	Local cArq		:=	""
	Local nI,Na		:=	0
	Local aIndBox	:= {}
	Local aIndBoxK	:= 	{}

	aAdd( aCampos,  { "TRB_OK"     ,"C",02,0 } )
	aAdd( aCampos,  { "TRB_GRUPO"  ,"C",IIf(nGruGC >  0, nGruGC, 3 ),0 } )
	aAdd( aCampos,  { "TRB_EMP"    ,"C",IIf(nEmpGC >  0, nEmpGC, 3 ),0 } )
	aAdd( aCampos,  { "TRB_UNID"   ,"C",IIf(nUnidGC > 0, nUnidGC,2 ),0 } )
	aAdd( aCampos,  { "TRB_FILEMP" ,"C",IIf(nFilGC >  0, nFilGC, 40),0 } )

	If _oFINC3201 <> Nil
		_oFINC3201:Delete()
		_oFINC3201	:= Nil
	Endif	
	
	cArq := GetNextAlias()

	_oFINC3201 := FWTemporaryTable():New(cArq)
	_oFINC3201:SetFields( aCampos )

	//Adiciona as Chaves de indices
	_oFINC3201:AddIndex("1",{"TRB_GRUPO"} 	)
	_oFINC3201:AddIndex("2",{"TRB_EMP"} 	)
	_oFINC3201:AddIndex("3",{"TRB_UNID"} 	)
	_oFINC3201:AddIndex("4",{"TRB_FILEMP"} 	)

	_oFINC3201:Create()
	
	cTblOficial := cArq

	For nI := 1 To Len(aTRB)
		RecLock(cTblOficial, .T.)
		(cTblOficial)->TRB_GRUPO	:= aTRB[nI][1]
		(cTblOficial)->TRB_EMP		:= aTRB[nI][3]
		(cTblOficial)->TRB_UNID		:= aTRB[nI][4]
		(cTblOficial)->TRB_FILEMP	:= aTRB[nI][5]
		(cTblOficial)->(MSUNLOCK())
	Next nI

	(cTblOficial)->(dbGotop())

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFC320Find บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcura  de acordo com rotina do Wizard                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320FIND(nOpcao,oObj,cProcura,aList)

	Local	lRet	:=	.T.
	Local	nPos	:=	0

	nPos	:=	aScan(aList,{|aX| AllTrim(cProcura)==Left(aX[1],Len(AllTrim(cProcura)))})

	If nOpcao==1
		oObj:nAT := Iif(nPos==0,1,nPos)
		oObj:Refresh()
	Else
		dbSelectArea(cTblOficial)
		(cTblOficial)->(dbSeek(AllTrim(cProcura)))
		oObj:oBrowse:Refresh()
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC320Marc บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona opcoes.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320MARC(llMarc,cpMarca)

Local cRec := RECNO()

	dbSelectArea(cTblOficial)
	(cTblOficial)->(dbGoTop())

	If llMarc
		While (cTblOficial)->(!Eof())
			If RecLock(cTblOficial,.F.)
				Replace (cTblOficial)->TRB_OK With cpMarca
				MsUnLock()
			EndIf
			(cTblOficial)->(dbSkip())
		EndDo
	Else
		While (cTblOficial)->(!Eof())
			If RecLock(cTblOficial,.F.)
				Replace (cTblOficial)->TRB_OK With Space(2)
				MsUnLock()
			EndIf
			(cTblOficial)->(dbSkip())
		EndDo
	EndIf

	(cTblOficial)->(dbGoto(cRec))    //Posiciona no registro Atual

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao	 |FC320VrfOKบAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica selecao.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320VRFOK()

	Local llReturn	:= .T.
	Local alOk		:= {}

	DbSelectArea(cTblOficial)
	(cTblOficial)->(DbGoTop())
	While (cTblOficial)->(!EOF())
		If !Empty((cTblOficial)->TRB_OK)
			aAdd(alOk,{(cTblOficial)->TRB_OK,Iif(!Empty((cTblOficial)->TRB_GRUPO),(cTblOficial)->TRB_GRUPO	,"");
								,Iif(!Empty((cTblOficial)->TRB_FILEMP),(cTblOficial)->TRB_FILEMP	,"");
								,Iif(!Empty((cTblOficial)->TRB_EMP),(cTblOficial)->TRB_EMP			,"");
								,Iif(!Empty((cTblOficial)->TRB_UNID),(cTblOficial)->TRB_UNID		,"")})
		EndIf
		(cTblOficial)->(DbSkip())
	EndDo

	If Empty(alOk)
		llReturn := .F.
		Aviso(OemToAnsi(STR0052),STR0053,{STR0001}) // "Atencao"##"Selecionar um Grupo"##"Ok"
		(cTblOficial)->(DbGoTop())
	EndIf

Return {alOk, llReturn}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC320DrillบAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta toda estrutura do Drill-Down e atualizacao dos valoresบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAP                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320DRILL(alGrpEmp)

	Local aVal		:= {}
	Local cArqTmp	:= ""
	Local clAlias	:= ""
	Local clHeader	:= ""

	Local lEnchBar	:= .T. // Se a janela de diแlogo possuirแ enchoicebar (.T.)
	Local lPadrao	:= .F. // Se a janela deve respeitar as medidas padr๕es do Protheus (.T.) ou usar o mแximo disponํvel (.F.)
	Local nMinY		:= 400 // Altura mํnima da janela

	Local aSize		:= MsAdvSize(lEnchBar, lPadrao, nMinY)

	Local oOk		:= LoadBitmap( GetResources() , 'PMSMAIS'  ) // Sinal de mais ( + )
	Local oNo		:= LoadBitmap( GetResources() , 'PMSMENOS' ) // Sinal de menos( - )
	Local oFnt1		:= Nil
	Local oDlg		:= Nil

	Local nX		:= 0
	Local nlI		:= 0
	Local nlK		:= 0
	Local nlJ		:= 0
	Local nlF		:= 0
	Local nlAte		:= 0
	Local nlTamGlo	:= 0
	Local nlAux		:= 0

	Local alNiv2	:= {}
	Local alNiv3	:= {}
	Local alNiv4	:= {}
	Local alNiv5	:= {}
	Local clNivel	:= ""

	Local nlGuarda	:= 0
	Local nlCont	:= 1
	Local nlCont2	:= 1
	Local nlCt		:= 0
	Local clDesc	:= ""
	Local nlTotSup	:= 0

	Local aHeadLst	:= {}

	Local clAux		:= ""
	Local clBLine	:= ""
	Local clBkpEmp	:= ""
	Local clEmp		:= ""
	Local clFil		:= ""

	Local mv_par07	:= Val(apRet[1][7])

	Local aButtons	:= {}

	Local aChavAux := {}
	
	Local oSize

	Private aNivel2	:= {}
	Private aNivel3	:= {}
	Private aNivel4	:= {}
	Private aNivel5	:= {}
	Private aCols	:= {}
	Private aHeader	:= {}
	Private oGetDados
	Private oTree
	Private aRotina := {{STR0034	, "AxPesqui", 0, 1},; //"Pesquisar"
						{STR0126	, "AxVisual", 0, 2},; //"Visualizar"
						{STR0127	, "AxInclui", 0, 3},; //"Incluir"
						{STR0128	, "AxAltera", 0, 4},; //"Alterar"
						{STR0129	, "AxDeleta", 0, 5}} //"Excluir"

	Private cpCondic:= ""
	Private oLbx	:= Nil
	Private aLbx	:= {}
	Private aGlobal	:= {}
	Private nNivelMin:= 6

	//Alterado FSW - 05/11 (CNI)

	AADD(aButtons,{"RELAT"		, {|| FC320REL()}			,STR0115,STR0115 }) //Relatorio

	If apRet[1][2] == '1' .AND. !IsBlind()
		// funcao que utilizada para apresentar a tela de selecao de tipos. 
		finaTipos()
		While Empty(cTipos)
			Help(NIL, NIL, "F320TIPO", NIL, STR0131, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0132})//"O parโmetro para selecionar os tipos de tํtulos foi ativado, por้m nenhum tipo foi selecionado."# "Selecionar o(s) tipo(s) desejado(s) ou cancelar a triagem de tipos de tํtulos."
			finaTipos()
		End 
	EndIF
	
	//------------------------------------------------------------
	// Obtem os valores. Processo executado via job para permitir
	// a abertura de ambientes de outros grupos de empresas
	//------------------------------------------------------------
	aVal := StartJob( "FC320Calc" , GetEnvServer() , .T. ,,,alGrpEmp,apRet,cTipos)


	aADD(aGlobal,{1, .F.,STR0056	," "," "," "," ",0	,0	,"01"})	//"FATURAMENTO(no mes)"
	aADD(aGlobal,{1, .F.,STR0057	," "," "," "," ",0 	,0	,"02"})	//"A Vista"
	aADD(aGlobal,{1, .F.,STR0058	," "," "," "," ",0	,0	,"03"})	//"A Prazo"

	aADD(aGlobal,{1, .F.,STR0059	," "," "," "," ",0	,0	,"04"})	//"VALORES BAIXADOS"
	aADD(aGlobal,{1, .F.,STR0060	," "," "," "," ",0 	,0	,"05"})	//"Recebido"
	aADD(aGlobal,{1, .F.,STR0061	," "," "," "," ",0	,0	,"06"}) //"Taxa de Permanencia"
	aADD(aGlobal,{1, .F.,STR0062	," "," "," "," ",0	,0	,"07"}) //"Multa"
	aADD(aGlobal,{1, .F.,STR0063	," "," "," "," ",0	,0	,"08"}) //"Correcao"
	aADD(aGlobal,{1, .F.,STR0064	," "," "," "," ",0	,0	,"09"}) //"Pgto Antecipado"
	aADD(aGlobal,{1, .F.,STR0129	," "," "," "," ",0	,0	,"10"}) //"Valor Acess๓rio"
	aADD(aGlobal,{1, .F.,STR0065	," "," "," "," ",0	,0	,"11"}) //"Original"
	
	aADD(aGlobal,{1, .F.,STR0066	," "," "," "," ",0	,0	,"12"}) //"TITULOS A VENCER"
	aADD(aGlobal,{1, .F.,STR0067	," "," "," "," ",0	,0	,"13"}) //"Ate 15 Dias"
	aADD(aGlobal,{1, .F.,STR0068	," "," "," "," ",0	,0	,"14"}) //"De 16 a 30 dias"
	aADD(aGlobal,{1, .F.,STR0070	," "," "," "," ",0	,0	,"15"}) //"De 31 a 60 dias"
	aADD(aGlobal,{1, .F.,STR0071	," "," "," "," ",0	,0	,"16"}) //"De 61 a 90 dias"
	aADD(aGlobal,{1, .F.,STR0072 	," "," "," "," ",0	,0	,"17"}) //"Acima de 90 Dias

	aADD(aGlobal,{1, .F.,STR0073	," "," "," "," ",0	,0	,"18"}) //"TITULOS VENCIDOS"
	aADD(aGlobal,{1, .F.,STR0067  	," "," "," "," ",0	,0	,"19"}) //"Ate 15 Dias"
	aADD(aGlobal,{1, .F.,STR0068 	," "," "," "," ",0	,0	,"20"}) //"De 16 a 30 dias"
	aADD(aGlobal,{1, .F.,STR0070 	," "," "," "," ",0	,0	,"21"}) //"De 31 a 60 dias"
	aADD(aGlobal,{1, .F.,STR0071 	," "," "," "," ",0	,0	,"22"}) //"De 61 a 90 dias"
	aADD(aGlobal,{1, .F.,STR0072 	," "," "," "," ",0	,0	,"23"}) //"Acima de 90 Dias"
	aADD(aGlobal,{1, .F.,STR0074	," "," "," "," ",0	,0	,"24"}) //"Recebimento Antecipado"
	aADD(aGlobal,{1, .F.,STR0075	," "," "," "," ",0	,0	,"25"}) //"Notas de Credito"

	aADD(aGlobal,{1, .F.,STR0076	," "," "," "," ",0	,0	,"26"}) //"DISTRIBUICAO DA COBRANCA"
	aADD(aGlobal,{1, .F.,STR0077	," "," "," "," ",0	,0	,"27"}) //"Carteira"
	aADD(aGlobal,{1, .F.,STR0078	," "," "," "," ",0	,0	,"28"})	//"Cobranca Simples"
	aADD(aGlobal,{1, .F.,STR0079	," "," "," "," ",0	,0	,"29"})	//"Cobranca Descontada"
	aADD(aGlobal,{1, .F.,STR0080	," "," "," "," ",0	,0	,"30"})	//"Cobranca Caucionada"
	aADD(aGlobal,{1, .F.,STR0081	," "," "," "," ",0	,0	,"31"})	//"Cobranca Vinculada"
	aADD(aGlobal,{1, .F.,STR0082	," "," "," "," ",0	,0	,"32"})	//"Cobranca Extra-Judicial" "Cobran็a c/Advogado"
	aADD(aGlobal,{1, .F.,STR0083	," "," "," "," ",0	,0	,"33"})	//"Cobranca Cartorio" "Cobranca Judicial"
	aADD(aGlobal,{1, .F.,STR0084	," "," "," "," ",0	,0	,"34"})	//"Cobr Cauc Descont"

	aADD(aGlobal,{1, .F.,STR0085	," "," "," "," ",0	,0	,"35"})	//"POR TIPO DE TITULO"
	aADD(aGlobal,{1, .F.,STR0086	," "," "," "," ",0	,0	,"36"})	//"Duplicatas"
	aADD(aGlobal,{1, .F.,STR0087	," "," "," "," ",0	,0	,"37"})	//"Notas Fiscais"
	aADD(aGlobal,{1, .F.,STR0088	," "," "," "," ",0	,0	,"38"})	//"Cheques Pre-Datados"
	aADD(aGlobal,{1, .F.,STR0089	," "," "," "," ",0	,0	,"39"})	//"Carnet De Pagamento"
	aADD(aGlobal,{1, .F.,STR0090	," "," "," "," ",0	,0	,"40"})	//"Impostos"
	aADD(aGlobal,{1, .F.,STR0091	," "," "," "," ",0	,0	,"41"})	//"Abatimentos"
	aADD(aGlobal,{1, .F.,STR0092	," "," "," "," ",0	,0	,"42"})	//"Outros"

	aADD(aGlobal,{1, .F.,STR0093	," "," "," "," ",0	,0	,"43"})	//"CARTEIRA DE PEDIDOS A ENTREGAR"
	aADD(aGlobal,{1, .F.,STR0094	," "," "," "," ",0	,0	,"44"})	//"Itens de Pedidos Vencidos"
	aADD(aGlobal,{1, .F.,STR0095 	," "," "," "," ",0	,0	,"45"})	//"Ate 30 Dias"
	aADD(aGlobal,{1, .F.,STR0070 	," "," "," "," ",0	,0	,"46"})	//"De 31 a 60 dias"
	aADD(aGlobal,{1, .F.,STR0071	," "," "," "," ",0	,0	,"47"})	//"De 61 a 90 dias"
	aADD(aGlobal,{1, .F.,STR0072	," "," "," "," ",0	,0	,"48"})	//"Acima de 90 Dias"

	nlTamGlo := Len(aGlobal)
	For nlI	:= 1 to nlTamGlo
		alNiv2	:= {{" ","00"}}
		alNiv3	:= {{" ","00"}}
		alNiv4	:= {{" ","00"}}
		alNiv5	:= {{" ","00"}}

		aChavAux := {{"","","",""},{"00","00","00","00"}}

		For nlJ :=1 to Len(alGrpEmp)
			clNivel := ""
			For nlK := 2 to Len(alGrpEmp[nlJ])

				//-------------------
				// Grupos de Empresa
				//-------------------
				If nlK == 2
					If alGrpEmp[nlJ][2] == aChavAux[1,1]
						clNivel += aGlobal[nlI][10] + "." + aChavAux[2,1]
					Else
						aChavAux[1,1] := alGrpEmp[nlJ][2]
				 		aChavAux[2,1] := Soma1(aChavAux[2,1])

						aAdd(alNiv2, {alGrpEmp[nlJ][2], aChavAux[2,1]})
						clNivel += aGlobal[nlI][10]+"."+aChavAux[2,1]
						aAdd(aGlobal, {nlK, .F.,aGlobal[nlI][3],alGrpEmp[nlJ][2]," "," "," ",0 	,0,clNivel })

						aChavAux := {{aChavAux[1,1],"","",""},{aChavAux[2,1],"00","00","00"}}

					EndIf

				//-------------------
				// Empresa
				//-------------------
				ElseIf nlK == 3
			 		If alGrpEmp[nlJ][4] == aChavAux[1,2]
						clNivel += "." + aChavAux[2,2]
					Else
						aChavAux[1,2] := alGrpEmp[nlJ][4]
				 		aChavAux[2,2] := Soma1(aChavAux[2,2])
						aAdd(alNiv3, {aChavAux[1,2],aChavAux[2,2]})
						clNivel += "." + aChavAux[2,2]
						aAdd(aGlobal, {nlK, .F.,aGlobal[nlI][3],aGlobal[Len(aGlobal)][4],alGrpEmp[nlJ][4]," "," ",0	,0,clNivel})

						aChavAux := {{aChavAux[1,1],aChavAux[1,2],"",""},{aChavAux[2,1],aChavAux[2,2],"00","00"}}

					EndIf

				//-------------------
				// Unidade de Negocio
				//-------------------
				ElseIf nlK == 4
					If alGrpEmp[nlJ][5] == aChavAux[1,3]
						clNivel += "." + aChavAux[2,3]
					Else
						aChavAux[1,3] := alGrpEmp[nlJ][5]
						aChavAux[2,3] := Soma1(aChavAux[2,3])
						aAdd(alNiv4, {aChavAux[1,3], aChavAux[2,3]})
						clNivel += "." + aChavAux[2,3]
						aAdd(aGlobal, {nlK, .F.,aGlobal[nlI][3],aGlobal[Len(aGlobal)][4],aGlobal[Len(aGlobal)][5],alGrpEmp[nlJ][5]," ",0	,0,clNivel})

						aChavAux := {{aChavAux[1,1],aChavAux[1,2],aChavAux[1,3],""},{aChavAux[2,1],aChavAux[2,2],aChavAux[2,3],"00"}}

					EndIf

				//-------------------
				// Filial
				//-------------------
				ElseIf nlK == 5
					If alGrpEmp[nlJ][3] == aChavAux[1,4]
						clNivel += "." + aChavAux[2,4]
						aAdd(aGlobal, {nlK, .F.,aGlobal[nlI][3],aGlobal[Len(aGlobal)][4],aGlobal[Len(aGlobal)][5],aGlobal[Len(aGlobal)][6],alGrpEmp[nlJ][3],0 ,0	,clNivel })
					Else
						aChavAux[1,4] := alGrpEmp[nlJ][3]
						aChavAux[2,4] := Soma1(aChavAux[2,4])
						aAdd(alNiv5, {alGrpEmp[nlJ][3], aChavAux[2,4]})
						clNivel += "." + aChavAux[2,4]
						aAdd(aGlobal, {nlK, .F.,aGlobal[nlI][3],aGlobal[Len(aGlobal)][4],aGlobal[Len(aGlobal)][5],aGlobal[Len(aGlobal)][6],alGrpEmp[nlJ][3],0,0,clNivel })
					EndIf
				EndIf

			Next nlK
		Next nlJ
	Next nlI

	nlAte := Iif(!Empty(aGlobal),Len(aGlobal[1])-2,(Aviso(STR0052  , ,{STR0001 }), -1)) //"Atencao"##"Nenhum arquivo encontrado"##"Ok"
	If nlAte == -1
		Return .F.
	EndIf
	aSort(aGlobal,,,{|aLx, aLy| aLx[10]  <  aLy[10]  })

	FC320Tot(aVal)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Alimenta a ListBox apenas com o Grupo        ณ
	//ณ neste caso sendo o nivel 1 da Array aGlobal  ณ
	//ณ ignorando os demais niveis que serao abertos ณ
	//ณ quando clicar no sinal de mais(+) da ListBox ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX := 1 To Len(aGlobal)
		If aGlobal[nX][1] == 1
			aAdd(aLbx, aGlobal[nX])
		EndIf
	Next nX
	aSort(aLbx,,,{|aLx, aLy| aLx[10] <  aLy[10] })
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria Cabecalho do TwBrowse |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(aHeadLst,''		)	//Ok -> (+)(-)
	aAdd(aHeadLst,STR0097	)	//DESCRICAO
	aAdd(aHeadLst,STR0098	)	//GRUPO
	aAdd(aHeadLst,STR0099	)	//EMPRESA
	aAdd(aHeadLst,STR0100	)	//UNIDADE
	aAdd(aHeadLst,STR0101	)	//FILIAL
	aAdd(aHeadLst,STR0102	)	//VALORES
	aAdd(aHeadLst,STR0103	)	//QUANTIDADE

	//Define dimensoes da tela
	aSize		:= MsAdvSize(,.F.,430)
	aObjects	:= {{ 100, 157 , .T., .T. }}
	aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPosObj	:= MsObjSize( aInfo, aObjects )

	oSize := FwDefSize():New(.T.,,,)
	oSize:AddObject( "MASTER",50, 100, .T., .T. ) // Totalmente dimensionavel	
	oSize:AddObject( "TREE",50, 100, .T., .T. ) // Totalmente dimensionavel
	oSize:lProp 		:= .T. // Proporcional
	oSize:lLateral	:= .T. // Proporcional        
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize:Process() 	   // Dispara os calculos

	Define MsDialog oDlg Title STR0104 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL  //"Posicao Geral Contas a Receber Consolidada"
	
	nLinIni := oSize:GetDimension("MASTER","LININI") 
	nColIni := oSize:GetDimension("MASTER","COLINI") 
	nLinEnd := oSize:GetDimension("MASTER","LINEND") 
	nColEnd := oSize:GetDimension("MASTER","COLEND")

	
	//Monta GetDados
	FC320MtaGetDad(@oDlg, @oGetDados,{nLinIni,nColIni,nLinEnd,nColEnd})
	
	nLinIni := oSize:GetDimension("TREE","LININI") 
	nColIni := oSize:GetDimension("TREE","COLINI") 
	nLinEnd := oSize:GetDimension("TREE","LINEND") 
	nColEnd := oSize:GetDimension("TREE","COLEND")
	//Monta Tree
	FC320MtaTree(@oDlg, {nLinIni,nColIni,nLinEnd,nColEnd})

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC320Tot  บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTotaliza Valores e quantidades                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAP                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320Tot(aVal)

	Local alNiv2	:= {}
	Local alNiv3	:= {}
	Local alNiv4	:= {}
	Local alNiv5	:= {}

	Local nlI		:= 0
	Local nlJ		:= 0
	Local nlAux		:= 0

	Local clDesc	:= ""

	// Gera os Valores do ultimo Nivel: FILIAL
	For nlI := 1 to Len(aGlobal)
		If aGlobal[nlI][1] == 1
			clDesc := aGlobal[nlI][3]
			nlAux:= nlI
			alNiv5	:= {}
			While nlAux <= Len(aGlobal) .And. clDesc == aGlobal[nlAux][3]
				If aGlobal[nlAux][1] == 5
					aAdd(alNiv5, {nlAux,SubStr(aGlobal[nlAux][10],1,2)} )
				EndIf
				nlAux++
			EndDo
			For nlJ := 1 to Len(alNiv5)
				If alNiv5[nlJ][2] $ ("04/05/06/07/08/09/10/11/26/34") 
					aGlobal[alNiv5[nlJ][1]][9] := 0
					If alNiv5[nlJ][2] $ ("04/26/35")
						aGlobal[alNiv5[nlJ][1]][8] := 0
					EndIf
					If alNiv5[nlJ][2] == "05"
						aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][40,1] //nRecebido
					ElseIf alNiv5[nlJ][2] == "06"
						aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][41,1] //nValJuros
					ElseIf alNiv5[nlJ][2] == "07"
						aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][42,1] //nMulta
					ElseIf alNiv5[nlJ][2] == "08"
						aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][43,1] //nCorrecao
					ElseIf alNiv5[nlJ][2] == "09"
						aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][44,1] //nDesconto
					ElseIf alNiv5[nlJ][2] == "10"
							aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][45,1] //45 // VA
					ElseIf alNiv5[nlJ][2] == "11" 
						aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][46,1] // nRecebido-
					EndIf
				ElseIf alNiv5[nlJ][2] $ ("12/18/43")
					If alNiv5[nlJ][2] == "12"
						aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][39,1]+aVal[nlJ][7,1]+aVal[nlJ][8,1]+aVal[nlJ][9,1]+aVal[nlJ][10,1]
						aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][39,2]+aVal[nlJ][7,2]+aVal[nlJ][8,2]+aVal[nlJ][9,2]+aVal[nlJ][10,2]
					ElseIf alNiv5[nlJ][2] == "18"
						aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][38,1]+aVal[nlJ][3,1]+aVal[nlJ][4,1]+aVal[nlJ][5,1]+aVal[nlJ][6,1]
						aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][38,2]+aVal[nlJ][3,2]+aVal[nlJ][4,2]+aVal[nlJ][5,2]+aVal[nlJ][6,2]
					Else
						aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][17,1]+aVal[nlJ][18,1]+aVal[nlJ][19,1]+aVal[nlJ][20,1]+aVal[nlJ][21,1]
						aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][17,2]+aVal[nlJ][18,2]+aVal[nlJ][19,2]+aVal[nlJ][20,2]+aVal[nlJ][21,2]
					EndIf
				ElseIf alNiv5[nlJ][2] == "01"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][1,1]+aVal[nlJ][2,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][1,2]+aVal[nlJ][2,2]
				ElseIf alNiv5[nlJ][2] == "02"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][1,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][1,2]
				ElseIf alNiv5[nlJ][2] == "03"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][2,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][2,2]
				ElseIf alNiv5[nlJ][2] == "13"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][39,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][39,2]
				ElseIf alNiv5[nlJ][2] == "14"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][7,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][7,2]
				ElseIf alNiv5[nlJ][2] == "15"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][8,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][8,2]
				ElseIf alNiv5[nlJ][2] == "16"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][9,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][8,2]
				ElseIf alNiv5[nlJ][2] == "17"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][10,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][10,2]
				ElseIf alNiv5[nlJ][2] == "19"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][38,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][38,2]
				ElseIf alNiv5[nlJ][2] == "20"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][3,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][3,2]
				ElseIf alNiv5[nlJ][2] == "21"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][4,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][4,2]
				ElseIf alNiv5[nlJ][2] == "22"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][5,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][5,2]
				ElseIf alNiv5[nlJ][2] == "23"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][6,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][6,2]
				ElseIf alNiv5[nlJ][2] == "24"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][24,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][24,2]
				ElseIf alNiv5[nlJ][2] == "25"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][36,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][36,2]
				ElseIf alNiv5[nlJ][2] == "27"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][25,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][25,2]
				ElseIf alNiv5[nlJ][2] == "28"
					aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][26,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][26,2]
    			ElseIf alNiv5[nlJ][2] == "29"
    				aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][27,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][27,2]
    			ElseIf alNiv5[nlJ][2] == "30"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][28,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][28,2]
    			ElseIf alNiv5[nlJ][2] == "31"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][29,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][29,2]
    			ElseIf alNiv5[nlJ][2] == "32"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][30,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][30,2]
    			ElseIf alNiv5[nlJ][2] == "33"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][31,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][31,2]
    			ElseIf alNiv5[nlJ][2] == "34"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][37,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][37,2]
    			ElseIf alNiv5[nlJ][2] == "36"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][11,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][11,2]
    			ElseIf alNiv5[nlJ][2] == "37"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][12,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][12,2]
    			ElseIf alNiv5[nlJ][2] == "38"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][13,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][13,2]
    			ElseIf alNiv5[nlJ][2] == "39"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][14,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][14,2]
    			ElseIf alNiv5[nlJ][2] == "40"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][15,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][15,2]
    			ElseIf alNiv5[nlJ][2] == "41"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][35,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][35,2]
    			ElseIf alNiv5[nlJ][2] == "42"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][16,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][16,2]
    			ElseIf alNiv5[nlJ][2] == "44"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][21,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][21,2]
    			ElseIf alNiv5[nlJ][2] == "45"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][17,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][17,2]
    			ElseIf alNiv5[nlJ][2] == "46"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][18,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][18,2]
	    		ElseIf alNiv5[nlJ][2] == "47"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][19,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][19,2]
	    		ElseIf alNiv5[nlJ][2] == "48"
    			    aGlobal[alNiv5[nlJ][1]][8] := aVal[nlJ][20,1]
					aGlobal[alNiv5[nlJ][1]][9] := aVal[nlJ][20,2]
    			EndIf
    		Next nlJ
    		nlI := nlAux -1
    	EndIf
    Next nlI

     // Sobre a Arvore de niveis e vai gerando a totalizacao nos niveis
	alNiv2	:= {}
	alNiv3	:= {}
	alNiv4	:= {}
	alNiv5	:= {}

	For nlI := Len(aGlobal) to 1 Step -1
		If nGruGC > 0 .And. nEmpGC	> 0 .And. nUnidGC > 0 .And. nFilGC > 0
			If aGlobal[nlI][1] == 5
				aAdd(alNiv5, {aGlobal[nlI][6], aGlobal[nlI][8], aGlobal[nlI][9]})
			ElseIf aGlobal[nlI][1] == 4
				For nlJ := 1 to Len(alNiv5)
					If alNiv5[nlJ][1] == aGlobal[nlI][6]
						aGlobal[nlI][8] += alNiv5[nlJ][2]
						aGlobal[nlI][9] += alNiv5[nlJ][3]
					EndIf
				Next nlJ
				aAdd(alNiv4, {aGlobal[nlI][5],aGlobal[nlI][8], aGlobal[nlI][9]})
			ElseIf aGlobal[nlI][1] == 3
				For nlJ := 1 to Len(alNiv4)
					If alNiv4[nlJ][1] == aGlobal[nlI][5]
						aGlobal[nlI][8] += alNiv4[nlJ][2]
						aGlobal[nlI][9] += alNiv4[nlJ][3]
					EndIf
				Next nlJ
				aAdd(alNiv3, {aGlobal[nlI][4],aGlobal[nlI][8], aGlobal[nlI][9]})
			ElseIf aGlobal[nlI][1] == 2
				For nlJ := 1 to Len(alNiv3)
					If alNiv3[nlJ][1] == aGlobal[nlI][4]
						aGlobal[nlI][8] += alNiv3[nlJ][2]
						aGlobal[nlI][9] += alNiv3[nlJ][3]
					EndIf
				Next nlJ
				aAdd(alNiv2, {aGlobal[nlI][3],aGlobal[nlI][8], aGlobal[nlI][9]})
			ElseIf aGlobal[nlI][1] == 1
				For nlJ := 1 to Len(alNiv2)
					If alNiv2[nlJ][1] == aGlobal[nlI][3]
						aGlobal[nlI][8] += alNiv2[nlJ][2]
						aGlobal[nlI][9] += alNiv2[nlJ][3]
					EndIf
				Next nlJ
				alNiv2	:= {}
				alNiv3	:= {}
				alNiv4	:= {}
				alNiv5	:= {}
			EndIf
		Else
			If aGlobal[nlI][1] == 5
				aAdd(alNiv3, {aGlobal[nlI][4], aGlobal[nlI][8], aGlobal[nlI][9]})
			ElseIf aGlobal[nlI][1] == 2
				For nlJ := 1 to Len(alNiv3)
					If alNiv3[nlJ][1] == aGlobal[nlI][4]
						aGlobal[nlI][8] += alNiv3[nlJ][2]
						aGlobal[nlI][9] += alNiv3[nlJ][3]
					EndIf
				Next nlJ
				aAdd(alNiv2, {aGlobal[nlI][3],aGlobal[nlI][8], aGlobal[nlI][9]})
			ElseIf aGlobal[nlI][1] == 1
				For nlJ := 1 to Len(alNiv2)
					If alNiv2[nlJ][1] == aGlobal[nlI][3]
						aGlobal[nlI][8] += alNiv2[nlJ][2]
						aGlobal[nlI][9] += alNiv2[nlJ][3]
					EndIf
				Next nlJ
				alNiv2	:= {}
				alNiv3	:= {}
				alNiv4	:= {}
				alNiv5	:= {}
			EndIf		
		
		EndIF
	Next nlI

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFC320Calc ณ Autor ณ Microsiga		        ณ Data ณ 30.10.10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Calculo dos valores do relatorio Posio Geral da Cobrana.ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe e ณ FA320Calc(cFiltSE1)                            			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FC320Calc(cFiltSE1,cFiltSED,alGrpEmp,apRet,cTipos)

	LOCAL mv_par01 := 1
	LOCAL mv_par02 := Val(apRet[1][1])	//Lista Baixas pela Data da
	LOCAL mv_par03 := Val(apRet[1][2])	//Seleciona Tipos
	LOCAL mv_par04 := apRet[1][3]		//Prefixo Inicial
	LOCAL mv_par05 := apRet[1][4]		//Prefixo Final
	LOCAL mv_par06 := Val(apRet[1][5])	//Considera Juros
	LOCAL mv_par07 := Val(apRet[1][6])	//TES do Pedido de Venda
	LOCAL mv_par08 := Val(apRet[1][7])	//Compoe Saldo Retroativo
	LOCAL mv_par09 := Val(apRet[1][8])	//Qual Moeda
	LOCAL mv_par10 := Val(apRet[1][9])	//Outras Moedas
	LOCAL mv_par11 := Val(apRet[1][10])	//Considera Abatimentos
	LOCAL mv_par12 := Val(apRet[1][11])	//Considera Pedidos de Venda
	LOCAL mv_par13 := apRet[1][12]		//Data Base
	LOCAL mv_par14 := Val(apRet[1][13])	//Titulo Emissao Futura
	LOCAL mv_par15 := IIF(Len(apRet[1]) >= 14, Val(apRet[1][14]), 2)	//Considera Valores Acess๓rios (Feito prote็ใo para descida de valores acessorios na v12.1.17 sem dicionario)
	LOCAL CbCont,CbTxt
	LOCAL tamanho:="P"
	LOCAL nSaldo 	:=0,nDias:=0,I:=0,J:=0,nSaldoAtu:=0
	LOCAL nFirst 	:=1,nFirst1:=1
	LOCAL aVal[46,2]
	LOCAL nRecebido	:=0
	LOCAL nValJuros	:=0
	LOCAL nDesconto	:=0
	LOCAL nCorrecao	:=0
	LOCAL nMulta	:=0
	LOCAL nvlracess	:=0
	LOCAL nOriginal	:=0
	LOCAL dDataBaixa:= STOD("")
	Local cCondSC6
	Local dOldDtBase:= STOD("")
	LOCAL nX,cCondFil,nIndex
	Local cQuery
	Local cArq
	Local aSitua	:= ARRAY(8)
	Local nI		:=0
	Local nMoedaBco	:= 1
	Local nDecs		:= 0
	Local cFiltro, cIndTmp, cAliasTmp
	Local nTipoData	:= 1
	Local lAdto
	Local nValAbat	:= 0
	Local nAbt		:= 0
	Local nlI		:= 0
	Local clEmp		:= ""
	Local clFil		:= ""
	Local aRetVal	:= {}
	Local lValAcess	:=	ExistFunc('FValAcess')
	
	
	
	
	DEFAULT cFiltSE1	:= ""
	DEFAULT cFiltSED	:= ""
	Default alGrpEmp	:= {}

	aSitua[1] := OemtoAnsi(STR0028)		//"Carteira"
	aSitua[2] := OemtoAnsi(STR0029)		//"Cobranca Simples"
	aSitua[3] := OemToAnsi(STR0030)		//"Cobranca Descontada"
	aSitua[4] := OemToAnsi(STR0031)		//"Cobranca Caucionada"
	aSitua[5] := OemToAnsi(STR0032)		//"Cobranca Vinculada"
	aSitua[6] := OemToAnsi(STR0033)		//"Cobranca Extra-Judicial"
	aSitua[7] := OemToAnsi(STR0034)		//"Cobranca Cartorio"
	aSitua[8] := OemToAnsi(STR0035)		//"Cobr Cauc Descont"

	//Tipo da data para a composicao do saldo via SaldoTit()
	If mv_par02 == 1			// Data da baixa (E5_BAIXA)
		nTipoData := 1
	ElseIf mv_par02 == 2 	//Data de Digitacao (E5_DTDIGIT)
		nTipoData := 3
	Else							//Data de Disponibilidade (E5_DTDISPO)
		nTipoData := 2
	Endif

	For nlI := 1 to Len(alGrpEmp)
		clEmp := alGrpEmp[nlI][2]
		clFil := alGrpEmp[nlI][4] + alGrpEmp[nlI][5] + alGrpEmp[nlI][3]

		If Type("cEmpAnt")== "U"
			RpcSetType(3)
			RpcSetEnv( clEmp, clFil,,,"FIN")
		ElseIf cEmpAnt != clEmp
			RpcClearEnv()
			RpcSetType(3)
			RpcSetEnv( clEmp, clFil,,,"FIN")
		ElseIf cFilAnt != clFil
			cFilAnt := clFil
		EndIf

		dOldDtBase	:= dDataBase
		nDecs		:= MsDecimais(mv_par09)

		dbSelectArea("SX5")
		dbSeek( CriaVar("X5_FILIAL",.F.) +"07")

		While !Eof() .and. X5_TABELA == "07"

			nI++
			If nI > Len(aSitua)
				Aadd(aSitua," ")		// garante um novo elemento
			Endif
			aSitua[nI] := TRIM(X5Descri())
			dbSkip()
		Enddo

		dbSelectArea("SE1")
		dbSetOrder(1)
		If mv_par01 == 1
			dbSeek(xFilial("SE1"))
		Else
			dbGotop()
		Endif

		//-------------------
		// Zera as variaveis
		//-------------------
		For i := 1 to 46 
			For j := 1 to 2
				aVal[I,J] := 0
			Next j
		Next i

		nRecebido	:= 0
		nValJuros	:= 0
		nDesconto	:= 0
		nCorrecao	:= 0
		nVlracess	:= 0
		nMulta		:= 0

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Filtra APENAS os emitidos antes da database, pois este relaณ
		//ณ torio pode ser retroativo.                                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aStru  := SE1->(dbStruct())
		cAliasTmp := "FINR320"
		cQuery := ""
		aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
		cQuery := "SELECT "+SubStr(cQuery,2)
		cQuery +=         ",R_E_C_N_O_ RECNO "
		cQuery += "FROM "+RetSQLName("SE1")+ " SE1 "

		cQuery += "WHERE "//Evita pegar indevidamente o cabecalho dos titulos que possuem desdobramento,duplicando dados

		If mv_par01 == 1
			cQuery += "SE1.E1_FILIAL ='"+xFilial("SE1")+"' AND "
		Endif
		If mv_par14 == 2 //Nao considerar titulos com emissao futura
			cQuery += "SE1.E1_EMISSAO <= '"+Dtos(dDataBase)+"' AND "
		Endif
		cQuery += "SE1.E1_PREFIXO >= '"+MV_PAR04+"' AND "
		cQuery += "SE1.E1_PREFIXO <= '"+MV_PAR05+"' AND "
		If mv_par10 == 2
			cQuery += "SE1.E1_MOEDA = "+Str(MV_PAR09,2)+" AND "
		Endif
		cQuery += " SE1.D_E_L_E_T_=' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
		For nX :=  1 To Len(aStru)
			If aStru[nX][2] <> "C"
				TcSetField(cAliasTmp,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX

		dbSelectArea(cAliasTmp)

		While !Eof()

			dbSelectArea(cAliasTmp)

			If mv_par03 == 1
				If !((cAliasTmp)->E1_TIPO$cTipos)
					(cAliasTmp)->(dbSkip())
					Loop
				Endif
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Considera filtro do usuario - SE1                            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !Empty(cFiltSE1).and.!(&cFiltSE1)
				dbSkip()
				Loop
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Considera filtro do usuario - SED                            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !Empty(cFiltSED)
				SED->(DbSetOrder(1))
				SED->(MsSeek(xFilial()+SE1->E1_NATUREZ))
				If SED->(!&(cFiltSED))
					SE1->(DbSkip())
					Loop
				Endif
			Endif

			IF !Empty(E1_FATURA) .and. Substr(E1_FATURA,1,6) != "NOTFAT" .and. E1_DTFATUR <= dDataBase
				dbSkip()
				Loop
			Endif

			If mv_par01 == 1 .and. E1_FILIAL != xFilial("SE1")
				Exit
			EndIF

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica se  provisขrio ou abatimento ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If E1_TIPO $ MVPROVIS+"/"+MVABATIM
				If E1_TIPO $ MVABATIM	//Somo o valor caso seja abatimento
					If mv_par11 == 1
						nAbt := IIF(dDatabase < E1_BAIXA, xMoeda(E1_VALOR,E1_MOEDA,MV_PAR09,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0)), xMoeda(E1_SALDO,E1_MOEDA,MV_PAR09,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0)))		// no resumo por tipo de titulos
						aVal[35,1] += nAbt
						aVal[35,2] += IIF(nAbt > 0,1,0)
					Endif
				Else
					aVal[16,1] += xMoeda(E1_SALDO,E1_MOEDA,MV_PAR09,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
					aVal[16,2] += IIF(SE1->E1_SALDO > 0,1,0)
				Endif
				dbSkip()
				Loop
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Calcula o faturamento baseado na data base/item 1 analise    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Month(E1_EMISSAO) == Month(dDatabase) .and. Year(E1_EMISSAO) == Year(dDataBase)
				If !(E1_TIPO $MV_CRNEG+"/"+MVRECANT)
					nDias := (E1_VENCREA - E1_EMISSAO)
					If nDias <= 1

						if E1_SALDO == 0 .and. E1_DESDOBR == "1"
							//o cabecalho do titulo com desdobramento deve ser ignorado
						Else

							IF !Empty(E1_BAIXA)
								aVal[1,1] += xMoeda(E1_SALDO,E1_MOEDA,MV_PAR09,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))

								If E1_SALDO > 0
									aVal[1,2] += 1
								EndIf
							Else
								aVal[1,1] += xMoeda(E1_VALOR,E1_MOEDA,MV_PAR09,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
								aVal[1,2] += 1
							EndIf
						EndIf
					Else

						IF !Empty(E1_BAIXA)
							aVal[2,1] += xMoeda(E1_SALDO,E1_MOEDA,MV_PAR09,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
	
							If E1_SALDO > 0
								aVal[2,2] += 1
							EndIf
						Else
							aVal[2,1] += xMoeda(E1_VALOR,E1_MOEDA,MV_PAR09,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
							aVal[2,2] += 1
						EndIf
					Endif

				Endif
			Endif

			nSaldoAtu := 0
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Acumula titulos vencidos/vencer / Item 2 e 3 da analise      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			// Posiciona SE2 ou SE1 para pegar o saldo do titulo correto
			SE1->(DbGoto((cAliasTmp)->RECNO))

			If mv_par08 == 1    // Considera Data Base
				dDataBase := mv_par13
			Endif
	
			If mv_par08 == 1
				IF !Empty(SE1->E1_BAIXA) .and. IIF(mv_par02 == 1,(SE1->E1_SALDO == 0 .and. SE1->E1_BAIXA <= dDataBase),.F.)
					nSaldoAtu := 0
				Else
					nSaldoAtu := SaldoTit( 	E1_PREFIXO,;
												E1_NUM,;
												E1_PARCELA,;
												E1_TIPO,;
												E1_NATUREZ,;
												"R",;
												E1_CLIENTE,;
												MV_PAR09,;
												dDataBase,;
												dDataBase,;
												E1_LOJA,;
												E1_FILIAL,;
												IIf(cPaisLoc=="BRA",E1_TXMOEDA,0),nTipoData )

					// Subtrai decrescimo para recompor o saldo na data escolhida.
					If Str(SE1->E1_VALOR,17,2) == Str(nSaldoAtu,17,2) .And. SE1->E1_DECRESC > 0 .And. SE1->E1_SDDECRE == 0
						nSaldoAtu -= SE1->E1_DECRESC
					Endif
					// Soma Acrescimo para recompor o saldo na data escolhida.
					If Str(SE1->E1_VALOR,17,2) == Str(nSaldoAtu,17,2) .And. SE1->E1_ACRESC > 0 .And. SE1->E1_SDACRES == 0
						nSaldoAtu += SE1->E1_ACRESC
					Endif

				Endif
			Else
				If cPaisLoc == "BRA"
					nSaldoAtu := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),E1_MOEDA,mv_par09,,,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
				Else
					nSaldoAtu := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),E1_MOEDA,mv_par09,E1_EMISSAO,nDecs+1,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
				EndIf
			Endif

			nSaldoAtu -= FaDescFin("SE1",dDataBase,nSaldoAtu,1)

			nValAbat := 0
			If !(E1_TIPO $MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM)
				// Se considerar titulos com emissao futura, envia a data de ref. para Somaabat para que ela considere os
				// titulos de abatimento com emissao <= Database + 40 anos (30 * 480) - Emissao futura
				nValAbat := SomaAbat(E1_PREFIXO,E1_NUM,E1_PARCELA,"R",1,,E1_CLIENTE,E1_LOJA,E1_FILIAL,If(mv_par14==1,dDataBase+(30*480),dDataBase))
			Endif

			If nSaldoAtu > 0 .and. (mv_par11 == 1 .or. STR(nSaldoAtu,17,2) == STR(nValAbat,17,2))
				nSaldoAtu-= nValAbat
			Endif
			nSaldoAtu:=Round(NoRound(nSaldoAtu,3),2)

			If nSaldoAtu > 0
				dBaixa := dDataBase
				nJuros := 0
				If mv_par06 == 1
					fa070juros(mv_par09)
				Endif

				lAdto := E1_TIPO $ MVRECANT+"/"+MV_CRNEG

				If E1_VENCREA < dDataBase
					nSaldoAtu+=nJuros
					nDias := (dDatabase - E1_VENCTO)
					
					If lValAcess
						If mv_par15 == 1
							//Calculo de Valor Acessorio 
							nSaldoAtu += FValAcess(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NATUREZ, Iif(Empty(SE1->E1_BAIXA),.F.,.T.),"","R",MV_PAR13)
						EndIf
					Endif

					aVal[34,1] += nSaldoAtu

					If !lAdto
						If nDias <= 15
							aVal[38,1] += nSaldoAtu
							aVal[38,2] += 1
						ElseIf nDias > 15 .And. nDias <= 30
							aVal[3,1] += nSaldoAtu
							aVal[3,2] += 1
						ElseIf nDias > 30 .And. nDias <= 60
							aVal[4,1] += nSaldoAtu
							aVal[4,2] += 1
						ElseIf nDias > 60 .And. nDias <= 90
							aVal[5,1] += nSaldoAtu
							aVal[5,2] += 1
						Else
							aVal[6,1] += nSaldoAtu
							aVal[6,2] += 1
						Endif
					Endif
				Else
					If !lAdto

						aVal[34,1] += nSaldoAtu

						nDias      := (E1_VENCREA - dDatabase)
						If nDias <= 15
							aVal[39,1] += nSaldoAtu
							aVal[39,2] += 1
						ElseIf nDias > 15 .And. nDias <= 30
							aVal[7,1] += nSaldoAtu
							aVal[7,2] += 1
						ElseIf nDias > 30 .And. nDias <= 60
							aVal[8,1] += nSaldoAtu
							aVal[8,2] += 1
						ElseIf nDias > 60 .And. nDias <= 90
							aVal[9,1] += nSaldoAtu
							aVal[9,2] += 1
						Else
							aVal[10,1] += nSaldoAtu
							aVal[10,2] += 1
						EndIF
					Endif
				EndIF
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Calcula a distribuicao de cobranca / item 4  analise         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nSaldoAtu > 0
				IF !(E1_TIPO $MV_CRNEG+"/"+MVRECANT)
					Do Case
						Case E1_SITUACA   $ " 0FG"

							aVal[25,1] += nSaldoAtu
							aVal[25,2] += 1

						Case E1_SITUACA   $ "1H"
							aVal[26,1] += nSaldoAtu
							aVal[26,2] += 1
						Case E1_SITUACA   = "2"
							aVal[27,1] += nSaldoAtu
							aVal[27,2] += 1
						Case E1_SITUACA   = "3"
							aVal[28,1] += nSaldoAtu
							aVal[28,2] += 1
						Case E1_SITUACA   = "4"
							aVal[29,1] += nSaldoAtu
							aVal[29,2] += 1
						Case E1_SITUACA   = "5"
							aVal[30,1] += nSaldoAtu
							aVal[30,2] += 1
						Case E1_SITUACA   = "6"
							aVal[31,1] += nSaldoAtu
							aVal[31,2] += 1
						Case E1_SITUACA   = "7"
							aVal[37,1] += nSaldoAtu
							aVal[37,2] += 1
					EndCase
				Endif
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Valor Recebido.     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nFirst1 == 1
				SA6->(dbSetorder(1)) // para pegar a moeda do banco.
				dbSelectArea("SE5")
				If mv_par01 == 1
					dbSeek(xFilial("SE5"))
				Else
					dbGotop()
				Endif

				aStru  := SE5->(dbStruct())
				cAliasSe5 := "NEWSE5"
				cCondFil := ""
				aEval(aStru,{|x| cCondFil += ","+AllTrim(x[1])})
				cCondFil := "SELECT "+SubStr(cCondFil,2)
				cCondFil +=         ",R_E_C_N_O_ RECNO "
				cCondFil += "FROM "+RetSQLName("SE5") + " SE5 "
				cCondFil += "WHERE "
				If mv_par01 == 1
					cCondFil += "E5_FILIAL='" + xFilial("SE5") + "' AND "
				Endif
				cCondFil += "E5_TIPODOC IN ('VL','V2','JR','J2','CM','C2','MT','M2','DC','D2','TL','BA','VA') AND E5_RECPAG = 'R' AND " 
				cCondFil += "E5_PREFIXO >= '"+MV_PAR04+"' AND "
				cCondFil += "E5_PREFIXO <= '"+MV_PAR05+"' AND "
				If mv_par02 == 1
					cCondFil += "E5_DATA >= '"
				ElseIf mv_par02 == 2
					cCondFil += "E5_DTDIGIT >= '"
				ElseIf mv_par02 == 3
					cCondFil += "E5_DTDISPO >= '"
				Endif
				cCondFIl += Subs(dtos(dDataBase),1,6)+"01"+"' AND "
				If mv_par02 == 1
					cCondFil += "E5_DATA <= '"
				ElseIf mv_par02 == 2
					cCondFil += "E5_DTDIGIT <= '"
				ElseIf mv_par02 == 3
					cCondFil += "E5_DTDISPO <= '"
				Endif
				cCondFIl += Dtos(LastDay(dDataBase))+"' AND "
				cCondFil += "D_E_L_E_T_=' ' "

				cCondFil := ChangeQuery(cCondFil)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cCondFil),cAliasSe5,.T.,.T.)
				
				For nX :=  1 To Len(aStru)
					If aStru[nX][2] <> "C"
						TcSetField(cAliasSe5,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
					EndIf
				Next nX

				DbSelectArea(cAliasSe5)
				DbGoTop()

				While (mv_par01 != 1 .OR. xFilial("SE5") == (cAliasSe5)->E5_FILIAL) .AND. !Eof()

					// Ignora registros que nao sao da moeda quando escolhido nao imprimir
					SA6->(dbSeek(xFilial()+(cAliasSe5)->E5_BANCO+(cAliasSe5)->E5_AGENCIA+(cAliasSe5)->E5_CONTA))
					If mv_par10 == 2 .AND. Max(SA6->A6_MOEDA, 1) != mv_par09
						dbSkip()
						Loop
					Endif

					nMoedaBco := If(SA6->(Found()), Max(SA6->A6_MOEDA, 1), 1)

					If mv_par02 == 1
						dDataBaixa := (cAliasSe5)->E5_DATA
					ElseIf mv_par02 == 2
						dDataBaixa := (cAliasSe5)->E5_DTDIGIT
					ElseIf mv_par02 == 3
						dDataBaixa := (cAliasSe5)->E5_DTDISPO
					Endif

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Valor Recebido.   ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If Month(dDatabase)== Month(dDataBaixa) .and.;
						Year(dDataBase) ==Year(dDataBaixa)   .and.;
						(cAliasSe5)->E5_RECPAG=="R" .and. dDataBaixa <= dDatabase .AND.;
						(cAliasSe5)->E5_TIPODOC$"VL/V2/BA" ;
						.and.  (cAliasSe5)->E5_SITUACA <> "C" .and. ;
						(	MovBcoBx((cAliasSe5)->E5_MOTBX) .or. ;
						((cAliasSe5)->E5_MOTBX=="CMP" .and. (cAliasSe5)->E5_TIPO $ MVRECANT+"#"+MV_CRNEG ) )

						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Verifica se existe estorno para esta baixa                       ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						SE5->(dbGoto((cAliasSe5)->RECNO))

						If !TemBxCanc((cAliasSe5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
							nRecebido += xMoeda((cAliasSe5)->E5_VALOR,nMoedaBco,mv_par09,(cAliasSe5)->E5_DATA,nDecs+1,,If(cPaisLoc=="BRA",(cAliasSe5)->E5_TXMOEDA,0))
						EndIf
					EndIf

				If Month(dDatabase) = Month(dDataBaixa) .and. ;
					Year(dDataBase)  = Year(dDataBaixa)  .and. (cAliasSe5)->E5_RECPAG=="R" .and. ;
					dDataBaixa <= dDatabase .and. (cAliasSe5)->E5_SITUACA <> "C" .and. ;
					MovBcoBx((cAliasSe5)->E5_MOTBX)
					nValorE5 := xMoeda((cAliasSe5)->E5_VALOR,nMoedaBco,mv_par09,(cAliasSe5)->E5_DATA,nDecs+1,,If(cPaisLoc=="BRA",(cAliasSe5)->E5_TXMOEDA,0))
					Do Case
						Case (cAliasSe5)->E5_TIPODOC $ "JR/J2/TL"  //Valor juros
							nValJuros += nValorE5
							Case (cAliasSe5)->E5_TIPODOC $ "CM/C2"     //Valor da correcao
							nCorrecao += nValorE5
							Case (cAliasSe5)->E5_TIPODOC $ "MT/M2"     //Valor da Multa
							nMulta    += nValorE5
							Case (cAliasSe5)->E5_TIPODOC $ "DC/D2"     //Valor do Desconto
							ndesconto += nValorE5
							Case (cAliasSe5)->E5_TIPODOC $ "VA"     //Valor Acess๓rio
							nVlrAcess += nValorE5
						EndCase
					EndIf
					dbSelectArea(cAliasSe5)
				dbSkip()
				Enddo

				dbSelectArea(cAliasSe5)
				dbCloseArea()
				dbSelectArea("SE5")

				nFirst1++
				dbSelectArea(cAliasTmp)
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Calcula a distribuicao por tipo de titulo / item 5 analise   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nSaldoAtu > 0 .and. (mv_par14 == 1 .Or. E1_EMISSAO <= dDatabase)
				Do Case
					Case E1_TIPO  $ MVDUPLIC

						aVal[11,1] += nSaldoAtu
						aVal[11,2] += 1

					Case E1_TIPO  $ MVNOTAFIS
						aVal[12,1] += nSaldoAtu
						aVal[12,2] += 1
					Case E1_TIPO  $ MVCHEQUES
						aVal[13,1] += nSaldoAtu
						aVal[13,2] += 1
					Case E1_TIPO   = "CN"
						aVal[14,1] += nSaldoAtu
						aVal[14,2] += 1
					Case E1_TIPO  $ MVTAXA
						aVal[15,1] += nSaldoAtu
						aVal[15,2] += 1
					Case E1_TIPO  $ MVRECANT
						aVal[24,1] += nSaldoAtu
						aVal[24,2] += 1
					Case E1_TIPO $ MV_CRNEG
						aVal[36,1] += nSaldoAtu
						aVal[36,2] += 1
					OtherWise
						aVal[16,1]  += nSaldoAtu
						aVal[16,2]  += 1
				EndCase
			End

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Calcula T.Carteira pedidos a entregar / item 6 da analise    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nFirst == 1 .and. mv_par12 == 1
				dbSelectArea("SC6")
				cCondSC6 := 'C6_QTDVEN > C6_QTDENT '
				cArq :=CriaTrab("",.F.)
				nIndex:=RetIndex("SC6")
				If mv_par01 == 1
					dbSeek(cFilial)
				Else
					dbGotop()
				Endif

				While !Eof()

					IF mv_par01 == 1 .and. cFilial != C6_FILIAL
							Exit
					Endif

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Posicionar do SC5 para localiza moeda do pedido              ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					dbSelectArea( "SC5" )
					dbSeek( cFilial + SC6->C6_NUM )
					dbSelectArea( "SC6" )
		
				 	// Calcula se moeda for igual a escolhida ou for para converter
				 	If SC5->C5_MOEDA == mv_par09 .OR. mv_par10 == 1
					nSaldo := xMoeda(FC320Saldo(mv_par07),SC5->C5_MOEDA, mv_par09,SC5->C5_EMISSAO,nDecs+1)
					If nSaldo > 0
							If dDatabase < C6_ENTREG // itens a vencer
								nDias := (C6_ENTREG - dDatabase)
								If nDias <= 30
									aVal[17,2]++
									aVal[17,1]+= nSaldo
								ElseIf nDias > 30 .And. nDias <= 60
									aVal[18,2]++
									aVal[18,1]+= nSaldo
								ElseIf nDias > 60 .And. nDias <= 90
									aVal[19,2]++
									aVal[19,1]+= nSaldo
								Else
									aVal[20,2]++
									aVal[20,1]+= nSaldo
								Endif
							Else // itens vencidos
								nDias := (dDatabase - C6_ENTREG)
								aVal[21,2]++
								aVal[21,1]+= nSaldo
							EndIf
						Endif
					Endif
				dbSkip()
				EndDo
				RetIndex("SC6")
				Set Filter to
				Ferase(cArq+OrdBagExt())
				nFirst++
				dbSelectArea(cAliasTmp)
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Calcula o P.M.A e P.M.P - indices / item 7 da analise        ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nSaldoAtu != 0

				aVal[22,1] += (E1_VENCREA-E1_EMISSAO)
				aVal[22,2] += 1
				aVal[23,1] += (E1_VENCREA-E1_EMISSAO)*;
						   xMoeda(nSaldoAtu,E1_MOEDA,mv_par09,E1_EMISSAO,nDecs+1,If(cPaisLoc=="BRA",E1_TXMOEDA,0))
				aVal[23,2] +=  xMoeda(nSaldoAtu,E1_MOEDA,mv_par09,E1_EMISSAO,nDecs+1,If(cPaisLoc=="BRA",E1_TXMOEDA,0))

			EndIf
			dbSelectArea(cAliasTmp)
			nSaldoAtu:=0
		dbSkip()
		Enddo

		dbSelectArea(cAliasTmp)
		dbCloseArea()
		dbSelectArea("SE1")

		dbSelectArea("SE1")
		dbSetOrder(1)
		Set Filter to

		dbSelectArea("SE5")
		dbSetOrder(1)
		Set Filter to

		aVal[40,1] := nRecebido
		aVal[41,1] := nValJuros
		aVal[42,1] := nMulta
		aVal[43,1] := nCorrecao
		aVal[44,1] := nDesconto
		aVal[45,1] := nVlrAcess
		aVal[46,1] := nRecebido-(nValJuros+nMulta+nCorrecao-nDesconto+nvlracess)
		dDataBase  := dOldDtBase // Restaura Data base

		Aadd(aRetVal,AClone(aVal))

	Next nlI
	RpcClearEnv()

Return aRetVal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFC320SaldoบAutor  ณMicrosiga           บ Data ณ 30/11/10    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o saldo do item do pedido                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FC320Saldo(mv_par07)
	Local nRetSaldo := 0

	If (C6_QTDVEN-C6_QTDENT) > 0 .And. C6_BLQ != "R"
		If !Empty( SC6->C6_TES )
			dbSelectArea("SF4")
	 		dbSetOrder(1)
			dbSeek( xFilial("SF4")+SC6->C6_TES )
			nRetSaldo := SC6->C6_PRCVEN * (SC6->C6_QTDVEN - SC6->C6_QTDENT)
			If mv_par07 == 1		// Verifica se ir  considerar o TES (F4_DUPLIC)
				nRetSaldo := 0
				If SF4->F4_DUPLIC == "S"
					nRetSaldo := SC6->C6_PRCVEN * (SC6->C6_QTDVEN - SC6->C6_QTDENT)
				Endif
			EndIf
		EndIf
	EndIf
	dbSelectArea("SC6")
	
Return(nRetSaldo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINC320   บAutor  ณFabricio Romera     บ Data ณ  11/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tree para tela de consulta.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320MtaTree(oDlg, aPosObj)

Local nX		:= 0
Local n1		:= 0
Local n2		:= 0
Local n3		:= 0
Local n4		:= 0
Local n5		:= 0
Local cCargo	:= ""
Local lCont		:= .T.

	//Atualiza estrutura do cargo para considerar emp/fil
	For nX := 1 to Len(aGlobal)
		cCargo := AllTrim( Left(aGlobal[nX][10], nTamN1) + "." + AllTrim( aGlobal[nX][4] ) + "." + ;
							AllTrim( aGlobal[nX][5] )+ "." + AllTrim( aGlobal[nX][6] ) + "." + AllTrim( aGlobal[nX][7] ))

		lCont := .T.
		//Retira "." remanescentes
		While lCont
			If Right(cCargo, 1) = "."
				cCargo := AllTrim( Left(cCargo, Len(cCargo)-1) )
			Else
				lCont := .F.
			End If
		End

		aGlobal[nX][10] := cCargo

	Next

	//Prepara arrays de sub-niveis
	For nX := 1 to Len(aGlobal)

		//Verifica nao eh primeiro nivel
		If !( Len(aGlobal[nX][10]) == nTamN1 )

			If nGruGC > 0 .And. nEmpGC	> 0 .And. nUnidGC > 0 .And. nFilGC > 0

				If Len( aGlobal[nX][10] ) == nTamN2
					aAdd( aNivel2, aGlobal[nX] )
				ElseIf Len( aGlobal[nX][10] ) == nTamN3
					aAdd( aNivel3, aGlobal[nX] )
				ElseIf Len( aGlobal[nX][10] ) == nTamN4
					aAdd( aNivel4, aGlobal[nX] )
				ElseIf	Len( aGlobal[nX][10] ) == nTamN5
					aAdd( aNivel5, aGlobal[nX] )
				End If
			Else
				If Len( aGlobal[nX][10] ) == nTamN2
					aAdd( aNivel2, aGlobal[nX] )
				Else
					aAdd( aNivel3, aGlobal[nX] )
				End If
			EndIf

		End If

	Next

	//Alterado FSW - 05/11 (CNI)

	//Monta objeto tree
	oTree := DbTree():New(aPosObj[1], aPosObj[2],aPosObj[3] ,aPosObj[4] ,oDlg,,,.T.) // Cria a Tree
	oTree:bChange := {|| ProcTrees(oTree) }

	oTree:AddTree(STR0116+space(21), .T., , , , , "00"+space(20) ) //"Pos Geral Ctas a Receber"

	//Adiciona itens da Tree
	
	If nGruGC > 0 .And. nEmpGC	> 0 .And. nUnidGC > 0 .And. nFilGC > 0
		For n1 := 1 to Len(aLbx)
	
			//Adiciona Nivel 1
			oTree:AddTree(aLbx[n1][10] + " - " + aLbx[n1][3], .T.,"BMPTABLE","BMPTABLE", , , aLbx[n1][10])
			For n2 := 1 to Len(aNivel2)
	
				//Adiciona Nivel 2
				If Left(aNivel2[n2][10], nTamN1 ) == aLbx[n1][10]
					oTree:AddTree(aNivel2[n2][10] + " - " + aNivel2[n2][3], .T.,"BMPTABLE","BMPTABLE", , , aNivel2[n2][10])
	
					For n3 := 1 to Len(aNivel3)
	
						//Adiciona Nivel 3
						If Left(aNivel3[n3][10], nTamN2 ) == aNivel2[n2][10]
							oTree:AddTree(aNivel3[n3][10] + " - " + aNivel3[n3][3], .T.,"BMPTABLE","BMPTABLE", , , aNivel3[n3][10])
	
							For n4 := 1 to Len(aNivel4)
	
								//Adiciona Nivel 4
								If Left(aNivel4[n4][10], nTamN3 ) == aNivel3[n3][10]
									oTree:AddTree(aNivel4[n4][10] + " - " + aNivel4[n4][3], .T.,"BMPTABLE","BMPTABLE", , , aNivel4[n4][10])
	
									For n5 := 1 to Len(aNivel5)
	
										//Adiciona Nivel 5
										If Left(aNivel5[n5][10], nTamN4 ) == aNivel4[n4][10]
											oTree:AddTreeItem(aNivel5[n5][10] + " - " + aNivel5[n5][3],"BMPTRG","BMPTRG",aNivel5[n5][10])
										End If
	
									Next
	
									oTree:EndTree()
								End If
	
							Next
	
							oTree:EndTree()
						End If
	
					Next
	
					oTree:EndTree()
				End If
			Next
			oTree:EndTree()
	
		Next nX
	Else
		//Sem Gestใo corporativa

		For n1 := 1 to Len(aLbx)
			//Adiciona Nivel 1
			oTree:AddTree(aLbx[n1][10] + " - " + aLbx[n1][3], .T.,"BMPTABLE","BMPTABLE", , , aLbx[n1][10])
			For n2 := 1 to Len(aNivel2)
				//Adiciona Nivel 2 -- Grupo de Empresas 
				If Left(aNivel2[n2][10], nTamN1 ) == aLbx[n1][10]
					oTree:AddTree(aNivel2[n2][10] + " - " + aNivel2[n2][3], .T.,"BMPTABLE","BMPTABLE", , , aNivel2[n2][10])
					For n3 := 1 to Len(aNivel3)
						//Adiciona Nivel 3 -- Filial
						If Left(aNivel3[n3][10], nGruGC+nFilGC+1 ) == aNivel2[n2][10]
							oTree:AddTreeItem(aNivel3[n3][10] + " - " + aNivel3[n3][3],"BMPTRG","BMPTRG",aNivel3[n3][10])
						EndIf
					Next n3
					oTree:EndTree()
				End If
			Next n2
			oTree:EndTree()
		Next n1	
	EndIf

	oTree:EndTree()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINC320   บAutor  ณFabricio Romera     บ Data ณ  11/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta get dados para visualizacao do item selecionado na    บฑฑ
ฑฑบ          ณtree.                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320MtaGetDad(oDlg, oGetDados, aPosObj)

	//Monta aHeader
	aAdd(aHeader, {STR0120	, "C1_NUM", "", 15, 0, .T., "", "C", "", ""} ) //"GRUPO"
	aAdd(aHeader, {STR0121	, "C1_NUM", "", 15, 0, .T., "", "C", "", ""} ) //"EMPRESA"
	aAdd(aHeader, {STR0122	, "C1_NUM", "", 15, 0, .T., "", "C", "", ""} ) //"UNIDADE"
	aAdd(aHeader, {STR0123	, "C1_NUM", "", 15, 0, .T., "", "C", "", ""} ) //"FILIAL"
	aAdd(aHeader, {STR0124	, "C1_NUM", "@E 999,999,999,999,999.99", 40, 2, .T., "", "N", "", ""} ) //"VALOR"
	aAdd(aHeader, {STR0125	, "C1_NUM", "@E 999,999,999.99", 20, 2, .T., "", "N", "", ""} ) //"QUANTIDADE"

	//Monta aCols
	aCols := {}
	aAdd( aCols, {Space(30),Space(30),Space(30),Space(30),0,0,.F.})

	//Monta GetDados
	oGetDados := MsGetDados():New(aPosObj[1],aPosObj[2], aPosObj[3], aPosObj[4], 2, "AlwaysTrue", "AlwaysTrue", "",.F.,{}, , .F., 200, "AlwaysTrue", "AlwaysFalse", ,"AlwaysFalse", oDlg)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcTrees บAutor  ณFabricio Romera     บ Data ณ  05/17/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcTrees(oTree)

Local nPos := 0
Local cCargo := ""

    cCargo := Trim(oTree:GetCargo())
	aCols  := {}
	
	If nGruGC > 0 .And. nEmpGC	> 0 .And. nUnidGC > 0 .And. nFilGC > 0

		If Len(cCargo) == nTamN1
	
			If cCargo == "00"
				aAdd( aCols, {Space(20),Space(20),Space(20),Space(20),0,0,.F.})
			Else
	
				//Busca item selecionado
				nPos := aScan( aLbx, {|x| x[10] = cCargo } )
	
				//Atualiza aCols
				aAdd(aCols, { 	aLbx[nPos][4], ;
								aLbx[nPos][5], ;
								aLbx[nPos][6], ;
								aLbx[nPos][7], ;
								aLbx[nPos][8], ;
								aLbx[nPos][9], ;
								.F.} )
	
			End	If
	
		ElseIf Len( cCargo ) == nTamN2
	
			//Busca item selecionado
			nPos := aScan( aNivel2, {|x| x[10] = cCargo } )
	
			//Atualiza aCols
			aAdd(aCols, { 	aNivel2[nPos][ 4], ;
							aNivel2[nPos][ 5], ;
							aNivel2[nPos][ 6], ;
							aNivel2[nPos][ 7], ;
							aNivel2[nPos][ 8], ;
							aNivel2[nPos][ 9], ;
						   	.F.} )
	
		ElseIf Len( cCargo ) == nTamN3
	
			//Busca item selecionado
			nPos := aScan( aNivel3, {|x| x[10] = cCargo } )
	
			//Atualiza aCols
			aAdd(aCols, { 	aNivel3[nPos][ 4], ;
							aNivel3[nPos][ 5], ;
							aNivel3[nPos][ 6], ;
							aNivel3[nPos][ 7], ;
							aNivel3[nPos][ 8], ;
							aNivel3[nPos][ 9], ;
							.F.} )
	
		ElseIf Len( cCargo ) == nTamN4
	
			//Busca item selecionado
			nPos := aScan( aNivel4, {|x| x[10] = cCargo } )
	
			//Atualiza aCols
			aAdd(aCols, { 	aNivel4[nPos][ 4], ;
							aNivel4[nPos][ 5], ;
							aNivel4[nPos][ 6], ;
							aNivel4[nPos][ 7], ;
							aNivel4[nPos][ 8], ;
							aNivel4[nPos][ 9], ;
						   	.F.} )
	
		ElseIf Len( cCargo ) == nTamN5
	
			//Busca item selecionado
			nPos := aScan( aNivel5, {|x| x[10] = cCargo } )
	
			//Atualiza aCols
			aAdd(aCols, { 	aNivel5[nPos][ 4], ;
							aNivel5[nPos][ 5], ;
							aNivel5[nPos][ 6], ;
							aNivel5[nPos][ 7], ;
							aNivel5[nPos][ 8], ;
							aNivel5[nPos][ 9], ;
						   	.F.} )
	
		End If
		
	Else
	
		If Len(cCargo) == nTamN1
	
			If cCargo == "00"
				aAdd( aCols, {Space(20),Space(20),Space(20),Space(20),0,0,.F.})
			Else
	
				//Busca item selecionado
				nPos := aScan( aLbx, {|x| x[10] = cCargo } )
	
				//Atualiza aCols
				aAdd(aCols, { 	aLbx[nPos][4], ;
								aLbx[nPos][5], ;
								aLbx[nPos][6], ;
								aLbx[nPos][7], ;
								aLbx[nPos][8], ;
								aLbx[nPos][9], ;
								.F.} )
	
			End	If
			
		ElseIf Len( cCargo ) == nTamN2
	
			//Busca item selecionado
			nPos := aScan( aNivel2, {|x| x[10] = cCargo } )
	
			//Atualiza aCols
			aAdd(aCols, { 	aNivel2[nPos][ 4], ;
							aNivel2[nPos][ 5], ;
							aNivel2[nPos][ 6], ;
							aNivel2[nPos][ 7], ;
							aNivel2[nPos][ 8], ;
							aNivel2[nPos][ 9], ;
						   	.F.} )
						   	
		Else
			//Busca item selecionado
			nPos := aScan( aNivel3, {|x| x[10] = cCargo } )
	
			//Atualiza aCols
			aAdd(aCols, { 	aNivel3[nPos][ 4], ;
							aNivel3[nPos][ 5], ;
							aNivel3[nPos][ 6], ;
							aNivel3[nPos][ 7], ;
							aNivel3[nPos][ 8], ;
							aNivel3[nPos][ 9], ;
						   	.F.} )
		
		EndIF
	
	EndIf

	oGetDados:ForceRefresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFC320REL  บAutor  ณFabricio Romera     บ Data ณ  05/17/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC320REL()

	Local cPerg	     := "FC320REL"
	Local cTitulo    := STR0116 //"Cons Geral Ctas Pagar"

	Local oDados1
	Local oReport
	Local aDados  	 := {aLbx, aNivel2, aNivel3, aNivel4, aNivel5}
	Local cTrb 		 := GetNextAlias()
	Local nNivMax 	 := 2
	Local bTabulacao := {|| Space( Len(AllTrim(TRB_NIVEL)) - 2 ) + TRB_NIVEL }
	Local bLimpaVal  := {|| If( Empty(TRB_NIVEL), NIL, TRB_VALOR ) }
	Local bLimpaQtd  := {|| If( Empty(TRB_NIVEL), NIL, TRB_QUANT ) }
	Local aOrd       := {}

	Pergunte( cPerg, .F. )

	oReport := TReport():New("FC320REL",cTitulo,cPerg,;
	{|oReport| DefPrint( oReport, aOrd, cTitulo, aDados, mv_par01, cTrb )}, STR0117) //"Este relat๓rio irแ imprimir informa็๕es do contas a pagar conforme dados aprensentados na tela de consulta."

	DEFINE SECTION oDados1 OF oReport TABLES cTrb TITLE cTitulo ORDERS aOrd
	DEFINE CELL NAME "TRB_NIVEL"	OF oDados1 ALIAS cTrb TITLE STR0118 SIZE 30 BLOCK bTabulacao  											//"NIVEL"
	DEFINE CELL NAME "TRB_DESCR"	OF oDados1 ALIAS cTrb TITLE STR0119 SIZE 30  															//"DESCRIวรO"
	DEFINE CELL NAME "TRB_GRUPO"	OF oDados1 ALIAS cTrb TITLE STR0120 																	//"GRUPO"
	DEFINE CELL NAME "TRB_EMPRES"	OF oDados1 ALIAS cTrb TITLE STR0121 																	//"EMPRESA"
	DEFINE CELL NAME "TRB_UNIDAD"	OF oDados1 ALIAS cTrb TITLE STR0122 																	//"UNIDADE"
	DEFINE CELL NAME "TRB_FILIAL"	OF oDados1 ALIAS cTrb TITLE STR0123 																	//"FILIAL"
	DEFINE CELL NAME "TRB_VALOR"	OF oDados1 ALIAS cTrb TITLE STR0124 SIZE 10 BLOCK bLimpaVal PICTURE	"@E 999,999,999,999,999.99"	ALIGN CENTER 	//"VALOR"
	DEFINE CELL NAME "TRB_QUANT"	OF oDados1 ALIAS cTrb TITLE STR0125 SIZE 10 BLOCK bLimpaQtd PICTURE	"@E 999,999,999,999,999.99"	ALIGN CENTER	//"QUANTIDADE"

	oDados1:OnPrintLine( {||oReport:SkipLine()})
	
	oReport:PrintDialog()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDefPrint  บAutor  ณFabricio Romera     บ Data ณ  05/17/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFC320REL                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DefPrint( oReport, aOrd, cTitulo, aDados, nNivMax, cTrb)

Local oSection1 := oReport:Section(1)

	//Cria arquivo de trabalho
	aStru := {}
	AADD(aStru,{"TRB_NIVEL"		, "C", 15, 0})
	AADD(aStru,{"TRB_DESCR"		, "C", 30, 0})
	AADD(aStru,{"TRB_GRUPO"		, "C",  2, 0})
	AADD(aStru,{"TRB_EMPRES"	, "C",  2, 0})
	AADD(aStru,{"TRB_UNIDAD"	, "C",  2, 0})
	AADD(aStru,{"TRB_FILIAL"	, "C",  3, 0})
	AADD(aStru,{"TRB_VALOR"		, "N", 30, 2})
	AADD(aStru,{"TRB_QUANT"		, "N", 15, 2})
	AADD(aStru,{"TRB_ORDEM"		, "C",  2, 0})

	If _oFINC3201 <> Nil
		_oFINC3201:Delete()
		_oFINC3201	:= Nil
	Endif	

	_oFINC3201 := FWTemporaryTable():New(cTrb)
	_oFINC3201:SetFields( aStru )
	
	aChave   := {"TRB_NIVEL","TRB_DESCR","TRB_GRUPO","TRB_EMPRES","TRB_UNIDAD","TRB_FILIAL","TRB_VALOR","TRB_QUANT", "TRB_ORDEM"}
	
	_oFINC3201:AddIndex("1", aChave)
	_oFINC3201:Create()
	
	//Preenche arquivo de trabalho conforme dados da tela
	PreencheTRB(aDados, cTrb, nNivMax)

	oReport:SetTitle(cTitulo)

	oSection1:Print()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPreencheTRBบAutor  ณFabricio Romera    บ Data ณ  05/19/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PreencheTRB(aDados, cAlias, nNivMax)

Local n1, n2, n3, n4, n5 := 0
Local aLinBranco := {"", "", "", "", "", "", "", 0, 0, ""}
Default nNivMax := 0

	//Varre array de dados e grava informacoes na tabela temporaria
	For n1 := 1 to Len(aDados[1])

		//Adiciona Nivel 1
		GravaRecTRB(aDados[1][n1], cAlias)

		For n2 := 1 to Len(aDados[2])

			//Adiciona Nivel 2
			If Left(aDados[2][n2][10], nTamN1 ) == aDados[1][n1][10] .And. nNivMax > 1

				GravaRecTRB(aDados[2][n2], cAlias)

				For n3 := 1 to Len(aNivel3)

					//Adiciona Nivel 3
					If Left(aDados[3][n3][10], nTamN2 ) == aDados[2][n2][10] .And. nNivMax > 2

						GravaRecTRB(aDados[3][n3], cAlias)

						For n4 := 1 to Len(aDados[4])

							//Adiciona Nivel 4
							If Left(aDados[4][n4][10], nTamN3 ) == aDados[3][n3][10] .And. nNivMax > 3

								GravaRecTRB(aDados[4][n4], cAlias)

								For n5 := 1 to Len(aDados[5])

									//Adiciona Nivel 5
									If Left(aDados[5][n5][10], nTamN4 ) == aDados[4][n4][10] .And. nNivMax > 4
										GravaRecTRB(aDados[5][n5], cAlias)
									End If

								Next

							End If

						Next

					End If

				Next

			End If

		Next

	Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaRecTRB บAutor  ณFabricio Romera   บ Data ณ  05/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PreencheTRB                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaRecTRB(aDados, cAlias)

	DbSelectArea(cAlias)
	
	RecLock(cAlias,.T.)
		(cAlias)->( TRB_NIVEL  ) := aDados[10]
		(cAlias)->( TRB_DESCR  ) := aDados[3]
		(cAlias)->( TRB_GRUPO  ) := aDados[4]
		(cAlias)->( TRB_EMPRES ) := aDados[5]
		(cAlias)->( TRB_UNIDAD ) := aDados[6]
		(cAlias)->( TRB_FILIAL ) := aDados[7]
		(cAlias)->( TRB_VALOR  ) := aDados[8]
		(cAlias)->( TRB_QUANT  ) := aDados[9]
		(cAlias)->( TRB_ORDEM  ) := aDados[10]
	MsUnlock()

Return
