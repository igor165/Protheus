#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFR120.CH"

#DEFINE ALIAS											01
#DEFINE RECNO											02
#DEFINE RECIBO_TRANSMISSAO								03
#DEFINE ESTABELECIMENTO									04
#DEFINE CPF												05
#DEFINE NOME											06
#DEFINE MATRICULA										07
#DEFINE CATEGORIA										08
#DEFINE LOTACAO											09
#DEFINE EVENTO_ESOCIAL									10
#DEFINE TIPO_BASE_CALCULO								11
#DEFINE FOLHA_BASE_INSS									12
#DEFINE FOLHA_VALOR_INSS								13
#DEFINE FOLHA_VALOR_SALARIO_FAMILIA						14
#DEFINE FOLHA_VALOR_SALARIO_MATERNIDADE					15
#DEFINE FOLHA_BASE_INSS_13_SALARIO						16
#DEFINE FOLHA_VALOR_INSS_13_SALARIO						17
#DEFINE FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO		18
#DEFINE TAF_BASE_INSS									19
#DEFINE TAF_VALOR_INSS									20
#DEFINE TAF_VALOR_SALARIO_FAMILIA						21
#DEFINE TAF_VALOR_SALARIO_MATERNIDADE					22
#DEFINE TAF_BASE_INSS_13_SALARIO						23
#DEFINE TAF_VALOR_INSS_13_SALARIO						24
#DEFINE TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO		25
#DEFINE GOVERNO_BASE_INSS								26
#DEFINE GOVERNO_VALOR_INSS								27
#DEFINE GOVERNO_VALOR_SALARIO_FAMILIA					28
#DEFINE GOVERNO_VALOR_SALARIO_MATERNIDADE				29
#DEFINE GOVERNO_BASE_INSS_13_SALARIO					30
#DEFINE GOVERNO_VALOR_INSS_13_SALARIO					31
#DEFINE GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO	32
#DEFINE OBSERVACAO										33
#DEFINE TIPO_FUNCIONARIO								34
#DEFINE GOVERNO_LOCALIZADO								35
#DEFINE GOVERNO_BASE_SUSPENSAO                          36

#DEFINE CPF_TRABALHADOR									01
#DEFINE NOME_TRABALHADOR								02
#DEFINE EVENTO_ESOCIAL_TOTALIZADOR						03
#DEFINE TOTALIZADOR_FOLHA_VALOR_INSS					04
#DEFINE TOTALIZADOR_TAF_VALOR_INSS						05
#DEFINE TOTALIZADOR_GOVERNO_VALOR_INSS					06
#DEFINE NUM_INSC_ESTABELECIMENTO						07

#DEFINE CHAVE_TOT_ESTAB									01
#DEFINE TOTALIZADOR_ESTABELECIMENTO						02

Static aInfoSM0		:=	FWLoadSM0()
Static __cInFiliais	:=	Nil
Static __lSemVlr	:=	.F.	//Default não mostra Colaboradores
Static __CPF		:=	""	//Default Filtro por CPF
Static lC8RCmpart	:=  If(FWModeAccess( "C8R", 1) == "E" .AND. FWModeAccess( "C8R", 2) == "E" .AND. FWModeAccess( "C8R", 3) == "E",.T.,.F. )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR120
@type			function
@description	Geração do arquivo de conferência do evento S-5001 em Excel.
@author			Felipe C. Seolin
@since			16/08/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFR120()

Local lContinua     := FindFunction("HMNew") .And. FindFunction("HMList") .And. FindFunction("HMClean") .And.;
						FindFunction("HMGet") .And. FindFunction("HMSet") .And. FindFunction("HMAdd")
Local oArqTrb		:= Nil
Local cPerg			:= PadR( "TAFR120", 10 )
Local cPath			:= ""
Local cTimeStart	:= ""
Local cTimeTotal	:= ""
Local cLinkDoc		:= "http://tdn.totvs.com/x/zDF-Fw"
Local nOpcAviso		:= 0
Local aArqTrb		:= {}
Local lCancel		:= .F.
Local oArqTot		:= Nil
Local oProfile		:= Nil
Local oDialog		:= Nil
Local oCheck		:= Nil
Local aSize			:= MsAdvSize()
Local cRetProf		:= ""
Local nHeightBox	:= 0
Local nWidthBox		:= 0
Local nHeight		:= aSize[6]
Local nWidth		:= aSize[5]
Local nPosIni		:= 0
Local lCheck		:= .F.
Local lRet			:= .F.
Local bClose		:= { || }
Local aTelaFil		:= {}
Local lProtheus		:= GetNewPar("MV_RHTAF", .F.)
Local oRunCharge	:= Nil

Private cST2Alias	:= "rsTAFST2"
Private aArqTot		:= {}
Private oArqEst		:= Nil
 
bClose := { || ( SetProfile( oProfile, lCheck ), oDialog:End() ) }

oProfile := FWProfile():New()
oProfile:SetUser( RetCodUsr() )
oProfile:SetProgram( "TAFR120" )
oProfile:SetTask( "RELINSS" )
oProfile:Load()

cRetProf := oProfile:GetStringProfile()

If Empty( cRetProf ) //.or. DateDiffDay( Date(), SToD( cRetProf ) ) >= 7
    lRet := .T.
EndIf

