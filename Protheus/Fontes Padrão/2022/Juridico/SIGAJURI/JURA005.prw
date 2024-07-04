#INCLUDE "JURA005.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA005
Comarca Juridica

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA005()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias("NQ6")
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NQ6" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL
//-------------------------------------------------------------------
/*
Chamado TSSQMY - adicionado esse comentário para compilar o fonte para ver se
atualiza o CH's STR0009 e STR0010, depois esse cometário pode ser retirado.
*/

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

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA005", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA005", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA005", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA005", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA005", 0, 8, 0, NIL } ) //"Imprimir"
	aAdd( aRotina, { STR0021, "JA005CFG()", 0, 3, 0, NIL } ) //"Utilizar Cadastro CNJ"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Comarca Juridica

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FwLoadModel( "JURA005" )
Local oStructNQ6
Local oStructNQC
Local oStructNQE
Local oStructNY3
Local oView

//--------------------------------------------------------------
//Montagem da interface via dicionario de dados
//--------------------------------------------------------------
oStructNQ6 := FWFormStruct( 2, "NQ6" )
oStructNQC := FWFormStruct( 2, "NQC" )
oStructNQE := FWFormStruct( 2, "NQE" )
oStructNY3 := FWFormStruct( 2, "NY3" )

oStructNQC:RemoveField( "NQC_CCOMAR" )
oStructNQE:RemoveField( "NQE_CLOC2N" )
oStructNY3:RemoveField( "NY3_CLOC3N" )	// Remove o campo "NY3_CLOC3N" da visualização do grid para o usuario

