#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEXTRF.CH"
#INCLUDE "HEADERGD.CH"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicao dos campos da GetDados 						         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
#DEFINE __TRF_PROCES__		01	//01 -> Processo
#DEFINE __TRF_PERDE__		02	//02 -> Periodo De
#DEFINE __TRF_NRODE__		03	//03 -> Numero de Pagamento De
#DEFINE __TRF_ROTDE__		04	//04 -> Roteiro De
#DEFINE __TRF_PROCPARA__	05	//05 -> Processo Para
#DEFINE __TRF_PERPARA__		06	//06 -> Periodo Para
#DEFINE __TRF_NROPARA__		07	//07 -> Numero de Pagamento Para
#DEFINE __TRF_FILIAL__		08	//08 -> Filial
#DEFINE __TRF_TABELA__		09	//09 -> Tabela
#DEFINE __TRF_DESCTAB__		10	//10 -> Descricao da Tabela
#DEFINE __TRF_EMPPARA__		11	//11 -> Empresa Destino
#DEFINE __DELETED__			12	//12 -> Campo de Delecao

Static aRecChange	:= {}	// Recno das tabelas para gravacao posterior
Static aPerChange 	:= {}	// Periodos a localizar para troca
Static aSaveCols 	:= {}	// aCols com as Informacoes a serem gravadas
Static aTrfHeader	:= {}	// aHeader criado no fonte
Static __cLastEmp

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммммкммммммямммммммммм╩╠╠
╠╠╨Fun┤┘o    Ё GPEXTRF  ЁAutor  ЁMauricio T. Takakura   Ё Data Ё19/04/2007╨╠╠
╠╠лддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╧╠╠
╠╠╨Descri┤┘o Ё Funcoes para Tratamento da Transferencia de Funcionarios   ╨╠╠
╠╠лддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╧╠╠
╠╠╨Uso       Ё Generico                                                   ╨╠╠
╠╠лддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╧╠╠
╠╠╨         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             ╨╠╠
╠╠лдддддддддддбддддддддбдддддддбдддддддддддддддддддддддддддддддддддддддддд╧╠╠
╠╠╨ProgramadorЁ Data   Ё BOPS   Ё  Motivo da Alteracao                    ╨╠╠
╠╠лдддддддддддеддддддддеддддддддедддддддддддддддддддддддддддддддддддддддд╧╠╠
╠╠╨Cecilia CarvЁ20/11/13ЁRHU210_01_24ЁUnificacao da Folha de Pagamento   ╨╠╠
╠╠╨Gabriel A. Ё19/05/16ЁTUZRDM  ЁInclusЦo das tabelas RGB e SRR para      ╨╠╠
╠╠╨           Ё        Ё        ЁtransferЙncias de processos.             ╨╠╠
╠╠╨Renan B.   Ё06/12/16ЁMRH-2160ЁAjuste para aparecer a tela dos periodos ╨╠╠
╠╠╨           Ё        Ё        Ёcorretamente.                            ╨╠╠
╠╠╨Eduardo P. Ё12/02/20ЁDMINA-  ЁAgregar bifurcaciones para el atributo   ╨╠╠
╠╠╨           Ё        Ё8213    ЁEmpresa destino.cambio solo para Brasil  ╨╠╠
╠╠юммммммммммммоммммммммоммммммомммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

/*/
зддддддддддбдддддддддддбддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRstTransf  ЁAutor Ё Mauricio Takakura     Ё Data Ё 27/04/07 Ё
цддддддддддедддддддддддаддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁLimpar as variavies de transferencia                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA010	                                                	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RstTransf()

aRecChange	:= {}
aPerChange := {}
aSaveCols 	:= {}
aTrfHeader	:= {}
__cLastEmp	:= NIL

Return

/*/
зддддддддддбдддддддддддбддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁfTransProc ЁAutor Ё Mauricio Takakura     Ё Data Ё 18/04/07 Ё
цддддддддддедддддддддддаддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁTransferencia de Processsos                                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA010	                                                	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function fTransProc(aFilesTransf,;	// Array com as tabelas a serem transferidos
					cNewProces	,;	// Processo para o qual sera transferido - DEFAULT M->RA_PROCES
					cTrfEmp		,;	// Empresa para o qual sera transferido - DEFAULT "" (nao possui transferencia de Empresa)
					cTrfFil		,;	// Filial para o qual sera transferido - DEFAULT "" (nao possui transferencia de Filial)
					lGrava		,;	// Se gravara as informacoes no banco ou somente listar e permitir selecao do usuario
					lShowSelPer	,;	// Se mostra a tela para selecao de Periodos
					lProcDados	,;	// Se busca informacoes no banco
					lLote		,; 	// Transferencia em Lote
					lRobo		 ;
					)

Local aArea	    := GetArea()
Local aFilesOpen := {}
Local aChgNotPer := {}

Local cAliasRCH 	 := "RCH"
Local cFilRCH
Local cFilSR8
Local cFilSRK
Local cFilSRG
Local cFilSRH
Local cFilFUN
Local cQryLoc
Local cFilSRR
Local cFilRGB

Local cRotOrd 		:= fGetRotOrdinar()
Local cKey
Local cFldKey
Local cRoteiro
Local cCpoFil
Local cCpoMat
Local cCpoProc
Local cCpoPer
Local cCpoNPago
Local cCpoRoteir
Local cAliasTrf		:= ""
Local cArqNotPer	   := Upper( AllTrim( SuperGetMv("MV_FNOTPER" , NIL , "" ) ) )

Local dDataFer      := CTOD('//')
Local dDataRes      := CTOD('//')

Local nPos
Local nPosRCH
Local nX
Local nTab
Local nOrdem
Local nPosPer
Local lRet 			:= .T.	// Variavel de retorno
Local lTrfMenu 		:= (FunName() == "GPEA180") // Se a transfere ocorre atraves do Menu de Transferencia
Local lRotBlank
Local lFilesTransf	:= .F.

DEFAULT aFilesTransf:= {}
DEFAULT cNewProces 	:= M->RA_PROCES
DEFAULT cTrfEmp		:= ""
DEFAULT cTrfFil		:= ""
DEFAULT lShowSelPer := .T.
DEFAULT lProcDados	:= .T.
DEFAULT lLote		:= .F.
DEFAULT lGrava		:= .T.
DEFAULT lRobo		:= .F.

Private cFilSRA		:= SRA->RA_FILIAL
Private cMatr		:= SRA->RA_MAT
Private cProcesso   := cNewProces
Private cProcAnt	:= SRA->RA_PROCES
Private aTrfTabs	:= {}

If Type("lEmpDif") == "U"
	Private lEmpDif := .F.
EndIf