If lContinua .And. IIf(FindFunction("ProtData"),ProtData(),.T.)
	oArqEst := TAFXHMNew()

    If TAFR120Dic( cPerg, .F., .T. ) .and. Pergunte( cPerg, .T. )
		//Valida a existência das novas perguntas do relatório
		If TAFR120Dic( cPerg, .T., .F. )
			__lSemVlr	:=	MV_PAR03 == 1
			__CPF		:=	MV_PAR04
		EndIf

		If GetRemoteType() <>  5
			cPath := cGetFile( "Diretório" + "|*.*", "Procurar", 0,, .T., GETF_RETDIRECTORY + GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD ,.T.,)
		EndIf

		If Empty( cPath ).and.GetRemoteType() <>  5
			MsgAlert( "Diretório não selecionado!" )
		Else

			If lRet
			
				oDialog := MsDialog():New( 0, 0, nHeight, nWidth, "Apresentação Melhoria Relatório",,,,,,,,, .T. )
			
				nHeightBox := ( nHeight - 60 ) / 2
				nWidthBox := ( nWidth - 20 ) / 2
				
				oTBitmap := TBitmap():New(0, 0, nWidthBox - 30, nHeightBox, NIL, "imgtafr120.png", .T., oDialog,;
			       {||}, NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
			
				oCheck := TCheckBox():New( nHeightBox + 10, 10, "Não desejo mais visualizar à apresentação", { || lCheck }, oDialog, 500, 010,, { || lCheck := !lCheck },,,,,, .T. )
			
			    nPosIni := ( ( nWidth - 20 ) / 2 ) - 52
				TButton():New( nHeightBox + 10, nPosIni, "Abrir Relatório", oDialog, bClose, 50, 15,,,, .T. )
			
				oDialog:Activate( ,,,.T. )
			
			EndIf

			If !lCancel
				cTimeStart := Time()

				ChargeINSS(oRunCharge, aTelaFil, MV_PAR01, lProtheus, @oArqTrb, @oArqTot)
				TAFXHMList(oArqTrb, aArqTrb)
				TAFXHMList(oArqTot, aArqTot)

				If !Empty( aArqTrb ) .And. Len(aArqTot) > 0
					FWMsgRun( ,{ |oMsgRun| PrintData( oMsgRun, cPath, aArqTrb, MV_PAR01, MV_PAR02, lProtheus, aArqTot ) }, "Etapa 4/4", "Aguarde..." )
					cTimeTotal := ElapTime( cTimeStart, Time() )

					If GetRemoteType() <>  5 // WebAPP
						nOpcAviso := Aviso( "Relatório", "Processo finalizado. Tempo Total: " + cTimeTotal + "." + CRLF +;
														"Em caso de dúvidas sobre o relatório, favor acessar a documentação oficial através do link: " + CRLF +;
														cLinkDoc + CRLF +;
														"Ou clique no botão <Acessar Link>";
									, { "Acessar Link", "Copiar Link", "Sair" } )

						If nOpcAviso == 1
							If Upper( TCSrvType() ) == "LINUX"
								ShellExecute( "Browser", "/usr/bin/firefox", cLinkDoc, "/", 1 )
							Else
								ShellExecute( "Open", cLinkDoc, "", "C:\", 1 )
							EndIf
						ElseIf nOpcAviso == 2
							CopyToClipboard( cLinkDoc )
							MsgInfo( "Link copiado com sucesso!", "Relatório" )
						EndIf
					Else
						nOpcAviso := Aviso( "Relatório", "Processo finalizado. Tempo Total: " + cTimeTotal + "." + CRLF +;
														"Em caso de dúvidas sobre o relatório, favor acessar a documentação oficial através do link: " + CRLF +;
														cLinkDoc + CRLF +;
														"Ou clique no botão Acessar Link";
									, { "Acessar Link", "Sair" } )

						If nOpcAviso == 1
							If Upper( TCSrvType() ) == "LINUX"
								ShellExecute( "Browser", "/usr/bin/firefox", cLinkDoc, "/", 1 )
							Else
								ShellExecute( "Open", cLinkDoc, "", "C:\", 1 )
							EndIf
						EndIf
					Endif	
				Else
					Alert( "Não foram encontrados dados com os parâmetros informados!" )
				EndIf

				(cST2Alias)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
Else
	Help( ,, "Atenção",, "Ambiente desatualizado.", 1, 0 )
Endif

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} DataS1200
@type			function
@description	Função responsável por colher as informações do Evento S-1200 no TAF.
@author			Felipe C. Seolin
@since			16/08/2018
@version		1.0
@param			oMsgRun		-	Objeto do FWMsgRun
@param			oArqTrb		-	Objeto com as informações para conferência ( Referência )
@param			cPeriodo	-	Período de referência das informações
@param			aFilial		-	Filiais selecionadas para processamento
@param			aFilMatriz	-	Array com as informações da Filial Matriz
@param			aFilMV		-	Array de filiais a ser consideradas na cláusula IN do SQL para Múltiplos Vínculos
@param			oArqTot		-	Objeto com as informações dos totalizadores para conferência ( Referência )
/*/
//---------------------------------------------------------------------
Static Function DataS1200(oMsgRun, oArqTrb, cPeriodo, aFilial, aFilMatriz, aFilMV, oArqTot)

	Local cAliasQry		:= ""
	Local cQuery		:= ""
	Local cFilQry		:= ""
	Local cID			:= ""
	Local cVersao		:= ""
	Local cIDEstab		:= ""
	Local cMVTpEstab	:= ""
	Local cMVEstab		:= ""
	Local cIDLotac		:= ""
	Local cMVLotac		:= ""
	Local cIDTrabal		:= ""
	Local cMVTrabal		:= ""
	Local cIDCateg		:= ""
	Local cC91Trabal	:= ""
	Local cRecibo		:= ""
	Local cIndApu		:= ""
	Local cCPF			:= ""
	Local cNome			:= ""
	Local cNatureza		:= ""
	Local cTipo			:= ""
	Local cIncidPS		:= ""
	Local cCodCat		:= ""
	Local cObsSemInss	:= "Funcionário não possui valores de INSS."
	Local cMatOrig		:= ""
	Local nRecnoQry		:= 0
	Local nBasINSS		:= 0
	Local nVlINSS		:= 0
	Local nSalFam		:= 0
	Local nSalMat		:= 0
	Local nBasINSS13	:= 0
	Local nVlINSS13		:= 0
	Local nSalMat13		:= 0
	Local nContAdd		:= 0
	Local nQtdTotal		:= 0
	Local nQtdProc		:= 0
	Local aPos			:= {}
	Local aArqTrb		:= {}
	Local lMultVinc		:= .F.
	Local lAdd			:= .F.
	Local aPosTot		:= {}
	Local cNrInscEst	:= ""
	Local aPosEstab		:= {}
	Local cCPFTot		:= ""
	Local cChaveHash	:= ""
	Local cTbIdEst		:= ""
	Local nTMatric		:= TamSX3('C9V_MATRIC')[01]
	Local nPosOrig		:= 0
	Local aAreaC9V		:= {}
	Local lTafGpeInss   := IIF(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F. )

	Private aTAFFil		:= {}

	If !Empty(aFilial)

		cAliasQry	:= "rsR1201"

		If Select(cAliasQry) > 0
			(cAliasQry)->(DbCloseArea())
		EndIf

		cQuery := "SELECT COUNT(*) QUANTIDADE "

		cQuery += "FROM " + RetSqlName( "C91" ) + " C91 "

		cQuery += "WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) "

		If Len( AllTrim( cPeriodo ) ) == 4
			cQuery += "  AND C91.C91_PERAPU = '" + cPeriodo +  "' " //Décimo Terceiro
		Else
			cQuery += "  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' " //verificar or para 13° salário
		EndIf

		cQuery += "  AND C91.C91_NOMEVE = 'S1200' "
		cQuery += "  AND C91.C91_ATIVO = '1' "
		cQuery += "  AND C91.C91_EVENTO <> 'E' "
		cQuery += "  AND C91.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )

		TCQuery cQuery New Alias (cAliasQry)

		( cAliasQry )->( DBGoTop() )

		If ( cAliasQry )->( !Eof() )
			nQtdTotal := ( cAliasQry )->QUANTIDADE
		EndIf

		( cAliasQry )->( DBCloseArea() )

		If nQtdTotal > 0
			//Tabelas com as informações do Trabalhador
			C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL, C9V_ID, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
			CUP->( DBSetOrder( 4 ) ) //CUP_FILIAL, CUP_ID, CUP_VERSAO, CUP_NOMEVE, CUP_MATRIC, R_E_C_N_O_, D_E_L_E_T_
			C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações do Estabelecimento
			C92->( DBSetOrder( 5 ) ) //C92_FILIAL, C92_ID, C92_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações da Lotação
			C99->( DBSetOrder( 4 ) ) //C99_FILIAL, C99_ID, C99_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			cAliasQry := "rsR1202"

			If Select(cAliasQry) > 0
				(cAliasQry)->(DbCloseArea())
			EndIf

			cQuery := "SELECT DISTINCT C91.R_E_C_N_O_ C91_RECONHECIMENTO, C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO, C91.C91_INDAPU, C91.C91_PERAPU, ' ' PERREF, ' ' RUBPERANT,  C91.C91_TRABAL, C91.C91_CPF, C91.C91_NOME, C91.C91_MV, C91.C91_PROTUL "
			cQuery += "     , C9K.C9K_ESTABE ESTABE, C9K.C9K_LOTACA LOTACA, C9K.C9K_TPINSC TPINSC, C9K.C9K_NRINSC NRINSC, C9K.C9K_CODLOT CODLOT "
			cQuery += "     , C9L.C9L_TRABAL TRABAL, C9L.C9L_DTRABA DTRABA "
			cQuery += "     , T14.T14_CODCAT "
			cQuery += "     , C89.C89_CODIGO, C8T.C8T_CODIGO, C8R.C8R_INDTRB "
			cQuery += "     , C89MV.C89_CODIGO MVC89_CODIGO, C8TMV.C8T_CODIGO MVC8T_CODIGO, C8RMV.C8R_INDTRB MVC8R_INDTRB "
			cQuery += "     , C9M.C9M_VLRRUB VLRRUB, C8R.C8R_CODRUB, C9M.R_E_C_N_O_ C9M_RECONHECIMENTO "

			cQuery += "FROM " + RetSqlName( "C91" ) + " C91 "

			cQuery += "INNER JOIN " + RetSqlName( "T14" ) + " T14 "
			cQuery += "   ON T14.T14_FILIAL = C91.C91_FILIAL "
			cQuery += "  AND T14.T14_ID = C91.C91_ID "
			cQuery += "  AND T14.T14_VERSAO = C91.C91_VERSAO "
			cQuery += "  AND T14.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "C9K" ) + " C9K "
			cQuery += "   ON C9K.C9K_FILIAL = T14.T14_FILIAL "
			cQuery += "  AND C9K.C9K_ID = T14.T14_ID "
			cQuery += "  AND C9K.C9K_VERSAO = T14.T14_VERSAO "
			cQuery += "  AND C9K.C9K_RECIBO = T14.T14_IDEDMD "
			cQuery += "  AND C9K.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "C9L" ) + " C9L "
			cQuery += "   ON C9L.C9L_FILIAL = C9K.C9K_FILIAL "
			cQuery += "  AND C9L.C9L_ID = C9K.C9K_ID "
			cQuery += "  AND C9L.C9L_VERSAO = C9K.C9K_VERSAO "
			cQuery += "  AND C9L.C9L_RECIBO = C9K.C9K_RECIBO "
			cQuery += "  AND C9L.C9L_ESTABE = C9K.C9K_ESTABE "
			cQuery += "  AND C9L.C9L_LOTACA = C9K.C9K_LOTACA "
			cQuery += "  AND C9L.C9L_TPINSC = C9K.C9K_TPINSC "
			cQuery += "  AND C9L.C9L_NRINSC = C9K.C9K_NRINSC "
			cQuery += "  AND C9L.C9L_CODLOT = C9K.C9K_CODLOT "
			cQuery += "  AND C9L.D_E_L_E_T_ = ' ' "

			//Filtro por CPF
			If !Empty( __CPF )
				cQuery += "INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
				cQuery += "   ON C9V.C9V_FILIAL = C91.C91_FILIAL "				
				cQuery += "  AND (C9V.C9V_ID = C91.C91_TRABAL OR C91.C91_TRABAL=' ')" 
				cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( __CPF ) + "' "
				cQuery += "  AND C9V.C9V_ATIVO = '1' "
				cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "
			EndIf

			cQuery += "INNER JOIN " + RetSqlName( "C9M" ) + " C9M "
			cQuery += "   ON C9M.C9M_FILIAL = C9L.C9L_FILIAL "
			cQuery += "  AND C9M.C9M_ID = C9L.C9L_ID "
			cQuery += "  AND C9M.C9M_VERSAO = C9L.C9L_VERSAO "
			cQuery += "  AND C9M.C9M_RECIBO = C9L.C9L_RECIBO "
			cQuery += "  AND C9M.C9M_ESTABE = C9L.C9L_ESTABE "
			cQuery += "  AND C9M.C9M_LOTACA = C9L.C9L_LOTACA "
			cQuery += "  AND C9M.C9M_TRABAL = C9L.C9L_TRABAL "
			cQuery += "  AND C9M.C9M_TPINSC = C9L.C9L_TPINSC "
			cQuery += "  AND C9M.C9M_NRINSC = C9L.C9L_NRINSC "
			cQuery += "  AND C9M.C9M_CODLOT = C9L.C9L_CODLOT "
			cQuery += "  AND C9M.C9M_DTRABA = C9L.C9L_DTRABA "
			cQuery += "  AND C9M.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "

			If lC8RCmpart
				cQuery += "  ON C8R.C8R_FILIAL = C9M.C9M_FILIAL "
			Else
				cQuery += "  ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
			EndIf
			
			cQuery += " AND C8R.C8R_ID = C9M.C9M_CODRUB "
			cQuery += " AND C8R.C8R_ATIVO = '1' "
			cQuery += " AND C8R.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
			cQuery += "  ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
			cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
			cQuery += " AND C89.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
			cQuery += "  ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
			cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
			cQuery += " AND C8T.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8R" ) + " C8RMV "
			cQuery += "	 ON C8RMV.C8R_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFilMV + " FILIAIS ) "
			cQuery += "	AND C8RMV.C8R_CODRUB = C9M.C9M_RUBRIC "
			cQuery += " AND C8RMV.C8R_IDTBRU = C9M.C9M_IDTABR "

			If Len( AllTrim( cPeriodo ) ) == 4 //Décimo Terceiro
				cQuery += " AND ( ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '12" + cPeriodo + "' ) ) "
			Else
				cQuery += " AND ( ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '" + cPeriodo + "' ) ) "
			EndIf

			cQuery += " AND C8RMV.C8R_ATIVO = '1' "
			cQuery += " AND C8RMV.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C89" ) + " C89MV "
			cQuery += "  ON C89MV.C89_FILIAL = '" + xFilial( "C89" ) + "' "
			cQuery += " AND C89MV.C89_ID = C8RMV.C8R_NATRUB "
			cQuery += " AND C89MV.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8T" ) + " C8TMV "
			cQuery += "  ON C8TMV.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
			cQuery += " AND C8TMV.C8T_ID = C8RMV.C8R_CINTPS "
			cQuery += " AND C8TMV.D_E_L_E_T_ = ' ' "

			cQuery += "WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) "

			If Len( AllTrim( cPeriodo ) ) == 4
				cQuery += "  AND C91.C91_PERAPU = '" + cPeriodo +  "' " //Décimo Terceiro
			Else
				cQuery += "  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' " //verificar or para 13° salário
			EndIf

			cQuery += "  AND C91.C91_NOMEVE = 'S1200' "
			cQuery += "  AND C91.C91_ATIVO = '1' "
			cQuery += "  AND C91.C91_EVENTO <> 'E' "
			cQuery += "  AND C91.D_E_L_E_T_ = ' ' "
			//Filtro por CPF
			If !Empty( __CPF )
				cQuery += "  AND C91.C91_CPF = '" + AllTrim( __CPF ) + "' "
			EndIf

			cQuery += "UNION ALL "

			cQuery += "SELECT DISTINCT C91.R_E_C_N_O_, C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO, C91.C91_INDAPU, C91.C91_PERAPU, C9R.C9R_PERREF  PERREF, C9R.C9R_CODRUB RUBPERANT, C91.C91_TRABAL, C91.C91_CPF, C91.C91_NOME, C91.C91_MV, C91.C91_PROTUL "
			cQuery += "     , C9P.C9P_ESTABE, C9P.C9P_LOTACA, C9P.C9P_TPINSC, C9P.C9P_NRINSC, C9P.C9P_CODLOT "
			cQuery += "     , C9Q.C9Q_TRABAL, C9Q.C9Q_DTRABA"
			cQuery += "     , T14.T14_CODCAT "
			cQuery += "     , C89.C89_CODIGO, C8T.C8T_CODIGO, C8R.C8R_INDTRB "
			cQuery += "     , C89MV.C89_CODIGO, C8TMV.C8T_CODIGO, C8RMV.C8R_INDTRB "
			cQuery += "     , C9R.C9R_VLRRUB, C8R.C8R_CODRUB, C9R.R_E_C_N_O_ C9R_RECONHECIMENTO "

			cQuery += "FROM " + RetSqlName( "C91" ) + " C91 "

			cQuery += "INNER JOIN " + RetSqlName( "T14" ) + " T14 "
			cQuery += "   ON T14.T14_FILIAL = C91.C91_FILIAL "
			cQuery += "  AND T14.T14_ID = C91.C91_ID "
			cQuery += "  AND T14.T14_VERSAO = C91.C91_VERSAO "
			cQuery += "  AND T14.D_E_L_E_T_ = ' ' "

			//Filtro por CPF
			If !Empty( __CPF )
				cQuery += "INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
				cQuery += "   ON C9V.C9V_FILIAL = C91.C91_FILIAL "
				cQuery += "  AND (C9V.C9V_ID = C91.C91_TRABAL OR C91.C91_TRABAL=' ')" 
				cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( __CPF ) + "' "
				cQuery += "  AND C9V.C9V_ATIVO = '1' "
				cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "
			EndIf

			cQuery += "INNER JOIN " + RetSqlName( "C9N" ) + " C9N "
			cQuery += "   ON C9N.C9N_FILIAL = T14.T14_FILIAL "
			cQuery += "  AND C9N.C9N_ID = T14.T14_ID "
			cQuery += "  AND C9N.C9N_VERSAO = T14.T14_VERSAO "
			cQuery += "  AND C9N.C9N_RECIBO = T14.T14_IDEDMD "
			cQuery += "  AND C9N.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "C9O" ) + " C9O "
			cQuery += "   ON C9O.C9O_FILIAL = C9N.C9N_FILIAL "
			cQuery += "  AND C9O.C9O_ID = C9N.C9N_ID "
			cQuery += "  AND C9O.C9O_VERSAO = C9N.C9N_VERSAO "
			cQuery += "  AND C9O.C9O_RECIBO = C9N.C9N_RECIBO "
			cQuery += "  AND C9O.C9O_DTACOR = C9N.C9N_DTACOR "
			cQuery += "  AND C9O.C9O_TPACOR = C9N.C9N_TPACOR "

			If TafColumnPos( "C9N_RELACO" )
				cQuery += "  AND C9O.C9O_COMPAC = C9N.C9N_RELACO "
			Else
				cQuery += "  AND C9O.C9O_COMPAC = C9N.C9N_COMPAC "
			EndIf

			cQuery += "  AND C9O.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "C9P" ) + " C9P "
			cQuery += "   ON C9P.C9P_FILIAL = C9O.C9O_FILIAL "
			cQuery += "  AND C9P.C9P_ID = C9O.C9O_ID "
			cQuery += "  AND C9P.C9P_VERSAO = C9O.C9O_VERSAO "
			cQuery += "  AND C9P.C9P_RECIBO = C9O.C9O_RECIBO "
			cQuery += "  AND C9P.C9P_DTACOR = C9O.C9O_DTACOR "
			cQuery += "  AND C9P.C9P_TPACOR = C9O.C9O_TPACOR "
			cQuery += "  AND C9P.C9P_COMPAC = C9O.C9O_COMPAC "
			cQuery += "  AND C9P.C9P_PERREF = C9O.C9O_PERREF "
			cQuery += "  AND C9P.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "C9Q" ) + " C9Q "
			cQuery += "   ON C9Q.C9Q_FILIAL = C9P.C9P_FILIAL "
			cQuery += "  AND C9Q.C9Q_ID = C9P.C9P_ID "
			cQuery += "  AND C9Q.C9Q_VERSAO = C9P.C9P_VERSAO "
			cQuery += "  AND C9Q.C9Q_RECIBO = C9P.C9P_RECIBO "
			cQuery += "  AND C9Q.C9Q_DTACOR = C9P.C9P_DTACOR "
			cQuery += "  AND C9Q.C9Q_TPACOR = C9P.C9P_TPACOR "
			cQuery += "  AND C9Q.C9Q_COMPAC = C9P.C9P_COMPAC "
			cQuery += "  AND C9Q.C9Q_PERREF = C9P.C9P_PERREF "
			cQuery += "  AND C9Q.C9Q_ESTABE = C9P.C9P_ESTABE "
			cQuery += "  AND C9Q.C9Q_LOTACA = C9P.C9P_LOTACA "
			cQuery += "  AND C9Q.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "C9R" ) + " C9R "
			cQuery += "   ON C9R.C9R_FILIAL = C9Q.C9Q_FILIAL "
			cQuery += "  AND C9R.C9R_ID = C9Q.C9Q_ID "
			cQuery += "  AND C9R.C9R_VERSAO = C9Q.C9Q_VERSAO "
			cQuery += "  AND C9R.C9R_RECIBO = C9Q.C9Q_RECIBO "
			cQuery += "  AND C9R.C9R_DTACOR = C9Q.C9Q_DTACOR "
			cQuery += "  AND C9R.C9R_TPACOR = C9Q.C9Q_TPACOR "
			cQuery += "  AND C9R.C9R_COMPAC = C9Q.C9Q_COMPAC "
			cQuery += "  AND C9R.C9R_PERREF = C9Q.C9Q_PERREF "
			cQuery += "  AND C9R.C9R_ESTABE = C9Q.C9Q_ESTABE "
			cQuery += "  AND C9R.C9R_LOTACA = C9Q.C9Q_LOTACA "
			cQuery += "  AND C9R.C9R_TRABAL = C9Q.C9Q_TRABAL "
			cQuery += "  AND C9R.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "

			If lC8RCmpart
				cQuery += "  ON C8R.C8R_FILIAL = C9R.C9R_FILIAL "
			Else
				cQuery += "  ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
			EndIf

			cQuery += " AND C8R.C8R_ID = C9R.C9R_CODRUB "
			cQuery += " AND C8R.C8R_ATIVO = '1' "
			cQuery += " AND C8R.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
			cQuery += "  ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
			cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
			cQuery += " AND C89.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
			cQuery += "  ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "	
			cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
			cQuery += " AND C8T.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8R" ) + " C8RMV "
			cQuery += "  ON C8RMV.C8R_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFilMV + " FILIAIS ) "
			cQuery += " AND C8RMV.C8R_CODRUB = C9R.C9R_RUBRIC "
			cQuery += " AND C8RMV.C8R_IDTBRU = C9R.C9R_IDTABR "

			If Len( AllTrim( cPeriodo ) ) == 4 //Décimo Terceiro
				cQuery += " AND ( ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '12" + cPeriodo + "' ) ) "
			Else
				cQuery += " AND ( ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '" + cPeriodo + "' ) ) "
			EndIf

			cQuery += " AND C8RMV.C8R_ATIVO = '1' "
			cQuery += " AND C8RMV.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C89" ) + " C89MV "
			cQuery += "  ON C89MV.C89_FILIAL = '" + xFilial( "C89" ) + "' "
			cQuery += " AND C89MV.C89_ID = C8RMV.C8R_NATRUB "
			cQuery += " AND C89MV.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8T" ) + " C8TMV "
			cQuery += "  ON C8TMV.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "		
			cQuery += " AND C8TMV.C8T_ID = C8RMV.C8R_CINTPS "
			cQuery += " AND C8TMV.D_E_L_E_T_ = ' ' "

			cQuery += "WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) "

			If Len( AllTrim( cPeriodo ) ) == 4
				cQuery += "  AND C91.C91_PERAPU = '" + cPeriodo +  "' " //Décimo Terceiro
			Else
				cQuery += "  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' " //verificar or para 13° salário
			EndIf

			cQuery += "  AND C91.C91_NOMEVE = 'S1200' "
			cQuery += "  AND C91.C91_ATIVO = '1' "
			cQuery += "  AND C91.C91_EVENTO <> 'E' "
			cQuery += "  AND C91.D_E_L_E_T_ = ' ' "
				
			//Filtro por CPF
			If !Empty( __CPF )
				cQuery += "  AND C91.C91_CPF = '" + AllTrim( __CPF ) + "' "
			EndIf

			cQuery += "ORDER BY C91_FILIAL, C91_ID, C91_VERSAO, C91_INDAPU, C91_PERAPU, PERREF, ESTABE, LOTACA, TPINSC, NRINSC, CODLOT, TRABAL, DTRABA "

			cQuery := ChangeQuery( cQuery )

			TCQuery cQuery New Alias (cAliasQry)

			( cAliasQry )->( DBGoTop() )

			While ( cAliasQry )->( !Eof() )
				cFilQry		:=	( cAliasQry )->C91_FILIAL
				cID			:=	( cAliasQry )->C91_ID
				cVersao		:=	( cAliasQry )->C91_VERSAO
				cIDEstab	:=	IIF(Empty(( cAliasQry )->ESTABE),fVerEstab(( cAliasQry )->ESTABE,( cAliasQry )->NRINSC,cFilQry),( cAliasQry )->ESTABE)
				cTbIdEst	:= ( cAliasQry )->ESTABE
				cMVTpEstab	:=	( cAliasQry )->TPINSC
				cMVEstab	:=	( cAliasQry )->NRINSC
				cIDLotac	:=	( cAliasQry )->LOTACA
				cMVLotac	:=	( cAliasQry )->CODLOT
				cIDTrabal	:=	( cAliasQry )->TRABAL
				cMVTrabal	:=	SubStr( (cAliasQry)->DTRABA, 1, nTMatric )
				cIDCateg	:=	( cAliasQry )->T14_CODCAT
				cIndApu		:=	( cAliasQry )->C91_INDAPU
				cC91Trabal	:=	( cAliasQry )->C91_TRABAL
				cCPF		:=	( cAliasQry )->C91_CPF				
				cNome		:=	( cAliasQry )->C91_NOME
				lMultVinc	:=	( cAliasQry )->C91_MV == "1"
				cRecibo		:=	( cAliasQry )->C91_PROTUL
				nRecnoQry	:=	( cAliasQry )->C91_RECONHECIMENTO
				

				While ( cAliasQry )->( C91_FILIAL + C91_ID + C91_VERSAO + ESTABE + TPINSC + NRINSC + LOTACA + CODLOT + TRABAL ) + SubStr( (cAliasQry)->DTRABA, 1, nTMatric ) + ( cAliasQry )->T14_CODCAT;
				== cFilQry + cID + cVersao + cTbIdEst + cMVTpEstab + cMVEstab + cIDLotac + cMVLotac + cIDTrabal + cMVTrabal + cIDCateg
					cNatureza	:=	Iif( lMultVinc, AllTrim( ( cAliasQry )->MVC89_CODIGO ), AllTrim( ( cAliasQry )->C89_CODIGO ) )
					cTipo		:=	Iif( lMultVinc, AllTrim( ( cAliasQry )->MVC8R_INDTRB ), AllTrim( ( cAliasQry )->C8R_INDTRB ) )
					cIncidPS	:=	Iif( lMultVinc, AllTrim( ( cAliasQry )->MVC8T_CODIGO ), AllTrim( ( cAliasQry )->C8T_CODIGO ) )

					If AllTrim( cIndApu ) == "1"
						
						If (cNatureza == "9201" .OR. cNatureza == "1623") .and. cIncidPS == "31"
							if cTipo == "1"
								nVlINSS -= ( cAliasQry )->VLRRUB
							Else
								nVlINSS += ( cAliasQry )->VLRRUB
							EndIf
							lAdd := .T.
						ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
							nBasINSS -= ( cAliasQry )->VLRRUB
							lRet := .T.
						ElseIf lTafGpeInss .And. cNatureza == "9901" .And. cTipo == "4"
							nBasINSS -= ( cAliasQry )->VLRRUB
							lRet := .T.
						ElseIf cNatureza == "9201" .and. cIncidPS == "32"
							nVlINSS13 += ( cAliasQry )->VLRRUB
							lAdd := .T.
						ElseIf cNatureza == "9901" .and. cTipo == "3"
							nBasINSS += ( cAliasQry )->VLRRUB
							lAdd := .T.
						ElseIf lTafGpeInss  .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
							nVlINSS -= ( cAliasQry )->VLRRUB
							lRet := .T. 
						ElseIf cNatureza == "1409" .and. cIncidPS == "51"
							nSalFam += ( cAliasQry )->VLRRUB
							lAdd := .T.
						ElseIf cNatureza == "4050" .and. cIncidPS == "21"
							nSalMat += ( cAliasQry )->VLRRUB
							lAdd := .T.
						ElseIf cNatureza == "4051" .and. cIncidPS == "22"
							nSalMat13 += ( cAliasQry )->VLRRUB
							lAdd := .T.													
						EndIf
					ElseIf AllTrim( cIndApu ) == "2"
						If cNatureza == "9201" .and. cIncidPS == "32"
							nVlINSS13 += ( cAliasQry )->VLRRUB
							lAdd := .T.
						ElseIf cNatureza == "9901" .and. cTipo == "3"
							nBasINSS13 += ( cAliasQry )->VLRRUB
							lAdd := .T.
						ElseIf cNatureza == "4051" .and. cIncidPS == "22"
							nSalMat13 += ( cAliasQry )->VLRRUB
							lAdd := .T.
						EndIf
					EndIf					


					( cAliasQry )->( DBSkip() )
				EndDo

				If lAdd .OR. __lSemVlr

					If !Empty(cCPF)

						C9V->(DbSetOrder(3))
						C9V->(MsSeek(xFilial("C9V", cFilQry) + cCPF + "1"))			

						If !Empty(cIDTrabal)

							aAreaC9V := C9V->(GetArea())

							C9V->(DbSetOrder(2))
							
							If !C9V->(MsSeek(xFilial("C9V", cFilQry) + cIDTrabal + "1"))	

								C9V->(RestArea(aAreaC9V))

							EndIf

						EndIf

					EndIf

					If lMultVinc
						//A tag matricula não é obrigatória no grupo de Remuneração para S-2300
						//Desta forma, caso não possua ID do Trabalhador na tabela filho, busco pelo ID da tabela principal
						If Empty(cCPF)
							C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL, C9V_ID, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
							If Empty( cMVTrabal )
								C9V->( MsSeek( xFilial( "C9V", cFilQry ) + cC91Trabal + "1" ) )
							Else
								C9V->( MsSeek( xFilial( "C9V", cFilQry ) + cMVTrabal + "1" ) )
							EndIf							
						EndIf
						cCPF	:=	C9V->C9V_CPF
						cNome	:=	C9V->C9V_NOME						

						C87->( MsSeek( xFilial( "C87", cFilQry ) + cIDCateg ) )

						cChaveHash := AllTrim( cMVEstab ) + "S-1200" + AllTrim( cCPF ) + AllTrim( cMVTrabal ) + AllTrim( C87->C87_CODIGO ) + AllTrim( cMVLotac )
						If TAFXHMGet( oArqTrb, cChaveHash, @aPos )
							aPos[1,ALIAS]										:=	"C91"
							aPos[1,RECNO]										:=	cValToChar( nRecnoQry )
							aPos[1,RECIBO_TRANSMISSAO]							:=	AllTrim( cRecibo )
							aPos[1,ESTABELECIMENTO]								:=	AllTrim( cMVEstab )
							aPos[1,CPF]											:=	AllTrim( cCPF )
							aPos[1,NOME]										:=	AllTrim( cNome )
							aPos[1,MATRICULA]									:=	AllTrim( cMVTrabal )
							aPos[1,CATEGORIA]									:=	AllTrim( C87->C87_CODIGO )
							aPos[1,LOTACAO]										:=	AllTrim( cMVLotac )
							aPos[1,EVENTO_ESOCIAL]								:=	"S-1200"
							aPos[1,TAF_BASE_INSS]								+=	nBasINSS
							aPos[1,TAF_VALOR_INSS]								+=	nVlINSS
							aPos[1,TAF_VALOR_SALARIO_FAMILIA]					+=	nSalFam
							aPos[1,TAF_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
							aPos[1,TAF_BASE_INSS_13_SALARIO]					+=	nBasINSS13
							aPos[1,TAF_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
							aPos[1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13
							aPos[1,OBSERVACAO]									:=	Iif( __lSemVlr .and. !lAdd, cObsSemInss, "" )
							aPos[1,TIPO_FUNCIONARIO]							:=	AllTrim( C9V->C9V_NOMEVE )

							TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
						Else
							TAFXHMAdd( oArqTrb, {	"C91",;												//ALIAS
													cValToChar( nRecnoQry ),;							//RECNO
													AllTrim( cRecibo ),;								//RECIBO_TRANSMISSAO
													AllTrim( cMVEstab ),;								//ESTABELECIMENTO
													AllTrim( cCPF ),;									//CPF
													AllTrim( cNome ),;									//NOME
													AllTrim( cMVTrabal ),;								//MATRICULA
													AllTrim( C87->C87_CODIGO ),;						//CATEGORIA
													AllTrim( cMVLotac ),;								//LOTACAO
													"S-1200",;											//EVENTO_ESOCIAL
													"",;												//TIPO_BASE_CALCULO
													0,;													//FOLHA_BASE_INSS
													0,;													//FOLHA_VALOR_INSS
													0,;													//FOLHA_VALOR_SALARIO_FAMILIA
													0,;													//FOLHA_VALOR_SALARIO_MATERNIDADE
													0,;													//FOLHA_BASE_INSS_13_SALARIO
													0,;													//FOLHA_VALOR_INSS_13_SALARIO
													0,;													//FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO
													nBasINSS,;											//TAF_BASE_INSS
													nVlINSS,;											//TAF_VALOR_INSS
													nSalFam,;											//TAF_VALOR_SALARIO_FAMILIA
													nSalMat,;											//TAF_VALOR_SALARIO_MATERNIDADE
													nBasINSS13,;										//TAF_BASE_INSS_13_SALARIO
													nVlINSS13,;											//TAF_VALOR_INSS_13_SALARIO
													nSalMat13,;											//TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO
													0,;													//GOVERNO_BASE_INSS
													0,;													//GOVERNO_VALOR_INSS
													0,;													//GOVERNO_VALOR_SALARIO_FAMILIA
													0,;													//GOVERNO_VALOR_SALARIO_MATERNIDADE
													0,;													//GOVERNO_BASE_INSS_13_SALARIO
													0,;													//GOVERNO_VALOR_INSS_13_SALARIO
													0,;													//GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO
													Iif( __lSemVlr .and. !lAdd, cObsSemInss, "" ),;		//OBSERVACAO
													AllTrim( C9V->C9V_NOMEVE ),;						//TIPO_FUNCIONARIO
													.F.,;												//GOVERNO_LOCALIZADO
													0 },;												//GOVERNO_BASE_SUSPENSAO
								ESTABELECIMENTO, 3,;
								EVENTO_ESOCIAL, 0,;
								CPF, 3,;
								MATRICULA, 3,;
								CATEGORIA, 3,;
								LOTACAO, 3 )
									
								cNrInscEst := AllTrim( cMVEstab )
						EndIf
					Else
						//A tag matricula não é obrigatória no grupo de Remuneração para S-2300
						//Desta forma, caso não possua ID do Trabalhador na tabela filho, busco pelo ID da tabela principal
						If Empty(cCPF)
							C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL, C9V_ID, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
							If Empty( cIDTrabal )
								C9V->( MsSeek( xFilial( "C9V", cFilQry ) + cC91Trabal + "1" ) )
							Else
								C9V->( MsSeek( xFilial( "C9V", cFilQry ) + cIDTrabal + "1" ) )
							EndIf
						EndIf
							
						cCPF	:=	C9V->C9V_CPF
						cNome	:=	C9V->C9V_NOME
						cCodCat := cIDCateg //GetCodCat( C9V->C9V_NOMEVE, C9V->C9V_FILIAL, C9V->C9V_ID, cPeriodo )
							
						If C9V->C9V_NOMEVE == "S2200"
							If Empty( cCodCat )
								CUP->( MsSeek( C9V->( xFilial( "CUP", C9V_FILIAL ) + C9V_ID + C9V_VERSAO + C9V_NOMEVE ) ) )
								cCodCat := CUP->CUP_CODCAT
							EndIf

							C87->( MsSeek( xFilial( "C87", C9V->C9V_FILIAL ) + cCodCat ) )
						ElseIf C9V->C9V_NOMEVE == "S2300"
							If Empty( cCodCat )
								cCodCat := C9V->C9V_CATCI
							EndIf

							C87->( MsSeek( xFilial( "C87", C9V->C9V_FILIAL ) + cCodCat ) )
						ElseIf C9V->C9V_NOMEVE == "TAUTO"
							C87->( MsSeek( xFilial( "C87", cFilQry ) + cCodCat ) )
						EndIf

						C92->( MsSeek( xFilial( "C92", cFilQry ) + cIDEstab + "1" ) )
						C99->( MsSeek( xFilial( "C99", cFilQry ) + cIDLotac + "1" ) )

						cChaveHash := AllTrim( C92->C92_NRINSC ) + "S-1200" + AllTrim( C9V->C9V_CPF ) + AllTrim( C9V->C9V_MATRIC ) + AllTrim( C87->C87_CODIGO ) + AllTrim( C99->C99_CODIGO )
						If TAFXHMGet( oArqTrb, cChaveHash, @aPos )
							aPos[1,ALIAS]										:=	"C91"
							aPos[1,RECNO]										:=	cValToChar( nRecnoQry )
							aPos[1,RECIBO_TRANSMISSAO]							:=	AllTrim( cRecibo )
							aPos[1,ESTABELECIMENTO]								:=	AllTrim( C92->C92_NRINSC )
							aPos[1,CPF]											:=	AllTrim( C9V->C9V_CPF )
							aPos[1,NOME]										:=	AllTrim( C9V->C9V_NOME )
							aPos[1,MATRICULA]									:=	AllTrim( C9V->C9V_MATRIC )
							aPos[1,CATEGORIA]									:=	AllTrim( C87->C87_CODIGO )
							aPos[1,LOTACAO]										:=	AllTrim( C99->C99_CODIGO )
							aPos[1,EVENTO_ESOCIAL]								:=	"S-1200"
							aPos[1,TAF_BASE_INSS]								+=	nBasINSS
							aPos[1,TAF_VALOR_INSS]								+=	nVlINSS
							aPos[1,TAF_VALOR_SALARIO_FAMILIA]					+=	nSalFam
							aPos[1,TAF_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
							aPos[1,TAF_BASE_INSS_13_SALARIO]					+=	nBasINSS13
							aPos[1,TAF_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
							aPos[1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13
							aPos[1,OBSERVACAO]									:=	Iif( __lSemVlr .and. !lAdd, cObsSemInss, "" )
							aPos[1,TIPO_FUNCIONARIO]							:=	AllTrim( C9V->C9V_NOMEVE )

							TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
						Else
							TAFXHMAdd( oArqTrb, {	"C91",;												//ALIAS
													cValToChar( nRecnoQry ),;							//RECNO
													AllTrim( cRecibo ),;								//RECIBO_TRANSMISSAO
													AllTrim( C92->C92_NRINSC ),;						//ESTABELECIMENTO
													AllTrim( C9V->C9V_CPF ),;							//CPF
													AllTrim( C9V->C9V_NOME ),;							//NOME
													AllTrim( C9V->C9V_MATRIC ),;						//MATRICULA
													AllTrim( C87->C87_CODIGO ),;						//CATEGORIA
													AllTrim( C99->C99_CODIGO ),;						//LOTACAO
													"S-1200",;											//EVENTO_ESOCIAL
													"",;												//TIPO_BASE_CALCULO
													0,;													//FOLHA_BASE_INSS
													0,;													//FOLHA_VALOR_INSS
													0,;													//FOLHA_VALOR_SALARIO_FAMILIA
													0,;													//FOLHA_VALOR_SALARIO_MATERNIDADE
													0,;													//FOLHA_BASE_INSS_13_SALARIO
													0,;													//FOLHA_VALOR_INSS_13_SALARIO
													0,;													//FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO
													nBasINSS,;											//TAF_BASE_INSS
													nVlINSS,;											//TAF_VALOR_INSS
													nSalFam,;											//TAF_VALOR_SALARIO_FAMILIA
													nSalMat,;											//TAF_VALOR_SALARIO_MATERNIDADE
													nBasINSS13,;										//TAF_BASE_INSS_13_SALARIO
													nVlINSS13,;											//TAF_VALOR_INSS_13_SALARIO
													nSalMat13,;											//TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO
													0,;													//GOVERNO_BASE_INSS
													0,;													//GOVERNO_VALOR_INSS
													0,;													//GOVERNO_VALOR_SALARIO_FAMILIA
													0,;													//GOVERNO_VALOR_SALARIO_MATERNIDADE
													0,;													//GOVERNO_BASE_INSS_13_SALARIO
													0,;													//GOVERNO_VALOR_INSS_13_SALARIO
													0,;													//GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO
													Iif( __lSemVlr .and. !lAdd, cObsSemInss, "" ),;		//OBSERVACAO
													AllTrim( C9V->C9V_NOMEVE ),;						//TIPO_FUNCIONARIO
													.F.,;												//GOVERNO_LOCALIZADO
													0 },;												//GOVERNO_BASE_SUSPENSAO
								ESTABELECIMENTO, 3,;
								EVENTO_ESOCIAL, 0,;
								CPF, 3,;
								MATRICULA, 3,;
								CATEGORIA, 3,;
								LOTACAO, 3 )
									
								cNrInscEst := AllTrim( C92->C92_NRINSC )
						EndIf
					EndIf
				EndIf
					
				cCPFTot := Iif( lMultVinc, cCPF, C9V->C9V_CPF )
				If TAFXHMGet( oArqTot, cCPFTot+"S-1200" , @aPosTot )
					aPosTot[1,TOTALIZADOR_TAF_VALOR_INSS] += ( nVlINSS + nVlINSS13 )
					aPosTot[1,NOME_TRABALHADOR] := C9V->C9V_NOME
						
					TAFXHMSet( oArqTot, aPosTot, cCPFTot+"S-1200" )
				Else
					TAFXHMAdd( oArqTot, {	cCPFTot,;
											AllTrim( C9V->C9V_NOME ),;
											"S-1200",;
											0 ,;
											nVlINSS + nVlINSS13,;
											0,;
											cNrInscEst},;
											CPF_TRABALHADOR, 3,;
											EVENTO_ESOCIAL_TOTALIZADOR, 0)
												
												
				EndIf
					
				If TAFXHMGet(oArqEst, cCPFTot+cNrInscEst+"S-1200", @aPosEstab )
					aPosEstab[1,TOTALIZADOR_ESTABELECIMENTO] += ( nVlINSS + nVlINSS13 )
						
					TAFXHMSet( oArqEst, aPosEstab, cCPFTot+cNrInscEst+"S-1200" )								
				Else
					TAFXHMAdd( oArqEst, {	cCPFTot+cNrInscEst+"S-1200",;
											nVlINSS + nVlINSS13},;
											CHAVE_TOT_ESTAB, 3)

				EndIf				
				If ( cAliasQry )->( C91_FILIAL + C91_ID + C91_VERSAO ) <> cFilQry + cID + cVersao
					TAFXHMList( oArqTrb, aArqTrb )
					If nContAdd <= Len( aArqTrb )
						nPosOrig := aScan(aArqTrb, {|x| (x[2][1][5]) == cCPF})
						If nPosOrig > 0
							cMatOrig := aArqTrb[nPosOrig][2][1][7]
						EndIf
						
						InsOrigC91( @oArqTrb, cFilQry, nRecnoQry, lMultVinc, cPeriodo, aFilMV , cCPFTot+"S-1200", @oArqTot, aFilMatriz, cMatOrig )
						Insert5001( @oArqTrb, cFilQry, "C91", cIndApu, cPeriodo, Iif( lMultVinc, cCPF, C9V->C9V_CPF ), cRecibo, aFilMatriz, lMultVinc, cCPFTot+"S-1200", @oArqTot, cChaveHash, cC91Trabal )
					
					EndIf

					nContAdd := Len( aArqTrb )
				EndIf
					
				nQtdProc ++
				SetIncPerc( oMsgRun, "S-1200", nQtdTotal, nQtdProc )

				cChaveHash	:=	""
				cFilQry		:=	""
				cID			:=	""
				cVersao		:=	""
				cIDEstab	:=	""
				cMVTpEstab	:=	""
				cMVEstab	:=	""
				cIDLotac	:=	""
				cMVLotac	:=	""
				cIDTrabal	:=	""
				cMVTrabal	:=	""
				cIDCateg	:=	""
				cIndApu		:=	""
				cC91Trabal	:=	""
				cCPF		:=	""
				cNome		:=	""
				cRecibo		:=	""
				cNatureza	:=	""
				cTipo		:=	""
				cIncidPS	:=	""
				cCodCat		:=	""
				cMatOrig	:=	""
				nRecnoQry	:=	0
				nBasINSS	:=	0
				nVlINSS		:=	0
				nSalFam		:=	0
				nSalMat		:=	0
				nBasINSS13	:=	0
				nVlINSS13	:=	0
				nSalMat13	:=	0
				nPosOrig	:= 	0
				lMultVinc	:=	.F.
				lAdd		:=	.F.
			EndDo

			( cAliasQry )->( DBCloseArea() )

		Else
			nQtdProc ++
			SetIncPerc( oMsgRun, "S-1200", nQtdTotal, nQtdProc )
		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MVQueryC8R
@type			function
@description	Realiza a consulta da Rubrica nas Filiais de mesma Raíz de CNPJ, devido ao mecanismo de Múltiplos Vínculos.
@author			Felipe C. Seolin
@since			02/09/2018
@version		1.0
@param			cCodRub		-	Código da Rubrica
@param			cIDTabRub	-	ID do Identificador de Tabela de Rubrica
@param			cPeriodo	-	Período de referência das informações
@param			aFilMV		-	Array de filiais a ser consideradas na cláusula IN do SQL para Múltiplos Vínculos
@param 			nTipPer     -   Tipo de período 1- Periodo Atual, 2-Perioro Anterior
@return			nRecno		-	Recno localizado para a Rubrica indicada
/*/
//---------------------------------------------------------------------
Static Function MVQueryC8R( cCodRub, cIDTabRub, cPeriodo, aFilMV, nTipPer )

	Local cAliasC8R := "rsR1203"
	Local cPer      := ""
	Local cQuery    := ""
	Local nPosRub   := 0
	Local nRecno    := 0

	If !FwIsInCallStack("TAF250XML")
		If Len(AllTrim(cPeriodo)) == 4 //Décimo Terceiro
			cPer :=  AllTrim(cPeriodo) + "12"
		ElseIf At("-", AllTrim(cPeriodo)) > 0
			cPer :=  StrTran(AllTrim(cPeriodo), "-")
		Else
			cPer :=	SubStr(cPeriodo,3,4) + SubStr(cPeriodo,1,2)
		EndIf
	Else
		cPer := cPeriodo
	EndIf

	If Type("cCachFilC8R") == "U"  

		cCachFilC8R := TAFCacheFil("C8R", aFilMV)

	EndIf

	cQuery := " SELECT C8R.R_E_C_N_O_ C8R_RECONHECIMENTO, " 
	cQuery += " SUBSTRING(C8R.C8R_DTINI, 3,4) || SUBSTRING(C8R.C8R_DTINI, 1,2) AS DTINI, "
	cQuery += " SUBSTRING(C8R.C8R_DTFIN, 3,4) || SUBSTRING(C8R.C8R_DTFIN, 1,2) AS DTFIN, "
	cQuery += " C8R.C8R_CODRUB, C8R.C8R_ATIVO "
	cQuery += " FROM " + RetSqlName( "C8R" ) + " C8R "
	cQuery += " WHERE C8R.C8R_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFilC8R + " FILIAIS ) "
	cQuery += " AND C8R.C8R_CODRUB = '" + cCodRub + "' "
	cQuery += " AND C8R.C8R_IDTBRU = '" + cIDTabRub + "' "
	cQuery += "	AND C8R.C8R_ATIVO  = '1' "
	cQuery += " AND C8R.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY DTINI DESC " //Alteração para considerar ambos os cenários.

	cQuery := ChangeQuery( cQuery )

	If Select(cAliasC8R) > 0
		(cAliasC8R)->(DbCloseArea())
	EndIf

	TCQuery cQuery New Alias (cAliasC8R)

	While ( cAliasC8R )->( !Eof() )

		nPosRub := 0

		If (cAliasC8R)->DTINI <= cPer .And. ( Empty((cAliasC8R)->DTFIN) .Or. (cAliasC8R)->DTFIN >= cPer)
			nRecno := ( cAliasC8R )->C8R_RECONHECIMENTO
			Exit
		EndIf

		( cAliasC8R )->( DbSkip() )
	End

	( cAliasC8R )->( DBCloseArea() )

Return nRecno

//---------------------------------------------------------------------
/*/{Protheus.doc} InsOrigC91
@type			function
@description	Função responsável por colher as informações do Evento S-1200 no XML de entrada.
@author			Felipe C. Seolin
@since			17/08/2018
@version		1.0
@param			oArqTrb		-	Objeto com as informações para conferência ( Referência )
@param			cFilEvt		-	Filial do registro do evento S-1200 no TAF
@param			nRecno		-	Recno do registro do evento S-1200 no TAF
@param			lMultVinc	-	Indica se o evento S-1200 é Múltiplo Vínculo
@param			cPeriodo	-	Período de referência das informações
@param			aFilMV		-	Array de filiais a ser consideradas na cláusula IN do SQL para Múltiplos Vínculos
@param			cChvTot		-	Chave do trabalhador para totalizador
@param			oArqTot		-	Objeto com as informações dos totalizadores para conferência ( Referência )
@param			cMatOrig	-	Matricula do trabalhador para conferência ( Referência )
/*/
//---------------------------------------------------------------------
Static Function InsOrigC91(oArqTrb, cFilEvt, nRecno, lMultVinc, cPeriodo, aFilMV, cChvTot, oArqTot, aFilMatriz, cMatOrig)

	Local aPos			:= {}
	Local aPosTot		:= {}
	Local aCodFil		:= {}
	Local aAreaC1E		:= C1E->(GetArea())
	Local aAreaC8R		:= C8R->(GetArea())
	Local aAreaC89		:= C89->(GetArea())
	Local aAreaC8T		:= C8T->(GetArea())
	Local cMatOrigem	:= ""
	Local cQuery		:= ""
	Local cXml			:= ""
	Local cIndApu		:= ""
	Local cNatureza		:= ""
	Local cTipo			:= ""
	Local cIncidPS		:= ""
	Local cIDTabR		:= ""
	Local cT14Path		:= ""
	Local cC9KPath		:= ""
	Local cC9LPath		:= ""
	Local cC9MPath		:= ""
	Local cC9NPath		:= ""
	Local cC9OPath		:= ""
	Local cC9PPath		:= ""
	Local cC9QPath		:= ""
	Local cC9RPath		:= ""
	Local cCodFil 		:= ""
	Local cC1EId		:= ""
	Local cMatricula	:= ""
	Local cAliasQry		:= "rsR1204"
	Local lAdd			:= .F.
	Local lTafGpeInss   := IIf(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F.)
	Local nT14			:= 0
	Local nC9K			:= 0
	Local nC9L			:= 0
	Local nC9M			:= 0
	Local nC9N			:= 0
	Local nC9O			:= 0
	Local nC9P			:= 0
	Local nC9Q			:= 0
	Local nC9R			:= 0
	Local nBasINSS		:= 0
	Local nVlINSS		:= 0
	Local nSalFam		:= 0
	Local nSalMat		:= 0
	Local nBasINSS13	:= 0
	Local nVlINSS13		:= 0
	Local nSalMat13		:= 0
	Local nFindFil		:= 0
	Local nRecnoC8R		:= 0
	Local oXml			:= Nil

	nFindFil := AScan(aTAFFil, {|x| x[1] == cFilEvt})

	If nFindFil > 0 .AND. ChkFile(aTAFFil[nFindFil][3])

		cCodFil := aTAFFil[nFindFil][2]	

	Else

		C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_
		If C1E->( MsSeek( xFilial( "C1E", cFilEvt ) + cFilEvt + "1" ) )
			cC1EId := C1E->C1E_ID
			aAdd(aCodFil,C1E->C1E_CODFIL)
		Else
			CR9->( DBSetOrder( 2 ) ) // CR9_FILIAL+CR9_CODFIL+CR9_ATIVO                                                                                                                                 
			If CR9->( MsSeek( xFilial( "CR9", cFilEvt ) + PadR( aFilMatriz[1]+cFilEvt, TamSX3( "CR9_CODFIL" )[1] ) + "1" ) )
				aAdd(aCodFil,CR9->CR9_CODFIL)
			EndIf
		EndIf

		// Busca as filiais De -> Para da CR9
		// Dessa forma tr?z todos os registros referentes a filial centralizadora contidos na TAFST2
		If !Empty(cC1EId)
			CR9->( DBSetOrder( 3 ) ) // CR9_FILIAL+CR9_ID+CR9_ATIVO                                                                                                                              
			If CR9->( MsSeek( xFilial( 'CR9') + cC1EId  + '1' ) )
				While CR9->(!EOF()) .And. ( xFilial('CR9') + cC1EId + '1' == CR9->CR9_FILIAL + CR9->CR9_ID + CR9->CR9_ATIVO )

					aAdd(aCodFil,AllTrim(CR9->CR9_CODFIL))

					CR9->(DbSkip())
				EndDo
			EndIf
		EndIf

		cCodFil := GenTAFFil(cFilEvt, aCodFil, nFindFil)
	
	EndIf

	If !Empty(cCodFil)

		cQuery := " SELECT TAFXERP.TAFKEY, MAX(TAFST2.R_E_C_N_O_) TAFST2_RECONHECIMENTO "
		cQuery += " FROM TAFXERP TAFXERP "
		cQuery += " INNER JOIN TAFST2 TAFST2 "
		cQuery += "   ON TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
		cQuery += "  AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
		cQuery += "  AND TAFST2.TAFFIL IN ( SELECT FILIAIS.TAFFIL FROM " + cCodFil + " FILIAIS ) "
		cQuery += "  AND TAFST2.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE TAFXERP.TAFALIAS = 'C91' "
		cQuery += "  AND TAFXERP.TAFRECNO = '" + cValToChar( nRecno ) + "' "
		cQuery += "  AND TAFXERP.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY	TAFXERP.TAFKEY "

		cQuery := ChangeQuery( cQuery )

		If Select(cAliasQry) > 0
			(cAliasQry)->(DbCloseArea())
		EndIf

		TCQuery cQuery New Alias (cAliasQry)

		( cAliasQry )->( DBGoTop() )

		While ( cAliasQry )->( !Eof() )

			C8R->( DBSetOrder( 3 ) ) //C8R_FILIAL, C8R_CODRUB, C8R_ATIVO, R_E_C_N_O_, D_E_L_E_T_
			C89->( DBSetOrder( 1 ) ) //C89_FILIAL, C89_ID, R_E_C_N_O_, D_E_L_E_T_
			C8T->( DBSetOrder( 1 ) ) //C8T_FILIAL, C8T_ID, R_E_C_N_O_, D_E_L_E_T_

			( cST2Alias )->( DBGoTo( ( cAliasQry )->TAFST2_RECONHECIMENTO ) )

			cXml := ( cST2Alias )->TAFMSG

			//Tiro os espaços em branco no início e final do XML e armazeno na variável
			cXml := EncodeUTF8( AllTrim( StrTran(cXml, ",",".") ))

			//Instancia objeto em oXml
			oXml := TXmlManager():New()

			If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
				cXml := StrTran( cXml, Chr( 13 ), "" )
				cXml := StrTran( cXml, Chr( 10 ), "" )

				//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
				If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
					cXml += ">"
				EndIf
			EndIf

			If !Empty( cXml ) .and. oXml:Parse( FTrocaPath( cXml, "eSocial" ) )
				oXml:bDecodeUTF8 := .T.
			EndIf

			cIndApu := oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideEvento/indApuracao" )

			//T14 - Informações do Recibo de Pagamento
			nT14 := 1
			cT14Path := "/eSocial/evtRemun/dmDev[" + cValToChar( nT14 ) + "]"
			While oXml:xPathHasNode( cT14Path )

				//C9K - Informações do Estabelecimento/Lotação
				nC9K := 1
				cC9KPath := cT14Path + "/infoPerApur/ideEstabLot[" + cValToChar( nC9K ) + "]"
				While oXml:xPathHasNode( cC9KPath )

					//C9L - Informações da Remuneração do Trabalhador
					nC9L := 1
					cC9LPath := cC9KPath + "/remunPerApur[" + cValToChar( nC9L ) + "]"
					While oXml:xPathHasNode( cC9LPath )

						//C9M - Informações das Rubricas
						nC9M := 1
						cC9MPath := cC9LPath + "/itensRemun[" + cValToChar( nC9M ) + "]"
						While oXml:xPathHasNode( cC9MPath )

							If lMultVinc
								cIDTabR := TAFIDTabRub( oXml:xPathGetNodeValue( cC9MPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cC9MPath + "/codRubr" ))
								nRecnoC8R := MVQueryC8R( oXml:xPathGetNodeValue( cC9MPath + "/codRubr" ), cIDTabR, cPeriodo, aFilMV, 1 )
								C8R->( DBGoTo( nRecnoC8R ) )
							Else
								cIDTabR := TAFIDTabRub( oXml:xPathGetNodeValue( cC9MPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cC9MPath + "/codRubr" ))
								nRecnoC8R := MVQueryC8R( oXml:xPathGetNodeValue( cC9MPath + "/codRubr" ), cIDTabR, cPeriodo, {xFilial("C8R")}, 1 )
								C8R->( DBGoTo( nRecnoC8R ) )
							EndIf

							If C8R->( !Eof() )

								If C89->( MsSeek( C8R->( xFilial( "C89", C8R_FILIAL ) + C8R_NATRUB ) ) )
									cNatureza := AllTrim( C89->C89_CODIGO )
								Else
									cNatureza := ""
								EndIf

								cTipo := C8R->C8R_INDTRB

								If C8T->( MsSeek( C8R->( xFilial( "C8T", C8R_FILIAL ) + C8R_CINTPS ) ) )
									cIncidPS := AllTrim( C8T->C8T_CODIGO )
								Else
									cIncidPS := ""
								EndIf

								If cIndApu == "1"
									If (cNatureza == "9201" .OR. cNatureza == "1623") .and. cIncidPS == "31"
										if cTipo == "1"
											nVlINSS -= Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										Else
											nVlINSS += Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										EndIf
										lAdd := .T.	
									ElseIf lTafGpeInss  .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
										nBasINSS -= Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.				
									ElseIf cNatureza == "9201" .and. cIncidPS == "32"
										nVlINSS13 += Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.								
									ElseIf cNatureza == "9901" .and. cTipo == "3"
										nBasINSS += Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.
									ElseIf lTafGpeInss  .And.  cNatureza == "9901" .and. cTipo == "4"
										nBasINSS -= Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.	
									ElseIf lTafGpeInss  .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
										nVlINSS -= Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.
									ElseIf cNatureza == "1409" .and. cIncidPS == "51"
										nSalFam += Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.
									ElseIf cNatureza == "4050" .and. cIncidPS == "21"
										nSalMat += Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.
									ElseIf cNatureza == "4051" .and. cIncidPS == "22"
										nSalMat13 += Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.								
									EndIf
								ElseIf cIndApu == "2"
									If cNatureza == "9201" .and. cIncidPS == "32"
										nVlINSS13 += Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.
									ElseIf cNatureza == "9901" .and. cTipo == "3"
										nBasINSS13 += Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.
									ElseIf cNatureza == "4051" .and. cIncidPS == "22"
										nSalMat13 += Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
										lAdd := .T.
									EndIf
								EndIf

							EndIf

							nC9M ++
							cC9MPath := cC9LPath + "/itensRemun[" + cValToChar( nC9M ) + "]"
						EndDo

						If lAdd .Or. __lSemVlr
							cMatricula := AllTrim(oXml:xPathGetNodeValue(cC9LPath + "/matricula")) 
							cMatOrigem := IIf(cMatOrig != Nil, cMatOrig, "")

							If TAFXHMGet( oArqTrb, AllTrim( oXml:xPathGetNodeValue( cC9KPath + "/nrInsc" ) ) + "S-1200" + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideTrabalhador/cpfTrab" ) ) + cMatOrigem + AllTrim( oXml:xPathGetNodeValue( cT14Path + "/codCateg" ) ) + AllTrim( oXml:xPathGetNodeValue( cC9KPath + "/codLotacao" ) ), @aPos );
								.Or. TAFXHMGet( oArqTrb, AllTrim( oXml:xPathGetNodeValue( cC9KPath + "/nrInsc" ) ) + "S-1200" + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideTrabalhador/cpfTrab" ) ) + cMatricula + AllTrim( oXml:xPathGetNodeValue( cT14Path + "/codCateg" ) ) + AllTrim( oXml:xPathGetNodeValue( cC9KPath + "/codLotacao" ) ), @aPos )

								aPos[1,FOLHA_BASE_INSS]								+=	nBasINSS
								aPos[1,FOLHA_VALOR_INSS]							+=	nVlINSS
								aPos[1,FOLHA_VALOR_SALARIO_FAMILIA]					+=	nSalFam
								aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
								aPos[1,FOLHA_BASE_INSS_13_SALARIO]					+=	nBasINSS13
								aPos[1,FOLHA_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
								aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13

								TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
							
							EndIf
							
							If TAFXHMGet( oArqTot, cChvTot , @aPosTot )
								aPosTot[1,TOTALIZADOR_FOLHA_VALOR_INSS]		+= nVlINSS + nVlINSS13
								TAFXHMSet( oArqTot, aPosTot, cChvTot )
							EndIf

							nBasINSS	:=	0
							nVlINSS		:=	0
							nSalFam		:=	0
							nSalMat		:=	0
							nBasINSS13	:=	0
							nVlINSS13	:=	0
							nSalMat13	:=	0
						EndIf

						lAdd := .F.

						nC9L ++
						cC9LPath := cC9KPath + "/remunPerApur[" + cValToChar( nC9L ) + "]"
					EndDo

					nC9K ++
					cC9KPath := cT14Path + "/infoPerApur/ideEstabLot[" + cValToChar( nC9K ) + "]"
				EndDo

				//Informações do Período de Apuração Anterior
				//C9N - Informações do Acordo
				nC9N := 1
				cC9NPath := cT14Path + "/infoPerAnt/ideADC[" + cValToChar( nC9N ) + "]"
				While oXml:xPathHasNode( cC9NPath )
					nC9O := 1
					cC9OPath := cC9NPath + "/idePeriodo[" + cValToChar( nC9O ) + "]"
					While oXml:xPathHasNode( cC9OPath )
						//C9P - Informações do Estabelecimento/Lotacão
						nC9P := 1
						cC9PPath := cC9OPath + "/ideEstabLot[" + cValToChar( nC9P ) + "]
						While oXml:xPathHasNode( cC9PPath )
							//C9Q - Informações da Remuneração
							nC9Q := 1
							cC9QPath := cC9PPath + "/remunPerAnt[" + cValToChar( nC9Q ) + "]"
							While oXml:xPathHasNode( cC9QPath )
								//C9R - Itens da Remuneração
								nC9R := 1
								cC9RPath := cC9QPath + "/itensRemun[" + cValToChar( nC9R ) + "]"
								While oXml:xPathHasNode( cC9RPath )

									If lMultVinc
										cIDTabR := TAFIDTabRub( oXml:xPathGetNodeValue( cC9RPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cC9RPath + "/codRubr" ))
										nRecnoC8R := MVQueryC8R( oXml:xPathGetNodeValue( cC9RPath + "/codRubr" ), cIDTabR, cPeriodo, aFilMV, 2 )
										C8R->( DBGoTo( nRecnoC8R ) )
									Else
										cIDTabR := TAFIDTabRub( oXml:xPathGetNodeValue( cC9RPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cC9RPath + "/codRubr" ))
										nRecnoC8R := MVQueryC8R( oXml:xPathGetNodeValue( cC9RPath + "/codRubr" ), cIDTabR, cPeriodo, {xFilial("C8R")}, 2 )
										C8R->( DBGoTo( nRecnoC8R ) )
									EndIf

									If C8R->( !Eof() )

										If C89->( MsSeek( C8R->( xFilial( "C89", C8R_FILIAL ) + C8R_NATRUB ) ) )
											cNatureza := AllTrim( C89->C89_CODIGO )
										Else
											cNatureza := ""
										EndIf

										cTipo := C8R->C8R_INDTRB

										If C8T->( MsSeek( C8R->( xFilial( "C8T", C8R_FILIAL ) + C8R_CINTPS ) ) )
											cIncidPS := AllTrim( C8T->C8T_CODIGO )
										Else
											cIncidPS := ""
										EndIf

										If cIndApu == "1"
											If cNatureza == "9201" .and. cIncidPS == "31"
												nVlINSS += Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.
											ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
												nBasINSS -= Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.
											ElseIf cNatureza == "9201" .and. cIncidPS == "32"
												nVlINSS13 += Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.										
											ElseIf cNatureza == "9901" .and. cTipo == "3"
												nBasINSS += Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.
											ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
												nVlINSS -= Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.
											ElseIf cNatureza == "1409" .and. cIncidPS == "51"
												nSalFam += Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.
											ElseIf cNatureza == "4050" .and. cIncidPS == "21"
												nSalMat += Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.
											ElseIf cNatureza == "4051" .and. cIncidPS == "22"
												nSalMat13 += Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.										
											EndIf
										ElseIf cIndApu == "2"
											If cNatureza == "9201" .and. cIncidPS == "32"
												nVlINSS13 += Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.
											ElseIf cNatureza == "9901" .and. cTipo == "3"
												nBasINSS13 += Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.
											ElseIf cNatureza == "4051" .and. cIncidPS == "22"
												nSalMat13 += Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
												lAdd := .T.
											EndIf
										EndIf

									EndIf

									nC9R ++
									cC9RPath := cC9QPath + "/itensRemun[" + cValToChar( nC9R ) + "]"
								EndDo

								If lAdd .Or. __lSemVlr
									cMatricula := AllTrim(oXml:xPathGetNodeValue(cC9QPath + "/matricula"))
									cMatOrigem := IIf(cMatOrig != Nil, cMatOrig, "")

									If TAFXHMGet( oArqTrb, AllTrim( oXml:xPathGetNodeValue( cC9PPath + "/nrInsc" ) ) + "S-1200" + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideTrabalhador/cpfTrab" ) ) + cMatOrigem + AllTrim( oXml:xPathGetNodeValue( cT14Path + "/codCateg" ) ) + AllTrim( oXml:xPathGetNodeValue( cC9PPath + "/codLotacao" ) ), @aPos );
										.Or. TAFXHMGet( oArqTrb, AllTrim( oXml:xPathGetNodeValue( cC9PPath + "/nrInsc" ) ) + "S-1200" + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideTrabalhador/cpfTrab" ) ) + cMatricula + AllTrim( oXml:xPathGetNodeValue( cT14Path + "/codCateg" ) ) + AllTrim( oXml:xPathGetNodeValue( cC9PPath + "/codLotacao" ) ), @aPos )
	
										aPos[1,FOLHA_BASE_INSS]								+=	nBasINSS
										aPos[1,FOLHA_VALOR_INSS]							+=	nVlINSS
										aPos[1,FOLHA_VALOR_SALARIO_FAMILIA]					+=	nSalFam
										aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
										aPos[1,FOLHA_BASE_INSS_13_SALARIO]					+=	nBasINSS13
										aPos[1,FOLHA_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
										aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13

										TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
																
									EndIf

									If TAFXHMGet( oArqTot, cChvTot , @aPosTot )
										aPosTot[1,TOTALIZADOR_FOLHA_VALOR_INSS] += nVlINSS + nVlINSS13
													
										TAFXHMSet( oArqTot, aPosTot, cChvTot )
									EndIf

									nBasINSS	:=	0
									nVlINSS		:=	0
									nSalFam		:=	0
									nSalMat		:=	0
									nBasINSS13	:=	0
									nVlINSS13	:=	0
									nSalMat13	:=	0
								EndIf

								lAdd := .F.

								nC9Q ++
								cC9QPath := cC9PPath + "/remunPerAnt[" + cValToChar( nC9Q ) + "]"
							EndDo

							nC9P ++
							cC9PPath := cC9OPath + "/ideEstabLot[" + cValToChar( nC9P ) + "]"
						EndDo

						nC9O ++
						cC9OPath := cC9NPath + "/idePeriodo[" + cValToChar( nC9O ) + "]"
					EndDo

					nC9N ++
					cC9NPath := cT14Path + "/infoPerAnt/ideADC[" + cValToChar( nC9N ) + "]"
				EndDo

				nT14 ++
				cT14Path := "/eSocial/evtRemun/dmDev[" + cValToChar( nT14 ) + "]"
			EndDo

			( cAliasQry )->( DBSkip() )
		EndDo

		( cAliasQry )->( DBCloseArea() )

		RestArea( aAreaC1E )
		RestArea( aAreaC8R )
		RestArea( aAreaC89 )
		RestArea( aAreaC8T )

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DataS2299
@type			function
@description	Função responsável por colher as informações do Evento S-2299 no TAF.
@author			Felipe C. Seolin
@since			21/08/2018
@version		1.0
@param			oMsgRun		-	Objeto do FWMsgRun
@param			oArqTrb		-	Objeto com as informações para conferência ( Referência )
@param			cPeriodo	-	Período de referência das informações
@param			aFilial		-	Filiais selecionadas para processamento
@param			lProtheus	-	Indica se a Origem dos dados parte do Protheus
@param			aFilMatriz	-	Array com as informações da Filial Matriz
@param			oArqTot		-	Objeto com as informações dos totalizadores para conferência ( Referência )
/*/
//---------------------------------------------------------------------
Static Function DataS2299(oMsgRun, oArqTrb, cPeriodo, aFilial, lProtheus, aFilMatriz, oArqTot)

	Local cAliasQry		:= ""
	Local cQuery		:= ""
	Local cFilQry		:= ""
	Local cID			:= ""
	Local cVersao		:= ""
	Local cIDEstab		:= ""
	Local cIDLotac		:= ""
	Local cIDTrabal		:= ""
	Local cRecibo		:= ""
	Local cNatureza		:= ""
	Local cTipo			:= ""
	Local cIncidPS		:= ""
	Local cCodCat		:= ""
	Local nRecnoQry		:= 0
	Local nBasINSS		:= 0
	Local nVlINSS		:= 0
	Local nSalFam		:= 0
	Local nSalMat		:= 0
	Local nBasINSS13	:= 0
	Local nVlINSS13		:= 0
	Local nSalMat13		:= 0
	Local nContAdd		:= 0
	Local nQtdTotal		:= 0
	Local nQtdProc		:= 0
	Local aPos			:= {}
	Local aArqTrb		:= {}
	Local lAdd			:= .F.
	Local cCPFTot		:= "" 
	Local cNrInscEst	:= ""
	Local aPosTot		:= {}
	Local aPosEstab		:= {}
	Local cChaveHash	:=	""
	Local lTafGpeInss   := IIF(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F. ) 

	If !Empty(aFilial)

		cAliasQry	:= "rsR1205"
		
		If Select(cAliasQry) > 0
			(cAliasQry)->(DbCloseArea())
		EndIf

		cQuery := "SELECT COUNT(*) QUANTIDADE "

		cQuery += "FROM " + RetSqlName( "CMD" ) + " CMD "

		cQuery += "WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) "

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
			cQuery += "  AND SUBSTR( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		Else
			cQuery += "  AND SUBSTRING( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		EndIf

		cQuery += "  AND CMD.CMD_ATIVO = '1' "
		cQuery += "  AND CMD.CMD_EVENTO <> 'E' "
		cQuery += "  AND CMD.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )

		TCQuery cQuery New Alias (cAliasQry)

		( cAliasQry )->( DBGoTop() )

		If ( cAliasQry )->( !Eof() )
			nQtdTotal := ( cAliasQry )->QUANTIDADE
		EndIf

		( cAliasQry )->( DBCloseArea() )

		If nQtdTotal > 0
			//Tabelas com as informações do Trabalhador
			C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL, C9V_ID, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
			CUP->( DBSetOrder( 4 ) ) //CUP_FILIAL, CUP_ID, CUP_VERSAO, CUP_NOMEVE, CUP_MATRIC, R_E_C_N_O_, D_E_L_E_T_
			C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações do Estabelecimento
			C92->( DBSetOrder( 5 ) ) //C92_FILIAL, C92_ID, C92_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações da Lotação
			C99->( DBSetOrder( 4 ) ) //C99_FILIAL, C99_ID, C99_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			cAliasQry := "rsR1206"

			If Select(cAliasQry) > 0
				(cAliasQry)->(DbCloseArea())
			EndIf

			cQuery := "SELECT DISTINCT CMD.R_E_C_N_O_ CMD_RECONHECIMENTO, CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO, CMD.CMD_DTDESL, CMD.CMD_FUNC, CMD.CMD_PROTUL "
			cQuery += "     , T3G.T3G_ESTABE ESTABE, T3G.T3G_LOTTRB LOTTRB "
			cQuery += "     , C89.C89_CODIGO, C8T.C8T_CODIGO, C8R.C8R_INDTRB "
			cQuery += "     , T05.T05_VLRRUB VLRRUB, T05.R_E_C_N_O_ T05_RECONHECIMENTO "

			cQuery += "FROM " + RetSqlName( "CMD" ) + " CMD "

			cQuery += "INNER JOIN " + RetSqlName( "T06" ) + " T06 "
			cQuery += "   ON T06.T06_FILIAL = CMD.CMD_FILIAL "
			cQuery += "  AND T06.T06_ID = CMD.CMD_ID "
			cQuery += "  AND T06.T06_VERSAO = CMD.CMD_VERSAO "
			cQuery += "  AND T06.D_E_L_E_T_ = ' ' "

			//Filtro por CPF
			If !Empty( __CPF )
				cQuery += "INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
				cQuery += "   ON C9V.C9V_FILIAL = CMD.CMD_FILIAL "
				cQuery += "  AND C9V.C9V_ID = CMD.CMD_FUNC "
				cQuery += "  AND C9V.C9V_ATIVO = '1' "
				cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( __CPF ) + "' "
				cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "
			EndIf

			cQuery += "INNER JOIN " + RetSqlName( "T3G" ) + " T3G "
			cQuery += "   ON T3G.T3G_FILIAL = T06.T06_FILIAL "
			cQuery += "  AND T3G.T3G_ID = T06.T06_ID "
			cQuery += "  AND T3G.T3G_VERSAO = T06.T06_VERSAO "
			cQuery += "  AND T3G.T3G_RECPAG = T06.T06_IDEDMD "
			cQuery += "  AND T3G.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "T05" ) + " T05 "
			cQuery += "   ON T05.T05_FILIAL = T3G.T3G_FILIAL "
			cQuery += "  AND T05.T05_ID = T3G.T3G_ID "
			cQuery += "  AND T05.T05_VERSAO = T3G.T3G_VERSAO "
			cQuery += "  AND T05.T05_RECPAG = T3G.T3G_RECPAG "
			cQuery += "  AND T05.T05_ESTABE = T3G.T3G_ESTABE "
			cQuery += "  AND T05.T05_LOTTRB = T3G.T3G_LOTTRB "
			cQuery += "  AND T05.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "

			If lC8RCmpart
				cQuery += "  ON C8R.C8R_FILIAL = T05.T05_FILIAL "
			Else
				cQuery += "  ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
			EndIf
				
			cQuery += " AND C8R.C8R_ID = T05.T05_CODRUB "
			cQuery += " AND C8R.C8R_ATIVO = '1' "
			cQuery += " AND C8R.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
			cQuery += "  ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
			cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
			cQuery += " AND C89.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
			cQuery += "  ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "	
			cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
			cQuery += " AND C8T.D_E_L_E_T_ = ' ' "

			cQuery += "WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) "

			If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
				cQuery += "  AND SUBSTR( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
			Else
				cQuery += "  AND SUBSTRING( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
			EndIf

			cQuery += "  AND CMD.CMD_ATIVO = '1' "
			cQuery += "  AND CMD.CMD_EVENTO <> 'E' "
			cQuery += "  AND CMD.D_E_L_E_T_ = ' ' "

			cQuery += "UNION ALL "

			cQuery += "SELECT DISTINCT CMD.R_E_C_N_O_, CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO, CMD.CMD_DTDESL, CMD.CMD_FUNC, CMD.CMD_PROTUL "
			cQuery += "     , T5Q.T5Q_ESTABE, T5Q.T5Q_LOTTRB "
			cQuery += "     , C89.C89_CODIGO, C8T.C8T_CODIGO, C8R.C8R_INDTRB, T5S.T5S_VLRRUB, T5S.R_E_C_N_O_ T5S_RECONHECIMENTO "

			cQuery += "FROM " + RetSqlName( "CMD" ) + " CMD "

			cQuery += "INNER JOIN " + RetSqlName( "T06" ) + " T06 "
			cQuery += "   ON T06.T06_FILIAL = CMD.CMD_FILIAL "
			cQuery += "  AND T06.T06_ID = CMD.CMD_ID "
			cQuery += "  AND T06.T06_VERSAO = CMD.CMD_VERSAO "
			cQuery += "  AND T06.D_E_L_E_T_ = ' ' "

			//Filtro por CPF
			If !Empty( __CPF )
				cQuery += "INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
				cQuery += "   ON C9V.C9V_FILIAL = CMD.CMD_FILIAL "
				cQuery += "  AND C9V.C9V_ID = CMD.CMD_FUNC "
				cQuery += "  AND C9V.C9V_ATIVO = '1' "
				cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( __CPF ) + "' "
				cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "
			EndIf

			cQuery += "INNER JOIN " + RetSqlName( "T5I" ) + " T5I "
			cQuery += "   ON T5I.T5I_FILIAL = T06.T06_FILIAL "
			cQuery += "  AND T5I.T5I_ID = T06.T06_ID "
			cQuery += "  AND T5I.T5I_VERSAO = T06.T06_VERSAO "
			cQuery += "  AND T5I.T5I_IDEDMD = T06.T06_IDEDMD "
			cQuery += "  AND T5I.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "T5J" ) + " T5J "
			cQuery += "   ON T5J.T5J_FILIAL = T5I.T5I_FILIAL "
			cQuery += "  AND T5J.T5J_ID = T5I.T5I_ID "
			cQuery += "  AND T5J.T5J_VERSAO = T5I.T5I_VERSAO "
			cQuery += "  AND T5J.T5J_IDEDMD = T5I.T5I_IDEDMD "
			cQuery += "  AND T5J.T5J_DTACCO = T5I.T5I_DTACCO "
			cQuery += "  AND T5J.T5J_TPACCO = T5I.T5I_TPACCO "
			cQuery += "  AND T5J.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "T5Q" ) + " T5Q "
			cQuery += "   ON T5Q.T5Q_FILIAL = T5J.T5J_FILIAL "
			cQuery += "  AND T5Q.T5Q_ID = T5J.T5J_ID "
			cQuery += "  AND T5Q.T5Q_VERSAO = T5J.T5J_VERSAO "
			cQuery += "  AND T5Q.T5Q_IDEDMD = T5J.T5J_IDEDMD "
			cQuery += "  AND T5Q.T5Q_DTACCO = T5J.T5J_DTACCO "
			cQuery += "  AND T5Q.T5Q_TPACCO = T5J.T5J_TPACCO "
			cQuery += "  AND T5Q.T5Q_PERREF = T5J.T5J_PERREF "
			cQuery += "  AND T5Q.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "T5S" ) + " T5S "
			cQuery += "   ON T5S.T5S_FILIAL = T5Q.T5Q_FILIAL "
			cQuery += "  AND T5S.T5S_ID = T5Q.T5Q_ID "
			cQuery += "  AND T5S.T5S_VERSAO = T5Q.T5Q_VERSAO "
			cQuery += "  AND T5S.T5S_IDEDMD = T5Q.T5Q_IDEDMD "
			cQuery += "  AND T5S.T5S_DTACCO = T5Q.T5Q_DTACCO "
			cQuery += "  AND T5S.T5S_TPACCO = T5Q.T5Q_TPACCO "
			cQuery += "  AND T5S.T5S_PERREF = T5Q.T5Q_PERREF "
			cQuery += "  AND T5S.T5S_ESTABE = T5Q.T5Q_ESTABE "
			cQuery += "  AND T5S.T5S_LOTTRB = T5Q.T5Q_LOTTRB "
			cQuery += "  AND T5S.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "

			If lC8RCmpart
				cQuery += "  ON C8R.C8R_FILIAL = T5S.T5S_FILIAL "
			Else
				cQuery += "  ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
			EndIf
				
			cQuery += " AND C8R.C8R_ID = T5S.T5S_CODRUB "
			cQuery += " AND C8R.C8R_ATIVO = '1' "
			cQuery += " AND C8R.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
			cQuery += "  ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
			cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
			cQuery += " AND C89.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
			cQuery += "  ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
			cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
			cQuery += " AND C8T.D_E_L_E_T_ = ' ' "

			cQuery += "WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) "

			If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
				cQuery += "  AND SUBSTR( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
			Else
				cQuery += "  AND SUBSTRING( CMD.CMD_DTDESL, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
			EndIf

			cQuery += "  AND CMD.CMD_ATIVO = '1' "
			cQuery += "  AND CMD.CMD_EVENTO <> 'E' "
			cQuery += "  AND CMD.D_E_L_E_T_ = ' ' "

			cQuery += "ORDER BY CMD_FILIAL, CMD_ID, CMD_VERSAO, CMD_DTDESL, ESTABE, LOTTRB "

			cQuery := ChangeQuery( cQuery )

			TCQuery cQuery New Alias (cAliasQry)

			( cAliasQry )->( DBGoTop() )

			While ( cAliasQry )->( !Eof() )
				cFilQry		:=	( cAliasQry )->CMD_FILIAL
				cID			:=	( cAliasQry )->CMD_ID
				cVersao		:=	( cAliasQry )->CMD_VERSAO
				cIDEstab	:=	( cAliasQry )->ESTABE
				cIDLotac	:=	( cAliasQry )->LOTTRB
				cIDTrabal	:=	( cAliasQry )->CMD_FUNC
				cRecibo		:=	( cAliasQry )->CMD_PROTUL
				nRecnoQry	:=	( cAliasQry )->CMD_RECONHECIMENTO

				While ( cAliasQry )->( CMD_FILIAL + CMD_ID + CMD_VERSAO + ESTABE + LOTTRB ) == cFilQry + cID + cVersao + cIDEstab + cIDLotac
					cNatureza	:=	AllTrim( ( cAliasQry )->C89_CODIGO )
					cTipo		:=	AllTrim( ( cAliasQry )->C8R_INDTRB )
					cIncidPS	:=	AllTrim( ( cAliasQry )->C8T_CODIGO )

					If cNatureza == "9201" .and. cIncidPS == "31"
						if cTipo == "1"
							nVlINSS -= ( cAliasQry )->VLRRUB
						Else
							nVlINSS += ( cAliasQry )->VLRRUB
						EndIf
						lAdd := .T.
					ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
						nBasINSS -= ( cAliasQry )->VLRRUB
						lAdd := .T.	
					ElseIf cNatureza == "9201" .and. cIncidPS == "32"
						nVlINSS13 += ( cAliasQry )->VLRRUB
						lAdd := .T.
					ElseIf cNatureza == "9901" .and. cTipo == "3"
						nBasINSS += ( cAliasQry )->VLRRUB
						//nBasINSS13 += ( cAliasQry )->VLRRUB
						lAdd := .T.
					ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
						nVlINSS -= ( cAliasQry )->VLRRUB
						lAdd := .T. 
					ElseIf cNatureza == "1409" .and. cIncidPS == "51"
						nSalFam += ( cAliasQry )->VLRRUB
						lAdd := .T.
					ElseIf cNatureza == "4050" .and. cIncidPS == "21"
						nSalMat += ( cAliasQry )->VLRRUB
						lAdd := .T.
					ElseIf cNatureza == "4051" .and. cIncidPS == "22"
						nSalMat13 += ( cAliasQry )->VLRRUB
						lAdd := .T.
					EndIf

					( cAliasQry )->( DBSkip() )
				EndDo

				If lAdd .or. __lSemVlr
					C9V->( MsSeek( xFilial( "C9V", cFilQry ) + cIDTrabal + "1" ) )

					cCodCat := GetCodCat( C9V->C9V_NOMEVE, C9V->C9V_FILIAL, C9V->C9V_ID, cPeriodo )

					If C9V->C9V_NOMEVE == "S2200"
						If Empty( cCodCat )
							CUP->( MsSeek( C9V->( xFilial( "CUP", C9V_FILIAL ) + C9V_ID + C9V_VERSAO + C9V_NOMEVE ) ) )
							cCodCat := CUP->CUP_CODCAT
						EndIf

						C87->( MsSeek( xFilial( "C87", C9V->C9V_FILIAL ) + cCodCat ) )
					ElseIf C9V->C9V_NOMEVE == "S2300"
						If Empty( cCodCat )
							cCodCat := C9V->C9V_CATCI
						EndIf

						C87->( MsSeek( xFilial( "C87", C9V->C9V_FILIAL ) + cCodCat ) )
					EndIf

					C92->( MsSeek( xFilial( "C92", cFilQry ) + cIDEstab + "1" ) )
					C99->( MsSeek( xFilial( "C99", cFilQry ) + cIDLotac + "1" ) )

					cChaveHash := AllTrim( C92->C92_NRINSC ) + "S-2299" + AllTrim( C9V->C9V_CPF ) + AllTrim( C9V->C9V_MATRIC ) + AllTrim( C87->C87_CODIGO ) + AllTrim( C99->C99_CODIGO )
					If TAFXHMGet( oArqTrb, cChaveHash, @aPos )
						aPos[1,ALIAS]										:=	"CMD"
						aPos[1,RECNO]										:=	cValToChar( nRecnoQry )
						aPos[1,RECIBO_TRANSMISSAO]							:=	AllTrim( cRecibo )
						aPos[1,ESTABELECIMENTO]								:=	AllTrim( C92->C92_NRINSC )
						aPos[1,CPF]											:=	AllTrim( C9V->C9V_CPF )
						aPos[1,NOME]										:=	AllTrim( C9V->C9V_NOME )
						aPos[1,MATRICULA]									:=	AllTrim( C9V->C9V_MATRIC )
						aPos[1,CATEGORIA]									:=	AllTrim( C87->C87_CODIGO )
						aPos[1,LOTACAO]										:=	AllTrim( C99->C99_CODIGO )
						aPos[1,EVENTO_ESOCIAL]								:=	"S-2299"
						aPos[1,TAF_BASE_INSS]								+=	nBasINSS
						aPos[1,TAF_VALOR_INSS]								+=	nVlINSS
						aPos[1,TAF_VALOR_SALARIO_FAMILIA]					+=	nSalFam
						aPos[1,TAF_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
						aPos[1,TAF_BASE_INSS_13_SALARIO]					+=	nBasINSS13
						aPos[1,TAF_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
						aPos[1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13
						aPos[1,OBSERVACAO]									:=	"A base de cálculo para os eventos de Desligamento ( S-2299 ) e Término de Vinculo ( S-2399 ) são consolidados na Folha e no TAF"
						aPos[1,TIPO_FUNCIONARIO]							:=	AllTrim( C9V->C9V_NOMEVE )

						TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
					Else
						TAFXHMAdd( oArqTrb, {	"CMD",;							//ALIAS
												cValToChar( nRecnoQry ),;		//RECNO
												AllTrim( cRecibo ),;			//RECIBO_TRANSMISSAO
												AllTrim( C92->C92_NRINSC ),;	//ESTABELECIMENTO
												AllTrim( C9V->C9V_CPF ),;		//CPF
												AllTrim( C9V->C9V_NOME ),;		//NOME
												AllTrim( C9V->C9V_MATRIC ),;	//MATRICULA
												AllTrim( C87->C87_CODIGO ),;	//CATEGORIA
												AllTrim( C99->C99_CODIGO ),;	//LOTACAO
												"S-2299",;						//EVENTO_ESOCIAL
												"",;							//TIPO_BASE_CALCULO
												0,;								//FOLHA_BASE_INSS
												0,;								//FOLHA_VALOR_INSS
												0,;								//FOLHA_VALOR_SALARIO_FAMILIA
												0,;								//FOLHA_VALOR_SALARIO_MATERNIDADE
												0,;								//FOLHA_BASE_INSS_13_SALARIO
												0,;								//FOLHA_VALOR_INSS_13_SALARIO
												0,;								//FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO
												nBasINSS,;						//TAF_BASE_INSS
												nVlINSS,;						//TAF_VALOR_INSS
												nSalFam,;						//TAF_VALOR_SALARIO_FAMILIA
												nSalMat,;						//TAF_VALOR_SALARIO_MATERNIDADE
												nBasINSS13,;					//TAF_BASE_INSS_13_SALARIO
												nVlINSS13,;						//TAF_VALOR_INSS_13_SALARIO
												nSalMat13,;						//TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO
												0,;								//GOVERNO_BASE_INSS
												0,;								//GOVERNO_VALOR_INSS
												0,;								//GOVERNO_VALOR_SALARIO_FAMILIA
												0,;								//GOVERNO_VALOR_SALARIO_MATERNIDADE
												0,;								//GOVERNO_BASE_INSS_13_SALARIO
												0,;								//GOVERNO_VALOR_INSS_13_SALARIO
												0,;								//GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO
												"A base de cálculo para os eventos de Desligamento ( S-2299 ) e Término de Vinculo ( S-2399 ) são consolidados na Folha e no TAF",;	//OBSERVACAO
												AllTrim( C9V->C9V_NOMEVE ),;	//TIPO_FUNCIONARIO
												.F.,;							//GOVERNO_LOCALIZADO
												0 },;                           //GOVERNO_BASE_SUSPENSAO
							ESTABELECIMENTO, 3,;
							EVENTO_ESOCIAL, 0,;
							CPF, 3,;
							MATRICULA, 3,;
							CATEGORIA, 3,;
							LOTACAO, 3 )
					EndIf
				EndIf
					
				cCPFTot    := AllTrim( C9V->C9V_CPF ) 
				cNrInscEst := AllTrim( C92->C92_NRINSC )
				If TAFXHMGet( oArqTot, cCPFTot+"S-2299" , @aPosTot )
					aPosTot[1,TOTALIZADOR_TAF_VALOR_INSS] += ( nVlINSS + nVlINSS13 )
						
					TAFXHMSet( oArqTot, aPosTot, cCPFTot+"S-2299" )
				Else
					TAFXHMAdd( oArqTot, {	cCPFTot,;
											AllTrim( C9V->C9V_NOME ),;
											"S-2299",;
											0 ,;
											nVlINSS + nVlINSS13,;
											0,;
											cNrInscEst},;
											CPF_TRABALHADOR, 3,;
											EVENTO_ESOCIAL_TOTALIZADOR, 0)
												
												
				EndIf
					
				If TAFXHMGet(oArqEst, cCPFTot+cNrInscEst+"S-2299", @aPosEstab )
					aPosEstab[1,TOTALIZADOR_ESTABELECIMENTO] += ( nVlINSS + nVlINSS13 )
						
					TAFXHMSet( oArqEst, aPosEstab, cCPFTot+cNrInscEst+"S-2299" )								
				Else
					TAFXHMAdd( oArqEst, {	cCPFTot+cNrInscEst+"S-2299",;
											nVlINSS + nVlINSS13 },;
											CHAVE_TOT_ESTAB, 3)

				EndIf

				If ( cAliasQry )->( CMD_FILIAL + CMD_ID + CMD_VERSAO ) <> cFilQry + cID + cVersao
					TAFXHMList( oArqTrb, aArqTrb )
					If nContAdd <= Len( aArqTrb )
						If !lProtheus .Or. ( lProtheus .And. StoD(Substr(cPeriodo,3,6)+Substr(cPeriodo,1,2) + "01" ) >= StoD("20191101") )
							InsOrigCMD( @oArqTrb, cFilQry, nRecnoQry, cCPFTot+"S-2299", @oArqTot, cPeriodo )
						EndIf
						Insert5001( @oArqTrb, cFilQry, "CMD", "1", cPeriodo, C9V->C9V_CPF, cRecibo, aFilMatriz,, cCPFTot+"S-2299", @oArqTot, cChaveHash )
					EndIf

					nContAdd := Len( aArqTrb )
				EndIf

				nQtdProc ++
				SetIncPerc( oMsgRun, "S-2299", nQtdTotal, nQtdProc )

				cChaveHash	:=	""
				cFilQry		:=	""
				cID			:=	""
				cVersao		:=	""
				cIDEstab	:=	""
				cIDLotac	:=	""
				cIDTrabal	:=	""
				cRecibo		:=	""
				cNatureza	:=	""
				cTipo		:=	""
				cIncidPS	:=	""
				cCodCat		:=	""
				nRecnoQry	:=	0
				nBasINSS	:=	0
				nVlINSS		:=	0
				nSalFam		:=	0
				nSalMat		:=	0
				nBasINSS13	:=	0
				nVlINSS13	:=	0
				nSalMat13	:=	0
				lAdd		:=	.F.
			EndDo

			( cAliasQry )->( DBCloseArea() )

		Else
			nQtdProc ++
			SetIncPerc( oMsgRun, "S-2299", nQtdTotal, nQtdProc )
		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} InsOrigCMD
@type			function
@description	Função responsável por colher as informações do Evento S-2299 no XML de entrada.
@author			Felipe C. Seolin
@since			21/08/2018
@version		1.0
@param			oArqTrb	-	Objeto com as informações para conferência ( Referência )
@param			cFilEvt	-	Filial do registro do evento S-2299 no TAF
@param			nRecno	-	Recno do registro do evento S-2299 no TAF
@param			cChvTot -	Chave do trabalhador para totalizador
@param			oArqTot -	Objeto com as informações dos totalizadores para conferência ( Referência )
/*/
//---------------------------------------------------------------------
Static Function InsOrigCMD( oArqTrb, cFilEvt, nRecno, cChvTot, oArqTot, cPeriodo )

Local oXml			:=	Nil
Local cAliasQry		:=	"rsR1207"
Local cQuery		:=	""
Local cXml			:=	""
Local cNatureza		:=	""
Local cTipo			:=	""
Local cIncidPS		:=	""
Local cT06Path		:=	""
Local cT3GPath		:=	""
Local cT05Path		:=	""
Local cT5IPath		:=	""
Local cT5JPath		:=	""
Local cT5QPath		:=	""
Local cT5SPath		:=	""
Local nT06			:=	0
Local nT3G			:=	0
Local nT05			:=	0
Local nT5I			:=	0
Local nT5J			:=	0
Local nT5Q			:=	0
Local nT5S			:=	0
Local nBasINSS		:=	0
Local nVlINSS		:=	0
Local nSalFam		:=	0
Local nSalMat		:=	0
Local nBasINSS13	:=	0
Local nVlINSS13		:=	0
Local nSalMat13		:=	0
Local nC9VCPF		:=	TamSX3( "C9V_CPF" )[1]
Local nC9VMATRIC	:=	TamSX3( "C9V_MATRIC" )[1]
Local aPos			:=	{}
Local aAreaC1E		:=	C1E->( GetArea() )
Local aAreaC9V		:=	C9V->( GetArea() )
Local aAreaCUP		:=	CUP->( GetArea() )
Local aAreaC87		:=	C87->( GetArea() )
Local aAreaC8R		:=	C8R->( GetArea() )
Local aAreaC89		:=	C89->( GetArea() )
Local aAreaC8T		:=	C8T->( GetArea() )
Local lAdd			:=	.F.
Local aPosTot		:= {}
Local cIDTabR 		:= ""
Local nRecnoC8R		:= 0
Local cCodCat       := ""
Local lTafGpeInss   := IIF(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F. )

C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_
C1E->( MsSeek( xFilial( "C1E", cFilEvt ) + cFilEvt + "1" ) )

cQuery := "SELECT TAFST2.R_E_C_N_O_ TAFST2_RECONHECIMENTO "
cQuery += "FROM TAFXERP TAFXERP "
cQuery += "INNER JOIN TAFST2 TAFST2 "
cQuery += "   ON TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
cQuery += "  AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
cQuery += "  AND TAFST2.TAFFIL = '" + C1E->C1E_CODFIL + "' "
cQuery += "  AND TAFST2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE TAFXERP.TAFALIAS = 'CMD' "
cQuery += "  AND TAFXERP.TAFRECNO = '" + cValToChar( nRecno ) + "' "
cQuery += "  AND TAFXERP.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY TAFXERP.R_E_C_N_O_ DESC "

cQuery := ChangeQuery( cQuery )

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf

TCQuery cQuery New Alias (cAliasQry)

( cAliasQry )->( DBGoTop() )

If ( cAliasQry )->( !Eof() )

	C9V->( DBSetOrder( 10 ) ) //C9V_FILIAL, C9V_CPF, C9V_MATRIC, C9V_NOMEVE, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	CUP->( DBSetOrder( 4 ) ) //CUP_FILIAL, CUP_ID, CUP_VERSAO, CUP_NOMEVE, CUP_MATRIC, R_E_C_N_O_, D_E_L_E_T_
	C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_
	C8R->( DBSetOrder( 3 ) ) //C8R_FILIAL, C8R_CODRUB, C8R_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C89->( DBSetOrder( 1 ) ) //C89_FILIAL, C89_ID, R_E_C_N_O_, D_E_L_E_T_
	C8T->( DBSetOrder( 1 ) ) //C8T_FILIAL, C8T_ID, R_E_C_N_O_, D_E_L_E_T_

	( cST2Alias )->( DBGoTo( ( cAliasQry )->TAFST2_RECONHECIMENTO ) )

	cXml := ( cST2Alias )->TAFMSG

	//Tiro os espaços em branco no início e final do XML e armazeno na variável
	cXml := EncodeUTF8( AllTrim(  StrTran(cXml, ",",".") ) )

	//Instancia objeto em oXml
	oXml := TXmlManager():New()

	If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
		cXml := StrTran( cXml, Chr( 13 ), "" )
		cXml := StrTran( cXml, Chr( 10 ), "" )

		//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
		If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
			cXml += ">"
		EndIf
	EndIf

	If !Empty( cXml ) .and. oXml:Parse( FTrocaPath( cXml, "eSocial" ) )
		oXml:bDecodeUTF8 := .T.
	EndIf

	//T06 - Informações do Recibo de Pagamento
	nT06 := 1
	cT06Path := "/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev[" + cValToChar( nT06 ) + "]"
	While oXml:xPathHasNode( cT06Path )

		//T3G - Informações do Estabelecimento/Lotação
		nT3G := 1
		cT3GPath := cT06Path + "/infoPerApur/ideEstabLot[" + cValToChar( nT3G ) + "]"
		While oXml:xPathHasNode( cT3GPath )

			//T05 - Informações das Rubricas
			nT05 := 1
			cT05Path := cT3GPath + "/detVerbas[" + cValToChar( nT05 ) + "]"
			While oXml:xPathHasNode( cT05Path )

				nRecnoC8R := 0
				cIDTabR := ""

				cIDTabR := TAFIDTabRub( oXml:xPathGetNodeValue( cT05Path + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cT05Path + "/codRubr" ))
            	nRecnoC8R := MVQueryC8R( oXml:xPathGetNodeValue( cT05Path + "/codRubr" ), cIDTabR, cPeriodo, {xFilial("C8R")}, 1 )
                C8R->( DBGoTo( nRecnoC8R ) )

				If C8R->( !Eof() )

					If C89->( MsSeek( C8R->( xFilial( "C89", C8R_FILIAL ) + C8R_NATRUB ) ) )
						cNatureza := AllTrim( C89->C89_CODIGO )
					Else
						cNatureza := ""
					EndIf

					cTipo := C8R->C8R_INDTRB

					If C8T->( MsSeek( C8R->( xFilial( "C8T", C8R_FILIAL ) + C8R_CINTPS ) ) )
						cIncidPS := AllTrim( C8T->C8T_CODIGO )
					Else
						cIncidPS := ""
					EndIf

					If cNatureza == "9201" .and. cIncidPS == "31"
						nVlINSS += Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
						nBasINSS -= Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))
						lAdd := .T.	
					ElseIf cNatureza == "9201" .and. cIncidPS == "32"
						nVlINSS13 += Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf cNatureza == "9901" .and. cTipo == "3"
						nBasINSS += Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
						nVlINSS -= Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))
						lAdd := .T. 
					ElseIf cNatureza == "1409" .and. cIncidPS == "51"
						nSalFam += Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf cNatureza == "4050" .and. cIncidPS == "21"
						nSalMat += Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf cNatureza == "4051" .and. cIncidPS == "22"
						nSalMat13 += Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))
						lAdd := .T.
					EndIf

				EndIf

				nT05 ++
				cT05Path := cT3GPath + "/detVerbas[" + cValToChar( nT05 ) + "]"
			EndDo

			If lAdd .or. __lSemVlr
				
				C9V->( MsSeek( xFilial( "C9V", cFilEvt ) + PadR( oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/cpfTrab" ), nC9VCPF ) + PadR( oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/matricula" ), nC9VMATRIC ) + "S2200" + "1" ) ) //Verificar xFilial
				
				cCodCat := GetCodCat( C9V->C9V_NOMEVE, C9V->C9V_FILIAL, C9V->C9V_ID, cPeriodo )

				If Empty( cCodCat )
					cCodCat := C9V->C9V_CATCI
				EndIf
				
				C87->( MsSeek( CUP->( xFilial( "C87", cFilEvt ) + cCodCat ) ) )

				If TAFXHMGet( oArqTrb, AllTrim( oXml:xPathGetNodeValue( cT3GPath + "/nrInsc" ) ) + "S-2299" + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/cpfTrab" ) ) + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/matricula" ) ) + AllTrim( C87->C87_CODIGO ) + AllTrim( oXml:xPathGetNodeValue( cT3GPath + "/codLotacao" ) ), @aPos )
					aPos[1,FOLHA_BASE_INSS]								+=	nBasINSS
					aPos[1,FOLHA_VALOR_INSS]							+=	nVlINSS
					aPos[1,FOLHA_VALOR_SALARIO_FAMILIA]					+=	nSalFam
					aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
					aPos[1,FOLHA_BASE_INSS_13_SALARIO]					+=	nBasINSS13
					aPos[1,FOLHA_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
					aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13					
					
					TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
						
				EndIf

				If TAFXHMGet( oArqTot, cChvTot , @aPosTot )
					aPosTot[1,TOTALIZADOR_FOLHA_VALOR_INSS] += ( nVlINSS + nVlINSS13 )
					
					TAFXHMSet( oArqTot, aPosTot, cChvTot )
				EndIf

				nBasINSS	:=	0
				nVlINSS		:=	0
				nSalFam		:=	0
				nSalMat		:=	0
				nBasINSS13	:=	0
				nVlINSS13	:=	0
				nSalMat13	:=	0
			EndIf

			lAdd := .F.

			nT3G ++
			cT3GPath := cT06Path + "/infoPerApur/ideEstabLot[" + cValToChar( nT3G ) + "]"
		EndDo

		//Informações do Período de Apuração Anterior
		//T5I - Informações do Acordo
		nT5I := 1
		cT5IPath := cT06Path + "/infoPerAnt/ideADC[" + cValToChar( nT5I ) + "]"
		While oXml:xPathHasNode( cT5IPath )

			//T5J - Identificação do Período de Referência
			nT5J := 1
			cT5JPath := cT5IPath + "/idePeriodo[" + cValToChar( nT5J ) + "]"
			While oXml:xPathHasNode( cT5JPath )

				//T5Q - Informações do Estabelecimento/Lotacão
				nT5Q := 1
				cT5QPath := cT5JPath + "/ideEstabLot[" + cValToChar( nT5Q ) + "]"
				While oXml:xPathHasNode( cT5QPath )

					//T5S - Itens da Remuneração
					nT5S := 1
					cT5SPath := cT5QPath + "/detVerbas[" + cValToChar( nT5S ) + "]"
					While oXml:xPathHasNode( cT5SPath )

						nRecnoC8R := 0
						cIDTabR := ""

						cIDTabR := TAFIDTabRub( oXml:xPathGetNodeValue( cT5SPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cT5SPath + "/codRubr" ))
            			nRecnoC8R := MVQueryC8R( oXml:xPathGetNodeValue( cT5SPath + "/codRubr" ), cIDTabR, cPeriodo, {xFilial("C8R")}, 2 )
                		C8R->( DBGoTo( nRecnoC8R ) )

						If C8R->( !Eof() )

							If C89->( MsSeek( C8R->( xFilial( "C89", C8R_FILIAL ) + C8R_NATRUB ) ) )
								cNatureza := AllTrim( C89->C89_CODIGO )
							Else
								cNatureza := ""
							EndIf

							cTipo := C8R->C8R_INDTRB

							If C8T->( MsSeek( C8R->( xFilial( "C8T", C8R_FILIAL ) + C8R_CINTPS ) ) )
								cIncidPS := AllTrim( C8T->C8T_CODIGO )
							Else
								cIncidPS := ""
							EndIf

							If cNatureza == "9201" .and. cIncidPS == "31"
								nVlINSS += Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))
								lAdd := .T.
							ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
								nBasINSS -= Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))
								lAdd := .T.
							ElseIf cNatureza == "9201" .and. cIncidPS == "32"
								nVlINSS13 += Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))
								lAdd := .T.
							ElseIf cNatureza == "9901" .and. cTipo == "3"
								nBasINSS += Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))
								//nBasINSS13 += Val( oXml:xPathGetNodeValue( cT5SPath + "/vrRubr" ) )
								lAdd := .T.
							ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
								nVlINSS -= Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))
								lAdd := .T.
							ElseIf cNatureza == "1409" .and. cIncidPS == "51"
								nSalFam += Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))
								lAdd := .T.
							ElseIf cNatureza == "4050" .and. cIncidPS == "21"
								nSalMat += Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))
								lAdd := .T.
							ElseIf cNatureza == "4051" .and. cIncidPS == "22"
								nSalMat13 += Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))
								lAdd := .T.
							EndIf

						EndIf

						nT5S ++
						cT5SPath := cT5QPath + "/detVerbas[" + cValToChar( nT5S ) + "]"
					EndDo

					If lAdd .or. __lSemVlr
					
						C9V->( MsSeek( xFilial( "C9V", cFilEvt ) + PadR( oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/cpfTrab" ), nC9VCPF ) + PadR( oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/matricula" ), nC9VMATRIC ) + "S2200" + "1" ) ) //Verificar xFilial
						
						cCodCat := GetCodCat( C9V->C9V_NOMEVE, C9V->C9V_FILIAL, C9V->C9V_ID, cPeriodo )

						If Empty( cCodCat )
							cCodCat := C9V->C9V_CATCI
						EndIf
						
						C87->( MsSeek( CUP->( xFilial( "C87", cFilEvt ) + cCodCat ) ) )

						If TAFXHMGet( oArqTrb, AllTrim( oXml:xPathGetNodeValue( cT5QPath + "/nrInsc" ) ) + "S-2299" + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/cpfTrab" ) ) + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/matricula" ) ) + AllTrim( C87->C87_CODIGO ) + AllTrim( oXml:xPathGetNodeValue( cT5QPath + "/codLotacao" ) ), @aPos )
							aPos[1,FOLHA_BASE_INSS]								+=	nBasINSS
							aPos[1,FOLHA_VALOR_INSS]							+=	nVlINSS
							aPos[1,FOLHA_VALOR_SALARIO_FAMILIA]					+=	nSalFam
							aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
							aPos[1,FOLHA_BASE_INSS_13_SALARIO]					+=	nBasINSS13
							aPos[1,FOLHA_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
							aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13

							TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
						EndIf

						If TAFXHMGet( oArqTot, cChvTot , @aPosTot )
							aPosTot[1,TOTALIZADOR_FOLHA_VALOR_INSS] += ( nVlINSS + nVlINSS13 )
							
							TAFXHMSet( oArqTot, aPosTot, cChvTot )
						EndIf

						nBasINSS	:=	0
						nVlINSS		:=	0
						nSalFam		:=	0
						nSalMat		:=	0
						nBasINSS13	:=	0
						nVlINSS13	:=	0
						nSalMat13	:=	0
					EndIf

					lAdd := .F.

					nT5Q ++
					cT5QPath := cT5JPath + "/ideEstabLot[" + cValToChar( nT5Q ) + "]"
				EndDo

				nT5J ++
				cT5JPath := cT5IPath + "/idePeriodo[" + cValToChar( nT5J ) + "]"
			EndDo

			nT5I ++
			cT5IPath := cT06Path + "/infoPerAnt/ideADC[" + cValToChar( nT5I ) + "]"
		EndDo

		nT06 ++
		cT06Path := "/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev[" + cValToChar( nT06 ) + "]"
	EndDo

EndIf

( cAliasQry )->( DBCloseArea() )

RestArea( aAreaC1E )
RestArea( aAreaC9V )
RestArea( aAreaCUP )
RestArea( aAreaC87 )
RestArea( aAreaC8R )
RestArea( aAreaC89 )
RestArea( aAreaC8T )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} DataS2399
@type			function
@description	Função responsável por colher as informações do Evento S-2399 no TAF.
@author			Felipe C. Seolin
@since			22/08/2018
@version		1.0
@param			oMsgRun		-	Objeto do FWMsgRun
@param			oArqTrb		-	Objeto com as informações para conferência ( Referência )
@param			cPeriodo	-	Período de referência das informações
@param			aFilial		-	Filiais selecionadas para processamento
@param			lProtheus	-	Indica se a Origem dos dados parte do Protheus
@param			aFilMatriz	-	Array com as informações da Filial Matriz
@param			oArqTot		-	Objeto com as informações dos totalizadores para conferência ( Referência )
/*/
//---------------------------------------------------------------------
Static Function DataS2399(oMsgRun, oArqTrb, cPeriodo, aFilial, lProtheus, aFilMatriz, oArqTot)

	Local cAliasQry		:= ""
	Local cQuery		:= ""
	Local cFilQry		:= ""
	Local cID			:= ""
	Local cVersao		:= ""
	Local cIDEstab		:= ""
	Local cIDLotac		:= ""
	Local cIDTrabal		:= ""
	Local cRecibo		:= ""
	Local cNatureza		:= ""
	Local cTipo			:= ""
	Local cIncidPS		:= ""
	Local cCodCat		:= ""
	Local nRecnoQry		:= 0
	Local nBasINSS		:= 0
	Local nVlINSS		:= 0
	Local nSalFam		:= 0
	Local nSalMat		:= 0
	Local nBasINSS13	:= 0
	Local nVlINSS13		:= 0
	Local nSalMat13		:= 0
	Local nContAdd		:= 0
	Local nQtdTotal		:= 0
	Local nQtdProc		:= 0
	Local aPos			:= {}
	Local aArqTrb		:= {}
	Local lAdd			:= .F.
	Local aPosTot		:= {}
	Local aPosEstab		:= {}
	Local cCPFTot		:= "" 
	Local cNrInscEst	:= ""
	Local cChaveHash	:= ""
	Local lTafGpeInss   := IIF(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F. )

	If !Empty(aFilial)

		cAliasQry	:= "rsR1208"

		If Select(cAliasQry) > 0
			(cAliasQry)->(DbCloseArea())
		EndIf

		cQuery := "SELECT COUNT(*) QUANTIDADE "

		cQuery += "FROM " + RetSqlName( "T92" ) + " T92 "

		cQuery += "WHERE T92.T92_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) "

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
			cQuery += "  AND SUBSTR( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		Else
			cQuery += "  AND SUBSTRING( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		EndIf

		cQuery += "  AND T92.T92_ATIVO = '1' "
		cQuery += "  AND T92.T92_EVENTO <> 'E' "
		cQuery += "  AND T92.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )

		TCQuery cQuery New Alias (cAliasQry)

		( cAliasQry )->( DBGoTop() )

		If ( cAliasQry )->( !Eof() )
			nQtdTotal := ( cAliasQry )->QUANTIDADE
		EndIf

		( cAliasQry )->( DBCloseArea() )

		If nQtdTotal > 0
			//Tabelas com as informações do Trabalhador
			C9V->( DBSetOrder( 2 ) ) //C9V_FILIAL, C9V_ID, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
			C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações do Estabelecimento
			C92->( DBSetOrder( 5 ) ) //C92_FILIAL, C92_ID, C92_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			//Tabela com as informações da Lotação
			C99->( DBSetOrder( 4 ) ) //C99_FILIAL, C99_ID, C99_ATIVO, R_E_C_N_O_, D_E_L_E_T_

			cAliasQry := "rsR1209"

			If Select(cAliasQry) > 0
				(cAliasQry)->(DbCloseArea())
			EndIf

			cQuery := "SELECT DISTINCT T92.R_E_C_N_O_ T92_RECONHECIMENTO, T92.T92_FILIAL, T92.T92_ID, T92.T92_VERSAO, T92.T92_DTERAV, T92.T92_TRABAL, T92.T92_PROTUL "
			cQuery += "     , T3J.T3J_ESTABE, T3J.T3J_LOTTRB "
			cQuery += "     , C89.C89_CODIGO, C8T.C8T_CODIGO, C8R.C8R_INDTRB "
			cQuery += "     , CMK.CMK_VLRRUB, CMK.R_E_C_N_O_ CMK_RECONHECIMENTO "

			cQuery += "FROM " + RetSqlName( "T92" ) + " T92 "

			cQuery += "INNER JOIN " + RetSqlName( "T3I" ) + " T3I "
			cQuery += "   ON T3I.T3I_FILIAL = T92.T92_FILIAL "
			cQuery += "  AND T3I.T3I_ID = T92.T92_ID "
			cQuery += "  AND T3I.T3I_VERSAO = T92.T92_VERSAO "
			cQuery += "  AND T3I.D_E_L_E_T_ = ' ' "

			//Filtro por CPF
			If !Empty( __CPF )
				cQuery += "INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
				cQuery += "   ON C9V.C9V_FILIAL = T92.T92_FILIAL "
				cQuery += "  AND C9V.C9V_ID = T92.T92_TRABAL "
				cQuery += "  AND C9V.C9V_ATIVO = '1' "
				cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( __CPF ) + "' "
				cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "
			EndIf

			cQuery += "INNER JOIN " + RetSqlName( "T3J" ) + " T3J "
			cQuery += "   ON T3J.T3J_FILIAL = T3I.T3I_FILIAL "
			cQuery += "  AND T3J.T3J_ID = T3I.T3I_ID "
			cQuery += "  AND T3J.T3J_VERSAO = T3I.T3I_VERSAO "
			cQuery += "  AND T3J.T3J_IDEDMD = T3I.T3I_IDEDMD "
			cQuery += "  AND T3J.D_E_L_E_T_ = ' ' "

			cQuery += "INNER JOIN " + RetSqlName( "CMK" ) + " CMK "
			cQuery += "   ON CMK.CMK_FILIAL = T3J.T3J_FILIAL "
			cQuery += "  AND CMK.CMK_ID = T3J.T3J_ID "
			cQuery += "  AND CMK.CMK_VERSAO = T3J.T3J_VERSAO "
			cQuery += "  AND CMK.CMK_IDEDMD = T3J.T3J_IDEDMD "
			cQuery += "  AND CMK.CMK_ESTABE = T3J.T3J_ESTABE "
			cQuery += "  AND CMK.CMK_LOTTRB = T3J.T3J_LOTTRB "
			cQuery += "  AND CMK.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "
				
			If lC8RCmpart
				cQuery += "  ON C8R.C8R_FILIAL = CMK.CMK_FILIAL "
			Else
				cQuery += "  ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
			EndIf
				
			cQuery += " AND C8R.C8R_ID = CMK.CMK_CODRUB "
			cQuery += " AND C8R.C8R_ATIVO = '1' "
			cQuery += " AND C8R.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
			cQuery += "  ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
			cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
			cQuery += " AND C89.D_E_L_E_T_ = ' ' "

			cQuery += "LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
			cQuery += "  ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "	
			cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
			cQuery += " AND C8T.D_E_L_E_T_ = ' ' "

			cQuery += "WHERE T92.T92_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cCachFil + " FILIAIS ) " 

			If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
				cQuery += "  AND SUBSTR( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
			Else
				cQuery += "  AND SUBSTRING( T92.T92_DTERAV, 1, 6 ) = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
			EndIf

			cQuery += "  AND T92.T92_ATIVO = '1' "
			cQuery += "  AND T92.T92_EVENTO <> 'E' "
			cQuery += "  AND T92.D_E_L_E_T_ = ' ' "

			cQuery += "ORDER BY T92_FILIAL, T92_ID, T92_VERSAO, T92_DTERAV, T3J_ESTABE, T3J_LOTTRB "

			cQuery := ChangeQuery( cQuery )

			TCQuery cQuery New Alias (cAliasQry)

			( cAliasQry )->( DBGoTop() )

			While ( cAliasQry )->( !Eof() )
				cFilQry		:=	( cAliasQry )->T92_FILIAL
				cID			:=	( cAliasQry )->T92_ID
				cVersao		:=	( cAliasQry )->T92_VERSAO
				cIDEstab	:=	( cAliasQry )->T3J_ESTABE
				cIDLotac	:=	( cAliasQry )->T3J_LOTTRB
				cIDTrabal	:=	( cAliasQry )->T92_TRABAL
				cRecibo		:=	( cAliasQry )->T92_PROTUL
				nRecnoQry	:=	( cAliasQry )->T92_RECONHECIMENTO

				While ( cAliasQry )->( T92_FILIAL + T92_ID + T92_VERSAO + T3J_ESTABE + T3J_LOTTRB ) == cFilQry + cID + cVersao + cIDEstab + cIDLotac
					cNatureza	:=	AllTrim( ( cAliasQry )->C89_CODIGO )
					cTipo		:=	AllTrim( ( cAliasQry )->C8R_INDTRB )
					cIncidPS	:=	AllTrim( ( cAliasQry )->C8T_CODIGO )

					If cNatureza == "9201" .and. cIncidPS == "31"
						if cTipo == "1"
							nVlINSS -= ( cAliasQry )->CMK_VLRRUB
						Else
							nVlINSS += ( cAliasQry )->CMK_VLRRUB
						EndIf
						lAdd := .T.
					ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
						nBasINSS -= ( cAliasQry )->CMK_VLRRUB
						lAdd := .T.
					ElseIf cNatureza == "9201" .and. cIncidPS == "32"
						nVlINSS13 += ( cAliasQry )->CMK_VLRRUB
						lAdd := .T.
					ElseIf cNatureza == "9901" .and. cTipo == "3"
						nBasINSS += ( cAliasQry )->CMK_VLRRUB
						//nBasINSS13 += ( cAliasQry )->CMK_VLRRUB
						lAdd := .T.
					ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
						nVlINSS -= ( cAliasQry )->CMK_VLRRUB
						lAdd := .T. 
					ElseIf cNatureza == "1409" .and. cIncidPS == "51"
						nSalFam += ( cAliasQry )->CMK_VLRRUB
						lAdd := .T.
					ElseIf cNatureza == "4050" .and. cIncidPS == "21"
						nSalMat += ( cAliasQry )->CMK_VLRRUB
						lAdd := .T.
					ElseIf cNatureza == "4051" .and. cIncidPS == "22"
						nSalMat13 += ( cAliasQry )->CMK_VLRRUB
						lAdd := .T.
					EndIf

					( cAliasQry )->( DBSkip() )
				EndDo

				If lAdd .or. __lSemVlr
					C9V->( MsSeek( xFilial( "C9V", cFilQry ) + cIDTrabal + "1" ) )

					cCodCat := GetCodCat( C9V->C9V_NOMEVE, C9V->C9V_FILIAL, C9V->C9V_ID, cPeriodo )

					If Empty( cCodCat )
						cCodCat := C9V->C9V_CATCI
					EndIf

					C87->( MsSeek( xFilial( "C87", C9V->C9V_FILIAL ) + cCodCat ) )
					C92->( MsSeek( xFilial( "C92", cFilQry ) + cIDEstab + "1" ) )
					C99->( MsSeek( xFilial( "C99", cFilQry ) + cIDLotac + "1" ) )

					cChaveHash := AllTrim( C92->C92_NRINSC ) + "S-2399" + AllTrim( C9V->C9V_CPF ) + AllTrim( C9V->C9V_MATRIC ) + AllTrim( C87->C87_CODIGO ) + AllTrim( C99->C99_CODIGO )
					If TAFXHMGet( oArqTrb, cChaveHash, @aPos )
						aPos[1,ALIAS]										:=	"T92"
						aPos[1,RECNO]										:=	cValToChar( nRecnoQry )
						aPos[1,RECIBO_TRANSMISSAO]							:=	AllTrim( cRecibo )
						aPos[1,ESTABELECIMENTO]								:=	AllTrim( C92->C92_NRINSC )
						aPos[1,CPF]											:=	AllTrim( C9V->C9V_CPF )
						aPos[1,NOME]										:=	AllTrim( C9V->C9V_NOME )
						aPos[1,MATRICULA]									:=	AllTrim( C9V->C9V_MATRIC )
						aPos[1,CATEGORIA]									:=	AllTrim( C87->C87_CODIGO )
						aPos[1,LOTACAO]										:=	AllTrim( C99->C99_CODIGO )
						aPos[1,EVENTO_ESOCIAL]								:=	"S-2399"
						aPos[1,TAF_BASE_INSS]								+=	nBasINSS
						aPos[1,TAF_VALOR_INSS]								+=	nVlINSS
						aPos[1,TAF_VALOR_SALARIO_FAMILIA]					+=	nSalFam
						aPos[1,TAF_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
						aPos[1,TAF_BASE_INSS_13_SALARIO]					+=	nBasINSS13
						aPos[1,TAF_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
						aPos[1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13
						aPos[1,OBSERVACAO]									:=	"A base de cálculo para os eventos de Desligamento ( S-2299 ) e Término de Vinculo ( S-2399 ) são consolidados na Folha e no TAF"
						aPos[1,TIPO_FUNCIONARIO]							:=	AllTrim( C9V->C9V_NOMEVE )

						TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
					Else
						TAFXHMAdd( oArqTrb, {	"T92",;							//ALIAS
												cValToChar( nRecnoQry ),;		//RECNO
												AllTrim( cRecibo ),;			//RECIBO_TRANSMISSAO
												AllTrim( C92->C92_NRINSC ),;	//ESTABELECIMENTO
												AllTrim( C9V->C9V_CPF ),;		//CPF
												AllTrim( C9V->C9V_NOME ),;		//NOME
												AllTrim( C9V->C9V_MATRIC ),;	//MATRICULA
												AllTrim( C87->C87_CODIGO ),;	//CATEGORIA
												AllTrim( C99->C99_CODIGO ),;	//LOTACAO
												"S-2399",;						//EVENTO_ESOCIAL
												"",;							//TIPO_BASE_CALCULO
												0,;								//FOLHA_BASE_INSS
												0,;								//FOLHA_VALOR_INSS
												0,;								//FOLHA_VALOR_SALARIO_FAMILIA
												0,;								//FOLHA_VALOR_SALARIO_MATERNIDADE
												0,;								//FOLHA_BASE_INSS_13_SALARIO
												0,;								//FOLHA_VALOR_INSS_13_SALARIO
												0,;								//FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO
												nBasINSS,;						//TAF_BASE_INSS
												nVlINSS,;						//TAF_VALOR_INSS
												nSalFam,;						//TAF_VALOR_SALARIO_FAMILIA
												nSalMat,;						//TAF_VALOR_SALARIO_MATERNIDADE
												nBasINSS13,;					//TAF_BASE_INSS_13_SALARIO
												nVlINSS13,;						//TAF_VALOR_INSS_13_SALARIO
												nSalMat13,;						//TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO
												0,;								//GOVERNO_BASE_INSS
												0,;								//GOVERNO_VALOR_INSS
												0,;								//GOVERNO_VALOR_SALARIO_FAMILIA
												0,;								//GOVERNO_VALOR_SALARIO_MATERNIDADE
												0,;								//GOVERNO_BASE_INSS_13_SALARIO
												0,;								//GOVERNO_VALOR_INSS_13_SALARIO
												0,;								//GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO
												"A base de cálculo para os eventos de Desligamento ( S-2299 ) e Término de Vinculo ( S-2399 ) são consolidados na Folha e no TAF",;	//OBSERVACAO
												AllTrim( C9V->C9V_NOMEVE ),;	//TIPO_FUNCIONARIO
												.F.,;							//GOVERNO_LOCALIZADO
												0 },;							//GOVERNO_BASE_SUSPENSAO
							ESTABELECIMENTO, 3,;
							EVENTO_ESOCIAL, 0,;
							CPF, 3,;
							MATRICULA, 3,;
							CATEGORIA, 3,;
							LOTACAO, 3 )
					EndIf
				EndIf

				cCPFTot    := AllTrim( C9V->C9V_CPF ) 
				cNrInscEst := AllTrim( C92->C92_NRINSC )
				If TAFXHMGet( oArqTot, cCPFTot+"S-2399" , @aPosTot )
					aPosTot[1,TOTALIZADOR_TAF_VALOR_INSS] += ( nVlINSS + nVlINSS13 )
						
					TAFXHMSet( oArqTot, aPosTot, cCPFTot+"S-2399" )
				Else
					TAFXHMAdd( oArqTot, {	cCPFTot,;
											AllTrim( C9V->C9V_NOME ),;
											"S-2399",;
											0 ,;
											nVlINSS + nVlINSS13,;
											0,;
											cNrInscEst},;
											CPF_TRABALHADOR, 3,;
											EVENTO_ESOCIAL_TOTALIZADOR, 0)
												
												
				EndIf
					
				If TAFXHMGet(oArqEst, cCPFTot+cNrInscEst+"S-2399", @aPosEstab )
					aPosEstab[1,TOTALIZADOR_ESTABELECIMENTO] += ( nVlINSS + nVlINSS13 )
						
					TAFXHMSet( oArqEst, aPosEstab, cCPFTot+cNrInscEst+"S-2399" )								
				Else
					TAFXHMAdd( oArqEst, {	cCPFTot+cNrInscEst+"S-2399",;
											nVlINSS + nVlINSS13},;
											CHAVE_TOT_ESTAB, 3)

				EndIf
					
				If ( cAliasQry )->( T92_FILIAL + T92_ID + T92_VERSAO ) <> cFilQry + cID + cVersao
					TAFXHMList( oArqTrb, aArqTrb )
					If nContAdd <= Len( aArqTrb )
						If !lProtheus .Or. ( lProtheus .And. StoD(Substr(cPeriodo,3,6)+Substr(cPeriodo,1,2) + "01" ) >= StoD("20191101") )
							InsOrigT92( @oArqTrb, cFilQry, nRecnoQry, cCPFTot+"S-2399", @oArqTot,aFilMatriz )
						EndIf
						Insert5001( @oArqTrb, cFilQry, "T92", "1", cPeriodo, C9V->C9V_CPF, cRecibo, aFilMatriz,, cCPFTot+"S-2399", @oArqTot, cChaveHash )
					EndIf

					nContAdd := Len( aArqTrb )
				EndIf

				nQtdProc ++
				SetIncPerc( oMsgRun, "S-2399", nQtdTotal, nQtdProc )

				cChaveHash	:=	""
				cFilQry		:=	""
				cID			:=	""
				cVersao		:=	""
				cIDEstab	:=	""
				cIDLotac	:=	""
				cIDTrabal	:=	""
				cRecibo		:=	""
				cNatureza	:=	""
				cTipo		:=	""
				cIncidPS	:=	""
				cCodCat		:=	""
				nRecnoQry	:=	0
				nBasINSS	:=	0
				nVlINSS		:=	0
				nSalFam		:=	0
				nSalMat		:=	0
				nBasINSS13	:=	0
				nVlINSS13	:=	0
				nSalMat13	:=	0
				lAdd		:=	.F.
			EndDo

			( cAliasQry )->( DBCloseArea() )

		Else
			nQtdProc ++
			SetIncPerc( oMsgRun, "S-2399", nQtdTotal, nQtdProc )
		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} InsOrigT92
@type			function
@description	Função responsável por colher as informações do Evento S-2399 no XML de entrada.
@author			Felipe C. Seolin
@since			22/08/2018
@version		1.0
@param			oArqTrb	-	Objeto com as informações para conferência ( Referência )
@param			cFilEvt	-	Filial do registro do evento S-2399 no TAF
@param			nRecno	-	Recno do registro do evento S-2399 no TAF
@param			cChvTot -	Chave do trabalhador para totalizador
@param			oArqTot -	Objeto com as informações dos totalizadores para conferência ( Referência )
/*/
//---------------------------------------------------------------------
Static Function InsOrigT92( oArqTrb, cFilEvt, nRecno, cChvTot, oArqTot,aFilMatriz )

