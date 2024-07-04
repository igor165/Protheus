#include 'totvs.ch'
#include 'FWMVCDEF.CH'

#DEFINE ARQUIVO_LOG	"job_carrega_beneficiarios.log"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCARBEN

Funcao criada para chamar a carga de beneficiarios (BA1) para a central de obrigacoes (B3K)

@author TOTVS PLS Team
@since 26/01/2016.
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCARBEN()
	Local aSay		:= {}
	Local aButton	:= {}
	Local nOpc		:= 0
	Local Titulo	:= 'Importacao de Beneficiários'
	Local cDesc1	:= 'Esta rotina fará a importação de beneficiarios para o núcleo de informações '
	Local cDesc2	:= 'e obrigações.'
	Local cDesc3	:= ''
	Local cRegANS	:= "" //Codigo de registro da operadora
	Local cDatBloq	:= "" //Data limite de bloqueio dos beneficiarios a serem importados
	Local lGerRepas	:= .F. //Indica se gera T. ou nao .F. para beneficiario de repasse
	Local lCriticado:= .F. //Indica se importara .T. ou nao .F. registros criticados
	Local cTpData	:= "" //Indica o tipo de tratamento a ser dado para data de bloqueio 1=Ate a data,2=Apos a data
	Private _oProcCent	:= NIL

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 5, .T., { || nOpc := 5, Pergunte('PLSCARBEN',.T.,Titulo,.F.) } } )
	aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
	aAdd( aButton, { 2, .T., { || FechaBatch() } } )

	FormBatch( Titulo, aSay, aButton )

	If nOpc == 2

		cRegANS		:= mv_par01
		cDatBloq	:= Iif(!Empty(mv_par02),DTOS(mv_par02),"")
		lGerRepas	:= AllTrim(Str(mv_par03)) == '1'
		lCriticado	:= AllTrim(Str(mv_par04)) == '2'
		If ValType( mv_par05) == "N"
			cTpData	:= AllTrim(Str(mv_par05))
		EndIf

		If !Empty(cRegANS)
			_oProcCent := MsNewProcess():New({|| ImportaBeneficiarios(nOpc,cRegANS,cDatBloq,lGerRepas,lCriticado,cTpData) },"Importação de Beneficiários","Processando...",.F.)
			_oProcCent:Activate()
		Else
			MsgInfo("Para confirmar o processamento selecione a operadora.","TOTVS")
		EndIf

	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ImportaBeneficiarios

Funcao de importacao de beneficiarios do PLS para o NIO - B3K

@param nOpc			Opcao de processamento 4-Carga inicial, 5-Reimporta criticados
@param cRegANS		Numero de registro da operadora na ANS
@param cDatBloq		Data de bloqueio a partir da data informada
@param lGerRepas	Indica se devera considerar usuario de repasse
@param lCriticado	Indica se ira importar .T. somente os criticados ou nao .F.

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------

