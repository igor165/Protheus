#include "Protheus.ch"
#include "GPEA935.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"

//Recuperar versão de envio
Static cVersEnvio	:= ""
Static lMiddleware	:= SuperGetMv("MV_MID",, .F.)
Static lRJ9CPO		:= ChkFile("RJ9") .And. If(RJ9->(ColumnPos("RJ9_CLIENT")) > 0, .T., .F.)
Static lDtLei		:= ChkFile("RJ9") .And. If(RJ9->(ColumnPos("RJ9_L11096")) > 0, .T., .F.)

/*/{Protheus.doc} GPEA935
Cadastro do Empregador
@author Silvia Taguti
@since 27/06/2019
@version P12.1.27
@Type     Function
/*/

Function GPEA935()
	Local cFiltraRh
	Local oBrwRJ9
	Local cMsgDesatu	:= ""
	Local aDados		:= {}

	If !ChkFile("RJ9")
		cMsgDesatu := CRLF + OemToAnsi(STR0008) + CRLF //"Tabela RJ6 não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	EndIf

	If !Findfunction("fVldIniRJ")
		cMsgDesatu += CRLF + OemToAnsi(STR0009)  //"Não foram encontradas atualizações necessárias para utilização desta rotina, favor atualizar o repositório."
	EndIf

	If lMiddleware .And. !ChkFile("RJE")
		cMsgDesatu := CRLF + OemToAnsi(STR0060) + CRLF //"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	EndIf

	If !Empty(cMsgDesatu)
		//ATENCAO"###"Tabela RJ9 não encontrada na base de dados. Execute o UPDDISTR."
		//ATENCAO"###"Não foram encontradas atualizações necessárias para utilização desta rotina, favor atualizar o repositório."
		Help( " ", 1, OemToAnsi(STR0007),, cMsgDesatu, 1, 0 )
		Return
	EndIf

	//Primeiro parâmetro da VldRotTab, quais eventos validar {S-1005, S-1010, S-1020}
	If !VldRotTab({.T.,.F.,.F.},@aDados)
		Help( " ", 1, OemToAnsi(STR0007),, CRLF + aDados[1] + CRLF + CRLF + OemToAnsi(STR0012) + CRLF + OemToAnsi(STR0013), 1, 0) //Atenção # O compartilhamento da tabela (RJ9) e (C92) estão divergentes, altere o modo de acesso através do Configurador. Arquivos (RJ9) e (C92)
		//O modo de acesso deve ser o mesmo para todas as tabelas envolvidas no processo, são elas: RJ9 e RJA."
		Return
	EndIf

	If FindFunction("fVersEsoc")
		fVersEsoc( "S1000", .F., /*aRetGPE*/, /*aRetTAF*/, Nil,Nil, @cVersEnvio)
	Endif

  	oBrwRJ9 := FWmBrowse():New()
	oBrwRJ9:SetAlias( 'RJ9' )
	oBrwRJ9:SetDescription(OemToAnsi(STR0001))	//"Cadastro do Empregador"

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh	:= CHKRH(FunName(),"RJ9","1")

	//Filtro padrao do Browse conforme tabela RJ9 (Cadastro do Empregador)
	oBrwRJ9:SetFilterDefault(cFiltraRh)
	oBrwRJ9:SetLocate()

	oBrwRJ9:ExecuteFilter(.T.)
	oBrwRJ9:Activate()

Return