If !lLote
	RstTransf()
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Estrutura do Array aPerChange  					            Ё
//Ё[01]-Tabela						[02]-Filial		            Ё
//Ё[03]-Periodo De					[04]-Nro Pagamento De       Ё
//Ё[05]-Processo De					[06]-Roteiro De		        Ё
//Ё[07]-Periodo Para		   		[08]-Nro Pagamento Para     Ё
//Ё[09]-Processo Para		  	 	[10]-Empresa Destino	    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//-- Localizar os registros dos periodos a transferir e para qual transferir
//-- Tabela SR8
If lProcDados

	// Carregar array com as tabelas a processar //
	If Empty(aFilesTransf)
		MsAguarde( { || lFilesTransf := FilesTransf(@aFilesTransf,@aFilesOpen) }, STR0019 + STR0020 ) //"Preparando Arquivos para Transferencia. Aguarde..."
		If !lFilesTransf
			Return( .F.)
		EndIf
	EndIf

	//Nao deixa mudar o perМodo das tabelas listadas no parametro
	If !Empty(cArqNotPer)
		For nX := 1 To Len(cArqNotPer) Step 3
			cAliasTrf := Upper( SubStr( cArqNotPer , nX , 3 ) )
			If (cAliasTrf != "SRA" )
				If ( (nPos := aScan( aFilesTransf , { |x| x[1] == cAliasTrf } ) ) > 0 )
					aAdd( aChgNotPer, cAliasTrf )
				EndIf
			EndIf
		Next nX
	EndIf

	cFilRCH := xFilial( "RCH" )
	nPosRCH := RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )

	cAliasRCH := "QRCH"
	cFilSR8 := "%RCH_FILIAL = '" + cFilRCH + "'%"
	cFilSRK := cFilSR8
	cFilSRG := cFilSR8
	cFilSRH := cFilSR8
	cFilFUN := cFilSR8
	cFilRGB := cFilSR8
	cFilSRR := cFilSR8

    //-- Querys com as tabelas Localizadas por Pais
	cQryLoc := "%AND RCH.D_E_L_E_T_ = ' '" // Foi trazido essa sentenca para ca, pois nao eh permitido enviar uma expressao em branco
	If cPaisLoc <> "MEX"
		//-- Ferias - SRH
		cQryLoc += " UNION ALL   "
	    cQryLoc += "SELECT RCH.RCH_FILIAL, RCH.RCH_PER, RCH.RCH_NUMPAG, RCH.RCH_PROCES, "
		cQryLoc += "       RCH.RCH_ROTEIR, RCH.RCH_MES, RCH.RCH_ANO, RCH.RCH_DTINI, "
		cQryLoc += "       RCH.RCH_DTFIM, SRH.RH_ROTEIR as ROTMOV, SRH.R_E_C_N_O_, 'SRH' as Tabela, "
		cQryLoc += "	   'RH_PERIODO' as PERIODO, 'RH_NPAGTO' as NUMPAGO,"
		cQryLoc += "       'RH_PROCES' as PROCESSO, 'RH_ROTEIR' as ROTEIRO"
		cQryLoc += "	FROM " + RetSqlName("RCH") + " RCH"
		cQryLoc += "	INNER JOIN " + RetSqlName("SRH") + " SRH"
		cQryLoc += "	   ON RCH_FILIAL = " + If(cFilRCH==Space(FwGetTamFilial), "'" + cFilRCH + "'", "SRH.RH_FILIAL")
		cQryLoc += "	  AND RCH.RCH_PER = SRH.RH_PERIODO"
		cQryLoc += "	  AND RCH.RCH_NUMPAG = SRH.RH_NPAGTO"
		cQryLoc += "	  AND (RCH.RCH_ROTEIR = '   ' OR RCH.RCH_ROTEIR = SRH.RH_ROTEIR )"
		cQryLoc += "	  AND RCH.RCH_PROCES = SRH.RH_PROCES"
		cQryLoc += "	  AND RCH.RCH_DTFECH = ''"
		cQryLoc += "	  AND SRH.RH_FILIAL = '" + cFilSRA + "'"
		cQryLoc += "	  AND SRH.RH_MAT = '" + cMatr + "'"
		cQryLoc += "	  AND SRH.D_E_L_E_T_ = ' '"
		cQryLoc += "	  AND RCH.D_E_L_E_T_ = ' '%"
	ElseIf cPaisLoc == "MEX"
		//-- Tempo Extra - RCR
		cQryLoc += " UNION ALL "
		cQryLoc += "SELECT 	RCH.RCH_FILIAL, RCH.RCH_PER, RCH.RCH_NUMPAG, RCH.RCH_PROCES,"
        cQryLoc += "		RCH.RCH_ROTEIR, RCH.RCH_MES, RCH.RCH_ANO, RCH.RCH_DTINI,"
       	cQryLoc += "		RCH.RCH_DTFIM, RCR.RCR_ROTEIR as ROTMOV, RCR.R_E_C_N_O_, 'RCR' as Tabela, "
       	cQryLoc += "		'RCR_PERIOD' as PERIODO, 'RCR_NPAGTO' as NUMPAGO,"
        cQryLoc += "		'RCR_PROCES' as PROCESSO, 'RCR_ROTEIR' as ROTEIRO"
		cQryLoc += "	FROM " + RetSqlName( "RCH" ) + " RCH"
		cQryLoc += "	INNER JOIN " + RetSqlName( "RCR" ) + " RCR"
		cQryLoc += "   	   ON RCH_FILIAL = " + If(cFilRCH==Space(FwGetTamFilial), "'" + cFilRCH + "'", "RCR.RCR_FILIAL")
		cQryLoc += "      AND RCH.RCH_PER = RCR.RCR_PERIOD"
		cQryLoc += "      AND RCH.RCH_NUMPAG = RCR.RCR_NPAGTO"
		cQryLoc += "      AND (RCH.RCH_ROTEIR = '   ' OR RCH.RCH_ROTEIR = RCR.RCR_ROTEIR )"
		cQryLoc += "      AND RCH.RCH_PROCES = RCR.RCR_PROCES"
		cQryLoc += "      AND RCH.RCH_DTFECH = ''"
		cQryLoc += "      AND RCR.RCR_FILIAL = '" + cFilSRA + "'"
		cQryLoc += "      AND RCR.RCR_MAT = '" + cMatr + "'"
		cQryLoc += "	  AND RCR.D_E_L_E_T_ = ' '"
		cQryLoc += "	  AND RCH.D_E_L_E_T_ = ' '%"
	Else
		cQryLoc += "%"
	EndIf

	BeginSql alias cAliasRCH

		//-- Movimento - SRC
		SELECT RCH.RCH_FILIAL, RCH.RCH_PER, RCH.RCH_NUMPAG, RCH.RCH_PROCES,
		       RCH.RCH_ROTEIR, RCH.RCH_MES, RCH.RCH_ANO, RCH.RCH_DTINI,
		       RCH.RCH_DTFIM, SRC.RC_ROTEIR as ROTMOV, SRC.R_E_C_N_O_, 'SRC' as Tabela,
		       'RC_PERIODO' as PERIODO, 'RC_SEMANA' as NUMPAGO,
		       'RC_PROCES' as PROCESSO, 'RC_ROTEIR' as ROTEIRO
		FROM %table:RCH% RCH
		INNER JOIN %table:SRC% SRC
		   ON %exp:cFilFUN%
		  AND RCH.RCH_PER = SRC.RC_PERIODO
		  AND RCH.RCH_NUMPAG = SRC.RC_SEMANA
		  AND (RCH.RCH_ROTEIR = '   ' OR RCH.RCH_ROTEIR = SRC.RC_ROTEIR )
		  AND RCH.RCH_PROCES = SRC.RC_PROCES
		  AND SRC.RC_FILIAL = %exp:cFilSRA%
		  AND SRC.RC_MAT = %exp:cMatr%
		  AND SRC.D_E_L_E_T_ = ' '
		  AND RCH.D_E_L_E_T_ = ' '

		//-- Afastamentos - SR8
		UNION ALL
		SELECT RCH.RCH_FILIAL, RCH.RCH_PER, RCH.RCH_NUMPAG, RCH.RCH_PROCES,
		       RCH.RCH_ROTEIR, RCH.RCH_MES, RCH.RCH_ANO, RCH.RCH_DTINI,
		       RCH.RCH_DTFIM, %Exp:cRotOrd% as ROTMOV, SR8.R_E_C_N_O_, 'SR8' as Tabela,
		       'R8_PER' as PERIODO, 'R8_NUMPAGO' as NUMPAGO,
		       'R8_PROCES' as PROCESSO, ' ' as ROTEIRO
		FROM %table:RCH% RCH
		INNER JOIN %table:SR8% SR8
		   ON %exp:cFilSR8%
		  AND RCH.RCH_PER = SR8.R8_PER
	 	  AND RCH.RCH_NUMPAG = SR8.R8_NUMPAGO
	 	  AND RCH.RCH_PROCES = SR8.R8_PROCES
		  AND RCH.RCH_STATUS = '0'
		  AND (RCH.RCH_ROTEIR = '   ' OR RCH.RCH_ROTEIR = %exp:cRotOrd%)
	 	  AND SR8.R8_FILIAL = %exp:cFilSRA%
	 	  AND SR8.R8_MAT = %exp:cMatr%
	 	  AND SR8.R8_DPAGOS = 0
	 	  AND SR8.R8_TIPOAFA NOT IN ('001','002')
	 	  AND SR8.R8_DIASEMP > 0
  	      AND SR8.D_E_L_E_T_ = ' '
   		  AND RCH.D_E_L_E_T_ = ' '

		  		//-- Valores Futuros - SRK
  		UNION ALL
		SELECT RCH.RCH_FILIAL, RCH.RCH_PER, RCH.RCH_NUMPAG, RCH.RCH_PROCES,
		       RCH.RCH_ROTEIR, RCH.RCH_MES, RCH.RCH_ANO, RCH.RCH_DTINI,
		       RCH.RCH_DTFIM, %exp:cRotOrd% as ROTMOV, SRK.R_E_C_N_O_, 'SRK' as Tabela,
		       'RK_PERINI' as PERIODO, 'RK_NUMPAGO' as NUMPAGO,
		       'RK_PROCES' as PROCESSO, ' ' as ROTEIRO
		FROM %table:RCH% RCH
		INNER JOIN %table:SRK% SRK
		   ON %exp:cFilSRK%
		  AND RCH.RCH_PER = SRK.RK_PERINI
			  AND RCH.RCH_NUMPAG = SRK.RK_NUMPAGO
			  AND RCH.RCH_PROCES = SRK.RK_PROCES
		  AND (RCH.RCH_ROTEIR = '   ' OR RCH.RCH_ROTEIR = %exp:cRotOrd%)
			  AND SRK.RK_FILIAL = %exp:cFilSRA%
			  AND SRK.RK_MAT = %exp:cMatr%
			  AND SRK.RK_VLRPAGO = 0
			  AND SRK.RK_PARCPAG = 0
			  AND SRK.D_E_L_E_T_ = ' '
		  	  AND RCH.D_E_L_E_T_ = ' '

		//-- Rescisao - SRG
		UNION ALL
	    SELECT RCH.RCH_FILIAL, RCH.RCH_PER, RCH.RCH_NUMPAG, RCH.RCH_PROCES,
			       RCH.RCH_ROTEIR, RCH.RCH_MES, RCH.RCH_ANO, RCH.RCH_DTINI,
			       RCH.RCH_DTFIM, SRG.RG_ROTEIR as ROTMOV, SRG.R_E_C_N_O_, 'SRG' as Tabela,
			       'RG_PERIODO' as PERIODO, 'RG_SEMANA' as NUMPAGO,
			       'RG_PROCES' as PROCESSO, 'RG_ROTEIR' as ROTEIRO
			FROM %table:RCH% RCH
			INNER JOIN %table:SRG% SRG
			   ON %exp:cFilSRG%
			  AND RCH.RCH_PER = SRG.RG_PERIODO
			  AND RCH.RCH_NUMPAG = SRG.RG_SEMANA
			  AND (RCH.RCH_ROTEIR = '   ' OR RCH.RCH_ROTEIR = SRG.RG_ROTEIR )
			  AND RCH.RCH_PROCES = SRG.RG_PROCES
			  AND RCH.RCH_DTFECH = %exp:dDataRes%
			  AND SRG.RG_FILIAL = %exp:cFilSRA%
			  AND SRG.RG_MAT = %exp:cMatr%
			  AND SRG.D_E_L_E_T_ = ' '
			  AND RCH.D_E_L_E_T_ = ' '

		//-- Ferias - SRH
		UNION ALL
	    SELECT RCH.RCH_FILIAL, RCH.RCH_PER, RCH.RCH_NUMPAG, RCH.RCH_PROCES,
			       RCH.RCH_ROTEIR, RCH.RCH_MES, RCH.RCH_ANO, RCH.RCH_DTINI,
			       RCH.RCH_DTFIM, SRH.RH_ROTEIR as ROTMOV, SRH.R_E_C_N_O_, 'SRH' as Tabela,
			       'RH_PERIODO' as PERIODO, 'RH_NPAGTO' as NUMPAGO,
			       'RH_PROCES' as PROCESSO, 'RH_ROTEIR' as ROTEIRO
			FROM %table:RCH% RCH
			INNER JOIN %table:SRH% SRH
			   ON %exp:cFilSRG%
			  AND RCH.RCH_PER = SRH.RH_PERIODO
			  AND RCH.RCH_NUMPAG = SRH.RH_NPAGTO
			  AND (RCH.RCH_ROTEIR = '   ' OR RCH.RCH_ROTEIR = SRH.RH_ROTEIR )
			  AND RCH.RCH_PROCES = SRH.RH_PROCES
			  AND RCH.RCH_DTFECH = %exp:dDataFer%
			  AND SRH.RH_FILIAL = %exp:cFilSRA%
			  AND SRH.RH_MAT = %exp:cMatr%
			  AND SRH.D_E_L_E_T_ = ' '
			  AND RCH.D_E_L_E_T_ = ' '

		//-- IncidЙncias - RGB
		UNION ALL
		SELECT RCH.RCH_FILIAL, RCH.RCH_PER, RCH.RCH_NUMPAG, RCH.RCH_PROCES,
			       RCH.RCH_ROTEIR, RCH.RCH_MES, RCH.RCH_ANO, RCH.RCH_DTINI,
			       RCH.RCH_DTFIM, RGB.RGB_ROTEIR as ROTMOV, RGB.R_E_C_N_O_, 'RGB' as Tabela,
			       'RGB_PERIOD' as PERIODO, 'RGB_SEMANA' as NUMPAGO,
			       'RGB_PROCES' as PROCESSO, 'RGB_ROTEIR' as ROTEIRO
			FROM %table:RCH% RCH
			INNER JOIN %table:RGB% RGB
			ON %exp:cFilRGB%
			AND RCH.RCH_PER = RGB.RGB_PERIOD
			AND RCH.RCH_NUMPAG = RGB.RGB_SEMANA
			AND (RCH.RCH_ROTEIR = '   ' OR RCH.RCH_ROTEIR = RGB.RGB_ROTEIR )
			AND RCH.RCH_PROCES = RGB.RGB_PROCES
			AND RGB.RGB_FILIAL = %exp:cFilSRA%
			AND RGB.RGB_MAT = %exp:cMatr%
			AND RGB.D_E_L_E_T_ = ' '
			AND RCH.D_E_L_E_T_ = ' '

		//-- Itens - FИrias e RescisУes - SRR
		UNION ALL
		SELECT RCH.RCH_FILIAL, RCH.RCH_PER, RCH.RCH_NUMPAG, RCH.RCH_PROCES,
			       RCH.RCH_ROTEIR, RCH.RCH_MES, RCH.RCH_ANO, RCH.RCH_DTINI,
			       RCH.RCH_DTFIM, SRR.RR_ROTEIR as ROTMOV, SRR.R_E_C_N_O_, 'SRR' as Tabela,
			       'RR_PERIODO' as PERIODO, 'RR_SEMANA' as NUMPAGO,
			       'RR_PROCES' as PROCESSO, 'RR_ROTEIR' as ROTEIRO
			FROM %table:RCH% RCH
			INNER JOIN %table:SRR% SRR
			ON %exp:cFilSRR%
			AND RCH.RCH_PER = SRR.RR_PERIODO
			AND RCH.RCH_NUMPAG = SRR.RR_SEMANA
			AND (RCH.RCH_ROTEIR = '   ' OR RCH.RCH_ROTEIR = SRR.RR_ROTEIR )
			AND RCH.RCH_PROCES = SRR.RR_PROCES
			AND RCH.RCH_DTFECH = %exp:dDataRes%
			AND SRR.RR_FILIAL = %exp:cFilSRA%
			AND SRR.RR_MAT = %exp:cMatr%
			AND SRR.D_E_L_E_T_ = ' '
			AND RCH.D_E_L_E_T_ = ' '

		//-- SRH (Ferias) e RCR (Tempo Extra)
		%exp:cQryLoc%

	EndSql

	While (cAliasRCH)->( !Eof() )

		If ( ( nPos := aScan( aFilesTransf, { |x| x[1] == Tabela } ) ) > 0 )
			If ( aFilesTransf[ nPos, 6 ] )
				If !( aScan( aChgNotPer , { |x| x == Tabela } ) > 0 )
					//-- Array para demonstrar ao usuario
					nPos := aScan( aPerChange, { |x| x[1]+x[3]+x[4]+x[5]+x[6] == (cAliasRCH)->(Tabela+RCH_PER+RCH_NUMPAG+RCH_PROCES+RCH_ROTEIR) } )
					If nPos = 0

						(cAliasRCH)->( aAdd( aPerChange, { Tabela, If(cPaisloc == "BRA", xFilial("RCH",cFilAte), ChkTamFil("RCH",cFilAte)), RCH_PER, RCH_NUMPAG, RCH_PROCES,RCH_ROTEIR, "", "", cProcesso, cTrfEmp} ))
						nPos := Len( aPerChange )
					EndIf

					// Para processamento atraves do Menu de Transferencia sera utilizado as alteracoes a cada registro //
					If !lLote
						aAdd( aRecChange, { (cAliasRCH)->(Tabela), nPos, (cAliasRCH)->(R_E_C_N_O_), (cAliasRCH)->(ROTMOV), { (cAliasRCH)->(PERIODO), (cAliasRCH)->(NUMPAGO), (cAliasRCH)->(PROCESSO), (cAliasRCH)->(ROTEIRO) } } )
					EndIf
				EndIf
			EndIf
		EndIf
		(cAliasRCH)->( DbSkip() )

	EndDo

	If ( Select( cAliasRCH ) > 0 )
		( cAliasRCH )->( dbCloseArea() )
		cAliasRCH := "RCH"
	EndIf

	// Se a Transferencia for pelo Menu de Transferencia deverА incluir a tabela SRA
	If lTrfMenu
		If cPaisLoc == "MEX"

			// Campos do periodo de admissao //
			If !lLote
				If fPosPeriodo( cFilRCH, cProcAnt, SRA->RA_PERADM, SRA->RA_PAGADM, cRotOrd, NIL, @lRotBlank, nPosRCH )
					(cAliasRCH)->( aAdd( aPerChange, { "SRA",  ChkTamFil("RCH",cFilAte), RCH->RCH_PER, RCH->RCH_NUMPAG, RCH->RCH_PROCES, RCH->RCH_ROTEIR, "", "", cProcesso } ))
				Else
					(cAliasRCH)->( aAdd( aPerChange, { "SRA", ChkTamFil("RCH", SRA->RA_FILIAL ), SRA->RA_PERADM, SRA->RA_PAGADM, SRA->RA_PROCES, cRotOrd, "", "", cProcesso } ))
				EndIf

				nPos := Len( aPerChange )
			    aAdd( aRecChange, { "SRA", nPos, SRA->(Recno()), "  ", { "RA_PERADM", "RA_PAGADM", "RA_PROCES", " " } } )

			    // Campos do periodo de alteracao salario //
			    If !Empty(SRA->RA_PERAUM)
				    If fPosPeriodo( cFilRCH, cProcAnt, SRA->RA_PERAUM, SRA->RA_PAGAUM, cRotOrd, NIL, @lRotBlank, nPosRCH )
						(cAliasRCH)->( aAdd( aPerChange, { "SRA",  ChkTamFil("RCH",cFilAte), RCH->RCH_PER, RCH->RCH_NUMPAG, RCH->RCH_PROCES, RCH->RCH_ROTEIR, "", "", cProcesso } ))
					Else
						(cAliasRCH)->( aAdd( aPerChange, { "SRA",  ChkTamFil("RCH",SRA->RA_FILIAL), SRA->RA_PERAUM, SRA->RA_PAGAUM, SRA->RA_PROCES, cRotOrd, "", "", cProcesso } ))
					EndIf
				EndIf
			Else
				If aScan( aPerChange, { |x| x[5] + x[1] == SRA->RA_PROCES + "SRA" } ) = 0
					(cAliasRCH)->( aAdd( aPerChange, { "SRA", ChkTamFil("RCH",SRA->RA_FILIAL), "INGRESO", "  ", SRA->RA_PROCES, cRotOrd, "", "", cProcesso } ))
					(cAliasRCH)->( aAdd( aPerChange, { "SRA", ChkTamFil("RCH",SRA->RA_FILIAL), "AUMENTO", "  ", SRA->RA_PROCES, cRotOrd, "", "", cProcesso } ))
				EndIf
			EndIf
		Endif
	EndIf