Function ImportaBeneficiarios(nOpc,cRegANS,cDatBloq,lGerRepas,lCriticado,cTpData, lAuto, nRecnoBA1)

	Local nArquivo	:= 0 //handle do arquivo/semaforo
	Local nRegua	:= 0 //Tamanho da regua
	Local nRegInc	:= 0 //Contador de registros incluidos
	Local nRegAlt	:= 0 //Contador de registros incluidos
	Local nRegPro	:= 0 //Contador de registros processados
	Local cWhere	:= ''

	Local lUsaSIB		:= "2" $ GetNewPar("MV_PLSTIPO","")
	Local lUsaSIP		:= "1" $ GetNewPar("MV_PLSTIPO","")
	Local lSIBSincrono	:= "2" $ GetNewPar("MV_PLOBRSI","1,2")
	Local lVldSibSin 	:= "2" $ GetNewPar("MV_PLVLDSI","2") .AND. lSIBSincrono
	Local lGrvCritic	:= GetNewPar("MV_PLGRCRI",.T.) //Indica se pode gravar o registro mesmo com críticas.
	Local lAltCancel	:= GetNewPar("MV_PLATCAN",.F.) //Indica se beneficiarios inativos enviarao retificacoes para a ANS

	Default nOpc		:= 2 //4-Importar carga incial; 5-Reimportar criticados
	Default cRegANS		:= "" //Codigo de registro da operadora
	Default cDatBloq	:= "" //Data limite de bloqueio dos beneficiarios a serem importados
	Default lGerRepas	:= .F. //Indica se gera T. ou nao .F. para beneficiario de repasse
	Default lCriticado	:= .F. //Indica se importara .T. ou nao .F. registros criticados
	Default cTpData		:= ""
	Default lAuto       := .F. //Para rodar a função na automação de testes sem chamar funções inadequadas
	Default nRecnoBA1   := 0

	PlsLogFil(CENDTHRL("I") + " Inicio PLSCARBEN",ARQUIVO_LOG)

	nArquivo := Semaforo('A',0)

	//Se abriu o semaforo e carregou os beneficiarios do PLS
	If nArquivo > 0 .AND. CarregaBeneficiarios(nOpc,cRegANS,cDatBloq,lGerRepas,lCriticado,@cWhere,cTpData,.T.   , @nRegua, nRecnoBA1) ;
			.AND. CarregaBeneficiarios(nOpc,cRegANS,cDatBloq,lGerRepas,lCriticado,@cWhere,cTpData,.F. ,,nRecnoBA1)

		If !lAuto
			if(nRegua/250 > 1)
				_oProcCent:SetRegua1(Round(nRegua/250,0) + 1)
			else
				_oProcCent:SetRegua1(nRegua)
			endif
		EndIf

		If !lAuto
			sleep(3000)
		EndIf

		TRBBEN->(DbGoTop())

		If !lAuto
			_oProcCent:IncRegua1("Importando " + alltrim(str(nRegua)) + " beneficiarios...")
		EndIf

		PlsLogFil(CENDTHRL("I") + " Importando ",ARQUIVO_LOG)

		While !TRBBEN->(Eof())

			nRegPro++
			If !lAuto
				AtualizaRegua(@nRegPro,nRegua)
			EndIF

			If PlSibEnvANS(TRBBEN->BA3_TIPOUS,TRBBEN->BA1_CODINT,TRBBEN->BA1_CODEMP,TRBBEN->BA1_CONEMP,TRBBEN->BA1_VERCON,TRBBEN->BA1_SUBCON,TRBBEN->BA1_VERSUB,TRBBEN->BA1_INFANS)

				IncluiBenef(@nRegInc,@nRegAlt,lUsaSIB,lUsaSIP,lSIBSincrono,lVldSibSin,lGrvCritic,lAltCancel)
				DelClassInf()

			Else
				PlsLogFil(CENDTHRL("W") + " Beneficiario configurado para nao ser enviado para a ANS. Matricula: " + TRBBEN->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),ARQUIVO_LOG)
			EndIf

			TRBBEN->(dbSkip())

		EndDo

	Else
		PlsLogFil(CENDTHRL("I") + " Nao foram encontrados dados de beneficiarios para importar ",ARQUIVO_LOG)
	EndIf

	If nArquivo > 0
		TRBBEN->(dbCloseArea())
	EndIf
	//Fecha semaforo
	nArquivo := Semaforo('F',nArquivo)

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLSCARBEN: " + AllTrim(Str(nRegInc)) + " beneficiarios " + Iif(lCriticado,"alterados","incluidos"),ARQUIVO_LOG)
	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Termino PLSCARBEN. Total Reg. Proc.: " + Alltrim(str(nRegPro)),ARQUIVO_LOG)

	If !lAuto
		MsgInfo("Processamento concluido." + Chr(13) + Chr(10) + AllTrim(Str(nRegInc)) + " beneficiarios incluidos" + " e " + AllTrim(Str(nRegAlt)) + " beneficiarios alterados de " +  AllTrim(Str(nRegPro)) + " processados.")
	EndIf

Return

