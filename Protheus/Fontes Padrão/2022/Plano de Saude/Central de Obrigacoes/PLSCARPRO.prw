#include 'protheus.ch'
#include 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCARBEN

Funcao criada para carregar os produtos (BI3) para a central de obrigacoes (B3J)

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCARPRO()
	Local aSay     := {}
	Local aButton  := {}
	Local nOpc     := 0
	Local Titulo   := 'Importacao de Produtos / Planos'
	Local cDesc1   := 'Esta rotina fará a importação de produtos ou planos para o núcleo de informações '
	Local cDesc2   := 'e obrigações.'
	Local cDesc3   := ''
	Local lOk      := .T.

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	//aAdd( aButton, { 5, .T., { || nOpc := 5, Pergunte('PLSCARPRO',.T.,Titulo,.F.) } } )
	aAdd( aButton, { 1, .T., { || nOpc := 2,  FechaBatch() } } )
	aAdd( aButton, { 2, .T., { || FechaBatch()            } } )

	FormBatch( Titulo, aSay, aButton )

	If nOpc == 2

		Processa( { || lOk := ImportaProdutos() },'Aguarde','Processando...',.F.)

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ImportaBeneficiarios

Funcao de importacao de produtos do PLS para o NIO - B3J

@param nOpc		Opcao de processamento 4-Carga inicial, 5-Reimporta criticados

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function ImportaProdutos(nOpc,lMsg)
	Local nArquivo	:= 0   //handle do arquivo/semaforo
	Local nRegua	:= 0   //Tamanho da regua
	Local nRegInc	:= 0   //Contador de registros incluidos
	Local nRegAlt   := 0   //Contador de registros Alterados
	Local nRegPro	:= 0   //Contador de registros processados
	Default lMsg    := .T. //Indica se deve apresentar msg na tela
	Default nOpc	:= 1   //1-Importar carga incial; 2-Reimportar criticados

	//abrir semaforo
	nArquivo := Semaforo('A',0)

	//Inicializa tamanho da regua
	nRegua := Regua()
	ProcRegua(nRegua)
	IncProc("Consultando produtos / planos a serem processados...")

	//Se abriu o semaforo e carregou os produtos do PLS
	If nArquivo > 0 .And. CarregaProdutos(nOpc)

		While !TRBPRO->(Eof())

			nRegPro++
			AtualizaRegua(nRegPro,nRegua)

			If nOpc == 1 .And. !ExisteProduto()

				If IncluiProduto(MODEL_OPERATION_INSERT)
					nRegInc++
				EndIf

			Else //nOpc == 2

				If IncluiProduto(MODEL_OPERATION_UPDATE)
					nRegAlt++
				EndIf

			EndIf

			TRBPRO->(dbSkip())

		EndDo

		If CarregaAbrangencias(nOpc)

			While !TRBABR->(Eof())

				If ExisteAbrangencia()
					IncluiAbrangencia(MODEL_OPERATION_UPDATE)
				Else
					IncluiAbrangencia(MODEL_OPERATION_INSERT)
				EndIf

				TRBABR->(dbSkip())

			EndDo

			TRBABR->(dbCloseArea())

		EndIf

		If CarregaSegmentos(nOpc)

			While !TRBSEG->(Eof())

				If ExisteSegmento()
					IncluiSegmento(MODEL_OPERATION_UPDATE)
				Else
					IncluiSegmento(MODEL_OPERATION_INSERT)
				EndIf

				TRBSEG->(dbSkip())

			EndDo

			TRBSEG->(dbCloseArea())

		EndIf

		TRBPRO->(dbCloseArea())

	EndIf

	//Fecha semaforo
	nArquivo := Semaforo('F',nArquivo)

	If lMsg
		MsgInfo("Processamento concluido." + Chr(13) + Chr(10) + AllTrim(Str(nRegInc)) + " produtos / planos incluído(s),  " + AllTrim(Str(nRegAlt)) + " alterado(s).")
	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Semaforo

Funcao criada para abrir e fechar semaforo em arquivo

@param cOpcao		A-abrir, F-Fechar
@param nArquivo Handle do arquivo no disco

