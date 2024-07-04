#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSA505.CH'
#include "PLSMGER.CH"
#include "PLSMCCR.CH"

Function PLSA505()
Local oBrowse

PRIVATE bDelLine := { || If(BCT->BCT_PROPRI$"0,5",(Help("",1,"PLSA505EXC"),.F.),.T.) }
PRIVATE cTagXML := ""
PRIVATE cCamTag := ""
PRIVATE cDADEXP := ""

If !PLSALIASEXI("BVN")
	Aviso( STR0007, STR0008, {STR0009} ) //"Tabela BVN não foi encontrada"###"Execute o compatibilizadores UPDPLSBC, UPDPLSBH do pacote TISS 3.0 conforme boletim técnico."###"Ok"
	Return
EndIf

PLSPOSGLO(PLSINTPAD(),__aCdCri026[1],__aCdCri026[2],nil,"0",nil)

// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()

// Definição da tabela do Browse
oBrowse:SetAlias('BCT')

// Titulo da Browse
oBrowse:SetDescription( 'Motivos de Criticas' )

// Ativação da Classe
oBrowse:Activate()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ ModelDef º Autor ³Bruno Iserhardt       Data ³  12/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Define o modelo de dados da aplicação                      ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ PLSA505                                                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruBCT := FWFormStruct( 1, 'BCT' )
Local oStruBVN := FWFormStruct( 1, 'BVN' )
// Modelo de dados construído
Local oModel

// Cria o objeto do Modelo de Dados e insere a funçao de pós-validação
oModel := MPFormModel():New( 'PLSA505', , {|| PLSA505OK() } )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'BCTMASTER', /*cOwner*/, oStruBCT )

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'BVNDETAIL', 'BCTMASTER', oStruBVN )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'BVNDETAIL', {	{ 'BVN_FILIAL'	, 'xFilial( "BVN" )'	},;
       									{ 'BVN_CODOPE'	, 'BCT_CODOPE' 		},;
       									{ 'BVN_PROPRI'	, 'BCT_PROPRI' 		},;
       									{ 'BVN_CODGLO'	, 'BCT_CODGLO' 		} },;
       				   BVN->( IndexKey( 1 ) ) )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( Fundesc() )

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'BCTMASTER' ):SetDescription( 'Motivos de Críticas' )

//BVN não é obrigatoria
oModel:GetModel('BVNDETAIL'):SetOptional(.T.)

// Retorna o Modelo de dados
Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ MenuDef  º Autor ³Everton M. Fernandesº Data ³  03/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Define o menu da aplicação                                 ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ PLSA445                                                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'				Action 'VIEWDEF.PLSA505' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir' 					Action 'VIEWDEF.PLSA505' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 					Action 'VIEWDEF.PLSA505' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 					Action 'VIEWDEF.PLSA505' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir' 				Action 'VIEWDEF.PLSA505' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Vinculo TISS' 			Action "MsgRun('',,{||PLVINCTIS('BCT',BCT->BCT_CODGLO, 1)})" OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Exluir Vinculo TISS' 	Action "MsgRun('',,{||PLVINCTIS('BCT',BCT->(BCT_FILIAL+BCT_CODOPE+BCT_PROPRI+BCT_CODGLO), 0)})" OPERATION 2 ACCESS 0

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ ViewDef  º Autor ³Everton M. Fernandesº Data ³  03/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Define o modelo de dados da aplicação                      ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ PLSA445                                                    ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSA505' )
// Cria as estruturas a serem usadas na View
Local oStruBCT := FWFormStruct( 2, 'BCT' )
Local oStruBVN := FWFormStruct( 2, 'BVN' )
// Interface de visualização construída
Local oView

oModel:SetPrimaryKey( { "BCT_FILIAL", "BCT_CODOPE", "BCT_PROPRI", "BCT_CODGLO" } )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_BCT', oStruBCT, 'BCTMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_BVN', oStruBVN, 'BVNDETAIL' )

//Informo que o campo é incremental
oView:AddIncrementField( 'VIEW_BVN', 'BVN_CDITEM' )

//Nao deixa duplicar o campo BTD_CAMPO
oModel:GetModel( 'BVNDETAIL' ):SetUniqueLine( { 'BVN_CDITEM' ,'BVN_TISVER'} )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 50 )
oView:CreateHorizontalBox( 'INFERIOR', 50 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_BCT', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_BVN', 'INFERIOR' )