Static Function IncluiBenef(nRegInc,nRegAlt,lUsaSIB,lUsaSIP,lSIBSincrono,lVldSibSin,lGrvCritic,lAltCancel)
	Local aDadCob	:= {}
	Local nOpc
	Local oModel

	Default lUsaSIP	:= .F.

	oModel 	:= Pl260DadNio('4',nil,0,"TRBBEN",aDadCob,.F.,.F., ,lUsaSIP)
	nOpc 	:= oModel:GetOperation()

	If nOpc == MODEL_OPERATION_INSERT //!ExisteBeneficiario()

		nRegInc++

	Else

		nRegAlt++

	EndIf

	oModel:commitData(.F.)
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Semaforo

Funcao criada para abrir e fechar semaforo em arquivo

@param cOpcao		A-abrir; F-Fechar
@param nArquivo	Handle do arquivo no disco

@return nArquivo	Handle do arquivo criado o zero quando fechar

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function Semaforo(cOpcao,nArquivo)
	Local cArquivo		:= 'job_beneficiarios.smf'
	Default nArquivo	:= 0
	Default cOpcao		:= 'A'

	Do Case

		Case cOpcao == 'A' //Vou criar/abrir o semaforo/arquivo

			nArquivo := FCreate(cArquivo)

		Case cOpcao == 'F' //Vou apagar/fechar o semaforo/arquivo

			If FClose(nArquivo)
				nArquivo := 0
			EndIf

	EndCase

Return nArquivo

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaBeneficiarios

Funcao cria a area de trabalho TRBBEN com as informacoes de todos os beneficarios (BA1)

@param nOpc			4-Importar carga incial; 5-Reimportar criticados
@param cRegANS		Numero de registro da operadora na ANS
@param cDatBloq	Data inicial para considerar beneficiarios bloqueados
@param lGerRepas	Indica se devera considerar .T. ou nao .F. beneficiarios de repasse
@param lCriticado	Indica se devera considerar .T. ou nao .F. beneficiarios criticados
@param cWhere

