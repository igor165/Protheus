#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TafxSpdK

Realiza a Geracao do Bloco K do Sped Fiscal

@param	aWizard		->	Wizard de geracao do Arquivo
		cFilSel		->	Variavel com as Filiais escolhidas pelo Usuario


@author Vitor Ferreira
@since 03/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafxSpdK( aWizard, cFilSel, lConv115, cPerfilSPD, cTabSped, cJobAux )
	Local  cTxtSys	 	:= CriaTrab(,.F.)+".TXT"
	Local  cFilBkp	 	:=	cFilAnt	//Backup da filial antes do inicio do processamento
	Local  nI		 		:=	0
	Local  nlI       		:= 0
	Local  nTotReg   		:= 1
	Local  lSave	 		:= .F.
Local  lLayout12  := Iif(aWizard[1][5] >= "012",.T.,.F.)
Local  aCmps	 :=	DistrCmps(lLayout12)                    
	Local  aFilSel   		:= Separa( StrTran( cFilSel, "'", "" ), "," )

	Local  cStrTxt	 	:=	''
	Local  aMacro   		:= {}

	Local  dDataIni  		:= aWizard[1][1]
	Local  dDataFim  		:= aWizard[1][2]
	Local  lGerK001  		:= .F.

	Local lFound 			:= .T.
	Local oError 			:= ErrorBlock( { |Obj| Conout( "Mensagem de Erro: " + Chr(10)+ Obj:Description + Chr(10)+ Obj:ErrorStack ) } )
	Local lGeraBlK		As Logical		// Variavel utilizada para verificar se o usuario optou por gerar o bloco K (.T.) ou nao gerar (.F.)
	Local lGeraTudo		As Logical		// Variavel utilizada para verificar se apenas os registros obrigatorios serão gerados (.F.) ou todos os registros (.T.)

	Private aTotRegK  	:= {}
	Private aInfoGrv  	:= {}

	/*-----------------------------------------------------------------------------
	Deve ser private para geracao dos registros do bloco 0 gerados durante o
	processamento dos movimentos
	-----------------------------------------------------------------------------*/
	Private aWizardBc  := aWizard
	Private cFilSelBc  := cFilSel
	Private cTabSpd    := cTabSped

	Default cJobAux := ""

	lGeraBlK		:= SubStr(AllTrim(aWizard[7][1]),1,1) <> '1'
	lGeraTudo		:= SubStr(AllTrim(aWizard[7][1]),1,1) == '0'

	/*-----------------------------------------------------------------------------
	Tratamento para que caso ocorra Erro durante o processamento não estoure na tela
	é exibida uma mensagem tratada do erro para o usuário final
	-----------------------------------------------------------------------------*/
	Begin Sequence

	/*-----------------------------------------------------------------------------
	Array com as informações a serem geradas na tabela compartilhada
	Filial + Data Inicio + Data Final + Bloco + Sequencializador
	-----------------------------------------------------------------------------*/
		aInfoGrv := { cFilAnt , DToS( aWizardBc[1,1] ), DToS( aWizardBc[1,2] ), "K", 0 }

		/*-----------------------------------------------------------------------------
		Verifica se já pode ser gerado o bloco K
		-----------------------------------------------------------------------------*/
		If TAFAlsInDic( "LER" ) .And. aWizard[1][5] >= "010" .And. lGeraBlK
			BlocoK( dDataIni , dDataFim , aCmps, @lGerK001, aWizard, cFilSel, cTabSped, lGeraTudo  )
		EndIf

		/*-----------------------------------------------------------------------------
		Caso nao tenha sido gerado o registro K001 ( Pois nao Houve Movimento )
		realizao a sua emissao agora
		-----------------------------------------------------------------------------*/
		If aWizard[1][5] >= "010"

			If !lGerK001
				aMacro	:=	{}
				aAdd( aMacro , "1" )

				cStrTxt := ""
				LoadString( 'K001' , aCmps , @cStrTxt, , , aMacro )

				aInfoGrv[5]++
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv )

				/*-----------------------------------------------------------------------------
				Conta os registros para totalizar no bloco 9
				-----------------------------------------------------------------------------*/
				TaFContBlc("K001",aTotRegK)
			Endif

			For nlI := 1 To Len( aTotRegK )
				nTotReg += aTotRegK[nlI][2]
			Next

			aMacro	:=	{}
			aAdd( aMacro , nTotReg )

			Reg990Spd( "K", cTabSped, cFilSel, aWizard )
		EndIf

		/*-----------------------------------------------------------------------------
		Restauro a Filial salva no inicio do processamento
		-----------------------------------------------------------------------------*/
		cFilAnt	:=	cFilBkp
	Recover
		lFound := .F.
	End Sequence

	/*-----------------------------------------------------------------------------
	Tratamento para quando ocorrer erros durante o processamento
	-----------------------------------------------------------------------------*/
	ErrorBlock( oError )

	If !lFound
		/*-----------------------------------------------------------------------------
		Status 9 - Indico Que ocorreu Erro no processamento
		-----------------------------------------------------------------------------*/
		PutGlbValue( cJobAux , "9" )
		GlbUnlock()

	Else
		/*-----------------------------------------------------------------------------
		Status 1 -
		Indico que o bloco foi encerrado corretamente para processamento Mult Thread
		-----------------------------------------------------------------------------*/
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

		/*-----------------------------------------------------------------------------
		Altera o Status da tabela de controle para 2, indicando que o bloco foi
		processado
		-----------------------------------------------------------------------------*/
		xTafCtlObr( "2", "K", aWizardBc, cFilSelBc, , "TAFGERCTL", "SPEDFIS" )
	EndIf
Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} BlocoK

Monta a Estrutura de Geracao dos Registros referentes ao Bloco K

@param	dDataIni	-> 	Data inicial do periodo
		dDataFim	->	Data final do periodo
		aCmps		->	Array de depara de campos das tabelas do TAF para a estrutura do EFD
		lGerK001    ->  Informa se ja foi gerado o Registro K001

@return NIL

@author Vitor Ferreira
@since 03/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BlocoK( dDataIni , dDataFim , aCmps, lGerK001, aWizard, cFilSel, cTabSped, lGeraTudo )
	Local 	cAliasQry 	 		:=  GetNextAlias()
	Local	cStrTxt	     	:=	''
	Local	nRWStrTxt	 		:=	0
	Local	cQuery				:=	''
	Local	aMacro				:=	{}
	Local	aSelect			:=	Array( 08 )
	Local	aJoin		 		:=	Array( 08 )
	Local	aWhere		 		:=	Array( 08 )
	Local	cOrderBy    		:= ""
	Local   cChaveAntK100 	:= ""
	Local 	cChave				:= "."


	/*-----------------------------------------------------------------------------
	SELECT PARA COMPOR OS REGISTROS K100 E K200
	-----------------------------------------------------------------------------*/
	/*T18 - K100*/	aSelect[1] := " DISTINCT T18.T18_FILIAL, T18.T18_ID T18_ID, T18.T18_DTINI  , T18.T18_DTFIN              , 'K200' REG,"
	/*T19 - K200*/	aSelect[1] += " T19.T19_FILIAL FILIAL  , T19.T19_ID ID    , T19.T19_DTEST  , C1L.C1L_CODIGO T19_CODITE  , T19.T19_QTDEST , T19.T19_INDEST  , C1H.C1H_CODPAR T19_CODPAR,"
