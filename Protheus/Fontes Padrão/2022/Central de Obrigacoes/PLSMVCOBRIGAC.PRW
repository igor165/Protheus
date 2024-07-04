#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE OBR_SIP 		"1"
#DEFINE OBR_SIB 		"2"
#DEFINE OBR_DIOPS	 	"3"
#DEFINE OBR_DMED	 	"4"
#DEFINE OBR_MONIT	 	"5"

#DEFINE SNZ_MENSAL 		1
#DEFINE SZN_BIMES 		2
#DEFINE SZN_TRIME 		3
#DEFINE SZN_SEMES 		4
#DEFINE SZN_ANUAL 		5
#DEFINE NAO_EXCLUI		"Não permite excluir obrigações com compromissos concluidos."
#DEFINE NAO_SAZON		'Não permite alterar a sazonalidade de obrigações com compromissos concluidos.'
#DEFINE NAO_OPERACAO	"Operação não poderá ser realizada"
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição das opções do menu

@return aRotina	Lista de opcoes do menu

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Incluir' 			Action 'VIEWDEF.PLSMVCOBRIGAC'	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 			Action 'VIEWDEF.PLSMVCOBRIGAC'	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 			Action 'VIEWDEF.PLSMVCOBRIGAC'	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Criticas' 		Action 'PlCritObr()'			OPERATION 1 ACCESS 0
//Implementação do botão para criar compromissos para o ano seguinte. Ficou comentado para inclusão em sprints futuras.
//ADD OPTION aRotina Title 'Criar Comp. Prox. Ano'	Action 'PLLOADCOMP(Year(dDataBase)+1)'	OPERATION 2 ACCESS 0

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para o conjunto B3A, B3U e B3C

