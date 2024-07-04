#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEXIDC.CH"
#INCLUDE "GPECONV.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ#ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GpeConv   ºAutor  ³Leandro Drumond     º Data ³  22/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função principal para a conversão da folha p12.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ºCícero Alves| 05/03/2015|Inclusão da função fAjustSXB e ajustes na SX3 º±±
±±ºP. Pompeu   | 17/03/2016|Correção Query para Informix................. º±±
±±ºP. Pompeu   | 13/04/2016|Adicionado Parametro cFiltro na funcão ConvSRFº±±
±±ºP. Pompeu   | 13/05/2016|TUNK86: Correções na Conversão da SRF..........±±
±±ºMatheus M.  | 21/06/2016|TVBWDR: Correções para os arquivos: SRR e SRH -±±
±±º			   | 		   |TVBWDR: SRD, RIS e SR0.						   ±±
±±ºMatheus M.  | 24/06/2016|TUWV93: Correções para o arquivo: RG3 		   ±±
±±ºMatheus M.  | 28/06/2016|TUVMVK: Correções para o arquivo: SR0 		   ±±
±±ºMatheus M.  | 08/07/2016|TVGR31: Correções para o Log do arquivo SRR.   ±±
±±ºMatheus M.  | 15/07/2016|TVI475: Ajuste na exibição das filiais.        ±±
±±ºMatheus M.  | 27/07/2016|TVQE72: Ajuste na conversão da RCG - Evitando  ±±
±±º			   | 		   |TVQE72: que o conversor entre em loop.		   ±±
±±ºAllyson M.  | 04/08/2016|TVPCHS: Ajuste para converter verbas de PLR    ±±
±±ºMatheus M.  | 05/09/2016|TVNCAA: Ajuste para converter SRR corretamente.±±
±±ºRaquel Hager| 09/09/2016|TVYMJ8: Correção na função ConvSRF para consi- ±±
±±º			   | 		   |derar conteudo do cAnoMes na geração de dados  ±±
±±º			   | 		   |da SRF devido migração Logix.                  ±±
±±ºGabriel A.  | 14/09/2016|TVZYBO:Ajuste na conversão da SRD.             ±±
±±ºGabriel A.  | 27/09/2016|TWAR65:Ajuste na validação de dados já         ±±
±±º            |           |      :convertidos da SRR.                     ±±
±±ºMatheus M.  | 03/10/2016|TVXEE9: Ajuste na conversão das verbas SRV.    ±±
±±ºFlavio C.   | 07/10/2016|TWCSG7 - Verificado dias de direito na SRH ao  ±±
±±º            |           |inves de estar fixo 30 dias					   ±±
±±º            |           |TWBV16 - Importação de layout de variaveis     ±±
±±º            |           |importando dois campos Data Referencia, sendo  ±±
±±º            |           |que um deles não tem relação com a RGB causando±±
±±º            |           | erro.										   ±±
±±º            |           |TWCCRD - Na 11 tem o campo RH_dtitens para 	   ±±
±±º            |           |tratar isso. Checar se o campo rh_dtitens existe±±
±±º            |           |, se ele existir uliliza-lo para comparar com a±±
±±º            |           |SRR caso contrario utilizar o rh_dtrecib	   ±±
±±º            |           |TWCBZR - Verificado se o campo rk_status está  ±±
±±º            |           |vazio e iniciado com '2' = ativo			   ±±
±±º            |           |TWDO31 - Criar na SRD um novo registro com ID  ±±
±±º            |           |0006 com o mesmo valor do ID 007 no roteiro ADI±±
±±º            |           |TVLPCT - Ajustado grid para mudar de acordo    ±±
±±º            |           | com a resolução 							   ±±
±±º            |           |TWFNJS - Atualizar o status da SRF para 	   ±±
±±º            |           |prescrito quando tem afastamento e perda de    ±±
±±º            |           | direito									   ±±
±±º            |           |TWFNJZ - Data limite para geração de periodo   ±±
±±º            |           |passa a ser o MV_FOLMES, caso esteja em branco ±±
±±º            |           | será usado a database 						   ±±
±±ºEduardo K.  | 10/11/2016|TWISPD - Ajuste na conversão do RD_ROTEIR p/   ±±
±±º            |           |verbas de 1º e 2º pgto de 13º                  ±±
±±ºEduardo K.  | 10/11/2016|TWKUAI - Ajuste na gravação do RD_SALARIO      ±±
±±ºGabriel A.  | 12/01/2017|Ajuste na conversão de dados de autônomos.     ±±
±±ºRenan Borges| 09/02/2017|Ajuste para ao realizar a conversão verificar  ±±
±±º            |           |a verba com ID 0008 que deve ser levada para a ±±
±±º            |           |nova versão com o roteiro de folha.            ±±
±±ºRaquel Hager| 15/02/2017|Ajuste para incluir criação de verba para ID   ±±
±±º            |           |1415 - 1 Parc. 13 Antecipado mesmo mes rescisão±±
±±ºIsabel N    | 30/08/2017|DRHPAG-5247 - Conversão verbas 13o.1a.Parc.    ±±
±±ºOswaldo L   | 27/11/2017|DRHPAG-8123 - Proteção erro de calculo quando  ±±
±±º            |           | a  data  final  estava  em  branco no cadastro±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Main function GFPConv()
	Local aFields		:= {}
	Local cPathSrv		:= GetSrvProfString("Startpath","")
	Local nRecSM0		:= 0
	Local cArqLogIdx	:= ""
	Local lCriaIdx		:= .T.

	Private oMsSelect 	:= Nil
	Private cNameFile	:= ""
	Private cNameLog	:= ""
	Private oWizard		:= Nil
	Private aParFil 	:= {}
	Private lPar04		:= .F.
	Private lPar06		:= .T.
	Private lTab01		:= .T.
	Private lTab02		:= .T.
	Private lTab03		:= .T.
	Private lTab04		:= .T.
	Private lTab05		:= .T.
	Private lTab06		:= .T.
	Private lTab07		:= .T.
	Private lTab08		:= .T.
	Private lTab09		:= .T.
	Private lTab10		:= .T.
	Private lTab11		:= .T.
	Private lTab12		:= .T.
	Private lTab13		:= .T.
	Private lTab14		:= .T.
	Private lTab15		:= .T.
	Private lTab16		:= .T.
	Private lTab17		:= .T.
	Private lTab18		:= .T.
	Private lTab19		:= .T.
	Private lTab20		:= .T.
	Private lTab21		:= .T.
	Private lTab22		:= .T.
	Private lTab23		:= .T.
	Private lTab24		:= .T.

	Private cFilOk		:= ""
	Private cDbfFil		:= "CONV"
	Private cDbfLog		:= "CLOG"
	Private cMark		:= ""
	Private lPreConv	:= .F.
	Private lRCMCompPr  := .F.
	Private cDataDe		:= Space(6)
	Private cDataAte	:= Space(6)

	OpenSm0Excl()
	DbSelectArea("SM0")
	dbGotop()

	while !SM0->(Eof())
		if SM0->(deleted())
			SM0->(DbSkip())
		else
			exit
		EndIf
	enddo

	RpcSetType(3)
	RpcSetEnv(SM0->M0_CODIGO, FwGetCodFilial,,,,,)

	cMark := GetMark()

	// Verifica a Existencia de "\" ou "/" barras separadoras de diretorio
	If !( Subst( cPathSrv , 1 , 1 ) $ "\/" )
		cPathSrv := "\"+cPathSrv
	EndIf

	If !( Subst( cPathSrv , -1	) $ "\/" )
		cPathSrv+= "\"
	EndIf

	cNameFile  := RetArq(__cRDD,"GPECONV",.T.)

	Begin Sequence
		If TCCanOpen(cNameFile)
			TCDelFile(cNameFile)
		EndIf

		aAdd(aFields, { "EMPRESA"	,"C",Len(SM0->M0_CODIGO)		,0} )
		aAdd(aFields, { "FILIAL"	,"C",Len(SM0->M0_CODFIL)		,0} )
		aAdd(aFields, { "MARK"		,"C",02							,0}	)
		aAdd(aFields, { "NOME"		,"C",20							,0}	)

		If !( lRet := MsCreate( cNameFile , aFields , "TOPCONN" ) )
			lCriaIdx := .F.
			Conout("Falha na criacao do arquivo")
			Break
		EndIf

		If lCriaIdx
			DbUseArea(.T., "TOPCONN", cNameFile, cNameFile, .F., .F.)
			dbCreateIndex(cNameFile+"1", "EMPRESA+FILIAL", { || EMPRESA+FILIAL })
			(cNameFile)->(DbCloseArea())
		EndIf

		If !( MsOpenDbf( .T. , "TOPCONN" , cNameFile , cDbfFil , .T. , .F. , .F. , .F. ) )
			Conout("Falha na abertura do arquivo")
			cDbfFil := ""
			Break
		EndIf

		dbClearind()
		dbSetIndex( cNameFile+"1" )

		If (cDbfFil)->(Eof())
			nRecSM0 := SM0->(Recno())
			SM0->(dbGotop())

			While SM0->(!Eof())
				If SM0->(deleted())
					SM0->(DbSkip())
					Loop
				EndIf

				RecLock(cDbfFil,.T.)
				(cDbfFil)->EMPRESA 	:= SM0->M0_CODIGO
				(cDbfFil)->FILIAL 	:= SM0->M0_CODFIL
				(cDbfFil)->NOME 	:= SM0->M0_FILIAL
				(cDbfFil)->MARK 	:= cMark
				(cDbfFil)->(MsUnLock())

				nCodEmp := (cDbfFil)->EMPRESA
				SM0->(DbSkip())
			EndDo

			SM0->(DbGoTo(nRecSM0))
			Break
		EndIf

		(cDbfFil)->(DbGoTop())

		While (cDbfFil)->(!Eof())
			If Empty((cDbfFil)->MARK)
				cFilOk += AllTrim((cDbfFil)->(EMPRESA)) + AllTrim((cDbfFil)->(FILIAL)) + "*"
			Else
				cMark := (cDbfFil)->MARK
			EndIf
			(cDbfFil)->(DbSkip())
		EndDo

		(cDbfFil)->(DbGoTop())
	End Sequence

	cNameLog := RetArq(__cRDD,"GPECONVLOG",.T.)
	aFields  := {}

	aAdd(aFields, { "EMPRESA"	,"C",Len("M0_CODIGO")			,0} )
	aAdd(aFields, { "FILIAL"	,"C",FWGETTAMFILIAL				,0} )
	aAdd(aFields, { "DATAI"		,"D",8							,0} )
	aAdd(aFields, { "HORA"		,"C",5							,0} )
	aAdd(aFields, { "MENSAGEM"	,"C",200						,0} )
	aAdd(aFields, { "PROCESSO"	,"N",2  						,0} )

	Begin Sequence
		lCriaIdx := .F.

		If !TCCanOpen(cNameLog)
			lCriaIdx := .T.

			If !( lRet := MsCreate( cNameLog , aFields , "TOPCONN" ) )
				lCriaIdx := .F.
				Conout("Falha na criacao do arquivo de log")
				Break
			EndIf
		EndIf

		If lCriaIdx
			DbUseArea(.T., "TOPCONN", cNameLog, cNameLog, .F., .F.)
			dbCreateIndex(cNameLog+"1", "EMPRESA+FILIAL+PROCESSO", { || EMPRESA+FILIAL+STRZERO(PROCESSO,2) })
			(cNameLog)->(DbCloseArea())
		EndIf

		If !( MsOpenDbf( .T. , 'TOPCONN' , cNameLog , cDbfLog , .T. , .F. , .F. , .F. ) )
			Conout("Falha na abertura do arquivo de log")
			cDbfFil := ""
			Break

		EndIf

		dbClearind()
		dbSetIndex( cNameLog+"1" )

		if (cDbfLog)->(FieldPos("PROCESSO")) == 0
			dbclosearea(cDbfLog)
			TCDelFile(cNameLog)
			lCriaIdx := .T.

			If !( lRet := MsCreate( cNameLog , aFields , "TOPCONN" ) )
				lCriaIdx := .F.
				Conout("Falha na criacao do arquivo de log")
				Break
			EndIf

			If lCriaIdx
				DbUseArea(.T., "TOPCONN", cNameLog, cNameLog, .F., .F.)
				dbCreateIndex(cNameLog+"1", "EMPRESA+FILIAL+PROCESSO", { || EMPRESA+FILIAL+STRZERO(PROCESSO,2) })
				(cNameLog)->(DbCloseArea())
			EndIf
		endIf
	End Sequence

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 1 - Tela inicial do Wizard 		            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard := APWizard():New(	OemToAnsi(STR0001) 								,; // "Efetuando Conversão de Base"
								OemToAnsi(STR0031) + CRLF + OemToAnsi(STR0032) ,; // "Essa ferramenta irá efetuar a conversão dos dados de sua versão antiga do Protheus para a nova versão 12."
								OemtoAnsi(STR0001)								,; // "Efetuando Conversão de Base"
								OemToAnsi(STR0033)								,; // "Nas próximas telas você deverá parametrizar os itens necessários para a conversão, é importante que o manual seja lido antes da conversão para sanar possíveis dúvidas."
								{||.T.} 										,;
								{||.T.}											,;
								.F.												,;
								Nil												,;
								{||.T.}											,;
								Nil												,;
								{00,00,600,800})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 2 - Selecao de Filiais		                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oWizard:NewPanel(	STR0065	,; //"Parametrização"
						STR0066	,; //"Selecione os parâemtros que serão utilizados durante a conversão"
						{||.T.}					,; //<bBack>
						{||.T.} 				,; //<bNext>
						{||.F.}					,; //<bFinish>
						.T.						,; //<.lPanel.>
						{|| GetFilConv()} )		   //<bExecute>
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 3 - Pré-Validações da Base	                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(	STR0065 									,; //""
						STR0068 									,; //" "
						{||.F.} 								    ,; //<bBack>
						{|| iif(lPreConv,.T.,(Alert(STR0069),.F.))} ,; //<bNext>
						{||.F.} 									,; //<bFinish>
						.T. 										,; //<.lPanel.>
						{|lEnd| GpPreCnvEx(@lEnd) }	)	   			   //<bExecute>


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 4 - Seleção das tabelas		                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(	OemToAnsi(STR0036)		,; //"Itens a Converter"
						OemToAnsi(STR0037)		,; //"Selecione as tabelas/itens que deverão ser convertidos"
						{||.T.}					,; //<bBack>
						{|| GpVldConv() }		,; //<bNext>
						{||.F.}					,; //<bFinish>
						.T. 					,; //<.lPanel.>
						{|| GetTabConv()}	)	   //<bExecute>


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 5 - Acompanhamento do Processo               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(	OemToAnsi(STR0001)			,; //"Efetuando Conversão da Base"
						OemToAnsi(STR0038)			,; //"Aguarde o Final do Processamento"
						{||.T.}						,; //<bBack>
						{||.F.} 					,; //<bNext>
						{||.T.}				  		,; //<bFinish>
						.T. 		  				,; //<.lPanel.>
						{| lEnd| GpConvExec(@lEnd)})  //<bExecute>


	oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})
Return Nil


Static Function GpPreCnvEx(lEnd)
	Private oProcess
	// Executa o processamento dos arquivos
	oProcess:=	MsNewProcess():New( {|lEnd| GpPreConv(oProcess) } , STR0070 , STR0070 )     //"Efetuando Conversão da Base"
	oProcess:Activate()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GpConvExecºAutor  ³Leandro Drumond     º Data ³  22/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o controle do obejto process da rotina              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GpConvExec(lEnd)
	Private oProcess

	// Executa o processamento dos arquivos
	oProcess:=	MsNewProcess():New( {|lEnd| GpeConvP(oProcess) } , OemToAnsi(STR0001) , OemToAnsi(STR0001) )     //"Efetuando Conversão da Base"
	oProcess:Activate()
Return