/*T20 - K220*/	aSelect[1] += " Null T20_DTMOV         , ' ' T20_CODITO   , ' ' T20_CODITD , 0 T20_QTDMOV               , 0 T20_QTDMDE   ,     
	/*T21 - K230*/	aSelect[1] += " Null T21_DTINIO		   , Null T21_DTFINO  , ' ' T21_CODOP  , ' ' T21_CODITE             , 0 T21_QTDPRO   ,"
	/*T22 - K235*/	aSelect[1] += " ' '  T22_CODOP         , Null T22_DTSAID  , ' ' T22_CODINS , 0 T22_QTDCON               , ' ' T22_INSSUB ,"
	/*T23 - K250*/	aSelect[1] += " Null T23_DTPROD        , ' ' T23_CODITE   , 0 T23_QTDPRO   ,"
	/*T24 - K255*/	aSelect[1] += " Null T24_DTPROD        , ' ' T24_CODITE   , Null T24_DTCONS, ' ' T24_ITECON				, 0 T24_QTDINS   , ' ' T24_INSSUB,"
	/*LER - K210*/	aSelect[1] += " Null LER_DTINIO        , Null LER_DTFINO  , ' ' LER_CODOS  , ' ' LER_CODITE   			, 0 LER_QTDORI,"
	/*LES - K215*/	aSelect[1] += " ' ' LES_CODITD         , 0 LES_QTDDES,"
	/*LET - K260*/	aSelect[1] += " ' ' LET_CODOSP         , ' ' LET_CODITE   , Null LET_DTSAID, 0 LET_QTDSAI			    , Null LET_DTRETO, 0 LET_QTDRET,"
	/*LEU - K265*/	aSelect[1] += " ' ' LEU_CODMER         , 0 LEU_QTDCON	  , 0 LEU_QTDRET,"
	/*LEV - K270*/	aSelect[1] += " Null LEV_DTINIA        , Null LEV_DTFINA  , ' ' LEV_CODOSP , ' ' LEV_CODITE			    , 0 LEV_QTDCPO   , 0 LEV_QTDCNE, ' ' LEV_ORIGEM,"
	/*LEX - K275*/	aSelect[1] += " ' ' LEX_CODMER         , 0 LEX_QTDCPO	  , 0 LEX_QTDCNE   , ' ' LEX_CODINS,"
	/*LEY - K280*/	aSelect[1] += " Null LEY_DTEST         , ' ' LEY_CODITE	  , 0 LEY_QTDCPO   , 0 LEY_QTDCNE  , 			' ' LEY_INDEST	 , ' ' LEY_CODPAR"

	aJoin[1]   := RetSqlName("T18") + " T18 "
  	aJoin[1]   += " LEFT JOIN " + RetSqlName("T19") + " T19  ON ( T19.T19_FILIAL = '" + xFilial("T19") + "'  AND T19.T19_ID = T18.T18_ID   AND T19.D_E_L_E_T_ = ' ' ) "
	aJoin[1]   += " LEFT JOIN " + RetSqlName("C1L") + " C1L  ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "T19.T19_FILIAL" ) + " AND T19.T19_CODITE = C1L.C1L_ID   	 		 AND C1L.D_E_L_E_T_ = ' ' ) "
	aJoin[1]   += " LEFT JOIN " + RetSqlName("C1H") + " C1H  ON ( C1H.C1H_FILIAL = " + Iif( FWModeAccess( "C1H" , 3 ) == "C" , "'" + xFilial( "C1H" ) + "'" , "T19.T19_FILIAL" ) + " AND T19.T19_CODPAR = C1H.C1H_ID   	 		 AND C1H.D_E_L_E_T_ = ' ' ) "

	aWhere[1]  := "  T18.T18_FILIAL = '"     + xFilial("T18") + "' "
	aWhere[1]  += "  AND T18.T18_DTINI >= '" + DTOS(dDataIni) + "' AND T18.T18_DTFIN <='" + DTOS(dDataFim) + "' AND T18.D_E_L_E_T_ = ' '"


	/*-----------------------------------------------------------------------------
	SELECT PARA COMPOR OS REGISTROS K100 E K220
	-----------------------------------------------------------------------------*/

	/*T18 - K100*/	aSelect[2] := " DISTINCT T18.T18_FILIAL, T18.T18_ID T18_ID        , T18.T18_DTINI             , T18.T18_DTFIN  , 'K220' REG,"
	/*T19 - K200*/	aSelect[2] += " T20.T20_FILIAL FILIAL  , T20.T20_ID ID            , Null T19_DTEST            , ' ' T19_CODITE , 0 T19_QTDEST  , ' ' T19_INDEST, ' ' T19_CODPAR,"
/*T20 - K220*/	aSelect[2] += " T20.T20_DTMOV          , C1L.C1L_CODIGO T20_CODITO, C1L2.C1L_CODIGO T20_CODITD, T20.T20_QTDMOV , "+iif(TAFColumnPos("T20_QTDMDE"), "T20.T20_QTDMDE", "0 T20_QTDMDE")+" , " 
	/*T21 - K230*/	aSelect[2] += " Null T21_DTINIO        , Null T21_DTFINO          , ' ' T21_CODOP             , ' ' T21_CODITE , 0 T21_QTDPRO  ,"
	/*T22 - K235*/	aSelect[2] += " ' ' T22_CODOP          , Null T22_DTSAID          , ' ' T22_CODINS            , 0 T22_QTDCON   , ' ' T22_INSSUB,"
	/*T23 - K250*/	aSelect[2] += " Null T23_DTPROD        , ' ' T23_CODITE           , 0 T23_QTDPRO              ,"
	/*T24 - K255*/	aSelect[2] += " Null T24_DTPROD        , ' ' T24_CODITE           , Null T24_DTCONS           , ' ' T24_ITECON , 0 T24_QTDINS  , ' ' T24_INSSUB,"
	/*LER - K210*/	aSelect[2] += " Null LER_DTINIO        , Null LER_DTFINO          , ' ' LER_CODOS	          , ' ' LER_CODITE   			   , 0 LER_QTDORI,"
	/*LES - K215*/	aSelect[2] += " ' ' LES_CODITD         , 0 LES_QTDDES,"
	/*LET - K260*/	aSelect[2] += " ' ' LET_CODOSP         , ' ' LET_CODITE   		  , Null LET_DTSAID, 0 LET_QTDSAI			   , Null LET_DTRETO, 0 LET_QTDRET,"
	/*LEU - K265*/	aSelect[2] += " ' ' LEU_CODMER         , 0 LEU_QTDCON	 		  , 0 LEU_QTDRET,"
	/*LEV - K270*/	aSelect[2] += " Null LEV_DTINIA        , Null LEV_DTFINA  		  , ' ' LEV_CODOSP , ' ' LEV_CODITE			   , 0 LEV_QTDCPO   , 0 LEV_QTDCNE, ' ' LEV_ORIGEM,"
	/*LEX - K275*/	aSelect[2] += " ' ' LEX_CODMER         , 0 LEX_QTDCPO	  		  , 0 LEX_QTDCNE   , ' ' LEX_CODINS,"
	/*LEY - K280*/	aSelect[2] += " Null LEY_DTEST         , ' ' LEY_CODITE	 		  , 0 LEY_QTDCPO   , 0 LEY_QTDCNE  			   , ' ' LEY_INDEST	, ' ' LEY_CODPAR"

	aJoin[2] := RetSqlName("T18") + " T18 "
  	aJoin[2] += " LEFT JOIN " + RetSqlName("T20") +  " T20   ON  ( T20.T20_FILIAL = '" + xFilial("T20")  + "'  AND T20.T20_ID = T18.T18_ID   AND T20.D_E_L_E_T_ = ' ' ) "
	aJoin[2] += " LEFT JOIN " + RetSqlName("C1L") +  " C1L   ON  ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "T20.T20_FILIAL" ) + " AND T20.T20_CODITO =      C1L.C1L_ID            AND C1L.D_E_L_E_T_ = ' ' ) "
	aJoin[2] += " LEFT JOIN " + RetSqlName("C1L2") + " C1L2  ON  ( C1L2.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "T20.T20_FILIAL" ) + " AND T20.T20_CODITD =      C1L2.C1L_ID           AND C1L2.D_E_L_E_T_ = ' ' ) "

	aWhere[2] := "  T18.T18_FILIAL = '"     + xFilial("T18") + "' "
	aWhere[2] += "  AND T18.T18_DTINI >= '" + DTOS(dDataIni) + "' AND T18.T18_DTFIN <='" + DTOS(dDataFim) + "' AND T20.D_E_L_E_T_ = ' ' AND T20.T20_ID IS NOT NULL "


	/*-----------------------------------------------------------------------------
	SELECT PARA COMPOR OS REGISTROS K100 E K230/K235
	-----------------------------------------------------------------------------*/
	/*T18 - K100*/	aSelect[3] := " DISTINCT T18.T18_FILIAL, T18.T18_ID T18_ID, T18.T18_DTINI  			  , T18.T18_DTFIN 			    , 'K230' REG,
	/*T19 - K200*/	aSelect[3] += " T21.T21_FILIAL FILIAL  , T21.T21_ID ID    , Null T19_DTEST 			  , ' ' T19_CODITE			    , 0 T19_QTDEST  , ' ' T19_INDEST, ' ' T19_CODPAR,"