EndIf

//-- Interface com as transferencias
If  lShowSelPer
	If !lRobo .and. !Empty(aPerChange)
		lRet := fTelaTransf(lGrava,cTrfEmp,cTrfFil,lLote)
	Else
		lRet := .T.
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

/*/
зддддддддддбдддддддддддбддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁfTelaTransfЁAutor Ё Mauricio Takakura     Ё Data Ё 18/04/07 Ё
цддддддддддедддддддддддаддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁTransferencia de Processsos                                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA010	                                                	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function fTelaTransf(lGrava,cEmp,cFil,lLote) 	// Se gravara as informacoes no banco ou somente listar e permitir selecao do usuario

Local aAdvSize
Local aInfoAdvSize
Local aObjCoords	   := {}
Local aObjSize
Local aVrtCols
Local aVrtHeader
Local aTrfCols		:= {}
Local aButtons		:= {{ "PMSZOOMIN", { || fVisualReg(oGetDados:aCols[oGetDados:nAt,__TRF_TABELA__], aRecChange)  }, OemToAnsi(STR0009) , OemToAnsi(STR0009) }} //"Visualizar Registro"

Local cChave
Local cFilPara
Local cPerDe
Local cNumDe
Local cRotDe
Local cProcPara
Local cAlias	:= "RCH"
Local cSvFilAnt := cFilAnt
Local cSvEmpAnt := cEmpAnt
Local cSvArqTab 	:= cArqTab

Local lRet 		:= .T.

Local nX
Local nReg
Local nPosPer
Local nPosMat
Local nPosNPag
Local nPosRot
Local nPosProcP	:= 0
Local nOrdemPer
Local nRegs      := Len(aPerChange)
Local cAliasVar := Iif(cPaisLoc=="BRA","GPE","")

Local oTrfDlg

DEFAULT lLote := .F.

If nRegs = 0
	Return(.T.)
EndIf

Private oGetDados

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVariaveis utilizadas no Filtro F3 de Periodo e Nro Pagto	      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cCond 		:= "1"					// Somente periodos abertos
Private cTipo 		:= ""					// Enviar o nome do camp NUMPAGO para filtro do Numero de Pagamento
Private cRot		:= ""					// Filtrar o Roteiro
Private cPeriodo	:= ""					// Filtrar o Periodo
Private cTrfEmp		:= cEmp					// Declarado como Private para ser utilizado nas funcoes de validacoes
Private cTrfFil		:= cFil

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁLocalizar Periodos Correspondentes							         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды



If lRet
	DbSelectArea(cAlias)
	nOrdemPer 	:= RetOrder("RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR")
	For nReg := 1 To nRegs

		cFilPara  	:= aPerChange[nReg,02]
		cPerDe		:= aPerChange[nReg,03]
		cNumDe  	:= aPerChange[nReg,04]
		cRotDe		:= aPerChange[nReg,06]
		cProcPara	:= aPerChange[nReg,09]
		If cPaisLoc == "BRA"
			cEmpPara	:= aPerChange[nReg,10]
			fAbrEmpresa("RCH",1,cEmpPara)
		Endif
		//-- Verificar existencia de Periodo identifico ao do processo De
		DbSetOrder( nOrdemPer )
		cChave := cFilPara+cProcPara+cPerDe+cNumDe+cRotDe
		DbSeek( cChave, .F.)
		If !Eof() .and. Empty((cAliasVar+cAlias)->RCH_DTFECH)
			aPerChange[nReg,07] := (cAliasVar+cAlias)->RCH_PER
			aPerChange[nReg,08] := (cAliasVar+cAlias)->RCH_NUMPAG
		Endif

		fFecEmpresa("RCH")

	Next nReg

	lRet := .F.
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁTela para confirmacao dos periodos							         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//--Geracao de um acols e aheader apenas para reutilizar as estruturas
aVrtCols := RCH->( GdMontaCols(	@aVrtHeader,NIL,NIL,NIL,NIL,NIL,NIL,NIL,"XZ"))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁGeracao do aCols da tela de Periodos  						      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPosPer 	:= GdFieldPos( "RCH_PER", aVrtHeader )
nPosNPag	:= GdFieldPos( "RCH_NUMPAG", aVrtHeader )
nPosRot 	:= GdFieldPos( "RCH_ROTEIR", aVrtHeader )
nPosProcP	:= GdFieldPos( "RCH_PROCES", aVrtHeader )

aAdd( aTrfHeader, aClone(aVrtHeader[GdFieldPos( "RCH_PROCES", aVrtHeader )]) )	//-- Campo Processo
aTrfHeader[__TRF_PROCES__,__AHEADER_TITLE__]  := STR0017+" " + STR0007			// "Processo" ## "De"
aTrfHeader[__TRF_PROCES__,__AHEADER_FIELD__]  := 'TRF_PROCES'					// Nome do Campo
aTrfHeader[__TRF_PROCES__,__AHEADER_VISUAL__] := "V"

aAdd( aTrfHeader, aClone(aVrtHeader[nPosPer]) )										//-- Campo Periodo Origem
aTrfHeader[__TRF_PERDE__,__AHEADER_TITLE__]  := OemToAnsi(STR0004)+" " + STR0007	// "Periodo" ## "De"
aTrfHeader[__TRF_PERDE__,__AHEADER_FIELD__]  := 'TRF_PERDE'							// Nome do Campo
aTrfHeader[__TRF_PERDE__,__AHEADER_VISUAL__] := "V"

aAdd( aTrfHeader, aClone(aVrtHeader[nPosNPag]) )									//-- Campo Numero Pagamento Origem
aTrfHeader[__TRF_NRODE__,__AHEADER_TITLE__]  := OemToAnsi(STR0005)+" " + STR0007	// "Numero Pago" ## "De"
aTrfHeader[__TRF_NRODE__,__AHEADER_FIELD__]  := 'TRF_NRODE'							// Nome do Campo
aTrfHeader[__TRF_NRODE__,__AHEADER_VISUAL__] := "V"

aAdd( aTrfHeader, aClone(aVrtHeader[nPosRot]) )										//-- Campo roteiro de Calculo Origem
aTrfHeader[__TRF_ROTDE__,__AHEADER_TITLE__]  := OemToAnsi(STR0006)+" " + STR0007	// "Roteiro" ### "De"
aTrfHeader[__TRF_ROTDE__,__AHEADER_FIELD__]  := 'TRF_ROTDE'							// Nome do Campo
aTrfHeader[__TRF_ROTDE__,__AHEADER_VISUAL__] := "V"

aAdd( aTrfHeader, aClone(aVrtHeader[nPosProcP]) )									//-- Campo Processo de Calculo Destino
aTrfHeader[__TRF_PROCPARA__,__AHEADER_TITLE__]  := OemToAnsi(STR0017)+" " + STR0008	// "Processo " ### "Para"
aTrfHeader[__TRF_PROCPARA__,__AHEADER_FIELD__]  := 'TRF_PROCPARA'					// Nome do Campo
aTrfHeader[__TRF_PROCPARA__,__AHEADER_VISUAL__] := "V"

aAdd( aTrfHeader, aClone(aVrtHeader[nPosPer]) )										//-- Campo Periodo Destino
aTrfHeader[__TRF_PERPARA__,__AHEADER_TITLE__]  := OemToAnsi(STR0004)+" " + STR0008	// "Periodo" ## "Para"
aTrfHeader[__TRF_PERPARA__,__AHEADER_FIELD__]  := 'TRF_PERPARA'						// Nome do Campo
aTrfHeader[__TRF_PERPARA__,__AHEADER_F3__]	   := "RCH"								// Consulta F3
aTrfHeader[__TRF_PERPARA__,__AHEADER_VALID__]  := "ValPer(1, oGetDados:aCols[oGetDados:nAt,7],oGetDados:aCols[oGetDados:nAt,4], M->TRF_PERPARA, NIl, oGetDados:aCols[oGetDados:nAt,8] )"	// Validar o Periodo
aTrfHeader[__TRF_PERPARA__,__AHEADER_WHEN__]   := "WhenPer(1,oGetDados:aCols[oGetDados:nAt,4],NIL,oGetDados:aCols[oGetDados:nAt,9])"	// Necessario para atualizar o periodo do filtro F3
aTrfHeader[__TRF_PERPARA__,__AHEADER_VISUAL__] := "A"

aAdd( aTrfHeader, aClone(aVrtHeader[nPosNPag]) )						//-- Campo Numero Pagamento Destino
aTrfHeader[__TRF_NROPARA__,__AHEADER_TITLE__]  := OemToAnsi(STR0005)+" " + STR0008	// "Numero Pago" ## "Para"
aTrfHeader[__TRF_NROPARA__,__AHEADER_FIELD__]  := 'TRF_NROPARA'			// Nome do Campo
aTrfHeader[__TRF_NROPARA__,__AHEADER_F3__]	   := "RCH01"				// Consulta F3
aTrfHeader[__TRF_NROPARA__,__AHEADER_VALID__]  := "ValPer(2, oGetDados:aCols[oGetDados:nAt,7],oGetDados:aCols[oGetDados:nAt,4],oGetDados:aCols[oGetDados:nAt,6], M->TRF_NROPARA, oGetDados:aCols[oGetDados:nAt,8] )"	// Validar o Periodo
aTrfHeader[__TRF_NROPARA__,__AHEADER_WHEN__]   := "WhenPer(2,oGetDados:aCols[oGetDados:nAt,4],oGetDados:aCols[oGetDados:nAt,6],oGetDados:aCols[oGetDados:nAt,9])"	// Necessario para atualizar o periodo do filtro F3
aTrfHeader[__TRF_NROPARA__,__AHEADER_VISUAL__] := "A"

aAdd( aTrfHeader, aClone(aVrtHeader[nPosPer]) )							//-- Campo Filial
aTrfHeader[__TRF_FILIAL__,__AHEADER_TITLE__]  := OemToAnsi(STR0002) 	// Descricao --> "Filial"
aTrfHeader[__TRF_FILIAL__,__AHEADER_WIDTH__]  := 2	  					// Tamanho
aTrfHeader[__TRF_FILIAL__,__AHEADER_FIELD__]  := 'TRF_FILIAL'			// Nome do Campo
aTrfHeader[__TRF_FILIAL__,__AHEADER_VISUAL__] := "V"

aAdd( aTrfHeader, aClone(aVrtHeader[nPosPer]) )							//-- Campo Tabela
aTrfHeader[__TRF_TABELA__,__AHEADER_TITLE__]  := OemToAnsi(STR0001)		// Descricao --> "Tabela"
aTrfHeader[__TRF_TABELA__,__AHEADER_WIDTH__]  := 3	  					// Tamanho
aTrfHeader[__TRF_TABELA__,__AHEADER_FIELD__]  := 'TRF_TABELA'			// Nome do Campo
aTrfHeader[__TRF_TABELA__,__AHEADER_VISUAL__] := "V"

aAdd( aTrfHeader, aClone(aVrtHeader[nPosPer]) )							//-- Campo Tabela
aTrfHeader[__TRF_DESCTAB__,__AHEADER_TITLE__]  := OemToAnsi(STR0016)	// Descricao --> "Desc. Tabela"
aTrfHeader[__TRF_DESCTAB__,__AHEADER_WIDTH__]  := 20	  				// Tamanho
aTrfHeader[__TRF_DESCTAB__,__AHEADER_FIELD__]  := 'TRF_DESCTAB'			// Nome do Campo
aTrfHeader[__TRF_DESCTAB__,__AHEADER_VISUAL__] := "V"

If cPaisLoc == "BRA"
	aAdd( aTrfHeader, aClone(aVrtHeader[nPosPer]) )							//-- Campo Empresa Destino
	aTrfHeader[__TRF_EMPPARA__,__AHEADER_TITLE__]  := OemToAnsi(STR0021)	// "Empresa " ## "Para"
	aTrfHeader[__TRF_EMPPARA__,__AHEADER_WIDTH__]  := 3	  					// Tamanho
	aTrfHeader[__TRF_EMPPARA__,__AHEADER_FIELD__]  := 'TRF_EMPPARA'			// Nome do Campo
	aTrfHeader[__TRF_EMPPARA__,__AHEADER_VISUAL__] := "V"
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁGeracao do aCols da tela de Periodos  						      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lLote // Reordenar somente para Lote pois nao possui referencia com aRecChange (Recnos)
	aSort( aPerChange,,, { |x,y| x[5]+x[1]+x[3]+x[4] < y[5]+y[1]+y[3]+y[4] } )
EndIf
aTrfCols := Array(Len( aPerChange ),12)
For nX := 1 To Len( aPerChange )
	aTrfCols[nX,__TRF_PROCES__]  := aPerChange[nX, 05]	// Processo Origem
	aTrfCols[nX,__TRF_PERDE__] 	 := aPerChange[nX, 03]	// Periodo Origem
	aTrfCols[nX,__TRF_NRODE__] 	 := aPerChange[nX, 04]	// Nro de Pagto Origem
	aTrfCols[nX,__TRF_ROTDE__] 	 := aPerChange[nX, 06]	// Roteiro de Origem
	aTrfCols[nX,__TRF_PROCPARA__]:= aPerChange[nX, 09]	// Processo Destino
	aTrfCols[nX,__TRF_PERPARA__] := If(Empty(aPerChange[nX, 07]),Space(aTrfHeader[__TRF_PERPARA__,__AHEADER_WIDTH__]),aPerChange[nX, 07])  // Periodo Destino
	aTrfCols[nX,__TRF_NROPARA__] := If(Empty(aPerChange[nX, 08]),Space(aTrfHeader[__TRF_NROPARA__,__AHEADER_WIDTH__]),aPerChange[nX, 08]) // Nro de Pagto Destino
	aTrfCols[nX,__TRF_FILIAL__]  := aPerChange[nX, 02]	// Filial
	aTrfCols[nX,__TRF_TABELA__]  := aPerChange[nX, 01]	// Tabela
	If cPaisLoc == "BRA"
		aTrfCols[nX,__TRF_EMPPARA__] := aPerChange[nX, 10]	// Empresa Destino
	Endif
	aTrfCols[nX,__TRF_DESCTAB__] := fDesc( "SX2" , aPerChange[nX, 01], "X2_NOME") // Descricao Tabela
	aTrfCols[nX,__DELETED__] 	 := .F.				  	// Deletado
Next nX

aTrfTabs := aClone(aTrfCols)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta as Dimensoes dos Objetos - Possui mais itens atualiza- Ё
//Ё dos na funcao Gpe290Window                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aAdvSize	:= MsAdvSize()
aAdvSize[1]	:= 01
aAdvSize[5]	:= 680
aAdvSize[6]	:= 540
aAdvSize[7]	:= 196
aAdvSize[3]	:= aAdvSize[5]/2
aAdvSize[4] := ( aAdvSize[6] - aAdvSize[7] - 20 ) / 2

aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
aAdd( aObjSize , aClone( aObjSize[1] ) )

aObjSize[ 1 , 3 ] := aObjSize[ 1 , 3 ]-3

bDialogInit	:= { || EnchoiceBar( oTrfDlg , bSet15 , bSet24, NIL, If( !lLote, aButtons, NIL ) ) }

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando houver transferencia de Empresa                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cTrfEmp) .Or. !cTrfFil==Space(FwGetTamFilial)
	If Empty(cTrfEmp)
		cEmp := cEmpAnt
	EndIf
	If Empty(cTrfFil)
		cFil := cFilAnt
	EndIf
	__cLastEmp := cEmpAnt+cFilAnt
	ChangeRCH(cEmp,cFil)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta o Dialogo Principal                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oTrfDlg TITLE OemToAnsi( STR0003 ) From aAdvSize[7],aAdvSize[1] TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL //"Transferencia de Processos"

	oGetDados	:= MsNewGetDados():New(	aObjSize[2,1],;  		// nTop
										aObjSize[2,2],;			// nLelft
										aObjSize[2,3],;			// nBottom
										aObjSize[2,4],;			// nRright
										GD_UPDATE+GD_DELETE,; 	// controle do que podera ser realizado na GetDado - nstyle
										'GpTrfTabs()',;			// funcao para validar a edicao da linha - ulinhaOK
										'GpTrfTudoOk',;			// funcao para validar todos os registros da GetDados - uTudoOK
										NIL,;					// cIniCPOS
										NIL,;					// aAlter
										0,;						// nfreeze
										99999,;					// nMax
										'GpTrfTabs()',;			// cFieldOK
										NIL,;					// usuperdel
										{ || GpTrfDel() },;		// bloco com funcao para validar registros deletados (Gp400DelOk())
										oTrfDlg,;              	// objeto de dialogo - oWnd
									    aTRFHeader,;			// Vetor com Header - AparHeader
									    aTRFCols;				// Vetor com Colunas - AparCols
									  )
  	If cPaisLoc == "BRA"
  		oGetDados:bChange := { |lChange|cProcesso := oGetDados:acols[oGetDados:nAt, __TRF_PROCPARA__] ,ChangeRCH(oGetDados:acols[oGetDados:nAt, __TRF_EMPPARA__], oGetDados:acols[oGetDados:nAt,__TRF_FILIAL__] ) }
  	Endif
	bSet15		:= { || If( GpTrfTudoOk(oGetDados:oBrowse), ( lRet := .T., oTrfDlg:End() ) , .F.) }
	bSet24		:= { || If( lLote, ( If( MsgYesNo( OemToAnsi(STR0018) ), oTrfDlg:End(), .F.) ), oTrfDlg:End()) } // "Deseja realmente Cancelar a Transferencia?"
ACTIVATE MSDIALOG oTrfDlg ON INIT Eval( bDialogInit ) CENTERED

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retornar a Empresa da consulta F3                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cTrfEmp) .Or. !cTrfFil==Space(FwGetTamFilial)
	ChangeRCH( cSvEmpAnt, cSvFilAnt )
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gravar as informacoes no banco                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet
	aSaveCols := aClone(oGetDados:aCols)
	If lGrava
		lRet := CheckExecForm( { || GravaTrf(aRecChange) }, .T. )
	EndIf
EndIf

cArqTab := cSvArqTab

Return(lRet)

/*/
зддддддддддбдддддддддддбддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁGravaTrf   ЁAutor Ё Mauricio Takakura     Ё Data Ё 23/04/07 Ё
цддддддддддедддддддддддаддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValid do Campo de Periodo e Nro de Pagamento                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA010	                                                	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function GravaTrf(aGrvRecno, aCols, lGeraSRE, cProcesso, cTrfEmp, cTrfFil)
Local cTabela
Local cFldPer
Local cFldNro
Local cFldProc
Local cFldRot
Local cPerDe
Local cRotDe
Local cNroDe
Local cTipo3
Local cRotMov
Local cAliasSRR 	:= "SRR"
Local cFilSRA 	:= SRA->RA_FILIAL
Local cMatr	  	:= SRA->RA_MAT
Local cProcAnt 	:= SRA->RA_PROCES
Local cCct		:= SRA->RA_CC
Local cItemct	:=""
Local cClvlct   :=""

