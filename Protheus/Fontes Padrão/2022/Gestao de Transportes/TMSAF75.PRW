#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF75.CH"
#INCLUDE "FOLDER.CH"

#Define XMARK   01
#Define XTITULO 02
#Define XCAMPO  03
#Define XOBRIG  04
                                 
Static aIndDDD		:= {}
Static aIndDDE		:= {}
Static aQtdDDD		:= {}
Static aQtdDDE		:= {}
Static cAliasMbw     := ""
Static aIndTmp		:= {}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsAF75
@autor		: Eduardo Alberti
@descricao	: Configuracao de Itens de Quebra de Agendamento Automatico.
@since		: Oct./2015
@using		: MRP Para EDI do SigaTMS.
@review	:  
/*/
//-------------------------------------------------------------------------------------------------
Function TmsAF75()

	Local oDlgMrk    := Nil
	Local aAlias     := {}
	Local aColumns   := {}
	Local nI         := 0
	Local aSeek      := {}
	Local lRet       := .F.

	Private aRotina   := MenuDef()
	Private cCadastro := OemToAnsi(STR0001) //-- 'Configuracao de Itens de Quebra de Agendamento Automatico'
	
	//-- Validação Do Dicionário Utilizado
	If ! AliasInDic("DDF")
		MsgNextRel()	//-- É Necessário a Atualização Do Sistema Para a Expedição Mais Recente
		Return()
	EndIf	
	
	//-- Se Não Encontrar Quebra Padrão Inclui Automaticamente
	If !(TMSAF75Qbr())
		lRet := TMSAF75Pdr() //-- Inclui Quebra Padrão
	EndIf

	//----------------------------------------------------------
	//-- Retorna as colunas para o preenchimento da FWMBrowse
	//----------------------------------------------------------
	aAlias		:= TmMapExcQr()
	cAliasMbw	:= aAlias[1]:GetAlias()
	aColumns 	:= aAlias[2]

	//----------------------------------------------------------
	//-- Insere Indice De Busca Por Rotinas
	//----------------------------------------------------------
	Aadd(aSeek,{ STR0004		, {{"","C",20,0, "DDF_CODQBR", STR0004 }}, 1, .T. } ) //-- "Código"
	Aadd(aSeek,{ STR0005		, {{"","C",10,0, "DDF_DESQBR", STR0005 }}, 2, .T. } ) //-- "Descrição"

	(cAliasMbw)->(DbGoTop())
	If !(cAliasMbw)->(Eof())

		//------------------------------------------
		//--Criação da FWMBrowse
		//------------------------------------------
		oMBrowse:= FWMBrowse():New()

		oMBrowse:AddLegend("DDF_QBRGEN == 'S'", "GREEN"  ,STR0025 + Space(1) + STR0026 ,"DDF_QBRGEN" )	// "Quebra" "Padrão"
		oMBrowse:AddLegend("DDF_QBRGEN <> 'S'", "YELLOW" ,STR0025 + Space(1) + STR0027 ,"DDF_QBRGEN" )	// "Quebra" "Específica"

		oMBrowse:SetOwner(oDlgMrk)
		oMBrowse:SetAlias(cAliasMbw)
		oMBrowse:SetMenuDef("TmsAF75")

		oMBrowse:SetTemporary(.T.)
		oMBrowse:SetSeek(,aSeek)

		oMBrowse:SetDescription( OemToAnsi( STR0018 ) + " TMS " ) // "Quebra de Agendamento "
		oMBrowse:SetColumns(aColumns)
		oMBrowse:Activate()

	Else
		Help('',1,'TMSAF7501',, STR0028 ,1,0) //-- "Não Existem Registros Para Exibição."
	EndIf

	aAlias[1]:Delete()

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@autor		: Eduardo Alberti
@descricao	: Funcao Para Montagem Do Menu Funcional Padrao Protheus
@since		: Oct./2015
@using		: MRP Para EDI do SigaTMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef(cTipo)

	Local aArea      := GetArea()
	Local aRotina    := {}

	Default cTipo  := "P"

	If cTipo == "M"
	
		ADD OPTION aRotina TITLE STR0024				ACTION 'TmsDDFRet'     OPERATION 2 ACCESS 0 DISABLE MENU 	//-- 'Confirmar'
		
	ElseIf cTipo == "P"

		ADD OPTION aRotina TITLE "Pesquisar"			Action 'TMSFA75Psq'    OPERATION 1 ACCESS 0 DISABLE MENU	//-- Pesquisar
		ADD OPTION aRotina TITLE STR0013				ACTION 'TMSFA75Mnt'    OPERATION 2 ACCESS 0 DISABLE MENU	//-- Visualizar
		ADD OPTION aRotina TITLE STR0014				ACTION 'TMSFA75Mnt'    OPERATION 3 ACCESS 0 					//-- Incluir
		ADD OPTION aRotina TITLE STR0015				ACTION 'TMSFA75Mnt'    OPERATION 4 ACCESS 0 DISABLE MENU	//-- Alterar
		ADD OPTION aRotina TITLE STR0016   			ACTION 'TMSFA75Mnt'    OPERATION 5 ACCESS 0 DISABLE MENU	//-- Excluir
		ADD OPTION aRotina TITLE STR0029				ACTION 'TmsaF75Leg'    OPERATION 2 ACCESS 0 DISABLE MENU	//-- Legenda

	EndIf
	
	//----------------------------------------------------------------------------
	//-- Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	//----------------------------------------------------------------------------
	If ExistBlock("TMF75MNU")
		ExecBlock("TMF75MNU",.F.,.F.)
	EndIf
	
	RestArea(aArea)

Return(aRotina)
//-------------------------------------------------------------------
/*/{Protheus.doc}TmMapExcQr
Executa Query Para Geração Do Browse Temporário
@author Eduardo Alberti
@since  Oct/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function TmMapExcQr(cAliasMbw)

	Local aArea      := GetArea()
	Local aStru      := {}
	Local aColumns   := {}	//-- Array com as colunas a serem apresentadas
	Local aRestrict  := {"D_E_L_E_T_","R_E_C_N_O_","R_E_C_D_E_L_"}
	Local nX         := 0
	Local nI         := 0
	Local aCampos    := {}
	Local oTempTable := NIL
	Local cRealName	 := ""
	Local cQuery	 := ""
	Local lRet		 := .T. 
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local cAliasTmp  := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local oStructTmp	:= Nil
	Local aFldsTmp		:= {}
	Local nPosTmp		:= 0

	cQuery += " SELECT      DISTINCT DDF.DDF_CODQBR, DDF.DDF_DESQBR, DDF_ATIVO, DDF_QBRGEN "
	cQuery += " FROM        	" +	RetSqlName("DDF") + " DDF "
	cQuery += " WHERE       DDF.DDF_FILIAL  = '" + xFilial("DDF") + "' "
	cQuery += " AND        (DDF.DDF_QBRNV1 = 'S' OR DDF_QBRNV2 = 'S')
	cQuery += " AND         DDF.D_E_L_E_T_  = ' ' "

	cQuery := ChangeQuery(cQuery)

	//-- Executa Query
	Processa( {|| Eval(bQuery)}, STR0030 , STR0030 ,.F.)	//-- "Pesquisando"
	
	//-- Le Estrutura Da Query
	aCampos := (cAliasT)->(DbStruct())

	oStructTmp := FWFormStruct(1, "DDF")
	aFldsTmp := oStructTmp:aFields

	//-- Gera Vetor Estrutura Do Browse
	For nX := 1 To Len(aCampos)

		If (nPosTmp := aScan(aFldsTmp, {|x| AllTrim(x[3]) == aCampos[nX][1]})) > 0
			If aScan(aRestrict,aCampos[nX,1]) == 0
				aAdd(aStru, {aFldsTmp[nPosTmp][3], aFldsTmp[nPosTmp][4] ,aFldsTmp[nPosTmp][5] ,aFldsTmp[nPosTmp][6]})
			EndIf
		EndIf

	Next nX

	FreeObj(oStructTmp)

	aSize(aFldsTmp, 0)
	aFldsTmp := Nil

	oTempTable := FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aStru )
	oTempTable:AddIndex("01", {"DDF_CODQBR"} )
	oTempTable:AddIndex("02", {"DDF_DESQBR"} )
	oTempTable:Create()

	cRealName	:= oTempTable:GetRealName()
	
	Processa( {|| lRet := TMSSqlToTemp(cQuery, aStru, cRealName , .T.  ) } )	// Cria arquivo temporario
	
	If !lRet
		oTempTable:Delete()
		aColumns	:= {} 
		cAliasTmp	:= ""
	Else
		//-- Posiciona no primeiro registro
		(cAliasTmp)->(dbGoTop()) 
	EndIf
	
	If Empty(cAliasMbw)
		DbSetOrder(1)

		//--Define as colunas a serem apresentadas na FWMarkBrowse
		For nX := 1 To Len(aStru)
	
			DbSelectArea("SX3")
			DbSetOrder(2)
			If MsSeek(aStru[nX,1])
	
				cTab := SubStr(aStru[nX][1],1,At("_",aStru[nX][1]) -1)
	
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
				aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
				aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
				aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
				aColumns[Len(aColumns)]:SetPicture(PesqPict(cTab,aStru[nX][1]))
	
			EndIf
		Next nX
	EndIf	

	//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return({oTempTable,aColumns})