@return oModel	objeto model criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB3A 		:= FWFormStruct( 1, 'B3A' )
	Local oStruB3U 		:= FWFormStruct( 1, 'B3U' )
	Local oStruB3C 		:= FWFormStruct( 1, 'B3C' )
	Local oModel // Modelo de dados construído
	Local oEvent  	    := CENEVTCENT():New()
	
	bInicPadr := FWBuildFeature( STRUCT_FEATURE_WHEN, '' )
	oStruB3A:SetProperty( 'B3A_TIPO' , MODEL_FIELD_INIT, bInicPadr)

	oModel := MPFormModel():New( 'PLSMVCOBRIGAC',,{ |oModel| PostValid(oModel) },{ |oModel| PLGrvComp( oModel ) } )
	
	oModel:AddFields( 'B3AMASTER', /*cOwner*/ , oStruB3A )
	oModel:AddGrid( 'B3UDETAIL', 'B3AMASTER', oStruB3U )
	oModel:AddGrid( 'B3CDETAIL', 'B3AMASTER', oStruB3C )

	oModel:SetRelation( 'B3UDETAIL',  { 	{ 'B3U_FILIAL', 'xFilial( "B3U" )' },;
												{ 'B3U_CODOPE' , 'B3A_CODOPE' },;
												{ 'B3U_CDOBRI' , 'B3A_CODIGO' };
						}, B3U->( IndexKey( 1 ) ) )
						
	oModel:SetRelation( 'B3CDETAIL',  { 	{ 'B3C_FILIAL', 'xFilial( "B3U" )' },;
												{ 'B3C_CODOPE' , 'B3A_CODOPE' },;
												{ 'B3C_CDOBRI' , 'B3A_CODIGO' };
						}, B3C->( IndexKey( 1 ) ) )

	oModel:SetDescription( 'Obrigações' )

	oModel:GetModel( 'B3AMASTER' ):SetDescription( " Obrigações " )
	oModel:GetModel( 'B3UDETAIL' ):SetDescription( " Contatos da Obrigação " )
	oModel:GetModel( 'B3CDETAIL' ):SetDescription( " Configuração dos Compromissos " )

	oModel:GetModel('B3CDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('B3CDETAIL'):SetNoDeleteLine(.T.)
	
	oModel:AddRules('B3AMASTER', 'B3A_TIPO' , 'B3AMASTER', 'B3A_CODOPE'  , 3 )
	oModel:AddRules('B3AMASTER', 'B3A_SZNLDD' , 'B3AMASTER', 'B3A_TIPO'  , 3 )
	oModel:SetVldActivate( { |oModel| B3AExclui( oModel ) } )

	oModel:InstallEvent("EVTATUB3A", /*cOwner*/, oEvent)

Return oModel

Static Function PostValid(oModel)
	Local lRet		:= .F.
	
	cAtivo := oModel:GetValue('B3AMASTER','B3A_ATIVO')
	//Verifica se ja existe obrigacao ativa
	lRet := cAtivo == "2" .Or. ObrigacaoAtiva(oModel:GetValue('B3AMASTER','B3A_CODOPE'),oModel:GetValue('B3AMASTER','B3A_CODIGO'),oModel:GetValue('B3AMASTER','B3A_TIPO'),cAtivo)

Return lRet

Function B3ASZNLDD()
	Local lRet	:= .T.

	B3D->(dbSetOrder(2))
	If ALTERA .And. B3D->(MsSeek(xFilial("B3D")+B3A->B3A_CODOPE+B3A->B3A_CODIGO+"6"))
		lRet := .F.
		Help(,,'HELP',,NAO_SAZON,1,0,,,,,,{NAO_OPERACAO})
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para o conjunto B3A, B3U e B3C

@return oView	objeto view criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSMVCOBRIGAC' )
// Cria as estruturas a serem usadas na View
Local oStruB3A 			:= FWFormStruct( 2, 'B3A' )
Local oStruB3U 			:= FWFormStruct( 2, 'B3U' )
Local oStruB3C 			:= FWFormStruct( 2, 'B3C' )
// Interface de visualização construída
Local oView

oStruB3A:SetProperty( 'B3A_TIPO' , MVC_VIEW_ORDEM, '05')
oStruB3A:SetProperty( 'B3A_SZNLDD' , MVC_VIEW_ORDEM, '07')

oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_B3A', oStruB3A, 'B3AMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_B3U', oStruB3U, 'B3UDETAIL' )
oView:AddGrid( 'VIEW_B3C', oStruB3C, 'B3CDETAIL' )

oStruB3U:RemoveField('B3U_CODOPE')
oStruB3U:RemoveField('B3U_CDOBRI')

oStruB3C:RemoveField('B3C_CODOPE')
oStruB3C:RemoveField('B3C_CDOBRI')

//Nao deixa duplicar o campo B7A_CAMPO
oModel:GetModel( 'B3UDETAIL' ):SetUniqueLine( { "B3U_FILIAL","B3U_CODOPE","B3U_CDOBRI","B3U_CODIGO"} )
oModel:GetModel( 'B3CDETAIL' ):SetUniqueLine( { "B3C_FILIAL","B3C_CODOPE","B3C_CDOBRI","B3C_CDCOMP"} )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 28 )
oView:CreateHorizontalBox( 'MEIO', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 32 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_B3A', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_B3C', 'MEIO' )
oView:SetOwnerView( 'VIEW_B3U', 'INFERIOR' )

//Insiro descrições nas views
oView:EnableTitleView( 'VIEW_B3C', "Configuração dos Compromissos" )
oView:EnableTitleView( 'VIEW_B3U', "Contatos da Obrigação" )

//Adiciona campo incremental
//oView:AddIncrementField( 'VIEW_B3A', 'B3A_CODIGO' )
oView:AddIncrementField( 'VIEW_B3U', 'B3U_CODIGO' )

//Adiciono o gatilho para preencher o grid Cfg Obrigações
oView:SetFieldAction( 'B3A_SZNLDD', { |oView, cIDView, cField, xValue| PLGridComp( oView, cIDView, cField, xValue ) } )
oView:SetFieldAction( 'B3A_TIPO', { |oView, cIDView, cField, xValue| setSazon( oView, cIDView, cField, xValue ) } )
oView:SetFieldAction( 'B3A_TIPO', { |oView, cIDView, cField, xValue| PLGridComp( oView, cIDView, cField, xValue ) } )

// Retorna o objeto de View criado
Return oView
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGridComp

Preenche o grid de configuracao de obrigacoes de acordo com a sazonalidade selecionada

