#INCLUDE "JURA167.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//#DEFINE FPOSICIONE    STR0109 + "POSICIONE(cTabela,nIndice,cChave,cCampo)" + CHR(13) + STR0103 + CHR(13) + CHR(13) + "cTabela = " + STR0104 + CHR(13) + "nIndice = " + STR0105 + CHR(13) + "cChave = " + STR0106 + CHR(13) + "cCampo   = " + STR0107 + CHR(13) + CHR(13) + STR0108 + "Posicione('NQA',1,xFilial('NQA')+NT9->NT9_CTPENV,'NQA_DESC')"  
#DEFINE FPOSICIONE    STR0109 + "POSICIONE(cTabela,nIndice,cChave,cCampo)" + CRLF + STR0103 + CRLF + CRLF + "cTabela = " + STR0104 + CRLF + "nIndice = " + STR0105 + CRLF + "cChave = " + STR0106 + CRLF + "cCampo   = " + STR0107 + CRLF + CRLF + STR0108 + CRLF + "Posicione('NQA',1,xFilial('NQA')+NT9->NT9_CTPENV,'NQA_DESC')"
#DEFINE FJ167VARENV   STR0109 + "J167VarEnv(cCampo, cCliente, cPrincipal, cPolo, cTipoEnv, cTipoP)" + CRLF + STR0111 + CRLF + CRLF + "cCampo = " + STR0112 + CRLF + "cCliente = " + STR0113 + CRLF + "cPrincipal = " + STR0114 + CRLF + "cPolo = " + STR0115 + CRLF + "cTipoEnv = " + STR0116 + CRLF + "cTipoP = " + STR0117 + CRLF + CRLF + STR0108 + CRLF + "J167VarEnv('NT9_NOME', '1', '1', '1', '20', '2')" + CRLF + "J167VarEnv('NT9_NOME', '', '', '', '20', '')" + CRLF + "J167VarEnv('NT9_NOME',,,, '20',)"  
#DEFINE FSUBSTR       STR0109 + "SubStr(cText, nIni, nEnd)" + CRLF + STR0118 +  CRLF + CRLF + "cText = " + STR0119 + CRLF + "nIni = " + STR0120 + CRLF + "nEnd = " + STR0121 + CRLF + CRLF + STR0108 + CRLF + "SubStr('abcde', 2,3)" + STR0137 + "bcd"
#DEFINE FDTOS         STR0109 + "DToS(dData)" + CRLF + STR0122 + CRLF + CRLF + "dData = " + STR0123 + CRLF + CRLF + STR0108 + CRLF + "DToS(DATE())" + STR0137 + "'20140218'"
#DEFINE FVAL          STR0109 + "Val( nNum )" + CRLF + STR0124 + CRLF + CRLF + "nNum = " + STR0125 + CRLF + CRLF + STR0108 + CRLF + "Val('123')" + STR0137 + "123"
#DEFINE FMESEXTENSO   STR0109 + "MesExtenso( dData )" + CRLF + STR0126 + CRLF + CRLF + "dData = " + STR0127 + CRLF + CRLF + STR0108 + CRLF + "MesExtenso( Date() )" + STR0137 + STR0140
#DEFINE FEXTENSO      STR0109 + "Extenso( nValor, lNum )" + CRLF + STR0128 + CRLF + CRLF + "nValor = " + STR0129 + CRLF + "lNum = " + STR0130 + CRLF + CRLF + STR0108 + CRLF + "Extenso( 1, .F. )" + STR0137 + STR0138 + CRLF + "Extenso( 1, .T. )" + STR0137 + STR0139
#DEFINE FUPPER        STR0109 + "Upper( cText )" + CRLF + STR0131 + CRLF + CRLF + "cText = " + STR0132 + CRLF + CRLF + STR0108 + CRLF + "Upper('text')" + STR0137 + "'TEXT'"
#DEFINE FSTR          STR0109 + "Str( nNumero, nTamanho, nDecimais)" + CRLF + STR0133 + CRLF + CRLF + "nNumero = " + STR0134 + CRLF + "nTamanho = " + STR0135 + CRLF + "nDecimais = " + STR0136
#DEFINE FSETANDO      STR0110
#DEFINE TRACEJADO     CRLF + "------------------------------------------------------------------------------------------------" + CRLF
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA167
Variáveis - Petições

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA167()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NYN" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NYN" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA167", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA167", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA167", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA167", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA167", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0013, "J167Filter"     , 0, 3, 0, NIL } ) // "Config. Inicial"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Variáveis - Petições

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA167" )
Local oStruct := FWFormStruct( 2, "NYN" )

//oStruct:RemoveField( "NYN_ALTERA" )