//-------------------------------------------------------------------
/*/{Protheus.doc}Tmsa029Leg
@descricao	: Legenda
@author Eduardo Alberti
@since  Dec/2014
@version 11
/*/
//-------------------------------------------------------------------
Function TmsaF75Leg()

	Local aLegenda  := {}
	Local cTitulo   := STR0029 //  "Legenda"

	AADD(aLegenda,{"BR_VERDE"  		, STR0026	})	// "Liberado"
	AADD(aLegenda,{"BR_AMARELO" 	, STR0027	})	// "Específica"

	BrwLegenda(cTitulo, STR0029 , aLegenda) // "Legenda"

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAF75Qbr
Executa Checar se Existe Quebras Cadastradas, onde nao existindo,apos o retorno dessa funcao sera inserida uma Quebra padrao na base do cliente.	
@author Adalberto S.M
@since  Dec/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function TMSAF75Qbr()

	Local lRet			:= .F.
	Local aArea		:= GetArea()
	Local cQuery		:= ""
	Local cAliasQry	:= GetNextAlias()
		
	cQuery	:= " "
	cQuery	+= " SELECT		COUNT( * ) TOTREG "
	cQuery	+= " FROM 			" + RetSqlName("DDF") + " DDF "
	cQuery	+= " WHERE 		DDF.DDF_FILIAL =  '" + xFilial("DDF") + "' "
	cQuery	+= " AND 			DDF.DDF_QBRGEN = 'S'"
	cQuery	+= " AND 			DDF.D_E_L_E_T_ = ' ' "

	cQuery 	:= ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAliasQry, .F., .T.)
	
	If (cAliasQry)->( !Eof() ) .And. (cAliasQry)->TOTREG > 0
		lRet := .T.
	EndIf
	
	(cAliasQry)->( DbCloseArea() )
	
	RestArea( aArea )