/*T20 - K220*/	aSelect[3] += " Null T20_DTMOV         , ' ' T20_CODITO   , ' ' T20_CODITD 			  , 0 T20_QTDMOV                , 0 T20_QTDMDE               ,"
	/*T21 - K230*/	aSelect[3] += " T21.T21_DTINIO         , T21.T21_DTFINO   , T21.T21_CODOP             , C1L.C1L_CODIGO T21_CODITE   , T21.T21_QTDPRO,"
	/*T22 - K235*/	aSelect[3] += " T22.T22_CODOP          , T22.T22_DTSAID   , C1L2.C1L_CODIGO T22_CODINS, T22.T22_QTDCON			    , C1L3.C1L_CODIGO T22_INSSUB,"
	/*T23 - K250*/  	aSelect[3] += " Null T23_DTPROD        , ' ' T23_CODITE   , 0 T23_QTDPRO              ,"
	/*T24 - K255*/	aSelect[3] += " Null T24_DTPROD        , ' ' T24_CODITE   , Null T24_DTCONS           , ' ' T24_ITECON, 0 T24_QTDINS, ' ' T24_INSSUB,"
	/*LER - K210*/	aSelect[3] += " Null LER_DTINIO        , Null LER_DTFINO  , ' ' LER_CODOS	          , ' ' LER_CODITE   			, 0 LER_QTDORI,"
	/*LES - K215*/	aSelect[3] += " ' ' LES_CODITD         , 0 LES_QTDDES,"
	/*LET - K260*/	aSelect[3] += " ' ' LET_CODOSP         , ' ' LET_CODITE   , Null LET_DTSAID			  , 0 LET_QTDSAI			    , Null LET_DTRETO, 0 LET_QTDRET,"
	/*LEU - K265*/	aSelect[3] += " ' ' LEU_CODMER         , 0 LEU_QTDCON	  , 0 LEU_QTDRET,"
	/*LEV - K270*/	aSelect[3] += " Null LEV_DTINIA        , Null LEV_DTFINA  , ' ' LEV_CODOSP 			  , ' ' LEV_CODITE			    , 0 LEV_QTDCPO   , 0 LEV_QTDCNE, ' ' LEV_ORIGEM,"
	/*LEX - K275*/	aSelect[3] += " ' ' LEX_CODMER         , 0 LEX_QTDCPO	  , 0 LEX_QTDCNE   			  , ' ' LEX_CODINS,"
	/*LEY - K280*/	aSelect[3] += " Null LEY_DTEST         , ' ' LEY_CODITE	  , 0 LEY_QTDCPO   			  , 0 LEY_QTDCNE  			    , ' ' LEY_INDEST , ' ' LEY_CODPAR"

	aJoin[3] := RetSqlName("T18") + " T18 "
  	aJoin[3] += " LEFT JOIN " + RetSqlName("T21") +  " T21   ON ( T21.T21_FILIAL = '" + xFilial("T21") + "'  AND T21.T21_ID  = T18.T18_ID  AND T21.D_E_L_E_T_ = ' ' )"
	aJoin[3] += " LEFT JOIN " + RetSqlName("T22") +  " T22   ON ( T22.T22_FILIAL = '" + xFilial("T22") + "'  AND T22.T22_ID  = T21.T21_ID  AND T22_CODOP = T21_CODOP AND T22_CODITE  = T21_CODITE  AND T22.D_E_L_E_T_ = ' ' )"
	aJoin[3] += " LEFT JOIN " + RetSqlName("C1L") +  " C1L   ON ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "T21.T21_FILIAL" ) + " AND T21.T21_CODITE = C1L.C1L_ID      AND C1L.D_E_L_E_T_ = ' ' ) "
	aJoin[3] += " LEFT JOIN " + RetSqlName("C1L2") + " C1L2  ON ( C1L2.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "T22.T22_FILIAL" ) + " AND T22.T22_CODINS = C1L2.C1L_ID     AND C1L2.D_E_L_E_T_ = ' ' ) "
	aJoin[3] += " LEFT JOIN " + RetSqlName("C1L3") + " C1L3  ON ( C1L3.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "T22.T22_FILIAL" ) + " AND T22.T22_INSSUB = C1L3.C1L_ID     AND C1L3.D_E_L_E_T_ = ' ' ) "

	aWhere[3] := "  T18.T18_FILIAL = '"     + xFilial("T18") + "' "
	aWhere[3] += "  AND T18.T18_DTINI >= '" + DTOS(dDataIni) + "' AND T18.T18_DTFIN <='" + DTOS(dDataFim) + "' AND T21.D_E_L_E_T_ = ' ' AND T21.T21_ID IS NOT NULL "

	/*-----------------------------------------------------------------------------
	SELECT PARA COMPOR OS REGISTROS K100 E K250/K255
	-----------------------------------------------------------------------------*/
	/*T18 - K100*/	aSelect[4] := " DISTINCT T18.T18_FILIAL, T18.T18_ID T18_ID		  , T18.T18_DTINI  , T18.T18_DTFIN 			   , 'K250' REG, "
	/*T19 - K200*/	aSelect[4] += " T23.T23_FILIAL FILIAL  , T23.T23_ID ID    		  , Null T19_DTEST , ' ' T19_CODITE			   , 0 T19_QTDEST  , ' ' T19_INDEST, ' ' T19_CODPAR,"
/*T20 - K220*/	aSelect[4] += " Null T20_DTMOV 		   , ' ' T20_CODITO  		  , ' ' T20_CODITD , 0 T20_QTDMOV              , 0 T20_QTDMDE  ,"
	/*T21 - K230*/	aSelect[4] += " Null T21_DTINIO		   , Null T21_DTFINO 		  , ' ' T21_CODOP  , ' ' T21_CODITE			   , 0 T21_QTDPRO  ,"
	/*T22 - K235*/	aSelect[4] += " ' ' T22_CODOP  		   , Null T22_DTSAID          , ' ' T22_CODINS , 0 T22_QTDCON   		   , ' ' T22_INSSUB,"
	/*T23 - K250*/ 	aSelect[4] += " T23.T23_DTPROD 		   , C1L.C1L_CODIGO T23_CODITE, T23.T23_QTDPRO ,"
	/*T24 - K255*/	aSelect[4] += " T24.T24_DTPROD 		   , T24.T24_CODITE			  , T24.T24_DTCONS , C1L2.C1L_CODIGO T24_ITECON, T24.T24_QTDINS, C1L3.C1L_CODIGO T24_INSSUB,"
	/*LER - K210*/	aSelect[4] += " Null LER_DTINIO        , Null LER_DTFINO  		  , ' ' LER_CODOS  , ' ' LER_CODITE   		   , 0 LER_QTDORI,"
	/*LES - K215*/	aSelect[4] += " ' ' LES_CODITD         , 0 LES_QTDDES,"
	/*LET - K260*/	aSelect[4] += " ' ' LET_CODOSP         , ' ' LET_CODITE   		  , Null LET_DTSAID, 0 LET_QTDSAI			   , Null LET_DTRETO, 0 LET_QTDRET,"
	/*LEU - K265*/	aSelect[4] += " ' ' LEU_CODMER         , 0 LEU_QTDCON	  		  , 0 LEU_QTDRET,"
	/*LEV - K270*/	aSelect[4] += " Null LEV_DTINIA        , Null LEV_DTFINA  		  , ' ' LEV_CODOSP , ' ' LEV_CODITE			   , 0 LEV_QTDCPO   , 0 LEV_QTDCNE, ' ' LEV_ORIGEM,"
	/*LEX - K275*/	aSelect[4] += " ' ' LEX_CODMER         , 0 LEX_QTDCPO	  		  , 0 LEX_QTDCNE   , ' ' LEX_CODINS,"
	/*LEY - K280*/	aSelect[4] += " Null LEY_DTEST         , ' ' LEY_CODITE	  		  , 0 LEY_QTDCPO   , 0 LEY_QTDCNE  			   , ' ' LEY_INDEST	, ' ' LEY_CODPAR"

	aJoin[4] := RetSqlName("T18") + " T18 "
  	aJoin[4] += " LEFT JOIN " + RetSqlName("T23") +  " T23   ON  ( T23.T23_FILIAL = '" + xFilial("T23") + "'  AND T23.T23_ID  = T18.T18_ID  AND T23.D_E_L_E_T_ = ' ' )"
	aJoin[4] += " LEFT JOIN " + RetSqlName("T24") +  " T24   ON  ( T24.T24_FILIAL = '" + xFilial("T24") + "'  AND T24.T24_ID  = T23.T23_ID  AND T24_DTPROD = T23_DTPROD AND T24_CODITE = T23_CODITE AND T24.D_E_L_E_T_ = ' ')"
	aJoin[4] += " LEFT JOIN " + RetSqlName("C1L") +  " C1L   ON  ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "T23.T23_FILIAL" ) + " AND T23.T23_CODITE = C1L.C1L_ID      AND C1L.D_E_L_E_T_ = ' ' ) "
	aJoin[4] += " LEFT JOIN " + RetSqlName("C1L2") + " C1L2  ON  ( C1L2.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "T24.T24_FILIAL" ) + " AND T24.T24_ITECON = C1L2.C1L_ID     AND C1L2.D_E_L_E_T_ = ' ' ) "
	aJoin[4] += " LEFT JOIN " + RetSqlName("C1L3") + " C1L3  ON  ( C1L3.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "T24.T24_FILIAL" ) + " AND T24.T24_INSSUB = C1L3.C1L_ID     AND C1L3.D_E_L_E_T_ = ' ' ) "

	aWhere[4] := "  T18.T18_FILIAL = '"     + xFilial("T18") + "' "
	aWhere[4] += "  AND T18.T18_DTINI >= '" + DTOS(dDataIni) + "' AND T18.T18_DTFIN <='" + DTOS(dDataFim) + "' AND T23.D_E_L_E_T_ = ' ' AND T23.T23_ID IS NOT NULL "


	/*-----------------------------------------------------------------------------
	SELECT PARA COMPOR OS REGISTROS K100 E K210/K215
	-----------------------------------------------------------------------------*/
	/*T18 - K100*/	aSelect[5] := " DISTINCT T18.T18_FILIAL, T18.T18_ID T18_ID , T18.T18_DTINI   , T18.T18_DTFIN   , 'K210' REG, "
	/*T19 - K200*/	aSelect[5] += " LER.LER_FILIAL FILIAL  , LER.LER_ID ID     , Null T19_DTEST  , ' ' T19_CODITE  , 0 T19_QTDEST, ' ' T19_INDEST, ' ' T19_CODPAR,"