Local lDelet

Local nReg
Local nRegs
Local nRecno
Local nRecSRR
Local nNextRecno
Local nPosCols
Local nOrdemSRR

DEFAULT aGrvRecno := aClone(aRecChange)
DEFAULT aCols	  := aClone(aSaveCols)
DEFAULT lGeraSRE  := .T.
DEFAULT cProcesso := M->RA_PROCES

If lItemClvl
	cItemct:=SRA->RA_ITEM
	cClvlct:=SRA->RA_CLVL
EndIf
// Gerar o array com recnos a serem atualizados
If !Empty(cTrfEmp)
	fTransProc(NIL, cProcesso, NIL, cTrfFil, .F., .F. )
EndIf

If !lItemClvl
	nOrdemSRR := RetOrder( "SRR", "RR_FILIAL+RR_MAT+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_SEQ+DTOS(RR_DATA)" )
Else
	nOrdemSRR := RetOrder( "SRR", "RR_FILIAL+RR_MAT+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_ITEM+RR_CLVL+RR_SEQ+DTOS(RR_DATA)" )
EndIf
nRegs := Len(aGrvRecno)
For nReg := 1 To nRegs
	nPosCols	:= aGrvRecno[nReg, 2]
	nRecno 		:= aGrvRecno[nReg, 3]
	cTabela 	:= aCols[nPosCols, __TRF_TABELA__]
	cAliasSRR	:= "SRR"
	cRotMov 	:= aGrvRecno[nReg, 4]

	cFldPer  	:= aGrvRecno[nReg, 5, 1]
	cFldNro  	:= aGrvRecno[nReg, 5, 2]
	cFldProc 	:= aGrvRecno[nReg, 5, 3]
	cFldRot  	:= aGrvRecno[nReg, 5, 4]

	// Quando houver transferencia entre empresas - utilizar tabela da empresa destino
	If !Empty( cTrfEmp )
		If ( Select( "GPE"+cTabela ) == 0 )
			If !fAbrEmpresa(cTabela,nOrdemSRR)
				Loop
			EndIf
		EndIf
		cTabela 	:= "GPE"+cTabela
		cAliasSRR	:= "GPE"+cAliasSRR
	EndIf

	Begin Transaction
		(cTabela)->(DbGoTo( nRecno ))
		lDelet := aCols[nPosCols, __DELETED__]
		(cTabela)->(RecLock(cTabela,.F.))
		If cTabela $ "SRG/SRH/GPESRG/GPESRH"
			cPerDe 	:= aCols[nPosCols,__TRF_PERDE__]
			cRotDe  := aCols[nPosCols,__TRF_ROTDE__]
			cNroDe  := aCols[nPosCols,__TRF_NRODE__]
			cTipo3  := If( cTabela $ "SRG/GPESRG", 'R', 'F' )
			If Empty( cRotDe )			// Roteiro do cadastro de periodo em branco, utilizar do movimento
				cRotDe := cRotMov
			EndIf
			DbSelectArea( cAliasSRR )
			DbSetOrder( nOrdemSRR )
			DbSeek( cFilSRA + cMatr + cPerDe + cRotDe + cNroDe, .F. )
			nNextRecno := 0
			nRecSRR    := 0
			While !Eof() .and. (cAliasSRR)->( RR_FILIAL+RR_MAT+RR_PERIODO+RR_ROTEIR+RR_SEMANA ) == cFilSRA + cMatr + cPerDe + cRotDe + cNroDe

				IF !GetNextRecno( cAliasSRR , @nNextRecno , @nRecSRR , nOrdemSRR )
					DbSkip()
					Loop
				EndIF

				If (cAliasSRR)->RR_PROCES <> cProcAnt .Or. (cAliasSRR)->RR_TIPO3 <> cTipo3
					GotoNextRecno( cAliasSRR, nNextRecno , nOrdemSRR )
					Loop
				EndIf

				RecLock(cAliasSRR,.F.)
				If !lDelet
					(cAliasSRR)->RR_PERIODO := aCols[nPosCols,__TRF_PERPARA__]
					(cAliasSRR)->RR_SEMANA	:= aCols[nPosCols,__TRF_NROPARA__]
					(cAliasSRR)->RR_ROTEIR	:= If( Empty(aCols[nPosCols,__TRF_ROTDE__]), cRotMov, aCols[nPosCols,__TRF_ROTDE__])
					(cAliasSRR)->RR_PROCES	:= cProcesso
				Else
					dbDelete()
				EndIf
				MsUnLock()
				GotoNextRecno( cAliasSRR, nNextRecno , nOrdemSRR )
			EndDo
		EndIf

		If !lDelet
			If !Empty( cFldProc )
				(cTabela)->(&cFldProc) := cProcesso
			EndIf
			If !Empty( cFldPer )
				(cTabela)->(&cFldPer) := aCols[nPosCols,__TRF_PERPARA__]
			EndIf
			If !Empty( cFldNro )
				(cTabela)->(&cFldNro) := aCols[nPosCols,__TRF_NROPARA__]
			EndIf
			If !Empty( cFldRot )
				(cTabela)->(&cFldRot) := If( Empty(aCols[nPosCols,__TRF_ROTDE__]), cRotMov, aCols[nPosCols,__TRF_ROTDE__])
			EndIf
		Else
			(cTabela)->(dbDelete())
		EndIf
		( cTabela )->( MsUnLock() )
	End Transaction
