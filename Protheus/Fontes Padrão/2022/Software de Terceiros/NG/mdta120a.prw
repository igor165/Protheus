#Include "MDTA120.ch"
#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA120A
Permite visualizar, incluir, alterar, excluir exames do
funcionario selecionado.

@author Inacio Luiz Kolling
@since 22/01/2000
@return .T.
/*/
//---------------------------------------------------------------------
Function MDTA120A(lMDTA110)

	Local aNGBEGINPRM	:= If(!IsInCallStack("MDTA120"),NGBEGINPRM(,"MDTA120",/*aChkAlias*/,.f.),{})
	Local cAcSalvo		:= acbrowse
	Local oldROTINA := aCLONE(aROTINA)
	Local cFunCall    := FunName()

	Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
	Private asMenu
	Private lSuperUsr := .F.
	Private aIndSTP := {}, bFiltraBrw := {|| Nil}
	//+--------------------------------------------------------------+
	//| Define Array contendo as Rotinas a executar do programa      |
	//| ----------- Elementos contidos por dimensao ------------     |
	//| 1. Nome a aparecer no cabecalho                              |
	//| 2. Nome da Rotina associada                                  |
	//| 3. Usado pela rotina                                         |
	//| 4. Tipo de Transa‡„o a ser efetuada                          |
	//|    1 - Pesquisa e Posiciona em um Banco de Dados             |
	//|    2 - Simplesmente Mostra os Campos                         |
	//|    3 - Inclui registros no Bancos de Dados                   |
	//|    4 - Altera o registro corrente                            |
	//|    5 - Remove o registro corrente do Banco de Dados          |
	//+--------------------------------------------------------------+
	Private aRotina := MenuDef( )
	Private LENUMFIC := .F.

	Default lMDTA110 := .F.

	If !(IsInCallStack( "MDTA110" ) .Or. IsInCallStack( "MDTA120" )) .And. !IsBlind()
		ShowHelpDlg( STR0108,;           //"ATENÇÃO"
		{ STR0235 }, 1,;     //"Execução não permitida."
		{ STR0236, "" }, 1 ) //"Rotina somente pode ser executada pelo menu de Ocorrências Ficha (MDTA110) ou Exames do Func. (MDTA120)."
		Return .F.
	EndIf

	acbrowse  := NgAcBrowse("MDTA120") //Altera configuracao de permissão aos botões do aRotina

	//Verificações de super usuario
	If ExistBlock("MDTA1201")
		lSuperUsr := ExecBlock("MDTA1201",.F.,.F.)
		If ValType( lSuperUsr ) <> "L"
			lSuperUsr := .F.
		EndIf
	EndIf

	If FindFunction("MDTRESTRI") .AND. !MDTRESTRI("MDTA120")
		Return .F.
	Endif

	dbSelectArea("SRA")
	dbSetOrder(01)
	dbSeek(xFilial("SRA",TM0->TM0_FILFUN)+TM0->TM0_MAT )
	If !Empty(SRA->RA_DEMISSA)
		If 	!MsgYesNo(STR0179)//"Este funcionário está demitido. Deseja realmente manipular seus exames ?"
			Return .F.
		Endif
	Endif

	aOldMenu := ACLONE(asMenu)
	asMenu := NGRIGHTCLICK("MDTA120")
	aAreaTM0 := TM0->(GetArea())

	If lMDTA110
		If !SitFunFicha(TM0->TM0_NUMFIC,.f.,.t.,.t.)
			RestArea(aAreaTM0)
			Return
		Endif
		If lSigaMdtPS
			cCliMdtps := TM0->(TM0_CLIENT+TM0_LOJA)
		Endif
	Endif

	dbSelectArea("TM0")
	dbSetOrder(1)
	If !dbSeek(xFilial("TM0"))
		RestArea(aAreaTM0)
		MsgStop(STR0046) //"Nao existe Ficha Medica Cadastrada."
		Return .T.
	Endif
	RestArea(aAreaTM0)

	SetFunName("MDTA120A")

	// Define o cabecalho da tela de atualizacoes
	dbSelectArea("TM0")
	dbSetOrder(1)

	cNUMFIC := TM0->TM0_NUMFIC

	cAlias := "TM5"

	cCondIsTp := 'TM0->TM0_NUMFIC = TM5->TM5_NUMFIC'
	cCondIsTp += ' .And. '
	ccondistp += '('
	ccondistp += 	'('
	ccondistp += 		'!Empty( TM0->TM0_MAT ) .And. ' 
	ccondistp +=		'('
	ccondistp += 			'('
	ccondistp += 				'!Empty( TM5->TM5_MAT ) .And. ' + "'" + xFilial( 'SRA' ) + "'" + " = TM5->TM5_FILFUN "
	ccondistp += 			')' 
	ccondistp += 			' .Or. '
	ccondistp += 			'(' 
	ccondistp += 				'Empty( TM5->TM5_MAT )  .And. ' + "'" + xFilial( 'TM5' ) + "'" + " = TM5->TM5_FILIAL "
	ccondistp += 			')' 
	ccondistp +=		')'
	ccondistp += 	')'
	ccondistp += 	' .Or. '
	ccondistp += 	'('
	cCondIsTp += 		'Empty( TM0->TM0_MAT ) .And. ' + "'" + xFilial( 'TM5' ) + "'" + ' = TM5->TM5_FILIAL'
	ccondistp += 	')'
	ccondistp += ')'

	bFiltraBrw := {|| FilBrowse("TM5",@aIndSTP,@cCondistp)}
	Eval(bFiltraBrw)

	nINDSTP := IndexOrd()

	mBrowse( 6, 1,22,75,"TM5",,,,,,fNG120Cor(),,,,,,,.F., )
	aEval(aIndSTP,{|x| Ferase(x[1]+OrdBagExt())})

	dbSelectArea("TM5")
	Set Filter To

	acbrowse := cAcSalvo
	aRotina := aCLONE(oldROTINA)
	RestArea(aAreaTM0)

	//Retorna conteudo de variaveis padroes
	NGRETURNPRM(aNGBEGINPRM)

	SetFunName(cFunCall)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional
@type static function
@author Rafael Diogo Richter
@since 11/01/2007
@return array, opções do menu com o seguinte layout:
				Parametros do array a Rotina:
				1. Nome a aparecer no cabecalho
				2. Nome da Rotina associada
				3. Reservado
				4. Tipo de Transação a ser efetuada:
					1 - Pesquisa e Posiciona em um Banco de Dados
					2 - Simplesmente Mostra os Campos
					3 - Inclui registros no Bancos de Dados
					4 - Altera o registro corrente
					5 - Remove o registro corrente do Banco de Dados
				5. Nivel de acesso
				6. Habilita Menu Funcional

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina
	Local lSigaMdtPs := SuperGetMv("MV_MDTPS", .F., "N") == "S"
	Local lPyme      := Iif(Type("__lPyme") <> "U",__lPyme,.F.)

	aRotina :=  { { STR0004 ,"PesqBrw"	, 0, 1	}		,;	//"Pesquisar"
	{ STR0005 ,"VIEXA120"	, 0, 2	}		,;	//"Visualizar"
	{ STR0008 ,"INEXA120"	, 0, 3	}		,;	//"Incluir"
	{ STR0009 ,"ALEXA120"	, 0, 4	}		,;	//"Alterar"
	{ STR0010 ,"EXEXA120"	, 0, 5, 3	}	,;	//"Excluir"
	{ STR0011 ,"REXAME120"	, 0, 2	}		,;	//"Resultado"
	{ STR0100 ,"MDT120Leg"	, 0 , 6	} }			//"Legenda"

	If !lPyme
		aAdd( aRotina, { STR0069, "MsDocument", 0, 4 } )  //"Conhecimento"
	EndIf

	If !lSigaMdtPs .AND. SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd( aRotina , {  STR0189,"MDTA991('TM5',{'TM5_NUMFIC','TM5_USERGI'},{'"+TM0->TM0_NUMFIC+"',STOD('"+DTOS(TM0->TM0_DTIMPL)+"')})" , 0 , 3 } )//"Hist. Exc."
	EndIf

Return aRotina