Local oXml			:=	Nil
Local cAliasQry		:=	"rsR120A"
Local cQuery		:=	""
Local cXml			:=	""
Local cNatureza		:=	""
Local cTipo			:=	""
Local cIncidPS		:=	""
Local cT3IPath		:=	""
Local cT3JPath		:=	""
Local cCMKPath		:=	""
Local cCodFil		:=	""
Local nT3I			:=	0
Local nT3J			:=	0
Local nCMK			:=	0
Local nBasINSS		:=	0
Local nVlINSS		:=	0
Local nSalFam		:=	0
Local nSalMat		:=	0
Local nBasINSS13	:=	0
Local nVlINSS13		:=	0
Local nSalMat13		:=	0
Local nC9VCPF		:=	TamSX3( "C9V_CPF" )[1]
Local nC8RCODRUB	:=	TamSX3( "C8R_CODRUB" )[1]
Local aPos			:=	{}
Local aAreaC1E		:=	C1E->( GetArea() )
Local aAreaC9V		:=	C9V->( GetArea() )
Local aAreaC87		:=	C87->( GetArea() )
Local aAreaC8R		:=	C8R->( GetArea() )
Local aAreaC89		:=	C89->( GetArea() )
Local aAreaC8T		:=	C8T->( GetArea() )
Local lAdd			:=	.F.
Local aPosTot		:= {}
Local lTafGpeInss   := IIF(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F. )