Return( lRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAF75Pdr
Inclusao dos registros padrao de Quebra de Agendamento	
@author Adalberto S.M
@since  Dec/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function TMSAF75Pdr()

	Local lRet			:= .F.
	Local aColsAGE	:= {}
	Local aColsOC		:= {}
	Local nCount		:= 0
	Local cCODQBR		:= GetSx8Num("DDF","DDF_CODQBR")
	Local nStackSX8	:= Val(cCODQBR)

	aIndDDD	:= {}
	aIndDDE	:= {}
	aQtdDDD	:= {}
	aQtdDDE	:= {}

	Aadd( aColsAGE, 'DDD_FILIAL')
	Aadd( aColsAGE, 'DDD_DATAGE')
	Aadd( aColsAGE, 'DDD_HORAGE')
	Aadd( aColsAGE, 'DDD_CODSOL')

	Aadd( aColsOC, 'DDE_FILIAL')
	Aadd( aColsOC, 'DDE_DATAGE')
	Aadd( aColsOC, 'DDE_HORAGE')
	Aadd( aColsOC, 'DDE_CLIDES')
	Aadd( aColsOC, 'DDE_LOJDES')
	Aadd( aColsOC, 'DDE_SQEDES')
	Aadd( aColsOC, 'DDE_CLIREM')
	Aadd( aColsOC, 'DDE_LOJREM')
	Aadd( aColsOC, 'DDE_SQEREM')

	//-- Inicializa Controle Transacional (TTS)
	Begin Transaction

		For nCount := 1 To Len( aColsAGE )

			DbSelectArea("DDF")
			dbSetOrder(1)
			If DDF->( MsSeek( xFilial('DDF') + cCODQBR + aColsAGE[ nCount] ) )
				RecLock("DDF",.F.)
			Else
				RecLock("DDF",.T.)
				DDF->DDF_QBRNV2	:= "N"
			EndIf
	
			DDF->DDF_FILIAL	:= xFilial("DDF")
			DDF->DDF_CODQBR	:= cCODQBR
			DDF->DDF_DESQBR	:= STR0017 + " - SIGATMS" //-- "QUEBRA AGENDAMENTO PADRAO"
			DDF->DDF_CPOSX3	:= aColsAGE[ nCount]
			DDF->DDF_QBRNV1	:= "S"
			DDF->DDF_QBRGEN	:= "S"
			DDF->DDF_ATIVO	:= "S"
			DDF->(MsUnLock())

			//-----------------------------------------------------------
			// BUSCAR INDICES EM QUE O RESPECTIVO CAMPO SEJA UTILIZADO
			//-----------------------------------------------------------
			SIX->( DbSetOrder(1) )
			If SIX->( DbSeek( 'DDD' ) )

				While !SIX->( Eof() ) .And. SIX->INDICE == 'DDD'

					nPosicao := 0
					nPosicao := AT(AllTrim(DDF->DDF_CPOSX3), AllTrim(SIX->CHAVE) )
				
					If nPosicao > 0
						Aadd( aIndDDD, { SIX->ORDEM, AllTrim(DDF->DDF_CPOSX3), nPosicao } )

						nPosicao := 0
						nPosicao := aScan( aQtdDDD, { | x |  x[1] == SIX->ORDEM } )
						
						If nPosicao == 0
							Aadd( aQtdDDD, { SIX->ORDEM, 1} )
						Else
							aQtdDDD[nPosicao, 2] := aQtdDDD[nPosicao, 2] + 1
						EndIf
					EndIf

					SIX->( DbSkip() )
				EndDo
			EndIf

			lRet := .T.
		Next nCount

		For nCount := 1 To Len( aColsOC )

			DbSelectArea("DDF")
			dbSetOrder(1)
			If DDF->( MsSeek( xFilial('DDF') + cCODQBR + aColsOC[ nCount ] ) )
				RecLock("DDF",.F.)
			Else
				RecLock("DDF",.T.)
				DDF->DDF_QBRNV1	:= "N"
			EndIf

			DDF->DDF_FILIAL	:= xFilial("DDF")
			DDF->DDF_CODQBR	:= cCODQBR
			DDF->DDF_DESQBR	:= STR0017 + " - SIGATMS" //-- "QUEBRA AGENDAMENTO PADRAO"
			DDF->DDF_CPOSX3	:= aColsOC[ nCount ]
			DDF->DDF_QBRNV2	:= "S"
			DDF->DDF_QBRGEN	:= "S"
			DDF->DDF_ATIVO	:= "S"
			DDF->(MsUnLock())

			//-----------------------------------------------------------
			// BUSCAR INDICES EM QUE O RESPECTIVO CAMPO SEJA UTILIZADO
			//-----------------------------------------------------------
			SIX->( DbSetOrder(1) )
			If SIX->( DbSeek( 'DDE' ) )

				While !SIX->( Eof() ) .And. SIX->INDICE == 'DDE'

					nPosicao := 0
					nPosicao := AT(AllTrim(DDF->DDF_CPOSX3), AllTrim(SIX->CHAVE) )
				
					If nPosicao > 0
						Aadd( aIndDDE, { SIX->ORDEM, AllTrim(DDF->DDF_CPOSX3), nPosicao } )

						nPosicao := 0
						nPosicao := aScan( aQtdDDE, { | x |  x[1] == SIX->ORDEM } )
						
						If nPosicao == 0
							Aadd( aQtdDDE, { SIX->ORDEM, 1} )
						Else
							aQtdDDE[nPosicao, 2] := aQtdDDE[nPosicao, 2] + 1
						EndIf
					EndIf

					SIX->( DbSkip() )
				EndDo
			EndIf

			lRet := .T.
			
		Next nCount

		ConfirmSX8()

	//-- Finaliza Controle Transacional (TTS)
	End Transaction

Return( lRet )
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSFA75Psq
@autor		: Eduardo Alberti
@descricao	: Função Para Pesquisa Do Arquivo DDF Retornando Para Arq. Temporário
@since		: Oct./2015
@using		: MRP Para EDI do SigaTMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMSFA75Psq( cAliasT, nReg, nOpcx, cArray)

	Local cAlsBrw	:= oMBrowse:cAlias

	DbSelectArea("DDF")
	DbSetOrder(1)
	DDF->(DbGoTop())
		
	AxPesqui()

	DbSelectArea(cAlsBrw)
	(cAlsBrw)->(MsSeek(DDF->DDF_CODQBR))

Return(.t.)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSFA75Mnt
@autor		: Adalberto S.M 
@descricao	: Manutencao de Itens de Quebra de Agendamento Automatico
@since		: Oct./2015
@using		: MRP Para EDI do SigaTMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMSFA75Mnt( cAliasT, nReg, nOpcx, cArray)

	Local aArea      		:= GetArea()
	Local cCODQBR			:= ""
	Local cDESQBR			:= ""
	Local aVisual			:= {}
	Local aAltEnc			:= {}
	Local aQuebra			:= {}
	Local aHeadAGE		:= {}
	Local aColsAGE		:= {}
	Local aColsOC			:= {}
	Local aPosObj			:= {}
	Local aButtons		:= {}
	Local aObjects		:= {}
	Local aAcao			:= {}
	Local lMark			:= .F.
	Local lRet				:= .T.
	Local lPadrao			:= .F.
	Local nOpcA			:= 0
	Local nStackSX8		:= Val(cCODQBR)
	Local oNoMarked		:= LoadBitmap( GetResources(),'LBNO' )
	Local oMarked			:= LoadBitmap( GetResources(),'LBOK' )
	Local aSizeT			:= MsAdvSize(.T.)
	Local oDlg
	Local oChk1
	Local oListAGE
	Local oListOC
	Local oListLim
	Local aColsLim		:= {}
	Local cAlsBrw			:= oMBrowse:cAlias
	Local nLimite			:= 0
	
	Local oCombo
	Local cTpQbr			:= ""
	Local aTpQbr			:= {}
	Local aTipos			:= RetSx3Box( Posicione('SX3', 2, 'DDF_TPQBR', 'X3CBox()' ),,, 1 )
	Local nI				:= 0
	
	//-- Carrega ComboBox da Dialog
	For nI := 1 To Len( aTipos )
		aAdd( aTpQbr, aTipos[nI][3] )
	Next nI	
	
	//-- Reposiciona Do Arquivo Temporario Para Tabela DDF
	If nOpcx <> 3
		
		DbSelectArea("DDF")
		DbSetOrder(1)
		MsSeek(xFilial("DDF") + (cAlsBrw)->DDF_CODQBR )
		
	EndIf	

	RegToMemory( 'DDF', nOpcx==3 )
	
	cCODQBR	:= IIf(nOpcx == 3, GetSx8Num("DDF","DDF_CODQBR"), M->DDF_CODQBR)
	cDESQBR	:= IIf(nOpcx == 3, Space(Len(M->DDF_DESQBR)), M->DDF_DESQBR)
	aQuebra	:= IIf(nOpcx <> 3, TMSAF75Pad( M->DDF_CODQBR ), {} )

	If Len(aQuebra) > 0
		cDESQBR	:= aQuebra[ 1 ]
		lPadrao	:= aQuebra[ 2 ]
		lMark		:= aQuebra[ 3 ]
	EndIf
	
	If lPadrao
		//nOpcx := 2 // Mudar para opcao 'Visualizar' pois o registro Padrao nao podera nunca ser alterado pelo usuario
	EndIf

	//-- Dimensoes padroes
	aSetKey	:= {}
	aSizeT	:= MsAdvSize()
	AAdd( aObjects, { 100, 10, .T., .F.		} )
	AAdd( aObjects, { 100, 60, .T., .T., .T. 	} )
	AAdd( aObjects, { 160, 60, .T., .T., .T. 	} )

	aInfo	:= { aSizeT[ 1 ], aSizeT[ 2 ], aSizeT[ 3 ], (aSizeT[ 6 ] - 60), 5, 5 }
	aPosObj:= MsObjSize( aInfo, aObjects,.T.)
	nGd1	:= 2
	nGd2	:= 2
	nGd3	:= 100
	nGd4	:= aPosObj[2, 4] - aPosObj[2, 2] - 04

	//-------------------------------
	// Adicionar Titulo dos campos
	//-------------------------------
	Aadd( aHeadAGE, '   ')
	Aadd( aHeadAGE, AllTrim(Posicione('SX3', 2, 'DDF_CPOSX3', 'X3Titulo()') ) )
	Aadd( aHeadAGE, STR0003 + ' SX3')
	Aadd( aHeadAGE, AllTrim(Posicione('SX3', 2, 'DDF_QBRNV1', 'X3Titulo()') ) )
	Aadd( aHeadAGE, AllTrim(Posicione('SX3', 2, 'DDF_QBRNV2', 'X3Titulo()') ) )

	aColsAGE	:= TMSAF75ACo( 1, M->DDF_CODQBR )
	aColsOC	:= TMSAF75ACo( 2, M->DDF_CODQBR )
	aColsLim	:= TMSAF75ACo( 3, M->DDF_CODQBR, @nLimite )
	cTpQbr		:= X3Combo("DDF_TPQBR", M->DDF_TPQBR )
		
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000,000 TO 600, 1200 PIXEL
	@ aPosObj[2][1]-18, 005 SAY 		STR0004 													SIZE 050, 10 OF oDlg PIXEL		//-- 'Codigo'
	@ aPosObj[2][1]-18, 060 SAY 		STR0005													SIZE 050, 10 OF oDlg PIXEL		//-- 'Descrição'
	@ aPosObj[2][1]-18, 205 SAY 		STR0006													SIZE 050, 10 OF oDlg PIXEL		//-- 'Quebra Por:'
	
	@ aPosObj[2][1]-09, 005 MSGET 	cCODQBR			When .F. 									SIZE 050, 10 OF oDlg PIXEL
	@ aPosObj[2][1]-09, 060 MSGET 	cDESQBR			When !lPadrao Valid(!Empty(cDESQBR))	SIZE 130, 10 OF oDlg PIXEL 

	@ aPosObj[2][1]-09, 205 MSCOMBOBOX oCombo VAR cTpQbr ITEMS aTpQbr When !lPadrao 			SIZE 080, 10 OF oDlg PIXEL 

	@ aPosObj[2][1]-09, 290 CHECKBOX 	oChk1 	VAR lMark PROMPT STR0008 When !lPadrao 		SIZE 100,20 PIXEL OF oDlg ON CLICK (lMark := TMSAF75Atv( cCODQBR, lMark, nOpcx ), oChk1:Refresh()) //-- "Quebra Habilitada?"
				
	@ aPosObj[2][1] + 20, aPosObj[2][2] 			SAY STR0036									SIZE 150, 08 OF oDlg PIXEL		//-- 'Quebra de Agendamentos'
	@ aPosObj[2][1] + 30, aPosObj[2][2] 			LISTBOX oListAGE VAR _cOpcao FIELDS HEADER aHeadAGE[ 1 ], aHeadAGE[ 2 ], aHeadAGE[ 3 ] Size (aPosObj[2][3] / 2) - 160, aPosObj[2][4] - 40 PIXEL OF oDlg ON DBLCLICK ( IIf(lPadrao, aColsAGE[oListAGE:nAt, XMARK], Iif(!aColsAGE[oListAGE:nAt, XOBRIG], aColsAGE[oListAGE:nAt, XMARK] := !aColsAGE[oListAGE:nAt, XMARK], .T.)), oListAGE:Refresh() )

	@ aPosObj[2][1] + 20, aPosObj[2][2] + 200 	SAY STR0037									SIZE 150, 08 OF oDlg PIXEL		//-- 'Quebra de Solicitacao de Coleta'
	@ aPosObj[2][1] + 30, aPosObj[2][2] + 200  	LISTBOX oListOC  VAR _cOpcao FIELDS HEADER aHeadAGE[ 1 ], aHeadAGE[ 2 ], aHeadAGE[ 3 ] Size (aPosObj[2][3] / 2) - 160, aPosObj[2][4] - 40 PIXEL OF oDlg ON DBLCLICK ( IIf(lPadrao, aColsOC[oListOC:nAt, XMARK], Iif(!aColsOC[oListOC:nAt, XOBRIG], aColsOC[oListOC:nAt, XMARK]   := !aColsOC[oListOC:nAt, XMARK], .T.)), oListOC:Refresh() )
		
	@ aPosObj[2][1] + 20, aPosObj[2][2] + 400 	SAY STR0011 									SIZE 150, 08 OF oDlg PIXEL		//-- 'Valor Limite'
	@ aPosObj[2][1] + 15, aPosObj[2][2] + 430		MSGET nLimite Picture PesqPict("DDF","DDF_LIMITE")	When !lPadrao 	SIZE 60, 10 OF oDlg PIXEL
	@ aPosObj[2][1] + 30, aPosObj[2][2] + 400  	LISTBOX oListLim VAR _cOpcao FIELDS HEADER aHeadAGE[ 1 ], aHeadAGE[ 2 ], aHeadAGE[ 3 ] Size (aPosObj[2][3] / 2) - 160, aPosObj[2][4] - 40 PIXEL OF oDlg ON DBLCLICK (TmsAF75Dbl(lPadrao,@aColsLim,oListLim:nAt),oListLim:Refresh())  //--( IIf(lPadrao, aColsLim[oListLim:nAt, XMARK], Iif(!aColsLim[oListLim:nAt, XOBRIG], aColsLim[oListLim:nAt, XMARK] := !aColsLim[oListLim:nAt, XMARK], .T.)), oListLim:Refresh() )

	oListAGE:SetArray(aColsAGE)
	oListOC:SetArray(aColsOC)
	oListLim:SetArray(aColsLim)

	oListAGE:bLine := { || { If (  aColsAGE[oListAGE:nAt, XMARK],oMarked, oNoMarked),;
		aColsAGE[oListAGE:nAt, XTITULO],;
		aColsAGE[oListAGE:nAt, XCAMPO]}}

	oListOC:bLine := { || { If (  aColsOC[oListOC:nAt, XMARK],oMarked, oNoMarked),;
		aColsOC[oListOC:nAt, XTITULO],;
		aColsOC[oListOC:nAt, XCAMPO]}}
		                                 
	oListLim:bLine := { || { If (  aColsLim[oListLim:nAt, XMARK],oMarked, oNoMarked),;
		aColsLim[oListLim:nAt, XTITULO],;
		aColsLim[oListLim:nAt, XCAMPO]}}

	oListAGE:Refresh()
	oListOC:Refresh()
	oListLim:Refresh()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If( TmsAF75Vl(nOpcx,lPadrao,cCODQBR,aColsAGE,aColsOC,aColsLim,nLimite,cTpQbr),(nOpcA := 1,oDlg:End()),Nil) },{|| nOpcA := 0,oDlg:End()},,aButtons)

	If nOpcA == 1
		aIndDDD	:= {}
		aIndDDE	:= {}
		aQtdDDD	:= {}
		aQtdDDE	:= {}
	
		If nOpcx == 5 .And. Len(aAcao) == 0 .And. lMark
			aAcao := {} //TMSAF75Atv( lMark, nOpcx )
		EndIf

		lRet := TMSAF75Grv(nOpcx, cCODQBR, cDESQBR, cTpQbr, lMark, aColsAGE, aColsOC, aColsLim, nStackSX8, aAcao, nLimite)

	Else
		RollBackSx8()
	EndIf

	RestArea(aArea)