// Retorna o objeto de View criado
Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ AtuSX3  ³ Autor ³ Patricia Duca          ³ Data ³ 17/09/09 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Atualizacao do campo BCT_PRIORI                            ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³                                                            ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuSX3()

dbSelectArea("BCT")
BCT->(dbSetOrder(1))
If BCT->(dbSeek(xFilial("BCT")+PlsIntPad()+"035")) .And.;	//BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
(BCT->BCT_ATIVO  != "1" .Or. BCT->BCT_LOCANA != "3")
	BCT->(RecLock("BCT",.F.))
	BCT->BCT_ATIVO  := "1" // Ativo
	BCT->BCT_LOCANA := "3" // Ambas
	BCT->(msUnLock())
EndIf
BCT->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA505OK ºAutor  ³Microsiga           º Data ³  06/22/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da critica 35 da operadora, por definicao do sis  º±±
±±º          ³tema ela deve sempre ficar ativa e analisar igual a ambos   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAPLS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA505OK()
Local lRet 			:= .T.
Local cMsg 			:= ""
Local nI 			:= 1
Local cTpVld		:= ""
Local oModel 		:= FWModelActive()
Local oModelDetail 	:= oModel:GetModel( 'BVNDETAIL' )

If M->BCT_PROPRI == "0" .And. M->BCT_CODGLO == "35"

	If M->BCT_ATIVO != "1"
		cMsg += STR0001 + "<BR>"
	ElseIf M->BCT_LOCANA != "3"
		cMsg += STR0002 + "<BR>"
	EndIf
	
EndIf

For nI := 1 To oModelDetail:Length()

	oModelDetail:GoLine( nI )
	
	cTpVld := oModelDetail:GetValue('BVN_TPVLD')

	If (cTpVld == "1")
	
		If (Empty(AllTrim(oModelDetail:GetValue('BVN_ALIAS'))))
			cMsg += STR0003 + cValToChar(nI) + "<BR>"
		EndIf
		
		If (oModelDetail:GetValue('BVN_INDICE') <= 0)
			cMsg += STR0004 + cValToChar(nI) + "<BR>"
		EndIf
		
	ElseIf (cTpVld == "2")
	
		If (Empty(AllTrim(oModelDetail:GetValue('BVN_ALIAS'))))
			cMsg += STR0003 + cValToChar(nI) + "<BR>"
		EndIf
		
		If (Empty(AllTrim(oModelDetail:GetValue('BVN_CODTAB'))))
			cMsg += STR0005 + cValToChar(nI) + "<BR>"
		EndIf
		
	ElseIf (cTpVld == "3")
	
		//aqui o indice é obrigatório somente se o alias for preenchido
		If (!Empty(AllTrim(oModelDetail:GetValue('BVN_ALIAS'))) .And. oModelDetail:GetValue('BVN_INDICE') <= 0)
			cMsg += STR0004 + cValToChar(nI) + "<BR>"
		EndIF
		
		If (Empty(AllTrim(oModelDetail:GetValue('BVN_DADEXP'))))
			cMsg += STR0006 + cValToChar(nI) + "<BR>"
		EndIf
		
	EndIf
	
Next

If ! Empty(cMsg)
	MsgInfo(cMsg)
	lRet := .F.
EndIf

//limpa a matriz STATIC do PLSPOSGLO()
PCLPOSGLO()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS505WHENºAutor  ³ Bruno Iserhardt    º Data ³  19/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação da habilitação dos campos BVN_ALIAS,       		º±±
±±º          ³BVN_INDICE, BVN_CODTAB e BVN_DADEXP de acordo com o que foi	º±±
±±º          ³selecionado no campo BVN_TPVLD.									º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS505WHEN()
Local cCpo   := ReadVar()
Local lRet   := .F.
Local cTpVld := ""
Local oModel := FwModelActive()

cTpVld := oModel:GetValue('BVNDETAIL','BVN_TPVLD')

If "BVN_ALIAS" $ cCpo
	lRet := (cTpVld == "1" .Or. cTpVld == "2" .Or. cTpVld == "3")
ElseIf "BVN_INDICE" $ cCpo
	lRet := (cTpVld == "1" .Or. cTpVld == "3")
ElseIf "BVN_CODTAB" $ cCpo
	lRet := (cTpVld == "2")