@return nArquivo	Handle do arquivo criado o zero quando fechar

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function Semaforo(cOpcao,nArquivo)
	Local cArquivo		:= 'job_produtos.smf'
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
/*/{Protheus.doc} CarregaProdutos

Funcao cria a area de trabalho TRBPRO com as informacoes de todos os produtos (BI3)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaProdutos(nOpc)
	Local cSql	:= ''
	Local lRet	:= .F.
	Default nOpc	:= 1

	cSql += "SELECT BI3_CODINT, BI3_CODIGO, BI3_DESCRI, BI3_VERSAO, BI3_ABRANG, BA0_SUSEP, BII_TIPPLA, BI6_SEGSIP, BI6_PERDES, BF7_CODORI, BF7_PERDES "

	If nOpc == 1
		cSql += "FROM " + RetSqlName("BI3") + " BI3, " + RetSqlName('BA0') + " BA0, " + RetSqlName('BII') + " BII, " + RetSqlName('BI6') + " BI6, "
		cSql += RetSqlName('BF7') + " BF7 "
		cSql += "WHERE BI3_FILIAL = '" + xFilial('BI3') + "' "
		cSql += "AND BA0_FILIAL = '" + xFilial('BA0') + "' "
		cSql += "AND BII_FILIAL = '" + xFilial('BII') + "' "
		cSql += "AND BI6_FILIAL = '" + xFilial('BI6') + "' "
		cSql += "AND BF7_FILIAL = '" + xFilial('BF7') + "' "
		cSql += "AND BI3_CODINT = BA0_CODIDE||BA0_CODINT "
		cSql += "AND BI3_TIPCON = BII_CODIGO "
		cSql += "AND BI3_CODSEG = BI6_CODSEG "
		cSql += "AND BI3_ABRANG = BF7_CODORI "
		cSql += "AND BII_TIPPLA <> ' '
		cSql += "AND BI6_SEGSIP <> ' '
		cSql += "AND BI3_INFANS <> '0' "
		cSql += "AND BI3.D_E_L_E_T_ = ' ' "
		cSql += "AND BA0.D_E_L_E_T_ = ' ' "
		cSql += "AND BII.D_E_L_E_T_ = ' ' "
		cSql += "AND BI6.D_E_L_E_T_ = ' ' "
		cSql += "AND BF7.D_E_L_E_T_ = ' ' "
	Else
		cSql += "FROM " + RetSqlName("BI3") + " BI3, " + RetSqlName('BA0') + " BA0, " + RetSqlName('BII') + " BII, " + RetSqlName('BI6') + " BI6, "
		cSql += RetSqlName('B3J') + " B3J, " + RetSqlName('BF7') + " BF7 "
		cSql += "WHERE BI3_FILIAL = '" + xFilial('BI3') + "' "
		cSql += "AND BA0_FILIAL = '" + xFilial('BA0') + "' "
		cSql += "AND BII_FILIAL = '" + xFilial('BII') + "' "
		cSql += "AND BI6_FILIAL = '" + xFilial('BI6') + "' "
		cSql += "AND B3J_FILIAL = '" + xFilial('B3J') + "' "
		cSql += "AND BF7_FILIAL = '" + xFilial('BF7') + "' "
		cSql += "AND BI3_CODINT = BA0_CODIDE||BA0_CODINT "
		cSql += "AND B3J_CODOPE = BA0_SUSEP "
		cSql += "AND B3J_CODIGO = BI3_CODINT||BI3_VERSAO "
		cSql += "AND BI3_TIPCON = BII_CODIGO "
		cSql += "AND BI3_CODSEG = BI6_CODSEG "
		cSql += "AND BI3_ABRANG = BF7_CODORI "
		cSql += "AND BII_TIPPLA <> ' '
		cSql += "AND BI6_SEGSIP <> ' '
		cSql += "AND BI3_INFANS <> '0' "
		cSql += "AND BI3.D_E_L_E_T_ = ' ' "
		cSql += "AND BA0.D_E_L_E_T_ = ' ' "
		cSql += "AND BII.D_E_L_E_T_ = ' ' "
		cSql += "AND BI6.D_E_L_E_T_ = ' ' "
		cSql += "AND B3J.D_E_L_E_T_ = ' ' "
		cSql += "AND BF7.D_E_L_E_T_ = ' ' "
	EndIf

	cSql += " GROUP BY BI3_CODINT, BI3_CODIGO, BI3_DESCRI, BI3_VERSAO, BI3_ABRANG, BA0_SUSEP, BII_TIPPLA, BI6_SEGSIP, BI6_PERDES, BF7_CODORI, BF7_PERDES "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBPRO",.F.,.T.)

	If TRBPRO->(Eof())
		lRet := .F.
	Else
		lRet := .T.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaAbrangencias

Funcao cria a area de trabalho TRBABR com as informacoes de todas as abrangencias (BF7)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaAbrangencias(nOpc)
	Local cSql	:= ''
	Local lRet	:= .F.
	Default nOpc	:= 1

	cSql += "SELECT DISTINCT BF7_CODORI, BF7_DESORI, BF7_PERDES "
	cSql += "FROM " + RetSqlName("BI3") + " BI3, " + RetSqlName('BF7') + " BF7 "
	cSql += "WHERE BI3_FILIAL = '" + xFilial('BI3') + "' "
	cSql += "AND BF7_FILIAL = '" + xFilial('BF7') + "' "
	cSql += "AND BI3_ABRANG = BF7_CODORI "
	cSql += "AND BI3_INFANS <> '0' "
	cSql += "AND BI3.D_E_L_E_T_ = ' ' "
	cSql += "AND BF7.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBABR",.F.,.T.)

	If TRBABR->(Eof())
		lRet := .F.
	Else
		lRet := .T.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaSegmentos

Funcao cria a area de trabalho TRBSEG com as informacoes de todos os segmentos (BI6)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaSegmentos(nOpc)
	Local cSql	:= ''
	Local lRet	:= .F.
	Default nOpc	:= 1

	cSql += "SELECT DISTINCT BI6_SEGSIP, BI6_PERDES "
	cSql += "FROM " + RetSqlName("BI3") + " BI3, " + RetSqlName('BI6') + " BI6 "
	cSql += "WHERE BI3_FILIAL = '" + xFilial('BI3') + "' "
	cSql += "AND BI6_FILIAL = '" + xFilial('BI6') + "' "
	cSql += "AND BI3_CODSEG = BI6_CODSEG "
	cSql += "AND BI3_INFANS <> '0' "
	cSql += "AND BI6_SEGSIP <> ' ' "
	cSql += "AND BI3.D_E_L_E_T_ = ' ' "
	cSql += "AND BI6.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBSEG",.F.,.T.)

	If TRBSEG->(Eof())
		lRet := .F.
	Else
		lRet := .T.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteProduto

Verifica se um produto ja se encontra cadastrado na tabela B3J da Central de Obrigacoes

@return lRet	Retorna .T. se encontrou o produto senao retorna .F.

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteProduto()
	Local lRet	:= .T.
	Local cSql	:= ""

	cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName('B3J') + " WHERE B3J_FILIAL = '" + xFilial('B3J') + "' AND B3J_CODOPE = '" + TRBPRO->BA0_SUSEP + "' "
	cSql += " AND B3J_CODIGO = '" + TRBPRO->(BI3_CODIGO+BI3_VERSAO) + "' AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBT",.F.,.T.)

	If !TRBT->(Eof())
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	TRBT->(dbCloseArea())

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteAbrangencia

Verifica se um produto ja se encontra cadastrado na tabela B3J da Central de Obrigacoes

@return lRet	Retorna .T. se encontrou o produto senao retorna .F.

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteAbrangencia()
	Local lRet	:= .T.
	Local cSql	:= ""

	cSql := "SELECT R_E_C_N_O_ "
	cSql += " FROM " + RetSqlName('B4X') + " "
	cSql += " WHERE B4X_FILIAL = '" + xFilial('B4X') + "' "
	cSql += " AND B4X_CODORI = '" + TRBABR->BF7_CODORI + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBT",.F.,.T.)

	If !TRBT->(Eof())
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	TRBT->(dbCloseArea())

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteSegmento

Verifica se um produto ja se encontra cadastrado na tabela B3J da Central de Obrigacoes

@return lRet	Retorna .T. se encontrou o produto senao retorna .F.

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteSegmento()
	Local lRet	:= .T.
	Local cSql	:= ""

	cSql := " SELECT R_E_C_N_O_ "
	cSql += " FROM " + RetSqlName('B4Y') + " "
	cSql += " WHERE B4Y_FILIAL = '" + xFilial('B4Y') + "' "
	cSql += " AND B4Y_SEGMEN = '" + TRBSEG->BI6_SEGSIP + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBT",.F.,.T.)

	If !TRBT->(Eof())
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	TRBT->(dbCloseArea())

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncluiProduto

Funcao inclui produtos ou planos no nucleo de informacoes e obrigacoes - tabela B3J

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncluiProduto(nOpcMVC)
	Local lRet := .F.
	Default nOpcMVC	:= MODEL_OPERATION_INSERT

	If nOpcMVC == 4 //Posiciono no produto do SIP

		B3J->(dbSetOrder(1)) //B3J_FILIAL+B3J_CODOPE+B3J_CODIGO
		B3J->(dbSeek(xFilial("B3J")+TRBPRO->(BA0_SUSEP)+TRBPRO->(BI3_CODIGO+BI3_VERSAO)))

	EndIf

	oModel	:= FWLoadModel( 'PLSMVCPRO' )
	oModel:SetOperation( nOpcMVC )
	oModel:Activate()
	oModel:SetValue( 'B3JMASTER', 'B3J_FILIAL'	, xFilial('B3J'))
	oModel:SetValue( 'B3JMASTER', 'B3J_CODOPE'	, TRBPRO->BA0_SUSEP)
	oModel:SetValue( 'B3JMASTER', 'B3J_CODIGO'	, TRBPRO->(BI3_CODIGO+BI3_VERSAO))
	oModel:SetValue( 'B3JMASTER', 'B3J_DESCRI'	, SubStr(ALLTRIM(TRBPRO->BI3_DESCRI), 1, 30))
	oModel:SetValue( 'B3JMASTER', 'B3J_FORCON'	, TRBPRO->BII_TIPPLA )
	oModel:SetValue( 'B3JMASTER', 'B3J_SEGMEN'	, SegPlsXCentral(TRBPRO->BI6_SEGSIP))
	oModel:SetValue( 'B3JMASTER', 'B3J_ABRANG'	, TRBPRO->BI3_ABRANG )
	oModel:SetValue( 'B3JMASTER', 'B3J_STATUS'	, '1' )

	If oModel:VldData()
		oModel:CommitData()
		lRet := .T.
	Else
		aErro := oModel:GetErrorMessage()
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil
	DelClassInf()

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SegPlsXCentral

Função para realizar De/Para dos dados do cBox do campo BI6_SEGSIP para B3J_SEGMEN

@param cSegSip	1=Hospitalar;2=Hospitalar Obstetricia;3=Outros;4=Ambulatorial;5=Odontologico

@param cSegmento 1=Ambulatorial;2=Hospitalar;3=Hospitalar obstetrico;4=Odontologico

@return cSegmento Retorna o valor do Case

@author Guilherme Carreiro da Silva
@since 02/12/2021
/*/
//--------------------------------------------------------------------------------------------------
Function SegPlsXCentral(cSegSip)

	Local cSegmento := ""
	Default cSegSip := ""

	Do Case
		case cSegSip == '1'
			cSegmento := '2'
		Case cSegSip == '2'
			cSegmento := '3'
		Case cSegSip == '3'
			cSegmento := ''
		Case cSegSip == '4'
			cSegmento := '1'
		Case cSegSip == '5'
			cSegmento := '4'
	EndCase

