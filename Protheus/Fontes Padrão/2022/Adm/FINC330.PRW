#Include "PROTHEUS.CH"
#Include "APWIZARD.CH"
#Include "TBICONN.CH"
#Include "FINC330.CH"
#Include "REPORT.CH"

#Define nTamN1	 2												//XX
#Define nTamN2	 nTamN1 + 1 + Len(AllTrim(FwGrpCompany()))		//XX.XX
#Define nTamN3	 nTamN2 + 1 + Len(AllTrim(FWCompany()))			//XX.XX.X
#Define nTamN4	 nTamN3 + 1 + Len(AllTrim(FWUnitBusiness()))	//XX.XX.X.XX
#Define nTamN5	 nTamN4 + 1 + Len(AllTrim(FWFilial()))			//XX.XX.X.XX.XX

Static __oFINC3301
Static __oFINC3302

//Alterado FSW - 05/11 (CNI) - Adaptacao da rotina para apresentar dados utilizando Tree e tReport para relatorio.

// PACOTE FNC 00000018102010
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |FINC330   บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosicao Geral Contas a Pagar Consolidada                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINC330()

	Private oFolder		:= Nil
	Private aTmpTabs	:= {}
	Private aMarks		:= {}
	Private aPanels		:= {}
	Private aCampos		:= {}
	Private aCpos		:= {}
	Private oWizard		:= Nil
	Private aIndexCab	:= {}
	Private aGetD		:= Nil
	Private aSM0		:= AdmAbreSM0()
	Private cFilExpr	:= ""
	Private nGruGC 		:= Len(FwGrpCompany())
	Private nEmpGC		:= Len(FWCompany())
	Private nUnidGC 	:= Len(FWUnitBusiness())
	Private nFilGC 		:= Len(FWFilial())

	FC330MTRB(aSM0)

	aCpos :=	{{"TRB_OK"		,""	,STR0001			,""},;	//"OK"
				{"TRB_GRUPO"	,""	,STR0002			,""},;	//"Grupo"
				{"TRB_EMP"		,""	,STR0003			,""},;	//"Empresa"
				{"TRB_UNID"	,""	,STR0004			,""},;	//"Unidade"
				{"TRB_FILEMP"	,""	,STR0005			,""}}	//"Filial"

	FC330WZD()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC330Wzd()บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de telas geradas atraves do Wizard                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330WZD()

	Local cMarca	:= GetMark ()
	Local lInverte	:= .F.
	Local lMark		:= .F.

	Local c2Procura	:=	Space(50)
	Local o2Procura
	Local aList		:=	{}
	Local aList2	:=	{}
	Local oFont
	Local oMSSelect
	Local nIndBox

	Local alPergs	:= {}
	Local alRetEmp	:= {}
	Local alGrpEmp	:= {}

	//////////////////////////////////////////
	//Variaveis de usa na tela 3- parametros//
	//////////////////////////////////////////
	Local nlTela	:= 0

	Local nlI		:= 0

	Local alOpc1	:= {STR0006,STR0007									} //"1=Filial"###"2=Empresa"
	Local alOpc2	:= {STR0008,OemToAnsi(STR0009),OemToAnsi(STR0010)	} //"1=Baixa"###"2=Digita็ใo"###"3=Disponibilidade"
	Local alOpc3	:= {STR0011,OemToAnsi(STR0012)						} //"1=Sim"###"2=Nใo"
	Local alOpc4	:= {STR0013,OemToAnsi(STR0014)						} //"1=Considera"###"2=Nใo Considera"
	Local alOpc5	:= {STR0015,STR0016,STR0017,STR0018,STR0019			} //"1=Moeda1"###"2=Moeda2"###"3=Moeda3"###"4=Moeda4"###"5=Moeda5"
	Local alOpc6	:= {STR0020,OemToAnsi(STR0021)						} //"1=Converter"###"2=Nใo Imprimir"

	Local clPicDat	:= CToD("//")

	Private aIndBox	:= {STR0002,STR0003,STR0022,STR0005} //Grupo##Empresa##Unidade##Filial
	Private apRet	:= Array(1,1)
	Private aStru	:= {}
	Private aReturn	:= { STR0003, 1,STR0004, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"

	Define FONT oFont NAME "Arial" SIZE 0, -11
	Define FONT oFontB NAME "Arial" SIZE 0, -11 BOLD

	DEFINE WIZARD oWizard TITLE OemToAnsi(STR0023); //"Resumo Geral do Contas a Pagar"
		HEADER OemToAnsi(STR0024);					//"Parametriza็ใo Resumo Geral do Contas a Pagar"
		MESSAGE "";
		TEXT OemToAnsi(STR0025) +;					//"Esta rotina define os parโmetros necessแrios para o Resumo Geral do Contas a Pagar."
		CRLF +;
		OemToAnsi(STR0027) ;						//"Informe todos os parโmetros corretamente e defina como serแ o processamento da consulta."
		NEXT {||.T.} ;
		FINISH {|| .T. } ;
		PANEL

		//Segunda Pagina
		CREATE PANEL oWizard ;
		HEADER OemToAnsi(STR0030) ;					//"Sele็ใo das Empresas do Grupo"
		MESSAGE STR0031 ;							//"Selecione as empresas"
		BACK {|| .T. } ;
		NEXT {|| alRetEmp := FC330VRFOK(), alGrpEmp := alRetEmp[1], alRetEmp[2] } ;
		FINISH {|| .T. } ;
		PANEL

		@25,05 TO 132,282 LABEL STR0032 OF oWizard:oMPanel[2] PIXEL	//"Grupo de Empresas"
		oMSSelect	:=	MsSelect():New ("TRB", "TRB_OK",,aCpos, @lInverte, @cMarca, {40, 10, 126, 276},,,oWizard:oMPanel[2])
		oMSSelect:oBrowse:lHasMark 	:= 	.f.
		oMSSelect:oBrowse:lCanAllMark	:=	.f.

		oChkMark := TCHECKBOX():Create(oWizard:oMPanel[2])
		oChkMark:cName				:= "oChkMark"
		oChkMark:cCaption			:= STR0033 //'Selecionar Todos '
		oChkMark:nLeft				:= 10
		oChkMark:nTop				:= 05
		oChkMark:nWidth				:= 120
		oChkMark:nHeight			:= 60
		oChkMark:lShowHint			:= .F.
		oChkMark:lReadOnly			:= .F.
		oChkMark:Align				:= 0
		oChkMark:cVariable			:= "lMark"
		oChkMark:bSetGet			:= {|u| If(PCount()>0,lMark:=u,lMark) }
		oChkMark:bChange			:= {||FC330MARC(lMark, cMarca ), oMSSelect:oBrowse:Refresh() }
		oChkMark:lVisibleControl	:= .T.

		oIndBox := TCOMBOBOX():Create(oWizard:oMPanel[2])
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
		oIndBox:bChange 		:= {|| TRB->( dbSetOrder(oIndBox:nAt ) ) }
		oIndBox:lVisibleControl := .T.

		TSay ():New (17, 150, {||STR0034}, oWizard:oMPanel[2],,oFont,.F.,.F.,.F., .T.,,, 100, 10, .F., .F., .F., .F., .F.)	//"Pesquisar"
		o2Procura := TGet ():New (15, 176, {|u| Iif(PCount()==0,c2Procura,c2Procura:=u)}, oWizard:oMPanel[2], 100, 9, "@!",{|| FC330FIND(2,oMSSelect,c2Procura,aList2)},,,,,, .T.)

		//Terceira Pagina
		CREATE PANEL oWizard ;
		HEADER OemToAnsi(STR0035) ;		//"Parโmetros"
		MESSAGE OemToAnsi(STR0036) ; 	//"Informe os parโmetros"
		BACK {|| TRB->(DbGoTop()), .T. } ;
		NEXT {|| .T. } ;
		FINISH {|| MsgRun(STR0112,STR0113,{|| FC330DRILL(alGrpEmp)}),.T. } ;//'Gerando Drill-Down de Visualiza็ใo...'###'Aguarde'
		PANEL

		aADD(alPergs ,{2,STR0038 ,'',alOpc2	,70	,'Pertence("123")'	,.F.}) //'Lista Baixas pela Data da'

		aADD(alPergs ,{1,STR0040 ,'','@!','','','',40,.F.}) //'Prefixo Inicial'
		aADD(alPergs ,{1,STR0041 ,'','@!','','','',40,.F.}) //'Prefixo Final'

		aADD(alPergs ,{2,STR0042 ,'',alOpc3	,40	,'Pertence("12")'		,.F.}) //'Considera Juros'
		aADD(alPergs ,{2,STR0043 ,'',alOpc3	,40	,'Pertence("12")'		,.F.}) //'Considera Pedidos de Compra'
		aADD(alPergs ,{2,STR0044 ,'',alOpc3	,40	,'Pertence("12")'		,.F.}) //'Compoe Saldo Retroativo'
		aADD(alPergs ,{2,STR0045 ,'',alOpc5	,70	,'Pertence("12345")'	,.F.}) //'Qual Moeda'
		aADD(alPergs ,{2,STR0046 ,'',alOpc6	,70	,'Pertence("12")'		,.F.}) //'Outras Moedas'
		aADD(alPergs ,{2,STR0047 ,'',alOpc4	,70 ,'Pertence("12")'		,.F.}) //'TES dos Pedidos de Compras'
		//Valores Acess๓rios
		aADD(alPergs ,{2,STR0115 ,'',alOpc3	,40	,'Pertence("12")'		,.F.})	// "Considera Valores Acess๓rios ?"
		aADD(alPergs ,{1,STR0116 ,'','' ,'','','',50,.F.}) 	// "Data Base"

		 If Len(apRet[1]) == 1
            apRet[1] := Array(Len(alPergs))
            For nlI := 1 to Len(apRet[1])
                If nlI != 11            //Pergunta Data Base
                    apRet[1][nlI] := Space(03)
                Else
                    apRet[1][nlI] := dDatabase
                Endif
            Next nlI
        EndIf

		ParamBox(alPergs ,STR0048 ,apRet[1],,, .T.,,,oWizard:oMPanel[3],, .F.,)

	ACTIVATE WIZARD oWizard CENTERED

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC330MTrb บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Trabalho                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330MTRB(aTrb)

	Local aCampos	:=	{}
	Local cArq		:=	""
	Local nI,Na		:=	0
	Local aIndBox	:= {}
	Local aIndBoxK	:= 	{}
	Local cNewAlias := "TRB"

	aAdd( aCampos,  { "TRB_OK"     ,"C",02,0 } )
	aAdd( aCampos,  { "TRB_GRUPO"  ,"C",IIf(nGruGC >  0, nGruGC , 3 ),0 } )
	aAdd( aCampos,  { "TRB_EMP"    ,"C",IIf(nEmpGC >  0, nEmpGC , 3 ),0 } )
	aAdd( aCampos,  { "TRB_UNID"   ,"C",IIf(nUnidGC > 0, nUnidGC, 2 ),0 } )
	aAdd( aCampos,  { "TRB_FILEMP" ,"C",IIf(nFilGC >  0, nFilGC , 40),0 } )

	If __oFINC3301 <> Nil
		__oFINC3301:Delete()
		__oFINC3301	:= Nil
	Endif	
	
	__oFINC3301 := FWTemporaryTable():New("TRB")
	__oFINC3301:SetFields( aCampos )

	//Adiciona as Chaves de indices
	__oFINC3301:AddIndex("1",{"TRB_GRUPO"} 	)
	__oFINC3301:AddIndex("2",{"TRB_EMP"} 	)
	__oFINC3301:AddIndex("3",{"TRB_UNID"} 	)
	__oFINC3301:AddIndex("4",{"TRB_FILEMP"} 	)

	__oFINC3301:Create()

	For nI := 1 To Len(aTRB)
		RecLock("TRB", .T.)
			TRB->TRB_GRUPO   := aTRB[nI][1]
			TRB->TRB_EMP     := aTRB[nI][3]
			TRB->TRB_UNID    := aTRB[nI][4]
			TRB->TRB_FILEMP  := aTRB[nI][5]
			TRB->(MSUNLOCK())
	Next nI

	TRB->(dbGotop())

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFC330Find บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcura  de acordo com rotina do Wizard                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330FIND(nOpcao,oObj,cProcura,aList)

	Local lRet	:=	.T.
	Local nPos	:=	0

	nPos := aScan(aList,{|aX| AllTrim(cProcura)==Left(aX[1],Len(AllTrim(cProcura)))})

	If nOpcao==1
		oObj:nAT := Iif(nPos==0,1,nPos)
		oObj:Refresh()
	Else
		dbSelectArea("TRB")
		TRB->(dbSeek(AllTrim(cProcura)))
		oObj:oBrowse:Refresh()
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC330Marc บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona opcoes.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330MARC(llMarc,cpMarca)

Local cRec := RECNO()

	dbSelectArea("TRB")
	TRB->(dbGoTop())

	If llMarc
		While TRB->(!Eof())
			If RecLock("TRB",.F.)
				Replace TRB->TRB_OK With cpMarca
				MsUnLock()
			EndIf
			TRB->(dbSkip())
		EndDo
	Else
		While TRB->(!Eof())
			If RecLock("TRB",.F.)
				Replace TRB->TRB_OK With Space(2)
				MsUnLock()
			EndIf
			TRB->(dbSkip())
		EndDo
	EndIf

	TRB->(dbGoto(cRec))    //Posiciona no registro Atual

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao  |FC330VrfOKบAutor  ณMicrosiga             บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica selecao.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330VRFOK()

	Local llReturn	:= .T.
	Local alOk		:= {}

	DbSelectArea('TRB')
	TRB->(DbGoTop())
	While TRB->(!EOF())
		If !Empty(TRB->TRB_OK)
			aAdd(alOk,{TRB->TRB_OK,Iif(!Empty(TRB->TRB_GRUPO),TRB->TRB_GRUPO,"");
								,Iif(!Empty(TRB->TRB_FILEMP),TRB->TRB_FILEMP,"");
								,Iif(!Empty(TRB->TRB_EMP),TRB->TRB_EMP,"");
								,Iif(!Empty(TRB->TRB_UNID),TRB->TRB_UNID,"")})
		EndIf
		TRB->(DbSkip())
	EndDo

	If Empty(alOk)
		llReturn := .F.
		Aviso(OemToAnsi(STR0049),STR0050,{STR0051})
		TRB->(DbGoTop())
	EndIf

Return {alOk, llReturn}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC330DrillบAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta toda estrutura do Drill-Down e atualizacao dos valoresบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAP                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330DRILL(alGrpEmp)

	Local aVal			:= {}
	Local cArqTmp		:= ""
	Local clAlias		:= ""
	Local clHeader		:= ""

	Local lEnchBar		:= .F. // Se a janela de diแlogo possuirแ enchoicebar (.T.)
	Local lPadrao		:= .F. // Se a janela deve respeitar as medidas padr๕es do Protheus (.T.) ou usar o mแximo disponํvel (.F.)
	Local nMinY			:= 400 // Altura mํnima da janela

	Local aSize			:= MsAdvSize(lEnchBar, lPadrao, nMinY)

	Local oOk			:= LoadBitmap( GetResources() , 'PMSMAIS'  ) // Sinal de mais ( + )
	Local oNo			:= LoadBitmap( GetResources() , 'PMSMENOS' ) // Sinal de menos( - )
	Local oFnt1			:= Nil
	Local oDlg			:= Nil

	Local nX			:= 0
	Local nY			:= 0
	Local nZ			:= 0
	Local nlI			:= 0
	Local nlK			:= 0
	Local nlJ			:= 0
	Local nlF			:= 0
	Local nlAte			:= 0
	Local nlTamGlo		:= 0
	Local llNum			:= .T.
	Local nlAux			:= 0

	Local alNiv2		:= {}
	Local alNiv3		:= {}
	Local alNiv4		:= {}
	Local alNiv5		:= {}
	Local clNivel		:= ""

	Local nlGuarda		:= 0
	Local nlCont		:= 1
	Local nlCont2		:= 1
	Local nlCt			:= 0
	Local clDesc		:= ""
	Local nlTotSup		:= 0

	Local aHeadLst		:= {}

	Local clAux			:= ""
	Local clBLine		:= ""
	Local clBkpEmp		:= ""

	Local mv_par06		:= Val(apRet[1][6])
	Local clEmp			:= ""
	Local clFil			:= ""

	Local aButtons		:= {}

	Local aChavAux := {}
	
	Local oSize

	Private aNivel2		:= {}
	Private aNivel3		:= {}
	Private aNivel4		:= {}
	Private aNivel5		:= {}
	Private aCols		:= {}
	Private aHeader		:= {}
	Private oGetDados
	Private oTree
	Private aRotina		:=	{{STR0034	,"AxPesqui",0,1},;	//"Pesquisar"
							{STR0028	,"AxVisual",0,2},;	//"Visualizar"
							{STR0029	,"AxInclui",0,3},;	//"Incluir"
							{STR0026	,"AxAltera",0,4},;	//"Alterar"
							{STR0114	,"AxDeleta",0,5}}	//"Excluir"

	Private cpCondic	:= ""
	Private oLbx		:= Nil
	Private aLbx		:= {}
	Private aGlobal		:= {}
	Private nNivelMin	:= 6
	Private cTipos		:= ""

	//Alterado FSW - 05/11 (CNI)
	AADD(aButtons,{"RELAT",{|| FC330REL()},STR0101,STR0101 }) //Relatorio

	//------------------------------------------------------------
	// Obtem os valores. Processo executado via job para permitir
	// a abertura de ambientes de outros grupos de empresas
	//------------------------------------------------------------
	aVal := StartJob( "FC330Calc" , GetEnvServer() , .T. ,,,,,,@llNum,alGrpEmp,apRet,aReturn)

	aADD(aGlobal,{1, .F.,STR0052," "," "," "," ",0	,0	,"01"}) //"COMPRAS (no mes)"
	aADD(aGlobal,{1, .F.,STR0053," "," "," "," ",0	,0	,"02"}) //"A Vista"
	aADD(aGlobal,{1, .F.,STR0054," "," "," "," ",0	,0	,"03"}) //"A Prazo"

	aADD(aGlobal,{1, .F.,STR0055 ," "," "," "," ",0	,0	,"04"}) //"VALORES BAIXADOS"
	aADD(aGlobal,{1, .F.,STR0056 ," "," "," "," ",0 ,0	,"05"}) //"Recebido"
	aADD(aGlobal,{1, .F.,STR0057 ," "," "," "," ",0	,0	,"06"}) //"Taxa de Juros"
	aADD(aGlobal,{1, .F.,STR0058 ," "," "," "," ",0	,0	,"07"}) //"Multa"
	aADD(aGlobal,{1, .F.,STR0059 ," "," "," "," ",0	,0	,"08"}) //"Correcao"
	aADD(aGlobal,{1, .F.,STR0060 ," "," "," "," ",0	,0	,"09"}) //"Descontos"
	aADD(aGlobal,{1, .F.,STR0061 ," "," "," "," ",0	,0	,"10"}) //"Pgto Antecipado"
	aADD(aGlobal,{1, .F.,STR0062 ," "," "," "," ",0	,0	,"11"})	//"ORIGINAL"

	aADD(aGlobal,{1, .F.,STR0063 ," "," "," "," ",0	,0	,"12"}) //"TITULOS A VENCER"
	aADD(aGlobal,{1, .F.,STR0064 ," "," "," "," ",0	,0	,"13"}) //"Ate 15 Dias"
	aADD(aGlobal,{1, .F.,STR0065 ," "," "," "," ",0	,0	,"14"}) //"De 16 a 30 dias"
	aADD(aGlobal,{1, .F.,STR0066 ," "," "," "," ",0	,0	,"15"}) //"De 31 a 60 dias"
	aADD(aGlobal,{1, .F.,STR0067 ," "," "," "," ",0	,0	,"16"}) //"De 61 a 90 dias"
	aADD(aGlobal,{1, .F.,STR0068 ," "," "," "," ",0	,0	,"17"}) //"Acima de 90 Dias

	aADD(aGlobal,{1, .F.,STR0069 ," "," "," "," ",0	,0	,"18"}) //"TITULOS VENCIDOS"
	aADD(aGlobal,{1, .F.,STR0064 ," "," "," "," ",0	,0	,"19"}) //"Ate 15 Dias"
	aADD(aGlobal,{1, .F.,STR0065 ," "," "," "," ",0	,0	,"20"}) //"De 16 a 30 dias"
	aADD(aGlobal,{1, .F.,STR0066 ," "," "," "," ",0	,0	,"21"}) //"De 31 a 60 dias"
	aADD(aGlobal,{1, .F.,STR0067 ," "," "," "," ",0	,0	,"22"}) //"De 61 a 90 dias"
	aADD(aGlobal,{1, .F.,STR0068 ," "," "," "," ",0	,0	,"23"}) //"Acima de 90 Dias

	aADD(aGlobal,{1, .F.,STR0070 ," "," "," "," ",0	,0	,"24"}) //"POR TIPO DE TITULO"
	aADD(aGlobal,{1, .F.,STR0071 ," "," "," "," ",0	,0	,"25"}) //"Duplicatas"
	aADD(aGlobal,{1, .F.,STR0072 ," "," "," "," ",0	,0	,"26"}) //"Notas Fiscais"
	aADD(aGlobal,{1, .F.,STR0073 ," "," "," "," ",0	,0	,"27"}) //"Cheque Pre-Datados"
	aADD(aGlobal,{1, .F.,STR0090 ," "," "," "," ",0	,0	,"28"}) //"Carne de Pagamento"
	aADD(aGlobal,{1, .F.,STR0074 ," "," "," "," ",0	,0	,"29"}) //"Impostos"
	aADD(aGlobal,{1, .F.,STR0075 ," "," "," "," ",0	,0	,"30"}) //"Pagamentos Antecipados"
	aADD(aGlobal,{1, .F.,STR0076 ," "," "," "," ",0	,0	,"31"}) //"Notas de Debito"
	aADD(aGlobal,{1, .F.,STR0077 ," "," "," "," ",0	,0	,"32"}) //"Outros"

	// Pedidos de Compras
	If Val(apRet[1][6]) == 1
		aADD(aGlobal,{1, .F.,STR0078 ," "," "," "," ",0	,0	,"33"}) //"PEDIDOS DE COMPRA ATRASADOS"
		aADD(aGlobal,{1, .F.,STR0064 ," "," "," "," ",0	,0	,"34"}) //"Ate 15 Dias"
		aADD(aGlobal,{1, .F.,STR0065 ," "," "," "," ",0	,0	,"35"}) //"De 16 a 30 dias"
		aADD(aGlobal,{1, .F.,STR0066 ," "," "," "," ",0	,0	,"36"}) //"De 31 a 60 dias"
		aADD(aGlobal,{1, .F.,STR0067 ," "," "," "," ",0	,0	,"37"}) //"De 61 a 90 dias"
		aADD(aGlobal,{1, .F.,STR0068 ," "," "," "," ",0	,0	,"38"}) //"Acima de 90 Dias

		aADD(aGlobal,{1, .F.,STR0079 ," "," "," "," ",0	,0	,"39"}) //"PEDIDOS DE COMPRA ADIANTADOS"
		aADD(aGlobal,{1, .F.,STR0064 ," "," "," "," ",0	,0	,"40"}) //"Ate 15 Dias"
		aADD(aGlobal,{1, .F.,STR0065 ," "," "," "," ",0	,0	,"41"}) //"De 16 a 30 dias"
		aADD(aGlobal,{1, .F.,STR0066 ," "," "," "," ",0	,0	,"42"}) //"De 31 a 60 dias"
		aADD(aGlobal,{1, .F.,STR0067 ," "," "," "," ",0	,0	,"43"}) //"De 61 a 90 dias"
		aADD(aGlobal,{1, .F.,STR0068 ," "," "," "," ",0	,0	,"44"}) //"Acima de 90 Dias
	EndIf

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

	nlAte := Iif(!Empty(aGlobal),Len(aGlobal[1])-2,(Aviso(STR0081, STR0080, {STR0001}), -1)) //"Atencao"##"Nenhum arquivo encontrado"##"Ok"
	If nlAte == -1
		Return .F.
	EndIf
	aSort(aGlobal,,,{|aLx, aLy| aLx[10]  <  aLy[10]  })

	FC330Tot(aVal)

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

	aAdd(aHeadLst, STR0082 	)	//DESCRICAO
	aAdd(aHeadLst, STR0083	)	//GRUPO
	aAdd(aHeadLst, STR0084	)	//EMPRESA
	aAdd(aHeadLst, STR0085	)	//UNIDADE
	aAdd(aHeadLst, STR0086	)	//FILIAL
	aAdd(aHeadLst, STR0087	)	//VALORES
	aAdd(aHeadLst, STR0088	)	//QUANTIDADE

	//Define dimensoes da tela
	aSize		:= MsAdvSize(,.F.,430)
	aObjects	:= {{ 100, 157 , .T., .T. }}
	aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPosObj		:= MsObjSize( aInfo, aObjects )
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
	FC330MtaGetDad(@oDlg, @oGetDados,{nLinIni,nColIni,nLinEnd,nColEnd})
	
	nLinIni := oSize:GetDimension("TREE","LININI") 
	nColIni := oSize:GetDimension("TREE","COLINI") 
	nLinEnd := oSize:GetDimension("TREE","LINEND") 
	nColEnd := oSize:GetDimension("TREE","COLEND")

	//Monta Tree
	FC330MtaTree(@oDlg, {nLinIni,nColIni,nLinEnd,nColEnd})

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    |FC330Tot  บAutor  ณMicrosiga           บ Data ณ  30/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTotaliza Valores e quantidades                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAP                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330Tot(aVal)

	Local alNiv2	:= {}
	Local alNiv3	:= {}
	Local alNiv4	:= {}
	Local alNiv5	:= {}

	Local nlI		:= 0
	Local nlJ		:= 0
	Local nlK		:= 0
	Local nlAux		:= 0
	Local nlCt		:= 0
	Local nlCont	:= 1
	Local nlCont2	:= 1

	Local clDesc	:= ""
	Local aRecebido	:= {}
	Local aTxJuros	:= {}
	Local aMulta	:= {}
	Local aCorrecao	:= {}
	Local aDesconto	:= {}

	// Gera os Valores do ultimo Nivel: FILIAL
	For nlI := 1 to Len(aGlobal)
		If aGlobal[nlI][1] == 1
			clDesc := aGlobal[nlI][3]
			nlAux := nlI
			nlCt++

			alNiv5	:= {}
			While nlAux <= Len(aGlobal) .And. clDesc == aGlobal[nlAux][3]
				If aGlobal[nlAux][1] == 5
					aAdd(alNiv5, nlAux)
				EndIf
				nlAux++
			EndDo
			If nlCt == 4 .Or. nlCt == 12 .Or. nlCt == 18 .Or. nlCt == 24 .Or. nlCt == 33 .Or. nlCt == 39
				nlCont++
				nlCont2 := 1
			EndIf
			nlGuarda := nlCont2
			For nlK := 1 to Len(alNiv5)
				nlCont2 := nlGuarda
				If nlCont == 1
					aGlobal[alNiv5[nlK]][8] := aVal[nlK][nlCont][nlCont2]
					aGlobal[alNiv5[nlK]][9] := 0
				ElseIf nlCont == 2
					If nlCont == 2 .And. nlCont2 == 1
						if clDesc == STR0055 //"VALORES BAIXADOS"
							aGlobal[alNiv5[nlK]][8] := aVal[nlK][2][1]
						Else
							aGlobal[alNiv5[nlK]][8] := 0
							aGlobal[alNiv5[nlK]][9] := 0
						EndIf
					ElseIf nlCont == 2 .And. (nlCont2-1) == 7
						if clDesc == STR0062 //"Original"
							aGlobal[alNiv5[nlK]][8] := aRecebido[nlK] + aTxJuros[nlK] + aMulta[nlK] + aCorrecao[nlK] + aDesconto[nlK] //Original  //aVal[nlK][2,1]+aVal[nlK][2,2]+aVal[nlK][2,3]+aVal[nlK][2,4]+aVal[nlK][2,5]
						Else
							aGlobal[alNiv5[nlK]][8] := aRecebido[nlK] - aTxJuros[nlK] - aMulta[nlK] - aCorrecao[nlK] + aDesconto[nlK] //Original  //aVal[nlK][2,1]+aVal[nlK][2,2]+aVal[nlK][2,3]+aVal[nlK][2,4]+aVal[nlK][2,5]
						EndIf

						aGlobal[alNiv5[nlK]][9] := 0
					Else
						aGlobal[alNiv5[nlK]][8] := aVal[nlK][nlCont][nlCont2-1]

						if clDesc == STR0056 //"Recebido"
				 			aadd (aRecebido, aGlobal[alNiv5[nlK]][8])
						EndIf

						if clDesc == STR0057 //"Taxa de Juros"
							aadd (aTxJuros,  aGlobal[alNiv5[nlK]][8])
						EndIf

						if clDesc == STR0058 //"Multa"
							aadd (aMulta,    aGlobal[alNiv5[nlK]][8])
						EndIf

						if clDesc == STR0059 //"Corre็ใo"
							aadd (aCorrecao, aGlobal[alNiv5[nlK]][8])
						EndIf

						if clDesc == STR0060 //"Descontos"
							aadd (aDesconto, aGlobal[alNiv5[nlK]][8])
						EndIf
						//oswaldo

						aGlobal[alNiv5[nlK]][9] := 0
					EndIf
				ElseIf nlCont > 2 .And. nlCont < 5
					aGlobal[alNiv5[nlK]][8]  := aVal[nlK][nlCont][nlCont2][1]
					aGlobal[alNiv5[nlK]][9]  := aVal[nlK][nlCont][nlCont2][2]
				ElseIf nlCont == 5
					If nlCont == 5 .And. nlCont2 == 1
						aGlobal[alNiv5[nlK]][8] := aVal[nlK][5,1]+aVal[nlK][5,2]+aVal[nlK][5,3]+aVal[nlK][5,4]+aVal[nlK][5,5]+aVal[nlK][5,6]+aVal[nlK][5,7]+aVal[nlK][5,8]
						aGlobal[alNiv5[nlK]][9]:= 0
					Else
						aGlobal[alNiv5[nlK]][8] := aVal[nlK][nlCont][nlCont2-1]
						aGlobal[alNiv5[nlK]][9] := 0
					EndIf
				ElseIf nlCont == 6
					If nlCont == 6 .And. nlCont2 == 1
						aGlobal[alNiv5[nlK]][8] := aVal[nlK][6,1]+aVal[nlK][6,2]+aVal[nlK][6,3]+aVal[nlK][6,4]+aVal[nlK][6,5]
						aGlobal[alNiv5[nlK]][9]:= 0
					Else
						aGlobal[alNiv5[nlK]][8] := aVal[nlK][nlCont][nlCont2-1]
						aGlobal[alNiv5[nlK]][9] := 0
					EndIf
				ElseIf nlCont == 7
					If nlCont == 7 .And. nlCont2 == 1
						aGlobal[alNiv5[nlK]][8] := aVal[nlK][7,1]+aVal[nlK][7,2]+aVal[nlK][7,3]+aVal[nlK][7,4]+aVal[nlK][7,5]
						aGlobal[alNiv5[nlK]][9]:= 0
					Else
						aGlobal[alNiv5[nlK]][8] := aVal[nlK][nlCont][nlCont2-1]
						aGlobal[alNiv5[nlK]][9] := 0
					EndIf
				EndIf
				nlCont2++
			Next nlK
			nlI := nlAux-1
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
		EndIf
	Next nlI

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFC330Calc ณ Autor ณ Adrianne Furtado      ณ Data ณ 30/11/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Retorna o saldo do item do pedido                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe e ณ FC330Calc()                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FC330Calc(lEnd,wnRel,cString,oReport,clFilial,llNum,alGrpEmp,apRet,aReturn)

	Local mv_par01 := 1					//1
	Local mv_par02 := Val(apRet[1][1])	//Lista Baixas pela Data da
	Local mv_par03 := apRet[1][2]		//Prefixo inicial
	Local mv_par04 := apRet[1][3]		//Prefixo final
	Local mv_par05 := Val(apRet[1][4])	//Considera Juros
	Local mv_par06 := Val(apRet[1][5])	//Considera Pedidos de Compra
	Local mv_par07 := Val(apRet[1][6])	//Comp๕e Saldo Retroativo
	Local mv_par08 := Val(apRet[1][7])	//Moeda
	Local mv_par09 := Val(apRet[1][8])	//Converte Moeda
	Local mv_par10 := Val(apRet[1][9])	//TES dos Pedidos de Compras
	Local mv_par11 := Val(apRet[1][10])	//Considera Valores Acess๓rios (Feito prote็ใo para descida de valores acessorios na v12.1.17 sem dicionario)
	LOCAL mv_par12 := apRet[1][11]		//Data Base

	LOCAL CbCont,CbTxt
	LOCAL tamanho:="P"

	//Acumuladores
	LOCAL aCompras	:= {}
	LOCAL aBaixados	:= {}
	LOCAL aVencer		:= {}
	LOCAL aVencidos	:= {}
	LOCAL aAcessoFil	:= {}
	LOCAL aTipos		:= {}
	LOCAL aAdiantados	:= {}
	LOCAL aAtrasados	:= {}
	Local aValores	:= {}
	Local aMedia		:= {}
	LOCAL nx			:= 0
	LOCAL nSaldo		:= 0
	Local nDias		:= 0
	Local nSaldoAtu	:= 0
	LOCAL cArq			:= ""
	Local cCondFil
	Local cFilterUser	:= aReturn[7]
	Local nDecs		:= 0
	Local cFiltro
	Local cIndTmp
	Local cAliasTmp
	Local nTipoData	:= 1
	Local cSQLSE2		:= If(oReport<>Nil,oReport:Section(1):GetSqlExp('SE2'),Nil)
	Local cFiltSED	:= If(oReport<>Nil,oReport:Section(1):GetAdvplExp('SED'),Nil)
	LOCAL dDataBaixa
	Local nIndex
	Local nMoedaBco	:= 1
	LOCAL nRecebido	:= 0

	Local cQuery		:= ""

	Local nlI			:= 0
	Local clEmp		:= ""
	Local clFil		:= ""
	Local aRetVal		:= {}
	
	Local lValAcess	:=	ExistFunc('FValAcess')

	Private cTipos	:= ""

	//Tipo da data para a composicao do saldo via SaldoTit()
	If mv_par02 == 1		// Data da baixa (E5_BAIXA)
		nTipoData := 1
	ElseIf mv_par02 == 2	//Data de Digitacao (E5_DTDIGIT)
		nTipoData := 3
	Else					//Data de Disponibilidade (E5_DTDISPO)
		nTipoData := 2
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       := 80
	m_pag    := 1

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

		aValores	:= {}

		//Zerar os Acumuladores
		aCompras		:= {0,0,0}
		aBaixados		:= {0,0,0,0,0,0,0}
		aVencer			:= {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}
		aVencidos		:= {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}
		aTipos			:= {0,0,0,0,0,0,0,0,0,0}
		aAtrasados		:= {0,0,0,0,0,0}
		aAdiantados		:= {0,0,0,0,0} 
		aMedia			:= {{0,0},{0,0}}

		nDecs		:= MsDecimais(mv_par08)
		aAcessoFil	:= MatFilCalc(.F.)

		dbSelectArea("SE2")
		dbSetOrder(1)
		If mv_par01 == 1
			dbSeek(xFilial("SE2"))
		Else
			dbGotop()
		Endif
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Filtra APENAS os emitidos antes da database, pois este relaณ
		//ณ torio pode ser retroativo.                                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
		aStru  := SE2->(dbStruct())
		cAliasTmp := "FINR330"
		cQuery := ""
		aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
		cQuery := "SELECT "+SubStr(cQuery,2)
		cQuery +=         ",R_E_C_N_O_ RECNO "
		cQuery += "FROM "+RetSqlName("SE2")+ " SE2 "
		cQuery += "WHERE "
	
		If mv_par01 == 1
			cQuery += "SE2.E2_FILIAL ='"+xFilial("SE2")+"' AND "     //Formato adotado pela CNI: 01DN0001
		Else
			cQuery += "SE2.E2_FILIAL IN ( "
			For nx:= 1 to len(aAcessoFil)
				If nx == 1
					cQuery += "'" + aAcessoFil[nx][2] + "'"
				Else
					cQuery += ",'" + aAcessoFil[nx][2] + "'"
				Endif
			Next
			cQuery += ") AND "
		Endif
	
		cQuery += "SE2.E2_EMISSAO <= '"+Dtos(dDataBase)+"' AND "
		cQuery += "SE2.E2_PREFIXO >= '"+mv_par03+"' AND "
		cQuery += "SE2.E2_PREFIXO <= '"+mv_par04+"' AND "
		If mv_par09 == 2
			cQuery += "SE2.E2_MOEDA = "+Str(mv_par08,2)+" AND "
		Endif
	
		If !Empty(cSQLSE2)
			cQuery += "("+cSqlSE2 +") AND "
		Endif
	
		cQuery += "SE2.D_E_L_E_T_=' ' "
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
		For nX :=  1 To Len(aStru)
			If aStru[nX][2] <> "C"
				TcSetField(cAliasTmp,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
	
		// Leitura do SE2 (Contas a Pagar)
		dbSelectArea(cAliasTmp)
	
		While !Eof()
	
			dbSelectArea(cAliasTmp)
	
			IF lEnd
	
				Exit
			End

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Considera filtro do usuario                                  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !Empty(cFilterUser).and.!(&cFilterUser)
	
				dbSkip()
				Loop
			Endif
	
			IF !Empty(E2_FATURA) .and. Substr(E2_FATURA,1,6) != "NOTFAT" .and. E2_DTFATUR <= dDataBase
	
				dbSkip()
				Loop
			Endif
	
			If mv_par01 == 1 .and. E2_FILIAL != xFilial("SE2")
	
				Exit
			EndIF
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica se  provisขrio ou abatimento ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If E2_TIPO $ MVPROVIS+"/"+MVABATIM
	
				dbSkip()
				Loop
			Endif
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Considera filtro do usuario - SED                            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !Empty(cFiltSED)
				SED->(DbSetOrder(1))
				SED->(MsSeek(xFilial()+(cAliasTmp)->E2_NATUREZ))
				If SED->(!&(cFiltSED))
	
					DbSkip()
					Loop
				Endif
			Endif
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Calcula o faturamento baseado na data base/item 1 analise    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Month(E2_EMISSAO) == Month(dDatabase) .and. Year(E2_EMISSAO) == Year(dDataBase)
				If !(E2_TIPO $MV_CPNEG+"/"+MVPAGANT)
					nDias := (E2_VENCREA - E2_EMISSAO)
					aCompras[1] += xMoeda(E2_VALOR,E2_MOEDA,mv_par08,,,If(cPaisLoc=="BRA",E2_TXMOEDA,0))
					If nDias <= 1
						aCompras[2] += xMoeda(E2_VALOR,E2_MOEDA,mv_par08,,,If(cPaisLoc=="BRA",E2_TXMOEDA,0))
					Else
						aCompras[3] += xMoeda(E2_VALOR,E2_MOEDA,mv_par08,,,If(cPaisLoc=="BRA",E2_TXMOEDA,0))
					Endif
				Endif
			Endif
	
			nSaldoAtu := 0
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Acumula titulos vencidos/vencer / Item 2 e 3 da analise      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If mv_par07 == 1
	
				// Posiciona SE2 ou SE1 para pegar o saldo do titulo correto
				SE2->(DbGoto((cAliasTmp)->RECNO))
	
				nSaldoAtu := SaldoTit( 	E2_PREFIXO,;
											E2_NUM,;
											E2_PARCELA,;
											E2_TIPO,;
											E2_NATUREZ,;
											"P",;
											E2_FORNECE,;
											mv_par08,;
											dDataBase,;
											dDataBase,;
											E2_LOJA,;
											E2_FILIAL,;
											IIf(cPaisLoc=="BRA",E2_TXMOEDA,0),nTipoData )
	
			Else
				If cPaisLoc == "BRA"
					nSaldoAtu := xMoeda(E2_SALDO,E2_MOEDA,mv_par08,,,If(cPaisLoc=="BRA",E2_TXMOEDA,0))
				Else
					nSaldoAtu := xMoeda(E2_SALDO,E2_MOEDA,mv_par08,E2_EMISSAO,nDecs+1,If(cPaisLoc=="BRA",E2_TXMOEDA,0))
				EndIf
			Endif
	
			If nSaldoAtu > 0
				nSaldoAtu-=SomaAbat(E2_PREFIXO,E2_NUM,E2_PARCELA,"P",1,,E2_FORNECE,E2_LOJA,E2_FILIAL)
			Endif
			nSaldoAtu:=Round(NoRound(nSaldoAtu,3),2)
	
			If E2_TIPO $ (MVPAGANT + "/" + MV_CPNEG) // Substrai as Notas de Debitou ou Adiantamentos
				nSaldoAtu := nSaldoAtu * -1
			Endif
	
			If nSaldoAtu <> 0
				dBaixa := dDataBase
				nJuros := 0
				If mv_par05 == 1
					fa080juros(mv_par08)
				Endif

				If lValAcess
					If mv_par11 == 1	// VALORES ACESSำRIOS
						//Calculo de Valor Acessorio 
						nSaldoAtu += FValAcess( SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ, Iif(Empty( SE2->E2_BAIXA),.F.,.T.),"","P", mv_par12 )
					EndIf
				Endif

				If dDataBase < E2_VENCREA .OR. E2_TIPO $ MVPAGANT //Titulos a vencer
					nSaldoAtu+=nJuros
					aVencer[1][1] += nSaldoAtu
					aVencer[1][2] ++
					nDias := (E2_VENCREA - dDatabase)
					If nDias <= 15
						aVencer[2][1] += nSaldoAtu
						aVencer[2][2] ++
	
					ElseIf nDias > 15 .And. nDias <= 30
						aVencer[3][1] += nSaldoAtu
						aVencer[3][2] ++
					ElseIf nDias > 30 .And. nDias <= 60
						aVencer[4][1] += nSaldoAtu
						aVencer[4][2] ++
					ElseIf nDias > 60 .And. nDias <= 90
						aVencer[5][1] += nSaldoAtu
						aVencer[5][2] ++
					Else
						aVencer[6][1] += nSaldoAtu
						aVencer[6][2] ++
					Endif
				Else		 	// Titulos Vencidos
					aVencidos[1][1] += nSaldoAtu
					aVencidos[1][2] ++
					nDias := (dDatabase - E2_VENCTO)
					If nDias <= 15
						aVencidos[2][1] += nSaldoAtu
						aVencidos[2][2] ++
					ElseIf nDias > 15 .And. nDias <= 30
						aVencidos[3][1] += nSaldoAtu
						aVencidos[3][2] ++
					ElseIf nDias > 30 .And. nDias <= 60
						aVencidos[4][1] += nSaldoAtu
						aVencidos[4][2] ++
					ElseIf nDias > 60 .And. nDias <= 90
						aVencidos[5][1] += nSaldoAtu
						aVencidos[5][2] ++
					Else
						aVencidos[6][1] += nSaldoAtu
						aVencidos[6][2] ++
					Endif
				Endif
			Endif
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Calcula Tipo de Titulo
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nSaldoAtu <> 0 .and. E2_EMISSAO <= dDatabase
				Do Case
					Case E2_TIPO  $ MVDUPLIC		//Duplicatas
						aTipos[1] += nSaldoAtu
					Case E2_TIPO  $ MVNOTAFIS	//Notas fiscais
						aTipos[2] += nSaldoAtu
					Case E2_TIPO  $ MVCHEQUES	//Cheque Pre
						aTipos[3] += nSaldoAtu
					Case E2_TIPO   = "CN"			//Carne de Pagamento
						aTipos[4] += nSaldoAtu
					Case E2_TIPO  $ MVTAXA		//Juros
						aTipos[5] += nSaldoAtu
					Case E2_TIPO  $ MVPAGANT		//Pagamento antecipado
						aTipos[6] += nSaldoAtu
					Case E2_TIPO $ MV_CPNEG		//Nota de Debito
						aTipos[7] += nSaldoAtu
					OtherWise						//Total
						aTipos[8] += nSaldoAtu
				EndCase
			Endif
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Calcula o P.M.A e P.M.P - indices / item 7 da analise        ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nSaldoAtu != 0
				aMedia[1][1] +=(E2_VENCREA-E2_EMISSAO)
				aMedia[1][2] += 1
				aMedia[2][1] += (E2_VENCREA-E2_EMISSAO)*;
							   xMoeda(nSaldoAtu,E2_MOEDA,mv_par08,E2_EMISSAO,nDecs+1,If(cPaisLoc=="BRA",E2_TXMOEDA,0))
				aMedia[2][2] += xMoeda(nSaldoAtu,E2_MOEDA,mv_par08,E2_EMISSAO,nDecs+1,If(cPaisLoc=="BRA",E2_TXMOEDA,0))
			EndIf
	
			dbSelectArea("SE5")
			dbSetOrder(7)
			If dbSeek(xFilial("SE5")+ (cAliasTmp)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE) )
				If SE5->E5_MOTBX $ 'DSD'
					aCompras[1] -= xMoeda((cAliasTmp)->E2_VALOR,(cAliasTmp)->E2_MOEDA,mv_par08,,,If(cPaisLoc=="BRA",(cAliasTmp)->E2_TXMOEDA,0))
					aCompras[2] -= xMoeda((cAliasTmp)->E2_VALOR,(cAliasTmp)->E2_MOEDA,mv_par08,,,If(cPaisLoc=="BRA",(cAliasTmp)->E2_TXMOEDA,0))
				EndIF
			EndIf
	
			dbSelectArea(cAliasTmp)
			dbSkip()
		EndDo
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Valor Recebido.     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
		cCondFil += "FROM "+RetSqlName("SE5") + " SE5 "
		cCondFil += "WHERE "
		If mv_par01 == 1
			cCondFil += "E5_FILIAL = '" + xFilial("SE5") + "' AND "
		Else
			cQuery += "SE5.E5_FILIAL IN ( "
			For nx:= 1 to len(aAcessoFil)
				If nx == 1
					cQuery += "'" + aAcessoFil[nx][2] + "'"
				Else
					cQuery += ",'" + aAcessoFil[nx][2] + "'"
				Endif
			Next
			cQuery += ") AND "
		Endif
		cCondFil += "E5_TIPODOC IN ('VL','V2','JR','J2','CM','C2','MT','M2','DC','D2','TL','BA','PA') AND E5_RECPAG = 'P' AND "
		cCondFil += "E5_PREFIXO >= '"+mv_par03+"' AND "
		cCondFil += "E5_PREFIXO <= '"+mv_par04+"' AND "
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
	
		(cAliasSE5)->(dbGoTop())
	
		Do While (mv_par01 != 1 .OR. xFilial("SE5") == (cAliasSe5)->E5_FILIAL) .AND. !Eof()
	
			// Ignora registros que nao sao da moeda quando escolhido nao imprimir
			SA6->(dbSeek(xFilial()+(cAliasSe5)->E5_BANCO+(cAliasSe5)->E5_AGENCIA+(cAliasSe5)->E5_CONTA))
			If mv_par09 == 2 .AND. Max(SA6->A6_MOEDA, 1) != mv_par08
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
				Year(dDataBase) ==Year(dDataBaixa) .and.;
				(cAliasSe5)->E5_RECPAG=="P" .and. dDataBaixa <= dDatabase .AND.;
				(cAliasSe5)->E5_TIPODOC$"VL/V2/BA" ;
				.and. (cAliasSe5)->E5_SITUACA <> "C" .and. ;
				(	MovBcoBx((cAliasSe5)->E5_MOTBX) .or. ;
				((cAliasSe5)->E5_MOTBX=="CMP" .and. (cAliasSe5)->E5_TIPO $ MVPAGANT+"#"+MV_CPNEG ) )
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Verifica se existe estorno para esta baixa                       ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				SE5->(dbGoto((cAliasSe5)->RECNO))
	
				If !TemBxCanc((cAliasSe5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
					nRecebido += xMoeda((cAliasSe5)->E5_VALOR,nMoedaBco,mv_par08,(cAliasSe5)->E5_DATA,nDecs+1,,If(cPaisLoc=="BRA",(cAliasSe5)->E5_TXMOEDA,0))
				EndIf
			EndIf
	
			If Month(dDatabase) = Month(dDataBaixa) .and. ;
				Year(dDataBase)  = Year(dDataBaixa)  .and. (cAliasSe5)->E5_RECPAG=="P" .and. ;
				dDataBaixa <= dDatabase .and. (cAliasSe5)->E5_SITUACA <> "C" .and. ;
				MovBcoBx((cAliasSe5)->E5_MOTBX)
				nValorE5 := xMoeda((cAliasSe5)->E5_VALOR,nMoedaBco,mv_par08,(cAliasSe5)->E5_DATA,nDecs+1,,If(cPaisLoc=="BRA",(cAliasSe5)->E5_TXMOEDA,0))
				Do Case
					Case (cAliasSe5)->E5_TIPODOC $ "VL/BA"		//Valor recebido
						aBaixados[1]+= nValorE5
					Case (cAliasSe5)->E5_TIPODOC $ "JR/J2/TL"	//Valor juros
						aBaixados[2] += nValorE5
					Case (cAliasSe5)->E5_TIPODOC $ "CM/C2"		//Valor da correcao
						aBaixados[4] += nValorE5
					Case (cAliasSe5)->E5_TIPODOC $ "MT/M2"		//Valor da Multa
						aBaixados[3] += nValorE5
					Case (cAliasSe5)->E5_TIPODOC $ "DC/D2"		//Valor do Desconto
						aBaixados[5] += nValorE5
					Case (cAliasSe5)->E5_TIPODOC $ MVPAGANT	//Valor do Pagamento antecipado
						aBaixados[6] += nValorE5
				EndCase
	
			EndIf
			dbSelectArea(cAliasSe5)
		dbSkip()
		Enddo
	
		dbSelectArea(cAliasSe5)
		dbSelectArea("SE5")
	
		DbClearFil()
		RetIndex("SE5")
		FErase(cArq+OrdBagExt())
	
		dbSelectArea("SE5")
		Set Filter to
		Ferase(cArq+OrdBagExt())
		dbSelectArea(cAliasTmp)
	
		// Pedidos de Compras
		If mv_par06 == 1
	
			dbSelectArea("SC7")
			If mv_par01 == 1
				dbSeek(xFilial("SC7"))
			Else
				dbGotop()
			Endif
	
			aStru  := SC7->(dbStruct())
			cCondFil := ""
			aEval(aStru,{|x| cCondFil += ","+AllTrim(x[1])})
			cCondFil := "SELECT "+SubStr(cCondFil,2)
			cCondFil +=         ",R_E_C_N_O_ RECNO "
			cCondFil += "FROM "+RetSqlName("SC7") + " SC7 "
			cCondFil += "WHERE "
			If mv_par01 == 1
				cCondFil += "C7_FILIAL='" + xFilial("SC7") + "' AND "
			Else
				cQuery += "SC7.C7_FILIAL IN ( "
				For nx:= 1 to len(aAcessoFil)
					If nx == 1
						cQuery += "'" + aAcessoFil[nx][2] + "'"
					Else
						cQuery += ",'" + aAcessoFil[nx][2] + "'"
					Endif
				Next
				cQuery += ") AND "
			Endif
			cCondFil += "D_E_L_E_T_ = ' ' "
	
			cCondFil := ChangeQuery(cCondFil)
	
			dbSelectArea("SC7")
			dbCloseArea()
			dbSelectArea("SA2")
	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cCondFil),"SC7",.T.,.T.)
	
			For nX :=  1 To Len(aStru)
				If aStru[nX][2] <> "C"
					TcSetField("SC7",aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
	
			While (mv_par01 != 1 .OR. xFilial("SC7") == SC7->C7_FILIAL) .AND. !Eof()
	
				If SC7->C7_QUJE >= SC7->C7_QUANT 			//	 pedido jแ atendido
					dbSkip()
					Loop
				Endif
	
				nSaldo := FC330Saldo(mv_par10)
				aAtrasados[6] += nSaldo
				If SC7->C7_DATPRF < dDataBase 			   // Pedidos atrasados
					nDias := dDataBase - SC7->C7_DATPRF
					If nDias <= 15
					   aAtrasados[1] += nSaldo
					ElseIf nDias > 15 .And. nDias <= 30
					   aAtrasados[2] += nSaldo
					ElseIf nDias > 30 .And. nDias <= 60
					   aAtrasados[3] += nSaldo
					ElseIf nDias > 60 .And. nDias <= 90
					   aAtrasados[4] += nSaldo
					Else
					   aAtrasados[5] += nSaldo
					EndIf
				Else
					nDias := SC7->C7_DATPRF - dDataBase    // Pedidos adiantados
					If nDias <= 15
					   aAdiantados[1] += nSaldo
					ElseIf nDias > 15 .And. nDias <= 30
					   aAdiantados[2] += nSaldo
					ElseIf nDias > 30 .And. nDias <= 60
					   aAdiantados[3] += nSaldo
					ElseIf nDias > 60 .And. nDias <= 90
					   aAdiantados[4] += nSaldo
					Else
					   aAdiantados[5] += nSaldo
					Endif
				Endif
	
				dbSelectArea("SC7")
				dbSkip()
	
			Enddo
	
		Endif
	
		If Select(cAliasTmp) <> 0
			dbSelectArea(cAliasTmp)
	 		dbCloseArea()
		EndIf
	
		If Select(cAliasSe5) <> 0
			dbSelectArea(cAliasSe5)
			dbCloseArea()
		EndIf
	
		dbSelectArea("SE2")
		ChKFile("SE2")
		dbSelectArea("SE2")
		dbSetOrder(1)
	
		dbSelectArea("SE5")
		dbCloseArea()
		ChKFile("SE5")
		dbSelectArea("SE5")
		dbSetOrder(1)
	
		dbSelectArea("SC7")
		dbCloseArea()
		ChKFile("SC7")
		dbSelectArea("SC7")
		dbSetOrder(1)
	
		If aReturn[5] = 1
			dbCommitAll()
		Endif
	
		AaDD(aValores, aCompras)
		AaDD(aValores, aBaixados)
		AaDD(aValores, aVencer)
		AaDD(aValores, aVencidos)
		AaDD(aValores, aTipos)
		AaDD(aValores, aAtrasados)
		AaDD(aValores, aAdiantados)
		AaDD(aValores, aMedia)

		Aadd(aRetVal,AClone(aValores))

	Next nlI
	RpcClearEnv()

Return aRetVal


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFC330Saldo  บAutor  ณMicrosiga          บ Data ณ  30/11/10  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o saldo do item do pedido                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330Saldo(mv_par10)

	Local nRetSaldo := 0

	If (C7_QUANT-C7_QUJE) > 0
		If !Empty( SC7->C7_TES )
			dbSelectArea("SF4")
	 		dbSetOrder(1)
			dbSeek( xFilial("SF4")+SC7->C7_TES )
			If mv_par10 == 1		// Verifica se ir  considerar o TES (F4_DUPLIC)
				If SF4->F4_DUPLIC == "S"
					nRetSaldo := (SC7->C7_QUANT - SC7->C7_QUJE) * SC7->C7_PRECO
				Endif
			Else
				nRetSaldo := (SC7->C7_QUANT - SC7->C7_QUJE) * SC7->C7_PRECO
			EndIf
		EndIf
	EndIf
	DbSelectArea("SC7")

Return(nRetSaldo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINC330   บAutor  ณFabricio Romera     บ Data ณ  11/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tree para tela de consulta.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330MtaTree(oDlg, aPosObj)

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
			                AllTrim( aGlobal[nX][5] )+ "." + AllTrim( aGlobal[nX][6] ) + "." + AllTrim( aGlobal[nX][7] )	)

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
		If !( Len(aGlobal[nX][10]) = nTamN1 )			//Nivel 01

			If nGruGC > 0 .And. nEmpGC	> 0 .And. nUnidGC > 0 .And. nFilGC > 0
				
				If Len( aGlobal[nX][10] ) == nTamN2			//Nivel 01 + Grupos de Empresa
					aAdd( aNivel2, aGlobal[nX] )
				ElseIf Len( aGlobal[nX][10] ) == nTamN3		//Nivel 01 + Grupos de Empresa + Empresa
					aAdd( aNivel3, aGlobal[nX] )
				ElseIf Len( aGlobal[nX][10] ) == nTamN4		//Nivel 01 + Grupos de Empresa + Empresa + Unidade de Negocio
					aAdd( aNivel4, aGlobal[nX] )
				ElseIf	Len( aGlobal[nX][10] ) == nTamN5	//Nivel 01 + Grupos de Empresa + Empresa + Unidade de Negocio + Filial
					aAdd( aNivel5, aGlobal[nX] )
				End If
			Else
				If Len( aGlobal[nX][10] ) == nTamN2
					aAdd( aNivel2, aGlobal[nX] )
				Else
					aAdd( aNivel3, aGlobal[nX] )
				End If
			EndIF

		End If

	Next

	//Monta objeto tree
	oTree := DbTree():New(aPosObj[1], aPosObj[2],aPosObj[3] ,aPosObj[4] ,oDlg,,,.T.) // Cria a Tree
	oTree:bChange := {|| ProcTrees(oTree) }

	oTree:AddTree(STR0102+space(21), .T., , , , , "00"+space(20) ) //"Pos Geral Ctas a Pagar"

	If nGruGC > 0 .And. nEmpGC	> 0 .And. nUnidGC > 0 .And. nFilGC > 0
		//Adiciona itens da Tree
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
	
		Next
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
ฑฑบPrograma  ณFINC330   บAutor  ณFabricio Romera     บ Data ณ  11/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta get dados para visualizacao do item selecionado na    บฑฑ
ฑฑบ          ณtree.                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330MtaGetDad(oDlg, oGetDados, aPosObj)

	//Monta aHeader
	aAdd(aHeader, {STR0106,"C1_NUM",""						,15,0,.T.,"","C","",""} ) //"GRUPO"
	aAdd(aHeader, {STR0107,"C1_NUM",""						,15,0,.T.,"","C","",""} ) //"EMPRESA"
	aAdd(aHeader, {STR0108,"C1_NUM",""						,15,0,.T.,"","C","",""} ) //"UNIDADE"
	aAdd(aHeader, {STR0109,"C1_NUM",""						,15,0,.T.,"","C","",""} ) //"FILIAL"
	aAdd(aHeader, {STR0110,"C1_NUM","@E 999,999,999,999.99"	,20,2,.T.,"","N","",""} ) //"VALOR"
	aAdd(aHeader, {STR0111,"C1_NUM","@E 999,999,999.99"		,20,2,.T.,"","N","",""} ) //"QUANTIDADE"

	//Monta aCols
	aCols := {}
	aAdd( aCols, {Space(30),Space(30),Space(30),Space(30),0,0,.F.})

	//Monta GetDados
	oGetDados := MsGetDados():New(aPosObj[1],aPosObj[2], aPosObj[3], aPosObj[4], 2, "AlwaysTrue", "AlwaysTrue", "",.F.,{}, , .F., 200, "AlwaysTrue", "AlwaysFalse", , "AlwaysFalse", oDlg)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcTrees บAutor  ณFabricio Romera     บ Data ณ  05/17/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza GetDados conforme nova posicao do objeto Tree.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcTrees(oTree)

Local nPos		:= 0
Local cCargo	:= ""

	cCargo := Trim(oTree:GetCargo())
	aCols  := {}
	
	If nGruGC > 0 .And. nEmpGC	> 0 .And. nUnidGC > 0 .And. nFilGC > 0

		If Len(cCargo) = nTamN1
	
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
			aAdd(aCols, { 	aNivel2[nPos][4], ;
							aNivel2[nPos][5], ;
							aNivel2[nPos][6], ;
							aNivel2[nPos][7], ;
							aNivel2[nPos][8], ;
							aNivel2[nPos][9], ;
							.F.} )
	
		ElseIf Len( cCargo ) == nTamN3
	
			//Busca item selecionado
			nPos := aScan( aNivel3, {|x| x[10] = cCargo } )
	
			//Atualiza aCols
			aAdd(aCols, { 	aNivel3[nPos][4], ;
							aNivel3[nPos][5], ;
							aNivel3[nPos][6], ;
							aNivel3[nPos][7], ;
							aNivel3[nPos][8], ;
							aNivel3[nPos][9], ;
							.F.} )
	
		ElseIf Len( cCargo ) == nTamN4
	
			//Busca item selecionado
			nPos := aScan( aNivel4, {|x| x[10] = cCargo } )
	
			//Atualiza aCols
			aAdd(aCols, { 	aNivel4[nPos][4], ;
							aNivel4[nPos][5], ;
							aNivel4[nPos][6], ;
							aNivel4[nPos][7], ;
							aNivel4[nPos][8], ;
							aNivel4[nPos][9], ;
							.F.} )
	
		ElseIf Len( cCargo ) == nTamN5
	
			//Busca item selecionado
			nPos := aScan( aNivel5, {|x| x[10] = cCargo } )
	
			//Atualiza aCols
			aAdd(aCols, { 	aNivel5[nPos][4], ;
							aNivel5[nPos][5], ;
							aNivel5[nPos][6], ;
							aNivel5[nPos][7], ;
							aNivel5[nPos][8], ;
							aNivel5[nPos][9], ;
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
	
	
	EndIF

	oGetDados:ForceRefresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFC330REL  บAutor  ณFabricio Romera     บ Data ณ  05/17/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEmite relatorio dos dados apresentados em tela              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FC330REL()

	Local cPerg			:= "FC330REL"
	Local cTitulo		:= STR0102 //"Cons Geral Ctas Pagar"

	Local oDados1
	Local oReport
	Local aDados		:= {aLbx, aNivel2, aNivel3, aNivel4, aNivel5}
	Local cTrb			:= GetNextAlias()
	Local nNivMax		:= 0
	Local bTabulacao	:= {|| Space( Len(AllTrim(TRB_NIVEL)) - 2 ) + TRB_NIVEL }
	Local bLimpaVal		:= {|| If( Empty(TRB_NIVEL), NIL, TRB_VALOR ) }
	Local bLimpaQtd		:= {|| If( Empty(TRB_NIVEL), NIL, TRB_QUANT ) }
	Local aOrd			:= {}

	Pergunte( cPerg, .F. )

	oReport := TReport():New("FC330REL",cTitulo,cPerg,;
	{|oReport| DefPrint( oReport, aOrd, cTitulo, aDados, mv_par01, cTrb )}, STR0103) //"Este relat๓rio irแ imprimir informa็๕es do contas a pagar conforme dados aprensentados na tela de consulta."

	DEFINE SECTION oDados1 OF oReport TABLES cTrb TITLE cTitulo ORDERS aOrd
	DEFINE CELL NAME "TRB_NIVEL"	OF oDados1 ALIAS cTrb TITLE STR0104 SIZE 30 BLOCK bTabulacao												//"NIVEL"
	DEFINE CELL NAME "TRB_DESCR"	OF oDados1 ALIAS cTrb TITLE STR0105 SIZE 30																	//"DESCRIวรO"
	DEFINE CELL NAME "TRB_GRUPO"	OF oDados1 ALIAS cTrb TITLE STR0106																			//"GRUPO"
	DEFINE CELL NAME "TRB_EMPRES"	OF oDados1 ALIAS cTrb TITLE STR0107																			//"EMPRESA"
	DEFINE CELL NAME "TRB_UNIDAD"	OF oDados1 ALIAS cTrb TITLE STR0108																			//"UNIDADE"
	DEFINE CELL NAME "TRB_FILIAL"	OF oDados1 ALIAS cTrb TITLE STR0109																			//"FILIAL"
	DEFINE CELL NAME "TRB_VALOR"	OF oDados1 ALIAS cTrb TITLE STR0110 SIZE 20 BLOCK bLimpaVal PICTURE	"@E 999,999,999,999.99"	ALIGN CENTER	//"VALOR"
	DEFINE CELL NAME "TRB_QUANT"	OF oDados1 ALIAS cTrb TITLE STR0111 SIZE 10 BLOCK bLimpaQtd PICTURE	"@E 999,999,999,999.99"	ALIGN CENTER	//"QUANTIDADE"
						
	oDados1:OnPrintLine( {||oReport:SkipLine()})
			
	oReport:PrintDialog()
			
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDefPrint  บAutor  ณFabricio Romera     บ Data ณ  05/17/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEstrutura dados para impressao.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFC330REL                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DefPrint( oReport, aOrd, cTitulo, aDados, nNivMax, cTrb)

Local oSection1 := oReport:Section(1)

	//Cria arquivo de trabalho
	aStru := {}
	AADD(aStru,{"TRB_NIVEL"		,"C"	,15	,0})
	AADD(aStru,{"TRB_DESCR"		,"C"	,30	,0})
	AADD(aStru,{"TRB_GRUPO"		,"C"	,2	,0})
	AADD(aStru,{"TRB_EMPRES"	,"C"	,2	,0})
	AADD(aStru,{"TRB_UNIDAD"	,"C"	,2	,0})
	AADD(aStru,{"TRB_FILIAL"	,"C"	,3	,0})
	AADD(aStru,{"TRB_VALOR"		,"N"	,15	,2})
	AADD(aStru,{"TRB_QUANT"		,"N"	,15	,2})
	AADD(aStru,{"TRB_ORDEM"		,"C"	,2	,0})

	If __oFINC3302 <> Nil
		__oFINC3302:Delete()
		__oFINC3302	:= Nil
	Endif	
	
	__oFINC3302 := FWTemporaryTable():New(cTrb)
	__oFINC3302:SetFields( aStru )
	
	aChave   := {"TRB_NIVEL","TRB_DESCR","TRB_GRUPO","TRB_EMPRES","TRB_UNIDAD","TRB_FILIAL","TRB_VALOR","TRB_QUANT", "TRB_ORDEM"}
	
	__oFINC3302:AddIndex("1", aChave)
	__oFINC3302:Create()
	
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
ฑฑบDesc.     ณPreenche arquivo de trabalho utilizado para relatorio       บฑฑ
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
ฑฑบDesc.     ณFuncao auxiliar para gravacao em arquivo de trabalho do relaบฑฑ
ฑฑบ          ณtorio.                                                      บฑฑ
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