Return ( lRet )
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsAF75Dbl
@autor		: Eduardo Alberti
@descricao	: Executado No Duplo Click Dos Campos Com Valores Numericos, Permite a Marcação De Apenas Um Campo          
@since		: Nov./2015
@using		: MRP Para EDI do SigaTMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function TmsAF75Dbl(lPadrao,aColsLim,nLinPos)

Local nLin := 0

If !lPadrao

	For nLin := 1 To Len(aColsLim)
	
		If nLin <> nLinPos
			aColsLim[nLin, XMARK] := .F. //-- Desmarca Campo
		Else
			aColsLim[nLin, XMARK] := Iif(aColsLim[nLin, XMARK],.F.,.T.) //-- Marca/Desmarca Campo Posicionado
		EndIf		
	Next nLin
EndIf

Return()
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsAF75Vl
@autor		: Eduardo Alberti
@descricao	: Validação Da Tela De Quebras Após Clicar OK          
@since		: Nov./2015
@using		: MRP Para EDI do SigaTMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function TmsAF75Vl(nOpcx,lPadrao,cCODQBR,aColsAGE,aColsOC,aColsLim,nLimite,cTpQbr)

	Local aArea   	:= GetArea()
	Local lRet 		:= .t.
	Local nLin 		:= 0
	Local lMark		:= .f.
	Local aTipos		:= RetSx3Box( Posicione('SX3', 2, 'DDF_TPQBR', 'X3CBox()' ),,, 1 )
	Local nI			:= 0
	Local cQuery		:= ""
	Local cAlsQry		:= ""
	Local cClientes	:= ""

	If !lPadrao

		If nOpcx == 5 //-- Exclusão

			cAlsQry	:= GetNextAlias()
		
			//-- Pesquisa Clientes Utilizando o Cadastro
			cQuery	:= " "
			cQuery	+= " SELECT		DEC_CODCLI, DEC_LOJCLI "
			cQuery	+= " FROM 			" + RetSqlName("DEC") + " DEC "
			cQuery	+= " WHERE 		DEC.DEC_FILIAL =  '" + xFilial("DEC") + "' "
			cQuery	+= " AND 			DEC.DEC_CODQBR = '" + cCODQBR + "'"
			cQuery	+= " AND 			DEC.D_E_L_E_T_ = ' ' "

			cQuery 	:= ChangeQuery(cQuery)

			dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAlsQry, .F., .T.)
	
			If (cAlsQry)->( !Eof() )
			
				//-- Determina Clientes Utilizando o Cadastro
				DbSelectArea(cAlsQry)
				(cAlsQry)->( DbGoTop() )
				While (cAlsQry)->( !Eof() )
				
					cClientes := Iif( !Empty(cClientes),",","") + (cAlsQry)->DEC_CODCLI + "-" + (cAlsQry)->DEC_LOJCLI
					
					(cAlsQry)->( DbSkip() )
				EndDo
				
				If !Empty(cClientes)			
					lRet := .F.
					Help("",1,"TMSAF7506",/*Titulo*/, STR0034 + cClientes /*Mensagem*/,1,0) //-- "Este Código De Quebra Está Em Uso No Cadastro 'Clientes X Layout' - TMSAE25. Cliente(s): "
				EndIf	
			EndIf
	
			//-- Fecha Arquivo Temporário
			If Select(cAlsQry) > 0
				(cAlsQry)->( DbCloseArea() )
			EndIf
		Else
	
			//-- Valida Tipo Da Quebra
			If Empty(cTpQbr)
				lRet := .f.
				Help("",1,"TMSAF7505",/*Titulo*/, STR0033 /*Mensagem*/,1,0) //-- "Informe Um Tipo De Quebra Válido!"
			Else
				//-- Verifica Se Codigo De Quebra Existe No Combo De Opções
				If ( aScan( aTipos, { |x| Alltrim(x[3]) == Alltrim(cTpQbr) } ) == 0 )
					lRet := .f.
					Help("",1,"TMSAF7505",/*Titulo*/, STR0033 /*Mensagem*/,1,0) //-- "Informe Um Tipo De Quebra Válido!"
				EndIf
			EndIf
	
			//-- Verifica Se Existe Campo Marcado
			For nLin := 1 To Len(aColsLim)
	
				If aColsLim[nLin, XMARK]
					lMark := .t.
				EndIf

			Next nLin
	
			//-- Verifica Se Existe Campo Marcado e Não Existe Valor Limite Informado
			If lMark .And. nLimite <= 0
	
				lRet := .f.
				Help("",1,"TMSAF7503",/*Titulo*/, STR0031 /*Mensagem*/,1,0) //-- Informe Um Valor Limite Ou Desmarque o Campo Da Coluna "Valor Limite".
	
	
			ElseIf !(lMark) .And. nLimite > 0

				lRet := .f.
				Help("",1,"TMSAF7504",/*Titulo*/, STR0032 /*Mensagem*/,1,0) //-- Informe o Campo De Controle De Limite Ou Informe Zero No Campo "Valor Limite".
	
			EndIf
		EndIf
	Else
		lRet := .F.
		Help("",1,"TMSAF7507",/*Titulo*/, STR0035 /*Mensagem*/,1,0) //-- "Cadastros Incluidos Pelo Sistema Não Podem Ser Excluidos!"		
	EndIf

	RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAF75ACo