/*T20 - K220*/	aSelect[5] += " Null T20_DTMOV 		   , ' ' T20_CODITO    , ' ' T20_CODITD  , 0 T20_QTDMOV    , 0 T20_QTDMDE  , "
	/*T21 - K230*/	aSelect[5] += " Null T21_DTINIO		   , Null T21_DTFINO   , ' ' T21_CODOP   , ' ' T21_CODITE  , 0 T21_QTDPRO,"
	/*T22 - K235*/	aSelect[5] += " ' ' T22_CODOP  		   , Null T22_DTSAID   , ' ' T22_CODINS  , 0 T22_QTDCON    , ' ' T22_INSSUB,"
	/*T23 - K250*/  	aSelect[5] += " Null T23_DTPROD        , ' ' T23_CODITE    , 0 T23_QTDPRO,"
	/*T24 - K255*/	aSelect[5] += " Null T24_DTPROD        , ' ' T24_CODITE    , Null T24_DTCONS , ' ' T24_ITECON  , 0 T24_QTDINS, ' ' T24_INSSUB,"
	/*LER - K210*/	aSelect[5] += " LER.LER_DTINIO         , LER.LER_DTFINO    , LER.LER_CODOS	 , C1L.C1L_CODIGO LER_CODITE  , LER.LER_QTDORI,"
	/*LES - K215*/	aSelect[5] += " C1L2.C1L_CODIGO LES_CODITD         , LES.LES_QTDDES,   "
	/*LET - K260*/	aSelect[5] += " ' ' LET_CODOSP         , ' ' LET_CODITE    , Null LET_DTSAID , 0 LET_QTDSAI	   , Null LET_DTRETO, 0 LET_QTDRET,"
	/*LEU - K265*/	aSelect[5] += " ' ' LEU_CODMER         , 0 LEU_QTDCON	   , 0 LEU_QTDRET,"
	/*LEV - K270*/	aSelect[5] += " Null LEV_DTINIA        , Null LEV_DTFINA   , ' ' LEV_CODOSP , ' ' LEV_CODITE   , 0 LEV_QTDCPO   , 0 LEV_QTDCNE, ' ' LEV_ORIGEM,"
	/*LEX - K275*/	aSelect[5] += " ' ' LEX_CODMER         , 0 LEX_QTDCPO	   , 0 LEX_QTDCNE   , ' ' LEX_CODINS,"
	/*LEY - K280*/	aSelect[5] += " Null LEY_DTEST         , ' ' LEY_CODITE	   , 0 LEY_QTDCPO   , 0 LEY_QTDCNE     , ' ' LEY_INDEST	, ' ' LEY_CODPAR"

	aJoin[5] := RetSqlName("T18") + " T18 "
  	aJoin[5] += " LEFT JOIN " + RetSqlName("LER") +  " LER   ON  ( LER.LER_FILIAL = '" + xFilial("LER") + "'  AND LER.LER_ID  = T18.T18_ID  AND LER.D_E_L_E_T_ = ' ' )"
	aJoin[5] += " LEFT JOIN " + RetSqlName("LES") +  " LES   ON  ( LES.LES_FILIAL = '" + xFilial("LES") + "'  AND LES.LES_ID  = LER.LER_ID  AND LES_CODOS = LER_CODOS AND LES_CODITE = LER_CODITE AND LES.D_E_L_E_T_ = ' ')"
	aJoin[5] += " LEFT JOIN " + RetSqlName("C1L") +  " C1L   ON  ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "LER.LER_FILIAL" ) + " AND LER.LER_CODITE = C1L.C1L_ID      AND C1L.D_E_L_E_T_ = ' ' ) "
	aJoin[5] += " LEFT JOIN " + RetSqlName("C1L2") + " C1L2  ON  ( C1L2.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "LES.LES_FILIAL" ) + " AND LES.LES_CODITD = C1L2.C1L_ID     AND C1L2.D_E_L_E_T_ = ' ' ) "

	aWhere[5] := "  T18.T18_FILIAL = '"     + xFilial("T18") + "' "
	aWhere[5] += "  AND T18.T18_DTINI >= '" + DTOS(dDataIni) + "' AND T18.T18_DTFIN <='" + DTOS(dDataFim) + "' AND LER.D_E_L_E_T_ = ' ' AND LER.LER_ID IS NOT NULL "


	/*-----------------------------------------------------------------------------
	SELECT PARA COMPOR OS REGISTROS K100 E K260/K265
	-----------------------------------------------------------------------------*/
	/*T18 - K100*/	aSelect[6] := " DISTINCT T18.T18_FILIAL, T18.T18_ID T18_ID , T18.T18_DTINI   , T18.T18_DTFIN   , 'K260' REG, "
	/*T19 - K200*/	aSelect[6] += " LET.LET_FILIAL FILIAL  , LET.LET_ID ID     , Null T19_DTEST  , ' ' T19_CODITE  , 0 T19_QTDEST, ' ' T19_INDEST, ' ' T19_CODPAR,"