@param oView		Objeto view
@param cIDView		Identificador do objeto view
@param cField		Campo
@param xValue		Valor

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PLGridComp( oView, cIDView, cField, xValue) 
Local oModel		:=	FWModelActive()
Local oModelB3A 	:= oModel:GetModel( 'B3AMASTER' )
Local oModelB3C 	:= oModel:GetModel( 'B3CDETAIL' )
Local nLinha		:= 0
Local nI
Local nSazon
//-----------------------------------------
//AJUSTE NA ABA DOS DÉBITOS NÂO CUMULATIVOS
//-----------------------------------------
aArea	:= GetArea()

//Limpa o grid
oModelB3C:SetNoDeleteLine(.F.)
//oModelB3C:DelAllLine()
nLenGrid := oModelB3C:Length()

For nI := 1 to nLenGrid
	If !oModelB3C:IsDeleted(nI)
		oModelB3C:GoLine(nI)
		oModelB3C:DeleteLine()
	EndIf
Next nI

oModelB3C:SetNoDeleteLine(.T.)

//Carrega os compromissos de acordo com a sazonalidade
If AllTrim(oModelB3A:GetValue("B3A_SZNLDD")) <> "" 
	
	nSazon := val(oModelB3A:GetValue("B3A_SZNLDD"))
	if nSazon == SNZ_MENSAL
		nSazon := 12
	ElseIf nSazon == SZN_BIMES
		nSazon := 6
	ElseIf nSazon == SZN_TRIME
		nSazon := 4
	ElseIf nSazon == SZN_SEMES
		nSazon := 2
	ElseIf nSazon == SZN_ANUAL
		nSazon := 1
	End If
	
	oModelB3C:SetNoInsertLine(.F.)
	
	For nLinha = 1 To nSazon 
		nDia := RetDiaEnv(oModelB3A:GetValue("B3A_TIPO"))
		nMes := RetMesEnvio(val(oModelB3A:GetValue("B3A_SZNLDD")),nLinha, oModelB3A:GetValue("B3A_TIPO"))
		cAnoEnv := RetAnoEnv(oModelB3A:GetValue("B3A_TIPO"), nMes, val(oModelB3A:GetValue("B3A_SZNLDD")))

		oModelB3C:AddLine(.T.)
		FwFldPut("B3C_FILIAL", xFilial("B3C") ) 
		FwFldPut("B3C_CODOPE",Iif( INCLUI,M->B3A_CODOPE,oModelB3A:GetValue("B3A_CODOPE") ) )
		FwFldPut("B3C_CDCOMP",AllTrim(StrZero(nLinha,3)))
		FwFldPut("B3C_DIAENV",nDia ) 
		FwFldPut("B3C_MESENV",nMes )
		FwFldPut("B3C_ANOENV",cAnoEnv) 
		FwFldPut("B3C_REFERE",AllTrim(Str(nLinha)) + "º " + subStr(X3COMBO("B3A_SZNLDD",oModelB3A:GetValue("B3A_SZNLDD")),1,3) ) 
	Next nLinha
	
	oModelB3C:GoLine(oModelB3C:Length() - nSazon + 1 )
	
	oModelB3C:SetNoInsertLine(.T.)
	
End If

oview:Refresh( 'VIEW_B3C' )
RestArea(aArea)

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetMesEnvio

Retorna o mes de envio do compromisso de acordo com a sazonalidade

@param nSazon	Sazonalidade
@param nMes		Sequencia da sazonalidade

@return nMes	Retorna o mes de envio do compromisso

@author timoteo.bega
@since 22/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetMesEnvio(nSazon,nMes,cTipoObr)
	Default nSazon	:= 1
	Default nMes	:= 1

	If nSazon == SNZ_MENSAL
		If cTipoObr == OBR_SIB
			nMes++
			If nMes == 13
				nMes := 1
			EndIf
		ElseIf cTipoObr == OBR_MONIT
			nMes:=nMes + 2
			If nMes >= 13
				nMes := nMes - 12
			EndIf
		EndIf

	ElseIf nSazon == SZN_BIMES//Bimestral

		If nMes == 2
			nMes := 3
		ElseIf nMes == 3
			nMes := 5
		ElseIf nMes == 4
			nMes := 7
		ElseIf nMes == 5
			nMes := 9
		ElseIf nMes == 6
			nMes := 11
		Else
			nMes := 1
		EndIf

	ElseIf nSazon == SZN_TRIME

		If nMes == 2
			nMes := 4
		ElseIf nMes == 3
			nMes := 7
		ElseIf nMes == 4
			nMes := 10
		Else
			nMes := 1
		EndIf

	ElseIf nSazon == SZN_SEMES

		If nMes == 2
			nMes := 7
		Else
			nMes := 1
		EndIf
	ElseIf nSazon == SZN_ANUAL

		nMes := 2

	EndIf