C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_
If C1E->( MsSeek( xFilial( "C1E", cFilEvt ) + cFilEvt + "1" ) )
	cCodFil := C1E->C1E_CODFIL
Else
	CR9->( DBSetOrder( 2 ) ) // CR9_FILIAL+CR9_CODFIL+CR9_ATIVO                                                                                                                                 
	If CR9->( MsSeek( xFilial( "CR9", cFilEvt ) + PadR( aFilMatriz[1]+cFilEvt, TamSX3( "CR9_CODFIL" )[1] ) + "1" ) )
		cCodFil := CR9->CR9_CODFIL
	EndIf
EndIf

cQuery := "SELECT TAFST2.R_E_C_N_O_ TAFST2_RECONHECIMENTO "
cQuery += "FROM TAFXERP TAFXERP "
cQuery += "INNER JOIN TAFST2 TAFST2 "
cQuery += "   ON TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
cQuery += "  AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
cQuery += "  AND TAFST2.TAFFIL = '" + cCodFil + "' "
cQuery += "  AND TAFST2.D_E_L_E_T_ = ' ' "
cQuery += "WHERE TAFXERP.TAFALIAS = 'T92' "
cQuery += "  AND TAFXERP.TAFRECNO = '" + cValToChar( nRecno ) + "' "
cQuery += "  AND TAFXERP.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY TAFXERP.R_E_C_N_O_ DESC "