Static Function GpPreConv()
	Local oPanel		:= nil
	Local cEmpAntAux	:= ""
	Local nZ 			:= 0
	Local nX 			:= 0
	Local nPosAux		:= 0
	Local lSRASRD		:= .T.
	Local lSRAAdm		:= .T.
	Local lRHLibUpd		:= .T.
	Local lTamR0		:= .T.
	Local lTamNumID		:= .T.
	Local lCompPer		:= .T.
	Local lidentCalc	:= .T.
	Local aVerbErr		:= {}
	Local aCodFol 		:= {}
	Local aSRV			:= {}
	Local aRetcoords 	:= {}
	Local aLogPreCnv	:= {}
	Local aIdCalObr		:= { "0040", "0041", "0042", "0072", "0103", "0891", "0927" }

	if len(aParFil) == 0
		aParFil := fGetParFil()
	endIf

	oPanel := oWizard:oMPanel[oWizard:nPanel]
	aRetcoords := RetCoords(2,10,20,25,2,,,,{100,0,oPanel:oWnd:nTop*0.92,oPanel:oWnd:nLeft*0.88})

	RpcClearEnv()
	OpenSm0Excl()
	DbSelectArea("SM0")
	dbGotop()
	oProcess:SetRegua2(LEN(aParFil))

	For nX := 1 to Len(aParFil)
		lIdentCalc := .T.
		oProcess:IncRegua2(STR0005 + aParFil[nX][1] + " - " + STR0006 + aParFil[nX][2])

		if !(aParFil[nX][3])
			Loop
		endIf

		aVerbErr := {}
		RpcSetType(3)
		RpcSetEnv(aParFil[nX][1], aParFil[nX][2],,,,,)

		__cInternet := Nil
		cEmpAnt		:= aParFil[nX][1]
		cFilAnt		:= aParFil[nX][2]

		if cEmpAntAux <> cEmpAnt
			fCodFolEmp(@aSRV)
			aadd(aLogPreCnv,"")
			aadd(aLogPreCnv,STR0005 + cEmpAnt)

		//	lTamR0		:= iif(lTamR0, TamSx3("R0_CODIGO")[1] == TamSx3("R0_MEIO")[1], .F.)
			lTamNumID	:= iif(lTamNumID, fTamNumID(@aLogPreCnv), .F.)
			lCompPer	:= iif(lCompPer,fVerCompPer(@aLogPreCnv),.F.)
		endIf

		aadd(aLogPreCnv,"")
		aadd(aLogPreCnv,STR0005 + cEmpAnt + " - " + STR0006 + cFilAnt)

		lSRAAdm 	:= iif(lSRAAdm, fVerDtSRA(@aLogPreCnv, aParFil[nX][2]), .F.)

		For nZ := 1 to Len(aIdCalObr)
			if aScan(aSRV, {|x| x[1] + x[2] == xFilial("SRV") + aIdCalObr[nZ] }) == 0
				if lIdentCalc
					aAdd(aLogPreCnv, "")
					aAdd(aLogPreCnv, STR0071)
					lIdentCalc := .F.
				endIf

				aAdd(aLogPreCnv,aIdCalObr[nZ])
			endIf
		Next nZ

		cEmpAntAux := aParFil[nX][1]
	Next nX

	lRHLibUpd  := GetApoInfo("RHLIBUPD.PRX")[4] >= STOD("20170824")

	TBitmap():New(aRetcoords[1][1],aRetcoords[1][2],30,30,,iif(lSRASRD ,"OK","CANCELA"),.T.,oPanel,NIL,NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	TSay():New(aRetcoords[2][1] + 3 ,aRetcoords[2][2],{||STR0072},oPanel,,,,,,.T.,,,200,60) //Todos os registros da SRD possuem funcionários vinculados e todos os demitidos possuem data de demissão.

	TBitmap():New(aRetcoords[3][1],aRetcoords[3][2],30,30,,iif(lSRAAdm,"OK","CANCELA"),.T.,oPanel,NIL,NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	TSay():New(aRetcoords[4][1] + 3 ,aRetcoords[4][2],{||STR0073},oPanel,,,,,,.T.,,,200,60)// Todos os funcionários possuem a data de admissão.

	TBitmap():New(aRetcoords[5][1],aRetcoords[5][2],30,30,,iif(lRHLibUpd,"OK","CANCELA"),.T.,oPanel,NIL,NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	TSay():New(aRetcoords[6][1] + 3,aRetcoords[6][2],{|| STR0074},oPanel,,,,,,.T.,,,200,60)//RHLIBUPD está atualizado.

	TBitmap():New(aRetcoords[7][1],aRetcoords[7][2],30,30,,iif(lTamR0,"OK","CANCELA"),.T.,oPanel,NIL,NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	TSay():New(aRetcoords[8][1] + 3,aRetcoords[8][2],{|| STR0075},oPanel,,,,,,.T.,,,200,60) //O tamanho dos campos R0_MEIO e R0_CODIGO estão iguais.

	TBitmap():New(aRetcoords[9][1],aRetcoords[9][2],30,30,,iif(lTamNumID,"OK","CANCELA"),.T.,oPanel,NIL,NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	TSay():New(aRetcoords[10][1] + 3,aRetcoords[10][2],{|| STR0076},oPanel,,,,,,.T.,,,200,60)//O tamanho do campo RK_NUMID é Maior que o mínimo necessário para a composição da chave.

	TBitmap():New(aRetcoords[11][1],aRetcoords[11][2],30,30,,iif(lCompPer,"OK","CANCELA"),.T.,oPanel,NIL,NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	TSay():New(aRetcoords[12][1] + 3,aRetcoords[12][2],{|| STR0077},oPanel,,,,,,.T.,,,200,60)//As tabelas de periodo possuem o compartilhamento igual.

	TBitmap():New(aRetcoords[13][1],aRetcoords[13][2],30,30,,iif(lIdentCalc,"OK","CANCELA"),.T.,oPanel,NIL,NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	TSay():New(aRetcoords[14][1] + 3,aRetcoords[14][2],{||STR0078},oPanel,,,,,,.T.,,,200,60)//Identificadores de cálculo possuem Verbas estão cadastradas.

	if(lTamR0 .AND. lTamNumID .AND. lCompPer .AND. lSRASRD .AND. lSRAAdm .AND. lIdentCalc)
		lPreConv := .T.
	endIf

	if(!lPreConv)
		TBitmap():New(aRetcoords[17][1],aRetcoords[17][2],30,30,,"UPDWARNING",.T.,oPanel,{|| ShowLog(STR0120 ,aLogPreCnv)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
		TSay():New(aRetcoords[18][1] + 3,aRetcoords[18][2],{||STR0080},oPanel,,,,,,.T.,,,200,60) //Clique no icone para ver as inconsistências encontradas
	endIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GpeConvP  ºAutor  ³Leandro Drumond     º Data ³  06/24/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de processamento das conversões.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GpeConvP()
	Local aCodFol	:= {}
	Local aTitleFil	:= {}
	Local aLogFil	:= {}
	Local aVerbErr	:= {}
	Local aTable    := {}
	Local aField    := {}
	Local aColPref  := {}
	Local aLogGFP   := {}
	Local cTexto 	:= ""
	Local cIniFil	:= ""
	Local cIniTab	:= ""
	Local cEmp		:= ""
	Local cAux 		:= ""
	Local cVerbErr	:= ""
	Local cFilSRV	:= "!!!!!!!"
	Local cFilRCJ	:= "!!!!!!!"
	Local cInicio	:= 0
	Local nX		:= 1
	Local nY		:= 0
	Local nRecno    := 0
	Local nProcRegua:= 0
	Local lPriVez	:= .T.
	Local dInicio 	:= CtoD("")
	Local dIniFil	:= CtoD("")
	Local dIniTab	:= CtoD("")
	Local nQtdConv	:= GpCntTab()

	Private aTitle		:= {}
	Private aLogErr		:= {}
	Private cAnoMes 	:= ""
	Private cNameDB		:= ""
	Private lGestPubl 	:= IF(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)	//Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP

	// Se for diferente de Gestão Pública não executa o GFPCONV
	IF !lGestPubl
		Alert("Função disponível apenas para Gestão de Folha Pública, verifique o parametro MV_SIGAGFP.")
		ConOut("Função disponível apenas para Gestão de Folha Pública, verifique o parametro MV_SIGAGFP.")
	ELSE
		If MsgYesNo(STR0004, STR0003) // "Deseja efetuar a Conversão dos dados da Folha para P12"#"Atencao"
			cInicio := Time()
			dInicio	:= MsDate()

			RpcClearEnv()
			OpenSm0Excl()
			DbSelectArea("SM0")
			dbGotop()

			//Verifica quantas empresas/filiais ativas existe no sigamat
			While SM0->(!Eof())
				nProcRegua++
				DbSkip()
			EndDo

			dbGotop()
			oProcess:SetRegua1(nProcRegua)
			DbSelectArea("SM0")
			dbGotop()

			// Percorre as empresas
			While SM0->(!Eof())
				If lPar06
					nPosAux := aScan( aParFil ,{|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL) } )

					If nPosAux > 0 .and. aParFil[nPosAux,3]
						lContinua := .T.
					Else
						lContinua := .F.
					EndIf
				Else
					lContinua := .T.
				EndIf

				If !lContinua
					cEmp := SM0->M0_CODIGO
					SM0->(dbSkip())
					nRecno := SM0->(Recno())

					If SM0->(!Eof()) //Se estiver em eof não fecha ambiente para que possa exibir log, se existir.
						SM0->(DbGoTo(nRecno))
					EndIf

					Loop
				EndIf

				If !lPriVez
					RpcClearEnv()
					OpenSm0Excl()
					SM0->(DbGoTo(nRecno))
				EndIf

				cIniFil := Time()
				dIniFil	:= MsDate()

				RpcSetType(3)
				RpcSetEnv(SM0->M0_CODIGO, FwGetCodFilial,,,,, { "SRA", "SRD", "SR8", "RCF", "RCG", "RCH", "RCJ", "RCM", "RFQ" ,"SRV", "SRX", "SRH", "RCA", "SRF", "SR5", "RCC", "SRG", "SRR", "SRK", "SRE", "SRI", "RCE", "SR7", "SR3", "RCB", "RIS", "RG3", "RI1", "RFJ", "RCN", "SRC", "RGB", "RFO", "SRM", "SR0", "RC2", "RC3","SRY","SRW", "RGM"})
				__cInternet := Nil
				lPriVez		:= .F.

				If Empty(cNameDB)
					cNameDB	:= Upper(TcGetDb())
				EndIf

				If cEmp <> SM0->M0_CODIGO
					fAjustSX()
					fAjustSX1()
					lCriaProc := .T. //Deve recriar procedure quando alterar empresa
				EndIf

				MsOpenDbf( .T. , "TOPCONN" , cNameLog , cDbfLog , .T. , .F. , .F. , .F. )
				dbClearind()
				dbSetIndex( cNameLog+"1" )

				aAdd(aTitleFil, STR0006 + xFilial("SRA") ) //"Tempo de processamento filial: " + xFilial("SRA")
				aAdd( aLogFil,{} )
				aAdd( aLogFil[Len(aLogFil)], "" )

				cTexto := STR0006 + FwGetCodFilial //"Empresa: ###"Filial: "

				oProcess:SetRegua2(nQtdConv)
				oProcess:IncRegua1(STR0005 + SM0->M0_CODIGO + " - " + STR0006 + FwGetCodFilial) //"Empresa: ###"Filial: "

				If cFilSRV <> xFilial("SRV") .or. cEmp <> SM0->M0_CODIGO
					aCodFol := {}
					RstaCodFol()

					// Assistente para criação de novas verbas
					If lTab01
						oProcess:IncRegua2(STR0039) //"Criação e Verbas"

						Begin Transaction
							fCriaVerbas(aCodFol,xFilial("SRV"))
							RecLock(cDbfLog,.T.)
							(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
							(cDbfLog)->FILIAL	:= FwGetCodFilial
							(cDbfLog)->DATAI	:= dDataBase
							(cDbfLog)->HORA		:= Time()
							(cDbfLog)->MENSAGEM	:= "Criação de Verbas concluído com sucesso."
							(cDbfLog)->PROCESSO	:= 01
							(cDbfLog)->(MsUnLock())
						End Transaction
					EndIf

					// Carrega as Verbas
					fp_CodFol( aCodFol , xFilial("SRV"), .F., .F., aLogErr)
					aLogErr := RemVerba(aLogErr) // Remove as verbas do E-Social

					// Atualiza o Log para não gravar as verbas desnecessárias
					IF !Empty(aLogErr)
						aAdd( aLogGFP , {})

						FOR nX := 1 TO LEN(aLogErr)
							aAdd( aLogGFP[1], aLogErr[nX])
						NEXT nX

						// Impede o processamento caso não possua alguma verba obrigatória.
						IF !EMPTY(aLogGFP)
							MsAguarde( { || fMakeLog( aLogGFP , {STR0999} , , NIL , , STR0998 ) } ,  STR0998 )
							Return
						ENDIF
					ENDIF
				EndIf

				//Cria os processos
				If lTab22 .And. cEmp <> SM0->M0_CODIGO .or. cFilRCJ <> xFilial("RCJ")
					oProcess:IncRegua2(STR0110) // "Cadastro de Processo"
					GpIniProc()
					cFilRCJ := xFilial("RCJ")
				EndIf

				If !Empty(aCodFol)
					Eval({|x| If(Empty(x[40,1]),aAdd(aVerbErr,"0040"),),If(Empty(x[41,1]),aAdd(aVerbErr,"0041"),),If(Empty(x[42,1]),aAdd(aVerbErr,"0042"),),if(Empty(x[72,1]),aAdd(aVerbErr,"0072"),),If(Empty(x[103,1]) .And. cPaisLoc <> "ARG",aAdd(aVerbErr,"0103"),)},aCodFol)

					If !Empty(aVerbErr)

						For nX := 1 to Len(aVerbErr)
							cVerbErr += aVerbErr[nX] + ", "
						Next nX

						cVerbErr := SubStr(cVerbErr,1,Len(cVerbErr)-2)

						MsgInfo(STR0007 + chr(10) + chr(13) + " " + STR0008 + chr(10)+chr(13) + cVerbErr ,STR0003) //"As verbas com os identificadores abaixo não foram encontradas. " ### "A carga dos tipos de ausência padrão não será executada"
						Return Nil
					Else
						cAnoMes := SuperGetMv("MV_FOLMES",,Substr( Dtos(dDatabase) , 1, 6))

						If cFilSRV <> xFilial("SRV") .or. cEmp <> SM0->M0_CODIGO
							cFilSRV := xFilial("SRV")
						Else
							If lTab01
								oProcess:IncRegua2(STR0039) //"Criação e Verbas"
							EndIf
						EndIf

						If Empty(aCodFol)
							Return()
						EndIf

						// Controle de Tipos de Ausência (RCM)
						If lTab03
							oProcess:IncRegua2(STR0041)
							fCargaRCM()

							// Grava tempo de execução no Log
							cIniTab := Time()
							dIniTab	:= MsDate()
							aAdd( aLogFil[Len(aLogFil)], STR0041 + "(RCM): " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						EndIf

						// Controle de Ausência (SR8)
						IF lTab07
							oProcess:IncRegua2(STR0041)
							fAusUpd()

							// Grava tempo de execução no Log
							cIniTab := Time()
							dIniTab	:= MsDate()
							aAdd( aLogFil[Len(aLogFil)], STR0041 + "(SR8): " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						ENDIF

						// Histórico de Movimentos (SRD)
						If lTab09
							oProcess:IncRegua2(STR0047)
							fConvSRD()

							// Grava tempo de execução no Log
							cIniTab := Time()
							dIniTab	:= MsDate()
							aAdd( aLogFil[Len(aLogFil)], STR0047 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						ENDIF

						// Manutenção de Tabelas
						IF lTab11
							oProcess:IncRegua2(STR0049)
							fRCCUpd("RCC", "RCC_FILIAL", "RCC_CODIGO")

							// Grava tempo de execução no Log
							cIniTab := Time()
							dIniTab	:= MsDate()
							aAdd( aLogFil[Len(aLogFil)], STR0049 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						ENDIF

						// Itens Férias e Rescisão
						IF lTab13
							ConvSRG() // Checkbox Exclui Movimento Aberto?

							// Grava tempo de execução no Log
							cIniTab := Time()
							dIniTab	:= MsDate()
							aAdd( aLogFil[Len(aLogFil)], STR0050 +", " + STR0051 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						ENDIF

						// Atualização de Mnemônicos
						IF lTab20
							oProcess:IncRegua2(STR0087)
							ConvRCA()

							// Grava tempo de execução no Log
							cIniTab := Time()
							dIniTab	:= MsDate()
							aAdd( aLogFil[Len(aLogFil)], STR0087 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						ENDIF

						// Atualização dos IDS dos Processos das seguintes tabelas abaixo
						IF lTab22
							aTable   := { "SRA", "RCF", "RCH", "RCG", "SR8", "SRD", "SRC", "SRH", "SRK", "RGB", "RCL", "RGA","RG1", "SRR", "SRG", "RCJ" }
							aColPref := { "RA", "RCF", "RCH", "RCG", "R8", "RD", "RC", "RH", "RK", "RGB", "RCL", "RGA", "RG1", "RR", "RG", "RCJ" }
							fProcUpd(aTable, aColPref)

							oProcess:IncRegua2(STR0110)

							// Grava tempo de execução no Log
							cIniTab := Time()
							dIniTab	:= MsDate()
							aAdd( aLogFil[Len(aLogFil)], STR0110 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						ENDIF

						// Atualização de Roteiros
						If lTab23
							// Atualização dos roteiros FOL e RES para FPB e RPB
							aTable   := { "RCF","RCH","SRR","SRG","RGB","SRC", "RG3","SRD","RG1","RG1" }
							aField   := { "RCF_ROTEIR","RCH_ROTEIR","RR_ROTEIR","RG_ROTEIR","RGB_ROTEIR","RC_ROTEIR", "RG3_ROTEIR","RD_ROTEIR","RG1_ROTEIR", "RG1_ROT" }
							aColPref := { "RCF","RCH","RR","RG","RGB","RC", "RG3","RD","RG1","RG1" }

							//Atualiza os Roteiros
							fRotUpd(aTable, aField, aColPref) // Tabelas, Campos, Prefixos

							// Label barra de Progresso
							oProcess:IncRegua2(STR0111)

							// Grava tempo de execução no Log
							cIniTab := Time()
							dIniTab	:= MsDate()
							aAdd( aLogFil[Len(aLogFil)], STR0111 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )

							// Atualização dos Tipos de Aumento
							fTpAumUpd({"SR3", "SR7","SX5"}, {"R3_TIPO","R7_TIPO","X5_CHAVE"} ,{"R3", "R7", "X5"}) // Tabelas, Campos, Prefixos
						ENDIF

						// Atualização de Períodos
						If lTab24
							oProcess:IncRegua2(STR0044)
							ConvPer()

							// Grava tempo de execução no Log
							cIniTab := Time()
							dIniTab	:= MsDate()
							aAdd( aLogFil[Len(aLogFil)], STR0044 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						EndIf


						// Atualização de Funcionários
						If lTab05
							Begin Transaction
								cIniTab := Time()
								dIniTab	:= MsDate()
								oProcess:IncRegua2( STR0043 )  //"Cadastro de Funcionários"
								ConvSRA()
								RecLock(cDbfLog,.T.)
								(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
								(cDbfLog)->FILIAL	:= FwGetCodFilial
								(cDbfLog)->DATAI	:= dDataBase
								(cDbfLog)->HORA		:= Time()
								(cDbfLog)->MENSAGEM	:= "Conversão do Cadastro de Funcionários Concluído com Sucesso."
								(cDbfLog)->PROCESSO	:= 05
								(cDbfLog)->(MsUnLock())
								aAdd( aLogFil[Len(aLogFil)], STR0043 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
							End Transaction
						EndIf

						MsOpenDbf( .T. , "TOPCONN" , cNameFile , cDbfFil , .T. , .F. , .F. , .F. )
						dbClearind()
						dbSetIndex( cNameFile+"1" )

						If (cDbfFil)->(DbSeek(SM0->M0_CODIGO + SM0->M0_CODFIL))
							RecLock(cDbfFil,.F.)
							(cDbfFil)->MARK := ""
							(cDbfFil)->(MsUnLock())
						EndIf
					EndIf
				EndIf

				cEmp := SM0->M0_CODIGO

				dbSelectArea("SX6")
				dbSetOrder(1)

				SM0->(dbSkip())
				nRecno := SM0->(Recno())

				aAdd( aLogFil[Len(aLogFil)], "" )
				aAdd( aLogFil[Len(aLogFil)], STR0056 + fCalcHrs( dIniFil , cIniFil , MsDate() , Time() ) )  //"Total Filial: "
			EndDo

			For nX := 1 to Len(aTitleFil)
				aAdd(aTitle,aTitleFil[nX])
				aAdd( aLogErr,{} )
				aAdd( aLogErr[Len(aLogErr)], "" )
				For nY := 1 to Len(aLogFil[nX])
					aAdd( aLogErr[Len(aLogErr)], aLogFil[nX,nY] )
				Next nY
			Next nX

			MsgInfo( STR0009 + fCalcHrs( dInicio , cInicio , MsDate() , Time() ) ) //"Duração da Conversão "

			If !Empty(aTitle)
				nModulo := 7 //Altera variavel publica para que no log seja exibido "Gestão de Pessoal"
				MsAguarde( { || fMakeLog( aLogErr , aTitle , NIL  , .T. , "GFPCONV" , NIL , NIL, NIL, NIL, .F. ) } ,  STR0010 )
			Endif

			ConOut("Conversão do Cadastro de Funcionários Concluído com Sucesso.")

			//Fecha empresa que não foi fechada anteriormente.
			RpcClearEnv()
		EndIf
	ENDIF
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvSra   ºAutor  ³Leandro Drumond     º Data ³  18/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conversão dos Funcionarios.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConvSra()
	Local cQuery  := ""
	Local nTot	  := 0
	Local nMinRec := 0
	Local nCont	  := 0
	Local nX	  := 0

	GpContReg(@nTot,@nMinRec,"SRA")

	Begin Sequence
		If nTot > 0
			If TcSrvType() == "AS/400"
				cRecno :=  IF( lExInAs400 , "RRN("+RetSqlName("SRA")+")", "R_E_C_N_O_" )
			Else
				cRecno := "R_E_C_N_O_"
			EndIf

			nCont := nMinRec + 1024

			For nx = 1 to nTot
				cQuery := " UPDATE " + RetSqlName( "SRA" ) + " SET RA_PROCES = ( CASE WHEN RA_CATFUNC IN ('A','P') AND RA_TIPOPGT = 'M' THEN '00003' "
				cQuery += 														     " WHEN RA_CATFUNC IN ('A','P') AND RA_TIPOPGT = 'S' THEN '00004' "
				cQuery += 															 " WHEN RA_TIPOPGT = 'S' THEN '00002' "
				cQuery += 															 " Else '00001' END ), "
				cQuery +=										  " RA_ADCINS = ( CASE WHEN RA_INSMIN > 0 THEN '2' "
				cQuery +=															 " WHEN RA_INSMED > 0 THEN '3' "
				cQuery +=															 " WHEN RA_INSMAX > 0 THEN '4' "
				cQuery +=															 " Else '1' END ), "
				cQuery +=										  " RA_INSMAX = ( CASE WHEN RA_INSMAX = 0 AND RA_INSMED >= 999 THEN RA_HRSMES "
				cQuery +=										                     " WHEN RA_INSMAX = 0 AND RA_INSMED > 0 THEN RA_INSMED "
				cQuery +=															 " WHEN RA_INSMAX = 0 AND RA_INSMIN >= 999 THEN RA_HRSMES "
				cQuery +=															 " WHEN RA_INSMAX = 0 AND RA_INSMIN > 0 THEN RA_INSMIN "
				cQuery +=															 " WHEN RA_INSMAX >= 999 THEN RA_HRSMES "
				cQuery +=															 " Else RA_INSMAX END ), "
				cQuery +=										  " RA_ADCPERI = ( CASE WHEN RA_PERICUL > 0 THEN '2' "
				cQuery +=															 " Else '1' END ), "
				cQuery +=										  " RA_PERICUL = ( CASE WHEN RA_PERICUL >= 999 THEN RA_HRSMES "
				cQuery +=															 " Else RA_PERICUL END ), "
				cQuery += 										  " RA_REGIME  = ( CASE WHEN RA_REGIME IS NULL OR RA_REGIME = '' THEN '2' Else RA_REGIME END ), "
				cQuery += 										  " RA_HRSDIA  = Round(RA_HRSMES / 30 , 4), "
				cQuery +=										  " RA_AFASFGT = (CASE
				cQuery +=															 "  WHEN RA_AFASFGT = '1 ' THEN 'U3' "
				cQuery +=															 "  WHEN RA_AFASFGT = '2 ' THEN 'I2' "
				cQuery +=															 "  WHEN RA_AFASFGT = '3 ' THEN 'I3' "
				cQuery +=															 "  WHEN RA_AFASFGT = '4 ' THEN 'I4' "
				cQuery +=															 "  WHEN RA_AFASFGT = '5 ' THEN 'N1' "
				cQuery +=															 "  WHEN RA_AFASFGT = '6 ' THEN 'Q5' "
				cQuery +=															 "  WHEN RA_AFASFGT = '7 ' THEN 'Q6' "
				cQuery +=															 "  WHEN RA_AFASFGT = '9 ' THEN 'S3' "
				cQuery +=															 "  WHEN RA_AFASFGT = 'B ' THEN 'Q4' "
				cQuery +=															 "  WHEN RA_AFASFGT = 'I ' THEN 'I1' "
				cQuery +=															 "  WHEN RA_AFASFGT = 'N ' THEN 'N2' "
				cQuery +=															 "  WHEN RA_AFASFGT = 'O ' THEN 'O1' "
				cQuery +=															 "  WHEN RA_AFASFGT = 'P ' THEN 'P1' "
				cQuery +=															 "  WHEN RA_AFASFGT = 'Q ' THEN 'Q1' "
				cQuery +=															 "  WHEN RA_AFASFGT = 'S ' THEN 'S2' "
				cQuery +=															 "  WHEN RA_AFASFGT = 'U ' THEN 'U1' "
				cQuery +=															 "  ELSE RA_AFASFGT "
				cQuery +=															 " END) "
				cQuery += " WHERE " + RetSqlName( "SRA" ) + ".D_E_L_E_T_ = ' '
				cQuery += " AND RA_FILIAL = '" + xFilial("SRA") + "' AND "
				cQuery += cRecno + ">=" + AllTrim(Str(nMinRec)) + " AND " + cRecno + "<=" + AllTrim(Str(nCont)) + " "

				nRet := TCSQLEXEC(cQuery)

				If nRet != 0
					UserException( TCSqlError() )
					Break
				EndIf

				nMinRec := nCont
				nCont   := nMinRec + 1024
			Next nx
		EndIf
	End Sequence
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GpContReg  |Autor  ³ Leandro Drumond	    ³ Data ³ 22/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Conta quantidade de registros na tabela.			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GpContReg(nTot,nMinRec,cAlias)
	Local nMaxRec	:= 0
	Local cPrefixo	:= ( PrefixoCpo( cAlias ) )
	Local cWhere 	:= " WHERE " + cPrefixo + "_FILIAL = '" + xFilial( cAlias ) + "' AND D_E_L_E_T_ = ' '"

	MsMinMaxRec( cAlias , @nMinRec , @nMaxRec,,cWhere  )

	If nMaxrec == nMinRec .and. nMaxRec # 0
		nTot := ( nMaxrec - nMinRec ) + 1
	Else
		nTot := ( nMaxrec - nMinRec )
	EndIf

	If nTot # 0
		// controle de transacao para processar de 1024 em 1024 registros
		nTot  := Ceiling(nTot / 1024) //Arredonda para cima em caso de numero quebrado
		If nTot < 1
			nTot := 1
		Else
			If (Int(nTot) - nTot) > 0
				nTot++
			EndIf
		EndIf
	EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GpCntTab      ºAutor ³Leandro Drumond  º Data ³  22/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Conta os registros selecionados para utilizacao na regua    º±±
±±º          ³de processamento.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GpCntTab()
	Local nRet	:= 0

	If lTab01
		nRet++
	EndIf
	If lTab02
		nRet++
	EndIf
	If lTab03
		nRet++
	EndIf
	If lTab04
		nRet++
	EndIf
	If lTab05
		nRet++
	EndIf
	If lTab06
		nRet++
	EndIf
	If lTab07
		nRet++
	EndIf
	If lTab08
		nRet++
	EndIf
	If lTab09
		nRet++
	EndIf
	If lTab10
		nRet++
	EndIf
	If lTab11
		nRet++
	EndIf
	If lTab12
		nRet++
	EndIf
	If lTab13
		nRet++
	EndIf
	If lTab14
		nRet++
	EndIf
	If lTab15
		nRet++
	EndIf
	If lTab16
		nRet++
	EndIf
	If lTab17
		nRet++
	EndIf
	If lTab18
		nRet++
	EndIf
	If lTab19
		nRet++
	EndIf
	If lTab20
		nRet++
	EndIf
	If lTab21
		nRet++
	EndIf
Return nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetFilConv ºAutor³Leandro Drumond            º Data ³ 27/05/14      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Monta tela para seleção das filiais.		                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ GetFilConv()                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPECONV                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetFilConv()
	Local aRetcoords	:= {}
	Local aColumns		:= {}
	Local bMarkAll 		:= { || RhMkAll( cDbfFil , .F., .T. , 'MARK', @cMarkAll ,cMark ) }
	Local cMarkAll		:= cMark
	Local oPanel 		:= oWizard:oMPanel[oWizard:nPanel]
	Local nX			:= 0

	If oMsSelect == Nil
		aAdd( aColumns, { "MARK"		,,''						,"@!"})
		aAdd( aColumns, { "EMPRESA"		,,"Empresa" 		 		,"@!"})
		aAdd( aColumns, { "FILIAL"		,,"Filial"					,"@!"})
		aAdd( aColumns, { "NOME"		,,"Nome"					,"@!"})

		(cDbfFil)->(DbGoTop())

		oMsSelect := MsSelect():New(;
										cDbfFil				,;	//Alias	do Arquivo de Filtro
										"MARK"				,;	//Campo para controle do mark
										NIL					,;	//Condicao para o Mark
										aColumns			,;	//Array com os Campos para o Browse
										NIL					,;	//
										cMark				,;	//Conteudo a Ser Gravado no campo de controle do Mark
										{0,0,235 ,400}		,;	//Coordenadas do Objeto
										NIL					,;  //
										NIL					,;	//
										oPanel				 ;	//Objeto Dialog
									)
		oMsSelect:oBrowse:lAllMark := .T.
		oMsSelect:oBrowse:bAllMark := bMarkAll
	EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RhMkAll     ³ Autor ³ Leandro Drumond     ³ Data ³ 02/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todos os elementos do browse                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPECONV                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function RhMkAll( cAlias, lInverte, lTodos, cCpoCtrl, cMark, cMarkAux )
	Local nRecno		:= (cAlias)->(Recno())

	(cAlias)->( dbGotop() )

	While (cAlias)->( !Eof() )
		RhMkMrk( cAlias , lInverte , lTodos, cCpoCtrl, cMark, {})
		(cAlias)->( dbSkip() )
	End While

	(cAlias)->( MsGoto( nRecno ) )

	If cMark == cMarkAux
		cMark := ""
	Else
		cMark := cMarkAux
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fGetParFil ºAutor³Leandro Drumond            º Data ³ 27/05/14      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Obtem filiais para conversao retirando as que já foram convertidas. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ fGetParFil()                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPECONV                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetParFil()
	Local aArea			:= GetArea()
	Local aRet			:= {}

	DbSelectArea(cDbfFil)
	dbGotop()

	While (cDbfFil)->(!Eof())
		If Empty((cDbfFil)->MARK)
			aAdd( aRet , {(cDbfFil)->EMPRESA , (cDbfFil)->FILIAL , .F. } )
		Else
			aAdd( aRet , {(cDbfFil)->EMPRESA , (cDbfFil)->FILIAL , .T. } )
		EndIf

		(cDbfFil)->(DbSkip())
	EndDo

	RestArea(aArea)
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetTabConv ºAutor³Leandro Drumond            º Data ³ 22/05/14      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Monta tela para seleção das tabelas para conversao.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ GetTabConv()                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPECONV                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetTabConv()
	Local aRetcoords:= {}
	Local oPanel	:= oWizard:oMPanel[oWizard:nPanel]
	Local oPanelTab := TPanelCss():New(01,04,nil,oPanel,nil,nil,nil,nil,nil,195,210,nil,nil)
	Local oPanelRod := TPanelCss():New(212,04,nil,oPanel,nil,nil,nil,nil,nil,391,22,nil,nil)
	Local oPanelPar := TPanelCss():New(01,200,nil,oPanel,nil,nil,nil,nil,nil,195,210,nil,nil)
	Local lTabSel	:= .T.
	Local oCheck2	:= Nil
	Local oCheck3	:= Nil
	Local oCheck5	:= Nil
	Local dSRDDe 	:= STOD("")
	Local dSRDAte 	:= STOD("")

	Private oCheck2
	Private oCheck3

	aRetcoords := RetCoords(2,20,60,12,2,,,,{0,0,oPanelTab:oWnd:nTop*0.92,oPanelTab:oWnd:nLeft*0.88})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Marca os parametros que serao utilizados	                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	/*Painel Esquerda*/
	TcheckBox():New(aRetcoords[01][1], aRetcoords[01][2], STR0058, {|| lTab01 }, oPanelTab, 300,10,,{|| lTab01:=!lTab01 },,,,,,.T.,,,)  // Assistente para criação de novas verbas
	TcheckBox():New(aRetcoords[03][1], aRetcoords[03][2], STR0110, {|| lTab22 }, oPanelTab, 300,10,,{|| lTab22:=!lTab22 },,,,,,.T.,,,)  // Cadastro de Processo
	TcheckBox():New(aRetcoords[05][1], aRetcoords[05][2], STR0043, {|| lTab05 }, oPanelTab, 300,10,,{|| lTab05:=!lTab05 },,,,,,.T.,,,)  // Cadastro de Funcionário
	TcheckBox():New(aRetcoords[07][1], aRetcoords[07][2], STR0044 ,{|| lTab24 }, oPanelTab, 300,10,,{|| lTab24:=!lTab24 },,,,,,.T.,,,)  // Cadastro de Períodos
	TcheckBox():New(aRetcoords[09][1], aRetcoords[09][2], STR0111, {|| lTab23 }, oPanelTab, 300,10,,{|| lTab23:=!lTab23 },,,,,,.T.,,,)  // Cadastro de Roteiro
	TcheckBox():New(aRetcoords[11][1], aRetcoords[11][2], STR0041 ,{|| lTab03 }, oPanelTab, 300,10,,{|| lTab03:=!lTab03 },,,,,,.T.,,,)  // Cadastro Tipo de Ausências
	TcheckBox():New(aRetcoords[13][1], aRetcoords[13][2], STR0045 ,{|| lTab07 }, oPanelTab, 300,10,,{|| lTab07:=!lTab07 },,,,,,.T.,,,)  // Cadastro de Ausências (Afastamento)
	TcheckBox():New(aRetcoords[15][1], aRetcoords[15][2], STR0087 ,{|| lTab20 }, oPanelTab, 300,10,,{|| lTab20:=!lTab20 },,,,,,.T.,,,)  // Cadastro de Mnemônicos
	TcheckBox():New(aRetcoords[17][1], aRetcoords[17][2], STR0049 ,{|| lTab11 }, oPanelTab, 300,10,,{|| lTab11:=!lTab11 },,,,,,.T.,,,)  // Manutenção de Tabelas

	/*Painel Direita*/
	TcheckBox():New(005,008,STR0051,{|| lTab13  },oPanelPar, 50,10,,{|| lTab13:=!lTab13, oWizard:RefreshButtons(), lTab13 },,{|| ((If(!lTab13,(lPar04:=.F.),)),.T.)},,,,.T.,,,) //Rescisao
	TBitmap():New(006,110,30,30,,"UPDINFORMATION17",.T.,oPanelPar, {|| fMsgInfCnv(.T.,STR0043,STR0051)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	TcheckBox():New(015,015,STR0062,{|| lPar04  },oPanelPar, 100,10,,{|| lPar04:=!lPar04 },,,,,,.T.,,,{||lTab13}) //"Exclui Movimento Aberto?"

	oCheck5 := TcheckBox():New(035,008,STR0047 + " (SRD)",{|| lTab09 },oPanelPar, 100,10,,{|| lTab09:=!lTab09, oWizard:RefreshButtons(), lTab09 },,,,,,.T.,,,)
	TBitmap():New(035, 110,30,30,,"UPDINFORMATION17",.T.,oPanelPar, {|| fMsgInfCnv(.F.,STR0044,STR0047) },NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	TSay():New( 050 ,015,{||'Período De'},oPanelPar,,,,,,.T.,,,200,10)
	TGet():New( 060, 015, { | u | If( PCount() == 0, dSRDDe, dSRDDe := u ) },oPanelPar,060, 010, "@D",{|| cDataDe := MESANO(dSRDDe)}, 0, 16777215,,.F.,,.T.,,.F.,{|| lTab09},.F.,.F.,,.F.,.F. ,,"dSRDDe",,,,.T.  )

	TSay():New( 050 ,080,{||'Período Até'},oPanelPar,,,,,,.T.,,,100,10)
	TGet():New( 060, 080, { | u | If( PCount() == 0, dSRDAte, dSRDAte := u ) },oPanelPar,060, 010, "@D",{|| If( Empty(dSRDDe).and.Empty(dSRDAte)  .OR.  !Empty(dSRDDe).and.!Empty(dSRDAte) .AND. dSRDAte >= dSRDDe,(cDataAte := MESANO(dSRDAte), .T.),(MsgInfo("Dados inválidos!" + CRLF + "Mês e ano final não podem ser menores que Mês e ano inicial. Para que todos os registros sejam convertidos, deixe todos os campos em branco."),.F.))}, 0, 16777215,,.F.,,.T.,,.F.,{|| lTab09},.F.,.F.,,.F.,.F. ,,"dSRDAte",,,,.T.  )

	/*RODAPE*/
	TcheckBox():New(005, 75,STR0089	,{|| lTabSel },oPanelRod, 100,10,,{|| fInverte(@lTabSel)},,,,,,.T.,,,)
Return


Static Function fInverte(lRet)
	lTab01 := !lTab01
	lTab02 := !lTab02
	lTab03 := !lTab03
	lTab04 := !lTab04
	lTab05 := !lTab05
	lTab06 := !lTab06
	lTab07 := !lTab07
	lTab08 := !lTab08
	lTab09 := !lTab09
	lTab10 := !lTab10
	lTab11 := !lTab11
	lTab12 := !lTab12
	lTab13 := !lTab13
	lTab14 := !lTab14
	lTab15 := !lTab15
	lTab16 := !lTab16
	lTab17 := !lTab17
	lTab18 := !lTab18
	lTab19 := !lTab19
	lTab20 := !lTab20
	lTab21 := !lTab21
	lTab22 := !lTab22
	lTab23 := !lTab23
	lTab24 := !lTab24
	lRet   := !lRet

	oWizard:RefreshButtons()
Return !lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvSRG    |Autor  ³ Leandro Drumond	    ³ Data ³ 30/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao das rescisoes (SRG e SRR).		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvSRG()
	Local aPerAtual	:= {}
	Local cPerAberto:= ""
	Local cProcPer	:= "XXXXXX"
	Local cDemSRG   := ""
	Local cDataItem := ""

	If lPar04 //Exclui movimento aberto
		If Empty(cAnoMes)
			cAnoMes := Substr( Dtos(dDatabase) , 1, 6)
		EndIf

		dbSelectArea("SRG")
		SRG->(dbSetOrder(1))
		SRG->(dbGotop())

		// Verifica Processo
		If cProcPer <> SRG->RG_PROCES
			fGetPerAtual(@aPerAtual, NIL, SRG->RG_PROCES, 'RES')
			cProcPer := SRG->RG_PROCES
		EndIf

		// Verifica período aberto
		If !Empty(aPerAtual)
			cPerAberto := aPerAtual[1,1]
		EndIf

		// Deleta linhas do Cabeçalho de Rescisão que possuem período aberto
		IF SRG->(dbSeek(FwxFilial('SRG')))
			WHILE !SRG->(EOF())
				cDemSRG := Substr(Dtos(SRG->RG_DATADEM), 1, 6)

				If cDemSRG >= cPerAberto
					RecLock("SRG",.F.)
						SRG->(DbDelete())
					SRG->(MsUnLock())
				EndIf
				SRG->(DBSKIP())
			ENDDO
		ENDIF

		// Deleta linhas de Itens de Rescisão que possuem período aberto
		dbSelectArea("SRR")
		SRR->(dbSetOrder(1))
		SRR->(dbGotop())

		IF SRR->(dbSeek(FwxFilial('SRR')))
			WHILE !SRR->(EOF())
				cDataItem := Substr(Dtos(SRR->RR_DATA), 1, 6)

				If (cDataItem >= cPerAberto) .AND. (SRR->RR_TIPO3 == "R") .AND. (SRR->RR_ROTEIR == "RPB")
					RecLock("SRR",.F.)
						SRR->(DbDelete())
					SRR->(MsUnLock())
				EndIf
				SRR->(DBSKIP())
			ENDDO
		ENDIF
	EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GpVldConv  ºAutor³Leandro Drumond            º Data ³ 22/05/14      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Valida se conversão podera ser feita.				               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ GpVldConv()                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParâmetros³                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPECONV                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GpVldConv()
	Local lRet 		:= .T.
	Local cEmpProc 	:= ""
	Local cFilProc 	:= ""
	Local cDtProc	:= ""
	Local aMsgPend	:= {}
	Local nX		:= 0
	Local cArqLogIdx := ""

	MsOpenDbf( .T. , "TOPCONN" , cNameLog , cDbfLog , .T. , .F. , .F. , .F. )
	dbClearind()
	dbSetIndex( cNameLog+"1" )

	For nX := 1 to Len(aParFil)

		if !(aParFil[nX][3])
			Loop
		endIf

		cEmpProc 	:= aParFil[nX][1]
		cFilProc 	:= aParFil[nX][2]

		if lTab03
			if !empty(cDtProc := fHistProc(cEmpProc,cFilProc,3)) .AND. RCM->(!EOF())
				aAdd(aMsgPend,STR0091 + STR0041 + STR0092 + cDtProc + STR0094 + RetSqlName("RCM")) //O processo Tipos de Ausência já foi executado em: 29/11/17, para continuar é necessário excluir a tabela RCMT10
			endIf
		endIf

		if lTab06
			if !empty(cDtProc := fHistProc(cEmpProc,cFilProc,6))
				aAdd(aMsgPend,STR0091 + STR0044 + STR0092 + cDtProc + STR0093 + RetSqlName("RCF") + " e " + RetSqlName("RCH") + STR0096)
			endIf
			if !lTab09 .AND. empty(fHistProc(cEmpProc,cFilProc,9))
				aAdd(aMsgPend,STR0091 + STR0044 + STR0095 + STR0047)
			endIf
		endIf

		if lTab07 .AND. ((!lTab03 .AND. empty(fHistProc(cEmpProc,cFilProc,3))) .OR. (!lTab06 .AND. empty(fHistProc(cEmpProc,cFilProc,6))) .OR. (!lTab12 .AND. empty(fHistProc(cEmpProc,cFilProc,12))))
			aAdd(aMsgPend,STR0091 + STR0045 + STR0095 + STR0041 +"," + STR0044 + " e " + STR0050)
		endIf

		if lTab08
			if !empty(cDtProc := fHistProc(cEmpProc,cFilProc,8))
				aAdd(aMsgPend,STR0091 + STR0046 + STR0092 + cDtProc + STR0093 + RetSqlName("SRF") + STR0096)
			endIf
			if (!lTab03 .AND. empty(fHistProc(cEmpProc,cFilProc,3))) .OR. (!lTab06 .AND. empty(fHistProc(cEmpProc,cFilProc,6))) .OR. (!lTab12 .AND. empty(fHistProc(cEmpProc,cFilProc,12)))
				aAdd(aMsgPend,STR0091 + STR0046 + STR0095 + STR0041 +"," + STR0044 + " e " + STR0050)
			endIf
		endIf

		if lTab09
			if!empty(cDtProc := fHistProc(cEmpProc,cFilProc,9))
				aAdd(aMsgPend, STR0091 + STR0047 + STR0092 + cDtProc + STR0093 + RetSqlName("SRD") + STR0096)
			endIf
			if (!lTab06 .AND. empty(fHistProc(cEmpProc,cFilProc,6)))
				aAdd(aMsgPend,STR0091 + STR0047 + STR0095 + STR0044)
			endIf
		endIf

		if lTab10 .AND. (!lTab05 .AND. empty(fHistProc(cEmpProc,cFilProc,5)))
			aAdd(aMsgPend,STR0091 + STR0048 + STR0095 + STR0043)
		endIf

		if lTab12 .AND. !empty(cDtProc := fHistProc(cEmpProc,cFilProc,12))
			aAdd(aMsgPend,STR0091 + STR0050 + STR0092 + cDtProc + STR0093 + RetSqlName("SRH") + " e " + RetSqlName("SRR") + STR0096)
		endIf

		if lTab13 .AND. (!lTab05 .AND. empty(fHistProc(cEmpProc,cFilProc,5)))
			aAdd(aMsgPend,STR0091 + STR0051 + STR0095 + STR0043)
		endIf

		if lTab14 .AND. (!lTab05 .AND. empty(fHistProc(cEmpProc,cFilProc,5)))
			aAdd(aMsgPend,STR0091 + STR0052 + STR0095 + STR0043)
		endIf

		if lTab15 .AND. (!lTab05 .AND. empty(fHistProc(cEmpProc,cFilProc,5)))
			aAdd(aMsgPend,STR0091 + STR0053 + STR0095 + STR0043)
		endIf

		if lTab16 .AND. (!lTab05 .AND. empty(fHistProc(cEmpProc,cFilProc,5)))
			aAdd(aMsgPend,STR0091 + STR0054 + STR0095 + STR0043)
		endIf

		if lTab17 .AND. ((!lTab05 .AND. empty(fHistProc(cEmpProc,cFilProc,5))) .OR. (!lTab11 .AND. empty(fHistProc(cEmpProc,cFilProc,11))))
			aAdd(aMsgPend,STR0091 + STR0055 + STR0095 + STR0043 + " e " + STR0049)
		endIf

		if lTab23 .AND. (!lTab05 .AND. empty(fHistProc(cEmpProc,cFilProc,5)))
			aAdd(aMsgPend,STR0091 + "Cadastro de Roteiro" + STR0095 + STR0043)
		endIf
		if lTab24 .And. (!lTab05 .AND. empty(fHistProc(cEmpProc,cFilProc,5)))
			aAdd(aMsgPend,STR0091 + STR0044 + STR0095 + STR0043)
		endIf

	next nX

	if LEN(aMsgPend) > 0
		ShowLog(STR0003,aMsgPend)
		lRet := MSGYESNO(STR0097,STR0003)
	endIf
Return lRet


/*/{Protheus.doc} fMsgInfCnv()
- Apresenta mensagem informativa sobre o processo
@author: Paulo.Inzonha
@since:  23/11/2017
/*/
Static Function fMsgInfCnv(lReproc, cRotAnt,cTitulo )
	local cTexto := ""

	cTexto := STR0104 + iif(lReproc, "Sim", "Não") + chr(13) + chr(10) //"Reprocessa: "
	cTexto += STR0105 + cRotAnt //"Depende da execução dos processos : "
	MSGINFO(cTexto , cTitulo )
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fCalcHrs    ³ Autor ³ Leandro Drumond     ³ Data ³ 04/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula a diferenca de HH:MM:SS entre duas data+hora       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPECONV                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fCalcHrs( dDt1 , cHr1 , dDt2 , cHr2 )
	Local cRet 		:= ""
	Local nValAux	:= 0
	Local nVal1		:= 0
	Local nVal2		:= 0

	nValAux := Val(DtoS(dDt2)) - Val(DtoS(dDt1))

	If nValAux > 0
		nVal1 := 86400 - TimeToSecs( cHr1 )
		nValAux--
		If nValAux > 0
			nVal2 := ( (nValAux+1)* 86400 ) - ( 86400 - TimeToSecs( cHr2 ) )
		Else
			nVal2 := TimeToSecs( cHr2 )
		EndIf
		nValAux := nVal1 + nVal2
	Else
		nValAux := TimeToSecs( cHr2 ) - TimeToSecs( cHr1 )
	EndIf

	cRet := SecsToTime( nValAux )
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fProcUpd
Realiza atualização de Rescisão, Itens e IDs de Processos.
@author  oliveira.hugo
@since   04/01/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fProcUpd(aTable, aColPref)
	Local nLinha := 1

	Begin Sequence
		For nLinha := 1 to LEN(aTable)

			IF aTable[nLinha] == "RCJ"
				cQuery := " UPDATE " + RetSqlName(aTable[nLinha]) + " SET " + aColPref[nLinha] + "_CODIGO = '50000', " + aColPref[nLinha] + "_MODULO = 'GFP'"
				cQuery += " WHERE " + RetSqlName(aTable[nLinha]) + ".D_E_L_E_T_ = ' ' AND " + aColPref[nLinha] + "_FILIAL = '" + xFilial(aTable[nLinha]) + "'"
				cQuery += " AND " + aColPref[nLinha] + "_CODIGO = '00001'"

			ELSEIF aTable[nLinha] $ "RCF|RCG|RCH"
				cQuery := " UPDATE " + RetSqlName(aTable[nLinha]) + " SET " + aColPref[nLinha] + "_PROCES = '50000', " + aColPref[nLinha] + "_MODULO = 'GFP'"
				cQuery += " WHERE " + RetSqlName(aTable[nLinha]) + ".D_E_L_E_T_ = ' ' AND " + aColPref[nLinha] + "_FILIAL = '" + xFilial(aTable[nLinha]) + "'"

			ELSE
				cQuery := " UPDATE " + RetSqlName(aTable[nLinha]) + " SET " + aColPref[nLinha] + "_PROCES = '50000'"
				cQuery += " WHERE " + RetSqlName(aTable[nLinha]) + ".D_E_L_E_T_ = ' ' AND " + aColPref[nLinha] + "_FILIAL = '" + xFilial(aTable[nLinha]) + "'"
			ENDIF

			If TCSQLEXEC(cQuery) != 0
				UserException(TCSqlError())
				Conout("Erro ao Executar comando SQL. Query: " + cQuery)
				Break
			EndIf

		Next nLinha
	End Sequence
return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvRCA    |Autor  ³ Leandro Drumond	    ³ Data ³ 02/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao do cadastro de mnemonicos.		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvRCA()
	Local aArea		:= GetArea()
	Local aDePara	:= {}
	Local cNewCod	:= ""
	Local lMneUsu	:= .F.
	Local nRecRCA	:= 0
	Local nX		:= 0
	Local cMnemon   := ""

	DbSelectArea("RCA")
	DbSetOrder(1) // Índice: RCA_FILIAL + RCA_MNEMON
	DbSeek(xFilial("RCA"))

	While RCA->(!Eof() .and. RCA_FILIAL == xFilial("RCA"))
		cNewCod := ""

		cMnemon := AllTrim(UPPER(RCA->RCA_MNEMON))

		If cMnemon == "M_PERCAUTO"
			cNewCod := "P_PERCAUTO"
		ElseIf cMnemon == "CAVPROPPDEM"
			cNewCod := "P_AVPROPDE"
		ElseIf cMnemon == "NANOAVIPRO"
			cNewCod := "P_ANOAVPRO"
		ElseIf cMnemon == "CCAVISTRA"
			cNewCod := "P_CCAVITRA"
		ElseIf cMnemon == "CCODPGIND"
			cNewCod := "P_CODPGIND"
		ElseIf cMnemon == "CDESCMEDAV"
			cNewCod := "P_DESCMEDA"
		ElseIf cMnemon == "CLIMAUXE15"
			cNewCod := "P_LIAUXE15"
		ElseIf cMnemon == "LMESATU"
			cNewCod := "P_LMESATU"
		ElseIf cMnemon == "NDRECALS"
			cNewCod := "P_NDRECALS"
		ElseIf cMnemon == "NTOTDIAS"
			cNewCod := "P_NTOTDIAS"
		ElseIf cMnemon == "CPAGINDFD"
			cNewCod := "P_PAGINDFD"
		ElseIf cMnemon == "CPAGRECES"
			cNewCod := "P_PAGRECES"
		ElseIf cMnemon == "NPERBCIR1"
			cNewCod := "P_PERBCIR1"
		ElseIf cMnemon == "NPERBCIR2"
			cNewCod := "P_PERBCIR2"
		ElseIf cMnemon == "LPGSALFEV"
			cNewCod := "P_PGSALFEV"
		ElseIf cMnemon == "CPIDEM1SM"
			cNewCod := "P_PIDEM1SM"
		ElseIf cMnemon == "CPIDEM2SM"
			cNewCod := "P_PIDEM2SM"
		ElseIf cMnemon == "LPROPCOMS"
			cNewCod := "P_PROPCOMS"
		ElseIf cMnemon == "LPROPCONTR"
			cNewCod := "P_PROPCONT"
		ElseIf cMnemon == "NSESTSENAT"
			cNewCod := "P_SESTSENA"
		ElseIf cMnemon == "LSOMAINC"
			cNewCod := "P_SOMAINC"
		ElseIf cMnemon == "CTRANSPAD"
			cNewCod := "P_TRANSPAD"
		ElseIf cMnemon == "CTRANSPAP"
			cNewCod := "P_TRANSPAP"
		ElseIf (cMnemon == "NVLLIMDIRF") .OR. (cMnemon == "P_VLIMDIRF")
			cNewCod := "P_VLLIMDIRF"
		ElseIf cMnemon == "NVLLIMOUT"
			cNewCod := "P_VLLIMOUT"
		ElseIf SubStr(cMnemon,1,2) == "M_"
			cNewCod := "P_" + SubStr(cMnemon,3,8)
			lMneUsu := .T.
		EndIf

		If !Empty(cNewCod)
			nRecRCA := RCA->(Recno())
			If !DbSeek(xFilial("RCA")+cNewCod)
				RCA->(DbGoTo(nRecRCA))

				aAdd( aDePara , { cMnemon , cNewCod } )

				RecLock("RCA",.F.)
				RCA->RCA_MNEMON := cNewCod
				RCA->(MsUnLock())
			Else
				RCA->(DbGoTo(nRecRCA))
			EndIf
		EndIf

		RCA->(DbSkip())
	EndDo

	If !Empty(aDePara)
		aAdd(aTitle, "Os seguintes mnemonicos foram alteradas durante a conversao:" ) //"As seguintes formulas foram alteradas durante a conversao:"
		aAdd( aLogErr,{} )

		aAdd( aLogErr[Len(aLogErr)], "" )
		aAdd( aLogErr[Len(aLogErr)], Padr("Filial", 15) + Padr("Mnemonico Antigo",15 ) + "Mnemonico Novo" ) //"Filial" ####Fórmula Antiga###Fórmula Nova##
		For nX := 1 to Len(aDePara)
			aAdd( aLogErr[Len(aLogErr)], Padr(xFilial("RCA"),15) + Padr(aDePara[nX,01],15) + aDePara[nX,02] )
		Next nX

		If lMneUsu
			aAdd( aLogErr[Len(aLogErr)], "" )
			aAdd( aLogErr[Len(aLogErr)], "Mnemonicos de usuário foram alterados durante a conversão. Será necessário rever as customizações." )
		EndIf
	EndIf

	RestArea(aArea)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} function fRCCUpd
Realiza atualização na Manutenção de Tabelas
@author  oliveira.hugo
@since   04/01/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fRCCUpd(cTable, cFilField, cProcField)
	dbSelectArea("RCC")
	RCC->(DBSETORDER(1))

	IF RCC->(dbSeek(FwxFilial('RCC') + 'S101')) // Procura o registro pesquisando por Filial e Codigo
		WHILE !RCC->(EOF())
			RCC->(RecLock("RCC", .F.))
				RCC->RCC_CONTEU := StrTran(RCC->RCC_CONTEU, "GPEA241", "GPEA240")
			RCC->(MsUnlock())
			RCC->(DBSKIP())
		ENDDO
	ENDIF
return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} function fRCCUpd
Realiza a troca de nomenclatura dos Tipos de Aumento do Vida Funcional.
@author  oliveira.hugo
@since   30/01/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fTpAumUpd(aTable, aField, aColPref)
	Local nLinha := 1

	Begin Sequence
		For nLinha := 1 to LEN(aTable)
			// Deleta os registros que possuem valor antigo no dicionário SX5
			IF aTable[nLinha] == "SX5"
				cQuery := " DELETE " + RetSqlName(aTable[nLinha])
				cQuery += " WHERE " + RetSqlName(aTable[nLinha]) + ".D_E_L_E_T_ = ' ' AND " + aColPref[nLinha] + "_FILIAL = '" + xFilial(aTable[nLinha]) + "'"
				cQuery += " AND " + aColPref[nLinha] + "_TABELA = '41'"
				cQuery += " AND " + aField[nLinha] + " IN ('004','005','016')"

			// Atualiza os Tipos de Aumento das tabelas SR3 e SR7
			ELSE
				cQuery := " UPDATE " + RetSqlName(aTable[nLinha]) + " SET " + aField[nLinha] + " = (CASE WHEN " + aField[nLinha] + " = '004' THEN 'NOM' "
				cQuery +=														                        " WHEN " + aField[nLinha] + " = '005' THEN 'EXO' "
				cQuery +=														                        " WHEN " + aField[nLinha] + " = '016' THEN 'APO' "
				cQuery +=														      			   		" ELSE " + aField[nLinha] + " END)"
				cQuery += " WHERE " + RetSqlName(aTable[nLinha]) + ".D_E_L_E_T_ = ' ' AND " + aColPref[nLinha] + "_FILIAL = '" + xFilial(aTable[nLinha]) + "'"
			ENDIF

			If TCSQLEXEC(cQuery) != 0
				UserException( TCSqlError() )
				Conout("Erro ao Executar comando SQL. Query: " + cQuery)
				Break
			EndIf
		Next nLinha
	End Sequence
RETURN NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} function fConvSRD
Converte dados do Histórico de Movimentos (SRD)
@author  oliveira.hugo
@since   06/01/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fConvSRD()
	Local cQuery := ""

	Begin Sequence
		cQuery := " SELECT " + RetSqlName("RCH") + ".RCH_NUMPAG AS NUMPAG, " + RetSqlName("SRD") + ".R_E_C_N_O_ AS RECNO"
		cQuery += " FROM " + RetSqlName("SRD") + " INNER JOIN RCH010 ON ( "
		cQuery += RetSqlName("RCH") + ".RCH_FILIAL = '  ' AND " + RetSqlName("SRD") + ".RD_PERIODO = " + RetSqlName("RCH") + ".RCH_PER AND "
		cQuery += RetSqlName("SRD") + ".RD_PROCES = " + RetSqlName("RCH") + ".RCH_PROCES AND " + RetSqlName("SRD") + ".RD_ROTEIR =  "
		cQuery += RetSqlName("RCH") + ".RCH_ROTEIR AND " + RetSqlName("RCH") + ".D_E_L_E_T_ = ' ') "
		cQuery += "WHERE " + RetSqlName("SRD") + ".D_E_L_E_T_ = ' ' AND " + RetSqlName("SRD") + ".RD_FILIAL = '01' AND " + RetSqlName("SRD") + ".RD_SEMANA = '  '"

		If !Empty(cDataDe) .and. !Empty(cDataAte)
			cQuery += " AND " + RetSqlName("SRD") + ".RD_DATARQ BETWEEN '" + cDataDe + "' AND '"	+ cDataAte + "'"
		EndIf

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cQuery)),"RDSEMANAS",.f.,.t.)
		RDSEMANAS->(DbGoTop())

		WHILE RDSEMANAS->( !Eof() )
			cQuery := " UPDATE " + RetSqlName("SRD") + " SET " + RetSqlName("SRD") + ".RD_SEMANA = '" + RDSEMANAS->NUMPAG  + "' "
			cQuery += " WHERE " + RetSqlName("SRD") + ".R_E_C_N_O_ = '" + ALLTRIM(STR(RDSEMANAS->RECNO)) + "' "

			If TCSQLEXEC(cQuery) != 0
				UserException( TCSqlError() )
				Conout("Erro ao Executar comando SQL. Query: " + cQuery)
				Break
			EndIf

			RDSEMANAS->(DbSkip())
		ENDDO
	End Sequence
return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} function fRotUpd
Realiza atualizações referentes ao roteiros
@author  oliveira.hugo
@since   04/01/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fRotUpd(aTable, aField, aColPref)
	Local cQuery := ""
	Local nLinha := 1

	Begin Sequence
		For nLinha := 1 to LEN(aTable)

			IF aTable[nLinha] == "RG1" .AND. aField[nLinha] == "RG1_ROT"
				cQuery := " UPDATE " + RetSqlName(aTable[nLinha]) + " SET " + aField[nLinha] + " = RG1_ROTEIR"
				cQuery += " WHERE " + RetSqlName(aTable[nLinha]) + ".D_E_L_E_T_ = ' ' AND " + aColPref[nLinha] + "_FILIAL = '" + xFilial(aTable[nLinha]) + "'"
			ELSE
				cQuery := " UPDATE " + RetSqlName(aTable[nLinha]) + " SET " + aField[nLinha] + " = (CASE WHEN " + aField[nLinha] + " = 'FOL' THEN 'FPB' "
				cQuery +=														                        " WHEN " + aField[nLinha] + " = 'RES' THEN 'RPB' "
				cQuery +=														      			   		" ELSE " + aField[nLinha] + " END)"
				cQuery += " WHERE " + RetSqlName(aTable[nLinha]) + ".D_E_L_E_T_ = ' ' AND " + aColPref[nLinha] + "_FILIAL = '" + xFilial(aTable[nLinha]) + "'"
			ENDIF

			If TCSQLEXEC(cQuery) != 0
				UserException( TCSqlError() )
				Conout("Erro ao Executar comando SQL. Query: " + cQuery)
				Break
			EndIf

		Next nLinha
	End Sequence
return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} function fCargaRCM
Realiza a carga dos novos Tipos de Ausências
@author  oliveira.hugo
@since   04/01/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fCargaRCM()
	Local nPosicao  := 0
	Local nX        := 1
	Local cAliasQry := GetNextAlias()
	Local nQtde     := 0

	BeginSql alias cAliasQry
		SELECT COUNT(*) QTDE FROM %Table:RCM% RCM WHERE RCM_FILIAL = %exp:xFilial("RCM")% AND RCM.%notDel%
	EndSql

	nQtde := (cAliasQry)->QTDE

	(cAliasQry)->( DbCloseArea() )

	DbSelectArea("RCM")
	RCM->(DBSETORDER(1)) // RCM_FILIAL + RCM_TIPO
	RCM->(DbGotop())

	If RCM->(DbSeek(xFilial("RCM"))) .And. !lRCMCompPr
		// Procura o registro pesquisando por Filial e Tipo
		While nQtde > 0 .And. RCM->RCM_FILIAL == xFilial("RCM")
			RCM->( DbSkip() )
			nPosicao := RCM->( Recno() )
			RCM->( DbSkip(-1) )

			// Tratamento para chave duplicada
			IF VAL(RCM->RCM_TIPO) < 500
				RecLock("RCM", .F.)

				// Tratamento dos Tipos de Ausências
				IF RCM->RCM_TIPO == "001" // Férias - Atualiza apenas os campos que estão vazios pelo padrão
					RCM->RCM_MESMED := 0
					RCM->RCM_REINCI := 0
					RCM->RCM_DIAS13 := 0
					RCM->RCM_DIASPL := 0
					RCM->RCM_DIASFE := 0
					RCM->RCM_SOBREP := "2"
					RCM->RCM_DEPFGT := "2"
					RCM->RCM_FERIAS := "4"
					RCM->RCM_DECIMO := "2"
					RCM->RCM_PROVFE := "1"
					RCM->RCM_ENCEMP := "2"
					RCM->RCM_PLR 	:= "2"
					RCM->RCM_SALFAM := "4"
					RCM->RCM_CSIND  := "1"
				ELSE
					RCM->RCM_TIPO := CVALTOCHAR(VAL(RCM->RCM_TIPO) + 500)

					// Tratamento especial para o campo RCM_PROVFE que possui mudança de conceito.
					IF RCM->RCM_PROVFE == "1"
						RCM->RCM_PROVFE := "2"
					ELSE
						RCM->RCM_PROVFE := "1"
					ENDIF
				ENDIF

				RCM->(MsUnLock())
			ENDIF

			RCM->(DbGoTo(nPosicao))
			nQtde--
		ENDDO
	EndIf

	lRCMCompPr := FWModeAccess("RCM", 3) == "C"
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} function fAusUpd
Realiza atualização de Ausências de acordo com os novos IDs da P12.
@author  oliveira.hugo
@since   04/01/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function fAusUpd()
	dbSelectArea("SR8")
	SR8->(dbSetOrder(1))
	SR8->(dbGotop())

	IF SR8->(dbSeek(FwxFilial('SR8')))
		WHILE SR8->(!Eof() .and. SR8->R8_FILIAL == xFilial("SR8"))

			IF (SR8->R8_TIPOAFA != "001") .AND. (VAL(SR8->R8_TIPOAFA) < 500) // 001 - Férias não deve mudar
				SR8->(RecLock("SR8", .F.))
					SR8->R8_TIPOAFA := CValToChar(VAL(SR8->R8_TIPOAFA) + 500)
				SR8->(MsUnlock())
			ENDIF
			SR8->(DbSkip())
		ENDDO
	ENDIF
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fVerDtSRA() ³ Autor ³ Leandro Drumond     ³ Data ³ 02/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe funcionario sem data de admissao		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPECONV                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fVerDtSRA(aLogPreCnv,cFilSRA)
	Local cAliasTst := GetNextAlias()
	Local lRet		:= .T.
	Local lPrimeiro := .T.

	BeginSql alias cAliasTst
		SELECT RA_FILIAL, RA_MAT, RA_ADMISSA,RA_SITFOLH,RA_DEMISSA, R_E_C_N_O_
		FROM %table:SRA% SRA
			WHERE ( SRA.RA_ADMISSA = '' OR (SRA.RA_SITFOLH = 'D' AND RA_DEMISSA = ''))
			AND SRA.RA_FILIAL = %exp:cFilSRA%
			AND SRA.%notDel%
	EndSql

	while ( (cAliasTst)->(!Eof()) )
		if(lPrimeiro)
			aAdd(aLogPreCnv,"")
			aAdd(aLogPreCnv,STR0106) //"Funcionários sem data de admissão ou demitidos sem data de demissão"
			lPrimeiro := .F.
			lRet	  := .F.
		endIf
		aAdd(aLogPreCnv,"RA_FILIAL: " + (cAliasTst)->RA_FILIAL + space(5) +  "RA_MAT: " + (cAliasTst)->RA_MAT +   space(5) +  "RA_ADMISSA: " + (cAliasTst)->RA_ADMISSA +   space(5) ;
		+  "RA_DEMISSA: " + (cAliasTst)->RA_DEMISSA +   space(5) +  "RA_SITFOLH: " + (cAliasTst)->RA_SITFOLH +   space(5) + "R_E_C_N_O_: " + STR((cAliasTst)->R_E_C_N_O_))
		(cAliasTst)->(dbSkip())
	EndDo
	(cAliasTst)->(DbCloseArea())
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fAjustSX()  ³ Autor ³ Leandro Drumond     ³ Data ³ 29/10/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajusta SX3.										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPECONV                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAjustSX()
	Local aArea		:= GetArea()
	Local aDados 	:= {}
	Local aOrd		:= {}
	Local nPos 		:= 0
	Local lDicDB	:= MPDicInDB()

	aAdd( aDados, { {'RK_NUMID'}, { { 'X3_RESERV', '–A', Nil } } } )
	aAdd( aDados, { {'RR_NUMID'}, { { 'X3_RESERV', '–A', Nil } } } )
	aAdd( aDados, { {'RD_NUMID'}, { { 'X3_RESERV', '–A', Nil } } } )
	aAdd( aDados, { {'RC_NUMID'}, { { 'X3_RESERV', '–A', Nil } } } )
	aAdd( aDados, { {'R8_NUMID'}, { { 'X3_RESERV', '–A', Nil } } } )
	aAdd( aDados, { {'RGE_NUMID'}, { { 'X3_RESERV', '–A', Nil } } } )
	aAdd( aDados, { {'RGB_NUMID'}, { { 'X3_RESERV', '–A', Nil } } } )
	aAdd( aDados, { {'RG1_NUMID'}, { { 'X3_RESERV', '–A', Nil } } } )
	aAdd( aDados, { {'RCK_NUMID'}, { { 'X3_RESERV', '–A', Nil } } } )

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))

	aOrd := {"R8_FILIAL","R8_MAT","R8_DATA","R8_TIPO","R8_SEQ","R8_TIPOAFA","R8_DESCTP","R8_PD","R8_DATAINI","R8_DURACAO","R8_AFARAIS","R8_DATAFIM","R8_CONTAFA","R8_DIASEMP","R8_TPCES","R8_DPAGAR","R8_SDPAGAR","R8_DPAGOS","R8_CONTINU","R8_CID","R8_CODCAT","R8_DTCAT","R8_MEMO","R8_SDODIAS","R8_CODMEMO","R8_STATUS","R8_NUMID","R8_PROCES","R8_PER","R8_CNPJSIN","R8_NUMPAGO","R8_EMPPG","R8_CODRPAT","R8_DTBLEG","R8_CODTPA","R8_RHEXP","R8_OBSAFAS","R8_TPEFD","R8_TIPOAT","R8_OBSTPA","R8_NMMED","R8_CRMMED","R8_UFCRM","R8_IDEOC","R8_CNPJCES","R8_TPCES","R8_CNPJSIN","R8_TPSIND"}
	For nPos :=1 To Len(aOrd)
		Aadd ( aDados, { { aOrd[nPos] },	{ { 'X3_ORDEM',  StrZero(nPos,2) } } } )
	Next nPos

	aOrd := {"RH_FILIAL","RH_MAT","RH_NOME","RH_SALMES","RH_SALDIA","RH_SALDIA1","RH_SALHRS","RH_SALHRS1","RH_DATABAS","RH_DBASEAT","RH_DFERVEN","RH_DFERIAS","RH_DABONPE","RH_ABOPEC","RH_DFALTAS","RH_PERC13S","RH_DATAINI","RH_DATAFIM","RH_DTAVISO","RH_DTRECIB","RH_DIALRE1","RH_ROTEIR","RH_SALDIF","RH_PERIODO","RH_DIALREM","RH_NPAGTO","RH_SALMIN","RH_SALMIND","RH_SALARIO","RH_SALARDF","RH_TIPCAL","RH_DAFASTA","RH_MEDATU","RH_OBSERVA","RH_PROCES","RH_RHEXP"}
	For nPos :=1 To Len(aOrd)
		Aadd ( aDados, { { aOrd[nPos] },	{ { X3_ORDEM,  StrZero(nPos,2) } } } )
	Next nPos


	aOrd := {"RG_FILIAL","RG_MAT","RG_NOME","RG_EFETIVA","RG_SABDOM","RG_DATADEM","RG_TIPORES","RG_DESCTPR","RG_DATAHOM","RG_DTGERAR","RG_DAVISO","RG_DTAVISO","RG_MEDATU","RG_DFERVEN","RG_DFERPRO","RG_DFERAVI","RG_NORMAL","RG_DESCANS","RG_SALMES","RG_SALDIA","RG_SALHORA","RG_PROCES","RG_COMPRAV","RG_JTCUMPR","RG_RHEXP","RG_IDCMPL","RG_RESCDIS","RG_RRA","RG_TPAVISO","RG_NPROC","RG_PERIODO","RG_OBITO","RG_ROTEIR","RG_SUCES","RG_OBS","RG_SEMANA","RG_TPDIR"}
	For nPos :=1 To Len(aOrd)
		Aadd ( aDados, { { aOrd[nPos] },	{ { X3_ORDEM,  StrZero(nPos,2) } } } )
	Next nPos

	/////////////////Q3_DESCCC ////////////////////
	Aadd ( aDados, { { 'Q3_DESCCC' }, { { 'X3_RELACAO', 'IF(Inclui,"",fDesc("CTT",SQ3->Q3_CC,"CTT_DESC01"))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' }  } } )

	/////////////////Q9_CODCONT////////////////////
	Aadd ( aDados, { { 'Q9_CODCONT' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////QD_DESCRIC////////////////////
	Aadd ( aDados, { { 'QD_DESCRIC' }, { { 'X3_RELACAO', 'Rs150Descri()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////QD_DRESULT////////////////////
	Aadd ( aDados, { { 'QD_DRESULT' }, { { 'X3_RELACAO', 'Rs150Dresul()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////QD_DTPPROC////////////////////
	Aadd ( aDados, { { 'QD_DTPPROC' }, { { 'X3_RELACAO', 'Rs150DTProc()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////QT_DESTIPO////////////////////
	Aadd ( aDados, { { 'QT_DESTIPO' }, { { 'X3_RELACAO', 'FDesc("SQX",SQT->QT_TIPO,"QX_DESC",,SQT->QT_FILIAL)' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////QW_DAREA  ////////////////////
	Aadd ( aDados, { { 'QW_DAREA' }, { { 'X3_RELACAO', 'IF(INCLUI,"",RS190DSX5("R1","SQW->QW_AREA","QW_DAREA"))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////QW_DNIVATE////////////////////
	Aadd ( aDados, { { 'QW_DNIVATE' }, { { 'X3_RELACAO', 'IF(INCLUI,"",RS190DSX5("RL","SQW->QW_NIVELAT","QW_DNIVATE"))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////QW_DNIVDE ////////////////////
	Aadd ( aDados, { { 'QW_DNIVDE' }, { { 'X3_RELACAO', 'IF(INCLUI,"",RS190DSX5("RL","SQW->QW_NIVELDE","QW_DNIVDE"))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////QW_DTIPO  ////////////////////
	Aadd ( aDados, { { 'QW_DTIPO' }, { { 'X3_RELACAO', 'IF(INCLUI,"",RS190DSX5("RJ","SQW->QW_TIPO","QW_DTIPO"))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////QW_DTOPICO////////////////////
	Aadd ( aDados, { { 'QW_DTOPICO' }, { { 'X3_RELACAO', 'IF(INCLUI,"",RS190DSX5("RJ","SQW->QW_TIPO","QW_DTIPO"))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////R0_DESC   ////////////////////
	Aadd ( aDados, { { 'R0_DESC' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////R3_TIPO   ////////////////////
	Aadd ( aDados, { { 'R3_TIPO' }, { { 'X3_RELACAO', 'R3TipoInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////R8_CODRPAT////////////////////
	Aadd ( aDados, { { 'R8_CODRPAT' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', 'gp240VerEdit()' }, { 'X3_CBOX', '' }, { 'X3_F3', 'GF0' } } } )

	/////////////////R8_CONTINU////////////////////
	Aadd ( aDados, { { 'R8_CONTINU' }, { { 'X3_RELACAO', '"2"' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '1=Sim;2=Nao' }, { 'X3_F3', '' } } } )

	/////////////////R8_DESCTP ////////////////////
	Aadd ( aDados, { { 'R8_DESCTP' }, { { 'X3_RELACAO', 'IF(INCLUI, "", Posicione("RCM",1,xFilial("RCM")+SR8->R8_TIPOAFA,"RCM_DESCRI"))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////R8_MEMO   ////////////////////
	Aadd ( aDados, { { 'R8_MEMO' }, { { 'X3_RELACAO', 'IF(INCLUI, "", MSMM(SR8->R8_CODMEMO))' }, { 'X3_WHEN', 'gp240VerEdit()' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////R8_PD     ////////////////////
	Aadd ( aDados, { { 'R8_PD' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', 'gp240VerEdit()' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SRV' } } } )

	/////////////////RE0_INDSUS////////////////////
	Aadd ( aDados, { { 'RE0_INDSUS' }, { { 'X3_ORDEM', '24' } } } )

	/////////////////RA1_DESGRU////////////////////
	Aadd ( aDados, { { 'RA1_DESGRU' }, { { 'X3_RELACAO', 'Ra1DesGruInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA2_ENTIDA////////////////////
	Aadd ( aDados, { { 'RA2_ENTIDA' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', 'Ra2EntidWhen()' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RA0' } } } )

	/////////////////RA4_DESCCU////////////////////
	Aadd ( aDados, { { 'RA4_DESCCU' }, { { 'X3_RELACAO', 'IF(INCLUI,"",FDesc("RA1",RA4->RA4_CURSO,"RA1->RA1_DESC",30))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA4_DESCEN////////////////////
	Aadd ( aDados, { { 'RA4_DESCEN' }, { { 'X3_RELACAO', 'IF(INCLUI,"",FDesc("RA0",RA4->RA4_ENTIDA,"RA0->RA0_DESC",30))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA4_DESCSI////////////////////
	Aadd ( aDados, { { 'RA4_DESCSI' }, { { 'X3_RELACAO', 'IF(INCLUI,"",FDesc("RA9",RA4->RA4_SINONI,"RA9->RA9_DESCR",30))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA4_NOTA  ////////////////////
	Aadd ( aDados, { { 'RA4_NOTA' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RAA_DESC  ////////////////////
	Aadd ( aDados, { { 'RAA_DESC' }, { { 'X3_RELACAO', 'IF(INCLUI,"",RS190DSX5("R8","RAA->RAA_DESPES","RAA_DESC"))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RAX_SEQUEN////////////////////
	Aadd ( aDados, { { 'RAX_SEQUEN' }, { { 'X3_RELACAO', 'SeqRAX()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RAY_DSCERT////////////////////
	Aadd ( aDados, { { 'RAY_DSCERT' }, { { 'X3_RELACAO', "FDESC('RHG', RAY->RAY_CERTIF, 'RHG_DESC')" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RAY_STATUS////////////////////
	Aadd ( aDados, { { 'RAY_STATUS' }, { { 'X3_RELACAO', "" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '"0=Inativo;1=Ativo;2=Indisponivel"' }, { 'X3_F3', '' } } } )

	/////////////////RA_ANOCHEG////////////////////
	Aadd ( aDados, { { 'RA_ANOCHEG' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_ASMEDIC////////////////////
	Aadd ( aDados, { { 'RA_ASMEDIC' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'S008' } } } )

	/////////////////RA_BCDEPSA////////////////////
	Aadd ( aDados, { { 'RA_BCDEPSA' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'BA1' } } } )

	/////////////////RA_CBO    ////////////////////
	Aadd ( aDados, { { 'RA_CBO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_CEP    ////////////////////
	Aadd ( aDados, { { 'RA_CEP' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_CLASSEC////////////////////
	Aadd ( aDados, { { 'RA_CLASSEC' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_CLVL   ////////////////////
	Aadd ( aDados, { { 'RA_CLVL' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'CTH' } } } )

	/////////////////RA_CODIGO ////////////////////
	Aadd ( aDados, { { 'RA_CODIGO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_CTDEPSA////////////////////
	Aadd ( aDados, { { 'RA_CTDEPSA' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_DESCFUN////////////////////
	Aadd ( aDados, { { 'RA_DESCFUN' }, { { 'X3_RELACAO', "IF(INCLUI,'',FDESC('SRJ',SRA->RA_CODFUNC,'RJ_DESC',TamSX3('RJ_DESC'),SRA->RA_FILIAL))" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_ESTADO ////////////////////
	Aadd ( aDados, { { 'RA_ESTADO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '12' } } } )

	/////////////////RA_INSMED ////////////////////
	Aadd ( aDados, { { 'RA_INSMED' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_INSMIN ////////////////////
	Aadd ( aDados, { { 'RA_INSMIN' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_INSSSC ////////////////////
	Aadd ( aDados, { { 'RA_INSSSC' }, { { 'X3_RELACAO', '"S"' }, { 'X3_WHEN', '' }, { 'X3_CBOX', 'S=Sim;N=Nao' }, { 'X3_F3', '' } } } )

	/////////////////RA_ITEM   ////////////////////
	Aadd ( aDados, { { 'RA_ITEM' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'CTD' } } } )

	/////////////////RA_MESTRAB////////////////////
	Aadd ( aDados, { { 'RA_MESTRAB' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_MUNICIP////////////////////
	Aadd ( aDados, { { 'RA_MUNICIP' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RA_PGCTSIN////////////////////
	Aadd ( aDados, { { 'RA_PGCTSIN' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '29' } } } )

	/////////////////RA_PROCES ////////////////////
	Aadd ( aDados, { { 'RA_PROCES' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RCJ2' } } } )

	/////////////////RA_RACACOR////////////////////
	Aadd ( aDados, { { 'RA_RACACOR' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '1=Indigena;2=Branca;4=Preta;6=Amarela;8=Parda;9=Nao Informado' }, { 'X3_F3', '' } } } )

	/////////////////RA_REGRA  ////////////////////
	Aadd ( aDados, { { 'RA_REGRA' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SPA' } } } )

	/////////////////RA_SEGUROV////////////////////
	Aadd ( aDados, { { 'RA_SEGUROV' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'S06BRA' } } } )

	/////////////////RA_SEQTURN////////////////////
	Aadd ( aDados, { { 'RA_SEQTURN' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'XPJ' } } } )

	/////////////////RA_TPCONTR////////////////////
	Aadd ( aDados, { { 'RA_TPCONTR' }, { { 'X3_RELACAO', '"1"' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '1=Indeterminado;2=Determinado' }, { 'X3_F3', '' } } } )

	/////////////////RA_VALEALI////////////////////
	Aadd ( aDados, { { 'RA_VALEALI' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RFO02' } } } )

	/////////////////RA_VALEREF////////////////////
	Aadd ( aDados, { { 'RA_VALEREF' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RFO01' } } } )

	/////////////////RA_LOGRTPD////////////////////
	Aadd ( aDados, { { 'RA_LOGRTPD' }, { { 'X3_RELACAO', 'If(Inclui, "", fDescRCC("S054", SRA->RA_LOGRTP, 1, 4, 5, 20))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RB_DTFIMAM////////////////////
	Aadd ( aDados, { { 'RB_DTFIMAM' }, { { 'X3_RELACAO', 'Ctod("//")' }, { 'X3_WHEN', 'WhenSetEpoch(.F.)' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RB_DTFIMAO////////////////////
	Aadd ( aDados, { { 'RB_DTFIMAO' }, { { 'X3_RELACAO', 'Ctod("//")' }, { 'X3_WHEN', 'WhenSetEpoch(.F.)' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RB_DTINIAM////////////////////
	Aadd ( aDados, { { 'RB_DTINIAM' }, { { 'X3_RELACAO', 'Ctod("//")' }, { 'X3_WHEN', 'WhenSetEpoch(.F.)' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RB_DTINIAO////////////////////
	Aadd ( aDados, { { 'RB_DTINIAO' }, { { 'X3_RELACAO', 'Ctod("//")' }, { 'X3_WHEN', 'WhenSetEpoch(.F.)' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC3_DESCR ////////////////////
	Aadd ( aDados, { { 'RC3_DESCR' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC3_FORM01////////////////////
	Aadd ( aDados, { { 'RC3_FORM01' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC3_FORM02////////////////////
	Aadd ( aDados, { { 'RC3_FORM02' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC3_OPERA1////////////////////
	Aadd ( aDados, { { 'RC3_OPERA1' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC3_OPERA2////////////////////
	Aadd ( aDados, { { 'RC3_OPERA2' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC3_OPERA3////////////////////
	Aadd ( aDados, { { 'RC3_OPERA3' }, { { 'X3_RELACAO', '".END."' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC3_RESULT////////////////////
	Aadd ( aDados, { { 'RC3_RESULT' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC3_SEQPAI////////////////////
	Aadd ( aDados, { { 'RC3_SEQPAI' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC3_TIPO  ////////////////////
	Aadd ( aDados, { { 'RC3_TIPO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC4_MEMO  ////////////////////
	Aadd ( aDados, { { 'RC4_MEMO' }, { { 'X3_RELACAO', 'Rc4MemoInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC8_INDRES////////////////////
	Aadd ( aDados, { { 'RC8_INDRES' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RC8GRP' } } } )

	/////////////////RCA_ACUMUL////////////////////
	Aadd ( aDados, { { 'RCA_ACUMUL' }, { { 'X3_RELACAO', 'RcaAcumulInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '#RcaAcumulBox()' }, { 'X3_F3', '' } } } )

	/////////////////RCF_CONTAB////////////////////
	Aadd ( aDados, { { 'RCF_CONTAB' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RCF_FECHAD////////////////////
	Aadd ( aDados, { { 'RCF_FECHAD' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RCH_DTPGAD////////////////////
	Aadd ( aDados, { { 'RCH_DTPGAD' }, { { 'X3_RELACAO', 'CTOD("//")' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RCJ_TPSAL ////////////////////
	Aadd ( aDados, { { 'RCJ_TPSAL' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RCL_DPROC ////////////////////
	Aadd ( aDados, { { 'RCL_DPROC' }, { { 'X3_RELACAO', 'RCLDProcIni()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RCL_PROCES////////////////////
	Aadd ( aDados, { { 'RCL_PROCES' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RCJ' } } } )

	/////////////////RC_CC     ////////////////////
	Aadd ( aDados, { { 'RC_CC' }, { { 'X3_RELACAO', 'RCCCINIT()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'CTT' } } } )

	/////////////////RC_CODB1T ////////////////////
	Aadd ( aDados, { { 'RC_CODB1T' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC_DATA   ////////////////////
	Aadd ( aDados, { { 'RC_DATA' }, { { 'X3_RELACAO', 'RcDataInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC_DEPTO  ////////////////////
	Aadd ( aDados, { { 'RC_DEPTO' }, { { 'X3_RELACAO', 'RcDeptoInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SQB' } } } )

	/////////////////RC_DTREF  ////////////////////
	Aadd ( aDados, { { 'RC_DTREF' }, { { 'X3_RELACAO', 'RcDtRefInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC_EMPCONS////////////////////
	Aadd ( aDados, { { 'RC_EMPCONS' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', 'S=Sim;N=Nao' }, { 'X3_F3', '' } } } )

	/////////////////RC_PROCES ////////////////////
	Aadd ( aDados, { { 'RC_PROCES' }, { { 'X3_RELACAO', 'RcProcesInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC_ROTEIR ////////////////////
	Aadd ( aDados, { { 'RC_ROTEIR' }, { { 'X3_RELACAO', 'RcRoteirInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC_TIPO2  ////////////////////
	Aadd ( aDados, { { 'RC_TIPO2' }, { { 'X3_RELACAO', 'RcTipo2Init()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RC_VNAOAPL////////////////////
	Aadd ( aDados, { { 'RC_VNAOAPL' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RD_CLVL   ////////////////////
	Aadd ( aDados, { { 'RD_CLVL' }, { { 'X3_RELACAO', 'SRA->RA_CLVL' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'CTH' } } } )

	/////////////////RD_DEPTO  ////////////////////
	Aadd ( aDados, { { 'RD_DEPTO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SQB' } } } )

	/////////////////RD_DTREF  ////////////////////
	Aadd ( aDados, { { 'RD_DTREF' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RD_EMPCONS////////////////////
	Aadd ( aDados, { { 'RD_EMPCONS' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', 'S=Sim;N=Nao' }, { 'X3_F3', '' } } } )

	/////////////////RD_NUMID  ////////////////////
	Aadd ( aDados, { { 'RD_NUMID' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RD_PERIODO////////////////////
	Aadd ( aDados, { { 'RD_PERIODO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RCH10' } } } )

	/////////////////RD_PROCES ////////////////////
	Aadd ( aDados, { { 'RD_PROCES' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RD_ROTEIR ////////////////////
	Aadd ( aDados, { { 'RD_ROTEIR' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SRY' } } } )

	/////////////////REC_DESCR ////////////////////
	Aadd ( aDados, { { 'REC_DESCR' }, { { 'X3_RELACAO', 'IF(Inclui,"",fDesc("RER",REC->REC_REGIAO,"RER_DESCR", , REC->REC_FILIAL))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////REH_ASSNOM////////////////////
	Aadd ( aDados, { { 'REH_ASSNOM' }, { { 'X3_RELACAO', 'IIF(!Inclui .AND. !EMPTY(REH->REH_ASSTEC),fDesc("RD0",REH->REH_ASSTEC,"RD0_NOME"),"")' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////REH_DTPERI////////////////////
	Aadd ( aDados, { { 'REH_DTPERI' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', 'RehSx3When()' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////REH_DTSOLI////////////////////
	Aadd ( aDados, { { 'REH_DTSOLI' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////REH_OBS   ////////////////////
	Aadd ( aDados, { { 'REH_OBS' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////REH_PERINO////////////////////
	Aadd ( aDados, { { 'REH_PERINO' }, { { 'X3_RELACAO', 'IIF(!Inclui .AND. !EMPTY(REH->REH_PERITO),fDesc("RD0",REH->REH_PERITO,"RD0_NOME"),"")' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////REH_RESDES////////////////////
	Aadd ( aDados, { { 'REH_RESDES' }, { { 'X3_RELACAO', 'IF(Inclui,"",IIF(!EMPTY(REH->REH_RESULT),fDesc("RE5",' + "RST" + '+REH->REH_RESULT,"RE5_DESCR"),""))' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////REM_DATA  ////////////////////
	Aadd ( aDados, { { 'REM_DATA' }, { { 'X3_RELACAO', 'CTOD("")' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RF_FVENPEN////////////////////
	Aadd ( aDados, { { 'RF_FVENPEN' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RF_IVENPEN////////////////////
	Aadd ( aDados, { { 'RF_IVENPEN' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RF_PD     ////////////////////
	Aadd ( aDados, { { 'RF_PD' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', 'gp050VerEdit()' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SRVSRF' } } } )

	/////////////////RG3_BLQ131////////////////////
	Aadd ( aDados, { { 'RG3_BLQ131' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RG3_BLQ132////////////////////
	Aadd ( aDados, { { 'RG3_BLQ132' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RG3_BLQADT////////////////////
	Aadd ( aDados, { { 'RG3_BLQADT' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RG3_DTBLOQ////////////////////
	Aadd ( aDados, { { 'RG3_DTBLOQ' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RG3_NUSER3////////////////////
	Aadd ( aDados, { { 'RG3_NUSER3' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RG3_NUSER4////////////////////
	Aadd ( aDados, { { 'RG3_NUSER4' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RG3_TIPO  ////////////////////
	Aadd ( aDados, { { 'RG3_TIPO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RG3_USER3 ////////////////////
	Aadd ( aDados, { { 'RG3_USER3' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'USR' } } } )

	/////////////////RG3_USER4 ////////////////////
	Aadd ( aDados, { { 'RG3_USER4' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'USR' } } } )

	/////////////////RGA_DESCAL////////////////////
	Aadd ( aDados, { { 'RGA_DESCAL' }, { { 'X3_RELACAO', "If(!INCLUI,fDesc('SRY', RGA->RGA_CALCUL, 'RY_DESC', NIL, RGA->RGA_FILIAL),'')" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RGA_DESPRO////////////////////
	Aadd ( aDados, { { 'RGA_DESPRO' }, { { 'X3_RELACAO', "If(!INCLUI,fDesc('RCJ', RGA->RGA_PROCES, 'RCJ_DESCRI', NIL, RGA->RGA_FILIAL),'')" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RGA_MODULO////////////////////
	Aadd ( aDados, { { 'RGA_MODULO' }, { { 'X3_RELACAO', 'If(INCLUI .OR. ALTERA, cModulo , "")' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RGE_DATAFI////////////////////
	Aadd ( aDados, { { 'RGE_DATAFI' }, { { 'X3_RELACAO', 'CtoD("//")' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RG_DESCTPR////////////////////
	Aadd ( aDados, { { 'RG_DESCTPR' }, { { 'X3_RELACAO', 'fDescRCC("S043",IF(Type("cTipRes")=="C" .And. !Empty(cTipRes),cTipRes,SRG->RG_TIPORES),1,2,3,30)' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RG_EFETIVA////////////////////
	Aadd ( aDados, { { 'RG_EFETIVA' }, { { 'X3_RELACAO', '"S"' }, { 'X3_WHEN', '' }, { 'X3_CBOX', 'S=Sim;N=Nao' }, { 'X3_F3', '' } } } )

	/////////////////RG_MEDATU ////////////////////
	Aadd ( aDados, { { 'RG_MEDATU' }, { { 'X3_RELACAO', '"N"' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )


	/////////////////RG_DATADEM ////////////////////
	Aadd ( aDados, { { 'RG_DATADEM' }, { { 'X3_VISUAL', 'A' } } } )

	/////////////////RG_TIPORES ////////////////////
	Aadd ( aDados, { { 'RG_TIPORES' }, { { 'X3_VISUAL', 'A' } } } )

	/////////////////RG_ROTEIR ////////////////////
	Aadd ( aDados, { { 'RG_ROTEIR' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RHM_MAT   ////////////////////
	Aadd ( aDados, { { 'RHM_MAT' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RH_NPAGTO ////////////////////
	Aadd ( aDados, { { 'RH_NPAGTO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RCH01' } } } )

	/////////////////RH_PERIODO////////////////////
	Aadd ( aDados, { { 'RH_PERIODO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RCH' } } } )

	/////////////////RH_PROCES ////////////////////
	Aadd ( aDados, { { 'RH_PROCES' }, { { 'X3_RELACAO', 'SRA->RA_PROCES' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RH_ROTEIR ////////////////////
	Aadd ( aDados, { { 'RH_ROTEIR' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RK_HORAS  ////////////////////
	Aadd ( aDados, { { 'RK_HORAS' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RK_NUMID  ////////////////////
	Aadd ( aDados, { { 'RK_NUMID' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RK_POSTO  ////////////////////
	Aadd ( aDados, { { 'RK_POSTO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RCL' } } } )

	/////////////////RK_PROCES ////////////////////
	Aadd ( aDados, { { 'RK_PROCES' }, { { 'X3_RELACAO', 'SRA->RA_PROCES' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RK_TIPO   ////////////////////
	Aadd ( aDados, { { 'RK_TIPO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RM_CHAVE  ////////////////////
	Aadd ( aDados, { { 'RM_CHAVE' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RM_CODFOR ////////////////////
	Aadd ( aDados, { { 'RM_CODFOR' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'RC201' } } } )

	/////////////////RM_FALSE  ////////////////////
	Aadd ( aDados, { { 'RM_FALSE' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RM_IF     ////////////////////
	Aadd ( aDados, { { 'RM_IF' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RM_VERBA  ////////////////////
	Aadd ( aDados, { { 'RM_VERBA' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', 'RmVerbaWhen()' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SRV' } } } )

	/////////////////RO_DESTAR ////////////////////
	Aadd ( aDados, { { 'RO_DESTAR' }, { { 'X3_RELACAO', 'fDescRCC("S070", SRO->RO_CODTAR, 1, 3, 4, 30)' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RR_PERIODO////////////////////
	Aadd ( aDados, { { 'RR_PERIODO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RV_DESMSEG////////////////////
	Aadd ( aDados, { { 'RV_DESMSEG' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RV_GRPVERB////////////////////
	Aadd ( aDados, { { 'RV_GRPVERB' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SRVGRP' } } } )

	/////////////////RV_RAIS   ////////////////////
	Aadd ( aDados, { { 'RV_RAIS' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SRVRAI' } } } )

	/////////////////RV_RLIMATE////////////////////
	Aadd ( aDados, { { 'RV_RLIMATE' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RV_RLIMDE ////////////////////
	Aadd ( aDados, { { 'RV_RLIMDE' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RV_VLIMATE////////////////////
	Aadd ( aDados, { { 'RV_VLIMATE' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RV_VLIMDE ////////////////////
	Aadd ( aDados, { { 'RV_VLIMDE' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RX_COD    ////////////////////
	Aadd ( aDados, { { 'RX_COD' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RY_ALIAS  ////////////////////
	Aadd ( aDados, { { 'RY_ALIAS' }, { { 'X3_RELACAO', 'RyAliasSX2Init' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '#RyGetAliasSX2()' }, { 'X3_F3', '' } } } )

	/////////////////RY_DESOBS ////////////////////
	Aadd ( aDados, { { 'RY_DESOBS' }, { { 'X3_RELACAO', 'RYDesObsInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////RY_ORDINAR////////////////////
	Aadd ( aDados, { { 'RY_ORDINAR' }, { { 'X3_RELACAO', '"2"' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '1=Sim;2=Nao' }, { 'X3_F3', '' } } } )

	/////////////////RY_ORIGEM ////////////////////
	Aadd ( aDados, { { 'RY_ORIGEM' }, { { 'X3_RELACAO', 'RyOrigemInit()' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '#RyOrigemBox()' }, { 'X3_F3', '' } } } )

	/////////////////RY_RECOMP ////////////////////
	Aadd ( aDados, { { 'RY_RECOMP' }, { { 'X3_RELACAO', '"1"' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '1=Sim;2=Nao' }, { 'X3_F3', '' } } } )

	/////////////////TJC_CODPRO////////////////////
	Aadd ( aDados, { { 'TJC_CODPRO' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', 'MDT182WHPR()' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TJF_DESMED////////////////////
	Aadd ( aDados, { { 'TJF_DESMED' }, { { 'X3_RELACAO', "If( INCLUI,'',Posicione( 'TO4', 1, xFilial( 'TO4' ) + TJF->TJF_MEDCON, 'TO4_NOMCTR' ))" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TK7_NUMFIC////////////////////
	Aadd ( aDados, { { 'TK7_NUMFIC' }, { { 'X3_RELACAO', "If( IsInCallStack('MDTA155A'), M->TMT_NUMFIC, '' )" }, { 'X3_WHEN', 'MD"925WHEN()' }, { 'X3_CBOX', '' }, { 'X3_F3', 'TM0' } } } )

	/////////////////TLA_UNIMED////////////////////
	Aadd ( aDados, { { 'TLA_UNIMED' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TLD_DESEXT////////////////////
	Aadd ( aDados, { { 'TLD_DESEXT' }, { { 'X3_RELACAO', 'MDT555R1(.F.)' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TLD_DESTIP////////////////////
	Aadd ( aDados, { { 'TLD_DESTIP' }, { { 'X3_RELACAO', 'MDT555R2(.F.)' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TM2_NOMEDI////////////////////
	Aadd ( aDados, { { 'TM2_NOMEDI' }, { { 'X3_RELACAO', "IF(!INCLUI, NGSEEK('TM1',TM2->TM2_CODMED,1,'TM1_NOMEDI'), '')" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TMJ_CODUSU////////////////////
	Aadd ( aDados, { { 'TMJ_CODUSU' }, { { 'X3_RELACAO', 'If(cPrograma == "MDTA410",Space(Len(TMJ_CODUSU)),TML->TML_CODUSU)' }, { 'X3_WHEN', 'cPrograma == "MDTA410"' }, { 'X3_CBOX', '' }, { 'X3_F3', 'TMKAGE' } } } )

	/////////////////TMJ_NOMUSU////////////////////
	Aadd ( aDados, { { 'TMJ_NOMUSU' }, { { 'X3_RELACAO', "NGSEEK('TMK',M->TMJ_CODUSU,1,'TMK_NOMUSU')" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN0_ATIPER////////////////////
	Aadd ( aDados, { { 'TN0_ATIPER' }, { { 'X3_RELACAO', "If(Inclui,'1',TN0->TN0_ATIPER)" }, { 'X3_WHEN', 'RisAtiWhen(2)' }, { 'X3_CBOX', '1=Não Periculosa;2=Periculosa' }, { 'X3_F3', '' } } } )

	/////////////////TN0_ATISAL////////////////////
	Aadd ( aDados, { { 'TN0_ATISAL' }, { { 'X3_RELACAO', "If(Inclui,'1',TN0->TN0_ATISAL)" }, { 'X3_WHEN', 'RisAtiWhen(1)' }, { 'X3_CBOX', '1=Salubre;2=Insalubre' }, { 'X3_F3', '' } } } )

	/////////////////TN0_DESMED////////////////////
	Aadd ( aDados, { { 'TN0_DESMED' }, { { 'X3_RELACAO', "If( INCLUI,'',Posicione( 'TO4', 1, xFilial( 'TO4' ) + TN0->TN0_MEDCON, 'TO4_NOMCTR' ))" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN0_NOMAGE////////////////////
	Aadd ( aDados, { { 'TN0_NOMAGE' }, { { 'X3_RELACAO', "If( INCLUI,'',Posicione( 'TMA', 1, xFilial( 'TMA' ) + TN0->TN0_AGENTE, 'TMA_AGENTE' ))" }, { 'X3_WHEN', 'DTVALIDA' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN0_NOMAMB////////////////////
	Aadd ( aDados, { { 'TN0_NOMAMB' }, { { 'X3_RELACAO', "If( INCLUI,'',Posicione( 'TNE', 1, xFilial( 'TNE' ) + TN0->TN0_CODAMB, 'TNE_NOME'   ))" }, { 'X3_WHEN', 'DTVALIDA' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN0_NOMFON////////////////////
	Aadd ( aDados, { { 'TN0_NOMFON' }, { { 'X3_RELACAO', "If( INCLUI,'',Posicione( 'TN7', 1, xFilial( 'TN7' ) + TN0->TN0_FONTE , 'TN7_NOMFON' ))" }, { 'X3_WHEN', 'DTVALIDA' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN5_DESCR1////////////////////
	Aadd ( aDados, { { 'TN5_DESCR1' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN5_DESCR2////////////////////
	Aadd ( aDados, { { 'TN5_DESCR2' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN5_DESCR3////////////////////
	Aadd ( aDados, { { 'TN5_DESCR3' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN5_DESCR4////////////////////
	Aadd ( aDados, { { 'TN5_DESCR4' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN5_DESTAR////////////////////
	Aadd ( aDados, { { 'TN5_DESTAR' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TN9_NOMEXA////////////////////
	Aadd ( aDados, { { 'TN9_NOMEXA' }, { { 'X3_RELACAO', 'If( INCLUI," " , Posicione( "TM4" , 1 , xFilial("TM4",TN9->TN9_FILIAL)+TN9->TN9_EXAME , "TM4_NOMEXA" ) )' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TNN_DTTERM////////////////////
	Aadd ( aDados, { { 'TNN_DTTERM' }, { { 'X3_RELACAO', "If(isincallstack('Mdt635Ext'),cDatafim,CTOD('  /  /  '))" }, { 'X3_WHEN', 'TNNEXTRAWH(cWhenOri)' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TNT_DESACI////////////////////
	Aadd ( aDados, { { 'TNT_DESACI' }, { { 'X3_RELACAO', 'MDT675ACID(TNC->TNC_ACIDEN)' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TNW_NOMUSU////////////////////
	Aadd ( aDados, { { 'TNW_NOMUSU' }, { { 'X3_RELACAO', 'MDT175INI( 1 )' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TNY_OCORRE////////////////////
	Aadd ( aDados, { { 'TNY_OCORRE' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '1=Atend. Clinico;2=Doenca do Trabalho;3=Acidente Tipico;4=Acidente Trajeto;5=Outros Atedimentos;6=Avaliacao NR7' }, { 'X3_F3', '' } } } )

	/////////////////TO0_NOMUSU////////////////////
	Aadd ( aDados, { { 'TO0_NOMUSU' }, { { 'X3_RELACAO', "IF(!INCLUI,SGARETQAASRA(TO0->TO0_CODUSU,TO0->TO0_TIPELA,'TMK','TMK->TMK_NOMUSU'),'')" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TO2_NOEQTO////////////////////
	Aadd ( aDados, { { 'TO2_NOEQTO' }, { { 'X3_RELACAO', "NGSEEK('TM7',TO2->TO2_EQPTO,1,'TM7_NOEQTO')" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TO5_CODFUN////////////////////
	Aadd ( aDados, { { 'TO5_CODFUN' }, { { 'X3_RELACAO', '' }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', 'SRJ' } } } )

	/////////////////TO5_NOMAMB////////////////////
	Aadd ( aDados, { { 'TO5_NOMAMB' }, { { 'X3_RELACAO', "NGSEEK('TNE',TO5->TO5_CODAMB,1,'TNE_NOME')" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	/////////////////TO9_NOMEPC////////////////////
	Aadd ( aDados, { { 'TO9_NOMEPC' }, { { 'X3_RELACAO', "MDT265RELC('TO9_NOMEPC')" }, { 'X3_WHEN', '' }, { 'X3_CBOX', '' }, { 'X3_F3', '' } } } )

	////////////////RA4_DESCCU/////////////////////////
	Aadd ( aDados, { { 'RA4_DESCCU' }, { { 'X3_RELACAO', 'IF(INCLUI,"",FDesc("RA1",RA4->RA4_CURSO,"RA1->RA1_DESC",30))' } } } )

	///////////////RA4_DESCSI/////////////////////////
	Aadd ( aDados, { { 'RA4_DESCSI' }, { { 'X3_RELACAO', 'IF(INCLUI,"",FDesc("RA9",RA4->RA4_SINONI,"RA9->RA9_DESCR",30))' } } } )

	////////////////////RA4_DESCEN/////////////////////
	Aadd ( aDados, { { 'RA4_DESCEN' }, { { 'X3_RELACAO', 'IF(INCLUI,"",FDesc("RA0",RA4->RA4_ENTIDA,"RA0->RA0_DESC",30))' } } } )

	////////////////////////RA_TIPOCON///////////////////
	If SX3->( dbSeek("RA_TIPOCON") )
		If UPPER(Alltrim(SX3->X3_WHEN)) == "FOPCTAB('M->RA_TIPOCON', 'S016', 1,2,  , , .T., .T.)"
			Aadd ( aDados, { { 'RA_TIPOCON' }, { { 'X3_VALID', "fOpcTab('M->RA_TIPOCON', 'S016', 1,2,  , , .T., .T.)" }, { 'X3_WHEN', '' } } } )
		Endif
	Endif

	/////////////////////RA_REGPREV//////////////////////
	If SX3->( dbSeek("RA_REGPREV") )
		If UPPER(Alltrim(SX3->X3_WHEN)) == "FOPCTAB('M->RA_TIPOCON', 'S016', 1,2,  , , .T., .T.)"
			Aadd ( aDados, { { 'RA_REGPREV' }, { { 'X3_VALID', "fOpcTab('M->RA_REGPREV','S013', 1,2)" }, { 'X3_WHEN', '' } } } )
		Endif
	Endif

	///////////////RF5_CODREF///////////////////////
	Aadd ( aDados, { { 'RF5_CODREF' }, { { 'X3_VALID', 'Vazio() .or. ExistCPO("SP1")' } } } )

	//Campos da CTT que foram criados na P11 para o eSocial e não serão mais utilizados na P12
	///////////////CTT_LOGRTP///////////////////////
	If (SX3->(dbSeek("CTT_LOGRTP"))) .AND. X3USO(SX3->X3_USADO)
		If lDicDb
			Aadd ( aDados, { { 'CTT_LOGRTP' }, { { 'X3_USADO', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       ' } } } )
		Else
			Aadd ( aDados, { { 'CTT_LOGRTP' }, { { 'X3_USADO', '€€€€€€€€€€€€€€€' } } } )
		Endif
	Endif


	///////////////CTT_LOGRTD///////////////////////
	If (SX3->(dbSeek("CTT_LOGRTD"))) .AND. X3USO(SX3->X3_USADO)
		If lDicDb
			Aadd ( aDados, { { 'CTT_LOGRTD' }, { { 'X3_USADO', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       ' } } } )
		Else
			Aadd ( aDados, { { 'CTT_LOGRTD' }, { { 'X3_USADO', '€€€€€€€€€€€€€€€' } } } )
		Endif
	Endif


	///////////////CTT_LOGRDS///////////////////////
	If (SX3->(dbSeek("CTT_LOGRDS"))) .AND. X3USO(SX3->X3_USADO)
		If lDicDb
			Aadd ( aDados, { { 'CTT_LOGRDS' }, { { 'X3_USADO', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       ' } } } )
		Else
			Aadd ( aDados, { { 'CTT_LOGRDS' }, { { 'X3_USADO', '€€€€€€€€€€€€€€€' } } } )
		Endif
	Endif

	///////////////CTT_LOGRNR///////////////////////
	If (SX3->(dbSeek("CTT_LOGRNR"))) .AND. X3USO(SX3->X3_USADO)
		If lDicDb
			Aadd ( aDados, { { 'CTT_LOGRNR' }, { { 'X3_USADO', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       ' } } } )
		Else
			Aadd ( aDados, { { 'CTT_LOGRNR' }, { { 'X3_USADO', '€€€€€€€€€€€€€€€' } } } )
		Endif
	Endif

	///////////////CTT_COMPL///////////////////////
	If (SX3->(dbSeek("CTT_COMPL"))) .AND. X3USO(SX3->X3_USADO)
		If lDicDb
			Aadd ( aDados, { { 'CTT_COMPL' }, { { 'X3_USADO', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       ' } } } )
		Else
			Aadd ( aDados, { { 'CTT_COMPL' }, { { 'X3_USADO', '€€€€€€€€€€€€€€€' } } } )
		Endif
	Endif

	///////////////CTT_DCODMU///////////////////////
	If (SX3->(dbSeek("CTT_DCODMU"))) .AND. X3USO(SX3->X3_USADO)
		If lDicDb
			Aadd ( aDados, { { 'CTT_DCODMU' }, { { 'X3_USADO', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       ' } } } )
		Else
			Aadd ( aDados, { { 'CTT_DCODMU' }, { { 'X3_USADO', '€€€€€€€€€€€€€€€' } } } )
		Endif
	Endif

	RestArea(aArea)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAjustSX1      ºAutor ³Leandro Drumond  º Data ³  18/11/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta SX1 naoalterado pelo UPDDISTR                        ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAjustSX1()
	Local aArea		:= GetArea()
	Local nX		:= 0

	dbSelectArea("SX1")
	dbSetorder(1)
	dbSeek("GPEM020   ")

	While SX1->(!Eof()) .and. AllTrim(SX1->X1_GRUPO) == "GPEM020"
		If SX1->X1_GRUPO + SX1->X1_ORDEM == "GPEM020   05"
			RecLock("SX1",.F.)
			DbDelete()
			SX1->(MsUnlock())
			Exit
		EndIf
		SX1->(DbSkip())
	Enddo

	RestArea(aArea)
Return Nil


/*/{Protheus.doc} fCodFolEmp()
- Carrega Array com Verbas da empresa
@author: Paulo.Inzonha
@since:  28/11/2017
/*/
Static Function fCodFolEmp(aSRV)
	Local cAliasTst := GetNextAlias()

	BeginSql alias cAliasTst
		SELECT SRV.RV_FILIAL, SRV.RV_CODFOL
		FROM %table:SRV% SRV
		WHERE SRV.RV_CODFOL in ('0040','0041','0042','0072','0103','0891','0927') AND SRV.%notDel%
	endSql

	while ( (cAliasTst)->(!Eof()) )
		aAdd(aSRV,{(cAliasTst)->RV_FILIAL,(cAliasTst)->RV_CODFOL})
		(cAliasTst)->(dbSkip())
	EndDo

	(cAliasTst)->(DbCloseArea())
Return


/*/{Protheus.doc} fTamNumID()
- Verifica se o tamanho do campo RK_NUMID é menor que o mínimo necessário para a composição da chave.
@author: Paulo.Inzonha
@since:  21/11/2017
/*/
Static Function fTamNumID(ALogFil)
	Local lRet		:= .T.
	Local nTamID := GetSx3Cache( "RK_NUMID" , "X3_TAMANHO" )
	Local nTamTot:= GetSx3Cache( "RK_FILIAL" , "X3_TAMANHO" ) + GetSx3Cache( "RK_MAT" , "X3_TAMANHO" ) + GetSx3Cache( "RK_DOCUMENT" , "X3_TAMANHO" )

	nTamTot := nTamTot + 6 //("SRK" + Código da verba)

	If nTamTot > nTamID
		aAdd(ALogFil,"")
		aAdd(ALogFil,STR0100)//"O tamanho do campo RK_NUMID é menor que o mínimo necessário para a composição da chave."
		aAdd(ALogFil,STR0101 + AllTrim(Str(nTamTot)) + STR0102)  //"Os seguintes campos deverão ter o tamanho alterado para " + AllTrim(Str(nTamTot)) + " através do configurador antes da conversão dos valores futuros."
		aAdd(ALogFil,"R8_NUMID, RC_NUMID, RD_NUMID, RK_NUMID, RR_NUMID, RCK_NUMID, RG1_NUMID, RGB_NUMID, RGE_NUMID")
		lRet := .F.
	EndIf
Return lRet


/*/{Protheus.doc} fVerCompPer()
- Verifica o compartilhamento das tabelas de período é igual
@author: Paulo.Inzonha
@since:  21/11/2017
/*/
Static Function fVerCompPer(aLogFil)
	Local cCompRCF	:= FWModeAccess("RCF",1) + FWModeAccess("RCF",2) + FWModeAccess("RCF",3)
	Local cCompRCG	:= FWModeAccess("RCG",1) + FWModeAccess("RCG",2) + FWModeAccess("RCG",3)
	Local cCompRCH	:= FWModeAccess("RCH",1) + FWModeAccess("RCH",2) + FWModeAccess("RCH",3)
	Local cCompRFQ	:= FWModeAccess("RFQ",1) + FWModeAccess("RFQ",2) + FWModeAccess("RFQ",3)
	Local lRet 		:= .F.

	if cCompRCF = cCompRCG
		if cCompRCG = cCompRCH
			if cCompRCH = cCompRFQ
				lRet := .T.
			endIf
		endIf
	endIf

	if !(lRet)
		aAdd(ALogFil,"")
		aAdd(ALogFil, STR0103 + cCompRCF, "RCG: " + cCompRCG, "RCH: " + cCompRCH, "RFQ: " + cCompRFQ) //" Compartilhamento diferente entre as tabelas tabelas RFC, RCG, RCH e RFQ","RCF: "
	endIf
Return lRet


/*/{Protheus.doc} fHistProc()
- Busca no log o processo já foi executado anteriormente
@author: Paulo.Inzonha
@since:  28/11/2017
/*/
Static Function fHistProc(cEmpProc, cFilProc, nProc)
	cRet := ""

	dbSetOrder(1)

	If (cDbfLog)->(DbSeek(Padr(cEmpProc,Len("M0_CODIGO")) + PadR(cFilProc,FWGETTAMFILIAL) + STRZERO(nProc,2)))
		cRet := DTOC((cDbfLog)->DATAI)
	EndIf
return cRet


Static Function ShowLog( cTitulo, aMemo )
	Local oDlg     := NIL
	Local oFont    := NIL
	Local oMemo    := NIL
	Local cMemo    := ""

	aEval( aMemo , { |X| cMemo += X + chr(13) + chr(10) } )

	DEFINE FONT oFont NAME "Courier New" SIZE 5,0
	DEFINE MSDIALOG oDlg TITLE cTitulo From 3,0 to 340,617 PIXEL

	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 300,145 READONLY OF oDlg PIXEL

	oMemo:oFont:=oFont

	DEFINE SBUTTON  FROM 153,280 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
	ACTIVATE MSDIALOG oDlg CENTER
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvPER   ºAutor  ³Leandro Drumond     º Data ³  13/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conversão dos Periodos.                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConvPER()
	Local aRot			:= {"FPB","060","070", "170","213",'113',"RPB","240","250","450", "Z10" }
	Local c13p1			:= "113"
	Local cPd113		:= fGetCodFol("0022")
	Local cPdPLR		:= fGetCodFol("0151")
	Local c13p2			:= "213"
	Local aProcesso		:= {}
	Local aSemana		:= {}
	Local cCompRCF		:= FWModeAccess("RCF",1) + FWModeAccess("RCF",2) + FWModeAccess("RCF",3)
	Local cCompRCG		:= FWModeAccess("RCG",1) + FWModeAccess("RCG",2) + FWModeAccess("RCG",3)
	Local cCompRCH		:= FWModeAccess("RCH",1) + FWModeAccess("RCH",2) + FWModeAccess("RCH",3)
	Local cCompRFQ		:= FWModeAccess("RFQ",1) + FWModeAccess("RFQ",2) + FWModeAccess("RFQ",3)
	Local cAliasTst		:= GetNextAlias()
	Local cAliasAux		:= GetNextAlias()
	Local cMsgPer		:= ""
	Local cMesAux		:= ""
	Local cAno			:= ""
	Local cMes			:= ""
	Local cPeriodo		:= ""
	Local cSemana		:= ""
	Local cSemAux		:= ""
	Local cDataAux		:= ""
	Local cKeyRCF		:= ""
	Local cTnoAux		:= ""
	Local cQuery		:= ""
	Local dDtPg 		:= CtoD("")
	Local dDataPag		:= CtoD("")
	Local dDataIni		:= CtoD("")
	Local dDataFim		:= CtoD("")
	Local dDataAux		:= CtoD("")
	Local lAberto		:= .F.
	Local lRHImp		:= .F.
	Local nX			:= 0
	Local cRyInte		:= ""
	Local nY			:= 0
	Local nZ			:= 0
	Local nDiasPer		:= 0
	Local nDiaNoTr		:= 0
	Local nDiasTrab		:= 0
	Local nRet			:= 0
	Local aPeriod131 	:= {}
	Local aPeriodPLR 	:= {}
	Local cUltSem	 	:= "05"
	Local lTemRCF	 	:= .F.
	Local cQryPD		:= ""
	Local nLinha  		:= 0
	Local cRoteiro      := '   '
	Local cSemBran		:= "99"

	DBSELECTAREA("SRY")
	SRY->(DBSETORDER(1))
	RCH->(DbSetOrder(1)) //--RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR
	RCF->(DbSetOrder(RetOrder("RCF","RCF_FILIAL+RCF_PER+RCF_SEMANA+RCF_ANO+RCF_MES+RCF_PROCES+RCF_ROTEIR+RCF_TNOTRA+DTOS(RCF_DTINI)+DTOS(RCF_DTFIM)+RCF_MODULO")))
	RFQ->( DbSetOrder(1) )
	//=============================
	//ANALISE DE COMPARTILHAMENTO
	//=============================
	If  ( cCompRCF <> cCompRCG .OR. cCompRCF <> cCompRCH .OR. cCompRCF <> cCompRFQ ) .OR.;
		( cCompRCG <> cCompRCH .OR. cCompRCG <> cCompRFQ )  .OR.;
		( cCompRCH <> cCompRFQ )
		cMsgPer += STR0011 + chr(10)+chr(13) //"Inconsistencia na compartilhamento de tabelas abaixo:"
		cMsgPer += STR0012 + chr(13) //"Tabela            Empresa        Unid. Neg.        Filial "
		cMsgPer += RetSqlName( "RCF" )+"            "+FWModeAccess("RCF",1)+"                     "+FWModeAccess("RCF",2)+"                    "+FWModeAccess("RCF",3)+chr(13)
		cMsgPer += RetSqlName( "RCG" )+"            "+FWModeAccess("RCG",1)+"                     "+FWModeAccess("RCG",2)+"                    "+FWModeAccess("RCG",3)+chr(13)
		cMsgPer += RetSqlName( "RCH" )+"            "+FWModeAccess("RCH",1)+"                     "+FWModeAccess("RCH",2)+"                    "+FWModeAccess("RCH",3)+chr(13)
		cMsgPer += RetSqlName( "RFQ" )+"            "+FWModeAccess("RFQ",1)+"                     "+FWModeAccess("RCQ",2)+"                    "+FWModeAccess("RFQ",3)+chr(13)
			Alert(cMsgPer)
			Return(.F.)
	EndIf

	If Empty(cAnoMes)
		cAnoMes := SuperGetMv("MV_FOLMES",,Substr( Dtos(dDatabase) , 1, 6))
		If Empty(cAnoMes)
			cAnoMes := Substr( Dtos(dDatabase) , 1, 6)
		Endif
	EndIf

	// BUSCA DOS DADOS DE 13
	BeginSql alias cAliasTst
		SELECT COUNT(*) TOTALREG
		FROM %table:SRA% SRA
			WHERE SRA.RA_PERCADT > 0 AND
			SRA.%notDel%
	EndSql

	If (cAliasTst)->TOTALREG > 0
		aAdd(aRot,"ADI") //--Inclui roteiro de adiantamento para geracao
	EndIf

	(cAliasTst)->(DbCloseArea())

	//BUSCA PRIMEIRA PARCEIRA DO 13 e PLR
	cQryPD:= "%'"+cPdPLR+"','"+cPd113+"'%"

	BeginSql alias cAliasTst
		SELECT DISTINCT RD_DATARQ,RD_PD
		FROM %table:SRD% SRD
		WHERE RD_PD IN (%exp:cQryPD%)
		AND	SRD.%notDel%
	EndSql

	While ( (cAliasTst)->(!Eof()) )
		If cPdPLR == (cAliasTst)->RD_PD
			aAdd(aPeriodPLR,(cAliasTst)->RD_PERIODO)
		EndIf

		If cPd113 == (cAliasTst)->RD_PD
			aAdd(aPeriod131,(cAliasTst)->RD_PERIODO	)
		EndIf

		(cAliasTst)->(dbSkip())
	EndDo

	(cAliasTst)->(DbCloseArea())

	If Len(aPeriod131) > 0
		aAdd(aRot,c13p1)
	EndIf

	If Len(aPeriodPLR) > 0
		aAdd(aRot,"PLR")
	EndIf

	//BUSCA OS PROCESSOS UTILIZADOS NOS FUNCIONÁRIOS
	BeginSql alias cAliasTst
		SELECT DISTINCT(RA_PROCES)
		FROM %table:SRA% SRA
		WHERE SRA.%notDel%
	EndSql

	While (cAliasTst)->(!Eof())
		If !Empty((cAliasTst)->RA_PROCES)
			aAdd(aProcesso,(cAliasTst)->RA_PROCES)
		EndIf
		(cAliasTst)->(DbSkip())
	EndDo


	(cAliasTst)->(DbCloseArea())

	//BUSCA O HISTÓRICO DE MOVIMENTO
	BeginSql alias cAliasTst
		SELECT DISTINCT(RD_PERIODO) AS RD_PERIODO, RD_SEMANA, RD_ROTEIR, RD_FILIAL
		FROM %table:SRD% SRD
		WHERE SRD.%notDel%
		ORDER BY RD_PERIODO, RD_SEMANA, RD_ROTEIR
	EndSql

	While (cAliasTst)->(!Eof())
		If  !Empty(AllTrim(xFilial("RCH"))) .Or. Empty((cAliasTst)->RD_PERIODO)
			(cAliasTst)->(DbSkip())
			cPeriodo := ""
			Loop
		EndIf

		cMesAux := SubStr((cAliasTst)->RD_PERIODO,5,2)

		If cMesAux == "13"
			cMes := "12"
			cPeriodo := ""
		Else
			cMes := cMesAux
		EndIf

		cAno := SubStr((cAliasTst)->RD_PERIODO,1,4)
		cSemAux  :=  (cAliasTst)->RD_SEMANA

		If !Empty(cPeriodo)
			If cPeriodo == cAno+cMes .and. cSemana == cSemAux .And. ( Empty(xFilial("RCH")) .or. AllTrim(xFilial("RCH")) $ (cAliasTst)->RD_FILIAL )
				(cAliasTst)->(DbSkip())
				Loop
			EndIf
		EndIf

		cPeriodo := cAno+cMes

		cRoteiro := (cAliasTst)->RD_ROTEIR

		If Empty((cAliasTst)->RD_ROTEIR)
			(cAliasTst)->(DbSkip())
			cRoteiro := ""
			Loop
		Endif

		BeginSql alias cAliasAux
			column RD_DATPGT AS Date
			SELECT RD_DATPGT
			FROM %table:SRD% SRD
			WHERE RD_PERIODO = %exp:(cAliasTst)->RD_PERIODO% AND
				RD_FILIAL = %exp:(cAliasTst)->RD_FILIAL% AND
				SRD.%notDel%
		EndSql

		If (cAliasAux)->(Eof())
			dDataPag := StoD(cPeriodo+STRZERO(F_ULTDIA(StoD(cPeriodo+"01")),2))
		Else
			dDataPag := (cAliasAux)->RD_DATPGT
		EndIf

		(cAliasAux)->(DbCloseArea())

		//ATUALIZARÁ RCF COM OS DADOS DE DTINI E DTFIM     // Mudar de posição, nao faz nada

		RCF->(DbSetOrder(RetOrder("RCF","RCF_FILIAL+RCF_PER+RCF_SEMANA+RCF_ANO+RCF_MES+RCF_PROCES+RCF_ROTEIR+RCF_TNOTRA+DTOS(RCF_DTINI)+DTOS(RCF_DTFIM)+RCF_MODULO")))

		For nY := 1 to Len(aProcesso)
			dDataIni := StoD(cAno+cMes+"01")
			dDataAux := dDataIni
			nDiasPer := F_ULTDIA(dDataIni)

			dDataFim := dDataAux + nDiasPer - 1
			cSemana  := cSemAux

			If Len(aSemana) == 1
				dDtPg := dDataPag
			Else
				dDtPg := dDataFim
			EndIf

			nDiaTrab := DateWorkDay(dDataAux,dDataFim)
			nDiaNoTr := ( dDataFim - dDataAux + 1 ) - nDiaTrab

			If cPeriodo >= cAnoMes
				lAberto := .T.
			Else
				lAberto := .F.
			EndIf

			//Atualiza registros pre-existentes na RCF
			If RCF->(DbSeek(xFilial("RCF")+Space(Len(cPeriodo))+cSemana+cAno+cMes+Space(Len(aProcesso[nY]))+Space(3)))

				While .T.
					nRecRCF := RCF->(Recno())
					If Empty(RCF->RCF_TNOTRA)
						cTnoAux := "@@@"
					Else
						cTnoAux := RCF->RCF_TNOTRA
					EndIf

					If !RCF->(DbSeek(xFilial("RCF")+cPeriodo+cSemana+cAno+cMes+aProcesso[nY]+Space(3)+cTnoAux))
						RCF->(DbGoTO(nRecRCF))
						RecLock("RCF",.F.)
						RCF->RCF_PER	:= cPeriodo
						RCF->RCF_PROCES	:= aProcesso[nY]
						RCF->RCF_SEMANA	:= cSemana
						RCF->RCF_TNOTRA	:= cTnoAux
						RCF->RCF_DCALCM	:= dDataFim - dDataAux + 1
						RCF->RCF_DPERIO	:= dDataFim - dDataAux + 1
						RCF->RCF_HRSDIA	:= 8
						RCF->RCF_DIADSR	:= nDiaNoTr / 2
						RCF->RCF_DUTEIS	:= RCF->RCF_DPERIO - RCF->RCF_DIADSR
						RCF->RCF_HRSDSR	:= ( nDiaNoTr / 2 ) * 8
						RCF->RCF_DIATRA	:= nDiaTrab
						RCF->RCF_HRSTRA	:= nDiasTrab * 8
						RCF->RCF_DNTRAB	:= nDiaNoTr / 2
						RCF->RCF_DUTILT	:= nDiaTrab
						RCF->RCF_DREFEI	:= nDiaTrab
						RCF->RCF_DALIM	:= nDiaTrab
						RCF->RCF_MODULO	:= "GFP"
						RCF->( MsUnLock() )

						If !RCF->(DbSeek(xFilial("RCF")+Space(Len(cPeriodo))+cSemana+cAno+cMes+Space(Len(aProcesso[nY]))+Space(3))) //Se existir mais registros sem conversão, continua no looping
							Exit
						EndIf
					Else
						RCF->(DbSkip())
						Exit
					EndIf
				EndDo
			ElseIf !RCF->(DbSeek(xFilial("RCF")+cPeriodo+cSemana+cAno+cMes+aProcesso[nY]+Space(3)+"@@@"))
				RecLock("RCF",.T.)

				RCF->RCF_FILIAL	:= xFilial("RCF")
				RCF->RCF_MES   	:= cMes
				RCF->RCF_ANO   	:= cAno
				RCF->RCF_PER	:= cPeriodo
				RCF->RCF_PROCES	:= aProcesso[nY]
				RCF->RCF_TNOTRA	:= "@@@"
				RCF->RCF_SEMANA	:= cSemana
				RCF->RCF_DTINI 	:= dDataAux
				RCF->RCF_DTFIM 	:= dDataFim
				RCF->RCF_DCALCM	:= dDataFim - dDataAux + 1
				RCF->RCF_DPERIO	:= dDataFim - dDataAux + 1
				RCF->RCF_HRSDIA	:= 8
				RCF->RCF_DIADSR	:= nDiaNoTr / 2
				RCF->RCF_DUTEIS	:= RCF->RCF_DPERIO - RCF->RCF_DIADSR
				RCF->RCF_HRSDSR	:= ( nDiaNoTr / 2 ) * 8
				RCF->RCF_DIATRA	:= nDiaTrab
				RCF->RCF_HRSTRA	:= nDiasTrab * 8
				RCF->RCF_DNTRAB	:= nDiaNoTr / 2
				RCF->RCF_DUTILT	:= nDiaTrab
				RCF->RCF_DREFEI	:= nDiaTrab
				RCF->RCF_DALIM	:= nDiaTrab
				RCF->RCF_MODULO	:= "GFP"
				RCF->( MsUnLock() )
			EndIf

			If cPeriodo >= cAnoMes
				lAberto := .T.
			Else
				lAberto := .F.
			EndIf

			RFQ->( DbSetOrder(1) )
			If !RFQ->( DbSeek( xFilial("RFQ")+aProcesso[nY]+cPeriodo+cSemana+DtoS(RCF->RCF_DTINI)+Dtos(RCF->RCF_DTFIM)+"GFP" ) )

				RecLock("RFQ",.T.)
				RFQ->RFQ_FILIAL	:= xFilial("RFQ")
				RFQ->RFQ_PROCES	:= aProcesso[nY]
				RFQ->RFQ_MES   	:= cMes
				RFQ->RFQ_ANO   	:= cAno
				RFQ->RFQ_PERIOD	:= cPeriodo
				RFQ->RFQ_NUMPAG	:= cSemana
				RFQ->RFQ_DTINI 	:= RCF->RCF_DTINI
				RFQ->RFQ_DTFIM 	:= RCF->RCF_DTFIM
				RFQ->RFQ_STATUS := If(lAberto,"1","2")
				RFQ->RFQ_MODULO	:= "GFP"
				RFQ->( MsUnLock() )
			ElseIf lAberto .and. RFQ->RFQ_STATUS <> '1'
				RecLock("RFQ",.F.)
				RFQ->RFQ_STATUS := "1"
				RFQ->( MsUnLock() )
			EndIf

			RCH->(DbSetOrder(RetOrder("RCH","RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR")))
			If !(RCH->(DbSeek(xFilial("RCH")+aProcesso[nY]+cPeriodo+cSemana+cRoteiro)))
				RecLock("RCH",.T.)
				RCH->RCH_FILIAL	:= xFilial("RCH")
				RCH->RCH_PER	:= cPeriodo
				RCH->RCH_NUMPAG	:= cSemana
				RCH->RCH_PROCES	:= aProcesso[nY]
				RCH->RCH_ROTEIR	:= cRoteiro
				RCH->RCH_MES   	:= cMes
				RCH->RCH_ANO   	:= cAno
				RCH->RCH_DTINI 	:= RCF->RCF_DTINI
				RCH->RCH_DTFIM 	:= RCF->RCF_DTFIM
				RCH->RCH_DTPAGO	:= dDtPg
				RCH->RCH_DTINTE := If(cRoteiro $ 'RES|RPB',RCF->RCF_DTINI, CtoD(""))
				RCH->RCH_DTCORT	:= RCF->RCF_DTINI
				RCH->RCH_DTFECH	:= If(lAberto,CtoD(""),RCF->RCF_DTINI)
				RCH->RCH_PERSEL	:= "2"
				RCH->RCH_STATUS	:= If(lAberto,"0","5")
				RCH->RCH_MODULO	:= "GFP"
				RCH->RCH_COMPL	:= "2"
				RCH->( MsUnLock() )
			EndIf

			If !lTemRCF
				dDataAux := RCF->RCF_DTINI + 1
			EndIf
		Next nX
		(cAliasTst)->(DbSkip())
	EndDo

	RCH->( dbGotop())
	RCF->( dbGotop())
	RFQ->( dbGotop())

	While !RCF->(EOF())
		If Empty(RCF->RCF_DTINI)
			If RCH->( DbSeek(xFilial("RCH")+RCF->RCF_PROCES+RCF->RCF_PER+RCF->RCF_SEMANA))
				RecLock("RCF",.F.)
				RCF->RCF_DTINI	:= RCH->RCH_DTINI
				RCF->RCF_DTFIM	:= RCH->RCH_DTFIM
				RCF->RCF_MODULO	:= "GFP"
				RCF->(MSUNLOCK())
			EndIf
		Endif

		If RCF->RCF_PER  >= cAnoMes
			lAberto := .T.
		Else
			lAberto := .F.
		EndIf

		RFQ->( DbSetOrder(1) )
		If !RFQ->( DbSeek( xFilial("RFQ")+RCF->RCF_PROCES+RCF->RCF_PER+RCF->RCF_SEMANA+DtoS(RCF->RCF_DTINI)+Dtos(RCF->RCF_DTFIM)+"GFP" ) )
			RecLock("RFQ",.T.)
			RFQ->RFQ_FILIAL	:= xFilial("RFQ")
			RFQ->RFQ_PROCES	:= RCF->RCF_PROCES
			RFQ->RFQ_MES   	:= RCF->RCF_MES
			RFQ->RFQ_ANO   	:= RCF->RCF_ANO
			RFQ->RFQ_PERIOD	:= RCF->RCF_PER
			RFQ->RFQ_NUMPAG	:= RCF->RCF_SEMANA
			RFQ->RFQ_DTINI 	:= RCF->RCF_DTINI
			RFQ->RFQ_DTFIM 	:= RCF->RCF_DTFIM
			RFQ->RFQ_STATUS := If(lAberto,"1","2")
			RFQ->RFQ_MODULO	:= "GFP"
			RFQ->( MsUnLock() )
		ElseIf lAberto .and. RFQ->RFQ_STATUS <> '1'
			RecLock("RFQ",.F.)
			RFQ->RFQ_STATUS := "1"
			RFQ->( MsUnLock() )
		EndIf
		RCF->( DBSKIP())
	Enddo

	RCH->( dbGotop())

	While !RCH->(Eof())
		If 	(Empty(RCH->RCH_STATUS) .Or. Empty(RCH->RCH_DTFECH).Or. Empty(RCH->RCH_DTINTE) .Or. Empty(RCH->RCH_COMPL)) .And. (RCH->RCH_PER) < cAnoMes
			RecLock("RCH",.F.)
			If Empty(RCH->RCH_STATUS)
				RCH->RCH_STATUS	:= "5"
			Endif
			If Empty(RCH->RCH_DTFECH)
				RCH->RCH_DTFECH	:= RCH->RCH_DTFIM
			Endif
			If Empty(RCH->RCH_DTINTE) .And. (RCH->RCH_ROTEIR) $ 'RES|RPB'
				RCH->RCH_DTINTE	:= RCH->RCH_DTINI
			Endif
			RCH->RCH_PERSEL	:= "2"
			RCH->RCH_COMPL	:= "2"
			RCH->( MsUnLock() )
		Endif
		RCH->( DBSKIP())
	Enddo


	DbSelectArea("RCG")

	RCF->(DbSetOrder(1)) //RCF_FILIAL+RCF_ANO+RCF_MES+RCF_TNOTRA+RCF_SEMANA
	RCG->(DbSetOrder(1)) //RCG_FILIAL+RCG_ANO+RCG_MES+RCG_TNOTRA+RCG_SEMANA
	RCG->(DbSeek(xFilial("RCG")))

	cAliasAux := GetNextAlias()

	BeginSql alias cAliasAux
		SELECT *
		FROM %table:RCG% RCG
		WHERE (RCG.RCG_PROCES = '' OR (RCG.RCG_DTINI ='' AND RCG.RCG_DTFIM =''))
		AND RCG.%notDel%
		AND RCG.RCG_FILIAL = %exp:xFilial("RCG")%
		ORDER BY RCG.RCG_FILIAL,RCG.RCG_ANO,RCG.RCG_MES,RCG.RCG_TNOTRA,RCG.RCG_SEMANA
	EndSql

	While !(cAliasAux)->(eof())
		If Empty((cAliasAux)->RCG_PROCES) .OR. (cAliasAux)->RCG_PROCES == '50000'
			cTnoAux := If(Empty((cAliasAux)->RCG_TNOTRA),"@@@",(cAliasAux)->RCG_TNOTRA)
			If Empty((cAliasAux)->RCG_SEMANA)
				cKeyRCF := (cAliasAux)->RCG_FILIAL+(cAliasAux)->RCG_ANO+(cAliasAux)->RCG_MES+cTnoAux+"01"
			Else
				cKeyRCF := (cAliasAux)->RCG_FILIAL+(cAliasAux)->RCG_ANO+(cAliasAux)->RCG_MES+cTnoAux+(cAliasAux)->RCG_SEMANA
			EndIf

			If RCF->(DbSeek(cKeyRCF))
				While RCF->(!Eof() .and. RCF_FILIAL + RCF_ANO + RCF_MES + RCF_TNOTRA + RCF_SEMANA == cKeyRCF)
					If Empty(RCF->RCF_PROCES) .or. Empty(RCF->RCF_PER)
						RCF->(DbSkip())
						Loop
					EndIf

					If (( Empty((cAliasAux)->RCG_SEMANA) .and. (RCF->RCF_PROCES $ '50000') ) .or. ( !Empty((cAliasAux)->RCG_SEMANA) .and. !(RCF->RCF_PROCES $ '50000') )) .And. Empty((cAliasAux)->RCG_PROCES)
						cQuery := " UPDATE " + RetSqlName( "RCG" ) + " SET RCG_PROCES = '" + RCF->RCF_PROCES + "', "
						cQuery += 														 " RCG_PER = '" + RCF->RCF_PER + "', "
						cQuery += 														 " RCG_SEMANA = '" + RCF->RCF_SEMANA +"',  "
						cQuery += 														 " RCG_TNOTRA = '" + cTnoAux + "', "
						cQuery += 														 " RCG_MODULO = 'GFP', "
						cQuery += 														 " RCG_DTINI = '" + DtoS(RCF->RCF_DTINI) + "', "
						cQuery += 														 " RCG_DTFIM = '" + DtoS(RCF->RCF_DTFIM) + "' "
						ElseIf Empty((cAliasAux)->RCG_DTINI) .OR. Empty((cAliasAux)->RCG_DTFIM)
							cQuery := " UPDATE " + RetSqlName( "RCG" ) + " SET "
						cQuery += 														 " RCG_DTINI = '" + DtoS(RCF->RCF_DTINI) + "', "
						cQuery += 														 " RCG_DTFIM = '" + DtoS(RCF->RCF_DTFIM) + "' "
					EndIf

					If !Empty(cQuery)
						cQuery += " WHERE RCG_FILIAL = '" + (cAliasAux)->RCG_FILIAL + "' AND "
						cQuery += " RCG_ANO = '" + (cAliasAux)->RCG_ANO + "' AND "
						cQuery += " RCG_MES = '" + (cAliasAux)->RCG_MES + "' AND "
						cQuery += " RCG_SEMANA = '" + (cAliasAux)->RCG_SEMANA + "' AND "
						cQuery += " RCG_PROCES = '" + (cAliasAux)->RCG_PROCES + "' AND "
						cQuery += " RCG_TNOTRA = '" + (cAliasAux)->RCG_TNOTRA + "' "

						nRet := TCSQLEXEC(cQuery)

							If nRet != 0
								UserException( TCSqlError() )
							EndIf
						Exit
					EndIf
					RCF->(DbSkip())
				EndDo
			EndIf
		EndIf
		(cAliasAux)->(DbSkip())
	EndDo

	(cAliasAux)->(dbCloseArea())

Return .T.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fMntColsMark³ Autor ³ Leandro Drumond       ³ Data ³ 11/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta dados dos campos da tabela temporaria                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMntColsMark()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fMntColsMark(aNewPD, aCodFol)
	Local aRet	 := {}
	Local cPdAux := ""
	Local nX	 := 0

	For nX := 1 to Len(aNewPD)
		If !Empty(aNewPD[nX,3])
			cPdAux := aCodFol[Val(aNewPD[nX,3]),1]
			If !Empty(cPdAux)
				aAdd( aRet , {aNewPD[nX,2] , aNewPD[nX,1] , aNewPD[nX,4], cPdAux, Fdesc("SRV", cPdAux, "RV_DESC") , .F.})
			EndIf
		EndIf
	Next nX
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCriaVerbas ºAutor  ³Leandro Drumond   º Data ³  11/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria verbas que novas (P12).				                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCriaVerbas(aCodFol,cFilSRV)
	Local aArea		:= GetArea()
	Local aVarAux	:= {}
	Local aStruct	:= {}
	Local aNewPD 	:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local nOpcA		:= 0
	Local nTamAux	:= 0
	Local cVarAux	:= "001"
	Local cQuery	:= ""
	Local cAliasSRV	:= ""
	Local oSize 	:= FwDefSize():New( .T.,,300,600 )

	fp_CodFol( aCodFol , xFilial("SRV"), .F., .F. )

	nTamAux	:= Len(aCodFol)

	For nX := 1279 to nTamAux
		If Empty(aCodFol[nX,1])
			aAdd( aNewPD, { StrZero(nX,4) , "" , "" , aCodFol[nX,2] } )
		EndIf
	Next nX

	If Empty(aCodFol[678,1])
		aAdd( aNewPD, { "0678" , "" , "" , aCodFol[678,2] } )
	EndIf
	If Empty(aCodFol[546,1])
		aAdd( aNewPD, { "0546" , "" , "" , aCodFol[546,2] } )
	EndIf
	If Empty(aCodFol[835,1])
		aAdd( aNewPD, { "0835" , "" , "" , aCodFol[835,2] } )
	EndIf
	If Empty(aCodFol[836,1])
		aAdd( aNewPD, { "0836" , "" , "" , aCodFol[836,2] } )
		EndIf
	If Empty(aCodFol[633,1])
		aAdd( aNewPD, { "0633" , "" , "" , aCodFol[633,2] } )
	EndIf
	If Empty(aCodFol[634,1])
		aAdd( aNewPD, { "0634" , "" , "" , aCodFol[634,2] } )
	EndIf
	If Empty(aCodFol[622,1])
		aAdd( aNewPD, { "0622" , "" , "" , aCodFol[622,2] } )
	EndIf
	If Empty(aCodFol[623,1])
		aAdd( aNewPD, { "0623" , "" , "" , aCodFol[623,2] } )
	EndIf
	If Empty(aCodFol[205,1])
		aAdd( aNewPD, { "0205" , "" , "" , aCodFol[205,2] } )
	EndIf
	If Empty(aCodFol[206,1])
		aAdd( aNewPD, { "0206" , "" , "" , aCodFol[206,2] } )
	EndIf
	If Empty(aCodFol[207,1])
		aAdd( aNewPD, { "0207" , "" , "" , aCodFol[207,2] } )
	EndIf
	If Empty(aCodFol[208,1])
		aAdd( aNewPD, { "0208" , "" , "" , aCodFol[208,2] } )
	EndIf
	If Empty(aCodFol[40,1])
		aAdd( aNewPD, { "0040" , "" , "" , aCodFol[40,2] } )
	EndIf
	If Empty(aCodFol[41,1])
		aAdd( aNewPD, { "0041" , "" , "" , aCodFol[41,2] } )
	EndIf
	If Empty(aCodFol[42,1])
		aAdd( aNewPD, { "0042" , "" , "" , aCodFol[42,2] } )
	EndIf
	If Empty(aCodFol[103,1])
		aAdd( aNewPD, { "0103" , "" , "" , aCodFol[103,2] } )
	EndIf

	If !Empty(aNewPD)
		DbSelectArea("SRV")
		DbSetOrder(1)

		SRV->(DbSeek(cFilSrv))

		While SRV->(!Eof() .and. RV_FILIAL == cFilSRV)
			aAdd(aVarAux,SRV->RV_COD)
			SRV->(DbSkip())
		EndDo

		nTamAux := Len(aNewPD)

		FOR nX := 1 TO nTamAux

		NEXT nX


		For nX := 1 to nTamAux
			If aNewPd[nX,1] == "1415"
				aNewPD[nX,3] := "0116"
			ElseIf aNewPd[nX,1] $ "1416*1417"
				aNewPD[nX,3] := "0096"
			ElseIf aNewPd[nX,1] $ "1418*1419"
				aNewPD[nX,3] := "0097"

			// Novas Verbas RPPS
			ElseIf aNewPd[nX,1] $ "1662"
				aNewPD[nX,3] := "0013"
			ElseIf aNewPd[nX,1] $ "1663"
				aNewPD[nX,3] := "0019"
			ElseIf aNewPd[nX,1] $ "1664"
				aNewPD[nX,3] := "0013"
			ElseIf aNewPd[nX,1] $ "1665"
				aNewPD[nX,3] := "0065"
			EndIf
		Next nX

		nX := 1

		While .T.
			If aScan( aVarAux , cVarAux ) == 0
				While .T.
					If !Empty(aNewPD[nX,3])
						aNewPd[nx,2] := cVarAux
						Exit
					Else
						nX++
					EndIf
					If nX > nTamAux
						Exit
					EndIf
				EndDo
				nX++
			EndIf

			cVarAux := Soma1(cVarAux)

			If nX > nTamAux
				Exit
			EndIf
		EndDo

		aSort( aNewPD ,,, { |x,y| x[1] < y[1] } )
		aColsSRV   := fMntColsMark(aNewPD, aCodFol)

		If !Empty(aColsSRV)
			oSize:AddObject( "GETDADOS",100, 100, .T., .T. )
			oSize:lLateral     := .F.
			oSize:Process() // Dispara os calculos

			Define MsDialog oDlg Title STR0015 FROM 20,0 TO 486,1009 Pixel //"Informe os códigos das verbas que devem ser criadas"
				aHeaderSRV := {}

				aAdd( aHeaderSRV , { STR0016 , "TAB_PD", "@!", 3, 0, "fVldSRVConv(.T.)" , ,"C","SRV", }) //"Verba"
				aAdd( aHeaderSRV , { STR0017 , "TAB_CODFOL", "@!", 4, 0, ".F." , ,"C",, })				//"ID. Calculo"
				aAdd( aHeaderSRV , { STR0018 , "TAB_DESC", "@!", 20, 0, ".T." , ,"C",, })				//"Descrição"
				aAdd( aHeaderSRV , { STR0025 , "TAB_PDM", "@!", 3, 0, "fVldSRVConv(.F.)" , ,"C",, })	//"Mod. Verba"
				aAdd( aHeaderSRV , { STR0018 , "TAB_DESCM", "@!", 20, 0, ".T." , ,"C",, })				//"Descrição"

				oGetSRV := MsNewGetDados():New( 33	,;	// 1  nTop
												3								,;  // 2  nLelft
												220								,;	// 3  nBottom
												493					    		,;	// 4  nRright
												GD_UPDATE			 			,;  // 5  Controle do que podera ser realizado na GetDado - nstyle
												.T.								,;	// 6  Funcao para validar a edicao da linha - ulinhaOK
												.T.								,;	// 7  Funcao para validar todas os registros da GetDados - uTudoOK
												Nil								,;	// 8  cIniCPOS
												{"TAB_PD","TAB_DESC","TAB_PDM"}	,;	// 9  aAlter
												0			  					,; 	// 10 nfreeze
												99999							,;  // 11 nMax
												Nil								,;	// 12 cFieldOK
												Nil								,;	// 13 usuperdel
												Nil								,;	// 14 udelOK
												@oDlg							,; 	// 15 Objeto de dialogo - oWnd
												@aHeaderSRV    					,;	// 16 Vetor com Colunas - AparHeader
												@aColsSRV 	    				)	// 17 Vetor com Header - AparCols

					bSet15 := { || nOpcA := 1 , aColsSRV := oGetSRV:aCols, oDlg:End()}
					bSet24 := { || nOpcA := 0 , If(fVldCancel(oGetSRV:aCols,aCodFol), oDlg:End(),) }
			Activate MsDialog oDlg Centered ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )
		EndIf

		If nOpcA == 1

			DbSelectArea("SRV")
			DbSetOrder(1)

			cVarAux 	:= "!!!!"
			aStruct 	:= SRV->(DbStruct())
			cAliasSRV 	:= "QSRV"
			nTamAux		:= Len(aColsSRV)

			If nTamAux > 0 .and. Type("aTitle") == "A"
				aAdd(aTitle, STR0019 ) //"Novas verbas criadas durante a execução da conversão."
				aAdd( aLogErr,{} )
				aAdd( aLogErr[Len(aLogErr)], Padr(STR0020,12) + Padr(STR0021,8) + Padr(STR0022,15) + Padr(STR0023,50) ) //"Filial" ###"Verba"###"Identificador"###"Descrição"
			EndIf

			aSort( aColsSRV ,,, { |x,y| x[4] < y[4] } )

			For nX := 1 to nTamAux
				If Empty(aColsSRV[nX,1]) .or. Empty(aColsSRV[nX,4]) .or. aColsSRV[nX,6]
					Loop
				EndIf

				If cVarAux <> aColsSRV[nX,4]
					cVarAux := aColsSRV[nX,4]
					cQuery := "SELECT * FROM " + RetSqlName("SRV") + " WHERE RV_FILIAL = '" + cFilSRV + "' AND RV_COD = '" + cVarAux + "' "

					cQuery := ChangeQuery( cQuery )

					If Select(cAliasSRV) > 0
						(cAliasSRV)->( dbCloseArea() )
					EndIf

					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSRV, .F., .T.)

					For nY := 1 To Len(aStruct)
						If ( aStruct[nY][2] <> "C" )
							TcSetField(cAliasSRV,aStruct[nY][1],aStruct[nY][2],aStruct[nY][3],aStruct[nY][4])
						EndIf
					Next nY
				EndIf

				If SRV->(DbSeek(cFilSRV+aColsSRV[nX,1]))
					RecLock("SRV",.F.)
					SRV->RV_CODFOL := aColsSRV[nX,2]
				Else

					RecLock("SRV",.T.)

					For nY := 1 to Len(aStruct)
						SRV->&( aStruct[nY,1] ) := (cAliasSRV)->&( aStruct[nY,1] )
					Next nY

					SRV->RV_FILIAL	:= cFilSRV
					SRV->RV_COD 	:= aColsSRV[nX,1]
					SRV->RV_CODFOL 	:= aColsSRV[nX,2]
					SRV->RV_DESC	:= UPPER(aColsSRV[nX,3])
					SRV->RV_DESCDET	:= UPPER(aColsSRV[nX,3])
				EndIf

				SRV->(MsUnLock())

				If Type("aTitle") == "A"
					aAdd( aLogErr[Len(aLogErr)], Padr(cFilSRV,12) + Padr(aColsSRV[nX,1],8) + Padr(aColsSRV[nX,2],15) + Padr(SRV->RV_DESC,50) )
				EndIf

			Next nX

			If Select(cAliasSRV) > 0
				(cAliasSRV)->( dbCloseArea() )
			EndIf

		EndIf

		aCodFol := {} //zera variavel para carregar novamente
		//aLogErr := {}
		RstaCodFol()
	EndIf

	RestArea(aArea)
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVldCancel |Autor  ³ Leandro Drumond	    ³ Data ³ 30/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida cancelamento da criacao de ferias.		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fVldCancel(aCols,aCodFol)
	Local lRet	:= .T.
	Local nX	:= 0
	Local nPos	:= 0

	For nX := 1 to Len(aCols)
		nPos := aScan(aCodFol[Val(aCols[nX,2]),4], { |X| X == "BRA*" .OR. X == "ALL*"})
		If nPos > 0
			If MsgYesNo( STR0098 + STR0097 ) //Existem verbas obrigatorias que nao foram cadastradas. Fechar abortará o processo de conversão. Deseja Continuar ?
				lRet := .T.
			Else
				lRet := .F.
			EndIf

			Exit
		EndIf
	Next nX
Return lRet


// Remove o elemento do Array se o ID da Verba for do E-Social
Static Function RemVerba(aArray)
	Local nX      := 1
	Local cAux    := ""
	Local aNewCod := {}

	IF !EMPTY(aArray)
		For nX := 1 To LEN(aArray)
			If !EMPTY(aArray[nX]) .AND. (VAL(SUBSTR(aArray[nX], 1, 4)) / 2) != 0
				cAux := SUBSTR(aArray[nX], 1, 4)

				If !( cAux $ "0123/0124/0625/1420/1432/1433/1434/1435/1436/1437/1438/1439/1440/1441/1442/1443/1444/1445/1446/1447/1449/1450/1451/1562/1628/1629/1630/1631/1632/1633/1634/1635/1636/1637/1639/1640/1641/1642/1643/1644/1645/1646/1647/1648")
					AADD(aNewCod, aArray[nX])
				Endif
			Endif
		Next nX
	Endif
Return aNewCod