/*T20 - K220*/	aSelect[6] += " Null T20_DTMOV 		   , ' ' T20_CODITO    , ' ' T20_CODITD  , 0 T20_QTDMOV    , 0 T20_QTDMDE  ,"
	/*T21 - K230*/	aSelect[6] += " Null T21_DTINIO		   , Null T21_DTFINO   , ' ' T21_CODOP   , ' ' T21_CODITE  , 0 T21_QTDPRO,"
	/*T22 - K235*/	aSelect[6] += " ' ' T22_CODOP  		   , Null T22_DTSAID   , ' ' T22_CODINS  , 0 T22_QTDCON    , ' ' T22_INSSUB,"
	/*T23 - K250*/  	aSelect[6] += " Null T23_DTPROD        , ' ' T23_CODITE    , 0 T23_QTDPRO,"
	/*T24 - K255*/	aSelect[6] += " Null T24_DTPROD        , ' ' T24_CODITE    , Null T24_DTCONS , ' ' T24_ITECON  , 0 T24_QTDINS, ' ' T24_INSSUB,"
	/*LER - K210*/	aSelect[6] += " Null LER_DTINIO        , Null LER_DTFINO   , ' ' LER_CODOS   , ' ' LER_CODITE  , 0 LER_QTDORI,"
	/*LES - K215*/	aSelect[6] += " ' ' LES_CODITD         , 0 LES_QTDDES,"
	/*LET - K260*/	aSelect[6] += " LET.LET_CODOSP         , C1L.C1L_CODIGO LET_CODITE    , LET.LET_DTSAID , LET.LET_QTDSAI   , LET.LET_DTRETO, LET.LET_QTDRET,"
	/*LEU - K265*/	aSelect[6] += " C1L2.C1L_CODIGO LEU_CODMER         , LEU.LEU_QTDCON	   , LEU.LEU_QTDRET,"
	/*LEV - K270*/	aSelect[6] += " Null LEV_DTINIA        , Null LEV_DTFINA   , ' ' LEV_CODOSP , ' ' LEV_CODITE	   , 0 LEV_QTDCPO  , 0 LEV_QTDCNE, ' ' LEV_ORIGEM,"
	/*LEX - K275*/	aSelect[6] += " ' ' LEX_CODMER         , 0 LEX_QTDCPO	   , 0 LEX_QTDCNE   , ' ' LEX_CODINS,"
	/*LEY - K280*/	aSelect[6] += " Null LEY_DTEST         , ' ' LEY_CODITE	   , 0 LEY_QTDCPO   , 0 LEY_QTDCNE     , ' ' LEY_INDEST, ' ' LEY_CODPAR"

	aJoin[6] := RetSqlName("T18") + " T18 "
  	aJoin[6] += " LEFT JOIN " + RetSqlName("LET") +  " LET   ON  ( LET.LET_FILIAL = '" + xFilial("LET") + "'  AND LET.LET_ID  = T18.T18_ID  AND LET.D_E_L_E_T_ = ' ' )"
	aJoin[6] += " LEFT JOIN " + RetSqlName("LEU") +  " LEU   ON  ( LEU.LEU_FILIAL = '" + xFilial("LEU") + "'  AND LEU.LEU_ID  = LET.LET_ID  AND LEU_CODOSP = LET_CODOSP AND LEU_CODITE = LET_CODITE AND LEU.D_E_L_E_T_ = ' ')"
	aJoin[6] += " LEFT JOIN " + RetSqlName("C1L") +  " C1L   ON  ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "LET.LET_FILIAL" ) + " AND LET.LET_CODITE = C1L.C1L_ID      AND C1L.D_E_L_E_T_ = ' ' ) "
	aJoin[6] += " LEFT JOIN " + RetSqlName("C1L2") + " C1L2  ON  ( C1L2.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "LEU.LEU_FILIAL" ) + " AND LEU.LEU_CODMER = C1L2.C1L_ID    AND C1L2.D_E_L_E_T_ = ' ' ) "

	aWhere[6] := "  T18.T18_FILIAL = '"     + xFilial("T18") + "' "
	aWhere[6] += "  AND T18.T18_DTINI >= '" + DTOS(dDataIni) + "' AND T18.T18_DTFIN <='" + DTOS(dDataFim) + "' AND LET.D_E_L_E_T_ = ' ' AND LET.LET_ID IS NOT NULL "


	/*-----------------------------------------------------------------------------
	SELECT PARA COMPOR OS REGISTROS K100 E K270/K275
	-----------------------------------------------------------------------------*/
	/*T18 - K100*/	aSelect[7] := " DISTINCT T18.T18_FILIAL, T18.T18_ID T18_ID , T18.T18_DTINI   , T18.T18_DTFIN   , 'K270' REG, "
	/*T19 - K200*/	aSelect[7] += " LEV.LEV_FILIAL FILIAL  , LEV.LEV_ID ID     , Null T19_DTEST  , ' ' T19_CODITE  , 0 T19_QTDEST, ' ' T19_INDEST, ' ' T19_CODPAR,"
/*T20 - K220*/	aSelect[7] += " Null T20_DTMOV 		   , ' ' T20_CODITO    , ' ' T20_CODITD  , 0 T20_QTDMOV    , 0 T20_QTDMDE   , "
	/*T21 - K230*/	aSelect[7] += " Null T21_DTINIO		   , Null T21_DTFINO   , ' ' T21_CODOP   , ' ' T21_CODITE  , 0 T21_QTDPRO,"
	/*T22 - K235*/	aSelect[7] += " ' ' T22_CODOP  		   , Null T22_DTSAID   , ' ' T22_CODINS  , 0 T22_QTDCON    , ' ' T22_INSSUB,"
	/*T23 - K250*/  	aSelect[7] += " Null T23_DTPROD        , ' ' T23_CODITE    , 0 T23_QTDPRO,"
	/*T24 - K255*/	aSelect[7] += " Null T24_DTPROD        , ' ' T24_CODITE    , Null T24_DTCONS , ' ' T24_ITECON  , 0 T24_QTDINS, ' ' T24_INSSUB,"
	/*LER - K210*/	aSelect[7] += " Null LER_DTINIO        , Null LER_DTFINO   , ' ' LER_CODOS   , ' ' LER_CODITE  , 0 LER_QTDORI,"
	/*LES - K215*/	aSelect[7] += " ' ' LES_CODITD         , 0 LES_QTDDES,"
	/*LET - K260*/	aSelect[7] += " ' ' LET_CODOSP         , ' ' LET_CODITE    , Null LET_DTSAID , 0 LET_QTDSAI	   , Null LET_DTRETO, 0 LET_QTDRET,"
	/*LEU - K265*/	aSelect[7] += " ' ' LEU_CODMER         , 0 LEU_QTDCON	   , 0 LEU_QTDRET,"
	/*LEV - K270*/	aSelect[7] += " LEV.LEV_DTINIA         , LEV.LEV_DTFINA    , LEV.LEV_CODOSP  , C1L.C1L_CODIGO LEV_CODITE  , LEV.LEV_QTDCPO , LEV.LEV_QTDCNE, LEV.LEV_ORIGEM,"
	/*LEX - K275*/	aSelect[7] += " C1L2.C1L_CODIGO LEX_CODMER         , LEX.LEX_QTDCPO	   , LEX.LEX_QTDCNE  , C1L3.C1L_CODIGO LEX_CODINS,"
	/*LEY - K280*/	aSelect[7] += " Null LEY_DTEST         , ' ' LEY_CODITE	   , 0 LEY_QTDCPO    , 0 LEY_QTDCNE    , ' ' LEY_INDEST	, ' ' LEY_CODPAR"

	aJoin[7] := RetSqlName("T18") + " T18 "
  	aJoin[7] += " LEFT JOIN " + RetSqlName("LEV") +  " LEV   ON  ( LEV.LEV_FILIAL = '" + xFilial("LEV") + "'  AND LEV.LEV_ID  = T18.T18_ID  AND LEV.D_E_L_E_T_ = ' ' )"
	aJoin[7] += " LEFT JOIN " + RetSqlName("LEX") +  " LEX   ON  ( LEX.LEX_FILIAL = '" + xFilial("LEX") + "'  AND LEX.LEX_ID  = LEV.LEV_ID  AND LEV_DTINIA = LEX_DTINIA AND LEV_DTFINA = LEX_DTFINA AND LEV_CODOSP = LEX_CODOSP AND LEV_CODITE = LEX_CODITE AND LEV.D_E_L_E_T_ = ' ')"
	aJoin[7] += " LEFT JOIN " + RetSqlName("C1L") +  " C1L   ON  ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'"  , "LEV.LEV_FILIAL" ) + " AND LEV.LEV_CODITE = C1L.C1L_ID      AND C1L.D_E_L_E_T_ = ' ' ) "
	aJoin[7] += " LEFT JOIN " + RetSqlName("C1L2") + " C1L2  ON  ( C1L2.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "LEX.LEX_FILIAL" ) + " AND LEX.LEX_CODMER = C1L2.C1L_ID     AND C1L2.D_E_L_E_T_ = ' ' ) "
 	aJoin[7] += " LEFT JOIN " + RetSqlName("C1L3") + " C1L3  ON  ( C1L3.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'" , "LEX.LEX_FILIAL" ) + " AND LEX.LEX_CODINS = C1L3.C1L_ID     AND C1L3.D_E_L_E_T_ = ' ' ) "

	aWhere[7] := "  T18.T18_FILIAL = '"     + xFilial("T18") + "' "
	aWhere[7] += "  AND T18.T18_DTINI >= '" + DTOS(dDataIni) + "' AND T18.T18_DTFIN <='" + DTOS(dDataFim) + "' AND LEV.D_E_L_E_T_ = ' ' AND LEV.LEV_ID IS NOT NULL "


	/*-----------------------------------------------------------------------------
	SELECT PARA COMPOR OS REGISTROS K100 E K280
	-----------------------------------------------------------------------------*/
	/*T18 - K100*/	aSelect[8] := " DISTINCT T18.T18_FILIAL, T18.T18_ID T18_ID , T18.T18_DTINI   , T18.T18_DTFIN   , 'K280' REG, "
	/*T19 - K200*/	aSelect[8] += " LEY.LEY_FILIAL FILIAL  , LEY.LEY_ID ID     , Null T19_DTEST  , ' ' T19_CODITE  , 0 T19_QTDEST, ' ' T19_INDEST, ' ' T19_CODPAR,"