Return nMes

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetDiaEnv

Retorna o dia de envio do compromisso de acordo a obrigacao

@param cTipoObr	Tipo da obrigação sendo cadastrada

@return nDia	Retorna o dia de envio do compromisso

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetDiaEnv(cTipoObr)
	Local nDia			:= 1
	Default cTipoObr	:= OBR_SIP

	If cTipoObr == OBR_SIB
		nDia := 5
	ElseIf cTipoObr == OBR_MONIT
		nDia := 25
	ElseIf cTipoObr == OBR_DMED
		nDia := 28
	EndIf

Return nDia

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetAnoEnv

Retorna o ano de envio do compromisso de acordo a obrigacao e mes

@param cTipoObr	Tipo da obrigação sendo cadastrada
@param nMes	Mes de envio

@return nDia	Retorna o ano de envio do compromisso

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetAnoEnv(cTipoObr, nMes, nSazon)
	Local cAnoEnv			:= "1"
	Default cTipoObr	:= OBR_SIP
	Default nMes	:= 1
	Default nSazon	:= SNZ_MENSAL

	If cTipoObr == OBR_SIB .AND. nSazon == SNZ_MENSAL .AND. nMes == 1 
		cAnoEnv := "2"
	ElseIf cTipoObr == OBR_MONIT .AND. nSazon == SNZ_MENSAL .AND. (nMes == 1 .Or. nMes == 2) .Or. (cTipoObr == OBR_DMED)
		cAnoEnv := "2"
	EndIf

Return cAnoEnv

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLGrvComp

Grava as alterações na obrigação e cria os compromissos do ano

@param oModel	Objeto model

@return lRet	.F. registro criticao ou .T. registro nao criticao

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PLGrvComp( oModel ) 
	Local oModelB3U  := oModel:GetModel( 'B3UDETAIL' )
	Local oModelB3C  := oModel:GetModel( 'B3CDETAIL' )
	Local oModelB3A	 := oModel:GetModel( 'B3AMASTER' )
	Local lRet 		 := .T.
	Local nOperation := oModel:GetOperation()

	aArea	:= GetArea()

	BEGIN TRANSACTION

	cAno := AllTrim(Str(Year(dDataBase)))
	cOpe := oModelB3A:GetValue("B3A_CODOPE")

	If(nOperation == MODEL_OPERATION_INSERT)
		//Grava os dados do model
		If lRet
			lRet := FWFormCommit( oModel )
		EndIf
		If lRet
			//Inclui os compromissos para o ano	
			PlInComMVC( oModelB3A,oModelB3U,oModelB3C, cAno) 	
		EndIf
		
	ElseIf (nOperation == MODEL_OPERATION_UPDATE)
		//Verifico se a ultima linha foi inserida nessa atualização. 
		//Isso indica que o usuário mexeu na sazonalidade
		oModelB3C:GoLine(oModelB3C:Length())
		lNovaSazon := oModelB3C:isInserted() .And. oModelB3A:GetValue("B3A_SZNLDD") <> B3A->B3A_SZNLDD
		
		If lNovaSazon
			//Perguntar ao usuario se deseja continuar
			If ApMsgNoYes ("A sazonalidade foi alterada, deseja gerar novamente os compromissos?","Central de Obrigações") 
				
				lRet := ExcluiComp(oModelB3A:GetValue("B3A_CODOPE"),oModelB3A:GetValue("B3A_CODIGO"), cAno,NAO_SAZON )
						
				If lRet
					//Recria os compromissos do ano.
					PlInComMVC( oModelB3A,oModelB3U,oModelB3C,cAno)
				EndIf
			Else
				lRet := .F.
			EndIf
		Else
			PlInComMVC( oModelB3A,oModelB3U,oModelB3C,cAno)
		EndIf
		If lRet
			lRet := FWFormCommit( oModel )
		EndIf

	ElseIf (nOperation == MODEL_OPERATION_DELETE)
		
		lRet := FWFormCommit( oModel )

	EndIf

	If !lRet
		DisarmTransaction()
	EndIf

	END TRANSACTION

	MsUnlockAll()

	RestArea(aArea)

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExcluiComp

Funcao generica para excluir os compromissos de uma obrigacao em um determinado ano

@param cCodOpe		Numero do registro da operadora na ANS
@param cCodObri		Chave da obrigacao
@param cAno			Ano do compromisso
@param cMsgErro		Mensagem de erro da exclusao

@return lRet		.T. se encontrou o registro e foi excluiso .F. se nao consegui excluir o registro

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExcluiComp( cCodOpe, cCodObri, cAno, cMsgErro ) 
	Local lRet := .T.
	Default cAno := ""
	Default cMsgErro := NAO_EXCLUI

	B3D->(dbSetOrder(2))
	If B3D->(MsSeek(xFilial("B3D")+cCodOpe+cCodObri+"6"))
		lRet := .F.
			Help( ,, 'HELP',, cMsgErro, 1, 0)
	Else
		B3D->(dbSetOrder(1))
		If B3D->(MsSeek(xFilial("B3D")+cCodOpe+cCodObri+cAno))
			
			Do While !B3D->(Eof()) .And. B3D->(B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI) ==;
					xFilial("B3D")+cCodOpe+cCodObri .and. (B3D->B3D_ANO == cAno .OR. cAno == "")
			
				//Limpar os quadros do compromisso
				If B3D->B3D_TIPOBR == OBR_DIOPS
					PlExQuaCmp(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO)
				EndIf
			
				//Apagar contatos
				If B3E->(MsSeek(xFilial("B3E")+B3D->(B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO)))
			
					Do While B3E->(!Eof()) .And. B3D->(B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO) ==;
							B3E->(B3E_FILIAL+B3E_CODOPE+B3E_CDOBRI+B3E_ANO+B3E_CDCOMP)
					
						Reclock("B3E",.F.)
							B3E->(dbDelete())				
						MsUnlock()
						B3E->(dbSkip())
					EndDo
				EndIf
				
				//Excluir as criticas geradas
				If B3F->(MsSeek(xFilial("B3F")+B3D->(B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO)))
			
					Do While B3F->(!Eof()) .And. B3D->(B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO) ==;
							B3F->(B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP)
					
						Reclock("B3F",.F.)
							B3F->(dbDelete())				
						MsUnlock()
						B3F->(dbSkip())
					EndDo
				EndIf
						
				Reclock("B3D",.F.)
					B3D->(dbDelete())				
				MsUnlock()
				B3D->(dbSkip())
			EndDo
			
		EndIf
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlInComMVC

Função generica para incluir os compromissos de uma obrigacao em um determinado ano utilizando estruturas MVC