Next nReg

If lGeraSRE // Gerar Informacoes no SRE
	Begin Transaction
		SRE->(RecLock("SRE",.T.))
		SRE->RE_DATA 	:= MsDate()
		SRE->RE_EMPD 	:= cEmpAnt
		SRE->RE_FILIALD := cFilSRA
		SRE->RE_MATD	:= cMatr
		SRE->RE_CCD		:= cCct
		If litemClvl
			SRE->RE_ITEMD		:= cItemct
			SRE->RE_CLVLD		:= cClvlct
		EndIf
		SRE->RE_PROCESD	:= cProcAnt
		SRE->RE_EMPP	:= cEmpAnt
		SRE->RE_FILIALP := cFilSRA
		SRE->RE_MATP	:= cMatr
		SRE->RE_CCP		:= cCct
		If lItemClvl
			SRE->RE_ITEMP		:= cItemct
			SRE->RE_CLVLP		:= cClvlct
		EndIf
		SRE->RE_FILIALP := cFilSRA
		SRE->RE_PROCESP := cProcesso
		SRE->( MsUnLock() )
	End Transaction
EndIf

Return

/*/
зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁGpTrfTudoOk Ё Autor ЁMauricio Takakura    Ё Data Ё09/08/2004Ё
цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁCritica Todas as Linhas digitadas                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGpea400                                                     Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function GpTrfDel()

Local lRet := .T.

If oGetDados:aCols[oGetDados:nAt, __TRF_TABELA__] == "SRA"
	lRet := .F.
EndIf

Return( lRet )

/*/
зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁGpTrfTudoOk Ё Autor ЁMauricio Takakura    Ё Data Ё09/08/2004Ё
цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁCritica Todas as Linhas digitadas                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGpea400                                                     Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function GpTrfTudoOk( oBrowse )
Local lTudoOk	:= .T.		//variavel para controle de Retorno
Local n			:= 0
Local nX 		:= 0		//variavel while/for