cQuery := ChangeQuery( cQuery )

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf

TCQuery cQuery New Alias (cAliasQry)

( cAliasQry )->( DBGoTop() )

If ( cAliasQry )->( !Eof() )

	C9V->( DBSetOrder( 19 ) ) //C9V_FILIAL, C9V_CPF, C9V_CATCI, C9V_NOMEVE, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C87->( DBSetOrder( 2 ) ) //C87_FILIAL, C87_CODIGO, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_

	C8R->( DBSetOrder( 3 ) ) //C8R_FILIAL, C8R_CODRUB, C8R_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C89->( DBSetOrder( 1 ) ) //C89_FILIAL, C89_ID, R_E_C_N_O_, D_E_L_E_T_
	C8T->( DBSetOrder( 1 ) ) //C8T_FILIAL, C8T_ID, R_E_C_N_O_, D_E_L_E_T_

	( cST2Alias )->( DBGoTo( ( cAliasQry )->TAFST2_RECONHECIMENTO ) )

	cXml := ( cST2Alias )->TAFMSG

	//Tiro os espaços em branco no início e final do XML e armazeno na variável
	cXml := EncodeUTF8( AllTrim(  StrTran(cXml, ",",".") ) )

	//Instancia objeto em oXml
	oXml := TXmlManager():New()

	If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
		cXml := StrTran( cXml, Chr( 13 ), "" )
		cXml := StrTran( cXml, Chr( 10 ), "" )

		//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
		If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
			cXml += ">"
		EndIf
	EndIf

	If !Empty( cXml ) .and. oXml:Parse( FTrocaPath( cXml, "eSocial" ) )
		oXml:bDecodeUTF8 := .T.
	EndIf

	//T06 - Informações do Recibo de Pagamento
	nT3I := 1
	cT3IPath := "/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev[" + cValToChar( nT3I ) + "]"
	While oXml:xPathHasNode( cT3IPath )

		nT3J := 1
		cT3JPath := cT3IPath + "/ideEstabLot[" + cValToChar( nT3J ) + "]"
		While oXml:xPathHasNode( cT3JPath )

			nCMK := 1
			cCMKPath := cT3JPath + "/detVerbas[" + cValToChar( nCMK ) + "]"
			While oXml:xPathHasNode( cCMKPath )

				If C8R->( MsSeek( xFilial( "C8R" ) + PadR( oXml:xPathGetNodeValue( cCMKPath + "/codRubr" ), nC8RCODRUB ) + "1" ) ) //Verificar xFilial

					If C89->( MsSeek( C8R->( xFilial( "C89", C8R_FILIAL ) + C8R_NATRUB ) ) )
						cNatureza := AllTrim( C89->C89_CODIGO )
					Else
						cNatureza := ""
					EndIf

					cTipo := C8R->C8R_INDTRB

					If C8T->( MsSeek( C8R->( xFilial( "C8T", C8R_FILIAL ) + C8R_CINTPS ) ) )
						cIncidPS := AllTrim( C8T->C8T_CODIGO )
					Else
						cIncidPS := ""
					EndIf

					If cNatureza == "9201" .and. cIncidPS == "31"
						nVlINSS += Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
						nBasINSS -= Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf cNatureza == "9201" .and. cIncidPS == "32"
						nVlINSS13 += Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf cNatureza == "9901" .and. cTipo == "3"
						nBasINSS += Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))
						//nBasINSS13 += Val( oXml:xPathGetNodeValue( cCMKPath + "/vrRubr" ) )
						lAdd := .T.
					ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
						nVlINSS -= Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf cNatureza == "1409" .and. cIncidPS == "51"
						nSalFam += Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf cNatureza == "4050" .and. cIncidPS == "21"
						nSalMat += Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))
						lAdd := .T.
					ElseIf cNatureza == "4051" .and. cIncidPS == "22"
						nSalMat13 += Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))
						lAdd := .T.
					EndIf

				EndIf

				nCMK ++
				cCMKPath := cT3JPath + "/detVerbas[" + cValToChar( nCMK ) + "]"
			EndDo

			If lAdd .or. __lSemVlr
				C87->( MsSeek( xFilial( "C87" ) + oXml:xPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/codCateg" ) ) )
				C9V->( MsSeek( xFilial( "C9V" ) + PadR( oXml:xPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/cpfTrab" ), nC9VCPF ) + C87->C87_ID + "S2300" + "1" ) ) //Verificar xFilial

				If TAFXHMGet( oArqTrb, AllTrim( oXml:xPathGetNodeValue( cT3JPath + "/nrInsc" ) ) + "S-2399" + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/cpfTrab" ) ) + AllTrim( C9V->C9V_MATRIC ) + AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/codCateg" ) ) + AllTrim( oXml:xPathGetNodeValue( cT3JPath + "/codLotacao" ) ), @aPos )
					aPos[1,FOLHA_BASE_INSS]								+=	nBasINSS
					aPos[1,FOLHA_VALOR_INSS]							+=	nVlINSS
					aPos[1,FOLHA_VALOR_SALARIO_FAMILIA]					+=	nSalFam
					aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
					aPos[1,FOLHA_BASE_INSS_13_SALARIO]					+=	nBasINSS13
					aPos[1,FOLHA_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
					aPos[1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13

					TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )

				EndIf

				If TAFXHMGet( oArqTot, cChvTot , @aPosTot )
					aPosTot[1,TOTALIZADOR_FOLHA_VALOR_INSS] += ( nVlINSS + nVlINSS13 )
					
					TAFXHMSet( oArqTot, aPosTot, cChvTot )
				EndIf
					
				nBasINSS	:=	0
				nVlINSS		:=	0
				nSalFam		:=	0
				nSalMat		:=	0
				nBasINSS13	:=	0
				nVlINSS13	:=	0
				nSalMat13	:=	0
			EndIf

			lAdd := .F.

			nT3J ++
			cT3JPath := cT3IPath + "/ideEstabLot[" + cValToChar( nT3J ) + "]"
		EndDo

		nT3I ++
		cT3IPath := "/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev[" + cValToChar( nT3I ) + "]"
	EndDo

EndIf

( cAliasQry )->( DBCloseArea() )

RestArea( aAreaC1E )
RestArea( aAreaC9V )
RestArea( aAreaC87 )
RestArea( aAreaC8R )
RestArea( aAreaC89 )
RestArea( aAreaC8T )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} Insert5001
@type			function
@description	Função responsável por colher as informações do Evento S-5001 no retorno do Governo.
@author			Felipe C. Seolin
@since			20/08/2018
@version		1.0
@param			oArqTrb		-	Objeto com as informações para conferência ( Referência )
@param			cFilEvt		-	Filial do registro no TAF
@param			cAlias		-	Alias do registro no TAF
@param			cIndApu		-	Indicador de Apuração do registro do evento no TAF
@param			cPeriodo	-	Período de referência das informações
@param			cCPF		-	CPF do registro no TAF
@param			cRecibo		-	Recibo do registro no TAF
@param			aFilMatriz	-	Array com as informações da Filial Matriz
@param			lMultVinc	-	Valida se é Multiplos Vinculos
@param			cChvTot		-	Chave do trabalhador para totalizador
@param			oArqTot		-	Objeto com as informações dos totalizadores para conferência ( Referência )
@param			cChaveHash	-	Chave do registro em operação para busca no hash
@param			cC91Trabal	-	ID do trabalhar registrado no evento S-1200
/*/
//---------------------------------------------------------------------
Static Function Insert5001( oArqTrb, cFilEvt, cAlias, cIndApu, cPeriodo, cCPF, cRecibo, aFilMatriz, lMultVinc, cChvTot, oArqTot, cChaveHash, cC91Trabal )

	Local cAliasQry		:=	"rsR120B"
	Local cQuery		:=	""
	Local cIDEstab		:=	""
	Local cIDLotac		:=	""
	Local cIDTrabal		:=	""
	Local cIDCateg		:=	""
	Local cTipo			:=	""
	Local cTipoBC		:=	""
	Local cEvtDesc		:=	""
	Local cCodCat		:=	""
	Local cFilMatriz	:=	Iif( !Empty( aFilMatriz ), aFilMatriz[2], "" )
	Local cFilQry		:=	""
	Local nBasINSS		:=	0
	Local nVlINSS		:=	0
	Local nSalFam		:=	0
	Local nSalMat		:=	0
	Local nBasINSS13	:=	0
	Local nVlINSS13		:=	0
	Local nSalMat13		:=	0
	Local nVlrSusp		:=	0
	Local dDtTot		:=	GetNewPar( "MV_TOTEXDT", SToD( "20991231" ) )
	Local aPos			:=	{}
	Local aAreaC87		:=	C87->( GetArea() )
	Local aAreaC92		:=	C92->( GetArea() )
	Local aAreaC99		:=	C99->( GetArea() )
	Local lAdd			:=	.F.
	Local lAddSemINSS	:=	.F.

	Local cQryTot       :=	""
	Local cAlQryTot		:=	""
	Local aPosTot		:= {}

	Default lMultVinc 	:= .F.
	Default	cC91Trabal 	:= ""

	If Len( AllTrim( cPeriodo ) ) == 4 //Décimo Terceiro
		If SToD( cPeriodo + "12" + "01" ) >= dDtTot
			cFilQry := cFilEvt
		Else
			cFilQry := cFilMatriz
		EndIf
	Else
		If SToD( SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) + "01" ) >= dDtTot
			cFilQry := cFilEvt
		Else
			cFilQry := cFilMatriz
		EndIf
	EndIf

	If cAlias == "C91"
		cEvtDesc := "S-1200"
	ElseIf cAlias == "CMD"
		cEvtDesc := "S-2299"
	ElseIf cAlias == "T92"
		cEvtDesc := "S-2399"
	EndIf

	C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_
	C92->( DBSetOrder( 5 ) ) //C92_FILIAL, C92_ID, C92_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C99->( DBSetOrder( 4 ) ) //C99_FILIAL, C99_ID, C99_ATIVO, R_E_C_N_O_, D_E_L_E_T_

	cQuery := "SELECT DISTINCT T2M.T2M_CPFTRB, T2P.T2P_ESTABE, T2P.T2P_LOTACA, T2Q.T2Q_MATRIC, T2Q.T2Q_CODCAT, T2R.T2R_INDDEC, T2T.T2T_CODIGO, T2R.T2R_VALOR "

	cQuery += "FROM " + RetSqlName( "T2M" ) + " T2M "

	cQuery += "LEFT JOIN " + RetSqlName( "T2P" ) + " T2P "
	cQuery += "   ON T2P.T2P_FILIAL = T2M.T2M_FILIAL "
	cQuery += "  AND T2P.T2P_ID = T2M.T2M_ID "
	cQuery += "  AND T2P.T2P_VERSAO = T2M.T2M_VERSAO "
	cQuery += "  AND T2P.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName( "T2Q" ) + " T2Q "
	cQuery += "   ON T2Q.T2Q_FILIAL = T2P.T2P_FILIAL "
	cQuery += "  AND T2Q.T2Q_ID = T2P.T2P_ID "
	cQuery += "  AND T2Q.T2Q_VERSAO = T2P.T2P_VERSAO "
	cQuery += "  AND T2Q.T2Q_ESTABE = T2P.T2P_ESTABE "
	cQuery += "  AND T2Q.T2Q_LOTACA = T2P.T2P_LOTACA "
	cQuery += "  AND T2Q.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName( "T2R" ) + " T2R "
	cQuery += "   ON T2R.T2R_FILIAL = T2Q.T2Q_FILIAL "
	cQuery += "  AND T2R.T2R_ID = T2Q.T2Q_ID "
	cQuery += "  AND T2R.T2R_VERSAO = T2Q.T2Q_VERSAO "
	cQuery += "  AND T2R.T2R_ESTABE = T2Q.T2Q_ESTABE "
	cQuery += "  AND T2R.T2R_LOTACA = T2Q.T2Q_LOTACA "
	cQuery += "  AND T2R.T2R_MATRIC = T2Q.T2Q_MATRIC "
	cQuery += "  AND T2R.T2R_CODCAT = T2Q.T2Q_CODCAT "
	cQuery += "  AND T2R.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName( "T2T" ) + " T2T "
	cQuery += "  ON T2T.T2T_FILIAL = '" + xFilial( "T2T", cFilQry ) + "' "
	cQuery += " AND T2T.T2T_ID = T2R.T2R_TPVLR "
	cQuery += " AND T2T.D_E_L_E_T_ = ' ' "

	cQuery += "WHERE T2M.T2M_FILIAL = '" + cFilQry + "' "
	cQuery += "  AND T2M.T2M_INDAPU = '" + cIndApu + "' "

	If Len( AllTrim( cPeriodo ) ) == 4 //Décimo Terceiro
		cQuery += "  AND T2M.T2M_PERAPU = '" + cPeriodo + "' "
	Else
		cQuery += "  AND T2M.T2M_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) + "' "
	EndIf

	cQuery += "  AND T2M.T2M_CPFTRB = '" + cCPF + "' "
	cQuery += "  AND T2M.T2M_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND T2M.T2M_ATIVO = '1' "
	cQuery += "  AND T2M.D_E_L_E_T_ = ' ' "

	cQuery += "ORDER BY T2P_ESTABE, T2P_LOTACA, T2Q_MATRIC, T2Q_CODCAT "

	cQuery := ChangeQuery( cQuery ) 

	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	While ( cAliasQry )->( !Eof() )
		
		cIDEstab	:=	( cAliasQry )->T2P_ESTABE
		cIDLotac	:=	( cAliasQry )->T2P_LOTACA
		cIDTrabal	:=	( cAliasQry )->T2Q_MATRIC
		cIDCateg	:=	( cAliasQry )->T2Q_CODCAT

		If Empty( cIDEstab + cIDLotac + cIDTrabal + cIDCateg )
			lAddSemINSS := .T.

			( cAliasQry )->( DBSkip() )
		Else
			While ( cAliasQry )->( T2P_ESTABE + T2P_LOTACA + T2Q_MATRIC + T2Q_CODCAT ) == cIDEstab + cIDLotac + cIDTrabal + cIDCateg
				cTipo := AllTrim( ( cAliasQry )->T2T_CODIGO )

				If ( cAliasQry )->T2R_INDDEC == "0"
					If cTipo $ "11|12|13|14|15|16|17|18|19"
						If !( cTipo $ cTipoBC )
							cTipoBC += Iif( Empty( cTipoBC ), cTipo, "," + cTipo )
						EndIf
						nBasINSS += ( cAliasQry )->T2R_VALOR
						lAdd := .T.
					ElseIf cTipo $ "91|92|93|94|95|96|97|98"
						If !( cTipo $ cTipoBC )
							cTipoBC += Iif( Empty( cTipoBC ), cTipo, "," + cTipo )
						EndIf
						nVlrSusp += ( cAliasQry )->T2R_VALOR
						lAdd := .T.
					ElseIf cTipo == "21"
						nVlINSS += ( cAliasQry )->T2R_VALOR
						lAdd := .T.
					ElseIf cTipo == "31"
						nSalFam += ( cAliasQry )->T2R_VALOR
						lAdd := .T.
					ElseIf cTipo == "32"
						nSalMat += ( cAliasQry )->T2R_VALOR
						lAdd := .T.
					EndIf
				ElseIf ( cAliasQry )->T2R_INDDEC == "1"
					If cTipo $ "11|12|13|14|15|16|17|18|19"
						If !( cTipo $ cTipoBC )
							cTipoBC += Iif( Empty( cTipoBC ), cTipo, "," + cTipo )
						EndIf
						nBasINSS13 += ( cAliasQry )->T2R_VALOR
						lAdd := .T.
					ElseIf cTipo $ "91|92|93|94|95|96|97|98"
						If !( cTipo $ cTipoBC )
							cTipoBC += Iif( Empty( cTipoBC ), cTipo, "," + cTipo )
						EndIf
						nVlrSusp += ( cAliasQry )->T2R_VALOR
						lAdd := .T.
					ElseIf cTipo == "21"
						nVlINSS13 += ( cAliasQry )->T2R_VALOR
						lAdd := .T.
					ElseIf cTipo == "32"
						nSalMat13 += ( cAliasQry )->T2R_VALOR
						lAdd := .T.
					EndIf
				EndIf
				( cAliasQry )->( DBSkip() )
			EndDo
		EndIf

		If lAddSemINSS
			If TAFXHMGet( oArqTrb, cChaveHash, @aPos )
				aPos[1,GOVERNO_LOCALIZADO]	:=	.T.

				TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
			EndIf
		ElseIf lAdd .or. __lSemVlr

			If !lMultVinc
				
				If Empty(cC91Trabal)
					cIDTrab := Posicione( "C9V", 3, cFilEvt + cCPF + "1", "C9V_ID" )
				Else
					cIDTrab := cC91Trabal
				EndIf

				cEvento := Posicione( "C9V", 2, cFilEvt + cIDTrab + "1", "C9V_NOMEVE" )

				cCodCat := GetCodCat( cEvento, cFilEvt, cIDTrab, cPeriodo )
			EndIf

			If Empty( cCodCat )
				cCodCat := cIDCateg
			EndIf

			C87->( MsSeek( xFilial( "C87", cFilEvt ) + cCodCat ) )
			C92->( MsSeek( xFilial( "C92", cFilEvt ) + cIDEstab + "1" ) )
			C99->( MsSeek( xFilial( "C99", cFilEvt ) + cIDLotac + "1" ) )

			If TAFXHMGet( oArqTrb, AllTrim( C92->C92_NRINSC ) + AllTrim( cEvtDesc ) + AllTrim( cCPF ) + AllTrim( cIDTrabal ) + AllTrim( C87->C87_CODIGO ) + AllTrim( C99->C99_CODIGO ), @aPos )
				aPos[1,TIPO_BASE_CALCULO]								:=	cTipoBC
				aPos[1,GOVERNO_BASE_INSS]								+=	nBasINSS
				aPos[1,GOVERNO_VALOR_INSS]								+=	nVlINSS
				aPos[1,GOVERNO_VALOR_SALARIO_FAMILIA]					+=	nSalFam
				aPos[1,GOVERNO_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
				aPos[1,GOVERNO_BASE_INSS_13_SALARIO]					+=	nBasINSS13
				aPos[1,GOVERNO_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
				aPos[1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13
				aPos[1,GOVERNO_BASE_SUSPENSAO]							+=	nVlrSusp
				aPos[1,GOVERNO_LOCALIZADO]								:=	.T.

				TAFXHMSet( oArqTrb, aPos, aPos[1,ESTABELECIMENTO] + aPos[1,EVENTO_ESOCIAL] + aPos[1,CPF] + aPos[1,MATRICULA] + aPos[1,CATEGORIA] + aPos[1,LOTACAO] )
						
			EndIf
			If TAFXHMGet( oArqTot, cChvTot , @aPosTot ) .And. aPosTot[1,TOTALIZADOR_GOVERNO_VALOR_INSS] == 0

				cAlQryTot := "rsR120C"

				If Select(cAlQryTot) > 0
					(cAlQryTot)->(DbCloseArea())
				EndIf
				
				cQryTot := "SELECT DISTINCT T2O.T2O_VRCPSE"
				cQryTot += " FROM " + RetSqlName( "T2M" ) + " T2M "
				cQryTot += "INNER JOIN " + RetSqlName( "T2O" ) + " T2O "
				cQryTot += "   ON T2O.T2O_FILIAL = T2M.T2M_FILIAL "
				cQryTot += "  AND T2O.T2O_ID = T2M.T2M_ID "
				cQryTot += "  AND T2O.T2O_VERSAO = T2M.T2M_VERSAO "
				cQryTot += "  AND T2O.D_E_L_E_T_ = ' ' "
				
				cQryTot += "WHERE T2M.T2M_FILIAL = '" + cFilQry + "' "
				cQryTot += "  AND T2M.T2M_INDAPU = '" + cIndApu + "' "
				
				If Len( AllTrim( cPeriodo ) ) == 4 //Décimo Terceiro
					cQryTot += "  AND T2M.T2M_PERAPU = '" + cPeriodo + "' "
				Else
					cQryTot += "  AND T2M.T2M_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) + "' "
				EndIf

				cQryTot += "  AND T2M.T2M_CPFTRB = '" + cCPF + "' "
				cQryTot += "  AND T2M.T2M_NRRECI = '" + cRecibo + "' "
				cQryTot += "  AND T2M.T2M_ATIVO = '1' "
				cQryTot += "  AND T2M.D_E_L_E_T_ = ' ' "

				cQryTot := ChangeQuery( cQryTot )
					
				TCQuery cQryTot New Alias (cAlQryTot)
				
				While ( cAlQryTot )->( !Eof() )
				
					If TAFXHMGet( oArqTot, cChvTot , @aPosTot )
						aPosTot[1,TOTALIZADOR_GOVERNO_VALOR_INSS] += ( cAlQryTot )->T2O_VRCPSE
						
						TAFXHMSet( oArqTot, aPosTot, cChvTot )
					EndIf
				
					( cAlQryTot )->( DBSkip() )
				EndDo		
					
				( cAlQryTot )->( DBCloseArea()) 
			EndIf
			
		EndIf

		cIDEstab	:=	""
		cIDLotac	:=	""
		cIDTrabal	:=	""
		cIDCateg	:=	""
		cTipo		:=	""
		cTipoBC		:=	""
		cCodCat		:=	""
		lAdd		:=	.F.
		lAddSemINSS	:=	.F.
		nBasINSS	:=	0
		nVlINSS		:=	0
		nSalFam		:=	0
		nSalMat		:=	0
		nBasINSS13	:=	0
		nVlINSS13	:=	0
		nSalMat13	:=	0
		nVlrSusp	:=	0
	EndDo

	( cAliasQry )->( DBCloseArea() )

	RestArea( aAreaC87 )
	RestArea( aAreaC92 )
	RestArea( aAreaC99 )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} PrintData
@type			function
@description	Função responsável por colher as informações do Evento S-5001 no retorno do Governo.
@author			Felipe C. Seolin
@since			16/08/2018
@version		1.0
@param			oMsgRun		-	Objeto do FWMsgRun
@param			cPath		-	Diretório selecionado para gravação do arquivo
@param			aArqTrb		-	Array com as informações para conferência
@param			cPeriodo	-	Período de referência das informações
@param			nDiverg		-	Opção selecionada para Listar apenas divergências
@param			lProtheus	-	Indica se a Origem dos dados parte do Protheus
@param			aArqTot		-	Array com as informações do totalizador para conferência
/*/
//---------------------------------------------------------------------
Static Function PrintData(oMsgRun, cPath, aArqTrb, cPeriodo, nDiverg, lProtheus, aArqTot)

	Local aEstab		:= {}
	Local aPosEstab		:= {}
	Local aResulTot		:= {}
	Local cAba			:= ""
	Local cTabela		:= ""
	Local cEstab		:= ""
	Local cEvtDesc		:= ""
	Local cStatusGov	:= ""
	Local cBarra 		:= ""
	Local cArquivo		:= "rel_s-5001_" + cPeriodo + "_" + DToS(MsDate()) + "_" + StrTran(Time(), ":", "") + ".xls"
	Local cDefPath		:= GetSrvProfString("StartPath", "\system\")
	Local cAba1         := "Totalizador de Valor INSS"
	Local lCabec		:= .T.
	Local lGerAba 		:= .F.
	Local lGer          := .F.
	Local lAba1			:= .F.
	Local lDiverg		:= nDiverg == 1
	Local lParanGr	    := SuperGetMv('MV_TAFGER', .F., .F.)
	Local nY			:= 0
	Local nEstab		:= 0
	Local nTotEstab	 	:= 0
	Local nCont 		:= 0
	Local nI			:= 0
	Local nINSSOrig		:= 0
	Local nINSSTAF		:= 0
	Local nINSSGov		:= 0
	Local nQtdTotal		:= Len(aArqTrb)
	Local oExcelApp		:= Nil
	Local oExcel		:= FWMSExcelEx():New()

	aSort( aArqTrb,,, { |x,y| x[1] < y[1] } ) 

	For nI := 1 to Len( aArqTrb )

		If nI == 1
			lCabec := .T.
		Else
			lCabec := cEstab <> aArqTrb[nI,2,1,ESTABELECIMENTO]
		EndIf
		
		If lParanGr .And. nI == 1
			lGerAba := .T.
		EndIf
		
		If lDiverg	
			If lProtheus .And. cPeriodo < "112019"
				If aArqTrb[nI,2,1,ALIAS] == "C91"
					nINSSOrig	:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS] + aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
					nINSSTAF	:=	aArqTrb[nI,2,1,TAF_VALOR_INSS] + aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
					nINSSGov	:=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS] + aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO]

					If !( nINSSOrig <> nINSSTAF .or. nINSSOrig <> nINSSGov .or. nINSSTAF <> nINSSGov ) .and.;
						!( aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] .or. aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] .or. aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] ) .and.;
						!( aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] .or. aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] .or. aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] ) .and.;
						!( aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .or. aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .or. aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] )
						nCont++
						Loop
					EndIf
				Else
					nINSSTAF := aArqTrb[nI,2,1,TAF_VALOR_INSS] + aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
					nINSSGov := aArqTrb[nI,2,1,GOVERNO_VALOR_INSS] + aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO]

					If !( nINSSTAF <> nINSSGov ) .and.;
						!( aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] ) .and.;
						!( aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] ) .and.;
						!( aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] )
						nCont++
						Loop
					EndIf
				EndIf
			Else
				nINSSOrig := aArqTrb[nI,2,1,FOLHA_VALOR_INSS] + aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
				nINSSTAF := aArqTrb[nI,2,1,TAF_VALOR_INSS] + aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
				nINSSGov := aArqTrb[nI,2,1,GOVERNO_VALOR_INSS] + aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO]

				If !( nINSSOrig <> nINSSTAF .or. nINSSOrig <> nINSSGov .or. nINSSTAF <> nINSSGov ) .and.;
					!( aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] .or. aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] .or. aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] ) .and.;
					!( aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] .or. aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] .or. aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] ) .and.;
					!( aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .or. aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .or. aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] )
					nCont++
					Loop
				EndIf
			EndIf
		EndIf

		If lCabec .And. lGerAba
			
			lGer := .T.
			cAba := "INSS - BASE DE CÁLCULO"

			If Len( AllTrim( cPeriodo ) ) == 4 //Décimo Terceiro
				cTabela := "Periodo_" + cPeriodo + " - " + "Estabelecimento_" + AllTrim( cEstab )
				cTabAb1 := "Periodo_" + cPeriodo + " - " + "Totalizador"
			Else
				cTabela := "Periodo_" + SubStr( cPeriodo, 1, 2 ) + "/" + SubStr( cPeriodo, 3, 4 ) + " - " + "Estabelecimento_" + AllTrim( cEstab )
				cTabAb1 := "Periodo_" + SubStr( cPeriodo, 1, 2 ) + "/" + SubStr( cPeriodo, 3, 4 ) + " - " + "Totalizador"
			EndIf

			aAdd(aEstab,{cAba})
		
			oExcel:AddWorkSheet( cAba )
			oExcel:AddTable( cAba, cTabela )

			oExcel:AddColumn( cAba, cTabela, "Tipo Funcionário", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "CPF", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Nome", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Matrícula", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Categoria", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Lotação", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Evento eSocial", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Tipo de Base de Cálculo", 1, 1, .F. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Base INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Base INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Base INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Suspensão Judicial", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Base INSS Total", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor INSS", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor Salário-Família", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor Salário-Família", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor Salário-Família", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor Salário-Maternidade", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor Salário-Maternidade", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor Salário-Maternidade", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Base INSS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Base INSS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Base INSS - 13° Salário", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor INSS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor INSS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor INSS - 13° Salário", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor Salário-Maternidade - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor Salário-Maternidade - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor Salário-Maternidade - 13° Salário", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Observação", 1, 1, .F. )

		ElseIf lCabec .And. !lGerAba .And. !lGer

			cEstab := aArqTrb[nI,2,1,ESTABELECIMENTO]
		
			cAba := AllTrim( cEstab )
			
			If Empty(cAba)
				cAba := "ESTABELECIMENTO DESCONHECIDO"
			EndIf

			If Len( AllTrim( cPeriodo ) ) == 4 //Décimo Terceiro
				cTabela := "Periodo_" + cPeriodo + " - " + "Estabelecimento_" + AllTrim( cEstab )
				cTabAb1 := "Periodo_" + cPeriodo + " - " + "Totalizador"
			Else
				cTabela := "Periodo_" + SubStr( cPeriodo, 1, 2 ) + "/" + SubStr( cPeriodo, 3, 4 ) + " - " + "Estabelecimento_" + AllTrim( cEstab )
				cTabAb1 := "Periodo_" + SubStr( cPeriodo, 1, 2 ) + "/" + SubStr( cPeriodo, 3, 4 ) + " - " + "Totalizador"
			EndIf
			
			aAdd(aEstab,{cAba})
			
			oExcel:AddWorkSheet( cAba )
			oExcel:AddTable( cAba, cTabela )

			oExcel:AddColumn( cAba, cTabela, "Tipo Funcionário", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "CPF", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Nome", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Matrícula", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Categoria", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Lotação", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Evento eSocial", 1, 1, .F. )
			oExcel:AddColumn( cAba, cTabela, "Tipo de Base de Cálculo", 1, 1, .F. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Base INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Base INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Base INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Suspensão Judicial", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Base INSS Total", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor INSS", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor INSS", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor Salário-Família", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor Salário-Família", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor Salário-Família", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor Salário-Maternidade", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor Salário-Maternidade", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor Salário-Maternidade", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Base INSS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Base INSS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Base INSS - 13° Salário", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor INSS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor INSS - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor INSS - 13° Salário", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Folha - Valor Salário-Maternidade - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "TAF - Valor Salário-Maternidade - 13° Salário", 1, 3, .T. )
			oExcel:AddColumn( cAba, cTabela, "Governo - Valor Salário-Maternidade - 13° Salário", 1, 3, .T. )

			oExcel:AddColumn( cAba, cTabela, "Observação", 1, 1, .F. )

		EndIf 

		If aArqTrb[nI,2,1,ALIAS] == "C91"
			cEvtDesc := "Remuneração ( S-1200 )"
		ElseIf aArqTrb[nI,2,1,ALIAS] == "CMD"
			cEvtDesc := "Desligamento ( S-2299 )"
		ElseIf aArqTrb[nI,2,1,ALIAS] == "T92"
			cEvtDesc := "Término TSV ( S-2399 )"
		EndIf

		If Empty( aArqTrb[nI,2,1,RECIBO_TRANSMISSAO] )
			cStatusGov := "Não Transmitido"
		ElseIf !aArqTrb[nI,2,1,GOVERNO_LOCALIZADO]
			cStatusGov := "Não Localizado"
		Else
			cStatusGov := ""
		EndIf

		oExcel:AddRow(	cAba,;
						cTabela,;
						{	aArqTrb[nI,2,1,TIPO_FUNCIONARIO],;
							aArqTrb[nI,2,1,CPF],;
							aArqTrb[nI,2,1,NOME],;
							aArqTrb[nI,2,1,MATRICULA],;
							aArqTrb[nI,2,1,CATEGORIA],;
							aArqTrb[nI,2,1,LOTACAO],;
							aArqTrb[nI,2,1,EVENTO_ESOCIAL],;
							aArqTrb[nI,2,1,TIPO_BASE_CALCULO],;
							aArqTrb[nI,2,1,FOLHA_BASE_INSS],;
							aArqTrb[nI,2,1,TAF_BASE_INSS],;
							Iif( Empty( cStatusGov ), aArqTrb[nI,2,1,GOVERNO_BASE_INSS] - aArqTrb[nI,2,1,GOVERNO_BASE_SUSPENSAO], cStatusGov ),;
							Iif( Empty( cStatusGov ), aArqTrb[nI,2,1,GOVERNO_BASE_SUSPENSAO], cStatusGov ),; //Suspensão Judicial
							Iif( Empty( cStatusGov ), aArqTrb[nI,2,1,GOVERNO_BASE_INSS], cStatusGov ),; //Total Base INSS
							aArqTrb[nI,2,1,FOLHA_VALOR_INSS],;
							aArqTrb[nI,2,1,TAF_VALOR_INSS],;
							Iif( Empty( cStatusGov ), aArqTrb[nI,2,1,GOVERNO_VALOR_INSS], cStatusGov ),;
							aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA],;
							aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA],;
							Iif( Empty( cStatusGov ), aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA], cStatusGov ),;
							aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE],;
							aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE],;
							Iif( Empty( cStatusGov ), aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE], cStatusGov ),;
							aArqTrb[nI,2,1,FOLHA_BASE_INSS_13_SALARIO],;
							aArqTrb[nI,2,1,TAF_BASE_INSS_13_SALARIO],;
							Iif( Empty( cStatusGov ), aArqTrb[nI,2,1,GOVERNO_BASE_INSS_13_SALARIO], cStatusGov ),;
							aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO],;
							aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO],;
							Iif( Empty( cStatusGov ), aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO], cStatusGov ),;
							aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO],;
							aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO],;
							Iif( Empty( cStatusGov ), aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO], cStatusGov ),;
							aArqTrb[nI,2,1,OBSERVACAO] } )


		SetIncPerc( oMsgRun, "Print", nQtdTotal, nI )
		lGerAba := .F.

	Next nI

	If nCont == Len( aArqTrb )
		MSGALERT( "Não há registros divergentes", "Atenção" )
	Else

		lAba1 := .T.

		For nY := 1 To Len(aArqTot)
			
			If lDiverg
				If !( aArqTot[nY,2,1,TOTALIZADOR_FOLHA_VALOR_INSS] <> aArqTot[nY,2,1,TOTALIZADOR_TAF_VALOR_INSS] .or.;
						aArqTot[nY,2,1,TOTALIZADOR_FOLHA_VALOR_INSS] <> aArqTot[nY,2,1,TOTALIZADOR_GOVERNO_VALOR_INSS] .or.;
							aArqTot[nY,2,1,TOTALIZADOR_TAF_VALOR_INSS] <> aArqTot[nY,2,1,TOTALIZADOR_GOVERNO_VALOR_INSS] )
					Loop
				EndIf	
			EndIf
			
			aResulTot := {}
			
			AAdd(aResulTot, aArqTot[nY, 2, 1, CPF_TRABALHADOR])
			AAdd(aResulTot, aArqTot[nY, 2, 1, NOME_TRABALHADOR])
			AAdd(aResulTot, aArqTot[nY, 2, 1, EVENTO_ESOCIAL_TOTALIZADOR])
			AAdd(aResulTot, aArqTot[nY, 2, 1, TOTALIZADOR_FOLHA_VALOR_INSS])
			AAdd(aResulTot, aArqTot[nY, 2, 1, TOTALIZADOR_TAF_VALOR_INSS])
			AAdd(aResulTot, aArqTot[nY, 2, 1, TOTALIZADOR_GOVERNO_VALOR_INSS])

			For nEstab := 1 to Len(aEstab)
				
				If TAFXHMGet(oArqEst, aArqTot[nY,2,1,CPF_TRABALHADOR]+aEstab[nEstab][1]+aArqTot[nY,2,1,EVENTO_ESOCIAL_TOTALIZADOR], @aPosEstab )
					nTotEstab := aPosEstab[1,TOTALIZADOR_ESTABELECIMENTO]
					AAdd(aResulTot ,nTotEstab)
				Else
					AAdd(aResulTot ,0)
				EndIf
				
			Next
			
			If lAba1

				lAba1 := .F.

				oExcel:AddWorkSheet(cAba1)
				oExcel:AddTable(cAba1, cTabAb1)

				oExcel:AddColumn(cAba1, cTabAb1, "CPF"					, 1, 1, .F.)
				oExcel:AddColumn(cAba1, cTabAb1, "Nome"					, 1, 1, .F.)
				oExcel:AddColumn(cAba1, cTabAb1, "Evento eSocial"		, 1, 1, .F.)

				oExcel:AddColumn(cAba1, cTabAb1, "Folha - Valor INSS"	, 1, 3, .T.)
				oExcel:AddColumn(cAba1, cTabAb1, "TAF - Valor INSS"		, 1, 3, .T.)
				oExcel:AddColumn(cAba1, cTabAb1, "Governo - Valor INSS"	, 1, 3, .T.)

				For nEstab := 1 To Len(aEstab)
					oExcel:AddColumn(cAba1, cTabAb1, "TAF Estab. "+ aEstab[nEstab][1], 1, 3, .T.)	
				Next

			EndIf

			oExcel:AddRow(cAba1, cTabAb1, aResulTot)

		Next

		aSize(aEstab,0)

		If !Empty( oExcel:aWorkSheet )
			oExcel:Activate()
			oExcel:GetXMLFile( cArquivo )

			//Para ambiente Smart, não conseguimos abrir oOleClient e por isto avisamos sobre o envio por email.
			If GetRemoteType() ==  5 // WebAPP

				nOpc := Aviso("TAF","Selecione a opção de envio",{"Download","Email"}) // "E-mail: relatório será enviado para o e-mail cadastrado para o usuário.", 'Download','E-mail'
				
				If nOpc == 1
					nRet := CpyS2TW( cDefPath + cArquivo , .T. )

					IIF((nRet == 0),MsgAlert("Download concluído com sucesso.", "Atenção"),TAFConOut("Falha na copia" + str(nRet) + str(nRet))) 
				Else
					cBarra  := 	Iif ( IsSrvUnix() , "/" , "\" )
					cPath := cBarra + cArquivo
					If __CopyFile( cDefPath + cArquivo,cPath)
						cPara	 :=	AllTrim(FWSFUser( __cUserId, "DATAUSER", "USR_EMAIL" ))
						cAssunto := "SMART eSocial| Relatório de conferência do evento S-5001. Extraido em: " + Dtoc(MsDate()) + " - " + Time()
						cAnexo	 := cArquivo //Em uma determinada versão de binário a função SEND MAIL parou de reconhecer os arquivos com / no inicio do Path.
						cMsg	 := TAFGetHmtl()

						If !(TAFSETMAIL( /*cDe*/,;
									cPara,;
									/*cCc*/,;
									/*cCCO*/,;
									cAssunto,;
									cAnexo,;
									cMsg,;
									/*cServer*/,;
									/*cEmail*/,;
									/*cPass*/,;
									/*lAuth*/,;
									/*cContAuth*/,;
									/*cPswAuth*/,;
									/*lSSL*/,;
									/*lTLS*/))

							MsgAlert('Erro ao enviar email! Arquivo salvo na pasta ' + cPath + ".")
						Else

							MsgAlert('Enviado o relatorio para o email: ' + cPara + '. Verifique a sua caixa de e-mail!')
							FErase(cPath)
						EndIf
					Else
						MsgAlert('Não foi possível realizar a cópia do arquivo ' + cAnexo)
					EndIf 
				EndIf
				
			ElseIf ApOleClient( "MSExcel" )
				__CopyFile( cDefPath + cArquivo, cPath + cArquivo )
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cPath + cArquivo ) //Abre a planilha
				oExcelApp:SetVisible( .T. )
			Else
				__CopyFile( cDefPath + cArquivo, cPath + cArquivo )
			EndIf
		EndIf
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIncPerc
@type			function
@description	Incrementa o progresso realizado.
@author			Felipe C. Seolin
@since			04/09/2018
@version		1.0
@param			oMsgRun		-	Objeto do FWMsgRun
@param			cEtapa		-	Etapa em curso de execução
@param			nQtdTotal	-	Quantidade total de registros a processar
@param			nQtdProc	-	Quantidade de registros processados
/*/
//---------------------------------------------------------------------
Static Function SetIncPerc( oMsgRun, cEtapa, nQtdTotal, nQtdProc )

Local cMessage	:=	""
Local cPercent	:=	cValToChar( Int( ( nQtdProc / nQtdTotal ) * 100 ) )

If cEtapa == "S-1200"
	cMessage := I18N( "#1 #2 - Progresso: #3%", { "Consultando", "Folha", cPercent } )
ElseIf cEtapa == "S-2299"
	cMessage := I18N( "#1 #2 - Progresso: #3%", { "Consultando", "Desligamento", cPercent } )
ElseIf cEtapa == "S-2399"
	cMessage := I18N( "#1 #2 - Progresso: #3%", { "Consultando", "Término TSV", cPercent } )
ElseIf cEtapa == "Print"
	cMessage := I18N( "#1 #2 - Progresso: #3%", { "Processando", "Relatório", cPercent } )
EndIf

oMsgRun:cCaption := cMessage
ProcessMessages()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR120Vld
@type			function
@description	Validação dos campos do Grupo de Perguntas TAFR120.
@author			Felipe C. Seolin
@since			24/08/2018
@version		1.0
@param			cCampo	-	Campo executor da validação
@return			lRet	-	Indicador de operação válida/inválida
/*/
//---------------------------------------------------------------------
Function TAFR120Vld( cCampo )