JurSetAgrp( 'NYN',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA167_VIEW", oStruct, "NYNMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA167_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Variaveis - Petições"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Variáveis - Petições

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0

@obs NYNMASTER - Dados do Variáveis - Petições

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NYN" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA167", /*Pre-Validacao*/, {|oX|JA167TOK(oX)}/*Pos-Validacao*/,{|oX|JA167Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NYNMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Variáveis - Petições"
oModel:GetModel( "NYNMASTER" ):SetDescription( STR0009 ) // "Dados de Variáveis - Petições"

JurSetRules( oModel, 'NYNMASTER',, 'NYN' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA167Commit
Commit de dados de Variáveis - Petições

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA167Commit(oModel)
Local lRet := .T.

	FWFormCommit(oModel)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA167VldNom
Validação do campo de nome

@author Jorge Luis Branco Martins Junior
@since 22/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J167VldNom()
Local lRet := .T.

	//If !(SubStr( M->NYN_NOME, 1, 1 ) == '#' .And. SubStr( M->NYN_NOME, Len(Alltrim(M->NYN_NOME)), 1 ) == '#')
	//	lRet := .F.
	//	JurMsgErro("O texto deve estar entre '##'. Exemplo: #Texto# ")		
	//EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA167TOK
Validação de dados de Variáveis - Petições

@author Jorge Luis Branco Martins Junior
@since 28/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA167TOK(oModel)
Local lRet  := .T.
Local nOpc  := oModel:GetOperation()
Local cNome := oModel:GetValue("NYNMASTER","NYN_NOME")

	If 	Alltrim(JurGetDados("NYM", 1, xFilial("NYM")+ cNome, "NYM_NOME")) != ""
		lRet := .F.
		JurMsgErro(STR0011) // "Já existe um texto cadastrado com esse nome. Verifique!"
	EndIf

	If nOpc == 3 .And. Alltrim(JurGetDados("NYN", 1, xFilial("NYN")+ cNome, "NYN_NOME")) != ""
		lRet := .F.
		JurMsgErro(STR0010) //"Já existe uma variável cadastrada com esse nome. Verifique!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J167VarEnv
Função para busca de valores de campos indicados para variaveis da
rotina de modelos de petição. Esta função retorna o valor do campo
indicado no parametro, com filtros indicados também por valores nos
parametros. 

@param cCampo				Campo que se dejesa obter valor
@param cCliente			Indica se o envolvido é cliente(1=SIM, 2=NAO)
@param cPrincipal		Indica se o envolvido é principal (1=SIM, 2=NAO)
@param cPolo					Indica o pólo do Envolvido 
											(1=Pólo Ativo;2=Pólo Passivo;3=Terceiro Interessado)
@param cTipoEnv			Código do Tipo de Envolvimento
@param cTipoP				Indica o Tipo de Pessoa do Envolvido
											(1=Física;2=Jurídica)

@return cRet        Retorna valor do campo indicado.
 
@author Jorge Luis Branco Martins Junior
@since 07/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J167VarEnv(cCampo, cCliente, cPrincipal, cPolo, cTipoEnv, cTipoP)
Local aArea      := GetArea()
Local cQuery     := ""
Local cRet       := ""
Local lCliente   := .F.
Local lPrincipal := .F.
Local lPolo      := .F.
Local lTipoEnv   := .F.
Local lTipoP     := .F.

Local cAlias

Default cCampo     := "NT9_NOME"
Default cCliente   := ""
Default cPrincipal := ""
Default cPolo      := ""
Default cTipoEnv   := ""
Default cTipoP     := "" 

SX3->( dbSetOrder( 2 ) )
If SX3->( dbSeek( PadR( cCampo, 10 ) ) )

	lCliente   := !Empty( AllTrim( cCliente   ) )
	lPrincipal := !Empty( AllTrim( cPrincipal ) )
	lPolo      := !Empty( AllTrim( cPolo      ) )
	lTipoEnv   := !Empty( AllTrim( cTipoEnv   ) )
	lTipoP     := !Empty( AllTrim( cTipoP     ) )
	
		cQuery := " SELECT " + cCampo + " CAMPO "
		cQuery +=     " FROM "+RetSqlName("NT9")+" NT9"
		cQuery +=   " WHERE NT9_FILIAL = '" + xFilial( "NT9" ) + "'"
		cQuery +=     " AND NT9_CAJURI = '" + NSZ->NSZ_COD + "' "
		If lCliente
			cQuery +=   " AND NT9_TIPOCL = '" + cCliente + "' "
		EndIf
		If lPrincipal
			cQuery +=   " AND NT9_PRINCI = '" + cPrincipal + "' "
		EndIf
		If lPolo
			cQuery +=   " AND NT9_TIPOEN = '" + cPolo + "' "
		EndIf
		If lTipoEnv
			cQuery +=   " AND NT9_CTPENV = '" + cTipoEnv + "' "
		EndIf
		If lTipoP
			cQuery +=   " AND NT9_TIPOP = '" + cTipoP + "' "
		EndIf
		cQuery +=     " AND NT9.D_E_L_E_T_ = ' '"
	
		cQuery := ChangeQuery(cQuery)
		
		cAlias := GetNextAlias()
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		
		(cAlias)->( dbGoTop() )
		
		While !(cAlias)->( EOF() )
			cRet := (cAlias)->CAMPO
			(cAlias)->(DbSkip())
		End
	
		(cAlias)->( dbcloseArea() )
		
	cRet := PADR(cRet ,TAMSX3(cCampo)[1] )

Else
	cRet := Space(10)
EndIf
	
RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA167CONFG
Inclusão de configuração inicial

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 07/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA167CONFG(cOutorgante, cOutorgado, cRepLegal, cContratante, cContratado, cAutor, cReu, cAdvReu, lAutomato)
Local aArea      := GetArea()
Local lRet       := .T.
Local lCadPadrao := .T.
Local oModel     := ModelDef()
Local aDados     := {}
Local nI         := 0

Default cOutorgante   := StrZero(0, TamSX3('NT9_CTPENV')[1])
Default cOutorgado    := StrZero(0, TamSX3('NT9_CTPENV')[1])
Default cRepLegal     := StrZero(0, TamSX3('NT9_CTPENV')[1])
Default cContratante  := StrZero(0, TamSX3('NT9_CTPENV')[1])
Default cContratado   := StrZero(0, TamSX3('NT9_CTPENV')[1])
Default cAutor        := StrZero(0, TamSX3('NT9_CTPENV')[1])
Default cReu          := StrZero(0, TamSX3('NT9_CTPENV')[1])
Default cAdvReu       := StrZero(0, TamSX3('NT9_CTPENV')[1])
Default lAutomato     := .F.

	//Configuração das variáveis     
	If !JA167EXVAR("OUTORGANTE")
		aAdd( aDados, { "OUTORGANTE", "J167VarEnv('NT9_NOME',,,,'"+cOutorgante+"',)", STR0029, FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ENDOUTORGANTE")
		aAdd( aDados, { "ENDOUTORGANTE", "J167VarEnv('NT9_ENDECL',,,,'"+cOutorgante+"',)", STR0030, FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("BAIRROOUTORGANTE")
		aAdd( aDados, { "BAIRROOUTORGANTE", "J167VarEnv('NT9_BAIRRO',,,,'"+cOutorgante+"',)", STR0031, FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CEPOUTORGANTE")
		aAdd( aDados, { "CEPOUTORGANTE", "J167VarEnv('NT9_CEP',,,,'"+cOutorgante+"',)", STR0032, FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CIDADEOUTORGANTE")
		aAdd( aDados, { "CIDADEOUTORGANTE", "POSICIONE( 'CC2', 1, XFILIAL('CC2') + J167VarEnv('NT9_ESTADO',,,,'"+cOutorgante+"',) + J167VarEnv('NT9_CMUNIC',,,,'"+cOutorgante+"',), 'CC2_MUN')", STR0033, FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ESTADOOUTORGANTE")
		aAdd( aDados, { "ESTADOOUTORGANTE", "J167VarEnv('NT9_ESTADO',,,,'"+cOutorgante+"',)", STR0034, FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CNPJOUTORGANTE")
		aAdd( aDados, { "CNPJOUTORGANTE", "J167VarEnv('NT9_CGC',,,,'"+cOutorgante+"',)", STR0035, FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("IEOUTORGANTE")
		aAdd( aDados, { "IEOUTORGANTE", "J167VarEnv('NT9_INSCR',,,,'"+cOutorgante+"',)", STR0036, FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("REPLEGAL")
		aAdd( aDados, { "REPLEGAL", "J167VarEnv('NT9_NOME',,,,'"+cRepLegal+"',)", STR0037, FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("NACIOREPLEGAL")
		aAdd( aDados, { "NACIOREPLEGAL", "POSICIONE('SX5',1,XFILIAL('SX5')+'34'+J167VarEnv('NT9_CNACIO',,,,'"+cRepLegal+"',),'X5_DESCRI')", STR0038, FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ESTCIVILREPLEGAL")
		aAdd( aDados, { "ESTCIVILREPLEGAL", "POSICIONE('SX5',1,XFILIAL('SX5')+'33'+J167VarEnv('NT9_CESTCV',,,,'"+cRepLegal+"',),'X5_DESCRI')", STR0039, FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("PROFISSAOREPLEGAL")
		aAdd( aDados, { "PROFISSAOREPLEGAL", "POSICIONE('NRP',1,XFILIAL('NRP')+J167VarEnv('NT9_CCGECL',,,,'"+cRepLegal+"',),'NRP_DESC')", STR0040, FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf

	If !JA167EXVAR("RGREPLEGAL")
		aAdd( aDados, { "RGREPLEGAL","J167VarEnv('NT9_RG',,,,'"+cRepLegal+"',)", STR0041, FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CPFREPLEGAL")
		aAdd( aDados, { "CPFREPLEGAL","J167VarEnv('NT9_CGC',,,,'"+cRepLegal+"',)",STR0042,FJ167VARENV } )
	EndIf

	If !JA167EXVAR("ENDREPLEGAL")
		aAdd( aDados, { "ENDREPLEGAL","J167VarEnv('NT9_ENDECL',,,,'"+cRepLegal+"',)",STR0043,FJ167VARENV } )
	EndIf

	If !JA167EXVAR("BAIRROREPLEGAL")
		aAdd( aDados, { "BAIRROREPLEGAL","J167VarEnv('NT9_BAIRRO',,,,'"+cRepLegal+"',)",STR0044,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CEPREPLEGAL")
		aAdd( aDados, { "CEPREPLEGAL","J167VarEnv('NT9_CEP',,,,'"+cRepLegal+"',)",STR0045,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CIDADEREPLEGAL")
		aAdd( aDados, { "CIDADEREPLEGAL","POSICIONE( 'CC2', 1, XFILIAL('CC2') + J167VarEnv('NT9_ESTADO',,,,'"+cRepLegal+"',) + J167VarEnv('NT9_CMUNIC',,,,'"+cRepLegal+"',), 'CC2_MUN')",STR0046,FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ESTADOREPLEGAL")
		aAdd( aDados, { "ESTADOREPLEGAL","J167VarEnv('NT9_ESTADO',,,,'"+cRepLegal+"',)",STR0047,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("OUTORGADO")
		aAdd( aDados, { "OUTORGADO","J167VarEnv('NT9_NOME',,,,'"+cOutorgado+"',)",STR0048,FJ167VARENV } )
	EndIf
		
	If !JA167EXVAR("NACIOOUTORGADO")
		aAdd( aDados, { "NACIOOUTORGADO","POSICIONE('SX5',1,XFILIAL('SX5')+'34'+J167VarEnv('NT9_CNACIO',,,,'"+cOutorgado+"',),'X5_DESCRI')",STR0049,FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
		
	If !JA167EXVAR("ESTCIVILOUTORGADO")
		aAdd( aDados, { "ESTCIVILOUTORGADO","POSICIONE('SX5',1,XFILIAL('SX5')+'33'+J167VarEnv('NT9_CESTCV',,,,'"+cOutorgado+"',),'X5_DESCRI')",STR0050,FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
		
	If !JA167EXVAR("PROFISSAOOUTORGADO")
		aAdd( aDados, { "PROFISSAOOUTORGADO","POSICIONE('NRP',1,XFILIAL('NRP')+J167VarEnv('NT9_CCGECL',,,,'"+cOutorgado+"',),'NRP_DESC')",STR0051,FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
		
	If !JA167EXVAR("OABOUTORGADO")
		aAdd( aDados, { "OABOUTORGADO","J167VarEnv('NT9_OAB',,,,'"+cOutorgado+"',)",STR0052,FJ167VARENV } )
	EndIf
		
	If !JA167EXVAR("CPFOUTORGADO")
		aAdd( aDados, { "CPFOUTORGADO","J167VarEnv('NT9_CGC',,,,'"+cOutorgado+"',)",STR0053,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ENDOUTORGADO")
		aAdd( aDados, { "ENDOUTORGADO","J167VarEnv('NT9_ENDECL',,,,'"+cOutorgado+"',)",STR0054,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("BAIRROOUTORGADO")
		aAdd( aDados, { "BAIRROOUTORGADO","J167VarEnv('NT9_BAIRRO',,,,'"+cOutorgado+"',)",STR0055,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CEPOUTORGADO")
		aAdd( aDados, { "CEPOUTORGADO","J167VarEnv('NT9_CEP',,,,'"+cOutorgado+"',)",STR0056,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CIDADEOUTORGADO")
		aAdd( aDados, { "CIDADEOUTORGADO","POSICIONE( 'CC2', 1, XFILIAL('CC2') + J167VarEnv('NT9_ESTADO',,,,'"+cOutorgado+"',) + J167VarEnv('NT9_CMUNIC',,,,'"+cOutorgado+"',), 'CC2_MUN')",STR0057,FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ESTADOOUTORGADO")
		aAdd( aDados, { "ESTADOOUTORGADO","J167VarEnv('NT9_ESTADO',,,,'"+cOutorgado+"',)",STR0058,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("PODERES")
		aAdd( aDados, { "PODERES","NSZ->NSZ_PODER",STR0059,STR0110 } )
	EndIf
	
	If !JA167EXVAR("MUNPROCURACAO")
		aAdd( aDados, { "MUNPROCURACAO","POSICIONE('CC2',1,XFILIAL('CC2')+NSZ->NSZ_ESTADO+NSZ->NSZ_CMUNIC,'CC2_MUN')",STR0060,FPOSICIONE } )
	EndIf
	
	If !JA167EXVAR("DIAPROCURACAO")
		aAdd( aDados, { "DIAPROCURACAO","SUBSTR(DtoS(NSZ->NSZ_DTINVI), 7, 2)",STR0061,FSUBSTR + CRLF + TRACEJADO + FDTOS } )
	EndIf
	
	If !JA167EXVAR("MESPROCURACAO")
		aAdd( aDados, { "MESPROCURACAO","MesExtenso( Val(SUBSTR(DtoS(NSZ->NSZ_DTINVI), 5, 2)) )",STR0062,FMESEXTENSO  + CRLF + TRACEJADO + FVAL + CRLF + TRACEJADO + FSUBSTR + CRLF + TRACEJADO + FDTOS } )
	EndIf
	
	If !JA167EXVAR("ANOPROCURACAO")
		aAdd( aDados, { "ANOPROCURACAO","SUBSTR(DtoS(NSZ->NSZ_DTINVI), 1, 4)",STR0063,FSUBSTR + CRLF + TRACEJADO + FDTOS } )
	EndIf
	
	If !JA167EXVAR("CONTRATANTE")
		aAdd( aDados, { "CONTRATANTE","J167VarEnv('NT9_NOME',,,,'"+cContratante+"',)",STR0064,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CIDADECONTRATANTE")
		aAdd( aDados, { "CIDADECONTRATANTE","POSICIONE( 'CC2', 1, XFILIAL('CC2') + J167VarEnv('NT9_ESTADO',,,,'"+cContratante+"',) + J167VarEnv('NT9_CMUNIC',,,,'"+cContratante+"',), 'CC2_MUN')",STR0065,FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ESTADOCONTRATANTE")
		aAdd( aDados, { "ESTADOCONTRATANTE","J167VarEnv('NT9_ESTADO',,,,'"+cContratante+"',)",STR0066,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ENDCONTRATANTE")
		aAdd( aDados, { "ENDCONTRATANTE","J167VarEnv('NT9_ENDECL',,,,'"+cContratante+"',)",STR0067,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("BAIRROCONTRATANTE")
		aAdd( aDados, { "BAIRROCONTRATANTE","J167VarEnv('NT9_BAIRRO',,,,'"+cContratante+"',)",STR0068,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CEPCONTRATANTE")
		aAdd( aDados, { "CEPCONTRATANTE","J167VarEnv('NT9_CEP',,,,'"+cContratante+"',)",STR0069,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CNPJCONTRATANTE")
		aAdd( aDados, { "CNPJCONTRATANTE","J167VarEnv('NT9_CGC',,,,'"+cContratante+"',)",STR0070,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CONTRATADO")
		aAdd( aDados, { "CONTRATADO","J167VarEnv('NT9_NOME',,,,'"+cContratado+"',)",STR0071,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CIDADECONTRATADO")
		aAdd( aDados, { "CIDADECONTRATADO","POSICIONE( 'CC2', 1, XFILIAL('CC2') + J167VarEnv('NT9_ESTADO',,,,'"+cContratado+"',) + J167VarEnv('NT9_CMUNIC',,,,'"+cContratado+"',), 'CC2_MUN')",STR0072,FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ESTADOCONTRATADO")
		aAdd( aDados, { "ESTADOCONTRATADO","J167VarEnv('NT9_ESTADO',,,,'"+cContratado+"',)",STR0073,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ENDCONTRATADO")
		aAdd( aDados, { "ENDCONTRATADO","J167VarEnv('NT9_ENDECL',,,,'"+cContratado+"',)",STR0074,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("BAIRROCONTRATADO")
		aAdd( aDados, { "BAIRROCONTRATADO","J167VarEnv('NT9_BAIRRO',,,,'"+cContratado+"',)",STR0075,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CEPCONTRATADO")
		aAdd( aDados, { "CEPCONTRATADO","J167VarEnv('NT9_CEP',,,,'"+cContratado+"',)",STR0076,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CNPJCONTRATADO")
		aAdd( aDados, { "CNPJCONTRATADO","J167VarEnv('NT9_CGC',,,,'"+cContratado+"',)",STR0077,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("OBJCONTRATO")
		aAdd( aDados, { "OBJCONTRATO","NSZ->NSZ_OBJCON",STR0078,STR0110 } )
	EndIf
	
	If !JA167EXVAR("INIVIGCONTRATO")
		aAdd( aDados, { "INIVIGCONTRATO","SUBSTR(DtoS(NSZ->NSZ_DTINVI), 7, 2) + '/' + SUBSTR(DtoS(NSZ->NSZ_DTINVI), 5, 2) + '/' + SUBSTR(DtoS(NSZ->NSZ_DTINVI), 1, 4)",STR0079,FSUBSTR + CRLF + TRACEJADO + FDTOS } )
	EndIf
	
	If !JA167EXVAR("FIMVIGCONTRATO")
		aAdd( aDados, { "FIMVIGCONTRATO","SUBSTR(DtoS(NSZ->NSZ_DTTMVI), 7, 2) + '/' + SUBSTR(DtoS(NSZ->NSZ_DTTMVI), 5, 2) + '/' + SUBSTR(DtoS(NSZ->NSZ_DTTMVI), 1, 4)",STR0080,FSUBSTR + CRLF + TRACEJADO + FDTOS } )
	EndIf
	
	If !JA167EXVAR("VALORCONTRATO")
		aAdd( aDados, { "VALORCONTRATO","STR(NSZ->NSZ_VLCONT)",STR0081,FSTR } )
	EndIf
	
	If !JA167EXVAR("VALOREXTCONTRATO")
		aAdd( aDados, { "VALOREXTCONTRATO","Capital(Extenso(NSZ->NSZ_VLCONT, .F. ))",STR0082,FEXTENSO } )
	EndIf
	
	If !JA167EXVAR("CONDPGCONTRATO")
		aAdd( aDados, { "CONDPGCONTRATO","POSICIONE( 'SE4', 1, XFILIAL('SE4') + ALLTRIM(NSZ->NSZ_CCPCON), 'E4_DESCRI')",STR0083,FPOSICIONE } )
	EndIf
	
	If !JA167EXVAR("MULTACONTRATO")
		aAdd( aDados, { "MULTACONTRATO","STR(NSZ->NSZ_MULCON)",STR0084,FSTR } )
	EndIf
	
	If !JA167EXVAR("MULTAEXTCONTRATO")
		aAdd( aDados, { "MULTAEXTCONTRATO","Capital(Extenso(NSZ->NSZ_MULCON, .T. ))",STR0085,FEXTENSO } )
	EndIf
	
	If !JA167EXVAR("INDICEMULTACONTRATO")
		aAdd( aDados, { "INDICEMULTACONTRATO","NSZ->NSZ_INDCON",STR0086,STR0110 } )
	EndIf
	
	If !JA167EXVAR("VARACIVEL")
		aAdd( aDados, { "VARACIVEL","Upper(Posicione('NQE',1,xFilial('NQE')+Posicione('NUQ',2,xFilial('NUQ')+NSZ->NSZ_COD+'1','NUQ_CLOC3N'),'NQE_DESC'))",STR0087,FUPPER + CRLF + TRACEJADO + FPOSICIONE } )
	EndIf
	
	If !JA167EXVAR("COMARCA")
		aAdd( aDados, { "COMARCA","Upper(Posicione('NQ6',1,xFilial('NQ6')+Posicione('NUQ',2,xFilial('NUQ')+NSZ->NSZ_COD+'1','NUQ_CCOMAR'),'NQ6_DESC'))",STR0088,FUPPER + CRLF + TRACEJADO + FPOSICIONE } )
	EndIf
	
	If !JA167EXVAR("PROCESSONUM")
		aAdd( aDados, { "PROCESSONUM","Posicione('NUQ',2,xFilial('NUQ')+NSZ->NSZ_COD+'1','NUQ_NUMPRO')",STR0089,FPOSICIONE } )
	EndIf
	
	If !JA167EXVAR("NOMEREU")
		aAdd( aDados, { "NOMEREU","J167VarEnv('NT9_NOME',,,,'"+cReu+"',)",STR0090,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("TIPOACAO")
		aAdd( aDados, { "TIPOACAO","Posicione('NQU',1,xFilial('NQU')+Posicione('NUQ',2,xFilial('NUQ')+NSZ->NSZ_COD+'1','NUQ_CTIPAC'),'NQU_DESC')",STR0091,FPOSICIONE } )
	EndIf
	
	If !JA167EXVAR("NOMEAUTOR")
		aAdd( aDados, { "NOMEAUTOR","J167VarEnv('NT9_NOME',,,,'"+cAutor+"',)",STR0092,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ENDERECOPASSIVO")
		aAdd( aDados, { "ENDERECOPASSIVO","J167VarEnv('NT9_ENDECL',,,,'"+cAdvReu+"',)",STR0093,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("BAIRROPASSIVO")
		aAdd( aDados, { "BAIRROPASSIVO","J167VarEnv('NT9_BAIRRO',,,,'"+cAdvReu+"',)",STR0094,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CIDADEPASSIVO")
		aAdd( aDados, { "CIDADEPASSIVO","POSICIONE( 'CC2', 1, XFILIAL('CC2') + J167VarEnv('NT9_ESTADO',,,,'"+cAdvReu+"',) + J167VarEnv('NT9_CMUNIC',,,,'"+cAdvReu+"',), 'CC2_MUN')",STR0095,FPOSICIONE + CRLF + TRACEJADO + FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("CEPPASSIVO")
		aAdd( aDados, { "CEPPASSIVO","J167VarEnv('NT9_CEP',,,,'"+cAdvReu+"',)",STR0096,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("ESTADOPASSIVO")
		aAdd( aDados, { "ESTADOPASSIVO","J167VarEnv('NT9_ESTADO',,,,'"+cAdvReu+"',)",STR0097,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("DIAATUAL")
		aAdd( aDados, { "DIAATUAL","SUBSTR(DtoS(Date()), 7, 2)",STR0098,FSUBSTR + CRLF + TRACEJADO + FDTOS } )
	EndIf
	
	If !JA167EXVAR("MESATUAL")
		aAdd( aDados, { "MESATUAL","MesExtenso( Val(SUBSTR(DtoS(Date()), 5, 2)) )",STR0099,FMESEXTENSO  + CRLF + TRACEJADO + FVAL + CRLF + TRACEJADO + FSUBSTR + CRLF + TRACEJADO + FDTOS } )
	EndIf
	
	If !JA167EXVAR("ANOATUAL")
		aAdd( aDados, { "ANOATUAL","SUBSTR(DtoS(Date()), 1, 4)",STR0100,FSUBSTR + CRLF + TRACEJADO + FDTOS } )
	EndIf
	
	If !JA167EXVAR("NOMEADVOGADO")
		aAdd( aDados, { "NOMEADVOGADO","J167VarEnv('NT9_NOME',,,,'"+cAdvReu+"',)",STR0101,FJ167VARENV } )
	EndIf
	
	If !JA167EXVAR("OABADVOGADO")
		aAdd( aDados, { "OABADVOGADO","J167VarEnv('NT9_OAB',,,,'"+cAdvReu+"',)",STR0102,FJ167VARENV } )
	EndIf	
	

	If Len(aDados) > 0
		oModel:SetOperation( 3 )
		For nI := 1 To Len( aDados )
			oModel:Activate()

			If !oModel:SetValue("NYNMASTER",'NYN_NOME',aDados[nI][1]) .Or. ;
			   !oModel:SetValue("NYNMASTER",'NYN_FORM',aDados[nI][2]) .Or. ;
			   !oModel:SetValue("NYNMASTER",'NYN_DESC',aDados[nI][3]) .Or. ;
			   !oModel:SetValue("NYNMASTER",'NYN_OBS',aDados[nI][4])
				lRet := .F.
				JurMsgErro( STR0012 ) //Erro na carga da configuração inicial
				Exit
			Else
				lCadPadrao := .F.
			EndIf

			If	lRet
				JA167Grava(oModel, lRet)
			EndIf

		  oModel:DeActivate()
		Next
	EndIf

	If lCadPadrao	                 
		lRet := .F.
		JurMsgErro( STR0014 ) //Não é possível realizar a carga inicial, já existe configuração.
	EndIf

	If lRet .AND. !lAutomato
		ApMsgInfo(STR0141)//"Configuração realizada com sucesso"
	EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA167Grava
Grava a configuração de tabela

@Param oModel	Model ativo
@Param lRet		.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 11/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 
Static Function JA167Grava(oModel, lRet) 
Local aErro:= {}

If lRet
	If ( lRet := oModel:VldData() )
		oModel:CommitData()
		If __lSX8
			ConfirmSX8()
		EndIf
	Else
		aErro := oModel:GetErrorMessage()
		JurMsgErro(aErro[6])
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA167EXVAR
Valida se a variável já está configurada na NYN

@Param cRelat	Varável que será validada na NYN

@Return lRet	 	.T./.F. Se a tabela existe ou não na configuração.

@author Jorge Luis Branco Martins Junior
@since 11/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA167EXVAR(cVar)
Local lRet := .F.
Local aArea    := GetArea()
Local aAreaNYN := NYN->( GetArea() )

dbSelectArea('NYN')
dbSetOrder(1)

If dbSeek(xFilial('NYN') + cVar)
	lRet := .T.
Endif

RestArea(aAreaNYN)
RestArea(aArea)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J167Filter
Relaliza filtro que identifica os tipos de envolvimento para 
configuração inicial de variáveis

@Param cRelat	Varável que será validada na NYN

@Return aDados	  Array que contém os tipos de envolvimento
								  para montagem das fórmulas.

@author Jorge Luis Branco Martins Junior
@since 17/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 
Function J167Filter()

Local oOutorgante, oOutorgado, oRepLegal, oContratante, oContratado, oAutor, oReu, oAdvReu
Local oDlg
Local oPanel  := NIL
Local oPanelA	:= NIL 
Local oGroupA	:= NIL

Local cOutorgante   := Criavar('NT9_CTPENV', .F.)
Local cOutorgado    := Criavar('NT9_CTPENV', .F.)
Local cRepLegal     := Criavar('NT9_CTPENV', .F.)
Local cContratante  := Criavar('NT9_CTPENV', .F.)
Local cContratado   := Criavar('NT9_CTPENV', .F.)
Local cAutor        := Criavar('NT9_CTPENV', .F.)
Local cReu          := Criavar('NT9_CTPENV', .F.)
Local cAdvReu       := Criavar('NT9_CTPENV', .F.)

	If ApMsgYesNo( STR0015 ) //"Serão incluídos novas variáveis do padrão, para isso é importante preencher os dados dos tipos de envolvimento para montagem das fórmulas. Deseja continuar?"

		Define MsDialog oDlg Title STR0013 FROM 176, 188  To 560, 500 Pixel // "Conf. Inicial"
		oPanel := tPanel():New(0,0,'',oDlg,,,,,,0,0,.F.,.F.)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT	

		oGroupA := TGroup():New( 003, 005, 173, 153, STR0016, oPanel, , , .T. )  //Tipo de Envolvimento
		oPanelA := tPanel():New(003+8, 005+3,'',oGroupA,,,,,/*CLR_YELLOW*/,143,153,.F.,.F.)

		oOutorgante := TJurPnlCampo():Initialize(010,005,040,022,oPanelA,STR0017,'NT9_CTPENV') //"Outorgante"
		oOutorgante:SetValid( {|| Empty(oOutorgante:GetValue()) .OR. ExistCpo('NQA', oOutorgante:GetValue()) } )
		oOutorgante:SetChange( {|| cOutorgante := oOutorgante:GetValue(), .T. } )
		oOutorgante:SetF3("NQA")
		oOutorgante:Activate()
		
		oOutorgado := TJurPnlCampo():Initialize(010,080,040,022,oPanelA,STR0018,'NT9_CTPENV') //"Outorgado"
		oOutorgado:SetValid( {|| Empty(oOutorgado:GetValue()) .OR. ExistCpo('NQA', oOutorgado:GetValue()) } )
		oOutorgado:SetChange( {|| cOutorgado := oOutorgado:GetValue(), .T. } )
		oOutorgado:SetF3("NQA")
		oOutorgado:Activate()
		
		oRepLegal := TJurPnlCampo():Initialize(050,005,040,022,oPanelA,STR0019,'NT9_CTPENV') //"Rep. Legal"
		oRepLegal:SetValid( {|| Empty(oRepLegal:GetValue()) .OR. ExistCpo('NQA', oRepLegal:GetValue()) } )
		oRepLegal:SetChange( {|| cRepLegal := oRepLegal:GetValue(), .T. } )
		oRepLegal:SetF3("NQA")
		oRepLegal:Activate()
		
		oContratante := TJurPnlCampo():Initialize(050,080,040,022,oPanelA,STR0020,'NT9_CTPENV') //"Contratante"
		oContratante:SetValid( {|| Empty(oContratante:GetValue()) .OR. ExistCpo('NQA', oContratante:GetValue()) } )
		oContratante:SetChange( {|| cContratante := oContratante:GetValue(), .T. } )
		oContratante:SetF3("NQA")
		oContratante:Activate()
		
		oContratado := TJurPnlCampo():Initialize(090,005,040,022,oPanelA,STR0021,'NT9_CTPENV') //"Contratado"
		oContratado:SetValid( {|| Empty(oContratado:GetValue()) .OR. ExistCpo('NQA', oContratado:GetValue()) } )
		oContratado:SetChange( {|| cContratado := oContratado:GetValue(), .T. } )
		oContratado:SetF3("NQA")
		oContratado:Activate()
		
		oAutor := TJurPnlCampo():Initialize(090,080,040,022,oPanelA,STR0022,'NT9_CTPENV') //"Autor"
		oAutor:SetValid( {|| Empty(oAutor:GetValue()) .OR. ExistCpo('NQA', oAutor:GetValue()) } )
		oAutor:SetChange( {|| cAutor := oAutor:GetValue(), .T. } )
		oAutor:SetF3("NQA")
		oAutor:Activate()
		
		oReu := TJurPnlCampo():Initialize(130,005,040,022,oPanelA,STR0023,'NT9_CTPENV') //"Réu"
		oReu:SetValid( {|| Empty(oReu:GetValue()) .OR. ExistCpo('NQA', oReu:GetValue()) } )
		oReu:SetChange( {|| cReu := oReu:GetValue(), .T. } )
		oReu:SetF3("NQA")
		oReu:Activate()
		
		oAdvReu := TJurPnlCampo():Initialize(130,080,040,022,oPanelA,STR0024,'NT9_CTPENV') //"Adv. do Réu"
		oAdvReu:SetValid( {|| Empty(oAdvReu:GetValue()) .OR. ExistCpo('NQA', oAdvReu:GetValue()) } )
		oAdvReu:SetChange( {|| cAdvReu := oAdvReu:GetValue(), .T. } )
		oAdvReu:SetF3("NQA")
		oAdvReu:Activate()

		@ 178,040 BUTTON obntOk Prompt STR0025 Size 28, 10 Of oPanel Pixel ; //Confirmar
		Action ( Processa( {|| IIF( JA167VLTPE(cOutorgante, cOutorgado, cRepLegal, cContratante, cContratado, cAutor, cReu, cAdvReu), JA167CONFG(cOutorgante, cOutorgado, cRepLegal, cContratante, cContratado, cAutor, cReu, cAdvReu), JurMsgErro("Preencha todos os campos")) } , STR0026, STR0027, .F. )) // 'Aguarde' e 'Gerando...
		@ 178,090 BUTTON obntSair Prompt STR0028 Size 28, 10 Of oPanel Pixel Action oDlg:End() //Sair
		
		Activate MsDialog oDlg Centered

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA167VLTPE
Valida se todos os tipos de envolvimento foram preenchidos

@Param 

@Return 

@author Jorge Luis Branco Martins Junior
@since 17/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 

Function JA167VLTPE(cOutorgante, cOutorgado, cRepLegal, cContratante, cContratado, cAutor, cReu, cAdvReu)
Local lRet := .T.

If     ( Empty(AllTrim(cOutorgante));
    .Or. Empty(AllTrim(cOutorgado));
    .Or. Empty(AllTrim(cRepLegal));
    .Or. Empty(AllTrim(cContratante));
    .Or. Empty(AllTrim(cContratado));
    .Or. Empty(AllTrim(cAutor));
    .Or. Empty(AllTrim(cReu));
    .Or. Empty(AllTrim(cAdvReu)) )
	lRet := .F.
EndIf
	
Return lRet