/*T20 - K220*/	aSelect[8] += " Null T20_DTMOV 		   , ' ' T20_CODITO    , ' ' T20_CODITD  , 0 T20_QTDMOV    , 0 T20_QTDMDE  ,"
	/*T21 - K230*/	aSelect[8] += " Null T21_DTINIO		   , Null T21_DTFINO   , ' ' T21_CODOP   , ' ' T21_CODITE  , 0 T21_QTDPRO,"
	/*T22 - K235*/	aSelect[8] += " ' ' T22_CODOP  		   , Null T22_DTSAID   , ' ' T22_CODINS  , 0 T22_QTDCON    , ' ' T22_INSSUB,"
	/*T23 - K250*/ 	aSelect[8] += " Null T23_DTPROD        , ' ' T23_CODITE    , 0 T23_QTDPRO,"
	/*T24 - K255*/	aSelect[8] += " Null T24_DTPROD        , ' ' T24_CODITE    , Null T24_DTCONS , ' ' T24_ITECON  , 0 T24_QTDINS, ' ' T24_INSSUB,"
	/*LER - K210*/	aSelect[8] += " Null LER_DTINIO        , Null LER_DTFINO   , ' ' LER_CODOS   , ' ' LER_CODITE  , 0 LER_QTDORI,"
	/*LES - K215*/	aSelect[8] += " ' ' LES_CODITD         , 0 LES_QTDDES,"
	/*LET - K260*/	aSelect[8] += " ' ' LET_CODOSP         , ' ' LET_CODITE    , Null LET_DTSAID , 0 LET_QTDSAI	   , Null LET_DTRETO, 0 LET_QTDRET,"
	/*LEU - K265*/	aSelect[8] += " ' ' LEU_CODMER         , 0 LEU_QTDCON	   , 0 LEU_QTDRET,"
	/*LEV - K270*/	aSelect[8] += " Null LEV_DTINIA        , Null LEV_DTFINA  , ' ' LEV_CODOSP , ' ' LEV_CODITE	   , 0 LEV_QTDCPO  , 0 LEV_QTDCNE, ' ' LEV_ORIGEM,"
	/*LEX - K275*/	aSelect[8] += " ' ' LEX_CODMER         , 0 LEX_QTDCPO	  , 0 LEX_QTDCNE   , ' ' LEX_CODINS,"
	/*LEY - K280*/	aSelect[8] += " LEY.LEY_DTEST          , C1L.C1L_CODIGO LEY_CODITE	  , LEY.LEY_QTDCPO , LEY.LEY_QTDCNE    , LEY.LEY_INDEST, C1H.C1H_CODPAR LEY_CODPAR"

	aJoin[8] := RetSqlName("T18") + " T18 "
  	aJoin[8] += " LEFT JOIN " + RetSqlName("LEY") +  " LEY   ON  ( LEY.LEY_FILIAL = '" + xFilial("LEY") + "'  AND LEY.LEY_ID  = T18.T18_ID  AND LEY.D_E_L_E_T_ = ' ' )"
	aJoin[8] += " LEFT JOIN " + RetSqlName("C1L") +  " C1L   ON  ( C1L.C1L_FILIAL = " + Iif( FWModeAccess( "C1L" , 3 ) == "C" , "'" + xFilial( "C1L" ) + "'"  , "LEY.LEY_FILIAL" ) + " AND LEY.LEY_CODITE = C1L.C1L_ID      AND C1L.D_E_L_E_T_ = ' ' ) "
	aJoin[8] += " LEFT JOIN " + RetSqlName("C1H") + " C1H  ON ( C1H.C1H_FILIAL = " + Iif( FWModeAccess( "C1H" , 3 ) == "C" , "'" + xFilial( "C1H" ) + "'" , "LEY.LEY_FILIAL" )     + " AND LEY.LEY_CODPAR = C1H.C1H_ID   	AND C1H.D_E_L_E_T_ = ' ' ) "

	aWhere[8] := "  T18.T18_FILIAL = '"     + xFilial("T18") + "' "
	aWhere[8] += "  AND T18.T18_DTINI >= '" + DTOS(dDataIni) + "' AND T18.T18_DTFIN <='" + DTOS(dDataFim) + "' AND LEY.D_E_L_E_T_ = ' ' AND LEY.LEY_ID IS NOT NULL "

	cOrderBy := "T18_ID"

	aSelect[1] := "%" + aSelect[1] + "%"
	aSelect[2] := "%" + aSelect[2] + "%"
	aSelect[3] := "%" + aSelect[3] + "%"
	aSelect[4] := "%" + aSelect[4] + "%"
	aSelect[5] := "%" + aSelect[5] + "%"
	aSelect[6] := "%" + aSelect[6] + "%"
	aSelect[7] := "%" + aSelect[7] + "%"
	aSelect[8] := "%" + aSelect[8] + "%"

	aJoin[1]   := "%" + aJoin[1]   + "%"
	aJoin[2]   := "%" + aJoin[2]   + "%"
	aJoin[3]   := "%" + aJoin[3]   + "%"
	aJoin[4]   := "%" + aJoin[4]   + "%"
	aJoin[5]   := "%" + aJoin[5]   + "%"
	aJoin[6]   := "%" + aJoin[6]   + "%"
	aJoin[7]   := "%" + aJoin[7]   + "%"
	aJoin[8]   := "%" + aJoin[8]   + "%"

	aWhere[1]   := "%" + aWhere[1]   + "%"
	aWhere[2]   := "%" + aWhere[2]   + "%"
	aWhere[3]   := "%" + aWhere[3]   + "%"
	aWhere[4]   := "%" + aWhere[4]   + "%"
	aWhere[5]   := "%" + aWhere[5]   + "%"
	aWhere[6]   := "%" + aWhere[6]   + "%"
	aWhere[7]   := "%" + aWhere[7]   + "%"
	aWhere[8]   := "%" + aWhere[8]   + "%"

	cOrderBy := "%" + cOrderBy + "%

	BeginSql Alias cAliasQry
	    SELECT
		    %Exp:aSelect[1]%
	    FROM
	        %Exp:aJoin[1]%
		WHERE
			%EXP:aWhere[1]%
		UNION
		SELECT
			%Exp:aSelect[2]%
		FROM
			%Exp:aJoin[2]%
		WHERE
			%EXP:aWhere[2]%
		UNION
	    SELECT
		    %Exp:aSelect[3]%
	    FROM
	        %Exp:aJoin[3]%
		WHERE
			%EXP:aWhere[3]%
		UNION
	    SELECT
		    %Exp:aSelect[4]%
	    FROM
	        %Exp:aJoin[4]%
		WHERE
			%EXP:aWhere[4]%
		UNION
	    SELECT
		    %Exp:aSelect[5]%
	    FROM
	        %Exp:aJoin[5]%
		WHERE
			%EXP:aWhere[5]%
		UNION
	    SELECT
		    %Exp:aSelect[6]%
	    FROM
	        %Exp:aJoin[6]%
		WHERE
			%EXP:aWhere[6]%
		UNION
	    SELECT
		    %Exp:aSelect[7]%
	    FROM
	        %Exp:aJoin[7]%
		WHERE
			%EXP:aWhere[7]%
		UNION
		SELECT
		    %Exp:aSelect[8]%
	    FROM
	        %Exp:aJoin[8]%
		WHERE
			%EXP:aWhere[8]%
		ORDER BY
			%Exp:cOrderBy%
	EndSql

	If !lGerK001
		If !( cAliasQry )->( Eof() )

		    aMacro	:=	{}
			aAdd( aMacro , "0" )

			LoadString( 'K001' , aCmps , @cStrTxt, , , aMacro )

			aInfoGrv[5]++
			If( nRWStrTxt	:=	WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K001" ) ) >= 0

				/*-----------------------------------------------------------------------------
				Conta os registros para totalizar no bloco 9
				-----------------------------------------------------------------------------*/
				TaFContBlc("K001", aTotRegK)

				lGerK001 := .T.
			EndIf
		EndIf
	EndIf

	/*-----------------------------------------------------------------------------
	Laco Principal da Rotina para Realizar a Emissao dos Registros
	-----------------------------------------------------------------------------*/
	(cAliasQry)->(DbGoTop())
	nCnt 	:= 1
	cTexto	:= ""

	While !( cAliasQry )->( Eof() )

		/*-----------------------------------------------------------------------------
		Gravacao do registro K100 no arquivo texto
		-----------------------------------------------------------------------------*/
		If (cAliasQry)->T18_ID <> cChaveAntK100

			/*-----------------------------------------------------------------------------
			Pega as informações da Query
			-----------------------------------------------------------------------------*/
			LoadString( 'K100' , aCmps , @cStrTxt, cAliasQry )
			aInfoGrv[5]++

			/*-----------------------------------------------------------------------------
			Grava no arquivo txt as informações e soma para totalizar no bloco
			-----------------------------------------------------------------------------*/
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
			TaFContBlc("K100",aTotRegK)

			/*-----------------------------------------------------------------------------
			Salva o id do pai
			-----------------------------------------------------------------------------*/
			cChaveAntK100	:= (cAliasQry)->T18_ID
		EndIf

		/*-----------------------------------------------------------------------------
		Gravacao do registro K200 no arquivo texto
		-----------------------------------------------------------------------------*/
		If 	(cAliasQry)->REG == 'K200' .AND. !Empty( (cAliasQry)->ID )

			/*-----------------------------------------------------------------------------
			Pega as informações da Query
			-----------------------------------------------------------------------------*/
			LoadString( 'K200' , aCmps , @cStrTxt, cAliasQry )
			aInfoGrv[5]++

			/*-----------------------------------------------------------------------------
			Grava no arquivo txt as informações e soma para totalizar no bloco
			-----------------------------------------------------------------------------*/
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
			TaFContBlc("K200",aTotRegK)

			xGerBlc0("0200", AllTrim((cAliasQry)->T19_CODITE), cFilSel, aWizard, cTabSped,  )
			xGerBlc0("0150", AllTrim((cAliasQry)->T19_CODPAR), cFilSel, aWizard, cTabSped,  )


		/*-----------------------------------------------------------------------------
		Gravacao do registro K210 no arquivo texto
		-----------------------------------------------------------------------------*/
		ElseIf  (cAliasQry) -> REG == 'K210' .And. lGeraTudo

			/*-----------------------------------------------------------------------------
			Verifica se ja foi impresso esse registro com essa chave e só deixa imprimir se
			não tiver sido impresso
			-----------------------------------------------------------------------------*/
			If cChaveAntK100 == (cAliasQry)-> T18_ID .AND. (Alltrim((cAliasQry)-> (LER_CODOS+LER_CODITE)) <> cChave)

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K210' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K210",aTotRegK)

				cChave:= Alltrim((cAliasQry)->(LER_CODOS + LER_CODITE))

				xGerBlc0("0200", AllTrim((cAliasQry)->LER_CODITE), cFilSel, aWizard, cTabSped,  )
			EndIf

			/*-----------------------------------------------------------------------------
			Gravacao do registro K215 no arquivo texto
			-----------------------------------------------------------------------------*/
			If !Empty( (cAliasQry)->LES_CODITD ) .And. lGeraTudo

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K215' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K215",aTotRegK)
				xGerBlc0("0200", AllTrim((cAliasQry)->LES_CODITD), cFilSel, aWizard, cTabSped,  )
			EndIf

		/*-----------------------------------------------------------------------------
		Gravacao do registro K220 no arquivo texto
		-----------------------------------------------------------------------------*/
		ElseIf (cAliasQry)->REG == 'K220' .And. lGeraTudo

			/*-----------------------------------------------------------------------------
			Pega as informações da Query
			-----------------------------------------------------------------------------*/
			LoadString( 'K220' , aCmps , @cStrTxt, cAliasQry )
			aInfoGrv[5]++

			/*-----------------------------------------------------------------------------
			Grava no arquivo txt as informações e soma para totalizar no bloco
			-----------------------------------------------------------------------------*/
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
			TaFContBlc("K220",aTotRegK)

			xGerBlc0("0200", AllTrim((cAliasQry)->T20_CODITO), cFilSel, aWizard, cTabSped,  )
			xGerBlc0("0200", AllTrim((cAliasQry)->T20_CODITD), cFilSel, aWizard, cTabSped,  )

		/*-----------------------------------------------------------------------------
		Gravacao do registro K230 no arquivo texto
		-----------------------------------------------------------------------------*/
		ElseIf  (cAliasQry)->REG == 'K230' .And. lGeraTudo

			/*-----------------------------------------------------------------------------
			Verifica se ja foi impresso esse registro com essa chave e só deixa imprimir se
			não tiver sido impresso
			-----------------------------------------------------------------------------*/
			If cChaveAntK100 == (cAliasQry)->T18_ID .AND. (Alltrim((cAliasQry)->(T21_CODOP +T21_CODITE)) <> cChave)

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K230' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K230",aTotRegK)

				cChave:= Alltrim((cAliasQry)->(T21_CODOP + T21_CODITE))

				xGerBlc0("0200", AllTrim((cAliasQry)->T21_CODITE), cFilSel, aWizard, cTabSped,  )
			EndIf

			/*-----------------------------------------------------------------------------
			Gravacao do registro K235 no arquivo texto
			-----------------------------------------------------------------------------*/
			If !Empty( (cAliasQry)->T22_DTSAID ) .And. lGeraTudo

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K235' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K235",aTotRegK)
				xGerBlc0("0200", AllTrim((cAliasQry)->T22_CODINS), cFilSel, aWizard, cTabSped,  )
			EndIf

		/*-----------------------------------------------------------------------------
		Gravacao do registro K250 no arquivo texto
		-----------------------------------------------------------------------------*/
		ElseIf	(cAliasQry)->REG == 'K250' .And. lGeraTudo

			/*-----------------------------------------------------------------------------
			Verifica se ja foi impresso esse registro com essa chave e só deixa imprimir se
			não tiver sido impresso
			-----------------------------------------------------------------------------*/
			If cChaveAntK100 == (cAliasQry)->T18_ID .AND. (Alltrim((cAliasQry)->(T23_DTPROD+T23_CODITE)) <> cChave)

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K250' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K250",aTotRegK)

				cChave := Alltrim((cAliasQry)->(T23_DTPROD + T23_CODITE))

				xGerBlc0("0200", AllTrim((cAliasQry)->T23_CODITE), cFilSel, aWizard, cTabSped,  )
			EndIf

			/*-----------------------------------------------------------------------------
			Gravacao do registro K255 no arquivo texto
			-----------------------------------------------------------------------------*/
			If !Empty( (cAliasQry)->T24_DTCONS )

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K255' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K255",aTotRegK)

				xGerBlc0("0200", AllTrim((cAliasQry)->T24_ITECON), cFilSel, aWizard, cTabSped,  )
			EndIf

		/*-----------------------------------------------------------------------------
		Gravacao do registro K260 no arquivo texto
		-----------------------------------------------------------------------------*/
		ElseIf	(cAliasQry)->REG == 'K260' .And. lGeraTudo

			/*-----------------------------------------------------------------------------
			Verifica se ja foi impresso esse registro com essa chave e só deixa imprimir se
			não tiver sido impresso
			-----------------------------------------------------------------------------*/
			If cChaveAntK100 == (cAliasQry)->T18_ID .AND. (Alltrim((cAliasQry)->(LET_CODOSP+LET_CODITE)) <> cChave)

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K260' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K260",aTotRegK)

				cChave := Alltrim((cAliasQry)->(LET_CODOSP + LET_CODITE))

				xGerBlc0("0200", AllTrim((cAliasQry)->LET_CODITE), cFilSel, aWizard, cTabSped,  )

			EndIf

			/*-----------------------------------------------------------------------------
			Gravacao do registro K265 no arquivo texto
			-----------------------------------------------------------------------------*/
			If !Empty( (cAliasQry)->LEU_CODMER )

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K265' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K265",aTotRegK)

				xGerBlc0("0200", AllTrim((cAliasQry)->LEU_CODMER), cFilSel, aWizard, cTabSped,  )
			EndIf

		/*-----------------------------------------------------------------------------
		Gravacao do registro K270 no arquivo texto
		-----------------------------------------------------------------------------*/
		ElseIf	(cAliasQry)->REG == 'K270' .And. lGeraTudo

			/*-----------------------------------------------------------------------------
			Verifica se ja foi impresso esse registro com essa chave e só deixa imprimir se
			não tiver sido impresso
			-----------------------------------------------------------------------------*/
			If cChaveAntK100 == (cAliasQry)->T18_ID .AND. (Alltrim((cAliasQry)->(LEV_DTINIA+LEV_DTFINA+LEV_CODOSP+LEV_CODITE)) <> cChave)

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K270' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K270",aTotRegK)

				cChave := Alltrim((cAliasQry)-> (LEV_DTINIA + LEV_DTFINA + LEV_CODOSP + LEV_CODITE))

				xGerBlc0("0200", AllTrim((cAliasQry)->LEV_CODITE), cFilSel, aWizard, cTabSped,  )
			EndIf

			/*-----------------------------------------------------------------------------
			Gravacao do registro K275 no arquivo texto
			-----------------------------------------------------------------------------*/
			If !Empty( (cAliasQry)->LEX_CODMER )

				/*-----------------------------------------------------------------------------
				Pega as informações da Query
				-----------------------------------------------------------------------------*/
				LoadString( 'K275' , aCmps , @cStrTxt, cAliasQry )
				aInfoGrv[5]++

				/*-----------------------------------------------------------------------------
				Grava no arquivo txt as informações e soma para totalizar no bloco
				-----------------------------------------------------------------------------*/
				WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
				TaFContBlc("K275",aTotRegK)

				xGerBlc0("0200", AllTrim((cAliasQry)->LEX_CODMER), cFilSel, aWizard, cTabSped,  )
				xGerBlc0("0200", AllTrim((cAliasQry)->LEX_CODINS), cFilSel, aWizard, cTabSped,  )
			EndIf

		/*-----------------------------------------------------------------------------
		Gravacao do registro K220 no arquivo texto
		-----------------------------------------------------------------------------*/
		ElseIf (cAliasQry)->REG == 'K280'

			/*-----------------------------------------------------------------------------
			Pega as informações da Query
			-----------------------------------------------------------------------------*/
			LoadString( 'K280' , aCmps , @cStrTxt, cAliasQry )
			aInfoGrv[5]++

			/*-----------------------------------------------------------------------------
			Grava no arquivo txt as informações e soma para totalizar no bloco
			-----------------------------------------------------------------------------*/
			WrtStrTxt(  , @cStrTxt, .T., @aInfoGrv, "K100" )
			TaFContBlc("K280",aTotRegK)

			xGerBlc0("0200", AllTrim((cAliasQry)->LEY_CODITE), cFilSel, aWizard, cTabSped,  )
			xGerBlc0("0150", AllTrim((cAliasQry)->LEY_CODPAR), cFilSel, aWizard, cTabSped,  )
		EndIf

		( cAliasQry )->(DbSkip())
		nCnt++
	EndDo

	(cAliasQry)->( DbCloseArea() )
Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} DistrCmps