@autor		: Adalberto S.M 
@descricao	: Geracao do vetor aCols 
@since		: Oct./2015
@using		: MRP Para EDI do SigaTMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSAF75ACo( nTipo, cCODQBR, nLimite )

	Local aDados		:= {}
	Local aObrigat	:= {}
	Local aCampo		:= {}
	Local lObrigat	:= .F.
	Local cQuery		:= ""
	Local cAliasQry	:= GetNextAlias()
	Local nPosic		:= 0
	Local nCount		:= 0
	Local cAliasT		:= ""
	Local lBusca		:= .T.
	Local oStructTmp	:= Nil
	Local aFldsTmp		:= {}
	Local nI			:= 0
	Local cFldTipo		:= ""
	Local lFldVirtua	:= .T.
	Local cFldCampo		:= ""
	Local cFldTitulo	:= ""
	
	Default nTipo 	:= 0
	Default cCodQBR	:= ''

	If nTipo == 1 // Agendamento
		Aadd( aObrigat, 'DDD_FILIAL')
		Aadd( aObrigat, 'DDD_DATAGE')
		Aadd( aObrigat, 'DDD_HORAGE')
		Aadd( aObrigat, 'DDD_CODSOL')

	Else // Solicitacao de Coleta
		Aadd( aObrigat, 'DDE_FILIAL')
		Aadd( aObrigat, 'DDE_DATAGE')
		Aadd( aObrigat, 'DDE_HORAGE')
		Aadd( aObrigat, 'DDE_CLIDES')
		Aadd( aObrigat, 'DDE_LOJDES')
		Aadd( aObrigat, 'DDE_SQEDES')
		Aadd( aObrigat, 'DDE_CLIREM')
		Aadd( aObrigat, 'DDE_LOJREM')
		Aadd( aObrigat, 'DDE_SQEREM')
	EndIf

	For nCount := 1 To 3
		lObrigat := .F.

		If nTipo == 1 // Agendamento
			If nCount == 1
				cAliasT := "DDD"
			Else
				cAliasT := "DDE"
			EndIf
	
		Else // Solicitacao de Coleta
			If nCount == 1
				cAliasT := "DDE"
			Else
				cAliasT := "DDD"
			EndIf
		EndIf

		oStructTmp := FWFormStruct(1, cAliasT)
		aFldsTmp := oStructTmp:aFields

		For nI := 1 To Len(aFldsTmp)

			cFldTipo := aFldsTmp[nI][4]
			lFldVirtua := aFldsTmp[nI][14]
			cFldCampo := aFldsTmp[nI][3]
			cFldTitulo := aFldsTmp[nI][1]
			If nTipo == 3
				lBusca := aFldsTmp[nI][4] == 'N'
			Else
				lBusca := aFldsTmp[nI][4] <> 'N'
			EndIf

			If lBusca
		
				lObrigat := .F.
				
				If !lFldVirtua .AND. ( Ascan(aCampo, {|x| AllTrim(x) == SUBSTR( AllTrim(cFldCampo), RAT('_',  AllTrim(cFldCampo) ) + 1, Len( AllTrim(cFldCampo) ) - (RAT('_',  AllTrim(cFldCampo) ) ) )}) == 0)
				
					Aadd(aCampo, SUBSTR( AllTrim(cFldCampo), RAT('_',  AllTrim(cFldCampo) ) + 1, Len( AllTrim(cFldCampo) ) - (RAT('_',  AllTrim(cFldCampo) ) ) ) )
		
					If ( Ascan( aObrigat, { |x| x == AllTrim(cFldCampo)} ) > 0 )
						lObrigat := .T.
					EndIf
			
					Aadd( aDados, { lObrigat,;		// CHECK
					AllTrim(cFldTitulo),; 		// TITULO
					AllTrim(cFldCampo),; 		// CAMPO
					lObrigat} ) 						// Campo Obrigatorio
				EndIf
			EndIf
			
		Next
	
	Next nCount

	
	If Len(aDados) > 0

		cQuery	:= " "
		cQuery	+= " SELECT	DDF.DDF_CPOSX3, DDF.DDF_LIMITE "
		cQuery	+= " FROM 		" + RetSqlName("DDF") + " DDF "
		cQuery	+= " WHERE 	DDF.DDF_FILIAL =  '" + xFilial("DDF") + "' "
		cQuery	+= " AND 		DDF.DDF_CODQBR =  '" + cCODQBR + "' "
		cQuery	+= " AND 		DDF.DDF_ATIVO  =  '" + M->DDF_ATIVO + "' "

		If nTipo == 1
			cQuery +=    " AND	DDF.DDF_QBRNV1 = 'S'"
		ElseIf nTipo == 2
			cQuery +=    " AND	DDF.DDF_QBRNV2 = 'S'"
		EndIf

		cQuery 	+=     " AND	DDF.D_E_L_E_T_ = ' '"

		cQuery 	:= ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAliasQry, .F., .T.)
		
		TcSetField(cAliasQry,"DDF_LIMITE","N",TamSX3("DDF_LIMITE")[1],TamSX3("DDF_LIMITE")[2])
			
		If (cAliasQry)->( !Eof() )
			While (cAliasQry)->( !Eof() )

				nPosic := Ascan(aDados, {|x| AllTrim(x[3]) == AllTrim((cAliasQry)->DDF_CPOSX3) })

				If nPosic > 0
					aDados[ nPosic, 1 ] := .T.
				EndIf
				
				If (cAliasQry)->DDF_LIMITE > 0
					nLimite := (cAliasQry)->DDF_LIMITE
				EndIf	
	
				(cAliasQry)->( DbSkip() )
			EndDo
		EndIf
	
		(cAliasQry)->( DbCloseArea() )
	EndIf