//--------------------------------------------------------------
//Montagem do View normal se Container
//--------------------------------------------------------------
JurSetAgrp( 'NQ6',, oStructNQ6 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:SetDescription( STR0007 ) //"Comarca Juridica"

oView:AddField( "JURA005_COMARCA" 	, oStructNQ6	, "NQ6MASTER" )

oView:AddGrid(  "JURA005_2NIVEL"  	, oStructNQC	, "NQC2NIVEL"  )
oView:AddGrid(  "JURA005_3NIVEL"  	, oStructNQE	, "NQE3NIVEL"  )
oView:AddGrid(  "JURA005_NY3DETAIL", oStructNY3	, "NY3DETAIL"  )

oView:CreateHorizontalBox( "FORMCOMARCA" 	, 10 )
oView:CreateHorizontalBox( "FORM2NIVEL"  	, 35 )
oView:CreateHorizontalBox( "FORM3NIVEL"  	, 35 )

oView:CreateHorizontalBox( "FORMNY3DETAIL", 20 )

oView:SetOwnerView( "NQ6MASTER" , "FORMCOMARCA" )
oView:SetOwnerView( "NQC2NIVEL" , "FORM2NIVEL"  )
oView:SetOwnerView( "NQE3NIVEL" , "FORM3NIVEL"  )
oView:SetOwnerView( "NY3DETAIL" , "FORMNY3DETAIL" )

oView:AddIncrementField( "NQC2NIVEL" , "NQC_COD"  )
oView:AddIncrementField( "NQE3NIVEL" , "NQE_COD"  )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

oView:EnableTitleView( "JURA005_2NIVEL"	)
oView:EnableTitleView( "JURA005_NY3DETAIL")
oView:EnableTitleView( "JURA005_3NIVEL"		)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Comarca Juridica

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0

@obs NQ6MASTER - Cabecalho Comarca Juridica / NQCDETAIL - Itens Comarca Juridica
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructNQ6 := NIL
Local oStructNQC := NIL
Local oStructNQE := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNQ6 := FWFormStruct(1,"NQ6")
oStructNQC := FWFormStruct(1,"NQC")

oStructNY3 := FWFormStruct(1,"NY3")
oStructNQE := FWFormStruct(1,"NQE")

oStructNQC:RemoveField( "NQC_CCOMAR" )
oStructNQE:RemoveField( "NQE_CLOC2N" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MpFormModel():New( "JURA005", /*Pre-Validacao*/, /*Pos-Validacao*/,{|oX|JA005Commit(oX)}/*Commit*/ )
oModel:SetDescription( STR0007 ) //"Modelo de Dados da Comarca Juridica"

oModel:AddFields( "NQ6MASTER", /*cOwner*/, oStructNQ6,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "NQ6MASTER" ):SetDescription( STR0008 ) //"Cabecalho Comarca Juridica"

// NQC - Localização 2º Nivel
oModel:AddGrid( "NQC2NIVEL", "NQ6MASTER" /*cOwner*/, oStructNQC, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NQC2NIVEL"  ):SetDescription( STR0009 ) //"Itens Comarca Juridica"
oModel:SetRelation( "NQC2NIVEL", { { "NQC_FILIAL", "XFILIAL('NQC')" }, { "NQC_CCOMAR", "NQ6_COD" } }, NQC->( IndexKey( 1 ) ) )

// NQE - Localização 3º Nivel
oModel:AddGrid( "NQE3NIVEL", "NQC2NIVEL" /*cOwner*/, oStructNQE, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NQE3NIVEL"  ):SetDescription( STR0010 ) //"Itens Comarca Juridica"
oModel:SetRelation( "NQE3NIVEL", { { "NQE_FILIAL", "XFILIAL('NQE')" }, { "NQE_CLOC2N", "NQC_COD" } }, NQE->( IndexKey( 1 ) ) )

// NY3 - SubVara
oModel:AddGrid( "NY3DETAIL", "NQE3NIVEL" /*cOwner*/, oStructNY3, {|oX|JA005VGrdNY3(oX)} /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NY3DETAIL"  ):SetDescription( STR0011 )  //"Cadastro de Subvara"
oModel:SetRelation( "NY3DETAIL", { { "NY3_FILIAL", "XFILIAL('NY3')" }, { "NY3_CLOC3N", "NQE_COD" } }, NY3->( IndexKey( 1 ) ) )

oModel:GetModel( "NQC2NIVEL" ):SetUniqueLine( { "NQC_COD" } )
oModel:GetModel( "NQE3NIVEL" ):SetUniqueLine( { "NQE_COD" } )
oModel:GetModel( "NY3DETAIL" ):SetUniqueLine( { "NY3_COD" } )
oModel:GetModel( "NQE3NIVEL" ):SetDelAllLine( .T. )


oModel:SetOptional( "NQE3NIVEL" , .T. )
oModel:SetOptional( "NY3DETAIL" , .T. )

JurSetRules( oModel, 'NQ6MASTER',, 'NQ6' )
JurSetRules( oModel, 'NQC2NIVEL',, 'NQC' )
JurSetRules( oModel, 'NQE3NIVEL',, 'NQE' )
JurSetRules( oModel, 'NY3DETAIL',, 'NY3' )

oModel:SetOnDemand()


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA005Commit
Commit de dados de Comarca Jurídica

@author Jorge Luis Branco Martins Junior
@since 17/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA005Commit(oModel)
Local lRet := .T.
Local cCod := ""
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)

	If nOpc == 3 .And. !IsInCallStack('J005IncCom')// Se for Inclusão e não for da rotina automática de inclusão de comarca CNJ
		cCod := oModel:GetValue("NQ6MASTER","NQ6_COD")
		lRet := JurSetRest('NQ6',cCod)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA005VGrdNY3
Valida o grid da NY3.
 O Grid de NY3 (Cadastro subvara) só poderá estar preenchido se o
 Grid NQE (localização 3º NIvel)estiver populado.

@author Rafael Rezende Costa
@since 10/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA005VGrdNY3(oModel)
Local lRet 				:= .T.
Local aArea        := GetArea()
Local aAreaNQC 	  := NQC->( GetArea() )
Local aAreaNQE 	  := NQE->( GetArea() )
Local aAreaNY3
Local aSaveLines  := FWSaveRows()  									    // Guarda a posicão dos grids
Local oModel2 	    := FwModelActive() 							     // Model Ativo
Local oModelNQE   := oModel2:GetModel("NQE3NIVEL")	// Informações sobre o grid de NQE (3º Nível)

aAreaNY3 := NY3->( GetArea() )

	DO CASE
	 // Verifica se a descrição do 3º Nível não esta deletada
	 Case oModel2:GetModel("NQE3NIVEL"):IsDeleted()
		  JurMsgErro(STR0012) 			 //"É necessário que o grid do 3º nível esteja preenchido para cadastrar as subvara(s) !"
			lRet := .F.

	 // Verifica se o campo esta preenchido e se não esta deletada.
	 Case Empty(Alltrim(oModelNQE:GetValue("NQE_DESC"))) .and. !oModel2:GetModel("NQE3NIVEL"):IsDeleted()
		  JurMsgErro(STR0012)			  //"É necessário que o grid do 3º nível esteja preenchido para cadastrar as subvara(s) !"
			lRet := .F.

	 OTHERWISE
			lRet := .T.
	ENDCASE

FWRestRows( aSaveLines ) // Restaura os posicionamentos

// Restura a posição dos ponteiros da tabela
RestArea( aArea )
RestArea( aAreaNQC )
RestArea( aAreaNQE )

RestArea( aAreaNY3 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA005NY3()
Filtra consulta padrão de localização de 4. nivel conforme localização de 3. nivel
Uso no cadastro de Instância.

@Return cRet	 	Comando para filtro
@#JURA005NY3()

@author Rafael Rezende Costa
@since 12/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA005NY3()
Local aArea        := GetArea()
Local aSaveLines  := FWSaveRows()
Local	 oModel		    := FwModelActive()  // Tela Ativa
Local oModelNQE	  := oModel:GetModel( "NQE3NIVEL" )
local cCodNQE		  := oModelNQE:GetValue("NQE_COD")
Local cRet 		   	:= "@#@#"

If !Empty(Alltrim(cCodNQE))
	cRet := "@#NY3->NY3_CLOC3N == '"+ cCodNQE +"'@#"
EndIf

RestArea( aArea )
FWRestRows( aSaveLines )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA005CFG()
Rotina que faz a chamada do processamento da carga inicial

@author Jorge Luis Branco Martins Junior
@since 04/08/16
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA005CFG()
Local oWS       := JURA222():New()
Local oComarca  := Nil
Local oMascara  := Nil
Local lCod      := .T. // Indica se os campos de código da comarca, 2º nível e 3º nível serão preenchidos com os valores vindos do BPO. Isso só acontecerá se NÃO existirem máscaras e comarcas
Local lSeek     := .F. // Indica se será necessário realizar busca de descrições de comarca, 2º nível e 3º nível para incluir somente registros novos. Quando NÃO existir nenhuma comarca não será necessário fazer essa busca.
Local lO00InDic := FWAliasInDic("O00")
Local nQtdComar := 0
Local nQtdLoc2N := 0
Local nQtdLoc3N := 0
Local nQtdTotal := 0
Local lRet      := .T.

	If oWS <> NIL

		DbSelectArea("NQ6")
		NQ6->( DbGoTop() )

		//Existem dados no cadastro de comarca?
		If NQ6->(Eof()) // Não

			// Baixar dados do Web Service criado no JURA222 (Tabelas O00, NQ6, NQC e NQE)

			// Obtem os registros de comarcas CNJ
			Processa( {|| oComarca := J005BusCom(oWs)} , STR0013, STR0014, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Iniciando busca de comarcas'
			If oComarca <> NIL
				// Inclui comarcas
				Processa( {|| J005IncCom(oComarca) } , STR0013, STR0015, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Iniciando atualização de comarcas'
			EndIf

			If lRet .And. lO00InDic

				DbSelectArea("O00")
				O00->( DbGoTop() )

				// Obtem os registros de máscaras CNJ
				Processa( {|| oMascara := J226BusMas(oWs) } , STR0013, STR0016, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Gerando...'
				If oMascara <> NIL
					// Inclui máscaras
					Processa( {|| J226IncMas(oMascara) } , STR0013, STR0017, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Gerando...'
				EndIf

			EndIf

		Else // Sim

			If lO00InDic

				lCod := .T. // Como já existem comarcas não poderá usar o código vindo do BPO, terá que usar a numeração do sistema

				DbSelectArea("O00")
				O00->( DbSetOrder(1) )	//O00_FILIAL+O00_MASCAR
				O00->( DbGoTop() )

				//Existem dados no cadastro de máscaras?
				If O00->(Eof()) // Não existem dados no cadastro de máscaras
					Processa( {|| oMascara := J226BusMas(oWs) } , STR0013, STR0016, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Gerando...'

					If oMascara <> NIL
						Processa( {|| J226IncMas(oMascara) } , STR0013, STR0017, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Gerando...'
					EndIf

					MsgAlert(STR0018) // 'Preencha o cadastro De/Para Comarca para completar o cadastro local!'

				Else // Sim, existem dados no cadastro de máscaras

					aQtd := J226LocMas()
					nQtdComar := aQtd[1]
					nQtdLoc2N := aQtd[2]
					nQtdLoc3N := aQtd[3]
					nQtdTotal := aQtd[4]

					// Registros estão todos localizados?
					If nQtdTotal > 0 .And. nQtdComar == 0 .And. nQtdLoc2N == 0 .And. nQtdLoc3N == 0 // Sim, estão todos localizados

						lSeek := .T. // Como já existem comarcas será necessário fazer essa busca.
						lProc := .T.

						// Obtem novos registros de comarcas CNJ
						Processa( {|| oComarca := J005BusCom(oWs)} , STR0013, STR0014, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Iniciando busca de comarcas'
						If oComarca <> NIL
							// Inclui comarcas
							Processa( {|| J005IncCom(oComarca) } , STR0013, STR0015, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Gerando...'
						EndIf

						// Obtem novos registros de máscaras CNJ
						Processa( {|| oMascara := J226BusMas(oWs) } , STR0013, STR0016, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Iniciando busca de máscaras'
						If oMascara <> NIL
							// Inclui máscaras
							Processa( {|| J226IncMas(oMascara) } , STR0013, STR0017, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Iniciando atualização de máscaras'
						EndIf

					Else // Não estão todos localizados

						// Obtem novos registros de máscaras CNJ
						Processa( {|| oMascara := J226BusMas(oWs) } , STR0013, STR0016, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Gerando...'
						If oMascara <> NIL
							// Inclui máscaras
							Processa( {|| J226IncMas(oMascara) } , STR0013, STR0017, .F. ) // 'Aguarde... Esse procedimento pode demorar alguns minutos', 'Gerando...'
							MsgAlert(STR0018) // 'Preencha o cadastro De/Para Comarca para completar o cadastro local!'
						EndIf

					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J005BusCom(oWs)
Obtem os registros de comarcas, com suas localizações de 2º e 3º nível

@Param oWs Objeto que contem dados do WebService - WSCOMARCA

@Return oLista Lista de comarcas

@author Jorge Luis Branco Martins Junior
@since 29/07/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J005BusCom(oWs)
Local aArea       := GetArea()
Local oLista      := {}
Local cUsuario    := SuperGetMV('MV_JINDUSR',, '')

	ProcRegua(0)
	IncProc()

	If oWS <> NIL

		IncProc(STR0019)//'Buscando comarcas'

		oWS:cUsuario := cUsuario

		oWS:MTAllComarcas()
		If oWS:oWSMTALLCOMARCASRESULT != Nil
			oLista := oWS:oWSMTALLCOMARCASRESULT:oWSSTRUDADOSCOMARCA
		EndIf

		oWs:oWSMTCOMARCASRESULT := NIL
		oWS := Nil

	EndIf

RestArea( aArea )

Return oLista

//-------------------------------------------------------------------
/*/{Protheus.doc} J005IncCom(oWS, oComarca, lCod, lSeek)
Inclui comarcas

@Param oWS       Objeto que contem dados do WebService - WSCOMARCA
@Param oComarca Objeto que contem dados das comarcas
@Param lCod     Indica se os campos de código da comarca, 2º nível e
				  3º nível serão preenchidos com os valores vindos do BPO.
				  Isso só acontecerá se NÃO existirem máscaras e comarcas
@Param lSeek    Indica se será necessário realizar busca de descrições
				  de comarca, 2º nível e 3º nível para incluir somente
				  registros novos. Quando NÃO existir nenhuma comarca não
				  será necessário fazer essa busca.

@Return

@author Jorge Luis Branco Martins Junior
@since 03/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J005IncCom(oComarca)

Local oModel     := FWLoadModel( "JURA005" )
Local oModelNQ6  := oModel:GetModel( "NQ6MASTER" )
Local oModelNQC  := oModel:GetModel( "NQC2NIVEL" )
Local oModelNQE  := oModel:GetModel( "NQE3NIVEL" )
Local lRet       := .T.
Local cCod       := ""
Local cDesc      := ""
Local cUF        := ""
Local nI         := 0
Local oLoc2N     := Nil
Local oStruNQ6   := oModelNQ6:GetStruct()
Local oStruNQC   := oModelNQC:GetStruct()
Local oStruNQE   := oModelNQE:GetStruct()
Local aComExist  := {}
Local nOpc       := 3

	// Ajuste nas Propriedades
	oStruNQ6:SetProperty("NQ6_COD", MODEL_FIELD_INIT, {|| NIL })
	oStruNQC:SetProperty("NQC_COD", MODEL_FIELD_INIT, {|| NIL })
	oStruNQE:SetProperty("NQE_COD", MODEL_FIELD_INIT, {|| NIL })

	oStruNQ6:SetProperty("NQ6_COD", MODEL_FIELD_VALID, {|| .T. })
	oStruNQC:SetProperty("NQC_COD", MODEL_FIELD_VALID, {|| .T. })
	oStruNQE:SetProperty("NQE_COD", MODEL_FIELD_VALID, {|| .T. })

	oStruNQ6:SetProperty("NQ6_UF"    , MODEL_FIELD_VALID, {|| .T. })

	nQtd := Len(oComarca)

	ProcRegua(0)
	IncProc()

	// Atualiza o GetSxeNum
	J005CorNum()

	// Loop para inclusão das Comarcas
	For nI := 1 to nQtd
		IncProc( I18N( STR0020,{ AllTrim(str(nI)) , AllTrim(str(nQtd)) } ) ) // "Atualizando comarcas #1 de #2"

		// Inicializa as variaveis
		nOpc       := 3
		cCod      := AllTrim(oComarca[nI]:cCODIGO)
		cDesc     := AllTrim(oComarca[nI]:cDESCRICAO)
		cUF       := AllTrim(oComarca[nI]:cUF)
		aComExist := J005Comarca( cDesc ,cUF, cCod) // Verificando se existe alguma Comarca com o mesmo código e mesma UF

		// Se não encontrou a Comarca com o Código e Descrição correspondente, busca pela Descrição dentro da UF
		If Empty(aComExist[1])
			aComExist := J005Comarca(cDesc, cUF)
		EndIf

		// Se encontrou, vai alterar
		If !Empty(aComExist[1])
			nOpc       := 4
			cCod       := aComExist[1]

			// Posiciona no Registro da tabela
			JSeekNQ6(cCod)
		Else
			If JFindNQ6(cCod)
				cCod := GetSxeNum("NQ6","NQ6_COD")
			EndIf
		EndIf

		oModel:SetOperation( nOpc )
		oModel:Activate()

		// Se for um novo, informa o ID
		If Empty(aComExist[1])
			oModel:LoadValue("NQ6MASTER", "NQ6_COD" , cCod  )
		EndIf

		oModel:SetValue("NQ6MASTER", "NQ6_DESC", cDesc )
		oModel:SetValue("NQ6MASTER", "NQ6_UF"  , cUF   )

		// Busca itens da localização de 2º nível
		oLoc2N := oComarca[nI]:oWSDadosLoc2N:oWSStruDadosLoc2N

		If oLoc2N <> Nil .And. Len(oLoc2N) > 0
			// Inclui itens da localização de 2º nível
			lRet := J005IncL2N(oLoc2N, @oModel, cCod)
		EndIf

		// Se tudo foi incluso, realiza a Validação e o Commit
		If lRet
			If oModel:VldData()
				oModel:CommitData()
			Else
				lRet := .F.
			EndIf
		EndIf

		oModel:DeActivate()
	Next

	// Atualiza o proximo ID da Comarca
	J005CorNum(nQtd)

	oModel:Destroy()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J005IncL2N()
Inclui localizações de 2º nível

@Param oWS          Objeto que contem dados do WebService - WSCOMARCA
@Param oLoc2N       Objeto que contem dados da localização de 2º nível
@Param oModel       Modelo de dados ativo
@Param cCodComarca Código da comarca em que o 2º nível está localizado
@Param lSeek       Indica se será necessário realizar busca de descrições
					 de comarca, 2º nível e 3º nível para incluir somente
					 registros novos. Quando NÃO existir nenhuma comarca não
					 será necessário fazer essa busca.
@Param lCod         Indica se os campos de código da comarca, 2º nível e
					 3º nível serão preenchidos com os valores vindos do BPO.
					 Isso só acontecerá se NÃO existirem máscaras e comarcas

@Return lRet Indica se a inclusão das localizações de 2º nível foi feita
			  com sucesso

@author Jorge Luis Branco Martins Junior
@since 03/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J005IncL2N(oLoc2N,oModel,cCodComarca)

Local lRet    := .T.
Local nQtd    := Len(oLoc2N)
Local cCod    := ""
Local cDesc   := ""
Local cEnd    := ""
Local nI      := 0
Local nC      := 0
Local oLoc3N  := Nil

	// Loop de Foros
	For nI := 1 to nQtd

		// Inicializa as variáveis
		cCod    := AllTrim(oLoc2N[nI]:cCODIGO)
		cDesc   := AllTrim(oLoc2N[nI]:cDESCRICAO)
		cEnd    := AllTrim(oLoc2N[nI]:cENDERECO)

		// Verifica se encontra o Foro pela descrição dentro da Comarca
		aForoExist := J005Loc2N(cDesc,cCodComarca,/*cCodForo*/)

		// Se encontrar, posiciona na Linha do Grid
		If !Empty(aForoExist[1])

			cCod  := aForoExist[1]
			cEnd  := aForoExist[4]

			// Loop para posicionar pelo Código
			For nC := 1 To oModel:GetModel("NQC2NIVEL"):Length()
				If ((oModel:GetModel("NQC2NIVEL"):GetValue("NQC_COD",nC) == cCod) .And. (!oModel:GetModel("NQC2NIVEL"):IsDeleted(nC)))
					oModel:GetModel("NQC2NIVEL"):GoLine(nC)
				EndIf
			Next
		Else
			// Verifica se existe algum Foro com o ID informado
			If JFindNQC(cCod)
				// Se houve, busca o proximo ID disponivel
				cCod := GetSxeNum("NQC","NQC_COD")
			EndIf

			// Verifica as seguintes Condições:
			//   Se for uma nova comarca, a 1ª linha do grid não estará preenchida, logo não deve incluir nova linha
			//   Se for uma comarca antiga inclui uma nova linha
			If nI <= nQtd .And. Empty(aForoExist[1]) .And. nI > 1
				oModel:GetModel("NQC2NIVEL"):AddLine()
			ElseIf nI == 1 .And. !Empty(oModel:GetModel("NQC2NIVEL"):GetValue("NQC_COD",1))
				oModel:GetModel("NQC2NIVEL"):AddLine()
			Endif

			oModel:LoadValue("NQC2NIVEL", "NQC_COD"   , cCod  )
		EndIf

		// Altera os dados
		oModel:SetValue("NQC2NIVEL", "NQC_DESC"   , cDesc   )
		oModel:SetValue("NQC2NIVEL", "NQC_ENDERE" , cEnd    )

		// Busca itens da localização de 3º nível
		oLoc3N := oLoc2N[nI]:oWSDadosLoc3N:oWSStruDadosLoc3N

		If oLoc3N <> Nil .And. Len(oLoc3N) > 0
			// Inclui itens da localização de 3º nível
			lRet := J005IncL3N(oLoc3N,@oModel,cCod)
		EndIf

	Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J005IncL3N
Inclui localizações de 3º nível

@Param oWS          Objeto que contem dados do WebService - WSCOMARCA
@Param oLoc3N       Objeto que contem dados da localização de 3º nível
@Param oModel       Modelo de dados ativo
@Param cCodLoc2N   Código da localização de 2º nível em que o 3º nível
					 está localizado
@Param lSeek       Indica se será necessário realizar busca de descrições
					 de comarca, 2º nível e 3º nível para incluir somente
					 registros novos. Quando NÃO existir nenhuma comarca não
					 será necessário fazer essa busca.
@Param lCod         Indica se os campos de código da comarca, 2º nível e
					 3º nível serão preenchidos com os valores vindos do BPO.
					 Isso só acontecerá se NÃO existirem máscaras e comarcas

@Return lRet Indica se a inclusão das localizações de 3º nível foi feita
			  com sucesso

@author Jorge Luis Branco Martins Junior
@since 03/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J005IncL3N(oLoc3N,oModel,cCodLoc2N)

Local lRet    := .T.
Local nQtd    := Len(oLoc3N)
Local cCod    := ""
Local cDesc   := ""
Local nI      := 0
Local nC      := 0

	// Loop das Vara
	For nI := 1 to nQtd

		// Inicializa a variável
		cCod    := AllTrim(oLoc3N[nI]:cCODIGO)
		cDesc   := AllTrim(oLoc3N[nI]:cDESCRICAO)

		// Verifica se há Vara com a descrição vinda do XML
		aVaraExist := J005Loc3N(cDesc, /*cCodVara*/, cCodLoc2N)

		// Se encontrar, vai posicionar na Linha pelo Código que foi encontrado
		If !Empty(aVaraExist[1])
			cCod  := aVaraExist[1]
			cDesc := aVaraExist[2]

			For nC := 1 To oModel:GetModel("NQE3NIVEL"):Length()
				If ((oModel:GetModel("NQE3NIVEL"):GetValue("NQE_COD",nC) == cCod) .And. (!oModel:GetModel("NQE3NIVEL"):IsDeleted(nC)))
					oModel:GetModel("NQE3NIVEL"):GoLine(nC)
				EndIf
			Next
		Else
			// Verifica se o ID está em uso
			If JFindNQE(cCod)
				// Se estiver, vai pegar o proximo ID disponivel
				cCod := GetSxeNum("NQE","NQE_COD")
			EndIf

			// Verifica as seguintes Condições:
			//   Se for um novo foro, a 1ª linha do grid não estará preenchida, logo não deve incluir nova linha
			//   Se for um foro antigo inclui uma nova linha
			If nI <= nQtd .And. Empty(aVaraExist[1]) .And. nI > 1
				oModel:GetModel("NQE3NIVEL"):AddLine()
			ElseIf nI == 1 .And. !Empty(oModel:GetModel("NQE3NIVEL"):GetValue("NQE_COD",1))
				oModel:GetModel("NQE3NIVEL"):AddLine()
			EndIf

			oModel:LoadValue("NQE3NIVEL", "NQE_COD"  , cCod  )
		EndIf

		// Informa a Descrição da Vara
		oModel:SetValue("NQE3NIVEL", "NQE_DESC" , cDesc )
	Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J005Comarca
Retorna o código da comarca caso seja identificada a descrição e UF

@param  cComDescri Descrição da comarca pesquisada
@param  cUF       UF da comarca para pesquisada

@return cCod     Código da comarca localizada (retorna em branco caso
				   não encontre)

@author Jorge Luis Branco Martins Junior
@since  08/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J005Comarca(cComDescri, cUF, cCodComarc)
Local aArea := GetArea()
Local cSQL  := ""

Local cNQ6Sql

Default cComDescri := ""
Default cUF        := ""
Default cCodComarc       := ""


	cComDescri := AllTrim( StrTran( Lower( JurLmpCpo(cComDescri) ), "#", " ") )

	cSQL := " SELECT NQ6.NQ6_COD, NQ6.NQ6_DESC, NQ6.NQ6_UF "
	cSQL +=  " FROM " + RetSqlName("NQ6") + " NQ6 "
	cSQL += "  WHERE NQ6.D_E_L_E_T_ = ' ' "
	cSQL +=    " AND NQ6.NQ6_FILIAL = '" + xFilial("NQ6") + "' "

	If !Empty(cCodComarc)
		cSQL += " AND NQ6_COD = '"+ cCodComarc +"' "
	EndIf

	If !Empty(cComDescri)
		cSQL += " AND " + JurFormat("NQ6_DESC", .T./*lAcentua*/, .T./*lPontua*/,,.T.) + " = '" + PADR(cComDescri, TamSx3('NQ6_DESC')[1]) + "' "
	Endif

	If !Empty(cUF)
		cSQL += " AND NQ6.NQ6_UF = '" + cUF + "' "
	Endif

	cSQL := ChangeQuery(cSQL)
	cSQL := StrTran(cSQL, "' '' '", "''''")

	cNQ6Sql := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cNQ6Sql,.T.,.T.)

	cCodComarc := ""

	If (cNQ6Sql)->(!Eof())
		cCodComarc := Alltrim((cNQ6Sql)->NQ6_COD)
		cComDescri := Alltrim((cNQ6Sql)->NQ6_DESC)
		cUF        := Alltrim((cNQ6Sql)->NQ6_UF)
	EndIf

	(cNQ6Sql)->(dbCloseArea())

	RestArea( aArea )

Return {cCodComarc,cComDescri,cUF}

//-------------------------------------------------------------------
/*/{Protheus.doc} J005Loc2N
Retorna o código da localização de 2º nível caso seja identificada
a descrição

@param  cDesLoc2N       Descrição da localização de 2º nível pesquisada
@param  cCodComarca Código da comarca em que está sendo pesquisada a
					  localização de 2º nível

@return cCod     Código da localização de 2º nível localizada (retorna
				   em branco caso não encontre)

@author Jorge Luis Branco Martins Junior
@since  08/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J005Loc2N(cDesLoc2N,cCodComarca, cCodLoc2N)
Local aArea   := GetArea()
Local cSQL    := ""
Local cEndere := ""

Local cNQCSql

Default cDesLoc2N   := ""
Default cCodComarca := ""
Default cCodLoc2N   := ""
	If !Empty(cDesLoc2N)

		cDesLoc2N  := AllTrim( StrTran( Lower( JurLmpCpo(cDesLoc2N)  ), "#", " ") )

		cSQL := " SELECT NQC.NQC_COD, NQC.NQC_CCOMAR, NQC.NQC_DESC, NQC.NQC_ENDERE "
		cSQL +=   " FROM " + RetSqlName("NQC") + " NQC "
		cSQL +=  " WHERE NQC.D_E_L_E_T_ = ' ' "
		cSQL +=    " AND NQC.NQC_FILIAL = '" + xFilial("NQC") + "' "

		If !Empty(cCodLoc2N)
			cSQL += " AND NQC.NQC_COD = '" + cCodLoc2N + "'"
		EndIf

		If !Empty(cCodComarca)
			cSQL +=  " AND NQC.NQC_CCOMAR = '" + cCodComarca + "' "
		EndIf

		If !Empty(cDesLoc2N)
			cSQL +=  " AND " + JurFormat("NQC_DESC", .T./*lAcentua*/, .T./*lPontua*/,,.T.) + " LIKE '%" + PADR(cDesLoc2N, TamSx3('NQC_DESC')[1]) + "%' "
		EndIf

		cSQL := ChangeQuery(cSQL)
		cNQCSql := GetNextAlias()
		cSQL := StrTran(cSQL, "' '' '", "''''")

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cNQCSql,.T.,.T.)

		If (cNQCSql)->(!Eof())
			cCodComarca := AllTrim((cNQCSql)->NQC_CCOMAR)
			cCodLoc2N   := Alltrim((cNQCSql)->NQC_COD)
			cDesLoc2N   := AllTrim((cNQCSql)->NQC_DESC)
			cEndere     := AllTrim((cNQCSql)->NQC_ENDERE)
		EndIf

		(cNQCSql)->(dbCloseArea())

	EndIf

	RestArea( aArea )

Return {cCodLoc2N, cDesLoc2N, cCodComarca, cEndere }

//-------------------------------------------------------------------
/*/{Protheus.doc} J005Loc3N
Retorna o código da localização de 3º nível caso seja identificada
a descrição

@param  cLoc3N       Descrição da localização de 3º nível pesquisada
@param  cCodLoc2N   Código da localização de 2º nível em que está
					  sendo pesquisada a localização de 3º nível

@return cCod     Código da localização de 3º nível localizada (retorna
				   em branco caso não encontre)

@author Jorge Luis Branco Martins Junior
@since  08/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J005Loc3N(cDesLoc3N, cCodLoc3N, cCodLoc2N)
Local aArea   := GetArea()
Local cSQL    := ""
Local cNQESql := ""

Default cDesLoc3N := ""
Default cCodLoc2N := ""
Default cCodLoc3N := ""

	If !Empty(cDesLoc3N)

		cDesLoc3N  := AllTrim( StrTran( Lower( JurLmpCpo(cDesLoc3N)  ), "#", " ") )

		cSQL := " SELECT NQE.NQE_COD, NQE.NQE_DESC, NQE.NQE_CLOC2N "
		cSQL +=   " FROM " + RetSqlName("NQE") + " NQE "
		cSQL +=  " WHERE NQE.D_E_L_E_T_ = ' ' "
		cSQL +=    " AND NQE.NQE_FILIAL = '" + xFilial("NQE") + "' "

		If !Empty(cCodLoc2N)
			cSQL +=  " AND NQE.NQE_CLOC2N = '" + cCodLoc2N + "' "
		EndIf

		If !Empty(cDesLoc3N)
			cSQL +=  " AND " + JurFormat("NQE_DESC", .T./*lAcentua*/, .T./*lPontua*/,, .T.) + " = '" + PADR(cDesLoc3N, TamSx3('NQE_DESC')[1]) + "' "
		Endif

		If !Empty(cCodLoc3N)
			cSQL += " AND NQE.NQE_COD = '" + cCodLoc3N + "' "
		EndIf

		cSQL := ChangeQuery(cSQL)
		cSQL := StrTran(cSQL, "' '' '", "''''")

		cNQESql := GetNextAlias()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cNQESql,.T.,.T.)

		If (cNQESql)->(!Eof())
			cCodLoc3N := Alltrim((cNQESql)->NQE_COD)
			cCodLoc2N := Alltrim((cNQESql)->NQE_CLOC2N)
			cDesLoc3N := Alltrim((cNQESql)->NQE_DESC)
		EndIf

		(cNQESql)->(dbCloseArea())
	EndIf

	RestArea( aArea )

Return {cCodLoc3N , cDesLoc3N ,cCodLoc2N}

//-------------------------------------------------------------------
/*/{Protheus.doc} J005CorNum
Função para adequar a numeração de comarca, localização de 2º e 3º
nível

@Param nNumNQ6 Último número usado no cadastro de comarcas

@Return

@author Jorge Luis Branco Martins Junior
@since 16/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J005CorNum(nNumNQ6)
Local aArea     := GetArea()
Local cNumNQC   := ''
Local cNumNQE   := ''

Default nNumNQ6 := 0

	// Quantidade de Varas cadastradas
	cNumNQC := JTotLoc2N()[2]

	// Quantidade de Foros cadastrados
	cNumNQE := JTotLoc3N()[2]

	// Atualiza a numeração das tabelas
	While val(GetSxeNum("NQ6","NQ6_COD")) < nNumNQ6
		ConfirmSX8()
	End

	While GetSxeNum("NQC","NQC_COD") < cNumNQC
		ConfirmSX8()
	End

	While GetSxeNum("NQE","NQE_COD") < cNumNQE
		ConfirmSX8()
	End

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JTotLoc2N(cComarca)
Total de Foros.

@Param cComarca - Código da Comarca, se for realizado filtro

@Return [nNumNQC] - Contagem de Foros
		[nMaxNQC] - ID maximo do Foro

@since 24/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTotLoc2N(cComarca)
Local cQrySql    := NIL
Local nNumNQC    := 0
Local nMaxNQC    := 0
Local cSQL       := ""

Default cComarca := ""

	cSQL := " SELECT COUNT(*) LOC2N, COALESCE(MAX(NQC_COD),'0') MAXCOD "
	cSQL +=   " FROM " + RetSqlName("NQC") + " NQC "
	cSQL += " WHERE NQC.NQC_FILIAL = '"+xFilial("NQC")+"' AND "
	cSQL +=       " NQC.D_E_L_E_T_ = ' ' "

	If !Empty(cComarca)
		cSQL += " AND NQC.NQC_CCOMAR = '" + cComarca + "' "
	EndIf

	cSQL := ChangeQuery(cSQL)
	cQrySql := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cQrySql,.T.,.T.)

	If (cQrySql)->(!Eof())
		nNumNQC := (cQrySql)->LOC2N // Quantidade de localizações de 3º nível não localizadas
		nMaxNQC := (cQrySql)->MAXCOD
	End

	(cQrySql)->(dbCloseArea())
Return {nNumNQC,nMaxNQC}

//-------------------------------------------------------------------
/*/{Protheus.doc} JTotLoc3N(cForo)
Total de Varas.

@Param cForo - Código do Foro, se for realizar filtro

@Return [nNumNQE] - Contagem de Varas
		[nMaxNQE] - ID maximo do Vara

@since 24/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTotLoc3N(cForo)
Local cQrySql    := NIL
Local nNumNQE    := 0
Local nMaxNQE    := 0
Local cSQL       := ""

Default cForo := ""

	cSQL := " SELECT COUNT(*) LOC3N, COALESCE(MAX(NQE_COD),'0') MAXCOD "
	cSQL +=   " FROM " + RetSqlName("NQE") + " NQE "
	cSQL += " WHERE NQE.NQE_FILIAL = '"+xFilial("NQE")+"' AND "
	cSQL +=       " NQE.D_E_L_E_T_ = ' ' "

	If !Empty(cForo)
		cSQL += " NQE.NQE_CLOC2N = '" + cForo + "' "
	EndIf

	cSQL := ChangeQuery(cSQL)
	cQrySql := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cQrySql,.T.,.T.)

	If (cQrySql)->(!Eof())
		nNumNQE := (cQrySql)->LOC3N // Quantidade de localizações de 3º nível não localizadas
		nMaxNQE := (cQrySql)->MAXCOD
	End

	(cQrySql)->(dbCloseArea())

Return {nNumNQE,nMaxNQE}

//-------------------------------------------------------------------
/*/{Protheus.doc} JSeekNQ6(cCod)
Posiciona na Comarca

@Param cCod - Código da Comarca

@Return lRet - Retorna se encontrou o código ou não

@since 24/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JSeekNQ6(cCod)
	NQ6->(DbSetOrder(1))
Return NQ6->( dbSeek( xFilial( 'NQ6' ) + cCod ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} JFindNQ6(cCod)
Verifica se encontra alguma Comarca com o ID Informado

@Param cCod - Código da Comarca a ser verificado

@Return lRet - Retorna se encontrou ID ou não

@since 24/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JFindNQ6(cCod)
Local lRet      := .F.
Local cAliasNQ6 := ""
Local cQrySel   := ""
Local cQryFrm   := ""
Local cQryWhr   := ""
Local cSQL      := ""

	cQrySel := " SELECT COUNT(*) Qtd "
	cQryFrm := " FROM " + RetSqlName("NQ6")
	cQryWhr := " WHERE NQ6_COD = '" + cCod + "' "
	cQryWhr +=   " AND NQ6_FILIAL = '" + xFilial("NQ6") + "' "
	cQryWhr +=   " AND D_E_L_E_T_ = ' ' "

	cAliasNQ6 := GetNextAlias()

	cSQL := ChangeQuery(cQrySel+cQryFrm+cQryWhr)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasNQ6,.T.,.T.)

	lRet := (cAliasNQ6)->Qtd > 0

	(cAliasNQ6)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JFindNQC(cCod)
Verifica se encontra alguma Foro com o ID Informado

@Param cCod - Código da Foro a ser verificado

@Return lRet - Retorna se encontrou ID ou não

@since 24/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JFindNQC(cCod)
Local lRet      := .F.
Local cAliasNQC := ""
Local cQrySel   := ""
Local cQryFrm   := ""
Local cQryWhr   := ""
Local cSQL      := ""

	cQrySel := " SELECT COUNT(*) Qtd "
	cQryFrm := " FROM " + RetSqlName("NQC")
	cQryWhr := " WHERE NQC_COD = '" + cCod + "' "
	cQryWhr +=   " AND NQC_FILIAL = '" + xFilial("NQC") + "' "
	cQryWhr +=   " AND D_E_L_E_T_ = ' ' "

	cAliasNQC := GetNextAlias()

	cSQL := ChangeQuery(cQrySel+cQryFrm+cQryWhr)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasNQC,.T.,.T.)

	lRet := (cAliasNQC)->Qtd > 0

	(cAliasNQC)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JFindNQE(cCod)
Verifica se encontra alguma Vara com o ID Informado

@Param cCod - Código da Vara a ser verificado

@Return lRet - Retorna se encontrou ID ou não

@since 24/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JFindNQE(cCod)
Local lRet      := .F.
Local cAliasNQE := ""
Local cQrySel   := ""
Local cQryFrm   := ""
Local cQryWhr   := ""
Local cSQL      := ""

	cQrySel := " SELECT COUNT(*) Qtd "
	cQryFrm := " FROM " + RetSqlName("NQE")
	cQryWhr := " WHERE NQE_COD = '" + cCod + "' "
	cQryWhr +=   " AND NQE_FILIAL = '" + xFilial("NQE") + "' "
	cQryWhr +=   " AND D_E_L_E_T_ = ' ' "

	cAliasNQE := GetNextAlias()

	cSQL := ChangeQuery(cQrySel+cQryFrm+cQryWhr)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasNQE,.T.,.T.)

	lRet := (cAliasNQE)->Qtd > 0

	(cAliasNQE)->(dbCloseArea())

Return lRet