Funcao responsavel por definir um depara do layout do fisco para a tabela do TAF,
os campos armazenados no array serao utilizados na gravacao como macro execucao

@return aRet - Array com os campos por registros

@author Vitor Ferreira
@since 03/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DistrCmps(lLayout12)
	Local	aRet	:=	{}
	Local	nI		:=	1

	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K001
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K001' , Array( 01 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| aMacro[ 1 ] }


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K100
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K100' , Array( 02 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T18_DTINI)  }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T18_DTFIN)  }


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K200
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K200' , Array( 05 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T19_DTEST)   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T19_CODITE    					}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(T19_QTDEST, 16, 3) 	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T19_INDEST						}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T19_CODPAR			    		}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K210
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K210' , Array( 05 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(LER_DTINIO)   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(LER_DTFINO)			}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LER_CODOS						}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LER_CODITE						}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(LER_QTDORI, 16, 3)	}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K215
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K215' , Array( 02 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LES_CODITD   					}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(LES_QTDDES, 16, 3)	}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K220
	-----------------------------------------------------------------------------*/
	nI	:=	1
if(lLayout12)
	aAdd( aRet , { 'K220' , Array( 05 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T20_DTMOV)   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T20_CODITO			   	 	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T20_CODITD			    	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(T20_QTDMOV, 16, 3) }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(T20_QTDMDE, 16, 3) }