Return (aDados)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAF75Grv
@autor		: Adalberto S.M 
@descricao	: Grava os Dados
@since		: Oct./2015
@using		: MRP Para EDI do SigaTMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSAF75Grv(nOpcx, cCODQBR, cDESQBR, cTpQbr, lMark, aColsAGE, aColsOC, aColsLim, nStackSX8, aAcao, nLimite)

	Local lRet			:= .F.
	Local nCount		:= 0
	Local nPosicao	:= 0
	Local aTipos		:= RetSx3Box( Posicione('SX3', 2, 'DDF_TPQBR', 'X3CBox()' ),,, 1 )
	
	//-- Resolve Expressão Do Combo
	cTpQbr := aTipos[aScan( aTipos, { |x| Alltrim(x[3]) == Alltrim(cTpQbr) } ),2]

	//-- Inicializa Controle Transacional (TTS)
	Begin Transaction

		If (nOpcx == 3) .Or. (nOpcx == 4)

			DbSelectArea("DDF")
			DbSetOrder(1)

			For nCount := 1 To Len( aColsAGE )

				If aColsAGE[ nCount, XMARK ]

					If DDF->( MsSeek( xFilial('DDF') + cCODQBR + PadR(aColsAGE[ nCount, XCAMPO ],TamSX3("DDF_CODQBR")[1]) ) )
						RecLock("DDF",.F.)
					Else
						RecLock("DDF",.T.)
						DDF->DDF_QBRNV2	:= "N"
					EndIf
	
					DDF->DDF_FILIAL	:= xFilial("DDF")
					DDF->DDF_CODQBR	:= cCODQBR
					DDF->DDF_DESQBR	:= Upper( AllTrim(cDESQBR) )
					DDF->DDF_CPOSX3	:= AllTrim(aColsAGE[ nCount, XCAMPO ])
					DDF->DDF_QBRNV1	:= "S"
					DDF->DDF_QBRGEN	:= Iif(DDF->DDF_QBRGEN == "S","S","N")
					DDF->DDF_ATIVO	:= IIf(lMark, "S", "N")
					DDF->DDF_TPQBR	:= cTpQbr
					DDF->(MsUnLock())

					lRet := .T.

					//-----------------------------------------------------------
					// BUSCAR INDICES EM QUE O RESPECTIVO CAMPO SEJA UTILIZADO
					//-----------------------------------------------------------
					SIX->( DbSetOrder(1) )
					If SIX->( DbSeek( 'DDD' ) )
						While !SIX->( Eof() ) .And. SIX->INDICE == 'DDD'
							nPosicao := 0
							nPosicao := AT(AllTrim(DDF->DDF_CPOSX3), AllTrim(SIX->CHAVE) )
						
							If nPosicao > 0
								Aadd( aIndDDD, { SIX->ORDEM, AllTrim(DDF->DDF_CPOSX3), nPosicao } )

								nPosicao := 0
								nPosicao := aScan( aQtdDDD, { | x |  x[1] == SIX->ORDEM } )
								
								If nPosicao == 0
									Aadd( aQtdDDD, { SIX->ORDEM, 1} )
								Else
									aQtdDDD[nPosicao, 2] := aQtdDDD[nPosicao, 2] + 1
								EndIf
							EndIf
							SIX->( DbSkip() )
						End
					EndIf
					
				ElseIf !aColsAGE[ nCount, XMARK ] .And. (nOpcx == 4)

					If DDF->( MsSeek( xFilial('DDF') + cCODQBR + AllTrim(aColsAGE[ nCount, XCAMPO ]) ) )

						RecLock("DDF",.F.)
						DDF->DDF_QBRNV1	:= "N"
						DDF->DDF_ATIVO	:= IIf(lMark, "S", "N")
						DDF->(MsUnLock())

						lRet := .T.

					EndIf
				EndIf
			Next nCount
	
			For nCount := 1 To Len( aColsOC )

				If aColsOC[ nCount, XMARK ]

					If DDF->( MsSeek( xFilial('DDF') + cCODQBR + AllTrim(aColsOC[ nCount, XCAMPO ]) ) )
						RecLock("DDF",.F.)
					Else
						RecLock("DDF",.T.)
						DDF->DDF_QBRNV1	:= "N"
					EndIf
	
					DDF->DDF_FILIAL	:= xFilial("DDF")
					DDF->DDF_CODQBR	:= cCODQBR
					DDF->DDF_DESQBR	:= Upper(cDESQBR)
					DDF->DDF_CPOSX3	:= AllTrim(aColsOC[ nCount, XCAMPO ])
					DDF->DDF_QBRNV2	:= "S"
					DDF->DDF_QBRGEN	:= Iif(DDF->DDF_QBRGEN == "S","S","N")
					DDF->DDF_ATIVO	:= IIf(lMark, "S", "N")
					DDF->DDF_TPQBR	:= cTpQbr
					DDF->(MsUnLock())

					lRet := .T.

					//-----------------------------------------------------------
					// BUSCAR INDICES EM QUE O RESPECTIVO CAMPO SEJA UTILIZADO 
					//-----------------------------------------------------------
					SIX->( DbSetOrder(1) )
					If SIX->( DbSeek( 'DDE' ) )

						While !SIX->( Eof() ) .And. SIX->INDICE == 'DDE'

							nPosicao := 0
							nPosicao := AT(AllTrim(DDF->DDF_CPOSX3), AllTrim(SIX->CHAVE) )
						
							If nPosicao > 0
								Aadd( aIndDDE, { SIX->ORDEM, AllTrim(DDF->DDF_CPOSX3), nPosicao } )

								nPosicao := 0
								nPosicao := aScan( aQtdDDE, { | x |  x[1] == SIX->ORDEM } )
								
								If nPosicao == 0
									Aadd( aQtdDDE, { SIX->ORDEM, 1} )
								Else
									aQtdDDE[nPosicao, 2] := aQtdDDE[nPosicao, 2] + 1
								EndIf
							EndIf

							SIX->( DbSkip() )
						EndDo
					EndIf

				ElseIf !aColsOC[ nCount, XMARK ] .And. (nOpcx == 4)

					If DDF->( MsSeek( xFilial('DDF') + cCODQBR + AllTrim(aColsOC[ nCount, XCAMPO ]) ) )

						RecLock("DDF",.F.)
						DDF->DDF_QBRNV2	:= "N"
						DDF->DDF_ATIVO	:= IIf(lMark, "S", "N")
						DDF->(MsUnLock())

						lRet := .T.

					EndIf
				EndIf
			Next nCount
	
			For nCount := 1 To Len( aColsLim )

				If aColsLim[ nCount, XMARK ]

					If DDF->( MsSeek( xFilial('DDF') + cCODQBR + AllTrim(aColsLim[ nCount, XCAMPO ]) ) )
						RecLock("DDF",.F.)
					Else
						RecLock("DDF",.T.)
						DDF->DDF_QBRNV1	:= "N"
					EndIf
	
					DDF->DDF_FILIAL	:= xFilial("DDF")
					DDF->DDF_CODQBR	:= cCODQBR
					DDF->DDF_DESQBR	:= Upper(cDESQBR)
					DDF->DDF_CPOSX3	:= AllTrim(aColsLim[ nCount, XCAMPO ])
					DDF->DDF_QBRNV2	:= "S"
					DDF->DDF_QBRGEN	:= Iif(DDF->DDF_QBRGEN == "S","S","N")
					DDF->DDF_ATIVO	:= IIf(lMark, "S", "N")
					DDF->DDF_TPQBR	:= cTpQbr
					DDF->DDF_LIMITE	:= nLimite
					DDF->(MsUnLock())

					lRet := .T.

					//-----------------------------------------------------------
					// BUSCAR INDICES EM QUE O RESPECTIVO CAMPO SEJA UTILIZADO 
					//-----------------------------------------------------------
					SIX->( DbSetOrder(1) )
					If SIX->( DbSeek( 'DDE' ) )

						While !SIX->( Eof() ) .And. SIX->INDICE == 'DDE'

							nPosicao := 0
							nPosicao := AT(AllTrim(DDF->DDF_CPOSX3), AllTrim(SIX->CHAVE) )
						
							If nPosicao > 0
								Aadd( aIndDDE, { SIX->ORDEM, AllTrim(DDF->DDF_CPOSX3), nPosicao } )

								nPosicao := 0
								nPosicao := aScan( aQtdDDE, { | x |  x[1] == SIX->ORDEM } )
								
								If nPosicao == 0
									Aadd( aQtdDDE, { SIX->ORDEM, 1} )
								Else
									aQtdDDE[nPosicao, 2] := aQtdDDE[nPosicao, 2] + 1
								EndIf
							EndIf

							SIX->( DbSkip() )
						EndDo
					EndIf

				ElseIf !aColsLim[ nCount, XMARK ] .And. (nOpcx == 4)

					If DDF->( MsSeek( xFilial('DDF') + cCODQBR + AllTrim(aColsLim[ nCount, XCAMPO ]) ) )

						RecLock("DDF",.F.)
						DDF->DDF_QBRNV2	:= "N"
						DDF->DDF_ATIVO	:= IIf(lMark, "S", "N")
						DDF->DDF_LIMITE	:= 0
						DDF->(MsUnLock())

						lRet := .T.

					EndIf
				EndIf
			Next nCount

			ConfirmSX8()

			If Len(aAcao) > 0

				DbSelectArea("DDF")
				DDF->(dbSetOrder(1))
				DDF->(DbSeek( xFilial('DDF') + AllTrim(aAcao[ 1 ]) ) )

				Do While !DDF->(Eof()) .And. DDF->DDF_FILIAL+DDF->DDF_CODQBR == xFilial('DDF') + AllTrim(aAcao[ 1 ])

					RecLock("DDF",.F.)
					DDF->DDF_ATIVO	:= IIF( aAcao[ 4 ], "S", "N")
					DDF->(MsUnLock())

					lRet := .T.

					DDF->(dbSkip())
				EndDo
			EndIf
									
		ElseIf (nOpcx == 5)

			DbSelectArea("DDF")
			DDF->(dbSetOrder(1))
			DDF->(DbSeek( xFilial('DDF') + cCODQBR ) )

			Do While !DDF->(Eof()) .And. DDF->DDF_FILIAL+DDF->DDF_CODQBR == xFilial('DDF') + cCODQBR

				RecLock("DDF", .F.)
				DDF->(dbDelete())
				DDF->(MsUnLock())

				lRet := .T.

				DDF->(dbSkip())
			EndDo

			If Len(aAcao) > 0

				DbSelectArea("DDF")
				DDF->(dbSetOrder(1))
				DDF->(DbSeek( xFilial('DDF') + AllTrim(aAcao[ 1 ]) ) )

				Do While !DDF->(Eof()) .And. DDF->DDF_FILIAL+DDF->DDF_CODQBR == xFilial('DDF') + AllTrim(aAcao[ 1 ])

					RecLock("DDF",.F.)
					DDF->DDF_ATIVO	:= IIF( aAcao[ 4 ], "S", "N")
					DDF->(MsUnLock())

					lRet := .T.

					DDF->(dbSkip())
				EndDo
			EndIf
		EndIf
	
	//-- Finaliza Controle Transacional (TTS)
	End Transaction

	//-- Atualiza Arq. Temporário
	TmMapExcQr(cAliasMbw)	