For nX := 1 To Len(oGetDados:aCols)
	n := nX
	If !oGetDados:aCols[nX, __DELETED__]
		If !(lTudoOk := ValPer( 3, oGetDados:aCols[nX,__TRF_FILIAL__],oGetDados:aCols[nX,__TRF_ROTDE__], oGetDados:aCols[nX,__TRF_PERPARA__], oGetDados:aCols[nX,__TRF_NROPARA__], oGetDados:aCols[nX,__TRF_TABELA__] ))
	 	    Exit
	 	EndIf
    EndIf
Next nX
If !lTudoOK
	oGetDados:Goto( n )
	oGetDados:Refresh()
EndIf

Return(lTudoOk)

/*/
зддддддддддбдддддддддддбддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁValPer	   ЁAutor Ё Mauricio Takakura     Ё Data Ё 23/04/07 Ё
цддддддддддедддддддддддаддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValid do Campo de Periodo e Nro de Pagamento                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA010	                                                	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function ValPer( nTipo, cFilRCH, cRoteiro, cPer, cNumPago, cTable) // 1-Validar Periodo, 2-Periodo+Numero Pago
Local aArea 	:= GetArea()
Local cAlias	:= "RCH"
Local lRet		:= .T.

DEFAULT cTable  := ""
DEFAULT nTipo 	:= 2

If !Empty(cTrfEmp)
	If !( lRet := fAbrEmpresa( "RCH" , 1 ) )
		Return( lRet )
	EndIf
	cAlias := "GPERCH"
EndIf

DbSelectArea( cAlias )
DbSetOrder( RetOrder("RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG") )
If nTipo == 1
	DbSeek( xFilial("RCH") + cProcesso + cRoteiro + cPer, .F.)
ElseIf nTipo == 2 .Or. nTipo == 3
	DbSeek( xFilial("RCH") + cProcesso + cRoteiro + cPer + cNumPago, .F.)
EndIf
If (cAlias)->( Eof() )
	Help( ' ' , 1 , "TRANSPROC", , OemToAnsi(STR0011) , 1 , 0 ) //"Periodo invalido para esse processo!"
 	lRet := .F.
Else
	// SRA -> Permitir periodos abertos e fechados
	If cTable <> "SRA" .and. nTipo == 3
		If !Empty((cAlias)->(RCH_DTFECH))
			Help( ' ' , 1 , "TRANSPROC", , OemToAnsi(STR0014)+CRLF+CRLF+OemToAnsi(STR0015), 1 , 0 ) //"Periodos ja esta fechado!" ### Selecione um periodo aberto!"
			lRet := .F.
		EndIf
	EndIf
EndIf
If lRet
	cRot 		:= ''
	cPeriodo 	:= ''
EndIf

If !Empty(cTrfEmp)
	fFecEmpresa( "RCH" )
EndIF

RestArea( aArea )

Return(lRet)

/*/
зддддддддддбдддддддддддбддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁWhenPer	   ЁAutor Ё Mauricio Takakura     Ё Data Ё 23/04/07 Ё
цддддддддддедддддддддддаддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁUtilizado para Atualizar as variaveis do Filtro F3 - RCH    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA010	                                                	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function WhenPer(nTipo, cRoteiro, cPer, cTable)

