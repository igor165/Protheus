#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA005.CH"

/*/{Protheus.doc} GPEA005
//Correção fechamento co-participação para a DIRF
@author eduardo.vicente
@since 25/02/2018
@see (links_or_references)
/*/
Function GPEA005()

	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd)
	Local oDlg
	Local oFWLayer
	Local oPanelUp
	Local aColsMark		:= {}
	Local lMarcar		:= .F.
	Local bIntegra		:= {|| IF(GPM005IniProc(),oDlg:End(),) }
	Local bGera			:= {|| GPM005Ver() }
	Local aStruct 		:= SRD->(DbStruct())
	Local aFieldsFilter	:= {}
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
	Local nI			:= 1

	Private	nCountTb	:= 0
	Private aRotMark   	:= {}
	Private cAliasMark 	:= "TABAUX"
	Private oMark
	Private oTmpTable := Nil
	Private cFilIn		:= Space(TamSx3("RA_FILIAL")[1])
	Private cFilFim		:= Space(TamSx3("RA_FILIAL")[1])
	Private cPerIni		:= Space(TamSx3("RCH_PER")[1])
	Private cPerFim		:= Space(TamSx3("RCH_PER")[1])

	//Tratamento de acesso a Dados Sensíveis
	If lBlqAcesso
		//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
		Return
	EndIf

	If fGP005PRM()
		For nI := 1 To Len(aStruct)
			Aadd(aFieldsFilter, { aStruct[nI, 1], aStruct[nI, 1], aStruct[nI, 2], aStruct[nI, 3], aStruct[nI, 4],})
		Next nI

		fCriaTmp()
		aColsMark:= fMntColsMark()
		DEFINE MSDIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL

		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlg,.F.,.T.)
		oFWLayer:AddLine("UP",100,.F.)
		oFWLayer:AddCollumn("ALLRCJ", 100, .T., 'UP' )
		oPanelUp := oFWLayer:GetColPanel("ALLRCJ", 'UP' )

		oMark := FWMarkBrowse():New()
		oMark:SetAlias((cAliasMark))
		oMark:SetFields(aColsMark)
		oMark:SetOwner( oPanelUp )
		oMark:bAllMark := {|| SetMarkAll(oMark:Mark(), lMarcar := !lMarcar), oMark:Refresh(.T.)}

		// Define o campo que sera utilizado para a marcação
		oMark:SetFieldMark( 'TAB_OK')
		oMark:SetUseFilter(.T.)
		oMark:SetValid({||.T.})
		oMark:AddButton(STR0002, bGera,,,, .F., 2 ) //"Verificar"
		oMark:AddButton(STR0003, bIntegra,,,, .F., 2 ) //"Gerar Histórico"
		oMark:obrowse:odata:afieldsfilter := aFieldsFilter
		oMark:SetMenuDef("")

		oMark:Activate()

		ACTIVATE MSDIALOG oDlg

		oTmpTable:Delete()
		oTmpTable := Nil

		RestArea(aArea)
	EndIf
Return .T.