ElseIf "BVN_DADEXP" $ cCpo
	lRet := (cTpVld == "1" .Or. cTpVld == "3")
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS505TAG ºAutor  ³ Bruno Iserhardt    º Data ³  19/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³F3 dos campos BVN_TAG e BVN_CAMTAG                          º±±
±±º          ³Tambem utilizado para os campos BVV_TAG E BVV_CAMTAG        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS505TAG()
Local aTag := PL444TREE()

If (Len(aTag) > 1)
	//preenche as variáveis de retorno do F3
	cTagXML := UPPER(aTag[1])
	cCamTag := UPPER(aTag[2])

	//insere uma contra barra no final no path caso nao haja
	If (Len(cCamTag) > 0)
		If (SubStr(cCamTag, Len(cCamTag), 1) != "\")
			cCamTag := cCamTag + "\"
		End If
	EndIf
EndIf
Return Len(aTag) > 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ PL973LEXPº Autor ³Bruno Iserhardt     º Data ³  23/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ F3 para o usuário informar a expressão da coluna BNV_DADEXPº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ Retorna a expressão informada pelo usuário                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ PLSA505                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL505LEXP(cCampoExp)
Local lRet			:= .F.
Local oModel 		:= FwModelActive()
Local aCoors 		:= FWGetDialogSize( oMainWnd )
Local cExpressao 	:= ""
Local cTissVer		:= ""
Local cCBVar
Local oDlgPrinc

If (cCampoExp == "BVN_DADEXP")
	//seleciona a expressão do registro corrente da BVN
	cExpressao := oModel:GetValue('BVNDETAIL','BVN_DADEXP')
	//seleciona a versão da TISS do registro dorrente da BVN
	cTissVer := oModel:GetValue('BVNDETAIL','BVN_TISVER')
ElseIf (cCampoExp == "BVP_VLREXP")
	//seleciona a expressão do registro corrente da BVP
	cExpressao := oModel:GetValue('BVPDETAIL','BVP_VLREXP')
	//seleciona a versão da TISS do registro dorrente da BVP
	cTissVer := oModel:GetValue('BVVMASTER','BVV_TISVER')
ElseIf (cCampoExp == "BVP_DADSEK")
	//seleciona a expressão do registro corrente da BVP
	cExpressao := oModel:GetValue('BVPDETAIL','BVP_DADSEK')
	//seleciona a versão da TISS do registro dorrente da BVP
	cTissVer := oModel:GetValue('BVVMASTER','BVV_TISVER')
Else
	MsgInfo("Campo não encontrado")
	Return
EndIf

Define MsDialog oDlgPrinc Title "Criação de Expressão" From 0, 0 To 120, 600 Pixel //"Criação de Expressão"

//Label Expressão
TSay():New( 007,005,{||"Expressão"},oDlgPrinc,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008) //"Expressão"
//TextBox da Expressão
TGet():New( 005,035,{ | U | If( PCOUNT() == 0, cExpressao, cExpressao := U ) },oDlgPrinc,250,011,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cExpressao,,,, )
//Label explicativo
TSay():New( 019,035,{||"[% %] = define que a expressão usará o valor de uma TAG"},oDlgPrinc,,,.F.,.F.,.F.,.T.,CLR_RED,CLR_WHITE,150,008) //"[% %] = define que a expressão usará o valor de uma TAG"
//Label Variáveis
TSay():New( 032,005,{||"Variáveis"},oDlgPrinc,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008) //"Variáveis"
//ComboBox com as variáveis da versão da TISS
oCBVar := TComboBox():New( 030,035,{|u| If(PCount()>0,cCBVar:=u,cCBVar)}, PGETVARTIS(cTissVer),060,010,oDlgPrinc,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cCBVar) //Variáveis
//Botão para inserir uma variável na expressão
TButton():New( 030,100,"Inserir Variável",oDlgPrinc,{|| PLINSVAR(@cExpressao, cCBVar) },040,012,,,,.T.,,,,,,.F. ) //"Inserir Variável"
//Botão para inserir uma tag na expressão
TButton():New( 047,035,"Inserir Tag",oDlgPrinc,{|| PLINSTAG(@cExpressao) },037,012,,,,.T.,,,,,,.F. ) //"Inserir Tag"
//Botão de OK
TButton():New( 047,247,"OK"			 ,oDlgPrinc,{|| lRet := .T., oDlgPrinc:End() },040,012,,,,.T.,,,,,,.F. ) //"Ok"

Activate MsDialog oDlgPrinc Center

If (lRet == .T.)
	//Atualiza a variável de retorno do F3
	cDADEXP := cExpressao
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ PLINSTAG º Autor ³Bruno Iserhardt     º Data ³  23/07/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Chama a tela para o usuário selecionar a tag desejada para º±±
±±º          ³ inseri-la na expressão.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ Retorna o conteúdo da expressão mais a tag selecionada     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLINSTAG(cExpressao)
Local aTag := PL444TREE()

If (Len(aTag) > 1)
	
	//Insere a tag no final da expressão
	cExpressao := AllTrim(cExpressao) + " [%" + aTag[2] + "\" + aTag[1] + "%]"
	
	//Insere espaços para permitir o usuário continuar a digitar a expressão
	If (Len(cExpressao) < 500)
		cExpressao += Space(500-Len(cExpressao))
	EndIf
	