DEFAULT cTable := ""
// Controlar o filtro da consulta F3 por Tabela
If cTable $ "SRA*RGB"
	cCond := "3"
Else
	cCond := "1"
EndIf
cRot 		:= cRoteiro
cPeriodo	:= cPer

Return(.T.)

/*/
зддддддддддбдддддддддддбддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁfVisualReg ЁAutor Ё Mauricio Takakura     Ё Data Ё 23/04/07 Ё
цддддддддддедддддддддддаддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁVisualizar a Informacao do Cadastro                         Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGPEA010	                                                	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function fVisualReg(cTabela, aRecnos)

Local aAdvSize
Local aInfoAdvSize
Local aObjCoords	:= {}
Local aObjSize
Local aSvCols
Local aVisCols		:= {}
Local aVisHeader
Local aRecProc		:= {}

Local cCampo

Local nX
Local nRecno
Local nField
Local nFields

Local oVisDlg
Local oVisGetDados

aSvCols := (cTabela)->( GdMontaCols( @aVisHeader,NIL,NIL,NIL,NIL,NIL,NIL,NIL,"XZ",NIL,NIL,NIL,NIL,NIL,NIL,NIL,.T.))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carregar o aCols com as Informacoes a Demonstrar             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aEval(aRecnos, { |x| If( x[1] == cTabela, aAdd( aRecProc, x[3] ), .T. ) } )
For nX := 1 To Len(aRecProc)
	aAdd(aVisCols, aClone(aSvCols[1]) )
	nRecno := aRecProc[nX]
	(cTabela)->(DbGoTo( nRecno ))
	nFields := Len( aVisHeader )
	For nField := 1 To nFields
		If!( "ALI_WT" $ aVisHeader[nField, __AHEADER_FIELD__] .Or. "REC_WT" $ aVisHeader[nField, __AHEADER_FIELD__] )
			cCampo := aVisHeader[nField, __AHEADER_FIELD__]
			aVisCols[nX, nField] := (cTabela)->(&cCampo)
		EndIf
	Next nField
Next nX

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta as Dimensoes dos Objetos - Possui mais itens atualiza- Ё
//Ё dos na funcao Gpe290Window                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aAdvSize		:= MsAdvSize()
aAdvSize[1]		:= 01
aAdvSize[5]		:= 720
aAdvSize[6]		:= 650
aAdvSize[7]		:= 250
aAdvSize[3]		:= aAdvSize[5]/2
aAdvSize[4] 	:= ( aAdvSize[6] - aAdvSize[7] - 20 ) / 2

aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
aAdd( aObjSize , aClone( aObjSize[1] ) )

aObjSize[ 1 , 3 ] := aObjSize[ 1 , 3 ]-3

bDialogInit	:= { || EnchoiceBar( oVisDlg , bSet15 , bSet24 ) }

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta o Dialogo Principal                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oVisDlg TITLE OemToAnsi( STR0010 ) From aAdvSize[7],aAdvSize[1] TO aAdvSize[6],aAdvSize[5]  OF oMainWnd PIXEL //"Informacoes do Registro"

	oVisGetDados	:= MsNewGetDados():New(	aObjSize[2,1],;  		// nTop
				  							aObjSize[2,2],;			// nLelft
											aObjSize[2,3],;			// nBottom
											aObjSize[2,4],;			// nRright
											NIL,; 					// controle do que podera ser realizado na GetDado - nstyle
											NIL,;					// funcao para validar a edicao da linha - ulinhaOK
											NIL,;					// funcao para validar todos os registros da GetDados - uTudoOK
											NIL,;					// cIniCPOS
											NIL,;					// aAlter
											0,;						// nfreeze
											99999,;					// nMax
											NIL,;					// cFieldOK
											NIL,;					// usuperdel
											NIL,;					// bloco com funcao para validar registros ados (Gp400DelOk())
											oVisDlg,;              	// objeto de dialogo - oWnd
										    aVisHeader,;			// Vetor com Header - AparHeader
										    aVisCols;				// Vetor com Colunas - AparCols
										  )

		bSet15		:= { ||oVisDlg:End() }
		bSet24		:= { ||oVisDlg:End() }
ACTIVATE MSDIALOG oVisDlg ON INIT Eval( bDialogInit )

Return( .T. )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁChangeRCH Ё Autor ЁMauricio T. Takakura   Ё Data Ё03/05/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁAbrir RCH para Consulta via Tecla F3                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ cEmp - Empresa de Destino                                  Ё
Ё          Ё cFil - Filial  de Destino                                  Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ChangeRCH(cEmp, cFil)

Local cModo := IIF(xFilial("RCH")==Space(FwGetTamFilial),"C","E")
Local nAT

	IF cEmp+cFil != __cLastEmp
		IF cEmp != SubStr(__cLastEmp,1,2)
			If Select("RCH") > 0
				RCH->(dbCloseArea())
			EndIf
			UniqueKey( NIL , "RCH" , .T. )
			MyEmpOpenFile("RCH","RCH",1,.t.,cEmp,@cModo)
		EndIF
		__cLastEmp := cEmp+cFil
		cEmpAnt := cEmp
		cFilAnt := cFil
		nAT := AT("RCH",cArqTab)
		IF nAT > 0
			cArqTab := SubStr(cArqTab,1,nAT+2)+cModo+SubStr(cArqTab,nAT+4)
		Else
			cArqTab += "RCH"+cModo+"/"
		EndIF
	EndIF

Return( NIL )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGetPerTrf Ё Autor ЁMauricio T. Takakura   Ё Data Ё08/05/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRetornar Array com os periodos selecionados                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ															Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GetPerTrf(aCols, aHeader)
aCols	:= aClone( aSaveCols )
aHeader	:= aClone( aTrfHeader )
Return( aClone(aSaveCols) )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGpTrfTabs Ё Autor ЁMarcelo Silveira       Ё Data Ё20/09/2011Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMantem o alias do registro que teve o periodo alterado      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ															Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function GpTrfTabs()

If "TRF_PERPARA" $ ReadVar()
	IF oGetDados:LEDITLINE
		aCols[oGetDados:nAt,__TRF_TABELA__]		:= aTrfTabs[n][__TRF_TABELA__]
		aCols[oGetDados:nAt,__TRF_DESCTAB__]	:= aTrfTabs[n][__TRF_DESCTAB__]
		aCols[oGetDados:nAt,__TRF_FILIAL__] 	:= aTrfTabs[n][__TRF_FILIAL__]
		If cPaisLoc == "BRA"
			aCols[oGetDados:nAt,__TRF_EMPPARA__] 	:= aTrfTabs[n][__TRF_EMPPARA__]
		Endif
	Else
		oGetDados:aCols[oGetDados:nAt,__TRF_TABELA__]	:= aTrfTabs[n][__TRF_TABELA__]
		oGetDados:aCols[oGetDados:nAt,__TRF_DESCTAB__]	:= aTrfTabs[n][__TRF_DESCTAB__]
		oGetDados:aCols[oGetDados:nAt,__TRF_FILIAL__] 	:= aTrfTabs[n][__TRF_FILIAL__]
		If cPaisLoc == "BRA"
			oGetDados:aCols[oGetDados:nAt,__TRF_EMPPARA__] 	:= aTrfTabs[n][__TRF_EMPPARA__]
		Endif
	ENDIF
EndIf

Return(.T.)

/*
зддддддддддбдддддддддддддддддбдддддддддддбддддддддддддддддбддддддбдддддддддд©
ЁFunГЦo    Ё  MyEmpOpenFile  Ё  Autoria  Ё   Isabel N.    Ё Data Ё14/03/2017Ё
цддддддддддедддддддддддддддддадддддддддддаддддддддддддддддаддддддадддддддддд╢
ЁDescriГЦo Ё Abre Arquivo de Outra Empresa                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ x1 - Alias com o Qual o Arquivo Sera Aberto                    Ё
Ё          Ё x2 - Alias do Arquivo Para Pesquisa e Comparacao               Ё
Ё          Ё x3 - Ordem do Arquivo a Ser Aberto                             Ё
Ё          Ё x4 - .T. Abre e .F. Fecha                                      Ё
Ё          Ё x5 - Empresa                                                   Ё
Ё          Ё x6 - Modo de Acesso (Passar por Referencia)                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MyEmpOpenFile(x1,x2,x3,x4,x5,x6)

Local cSavE := cEmpAnt, cSavF := cFilAnt, xRet
xRet	:= EmpOpenFile(@x1,@x2,@x3,@x4,@x5,@x6)
cEmpAnt := cSavE
cFilAnt := cSavF

Return( xRet )


/*/{Protheus.doc} ChkTamFil
Funcion que verifica si se esta usando gestion corporativa o no
Example:	ChkTamFil( @cAlix,@cFilAt )
@param		cAlix = Alias RCH tabla de periodos.
@param		cFilAt = Filial correspondiente a la tabla SRA.
@return		cFilBus = Filial que se retorna despues de verificar el uso de la gestion corpotativa
@author		Eduardo PИrez ManrМquez
@since		24/03/2020
@version	12
/*/
Function ChkTamFil (cAlix,cFilAt)
Local cFilBus := ""
Local lGestao := ( FWSizeFilial() > 2 )
Local lExcTab := Iif( lGestao, FWModeAccess(cAlix,1) == "E", FWModeAccess(cAlix,3) == "E") //verifica el acceso a nivel empresa 1, o a nivel filial 2
Default cFilAt:=cFilAnt
if !lExcTab
    cFilBus:=cFilAt
else
	cFilBus:=xfilial(cAlix)
endif

return	cFilBus