/*/{Protheus.doc} fMntColsMark
//Monta acols
@author eduardo.vicente
@since 25/02/2018
@see (links_or_references)
/*/
Static Function fMntColsMark()

	Local aArea		:= GetArea()
	Local aColsAux 	:=`{}
	Local aColsSX3	:= {}
	Local aCampos  	:= SRD->(dbStruct())
	Local nX		:= 0

	DbSelectArea("SX3")
	DbSetOrder(2)

	For nX := 1 to Len(aCampos)
		If SX3->( dbSeek(aCampos[nX,1]) )
		    aColsSX3 := {X3Titulo(), &("{||(cAliasMark)->"+(aCampos[nX,1])+"}"), SX3->X3_TIPO, SX3->X3_PICTURE,1,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,,,,,,,,1}
		    aAdd(aColsAux,aColsSX3)
		    aColsSX3 := {}
		EndIf
	Next nX

	RestArea(aArea)

Return aColsAux

/*/{Protheus.doc} fCriaTmp
//Cria tabela temporária
@author eduardo.vicente
@since 25/02/2018
@see (links_or_references)
/*/
Static Function fCriaTmp()

	Local aColumns	 := {}
	Local lRet		 := .F.
	Local aCampos  	:= SRD->(dbStruct())
	Local nI		:= 1

	If Select(cAliasMark) > 0
		DbSelectArea(cAliasMark)
		DbCloseArea()
	EndIf

	aAdd(aColumns, {"TAB_OK", "C", 02, 00})

	For nI := 1 To Len(aCampos)
		aAdd(aColumns, {aCampos[nI, 1], aCampos[nI, 2], aCampos[nI, 3], aCampos[nI, 4]})
	Next nI

	oTmpTable := FWTemporaryTable():New(cAliasMark)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex("IND", {aCampos[1, 1], aCampos[2, 1]})
	oTmpTable:Create()

Return lRet

/*/{Protheus.doc} SetMarkAll
//Seleção de registros
@author eduardo.vicente
@since 25/02/2018
@see (links_or_references)
/*/
Static Function SetMarkAll(cMarca, lMarcar)

	Local aAreaMark  := (cAliasMark)->(GetArea())

	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )

	While !(cAliasMark)->( Eof() )
		RecLock( (cAliasMark), .F. )
			(cAliasMark)->TAB_OK := IIf(lMarcar, cMarca, '  ')
		MsUnLock()

		(cAliasMark)->(dbSkip())

	EndDo

RestArea(aAreaMark)

/*/{Protheus.doc} GPM005IniProc
//Processamento dos registros selecionados
@author eduardo.vicente
@since 25/02/2018
@see (links_or_references)
/*/
Static Function GPM005IniProc()

	Local bProcesso		:= {|oSelf| GPM005Proc(oSelf)}
	Local cCadastro 	:= STR0004
	Local cDescricao	:= STR0005
	Local lRet			:= .T.

	DbSelectArea(cAliasMark)
	count to nCountTb
	(cAliasMark)->(DbGoTop())

	If nCountTb > 0
		tNewProcess():New( "GPEA005" , cCadastro , bProcesso , cDescricao , "",,,,,.T.)
	Else
		Help( ,, STR0006,, STR0007,1,0 )
		lRet:= .F.
	EndIf
	oMark:deactivate()

Return lRet

/*/{Protheus.doc} fBuscaDtPg
//BUSCA DATA DE PAGAMENTO BASEADO NO PERÍODO, VERBA E DADOS DO FUNCIONÁRIO
@author eduardo.vicente
@since 08/02/2019
@see (links_or_references)
/*/
Static Function fBuscaDtPg(cAnoMes,cVerba, cFilFun,cMatFun)

	Local aArea		:= GetArea()
	Local dDtPag	:= CtoD("//")
	Local lRet		:= .F.

	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If SRA->(dbSeek(cFilFun+cMatFun))

		lRet := fPosPeriodo( xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cAnoMes,"" , fGetCalcRot('2'),,,6,cAnomes)

		If lRet
			dDtPag	:= RCH->RCH_DTPAGO
		EndIf

	EndIf

	RestArea(aArea)

Return(dDtPag)

/*/{Protheus.doc} GPM005Proc
//Processamento dos registros selecionados
@author eduardo.vicente
@since 25/02/2018
@see (links_or_references)
/*/
Static Function GPM005Proc(oSelf)

	Local cMarca 		:= oMark:Mark()
	Local dDtPag
	Local cAliasPLA
	Local nT			:= 1
	Local aCodFol		:= {}
	Local cFilAux		:= ""
	Local nTotReg		:= 0
	Local nRecno		:= 0

	DbSelectArea(cAliasMark)
	count to nTotReg
	nCountTb:= nTotReg
	(cAliasMark)->(DbGoTop())

	DbSelectArea("SRD")
	SRD->(dbSetOrder(3))//RD_FILIAL+RD_MAT+RD_PERIODO+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
	oSelf:SetRegua1(nTotReg)

	oSelf:SaveLog("Corrigindo SRD" + " - " + "Inicio do processamento")

	While !(cAliasMark)->(Eof())
		oSelf:IncRegua1("Funcionário: "+ " " + (cAliasMark)->RD_FILIAL + " - " + (cAliasMark)->RD_MAT) // Funcionário

		If oMark:IsMark(cMarca)
			dDtPag := cTod("  /  / ")
			If SRD->(dbSeek((cAliasMark)->RD_FILIAL+(cAliasMark)->RD_MAT+(cAliasMark)->RD_PERIODO+(cAliasMark)->RD_DATARQ+(cAliasMark)->RD_PD+(cAliasMark)->RD_SEMANA+(cAliasMark)->RD_SEQ+(cAliasMark)->RD_CC))
				oSelf:SaveLog("Funcionário: "+ " " + (cAliasMark)->RD_FILIAL + " - " + (cAliasMark)->RD_MAT + " - "+ "Processado")
				SRD->(RecLock("SRD", .F.))
				//---------------------------------------------------
				//BUSCA A DATA DE PAGAMENTO DA FOLHA DO FUNCIONARIO
				//---------------------------------------------------
				dDtPag			:= fBuscaDtPg((cAliasMark)->RD_PERIODO, (cAliasMark)->RD_PD, (cAliasMark)->RD_FILIAL, (cAliasMark)->RD_MAT)
				SRD->RD_DATPGT	:= dDtPag
				SRD->(MsUnlock())
			EndIf
		EndIf

		(cAliasMark)->(DbSkip())
	EndDo

	(cAliasMark)->(DbGoTop())

	oSelf:SaveLog("Correção de Data de Pagamento ID 0012 " + " - " + "Fim do processamento") //"Correção de Data de Pagamento ID 0012 "##"Fim do processamento"

	SetMarkAll(oMark:Mark(),.F. )

	oMark:Refresh() //Atualiza markbrowse

Return Nil

/*/{Protheus.doc} GPM005Ver
//Carrega registros
@author eduardo.vicente
@since 25/02/2018
@see (links_or_references)
/*/
Static Function GPM005Ver

	Processa( {|| GPM005Carga( ) } )

Return

/*/{Protheus.doc} GPM005Ver
//Carrega registros
@author eduardo.vicente
@since 25/02/2018
@see (links_or_references)
/*/
Static Function GPM005Carga()

	Local aArea		:= GetArea()
	Local cAliasSRD	:= GetNextAlias()
	Local cAliasSRV	:= GetNextAlias()
	Local aCampos  	:= SRD->(dbStruct())
	Local nI		:= 1
	Local nT		:= 1
	Local lTem		:= .F.

	//-----------------------------------------------------
	//MOMENTO DA LIMPEZA NO GRID PARA NOVA CARGA DE DADOS
	//-----------------------------------------------------
	DbSelectArea(cAliasMark)
	(cAliasMark)->(DbGotop())

	While !(cAliasMark)->(Eof() )
		RecLock(cAliasMark,.F.)
		(cAliasMark)->(__dbZap())
		(cAliasMark)->(msUnlock())
		(cAliasMark)->(dbSkip())
	End

	//---------------------------------------------------
	//CONSULTA AS VERBAS VINCULADAS AO ID DE VERBA 0012
	//---------------------------------------------------
	BeginSql alias cAliasSRV
		SELECT RV_FILIAL, RV_COD
		FROM %table:SRV% SRV
		WHERE 	SRV.D_E_L_E_T_ = ' ' AND RV_CODFOL = '0012' AND
				SRV.RV_FILIAL BETWEEN %exp:cFilIn% AND %exp:cFilFim%
	EndSql


	DbSelectArea(cAliasMark)
	//--------------------------------------------------------------
	//FAZ VARREDURA DE SRV PARA REALIZAÇÃO DO INCREMENTO NA
	// TABELA TEMPORÁRIA.
	//--------------------------------------------------------------
	While (cAliasSRV)->(!Eof())

		IncProc("Processando..")
		//---------------------------------------------------------------
		//CONSULTA NA SRD BUSCANDO TODOS OS REGITROS DIVERGENTES
		//ONDE A DA DE PAGAMENTO ESTÁ DIFERENTE DA RCH PARA ATUALIZAÇÃO
		//---------------------------------------------------------------
		cAliasSRD	 := GetNextAlias()
		BeginSql alias cAliasSRD
			SELECT SRD.* FROM  %table:SRD% AS SRD
			INNER JOIN  %table:RCH% AS RCH ON  (
											RCH.RCH_PER = RD_PERIODO AND
											RCH.RCH_DTPAGO <> RD_DATPGT AND
											RCH.RCH_PROCES = RD_PROCES AND
											RCH.D_E_L_E_T_= ' ' AND
											RCH.RCH_ROTEIR = 'ADI'	AND
											RCH.%notDel%)
			WHERE 	SRD.%notDel% AND
					SRD.RD_PD = %exp:(cAliasSRV)->RV_COD% AND
					SRD.RD_FILIAL = %exp:(cAliasSRV)->RV_FILIAL% AND
					SRD.RD_PERIODO BETWEEN %exp:cPerIni% AND %exp:cPerFim%

		EndSql
		//-------------------------------------------------
		//PREENCHIMENTO DE CADA CAMPO DA TABELA TEMPORÁRIA
		//-------------------------------------------------
		While!(cAliasSRD)->(eof())
			lTem := .T.
			RecLock(cAliasMark,.T.)
			For nT := 1 To Len( aCampos )
				If ValType((cAliasMark)->( &(aCampos[nT, 1]) )) == "D"
					(cAliasMark)->( &(aCampos[nT, 1]) ) := StoD((cAliasSRD)->( &(aCampos[nT, 1]) ))
				Else
					(cAliasMark)->( &(aCampos[nT, 1]) ) := (cAliasSRD)->( &(aCampos[nT, 1]) )
				EndIf
			Next nT
			(cAliasMark)->(MsUnLock())

			(cAliasSRD)->(DbSkip())
		EndDo
		(cAliasSRD)->(dbCloseArea())
		(cAliasSRV)->(DbSkip())
	EndDo

	(cAliasSRV)->( dbCloseArea() )
	(cAliasMark)->(dbGotop())

	If !lTem
		Aviso(STR0006, STR0008, {STR0009})
	EndIf

	RestArea(aArea)

	oMark:Refresh(.T.)

Return

/*/{Protheus.doc} fGP005PRM
//TODO Interface de parametros para que haja um filtro dos
//dados no decorrer da rotina
@author Eduardo
@since 11/02/2019
@version undefined
@return return, return_description
/*/
Static Function fGP005PRM()
Local cDlgTitulo 	:= "PARÂMETROS"
Local aSvKeys		:= GetKeys()
Local aAdvSize		:= MsAdvSize(  , .T. , 390 )
Local aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
Local aObjCoords	:= { { 0 , 0 , .T. , .T. } }
Local aObjSize 		:= MsObjSize( aInfoAdvSize , aObjCoords )
Local lRet			:= .F.
Local bOk     		:= {||lRet:=.T.,oDlg:End()}
Local bCancel		:= {|| oDlg:End()}
Local nDiv			:= 1.5
Local oDlg 			:= NIL



DEFINE MSDIALOG oDlg TITLE cDlgTitulo From aAdvSize[7],0 TO aAdvSize[6]/nDiv,aAdvSize[5]/nDiv OF GetWndDefault() PIXEL
	@ aObjSize[1,1]	  , aObjSize[1,2]+10 SAY  "Filial Inicial:" SIZE 70,10 PIXEL OF oDlg//"FILIAL INICIAL"
	@ aObjSize[1,1]	  , aObjSize[1,2]+50 		MSGET oGet VAR cFilIn PICTURE "@!" SIZE TamSx3("RA_FILIAL")[1]+10,10 OF oDlg PIXEL F3 "XM0" VALID( iif(!Empty(cFilFim),cFilFim >= cFilIn,.T.)) HASBUTTON
	@ aObjSize[1,1]+20, aObjSize[1,2]+10 SAY  "Filial Final:" SIZE 70,10 PIXEL OF oDlg //"FILIAL FINAL"
	@ aObjSize[1,1]+20, aObjSize[1,2]+50 	MSGET oGet VAR cFilFim PICTURE "@!" SIZE TamSx3("RA_FILIAL")[1]+10,10 OF oDlg PIXEL F3 "XM0" VALID(NaoVazio()  .And. cFilFim>=cFilIn) HASBUTTON
	@ aObjSize[1,1]+40, aObjSize[1,2]+10 SAY  "Per. Inicial:" SIZE 70,10 PIXEL OF oDlg
	@ aObjSize[1,1]+40, aObjSize[1,2]+50 	MSGET oGet VAR  cPerIni PICTURE "@!" SIZE TamSx3("RCH_PER")[1]+10,10 OF oDlg PIXEL F3 "RCH10" VALID(iif(!Empty(cPerFim),cPerIni <= cPerFim,.T.)) HASBUTTON
	@ aObjSize[1,1]+60, aObjSize[1,2]+10 SAY  "Per. Final:" SIZE 70,10 PIXEL OF oDlg //PERIODO FINAL
	@ aObjSize[1,1]+60, aObjSize[1,2]+50 	MSGET oGet VAR  cPerFim PICTURE "@!" SIZE TamSx3("RCH_PER")[1]+10,10 OF oDlg PIXEL F3 "RCH10" VALID(NaoVazio()  .And. cPerIni<=cPerFim) HASBUTTON
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

If Empty(cPerfim) .Or. Empty(cFilFim)
	Help( ,, STR0006,, STR0010,1,0 )
	lRet:=	.F.
	fGP005PRM()
EndIf
Return( lRet )