Local cMes		:=	""
Local cAno		:=	""
Local cPeriodo	:=	""
Local lRet		:=	.T.

If cCampo == "MV_PAR01" .and. !Empty( MV_PAR01 )

	cPeriodo := MV_PAR01

	If Len( AllTrim( cPeriodo ) ) == 4 .And. Val( AllTrim( cPeriodo ) ) < 2018 //Décimo Terceiro
		lRet := .F.
		Help( ,, "Atenção",, "Período informado é anterior ao início do envio dos eventos periódicos do eSocial.", 1, 0 )

	ElseIf Len( AllTrim( cPeriodo ) ) == 6

		cMes := SubStr( MV_PAR01, 1, 2 )
		cAno := SubStr( MV_PAR01, 3, 4 )

		If Val( cMes ) > 12 .or. Val( cMes ) <= 0
			lRet := .F.
			Help( ,, "Atenção",, "Mês informado inválido.", 1, 0 )
		ElseIf Val( cAno ) < 2018 .or. ( Val( cAno ) == 2018 .and. Val( cMes ) < 5 )
			lRet := .F.
			Help( ,, "Atenção",, "Período informado é anterior ao início do envio dos eventos periódicos do eSocial.", 1, 0 )
		EndIf
	EndIf

ElseIf cCampo == "MV_PAR02" .and. !Empty( MV_PAR02 )
	If !( cValToChar( MV_PAR02 ) $ "1|2" )
		lRet := .F.
		Help( ,, "Atenção",, "A opção selecionada é inválida.", 1, 0 )
	EndIf