@param oModelB3A	Modelo de dados da tabela B3A
@param oModelB3U	Modelo de dados da tabela B3U
@param oModelB3C	Modelo de dados da tabela B3C
@param cAno			Ano do compromisso

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlInComMVC( oModelB3A,oModelB3U,oModelB3C, cAno) 
	Local nI
	Local nJ
	Local nLen := oModelB3C:Length()
	Local nLen2 := oModelB3U:Length()
	Local lInclui := .T.
	Local cDia
	Local cMes

	B3D->(dbSetOrder(1))
	B3E->(dbSetOrder(1))
	For nI = 1 To nLen 

		oModelB3C:GoLine( nI )
		If !oModelB3C:IsDeleted()
			
			cDia		:= AllTrim(Str(oModelB3C:GetValue("B3C_DIAENV"))) 
			cMes		:= AllTrim(Str(oModelB3C:GetValue("B3C_MESENV")))
			
			cAnoEnv :=  oModelB3C:GetValue("B3C_ANOENV")
			cAnoAux := IIf(cAnoEnv == "2",AllTrim(Str(val(cAno)+1)), cAno)
			lInclui := !B3D->(MsSeek(xFilial("B3D")+oModelB3A:GetValue("B3A_CODOPE")+oModelB3A:GetValue("B3A_CODIGO")+cAno+oModelB3C:GetValue("B3C_CDCOMP") ))
			Reclock("B3D",lInclui)		
				B3D->B3D_FILIAL := xFilial("B3D")
				B3D->B3D_CODOPE := oModelB3A:GetValue("B3A_CODOPE") 
				B3D->B3D_CDOBRI := oModelB3A:GetValue("B3A_CODIGO")
				B3D->B3D_CODIGO := oModelB3C:GetValue("B3C_CDCOMP") 
				B3D->B3D_VCTO	:= CtoD(cDia + "/" + cMes + "/" + cAnoAux )
				B3D->B3D_REFERE := AllTrim(oModelB3C:GetValue("B3C_REFERE")) + "/" + subStr(cAno,3,2)
				B3D->B3D_TIPOBR := oModelB3A:GetValue("B3A_TIPO")
				B3D->B3D_AVVCTO := oModelB3A:GetValue("B3A_AVVCTO")
				B3D->B3D_ANO := cAno
				If lInclui
					B3D->B3D_STATUS := "1"
				EndIf
			B3D->(MsUnlock())
			
			If B3D->B3D_TIPOBR == OBR_DIOPS
				PlInQuaCmp(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO,B3D->B3D_TIPOBR)
			EndIf
			
			For nJ = 1 To nLen2 
			
				oModelB3U:GoLine( nJ )
				If !oModelB3U:IsDeleted()
					lInclui := !B3E->(MsSeek(xFilial("B3E")+oModelB3A:GetValue("B3A_CODOPE") +oModelB3A:GetValue("B3A_CODIGO")+cAno+oModelB3C:GetValue("B3C_CDCOMP")+oModelB3U:GetValue("B3U_CODIGO")  ))
					Reclock("B3E",lInclui)		
						B3E->B3E_FILIAL 	:= xFilial("B3D")
						B3E->B3E_CODOPE 	:= oModelB3A:GetValue("B3A_CODOPE") 
						B3E->B3E_CDOBRI 	:= oModelB3A:GetValue("B3A_CODIGO")
						B3E->B3E_ANO 		:= cAno
						B3E->B3E_CDCOMP 	:= oModelB3C:GetValue("B3C_CDCOMP") 
						B3E->B3E_CODIGO 	:= oModelB3U:GetValue("B3U_CODIGO") 
						B3E->B3E_NOME		:= oModelB3U:GetValue("B3U_NOME")
						B3E->B3E_EMAIL 	:= oModelB3U:GetValue("B3U_EMAIL")
					B3E->(MsUnlock())
										
				EndIf
				
			Next nJ

		EndIf
		
	Next nI

Return .T.
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlInComPad

Função generica para incluir os compromissos de uma obrigacao em um determinado ano utilizando Seeks