Return ( lRet )
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAF75Pad
@autor		: Adalberto S.M 
@descricao	: Verifica se a Quebra passada como parametro eh ou nao padrao
@since		: Oct./2015
@using		: MRP Para EDI do SigaTMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSAF75Pad( cCODQBR )

	Local aRet			:= {}
	Local cQuery		:= ""
	Local cAliasQry	:= GetNextAlias()
		
	cQuery := " "
	cQuery += " SELECT		DISTINCT DDF.DDF_QBRGEN, "
	cQuery += " 				DDF.DDF_DESQBR, "
	cQuery += " 				DDF.DDF_ATIVO "
	cQuery += " FROM 			" + RetSqlName("DDF") + " DDF "
	cQuery += " WHERE 		DDF.DDF_FILIAL  =  '" + xFilial("DDF") + "' "
	cQuery += " AND 			DDF.DDF_CODQBR  =  '" + cCODQBR + "' "
	cQuery += " AND			(DDF.DDF_QBRNV1 =  'S' OR DDF_QBRNV2 = 'S' ) "
	cQuery += " AND 			DDF.D_E_L_E_T_  =  ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAliasQry, .F., .T.)
	
	If (cAliasQry)->( !Eof() )

		Aadd( aRet, (cAliasQry)->DDF_DESQBR)
		Aadd( aRet, IIf((cAliasQry)->DDF_QBRGEN == 'S', .T., .F.) )
		Aadd( aRet, IIf((cAliasQry)->DDF_ATIVO  == 'S', .T., .F.) )

	EndIf
	
	(cAliasQry)->( DbCloseArea() )