ElseIf cCampo == "MV_PAR04" .and. !Empty( MV_PAR04 )
	If !CGC( MV_PAR04 )
		lRet := .F.
		Help( ,, "Atenção",, "O CPF informado é inválido.", 1, 0 )
	EndIf
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR120Dic
@type			function
@description	Verifica a existência do dicionário necessário para a execução do programa.
@author			Felipe C. Seolin
@since			03/09/2018
@version		1.0
@param			cPerg		-	Grupo de Perguntas utilizado no programa
@param			lNewParam	-	Indica se deve executar a validação para as novas perguntas do SX1
@param			lShowMsg	-	Indica se deve mostrar a mensagem de erro
@return			lRet		-	Indica se o dicionário está aplicado no ambiente
/*/
//---------------------------------------------------------------------
Function TAFR120Dic( cPerg, lNewParam, lShowMsg )

Local lRet	:=	.T.

Default lNewParam	:=	.F.
Default lShowMsg	:=	.T.

DBSelectArea( "SX1" )
SX1->( DBSetOrder( 1 ) )

If !SX1->( MsSeek( cPerg + "01" ) )
	lRet := .F.
EndIf

If !SX1->( MsSeek( cPerg + "02" ) )
	lRet := .F.
EndIf

If lNewParam
	If !SX1->( MsSeek( cPerg + "03" ) )
		lRet := .F.
	EndIf

	If !SX1->( MsSeek( cPerg + "04" ) )
		lRet := .F.
	EndIf
EndIf

If !lRet .and. lShowMsg
	Aviso( "Dicionário Incompatível", "O ambiente do TAF está com o dicionário de dados incompatível com a versão do programa TAFR120";
			+ " existente no repositório de dados, este problema ocorre devido a não execução dos compatibilizadores do produto.";
			+ " Execute o compatibilizador de dicionário indicado para execução deste programa!", { "Encerrar" }, 2 )
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCodCat
@type			Static function
@description	Busca a categoria do trabalhador se houver alteração de cadastro (S2206\S2306).
@author			TAF E-social
@since			01/03/2019
@version		1.0
@param			cNomEve	-	Nome do evento
@param			cFilTrb	-	Filial do trabalhador posicionado
@param			cID		-	ID do trabalhador posicionado
@param			cPeriod	-	Data informada no Pergunte utilizado no programa
@return			cRet	-	Categoria do Trabalhador
/*/
//---------------------------------------------------------------------
Static Function GetCodCat( cNomEve, cFilTrb, cID, cPeriod )

	Local cAlias1	:=  "rsR120D"
	Local cSelect	:=	""
	Local cFrom		:=	""
	Local cWhere	:=	""
	Local cRet		:=	""

	If !Empty( cNomEve ) .and. AllTrim( cNomEve ) <> "TAUTO"

		If cNomEve == "S2200"

			cSelect := "T1V_CODCAT"

			cFrom   := RetSqlName( "T1V" ) + " T1V " 										

			cWhere := " T1V.T1V_FILIAL = '" + cFilTrb + "' "
			cWhere += " AND T1V.T1V_ID = '"+ cID + "' "

			If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
				cWhere += " AND SUBSTR(T1V.T1V_DTALT,1,6) <= '" + SubStr( cPeriod, 3, 4 ) + SubStr( cPeriod, 1, 2 ) + "' "
			Else
				cWhere += " AND SUBSTRING(T1V.T1V_DTALT,1,6) <= '" + SubStr( cPeriod, 3, 4 ) + SubStr( cPeriod, 1, 2 ) + "' "
			EndIf

			cWhere += " AND T1V.D_E_L_E_T_ = '' "
			cWhere += " ORDER BY T1V.T1V_DTALT DESC "

		ElseIf cNomEve == "S2300"

			cSelect := "T0F_CATAV"

			cFrom +=  RetSqlName( "T0F" ) + " T0F "

			cWhere := " T0F.T0F_FILIAL = '" + cFilTrb + "' "
			cWhere += " AND T0F.T0F_ID = '"+ cID + "' "

			If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"
				cWhere += " AND SUBSTR(T0F.T0F_DTALT,1,6) <= '" + SubStr( cPeriod, 3, 4 ) + SubStr( cPeriod, 1, 2 ) + "' "
			Else
				cWhere += " AND SUBSTRING(T0F.T0F_DTALT,1,6) <= '" + SubStr( cPeriod, 3, 4 ) + SubStr( cPeriod, 1, 2 ) + "' "
			EndIf

			cWhere += " AND T0F.D_E_L_E_T_ = '' "
			cWhere += " ORDER BY T0F.T0F_DTALT DESC "

		EndIf

		cSelect	:= "%" + cSelect	+ "%"
		cFrom	:= "%" + cFrom		+ "%"
		cWhere	:= "%" + cWhere		+ "%"

		If Select(cAlias1) > 0
			(cAlias1)->(DbCloseArea())
		EndIf

		BeginSql Alias cAlias1
			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%
		EndSql

		( cAlias1 )->(DbGoTop())

		If ( cAlias1 )->( !Eof() )

			If cNomEve == "S2200"
				cRet := ( cAlias1 )->T1V_CODCAT
			ElseIf cNomEve == "S2300"
				cRet := ( cAlias1 )->T0F_CATAV
			EndIf
		
		Else

			//Se não tiver alterações de categoria procuro a categoria nas tabelas de origem do cadastro inicial
			cSelect	:= ""
			cFrom	:= ""
			cWhere	:= ""

			If cNomEve == "S2200"

				cSelect := "CUP.CUP_CODCAT"
				cFrom 	+=  RetSqlName( "CUP" ) + " CUP "
				cWhere 	:= " CUP.CUP_FILIAL = '" + cFilTrb + "' "
				cWhere 	+= " AND CUP.CUP_ID = '"+ cID + "' "
				cWhere 	+= " AND CUP.D_E_L_E_T_ = '' "
				cWhere 	+= " ORDER BY CUP.CUP_VERSAO DESC "

				cSelect	:= "%" + cSelect	+ "%"
				cFrom	:= "%" + cFrom		+ "%"
				cWhere	:= "%" + cWhere		+ "%"

				If Select(cAlias1) > 0
					(cAlias1)->(DbCloseArea())
				EndIf

				BeginSql Alias cAlias1
					SELECT
						%Exp:cSelect%
					FROM
						%Exp:cFrom%
					WHERE
						%Exp:cWhere%
				EndSql

				( cAlias1 )->(DbGoTop())

				If ( cAlias1 )->( !Eof() )

					cRet := ( cAlias1 )->CUP_CODCAT

				EndIf

			ElseIf cNomEve == "S2300"

				cSelect := "C9V.C9V_CATCI"
				cFrom 	+=  RetSqlName( "C9V" ) + " C9V "
				cWhere 	:= " C9V.C9V_FILIAL = '" + cFilTrb + "' "
				cWhere 	+= " AND C9V.C9V_ID = '"+ cID + "' "
				cWhere 	+= " AND C9V.C9V_ATIVO = '1' "
				cWhere 	+= " AND C9V.D_E_L_E_T_ = '' "

				cSelect	:= "%" + cSelect	+ "%"
				cFrom	:= "%" + cFrom		+ "%"
				cWhere	:= "%" + cWhere		+ "%"

				If Select(cAlias1) > 0
					(cAlias1)->(DbCloseArea())
				EndIf

				BeginSql Alias cAlias1
					SELECT
						%Exp:cSelect%
					FROM
						%Exp:cFrom%
					WHERE
						%Exp:cWhere%
				EndSql

				( cAlias1 )->(DbGoTop())

				If ( cAlias1 )->( !Eof() )

					cRet := ( cAlias1 )->C9V_CATCI

				EndIf

			EndIf
		
		EndIf

		( cAlias1 )->( DBCloseArea() )

	EndIf