Return cSegmento
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncluiAbrangencia

Funcao inclui abrangências no nucleo de informacoes e obrigacoes - tabela B4X

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncluiAbrangencia(nOpcMVC)
	Local lRet := .F.
	Default nOpcMVC	:= MODEL_OPERATION_INSERT

	If nOpcMVC == 4 //Posiciono no produto do SIP

		B4X->(dbSetOrder(1)) //B4X_FILIAL+B4X_CODORI
		B4X->(dbSeek(xFilial("B4X")+TRBABR->BF7_CODORI))

	EndIf

	oModel	:= FWLoadModel( 'PLSMVCABR' )
	oModel:SetOperation( nOpcMVC )
	oModel:Activate()
	oModel:SetValue( 'B4XMASTER', 'B4X_FILIAL'	, xFilial('B3J') )
	oModel:SetValue( 'B4XMASTER', 'B4X_CODORI'	, TRBABR->BF7_CODORI )
	oModel:SetValue( 'B4XMASTER', 'B4X_DESORI'	, TRBABR->BF7_DESORI )
	oModel:SetValue( 'B4XMASTER', 'B4X_PERDES'	, TRBABR->BF7_PERDES )

	If oModel:VldData()
		oModel:CommitData()
		lRet := .T.
	Else
		aErro := oModel:GetErrorMessage()
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil
	DelClassInf()

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncluiSegmento

Funcao inclui segmentos no nucleo de informacoes e obrigacoes - tabela B4Y

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncluiSegmento(nOpcMVC)
	Local lRet := .F.
	Default nOpcMVC	:= MODEL_OPERATION_INSERT

	If nOpcMVC == 4 //Posiciono no produto do SIP

		B4Y->(dbSetOrder(1)) //B4Y_FILIAL+B4Y_SEGMEN
		B4Y->(dbSeek(xFilial("B4Y")+TRBSEG->BI6_SEGSIP))

	EndIf

	oModel	:= FWLoadModel( 'PLSMVCSEG' )
	oModel:SetOperation( nOpcMVC )
	oModel:Activate()
	oModel:SetValue( 'B4YMASTER', 'B4Y_FILIAL'	, xFilial('B3J') )
	oModel:SetValue( 'B4YMASTER', 'B4Y_SEGMEN'	, TRBSEG->BI6_SEGSIP )
	oModel:SetValue( 'B4YMASTER', 'B4Y_DESORI'	, RETCBOX("B3J_SEGMEN",TRBSEG->BI6_SEGSIP) )
	oModel:SetValue( 'B4YMASTER', 'B4Y_PERDES'	, TRBSEG->BI6_PERDES )

	If oModel:VldData()
		oModel:CommitData()
		lRet := .T.
	Else
		aErro := oModel:GetErrorMessage()
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil
	DelClassInf()

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Regua