@param cAno			Ano do compromisso

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlInComPad( cAno ) 
	Local cDia	:= ""
	Local cMes	:= ""
	Local lInclui := .T.
	Default cAno := AllTrim(Str(Year(dDataBase)))

	B3U->(dbSetOrder(1))
	B3C->(dbSetOrder(1))
	B3D->(dbSetOrder(1))
	B3E->(dbSetOrder(1))

	If B3C->(MsSeek(xFilial("B3U")+B3A->(B3A_CODOPE+B3A_CODIGO) ))
		Do While !B3C->(Eof()) .AND. xFilial("B3C")+B3A->(B3A_CODOPE+B3A_CODIGO) == B3C->(B3C_FILIAL+B3C_CODOPE+B3C_CDOBRI) 
			
			cDia		:= AllTrim(Str(B3C->B3C_DIAENV)) 
			cMes		:= AllTrim(Str(B3C->B3C_MESENV))
			
			cAnoEnv :=  B3C->B3C_ANOENV
			cAnoAux := IIf(cAnoEnv == "2",AllTrim(Str(val(cAno)+1)), cAno)
			//B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+B3D_TIPOBR
			lInclui := !B3D->(MsSeek(xFilial("B3D")+B3C->(B3C_CODOPE+B3C_CDOBRI+cAno+B3C_CDCOMP) ))
			Reclock("B3D",lInclui)		
				B3D->B3D_FILIAL := xFilial("B3D")
				B3D->B3D_CODOPE := B3C->B3C_CODOPE
				B3D->B3D_CDOBRI := B3C->B3C_CDOBRI
				B3D->B3D_CODIGO := B3C->B3C_CDCOMP 
				B3D->B3D_VCTO	:= CtoD(cDia + "/" + cMes + "/" + cAnoAux )
				B3D->B3D_REFERE := AllTrim(B3C->B3C_REFERE) + "/" + subStr(cAno,3,2)
				B3D->B3D_TIPOBR := B3A->B3A_TIPO
				B3D->B3D_AVVCTO := B3A->B3A_AVVCTO
				B3D->B3D_ANO := cAno
				If lInclui
					B3D->B3D_STATUS := "1"
				EndIf
			B3D->(MsUnlock())
			
			If B3D->B3D_TIPOBR == OBR_DIOPS
				PlInQuaCmp(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO,B3D->B3D_TIPOBR)
			EndIf

			If B3U->(MsSeek(xFilial("B3U")+B3A->(B3A_CODOPE+B3A_CODIGO)))
				Do While !B3U->(Eof()) .AND. xFilial("B3U")+B3A->(B3A_CODOPE+B3A_CODIGO) == B3U->(B3U_FILIAL+B3U_CODOPE+B3U_CDOBRI)
					lInclui := !B3E->(MsSeek(xFilial("B3E")+B3C->(B3C_CODOPE+B3C_CDOBRI+cAno+B3C_CDCOMP)+B3U->B3U_CODIGO ))
					Reclock("B3E",lInclui)		
						B3E->B3E_FILIAL 	:= xFilial("B3E")
						B3E->B3E_CODOPE 	:= B3U->B3U_CODOPE 
						B3E->B3E_CDOBRI 	:= B3U->B3U_CDOBRI
						B3E->B3E_ANO 		:= cAno
						B3E->B3E_CDCOMP 	:= B3C->B3C_CDCOMP
						B3E->B3E_CODIGO 	:= B3U->B3U_CODIGO 
						B3E->B3E_NOME		:= B3U->B3U_NOME
						B3E->B3E_EMAIL 		:= B3U->B3U_EMAIL
					B3E->(MsUnlock())
											
					B3U->(DbSkip())
				EndDo
			EndIf
			B3C->(DbSkip())
		EndDo
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlCritObr
Funcao criada para verificar se o número de criticas não ultrapassa o limite do grid do MVC

@param cAlias		Area de trabalho corrente

@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------

Function PlCritObr()

	Local cFiltro := " B3F_FILIAL = xFilial( 'B3F' ) .AND. " +;
					" B3F_CODOPE = B3A->B3A_CODOPE .AND. " +;
					" B3F_CDOBRI = B3A->B3A_CODIGO "

	PLBRWCrit(cFiltro)
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlLimitGrid
Funcao criada para verificar se o número de criticas não ultrapassa o limite do grid do MVC

@param cAlias		Area de trabalho corrente

@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlLimitGrid(cOpe,cObri,cAno,cComp)
	Local lRetorno	:= .F.

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ObrigacaoAtiva

Função criada para verificar se já existe obrigação ativa e não permite cadastrar uma nova caso já exista

@author timoteo.bega
@since 15/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ObrigacaoAtiva(cCodOpe,cCodigo,cTipo,cAtivo)
Local lRetorno		:= .T.
Local cSql			:= ""
Local cAliSql		:= GetNextAlias()
Local cMsgErro		:= "Ja existe uma obrigacao Ativa cadastrada. Exclua ou desative a obrigacao para cadastrar / ativar."
Default cCodOpe	:= ""
Default cCodigo	:= ""
Default cTipo		:= ""
Default cAtivo		:= "1"

cSql := "SELECT B3A_CODIGO FROM " + RetSqlName("B3A") + " WHERE B3A_FILIAL='" + xFilial("B3A") + "' AND B3A_CODOPE='"+cCodOpe+"' AND B3A_CODIGO <> '" + cCodigo + "' AND B3A_TIPO='"+cTipo+"' AND B3A_ATIVO='" + cAtivo + "' AND D_E_L_E_T_=' '"
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliSql,.F.,.T.)

If !(cAliSql)->(Eof())
	lRetorno := .F.
	Help( ,, 'HELP',, cMsgErro, 1, 0)
EndIf

(cAliSql)->(dbCloseArea())

Return lRetorno