Return( cRet )

Static Function TAFGetHmtl()
	Local cMsg := ""

	cMsg+='<html>'
	cMsg+='<head>'
	cMsg+='<title>EMKT - Smart eSocial</title>'
	cMsg+='<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
	cMsg+='</head>'
	cMsg+='<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">'
	cMsg+='<!-- Save for Web Slices (emkt_Smart_Analytics_v2.psd) -->'
	cMsg+='<table width="700" height="auto" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;" align="center" idforbackup="rkydbecohjok">'
	cMsg+='	<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='	<tr valign="top" style="font-size: 0;" bgcolor="#f0f1f2">'
	cMsg+='		<td width="700" height="257" valign="top" style="font-size: 0;">'
	cMsg+='			<table width="700" height="257" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='				<tr valign="top" style="font-size: 0;">'
	cMsg+='					<td width="700" height="257" valign="top" style="font-size: 0;">'
	cMsg+='						<table width="700" height="257" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='							<tr valign="top" style="font-size: 0;">'
	cMsg+='								<td width="700" height="257" valign="top" style="font-size: 0;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_01.jpg" width="700" height="257" border="0" style="display: block; border: 0;" alt="SMART eSocial - TOTVS" title="SMART eSocial - TOTVS"></td>'
	cMsg+='							</tr>'
	cMsg+='							</tbody>'
	cMsg+='						</table>'
	cMsg+='					</td>'
	cMsg+='				</tr>'
	cMsg+='				</tbody>'
	cMsg+='			</table>'
	cMsg+='		</td>'
	cMsg+='	</tr>'
	cMsg+='	<tr valign="top" style="font-size: 0;" bgcolor="#f0f1f2">'
	cMsg+='		<td width="700" height="0" valign="top" style="font-size: 0;">'
	cMsg+='			<table width="700" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='				<tr valign="top" style="font-size: 0;">'
	cMsg+='					<td width="700" height="0" valign="top" style="font-size: 0;">'
	cMsg+='						<table width="700" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='							<tr valign="top" style="font-size: 0;">'
	cMsg+='								<td width="60" height="0" valign="top" style="font-size: 0;" bgcolor="#f0f1f2"></td>'
	cMsg+='								<td width="580" height="0" valign="top" style="font-size: 0;">'
	cMsg+='									<table width="580" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='										<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='										<tr valign="top" style="font-size: 0;">'
	cMsg+='											<td width="580" height="54" valign="top" style="font-size: 0;">'
	cMsg+='												<table width="580" height="54" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='													<tr valign="top" style="font-size: 0;">'
	cMsg+='														<td width="580" height="54" valign="top" style="font-size: 0;">'
	cMsg+='															<table width="580" height="54" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='																<tr valign="top" style="font-size: 0;">'
	cMsg+='																</tr>'
	cMsg+='																</tbody>'
	cMsg+='															</table>'
	cMsg+='														</td>'
	cMsg+='													</tr>'
	cMsg+='													</tbody>'
	cMsg+='												</table>'
	cMsg+='											</td>'
	cMsg+='										</tr>'
	cMsg+='										<tr valign="top" style="font-size: 0;">'
	cMsg+='											<td width="580" height="36" valign="top" style="font-size: 0;">'
	cMsg+='												<table width="580" height="36" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='													<tr valign="top" style="font-size: 0;">'
	cMsg+='														<td width="580" height="36" valign="top" style="font-size: 0;">'
	cMsg+='															<table width="580" height="36" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='																<tr valign="top" style="font-size: 0;">'
	cMsg+='																</tr>'
	cMsg+='																</tbody>'
	cMsg+='															</table>'
	cMsg+='														</td>'
	cMsg+='													</tr>'
	cMsg+='													</tbody>'
	cMsg+='												</table>'
	cMsg+='											</td>'
	cMsg+='										</tr>'
	cMsg+='										<tr valign="top" style="font-size: 0;">'
	cMsg+='											<td width="580" height="0" valign="top" style="font-size: 0;" bgcolor="#f0f1f2">'
	cMsg+='												<table width="580" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='													<tr valign="top" style="font-size: 0;">'
	cMsg+='														<td width="580" height="0" valign="top" style="font-size: 0;">'
	cMsg+='															<table width="580" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='																<tr valign="top" style="font-size: 0;">'
	cMsg+='                                                              	<td width="580" height="0" valign="top" style="font-size: 0; text-align: left;" bgcolor="#f0f1f2"><span style="color: #494440;font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif;font-size: 14px;font-weight: 400;font-style: normal;line-height: 1.6;">'
	cMsg+='																	<h1><b> Olá, ' + Substring( Alltrim(cUsuario) ,7 ,15) + '</b></h1>'
	cMsg+='																		<br>Estamos encaminhando por anexo o relatório de conferência de INSS, confome solicitado pelo aplicativo do SMART eSocial.<br><br><br>' 
	cMsg+='																		</span></td>'
	cMsg+='																</tr>'
	cMsg+='																</tbody>'
	cMsg+='															</table>'
	cMsg+='														</td>'
	cMsg+='													</tr>'
	cMsg+='													</tbody>'
	cMsg+='												</table>'
	cMsg+='											</td>'
	cMsg+='										</tr>'
	cMsg+='										<tr valign="top" style="font-size: 0;">'
	cMsg+='											<td width="580" height="18" valign="top" style="font-size: 0;">'
	cMsg+='												<table width="580" height="18" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='													<tr valign="top" style="font-size: 0;">'
	cMsg+='														<td width="580" height="18" valign="top" style="font-size: 0;">'
	cMsg+='															<table width="580" height="18" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='																<tr valign="top" style="font-size: 0;">'
	cMsg+='																	<td width="580" height="18" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#f0f1f2"><span style="color: #494440; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 14px; font-weight: 700; font-style: normal; line-height: normal;">Atenciosamente,</span></td>'
	cMsg+='																</tr>'
	cMsg+='																</tbody>'
	cMsg+='															</table>'
	cMsg+='														</td>'
	cMsg+='													</tr>'
	cMsg+='													</tbody>'
	cMsg+='												</table>'
	cMsg+='											</td>'
	cMsg+='										</tr>'
	cMsg+='										<tr valign="top" style="font-size: 0;">'
	cMsg+='											<td width="580" height="53" valign="top" style="font-size: 0;">'
	cMsg+='												<table width="580" height="53" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='													<tr valign="top" style="font-size: 0;">'
	cMsg+='														<td width="580" height="53" valign="top" style="font-size: 0;">'
	cMsg+='															<table width="580" height="53" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='																<tr valign="top" style="font-size: 0;">'
	cMsg+='																	<td width="580" height="53" valign="top" style="font-size: 0; text-align: left;" bgcolor="#f0f1f2"><span style="color: #139dc0; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 16px; font-weight: 700; font-style: normal; line-height: normal;">Equipe Smart Fiscal TOTVS</span></td>'
	cMsg+='																</tr>'
	cMsg+='																</tbody>'
	cMsg+='															</table>'
	cMsg+='														</td>'
	cMsg+='													</tr>'
	cMsg+='													</tbody>'
	cMsg+='												</table>'
	cMsg+='											</td>'
	cMsg+='										</tr>'
	cMsg+='										</tbody>'
	cMsg+='									</table>'
	cMsg+='								</td>'
	cMsg+='								<td width="60" height="0" valign="top" style="font-size: 0;" bgcolor="#f0f1f2"></td>'
	cMsg+='							</tr>'
	cMsg+='							</tbody>'
	cMsg+='						</table>'
	cMsg+='					</td>'
	cMsg+='				</tr>'
	cMsg+='				</tbody>'
	cMsg+='			</table>'
	cMsg+='		</td>'
	cMsg+='	</tr>'
	cMsg+='	<tr valign="top" style="font-size: 0;">'
	cMsg+='		<td width="700" height="29" valign="top" style="font-size: 0;">'
	cMsg+='			<table width="700" height="29" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='				<tr valign="top" style="font-size: 0;">'
	cMsg+='					<td width="700" height="29" valign="top" style="font-size: 0;">'
	cMsg+='						<table width="700" height="29" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='							<tr valign="top" style="font-size: 0;">'
	cMsg+='								<td width="60" height="29" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="580" height="29" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="60" height="29" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='							</tr>'
	cMsg+='							</tbody>'
	cMsg+='						</table>'
	cMsg+='					</td>'
	cMsg+='				</tr>'
	cMsg+='				</tbody>'
	cMsg+='			</table>'
	cMsg+='		</td>'
	cMsg+='	</tr>'
	cMsg+='	<tr valign="top" style="font-size: 0;">'
	cMsg+='		<td width="700" height="48" valign="top" style="font-size: 0;">'
	cMsg+='			<table width="700" height="48" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='				<tr valign="top" style="font-size: 0;">'
	cMsg+='					<td width="700" height="48" valign="top" style="font-size: 0;">'
	cMsg+='						<table width="700" height="48" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='							<tr valign="top" style="font-size: 0;">'
	cMsg+='								<td width="60" height="48" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="261" height="48" valign="top" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #ffffff; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 19px; font-weight: 700; font-style: normal; line-height: normal;">Interaja conosco <br>nas redes sociais'
	cMsg+='<span style="color: #000000;font-size: 4px;line-height: 25px;">a</span>'
	cMsg+='<br></span></td>'
	cMsg+='								<td width="36" height="48" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="283" height="48" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #ffffff; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 19px; font-weight: 700; font-style: normal; line-height: normal;">Quer saber mais sobre <br>a TOTVS?'
	cMsg+='<span style="color: #000000;font-size: 4px;line-height: 25px;">a</span></span></td>'
	cMsg+='								<td width="60" height="48" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='							</tr>'
	cMsg+='							</tbody>'
	cMsg+='						</table>'
	cMsg+='					</td>'
	cMsg+='				</tr>'
	cMsg+='				</tbody>'
	cMsg+='			</table>'
	cMsg+='		</td>'
	cMsg+='	</tr>'
	cMsg+='	<tr valign="top" style="font-size: 0;" bgcolor="#000000">'
	cMsg+='		<td width="700" height="40" valign="top" style="font-size: 0;">'
	cMsg+='			<table width="700" height="40" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='				<tr valign="top" style="font-size: 0;">'
	cMsg+='					<td width="700" height="40" valign="top" style="font-size: 0;">'
	cMsg+='						<table width="700" height="40" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='							<tr valign="top" style="font-size: 0;">'
	cMsg+='								<td width="60" height="40" valign="top" style="font-size: 0;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_24.jpg" width="60" height="40" border="0" style="display: block; border: 0;" alt="" title=""></td>'
	cMsg+='								<td width="32" height="40" valign="top" style="font-size: 0;"><a href="https://www.linkedin.com/company/totvs" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_25.jpg" width="32" height="40" border="0" style="display: block; border: 0;" alt="Linkedin" title="Linkedin"></a></td>'
	cMsg+='								<td width="32" height="40" valign="top" style="font-size: 0;"><a href="https://www.facebook.com/totvs" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_26.jpg" width="32" height="40" border="0" style="display: block; border: 0;" alt="Facebook" title="Facebook"></a></td>'
	cMsg+='								<td width="32" height="40" valign="top" style="font-size: 0;"><a href="https://www.instagram.com/totvsbrasil/" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_27.jpg" width="32" height="40" border="0" style="display: block; border: 0;" alt="Instagran" title="Instagran"></a></td>'
	cMsg+='								<td width="32" height="40" valign="top" style="font-size: 0;"><a href="https://www.youtube.com/totvs" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_28.jpg" width="32" height="40" border="0" style="display: block; border: 0;" alt="Youtube" title="Youtube"></a></td>'
	cMsg+='								<td width="133" height="40" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="36" height="40" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="283" height="40" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #989898; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 16px; font-weight: 400; font-style: normal; line-height: normal;">Assine nossa newsletter e fique <br>por dentro das novidades.</span></td>'
	cMsg+='								<td width="60" height="40" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='							</tr>'
	cMsg+='							</tbody>'
	cMsg+='						</table>'
	cMsg+='					</td>'
	cMsg+='				</tr>'
	cMsg+='				</tbody>'
	cMsg+='			</table>'
	cMsg+='		</td>'
	cMsg+='	</tr>'
	cMsg+='	<tr valign="top" style="font-size: 0;">'
	cMsg+='		<td width="700" height="33" valign="top" style="font-size: 0;">'
	cMsg+='			<table width="700" height="33" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='				<tr valign="top" style="font-size: 0;">'
	cMsg+='					<td width="700" height="33" valign="top" style="font-size: 0;">'
	cMsg+='						<table width="700" height="33" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='							<tr valign="top" style="font-size: 0;">'
	cMsg+='								<td width="60" height="33" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="261" height="33" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #ffffff; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 19px; font-weight: 700; font-style: normal; line-height: normal;">Ou entre em contato</span></td>'
	cMsg+='								<td width="36" height="33" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="283" height="33" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="60" height="33" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='							</tr>'
	cMsg+='							</tbody>'
	cMsg+='						</table>'
	cMsg+='					</td>'
	cMsg+='				</tr>'
	cMsg+='				</tbody>'
	cMsg+='			</table>'
	cMsg+='		</td>'
	cMsg+='	</tr>'
	cMsg+='	<tr valign="top" style="font-size: 0;">'
	cMsg+='		<td width="700" height="49" valign="top" style="font-size: 0;">'
	cMsg+='			<table width="700" height="49" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='				<tr valign="top" style="font-size: 0;">'
	cMsg+='					<td width="700" height="49" valign="top" style="font-size: 0;">'
	cMsg+='						<table width="700" height="49" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='							<tr valign="top" style="font-size: 0;">'
	cMsg+='								<td width="60" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="142" height="49" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #989898; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 16px; font-weight: 400; font-style: normal; line-height: normal;">LIGUE<br><span style="color: #e38f2b;font-weight: bold;">0800 70 98 100</span></span></td>'
	cMsg+='								<td width="119" height="49" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #989898; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 16px; font-weight: 400; font-style: normal; line-height: normal;">ACESSE<br><a href="https://v4.aloweb.com.br/chat/atendimentos/standalone?token=z0lIts0hQQCnbF9O5SiUSt1KunmGYQYbeNbTcWJg&amp;id=235" target="_blank" border="0" style="color: #e38f2b;font-weight: bold;border: 0;cursor: pointer;text-decoration: none;">CHAT ONLINE</a></span></td>'
	cMsg+='								<td width="36" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="184" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"><a href="https://www.totvs.com/" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_42.jpg" width="184" height="49" border="0" style="display: block; border: 0;" alt="Clique aqui!" title="Clique aqui!"></a></td>'
	cMsg+='								<td width="99" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="60" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='							</tr>'
	cMsg+='							</tbody>'
	cMsg+='						</table>'
	cMsg+='					</td>'
	cMsg+='				</tr>'
	cMsg+='				</tbody>'
	cMsg+='			</table>'
	cMsg+='		</td>'
	cMsg+='	</tr>'
	cMsg+='	<tr valign="top" style="font-size: 0;">'
	cMsg+='		<td width="700" height="24" valign="top" style="font-size: 0;">'
	cMsg+='			<table width="700" height="24" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='				<tr valign="top" style="font-size: 0;">'
	cMsg+='					<td width="700" height="24" valign="top" style="font-size: 0;">'
	cMsg+='						<table width="700" height="24" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
	cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
	cMsg+='							<tr valign="top" style="font-size: 0;">'
	cMsg+='								<td width="60" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="261" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="36" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="283" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='								<td width="60" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
	cMsg+='							</tr>'
	cMsg+='							</tbody>'
	cMsg+='						</table>'
	cMsg+='					</td>'
	cMsg+='				</tr>'
	cMsg+='				</tbody>'
	cMsg+='			</table>'
	cMsg+='		</td>'
	cMsg+='	</tr>'
	cMsg+='	</tbody>'
	cMsg+='</table>'
	cMsg+='<!-- End Save for Web Slices -->'
	cMsg+=''
	cMsg+=''
	cMsg+=''
	cMsg+=''
	cMsg+=''
	cMsg+=''
	cMsg+=''
	cMsg+=''
	cMsg+=''
	cMsg+=''
	cMsg+='</body>'
	cMsg+='</html>'

Return cMsg

//---------------------------------------------------------------------
/*/{Protheus.doc} SetProfile
@type			function
@description	Atualiza o arquivo de profile da GRFGTS.
@author			Felipe C. Seolin
@since			29/01/2019
@param			oProfile	-	Objeto referente ao arquivo de profile
@param			lCheck		-	Indica se a opção para não exibir nos próximos 7 dias foi marcada
/*/
//---------------------------------------------------------------------
Static Function SetProfile( oProfile, lCheck )

Local cSetting	:=	""

If lCheck
    cSetting := DToS( Date() )
EndIf

oProfile:SetStringProfile( cSetting )
oProfile:Save()

Return()
//---------------------------------------------------------------------
/*/{Protheus.doc} fVerEstab
@type			function
@description	Retorna o id estabelecimento
@author			Felipe C. Seolin
@since			29/01/2021
@param			cEstab		-	id do Estabelecimento
@param			cNrInsc		-	Numero da Inscrição do Estabelecimento
@param			cFilQry		-	Filial do registro posicionado
/*/
//---------------------------------------------------------------------
Static Function fVerEstab(cEstab,cNrInsc,cFilQry)
Local aAreaC92 := C92->(GetArea())
Local cIdEstab	:= ""

Default cEstab	:= ""
Default cNrInsc	:= ""
Default cFilQry	:= ""

cIdEstab	:= cEstab
C92->(dbSetOrder(8))
If Empty(cEstab) 
	If C92->( MsSeek( xFilial( "C92", cFilQry ) + cNrInsc + "1" ) )
		cIdEstab	:= C92->C92_ID
	Endif
EndIf

RESTAREA(aAreaC92)
Return cIdEstab

//-------------------------------------------------------------------
/*/{Protheus.doc} ChargeINSS
Executa a carga na tabela V3N para INSS

@param oRunCharge - Objeto FWMsgRun()
@param aTelaFil - Filiais selecionadas
@param cPeriodo - Período informado
@param lProtheus - Indica se a Origem dos dados parte do Protheus
@param oArqTrb - Objeto com as informações para conferência (Referência)
@param oArqTot - Objeto com as informações dos totalizadores para conferência (Referência)

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function ChargeINSS(oRunCharge, aTelaFil, cPeriodo, lProtheus, oArqTrb, oArqTot)

	Local aFilMV		:= {}
	Local aFilial		:= {}
	Local aFilMatriz	:= TAFGFilMatriz()
	Local cMsgS1200 	:= STR0001
	Local cMsgS2299 	:= STR0002
	Local cMsgS2399 	:= STR0003
	Local cCNPJRaiz		:= SubStr(SM0->M0_CGC, 1, 8)
	Local lCancel		:= .F.
	Local nI			:= 0

	Private cST2Alias	:= Iif(Type("cST2Alias") == "U", "rsTAFST2", cST2Alias)
	Private oArqEst		:= Iif(Type("oArqEst") == "U", TAFXHMNew(), oArqEst)
	Private cCachFil	:= ""
	Private cCachFilMV	:= ""
	Private cCachFilC8R	:= ""
	
	Default aTelaFil	:= {}
	Default cPeriodo 	:= ""
	Default lProtheus	:= GetNewPar("MV_RHTAF", .F.)
	Default oArqTrb		:= TAFXHMNew()
	Default oArqTot		:= TAFXHMNew()
	Default oRunCharge	:= Nil

    C1E->(DBSetOrder(3))

    If C1E->(MSSeek(xFilial("C1E") + PadR(SM0->M0_CODFIL, GetSX3Cache("C1E_FILTAF", "X3_TAMANHO")) + "1"))

        If C1E->C1E_MATRIZ

			While Empty(aTelaFil) .AND. !lCancel
			
				aTelaFil := xFunTelaFil(.T.,,,,, .F., @lCancel, .T.)
			
			EndDo

            For nI := 1 to Len(aTelaFil)

                If aTelaFil[nI][1]

                    aAdd(aFilial, aTelaFil[nI][2])

                EndIf

            Next

        Else

            aAdd(aFilial, cFilAnt)

        EndIf

    EndIf

    aEval(aInfoSM0, {|x| Iif(SubStr(x[18], 1, 8) == cCNPJRaiz .AND. x[1] == cEmpAnt, aAdd(aFilMV, x[2]), Nil)})

	cCachFil	:= TAFCacheFil(Nil, aFilial)
	cCachFilMV	:= TAFCacheFil(Nil, aFilMV, .T.)
	
	If FindFunction("VldTabTAF") .And. VldTabTAF("C8R") $ "CCE|CEE"
		cCachFilC8R := TAFCacheFil("C8R",, .T.)
	Else
		cCachFilC8R := cCachFil
	EndIf
	
	xTAFCriaTB(,, "TAFST2", cST2Alias)

	If oRunCharge <> Nil

		cMsgS1200 := STR0004
		cMsgS2299 := STR0005
		cMsgS2399 := STR0006

	EndIf

	FWMsgRun(oRunCharge, {|oMsgRun| DataS1200(oMsgRun, @oArqTrb, cPeriodo, aFilial, aFilMatriz, aFilMV, @oArqTot)}, cMsgS1200, STR0007)

	If Len(AllTrim(cPeriodo)) <> 4

		FWMsgRun(oRunCharge, {|oMsgRun| DataS2299(oMsgRun, @oArqTrb, cPeriodo, aFilial, lProtheus, aFilMatriz, @oArqTot)}, cMsgS2299, STR0007)
		FWMsgRun(oRunCharge, {|oMsgRun| DataS2399(oMsgRun, @oArqTrb, cPeriodo, aFilial, lProtheus, aFilMatriz, @oArqTot)}, cMsgS2399, STR0007)
	
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GenTAFFil
Cria uma tabela temporária para armazenar as filiais que serão usadas
na query da TAFST2. Essa tabela é necessária para não estourar o tamanho
da query quando houver muitas filiais.

@param cFilEvt - Filial do registro atual
@param aFiliais - Array contendo as filiais a serem gravadas na tabela temporária
@param nFindFil - Posição do elemento na variável privada aTAFFil

@author Melkz Siqueira
@since 29/10/2021
@version 1.0

@return cTabFil - Nome da tabela temporária criada
/*/
//-------------------------------------------------------------------
Static Function GenTAFFil(cFilEvt, aFiliais, nFindFil)

	Local aFields		:= {}
	Local cTabFil		:= ""
	Local cTmpTab		:= ""
	Local cTmpAlia		:= ""
	Local nFilTam		:= 0
	Local nI			:= 0
	Local oTmpTab		:= Nil

	Default aFiliais 	:= {}
	Default cFilEvt 	:= ""
	Default nFindFil	:= 0

	If !Empty(cFilEvt) .AND. !Empty(aFiliais)

		cTmpTab	:= GetNextAlias()
		nFilTam	:= GetSX3Cache("CR9_CODFIL", "X3_TAMANHO")

		aAdd(aFields, {"TAFFIL", "C", nFilTam, 0})
		
		oTmpTab := FWTemporaryTable():New(cTmpTab)

		oTmpTab:SetFields(aFields)
		oTmpTab:AddIndex("01", {"TAFFIL"})
		oTmpTab:Create()

		cTabFil		:= oTmpTab:GetRealName()
		cTmpAlia	:= oTmpTab:GetAlias()

		(cTmpTab)->(DBSetOrder(1))

		For nI := 1 To Len(aFiliais)

			If (cTmpTab)->(RecLock(cTmpTab, .T.))

				(cTmpTab)->TAFFIL := aFiliais[nI]

				(cTmpTab)->(MSUnlock())

			EndIf

		Next
		
		If nFindFil > 0

			aTAFFil[nFindFil][2] := cTabFil
			aTAFFil[nFindFil][3] := cTmpAlia

		Else
			
			AAdd(aTAFFil, {cFilEvt, cTabFil, cTmpAlia})

		EndIf

		FWFreeArray(aFields)
		FWFreeArray(aFiliais)
		FWFreeObj(oTmpTab)

	EndIf

Return cTabFil