Funcao criada para definir o tamanho da regua de progresso dos registros processados

@return nTamanho	Tamanho da regua de processamento

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function Regua()
	Local nTamanho	:= 0
	Local cSql		:= ''

	cSql += "SELECT COUNT(1) QTDE FROM ( "
	cSql += " SELECT BI3_CODINT, BI3_CODIGO, BI3_DESCRI, BI3_VERSAO, BI3_ABRANG, BA0_SUSEP, BII_TIPPLA, BI6_SEGSIP, BI6_PERDES, BF7_CODORI, BF7_PERDES "
	cSql += " FROM " + RetSqlName("BI3") + " BI3, " + RetSqlName('BA0') + " BA0, " + RetSqlName('BII') + " BII, " + RetSqlName('BI6') + " BI6, " + RetSqlName('BF7') + " BF7  "
	cSql += " WHERE BI3_FILIAL = '" + xFilial('BI3') + "' AND BA0_FILIAL = '" + xFilial('BA0') + "' AND BII_FILIAL = '" + xFilial('BII') + "' AND BI6_FILIAL = '" + xFilial('BI6') + "' "
	cSql += " AND BI3_CODINT = BA0_CODIDE||BA0_CODINT "
	cSql += " AND BII_TIPPLA <> ' '
	cSql += " AND BI6_SEGSIP <> ' '
	cSql += " AND BI3_ABRANG = BF7_CODORI "
	cSql += " AND BI3_TIPCON = BII_CODIGO AND BI3_CODSEG = BI6_CODSEG AND BI3_INFANS <> '0' "
	cSql += " AND BI3.D_E_L_E_T_ = ' ' AND BA0.D_E_L_E_T_ = ' ' AND BII.D_E_L_E_T_ = ' ' AND BI6.D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY BI3.R_E_C_N_O_,	BI3_SUSEP, 	BI3_CODIGO, 	BI3_VERSAO, 	BI3_DESCRI, 	BI3_TIPPLA, 	BI3_ABRANG, 	BII_TIPPLA, BI3_CODINT, BA0_SUSEP, BI6_SEGSIP, BI6_PERDES,BF7_CODORI, BF7_PERDES "
	cSql += " ) BI3 "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBR",.F.,.T.)

	If !TRBR->(Eof())
		nTamanho := TRBR->QTDE
	Endif

	TRBR->(dbCloseArea())

Return nTamanho
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
	Default nRegua		:= 0
	Default nRegPro	:= 0

	If nRegPro % 1 == 0
		IncProc(AllTrim(Str(nRegPro)) +"/"+ AllTrim(Str(nRegua)) + " produtos / planos processados ")
	EndIf

Return