Else
	aAdd( aRet , { 'K220' , Array( 04 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T20_DTMOV)   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T20_CODITO			   	 		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T20_CODITD			    		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(T20_QTDMOV, 16, 3) 	}
endif

	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K230
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K230' , Array( 05 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T21_DTINIO)  	   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T21_DTFINO)  	   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T21_CODOP			    	   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T21_CODITE			    	   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(T21_QTDPRO, 16, 3)  	}

	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K235
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K235' , Array( 04 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T22_DTSAID)  	   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T22_CODINS			    	   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(T22_QTDCON, 16, 3)    	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T22_INSSUB 		           	}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K250
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K250' , Array( 03 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T23_DTPROD)  			}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T23_CODITE			    			}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(T23_QTDPRO, 16, 3) 		}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K255
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K255' , Array( 04 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(T24_DTCONS)         	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T24_ITECON			           	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(T24_QTDINS, 16, 3)    	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| T24_INSSUB			           	}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K260
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K260' , Array( 06 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LET_CODOSP				       	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LET_CODITE			           	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(LET_DTSAID)		   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(LET_QTDSAI, 16, 3)    	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(LET_DTRETO)		   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(LET_QTDRET, 16, 3)    	}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K265
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K265' , Array( 03 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEU_CODMER         		   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(LEU_QTDCON, 16, 3)    	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str(LEU_QTDRET, 16, 3)    	}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K270
	-----------------------------------------------------------------------------*/
	nI  :=     1
	aAdd( aRet , { 'K270' , Array( 07 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(LEV_DTINIA)								   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(LEV_DTFINA)          					   		}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEV_CODOSP                    						   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEV_CODITE                    						   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| IIf(LEV_QTDCPO == 0,"",Val2Str(LEV_QTDCPO, 16, 3))  	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| IIf(LEV_QTDCNE == 0,"",Val2Str(LEV_QTDCNE, 16, 3))  	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEV_ORIGEM                             			   	}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K275
	-----------------------------------------------------------------------------*/
	nI     :=     1
	aAdd( aRet , { 'K275' , Array( 04 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEX_CODMER                      					   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| IIf(LEX_QTDCPO == 0,"",Val2Str(LEX_QTDCPO, 16, 3))  	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| IIf(LEX_QTDCNE == 0,"",Val2Str(LEX_QTDCNE, 16, 3))   }
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEX_CODINS                      					   	}


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K280
	-----------------------------------------------------------------------------*/
	nI     :=     1
	aAdd( aRet , { 'K280' , Array( 06 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Dt2Caract(LEY_DTEST)         						   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEY_CODITE                              			   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| IIf(LEY_QTDCPO == 0,"",Val2Str(LEY_QTDCPO, 16, 3))  	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| IIf(LEY_QTDCNE == 0,"",Val2Str(LEY_QTDCNE, 16, 3))  	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEY_INDEST                                   		   	}
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| LEY_CODPAR                             		       }


	/*-----------------------------------------------------------------------------
	ESTRUTURA DO REGISTRO K990
	-----------------------------------------------------------------------------*/
	nI	:=	1
	aAdd( aRet , { 'K990' , Array( 1 ) } )
	aTail( aRet[ Len( aRet ) ] ) [ nI++ ] := {|| Val2Str( aMacro[ 1 ], 16, 0 ) }

Return ( aRet )