/*/{Protheus.doc}
Menu Funcional
@type      	Static Function
@author   	Silvia Taguti
@since		27/06/2019
@version	1.0
@return		oMdlRJ9
/*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA935'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA935'  OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA935'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA935'	OPERATION 5 ACCESS 0 //"Excluir"
If lRJ9CPO
	ADD OPTION aRotina Title OemToAnsi(STR0079) ACTION 'fAtuCred()'		 	OPERATION 6 ACCESS 0 //"Atualizar Credenciais"
EndIf

Return aRotina

/*/{Protheus.doc}
Modelo de dados e Regras de Preenchimento para o Cadastro do Empregador
@type      	Static Function
@author   	Silvia Taguti
@since		27/06/2019
@version	1.0
@return		oMdlRJ9
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRJ9	:= FWFormStruct( 1, 'RJ9', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStructRJA := FWFormStruct(1,"RJA")
	Local oMdlRJ9

	// Blocos de codigo do modelo
    Local bPosValid 	:= { |oMdlRJ9| Gp935CPosVal( oMdlRJ9 )}
    Local bCommit		:= { |oMdlRJ9| Gp935CGrav( oMdlRJ9 )}

	// Bloco de codigo Fields
	Local bTOkVld		:= { |oGrid| Gp935TdOk( oGrid, oMdlRJ9)}

	// Cria o objeto do Modelo de Dados
	oMdlRJ9 := MPFormModel():New('GPEA935', /*bPreValid*/ , bPosValid, bCommit, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oMdlRJ9:AddFields( 'GPEA935_RJ9', /*cOwner*/, oStruRJ9, /*bLOkVl*/ , bTOkVld, /*bCarga*/ )

	//Adiciona o Grid
	oMdlRJ9:AddGrid("GPEA935_RJA", "GPEA935_RJ9"/*cOwner*/, oStructRJA , /*bLinePre*/ ,  { |oGrid| GP935LOk(oGrid) }/* bLinePost*/, /*bPreValid*/,  /*bPosVaGrid*/,/*bLoad*/)

	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRJ9:GetModel( 'GPEA935_RJ9' ):SetDescription(OemToAnsi(STR0001)) //"Cadastro do Empregador"

	oMdlRJ9:SetRelation("GPEA935_RJA",{{"RJA_FILIAL",'xFilial("RJA",RJ9->RJ9_FILIAL)'},{"RJA_INI","RJ9_INI"},{"RJA_TPINSC","RJ9_TPINSC"}, {"RJA_NRINSC","RJ9_NRINSC"}},RJA->(IndexKey()))

	oMdlRJ9:GetModel('GPEA935_RJA'):SetOptional(.T.)

Return oMdlRJ9


/*/{Protheus.doc}
Visualizador de dados do Cadastro de Empresa
@type      	Static Function
@author   	Silvia Taguti
@since		27/06/2019
@version	1.0
@return		oView
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oMdlRJ9   := FWLoadModel( 'GPEA935' )
	// Cria a estrutura a ser usada na View
	Local oStruRJ9 := FWFormStruct( 2, 'RJ9' )
	Local oStructRJA := FWFormStruct(2,"RJA")
	Local oView

	//--------------------------------------------------------------
	//Montagem do View normal se Container
	//--------------------------------------------------------------
	oView := FWFormView():New()

	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlRJ9 )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_GPEA935', oStruRJ9, 'GPEA935_RJ9' )

	oView:AddGrid(  "GPEA935_RJA" , oStructRJA )

	oStructRJA:RemoveField( "RJA_TPINSC" )
	oStructRJA:RemoveField( "RJA_NRINSC" )
	oStructRJA:RemoveField( "RJA_INI" )

	//Retira a pasta de Orgãos Públicos
	oStruRJ9:RemoveField("RJ9_IDEEFR")
	oStruRJ9:RemoveField("RJ9_NRFER")
	oStruRJ9:RemoveField("RJ9_EFNM")
	oStruRJ9:RemoveField("RJ9_EFCMN")
	oStruRJ9:RemoveField("RJ9_EFRPPS")
	oStruRJ9:RemoveField("RJ9_EFST")
	oStruRJ9:RemoveField("RJ9_IDEEFR")
	oStruRJ9:RemoveField("RJ9_EFUF")
	oStruRJ9:RemoveField("RJ9_EFVST")
	If cVersEnvio < "9.0" .And. lDtLei
		oStruRJ9:RemoveField("RJ9_L11096")
	EndIf

	// Criar um "box" horizontal para receber algum elemento da view
	oView:createHorizontalBox("FORMFIELD",55)
	oView:createHorizontalBox("GRID"     ,45)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_GPEA935', 'FORMFIELD' )
	oView:SetOwnerView( "GPEA935_RJA","GRID")

	// Liga a identificacao do componente
	oView:EnableTitleView("VIEW_GPEA935", OemToAnsi( STR0001 )) //"Cadastro Empregador"
	oView:EnableTitleView("GPEA935_RJA", OemToAnsi( STR0056 )) //"Dados Softwarehouse

//	oView:SetCloseOnOk( { |oView| GP935ClsOk( oView ) } )

Return oView

Static Function GP935ClsOk( oView )
Local aArea      := GetArea()
Local nOperation := oView:oMdlRJ9:GetOperation()
Local oGrid      := oView:oMdlRJ9:GetModel("GPEA935_RJA")
Local nLinGrdPos := oGrid:GetLine() //Linha posicionada atualmente no Grid
Local lRet       :=  .F.
Local nX         := 0

	If nOperation == MODEL_OPERATION_UPDATE
		lRet := .T.
		For nX:=1 to oGrid:GetQtdLine()
			oGrid:GoLine( nX )
			if !oGrid:IsDeleted()
				lRet := .F.
				Exit
			EndIf
		Next nX
		oGrid:GoLine( nLinGrdPos )
	EndIf

	RestArea( aArea )
	oGrid := Nil
Return lRet

/*/{Protheus.doc}
Pos-validacao do Cadastro de Empresa
@type      	Static Function
@author   	Silvia Taguti
@since		27/06/2019
@version	1.0
@param		oMdlRJ9, object, Modelo a ser validado
@return		lRetorno
/*/

Static Function Gp935CPosVal( oMdlRJ9 )

Local lRetorno      := .T.
Local nOperation
Local cChave		:= ""

// Seta qual é a operacao corrente
	nOperation := oMdlRJ9:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .or. ( nOperation == MODEL_OPERATION_UPDATE .and. (oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_INI') + oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_TPINSC') + oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NRINSC')  <> RJ9->(RJ9_INI + RJ9_TPINSC + RJ9_NRINSC ) ))

	    cChave := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_INI') + oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_TPINSC') + oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NRINSC')
	    dbSelectArea( "RJ9" )
	    If dbSeek(xFilial("RJ9") + cChave )
	        //Atenção # Já existe um registro com a chave informada: RJ9_INI + RJ9_TPINSC + RJ9_NRINSC  # Informe uma chave não existente na base de dados.
			Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0010) + "RJ9_INI + RJ9_TPINSC + RJ9_NRINSC", 2 , 0 , , , , , , { OemToAnsi(STR0011) } )
			lRetorno := .F.
		EndIf
		If !(oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NATJ') $ "101-5/104-0/107-4/116-3") .And. oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_TPINSC') == "1"
			cChave := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_INI') + oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_TPINSC') + SubStr( oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NRINSC'), 1, 8 )
			If dbSeek(xFilial("RJ9") + cChave )
				//Atenção # Já existe um registro com a chave informada: RJ9_INI + RJ9_TPINSC + RJ9_NRINSC  # Informe uma chave não existente na base de dados.
				Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0010) + "RJ9_INI + RJ9_TPINSC + RJ9_NRINSC (Raiz)", 2 , 0 , , , , , , { OemToAnsi(STR0011) } )
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

Return lRetorno

/*/{Protheus.doc}
Commit do Cadastro de Empresa
@type      	Static Function
@author   	Silvia Taguti
@since		27/06/2019
@version	1.0
@param		oMdlRJ9, object, Modelo a ser validado
@return		lRetorno
/*/
Static Function Gp935CGrav( oMdlRJ9 )

Local lRetorno     	:= .T.
Local aArea      	:= GetArea()
Local aSaveLines 	:= FWSaveRows( oMdlRJ9 )
Local cMsgErro		:= ""
Local nOperation	:= oMdlRJ9:GetOperation()

Begin Transaction

	lRetorno := FWFormCommit( oMdlRJ9 )

	If lRetorno .And. lMiddleware .And. nOperation == MODEL_OPERATION_DELETE
		If !(lRetorno := fGeraRJE( oMdlRJ9, @cMsgErro ))
			oMdlRJ9:SetErrorMessage("",,oMdlRJ9:GetId(),"","",cMsgErro)
			DisarmTransaction()
			Break
		EndIf
	EndIf

	FWRestRows( aSaveLines, oMdlRJ9 )

	RestArea( aArea )

	aSize(aSaveLines,0)
	aSaveLines := Nil
	oGrid := Nil

End Transaction

RestArea( aArea )

Return lRetorno


/*/{Protheus.doc}
Linhao Ok Dados Softwarehouse
@type      	Static Function
@author   	Silvia Taguti
@since		02/07/2019
@version	1.0
@param		oGrid, 		object, 	Objeto da Grid a ser validada
@return		lRet,		logic
/*/

Static Function GP935LOk(oGrid)
Local lRet 	  := .T.
Local oStruct := oGrid:GetStruct()
Local aCampos := oStruct:GetFields()
Local cCNPJ	  := ''
Local nx	  := 0
Local nGrid	  := 0
Local nG	  := 0

If !oGrid:IsDeleted()
	For nx := 1 To Len(aCampos)
		If Empty(oGrid:GetValue(Trim(aCampos[nx][MODEL_FIELD_IDFIELD])))
			nGrid:=oGrid:GetLine()
			cCNPJ := Alltrim(oGrid:GetValue("RJA_CNPJ"))

			For nG := 1 To oGrid:Length()
				oGrid:GoLine( nG )
				If nGrid <> nG .And. !Empty(oGrid:GetValue("RJA_CNPJ"))
					If !oGrid:IsDeleted() .And. Alltrim(oGrid:GetValue("RJA_CNPJ")) == cCNPJ
						Help( , , OemtoAnsi(STR0007), , OemtoAnsi(STR0055), 1, 0)	// "CNPJ Informado ja foi cadastrado para outra Softwarehouse
			   			lRet := .F.
			   			Exit
					Endif
				Endif
			Next nG
			oGrid:GoLine( nGrid )
		Endif
	Next nX
	oGrid:GoLine( nGrid )
EndIf

Return lRet


/*/{Protheus.doc}
Tudo Ok do Cadastro de Empresa
@type      	Static Function
@author   	Silvia Taguti
@since		01/07/2019
@version	1.0
@param		oGrid, 		object, 	Objeto da Grid a ser validada
@param		oMdlRJ9,	object, 	Objeto do Modelo a ser validado
@return		lRet,		logic
/*/
Static Function Gp935TdOk( oGrid, oMdlRJ9 )

	Local lRet		:= .T.
	Local cMsgErro	:= ""
	Local cChave	:= ""
	Local cTpInsc   := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_TPINSC')
	Local cNrInsc   := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NRINSC')
	Local cIni  	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_INI')
	Local cNatJ  	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NATJ')
	Local cClass    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_CLASS')
	Local cCoop    	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_COOP')
	Local cCons    	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_CONS')
	Local cDeson    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_DESON')
	Local cEduc    	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_EDUC')
	Local cRItem    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_RTEM')
	Local cTemp    	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_TEMP')
	Local cIsLei    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_ISLEI')
	Local cIsNum    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_ISNUM')
	Local cIsDte    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_ISDTE')
	Local cIsVct    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_ISVCT')
	Local cIsPtc    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_ISPTC')
	Local cIsTdpt   := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_ISTDPT')
	Local cDtDou    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_DTDOU')
	Local cPagDou   := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_PAGDOU')
	Local cIdeEfr   := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_IDEEFR')
	Local cNrFer    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NRFER')
	Local cEfNm    	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_EFNM')
	Local cEfUf    	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_EFUF')
	Local cEfCmn   	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_EFCMN')
	Local cEfRpps   := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_EFRPPS')
	Local cEfSt    	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_EFST')
	Local cEfVst    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_EFVST')
	Local cOiMul    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_OIMUL')
	Local cSitPj    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_SITPJ')
	Local cSitPf    := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_SITPF')
	Local cNmCtt	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_CNM')
	Local cCpfCtt	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_CCPF')
	Local cFoneFixo	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_CFIXO')
	Local cFoneCel	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_CCEL')
	Local cEmail	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_CEMAIL')
	Local cSiafi	:= oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_SIAFI')
	Local dDtLei	:= If(lDtLei .And. cVersEnvio >= "9.0", oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_L11096'), Ctod("//"))
	Local nOper		:= oMdlRJ9:GetOperation()

	cChave := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_INI') + oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_TPINSC') +  oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NRINSC')

	If nOper == MODEL_OPERATION_INSERT .Or. (nOper == MODEL_OPERATION_UPDATE .And. cChave != RJ9->RJ9_INI + RJ9->RJ9_TPINSC + RJ9->RJ9_NRINSC)
		dbSelectArea( "RJ9" )
		If dbSeek(xFilial("RJ9") + cChave )
		//Atenção # Já existe um registro com a chave informada: RJ9_INI + RJ9_TPINSC + RJ9_NRINSC  # Informe uma chave não existente na base de dados.
		Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0010) + "RJ9_INI + RJ9_TPINSC + RJ9_NRINSC", 2 , 0 , , , , , , { OemToAnsi(STR0011) } )
		lRet := .F.
		EndIf

		If !(oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NATJ') $ "101-5/104-0/107-4/116-3") .And. oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_TPINSC') == "1"
			cChave := oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_INI') + oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_TPINSC') + SubStr( oMdlRJ9:GetValue('GPEA935_RJ9','RJ9_NRINSC'), 1, 8 )
			If dbSeek(xFilial("RJ9") + cChave )
				//Atenção # Já existe um registro com a chave informada: RJ9_INI + RJ9_TPINSC + RJ9_NRINSC  # Informe uma chave não existente na base de dados.
				Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0010) + "RJ9_INI + RJ9_TPINSC + RJ9_NRINSC (Raiz)", 2 , 0 , , , , , , { OemToAnsi(STR0011) } )
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If cTpInsc == '1'  //.And.  Substr(Alltrim(cNatJ),1,1) == '1' // Administração Publica
		If Empty(cNrInsc).Or. !(CNPJ(cNrInsc))
			Help( ,, 'HELP',,OemToAnsi(STR0016), 1, 0 )     //"Numero de Inscrição Invalida"
			lRet := .F.
		Endif
		If Empty(cSitPj) .And. cVersEnvio < "9.0.00"
			Help( ,, 'HELP',,OemToAnsi(STR0018), 1, 0 ) //Preenchimento da Situação PJ é obrigatoria
			lRet := .F.
		Endif
		If !Empty(cSitPF) .And. cVersEnvio < "9.0.00"
			Help( ,, 'HELP',,OemToAnsi(STR0019), 1, 0 ) //Situação PF não deve ser preenchida
			lRet := .F.
		Endif
		If Empty(cCons)
			Help( ,, 'HELP',,OemToAnsi(STR0058), 1, 0 ) //"O preenchimento da empresa construtora é obrigatório para PJ"

			lRet := .F.
		Endif
		If Empty(cEduc) .And. cVersEnvio < "9.0.00"
			Help( ,, 'HELP',,OemToAnsi(STR0059), 1, 0 )  //"O preenchimento da entidade educativa é obrigatória para PJ"
			lRet := .F.
		Endif

	ElseIf cTpInsc == '1' .And. Empty(cNatJ)
		Help( ,, 'HELP',,OemToAnsi(STR0017), 1, 0 )     //"Preenchimento da Natureza Juridica é obrigatorio para PJ"
		lRet := .F.
	ElseIf cTpInsc == '2'
		If Empty(cNrInsc) .OR. !(ChkCPF(cNrInsc))
			Help( ,, 'HELP',,OemToAnsi(STR0020), 1, 0 )       //CPF Invalido
			lRet := .F.
		Endif
		If !Empty(cNatJ)
			Help( ,, 'HELP',,OemToAnsi(STR0021), 1, 0 ) //Preenchimento da Natureza Juridica é obrigatorio somente para PJ
			lRet := .F.
		Endif
		If cCons == '1'
			Help( ,, 'HELP',,OemToAnsi(STR0022), 1, 0 ) //Empresa construtora invalida para o tipo de inscrição
			lRet := .F.
		Endif
		If cEduc == '2'
			Help( ,, 'HELP',,OemToAnsi(STR0023), 1, 0 )  //Entidade Educativa invalida para o tipo de inscrição
			lRet := .F.
		Endif
		If Empty(cSitPF) .And. cVersEnvio < "9.0.00"
			Help( ,, 'HELP',,OemToAnsi(STR0024), 1, 0 ) //Preenchimento da Situação PF é obrigatoria
			lRet := .F.
		Endif
		If !Empty(cSitPJ)
			Help( ,, 'HELP',,OemToAnsi(STR0025), 1, 0 )   //Situação PJ não deve ser preenchida
			lRet := .F.
		Endif
	ElseIf Empty(cTpInsc)
		Help( ,, 'HELP',,OemToAnsi(STR0026), 1, 0 ) //Tipo de Inscrição Obrigatorio
		lRet := .F.
	Endif

	If Empty(cIni)
		Help( ,, 'HELP',,OemToAnsi(STR0057), 1, 0 ) //"O preenchimento do Inicio da Validade é obrigatório"
		lRet := .F.
	Endif

	If cClass == '85'
	 	If Substr(Alltrim(cNatJ),1,1) <> '1'
	 		Help( ,, 'HELP',,OemToAnsi(STR0027), 1, 0 )  //Natureza Juridica invalida para a Classificação Tributaria 85
	 		lRet := .F.
	 	Endif
	ElseIf cClass $ "21|22" .And. !Empty(dDtLei)
			Help( ,, 'Campo Dt Lei 11096',,OemToAnsi(STR0098), 1, 0 )	//"Data de transformação em sociedade de fins lucrativos não deve ser preenchida para Classificação Tributária = 21 ou 22."
			lRet := .F.
	ElseIf cClass <> '80' .And. !Empty(cClass)
		If !Empty(cIsLei)
	 		Help( ,, 'HELP',,OemToAnsi(STR0028), 1, 0 )    //Lei da Isenção não deve ser preenchido para essa Classificação Tributaria
	 		lRet := .F.
	 	Endif
		If !Empty(cIsNum)
	 		Help( ,, 'HELP',,OemToAnsi(STR0029), 1, 0 )     //Numero Entidade Beneficente não deve ser preenchido para essa Classificação Tributaria
	 		lRet := .F.
	 	Endif
		If !Empty(cIsDte)
	 		Help( ,, 'HELP',,OemToAnsi(STR0030), 1, 0 )    //Data da Emissão da Lei não deve ser preenchido para essa Classificação Tributaria
	 		lRet := .F.
	 	Endif
		If !Empty(cIsVct)
	 		Help( ,, 'HELP',,OemToAnsi(STR0031), 1, 0 )      //Data de vencimento da Lei não deve ser preenchido para essa Classificação Tributaria
	 		lRet := .F.
	 	Endif
		If !Empty(cIsPtc)
	 		Help( ,, 'HELP',,OemToAnsi(STR0032), 1, 0 )    //Protocolo de Renovação não deve ser preenchido para essa Classificação Tributaria
	 		lRet := .F.
	 	Endif
		If !Empty(cIsTdpt)
	 		Help( ,, 'HELP',,OemToAnsi(STR0033), 1, 0 )     //Data Protocolo de Renovação não deve ser preenchido para essa Classificação Tributaria
	 		lRet := .F.
	 	Endif
		If !Empty(cDtDou)
	 		Help( ,, 'HELP',,OemToAnsi(STR0034), 1, 0 )        //Data Publicação do DOU não deve ser preenchido para essa Classificação Tributaria
	 		lRet := .F.
	 	Endif
		If !Empty(cPagDou)
	 		Help( ,, 'HELP',,OemToAnsi(STR0035), 1, 0 )     //Numero de pagina publicação não deve ser preenchido para essa Classificação Tributaria
	 		lRet := .F.
	 	Endif
	ElseIf cClass == '80'
	 	If !Empty(cIsLei) .Or. !Empty(cIsNum) .Or. !Empty(cIsDte) .Or. !Empty(cIsVct)
	 		If Empty(cIsLei) .Or. Empty(cIsNum) .Or. Empty(cIsDte) .Or. Empty(cIsVct) .Or. Empty(cIsPtc) .Or. Empty(cIsTdpt) .Or. Empty(cIsTdpt) .Or.  Empty(cDtDou) .Or. Empty(cPagDou)
	 			//Os campos de Lei da Isenção, Numero Entidade Beneficente, Data da Emissão da Lei, Data de vencimento da Lei, Protocolo de Renovação, Data Protocolo de Renovação,Data Protocolo de Renovação, Data Publicação do DOU e Numero de pagina publicação devem ser preenchidos
	 			Help( ,, 'HELP',,OemToAnsi(STR0036), 1, 0 )
	 			lRet := .F.
	 		Endif
	 	Endif
	ElseIf Empty(cClass) .And. cVersEnvio >= "9.0.00"
		Help( ,, 'HELP',,OemToAnsi(STR0067), 1, 0 ) //"O preenchimento da Classificação Tributária é obrigatório"
	Endif

	If cNatJ == '402-2' .Or. cNatJ =='412-0'
		Help( ,, 'HELP',,OemToAnsi(STR0037), 1, 0 ) //Natureza Juridica não é permitida
		lRet := .F.
	 Endif

	If Substr(Alltrim(cNatJ),1,1) <> '5' .And. (cOiMul == '2' .Or. !Empty(cOiMul) )
		Help( ,, 'HELP',,OemToAnsi(STR0038), 1, 0 ) //Acordo Internacional invalido para a Natureza Juridica
		lRet := .F.
	ElseIf Substr(Alltrim(cNatJ),1,1) == '5' .And. Empty(cOiMul)
		Help( ,, 'HELP',,OemToAnsi(STR0039), 1, 0 ) //Acordo Internacional deve ser selecionado
		lRet := .F.
	 Endif

	 If !Empty(cCoop)
	  	If cTpInsc == '2'
	 		Help( ,, 'HELP',,OemToAnsi(STR0040), 1, 0 ) //O preenchimento do campo de cooperativa é exclusivo para PJ
	 		lRet := .F.
	 	Endif
	 	If cCoop <> '0' .And. cNatJ <> '214-3'
	 		Help( ,, 'HELP',,OemToAnsi(STR0041), 1, 0 )   //Tipo de Cooperativa incompativel com para a Natureza Juridica
	 		lRet := .F.
	 	Endif
	 Endif

	 If cDeson == '1' .And. !(cClass $ '02|03|99')
 		Help( ,, 'HELP',,OemToAnsi(STR0042), 1, 0 )  //Desoneração incompatível com a Classificação Tributária
 		lRet := .F.
	 Endif

	 If cTemp == '2'
	 	If Empty(cRItem) .And. cVersEnvio < "9.0.00"
	 		Help( ,, 'HELP',,OemToAnsi(STR0043), 1, 0 )  //Número do registro da Empresa de Trabalho Temporário deve ser preenchido
	 		lRet := .F.
	 	Endif
	 Else
	 	If !Empty(cRItem)
	 		Help( ,, 'HELP',,OemToAnsi(STR0044), 1, 0 ) //Número do registro da Empresa de Trabalho Temporário não deve ser preenchido
	 		lRet := .F.
	 	Endif
	Endif

	If !(cNatJ $ '102-3|103-1|105-8|106-6|108-2|117-1|118-0|123-6|124-4')
		If !Empty(cIdeEfr) .And. cVersEnvio < "9.0.00"
	 		Help( ,, 'HELP',,OemToAnsi(STR0045), 1, 0 ) //Ente Federativo Responsavel deve ser preenchido somente para as Naturezas Juridicas: 102-3,103-1,105-8,106-6,108-2,117-1,118-0,123-6 e 124-4"
	 		lRet := .F.
	 	Endif
		If !Empty(cNrFer)
	 		Help( ,, 'HELP',,OemToAnsi(STR0046), 1, 0 ) //"Identificação do Ente Federativo Responsavel deve ser preenchido somente para as Naturezas Juridicas: 102-3,103-1,105-8,106-6,108-2,117-1,118-0,123-6 e 124-4"
	 		lRet := .F.
	 	Endif
		If !Empty(cEfNm)
	 		Help( ,, 'HELP',,OemToAnsi(STR0047), 1, 0 ) //"Nome do Ente Federativo deve ser preenchido somente para as Naturezas Juridicas: 102-3,103-1,105-8,106-6,108-2,117-1,118-0,123-6 e 124-4"
	 		lRet := .F.
	 	Endif
		If !Empty(cEfUf)
	 		Help( ,, 'HELP',,OemToAnsi(STR0048), 1, 0 ) //Unidade da Federação deve ser preenchido somente para as Naturezas Juridicas: 102-3,103-1,105-8,106-6,108-2,117-1,118-0,123-6 e 124-4"
	 		lRet := .F.
	 	Endif
		If !Empty(cEfCmn)
	 		Help( ,, 'HELP',,OemToAnsi(STR0049), 1, 0 ) //Codigo do Municipio deve ser preenchido somente para as Naturezas Juridicas: 102-3,103-1,105-8,106-6,108-2,117-1,118-0,123-6 e 124-4"
	 		lRet := .F.
	 	Endif
		If !Empty(cEfRpps)
	 		Help( ,, 'HELP',,OemToAnsi(STR0050), 1, 0 ) //Regime Próprio de Previdência Social - RPPS deve ser preenchido somente para as Naturezas Juridicas: 102-3,103-1,105-8,106-6,108-2,117-1,118-0,123-6 e 124-4"
	 		lRet := .F.
	 	Endif
		If !Empty(cEfSt)
	 		Help( ,, 'HELP',,OemToAnsi(STR0051), 1, 0 ) //Identificação do Sub-teto deve ser preenchido somente para as Naturezas Juridicas: 102-3,103-1,105-8,106-6,108-2,117-1,118-0,123-6 e 124-4"
	 		lRet := .F.
	 	Endif
		If !Empty(cEfVst)
	 		Help( ,, 'HELP',,OemToAnsi(STR0052), 1, 0 ) //Valor do Sub-teto deve ser preenchido somente para as Naturezas Juridicas: 102-3,103-1,105-8,106-6,108-2,117-1,118-0,123-6 e 124-4"
	 		lRet := .F.
	 	Endif
	Else
		If (Empty(cIdeEfr) .Or. Empty(cEfNm).Or. Empty(cEfUf) .Or. Empty(cEfRpps) .Or. Empty(cEfSt) .Or. Empty(cEfVst) ) .And. cVersEnvio < "9.0.00"
	 		Help( ,, 'HELP',,OemToAnsi(STR0053), 1, 0 )
	 		//"Os campos: Ente Federativo Responsavel, Identificação do Ente Federativo Responsavel, Nome do Ente Federativo, Unidade da Federação, Regime Próprio de Previdência Social - RPPS, Identificação do Sub-teto e Valor do Sub-teto são obrigatorios para a Natureza Juridica selecionada"
	 		lRet := .F.
	 	Endif
	 	If cIdeEfr == '2' .And. Empty(cNrFer)
	 		Help( ,, 'HELP',,OemToAnsi(STR0054), 1, 0 ) //Nome do Ente Federativo deve ser preenchido
	 		lRet := .F.
	 	Endif
		If Empty(cSiafi) .And. cNatJ $ ("101-5/104-0/107-4/116-3") .And. cVersEnvio < "9.0.00"
 			Help( ,, 'HELP',,OemToAnsi(STR0073), 1, 0 ) //"O preenchimento do numero do SIAFI é obrigatório"
 			lRet := .F.
 		Endif
	Endif

 	If Empty(cNmCtt) .And. cVersEnvio < "9.0.00"
 		Help( ,, 'HELP',,OemToAnsi(STR0068), 1, 0 ) //"O preenchimento do Nome do Contato é obrigatorio"
 		lRet := .F.
 	Endif
 	If Empty(cCpfCtt) .And. cVersEnvio < "9.0.00"
 		Help( ,, 'HELP',,OemToAnsi(STR0069), 1, 0 ) //"O preenchimento do CPF do contato é obrigatório"
 		lRet := .F.
 	Endif
 	If Empty(cFoneFixo) .And. cVersEnvio < "9.0.00"
 		Help( ,, 'HELP',,OemToAnsi(STR0070), 1, 0 ) //"O preenchimento do telefone é obrigatório"
 		lRet := .F.
 	Endif
 	If Empty(cFoneCel) .And. cVersEnvio < "9.0.00"
 		Help( ,, 'HELP',,OemToAnsi(STR0071), 1, 0 ) //"O preenchimento do numero do celular é obrigatório"
 		lRet := .F.
 	Endif
 	If Empty(cEmail) .And. cVersEnvio < "9.0.00"
 		Help( ,, 'HELP',,OemToAnsi(STR0072), 1, 0 ) //"O preenchimento do e-mail do contato é obrigatório"
 		lRet := .F.
 	Endif

	If lRet .And. lMiddleware
		If !(lRet := fGeraRJE( oMdlRJ9, @cMsgErro ))
			Help( ,, 'HELP',,cMsgErro, 1, 0 )
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGeraRJE
Função que gera o XML do S-1000
@author  Allyson Mesashi
@since   16/07/2019
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function fGeraRJE( oModel, cMsgErro )

Local aArea			:= GetArea()
Local aDados		:= {}
Local aSM0    		:= FWLoadSM0(.T.,,.T.)
Local cId			:= ""
Local cTpInsc		:= ""
Local cNrInsc		:= ""
Local cIni			:= ""
Local cNmRazao  	:= ""
Local cClass  		:= ""
Local cNatJ  		:= ""
Local cCoop    		:= ""
Local cCons    		:= ""
Local cDeson    	:= ""
Local cPonto    	:= ""
Local cEduc    		:= ""
Local cTemp    		:= ""
Local cRItem    	:= ""
Local cIsLei    	:= ""
Local cIsNum    	:= ""
Local dIsDte    	:= cToD("//")
Local dIsVct    	:= cToD("//")
Local cIsPtc    	:= ""
Local dIsTdpt   	:= cToD("//")
Local dDtDou    	:= cToD("//")
Local cPagDou   	:= ""
Local cNmCtt		:= ""
Local cCpfCtt		:= ""
Local cFoneFixo		:= ""
Local cFoneCel		:= ""
Local cEmail		:= ""
Local cSiafi		:= ""
Local cIdeEfr   	:= ""
Local cNrFer    	:= ""
Local cEfNm    		:= ""
Local cEfUf    		:= ""
Local cEfCmn   		:= ""
Local cEfRpps   	:= ""
Local cEfSt    		:= ""
Local nEfVst    	:= 0
Local cOiMul    	:= ""
Local cSitPj    	:= ""
Local cSitPf    	:= ""
Local cChaveBus		:= ""
Local cFilEmp		:= ""
Local cHrGer		:= Time()
Local cOperNew		:= "I"
Local cOperOld		:= "I"
Local cOperRJE		:= "I"
Local cRetfNew		:= "1"
Local cRetfOld		:= "1"
Local cRetfRJE		:= "1"
Local cSeqId		:= "00001"
Local cStatNew		:= "1"
Local cStatOld		:= "-1"
Local cStatRJE		:= "-1"
Local cXml			:= ""
Local dDtGer		:= Date()
Local lAdmPubl		:= .F.
Local lNovoRJE		:= .F.
Local lRet			:= .T.
Local nCont			:= 0
Local nFilEmp		:= 0
Local nLinGrid		:= 0
Local nOpcao		:= 3
Local nOperation	:= 0
Local nRecOld		:= 0
Local nRecRJE		:= 0
Local oGrid			:= Nil
Local cGpeAmbe		:= ""
Local dDtLei		:= cToD("//")

Default oModel 		:= Nil
Default cMsgErro	:= ""

If ValType(oModel) != "U"
	fVersEsoc( "S1000", .F., Nil, Nil, Nil, Nil, @cVersEnvio,, @cGpeAmbe )
	nOperation	:= oModel:GetOperation()
	oGrid		:= oModel:GetModel("GPEA935_RJA")
	nLinGrid	:= oGrid:Length()

	cNatJ  		:= AllTrim(StrTran( oModel:GetValue('GPEA935_RJ9','RJ9_NATJ'), "-", ""))
	lAdmPubl	:= cNatJ $ ("1015/1040/1074/1163/1341")
	cTpInsc 	:= oModel:GetValue('GPEA935_RJ9','RJ9_TPINSC')
	If cTpInsc == "1" .And. !lAdmPubl
		cNrInsc := SubStr( oModel:GetValue('GPEA935_RJ9','RJ9_NRINSC'), 1, 8 )
	Else
		cNrInsc := oModel:GetValue('GPEA935_RJ9','RJ9_NRINSC')
	EndIf
	If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == AllTrim(oModel:GetValue('GPEA935_RJ9','RJ9_NRINSC')) }) ) > 0
		cFilEmp := aSM0[nFilEmp, 2]
	Else
		cFilEmp := If(empty(RJ9->RJ9_FILIAL),cFilAnt,RJ9->RJ9_FILIAL)
	EndIf

	cId	 		:= "ID"+cTpInsc+Iif( cTpInsc == "1" .And. !lAdmPubl, PadR(SubStr(cNrInsc, 1, 8), 14, "0"), cNrInsc )+dToS(dDtGer)+StrTran(cHrGer, ":", "")+cSeqId
	cIni 		:= oModel:GetValue('GPEA935_RJ9','RJ9_INI')
	cNmRazao	:= oModel:GetValue('GPEA935_RJ9','RJ9_NOME')
	cClass  	:= oModel:GetValue('GPEA935_RJ9','RJ9_CLASS')
	cCoop    	:= oModel:GetValue('GPEA935_RJ9','RJ9_COOP')
	cCons    	:= oModel:GetValue('GPEA935_RJ9','RJ9_CONS')
	cDeson    	:= oModel:GetValue('GPEA935_RJ9','RJ9_DESON')
	cPonto    	:= oModel:GetValue('GPEA935_RJ9','RJ9_PONTO')
	cEduc    	:= oModel:GetValue('GPEA935_RJ9','RJ9_EDUC')
	cTemp    	:= oModel:GetValue('GPEA935_RJ9','RJ9_TEMP')
	cRItem    	:= oModel:GetValue('GPEA935_RJ9','RJ9_RTEM')
	cIsLei    	:= oModel:GetValue('GPEA935_RJ9','RJ9_ISLEI')
	cIsNum    	:= oModel:GetValue('GPEA935_RJ9','RJ9_ISNUM')
	dIsDte    	:= oModel:GetValue('GPEA935_RJ9','RJ9_ISDTE')
	dIsVct    	:= oModel:GetValue('GPEA935_RJ9','RJ9_ISVCT')
	cIsPtc    	:= oModel:GetValue('GPEA935_RJ9','RJ9_ISPTC')
	dIsTdpt   	:= oModel:GetValue('GPEA935_RJ9','RJ9_ISTDPT')
	dDtDou    	:= oModel:GetValue('GPEA935_RJ9','RJ9_DTDOU')
	cPagDou   	:= oModel:GetValue('GPEA935_RJ9','RJ9_PAGDOU')
	cNmCtt		:= oModel:GetValue('GPEA935_RJ9','RJ9_CNM')
	cCpfCtt		:= oModel:GetValue('GPEA935_RJ9','RJ9_CCPF')
	cFoneFixo	:= oModel:GetValue('GPEA935_RJ9','RJ9_CFIXO')
	cFoneCel	:= oModel:GetValue('GPEA935_RJ9','RJ9_CCEL')
	cEmail		:= oModel:GetValue('GPEA935_RJ9','RJ9_CEMAIL')
	cSiafi		:= oModel:GetValue('GPEA935_RJ9','RJ9_SIAFI')
	cIdeEfr   	:= oModel:GetValue('GPEA935_RJ9','RJ9_IDEEFR')
	cNrFer    	:= oModel:GetValue('GPEA935_RJ9','RJ9_NRFER')
	cEfNm    	:= oModel:GetValue('GPEA935_RJ9','RJ9_EFNM')
	cEfUf    	:= oModel:GetValue('GPEA935_RJ9','RJ9_EFUF')
	cEfCmn   	:= oModel:GetValue('GPEA935_RJ9','RJ9_EFCMN')
	cEfRpps   	:= oModel:GetValue('GPEA935_RJ9','RJ9_EFRPPS')
	cEfSt    	:= oModel:GetValue('GPEA935_RJ9','RJ9_EFST')
	nEfVst    	:= oModel:GetValue('GPEA935_RJ9','RJ9_EFVST')
	cOiMul    	:= oModel:GetValue('GPEA935_RJ9','RJ9_OIMUL')
	cSitPj    	:= oModel:GetValue('GPEA935_RJ9','RJ9_SITPJ')
	cSitPf    	:= oModel:GetValue('GPEA935_RJ9','RJ9_SITPF')
	If lDtLei .And. cVersEnvio >= "9.0"
		dDtLei	:= oModel:GetValue('GPEA935_RJ9','RJ9_L11096')
	EndIf

	cChaveBus := cTpInsc + PadR(cNrInsc, 14, " ") + "S1000" + Padr(cFilEmp, fTamRJEKey(), " ") + cIni
	GetInfRJE( 2, cChaveBus, @cStatRJE, @cOperRJE, @cRetfRJE, @nRecRJE )
	If nOperation == MODEL_OPERATION_UPDATE
		cChaveBus := cTpInsc + PadR(cNrInsc, 14, " ") + "S1000" + Padr(cFilEmp, fTamRJEKey(), " ") + RJ9->RJ9_INI
		GetInfRJE( 2, cChaveBus, @cStatOld, @cOperOld, @cRetfOld, @nRecOld )
		If cStatOld $ "1/3"
			cStatRJE := cStatOld
			cOperRJE := cOperRJE
			cRetfRJE := cRetfOld
			nRecRJE  := nRecOld
		EndIf
	EndIf

	//Alteração ou exclusão
	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
		//Retorno pendente impede o cadastro
		If cStatRJE == "2" .Or. cStatOld == "2"
			cMsgErro 	:= STR0061//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
			lRet		:= .F.
		EndIf
		If cStatOld == "4" .And. RJ9->RJ9_INI != cIni
			cMsgErro 	:= STR0061//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
			lRet		:= .F.
		EndIf
		//Alteração
		If nOperation == MODEL_OPERATION_UPDATE
			//Evento de exclusão sem transmissão impede o cadastro
			If cOperRJE == "E" .And. cStatRJE != "4"
				cMsgErro 	:= STR0064//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
				lRet		:= .F.
			//Não existe na fila, será tratado como inclusão
			ElseIf cStatRJE == "-1"
				nOpcao 		:= 3
				cOperNew 	:= "I"
				cRetfNew	:= "1"
				cStatNew	:= "1"
				lNovoRJE	:= .T.
			//Evento sem transmissão, irá sobrescrever o registro na fila
			ElseIf cStatRJE $ "1/3"
				If cOperRJE == "A"
					nOpcao 	:= 4
				EndIf
				cOperNew 	:= cOperRJE
				cRetfNew	:= cRetfRJE
				cStatNew	:= "1"
				lNovoRJE	:= .F.
			//Evento diferente de exclusão transmitido, irá gerar uma retificação
			ElseIf cOperRJE != "E" .And. cStatRJE == "4"
				nOpcao 		:= 4
				cOperNew 	:= "A"
				cRetfNew	:= "2"
				cStatNew	:= "1"
				lNovoRJE	:= .T.
			//Evento de exclusão transmitido, será tratado como inclusão
			ElseIf cOperRJE == "E" .And. cStatRJE == "4"
				nOpcao 		:= 3
				cOperNew 	:= "I"
				cRetfNew	:= "1"
				cStatNew	:= "1"
				lNovoRJE	:= .T.
			EndIf
		//Exclusão
		ElseIf nOperation == MODEL_OPERATION_DELETE
			nOpcao 		:= 5
			//Evento de exclusão sem transmissão impede o cadastro
			If cOperRJE == "E" .And. cStatRJE != "4"
				cMsgErro 	:= STR0064//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
				lRet		:= .F.
			//Evento diferente de exclusão transmitido irá gerar uma exclusão
			ElseIf cOperRJE != "E" .And. cStatRJE == "4"
				cOperNew 	:= "E"
				cRetfNew	:= cRetfRJE
				cStatNew	:= "1"
				lNovoRJE	:= .T.
			EndIf
		EndIf
	ElseIf nOperation == MODEL_OPERATION_INSERT
		//Retorno pendente impede o cadastro
		If cStatRJE == "2"
			cMsgErro 	:= STR0061//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
			lRet		:= .F.
		//Evento de exclusão sem transmissão impede o cadastro
		ElseIf cOperRJE == "E" .And. cStatRJE != "4"
			cMsgErro 	:= STR0064//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
			lRet		:= .F.
		//Evento sem transmissão, irá sobrescrever o registro na fila
		ElseIf cStatRJE $ "1/3"
			nOpcao		:= Iif( cOperRJE == "I", 3, 4 )
			cOperNew 	:= cOperRJE
			cRetfNew	:= cRetfRJE
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		//Evento diferente de exclusão transmitido, irá gerar uma retificação
		ElseIf cOperRJE != "E" .And. cStatRJE == "4"
			cOperNew 	:= "A"
			cRetfNew	:= "2"
			cStatNew	:=  "1"
			lNovoRJE	:= .T.
		//Será tratado como inclusão
		Else
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		EndIf
	EndIf

	If lRet
		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtInfoEmpregador/v" + cVersEnvio + "'>"
		cXML += 	"<evtInfoEmpregador Id='" + cId + "'>"
		fXMLIdEve( @cXML, { Nil, Nil, Nil, Nil, cGpeAmbe, 1, "12" } )
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
		cXML += 		"<infoEmpregador>"
		If nOpcao == 3
			cXML += 		"<inclusao>"
		ElseIf nOpcao == 4
			cXML += 		"<alteracao>"
		Else
			cXML += 		"<exclusao>"
		EndIf
		cXML += 				"<idePeriodo>"
		cXML += 					"<iniValid>" + SubStr(cIni, 1, 4) + "-" + SubStr(cIni, 5, 2) + "</iniValid>"
		cXML += 				"</idePeriodo>"
		If nOpcao != 5
			cXML += 			"<infoCadastro>"
			If cVersEnvio < "9.0.00"
				cXML += 			"<nmRazao>" + If(Findfunction("GPENorStrES"), GPENorStrES(Alltrim(cNmRazao)), Alltrim(cNmRazao))  + "</nmRazao>"
			EndIf
			cXML += 				"<classTrib>" + cClass + "</classTrib>"
			If !Empty(cNatJ) .And. cVersEnvio < "9.0.00"
				cXML += 			"<natJurid>" + cNatJ + "</natJurid>"
			EndIf
			If !Empty(cCoop)
				cXML += 			"<indCoop>" + cCoop + "</indCoop>"
			EndIf
			If !Empty(cCons)
				cXML += 			"<indConstr>" + cCons + "</indConstr>"
			EndIf
			cXML += 				"<indDesFolha>" + cDeson + "</indDesFolha>"
			cXML += 				"<indOptRegEletron>" + cPonto + "</indOptRegEletron>"
			If !Empty(cEduc) .And. cVersEnvio < "9.0.00"
				cXML += 			"<indEntEd>" + Iif(cEduc == "1", "N", "S") + "</indEntEd>"
			EndIf
			If cVersEnvio < "9.0.00"
				cXML += 			"<indEtt>" + Iif(cTemp == "1", "N", "S") + "</indEtt>"
			EndIf
			If !Empty(cRItem) .And. cVersEnvio < "9.0.00"
				cXML += 			"<nrRegEtt>" + cRItem + "</nrRegEtt>"
			EndIf
			If cVersEnvio >= "9.0.00" .And. !Empty(dDtLei)
				cXML += 			"<dtTrans11096>" + SubStr( dToS(dDtLei), 1, 4 ) + "-" + SubStr( dToS(dDtLei), 5, 2 ) + "-" + SubStr( dToS(dDtLei), 7, 2 ) + "</dtTrans11096>"
			EndIf
			If !Empty(cIsNum)
				cXML += 			"<dadosIsencao>"
				cXML += 				"<ideMinLei>" + cIsLei + "</ideMinLei>"
				cXML += 				"<nrCertif>" + cIsNum + "</nrCertif>"
				cXML += 				"<dtEmisCertif>" + SubStr( dToS(dIsDte), 1, 4 ) + "-" + SubStr( dToS(dIsDte), 5, 2 ) + "-" + SubStr( dToS(dIsDte), 7, 2 ) + "</dtEmisCertif>"
				cXML += 				"<dtVencCertif>" + SubStr( dToS(dIsVct), 1, 4 ) + "-" + SubStr( dToS(dIsVct), 5, 2 ) + "-" + SubStr( dToS(dIsVct), 7, 2 ) + "</dtVencCertif>"
				If !Empty(cIsPtc)
					cXML += 			"<nrProtRenov>" + cIsPtc + "</nrProtRenov>"
				EndIf
				If !Empty(dIsTdpt)
					cXML += 			"<dtProtRenov>" + SubStr( dToS(dIsTdpt), 1, 4 ) + "-" + SubStr( dToS(dIsTdpt), 5, 2 ) + "-" + SubStr( dToS(dIsTdpt), 7, 2 ) + "</dtProtRenov>"
				EndIf
				If !Empty(dDtDou)
					cXML += 			"<dtDou>" + SubStr( dToS(dDtDou), 1, 4 ) + "-" + SubStr( dToS(dDtDou), 5, 2 ) + "-" + SubStr( dToS(dDtDou), 7, 2 ) + "</dtDou>"
				EndIf
				If !Empty(cPagDou)
					cXML += 			"<pagDou>" + cPagDou + "</pagDou>"
				EndIf
				cXML += 			"</dadosIsencao>"
			EndIf
			If cVersEnvio < "9.0.00"
				cXML += 				"<contato>"
				cXML += 					"<nmCtt>" + Alltrim(cNmCtt) + "</nmCtt>"
				cXML += 					"<cpfCtt>" + cCpfCtt + "</cpfCtt>"
				If !Empty(cFoneFixo)
					cXML += 				"<foneFixo>" + Alltrim(cFoneFixo) + "</foneFixo>"
				EndIf
				If !Empty(cFoneCel)
					cXML += 				"<foneCel>" + Alltrim(cFoneCel) + "</foneCel>"
				EndIf
				If !Empty(cEmail)
					cXML += 				"<email>" + Alltrim(cEmail) + "</email>"
				EndIf
				cXML += 				"</contato>"
			EndIf
			If !Empty(cSiafi) .And. cVersEnvio < "9.0.00"
				cXML += 			"<infoOP>"
				cXML += 				"<nrSiafi>" + cSiafi + "</nrSiafi>"
				If !Empty(cIdeEfr)
					cXML += 				"<infoEFR>"
					cXML += 					"<ideEFR>" + Iif(cIdeEfr == "1", "S", "N") + "</ideEFR>"
					If !Empty(cNrFer)
						cXML += 				"<cnpjEFR>" + cNrFer + "</cnpjEFR>"
					EndIf
					cXML += 				"</infoEFR>"
				EndIf
				If !Empty(cEfNm)
					cXML += 			"<infoEnte>"
					cXML += 				"<nmEnte>" + cEfNm + "</nmEnte>"
					cXML += 				"<uf>" + cEfUf + "</uf>"
					If !Empty(cEfCmn)
						cXML += 			"<codMunic>" + cEfCmn + "</codMunic>"
					EndIf
					cXML += 				"<indRPPS>" + Iif(cEfRpps == "1", "S", "N") + "</indRPPS>"
					cXML += 				"<subteto>" + cEfSt + "</subteto>"
					cXML += 				"<vrSubteto>" + AllTrim(Str(nEfVst)) + "</vrSubteto>"
					cXML += 			"</infoEnte>"
				EndIF
				cXML += 			"</infoOP>"
			EndIf
			If !Empty(cOiMul)
				cXML += 				"<infoOrgInternacional>"
				cXML += 					"<indAcordoIsenMulta>" + cOiMul + "</indAcordoIsenMulta>"
				cXML += 				"</infoOrgInternacional>"
			EndIf

			If cVersEnvio < "9.0.00"
				For nCont := 1 To nLinGrid
					oGrid:GoLine(nCont)
					If !oGrid:IsDeleted() .And. !Empty(oGrid:GetValue('RJA_CNPJ'))
						cXML +=			"<softwareHouse>"
						cXML += 			"<cnpjSoftHouse>" + oGrid:GetValue('RJA_CNPJ') + "</cnpjSoftHouse>"
						cXML += 			"<nmRazao>" + If(Findfunction("GPENorStrES"), GPENorStrES(oGrid:GetValue('RJA_NOME')), oGrid:GetValue('RJA_NOME')) + "</nmRazao>"
						cXML += 			"<nmCont>" + oGrid:GetValue('RJA_CONTA') + "</nmCont>"
						cXML += 			"<telefone>" + oGrid:GetValue('RJA_TELEF') + "</telefone>"
						If !Empty(oGrid:GetValue('RJA_EMAIL'))
							cXML += 		"<email>" + oGrid:GetValue('RJA_EMAIL') + "</email>"
						EndIf
						cXML +=			"</softwareHouse>"
					EndIf
				Next nCont
			Endif
			If cVersEnvio < "9.0.00"
				cXML += 				"<infoComplementares>"
				If !Empty(cSitPj)
					cXML += 				"<situacaoPJ>"
					cXML += 					"<indSitPJ>" + cSitPj + "</indSitPJ>"
					cXML += 				"</situacaoPJ>"
				EndIf
				If !Empty(cSitPf)
					cXML += 				"<situacaoPF>"
					cXML += 					"<indSitPF>" + cSitPf + "</indSitPF>"
					cXML += 				"</situacaoPF>"
				EndIf
				cXML += 				"</infoComplementares>"
			EndIf

			If !Empty(cNrFer) .And. cVersEnvio >= "9.0.00"
				cXML += 			"<cnpjEFR>" + cNrFer + "</cnpjEFR>"
			EndIf

			cXML += 			"</infoCadastro>"
			If nOpcao == 3
				cXML += 	"</inclusao>"
			ElseIf nOpcao == 4
				cXML += 	"</alteracao>"
			EndIf
		Else
			cXML += 		"</exclusao>"
		EndIf
		cXML += 		"</infoEmpregador>"
		cXML += 	"</evtInfoEmpregador>"
		cXML += "</eSocial>"

		aAdd( aDados, { xFilial("RJE", cFilEmp), cFilEmp, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1000", cIni, cFilEmp, cId, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew } )
		GrvTxtArq(cXml, "S1000")
		//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
		If !( nOpcao == 5 .And. ((cOperRJE == "E" .And. cStatRJE == "4") .Or. cStatRJE $ "-1/1/3") )
			If !( lRet := fGravaRJE( aDados, cXml, lNovoRJE, nRecRJE ) )
				cMsgErro := STR0062//"Ocorreu um erro na gravação do registro na tabela RJE"
			EndIf
		//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
		ElseIf nOpcao == 5 .And. cStatRJE != "-1" .And. !(cOperRJE == "E" .And. cStatRJE == "4")
			If !( lRet := fExcluiRJE( nRecRJE ) )
				cMsgErro := STR0063//"Ocorreu um erro na exclusão do registro na tabela RJE"
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} function fVldCTrib
Função que valida o codigo da classificação tributária informado no campo RJ9_CLASS.

@author  Silvio C. Stecca
@since   29/12/2020
@version V 1.0

/*/
//-------------------------------------------------------------------
Function fVldCTrib()

	Local lCodOk	:= .T.
	Local aArea		:= GetArea()
	Local cArqRCC	:= GetNextAlias()
	Local cWhere	:= ""
	Local cCodRCC	:= "S135"
	Local cNameDB	:= Alltrim(Upper(TcGetDb()))

	If !Empty(M->RJ9_CLASS)
		cWhere := "% RCC.RCC_FILIAL = '" + xFilial("RCC") + "'"
		cWhere += " AND RCC.RCC_CODIGO = '" + cCodRCC + "'"

		If cNameDB $ "ORACLE"
			cWhere += " AND SUBSTR(RCC.RCC_CONTEU, 1, 2) = '" + M->RJ9_CLASS + "'"
		Else
			cWhere += " AND SUBSTRING(RCC.RCC_CONTEU, 1, 2) = '" + M->RJ9_CLASS + "'"
		EndIf

		cWhere += " AND RCC.D_E_L_E_T_ = ' '"
		cWhere += " %"

		BeginSql alias cArqRCC
			SELECT RCC_CODIGO, RCC_CONTEU
			FROM %table:RCC% RCC
			WHERE %exp:cWhere%
		EndSql

		If (cArqRCC)->(Eof())
			Help(,, "CLASSTRIB",, + CRLF + OemToAnsi(STR0065), 1, 0,,,,,, {+ CRLF + OemToAnsi(STR0066)})
			lCodOk := .F.
		Endif

		// FECHA O ARQUIVO TEMPORARIO CRIADO.
		(cArqRCC)->(dbCloseArea())

		// RESTAURA O AMBIENTE SALVO.
		RestArea(aArea)
	EndIf

Return lCodOk

//-------------------------------------------------------------------
/*/{Protheus.doc} function fAtuCred
Função responsável pela atualização das credenciais
@author  lidio.oliveira
@since   28/09/2021
@version V 1.0
/*/
//-------------------------------------------------------------------
Function fAtuCred()

	Local aArea		:= GetArea()
	Local aButtons  := {}
	Local aSays     := {}
	Local nOpcA     := 0
	Local cLink		:= 'https://tdn.totvs.com/x/mQJKJg'

	Private aLog    := {}
	Private aTitle  := {}
	Private aPerg   := {}

	aAdd(aSays,OemToAnsi(STR0074)) //"Este programa tem como objetivo atualizar as credencias do TSS em caso de utilização"
	aAdd(aSays,OemToAnsi(STR0075)) //"de Token. A possibilidade de uso de Token está disponível apenas na release 12.1.33 "
	aAdd(aSays,OemToAnsi(STR0076)) //"do TSS, portanto, caso não esteja nesta versão do TSS não é preciso executar esta rotina,"
	aAdd(aSays,OemToAnsi(STR0077)) //"caso faça uso deste recurso consulte nossa documentação."

	aAdd(aButtons, { 14,.T.,{|| ShellExecute("Open",cLink,"","",1) } } )
	aAdd(aButtons, { 5,.T.,{|| fParam(@aPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	//Abre a tela de processamento
	FormBatch(OemToAnsi(STR0079), aSays, aButtons )

	//Efetua o processamento
	If nOpcA == 1
		If len(aPerg) == 0
			MsgInfo(OemToAnsi(STR0080)) //Parâmetros não foram preenchidos
			Return
		EndIf
		Aadd( aTitle, OemToAnsi(STR0081)) ////CNPJ`s atualizados com as credenciais informadas:
		Aadd( aLog, {} )
		ProcGpe( {|lEnd| fProcessa()},,,.T. )
		fMakeLog(aLog,aTitle,,,OemToAnsi(STR0082),OemToAnsi(STR0083),"M","P",,.F.)
	EndIf

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} function fProcessa
Função responsável pelo processamento das credenciais
@author  lidio.oliveira
@since   28/09/2021
@version V 1.0
/*/
//-------------------------------------------------------------------
Static Function fProcessa()

	Local cAliasQry := GetNextAlias()
	Local aArea		:= GetArea()
	Local cWhere    := ""
	Local cMsg      := ""
	Local lNovoRJ0	:= .F.
	Local lGravou	:= .F.

	If Empty(aPerg[1,3]) .Or. Empty(aPerg[1,4])
		cMsg := OemToAnsi(STR0084) //"ClientId e Client Secret não foram informados, verifique os parâmetros preenchidos."
		MsgInfo( cMsg )
		Return()
	EndIf

	//CNPJ inicial
	cWhere += "RJ9_NRINSC >= '" + aPerg[1,1] + "' "

	//CNPJ Final
	cWhere += "AND RJ9_NRINSC <= '" + aPerg[1,2] + "' "

	//Prepara a variável para uso no BeginSql
	cWhere := "%" + cWhere + "%"

	//Processa a query e cria a tabela temporária com os resultados da RJ9
	BeginSql alias cAliasQry
		SELECT RJ9.RJ9_FILIAL, RJ9.RJ9_TPINSC, RJ9.RJ9_NRINSC, RJ9.RJ9_INI, RJ9.RJ9_NOME
		FROM %table:RJ9% RJ9
		WHERE %exp:cWhere% AND
        RJ9.%notDel%
	EndSql

	//Processa as filiais para gravação das credenciais
	While (cAliasQry)->( !EoF() )

		lGravou	:= .F.

		//Posicona a tabela RJ9 no indice 4 RJ9_TPINSC+RJ9_NRINSC+RJ9_INI
    	RJ9->( dbSetOrder(4) )

		//Posicona no registro da RJ9
		If RJ9->( dbSeek( (cAliasQry)->RJ9_TPINSC + (cAliasQry)->RJ9_NRINSC + (cAliasQry)->RJ9_INI ) )
			//Trava o registro na RJ9 para edição
			If RJ9->( RecLock("RJ9", .F.) )
				RJ9->RJ9_CLIENT := aPerg[1,3]
				RJ9->RJ9_SECRET	:= aPerg[1,4]
			RJ9->( MsUnlock() )
			lGravou := .T.
			EndIf
		EndIf

		//Posicona a tabela RJ0 no indice 1 RJ0_FILIAL+RJ0_TPINSCl+RJ0_NRINSC
    	RJ0->( dbSetOrder(1) )

		//Verifica se deve ser incluído um novo registro:
    	lNovoRJ0 := RJ0->( !dbSeek( xFilial("RJ0") + aPerg[1,3] + aPerg[1,4]) )

		//Trava o registro na RJ0 para edição
        If RJ0->( RecLock("RJ0", lNovoRJ0) )
            RJ0->RJ0_CLIENT	:= aPerg[1,3]
            RJ0->RJ0_SECRET	:= aPerg[1,4]
            RJ0->( MsUnlock() )
			lGravou := .T.
        EndIf

		//Adiciona no log de ocorrências
		If lGravou
        	aAdd( aLog[1], OemToAnsi(STR0085) + alltrim(RJ9->RJ9_NOME) + OemToAnsi(STR0086) + If(RJ9->RJ9_TPINSC == "1", OemToAnsi(STR0087), OemToAnsi(STR0088)) + RJ9->RJ9_NRINSC)
		EndIf

		//Pula para o próximo registro
    	(cAliasQry)->( dbSkip() )
	EndDo

	//Fecha a tabela temporária da query
	(cAliasQry)->( dbCloseArea() )

	//Se o log não foi gravado significa que não foram encontrados registros para processamento
	If Empty(aLog[1]) .And. !lGravou
		aAdd( aLog[1], OemToAnsi(STR0089)) //"Não foram encontrados registros para processamento."
	EndIf

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fParam
Cria tela com perguntes
@author  lidio.oliveira
@since   28/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fParam(aParam)

	Local aAdvSize      := {}
	Local aInfoAdvSize  := {}
	Local aObjCoords    := {}
	Local aObjSize      := {}
	Local cCNPJDE       := Space(14)
	Local cCNPJATE      := cCNPJDE
	Local cClient       := Space(40)
	Local cSecret       := Space(200)
	Local bSet15		:= { || nOpcA := 1, oDlg:End() }
	Local bSet24		:= { || nOpca := 2, oDlg:End() }
	Local lOk           := .T.
	Local nOpcA			:= 0
	Local oCNPJ
	Local oClient
	Local oSecret

	Default aParam      := {}

	aAdvSize		:= MsAdvSize()
	aAdvSize[6]	:=	200	//Vertical
	aAdvSize[5]	:=  1200//horizontal
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )

	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM aAdvSize[7], 0 TO aAdvSize[6], aAdvSize[5] TITLE OemToAnsi(STR0090) OF oMainWnd PIXEL

	@ aObjSize[1][1],aObjSize[1][2] 	SAY STR0094	 SIZE 050,10  FONT oFont OF oDlg PIXEL //"CNPJ/CPF de:"
	@ aObjSize[1][1],aObjSize[1][2]+80	MSGET oCNPJ VAR cCNPJDE   SIZE 100,10 OF oDlg PIXEL

	@ aObjSize[2][1],aObjSize[2][2] 	SAY STR0095 SIZE 050,10  FONT oFont OF oDlg PIXEL //"CNPJ/CPF Até:"
	@ aObjSize[2][1],aObjSize[2][2]+80	MSGET oCNPJ VAR cCNPJATE  SIZE 100,10 OF oDlg PIXEL

	@ aObjSize[3][1],aObjSize[3][2] 	SAY STR0096 SIZE 050,10  FONT oFont OF oDlg PIXEL //"Client Id:"
	@ aObjSize[3][1],aObjSize[3][2]+80	MSGET oClient VAR cClient  SIZE 150,10 OF oDlg PIXEL

	@ aObjSize[4][1],aObjSize[4][2] 	SAY STR0097 SIZE 050,10  FONT oFont OF oDlg PIXEL //"Client Secret:"
	@ aObjSize[4][1],aObjSize[4][2]+80	MSGET oSecret VAR cSecret  SIZE 510,10 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24) CENTERED

	If nOpcA == 2
		Return
	Else
		// Tratamento dos parâmetros preenchidos
		If (Empty(cClient) .Or. Empty(cSecret)) .And. lOk
			Aviso( OemtoAnsi(STR0091) , OemtoAnsi(STR0092),	{ OemtoAnsi(STR0093) } )
			lOk := .F.
		EndIf

		If lOk
			aAdd(aParam,{cCNPJDE, cCNPJATE, cClient, cSecret})
		EndIf
	EndIf
Return