Return( aRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSAF75Atv
@autor		: Eduardo Alberti
@descricao	: Pesquisa Se Cadastro Pode Ser Desativado Conforme Amarração Cliente X Layout.
@since		: Nov./2015
@using		: MRP Para EDI do SigaTMS.
@review	: 
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSAF75Atv( cCODQBR, lMark, nOpcx )

	Local aArea		:= GetArea()
	Local cQuery		:= ""
	Local cAlsQry		:= GetNextAlias()
	Local cClientes	:= ""
			
	//-- Desmarcou
	If !lMark .And. nOpcx == 4
		
		//-- Pesquisa Clientes Utilizando o Cadastro
		cQuery	:= " "
		cQuery	+= " SELECT		DEC_CODCLI, DEC_LOJCLI "
		cQuery	+= " FROM 			" + RetSqlName("DEC") + " DEC "
		cQuery	+= " WHERE 		DEC.DEC_FILIAL =  '" + xFilial("DEC") + "' "
		cQuery	+= " AND 			DEC.DEC_CODQBR = '" + cCODQBR + "'"
		cQuery	+= " AND 			DEC.D_E_L_E_T_ = ' ' "
	
		cQuery 	:= ChangeQuery(cQuery)
	
		dbUseArea( .T., "TOPCONN", TCGENQRY(, ,cQuery), cAlsQry, .F., .T.)
		
		If (cAlsQry)->( !Eof() )
				
			//-- Determina Clientes Utilizando o Cadastro
			DbSelectArea(cAlsQry)
			(cAlsQry)->( DbGoTop() )
			While (cAlsQry)->( !Eof() )
					
				cClientes := Iif( !Empty(cClientes),",","") + (cAlsQry)->DEC_CODCLI + "-" + (cAlsQry)->DEC_LOJCLI
						
				(cAlsQry)->( DbSkip() )
			EndDo
					
			If !Empty(cClientes)
				lMark := .T.
				Help("",1,"TMSAF7506",/*Titulo*/, STR0034 + cClientes /*Mensagem*/,1,0) //-- "Este Código De Quebra Está Em Uso No Cadastro 'Clientes X Layout' - TMSAE25. Cliente(s): "
			EndIf
		EndIf
		
		//-- Fecha Arquivo Temporário
		If Select(cAlsQry) > 0
			(cAlsQry)->( DbCloseArea() )
		EndIf
	EndIf

	RestArea(aArea)

Return( lMark )

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDFQbr
FWMarkBrowse Para Seleção Dos Códigos De Quebra De Agendamento Da Tabela DDF
@author Eduardo Alberti
@since 28/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function TmsDDFQbr()

	Local aArea      := GetArea()
	Local aAlias     := {}
	Local oDlgMrk    := Nil
	Local aColumns   := {}
	Local cTrbMark   := {}
	Local aRotOld	   := Iif(Type("aRotina") <> "U",aClone(aRotina),{})
	Local lRet		   := .T.
	Local cMarca     := ""

	aRotina := MenuDef("M")

	If lRet

		//----------------------------------------------------------
		//--Retorna as colunas para o preenchimento da FWMarkBrowse
		//----------------------------------------------------------
		aAlias		:= TmDDFExcQr()
		cAliasMrk	:= aAlias[1]
		aColumns 	:= aAlias[2]

		If !(cAliasMrk)->(Eof())

			//------------------------------------------
			//--Criação da FWMarkBrowse
			//------------------------------------------
			oMrkBrowse:= FWMarkBrowse():New()
			oMrkBrowse:SetFieldMark("DDF_OK")
			oMrkBrowse:SetOwner(oDlgMrk)
			oMrkBrowse:SetAlias(cAliasMrk)
			oMrkBrowse:SetIniWindow({|| TmsDDFCt(oMrkBrowse,cAliasMrk) }) //-- Carrega Os Dados Marcados Anteriormente
			oMrkBrowse:bMark    := {|| TmsDDFMk(cAliasMrk )} //-- Executa Durante a Marcação
			oMrkBrowse:SetDescription( STR0022 ) //-- "Selecione O Código De Quebra"
			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:DisableReport()
			oMrkBrowse:DisableConfig()
			oMrkBrowse:DisableSaveConfig()
			oMrkBrowse:Activate()

		Else
			Help(" ",1,"RECNO")
		EndIf

		If !Empty(cAliasMrk)
			dbSelectArea(cAliasMrk)
			dbCloseArea()
			Ferase(cAliasMrk+GetDBExtension())
			Ferase(cAliasMrk+OrdBagExt())
			cAliasMrk := ""
		EndIf
	Endif

	RestArea(aArea)

	If Len(aRotOld) > 0
		aRotina := aClone(aRotOld)
	EndIf

Return(.t.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDFRet
Rotina Acionada Pelo Botao "Confirmar" Do FWMarkBrowse
@author Totvs
@since 28/10/2013
@version P12
/*/
//-------------------------------------------------------------------
Function TmsDDFRet()

	Local aArea       := GetArea()
	Local cValor      := ""

	DbSelectArea(cAliasMrk)
	(cAliasMrk)->(DbGoTop())

	While !(cAliasMrk)->(Eof())

		If !Empty((cAliasMrk)->DDF_OK)
			cValor += Iif(Empty(cValor),"",",") + (cAliasMrk)->DDF_CODQBR
		EndIf

		DbSelectArea(cAliasMrk)
		(cAliasMrk)->(DbSkip())
	EndDo

	oMrkBrowse:GetOwner():End()

	//-- Carrega Variavel De Memória
	M->DEC_CODQBR := PadR(cValor,TamSX3("DEC_CODQBR")[1])

	RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc}TmDDFExcQr
Executa Query Pesquisando Codigos De Quebra Da Tabela DDF
@author Eduardo Alberti
@since  28/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function TmDDFExcQr()

	Local aArea      := GetArea()
	Local aStru      := {}
	Local aColumns   := {}	//Array com as colunas a serem apresentadas
	Local aRestrict  := {}
	Local nX         := 0
	Local cArqTrab   := ""
	Local cQuery	 := ""
	Local cRealName	 := ""
	Local lRet		 := .T. 
	Local oTemp		 := Nil
	
	cQuery += " SELECT      '' , DDF.DDF_CODQBR, DDF.DDF_DESQBR, Max(DDF.R_E_C_N_O_) AS RECDDF "
	cQuery += " FROM        " +	RetSqlName("DDF") + " DDF "
	cQuery += " WHERE       DDF.DDF_FILIAL  = '" + xFilial("DDF") + "' "
	cQuery += " AND         DDF.DDF_ATIVO   = 'S' "
	cQuery += " AND         DDF.D_E_L_E_T_  = ' ' "
	cQuery += " GROUP BY    DDF.DDF_CODQBR, DDF.DDF_DESQBR "
	cQuery += " ORDER BY    DDF.DDF_CODQBR "
	
	cQuery := ChangeQuery(cQuery)

	cChave		:= "DDF_CODQBR"

	Aadd(aStru, {"DDF_OK"    ,"C",2                      	,0}) //-- Campo Para Marcação
	Aadd(aStru, {"DDF_CODQBR","C",TamSX3("DDF_CODQBR")[1]	,0})
	Aadd(aStru, {"DDF_DESQBR","C",TamSX3("DDF_DESQBR")[1]	,0})
	Aadd(aStru, {"RECDDF"    ,"N",8								,0})

	cArqTrab	:= GetNextAlias()
		
	oTemp	:= FwTemporaryTable():New(cArqTrab)
	oTemp:SetFields( aStru )
	oTemp:AddIndex("01", {"DDF_CODQBR" } )
	oTemp:Create()
	
	cRealName	:= oTemp:GetRealName()
	
	Processa( {|| lRet := TMSSqlToTemp(cQuery, aStru, cRealName , .T.  ) } )	// Cria arquivo temporario
	
	If !lRet
		oTemp:Delete()
		aColumns	:= {} 
		cArqTrab	:= ""
	Else
		//-- Posiciona no primeiro registro
		(cArqTrab)->(dbGoTop()) 
		
		//--Define as colunas a serem apresentadas na FWMarkBrowse
		For nX := 1 To Len(aStru)
			If	aStru[nX][1] $ "DDF_CODQBR|DDF_DESQBR"
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
				aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
				aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
				aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
				aColumns[Len(aColumns)]:SetPicture(PesqPict("DDF",aStru[nX][1]))
			EndIf
		Next nX		
		
	EndIf		
		
	RestArea(aArea)

Return({cArqTrab,aColumns})

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDFMk
Executado Na Marcacao De Um Registro
@author Totvs
@since 28/10/2013
@version P12
/*/
//-------------------------------------------------------------------
Static Function TmsDDFMk(cAliasTRB)

	Local lRet		:= .T.
	Local nReg		:= (cAliasTRB)->(Recno())
	Local cMarca	:= oMrkBrowse:cMark

	DbSelectArea(cAliasTRB)
	DbGoTop()

	While !(cAliasTRB)->(Eof())

		If	(cAliasTRB)->DDF_OK == cMarca .And. (cAliasTRB)->(Recno()) <> nReg
			(cAliasTRB)->(MsRLock())
			(cAliasTRB)->DDF_OK := "  "
			(cAliasTRB)->(MsUnlock())
		Endif

		(cAliasTRB)->(dbSkip())
	Enddo
	
	(cAliasTRB)->(dbGoto(nReg))

	oMrkBrowse:oBrowse:Refresh(.t.)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsDDFCt
@autor		: Eduardo Alberti
@descricao	: Marca No FWMarkBrowse Os Campos Informados Anteriormente
@since		: Oct./2015
@using		: Captura Valores Do Campo DDF_CODQBR e Traz Marcado Na FWMarkBrowse
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsDDFCt(oMrkBrowse,cAliasMrk)

	Local aArea    := GetArea()
	Local cContOld := M->DEC_CODQBR
	Local cMarca	 := oMrkBrowse:cMark
	Local nReg		 := (cAliasMrk)->(Recno())

	//--Atualiza FWMarkBrowse Com Dados Já Informados No Campo
	If !Empty(cContOld)

		DbSelectArea(cAliasMrk)
		(cAliasMrk)->(DbGoTop())

		While !(cAliasMrk)->(Eof())

			If Alltrim((cAliasMrk)->DDF_CODQBR) $ cContOld
				RecLock(cAliasMrk,.f.)
				(cAliasMrk)->DDF_OK := cMarca
				(cAliasMrk)->(MsUnlock())
			EndIf

			DbSelectArea(cAliasMrk)
			(cAliasMrk)->(DbSkip())
		EndDo

		(cAliasMrk)->(dbGoto(nReg))

		RestArea(aArea)

		oMrkBrowse:oBrowse:Refresh(.t.)

	EndIf

Return(.t.)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsDDFVl
@autor		: Eduardo Alberti
@descricao	: Validação Do Código De Quebra Informado No Campo DEC_CODQBR
@since		: Oct./2015
@using		: MRP Para EDI do SigaTMS.
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsDDFVL()

	Local aArea	:= GetArea()
	Local lRet		:= .t.
	Local cCod		:= &(ReadVar())
	
	DbSelectArea("DDF")
	DbSetOrder(1) //-- DDF_FILIAL+DDF_CODQBR+DDF_CPOSX3
	MsSeek(xFilial("DDF") + cCod ,.f.)
	
	While DDF->(!Eof()) .And. DDF->DDF_CODQBR == cCod
	
		If DDF->DDF_QBRNV1 == 'S' .Or. DDF->QBRNV2 == 'S'
			lRet := (DDF->DDF_ATIVO == 'S')

			//-- Retorna Help Caso Código Não Esteja Ativo
			If !lRet
				Help("",1,"TMSAF7508",/*Titulo*/, /*Mensagem*/,1,0) //-- "O Código De Quebra Informado Não Está Ativo! Selecione Um Código De Quebra Ativo. "
			EndIf

			Exit

		EndIf
	
		DDF->(DbSkip())
	EndDo

	RestArea(aArea)

Return(lRet)
