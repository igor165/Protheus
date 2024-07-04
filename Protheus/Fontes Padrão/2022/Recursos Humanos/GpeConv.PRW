#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
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

Main function GpeConv()
	Local aFields		:= {}
	Local cRdd			:= "DBFCDX"
	Local cPathSrv		:= GetSrvProfString("Startpath","")
	Local cArqNtx		:= ""
	Local nRecSM0		:= 0
	Local cArqLogIdx	:= ""
	Local lCriaIdx		:= .T.

	Private cNameFile	:= ""
	Private cNameLog	:= ""
	Private cDataDe		:= Space(6)
	Private cDataAte	:= Space(6)
	Private dPerIniDem	:= STOD("")
	Private oMsSelect 	:= Nil
	Private oWizard		:= Nil
	Private aParFil 	:= {}
	Private lPar01		:= .F.
	Private lPar02		:= .T.
	Private lPar04		:= .F.
	Private lPar05		:= .F.
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
	Private lNextPanel 	:= .T.
	Private cFilOk		:= ""
	Private cDbfFil		:= "CONV"
	Private cDbfLog		:= "CLOG"
	Private cMark		:= ""
	Private lAtuSRR		:= .F.
	Private lAtuRCC		:= .T.
	Private lPreConv	:= .F.

	DEFINE Window oMainWnd FROM 0, 0 TO 1, 1 TITLE STR0001 //"Efetuando Conversão de Base"

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

	cMark	:= GetMark()

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Verifica a Existencia de "\" ou "/" barras separadoras de diretorio  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
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
	aFields := {}
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
								{||.T.}									,;
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
	oWizard:NewPanel(	STR0065		,; //""
						STR0068,; //" "
						{||(MsOpenDbf( .T. , "TOPCONN" , cNameFile , cDbfFil , .T. , .F. , .F. , .F. ),.T.),dbClearind(),dbSetIndex( cNameFile+"1" )}					,; //<bBack>
						{|| iif(lPreConv,.T.,(Alert(STR0069),.F.))}					,; //<bNext>
						{||.F.}					,; //<bFinish>
						.T. 					,; //<.lPanel.>
						{|lEnd| GpPreCnvEx(@lEnd) }	)	   //<bExecute>


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 4 - Seleção das tabelas		                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(	OemToAnsi(STR0036)		,; //"Itens a Converter"
						OemToAnsi(STR0037)		,; //"Selecione as tabelas/itens que deverão ser convertidos"
						{||.T.}					,; //<bBack>
						{|| GpVldConv() }			  		,; //<bNext>
						{||.F.}					,; //<bFinish>
						.T. 					,; //<.lPanel.>
						{|| GetTabConv()}	)	   //<bExecute>


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 5 - Acompanhamento do Processo               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard:NewPanel(	OemToAnsi(STR0001)			,; //"Efetuando COnversão da Base"
						OemToAnsi(STR0038)			,; //"Aguarde o Final do Processamento"
						{||.F.}						,; //<bBack>
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
Local aRetcoords 	:= {}
Local aLogPreCnv	:= {}
Local nZ 			:= 0
Local nX 			:= 0
Local nPosAux		:= 0
Local lSRASRD		:= .T.
Local lSRAAdm		:= .T.
Local lSRHDuplic	:= .T.
Local lRHLibUpd		:= .T.
Local lTamR0		:= .T.
Local lTamNumID		:= .T.
Local lCompPer		:= .T.
Local cEmpAntAux	:= ""
Local lidentCalc	:= .T.
Local aVerbErr		:= {}
Local aCodFol 		:= {}
Local aSRV			:= {}
Local aIdCalObr		:= {"0040","0041","0042","0072","0103","0891","0927"}


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

		lTamR0		:= iif(lTamR0, TamSx3("R0_CODIGO")[1] == TamSx3("R0_MEIO")[1], .F.)
		lTamNumID	:= iif(lTamNumID, fTamNumID(@aLogPreCnv), .F.)
		lCompPer	:= iif(lCompPer,fVerCompPer(@aLogPreCnv),.F.)

	endIf

	aadd(aLogPreCnv,"")
	aadd(aLogPreCnv,STR0005 + cEmpAnt + " - " + STR0006 + cFilAnt)

	lSRASRD 	:= iif(lSRASRD, fMovSemFun(@aLogPreCnv, aParFil[nX][2]), .F.)
	lSRAAdm 	:= iif(lSRAAdm, fVerDtSRA(@aLogPreCnv, aParFil[nX][2]), .F.)
	lSRHDuplic	:= iif(lSRHDuplic, fSRHDuplic(@aLogPreCnv,aParFil[nX][2]), .F.)

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

lRHLibUpd 	:= GetApoInfo("RHLIBUPD.PRX")[4] >= STOD("20170824")


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

TBitmap():New(aRetcoords[15][1],aRetcoords[15][2],30,30,,iif(lSRHDuplic,"OK","CANCELA"),.T.,oPanel,NIL,NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TSay():New(aRetcoords[16][1] + 3,aRetcoords[16][2],{||STR0108},oPanel,,,,,,.T.,,,200,60)//SRH possui registros duplicados.


if(lTamR0 .AND. lTamNumID .AND. lCompPer .AND. lSRASRD .AND. lSRAAdm .AND. lIdentCalc .AND. lSRHDuplic)
	lPreConv := .T.
endIf

if(!lPreConv)
	TBitmap():New(aRetcoords[17][1],aRetcoords[17][2],30,30,,"UPDWARNING",.T.,oPanel,{|| ShowLog(STR0079 ,aLogPreCnv)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
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
Local cTexto 	:= ""
Local cIniFil	:= ""
Local cIniTab	:= ""
Local cEmp		:= ""
Local cFilSRV	:= "!!!!!!!"
Local cFilRCH	:= "!!!!!!!"
Local cFilRCJ	:= "!!!!!!!"
Local cFilMne	:= "!!!!!!!"
Local cFilForm	:= "!!!!!!!"
Local cVerbErr	:= ""
Local dInicio 	:= CtoD("")
Local dIniFil	:= CtoD("")
Local dIniTab	:= CtoD("")
Local cInicio	:= 0
Local nX		:= 0
Local nY		:= 0
Local nRecno    := 0
Local nProcRegua:= 0
Local nQtdConv	:= GpCntTab()
Local lPriVez	:= .T.
Local lGpEncEmp	:= ExistBlock("GPENCEMP") .And. !Empty( cDataDe ) .And. !Empty( cDataAte )
Local lGerBen 	:=  TamSx3("R0_CODIGO")[1] == TamSx3("R0_MEIO")[1]
Local cRCMFil	:= ""

Private aTitle		:= {}
Private aLogErr		:= {}
Private aFilPer 	:= {}
Private aSR5toRCB	:= {}
Private cAnoMes 	:= ""
Private cNameDB		:= ""

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
			RstaCodFol() //Reseta static aCodFol

			If lTab01
				oProcess:IncRegua2(STR0039) //"Criação de Verbas"
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

			fp_CodFol( @aCodFol , xFilial("SRV"), .F., .F. )
		EndIf

		If cEmp <> SM0->M0_CODIGO .or. cFilRCJ <> xFilial("RCJ")
			//Cria os processos
			GpIniProc()
			cFilRCJ := xFilial("RCJ")
		EndIf

		If !Empty(aCodFol)

			Eval({|x| If(Empty(x[40,1]),aAdd(aVerbErr,"0040"),),If(Empty(x[41,1]),aAdd(aVerbErr,"0041"),),If(Empty(x[42,1]),aAdd(aVerbErr,"0042"),),If(Empty(x[72,1]),aAdd(aVerbErr,"0072"),),If(Empty(x[103,1]) .And. cPaisLoc <> "ARG",aAdd(aVerbErr,"0103"),)},aCodFol)

			If !Empty(aVerbErr)
				For nX := 1 to Len(aVerbErr)
					cVerbErr += aVerbErr[nX] + ", "
				Next nX
				cVerbErr := SubStr(cVerbErr,1,Len(cVerbErr)-2)

				MsgInfo(STR0007 + chr(10) + chr(13) + " " + STR0008 + chr(10)+chr(13) + cVerbErr ,STR0003) //"As verbas com os identificadores abaixo não foram encontradas. " ### "A carga dos tipos de ausência padrão não será executada"
				Return Nil
			Else

				cAnoMes := SuperGetMv("MV_FOLMES",,AnoMes(dDataBase))

				If cFilSRV <> xFilial("SRV") .or. cEmp <> SM0->M0_CODIGO
					If lTab02
						Begin Transaction
							cIniTab := Time()
							dIniTab	:= MsDate()
							oProcess:IncRegua2(STR0040) //"Cadastro de Verbas"
							ConvSRV(aCodFol)
							aAdd( aLogFil[Len(aLogFil)], STR0040 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
							RecLock(cDbfLog,.T.)
							(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
							(cDbfLog)->FILIAL	:= FwGetCodFilial
							(cDbfLog)->DATAI	:= dDataBase
							(cDbfLog)->HORA		:= Time()
							(cDbfLog)->MENSAGEM	:= "Conversão das Verbas Concluído com Sucesso."
							(cDbfLog)->PROCESSO	:= 02
							(cDbfLog)->(MsUnLock())
						End Transaction
					EndIf
					cFilSRV := xFilial("SRV")
				Else
					If lTab01
						oProcess:IncRegua2(STR0039) //"Criação de Verbas"
					EndIf
					If lTab02
						oProcess:IncRegua2(STR0040) //"Cadastro de Verbas"
					EndIf
				EndIf

				fp_CodFol( @aCodFol , xFilial("SRV"), .T. )

				If Empty(aCodFol)
					Return()
				EndIf

			   	If lTab03
				   	If cEmp + cRCMFil <> SM0->M0_CODIGO + xFilial("RCM")
				   		Begin Transaction
					   		cIniTab := Time()
					   		dIniTab	:= MsDate()
					   		oProcess:IncRegua2(STR0041) //"Tipos de Ausência"
					   	  	fCargaRCM()
							RecLock(cDbfLog,.T.)
							(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
							(cDbfLog)->FILIAL	:= FwGetCodFilial
							(cDbfLog)->DATAI	:= dDataBase
							(cDbfLog)->HORA		:= Time()
							(cDbfLog)->MENSAGEM	:= "Conversão dos Tipos de Ausência Concluído com Sucesso."
							(cDbfLog)->PROCESSO	:= 03
							(cDbfLog)->(MsUnLock())
					   	  	aAdd( aLogFil[Len(aLogFil)], STR0041 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
							cRCMFil := xFilial("RCM")
					   	 End Transaction
				   	EndIf
				EndIf

				If lTab04
					Begin Transaction
					   	cIniTab := Time()
					   	dIniTab	:= MsDate()
					   	oProcess:IncRegua2(STR0042)		//"Cadastro de Sindicatos"
					   	ConvRCE(aCodFol)
							RecLock(cDbfLog,.T.)
							(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
							(cDbfLog)->FILIAL	:= FwGetCodFilial
							(cDbfLog)->DATAI	:= dDataBase
							(cDbfLog)->HORA		:= Time()
							(cDbfLog)->MENSAGEM	:= "Conversão do Cadastro de Sindicatos Concluído com Sucesso."
							(cDbfLog)->PROCESSO	:= 04
							(cDbfLog)->(MsUnLock())
					   	aAdd( aLogFil[Len(aLogFil)], STR0042 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
					End Transaction
				EndIf

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

               	If lTab06
               		Begin Transaction
						cIniTab := Time()
						dIniTab	:= MsDate()
						oProcess:IncRegua2( STR0044 )	//"Cadastro de Períodos"
				  		If cFilRCH <> xFilial("RCH") .or. cEmp <> SM0->M0_CODIGO
					  		If !ConvPER()
					  			DisarmTransaction()
					  			Return()
					  		EndIf
					  		cFilRCH := xFilial("RCH")
					  	EndIf
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão do Cadastro de Períodos Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 06
						(cDbfLog)->(MsUnLock())
					  	aAdd( aLogFil[Len(aLogFil)], STR0044 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
					End Transaction

				EndIf

				//Deve atualiza férias antes das ausencias e dias de direito
			  	If lTab12
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0050 )	//"Férias"
				  		ConvSRH()
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						If lAtuSRR
							(cDbfLog)->MENSAGEM := "Não foi possível efetuar a conversão de Férias"
							aAdd( aLogFil[Len(aLogFil)], "A conversão de Férias não foi efetuada." + CRLF + "Alguns dados já foram migrados anteriormente impossibilitando a atualização.")
						Else
							(cDbfLog)->PROCESSO	:= 12
							(cDbfLog)->MENSAGEM	:= "Conversão das Férias Concluído com Sucesso."
							aAdd( aLogFil[Len(aLogFil)], STR0050 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						EndIf
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0050 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
			  	EndIf

				If lTab07
					Begin Transaction
						cIniTab := Time()
						dIniTab	:= MsDate()
						oProcess:IncRegua2( STR0045 )	//"Cadastro de Ausências"
				  		ConvSR8()
							RecLock(cDbfLog,.T.)
							(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
							(cDbfLog)->FILIAL	:= FwGetCodFilial
							(cDbfLog)->DATAI	:= dDataBase
							(cDbfLog)->HORA		:= Time()
							(cDbfLog)->MENSAGEM	:= "Conversão do Cadastro de Ausências Concluído com Sucesso."
							(cDbfLog)->PROCESSO	:= 07
							(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0045 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
				EndIf

				If lTab08
					Begin Transaction
						cIniTab := Time()
						dIniTab	:= MsDate()
						oProcess:IncRegua2( STR0046 )	//"Controle Dias de Direito"

				  		ConvSRF(aCodFol)
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão do Controle Dias de Direito Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 08
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0046 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
				EndIf

				If lTab09
					//Begin Transaction --Retirado controle de transação para ver se melhora a performance
						cIniTab := Time()
						dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0047 )	//"Histórico de Movimentos"
				  		ConvSRD(@aLogFil)
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão do Histórico de Movimentos Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 09
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0047 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )

				  	//End Transaction
				EndIf

				If lTab10
					Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0048 )	//"Movimento 2ª parc. 13º Sal."
				  		ConvSRI()
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão do Movimento 2a. Parc. 13o. Sal. Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 10
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0048 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				 	End Transaction
			 	EndIf

			 	If lTab11
			 		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0049 )	//"Manutenção de Tabelas"
				  		ConvRCC()
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						If !lAtuRCC
							(cDbfLog)->MENSAGEM := "S037 não convertida completamente."
							aAdd( aLogFil[Len(aLogFil)], "A estrutura da tabela de S037(SIGAGPE - SR5(parâmetro 14)) está diferente da " + CRLF + " da tabela SRX.")
						Else
							(cDbfLog)->PROCESSO	:= 11
							(cDbfLog)->MENSAGEM	:= "Conversão da Manutenção de Tabelas Concluído com Sucesso."
							aAdd( aLogFil[Len(aLogFil)], STR0050 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						EndIf

						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0049 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
			  	EndIf

			  	If lTab13
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0051 )	//"Rescisão"
				  		ConvSRG()
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão das Rescisões Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 13
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0051 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
			  	EndIf

			  	If lTab14
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0052 )	//"Valores Futuros"
				  		ConvSRK(@aLogFil)
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão dos Valores Futuros Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 14
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0052 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
			  	EndIf

			  	If lTab15
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0053 )	//"Transferências"
				  		ConvSRE()
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão das Transferências Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 15
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0053 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
			  	EndIf

			  	If lTab16
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0054 )	//"Movimento Mensal"
				  		ConvSRC(aCodFol)
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão do Movimento Mensal Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 16
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0054 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
			  	EndIf

			  	If lTab17
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0055 )	//"Outros Beneficios"
				  		If lGerBen
				  			ConvBEN(aCodFol)
				  		EndIf
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						If !lGerBen
							(cDbfLog)->MENSAGEM := "Não foi possível efetuar a conversão de Benefícios"
							aAdd( aLogFil[Len(aLogFil)], "Não foi possível efetuar a conversão de Benefícios. O tamanho dos campos R0_MEIO e R0_CODIGO estão diferentes." + CRLF + "Favor alterar o tamanho do campo para o maior deles.")
						Else
							(cDbfLog)->PROCESSO	:= 17
							(cDbfLog)->MENSAGEM	:= "Conversão de Outros Beneficios Concluído com Sucesso."
							aAdd( aLogFil[Len(aLogFil)], STR0055 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
						EndIf
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0055 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
				EndIf

			  	If lTab18
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0059 )	//"Bloqueio de Periodos"
				  		ConvRG3()
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão do Bloqueio de Períodos Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 18
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], STR0059 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
				EndIf

			  	If lTab19
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( "Fórmulas" )	//"Fórmulas"
				  		If cFilForm <> xFilial("RC2") .or. cEmp <> SM0->M0_CODIGO
					  		ConvForm()
					  		cFilForm := xFilial("RC2")
					  	EndIf
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão das Fórmulas Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 19
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], "Fórmulas" + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
				EndIf

			  	If lTab20
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( "Mnemonicos" )	//"Mnemonicos"
				  		If cFilMne <> xFilial("RCA") .or. cEmp <> SM0->M0_CODIGO
					  		ConvRCA()
					  		cFilMne := xFilial("RCA")
					  	EndIf
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão dos Mnemonicos Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 20
						(cDbfLog)->(MsUnLock())
				  		aAdd( aLogFil[Len(aLogFil)], "Mnemonicos" + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )
				  	End Transaction
				EndIf

			  	If lTab21
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( "Importação de Variáveis" )	//"Fórmulas"
				  		ConvRFJ()
						RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão da Importação de Variáveis Concluído com Sucesso."
						(cDbfLog)->PROCESSO	:= 21
						(cDbfLog)->(MsUnLock())

				  		aAdd( aLogFil[Len(aLogFil)], "Importação de Variáveis" + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) )

				  	End Transaction
				EndIf

			  	If lTab22 .And. lGpEncEmp
			  		Begin Transaction
				  		cIniTab := Time()
				  		dIniTab	:= MsDate()
				  		oProcess:IncRegua2( STR0064 ) // "Encargos Empresa Analíticos"
				  		ExecBlock( "GPENCEMP", .F., .F. )
				  		RecLock(cDbfLog,.T.)
						(cDbfLog)->EMPRESA	:= SM0->M0_CODIGO
						(cDbfLog)->FILIAL	:= FwGetCodFilial
						(cDbfLog)->DATAI	:= dDataBase
						(cDbfLog)->HORA		:= Time()
						(cDbfLog)->MENSAGEM	:= "Conversão de Encargos Empresa Analíticos Concluída com Sucesso."
						(cDbfLog)->PROCESSO	:= 22
						(cDbfLog)->(MsUnLock())

				  		aAdd( aLogFil[Len(aLogFil)], STR0064 + ": " + fCalcHrs( dIniTab , cIniTab , MsDate() , Time() ) ) // "Encargos Empresa Analíticos"

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
		MsAguarde( { || fMakeLog( aLogErr , aTitle , NIL  , .T. , "GPECONV" , NIL , NIL, NIL, NIL, .F. ) } ,  STR0010 )
	Endif

	//Fecha empresa que não foi fechada anteriormente.
	RpcClearEnv()

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvRCE   ºAutor  ³Leandro Drumond     º Data ³  19/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conversão dos Sindicatos  .                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConvRCE(aCodFol)

Local nValor := 0
Local nPerc	 := 0
Local cBasCat:= If(fBasCat() > 0,"2","1")

SetMnemonicos( , , .T. )

DbSelectArea("RCE")
DbSetOrder(1)
If DbSeek(xFilial("RCE"))
	While RCE->(!Eof() .and. RCE_FILIAL == xFilial("RCE") )
		DbSelectArea("RCE")
		If fCrgADTS(RCE->RCE_CODIGO)
			nValor  := VAL_ANU + VAL_BIE + VAL_TRI + VAL_QUA + VAL_QUI
			nPerc	:= PER_ANU + PER_BIE + PER_TRI + PER_QUA + PER_QUI
			RecLock("RCE",.F.)

			//--ADICIONAIS POR TEMPO DE SERVICO
			RCE->RCE_TPCATS := If (nValor > 0 .and. nPerc > 0,"2",If(nPerc > 0, "1","3"))
			RCE->RCE_BASCAT := cBasCat
			RCE->RCE_VLRAN	:= VAL_ANU
			RCE->RCE_PERAN	:= PER_ANU
			RCE->RCE_LIMAN	:= LIM_ANU
			RCE->RCE_DTIAN	:= DTB_ANU
			RCE->RCE_ACUAN	:= IIF(ACU_ANU == "N", "2", "1")
			RCE->RCE_CARAN	:= Val(CAR_ANU)
			RCE->RCE_VLRBI	:= VAL_BIE
			RCE->RCE_PERBI	:= PER_BIE
			RCE->RCE_LIMBI	:= LIM_BIE
			RCE->RCE_DTIBI	:= DTB_BIE
			RCE->RCE_ACUBI	:= IIF(ACU_BIE == "N", "2", "1")
			RCE->RCE_CARBI	:= Val(CAR_BIE)
			RCE->RCE_VLRTR	:= VAL_TRI
			RCE->RCE_PERTR	:= PER_TRI
			RCE->RCE_LIMTR	:= LIM_TRI
			RCE->RCE_DTITR	:= DTB_TRI
			RCE->RCE_ACUTR	:= IIF(ACU_TRI == "N", "2", "1")
			RCE->RCE_CARTR	:= Val(CAR_TRI)
			RCE->RCE_VLRQR	:= VAL_QUA
			RCE->RCE_PERQR	:= PER_QUA
			RCE->RCE_LIMQR	:= LIM_QUA
			RCE->RCE_DTIQR	:= DTB_QUA
			RCE->RCE_ACUQR	:= IIF(ACU_QUA == "N", "2", "1")
			RCE->RCE_CARQR	:= Val(CAR_QUA)
			RCE->RCE_VLRQN	:= VAL_QUI
			RCE->RCE_PERQN	:= PER_QUI
			RCE->RCE_LIMQN	:= LIM_QUI
			RCE->RCE_DTIQN	:= DTB_QUI
			RCE->RCE_ACUQN	:= IIF(ACU_QUI == "N", "2", "1")
			RCE->RCE_CARQN	:= Val(CAR_QUI)
		Else
			RecLock("RCE",.F.)
		EndIf

		//--PERICULOSIDADE
		RCE->RCE_BCALPE	:= fBCalPE(RCE->RCE_CODIGO)
		RCE->RCE_PERPE	:= PosSrv(aCodFol[36,1],xFilial("SRV"),"RV_PERC")

		//--INSALUBRIDADE
		RCE->RCE_BCALIN		:= fBCAlIn(RCE->RCE_CODIGO)
		RCE->RCE_PINSMI 	:= PosSrv(aCodFol[37,1],xFilial("SRV"),"RV_PERC")
		RCE->RCE_PINSME		:= PosSrv(aCodFol[38,1],xFilial("SRV"),"RV_PERC")
		RCE->RCE_PINSMA		:= PosSrv(aCodFol[39,1],xFilial("SRV"),"RV_PERC")

		RCE->(MsUnLock())

		RCE->(DbSkip())
	EndDo
EndIf

Return Nil

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

Local cQuery 	:= ""
Local nTot	 := 0
Local nMinRec:= 0
Local nCont	 := 0
Local nX	 := 0

GpContReg(@nTot,@nMinRec,"SRA")

Begin Sequence

	If nTot > 0

		cRecno	:= "R_E_C_N_O_"
		nCont	:= nMinRec + 1024

		For nx = 1 to nTot

			cQuery := " UPDATE " + RetSqlName( "SRA" ) + " SET RA_PROCES = ( CASE WHEN RA_CATFUNC IN ('A','P') AND RA_TIPOPGT = 'M' THEN '00003' "
			cQuery += 														     " WHEN RA_CATFUNC IN ('A','P') AND RA_TIPOPGT = 'S' THEN '00004' "
			cQuery += 															 " WHEN RA_TIPOPGT = 'S' THEN '00002' "
			cQuery += 															 " Else '00001' END ), "
			cQuery += 										  " RA_HRSDIA = Round(RA_HRSMES / 30 , 4), "
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
		   	nCont  := nMinRec + 1024

		Next nx
	EndIf

End Sequence

Return

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

Local aRot		:= {"FOL","AUT","FER","132","RES"}
Local aProcesso	:= {}
Local aSemana	:= {}
Local cCompRCF	:= FWModeAccess("RCF",1) + FWModeAccess("RCF",2) + FWModeAccess("RCF",3)
Local cCompRCG	:= FWModeAccess("RCG",1) + FWModeAccess("RCG",2) + FWModeAccess("RCG",3)
Local cCompRCH	:= FWModeAccess("RCH",1) + FWModeAccess("RCH",2) + FWModeAccess("RCH",3)
Local cCompRFQ	:= FWModeAccess("RFQ",1) + FWModeAccess("RFQ",2) + FWModeAccess("RFQ",3)
Local cAliasTst	:= GetNextAlias()
Local cAliasAux	:= GetNextAlias()
Local cPd113	:= fGetCodFol("0022")
Local cPdPLR	:= fGetCodFol("0151")
Local cMsgPer	:= ""
Local cMesAux	:= ""
Local cAno		:= ""
Local cMes		:= ""
Local cPeriodo	:= ""
Local cSemana	:= ""
Local cSemAux	:= ""
Local cDataAux	:= ""
Local cKeyRCF	:= ""
Local cTnoAux	:= ""
Local cQuery	:= ""
Local cKeyRCG	:= ""
Local cQtdeDPer	:= SuperGetMv( "MV_DIASPER" , .F. , "1" ,  )	 // 1 = Usa qtde de dias do mes do periodo , 2 = Usa sempre 30
Local dDtPg 	:= CtoD("")
Local dDataPag	:= CtoD("")
Local dDataIni	:= CtoD("")
Local dDataFim	:= CtoD("")
Local dDataAux	:= CtoD("")
Local lAberto	:= .F.
Local lRHImp	:= .F.
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0
Local nDiasPer	:= 0
Local nDiaNoTr	:= 0
Local nDiasTrab	:= 0
Local nRet		:= 0
Local aPeriod131 := {}
Local aPeriodPLR := {}
Local nRecRCG 	 := 0
Local cUltSem	 := "05"
Local lTemRCF	 := .F.

If ( cCompRCF <> cCompRCG .OR. cCompRCF <> cCompRCH .OR. cCompRCF <> cCompRFQ ) .OR.;
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
	cAnoMes := AnoMes(dDataBase)
EndIf

RCF->(DbSetOrder(RetOrder("RCF","RCF_FILIAL+RCF_PER+RCF_SEMANA+RCF_ANO+RCF_MES+RCF_PROCES+RCF_ROTEIR+RCF_TNOTRA+DTOS(RCF_DTINI)+DTOS(RCF_DTFIM)+RCF_MODULO")))

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

If(IsInCallStack('RHIMP01') .OR. IsInCallStack('U_RHIMP23'))
	lRhImp := .T.
	aAdd(aRot,"131")

	BeginSql alias cAliasTst
		SELECT DISTINCT RD_DATARQ
		FROM %table:SRD% SRD
		WHERE
		RD_ROTEIR = '131'
		AND
 	   SRD.%notDel%
	EndSql

	while ( (cAliasTst)->(!Eof()) )
		aAdd(aPeriod131,(cAliasTst)->RD_DATARQ)
		(cAliasTst)->(dbSkip())
	EndDo

	(cAliasTst)->(DbCloseArea())
Else

	BeginSql alias cAliasTst
		SELECT DISTINCT RD_DATARQ
		FROM %table:SRD% SRD
		WHERE
		RD_PD = %exp:cPd113%
		AND
 	   SRD.%notDel%
	EndSql

	While ( (cAliasTst)->(!Eof()) )
		aAdd(aPeriod131,(cAliasTst)->RD_DATARQ)
		(cAliasTst)->(dbSkip())
	EndDo

	If Len(aPeriod131) > 0
		aAdd(aRot,"131")
	EndIf

	(cAliasTst)->(DbCloseArea())

	BeginSql alias cAliasTst
		SELECT DISTINCT RD_DATARQ
		FROM %table:SRD% SRD
		WHERE
		RD_PD = %exp:cPdPLR%
		AND
 	   SRD.%notDel%
	EndSql

	While ( (cAliasTst)->(!Eof()) )
		aAdd(aPeriodPLR,(cAliasTst)->RD_DATARQ)
		(cAliasTst)->(dbSkip())
	EndDo

	If Len(aPeriodPLR) > 0
		aAdd(aRot,"PLR")
	EndIf

	(cAliasTst)->(DbCloseArea())


EndIf


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

BeginSql alias cAliasTst
	SELECT DISTINCT(RD_DATARQ) AS RD_DATARQ, RD_FILIAL
	FROM %table:SRD% SRD
		WHERE SRD.%notDel%
	UNION
	SELECT DISTINCT(SUBSTRING(RH_DATABAS,1,6)) AS RD_DATARQ, RH_FILIAL
	FROM %table:SRH% SRH
		WHERE SRH.%notDel%
	UNION
	SELECT DISTINCT(SUBSTRING(R8_DATAINI,1,6)) AS RD_DATARQ, R8_FILIAL
	FROM %table:SR8% SR8
		WHERE SR8.%notDel%
		ORDER BY RD_DATARQ
EndSql

While (cAliasTst)->(!Eof())
	If !(AllTrim(xFilial("RCH")) $ AllTrim((cAliasTst)->RD_FILIAL )) .AND. !Empty(AllTrim(xFilial("RCH")))
		(cAliasTst)->(DbSkip())
		cPeriodo := ""
		Loop
	EndIf
	If Empty((cAliasTst)->RD_DATARQ)
		(cAliasTst)->(DbSkip())
		cPeriodo := ""
		Loop
	EndIf
	cMesAux := SubStr((cAliasTst)->RD_DATARQ,5,2)
	If cMesAux == "13"
		cMes := "12"
		cPeriodo := ""
	Else
		cMes := cMesAux
	EndIf

	cAno := SubStr((cAliasTst)->RD_DATARQ,1,4)

	If !Empty(cPeriodo)
		If cPeriodo == cAno+cMes .and. ( Empty(xFilial("RCH")) .or. AllTrim(xFilial("RCH")) $ (cAliasTst)->RD_FILIAL )
			(cAliasTst)->(DbSkip())
			Loop
		EndIf
	EndIf

	cPeriodo := cAno+cMes

	BeginSql alias cAliasAux
		column RD_DATPGT AS Date
		SELECT RD_DATPGT
		FROM %table:SRD% SRD
			WHERE RD_DATARQ = %exp:(cAliasTst)->RD_DATARQ% AND
			RD_FILIAL = %exp:(cAliasTst)->RD_FILIAL% AND
			SRD.%notDel%
	EndSql

	If (cAliasAux)->(Eof())
		dDataPag := StoD(cPeriodo+STRZERO(F_ULTDIA(StoD(cPeriodo+"01")),2))
  	Else
		dDataPag := (cAliasAux)->RD_DATPGT
	EndIf

	(cAliasAux)->(DbCloseArea())

	RCF->(DbSetOrder(RetOrder("RCF","RCF_FILIAL+RCF_PER+RCF_SEMANA+RCF_ANO+RCF_MES+RCF_PROCES+RCF_ROTEIR+RCF_TNOTRA+DTOS(RCF_DTINI)+DTOS(RCF_DTFIM)+RCF_MODULO")))

	For nX := 1 to Len(aRot)

		If aRot[nX] == "132" .and. cMesAux <> "13" .and. !lRhImp
			Loop
		EndIf

		If cMesAux == "13" .and. aRot[nX] <> "132"
			Loop
		EndIf

		If(aRot[nX] == "131" .And. aScan(aPeriod131,cPeriodo) <= 0)
			Loop
		EndIf

		If(aRot[nX] == "PLR" .And. aScan(aPeriodPLR,cPeriodo) <= 0)
			Loop
		EndIf


		For nY := 1 to Len(aProcesso)

			If aProcesso[nY] $ "00003*00004" .and. aRot[nX] <> "AUT"
				Loop
			EndIf

			If aProcesso[nY] $ "00001*00002" .and. aRot[nX] == "AUT"
				Loop
			EndIf

			dDataIni := StoD(cAno+cMes+"01")
			dDataAux := dDataIni
			aSemana	 := {}
			lTemRCF  := .F.
			If aProcesso[nY] $ "00002*00004"
				cAliasAux := GetNextAlias()
				BeginSql alias cAliasAux
					column RCF_DTINI AS Date
					column RCF_DTFIM AS Date
					SELECT RCF_SEMANA,RCF_DTINI,RCF_DTFIM
					FROM %table:RCF% RCF
					WHERE RCF.RCF_SEMANA <> ''
					AND RCF.%notDel%
					AND RCF.RCF_MES = %exp:cMes%
					AND RCF.RCF_ANO = %exp:cAno%
					AND RCF.RCF_FILIAL = %exp:xFilial("RCF")%
					ORDER BY RCF.RCF_SEMANA
				EndSql

				While !(cAliasAux)->(eof())
					If ( (aProcesso[nY] == "00002" .And. aRot[nX] == "FOL") .Or. (aProcesso[nY] == "00004" .And. aRot[nX] == "AUT") )  .And.  ((cAliasAux)->RCF_DTFIM - (cAliasAux)->RCF_DTINI) < 28
						aadd(aSemana,{(cAliasAux)->RCF_SEMANA,(cAliasAux)->RCF_DTINI,(cAliasAux)->RCF_DTFIM})
					ElseIf !(aRot[nX] $ "AUT*FOL") .And. ((cAliasAux)->RCF_DTFIM - (cAliasAux)->RCF_DTINI) >= 28
						aadd(aSemana,{(cAliasAux)->RCF_SEMANA,(cAliasAux)->RCF_DTINI,(cAliasAux)->RCF_DTFIM})
						cUltSem := (cAliasAux)->RCF_SEMANA
					EndIf
					(cAliasAux)->(dbSkip())
				EndDo
				(cAliasAux)->(dbCloseArea())

				lTemRCF := !Empty(aSemana)

				If !lTemRCF
					If aRot[nX] $ "AUT*FOL"
						aSemana  := {"01","02","03","04"}
						nDiasPer := 7
					Else
						aSemana  := {"05"}
						nDiasPer := F_ULTDIA(dDataIni)
					EndIf
				EndIf
			Else
				aSemana  := {"01"}
				nDiasPer := F_ULTDIA(dDataIni)
			EndIf

			For nZ := 1 to Len(aSemana)
				If lTemRCF
					cSemana  := aSemana[nZ][1]
					dDataAux := aSemana[nZ][2]
					dDataFim := aSemana[nZ][3]
				Else
					cSemana  := aSemana[nZ]
					dDataFim := dDataAux + nDiasPer - 1
				EndIf

				cSemAux  := If(aProcesso[nY] $ "00002*00004", cSemana, "  ")

				If !lTemRCF .And. cSemana == "04" //--Ultimo semana é prolongada ate o final do periodo
					dDataFim := dDataIni + F_ULTDIA(dDataIni) - 1
				EndIf

				If Len(aSemana) == 1
					dDtPg := dDataPag
				Else
					dDtPg := dDataFim
				EndIf

				nDiaTrab := DateWorkDay(dDataAux,dDataFim)
				nDiaNoTr := ( dDataFim - dDataAux + 1 ) - nDiaTrab

				//Atualiza registros pre-existentes na RCF
				If RCF->(DbSeek(xFilial("RCF")+Space(Len(cPeriodo))+cSemAux+cAno+cMes+Space(Len(aProcesso[nY]))+Space(3)))
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
							RCF->RCF_DCALCM	:= IIF(cQtdeDPer == "1", dDataFim - dDataAux + 1, 30)
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
							RCF->RCF_MODULO	:= "GPE"
							RCF->( MsUnLock() )
							If !RCF->(DbSeek(xFilial("RCF")+Space(Len(cPeriodo))+cSemAux+cAno+cMes+Space(Len(aProcesso[nY]))+Space(3))) //Se existir mais registros sem conversão, continua no looping
								Exit
							EndIf
						Else
							RCF->(DbSkip())
							Exit
						EndIf
					EndDo
				EndIf

				If !RCF->(DbSeek(xFilial("RCF")+cPeriodo+cSemana+cAno+cMes+aProcesso[nY]+Space(3)+"@@@"))
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
					RCF->RCF_DCALCM	:= IIF(cQtdeDPer == "1", dDataFim - dDataAux + 1, 30)
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
					RCF->RCF_MODULO	:= "GPE"

				EndIf

				RCF->( MsUnLock() )

				If cPeriodo >= cAnoMes
					lAberto := .T.
				Else
					lAberto := .F.
				EndIf

				RFQ->( DbSetOrder(1) )
				If !RFQ->( DbSeek( xFilial("RFQ")+aProcesso[nY]+cPeriodo+cSemana+DtoS(RCF->RCF_DTINI)+Dtos(RCF->RCF_DTFIM)+"GPE" ) )
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
					RFQ->RFQ_MODULO	:= "GPE"
					RFQ->( MsUnLock() )
				ElseIf lAberto .and. RFQ->RFQ_STATUS <> '1'
					RecLock("RFQ",.F.)
					RFQ->RFQ_STATUS := "1"
					RFQ->( MsUnLock() )
				EndIf

				RCH->(DbSetOrder(1)) //--RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR
				If !(RCH->(DbSeek(xFilial("RCH")+aProcesso[nY]+cPeriodo+cSemana+aRot[nX])))
					RecLock("RCH",.T.)
					RCH->RCH_FILIAL	:= xFilial("RCH")
					RCH->RCH_PER	:= cPeriodo
					RCH->RCH_NUMPAG	:= cSemana
					RCH->RCH_PROCES	:= aProcesso[nY]
					RCH->RCH_ROTEIR	:= aRot[nX]
					RCH->RCH_MES   	:= cMes
					RCH->RCH_ANO   	:= cAno
					RCH->RCH_DTINI 	:= RCF->RCF_DTINI
					RCH->RCH_DTFIM 	:= RCF->RCF_DTFIM
					RCH->RCH_DTPAGO	:= dDtPg
					RCH->RCH_DTINTE := If(lAberto,CtoD(""),RCF->RCF_DTINI)
					RCH->RCH_DTCORT	:= RCF->RCF_DTINI
					RCH->RCH_DTFECH	:= If(lAberto,CtoD(""),RCF->RCF_DTINI)
					RCH->RCH_PERSEL	:= "2"
					RCH->RCH_STATUS	:= If(lAberto,"0","5")
					RCH->RCH_MODULO	:= "GPE"
					RCH->RCH_COMPL	:= "2"
					RCH->( MsUnLock() )
				EndIf

				If !lTemRCF
					dDataAux := RCF->RCF_DTINI + 1
				EndIf

			Next nZ

		Next nY

	Next nX

	(cAliasTst)->(DbSkip())
EndDo

//--Procura periodo ativo de 13. segunda parcela
DbSelectArea("SRI")
DbSetOrder(1)

If DbSeek(xFilial("SRI"))
	cPeriodo := AnoMes(SRI->RI_DATA)
	If Empty(cPeriodo)
		cPeriodo := cAnoMes
	EndIf
	cMes 	 := SubStr(cPeriodo,5,2)
	cAno	 := SubStr(cPeriodo,1,4)
	cRotAux	 := "132"

	For nY := 1 to Len(aProcesso)
		dDataIni := StoD(cAno+cMes+"01")
		dDataAux := dDataIni
		If aProcesso[nY] $ "00002*00004"
			cSemana  := cUltSem
		Else
			cSemana  := "01"
		EndIf

		nDiasPer := F_ULTDIA(dDataIni)

		dDataFim := dDataAux + nDiasPer - 1
		dDtPg 	 := dDataFim

		If RCH->(DbSeek(xFilial("RCH")+aProcesso[nY]+cPeriodo+cSemana+cRotAux))
			Loop
		EndIf

		nDiaTrab := DateWorkDay(dDataIni,dDataFim)
		nDiaNoTr := ( dDataFim - dDataIni + 1 ) - nDiaTrab

		//Atualiza registros pre-existentes na RCF
		If RCF->(DbSeek(xFilial("RCF")+Space(Len(cPeriodo))+cSemana+cAno+cMes+Space(Len(aProcesso[nY]))+Space(3)))
			nRecRCF := RCF->(Recno())
			If Empty(RCF->RCF_TNOTRA)
				cTnoAux := "@@@"
			Else
				cTnoAux := RCF->RCF_TNOTRA
			EndIf
			If !RCF->(DbSeek(xFilial("RCF")+cPeriodo+cSemana+cAno+cMes+aProcesso[nY]+Space(3)+RCF->RCF_TNOTRA))
				RCF->(DbGoTO(nRecRCF))
				RecLock("RCF",.F.)

				RCF->RCF_PER	:= cPeriodo
				RCF->RCF_PROCES	:= aProcesso[nY]
				RCF->RCF_SEMANA	:= cSemana
				RCF->RCF_TNOTRA	:= cTnoAux
				RCF->RCF_DCALCM	:= RCF->RCF_DTFIM - RCF->RCF_DTINI + 1
				RCF->RCF_DPERIO 	:= RCF->RCF_DTFIM - RCF->RCF_DTINI + 1
				RCF->RCF_DIADSR	:= nDiaNoTr / 2
				RCF->RCF_DUTEIS	:= RCF->RCF_DPERIO - RCF->RCF_DIADSR
				RCF->RCF_HRSDSR	:= ( nDiaNoTr / 2 ) * 8
				RCF->RCF_DIATRA	:= nDiaTrab
				RCF->RCF_HRSTRA	:= nDiasTrab * 8
				RCF->RCF_DNTRAB	:= nDiaNoTr / 2
				RCF->RCF_DUTILT	:= nDiaTrab
				RCF->RCF_DREFEI	:= nDiaTrab
				RCF->RCF_DALIM		:= nDiaTrab
				RCF->RCF_MODULO	:= "GPE"
				RCF->( MsUnLock() )
			EndIf

		ElseIf RCF->(DbSeek(xFilial("RCF")+Space(Len(cPeriodo))+Space(2)+cAno+cMes+Space(Len(aProcesso[nY]))+Space(3)))
			nRecRCF := RCF->(Recno())
			If Empty(RCF->RCF_TNOTRA)
				cTnoAux := "@@@"
			Else
				cTnoAux := RCF->RCF_TNOTRA
			EndIf
			If !RCF->(DbSeek(xFilial("RCF")+cPeriodo+cSemana+cAno+cMes+aProcesso[nY]+Space(3)+RCF->RCF_TNOTRA))
				RCF->(DbGoTO(nRecRCF))
				RecLock("RCF",.F.)

				RCF->RCF_PER	:= cPeriodo
				RCF->RCF_PROCES	:= aProcesso[nY]
				RCF->RCF_SEMANA	:= cSemana
				RCF->RCF_TNOTRA	:= cTnoAux
				RCF->RCF_DCALCM	:= RCF->RCF_DTFIM - RCF->RCF_DTINI + 1
				RCF->RCF_DPERIO 	:= RCF->RCF_DTFIM - RCF->RCF_DTINI + 1
				RCF->RCF_DIADSR	:= nDiaNoTr / 2
				RCF->RCF_DUTEIS	:= RCF->RCF_DPERIO - RCF->RCF_DIADSR
				RCF->RCF_HRSDSR	:= ( nDiaNoTr / 2 ) * 8
				RCF->RCF_DIATRA	:= nDiaTrab
				RCF->RCF_HRSTRA	:= nDiasTrab * 8
				RCF->RCF_DNTRAB	:= nDiaNoTr / 2
				RCF->RCF_DUTILT	:= nDiaTrab
				RCF->RCF_DREFEI	:= nDiaTrab
				RCF->RCF_DALIM		:= nDiaTrab
				RCF->RCF_MODULO	:= "GPE"
				RCF->( MsUnLock() )
			EndIf
		EndIf

		If !RCF->(DbSeek(xFilial("RCF")+cPeriodo+cSemana+cAno+cMes+aProcesso[nY]+Space(3)+"@@@"))
			RecLock("RCF",.T.)

			RCF->RCF_FILIAL	:= xFilial("RCF")
			RCF->RCF_MES   	:= cMes
			RCF->RCF_ANO   	:= cAno
			RCF->RCF_PER	:= cPeriodo
			RCF->RCF_PROCES	:= aProcesso[nY]
			RCF->RCF_TNOTRA	:= "@@@"
			RCF->RCF_SEMANA	:= cSemana
			RCF->RCF_DTINI 	:= dDataIni
			RCF->RCF_DTFIM 	:= dDataFim
			RCF->RCF_DCALCM	:= dDataFim - dDataIni + 1
			RCF->RCF_DPERIO	:= dDataFim - dDataIni + 1
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
			RCF->RCF_MODULO	:= "GPE"
		Else
			RecLock("RCF",.F.)
			RCF->RCF_PER	:= cPeriodo
			RCF->RCF_PROCES	:= aProcesso[nY]
			RCF->RCF_SEMANA	:= cSemana
			RCF->RCF_DCALCM	:= RCF->RCF_DTFIM - RCF->RCF_DTINI + 1
			RCF->RCF_DPERIO 	:= RCF->RCF_DTFIM - RCF->RCF_DTINI + 1
			RCF->RCF_DIADSR	:= nDiaNoTr / 2
			RCF->RCF_DUTEIS	:= RCF->RCF_DPERIO - RCF->RCF_DIADSR
			RCF->RCF_HRSDSR	:= ( nDiaNoTr / 2 ) * 8
			RCF->RCF_DIATRA	:= nDiaTrab
			RCF->RCF_HRSTRA	:= nDiasTrab * 8
			RCF->RCF_DNTRAB	:= nDiaNoTr / 2
			RCF->RCF_DUTILT	:= nDiaTrab
			RCF->RCF_DREFEI	:= nDiaTrab
			RCF->RCF_DALIM	:= nDiaTrab
			RCF->RCF_MODULO	:= "GPE"
		EndIf

		RCF->( MsUnLock() )

		RFQ->( DbSetOrder(1) )
		If !RFQ->( DbSeek( xFilial("RFQ")+aProcesso[nY]+cPeriodo+cSemana+DtoS(dDataIni)+Dtos(dDataFim)+"GPE" ) )
			RecLock("RFQ",.T.)
			RFQ->RFQ_FILIAL	:= xFilial("RFQ")
			RFQ->RFQ_PROCES	:= aProcesso[nY]
			RFQ->RFQ_MES   	:= cMes
			RFQ->RFQ_ANO   	:= cAno
			RFQ->RFQ_PERIOD	:= cPeriodo
			RFQ->RFQ_NUMPAG	:= cSemana
			RFQ->RFQ_DTINI 	:= dDataIni
			RFQ->RFQ_DTFIM 	:= dDataFim
			RFQ->RFQ_MODULO	:= "GPE"
			RFQ->( MsUnLock() )
		EndIf

		RecLock("RCH",.T.)
		RCH->RCH_FILIAL	:= xFilial("RCH")
		RCH->RCH_PER	:= cPeriodo
		RCH->RCH_NUMPAG	:= cSemana
		RCH->RCH_PROCES	:= aProcesso[nY]
		RCH->RCH_ROTEIR	:= cRotAux
		RCH->RCH_MES   	:= cMes
		RCH->RCH_ANO   	:= cAno
		RCH->RCH_DTINI 	:= dDataIni
		RCH->RCH_DTFIM 	:= dDataFim
		RCH->RCH_DTPAGO	:= dDtPg
		RCH->RCH_DTCORT	:= dDataFim
		RCH->RCH_PERSEL	:= "1"
		RCH->RCH_STATUS	:= "0"
		RCH->RCH_MODULO	:= "GPE"
		RCH->RCH_COMPL	:= "2"
		RCH->( MsUnLock() )

		dDataAux := dDataFim + 1

	Next nY

EndIf

//--Cria periodo atual
cMes 		:= SubStr(cAnoMes,5,2)
cAno 		:= SubStr(cAnoMes,1,4)
cPeriodo 	:= cAnoMes

RCH->(DbSetOrder(RetOrder("RCH","RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR")))

For nX := 1 to Len(aRot)
	If aRot[nX] == "132" .and. cMes <> "12"
		Loop
	EndIf

	If lRhImp .and. aRot[nX] == "131" .and. cMes <> "11"
		Loop
	EndIf

	For nY := 1 to Len(aProcesso)
		dDataIni := StoD(cAno+cMes+"01")
		dDataAux := dDataIni

		If aProcesso[nY] $ "00003*00004" .and. aRot[nX] <> "AUT"
			Loop
		EndIf

		If aProcesso[nY] $ "00001*00002" .and. aRot[nX] == "AUT"
			Loop
		EndIf

		If aProcesso[nY] <> "00001" .and. aRot[nX] == "ADI"
			Loop
		EndIf

		aSemana := {}
		lTemRCF := .F.

		If aProcesso[nY] $ "00002*00004"

			cAliasAux := GetNextAlias()
			BeginSql alias cAliasAux
				column RCF_DTINI AS Date
				column RCF_DTFIM AS Date
				SELECT RCF_SEMANA,RCF_DTINI,RCF_DTFIM
				FROM %table:RCF% RCF
				WHERE RCF.RCF_SEMANA <> ''
				AND RCF.%notDel%
				AND RCF.RCF_MES = %exp:cMes%
				AND RCF.RCF_ANO = %exp:cAno%
				AND RCF.RCF_FILIAL = %exp:xFilial("RCF")%
				ORDER BY RCF.RCF_SEMANA
			EndSql

			While !(cAliasAux)->(eof())
				If ( (aProcesso[nY] == "00002" .And. aRot[nX] == "FOL") .Or. (aProcesso[nY] == "00004" .And. aRot[nX] == "AUT") )  .And.  ((cAliasAux)->RCF_DTFIM - (cAliasAux)->RCF_DTINI) < 28
					aadd(aSemana,{(cAliasAux)->RCF_SEMANA,(cAliasAux)->RCF_DTINI,(cAliasAux)->RCF_DTFIM})
				ElseIf !(aRot[nX] $ "AUT*FOL") .And. ((cAliasAux)->RCF_DTFIM - (cAliasAux)->RCF_DTINI) >= 28
					aadd(aSemana,{(cAliasAux)->RCF_SEMANA,(cAliasAux)->RCF_DTINI,(cAliasAux)->RCF_DTFIM})
					cUltSem := (cAliasAux)->RCF_SEMANA
				EndIf
				(cAliasAux)->(dbSkip())
			EndDo
			(cAliasAux)->(dbCloseArea())

			lTemRCF := !Empty(aSemana)

			If !lTemRCF
				If aRot[nX] $ "AUT*FOL"
					aSemana  := {"01","02","03","04"}
					nDiasPer := 7
				Else
					aSemana  := {"05"}
					nDiasPer := F_ULTDIA(dDataIni)
				EndIf
			EndIf
		Else
			aSemana  := {"01"}
			nDiasPer := F_ULTDIA(dDataIni)
		EndIf

		For nZ := 1 to Len(aSemana)
			If lTemRCF
				cSemana  := aSemana[nZ][1]
				dDataAux := aSemana[nZ][2]
				dDataFim := aSemana[nZ][3]
			Else
				cSemana  := aSemana[nZ]
				dDataFim := dDataAux + nDiasPer - 1
				If cSemana == "04" //--Ultimo semana é prolongada ate o final do periodo
					dDataFim := dDataIni + F_ULTDIA(dDataIni) - 1
				EndIf
			EndIf

			dDtPg 	 := dDataFim

			If aRot[nX] == "ADI"
				cDataAux := DtoS(dDataIni)
				dDtPg := StoD(SubStr(cDataAux,1,4) + SubStr(cDataAux,5,2) + "20")
			EndIf

			nDiaTrab := DateWorkDay(dDataAux,dDataFim)
			nDiaNoTr := ( dDataFim - dDataAux + 1 ) - nDiaTrab

			//Atualiza registros pre-existentes na RCF
			If RCF->(DbSeek(xFilial("RCF")+Space(Len(cPeriodo))+cSemana+cAno+cMes+Space(Len(aProcesso[nY]))+Space(3)))
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
					RCF->( MsUnLock() )
				EndIf

			ElseIf RCF->(DbSeek(xFilial("RCF")+Space(Len(cPeriodo))+Space(2)+cAno+cMes+Space(Len(aProcesso[nY]))+Space(3)))
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
					RCF->( MsUnLock() )
				EndIf
			EndIf

			If !RCF->(DbSeek(xFilial("RCF")+cPeriodo+cSemana+cAno+cMes+aProcesso[nY]+Space(3)+"@@@"+DtoS(dDataAux)+DtoS(dDataFim)+"GPE"))
				RecLock("RCF",.T.)
			Else
				RecLock("RCF",.F.)
			EndIf

			RCF->RCF_FILIAL	:= xFilial("RCF")
			RCF->RCF_MES   	:= cMes
			RCF->RCF_ANO   	:= cAno
			RCF->RCF_PER	:= cPeriodo
			RCF->RCF_PROCES	:= aProcesso[nY]
			RCF->RCF_TNOTRA	:= "@@@"
			RCF->RCF_SEMANA	:= cSemana
			RCF->RCF_DTINI 	:= dDataAux
			RCF->RCF_DTFIM 	:= dDataFim
			RCF->RCF_DCALCM	:= IIF(cQtdeDPer == "1", dDataFim - dDataAux + 1, 30)
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
			RCF->RCF_MODULO	:= "GPE"
			RCF->( MsUnLock() )

			RFQ->( DbSetOrder(1) )
			If !RFQ->( DbSeek( xFilial("RFQ")+aProcesso[nY]+cPeriodo+cSemana+DtoS(dDataAux)+Dtos(dDataFim)+"GPE" ) )
				RecLock("RFQ",.T.)
			Else
				RecLock("RFQ",.F.)
			EndIf

			RFQ->RFQ_FILIAL	:= xFilial("RFQ")
			RFQ->RFQ_PROCES	:= aProcesso[nY]
			RFQ->RFQ_MES   	:= cMes
			RFQ->RFQ_ANO   	:= cAno
			RFQ->RFQ_PERIOD	:= cPeriodo
			RFQ->RFQ_NUMPAG	:= cSemana
			RFQ->RFQ_DTINI 	:= dDataAux
			RFQ->RFQ_DTFIM 	:= dDataFim
			RFQ->RFQ_STATUS := "1"
			RFQ->RFQ_MODULO	:= "GPE"
			RFQ->( MsUnLock() )

			If !RCH->(DbSeek(xFilial("RCH")+aProcesso[nY]+cPeriodo+cSemana+aRot[nX]))
				RecLock("RCH",.T.)
			Else
				RecLock("RCH",.F.)
			EndIf

			RCH->RCH_FILIAL	:= xFilial("RCH")
			RCH->RCH_PER	:= cPeriodo
			RCH->RCH_NUMPAG	:= cSemana
			RCH->RCH_PROCES	:= aProcesso[nY]
			RCH->RCH_ROTEIR	:= aRot[nX]
			RCH->RCH_MES   	:= cMes
			RCH->RCH_ANO   	:= cAno
			RCH->RCH_DTINI 	:= dDataAux
			RCH->RCH_DTFIM 	:= dDataFim
			RCH->RCH_DTPAGO	:= dDtPg
			RCH->RCH_DTCORT	:= dDataFim
			RCH->RCH_DTFECH := CtoD("")
			RCH->RCH_PERSEL	:= If(cSemana $ "01*05","1","2")
			RCH->RCH_STATUS	:= "0"
			RCH->RCH_MODULO	:= "GPE"
			RCH->RCH_COMPL	:= "2"
			RCH->( MsUnLock() )

			dDataAux := dDataFim + 1

		Next nZ

	Next nY

Next nX

DbSelectArea("RCF")
DbSetOrder(1) //RCF_FILIAL+RCF_ANO+RCF_MES+RCF_TNOTRA+RCF_SEMANA

DbSelectArea("RCG")
DbSetOrder(1) //RCG_FILIAL+RCG_ANO+RCG_MES+RCG_TNOTRA+RCG_SEMANA
DbSeek(xFilial("RCG"))

cAliasAux := GetNextAlias()
BeginSql alias cAliasAux
	SELECT *
	FROM %table:RCG% RCG
	WHERE RCG.RCG_PROCES = ''
	AND RCG.%notDel%
	AND RCG.RCG_FILIAL = %exp:xFilial("RCG")%
	ORDER BY RCG.RCG_FILIAL,RCG.RCG_ANO,RCG.RCG_MES,RCG.RCG_TNOTRA,RCG.RCG_SEMANA
EndSql

While !(cAliasAux)->(eof())
	If Empty((cAliasAux)->RCG_PROCES)
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
				If ( Empty((cAliasAux)->RCG_SEMANA) .and. (RCF->RCF_PROCES $ '00001*00003') ) .or. ( !Empty((cAliasAux)->RCG_SEMANA) .and. !(RCF->RCF_PROCES $ '00001*00003') )
					cQuery := " UPDATE " + RetSqlName( "RCG" ) + " SET RCG_PROCES = '" + RCF->RCF_PROCES + "', "
					cQuery += 														 " RCG_PER = '" + RCF->RCF_PER + "', "
					cQuery += 														 " RCG_SEMANA = '" + RCF->RCF_SEMANA +"',  "
					cQuery += 														 " RCG_TNOTRA = '" + cTnoAux + "', "
					cQuery += 														 " RCG_MODULO = 'GPE', "
					cQuery += 														 " RCG_DTINI = '" + DtoS(RCF->RCF_DTINI) + "', "
					cQuery += 														 " RCG_DTFIM = '" + DtoS(RCF->RCF_DTFIM) + "' "
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvSR8   ºAutor  ³Leandro Drumond     º Data ³  06/18/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conversao das Ausencias.                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConvSR8()

Local cQuery 	:= ""
Local i			:= 0
Local aTipos 	:= {}
Local aSeqAfa	:= {}
Local aPerAtual	:= {}
Local cPerAus	:= ""
Local cNumPgAus	:= ""
Local cSeqAfa	:= ""
Local cMatAux	:= ""
Local cPerAberto:= ""
Local cProcPer	:= "XXXXXX"
Local nDiasPg	:= 0
Local nSldPg 	:= 0
Local nPosSeq	:= 0
Local nDiasSeq	:= 0
Local dDtAux	:= ctod("//")
Local dDtIniP	:= ctod("//")
Local lDeleta	:= .F.

	If Empty(cAnoMes)
		cAnoMes := Substr( Dtos(dDatabase) , 1, 6)
	EndIf

	dDtIniP := StoD( cAnoMes + "01" )
	dDtFimP := StoD( cAnoMes + Alltrim(Str(F_ULTDIA(StoD(cAnoMes+"01")))) )

	aAdd( aTipos, {"F","001" } )
	aAdd( aTipos, {"D","002" } )
	aAdd( aTipos, {"O","003" } )
	aAdd( aTipos, {"P","004" } )
	aAdd( aTipos, {"R","005" } )
	aAdd( aTipos, {"Q","008" } )
	aAdd( aTipos, {"Q","007" } )
	aAdd( aTipos, {"Q","006" } )
	aAdd( aTipos, {"B","010" } )
	aAdd( aTipos, {"6","011" } )
	aAdd( aTipos, {"7","012" } )
	aAdd( aTipos, {"W","013" } )
	aAdd( aTipos, {"X","014" } )
	aAdd( aTipos, {"8","015" } )
	aAdd( aTipos, {"Y","016" } )
	aAdd( aTipos, {"V","016" } )
	aAdd( aTipos, {"1","017" } )
	aAdd( aTipos, {"U","017" } )

	cQuery += " SELECT SR8.R_E_C_N_O_ R8RECNO, R8_DATAINI, RCM_TIPO, RCM_PD, RCM_DIASEM, RA_PROCES, RA_CATFUNC, COALESCE(RCF_PER, '') AS RCF_PER, COALESCE(RCF_SEMANA, '') AS RCF_SEMANA "
	cQuery += " FROM " + RetSqlName( "SR8" ) + " SR8 "
	cQuery += " INNER JOIN " + RetSqlName( "SRA" ) + " SRA ON RA_FILIAL = R8_FILIAL AND RA_MAT = R8_MAT "
	cQuery += " LEFT JOIN " + RetSqlName( "RCF" ) + " RCF ON RCF_FILIAL = '"+xFilial( "RCF" )+"' AND RCF_PROCES = RA_PROCES AND RCF_DTINI <= R8_DATAINI AND  RCF_DTFIM >= R8_DATAINI AND RCF.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName( "RCM" ) + " RCM ON RCM_FILIAL = '"+xFilial( "RCM" )+"' "

	cQuery += " AND RCM_TIPO = ( CASE "

	For i:=1 to Len(aTipos)
		If aTipos[i][1] == "Q" .AND. aTipos[i][2] == "007"
	 		cQuery += " WHEN R8_TIPO = '"+aTipos[i][1]+"' AND ( RA_CATFUNC = 'P' OR RA_CATFUNC = 'A' ) THEN '"+aTipos[i][2]+"' "
		ElseIf aTipos[i][1] == "Q" .AND. aTipos[i][2] == "008"
	 		cQuery += " WHEN R8_TIPO = '"+aTipos[i][1]+"' AND R8_CONTAFA <> '' AND R8_DURACAO >= 60 THEN '"+aTipos[i][2]+"' "
	 	Else
			cQuery += " WHEN R8_TIPO = '"+aTipos[i][1]+"' THEN '"+aTipos[i][2]+"' "
		EndIf
    Next i

	cQuery += " END ) "
	cQuery += " WHERE SR8.D_E_L_E_T_ = ' ' AND RCM.D_E_L_E_T_ = ' ' AND SRA.D_E_L_E_T_ = ' ' AND SR8.R8_FILIAL = '"+xFilial("SR8")+"' "
	cQuery += " ORDER BY R8_FILIAL,RA_PROCES,R8_MAT,R8_DATA,R8_TIPO,R8_SEQ "

    If SELECT("TSR8") > 0
    	TSR8->( dbclosearea() )
    EndIf

    cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TSR8", .F., .T.)
	TCSETFIELD("TSR8","R8_DATAINI","D")

	TSR8->( dbgotop() )
	While TSR8->( !Eof() )

		lDeleta	:= .F.

		If TSR8->RCM_TIPO == "001" .and. AnoMes(TSR8->R8_DATAINI) >= cAnoMes
			lDeleta := .T.
		EndIf

		If !Empty(TSR8->RCF_PER)

			If cProcPer <> TSR8->RA_PROCES
				fGetPerAtual( @aPerAtual, xFilial("RCH"), TSR8->RA_PROCES, If (TSR8->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar()) )
				cProcPer := TSR8->RA_PROCES
			EndIf

			If !Empty(aPerAtual)
				cPerAberto := aPerAtual[1,1]
				dDtIniP := StoD( cPerAberto + "01" )
				dDtFimP := StoD( cPerAberto + Alltrim(Str(F_ULTDIA(StoD(cPerAberto+"01")))) )
			Else
				cPerAberto := cPerAberto
			EndIf

			SR8->( dbgoto(TSR8->R8RECNO) )

			If cMatAux <> SR8->R8_MAT
				aSeqAfa := {}
				cMatAux := SR8->R8_MAT
			EndIf

			RecLock("SR8",.F.)

			R8_TIPOAFA		:= TSR8->RCM_TIPO
			R8_PD			:= TSR8->RCM_PD
			R8_DIASEMP		:= TSR8->RCM_DIASEM
			R8_PROCES 		:= TSR8->RA_PROCES
			R8_PER			:= TSR8->RCF_PER
			R8_NUMPAGO		:= TSR8->RCF_SEMANA

			If Empty(SR8->R8_DATAFIM)
				R8_DURACAO := 999
			EndIf

			If SR8->R8_DURACAO == 0
				R8_DURACAO := SR8->R8_DATAFIM - SR8->R8_DATAINI + 1
			EndIf

			nDiasPg := Min(TSR8->RCM_DIASEM,SR8->R8_DURACAO)

			If Empty(SR8->R8_DATAFIM) .AND. TSR8->RCM_DIASEM == 999
				nDiasPg := 999
			EndIf

			cSeqAfa := SR8->R8_CONTAFA
			nDiasSeq:= 0
			If !Empty(cSeqAfa)
				If ( nPosSeq := aScan( aSeqAfa ,{|x| x[1] == cSeqAfa } ) ) > 0
					While .T.
						if !(aSeqAfa[nPosSeq,4] == "Q" .AND. aSeqAfa[nPosSeq,5] <> R8_TIPOAFA)
							nDiasSeq += aSeqAfa[nPosSeq,3]
						endIf
						cSeqAfa := aSeqAfa[nPosSeq,2]
						If Empty(cSeqAfa)
							Exit
						Else
							nPosSeq := aScan( aSeqAfa ,{|x| x[1] == cSeqAfa } )
							If Empty(nPosSeq)
								Exit
							EndIf
						EndIf
					EndDo
				EndIf
			EndIf

			aAdd(aSeqAfa,{SR8->R8_SEQ,SR8->R8_CONTAFA,SR8->R8_DURACAO,SR8->R8_TIPO,R8_TIPOAFA})

			R8_DIASEMP	-= nDiasSeq
			R8_DIASEMP	:= Max(R8_DIASEMP,0)

			nDiasPg := Min(nDiasPg,R8_DIASEMP)

			R8_DPAGAR       := nDiasPg

			If Substr( Dtos(SR8->R8_DATAINI),1,6) >= cPerAberto
				nSldPg := 0
				nDiasPg:= 0
			ElseIf !Empty(SR8->R8_DATAFIM)
				If Substr( Dtos(SR8->R8_DATAFIM) ,1 ,6) < cPerAberto
					nSldPg := 0
				ElseIf Substr( Dtos(SR8->R8_DATAFIM) ,1 ,6) >= cPerAberto
					nSldPg := ( SR8->R8_DATAFIM - Max(SR8->R8_DATAINI,dDtIniP) ) + 1
				EndIf
				nSldPg := Max(nSldPg,0)
			ElseIf Empty(SR8->R8_DATAFIM) .and. TSR8->RCM_DIASEM == 999 .and. SR8->R8_DURACAO == 999
				nSldPg := 999 - ( dDtIniP - SR8->R8_DATAINI )
			Else
				dDtAux := SR8->R8_DATAINI + nDiasPg
				If dDtAux >= dDtIniP
					nSldPg := dDtAux - dDtIniP + 1
				Else
			   		nSldPg := 0
				EndIf
			EndIf

			If nSldPg > nDiasPg
				nSldPg := nDiasPg
			EndIf

			R8_SDPAGAR      := nSldPg
			R8_DPAGOS		:= nDiasPg - nSldPg

			R8_STATUS		:= IIF( nSldPg == 0 , "C" , "" )
			R8_NUMID		:= "SR8"+SR8->R8_MAT+SR8->R8_PD+DTOS(SR8->R8_DATAINI)

			SR8->( MSUNLOCK() )
		EndIf

		If lDeleta //Apaga férias do mês na SR8 e muda situaçao do funcionário
			SR8->( dbgoto(TSR8->R8RECNO) )

			DbSelectArea("SRA")
			DbSetOrder(1)
			DbSeek(SR8->R8_FILIAL + SR8->R8_MAT)

			If SRA->RA_SITFOLH == "F"
				RecLock("SRA",.F.)
				SRA->RA_SITFOLH = ''
				MsUnLock()
			EndIf

			RecLock("SR8",.F.)
			SR8->(DbDelete())
			SR8->(MsUnLock())
		EndIf

		cPerAus   := ""
		cNumPgAus := ""

		TSR8->( DbSkip() )
	EndDo

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvSRF   ºAutor  ³Leandro Drumond     º Data ³  10/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ConvSRF(aCodFol,cFiltro)

Local cQuery 	:= ""
Local cAnoIni	:= ""
Local cAnoFim   := ""
Local cObsFer	:= ""
Local cAliasSRA	:= GetNextAlias()
Local dDtIni	:= CtoD("//")
Local dDtFim	:= CtoD("//")
Local dNewPer	:= CtoD("//")
Local dDtIniPen	:= CtoD("//")
Local dDtFimPen := CtoD("//")
Local dDtAux	:= CtoD("//")
Local cStatus	:= ""
Local cPdFer	:= fGetCodFol("0072")
Local cPdRes	:= fGetCodFol("0891")
Local nRecSRF	:= 0
Local nDiasDir	:= 0
Local nDiasVen	:= 0
Local nDiasAVen	:= 0
Local nDiasPg	:= 0
Local nFalVenc	:= 0
Local nFalProp 	:= 0
Local nFaltas	:= 0
Local nDirPen	:= 0
Local lContinua	:= .T.
Local dDtAnoMes	:= CToD("//")
Local dDtFechado:= CtoD("//")
Local nFerVen	:= 0
Local aProgFer := {} //{RF_DATABAS, RF_DATAINI, RF_DATINI2, RF_DATINI3, RF_DFEPRO1, RF_DFEPRO2, RF_DFEPRO3, RF_DABPRO1, RF_DABPRO2, RF_DABPRO3}
Local dDtPagFer	:= cToD("//")
Local lExistCpo := ( SRH->(FieldPos( "RH_DTITENS" )) # 0 )

Default cFiltro := ""

If Empty(cPdRes) //Se a verba de rescesso de estagiário estiver vazia, indica que não possui estagiários.
	cPdRes := cPdFer
EndIf

Private lPerFeAc := SuperGetMv("MV_FERPAC",,"N") == "S"

	If Empty(cAnoMes)
		cAnoMes := Substr(Dtos(dDataBase),1,6)
	EndIf

	dDtAnoMes	:= CToD("01"+"/"+Substr(cAnoMes,5,2)+"/"+Substr(cAnoMes,1,4))

	cQuery := " SELECT SRA.R_E_C_N_O_ AS RECNORA, SRA.* FROM " + RetSqlName( "SRA" ) + " SRA "
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND RA_FILIAL = '"+xFilial("SRA")+"' AND RA_CATFUNC NOT IN ('A','P')"

	If!(Empty(cFiltro))
		cQuery +=" " + cFiltro +" "
	EndIf

	cQuery += " ORDER BY RA_FILIAL, RA_MAT "

   	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSRA, .F., .T.)
   	TCSETFIELD(cAliasSRA,"RA_ADMISSA","D")

	(cAliasSRA)->( DbGoTop() )

	While (cAliasSRA)->( !Eof() )
		SRA->(DbGoTO((cAliasSRA)->RECNORA))

		DbSelectArea("SRF")
		SRF->( dbSetOrder(1) )
		If SRF->( dbseek( xFilial("SRF") + SRA->RA_MAT ) )
			//Ja foi convertido
			If SRF->RF_PD $ cPdFer + "*" + cPdRes
				(cAliasSRA)->( DbSkip() )
				Loop
			EndIf
			dDtIni := If(SRA->RA_CATFUNC $ "A*P", Max(SRF->RF_DATABAS,SRA->RA_ADMISSA) , SRA->RA_ADMISSA) //IRÁ CRIAR TODOS OS PERÍODOS DESDE ADMISSAO
			dDtFim := SRF->RF_DATAFIM

			If Empty(dDtFim)
				dDtFim := YearSum( dDtIni , 1 ) - 1
			EndIf

			//antes de fazer qualquer alteracao na SRF, verifica se ha ferias programadas e guarda as informacoes.
			If !Empty(SRF->RF_DATAINI) .OR. !Empty(SRF->RF_DATINI2) .OR. !Empty(SRF->RF_DATINI3)
				aProgFer := {SRF->RF_DATABAS, SRF->RF_DATAINI, SRF->RF_DATINI2, SRF->RF_DATINI3, SRF->RF_DFEPRO1, SRF->RF_DFEPRO2, SRF->RF_DFEPRO3, SRF->RF_DABPRO1, SRF->RF_DABPRO2, SRF->RF_DABPRO3}
				RecLock("SRF",.F.)
					SRF->RF_DATAINI := CToD("//")
					SRF->RF_DATINI2 := CToD("//")
					SRF->RF_DATINI3 := CToD("//")
					SRF->RF_DFEPRO1 := 0
					SRF->RF_DFEPRO2 := 0
					SRF->RF_DFEPRO3 := 0
					SRF->RF_DABPRO1 := 0
					SRF->RF_DABPRO2 := 0
					SRF->RF_DABPRO3 := 0
				SRF->( MsUnLock() )
			EndIf

			If SRA->RA_SITFOLH == 'D'
				RecLock("SRF",.F.)
		  		SRF->RF_DATABAS := dDtIni
		  		SRF->RF_DATAFIM := dDtFim
		  		SRF->RF_PD		:= If (SRA->RA_CATFUNC $ "E*G", cPdRes , cPdFer )
		  		SRF->RF_STATUS	:= "3"
		  		MsUnLock()
			EndIf

			nRecSRF := SRF->(Recno())
		Else
	   		dDtIni := SRA->RA_ADMISSA
  			dDtFim := YearSum( dDtIni , 1 ) - 1
		EndIf

		If SRA->RA_SITFOLH == 'D' .and. (!lPar05 .OR. (lPar05 .AND. !empty(dPerIniDem) .AND. SRA->RA_DEMISSA <= dPeriniDem))
			(cAliasSRA)->( DbSkip() )
			Loop
		EndIf

		cAnoIni		:= AnoMes(dDtIni)

		If SRA->RA_SITFOLH == 'D' .and. !Empty(SRA->RA_DEMISSA)
			cAnoFim		:= AnoMes(SRA->RA_DEMISSA)
		Else
	  		cAnoFim		:= If(dDtAnoMes <= dDtFim, AnoMes(dDtFim), cAnoMes)
	 	EndIf

	 	dDtFechado := CtoD("//")

  		While cAnoIni < cAnoFim
  			nDiasPg 	:= 0
  			nFalVenc	:= 0
  			nFalProp	:= 0
  			nDiasVen	:= 0
  			nDiasDir	:= 0
  			nDiasAVen	:= 0
  			dNewPer		:= CtoD("")
  			cObsFer		:= ""
  			cStatus 	:= ""

  			fTrataAfas(dDtIni,@dDtFim,@cStatus,@nDiasDir,@nDiasVen,@nDiasAVen,@nDiasPg,@nFalVenc,@nFalProp,@dNewPer,@cObsFer,aCodFol,@lContinua)

	  		DbSelectArea("SRF")
	  		SRF->( dbSetOrder(1) )

			If !Empty(nRecSRF)
		  		SRF->(DbGoTo(nRecSRF))
		  		If SRF->RF_DATABAS <> dDtIni //Garante que o primeiro registro nao ficara em branco caso a data inicial seja alterada
		  			If !SRF->( Dbseek( xFilial("SRF") + SRA->RA_MAT + Dtos(dDtIni) ) )
		  				SRF->(DbGoTo(nRecSRF))
			  			RecLock("SRF",.F.)
			  			SRF->RF_DATABAS := dDtIni
			  			MsUnLock()
			  		EndIf
		  		EndIf
		  		nRecSRF := 0
		 	EndIf

		 	If SRF->( Dbseek( xFilial("SRF") + SRA->RA_MAT + Dtos(dDtIni) ) )

			 	If !Empty(SRF->RF_IVENPEN) .And. !Empty(SRF->RF_FVENPEN)
			 		nRecSRF   := SRF->(Recno())
			 		dDtIniPen := SRF->RF_IVENPEN
			 		dDtFimPen := SRF->RF_FVENPEN
			 		nDirPen	  := SRF->RF_DVENPEN
			 		nDiasProp := 0
				 	nDiasProPg:= 0
				 	nDiasReces:= 0

			 		If !SRF->(DbSeek(xFilial("SRF")+SRA->RA_MAT+DtoS(dDtIniPen)))
			 			If SRA->RA_CATFUNC $ "E*G"
			 				DbSelectArea("SRD")
			 				DbSetOrder(6) //RD_FILIAL+RD_MAT+RD_PD+RD_ROTEIR+DTOS(RD_DATPGT)
			 				If DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cPdRes) //Soma todos os dias de rescesso concedidos, não tem como saber a qual período aquisito refere-se o rescesso.
			 					While SRD->(!Eof() .and. RD_FILIAL + RD_MAT + RD_PD == SRA->RA_FILIAL + SRA->RA_MAT + cPdRes )
			 						nDiasReces += SRD->RD_HORAS
			 						SRD->(DbSkip())
			 					EndDo
			 				EndIf
			 			Else
				 			DbSelectArea("SRH")
				 			DbSetOrder(1)
				 			If DbSeek(xFilial("SRH")+SRA->RA_MAT+DtoS(dDtIniPen))
				 				While SRH->(!Eof() .and. RH_FILIAL + RH_MAT + DtoS(RH_DATABAS) == SRA->RA_FILIAL+SRA->RA_MAT+DtoS(dDtIniPen))

					 				nDiasProp += SRH->RH_DFERVEN
					 				nDiasProPg+= SRH->RH_DFERIAS + SRH->RH_DABONPE
					 				SRH->(Dbskip())
					 			EndDo
				 			Else
				 				nDiasProp := ( DateDiffMonth( dDtIniPen , dDtFimPen ) * 2.5 )
				 				nDiasProPg:= nDiasProp - nDirPen
							EndIf
						EndIf
						DbSelectARea("SRF")
				 		RecLock("SRF",.T.)
		  				RF_FILIAL 		:= xFilial("SRF")
		  				RF_MAT	   		:= SRA->RA_MAT
		  				RF_DATABAS 		:= dDtIniPen
		  				RF_DATAFIM		:= dDtFimPen
				  		RF_PD 			:= If (SRA->RA_CATFUNC $ "E*G", cPdRes , cPdFer )
				  		RF_DIASDIR		:= 30
				  		If SRA->RA_CATFUNC $ "E*G"
			  				If SRA->RA_SITFOLH == 'D'
			  					RF_STATUS		:= "3"
			  				Else
			  					RF_STATUS		:= If(nDiasReces >= 30,"3","1")          //Aberto
			  				EndIf
			  				RF_DFERAAT 	:= 0
			  				RF_DFERANT	:= Min(30,nDiasReces)
			  				nDiasReces  := Max(( nDiasReces - 30 ),0)
			  			Else
			  				If SRA->RA_SITFOLH == 'D'
			  					RF_STATUS		:= "3"
			  				Else
			  					RF_STATUS		:= If(nDiasProPg >= 30,"3","1")          //Aberto
			  				EndIf
			  				RF_DFERAAT 	:= nDiasProp	//Ferias Proporc.
			  				RF_DFERANT	:= nDiasProPg
				  		EndIf
				  		RF_DFERVAT 	:= 0 		   	//Ferias Vencidas
			  			RF_DVENPEN	:= 0
			  			RF_DFALVAT	:= 0
			  			RF_DFALAAT	:= 0
			  			RF_OBSERVA 	:= ""

			  			MsUnLock()
			  		EndIf

		  			SRF->(DbGoTo(nRecSRF)) //Retorna registro original
		  			nRecSRF := 0
		  		EndIf

		  		RecLock("SRF",.F.)
		  	Else
  				RecLock("SRF",.T.)
  				RF_FILIAL 		:= xFilial("SRF")
  				RF_MAT	   		:= SRA->RA_MAT
  				RF_DATABAS 		:= dDtIni
  			EndIf

	  		RF_PD 			:= If (SRA->RA_CATFUNC $ "E*G", cPdRes , cPdFer )
	  		RF_DATAFIM 		:= dDtFim
	  		RF_DIASDIR		:= nDiasDir

	  		If SRA->RA_SITFOLH == 'D'
	  			RF_STATUS		:= "3"
	  		Else
	  			RF_STATUS		:= cStatus
	  		EndIf

	  		If cStatus == "3" .and. ( Empty(dDtFechado) .or. dDtFechado < RF_DATABAS)
	  			dDtFechado := RF_DATABAS
	  		EndIf

  			RF_DFERVAT 		:= nDiasVen //Ferias Vencidas
  			RF_DFERAAT 		:= nDiasAVen//Ferias Proporc.
  			RF_DFALVAT		:= Max(nFalVenc,0)
  			RF_DFALAAT		:= Max(nFalProp,0)
  			RF_OBSERVA 		:= cObsFer
  			RF_DFERANT		:= nDiasPg
  			RF_PAR13AT		:= 0

	  		SRF->( MsUnlock() )

	  		If !Empty(dNewPer)
	  			dDtIni := dNewPer
	  		Else
		  		dDtIni := dDtFim + 1
		  	EndIf

  			dDtFim := YearSum( dDtIni , 1 ) - 1

	  		If !lContinua .or. cAnoIni == AnoMes(dDtIni) //Se AnoMes não mudou, sai do laço
	  			Exit
	  		EndIf

	  		cAnoIni := AnoMes(dDtIni)

  		EndDo

		DbSelectArea("SRH")
		DbSetOrder(1)
		//Verifica se todos os periodos da SRH existem e os cria se necessario.
		If DbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
			dDtAux := CtoD("//")
			nFerVen := 0
			While SRH->(!Eof() .and. RH_FILIAL + RH_MAT == SRA->RA_FILIAL+SRA->RA_MAT)
				//Se nao encontrar registro no SRF, efetua a gravacao
				If !(SRF->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+DtoS(SRH->RH_DATABAS)))) //.or. dDtAux == SRH->RH_DATABAS
					RecLock("SRF",.T.)
	  				SRF->RF_FILIAL 		:= SRA->RA_FILIAL
	  				SRF->RF_MAT	   		:= SRA->RA_MAT
			  		SRF->RF_PD 			:= If (SRA->RA_CATFUNC $ "E*G", cPdRes , cPdFer )
			  		SRF->RF_DIASDIR		:= 30
		  			SRF->RF_DFERAAT		:= 0					//Ferias Proporc.
		  			SRF->RF_DVENPEN		:= 0
		  			SRF->RF_DFALVAT		:= 0
		  			SRF->RF_DFALAAT		:= 0
		  			SRF->RF_OBSERVA		:= ""
				Else
					RecLock("SRF",.F.)
				EndIf

  				SRF->RF_DATABAS		:= SRH->RH_DATABAS
  				SRF->RF_DATAFIM		:= SRH->RH_DBASEAT
				SRF->RF_PERC13S		:= SRH->RH_PERC13S

				If lExistCpo
				  	dDtPagFer := SRH->RH_DTRECIB
				Else
				  	dDtPagFer := SRH->RH_DTRECIB
				EndIf
			  	If SRR->( dbSeek( SRF->RF_FILIAL+SRF->RF_MAT+"F"+dToS(dDtPagFer)+aCodFol[22,1] ) )
				  	While SRR->( !EoF() ) .And. SRR->RR_FILIAL+SRR->RR_MAT+SRR->RR_TIPO3+dToS(SRR->RR_DATA)+SRR->RR_PD == SRF->RF_FILIAL+SRF->RF_MAT+"F"+dToS(dDtPagFer)+aCodFol[22,1]
				  		SRF->RF_PAR13AT += SRR->RR_VALOR
				  		SRR->( dbSkip() )
				  	End While
			  	EndIf

	  			If dDtAux <> SRH->RH_DATABAS
		  			SRF->RF_DFERANT		:= SRH->RH_DFERIAS + SRH->RH_DABONPE
		  			nFerVen := SRF->RF_DFERVAT
		  		Else
		  			SRF->RF_DFERANT		:= SRF->RF_DFERANT + SRH->RH_DFERIAS + SRH->RH_DABONPE
		  		EndIf

  				If SRF->RF_DFERVAT == 0
  					If SRH->RH_DFERVEN >= SRF->RF_DIASDIR
  						SRF->RF_DFERVAT		:= SRH->RH_DFERVEN  	//Ferias Vencidas
  						SRF->RF_DFERAAT     := 0
  					Else
  						SRF->RF_DFERAAT		:= SRH->RH_DFERVEN
  					EndIf
  				EndIf

		  		If SRA->RA_SITFOLH == 'D'
		  			SRF->RF_STATUS		:= "3"
		  		Else
		  			If SRF->RF_STATUS <> "2"
		  				If(nFaltas := SRH->RH_DFALTAS) > 0
		  					TabFaltas(@nFaltas)
		  				EndIf
			  			If SRF->RF_DFERANT + nFaltas >= SRF->RF_DIASDIR
			  				SRF->RF_STATUS		:= "3"
			  			Else
			  				SRF->RF_STATUS		:= "1"
			  			EndIf
			  		EndIf
		  		EndIf

	  			dDtAux				:= SRH->RH_DATABAS

				SRF->(MsUnLock())

				SRH->(DbSkip())

				If SRF->RF_STATUS == "3" .and. ( Empty(dDtFechado) .or. dDtFechado < dDtAux)
					dDtFechado := dDtAux
				EndIf
			EndDo
		EndIf

		If !Empty(dDtFechado)
			DbSelectArea("SRF")
			SRF->( dbSetOrder(1) )
			If SRF->( dbseek( SRA->RA_FILIAL + SRA->RA_MAT ) )
				While SRF->(!Eof() .and. RF_FILIAL + RF_MAT == SRA->RA_FILIAL + SRA->RA_MAT)
					If SRF->RF_STATUS == '1' .AND. SRF->RF_DATABAS < dDtFechado
						RecLock("SRF",.F.)
						SRF->RF_STATUS = "3"
						SRF->RF_DFERANT := SRF->RF_DFERVAT + SRF->RF_DFERAAT
						SRF->(MsUnLock())
					EndIf
					SRF->(DbSkip())
				EndDo
			EndIf
		EndIf

		// Tratamento para programação de férias
		If !Empty(aProgFer) .AND. SRF->( DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + DtoS(aProgFer[1])) ) //.And. SRF->RF_STATUS <> "1"
			RecLock("SRF",.F.)
				SRF->RF_DATAINI := aProgFer[2]
				SRF->RF_DATINI2 := aProgFer[3]
				SRF->RF_DATINI3 := aProgFer[4]
				SRF->RF_DFEPRO1 := aProgFer[5]
				SRF->RF_DFEPRO2 := aProgFer[6]
				SRF->RF_DFEPRO3 := aProgFer[7]
				SRF->RF_DABPRO1 := aProgFer[8]
				SRF->RF_DABPRO2 := aProgFer[9]
				SRF->RF_DABPRO3 := aProgFer[10]
			SRF->( MsUnLock() )
		EndIf
		aProgFer := {}
		(cAliasSRA)->( DbSkip() )
	EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  fTrataAfas ºAutor  |Leandro Drumond     º Data ³  10/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fTrataAfas(dDtIni,dDtFim,cStatus,nDiasDir,nDiasFeve,nDiasFeAv,nDiasPg,nFalVenc,nFalProp,dNewPer,cObsFer,aCodFol,lContinua)

Local aPerFerAux:= {}
Local aTabFer	:= {}
Local dDataAux	:= CtoD("")
Local nX		:= 0
Local lLoop		:= .T.
Local dDatBas	:= Stod(cAnoMes+"01")

Private nAvosTot    := 0
Private nFato       := 0
Private nTotDiasPer := 0

DbSelectArea("SRH")
SRH->( dbsetorder(1) )

fTab_Fer(@aTabFer)

If Len(aTabFer) > 0
	nDiasDir := aTabFer[3]
	nFator	 := aTabFer[4]
Else
	nDiasDir := 30
	nFator	 := 2.5
EndIf

If AnoMes(dDtFim) <= cAnoMes
	nDiasFeve := nDiasDir
	nDiasFeAv := 0
Else
	nDiasFeve := 0
	dDataAux  := StoD(cAnoMes + AllTrim(Str(F_ULTDIA(StoD(cAnoMes + "01")))))
	nDiasFeAv := DateDiffMonth( dDtIni , dDataAux ) * nFator
EndIf

aAdd(aPerFerAux,{		dDtIni			,;	// 01
						dDtFim			,;	// 02
						0.00			,;	// 03
						0.00			,;	// 04
						0.00			,;	// 05
						""				,;	// 06
						CtoD("")		,;	// 07
						"1"				,;	// 08
						CtoD("")		,;	// 09
						0.00			,;	// 10
						0.00			,;	// 11
						CtoD("")		,;	// 12
						CtoD("")		,;	// 13
						0.00			,;	// 14
						0.00			,;	// 15
						0.00			,;	// 16
						0.00			,;	// 17
						0.00			,;	// 18
						0.00		    ,;	// 19
						0.00			,;	// 20
						0.00		    ,;	// 21
						0.00			,;	// 22
						0.00			,;	// 23
						0.00			,;	// 24
						0.00			,;	// 25
						0.00			,;	// 26
						0.00			,;	// 27
						0.00			,;	// 28
						0.00			,;  // 29
						0.00			;	// 30
				})

dDtLimite := Min(dDatBas,dDtFim)

fValPerFerias(dDtLimite,dDtIni,@aPerFerAux,,,,,12,@nDiasFeve,@nDiasFeAv,,@cObsFer,aCodFol,@lContinua)

nDiasBase := 12

For nx := 1 to Len(aPerFerAux)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³ Calcula os dias de ferias vencidas e a vencer.   			 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aPerFerAux[nx,8] == "1"	// Somente periodos abertos.
		nTDiasFe	:= 0  //dias de ferias (avos)
	    nDiasFeve	:= 0  //dias de ferias vencidas
		nDiasFeAv	:= 0  //dias de ferias a vencer
	    nDiasBove	:= 0
		nDiasBoAv	:= 0
		If cPaisLoc == "VEN"
			nDiasBon	:= 0
		    nDiasBoVe	:= 0
			nDiasBoAv	:= 0
			aDiasVen	:= {}
		EndIf
		If cPaisLoc == "ANG"
			aDiasAng	:= {}
		EndIf
		If cPaisLoc == "EQU"
			aDiasEqu	:= {}
		EndIf
		dDtAux1		:= dDtAux2 := aPerFerAux[nx,1]
		dFimDtBas	:= aPerFerAux[nx,2]
		dFimDtBas	:= Min( dFimDtBas, dDtLimite )

		If cPaisLoc == "ARG"
			lLoop := !DiasFerArg(lPerFeAc,dDtAux1,dFimDtBas,@nTDiasFe)
		EndIf

		If cPaisLoc == "VEN"
			If !(lLoop := DiasFerVen(dDtAux1,dFimDtBas,@aDiasVen,nX==Len(aPerFerAux)))
				Return
			EndIf
		EndIf

		If cPaisLoc == "ANG"
			If DiasFerAng(dDtAux1,dFimDtBas,@aDiasAng,lAdmissa)
				lLoop := .F.
			EndIf
		EndIf

		If cPaisLoc == "EQU"
			If DiasFerEqu(dDtAux1,dFimDtBas,@aDiasEqu,dDtLimite)
				lLoop := .F.
			EndIf
		EndIf

		If cPaisLoc == "PER"
			lLoop:= .F.
			aPerFerAux[nX][24]:= nDiasFer
			If aPerFerAux[nX][03] == 0
				aDiasPer:= {}
				DiasFerPer(dDtAux1,dFimDtBas,@aDiasPer)

				If !Empty(dDtIniPer) .And. dDtIniPer <= aPerFerAux[nX][02] .And. dDtLimite >= aPerFerAux[nX][02]

					//If dDtLimite >= aPerFerAux[nX][02] //se o periodo aquisitivo fechou
                    aPerFerAux[nX,24] := aDiasPer[1]
					aPerFerAux[nX,03] := aDiasPer[2] - aPerFerAux[nX,14]
					aPerFerAux[nX,04] := 0
					aPerFerAux[nX,15] := aDiasPer[4]
					aPerFerAux[nX,16] := aDiasPer[3]
				Else
					aPerFerAux[nX,24] := aDiasPer[1]
					aPerFerAux[nX,04] := aDiasPer[2]
					aPerFerAux[nX,15] := aDiasPer[4]
					aPerFerAux[nX,16] := aDiasPer[3]
				EndIf

			EndIf
		EndIf

		If lLoop

	        If cPaisLoc == "VEN"
				nFatorFe	:= aDiasVen[1] / (DateDiffMonth(dDtAux1,If(nX = Len(aPerFerAux),fCalcFimAq(dDtAux1),dFimDtBas))+If(Day(dDtAux1)=1,1,0))
				nFatorBo	:= aDiasVen[2] / (DateDiffMonth(dDtAux1,If(nX = Len(aPerFerAux),fCalcFimAq(dDtAux1),dFimDtBas))+If(Day(dDtAux1)=1,1,0))
				nDFalFer	:= aDiasVen[3]
				nDFalBon	:= aDiasVen[4]
				aPerFerAux[nx,19] := aDiasVen[1]
				aPerFerAux[nx,20] := aDiasVen[2]
			EndIf

			//# Verifica novamente o Fator do Ano
			If cPaisLoc == "ARG"
				If MesAno(CtoD("31/12/"+Str(Year(dDtAux1)))) > MesAno(dDtLimite)
					nFator := FatorFerArg(dDtLimite,,aPerFerAux[nx,14])
				Else
					nFator := FatorFerArg(CtoD("31/12/"+Str(Year(dDtAux1))),,aPerFerAux[nx,14])
				EndIf

				//# Grava o Total de Dias de Ferias do Periodo
				aPerFerAux[nx,24] := nTotDiasPer
			EndIf

			While dDtAux2 < dFimDtBas
				dProxMes := dDtAux2 + (f_UltDia(dDtAux2) - Day(dDtAux2) + 1)
				nDiaBom  := Min( Day(dDtAux2), f_UltDia(dProxMes) )
				dDtAux2  := CtoD( StrZero(nDiaBom,2)+"/"+StrZero(Month(dProxMes),2)+"/"+StrZero(Year(dProxMes),4),"DDMMYY" )
				dDtAux2  := Min(dDtAux2, dFimDtBas)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada p/alterar a contagem do direito aos avos de |
				//³ acordo com necessidade do usario.(contar baseado em 14 dias) |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc == "PTG"
					If Year(dDtAux2) == Year(SRA->RA_ADMISSA)
						If nTDiasFe < 20
							nTDiasFe += 2
						EndIf
					Else
						nTDiasFe += nFator
					EndIf
				ElseIf cPaisLoc == "ARG"
					nTDiasFe += nFator
				ElseIf cPaisLoc == "VEN"
					nTDiasFe	+= nFatorFe
					nDiasBon	+= nFatorBo
				ElseIf cPaisLoc == "CHI"
					If dDtAux2 - dDtAux1 + 1 >= If(Month(dDtAux1) <> 2,30,28)
					   nTDiasFe += nFator
					Else
						If Type("cTipoRot") <> "U" .And. cTipoRot == "4"
							If f_UltDia(dDtAux1) == 31
								nDiaProp := -1
							ElseIf f_UltDia(dDtAux1) == 29
								nDiaProp := 1
							ElseIf f_UltDia(dDtAux1) == 28
								nDiaProp := 2
							Else
								nDiaProp := 0
							EndIf
							nTDiasFe += nFator *((dDtAux2 - dDtAux1 + nDiaProp) /30 )
						Else
							If dDtAux2 - dDtAux1 + 1 >= 15
						   		nTDiasFe += nfator
						   	EndIf
						EndIf
					EndIf
				ElseIf ExistBlock("GPALTCFE")
					ExecBlock("GPALTCFE",.F.,.F.)
				Else
					//?-Verifica o Parametro MV_SABDOM se funcionario eh Demitido
					If GetMv( "MV_SABDOM" ) == "S" .And. SRA->RA_DEMISSA == dDtAux2
						nSabDom := If( Dow( dDtAux2 ) == 6 , 2 , 0 )
					Else
						nSabDom := 0
					EndIf

					If (dDtAux2 - dDtAux1 + 1 + nSabDom) >= 15	//?-
					   nTDiasFe += nfator
					   //nAvosFe++
					EndIf
				EndIf

				dDtAux1 := dDtAux2
			EndDo

		EndIf

		//Atualizacao dos dias de ferias vencidas e/ou proporcionais
		If 	cPaisLoc == "ANG" .AND. Len(aDiasAng) > 0

			If Type("cAnoMes") == "U"
				If Type("cAnoProc") # "U" .And. Type("cMesProc") # "U"
					cAnoMes := cAnoProc+cMesProc
				EndIf
			EndIf

			If Empty(cAnoMes) .And. Type("cMesAnoRef") # "U"
				cAnoMes := cMesAnoRef
			EndIf

			//Na admissao acima da data 15/01 o periodo vencera somente em julho do ano seguinte.
			//Caso o mnemonico P_FEACVEN esteja ativo esta regra nao e aplicada
			If Type("P_FEACVEN") == "U"
				P_FEACVEN := &( AllTrim(Posicione("RCA",1,xFilial("RCA")+"P_FEACVEN","RCA_CONTEU")) )
				P_FEACVEN := If( P_FEACVEN == Nil, .T., P_FEACVEN )
			EndIf

			If !P_FEACVEN
				If lAnoAdm := AnoMes(aPerFerAux[nx,1]) == AnoMes(SRA->RA_ADMISSA) .And. MesDia(SRA->RA_ADMISSA) > "0115"
					lVencPer := cAnoMes >= CValToChar( Year(SRA->RA_ADMISSA)+1 ) + "07"
				Else
					lVencPer := .T.
				EndIf
			Else
				lVencPer := .T.
			EndIf

			//Antes do mes do vencimento atualiza os dias proporcionais
        	If cAnoMes >= AnoMes(aPerFerAux[nx,1]) .and. cAnoMes < AnoMes(aPerFerAux[nx,2])
				If Len( aDiasAng ) > 4
					aPerFerAux[nx,4] := aDiasAng[5] - aPerFerAux[nx][14]
					aPerFerAux[nx,3] := 0
				EndIf

			//Se no vencimento a regra de admissao nao for aplicavel, o periodo sera marcado como vencido
        	ElseIf ( cAnoMes >= AnoMes(aPerFerAux[nx,1]) .and. cAnoMes >= AnoMes(aPerFerAux[nx,2]) .And. !lAnoAdm )
				If Len( aDiasAng ) > 4
					aPerFerAux[nx,3]  := aDiasAng[5] - aPerFerAux[nx][14]
					aPerFerAux[nx,4]  := 0
				EndIf

			//Se no mes do vencimento a regra de admissao for aplicavel, atualiza apenas os dias proporcionais
			ElseIf ( cAnoMes >= AnoMes(aPerFerAux[nx,1]) .and. cAnoMes >= AnoMes(aPerFerAux[nx,2]) ) .And. ( lAnoAdm .And. !lVencPer )
				If Len( aDiasAng ) > 4
					aPerFerAux[nx,4] := aDiasAng[5] - aPerFerAux[nx][14]
					aPerFerAux[nx,3] := 0
				EndIf

			//Se esta ou ja passou do mes do vencimento e ja venceu o prazo da regra de admissao, o periodo sera marcado como vencido
			ElseIf ( cAnoMes >= AnoMes(aPerFerAux[nx,1]) .and. cAnoMes >= AnoMes(aPerFerAux[nx,2]) .And. lVencPer )
				If Len( aDiasAng ) > 4
					aPerFerAux[nx,3]  := aDiasAng[5] - aPerFerAux[nx][14]
					aPerFerAux[nx,4]  := 0
				EndIf

			EndIf

			//Atualiza dias de ausencia convertidos em ferias
			aPerFerAux[nx,23] := aDiasAng[3]

			//Quantidade minima de dias a serem pagos na admissao ou demissao
			aPerFerAux[nx,29] := aDiasAng[4]

		EndIf

		If cPaisLoc == "EQU" .AND. Len(aDiasEqu) > 0
			aPerFerAux[nx,5]  := aDiasEqu[5] 	 // 05 - Dias totais de afastamento por periodo
			aPerFerAux[nx,19] := aDiasEqu[1] 	 // 19 - Total de dias de ferias
			aPerFerAux[nx,20] := aDiasEqu[2] 	 // 20 - Total de dias de bonificacao
        	If (dDtLimite >= aPerFerAux[nx,1] .and. dDtLimite <= aPerFerAux[nx,2]) .or. aPerFerAux[nx,1] > dDtLimite
				aPerFerAux[nx,3]  := 0
				aPerFerAux[nx,4]  := aDiasEqu[3]
				aPerFerAux[nx,17] := 0
				aPerFerAux[nx,18] := aDiasEqu[4]
				aPerFerAux[nx,15] := 0
				aPerFerAux[nx,16] := aDiasEqu[5]
			Else
				aPerFerAux[nx,3]  := aDiasEqu[3] // 03 - Dias de ferias vencidas
				aPerFerAux[nx,4]  := 0			 // 04 - Dias de ferias a vencer
				aPerFerAux[nx,17] := aDiasEqu[4] // 17 - Dias de bono vencido
				aPerFerAux[nx,18] := 0			 // 18 - Dias de bono a Vencer
				aPerFerAux[nx,15] := aDiasEqu[5] // 15 - Dias de falta vencida
				aPerFerAux[nx,16] := 0			 // 16 - Dias de falta a vencer
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	//³ Se Ano Civil e fim do periodo 31/12, os dias serao vencidos. |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "VEN"
			If nTDiasFe == aDiasVen[1]
				nDiasFeVe	:= nTDiasFe
				nDiasFeAv	:= 0
			Else
				nDiasFeAv	:= nTDiasFe
			EndIf
			If nDiasBon == aDiasVen[2]
				nDiasBoVe	:= nDiasBon
				nDiasBoAv	:= 0
			Else
				nDiasBoAv := nDiasBon
			EndIf
		ElseIf !(cPaisLoc $ "ANG*PER")
			If Substr(DTOS(dFimDtBas),5,4) == "1231" .And. lPerFeAc //Variavel carregada em fCalcFimAq()
				nDVencAux := nTDiasFe
			Else
				nDVencAux := INT(Round(nTDiasFe/(nDiasBase*nFator),8))*(nDiasBase*nFator)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   	//³ Ajusta as variaveis de dias de ferias vencidas e a vencer.   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTDiasFe == nDVencAux .or. ( nTDiasFe - aPerFerAux[nX,10] ) == nDVencAux
				nDiasFeve	:= nTDiasFe
				nDiasFeAv	:= 0
			ElseIf aPerFerAux[nX,11] > 0
				nDiasFeve	:= nTDiasFe
				nDiasFeAv	:= 0
			Else
				nDiasFeAv	:= nTDiasFe
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Redistribui os dias de vencidas e a vencer.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nToDiaPer := (nDiasBase*nFator)
		EndIf

		If !(cPaisLoc $ "ANG*PER*EQU")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   	//³ Ajusta o direito de ferias no array dos periodos aquisitivos.|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//-- Abate os avos que o funcionario ficou afastado por tipo R*W*X e considera como ferias vencidas.
			If cPaisLoc == "ARG"

				If Alltrim(FunName()) == "GPEM030" .Or. Alltrim(FunName()) == "GPEM040" .Or. Alltrim(FunName()) == "GPEM060" .Or. Alltrim(FunName()) == "GPEM630"

					If Type("P_ARRDVAC") # "U" .And. P_ARRDVAC == "1"
						//# Arredonda os Dias de Vacaciones
						aPerFerAux[nx,3]	:= Round( Iif(nDiasFeVe>0,nDiasFeVe - (Iif(aPerFerAux[nx,2]<=dDtLimite,aPerFerAux[nx,10],0)),0) ,0)
						aPerFerAux[nx,4]	:= Round( Iif(nDiasFeAv>0,nDiasFeAv - (Iif(aPerFerAux[nx,2]<=dDtLimite,aPerFerAux[nx,10],0)),0) ,0)
					Else
						aPerFerAux[nx,3]	:= Iif(nDiasFeVe>0,nDiasFeVe - (Iif(aPerFerAux[nx,2]<=dDtLimite,aPerFerAux[nx,10],0)),0)
						aPerFerAux[nx,4]	:= Iif(nDiasFeAv>0,nDiasFeAv - (Iif(aPerFerAux[nx,2]<=dDtLimite,aPerFerAux[nx,10],0)),0)
					EndIf
				Else

					If Type("P_ARRDVAC") # "U" .And. P_ARRDVAC == "1"
						//# Arredonda os Dias de Vacaciones
						nDiasVArg           := Round( Iif(nDiasFeVe>0,nDiasFeVe - (Iif(aPerFerAux[nx,2]<=dDtLimite,aPerFerAux[nx,10],0)),0) ,0)
						aPerFerAux[nx,3]	:= Round( Iif( nDiasVArg       >  aPerFerAux[nx,24]                                              .AND. ;
													    !( SRA->RA_ADMISSA >= aPerFerAux[nx,01] .AND. SRA->RA_ADMISSA <= aPerFerAux[nx,02] ) .AND. ;
													    !( dDtLimite       >= aPerFerAux[nx,01] .AND. dDtLimite       <= aPerFerAux[nx,02] )     , ;
														   aPerFerAux[nx,24] , nDiasVArg) ,0)
						aPerFerAux[nx,4]	:= Round( Iif(nDiasFeAv>0,nDiasFeAv - (Iif(aPerFerAux[nx,2]<=dDtLimite,aPerFerAux[nx,10],0)),0) ,0)
					Else
						nDiasVArg           := Iif(nDiasFeVe>0,nDiasFeVe - (Iif(aPerFerAux[nx,2]<=dDtLimite,aPerFerAux[nx,10],0)),0)
						aPerFerAux[nx,3]	:= Iif( nDiasVArg      >  aPerFerAux[nx,24]                                              .AND. ;
											    !( SRA->RA_ADMISSA >= aPerFerAux[nx,01] .AND. SRA->RA_ADMISSA <= aPerFerAux[nx,02] ) .AND. ;
											    !( dDtLimite       >= aPerFerAux[nx,01] .AND. dDtLimite       <= aPerFerAux[nx,02] )     , ;
												   aPerFerAux[nx,24] , nDiasVArg )
						aPerFerAux[nx,4]	:= Iif(nDiasFeAv>0,nDiasFeAv - (Iif(aPerFerAux[nx,2]<=dDtLimite,aPerFerAux[nx,10],0)),0)
					EndIf
				EndIf
			Else
				aPerFerAux[nx,3]	:= Iif(nDiasFeVe>0,nDiasFeVe - (Iif(nDiasFeAv == 0,aPerFerAux[nx,10],0)),0)
				aPerFerAux[nx,4]	:= Iif(nDiasFeAv>0,nDiasFeAv - (Iif(nDiasFeVe == 0,aPerFerAux[nx,10],0)),0)
			EndIf

			If cPaisLoc == "VEN"
				aPerFerAux[nx,17] := nDiasBoVe
				aPerFerAux[nx,18] := nDiasBoAv
				If nx < Len(aPerFerAux)
					aPerFerAux[nx,15] := nDFalFer
					aPerFerAux[nx,21] := nDFalBon
				Else
					aPerFerAux[nx,16] := nDFalFer
					aPerFerAux[nx,22] := nDFalBon
				EndIf
			EndIf
		EndIf
	EndIf
Next nx

/**/
If AnoMes(dDtIni) < cAnoMes .and. SRH->( dbseek( xFilial("SRH") + SRA->RA_MAT + dTos(dDtIni) ) ) .And. SRH->RH_DFERIAS > 0 .AND. !(ISINCALLSTACK("RHIMP01"))
	dDtFim 			:= SRH->RH_DBASEAT
	cStatus     	:= "3"
	nDiasPg			:= SRH->RH_DFERIAS
	nDiasFeve   	:= if(nDiasDir <= SRH->RH_DFERVEN,SRH->RH_DFERVEN,0)
	nDiasFeAv   	:= if(nDiasDir > SRH->RH_DFERVEN,SRH->RH_DFERVEN,0)
Else
	dDtFim		:= aPerFerAux[1][2]
	cStatus 	:= aPerFerAux[1][8]
	dNewPer		:= aPerFerAux[1][9]
	nDiasFeVe 	:= Max(aPerFerAux[1,3],0)
	nDiasFeAv 	:= Max(aPerFerAux[1,4],0)
EndIf

If nDiasFeVe > 0
	nFalVenc	:= aPerFerAux[1][15]
	nFalProp 	:= aPerFerAux[1][16] := 0 //Zera proporcionais
Else
	nFalProp	:= aPerFerAux[1][16]
	nFalVenc 	:= aPerFerAux[1][15] := 0 //Zera vencidas
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPECONV   ºAutor  ³Microsiga           º Data ³  10/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fValPerFerias(	dDtLimite,;		// Data de referencia do processamento
								dDtBasFer,;		// Data base inicial do periodo aquisitivo mais antigo
								aPerFerias,;	// Array com os periodos a serem verificados
								nTDiasAfa,;		// Total de dias de afastamentos do periodo
								cTipAfa,;		// Codigos dos afastamentos que deverao ser tratados
								lDiasAfAcum,;	// Retona dias de afastamentos acumulados
								dRetFimOP,;		// Data de retorno do afastamento
								nDiasBase,;
								nDiasFeVe,;
								nDiasFeAv,;
								nDVencAux,;
								cDescTipAfa,;
								aCodFol,;
								lContinua )
Local aAfast		:= {}
Local aAfastAux		:= {}
Local cTip180		:= ""
Local cTipSusp		:= ""
Local nAvosAf		:= 0
Local nDiasAf		:= 0
Local nCnt			:= 0
Local nDias180 		:= 0
Local nDias30	 	:= 0
Local nDiasSusp		:= 0
Local nAvosSusp		:= 0
Local nTotSusp		:= 0
Local nTotPerSusp	:= 0
Local nVezes		:= 0
Local nX			:= 0
Local nFaltas		:= 0
Local dRet30		:= CtoD("")
Local dRet180		:= CtoD("")
Local dRetSusp		:= CtoD("")
Local dNewPerIni	:= CtoD("")
Local dIniDtBas		:= CtoD("")
Local dFimDtBas 	:= CtoD("")
Local dIniPerOk 	:= CtoD("")
Local lMudaPer		:= .F.
Local lSimAf1Per   	:= .F.	    // Tem dia de afastamento RWX no 1o periodo de ferias
Local lSimAf2Per   	:= .F.      // Tem dia de afastamento RWX no 2o periodo de ferias
Local dDatBas	    := Stod(cAnoMes+"01")
Local lSemRetorno   := .F.		//Indica que não houve retorno do afastamento
/*	Estrutura aPerFerias
	// 01 - Inicio Database de Ferias
	// 02 - Final Database de Ferias
	// 03 - Dias de ferias vencidas
	// 04 - Dias de ferias a vencer
	// 05 - Dias totais de afastamento por periodo
	// 06 - Descricao do tipo de afastamento do periodo
	// 07 - Data de original de termino do p.aquisitivo quando houver prorrogacao do mesmo RWX
	// 08 - Status do periodo de ferias:  1-Ativo (Vencidos/A vencer)/2-Prescrito (Perdido)/3-Pago
	// 09 - Data de Inicio do Proximo periodo caso seja um periodo perdido.
	// 10 - Quantidade dias de deducao para o direito apurado no periodo
	// 11 - Dias Vencidos Pendentes
    // 12 - Data Inicia Vencido Pendente
	// 12 - Data Inicia Vencido Pendente
    // 13 - Dias de Ferias Antecipadas
	// 14 - Dias de Ferias Antecipadas
	// 15 - Dias de Faltas Vencidas
	// 16 - Dias de Faltas a Vencer
	// 17 - Dias de bono vencido
	// 18 - Dias de bono a Vencer
	// 19 - Total de dias de ferias
	// 20 - Total de dias de bonificacao
	// 21 - Dias de Faltas vencidas bonificacao
	// 22 - Dias de ¦Faltas a Vencer bonificacao
	// 23 - Dias de ausencia convertidos em ferias
	// 24 - Total de Dias de Ferias do Periodo
*/

DEFAULT nDiasBase := 12
DEFAULT nDiasFeVe := 0
DEFAULT nDiasFeAv := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Posiciona no primeiro periodo aquisitivo de ferias em aberto p/|
//| processamento dos calculos de localizacoes.                    |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos		:= 1
nVezes		:= Len(aPerFerias)
For nx := nPos to nVezes
	//-- Processa somente para periodos aberto e virtuais, periodos perdidos serao desconsiderados.
	cDescTipAfa := ""										// Tipo de afastamento que ocasionou a troca do periodo
	dIniPerOk	:= CtoD("")									// Data de inicio do periodo aquisitivo quando houve perda do periodo aquisitivo anterior.
	dDtFimOk    := CtoD("")									// Fim do periodo aquisitivo valido
	If aPerFerias[nx,8] $ "1"
		If !Empty(dNewPerIni)
			aPerFerias[nx,1] := dNewPerIni
			aPerFerias[nx,2] := fCalcFimAq(dNewPerIni)
			dNewPerIni		 := aPerFerias[nx,2] + 1
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	//³ Atualiza o inicio e o fim da data base para avaliacao.   	 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Periodo normal sem alteracao na data base de inicio das ferias.
		dIniDtBas	:= aPerFerias[nx,1]
		dFimDtBas	:= aPerFerias[nx,2]
		dFimDtBas	:= Min( dFimDtBas, dDtLimite )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	//³ Busca os dias de afastamento do periodo corrente.  			 |
	   	//³ O-Acidente P-Doenca  R-servico militar  X-Licenca sem Venc.  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAfast  := {}
		nAvosAf := nDiasAf := 0
		fRetAfas(dIniDtBas,dFimDtBas,cTipAfa,@nAvosAf,@nDiasAf,,@aAfast,,.F.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   	//³ A partir do array aAfast, obtem dias e retorno do afastamento|
	   	//³ Elementos do Array aAfast[Avos,Dias,Inicio,Fim,Tipo]		 |
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//| Quando existir o afastamento de aposentadoria por invalidez  |
		//| deve tratar como Doença ou Acidente de Trabalho porem ira    |
		//| preservar a data de retorno p/afast. O e P.                  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nDias180 	:= 0
		dRet180		:= CtoD("")
		cTip180		:= ""
		nDias30	 	:= 0
		dRet30		:= CtoD("")
		nDiasSusp	:= 0
		nAvosSusp	:= 0
		dRetSusp	:= CtoD("")
		nTotSusp	:= 0
		nTotPerSusp	:= 0
		cTipSusp	:= ""

		For nCnt := 1 To Len(aAfast)
			If ( dIniDtBas == dDtBasFer .or. (dIniDtBas > dDtBasFer .and. aPerFerias[nx,2] > dDtLimite)).And. (aAfast[nCnt,7] == "2" .and. aAfast[nCnt,2] > 0 )
				//Para rescisao, verificar se inicio ou fim do afastamento esta dentro do 1.periodo de ferias, levando em consideracao
				//data da rescisao como fim do periodo.
				If !Empty(aAfast[nCnt,4]) .and. aAfast[nCnt,3] <=  dFimDtBas .and. aAfast[nCnt,4] >= fCalcFimAq(dDtBasFer) 	
					lSimAf1Per	:= .T. // TEM afastamento X,R,W no primeiro periodo de ferias			
				EndIf				
			ElseIf dIniDtBas >  dDtBasFer .And. (aAfast[nCnt,7] == "2" .and. aAfast[nCnt,2] > 0 )
				lSimAf2Per 	:= .T. // TEM afastamento X,R,W no segundo periodo de ferias
			EndIf

			If aAfast[nCnt,7] == "1"	//Perde ferias apos 180 dias
				nDias180 	+= aAfast[nCnt,2]    // Dias afastado
				If !lSemRetorno
					dRet180	 	:= aAfast[nCnt,4]    // Data do retorno
				EndIf
				If Empty(aAfast[nCnt,4])
					lSemRetorno := .T. //Se houve um afastamento sem retorno, não altera mais dRet180
				EndIf
				cTip180	 	:= aAfast[nCnt,16]   // Tipo de afastamento
				cTipAux		:= aAfast[nCnt,13]
			ElseIf aAfast[nCnt,7] == "2"	//Suspensa do periodo
				nDiasSusp	+= aAfast[nCnt,2]	// Dias afastado
				dRetSusp	:= If(lSimAf1Per,If(Empty(aAfast[nCnt,4]),dDatBas,aAfast[nCnt,4]),dRetSusp) 				// Data do retorno - Se nao houve afastamento no 1o periodo nao posso mudar a data de termino do periodo aquisitivo de ferias.
				cTipSusp    := AllTrim(aAfast[nCnt,16])                            	// Tipo de afastamento
				nTotSusp	+= (If(Empty(aAfast[nCnt,4]),dDatBas,aAfast[nCnt,4]) - aAfast[nCnt,3])+1                	// Total de Dias Afatados (Data Fim - Data Inicio)
				If fCalcFimAq(dDtBasFer) < aAfast[nCnt,4] //Afastamento terminou em outro período aquisitivo
					nTotPerSusp	+= ( aAfast[nCnt,4] - fCalcFimAq(dDtBasFer) ) + 1
				EndIf
				If dRetSusp > dFimDtBas
					fRetAfas(dIniDtBas,dRetSusp,cTipAfa,@nAvosAf,@nDiasAf,,@aAfastAux,,.F.)
					nAvosSusp += nAvosAf
				Else
					nAvosSusp	+= aAfast[nCnt,1]   // Avos perdidos no afastamento
				EndIf
				cTipAux		:= aAfast[nCnt,13]
				If Empty(dRetSusp) .and. Empty(aAfast[nCnt,4])
					lContinua := .F.
				EndIf
			ElseIf aAfast[nCnt,7] == "3"//Perde ferias apos 30 dias
				nDias30		+= aAfast[nCnt,2]     		// Dias afastado
				If !lSemRetorno
					dRet30		:= aAfast[nCnt,4]     		// Data do retorno
				EndIf
				If Empty(aAfast[nCnt,4])
					lSemRetorno := .T. //Se houve um afastamento sem retorno, não altera mais dRet30
				EndIf
				cTipAux		:= aAfast[nCnt,13]
			EndIf

		Next nCnt

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Atualiza Variavel Com o Total de Dias de Afastamento (O*P)   |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lDiasAfAcum  // Se total de dias afastados (acumulado)
			nTDiasAfa += ( nDias180 + nDiasSusp )
		Else          // Se total de dias do periodo
			nTDiasAfa := nDias180 + nDiasSusp
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Trata a perda do periodo (DOENCA/AC.TRABALHO/L.REMUNERADA)   |
		//| Obs.: Somente deve ser avaliado se afastado mais que 180 dias|
		//|       ou licenca remunerada e afastamento maior que 30 dias. |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nDias180 > 180 .Or. nDias30 > 30

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   		//³ Define o historico da perda do periodo de ferias p/afastamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nDias180 > 180
				cCodTipAfa	:= cTip180
			Else
				cCodTipAfa	:= ""
			EndIf

			cDescTipAfa := PosAlias( "RCM" , cTipAux , xFilial("RCM") , "RCM_DESCRI" , 1  )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Data do novo periodo encontrada a partir da data de retorno. |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(cPaisLoc == "URU")
				If Empty(dIniPerOk) .And. nDias180 > 180
					If !Empty(dRet180)
						dIniPerOk  := dRet180 + 1 // Indica o inicio de um periodo valido
					Else
						aPerFerias[nx,10] := 30 //Periodo foi perdido porem ainda não retornou do afastamento, portanto subtrai 30 dias das férias vencidas
						dIniPerOk  := dRet180 := dDataBase + 1 //Coloca a database + 1 dia para que não sejam criados novos periodos aquisitivos.
					EndIf
					dRetFimOP  := dRet180
					lMudaPer   := .T.
				ElseIf !Empty(dRet30)				// Novo periodo para afastamento por licenca remunerada
					dIniPerOk  := dRet30 + 1       // Indica o inicio de um periodo valido
					lMudaPer   := .T.
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Trata a perda dos meses afastado (S.MILITAR/L.N.REM./M.SIND.)|
		//| Obs.: Deve ser avaliado mesmo sem periodo vencido			 |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nDiasSusp > 0
			nDiasDed :=  0
			If nAvosSusp > 0
				nDiasDed := nAvosSusp * nFator
			ElseIf Day( dIniDtBas ) != 17
				nDiasDed := Int(nDiasSusp/15) * nFator
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   		//³ Encontra o proximo periodo. Exemplo:                         |
	   		//| Ini Periodo   Ini Afast.  Fim Afast.   Retorno   Compl. Per. |
	   		//|	  01/04/97    02/03/98     12/01/99    13/01/99    12/02/99  |
	   		//|                                                              |
	   		//| De 01/04/97 a 02/03/98 sao 11 meses trabalhados. O retorno se|
	   		//| deu em 13/01/99, portanto deve-se trabalhar mais um (1) mes, |
	   		//| ate (12/02/99) para completar o periodo. O Inicio do proximo |
	   		//| periodo neste exemplo, dar-se-a em 13/02/99. (CLT, Art.132)  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(dRetSusp)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   		//³ nDiasSusp   = Dias afastados no periodo aquisitivo                                         	   |
		   		//³ nTotSusp    = Dias afastados (Fim Afastamento - Inicio do afastamento)                     	   |
				//³	nTotPerSusp = Dias afastados do proximo periodo aquisitivo (nTotSusp - nDiasSusp )         	   |
		   		//| 																				           	   |
		        //|Calculo dDtFimOK    															               	   |
		        //|  * Se periodo aquisitivo de ferias, "lMudaPer" = .T., foi alterado devido a perda de periodo   |
		        //|    por afastamento P ou O, e tiver dias de afastamento TIPO X,R,W no 1. ou 2.Perido de ferias. |
				//|    verificar novamente os afastamento (fRetAfas) considerando as datas do novo periodo         |
		        //|    dIniPerOk) 															   	   |
		        //|  * Achando a qtd de dias afastados pelo tipo X, R ou W,  novo peiodo, calcular a data fim  	   |
		        //|    do periodo aquisitivo somando os dias do afastamento (nDiasSusp) no final novo periodo  	   |
		        //|    aquisitivo. 																		   	   	   |
		        //|    					   															   	       	   |
			    //|  * Se periodo aqusitivo nao for alterado, lMudaPer = .F. , e :                                 |
				//|	   * Qtd de Dias em nTotPerSusp for > 0 (zero), ou seja, termino afast. fora periodo aquis.    |
		        //|       => Retorno Afastamento (dRetSusp) + Dias afastados dentro do periodo (nDiasSusp)         |
		        //|    * Qtd de Dias em nTotPerSusp for = 0 (zero), ou seja, fim afast. dentro periodo aquis.:     |
		        //|       => Final do Periodo aquisitivo (fCalcFimArq) + Dias afastados (nDiasSusp )               |
		        //|    * Qtd de Dias em nTotPerSusp for > 0 (zero), ou seja, termino afast. fora periodo aquis.:   |
		        //|       => Retorno Afastamento (dRetSusp) + Dias afastados dentro do periodo (nDiasSusp)         |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(dDtFimOk) .and. (lSimAf2Per .or. lSimAf1Per) // Data Fim esta em branco e tem afastamento (X,R,W )no 1. ou 2.periodo
					If lMudaPer
						aAfast  	:= {}
					    nDiasSusp	:= 0
						dRetSusp 	:= CtoD("")

						fRetAfas(dIniPerOK,fCalcFimAq(dIniPerOk),cTipAfa,'','',,@aAfast,,.F.)

						For nCnt := 1 To Len(aAfast)
								If aAfast[nCnt,7] == "2"	//Suspensa do periodo
									nDiasSusp 	+= aAfast[nCnt,2]      // Dias afastado
									dRetSusp 	:= aAfast[nCnt,4]      // Data do retorno - Se nao houve afastamento no
					            EndIf
						Next nCnt

				   	    dDtFimOk := (fCalcFimAq(dIniPerOk) + nDiasSusp)
				  	Else
						dDtFimOk := If(nTotPerSusp == 0,(fCalcFimAq(dIniDtBas) + nDiasSusp), (dRetSusp + nDiasSusp))
					EndIf

				EndIf
				cCodTipAfa	:= If(cTipSusp == "R", "R", If (cTipSusp == "X", "X", If (cTipSusp == "W","W",cTipSusp ) ) )
				cDescTipAfa := PosAlias( "RCM" , cTipAux , xFilial("RCM") , "RCM_DESCRI" , 1  )

		   	Else
		   		aPerFerias[nx,10]:= nDiasDed
		   	EndIf
		EndIf

		//-- Atualizacao final do periodo aquisitivo corrente no array aPerFerias
		//-- Verifica se a data final do periodo foi modificada por afastamentoS R*X*W
		If !Empty(dDtFimOK)
			aPerFerias[nx,10]:= nDiasDed			// 10 - Dias de deducao do direito a ferias por afastamento RWX
			aPerFerias[nx,7] := aPerFerias[nx,2]	// 07 - Data final original do periodo aquisitivo
			aPerFerias[nx,2] := dDtFimOK			// 02 - Final Database de Ferias
			If Empty(dIniPerOk)
				dNewPerIni := dDtFimOK + 1
			EndIf
		EndIf

		aPerFerias[nx,5] := nDias180 + nDias30 + nDiasSusp	// 05 - Dias totais de afastamento por periodo
		aPerFerias[nx,6] := cDescTipAfa						// 06 - Descricao do tipo de afastamento do periodo

		//-- Ajusta a data Inicial do proximo periodo, quantidades de dias de ferias vencidas e a vencer
		//-- para os tipos de afastamentos O*P*8
		If !Empty(dIniPerOk)
			aPerFerias[nx,3] := 0			// 03 - dias de ferias vencidas
			aPerFerias[nx,4] := 0			// 04 - dias de ferias a vencer
			aPerFerias[nx,8] := "2"			// 08 - Tipo do periodo 2 - Prescrito (Perdido)
			aPerFerias[nx,9] := dIniPerOk	// 09 - Data de Inicio do Proximo periodo aquisitivo quando houver perda do direito
		EndIf

		cPdAux := "'" + aCodFol[54,1] + "','" + aCodFol[203,1] + "','" + aCodFol[242,1] + "','" + aCodFol[244,1] + "'"

		cWhere := "%"
		cWhere += " SRD.RD_FILIAL = '"	 	+ SRA->RA_FILIAL + "' "
		cWhere += " AND SRD.RD_MAT = '" 	+ SRA->RA_MAT    + "' "
		cWhere += " AND SRD.RD_DATARQ >= '"	+ AnoMes(aPerFerias[nX,1]) + "' "
		cWhere += " AND SRD.RD_DATARQ <= '"	+ AnoMes(aPerFerias[nX,2]) + "' "
		cWhere += " AND SRD.RD_PD IN (" 	+ cPdAux   + ") "
		cWhere += "%"

		cAliasQry:= "QSRD"

		BeginSql alias cAliasQry
			SELECT * FROM %table:SRD% SRD
			WHERE 		%exp:cWhere% AND
	 	    SRD.%notDel%
		EndSql

		nFaltas := 0

		While (cAliasQry)->(!Eof())

			fAcumFaltas(AnoMes(aPerFerias[nx,1]),AnoMes(aPerFerias[nx,2]),(cAliasQry)->RD_DATARQ,(cAliasQry)->RD_PD,cAliasQry,@nFaltas,aCodFol)

			(cAliasQry)->(DbSkip())

		EndDo

		(cAliasQry)->(DbCloseArea())

		aPerFerias[nX,15] := nFaltas //Faltas vencidas
		aPerFerias[nX,16] := nFaltas //Faltas a vencer

	EndIf
Next nx

dDtBasFer := If(Empty(dIniPerOk), dDtBasFer, dIniPerOk) // Data atualizada se passada por referencia

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fTab_Fer ³ Autor ³ Emerson Rosa          ³ Data ³ 06.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega tabela para calculo das ferias					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fTab_Fer(aTabFer,lLerTodas)

Local cAlias := ALIAS()
Local cChaveBus
Local dDatBas	:= Stod(cAnoMes+"01")
Local nMesesFunc	:=	MesesFunc(SRA->RA_ADMISSA,dDatBas)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O sistema permite cadastrar uma regra para cada periodo. Ex:³
//³ Meses do Periodo   Nro Periodos   Dias do Mes   Fator do Mes³
//³       12                5              30            2.5    ³
//³       12                5              30            3.5    ³
//³       12                0              30            4.5    ³
//³ Este exemplo indica um periodo de 12 meses, sendo o mes de  ³
//| 30 dias com 2.5 dias nos primeiros 5 periodos (anos), 3.5   ³
//| nos proximos 5 periodos (anos) e 4.5 nos demais.			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lLerTodas := If(lLerTodas == Nil, .F., lLerTodas)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabela para o calculo dos dias de ferias                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTabFer := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca pela chave - FILIAL + SINDICATO						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SRX" )
dbSetOrder(1)
If FPHIST82(SRA->RA_FILIAL,"46",RhTamFilial(SRA->RA_FILIAL)+SRA->RA_SINDICA+"01") .Or.;
   FPHIST82(SRA->RA_FILIAL,"46",RhTamFilial(SRA->RA_FILIAL)+"  "+"01") .Or.;
   FPHIST82(SRA->RA_FILIAL,"46",RhTamFilial(Space(FwSizeFilial()))+SRA->RA_SINDICA+"01") .Or.;
   FPHIST82(SRA->RA_FILIAL,"46",RhTamFilial(Space(FwSizeFilial()))+"  "+"01")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le enquanto for a mesma chave (sequencias diferentes)       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChaveBus := SRX->RX_FILIAL + SRX->RX_TIP + Substr(SRX->RX_COD, 01, 14)
	While SRX->RX_FILIAL + SRX->RX_TIP + Substr(SRX->RX_COD, 01, 14) == cChaveBus
		nMesesPer := Val(Substr(SRX->RX_TXT, 01, 02))  // Meses do Periodo
		nNroMeses := Val(Substr(SRX->RX_TXT, 03, 02))  // Numero de Periodos
		nNroDMes  := Val(Substr(SRX->RX_TXT, 05, 02))  // Dias de cada Mes
		nDiasPMes := Val(Substr(SRX->RX_TXT, 07, 07))  // Fator (Dias por Mes)
		If lLerTodas
			Aadd( aTabFer, { nMesesPer,nNroMeses,Round(nDiasPMes*nMesesPer,0),nDiasPMes } )
		Else
			aTabFer := { nMesesPer,nNroMeses,Round(nDiasPMes*nMesesPer,0),nDiasPMes }
			If (nMesesFunc < nNroMeses*nMesesPer) .Or. nMesesPer == 0
				Exit
			EndIf
		EndIf
		SRX->(dbSkip())
    EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Regra padrao para calculo dos dias de ferias 				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aTabFer) == 0
	aTabFer := { 12, 0, 30, 2.5 }
EndIf

DbSelectArea( cAlias )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConvSRV   ºAutor  ³Leandro Drumond     º Data ³  08/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conversão das Verbas.                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ConvSRV(aCodFol)

Local aArea 	:= GetArea()
Local aLog		:= {}
Local aCodCom	:= {}
Local aDePara	:= FSrvDePara()
Local cFilSRV	:= xFilial("SRV")
Local nX		:= 0
Local nPosSRV	:= 0
Local aCodCorr	:= {}

DbSelectArea("SRV")
DbSetOrder(1)
DbSeek(cFilSRV)

While SRV->(!Eof() .and. RV_FILIAL == cFilSRV)
	RecLock("SRV",.F.)

	If Len(AllTrim(SRV->RV_CODFOL)) == 3
		SRV->RV_CODFOL := "0" + SRV->RV_CODFOL //Altera o id de calculo para 4 digitos
	EndIf
	MsUnLock()
	SRV->(DbSkip())
EndDo

fp_CodFol( @aCodFol , xFilial("SRV"), .F., .F. )

DbSelectArea("SRV")
DbSetOrder(2)
DbSeek(cFilSRV)

While SRV->(!Eof() .and. RV_FILIAL == cFilSRV)
	RecLock("SRV",.F.)

	If Empty(SRV->RV_IMPRIPD)
		SRV->RV_IMPRIPD := "1"
	EndIf
	If Empty(SRV->RV_LEEINC)
		SRV->RV_LEEINC := "1"
	EndIf
	If Empty(SRV->RV_LEEPRE)
		SRV->RV_LEEPRE := "1"
	EndIf
	If Empty(SRV->RV_LEEAUS)
		SRV->RV_LEEAUS := "1"
	EndIf
	If Empty(SRV->RV_LEEBEN)
		SRV->RV_LEEBEN := "1"
	EndIf
	If Empty(SRV->RV_LEEFIX)
		SRV->RV_LEEFIX := "1"
	EndIf
	If Empty(SRV->RV_FECCOMP)
		SRV->RV_FECCOMP := "2"
	EndIf
	If Empty(SRV->RV_BASCAL)
		SRV->RV_BASCAL := "1"
	EndIf
	If Empty(SRV->RV_EMPCONS)
		SRV->RV_EMPCONS := "2"
	EndIf
	If Empty(SRV->RV_INSSFER)
		If SRV->RV_REFFER == "S"
			If (SRV->RV_CODFOL $ "0073*0076*0078*0081*0083*0085*0160*0205*0206*0344*0346*0633*0634*0635*0637")
				If ( nPosSRV := aScan( aDePara ,{|x| x[1] == SRV->RV_CODFOL } ) ) > 0
					SRV->RV_INSSFER := If(aDePara[nPosSRV,03]=="S","1","2")
				EndIf
			Else
				SRV->RV_INSSFER := If(SRV->RV_INSS=="S","1","2")
			EndIf
		Else
			SRV->RV_INSSFER := "2"
		EndIf
	EndIf
	If Empty(SRV->RV_CODMSEG) .and. !Empty(SRV->RV_CODFOL)
		SRV->RV_CODMSEG := fBuscaMesSeg(SRV->RV_CODFOL,aCodFol)
	EndIf
	If Empty(SRV->RV_FERSEG) .and. !Empty(SRV->RV_CODFOL)
		SRV->RV_FERSEG := fBuscaFerSeg(SRV->RV_COD,@aLog,aCodFol)
	EndIf

	If SRV->RV_CODFOL == "0088" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0072",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0089" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0073",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0090" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0077",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0091" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0078",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0092" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0080",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0093" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0081",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0094" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0074",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0095" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0079",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0096" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0082",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0097" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0083",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0098" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0084",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0099" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0085",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0161" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0159",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0162" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0160",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0163" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0022",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0207" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0205",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0208" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0206",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0227" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0224",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0228" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0226",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0838" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0075",SRV->RV_CODCOM_})
	ElseIf SRV->RV_CODFOL == "0839" .and. !Empty(SRV->RV_CODCOM_)
		aAdd(aCodCom,{"0076",SRV->RV_CODCOM_})
	EndIf

	If ( nPosSRV := aScan( aDePara ,{|x| x[2] == SRV->RV_CODFOL } ) ) > 0
		aDePara[nPosSRV,03] := SRV->RV_INSS
	EndIf

	If SRV->RV_CODFOL == "0023" //desconto antecipação 13 não utilizada na P12, vamos transformar a verba em base
		SRV->RV_TIPOCOD := "4"
	EndIf

	If SRV->RV_CODFOL == "0151" .Or. SRV->RV_CODFOL == "0152"  //desconto PLR não utilizada na P12, vamos transformar a verba em base
		If !Empty(SRV->RV_CODCORR)
			aAdd(aCodCorr, SRV->RV_CODCORR)
			SRV->RV_CODCORR := ""
		EndIf
	EndIf

	SRV->( MsUnLock() )

	SRV->(DbSkip())
EndDo

If !Empty(aCodCom)
	DbSelectArea("SRV")
	DbSetOrder(2)

	For nX := 1 to Len(aCodCom)
		If DbSeek(cFilSRV + aCodCom[nX,1])
			If Empty(SRV->RV_CODCOM_)
				RecLock("SRV",.F.)
					SRV->RV_CODCOM_ := aCodCom[nX,2]
				MsUnLock()
			EndIf
		EndIf
	Next nX
EndIf

If !Empty(aCodCorr)
	DbSelectArea("SRV")
	DbSetOrder(1)

	For nX := 1 to Len(aCodCorr)
		If DbSeek(cFilSRV + aCodCorr[nX])
			RecLock("SRV",.F.)
				SRV->RV_TIPOCOD := "4"
			MsUnLock()
		EndIf
	Next nX
EndIf


If !Empty(aLog)
	aAdd(aTitle, STR0014 ) //"Falha na gravação da Verba de Diferença de Férias (RV_FERSEG)"
	aAdd( aLogErr,{} )

	aAdd( aLogErr[Len(aLogErr)], "" )
	aAdd( aLogErr[Len(aLogErr)], STR0013 ) //"As verbas dos seguintes identificadores não foram encontradas. Cadastre-as e informe-a no campo RV_FERSEG da verba referenciada:"
	aAdd( aLogErr[Len(aLogErr)], Padr(STR0020,15 ) + Padr(STR0022,18) + Padr(STR0023,50) + STR0024 ) //"Filial###Identificador###Descrição###Ref. Verba"

	For nX := 1 To Len( aLog)
		aAdd( aLogErr[Len(aLogErr)], aLog[nX] )
	Next nX
	aAdd( aLogErr[Len(aLogErr)], "" )
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaFerSegºAutor  ³Leandro Drumond   º Data ³  08/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca o codigo para ferias do mes seguinte.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fBuscaFerSeg(cVerba,aLog,aCodFol)
Local cRet 		:= ""
Local cFilAux	:= xFilial("SRV")

If cVerba == aCodFol[22,1]			//1¦ Parc. 13§ Sal.
	cRet := aCodFol[163,1]			//Dif. 1¦ Parcela 13§ Salario
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0163",18) + Padr(aCodFol[163,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[72,1]		//Pagto Ferias
	cRet := aCodFol[88,1]			//Dif Ferias
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0088",18) + Padr(aCodFol[88,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[73,1]		//Pagto Ferias Mes Seguinte
	cRet := aCodFol[89,1]			//Dif Ferias Mes seguinte
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0089",18) + Padr(aCodFol[89,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[74,1]		//Abono Pecun. Ferias
	cRet := aCodFol[94,1]			//Dif Abono Pecun Ferias
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0094",18) + Padr(aCodFol[94,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[77,1]		//Adicional 1/3 sobre Ferias
	cRet := aCodFol[90,1]			//Dif 1/3 Ferias
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0090",18) + Padr(aCodFol[90,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[78,1]		//Adicional 1/3 Mes Seguinte
	cRet := aCodFol[91,1]			//Dif 1/3 Ferias Mes seguinte
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0091",18) + Padr(aCodFol[91,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[79,1]		//Adic. 1/3 Sobre Abono Pecun.
	cRet := aCodFol[95,1]			//Dif 1/3 sobre Abono Ferias
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0095",18) + Padr(aCodFol[95,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[80,1]		//DSR sobre Medias
	cRet := aCodFol[92,1]			//Dif DSR s/ Ferias
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0092",18) + Padr(aCodFol[92,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[81,1]		//DSR s/ Medias Mes Seguinte
	cRet := aCodFol[93,1]			//Dif DSR s/ Ferias mes Seguinte
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0093",18) + Padr(aCodFol[93,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[82,1]		//Medias s/ Horas Extras Mes
	cRet := aCodFol[96,1]			//Dif Medias H. Extras no mes
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0096",18) + Padr(aCodFol[96,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[83,1]		//Medias s/ Horas Mes Seguinte
	cRet := aCodFol[97,1]			//Dif Medias H. Extras mes seg.
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0097",18) + Padr(aCodFol[97,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[159,1]		//Convencao Coletiva Ferias
	cRet := aCodFol[161,1]			//Diferenca Convencao Coletiva Ferias
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0161",18) + Padr(aCodFol[161,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[160,1]		//Convencao Coletiva Ferias Mes Seguinte
	cRet := aCodFol[162,1]			//Diferenca Convencao Coletiva Ferias Mes Seguinte
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0162",18) + Padr(aCodFol[162,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[205,1]		//Abono Mes Seguinte
	cRet := aCodFol[207,1]			//Dif. Abono Mes. Seg.
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0207",18) + Padr(aCodFol[207,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[206,1]		//1/3 Abono Mes. Seg.
	cRet := aCodFol[208,1]			//Dif. 1/3 Abono Mes. Seg.
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0208",18) + Padr(aCodFol[208,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[224,1]		//Ferias em Dobro.
	cRet := aCodFol[227,1]			//Dif. de Ferias em Dobro
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0227",18) + Padr(aCodFol[227,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba == aCodFol[226,1]		//1/3 Ferias em Dobro
	cRet := aCodFol[228,1]			//Dif. de 1/3 Ferias em Dobro
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0228",18) + Padr(aCodFol[228,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba $ aCodFol[1312,1] + "*" + aCodFol[1316,1] + "*" + aCodFol[1320,1] + "*" +  aCodFol[1324,1] + "*" + aCodFol[1326,1]  + "*" + aCodFol[1330,1]//( ATS + Periculosidade + Insalubridade + Cargo COnfiança + Transferencia + DSR Sobre Medias) ABONO MES
	cRet := aCodFol[94,1]			//Dif Abono Pecun Ferias
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0094",18) + Padr(aCodFol[94,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba $ aCodFol[1313,1] + "*" + aCodFol[1317,1] + "*" + aCodFol[1321,1] + "*" +  aCodFol[1325,1] + "*" + aCodFol[1327,1]  + "*" + aCodFol[1331,1] //( ATS + Periculosidade + Insalubridade + Cargo COnfiança + Transferencia + DSR Sobre Medias) ABONO MES SEGUINTE
	cRet := aCodFol[207,1]			//Dif. Abono Mes. Seg.
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0207",18) + Padr(aCodFol[207,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba $ aCodFol[1296,1] + "*" + aCodFol[1300,1] + "*" + aCodFol[1304,1] + "*" + aCodFol[1308,1] + "*" + aCodFol[1310,1] //( ATS + Periculosidade + Insalubridade + Confiança + Transferencia ) FERIAS MES
	cRet := aCodFol[88,1]			//Dif Ferias
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0088",18) + Padr(aCodFol[88,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba $ aCodFol[1297,1] + "*" + aCodFol[1301,1] + "*" + aCodFol[1305,1] + "*" + aCodFol[1309,1] + "*" + aCodFol[1311,1] //( ATS + Periculosidade + Insalubridade + Confiança + Transferencia ) FERIAS MES SEGUINTE
	cRet := aCodFol[89,1]			//Dif Ferias Mes seguinte
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0089",18) + Padr(aCodFol[89,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba $ aCodFol[75,1] + "*" + aCodFol[343,1] + "*" + aCodFol[345,1]  //Media de ferias + Media de ferias Comissionados + Media de ferias Tarefeiros
	cRet := aCodFol[838,1]			//Diferença de Média de Férias no Mês
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0838",18) + Padr(aCodFol[838,2],50) + " " + cVerba )
	EndIf
ElseIf cVerba $ aCodFol[76,1] + "*" + aCodFol[344,1] + "*" + aCodFol[346,1]  //( Media de ferias + Media de ferias Comissionados + Media de ferias Tarefeiros ) Mes seguinte
	cRet := aCodFol[839,1]			//Diferença de Média de Férias Mês Seguinte
	If Empty(cRet)
		aAdd(aLog , Padr(cFilAux,15) + Padr("0839",18) + Padr(aCodFol[839,2],50) + " " + cVerba )
	EndIf
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaMesSegºAutor  ³Leandro Drumond   º Data ³  11/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca verba referente ao mês seguintes	                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fBuscaMesSeg(cIdFol,aCodFol)
Local cRet	:= ""

If cIdFol == "0073" 	//Ferias
	cRet := aCodFol[72,1] 	//Ferias Mes Seguinte
ElseIf cIdFol == "0076"	//Media Ferias Valor
	cRet := aCodFol[75,1] 	//Media Ferias Valor Mes Seguinte
ElseIf cIdFol == "0078"	//Adicional 1/3 sobre Ferias
	cRet := aCodFol[77,1]	//Adicional 1/3 sobre Ferias Mes Seguinte
ElseIf cIdFol == "0081"	//DSR sobre Medias
	cRet := aCodFol[80,1]	//DSR Sobre Medias Mes Seguinte
ElseIf cIdFol == "0083"	//Medias s/ Horas Extras Mes
	cRet := aCodFol[82,1]	//Medias s/ Horas Mes Seguinte
ElseIf cIdFol == "0085"	//Outros Adicionais
	cRet := aCodFol[84,1]	//Outros Adicionais Mes Seg.
ElseIf cIdFol == "0089"	//Dif Ferias
	cRet := aCodFol[88,1]	//Dif Ferias Mes seguinte
ElseIf cIdFol == "0091"	//Dif 1/3 Ferias
	cRet := aCodFol[90,1]	//Dif 1/3 Ferias Mes seguinte
ElseIf cIdFol == "0093"	//Dif DSR s/ Ferias
	cRet := aCodFol[92,1]	//Dif DSR s/ Ferias mes Seguinte
ElseIf cIdFol == "0097"	//Dif Medias H. Extras no mes
	cRet := aCodFol[96,1]	//Dif Medias H. Extras mes seg.
ElseIf cIdFol == "0099"	//Dif Outros Adicionais
	cRet := aCodFol[98,1]	//Dif Outros Adic. Mes Seg.
ElseIf cIdFol == "0160"	//Convencao Coletiva Ferias
	cRet := aCodFol[159,1]	//Convencao Coletiva Ferias Mes Seguinte
ElseIf cIdFol == "0162"	//Diferenca Convencao Coletiva Ferias
	cRet := aCodFol[161,1]	//Diferenca Convencao Coletiva Ferias Mes Seguinte
ElseIf cIdFol == "0205"	//Abono Pecun. Ferias
	cRet := aCodFol[74,1] 	//Abono Mes Seguinte
ElseIf cIdFol == "0206"	//Adic. 1/3 Sobre Abono Pecun.
	cRet := aCodFol[79,1] 	//1/3 Abono Mes. Seg.
ElseIf cIdFol == "0207"	//Dif Abono Pecun Ferias
	cRet := aCodFol[94,1] 	//Dif. Abono Mes. Seg.
ElseIf cIdFol == "0208"	//Dif 1/3 sobre Abono Ferias
	cRet := aCodFol[95,1] 	//Dif. 1/3 Abono Mes. Seg.
ElseIf cIdFol == "0344"	//Media Ferias de Comissiao no Mes
	cRet := aCodFol[343,1]	//Media Ferias de Comissiao no Mes Seguinte
ElseIf cIdFol == "0346"	//Media Ferias de Tarefa no Mes
	cRet := aCodFol[345,1]	//Media Ferias de Tarefa no Mes Seguinte
ElseIf cIdFol == "0373"	//Sustutivo de Carne - Ferias
	cRet := aCodFol[366,1]	//Sustutivo de Carne -Ferias Mes Seguinte
ElseIf cIdFol == "0374"	//Sustutivo de Carne - Salario Vacacional
	cRet := aCodFol[367,1]	//Sustutivo de Carne -Sal.Vac. Mes Seguinte
ElseIf cIdFol == "0376"	//BPS - Ferias
	cRet := aCodFol[375,1]	//BPS - Ferias Mes Seguinte
ElseIf cIdFol == "0377"	//IRP - Ferias
	cRet := aCodFol[646,1]	//IRP - Ferias Mes Seguinte
ElseIf cIdFol == "0379"	//Disse Ferias
	cRet := aCodFol[356,1]	//DISSE - Ferias Mes Seguinte
ElseIf cIdFol == "0432"	//Dif. Sust.Carne Ferias
	cRet := aCodFol[431,1]	//Dif. Sust.Carne Fer.Mes Seguinte
ElseIf cIdFol == "0434"	//Dif. Sust.Carne Sal.Vacacional
	cRet := aCodFol[433,1]	//Dif. Sust.Carne Sal.Vac.Mes Seg.
ElseIf cIdFol == "0436"	//Dif. Media Sal.Vacacional
	cRet := aCodFol[435,1]	//Dif. Media Sal.Vac.Mes Seg.
ElseIf cIdFol == "0633"	//Media Horas sobre Abono
	cRet := aCodFol[622,1]	//Media Horas sobre Abono Mes seguinte
ElseIf cIdFol == "0634"	//Media Valor sobre Abono
	cRet := aCodFol[623,1]	//Media valor sobre Abono Mes seguinte
ElseIf cIdFol == "0635"	//Adicionais sobre Abono Pecuniario
	cRet := aCodFol[632,1]	//Adicionais sobre Abono Mes Seguinte
ElseIf cIdFol == "0839"	//Diferença de Média de Férias no Mês
	cRet := aCodFol[838,1]	//Diferença de Média de Férias Mês Seguinte"
ElseIf cIdFol == "0841"	//Diferença 1/3 sobre Média de Férias no Mês
	cRet := aCodFol[840,1]	//Diferença 1/3 sobre Média de Férias Mês Seguinte
ElseIf cIdFol == "1095"	//Desc Ferias Mes CVG
	cRet := aCodFol[1094,1]	//Base Ferias Mes Seguinte CVG
ElseIf cIdFol == "1297"	//ATS Férias Mes
	cRet := aCodFol[1296,1]	//ATS Férias Mês Seguinte
ElseIf cIdFol == "1299"	//ATS Férias Mês s/verbas
	cRet := aCodFol[1298,1]	//ATS Férias Mês Seg.  s/verbas
ElseIf cIdFol == "1301"	//Periculosidade Férias Mês
	cRet := aCodFol[1300,1]	//Periculosidade Férias Mês Seg.
ElseIf cIdFol == "1303"	//Periculosidade Férias Mês s/verbas
	cRet := aCodFol[1302,1]	//Periculosidade Férias Mês Seg. s/verbas
ElseIf cIdFol == "1305"	//Insalubridade Férias Mês
	cRet := aCodFol[1304,1]	//Insalubridade Férias Mês Seg.
ElseIf cIdFol == "1307"	//Insalubridade Férias Mês s/verbas
	cRet := aCodFol[1306,1]	//Insalubridade Férias Mês Seg. s/verbas
ElseIf cIdFol == "1309"	//Adic. Cargo Confiança Férias Mes
	cRet := aCodFol[1308,1]	//Adic Cargo Confiança Férias Mês Seg.
ElseIf cIdFol == "1311"	//Adic. Transferencia Férias Mes
	cRet := aCodFol[1310,1]	//Adic. Transferencia Férias Mês Seg.
ElseIf cIdFol == "1313"	//ATS Abono Mes
	cRet := aCodFol[1312,1]	//ATS Abono Mês Seg.
ElseIf cIdFol == "1315"	//ATS Abono Mês s/verbas
	cRet := aCodFol[1314,1]	//ATS Abono Mês Seg. s/verbas
ElseIf cIdFol == "1317"	//Periculosidade Abono Mês
	cRet := aCodFol[1316,1]	//Periculosidade Abono Mês Seg.
ElseIf cIdFol == "1319"	//Periculosidade Abono Mês s/verbas
	cRet := aCodFol[1318,1]	//Periculosidade Abono Mês Seg. s/verbas
ElseIf cIdFol == "1321"	//Insalubridade Abono Mês
	cRet := aCodFol[1320,1]	//Insalubridade Abono Mês Seg.
ElseIf cIdFol == "1323"	//Insalubridade Abono Mês s/verbas
	cRet := aCodFol[1322,1]	//Insalubridade Abono Mês Seg. s/verbas
ElseIf cIdFol == "1325"	//Adic. Cargo Confiança Abonos Mes
	cRet := aCodFol[1324,1]	//Adic. Cargo Confiança Abono Mês Seg.
ElseIf cIdFol == "1327"	//Adic. Transferencia Abono Mes
	cRet := aCodFol[1326,1]	//Adic. Transferencia Abono Mês Seg.
ElseIf cIdFol == "1331"	//DSR sobre Medias Abono
	cRet := aCodFol[1330,1]	//DSR sobre Medias Abono Mes Seguinte
ElseIf cIdFol == "0232"	//INSS
	cRet := aCodFol[065,1]	//INSS Mês Seguinte
EndIf

Return cRet

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
Function fCriaVerbas(aCodFol,cFilSRV)
Local aArea			:= GetArea()
Local aVarAux		:= {}
Local aStruct		:= {}
Local aColsMark		:= {}
Local aNewPD		:= {}
Local aNewSRV		:= {}
Local nX			:= 0
Local nY			:= 0
Local nOpcA			:= 0
Local nTamAux		:= 0
Local cVarAux		:= "001"
Local cQuery		:= ""
Local cAliasSRV		:= ""
Local lMarcar		:= .T.
Local oSize			:= FwDefSize():New( .T.,,300,600 )
Local aMemoSRV      := {}
Local nMemoSRV      := 1

Private aPDInteg	:= {}
Private aRotMark	:= {}
Private oMark

	fp_CodFol( @aCodFol , xFilial("SRV"), .F., .F. )

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

		For nX := 1 to nTamAux
			If aNewPD[nX,1] $ "0678*0546*0836"
				aNewPD[nX,3] := "0021"
			ElseIf aNewPD[nX,1] == "0835"
				aNewPD[nX,3] := "0015"
			ElseIf aNewPD[nX,1] $ "0040*0041*0042*0103"
				aNewPD[nX,3] := "0031"
			ElseIf aNewPd[nX,1] == "1279"
				aNewPD[nX,3] := "0007"
			ElseIf aNewPd[nX,1] $ "1281*1290*1291*1340*1353"
				aNewPD[nX,3] := "0036"
			ElseIf aNewPd[nX,1] $ "1282*1292*1293*1339*1352"
				aNewPD[nX,3] := "0037"
			ElseIf aNewPd[nX,1] $ "1283*1284*1285*1286*1287*1288*1289"
				aNewPD[nX,3] := "0001"
			ElseIf aNewPd[nX,1] $ "*1296*1298*1300*1302*1304*1306*1308*1310"
				aNewPd[nX,3] := "0072"
			ElseIf aNewPd[nX,1] $ "1297*1299*1301*1303*1305*1307*1309*1311"
				aNewPd[nX,3] := "0073"
			ElseIf aNewPd[nX,1] $ "1312*1314*1316*1318*1320*1322*1324*1326"
				aNewPd[nX,3] := "0074"
			ElseIf aNewPd[nX,1] $ "1313*1315*1317*1319*1321*1323*1325*1327"
				aNewPd[nX,3] := "0205"
			ElseIf aNewPd[nX,1] $ "1294*1341*1354"
				aNewPD[nX,3] := "0984"
			ElseIf aNewPd[nX,1] $ "1295*1342*1355"
				aNewPD[nX,3] := "0988"
			ElseIf aNewPd[nX,1] == "1328"
				aNewPD[nX,3] := "0107"
			ElseIf aNewPd[nX,1] == "1329"
				aNewPD[nX,3] := "0043"
			ElseIf aNewPd[nX,1] == "1330"
				aNewPD[nX,3] := "0080"
			ElseIf aNewPd[nX,1] == "1331"
				aNewPD[nX,3] := "0081"
			ElseIf aNewPd[nX,1] == "1415"
				aNewPD[nX,3] := "0116"
			ElseIf aNewPd[nX,1] $ "1416*1417"
				aNewPD[nX,3] := "0096"
			ElseIf aNewPd[nX,1] $ "1418*1419"
				aNewPD[nX,3] := "0097"
			ElseIf aNewPd[nX,1] $ "0633*0622"
				aNewPD[nX,3] := "0082"
			ElseIf aNewPd[nX,1] $ "0634*0623"
				aNewPD[nX,3] := "0075"
			ElseIf aNewPd[nX,1] $ "0205"
				aNewPD[nX,3] := "0074"
			ElseIf aNewPd[nX,1] $ "0206"
				aNewPD[nX,3] := "0079"
			ElseIf aNewPd[nX,1] $ "0207"
				aNewPD[nX,3] := "0094"
			ElseIf aNewPd[nX,1] $ "0208"
				aNewPD[nX,3] := "0095"
			//--Desmembramento dos adicionais na rescisão
			ElseIf aNewPd[nX,1] $ "1680" //Periculosidade Férias Indenizadas
				aNewPD[nX,3] := "1316"
			ElseIf aNewPd[nX,1] $ "1681*1682" //Periculosidade Férias Prop./ Aviso
				aNewPD[nX,3] := "1300"
			ElseIf aNewPd[nX,1] $ "1683" //Periculosidade Aviso
				aNewPD[nX,3] := "0036"
			ElseIf aNewPd[nX,1] $ "1684*1685" //Periculosidade 13o rescisão
				aNewPD[nX,3] := "1290"
			ElseIf aNewPd[nX,1] $ "1686" //Periculosidade Média Férias Indenizadas
				aNewPD[nX,3] := "1407"
			ElseIf aNewPd[nX,1] $ "1687*1688" //Periculosidade Média Férias Prop./ Aviso
				aNewPD[nX,3] := "0639"
			ElseIf aNewPd[nX,1] $ "1689" //Periculosidade Média Aviso
				aNewPD[nX,3] := "0036"
			ElseIf aNewPd[nX,1] $ "1690*1691" //Periculosidade Média 13o rescisão
				aNewPD[nX,3] := "0181"
			ElseIf aNewPd[nX,1] $ "1692" //Insalubridade Férias Indenizadas
				aNewPD[nX,3] := "1320"
			ElseIf aNewPd[nX,1] $ "1693*1694" //Insalubridade Férias Prop./ Aviso
				aNewPD[nX,3] := "1304"
			ElseIf aNewPd[nX,1] $ "1695" //Insalubridade Aviso
				aNewPD[nX,3] := "0037"
			ElseIf aNewPd[nX,1] $ "1696*1697" //Insalubridade 13o rescisão
				aNewPD[nX,3] := "1292"
			ElseIf aNewPd[nX,1] $ "1698" //Insalubridade Média Férias Indenizadas
				aNewPD[nX,3] := "1408"
			ElseIf aNewPd[nX,1] $ "1699*1700" //Insalubridade Média Férias Prop./ Aviso
				aNewPD[nX,3] := "0640"
			ElseIf aNewPd[nX,1] $ "1701" //Insalubridade Média Aviso
				aNewPD[nX,3] := "0037"
			ElseIf aNewPd[nX,1] $ "1702*1703" //Insalubridade Média 13o rescisão
				aNewPD[nX,3] := "0182"
			ElseIf aNewPd[nX,1] $ "1704" //ATS Férias Indenizadas
				aNewPD[nX,3] := "1312"
			ElseIf aNewPd[nX,1] $ "1705*1706" //ATS Férias Prop./ Aviso
				aNewPD[nX,3] := "1296"
			ElseIf aNewPd[nX,1] $ "1707" //ATS Aviso
				aNewPD[nX,3] := "0001"
			ElseIf aNewPd[nX,1] $ "1708*1709" //ATS 13o rescisão
				aNewPD[nX,3] := "1288"
			ElseIf aNewPd[nX,1] $ "1710" //Transf. Férias Indenizadas
				aNewPD[nX,3] := "1326"
			ElseIf aNewPd[nX,1] $ "1711*1712" //Transf. Férias Prop./ Aviso
				aNewPD[nX,3] := "1310"
			ElseIf aNewPd[nX,1] $ "1713" //Transf. Aviso
				aNewPD[nX,3] := "0988"
			ElseIf aNewPd[nX,1] $ "1714*1715" //Transf. 13o rescisão
				aNewPD[nX,3] := "1295"
			ElseIf aNewPd[nX,1] $ "1716" //Conf. Férias Indenizadas
				aNewPD[nX,3] := "1324"
			ElseIf aNewPd[nX,1] $ "1717*1718" //Conf. Férias Prop./ Aviso
				aNewPD[nX,3] := "1308"
			ElseIf aNewPd[nX,1] $ "1719" //Conf. Aviso
				aNewPD[nX,3] := "0984"
			ElseIf aNewPd[nX,1] $ "1720*1721" //Conf. 13o rescisão
				aNewPD[nX,3] := "1294"
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

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ou diretamente, pelo AddObject                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSize:AddObject( "GETDADOS",100, 100, .T., .T. )
			oSize:lLateral     := .F.
			oSize:Process() // Dispara os calculos


			Define MsDialog oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] Title STR0015 Pixel style DS_MODALFRAME //"Informe os códigos das verbas que devem ser criadas"

				aHeaderSRV := {}

				aAdd( aHeaderSRV , { STR0016 , "TAB_PD", "@!", 3, 0, "fVldSRVConv(.T.)" , ,"C","SRV", })//"Verba"
				aAdd( aHeaderSRV , { STR0017 , "TAB_CODFOL", "@!", 4, 0, ".F." , ,"C",, })				//"ID. Calculo"
				aAdd( aHeaderSRV , { STR0018 , "TAB_DESC", "@!", 20, 0, ".T." , ,"C",, })				//"Descrição"
				aAdd( aHeaderSRV , { STR0025 , "TAB_PDM", "@!", 3, 0, "fVldSRVConv(.F.)" , ,"C","SRV", })	//"Mod. Verba"
				aAdd( aHeaderSRV , { STR0018 , "TAB_DESCM", "@!", 20, 0, ".T." , ,"C",, })				//"Descrição"

				oGetSRV := MsNewGetDados():New(oSize:GetDimension("GETDADOS","LININI")		,;	// 1  nTop
												oSize:GetDimension("GETDADOS","COLINI")		,;	// 2  nLelft
												oSize:GetDimension("GETDADOS","LINEND") - 10,;	// 3  nBottom
												oSize:GetDimension("GETDADOS","COLEND")	- 10,;	// 4  nRright
												GD_UPDATE									,;	// 5  Controle do que podera ser realizado na GetDado - nstyle
												.T.											,;	// 6  Funcao para validar a edicao da linha - ulinhaOK
												.T.											,;	// 7  Funcao para validar todas os registros da GetDados - uTudoOK
												Nil											,;	// 8  cIniCPOS
												{"TAB_PD","TAB_DESC","TAB_PDM"}				,;	// 9  aAlter
												0											,;	// 10 nfreeze
												99999										,;	// 11 nMax
												Nil											,;	// 12 cFieldOK
												Nil											,;	// 13 usuperdel
												Nil											,;	// 14 udelOK
												@oDlg										,;	// 15 Objeto de dialogo - oWnd
												@aHeaderSRV									,;	// 16 Vetor com Colunas - AparHeader
												@aColsSRV									)	// 17 Vetor com Header - AparCols

				bSet15 := { || nOpcA := 1 , aColsSRV := oGetSRV:aCols, IIf(fVldVerb(oGetSRV:aCols),oDlg:End(),) }
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
							If aStruct[nY,2] == "M" //Tratamento específico para campo memo
								If SRV->( MsSeek( cFilSRV + cVarAux ) )
									AAdd( aMemoSRV, SRV->( &( aStruct[nY,1] ) ) )
								EndIf
							EndIf
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
						If aStruct[nY,2] == "M" .And. Len(aMemoSRV) >= nMemoSRV //Tratamento específico para campo memo
							SRV->&( aStruct[nY,1] ) := aMemoSRV[nMemoSRV]
							nMemoSRV += 1
						Else
							SRV->&( aStruct[nY,1] ) := (cAliasSRV)->&( aStruct[nY,1] )
						EndIf
					Next nY

					SRV->RV_FILIAL	:= cFilSRV
					SRV->RV_COD 	:= aColsSRV[nX,1]
					SRV->RV_CODFOL 	:= aColsSRV[nX,2]
					SRV->RV_DESC	:= UPPER(aColsSRV[nX,3])
					SRV->RV_DESCDET	:= UPPER(aColsSRV[nX,3])

					aAdd( aNewSRV, SRV->(Recno()) )
				EndIf

				SRV->(MsUnLock())

				If Type("aTitle") == "A"
					aAdd( aLogErr[Len(aLogErr)], Padr(cFilSRV,12) + Padr(aColsSRV[nX,1],8) + Padr(aColsSRV[nX,2],15) + Padr(SRV->RV_DESC,50) )
				EndIf

				If nMemoSRV > 1
					aMemoSRV := {}
					nMemoSRV := 1
				EndIf
			Next nX

			If Select(cAliasSRV) > 0
				(cAliasSRV)->( dbCloseArea() )
			EndIf

		EndIf

		aCodFol := {} //zera variavel para carregar novamente
		RstaCodFol()
	EndIf

	RestArea(aArea)

Return aNewSRV

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
Local aRet	 	:= {}
Local cPdAux	:= ""
Local cPdAux2   := ""
Local nX		:= 0

For nX := 1 to Len(aNewPD)
	If !Empty(aNewPD[nX,3])
		cPdAux  := aCodFol[Val(aNewPD[nX,3]),1]
		cPdAux2 := aCodFol[Val(aNewPD[nX,1]),1]
		If !Empty(cPdAux) .Or. Empty( cPdAux + cPdAux2 )
			aAdd( aRet , {aNewPD[nX,2] , aNewPD[nX,1] , aNewPD[nX,4], cPdAux, Fdesc("SRV", cPdAux, "RV_DESC") , .F.})
		EndIf
	EndIf
Next nX

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVldSRVConv ³ Autor ³ Leandro Drumond       ³ Data ³ 11/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se verba informada ja existe	     	                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fVldSRVConv()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fVldSRVConv(lVldGrid)
Local aArea	 := GetArea()
Local cVerba := &(ReadVar())
Local lRet 	 := .T.
Local nX	 := 0

SRV->(DbSetOrder(1))
SRV->(DBGOTOP())

If Empty(cVerba)
	lRet := .F.
ElseIf SRV->(DbSeek(xFilial("SRV") + cVerba ))
	If lVldGrid
		If Empty(SRV->RV_CODFOL)
			If MsgYesNo(STR0081 + cVerba + STR0082) //Deseja associar a verba " + cVerba + " a este identificador?")
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		Else
			If SRV->RV_CODFOL == aCols[n,2]
				lRet := .T.
			Else
				MsgAlert(STR0083) //"A verba informada já possui identificador de cálculo e não poderá ser utilizada."
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .T.
	EndIf
Else
	lRet := lVldGrid
EndIf

If lRet
	If lVldGrid
		For nX := 1 to Len(aCols)
			If nX == n
				Loop
			EndIf
			If cVerba == aCols[nX,1] .and. !aCols[nX,6]
				lRet := .F.
				Exit
			EndIf
		Next nX
	Else
		aCols[n,5] := Fdesc("SRV", cVerba, "RV_DESC")
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCrgADTS    ³ Autor ³ Leandro Drumond       ³ Data ³ 19/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega adicionais por tempo de servico da tabala X20        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fVldSRVConv()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fCrgADTS(cSind)
Local aArea := GetArea()
Local lRet	:= .T.

If FPHIST82(RCE->RCE_FILIAL,"20",RhTamFilial(SRA->RA_FILIAL)+cSind+"01") .Or.;
	FPHIST82(RCE->RCE_FILIAL,"20",RhTamFilial(SRA->RA_FILIAL)+"  "+"01") .Or.;
	FPHIST82(RCE->RCE_FILIAL,"20",RhTamFilial(Space(FwSizeFilial()))+cSind+"01") .Or.;
	FPHIST82(RCE->RCE_FILIAL,"20",RhTamFilial(Space(FwSizeFilial()))+"  "+"01")
	dbSelectArea("SRX")
	VAL_ANU := VAL(SubStr(SRX->RX_TXT,01,12))
	VAL_BIE := VAL(SubStr(SRX->RX_TXT,13,12))
	VAL_TRI := VAL(SubStr(SRX->RX_TXT,25,12))
	VAL_QUA := VAL(SubStr(SRX->RX_TXT,37,12))
	VAL_QUI := VAL(SubStr(SRX->RX_TXT,49,12))
	dbSkip()
	CAR_ANU := SubStr(SRX->RX_TXT,01,02)
	CAR_BIE := SubStr(SRX->RX_TXT,03,02)
	CAR_TRI := SubStr(SRX->RX_TXT,05,02)
	CAR_QUA := SubStr(SRX->RX_TXT,07,02)
	CAR_QUI := SubStr(SRX->RX_TXT,09,02)
	PER_ANU := VAL(SubStr(SRX->RX_TXT,11,07))
	PER_BIE := VAL(SubStr(SRX->RX_TXT,18,07))
	PER_TRI := VAL(SubStr(SRX->RX_TXT,25,07))
	PER_QUA := VAL(SubStr(SRX->RX_TXT,32,07))
	PER_QUI := VAL(SubStr(SRX->RX_TXT,39,07))
	dbSkip()
	LIM_ANU := VAL(SubStr(SRX->RX_TXT,01,12))
	LIM_BIE := VAL(SubStr(SRX->RX_TXT,13,12))
	LIM_TRI := VAL(SubStr(SRX->RX_TXT,25,12))
	LIM_QUA := VAL(SubStr(SRX->RX_TXT,37,12))
	LIM_QUI := VAL(SubStr(SRX->RX_TXT,49,12))
	dbSkip()
	DTB_ANU := if("/" $ SubStr(SRX->RX_TXT,01,08),CTOD((SubStr(SRX->RX_TXT,01,08)),"DDMMYY"),Stod(SubStr(SRX->RX_TXT,01,08),"DDMMYY") )
	DTB_BIE := if("/" $ SubStr(SRX->RX_TXT,09,08),CTOD((SubStr(SRX->RX_TXT,09,08)),"DDMMYY"),Stod(SubStr(SRX->RX_TXT,09,08),"DDMMYY") )
	DTB_TRI := if("/" $ SubStr(SRX->RX_TXT,17,08),CTOD((SubStr(SRX->RX_TXT,17,08)),"DDMMYY"),Stod(SubStr(SRX->RX_TXT,17,08),"DDMMYY") )
	DTB_QUA := if("/" $ SubStr(SRX->RX_TXT,25,08),CTOD((SubStr(SRX->RX_TXT,25,08)),"DDMMYY"),Stod(SubStr(SRX->RX_TXT,25,08),"DDMMYY") )
	DTB_QUI := if("/" $ SubStr(SRX->RX_TXT,33,08),CTOD((SubStr(SRX->RX_TXT,33,08)),"DDMMYY"),Stod(SubStr(SRX->RX_TXT,33,08),"DDMMYY") )
	ACU_ANU := SubStr(SRX->RX_TXT,41,01)
	ACU_BIE := SubStr(SRX->RX_TXT,42,01)
	ACU_TRI := SubStr(SRX->RX_TXT,43,01)
	ACU_QUA := SubStr(SRX->RX_TXT,44,01)
	ACU_QUI := SubStr(SRX->RX_TXT,45,01)
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fBasCat     ³ Autor ³ Leandro Drumond       ³ Data ³ 19/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem a base de calculo do ATS						        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fBasCat()	                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fBasCat()
Local nRet 		:= ""
Local cWhere	:= ""
Local cAliasTst	:= GetNextAlias()

cWhere += "%"
cWhere += " SRV.RV_FILIAL = '" + xFilial("SRV") + "' "
cWhere += " AND SRV.RV_ADICTS = 'S' "
cWhere += "%"

BeginSql alias cAliasTst
	SELECT COUNT(*) TOTALREG
	FROM %table:SRV% SRV
		WHERE 		%exp:cWhere% AND
 	    SRV.%notDel%
EndSql
nRet := (cAliasTst)->TOTALREG

(cAliasTst)->(DbCloseArea())

Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fBcalPE     ³ Autor ³ Leandro Drumond       ³ Data ³ 19/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem a base de calculo da Periculosidade			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fBcalPE()	                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fBcalPE(cSind)
Local cRet 		:= "1"
Local cWhere	:= ""
Local cJoin		:= ""
Local cAliasTst	:= GetNextAlias()
Local nCount	:= 0

cWhere += "%"
cWhere += " SRA.RA_SINDICA = '" + cSind + "' "
cWhere += " AND SRA.RA_PERICUL >= '999' "
cWhere += " AND RCE.RCE_FILIAL = '" + xFilial("RCE") + "' "
cWhere += "%"

cJoin += "%"
cJoin += FWJoinFilial( "RCE", "SRA" )
cJoin += "%"

BeginSql alias cAliasTst
	SELECT COUNT(*) TOTALREG
	FROM %table:SRA% SRA
	INNER JOIN  %table:RCE% RCE
	ON 			%exp:cJoin% AND
    RCE.RCE_CODIGO = SRA.RA_SINDICA
	WHERE 		%exp:cWhere% AND
 	SRA.%notDel%
EndSql

nCount := (cAliasTst)->TOTALREG

(cAliasTst)->(DbCloseArea())

If nCount > 0
	cRet := "2"
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fBCalIn     ³ Autor ³ Leandro Drumond       ³ Data ³ 19/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtem a base de calculo da Insalubridade				        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fBCalIn()	                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fBCalIn(cSind)
Local cRet 		:= ""
Local cWhere	:= ""
Local cJoin		:= ""
Local cAliasTst	:= ""
Local nCount	:= 0
Local lUsasMin	:= SuperGetMv("MV_USASMIN",,.F.)

If lUsasMin
	cRet := "1"
Else
	cAliasTst := GetNextAlias()

	cWhere += "%"
	cWhere += " SRA.RA_SINDICA = '" + cSind + "' "
	cWhere += " AND ( SRA.RA_INSMAX >= '999' OR SRA.RA_INSMED >= '999' OR SRA.RA_INSMIN >= '999' ) "
	cWhere += " AND RCE.RCE_FILIAL = '" + xFilial("RCE") + "' "
	cWhere += "%"

	cJoin += "%"
	cJoin += FWJoinFilial( "RCE", "SRA" )
	cJoin += "%"

	BeginSql alias cAliasTst
		SELECT COUNT(*) TOTALREG
		FROM %table:SRA% SRA
		INNER JOIN  %table:RCE% RCE
		ON 			%exp:cJoin% AND
	    RCE.RCE_CODIGO = SRA.RA_SINDICA
		WHERE 		%exp:cWhere% AND
	 	SRA.%notDel%
	EndSql


	nCount := (cAliasTst)->TOTALREG

	(cAliasTst)->(DbCloseArea())

	If nCount > 0
		cRet := "3"
	Else
		cRet := "2"
	EndIf
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MesesFunc ºAutor  ³Bruno Sobieski      ºFecha ³  01/25/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o numero de meses de casa que tem o funcionario paraº±±
±±º          ³o calculo de ferias, considerando ano civila ou nao.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MesesFunc(dDtIni,dDtFim)
Local nMeses
If GetNewPar("MV_FERPAC ","N")=="S" .And. Substr(DtoS(dDtFim),5,4)<>"1231"
	dDtFim	:=	CTOD("31/12/"+Str(Year(dDtFim)-1,4))
EndIf

nMeses	:=	(Year(dDtFim)*12) - (Year(dDtIni)*12) + Month(dDtFim)-Month(dDtIni)

Return nMeses

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fAcumFaltas|Autor  ³ Leandro Drumond	    ³ Data ³ 06/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acumula as faltas para utilizacao nas conversao.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAcumFaltas(cDatai,cDataF,cMesAno,cVerbaPesq,cAlias,nFaltas,aCodFol)

If cMesAno >= cDatai .And. cMesAno <= cDataF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa Faltas no Acumulado                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cVerbaPesq == aCodFol[054,1]
		If PosSrv(aCodFol[54,1],SRA->RA_FILIAL,"RV_MEDFER") $ "S *SP"
			nFaltas += If((cAlias)->RD_TIPO1 == "D", (cAlias)->RD_HORAS, Int((cAlias)->RD_HORAS/Round(SRA->RA_HRSMES/30,2)) )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa Faltas Mes Anterior no Acumulado                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cVerbaPesq == aCodFol[203,1]
		If PosSrv(aCodFol[203,1],SRA->RA_FILIAL,"RV_MEDFER") $ "S *SP"
			nFaltas += If((cAlias)->RD_TIPO1 == "D", (cAlias)->RD_HORAS, Int((cAlias)->RD_HORAS/Round(SRA->RA_HRSMES/30,2)) )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa Faltas (II) no Acumulado                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cVerbaPesq == aCodFol[242,1]
		If PosSrv(aCodFol[242,1],SRA->RA_FILIAL,"RV_MEDFER") $ "S *SP"
			nFaltas += If((cAlias)->RD_TIPO1 == "D", (cAlias)->RD_HORAS, Int((cAlias)->RD_HORAS/Round(SRA->RA_HRSMES/30,2)) )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa Reembolso de Faltas no Acumulado                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cVerbaPesq == aCodFol[244,1]
		If PosSrv(aCodFol[244,1],SRA->RA_FILIAL,"RV_MEDFER") $ "S *SP"
			nFaltas -= If((cAlias)->RD_TIPO1 == "D", (cAlias)->RD_HORAS, Int((cAlias)->RD_HORAS/Round(SRA->RA_HRSMES/30,2)) )
		EndIf
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvSRD    |Autor  ³ Leandro Drumond	    ³ Data ³ 30/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao do historico de movimentos (SRD).         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvSRD(aLogFil)
Local aRecnos	:= {}
Local aPdADI	:= {}
Local aRet_SP	:= {}
Local aError	:= {}
Local aStruSRD 	:= SRD->(dbStruct())
Local cPdAdiant	:= fGetCodFol("0007")
Local cPdAd  	:= fGetCodFol("0006")
Local cPdArrAd  := fGetCodFol("0008")
Local cPd151	:= fGetCodFol("0151")
Local cPd152	:= fGetCodFol("0152")
Local cPd300	:= fGetCodFol("0300")
Local cPdPLR	:= "'" + cPd151 + "', '" + cPd152 + "', '" + cPd300 + "'"
Local cPd0022	:= fGetCodFol("0022")
Local cPd0108	:= fGetCodFol("0108")
Local cPd0109	:= fGetCodFol("0109")
Local cPd0678	:= fGetCodFol("0678")
Local cPd113	:= "'" + cPd0022 + "', '" + cPd0108 + "', '" + cPd0109 + "', '" + cPd0678 + "'"
Local cPd213	:= fGetCodFol("0024")
Local cPdDesc13	:= fGetCodFol("0023")
Local cSraFil 	:= xFilial("SRA")
Local cAliasQry := GetNextAlias()
Local cEmpAux	:= ""
Local cFilAux	:= ""
Local cUserAux	:= ""
Local cQuery	:= ""
Local cRet		:= ""
Local cWhere	:= ""
Local nAux		:= 0
Local nX		:= 0
Local nPos		:= 0
Local nRotFim	:= 0

Static lCriaProc	:= .T.

aAdd(aPdADI,{fGetCodFol("0009"),fGetCodFol("0012")})
aAdd(aPdADI,{fGetCodFol("1329"),cPdArrAd})
aAdd(aPdADI,{fGetCodFol("0010"),fGetCodFol("0010")})
aAdd(aPdADI,{cPdAd,cPdAdiant})

If lCriaProc

	cQuery += "Create Procedure CONVUPDSRV_"+cEmpAnt+"("+CRLF
	cQuery += "   @IN_FILIAL		Char( " + Str( FWGETTAMFILIAL ) + " ),"+CRLF
	cQuery += "   @IN_DTINI		Char( 08 ),"+CRLF
	cQuery += "   @IN_DTFIM		Char( 08 ),"+CRLF
	cQuery += "   @IN_PDADIANT	Char( 03 ),"+CRLF
	cQuery += "   @IN_PDARRAD	Char( 03 ),"+CRLF
	cQuery += "   @IN_PD151		Char( 03 ),"+CRLF
	cQuery += "   @IN_PD152		Char( 03 ),"+CRLF
	cQuery += "   @IN_PD300		Char( 03 ),"+CRLF
	cQuery += "   @IN_PD0022		Char( 03 ),"+CRLF
	cQuery += "   @IN_PD0108		Char( 03 ),"+CRLF
	cQuery += "   @IN_PD0109		Char( 03 ),"+CRLF
	cQuery += "   @IN_PD0678		Char( 03 ),"+CRLF
	cQuery += "   @IN_PD213		Char( 03 ),"+CRLF
	cQuery += "   @IN_PDDESC13 Char( 03 )," + CRLF
	cQuery += "   @OUT_RESULTADO Char( 01 )OutPut"+CRLF
	cQuery += "   )"+CRLF
	cQuery += "AS"+CRLF

	cQuery += "Declare @cFILIAL  char( " + Str( FWGETTAMFILIAL ) + " )"+CRLF
	nTam := TamSX3("RA_MAT")[1]
	cQuery += "Declare @cMATRIC  char( "+StrZero(nTam,2)+" )"+CRLF
	cQuery += "Declare @cPROC  char( 05 )"+CRLF
	cQuery += "Declare @cCATFUNC char( 01 )"+CRLF
	cQuery += "Declare @nROT131  INT"+CRLF
	cQuery += "Declare @cTIPOPGT char( 01 )"+CRLF

	cQuery += "begin"+CRLF
	cQuery += "   Select @OUT_RESULTADO = '0'"+CRLF

	cQuery += "   declare FUNC_SRA insensitive  cursor for "+CRLF
	cQuery += "   select "+CRLF
	cQuery += "   	RA_FILIAL, "+CRLF
	cQuery += "   	RA_MAT,"+CRLF
	cQuery += "   	RA_PROCES,"+CRLF
	cQuery += "   	RA_CATFUNC,"+CRLF
	cQuery += "   	RA_TIPOPGT"+CRLF
	cQuery += "   FROM"+CRLF
	cQuery += "   	"+RetSqlName("SRA")+" SRA"+CRLF
	cQuery += "   where "+CRLF
	cQuery += "   	RA_FILIAL = @IN_FILIAL AND RA_PROCES <> ' ' and D_E_L_E_T_ = ' '"+CRLF
	cQuery += "   ORDER BY RA_FILIAL,RA_MAT"+CRLF

	cQuery += "   for read only "+CRLF
	cQuery += "   open FUNC_SRA"+CRLF
	cQuery += "   fetch FUNC_SRA into @cFILIAL, @cMATRIC, @cPROC, @cCATFUNC, @cTIPOPGT"+CRLF

	cQuery += "   while ( (@@Fetch_status  = 0 ) ) begin"+CRLF
	cQuery += "      Begin Transaction"+CRLF
	cQuery += "      	begin "+CRLF
	cQuery += "      		update "+RetSqlName("SRD")+CRLF
	cQuery += " 			SET 	RD_PERIODO = '##_PER_ATU##', " + CRLF
	cQuery += " 					RD_SEQ = '##_SEQ_ATU##'," + CRLF
	cQuery += " 					RD_ROTEIR = '##_ROT_ATU##' ," + CRLF
	cQuery += "		 				RD_DTREF = '##_DT_ATU##'," + CRLF
	cQuery += " 					RD_SEMANA = '##_SEM_ATU##'," + CRLF
	cQuery += " 					RD_PROCES = @cPROC " + CRLF
	cQuery += "         	 where RD_FILIAL = @cFILIAL AND RD_MAT = @cMATRIC AND RD_DATARQ between @IN_DTINI and @IN_DTFIM" +CRLF
	cQuery += "      	End"+CRLF
	cQuery += "      Commit Transaction"+CRLF
	/* ------------------------------------------------------------------------------------------------------
	   Tratamento para o DB2
	   ------------------------------------------------------------------------------------------------------ */
	If Trim(cNameDB) = 'DB2'
		cQuery += "      SELECT @fim_CUR = 0"+CRLF
	EndIf
	cQuery += "      fetch FUNC_SRA into @cFILIAL, @cMATRIC, @cPROC, @cCATFUNC,@cTIPOPGT "+CRLF
	cQuery += "   end "+CRLF

	cQuery += "   close FUNC_SRA"+CRLF
	cQuery += "   deallocate FUNC_SRA"+CRLF
	cQuery += "   select @OUT_RESULTADO = '1'"+CRLF
	cQuery += "end"+CRLF
	cQuery := MsParse(cQuery,Alltrim(TcGetDB()))

	If ( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery := Replace(cQuery, "'##_PER_ATU##'", "CASE WHEN RD_MES < '13' THEN RD_DATARQ ELSE CONCAT(SUBSTR(RD_DATARQ,1,4) , '12') END")
	Else
		cQuery := Replace(cQuery, "'##_PER_ATU##'", "CASE WHEN RD_MES < '13' THEN RD_DATARQ ELSE SUBSTRING(RD_DATARQ,1,4) + '12' END")
	EndIf
	cQuery := Replace(cQuery, "'##_ROT_ATU##'", "CASE WHEN RD_ROTEIR <> '   ' THEN RD_ROTEIR WHEN RD_TIPO2 = 'A' AND RD_PD NOT IN (@IN_PDADIANT, @IN_PDARRAD) AND RD_SEMANA = '  ' THEN 'ADI' WHEN ( ( RD_MES < '13' AND RD_PD IN (@IN_PD151,@IN_PD152,@IN_PD300) ) OR (RD_TIPO2 = 'A' AND RD_SEMANA = '01') ) THEN 'PLR' WHEN RD_MES < '13' AND RD_PD IN (@IN_PD0022, @IN_PD0108, @IN_PD0109, @IN_PD0678) AND (SELECT COUNT(*) FROM " + RetSqlName("SRD") + " SRDAUX WHERE SRDAUX.RD_FILIAL = @cFILIAL AND SRDAUX.RD_MAT = @cMATRIC AND SRDAUX.RD_DATARQ between @IN_DTINI and @IN_DTFIM AND RD_PD = @IN_PDDESC13 AND SRDAUX.D_E_L_E_T_ = ' ') > 0 THEN '131' WHEN RD_PD = @IN_PD213 OR (RD_TIPO2 = 'S' AND RD_MES = '13') THEN '132' WHEN @cCATFUNC IN ('P','A') THEN 'AUT' ELSE 'FOL'   END")
	If ( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery := Replace(cQuery, "'##_DT_ATU##'", "CASE WHEN RD_MES < '13' AND RD_PD IN (@IN_PD151,@IN_PD152,@IN_PD300) THEN CONCAT(SUBSTR(RD_DTREF,1,4), '0101') ELSE RD_DTREF END")
	Else
		cQuery := Replace(cQuery, "'##_DT_ATU##'", "CASE WHEN RD_MES < '13' AND RD_PD IN (@IN_PD151,@IN_PD152,@IN_PD300) THEN SUBSTRING(RD_DTREF,1,4) + '0101' ELSE RD_DTREF END")
	EndIf
	cQuery := Replace(cQuery, "'##_SEM_ATU##'", "CASE WHEN RD_SEMANA = '  ' THEN '01' ELSE RD_SEMANA END")

	If Trim(cNameDB)  $ "POSTGRES"
		cQuery := Replace(cQuery, "'##_SEQ_ATU##'", "CASE WHEN RD_SEQ = '9' THEN ' ' WHEN RD_ROTEIR = '   ' AND RD_SEMANA <> '  ' AND  @cTIPOPGT <> 'S' THEN (CASE WHEN RD_SEQ = '' ::CHAR(1) THEN '1' ELSE  CAST(((CAST((REPLACE(RD_SEQ,' ','0')) AS INT) + 1)) AS CHAR)  END ) ELSE RD_SEQ END")
	Else
		cQuery := Replace(cQuery, "'##_SEQ_ATU##'", "CASE WHEN RD_SEQ = '9' THEN ' ' WHEN RD_ROTEIR = '   ' AND RD_SEMANA <> '  ' AND  @cTIPOPGT <> 'S' THEN CAST(((CAST((REPLACE(RD_SEQ,' ','0')) AS INT) + 1)) AS CHAR) ELSE RD_SEQ END")
	EndIf

	If Trim(cNameDB)  $ "ORACLE*DB2*INFORMIX*POSTGRES"
		cQuery := Replace(cQuery, "@IN_", "IN_")
		cQuery := Replace(cQuery, "@cCATFUNC", "vcCATFUNC")
		cQuery := Replace(cQuery, "@cPROC", "vcPROC")
		cQuery := Replace(cQuery, "@cMATRIC", "vcMATRIC")
		cQuery := Replace(cQuery, "@cFILIAL", "vcFILIAL")
		cQuery := Replace(cQuery, "@nROT131", "vnROT131")
		cQuery := Replace(cQuery, "@cTIPOPGT", "vcTIPOPGT")
	EndIf
	If Trim(cNameDB) == 'SYBASE'
		cQuery := strtran(cQuery," LEN("," DATALENGTH(")
		cQuery := strtran(cQuery," Len("," DATALENGTH(")
		cQuery := strtran(cQuery," len("," DATALENGTH(")
	EndIf
	If Trim(cNameDB) $ "MSSQL*SYSBASE"
		cQuery := StrTran(cQuery, 'SET @iTranCount = 0', " Commit Transaction ")
		cQuery := StrTran(cQuery, 'SET @iTranCount  = 0', " Commit Transaction ")
	End
	If Trim(cNameDB) == 'INFORMIX'
		cQuery := StrTran(cQuery, 'LET viTranCount  = 0', "COMMIT WORK")
		cQuery := StrTran(cQuery, 'LTRIM ( RTRIM (', "TRIM((")
	EndIf
	If Trim(cNameDB) == 'DB2'
		cQuery	:= StrTran( cQuery, 'set vfim_CUR  = 0 ;', 'set fim_CUR = 0;' )
	EndIf

	If TCSPExist( "CONVUPDSRV_"+cEmpAnt )
		cRet := TcSqlExec("DROP PROCEDURE CONVUPDSRV_"+cEmpAnt)
		If cRet <> 0
			aAdd( aLogFil[Len(aLogFil)], "Conversão do Histórico de Movimento - Erro na Exclusão da Procedure" )
			Return .F.
		EndIf
	EndIf

	cRet := TcSqlExec(cQuery)

	If cRet < 0
		aAdd( aLogFil[Len(aLogFil)], "Conversão do Histórico de Movimento - Erro na Criação da Procedure" )
		aAdd( aLogFil[Len(aLogFil)], Str(cRet) + " - " + TCSqlError() )
		Return .F.
	EndIf
	lCriaProc := .F.
EndIf

aRet_SP := TCSPEXEC( xProcedures("CONVUPDSRV"),cFilAnt, If(!Empty(cDataDe),cDataDe,"000000"),If(!Empty(cDataAte),cDataAte,"999999"),cPdAdiant,cPdArrAd,cPd151,cPd152,cPd300,cPd0022,cPd0108,cPd0109,cPd0678,cPd213,cPdDesc13)

If Empty(aRet_SP) .Or. aRet_SP[1]=='0'
	aAdd( aLogFil[Len(aLogFil)], "Conversão do Histórico de Movimento - Erro na chamada da Procedure" )

	cError := TCSQLError()
	aError	:= Str2Arr( cError , Chr( 10 ) )
	conout(cError)
	aEval( aError , { |X| aAdd(aLogFil[Len(aLogFil)], X) } )
	Return .F.
EndIf

cWhere := "%"
cWhere += " SRD.RD_FILIAL = '"	 	+ cFilAnt + "' "
If !Empty(cDataDe) .and. !Empty(cDataAte)
	cWhere += " AND SRD.RD_DATARQ >= '"	+ cDataDe + "' "
	cWhere += " AND SRD.RD_DATARQ <= '"	+ cDataAte + "' "
EndIf
cWhere += "%"

//Gera verba adiantamento ID 006
GeraADI(aStruSRD,aPdADI,cWhere)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GeraADI    |Autor  ³ Flavio Correa	    ³ Data ³ 13/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria verba ID 0006 - Adiantamento no roteiro ADI		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraADI(aStruSRD,aPdADI,cWhere)
Local aArea	 	:= SRD->(GetArea())
Local cQry		:= GetNextAlias()
Local nReg		:= 1
Local nX		:= 0
Local cBusca 	:= ""
Local cPdAux	:= ""

For nX := 1 to Len(aPdADI)
	If nX > 1
		cPdAux += ","
	EndIf
	cPdAux += "'" + aPdADI[nX,2] + "'"
Next nX

cPdAux := "% (" + cPdAux + ") %"

BeginSql Alias cQry
	SELECT SRD.*
	FROM %table:SRD% SRD
	WHERE %exp:cWhere%
	AND SRD.RD_PD IN %exp:cPdAux%
	AND SRD.%notDel%
EndSql

For nReg := 1 To Len(aStruSRD)
	If (aStruSRD[nReg][2] <> "C")
		TcSetField(cQry,aStruSRD[nReg][1],aStruSRD[nReg][2],aStruSRD[nReg][3],aStruSRD[nReg][4])
	EndIf
Next nReg

dbSelectArea("SRD")
SRD->(dbSetOrder(12))

While !(cQry)->(Eof())
	nX := aScan(aPdADI, { |x| x[2] ==  (cQry)->(RD_PD) } )

	cBusca := (cQry)->(RD_FILIAL+RD_MAT+RD_CC+RD_ITEM+RD_CLVL+RD_DATARQ)+aPdADI[nX,1]+(cQry)->(RD_SEQ+RD_PERIODO+RD_SEMANA)+"ADI"+(cQry)->(DTOS(RD_DTREF))

	If !SRD->(dbSeek(cBusca))
		RecLock("SRD",.T.)
		For nReg := 1 To Len(aStruSRD)
			SRD->&( aStruSRD[nReg,1] ) := (cQry)->&( aStruSRD[nReg,1] )
		Next nReg
		SRD->RD_ROTEIR := "ADI"
		SRD->RD_PD := aPdADI[nX,1]
		SRD->RD_TIPO2 := "A"

		SRD->(msUnlock())
	EndIf
	(cQry)->(dbSkip())
EndDo

(cQry)->(dbCloseArea())

RestArea(aArea)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvSRI    |Autor  ³ Leandro Drumond	    ³ Data ³ 13/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao do 13º salario 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvSRI()
Local aArea	 	:= GetArea()
Local cRotAux	:= "132"
Local cPeriodo	:= ""
Local cSemana	:= ""
Local cFilAux	:= ""
Local cMatAux	:= ""
Local cPDAux	:= ""
Local cAliasQry	:= GetNextAlias()

DbSelectArea("SRC")
DbSetOrder(RetOrder("SRC","RC_FILIAL+RC_PROCES+RC_MAT+RC_PERIODO+RC_SEMANA+RC_ROTEIR+RC_PD+RC_CC+RC_SEQ+DTOS(RC_DTREF)"))

BeginSql alias cAliasQry
	column RI_DATA AS Date
	SELECT SRI.*, RA_PROCES
	FROM %table:SRI% SRI
	INNER JOIN  %table:SRA% SRA
	ON SRI.RI_FILIAL = SRA.RA_FILIAL AND
	SRI.RI_MAT = SRA.RA_MAT
	WHERE RA_FILIAL = %exp:xFilial("SRA")% AND
	SRA.%notDel% AND SRI.%notDel%
EndSql

While (cAliasQry)->(!Eof())
	cFilAux		:= (cAliasQry)->RI_FILIAL
	cMatAux		:= (cAliasQry)->RI_MAT
	cPdAux		:= (cAliasQry)->RI_PD
	cPeriodo 	:= AnoMes((cAliasQry)->RI_DATA)
	cProcesso 	:= (cAliasQry)->RA_PROCES
	If cProcesso $ "00002*00004"
		cSemana := "05"
	Else
		cSemana := "01"
	EndIf

	If!(SRC->(DbSeek(cFilAux+cProcesso+cMatAux+cPeriodo+cSemana+cRotAux+cPDAux)))
		RecLock("SRC",.T.)
		SRC->RC_FILIAL	:= cFilAux
		SRC->RC_MAT		:= cMatAux
		SRC->RC_PROCES	:= cProcesso
		SRC->RC_PERIODO	:= cPeriodo
		SRC->RC_SEMANA	:= cSemana
		SRC->RC_ROTEIR	:= cRotAux
		SRC->RC_PD		:= cPDAux
		SRC->RC_TIPO1	:= (cAliasQry)->RI_TIPO1
		SRC->RC_QTDSEM	:= (cAliasQry)->RI_QTDSEM
		SRC->RC_HORAS	:= (cAliasQry)->RI_HORAS
		SRC->RC_VALOR	:= (cAliasQry)->RI_VALOR
		If !Empty((cAliasQry)->RI_DATA)
			SRC->RC_DATA	:= (cAliasQry)->RI_DATA
			SRC->RC_DTREF	:= (cAliasQry)->RI_DATA
		EndIf
		SRC->RC_CC		:= (cAliasQry)->RI_CC
		SRC->RC_TIPO2	:= (cAliasQry)->RI_TIPO2
		SRC->RC_ITEM	:= (cAliasQry)->RI_ITEM
		SRC->RC_CLVL	:= (cAliasQry)->RI_CLVL

		SRC->(MsUnLock())
	EndIf

	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvRCC    |Autor  ³ Leandro Drumond	    ³ Data ³ 30/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao dos parametros (SR5 para RCC).	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvRCC()

Local aSRX		:= {}
Local aTabelas 	:= {{"03","S080"},{"06","S036"},{"08","S001"},{"09","S002"},{"10","S003"},{"11","S004"},{"14","S037"},{"15","S035"},{"32","S043"},{"41","S039"},{"44","S040"},{"45","S041"},{"46","S042"},{"59","S070"}}
Local aGrvRCC 	:= {}
Local aConteudo	:= {}
Local cKeySR5	:= ""
Local cTabela	:= ""
Local cSeqRCC	:= ""
Local cConteudo	:= ""
Local cFilAux	:= ""
Local cDataAux	:= ""
Local cChvRCC	:= ""
Local cAnoMesIni:= ""
Local cAnoMesFim:= ""
Local cAnoMesTst:= ""
Local cAnoAux	:= ""
Local cSpaceFil	:= Space(TamSX3("RCC_FIL")[1])
Local cSpaceChv	:= Space(TamSX3("RCC_CHAVE")[1])
Local nX		:= 0
Local nY		:= 0
Local nPosSR5	:= 0
Local nRegSR5	:= 0
Local nXAux		:= 0
Local nPosShw	:= 0
Local nTstAux	:= 0
Local lProjAv	:= SuperGetMv("MV_PROJAV",,.F.)
Local lNoReg	:= .F.
Local nTamanho	:= 0
//Excluir tabelas que nao serao mais usadas
fDelRCBRCC()

GpIniTab() //Carrega as tabelas do fonte padrao

fSR5toRCB() //Carrega array com posicoes do RCB e SR5

dbSelectArea("SR5")
SR5->(dbSetOrder(1))

dbSelectArea("SRX")
SRX->(dbSetOrder(1))

nPosSR5 := aScan( aSR5toRCB , { |x| x[5]+AllTrim(x[4]) == "S035" + "CDECUSTO" } )
If nPosSR5 > 0
	nTamanho 	:= aSR5toRCB[nPosSR5,03]
EndIf

nPosSR5 := aScan( aSR5toRCB , { |x| x[5]+AllTrim(x[4]) == "S035" + "VERBA" } )
If nPosSR5 > 0
	nTamanho 	+= aSR5toRCB[nPosSR5,03]
EndIf


For nX := 1 to Len(aTabelas)
	If SRX->(dbSeek( xFilial('SRX') + aTabelas[nX,1] ))
		nRegSR5 := 0

		cKeySR5	 := RhTamFilial(xFilial('SR5')) + "X" + SRX->RX_TIP

		While SRX->(!Eof() .And. RX_FILIAL == xFilial('SRX') .And. RX_TIP == aTabelas[nX,1] )

			If aTabelas[nX,2] == "S035"
				nRegSR5 := val(substr(Alltrim(SRX->RX_COD),len(Alltrim(SRX->RX_COD)),1))
			Else
				nRegSR5++
			EndIf
			lNoReg	:= .F.

			If !SR5->( dbSeek( cKeySR5 + StrZero(nRegSR5,2) ) ) .and. nRegSR5 > 1
				nRegSR5 := 1
				lNoReg	:= .T.
				If aTabelas[nX,2] == "S037"
					lNoreg := !(val(substr(Alltrim(SRX->RX_COD),len(Alltrim(SRX->RX_COD)),1)) == 1)
				EndIf

				SR5->( dbSeek( cKeySR5 + StrZero(nRegSR5,2) ) )
			EndIf

			If aTabelas[nX,2] == "S037" .And. lNoReg
				nRegSR5 := 0
				lAtuRCC := .F.
			Else
				If aTabelas[nX,2] == "S035" .and. nTamanho > 0
					aAdd(aSRX,{aTabelas[nX,2],Substr(SRX->RX_COD,1,Len(SRX->RX_COD)-1)+substr(SRX->RX_TXT,1,nTamanho),SRX->RX_TXT,SR5->R5_REG})
				Else
					aAdd(aSRX,{aTabelas[nX,2],SRX->RX_COD,SRX->RX_TXT,SR5->R5_REG})
				EndIf
			EndIf
			SRX->(dbSkip())
		EndDo
	EndIf
Next

cFilRCC		:= xFilial("RCC")

For nX := 1 to Len(aSRX)

	If cTabela <> aSRX[nX,1]
		cSeqRCC		:= "000"
		cTabela 	:= aSRX[nX,1]
		cAnoMesTst 	:= ""
	EndIf

	nPosSR5 := aScan( aSR5toRCB , { |x| x[5] == cTabela } )
	nPosSWH := aScan( aSR5toRCB , { |x| x[5]+x[6] == cTabela + "RCC_CONTEUD" } )

	cSeqRCC		:= Soma1(cSeqRCC)

	Do Case
		Case cTabela $ "S002*S004*S035*S036*S037*S039" //IR*Salario Minimo*Complemento GPS*Mensagens*Encargos Empresa*Indicador Economico

			cConteudo 	:= ""
			If aSR5toRCB[nPosSWH,11] == "S"

				cAnoAux		:= fGetRxValue("ANO",cTabela,aSRX[nX,2])
				If Len(cAnoAux) == 2
					cAnoAux := AllTrim(Str(Year(CtoD("01/01/"+cAnoAux))))
				EndIf
				cChvRCC		:= fGetRxValue("MES",cTabela,aSRX[nX,2])
				If Empty(cChvRCC) .or. Empty(cAnoAux)
					cChvRCC := cSpaceChv
				Else
					cChvRCC := cAnoAux + cChvRCC
				EndIf
				cAnoMesIni	:= ""
				cAnoMesFim	:= ""
			Else
				cAnoMesIni	:= fGetRxValue("ANO",cTabela,aSRX[nX,2]) + fGetRxValue("MES",cTabela,aSRX[nX,2])
				If Empty(cAnoMesIni)
					cAnoMesIni	:= If(!Empty(cAnoMes),SubStr(cAnoMes,1,4),SubStr(DtoS(dDataBase),1,4)) + "01"
					cAnoMesTst	:= cAnoMesIni
					nTstAux		:= 0
				EndIf
				cAnoMesFim	:= SubStr(cAnoMesIni,1,4)
				cAnoMesFim 	+= "12"
				cChvRCC := cSpaceChv
			EndIf

			cFilAux		:= fGetRxValue("FILIAL",cTabela,aSRX[nX,2])
			nTstAux++

			If Empty(cFilAux)
				cFilAux := cSpaceFil
			EndIf

			If cTabela == "S036"
				cConteudo += SubStr(ALLTRIM(aSRX[nX,2]),-1)
			ElseIf cTabela = "S037"
				cConteudo += SubStr(ALLTRIM(aSRX[nX,2]),-2,1)
			ElseIf cTabela == "S039"
				cConteudo += fGetRxValue("SINDICATO",cTabela,aSRX[nX,2])
			EndIf

			nXAux		:= nX

			cConteudo	+= fGetRxValue("",cTabela,aSRX[nX,2],aSRX,"RCC_CONTEUD",@nXAux)

			If Empty(cAnoMesTst) .or. cAnoMesTst <> cAnoMesIni .or. nTstAux == 1
				aAdd(aGrvRCC,{cFilRCC,cTabela,cFilAux,cChvRCC,cSeqRCC,cConteudo,cAnoMesIni,cAnoMesFim})
			EndIf

			If cTabela == "S037"
				cConteudo	:= fGetRxValue("","S038",aSRX[nX,2],aSRX,"RCC_CONTEUD",@nX)
				If Empty(cAnoMesTst) .or. cAnoMesTst <> cAnoMesIni .or. nTstAux == 1
					aAdd(aGrvRCC,{cFilRCC,"S038",cFilAux,cChvRCC,cSeqRCC,cConteudo,cAnoMesIni,cAnoMesFim})
				EndIf
			EndIf

			nX := Max(nXAux,nX)

		Case cTabela $ "S001*S003" //Tabela INSS*Salario Familia

			cConteudo 	:= ""
			cFilAux		:= fGetRxValue("FILIAL",cTabela,aSRX[nX,2])

			If Empty(cFilAux)
				cFilAux := cSpaceFil
			EndIf
			cAnoMesIni	:= fGetRxValue("ANO",cTabela,aSRX[nX,2]) + fGetRxValue("MES",cTabela,aSRX[nX,2])
			If Empty(cAnoMesIni)
				cAnoMesIni	:= If(!Empty(cAnoMes),SubStr(cAnoMes,1,4),SubStr(DtoS(dDataBase),1,4)) + "01"
				cAnoMesTst	:= cAnoMesIni
				nTstAux		:= 0
			EndIf
			nTstAux++
			cAnoMesFim	:= SubStr(cAnoMesIni,1,4)
			cAnoMesFim 	+= "12"
			aConteudo	:= fGetRxValue("",cTabela,aSRX[nX,2],aSRX,"RCC_CONTEUD",@nX,If(cTabela=="S003","VLLIMITE","SALCATE"))

			If ValType(aConteudo) == "A"
				For nY := 1 to Len(aConteudo)
					If Empty(cAnoMesTst) .or. cAnoMesTst <> cAnoMesIni .or. nTstAux == 1
						aAdd(aGrvRCC,{cFilRCC,cTabela,cFilAux,cSpaceChv,cSeqRCC,aConteudo[nY],cAnoMesIni,cAnoMesFim})
						If nY + 1 <= Len(aConteudo)
							cSeqRCC		:= Soma1(cSeqRCC)
						EndIf
					EndIf
				Next nY
			EndIf

		Case cTabela == "S040"  //Convencao Coletiva

			cConteudo 	:= ""
			cConteudo	+= fGetRxValue("SINDICATO",cTabela,aSRX[nX,2])
			cFilAux		:= fGetRxValue("FILIAL",cTabela,aSRX[nX,2])

			If aSRX[nX,4] == "02"
				cDataAux	:= fGetRxValue("DATABASE",cTabela,aSRX[nX,3])
			Else
				cDataAux	:= fGetRxValue("DATABASE",cTabela,aSRX[nX+1,3])
			EndIf

			If Empty(cFilAux)
				cFilAux := cSpaceFil
			EndIf

			aConteudo	:= fGetRxValue("",cTabela,aSRX[nX,2],aSRX,"RCC_CONTEUD",@nX,"INIFAIXA")

			If ValType(aConteudo) == "A"
				For nY := 1 to Len(aConteudo)
					aAdd(aGrvRCC,{cFilRCC,cTabela,cFilAux,cSpaceChv,cSeqRCC,cConteudo+StrZero(nY,3)+aConteudo[nY]+cDataAux,"",""})
					If nY + 1 <= Len(aConteudo)
						cSeqRCC		:= Soma1(cSeqRCC)
					EndIf
				Next nY
			EndIf

		Case cTabela $ "S041*S042" //Parametros RAIS*Dias de Ferias
			cConteudo 	:= ""
			If cTabela == "S041"
				cConteudo	+= fGetRxValue("ANO",cTabela,aSRX[nX,2])
			Else
				cConteudo	+= fGetRxValue("SINDICATO",cTabela,aSRX[nX,2])
				cConteudo	+= fGetRxValue("SEQUENCIA",cTabela,aSRX[nX,2])
			EndIf
			cFilAux		:= fGetRxValue("FILIAL",cTabela,aSRX[nX,2])

			If Empty(cFilAux)
				cFilAux := cSpaceFil
			EndIf

			cConteudo	+= fGetRxValue("",cTabela,aSRX[nX,2],aSRX,"RCC_CONTEUD",@nX)

			aAdd(aGrvRCC,{cFilRCC,cTabela,cFilAux,cSpaceChv,cSeqRCC,cConteudo,"",""})

		Case cTabela $ "S070*S043" //Tarefas * Tipos de Rescisao
			cConteudo 	:= ""
			cFilAux		:= fGetRxValue("FILIAL",cTabela,aSRX[nX,2])

			If cTabela == "S043"
				cConteudo	+= fGetRxValue("TIPORESC",cTabela,aSRX[nX,2])
			Else
				cConteudo	+= fGetRxValue("CODTAREFA",cTabela,aSRX[nX,2])
			EndIf

			If Empty(cFilAux)
				cFilAux := cSpaceFil
			EndIf

			cConteudo	+= fGetRxValue("",cTabela,aSRX[nX,2],aSRX,"RCC_CONTEUD",@nX)

			aAdd(aGrvRCC,{cFilRCC,cTabela,cFilAux,cSpaceChv,cSeqRCC,cConteudo,"",""})

		Case cTabela == "S080"  //Moedas e Cedulas
			cConteudo 	:= ""

			aConteudo	:= fGetRxValue("",cTabela,aSRX[nX,2],aSRX,"RCC_CONTEUD",@nX,"MOEDACED")

			If ValType(aConteudo) == "A"
				For nY := 1 to Len(aConteudo)
					If !Empty(SubStr(aConteudo[nY],1,1))
						aAdd(aGrvRCC,{cFilRCC,cTabela,cSpaceFil,cSpaceChv,cSeqRCC,aConteudo[nY],"",""})
						If nY + 1 <= Len(aConteudo)
							cSeqRCC		:= Soma1(cSeqRCC)
						EndIf
					EndIf
				Next nY
			EndIf
	EndCase

Next nX

fAjustAnoMes(@aGrvRCC)

DbSelectArea("RCC")
DbSetOrder(1)

For nX := 1 to Len(aGrvRCC)
	If dbSeek(aGrvRCC[nX,1] + aGrvRCC[nX,2] + aGrvRCC[nX,3] + aGrvRCC[nX,4] + aGrvRCC[nX,5])
		RecLock("RCC",.F.)
	Else
		RecLock("RCC",.T.)
		RCC->RCC_FILIAL	:=  aGrvRCC[nX,01]
		RCC->RCC_CODIGO	:=  aGrvRCC[nX,02]
		RCC->RCC_FIL	:=  aGrvRCC[nX,03]
		RCC->RCC_CHAVE	:=  aGrvRCC[nX,04]
		RCC->RCC_SEQUEN	:=  aGrvRCC[nX,05]
	EndIf

	RCC->RCC_CONTEU	:=  aGrvRCC[nX,07]+aGrvRCC[nX,08]+aGrvRCC[nX,06]

	If aGrvRCC[nX,2] == "S043"
		RCC->RCC_CONTEU := RCC->RCC_CONTEU	:=  aGrvRCC[nX,07]+aGrvRCC[nX,08]+aGrvRCC[nX,06] + If(lProjAv,"S","N")
	Else
		RCC->RCC_CONTEU	:=  aGrvRCC[nX,07]+aGrvRCC[nX,08]+aGrvRCC[nX,06]
	EndIf

	MsUnlock()

Next nX

//Ajusta as tabelas de usuaários para apresentar mês e ano quando o campo RCB_SHOWMA esta em branco
fAjTabUs()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvSRH    |Autor  ³ Leandro Drumond	    ³ Data ³ 30/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao das ferias (SRH e SRR).	   		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvSRH()

Local cQuery := ""
Local nRet	 := 0
Local nTot	 := 0
Local nMinRec:= 0
Local nCont	 := 0
Local nX	 := 0
Local cAliasQry := GetNextAlias()
Local nCountAtu := 0
Local lExistCpo := ( SRH->(FieldPos( "RH_DTITENS" )) # 0 )

BeginSql alias cAliasQry
	SELECT COUNT(*) TOTALREG
	FROM %table:SRR% SRR
		WHERE SRR.RR_ROTEIR <> ' ' AND
			   SRR.RR_TIPO3 = 'F' AND
			   SRR.RR_FILIAL = %exp:xFilial( "SRR" )% AND
 	    SRR.%notDel%
EndSql

nCountAtu := (cAliasQry)->TOTALREG
(cAliasQry)->(DbCloseArea())

If nCountAtu > 0
	lAtuSRR := .T.
	Return( Nil )
Else
	lAtuSRR := .F.
EndIf

GpContReg(@nTot,@nMinRec,"SRH")

Begin Sequence

	If nTot > 0

		cRecno 	:= "R_E_C_N_O_"
		nCont 	:= nMinRec + 1024

		For nx = 1 to nTot
			cQuery := " UPDATE " + RetSqlName( "SRH" )
			If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
				cQuery += " 		SET RH_PERIODO = SUBSTRING(RH_DATAINI,1,6) , RH_SALARIO = RH_SALMES , "
			Else
				cQuery += " 		SET RH_PERIODO = SUBSTR(RH_DATAINI,1,6) , RH_SALARIO = RH_SALMES , "
			EndIf
			If ( cNameDB $ "INFORMIX" )
				cQuery += " 		RH_PROCES = NVL((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RH_FILIAL AND RA_MAT = RH_MAT AND D_E_L_E_T_ <> '*') , ' '), "
			Else
				cQuery += " 		RH_PROCES = COALESCE((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RH_FILIAL AND RA_MAT = RH_MAT AND D_E_L_E_T_ <> '*') , ' '), "
			Endif
			cQuery += " 		RH_ROTEIR = 'FER', "
			cQuery += " 		RH_NPAGTO = CASE WHEN RH_NPAGTO = '  ' THEN '01' ELSE RH_NPAGTO END "
			cQuery += " WHERE RH_FILIAL = '" + xFilial( "SRH" ) + "' AND "
			cQuery += cRecno + ">=" + AllTrim(Str(nMinRec)) + " AND " + cRecno + "<=" + AllTrim(Str(nCont)) + " "

	    	nRet := TCSQLEXEC(cQuery)

	    	If nRet != 0
				UserException( TCSqlError() )
				Break
			EndIf

		   	nMinRec := nCont
		   	nCont  := nMinRec + 1024

		Next nx
	EndIf

	nTot 	:= 0
	nMinRec := 0

	GpContReg(@nTot,@nMinRec,"SRR")

	If nTot > 0

		cRecno	:= "R_E_C_N_O_"
		nCont	:= nMinRec + 1024

		For nX = 1 to nTot

			cQuery := " UPDATE " + RetSqlName( "SRR" )
			If ( cNameDB $ "INFORMIX" )
				If lExistCpo
					cQuery += " 	SET	RR_PROCES = NVL((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RR_FILIAL AND RA_MAT = RR_MAT AND D_E_L_E_T_ <> '*') , ' '), "
					cQuery += " 		RR_ROTEIR = 'FER', "
					cQuery += "			RR_DATA = NVL((SELECT RH_DATAINI FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND (RH_DTITENS <> '' AND RH_DTITENS = RR_DATA OR RH_DTITENS = '' AND RH_DTRECIB = RR_DATA) AND D_E_L_E_T_ <> '*'),RR_DATA), "
					cQuery += "			RR_DATAPAG = NVL((SELECT CASE WHEN RH_DTITENS <> '' THEN RH_DTITENS ELSE RH_DTRECIB END FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND (RH_DTITENS <> '' AND RH_DTITENS = RR_DATA OR RH_DTITENS = '' AND RH_DTRECIB = RR_DATA) AND D_E_L_E_T_ <> '*'),RR_DATA), "
					cQuery += " 		RR_PERIODO = NVL((SELECT RH_PERIODO FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND (RH_DTITENS <> '' AND RH_DTITENS = RR_DATA OR RH_DTITENS = '' AND RH_DTRECIB = RR_DATA) AND D_E_L_E_T_ <> '*'),RR_PERIODO), "
				Else
					cQuery += " 	SET	RR_PROCES = NVL((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RR_FILIAL AND RA_MAT = RR_MAT AND D_E_L_E_T_ <> '*') , ' '), "
					cQuery += " 		RR_ROTEIR = 'FER', "
					cQuery += "			RR_DATA = NVL((SELECT RH_DATAINI FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND RH_DTRECIB = RR_DATA AND D_E_L_E_T_ <> '*'),RR_DATA), "
					cQuery += "			RR_DATAPAG = NVL((SELECT RH_DTRECIB FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND RH_DTRECIB = RR_DATA AND D_E_L_E_T_ <> '*'),RR_DATA), "
					cQuery += " 		RR_PERIODO = NVL((SELECT RH_PERIODO FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND RH_DTRECIB = RR_DATA AND D_E_L_E_T_ <> '*'),RR_PERIODO), "
				EndIf
			Else
				If lExistCpo
					cQuery += " 	SET	RR_PROCES = COALESCE((SELECT DISTINCT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RR_FILIAL AND RA_MAT = RR_MAT AND D_E_L_E_T_ <> '*') , ' '), "
					cQuery += " 		RR_ROTEIR = 'FER', "
					cQuery += "			RR_DATA = COALESCE((SELECT DISTINCT RH_DATAINI FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND (RH_DTITENS <> '' AND RH_DTITENS = RR_DATA OR RH_DTITENS = '' AND RH_DTRECIB = RR_DATA) AND D_E_L_E_T_ <> '*'),RR_DATA), "
					cQuery += "			RR_DATAPAG = COALESCE((SELECT DISTINCT  CASE WHEN RH_DTITENS <> '' THEN RH_DTITENS ELSE RH_DTRECIB END FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND (RH_DTITENS <> '' AND RH_DTITENS = RR_DATA OR RH_DTITENS = '' AND RH_DTRECIB = RR_DATA) AND D_E_L_E_T_ <> '*'),RR_DATA), "
					cQuery += " 		RR_PERIODO = COALESCE((SELECT DISTINCT RH_PERIODO FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND (RH_DTITENS <> '' AND RH_DTITENS = RR_DATA OR RH_DTITENS = '' AND RH_DTRECIB = RR_DATA) AND D_E_L_E_T_ <> '*'),RR_PERIODO), "
				Else
					cQuery += " 	SET	RR_PROCES = COALESCE((SELECT DISTINCT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RR_FILIAL AND RA_MAT = RR_MAT AND D_E_L_E_T_ <> '*') , ' '), "
					cQuery += " 		RR_ROTEIR = 'FER', "
					cQuery += "			RR_DATA = COALESCE((SELECT DISTINCT RH_DATAINI FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND RH_DTRECIB = RR_DATA AND D_E_L_E_T_ <> '*'),RR_DATA), "
					cQuery += "			RR_DATAPAG = COALESCE((SELECT DISTINCT RH_DTRECIB FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND RH_DTRECIB = RR_DATA AND D_E_L_E_T_ <> '*'),RR_DATA), "
					cQuery += " 		RR_PERIODO = COALESCE((SELECT DISTINCT RH_PERIODO FROM " + RetSqlName("SRH") + " SRH WHERE RH_FILIAL = RR_FILIAL AND RH_MAT = RR_MAT AND RH_DTRECIB = RR_DATA AND D_E_L_E_T_ <> '*'),RR_PERIODO), "
				EndIf
			Endif
			cQuery += " 		RR_SEMANA = CASE WHEN RR_SEMANA = '  ' THEN '01' ELSE RR_SEMANA END "
			cQuery += " WHERE RR_FILIAL = '" + xFilial( "SRR" ) + "' AND RR_TIPO3 = 'F' AND "
			cQuery += cRecno + ">=" + AllTrim(Str(nMinRec)) + " AND " + cRecno + "<=" + AllTrim(Str(nCont)) + " "

			nRet := TCSQLEXEC(cQuery)

	    	If nRet != 0
				UserException( TCSqlError() )
				Break
			EndIf

		   	nMinRec := nCont
		   	nCont  := nMinRec + 1024

		Next nX
	EndIf

	// - Efetua a busca do conteúdo do parâmetro MV_FOLMES
	// - Para a empresa aberta corretamente.
	cAnoMes := fBuscaFolmes()

	// - Garante a integridade do conteúdo caso o retorno da função
	// - fBuscaFolmes seja vazio.
	If Empty(cAnoMes)
		cAnoMes := SuperGetMv("MV_FOLMES",,AnoMes(dDataBase))
	EndIf

	//Exclui movimento aberto
	//Visando evitar erros no calculo da folha, devido a mudança de conceito existente na P12.
	//Sempre deverá excluir o movimento aberto, não existe mais opção
	cQuery := "DELETE FROM " + RetSqlName("SRH")
	cQuery += " WHERE RH_FILIAL = '" + xFilial("SRH") + "' "
	If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery += " AND SUBSTRING(RH_DATAINI,1,6) >= '" + cAnoMes + "' "
	Else
		cQuery += " AND SUBSTR(RH_DATAINI,1,6)>= '" + cAnoMes + "' "
	EndIf

	If TCSQLEXEC(cQuery) != 0
		UserException( TCSqlError() )
	EndIf

	cQuery := "DELETE FROM " + RetSqlName("SRR")
	cQuery += " WHERE RR_FILIAL = '" + xFilial("SRR") + "' "
	If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery += " AND SUBSTRING(RR_DATA,1,6) >= '" + cAnoMes + "' "
	Else
		cQuery += " AND SUBSTR(RR_DATA,1,6)>= '" + cAnoMes + "' "
	EndIf
	cQuery += " AND RR_TIPO3 = 'F' "

	If TCSQLEXEC(cQuery) != 0
		UserException( TCSqlError() )
	EndIf

End Sequence

Return

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

Local cQuery := ""
Local cRecno := ""
Local nRet	 := 0
Local nTot	 := 0
Local nMinRec:= 0
Local nCont	 := 0
Local nX	 := 0

//Exclui movimento aberto
If lPar04
	cQuery := "DELETE FROM " + RetSqlName("SRG")
	cQuery += " WHERE RG_FILIAL = '" + xFilial("SRG") + "' "
	If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery += " AND SUBSTRING(RG_DATADEM,1,6) >= '" + cAnoMes + "' "
	Else
		cQuery += " AND SUBSTR(RG_DATADEM,1,6)>= '" + cAnoMes + "' "
	EndIf

	If TCSQLEXEC(cQuery) != 0
		UserException( TCSqlError() )
	EndIf

	cQuery := "DELETE FROM " + RetSqlName("SRR")
	cQuery += " WHERE RR_FILIAL = '" + xFilial("SRR") + "' "
	If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
		cQuery += " AND SUBSTRING(RR_DATA,1,6) >= '" + cAnoMes + "' "
	Else
		cQuery += " AND SUBSTR(RR_DATA,1,6)>= '" + cAnoMes + "' "
		cQuery += " AND RR_TIPO3 = 'R' "
	EndIf

	If TCSQLEXEC(cQuery) != 0
		UserException( TCSqlError() )
	EndIf
EndIf

GpContReg(@nTot,@nMinRec,"SRG")

Begin Sequence

	If nTot > 0

		cRecno 	:= "R_E_C_N_O_"
		nCont 	:= nMinRec + 1024

		For nx = 1 to nTot

			cQuery := " UPDATE " + RetSqlName( "SRG" )
			If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
				cQuery += " 		SET RG_PERIODO = SUBSTRING(RG_DATADEM,1,6) , "
			Else
				cQuery += " 		SET RG_PERIODO = SUBSTR(RG_DATADEM,1,6) , "
			EndIf
			If ( cNameDB $ "INFORMIX" )
				cQuery += " 		RG_PROCES = NVL((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RG_FILIAL AND RA_MAT = RG_MAT AND D_E_L_E_T_ <> '*') , ' '), "
			Else
				cQuery += " 		RG_PROCES = COALESCE((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RG_FILIAL AND RA_MAT = RG_MAT AND D_E_L_E_T_ <> '*') , ' '), "
			Endif
			cQuery += " 		RG_ROTEIR = 'RES', "
			cQuery += " 		RG_SEMANA = CASE WHEN RG_SEMANA = '  ' THEN '01' ELSE RG_SEMANA END "
			cQuery += " WHERE RG_FILIAL = '" + xFilial( "SRG" ) + "' AND "
			cQuery += cRecno + ">=" + AllTrim(Str(nMinRec)) + " AND " + cRecno + "<=" + AllTrim(Str(nCont)) + " "

	    	nRet := TCSQLEXEC(cQuery)

	    	If nRet != 0
				UserException( TCSqlError() )
				Break
			EndIf

		   	nMinRec := nCont
		   	nCont  := nMinRec + 1024

		Next nx
	EndIf

	nTot 	:= 0
	nMinRec := 0

	GpContReg(@nTot,@nMinRec,"SRR")

	If nTot > 0

		cRecno	:= "R_E_C_N_O_"
		nCont	:= nMinRec + 1024

		For nx = 1 to nTot
			cQuery := " UPDATE " + RetSqlName( "SRR" )
			If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
				cQuery += " 		SET RR_PERIODO = SUBSTRING(RR_DATA,1,6) , "
			Else
				cQuery += " 		SET RR_PERIODO = SUBSTR(RR_DATA,1,6) , "
			EndIf
			If ( cNameDB $ "INFORMIX" )
				cQuery += "			RR_PROCES = NVL((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RR_FILIAL AND RA_MAT = RR_MAT AND D_E_L_E_T_ <> '*') , ' '), "
			Else
				cQuery += "			RR_PROCES = COALESCE((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RR_FILIAL AND RA_MAT = RR_MAT AND D_E_L_E_T_ <> '*') , ' '), "
			Endif
			cQuery += " 		RR_ROTEIR = 'RES', "
			cQuery += " 		RR_SEMANA = CASE WHEN RR_SEMANA = '  ' THEN '01' ELSE RR_SEMANA END "
			cQuery += " WHERE RR_FILIAL = '" + xFilial( "SRR" ) + "' AND RR_TIPO3 = 'R' AND "
			cQuery += cRecno + ">=" + AllTrim(Str(nMinRec)) + " AND " + cRecno + "<=" + AllTrim(Str(nCont)) + " "

			nRet := TCSQLEXEC(cQuery)

	    	If nRet != 0
				UserException( TCSqlError() )
				Break
			EndIf

		   	nMinRec := nCont
		   	nCont  := nMinRec + 1024
		Next nx
	EndIf

End Sequence

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvSRK    |Autor  ³ Leandro Drumond	    ³ Data ³ 30/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao dos valores futuros (SRK).		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvSRK(aLogFil)

Local cQuery := ""
Local nRet	 := 0
Local nTot	 := 0
Local nMinRec:= 0
Local nCont	 := 0
Local nX	 := 0
Local nTamID := GetSx3Cache( "RK_NUMID" , "X3_TAMANHO" )
Local nTamTot:= GetSx3Cache( "RK_FILIAL" , "X3_TAMANHO" ) + GetSx3Cache( "RK_MAT" , "X3_TAMANHO" ) + GetSx3Cache( "RK_DOCUMENT" , "X3_TAMANHO" )

nTamTot := nTamTot + 6 //("SRK" + Código da verba)

If nTamTot > nTamID
	aAdd( aLogFil[Len(aLogFil)], STR0084 ) //"O tamanho do campo RK_NUMID é menor que o mínimo necessário para a composição da chave." )
	aAdd( aLogFil[Len(aLogFil)], STR0085 + AllTrim(Str(nTamTot)) + STR0107 ) //"Os seguintes campos deverão ter o tamanho alterado para " + AllTrim(Str(nTamTot)) + " através do configurador antes da conversão dos valores futuros."  )
	aAdd( aLogFil[Len(aLogFil)], "R8_NUMID" )
	aAdd( aLogFil[Len(aLogFil)], "RC_NUMID" )
	aAdd( aLogFil[Len(aLogFil)], "RD_NUMID" )
	aAdd( aLogFil[Len(aLogFil)], "RK_NUMID" )
	aAdd( aLogFil[Len(aLogFil)], "RR_NUMID" )
	aAdd( aLogFil[Len(aLogFil)], "RCK_NUMID" )
	aAdd( aLogFil[Len(aLogFil)], "RG1_NUMID" )
	aAdd( aLogFil[Len(aLogFil)], "RGB_NUMID" )
	aAdd( aLogFil[Len(aLogFil)], "RGE_NUMID" )
	Return .F.
EndIf

GpContReg(@nTot,@nMinRec,"SRK")

Begin Sequence

	If nTot > 0

		cRecno	:= "R_E_C_N_O_"
		nCont	:= nMinRec + 1024

		For nX = 1 to nTot

			cQuery := " UPDATE " + RetSqlName( "SRK" )
			If ( cNameDB $ "INFORMIX" )
				cQuery += 			" SET RK_PROCES = NVL((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RK_FILIAL AND RA_MAT = RK_MAT AND D_E_L_E_T_ <> '*') , ' '), "
			Else
				cQuery += 			" SET RK_PROCES = COALESCE((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RK_FILIAL AND RA_MAT = RK_MAT AND D_E_L_E_T_ <> '*') , ' '), "
			Endif

			If !( cNameDB $ "DB2_ORACLE_INFORMIX_POSTGRES" )
				cQuery += 			"RK_PERINI = SUBSTRING(RK_DTVENC,1,6) , "
				cQuery += 			"RK_NUMID = 'SRK'+RK_FILIAL+RK_MAT+RK_PD+RK_DOCUMEN , "
			Else
				cQuery += 			"RK_PERINI = SUBSTR(RK_DTVENC,1,6) , "
				cQuery += 			"RK_NUMID = CONCAT(CONCAT(CONCAT(CONCAT('SRK',RK_FILIAL),RK_MAT),RK_PD),RK_DOCUMEN) , "
			EndIf
			cQuery += 			"RK_STATUS = CASE WHEN RK_PARCELA = RK_PARCPAG THEN '3' ELSE CASE WHEN RK_STATUS = ' ' THEN '2' ELSE RK_STATUS END END , "
			cQuery += 			"RK_NUMPAGO = CASE WHEN RK_NUMPAGO = '  ' THEN '01' ELSE RK_NUMPAGO END "
			cQuery += " WHERE RK_FILIAL = '" + xFilial( "SRK" ) + "' AND "
			cQuery += cRecno + ">=" + AllTrim(Str(nMinRec)) + " AND " + cRecno + "<=" + AllTrim(Str(nCont)) + " "

			nRet := TCSQLEXEC(cQuery)

		    If nRet != 0
				UserException( TCSqlError() )
				Break
			EndIf

			nMinRec := nCont
			nCont  := nMinRec + 1024
		Next nX
	EndIf

End Sequence

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvSRE    |Autor  ³ Leandro Drumond	    ³ Data ³ 05/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao das transferencias (SRE).		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvSRE()

Local cQuery := ""
Local nRet	 := 0
Local nTot	 := 0
Local nMinRec:= 0
Local nCont	 := 0
Local nX	 := 0

GpContReg(@nTot,@nMinRec,"SRE")

Begin Sequence

	If nTot > 0

		cRecno 	:= "R_E_C_N_O_"
		nCont 	:= nMinRec + 1024

		For nX = 1 to nTot

			cQuery := " UPDATE " + RetSqlName( "SRE" )
			If ( cNameDB $ "INFORMIX" )
				cQuery += 			" SET RE_PROCESD = NVL((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RE_FILIALD AND RA_MAT = RE_MATD  AND D_E_L_E_T_ <> '*') , ' '), "
				cQuery += 			"RE_PROCESP = NVL((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RE_FILIALP AND RA_MAT = RE_MATP  AND D_E_L_E_T_ <> '*') , ' ') "
			Else
				cQuery += 			" SET RE_PROCESD = COALESCE((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RE_FILIALD AND RA_MAT = RE_MATD  AND D_E_L_E_T_ <> '*') , ' '), "
				cQuery += 			"RE_PROCESP = COALESCE((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RE_FILIALP AND RA_MAT = RE_MATP  AND D_E_L_E_T_ <> '*') , ' ') "

			Endif
			cQuery += " WHERE RE_FILIAL = '" + xFilial( "SRE" ) + "' AND "
			cQuery += cRecno + ">=" + AllTrim(Str(nMinRec)) + " AND " + cRecno + "<=" + AllTrim(Str(nCont)) + " "

			nRet := TCSQLEXEC(cQuery)

		    If nRet != 0
				UserException( TCSqlError() )
				Break
			EndIf

			nMinRec := nCont
			nCont  := nMinRec + 1024
		Next nX
	EndIf

End Sequence

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvSRC    |Autor  ³ Leandro Drumond	    ³ Data ³ 05/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao do movimento (SRC).				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvSRC(aCodFol)

Local aStruct 	:= SRV->(DbStruct())
Local cQuery 	:= ""
Local cRecno	:= ""
Local cAliasSRC	:= "TSRC"
Local cPdAdi	:= aCodFol[0106,1]+"*"+aCodFol[0107,1]
Local nY		:= 0
Local nTot		:= 0
Local nMinRec	:= 0
Local nX		:= 0

If Empty(cAnoMes)
	cAnoMes := Substr( Dtos(dDatabase) , 1, 6)
EndIf

//Converte lancamentos para RGB
If lPar02
	cQuery := " SELECT SRC.R_E_C_N_O_ RCRECNO, SRC.*, SRA.* FROM " + RetSqlName( "SRC" ) + " SRC "
	cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA "
	cQuery += " ON RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT"
	cQuery += " WHERE SRC.D_E_L_E_T_ = ' ' AND RC_FILIAL = '"+xFilial("SRC")+"' AND RC_TIPO2 IN ('I','V','F','G','E') AND SRA.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY RC_MAT "

	If SELECT(cAliasSRC) > 0
	   	(cAliasSRC)->( dbclosearea() )
	EndIf

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSRC, .F., .T.)

	For nY := 1 To Len(aStruct)
		If ( aStruct[nY][2] <> "C" )
			TcSetField(cAliasSRC,aStruct[nY][1],aStruct[nY][2],aStruct[nY][3],aStruct[nY][4])
		EndIf
	Next nY

	DbSelectArea("RGB")
	DbSetOrder(RetOrder("RGB","RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_SEMANA+RGB_SEQ"))

	While (cAliasSRC)->(!Eof())

		If RGB->(DbSeek((cAliasSRC)->(RC_FILIAL + RC_MAT + RC_PD + RC_CC + RC_SEMANA + RC_SEQ)))
			RecLock("RGB",.F.)
		Else
			RecLock("RGB",.T.)
		EndIf

		RGB->RGB_FILIAL 	:= (cAliasSRC)->RC_FILIAL
		RGB->RGB_PROCES		:= (cAliasSRC)->RA_PROCES
		RGB->RGB_PERIOD		:= cAnoMes
		RGB->RGB_SEMANA		:= If(Empty((cAliasSRC)->RC_SEMANA), "01", (cAliasSRC)->RC_SEMANA)
		If (cAliasSRC)->RC_PD $ cPdAdi .and. (cAliasSRC)->RA_PERCADT > 0
			RGB->RGB_ROTEIR		:= "ADI"
		Else
			RGB->RGB_ROTEIR		:= IIf( (cAliasSRC)->RA_CATFUNC $ "A*P" , "AUT" , "FOL" )
		EndIf
		RGB->RGB_MAT		:= (cAliasSRC)->RC_MAT
		RGB->RGB_PD			:= (cAliasSRC)->RC_PD
		RGB->RGB_TIPO1 		:= (cAliasSRC)->RC_TIPO1
		RGB->RGB_QTDSEM		:= (cAliasSRC)->RC_QTDSEM
		RGB->RGB_HORAS		:= If(Empty((cAliasSRC)->RC_HORINFO), (cAliasSRC)->RC_HORAS, (cAliasSRC)->RC_HORINFO)
		RGB->RGB_VALOR		:= If(Empty((cAliasSRC)->RC_VALINFO), (cAliasSRC)->RC_VALOR, (cAliasSRC)->RC_VALINFO)
		RGB->RGB_DTREF		:= StoD((cAliasSRC)->RC_DATA)
		RGB->RGB_CC			:= (cAliasSRC)->RC_CC
		RGB->RGB_PARCEL		:= (cAliasSRC)->RC_PARCELA
		RGB->RGB_TIPO2		:= (cAliasSRC)->RC_TIPO2
		RGB->RGB_SEQ		:= (cAliasSRC)->RC_SEQ
		RGB->RGB_NUMID		:= (cAliasSRC)->RC_NUMID
		RGB->RGB_POSTO		:= (cAliasSRC)->RC_POSTO
		RGB->RGB_DEPTO		:= (cAliasSRC)->RC_DEPTO
		RGB->RGB_ITEM		:= (cAliasSRC)->RC_ITEM
		RGB->RGB_CLVL		:= (cAliasSRC)->RC_CLVL
		RGB->RGB_IDCMPL		:= (cAliasSRC)->RC_IDCMPL

		RGB->(MSUNLOCK())

		SRC->(DbGoTo((cAliasSRC)->(RCRECNO)))
		RecLock("SRC",.F.)
		SRC->(DbDelete())
		SRC->(MsUnLock())

		(cAliasSRC)->(DbSkip())
	EndDo
EndIf

dbSelectArea("SRC")

If lPar01
	cQuery := "DELETE FROM " + RetSqlName("SRC")
	cQuery += " WHERE RC_FILIAL = '" + xFilial("SRC") + "' "

	If TCSQLEXEC(cQuery) != 0
		UserException( TCSqlError() )
	EndIf
Else
	GpContReg(@nTot,@nMinRec,"SRC")

	If nTot > 0

		cRecno 	:= "R_E_C_N_O_"
		nCont 	:= nMinRec + 1024

		For nX = 1 to nTot
			For nY := 1 To 2
				cQuery := " UPDATE " + RetSqlName( "SRC" )
				cQuery += " 		SET RC_PERIODO = '" + cAnoMes + "', "
				If ( cNameDB $ "INFORMIX" )
					cQuery += " 		RC_PROCES = NVL((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT  AND D_E_L_E_T_ <> '*') , ' '), "
				Else
					cQuery += " 		RC_PROCES = COALESCE((SELECT RA_PROCES FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT  AND D_E_L_E_T_ <> '*') , ' '), "
				Endif
				cQuery += " 		RC_ROTEIR = CASE WHEN RC_TIPO2 = 'A' THEN 'ADI' "
				cQuery += IIf( nY == 1 , " ELSE 'AUT' END, " , " ELSE 'FOL' END, " )
				cQuery += " 		RC_SEMANA = CASE WHEN RC_SEMANA = '  ' THEN '01' ELSE RC_SEMANA END "
				cQuery += " WHERE RC_FILIAL = '" + xFilial( "SRC" ) + "' AND "
				cQuery += cRecno + ">=" + AllTrim(Str(nMinRec)) + " AND " + cRecno + "<=" + AllTrim(Str(nCont)) + " "
				cQuery += " AND RC_MAT IN "
				cQuery += " (SELECT RA_MAT FROM " + RetSqlName("SRA") + " WHERE RA_FILIAL = RC_FILIAL AND RA_CATFUNC "
				cQuery += IIf( nY == 1 , " IN ('A','P') ) " , " NOT IN ('A','P') ) " )

		    	If TCSQLEXEC(cQuery) != 0
					UserException( TCSqlError() )
					Break
				EndIf
			Next nY

		   	nMinRec := nCont
		   	nCont  := nMinRec + 1024

		Next nx
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvBEN    |Autor  ³ Leandro Drumond	    ³ Data ³ 23/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao dos beneficios.					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvBEN(aCodFol)

Local aArea			:= GetArea()
Local aTabS058		:= {}
Local aCabTab		:= {}
Local aSRX			:= {}
Local aTabelas 		:= {{"35","81"},{"39","82"}}
Local cTab			:= "S058"
Local cConteudo		:= ""
Local cFilRIS		:= ""
Local cQuery		:= ""
Local cCodRIS		:= "00"
Local cAliasTst 	:= GetNextAlias()
Local nPosIni 		:= 0
Local nColAte 		:= 0
Local nTamCpo 		:= 0
Local nDecCpo 		:= 0
Local nRegSR5 		:= 0
Local nX			:= 0
Local nT			:= 0
Local nRet			:= 0
Local cSraValeRef 	:= ""
Local cSraValeAli 	:= ""

//Vale Cultura
dbSelectArea("RCB")
If dbSeek(xFilial("RCB")+cTab,.T.)

	While !Eof()

		If RCB->RCB_CODIGO <> cTab
			Exit
		EndIf

		//--Carrega o Cabecalho da Tabela
		aCabTab := {}
		While !Eof() .And. cTab == RCB->RCB_CODIGO
			RCB->(aAdd(aCabTab,{RCB_CAMPOS,RCB_TIPO,RCB_TAMAN,RCB_DECIMA}))
			dbSelectArea("RCB")
			dbSkip()
		Enddo

		//--Carregar Dados das Tabelas
		dbSelectArea("RCC")
		If !dbSeek(xFilial("RCC")+cTab,.T.)
			Exit
		Else
			While !Eof() .And. RCC->RCC_FILIAL+RCC->RCC_CODIGO == xFilial("RCC")+cTab
				// Determina o Periodo para Selecao da Tabela
 				aAdd(aTabS058, {cTab,RCC->RCC_FIL,RCC->RCC_CHAVE,RCC->RCC_SEQUEN})

				nPosIni := 1
				nColAte := 1
				For nT:= 1 To Len(aCabTab)

					//--Tamanho do Campo
					nTamCpo := aCabTab[nT,3]
					nDecCpo := aCabTab[nT,4]

					//--Guarda conteudo do campo na Variavel
					If aCabTab[nT,2] == "C"
						cConteudo := Subs(RCC->RCC_CONTEU,nPosIni,nTamCpo)
					ElseIf aCabTab[nT,2] == "N"
						cConteudo := Val(Subs(RCC->RCC_CONTEU,nPosIni,nTamCpo))
					ElseIf aCabTab[nT,2] == "D"
						cConteudo := Stod(Subs(RCC->RCC_CONTEU,nPosIni,nTamCpo))
					Endif

	 				aAdd(aTabS058[ Len(aTabS058)],cConteudo)

					//--Posicao Proximo Campo
					nPosIni += nTamCpo

				Next nT

				dbSelectArea("RCC")
				dbSkip()
			Enddo

			dbSelectArea("RCB")
			If !Eof()
				dbSkip()
			EndIf
		EndIf
	Enddo
EndIf

DbSelectArea("RIS")
DbSetOrder(1) //RIS_FILIAL+RIS_TPBENE+RIS_COD+STR(RIS_SALATE)

cFilRIS	:= xFilial("RIS")

  	//Procura Vale Cultura
If !Empty(aTabS058)
	For nX := 1 to Len(aTabS058)
		cCodRIS := Soma1(cCodRIS)
		If !RIS->(DbSeek(cFilRIS+"80"+cCodRIS))
			RecLock("RIS",.T.)
			RIS_FILIAL := cFilRIS
			RIS_TPBENE := "80"
			RIS_COD    := cCodRIS
			RIS_DESC   := "Vale Cultura " + cCodRIS
			RIS_SALATE := 0
			RIS_SALMIN := aTabS058[nX,06] //Quantidade de Salário Minimo
			RIS_TPREF  := "1" //Valor Fixo
			RIS_REF    := aTabS058[nX,05]
			RIS_FUNCP  := 100 //No modo antigo sempre era pago 100% do valor informado
			RIS_TPDESC := "1" //Percentual do Beneficio
			RIS_FUNCD  := aTabS058[nX,07]
			RIS_EMP    := 0 //Nao existia estas informacoes
			RIS_MINIMO := 0 //Nao existia estas informacoes
			RIS_MAXIMO := 0 //Nao existia estas informacoes
			RIS->(MsUnLock())
		EndIf
	Next nX
EndIf

//Seguro de Vida
dbSelectArea("SR5")
SR5->(dbSetOrder(1))

dbSelectArea("SRX")
SRX->(dbSetOrder(1))

cTab := "!!"

For nX := 1 to Len(aTabelas)
	If SRX->(dbSeek( xFilial('SRX') + aTabelas[nX,1] ))
		nRegSR5 := 0

		cKeySR5	:= RhTamFilial(xFilial('SR5')) + "X" + SRX->RX_TIP

		While SRX->(!Eof() .And. RX_FILIAL == xFilial('SRX') .And. RX_TIP == aTabelas[nX,1] )

			If !(cTab == SRX->RX_TIP)
				If !Empty(aSRX)
					fGrvBenef(aSRX,cTab)
				EndIf
				cTab := SRX->RX_TIP
				aSRX := {}
			EndIf

			nRegSR5++

			If !SR5->( dbSeek( cKeySR5 + StrZero(nRegSR5,2) ) ) .and. nRegSR5 > 1
				nRegSR5 := 1
				SR5->( dbSeek( cKeySR5 + StrZero(nRegSR5,2) ) )
			EndIf

			If nRegSR5 == 1
				aAdd(aSRX,{})
			EndIf

			While SR5->(!Eof() .And. R5_FILIAL + R5_ARQUIVO + R5_REG == cKeySR5 + StrZero(nRegSR5,2) )
				If Alltrim(SR5->R5_DEONDE) == "RX_TXT"
					If Empty(SR5->R5_POSICAO)
						SR5->(DbSkip())
						Loop
					EndIf
					nPosDe 	:= SR5->R5_DE
					nQuantos:= SR5->R5_QUANTOS
				Else
					If !Empty(Alltrim(SR5->R5_DEONDE)) .and. !(Alltrim(SR5->R5_DEONDE) $ "RX_FILIAL") .and. nRegSR5 == 1
						nPosDe 	:= SR5->R5_DE
						nQuantos:= SR5->R5_QUANTOS
						aAdd(aSRX[Len(aSRX)],(SubStr(SRX->RX_COD,nPosDe,nQuantos)))
					EndIf
					SR5->(DbSkip())
					Loop
				EndIf

				If SR5->R5_TIPO == "N"
					aAdd(aSRX[Len(aSRX)],Val(SubStr(SRX->RX_TXT,nPosDe,nQuantos)))
				Else
					aAdd(aSRX[Len(aSRX)],(SubStr(SRX->RX_TXT,nPosDe,nQuantos)))
				EndIf

				SR5->(DbSkip())
			EndDo

			SRX->(dbSkip())
		EndDo
	EndIf
Next

If !Empty(aSRX)
	fGrvBenef(aSRX,cTab)
EndIf

DbSelectArea("RFO")
DbSetOrder(1)

//Se nao encontrar nada, converte da 11 para 11.8/12
If !DbSeek(xFilial("RFO"))
	fConvRFO()
EndIf

BeginSql alias cAliasTst
	SELECT * FROM %table:SRA% SRA
		WHERE SRA.%notDel%  AND SRA.RA_FILIAL = %exp:xFilial("SRA")% AND
		( SRA.RA_VALEREF <> %exp:' '% OR SRA.RA_VALEALI <> %exp:' '% OR SRA.RA_SEGUROV <> %exp:' '% OR SRA.RA_CESTAB = %exp:'S'% )

EndSql

DbSelectArea("SR0")
DbSetOrder(2) //R0_FILIAL+R0_TPVALE+R0_CODIGO+R0_MAT

//Existe dados de vale transporte no modelo antigo (P11), atualiza para 11.8/12
If SR0->(DbSeek(xFilial("SR0")+"  "))
	cQuery := " UPDATE " + RetSqlName( "SR0" ) + " SET R0_TPVALE = '0', "
	cQuery +=	  									" R0_CODIGO = R0_MEIO, "
	cQuery +=										" R0_MEIO = '  '
	cQuery += " WHERE R0_CODIGO = '  ' AND "
	cQuery += " R0_TPVALE = ' ' AND "
	cQuery += " R0_FILIAL = '" + xFilial("SR0") + "' "

    nRet := TCSQLEXEC(cQuery)

	If nRet != 0
		UserException( TCSqlError() )
	EndIf
EndIf

DbSelectArea("SR0")
DbSetOrder(1) //R0_FILIAL+R0_MAT+R0_CODIGO+R0_TPVALE

DbSelectArea("RI1")
DbSetOrder(1) //RI1_FILIAL+RI1_MAT+RI1_BENEF+RI1_TABELA

While (cAliasTst)->(!Eof())

	cSraValeRef := (cAliasTst)->RA_VALEREF
	cSraValeAli := (cAliasTst)->RA_VALEALI

	If Len((cAliasTst)->RA_VALEREF) == 2
		cSraValeRef := Padr( cSraValeRef, TamSx3("R0_CODIGO")[1])
	EndIf

	//Vale Refeicao
	If !Empty( (cAliasTst)->RA_VALEREF )
		If !(SR0->(DbSeek(xFilial("SR0")+(cAliasTst)->RA_MAT+cSraValeRef+"1")))
			RecLock("SR0",.T.)
				SR0->R0_FILIAL 	:= xFilial("SR0")
				SR0->R0_MAT		:= (cAliasTst)->RA_MAT
				SR0->R0_CODIGO	:= (cAliasTst)->RA_VALEREF
				SR0->R0_TPVALE	:= "1"
			SR0->(MsUnLock())
		EndIf
	EndIf

	If Len((cAliasTst)->RA_VALEALI) == 2
		cSraValeAli := Padr( cSraValeAli, TamSx3("R0_CODIGO")[1])
	EndIf

	//Vale Alimentacao
	If !Empty( (cAliasTst)->RA_VALEALI )
		If !(SR0->(DbSeek(xFilial("SR0")+(cAliasTst)->RA_MAT+cSraValeAli+"2")))
			RecLock("SR0",.T.)
				SR0->R0_FILIAL 	:= xFilial("SR0")
				SR0->R0_MAT		:= (cAliasTst)->RA_MAT
				SR0->R0_CODIGO	:= (cAliasTst)->RA_VALEALI
				SR0->R0_TPVALE	:= "2"
			SR0->(MsUnLock())
		EndIf
	EndIf
	//Seguro de Vida
	If !Empty( (cAliasTst)->RA_SEGUROV )
		If !(RI1->(DbSeek(xFilial("RI1")+(cAliasTst)->RA_MAT+"82"+(cAliasTst)->RA_SEGUROV)))
			RecLock("RI1",.T.)
				RI1->RI1_FILIAL := xFilial("RI1")
				RI1->RI1_MAT	:= (cAliasTst)->RA_MAT
				RI1->RI1_TABELA	:= (cAliasTst)->RA_SEGUROV
				RI1->RI1_BENEF	:= "82"
				RI1->RI1_PD1	:= aCodFol[153,1]
				RI1->RI1_PD2	:= aCodFol[154,1]
			RI1->(MsUnLock())
		EndIf
	EndIf

	//Cesta Basica
	If (cAliasTst)->RA_CESTAB == 'S'
		If !(RI1->(DbSeek(xFilial("RI1")+(cAliasTst)->RA_MAT+"81"+"01")))
			RecLock("RI1",.T.)
				RI1->RI1_FILIAL := xFilial("RI1")
				RI1->RI1_MAT	:= (cAliasTst)->RA_MAT
				RI1->RI1_TABELA	:= "01"
				RI1->RI1_BENEF	:= "81"
			RI1->(MsUnLock())
		EndIf
	EndIf

	(cAliasTst)->(DbSkip())
EndDo

(cAliasTst)->(DbCloseArea())

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fGrvBenef  |Autor  ³ Leandro Drumond	    ³ Data ³ 22/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava beneficios.								          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGrvBenef(aSRX,cTab)

Local aArea 	:= GetArea()
Local cCodRIS 	:= "00"
Local cFilRIS	:= xFilial("RIS")
Local nX		:= 0
Local nPosAux	:= 0

DbSelectArea("RIS")
DbSetOrder(1) //RIS_FILIAL+RIS_TPBENE+RIS_COD+STR(RIS_SALATE)

If cTab == "35"
	For nX := 1 to Len(aSRX)
		If Empty(aSRX[nX])
			Loop
		EndIf
		nPosAux := 5
		While .T.
			If nPosAux > 17 .or. aSRX[nX,nPosAux] == 0
				Exit
			EndIf
			cCodRIS := Soma1(cCodRIS)
			If !RIS->(DbSeek(cFilRIS+"81"+cCodRIS)) .or. AllTrim(STR(RIS->RIS_SALATE)) <> AllTrim(STR(aSRX[nX,nPosAux]))
				RecLock("RIS",.T.)
				RIS_FILIAL := cFilRIS
				RIS_TPBENE := "81"
				RIS_COD    := cCodRIS
				RIS_DESC   := "Cesta Básica " + cCodRIS
				RIS_SALATE := aSRX[nX,nPosAux]
				RIS_SALMIN := 0
				RIS_TPREF  := "1" //Valor Fixo
				RIS_REF    := aSRX[nX,3]
				RIS_FUNCP  := 100
				RIS_TPDESC := "1" //Percentual do Beneficio
				RIS_FUNCD  := aSRX[nX,nPosAux+1]
				RIS_EMP    := 100 - aSRX[nX,nPosAux+1]
				RIS_MINIMO := 0
				RIS_MAXIMO := 0
				RIS->(MsUnLock())
			EndIf
			nPosAux += 3
		EndDo
	Next nX
ElseIf cTab == "39"

	For nX := 1 to Len(aSRX)
		If Empty(aSRX[nX])
			Loop
		EndIf
		nPosAux := 6
		While .T.
			If nPosAux > 34 .or. aSRX[nX,nPosAux] == 0
				Exit
			EndIf
			If !Empty(aSRX[nX,02])
				If !RIS->(DbSeek(cFilRIS+"82"+aSRX[nX,02]+AllTrim(STR(aSRX[nX,nPosAux])))) //.or. AllTrim(STR(RIS->RIS_SALMIN)) <> AllTrim(STR(aSRX[nX,nPosAux]))
					RecLock("RIS",.T.)
					RIS_FILIAL := cFilRIS
					RIS_TPBENE := "82"
					RIS_COD    := aSRX[nX,02]
					RIS_DESC   := aSRX[nX,04]
					RIS_SALATE := aSRX[nX,nPosAux]
					RIS_SALMIN := 0
					RIS_TPREF  := "1" //Valor Fixo
					RIS_REF    := aSRX[nX,nPosAux+3]
					RIS_FUNCP  := 100
					RIS_TPDESC := "1" //Percentual do Beneficio
					RIS_FUNCD  := aSRX[nX,nPosAux+1]
					RIS_EMP    := aSRX[nX,nPosAux+2]
					RIS_MINIMO := aSRX[nX,nPosAux+4]
					RIS_MAXIMO := aSRX[nX,nPosAux+5]
					RIS->(MsUnLock())
				EndIf
			EndIf
			nPosAux += 7
		EndDo
	Next nX
EndIf

RestArea(aArea)

Return Nil

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
Local cWhere 	:= " WHERE " + cPrefixo + "_FILIAL = '" + xFilial( cAlias ) + "' AND D_E_L_E_T_ <> '*'"

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
±±ºPrograma  ³fCargaRCM     ºAutor ³Leandro Drumond  º Data ³  03/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua carga dos tipos de ausencia padrao                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fCargaRCM()
Local aArea	  	:= GetArea()
Local aVerbErr	:= {}
Local aCodFol 	:= {}
Local aCabRCM 	:= {}
Local aDadRCM 	:= {}
Local aFillAtu	:= FWLoadSM0()
Local cFilVerba	:= ""
Local cFilAux 	:= cFilAnt
Local cFilRCM	:= xFilial("RCM")
Local nMComiss	:= SuperGetMv("MV_MCOMISS",,0)
Local cAbatAfa	:= SuperGetMv("MV_ABATAFA",,"S")
Local cPfCalc	:= SuperGetMV("MV_PFCALAC",,"C")
Local cPfCalad	:= SuperGetMV("MV_PFCALAD",,"C")
Local cTafafer	:= SuperGetMV("MV_TAFAFER",,"")
Local cPdCalac	:= SuperGetMV("MV_PDCALAC",,"S")
Local cPdCalad	:= SuperGetMV("MV_PDCALAC",,"S")
Local cPdCadoc	:= SuperGetMV("MV_PDCADOC",,"S")
Local nX	  	:= 0
Local nY	  	:= 0

If !fp_CodFol( @aCodFol , xFilial("SRV"), cFilRCM == xFilial("RCM") )
	aCodFol := {}
EndIf

If !Empty(aCodFol)

	aDadRCM   := {}

	aCabRCM   := {"RCM_TIPO","RCM_DESCRI"																	       ,"RCM_TIPOAF"	,"RCM_DIASEM"	,"RCM_TIPODI"	,"RCM_PD"		  	,"RCM_REINCI"	,"RCM_SOBREP"	,"RCM_CODSEF"	,"RCM_CODRAI"	,"RCM_DEPFGT"	,"RCM_ENCEMP"	,"RCM_FERIAS"	,"RCM_DECIMO"										,"RCM_PROVFE"  										,"RCM_PROV13"																,"RCM_PLR"	,"RCM_DIAS13"	,"RCM_DIASPL"	,"RCM_DIASFE"	,"RCM_MESMED"	,"RCM_CATMED"  	,"RCM_CODHOM"	, "RCM_CSIND", "RCM_SALFAM" }

	aAdd(aDadRCM,{"001"		,"Férias"																		       	,"4"			,999			,"2"			,aCodFol[72,1]  	,0				,"2"			,""				,""				,"2"			,"2"			,"4"			,"2"												,"1"		  										,If(cAbatAfa=="S","1","2")		  											,"2"		,0				,0				,0				,0				,""           	,""				,"1" 		 , "4"})
	aAdd(aDadRCM,{"002"		,"Recesso"																		       	,"4"			,999			,"2"			,aCodFol[891,1] 	,0				,"2"			,""				,""				,"2"			,"2"			,"4"			,"2"												,"1"												,If(cAbatAfa=="S","1","2")													,"2"		,0				,0				,0				,0				,""           	,""				,"1"		 , "4"})
	aAdd(aDadRCM,{"003"		,"Afastamento Temporário Acidente Trabalho"										 		,"1"			,15				,"2"			,aCodFol[42,1]  	,60				,"2"			,"O1"			,"10"			,"1"			,"2"			,"1"			,If(cAbatAfa=="S" .or. "O" $ cAbatAfa,"1","2")		,If(cPfCalc=="S","1",(If(cPfCalc=="N","2","3")))	,If(cAbatAfa=="S" .or. "O" $ cAbatAfa,(If(cPdCalac=="S","1","2")),"2")	,"1"		,15				,15				,15				,6				,"CTIJ"       	,"O1 "			,"2"		 , "2"})
	aAdd(aDadRCM,{"004"		,"Afastamento Temporário por Doença"											    	,"1"			,15				,"2"			,aCodFol[41,1]  	,60				,"2"			,"P1"			,"40"			,"2"			,"2"			,"1"			,If(cAbatAfa=="S" .or. "P" $ cAbatAfa,"1","2")		,If(cPfCalad=="S","1",(If(cPfCalad=="N","2","3")))	,If(cAbatAfa=="S" .or. "P" $ cAbatAfa,(If(cPdCalad=="S","1","2")),"2")	,"1"		,15				,15				,15				,6				,"CTIJ"       	,"P1 "			,"2"		 , "2"})
	aAdd(aDadRCM,{"005"		,"Afastamento Temporário para Prestação Serviço Militar"						 		,"1"			,0				,"2"			,""				  	,0				,"2"			,"R"			,"60"			,"1"			,"2"			,"2"			,If(cAbatAfa=="S" .or. "R" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "R" $ cAbatAfa,"1","2")								,"1"		,1				,1				,1				,0				,""           	,"R  "			,"1"		 , "4"})
	aAdd(aDadRCM,{"006"		,"Afastamento Temporário por Motivo de Licença-Maternidade Pago pela Empresa" 			,"1"			,999			,"2"			,aCodFol[40,1]  	,0				,"2"			,"Q1"			,"50"			,"2"			,"2"			,"4"			,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")								,"1"		,1				,1				,0				,nMComiss		,"ACDEGHIJMPST"	,"Q1 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"007"		,"Afastamento Temporário por Motivo de Licença-Maternidade Pago pelo INSS"	 			,"1"			,0				,"2"			,""				  	,0				,"2"			,"Q1"			,"50"			,"1"			,"1"			,"4"			,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")								,"1"		,1				,1				,0				,nMComiss		,"ACDEGHIJMPST"	,"Q1 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"008"		,"Prorrogação do Afastamento Temporário por Motivo de Licença-Maternidade"	 			,"1"			,60				,"2"			,aCodFol[927,1] 	,0				,"2"			,"Q2"			,"50"			,"2"			,"2"			,"4"			,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")								,"1"		,0				,1				,0				,nMComiss		,"ACDEGHIJMPST"	,"Q2 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"009"		,"Afastamento Temporário por Motivo de Aborto não Criminoso"					 		,"1"			,999			,"2"			,aCodFol[40,1]  	,0				,"2"			,"Q3"			,"50"			,"2"			,"2"			,"4"			,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")								,"1"		,1				,1				,0				,nMComiss		,"ACDEGHIJMPST"	,"Q3 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"010"		,"Licença-Maternidade Decorrente de Adoção (120 Dias)"						    		,"1"			,0				,"2"			,""				  	,0				,"2"			,"Q4"			,"50"			,"1"			,"1"			,"4"			,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,(If(cPdCadoc=="S","1","2")),"2")	,"1"		,1				,1				,0				,nMComiss		,"ACDEGHIJMPST"	,"Q4 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"011"		,"Licença-Maternidade Decorrente de Adoção Criança Entre 1 e 4 Anos (60 Dias)"			,"1"			,0				,"2"			,""				  	,0				,"2"			,"Q5"			,"50"			,"1"			,"1"			,"4"			,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,(If(cPdCadoc=="S","1","2")),"2")	,"1"		,1				,1				,0				,nMComiss		,"ACDEGHIJMPST"	,"Q5 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"012"		,"Licença-Maternidade Decorrente de Adoção Criança Acima 4 Anos (30 Dias)"	 			,"1"			,0				,"2"			,""				  	,0				,"2"			,"Q6"			,"50"			,"1"			,"1"			,"4"			,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "Q" $ cAbatAfa,(If(cPdCadoc=="S","1","2")),"2")	,"1"		,1				,1				,0				,nMComiss		,"ACDEGHIJMPST"	,"Q6 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"013"		,"Afastamento Temporário Mandato Sindical"										 		,"1"			,0				,"2"			,""				  	,0				,"2"			,"W"			,"70"			,"1"			,"2"			,"2"			,If(cAbatAfa=="S" .or. "W" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "W" $ cAbatAfa,"1","2")								,"1"		,1				,1				,1				,0				,""           	,"W  "			,"1"		 , "4"})
	aAdd(aDadRCM,{"014"		,"Licença sem Vencimentos"														    	,"1"			,0				,"2"			,""				  	,0				,"2"			,"X"			,"70"			,"2"			,"2"			,"2"			,If(cAbatAfa=="S" .or. "X" $ cAbatAfa,"1","2")		,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" .or. "X" $ cAbatAfa,"1","2")								,"1"		,1				,1				,1				,0				,""           	,"X2 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"015"		,"Licença Remunerada"															    	,"1"			,999			,"2"			,aCodFol[103,1] 	,0				,"2"			,""				,""				,"2"			,"2"			,"3"			,"2"				   								,If("R" $ cTafafer,"1","2")							,If(cAbatAfa=="S" ,"1","2")													,"1"		,0				,1				,30				,0				,""           	,"X1 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"016"		,"Outros Motivos de Afastamento Temporário"										 		,"1"			,0				,"2"			,""			     	,0				,"2"			,"Y"			,"70"			,"2"			,"2"			,"2"			,If(cAbatAfa=="S" .or. "Y" $ cAbatAfa,"1","2")		,"2"												,If(cAbatAfa=="S" .or. "Y" $ cAbatAfa,"1","2")								,"1"		,1				,1				,1				,0				,""          	,""				,"1"		 , "4"})
	aAdd(aDadRCM,{"017"		,"Aposentadoria por Invalidez"													    	,"1"			,0				,"2"			,""				  	,0				,"2"			,"U3"			,"70"			,"2"			,"2"			,"2"			,If(cAbatAfa=="S" .or. "U" $ cAbatAfa,"1","2")		,"2"		   										,If(cAbatAfa=="S" .or. "U" $ cAbatAfa,"1","2")								,"1"		,1				,1				,1				,0				,""           	,"U3 "			,"1"		 , "4"})
	aAdd(aDadRCM,{"018"		,"Mudança por Regime Estatuário"												 		,"1"			,0				,"2"			,""				  	,0				,"2"			,"M"			,"60" 			,"1"			,"2"			,"2"			,If(cAbatAfa=="S" .or. "M" $ cAbatAfa,"1","2")		,"2"		 										,If(cAbatAfa=="S" .or. "M" $ cAbatAfa,"1","2")	  							,"1"		,1				,1				,1				,0				,""           	,"M  "			,"1"		 , "4"})

	DbSelectArea("RCM")

	For nX := 1 to Len(aDadRCM)
		RCM->( DBSETORDER(1) )
		If !RCM->( DBSEEK( xFilial("RCM") + aDadRCM[nX,1] ) )
			RecLock("RCM",.T.)
			RCM->RCM_FILIAL := xFilial("RCM")
			For nY := 1 to Len(aCabRCM)
				&(aCabRCM[nY]) := aDadRCM[nX,nY]
			Next nY
			MsUnLock()
		EndIf
	Next nX

	While GETSX8NUM("RCM","RCM_TIPO") <= "017"
		ConfirmSX8()
	EndDo

	RollBackSx8() //Da rollback no ultimo getsx8 efetuado antes de sair do while

Else
		//Corre o getsx8num até i 017 para permitir cadastros somente a partir do 018
	While GETSX8NUM("RCM","RCM_TIPO") <= "017"
		ConfirmSX8()
	EndDo
	RollBackSx8() //Da rollback no ultimo getsx8 efetuado antes de sair do while
EndIf

cFilAnt := cFilAux

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fSR5toRCB     ºAutor ³Leandro Drumond  º Data ³  16/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os campos da SR5 e seu correspondente na RCB        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSR5toRCB()
Local aArea		:= GetArea()
Local cArqNtx	:= ""
Local nIndex	:= 0
Local nX		:= 0

//So carrega uma vez
If !Empty(aSR5toRCB)
	Return Nil
EndIf

aAdd( aSR5toRCB , { "X03_TIP01",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"01","","",""})
aAdd( aSR5toRCB , { "X03_VAL01",0,0,"VALOR","S080","RCC_CONTEUD",0,"02","","",""})
aAdd( aSR5toRCB , { "X03_TIP02",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"03","","",""})
aAdd( aSR5toRCB , { "X03_VAL02",0,0,"VALOR","S080","RCC_CONTEUD",0,"04","","",""})
aAdd( aSR5toRCB , { "X03_TIP03",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"05","","",""})
aAdd( aSR5toRCB , { "X03_VAL03",0,0,"VALOR","S080","RCC_CONTEUD",0,"06","","",""})
aAdd( aSR5toRCB , { "X03_TIP04",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"07","","",""})
aAdd( aSR5toRCB , { "X03_VAL04",0,0,"VALOR","S080","RCC_CONTEUD",0,"08","","",""})
aAdd( aSR5toRCB , { "X03_TIP05",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"09","","",""})
aAdd( aSR5toRCB , { "X03_VAL05",0,0,"VALOR","S080","RCC_CONTEUD",0,"10","","",""})
aAdd( aSR5toRCB , { "X03_TIP06",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"11","","",""})
aAdd( aSR5toRCB , { "X03_VAL06",0,0,"VALOR","S080","RCC_CONTEUD",0,"12","","",""})
aAdd( aSR5toRCB , { "X03_TIP07",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"13","","",""})
aAdd( aSR5toRCB , { "X03_VAL07",0,0,"VALOR","S080","RCC_CONTEUD",0,"14","","",""})
aAdd( aSR5toRCB , { "X03_TIP08",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"15","","",""})
aAdd( aSR5toRCB , { "X03_VAL08",0,0,"VALOR","S080","RCC_CONTEUD",0,"16","","",""})
aAdd( aSR5toRCB , { "X03_TIP09",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"17","","",""})
aAdd( aSR5toRCB , { "X03_VAL09",0,0,"VALOR","S080","RCC_CONTEUD",0,"18","","",""})
aAdd( aSR5toRCB , { "X03_TIP10",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"19","","",""})
aAdd( aSR5toRCB , { "X03_VAL10",0,0,"VALOR","S080","RCC_CONTEUD",0,"20","","",""})
aAdd( aSR5toRCB , { "X03_TIP11",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"21","","",""})
aAdd( aSR5toRCB , { "X03_VAL11",0,0,"VALOR","S080","RCC_CONTEUD",0,"22","","",""})
aAdd( aSR5toRCB , { "X03_TIP12",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"23","","",""})
aAdd( aSR5toRCB , { "X03_VAL12",0,0,"VALOR","S080","RCC_CONTEUD",0,"24","","",""})
aAdd( aSR5toRCB , { "X03_TIP13",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"25","","",""})
aAdd( aSR5toRCB , { "X03_VAL13",0,0,"VALOR","S080","RCC_CONTEUD",0,"26","","",""})
aAdd( aSR5toRCB , { "X03_TIP14",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"27","","",""})
aAdd( aSR5toRCB , { "X03_VAL14",0,0,"VALOR","S080","RCC_CONTEUD",0,"28","","",""})
aAdd( aSR5toRCB , { "X03_TIP15",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"29","","",""})
aAdd( aSR5toRCB , { "X03_VAL15",0,0,"VALOR","S080","RCC_CONTEUD",0,"30","","",""})
aAdd( aSR5toRCB , { "X03_TIP16",0,0,"MOEDACED","S080","RCC_CONTEUD",0,"31","","",""})
aAdd( aSR5toRCB , { "X03_VAL16",0,0,"VALOR","S080","RCC_CONTEUD",0,"32","","",""})
aAdd( aSR5toRCB , { "X06_EMPRE1",0,0,"FILIAL","S036","RCC_FIL",0,"","","",""})
aAdd( aSR5toRCB , { "X06_DESCRI",0,0,"MENSAGEM","S036","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X08_AA1",0,0,"ANO","S001","",0,"","","",""})
aAdd( aSR5toRCB , { "X08_MM1",0,0,"MES","S001","",0,"","","",""})
aAdd( aSR5toRCB , { "X08_LIM1",0,0,"SALCATE","S001","RCC_CONTEUD",0,"01","","",""})
aAdd( aSR5toRCB , { "X08_LIM2",0,0,"SALCATE","S001","RCC_CONTEUD",0,"04","","",""})
aAdd( aSR5toRCB , { "X08_LIM3",0,0,"SALCATE","S001","RCC_CONTEUD",0,"07","","",""})
aAdd( aSR5toRCB , { "X08_PERC1",0,0,"PERCINSS","S001","RCC_CONTEUD",0,"02","","",""})
aAdd( aSR5toRCB , { "X08_PERC2",0,0,"PERCINSS","S001","RCC_CONTEUD",0,"05","","",""})
aAdd( aSR5toRCB , { "X08_PERC3",0,0,"PERCINSS","S001","RCC_CONTEUD",0,"08","","",""})
aAdd( aSR5toRCB , { "X08_PIR1",0,0,"PERCDIR","S001","RCC_CONTEUD",0,"03","","",""})
aAdd( aSR5toRCB , { "X08_PIR2",0,0,"PERCDIR","S001","RCC_CONTEUD",0,"06","","",""})
aAdd( aSR5toRCB , { "X08_PIR3",0,0,"PERCDIR","S001","RCC_CONTEUD",0,"09","","",""})
aAdd( aSR5toRCB , { "X08_LIM4",0,0,"SALCATE","S001","RCC_CONTEUD",0,"10","","",""})
aAdd( aSR5toRCB , { "X08_PERC4",0,0,"PERCINSS","S001","RCC_CONTEUD",0,"11","","",""})
aAdd( aSR5toRCB , { "X08_PIR4",0,0,"PERCDIR","S001","RCC_CONTEUD",0,"12","","",""})
aAdd( aSR5toRCB , { "X09_AA1",0,0,"ANO","S002","",0,"","","",""})
aAdd( aSR5toRCB , { "X09_MM1",0,0,"MES","S002","",0,"","","",""})
aAdd( aSR5toRCB , { "X09_REND1",0,0,"ISENCAO","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_REND2",0,0,"REND1","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_ALIQ2",0,0,"ALIQ1","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_PARC2",0,0,"DED1","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_REND3",0,0,"REND2","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_ALIQ3",0,0,"ALIQ2","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_PARC3",0,0,"DED2","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_REND4",0,0,"REND3","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_ALIQ4",0,0,"ALIQ3","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_PARC4",0,0,"DED3","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_REND5",0,0,"REND4","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_ALIQ5",0,0,"ALIQ4","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_PARC5",0,0,"DED4","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_DEDDEP",0,0,"DEDDEP","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_LIMDEP",0,0,"LIMDEP","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X09_RETMIN",0,0,"RETMIN","S002","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X10_AA1",0,0,"ANO","S003","",0,"","","",""})
aAdd( aSR5toRCB , { "X10_MM1",0,0,"MES","S003","",0,"","","",""})
aAdd( aSR5toRCB , { "X10_LIM1",0,0,"VLLIMITE","S003","RCC_CONTEUD",0,"01","","",""})
aAdd( aSR5toRCB , { "X10_COTA1",0,0,"VLCOTA","S003","RCC_CONTEUD",0,"02","","",""})
aAdd( aSR5toRCB , { "X10_LIM2",0,0,"VLLIMITE","S003","RCC_CONTEUD",0,"03","","",""})
aAdd( aSR5toRCB , { "X10_COTA2",0,0,"VLCOTA","S003","RCC_CONTEUD",0,"04","","",""})
aAdd( aSR5toRCB , { "X11_AA1",0,0,"ANO","S004","",0,"","","",""})
aAdd( aSR5toRCB , { "X11_MM1",0,0,"MES","S004","",0,"","","",""})
aAdd( aSR5toRCB , { "X11_MINIMO",0,0,"VLSALMIN","S004","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_EMPRE1",0,0,"FILIAL","S037","RCC_FIL",0,"","","",""})
aAdd( aSR5toRCB , { "X14_AA1",0,0,"ANO","S037","",0,"","","",""})
aAdd( aSR5toRCB , { "X14_MM1",0,0,"MES","S037","",0,"","","",""})
aAdd( aSR5toRCB , { "X14_PEREMP",0,0,"EMPRESA","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_PERTER",0,0,"TERCEIRO","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_PERACT",0,0,"ACIDTRB","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_FGTS",0,0,"FGTS","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_PRO13",0,0,"PROV13","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_PROFER",0,0,"PROVFER","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SALEDU",0,0,"SALEDU","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_INCRA",0,0,"INCRA","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SENAI",0,0,"SENAI","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SESI",0,0,"SESI","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SENAC",0,0,"SENAC","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SESC",0,0,"SESC","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SEBRAE",0,0,"SEBRAE","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_DPC",0,0,"DPC","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_FAER",0,0,"FAER","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SENAR",0,0,"SENAR","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SECONC",0,0,"SECONC","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_TERCEI",0,0,"CODTERC","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_CODEMP",0,0,"CODFGTS","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_PROVRE",0,0,"PROVRES","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SEST",0,0,"SEST","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SENAT",0,0,"SENAT","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SIMPLE",0,0,"OPSIMPLES","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_CODGPS",0,0,"CDPTOGPS","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_SESCOO",0,0,"SESCOOP","S038","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_RECFAT",0,0,"RECFATUR","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_MINGPS",0,0,"VLRMINGP","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X14_PERRAT",0,0,"RAT","S037","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_EMPRE1",0,0,"FILIAL","S035","RCC_FIL",0,"","","",""})
aAdd( aSR5toRCB , { "X15_AA1",0,0,"ANO","S035","",0,"","","",""})
aAdd( aSR5toRCB , { "X15_MM1",0,0,"MES","S035","",0,"","","",""})
aAdd( aSR5toRCB , { "X15_CC",0,0,"CDECUSTO","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_PD",0,0,"VERBA","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_BASE",0,0,"BASE","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_PERC",0,0,"PERCENTUAL","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_VALOR",0,0,"VALOR","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_TPCONT",0,0,"TPCONTR","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_RECDED",0,0,"RECDED","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_OBS",0,0,"OBSERVACAO","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_CMPINM",0,0,"CMPINIMM","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_CMPINA",0,0,"CMPANOIN","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_CMPFIM",0,0,"CMPFIMMM","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X15_CMPFIA",0,0,"CMPFIMAN","S035","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_COD",0,0,"TIPORESC","S043","",0,"","","",""})
aAdd( aSR5toRCB , { "X32_DESCRI",0,0,"DESCRICAO","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_INDENI",0,0,"INDENIZACA","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_AVIPRE",0,0,"AVISOPREV","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_13RESC",0,0,"DTRESCIS","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_FERPRO",0,0,"FERPROPOR","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_FGTSMA",0,0,"FGTSMANT","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_FGTSMR",0,0,"FGTSMRES","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_FGTS40",0,0,"FGTSMULTA","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_DSRMFE",0,0,"DSRMEDFE","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_DSRM13",0,0,"DSRMEDDT","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_DSRMAP",0,0,"DSRMAVP","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_PERCFG",0,0,"FGTS","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_RESCRA",0,0,"RESCRAIS","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_AFASFG",0,0,"AFASTFGTS","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_CODAM",0,0,"CODIGOAM","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_PGTEXP",0,0,"PGTCONTE","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_DESEXP",0,0,"DESCONTE","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_MTADIS",0,0,"SALINDDI","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_SDOSAL",0,0,"SDOSALARI","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_NOMSAC",0,0,"IMPSACADO","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_CODHOM",0,0,"CODHOMOLO","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X32_MOTDES",0,0,"MOTDES","S043","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X41_EMPRE1",0,0,"FILIAL","S039","RCC_FIL",0,"","","",""})
aAdd( aSR5toRCB , { "X41_SIND",0,0,"SINDICATO","S039","",0,"","","",""})
aAdd( aSR5toRCB , { "X41_AA1",0,0,"ANO","S039","",0,"","","",""})
aAdd( aSR5toRCB , { "X41_MM1",0,0,"MES","S039","",0,"","","",""})
aAdd( aSR5toRCB , { "X41_INDICE",0,0,"REAJMEDIA","S039","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X44_SIND1",0,0,"SINDICATO","S040","",0,"","","",""})
aAdd( aSR5toRCB , { "X44_DE1",0,0,"INIFAIXA","S040","RCC_CONTEUD",0,"01","","",""})
aAdd( aSR5toRCB , { "X44_ATE1",0,0,"FIMFAIXA","S040","RCC_CONTEUD",0,"02","","",""})
aAdd( aSR5toRCB , { "X44_PERC1",0,0,"PORCFAIXA","S040","RCC_CONTEUD",0,"03","","",""})
aAdd( aSR5toRCB , { "X44_DE2",0,0,"INIFAIXA","S040","RCC_CONTEUD",0,"04","","",""})
aAdd( aSR5toRCB , { "X44_ATE2",0,0,"FIMFAIXA","S040","RCC_CONTEUD",0,"05","","",""})
aAdd( aSR5toRCB , { "X44_PERC2",0,0,"PORCFAIXA","S040","RCC_CONTEUD",0,"06","","",""})
aAdd( aSR5toRCB , { "X44_DE3",0,0,"INIFAIXA","S040","RCC_CONTEUD",0,"07","","",""})
aAdd( aSR5toRCB , { "X44_ATE3",0,0,"FIMFAIXA","S040","RCC_CONTEUD",0,"08","","",""})
aAdd( aSR5toRCB , { "X44_PERC3",0,0,"PORCFAIXA","S040","RCC_CONTEUD",0,"09","","",""})
aAdd( aSR5toRCB , { "X44_DE4",0,0,"INIFAIXA","S040","RCC_CONTEUD",0,"10","","",""})
aAdd( aSR5toRCB , { "X44_ATE4",0,0,"FIMFAIXA","S040","RCC_CONTEUD",0,"11","","",""})
aAdd( aSR5toRCB , { "X44_PERC4",0,0,"PORCFAIXA","S040","RCC_CONTEUD",0,"12","","",""})
aAdd( aSR5toRCB , { "X44_DE5",0,0,"INIFAIXA","S040","RCC_CONTEUD",0,"13","","",""})
aAdd( aSR5toRCB , { "X44_ATE5",0,0,"FIMFAIXA","S040","RCC_CONTEUD",0,"14","","",""})
aAdd( aSR5toRCB , { "X44_PERC5",0,0,"PORCFAIXA","S040","RCC_CONTEUD",0,"15","","",""})
aAdd( aSR5toRCB , { "X44_DE6",0,0,"INIFAIXA","S040","RCC_CONTEUD",0,"16","","",""})
aAdd( aSR5toRCB , { "X44_ATE6",0,0,"FIMFAIXA","S040","RCC_CONTEUD",0,"17","","",""})
aAdd( aSR5toRCB , { "X44_PERC6",0,0,"PORCFAIXA","S040","RCC_CONTEUD",0,"18","","",""})
aAdd( aSR5toRCB , { "X44_DTBASE",0,0,"DATABASE","S040","",0,"","","",""})
aAdd( aSR5toRCB , { "X45_EMPRE1",0,0,"FILIAL","S041","RCC_FIL",0,"","","",""})
aAdd( aSR5toRCB , { "X45_AA1",0,0,"ANO","S041","",0,"","","",""})
aAdd( aSR5toRCB , { "X45_PTEMPR",0,0,"PORTEEMPR","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_PAT",0,0,"PARTICPAT","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_VIATE5",0,0,"VATE5MIN","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_VIACI5",0,0,"VACI5MIN","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_SERVPR",0,0,"SERVPRO","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_ADMCOZ",0,0,"ADMCOZI","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_RFCONV",0,0,"REFCON","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_RFTRAN",0,0,"REFTRAN","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_CESTAL",0,0,"CESTAAL","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_ALCONV",0,0,"ALIMCON","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_EXERAT",0,0,"EXERCATIV","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_CENCER",0,0,"ENCERRATI","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X45_DENCER",0,0,"DATENCERR","S041","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X46_EMPRE1",0,0,"FILIAL","S042","RCC_FIL",0,"","","",""})
aAdd( aSR5toRCB , { "X46_SINDI1",0,0,"SINDICATO","S042","",0,"","","",""})
aAdd( aSR5toRCB , { "X46_SEQ1",0,0,"SEQUENCIA","S042","",0,"","","",""})
aAdd( aSR5toRCB , { "X46_MESPER",0,0,"NMESES","S042","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X46_NROPER",0,0,"NPERIODO","S042","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X46_DIAMES",0,0,"DTRABMES","S042","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X46_FATFER",0,0,"FATFERIAS","S042","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X59_CODTA1",0,0,"CODTAREFA","S070","",0,"","","",""})
aAdd( aSR5toRCB , { "X59_DESCRI",0,0,"DESCRICAO","S070","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X59_VALUNI",0,0,"VALUNITAR","S070","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X59_CODVER",0,0,"CODVERBA","S070","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X59_DTREAJ",0,0,"DTREAJUST","S070","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X59_HRSEXT",0,0,"CODHE","S070","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X59_HRSFAL",0,0,"CODFAL","S070","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X59_DTBLOQ",0,0,"DATABLOQ","S070","RCC_CONTEUD",0,"","","",""})
aAdd( aSR5toRCB , { "X59_MOTBLQ",0,0,"CODBLOQ","S070","RCC_CONTEUD",0,"","","",""})

DbSelectArea("SR5")
cArqNtx  := CriaTrab("",.F.)
SR5->( IndRegua( "SR5" , cArqNtx , "R5_FILIAL+R5_ARQUIVO+R5_CAMPO" , NIL , NIL , NIL , .F. ) )
nIndex := RetIndex("SR5")

dbSetOrder(nIndex+1)

For nX := 1 to Len(aSR5toRCB)
	If DbSeek(RhTamFilial(xFilial("SR5")) + SubStr(aSR5toRCB[nX,01],1,3) + aSR5toRCB[nX,01])
		aSR5toRCB[nX,02] := R5_DE
		aSR5toRCB[nX,03] := R5_QUANTOS
		aSR5toRCB[nX,09] := If(AllTrim(R5_DEONDE) == "RX_TXT","RX_TXT","RX_COD")
		aSR5toRCB[nX,10] := R5_REG
	EndIf
Next nX

dbSetOrder(1)
FErase (cArqNtx+OrdBagExt())

DbSelectArea("RCB")
DbSetOrder(1)   //RCB_FILIAL+RCB_CODIGO

For nX := 1 to Len(aSR5toRCB)
	If DbSeek(xFilial("RCB") + aSR5toRCB[nX,05])
		While !Eof() .and. RCB_CODIGO == aSR5toRCB[nX,05]
			If AllTrim(UPPER(RCB_CAMPOS)) == aSR5toRCB[nX,04]
				aSR5toRCB[nX,07] := RCB_TAMAN
				aSR5toRCB[nX,11] := RCB_SHOWMA
				If !(aSR5toRCB[nX,05] $ "S001*S080*S003*S040")
					aSR5toRCB[nX,08] := RCB_ORDEM
				EndIf
				Exit
			EndIf
			DbSkip()
		EndDo
	EndIf
Next nX

aSort( aSR5toRCB ,,, { |x,y| x[5]+x[8] < y[5]+y[8] } )

RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetRxValue   ºAutor ³Leandro Drumond  º Data ³  20/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³carrega conteudo do SRX para RCC						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetRxValue(cCampo,cTab,cKeySRX,aSRX,cKeyRCC,nRet,cCpoIni)
Local aRet		:= {}
Local cRet		:= ""
Local cRetAux	:= ""
Local lRetStr	:= .T.
Local lTrunca	:= cTab $ "S001*S002*S036*S037*S040*S041*S070*S080"
Local nPosSR5	:= 0
Local nPosSRX	:= 0
Local nX		:= 0
Local nAux		:= 0

DEFAULT cCpoIni := ""

If lTrunca
	cKeySRX := SubStr(cKeySRX,1,Len(cKeySRX)-1)
EndIf

If !Empty(cCampo)
	nPosSR5 := aScan( aSR5toRCB , { |x| x[5]+AllTrim(x[4]) == cTab + cCampo } )
	If nPosSR5 > 0
		If cCampo == "FILIAL"
			cRet	:= SubStr(cKeySRX,1,TamSX3("RCC_FIL")[1])
		Else
			cRet 	:= SubStr(cKeySRX,aSR5toRCB[nPosSR5,02],aSR5toRCB[nPosSR5,03])
		EndIf
	EndIf
Else
	nPosSR5 := aScan( aSR5toRCB , { |x| x[5]+AllTrim(x[6]) == cTab + cKeyRCC } )
	nPosSRX := aScan( aSRX , { |x| x[1]+If(lTrunca,SubStr(x[2],1,Len(x[2])-1),x[2]) == If(cTab=="S038","S037",cTab) + cKeySRX } )
	For nX := nPosSR5 to Len(aSR5toRCB)

		If !Empty(cRet) .and. !Empty(cCpoIni) .and. cCpoIni == aSR5toRCB[nX,04]
			aAdd( aRet , cRet )
			cRet := ""
			lRetStr := .F.
		EndIf

		If aSR5toRCB[nX,05] <> cTab
			Exit
		EndIf
		nAux 	:= nPosSRX
		cRetAux	:= ""

		While .T.
			If empty( aSR5toRCB[nX,10]) .And. cTab $ "S038/S037"
				Exit
			EndIf
			If aSR5toRCB[nX,10] == aSRX[nAux,4]
				cRetAux += SubStr(aSRX[nAux,03],aSR5toRCB[nX,02],aSR5toRCB[nX,03])
				Exit
			EndIf

			nAux++
			If nAux > Len(aSRX) .or. aSRX[nAux,1] <> If(cTab=="S038","S037",cTab)
				Exit
			EndIf

			nRet := Max(nRet,nAux)
		EndDo

		cRet += If(Empty(cRetAux),Space(aSR5toRCB[nX,07]),PadR(cRetAux,aSR5toRCB[nX,07]))
	Next nX
	If !Empty(cRet) .and. !Empty(cCpoIni)
		aAdd( aRet , cRet )
		cRet := ""
	EndIf
EndIf

Return If(lRetStr,cRet,aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAjustAnoMes  ºAutor ³Leandro Drumond  º Data ³  20/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta AnoMes dos registros, executado em casos de IR,      º±±
±±º          ³por exemplo, que possuem duas tabelas no mesmo ano.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAjustAnoMes(aGrvRCC)
Local cTabela 	:= ""
Local cAMIniAnt	:= ""
Local cAMFimAnt	:= ""
Local nX		:= 0

For nX := 1 to Len(aGrvRCC)
	If !Empty(aGrvRCC[nX,7])
		If cTabela <> aGrvRCC[nX,2]
			cTabela 	:= aGrvRCC[nX,2]
			cAMIniAnt 	:= ""
			cAMIFimAnt	:= ""
			nPosAux		:= 0
		EndIf
		If Empty(cAMIniAnt)
			cAMIniAnt := aGrvRCC[nX,7]
			cAMFimAnt := aGrvRCC[nX,8]
			nPosAux++
		Else
			If cAMIniAnt + cAMFimAnt <> aGrvRCC[nX,7] + aGrvRCC[nX,8]
				If cAMFimAnt >= aGrvRCC[nX,7] .and. cAMIniAnt < aGrvRCC[nX,7]
					aGrvRCC[nX-1,8] := SubMesAno( aGrvRCC[nX,7]  )
					If cTabela $ "S001*S003"
						While nPosAux > 0
							aGrvRCC[nX-nPosAux,8] := SubMesAno( aGrvRCC[nX,7]  )
							nPosAux--
						EndDo
					EndIf
				Else
					If SubMesAno( aGrvRCC[nX,7]  ) > cAMFimAnt
						aGrvRCC[nX-1,8] := SubMesAno( aGrvRCC[nX,7]  )
						If cTabela $ "S001*S003"
							While nPosAux > 0
								aGrvRCC[nX-nPosAux,8] := SubMesAno( aGrvRCC[nX,7]  )
								nPosAux--
							EndDo
						EndIf
					EndIf
				EndIf
				nPosAux := 0
			EndIf
			nPosAux++
			cAMIniAnt := aGrvRCC[nX,7]
			cAMFimAnt := aGrvRCC[nX,8]
		EndIf
	EndIf
Next nX

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
If lTab22
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
									{0,0,235 ,400}					,;	//Coordenadas do Objeto
									NIL					,;  //
									NIL					,;	//
									oPanel				 ;	//Objeto Dialog
								)
	oMsSelect:oBrowse:lAllMark := .T.
	oMsSelect:oBrowse:bAllMark := bMarkAll
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
Local oPanelPar := TPanelCss():New(01,200,nil,oPanel,nil,nil,nil,nil,nil,195,210,nil,nil)
Local oPanelRod := TPanelCss():New(212,04,nil,oPanel,nil,nil,nil,nil,nil,391,22,nil,nil)
Local lTabSel	:= .T.
Local cMesDe		:= Space(2)
Local cMesAte		:= Space(2)
Local cAnoDe		:= Space(4)
Local cAnoAte		:= Space(4)
Local cMesPer		:= Space(2)
Local cAnoPer		:= Space(4)
Local oCheck1		:= Nil
Local oCheck2		:= Nil
Local oCheck3		:= Nil
Local oCheck4		:= Nil
Local oCheck5		:= Nil
Local oCheck6		:= Nil
Local oCheck7		:= Nil
Local oCheck8		:= Nil
Local oCheck9		:= Nil
Local dSRDDe 		:= STOD("")
Local dSRDAte 		:= STOD("")
Local dPerDem 		:= STOD("")

Private oChkTeste
Private oCheck2
Private oCheck3

aRetcoords := RetCoords(2,20,60,12,2,,,,{0,0,oPanelTab:oWnd:nTop*0.92,oPanelTab:oWnd:nLeft*0.88})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Marca os parametros que serao utilizados	                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*Painel Esquerda*/
TcheckBox():New(aRetcoords[01][1], aRetcoords[01][2],STR0058	,{|| lTab01 },oPanelTab, 300,10,,{|| lTab01:=!lTab01 },,,,,,.T.,,,)
TcheckBox():New(aRetcoords[03][1], aRetcoords[03][2],STR0040	,{|| lTab02 },oPanelTab, 300,10,,{|| lTab02:=!lTab02 },,,,,,.T.,,,)
TcheckBox():New(aRetcoords[05][1], aRetcoords[05][2],STR0042	,{|| lTab04 },oPanelTab, 300,10,,{|| lTab04:=!lTab04 },,,,,,.T.,,,)
TcheckBox():New(aRetcoords[07][1], aRetcoords[07][2],STR0044	,{|| lTab06 },oPanelTab, 060,10,,{|| lTab06:=!lTab06 },,,,,,.T.,,,)
TBitmap():New(aRetcoords[08][1]+1, aRetcoords[08][2],60,60,,"UPDINFORMATION17",.T.,oPanelTab, {|| fMsgInfCnv(.F.,STR0047,STR0044)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TcheckBox():New(aRetcoords[09][1], aRetcoords[09][2],STR0049	,{|| lTab11 },oPanelTab, 300,10,,{|| lTab11:=!lTab11 },,,,,,.T.,,,)
TcheckBox():New(aRetcoords[11][1], aRetcoords[11][2],STR0059	,{|| lTab18 },oPanelTab, 300,10,,{|| lTab18:=!lTab18 },,,,,,.T.,,,)
TcheckBox():New(aRetcoords[13][1], aRetcoords[13][2],STR0086	,{|| lTab19 },oPanelTab, 300,10,,{|| lTab19:=!lTab19 },,,,,,.T.,,,)
TcheckBox():New(aRetcoords[15][1], aRetcoords[15][2],STR0087	,{|| lTab20 },oPanelTab, 300,10,,{|| lTab20:=!lTab20 },,,,,,.T.,,,)
TcheckBox():New(aRetcoords[17][1], aRetcoords[17][2],STR0088	,{|| lTab21 },oPanelTab, 300,10,,{|| lTab21:=!lTab21 },,,,,,.T.,,,)
TcheckBox():New(aRetcoords[19][1], aRetcoords[19][2],STR0041	,{|| lTab03 },oPanelTab, 055,10,,{|| lTab03:=!lTab03 },,,,,,.T.,,,)
TBitmap():New(aRetcoords[20][1]+1, aRetcoords[20][2],60,60,,"UPDINFORMATION17",.T.,oPanelTab, {|| fMsgInfCnv(.F.,STR0040,STR0041)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TcheckBox():New(aRetcoords[21][1], aRetcoords[21][2],STR0043	,{|| lTab05 },oPanelTab, 300,10,,{|| lTab05:=!lTab05 },,,,,,.T.,,,)
TcheckBox():New(aRetcoords[23][1], aRetcoords[23][2],STR0055	,{|| lTab17 },oPanelTab, 055,10,,{|| lTab17:=!lTab17 },,,,,,.T.,,,)
TBitmap():New(aRetcoords[24][1]+1, aRetcoords[24][2],30,30,,"UPDINFORMATION17",.T.,oPanelTab, {|| fMsgInfCnv(.T.,STR0043 + "," + STR0049,STR0055)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TcheckBox():New(aRetcoords[25][1], aRetcoords[25][2],STR0052	,{|| lTab14 },oPanelTab, 055,10,,{|| lTab14:=!lTab14 },,,,,,.T.,,,)
TBitmap():New(aRetcoords[26][1]+1, aRetcoords[26][2],60,60,,"UPDINFORMATION17",.T.,oPanelTab, {|| fMsgInfCnv(.T.,STR0043,STR0052)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TcheckBox():New(aRetcoords[27][1], aRetcoords[27][2],STR0053	,{|| lTab15 },oPanelTab, 055,10,,{|| lTab15:=!lTab15 },,,,,,.T.,,,)
TBitmap():New(aRetcoords[28][1]+1, aRetcoords[28][2],30,30,,"UPDINFORMATION17",.T.,oPanelTab, {|| fMsgInfCnv(.T.,STR0043,STR0053)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TcheckBox():New(aRetcoords[29][1]+1, aRetcoords[29][2],STR0050,{|| lTab12  },oPanelTab, 300,10,,{|| lTab12:=!lTab12 },,,,,,.T.,,,) //Ferias
TcheckBox():New(aRetcoords[31][1]+1, aRetcoords[31][2],STR0045	,{|| lTab07 },oPanelTab, 105,10,,{|| lTab07:=!lTab07 },,,,,,.T.,,,)
TBitmap():New(aRetcoords[32][1]+1, aRetcoords[32][2]+50,60,60,,"UPDINFORMATION17",.T.,oPanelTab, {|| fMsgInfCnv(.F.,STR0041 + "," + STR0044 + "," + STR0050,STR0045)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)

/*Painel Direita*/

TcheckBox():New(005,008,STR0046,{|| lTab08  },oPanelPar, 125,10,,{|| lTab08:=!lTab08, oWizard:RefreshButtons(), lTab08 },,{|| ((If(!lTab08,(lPar05:=.F.),)),.T.)},,,,.T.,,,) //Dias de Direito
TBitmap():New(006,135,30,30,,"UPDINFORMATION17",.T.,oPanelPar, {|| fMsgInfCnv(.F.,STR0041 + "," + STR0044 + "," + STR0050,STR0046)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TcheckBox():New(015,015,STR0063,{|| lPar05  },oPanelPar, 100,10,,{|| lPar05:=!lPar05,oWizard:RefreshButtons(),lPar05 },,,,,,.T.,,,{||lTab08}) //"Converter Demitidos?"
TSay():New( 025 ,030,{||'Demitidos a partir de:'},oPanelPar,,,,,,.T.,,,100,10)
TGet():New( 035, 030, { | u | If( PCount() == 0, dPerDem, dPerDem := u ) },oPanelPar,060, 010, "@D",{|| dPerIniDem := dPerDem }, 0, 16777215,,.F.,,.T.,,.F.,{|| lPar05},.F.,.F.,,.F.,.F. ,,"dPerDem",,,,.T.)

TcheckBox():New(050,008,STR0051,{|| lTab13  },oPanelPar, 50,10,,{|| lTab13:=!lTab13, oWizard:RefreshButtons(), lTab13 },,{|| ((If(!lTab13,(lPar04:=.F.),)),.T.)},,,,.T.,,,) //Rescisao
TBitmap():New(051,55,30,30,,"UPDINFORMATION17",.T.,oPanelPar, {|| fMsgInfCnv(.T.,STR0043,STR0051)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TcheckBox():New(060,015,STR0062,{|| lPar04  },oPanelPar, 100,10,,{|| lPar04:=!lPar04 },,,,,,.T.,,,{||lTab13}) //"Exclui Movimento Aberto?"

TcheckBox():New(075, 008,STR0048	,{|| lTab10 },oPanelPar, 68,10,,{|| lTab10:=!lTab10 },,,,,,.T.,,,)
TBitmap():New(076,095,30,30,,"UPDINFORMATION17",.T.,oPanelPar, {|| fMsgInfCnv(.T.,STR0043,STR0048)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)

TcheckBox():New(090,008,STR0054 + " (SRC)",{|| lTab16  },oPanelPar, 80,10,,{|| lTab16:=!lTab16, oWizard:RefreshButtons(), lTab16 },,{|| ((If(!lTab16,(lPar01:=lPar02:=.F.),)),.T.)},,,,.T.,,,) //Movimento Mensal (SRC)
TBitmap():New(091,85,30,30,,"UPDINFORMATION17",.T.,oPanelPar, {|| fMsgInfCnv(.T.,STR0043,STR0054)},NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TcheckBox():New(100,015,STR0060,{|| lPar01  },oPanelPar, 300,10,,{|| lPar01:=!lPar01 },,,,,,.T.,,,{||lTab16}) //"Excluir Lançamentos?"
TcheckBox():New(110,015,STR0061,{|| lPar02  },oPanelPar, 300,10,,{|| lPar02:=!lPar02 },,,,,,.T.,,,{||lTab16}) //"Enviar lançamentos para RGB?"

oCheck5 := TcheckBox():New(125,008,STR0047 + " (SRD)",{|| lTab09 },oPanelPar, 100,10,,{|| lTab09:=!lTab09, oWizard:RefreshButtons(), lTab09 },,,,,,.T.,,,)
TBitmap():New(126, 110,30,30,,"UPDINFORMATION17",.T.,oPanelPar, {|| fMsgInfCnv(.F.,STR0044,STR0047) },NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TSay():New( 135 ,015,{||'Período De'},oPanelPar,,,,,,.T.,,,200,10)
TGet():New( 145, 015, { | u | If( PCount() == 0, dSRDDe, dSRDDe := u ) },oPanelPar,060, 010, "@D",{|| cDataDe := MESANO(dSRDDe)}, 0, 16777215,,.F.,,.T.,,.F.,{|| lTab09},.F.,.F.,,.F.,.F. ,,"dSRDDe",,,,.T.  )

TSay():New( 135 ,080,{||'Período Até'},oPanelPar,,,,,,.T.,,,100,10)
TGet():New( 145, 080, { | u | If( PCount() == 0, dSRDAte, dSRDAte := u ) },oPanelPar,060, 010, "@D",{|| If( Empty(dSRDDe).and.Empty(dSRDAte)  .OR.  !Empty(dSRDDe).and.!Empty(dSRDAte) .AND. dSRDAte >= dSRDDe,(cDataAte := MESANO(dSRDAte), .T.),(MsgInfo("Dados inválidos!" + CRLF + "Mês e ano final não podem ser menores que Mês e ano inicial. Para que todos os registros sejam convertidos, deixe todos os campos em branco."),.F.))}, 0, 16777215,,.F.,,.T.,,.F.,{|| lTab09},.F.,.F.,,.F.,.F. ,,"dSRDAte",,,,.T.  )

TcheckBox():New(160, 008,STR0064	,{|| lTab22 },oPanelPar, 80,10,,{|| lTab22:=!lTab22 },,,,,,.T.,,,)
TBitmap():New(161, 100,30,30,,"UPDINFORMATION17",.T.,oPanelPar, {|| fMsgInfCnv(.F.,STR0043 + ", " + STR0044 + ", " + STR0047 + " e " + STR0040 ,STR0064) },NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)

/*RODAPE*/

TcheckBox():New(005, 75,STR0089	,{|| lTabSel },oPanelRod, 100,10,,{|| fInverte(@lTabSel)},,,,,,.T.,,,)
TBitmap():New(006, 180,30,30,,"UPDINFORMATION17",.T.,oPanelRod, NIL,NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
TSay():New(006 ,200,{||STR0090},oPanelRod,,,,,,.T.,,,200,60)

Return

Function fInverte(lRet)

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
lRet   := !lRet

oWizard:RefreshButtons()

Return !lRet

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
	/*
	aadd(aMsgPend, "")
	aadd(aMsgPend, STR0005 + aParFil[nX][1] + " - " + STR0006 + aParFil[nX][2])
	*/
	if lTab03
	 	if !empty(cDtProc := fHistProc(cEmpProc,cFilProc,3)) .AND. RCM->(!EOF())
	 		aAdd(aMsgPend,STR0091 + STR0041 + STR0092 + cDtProc + STR0094 + RetSqlName("RCM")) //O processo Tipos de Ausência já foi executado em: 29/11/17, para continuar é necessário excluir a tabela RCMT10
	 	endIf
	 	if !lTab02 .AND. empty(fHistProc(cEmpProc,cFilProc,2))
	 		aAdd(aMsgPend,STR0091 + STR0041 + STR0095 + STR0040)
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

	if lTab22
		if !empty(cDtProc := fHistProc(cEmpProc,cFilProc,22))
			aAdd(aMsgPend,STR0091 + STR0064 + STR0092 + cDtProc + STR0093 + RetSqlName("SRD") + STR0096)
		endIf
		if (!lTab06 .AND. empty(fHistProc(cEmpProc,cFilProc,6))) .OR. (!lTab05 .AND. empty(fHistProc(cEmpProc,cFilProc,5))) .OR. (!lTab09 .AND. empty(fHistProc(cEmpProc,cFilProc,9))) .OR. (!lTab02 .AND. empty(fHistProc(cEmpProc,cFilProc,2)))
			aAdd(aMsgPend,STR0091 + STR0064 + STR0095 + STR0044 + "," + STR0043 + "," + STR0047 + " e " + STR0040)
		endIf
	endIf

next nX

if LEN(aMsgPend) > 0
	ShowLog(STR0003,aMsgPend)
	lRet := MSGYESNO(STR0097,STR0003)
endIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSrvDePara |Autor  ³ Leandro Drumond	    ³ Data ³ 26/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ De para dos campos INSS e INSSFER				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSrvDePara()
Local aRet := {}

aAdd(aRet,{"0073","0072",""})
aAdd(aRet,{"0076","0075",""})
aAdd(aRet,{"0078","0077",""})
aAdd(aRet,{"0083","0082",""})
aAdd(aRet,{"0085","0084",""})
aAdd(aRet,{"0160","0159",""})
aAdd(aRet,{"0205","0074",""})
aAdd(aRet,{"0206","0205",""})
aAdd(aRet,{"0344","0343",""})
aAdd(aRet,{"0346","0345",""})
aAdd(aRet,{"0633","0622",""})
aAdd(aRet,{"0634","0623",""})
aAdd(aRet,{"0635","0632",""})
aAdd(aRet,{"0637","0636",""})

Return aRet

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVldWiz    |Autor  ³ Leandro Drumond	    ³ Data ³ 30/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida wizard.									          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fVldWiz()

If oWizard:GetPanel() == 2 .and. !lPar06
	oWizard:SetPanel(4)
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvForm   |Autor  ³ Leandro Drumond	    ³ Data ³ 30/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao das formulas.					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvForm()
Local aArea 	:= GetArea()
Local aDePara	:= {}
Local cFilAux	:= xFilial("RC2")
Local cSeqAux	:= ""
Local cSeqPai	:= ""
Local cCodigo	:= ""
Local cNewCod	:= ""
Local cNumFor	:= "0000"
Local nX		:= 0
Local nRecRC2	:= 0
Local nRecAux	:= 0
Local lExistPai	:= .F.
Local lRotUsua	:= .T.

DbSelectArea("RC2")
DbSetOrder(1) //RC2_FILIAL+RC2_ORIGEM+RC2_CODIGO

DbSelectArea("RC3")
DbSetOrder(1) //RC3_FILIAL+RC3_ORIGEM+RC3_CODIGO+RC3_SEQFOR+RC3_SEQPAI

If RC2->(DbSeek(cFilAux + "U_"))
	While RC2->(!Eof() .and. RC2_FILIAL + RC2_ORIGEM == cFilAux + "U_")

		//Nao reprocessa se registro ja foi convertido
		If RC2->RC2_MODELO == "1" .and. Empty(RC2->RC2_RETURN)
			RC2->(DbSkip())
			Loop
		EndIf

		cNumFor := Soma1(cNumFor)

		cCodigo := RC2->RC2_CODIGO
		cNewCod	:= "UFOR" + cNumFor

		If nRecRC2 == 0
			nRecRC2 := RC2->(Recno())
			//Se existir ja converteu, portanto sai da conversao.
			If RC2->(DbSeek(cFilAux+"U_"+cNewCod))
				Exit
			Else
				RC2->(DbGoTo(nRecRC2))
			EndIf
		EndIf

		aAdd( aDePara, {cCodigo , cNewCod} )

		RC2->(DbSkip(-1))
		//Guarda recno anterior
		nRecAux := RC2->(Recno())
		RC2->(DbSkip())

		RecLock("RC2",.F.)
		RC2->RC2_MODELO := "1"
		RC2->RC2_CODIGO	:= cNewCod
		RC2->RC2_RETURN	:= ""
		RC2->(MsUnLock())

		cSeqAux := "000000"
		cSeqPai	:= "000000"
		lExistPai := .F.

		If RC3->(DbSeek(RC2->RC2_FILIAL + RC2->RC2_ORIGEM + cCodigo))
			While RC3->(!Eof() .and. RC3_FILIAL + RC3_ORIGEM + RC3_CODIGO == RC2->RC2_FILIAL + RC2->RC2_ORIGEM + cCodigo )

				If !Empty( RC3->RC3_SEQPAI )
					RC3->( dbSkip() )
					Loop
				EndIf

				cSeqAux := Soma1(cSeqAux)

				RecLock("RC3",.F.)

				If Empty(RC3->RC3_RESULT)
					RC3->RC3_DESCR	:= UPPER(RC3->(RC3_FORM01 + " " + RC3_OPERA2 + " " + RC3_FORM02))
				Else
					RC3->RC3_DESCR 	:= UPPER(RC3->RC3_RESULT)
				EndIf
				RC3->RC3_SEQFOR	:= cSeqAux
				RC3->RC3_CODIGO := cNewCod

				// Gravar as imagens //
				If RC3->RC3_TIPO == ".CON."
					RC3->RC3_RESOU1 := "PMSTASK1"
					RC3->RC3_RESOU2 := "PMSTASK1"
				ElseIf RC3->RC3_TIPO == ".EXE."
					RC3->RC3_RESOU1 := "PMSTASK4"
					RC3->RC3_RESOU2 := "PMSTASK4"
				Else
					RC3->RC3_RESOU1 := "PMSTASK3"
					RC3->RC3_RESOU2 := "PMSTASK3"
				EndIf

				// Gravacao do Pai //
				RC3->RC3_SEQPAI := cSeqPai

				If (!(RC3->RC3_TIPO == ".EXE." .and. RC3->RC3_OPERA3 == ".CNT.") .and. !lExistPai) .Or.;
				   (RC3->RC3_Tipo == ".CON." .and. RC3->RC3_Opera3 == ".END.")
					cSeqPai := RC3->RC3_SEQFOR
				EndIf

				If (RC3->RC3_TIPO == ".EXE." .and. RC3->RC3_OPERA3 == ".END.") .Or. ((RC3->RC3_TIPO == ".CON." .And. ( RC3->RC3_OPERA3 == ".AND." .Or. RC3->RC3_OPERA3 = ".OR." )) .And. !lExistPai)
					cSeqPai := Replicate( "0" , GetSx3Cache( "RC3_SEQFOR" , "X3_TAMANHO" ) )
				EndIf

				If !lExistPai .Or. (lExistPai .and. RC3->RC3_OPERA3 == ".END.")
					lExistPai := (RC3->RC3_TIPO == ".EXE." .and. RC3->RC3_OPERA3 == ".CNT.") .Or. (RC3->RC3_TIPO == ".CON." .and. RC3->RC3_OPERA3 == ".END.")
				EndIf

				RC3->( MsUnLock() )

				RC3->(DbSeek(RC2->RC2_FILIAL + RC2->RC2_ORIGEM + cCodigo))
			EndDo
		EndIf
		RC2->(DbGoTo(nRecAux))
		RC2->(DbSkip())
	EndDo
EndIf

If RC2->(DbSeek(cFilAux + "S_"))
	While RC2->(!Eof() .and. RC2_FILIAL + RC2_ORIGEM == cFilAux + "S_")
		If RC3->(DbSeek(RC2->RC2_FILIAL + RC2->RC2_ORIGEM + RC2->RC2_CODIGO))
			While RC3->(!Eof() .and. RC3_FILIAL + RC3_ORIGEM + RC3_CODIGO == RC2->RC2_FILIAL + RC2->RC2_ORIGEM + RC2->RC2_CODIGO )
				Reclock("RC3",.F.)
				RC3->(DbDelete())
				RC3->(MsUnLock())
				RC3->(DbSkip())
			EndDo
		EndIf
		Reclock("RC2",.F.)
		RC2->(DbDelete())
		RC2->(MsUnLock())
		RC2->(DbSkip())
	EndDo
EndIf

If !Empty(aDePara)
	aAdd(aTitle, "As seguintes formulas foram alteradas durante a conversao:" ) //"As seguintes formulas foram alteradas durante a conversao:"
	aAdd( aLogErr,{} )

	aAdd( aLogErr[Len(aLogErr)], "" )
	aAdd( aLogErr[Len(aLogErr)], Padr("Filial", 15) + Padr("Fórmula Antiga",35 ) + "Fórmula Nova" ) //"Filial" ####Fórmula Antiga###Fórmula Nova##
	For nX := 1 to Len(aDePara)
		aAdd( aLogErr[Len(aLogErr)], Padr(xFilial("RC2"),15) + Padr(aDePara[nX,01],35) + aDePara[nX,02] )
	Next nX
EndIf

DbSelectArea("SRM")
DbSetOrder(1)
If DbSeek(xFilial("SRM"))
	While SRM->(!Eof() .and. SRM->RM_FILIAL == xFilial("SRM"))
		If Mod(Val(SRM->RM_SEQ),2) <> 0
			If lRotUsua
				aAdd(aTitle, "As seguintes linhas customizadas do roteiro foram deletadas durante a conversão:" )
				aAdd( aLogErr,{} )

				aAdd( aLogErr[Len(aLogErr)], "" )
				aAdd( aLogErr[Len(aLogErr)], Padr("Filial", 15) + Padr("Roteiro",5 ) + Padr("Sequencia",8) + Padr("Descrição",50) )
				lRotUsua := .F.
			EndIf
			aAdd( aLogErr[Len(aLogErr)], Padr(xFilial("SRM"),15) + Padr(SRM->RM_CALCULO,5) + Padr(SRM->RM_SEQ,8) + Padr(SRM->RM_DESCRIC,50) )
		EndIf
		Reclock("SRM",.F.)
		SRM->(DbDelete())
		SRM->(MsUnLock())
		SRM->(DbSkip())
	EndDo
EndIf

DbSelectArea("SRY")
DbSetOrder(1)
If DbSeek(xFilial("SRY"))
	While SRY->(!Eof() .and. SRY->RY_FILIAL == xFilial("SRY"))
		Reclock("SRY",.F.)
		SRY->(DbDelete())
		SRY->(MsUnLock())
		SRY->(DbSkip())
	EndDo
EndIf

RestArea(aArea)

Return Nil

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
Local nRecAnt	:= 0
Local nX		:= 0

DbSelectArea("RCA")
DbSetOrder(1)
DbSeek(xFilial("RCA"))

While RCA->(!Eof() .and. RCA_FILIAL == xFilial("RCA"))
	cNewCod := ""

	If ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "M_PERCAUTO"
		cNewCod := "P_PERCAUTO"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CAVPROPPDE"
		cNewCod := "P_AVPROPDE"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "NANOAVIPRO"
		cNewCod := "P_ANOAVPRO"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CCAVISTRA"
		cNewCod := "P_CCAVITRA"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CCODPGIND"
		cNewCod := "P_CODPGIND"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CDESCMEDAV"
		cNewCod := "P_DESCMEDA"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CLIMAUXE15"
		cNewCod := "P_LIAUXE15"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "LMESATU"
		cNewCod := "P_LMESATU"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "NDRECALS"
		cNewCod := "P_NDRECALS"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "NTOTDIAS"
		cNewCod := "P_NTOTDIAS"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CPAGINDFD"
		cNewCod := "P_PAGINDFD"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CPAGRECES"
		cNewCod := "P_PAGRECES"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "NPERBCIR1"
		cNewCod := "P_PERBCIR1"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "NPERBCIR2"
		cNewCod := "P_PERBCIR2"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "LPGSALFEV"
		cNewCod := "P_PGSALFEV"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CPIDEM1SM"
		cNewCod := "P_PIDEM1SM"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CPIDEM2SM"
		cNewCod := "P_PIDEM2SM"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "LPROPCOMS"
		cNewCod := "P_PROPCOMS"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "LPROPCONTR"
		cNewCod := "P_PROPCONT"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "NSESTSENAT"
		cNewCod := "P_SESTSENA"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "LSOMAINC"
		cNewCod := "P_SOMAINC"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CTRANSPAD"
		cNewCod := "P_TRANSPAD"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "CTRANSPAP"
		cNewCod := "P_TRANSPAP"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "NVLLIMDIRF"
		cNewCod := "P_VLIMDIRF"
	ElseIf ALLTRIM(UPPER(RCA->RCA_MNEMON)) == "NVLLIMOUT"
		cNewCod := "P_VLLIMOUT"
	ElseIf SubStr(UPPER(RCA->RCA_MNEMON),1,2) == "M_"
		cNewCod := "P_" + SubStr(RCA->RCA_MNEMON,3,8)
		lMneUsu := .T.
	EndIf

	If !Empty(cNewCod)
		nRecRCA := RCA->(Recno())
		RCA->(DbSkip(-1))
		nRecAnt := RCA->(Recno())

		If !DbSeek(xFilial("RCA")+cNewCod)
			RCA->(DbGoTo(nRecRCA))

			aAdd( aDePara , { UPPER(RCA->RCA_MNEMON) , cNewCod } )

			RecLock("RCA",.F.)
			RCA->RCA_MNEMON := cNewCod
			RCA->(MsUnLock())
			RCA->(DbGoTo(nRecAnt))
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvRFJ    |Autor  ³ Leandro Drumond	    ³ Data ³ 02/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao da importação de variaveis.		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvRFJ()
Local aArea		:= GetArea()
Local cCodigo	:= ""
Local cDesc		:= ""
Local cAlias	:= ""
Local cCond		:= ""
Local nRecSRX	:= 0
Local lOk		:= .T.

DbSelectArea("RFJ")
DbSetOrder(1)

dbSelectArea("SRX")
dbSetOrder(1)

If SRX->(dbSeek( xFilial('SRX') + "02" + "COD" ))

	While SRX->(!Eof() .and. RX_FILIAL == xFilial('SRX') .and. RX_TIP == "02" .and. SubStr(RX_COD,1,3) == "COD" )

		cCodigo := SubStr(SRX->RX_COD,4,3)

		If SubStr(SRX->RX_COD,7,1) == "1"
			cDesc 	:= SubStr(SRX->RX_TXT,1,30)
			cAlias 	:= SubStr(SRX->RX_TXT,31,3)
		Else
			cCond	:= SubStr(SRX->RX_TXT,1,60)

			nRecSRX := SRX->(Recno())

			If SRX->(DbSeek(xFilial("SRX")+"02"+cCodigo))

				nOrdem := 0

				While SRX->(!Eof() .and. RX_FILIAL + RX_TIP == xFilial("SRX") + "02" .and. SubStr(RX_COD,1,3) == cCodigo )
					cCpoAux := SubStr(SRX->RX_COD,4,2)
					cPosIni	:= SubStr(SRX->RX_TXT,1,3)
					cPosFin	:= SubStr(SRX->RX_TXT,4,3)
					cForm	:= SubStr(SRX->RX_TXT,7,54)
					cCampo	:= ""
					lOk := .T.
					Do Case
						Case cCpoAux == "01"
							cCampo := "RGB_FILIAL"
						Case cCpoAux == "02"
							cCampo := "RGB_MAT"
						Case cCpoAux == "03"
							cCampo := "RGB_CC"
						Case cCpoAux == "04"
							cCampo := "RGB_PD"
						Case cCpoAux == "05"
							cCampo := "RGB_TIPO1"
						Case cCpoAux == "06"
							cCampo := "RGB_HORAS"
						Case cCpoAux == "07"
							cCampo := "RGB_VALOR"
						Case cCpoAux == "08"
							cCampo := "RGB_SEMANA"
						Case cCpoAux == "09"
							cCampo := "RGB_PARCEL"
						Case cCpoAux == "10"
							lOk := .F.
						Case cCpoAux == "11"
							cCampo := "RGB_DTREF"
					End Case

					If lOk
						nOrdem++

						If RFJ->(DbSeek(xFilial("RFJ")+cCodigo+"RGB"+cCampo))
							RecLock("RFJ",.F.)
						Else
							RecLock("RFJ",.T.)
						EndIf

						RFJ->RFJ_FILIAL	:= xFilial("RFJ")
						RFJ->RFJ_CODIGO	:= cCodigo
						RFJ->RFJ_DESC	:= cDesc
						RFJ->RFJ_TBDEST	:= "RGB"
						RFJ->RFJ_COND	:= cCond
						RFJ->RFJ_CPO	:= cCampo
						RFJ->RFJ_POSINI	:= Val(cPosIni)
						RFJ->RFJ_POSFIN	:= Val(cPosFin)
						RFJ->RFJ_FORM	:= cForm
						RFJ->RFJ_ORDEM	:= nOrdem

						RFJ->(MsUnLock())
					EndIf
					SRX->(DbSkip())
				EndDo
			EndIf
			SRX->(DbGoTo(nRecSRX))
		EndIf

		SRX->(dbSkip())
	EndDo
EndIf

RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ConvRG3    |Autor  ³ Leandro Drumond	    ³ Data ³ 22/07/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua conversao do Controle de Acesso			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Conversao                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvRG3()
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cQuery2	:= ""

RG3->( DbSelectArea("RG3") )

If RG3->( ColumnPos("RG3_PROCES")) > 0
	RG3->( DbSetOrder(1) )  // - Campo Processo incluso.
	cQuery := " UPDATE " + RetSqlName( "RG3" )
	cQuery += " 		SET RG3_ROTEIR = CASE WHEN RG3_TIPO = '1' THEN 'RES' ELSE 'FOL*AUT*ADI*FER*131*132' END, "
	cQuery += "		RG3_PROCES = CASE WHEN RG3_SEMANA <> '  ' THEN '00002' ELSE '00001' END "
	cQuery += " WHERE RG3_FILIAL = '" + xFilial( "RG3" ) + "' "

	//Query para alterar a semana apenas se já não existir registro igual na RG3, evitando chave duplicada.
	cQuery2 := " UPDATE " + RetSqlName( "RG3" )
	cQuery2 += " 		SET RG3_SEMANA = '01' "
	cQuery2 += " WHERE RG3_SEMANA = '' AND RG3_FILIAL = '" + xFilial("RG3") + "' AND RG3_PERIOD NOT IN ( SELECT RG3_PERIOD FROM " + RetSqlName( "RG3" ) + " S WHERE S.RG3_FILIAL = RG3_FILIAL AND S.RG3_PERIOD = RG3_PERIOD AND S.RG3_FIL = RG3_FIL AND S.RG3_EMP = RG3_EMP AND S.RG3_PROCES = RG3_PROCES AND S.RG3_SEMANA = '01' AND S.D_E_L_E_T_ = ' ' ) "

Else
	RG3->( DbSetOrder(1) )
	cQuery := " UPDATE " + RetSqlName( "RG3" )
	cQuery += " 		SET RG3_ROTEIR = CASE WHEN RG3_TIPO = '1' THEN 'RES' ELSE 'FOL*AUT*ADI*FER*131*132' END "
	cQuery += " WHERE RG3_FILIAL = '" + xFilial( "RG3" ) + "' "

	//Query para alterar a semana apenas se já não existir registro igual na RG3, evitando chave duplicada.
	cQuery2 := " UPDATE " + RetSqlName( "RG3" )
	cQuery2 += " 		SET RG3_SEMANA = '01' "
	cQuery2 += " WHERE RG3_SEMANA = '' AND RG3_FILIAL = '" + xFilial("RG3") + "' AND RG3_PERIOD NOT IN ( SELECT RG3_PERIOD FROM " + RetSqlName( "RG3" ) + " S WHERE S.RG3_FILIAL = RG3_FILIAL AND S.RG3_PERIOD = RG3_PERIOD AND S.RG3_FIL = RG3_FIL AND S.RG3_EMP = RG3_EMP AND S.RG3_SEMANA = '01' AND S.D_E_L_E_T_ = ' ') "
EndIf

If TCSQLEXEC(cQuery) != 0
	UserException( TCSqlError() )
Else
	If TCSQLEXEC(cQuery2) != 0
		UserException( TCSqlError() )
	EndIf
EndIf

RG3->( DbCloseArea() )
RestArea(aArea)

Return Nil

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fDelRCBRCC  ³ Autor ³ Leandro Drumond     ³ Data ³ 02/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui as tabelas que nao serao mais utilizadas.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPECONV                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fDelRCBRCC()
Local aArea		:= GetArea()
Local aTabelas	:= {"S005","S006","S007","S010"}
Local cFilAux	:= xFilial("RCB")
Local nX		:= 0

DbSelectArea("RCB")
DbSetOrder(1)

DbSelectArea("RCC")
DbSetOrder(1)

For nX := 1 to Len(aTabelas)
	If RCB->(DbSeek(cFilAux+aTabelas[nX]))
		While RCB->(!Eof() .and. RCB_FILIAL + RCB_CODIGO == cFilAux + aTabelas[nX])
			RecLock("RCB",.F.)
			RCB->(DbDelete())
			RCB->(MsUnLock())
			RCB->(DbSkip())
		EndDo
	EndIf

	If RCC->(DbSeek(cFilAux+aTabelas[nX]))
		While RCC->(!Eof() .and. RCC_FILIAL + RCC_CODIGO == cFilAux + aTabelas[nX])
			RecLock("RCC",.F.)
			RCC->(DbDelete())
			RCC->(MsUnLock())
			RCC->(DbSkip())
		EndDo
	EndIf
Next nX

RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fConvRFO    ³ Autor ³ Leandro Drumond     ³ Data ³ 03/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte parametro para RFO.						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPECONV                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fConvRFO()
Local aSRX		:= {}
Local cKeySR5	:= ""
Local cTab		:= "!!"
Local nRegSR5	:= 0
Local nPosDe	:= 0
Local nQuantos	:= 0

dbSelectArea("SR5")
SR5->(dbSetOrder(1))

dbSelectArea("SRX")
SRX->(dbSetOrder(1))

cTab := "!!"

If SRX->(dbSeek( xFilial('SRX') + "26" ))
	nRegSR5 := 0

	cKeySR5	:= RhTamFilial(xFilial('SR5')) + "X" + SRX->RX_TIP

	While SRX->(!Eof() .And. RX_FILIAL == xFilial('SRX') .And. RX_TIP == "26" )

		If !(cTab == SRX->RX_TIP)
			If !Empty(aSRX)
				fGrvRFO(aSRX)
			EndIf
			cTab := SRX->RX_TIP
			aSRX := {}
		EndIf

		nRegSR5++

		If !SR5->( dbSeek( cKeySR5 + StrZero(nRegSR5,2) ) ) .and. nRegSR5 > 1
			nRegSR5 := 1
			SR5->( dbSeek( cKeySR5 + StrZero(nRegSR5,2) ) )
		EndIf

		If nRegSR5 == 1
			aAdd(aSRX,{})
		EndIf

		While SR5->(!Eof() .And. R5_FILIAL + R5_ARQUIVO + R5_REG == cKeySR5 + StrZero(nRegSR5,2) )
			If Alltrim(SR5->R5_DEONDE) == "RX_TXT"
				If Empty(SR5->R5_POSICAO)
					SR5->(DbSkip())
					Loop
				EndIf
				nPosDe 	:= SR5->R5_DE
				nQuantos:= SR5->R5_QUANTOS
			Else
				If !Empty(Alltrim(SR5->R5_DEONDE)) .and. !(Alltrim(SR5->R5_DEONDE) $ "RX_FILIAL") .and. nRegSR5 == 1
					nPosDe 	:= SR5->R5_DE
					nQuantos:= SR5->R5_QUANTOS
					aAdd(aSRX[Len(aSRX)],(SubStr(SRX->RX_COD,nPosDe,nQuantos)))
				EndIf
				SR5->(DbSkip())
				Loop
			EndIf

			If SR5->R5_TIPO == "N"
				aAdd(aSRX[Len(aSRX)],Val(SubStr(SRX->RX_TXT,nPosDe,nQuantos)))
			Else
				aAdd(aSRX[Len(aSRX)],(SubStr(SRX->RX_TXT,nPosDe,nQuantos)))
			EndIf

			SR5->(DbSkip())
		EndDo

		SRX->(dbSkip())
	EndDo
EndIf

If !Empty(aSRX)
	fGrvRFO(aSRX)
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGrvRFO     ³ Autor ³ Leandro Drumond     ³ Data ³ 03/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava registro na RFO.							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPECONV                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGrvRFO(aSRX)

Local aArea 	:= GetArea()
Local cFilRFO	:= xFilial("RFO")
Local nX		:= 0

DbSelectArea("RFO")
DbSetOrder(1) //RFO_FILIAL+RFO_TPVALE+RFO_CODIGO

For nX := 1 to Len(aSRX)
	If Empty(aSRX[nX])
		Loop
	EndIf
	If !RFO->(DbSeek(cFilRFO+"1"+aSRX[nX,2]))
		RecLock("RFO",.T.)
		RFO_FILIAL 	:= cFilRFO
		RFO_TPVALE	:= "1"
		RFO_CODIGO 	:= aSRX[nX,2]
		RFO_DESCR   := aSRX[nX,3]
		RFO_VALOR	:= aSRX[nX,4]
		RFO_PERC	:= aSRX[nX,6]
		RFO_TETO	:= aSRX[nX,7]
		RFO_TPBEN	:= "02"
		MsUnLock()
	EndIf
Next nX

RestArea(aArea)

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
±±ºPrograma  ³fAjTabUs      ºAutor ³Emerson Campos   º Data ³  10/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta as tabelas de usuaários para apresentar mês e ano    ¹±±
±±ºDesc.     ³quando o campo RCB_SHOWMA esta em branco                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fAjTabUs()
Local aArea		:= GetArea()
Local nX			:= 0

DbSelectArea("RCB")
DbSetOrder(1)

While RCB->(!Eof())
	If Substr(RCB_CODIGO,1,1) == 'U' .and. Empty(RCB_SHOWMA)
		RecLock("RCB",.F.)
		RCB->RCB_SHOWMA := "S"
		RCB->(MsUnLock())
	EndIf
	RCB->(DbSkip())
EndDo

RestArea(aArea)

Return Nil

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
Local nX			:= 0

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

/*/{Protheus.doc} fBuscaFolmes()
- Função responsável por buscar o conteúdo do parâmetro MV_FOLMES na empresa corrente.
@author: Matheus Bizutti
@since:  21/06/2016
/*/
Static Function fBuscaFolmes()

Local cAnoMesAux := ''
Local aArea 	 := GetArea()

	OpenSxs(,,.F.,.F.,cEmpAnt,"SX6TMP","SX6")
	SX6TMP->( dbSelectArea("SX6TMP") )
	SX6TMP->( dbSetOrder(1) )

	If SX6TMP->( DbSeek(xFilial("SX6") + "MV_FOLMES") )
		cAnoMesAux := Alltrim(SX6TMP->X6_CONTEUD)
	EndIf

	SX6TMP->( dbCloseArea() )
	RestArea(aArea)

Return( cAnoMesAux )

/*/{Protheus.doc} fMovSemFun()
- Verifica se há registro na SRD sem funcionário Vinculado
@author: Paulo.Inzonha
@since:  21/11/2017
/*/
Static Function fMovSemFun(aLogPreCnv, cFilSRD)

Local lPrimeiro := .T.
Local cAliasTst := GetNextAlias()
Local lRet	:= .T.

BeginSql alias cAliasTst
	SELECT RD_FILIAL, RD_MAT, RD_PD, R_E_C_N_O_
	FROM %table:SRD% SRD
		WHERE NOT EXISTS(
		SELECT R_E_C_N_O_ FROM %table:SRA% SRA WHERE SRA.RA_MAT = SRD.RD_MAT AND SRA.RA_FILIAL = SRD.RD_FILIAL)
		AND RD_FILIAL = %exp:cFilSRD%
endSql

while ( (cAliasTst)->(!Eof()) )

	if(lPrimeiro)
		aAdd(aLogPreCnv,"")
		aAdd(aLogPreCnv,STR0099)
		lPrimeiro := .F.
		lRet := .F.
	endIf

	aAdd(aLogPreCnv,"RD_FILIAL: " + (cAliasTst)->RD_FILIAL + space(10) + "RD_MAT: " + (cAliasTst)->RD_MAT + space(10) +  "RD_PD: " + (cAliasTst)->RD_PD +   space(10) + "R_E_C_N_O_: " + STR((cAliasTst)->R_E_C_N_O_))
	(cAliasTst)->(dbSkip())
EndDo

(cAliasTst)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} fCodFolEmp()
- Carrega Array com Verbas da empresa
@author: Paulo.Inzonha
@since:  28/11/2017
/*/
Static Function fCodFolEmp(aSRV)

Local cAliasTst := GetNextAlias()

BeginSql alias cAliasTst
	SELECT RV_FILIAL,RV_CODFOL
	FROM %table:SRV% SRV
	WHERE RV_CODFOL in ('0040','0041','0042','0072','0103','0891','0927')
	AND SRV.%notDel%
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

/*/{Protheus.doc} fSRHDuplic()
- Verifica duplicidades na tabela SRH
@author: Paulo.Inzonha
@since:  18/01/2018
/*/
Static Function fSRHDuplic(aLogPreCnv,cFilSRH)

Local cAliasTst := GetNextAlias()
Local lRet 		:= .T.
Local lPrimeiro := .T.

BeginSql alias cAliasTst
	SELECT RH_FILIAL,RH_MAT, RH_DATABAS, RH_DTRECIB, COUNT(*) TOTAL
	FROM %table:SRH% SRH
	WHERE SRH.%notDel% AND RH_FILIAL = %exp:cFilSRH%
	GROUP BY RH_FILIAL,RH_MAT, RH_DATABAS, RH_DTRECIB
	HAVING COUNT(*) > 1
endSql

while ( (cAliasTst)->(!Eof()) )

	if(lPrimeiro)
		aAdd(aLogPreCnv,"")
		aAdd(aLogPreCnv,STR0109)
		lPrimeiro := .F.
		lRet := .F.
	endIf

	aAdd(aLogPreCnv,"RH_FILIAL: " + (cAliasTst)->RH_FILIAL + space(10) + "RH_MAT :" + (cAliasTst)->RH_MAT + space(10) + "RH_DTRECIB :" + (cAliasTst)->RH_DTRECIB)
	(cAliasTst)->(dbSkip())
EndDo

(cAliasTst)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} fVldVerb
Valida se as verbas de base foram selecionadas
@author gabriel.almeida
@since 19/08/2019
@version 1.0
/*/
Static Function fVldVerb(aColsSRV)
	Local lValidVerb := .T.
	Local nX         := 0
	Local nTamAcols  := Len(aColsSRV)

	For nX := 1 to nTamAcols
		If Empty(aColsSRV[nX,4])
			lValidVerb := .F.
			HELP(' ',1,STR0003 ,,STR0121,2,0,,,,,, {STR0122}) //Existem verbas que não serão criadas, pois no campo 'Mod. Verba' não foi selecionada a verba de base para o cadastro.

			Exit
		EndIf
	Next nX
Return lValidVerb

/*/{Protheus.doc} GpeConvSRF
Executa CONVSRF para o RHIMP15, proibição do uso de StaticCall
@author Leandro Drumond
@since 08/03/2022
@version 1.0
/*/
Function GpeConvSRF(aCodFol,cFiltro)

	ConvSRF(aCodFol,cFiltro)

Return

/*/{Protheus.doc} GpeConvPER
Executa CONVPER para o RHIMP15, proibição do uso de StaticCall
@author Leandro Drumond
@since 08/03/2022
@version 1.0
/*/
Function GpeConvPER()

	ConvPER()

Return