EndIf
//Retorna a expressão com a tag
Return cExpressao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ PLINSVAR º Autor ³Bruno Iserhardt     º Data ³  21/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Insere a variável selecionada na expressão.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ Retorna o conteúdo da expressão mais a variável selecionadaº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLINSVAR(cExpressao, cCBVar)
If (cCBVar == Nil)
	MsgInfo("Versão TISS não informada.")
Else
	//Insere a tag no final da expressão
	cExpressao := AllTrim(cExpressao) + Space(1) + cCBVar
	//Insere espaços para permitir o usuário continuar a digitar a expressão
	If (Len(cExpressao) < 500)
		cExpressao += Space(500-Len(cExpressao))
	EndIf
EndIF
//Retorna a expressão com a variável
Return cExpressao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³PGETVARTISº Autor ³Bruno Iserhardt     º Data ³  21/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Retorna um array com todas as variáveis de uma versão TISS.º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PGETVARTIS(cTissVer)
Local aVars := {}

//verifica se a versão da tiss está preenchida
If (!Empty(AllTrim(cTissVer)))
	BVP->(DbSelectArea("BVP"))
	BVP->(DbSetOrder(1)) //BVP_FILIAL+BVP_TISVER

	If (BVP->(MsSeek(xFilial("BVP")+cTissVer)))
		While (!BVP->(Eof()) .And. BVP->(BVP_FILIAL+BVP_TISVER) == xFilial("BVP")+cTissVer)
			aAdd(aVars, BVP->BVP_NOMVAR)
			BVP->(DbSkip())
		EndDo
	EndIF
EndIf

Return aVars

/*/{Protheus.doc} PL505BCTW
Verifica se o campo pode ser alterado, pois existem criticas que nao podem ser desativadas
ou podem ser criticadas somente em determinado local de atendimento para nao causar inconsistencia
@author victor.silva
@since 14/10/2016
@version version
@return lRet, retorno informando se o campo pode ser alterado.
/*/
function PL505BCTW()
local lRet			:= .t.
local oModel		:= FwModelActive()
local cPropri		:= oModel:GetValue('BCTMASTER','BCT_PROPRI')
local cCodGlo		:= oModel:GetValue('BCTMASTER','BCT_CODGLO')
local cAtivo		:= oModel:GetValue('BCTMASTER','BCT_ATIVO')
local cCodBVN		:= oModel:GetValue('BVNDETAIL','BVN_CODGLO')

//Campo BCT_LOCANA
if ReadVar() == "M->BCT_LOCANA"
	
	if cPropri + cCodGlo $ "09I/063/035"
		lRet := .f.
	endif

//Campo BCT_ATIVO
elseif ReadVar() == "M->BCT_ATIVO"
	
	//Somente criticas que nao sao de propriedade do SISTEMA podem ser desabilitadas
	if cPropri == "5"
		lRet := .f.
	endif
	
	//Criticas que comprometem a consistencia da entrada de dados nao podem ser desabilitadas
	if cPropri + cCodGlo $ "X17/X18/X19/X20/X24/X33/035"
		lRet := .f.
	endif
	
elseif ReadVar() == "M->BCT_ENVCOX"

	//Criticas de XML que comprometem a consitencia da entrada de dados nao podem ir para conferencia
	if cPropri + cCodGlo $ "X17/X18/X19/X20/X24/X33"
		lRet := .f.
	endif
	
	//So pode enviar para a conferencia quando a critica estiver desativada
	if cAtivo == "1"
		lRet := .f.
	endif
	
	//Se nao existir BVN no registro nao eh critica de XML  
	if Empty(cCodBVN) 
		lRet := .f.
	endif
	
endif

return lRet