@return lRetorno	Indica se foi .T. ou nao .F. encontrado beneficiario no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaBeneficiarios(nOpc,cRegANS,cDatBloq,lGerRepas,lCriticado,cWhere,cTpData,lCount, nQtd, nRecnoBA1)
	Local cSql			:= ''
	Local lRetorno		:= .F.
	Local cLisReps		:= GetNewPar("MV_PLSGEIN ","0050")
	Default nOpc		:= 4
	Default cRegANS		:= "000000"
	Default cDatBloq	:= ""
	Default cWhere		:= ""
	Default lGerRepas	:= .F.
	Default lCriticado	:= .F.
	Default cTpData		:= "1"//1=Ate a data,2=Apos a data
	Default lCount		:= .F.
	Default nQtd		:= 0
	Default nRecnoBA1	:= 0

	cSql := "SELECT "
	If lCount
		cSql += " Count(1) QTD"
	Else
		cSql += " BA1_CODINT, BA1_CODEMP,BA1_CONEMP,BA1_VERCON,BA1_SUBCON,BA1_VERSUB, BA1_MATRIC,BA1_MATANT, BA1_TIPREG, BA1_DIGITO, BA1_CODCCO, BA1_DATNAS, BA1_DATINC, "
		cSql += " BA1_DATBLO, BA3_DATBLO, BA1_ESTADO, BA3_ESTADO, BA1_CODPLA, BA1_VERSAO, BA1_SEXO, BA3_CODPLA," + IIf(BA3->(FieldPos("BA3_GRPFAM")) > 0,"BA3_GRPFAM, " , " ")
		cSql += " BA3_VERSAO, BA1_DATCAR, BA1_PLPOR, BA1_NOMUSR, BA1_OPEORI, BA1_CPFUSR, BA1_MAE, BA1_ENDERE, "
		cSql += " BA1_CEPUSR, BA1_TRADES, BA1_TRAORI, BA1_MUNICI, BA1_ESTADO, BA1_NR_END, BA1_COMEND, BA1_BAIRRO, BA1_CODMUN, "
		cSql += Iif(BA1->(FieldPos('BA1_TIPEND')) > 0,'BA1_TIPEND, BA1_RESEXT, BA1_MUNRES, ',' ')
		cSql += Iif(BA1->(FieldPos('BA1_CRINOM')) > 0,'BA1_CRINOM, BA1_CRIMAE, ',' ')
		cSql += " BA1_CPFPRE, BA1_CPFMAE, BA1_GRAUPA, BA1_TIPUSU, BA1_LOCSIB, BA3_PLPOR, BA3_TIPOUS, "
		cSql += " BTS_PISPAS, BTS_NRCRNA, BTS_DENAVI, BA1_LOCSIB,BA3_CODCLI,BA3_LOJA,BA1_EXCANS,BA1_MOTBLO,BA1_INFANS,BA1_MATVID,"
		cSql += " BA3_CODINT,BA3_CODEMP,BA3_MATRIC,BA3_CONEMP,BA3_VERCON,BA3_SUBCON,BA3_VERSUB,BA1_PISPAS"
	EndIf

	If lCriticado //re-importacao de beneficiarios criticados
		cWhere := " FROM " + RetSqlName('BA1') + " BA1, " + RetSqlName('BA3') + " BA3, " + RetSqlName('BG9') + " BG9, " + RetSqlName("B3K") + " B3K, " + RetSqlName('BTS') + " BTS "
		cWhere += " WHERE BA1_FILIAL = '" + xFilial('BA1') + "' AND BA3_FILIAL = '" + xFilial('BA3') + "' AND BG9_FILIAL = '" + xFilial('BG9') + "' AND B3K_FILIAL = '" + xFilial("B3K") + "' AND BTS_FILIAL = '" + xFilial("BTS") + "' "
		cWhere += " AND BA1_CODINT = BA3_CODINT "
		cWhere += " AND BA1_CODEMP = BA3_CODEMP "
		cWhere += " AND BA1_MATRIC = BA3_MATRIC "
		cWhere += " AND BA1_CODINT = BG9_CODINT "
		cWhere += " AND BA1_CODEMP = BG9_CODIGO "
		cWhere += " AND BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO = B3K_MATRIC "
		cWhere += " AND BA1_DATINC = B3K_DATINC "	// Sistema passou a permitir 2 CCO com mesma matricula, a diferença está no _DATINC
		cWhere += " AND BA1_INFANS <> '0' "
		cWhere += " AND (B3K_STATUS = '3' OR B3K_STASIB = '3' OR B3K_STAESP = '3') "
		cWhere += " AND BA1_MATVID = BTS_MATVID "
		If !lGerRepas
			cWhere += "AND BG9_CODIGO NOT IN ('" + StrTran(cLisReps,",","','") + "') "
		EndIf
		If !Empty(cDatBloq)
			cWhere += " AND ( BA1_DATBLO = '' OR BA1_DATBLO " + Iif(cTpData=='1','<=','>=') + " '" + cDatBloq + "') "
		EndIf
		cWhere += " AND BA1.D_E_L_E_T_ = ' ' "
		cWhere += " AND BA3.D_E_L_E_T_ = ' ' "
		cWhere += " AND BG9.D_E_L_E_T_ = ' ' "
		cWhere += " AND B3K.D_E_L_E_T_ = ' ' "
		cWhere += " AND BTS.D_E_L_E_T_ = ' ' "

	Else
		cWhere := " FROM " + RetSqlName('BA1') + " BA1, " + RetSqlName('BA3') + " BA3, " + RetSqlName('BG9') + " BG9, " + RetSqlName('BTS') + " BTS "
		cWhere += " WHERE BA1_FILIAL = '" + xFilial('BA1') + "' AND BA3_FILIAL = '" + xFilial('BA3') + "' AND BG9_FILIAL = '" + xFilial('BG9') + "' "
		cWhere += " AND BTS_FILIAL = '" + xFilial("BTS") + "' "
		cWhere += " AND BA1_MATVID = BTS_MATVID "
		cWhere += " AND BA1_CODINT = BA3_CODINT "
		cWhere += " AND BA1_CODEMP = BA3_CODEMP "
		cWhere += " AND BA1_MATRIC = BA3_MATRIC "
		cWhere += " AND BA1_CODINT = BG9_CODINT "
		cWhere += " AND BA1_CODEMP = BG9_CODIGO "
		cWhere += " AND BA1_INFANS <> '0' "
		cWhere += " AND BA1.D_E_L_E_T_ = ' ' "
		cWhere += " AND BA3.D_E_L_E_T_ = ' ' "
		cWhere += " AND BG9.D_E_L_E_T_ = ' ' "
		cWhere += " AND BTS.D_E_L_E_T_ = ' ' "

		If !lGerRepas
			cWhere += "AND BG9_CODIGO NOT IN ('" + StrTran(cLisReps,",","','") + "') "
		EndIf
		If !Empty(cDatBloq)
			cWhere += "AND ( BA1_DATBLO = '' OR BA1_DATBLO " + Iif(cTpData=='1','<=','>=') + " '" + cDatBloq + "') "
		EndIf

		If nRecnoBA1 > 0
			cWhere += " AND BA1.R_E_C_N_O_ = " + Alltrim(Str(nRecnoBA1)) + " "
		EndIf

		cWhere += " AND BA1.D_E_L_E_T_ = ' ' AND BA3.D_E_L_E_T_ = ' ' AND BG9.D_E_L_E_T_ = ' ' AND BTS.D_E_L_E_T_ = ' '"
	EndIf

	cSql := ChangeQuery(cSql+cWhere)
	If lCount
		cTexto := "Contando"
	Else
		cTexto := "Selecionando"
	EndIf

	If Select("TRBBEN") > 0
		TRBBEN->(DBCloseArea())
	EndIf

	PlsLogFil(CENDTHRL("I") + " " + cTexto + " Beneficiarios: " + cSql,ARQUIVO_LOG)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBEN",.F.,.T.)
	PlsLogFil(CENDTHRL("I") + " Fim da query",ARQUIVO_LOG)

	If TRBBEN->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
		If lCount
			nQtd := TRBBEN->QTD
			PlsLogFil(CENDTHRL("I") + Alltrim(Str(nQtd)) + " beneficiarios selecionados.",ARQUIVO_LOG)
		EndIf
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlSibEnvANS

Verifica se o beneficiario pode ser enviado para a ANS SIB ou SIP
Verifica os campos do Contrato, Subcontrato e Beneficiário.

@param cTipo		1-Pessoa Fisica, senao juridica
@param cInt			Codigo da operadora
@param cEmp			Codigo da empresa
@param cConEmp		Numero do contrato
@param cVerCon		Versao do contrato
@param cSubCon		Numero do subcontrato
@param cVerSub		Versao do subcontrato
@param cInfSIB		Para PF 1 = informa beneficiario para ANS

@return lRet	Retorna .T. se envia para a ANS senao retorna .F.

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlSibEnvANS(cTipo,cInt,cEmp,cConEmp,cVerCon,cSubCon,cVerSub,cInfSIB)
	Local lEnvANS		:= .F.
	Local cSql			:= ""
	Default cInfSIB := "1"

	lBenEnvANS := cInfSIB == '1'

	If lBenEnvANS

		lEnvANS := .T.

		If cTipo == '2' //Pessoa Física

			cSql := "SELECT "
			cSql += " BT5_INFANS,"
			cSql += " BQC_INFANS "
			cSql += " FROM " + RetSqlName('BT5') + " BT5 "
			cSql += " , " + RetSqlName('BQC') + " BQC "
			cSql += " WHERE "
			cSql += " BT5_FILIAL = '" + xFilial('BT5') + "' "
			cSql += " AND BT5_CODINT = '" + cInt + "' "
			cSql += " AND BT5_CODIGO = '" + cEmp + "' "
			cSql += " AND BT5_NUMCON = '" + cConEmp + "' "
			cSql += " AND BT5_VERSAO = '" + cVerCon + "' "
			cSql += " AND BQC_FILIAL = '" + xFilial('BQC') + "' "
			cSql += " AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
			cSql += " AND BQC_NUMCON = BT5_NUMCON "
			cSql += " AND BQC_VERCON = BT5_VERSAO "
			cSql += " AND BQC_SUBCON = '" + cSubCon + "' "
			cSql += " AND BQC_VERSUB = '" + cVerSub + "' "
			cSql += " AND BT5.D_E_L_E_T_ = ' '"
			cSql += " AND BQC.D_E_L_E_T_ = ' '"

			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBT",.F.,.T.)

			If !TRBT->(Eof())
				lEnvANS := TRBT->BT5_INFANS == '1' .AND. TRBT->BQC_INFANS == '1'
			Else
				lEnvANS := .T.
			EndIf

			TRBT->(dbCloseArea())
		EndIf

	EndIf