Function B3AExclui(oModel)
	Local lRet	:= .T.

	If oModel:GetOperation() != MODEL_OPERATION_UPDATE  .And. oModel:GetOperation() != MODEL_OPERATION_INSERT .And. !ExcluiComp(B3A->B3A_CODOPE,B3A->B3A_CODIGO,"",NAO_EXCLUI)
	
		lRet := .F.
		Help( ,, 'HELP',, NAO_EXCLUI, 1, 0,,,,,,{NAO_OPERACAO})

	EndIf
	
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlInQuaCmp

Cria os quadros por compromisso

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function PlInQuaCmp(cCodOpe,cCodObr,cCdComp,cAnoCmp)
	Local aQuadros		:= getQuadrosDiops()
	Local nFor			:= 0
	Local cFilB8X		:= xFilial("B8X")
	Local lInclui		:= .T.
	Local lRetorno		:= .F.
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cCdComp	:= ""
	Default cAnoCmp	:= ""

	B8X->(dbSetOrder(1))
	If Len(aQuadros) >= 1

		lRetorno := .T.

		For nFor := 1 TO Len(aQuadros)
			//B8X_FILIAL+B8X_CODOPE+B8X_CODOBR+B8X_ANOCMP+B8X_CDCOMP+B8X_QUADRO
			GravaB8X(cCodOpe,cCodObr,cCdComp,cAnoCmp,aQuadros[nFor,1])
		Next nFor

	EndIf
	
Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlExQuaCmp

Limpa os quadros por compromisso

@author timoteo.bega
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function PlExQuaCmp(cCodOpe,cCodObr,cCdComp,cAnoCmp)
	Local cDelete		:= ""
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cCdComp	:= ""
	Default cAnoCmp	:= ""
	
	cDelete := "DELETE FROM "+RetSqlName("B8X")+" WHERE B8X_FILIAL='"+xFilial("B8X")+"' AND B8X_CODOPE='"+cCodOpe+"' AND B8X_CODOBR='"+cCodObr+"' AND B8X_CDCOMP='"+cCdComp+"' AND B8X_ANOCMP='"+cAnoCmp+"' "
	TCSQLEXEC(cDelete)
	
Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaB8X

Grava os dados da B8X

@author Jose.paulo
@since 19/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Function GravaB8X(cCodOpe,cCodObr,cCdComp,cAnoCmp,cQuadro)
	Local cFilB8X		:= xFilial("B8X")
	Local lInclui       := .T.
    Local lRetorno      := .F.
    
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cCdComp	:= ""
	Default cAnoCmp	:= ""
	Default cQuadro := ""

	If !Empty(cCodOpe) .And. !Empty(cCodObr) .And. !EMpty(cQuadro)

		lRetorno := .T.
		B8X->(dbSetOrder(1))

		//B8X_FILIAL+B8X_CODOPE+B8X_CODOBR+B8X_ANOCMP+B8X_CDCOMP+B8X_QUADRO
		lInclui := !B8X->(MsSeek(xFilial("B8X")+cCodOpe+cCodObr+cAnoCmp+cCdComp+cQuadro))
	
		RecLock("B8X",lInclui)
			B8X->B8X_FILIAL := cFilB8X
			B8X->B8X_CODOPE := cCodOpe
			B8X->B8X_CODOBR := cCodObr
			B8X->B8X_CDCOMP := cCdComp
			B8X->B8X_ANOCMP := cAnoCmp
			B8X->B8X_RECEBI := '2'//1=Sim;2=Nao
			B8X->B8X_VALIDA := '2'//1=Sim;2=Nao
			B8X->B8X_QUADRO := cQuadro
		B8X->(msUnLock())

	EndIf
	
Return lRetorno 

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} setSazon

Define a sazonalidade de acordo com o tipo da obrigação

@author p.drivas
@since 14/10/2020
/*/
//--------------------------------------------------------------------------------------------------

Static Function setSazon( oView, cIDView, cField, xValue )
	
	Local oModel	:= FWModelActive()
	Local oModelB3A := oModel:GetModel( 'B3AMASTER' )
	Local cTipoObr := oModelB3A:GetValue("B3A_TIPO")
	Local aSazon   := {'3','1','3','5','1'}
	Local aArea    := GetArea()

	FwFldPut("B3A_SZNLDD", aSazon[Val(cTipoObr)]) 
	oview:Refresh( 'VIEW_B3A' )
	PLGridComp( oView, cIDView, cField, xValue )

	RestArea(aArea)

return 