Return lEnvANS

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaRegua

Funcao atualiza a regua de progresso de registros processados

@param nRegPro		Quantidade de registros processados
@param nRegua		Tamanho da regua de processamento

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function AtualizaRegua(nRegPro,nRegua)
	Default nRegua	:= 0
	Default nRegPro	:= 0

	If nRegPro == 1 .OR. (nRegPro % 250) == 0
		_oProcCent:IncRegua1(AllTrim(Str(nRegPro)) +"/"+ AllTrim(Str(nRegua)) + " beneficiarios processados ")
		PlsLogFil(CENDTHRL("I") + " PLSCARBEN: " + AllTrim( Str(nRegPro) ) + " beneficiarios processados " , ARQUIVO_LOG)
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaPergunta

Funcao criada para verificar se as perguntas obrigatorias foram respondidas

@return lRet	Verdadeiro (.T.) se as perguntas foram respondidas, senao Falso (.F.)

@author timoteo.bega
@since 03/06/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ValidaPergunta()
	Local lRet	:= .T.
	Local cMsg	:= ""

	If Empty(mv_par01)
		lRet := .F.
		cMsg += "Qual a operadora padrao ?" + CRLF
	EndIf

	If !lRet
		MsgInfo("Os seguintes parametros nao foram respondidos: " + CRLF + CRLF + cMsg ,"TOTVS")
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CargaBCAB4W

Atualiza o historico de bloqueio da Central

@author everton.mateus
@since 26/05/2017
/*/
//--------------------------------------------------------------------------------------------------
Function CargaBCAB4W(cMatric)
	local lStrTPLS	:= FindFunction("StrTPLS")

	Default cMatric := ""

	//Procuro a critica
	If BCA->( MsSeek(xFilial("BCA") ))
		Do While !BCA->( Eof() ) .AND.  BCA->BCA_FILIAL == Xfilial("BCA")

			If !lStrTPLS
				cMatric := BCA->(BCA_MATRIC+BCA_TIPREG)+Modulo11(BCA->(BCA_MATRIC+BCA_TIPREG))
			Else
				cMatric := BCA->(BCA_MATRIC+BCA_TIPREG)+Modulo11(StrTPLS(BCA->(BCA_MATRIC+BCA_TIPREG)))
			EndIf

			B4W->(DbSetOrder(1))//B4W_FILIAL+B4W_MATRIC+DTOS(B4W_DATA)+B4W_TIPO
			If !B4W->(MsSeek(xFilial("B4W")+cMatric+DTOS(BCA->BCA_DATA)+BCA->BCA_TIPO))

				Reclock("B4W",.T.)
				B4W->B4W_FILIAL	:= xFilial("B4W")
				B4W->B4W_MATRIC	:= cMatric
				B4W->B4W_TIPO 	:= BCA->BCA_TIPO
				B4W->B4W_DATA		:= BCA->BCA_DATA
				B4W->B4W_STATUS	:= "1"
				If BCA->BCA_TIPO =='0'
					B4W->B4W_MOTBLO	:= PlMotBloANS("U",BCA->BCA_MOTBLO)
				EndIf
				B4W->(MsUnlock())
			EndIf
			BCA->(DbSkip())
		EndDo
	EndIf
Return